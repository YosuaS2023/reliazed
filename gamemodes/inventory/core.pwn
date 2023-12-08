#define MAX_INVENTORY 20
enum inventoryData
{
	invExists,
	invID,
	invItem[32 char],
	invModel,
	invQuantity
};

new InventoryData[MAX_PLAYERS][MAX_INVENTORY][inventoryData];

	
enum e_InventoryItems
{
	e_InventoryItem[32],
	e_InventoryModel
};


new const g_aInventoryItems[][e_InventoryItems] =
{
	{"GPS", 18875},
	{"Cellphone", 18867},
	{"Medkit", 1580},
	{"Portable Radio", 19942},
	{"Mask", 19036},
	{"Snack", 2768},
	{"Water", 2958},
	{"Rolling Paper", 19873},
	{"Rolled Weed", 3027},
	{"Weed", 1578},
	{"Component", 19627},
	{"Weed Seed", 1279},
	{"9mm Luger", 19995},
	{"12 Gauge", 19995},
	{"9mm Silenced Schematic", 3111},
	{"Shotgun Schematic", 3111},
	{"9mm Silenced Material", 3052},
	{"Shotgun Material", 3052},
	{"Axe", 19631},
	{"Fish Rod", 18632},
	{"Bait", 19566}
};
