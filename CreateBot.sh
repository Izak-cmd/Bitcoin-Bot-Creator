#!/bin/sh
#Declare distinguishable features
bold=$(tput bold)
normal=$(tput sgr0)
#Delcare Input Strings Required
PROCESS=""
INPUT=""
TOKENINPUT=""
STRINGINPUT=""
#Directory is equal to the directory of the bash script
#Which should be /home/username/.Create.sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#Start Functions
CheckSudo() {
#sudo is root, root is EUID 0, if not 0 then not sudo
	if (( $EUID != 0 )); then {
#Show the Warning
	clear
	echo -e "${bold}Bitcoin Bot Creator must be run with sudo!${normal}\n"
	echo "Press enter to quit.."
#Get Response and don't show the input as indicated by -s
	read -s Response
#If there is or isn't any input, exit
		if [[ ! -z $Response ]] || [[ -z $Response ]]; then {
		exit 1
		}
		fi
	}
	fi
}
MainOptions() {
#Make Title Bold to make distinguishable
	clear
#-e to allow backslash and backslash interpreter
	echo -e "${bold}Bitcoin Bot Creator ${normal}\n"
	echo -e "\nThe following Modules and Applications will be installed:\nNode.js\nNode Package Manager\nCurl\nProcess Manager(npm)\npromise-mysql(npm)\nbitcoin-core(npm)"
	echo -e "\nBitcore and MySQL must be installed, you will be asked to provide it's directory\nYou will be asked for MySQL credentials, it is best practice to create a user who only has permissions to access the table via a localhost connection\nYou can use an external connection if neccesary.\n\n"
	InstallAcknowledgement
}
NpmProcess() {
	echo "Initializing Node Environment"
	set STRINGINPUT = "${BotDescription}"
	if [[ StringCheck ]]; then {
	echo "${BotDescription}" | tee "${DIR}/${BotName}/README.md"
	sudo npm set init.description README.md
	}
	fi
	sudo npm set init.author.name $BotCreator
	sudo npm set init.author.email $Email
	sudo npm set init.version $BotVersion
	sudo npm set init.license $License
	sudo npm set init.author.author $BotName
	sudo npm set init.main "${BotName}.js"
	sudo npm init --yes
	echo "Installing NPM"
	sudo npm install

}
PmProcess() {
	echo "Installing PM2"
	sudo npm install pm2@latest -g
	sudo npm install express
	sudo pm2 init
	WriteProcessConfig
	sudo pm2 start ${BotName}.js
	echo ${bold}
	sudo pm2 save
	clear
	sudo pm2 status
	echo -e "Installation Complete!\nType 'sudo pm2 logs "${BotName}"' to see the result!"
}
DiscordProcess() {
	echo "Installing Discord.js"
	sudo npm install discord.js -y
	echo "Installing bitcoin-core NPM Module"
	sudo npm install bitcoin-core -y
	sudo npm install promise-mysql -y
	sudo npm install bignumber.js -y
	WriteBasicDiscordBot
	PmProcess
	EmptyID
}
DiscordInputCheck() { 
while [[ $BotName = '' ]]
do
    	echo -e "The Bot Name cannot be Empty!\nAborting!"
	return;
done
clear
	sudo mkdir "${DIR}/${BotName}"
	clear
	cd "${DIR}/${BotName}"
TokenInput
}
# A Basic Javascript Discord Bot
WriteBasicDiscordBot(){
BasicBot='var path = require("path"), fs = require("fs");
var commands;
async function parseMsg(msg) {
    //If the command exists
    if (typeof(commands[msg.text[0]]) !== "undefined") {
        await commands[msg.text[0]](msg);
        return;
    }
    //else warn
    msg.obj.reply("Not a command. Run \"!help\" to get a list of commands or edit your last message.");
}
//Handler
async function handleMessage(msg) {
    //Get the ID of whoever sent the message.
    var sender = msg.author.id;
    //Dont listen to self
    if (sender === process.settings.discord.user) {
        return;
    }
    //Split among spaces.
    var text = msg.content.split(" ").filter((item) => {
        return item !== "";
    });
    //If bot is mentioned, swap it for prefix.
    if (text[0] === process.client.user.toString()) {
        text[1] = ">" + text[1];
        //Remove the ping.
        text.splice(0, 1);
    }
    //Filter message
    text = text
        .join(" ")                          //Convert to string.
        .replace(/[^\x00-\x7F]/g, "")       //Remove unicode.
        .toLowerCase()                      //Convert to lower case.
        .replace(new RegExp("\r", "g"), "") //Remove any \r characters.
        .replace(new RegExp("\n", "g"), "") //Remove any \n characters.
        .split(" ");                        //Split spaces.

    //If the messages first character is not the prefix
    if (text[0].substr(0, 1) !== ">") {
        return;
    }
	//Create an Account
    if  (await process.core.users.create(sender)) {
	//Set Notified        
	await process.core.users.setNotified(sender);
	// If doesnt have an address which is doesnt
    	if (!(await process.core.users.getAddress(msg.sender))) {
	// Set the address with the name equal to the sender ID
        await process.core.users.setAddress(msg.sender, await process.core.coin.createAddress(msg.sender));
    	}
    }
    //Remove the prefix.
    text[0] = text[0].substring(1, text[0].length);
    //If the command is channel locked.
    if (typeof(process.settings.commands[text[0]]) !== "undefined") {
        //If not an approved channel.
        if (process.settings.commands[text[0]].indexOf(msg.channel.id) === -1) {
            //Print the channel that can be used.
            msg.reply("That command can only be run in:\r\n<#" + process.settings.commands[text[0]].join(">\r\n<#") + ">");
            return;
        }
    }	
parseMsg({
        text: text,
        sender: sender,
        obj: msg
    });
}
async function main() {
    //Load settings
    process.settings = require("./settings.json");
    //Load its path separately
    process.settingsPath = path.join(__dirname, "settings.json");
    //Set the core libs to a global object
    process.core = {};
    //Require and init the coin lib, set by the settings.
    process.core.coin = await (require("./core/" + process.settings.coin.type.toLowerCase() + ".js"))();
    //Require and init the users lib.
    process.core.users = await (require("./core/users.js"))();
    //Declare the commands and load them.
    commands = {
        help:     require("./commands/help.js"),
        deposit:  require("./commands/deposit.js"),
        balance:  require("./commands/balance.js"),
        tip:      require("./commands/tip.js"),
        withdraw: require("./commands/withdraw.js")
        //pool:     require("./commands/pool.js"),
        //giveaway: require("./commands/giveaway.js")
    };
    //Create a Discord process.client.
    process.client = new (require("discord.js")).Client();
    //Handle messages.
    process.client.on("message", handleMessage);
    process.client.on("messageUpdate", async (oldMsg, msg) => {
        handleMessage(msg);
    });
    //Connect.
    process.client.login(process.settings.discord.token);

}
(async () => {
    try {
        await main();
    } catch(e) {
        /*eslint no-console: ["error", {allow: ["error"]}]*/
        console.error(e);
    }
})();'
echo "${BasicBot}" | tee "${DIR}/${BotName}/${BotName}.js"
}

WriteSettings(){
Settings='{
 "discord": {
        "token": "DiscordToken",
	"prefix" : ">",
        "admin" : "AdministratorRole",
        "sandbox" : "ChannelID",
        "user": "Bot User ID",
        "giveawayEmoji": "593992166502563865"
    },
    "coin": {
        "type": "btc",
        "symbol": "BTC",
        "host": "localhost",
        "decimals": 8,
        "port": 8332,
        "user": "Username",
        "pass": "Password"
    },
    "mysql": {
	"host": "localhost",
        "db": "DatabaseName",
        "user": "Username",
        "pass": "Password",
	"table": "Tablename"
    },
"commands": {
        "example": [
            "CHANNEL ID"
        ]
    },
    "pools": {
        "pool": {
            "printName": "Pool",
            "admins": [
                "USER ID"
            ],
            "members": []
        },
        "giveaways": {
            "Name": "Giveaways",
            "admins": [],
            "members": []
        }
    }
}'
echo "${Settings}" | tee "${DIR}/${BotName}/settings.json"
}


TokenCheck() { 
while [[ $BotToken = '' ]]
do
   	echo -e "The Bot Name cannot be Empty!\nAborting!"
sudo rm -r "${DIR}/${BotName}"
	return;
done
clear
DiscordConfigCreator
}
DiscordAcknowledgement(){
echo "${normal}Do you wish to continue? (Y/N)"
read Answer
	if [[ $Answer = "Y" || $Answer = "y" || $Answer = "" ]]; then {
	
	DiscordProcess
	
	}
	else {
	sudo rm -r "${DIR}/${BotName}"
	echo "Aborted Install!"
	exit 1
	}
fi
}
InstallAcknowledgement(){
echo "${normal}Do you wish to continue? (Y/N)"
read Answer
	if [[ $Answer = "Y" || $Answer = "y" || $Answer = "" ]]; then {
	clear
	echo -e "${bold}Create Bitcoin Bot ${normal}\n"
	BotNameInput
	}
	else {
	clear
	echo "Aborted Install!"
	exit 1
	}
fi
}
StringCheck(){
while [[ $STRINGINPUT = '' ]]
do
    #If the String is Empty, Continue
	continue;
done
}
EmptyID(){
while [[ $BotID = '' ]]
do
    echo "Client ID has not been provided, so no OAuth link has been provided."
	return;
done
echo -e 'https://discordapp.com/oauth2/authorize?&client_id='${BotID}'&scope=bot&permissions=8\a

Hold CTRL and click the link above to Invite your bot to your server!\a' 
}

BotNameInput(){
echo -e "Please follow the instructions to create your Discord Bot & Node Environment\n\n [Required]"
	read -p "Enter a new Bot Name: " BotName
	set INPUT = "${BotName}"
	DiscordInputCheck
}
TokenInput(){
	echo "[Required]"
	read -p "Enter the Bot Token: " BotToken
	set TOKENINPUT = "${BotToken}"
	TokenCheck
}

WriteProcessConfig(){
PM='module.exports = {
  apps : [{
    script: "'${BotName}'.js",
    watch: "."
  }],

  deploy : {
    production : {
      user : "SSH_USERNAME",
      host : "SSH_HOSTMACHINE",
      ref  : "origin/master",
      repo : "GIT_REPOSITORY",
      path : "DESTINATION_PATH",
      "pre-deploy-local": "",
      "post-deploy" : "npm install && pm2 reload ecosystem.config.js --env production",
      "pre-setup": ""
    }
  }
};'
sudo rm ecosystem.config.js
echo "${PM}" | tee "${DIR}/${BotName}/ecosystem.config.js"
}

DiscordConfigCreator(){
	echo -e "[Optional]\nEnter the Creator Name:"
	read BotCreator
	clear
	echo -e "[Optional]\nCreates an OAuth2 Link at the end of the installation\Enter Bot Client ID:"
	read BotID
	clear
	echo -e "[Optional]\nEnter the Version Number:\nExample: 1.0.1"
	read BotVersion
	clear
	echo -e "[Optional]\nEnter the Creator Email:"
	read Email
	clear	
	echo "Enter the Bot Description:"
	read BotDescription
	clear
	echo -e "[Optional]\nEnter the License Type:\nExample: MIT or CC0"
	read License
	clear	
	echo -e "Name: ${BotName}\nVersion: v${BotVersion}\nBot Directory: ${DIR}/${BotName}\nCreator: ${BotCreator}\nDescription:\n${BotDescription}\nEmail: ${Email}\nLicense: ${License}\n"	
	DiscordAcknowledgement
}
function Installation() {
sudo apt update -y
sudo apt install nodejs -y
sudo apt install npm -y
sudo apt install curl -y
curl -sL https://deb.nodesource.com/setup_12.x | sudo bash - 
sudo apt update -y
sudo apt-get install nodejs -y
sudo apt update -y
}
#End Functions
#Start Script
#Check if run with Sudo
	CheckSudo
#Present Options and interpret the response
	MainOptions

