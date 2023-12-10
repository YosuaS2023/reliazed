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