CMD:setleader(playerid, params[])
{
	static
		userid,
		id;

    if (CheckAdmin(playerid, 4))
	    return SendErrorMessage(playerid, "You don't have permission to use this command.");

	if (sscanf(params, "ud", userid, id))
	    return SendSyntaxMessage(playerid, "/setleader [playerid/PartOfName] [faction id] (Use -1 to unset)");

	if (userid == INVALID_PLAYER_ID)
	    return SendErrorMessage(playerid, "You have specified an invalid player.");

    if ((id < -1 || id >= MAX_FACTIONS) || (id != -1 && !FactionData[id][factionExists]))
	    return SendErrorMessage(playerid, "You have specified an invalid faction ID.");

	if (id == -1)
	{
	    ResetFaction(userid);

	    SendServerMessage(playerid, "You have removed %s's faction leadership.", ReturnName(userid));
    	SendServerMessage(userid, "%s has removed your faction leadership.", AccountData[playerid][uUsername]);
	}
	else
	{
		SetFaction(userid, id);
		PlayerData[userid][pFactionRank] = FactionData[id][factionRanks];

		SendServerMessage(playerid, "You have made %s the leader of \"%s\".", ReturnName(userid), FactionData[id][factionName]);
    	SendServerMessage(userid, "%s has made you the leader of \"%s\".",AccountData[playerid][uUsername], FactionData[id][factionName]);
	}
    return 1;
}

CMD:createfaction(playerid, params[])
{
	static
	    id = -1,
		type,
		name[32];

    if (CheckAdmin(playerid, 4))
	    return SendErrorMessage(playerid, "You don't have permission to use this command.");

	if (sscanf(params, "ds[32]", type, name))
	{
	    SendSyntaxMessage(playerid, "/createfaction [type] [name]");
	    SendClientMessage(playerid, COLOR_YELLOW, "[TYPES]:{FFFFFF} 1: Police | 2: News | 3: Medical | 4: Government | 5: Family");
		return 1;
	}
	if (type < 1 || type > 5)
	    return SendErrorMessage(playerid, "Invalid type specified. Types range from 1 to 5.");

	id = Faction_Create(name, type);

	if (id == -1)
	    return SendErrorMessage(playerid, "The server has reached the limit for factions.");

	SendServerMessage(playerid, "You have successfully created faction ID: %d.", id);
	return 1;
}

CMD:editfaction(playerid, params[])
{
	static
	    id,
	    type[24],
	    string[128];

	if (CheckAdmin(playerid, 4))
	    return SendErrorMessage(playerid, "You don't have permission to use this command.");

	if (sscanf(params, "ds[24]S()[128]", id, type, string))
 	{
	 	SendSyntaxMessage(playerid, "/editfaction [id] [name]");
	    SendClientMessage(playerid, COLOR_YELLOW, "[NAMES]:{FFFFFF} name, color, type, models, locker, ranks, maxranks, salary");
		return 1;
	}
	if ((id < 0 || id >= MAX_FACTIONS) || !FactionData[id][factionExists])
	    return SendErrorMessage(playerid, "You have specified an invalid faction ID.");

    if (!strcmp(type, "name", true))
	{
	    new name[32];

	    if (sscanf(string, "s[32]", name))
	        return SendSyntaxMessage(playerid, "/editfaction [id] [name] [new name]");

	    format(FactionData[id][factionName], 32, name);

	    Faction_Save(id);
		SendAdminMessage(COLOR_LIGHTRED, "AdmCmd: %s has adjusted the name of faction ID: %d to \"%s\".", AccountData[playerid][uUsername], id, name);
	}
	else if (!strcmp(type, "maxranks", true))
	{
	    new ranks;

	    if (sscanf(string, "d", ranks))
	        return SendSyntaxMessage(playerid, "/editfaction [id] [maxranks] [maximum ranks]");

		if (ranks < 1 || ranks > 15)
		    return SendErrorMessage(playerid, "The specified ranks can't be below 1 or above 15.");

	    FactionData[id][factionRanks] = ranks;

	    Faction_Save(id);
		SendAdminMessage(COLOR_LIGHTRED, "AdmCmd: %s has adjusted the maximum ranks of faction ID: %d to %d.", AccountData[playerid][uUsername], id, ranks);
	}
	else if (!strcmp(type, "ranks", true))
	{
	    Faction_ShowRanks(playerid, id);
	}
	else if (!strcmp(type, "color", true))
	{
	    new color;

	    if (sscanf(string, "h", color))
	        return SendSyntaxMessage(playerid, "/editfaction [id] [color] [hex color]");

	    FactionData[id][factionColor] = color;
	    Faction_Update(id);

	    Faction_Save(id);
		SendAdminMessage(COLOR_LIGHTRED, "AdmCmd: %s has adjusted the {%06x}color{FF6347} of faction ID: %d.", AccountData[playerid][uUsername], color >>> 8, id);
	}
	else if (!strcmp(type, "type", true))
	{
	    new typeint;

	    if (sscanf(string, "d", typeint))
     	{
		 	SendSyntaxMessage(playerid, "/editfaction [id] [type] [faction type]");
            SendClientMessage(playerid, COLOR_YELLOW, "[TYPES]:{FFFFFF} 1: Police | 2: News | 3: Medical | 4: Government | 5: Family");
            return 1;
		}
		if (typeint < 1 || typeint > 5)
		    return SendErrorMessage(playerid, "Invalid type specified. Types range from 1 to 5.");

	    FactionData[id][factionType] = typeint;

	    Faction_Save(id);
		SendAdminMessage(COLOR_LIGHTRED, "AdmCmd: %s has adjusted the type of faction ID: %d to %d.", AccountData[playerid][uUsername], id, typeint);
	}
	else if (!strcmp(type, "models", true))
	{
	    static
	        skins[8];

		for (new i = 0; i < sizeof(skins); i ++)
		    skins[i] = (FactionData[id][factionSkins][i]) ? (FactionData[id][factionSkins][i]) : (19300);

	    PlayerData[playerid][pFactionEdit] = id;
		ShowModelSelectionMenu(playerid, "Faction Skins", MODEL_SELECTION_FACTION_SKINS, skins, sizeof(skins), -16.0, 0.0, -55.0);
	}
	else if (!strcmp(type, "locker", true))
	{
        PlayerData[playerid][pFactionEdit] = id;
		ShowPlayerDialog(playerid, DIALOG_EDITLOCKER, DIALOG_STYLE_LIST, "Faction Locker", "Set Location\nLocker Weapons", "Select", "Cancel");
	}
	else if(!strcmp(type, "salary", true))
	{
		Faction_ShowSalary(playerid, id);
	}
	return 1;
}

CMD:destroyfaction(playerid, params[])
{
	static
	    id = 0;

    if (CheckAdmin(playerid, 4))
	    return SendErrorMessage(playerid, "You don't have permission to use this command.");

	if (sscanf(params, "d", id))
	    return SendSyntaxMessage(playerid, "/destroyfaction [faction id]");

	if ((id < 0 || id >= MAX_FACTIONS) || !FactionData[id][factionExists])
	    return SendErrorMessage(playerid, "You have specified an invalid faction ID.");

	Faction_Delete(id);
	SendServerMessage(playerid, "You have successfully destroyed faction ID: %d.", id);
	return 1;
}

CMD:f(playerid, params[])
	return cmd_faction(playerid, params);

CMD:faction(playerid, params[])
{

	new type[24], string[128];
	if (sscanf(params, "s[24]S()[128]", type, string))
		return SendSyntaxMessage(playerid, "/faction [Names]"), SendClientMessage(playerid, COLOR_SERVER, "Names: {FFFFFF}locker, invite, kick, menu, accept, setrank");

	if(!strcmp(type, "locker", true))
	{
		if(PlayerData[playerid][pFaction] == -1)
			return SendErrorMessage(playerid, "You aren't in any faction.");

		new factionid = PlayerData[playerid][pFaction];

	 	if (factionid == -1)
		    return SendErrorMessage(playerid, "You must be a faction member.");

		if (!IsNearFactionLocker(playerid))
		    return SendErrorMessage(playerid, "You are not in range of your faction's locker.");

	 	if (FactionData[factionid][factionType] != FACTION_FAMILY)
			ShowPlayerDialog(playerid, DIALOG_LOCKER, DIALOG_STYLE_LIST, "Faction Locker", "Toggle Duty\nArmored Vest\nLocker Skins\nLocker Weapons", "Select", "Cancel");

		else ShowPlayerDialog(playerid, DIALOG_LOCKER, DIALOG_STYLE_LIST, "Faction Locker", "Locker Weapons\nRespawn Vehicles", "Select", "Cancel");	
	}
	else if(!strcmp(type, "invite", true))
	{

		new
		    userid;

		if (PlayerData[playerid][pFaction] == -1)
		    return SendErrorMessage(playerid, "You must be a faction member.");

		if (PlayerData[playerid][pFactionRank] < FactionData[PlayerData[playerid][pFaction]][factionRanks] - 1)
		    return SendErrorMessage(playerid, "You must be at least rank %d.", FactionData[PlayerData[playerid][pFaction]][factionRanks] - 1);

		if (sscanf(string, "u", userid))
		    return SendSyntaxMessage(playerid, "/faction invite [playerid/PartOfName]");

		if (userid == INVALID_PLAYER_ID)
		    return SendErrorMessage(playerid, "That player is disconnected.");

		if (PlayerData[userid][pFaction] == PlayerData[playerid][pFaction])
		    return SendErrorMessage(playerid, "That player is already part of your faction.");

	    if (PlayerData[userid][pFaction] != -1)
		    return SendErrorMessage(playerid, "That player is already part of another faction.");

		if(!IsPlayerNearPlayer(playerid, userid, 5.0))
			return SendErrorMessage(playerid, "You must close to that player!");

		PlayerData[userid][pFactionOffer] = playerid;
	    PlayerData[userid][pFactionOffered] = PlayerData[playerid][pFaction];

	    SendServerMessage(playerid, "You have requested %s to join \"%s\".", ReturnName(userid), Faction_GetName(playerid));
	    SendServerMessage(userid, "%s has offered you to join \"%s\" (type \"/faction accept\").", ReturnName(playerid), Faction_GetName(playerid));
	}
	else if(!strcmp(type, "accept", true) && PlayerData[playerid][pFactionOffer] != INVALID_PLAYER_ID)
	{
	    new
	        targetid = PlayerData[playerid][pFactionOffer],
	        factionid = PlayerData[playerid][pFactionOffered];

		if (!FactionData[factionid][factionExists] || PlayerData[targetid][pFactionRank] < FactionData[PlayerData[targetid][pFaction]][factionRanks] - 1)
	   	 	return SendErrorMessage(playerid, "The faction offer is no longer available.");

		SetFaction(playerid, factionid);
		PlayerData[playerid][pFactionRank] = 1;

		SendServerMessage(playerid, "You have accepted %s's offer to join \"%s\".", ReturnName(targetid), Faction_GetName(targetid));
		SendServerMessage(targetid, "%s has accepted your offer to join \"%s\".", ReturnName(playerid), Faction_GetName(targetid));

        PlayerData[playerid][pFactionOffer] = INVALID_PLAYER_ID;
        PlayerData[playerid][pFactionOffered] = -1;
	}
	else if(!strcmp(type, "menu", true))
	{
		if(PlayerData[playerid][pFaction] == -1)
			return SendErrorMessage(playerid, "You must be a faction member.");

		ShowPlayerDialog(playerid, DIALOG_FACTION_MENU, DIALOG_STYLE_LIST, "Faction Menu", "Online Member(s)\nTotal Member(s)", "Select", "Close");
	}
	else if(!strcmp(type, "setrank", true))
	{
    	new
		    userid,
			rankid;

		if (PlayerData[playerid][pFaction] == -1)
		    return SendErrorMessage(playerid, "You must be a faction member.");

		if (PlayerData[playerid][pFactionRank] < FactionData[PlayerData[playerid][pFaction]][factionRanks] - 1)
		    return SendErrorMessage(playerid, "You must be at least rank %d.", FactionData[PlayerData[playerid][pFaction]][factionRanks] - 1);

		if (sscanf(string, "ud", userid, rankid))
		    return SendSyntaxMessage(playerid, "/faction setrank [playerid/PartOfName] [rank (1-%d)]", FactionData[PlayerData[playerid][pFaction]][factionRanks]);

		if (userid == INVALID_PLAYER_ID)
		    return SendErrorMessage(playerid, "That player is disconnected.");

		if (PlayerData[userid][pFaction] != PlayerData[playerid][pFaction])
		    return SendErrorMessage(playerid, "That player is not part of your faction.");

		if (rankid < 0 || rankid > FactionData[PlayerData[playerid][pFaction]][factionRanks])
		    return SendErrorMessage(playerid, "Invalid rank specified. Ranks range from 1 to %d.", FactionData[PlayerData[playerid][pFaction]][factionRanks]);

		PlayerData[userid][pFactionRank] = rankid;

	    SendServerMessage(playerid, "You have adjusted %s rank to %s (%d).", ReturnName(userid), Faction_GetRank(userid), rankid);
	    SendServerMessage(userid, "%s has adjusted your rank to %s (%d).", ReturnName(playerid), Faction_GetRank(userid), rankid);
	}
	else if(!strcmp(type, "kick", true))
	{
		new
		    userid;

		if (PlayerData[playerid][pFaction] == -1)
		    return SendErrorMessage(playerid, "You must be a faction member.");

		if (PlayerData[playerid][pFactionRank] < FactionData[PlayerData[playerid][pFaction]][factionRanks] - 1)
		    return SendErrorMessage(playerid, "You must be at least rank %d.", FactionData[PlayerData[playerid][pFaction]][factionRanks] - 1);

		if (sscanf(string, "u", userid))
		    return SendSyntaxMessage(playerid, "/faction kick [playerid/PartOfName]");

		if (userid == INVALID_PLAYER_ID)
		    return SendErrorMessage(playerid, "That player is disconnected.");

		if (PlayerData[userid][pFaction] != PlayerData[playerid][pFaction])
		    return SendErrorMessage(playerid, "That player is not part of your faction.");

		if(!IsPlayerNearPlayer(playerid, userid, 5.0))
			return SendErrorMessage(playerid, "You must close to that player!");

		ResetFaction(userid);
		SendServerMessage(playerid, "You have kicked %s from your faction!", ReturnName(userid));
	}
	return 1;
}