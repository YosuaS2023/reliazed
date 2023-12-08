#include <a_samp>
#include <gps>
#include <PlayerZone>

#define GPS_MODE_ALL

#include "./route/core.pwn"
public OnPlayerDisconnect(playerid){return 1;}
public OnPlayerConnect(playerid){

return 1;}
public OnPlayerRequestClass(playerid, classid)
{

	TogglePlayerSpectating(playerid, true);
	InterpolateCameraPos(playerid, 1791.130737, -1570.935546, 209.488677, 1791.130737, -1570.935546, 209.488677, 4000);
 	InterpolateCameraLookAt(playerid, 1787.104736, -1567.996215, 209.098770, 1787.104736, -1567.996215, 209.098770, 4000);
    return 1;
}
/*
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    GPS_SetPlayerCheckpoint(playerid, fX,fY,fZ);
    return 1;
}*/