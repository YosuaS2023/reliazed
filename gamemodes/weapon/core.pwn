#define 	MULTIPLE_MATERIAL	10
#define 	MAX_WEAPON_SLOT		13
#define 	DEFAULT_AMMO		20
#define 	WEAPON_DURABILITY	500

#define 	PLAYER_NORMAL 		1
#define 	PLAYER_OFFICIAL		2


enum e_WeaponItems {
	wep_model,
	wep_material,
	wep_auth
};

new const g_aWeaponItems[][e_WeaponItems] = {
	{WEAPON_KNIFE, 100, PLAYER_NORMAL},
	{WEAPON_COLT45, 350, PLAYER_NORMAL},
	{WEAPON_SILENCED, 500, PLAYER_NORMAL},
	{WEAPON_SHOTGUN, 1000, PLAYER_NORMAL},
	{WEAPON_DEAGLE, 500, PLAYER_OFFICIAL},
	{WEAPON_RIFLE, 1500, PLAYER_OFFICIAL},
	{WEAPON_AK47, 3000, PLAYER_OFFICIAL},
	{WEAPON_TEC9, 1500, PLAYER_OFFICIAL}
};

new const MaxGunAmmo[54] = {
	0,-1,-1,-1,-1,-1,-1,-1,-1,-1,
	-1,-1,-1,-1,-1,-1,10,10,10,0,
	0,0,850,350,350,250,200,350,2000,2000,
	2000,750,2000,100,50,5,5,10,9999,10,
	-1,500,500,10,-1,-1,-1,0,0,0,
	0,0,0,0
};


enum E_WEAPON_DATA {
	weapon_id,
	weapon_slot,
	weapon_durability,
	weapon_ammo
};


new 
	PlayerGuns[MAX_PLAYERS][MAX_WEAPON_SLOT][E_WEAPON_DATA];
	// ListedWeapons[MAX_PLAYERS][MAX_WEAPON_SLOT];

function OnLoadPlayerWeapons(playerid) 
{
	new weaponid;
	
	for(new i = 0; i < cache_num_rows(); i++)
	{
		cache_get_value_int(i, "weaponid", weaponid);
		new slot = g_aWeaponSlots[weaponid];

		if(!(0 < weaponid < 46))
			continue;

	    PlayerGuns[playerid][slot][weapon_id] 			= weaponid;
		PlayerGuns[playerid][slot][weapon_slot] 		= slot;
		cache_get_value_int(i, "ammo", PlayerGuns[playerid][slot][weapon_ammo]);
		cache_get_value_int(i, "durability", PlayerGuns[playerid][slot][weapon_durability]);

		if(!IsPlayerDuty(playerid))
			RefreshWeapon(playerid);
	}

	SetPlayerArmedWeapon(playerid, 0);
	return 1; 
}

#include <YSI\y_hooks>
hook OnPlayerDisconnectEx(playerid) 
{
	if(SQL_IsCharacterLogged(playerid))
	{
		SavePlayerWeapon(playerid);

		for (new i = 0; i < MAX_WEAPON_SLOT; i ++) if(PlayerGuns[playerid][i][weapon_id]) {
	        PlayerGuns[playerid][i][weapon_id] = 0;
	        PlayerGuns[playerid][i][weapon_ammo] = 0;
	        PlayerGuns[playerid][i][weapon_slot] = 0;
	        PlayerGuns[playerid][i][weapon_durability] = 0;
	    }
	    ResetPlayerWeapons(playerid);
	}

	return 1;
}


hook OnPlayerShootDynObj(playerid, weaponid, objectid, Float:x, Float:y, Float:z)
{
	if((!IsPlayerDuty(playerid) || !eventJoin[playerid]) && GetWeapon(playerid) == weaponid)
	{
		new slot = g_aWeaponSlots[weaponid];

		if(--PlayerGuns[playerid][slot][weapon_ammo] <= 0) {
			SetPlayerArmedWeapon(playerid, 0);
			SendCustomMessage(playerid, "WEAPON", "Kamu kehabisan amunisi, isi kembali dengan perintah "YELLOW"/createammo.");
		}

		if(--PlayerGuns[playerid][slot][weapon_durability] <= 0) {
			if(PlayerGuns[playerid][slot][weapon_ammo]) {
				SetPlayerArmedWeapon(playerid, 0);
				SendCustomMessage(playerid, "WEAPON", "Senjata "YELLOW"%s "WHITE"rusak, kamu dapat memperbaikinya dengan '/repairgun'.", ReturnWeaponName(weaponid));
			} else {
				SendCustomMessage(playerid, "WEAPON", "Senjata "YELLOW"%s "WHITE"rusak dan tidak mempunyai amunisi lagi.", ReturnWeaponName(weaponid));
				ResetWeaponID(playerid, weaponid);
			}
		}
	}
	return 1;
}


hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if((!IsPlayerDuty(playerid) || !eventJoin[playerid]) && GetWeapon(playerid) == weaponid)
	{
		new slot = g_aWeaponSlots[weaponid];

		if(--PlayerGuns[playerid][slot][weapon_ammo] <= 0) {
			SetPlayerArmedWeapon(playerid, 0);
			SendCustomMessage(playerid, "WEAPON", "Kamu kehabisan amunisi");
		}

		if(--PlayerGuns[playerid][slot][weapon_durability] <= 0) {
			if(PlayerGuns[playerid][slot][weapon_ammo]) {
				SetPlayerArmedWeapon(playerid, 0);
				SendCustomMessage(playerid, "WEAPON", "Senjata "YELLOW"%s "WHITE"rusak, kamu dapat memperbaikinya dengan '/repairgun'.", ReturnWeaponName(weaponid));
			} else {
				SendCustomMessage(playerid, "WEAPON", "Senjata "YELLOW"%s "WHITE"rusak dan tidak mempunyai ammo lagi.", ReturnWeaponName(weaponid));
				ResetWeaponID(playerid, weaponid);
			}
		}
	}
	return 1;
}


hook OnPlayerScriptUpdate(playerid)
{
	if(SQL_IsCharacterLogged(playerid))
	{
		new
			weaponid;

		if((weaponid = GetWeapon(playerid)) != 0 && !eventJoin[playerid])
			PlayerTextDrawSetString(playerid, PlayerTextdraws[playerid][textdraw_ammo], sprintf("%s", (PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_ammo]) ? (sprintf("%d", PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_ammo])) : ("No Ammo")));
		else 
			PlayerTextDrawSetString(playerid, PlayerTextdraws[playerid][textdraw_ammo], "_");
	}

	return 1;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (PRESSED(KEY_FIRE) || PRESSED(KEY_HANDBRAKE))
	{
		new weaponid;

		if((weaponid = GetWeapon(playerid)) != 0 && (!PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_ammo] || !PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_durability])) {
			TogglePlayerControllable(playerid, 0);
			SetPlayerArmedWeapon(playerid, 0);
			TogglePlayerControllable(playerid, 1);
			SetCameraBehindPlayer(playerid);

			ShowPlayerFooter(playerid, "~y~~h~WARNING: ~w~Tidak ada amunisi di senjata ini atau senjata ini sudah rusak.", 1500, 1);
		}
	}

	return 1;
}


RemoveWeaponInSlot(playerid, slotid) 
{
    new
        arrWeapons[2][13];
        
    for (new i = 0; i < 13; i ++) {
        GetPlayerWeaponData(playerid, i, arrWeapons[0][i], arrWeapons[1][i]);
    }
    ResetPlayerWeapons(playerid);
    
    for (new i = 0; i < 13; i ++) if (i != slotid) {
        GivePlayerWeapon(playerid, arrWeapons[0][i], arrWeapons[1][i]);
    }
    return 1;
}

PlayerHasWeaponInSlot(playerid, weaponid) 
{
    if(PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_slot] == g_aWeaponSlots[weaponid]) {
        return 1;
    }
    return 0;
}

GivePlayerWeaponEx(playerid, weaponid, ammo = DEFAULT_AMMO, durability = WEAPON_DURABILITY) 
{
	if(!(0 < weaponid < 46))
		return 0;

	if(PlayerHasWeapon(playerid, weaponid))
		return 1;

	new query[255],
		slot = g_aWeaponSlots[weaponid];

	if(slot == 1 || slot == 10)
		ammo = durability = 1;

	PlayerGuns[playerid][slot][weapon_id] 			= weaponid;
	PlayerGuns[playerid][slot][weapon_ammo] 		= ammo;
	PlayerGuns[playerid][slot][weapon_slot] 		= slot;
	PlayerGuns[playerid][slot][weapon_durability] 	= durability;

	GivePlayerWeapon(playerid, weaponid, 999999);

	mysql_format(g_iHandle, query, sizeof(query), "INSERT INTO weapon_players VALUES ('%d', '%d', '%d', '%d', '%d', '%d') ON DUPLICATE KEY UPDATE ammo = %d, durability = %d, created = %d", GetPlayerSQLID(playerid), slot, weaponid, ammo, durability, gettime(), ammo, durability, gettime());
	mysql_tquery(g_iHandle, query);
	return 1;
}

SavePlayerWeapon(playerid) 
{
	for(new i = 1; i < MAX_WEAPON_SLOT; i++)
	{
		if(!PlayerGuns[playerid][i][weapon_id]) 
			continue;
		
		new query[255];
		mysql_format(g_iHandle, query, sizeof(query), "INSERT INTO weapon_players VALUES ('%d', '%d', '%d', '%d', '%d', '%d') ON DUPLICATE KEY UPDATE ammo = %d, durability = %d", GetPlayerSQLID(playerid), i, PlayerGuns[playerid][i][weapon_id], PlayerGuns[playerid][i][weapon_ammo], PlayerGuns[playerid][i][weapon_durability], gettime(), PlayerGuns[playerid][i][weapon_ammo], PlayerGuns[playerid][i][weapon_durability]);
		mysql_tquery(g_iHandle, query);
	}
	return 1;
}

ResetWeaponID(playerid, weaponid) 
{
	new slot = g_aWeaponSlots[weaponid];

    PlayerGuns[playerid][slot][weapon_id] = PlayerGuns[playerid][slot][weapon_ammo] = 0;
	PlayerGuns[playerid][slot][weapon_slot] = PlayerGuns[playerid][slot][weapon_durability] = 0;
	mysql_tquery(g_iHandle, sprintf("DELETE FROM `weapon_players` WHERE `slot` = '%d' AND `userid` = '%d';", slot, GetPlayerSQLID(playerid)));

	RemoveWeaponInSlot(playerid, slot);
	return 1;
}

ResetWeapons(playerid)
{
	ResetPlayerWeapons(playerid);

    for (new i = 0; i < MAX_WEAPON_SLOT; i ++) if(PlayerGuns[playerid][i][weapon_id]) {
        PlayerGuns[playerid][i][weapon_id] = PlayerGuns[playerid][i][weapon_ammo] = 0;
		PlayerGuns[playerid][i][weapon_slot] = PlayerGuns[playerid][i][weapon_durability] = 0;

    }
	mysql_tquery(g_iHandle, sprintf("DELETE FROM `weapon_players` WHERE `userid` = '%d';", GetPlayerSQLID(playerid)));
	return 1;
}

GetWeapon(playerid) 
{
    new weaponid = GetPlayerWeapon(playerid);

    if(1 < weaponid < 46 && PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_id] == weaponid)
        return weaponid;

    return 0;
}

ReturnWeaponCount(playerid) 
{
	new count;

	for (new i = 0; i < MAX_WEAPON_SLOT; i ++) if(PlayerGuns[playerid][i][weapon_id]) {
		count++;
    }
    return count;
}

PlayerHasWeapon(playerid, weaponid) 
{
    for (new i = 0; i < MAX_WEAPON_SLOT; i ++) if(PlayerGuns[playerid][i][weapon_id] == weaponid) {
        return 1;
    }
    return 0;
}

ReturnWeaponAmmo(playerid, weaponid)
{
	new slot = g_aWeaponSlots[weaponid];

	if(PlayerGuns[playerid][slot][weapon_id] != 0)
		return PlayerGuns[playerid][slot][weapon_ammo];

	return 0;
}

ReturnWeaponDurability(playerid, weaponid)
{
	new slot = g_aWeaponSlots[weaponid];
	
	if(PlayerGuns[playerid][slot][weapon_id] != 0)
		return PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_durability];

	return 0;
}

ReturnWeaponMaterial(weaponid)
{
	for(new i = 0; i < sizeof(g_aWeaponItems); i++) if(weaponid == g_aWeaponItems[i][wep_model]) {
		return g_aWeaponItems[i][wep_material];
	}
	return 0;
}

RefreshWeapon(playerid)
{
	ResetPlayerWeapons(playerid);

	for(new i = 1; i != MAX_WEAPON_SLOT; i++) if(PlayerGuns[playerid][i][weapon_id]) {
        GivePlayerWeapon(playerid, PlayerGuns[playerid][i][weapon_id], 999999);
    }
}

RefreshWeaponSlot(playerid, weaponid)
{
	if (weaponid < 0 || weaponid > 46)
		return 0;

	new slot = g_aWeaponSlots[weaponid];

	RemoveWeaponInSlot(playerid, slot);

	if(!PlayerGuns[playerid][slot][weapon_id])
		return 0;

    GivePlayerWeapon(playerid, PlayerGuns[playerid][slot][weapon_id], 999999);
    return 1;
}

ShowPlayerWeapon(playerid, userid)
{
	new
		weapon_list[128],
		count = 0;

	strcat(weapon_list, "Weapon\tAmmo\tDurability\n");
	for(new i = 1; i != MAX_WEAPON_SLOT; i++) if(PlayerGuns[playerid][i][weapon_id]) {
		strcat(weapon_list, sprintf("%s\t%s\t%s\n", ReturnWeaponName(PlayerGuns[playerid][i][weapon_id]), (i == 1) ? (" ") : sprintf("%d", PlayerGuns[playerid][i][weapon_ammo]), (i == 1) ? (" ") :  (sprintf("%d", PlayerGuns[playerid][i][weapon_durability]))));
		count++;
	}

	if(count) Dialog_Show(userid, ShowOnly, DIALOG_STYLE_TABLIST_HEADERS, "Weapons", weapon_list, "Close", "");
	else {
		strcat(weapon_list, "There is no weapon\t \t \n");
		Dialog_Show(userid, ShowOnly, DIALOG_STYLE_TABLIST_HEADERS, "Weapons", weapon_list, "Close", "");
	}
	return 1;
}

/* IsValidWeaponSlot(weaponid)
{
	if (g_aWeaponSlots[weaponid] == 7 || g_aWeaponSlots[weaponid] == 8)
		return 0;

	if (g_aWeaponSlots[weaponid] == 11 && weaponid != 46)
		return 0;

	return 1;
} */