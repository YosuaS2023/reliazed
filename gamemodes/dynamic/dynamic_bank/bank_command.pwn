CMD:bank(playerid, params[])
{
    if(!IsPlayerNearBanker(playerid)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You're not near a banker.");
    SetPVarInt(playerid, "usingATM", 0);
    Bank_ShowMenu(playerid);
    return 1;
}
 
CMD:atm(playerid, params[])
{
    new id = GetClosestATM(playerid);
    if(id == -1) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You're not near an ATM.");
    #if defined ROBBABLE_ATMS
    if(ATMData[id][atmRegen] > 0) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}This ATM is out of service.");
    #endif
 
    SetPVarInt(playerid, "usingATM", 1);
    Bank_ShowMenu(playerid);
    return 1;
}
 
// Admin Commands
CMD:asetowner(playerid, params[])
{
    if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new id, owner[MAX_PLAYER_NAME];
    if(sscanf(params, "is[24]", id, owner)) return SendClientMessage(playerid, 0xE88732FF, "SYNTAX: {FFFFFF}/asetowner [account id] [new owner]");
    new query[128];
    mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_accounts SET Owner='%e' WHERE ID=%d", owner, id);
    mysql_tquery(BankSQLHandle, query, "OnBankAccountAdminEdit", "i", playerid);
    return 1;
}
 
CMD:asetpassword(playerid, params[])
{
    if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new id, password[16];
    if(sscanf(params, "is[16]", id, password)) return SendClientMessage(playerid, 0xE88732FF, "SYNTAX: {FFFFFF}/asetpassword [account id] [new password]");
    new query[128];
    mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_accounts SET Password=md5('%e') WHERE ID=%d", password, id);
    mysql_tquery(BankSQLHandle, query, "OnBankAccountAdminEdit", "i", playerid);
    return 1;
}
 
CMD:asetbalance(playerid, params[])
{
    if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new id, balance;
    if(sscanf(params, "ii", id, balance)) return SendClientMessage(playerid, 0xE88732FF, "SYNTAX: {FFFFFF}/asetbalance [account id] [balance]");
    if(balance > ACCOUNT_LIMIT) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Balance you specified exceeds account money limit.");
    new query[128];
    mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_accounts SET Balance=%d WHERE ID=%d", balance, id);
    mysql_tquery(BankSQLHandle, query, "OnBankAccountAdminEdit", "i", playerid);
    return 1;
}
 
CMD:aclearlogs(playerid, params[])
{
    if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new id, type;
    if(sscanf(params, "iI(0)", id, type))
    {
        SendClientMessage(playerid, 0xE88732FF, "SYNTAX: {FFFFFF}/aclearlogs [account id] [log type (optional)]");
        SendClientMessage(playerid, 0xE88732FF, "TYPES: {FFFFFF}0- All | 1- Logins | 2- Deposits | 3- Withdraws | 4- Transfers | 5- Password Changes");
        return 1;
    }
 
    new query[128];
    if(type > 0) {
        mysql_format(BankSQLHandle, query, sizeof(query), "DELETE FROM bank_logs WHERE AccountID=%d && Type=%d", id, type);
    }else{
        mysql_format(BankSQLHandle, query, sizeof(query), "DELETE FROM bank_logs WHERE AccountID=%d", id);
    }
 
    mysql_tquery(BankSQLHandle, query, "OnBankAccountAdminEdit", "i", playerid);
    return 1;
}
 
CMD:aremoveaccount(playerid, params[])
{
    if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new id;
    if(sscanf(params, "i", id)) return SendClientMessage(playerid, 0xE88732FF, "SYNTAX: {FFFFFF}/aremoveaccount [account id]");
    foreach(new i : Player)
    {
        if(CurrentAccountID[i] == id) CurrentAccountID[i] = -1;
    }
 
    new query[128];
    mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_accounts SET Disabled=1 WHERE ID=%d", id);
    mysql_tquery(BankSQLHandle, query, "OnBankAccountAdminEdit", "i", playerid);
    return 1;
}
 
CMD:areturnaccount(playerid, params[])
{
    if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new id;
    if(sscanf(params, "i", id)) return SendClientMessage(playerid, 0xE88732FF, "SYNTAX: {FFFFFF}/areturnaccount [account id]");
    new query[128];
    mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bank_accounts SET Disabled=0 WHERE ID=%d", id);
    mysql_tquery(BankSQLHandle, query, "OnBankAccountAdminEdit", "i", playerid);
    return 1;
}
 
// Admin Commands for Bankers
CMD:createbanker(playerid, params[])
{
    if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new id = Iter_Free(Bankers);
    if(id == -1) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Can't create any more bankers.");
    new skin;
    if(sscanf(params, "i", skin)) return SendClientMessage(playerid, 0xE88732FF, "SYNTAX: {FFFFFF}/createbanker [skin id]");
    if(!(0 <= skin <= 311)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Invalid skin ID.");
    BankerData[id][Skin] = skin;
    GetPlayerPos(playerid, BankerData[id][bankerX], BankerData[id][bankerY], BankerData[id][bankerZ]);
    GetPlayerFacingAngle(playerid, BankerData[id][bankerA]);
    SetPlayerPos(playerid, BankerData[id][bankerX] + (1.0 * floatsin(-BankerData[id][bankerA], degrees)), BankerData[id][bankerY] + (1.0 * floatcos(-BankerData[id][bankerA], degrees)), BankerData[id][bankerZ]);
 
    BankerData[id][bankerActorID] = CreateActor(skin, BankerData[id][bankerX], BankerData[id][bankerY], BankerData[id][bankerZ], BankerData[id][bankerA]);
    if(IsValidActor(BankerData[id][bankerActorID])) SetActorInvulnerable(BankerData[id][bankerActorID], true);
 
    #if defined BANKER_USE_MAPICON
    BankerData[id][bankerIconID] = CreateDynamicMapIcon(BankerData[id][bankerX], BankerData[id][bankerY], BankerData[id][bankerZ], 58, 0, .streamdistance = BANKER_ICON_RANGE);
    #endif
 
    new label_string[64];
    format(label_string, sizeof(label_string), "Banker (%d)\n\n{FFFFFF}Use {F1C40F}/bank!", id);
    BankerData[id][bankerLabel] = CreateDynamic3DTextLabel(label_string, 0x1ABC9CFF, BankerData[id][bankerX], BankerData[id][bankerY], BankerData[id][bankerZ] + 0.25, 5.0, .testlos = 1);
 
    new query[144];
    mysql_format(BankSQLHandle, query, sizeof(query), "INSERT INTO bankers SET ID=%d, Skin=%d, PosX='%f', PosY='%f', PosZ='%f', PosA='%f'", id, skin, BankerData[id][bankerX], BankerData[id][bankerY], BankerData[id][bankerZ], BankerData[id][bankerA]);
    mysql_tquery(BankSQLHandle, query);
 
    Iter_Add(Bankers, id);
    return 1;
}
 
CMD:setbankerpos(playerid, params[])
{
    if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new id;
    if(sscanf(params, "i", id)) return SendClientMessage(playerid, 0xE88732FF, "SYNTAX: {FFFFFF}/setbankerpos [banker id]");
    if(!Iter_Contains(Bankers, id)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Invalid banker ID.");
    GetPlayerPos(playerid, BankerData[id][bankerX], BankerData[id][bankerY], BankerData[id][bankerZ]);
    GetPlayerFacingAngle(playerid, BankerData[id][bankerA]);
 
    DestroyActor(BankerData[id][bankerActorID]);
    BankerData[id][bankerActorID] = CreateActor(BankerData[id][Skin], BankerData[id][bankerX], BankerData[id][bankerY], BankerData[id][bankerZ], BankerData[id][bankerA]);
    if(IsValidActor(BankerData[id][bankerActorID])) SetActorInvulnerable(BankerData[id][bankerActorID], true);
 
    #if defined BANKER_USE_MAPICON
    Streamer_SetFloatData(STREAMER_TYPE_MAP_ICON, BankerData[id][bankerIconID], E_STREAMER_X, BankerData[id][bankerX]);
    Streamer_SetFloatData(STREAMER_TYPE_MAP_ICON, BankerData[id][bankerIconID], E_STREAMER_Y, BankerData[id][bankerY]);
    Streamer_SetFloatData(STREAMER_TYPE_MAP_ICON, BankerData[id][bankerIconID], E_STREAMER_Z, BankerData[id][bankerZ]);
    #endif
 
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, BankerData[id][bankerLabel], E_STREAMER_X, BankerData[id][bankerX]);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, BankerData[id][bankerLabel], E_STREAMER_Y, BankerData[id][bankerY]);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, BankerData[id][bankerLabel], E_STREAMER_Z, BankerData[id][bankerZ]);
 
    SetPlayerPos(playerid, BankerData[id][bankerX] + (1.0 * floatsin(-BankerData[id][bankerA], degrees)), BankerData[id][bankerY] + (1.0 * floatcos(-BankerData[id][bankerA], degrees)), BankerData[id][bankerZ]);
 
    new query[144];
    mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bankers SET PosX='%f', PosY='%f', PosZ='%f', PosA='%f' WHERE ID=%d", BankerData[id][bankerX], BankerData[id][bankerY], BankerData[id][bankerZ], BankerData[id][bankerA], id);
    mysql_tquery(BankSQLHandle, query);
    return 1;
}
 
CMD:setbankerskin(playerid, params[])
{
    if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new id, skin;
    if(sscanf(params, "ii", id, skin)) return SendClientMessage(playerid, 0xE88732FF, "SYNTAX: {FFFFFF}/setbankerskin [banker id] [skin id]");
    if(!Iter_Contains(Bankers, id)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Invalid banker ID.");
    if(!(0 <= skin <= 311)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Invalid skin ID.");
    BankerData[id][Skin] = skin;
 
    if(IsValidActor(BankerData[id][bankerActorID])) DestroyActor(BankerData[id][bankerActorID]);
    BankerData[id][bankerActorID] = CreateActor(BankerData[id][Skin], BankerData[id][bankerX], BankerData[id][bankerY], BankerData[id][bankerZ], BankerData[id][bankerA]);
    if(IsValidActor(BankerData[id][bankerActorID])) SetActorInvulnerable(BankerData[id][bankerActorID], true);
 
    new query[48];
    mysql_format(BankSQLHandle, query, sizeof(query), "UPDATE bankers SET Skin=%d WHERE ID=%d", BankerData[id][Skin], id);
    mysql_tquery(BankSQLHandle, query);
    return 1;
}
 
CMD:removebanker(playerid, params[])
{
    if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new id;
    if(sscanf(params, "i", id)) return SendClientMessage(playerid, 0xE88732FF, "SYNTAX: {FFFFFF}/removebanker [banker id]");
    if(!Iter_Contains(Bankers, id)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Invalid banker ID.");
    if(IsValidActor(BankerData[id][bankerActorID])) DestroyActor(BankerData[id][bankerActorID]);
    BankerData[id][bankerActorID] = -1;
 
    #if defined BANKER_USE_MAPICON
    if(IsValidDynamicMapIcon(BankerData[id][bankerIconID])) DestroyDynamicMapIcon(BankerData[id][bankerIconID]);
    BankerData[id][bankerIconID] = -1;
    #endif
 
    if(IsValidDynamic3DTextLabel(BankerData[id][bankerLabel])) DestroyDynamic3DTextLabel(BankerData[id][bankerLabel]);
    BankerData[id][bankerLabel] = Text3D: -1;
 
    Iter_Remove(Bankers, id);
 
    new query[48];
    mysql_format(BankSQLHandle, query, sizeof(query), "DELETE FROM bankers WHERE ID=%d", id);
    mysql_tquery(BankSQLHandle, query);
    return 1;
}
 
// Admin Commands for ATMs
CMD:createatm(playerid, params[])
{
    if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new id = Iter_Free(ATMs);
    if(id == -1) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Can't create any more ATMs.");
    ATMData[id][atmRX] = ATMData[id][atmRY] = 0.0;
 
    GetPlayerPos(playerid, ATMData[id][atmX], ATMData[id][atmY], ATMData[id][atmZ]);
    GetPlayerFacingAngle(playerid, ATMData[id][atmRZ]);
 
    ATMData[id][atmX] += (2.0 * floatsin(-ATMData[id][atmRZ], degrees));
    ATMData[id][atmY] += (2.0 * floatcos(-ATMData[id][atmRZ], degrees));
    ATMData[id][atmZ] -= 0.3;
 
    ATMData[id][atmObjID] = CreateDynamicObject(19324, ATMData[id][atmX], ATMData[id][atmY], ATMData[id][atmZ], ATMData[id][atmRX], ATMData[id][atmRY], ATMData[id][atmRZ]);
    if(IsValidDynamicObject(ATMData[id][atmObjID]))
    {
        #if defined ROBBABLE_ATMS
        new dataArray[E_ATMDATA];
        format(dataArray[IDString], 8, "atm_sys");
        dataArray[refID] = id;
        Streamer_SetArrayData(STREAMER_TYPE_OBJECT, ATMData[id][atmObjID], E_STREAMER_EXTRA_ID, dataArray);
        #endif
        
        EditingATMID[playerid] = id;
        EditDynamicObject(playerid, ATMData[id][atmObjID]);
    }
 
    #if defined ATM_USE_MAPICON
    ATMData[id][atmIconID] = CreateDynamicMapIcon(ATMData[id][atmX], ATMData[id][atmY], ATMData[id][atmZ], 52, 0, .streamdistance = ATM_ICON_RANGE);
    #endif
 
    new label_string[64];
    format(label_string, sizeof(label_string), "ATM (%d)\n\n{FFFFFF}Use {F1C40F}/atm!", id);
    ATMData[id][atmLabel] = CreateDynamic3DTextLabel(label_string, 0x1ABC9CFF, ATMData[id][atmX], ATMData[id][atmY], ATMData[id][atmZ] + 0.85, 5.0, .testlos = 1);
 
    new query[144];
    mysql_format(BankSQLHandle, query, sizeof(query), "INSERT INTO bank_atms SET ID=%d, PosX='%f', PosY='%f', PosZ='%f', RotX='%f', RotY='%f', RotZ='%f'", id, ATMData[id][atmX], ATMData[id][atmY], ATMData[id][atmZ], ATMData[id][atmRX], ATMData[id][atmRY], ATMData[id][atmRZ]);
    mysql_tquery(BankSQLHandle, query);
 
    Iter_Add(ATMs, id);
    return 1;
}
 
CMD:editatm(playerid, params[])
{
    if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new id;
    if(sscanf(params, "i", id)) return SendClientMessage(playerid, 0xE88732FF, "SYNTAX: {FFFFFF}/editatm [ATM id]");
    if(!Iter_Contains(ATMs, id)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Invalid ATM ID.");
    if(!IsPlayerInRangeOfPoint(playerid, 30.0, ATMData[id][atmX], ATMData[id][atmY], ATMData[id][atmZ])) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You're not near the ATM you want to edit.");
    if(EditingATMID[playerid] != -1) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You're already editing an ATM.");
    EditingATMID[playerid] = id;
    EditDynamicObject(playerid, ATMData[id][atmObjID]);
    return 1;
}
 
CMD:removeatm(playerid, params[])
{
    if(CheckAdmin(playerid, 4)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new id;
    if(sscanf(params, "i", id)) return SendClientMessage(playerid, 0xE88732FF, "SYNTAX: {FFFFFF}/removeatm [ATM id]");
    if(!Iter_Contains(ATMs, id)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Invalid ATM ID.");
    if(IsValidDynamicObject(ATMData[id][atmObjID])) DestroyDynamicObject(ATMData[id][atmObjID]);
    ATMData[id][atmObjID] = -1;
 
    #if defined ATM_USE_MAPICON
    if(IsValidDynamicMapIcon(ATMData[id][atmIconID])) DestroyDynamicMapIcon(ATMData[id][atmIconID]);
    ATMData[id][atmIconID] = -1;
    #endif
 
    if(IsValidDynamic3DTextLabel(ATMData[id][atmLabel])) DestroyDynamic3DTextLabel(ATMData[id][atmLabel]);
    ATMData[id][atmLabel] = Text3D: -1;
 
    #if defined ROBBABLE_ATMS
    if(ATMData[id][atmTimer] != -1) KillTimer(ATMData[id][atmTimer]);
    ATMData[id][atmTimer] = -1;
 
    if(IsValidDynamicPickup(ATMData[id][atmPickup])) DestroyDynamicPickup(ATMData[id][atmPickup]);
    ATMData[id][atmPickup] = -1;
 
    ATMData[id][atmHealth] = ATM_HEALTH;
    ATMData[id][atmRegen] = 0;
    #endif
    
    Iter_Remove(ATMs, id);
    
    new query[48];
    mysql_format(BankSQLHandle, query, sizeof(query), "DELETE FROM bank_atms WHERE ID=%d", id);
    mysql_tquery(BankSQLHandle, query);
    return 1;
}