#define GetPlayerSQLID(%0)              PlayerData[%0][pID]
#define GetMoney(%0)                    PlayerData[%0][pMoney]
#define GetBank(%0)                     PlayerData[%0][pBankMoney]
#define GetPlayerSalary(%0)             PlayerData[%0][pSalary]

#define IsPlayerDuty(%0)                PlayerData[%0][pOnDuty]
#define GetPlayerJob(%0)                PlayerData[%0][pJob]

#define ReturnAdminName(%0)             AccountData[%0][uUsername]
#define GetAdminLevel(%0)               AccountData[%0][uAdmin]
#define ReturnAdminRankName(%0)         AccountData[%0][uAdminRankName]
#define GetUCPSQLID(%0)                 AccountData[%0][uID]
#define CheckAdmin(%0,%1)               AccountData[%0][uAdmin] < %1

#define NormalName(%0)                  CharacterList[%0][PlayerData[%0][pCharacter]]

#define Pump_BusinessID(%0)	                PumpData[%0][pumpBusiness]
#define IsPlayerToggleSpeedTrap(%0)			GetPVarInt(%0, "ToggleSpeedLog")
#define SetPlayerToggleSpeedTrap(%0,%1)		SetPVarInt(%0, "ToggleSpeedLog",%1)

#define GetPlayerFaction(%0)            PlayerData[%0][pFaction]
#define GetPlayerFactionID(%0)          PlayerData[%0][pFactionID]

#define GetPlayerVIPLevel(%0)           PlayerData[%0][pStar]
#define FUNC::%0(%1) forward %0(%1); public %0(%1)
#define function%0(%1) forward %0(%1); public %0(%1)
#define Function:%0(%1) forward %0(%1); public %0(%1)

#define Env: env_
#define void:
#define forex(%0,%1) for(new %0 = 0; %0 < %1; %0++)
#define Array:%0 arr_%0
#define Enumerated: enum_%0