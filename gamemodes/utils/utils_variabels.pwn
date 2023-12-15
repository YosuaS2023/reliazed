// General
new MySQL:sqlcon;
new g_RaceCheck[MAX_PLAYERS];

new Env:pump;
new Env:house;
// Vehicle & Faction
new MotdData[e_MotdData];
new govData[gov_data];
new ListedVehObject[MAX_PLAYERS][MAX_VEHICLE_OBJECT];
new VehicleObjects[MAX_DYNAMIC_VEHICLES][MAX_VEHICLE_OBJECT][E_VEHICLE_OBJECT];
new FactionVehicle[MAX_FACTION_VEHICLE][e_faction_vehicle];
new VehCore[MAX_VEHICLES][vCore];
new HouseData[MAX_HOUSES][houseData];
new selectedTarget[MAX_PLAYERS];
new PlayerDeath[MAX_PLAYERS];
new listCommand[MAX_TYPE_LISTCOMMAND][MAX_STRING_LISTCOMMAND];

new GunrackData[MAX_DYNAMIC_VEHICLES][E_GUN_RACK][MAX_GUNRACK_SLOT];

// vehicle
new VehicleKeyData[MAX_PLAYERS][PLAYER_MAX_VEHICLE_SHARE_KEYS][E_P_VEHICLE_KEYS];
new
	PumpData[MAX_DYNAMIC_PUMPS][E_PUMP_DATA],
	Iterator:GasPump<MAX_DYNAMIC_PUMPS>;

new BusinessData[MAX_BUSINESSES][e_biz_data];
new ProductName[MAX_BUSINESSES][7][24], ProductDescription[MAX_BUSINESSES][7][42];
// Account
new CharacterList[MAX_PLAYERS][MAX_CHARACTERS][MAX_PLAYER_NAME + 1];
new PlayerData[MAX_PLAYERS][e_player_data]; // Character
new AccountData[MAX_PLAYERS][UserData]; // Account
// Inventory
new InventoryData[MAX_PLAYERS][MAX_INVENTORY][inventoryData];
// Playertext
new PlayerTextdraws[MAX_PLAYERS][playerTextraws];
// damage
new DamageData[MAX_PLAYERS][MAX_DAMAGE][damageData];
new damageList[MAX_PLAYERS][10][128];
// Job
new JobData[MAX_DYNAMIC_JOB][jobData];

new
    MySQL: BankSQLHandle;
 
new
    BankerData[MAX_BANKERS][E_BANKER],
    ATMData[MAX_ATMS][E_ATM];
 
new
    Iterator: Bankers<MAX_BANKERS>,
    Iterator: ATMs<MAX_ATMS>;
 
new
    CurrentAccountID[MAX_PLAYERS] = {-1, ...},
    LogListType[MAX_PLAYERS] = {TYPE_NONE, ...},
    LogListPage[MAX_PLAYERS],
    EditingATMID[MAX_PLAYERS] = {-1, ...};

new
	SanNewsVehicles[14],
	LSMDVehicles[3],
	LSPDVehicles[28],
	BusVehicle[3],
	SweeperVehicle[3];

new FactionData[MAX_FACTIONS][factionData];
new FactionRanks[MAX_FACTIONS][15][32];

new
	Iterator:Speed<MAX_DYNAMIC_SPEED>,
	SpeedData[MAX_DYNAMIC_SPEED][E_SPEED_DATA];

new Vehicle_RadarObjectID[MAX_DYNAMIC_VEHICLES];
new bool:Player_RadarToggle[MAX_PLAYERS];
new bool:Vehicle_RadarToggle[MAX_DYNAMIC_VEHICLES];
new Timer:Vehicle_CheckingSpeed[MAX_DYNAMIC_VEHICLES];
new Player_OldVehicleID[MAX_PLAYERS];

new
	VehicleData[MAX_DYNAMIC_VEHICLES][E_VEHICLE_DATA],
	VehicleStorageData[MAX_DYNAMIC_VEHICLES][MAX_VEHICLE_STORAGE][E_VEHICLE_STORAGE_DATA];

new
	// Iterator:ServerVehicles<MAX_DYNAMIC_VEHICLES>,
	Iterator:OwnedVehicles<MAX_PLAYERS, MAX_DYNAMIC_VEHICLES>,
	Iterator:RentedVehicles<MAX_PLAYERS, MAX_DYNAMIC_VEHICLES>;

new 
	g_selected_vehicle[MAX_PLAYERS][MAX_OWNED_VEHICLES] = {INVALID_VEHICLE_ID, ...},
	g_selected_vehicle_time[MAX_PLAYERS][MAX_OWNED_VEHICLES] = {INVALID_VEHICLE_ID, ...},
	g_selected_vehicle_price[MAX_PLAYERS][MAX_OWNED_VEHICLES] = {INVALID_VEHICLE_ID, ...};
	
new parking_selected_vehicle[MAX_PLAYERS][MAX_OWNED_VEHICLES] = {INVALID_VEHICLE_ID, ...};

new color_string[3256], object_font[200];