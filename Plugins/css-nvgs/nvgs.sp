
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
#include <sdktools_functions>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "[CSS] !nv",
	author = "IT-KiLLER",
	description = "",
	version = "1.0",
	url = "https://github.com/IT-KiLLER"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_nv", Command_NV);
}

public Action Command_NV(int client, int args)
{
	if(!client) return Plugin_Handled;
	PrintToChat(client, "[SM] You got nvg.");
	GivePlayerItem(client, "item_nvgs");  
	return Plugin_Handled;
}