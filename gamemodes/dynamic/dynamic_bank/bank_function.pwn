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
            "{%06x}Create Account\t{2ECC71}%s\nMy Accounts\t{F1C40F}%d\nDeposit\t{2ECC71}%s\nWithdraw\t{2ECC71}%s\nTransfer\t{2ECC71}%s\nPaycheck\t{2ECC71}%s\n{%06x}Account Logs\n{%06x}Change Password\n{%06x}Remove Account\nLogout",
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

function Bank_SetBalance(playerid, amount)
{
    new query[96];
    mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_accounts SET Balance=Balance+%d WHERE ID=%d && Disabled=0", amount, CurrentAccountID[playerid]);
    mysql_tquery(BankSQLHandle, query, "OnBankAccountSetBalance", "ii", playerid, amount);
    return 1;
}

forward OnBankAccountSetBalance(playerid, amount);
public OnBankAccountSetBalance(playerid, amount)
{
    if(cache_affected_rows() > 0) {
        new string[64];
        //format(string, sizeof(string), "BANK: {FFFFFF}Successfully  {2ECC71}%s.", FormatMoney(amount));
        //SendClientMessage(playerid, 0x3498DBFF, string);
 
        GiveMoney(playerid, -amount);
        Bank_SaveLog(playerid, TYPE_DEPOSIT, CurrentAccountID[playerid], -1, amount);
    }else{
        SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Transaction failed.");
    }
 
    Bank_ShowMenu(playerid);
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
				new taxval = PlayerData[playerid][pSalary]/100*govData[govTax];
				format(str, sizeof(str), "{FFFFFF}Salary: {009000}$%s\n{FFFFFF}Tax: {FFFF00}-$%s {FF0000}(%d percent)\n{FFFFFF}Total Interest: {00FF00}$%s", FormatMoney(PlayerData[playerid][pSalary]), FormatMoney(taxval), govData[govTax], FormatMoney(PlayerData[playerid][pSalary]-taxval));
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