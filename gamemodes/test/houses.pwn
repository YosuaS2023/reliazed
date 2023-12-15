House_CountVehicleSlot(playerid)
{
	new Cache:execute, total = 0, slot;

	execute = mysql_query(g_iHandle, sprintf("SELECT `houseParkingSlot` FROM `houses` WHERE `houseOwner`='%d';", GetPlayerSQLID(playerid)));

	if(cache_num_rows())
	{
        for(new i; i != cache_num_rows(); i++)
        {
            slot = cache_get_field_int(i, "houseParkingSlot");
            total += slot;
        }
    }
	cache_delete(execute);
	return total;
}

// House_CountVehicleSlot(playerid)
// {
//     for(new i; i != MAX_HOUSES; i++)
//     {
//         if(HouseData[i][houseExists] && HouseData[i][houseOwner] == PlayerData[playerid][pID])
//         {
//             new totalslot;
//             totalslot += HouseData[i][houseParkingSlot];

//             return totalslot;
//         }
//     }
//     return 1;
// }
Function:House_Load()
{
    static
        rows,
        fields,
        str[128];

    cache_get_data(rows, fields);

    for (new i = 0; i < rows; i ++) if(i < MAX_HOUSES)
    {
        HouseData[i][houseExists] = true;
        HouseData[i][houseLights] = false;

        HouseData[i][houseID] = cache_get_field_int(i, "houseID");
        HouseData[i][houseOwner] = cache_get_field_int(i, "houseOwner");
        HouseData[i][housePrice] = cache_get_field_int(i, "housePrice");
        HouseData[i][houseSeal] = cache_get_field_int(i, "houseSeal");

        cache_get_field_content(i, "houseAddress", HouseData[i][houseAddress], 32);
        cache_get_field_content(i, "houseOwnerName", HouseData[i][houseOwnerName], 32);

        HouseData[i][housePos][0] = cache_get_field_float(i, "housePosX");
        HouseData[i][housePos][1] = cache_get_field_float(i, "housePosY");
        HouseData[i][housePos][2] = cache_get_field_float(i, "housePosZ");
        HouseData[i][housePos][3] = cache_get_field_float(i, "housePosA");
        HouseData[i][houseInt][0] = cache_get_field_float(i, "houseIntX");
        HouseData[i][houseInt][1] = cache_get_field_float(i, "houseIntY");
        HouseData[i][houseInt][2] = cache_get_field_float(i, "houseIntZ");
        HouseData[i][houseInt][3] = cache_get_field_float(i, "houseIntA");
        HouseData[i][houseInterior] = cache_get_field_int(i, "houseInterior");
        HouseData[i][houseExterior] = cache_get_field_int(i, "houseExterior");
        HouseData[i][houseExteriorVW] = cache_get_field_int(i, "houseExteriorVW");
        HouseData[i][houseLocked] = cache_get_field_int(i, "houseLocked");
        HouseData[i][houseMoney] = cache_get_field_int(i, "houseMoney");
        HouseData[i][houseLastVisited] = cache_get_field_int(i, "houseLastVisited");

        //Parking Spawn House
        HouseData[i][houseParkingSlot]   = cache_get_field_int(i, "houseParkingSlot");
        HouseData[i][houseParkingSlotUsed] = cache_get_field_int(i, "houseParkingSlotUsed");
        HouseData[i][housePacket] = 0;

        for (new house_furniture_id = 0; house_furniture_id < MAX_HOUSE_FURNITURE; house_furniture_id++)
        {
            HouseData[i][furniture][house_furniture_id] = -1;
        }

        House_Refresh(i);
    }
    for (new i = 0; i < MAX_HOUSES; i ++) 
    {
        if(HouseData[i][houseExists]) 
        {
            format(str, sizeof(str), "SELECT * FROM `weapon_houses` WHERE `houseid` = '%d' ORDER BY `slot` ASC LIMIT 5", HouseData[i][houseID]);
            mysql_tquery(g_iHandle, str, "OnLoadWeapon", "d", i);

            format(str, sizeof(str), "SELECT * FROM `housestorage` WHERE `ID` = '%d'", HouseData[i][houseID]);
            mysql_tquery(g_iHandle, str, "OnLoadStorage", "d", i);

            format(str, sizeof(str), "SELECT * FROM `furniture` WHERE `ID` = '%d'", HouseData[i][houseID]);
            mysql_tquery(g_iHandle, str, "OnLoadFurniture", "d", i);

            format(str, sizeof(str), "SELECT * FROM `clothes_wardrobe` WHERE `houseid` = '%d' LIMIT %d", HouseData[i][houseID], MAX_CLOTHES_WARDROBE);
            mysql_tquery(g_iHandle, str, "OnLoadClothes", "d", i);

            format(str, sizeof(str), "SELECT * FROM `accesories_wardrobe` WHERE `houseid` = '%d' LIMIT %d", HouseData[i][houseID], MAX_CLOTHES_WARDROBE);
            mysql_tquery(g_iHandle, str, "OnLoadAccesories", "d", i);
        }
    }
    printf("*** [load] house data (%d count).", rows);
    return 1;
}

House_Save(houseid)
{
    static
        query[2150];

    format(query, sizeof(query), "UPDATE `houses` SET `houseOwner` = '%d', `housePrice` = '%d', `houseAddress` = '%s', `housePosX` = '%.4f', `housePosY` = '%.4f', `housePosZ` = '%.4f', `housePosA` = '%.4f', `houseIntX` = '%.4f', `houseIntY` = '%.4f', `houseIntZ` = '%.4f', `houseIntA` = '%.4f', `houseInterior` = '%d', `houseExterior` = '%d', `houseExteriorVW` = '%d'",
        HouseData[houseid][houseOwner],
        HouseData[houseid][housePrice],
        SQL_ReturnEscaped(HouseData[houseid][houseAddress]),
        HouseData[houseid][housePos][0],
        HouseData[houseid][housePos][1],
        HouseData[houseid][housePos][2],
        HouseData[houseid][housePos][3],
        HouseData[houseid][houseInt][0],
        HouseData[houseid][houseInt][1],
        HouseData[houseid][houseInt][2],
        HouseData[houseid][houseInt][3],
        HouseData[houseid][houseInterior],
        HouseData[houseid][houseExterior],
        HouseData[houseid][houseExteriorVW]
    );
    format(query, sizeof(query), "%s, `houseParkingSlot` = '%d', `houseParkingSlotUsed` = '%d', `houseSeal` = '%d'",
        query,
        HouseData[houseid][houseParkingSlot],
        HouseData[houseid][houseParkingSlotUsed],
        HouseData[houseid][houseSeal]
        //, `houseParkingPosX` = '%.4f', `houseParkingPosY` = '%.4f', `houseParkingPosZ` = '%.4f', `houseParkingPosRZ` = '%.4f'
        // HouseData[houseid][houseParkingPos][0],
        // HouseData[houseid][houseParkingPos][1],
        // HouseData[houseid][houseParkingPos][2],
        // HouseData[houseid][houseParkingPos][3]
    );
    format(query, sizeof(query), "%s, `houseLocked` = '%d', `houseMoney` = '%d', `houseOwnerName` = '%s', `houseLastVisited` = '%d' WHERE `houseID` = '%d'",
        query,
        HouseData[houseid][houseLocked],
        HouseData[houseid][houseMoney],
        HouseData[houseid][houseOwnerName],
        HouseData[houseid][houseLastVisited],
        HouseData[houseid][houseID]
    );
    return mysql_tquery(g_iHandle, query);
}

House_Inside(playerid)
{
    if(PlayerData[playerid][pHouse] != -1)
    {
        for (new i = 0; i != MAX_HOUSES; i ++) if(HouseData[i][houseExists] && HouseData[i][houseID] == PlayerData[playerid][pHouse] && GetPlayerInterior(playerid) == HouseData[i][houseInterior] && GetPlayerVirtualWorld(playerid) > 0) {
            return i;
        }
    }
    return -1;
}


House_Nearest(playerid)
{
    for (new i = 0; i != MAX_HOUSES; i ++) if(HouseData[i][houseExists] && IsPlayerInRangeOfPoint(playerid, 2.5, HouseData[i][housePos][0], HouseData[i][housePos][1], HouseData[i][housePos][2]))
    {
        if(GetPlayerInterior(playerid) == HouseData[i][houseExterior] && GetPlayerVirtualWorld(playerid) == HouseData[i][houseExteriorVW])
            return i;
    }
    return -1;
}

House_Refresh(houseid)
{
    if(houseid != -1 && HouseData[houseid][houseExists])
    {
        new
            Float:x = HouseData[houseid][housePos][0],
            Float:y = HouseData[houseid][housePos][1],
            Float:z = HouseData[houseid][housePos][2],
            int = HouseData[houseid][houseExterior],
            vw  = HouseData[houseid][houseExteriorVW],
            price = HouseData[houseid][housePrice],
            after_inflation_price = Economy_GetAmountAfterInflation(price),
            string[1024]
        ;

        if(!HouseData[houseid][houseOwner])
        {
            format(string, sizeof(string), "[#%d | ID: %d]\n"COL_GREEN"This house for sell\n"WHITE"Address: "YELLOW"%s\n"WHITE"Parking Slot: "YELLOW"%d\n"WHITE"Price: "YELLOW"%s\n"WHITE"Type /buy to purchase", HouseData[houseid][houseID], houseid, GetLocation(HouseData[houseid][housePos][0], HouseData[houseid][housePos][1], HouseData[houseid][housePos][2]), HouseData[houseid][houseParkingSlot], FormatNumber(after_inflation_price));
        }
        else
        {
            if(HouseData[houseid][houseSeal]) format(string, sizeof(string), "[#%d | ID: %d]\n"WHITE"Location "YELLOW"%s\n"WHITE"Parking Slot : %d\n"WHITE"Owned by %s\n"WHITE"This house is sealed by "COL_RED"authority\n"WHITE"Press '"COL_RED"~k~~GROUP_CONTROL_BWD~"WHITE"' to enter", HouseData[houseid][houseID], houseid, GetLocation(HouseData[houseid][housePos][0], HouseData[houseid][housePos][1], HouseData[houseid][housePos][2]), HouseData[houseid][houseParkingSlot], HouseData[houseid][houseOwnerName]);
            else format(string, sizeof(string), "[#%d | ID: %d]\n"WHITE"Location "YELLOW"%s\n"WHITE"Parking Slot : %d\n"WHITE"Owned by %s\n"WHITE"Press '"COL_RED"~k~~GROUP_CONTROL_BWD~"WHITE"' to enter", HouseData[houseid][houseID], houseid, GetLocation(HouseData[houseid][housePos][0], HouseData[houseid][housePos][1], HouseData[houseid][housePos][2]), HouseData[houseid][houseParkingSlot], HouseData[houseid][houseOwnerName]);
        }

        if(IsValidDynamic3DTextLabel(HouseData[houseid][houseText3D]))
        {
            Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, HouseData[houseid][houseText3D], E_STREAMER_X, x);
            Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, HouseData[houseid][houseText3D], E_STREAMER_Y, y);
            Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, HouseData[houseid][houseText3D], E_STREAMER_Z, z);

            Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, HouseData[houseid][houseText3D], E_STREAMER_WORLD_ID, vw);
            Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, HouseData[houseid][houseText3D], E_STREAMER_INTERIOR_ID, int);

            UpdateDynamic3DTextLabelText(HouseData[houseid][houseText3D], X11_TURQUOISE_1, string);
        }
        else
        {
            HouseData[houseid][houseText3D] = CreateDynamic3DTextLabel(string, X11_TURQUOISE_1, x, y, z+0.5, 15, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, vw, int);
        }

        if(IsValidDynamicPickup(HouseData[houseid][housePickup]))
        {
            Streamer_SetFloatData(STREAMER_TYPE_PICKUP, HouseData[houseid][housePickup], E_STREAMER_X, x);
            Streamer_SetFloatData(STREAMER_TYPE_PICKUP, HouseData[houseid][housePickup], E_STREAMER_Y, y);
            Streamer_SetFloatData(STREAMER_TYPE_PICKUP, HouseData[houseid][housePickup], E_STREAMER_Z, z);

            Streamer_SetIntData(STREAMER_TYPE_PICKUP, HouseData[houseid][housePickup], E_STREAMER_WORLD_ID, vw);
            Streamer_SetIntData(STREAMER_TYPE_PICKUP, HouseData[houseid][housePickup], E_STREAMER_INTERIOR_ID, int);
        }
        else
        {
            HouseData[houseid][housePickup] = CreateDynamicPickup(1273, 23, x, y, z+0.2, vw, int);
        }

        if(IsValidDynamicCP(HouseData[houseid][houseCheckpoint]))
        {
            Streamer_SetFloatData(STREAMER_TYPE_CP, HouseData[houseid][houseCheckpoint], E_STREAMER_X, x);
            Streamer_SetFloatData(STREAMER_TYPE_CP, HouseData[houseid][houseCheckpoint], E_STREAMER_Y, y);
            Streamer_SetFloatData(STREAMER_TYPE_CP, HouseData[houseid][houseCheckpoint], E_STREAMER_Z, z);

            Streamer_SetIntData(STREAMER_TYPE_CP, HouseData[houseid][houseCheckpoint], E_STREAMER_WORLD_ID, vw);
            Streamer_SetIntData(STREAMER_TYPE_CP, HouseData[houseid][houseCheckpoint], E_STREAMER_INTERIOR_ID, int);

        }
        else
        {
            HouseData[houseid][houseCheckpoint] = CreateDynamicCP(x, y, z, 1, _, _, _, 3);
        }
    }
    return 1;
}

House_RefreshAll()
{
    for (new i = 0; i < MAX_HOUSES; i ++)
    {
        House_Refresh(i);
    }
}

House_GetCount(playerid)
{
    new
        count = 0;

    for (new i = 0; i != MAX_HOUSES; i ++) if(HouseData[i][houseExists] && House_IsOwner(playerid, i, false))
    {
        count++;
    }
    return count;
}

House_Create(playerid, price,address[], type = TYPE_SMALL)
{
    static
        Float:x,
        Float:y,
        Float:z,
        Float:angle;

    if(GetPlayerPos(playerid, x, y, z) && GetPlayerFacingAngle(playerid, angle))
    {
        for (new i = 0; i != MAX_HOUSES; i ++) if(!HouseData[i][houseExists])
        {
            HouseData[i][houseExists] = true;
            HouseData[i][houseOwner] = 0;
            HouseData[i][housePrice] = price;
            HouseData[i][houseMoney] = 0;

            format(HouseData[i][houseAddress], 32, "%s", address);
            format(HouseData[i][houseOwnerName], 32, "The State");

            HouseData[i][housePos][0] = x;
            HouseData[i][housePos][1] = y;
            HouseData[i][housePos][2] = z;
            HouseData[i][housePos][3] = angle;

            HouseData[i][houseInt][0] = arrHouseInteriors[type][eHouseX];
            HouseData[i][houseInt][1] = arrHouseInteriors[type][eHouseY];
            HouseData[i][houseInt][2] = arrHouseInteriors[type][eHouseZ];
            HouseData[i][houseInt][3] = arrHouseInteriors[type][eHouseAngle];
            HouseData[i][houseInterior] = arrHouseInteriors[type][eHouseInterior];

            HouseData[i][houseExterior] = GetPlayerInterior(playerid);
            HouseData[i][houseExteriorVW] = GetPlayerVirtualWorld(playerid);

            HouseData[i][houseLights] = false;
            HouseData[i][houseLocked] = true;

            House_Refresh(i);
            mysql_tquery(g_iHandle, "INSERT INTO `houses` (`houseOwner`) VALUES(0)", "OnHouseCreated", "d", i);
            return i;
        }
    }
    return -1;
}

House_RemoveFurniture(houseid)
{
    if(HouseData[houseid][houseExists])
    {
        for (new i = 0; i != MAX_FURNITURE; i ++) if(FurnitureData[i][furnitureExists] && FurnitureData[i][furnitureHouse] == houseid) {
            FurnitureData[i][furnitureExists] = false;
            FurnitureData[i][furnitureModel] = 0;
            FurnitureData[i][furnitureHouse] = -1;

            DestroyDynamicObject(FurnitureData[i][furnitureObject]);
            FurnitureData[i][furnitureObject] = INVALID_STREAMER_ID;
        }
        mysql_tquery(g_iHandle, sprintf("DELETE FROM `furniture` WHERE `ID` = '%d'", HouseData[houseid][houseID]));
    }
    return 1;
}

House_Delete(houseid)
{
    if(houseid != -1 && HouseData[houseid][houseExists])
    {
        new
        string[64];

        format(string, sizeof(string), "DELETE FROM `houses` WHERE `houseID` = '%d'", HouseData[houseid][houseID]);
        mysql_tquery(g_iHandle, string);

        if(IsValidDynamic3DTextLabel(HouseData[houseid][houseText3D]))
            DestroyDynamic3DTextLabel(HouseData[houseid][houseText3D]);

        if(IsValidDynamicPickup(HouseData[houseid][housePickup]))
            DestroyDynamicPickup(HouseData[houseid][housePickup]);

        if(IsValidDynamicCP(HouseData[houseid][houseCheckpoint]))
            DestroyDynamicCP(HouseData[houseid][houseCheckpoint]);

        /*for (new i = 0; i < MAX_BACKPACKS; i ++) if(BackpackData[i][backpackExists] && BackpackData[i][backpackHouse] == HouseData[houseid][houseID]) {
            Backpack_Delete(i);
        }*/
        House_RemoveFurniture(houseid);
        House_RemoveAllItems(houseid);

        HouseData[houseid][houseExists] = false;
        HouseData[houseid][houseOwner] = 0;
        HouseData[houseid][houseID] = 0;
        HouseData[houseid][houseText3D] = Text3D:INVALID_STREAMER_ID;
        HouseData[houseid][housePickup] = HouseData[houseid][houseCheckpoint] = INVALID_STREAMER_ID;
    }
    return 1;
}
House_IsShared(playerid, houseid)
{
	for(new i; i < PLAYER_MAX_HOUSE_SHARE_KEYS; i++) 
	if(HouseKeyData[playerid][i][houseID] == HouseData[houseid][houseID])
		return 1;

	return 0;
}
House_IsOwner(playerid, houseid, bool:shared = true)
{
    if (houseid < 0)
        return 0;

    if(!PlayerData[playerid][pLogged] || PlayerData[playerid][pID] == -1)
        return 0;

    if((HouseData[houseid][houseExists] && HouseData[houseid][houseOwner] != 0) && HouseData[houseid][houseOwner] == PlayerData[playerid][pID])
        return 1;

    if(shared && House_IsShared(playerid, houseid))
        return 1;

    return 0;
}

Dialog:MyInventory(playerid, response, listitem, inputtext[])
{
    if(response)
    {
        if (listitem < 0)
        {
            // kasih warning untuk pilih salah 1 di list.
            SendErrorMessage(playerid, "Please select one of the list.");
            OpenInventory(playerid);
            return 1;
        }

        new index = ListedInventory[playerid][listitem];
        if(InventoryData[playerid][index][invExists])
        {
            new
                name[48],
                id = -1;
                //backpack = GetPlayerBackpack(playerid);

            PlayerData[playerid][pInventoryItem] = index;
            strunpack(name, InventoryData[playerid][index][invItem]);

            switch (PlayerData[playerid][pStorageSelect])
            {
                case 1:
                {
                    if((id = House_Inside(playerid)) != -1 && House_IsOwner(playerid, id))
                    {
                        if(InventoryData[playerid][index][invQuantity] == 1)
                        {
                            /*if(!strcmp(name, "Backpack") && GetHouseBackpack(id) != -1)
                                return SendErrorMessage(playerid, "You can only store one backpack in your house.");*/

                            House_AddItem(id, name, InventoryData[playerid][index][invModel], 1);
                            Inventory_Remove(playerid, name);

                            SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has stored a \"%s\" into their house storage.", ReturnName(playerid, 0), name);
                            House_ShowItems(playerid, id);

                            /*if(!strcmp(name, "Backpack") && backpack != -1)
                            {
                                BackpackData[backpack][backpackPlayer] = 0;
                                BackpackData[backpack][backpackHouse] = HouseData[id][houseID];

                                Backpack_Save(backpack);
                                SetAccessories(playerid);
                            }*/
                        }
                        else Dialog_Show(playerid, HouseDeposit, DIALOG_STYLE_INPUT, "House Deposit", "Item: %s (Quantity: %d)\n\nPlease enter the quantity that you wish to store for this item:", "Store", "Back", name, InventoryData[playerid][index][invQuantity]);
                    }
                    PlayerData[playerid][pStorageSelect] = 0;
                }
                case 2:
                {
                    if((id = ApartmentRoom_Inside(playerid)) != -1 && ApartmentRoom_IsOwned(playerid, id))
                    {
                        if(InventoryData[playerid][index][invQuantity] == 1)
                        {
                            /*if(!strcmp(name, "Backpack") && GetHouseBackpack(id) != -1)
                                return SendErrorMessage(playerid, "You can only store one backpack in your house.");*/

                            Apartment_AddItem(id, name, InventoryData[playerid][index][invModel], 1);
                            Inventory_Remove(playerid, name);

                            SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has stored a \"%s\" into their house storage.", ReturnName(playerid, 0), name);
                            Apartment_ShowItem(playerid, id);
                        }
                        else Dialog_Show(playerid, ApartmentDeposit, DIALOG_STYLE_INPUT, "House Deposit", "Item: %s (Quantity: %d)\n\nPlease enter the quantity that you wish to store for this item:", "Store", "Back", name, InventoryData[playerid][index][invQuantity]);
                    }
                    PlayerData[playerid][pStorageSelect] = 0;
                }
                case 3:
                {
                    /*if(!strcmp(name, "Backpack"))
                        return SendErrorMessage(playerid, "This item cannot be stored.");*/

                    /*if(InventoryData[playerid][index][invQuantity] == 1)
                    {
                        Backpack_Add(GetPlayerBackpack(playerid), name, InventoryData[playerid][index][invModel], 1);
                        Inventory_Remove(playerid, name);

                        SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has stored a \"%s\" into their backpack.", ReturnName(playerid, 0), name);
                        Backpack_Open(playerid);
                    }
                    else
                    {
                        Dialog_Show(playerid, BackpackDeposit, DIALOG_STYLE_INPUT, "Backpack Deposit", "Item: %s (Quantity: %d)\n\nPlease enter the quantity that you wish to store for this item:", "Store", "Back", name, InventoryData[playerid][index][invQuantity]);
                    }
                    PlayerData[playerid][pStorageSelect] = 0;*/
                    SendServerMessage(playerid, "This option does't work at the moment.");
                }
                default:
                {
                    format(name, sizeof(name), "%s (%d)", name, InventoryData[playerid][index][invQuantity]);

                    if(Garbage_Nearest(playerid) != -1) Dialog_Show(playerid, Inventory, DIALOG_STYLE_LIST, name, "Use Item\nGive Item\nThrow Out", "Select", "Cancel");
                    else Dialog_Show(playerid, Inventory, DIALOG_STYLE_LIST, name, "Use Item\nGive Item\nDrop Item", "Select", "Cancel");
                }
            }
        }
    }
    return 1;
}
CMD:abadon(playerid)
{
   else if(!IsPlayerInAnyVehicle(playerid) && (id = House_Nearest(playerid)) != -1 && House_IsOwner(playerid, id, false))
    {
        if(isnull(params) || (!isnull(params) && strcmp(params, "confirm", true) != 0))
        {
            SendSyntaxMessage(playerid, "/abandon [confirm]");
            SendClientMessage(playerid, X11_TOMATO_1, "WARNING:"WHITE" You are about to abandon your house with no refund.");
            SendClientMessage(playerid, X11_TOMATO_1, "WARNING:"WHITE" Including money, gun in your house.");
        }
        else if(!strcmp(params, "confirm", true))
        {
            HouseData[id][houseOwner] = 0;

            // mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET `house_parking`='-1',`state`='%d' WHERE `house_parking`='%d';", VEHICLE_STATE_SPAWNED , HouseData[id][houseID]));
            // Vehicle_PlayerLoad(playerid);

            House_RemoveAllItems(id);
            House_Refresh(id);
            House_Save(id);

            RemoveAllHouseKey(id);

            SendServerMessage(playerid, "You have abandoned your house: %s.", HouseData[id][houseAddress]);
            Log_Save(E_LOG_HOUSE, sprintf("[%s] %s has abandoned house ID: %d.", ReturnDate(), ReturnName(playerid), id));
        }
    }
}
CMD:switch(playerid, params[])
{
    static
        id = -1;

    if((id = House_Inside(playerid)) != -1)
    {
        if(House_IsOwner(playerid, id))
        {
            if(HouseData[id][houseLights])
            {
                foreach (new i : Player) if(House_Inside(i) == id) {
                    PlayerTextDrawShow(i, PlayerTextdraws[i][textdraw_switch]);
                }
                SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s flicks the light switch off.", ReturnName(playerid, 0));
                HouseData[id][houseLights] = false;
            }
            else
            {
                foreach (new i : Player) if(House_Inside(i) == id) {
                    PlayerTextDrawHide(i, PlayerTextdraws[i][textdraw_switch]);
                }
                SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s flicks the light switch on.", ReturnName(playerid, 0));
                HouseData[id][houseLights] = true;
            }
            return 1;
        }
        SendErrorMessage(playerid, "You must be in your house to manage the house lights.");
        return 1;
    }
    SendErrorMessage(playerid, "You must be in a house to use the lights.");
    return 1;
}

CMD:lock(playerid, params[])
{
    static
        id = -1;

    if(!IsPlayerInAnyVehicle(playerid) && (id = (ApartmentRoom_Inside(playerid) == -1) ? (ApartmentRoom_Nearest(playerid)) : (ApartmentRoom_Inside(playerid))) != -1)
    {
        if(ApartmentRoom_IsOwned(playerid, id))
        {
            if(!ApartmentRoomData[id][apartmentRoomLock])
            {
                ApartmentRoomData[id][apartmentRoomLock] = 1;
                ApartmentRoom_Save(id);

                ShowPlayerFooter(playerid, "You have ~r~locked~w~ your apartment!");
                PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
            }
            else
            {
                ApartmentRoomData[id][apartmentRoomLock] = 0;
                ApartmentRoom_Save(id);

                ShowPlayerFooter(playerid, "You have ~g~unlocked~w~ your apartment!");
                PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
            }
        }
    }
    else if(!IsPlayerInAnyVehicle(playerid) && (id = (House_Inside(playerid) == -1) ? (House_Nearest(playerid)) : (House_Inside(playerid))) != -1)
    {
        if(House_IsOwner(playerid, id))
        {
            if(!HouseData[id][houseLocked])
            {
                HouseData[id][houseLocked] = true;
                House_Save(id);

                ShowPlayerFooter(playerid, "You have ~r~locked~w~ your house!");
                PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
            }
            else
            {
                HouseData[id][houseLocked] = false;
                House_Save(id);

                ShowPlayerFooter(playerid, "You have ~g~unlocked~w~ your house!");
                PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
            }
        }
    }
    else if(!IsPlayerInAnyVehicle(playerid) && (id = (Business_Inside(playerid) == -1) ? (Business_Nearest(playerid)) : (Business_Inside(playerid))) != -1)
    {
        if(Business_IsOwner(playerid, id))
        {
            if(!BusinessData[id][bizLocked])
            {
                BusinessData[id][bizLocked] = true;

                Business_Refresh(id);
                Business_Save(id);

                ShowPlayerFooter(playerid, "You have ~r~locked~w~ the business!");
                PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
            }
            else
            {
                BusinessData[id][bizLocked] = false;

                Business_Refresh(id);
                Business_Save(id);

                ShowPlayerFooter(playerid, "You have ~g~unlocked~w~ the business!");
                PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
            }
        }
    }
    else SendErrorMessage(playerid, "You are not in range of anything you can lock.");
    return 1;
}

CMD:sell(playerid, params[])
{
    new
        targetid,
        type[24],
        string[128];

    if(sscanf(params, "us[24]S()[128]", targetid, type, string))
    {
        SendSyntaxMessage(playerid, "/sell [playerid/PartOfName] [name]");
        SendClientMessage(playerid, X11_YELLOW_2, "[NAMES]:"WHITE" house, business, workshop, vending, apartment");
        return 1;
    }
    if(targetid == INVALID_PLAYER_ID || !IsPlayerNearPlayer(playerid, targetid, 5.0)) return SendErrorMessage(playerid, "The player is disconnected or not near you.");
    if(PlayerData[targetid][pSpectator] != INVALID_PLAYER_ID) return SendErrorMessage(playerid, "That player is disconnected or not near you.");
    if(targetid == playerid) return SendErrorMessage(playerid, "You cannot sell to yourself.");


    if(!strcmp(type, "apartment", true))
    {
        static
            price,
            index = -1;

        if(ApartmentRoom_GetCount(targetid) >= MAX_PLAYER_APARTMENT)
            return SendErrorMessage(playerid, "That player can only own %d apartment at a time.", MAX_PLAYER_APARTMENT);

        if(sscanf(string, "d", price))
            return SendSyntaxMessage(playerid, "/sell [playerid/PartOfName] [apartment] [price]");

        if(price < 1)
            return SendErrorMessage(playerid, "The price you've entered cannot below the value of $1.");

        if((index = ApartmentRoom_Nearest(playerid)) != -1 && ApartmentRoom_IsOwned(playerid, index)) {
            PlayerData[targetid][pApartmentSeller] = playerid;
            PlayerData[targetid][pApartmentOffered] = index;
            PlayerData[targetid][pApartmentValue] = price;

            SendServerMessage(playerid, "You have requested %s to purchase your apartment (%s).", ReturnName(targetid, 0), FormatNumber(price));
            SendServerMessage(targetid, "%s has offered you their apartment room for %s (type \"/approve apartment\" to accept).", ReturnName(playerid, 0), FormatNumber(price));
            return 1;
        }
        else SendErrorMessage(playerid, "You are not in range of any of your apartment.");
    }
    else if(!strcmp(type, "vending", true))
    {
        static
            price,
            index = -1;

        if(Vending_GetCount(targetid) >= MAX_OWNABLE_VENDING)
            return SendErrorMessage(playerid, "That player can only own %d vending machine at a time.", MAX_OWNABLE_VENDING);

        if(sscanf(string, "d", price))
            return SendSyntaxMessage(playerid, "/sell [playerid/PartOfName] [vending] [price]");

        if(price < 1)
            return SendErrorMessage(playerid, "The price you've entered cannot below the value of $1.");

        if((index = Vending_Nearest(playerid)) != -1 && Vending_IsOwned(playerid, index)) {
            PlayerData[targetid][pVendingSeller] = playerid;
            PlayerData[targetid][pVendingOffered] = index;
            PlayerData[targetid][pVendingValue] = price;

            SendServerMessage(playerid, "You have requested %s to purchase your vending machine (%s).", ReturnName(targetid, 0), FormatNumber(price));
            SendServerMessage(targetid, "%s has offered you their vending machine for %s (type \"/approve vending\" to accept).", ReturnName(playerid, 0), FormatNumber(price));
            return 1;
        }
        else SendErrorMessage(playerid, "You are not in range of any of your vending.");
    }
    else if(!strcmp(type, "house", true))
    {
        static
            price,
            houseid = -1;

        if(GetAdminLevel(targetid) >= 8)
        {
            if(House_GetCount(targetid) >= MAX_OWNABLE_HOUSES+1)
                return SendErrorMessage(playerid, "That player can only own %d houses at a time.", MAX_OWNABLE_HOUSES+1);
        }
        else
        {
            if(House_GetCount(targetid) >= MAX_OWNABLE_HOUSES && GetPlayerVIPLevel(targetid) < 4)
                return SendErrorMessage(playerid, "That player can only own %d houses at a time.", MAX_OWNABLE_HOUSES);

            else if(House_GetCount(targetid) >= MAX_OWNABLE_HOUSES+1)
                return SendErrorMessage(playerid, "That player can only own %d houses at a time.", MAX_OWNABLE_HOUSES+1);
        }

        if(sscanf(string, "d", price))
            return SendSyntaxMessage(playerid, "/sell [playerid/PartOfName] [house] [price]");

        if(price < 1)
            return SendErrorMessage(playerid, "The price you've entered cannot below the value of $1.");

        if((houseid = House_Nearest(playerid)) != -1 && House_IsOwner(playerid, houseid, false)) {
            PlayerData[targetid][pHouseSeller] = playerid;
            PlayerData[targetid][pHouseOffered] = houseid;
            PlayerData[targetid][pHouseValue] = price;

            SendServerMessage(playerid, "You have requested %s to purchase your house (%s).", ReturnName(targetid, 0), FormatNumber(price));
            SendServerMessage(targetid, "%s has offered you their house for %s (type \"/approve house\" to accept).", ReturnName(playerid, 0), FormatNumber(price));
            return 1;
        }
        else SendErrorMessage(playerid, "You are not in range of any of your houses.");
    }
    else if(!strcmp(type, "business", true))
    {
        static
            price,
            bizid = -1;

        if(!PlayerData[targetid][pBusinessLicenseExpired])
            return SendErrorMessage(playerid, "That player don't have business licenses.");

        if(GetAdminLevel(targetid) >= 8)
        {
            if(Business_GetCount(targetid) >= MAX_OWNABLE_BUSINESSES+1)
                return SendErrorMessage(playerid, "That player can only own %d businesses at a time.", MAX_OWNABLE_BUSINESSES+1);
        }
        else
        {
            if(Business_GetCount(targetid) >= MAX_OWNABLE_BUSINESSES && GetPlayerVIPLevel(targetid) < 4)
                return SendErrorMessage(playerid, "That player can only own %d businesses at a time.", MAX_OWNABLE_BUSINESSES);

            else if(Business_GetCount(targetid) >= MAX_OWNABLE_BUSINESSES+1)
                return SendErrorMessage(playerid, "That player can only own %d businesses at a time.", MAX_OWNABLE_BUSINESSES+1);
        }

        if(sscanf(string, "d", price))
            return SendSyntaxMessage(playerid, "/sell [playerid/PartOfName] [business] [price]");

        if(price < 1)
            return SendErrorMessage(playerid, "The price you've entered cannot below the value of $1.");

        if((bizid = Business_Nearest(playerid)) != -1 && Business_IsOwner(playerid, bizid)) {
            if(BusinessData[bizid][bizSeal]) return SendErrorMessage(playerid, "Can't sell sealed property.");
            PlayerData[targetid][pBusinessSeller] = playerid;
            PlayerData[targetid][pBusinessOffered] = bizid;
            PlayerData[targetid][pBusinessValue] = price;

            SendServerMessage(playerid, "You have requested %s to purchase your business (%s).", ReturnName(targetid, 0), FormatNumber(price));
            SendServerMessage(targetid, "%s has offered you their business for %s (type \"/approve business\" to accept).", ReturnName(playerid, 0), FormatNumber(price));
            return 1;
        }
        SendErrorMessage(playerid, "You are not in range of any of your businesses.");
    }
    else if(!strcmp(type, "workshop", true))
    {
        static
            price,
            ws = -1;

        if(!PlayerData[targetid][pWorkshopLicenseExpired])
            return SendErrorMessage(playerid, "That player don't have workshop licenses.");

        if(AccountData[targetid][pAdmin] < 1)
        {
            if(Workshop_GetCount(targetid) >= MAX_OWNABLE_WORKSHOP)
                return SendErrorMessage(playerid, "That player can only own %d workshop at a time.", MAX_OWNABLE_WORKSHOP);
        }
        else {
            if(Workshop_GetCount(targetid) >= MAX_OWNABLE_WORKSHOP+1)
                return SendErrorMessage(playerid, "That player can only own %d workshop at a time.", MAX_OWNABLE_WORKSHOP+1);
        }

        if(sscanf(string, "d", price))
            return SendSyntaxMessage(playerid, "/sell [playerid/PartOfName] [workshop] [price]");

        if(price < 1)
            return SendErrorMessage(playerid, "The price you've entered cannot below the value of $1.");

        if((ws = Workshop_Nearest(playerid)) != -1 && Workshop_IsOwner(playerid, ws)) {
            if(WorkshopData[ws][wSeal]) return SendErrorMessage(playerid, "Can't sell sealed property.");
            PlayerData[targetid][pWorkshopSeller] = playerid;
            PlayerData[targetid][pWorkshopOffered] = ws;
            PlayerData[targetid][pWorkshopValue] = price;

            SendServerMessage(playerid, "You have requested %s to purchase your workshop (%s).", ReturnName(targetid, 0), FormatNumber(price));
            SendServerMessage(targetid, "%s has offered you their workshop for %s (type \"/approve workshop\" to accept).", ReturnName(playerid, 0), FormatNumber(price));
            return 1;
        }
        SendErrorMessage(playerid, "You are not in range of any of your workshop.");
    }
    return 1;
}
CMD:createhouse(playerid, params[])
{
    static
        price,
        id,
        type,
        address[32];

    if (CheckAdmin(playerid, 7))
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

    if (CheckAdmin(playerid, 7))
        return PermissionError(playerid);

    if(sscanf(params, "d", id))
        return SendSyntaxMessage(playerid, "/destroyhouse [house id]");

    if((id < 0 || id >= MAX_HOUSES) || !HouseData[id][houseExists])
        return SendErrorMessage(playerid, "You have specified an invalid house ID.");

    House_Delete(id);
    SendServerMessage(playerid, "You have successfully destroyed house ID: %d.", id);
    return 1;
}

CMD:housecmds(playerid, params[])
{
    SendClientMessage(playerid, COLOR_CLIENT, "HOUSES:"WHITE" /buy, /abandon, /lock, /storage, /furniture.");
    SendClientMessage(playerid, COLOR_CLIENT, "HOUSES:"WHITE" /doorbell, /switch.");
    return 1;
}

hook beli
{
    else if((id = House_Nearest(playerid)) != -1)
    {
        if(GetAdminLevel(playerid) >= 8)
        {
            if(House_GetCount(playerid) >= MAX_OWNABLE_HOUSES+1)
                return SendErrorMessage(playerid, "You can only own %d houses at a time.", MAX_OWNABLE_HOUSES+1);
        }
        else
        {
            if(House_GetCount(playerid) >= MAX_OWNABLE_HOUSES && GetPlayerVIPLevel(playerid) < 4)
                return SendErrorMessage(playerid, "You can only own %d houses at a time.", MAX_OWNABLE_HOUSES);

            else if(House_GetCount(playerid) >= MAX_OWNABLE_HOUSES+1)
                return SendErrorMessage(playerid, "You can only own %d houses at a time.", MAX_OWNABLE_HOUSES+1);
        }

        new
            price = HouseData[id][housePrice],
            after_inflation_price = Economy_GetAmountAfterInflation(price)
        ;

        if(HouseData[id][houseOwner] != 0)
            return SendErrorMessage(playerid, "This house is already owned at the moment.");

        if(after_inflation_price > GetMoney(playerid))
            return SendErrorMessage(playerid, "You have insufficient funds for the purchase.");

        HouseData[id][houseOwner] = GetPlayerSQLID(playerid);
        HouseData[id][houseLastVisited] = gettime();
        format(HouseData[id][houseOwnerName],32,"%s", NormalName(playerid));

        House_Refresh(id);
        House_Save(id);

        GiveMoney(playerid, -after_inflation_price, ECONOMY_ADD_SUPPLY, "bought house");
        SendServerMessage(playerid, "You have purchased \"%s\" for %s!", HouseData[id][houseAddress], FormatNumber(after_inflation_price));

        ShowPlayerFooter(playerid, "You have ~g~purchased~w~ a house!");
        Log_Save(E_LOG_HOUSE, sprintf("[%s] %s has purchased house ID: %d for %s.", ReturnDate(), ReturnName(playerid), id, FormatNumber(after_inflation_price)));
    }
}
static House_WeaponStorage(playerid, houseid)
{
    if(houseid == -1 || !HouseData[houseid][houseExists])
        return 0;

    new
        string[1050];

    for (new i = 0; i < 5; i ++)
    {
        if(!HouseData[houseid][houseWeapons][i]) format(string, sizeof(string), "%sEmpty Slot\n", string);
        else format(string, sizeof(string), "%s%s ("YELLOW"Ammo: %d"WHITE") ("CYAN"Durability: %d"WHITE")\n", string, ReturnWeaponName(HouseData[houseid][houseWeapons][i]), HouseData[houseid][houseAmmo][i], HouseData[houseid][houseDurability][i]);
    }
    Dialog_Show(playerid, HouseWeapons, DIALOG_STYLE_LIST, "Weapon Storage", string, "Select", "Cancel");
    return 1;
}

static House_ShowItems(playerid, houseid)
{
    if(houseid == -1 || !HouseData[houseid][houseExists])
        return 0;

    static
        string[MAX_HOUSE_STORAGE * 32],
        name[32];

    string[0] = 0;

    for (new i = 0; i != MAX_HOUSE_STORAGE; i ++)
    {
        if(!HouseStorage[houseid][i][hItemExists])
            format(string, sizeof(string), "%sEmpty Slot\n", string);

        else {
            strunpack(name, HouseStorage[houseid][i][hItemName]);

            if(HouseStorage[houseid][i][hItemQuantity] == 1) {
                format(string, sizeof(string), "%s%s\n", string, name);
            }
            else format(string, sizeof(string), "%s%s (%d)\n", string, name, HouseStorage[houseid][i][hItemQuantity]);
        }
    }
    Dialog_Show(playerid, HouseItems, DIALOG_STYLE_LIST, "Item Storage", string, "Select", "Cancel");
    return 1;
}
static House_OpenStorage(playerid, houseid)
{
    if(houseid == -1 || !HouseData[houseid][houseExists])
        return 0;

    new
        items[2],
        string[MAX_HOUSE_STORAGE * 32];

    for (new i = 0; i < MAX_HOUSE_STORAGE; i ++) if(HouseStorage[houseid][i][hItemExists]) {
        items[0]++;
    }
    for (new i = 0; i < 5; i ++) if(HouseData[houseid][houseWeapons][i]) {
        items[1]++;
    }
    format(string, sizeof(string), "Item Storage (%d/%d)\nWeapon Storage (%d/5)\nMoney Safe (%s)", items[0], MAX_HOUSE_STORAGE, items[1], FormatNumber(HouseData[houseid][houseMoney]));
    Dialog_Show(playerid, HouseStorage, DIALOG_STYLE_LIST, "House Storage", string, "Select", "Cancel");
    return 1;
}

static House_GetItemID(houseid, item[])
{
    if(houseid == -1 || !HouseData[houseid][houseExists])
        return 0;

    for (new i = 0; i < MAX_HOUSE_STORAGE; i ++)
    {
        if(!HouseStorage[houseid][i][hItemExists])
            continue;

        if(!strcmp(HouseStorage[houseid][i][hItemName], item)) return i;
    }
    return -1;
}

static House_GetFreeID(houseid)
{
    if(houseid == -1 || !HouseData[houseid][houseExists])
        return 0;

    for (new i = 0; i < MAX_HOUSE_STORAGE; i ++)
    {
        if(!HouseStorage[houseid][i][hItemExists])
        return i;
    }
    return -1;
}

static House_AddItem(houseid, item[], model, quantity = 1, slotid = -1)
{
    if(houseid == -1 || !HouseData[houseid][houseExists])
        return 0;

    new
        itemid = House_GetItemID(houseid, item),
        string[128];

    if(itemid == -1)
    {
        itemid = House_GetFreeID(houseid);

        if(itemid != -1)
        {
            if(slotid != -1)
                itemid = slotid;

            HouseStorage[houseid][itemid][hItemExists] = true;
            HouseStorage[houseid][itemid][hItemModel] = model;
            HouseStorage[houseid][itemid][hItemQuantity] = quantity;

            strpack(HouseStorage[houseid][itemid][hItemName], item, 32 char);

            format(string, sizeof(string), "INSERT INTO `housestorage` (`ID`, `itemName`, `itemModel`, `itemQuantity`) VALUES('%d', '%s', '%d', '%d')", HouseData[houseid][houseID], item, model, quantity);
            mysql_tquery(g_iHandle, string, "OnStorageAdd", "dd", houseid, itemid);

            return itemid;
        }
        return -1;
    }
    else
    {
        format(string, sizeof(string), "UPDATE `housestorage` SET `itemQuantity` = `itemQuantity` + %d WHERE `ID` = '%d' AND `itemID` = '%d'", quantity, HouseData[houseid][houseID], HouseStorage[houseid][itemid][hItemID]);
        mysql_tquery(g_iHandle, string);

        HouseStorage[houseid][itemid][hItemQuantity] += quantity;
    }
    return itemid;
}

static House_RemoveItem(houseid, item[], quantity = 1)
{
    if(houseid == -1 || !HouseData[houseid][houseExists])
        return 0;

    new
        itemid = House_GetItemID(houseid, item),
        string[128];

    if(itemid != -1)
    {
        if(HouseStorage[houseid][itemid][hItemQuantity] > 0)
        {
            HouseStorage[houseid][itemid][hItemQuantity] -= quantity;
        }
        if(quantity == -1 || HouseStorage[houseid][itemid][hItemQuantity] < 1)
        {
            HouseStorage[houseid][itemid][hItemExists] = false;
            HouseStorage[houseid][itemid][hItemModel] = 0;
            HouseStorage[houseid][itemid][hItemQuantity] = 0;

            format(string, sizeof(string), "DELETE FROM `housestorage` WHERE `ID` = '%d' AND `itemID` = '%d'", HouseData[houseid][houseID], HouseStorage[houseid][itemid][hItemID]);
            mysql_tquery(g_iHandle, string);
        }
        else if(quantity != -1 && HouseStorage[houseid][itemid][hItemQuantity] > 0)
        {
            format(string, sizeof(string), "UPDATE `housestorage` SET `itemQuantity` = `itemQuantity` - %d WHERE `ID` = '%d' AND `itemID` = '%d'", quantity, HouseData[houseid][houseID], HouseStorage[houseid][itemid][hItemID]);
            mysql_tquery(g_iHandle, string);
        }
        return 1;
    }
    return 0;
}

House_RemoveAllItems(houseid)
{
    for (new i = 0; i != MAX_HOUSE_STORAGE; i ++) {
        HouseStorage[houseid][i][hItemExists] = false;
        HouseStorage[houseid][i][hItemModel] = 0;
        HouseStorage[houseid][i][hItemQuantity] = 0;
    }
    mysql_tquery(g_iHandle, sprintf("DELETE FROM `housestorage` WHERE `ID` = '%d'", HouseData[houseid][houseID]));

    for (new i = 0; i < 5; i ++) {
        HouseData[houseid][houseWeapons][i] = 0;
        HouseData[houseid][houseAmmo][i] = 0;
        HouseData[houseid][houseDurability][i] = 0;
        HouseData[houseid][houseWeaponSlot][i] = -1;
        HouseData[houseid][houseSerial][i] = 0;
    }
    mysql_tquery(g_iHandle, sprintf("DELETE FROM `weapon_houses` WHERE `houseid` = '%d'", HouseData[houseid][houseID]));
    return 1;
}

hook lohin
{
    for(new i=0; i < MAX_HOUSES; i++)
    {
        if(House_IsOwner(playerid, i, false))
        {
            jumlahrumah++;
        }
    }
}
hook ONPLAYERKEY
{
    if(newkeys & KEY_CTRL_BACK) //Key H
    {
        new
            id = -1;

        if((id = House_Nearest(playerid)) != -1 && IsPlayerInDynamicCP(playerid, HouseData[id][houseCheckpoint]))
        {
            if(Entrance_HasRecentTeleport(playerid))
                return ShowPlayerFooter(playerid, "~g~INFO: ~w~Tunggu beberapa detik sebelum berpindah...");

            if(HouseData[id][houseInt][0] == 0.00 && HouseData[id][houseInt][1] == 0.00 && HouseData[id][houseInt][2] == 0.00) return SendErrorMessage(playerid, "Interior rumah masih kosong, atau belum memiliki interior.");
            if(HouseData[id][houseLocked]) return GameTextForPlayer(playerid, "~r~Locked", 1500, 1);
            if(HouseData[id][houseSeal]) return SendErrorMessage(playerid, "Rumah ini di sita oleh pihak {C0C0C0}LSPD.");

            Player_ToggleTelportAntiCheat(playerid, false);
            Entrance_UpdateRecentTeleport(playerid);
            SetPlayerPosEx(playerid, HouseData[id][houseInt][0], HouseData[id][houseInt][1], HouseData[id][houseInt][2], 2500);
            SetPlayerFacingAngle(playerid, HouseData[id][houseInt][3]);
            SetPlayerInterior(playerid, HouseData[id][houseInterior]);
            SetPlayerVirtualWorld(playerid, HouseData[id][houseID] + 5000);

            PlayerData[playerid][pHouse] = HouseData[id][houseID];
            SetPlayerWeather(playerid, 1);
            SetPlayerTime(playerid, 12, 0);
            return 1;
        }

        if((id = House_Inside(playerid)) != -1 && IsPlayerInRangeOfPoint(playerid, 2.5, HouseData[id][houseInt][0], HouseData[id][houseInt][1], HouseData[id][houseInt][2]))
        {
            if(Entrance_HasRecentTeleport(playerid))
                return ShowPlayerFooter(playerid, "~g~INFO: ~w~Tunggu beberapa detik sebelum berpindah...");

            Player_ToggleTelportAntiCheat(playerid, false);
            Entrance_UpdateRecentTeleport(playerid);
            SetPlayerPos(playerid, HouseData[id][housePos][0], HouseData[id][housePos][1], HouseData[id][housePos][2]);
            SetPlayerFacingAngle(playerid, HouseData[id][housePos][3] - 180.0);
            SetPlayerInterior(playerid, HouseData[id][houseExterior]);
            SetPlayerVirtualWorld(playerid, HouseData[id][houseExteriorVW]);
            SetCameraBehindPlayer(playerid);
            Player_ToggleTelportAntiCheat(playerid, true);

            PlayerData[playerid][pHouse] = -1;

            if(ChargePhone[playerid] >= 1)
            {
                ChargePhone[playerid] = 0;
                SendClientMessage(playerid, COLOR_WHITE, "You "RED"stop "WHITE"charging your battery as you get out from the house");
                SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s removes charge from his phone and stop charging their phone.", ReturnName(playerid, 0));

            }
            return 1;
        }
    }
}

Function:KickHouse(playerid, id)
{
    if(GetFactionType(playerid) != FACTION_POLICE || House_Nearest(playerid) != id)
        return 0;

    switch (random(6))
    {
        case 0..2:
        {
            ShowPlayerFooter(playerid, "You have ~r~failed~w~ to kick the door down.", 3000, 1);
            SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has failed to kick the door down.", ReturnName(playerid, 0));
        }
        default:
        {
            HouseData[id][houseLocked] = 0;
            House_Save(id);

            SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has successfully kicked the door down.", ReturnName(playerid, 0));
            ShowPlayerFooter(playerid, "Press ~y~'H'~w~ to enter the house.", 3000, 1);
        }
    }
    return 1;
}

Function:OnChangeRPName(playerid, newname[])
{
    if(!IsPlayerConnected(playerid))
        return 0;

    if(cache_num_rows())
        return Dialog_Show(playerid, NRPName, DIALOG_STYLE_INPUT, "Change Name", "Kamu harus masukan nama yang berbeda!", "Change", "Close");

    new oldname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, oldname, sizeof(oldname));

    UpdateCharacterString(playerid, "Character", newname);
    format(NormalName(playerid), MAX_PLAYER_NAME, newname);

    SetPlayerName(playerid, newname);

    for(new id; id < MAX_HOUSES; id++) if(HouseData[id][houseExists] && HouseData[id][houseOwner] == GetPlayerSQLID(playerid)) {
        format(HouseData[id][houseOwnerName], MAX_PLAYER_NAME, newname);
        House_Refresh(id);
    }
    SendServerMessage(playerid, "Kamu mengganti nama karakter %s menjadi %s.", oldname, newname);
    SendServerMessage(userid, "%s mengganti nama karaktermu menjadi %s.", ReturnAdminName(playerid), newname);

    Log_Save(E_LOG_SET_NAME, sprintf("[%s] %s mengganti nama %s menjadi %s.", ReturnDate(), ReturnAdminName(playerid), oldname, newname));
    ResetNameTag(playerid, false, false, false, false, true);
    //Discord_Log(SETNAMELOG, sprintf("%s mengganti nama %s menjadi %s.", ReturnAdminName(playerid), oldname, newname));
}
Function:OnHouseCreated(houseid)
{
    if(houseid == -1 || !HouseData[houseid][houseExists])
        return 0;

    HouseData[houseid][houseID] = cache_insert_id();
    House_Save(houseid);

    return 1;
}

Function:SpawnTimer(playerrid)
{
    mysql_tquery(g_iHandle, sprintf("SELECT * FROM `house_queue` WHERE `Username` = '%s'", ReturnName(playerid, 1)), "HouseQueue", "d", playerid);
    for(new i = 0; i != MAX_HOUSES; i++) if(House_IsOwner(playerid, i)) {
        HouseData[i][houseLastVisited] = gettime();
    }
}

task Server_RefreshStorage[1800000]()
{
    for(new i=0; i != MAX_DYNAMIC_JOBS; i++)
    {
        if(JobData[i][jobExists] && JobData[i][jobStock] < 2000)
        {
            JobData[i][jobExists] += 1000;      
        }
    }
    return 1;
}
task Server_PriceUpdate[2400000]()
{
    ServerData[cow_price] = RandomEx(200,350);
    ServerData[deer_price] = RandomEx(100,150);
    ServerData[fish_Price] = RandomFloat(3.5,5.0);
    ServerData[lsd_price] = RandomEx(450,650);
    ServerData[ecs_price] = RandomEx(650,850);
    ServerData[wheat_price] = RandomEx(50, 100);
    return 1;
}

task System_UpdateHouse[900000]()
{
    for(new id = 0; id != MAX_HOUSES; id++)
    { 
        if(HouseData[id][houseExists] && HouseData[id][houseOwner])
        {
            if((gettime()-HouseData[id][houseLastVisited]) > (AUTOSELLDAYS * 86400)) 
            {
                HouseData[id][houseOwner] = 0;
                HouseData[id][houseMoney] = 0;
                HouseData[id][houseLocked] = 1;
                HouseData[id][houseLastVisited] = 0;
                HouseData[id][houseParkingSlotUsed] = 0;

		        mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET state=%d,`house_parking`='-1',`interior` = '0' , `world` = '0' WHERE `state` = '%d' AND `house_parking`='%d';", VEHICLE_STATE_SPAWNED, VEHICLE_STATE_HOUSEPARKED, HouseData[id][houseID]));

                House_RemoveAllItems(id);

                new query[256];
                format(query, sizeof(query), "INSERT INTO `house_queue` SET Username = '%s', Location='%s', Date = UNIX_TIMESTAMP(), ID = '%d'", HouseData[id][houseOwnerName], SQL_ReturnEscaped(GetLocation(HouseData[id][housePos][0], HouseData[id][housePos][1], HouseData[id][housePos][2])), id);
                mysql_tquery(g_iHandle, query);

                format(HouseData[id][houseOwnerName], MAX_PLAYER_NAME, "None");
            }

            House_Refresh(id);
            House_Save(id);
        }
    }
    return 1;
}