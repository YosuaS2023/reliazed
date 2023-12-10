

new MAX_FACTION;
hook OnGameModeInitEx()
{
	new Node:server_management[2], Node:server_management_gov[2], Node:server_management_max[2];
    JSON_ParseFile("server_management.json",server_management[0]);
    JSON_GetObject(server_management[0], "MOTD", server_management[1]);
    JSON_GetString(server_management[1], "administrator", MotdData[motdAdmin]);
    JSON_GetString(server_management[1], "player", MotdData[motdPlayer]);

    JSON_GetObject(server_management_gov[0], "Goverment", server_management[1]);
    JSON_GetInt(server_management_gov[1], "salaryTax", govData[govTax]);
    JSON_GetInt(server_management_gov[1], "vault", govData[govVault]);

    JSON_GetObject(server_management_max[0], "setting max", server_management[1]);
    JSON_GetInt(server_management_max[1], "faction max", MAX_FACTION);
    printf("--------------------------------");
    printf("MOTD Admin: %s | MOTD: Player: %s", MotdData[motdAdmin], MotdData[motdPlayer]);
    printf("Goverment [Salary Tax: %i, Vault: %i]", govData[govTax], govData[govVault]);
    printf("SETTING MAX: [FACTION MAX: %i]", MAX_FACTIONS);
    printf("--------------------------------");
	return 1;
}


hook OnPlayerLogin(playerid)
{
    SendClientMessageEx(playerid, -1, "{00FFFF}MOTD: {FFFF00}%s", MotdData[motdPlayer]);
    if(AccountData[playerid][uAdmin] > 0)
    {
        SendClientMessageEx(playerid, -1, "{FF0000}AMOTD: {FFFF00}%s", MotdData[motdAdmin]);
    }
    return 1;
}
/*
COMMAND:config(playerid)
{
    if(CheckAdmin(playerid, 4)) return PermissionError(playerid);
    Dialog_Show(playerid, configuration, DIALOG_STYLE_LIST, "Server Management", "Reload Server Data", "Confirm", "Cancel");
    return 1;
}

Dialog:configuration(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    CallLocalFunction(arr_functionServerManagement[listitem], "");
    return 1;
}*/