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