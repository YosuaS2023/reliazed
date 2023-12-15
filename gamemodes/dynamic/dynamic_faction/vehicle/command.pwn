CMD:createfactionveh(playerid, params[])
{
	new
	    model[32],
		color1,
		color2,
		factid;

	if(CheckAdmin(playerid, ADM_FOUNDER))
		return SendErrorMessage(playerid, NO_PERMISSION);

	if (sscanf(params, "ds[32]I(-1)I(-1)", factid, model, color1, color2))
	    return SendSyntaxMessage(playerid, "/createfactionveh [factionid] [model id/name] <color 1> <color 2>");

	if(!FactionData[factid][factionExists])
		return SendErrorMessage(playerid, "Invalid factionid!");

	if ((model[0] = GetVehicleModelByName(model)) == 0)
	    return SendErrorMessage(playerid, "Invalid model ID.");

	new
	    Float:x,
	    Float:y,
	    Float:z,
	    Float:a;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);

	new id = FactionVehicle_Create(FactionData[factid][factionID], model[0], x, y, z, a, color1, color2);

	if(id == -1)
		return SendErrorMessage(playerid, "You cannot create more faction vehicle!");

	SendServerMessage(playerid, "You have successfully create vehicle for faction id %d", factid);
	return 1;
}

CMD:editfactionveh(playerid, params[])
{
	new
	    id,
	    type[24],
	    string[128];

	if (CheckAdmin(playerid, ADM_FOUNDER))
	    return SendErrorMessage(playerid, "You don't have permission to use this command.");

	if (sscanf(params, "ds[24]S()[128]", id, type, string))
 	{
	 	SendSyntaxMessage(playerid, "/editfactionveh [id] [name]");
	    SendClientMessage(playerid, COLOR_YELLOW, "Names:{FFFFFF} pos");
		return 1;
	}
	if(!strcmp(type, "pos", true))
	{
		if(!IsPlayerInVehicle(playerid, FactionVehicle[id][fvVehicle]))
			return SendErrorMessage(playerid, "You must inside the faction vehicle!");

		GetVehiclePos(GetPlayerVehicleID(playerid), FactionVehicle[id][fvPos][0], FactionVehicle[id][fvPos][1], FactionVehicle[id][fvPos][2]);
		GetVehicleZAngle(GetPlayerVehicleID(playerid), FactionVehicle[id][fvPos][3]);

		SendServerMessage(playerid, "You have adjusted position for faction vehicle id %d", id);
		FactionVehicle_Save(id);
	}

	return 1;
}

CMD:gotofactionveh(playerid, params[])
{
	if (CheckAdmin(playerid, ADM_FOUNDER))
	    return SendErrorMessage(playerid, "You don't have permission to use this command.");

	if(isnull(params))
		return SendSyntaxMessage(playerid, "/gotofactionveh [id]");

	if(!IsNumeric(params))
		return SendErrorMessage(playerid, "Invalid faction vehicle ID!");

	if(!FactionVehicle[strval(params)][fvExists])
		return SendErrorMessage(playerid, "Invalid faction vehicle ID!");

	new
	    Float:x,
	    Float:y,
	    Float:z;

	GetVehiclePos(FactionVehicle[strval(params)][fvVehicle], x, y, z);
	SetPlayerPos(playerid, x, y - 2, z + 2);
	return 1;
}

CMD:destroyfactionveh(playerid, params[])
{
	if (CheckAdmin(playerid, ADM_FOUNDER))
	    return SendErrorMessage(playerid, "You don't have permission to use this command.");
	
	if(isnull(params))
		return SendSyntaxMessage(playerid, "/destroyfactionveh [vehicleid]");

	if(!IsNumeric(params))
		return SendErrorMessage(playerid, "Invalid vehicle ID");

	if(!IsValidVehicle(strval(params)))
		return SendErrorMessage(playerid, "Invalid vehicle ID");

	if(IsFactionVehicle(strval(params)) == -1)
		return SendErrorMessage(playerid, "That vehicle is not faction vehicle!");	

	FactionVehicle_Delete(IsFactionVehicle(strval(params)));
	SendServerMessage(playerid, "You have removed faction vehicle id", IsFactionVehicle(strval(params)));
	return 1;
}