GetDuration(time)
{
    new
        str[32];

    if(time < 0 || time == gettime()) {
        format(str, sizeof(str), "Never");
        return str;
    }
    else if(time < 60)
        format(str, sizeof(str), "%d seconds", time);

    else if(time >= 0 && time < 60)
        format(str, sizeof(str), "%d seconds", time);

    else if(time >= 60 && time < 3600)
        format(str, sizeof(str), (time >= 120) ? ("%d minutes") : ("%d minute"), time / 60);

    else if(time >= 3600 && time < 86400)
        format(str, sizeof(str), (time >= 7200) ? ("%d hours") : ("%d hour"), time / 3600);

    else if(time >= 86400 && time < 2592000)
        format(str, sizeof(str), (time >= 172800) ? ("%d days") : ("%d day"), time / 86400);

    else if(time >= 2592000 && time < 31536000)
        format(str, sizeof(str), (time >= 5184000) ? ("%d months") : ("%d month"), time / 2592000);

    else if(time >= 31536000)
        format(str, sizeof(str), (time >= 63072000) ? ("%d years") : ("%d year"), time / 31536000);

    strcat(str, " ago");

    return str;
}
