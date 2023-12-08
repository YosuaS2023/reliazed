#if defined include_valk_gps
	#endinput
#endif

#define include_valk_gps

/* Parametros configurables */
#define GPS_COLOR 0x8A44E4FF

new const ColorsRutePlayerGPS[] = {
	0x8A44E4FF, // Morado
	0xDA1515FF // Rojo
};

#define GPS_UPDATE_TIME 1100


#if !defined GPS_MODE_1 && !defined GPS_MODE_2 && !defined GPS_MODE_ALL
 	#error "GPS_MODE is not defined"
#endif

#if defined GPS_MODE_ALL
 	#define GPS_MODE_1
 	#define GPS_MODE_2
#endif

#define MAX_DOTS 100

#include <GPS> 

#include <YSI_Coding\y_hooks>

/* --------------------------------------------------------------------- */
#if __Pawn != 0x030A
    #define INITIALIZE_WITH_FOR // Fix problem for native-compiler users.
#endif

new
	bool:playerHasGPSActive[MAX_PLAYERS],
	PlayerColorGPS[MAX_PLAYERS],
	PlayerGPSTimer[MAX_PLAYERS],
	Float:PlayerGPS_PointX[MAX_PLAYERS],
	Float:PlayerGPS_PointY[MAX_PLAYERS],
	Float:PlayerGPS_PointZ[MAX_PLAYERS],

#if defined INITIALIZE_WITH_FOR
	Routes[MAX_PLAYERS][MAX_DOTS];
#else
	Routes[MAX_PLAYERS][MAX_DOTS] = {-1, ...};
#endif