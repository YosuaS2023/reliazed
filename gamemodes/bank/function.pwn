IsPlayerNearBanker(playerid)
{
    foreach(new i : Bankers)
    {
        if(IsPlayerInRangeOfPoint(playerid, 3.0, BankerData[i][bankerX], BankerData[i][bankerY], BankerData[i][bankerZ])) return 1;
    }
 
    return 0;
}
 
GetClosestATM(playerid, Float: range = 3.0)
{
    new id = -1, Float: dist = range, Float: tempdist;
    foreach(new i : ATMs)
    {
        tempdist = GetPlayerDistanceFromPoint(playerid, ATMData[i][atmX], ATMData[i][atmY], ATMData[i][atmZ]);
 
        if(tempdist > range) continue;
        if(tempdist <= dist)
        {
            dist = tempdist;
            id = i;
        }
    }
 
    return id;
}
 
Bank_SaveLog(playerid, type, accid, toaccid, amount)
{
    if(type == TYPE_NONE) return 1;
    new query[256];
 
    switch(type)
    {
        case TYPE_LOGIN, TYPE_PASSCHANGE: mysql_format(BankSQLHandle, query, sizeof(query), "INSERT INTO bank_logs SET AccountID=%d, Type=%d, Player='%e', Date=UNIX_TIMESTAMP()", accid, type, Player_GetName(playerid));
        case TYPE_DEPOSIT, TYPE_WITHDRAW: mysql_format(BankSQLHandle, query, sizeof(query), "INSERT INTO bank_logs SET AccountID=%d, Type=%d, Player='%e', Amount=%d, Date=UNIX_TIMESTAMP()", accid, type, Player_GetName(playerid), amount);
        case TYPE_TRANSFER: mysql_format(BankSQLHandle, query, sizeof(query), "INSERT INTO bank_logs SET AccountID=%d, ToAccountID=%d, Type=%d, Player='%e', Amount=%d, Date=UNIX_TIMESTAMP()", accid, toaccid, type, Player_GetName(playerid), amount);
    }
 
    mysql_tquery(BankSQLHandle, query);
    return 1;
}
 
Bank_ShowMenu(playerid)
{
    new string[256], using_atm = GetPVarInt(playerid, "usingATM");
    if(CurrentAccountID[playerid] == -1) {
        format(string, sizeof(string), "{%06x}Create Account\t{2ECC71}%s\nMy Accounts\t{F1C40F}%d\nAccount Login", (using_atm ? 0xE74C3CFF >>> 8 : 0xFFFFFFFF >>> 8), (using_atm ? ("") : FormatMoney(ACCOUNT_PRICE)), Bank_AccountCount(playerid));
        ShowPlayerDialog(playerid, DIALOG_BANK_MENU_NOLOGIN, DIALOG_STYLE_TABLIST, "{F1C40F}Bank: {FFFFFF}Menu", string, "Choose", "Close");
    }else{
        new balance = Bank_GetBalance(CurrentAccountID[playerid]), menu_title[64];
        format(menu_title, sizeof(menu_title), "{F1C40F}Bank: {FFFFFF}Menu (Account ID: {F1C40F}%d{FFFFFF})", CurrentAccountID[playerid]);
 
        format(
            string,
            sizeof(string),
            "{%06x}Create Account\t{2ECC71}%s\nMy Accounts\t{F1C40F}%d\nDeposit\t{2ECC71}%s\nWithdraw\t{2ECC71}%s\nTransfer\t{2ECC71}%s\nPaycheck\t{2ECC71}%d\n{%06x}Account Logs\n{%06x}Change Password\n{%06x}Remove Account\nLogout",
            (using_atm ? 0xE74C3CFF >>> 8 : 0xFFFFFFFF >>> 8),
            (using_atm ? ("") : FormatMoney(ACCOUNT_PRICE)),
            Bank_AccountCount(playerid),
            FormatMoney(GetMoney(playerid)),
            FormatMoney(balance),
            FormatMoney(balance),
            FormatMoney(GetPlayerSalary(playerid)),
            (using_atm ? 0xE74C3CFF >>> 8 : 0xFFFFFFFF >>> 8),
            (using_atm ? 0xE74C3CFF >>> 8 : 0xFFFFFFFF >>> 8),
            (using_atm ? 0xE74C3CFF >>> 8 : 0xFFFFFFFF >>> 8)
        );
 
        ShowPlayerDialog(playerid, DIALOG_BANK_MENU, DIALOG_STYLE_TABLIST, menu_title, string, "Choose", "Close");
    }
 
    DeletePVar(playerid, "bankLoginAccount");
    DeletePVar(playerid, "bankTransferAccount");
    return 1;
}
 
Bank_ShowLogMenu(playerid)
{
    LogListType[playerid] = TYPE_NONE;
    LogListPage[playerid] = 0;
    ShowPlayerDialog(playerid, DIALOG_BANK_LOGS, DIALOG_STYLE_LIST, "{F1C40F}Bank: {FFFFFF}Logs", "Deposited Money\nWithdrawn Money\nTransfers\nLogins\nPassword Changes", "Show", "Back");
    return 1;
}
 
Player_GetName(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, MAX_PLAYER_NAME);
    return name;
}
 
Bank_AccountCount(playerid)
{
    new query[144], Cache: find_accounts;
    mysql_format(BankSQLHandle, query, sizeof(query), "SELECT null FROM bank_accounts WHERE Owner='%e' && Disabled=0", Player_GetName(playerid));
    find_accounts = mysql_query(BankSQLHandle, query);
 
    new count = cache_num_rows();
    cache_delete(find_accounts);
    return count;
}
 
Bank_GetBalance(accountid)
{
    new query[144], Cache: get_balance;
    mysql_format(BankSQLHandle, query, sizeof(query), "SELECT Balance FROM bank_accounts WHERE ID=%d && Disabled=0", accountid);
    get_balance = mysql_query(BankSQLHandle, query);
 
    new balance;
    cache_get_value_name_int(0, "Balance", balance);
    cache_delete(get_balance);
    return balance;
}
 
Bank_GetOwner(accountid)
{
    new query[144], owner[MAX_PLAYER_NAME], Cache: get_owner;
    mysql_format(BankSQLHandle, query, sizeof(query), "SELECT Owner FROM bank_accounts WHERE ID=%d && Disabled=0", accountid);
    get_owner = mysql_query(BankSQLHandle, query);
 
    cache_get_value_name(0, "Owner", owner);
    cache_delete(get_owner);
    return owner;
}
 
Bank_ListAccounts(playerid)
{
    new query[256], Cache: get_accounts;
    mysql_format(BankSQLHandle, query, sizeof(query), "SELECT ID, Balance, LastAccess, FROM_UNIXTIME(CreatedOn, '%%d/%%m/%%Y %%H:%%i:%%s') AS Created, FROM_UNIXTIME(LastAccess, '%%d/%%m/%%Y %%H:%%i:%%s') AS Last FROM bank_accounts WHERE Owner='%e' && Disabled=0 ORDER BY CreatedOn DESC", Player_GetName(playerid));
    get_accounts = mysql_query(BankSQLHandle, query);
    new rows = cache_num_rows();
 
    if(rows) {
        new string[1024], acc_id, balance, last_access, cdate[24], ldate[24];
        format(string, sizeof(string), "ID\tBalance\tCreated On\tLast Access\n");
        for(new i; i < rows; ++i)
        {
            cache_get_value_name_int(i, "ID", acc_id);
            cache_get_value_name_int(i, "Balance", balance);
            cache_get_value_name_int(i, "LastAccess", last_access);
            cache_get_value_name(i, "Created", cdate);
            cache_get_value_name(i, "Last", ldate);
            
            format(string, sizeof(string), "%s{FFFFFF}%d\t{2ECC71}%s\t{FFFFFF}%s\t%s\n", string, acc_id, FormatMoney(balance), cdate, (last_access == 0) ? ("Never") : ldate);
        }
 
        ShowPlayerDialog(playerid, DIALOG_BANK_ACCOUNTS, DIALOG_STYLE_TABLIST_HEADERS, "{F1C40F}Bank: {FFFFFF}My Accounts", string, "Login", "Back");
    }else{
        SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You don't have any bank accounts.");
        Bank_ShowMenu(playerid);
    }
 
    cache_delete(get_accounts);
    return 1;
}
 
Bank_ShowLogs(playerid)
{
    new query[196], type = LogListType[playerid], Cache: bank_logs;
    mysql_format(BankSQLHandle, query, sizeof(query), "SELECT *, FROM_UNIXTIME(Date, '%%d/%%m/%%Y %%H:%%i:%%s') as ActionDate FROM bank_logs WHERE AccountID=%d && Type=%d ORDER BY Date DESC LIMIT %d, 15", CurrentAccountID[playerid], type, LogListPage[playerid] * 15);
    bank_logs = mysql_query(BankSQLHandle, query);
 
    new rows = cache_num_rows();
    if(rows) {
        new list[1512], title[96], name[MAX_PLAYER_NAME], date[24];
        switch(type)
        {
            case TYPE_LOGIN:
            {
                format(list, sizeof(list), "By\tAction Date\n");
                format(title, sizeof(title), "{F1C40F}Bank: {FFFFFF}Login History (Page %d)", LogListPage[playerid] + 1);
            }
 
            case TYPE_DEPOSIT:
            {
                format(list, sizeof(list), "By\tAmount\tDeposit Date\n");
                format(title, sizeof(title), "{F1C40F}Bank: {FFFFFF}Deposit History (Page %d)", LogListPage[playerid] + 1);
            }
 
            case TYPE_WITHDRAW:
            {
                format(list, sizeof(list), "By\tAmount\tWithdraw Date\n");
                format(title, sizeof(title), "{F1C40F}Bank: {FFFFFF}Withdraw History (Page %d)", LogListPage[playerid] + 1);
            }
 
            case TYPE_TRANSFER:
            {
                format(list, sizeof(list), "By\tTo Account\tAmount\tTransfer Date\n");
                format(title, sizeof(title), "{F1C40F}Bank: {FFFFFF}Transfer History (Page %d)", LogListPage[playerid] + 1);
            }
 
            case TYPE_PASSCHANGE:
            {
                format(list, sizeof(list), "By\tAction Date\n");
                format(title, sizeof(title), "{F1C40F}Bank: {FFFFFF}Password Changes (Page %d)", LogListPage[playerid] + 1);
            }
        }
 
        new amount, to_acc_id;
        for(new i; i < rows; ++i)
        {
            cache_get_value_name(i, "Player", name);
            cache_get_value_name(i, "ActionDate", date);
 
            switch(type)
            {
                case TYPE_LOGIN:
                {
                    format(list, sizeof(list), "%s%s\t%s\n", list, name, date);
                }
 
                case TYPE_DEPOSIT:
                {
                    cache_get_value_name_int(i, "Amount", amount);
                    format(list, sizeof(list), "%s%s\t{2ECC71}%s\t%s\n", list, name, FormatMoney(amount), date);
                }
 
                case TYPE_WITHDRAW:
                {
                    cache_get_value_name_int(i, "Amount", amount);
                    format(list, sizeof(list), "%s%s\t{2ECC71}%s\t%s\n", list, name, FormatMoney(amount), date);
                }
 
                case TYPE_TRANSFER:
                {
                    cache_get_value_name_int(i, "ToAccountID", to_acc_id);
                    cache_get_value_name_int(i, "Amount", amount);
                    
                    format(list, sizeof(list), "%s%s\t%d\t{2ECC71}%s\t%s\n", list, name, to_acc_id, FormatMoney(amount), date);
                }
 
                case TYPE_PASSCHANGE:
                {
                    format(list, sizeof(list), "%s%s\t%s\n", list, name, date);
                }
            }
        }
 
        ShowPlayerDialog(playerid, DIALOG_BANK_LOG_PAGE, DIALOG_STYLE_TABLIST_HEADERS, title, list, "Next", "Previous");
    }else{
        SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Can't find any more records.");
        Bank_ShowLogMenu(playerid);
    }
 
    cache_delete(bank_logs);
    return 1;
}
 
#if defined ROBBABLE_ATMS
ATM_ReturnDmgText(id)
{
    new Float: health = ATMData[id][atmHealth], color, string[16];
 
    if(health < (ATM_HEALTH / 4)) {
        color = 0xE74C3CFF;
    }else if(health < (ATM_HEALTH / 2)) {
        color = 0xF39C12FF;
    }else{
        color = 0x2ECC71FF;
    }
 
    format(string, sizeof(string), "{%06x}%.2f%%", color >>> 8, (health * 100 / ATM_HEALTH));
    return string;
}
#endif

forward LoadBankers();
public LoadBankers()
{
    new rows = cache_num_rows();
    if(rows)
    {
        new id, label_string[64];
        for(new i; i < rows; i++)
        {
            cache_get_value_name_int(i, "ID", id);
            cache_get_value_name_int(i, "Skin", BankerData[id][Skin]);
            cache_get_value_name_float(i, "PosX", BankerData[id][bankerX]);
            cache_get_value_name_float(i, "PosY", BankerData[id][bankerY]);
            cache_get_value_name_float(i, "PosZ", BankerData[id][bankerZ]);
            cache_get_value_name_float(i, "PosA", BankerData[id][bankerA]);
 
            BankerData[id][bankerActorID] = CreateActor(BankerData[id][Skin], BankerData[id][bankerX], BankerData[id][bankerY], BankerData[id][bankerZ], BankerData[id][bankerA]);
            if(!IsValidActor(BankerData[id][bankerActorID])) {
                printf("  [Bank System] Couldn't create an actor for banker ID %d.", id);
            }else{
                SetActorInvulnerable(BankerData[id][bankerActorID], true); // people may use a version where actors aren't invulnerable by default
            }
 
            #if defined BANKER_USE_MAPICON
            BankerData[id][bankerIconID] = CreateDynamicMapIcon(BankerData[id][bankerX], BankerData[id][bankerY], BankerData[id][bankerZ], 58, 0, .streamdistance = BANKER_ICON_RANGE);
            #endif
 
            format(label_string, sizeof(label_string), "Banker (%d)\n\n{FFFFFF}Use {F1C40F}/bank!", id);
            BankerData[id][bankerLabel] = CreateDynamic3DTextLabel(label_string, 0x1ABC9CFF, BankerData[id][bankerX], BankerData[id][bankerY], BankerData[id][bankerZ] + 0.25, 5.0, .testlos = 1);
 
            Iter_Add(Bankers, id);
        }
    }
 
    printf("  [Bank System] Loaded %d bankers.", Iter_Count(Bankers));
    return 1;
}
 
forward LoadATMs();
public LoadATMs()
{
    new rows = cache_num_rows();
    if(rows)
    {
        new id, label_string[64];
        #if defined ROBBABLE_ATMS
        new dataArray[E_ATMDATA];
        #endif
        
        for(new i; i < rows; i++)
        {
            cache_get_value_name_int(i, "ID", id);
            cache_get_value_name_float(i, "PosX", ATMData[id][atmX]);
            cache_get_value_name_float(i, "PosY", ATMData[id][atmY]);
            cache_get_value_name_float(i, "PosZ", ATMData[id][atmZ]);
            cache_get_value_name_float(i, "RotX", ATMData[id][atmRX]);
            cache_get_value_name_float(i, "RotY", ATMData[id][atmRY]);
            cache_get_value_name_float(i, "RotZ", ATMData[id][atmRZ]);
 
            ATMData[id][atmObjID] = CreateDynamicObject(19324, ATMData[id][atmX], ATMData[id][atmY], ATMData[id][atmZ], ATMData[id][atmRX], ATMData[id][atmRY], ATMData[id][atmRZ]);
 
            #if defined ROBBABLE_ATMS
            if(IsValidDynamicObject(ATMData[id][atmObjID])) {
                format(dataArray[IDString], 8, "atm_sys");
                dataArray[refID] = id;
 
                Streamer_SetArrayData(STREAMER_TYPE_OBJECT, ATMData[id][atmObjID], E_STREAMER_EXTRA_ID, dataArray);
            }else{
                printf("  [Bank System] Couldn't create an ATM object for ATM ID %d.", id);
            }
            #else
            if(!IsValidDynamicObject(ATMData[id][atmObjID])) printf("  [Bank System] Couldn't create an ATM object for ATM ID %d.", id);
            #endif
            
            #if defined ATM_USE_MAPICON
            ATMData[id][atmIconID] = CreateDynamicMapIcon(ATMData[id][atmX], ATMData[id][atmY], ATMData[id][atmZ], 52, 0, .streamdistance = ATM_ICON_RANGE);
            #endif
 
            format(label_string, sizeof(label_string), "ATM (%d)\n\n{FFFFFF}Use {F1C40F}/atm!", id);
            ATMData[id][atmLabel] = CreateDynamic3DTextLabel(label_string, 0x1ABC9CFF, ATMData[id][atmX], ATMData[id][atmY], ATMData[id][atmZ] + 0.85, 5.0, .testlos = 1);
 
            Iter_Add(ATMs, id);
        }
    }
 
    printf("  [Bank System] Loaded %d ATMs.", Iter_Count(ATMs));
    return 1;
}
 
forward OnBankAccountCreated(playerid, pass[]);
public OnBankAccountCreated(playerid, pass[])
{
    GiveMoney(playerid, -ACCOUNT_PRICE);
 
    new id = cache_insert_id(), string[64];
    SendClientMessage(playerid, 0x3498DBFF, "BANK: {FFFFFF}Successfully created an account for you!");
 
    format(string, sizeof(string), "BANK: {FFFFFF}Your account ID: {F1C40F}%d", id);
    SendClientMessage(playerid, 0x3498DBFF, string);
 
    format(string, sizeof(string), "BANK: {FFFFFF}Your account password: {F1C40F}%s", pass);
    SendClientMessage(playerid, 0x3498DBFF, string);
    return 1;
}
 
forward OnBankAccountLogin(playerid, id);
public OnBankAccountLogin(playerid, id)
{
    if(cache_num_rows() > 0) {
        new string[128], owner[MAX_PLAYER_NAME], last_access, ldate[24];
        cache_get_value_name(0, "Owner", owner);
        cache_get_value_name_int(0, "LastAccess", last_access);
        cache_get_value_name(0, "Last", ldate);
 
        format(string, sizeof(string), "BANK: {FFFFFF}This account is owned by {F1C40F}%s.", owner);
        SendClientMessage(playerid, 0x3498DBFF, string);
        format(string, sizeof(string), "BANK: {FFFFFF}Last Accessed On: {F1C40F}%s", (last_access == 0) ? ("Never") : ldate);
        SendClientMessage(playerid, 0x3498DBFF, string);
 
        CurrentAccountID[playerid] = id;
        Bank_ShowMenu(playerid);
 
        new query[96];
        mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_accounts SET LastAccess=UNIX_TIMESTAMP() WHERE ID=%d && Disabled=0", id);
        mysql_tquery(BankSQLHandle, query);
 
        Bank_SaveLog(playerid, TYPE_LOGIN, id, -1, 0);
    }else{
        SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Invalid credentials.");
        Bank_ShowMenu(playerid);
    }
 
    return 1;
}
 
forward OnBankAccountDeposit(playerid, amount);
public OnBankAccountDeposit(playerid, amount)
{
    if(cache_affected_rows() > 0) {
        new string[64];
        format(string, sizeof(string), "BANK: {FFFFFF}Successfully deposited {2ECC71}%s.", FormatMoney(amount));
        SendClientMessage(playerid, 0x3498DBFF, string);
 
        GiveMoney(playerid, -amount);
        Bank_SaveLog(playerid, TYPE_DEPOSIT, CurrentAccountID[playerid], -1, amount);
    }else{
        SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Transaction failed.");
    }
 
    Bank_ShowMenu(playerid);
    return 1;
}
 
forward OnBankAccountWithdraw(playerid, amount);
public OnBankAccountWithdraw(playerid, amount)
{
    if(cache_affected_rows() > 0) {
        new string[64];
        format(string, sizeof(string), "BANK: {FFFFFF}Successfully withdrawn {2ECC71}%s.", FormatMoney(amount));
        SendClientMessage(playerid, 0x3498DBFF, string);
 
        GiveMoney(playerid, amount);
        Bank_SaveLog(playerid, TYPE_WITHDRAW, CurrentAccountID[playerid], -1, amount);
    }else{
        SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Transaction failed.");
    }
 
    Bank_ShowMenu(playerid);
    return 1;
}
 
forward OnBankAccountTransfer(playerid, id, amount);
public OnBankAccountTransfer(playerid, id, amount)
{
    if(cache_affected_rows() > 0) {
        new query[144];
        mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_accounts SET Balance=Balance-%d WHERE ID=%d && Disabled=0", amount, CurrentAccountID[playerid]);
        mysql_tquery(BankSQLHandle, query, "OnBankAccountTransferDone", "iii", playerid, id, amount);
    }else{
        SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Transaction failed.");
        Bank_ShowMenu(playerid);
    }
 
    return 1;
}
 
forward OnBankAccountTransferDone(playerid, id, amount);
public OnBankAccountTransferDone(playerid, id, amount)
{
    if(cache_affected_rows() > 0) {
        new string[128];
        format(string, sizeof(string), "BANK: {FFFFFF}Successfully transferred {2ECC71}%s {FFFFFF}to account ID {F1C40F}%d.", FormatMoney(amount), id);
        SendClientMessage(playerid, 0x3498DBFF, string);
 
        Bank_SaveLog(playerid, TYPE_TRANSFER, CurrentAccountID[playerid], id, amount);
    }else{
        SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Transaction failed.");
 
    }
 
    Bank_ShowMenu(playerid);
    return 1;
}
 
forward OnBankAccountPassChange(playerid, newpass[]);
public OnBankAccountPassChange(playerid, newpass[])
{
    if(cache_affected_rows() > 0) {
        new string[128];
        format(string, sizeof(string), "BANK: {FFFFFF}Account password set to {F1C40F}%s.", newpass);
        SendClientMessage(playerid, 0x3498DBFF, string);
 
        Bank_SaveLog(playerid, TYPE_PASSCHANGE, CurrentAccountID[playerid], -1, 0);
    }else{
        SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Password change failed.");
    }
 
    Bank_ShowMenu(playerid);
    return 1;
}
 
forward OnBankAccountDeleted(playerid, id, amount);
public OnBankAccountDeleted(playerid, id, amount)
{
    if(cache_affected_rows() > 0) {
        GiveMoney(playerid, amount);
 
        foreach(new i : Player)
        {
            if(i == playerid) continue;
            if(CurrentAccountID[i] == id) CurrentAccountID[i] = -1;
        }
 
        new string[128];
        format(string, sizeof(string), "BANK: {FFFFFF}Account removed, you got the {2ECC71}%s {FFFFFF}left in the account.", FormatMoney(amount));
        SendClientMessage(playerid, 0x3498DBFF, string);
    }else{
        SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Account removal failed.");
    }
 
    CurrentAccountID[playerid] = -1;
    Bank_ShowMenu(playerid);
    return 1;
}
 
forward OnBankAccountAdminEdit(playerid);
public OnBankAccountAdminEdit(playerid)
{
    if(cache_affected_rows() > 0) {
        SendClientMessage(playerid, 0x3498DBFF, "BANK: {FFFFFF}Account edited.");
    }else{
        SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Account editing failed. (No affected rows)");
    }
 
    return 1;
}
 
#if defined ROBBABLE_ATMS
forward ATM_Regen(id);
public ATM_Regen(id)
{
    new string[64];
 
    if(ATMData[id][atmRegen] > 1) {
        ATMData[id][atmRegen]--;
 
        format(string, sizeof(string), "ATM (%d)\n\n{FFFFFF}Out of Service\n{E74C3C}%s", id, ConvertToMinutes(ATMData[id][atmRegen]));
        UpdateDynamic3DTextLabelText(ATMData[id][atmLabel], 0x1ABC9CFF, string);
    }else if(ATMData[id][atmRegen] == 1) {
        if(IsValidDynamicPickup(ATMData[id][atmPickup])) DestroyDynamicPickup(ATMData[id][atmPickup]);
        KillTimer(ATMData[id][atmTimer]);
 
        ATMData[id][atmHealth] = ATM_HEALTH;
        ATMData[id][atmRegen] = 0;
        ATMData[id][atmTimer] = ATMData[id][atmPickup] = -1;
 
        Streamer_SetIntData(STREAMER_TYPE_OBJECT, ATMData[id][atmObjID], E_STREAMER_MODEL_ID, 19324);
 
        format(string, sizeof(string), "ATM (%d)\n\n{FFFFFF}Use {F1C40F}/atm!", id);
        UpdateDynamic3DTextLabelText(ATMData[id][atmLabel], 0x1ABC9CFF, string);
    }
 
    return 1;
}
#endif