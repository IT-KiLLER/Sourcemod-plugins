#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
	name = "Zero Nominations Day",
	author = "IT-KiLLER",
	description = "Another mapcycle file for Zero-nom day",
	version = "1.0 pre-release",
	url = "https://github.com/IT-KiLLER"
};

public void OnPluginEnd()
{
	SetMapListCompatBind("mapcyclefile", "mapcycle.txt");
	SetMapListCompatBind("official", "mapcycle.txt");
	SetMapListCompatBind("nominations", "mapcycle.txt");
}

public void OnMapStart()
{
	char FormatedTime[12];
	FormatTime(FormatedTime, 12, "%A", GetTime());
	
	if(StrEqual(FormatedTime, "Sunday", true) || true) 
	{
		SetMapListCompatBind("mapcyclefile", "mapcycle_zeronom.txt");
		SetMapListCompatBind("official", "mapcycle_zeronom.txt");
		SetMapListCompatBind("nominations", "mapcycle_zeronom.txt");
	}
	else
	{
		SetMapListCompatBind("mapcyclefile", "mapcycle.txt");
		SetMapListCompatBind("official", "mapcycle.txt");
		SetMapListCompatBind("nominations", "mapcycle.txt");
	}
}