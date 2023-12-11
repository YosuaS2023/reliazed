#include <ysi\y_hooks>/*
stock InjuredPlayer(playerid, killerid, weaponid)
{
	if(PlayerData[playerid][pInjured])
		return 0;

	foreach(new i : Player) if(AccountData[i][uAdmin] > 0)
	{
		SendDeathMessageToPlayer(i, killerid, playerid, weaponid);
	}

	GetPlayerPos(playerid, PlayerData[playerid][pPos][0], PlayerData[playerid][pPos][1], PlayerData[playerid][pPos][2]);
	
	if (IsPlayerInAnyVehicle(playerid))
 		SetPlayerPos(playerid, PlayerData[playerid][pPos][0], PlayerData[playerid][pPos][1], PlayerData[playerid][pPos][2] + 0.7);

	PlayerData[playerid][pInjured] = 1;
	SetPlayerHealth(playerid, 100);
	PlayerData[playerid][pInjuredTime] = 600;
	SendClientMessage(playerid, COLOR_LIGHTRED, "WARNING: {FFFFFF}You have been {E20000}downed.{FFFFFF} You may choose to {44C300}/accept death");
	SendClientMessage(playerid, COLOR_WHITE, "...after your death timer expires or wait until you are revived.");

	ApplyAnimation(playerid, "WUZI", "CS_DEAD_GUY", 4.0, 1, 0, 0, 0, 0, 1);
	TogglePlayerControllable(playerid, false);
	PlayerData[playerid][pInjuredTag] = CreateDynamic3DTextLabel("(( THIS PLAYER IS INJURED ))", COLOR_LIGHTRED, 0.0, 0.0, 0.50, 15.0, playerid);

	return 1;
}
hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
    new Float:health,
		Float:armour;

	health = GetHealth(playerid);
	armour = GetArmour(playerid);
	if(damagedid != INVALID_PLAYER_ID)
	{
		new Float:damage;
		switch(weaponid)
		{
		    case 0: damage = 2.0; // Fist
			case 1: damage = 5.0; // Brass Knuckles
			case 2: damage = 5.0;   // Golf Club
			case 3: damage = 5.0; // Nightstick
			case 4: damage = 7.0; // Knife
			case 5: damage = 5.0; // Baseball Bat
			case 6: damage = 5.0; // Shovel
			case 7: damage = 5.0; // Pool Cue
			case 8: damage = 8.0; // Katana
			case 9: damage = 10.0; // Chainsaw
			case 14: damage = 2.0; // Flowers
			case 15: damage = 5.0; // Cane
			case 16: damage = 50.0; // Grenade
			case 18: damage = 20.0; // Molotov
			case 22: damage = float(RandomEx(15, 20)); // Colt45
			case 23, 28, 29, 32: damage = float(RandomEx(17, 23)); // SD Pistol, UZI, MP5, Tec
			case 24: damage = float(RandomEx(38, 43)); // Desert Eagle
			case 25, 26, 27: // Shotgun, Sawnoff Shotgun, CombatShotgun
			{
			    new Float: p_x, Float: p_y, Float: p_z;
			    GetPlayerPos(playerid, p_x, p_y, p_z);
			    new Float: dist = GetPlayerDistanceFromPoint(damagedid, p_x, p_y, p_z);

			    if (dist < 5.0)
					damage = float(RandomEx(50, 55));

				else if (dist < 10.0)
					damage = float(RandomEx(23, 35));

				else if (dist < 15.0)
					damage = float(RandomEx(15, 25));

				else if (dist < 20.0)
					damage = float(RandomEx(10, 15));

				else if (dist < 30.0)
					damage = float(RandomEx(5, 8));
			}
			case 30: damage = float(RandomEx(20, 25)); // AK47
			case 31: damage = float(RandomEx(20, 22)); // M4A1
			case 33, 34: damage = float(RandomEx(70, 75)); // Country Rifle, Sniper Rifle
			case 35: damage = 0.0; // RPG
			case 36: damage = 0.0; // HS Rocket
			case 38: damage = 0.0; // Minigun
		}

        if(bodypart == BODY_PART_TORSO && armour > 0.0 && (22 <= weaponid <= 38))
		{
		    if(armour - damage <= 7.0) {
				AddDamage(damagedid, bodypart, weaponid, damage, true);
				SetArmour(damagedid, 0.0);
			}
	 		else{
			 	SetArmour(damagedid, armour - damage);
				AddDamage(damagedid, bodypart, weaponid, damage, true);
			}

            SetHealth(damagedid, health);
			AddDamage(damagedid, bodypart, weaponid, damage);
		}
		else
		{
		    if(health - damage <= 7.0)
				InjuredPlayer(damagedid, playerid, weaponid);
			else
			{
				if(health <= 30.0)
				{
					SetHealth(damagedid, health - damage / 2); 
					AddDamage(damagedid, (bodypart - 3), weaponid, damage / 2);
				}
				else
				{
					SetHealth(damagedid, health - damage);
					AddDamage(damagedid, (bodypart - 3), weaponid, damage);
				}
			}

			if(armour => 1.0){
			    SetArmour(damagedid, armour - damage);
				AddDamage(damagedid, (bodypart - 3), weaponid, damage, true);
			}
		}
	}
	else
	{
	    if(health - amount <= 7.0)
			InjuredPlayer(damagedid, playerid, weaponid);
	}
	return 1;
}
hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{

	return 1;
}
*/

SetPlayerInjured(playerid)
{
    new 
        killerid = PlayerData[playerid][pKiller],
        reason = PlayerData[playerid][pKillerReason]
    ;
    if(!PlayerData[playerid][pInjured])
    {
        PlayerData[playerid][pInjured] = 1;
    }
   /* if(PlayerData[playerid][pCallLine] != INVALID_PLAYER_ID)
    {
        SendClientMessage(PlayerData[playerid][pCallLine], X11_YELLOW_2, "[PHONE]:"WHITE" The line went dead...");
        CancelCall(playerid);
    }
    if(PlayerData[playerid][pCarryCrate] != -1)
    {
        Crate_Drop(playerid);
    }

    if(PlayerData[playerid][pHudStyle] == 0) Speedometer_Hide(playerid);
    else SpeedometerNew_Hide(playerid);

    PlayerTextDrawHide(playerid, PlayerTextdraws[playerid][textdraw_supply]);*/
    //ResetPlayer(playerid);

    InjuredTag(playerid, true);

    TextDrawShowForPlayer(playerid, gServerTextdraws[0]);
    TextDrawSetString(gServerTextdraws[0], "You_are_injured!_~r~/call_911_~w~or_~r~/giveup");

    if(IsPlayerInAnyVehicle(playerid))
    {
        new Float:x, Float:y, Float:z, vehicleid = GetPlayerVehicleID(playerid);
        if(IsABike(vehicleid) || IsSportBike(vehicleid))
        {
            GetPlayerPos(playerid, x, y, z);
            SetPlayerPos(playerid, x, y, z+0.5);
            ApplyAnimation(playerid, "PED", "CAR_DEAD_LHS",   4.0, 0, 0, 0, 1, 0, 1);
            ApplyAnimation(playerid, "PED", "CAR_DEAD_LHS",   4.0, 0, 0, 0, 1, 0, 1);
        }
        else
        {
            ApplyAnimation(playerid, "PED", "CAR_DEAD_LHS",   4.0, 0, 0, 0, 1, 0, 1);
            ApplyAnimation(playerid, "PED", "CAR_DEAD_LHS",   4.0, 0, 0, 0, 1, 0, 1);
        }
        SetEngineStatus(vehicleid, false);
    }
    else
    {
        ApplyAnimation(playerid, "WUZI", "CS_DEAD_GUY",   4.0, 0, 0, 0, 1, 0, 1);
        ApplyAnimation(playerid, "WUZI", "CS_DEAD_GUY",   4.0, 0, 0, 0, 1, 0, 1);
    }

    if(killerid != INVALID_PLAYER_ID)
    {
        if(1 <= reason <= 46)
            Log_Save(E_LOG_KILL, sprintf("[%s] %s has killed %s (%s).", ReturnDate(), ReturnName(killerid), ReturnName(playerid), ReturnWeaponName(reason)));

        else
            Log_Save(E_LOG_KILL, sprintf("[%s] %s has killed %s (reason %d).", ReturnDate(), ReturnName(killerid), ReturnName(playerid), reason));

        if(reason == 50 && killerid != INVALID_PLAYER_ID)
            SendAdminMessage(X11_TOMATO_1, "AdmWarn: %s has killed %s by heli-blading.", ReturnName(killerid, 0), ReturnName(playerid, 0));

        if(reason == 29 && killerid != INVALID_PLAYER_ID && GetPlayerState(killerid) == PLAYER_STATE_DRIVER)
            SendAdminMessage(X11_TOMATO_1, "AdmWarn: %s has killed %s by driver shooting.", ReturnName(killerid, 0), ReturnName(playerid, 0));
    }

    if(playerUseRope[playerid] == 1)
    {
        for(new destr2=0;destr2<=ropelength;destr2++)
        {
            DestroyObject(r0pes[playerid][destr2]);
        }
        playerUseRope[playerid] = 0;
        playerVehicleRope[playerid] = 0;
        ClearAnimations(playerid);
        TogglePlayerControllable(playerid,0);
        TogglePlayerControllable(playerid,1);
        DisablePlayerCheckpoint(playerid);
    }

    foreach(new i : Player)
    {
        if(AccountData[i][pAdmin] > 0)
        {
            SendDeathMessageToPlayer(i, killerid, playerid, reason);
        }
    }

    SendClientMessage(playerid, X11_TOMATO_1, "WARNING:"WHITE" Anda terluka dan membutuhkan pertolongan medis (/call 911 > medics).");
    SendClientMessage(playerid, X11_GREY_60, "USAGE:"WHITE" (( /giveup untuk spawn ke rumah sakit. Tunggu 5 menit agar bisa melakukannya. ))");
    PlayerData[playerid][pGiveupTime] = 300; // 300
    new Float:rand = RandomFloat(60.0, 90.0);
    SetPlayerRate(playerid, rand);
    return 1;
}

InjuredTag(playerid, bool:injured = false, bool:dead = false, bool:spawned = false)
{
    if(injured)
    {
        if(!IsValidDynamic3DTextLabel(PlayerData[playerid][pInjuredTag]))
        {
            PlayerData[playerid][pInjuredTag] = CreateDynamic3DTextLabel("(( THIS PLAYER IS INJURED ))", COLOR_LIGHTRED, 0.0, 0.0, 0.2, 8.0, playerid, INVALID_VEHICLE_ID, 1);
        }
    }

    if(dead)
    {
        if(PlayerData[playerid][pInjured])
        {
            if(IsValidDynamic3DTextLabel(PlayerData[playerid][pInjuredTag]))
            {
                UpdateDynamic3DTextLabelText(PlayerData[playerid][pInjuredTag], COLOR_LIGHTRED, "(( THIS PLAYER IS DEAD ))");
                SendServerMessage(playerid, "You're no longer injured, your character now is"RED" Dead");
            }      
        }        
    }

    if(spawned)
    {
        if(IsValidDynamic3DTextLabel(PlayerData[playerid][pInjuredTag]))
            DestroyDynamic3DTextLabel(PlayerData[playerid][pInjuredTag]);

        PlayerData[playerid][pInjuredTag] = Text3D:INVALID_STREAMER_ID;        
    }
    return 1;
}

hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	#if defined DEBUG_MODE
	    printf("[debug] OnPlayerTakeDamage(PID %d : TID : %d Amount : %.2f WID : %d BodyPart : %d)", playerid, issuerid, amount, weaponid, bodypart);
	#endif

    {
        new 
            Float:armour = GetArmour(playerid), 
            Float:health = GetHealth(playerid)
        ;
        if(PlayerData[playerid][pInjured])
        {
            if(bodypart == BODY_PART_HEAD)
            {
                SetPlayerRate(playerid, 0.0);
            }
            else
            {
                SetPlayerRate(playerid, PlayerData[playerid][pDead] - amount);
            }
        }

        if(issuerid == INVALID_PLAYER_ID)
        {
            SetHealth(playerid, health-amount);
        }
        else if(issuerid != INVALID_PLAYER_ID)
        {
            if(PlayerHasBeanBullets(issuerid) && IsPlayerNearPlayer(issuerid, playerid, 10.0) && !IsPlayerInAnyVehicle(playerid))
            {
                ClearAnimations(playerid);
                ApplyAnimation(playerid, "PED", "KO_SKID_FRONT", 4.1, 0, 0, 0, 0, 0, 1);
                ApplyAnimation(playerid, "PED", "KO_SKID_FRONT", 4.1, 0, 0, 0, 0, 0, 1);
                defer GetUpAnimations(playerid);
            }
        }
        if(issuerid != INVALID_PLAYER_ID) {
            for(new i = 0; i < (10-1); i++) {
                format(damageList[playerid][i], 128, damageList[playerid][1+i]);
            }
            format(damageList[playerid][10-1], 128, "[%s] Issue: %s | Amount: %.2f | Weapon: %d | Body: %d", ReturnDate(), ReturnName(issuerid, 0), amount, weaponid, bodypart);
        }

        if(issuerid != INVALID_PLAYER_ID && !PlayerHasBeanBullets(issuerid) && !PlayerHasTazer(issuerid) && BODY_PART_TORSO <= bodypart <= BODY_PART_HEAD) 
        {   
            if(weaponid >= 0  && weaponid <= 8 && armour >= 0)
            {
                SetHealth(playerid, health-amount);
                AddDamage(playerid, (bodypart - 3), weaponid, amount);
            }
            else if(22 <= weaponid <= 46)
            {
                switch(bodypart)
                {
                    case BODY_PART_TORSO:
                    {
                        switch(weaponid)
                        {
                            case WEAPON_SNIPER:
                            {
                                SetHealth(playerid, health-80);
                                AddDamage(playerid, (bodypart - 3), weaponid, 80);
                            }
                            default:
                            {
                                if(armour > 0)
                                {
                                    AddDamage(playerid, (bodypart - 3), weaponid, amount, true);
                                    SetArmour(playerid, armour-amount); 
                                }
                                else if(armour <= 0)
                                {
                                    AddDamage(playerid, (bodypart - 3), weaponid, amount);
                                    SetHealth(playerid, health-amount);
                                }
                            }
                        }
                    }
                    case BODY_PART_HEAD:
                    {                        
                        switch(weaponid)
                        {  
                           case WEAPON_SNIPER:
                           {
                                SetHealth(playerid, 0);
                                AddDamage(playerid, (bodypart - 3), weaponid, 100);
                           }
                           default:
                           {
                                SetHealth(playerid, health-amount);
                                AddDamage(playerid, (bodypart - 3), weaponid, amount);
                           }
                        }
                    }
                    default :
                    {
                        SetHealth(playerid, health-amount);
                        AddDamage(playerid, (bodypart - 3), weaponid, amount);
                    }
                }
            }
        }

        if(AccountData[playerid][uAdminDuty])
        {
            SetHealth(playerid, 100);
        }

        PlayerData[playerid][pKiller] = issuerid;
        PlayerData[playerid][pKillerReason] = weaponid;
    }
    return 1;
}