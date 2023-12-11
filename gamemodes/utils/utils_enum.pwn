enum damageData {
    damageID,
    damageExists,
    damageBodypart,
    damageWeapon,
    Float:damageAmount,
	Float:damageKevlar,
    damageTime
};

enum e_MotdData {
	motdPlayer[70],
	motdAdmin[70]
}

enum gov_data
{
	govTax,
	govVault,
	STREAMER_TAG_OBJECT:govDoor,
	govButton[2],
	bool:govDoorStatus,
}

enum UserData {
	//ucp player
	uID,
    uUsername[MAX_PLAYER_NAME + 1],
    uPassword[65],
    uSalt[65],
    uIP[16],
    uLogged,
    uLeaveIP,
    uRegisterDate,
    Timer:uLoginTimer,
    uLoginAttempts,

    //admin
    uAdmin,
	uDeveloper,
    uAdminHide,
    uAdminDuty,
    uReportPoint,
    uLoginDate,
    uAdminDutyTime,
    uAdminAcceptReport,
    uAdminDeniedReport,
    uAdminAcceptStuck,
    uAdminDeniedStuck,
    uAdminBanned,
    uAdminUnbanned,
    uAdminJail,
    uAdminAnswer,
    uAdminRankName
};

enum e_player_data
{
	pID,
	pCharacter,
	Float:pHealth,
    Float:pArmorStatus,
	Float:pPos[4],
	pCreated,
	pStory,
    pInjured,
    Text3D:pInjuredTag,
    pInjuredTime,
    pGiveupTime,
    Float:pDead,
    pKiller,
    pKillerReason,
    pLastShot,
    pShotTime,
	pMoney,
	pPaycheck,
	pSalary,
	pOrigin[32],
	pExp,
    pJob,
	pQuitjob,
	pGender,
	pSkin,
	pBirthdate[24],
	pBankMoney,
	pWorld,
	pInterior,
	pKicked,
	pLogged,
	pMaskOn,
	pMaskID,
	pKilled,
	pShowFooter,
	pFooterTimer,
	pDisableAdmin,
	pDisableLogin,
	pFreeze,
	Timer:pFreezeTimer,
	pSpawnPoint,
	pScore,
	pAlias,
	pRegisterDate,
	pMinute,
	pHour,
	pSecond,
    pBeanBullets,
    pTazer,
	pStorageSelect,
	pSelectedSlot,
    pListitem,
	//Faction
	pFaction,
	pFactionID,
	pFactionRank,
	pOnDuty,
    pDutyTime,
    pDutySecond,
    pDutyMinute,
    pDutyHour,
	pFactionEdit,
	pFactionOffer,
	pFactionOffered,
    pFactionSkin,
	Timer:pPtask_Stats
};

enum
{
	DIALOG_UNUSED,
	DIALOG_REGISTER,
	DIALOG_LOGIN,
	DIALOG_PASSWORD,
	DIALOG_SELECTCHAR,
	DIALOG_CREATECHAR,
	DIALOG_PERSONAL,
	DIALOG_GENDER,
	DIALOG_DATEBIRTH,
	DIALOG_ORIGIN,
    //
    DIALOG_FACTION_MENU,
	DIALOG_FACTION_RETURN,
	DIALOG_EDITFACTION_SALARY_LIST,
	DIALOG_EDITFACTION_SALARY_SET,
	DIALOG_EDITRANK,
	DIALOG_EDITRANK_NAME,
	DIALOG_LOCKER,
	DIALOG_LOCKER_WEAPON,
	DIALOG_EDITLOCKER,
	DIALOG_EDITLOCKER_WEAPON,
	DIALOG_EDITLOCKER_WEAPON_SET,
	DIALOG_EDITLOCKER_WEAPON_ID,
	DIALOG_EDITLOCKER_WEAPON_AMMO,
	DIALOG_EDITLOCKER_SKIN,
	DIALOG_EDITLOCKER_SKIN_MODEL,
};

enum    _:E_ISSUE {
    THREAD_CREATE_CHAR = 1,
    THREAD_LIST_CHARACTERS,
    THREAD_FIND_USERNAME,
    THREAD_LOAD_CHARACTERS,
    THREAD_LOAD_DAMAGES,
    THREAD_LOAD_INVENTORY
};

enum playerTextraws {
    PlayerText:textdraw_footer,
	PlayerText:textdraw_ammo
};


enum    _:E_SELECTION_TYPE {
    MODEL_SELECTION_NONE = 0,
    MODEL_SELECTION_SKIN ,
    MODEL_SELECTION_FACTION_SKIN     ,
    MODEL_SELECTION_FACTION_SKINS,
    MODEL_SELECTION_ADD_SKIN
}

enum
{
  E_LOG_NONE = 0,
  E_LOG_ACP_BAN,
  E_LOG_ADD_SALARY,
  E_LOG_ADMIN_CHAT,
  E_LOG_ADMIN_COMMAND,
  E_LOG_ADMIN_RESET_PASSWORD,
  E_LOG_ADMIN_SELL,
  E_LOG_BAN,
  E_LOG_BIZ,
  E_LOG_BUSINESS,
  E_LOG_CHANGE_CHAR_NAME,
  E_LOG_CHARITY,
  E_LOG_CHEAT,
  E_LOG_CONNECTIONS,
  E_LOG_CREATE_VEHICLE,
  E_LOG_CURE,
  E_LOG_DEPOSIT,
  E_LOG_DESTROY_ITEM,
  E_LOG_DROP_PICK,
  E_LOG_DROP_WEAPON,
  E_LOG_DYNAMIC_JOB,
  E_LOG_DYNAMIC_VEHICLE,
  E_LOG_EDIT_OBJECT,
  E_LOG_FACTION_CHAT,
  E_LOG_FACTION_OOC_CHAT,
  E_LOG_FINE_COIN,
  E_LOG_FINE,
  E_LOG_FACTION_WITHDRAW,
  E_LOG_GARAGE,
  E_LOG_GENERATE_COIN,
  E_LOG_GENERATE_VIP,
  E_LOG_GIVE,
  E_LOG_GUN_AUTH,
  E_LOG_HEAL,
  E_LOG_HOUSE_ITEMS,
  E_LOG_HOUSE,
  E_LOG_HOUSE_SAFE,
  E_LOG_IP_BAN,
  E_LOG_JAIL,
  E_LOG_KICK,
  E_LOG_KILL,
  E_LOG_LEAVE_TAXI,
  E_LOG_LICENSE,
  E_LOG_MYSQL,
  E_LOG_OFFER,
  E_LOG_OFFER_VEH,
  E_LOG_OFFLINE_FINE,
  E_LOG_OFFLINE_FINE_COIN,
  E_LOG_PAY,
  E_LOG_PM,
  E_LOG_RCON,
  E_LOG_REDEEM_CODE,
  E_LOG_REDEEM_COIN,
  E_LOG_RESET_STORAGE,
  E_LOG_RESET_VIP,
  E_LOG_SET_ACP_NAME,
  E_LOG_SET_ADMIN,
  E_LOG_SET_ITEM,
  E_LOG_SET_NAME,
  E_LOG_SET_PLAYER,
  E_LOG_SPAWN_ITEM,
  E_LOG_STORAGE,
  E_LOG_TEMP_BAN,
  E_LOG_TICKET,
  E_LOG_TRANSFER,
  E_LOG_UNWARN,
  E_LOG_VEHICLE_STORAGE,
  E_LOG_VENDING_MACHINE,
  E_LOG_WARN,
  E_LOG_WEAPON,
  E_LOG_WITHDRAW,
  E_LOG_APARTMENT_ITEMS,
  E_LOG_APARTMENT,
  E_LOG_APARTMENT_SAFE,
};

enum {
    JOB_NONE = 0,
    JOB_COURIER,   
    JOB_MECHANIC,  
    JOB_TAXI,    
    JOB_UNLOADER,  
    JOB_MINER,     
    JOB_FOOD_VENDOR, 
    JOB_SORTER,    
    JOB_ARMS_DEALER,
    JOB_LUMBERJACK
}

enum e_faction_vehicle
{
	fvID,
	bool:fvExists,
	fvModel,
	Float:fvPos[4],
	fvColor[2],
	fvFaction,
	fvVehicle,
};

enum vCore
{
	vehFuel,
	bool:vehRepair,
	bool:vehAdmin,
	bool:vehHandbrake,
	Float:vehHandbrakePos[4],
	vehWood,
	bool:vehHood,
	bool:vehBoot,
};

// Job
enum
{
	JOB_POS_ICON = 0,
	JOB_POS_LABEL,
	JOB_POS_LABEL_POINT,
	JOB_POS_PICKUP,
	JOB_POS_PICKUP_POINT
}

enum jobData {
    jobID,
    jobExists,
    jobType,
    Float:jobPos[3],
    Float:jobPoint[3],
    Float:jobDeliver[3],
    jobInterior,
    jobWorld,
    jobPointInt,
    jobPointWorld,
    jobStock,
    jobPickups[3],
    jobIcon,
    jobPrison,
    Text3D:jobText3D[3]
};

// Inventory
enum inventoryData
{
	invExists,
	invID,
	invItem[32 char],
	invModel,
	invQuantity
};

enum e_InventoryItems
{
	e_InventoryItem[32],
	e_InventoryModel
};