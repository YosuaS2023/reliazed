CMD:biz(playerid, params[])
{
	new
	    type[24],
	    string[128];

	if (sscanf(params, "s[24]S()[128]", type, string))
	{
	    SendSyntaxMessage(playerid, "/biz [name]");
	    SendClientMessage(playerid, COLOR_SERVER, "Names:{FFFFFF} buy, convertfuel, reqstock, menu, lock");
	    return 1;
	}
	if(!strcmp(type, "buy", true))
	{
	    if(Biz_GetCount(playerid) >= 1 && PlayerData[playerid][pAdmin] < 1)
	        return SendErrorMessage(playerid, "Kamu hanya bisa memiliki 1 Bisnis!");
	        
		forex(i, MAX_BUSINESSES)if(BusinessData[i][bizExists])
		{
      		if(IsPlayerInRangeOfPoint(playerid, 3.5, BusinessData[i][bizExt][0], BusinessData[i][bizExt][1], BusinessData[i][bizExt][2]))
			{
			    if(BusinessData[i][bizOwner] != -1)
			        return SendErrorMessage(playerid, "Bisnis ini sudah dimiliki seseorang!");
			        
				if(GetMoney(playerid) < BusinessData[i][bizPrice])
				    return SendErrorMessage(playerid, "Kamu tidak memiliki cukup uang untuk membeli Bisnis ini!");
				    
				BusinessData[i][bizOwner] = PlayerData[playerid][pID];
                format(BusinessData[i][bizOwnerName], MAX_PLAYER_NAME, GetName(playerid));
                SendServerMessage(playerid, "Kamu berhasil membeli Business ini seharga {00FF00}$%s", FormatNumber(BusinessData[i][bizPrice]));
                GiveMoney(playerid, -BusinessData[i][bizPrice]);
                Business_Refresh(i);
                Business_Save(i);
			}
		}
	}
	else if(!strcmp(type, "convertfuel", true))
	{
		new bid = PlayerData[playerid][pInBiz];
		if(bid == -1)
			return SendErrorMessage(playerid, "You must be inside your own business!");

		if(BusinessData[bid][bizOwner] != PlayerData[playerid][pID])
			return SendErrorMessage(playerid, "You must be inside your own business!");

		if(BusinessData[bid][bizType] != 2)
			return SendErrorMessage(playerid, "The business type must be 24/7!");

		if(BusinessData[bid][bizStock] < 50)
			return SendErrorMessage(playerid, "Harus ada 50 stock product dalam business-mu!");

		BusinessData[bid][bizFuel] = 1000;
		BusinessData[bid][bizDiesel] = 1000;
		SendClientMessage(playerid, COLOR_SERVER, "BUSINESS: {FFFFFF}50 percent product stock converted successfully to Fuel stock!");
		Business_Refresh(bid);
		Business_Save(bid);	
	}
	else if(!strcmp(type, "reqstock", true))
	{
		new bid = PlayerData[playerid][pInBiz];
		if(bid == -1)
			return SendErrorMessage(playerid, "You must be inside your own business!");

		if(BusinessData[bid][bizOwner] != PlayerData[playerid][pID])
			return SendErrorMessage(playerid, "You must be inside your own business!");

		if(!BusinessData[bid][bizReq])
		{
			BusinessData[bid][bizReq] = true;
			SendClientMessage(playerid, COLOR_SERVER, "BUSINESS: {FFFFFF}You've requesting the business restock, informing to all online Trucker!");
			foreach(new i : Player) if(PlayerData[i][pSpawned] && PlayerData[i][pJob] == JOB_TRUCKER)
			{
				SendClientMessageEx(i, COLOR_SERVER, "RESTOCK: {FFFFFF}Business {FFFF00}%s {FFFFFF}is requesting product Restock for Type {00FFFF}%s", BusinessData[bid][bizName], GetBizType(BusinessData[bid][bizType]));
			}
		}
		else
		{
			BusinessData[bid][bizReq] = false;
			SendClientMessage(playerid, COLOR_SERVER, "BUSINESS: {FFFFFF}Your business no longer requesting Product Restock.");
			foreach(new i : Player) if(PlayerData[i][pSpawned] && PlayerData[i][pJob] == JOB_TRUCKER)
			{
				SendClientMessageEx(i, COLOR_SERVER, "RESTOCK: {FFFFFF}Business {FFFF00}%s {FFFFFF}is no longer requesting product Restock");
			}			
		}
	}
	else if(!strcmp(type, "lock", true))
	{
		new inbiz = PlayerData[playerid][pInBiz];
		new bnear = Business_Nearest(playerid, 3.5);
		if(inbiz == -1)
		{
			if(bnear != -1)
			{
				if(Biz_IsOwner(playerid, bnear))
				{
					BusinessData[bnear][bizLocked] = (!BusinessData[bnear][bizLocked]);
					ShowMessage(playerid, sprintf("You have %s ~w~your business.", (BusinessData[bnear][bizLocked]) ? ("~r~Locked") : ("~g~Unlocked")), 3);

				}
			}
		}
		else
		{
			if(Biz_IsOwner(playerid, inbiz))
			{
				BusinessData[inbiz][bizLocked] = (!BusinessData[inbiz][bizLocked]);
				ShowMessage(playerid, sprintf("You have %s ~w~your business.", (BusinessData[inbiz][bizLocked]) ? ("~r~Locked") : ("~g~Unlocked")), 3);

			}
		}
	}
	else if(!strcmp(type, "menu", true))
	{
		if(PlayerData[playerid][pInBiz] != -1 && GetPlayerInterior(playerid) == BusinessData[PlayerData[playerid][pInBiz]][bizInterior] && GetPlayerVirtualWorld(playerid) == BusinessData[PlayerData[playerid][pInBiz]][bizWorld] && Biz_IsOwner(playerid, PlayerData[playerid][pInBiz]))
		{
		    ShowPlayerDialog(playerid, DIALOG_BIZMENU, DIALOG_STYLE_LIST, "Business Menu", "Business Details\nSet Product Name\nSet Product Price\nSet Business Name\nSet Cargo Price\nWithdraw Vault\nDeposit Vault\nSet Product Description", "Select", "Close");
		}
		else
			SendErrorMessage(playerid, "Kamu tidak berada didalam bisnis milikmu!");
	}
	return 1;
}

CMD:hidebuy(playerid, params[])
{
	MenuStore_Close(playerid);
	return 1;
}
CMD:buy(playerid, params[])
{
	if(PlayerData[playerid][pInBiz] != -1 && GetPlayerInterior(playerid) == BusinessData[PlayerData[playerid][pInBiz]][bizInterior] && GetPlayerVirtualWorld(playerid) == BusinessData[PlayerData[playerid][pInBiz]][bizWorld])
	{
		if(BusinessData[PlayerData[playerid][pInBiz]][bizOwner] == -1)
			return SendErrorMessage(playerid, "This busines is Closed!");

	    ShowBusinessMenu(playerid);
	}
	return 1;
}

CMD:createbiz(playerid, params[])
{
    new
		type,
	    price[32],
	    id;

    if (PlayerData[playerid][pAdmin] < 7)
	    return SendErrorMessage(playerid, "You don't have permission to use this command.");

	if (sscanf(params, "ds[32]", type, price))
 	{
	 	SendSyntaxMessage(playerid, "/createbiz [type] [price]");
    	SendClientMessage(playerid, COLOR_SERVER, "Type:{FFFFFF} 1: Fast Food | 2: 24/7 | 3: Clothes | 4: Electronic");
    	return 1;
	}
	if (type < 1 || type > 4)
	    return SendErrorMessage(playerid, "Invalid type specified. Types range from 1 to 7.");

	id = Business_Create(playerid, type, strcash(price));

	if (id == -1)
	    return SendErrorMessage(playerid, "The server has reached the limit for businesses.");

	SendServerMessage(playerid, "You have successfully created business ID: %d.", id);
	return 1;
}

CMD:editbiz(playerid, params[])
{
    new
        id,
        type[24],
        string[256];

    if(PlayerData[playerid][pAdmin] < 6)
        return SendErrorMessage(playerid, "You don't have permission to use this command!");

    if(sscanf(params, "ds[24]S()[128]", id, type, string))
    {
        SendSyntaxMessage(playerid, "/editbiz [id] [name]");
        SendClientMessage(playerid, COLOR_SERVER, "Names:{FFFFFF} location, interior, fuelpoint, fuelstock, price, stock, deliver, delete, asell");
        return 1;
    }
    if((id < 0 || id >= MAX_BUSINESSES))
        return SendErrorMessage(playerid, "You have specified an invalid ID.");

	if(!BusinessData[id][bizExists])
        return SendErrorMessage(playerid, "You have specified an invalid ID.");

    if(!strcmp(type, "location", true))
    {
		GetPlayerPos(playerid, BusinessData[id][bizExt][0], BusinessData[id][bizExt][1], BusinessData[id][bizExt][2]);
		Business_Save(id);
		Business_Refresh(id);

		SendClientMessageEx(playerid, COLOR_LIGHTRED, "AdmBiz: {FFFFFF}Kamu telah mengubah posisi Business ID: %d", id);
    }
    else if(!strcmp(type, "interior", true))
    {
    	BusinessData[id][bizInterior] = GetPlayerInterior(playerid);

		GetPlayerPos(playerid, BusinessData[id][bizInt][0], BusinessData[id][bizInt][1], BusinessData[id][bizInt][2]);
		Business_Save(id);
		Business_Refresh(id);

		SendClientMessageEx(playerid, COLOR_LIGHTRED, "AdmBiz: {FFFFFF}Kamu telah mengubah posisi Business ID: %d", id);
    }
    else if(!strcmp(type, "fuelpoint", true))
    {
    	if(BusinessData[id][bizType] != 2)
    		return SendErrorMessage(playerid, "Fuelpoint hanya bisa dengan Business type 24/7!");

		if(BusinessData[id][bizFuelPos][0] == 0 && BusinessData[id][bizFuelPos][1] == 0 && BusinessData[id][bizFuelPos][2] == 0)
		{
			BusinessData[id][bizFuelText] = CreateDynamic3DTextLabel(sprintf("Gasoline: %d Liter\nDiesel: %d Liter\nType /refuel to refuel", BusinessData[id][bizFuel], BusinessData[id][bizDiesel]), COLOR_SERVER, BusinessData[id][bizFuelPos][0], BusinessData[id][bizFuelPos][1], BusinessData[id][bizFuelPos][2], 15.0);
			BusinessData[id][bizFuelPickup] = CreateDynamicPickup(1650, 23, BusinessData[id][bizFuelPos][0], BusinessData[id][bizFuelPos][1], BusinessData[id][bizFuelPos][2], -1, -1);
		}

    	GetPlayerPos(playerid, BusinessData[id][bizFuelPos][0], BusinessData[id][bizFuelPos][1], BusinessData[id][bizFuelPos][2]);
    	Business_Save(id);
    	Business_Refresh(id);

    	SendClientMessageEx(playerid, COLOR_LIGHTRED, "AdmBiz: {FFFFFF}Kamu telah mengubah posisi Fuel Point Business ID: %d", id);  
    }
    else if(!strcmp(type, "deliver", true))
    {
		if(BusinessData[id][bizDeliver][0] == 0 && BusinessData[id][bizDeliver][1] == 0 && BusinessData[id][bizDeliver][2] == 0)
		{
			BusinessData[id][bizDeliverPickup] = CreateDynamicPickup(1239, 23, BusinessData[id][bizDeliver][0], BusinessData[id][bizDeliver][1], BusinessData[id][bizDeliver][2], -1, -1);
			BusinessData[id][bizDeliverText] = CreateDynamic3DTextLabel(sprintf("%s\nDelivery Point", BusinessData[id][bizName]), COLOR_SERVER, BusinessData[id][bizDeliver][0], BusinessData[id][bizDeliver][1], BusinessData[id][bizDeliver][2], 15.0);
		}
 		GetPlayerPos(playerid, BusinessData[id][bizDeliver][0], BusinessData[id][bizDeliver][1], BusinessData[id][bizDeliver][2]);
		Business_Save(id);
		Business_Refresh(id);

		SendClientMessageEx(playerid, COLOR_LIGHTRED, "AdmBiz: {FFFFFF}Kamu telah mengubah posisi Deliver Point Business ID: %d", id);   	
    }
    else if(!strcmp(type, "price", true))
    {
    	new amount[32];

    	if(sscanf(string, "s[32]", amount))
    		return SendSyntaxMessage(playerid, "/editbiz [id] [price] [new price]");

    	BusinessData[id][bizPrice] = strcash(amount);
    	SendAdminMessage(COLOR_LIGHTRED, "AdmBiz: %s has set Business ID %d price to $%s", PlayerData[playerid][pUCP], id, FormatNumber(strcash(amount)));
    	Business_Save(id);
    	Business_Refresh(id);
    }
    else if(!strcmp(type, "stock", true))
    {
    	new amount;

    	if(sscanf(string, "d", amount))
    		return SendSyntaxMessage(playerid, "/editbiz [id] [stock] [amount]");

    	BusinessData[id][bizStock] = amount;
    	SendAdminMessage(COLOR_LIGHTRED, "AdmBiz: %s has set Business ID %d stock to %d", PlayerData[playerid][pUCP], id, amount);
    	Business_Save(id);
    }
    else if(!strcmp(type, "delete", true))
    {
    	Business_Delete(id);
    	SendAdminMessage(COLOR_LIGHTRED, "AdmCmd: %s has deleted Business ID: %d", PlayerData[playerid][pUCP], id);
    }
    else if(!strcmp(type, "asell", true))
    {
    	BusinessData[id][bizOwner] = -1;
    	Business_Refresh(id);
    	Business_Save(id);
    	SendAdminMessage(COLOR_LIGHTRED, "AdmCmd: Business %d has aselled by %s", id, PlayerData[playerid][pUCP]);
    }
    return 1;
}