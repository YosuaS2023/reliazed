/* ===================================================================
 *                        Script Information:
 *
 * Name: Base Roleplay Script v0.1
 * Created by: 

 * Thanks to:
 * SAMP Team
 * pBlueG for mysql
 * samp-incognito for streamer
 * Y_Less for YSI
 * SouthClaws for chrono
 * Zeek for crashdetect
 * ===================================================================
**/
// Configuration
// ATM Robbery Config

#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 500

#include <a_mysql> 
#include <GPS>
#include <samp\samp_zona>
#include <streamer>                 //by Incognito
#include <EVF>
#include <Dini>
#include <chalk>
#include <sscanf2>                  //by Y_Less fixed by maddinat0r & Emmet_
#include <chrono>                   //by Southclaws
#include <Southclaws\json>
#include <Southclaws\WeaponData>
#include <easyDialog>
#include <Pawn.CMD.inc>
#include <crashdetect>
#include <filemanager>
#include <strlib>                   //by Slice
#include <YSI\y_timers>             //by Y_Less from YSI
#include <YSI\y_colours>            //by Y_Less from YSI
#include <YSI\y_vehicledata>
#include <eSelection>
#include <MemoryPluginVersion>

#define DEVELOPER "Suzy"
//==========[ MODULAR ]==========
forward OnGameModeInitEx();
forward OnPlayerLogin(playerid);
forward OnPlayerDisconnectEx(playerid, reason);
#define GPS_MODE_ALL
#include "./core/utils.pwn"
#include "./core/systems.pwn"
#include "./core/timers.pwn"
#include "../main/define.pwn"
#include "../main/enum.pwn"
#include "../main/enum_variable.pwn"
#include "../main/macros.pwn"
#include "../main/color.pwn"
#include "../main/mysql.pwn"
#include "../main/sscanf.pwn"
/*
#include "./route/core.pwn"
#include "./route/function.pwn"
#include "./route/callback.pwn"*/

#include "./server_management/server.pwn"
// core
#include "./admin/core.pwn"
#include "./inventory/core.pwn"
#include "./economy/core.pwn"
#include "./admin/admin_developer/core.pwn"
#include "./weapon/core.pwn"
//#include "./vehicle/core.pwn"

#include "./core/interface.pwn"
#include "./ptask_function/ptask_function_stats.pwn"
#include "../main/func.pwn"
#include "../main/dialog.pwn"
#include "../main/timer.pwn"
//===============================
/* Gamemode Start! */
#include "./ucp_system/function.pwn"
#include "./ucp_system/timer.pwn"

#include "./command/list.pwn"

#include "./economy/funcs.pwn"
#include "./economy/cmds.pwn"
#include "./economy/hooks.pwn"

#include "./admin/admin_activities.pwn"
#include "./admin/admin_duty_times.pwn"
#include "./admin/admin_developer/function.pwn"
#include "./admin/callbacks.pwn"
#include "./admin/cmd.pwn"
#include "./admin/hidden_command.pwn"

#include "./server/salary.pwn"
#include "./core/dynamic.pwn"

#include "./vehicle/function.pwn"
#include "./vehicle/object.pwn"
#include "./vehicle/weapon.pwn"
#include "./vehicle/cmd.pwn"


// vehicle private
//#include "./vehicle/function.pwn"

#include "./inventory/function.pwn"
#include "./inventory/callback.pwn"
#include "./weapon/faction.pwn"
#include "./weapon/cmd.pwn"
main()
{
    print("\n----------------------------------------");
    print(" Gamemode Ucp versi 0.1 register dan login");
    print("----------------------------------------\n");
}

public OnGameModeInit()
{
	#if defined DEBUG_MODE
        printf("[debug] OnGameModeInit()");
	#endif

    print("[OnGameModeInit] Initialising 'Main'...");
	mysql_tquery(sqlcon, "SELECT * FROM `factions`", "Faction_Load", "");
	mysql_tquery(sqlcon, "SELECT * FROM `factionvehicle`", "FactionVehicle_Load", "");
    OnGameModeInit_Setup();
    #if defined main_OnGameModeInit
        return main_OnGameModeInit();
    #else
        return 1;
    #endif
}
#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit main_OnGameModeInit
#if defined main_OnGameModeInit
    forward main_OnGameModeInit();
#endif

OnGameModeInit_Setup()
{
    //Server configuration
    MySqlStartConnection();
    ManualVehicleEngineAndLights();
    Streamer_ToggleErrorCallback(1);
    SetGameModeText(SERVER_REVISION);

    CallLocalFunction("OnGameModeInitEx", "");
    return 1;
}

public OnGameModeExit()
{
    foreach(new playerid : Player)
        TerminateConnection(playerid);
	MySqlCloseConnection();
	return 1;
}

public OnPlayerConnect(playerid)
{
	g_RaceCheck{playerid} ++;
    ResetStatistics(playerid);
    SetPlayerColor(playerid, DEFAULT_COLOR);
	GetPlayerName(playerid, ReturnName(playerid), MAX_PLAYER_NAME + 1);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	SQL_SaveAccounts(playerid);
    TerminateConnection(playerid);
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
    CallLocalFunction("OnPlayerDisconnectEx", "ii", playerid, reason);
	return 1;
}

static SetDefaultSpawn(playerid)
{
    SendClientMessageEx(playerid, COLOR_WHITE,"---------------------------------------------------------------------------------------------------------------");
    SendClientMessageEx(playerid, COLOR_WHITE,"Selamat datang "YELLOW"%s"WHITE", anda telah landing dan sekarang berada di Bandara Los Santos International .", ReturnName(playerid,0));
    SendClientMessageEx(playerid, COLOR_WHITE,"---------------------------------------------------------------------------------------------------------------");

    SetPlayerPosEx(playerid, 1682.4869,-2330.1724,13.5469);
    SetPlayerFacingAngle(playerid, 359.7332);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    return 1;
}
static SetCameraData(playerid)
{
    TogglePlayerSpectating(playerid, 1);
    switch(random(1))
    {
        case 0:
        {
            InterpolateCameraPos(playerid, 1964.020629, -1746.168457, 21.459442, 1970.416503, -1819.768920, 22.540792, 8000);
            InterpolateCameraLookAt(playerid, 1960.333129, -1749.514892, 21.008031, 1966.392456, -1816.848754, 22.012056, 8000);
        }
        case 1:
        {
            InterpolateCameraPos(playerid, 1964.020629, -1746.168457, 21.459442, 1970.416503, -1819.768920, 22.540792, 8000);
            InterpolateCameraLookAt(playerid, 1960.333129, -1749.514892, 21.008031, 1966.392456, -1816.848754, 22.012056, 8000);
        }
    }
    return 1;
}
public OnPlayerRequestClass(playerid, classid)
{
    if(IsValidRoleplayName(ReturnName(playerid)))
    {
        SendErrorMessage(playerid, "Format Nama tidak sesuai.");
        SendErrorMessage(playerid, "Gunakan nama dengan format nama biasa.");
        SendErrorMessage(playerid, "Sebagai contoh, Suzy, Zuan, Oxy.");
        KickEx(playerid);
    }
    if(!PlayerData[playerid][pKicked])
    {
        SetCameraData(playerid);
        SQL_CheckAccount(playerid);
        SetPlayerColor(playerid, DEFAULT_COLOR);
    }
    return 1;
}
public OnPlayerRequestSpawn(playerid)
{
    if (AccountData[playerid][uLogged] == 0)
    {
        KickEx(playerid);
        return 0;
    }
    return 1;
}

public OnPlayerSpawn(playerid)
{
	#if defined DEBUG_MODE
	    printf("[debug] OnPlayerSpawn(PID : %d)", playerid);
	#endif
    SetPlayerScore(playerid, PlayerData[playerid][pScore]);
    Streamer_ToggleIdleUpdate(playerid, true);

    if(!PlayerData[playerid][pCreated])
    {
        for (new i = 0; i < 20; i ++) {
            SendClientMessage(playerid , -1, "");
        }
        PlayerData[playerid][pSkin] = 98;
        SetPlayerSkinEx(playerid, 98);

        PlayerData[playerid][pOrigin][0] = '\0';
        PlayerData[playerid][pBirthdate][0] = '\0';

        SetPlayerPos(playerid, 258.0770, -42.3550, 1002.0234);
        SetPlayerFacingAngle(playerid,45.5218);
        SetPlayerInterior(playerid, 14);
        SetPlayerVirtualWorld(playerid, (playerid+3));
        SetPlayerCameraPos(playerid,255.014175,-39.542194,1002.023437);
        SetPlayerCameraLookAt(playerid,257.987945,-42.462291,1002.023437);
    }
    else
    {
        SetPlayerFacingAngle(playerid, PlayerData[playerid][pPos][3]);

        SetPlayerInterior(playerid, PlayerData[playerid][pInterior]);
        SetPlayerVirtualWorld(playerid, PlayerData[playerid][pWorld]);
    }
	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
    return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleSirenStateChange(playerid, vehicleid, newstate)
{
    return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{

    return 1;
}
public OnModelSelectionResponse(playerid, extraid, index, modelid, response)
{
	if ((response) && (extraid == MODEL_SELECTION_ADD_SKIN))
	{
	    FactionData[PlayerData[playerid][pFactionEdit]][factionSkins][PlayerData[playerid][pSelectedSlot]] = modelid;
		Faction_Save(PlayerData[playerid][pFactionEdit]);

		SendServerMessage(playerid, "You have set the skin ID in slot %d to %d.", PlayerData[playerid][pSelectedSlot], modelid);
	}
    if ((response) && (extraid == MODEL_SELECTION_FACTION_SKIN))
	{
	    new factionid = PlayerData[playerid][pFaction];

		if (factionid == -1 || !IsNearFactionLocker(playerid))
	    	return 0;

		if (modelid == 19300)
		    return SendErrorMessage(playerid, "There is no model in the selected slot.");

  		SetFactionSkin(playerid, modelid);
		SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s has changed their uniform.", ReturnName(playerid));
	}
	if ((response) && (extraid == MODEL_SELECTION_FACTION_SKINS))
	{
	    ShowPlayerDialog(playerid, DIALOG_EDITLOCKER_SKIN, DIALOG_STYLE_LIST, "Edit Skin", "Add by Model ID\nAdd by Thumbnail\nClear Slot", "Select", "Cancel");
	    PlayerData[playerid][pSelectedSlot] = index;
	}
	if((response) && (extraid == MODEL_SELECTION_SKIN))
    {
        for (new i = 0; i < 50; i ++) {
            SendClientMessage(playerid, -1, "");
        }

        PlayerData[playerid][pSkin] = modelid;
        PlayerData[playerid][pScore] = 1;
        PlayerData[playerid][pCreated] = 1;
        PlayerData[playerid][pHour] = 0;
        PlayerData[playerid][pMinute] = 0;
        PlayerData[playerid][pSecond] = 0;
        PlayerData[playerid][pLogged] = 1;
        SetHealth(playerid, 100);

        PlayerData[playerid][pRegisterDate] = gettime();
        mysql_tquery(sqlcon, sprintf("UPDATE `ucp_characters` SET `RegisterDate`='%d' WHERE `ID`='%d';", PlayerData[playerid][pRegisterDate], PlayerData[playerid][pID]));

        SetPlayerSkinEx(playerid, modelid);
        TogglePlayerSpectating(playerid, false);

        SetDefaultSpawn(playerid);
        SQL_SaveAccounts(playerid);

        SetPlayerScore(playerid,PlayerData[playerid][pScore]);

        TogglePlayerControllable(playerid, 0);
    }
	return 1;
}
public OnPlayerText(playerid, text[])
{
	SendNearbyMessage(playerid, 15.0, COLOR_WHITE, "%s:  %s", ReturnName(playerid, 0), text);
    return 0;
}