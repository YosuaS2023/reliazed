static Paycheck(playerid)
{
    if(!PlayerData[playerid][pCanPaycheck])
        return SendErrorMessage(playerid, "Belum bisa mengambil paycheck untuk saat ini.");

    
    new
        salary,
        dialog_string[1024],
        paycheck = RandomEx(50, 150) * (PlayerData[playerid][pScore]+PlayerData[playerid][pHour])/100,
        jumlahrumah,
        jumlahbusiness,
        jumlahapartment,
        taxrumah,
        taxbisnis,
        taxapartment,
        jumlahkendaraan[5], //0 Sport, 1 Normal, 2 Truck, 3 Motor, 4 Kapal
        taxkendaraan[5],
        totaltaxkendaraan,
        pajakproperti,
        pajaktotal,
        pajakparkir;
    new bankinterest = PlayerData[playerid][pBankMoney]/1000;
    new totalpay = bankinterest + paycheck;
    new taxamount = ((totalpay/100) * ServerData[Tax]);

    for(new i=0; i < MAX_BUSINESSES; i++)
    {
        if(Business_IsOwner(playerid, i))
        {
            jumlahbusiness++;
        }
    }
    foreach(new i : ApartmentRoom)
    {
        if(ApartmentRoom_IsOwned(playerid, i))
        {
            jumlahapartment++;
        }
    }
    for(new i=0; i < MAX_HOUSES; i++)
    {
        if(House_IsOwner(playerid, i, false))
        {
            jumlahrumah++;
        }
    }
    foreach(new vehicle : OwnedVehicles<playerid>)
    {
        new vehicleid = VehicleData[vehicle][vehVehicleID];
        if(IsSportCar(vehicleid)) {
            jumlahkendaraan[0]++;
            taxkendaraan[0] = ((jumlahkendaraan[0]*7000) * ServerData[Tax])/100;
        }
        else if(IsDoorVehicle(vehicleid) && !IsSportCar(vehicleid)) {
            jumlahkendaraan[1]++;
            taxkendaraan[1] = ((jumlahkendaraan[1]*1500) * ServerData[Tax])/100;
        }
        else if(IsNormalTruck(vehicleid) || IsBigTruck(vehicleid)) {
            jumlahkendaraan[2]++;
            taxkendaraan[2] = ((jumlahkendaraan[2]*2000) * ServerData[Tax])/100;
        }
        else if(IsABike(vehicleid)) {
            jumlahkendaraan[3]++;
            taxkendaraan[3] = ((jumlahkendaraan[3]*500) * ServerData[Tax])/100;
        }
        else if(IsABoat(vehicleid)) {
            jumlahkendaraan[4]++;
            taxkendaraan[4] = ((jumlahkendaraan[4]*5000) * ServerData[Tax])/100;
        }
    }
    if(GetPlayerVIPLevel(playerid) < 2)
    {
        totaltaxkendaraan = taxkendaraan[0] + taxkendaraan[1] + taxkendaraan[2] + taxkendaraan[3] + taxkendaraan[4];
        taxrumah = ((jumlahrumah*10000) * ServerData[Tax])/100;
        taxbisnis = ((jumlahbusiness*10000) * ServerData[Tax])/100;
        taxapartment = ((jumlahapartment*10000) * ServerData[Tax]/100);
        pajakparkir = PlayerData[playerid][pParkedVehicle]*2000;
    }
    pajakparkir = PlayerData[playerid][pParkedVehicle]*1000;
    PlayerData[playerid][pMinutes]      = 0;
    PlayerData[playerid][pCanPaycheck]  = 0;
    pajakproperti = taxrumah+taxbisnis+totaltaxkendaraan+pajakparkir+taxapartment;
    pajaktotal = taxamount + pajakproperti;
    if(PlayerData[playerid][pHour] >= 24)
    {
        format(dialog_string, sizeof(dialog_string), WHITE"----------------------------------------------------\n\n");

        GetSalaryMoney(playerid, salary);
        format(dialog_string, sizeof(dialog_string), "%s"WHITE"Your salary: "GREEN"%s\n", dialog_string, FormatNumber(salary));
        format(dialog_string, sizeof(dialog_string), "%s"WHITE"Bonus salary: "GREEN"%s\n", dialog_string, FormatNumber(paycheck));
        format(dialog_string, sizeof(dialog_string), "%s"WHITE"Bank interest: "GREEN"%s\n", dialog_string, FormatNumber(bankinterest));
        if(totaltaxkendaraan > 1)format(dialog_string, sizeof(dialog_string), "%s"WHITE"Vehicle Tax : "RED"%s\n", dialog_string, FormatNumber(totaltaxkendaraan));
        if(taxrumah > 1) format(dialog_string, sizeof(dialog_string), "%s"WHITE"House Tax : "RED"%s\n", dialog_string, FormatNumber(taxrumah));
        if(taxbisnis > 1)format(dialog_string, sizeof(dialog_string), "%s"WHITE"Business Tax : "RED"%s\n", dialog_string, FormatNumber(taxbisnis));
        format(dialog_string, sizeof(dialog_string), "%s"WHITE"Total Government Tax (%d%%): "RED"%s\n", dialog_string, ServerData[Tax], FormatNumber(pajaktotal));    
        
        if(PlayerData[playerid][pStatus] == 2)
        {
            new bonusmoney = 500;
            format(dialog_string, sizeof(dialog_string), "%s"WHITE"Government Allowance : "GREEN"$%d!\n", dialog_string, bonusmoney);
            PlayerData[playerid][pBankMoney] += bonusmoney;
        }
        format(dialog_string, sizeof(dialog_string), "%s\n"WHITE"Your previous balance: "YELLOW"%s\n", dialog_string, FormatNumber(PlayerData[playerid][pBankMoney]));

        PlayerData[playerid][pBankMoney] -= pajaktotal;
        PlayerData[playerid][pBankMoney] += totalpay;
        PlayerData[playerid][pFactionHour] = 0;
        PlayerData[playerid][pBizDutyHour] = 0;
        GivePlayerSalary(playerid);

        format(dialog_string, sizeof(dialog_string), "%s"WHITE"Your current balance: "GREEN"%s\n\n", dialog_string, FormatNumber(PlayerData[playerid][pBankMoney]));
    }
    else
    {
        format(dialog_string, sizeof(dialog_string), WHITE"----------------------------------------------------\n\n");

        GetSalaryMoney(playerid, salary);
        format(dialog_string, sizeof(dialog_string), WHITE"%sYour salary: "GREEN"%s\n", dialog_string, FormatNumber(salary));
        format(dialog_string, sizeof(dialog_string), WHITE"%sBonus salary: "GREEN"%s\n", dialog_string, FormatNumber(paycheck));
        format(dialog_string, sizeof(dialog_string), WHITE"%sBank interest: "GREEN"%s\n", dialog_string, FormatNumber(bankinterest)); 
        
        if(PlayerData[playerid][pStatus] == 2)
        {
            new bonusmoney = 500;
            format(dialog_string, sizeof(dialog_string), "%s"WHITE"Government Allowance : "GREEN"$%d!\n", dialog_string, bonusmoney);
            PlayerData[playerid][pBankMoney] += bonusmoney;
        }
        format(dialog_string, sizeof(dialog_string), "%s\n"WHITE"Your previous balance: "YELLOW"%s\n", dialog_string, FormatNumber(PlayerData[playerid][pBankMoney]));

        PlayerData[playerid][pBankMoney] += totalpay;
        GivePlayerSalary(playerid);

        format(dialog_string, sizeof(dialog_string), "%s"WHITE"Your current balance: "GREEN"%s\n\n", dialog_string, FormatNumber(PlayerData[playerid][pBankMoney]));

    }


    if(--PlayerData[playerid][pJobLeave] == 0)
    {
        format(dialog_string, sizeof(dialog_string), "%s"LIGHT_SKY_BLUE_1"JOB: "WHITE"Now you can work in other job!\n", dialog_string);
        SendServerMessage(playerid, "Kontrak kerja sudah habis, kamu bisa keluar dari pekerjaan sekarang!");
    }

    format(dialog_string, sizeof(dialog_string), "%s"WHITE"----------------------------------------------------", dialog_string);
    Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_MSGBOX, "Paycheck", dialog_string, "Close", "");
    return 1;
 }
