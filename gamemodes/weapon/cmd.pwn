CMD:weapons(playerid, params[]) 
{
	ShowPlayerWeapon(playerid, playerid);
	return 1;
}

CMD:weapon(playerid, params[]) 
{
	if(PlayerData[playerid][pInjured])
        return SendErrorMessage(playerid, "Tidak bisa menggunakan perintah ini ketika injured.");

    if(PlayerData[playerid][pHospitalTime])
        return SendErrorMessage(playerid, "Tidak bisa menggunakan perintah ini ketika dalam masa pemulihan.");

	new category[32], string[32];

	if(sscanf(params, "s[32]S()[32]", category, string))
		return SendSyntaxMessage(playerid, "/weapon [give/view/acceptview/scrap/destroy]");

	if(!strcmp(category, "give"))
	{
		new userid, weaponid;

		if(sscanf(string, "u", userid))
			return SendSyntaxMessage(playerid, "/weapon give [userid]");

		if(userid == INVALID_PLAYER_ID || !IsPlayerNearPlayer(playerid, userid, 5.0)) 
			return SendErrorMessage(playerid, "Player tidak login atau tidak bedara didekatmu.");

		if (!PlayerData[userid][pStory])
			return SendErrorMessage(playerid, "That player must have accepted character story.");

		if(!(weaponid = GetWeapon(playerid)))
			return SendErrorMessage(playerid, "Kamu tidak memegang senjata apapun.");

        if(PlayerHasWeaponInSlot(userid, weaponid))
        	return SendErrorMessage(playerid, "Player tersebut memiliki senjata di slot yang sama.");

		GivePlayerWeaponEx(userid, weaponid, PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_ammo], PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_durability]);
		ResetWeaponID(playerid, weaponid);

		SendServerMessage(playerid, "Kamu telah memberi "RED"%s"WHITE" kepada "YELLOW"%s.", ReturnWeaponName(weaponid), ReturnName(userid));
		SendServerMessage(userid, ""YELLOW"%s"WHITE" memberikan "RED"%s"WHITE" kepadamu.", ReturnName(playerid), ReturnWeaponName(weaponid));
	}
	else if(!strcmp(category, "scrap"))
	{
		new weaponid, confirm[10] ;

		if(!(weaponid = GetWeapon(playerid)))
			return SendErrorMessage(playerid, "Kamu tidak memegang senjata apapun.");

		if(sscanf(string, "s[10]", confirm)) {
			SendCustomMessage(playerid, "USAGE","/weapon scrap ['confirm']");
			SendCustomMessage(playerid, "INFO","Perintah ini untuk menggantikan senjata dan peluru menjadi material!");
			return 1;
		}

		if(!strcmp(confirm, "confirm"))
		{
			if (weaponid >= 2 && weaponid <= 15 || weaponid > 38)
				return SendErrorMessage(playerid, "Senjata jenis ini tidak dapat discrap!");

			Inventory_Add(playerid, "Materials", 11746, floatround((ReturnWeaponMaterial(weaponid)/4)));
			SendCustomMessage(playerid, "WEAPON", "Berhasil melakukan scrap senjata "RED"%s "WHITE"menjadi "YELLOW"%d material(s)", ReturnWeaponName(weaponid), floatround((ReturnWeaponMaterial(weaponid)/4)));

			Inventory_Add(playerid, "Materials", 11746, floatround((PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_ammo]/2)));
			SendCustomMessage(playerid, "WEAPON", "Berhasil melakukan scrap "RED"%d aminisi "WHITE"menjadi "YELLOW"%d material(s)", PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_ammo], floatround((PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_ammo]/2)));

			ResetWeaponID(playerid, weaponid);
		}
	}
	else if(!strcmp(category, "destroy"))
	{
		new weaponid, confirm[10];

		if((weaponid = GetWeapon(playerid)) == 0)
			return SendErrorMessage(playerid, "Kamu tidak memegang senjata apapun.");

		if(sscanf(string, "s[10]", confirm)) {
			SendCustomMessage(playerid, "USAGE", "/weapon destroy ['confirm']");
			SendCustomMessage(playerid, "WARNING","Perintah ini digunakan untuk menghancurkan habis senjatamu, termasuk peluru di dalamnya!");
			SendCustomMessage(playerid, "WARNING","Tidak ada refund setelah menggunakan perintah ini!");
			return 1;
		}

		if(!strcmp(confirm, "confirm"))
		{
			SendCustomMessage(playerid, "WEAPON", "Berhasil menghancurkan senjata "RED"%s.", ReturnWeaponName(weaponid));
			ResetWeaponID(playerid, weaponid);
		}
	}
	else if(!strcmp(category, "view"))
	{
		new userid;

		if(sscanf(string, "u", userid))
			return SendSyntaxMessage(playerid, "/weapon view [playerid/PartOfName]");

		if(userid == INVALID_PLAYER_ID || !IsPlayerNearPlayer(playerid, userid, 5.0)) 
			return SendErrorMessage(playerid, "Player tidak login atau tidak bedara didekatmu.");

		ShowPlayerWeapon(playerid, userid);		
		SendServerMessage(playerid, "Kamu memperlihatkan senjatamu kepada %s.", ReturnName(userid, 0, 1));
	}
	else SendSyntaxMessage(playerid, "/weapon [give/view/acceptview/scrap/destroy]");
	return 1;
}

CMD:creategun(playerid, params[]) 
{
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, 331.41, 1123.09, 1084.66)) 
        return SendErrorMessage(playerid, "Kamu tidak berada di blackmarket.");

	if(IsPlayerDuty(playerid)) 
        return SendErrorMessage(playerid, "Kamu sedang duty faction.");

    if(GetPlayerJob(playerid, 0) != JOB_ARMS_DEALER && GetPlayerJob(playerid, 1) != JOB_ARMS_DEALER)
    	return SendErrorMessage(playerid, "Kamu tidak bekerja sebagai arms dealer.");

	if (!PlayerData[playerid][pStory])
		return SendErrorMessage(playerid, "You must have accepted character story for creating a gun.");

    new string[156];

    strcat(string, "Weapon\tAmmo\tMaterial\n");
    for(new i = 0; i < sizeof(g_aWeaponItems); i++) {
    	if(g_aWeaponItems[i][wep_auth] == PLAYER_NORMAL) {
	    	strcat(string, sprintf("%s\t%d\t%d\n", ReturnWeaponName(g_aWeaponItems[i][wep_model]), (g_aWeaponSlots[g_aWeaponItems[i][wep_model]] == 1) ? (1) : (((MaxGunAmmo[g_aWeaponItems[i][wep_model]] * 2)/10)), g_aWeaponItems[i][wep_material]));
	    }

	   	if(GetFactionType(playerid) == FACTION_GANG)
	   	{
	    	if(g_aWeaponItems[i][wep_auth] == PLAYER_OFFICIAL) {
		    	strcat(string, sprintf("%s\t%d\t%d\n", ReturnWeaponName(g_aWeaponItems[i][wep_model]), (g_aWeaponSlots[g_aWeaponItems[i][wep_model]] == 1) ? (1) : (((MaxGunAmmo[g_aWeaponItems[i][wep_model]] * 2)/10)), g_aWeaponItems[i][wep_material]));
		    }
	   	}
    }
    Dialog_Show(playerid, CreateGun, DIALOG_STYLE_TABLIST_HEADERS, "Create Gun", string, "Create", "Cancel");
	return 1;
}

CMD:buymaterials(playerid, params[]) 
{
    new 
        amount, id;

	if(GetPlayerJob(playerid, 0) != JOB_ARMS_DEALER && GetPlayerJob(playerid, 1) != JOB_ARMS_DEALER)
		return SendErrorMessage(playerid, "You don't have the appropriate job.");

    if((id = Job_NearestPoint(playerid)) != -1 && JobData[id][jobType] == JOB_ARMS_DEALER)
		{   
	    if(sscanf(params, "d", amount))
	        return SendSyntaxMessage(playerid, "/buymaterials [jumlah ($10/mats)]");

	    if(amount < 0)
	        return SendErrorMessage(playerid, "Jumlah yang di masukkan tidak boleh kurang dari nol.");

	    if(GetMoney(playerid) < (MULTIPLE_MATERIAL*amount))
	        return SendErrorMessage(playerid, "Uang yang kamu miliki kurang untuk membeli %d material (%s).", amount, FormatNumber(MULTIPLE_MATERIAL*amount));

	    if((Inventory_Count(playerid, "Materials")+amount) > 10000)
	    	return SendErrorMessage(playerid, "Kamu hanya dapat membeli %d material.", (10000-Inventory_Count(playerid, "Materials")));

	    if(Inventory_Add(playerid, "Materials", 11746, amount) == -1)
	    	return SendErrorMessage(playerid, "Sisa slot di inventory kamu sudah penuh, buang atau gunakan beberapa item yang tidak terpakai.");

	    SendServerMessage(playerid, "Berhasil membeli "YELLOW"%d material "WHITE"dengan total harga "GREEN"%s.", amount, FormatNumber((MULTIPLE_MATERIAL*amount)));
	    GiveMoney(playerid, -(MULTIPLE_MATERIAL*amount));
    }
    else SendErrorMessage(playerid, "Kamu tidak berada digudang penjualan material.");

    return 1;
}

CMD:createammo(playerid, params[])
{
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, 331.41, 1123.09, 1084.66)) 
        return SendErrorMessage(playerid, "Kamu tidak berada di blackmarket.");

    if(IsPlayerDuty(playerid)) 
        return SendErrorMessage(playerid, "Kamu sedang duty faction.");

    if(GetPlayerJob(playerid, 0) != JOB_ARMS_DEALER && GetPlayerJob(playerid, 1) != JOB_ARMS_DEALER)
    	return SendErrorMessage(playerid, "Kamu tidak bekerja sebagai arms dealer.");

	if (!PlayerData[playerid][pStory])
				return SendErrorMessage(playerid, "You must have accepted character story for creating ammo.");

    if(!Inventory_HasItem(playerid, "Materials"))
        return SendErrorMessage(playerid, "Kamu tidak memiliki material.");

    new
        confirm[24],
        weaponid;

    if((weaponid = GetWeapon(playerid)) == 0) 
        return SendErrorMessage(playerid, "Kamu tidak memegang senjata apapun.");

    if(g_aWeaponSlots[weaponid] == 1)
    	return SendErrorMessage(playerid, "Senjata ini tidak dapat diisi amunisi.");

	if (ReturnWeaponAmmo(playerid, weaponid) >= MaxGunAmmo[weaponid])
		return SendErrorMessage(playerid, "Senjata ini tidak memerlukan amunisi lagi.");

    if(sscanf(params, "s[24]", confirm)) {
        SendSyntaxMessage(playerid, "/createammo ['confirm']");
    	SendCustomMessage(playerid, "DETAILS", "Weapon: "RED"%s"WHITE", current: "YELLOW"%d/%d ammo", ReturnWeaponName(weaponid), ReturnWeaponAmmo(playerid, weaponid), MaxGunAmmo[weaponid]);
    	SendCustomMessage(playerid, "DETAILS", "Creating ammo: "YELLOW"%d"WHITE", material cost: "YELLOW"%d unit(s)", (MaxGunAmmo[weaponid]-ReturnWeaponAmmo(playerid, weaponid)), floatround(((MaxGunAmmo[weaponid]-ReturnWeaponAmmo(playerid, weaponid))/2)));
    	return 1;
    }

    new amount = (MaxGunAmmo[weaponid]-ReturnWeaponAmmo(playerid, weaponid));

    if(!strcmp(confirm, "confirm"))
    {
	    if(floatround(amount/2) > Inventory_Count(playerid, "Materials"))
	        return SendErrorMessage(playerid, "Jumlah material tidak mencukupi.");

	    if(weaponid > 22 || weaponid < 38)
	    {
	        PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_ammo] += amount;
	        Inventory_Remove(playerid, "Materials", floatround((amount/2)));

	        SendCustomMessage(playerid, "AMMO","Sukses membuat "YELLOW"%d amunisi (%d material) "WHITE"untuk senjata "RED"%s.", amount, floatround((amount/2)), ReturnWeaponName(weaponid));
	    }
	    else SendErrorMessage(playerid, "Senjata ini tidak dapat diisi amunisi.");
    }
    return 1;
}

CMD:repairgun(playerid, params[]) {
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, 331.41, 1123.09, 1084.66)) 
        return SendErrorMessage(playerid, "Kamu tidak berada di blackmarket.");

    if(IsPlayerDuty(playerid)) 
        return SendErrorMessage(playerid, "Kamu sedang duty faction.");

    if(GetPlayerJob(playerid, 0) != JOB_ARMS_DEALER && GetPlayerJob(playerid, 1) != JOB_ARMS_DEALER)
    	return SendErrorMessage(playerid, "Kamu tidak bekerja sebagai arms dealer.");

	if (!PlayerData[playerid][pStory])
		return SendErrorMessage(playerid, "You must have accepted character story for creating ammo.");

    if(!Inventory_HasItem(playerid, "Materials"))
        return SendErrorMessage(playerid, "Kamu tidak memiliki material.");

    new
        confirm[24],
        weaponid;

    if((weaponid = GetWeapon(playerid)) == 0) 
        return SendErrorMessage(playerid, "Kamu tidak memegang senjata apapun.");

    if(g_aWeaponSlots[weaponid] == 1)
    	return SendErrorMessage(playerid, "Senjata ini tidak dapat direpair.");

	if (ReturnWeaponDurability(playerid, weaponid) >= MaxGunAmmo[weaponid])
		return SendErrorMessage(playerid, "Senjata ini tidak memerlukan repair.");

    if(sscanf(params, "s[24]", confirm)) {
        SendSyntaxMessage(playerid, "/repairgun ['confirm']");
    	SendCustomMessage(playerid, "DETAILS", "Weapon: "RED"%s"WHITE", current: "YELLOW"%d/%d durability", ReturnWeaponName(weaponid), ReturnWeaponDurability(playerid, weaponid), MaxGunAmmo[weaponid]);
    	SendCustomMessage(playerid, "DETAILS", "Repairing gun: "YELLOW"%d"WHITE", material cost: "YELLOW"%d unit(s)", (MaxGunAmmo[weaponid]-ReturnWeaponDurability(playerid, weaponid)), floatround(((MaxGunAmmo[weaponid]-ReturnWeaponDurability(playerid, weaponid))/2)));
    	return 1;
    }

    new amount = (MaxGunAmmo[weaponid]-ReturnWeaponDurability(playerid, weaponid));

    if(!strcmp(confirm, "confirm"))
    {
	    if(floatround(amount/2) > Inventory_Count(playerid, "Materials"))
	        return SendErrorMessage(playerid, "Jumlah material tidak mencukupi.");

	    if(weaponid > 22 || weaponid < 38)
	    {
	        PlayerGuns[playerid][g_aWeaponSlots[weaponid]][weapon_durability] += amount;
	        Inventory_Remove(playerid, "Materials", floatround((amount/2)));

	        SendCustomMessage(playerid, "AMMO","Sukses memperbaiki kerusakan pada senjata "RED"%s "WHITE"dengan "YELLOW"%d "WHITE"material(s)", ReturnWeaponName(weaponid), floatround((amount/2)));
	    }
	    else SendErrorMessage(playerid, "Senjata ini tidak dapat direpair.");
    }
    return 1;
}

Dialog:CreateGun(playerid, response, listitem, inputtext[]) 
{
	if(response)
	{
		new 
			material = g_aWeaponItems[listitem][wep_material],
			model = g_aWeaponItems[listitem][wep_model]
		;
		if(Inventory_Count(playerid, "Materials") < material)
        	return SendErrorMessage(playerid, "You don't have enough materials.");

        if(PlayerHasWeapon(playerid, model))
			return SendErrorMessage(playerid, "You already have %s, /buyammo to add more ammo.", ReturnWeaponName(model));

        if(PlayerHasWeaponInSlot(playerid, model))
        	return SendErrorMessage(playerid, "You already have weapon in the same slot.");

		GivePlayerWeaponEx(playerid, model, ((MaxGunAmmo[model] * 2)/10));
        Inventory_Remove(playerid, "Materials", material);
		SendCustomMessage(playerid, "WEAPON", "Berhasil membuat "RED"%s (%d ammo) "WHITE"dengan "YELLOW"%d material.", ReturnWeaponName(model), ((MaxGunAmmo[model] * 2)/10), material);
	}
	return 1;
}