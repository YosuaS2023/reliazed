#define MAX_DYNAMIC_JOB		10
#include   <ysi\y_hooks>

enum
{
	JOB_POS_ICON = 0,
	JOB_POS_LABEL,
	JOB_POS_LABEL_POINT,
	JOB_POS_PICKUP,
	JOB_POS_PICKUP_POINT
}

enum jobData {
    jobID,
    jobExists,
    jobType,
    Float:jobPos[3],
    Float:jobPoint[3],
    Float:jobDeliver[3],
    jobInterior,
    jobWorld,
    jobPointInt,
    jobPointWorld,
    jobStock,
    jobPickups[3],
    jobIcon,
    jobPrison,
    Text3D:jobText3D[3]
};
new JobData[MAX_DYNAMIC_JOB][jobData];

hook OnGameModeInit()
{
    mysql_tquery(sqlcon, "SELECT * FROM `jobs`", "Job_Load");
    return 1;
}

function Job_Load()
{
    static
        rows,
        fields;

    cache_get_data(rows, fields);

    for (new i = 0; i < rows; i ++) if(i < MAX_DYNAMIC_JOB)
    {
        JobData[i][jobExists] = true;
        JobData[i][jobID] = cache_get_field_int(i, "jobID");
        JobData[i][jobType] = cache_get_field_int(i, "jobType");
        JobData[i][jobPos][0] = cache_get_field_float(i, "jobPosX");
        JobData[i][jobPos][1] = cache_get_field_float(i, "jobPosY");
        JobData[i][jobPos][2] = cache_get_field_float(i, "jobPosZ");
        JobData[i][jobInterior] = cache_get_field_int(i, "jobInterior");
        JobData[i][jobWorld] = cache_get_field_int(i, "jobWorld");
        JobData[i][jobPoint][0] = cache_get_field_float(i, "jobPointX");
        JobData[i][jobPoint][1] = cache_get_field_float(i, "jobPointY");
        JobData[i][jobPoint][2] = cache_get_field_float(i, "jobPointZ");
        JobData[i][jobDeliver][0] = cache_get_field_float(i, "jobDeliverX");
        JobData[i][jobDeliver][1] = cache_get_field_float(i, "jobDeliverY");
        JobData[i][jobDeliver][2] = cache_get_field_float(i, "jobDeliverZ");
        JobData[i][jobPointInt] = cache_get_field_int(i, "jobPointInt");
        JobData[i][jobPointWorld] = cache_get_field_int(i, "jobPointWorld");
        JobData[i][jobStock] = cache_get_field_int(i, "jobStock");
        JobData[i][jobPrison] = cache_get_field_int(i, "jobPrison");
        Job_Refresh(i);
    }
    printf("*** [load] job data (%d count).", rows);
    return 1;
}

Job_Save(jobid)
{
    static
        query[512];

    format(query, sizeof(query), "UPDATE `jobs` SET `jobType` = '%d', `jobPosX` = '%.4f', `jobPosY` = '%.4f', `jobPosZ` = '%.4f', `jobInterior` = '%d', `jobWorld` = '%d', `jobPointX` = '%.4f', `jobPointY` = '%.4f', `jobPointZ` = '%.4f', `jobDeliverX` = '%.4f', `jobDeliverY` = '%.4f', `jobDeliverZ` = '%.4f', `jobPointInt` = '%d', `jobPointWorld` = '%d', `jobStock`='%d', `jobPrison`='%d' WHERE `jobID` = '%d'",
        JobData[jobid][jobType],
        JobData[jobid][jobPos][0],
        JobData[jobid][jobPos][1],
        JobData[jobid][jobPos][2],
        JobData[jobid][jobInterior],
        JobData[jobid][jobWorld],
        JobData[jobid][jobPoint][0],
        JobData[jobid][jobPoint][1],
        JobData[jobid][jobPoint][2],
        JobData[jobid][jobDeliver][0],
        JobData[jobid][jobDeliver][1],
        JobData[jobid][jobDeliver][2],
        JobData[jobid][jobPointInt],
        JobData[jobid][jobPointWorld],
        JobData[jobid][jobStock],
        JobData[jobid][jobPrison],
        JobData[jobid][jobID]
    );
    return mysql_tquery(sqlcon, query);
}

Job_Refresh(jobid)
{
    if(jobid != -1 && JobData[jobid][jobExists])
    {
        for (new i = 0; i < 3; i ++) {
            if(IsValidDynamic3DTextLabel(JobData[jobid][jobText3D][i]))
                DestroyDynamic3DTextLabel(JobData[jobid][jobText3D][i]);

            if(IsValidDynamicPickup(JobData[jobid][jobPickups][i]))
                DestroyDynamicPickup(JobData[jobid][jobPickups][i]);

        }
        if(IsValidDynamicMapIcon(JobData[jobid][jobIcon]))
            DestroyDynamicMapIcon(JobData[jobid][jobIcon]);

        new
            strings[200];


        JobData[jobid][jobText3D][0] = CreateDynamic3DTextLabel(sprintf("[%d]\nJOB TYPE: "YELLOW"[%d]\n [%s]""\n"WHITE"Type "YELLOW"/takejob "WHITE"to acquire this job!", jobid, JobData[jobid][jobType], Job_GetName(JobData[jobid][jobType])), COLOR_CLIENT, JobData[jobid][jobPos][0], JobData[jobid][jobPos][1], JobData[jobid][jobPos][2]+0.5, 7.5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, JobData[jobid][jobWorld], JobData[jobid][jobInterior]);
        JobData[jobid][jobPickups][0] = CreateDynamicPickup(1239, 23, JobData[jobid][jobPos][0], JobData[jobid][jobPos][1], JobData[jobid][jobPos][2], JobData[jobid][jobWorld], JobData[jobid][jobInterior]);

        if(!JobData[jobid][jobInterior])
            JobData[jobid][jobIcon] = CreateDynamicMapIcon(JobData[jobid][jobPos][0], JobData[jobid][jobPos][1], JobData[jobid][jobPos][2], 56, -1, -1, 0, -1, _, MAPICON_LOCAL);
    }
    
    return 1;
}


Job_Delete(jobid)
{
    if(jobid != -1 && JobData[jobid][jobExists])
    {
        new
        string[64];

        format(string, sizeof(string), "DELETE FROM `jobs` WHERE `jobID` = '%d'", JobData[jobid][jobID]);
        mysql_tquery(sqlcon, string);

        for (new i = 0; i < 3; i ++) {
            if(IsValidDynamic3DTextLabel(JobData[jobid][jobText3D][i])) {
                DestroyDynamic3DTextLabel(JobData[jobid][jobText3D][i]);

                JobData[jobid][jobText3D][i] = Text3D:INVALID_STREAMER_ID;
            }

            if(IsValidDynamicPickup(JobData[jobid][jobPickups][i])) {
                DestroyDynamicPickup(JobData[jobid][jobPickups][i]);

                JobData[jobid][jobPickups][i] = INVALID_STREAMER_ID;
            }

        }

        if(IsValidDynamicMapIcon(JobData[jobid][jobIcon]))
            DestroyDynamicMapIcon(JobData[jobid][jobIcon]);

        JobData[jobid][jobExists] = false;
        JobData[jobid][jobType] = 0;
        JobData[jobid][jobID] = 0;
        JobData[jobid][jobStock] = 0;
        JobData[jobid][jobPrison] = 0;
        JobData[jobid][jobIcon] = INVALID_STREAMER_ID;
    }
    return 1;
}

Job_Create(playerid, type)
{
    static
        Float:x,
        Float:y,
        Float:z;

    if(GetPlayerPos(playerid, x, y, z))
    {
        for (new i = 0; i != MAX_DYNAMIC_JOB; i ++)
        {
            if(!JobData[i][jobExists])
            {
                JobData[i][jobExists] = true;
                JobData[i][jobType] = type;

                JobData[i][jobPos][0] = x;
                JobData[i][jobPos][1] = y;
                JobData[i][jobPos][2] = z;
                JobData[i][jobPoint][0] = 0.0;
                JobData[i][jobPoint][1] = 0.0;
                JobData[i][jobPoint][2] = 0.0;
                JobData[i][jobDeliver][0] = 0.0;
                JobData[i][jobDeliver][1] = 0.0;
                JobData[i][jobDeliver][2] = 0.0;

                JobData[i][jobInterior] = GetPlayerInterior(playerid);
                JobData[i][jobWorld] = GetPlayerVirtualWorld(playerid);

                JobData[i][jobPointInt] = 0;
                JobData[i][jobPointWorld] = 0;
                JobData[i][jobStock] = 0;
                JobData[i][jobPrison] = 0;

                Job_Refresh(i);
                mysql_tquery(sqlcon, "INSERT INTO `jobs` (`jobInterior`) VALUES(0)", "OnJobCreated", "d", i);
                return i;
            }
        }
    }
    return -1;
}

Job_NearestPoint(playerid, Float:radius = 4.0)
{
    for (new i = 0; i != MAX_DYNAMIC_JOB; i ++) if(JobData[i][jobExists] && IsPlayerInRangeOfPoint(playerid, radius, JobData[i][jobPoint][0], JobData[i][jobPoint][1], JobData[i][jobPoint][2])) {
        return i;
    }
    return -1;
}

Job_Nearest(playerid)
{
    for (new i = 0; i != MAX_DYNAMIC_JOB; i ++) if(JobData[i][jobExists] && IsPlayerInRangeOfPoint(playerid, 2.5, JobData[i][jobPos][0], JobData[i][jobPos][1], JobData[i][jobPos][2]))
    {
        if(GetPlayerInterior(playerid) == JobData[i][jobInterior] && GetPlayerVirtualWorld(playerid) == JobData[i][jobWorld])
        return i;
    }
    return -1;
}

Job_GetName(type)
{
    static
        str[24];

    switch (type)
    {
        default: str = "None";
    }
    return str;
}