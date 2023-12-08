#include <a_samp>
#include <zcmd>
#include <sky>
new Text: Text_Global[1];
public OnPlayerConnect(playerid)
{

Text_Global[0] = TextDrawCreate(213.000, 246.000, "$1000");
TextDrawLetterSize(Text_Global[0], 0.300, 1.500);
TextDrawAlignment(Text_Global[0], 1);
TextDrawColor(Text_Global[0], -256);
TextDrawSetShadow(Text_Global[0], 1);
TextDrawSetOutline(Text_Global[0], 1);
TextDrawBackgroundColor(Text_Global[0], 0);
TextDrawFont(Text_Global[0], 3);
TextDrawSetProportional(Text_Global[0], 1);
TextDrawShowForPlayer(playerid, Text_Global[0]);
}
new timer;
CMD:show(p)
{
    timer = SetTimerEx("timerr", 20, true, "i", p);
    return 1;
}
new color_old = -256;
new Float:old_x, Float:old_y, Float:new_x, Float:new_y;
public timerr(p)
{
    if(color_old == -1) return SendClientMessage(p, -1, "max");
    old_x = 213.000;
    old_y = 246.000;
    new_x += old_x+0.6;
    color_old += 20;
    TextDrawColor(Text_Global[0], color_old);
    TextDrawSetPosition(Text_Global[0], new_x, old_y);
    TextDrawShowForPlayer(p, Text_Global[0]);
    SendClientMessage(p, -1, "low");
}

public hide(p)
{
    if(color_old == -256) return SendClientMessage(p, -1, "max");
    {
        SetTimerEx("hide", 1, true, "i", p);
    }
    color_old -= 1;
    TextDrawColor(Text_Global[0], color_old);
    TextDrawShowForPlayer(p, Text_Global[0]);
    SendClientMessage(p, -1, "low");
}