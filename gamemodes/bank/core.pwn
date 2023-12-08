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

enum    _:E_BANK_DIALOG
{
    DIALOG_BANK_MENU_NOLOGIN = 12450,
    DIALOG_BANK_MENU,
    DIALOG_BANK_CREATE_ACCOUNT,
    DIALOG_BANK_ACCOUNTS,
    DIALOG_BANK_LOGIN_ID,
    DIALOG_BANK_LOGIN_PASS,
    DIALOG_BANK_DEPOSIT,
    DIALOG_BANK_WITHDRAW,
    DIALOG_BANK_TRANSFER_1,
    DIALOG_BANK_TRANSFER_2,
    DIALOG_BANK_PASSWORD,
    DIALOG_BANK_REMOVE,
    DIALOG_BANK_LOGS,
    DIALOG_BANK_LOG_PAGE
}
 
enum    _:E_BANK_LOGTYPE
{
    TYPE_NONE,
    TYPE_LOGIN,
    TYPE_DEPOSIT,
    TYPE_WITHDRAW,
    TYPE_TRANSFER,
    TYPE_PASSCHANGE
}
 
#if defined ROBBABLE_ATMS
enum    _:E_ATMDATA
{
    IDString[8],
    refID
}
#endif
 
enum    E_BANKER
{
    // saved
    Skin,
    Float: bankerX,
    Float: bankerY,
    Float: bankerZ,
    Float: bankerA,
    // temp
    bankerActorID,
    #if defined BANKER_USE_MAPICON
    bankerIconID,
    #endif
    Text3D: bankerLabel
}
 
enum    E_ATM
{
    // saved
    Float: atmX,
    Float: atmY,
    Float: atmZ,
    Float: atmRX,
    Float: atmRY,
    Float: atmRZ,
    // temp
    atmObjID,
    
    #if defined ATM_USE_MAPICON
    atmIconID,
    #endif
    
    #if defined ROBBABLE_ATMS
    Float: atmHealth,
    atmRegen,
    atmTimer,
    atmPickup,
    #endif
    
    Text3D: atmLabel
}

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