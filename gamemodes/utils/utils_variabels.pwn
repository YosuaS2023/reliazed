// General
new MySQL:sqlcon;
new g_RaceCheck[MAX_PLAYERS];
// Vehicle & Faction
new MotdData[e_MotdData];
new govData[gov_data];
new FactionVehicle[MAX_FACTION_VEHICLE][e_faction_vehicle];
new VehCore[MAX_VEHICLES][vCore];
new selectedTarget[MAX_PLAYERS];

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