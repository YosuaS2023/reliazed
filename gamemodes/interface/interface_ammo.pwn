#include <ysi\y_hooks>
hook OnPlayerLogin(playerid)
{
    PlayerTextdraws[playerid][textdraw_ammo] = CreatePlayerTextDraw(playerid, 520.633239, 62.733345, "_");
    PlayerTextDrawLetterSize(playerid, PlayerTextdraws[playerid][textdraw_ammo], 0.278001, 1.200000);
    PlayerTextDrawAlignment(playerid, PlayerTextdraws[playerid][textdraw_ammo], 2);
    PlayerTextDrawColor(playerid, PlayerTextdraws[playerid][textdraw_ammo], -1378294017);
    PlayerTextDrawSetShadow(playerid, PlayerTextdraws[playerid][textdraw_ammo], 0);
    PlayerTextDrawSetOutline(playerid, PlayerTextdraws[playerid][textdraw_ammo], 1);
    PlayerTextDrawBackgroundColor(playerid, PlayerTextdraws[playerid][textdraw_ammo], 255);
    PlayerTextDrawFont(playerid, PlayerTextdraws[playerid][textdraw_ammo], 3);
    PlayerTextDrawSetProportional(playerid, PlayerTextdraws[playerid][textdraw_ammo], 1);
    PlayerTextDrawSetShadow(playerid, PlayerTextdraws[playerid][textdraw_ammo], 0);

    return 1;
}