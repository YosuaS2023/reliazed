// Ini adalah file utama untuk memuat modul Admin Duty Times.

#if defined ADMIN_DUTY_TIMES_MODULE
  #endinput
#endif
#define ADMIN_DUTY_TIMES_MODULE

// =========================================================

#include <a_mysql>

// =========================================================

// Nama tabel untuk menyimpan admin duty times.
#define ADMIN_DUTY_TIMES_TABLE_NAME "admin_duty_times"

// =========================================================

#include "./admin/duty_times/enumerations.pwn"
#include "./admin/duty_times/functions.pwn"
#include "./admin/duty_times/callbacks.pwn"
