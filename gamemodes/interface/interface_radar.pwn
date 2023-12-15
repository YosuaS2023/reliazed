#include <ysi\y_hooks>
hook OnPlayerLogin(playerid)
{
    RadarBOX[playerid] = CreatePlayerTextDraw(playerid, 557.000000, 121.000000, "_");
    PlayerTextDrawFont(playerid, RadarBOX[playerid], 1);
    PlayerTextDrawLetterSize(playerid, RadarBOX[playerid], 0.600000, 5.899997);
    PlayerTextDrawTextSize(playerid, RadarBOX[playerid], 298.500000, 106.000000);
    PlayerTextDrawSetOutline(playerid, RadarBOX[playerid], 1);
    PlayerTextDrawSetShadow(playerid, RadarBOX[playerid], 0);
    PlayerTextDrawAlignment(playerid, RadarBOX[playerid], 2);
    PlayerTextDrawColor(playerid, RadarBOX[playerid], -1);
    PlayerTextDrawBackgroundColor(playerid, RadarBOX[playerid], 255);
    PlayerTextDrawBoxColor(playerid, RadarBOX[playerid], 100);
    PlayerTextDrawUseBox(playerid, RadarBOX[playerid], 1);
    PlayerTextDrawSetProportional(playerid, RadarBOX[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, RadarBOX[playerid], 0);

    SpeedRadarTD[playerid] = CreatePlayerTextDraw(playerid, 533.000000, 119.000000, "Speed Radar");
    PlayerTextDrawFont(playerid, SpeedRadarTD[playerid], 1);
    PlayerTextDrawLetterSize(playerid, SpeedRadarTD[playerid], 0.212500, 1.000000);
    PlayerTextDrawTextSize(playerid, SpeedRadarTD[playerid], 620.000000, 15.500000);
    PlayerTextDrawSetOutline(playerid, SpeedRadarTD[playerid], 1);
    PlayerTextDrawSetShadow(playerid, SpeedRadarTD[playerid], 0);
    PlayerTextDrawAlignment(playerid, SpeedRadarTD[playerid], 1);
    PlayerTextDrawColor(playerid, SpeedRadarTD[playerid], -1);
    PlayerTextDrawBackgroundColor(playerid, SpeedRadarTD[playerid], 255);
    PlayerTextDrawBoxColor(playerid, SpeedRadarTD[playerid], 50);
    PlayerTextDrawUseBox(playerid, SpeedRadarTD[playerid], 0);
    PlayerTextDrawSetProportional(playerid, SpeedRadarTD[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, SpeedRadarTD[playerid], 0);

    SpeedTextTD[playerid] = CreatePlayerTextDraw(playerid, 509.000000, 146.000000, "Speed");
    PlayerTextDrawFont(playerid, SpeedTextTD[playerid], 1);
    PlayerTextDrawLetterSize(playerid, SpeedTextTD[playerid], 0.225000, 1.100000);
    PlayerTextDrawTextSize(playerid, SpeedTextTD[playerid], 620.000000, 15.500000);
    PlayerTextDrawSetOutline(playerid, SpeedTextTD[playerid], 1);
    PlayerTextDrawSetShadow(playerid, SpeedTextTD[playerid], 0);
    PlayerTextDrawAlignment(playerid, SpeedTextTD[playerid], 1);
    PlayerTextDrawColor(playerid, SpeedTextTD[playerid], 16777215);
    PlayerTextDrawBackgroundColor(playerid, SpeedTextTD[playerid], 255);
    PlayerTextDrawBoxColor(playerid, SpeedTextTD[playerid], 50);
    PlayerTextDrawUseBox(playerid, SpeedTextTD[playerid], 0);
    PlayerTextDrawSetProportional(playerid, SpeedTextTD[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, SpeedTextTD[playerid], 0);

    ModelTextTD[playerid] = CreatePlayerTextDraw(playerid, 509.000000, 132.000000, "Model");
    PlayerTextDrawFont(playerid, ModelTextTD[playerid], 1);
    PlayerTextDrawLetterSize(playerid, ModelTextTD[playerid], 0.225000, 1.100000);
    PlayerTextDrawTextSize(playerid, ModelTextTD[playerid], 620.000000, 15.500000);
    PlayerTextDrawSetOutline(playerid, ModelTextTD[playerid], 1);
    PlayerTextDrawSetShadow(playerid, ModelTextTD[playerid], 0);
    PlayerTextDrawAlignment(playerid, ModelTextTD[playerid], 1);
    PlayerTextDrawColor(playerid, ModelTextTD[playerid], 16777215);
    PlayerTextDrawBackgroundColor(playerid, ModelTextTD[playerid], 255);
    PlayerTextDrawBoxColor(playerid, ModelTextTD[playerid], 50);
    PlayerTextDrawUseBox(playerid, ModelTextTD[playerid], 0);
    PlayerTextDrawSetProportional(playerid, ModelTextTD[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, ModelTextTD[playerid], 0);

    PlateTextTD[playerid] = CreatePlayerTextDraw(playerid, 509.500000, 161.000000, "Plate");
    PlayerTextDrawFont(playerid, PlateTextTD[playerid], 1);
    PlayerTextDrawLetterSize(playerid, PlateTextTD[playerid], 0.225000, 1.100000);
    PlayerTextDrawTextSize(playerid, PlateTextTD[playerid], 620.000000, 15.500000);
    PlayerTextDrawSetOutline(playerid, PlateTextTD[playerid], 1);
    PlayerTextDrawSetShadow(playerid, PlateTextTD[playerid], 0);
    PlayerTextDrawAlignment(playerid, PlateTextTD[playerid], 1);
    PlayerTextDrawColor(playerid, PlateTextTD[playerid], 16777215);
    PlayerTextDrawBackgroundColor(playerid, PlateTextTD[playerid], 255);
    PlayerTextDrawBoxColor(playerid, PlateTextTD[playerid], 50);
    PlayerTextDrawUseBox(playerid, PlateTextTD[playerid], 0);
    PlayerTextDrawSetProportional(playerid, PlateTextTD[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, PlateTextTD[playerid], 0);

    SeparatorTD[playerid] = CreatePlayerTextDraw(playerid, 538.000000, 127.000000, ":~n~:~n~:");
    PlayerTextDrawFont(playerid, SeparatorTD[playerid], 1);
    PlayerTextDrawLetterSize(playerid, SeparatorTD[playerid], 0.316666, 1.650002);
    PlayerTextDrawTextSize(playerid, SeparatorTD[playerid], 620.000000, 15.500000);
    PlayerTextDrawSetOutline(playerid, SeparatorTD[playerid], 1);
    PlayerTextDrawSetShadow(playerid, SeparatorTD[playerid], 0);
    PlayerTextDrawAlignment(playerid, SeparatorTD[playerid], 1);
    PlayerTextDrawColor(playerid, SeparatorTD[playerid], -1);
    PlayerTextDrawBackgroundColor(playerid, SeparatorTD[playerid], 255);
    PlayerTextDrawBoxColor(playerid, SeparatorTD[playerid], 50);
    PlayerTextDrawUseBox(playerid, SeparatorTD[playerid], 0);
    PlayerTextDrawSetProportional(playerid, SeparatorTD[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, SeparatorTD[playerid], 0);

    ModelTD[playerid] = CreatePlayerTextDraw(playerid, 548.000000, 132.000000, "N/A");
    PlayerTextDrawFont(playerid, ModelTD[playerid], 1);
    PlayerTextDrawLetterSize(playerid, ModelTD[playerid], 0.204165, 0.949998);
    PlayerTextDrawTextSize(playerid, ModelTD[playerid], 614.500000, 17.000000);
    PlayerTextDrawSetOutline(playerid, ModelTD[playerid], 1);
    PlayerTextDrawSetShadow(playerid, ModelTD[playerid], 0);
    PlayerTextDrawAlignment(playerid, ModelTD[playerid], 1);
    PlayerTextDrawColor(playerid, ModelTD[playerid], -1);
    PlayerTextDrawBackgroundColor(playerid, ModelTD[playerid], 255);
    PlayerTextDrawBoxColor(playerid, ModelTD[playerid], 50);
    PlayerTextDrawUseBox(playerid, ModelTD[playerid], 0);
    PlayerTextDrawSetProportional(playerid, ModelTD[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, ModelTD[playerid], 0);

    SpeedTD[playerid] = CreatePlayerTextDraw(playerid, 548.000000, 147.000000, "N/A");
    PlayerTextDrawFont(playerid, SpeedTD[playerid], 1);
    PlayerTextDrawLetterSize(playerid, SpeedTD[playerid], 0.204165, 0.949998);
    PlayerTextDrawTextSize(playerid, SpeedTD[playerid], 614.500000, 17.000000);
    PlayerTextDrawSetOutline(playerid, SpeedTD[playerid], 1);
    PlayerTextDrawSetShadow(playerid, SpeedTD[playerid], 0);
    PlayerTextDrawAlignment(playerid, SpeedTD[playerid], 1);
    PlayerTextDrawColor(playerid, SpeedTD[playerid], -1);
    PlayerTextDrawBackgroundColor(playerid, SpeedTD[playerid], 255);
    PlayerTextDrawBoxColor(playerid, SpeedTD[playerid], 50);
    PlayerTextDrawUseBox(playerid, SpeedTD[playerid], 0);
    PlayerTextDrawSetProportional(playerid, SpeedTD[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, SpeedTD[playerid], 0);

    PlateTD[playerid] = CreatePlayerTextDraw(playerid, 548.000000, 162.000000, "N/A");
    PlayerTextDrawFont(playerid, PlateTD[playerid], 1);
    PlayerTextDrawLetterSize(playerid, PlateTD[playerid], 0.204165, 0.949998);
    PlayerTextDrawTextSize(playerid, PlateTD[playerid], 614.500000, 17.000000);
    PlayerTextDrawSetOutline(playerid, PlateTD[playerid], 1);
    PlayerTextDrawSetShadow(playerid, PlateTD[playerid], 0);
    PlayerTextDrawAlignment(playerid, PlateTD[playerid], 1);
    PlayerTextDrawColor(playerid, PlateTD[playerid], -1);
    PlayerTextDrawBackgroundColor(playerid, PlateTD[playerid], 255);
    PlayerTextDrawBoxColor(playerid, PlateTD[playerid], 50);
    PlayerTextDrawUseBox(playerid, PlateTD[playerid], 0);
    PlayerTextDrawSetProportional(playerid, PlateTD[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, PlateTD[playerid], 0);
    return 1;
}


EnableSpeedRadar(playerid)
{
    PlayerTextDrawShow(playerid, RadarBOX[playerid]);
    PlayerTextDrawShow(playerid, SpeedRadarTD[playerid]);
    PlayerTextDrawShow(playerid, SpeedTextTD[playerid]);
    PlayerTextDrawShow(playerid, ModelTextTD[playerid]);
    PlayerTextDrawShow(playerid, PlateTextTD[playerid]);
    PlayerTextDrawShow(playerid, SeparatorTD[playerid]);
    PlayerTextDrawShow(playerid, ModelTD[playerid]);
    PlayerTextDrawShow(playerid, SpeedTD[playerid]);
    PlayerTextDrawShow(playerid, PlateTD[playerid]);
    Player_RadarToggle[playerid] = true;
    return 1;
}

DisableSpeedRadar(playerid)
{
    PlayerTextDrawHide(playerid, RadarBOX[playerid]);
    PlayerTextDrawHide(playerid, SpeedRadarTD[playerid]);
    PlayerTextDrawHide(playerid, SpeedTextTD[playerid]);
    PlayerTextDrawHide(playerid, ModelTextTD[playerid]);
    PlayerTextDrawHide(playerid, PlateTextTD[playerid]);
    PlayerTextDrawHide(playerid, SeparatorTD[playerid]);
    PlayerTextDrawHide(playerid, ModelTD[playerid]);
    PlayerTextDrawHide(playerid, SpeedTD[playerid]);
    PlayerTextDrawHide(playerid, PlateTD[playerid]);
    Player_RadarToggle[playerid] = false;
    return 1;
}