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
// Set Vehicle
SetEngineStatus(vehicleid, status)
{
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    return SetVehicleParamsEx(vehicleid, status, lights, alarm, doors, bonnet, boot, objective);
}
// vehicle type
IsSportBike(vehicleid)
{
	new Sport[] = { 581, 461, 521, 463, 522, 523 };
	for(new i = 0; i < sizeof(Sport); i++) {
	    if(GetVehicleModel(vehicleid) == Sport[i]) return 1;
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
IsABike(vehicleid)
{
    switch (GetVehicleModel(vehicleid)) {
        case 448, 461..463, 468, 521..523, 581, 586: return 1;
    }
    return 0;
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