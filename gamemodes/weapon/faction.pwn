#include <YSI\y_hooks>

// Local function
hook OnPlayerDisconnectEx(playerid)
{
	if(IsPlayerDuty(playerid))
		SaveFactionWeapon(playerid);
	
	return 1;
}

// Callback
GiveFactionWeapon(playerid, weaponid, ammo) 
{
	if(!IsPlayerDuty(playerid))
		return 0;

	if(!(0 <= weaponid <= 46))
		return 0;

	new query[255];

	GivePlayerWeapon(playerid, weaponid, ammo);
	mysql_format(sqlcon, query, sizeof(query), "INSERT INTO `weapon_factions` VALUES ('%d', '%d', '%d', '%d') ON DUPLICATE KEY UPDATE ammo = %d, weaponid = %d", GetPlayerSQLID(playerid), weaponid, ammo, g_aWeaponSlots[weaponid], ammo, weaponid);
	mysql_tquery(sqlcon, query);
	return 1;
}

SaveFactionWeapon(playerid)
{
	if(!IsPlayerDuty(playerid))
		return 0;

	new weaponid, ammo;

	for(new i = 1; i < MAX_WEAPON_SLOT; i++) {
		GetPlayerWeaponData(playerid, i, weaponid, ammo);

		if(!weaponid) 
			continue;
		new query[255];

		mysql_format(sqlcon, query, sizeof(query), "INSERT INTO weapon_factions VALUES ('%d', '%d', '%d', '%d') ON DUPLICATE KEY UPDATE ammo = %d", GetPlayerSQLID(playerid), weaponid, ammo, i, ammo);
		mysql_tquery(sqlcon, query);
	}
	return 1;
}

ResetFactionWeapon(playerid) 
{
	if(!IsPlayerDuty(playerid))
		return 0;

	ResetPlayerWeapons(playerid);
	mysql_tquery(sqlcon, sprintf("DELETE FROM weapon_factions WHERE `userid` = '%d'", GetPlayerSQLID(playerid)));
	return 1;
}

RefreshFactionWeapon(playerid)
{
	if(!IsPlayerDuty(playerid))
		return 0;

	ResetPlayerWeapons(playerid);

	mysql_tquery(sqlcon, sprintf("SELECT * FROM `weapon_factions` WHERE `userid` = '%d';", GetPlayerSQLID(playerid)), "OnLoadPlayerFacWeapons", "d", playerid);
	return 1;
}

/*IsFactionWeaponInSlot(playerid, weaponid) {
	for(new i = 1; i < MAX_WEAPON_SLOT; i++) {
		GetPlayerWeaponData(playerid, i, weaponid, ammo);

		if(i == g_aWeaponSlots[weaponid])
			return 1;
	}
	return 0;
}*/

// Funtion
function OnLoadPlayerFacWeapons(playerid)
{
	new weaponid, ammo;

	ResetPlayerWeapons(playerid);
	for(new i = 0; i < cache_num_rows(); i++)
	{
	    cache_get_value_int(i, "weaponid", weaponid);
	    cache_get_value_int(i, "ammo", ammo);
		
		if(!(0 <= weaponid <= 46))
			continue;

		GivePlayerWeapon(playerid, weaponid, ammo);
	}
	SetPlayerArmedWeapon(playerid, 0);
	return 1;
}