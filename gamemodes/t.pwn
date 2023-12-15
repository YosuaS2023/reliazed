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

#define Env: env_
#define CheckAdmin(%0,%1) admin[%0] < %1
new Env:data;
new admin[100];
CMD:pp(playerid)
{
    if(CheckAdmin(playerid, Env:data)) return 1;
}