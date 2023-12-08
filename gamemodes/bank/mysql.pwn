mysql:Bank_SetBalance(playerid, amount[])
{
    new query[96];
    mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_accounts SET Balance=Balance+%d WHERE ID=%d && Disabled=0", amount, CurrentAccountID[playerid]);
    mysql_tquery(BankSQLHandle, query, "OnBankAccountDeposit", "ii", playerid, amount);
    return 1;
}