
# Election app

This election app demostrates running an election on the Etherum blockchain


## Installation

0. Check that one is using node v10.16.0 (npm v6.9.0)

1. Install Truffle, e.g.

    ```
    npm install -g truffle
    ```

2. Install Ganache-CLI, e.g.
    ```
    npm install -g ganache-cli
    ```

3. Install dependencies

    ```
    npm install
    ```

4. Compile and test the smart contracts
    ```
    truffle compile
    ```

    ```
    truffle test
    ```


5. Migrate the smart contracts
    ```
    truffle migrate
    ```

6. Start Ganache (in a separate terminal)
    ```
    ganache-cli
    ```

7. In another terminal, 
   run the server for front-end reloading (of the html/js/css files), 
   note that smart contract changes need to be recompiled and migrated 
   (`truffle migrate --reset`)

    ```
    npm run start
    ```


## Credits

Web assets adapted from TodoList example at http://www.dappuniversity.com/articles/blockchain-app-tutorial
