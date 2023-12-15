UpdateCharacterInt(playerid, const column_name[], value)
{
	mysql_tquery(sqlcon, sprintf("UPDATE `ucp_characters` SET `%s` = '%d' WHERE `ID` = '%d';", column_name, value, GetPlayerSQLID(playerid)));
	return 1;
}

stock UpdateCharacterFloat(playerid, const column_name[], Float:value) 
{
	mysql_tquery(sqlcon, sprintf("UPDATE `ucp_characters` SET `%s` = '%.4f' WHERE `ID`='%d';", column_name, value, GetPlayerSQLID(playerid)));
	return 1;
}

UpdateCharacterString(playerid, const column_name[], value[]) 
{
	mysql_tquery(sqlcon, sprintf("UPDATE `ucp_characters` SET `%s` = '%s' WHERE `ID`='%d';", column_name, SQL_ReturnEscaped(value), GetPlayerSQLID(playerid)));
	return 1;
}

cache_get_field_content(row, const field_name[], destination[], max_len = sizeof(destination))
{
    cache_get_value_name(row, field_name, destination, max_len);
}

cache_get_data(&rows, &fields)
{
    cache_get_row_count(rows);
    cache_get_field_count(fields);
}

cache_get_field_int(row, const field_name[])
{
    new val;
    cache_get_value_name_int(row, field_name, val);
    return val;
}

stock Float:cache_get_field_float(row, const field_name[])
{
    new
        str[16];

    cache_get_field_content(row, field_name, str, sizeof(str));
    return floatstr(str);
}