#include <YSI\y_hooks>
hook OnGameModeInit()
{
	print("[SERVER]: MySQL Connection was successful.");
	print("jaaa");
	mysql_tquery(sqlcon, "CREATE TABLE IF NOT EXISTS `updates` (`UpdateID` int(10) AUTO_INCREMENT PRIMARY KEY, `AddedBy` VARCHAR(24) NOT NULL, `Text` VARCHAR(128) NOT NULL, `Status` int(10), `DateAdded` VARCHAR(30) NOT NULL); ");
	return 1;
}

forward Player_ViewUpdates(playerid);
public Player_ViewUpdates(playerid)
{
	if(cache_num_rows())
	{
		new
			updateid, addedby[24], text[128], status, sstatus[128], dateadded[30], string[500] // the reason this is huge is because there might be a lot of updates so it should be bigger, you can change this any time you want.
		;

		format(string, sizeof(string), "This is a list of the new server updates on the last revision:\n\n");
		for(new i = 0; i < cache_num_rows(); i ++)
		{
			cache_get_value_name_int(i, "UpdateID", updateid);
			cache_get_value_name(i, "AddedBy", addedby);
			cache_get_value_name(i, "Text", text);
			cache_get_value_name_int(i, "Status", status);
			cache_get_value_name(i, "DateAdded", dateadded);

			switch(status)
			{
				case 1: sstatus = "Added";
				case 2: sstatus = "Changed";
				case 3: sstatus = "Fixed";
				case 4: sstatus = "Removed";
			}

			format(string, sizeof(string), "%s[%d] %s - %s [%s] on %s\n", string, updateid, sstatus, text, addedby, dateadded);
		}
		Dialog_Show(playerid, DIALOG_UPDATES, DIALOG_STYLE_MSGBOX, "Server new Updates", string, "Close", "");
	}
	else
	{
		Dialog_Show(playerid, DIALOG_UPDATES, DIALOG_STYLE_MSGBOX, "Server new Updates", "There are currently no updates on the database.", "Close", "");
	}
	return 1;
}

forward OnPlayerDeleteUpdate(playerid, updateid);
public OnPlayerDeleteUpdate(playerid, updateid)
{	
	if(cache_num_rows())
	{
		new
			string[128], query[128]
		;

		format(string, sizeof(string), "You have successfully removed UpdateID %d from the database.", updateid);
		SendClientMessage(playerid, -1, string);

		mysql_format(sqlcon, query, sizeof(query), "DELETE FROM `update_updatenote` WHERE `UpdateID` = '%i'", updateid);
		mysql_query(sqlcon, query);
	}
	else 
	{
		SendClientMessage(playerid, -1, "That UpdateID was not found in the database.");
	}
	return 1;
}

forward OnPlayerAddUpdate(playerid, status, text[]);
public OnPlayerAddUpdate(playerid, status, text[]) 
{
	new 
		updateid = cache_insert_id(), string[128], sstring[100]
	;

	switch(status)
	{
		case 1: sstring = "Added"; 
		case 2: sstring = "Changed";
		case 3: sstring = "Fixed";
		case 4: sstring = "Removed";
	}

	format(string, sizeof(string), "You have successfully a new update - [ID: %d] - [Text: %s] - [Status: %s]", updateid, text, sstring);
	SendClientMessage(playerid, -1, string);
	return 1;
}