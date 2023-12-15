CMD:ame(playerid, params[])
{
    //if(PlayerData[playerid][pHospital] != -1) return 0;

    new flyingtext[164];

    if(isnull(params))
        return SendSyntaxMessage(playerid, "/ame [action]");

    if(strlen(params) > 128)
        return SendErrorMessage(playerid, "Max action can only maximmum 128 characters.");

    if(strlen(params) > 64) {
        SendClientMessageEx(playerid, X11_PLUM, "* [AME]: %.64s ..", params);
        SendClientMessageEx(playerid, X11_PLUM, ".. %s", params[64]);
    }
    else {
        SendClientMessageEx(playerid, X11_PLUM, "* [AME]: %s", params);
    }
    format(flyingtext, sizeof(flyingtext), "* %s %s*", ReturnName(playerid, 0, 1), params);
    SetPlayerChatBubble(playerid, flyingtext, X11_PLUM, 10.0, 10000);

    return 1;
}