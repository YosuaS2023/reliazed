#include <YSI\y_hooks>
GetInitials(const string[])
{
	new
	    ret[32],
		index = 0;

	for (new i = 0, l = strlen(string); i != l; i ++)
	{
	    if (('A' <= string[i] <= 'Z') && (i == 0 || string[i - 1] == ' '))
			ret[index++] = string[i];
	}
	return ret;
}

function IsNearFactionLocker(playerid)
{
	new factionid = PlayerData[playerid][pFaction];

	if (factionid == -1)
	    return 0;

	if (IsPlayerInRangeOfPoint(playerid, 3.0, FactionData[factionid][factionLockerPos][0], FactionData[factionid][factionLockerPos][1], FactionData[factionid][factionLockerPos][2]) && GetPlayerInterior(playerid) == FactionData[factionid][factionLockerInt] && GetPlayerVirtualWorld(playerid) == FactionData[factionid][factionLockerWorld])
	    return 1;

	return 0;
}

function GetFactionByID(sqlid)
{
	forex(i, MAX_FACTIONS) if (FactionData[i][factionExists] && FactionData[i][factionID] == sqlid)
	    return i;

	return -1;
}

function SetFaction(playerid, id)
{
	if (id != -1 && FactionData[id][factionExists])
	{
		PlayerData[playerid][pFaction] = id;
		PlayerData[playerid][pFactionID] = FactionData[id][factionID];
	}
	return 1;
}

function SetFactionColor(playerid)
{
	new factionid = PlayerData[playerid][pFaction];

	if (factionid != -1)
		return SetPlayerColor(playerid, RemoveAlpha(FactionData[factionid][factionColor]));

	return 0;
}

function Faction_Update(factionid)
{
	if (factionid != -1 || FactionData[factionid][factionExists])
	{
	    foreach (new i : Player) if (PlayerData[i][pFaction] == factionid)
		{
 			if (GetFactionType(i) == FACTION_FAMILY || (GetFactionType(i) != FACTION_FAMILY && PlayerData[i][pOnDuty]))
			 	SetFactionColor(i);
		}
	}
	return 1;
}

function Faction_Refresh(factionid)
{
	if (factionid != -1 && FactionData[factionid][factionExists])
	{
	    if (FactionData[factionid][factionLockerPos][0] != 0.0 && FactionData[factionid][factionLockerPos][1] != 0.0 && FactionData[factionid][factionLockerPos][2] != 0.0)
	    {
		    static
		        string[128];

			if (IsValidDynamicPickup(FactionData[factionid][factionPickup]))
			    DestroyDynamicPickup(FactionData[factionid][factionPickup]);

			if (IsValidDynamic3DTextLabel(FactionData[factionid][factionText3D]))
			    DestroyDynamic3DTextLabel(FactionData[factionid][factionText3D]);

			FactionData[factionid][factionPickup] = CreateDynamicPickup(1239, 23, FactionData[factionid][factionLockerPos][0], FactionData[factionid][factionLockerPos][1], FactionData[factionid][factionLockerPos][2], FactionData[factionid][factionLockerWorld], FactionData[factionid][factionLockerInt]);

			format(string, sizeof(string), "[ID: %d]\n{FFFFFF}Type {FFFF00}/faction locker {FFFFFF}to access the locker.", factionid);
	  		FactionData[factionid][factionText3D] = CreateDynamic3DTextLabel(string, -1, FactionData[factionid][factionLockerPos][0], FactionData[factionid][factionLockerPos][1], FactionData[factionid][factionLockerPos][2], 5.0, INVALID_VEHICLE_ID, INVALID_PLAYER_ID, 0, FactionData[factionid][factionLockerWorld], FactionData[factionid][factionLockerInt]);
		}
	}
	return 1;
}

function Faction_Save(factionid)
{
	static
	    query[2048];

	mysql_format(sqlcon, query, sizeof(query), "UPDATE `factions` SET `factionName` = '%s', `factionColor` = '%d', `factionType` = '%d', `factionRanks` = '%d', `factionLockerX` = '%.4f', `factionLockerY` = '%.4f', `factionLockerZ` = '%.4f', `factionLockerInt` = '%d', `factionLockerWorld` = '%d', `SpawnX` = '%f', `SpawnY` = '%f', `SpawnZ` = '%f', `SpawnInterior` = '%d', `SpawnVW` = '%d'",
		FactionData[factionid][factionName],
		FactionData[factionid][factionColor],
		FactionData[factionid][factionType],
		FactionData[factionid][factionRanks],
		FactionData[factionid][factionLockerPos][0],
		FactionData[factionid][factionLockerPos][1],
		FactionData[factionid][factionLockerPos][2],
		FactionData[factionid][factionLockerInt],
		FactionData[factionid][factionLockerWorld],
		FactionData[factionid][SpawnX],
		FactionData[factionid][SpawnY],
		FactionData[factionid][SpawnZ],
		FactionData[factionid][SpawnInterior],
		FactionData[factionid][SpawnVW]
	);
	forex(i, 10)
	{
	    if (i < 8)
			mysql_format(sqlcon, query, sizeof(query), "%s, `factionSkin%d` = '%d', `factionWeapon%d` = '%d', `factionAmmo%d` = '%d', `factionDurability%d` = '%d'", query, i + 1, FactionData[factionid][factionSkins][i], i + 1, FactionData[factionid][factionWeapons][i], i + 1, FactionData[factionid][factionAmmo][i], i + 1, FactionData[factionid][factionDurability][i]);

		else
			mysql_format(sqlcon, query, sizeof(query), "%s, `factionWeapon%d` = '%d', `factionAmmo%d` = '%d', `factionDurability%d` = '%d'", query, i + 1, FactionData[factionid][factionWeapons][i], i + 1, FactionData[factionid][factionAmmo][i], i + 1, FactionData[factionid][factionDurability][i]);
	}
	forex(i, 15)
	{
		mysql_format(sqlcon, query, sizeof(query), "%s, `factionSalary%d` = '%d'", query, i + 1, FactionData[factionid][factionSalary][i]);
	}
	mysql_format(sqlcon, query, sizeof(query), "%s WHERE `factionID` = '%d'",
		query,
		FactionData[factionid][factionID]
	);
	return mysql_tquery(sqlcon, query);
}

function Faction_SaveRanks(factionid)
{
	static
	    query[768];

	mysql_format(sqlcon, query, sizeof(query), "UPDATE `factions` SET `factionRank1` = '%s', `factionRank2` = '%s', `factionRank3` = '%s', `factionRank4` = '%s', `factionRank5` = '%s', `factionRank6` = '%s', `factionRank7` = '%s', `factionRank8` = '%s', `factionRank9` = '%s', `factionRank10` = '%s', `factionRank11` = '%s', `factionRank12` = '%s', `factionRank13` = '%s', `factionRank14` = '%s', `factionRank15` = '%s' WHERE `factionID` = '%d'",
	    FactionRanks[factionid][0],
	    FactionRanks[factionid][1],
	    FactionRanks[factionid][2],
	    FactionRanks[factionid][3],
	    FactionRanks[factionid][4],
	    FactionRanks[factionid][5],
	    FactionRanks[factionid][6],
	    FactionRanks[factionid][7],
	    FactionRanks[factionid][8],
	    FactionRanks[factionid][9],
	    FactionRanks[factionid][10],
	    FactionRanks[factionid][11],
	    FactionRanks[factionid][12],
	    FactionRanks[factionid][13],
	    FactionRanks[factionid][14],
	    FactionData[factionid][factionID]
	);
	return mysql_tquery(sqlcon, query);
}

Faction_Delete(factionid)
{
	if (factionid != -1 && FactionData[factionid][factionExists])
	{
	    new
	        string[64];

		format(string, sizeof(string), "DELETE FROM `factions` WHERE `factionID` = '%d'", FactionData[factionid][factionID]);
		mysql_tquery(sqlcon, string);

		format(string, sizeof(string), "UPDATE `characters` SET `Faction` = '-1' WHERE `Faction` = '%d'", FactionData[factionid][factionID]);
		mysql_tquery(sqlcon, string);

		foreach (new i : Player)
		{
			if (PlayerData[i][pFaction] == factionid) {
		    	PlayerData[i][pFaction] = -1;
		    	PlayerData[i][pFactionID] = -1;
		    	PlayerData[i][pFactionRank] = -1;
			}
			if (PlayerData[i][pFactionEdit] == factionid) {
			    PlayerData[i][pFactionEdit] = -1;
			}
		}
		if (IsValidDynamicPickup(FactionData[factionid][factionPickup]))
  			DestroyDynamicPickup(FactionData[factionid][factionPickup]);

		if (IsValidDynamic3DTextLabel(FactionData[factionid][factionText3D]))
  			DestroyDynamic3DTextLabel(FactionData[factionid][factionText3D]);

	    FactionData[factionid][factionExists] = false;
	    FactionData[factionid][factionType] = 0;
	    FactionData[factionid][factionID] = 0;
	}
	return 1;
}

function GetFactionType(playerid)
{
	if (PlayerData[playerid][pFaction] == -1)
	    return 0;

	return (FactionData[PlayerData[playerid][pFaction]][factionType]);
}

function Faction_ShowSalary(playerid, factionid)
{
    if (factionid != -1 && FactionData[factionid][factionExists])
	{
		static
		    string[640];

		string[0] = 0;

		forex(i, FactionData[factionid][factionRanks])
			format(string, sizeof(string), "%sRank %d: $%s\n", string, i + 1, FormatMoney(FactionData[factionid][factionSalary][i]));

		PlayerData[playerid][pFactionEdit] = factionid;
		ShowPlayerDialog(playerid, DIALOG_EDITFACTION_SALARY_LIST, DIALOG_STYLE_LIST, FactionData[factionid][factionName], string, "Change", "Cancel");
	}
	return 1;
}

function Faction_ShowRanks(playerid, factionid)
{
    if (factionid != -1 && FactionData[factionid][factionExists])
	{
		static
		    string[640];

		string[0] = 0;

		forex(i, FactionData[factionid][factionRanks])
		    format(string, sizeof(string), "%sRank %d: %s\n", string, i + 1, FactionRanks[factionid][i]);

		PlayerData[playerid][pFactionEdit] = factionid;
		ShowPlayerDialog(playerid, DIALOG_EDITRANK, DIALOG_STYLE_LIST, FactionData[factionid][factionName], string, "Change", "Cancel");	
	}
	return 1;
}

function Faction_Create(name[], type)
{
	forex(i, MAX_FACTIONS) if (!FactionData[i][factionExists])
	{
	    format(FactionData[i][factionName], 32, name);

        FactionData[i][factionExists] = true;
        FactionData[i][factionColor] = 0xFFFFFF00;
        FactionData[i][factionType] = type;
        FactionData[i][factionRanks] = 5;

        FactionData[i][factionLockerPos][0] = 0.0;
        FactionData[i][factionLockerPos][1] = 0.0;
        FactionData[i][factionLockerPos][2] = 0.0;
        FactionData[i][factionLockerInt] = 0;
        FactionData[i][factionLockerWorld] = 0;

        for (new j = 0; j < 8; j ++) {
            FactionData[i][factionSkins][j] = 0;
        }
        for (new j = 0; j < 10; j ++) {
            FactionData[i][factionWeapons][j] = 0;
            FactionData[i][factionAmmo][j] = 0;
            FactionData[i][factionDurability][j] = 0;
	    }
	    for (new j = 0; j < 15; j ++) {
			format(FactionRanks[i][j], 32, "Rank %d", j + 1);
	    }
	    mysql_tquery(sqlcon, "INSERT INTO `factions` (`factionType`) VALUES(0)", "OnFactionCreated", "d", i);
	    return i;
	}
	return -1;
}

FUNC::OnFactionCreated(factionid)
{
	if (factionid == -1 || !FactionData[factionid][factionExists])
	    return 0;

	FactionData[factionid][factionID] = cache_insert_id();

	Faction_Save(factionid);
	Faction_SaveRanks(factionid);

	return 1;
}
FUNC::Faction_Load()
{
	new
	    rows = cache_num_rows(),
		str[56];

	if(rows)
	{
		forex(i, rows)
		{
		    FactionData[i][factionExists] = true;
		    cache_get_value_name_int(i, "factionID", FactionData[i][factionID]);
		    cache_get_value_name(i, "factionName", FactionData[i][factionName], 32);
		    cache_get_value_name_int(i, "factionColor", FactionData[i][factionColor]);
		    cache_get_value_name_int(i, "factionType", FactionData[i][factionType]);
		    cache_get_value_name_int(i, "factionRanks", FactionData[i][factionRanks]);
		    cache_get_value_name_float(i, "factionLockerX", FactionData[i][factionLockerPos][0]);
		    cache_get_value_name_float(i, "factionLockerY", FactionData[i][factionLockerPos][1]);
		    cache_get_value_name_float(i, "factionLockerZ", FactionData[i][factionLockerPos][2]);
		    cache_get_value_name_int(i, "factionLockerInt", FactionData[i][factionLockerInt]);
		    cache_get_value_name_int(i, "factionLockerWorld", FactionData[i][factionLockerWorld]);
		    cache_get_value_name_float(i, "SpawnX", FactionData[i][SpawnX]);
		    cache_get_value_name_float(i, "SpawnY", FactionData[i][SpawnY]);
		    cache_get_value_name_float(i, "SpawnZ", FactionData[i][SpawnZ]);
		    cache_get_value_name_int(i, "SpawnInterior", FactionData[i][SpawnInterior]);
		    cache_get_value_name_int(i, "SpawnVW", FactionData[i][SpawnVW]);

		    for (new j = 0; j < 8; j ++) {
		        format(str, sizeof(str), "factionSkin%d", j + 1);

		        cache_get_value_name_int(i, str, FactionData[i][factionSkins][j]);
			}
	        for (new j = 0; j < 10; j ++) {
		        format(str, sizeof(str), "factionWeapon%d", j + 1);

		        cache_get_value_name_int(i, str, FactionData[i][factionWeapons][j]);

		        format(str, sizeof(str), "factionAmmo%d", j + 1);

				cache_get_value_name_int(i, str, FactionData[i][factionAmmo][j]);

		        format(str, sizeof(str), "factionDurability%d", j + 1);

				cache_get_value_name_int(i, str, FactionData[i][factionDurability][j]);
			}
			for (new j = 0; j < 15; j ++) 
			{
			    format(str, sizeof(str), "factionRank%d", j + 1);

			    cache_get_value_name(i, str, FactionRanks[i][j], 32);

			    format(str, sizeof(str), "factionSalary%d", j + 1);

			    cache_get_value_name_int(i, str, FactionData[i][factionSalary][j]);
			}
			Faction_Refresh(i);
		}
		printf("[FACTION] Loaded %d faction from database", rows);
	}
	return 1;
}
Faction_GetName(playerid)
{
    new
		factionid = PlayerData[playerid][pFaction],
		name[32] = "None";

 	if (factionid == -1)
	    return name;

	format(name, 32, FactionData[factionid][factionName]);
	return name;
}

Faction_GetRank(playerid)
{
    new
		factionid = PlayerData[playerid][pFaction],
		rank[32] = "None";

 	if (factionid == -1)
	    return rank;

	format(rank, 32, FactionRanks[factionid][PlayerData[playerid][pFactionRank] - 1]);
	return rank;
}
stock ShowMDC(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid))
		return SendErrorMessage(playerid, "You must inside faction vehicle!");

	if(GetFactionType(playerid) == FACTION_POLICE)
	{
		if(!IsPoliceVehicle(GetPlayerVehicleID(playerid)))
			return SendErrorMessage(playerid, "You must be inside Police Vehicle!");

		ShowPlayerDialog(playerid, DIALOG_MDC, DIALOG_STYLE_LIST, "MDC - Dashboard", "Recent 911 calls\nPlate Search", "Select", "Logout");
		PlayerPlayNearbySound(playerid, MDC_OPEN);
		SetPlayerChatBubble(playerid, "* Logs into the Mobile Data Computer *", COLOR_PURPLE, 15.0, 10000);
	}
	else
	{
		if(!IsMedicVehicle(GetPlayerVehicleID(playerid)))
			return SendErrorMessage(playerid, "You must be inside Medic Vehicle!");		

		ShowPlayerDialog(playerid, DIALOG_MDC, DIALOG_STYLE_LIST, "MDC - Dashboard", "Recent 911 calls", "Select", "Close");
		PlayerPlayNearbySound(playerid, MDC_OPEN);
		SetPlayerChatBubble(playerid, "* Logs into the Mobile Data Computer *", COLOR_PURPLE, 15.0, 10000);
	}
	return 1;
}

stock SendDutyMessage(faction, color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[256]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 8); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if (GetFactionType(i) == faction && PlayerData[i][pOnDuty])
			{
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
	foreach (new i : Player)
	{
		if (GetFactionType(i) == faction && PlayerData[i][pOnDuty]) {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}

stock SendFactionMessageEx(faction, color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[256]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 8); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if (GetFactionType(i) == faction)
			{
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
	foreach (new i : Player)
	{
		if (GetFactionType(i) == faction) {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}

stock SendFactionMessage(factionid, color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 12)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 12); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string
		#emit PUSH.C args

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		foreach (new i : Player) if (PlayerData[i][pFaction] == factionid) 
		{
		    SendClientMessage(i, color, string);
		}
		return 1;
	}
	foreach (new i : Player) if (PlayerData[i][pFaction] == factionid) 
	{
 		SendClientMessage(i, color, str);
	}
	return 1;
}

stock SetFactionSkin(playerid, model)
{
	SetPlayerSkin(playerid, model);
	PlayerData[playerid][pFactionSkin] = model;
}

stock ResetFaction(playerid)
{
    PlayerData[playerid][pFaction] = -1;
    PlayerData[playerid][pFactionID] = -1;
    PlayerData[playerid][pFactionRank] = 0;
    PlayerData[playerid][pOnDuty] = false;
    SetPlayerSkin(playerid, PlayerData[playerid][pSkin]);
    SetPlayerColor(playerid, COLOR_WHITE);
}

stock IsMedicVehicle(vehicleid)
{
	forex(i, sizeof(LSMDVehicles))
	{
		if(vehicleid == LSMDVehicles[i]) return 1;
	}	
	return 0;
}

stock IsPoliceVehicle(vehicleid)
{
	forex(i, sizeof(LSPDVehicles))
	{
		if(vehicleid == LSPDVehicles[i]) return 1;
	}	
	return 0;
}

stock CountFaction(faction)
{
	new count = 0;
	foreach(new i : Player) if(GetFactionType(i) == faction && PlayerData[i][pOnDuty])
	{
		count++;
	}
	return count;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_FACTION_RETURN)
	{
		callcmd::faction(playerid, "menu");
	}
	if(dialogid == DIALOG_FACTION_MENU)
	{
		if(response)
		{
			new str[1012];
			if(listitem == 0)
			{
				if(GetFactionType(playerid) == FACTION_FAMILY)
				{
					format(str, sizeof(str), "Name(ID)\tRank\n");
				}
				else
				{
					format(str, sizeof(str), "Name(ID)\tStatus\tRank\tDuty Time\n");
				}
				foreach(new i : Player) if(PlayerData[i][pFaction] == PlayerData[playerid][pFaction])
				{
					if(GetFactionType(playerid) == FACTION_FAMILY)
					{
						format(str, sizeof(str), "%s%s(%d)\t%s\n", str, NormalName(i), i, Faction_GetRank(i));
					}
					else
					{
						format(str, sizeof(str), "%s%s(%d)\t%s\t%s\t%dh %dm %ds\n", str, NormalName(i), i, (!PlayerData[i][pOnDuty]) ? ("Off Duty") : ("On Duty"), Faction_GetRank(i), PlayerData[i][pDutyHour], PlayerData[i][pDutyMinute], PlayerData[i][pDutySecond]);
					}
				}
				ShowPlayerDialog(playerid, DIALOG_FACTION_RETURN, DIALOG_STYLE_TABLIST_HEADERS, "Online Member(s)", str, "Return", "");
			}
			if(listitem == 1)
			{
				new query[167];
				mysql_format(sqlcon, query, sizeof(query), "SELECT * FROM characters WHERE Faction = '%d'", PlayerData[playerid][pFaction]);
				mysql_query(sqlcon, query);
				if(cache_num_rows())
				{
					format(str, sizeof(str), "Name\tRank\n");
					forex(i, cache_num_rows())
					{
						new tempname[24], rank;
						cache_get_value_name(i, "Name", tempname, 24);
						cache_get_value_name_int(i, "FactionRank", rank);

						format(str, sizeof(str), "%s%s\tRank %d\n", str, tempname, rank);
					}
					ShowPlayerDialog(playerid, DIALOG_FACTION_RETURN, DIALOG_STYLE_TABLIST_HEADERS, "Total Member(s)", str, "Return", "");
				}
			}
		}
	}
	if(dialogid == DIALOG_EDITLOCKER_SKIN_MODEL)
	{
		if (response)
		{
		    new skin = strval(inputtext);

		    if (isnull(inputtext))
		        return  ShowPlayerDialog(playerid, DIALOG_EDITLOCKER_SKIN_MODEL, DIALOG_STYLE_INPUT, "Add by Model ID", "Please enter the model ID of the skin below (0-311):", "Add", "Cancel");

			if (skin < 0 || skin > 311)
			    return ShowPlayerDialog(playerid, DIALOG_EDITLOCKER_SKIN_MODEL, DIALOG_STYLE_INPUT, "Add by Model ID", "Please enter the model ID of the skin below (0-311):", "Add", "Cancel");

	        FactionData[PlayerData[playerid][pFactionEdit]][factionSkins][PlayerData[playerid][pSelectedSlot]] = skin;
			Faction_Save(PlayerData[playerid][pFactionEdit]);

			if (skin) {
			    SendServerMessage(playerid, "You have set the skin ID in slot %d to %d.", PlayerData[playerid][pSelectedSlot] + 1, skin);
			}
			else {
			    SendServerMessage(playerid, "You have removed the skin ID in slot %d.", PlayerData[playerid][pSelectedSlot] + 1);
			}
		}
	}
	if(dialogid == DIALOG_EDITLOCKER_SKIN)
	{
		if (response)
		{
		    static
		        skins[299];

			switch (listitem)
			{
			    case 0:
			        ShowPlayerDialog(playerid, DIALOG_EDITLOCKER_SKIN_MODEL, DIALOG_STYLE_INPUT, "Add by Model ID", "Please enter the model ID of the skin below (0-311):", "Add", "Cancel");

				case 1:
				{
				    for (new i = 0; i < sizeof(skins); i ++)
				        skins[i] = i + 1;

					ShowModelSelectionMenu(playerid, "Add Skin", MODEL_SELECTION_ADD_SKIN, skins, sizeof(skins), -16.0, 0.0, -55.0);
				}
				case 2:
				{
				    FactionData[PlayerData[playerid][pFactionEdit]][factionSkins][PlayerData[playerid][pSelectedSlot]] = 0;

				    Faction_Save(PlayerData[playerid][pFactionEdit]);
				    SendServerMessage(playerid, "You have removed the skin ID in slot %d.", PlayerData[playerid][pSelectedSlot] + 1);
				}
			}
		}
	}
	if(dialogid == DIALOG_EDITLOCKER)
	{
		if (response)
		{
		    switch (listitem)
		    {
		        case 0:
		        {
				    new
				        Float:x,
				        Float:y,
				        Float:z;

					GetPlayerPos(playerid, x, y, z);

					FactionData[PlayerData[playerid][pFactionEdit]][factionLockerPos][0] = x;
					FactionData[PlayerData[playerid][pFactionEdit]][factionLockerPos][1] = y;
					FactionData[PlayerData[playerid][pFactionEdit]][factionLockerPos][2] = z;

					FactionData[PlayerData[playerid][pFactionEdit]][factionLockerInt] = GetPlayerInterior(playerid);
					FactionData[PlayerData[playerid][pFactionEdit]][factionLockerWorld] = GetPlayerVirtualWorld(playerid);

					Faction_Refresh(PlayerData[playerid][pFactionEdit]);
					Faction_Save(PlayerData[playerid][pFactionEdit]);
					SendServerMessage(playerid, "You have adjusted the locker position of faction ID: %d.", PlayerData[playerid][pFactionEdit]);
				}
				case 1:
				{
					new
					    string[512];

					string[0] = 0;

				    for (new i = 0; i < 10; i ++)
					{
				        if (FactionData[PlayerData[playerid][pFactionEdit]][factionWeapons][i])
							format(string, sizeof(string), "%sWeapon %d: %s\n", string, i + 1, ReturnWeaponName(FactionData[PlayerData[playerid][pFactionEdit]][factionWeapons][i]));

						else format(string, sizeof(string), "%sEmpty Slot\n", string);
				    }
				    ShowPlayerDialog(playerid, DIALOG_EDITLOCKER_WEAPON, DIALOG_STYLE_LIST, "Locker Weapons", string, "Select", "Cancel");
				}
			}
		}
	}
	if(dialogid == DIALOG_EDITLOCKER_WEAPON_ID)
	{
		if (response)
		{
		    new weaponid = strval(inputtext);

		    if (isnull(inputtext))
		        return ShowPlayerDialog(playerid, DIALOG_EDITLOCKER_WEAPON_ID, DIALOG_STYLE_INPUT, "Set Weapon", sprintf("Current Weapon: %s (%d)\n\nPlease enter the new weapon ID for slot %d:", ReturnWeaponName(FactionData[PlayerData[playerid][pFactionEdit]][factionWeapons][PlayerData[playerid][pSelectedSlot]]), FactionData[PlayerData[playerid][pFactionEdit]][factionWeapons][PlayerData[playerid][pSelectedSlot]], PlayerData[playerid][pSelectedSlot]), "Submit", "Cancel");

			if (weaponid < 0 || weaponid > 46)
			    return ShowPlayerDialog(playerid, DIALOG_EDITLOCKER_WEAPON_ID, DIALOG_STYLE_INPUT, "Set Weapon", sprintf("Current Weapon: %s (%d)\n\nPlease enter the new weapon ID for slot %d:", ReturnWeaponName(FactionData[PlayerData[playerid][pFactionEdit]][factionWeapons][PlayerData[playerid][pSelectedSlot]]), FactionData[PlayerData[playerid][pFactionEdit]][factionWeapons][PlayerData[playerid][pSelectedSlot]], PlayerData[playerid][pSelectedSlot]), "Submit", "Cancel");

	        FactionData[PlayerData[playerid][pFactionEdit]][factionWeapons][PlayerData[playerid][pSelectedSlot]] = weaponid;
	        Faction_Save(PlayerData[playerid][pFactionEdit]);

		    if (weaponid) {
			    SendServerMessage(playerid, "You have set the weapon in slot %d to %s.", PlayerData[playerid][pSelectedSlot] + 1, ReturnWeaponName(weaponid));
			}
			else {
			    SendServerMessage(playerid, "You have removed the weapon in slot %d.", PlayerData[playerid][pSelectedSlot] + 1);
			}
		}
	}
	if(dialogid == DIALOG_EDITLOCKER_WEAPON_AMMO)
	{
		if (response)
		{
		    new ammo = strval(inputtext);

		    if (isnull(inputtext))
		        return ShowPlayerDialog(playerid, DIALOG_EDITLOCKER_WEAPON_AMMO, DIALOG_STYLE_INPUT, "Set Ammunition", sprintf("Current Ammo: %d\n\nPlease enter the new ammunition for the weapon in slot %d:", FactionData[PlayerData[playerid][pFactionEdit]][factionAmmo][PlayerData[playerid][pSelectedSlot]], PlayerData[playerid][pSelectedSlot]), "Submit", "Cancel");

			if (ammo < 1 || ammo > 15000)
			    return ShowPlayerDialog(playerid, DIALOG_EDITLOCKER_WEAPON_AMMO, DIALOG_STYLE_INPUT, "Set Ammunition", sprintf("Current Ammo: %d\n\nPlease enter the new ammunition for the weapon in slot %d:", FactionData[PlayerData[playerid][pFactionEdit]][factionAmmo][PlayerData[playerid][pSelectedSlot]], PlayerData[playerid][pSelectedSlot]), "Submit", "Cancel");

	        FactionData[PlayerData[playerid][pFactionEdit]][factionAmmo][PlayerData[playerid][pSelectedSlot]] = ammo;
	        Faction_Save(PlayerData[playerid][pFactionEdit]);

			SendServerMessage(playerid, "You have set the ammunition in slot %d to %d.", PlayerData[playerid][pSelectedSlot] + 1, ammo);
		}		
	}
	if(dialogid == DIALOG_EDITLOCKER_WEAPON_SET)
	{
		if (response)
		{
		    switch (listitem)
		    {
		        case 0:
		        	ShowPlayerDialog(playerid, DIALOG_EDITLOCKER_WEAPON_ID, DIALOG_STYLE_INPUT, "Set Weapon", sprintf("Current Weapon: %s (%d)\n\nPlease enter the new weapon ID for slot %d:", ReturnWeaponName(FactionData[PlayerData[playerid][pFactionEdit]][factionWeapons][PlayerData[playerid][pSelectedSlot]]), FactionData[PlayerData[playerid][pFactionEdit]][factionWeapons][PlayerData[playerid][pSelectedSlot]], PlayerData[playerid][pSelectedSlot]), "Submit", "Cancel");

				case 1:
		            ShowPlayerDialog(playerid, DIALOG_EDITLOCKER_WEAPON_AMMO, DIALOG_STYLE_INPUT, "Set Ammunition", sprintf("Current Ammo: %d\n\nPlease enter the new ammunition for the weapon in slot %d:", FactionData[PlayerData[playerid][pFactionEdit]][factionAmmo][PlayerData[playerid][pSelectedSlot]], PlayerData[playerid][pSelectedSlot]), "Submit", "Cancel");

				case 2:
				{
				    FactionData[PlayerData[playerid][pFactionEdit]][factionWeapons][PlayerData[playerid][pSelectedSlot]] = 0;
					FactionData[PlayerData[playerid][pFactionEdit]][factionAmmo][PlayerData[playerid][pSelectedSlot]] = 0;

					Faction_Save(PlayerData[playerid][pFactionEdit]);

					SendServerMessage(playerid, "You have removed the weapon in slot %d.", PlayerData[playerid][pSelectedSlot] + 1);
				}
		    }
		}
	}
	if(dialogid == DIALOG_EDITLOCKER_WEAPON)
	{
		if (response)
		{
		    PlayerData[playerid][pSelectedSlot] = listitem;
		    ShowPlayerDialog(playerid, DIALOG_EDITLOCKER_WEAPON_SET, DIALOG_STYLE_LIST, "Edit Weapon", sprintf("Set Weapon (%d)\nSet Ammunition (%d)\nClear Slot", FactionData[PlayerData[playerid][pFactionEdit]][factionWeapons][PlayerData[playerid][pSelectedSlot]], FactionData[PlayerData[playerid][pFactionEdit]][factionAmmo][PlayerData[playerid][pSelectedSlot]]), "Select", "Cancel");
		}
	}
	if(dialogid == DIALOG_LOCKER_WEAPON)
	{
		new factionid = PlayerData[playerid][pFaction];
		if (response)
		{
		    new
		        weaponid = FactionData[factionid][factionWeapons][listitem],
		        ammo = FactionData[factionid][factionAmmo][listitem],
		        dura = FactionData[factionid][factionDurability][listitem];

		    if (weaponid)
			{
				if(GetFactionType(playerid) == FACTION_FAMILY)
				{
			        if (PlayerHasWeapon(playerid, weaponid))
			            return SendErrorMessage(playerid, "You have this weapon equipped already.");

			        GivePlayerWeaponEx(playerid, weaponid, ammo, dura);
			        SendNearbyMessage(playerid, 15.0, COLOR_PURPLE, "* %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(weaponid));

			        FactionData[factionid][factionWeapons][listitem] = 0;
			        FactionData[factionid][factionAmmo][listitem] = 0;

			        Faction_Save(factionid);
				}
				else
				{
					if(!PlayerData[playerid][pOnDuty])
						return SendErrorMessage(playerid, "You must faction duty!");

			        if (PlayerHasWeapon(playerid, weaponid))
			            return SendErrorMessage(playerid, "You have this weapon equipped already.");

			        GivePlayerWeaponEx(playerid, weaponid, ammo, 500);
			        SendNearbyMessage(playerid, 15.0, COLOR_PURPLE, "* %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(weaponid));
				}
			}
			else
			{
			    if (GetFactionType(playerid) == FACTION_FAMILY)
			    {
			        if ((weaponid = GetWeapon(playerid)) == 0)
			            return SendErrorMessage(playerid, "You are not holding any weapon.");

			        FactionData[factionid][factionWeapons][listitem] = weaponid;
			        FactionData[factionid][factionAmmo][listitem] = PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_ammo];
			        FactionData[factionid][factionDurability][listitem] = PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_durability];

			        Faction_Save(factionid);

	                ResetWeaponID(playerid, weaponid);
			        SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s takes out a %s and stores it in the locker.", ReturnName(playerid), ReturnWeaponName(weaponid));
				}
				else
				{
				    SendErrorMessage(playerid, "The selected weapon slot is empty.");
				}
		    }
		}
		else {
		    callcmd::faction(playerid, "locker");
		}
	}
	if(dialogid == DIALOG_LOCKER)
	{
		if (response)
		{
			new factionid = PlayerData[playerid][pFaction];
		    new
		        skins[8],
		        string[512];

			string[0] = 0;

		    if (FactionData[factionid][factionType] != FACTION_FAMILY)
		    {
		        switch (listitem)
		        {
		            case 0:
		            {
		                if (!PlayerData[playerid][pOnDuty])
		                {
		                    PlayerData[playerid][pOnDuty] = true;
		                    SetPlayerArmour(playerid, 100.0);

		                    SetFactionColor(playerid);
		                    SetPlayerSkin(playerid, PlayerData[playerid][pFactionSkin]);
		                    SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s has clocked in and is now on duty.", ReturnName(playerid));

		                    PlayerData[playerid][pDutyTime] = 3600;
		                }
		                else
		                {
		                    PlayerData[playerid][pOnDuty] = false;
		                    SetPlayerArmour(playerid, 0.0);

		                    SetPlayerColor(playerid, COLOR_WHITE);
		                    SetPlayerSkin(playerid, PlayerData[playerid][pSkin]);
		                    ResetWeapons(playerid);

		                    SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s has clocked out and is now off duty.", ReturnName(playerid));

							PlayerData[playerid][pDutySecond] = 0;
							PlayerData[playerid][pDutyMinute] = 0;
							PlayerData[playerid][pDutyHour] = 0;
		                }
					}
					case 1:
					{
					    SetPlayerArmour(playerid, 100.0);
					    SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s reaches into the locker and takes out a vest.", ReturnName(playerid));
					}
					case 2:
					{
						for (new i = 0; i < sizeof(skins); i ++)
						    skins[i] = (FactionData[factionid][factionSkins][i]) ? (FactionData[factionid][factionSkins][i]) : (19300);

						ShowModelSelectionMenu(playerid, "Choose Skin", MODEL_SELECTION_FACTION_SKIN, skins, sizeof(skins), -16.0, 0.0, -55.0);
					}
					case 3:
					{
					    for (new i = 0; i < 10; i ++)
						{
					        if (FactionData[factionid][factionWeapons][i])
								format(string, sizeof(string), "%sWeapon %d: %s\n", string, i + 1, ReturnWeaponName(FactionData[factionid][factionWeapons][i]));

							else format(string, sizeof(string), "%sEmpty Slot\n", string);
					    }
					    ShowPlayerDialog(playerid, DIALOG_LOCKER_WEAPON, DIALOG_STYLE_LIST, "Locker Weapons", string, "Equip", "Close");
					}
				}
		    }
		    else
		    {
		        switch (listitem)
		        {
					case 0:
					{
					    for (new i = 0; i < 10; i ++)
						{
					        if (FactionData[factionid][factionWeapons][i] && GetFactionType(playerid) != FACTION_FAMILY)
								format(string, sizeof(string), "%sWeapon %d: %s\n", string, i + 1, ReturnWeaponName(FactionData[factionid][factionWeapons][i]));

							else if (FactionData[factionid][factionWeapons][i] && GetFactionType(playerid) == FACTION_FAMILY)
								format(string, sizeof(string), "%s[%d] : %s (%d ammo) (%d durability)\n", string, i + 1, ReturnWeaponName(FactionData[factionid][factionWeapons][i]), FactionData[factionid][factionAmmo][i], FactionData[factionid][factionDurability][i]);

							else format(string, sizeof(string), "%sEmpty Slot\n", string);
					    }
					    ShowPlayerDialog(playerid, DIALOG_LOCKER_WEAPON, DIALOG_STYLE_LIST, "Locker Weapons", string, "Equip", "Close");
					}
					case 1:
					{
						new count = false;
						forex(i, MAX_FACTION_VEHICLE) if(FactionVehicle[i][fvFaction] == PlayerData[playerid][pFactionID])
						{
							if(IsValidVehicle(FactionVehicle[i][fvVehicle]))
								SetVehicleToRespawn(FactionVehicle[i][fvVehicle]);

							VehCore[FactionVehicle[i][fvVehicle]][vehFuel] = 100;

							count = true;
						}
						if(count)
							SendFactionMessage(PlayerData[playerid][pFaction], COLOR_SERVER, "FACTION VEHICLE: {FFFFFF}%s faction vehicle has been respawned by {FFFF00}%s", FactionData[factionid][factionName], ReturnName(playerid));
						else
							SendErrorMessage(playerid, "Your faction doesn't have faction vehicle!");
					}
				}
		    }
		}
	}
	if(dialogid == DIALOG_EDITRANK_NAME)
	{
		new str[256];
		if (response)
		{
		    if (isnull(inputtext))
				return format(str, sizeof(str), "Rank: %s (%d)\n\nPlease enter a new name for this rank below:", FactionRanks[PlayerData[playerid][pFactionEdit]][PlayerData[playerid][pSelectedSlot]], PlayerData[playerid][pSelectedSlot] + 1), 
						ShowPlayerDialog(playerid, DIALOG_EDITRANK_NAME, DIALOG_STYLE_INPUT, "Set Rank Name", str, "Submit", "Close");

		    if (strlen(inputtext) > 32)
		        return format(str, sizeof(str), "Rank: %s (%d)\n\nPlease enter a new name for this rank below:", FactionRanks[PlayerData[playerid][pFactionEdit]][PlayerData[playerid][pSelectedSlot]], PlayerData[playerid][pSelectedSlot] + 1), 
						ShowPlayerDialog(playerid, DIALOG_EDITRANK_NAME, DIALOG_STYLE_INPUT, "Set Rank Name", str, "Submit", "Close");

			format(FactionRanks[PlayerData[playerid][pFactionEdit]][PlayerData[playerid][pSelectedSlot]], 32, inputtext);
			Faction_SaveRanks(PlayerData[playerid][pFactionEdit]);

			Faction_ShowRanks(playerid, PlayerData[playerid][pFactionEdit]);
			SendServerMessage(playerid, "You have set the name of rank %d to \"%s\".", PlayerData[playerid][pSelectedSlot] + 1, inputtext);
		}
		else Faction_ShowRanks(playerid, PlayerData[playerid][pFactionEdit]);
	}
	if(dialogid == DIALOG_EDITFACTION_SALARY_LIST)
	{
		if (response)
		{
		    if (!FactionData[PlayerData[playerid][pFactionEdit]][factionExists])
				return 0;

			PlayerData[playerid][pListitem] = listitem;
			new str[256];
			format(str, sizeof(str), "Please enter new salary for rank %d below:", PlayerData[playerid][pListitem] + 1);
			ShowPlayerDialog(playerid, DIALOG_EDITFACTION_SALARY_SET, DIALOG_STYLE_INPUT, "Set Rank Salary", str, "Submit", "Close");
		}
	}			
	if(dialogid == DIALOG_EDITFACTION_SALARY_SET)
	{
		if(response)
		{
			new id = PlayerData[playerid][pFactionEdit], slot = PlayerData[playerid][pListitem], str[256];
			if(isnull(inputtext))
				return format(str, sizeof(str), "Please enter new salary for rank %d below:", PlayerData[playerid][pListitem] + 1),
						ShowPlayerDialog(playerid, DIALOG_EDITFACTION_SALARY_SET, DIALOG_STYLE_INPUT, "Set Rank Salary", str, "Submit", "Close");

			FactionData[id][factionSalary][slot] = strcash(inputtext);
			Faction_Save(id);
			SendServerMessage(playerid, "You have set salary for rank %d to $%s", slot + 1, FormatMoney(strcash(inputtext)));
		}
	}
	if(dialogid == DIALOG_EDITRANK)
	{
		if (response)
		{
		    if (!FactionData[PlayerData[playerid][pFactionEdit]][factionExists])
				return 0;

			PlayerData[playerid][pSelectedSlot] = listitem;
			new str[256];
			format(str, sizeof(str), "Rank: %s (%d)\n\nPlease enter a new name for this rank below:", FactionRanks[PlayerData[playerid][pFactionEdit]][PlayerData[playerid][pSelectedSlot]], PlayerData[playerid][pSelectedSlot] + 1);
			ShowPlayerDialog(playerid, DIALOG_EDITRANK_NAME, DIALOG_STYLE_INPUT, "Set Rank Name", str, "Submit", "Close");
		}
	}
	return 1;
}