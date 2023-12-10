UpdateCharacterInt(playerid, const column_name[], value)
{
	mysql_tquery(sqlcon, sprintf("UPDATE `ucp_characters` SET `%s` = '%d' WHERE `ID` = '%d';", column_name, value, GetPlayerSQLID(playerid)));
	return 1;
}

stock UpdateCharacterFloat(playerid, const column_name[], Float:value) 
{
	mysql_tquery(sqlcon, sprintf("UPDATE `ucp_characters` SET `%s` = '%.4f' WHERE `ID`='%d';", column_name, value, GetPlayerSQLID(playerid)));
	return 1;
}

UpdateCharacterString(playerid, const column_name[], value[]) 
{
	mysql_tquery(sqlcon, sprintf("UPDATE `ucp_characters` SET `%s` = '%s' WHERE `ID`='%d';", column_name, SQL_ReturnEscaped(value), GetPlayerSQLID(playerid)));
	return 1;
}

ResetStatistics(playerid)
{
    PlayerData[playerid][pID] = -1;
    PlayerData[playerid][pGender] = 1;
    PlayerData[playerid][pSkin] = 98;
    PlayerData[playerid][pMoney] = 500;
	PlayerData[playerid][pLogged] = 0;
	PlayerData[playerid][pScore] = 0;
	PlayerData[playerid][pExp] = 0;
    PlayerData[playerid][pBankMoney] = 1000;
	
	PlayerData[playerid][pSalary] = 0;
	PlayerData[playerid][pLogged] = 0;
	PlayerData[playerid][pPaycheck] = 0;
	// Faction
	
	PlayerData[playerid][pFaction] = -1;
	PlayerData[playerid][pFactionID] = -1;
	PlayerData[playerid][pOnDuty] = false;
	PlayerData[playerid][pFactionEdit] = -1;
	PlayerData[playerid][pFactionRank] = -1;
	PlayerData[playerid][pFactionOffer] = -1;
	PlayerData[playerid][pFactionOffered] = -1;
    printf("Resetting player statistics for ID %d", playerid);
    return 1;
}