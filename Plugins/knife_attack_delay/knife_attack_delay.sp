#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#pragma semicolon 1
#pragma newdecls required
 
bool Marked[MAXPLAYERS + 1];
 
public Plugin myinfo =  
{
	name = "Knife Delay",  
	author = "Arkarr, thedudeguy1, IT-KILLER",
	description = "Knifed delay",  
	version = "1.3.1",  
	url = "https://github.com/IT-KiLLER"
};

public void OnPluginStart()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		}
	}
}
 
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
 
public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (!victim || !attacker) return Plugin_Continue;

	char weapon[64];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if (StrContains(weapon, "knife") != -1 || StrEqual(weapon, "weapon_bayonet"))
	{
		if (!Marked[victim])
		{
			ImmunePlayer(victim);
			if(damage > 65.00)
			{
				damage = 65.00;
				return Plugin_Changed;
			}
		}
		else
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}
 
public void ImmunePlayer(int client)
{
	Marked[client] = true;
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, 100, 255, 100, 200);
	 
	CreateTimer(3.0, TMR_Unmark, client);
}
 
public Action TMR_Unmark(Handle tmr, any client)
{
	Marked[client] = false;
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, 255, 255, 255, 255);
}