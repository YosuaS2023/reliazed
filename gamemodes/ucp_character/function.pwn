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