GetVehicleModelByName(const name[])
{
	if(IsNumeric(name) && (strval(name) >= 400 && strval(name) <= 611))
		return strval(name);

	for (new i = 0; i < sizeof(g_arrVehicleNames); i ++)
	{
		if(strfind(g_arrVehicleNames[i], name, true) != -1)
		{
			return i + 400;
		}
	}
	return 0;
}
GetVehicleNameByVehicle(vehicleid)
{
    new
        model = GetVehicleModel(vehicleid),
        name[32] = "None";

    if(model < 400 || model > 611)
        return name;

    format(name, sizeof(name), g_arrVehicleNames[model - 400]);
    return name;
}
GetVehicleNameByModel(model)
{
    new
        name[32] = "None";

    if(model < 400 || model > 611)
        return name;

    format(name, sizeof(name), g_arrVehicleNames[model - 400]);
    return name;
}
// Set Vehicle
GetEngineStatus(vehicleid)
{
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

    if(engine != 1)
        return 0;

    return 1;
}

GetHoodStatus(vehicleid)
{
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

    if(bonnet != 1)
        return 0;

    return 1;
}

GetTrunkStatus(vehicleid)
{
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

    if(boot != 1)
        return 0;

    return 1;
}

stock GetAlarmStatus(vehicleid)
{
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

    if(alarm != 1)
        return 0;

    return 1;
}

GetDoorStatus(vehicleid)
{
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

    if(doors != 1)
        return 0;

    return 1;
}

GetLightStatus(vehicleid)
{
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

    if(lights != 1)
        return 0;

    return 1;
}

SetLightStatus(vehicleid, status)
{
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    return SetVehicleParamsEx(vehicleid, engine, status, alarm, doors, bonnet, boot, objective);
}

SetTrunkStatus(vehicleid, status)
{
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    return SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, status, objective);
}

SetHoodStatus(vehicleid, status)
{
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    return SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, status, boot, objective);
}

SetDoorStatus(vehicleid, status)
{
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    return SetVehicleParamsEx(vehicleid, engine, lights, alarm, status, bonnet, boot, objective);
}

stock SetAlarmStatus(vehicleid, status)
{
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    return SetVehicleParamsEx(vehicleid, engine, lights, status, doors, bonnet, boot, objective);
}

stock IsPoweredVehicle(vehicleid)
{
    new
        model = GetVehicleModel(vehicleid);

    if (400 <= model <= 611)
    {
        static const g_EngineInfo[] = {
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1,
            1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0
        };

        return g_EngineInfo[model - 400];
    }
    return 0;
}
SetEngineStatus(vehicleid, status)
{
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    return SetVehicleParamsEx(vehicleid, status, lights, alarm, doors, bonnet, boot, objective);
}

IsVehicleInRangeOfPoint(vehicleid, Float:range, Float:x, Float:y, Float:z)
{
    if(GetVehicleDistanceFromPoint(vehicleid, x, y, z) <= range) {
        return 1;
    }
    return 0;
}
// vehicle type

IsNewsVehicle(vehicleid)
{
    switch (GetVehicleModel(vehicleid)) {
        case 488, 582: return 1;
    }
    return 0;
}
IsATruck(vehicleid)
{
    switch (GetVehicleModel(vehicleid)) {
        case 456, 455: return 1;
    }
    return 0;
}
IsABigTruck(vehicleid)
{
    switch (GetVehicleModel(vehicleid))
    {
        case 403, 514, 515: return 1;
    }
    return 0;
}

IsSportCar(vehicleid)
{
	new Sport[] = { 502, 409, 587, 602, 589, 555, 503, 504, 494, 541, 411, 477, 562, 506, 451, 565, 429, 560, 603, 559, 402, 561, 558, 415, 480 };
	for(new i = 0; i < sizeof(Sport); i++) {
	    if(GetVehicleModel(vehicleid) == Sport[i]) return 1;
	}
	return 0;
}

IsNormalCar(vehicleid)
{
	new Normal[] = { 605, 604, 418, 600, 596, 597, 598, 583, 585, 568, 580, 545, 546, 547, 549, 550, 551, 552, 554, 533, 540, 
    542, 543, 531, 529, 526, 527, 516, 517, 518, 507, 500, 496, 536, 534, 567, 535, 412, 566, 575, 576, 445, 419, 401, 410,
    426, 436, 400, 421, 404, 413, 416, 420, 422, 424, 427, 434, 438, 439, 440, 442, 457, 459, 466, 467, 474, 475, 478, 
    479, 480, 482, 483, 492, 405 };
    
	for(new i = 0; i < sizeof(Normal); i++) {
	    if(GetVehicleModel(vehicleid) == Normal[i]) return 1;
	}
	return 0;
}
IsNormalTruck(vehicleid)
{
	new Normal[] = { 428, 609, 601, 599, 588, 582, 579, 528, 525, 508, 505, 414, 423, 470, 489, 490, 491, 495, 498, 499 };
	for(new i = 0; i < sizeof(Normal); i++) {
	    if(GetVehicleModel(vehicleid) == Normal[i]) return 1;
	}
	return 0;
}

IsBigTruck(vehicleid)
{
	new Normal[] = { 432, 406, 578, 573, 557, 556, 532, 544, 524, 514, 515, 403, 407, 408, 431, 433, 437, 443, 444, 456, 486 };
	for(new i = 0; i < sizeof(Normal); i++) {
	    if(GetVehicleModel(vehicleid) == Normal[i]) return 1;
	}
	return 0;
}
IsSportBike(vehicleid)
{
	new Sport[] = { 581, 461, 521, 463, 522, 523 };
	for(new i = 0; i < sizeof(Sport); i++) {
	    if(GetVehicleModel(vehicleid) == Sport[i]) return 1;
	}
	return 0;
}
IsACruiser(vehicleid)
{
    switch (GetVehicleModel(vehicleid)) {
        case 523, 427, 490, 528, 596..599, 601: return 1;
    }
    return 0;
}
IsSportBikeModel(modelid)
{
	new Sport[] = { 581, 461, 521, 463, 522, 523 };
	for(new i = 0; i < sizeof(Sport); i++) {
	    if(modelid == Sport[i]) return 1;
	}
	return 0;
}
IsNewsVehicleModel(modelid)
{
    switch (modelid) {
        case 488, 582: return 1;
    }
    return 0;
}
IsACruiserModel(modelid)
{
    switch (modelid) {
        case 523, 427, 490, 528, 596..599, 601: return 1;
    }
    return 0;
}

IsSportCarModel(modelid)
{
	new Sport[] = { 502, 409, 587, 602, 589, 555, 503, 504, 494, 541, 411, 477, 562, 506, 451, 565, 429, 560, 603, 559, 402, 561, 558, 415, 480 };
	for(new i = 0; i < sizeof(Sport); i++) {
	    if(modelid == Sport[i]) return 1;
	}
	return 0;
}

IsNormalCarModel(modelid)
{
	new Normal[] = { 605, 604, 418, 600, 596, 597, 598, 583, 585, 568, 580, 545, 546, 547, 549, 550, 551, 552, 554, 533, 540, 
    542, 543, 529, 526, 527, 516, 517, 518, 507, 500, 496, 536, 534, 567, 535, 412, 566, 575, 576, 445, 419, 401, 410,
    426, 436, 400, 421, 404, 413, 416, 424, 427, 434, 438, 439, 440, 442, 457, 459, 466, 467, 474, 475, 478, 
    479, 480, 482, 483, 492, 405 };
    
	for(new i = 0; i < sizeof(Normal); i++) {
	    if(modelid == Normal[i]) return 1;
	}
	return 0;
}
IsABikeModel(modelid)
{
    switch (modelid) {
        case 448, 461..463, 468, 521..523, 581, 586, 481, 509, 510: return 1;
    }
    return 0;
}

IsABicycleModel(modelid)
{
    switch (modelid) {
        case 481, 509, 510: return 1;
    }
    return 0;
}
IsVehicleHasTireNotTruck(modelid)
{
    return
        IsABikeModel(modelid) ||
        IsABicycleModel(modelid) ||
        IsSportBikeModel(modelid) ||
        IsNewsVehicleModel(modelid) ||
        IsSportCarModel(modelid) ||
        IsNormalCarModel(modelid) ||
        IsACruiserModel(modelid)
    ;
}
IsDoorVehicle(vehicleid)
{
    switch (GetVehicleModel(vehicleid)) {
        case 400..424, 426..429, 431..440, 442..445, 451, 455, 456, 458, 459, 466, 467, 470, 474, 475:
            return 1;

        case 477..480, 482, 483, 486, 489, 490..492, 494..496, 498..500, 502..508, 514..518, 524..529, 533..536:
            return 1;

        case 540..547, 549..552, 554..562, 565..568, 573, 575, 576, 578..580, 582, 585, 587..589, 596..605, 609:
            return 1;
    }
    return 0;
}


IsSpeedoVehicle(vehicleid)
{
    if(!IsEngineVehicle(vehicleid))
        return 0;

    switch(GetVehicleModel(vehicleid)) {
        case 509..510, 481: return 0;
    }

    return 1;
}

IsLoadableVehicle(vehicleid)
{
    new modelid = GetVehicleModel(vehicleid);

    if(GetVehicleTrailer(vehicleid))
        modelid = GetVehicleModel(GetVehicleTrailer(vehicleid));

    switch (modelid) {
        case 609, 403, 414, 456, 498, 499, 514, 515, 435, 591: return 1;
    }
    return 0;
}

GetMaxCrates(vehicleid)
{
    new crates;

    switch (GetVehicleModel(vehicleid)) {
        case 498, 609: crates = 10;
        case 414: crates = 8;
        case 456, 499: crates = 6;
        case 435, 591: crates = 15;
    }
    return crates;
}
/*
IsCrateInUse(crateid)
{
    if(CrateData[crateid][crateVehicle] != INVALID_VEHICLE_ID && IsValidVehicle(CrateData[crateid][crateVehicle])) {
        return 1;
    }
    foreach (new i : Player) if(PlayerData[i][pCarryCrate] == crateid && GetPlayerSpecialAction(i) == SPECIAL_ACTION_CARRY) {
        return 1;
    }
    return 0;
}

GetVehicleCrates(vehicleid)
{
    if(!IsValidVehicle(vehicleid) || !IsLoadableVehicle(vehicleid))
        return 0;

    new crates;

    for (new i = 0; i != MAX_CRATES; i ++) if(CrateData[i][crateExists] && CrateData[i][crateVehicle] == vehicleid) {
        crates++;
    }
    return crates;
}*/

IsABoat(vehicleid)
{
    switch (GetVehicleModel(vehicleid)) {
        case 430, 446, 452, 453, 454, 472, 473, 484, 493, 595: return 1; //452, 453, 454, 472, 473, 484, 493, 595, 430, 446
    }
    return 0;
}

IsABike(vehicleid)
{
    switch (GetVehicleModel(vehicleid)) {
        case 448, 461..463, 468, 521..523, 581, 586: return 1;
    }
    return 0;
}

IsABicycle(vehicleid)
{
    switch (GetVehicleModel(vehicleid)) {
        case 481, 509, 510: return 1;
    }
    return 0;
}

IsAPlane(vehicleid)
{
    switch (GetVehicleModel(vehicleid)) {
        case 460, 464, 476, 511, 512, 513, 519, 520, 553, 577, 592, 593: return 1;
    }
    return 0;
}

IsAHelicopter(vehicleid)
{
    switch (GetVehicleModel(vehicleid)) {
        case 417, 425, 447, 465, 469, 487, 488, 497, 501, 548, 563: return 1;
    }
    return 0;
}

IsVehicleDrivingBackwards(vehicleid) // By Joker
{
    new
        Float:Float[3]
    ;
    if(GetVehicleVelocity(vehicleid, Float[1], Float[2], Float[0]))
    {
        GetVehicleZAngle(vehicleid, Float[0]);
        if(Float[0] < 90)
        {
            if(Float[1] > 0 && Float[2] < 0) return true;
        }
        else if(Float[0] < 180)
        {
            if(Float[1] > 0 && Float[2] > 0) return true;
        }
        else if(Float[0] < 270)
        {
            if(Float[1] < 0 && Float[2] > 0) return true;
        }
        else if(Float[1] < 0 && Float[2] < 0) return true;
    }
    return false;
}

IsEngineVehicle(vehicleid)
{
    static const g_aEngineStatus[] = {
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
        1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0
    };
    new modelid = GetVehicleModel(vehicleid);

    if(modelid < 400 || modelid > 611)
        return 0;

    return (g_aEngineStatus[modelid - 400]);
}

IsFourWheelVehicle(vehicleid)
{
    return
        !IsABoat(vehicleid) &&
        !IsABike(vehicleid) &&
        !IsABicycle(vehicleid) &&
        !IsAPlane(vehicleid) &&
        !IsAHelicopter(vehicleid) &&
        !IsSportBike(vehicleid)
    ;
}

IsVehicleHasTire(vehicleid)
{
    return
        IsABike(vehicleid) ||
        IsSportBike(vehicleid) ||
        IsNewsVehicle(vehicleid) ||
        IsATruck(vehicleid) ||
        IsSportCar(vehicleid) ||
        IsNormalCar(vehicleid) ||
        IsNormalTruck(vehicleid) ||
        IsBigTruck(vehicleid) ||
        IsACruiser(vehicleid) ||
        IsDoorVehicle(vehicleid)
    ;
}

IsModValid(vehicleid, componentid)
{
  new model = GetVehicleModel(vehicleid);
  
  //Untuk ngecheck component id kurang dari 1000 dan lebih dari max vehicle mod id
  if(componentid < 1000 || componentid > MAX_VEHICLE_MOD_ID+1)
  {
    return 0;
  }
  //Untuk ngecheck model kendaraan nya valid
  if(model < 400 || model > 611)
  {
    return 0;
  }
  //untuk ngecheck kalau model id kendaraannya valid.
  model = model - 400;


  if(!Iter_Contains(g_Iter_VVM[model], componentid)) // Kalau komponennya valid, di add
  {
    return 0;
  }
  return 1;
}

VehicleMod_GetSectionName(section, value[], length = sizeof(value))
{
  format(value, length, "(unknown)");

  if (section < 0 || section > MAX_VEHICLE_MOD_SECTIONS)
  {
    return 1;
  }

  format(value, length, "%s", g_VehicleModSections[section]);
  return 1;
}

VehicleMod_GetComponentName(componentid, bool:include_section_name = true, value[], length = sizeof(value))
{
  format(value, length, "");

  if (componentid < 1000 || componentid > (MAX_VEHICLE_MOD_ID+1))
  {
    return 1;
  }

  if (include_section_name)
  {
    new mod_section = g_VehicleMods[componentid - 1000][VEHICLE_MOD_MODEL_SECTION];
    format(value, length, "%s - ", g_VehicleModSections[mod_section]);
  }

  strcat(value, g_VehicleMods[componentid - 1000][VEHICLE_MOD_MODEL_BRAND], length);
  return 1;
}

VehicleMod_GetComponentSection(componentid)
{
  if (componentid < 1000 || componentid > 1194)
  {
    return INVALID_VEHICLE_MOD_SECTION_ID;
  }

  componentid = componentid - 1000;
  return g_VehicleMods[componentid][VEHICLE_MOD_MODEL_SECTION];
}

Vehicle_HasAnyModableComponent(vehicleid)
{
  new model = GetVehicleModel(vehicleid);

  //Untuk ngecheck model kendaraan nya valid
  if(model < 400 || model > 611)
  {
    return 0;
  }

  //untuk ngecheck kalau model id kendaraannya valid.
  model = model - 400;

  if(Iter_Count(g_Iter_VVM[model]) < 1) // Kalau jumlah component yang bisa di-mod kurang dari 1, berarti tidak bisa di-mod.
  {
    return 0;
  }

  return 1;
}

Vehicle_IsModSectionModable(vehicleid, section)
{
  new model = GetVehicleModel(vehicleid);
  
  // Untuk memeriksa section-nya kurang dari 0 dan lebih dari MAX_VEHICLE_MOD_SECTIONS
  if(section < 0 || section > MAX_VEHICLE_MOD_SECTIONS+1)
  {
    return 0;
  }
  //Untuk ngecheck model kendaraan nya valid
  if(model < 400 || model > 611)
  {
    return 0;
  }
  //untuk ngecheck kalau model id kendaraannya valid.
  model = model - 400;


  if(!Iter_Contains(gI_VehModableSect[model], section)) // Kalau section-nya valid, di add
  {
    return 0;
  }
  return 1;
}

Vehicle_GetModableSection(vehicleid, value[], length  = sizeof(value))
{
  // Reset value terlebih dahulu.
  format(value, length, "");

  // Mengembalikan ID model kendaraannya.
  new model = GetVehicleModel(vehicleid);

  // Jika tidak ada section yang bisa di-mod, maka hanya mengembalikan header-nya saja.
  if(!model || !Vehicle_HasAnyModableComponent(vehicleid))
  {
    format(value, length, "Section ID\tSection Name\n");
    return 1;
  }

  model = model - 400;

  format(value, length, "%s", g_VehicleModableSections[model]);
  return 1;
}

Vehicle_GetModableComponent(vehicleid, section, bool:modelid_only, value[], length = sizeof(value))
{
  // Reset value terlebih dahulu.
  format(value, length, "");

  // Mengembalikan ID model kendaraannya.
  new model = GetVehicleModel(vehicleid);

  // Jika tidak ada section yang bisa di-mod, maka hanya mengembalikan header-nya saja.
  if(!model || section < 0 || section > MAX_VEHICLE_MOD_SECTIONS+1 || !Vehicle_HasAnyModableComponent(vehicleid))
  {
    if (!modelid_only)
    {
      format(value, length, "Component ID\tComponent Name\n");
    }

    return 1;
  }

  model = model - 400;

  if (modelid_only)
  {
    foreach(new i : gI_VehModableComp[model]<section>)
    {
      if (strlen(value) < 1)
      {
        format(value, length, "%d\n", i);
      }
      else
      {
        format(value, length, "%s%d\n", value, i);
      }
    }
  }
  else
  {
    format(value, length, "%s", g_VehicleModableComponents[model][section]);
  }

  return 1;
}

Vehicle_RegisterValidMod(modelid, componentid)
{
  new valid_mod_index = componentid - 1000;
  new section = g_VehicleMods[valid_mod_index][VEHICLE_MOD_MODEL_SECTION];

  if (!Iter_Contains(gI_VehModableSect[modelid], section))
  {
    Iter_Add(gI_VehModableSect[modelid], section);
  }

  if (!Iter_Contains(gI_VehModableComp[modelid]<section>, componentid))
  {
    Iter_Add(gI_VehModableComp[modelid]<section>, componentid);
  }
}

Vehicle_BuildComponentList(modelid, section)
{
  if (modelid < 0 || modelid > MAX_VEHICLE_MODELS)
  {
    return 1;
  }

  if (section < 0 || section > MAX_VEHICLE_MOD_SECTIONS)
  {
    return 1;
  }

  new str[64];
  format(g_VehicleModableComponents[modelid][section], 512, "Component ID\tComponent Name\n");

  foreach(new componentid : gI_VehModableComp[modelid]<section>)
  {
    new valid_mod_index = componentid - 1000;

    format(str, sizeof(str), "%d\t%s\n", componentid, g_VehicleMods[valid_mod_index][VEHICLE_MOD_MODEL_BRAND]);
    strcat(g_VehicleModableComponents[modelid][section], str);
  }

  // printf("modelid: %d -> component string:\n%s", modelid+400, g_VehicleModableComponents[modelid][section]);
  return 1;
}

Vehicle_BuildSectionList(modelid)
{
  if (modelid < 0 || modelid > MAX_VEHICLE_MODELS)
  {
    return 1;
  }

  new str[64];
  format(g_VehicleModableSections[modelid], 256, "Section ID\tSection Name\n");

  foreach(new i : gI_VehModableSect[modelid])
  {
    format(str, sizeof(str), "%d\t%s\n", i, g_VehicleModSections[i]);
    strcat(g_VehicleModableSections[modelid], str);

    // printf("modelid: %d -> section: %d -> section string:\n%s", modelid+400, i, g_VehicleModableSections[modelid]);
    Vehicle_BuildComponentList(modelid, i);
  }

  return 1;
}

hook OnGameModeInit()
{
  // Inisialisasi iterator.
  Iter_Init(g_Iter_VVM);
  Iter_Init(gI_VehModableSect);
  Iter_Init(gI_VehModableComp);

  // Memuat mod ke section yang sesuai.
  // PreLoadVehicleModSections();

  // Memasukkan semua ID mod component-nya ke dalam iterator.
  for (new model = 0; model < MAX_VEHICLE_MODELS; model++)
  {
    for (new mod = 0; mod < MAX_VEHICLE_COMPAT_MODS; mod++)
    {
          // Hanya memasukkan ID mod lebih dari atau sama dengan 1000.
      if (g_VehicleValidMods[model][mod] >= 1000)
      {
        Iter_Add(g_Iter_VVM[model], g_VehicleValidMods[model][mod]);
        Vehicle_RegisterValidMod(model, g_VehicleValidMods[model][mod]);
      }			
    }

    // Membentuk string dialog untuk menampilkan section mod yang valid untuk model kendaraannya.
    Vehicle_BuildSectionList(model);

    // Untuk memuat informasi mod yang cocok berdasarkan ID model kendaraannya.
    // printf("Vehicle Mod Compability -> modelid: %d | model_name: %s | compatible mods: %d mods", 400 + model, GetVehicleNameByModel(400 + model), Iter_Count(g_Iter_VVM[model]));
  }
  return 1;
}

//

Float:GetVehicleSpeed(vehicleid, bool:kmh = true, Float:velx = 0.0, Float:vely = 0.0, Float:velz = 0.0)
{
    if( velx == 0.0 && vely == 0.0 && velz == 0.0)
        GetVehicleVelocity(vehicleid, velx, vely, velz);

    return float(floatround((floatsqroot(((velx * velx) + (vely * vely)) + (velz * velz)) * (kmh ? (136.666667) : (85.4166672))), floatround_round));
}