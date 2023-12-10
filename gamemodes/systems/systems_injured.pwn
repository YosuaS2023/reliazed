#include <YSI\y_hooks>
#include <wep-config>

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
 /*/   if(PlayerData[playerid][pCallLine] != INVALID_PLAYER_ID)
    {
        SendClientMessage(PlayerData[playerid][pCallLine], X11_YELLOW_2, "[PHONE]:"WHITE" The line went dead...");
        CancelCall(playerid);
    }*/
    /*PlayerTextDrawHide(playerid, PlayerTextdraws[playerid][textdraw_supply]);
    ResetPlayer(playerid);*/

    InjuredTag(playerid, true);

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

    foreach(new i : Player)
    {
        if(AccountData[i][uAdmin] > 0)
        {
            SendDeathMessageToPlayer(i, killerid, playerid, reason);
        }
    }

    SendClientMessage(playerid, X11_TOMATO_1, "WARNING:"WHITE" Anda terluka dan membutuhkan pertolongan medis (/call 911 > medics | pengembangan).");
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
public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	#if defined DEBUG_MODE
	    printf("[debug] OnPlayerTakeDamage(PID %d : TID : %d Amount : %.2f WID : %d BodyPart : %d)", playerid, issuerid, amount, weaponid, bodypart);
	#endif

    //if(!IsPlayerInEvent(playerid))
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

            /*if(PlayerData[playerid][pFirstAid])
            {
                SendClientMessage(playerid, X11_TOMATO_1, "WARNING:"WHITE" Your first aid kit is no longer in effect as you took damage.");

                PlayerData[playerid][pFirstAid] = false;
                stop PlayerData[playerid][pAidTimer];
            }*/
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


public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
	#if defined DEBUG_MODE
	    printf("[debug] OnPlayerGiveDamage(PID : %d TID : %d Amount : %.2f WID : %d Body-Part : %d)", playerid, damagedid, amount, weaponid, bodypart);
	#endif

    if(damagedid != INVALID_PLAYER_ID && weaponid == WEAPON_CHAINSAW) {
        TogglePlayerControllable(playerid, 0);
        SetPlayerArmedWeapon(playerid, 0);
        TogglePlayerControllable(playerid, 1);
        SetCameraBehindPlayer(playerid);

        SetPVarInt(playerid, "ChainsawWarning", GetPVarInt(playerid, "ChainsawWarning")+1);

        if(GetPVarInt(playerid, "ChainsawWarning") == 3) {
            SendClientMessageToAllEx(X11_TOMATO_1, "AdmCmd: %s was kicked by BOT. Reason: Abusing Chainsaw", ReturnName2(playerid, 0));
            DeletePVar(playerid, "ChainsawWarning");
            KickEx(playerid);
        }
    }
    return 1;
}
