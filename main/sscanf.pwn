stock strcash(value[])
{
	new dollars, cents, totalcash[25];
	if(strfind(value, ".", true) != -1)
	{
		sscanf(value, "p<.>dd", dollars, cents);
		format(totalcash, sizeof(totalcash), "%d%02d", dollars, cents);
	}
	else
	{
		sscanf(value, "d", dollars);
		format(totalcash, sizeof(totalcash), "%d00", dollars);
	}
	return strval(totalcash);
}