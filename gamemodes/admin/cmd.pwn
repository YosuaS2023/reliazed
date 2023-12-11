#include <realtime-clock>

CMD:admins(playerid, params[])
{
    new count = 0;

    if(GetAdminLevel(playerid))
    {
    	new output[1500];

    	strcat(output, "ID\tName (Admin Name)\tRank\tDuty\tOnline Time (minutes)\n");

	    foreach (new i : Player) if (IsPlayerConnected(i) && AccountData[i][uAdmin])
	    {
	    	strcat(output, sprintf("%d\t%s (%s)\t%s\t%s\t%d\n", i, NormalName(i), ReturnAdminName(i), gAdminLevel[AccountData[playerid][uAdmin]], (AccountData[i][uAdminDuty]) ? ("Yes") : ("No"), ((gettime()-AccountData[i][uLoginDate])/60)));
	        count++;
	    }

	    if(!count) SendClientMessage(playerid, X11_WHITE, "* No admin/helper online.");
	    else Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_TABLIST_HEADERS, "Admin/Helper list", output, "Close", "");
    }
    else
    {
	    SendClientMessage(playerid, X11_GREY_60,"Admin/Helper list:");
	
	    foreach (new i : Player) if (IsPlayerConnected(i) && AccountData[i][uAdmin] && AccountData[i][uAdminDuty] && AccountData[i][uAdminHide] != 1) {
	        if(!strcmp(AccountData[i][uAdminRankName], "None")) SendClientMessageEx(playerid, X11_WHITE, "* (%s) %s (ID: %d), AOD: %s%s", gAdminLevel[AccountData[i][uAdmin]], ReturnAdminName(i), i, (AccountData[i][uAdminDuty]) ? (GREEN) : (RED), (AccountData[i][uAdminDuty]) ? ("Yes") : ("No"));
	        else SendClientMessageEx(playerid, X11_WHITE, "* (%s) %s (ID: %d), AOD: %s%s", ReturnAdminRankName(i), ReturnAdminName(i), i, (AccountData[i][uAdminDuty]) ? (GREEN_E) : (RED_E), (AccountData[i][uAdminDuty]) ? ("Yes") : ("No"));
	        count++;
	    }

	    if(!count) SendClientMessage(playerid, X11_WHITE, "* No admin/helper online.");
    }
    return 1;
}

CMD:netstats(playerid, params[])
{
	if (GetAdminLevel(playerid))
	{
		new
			stats[ 512 ]
		;

		GetNetworkStats(stats, sizeof(stats)); // get the servers networkstats
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Server Network Stats", stats, "Close", "");
	}

	return 1;
}

CMD:adminactivity(playerid, params[])
{
	if(CheckAdmin(playerid, 1))
        return PermissionError(playerid);

    new 
		Cache:admincheck,
		string[1500]
	;

	admincheck = mysql_query(sqlcon, "SELECT * FROM `ucp_accounts` WHERE `Admin`>='1' ORDER BY `Admin` DESC");

	format(string, sizeof(string), "Account ID\tAdmin Name\tRank\n");
	for(new i = 0; i != cache_num_rows(); i++) 
	{
		new
			accountid,
			accountname[25],
			accountrankname[32]
		;
		cache_get_field_content(i, "Username", accountname, 25);
		cache_get_field_content(i, "AdminRankName", accountrankname, 32);
		accountid = cache_get_field_int(i, "ID"),

		format(string, sizeof(string), "%s%d\t%s\t%s\n", string, accountid, accountname, accountrankname);
	}
	Dialog_Show(playerid, AdminActivity, DIALOG_STYLE_TABLIST_HEADERS, "Admin/Helper list", string, "Select", "Close");

	cache_delete(admincheck);
    return 1;
}

Dialog:AdminActivity(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new 
			Cache:adminstatscheck,
			query[255],
			string[2000],
			adminname[500],
			account_admin_name[25],
			account_admin_rankname[32],
			account_accept_report,
			account_denied_report,
			account_accept_stuck,
			account_denied_stuck,
			account_banned_record,
			account_unbanned_record,
			account_jail_record,
			account_answer_record,
			account_duty_hour
		;

		format(query, sizeof(query), "SELECT * FROM `ucp_accounts` WHERE `ID` = '%d'", strval(inputtext));
		adminstatscheck = mysql_query(sqlcon, query);

		if(cache_num_rows())
    	{
			cache_get_field_content(0, "Username", account_admin_name, 25);
			cache_get_field_content(0, "AdminRankName", account_admin_rankname, 32);

			account_accept_report = cache_get_field_int(0, "AdminAcceptReport");
			account_denied_report = cache_get_field_int(0, "AdminDeniedReport");
			account_accept_stuck = cache_get_field_int(0, "AdminAcceptStuck");
			account_denied_stuck = cache_get_field_int(0, "AdminDeniedStuck");
			account_banned_record = cache_get_field_int(0, "AdminBanned");
			account_unbanned_record = cache_get_field_int(0, "AdminUnbanned");
			account_jail_record = cache_get_field_int(0, "AdminJail");
			account_answer_record = cache_get_field_int(0, "AdminAnswer");
			account_duty_hour = cache_get_field_int(0, "AdminDutyTime");

			cache_delete(adminstatscheck);		
		}
		format(adminname, sizeof(adminname), "Account ID - %d - %s - %s", strval(inputtext), account_admin_name, account_admin_rankname);
		format(string, sizeof(string), "Admin Name : "RED"%s\n"WHITE"Admin Rankname : "RED"%s\n"WHITE"Admin Duty Minute(s) : "GREEN"%d\n"WHITE"Answered Question : "GREEN"%d\n"WHITE"Accepted Report : "GREEN"%d\n"WHITE"Denied Report : "GREEN"%d\n"WHITE"Accepted Stuck : "GREEN"%d\n"WHITE"Denied Stuck : "GREEN"%d\n"WHITE"Banned Record : "GREEN"%d\n"WHITE"Unbanned Record : "GREEN"%d\n"WHITE"Jail Record : "GREEN"%d", account_admin_name, account_admin_rankname, account_duty_hour, account_answer_record, account_accept_report, account_denied_report, account_accept_stuck, account_denied_stuck, account_banned_record, account_unbanned_record, account_jail_record);

		Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_LIST, adminname, string, "Close", "");
	}
	return 1;
}


task UpdateAdminStatus[5000]()
{
	new 
		string[3072],
		str[128],
		query[3072]
	;
	TimeFormat(Timestamp:Now()+Hours:7, "Last Check : %A, %d %B %Y -- %H:%M:%S\n\n", string);
	foreach (new i : Player)
	{ 
		if (IsPlayerConnected(i) && AccountData[i][uAdmin] > 0) 
		{
			if(!strcmp(AccountData[i][uAdminRankName], "None")) 
			{
				format(str, sizeof(str), "* (%s) %s (ID: %d), ON-DUTY: %s *\n",gAdminLevel[AccountData[i][uAdmin]], ReturnAdminName(i), i, (AccountData[i][uAdminDuty]) ? ("Yes") : ("No"));
				strcat(string, str);
				
			}
			else
			{
				format(str, sizeof(str), "* (%s) %s (ID: %d), ON-DUTY: %s *\n",ReturnAdminRankName(i), ReturnAdminName(i), i, (AccountData[i][uAdminDuty]) ? ("Yes") : ("No"));
				strcat(string, str);
			}
		}
	}
	mysql_format(sqlcon, query, sizeof(query), "UPDATE `server` SET `admin_online` = '%s' WHERE `ID` = '1'", string);
	mysql_tquery(sqlcon, query);
	return 1;
}

CMD:aduty(playerid, params[])
{
    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);
   // if(PlayerData[playerid][pMaskOn]) return SendErrorMessage(playerid, "You're using a mask remove the mask first");
    if(!AccountData[playerid][uAdminDuty])
    {
        if (GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
            SetHealth(playerid, 99999);
            
        SetPVarInt(playerid, "PreviousColor", GetPlayerColor(playerid));

        AccountData[playerid][uAdminDuty] = 1;
        SetPlayerColor(playerid, RemoveAlpha(0x660000FF));
        SetPlayerName(playerid, ReturnAdminName(playerid));
        //ResetNameTag(playerid, false, false, true);
        AdminDutyTime_WriteStartTime(playerid);
        SendAdminAction(X11_TOMATO_1, "* %s is now duty as an admin.", ReturnName(playerid,1));
    }
    else
    {
        //new faction_id = GetPlayerFaction(playerid);

        SetHealth(playerid, 100);
        AccountData[playerid][uAdminDuty] = 0;
        SetPlayerColor(playerid, /*(faction_id != -1 && IsPlayerDuty(playerid)) ? (RemoveAlpha(FactionData[faction_id][factionColor])) : (RemoveAlpha(GetPVarInt(playerid, "PreviousColor")))*/ COLOR_WHITE);
        SetPlayerName(playerid, NormalName(playerid));
        //ResetNameTag(playerid, false, false, false, true);
        AdminDutyTime_UpdateEndTime(playerid);
        SendAdminAction(X11_TOMATO_1, "* %s is no longer on admin duty.", ReturnName(playerid,1));
    }
    return 1;
}

CMD:asay(playerid, params[])
{
    if(CheckAdmin(playerid, 1))
        return PermissionError(playerid);

    if(isnull(params))
        return SendSyntaxMessage(playerid, "/asay [text]");

    if (strlen(params) > 64)
    {
        SendClientMessageToAllEx(X11_TOMATO_1, "Admin %s: %.64s ..", ReturnAdminName(playerid), ColouredText(params));
        SendClientMessageToAllEx(X11_TOMATO_1, "Admin %s: .. %s", ReturnAdminName(playerid), ColouredText(params[64]));
        return 1;
    }

    SendClientMessageToAllEx(X11_TOMATO_1, "Admin %s: %s", ReturnAdminName(playerid), ColouredText(params));
    return 1;
}

CMD:setarmor(playerid, params[])
{
	static
		userid,
	    Float:amount;

	if (AccountData[playerid][uAdmin] < 1)
	    return SendErrorMessage(playerid, "You don't have permission to use this command.");

	if (sscanf(params, "uf", userid, amount))
		return SendSyntaxMessage(playerid, "/setarmor [playerid/PartOfName] [amount]");

	if (userid == INVALID_PLAYER_ID)
	    return SendErrorMessage(playerid, "You have specified an invalid player.");

	SetArmour(userid, amount);
	SendServerMessage(playerid, "You have set %s's armour to %.2f.", ReturnName(userid), amount);
	return 1;
}

CMD:sethp(playerid, params[])
{
	new
		userid,
	    Float:amount;

	if (AccountData[playerid][uAdmin] < 1)
	    return SendErrorMessage(playerid, "You don't have permission to use this command.");

	if (sscanf(params, "uf", userid, amount))
		return SendSyntaxMessage(playerid, "/sethp [playerid/PartOfName] [amount]");

	if (userid == INVALID_PLAYER_ID)
	    return SendErrorMessage(playerid, "You have specified an invalid player.");

	if(amount <= 7.0)
	{
		InjuredPlayer(userid, INVALID_PLAYER_ID, WEAPON_COLLISION);
	}
	else
	{
		SetHealth(userid, amount);
	}
	SendServerMessage(playerid, "You have set %s's health to %.2f.", ReturnName(userid), amount);
	return 1;
}