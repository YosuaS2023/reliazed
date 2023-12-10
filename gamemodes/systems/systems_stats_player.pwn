#define MAX_DAMAGE                      (55)
#define TOTAL_BODY_STATUS				(7)

enum damageData {
    damageID,
    damageExists,
    damageBodypart,
    damageWeapon,
    Float:damageAmount,
	Float:damageKevlar,
    damageTime
};

new DamageData[MAX_PLAYERS][MAX_DAMAGE][damageData];
new damageList[MAX_PLAYERS][10][128];

DamageCreated(playerid, damageid)
{
    DamageData[playerid][damageid][damageID] = cache_insert_id();
    Damage_Save(playerid, damageid);
    return 1;
}

stock Damage_Remove(playerid, damage)
{
    mysql_tquery(sqlcon, sprintf("DELETE FROM `damages` WHERE `ID`='%d' AND `IDs`='%d'", DamageData[playerid][damage][damageID], PlayerData[playerid][pID]));

    DamageData[playerid][damage][damageExists] = false;
    DamageData[playerid][damage][damageWeapon] = 0;

    DamageData[playerid][damage][damageBodypart] = 0;
    DamageData[playerid][damage][damageTime] = 0;
    DamageData[playerid][damage][damageAmount] = 0;
    DamageData[playerid][damage][damageID] = 0;
    return 1;
}

stock Damage_Reset(playerid, type = 0)
{
    if(!type)
        mysql_tquery(sqlcon, sprintf("DELETE FROM `damages` WHERE `IDs`='%d'", PlayerData[playerid][pID]));

    for(new id; id != MAX_DAMAGE; id++) if(DamageData[playerid][id][damageExists])
    {
        DamageData[playerid][id][damageExists] = false;
        DamageData[playerid][id][damageWeapon] = DamageData[playerid][id][damageBodypart] = 0;
        DamageData[playerid][id][damageTime] = DamageData[playerid][id][damageID] = 0;
        DamageData[playerid][id][damageAmount] = DamageData[playerid][id][damageKevlar] = 0;
    }
    return 1;
}

Damage_Save(playerid, damage)
{
    new query[512];

    format(query, sizeof(query), "UPDATE `damages` SET `weapon`= '%d', `bodypart`= '%d', `amount`= '%.2f', `amountkevlar`= '%.2f', `time`= '%d' WHERE ID = '%d' AND IDs = '%d'",
        DamageData[playerid][damage][damageWeapon],
        DamageData[playerid][damage][damageBodypart],
        DamageData[playerid][damage][damageAmount],
        DamageData[playerid][damage][damageKevlar],
        DamageData[playerid][damage][damageTime],
        DamageData[playerid][damage][damageID],
        PlayerData[playerid][pID]
    );
    return mysql_tquery(sqlcon, query);
}
    
AddDamage(playerid, bodypart, weapon, Float:amount, bool:kevlarhit = false)
{
    for (new id = 0; id != MAX_DAMAGE; id++)
    {
        if(DamageData[playerid][id][damageExists] && DamageData[playerid][id][damageWeapon] == weapon && DamageData[playerid][id][damageBodypart] == bodypart)
        {
            if(!kevlarhit) DamageData[playerid][id][damageAmount] += amount;
            else DamageData[playerid][id][damageKevlar] += amount;
            DamageData[playerid][id][damageTime] = gettime();
            return 1;
        }
        else if(!DamageData[playerid][id][damageExists])
        {
            DamageData[playerid][id][damageExists] = true;
            DamageData[playerid][id][damageWeapon] = weapon;
            DamageData[playerid][id][damageBodypart] = bodypart;
            if(!kevlarhit) DamageData[playerid][id][damageAmount] = amount;
            else DamageData[playerid][id][damageKevlar] = amount;
            DamageData[playerid][id][damageTime] = gettime();
            mysql_tquery(sqlcon, sprintf("INSERT INTO `damages` SET `weapon`='%d', `bodypart`='%d', `amount`='%.2f', `amountkevlar`='%.2f', `IDs`='%d'", DamageData[playerid][id][damageWeapon], DamageData[playerid][id][damageBodypart], DamageData[playerid][id][damageAmount], DamageData[playerid][id][damageKevlar], PlayerData[playerid][pID]), "DamageCreated", "dd", playerid, id);
            return 1;
        }
    }
    return 1;
}

stock Damage_Count(playerid)
{
    new count = 0;
    for(new i; i != MAX_DAMAGE; i++) if(DamageData[playerid][i][damageExists]) {
        count ++;
    }
    return count;
}


Damage_Show(playerid, player)
{
    new title[64];
    format(title, sizeof(title), "%s's Body Status", ReturnName(player));
    new 
        string[4096],
        torso_str[1024],
        groin_str[1024],
        leftarm_str[1024],
        rightarm_str[1024],
        leftleg_str[1024],
        rightleg_str[1024],
        head_str[1024]
    ;
    for(new i = 0; i < MAX_DAMAGE; i++)
    {
        if(DamageData[player][i][damageExists])
        {
            switch(DamageData[player][i][damageBodypart] + 3)
            {
                case BODY_PART_TORSO:
                {
                    strcat(torso_str, sprintf(""WHITE"Weapon "GREEN"%s "WHITE"Amount "YELLOW"%.2f "WHITE"Kevlar Hit "YELLOW"(%.2f) "RED"%s\n", ReturnWeaponName(DamageData[player][i][damageWeapon]), DamageData[player][i][damageAmount],DamageData[player][i][damageKevlar], GetDuration(gettime() - DamageData[player][i][damageTime])));
                }
                case BODY_PART_GROIN:
                {
                    strcat(groin_str, sprintf(""WHITE"Weapon "GREEN"%s "WHITE"Amount "YELLOW"%.2f "WHITE"Kevlar Hit "YELLOW"(%.2f) "RED"%s\n", ReturnWeaponName(DamageData[player][i][damageWeapon]), DamageData[player][i][damageAmount],DamageData[player][i][damageKevlar], GetDuration(gettime() - DamageData[player][i][damageTime])));
                }
                case BODY_PART_LEFT_ARM:
                {
                    strcat(leftarm_str, sprintf(""WHITE"Weapon "GREEN"%s "WHITE"Amount "YELLOW"%.2f "WHITE"Kevlar Hit "YELLOW"(%.2f) "RED"%s\n", ReturnWeaponName(DamageData[player][i][damageWeapon]), DamageData[player][i][damageAmount],DamageData[player][i][damageKevlar], GetDuration(gettime() - DamageData[player][i][damageTime])));
                }
                case BODY_PART_RIGHT_ARM:
                {
                    strcat(rightarm_str, sprintf(""WHITE"Weapon "GREEN"%s "WHITE"Amount "YELLOW"%.2f "WHITE"Kevlar Hit "YELLOW"(%.2f) "RED"%s\n", ReturnWeaponName(DamageData[player][i][damageWeapon]), DamageData[player][i][damageAmount],DamageData[player][i][damageKevlar], GetDuration(gettime() - DamageData[player][i][damageTime])));
                }
                case BODY_PART_LEFT_LEG:
                {
                    strcat(leftleg_str, sprintf(""WHITE"Weapon "GREEN"%s "WHITE"Amount "YELLOW"%.2f "WHITE"Kevlar Hit "YELLOW"(%.2f) "RED"%s\n", ReturnWeaponName(DamageData[player][i][damageWeapon]), DamageData[player][i][damageAmount],DamageData[player][i][damageKevlar], GetDuration(gettime() - DamageData[player][i][damageTime])));
                }
                case BODY_PART_RIGHT_LEG:
                {
                    strcat(rightleg_str, sprintf(""WHITE"Weapon "GREEN"%s "WHITE"Amount "YELLOW"%.2f "WHITE"Kevlar Hit "YELLOW"(%.2f) "RED"%s\n", ReturnWeaponName(DamageData[player][i][damageWeapon]), DamageData[player][i][damageAmount],DamageData[player][i][damageKevlar], GetDuration(gettime() - DamageData[player][i][damageTime])));
                }
                case BODY_PART_HEAD:
                {
                    strcat(head_str, sprintf(""WHITE"Weapon "GREEN"%s "WHITE"Amount "YELLOW"%.2f "WHITE"Kevlar Hit "YELLOW"(%.2f) "RED"%s\n", ReturnWeaponName(DamageData[player][i][damageWeapon]), DamageData[player][i][damageAmount],DamageData[player][i][damageKevlar], GetDuration(gettime() - DamageData[player][i][damageTime])));
                }
            }    
        }
    }
    if(strlen(torso_str) == 0) 
    {
        format(torso_str, sizeof(torso_str), ""GREEN"Healthy\n"WHITE"");
    }
    if(strlen(groin_str) == 0) 
    {
        format(groin_str, sizeof(groin_str), ""GREEN"Healthy\n"WHITE"");
    }
    if(strlen(leftarm_str) == 0) 
    {
        format(leftarm_str, sizeof(leftarm_str), ""GREEN"Healthy\n"WHITE"");
    }
    if(strlen(rightarm_str) == 0) 
    {
        format(rightarm_str, sizeof(rightarm_str), ""GREEN"Healthy\n"WHITE"");
    }
    if(strlen(leftleg_str) == 0) 
    {
        format(leftleg_str, sizeof(leftleg_str), ""GREEN"Healthy\n"WHITE"");
    }
    if(strlen(rightleg_str) == 0) 
    {
        format(rightleg_str, sizeof(rightleg_str), ""GREEN"Healthy\n"WHITE"");
    }
    if(strlen(head_str) == 0) 
    {
        format(head_str, sizeof(head_str), ""GREEN"Healthy\n"WHITE"");
    }

    format(string, sizeof(string), ""RED"[Torso]\n%s\n"RED"[Groin]\n%s\n"RED"[Left Arm]\n%s\n"RED"[Right Arm]\n%s\n"RED"[Left Leg]\n%s\n"RED"[Right Leg]\n%s\n"RED"[Head]\n%s",
    torso_str,
    groin_str,
    leftarm_str,
    rightarm_str,
    leftleg_str,
    rightleg_str,
    head_str
    );


    Dialog_Show(playerid, DisplayDamage, DIALOG_STYLE_MSGBOX, title, string,"Close","");
    return 1;
}

CMD:damages(playerid, params[])
{
    new player;

    if(sscanf(params, "u", player))
    {
        return Damage_Show(playerid, playerid);
    }

    if(player == playerid) return SendErrorMessage(playerid, "Use command /damages to check your damages.");
    if(player == INVALID_PLAYER_ID || !IsPlayerNearPlayer(playerid, player, 3.0)) return SendErrorMessage(playerid, "That player is disconnected or not near you.");
    //if(PlayerData[player][pSpectator] != INVALID_PLAYER_ID) return SendErrorMessage(playerid, "That player is disconnected or not near you.");

    SendServerMessage(player, "%s melihat kondisi karakter anda.", ReturnName(playerid, 0));
    SendServerMessage(playerid, "Anda melihat kondisi karakter %s.", ReturnName(player, 0));
    Damage_Show(playerid, player);
    return 1;
}

CMD:resetdamage(playerid, params[])
{
    new player;

    if (CheckAdmin(playerid, 4))
        return PermissionError(playerid);

    if(sscanf(params, "u", player))
        return SendSyntaxMessage(playerid, "/resetdamage [playerid/part of name]");

    if(!IsPlayerConnected(player))
        return SendErrorMessage(playerid, "That player isn't logged in.");

    Damage_Reset(player);
    SendServerMessage(player, "Admin %s telah mereset damage anda.", ReturnAdminName(playerid));
    SendAdminMessage(X11_TOMATO_1, "AdmWarn: %s reset %s damages.", ReturnName(playerid),ReturnName(player));
    return 1;
}

CMD:resetshooter(playerid, params[])
{
    static
        userid;

    if (CheckAdmin(playerid, 4))
        return PermissionError(playerid);

    if(sscanf(params, "u", userid)) return SendSyntaxMessage(playerid, "/shooter [playerid/PartOfName]");
    if(userid == INVALID_PLAYER_ID) return SendErrorMessage(playerid, "You have specified an invalid player.");

    for(new i = 0; i < 10; i++) {
        damageList[userid][i] = "None";
    }
    SendServerMessage(playerid, "Successfull reset shooter list for %s.", ReturnName(userid));
    return 1;
}