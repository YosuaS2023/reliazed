CMD:createhouse(playerid, params[])
{
    static
        price,
        id,
        type,
        address[32];

    if (CheckAdmin(playerid, Env:house))
        return PermissionError(playerid);

    if(sscanf(params, "dds[32]", type, price, address))
    {
        SendSyntaxMessage(playerid, "/createhouse [interior type] [price] [house address]");

        static str[84];
        for (new i = 0; i < sizeof(arrHouseInteriors); i++)
        {
            format(str, sizeof(str), "%d: %s", i, arrHouseInteriors[i][eHouseDesc]);
            SendClientMessage(playerid, X11_GREY_80, str);
        }

        return 1;
    }

    if(type < 0 || type > 13) return SendErrorMessage(playerid, "The specified interior must be between 0 - 13.");
    if(price < 0) return SendErrorMessage(playerid, "Price can't under zero.");

    for (new i = 0; i != MAX_HOUSES; i ++) if(HouseData[i][houseExists] && !strcmp(HouseData[i][houseAddress], address, true)) {
        return SendErrorMessage(playerid, "The address \"%s\" is already in use (ID: %d).", address, i);
    }

    if((id = House_Create(playerid, price, address, type)) == -1) return SendErrorMessage(playerid, "The server has reached the limit for houses.");

    SendServerMessage(playerid, "You have successfully created house ID: %d.", id);
    return 1;
}

CMD:destroyhouse(playerid, params[])
{
    static
        id = 0;

    if (CheckAdmin(playerid, Env:house))
        return PermissionError(playerid);

    if(sscanf(params, "d", id))
        return SendSyntaxMessage(playerid, "/destroyhouse [house id]");

    if((id < 0 || id >= MAX_HOUSES) || !HouseData[id][houseExists])
        return SendErrorMessage(playerid, "You have specified an invalid house ID.");

    House_Delete(id);
    SendServerMessage(playerid, "You have successfully destroyed house ID: %d.", id);
    return 1;
}

CMD:edithouse(playerid, params[])
{
    static
        id,
        type[24],
        string[128];

    if (CheckAdmin(playerid, Env:house))
        return PermissionError(playerid);

    if(sscanf(params, "ds[24]S()[128]", id, type, string))
    {
        SendSyntaxMessage(playerid, "/edithouse [id] [name]");
        SendClientMessage(playerid, X11_YELLOW_2, "[NAMES]:"WHITE" location, intworld, interior, price, address, type, lock, resetstorage, parkslot");
        return 1;
    }
    if((id < 0 || id >= MAX_HOUSES) || !HouseData[id][houseExists])
        return SendErrorMessage(playerid, "You have specified an invalid house ID.");

    if(!strcmp(type, "location", true))
    {
        GetPlayerPos(playerid, HouseData[id][housePos][0], HouseData[id][housePos][1], HouseData[id][housePos][2]);
        GetPlayerFacingAngle(playerid, HouseData[id][housePos][3]);

        HouseData[id][houseExterior] = GetPlayerInterior(playerid);
        HouseData[id][houseExteriorVW] = GetPlayerVirtualWorld(playerid);

        House_Refresh(id);
        House_Save(id);

        SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has adjusted the location of house ID: %d.", ReturnName(playerid, 0), id);
    }
    else if(!strcmp(type, "intworld", true))
    {
        GetPlayerPos(playerid, HouseData[id][houseInt][0], HouseData[id][houseInt][1], HouseData[id][houseInt][2]);
        GetPlayerFacingAngle(playerid, HouseData[id][houseInt][3]);

        HouseData[id][houseInterior] = GetPlayerInterior(playerid);

        foreach (new i : Player)
        {
            if(PlayerData[i][pHouse] == HouseData[id][houseID])
            {
                SetPlayerPosEx(i, HouseData[id][houseInt][0], HouseData[id][houseInt][1], HouseData[id][houseInt][2]);
                SetPlayerFacingAngle(i, HouseData[id][houseInt][3]);

                SetPlayerInterior(i, HouseData[id][houseInterior]);
                SetCameraBehindPlayer(i);
            }
        }
        House_Save(id);
        SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has adjusted the interior spawn of house ID: %d.", ReturnName(playerid, 0), id);
    }
    else if(!strcmp(type, "parkslot", true))
    {
        new parkslot;

        if(sscanf(string, "d", parkslot))
            return SendSyntaxMessage(playerid, "/edithouse [id] [slot]");

        HouseData[id][houseParkingSlot] = parkslot;

        House_Refresh(id);
        House_Save(id);

        SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has adjusted the park slot of house ID: %d to %d.", ReturnName(playerid, 0), id, parkslot);
    }
    else if(!strcmp(type, "price", true))
    {
        new price;

        if(sscanf(string, "d", price))
            return SendSyntaxMessage(playerid, "/edithouse [id] [price] [new price]");

        HouseData[id][housePrice] = price;

        House_Refresh(id);
        House_Save(id);

        SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has adjusted the price of house ID: %d to %s.", ReturnName(playerid, 0), id, FormatMoney(price));
    }
    else if(!strcmp(type, "address", true))
    {
        new address[32];

        if(sscanf(string, "s[32]", address))
            return SendSyntaxMessage(playerid, "/edithouse [id] [address] [new address]");

        format(HouseData[id][houseAddress], 32, address);

        House_Refresh(id);
        House_Save(id);

        SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has adjusted the address of house ID: %d to \"%s\".", ReturnName(playerid, 0), id, address);
    }
    else if(!strcmp(type, "lock", true))
    {
        new lockid;

        if(sscanf(string, "d", lockid))
            return SendSyntaxMessage(playerid, "/edithouse [id] [lock] [0/1]");

        HouseData[id][houseLocked] = lockid;
        SendServerMessage(playerid, "You've %s this house.", HouseData[id][houseLocked] ? ("locked") : ("unlock"));
    }
    else if(!strcmp(type, "resetstorage", true))
    {
        House_RemoveAllItems(id);
        SendServerMessage(playerid, "You've reset house storage id %d.", id);
        Log_Save(E_LOG_RESET_STORAGE, sprintf("[%s] %s (%s) mereset storage rumah index %d.", ReturnDate(), ReturnAdminName(playerid), AccountData[playerid][uIP], id));
    }
    else if(!strcmp(type, "interior", true))
    {
        new typeint;

        if(sscanf(string, "d", typeint))
            return SendSyntaxMessage(playerid, "/edithouse [id] [interior] [interior: /goto houseint]");

        if(typeint < 0 || typeint > 13)
            return SendErrorMessage(playerid, "The specified interior must be between 0 - 13.");

        HouseData[id][houseInt][0] = arrHouseInteriors[typeint][eHouseX];
        HouseData[id][houseInt][1] = arrHouseInteriors[typeint][eHouseY];
        HouseData[id][houseInt][2] = arrHouseInteriors[typeint][eHouseZ];
        HouseData[id][houseInt][3] = arrHouseInteriors[typeint][eHouseAngle];
        HouseData[id][houseInterior] = arrHouseInteriors[typeint][eHouseInterior];

        foreach (new i : Player) if(PlayerData[i][pHouse] == HouseData[id][houseID])
        {
            SetPlayerPosEx(i, HouseData[id][houseInt][0], HouseData[id][houseInt][1], HouseData[id][houseInt][2]);
            SetPlayerFacingAngle(i, HouseData[id][houseInt][3]);

            SetPlayerInterior(i, HouseData[id][houseInterior]);
            SetCameraBehindPlayer(i);
        }
        House_Save(id);
        SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has adjusted the interior of house ID: %d to %d.", ReturnName(playerid, 0), id, typeint);
    }
    return 1;
}

CMD:housecmds(playerid, params[])
{
    SendClientMessage(playerid, COLOR_CLIENT, "HOUSES:"WHITE" /buy, /abandon, /lock, /storage, /furniture.");
    SendClientMessage(playerid, COLOR_CLIENT, "HOUSES:"WHITE" /doorbell, /switch.");
    return 1;
}

CMD:storage(playerid, params[])
{
    static
        houseid = -1;
    if((houseid = House_Inside(playerid)) != -1) 
    {
        if(House_IsOwner(playerid, houseid))
        {
            House_OpenStorage(playerid, houseid);
        }
        return 1;
    }
    SendErrorMessage(playerid, "You are not in range of your house interior.");
    return 1;
}

CMD:checkstorage(playerid, params[])
{
    if(CheckAdmin(playerid, Env:house) && GetFactionType(playerid) != FACTION_POLICE)
        return PermissionError(playerid);

    if(CheckAdmin(playerid, Env:house) && GetFactionType(playerid) == FACTION_POLICE && !IsPlayerDuty(playerid))
        return SendErrorMessage(playerid, "Duty terlebih dahulu!");

    static
        id = -1;

    if((id = House_Inside(playerid)) != -1) House_OpenStorage(playerid, id);
    /*else if((id = Business_Nearest(playerid)) != -1)
    {
        if(CheckAdmin(playerid, Env:house))
            return SendErrorMessage(playerid, "You are not in range of your house interior.");

        SendServerMessage(playerid, "Business money: "GREEN"%s.", FormatMoney(BusinessData[id][bizVault]));
    }*/
    else SendErrorMessage(playerid, "You are not in range of your house interior.");
    return 1;
}

CMD:nearesthouse(playerid, params[])
{
    if (CheckAdmin(playerid, 3))
        return PermissionError(playerid);

    new
        id = -1;

    if((id = House_Nearest(playerid)) != -1) SendServerMessage(playerid, "You are standing near house "YELLOW"ID: %d.", id);
    else SendServerMessage(playerid, "Kamu tidak berada didekat property apapun!");

    return 1;
}

CMD:unseal(playerid, params[])
{
    static id;
    if(GetFactionType(playerid) == FACTION_POLICE && PlayerData[playerid][pOnDuty])
    {
        if((id = House_Nearest(playerid)) != -1) if(HouseData[id][houseSeal])
        {
            HouseData[id][houseSeal] = 0;
            SendFactionMessageEx(FACTION_POLICE, COLOR_RADIO, "SEAL: %s have been unsealed this workshop.", ReturnName2(playerid,1));

            House_Refresh(id);
            House_Save(id);
        }
        else SendErrorMessage(playerid, "This house already to unseal");
    }
    return 1;
}
CMD:seal(playerid, params[])
{
    static id;
    if(GetFactionType(playerid) == FACTION_POLICE && PlayerData[playerid][pOnDuty])
    {
        if((id = House_Nearest(playerid)) != -1) if(!HouseData[id][houseSeal])
        {
            HouseData[id][houseSeal] = 1;
            SendFactionMessageEx(FACTION_POLICE, COLOR_RADIO, "SEAL: %s have been sealed this business.", ReturnName2(playerid,1));

            House_Refresh(id);
            House_Save(id);
        }        
    }
    return 1;
}

CMD:properties(playerid, params[])
{
    new count, string[1024], userid;

    if(sscanf(params, "u", userid)) {
        for (new i = 0; i < MAX_HOUSES; i ++) if(House_IsOwner(playerid, i, false)) {
            format(string,sizeof(string),"%sHouse ID: %d | Address: %s | Location: %s\n", string, i, HouseData[i][houseAddress], GetLocation(HouseData[i][housePos][0], HouseData[i][housePos][1], HouseData[i][housePos][2]));
            count++;
        }
        if(!count) SendErrorMessage(playerid, "You don't own any properties.");
        else Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_LIST, "Properties List", string, "Close", "");
        return 1;
    }

    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);

    if(userid == INVALID_PLAYER_ID) return SendErrorMessage(playerid, "Invalid Player ID!");

    if(!SQL_IsCharacterLogged(userid)) return SendErrorMessage(playerid, "Invalid player id.");

    for (new i = 0; i < MAX_HOUSES; i ++) if(House_IsOwner(userid, i, false)) {
        format(string,sizeof(string),"%sHouse ID: %d | Address: %s | Location: %s\n", string, i, HouseData[i][houseAddress], GetLocation(HouseData[i][housePos][0], HouseData[i][housePos][1], HouseData[i][housePos][2]));
        count++;
    }
    if(!count) SendErrorMessage(playerid, "This player don't own any properties.");
    else Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_LIST, sprintf("%s Properties", ReturnName(userid, 0)), string, "Close", "");
    return 1;
}