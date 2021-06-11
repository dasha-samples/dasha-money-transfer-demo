import "commonReactions/all.dsl";


/**
* Type alias declarations.
*/
type Account = { [x:string]:string; }?;

/**
* Context declaration.
*/
context
{
    input phone: string;
    input userAccounts: Account[];
    input bankAccounts: Account[];
    amount: string="";
    source_account: Account=null;
    target_account: Account=null;
    firstTry: boolean=true;
    output result:boolean=false;
}

/**
* External call declarations.
*/
external function transfer_money(amount: string, source: Account, target: Account): boolean;
external function resolve_target_account(account: string): Account;
external function resolve_source_account(account: string): Account;

/**
* Script.
*/
start node root
{
    do
    {
        #connectSafe($phone);
        #waitForSpeech(1000);
        #say("greeting");
        
        wait *;
    }
    transitions
    {
        transfer_money: goto transfer_money on #messageHasIntent("transfer_money");
    }
    onexit
    {
        transfer_money : do
        {
            set $amount = digression.transfer_data.amount;
            if (digression.transfer_data.source_account != "") {
                set $source_account = external resolve_source_account(digression.transfer_data.source_account);
            }
            if (digression.transfer_data.target_account != "") {
                set $target_account = external resolve_target_account(digression.transfer_data.target_account);
            }

            set digression.transfer_data.amount = "";
            set digression.transfer_data.account = "";
        }
    }
}

preprocessor digression transfer_data
{
    conditions
    {
        on true;
    }
    
    var amount: string = "";
    var source_account: string="";
    var target_account: string="";
    var account: string ="";
    
    do
    {
        set digression.transfer_data.amount = #messageGetData("numberword", { value: true })[0]?.value??"";
        
        var accounts = #messageGetData("account", { value: true, tag: true });
        var banks = #messageGetData("bank", { value: true, tag: true });

        for (var account in accounts) {
            if (account.tag == "source") {
                set digression.transfer_data.source_account = account?.value??"";
            }
        }
        for (var bank in banks) {
            if (bank.tag == "source") {
                set digression.transfer_data.source_account = bank?.value??"";
            }
        }
        for (var account in accounts) {
            if (account.tag == "target") {
                set digression.transfer_data.target_account = account?.value??"";
            }
        }
        for (var bank in banks) {
            if (bank.tag == "target") {
                set digression.transfer_data.target_account = bank?.value??"";
            }
        }
        set digression.transfer_data.account = #messageGetData("account", { value: true, tag: false })[0]?.value??"";
        if (digression.transfer_data.account == "") {
            set digression.transfer_data.account = #messageGetData("bank", { value: true, tag: false })[0]?.value??"";
        }
        if (digression.transfer_data.account == "") {
            set digression.transfer_data.account = #messageGetData("numberword", { value: true })[0]?.value??"";
        }
        
        return;
    }
}

node transfer_money
{
    do
    {
        if ($firstTry) #say("will_help");
        set $firstTry = false;
        
        if ($amount == "")
        {
            if (digression.transfer_data.amount == "")
            {
                #say("how_much");
                wait *;
            }
            else
            {
                set $amount = digression.transfer_data.amount;
            }
            set digression.transfer_data.amount = "";
            set digression.transfer_data.account = "";
            goto loop;
        }
        
        if ($source_account is null)
        {
            if (digression.transfer_data.source_account == "" and digression.transfer_data.account == "")
            {
                #say("select_source_account");
                for (var account in $userAccounts) {
                    #say("dynamic_transit_from", { name: account?.name, num: account?.num });
                }
                wait *;
            }
            else
            {                
                var account = digression.transfer_data.source_account != "" 
                    ? digression.transfer_data.source_account
                    : digression.transfer_data.account;
                set $source_account = external resolve_source_account(account);
            }
            set digression.transfer_data.account = "";
            goto loop;
        }
        
        if ($target_account is null)
        {
            if (digression.transfer_data.target_account == "" and digression.transfer_data.account == "")
            {
                #say("select_target_account");
                for (var account in $bankAccounts) {
                    #say("dynamic_transit_to", { name: account?.name, num: account?.num });
                }
                for (var account in $userAccounts) {
                    #say("dynamic_transit_to", { name: account?.name, num: account?.num });
                }
                wait *;
            }
            else
            {
                var account = digression.transfer_data.target_account != "" 
                    ? digression.transfer_data.target_account
                    : digression.transfer_data.account;
                set $target_account = external resolve_target_account(account);
            }
            set digression.transfer_data.account = "";
            goto loop;
        }
        goto confirm;
    }
    transitions
    {
        provide_data: goto transfer_money on #messageHasIntent("transfer_money") or #messageHasData("bank") or #messageHasData("account") or #messageHasData("numberword");
        loop: goto transfer_money;
        confirm: goto transfer_confirmation;
    }
}

node transfer_confirmation
{
    do
    {
        #log($source_account);
        #log($target_account);
        #say("ask_transfer_confirmation",
        {
            amount: $amount,
            source_name: $source_account?.name,
            source_num: $source_account?.num,
            target_name: $target_account?.name,
            target_num: $target_account?.num
        }
        );
        wait *;
    }
    transitions
    {
        positive: goto process_transfer on #messageHasIntent("agreement", "positive");
        negative: goto transfer_money on #messageHasIntent("agreement", "negative");
    }
    onexit 
    {
        negative: do {
            set $amount = "";
            set $source_account = null;
            set $target_account = null;
            set digression.transfer_data.amount = "";
            set digression.transfer_data.source_account = "";
            set digression.transfer_data.target_account = "";
            set digression.transfer_data.account = "";
        }
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
