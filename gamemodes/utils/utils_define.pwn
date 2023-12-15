// Configuration server
#define SERVER_NAME                     "Realized Reality Project"
#define SERVER_URL                      "https://github.com/Cagus17/gamemode-basic-ucp"
#define SERVER_DISCORD					"Coming Soon"
#define SERVER_REVISION                 "RRP 0.3 New era"

#define UTC_07							(25200)

// Sync
#define ADM_FOUNDER                     (4)
#define NO_PERMISSION                   "ERROR: Kamu tidak diizinkan menggunakan perintah ini!"
#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define SendServerMessage(%0,%1)        SendClientMessageEx(%0, COLOR_SERVER, "SERVER: "WHITE""%1)
#define SendCustomMessage(%0,%1,%2)     SendClientMessageEx(%0, COLOR_SERVER, %1": "WHITE""%2)
#define SendSyntaxMessage(%0,%1)        SendClientMessageEx(%0, X11_GREY_80, "USAGE: "%1)
#define SendErrorMessage(%0,%1)         SendClientMessageEx(%0, X11_GREY_80, "ERROR: "%1)
#define SendAdminAction(%0,%1)          SendClientMessageEx(%0, X11_TOMATO, "ADMIN: "%1)
#define PermissionError(%0)				SendClientMessageEx(%0, X11_GREY_80, "ERROR: Kamu tidak diizinkan menggunakan perintah ini!")

// vehicle
#define MINIMUM_MILEAGE	 (20) // Batas minimum bisa melakukan maintenance kendaraan.
#define SAFE_MILEAGE		(100) // Rentang aman mileage kendaraan.

#define MAX_VEHICLE_OBJECT	5

#define MAX_COLOR_MATERIAL	5

#define OBJECT_TYPE_BODY	1
#define OBJECT_TYPE_TEXT	2

#define INVALID_VEHICLE_KEY_ID (-1)
#define PLAYER_MAX_VEHICLE_SHARE_KEYS	(100)

// definisi max pada server
#define MAX_TYPE_LISTCOMMAND            (2)
#define MAX_STRING_LISTCOMMAND          (800)
#define MAX_GUNRACK_SLOT 5
#define COMMAND_TYPE_GENERAL            (0)
#define COMMAND_TYPE_ADMINISTRATOR      (1)
#define MAX_BUSINESSES                    (10)
#define MIN_VIRTUAL_WORLD				(1000000)
#define MAX_VIRTUAL_WORLD				(1200000)
#define MAX_HOUSES                      (1000)
#define MAX_HOUSE_FURNITURE             (100)
#define MAX_CLOTHES_WARDROBE 		(3)
#define MAX_CHARACTERS                  (3)
#define MAX_DYNAMIC_SPEED	            100
#define MAX_FACTION_VEHICLE             10
#define MAX_INVENTORY                   20
#define MAX_DYNAMIC_JOB		            10 // Job dynamic
#define MAX_DOTS                        100 // GPS
#define MAX_DAMAGE                      (55)
#define TOTAL_BODY_STATUS				(7)
#define MAX_FACTIONS                    10
#define JOB_STOCK_LIMIT                 (15000)
#define MAX_DYNAMIC_PUMPS	(100)
#define MAX_DYNAMIC_VEHICLES (1000)

#define     MAX_BANKERS     (20)
#define     MAX_ATMS        (100)
 
#define     BANKER_USE_MAPICON                  // comment or remove this line if you don't want bankers to have mapicons
#define     ATM_USE_MAPICON                     // comment or remove this line if you don't want atms to have mapicons
#define     BANKER_ICON_RANGE       (10.0)      // banker mapicon stream distance, you can remove this if you're not using banker icons (default: 10.0)
#define     ATM_ICON_RANGE          (100.0)     // atm mapicon stream distance, you can remove this if you're not using banker icons (default: 100.0)
#define     ACCOUNT_PRICE           (100)       // amount of money required to create a new bank account (default: 100)
#define     ACCOUNT_CLIMIT          (5)         // a player can create x accounts, you can comment or remove this line if you don't want an account limit (default: 5)
#define     ACCOUNT_LIMIT           (500000000) // how much money can a bank account have (default: 500,000,000)
 

#if defined ROBBABLE_ATMS
    #define     ATM_HEALTH              (350.0)     // health of an atm (Default: 350.0)
    #define     ATM_REGEN               (120)       // a robbed atm will start working after x seconds (Default: 120)
    #define     ATM_ROB_MIN             (1500)      // min. amount of money stolen from an atm (Default: 1500)
    #define     ATM_ROB_MAX             (3500)      // max. amount of money stolen from an atm (Default: 3500)
#endif

#define MAX_PLAYER_VEHICLES				3
#define MAX_VEHICLE_STORAGE				5
#define MAX_VIP_VEHICLES				5
#define MAX_RENTED_VEHICLES				2
#define MAX_OWNED_VEHICLES				110

#define RETURN_INVALID_VEHICLE_ID		-1

#define BUSINESS_TYPE_GASSTATION 6

#define COL_GREY                        "{C3C3C3}"
#define COL_GREEN                       "{37DB45}"
#define COL_RED                         "{FF3333}"
#define COL_NICERED                     "{FF0000}"
#define COL_ORANGE                      "{F9B857}"
#define COL_BLUE                        "{0049FF}"
#define COL_PINK                        "{FF00EA}"
#define COL_LIGHTBLUE                   "{00C0FF}"
#define COL_LGREEN                      "{C9FFAB}"
#define COL_LIGHTGREEN                  "{9ACD32}"
#define COL_DEPARTMENT                  "{F0CC00}"
#define COL_LIGHTRED                    "{FF6347}"
#define COL_CLIENT                      "{AAC4E5}"