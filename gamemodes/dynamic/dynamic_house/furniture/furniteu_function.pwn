Function:OnLoadFurniture(houseid)
{
    static
        rows,
        fields,
        id = -1;

    cache_get_data(rows, fields);

    for (new i = 0; i != rows; i ++) if((id = Furniture_GetFreeID()) != -1) {
        FurnitureData[id][furnitureExists] = true;
        FurnitureData[id][furnitureHouse] = houseid;

        cache_get_field_content(i, "furnitureName", FurnitureData[id][furnitureName], 32);

        FurnitureData[id][furnitureID] = cache_get_field_int(i, "furnitureID");
        FurnitureData[id][furnitureModel] = cache_get_field_int(i, "furnitureModel");
        FurnitureData[id][furnitureUnused] = cache_get_field_int(i, "furnitureUnused");
        FurnitureData[id][furniturePos][0] = cache_get_field_float(i, "furnitureX");
        FurnitureData[id][furniturePos][1] = cache_get_field_float(i, "furnitureY");
        FurnitureData[id][furniturePos][2] = cache_get_field_float(i, "furnitureZ");
        FurnitureData[id][furnitureRot][0] = cache_get_field_float(i, "furnitureRX");
        FurnitureData[id][furnitureRot][1] = cache_get_field_float(i, "furnitureRY");
        FurnitureData[id][furnitureRot][2] = cache_get_field_float(i, "furnitureRZ");
        // Kasih batasan agar tidak buffer overflow.
        if (i < MAX_HOUSE_FURNITURE)
        {
            HouseData[houseid][furniture][i] = id;
        }

        Furniture_Refresh(id);
    }
    return 1;
}

Furniture_GetCount(houseid)
{
    new count;

    for (new i = 0; i < MAX_FURNITURE; i ++)
    {
        if(FurnitureData[i][furnitureExists] && FurnitureData[i][furnitureHouse] == houseid)
        {
            // SendServerMessage(0, "furnExist: %d | houseid: %d | houseSQLID: %d | houseFurnID: %d | furnHouse: %d | furnSQLID: %d", FurnitureData[i][furnitureExists], houseid, HouseData[houseid][houseID], i, FurnitureData[i][furnitureHouse], FurnitureData[i][furnitureID]);
            count++;
        }
    }
    return count;
}

Furniture_GetFreeID()
{
    for (new i = 0; i != MAX_FURNITURE; i ++)
    {
        if(!FurnitureData[i][furnitureExists])
        {
            return i;
        }
    }
    return -1;
}

Furniture_Update(furnitureid)
{
    if(furnitureid != -1 && FurnitureData[furnitureid][furnitureExists])
    {
        if(FurnitureData[furnitureid][furnitureUnused] == 0) {
            Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FurnitureData[furnitureid][furnitureObject], E_STREAMER_X, FurnitureData[furnitureid][furniturePos][0]);
            Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FurnitureData[furnitureid][furnitureObject], E_STREAMER_Y, FurnitureData[furnitureid][furniturePos][1]);
            Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FurnitureData[furnitureid][furnitureObject], E_STREAMER_Z, FurnitureData[furnitureid][furniturePos][2]);
            Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FurnitureData[furnitureid][furnitureObject], E_STREAMER_R_X, FurnitureData[furnitureid][furnitureRot][0]);
            Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FurnitureData[furnitureid][furnitureObject], E_STREAMER_R_Y, FurnitureData[furnitureid][furnitureRot][1]);
            Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FurnitureData[furnitureid][furnitureObject], E_STREAMER_R_Z, FurnitureData[furnitureid][furnitureRot][2]);

            Streamer_SetIntData(STREAMER_TYPE_OBJECT, FurnitureData[furnitureid][furnitureObject], E_STREAMER_WORLD_ID, HouseData[FurnitureData[furnitureid][furnitureHouse]][houseID] + 5000);
            Streamer_SetIntData(STREAMER_TYPE_OBJECT, FurnitureData[furnitureid][furnitureObject], E_STREAMER_INTERIOR_ID, HouseData[FurnitureData[furnitureid][furnitureHouse]][houseInterior]);
        }
    }
    return 1;
}

Furniture_Refresh(furnitureid)
{
    if(furnitureid != -1 && FurnitureData[furnitureid][furnitureExists])
    {
        if(IsValidDynamicObject(FurnitureData[furnitureid][furnitureObject]))
            DestroyDynamicObject(FurnitureData[furnitureid][furnitureObject]);

        if(FurnitureData[furnitureid][furnitureUnused] == 0)
        {
            FurnitureData[furnitureid][furnitureObject] = CreateDynamicObject(
                FurnitureData[furnitureid][furnitureModel],
                FurnitureData[furnitureid][furniturePos][0],
                FurnitureData[furnitureid][furniturePos][1],
                FurnitureData[furnitureid][furniturePos][2],
                FurnitureData[furnitureid][furnitureRot][0],
                FurnitureData[furnitureid][furnitureRot][1],
                FurnitureData[furnitureid][furnitureRot][2],
                HouseData[FurnitureData[furnitureid][furnitureHouse]][houseID] + 5000,
                HouseData[FurnitureData[furnitureid][furnitureHouse]][houseInterior]
            );
        }
    }
    return 1;
}

Furniture_Save(furnitureid)
{
    static
        string[600];

    format(string, sizeof(string), "UPDATE `furniture` SET `furnitureModel` = '%d', `furnitureName` = '%s', `furnitureX` = '%.4f', `furnitureY` = '%.4f', `furnitureZ` = '%.4f', `furnitureRX` = '%.4f', `furnitureRY` = '%.4f', `furnitureRZ` = '%.4f', `furnitureUnused` = '%d' WHERE `ID` = '%d' AND `furnitureID` = '%d'",
        FurnitureData[furnitureid][furnitureModel],
        SQL_ReturnEscaped(FurnitureData[furnitureid][furnitureName]),
        FurnitureData[furnitureid][furniturePos][0],
        FurnitureData[furnitureid][furniturePos][1],
        FurnitureData[furnitureid][furniturePos][2],
        FurnitureData[furnitureid][furnitureRot][0],
        FurnitureData[furnitureid][furnitureRot][1],
        FurnitureData[furnitureid][furnitureRot][2],
        FurnitureData[furnitureid][furnitureUnused],
        HouseData[FurnitureData[furnitureid][furnitureHouse]][houseID],
        FurnitureData[furnitureid][furnitureID]
    );
    return mysql_tquery(g_iHandle, string);
}

Furniture_Add(houseid, name[], modelid, Float:x, Float:y, Float:z, Float:rx = 0.0, Float:ry = 0.0, Float:rz = 0.0, unused = 1)
{
    new
        string[64],
        id = Furniture_GetFreeID()
    ;

    if(houseid == -1 || !HouseData[houseid][houseExists])
        return 0;

    if(id >= 0)
    {
        FurnitureData[id][furnitureExists] = true;
        format(FurnitureData[id][furnitureName], 32, name);

        FurnitureData[id][furnitureHouse] = houseid;
        FurnitureData[id][furnitureModel] = modelid;
        FurnitureData[id][furniturePos][0] = x;
        FurnitureData[id][furniturePos][1] = y;
        FurnitureData[id][furniturePos][2] = z;
        FurnitureData[id][furnitureRot][0] = rx;
        FurnitureData[id][furnitureRot][1] = ry;
        FurnitureData[id][furnitureRot][2] = rz;
        FurnitureData[id][furnitureUnused] = unused;

        for (new i = 0; i < MAX_HOUSE_FURNITURE; i++)
        {
            //new furnitureid = HouseData[houseid][furniture][i];
            // SendServerMessage(0, "houseid: %d | house SQL ID: %d | housefurnitureid: %d | furniture SQL ID: %d", houseid, HouseData[houseid][houseID], HouseData[houseid][furniture][i], furnitureid >= 0 ? FurnitureData[furnitureid][furnitureID] : -1);

            if(HouseData[houseid][furniture][i] == -1)
            {
                HouseData[houseid][furniture][i] = id;

                Furniture_Refresh(id);

                format(string, sizeof(string), "INSERT INTO `furniture` (`ID`) VALUES(%d)", HouseData[houseid][houseID]);
                mysql_tquery(g_iHandle, string, "OnFurnitureCreated", "d", id);

                return id;
            }
        }
    }
    return -1;
}

Furniture_Delete(furnitureid)
{
    if(furnitureid != -1 && FurnitureData[furnitureid][furnitureExists])
    {
        mysql_tquery(g_iHandle, sprintf("DELETE FROM `furniture` WHERE `ID` = '%d' AND `furnitureID` = '%d'", HouseData[FurnitureData[furnitureid][furnitureHouse]][houseID], FurnitureData[furnitureid][furnitureID]));

        FurnitureData[furnitureid][furnitureExists] = false;
        FurnitureData[furnitureid][furnitureModel] = 0;

        // Mengambil ID rumah berdasarkan furniture-nya.
        new houseid = FurnitureData[furnitureid][furnitureHouse];

        // Looping berdasarkan maksimal furniture rumahnya.
        for (new house_furniture = 0; house_furniture < MAX_HOUSE_FURNITURE; house_furniture++)
        {
            // Jika furniture-nya sama dengan yang ada di slot rumahnya, maka perlu dihapus dari array.
            if (HouseData[houseid][furniture][house_furniture] >= 0 && HouseData[houseid][furniture][house_furniture] == furnitureid)
            {
                HouseData[houseid][furniture][house_furniture] = -1;
                break;
            }
        }
        DestroyDynamicObject(FurnitureData[furnitureid][furnitureObject]);
        FurnitureData[furnitureid][furnitureObject] = INVALID_STREAMER_ID;
    }
    return 1;
}