DestroyPlayer3DText(playerid)
{

    if(IsValidDynamic3DTextLabel(PlayerData[playerid][pInjuredTag]))
        DestroyDynamic3DTextLabel(PlayerData[playerid][pInjuredTag]);

    PlayerData[playerid][pInjuredTag]   = Text3D:INVALID_STREAMER_ID;
    return 1;
}

ResetEditing(playerid)
{
    switch(PlayerData[playerid][pEditingMode])
    {/*
        case FURNITURE: {
            if(PlayerData[playerid][pEditFurniture] != -1) {
                Furniture_Update(PlayerData[playerid][pEditFurniture]);
                PlayerData[playerid][pEditFurniture] = -1;
            }
        }
        case OBJECTTEXT: {
            if(PlayerData[playerid][pEditTextObject] != -1) {
                ObjectText_Refresh(PlayerData[playerid][pEditTextObject]);
                PlayerData[playerid][pEditTextObject] = -1;
            }
        }*/
        case VEHICLE:
        {
            if(PlayerData[playerid][pEditVehicleObject] != -1 && PlayerData[playerid][pEditVehicleObjectSlot] != -1){
                Vehicle_AttachObject(PlayerData[playerid][pEditVehicleObject], PlayerData[playerid][pEditVehicleObjectSlot]);
                Vehicle_ObjectUpdate(PlayerData[playerid][pEditVehicleObject], PlayerData[playerid][pEditVehicleObjectSlot]);
                
                PlayerData[playerid][pEditVehicleObject] = -1;
                PlayerData[playerid][pEditVehicleObjectSlot] = -1;
            }
        }/*
        case ROADBLOCK:
        {
            if(PlayerData[playerid][pEditRoadblock] != -1)
            {
                Barricade_Sync(PlayerData[playerid][pEditRoadblock]);
                PlayerData[playerid][pEditRoadblock] = -1;
            }
        }*/
    }
    PlayerData[playerid][pEditingMode] = NOTHING;
    return 1;
}

ResetStatistics(playerid) // mereset statistik pemain saat disconnect
{
    PlayerData[playerid][pID] = -1;
    PlayerData[playerid][pGender] = 1;
    PlayerData[playerid][pSkin] = 98;
    PlayerData[playerid][pMoney] = 500;
    PlayerData[playerid][pHealth] = 100;
    PlayerData[playerid][pEditVehicleObject] = -1;
    PlayerData[playerid][pEditVehicleObjectSlot] = -1;
    PlayerData[playerid][pGasPump] = 0;
    PlayerData[playerid][pArmorStatus] = 0;
	PlayerData[playerid][pLogged] = 0;
	PlayerData[playerid][pScore] = 0;
	PlayerData[playerid][pExp] = 0;
    PlayerData[playerid][pBankMoney] = 1000;
	
	PlayerData[playerid][pSalary] = 0;
	PlayerData[playerid][pLogged] = 0;
	PlayerData[playerid][pPaycheck] = 0;
	// Faction
	PlayerData[playerid][pFaction] = -1;
	PlayerData[playerid][pFactionID] = -1;
	PlayerData[playerid][pOnDuty] = false;
	PlayerData[playerid][pFactionEdit] = -1;
	PlayerData[playerid][pFactionRank] = -1;
	PlayerData[playerid][pFactionOffer] = INVALID_PLAYER_ID;
	PlayerData[playerid][pFactionOffered] = -1;

    PlayerData[playerid][pHouse] = -1;
	PlayerData[playerid][pStory] = 0;
    PlayerData[playerid][pInjured] = 0;
    PlayerData[playerid][pInjuredTag] = Text3D:INVALID_STREAMER_ID;
    PlayerData[playerid][pInjuredTime] = 0;
    PlayerData[playerid][pGiveupTime] = 0;
    PlayerData[playerid][pDead] = 0;
    PlayerData[playerid][pKiller] = INVALID_PLAYER_ID;
    PlayerData[playerid][pLastShot] = INVALID_PLAYER_ID;
    PlayerData[playerid][pJob] = 0;
	PlayerData[playerid][pQuitjob] = 0;
    PlayerData[playerid][pBeanBullets] = 0;
    PlayerData[playerid][pTazer] = 0;
	PlayerData[playerid][pStorageSelect] = -1;
	PlayerData[playerid][pSelectedSlot] = -1;
    PlayerData[playerid][pListitem] = -1;
    PlayerData[playerid][pDutyTime] = 0;
    PlayerData[playerid][pDutySecond] = 0;
    PlayerData[playerid][pDutyMinute] = 0;
    PlayerData[playerid][pDutyHour] = 0;
    printf("Resetting player statistics for ID %d", playerid);
    return 1;
}

TerminateConnection(playerid)
{
    if(PlayerData[playerid][pShowFooter]) {
        KillTimer(PlayerData[playerid][pFooterTimer]);
    }
    if(PlayerData[playerid][pFreeze]) {
        stop PlayerData[playerid][pFreezeTimer];
    }
    stop AccountData[playerid][uLoginTimer];

    for (new id = 0; id != MAX_DAMAGE; id++) if(DamageData[playerid][id][damageExists]) {
        Damage_Save(playerid, id);
    }

    foreach(new i : Player)
    {
        if(PlayerData[i][pFactionOffer] == playerid) {
            PlayerData[i][pFactionOffer] = INVALID_PLAYER_ID;
            PlayerData[i][pFactionOffered] = -1;
        }
        if(PlayerData[i][pLastShot] == playerid) {
            PlayerData[i][pLastShot] = INVALID_PLAYER_ID;
        }
    }
    SQL_SaveCharacter(playerid);
    SQL_SaveAccounts(playerid);
    ResetStatistics(playerid);
    return 1;
}