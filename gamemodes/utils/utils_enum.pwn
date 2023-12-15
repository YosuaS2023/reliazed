enum damageData {
    damageID,
    damageExists,
    damageBodypart,
    damageWeapon,
    Float:damageAmount,
	Float:damageKevlar,
    damageTime
};

enum
{
    INVALID_AREA_INDEX = 0,
    ATM_AREA_INDEX,
    PLANT_AREA_INDEX,
    SPEED_AREA_INDEX,
    BARRICADE_AREA_INDEX,
    FIRE_AREA_INDEX,
    VENDING_AREA_INDEX,
    DRUGLAB_AREA_INDEX
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
    pHouse,
    pStar,
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
    pEditingMode,
    pEditVehicleObject,
    pEditVehicleObjectSlot,
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
    pGasPump,
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

enum enum_listCommands
{
    listCommandName[30],
    listCommandType
};

enum    _:E_BANK_DIALOG
{
    DIALOG_BANK_MENU_NOLOGIN = 12450,
    DIALOG_BANK_MENU,
    DIALOG_BANK_CREATE_ACCOUNT,
    DIALOG_BANK_ACCOUNTS,
    DIALOG_BANK_LOGIN_ID,
    DIALOG_BANK_LOGIN_PASS,
    DIALOG_BANK_DEPOSIT,
    DIALOG_BANK_WITHDRAW,
    DIALOG_BANK_TRANSFER_1,
    DIALOG_BANK_TRANSFER_2,
    DIALOG_BANK_PASSWORD,
    DIALOG_BANK_REMOVE,
    DIALOG_BANK_LOGS,
    DIALOG_BANK_LOG_PAGE
}
 
enum    _:E_BANK_LOGTYPE
{
    TYPE_NONE,
    TYPE_LOGIN,
    TYPE_DEPOSIT,
    TYPE_WITHDRAW,
    TYPE_TRANSFER,
    TYPE_PASSCHANGE
}
 
#if defined ROBBABLE_ATMS
enum    _:E_ATMDATA
{
    IDString[8],
    refID
}
#endif
 
enum    E_BANKER
{
    // saved
    Skin,
    Float: bankerX,
    Float: bankerY,
    Float: bankerZ,
    Float: bankerA,
    // temp
    bankerActorID,
    #if defined BANKER_USE_MAPICON
    bankerIconID,
    #endif
    Text3D: bankerLabel
}
 
enum    E_ATM
{
    // saved
    Float: atmX,
    Float: atmY,
    Float: atmZ,
    Float: atmRX,
    Float: atmRY,
    Float: atmRZ,
    // temp
    atmObjID,
    
    #if defined ATM_USE_MAPICON
    atmIconID,
    #endif
    
    #if defined ROBBABLE_ATMS
    Float: atmHealth,
    atmRegen,
    atmTimer,
    atmPickup,
    #endif
    
    Text3D: atmLabel
}

enum
{
	FACTION_POLICE = 1,
	FACTION_NEWS,
	FACTION_MEDIC,
	FACTION_GOV,
	FACTION_FAMILY

};

enum factionData 
{
	factionID,
	factionExists,
	factionName[32],
	factionColor,
	factionType,
	factionRanks,
	Float:factionLockerPos[3],
	factionLockerInt,
	factionLockerWorld,
	factionSkins[8],
	factionWeapons[10],
	factionAmmo[10],
	factionDurability[10],
	factionSalary[15],
	STREAMER_TAG_3D_TEXT_LABEL:factionText3D,
	STREAMER_TAG_PICKUP:factionPickup,
	Float:SpawnX,
	Float:SpawnY,
	Float:SpawnZ,
	SpawnInterior,
	SpawnVW
};

// vehicle
enum E_P_VEHICLE_KEYS
{
	playerID, //Untuk menampung ID SQL Player
	vehicleID, //Untuk menampung ID SQL Vehicle
	vehicleKeyExists, // Untuk menampung kosong atau tidak
	vehicleModel // untuk menampung model kendaraan
};

enum E_PUMP_DATA
{
    pumpID,
    pumpBusiness,
    Float:pumpPos[4],
    pumpFuel,

    pumpObject,
    Text3D:pumpText3D
};

enum 
{
	TYPE_FASTFOOD = 1,
	TYPE_247,
	TYPE_CLOTHES,
	TYPE_ELECTRO
};

enum e_biz_data
{
	bizID,
	bizName[32],
	bizOwner,
	bizOwnerName[MAX_PLAYER_NAME],
	bool:bizExists,
	Float:bizInt[3],
	Float:bizExt[3],
	Float:bizDeliver[3],
	bizWorld,
	bizInterior,
	bizVault,
	bizPrices,
	bizLocked,
	bizFuel,
	bizProduct[7],
	bizType,
	bizStock,
	bizCargo,
	bizDiesel,
	bool:bizReq,
	Float:bizFuelPos[3],
	STREAMER_TAG_PICKUP:bizFuelPickup,
	STREAMER_TAG_3D_TEXT_LABEL:bizFuelText,
	STREAMER_TAG_PICKUP:bizDeliverPickup,
	STREAMER_TAG_3D_TEXT_LABEL:bizDeliverText,
	STREAMER_TAG_PICKUP:bizPickup,
	STREAMER_TAG_3D_TEXT_LABEL:bizText,
	STREAMER_TAG_CP:bizCP,
	STREAMER_TAG_MAP_ICON:bizIcon,
};

enum E_VEHICLE_OBJECT {
    vehObjectID,
    vehObjectVehicleIndex,
    vehObjectType,
    vehObjectModel,
    vehObjectColor,

    vehObjectText[32],
    vehObjectFont[24],
    vehObjectFontSize,
    vehObjectFontColor,

    vehObject,
    
    bool:vehObjectExists,

    Float:vehObjectPosX,
    Float:vehObjectPosY,
    Float:vehObjectPosZ,
    Float:vehObjectPosRX,
    Float:vehObjectPosRY,
    Float:vehObjectPosRZ
};

enum bodyEnums {
    Model,
    Name[37]
};

enum E_SPEED_DATA
{
	speedID,
	speedMax,

	speedDetail[128],
	Float:speedPos[4],

	speedArea,
	speedObject,
	Text3D:speedLabel
};

enum
{
	VEHICLE_TYPE_NONE = 0,
	VEHICLE_TYPE_PLAYER,
	VEHICLE_TYPE_FACTION,
	VEHICLE_TYPE_SIDEJOB,
	VEHICLE_TYPE_RENTAL,
	VEHICLE_TYPE_DRIVING_SCHOOL
};

enum
{
	VEHICLE_STATE_NONE = 0,
	VEHICLE_STATE_SPAWNED,
	VEHICLE_STATE_DEAD,
	VEHICLE_STATE_INSURANCE,
	VEHICLE_STATE_IMPOUND,
	VEHICLE_STATE_PARKED,
	VEHICLE_STATE_HOUSEPARKED,
	VEHICLE_STATE_APARTPARKED
};

enum
{
	VEHICLE_SAVE_ALL = 0,
	VEHICLE_SAVE_POSITION,
	VEHICLE_SAVE_COLOR,
	VEHICLE_SAVE_MISC,
	VEHICLE_SAVE_DAMAGES,
	VEHICLE_SAVE_COMPONENT
};

enum
{
	VEHICLE_SIDEJOB_NONE = 0,
	VEHICLE_SIDEJOB_BUS,
	VEHICLE_SIDEJOB_SWEEPER,
	VEHICLE_SIDEJOB_TRASHMASTER,
	VEHICLE_SIDEJOB_MONEYTRANS,
	VEHICLE_SIDEJOB_BOXVILLE
};

enum e_TRUNK_FLAGS
{
	e_TRUNK_NOTHING = 0,
	e_TRUNK_WEAPON,
	e_TRUNK_INVENTORY
};

enum E_VEHICLE_DATA
{
		// Info
		vehIndex,
		vehPlate[32],
		vehModel,
		vehExtraID,

		// World
		vehVirtual,
		vehInterior,
Float:	vehPosX,
Float:	vehPosY,
Float:	vehPosZ,
Float:	vehPosRZ,

		// Color
		vehColor1,
		vehColor2,
		vehPaintjob,

		// Damaged
		vehPanel,
		vehDoor,
		vehLight,
		vehTires,
Float:	vehHealth,

		// Additions
		vehType,
		vehState,
Float:	vehFuel,
Float:	vehLastCoords[3],
	
		// Trunk Storage
		e_TRUNK_FLAGS:vehTrunkType[MAX_VEHICLE_STORAGE],

		// Trunk Storage - Weapon
		vehAmmo[MAX_VEHICLE_STORAGE],
		vehWeapon[MAX_VEHICLE_STORAGE],
		vehDurability[MAX_VEHICLE_STORAGE],
		vehSerial[MAX_VEHICLE_STORAGE],

		// Other
		vehSiren,
		vehMod[MAX_VEHICLE_MOD_SECTIONS],
		vehLumber,
		vehRentTime,
		vehKillerID,
		vehVehicleID,
		vehInsurance,

		// Vehicle Upgrade
		vehEngineUpgrade,
		vehBodyUpgrade,
		Float:vehBodyRepair,
		vehGasUpgrade,
		vehTurbo,

		// Vehicle Component Preview
		vehModSectionPreview,
		vehModCompPreview,

		// Vehicle Neon
		vehNeonL, //Neon kiri
		vehNeonR,  //Neon kanan
		vehNeonColor,
		vehTogNeon,

		//Truck Haul
		vehComponent,
		vehWoods,

		//vehicle Interior ((RV))
		vehInteriorVW,

		vehURL[128],
		vehAudio,

		vehParking,
		vehHouseParking,

		vehDoorStatus,
		vehEngineStatus,

		vehHandBrake,

		vehLockTire,
		Text3D:vehLockTireText,

		// Mileage
		Float:accumulatedMileage, // Mileage yang terakumulasi.
		Float:currentMileage,		  // Mileage saat ini
		Float:durabilityMileage,   // Ketahanan kendaraan di nilai mileage tertentu.
		
		Timer:vehLockTireTimer,
		Timer:vehHandbrakeTimer
		
};

enum E_VEHICLE_STORAGE_DATA {
	vehInvIndex,
    vehInvName[32],
    vehInvModel,
    vehInvQuantity
};

enum E_GUN_RACK
{
	weaponModel,
	weaponAmmo,
	weaponExists
};

enum
{
    NOTHING = 0,
    VEHICLE
};

enum houseData {
    houseID,
    houseExists,
    houseOwner,
    housePrice,
    houseOwnerName[32],
    houseAddress[32],
    Float:housePos[4],
    Float:houseInt[4],
    houseInterior,
    houseExterior,
    houseExteriorVW,
    houseLocked,
    houseMoney,
    Text3D:houseText3D,
    housePickup,
    houseCheckpoint,
    houseLights,
    houseWeaponSlot[5],
    houseWeapons[5],
    houseAmmo[5],
    houseDurability[5],
    houseSerial[5],
    houseLastVisited,
    furniture[MAX_HOUSE_FURNITURE],

    //House Parking Spawn
    houseParkingSlot,
    houseParkingSlotUsed,
    //Float:houseParkingPos[4]
    housePacket,
    houseSeal
};

enum    _:E_HOUSE_TYPE {
    TYPE_SMALL = 0,
    TYPE_MEDIUM,
    TYPE_LARGE
}