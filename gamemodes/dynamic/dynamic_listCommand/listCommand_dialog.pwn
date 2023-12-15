Dialog:handler_commandlist(playerid, response, listitem, inputtext[])
{
    if(response)
    {
        new get_type_command = GetTypeListCommand(inputtext);
        Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_MSGBOX, "List Command - Reliazed Roleplay", listCommand[get_type_command], "Accept", "Close");
    }
    return 1;
}