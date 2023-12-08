#include <YSI_CODING\Y_HOOKS>
hook OnGameModeInitEx()
{
    print("  [Bank System] Initializing...");
 
    for(new i; i < MAX_BANKERS; i++)
    {
        BankerData[i][bankerActorID] = -1;
 
        #if defined BANKER_USE_MAPICON
        BankerData[i][bankerIconID] = -1;
        #endif
 
        BankerData[i][bankerLabel] = Text3D: -1;
    }
 
    for(new i; i < MAX_ATMS; i++)
    {
        ATMData[i][atmObjID] = -1;
 
        #if defined ATM_USE_MAPICON
        ATMData[i][atmIconID] = -1;
        #endif
        
        #if defined ROBBABLE_ATMS
        ATMData[i][atmTimer] = ATMData[i][atmPickup] = -1;
        ATMData[i][atmHealth] = ATM_HEALTH;
        #endif
 
        ATMData[i][atmLabel] = Text3D: -1;
    }

    new Node:samp_server[2];
    new MYSQL_HOST[24];
    new MYSQL_USER[24];
    new MYSQL_PASS[24];
    new MYSQL_DATABASE[24];
    
    JSON_ParseFile("gamemodes/samp-server.json",samp_server[0]);
    JSON_GetObject(samp_server[0], "mysql", samp_server[1]);
    JSON_GetString(samp_server[1], "host", MYSQL_HOST);
    JSON_GetString(samp_server[1], "username", MYSQL_USER);
    JSON_GetString(samp_server[1], "password", MYSQL_PASS);
    JSON_GetString(samp_server[1], "database", MYSQL_DATABASE);

    BankSQLHandle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DATABASE);
    mysql_log(ERROR | WARNING);
    if(mysql_errno()) return printf("  [Bank System] Can't connect to MySQL. (Error #%d)", mysql_errno());
 
    // create tables if they don't exist
    mysql_tquery(BankSQLHandle, "CREATE TABLE IF NOT EXISTS `bankers` (\
      `ID` int(11) NOT NULL,\
      `Skin` smallint(3) NOT NULL,\
      `PosX` float NOT NULL,\
      `PosY` float NOT NULL,\
      `PosZ` float NOT NULL,\
      `PosA` float NOT NULL\
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
 
    mysql_tquery(BankSQLHandle, "CREATE TABLE IF NOT EXISTS `bank_atms` (\
      `ID` int(11) NOT NULL,\
      `PosX` float NOT NULL,\
      `PosY` float NOT NULL,\
      `PosZ` float NOT NULL,\
      `RotX` float NOT NULL,\
      `RotY` float NOT NULL,\
      `RotZ` float NOT NULL\
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
 
    mysql_tquery(BankSQLHandle, "CREATE TABLE IF NOT EXISTS `bank_accounts` (\
      `ID` int(11) NOT NULL auto_increment,\
      `Owner` varchar(24) NOT NULL,\
      `Password` varchar(32) NOT NULL,\
      `Balance` int(11) NOT NULL,\
      `CreatedOn` int(11) NOT NULL,\
      `LastAccess` int(11) NOT NULL,\
      `Disabled` smallint(1) NOT NULL,\
      PRIMARY KEY  (`ID`)\
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
 
    new query[512];
    mysql_format(BankSQLHandle, query, sizeof(query), "CREATE TABLE IF NOT EXISTS `bank_logs` (\
        `ID` int(11) NOT NULL auto_increment,\
        `AccountID` int(11) NOT NULL,\
        `ToAccountID` int(11) NOT NULL default '-1',\
        `Type` smallint(1) NOT NULL,\
        `Player` varchar(24) NOT NULL,\
        `Amount` int(11) NOT NULL,\
        `Date` int(11) NOT NULL,");
 
    mysql_format(BankSQLHandle, query, sizeof(query), "%s\
        PRIMARY KEY  (`ID`),\
        KEY `bank_logs_ibfk_1` (`AccountID`),\
        CONSTRAINT `bank_logs_ibfk_1` FOREIGN KEY (`AccountID`) REFERENCES `bank_accounts` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE\
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;", query);
 
    mysql_tquery(BankSQLHandle, query);
 
    print("  [Bank System] Connected to MySQL, loading data...");
    mysql_tquery(BankSQLHandle, "SELECT * FROM bankers", "LoadBankers");
    mysql_tquery(BankSQLHandle, "SELECT * FROM bank_atms", "LoadATMs");
    return 1;
}
 
hook OnGameModeExit()
{
    foreach(new i : Bankers)
    {
        if(IsValidActor(BankerData[i][bankerActorID])) DestroyActor(BankerData[i][bankerActorID]);
    }
 
    print("  [Bank System] Unloaded.");
    mysql_close(BankSQLHandle);
    return 1;
}
 
hook OnPlayerConnect(playerid)
{
    CurrentAccountID[playerid] = -1;
    LogListType[playerid] = TYPE_NONE;
    LogListPage[playerid] = 0;
 
    EditingATMID[playerid] = -1;
    return 1;
}
 
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        /* ---------------------------------------------------------------------- */
        case DIALOG_BANK_MENU_NOLOGIN:
        {
            if(!response) return 1;
            if(listitem == 0)
            {
                if(GetPVarInt(playerid, "usingATM"))
                {
                    SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You can't do this at an ATM, visit a banker.");
                    return Bank_ShowMenu(playerid);
                }
 
                if(ACCOUNT_PRICE > GetMoney(playerid))
                {
                    SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You don't have enough money to create a bank account.");
                    return Bank_ShowMenu(playerid);
                }
 
                #if defined ACCOUNT_CLIMIT
                if(Bank_AccountCount(playerid) >= ACCOUNT_CLIMIT)
                {
                    SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You can't create any more bank accounts.");
                    return Bank_ShowMenu(playerid);
                }
                #endif
 
                ShowPlayerDialog(playerid, DIALOG_BANK_CREATE_ACCOUNT, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Create Account", "Choose a password for your new bank account:", "Create", "Back");
            }
 
            if(listitem == 1) Bank_ListAccounts(playerid);
            if(listitem == 2) ShowPlayerDialog(playerid, DIALOG_BANK_LOGIN_ID, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Login", "Account ID:", "Continue", "Cancel");
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_BANK_MENU:
        {
            if(!response) return 1;
            if(listitem == 0)
            {
                if(GetPVarInt(playerid, "usingATM"))
                {
                    SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You can't do this at an ATM, visit a banker.");
                    return Bank_ShowMenu(playerid);
                }
 
                if(ACCOUNT_PRICE > GetMoney(playerid))
                {
                    SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You don't have enough money to create a bank account.");
                    return Bank_ShowMenu(playerid);
                }
 
                #if defined ACCOUNT_CLIMIT
                if(Bank_AccountCount(playerid) >= ACCOUNT_CLIMIT)
                {
                    SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You can't create any more bank accounts.");
                    return Bank_ShowMenu(playerid);
                }
                #endif
 
                ShowPlayerDialog(playerid, DIALOG_BANK_CREATE_ACCOUNT, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Create Account", "Choose a password for your new bank account:", "Create", "Back");
            }
 
            if(listitem == 1) Bank_ListAccounts(playerid);
            if(listitem == 2) ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSIT, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Deposit", "How much money do you want to deposit?", "Deposit", "Back");
            if(listitem == 3) ShowPlayerDialog(playerid, DIALOG_BANK_WITHDRAW, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Withdraw", "How much money do you want to withdraw?", "Withdraw", "Back");
            if(listitem == 4) ShowPlayerDialog(playerid, DIALOG_BANK_TRANSFER_1, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Transfer", "Specify an account ID:", "Continue", "Back");
			if(listitem == 5)
			{
				if(PlayerData[playerid][pPaycheck] > 0 && AccountData[playerid][uAdmin] < 2)
					return SendErrorMessage(playerid, "Kamu harus menunggu %d menit untuk Paycheck!", PlayerData[playerid][pPaycheck]/60);

				new str[256];
				new taxval = PlayerData[playerid][pSalary]/100*GovData[govTax];
				format(str, sizeof(str), "{FFFFFF}Salary: {009000}$%s\n{FFFFFF}Tax: {FFFF00}-$%s {FF0000}(%d percent)\n{FFFFFF}Total Interest: {00FF00}$%s", FormatMoney(PlayerData[playerid][pSalary]), FormatMoney(taxval), GovData[govTax], FormatMoney(PlayerData[playerid][pSalary]-taxval));
				Dialog_Show(playerid, salary_paycheck, DIALOG_STYLE_MSGBOX, "Paycheck", str, "Get", "Close");
			}
            if(listitem == 6)
            {
                if(GetPVarInt(playerid, "usingATM"))
                {
                    SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You can't do this at an ATM, visit a banker.");
                    return Bank_ShowMenu(playerid);
                }
 
                Bank_ShowLogMenu(playerid);
            }
 
            if(listitem == 7)
            {
                if(GetPVarInt(playerid, "usingATM"))
                {
                    SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You can't do this at an ATM, visit a banker.");
                    return Bank_ShowMenu(playerid);
                }
 
                if(strcmp(Bank_GetOwner(CurrentAccountID[playerid]), Player_GetName(playerid)))
                {
                    SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only the account owner can do this.");
                    return Bank_ShowMenu(playerid);
                }
 
                ShowPlayerDialog(playerid, DIALOG_BANK_PASSWORD, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Change Password", "Write a new password:", "Change", "Back");
            }
 
            if(listitem == 8)
            {
                if(GetPVarInt(playerid, "usingATM"))
                {
                    SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You can't do this at an ATM, visit a banker.");
                    return Bank_ShowMenu(playerid);
                }
 
                if(strcmp(Bank_GetOwner(CurrentAccountID[playerid]), Player_GetName(playerid)))
                {
                    SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only the account owner can do this.");
                    return Bank_ShowMenu(playerid);
                }
 
                ShowPlayerDialog(playerid, DIALOG_BANK_REMOVE, DIALOG_STYLE_MSGBOX, "{F1C40F}Bank: {FFFFFF}Remove Account", "Are you sure? This account will get deleted {E74C3C}permanently.", "Yes", "Back");
                // https://youtu.be/rcjpags7JT8 - because it doesn't get deleted actually
            }
 
            if(listitem == 9)
            {
                SendClientMessage(playerid, 0x3498DBFF, "BANK: {FFFFFF}Successfully logged out.");
 
                CurrentAccountID[playerid] = -1;
                Bank_ShowMenu(playerid);
            }
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_BANK_CREATE_ACCOUNT:
        {
            if(!response) return Bank_ShowMenu(playerid);
            if(isnull(inputtext)) return ShowPlayerDialog(playerid, DIALOG_BANK_CREATE_ACCOUNT, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Create Account", "{E74C3C}You can't leave your account password empty.\n\n{FFFFFF}Choose a password for your new bank account:", "Create", "Back");
            if(strlen(inputtext) > 16) return ShowPlayerDialog(playerid, DIALOG_BANK_CREATE_ACCOUNT, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Create Account", "{E74C3C}Account password can't be more than 16 characters.\n\n{FFFFFF}Choose a password for your new bank account:", "Create", "Back");
            if(ACCOUNT_PRICE > GetMoney(playerid))
            {
                SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You don't have enough money to create a bank account.");
                return Bank_ShowMenu(playerid);
            }
 
            #if defined ACCOUNT_CLIMIT
            if(Bank_AccountCount(playerid) >= ACCOUNT_CLIMIT)
            {
                SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You can't create any more bank accounts.");
                return Bank_ShowMenu(playerid);
            }
            #endif
 
            new query[144];
            mysql_format(BankSQLHandle, query, sizeof(query), "INSERT INTO bank_accounts SET Owner='%e', Password=md5('%e'), CreatedOn=UNIX_TIMESTAMP()", Player_GetName(playerid), inputtext);
            mysql_tquery(BankSQLHandle, query, "OnBankAccountCreated", "is", playerid, inputtext);
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_BANK_ACCOUNTS:
        {
            if(!response) return Bank_ShowMenu(playerid);
 
            SetPVarInt(playerid, "bankLoginAccount", strval(inputtext));
            ShowPlayerDialog(playerid, DIALOG_BANK_LOGIN_PASS, DIALOG_STYLE_PASSWORD, "{F1C40F}Bank: {FFFFFF}Login", "Account Password:", "Login", "Cancel");
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_BANK_LOGIN_ID:
        {
            if(!response) return Bank_ShowMenu(playerid);
            if(isnull(inputtext)) return ShowPlayerDialog(playerid, DIALOG_BANK_LOGIN_ID, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Login", "{E74C3C}You can't leave the ID empty.\n\n{FFFFFF}Account ID:", "Continue", "Cancel");
 
            SetPVarInt(playerid, "bankLoginAccount", strval(inputtext));
            ShowPlayerDialog(playerid, DIALOG_BANK_LOGIN_PASS, DIALOG_STYLE_PASSWORD, "{F1C40F}Bank: {FFFFFF}Login", "Account Password:", "Login", "Cancel");
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_BANK_LOGIN_PASS:
        {
            if(!response) return Bank_ShowMenu(playerid);
            if(isnull(inputtext)) return ShowPlayerDialog(playerid, DIALOG_BANK_LOGIN_PASS, DIALOG_STYLE_PASSWORD, "{F1C40F}Bank: {FFFFFF}Login", "{E74C3C}You can't leave the password empty.\n\n{FFFFFF}Account Password:", "Login", "Cancel");
 
            new query[200], id = GetPVarInt(playerid, "bankLoginAccount");
            mysql_format(BankSQLHandle, query, sizeof(query), "SELECT Owner, LastAccess, FROM_UNIXTIME(LastAccess, '%%d/%%m/%%Y %%H:%%i:%%s') AS Last FROM bank_accounts WHERE ID=%d && Password=md5('%e') && Disabled=0 LIMIT 1", id, inputtext);
            mysql_tquery(BankSQLHandle, query, "OnBankAccountLogin", "ii", playerid, id);
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_BANK_DEPOSIT:
        {
            if(!response) return Bank_ShowMenu(playerid);
            if(CurrentAccountID[playerid] == -1) return 1;
            if(isnull(inputtext)) return ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSIT, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Deposit", "{E74C3C}You can't leave the input empty.\n\n{FFFFFF}How much money do you want to deposit?", "Deposit", "Back");
            new amount = strval(inputtext);
            if(!(1 <= amount <= (GetPVarInt(playerid, "usingATM") ? 5000000 : 250000000))) return ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSIT, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Deposit", "{E74C3C}You can't deposit less than $1 or more than $250,000,000 at once. ($5,000,000 at once on ATMs)\n\n{FFFFFF}How much money do you want to deposit?", "Deposit", "Back");
            if(amount > GetMoney(playerid)) return ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSIT, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Deposit", "{E74C3C}You don't have enough money.\n\n{FFFFFF}How much money do you want to deposit?", "Deposit", "Back");
            if((amount + Bank_GetBalance(CurrentAccountID[playerid])) > ACCOUNT_LIMIT)
            {
                SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You can't deposit any more money to this account.");
                return Bank_ShowMenu(playerid);
            }
 
            new query[96];
            mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_accounts SET Balance=Balance+%d WHERE ID=%d && Disabled=0", amount, CurrentAccountID[playerid]);
            mysql_tquery(BankSQLHandle, query, "OnBankAccountDeposit", "ii", playerid, amount);
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_BANK_WITHDRAW:
        {
            if(!response) return Bank_ShowMenu(playerid);
            if(CurrentAccountID[playerid] == -1) return 1;
            if(isnull(inputtext)) return ShowPlayerDialog(playerid, DIALOG_BANK_WITHDRAW, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Withdraw", "{E74C3C}You can't leave the input empty.\n\n{FFFFFF}How much money do you want to withdraw?", "Withdraw", "Back");
            new amount = strval(inputtext);
            if(!(1 <= amount <= (GetPVarInt(playerid, "usingATM") ? 5000000 : 250000000))) return ShowPlayerDialog(playerid, DIALOG_BANK_WITHDRAW, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Withdraw", "{E74C3C}You can't withdraw less than $1 or more than $250,000,000 at once. ($5,000,000 at once on ATMs)\n\n{FFFFFF}How much money do you want to withdraw?", "Withdraw", "Back");
            if(amount > Bank_GetBalance(CurrentAccountID[playerid])) return ShowPlayerDialog(playerid, DIALOG_BANK_WITHDRAW, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Withdraw", "{E74C3C}Account doesn't have enough money.\n\n{FFFFFF}How much money do you want to withdraw?", "Withdraw", "Back");
 
            new query[96];
            mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_accounts SET Balance=Balance-%d WHERE ID=%d && Disabled=0", amount, CurrentAccountID[playerid]);
            mysql_tquery(BankSQLHandle, query, "OnBankAccountWithdraw", "ii", playerid, amount);
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_BANK_TRANSFER_1:
        {
            if(!response) return Bank_ShowMenu(playerid);
            if(CurrentAccountID[playerid] == -1) return 1;
            if(isnull(inputtext)) return ShowPlayerDialog(playerid, DIALOG_BANK_TRANSFER_1, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Transfer", "{E74C3C}You can't leave the input empty.\n\n{FFFFFF}Specify an account ID:", "Continue", "Back");
            if(strval(inputtext) == CurrentAccountID[playerid]) return ShowPlayerDialog(playerid, DIALOG_BANK_TRANSFER_1, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Transfer", "{E74C3C}You can't transfer money to your current account.\n\n{FFFFFF}Specify an account ID:", "Continue", "Back");
            SetPVarInt(playerid, "bankTransferAccount", strval(inputtext));
            ShowPlayerDialog(playerid, DIALOG_BANK_TRANSFER_2, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Transfer", "Specify an amount:", "Transfer", "Back");
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_BANK_TRANSFER_2:
        {
            if(!response) return ShowPlayerDialog(playerid, DIALOG_BANK_TRANSFER_1, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Transfer", "Specify an account ID:", "Continue", "Back");
            if(CurrentAccountID[playerid] == -1) return 1;
            if(isnull(inputtext)) return ShowPlayerDialog(playerid, DIALOG_BANK_TRANSFER_2, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Transfer", "{E74C3C}You can't leave the input empty.\n\n{FFFFFF}Specify an amount:", "Transfer", "Back");
            new amount = strval(inputtext);
            if(!(1 <= amount <= (GetPVarInt(playerid, "usingATM") ? 5000000 : 250000000))) return ShowPlayerDialog(playerid, DIALOG_BANK_TRANSFER_2, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Transfer", "{E74C3C}You can't transfer less than $1 or more than $250,000,000 at once. ($5,000,000 on ATMs)\n\n{FFFFFF}Specify an amount:", "Transfer", "Back");
            if(amount > Bank_GetBalance(CurrentAccountID[playerid])) return ShowPlayerDialog(playerid, DIALOG_BANK_TRANSFER_2, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Transfer", "{E74C3C}Account doesn't have enough money.\n\n{FFFFFF}Specify an amount:", "Transfer", "Back");
            new id = GetPVarInt(playerid, "bankTransferAccount");
            if((amount + Bank_GetBalance(id)) > ACCOUNT_LIMIT)
            {
                SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Can't deposit any more money to the account you specified.");
                return Bank_ShowMenu(playerid);
            }
 
            new query[96];
            mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_accounts SET Balance=Balance+%d WHERE ID=%d && Disabled=0", amount, id);
            mysql_tquery(BankSQLHandle, query, "OnBankAccountTransfer", "iii", playerid, id, amount);
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_BANK_PASSWORD:
        {
            if(!response) return Bank_ShowMenu(playerid);
            if(CurrentAccountID[playerid] == -1) return 1;
            if(isnull(inputtext)) return ShowPlayerDialog(playerid, DIALOG_BANK_PASSWORD, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Change Password", "{E74C3C}You can't leave the input empty.\n\n{FFFFFF}Write a new password:", "Change", "Back");
            if(strlen(inputtext) > 16) return ShowPlayerDialog(playerid, DIALOG_BANK_PASSWORD, DIALOG_STYLE_INPUT, "{F1C40F}Bank: {FFFFFF}Change Password", "{E74C3C}New password can't be more than 16 characters.\n\n{FFFFFF}Write a new password:", "Change", "Back");
 
            new query[128];
            mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_accounts SET Password=md5('%e') WHERE ID=%d && Disabled=0", inputtext, CurrentAccountID[playerid]);
            mysql_tquery(BankSQLHandle, query, "OnBankAccountPassChange", "is", playerid, inputtext);
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_BANK_REMOVE:
        {
            if(!response) return Bank_ShowMenu(playerid);
            if(CurrentAccountID[playerid] == -1) return 1;
 
            new query[96], amount = Bank_GetBalance(CurrentAccountID[playerid]);
            mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_accounts SET Disabled=1 WHERE ID=%d", CurrentAccountID[playerid]);
            mysql_tquery(BankSQLHandle, query, "OnBankAccountDeleted", "iii", playerid, CurrentAccountID[playerid], amount);
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_BANK_LOGS:
        {
            if(!response) return Bank_ShowMenu(playerid);
            if(CurrentAccountID[playerid] == -1) return 1;
 
            new typelist[6] = {TYPE_NONE, TYPE_DEPOSIT, TYPE_WITHDRAW, TYPE_TRANSFER, TYPE_LOGIN, TYPE_PASSCHANGE};
            LogListType[playerid] = typelist[listitem + 1];
            LogListPage[playerid] = 0;
            Bank_ShowLogs(playerid);
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_BANK_LOG_PAGE:
        {
            if(CurrentAccountID[playerid] == -1 || LogListType[playerid] == TYPE_NONE) return 1;
            if(!response) {
                LogListPage[playerid]--;
                if(LogListPage[playerid] < 0) return Bank_ShowLogMenu(playerid);
            }else{
                LogListPage[playerid]++;
            }
 
            Bank_ShowLogs(playerid);
            return 1;
        }
        /* ---------------------------------------------------------------------- */
    }
 
    return 0;
}
 
hook OnPlayerEditDynObj(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
    if(Iter_Contains(ATMs, EditingATMID[playerid]))
    {
        if(response == EDIT_RESPONSE_FINAL)
        {
            new id = EditingATMID[playerid];
            ATMData[id][atmX] = x;
            ATMData[id][atmY] = y;
            ATMData[id][atmZ] = z;
            ATMData[id][atmRX] = rx;
            ATMData[id][atmRY] = ry;
            ATMData[id][atmRZ] = rz;
 
            SetDynamicObjectPos(objectid, ATMData[id][atmX], ATMData[id][atmY], ATMData[id][atmZ]);
            SetDynamicObjectRot(objectid, ATMData[id][atmRX], ATMData[id][atmRY], ATMData[id][atmRZ]);
 
            #if defined ATM_USE_MAPICON
            Streamer_SetFloatData(STREAMER_TYPE_MAP_ICON, ATMData[id][atmIconID], E_STREAMER_X, ATMData[id][atmX]);
            Streamer_SetFloatData(STREAMER_TYPE_MAP_ICON, ATMData[id][atmIconID], E_STREAMER_Y, ATMData[id][atmY]);
            Streamer_SetFloatData(STREAMER_TYPE_MAP_ICON, ATMData[id][atmIconID], E_STREAMER_Z, ATMData[id][atmZ]);
            #endif
 
            Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, ATMData[id][atmLabel], E_STREAMER_X, ATMData[id][atmX]);
            Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, ATMData[id][atmLabel], E_STREAMER_Y, ATMData[id][atmY]);
            Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, ATMData[id][atmLabel], E_STREAMER_Z, ATMData[id][atmZ] + 0.85);
 
            new query[144];
            mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_atms SET PosX='%f', PosY='%f', PosZ='%f', RotX='%f', RotY='%f', RotZ='%f' WHERE ID=%d", x, y, z, rx, ry, rz, id);
            mysql_tquery(BankSQLHandle, query);
 
            EditingATMID[playerid] = -1;
        }
 
        if(response == EDIT_RESPONSE_CANCEL)
        {
            new id = EditingATMID[playerid];
            SetDynamicObjectPos(objectid, ATMData[id][atmX], ATMData[id][atmY], ATMData[id][atmZ]);
            SetDynamicObjectRot(objectid, ATMData[id][atmRX], ATMData[id][atmRY], ATMData[id][atmRZ]);
            EditingATMID[playerid] = -1;
        }
    }
 
    return 1;
}
 
#if defined ROBBABLE_ATMS
hook OnPlayerShootDynObj(playerid, weaponid, STREAMER_TAG_OBJECT:objectid, Float:x, Float:y, Float:z)
{
    if(Streamer_GetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_MODEL_ID) == 19324)
    {
        new dataArray[E_ATMDATA];
        Streamer_GetArrayData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, dataArray);
 
        if(strlen(dataArray[IDString]) && !strcmp(dataArray[IDString], "atm_sys") && Iter_Contains(ATMs, dataArray[refID]) && ATMData[ dataArray[refID] ][atmRegen] == 0)
        {
            new id = dataArray[refID], string[64], Float: damage = GetWeaponDamageFromDistance(weaponid, GetPlayerDistanceFromPoint(playerid, ATMData[id][atmX], ATMData[id][atmY], ATMData[id][atmZ])) / 1.5;
            ATMData[id][atmHealth] -= damage;
 
            if(ATMData[id][atmHealth] < 0.0) {
                ATMData[id][atmHealth] = 0.0;
 
                format(string, sizeof(string), "ATM (%d)\n\n{FFFFFF}Out of Service\n{E74C3C}%s", id, ConvertToMinutes(ATM_REGEN));
                UpdateDynamic3DTextLabelText(ATMData[id][atmLabel], 0x1ABC9CFF, string);
 
                ATMData[id][atmRegen] = ATM_REGEN;
                ATMData[id][atmTimer] = SetTimerEx("ATM_Regen", 1000, true, "i", id);
                Streamer_SetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_MODEL_ID, 2943);
 
                new Float: a = ATMData[id][atmRZ] + 180.0;
                ATMData[id][atmPickup] = CreateDynamicPickup(1212, 1, ATMData[id][atmX] + (1.25 * floatsin(-a, degrees)), ATMData[id][atmY] + (1.25 * floatcos(-a, degrees)), ATMData[id][atmZ] - 0.25);
 
                if(IsValidDynamicPickup(ATMData[id][atmPickup]))
                {
                    new pickupDataArray[E_ATMDATA];
                    format(pickupDataArray[IDString], 8, "atm_sys");
                    pickupDataArray[refID] = id;
                    Streamer_SetArrayData(STREAMER_TYPE_PICKUP, ATMData[id][atmPickup], E_STREAMER_EXTRA_ID, pickupDataArray);
                }
 
                Streamer_Update(playerid);
            }else{
                format(string, sizeof(string), "ATM (%d)\n\n{FFFFFF}Use {F1C40F}/atm!\n%s", id, ATM_ReturnDmgText(id));
                UpdateDynamic3DTextLabelText(ATMData[id][atmLabel], 0x1ABC9CFF, string);
            }
 
            PlayerPlaySound(playerid, 17802, 0.0, 0.0, 0.0);
        }
    }
 
    return 1;
}
 
hook OnPlayerPickUpDynPickup(playerid, pickupid)
{
    if(Streamer_GetIntData(STREAMER_TYPE_PICKUP, pickupid, E_STREAMER_MODEL_ID) == 1212)
    {
        new dataArray[E_ATMDATA];
        Streamer_GetArrayData(STREAMER_TYPE_PICKUP, pickupid, E_STREAMER_EXTRA_ID, dataArray);
 
        if(strlen(dataArray[IDString]) && !strcmp(dataArray[IDString], "atm_sys"))
        {
            new money = RandomEx(ATM_ROB_MIN, ATM_ROB_MAX), string[64];
            format(string, sizeof(string), "ATM: {FFFFFF}You stole {2ECC71}%s {FFFFFF}from the ATM.", FormatMoney(money));
            SendClientMessage(playerid, 0x3498DBFF, string);
            GivePlayerMoney(playerid, money);
 
            ATMData[ dataArray[refID] ][atmPickup] = -1;
            DestroyDynamicPickup(pickupid);
        }
    }
 
    return 1;
}
#endif