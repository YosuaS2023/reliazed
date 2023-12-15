CMD:addupdate(playerid, params[])
{
	new
		text[128], status, query[280]
	;

	if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, -1, "You must be an admin to use this command.");
	if(sscanf(params, "is[128]", status, text)) 
	{ 
		SendClientMessage(playerid, -1, "[USAGE]: {AFAFAF}/addupdate [status] [text]");
		SendClientMessage(playerid, -1, "Use 1 if you want to display the update as added, 2 if you want to display it as changed, 3 as fixed and 4 as removed.");
		return 1;
	}

	mysql_format(sqlcon, query, sizeof(query), "INSERT INTO `handler_updatenote` (`AddedBy`, `Text`, `Status`, `DateAdded`) VALUES ('%e', '%e', '%i', '%e')", ReturnName(playerid), text, status, ReturnDate());
	mysql_tquery(sqlcon, query, "OnPlayerAddUpdate", "iis", playerid, status, text);
	return 1;
}

CMD:removeupdate(playerid, params[])
{
	new 
		updateid, query[128]
	;

	if(CheckAdmin (playerid, 4)) return SendClientMessage(playerid, -1, "You must be an admin to use this command.");
	if(sscanf(params, "i", updateid)) return SendClientMessage(playerid, -1, "[USAGE]: {AFAFAF}/removeupdate [updateid]");

	mysql_format(sqlcon, query, sizeof(query), "SELECT `UpdateID` FROM `handler_updatenote` WHERE `UpdateID` = '%i'", updateid);
	mysql_tquery(sqlcon, query, "OnPlayerDeleteUpdate", "ii", playerid, updateid);
	return 1;
}

CMD:updates(playerid, params[])
{
	new 
		query[128]
	;

	mysql_format(sqlcon, query, sizeof(query), "SELECT * FROM `handler_updatenote`");
	mysql_pquery(sqlcon, query, "Player_ViewUpdates", "i", playerid);
	return 1;
}