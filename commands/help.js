//Get variables from the settings.
var bot = process.settings.discord.user;
var symbol = process.settings.coin.symbol;
var decimals = process.settings.coin.decimals;
var fee;
//Default help tect.
async function prehelp(){
var check = await process.core.coin.getFee();                
    fee = JSON.parse(check.feerate);
}
var help;

module.exports = async (msg) => {
await prehelp();
help = `
**Bitcoin Bot Help**

To run a command, either prefix it with ">" (">deposit", ">tip") or mention the bot ("<@${bot}> deposit", "<@${bot}> tip").

**Do not encapsulate the mentioned user, address or amount with "<>"!**

You can also use "all" instead of any amount to tip or withdraw your entire balance, e.g. (">withdraw all <address>", ">tip all <@user>").

-- *>balance*
Prints your balance.

-- *>tip <@user> <amount>*
Tips the person that amount of ${symbol}.

-- *>withdraw <amount> <address>*
Withdraws AMOUNT to ADDRESS, charging a ${fee} ${symbol} fee.

-- *>deposit*
Prints your personal deposit address.

`;
    msg.obj.reply({
        embed: {
            description: help
        }
    });
};
