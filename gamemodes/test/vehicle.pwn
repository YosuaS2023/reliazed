CMD:approve(playerid, params[])
{
    if(isnull(params))
    {
        SendSyntaxMessage(playerid, "/approve [name]");
        SendClientMessage(playerid, X11_YELLOW_2, "[NAMES]:"WHITE" house, business, workshop, car, vending, apartment");
        SendClientMessage(playerid, X11_YELLOW_2, "[NAMES]:"WHITE" food, faction, greet, frisk, body, stnk, inspect");
        return 1;
    }
    if(!strcmp(params, "car", true) && PlayerData[playerid][pCarSeller] != INVALID_PLAYER_ID)
    {
        new
            sellerid = PlayerData[playerid][pCarSeller],
            vehicleid = PlayerData[playerid][pCarOffered],
            price = PlayerData[playerid][pCarValue],
            housevehicleslot = House_CountVehicleSlot(playerid);

        if(GetPlayerVIPLevel(playerid) > 2)
        {
            
            if(Vehicle_PlayerTotalCount(playerid) >= MAX_VIP_VEHICLES+housevehicleslot)
                return SendErrorMessage(playerid, "Kendaraanmu sudah mencapai batas maksimal.");
        }
        else
        {
            if(Vehicle_PlayerTotalCount(playerid) >= MAX_PLAYER_VEHICLES+housevehicleslot)
                return SendErrorMessage(playerid, "Kendaraanmu sudah mencapai batas maksimal.");
        }

        if(!IsPlayerNearPlayer(playerid, sellerid, 5.0))
            return SendErrorMessage(playerid, "Kamu tidak dekat dengan player yang menjual kendaraan!.");

        if(GetMoney(playerid) < price)
            return SendErrorMessage(playerid, "Uang tidak mencukupi!.");

        if(Vehicle_Nearest(playerid, 5) != VehicleData[vehicleid][vehVehicleID])
            return SendErrorMessage(playerid, "Harus dekat dengan kendaraan yang dijual.");

        if(!Vehicle_IsOwned(sellerid, vehicleid))
            return SendErrorMessage(playerid, "This vehicle offer is no longer valid.");

        GiveMoney(playerid, -price);
        GiveMoney(sellerid, price);

        SendServerMessage(playerid, "Sukses membeli kendaraan "CYAN"%s "WHITE"milik "YELLOW"%s "WHITE"seharga "GREEN"%s.", GetVehicleNameByModel(VehicleData[vehicleid][vehModel]), ReturnName(sellerid, 0), FormatNumber(price));
        SendServerMessage(sellerid, ""YELLOW"%s "WHITE"sukses membeli "CYAN"%s "WHITE"milikmu seharga "GREEN"%s.", ReturnName(playerid, 0), GetVehicleNameByModel(VehicleData[vehicleid][vehModel]), FormatNumber(price));

        Iter_Remove(OwnedVehicles<sellerid>, vehicleid);
        Vehicle_SetOwner(playerid, vehicleid);
        Vehicle_ExecuteInt(vehicleid, "extraid", GetPlayerSQLID(playerid));

        Log_Save(E_LOG_OFFER_VEH, sprintf("[%s] %s (%s) has sold a %s to %s (%s) for %s.", ReturnDate(), ReturnName(sellerid, 0), AccountData[sellerid][pIP], GetVehicleNameByModel(VehicleData[vehicleid][vehModel]), ReturnName(playerid, 0), AccountData[playerid][pIP], FormatNumber(price)));

        PlayerData[playerid][pCarSeller] = INVALID_PLAYER_ID;
        PlayerData[playerid][pCarOffered] = -1;
        PlayerData[playerid][pCarValue] = 0;
    }
    if(!strcmp(params, "house", true) && PlayerData[playerid][pHouseSeller] != INVALID_PLAYER_ID)
    {
        new
            sellerid = PlayerData[playerid][pHouseSeller],
            houseid = PlayerData[playerid][pHouseOffered],
            price = PlayerData[playerid][pHouseValue];

        if(!IsPlayerNearPlayer(playerid, sellerid, 6.0))
            return SendErrorMessage(playerid, "You are not near that player.");

        if(GetMoney(playerid) < price)
            return SendErrorMessage(playerid, "You have insufficient funds to purchase this house.");

        if(House_Nearest(playerid) != houseid)
            return SendErrorMessage(playerid, "You must be near the house to purchase it.");

        if(!House_IsOwner(sellerid, houseid, false))
            return SendErrorMessage(playerid, "This house offer is no longer valid.");

        SendServerMessage(playerid, "You have successfully purchased %s's house for %s.", ReturnName(sellerid, 0), FormatNumber(price));
        SendServerMessage(sellerid, "%s has successfully purchased your house for %s.", ReturnName(playerid, 0), FormatNumber(price));

        // mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET `house_parking`='-1',`state`='%d' WHERE `house_parking`='%d';", VEHICLE_STATE_SPAWNED , HouseData[houseid][houseID]));
        // Vehicle_PlayerLoad(sellerid);

        format(HouseData[houseid][houseOwnerName], MAX_PLAYER_NAME, NormalName(playerid));
        HouseData[houseid][houseOwner] = GetPlayerSQLID(playerid);
        HouseData[houseid][houseLastVisited] = gettime();

        House_Save(houseid);
        House_Refresh(houseid);

        GiveMoney(playerid, -price);
        GiveMoney(sellerid, price);

        RemoveAllHouseKey(houseid);

        Log_Save(E_LOG_OFFER, sprintf("[%s] %s (%s) has sold a house to %s (%s) for %s.", ReturnDate(), ReturnName(playerid, 0), AccountData[playerid][pIP], ReturnName(sellerid, 0), AccountData[sellerid][pIP], FormatNumber(price)));

        PlayerData[playerid][pHouseSeller] = INVALID_PLAYER_ID;
        PlayerData[playerid][pHouseOffered] = -1;
        PlayerData[playerid][pHouseValue] = 0;
    }
}