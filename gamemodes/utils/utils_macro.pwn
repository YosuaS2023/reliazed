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

#define FUNC::%0(%1) forward %0(%1); public %0(%1)
#define function%0(%1) forward %0(%1); public %0(%1)
#define void:
#define forex(%0,%1) for(new %0 = 0; %0 < %1; %0++)