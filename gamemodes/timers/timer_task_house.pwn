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