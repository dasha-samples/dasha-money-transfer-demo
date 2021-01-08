import "commonReactions/all.dsl";

/**
* Context declaration.
*/
context
{
    input phone: string;
    amount: string="";
    source_account: string="";
    target_account: string="";
    input depositNumber: string;
    input savingsNumber: string;
    tmpInfo: TmpInfoType="";
    firstTry: boolean=true;
    output result:boolean=false;
}

/**
* Type alias declarations.
*/
type TmpInfoType = < string|
{
    [x:string]:string;
}
[]
>;

/**
* External call declarations.
*/
external function transfer_money(amount: string, from: string, to: string): boolean;
external function resolve_target_account(info: TmpInfoType): string;
external function resolve_source_account(info: TmpInfoType): string;
external function get_target_accounts(): string[];

/**
* Script.
*/
start node root
{
    do
    {
        #connectSafe($phone);
        wait *;
    }
    transitions
    {
        greeting: goto greeting on true;
    }
}

node greeting
{
    do
    {
        #say("greeting");
        wait *;
    }
    transitions
    {
        transfer_money: goto transfer_money on #messageHasIntent("transfer_money");
    }
}

node transfer_money
{
    do
    {
        #say("will_help");
        #say("how_much");
        wait *;
    }
    transitions
    {
        amount: goto amount_confirmation on #messageHasData("numberword",
        {
            value: true
        }
        );
    }
    onexit
    {
        amount: do
        {
            set $amount = #messageGetData("numberword",
            {
                value: true
            }
            )[0]?.value??"no_data";
        }
    }
}

node amount_confirmation
{
    do
    {
        set $firstTry=true;
        #say("ask_amount_confirmation",
        {
            amount: $amount
        }
        );
        wait *;
    }
    transitions
    {
        positive: goto select_source_account on #messageHasSentiment("positive");
        negative: goto transfer_money on #messageHasSentiment("negative");
    }
}

node select_source_account
{
    do
    {
        if(!$firstTry)
        {
            set $source_account = external resolve_source_account($tmpInfo);
            if ($source_account == "unknown")
            {
                #say("dont_understand");
                goto loop;
            }
            goto @exit;
        }
        set $firstTry=false;
        #say("select_source_account");
        #say("source_account_variants",
        {
            depositNumber :$depositNumber,
            savingsNumber :$savingsNumber
        }
        );
        wait *;
    }
    transitions
    {
        deposit: goto select_source_account on #messageHasIntent("deposit");
        savings: goto select_source_account on #messageHasIntent("savings");
        @number: goto select_source_account on #messageHasData("numberword",
        {
            value: true
        }
        );
        loop: goto select_source_account;
        @exit: goto select_target_account;
    }
    onexit
    {
        deposit: do
        {
            set $tmpInfo = "deposit";
        }
        savings: do
        {
            set $tmpInfo = "savings";
        }
        @number: do
        {
            set $tmpInfo = #messageGetData("numberword",
            {
                value: true
            }
            );
        }
        loop:
        @exit: do
        {
            set $firstTry=true;
        }
    }
}

node select_target_account
{
    do
    {
        if(!$firstTry)
        {
            set $target_account = external resolve_target_account($tmpInfo);
            if ($target_account == "unknown")
            {
                #say("dont_understand");
                goto loop;
            }
            goto @exit;
        }
        set $firstTry=false;
        
        var accounts: string[] = external get_target_accounts();
        #say("select_target_account");
        #say("dynamic_transit_id",
        {
            @number: accounts[0]
        }
        );
        #say("dynamic_transit_id",
        {
            @number: accounts[1]
        }
        );
        #say("dynamic_transit_id",
        {
            @number: accounts[2]
        }
        );

        wait *;
    }
    transitions
    {
        wells_fargo: goto select_target_account on #messageHasIntent("wells_fargo");
        account_number: goto select_target_account on #messageHasData("numberword",
        {
            value: true
        }
        );
        loop: goto select_target_account;
        @exit: goto account_confirmation;
    }
    onexit
    {
        wells_fargo: do
        {
            set $tmpInfo = "wells_fargo";
        }
        account_number: do
        {
            set $tmpInfo = #messageGetData("numberword",
            {
                value: true
            }
            );
        }
        loop:
        @exit: do
        {
            set $firstTry=true;
        }
    }
}

node account_confirmation
{
    do
    {
        #say("ask_account_confirmation",
        {
            account: $target_account
        }
        );
        wait *;
    }
    transitions
    {
        positive: goto transfer_confirmation on #messageHasSentiment("positive");
        negative: goto select_target_account on #messageHasSentiment("negative");
    }
}

node transfer_confirmation
{
    do
    {
        #say("ask_transfer_confirmation_amount",
        {
            amount: $amount
        }
        );
        #say("ask_transfer_confirmation_source",
        {
            source_account: $source_account
        }
        );
        #say("ask_transfer_confirmation_target",
        {
            target_account: $target_account
        }
        );
        wait *;
    }
    transitions
    {
        positive: goto process_transfer on #messageHasSentiment("positive");
        negative: goto transfer_money on #messageHasSentiment("negative");
    }
}

node process_transfer
{
    do
    {
        #say("wait_for_processing");
        set $result = external transfer_money($amount, $source_account, $target_account);
        if($result)
        {
            #say("transfer_success");
        }
        else
        {
            #say("transfer_failed");
        }
        #disconnect();
        exit;
    }
    transitions
    {
    }
}

