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
}
new AccountData[MAX_PLAYERS][UserData];

enum e_player_data
{
	pID,
	pCharacter,
	Float:pHealth,
	Float:pPos[4],
	pCreated,
	pMoney,
	pPaycheck,
	pSalary,
	pOrigin[32],
	pExp,
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
	pStorageSelect,
	Timer:pPtask_Stats
};
new CharacterList[MAX_PLAYERS][MAX_CHARACTERS][MAX_PLAYER_NAME + 1];
new PlayerData[MAX_PLAYERS][e_player_data];

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
	DIALOG_UPDATE,
	DIALOG_UE
};

enum    _:E_ISSUE {
    THREAD_CREATE_CHAR = 1,
    THREAD_LIST_CHARACTERS,
    THREAD_FIND_USERNAME,
    THREAD_LOAD_CHARACTERS
}

enum playerTextraws {
    PlayerText:textdraw_footer
};
new PlayerTextdraws[MAX_PLAYERS][playerTextraws];

enum    _:E_SELECTION_TYPE {
    MODEL_SELECTION_NONE = 0,
    MODEL_SELECTION_SKIN       
}

new MySQL:sqlcon;
new g_RaceCheck[MAX_PLAYERS];

new g_aSpawnMaleSkins[13] = {
    78, 79, 128, 133, 134, 135, 136, 137, 159, 212, 213, 230, 239
};
new g_aSpawnFemaleSkins[6] = {
    77, 93, 131, 157, 198, 201
};