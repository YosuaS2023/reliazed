stock ShowNumberIndex(playerid)
{
	new str[256];

	forex(i, 5)
	{
		NumberIndex[playerid][i] = RandomEx(11111, 98888);
		format(str, sizeof(str), "%s{FFFF00}%d\n", str, NumberIndex[playerid][i]);
	}
	format(str, sizeof(str), "%s{FF0000}Refresh Number List", str);
	ShowPlayerDialog(playerid, DIALOG_NUMBERPHONE, DIALOG_STYLE_LIST, "Select Phone Number", str, "Select", "Close");
	return 1;
}

stock ShowBizStats(playerid)
{
	new id = PlayerData[playerid][pInBiz];
	if(id == -1)
		return 0;

	new str[512];
	strcat(str, "Name\tInfo\n");
	strcat(str, sprintf("Business Name:\t%s\n", BusinessData[id][bizName]));
	strcat(str, sprintf("Business Type:\t%s\n", GetBizType(BusinessData[id][bizType])));
	strcat(str, sprintf("Available stock:\t%d left\n", BusinessData[id][bizStock]));
	strcat(str, sprintf("Cash Vault:\t$%s\t", FormatMoney(BusinessData[id][bizVault])));
	Dialog_Show(playerid, OnlyShow, DIALOG_STYLE_TABLIST_HEADERS, "Business Stats", str, "Close", "");
	return 1;
}

stock Biz_GetCount(playerid)
{
	new count = 0;
	forex(i, MAX_BUSINESSES) if(BusinessData[i][bizExists] && BusinessData[i][bizOwner] == PlayerData[playerid][pID])
	{
	    count++;
	}
	return count;
}

stock SetProductName(playerid)
{
	new bid = PlayerData[playerid][pInBiz], string[712];
	if(!BusinessData[bid][bizExists])
	    return 0;

	switch(BusinessData[bid][bizType])
	{
	    case 1:
	    {
	        format(string, sizeof(string), "Product\tPrice\n%s (Food +20)\t$%s\n%s (Food +40)\t$%s\n%s (Drink)\t$%s",
				ProductName[bid][0],
				FormatMoney(BusinessData[bid][bizProduct][0]),
				ProductName[bid][1],
	            FormatMoney(BusinessData[bid][bizProduct][1]),
	            ProductName[bid][2],
	            FormatMoney(BusinessData[bid][bizProduct][2])
			);
		}
		case 2:
		{
		    format(string, sizeof(string), "Product\tPrice\n%s\t$%s\n%s\t$%s\n%s\t$%s\n%s\t$%s\n%s\t$%s\n%s\t$%s\n%s\t$%s",
                ProductName[bid][0],
				FormatMoney(BusinessData[bid][bizProduct][0]),
				ProductName[bid][1],
	            FormatMoney(BusinessData[bid][bizProduct][1]),
	            ProductName[bid][2],
	            FormatMoney(BusinessData[bid][bizProduct][2]),
	            ProductName[bid][3],
	            FormatMoney(BusinessData[bid][bizProduct][3]),
	        	ProductName[bid][4],
	            FormatMoney(BusinessData[bid][bizProduct][4]),
	        	ProductName[bid][5],
	            FormatMoney(BusinessData[bid][bizProduct][5]),
	            ProductName[bid][6],
	            FormatMoney(BusinessData[bid][bizProduct][6])
			);
		}
		case 3:
		{
		    format(string, sizeof(string), "Product\tPrice\n%s (Clothes)\t$%s\n%s (Accessory)\t$%s",
                ProductName[bid][0],
		        FormatMoney(BusinessData[bid][bizProduct][0]),
                ProductName[bid][1],
		        FormatMoney(BusinessData[bid][bizProduct][1])
			);
		}
		case 4:
		{
		    format(string, sizeof(string), "Product\tPrice\n%s (Cellphone)\t$%s\n%s (GPS)\t$%s\n%s (Radio)\t$%s\n%s (Phone Credit)\t$%s",
                ProductName[bid][0],
				FormatMoney(BusinessData[bid][bizProduct][0]),
				ProductName[bid][1],
	            FormatMoney(BusinessData[bid][bizProduct][1]),
	            ProductName[bid][2],
	            FormatMoney(BusinessData[bid][bizProduct][2]),
	            ProductName[bid][3],
	            FormatMoney(BusinessData[bid][bizProduct][3])
			);
		}
	}
	ShowPlayerDialog(playerid, DIALOG_BIZPROD, DIALOG_STYLE_TABLIST_HEADERS, "Set Product Name", string, "Select", "Close");
	return 1;
}

stock Business_Create(playerid, type, price)
{
	new
	    Float:x,
	    Float:y,
	    Float:z;

	if (GetPlayerPos(playerid, x, y, z))
	{
		forex(i, MAX_BUSINESSES)
		{
	    	if (!BusinessData[i][bizExists])
		    {
    	        BusinessData[i][bizExists] = true;
        	    BusinessData[i][bizOwner] = -1;
            	BusinessData[i][bizPrices] = price;
            	BusinessData[i][bizType] = type;

				format(BusinessData[i][bizName], 32, "None Business");
				format(BusinessData[i][bizOwnerName], MAX_PLAYER_NAME, "No Owner");
    	        BusinessData[i][bizExt][0] = x;
    	        BusinessData[i][bizExt][1] = y;
    	        BusinessData[i][bizExt][2] = z;

				if (type == 1)
				{
                	BusinessData[i][bizInt][0] = 363.22;
                	BusinessData[i][bizInt][1] = -74.86;
                	BusinessData[i][bizInt][2] = 1001.50;
					BusinessData[i][bizInterior] = 10;
					format(ProductName[i][0], 24, "French Fries");
					format(ProductName[i][1], 24, "Fried Chicken");
					format(ProductName[i][2], 24, "Coca Cola");
				}
				else if (type == 2)
				{
                	BusinessData[i][bizInt][0] = 5.73;
                	BusinessData[i][bizInt][1] = -31.04;
                	BusinessData[i][bizInt][2] = 1003.54;
					BusinessData[i][bizInterior] = 10;
					format(ProductName[i][0], 24, "Chitato");
					format(ProductName[i][1], 24, "Danone Mineral");
					format(ProductName[i][2], 24, "Mask");
					format(ProductName[i][3], 24, "First Aid");
					format(ProductName[i][4], 24, "Rolling Paper");
					format(ProductName[i][5], 24, "Axe");
					format(ProductName[i][6], 24, "Fish Rod");
				}
				else if(type == 3)
				{
                	BusinessData[i][bizInt][0] = 207.55;
                	BusinessData[i][bizInt][1] = -110.67;
                	BusinessData[i][bizInt][2] = 1005.13;
					BusinessData[i][bizInterior] = 15;
					format(ProductName[i][0], 24, "Clothes");
					format(ProductName[i][1], 24, "Accessory");
				}
				else if(type == 4)
				{
                	BusinessData[i][bizInt][0] = -2240.7825;
                	BusinessData[i][bizInt][1] = 137.1855;
                	BusinessData[i][bizInt][2] = 1035.4141;
					BusinessData[i][bizInterior] = 6;
					format(ProductName[i][0], 24, "Huawei Mate");
					format(ProductName[i][1], 24, "GPS");
					format(ProductName[i][2], 24, "Walkie Talkie");
					format(ProductName[i][3], 24, "Electric Credit");
				}
				forex(e, 7)
				{
					format(ProductDescription[i][e], 40, "No description");
				}
				BusinessData[i][bizVault] = 0;
				BusinessData[i][bizStock] = 100;
				BusinessData[i][bizCargo] = 10000;
				BusinessData[i][bizFuel] = 1000;
				BusinessData[i][bizDiesel] = 1000;
				BusinessData[i][bizLocked] = true;
				Business_Spawn(i);
				mysql_tquery(sqlcon, "INSERT INTO `business` (`bizOwner`) VALUES(0)", "OnBusinessCreated", "d", i);
				return i;
			}
		}
	}
	return -1;
}

stock Biz_IsOwner(playerid, id)
{
	if(!BusinessData[id][bizExists])
	    return 0;
	    
	if(BusinessData[id][bizOwner] == PlayerData[playerid][pID])
		return 1;
		
	return 0;
}

FUNC::OnBusinessCreated(bizid)
{
	if (bizid == -1 || !BusinessData[bizid][bizExists])
	    return 0;

	BusinessData[bizid][bizID] = cache_insert_id();
	BusinessData[bizid][bizWorld] = BusinessData[bizid][bizID]+1000;
	
	Business_Save(bizid);
	return 1;
}

FUNC::Business_Load()
{
	new rows = cache_num_rows(), str[128], desc[312];
 	if(rows)
  	{
		forex(i, rows)
		{
		    BusinessData[i][bizExists] = true;
		    cache_get_value_name(i, "bizName", BusinessData[i][bizName]);
		    cache_get_value_name_int(i, "bizOwner", BusinessData[i][bizOwner]);
		    cache_get_value_name_int(i, "bizID", BusinessData[i][bizID]);
		    cache_get_value_name_float(i, "bizExtX", BusinessData[i][bizExt][0]);
		    cache_get_value_name_float(i, "bizExtY", BusinessData[i][bizExt][1]);
		    cache_get_value_name_float(i, "bizExtZ", BusinessData[i][bizExt][2]);
		    cache_get_value_name_float(i, "bizIntX", BusinessData[i][bizInt][0]);
		    cache_get_value_name_float(i, "bizIntY", BusinessData[i][bizInt][1]);
		    cache_get_value_name_float(i, "bizIntZ", BusinessData[i][bizInt][2]);
			forex(j, 7)
			{
				format(str, 32, "bizProduct%d", j + 1);
				cache_get_value_name_int(i, str, BusinessData[i][bizProduct][j]);
				format(str, 32, "bizProdName%d", j + 1);
				cache_get_value_name(i, str, ProductName[i][j]);
				format(desc, 312, "bizDescription%d", j + 1);
				cache_get_value_name(i, desc, ProductDescription[i][j]);
			}

			cache_get_value_name_int(i, "bizVault", BusinessData[i][bizVault]);
			cache_get_value_name_int(i, "bizPrices", BusinessData[i][bizPrices]);
			cache_get_value_name_int(i, "bizType", BusinessData[i][bizType]);
			cache_get_value_name_int(i, "bizWorld", BusinessData[i][bizWorld]);
			cache_get_value_name_int(i, "bizInterior", BusinessData[i][bizInterior]);
			cache_get_value_name_int(i, "bizType", BusinessData[i][bizType]);
			cache_get_value_name_int(i, "bizStock", BusinessData[i][bizStock]);
			cache_get_value_name_int(i, "bizFuel", BusinessData[i][bizFuel]);
			cache_get_value_name(i, "bizOwnerName", BusinessData[i][bizOwnerName]);
			cache_get_value_name_float(i, "bizDeliverX", BusinessData[i][bizDeliver][0]);
			cache_get_value_name_float(i, "bizDeliverY", BusinessData[i][bizDeliver][1]);
			cache_get_value_name_float(i, "bizDeliverZ", BusinessData[i][bizDeliver][2]);
			cache_get_value_name_int(i, "bizCargo", BusinessData[i][bizCargo]);
			cache_get_value_name_float(i, "bizFuelX", BusinessData[i][bizFuelPos][0]);
			cache_get_value_name_float(i, "bizFuelY", BusinessData[i][bizFuelPos][1]);
			cache_get_value_name_float(i, "bizFuelZ", BusinessData[i][bizFuelPos][2]);
			cache_get_value_name_int(i, "bizLocked", BusinessData[i][bizLocked]);
			cache_get_value_name_int(i, "bizDiesel", BusinessData[i][bizDiesel]);

			Business_Spawn(i);
		}
		printf("[BUSINESS] Loaded %d Business from database", rows);
	}
	return 1;
}

stock Business_Spawn(i)
{
	new
	    string[256], icon;
	//1: Fast Food | 2: 24/7 | 3: Clothes | 4: Electronic
	switch(BusinessData[i][bizType])
	{
		case 1: icon = 50;
		case 2: icon = 48;
		case 3: icon = 45;
		case 4: icon = 25;
	}
	if(BusinessData[i][bizDeliver][0] != 0 && BusinessData[i][bizDeliver][1] != 0 && BusinessData[i][bizDeliver][2] != 0)
	{
		BusinessData[i][bizDeliverPickup] = CreateDynamicPickup(1239, 23, BusinessData[i][bizDeliver][0], BusinessData[i][bizDeliver][1], BusinessData[i][bizDeliver][2], -1, -1);
		BusinessData[i][bizDeliverText] = CreateDynamic3DTextLabel(sprintf("%s\n{C6E2FF}Delivery Point", BusinessData[i][bizName]), COLOR_SERVER, BusinessData[i][bizDeliver][0], BusinessData[i][bizDeliver][1], BusinessData[i][bizDeliver][2], 15.0);
	}
	if(BusinessData[i][bizFuelPos][0] != 0 && BusinessData[i][bizFuelPos][1] != 0 && BusinessData[i][bizFuelPos][2] != 0)
	{
		BusinessData[i][bizFuelText] = CreateDynamic3DTextLabel(sprintf("Gasoline: %d Liter\nDiesel: %d Liter\nType /refuel to refuel", BusinessData[i][bizFuel], BusinessData[i][bizDiesel]), COLOR_SERVER, BusinessData[i][bizFuelPos][0], BusinessData[i][bizFuelPos][1], BusinessData[i][bizFuelPos][2], 15.0);
		BusinessData[i][bizFuelPickup] = CreateDynamicPickup(1650, 23, BusinessData[i][bizFuelPos][0], BusinessData[i][bizFuelPos][1], BusinessData[i][bizFuelPos][2], -1, -1);
	}
	if (BusinessData[i][bizOwner] == -1)
	{
		format(string, sizeof(string), "[ID: %d]\nType: {C6E2FF}%s\n{FFFFFF}Price: {C6E2FF}$%s\n{FFFFFF}This business for sell\n{FFFF00}/biz buy {FFFFFF}for purchase this business.", i, GetBizType(BusinessData[i][bizType]), FormatMoney(BusinessData[i][bizPrices]));
        BusinessData[i][bizText] = CreateDynamic3DTextLabel(string, -1, BusinessData[i][bizExt][0], BusinessData[i][bizExt][1], BusinessData[i][bizExt][2], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
	}
	else
	{
		format(string, sizeof(string), "[ID: %d]\nName: %s{FFFFFF}\nStatus: {C6E2FF}%s{FFFFFF}\nType: {C6E2FF}%s", i, BusinessData[i][bizName], (!BusinessData[i][bizLocked]) ? ("{00FF00}Open{FFFFFF}") : ("{FF0000}Closed{FFFFFF}"), GetBizType(BusinessData[i][bizType]));
		BusinessData[i][bizText] = CreateDynamic3DTextLabel(string, -1, BusinessData[i][bizExt][0], BusinessData[i][bizExt][1], BusinessData[i][bizExt][2], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
	}
	BusinessData[i][bizCP] = CreateDynamicCP(BusinessData[i][bizExt][0], BusinessData[i][bizExt][1], BusinessData[i][bizExt][2], 1.0, -1, -1, -1, 2.0);
	BusinessData[i][bizPickup] = CreateDynamicPickup(19130, 23, BusinessData[i][bizExt][0], BusinessData[i][bizExt][1], BusinessData[i][bizExt][2], -1, -1);
	BusinessData[i][bizIcon] = CreateDynamicMapIcon(BusinessData[i][bizExt][0], BusinessData[i][bizExt][1], BusinessData[i][bizExt][2], icon, -1, -1, -1, -1, 70.0);
	return 1;
}
stock Business_Save(bizid)
{
	new
	    query[2048];

	mysql_format(sqlcon, query, sizeof(query), "UPDATE `business` SET `bizName` = '%s', `bizOwner` = '%d', `bizExtX` = '%f', `bizExtY` = '%f', `bizExtZ` = '%f', `bizIntX` = '%f', `bizIntY` = '%f', `bizIntZ` = '%f', `bizDeliverX` = '%f', `bizDeliverY` = '%f', `bizDeliverZ` = '%f', `bizCargo` = '%d', `bizDiesel` = '%d', `bizLocked` = '%d'",
		BusinessData[bizid][bizName],
		BusinessData[bizid][bizOwner],
		BusinessData[bizid][bizExt][0],
		BusinessData[bizid][bizExt][1],
		BusinessData[bizid][bizExt][2],
		BusinessData[bizid][bizInt][0],
		BusinessData[bizid][bizInt][1],
		BusinessData[bizid][bizInt][2],
		BusinessData[bizid][bizDeliver][0],
		BusinessData[bizid][bizDeliver][1],
		BusinessData[bizid][bizDeliver][2],
		BusinessData[bizid][bizCargo],
		BusinessData[bizid][bizDiesel],
		BusinessData[bizid][bizLocked]
	);
	forex(i, 7)
	{
		mysql_format(sqlcon, query, sizeof(query), "%s, `bizProduct%d` = '%d'", query, i + 1, BusinessData[bizid][bizProduct][i]);
	}
	forex(i, 7)
	{
		mysql_format(sqlcon, query, sizeof(query), "%s, `bizProdName%d` = '%s', `bizDescription%d` = '%s'", query, i + 1, ProductName[bizid][i], i + 1, ProductDescription[bizid][i]);
	}
	mysql_format(sqlcon, query, sizeof(query), "%s, `bizWorld` = '%d', `bizInterior` = '%d', `bizVault` = '%d', `bizType` = '%d', `bizStock` = '%d', `bizPrices` = '%d', `bizFuel` = '%d', `bizOwnerName` = '%s', `bizFuelX` = '%f', `bizFuelY` = '%f', `bizFuelZ` = '%f' WHERE `bizID` = '%d'",
		query,
		BusinessData[bizid][bizWorld],
		BusinessData[bizid][bizInterior],
		BusinessData[bizid][bizVault],
		BusinessData[bizid][bizType],
		BusinessData[bizid][bizStock],
		BusinessData[bizid][bizPrices],
		BusinessData[bizid][bizFuel],
		BusinessData[bizid][bizOwnerName],
		BusinessData[bizid][bizFuelPos][0], 
		BusinessData[bizid][bizFuelPos][1], 
		BusinessData[bizid][bizFuelPos][2], 
		BusinessData[bizid][bizID]
	);
	return mysql_tquery(sqlcon, query);
}

stock GetBizType(type)
{
	new str[32];
	switch(type)
	{
	    case 1: str = "Fast Food";
	    case 2: str = "24/7";
	    case 3: str = "Clothes";
	    case 4: str = "Electronic";
	}
	return str;
}

stock Business_Refresh(bizid)
{
	if (bizid != -1 && BusinessData[bizid][bizExists])
	{

		new
		    string[256];

		if(BusinessData[bizid][bizDeliver][0] != 0 && BusinessData[bizid][bizDeliver][1] != 0 && BusinessData[bizid][bizDeliver][2] != 0)
		{
			Streamer_SetFloatData(STREAMER_TYPE_PICKUP, BusinessData[bizid][bizDeliverPickup], E_STREAMER_X, BusinessData[bizid][bizDeliver][0]);
			Streamer_SetFloatData(STREAMER_TYPE_PICKUP, BusinessData[bizid][bizDeliverPickup], E_STREAMER_Y, BusinessData[bizid][bizDeliver][1]);
			Streamer_SetFloatData(STREAMER_TYPE_PICKUP, BusinessData[bizid][bizDeliverPickup], E_STREAMER_Z, BusinessData[bizid][bizDeliver][2]);

			Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, BusinessData[bizid][bizDeliverText], E_STREAMER_X, BusinessData[bizid][bizDeliver][0]);
			Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, BusinessData[bizid][bizDeliverText], E_STREAMER_Y, BusinessData[bizid][bizDeliver][1]);
			Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, BusinessData[bizid][bizDeliverText], E_STREAMER_Z, BusinessData[bizid][bizDeliver][2]);

			UpdateDynamic3DTextLabelText(BusinessData[bizid][bizDeliverText], COLOR_SERVER, sprintf("%s\nDelivery Point", BusinessData[bizid][bizName]));
		}
		if(BusinessData[bizid][bizFuelPos][0] != 0 && BusinessData[bizid][bizFuelPos][1] != 0 && BusinessData[bizid][bizFuelPos][2] != 0)
		{
			Streamer_SetFloatData(STREAMER_TYPE_PICKUP, BusinessData[bizid][bizFuelPickup], E_STREAMER_X, BusinessData[bizid][bizFuelPos][0]);
			Streamer_SetFloatData(STREAMER_TYPE_PICKUP, BusinessData[bizid][bizFuelPickup], E_STREAMER_Y, BusinessData[bizid][bizFuelPos][1]);
			Streamer_SetFloatData(STREAMER_TYPE_PICKUP, BusinessData[bizid][bizFuelPickup], E_STREAMER_Z, BusinessData[bizid][bizFuelPos][2]);

			Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, BusinessData[bizid][bizFuelText], E_STREAMER_X, BusinessData[bizid][bizFuelPos][0]);
			Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, BusinessData[bizid][bizFuelText], E_STREAMER_Y, BusinessData[bizid][bizFuelPos][1]);
			Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, BusinessData[bizid][bizFuelText], E_STREAMER_Z, BusinessData[bizid][bizFuelPos][2]);


			UpdateDynamic3DTextLabelText(BusinessData[bizid][bizFuelText], COLOR_SERVER, sprintf("Gasoline: %d Liter\nDiesel: %d Liter\nType /refuel to refuel", BusinessData[bizid][bizFuel], BusinessData[bizid][bizDiesel]));
		}
		if (BusinessData[bizid][bizOwner] == -1)
		{
			format(string, sizeof(string), "[ID: %d]\nType: {C6E2FF}%s\n{FFFFFF}Price: {C6E2FF}$%s\n{FFFFFF}This business for sell\n{FFFF00}/biz buy {FFFFFF}for purchase this business.", bizid, GetBizType(BusinessData[bizid][bizType]), FormatMoney(BusinessData[bizid][bizPrices]));
		}
		else
		{
  			format(string, sizeof(string), "[ID: %d]\nName: %s{FFFFFF}\nStatus: {C6E2FF}%s{FFFFFF}\nType: {C6E2FF}%s", bizid, BusinessData[bizid][bizName], (!BusinessData[bizid][bizLocked]) ? ("{00FF00}Open{FFFFFF}") : ("{FF0000}Closed{FFFFFF}"), GetBizType(BusinessData[bizid][bizType]));
		}
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, BusinessData[bizid][bizText], E_STREAMER_X, BusinessData[bizid][bizExt][0]);
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, BusinessData[bizid][bizText], E_STREAMER_Y, BusinessData[bizid][bizExt][1]);
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, BusinessData[bizid][bizText], E_STREAMER_Z, BusinessData[bizid][bizExt][2]);

		Streamer_SetFloatData(STREAMER_TYPE_PICKUP, BusinessData[bizid][bizPickup], E_STREAMER_X, BusinessData[bizid][bizExt][0]);
		Streamer_SetFloatData(STREAMER_TYPE_PICKUP, BusinessData[bizid][bizPickup], E_STREAMER_Y, BusinessData[bizid][bizExt][1]);
		Streamer_SetFloatData(STREAMER_TYPE_PICKUP, BusinessData[bizid][bizPickup], E_STREAMER_Z, BusinessData[bizid][bizExt][2]);

		Streamer_SetFloatData(STREAMER_TYPE_CP, BusinessData[bizid][bizCP], E_STREAMER_X, BusinessData[bizid][bizExt][0]);
		Streamer_SetFloatData(STREAMER_TYPE_CP, BusinessData[bizid][bizCP], E_STREAMER_Y, BusinessData[bizid][bizExt][1]);
		Streamer_SetFloatData(STREAMER_TYPE_CP, BusinessData[bizid][bizCP], E_STREAMER_Z, BusinessData[bizid][bizExt][2]);
		UpdateDynamic3DTextLabelText(BusinessData[bizid][bizText], COLOR_SERVER, string);

		Streamer_SetPosition(STREAMER_TYPE_MAP_ICON, BusinessData[bizid][bizIcon], BusinessData[bizid][bizExt][0], BusinessData[bizid][bizExt][1], BusinessData[bizid][bizExt][2]);
	}
	return 1;
}

stock Business_Nearest(playerid, Float:range = 4.0)
{
	forex(i, MAX_BUSINESSES) if(BusinessData[i][bizExists])
	{
		if(IsPlayerInRangeOfPoint(playerid, range, BusinessData[i][bizExt][0], BusinessData[i][bizExt][1], BusinessData[i][bizExt][2]))
		{
			return i;
		}
	}
	return -1;
}

stock Business_NearestDeliver(playerid, Float:range = 4.0)
{
	forex(i, MAX_BUSINESSES) if(BusinessData[i][bizExists])
	{
		if(IsPlayerInRangeOfPoint(playerid, range, BusinessData[i][bizDeliver][0], BusinessData[i][bizDeliver][1], BusinessData[i][bizDeliver][2]))
		{
			return i;
		}
	}
	return -1;
}

stock Business_NearestFuel(playerid, Float:range = 4.0)
{
	forex(i, MAX_BUSINESSES) if(BusinessData[i][bizExists])
	{
		if(IsPlayerInRangeOfPoint(playerid, range, BusinessData[i][bizFuelPos][0], BusinessData[i][bizFuelPos][1], BusinessData[i][bizFuelPos][2]))
		{
			return i;
		}
	}
	return -1;
}

stock Business_Delete(bizid)
{
	if(BusinessData[bizid][bizExists])
	{
		new string[64];
		mysql_format(sqlcon, string, sizeof(string), "DELETE FROM `business` WHERE `bizID` = '%d'", BusinessData[bizid][bizID]);
		mysql_tquery(sqlcon, string);

		if (IsValidDynamic3DTextLabel(BusinessData[bizid][bizText]))
		    DestroyDynamic3DTextLabel(BusinessData[bizid][bizText]);

		if (IsValidDynamicPickup(BusinessData[bizid][bizPickup]))
		    DestroyDynamicPickup(BusinessData[bizid][bizPickup]);

		if(IsValidDynamicCP(BusinessData[bizid][bizCP]))
		    DestroyDynamicCP(BusinessData[bizid][bizCP]);
		   
		if(IsValidDynamicPickup(BusinessData[bizid][bizDeliverPickup]))
			DestroyDynamicPickup(BusinessData[bizid][bizDeliverPickup]);

		if(IsValidDynamic3DTextLabel(BusinessData[bizid][bizDeliverText]))
			DestroyDynamic3DTextLabel(BusinessData[bizid][bizDeliverText]);

		if(IsValidDynamicPickup(BusinessData[bizid][bizFuelPickup]))
			DestroyDynamicPickup(BusinessData[bizid][bizFuelPickup]);

		if(IsValidDynamic3DTextLabel(BusinessData[bizid][bizFuelText]))
			DestroyDynamic3DTextLabel(BusinessData[bizid][bizFuelText]);

		if(IsValidDynamicMapIcon(BusinessData[bizid][bizIcon]))
			DestroyDynamicMapIcon(BusinessData[bizid][bizIcon]);

		BusinessData[bizid][bizID] = 0;
		BusinessData[bizid][bizExists] = false;
		BusinessData[bizid][bizOwner] = -1;
	}
	return 1;
}

stock SetProductPrice(playerid)
{
	new bid = PlayerData[playerid][pInBiz], string[712];
	if(!BusinessData[bid][bizExists])
	    return 0;

	switch(BusinessData[bid][bizType])
	{
	    case 1:
	    {
	        format(string, sizeof(string), "Product\tPrice\n%s\t$%s\n%s\t$%s\n%s\t$%s",
				ProductName[bid][0],
				FormatMoney(BusinessData[bid][bizProduct][0]),
				ProductName[bid][1],
	            FormatMoney(BusinessData[bid][bizProduct][1]),
	            ProductName[bid][2],
	            FormatMoney(BusinessData[bid][bizProduct][2])
			);
		}
		case 2:
		{
		    format(string, sizeof(string), "Product\tPrice\n%s\t$%s\n%s\t$%s\n%s\t$%s\n%s\t$%s\n%s\t$%s\n%s\t$%s\n%s\t$%s",
                ProductName[bid][0],
				FormatMoney(BusinessData[bid][bizProduct][0]),
				ProductName[bid][1],
	            FormatMoney(BusinessData[bid][bizProduct][1]),
	            ProductName[bid][2],
	            FormatMoney(BusinessData[bid][bizProduct][2]),
	            ProductName[bid][3],
	            FormatMoney(BusinessData[bid][bizProduct][3]),
	        	ProductName[bid][4],
	            FormatMoney(BusinessData[bid][bizProduct][4]),
	        	ProductName[bid][5],
	            FormatMoney(BusinessData[bid][bizProduct][5]),
	            ProductName[bid][6],
	            FormatMoney(BusinessData[bid][bizProduct][6])
			);
		}
		case 3:
		{
		    format(string, sizeof(string), "Product\tPrice\n%s\t$%s\n%s\t$%s",
                ProductName[bid][0],
		        FormatMoney(BusinessData[bid][bizProduct][0]),
                ProductName[bid][1],
		        FormatMoney(BusinessData[bid][bizProduct][1]) 
			);
		}
		case 4:
		{
		    format(string, sizeof(string), "Product\tPrice\n%s\t$%s\n%s\t$%s\n%s\t$%s\n%s\t$%s",
                ProductName[bid][0],
				FormatMoney(BusinessData[bid][bizProduct][0]),
				ProductName[bid][1],
	            FormatMoney(BusinessData[bid][bizProduct][1]),
	            ProductName[bid][2],
	            FormatMoney(BusinessData[bid][bizProduct][2]),
	            ProductName[bid][3],
	            FormatMoney(BusinessData[bid][bizProduct][3])
			);
		}
	}
	ShowPlayerDialog(playerid, DIALOG_BIZPRICE, DIALOG_STYLE_TABLIST_HEADERS, "Set Product Price", string, "Select", "Close");
	return 1;
}

Store:BusinessElectronic(playerid, response, itemid, modelid, price, amount, itemname[])
{
	new bizid = PlayerData[playerid][pInBiz];

    if(!response)
        return true;

    if(GetMoney(playerid) < price)
        return SendErrorMessage(playerid, "You don't have enough money to purchase %s!", itemname);

    if(modelid == 18875 && Inventory_Count(playerid, "GPS") > 0)
    	return SendErrorMessage(playerid, "You already have a GPS!");

    if(itemid == 1)
    {
    	ShowNumberIndex(playerid);
    }
    else if(itemid == 4)
    {
		PlayerData[playerid][pCredit] += 50;
		SendNearbyMessage(playerid, 20.0, COLOR_PURPLE, "* %s has paid $%s and purchased a %s.", ReturnName(playerid), FormatMoney(price), ProductName[bizid][itemid - 1]);
		GiveMoney(playerid, -price);
		BusinessData[bizid][bizStock]--;
		BusinessData[bizid][bizVault] += price;
    }
    else
    {
    	new const itemnames[3][24] = {
    		"Cellphone",
    		"GPS",
    		"Portable Radio"
    	};

    	Inventory_Add(playerid, itemnames[itemid - 1], modelid, 1);
	 	GiveMoney(playerid, -price);
		SendNearbyMessage(playerid, 20.0, COLOR_PURPLE, "* %s has paid $%s and purchased a %s.", ReturnName(playerid), FormatMoney(price), ProductName[bizid][itemid - 1]);
		BusinessData[bizid][bizStock]--;
		BusinessData[bizid][bizVault] += price;
    }
    TogglePlayerControllable(playerid, 1);
    return 1;
}
Store:BusinessMarket(playerid, response, itemid, modelid, price, amount, itemname[])
{
	new bizid = PlayerData[playerid][pInBiz];

    if(!response)
        return true;

    if(GetMoney(playerid) < price)
        return SendErrorMessage(playerid, "You don't have enough money to purchase %s!", itemname);

    if(modelid == 19036 && Inventory_Count(playerid, "Mask") > 0)
    	return SendErrorMessage(playerid, "You already have a mask!");


 	GiveMoney(playerid, -price);
	SendNearbyMessage(playerid, 20.0, COLOR_PURPLE, "* %s has paid $%s and purchased a %s.", ReturnName(playerid), FormatMoney(price), ProductName[bizid][itemid - 1]);	GiveMoney(playerid, -price);
	BusinessData[bizid][bizStock]--;
	BusinessData[bizid][bizVault] += price;
	new const itemnames[7][24] = {
		"Snack",
		"Water",
		"Mask",
		"Medkit",
		"Rolling Paper",
		"Axe",
		"Fish Rod"
	};

	Inventory_Add(playerid, itemnames[itemid - 1], modelid, 1);

	if(modelid == 19036)
	{
		PlayerData[playerid][pMaskID] = PlayerData[playerid][pID]+random(90000) + 10000;
		SendClientMessageEx(playerid, -1, "* You have purchased a mask, your MaskID {FFFF00}%d", PlayerData[playerid][pMaskID]);
	}
	TogglePlayerControllable(playerid, 1);
    return true;
}
stock ShowBusinessMenu(playerid)
{
	new bid = PlayerData[playerid][pInBiz], string[712];
	if(!BusinessData[bid][bizExists])
	    return 0;
	    
	switch(BusinessData[bid][bizType])
	{
	    case 1:
	    {
	        format(string, sizeof(string), "Product\tPrice\n%s\t$%s\n%s\t$%s\n%s\t$%s",
				ProductName[bid][0],
				FormatMoney(BusinessData[bid][bizProduct][0]),
				ProductName[bid][1],
	            FormatMoney(BusinessData[bid][bizProduct][1]),
	            ProductName[bid][2],
	            FormatMoney(BusinessData[bid][bizProduct][2])
			);
			ShowPlayerDialog(playerid, DIALOG_BIZBUY, DIALOG_STYLE_TABLIST_HEADERS, "Business Product", string, "Select", "Close");
		}
		case 2://anjime
		{
			if(PlayerData[playerid][pTogBuy])
			{
				MenuStore_AddItem(playerid, 1, 2768, ProductName[bid][0], BusinessData[bid][bizProduct][0], ProductDescription[bid][0], 200);
				MenuStore_AddItem(playerid, 2, 2958, ProductName[bid][1], BusinessData[bid][bizProduct][1], ProductDescription[bid][1], 200);
				MenuStore_AddItem(playerid, 3, 19036, ProductName[bid][2], BusinessData[bid][bizProduct][2], ProductDescription[bid][2], 200);
				MenuStore_AddItem(playerid, 4, 1580, ProductName[bid][3], BusinessData[bid][bizProduct][3], ProductDescription[bid][3], 200);
				MenuStore_AddItem(playerid, 5, 19873, ProductName[bid][4], BusinessData[bid][bizProduct][4], ProductDescription[bid][4], 200);
				MenuStore_AddItem(playerid, 6, 19631, ProductName[bid][5], BusinessData[bid][bizProduct][5], ProductDescription[bid][5], 200);
				MenuStore_AddItem(playerid, 7, 18632, ProductName[bid][6], BusinessData[bid][bizProduct][6], ProductDescription[bid][6], 200);
				MenuStore_Show(playerid, BusinessMarket, BusinessData[bid][bizName]);
			}
			else
			{
			    format(string, sizeof(string), "Product\tPrice\n%s\t$%s\n%s\t$%s\n%s\t$%s\n%s\t$%s\n%s\t$%s\n%s\t$%s\n%s\t$%s",
	                ProductName[bid][0],
					FormatMoney(BusinessData[bid][bizProduct][0]),
					ProductName[bid][1],
		            FormatMoney(BusinessData[bid][bizProduct][1]),
		            ProductName[bid][2],
		            FormatMoney(BusinessData[bid][bizProduct][2]),
		            ProductName[bid][3],
		            FormatMoney(BusinessData[bid][bizProduct][3]),
		        	ProductName[bid][4],
		            FormatMoney(BusinessData[bid][bizProduct][4]),
		            ProductName[bid][5],
		            FormatMoney(BusinessData[bid][bizProduct][5]),
		            ProductName[bid][6],
		            FormatMoney(BusinessData[bid][bizProduct][6])

				);
				ShowPlayerDialog(playerid, DIALOG_BIZBUY, DIALOG_STYLE_TABLIST_HEADERS, "Business Product", string, "Select", "Close");
			}
		}
		case 3:
		{
		    format(string, sizeof(string), "Product\tPrice\n%s\t$%s\n%s\t$%s",
                ProductName[bid][0],
		        FormatMoney(BusinessData[bid][bizProduct][0]),
                ProductName[bid][1],
		        FormatMoney(BusinessData[bid][bizProduct][1])
			);
			ShowPlayerDialog(playerid, DIALOG_BIZBUY, DIALOG_STYLE_TABLIST_HEADERS, "Business Product", string, "Select", "Close");
		}
		case 4:
		{
			if(PlayerData[playerid][pTogBuy])
			{
				MenuStore_AddItem(playerid, 1, 18867, ProductName[bid][0], BusinessData[bid][bizProduct][0], ProductDescription[bid][0], 200);
				MenuStore_AddItem(playerid, 2, 18875, ProductName[bid][1], BusinessData[bid][bizProduct][1], ProductDescription[bid][1], 200);
				MenuStore_AddItem(playerid, 3, 19942, ProductName[bid][2], BusinessData[bid][bizProduct][2], ProductDescription[bid][2], 200);
				MenuStore_AddItem(playerid, 4, 19792, ProductName[bid][3], BusinessData[bid][bizProduct][3], ProductDescription[bid][3], 200);
				MenuStore_Show(playerid, BusinessElectronic, BusinessData[bid][bizName]);
			}
			else
			{   
			    format(string, sizeof(string), "Product\tPrice\n%s\t$%s\n%s\t$%s\n%s\t$%s\n%s\t$%s",
	                ProductName[bid][0],
					FormatMoney(BusinessData[bid][bizProduct][0]),
					ProductName[bid][1],
		            FormatMoney(BusinessData[bid][bizProduct][1]),
		            ProductName[bid][2],
		            FormatMoney(BusinessData[bid][bizProduct][2]),
		            ProductName[bid][3],
		            FormatMoney(BusinessData[bid][bizProduct][3])
				);
				ShowPlayerDialog(playerid, DIALOG_BIZBUY, DIALOG_STYLE_TABLIST_HEADERS, "Business Product", string, "Select", "Close");
			}
		}
	}
	return 1;
}