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
            mysql_tquery(sqlcon, str, "OnLoadWeapon", "d", i);

            format(str, sizeof(str), "SELECT * FROM `housestorage` WHERE `ID` = '%d'", HouseData[i][houseID]);
            mysql_tquery(sqlcon, str, "OnLoadStorage", "d", i);

            format(str, sizeof(str), "SELECT * FROM `furniture` WHERE `ID` = '%d'", HouseData[i][houseID]);
            mysql_tquery(sqlcon, str, "OnLoadFurniture", "d", i);

            format(str, sizeof(str), "SELECT * FROM `clothes_wardrobe` WHERE `houseid` = '%d' LIMIT %d", HouseData[i][houseID], MAX_CLOTHES_WARDROBE);
            mysql_tquery(sqlcon, str, "OnLoadClothes", "d", i);

            format(str, sizeof(str), "SELECT * FROM `accesories_wardrobe` WHERE `houseid` = '%d' LIMIT %d", HouseData[i][houseID], MAX_CLOTHES_WARDROBE);
            mysql_tquery(sqlcon, str, "OnLoadAccesories", "d", i);
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
    return mysql_tquery(sqlcon, query);
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
            format(string, sizeof(string), "[#%d | ID: %d]\n"COL_GREEN"This house for sell\n"WHITE"Address: "YELLOW"%s\n"WHITE"Parking Slot: "YELLOW"%d\n"WHITE"Price: "YELLOW"%s\n"WHITE"Type /buy to purchase", HouseData[houseid][houseID], houseid, GetLocation(HouseData[houseid][housePos][0], HouseData[houseid][housePos][1], HouseData[houseid][housePos][2]), HouseData[houseid][houseParkingSlot], FormatMoney(after_inflation_price));
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
            mysql_tquery(sqlcon, "INSERT INTO `houses` (`houseOwner`) VALUES(0)", "OnHouseCreated", "d", i);
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
        mysql_tquery(sqlcon, sprintf("DELETE FROM `furniture` WHERE `ID` = '%d'", HouseData[houseid][houseID]));
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
        mysql_tquery(sqlcon, string);

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

stock House_WeaponStorage(playerid, houseid)
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

stock House_ShowItems(playerid, houseid)
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
stock House_OpenStorage(playerid, houseid)
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
    format(string, sizeof(string), "Item Storage (%d/%d)\nWeapon Storage (%d/5)\nMoney Safe (%s)", items[0], MAX_HOUSE_STORAGE, items[1], FormatMoney(HouseData[houseid][houseMoney]));
    Dialog_Show(playerid, HouseStorage, DIALOG_STYLE_LIST, "House Storage", string, "Select", "Cancel");
    return 1;
}

stock House_GetItemID(houseid, item[])
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

stock House_AddItem(houseid, item[], model, quantity = 1, slotid = -1)
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
            mysql_tquery(sqlcon, string, "OnStorageAdd", "dd", houseid, itemid);

            return itemid;
        }
        return -1;
    }
    else
    {
        format(string, sizeof(string), "UPDATE `housestorage` SET `itemQuantity` = `itemQuantity` + %d WHERE `ID` = '%d' AND `itemID` = '%d'", quantity, HouseData[houseid][houseID], HouseStorage[houseid][itemid][hItemID]);
        mysql_tquery(sqlcon, string);

        HouseStorage[houseid][itemid][hItemQuantity] += quantity;
    }
    return itemid;
}

stock House_RemoveItem(houseid, item[], quantity = 1)
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
            mysql_tquery(sqlcon, string);
        }
        else if(quantity != -1 && HouseStorage[houseid][itemid][hItemQuantity] > 0)
        {
            format(string, sizeof(string), "UPDATE `housestorage` SET `itemQuantity` = `itemQuantity` - %d WHERE `ID` = '%d' AND `itemID` = '%d'", quantity, HouseData[houseid][houseID], HouseStorage[houseid][itemid][hItemID]);
            mysql_tquery(sqlcon, string);
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
    mysql_tquery(sqlcon, sprintf("DELETE FROM `housestorage` WHERE `ID` = '%d'", HouseData[houseid][houseID]));

    for (new i = 0; i < 5; i ++) {
        HouseData[houseid][houseWeapons][i] = 0;
        HouseData[houseid][houseAmmo][i] = 0;
        HouseData[houseid][houseDurability][i] = 0;
        HouseData[houseid][houseWeaponSlot][i] = -1;
        HouseData[houseid][houseSerial][i] = 0;
    }
    mysql_tquery(sqlcon, sprintf("DELETE FROM `weapon_houses` WHERE `houseid` = '%d'", HouseData[houseid][houseID]));
    return 1;
}

Function:OnHouseCreated(houseid)
{
    if(houseid == -1 || !HouseData[houseid][houseExists])
        return 0;

    HouseData[houseid][houseID] = cache_insert_id();
    House_Save(houseid);

    return 1;
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

Dialog:HouseWeapons(playerid, response, listitem, inputtext[])
{
    new
        houseid;

    if((houseid = House_Inside(playerid)) != -1 && (House_IsOwner(playerid, houseid) || GetAdminLevel(playerid) >= 5))
    {
        if(response)
        {
            if(HouseData[houseid][houseWeapons][listitem] != 0)
            {
                if(IsPlayerDuty(playerid))
                    return SendErrorMessage(playerid, "Duty faction tidak dapat mengambil senjata.");

                if(PlayerHasWeapon(playerid, HouseData[houseid][houseWeapons][listitem]))
                    return SendErrorMessage(playerid, "Kamu sudah memiliki senjata yang sama.");

                if(PlayerHasWeaponInSlot(playerid, HouseData[houseid][houseWeapons][listitem]))
                    return SendErrorMessage(playerid, "Senjata ini berada satu slot dengan senjata yang kamu punya.");

                new serial[64];
                valstr(serial, HouseData[houseid][houseSerial][listitem]);

                GivePlayerWeaponEx(playerid, HouseData[houseid][houseWeapons][listitem], HouseData[houseid][houseAmmo][listitem], HouseData[houseid][houseDurability][listitem], serial);
                mysql_tquery(sqlcon, sprintf("DELETE FROM `weapon_houses` WHERE `houseid` = '%d' AND `ammo`='%d' AND `weaponid`='%d' AND `durability`='%d' AND `slot` = '%d';", HouseData[houseid][houseID], HouseData[houseid][houseAmmo][listitem], HouseData[houseid][houseWeapons][listitem], HouseData[houseid][houseDurability][listitem], HouseData[houseid][houseWeaponSlot][listitem]));


                SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has taken a \"%s\" from their weapon storage.", ReturnName(playerid, 0), ReturnWeaponName(HouseData[houseid][houseWeapons][listitem]));

                Log_Save(E_LOG_HOUSE_ITEMS, sprintf("[%s] %s has taken (w: %s a: %d, d: %d) from house id: %d (owned: %s).", ReturnDate(), ReturnName(playerid, 0), ReturnWeaponName(HouseData[houseid][houseWeapons][listitem]), HouseData[houseid][houseAmmo][listitem], HouseData[houseid][houseDurability][listitem], HouseData[houseid][houseID], (House_IsOwner(playerid, houseid)) ? ("Yes") : ("No")));
                //Discord_Log(HOUSEITEMSLOG, sprintf("%s has taken (w: %s a: %d, d: %d) from house id: %d (owned: %s).", ReturnName(playerid, 0), ReturnWeaponName(HouseData[houseid][houseWeapons][listitem]), HouseData[houseid][houseAmmo][listitem], HouseData[houseid][houseDurability][listitem], HouseData[houseid][houseID], (House_IsOwner(playerid, houseid)) ? ("Yes") : ("No")));

                HouseData[houseid][houseWeapons][listitem]      = 0;
                HouseData[houseid][houseAmmo][listitem]         = 0;
                HouseData[houseid][houseDurability][listitem]   = 0;
                HouseData[houseid][houseWeaponSlot][listitem]   = -1;
                HouseData[houseid][houseSerial][listitem]       = 0;

                House_WeaponStorage(playerid, houseid);
            }
            else
            {
                new
                    weaponid = GetWeapon(playerid),
                    ammo = ReturnWeaponAmmo(playerid, weaponid),
                    durability = ReturnWeaponDurability(playerid, weaponid),
                    serialnumber = ReturnWeaponSerial(playerid, weaponid)
                ;

                if(!House_IsOwner(playerid, houseid))
                    return SendErrorMessage(playerid, "Hanya pemilik rumah yang dapat meletakkan senjata!");

                if(IsPlayerDuty(playerid))
                    return SendErrorMessage(playerid, "Duty faction tidak dapat menyimpan senjata.");

                if(!weaponid)
                    return SendErrorMessage(playerid, "You are not holding any weapon!");

                HouseData[houseid][houseWeapons][listitem] = weaponid;
                HouseData[houseid][houseAmmo][listitem] = ammo;
                HouseData[houseid][houseDurability][listitem] = durability;
                HouseData[houseid][houseWeaponSlot][listitem] = listitem;
                HouseData[houseid][houseSerial][listitem] = serialnumber;

                mysql_tquery(sqlcon, sprintf("INSERT INTO `weapon_houses`(`houseid`, `weaponid`, `ammo`, `durability`, `slot`, `serial`) VALUES ('%d','%d','%d','%d', '%d', '%d');", HouseData[houseid][houseID], weaponid, ammo, durability, listitem, serialnumber));

                ResetWeaponID(playerid, weaponid);
                House_WeaponStorage(playerid, houseid);

                SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has stored a \"%s\" into their weapon storage.", ReturnName(playerid, 0), ReturnWeaponName(weaponid));

                Log_Save(E_LOG_HOUSE_ITEMS, sprintf("[%s] %s has stored (w: %s a: %d, d: %d) from house id: %d (owned: %s).", ReturnDate(), ReturnName(playerid, 0), ReturnWeaponName(weaponid), ammo, durability, HouseData[houseid][houseID], (House_IsOwner(playerid, houseid)) ? ("Yes") : ("No")));
                //Discord_Log(HOUSEITEMSLOG, sprintf("%s has stored (w: %s a: %d, d: %d) from house id: %d (owned: %s).", ReturnName(playerid, 0), ReturnWeaponName(weaponid), ammo, durability, HouseData[houseid][houseID], (House_IsOwner(playerid, houseid)) ? ("Yes") : ("No")));
            }
        }
        else House_OpenStorage(playerid, houseid);
    }
    return 1;
}

Dialog:HouseDeposit(playerid, response, listitem, inputtext[])
{
    new
        houseid,
        string[32];

    if((houseid = House_Inside(playerid)) != -1)
    {
        if(!House_IsOwner(playerid, houseid))
            return SendErrorMessage(playerid, "Hanya pemilik rumah yang dapat menyimpan uang!");

        strunpack(string, InventoryData[playerid][PlayerData[playerid][pInventoryItem]][invItem]);

        if(response)
        {
            new amount = strval(inputtext);

            if(amount < 1 || amount > InventoryData[playerid][PlayerData[playerid][pInventoryItem]][invQuantity])
                return Dialog_Show(playerid, HouseDeposit, DIALOG_STYLE_INPUT, "House Deposit", "Item: %s (Quantity: %d)\n\nPlease enter the quantity that you wish to store for this item:", "Store", "Back", string, InventoryData[playerid][PlayerData[playerid][pInventoryItem]][invQuantity]);

            House_AddItem(houseid, string, InventoryData[playerid][PlayerData[playerid][pInventoryItem]][invModel], amount);
            Inventory_Remove(playerid, string, amount);

            House_ShowItems(playerid, houseid);
            SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has stored a \"%s\" into their house storage.", ReturnName(playerid, 0), string);

            Log_Save(E_LOG_HOUSE_ITEMS, sprintf("[%s] %s has stored %d \"%s\" from their house storage id: %d (owned: %s).", ReturnDate(), ReturnName(playerid, 0), amount, string, HouseData[houseid][houseID], (House_IsOwner(playerid, houseid)) ? ("Yes") : ("No")));
            //Discord_Log(HOUSEITEMSLOG, sprintf("%s has stored %d \"%s\" from their house storage id: %d (owned: %s).", ReturnName(playerid, 0), amount, string, HouseData[houseid][houseID], (House_IsOwner(playerid, houseid)) ? ("Yes") : ("No")));
        }
        else House_OpenStorage(playerid, houseid);
    }
    return 1;
}

Dialog:HouseTake(playerid, response, listitem, inputtext[])
{
    new
        houseid,
        string[32];

    if((houseid = House_Inside(playerid)) != -1 && (House_IsOwner(playerid, houseid) || GetAdminLevel(playerid) >= 5))
    {
        strunpack(string, HouseStorage[houseid][PlayerData[playerid][pStorageItem]][hItemName]);

        if(response)
        {
            new amount = strval(inputtext);

            if(amount < 1 || amount > HouseStorage[houseid][PlayerData[playerid][pStorageItem]][hItemQuantity])
                return Dialog_Show(playerid, HouseTake, DIALOG_STYLE_INPUT, "House Take", "Item: %s (Quantity: %d)\n\nPlease enter the quantity that you wish to take for this item:", "Take", "Back", string, HouseStorage[houseid][PlayerData[playerid][pInventoryItem]][hItemQuantity]);

            for (new i = 0; i < sizeof(g_aInventoryItems); i ++) if(!strcmp(g_aInventoryItems[i][e_InventoryItem], string, true)) {
                if((Inventory_Count(playerid, g_aInventoryItems[i][e_InventoryItem])+amount) > g_aInventoryItems[i][e_InventoryMax])
                    return Dialog_Show(playerid, HouseTake, DIALOG_STYLE_INPUT, "House Take", "Item: %s (Quantity: %d)\n\nPlease enter the quantity that you wish to take for this item:\n(You can take %d %s now!)", "Take", "Back", string, HouseStorage[houseid][PlayerData[playerid][pInventoryItem]][hItemQuantity], (g_aInventoryItems[i][e_InventoryMax]-Inventory_Count(playerid, g_aInventoryItems[i][e_InventoryItem])), string);
            }

            if(Inventory_Add(playerid, string, HouseStorage[houseid][PlayerData[playerid][pStorageItem]][hItemModel], amount) != -1)
            {
                House_RemoveItem(houseid, string, amount);
                SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has taken a \"%s\" from their house storage.", ReturnName(playerid, 0), string);

                House_ShowItems(playerid, houseid);

                Log_Save(E_LOG_HOUSE_ITEMS, sprintf("[%s] %s has taken %d \"%s\" from their house storage id: %d (owned: %s).", ReturnDate(), ReturnName(playerid, 0), amount, string, HouseData[houseid][houseID], (House_IsOwner(playerid, houseid)) ? ("Yes") : ("No")));
                //Discord_Log(HOUSEITEMSLOG, sprintf("%s has taken %d \"%s\" from their house storage id: %d (owned: %s).", ReturnName(playerid, 0), amount, string, HouseData[houseid][houseID], (House_IsOwner(playerid, houseid)) ? ("Yes") : ("No")));
            }
        }
        else House_OpenStorage(playerid, houseid);
    }
    return 1;
}

Dialog:HouseWithdrawCash(playerid, response, listitem, inputtext[])
{
    new
        houseid;

    if((houseid = House_Inside(playerid)) != -1 && (House_IsOwner(playerid, houseid) || GetAdminLevel(playerid) >= 5))
    {
        if(response)
        {
            new amount = strval(inputtext);

            if(isnull(inputtext))
                return Dialog_Show(playerid, HouseWithdrawCash, DIALOG_STYLE_INPUT, "Withdraw from safe", "Safe Balance: %s\n\nPlease enter how much money you wish to withdraw from the safe:", "Withdraw", "Back", FormatMoney(HouseData[houseid][houseMoney]));

            if(amount < 1 || amount > HouseData[houseid][houseMoney])
                return Dialog_Show(playerid, HouseWithdrawCash, DIALOG_STYLE_INPUT, "Withdraw from safe", "Error: Insufficient funds.\n\nSafe Balance: %s\n\nPlease enter how much money you wish to withdraw from the safe:", "Withdraw", "Back", FormatMoney(HouseData[houseid][houseMoney]));

            HouseData[houseid][houseMoney] -= amount;
            GiveMoney(playerid, amount);

            House_Save(houseid);
            House_OpenStorage(playerid, houseid);

            SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has withdrawn %s from their house safe.", ReturnName(playerid, 0), FormatMoney(amount));

            Log_Save(E_LOG_HOUSE_SAFE, sprintf("[%s] %s has withdrawn \"%s\" (current safe: %s) from their house id: %d.", ReturnDate(), ReturnName(playerid, 0), FormatMoney(amount), FormatMoney(HouseData[houseid][houseMoney]), HouseData[houseid][houseID]));
            //Discord_Log(HOUSESAFELOG, sprintf("%s has withdrawn \"%s\" (current safe: %s) from their house id: %d.", ReturnName(playerid, 0), FormatMoney(amount), FormatMoney(HouseData[houseid][houseMoney]), HouseData[houseid][houseID]));
        }
        else Dialog_Show(playerid, HouseMoney, DIALOG_STYLE_LIST, "Money Safe", "Withdraw from safe\nDeposit into safe", "Select", "Back");
    }
    return 1;
}

Dialog:HouseDepositCash(playerid, response, listitem, inputtext[])
{
    new
        houseid;

    if((houseid = House_Inside(playerid)) != -1 && House_IsOwner(playerid, houseid))
    {
        if(response)
        {
            new amount = strval(inputtext);

            if(isnull(inputtext))
                return Dialog_Show(playerid, HouseDepositCash, DIALOG_STYLE_INPUT, "Deposit into safe", "Safe Balance: %s\n\nPlease enter how much money you wish to deposit into the safe:", "Withdraw", "Back", FormatMoney(HouseData[houseid][houseMoney]));

            if(amount < 1 || amount > GetMoney(playerid))
                return Dialog_Show(playerid, HouseDepositCash, DIALOG_STYLE_INPUT, "Deposit into safe", "Error: Insufficient funds.\n\nSafe Balance: %s\n\nPlease enter how much money you wish to deposit into the safe:", "Withdraw", "Back", FormatMoney(HouseData[houseid][houseMoney]));

            HouseData[houseid][houseMoney] += amount;
            GiveMoney(playerid, -amount);

            House_Save(houseid);
            House_OpenStorage(playerid, houseid);

            SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has deposited %s into their house safe.", ReturnName(playerid, 0), FormatMoney(amount));
            Log_Save(E_LOG_HOUSE_SAFE, sprintf("[%s] %s has deposited \"%s\" (current safe: %s) into their house id: %d.", ReturnDate(), ReturnName(playerid, 0), FormatMoney(amount), FormatMoney(HouseData[houseid][houseMoney]), HouseData[houseid][houseID]));
            //Discord_Log(HOUSESAFELOG, sprintf("%s has deposited \"%s\" (current safe: %s) into their house id: %d.", ReturnName(playerid, 0), FormatMoney(amount), FormatMoney(HouseData[houseid][houseMoney]), HouseData[houseid][houseID]));
        }
        else Dialog_Show(playerid, HouseMoney, DIALOG_STYLE_LIST, "Money Safe", "Withdraw from safe\nDeposit into safe", "Select", "Back");
    }
    return 1;
}

Dialog:HouseMoney(playerid, response, listitem, inputtext[])
{
    new
        houseid;

    if((houseid = House_Inside(playerid)) != -1 && House_IsOwner(playerid, houseid) || GetAdminLevel(playerid) >= 8)
    {
        if(response)
        {
            switch (listitem)
            {
                case 0: Dialog_Show(playerid, HouseWithdrawCash, DIALOG_STYLE_INPUT, "Withdraw from safe", "Safe Balance: %s\n\nPlease enter how much money you wish to withdraw from the safe:", "Withdraw", "Back", FormatMoney(HouseData[houseid][houseMoney]));
                case 1: Dialog_Show(playerid, HouseDepositCash, DIALOG_STYLE_INPUT, "Deposit into safe", "Safe Balance: %s\n\nPlease enter how much money you wish to deposit into the safe:", "Withdraw", "Back", FormatMoney(HouseData[houseid][houseMoney]));
            }
        }
        else House_OpenStorage(playerid, houseid);
    }
    return 1;
}

Dialog:HouseItems(playerid, response, listitem, inputtext[])
{
    new
        houseid,
        string[64];

    if((houseid = House_Inside(playerid)) != -1 && (House_IsOwner(playerid, houseid) || GetAdminLevel(playerid) >= 5))
    {
        if(response)
        {
            if(HouseStorage[houseid][listitem][hItemExists])
            {
                PlayerData[playerid][pStorageItem] = listitem;
                PlayerData[playerid][pInventoryItem] = listitem;

                strunpack(string, HouseStorage[houseid][listitem][hItemName]);

                format(string, sizeof(string), "%s (Quantity: %d)", string, HouseStorage[houseid][listitem][hItemQuantity]);
                Dialog_Show(playerid, StorageOptions, DIALOG_STYLE_LIST, string, "Take Item\nStore Item", "Select", "Back");
            }
            else
            {
                if(!House_IsOwner(playerid, houseid))
                    return SendErrorMessage(playerid, "Hanya pemilik rumah yang dapat meletakkan item!");

                OpenInventory(playerid);
                PlayerData[playerid][pStorageSelect] = 1;
            }
        }
        else House_OpenStorage(playerid, houseid);
    }
    return 1;
}

Dialog:HouseStorage(playerid, response, listitem, inputtext[])
{
    new
        houseid = -1;

    if((houseid = House_Inside(playerid)) != -1 && (House_IsOwner(playerid, houseid) || GetAdminLevel(playerid) >= 5 || GetFactionType(playerid) == FACTION_POLICE))
    {
        if(response)
        {
            if(listitem == 0)
            {
                House_ShowItems(playerid, houseid);
            }
            else if(listitem == 1)
            {
                if(PlayerData[playerid][pScore] < 2)
                    return SendErrorMessage(playerid, "You're not allowed to accese this storage if you're not level 2.");

                House_WeaponStorage(playerid, houseid);
            }
            else if(listitem == 2)
            {
                Dialog_Show(playerid, HouseMoney, DIALOG_STYLE_LIST, "Money Safe", "Withdraw from safe\nDeposit into safe", "Select", "Back");
            }
        }
    }
    else SendServerMessage(playerid, "Hanya dapat melihat isi penyimpanan, tidak dapat mengoperasikan isi didalamnya!");

    return 1;
}

Dialog:StorageOptions(playerid, response, listitem, inputtext[])
{
    new
        houseid = -1,
        itemid = -1,
//        backpack = -1,
        string[32];

    if((houseid = House_Inside(playerid)) != -1 && (House_IsOwner(playerid, houseid) || GetAdminLevel(playerid) >= 5))
    {
        itemid = PlayerData[playerid][pStorageItem];

        strunpack(string, HouseStorage[houseid][itemid][hItemName]);

        if(response)
        {
            switch (listitem)
            {
                case 0:
                {
                    if(HouseStorage[houseid][itemid][hItemQuantity] == 1)
                    {
                        if(!strcmp(string, "Backpack") && Inventory_HasItem(playerid, "Backpack"))
                            return SendErrorMessage(playerid, "You already have a backpack in your inventory.");

                        for (new i = 0; i < sizeof(g_aInventoryItems); i ++) if(!strcmp(g_aInventoryItems[i][e_InventoryItem], string, true)) {
                            if((Inventory_Count(playerid, g_aInventoryItems[i][e_InventoryItem])+1) > g_aInventoryItems[i][e_InventoryMax])
                                return SendErrorMessage(playerid, "You're limited %d for %s.", g_aInventoryItems[i][e_InventoryMax], string);
                        }

                        if(Inventory_Add(playerid, string, HouseStorage[houseid][itemid][hItemModel], 1) != -1)
                        {
                            House_RemoveItem(houseid, string);
                            SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has taken a \"%s\" from their house storage.", ReturnName(playerid, 0), string);

                            House_ShowItems(playerid, houseid);
                            Log_Save(E_LOG_STORAGE, sprintf("[%s] %s has taken \"%s\" from house ID: %d.", ReturnDate(), ReturnName(playerid, 0), string, houseid));
                        }
                    }
                    else
                    {
                        Dialog_Show(playerid, HouseTake, DIALOG_STYLE_INPUT, "House Take", "Item: %s (Quantity: %d)\n\nPlease enter the quantity that you wish to take for this item:", "Take", "Back", string, HouseStorage[houseid][itemid][hItemQuantity]);
                    }
                }
                case 1:
                {
                    if(!House_IsOwner(playerid, houseid))
                        return SendErrorMessage(playerid, "Hanya pemilik rumah yang dapat meletakkan item!");

                    new id = Inventory_GetItemID(playerid, string);

                    if(id == -1) {
                        House_ShowItems(playerid, houseid);

                        return SendErrorMessage(playerid, "You don't have anymore of this item to store!");
                    }
                    else if(InventoryData[playerid][id][invQuantity] == 1)
                    {
                        House_AddItem(houseid, string, InventoryData[playerid][id][invModel]);
                        Inventory_Remove(playerid, string);

                        SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has stored a \"%s\" into their house storage.", ReturnName(playerid, 0), string);
                        Log_Save(E_LOG_STORAGE, sprintf("[%s] %s has stored \"%s\" into their house ID: %d.", ReturnDate(), ReturnName(playerid, 0), string, houseid));
                        House_ShowItems(playerid, houseid);
                    }
                    else if(InventoryData[playerid][id][invQuantity] > 1) {
                        PlayerData[playerid][pInventoryItem] = id;

                        Dialog_Show(playerid, HouseDeposit, DIALOG_STYLE_INPUT, "House Deposit", "Item: %s (Quantity: %d)\n\nPlease enter the quantity that you wish to store for this item:", "Store", "Back", string, InventoryData[playerid][id][invQuantity]);
                    }
                }
            }
        }
        else
        {
            House_ShowItems(playerid, houseid);
        }
    }
    return 1;
}
