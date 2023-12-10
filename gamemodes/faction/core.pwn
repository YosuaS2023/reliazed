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
new FactionData[MAX_FACTIONS][factionData];
new FactionRanks[MAX_FACTIONS][15][32];