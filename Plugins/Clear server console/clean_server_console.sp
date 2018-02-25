
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

#include <PTaH>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[CS:GO] Clear server console",
	author = "IT-KiLLER",
	description = "clear server console",
	version = "1.0 pre-release",
	url = "https://github.com/IT-KiLLER"
}

public void OnPluginStart() 
{
	PTaH(PTaH_ServerConsolePrint, Hook, ServerConsolePrint);
}

//Block messages that contain DataTable warning etc.
public Action ServerConsolePrint(const char[] sMessage, LoggingSeverity severity)
{
	if (
		StrContains(sMessage, "<BOT>") != -1 || 
		StrContains(sMessage, "] attacked ") != -1 || 
		StrContains(sMessage, "NOCLIP mode") != -1 || 
		StrContains(sMessage, "purchased ") != -1 || 
		StrContains(sMessage, "buyzone ") != -1 || 
		StrContains(sMessage, "UTIL_GetListenServerHost() ") != -1 ||
		StrContains(sMessage, "DataTable warning") != -1
		) {
		return Plugin_Handled; 
	}
	return Plugin_Continue;
}  