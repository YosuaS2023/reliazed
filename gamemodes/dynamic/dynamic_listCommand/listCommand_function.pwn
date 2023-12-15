hook OnGameModeInit()
{   
    static log_error;
	mysql_tquery(sqlcon, "CREATE TABLE IF NOT EXISTS handler_command (`CommandID` int(10) AUTO_INCREMENT PRIMARY KEY, `AddedBy` VARCHAR(24) NOT NULL, `Command` VARCHAR(128) NOT NULL, `Type` int(10), `DateAdded` VARCHAR(30) NOT NULL); ");
    if(log_error == 1)
    {
        printf("[MySQL] Created table 'handler_command': %s", "Susccess");
    }
    else
    {
        printf("[MySQL] Created table 'handler_command': %s", "Error");
    }
    return 1;
}

forward Player_ViewCommands(playerid);
public Player_ViewCommands(playerid)
{
	if(cache_num_rows())
	{
		new
			commandid, addedby[24], text[128], status, sstatus[128], dateadded[30], string[500] // the reason this is huge is because there might be a lot of updates so it should be bigger, you can change this any time you want.
		;

		format(string, sizeof(string), "This is a list of server commands:\n\n");
		for(new i = 0; i < cache_num_rows(); i ++)
		{
			cache_get_value_name_int(i, "CommandID", commandid);
			cache_get_value_name(i, "AddedBy", addedby);
			cache_get_value_name(i, "Command", text);
			cache_get_value_name_int(i, "Type", status);
			cache_get_value_name(i, "DateAdded", dateadded);
			forex(cid, MAX_TYPE_LISTCOMMAND)
			{
				if(status == cid){
					format(listCommand[cid], sizeof(listCommand), "%s%i.%s\n", listCommand[cid], commandid, text);
				}
			}
		}
		new str[38+1];
        format(str, sizeof(str), "Command General\nCommand Administrator");
        Dialog_Show(playerid,handler_commandlist, DIALOG_STYLE_LIST, "List command - {16E2F5}Reliazed Roleplay", str, "Accept", "Cancel");
	}
	else
	{
        new str[65+1];
        format(str, sizeof(str), "%s{E60000}Sorry{FFFFFF}, List command is not yet available in database.", str);
        Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_MSGBOX, "List Command - {16E2F5}Reliazed Roleplay", str, "Accept", "Cancel");
	}
	return 1;
}

forward OnPlayerDeleteCommandList(playerid, updateid);
public OnPlayerDeleteCommandList(playerid, updateid)
{	
	if(cache_num_rows())
	{
		new
			string[128], query[128]
		;

		format(string, sizeof(string), "You have successfully removed CommandID %d from the database.", updateid);
		SendClientMessage(playerid, -1, string);

		mysql_format(sqlcon, query, sizeof(query), "DELETE FROM `handler_command` WHERE `CommandID` = '%i'", updateid);
		mysql_query(sqlcon, query);
	}
	else 
	{
		SendClientMessage(playerid, -1, "That CommandID was not found in the database.");
	}
	return 1;
}

forward OnPlayerAddCommandList(playerid, status, text[]);
public OnPlayerAddCommandList(playerid, status, text[]) 
{
	new 
		updateid = cache_insert_id(), string[128], sstring[100]
	;
	format(string, sizeof(string), "You have successfully a new command - [ID: %d] - [Command: %s]", updateid, text, sstring);
	SendClientMessage(playerid, -1, string);
	return 1;
}

GetTypeListCommand(name[])
{
	forex(i, MAX_TYPE_LISTCOMMAND)
	{
		if (!strcmp(arr_listCommand[i][listCommandName], name)) return arr_listCommand[i][listCommandType];
	}
	return -1;
}