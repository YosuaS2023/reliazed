CMD:takejob(playerid, params[])
{
    static
        id = -1;

    if((id = Job_Nearest(playerid)) != -1)
    {
        if(PlayerData[playerid][pJob])
            return SendErrorMessage(playerid, "You must '/quitjob' to get new job.");

        if(PlayerData[playerid][pJob] == JobData[id][jobType])
            return SendErrorMessage(playerid, "You have this job already.");

        if(JobData[id][jobType] == JOB_LUMBERJACK && PlayerData[playerid][pScore] < 2)
            return SendErrorMessage(playerid, "You must level 2 to join this job.");

        if(isnull(params))
        {
            SendServerMessage(playerid, "/takejob [confirm]");
            SendClientMessage(playerid, X11_TOMATO_1, "WARNING:"WHITE" /takejob 'confirm' to take this job.");
            return 1;
        }
        if(!strcmp(params, "confirm", true))
        {
            PlayerData[playerid][pJob] = JobData[id][jobType];
            PlayerData[playerid][pQuitjob] = 2;

            SendServerMessage(playerid, "You are now a "YELLOW"%s "WHITE"- type "YELLOW"\"/help > Job Commands\" "WHITE"for job commands.", Job_GetName(JobData[id][jobType]));

/*            if(PlayerData[playerid][pJob] == JOB_COURIER)
            {
                SendCustomMessage(playerid, "TRUCKER","Untuk memulai pekerjaan ini, telebih dahulu Kamu menggunakan perintah (/shipments) untuk memulai pekerjaan awal.");
                SendCustomMessage(playerid, "TRUCKER","Setelah itu, Kamu bisa menggunakan perintah /startdelivery untuk mengumpulkan crate ke dalam truck, sesuai dengan jenis ..-");
                SendCustomMessage(playerid, "TRUCKER","Yang Kamu pilih sewaktu menggunakan perintah /shipments.");
            }*/
        }
        else
        {
            SendServerMessage(playerid, "/takejob [confirm]");
            SendClientMessage(playerid, X11_TOMATO_1, "WARNING:"WHITE" /takejob 'confirm' to take this job.");
        }
        return 1;
    }
    SendErrorMessage(playerid, "You are not in range of any job pickup.");
    return 1;
}

CMD:createjob(playerid, params[])
{
    static
        type,
        id = -1;

    if (CheckAdmin(playerid, 4))
        return PermissionError(playerid);

    if(sscanf(params, "d", type))
    {
        SendSyntaxMessage(playerid, "/createjob [type]");
        SendClientMessageEx(playerid, X11_YELLOW_2,"TYPES: "WHITE"1: Taxi | 2: Mechanic | 3: Lumber Jack | 4: Trucker");
        SendClientMessageEx(playerid, X11_YELLOW_2,"TYPES: "WHITE"5: Miner | 6: Production | 7: Farmer | 8: Arms Dealer");
        return 1;
    }
    if(type < 1 || type > 8)
        return SendErrorMessage(playerid, "Invalid type specified. Types range from 1 to 11.");

    id = Job_Create(playerid, type);

    if(id == -1)
        return SendErrorMessage(playerid, "The server has reached the limit for jobs.");

    SendServerMessage(playerid, "You have successfully created job ID: %d.", id);
    return 1;
}

CMD:destroyjob(playerid, params[])
{
    static
        id = 0;

    if (CheckAdmin(playerid, 4))
        return PermissionError(playerid);

    if(sscanf(params, "d", id))
        return SendSyntaxMessage(playerid, "/destroyjob [job id]");

    if((id < 0 || id >= MAX_DYNAMIC_JOB) || !JobData[id][jobExists])
        return SendErrorMessage(playerid, "You have specified an invalid job ID.");

    Job_Delete(id);
    SendServerMessage(playerid, "You have successfully destroyed job ID: %d.", id);
    return 1;
}

CMD:editjob(playerid, params[])
{
    static
        id,
        type[24],
        string[128];

    if (CheckAdmin(playerid, 4))
        return PermissionError(playerid);

    if(sscanf(params, "ds[24]S()[128]", id, type, string))
    {
        SendSyntaxMessage(playerid, "/editjob [id] [name]");
        SendClientMessage(playerid, X11_YELLOW_2, "[NAMES]:"WHITE" location, type, point, deliver, stock, prison");
        return 1;
    }
    if((id < 0 || id >= MAX_DYNAMIC_JOB) || !JobData[id][jobExists])
        return SendErrorMessage(playerid, "You have specified an invalid job ID.");

    if(!strcmp(type, "location", true))
    {
        static
            Float:x,
            Float:y,
            Float:z;

        GetPlayerPos(playerid, x, y, z);

        JobData[id][jobPos][0] = x;
        JobData[id][jobPos][1] = y;
        JobData[id][jobPos][2] = z;

        JobData[id][jobInterior] = GetPlayerInterior(playerid);
        JobData[id][jobWorld] = GetPlayerVirtualWorld(playerid);

        Job_Refresh(id);
        Job_Save(id);

        SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has adjusted the location of job ID: %d.", ReturnName(playerid), id);
        Log_Save(E_LOG_DYNAMIC_JOB, sprintf("[%s] %s has adjusted the location of JOB ID: (%d) to %s.", ReturnDate(), ReturnName(playerid), id, JobData[id][jobPos]));
    }
    else if(!strcmp(type, "jobids", true))
    {
        new typeint;

        if(sscanf(string, "d", typeint))
        {
            SendSyntaxMessage(playerid, "/editjob [id] [type] [new type]");
            SendClientMessageEx(playerid, X11_YELLOW_2,"TYPES: "WHITE"1: Trucker | 2: Mechanic | 3: Taxi Driver | 4: Cargo Unloader.");
            SendClientMessageEx(playerid, X11_YELLOW_2,"TYPES: "WHITE"5: Miner | 6: Food Vendor | 7: Package sorter | 8: Arms Dealer | 9: Lumberjack.");
            return 1;
        }
        if(typeint < 1 || typeint > 11)
            return SendErrorMessage(playerid, "Invalid type specified. Types range from 1 to 11.");

        JobData[id][jobType] = typeint;

        Job_Refresh(id);
        Job_Save(id);

        SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has adjusted the type of job ID: %d to %s.", ReturnName(playerid), id, Job_GetName(typeint));
        Log_Save(E_LOG_DYNAMIC_JOB, sprintf("[%s] %s has adjusted the type of JOB ID: (%d) to %s.", ReturnDate(), ReturnName(playerid), id, Job_GetName(typeint)));
    }
    else if(!strcmp(type, "stock", true))
    {
        new typeint;

        if(sscanf(string, "d", typeint)) return SendSyntaxMessage(playerid, "/editjob [id] [stock] [stock]");

        if(typeint < 0 || typeint > JOB_STOCK_LIMIT)
            return SendErrorMessage(playerid, "Invalid type specified. Types range from 1 to 15000.");

        JobData[id][jobStock] = typeint;

        Job_Refresh(id);
        Job_Save(id);

        SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has adjusted the stock of job ID: %d to %d.", ReturnName(playerid), id, typeint);
    }
    else if(!strcmp(type, "prison", true))
    {
        new prison;

        if(sscanf(string, "d", prison)) return SendSyntaxMessage(playerid, "/editjob [id] [prison] [0/1]]");

        if(prison < 0 || prison > 1)
            return SendErrorMessage(playerid, "Invalid type specified. Prison Type : 1 , 0 None.");

        JobData[id][jobPrison] = prison;

        Job_Refresh(id);
        Job_Save(id);

        SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has adjusted the prison type of job ID: %d to %d.", ReturnName(playerid), id, prison);
    }
    else if(!strcmp(type, "point", true))
    {
        static
            Float:x,
            Float:y,
            Float:z;

        GetPlayerPos(playerid, x, y, z);

        JobData[id][jobPoint][0] = x;
        JobData[id][jobPoint][1] = y;
        JobData[id][jobPoint][2] = z;
        JobData[id][jobPointInt] = GetPlayerInterior(playerid);
        JobData[id][jobPointWorld] = GetPlayerVirtualWorld(playerid);

        Job_Refresh(id);
        Job_Save(id);

        SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has adjusted the point of job ID: %d.", ReturnName(playerid), id);
        Log_Save(E_LOG_DYNAMIC_JOB, sprintf("[%s] %s has adjusted the point of JOB ID: (%d)", ReturnDate(), ReturnName(playerid), id));

    }
    else if(!strcmp(type, "deliver", true))
    {
        if(GetPlayerInterior(playerid) > 0 || GetPlayerVirtualWorld(playerid) > 0)
            return SendErrorMessage(playerid, "You can't place the deliver point inside interiors.");

        static
            Float:x,
            Float:y,
            Float:z;

        GetPlayerPos(playerid, x, y, z);

        JobData[id][jobDeliver][0] = x;
        JobData[id][jobDeliver][1] = y;
        JobData[id][jobDeliver][2] = z;

        Job_Refresh(id);
        Job_Save(id);

        SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has adjusted the deliver point of job ID: %d.", ReturnName(playerid), id);
        Log_Save(E_LOG_DYNAMIC_JOB, sprintf("[%s] %s has adjusted the deliver point of JOB ID: (%d).", ReturnDate(), ReturnName(playerid), id));
    }
    return 1;
}