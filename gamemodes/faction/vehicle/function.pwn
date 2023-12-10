stock FactionVehicle_Create(factionid, model, Float:x, Float:y, Float:z, Float:a, color1, color2)
{
	forex(i, MAX_FACTION_VEHICLE) if(!FactionVehicle[i][fvExists])
	{
		FactionVehicle[i][fvPos][0] = x;
		FactionVehicle[i][fvPos][1] = y;
		FactionVehicle[i][fvPos][2] = z;
		FactionVehicle[i][fvPos][3] = a;
		FactionVehicle[i][fvColor][0] = color1;
		FactionVehicle[i][fvColor][1] = color2;
		FactionVehicle[i][fvModel] = model;
		FactionVehicle[i][fvExists] = true;
		FactionVehicle[i][fvFaction] = factionid;

		FactionVehicle[i][fvVehicle] = CreateVehicle(model, x, y, z, a, color1, color2, 60000);
		VehCore[FactionVehicle[i][fvVehicle]][vehFuel] = 100;
		
		mysql_tquery(sqlcon, "INSERT INTO `faction_vehicle` (`Model`) VALUES(0)", "OnFactionVehicleCreated", "d", i);
		return 1;
	}
	return -1;
}

FUNC::OnFactionVehicleCreated(id)
{
	FactionVehicle[id][fvID] = cache_insert_id();
	FactionVehicle_Save(id);
}

stock FactionVehicle_Save(id)
{

	if(!FactionVehicle[id][fvExists])
		return 0;
	new query[1012];
	mysql_format(sqlcon, query, sizeof(query), "UPDATE `faction_vehicle` SET ");
	mysql_format(sqlcon, query, sizeof(query), "%s`Model` = '%d', ", query,FactionVehicle[id][fvModel]);
	mysql_format(sqlcon, query, sizeof(query), "%s`PosX` = '%f', ", query, FactionVehicle[id][fvPos][0]);
	mysql_format(sqlcon, query, sizeof(query), "%s`PosY` = '%f', ", query,FactionVehicle[id][fvPos][1]);
	mysql_format(sqlcon, query, sizeof(query), "%s`PosZ` = '%f', ", query,FactionVehicle[id][fvPos][2]);
	mysql_format(sqlcon, query, sizeof(query), "%s`PosA` = '%f', ", query,FactionVehicle[id][fvPos][3]);
	mysql_format(sqlcon, query, sizeof(query), "%s`Color1` = '%d', ", query,FactionVehicle[id][fvColor][0]);
	mysql_format(sqlcon, query, sizeof(query), "%s`Color2` = '%d', ", query,FactionVehicle[id][fvColor][1]);
	mysql_format(sqlcon, query, sizeof(query), "%s`Faction` = '%d' ", query,FactionVehicle[id][fvFaction]);
	mysql_format(sqlcon, query, sizeof(query), "%sWHERE `ID` = '%d'", query, FactionVehicle[id][fvID]);
	mysql_query(sqlcon, query, true);
	return 1;
}

FUNC::FactionVehicle_Load(id)
{
	if(cache_num_rows())
	{
		forex(i, cache_num_rows())
		{
			FactionVehicle[i][fvExists] = true;
			cache_get_value_name_int(i, "ID", FactionVehicle[i][fvID]);
			cache_get_value_name_int(i, "Model", FactionVehicle[i][fvModel]);
			cache_get_value_name_float(i, "PosX", FactionVehicle[i][fvPos][0]);
			cache_get_value_name_float(i, "PosY", FactionVehicle[i][fvPos][1]);
			cache_get_value_name_float(i, "PosZ", FactionVehicle[i][fvPos][2]);
			cache_get_value_name_float(i, "PosA", FactionVehicle[i][fvPos][3]);
			cache_get_value_name_int(i, "Color1", FactionVehicle[i][fvColor][0]);
			cache_get_value_name_int(i, "Color2", FactionVehicle[i][fvColor][1]);
			cache_get_value_name_int(i, "Faction", FactionVehicle[i][fvFaction]);

			FactionVehicle[i][fvVehicle] = CreateVehicle(FactionVehicle[i][fvModel], FactionVehicle[i][fvPos][0], FactionVehicle[i][fvPos][1], FactionVehicle[i][fvPos][2], FactionVehicle[i][fvPos][3], FactionVehicle[i][fvColor][0], FactionVehicle[i][fvColor][1], 60000);
			VehCore[FactionVehicle[i][fvVehicle]][vehFuel] = 100;
		}
		printf("[FACTION VEHICLE] Loaded %d faction vehicle from database", cache_num_rows());
	}
	return 1;
}

stock FactionVehicle_Delete(id)
{
	new query[128];
	mysql_format(sqlcon, query, 128, "DELETE FROM `faction_vehicle` WHERE `ID` = '%d'", FactionVehicle[id][fvID]);
	mysql_query(sqlcon, query, true);

	if(IsValidVehicle(FactionVehicle[id][fvVehicle]))
		DestroyVehicle(FactionVehicle[id][fvVehicle]);

	FactionVehicle[id][fvExists] = false;
	FactionVehicle[id][fvModel] = 0;
	return 1;
}
stock IsFactionVehicle(vehicleid)
{
	forex(i, MAX_FACTION_VEHICLE) if(FactionVehicle[i][fvExists] && FactionVehicle[i][fvVehicle] == vehicleid)
		return i;

	return -1;
}