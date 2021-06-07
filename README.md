
# Money transfer demo

This example shows how to build an interactive flow that includes processing user input with entites and interaction with database (users_db.json file). If you need any help, join us in our [Developer Community](https://discord.gg/R8mDP2JGmv).

## How to start the demo app

1. Clone the repo and install the dependencies:

```sh
git clone https://github.com/dasha-samples/dasha-money-transfer-demo
cd dasha-money-transfer-demo
npm install
```

2. Create or log into your account using the Dasha CLI tool:

```sh
npx dasha account login
```

3. Run one of the following:
    * To start outbound call run
    ```sh
    npm start <phone_number>
    ```
     (phone number in international format without `+`, for instance `12223334455`).

    When you run with phone_number, app search for user with this phone in database. Make sure that you have this phone in database.
     
    * To start text chat run
    ```sh
    npm start chat <user_id>
    ```

    When you run with user_id, app search for user with this phone in id.

## Examples

AI: Hello, this is Acme bank. How can I help you?   
Human: transfer money from savings to deposit   
AI: Absolutely, we can assist you with that.   
AI: How much money would you like to transfer?   
Human: 100   
AI: Awesome! Let's summarize! Transferring $100 from savings account ending 12 65 to deposit account ending 81 45. Could you confirm?   
Human: yes   
AI: Wait for a second please while I'm executing the transfer.   
AI: Transfer is completed. Have a really nice day!   

################################

AI: Hello, this is Acme bank. How can I help you?   
Human: transfer 50 dollars from savings to wells fargo bank   
AI: Awesome! Let's summarize! Transferring $50 from savings account ending 12 65 to Wells Fargo account ending 92 41. Could you confirm?   
Human: yes   
AI: Wait for a second please while I'm executing the transfer.   
AI: Transfer is completed. Have a really nice day!   

################################

AI: Hello, this is Acme bank. How can I help you?   
Human: transfer 10 dollars to bank of America   
AI: We found that you have multiple accounts. From which one of these two accounts you would like to transfer from?   
AI: from savings account ending 12 65   
AI: from deposit account ending 81 45   
Human: 1265   
AI: Awesome! Let's summarize! Transferring $10 from savings account ending 12 65 to Bank of America account ending 48 79. Could you confirm?   
Human: confirm   
AI: Wait for a second please while I'm executing the transfer.   
AI: Transfer is completed. Have a really nice day!   

################################

AI: Hello, this is Acme bank. How can I help you?   
Human: transfer money   
AI: Absolutely, we can assist you with that.   
AI: How much money would you like to transfer?   
Human: 501   
AI: We found that you have multiple accounts. From which one of these two accounts you would like to transfer from?   
AI: from savings account ending 12 65   
AI: from deposit account ending 81 45   
Human: savings   
AI: I can transfer   
AI: to Wells Fargo account ending 92 41   
AI: to Bank of America account ending 48 79   
AI: to savings account ending 12 65   
AI: to deposit account ending 81 45   
Human: 8145   
AI: Awesome! Let's summarize! Transferring $501 from savings account ending 12 65 to deposit account ending 81 45. Could you confirm?   
Human: yes   
AI: Wait for a second please while I'm executing the transfer.   
AI: Transfer failed. Have a really nice day!   

(Not enough money at savings account)
