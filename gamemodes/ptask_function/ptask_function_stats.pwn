#include <YSI\y_hooks>

timer PlayerStats[1000](playerid)
{
	if(PlayerData[playerid][pLogged] == 1)
	{
		if(PlayerData[playerid][pPaycheck] > 3600)
		{
			PlayerData[playerid][pPaycheck] = 0;
		}
		if(PlayerData[playerid][pPaycheck] > 0)
		{
			PlayerData[playerid][pPaycheck]--;
			if(PlayerData[playerid][pPaycheck] <= 0)
			{
				SendServerMessage(playerid, "Kamu sudah bisa mengambil Paycheck sekarang!");
				PlayerData[playerid][pPaycheck] = 0;
			}
		}
        if(IsPlayerDeveloper(playerid) == DEVELOPER_GAMEMODE)
        {
            SendCustomMessage(playerid, "DEBUG", "Variable player 'pPaycheck': %i", PlayerData[playerid][pPaycheck]);
        }
	}
}

hook OnPlayerLogin(playerid)
{
    PlayerData[playerid][pPtask_Stats] = repeat PlayerStats(playerid);
    return 1;
}

hook OnPlayerDisconnectEx(playerid, reason)
{
   stop PlayerData[playerid][pPtask_Stats];
}