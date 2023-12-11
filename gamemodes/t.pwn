#include <a_samp>
#include <zcmd>
public OnPlayerSpawn(playerid)
{
    PlayerPlaySound(playerid, 5453, 0.0,0.0,0.0);
    return 1;
}

CMD:p(playerid)
{
    new Float:x ,Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    PlayerPlaySound(playerid, 5453, x,y,z);
}