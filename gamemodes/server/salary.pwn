stock AddSalary(playerid, name[], amount)
{
	new query[512];
	mysql_format(sqlcon, query, sizeof(query), "INSERT INTO character_salary(owner, name, amount, date) VALUES ('%d', '%s', '%d', CURRENT_TIMESTAMP())", PlayerData[playerid][pID], name, amount);
	mysql_tquery(sqlcon, query);
	PlayerData[playerid][pSalary] += amount;
    UpdateCharacterInt(playerid, "salary", GetPlayerSalary(playerid));
	return 1;
}

stock ShowPlayerSalary(playerid, targetid)
{
	new query[512], list[2056], name[32], date[40], amount;
	mysql_format(sqlcon, query, sizeof(query), "SELECT * FROM character_salary WHERE owner='%d' ORDER BY id ASC", PlayerData[targetid][pID]);
	mysql_query(sqlcon, query);
	new rows = cache_num_rows();
	if(rows)
	{
	    format(list, sizeof(list), "{FFFFFF}Name\t{FFFFFF}Amount\t{FFFFFF}Date\n");
		for(new i; i < rows; ++i)
	    {
			cache_get_value_name(i, "name", name);
			cache_get_value_name(i, "date", date);
			cache_get_value_name_int(i, "amount", amount);

			format(list, sizeof(list), "%s{FFFFFF}%s\t{00FF00}$%s\t{FFFFFF}%s\n", list, name, FormatMoney(amount), date);
		}
		new title[48];
		format(title, sizeof(title), "Total Salary: $%s", FormatMoney(PlayerData[targetid][pSalary]));
		Dialog_Show(playerid, none, DIALOG_STYLE_TABLIST_HEADERS, title, list, "Close", "");
	}
	else
	{
		SendServerMessage(playerid, "There is no Salary to display.");
	}
	return 1;
}

CMD:salary(playerid, params[])
{
	ShowPlayerSalary(playerid, playerid);
	return 1;
}

CMD:setsalary(playerid, params[])
{
	if(CheckAdmin(playerid, 3)) return PermissionError(playerid);
	if(sscanf(params, "iis[20]", params[0], params[1], params[2])) return SendSyntaxMessage(playerid, "/setsalary [playerid] [amount] [name]");

	AddSalary(params[0], params[2], params[1]);
	return 1;
}
CMD:paycheck(playerid, params[])
{
    if(!IsPlayerNearBanker(playerid)) return SendErrorMessage(playerid, "You're not near a banker.");

	if(PlayerData[playerid][pPaycheck] > 0 && AccountData[playerid][uAdmin] < 2)
		return SendErrorMessage(playerid, "Kamu harus menunggu %d menit untuk Paycheck!", PlayerData[playerid][pPaycheck]/60);

	new str[256];
	new taxval = PlayerData[playerid][pSalary]/100*govData[govTax];
	format(str, sizeof(str), "{FFFFFF}Salary: {009000}$%s\n{FFFFFF}Tax: {FFFF00}-$%s {FF0000}(%d percent)\n{FFFFFF}Total Interest: {00FF00}$%s", FormatMoney(PlayerData[playerid][pSalary]), FormatMoney(taxval), govData[govTax], FormatMoney(PlayerData[playerid][pSalary]-taxval));
	Dialog_Show(playerid, salary_paycheck, DIALOG_STYLE_MSGBOX, "Paycheck", str, "Get", "Close");
	return 1;
}

Dialog:salary_paycheck(playerid, response, listitem, inputtext[])
{
    if(response)
    {
        new taxval = PlayerData[playerid][pSalary]/100*govData[govTax];
        new nxtlevel = PlayerData[playerid][pScore]+1;
        new expamount = nxtlevel*1;
        Bank_SetBalance(playerid, PlayerData[playerid][pSalary]-taxval);
        PlayerData[playerid][pExp]++;
        GameTextForPlayer(playerid, "~w~Paycheck ~y~taken!", 5000, 1);
        PlayerData[playerid][pPaycheck] = 3600;
        PlayerData[playerid][pSalary] = 0;
        new string[256];
        mysql_format(sqlcon,string, sizeof(string), "DELETE FROM `character_salary` WHERE `owner` = '%d'", PlayerData[playerid][pID]);
        mysql_tquery(sqlcon, string);

        if (PlayerData[playerid][pExp] < expamount)
        {
            SendServerMessage(playerid, "You need %d more Paycheck to the next level.", expamount - PlayerData[playerid][pExp]);
        }
        else
        {
            PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
            PlayerData[playerid][pScore]++;
            PlayerData[playerid][pExp] = PlayerData[playerid][pExp]-expamount;

            SetPlayerScore(playerid, PlayerData[playerid][pScore]);
        
            SendServerMessage(playerid, "Level UP! Sekarang kamu level %d", PlayerData[playerid][pScore]);
            //PlayAudioStreamForPlayer(playerid, "https://www.mboxdrive.com/GTA San Andreas - Mission passed sound.mp3");
        }
        if(PlayerData[playerid][pQuitjob] > 0)
        {
            PlayerData[playerid][pQuitjob]--;
        }
    }
}

task Salary[1000]()
{
	foreach(new playerid : Player)
	{
	if(PlayerData[playerid][pLogged] == 1)
	{
		if(PlayerData[playerid][pPaycheck] > 3600)
		{
			PlayerData[playerid][pPaycheck] = 0;
		}
		if(PlayerData[playerid][pPaycheck] > 0)
		{
			PlayerData[playerid][pPaycheck]--;
			if(PlayerData[playerid][pPaycheck] <= 0)
			{
				SendServerMessage(playerid, "Kamu sudah bisa mengambil Paycheck sekarang!");
				PlayerData[playerid][pPaycheck] = 0;
			}
		}
	}
	}
}