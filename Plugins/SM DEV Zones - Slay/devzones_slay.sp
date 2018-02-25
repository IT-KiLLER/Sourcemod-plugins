
/*	Copyright (C) 2018 IT-KiLLER
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
#include <sdktools>
#include <devzones>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "SM DEV Zones - Slay",
	author = "IT-KiLLER", 
	description = "Slay Zone", 
	version = "1.0", 
	url = "https://github.com/IT-KiLLER"
};

public int Zone_OnClientEntry(int client, char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) return;

	if(StrContains(zone, "slay", false) != 0) return;

	ForcePlayerSuicide(client);
}
