// Configuration server
#define SERVER_NAME                     "Realized Reality Project"
#define SERVER_URL                      "https://github.com/Cagus17/gamemode-basic-ucp"
#define SERVER_DISCORD					"Coming Soon"
#define SERVER_REVISION                 "RRP 0.3 New era"

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

// definisi max pada server
#define MIN_VIRTUAL_WORLD				(1000000)
#define MAX_VIRTUAL_WORLD				(1200000)
#define MAX_CHARACTERS                  (3)
#define MAX_FACTION_VEHICLE             10
#define MAX_INVENTORY                   20
#define MAX_DYNAMIC_JOB		            10 // Job dynamic
#define MAX_DOTS                        100 // GPS
#define MAX_DAMAGE                      (55)
#define TOTAL_BODY_STATUS				(7)
#define MAX_FACTIONS                    10
#define JOB_STOCK_LIMIT                 (15000)
