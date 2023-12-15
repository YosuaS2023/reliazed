#include <YSI\y_hooks>
hook OnPlayerLogin(playerid)
{
    //Notifikasi
    PlayerTextdraws[playerid][textdraw_footer] = CreatePlayerTextDraw(playerid, 321.000000, 352.000793, "_");
    PlayerTextDrawLetterSize(playerid, PlayerTextdraws[playerid][textdraw_footer], 0.214499, 1.031875);
    PlayerTextDrawAlignment(playerid, PlayerTextdraws[playerid][textdraw_footer], 2);
    PlayerTextDrawColor(playerid, PlayerTextdraws[playerid][textdraw_footer], -1);
    PlayerTextDrawSetShadow(playerid, PlayerTextdraws[playerid][textdraw_footer], 0);
    PlayerTextDrawSetOutline(playerid, PlayerTextdraws[playerid][textdraw_footer], 1);
    PlayerTextDrawBackgroundColor(playerid, PlayerTextdraws[playerid][textdraw_footer], 255);
    PlayerTextDrawFont(playerid, PlayerTextdraws[playerid][textdraw_footer], 1);
    PlayerTextDrawSetProportional(playerid, PlayerTextdraws[playerid][textdraw_footer], 1);
    PlayerTextDrawSetShadow(playerid, PlayerTextdraws[playerid][textdraw_footer], 0);
    return 1;
}