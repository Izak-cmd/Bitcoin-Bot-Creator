# Bitcoin-Bot-Creator

A Shell Script designed to create a Discord Bitcoin Bot.

## Getting Started

Simply place the CreateBot.sh in your /home/user folder
You do not need to create a folder.

### What is Installed

```
Discord.js
NodeJs v12.6.2
NPM v6.14.4
PM2 v4.3.0
```

A clean virtual private server is best. 
If you have previously installed any of the above modules of a lower version, they may be updated.

### Installing

To download this repository directly to your server, you can run the ```sudo wget https://raw.githubusercontent.com/Izak-cmd/Bitcoin-Bot-Creator/CreateBot.sh``` and execute it using ```sudo bash CreateBot.sh```.

Installation Instructions:
- Install Bitcore, transactions will not be confirmed by the bot while it is unsynced.
    - Edit the conf file to add `server=1`, `rpcuser=user`, and `rpcpass=pass` (with your own username and password).
    - Start the daemon.
    - Edit the `settings.json` file's `coin` object to have:
        - `user` set to the username you set in the your .conf file ("user").
        - `pass` set to the password you set in the your .conf file ("pass").

- Install MySQL
    - Create a Database
    - Create a Table with `name VARCHAR(64), address VARCHAR(64), balance VARCHAR(64), notification tinyint(1)`.
    - Edit the `settings.json` file's `mysql` var to have:
        - `db` set to the name of the database you made for the bot.
        - `table` set to the name of the table you made for the bot.
        - `user` set to the name of a MySQL user with access to the database.
        - `pass` set to the password of that MySQL user.

### Compatibility
The bot produced by this script can run other coin based systems and is capable of running Litecoin, Dash and Bitcoin, but not ERC20 Tokens.

### Errors

Common errors that will occur will be related to the MySQL connection/permissions and/or Bitcore RPC connection. Please ensure you assign appropriate permissions.

## Authors

* **Isaac Goodrick** - *Initial work* - [Izak](https://github.com/Izak-cmd)

## License

This project is licensed under the CC0 License and is free for distribution, modification and use in commercial applications - see the [LICENSE.md](LICENSE.md) file for details.
