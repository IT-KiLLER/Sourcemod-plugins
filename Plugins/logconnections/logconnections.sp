
/*	Copyright (C) 2017 IT-KiLLER
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include <sourcemod>
#include <geoip>
#pragma semicolon 1
#pragma newdecls required
#define PLAYER_LOG_PATH "logs/connections/player"
#define ADMIN_LOG_PATH "logs/connections/admin"

public Plugin myinfo =
{
	name = "Log Connections",
	author = "Xander and IT-KiLLER",
	description = "This plugin logs players' connect and disconnect times along with their Name, SteamID, and IP Address to a text file at /sourcemod/logs/connections/ seperate from the server logs.",
	version = "1.2a",
	url = "https://github.com/IT-KiLLER"
}

char player_filepath[PLATFORM_MAX_PATH];
char admin_filepath[PLATFORM_MAX_PATH];
bool clientConnected[MAXPLAYERS+1] = {false,...};
bool clientIsAdmin[MAXPLAYERS+1] = {false,...};

public void OnPluginStart()
{
	// PLAYER
	BuildPath(Path_SM, player_filepath, sizeof(player_filepath), PLAYER_LOG_PATH);
	if (!DirExists(player_filepath))
	{
		CreateDirectory(player_filepath, 511);
		
		if (!DirExists(player_filepath))
			LogMessage("Failed to create directory at %s - Please manually create that path and reload this plugin.", PLAYER_LOG_PATH);
	}
	// ADMIN
	BuildPath(Path_SM, admin_filepath, sizeof(admin_filepath), ADMIN_LOG_PATH);
	if (!DirExists(admin_filepath))
	{
		CreateDirectory(admin_filepath, 511);
		
		if (!DirExists(admin_filepath))
			LogMessage("Failed to create directory at %s - Please manually create that path and reload this plugin.", ADMIN_LOG_PATH);
	}

	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			clientConnected[client] = true;
			if(IsPlayerAdmin(client)) 
				clientIsAdmin[client] = true;
		}
	}
}

public void OnMapStart()
{
	char FormatedTime[100];
	char MapName[100];
		
	int CurrentTime = GetTime();
	
	GetCurrentMap(MapName, 100);
	FormatTime(FormatedTime, 100, "%d_%b_%Y", CurrentTime); //name the file 'day month year'
	
	BuildPath(Path_SM, player_filepath, sizeof(player_filepath), "%s/%s_player.txt", PLAYER_LOG_PATH,FormatedTime);
	BuildPath(Path_SM, admin_filepath, sizeof(admin_filepath), "%s/%s_admin.txt", ADMIN_LOG_PATH,FormatedTime);
	
	Handle playerHandle = OpenFile(player_filepath, "a+");
	Handle adminHandle = OpenFile(admin_filepath, "a+");
	
	FormatTime(FormatedTime, 100, "%X", CurrentTime);
	// PLAYER
	WriteFileLine(playerHandle, "");
	WriteFileLine(playerHandle, "%s - ===== Map change to %s =====", FormatedTime, MapName);
	WriteFileLine(playerHandle, "");
	CloseHandle(playerHandle);
	// ADMIN
	WriteFileLine(adminHandle, "");
	WriteFileLine(adminHandle, "%s - ===== Map change to %s =====", FormatedTime, MapName);
	WriteFileLine(adminHandle, "");
	CloseHandle(adminHandle);
}

public void OnRebuildAdminCache(AdminCachePart part)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAdmin(client))
		{
			clientIsAdmin[client] = true;
		}
	}
}

public void OnClientPostAdminCheck(int client) {
	if(!client)
	{
		// console or unknown client
	} 
	else if(IsFakeClient(client))
	{
		// bot
	}	
	else if (clientConnected[client])
	{
		// Already connected
	}
	else if(IsPlayerAdmin(client)) 
	{ 	// ADMIN
		clientConnected[client] = true;
		clientIsAdmin[client] = true;
		char PlayerName[64];
		char Authid[64];
		char IPAddress[64];
		char Country[64];
		char FormatedTime[64];
		
		GetClientName(client, PlayerName, 64);
		GetClientAuthId(client, AuthId_Steam2, Authid, sizeof(Authid), false);
		GetClientIP(client, IPAddress, 64);
		FormatTime(FormatedTime, 64, "%X", GetTime());
		
		if(!GeoipCountry(IPAddress, Country, 64))
		{
			Format(Country, 64, "Unknown");
		}
		
		Handle adminHandle = OpenFile(admin_filepath, "a+");
		WriteFileLine(adminHandle, "%s - <%s> <%s> <%s> CONNECTED from <%s>",
								FormatedTime,
								PlayerName,
								Authid,
								IPAddress,
								Country);

		CloseHandle(adminHandle);
	}	
	else // PLAYER
	{
		clientConnected[client] = true;
		clientIsAdmin[client] = false;
		char PlayerName[64];
		char Authid[64];
		char IPAddress[64];
		char Country[64];
		char FormatedTime[64];
		
		GetClientName(client, PlayerName, 64);
		GetClientAuthId(client, AuthId_Steam2, Authid, sizeof(Authid), false);
		GetClientIP(client, IPAddress, 64);
		FormatTime(FormatedTime, 64, "%X", GetTime());
		
		if(!GeoipCountry(IPAddress, Country, 64))
		{
			Format(Country, 64, "Unknown");
		}
		
		Handle playerHandle = OpenFile(player_filepath, "a+");
		WriteFileLine(playerHandle, "%s - <%s> <%s> <%s> CONNECTED from <%s>",
								FormatedTime,
								PlayerName,
								Authid,
								IPAddress,
								Country);

		CloseHandle(playerHandle);
	}
}

public Action Event_PlayerDisconnect(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!clientConnected[client]) return;
	clientConnected[client] = false;
	if (!client)
	{
		// console or unknown client
	}
	else if (IsFakeClient(client))
	{
		// bot
	}	
	else if (clientIsAdmin[client]) 
	{	// ADMIN
		int ConnectionTime = -1;
		Handle adminHandle = OpenFile(admin_filepath, "a+");
		
		char PlayerName[64];
		char Authid[64];
		char IPAddress[64];
		char FormatedTime[64];
		char Reason[128];
		
		GetClientName(client, PlayerName, 64);
		GetClientIP(client, IPAddress, 64);
		FormatTime(FormatedTime, 64, "%X", GetTime());
		GetEventString(event, "reason", Reason, 128);

		if (!GetClientAuthId(client, AuthId_Steam2, Authid, sizeof(Authid), false))
		{
			Format(Authid, 64, "Unknown SteamID");
		}
		
		if (IsClientInGame(client))
		{
			ConnectionTime = RoundToCeil(GetClientTime(client) / 60);
		}
		
		WriteFileLine(adminHandle, "%s - <%s> <%s> <%s> DISCONNECTED after %d minutes. <%s>",
								FormatedTime,
								PlayerName,
								Authid,
								IPAddress,
								ConnectionTime,
								Reason);
		
		CloseHandle(adminHandle);
	}	
	else
	{	// PLAYER
		int ConnectionTime = -1;
		Handle playerHandle = OpenFile(admin_filepath, "a+");
		
		char PlayerName[64];
		char Authid[64];
		char IPAddress[64];
		char FormatedTime[64];
		char Reason[128];
		
		GetClientName(client, PlayerName, 64);
		GetClientIP(client, IPAddress, 64);
		FormatTime(FormatedTime, 64, "%X", GetTime());
		GetEventString(event, "reason", Reason, 128);

		if (!GetClientAuthId(client, AuthId_Steam2, Authid, sizeof(Authid), false))
		{
			Format(Authid, 64, "Unknown SteamID");
		}
		
		if (IsClientInGame(client))
		{
			ConnectionTime = RoundToCeil(GetClientTime(client) / 60);
		}
		
		WriteFileLine(playerHandle, "%s - <%s> <%s> <%s> DISCONNECTED after %d minutes. <%s>",
								FormatedTime,
								PlayerName,
								Authid,
								IPAddress,
								ConnectionTime,
								Reason);
		
		CloseHandle(playerHandle);
	}
	clientIsAdmin[client] = false;
}

// Checking if a client is admin
stock bool IsPlayerAdmin(int client)
{
	if (CheckCommandAccess(client, "Generic_admin", ADMFLAG_GENERIC, false))
	{
		return true;
	}
	return false;
}