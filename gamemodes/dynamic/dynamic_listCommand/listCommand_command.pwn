CMD:addcommand(playerid, params[])
{
	new
		text[128], status, query[280]
	;

	if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, -1, "You must be an admin to use this command.");
	if(sscanf(params, "is[128]", status, text)) 
	{ 
		SendClientMessage(playerid, -1, "[USAGE]: {AFAFAF}/addcommand [type] [command]");
		SendClientMessage(playerid, -1, "Use 1 if you want to display the command general as added, 2 if you want to display it as changed, 3 as fixed and 4 as removed.");
		return 1;
	}

	mysql_format(sqlcon, query, sizeof(query), "INSERT INTO `handler_command` (`AddedBy`, `Command`, `Type`, `DateAdded`) VALUES ('%e', '%e', '%i', '%e')", ReturnName(playerid), text, status, ReturnDate());
	mysql_tquery(sqlcon, query, "OnPlayerAddCommandList", "iis", playerid, status, text);
	return 1;
}

CMD:removecommand(playerid, params[])
{
	new 
		commandid, query[128]
	;

	if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, -1, "You must be an admin to use this command.");
	if(sscanf(params, "i", commandid)) return SendClientMessage(playerid, -1, "[USAGE]: {AFAFAF}/removecommand [commandid]");

	mysql_format(sqlcon, query, sizeof(query), "SELECT `CommandID` FROM `handler_command` WHERE `CommandID` = '%i'", commandid);
	mysql_tquery(sqlcon, query, "OnPlayerDeleteCommandList", "ii", playerid, commandid);
	return 1;
}

CMD:listcommand(playerid, params[])
{
	new 
		query[128]
	;

	mysql_format(sqlcon, query, sizeof(query), "SELECT * FROM `handler_command`");
	mysql_pquery(sqlcon, query, "Player_ViewCommands", "i", playerid);
	return 1;
}