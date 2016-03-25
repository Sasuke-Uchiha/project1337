//CYCLE HANDLER (FS)
#include <a_samp>
#include <stuff\defines>

enum MAP_INFO_enum
{
	MapID, //A unique Map ID.
	MapType, // The Type of Map.
	MapName[50], // Name of Map.
	MapMin, // Map Time in Mins.
	MapSec, // Map Time in Secs.
	MapBy[MAX_PLAYER_NAME] //Name of user who made the map.
}
new MapInfo[][MAP_INFO_enum] = {
	{1,MAP_TYPE_RACE,"MapName",5,30,"TheUser"}
};	

new MaxMaps;
new counter;

forward cycle_nextMission();
forward cycle_getcurrentid();
forward cycle_getcurrentmode();
forward cycle_getcurrentmaptime(variable);
//forward cycle_sendmissionname();

public OnFilterScriptInit()
{
	//load mission IDs and Names from Database
	counter = 0;
	MaxMaps=sizeof(MapInfo);
}

//Cross-Scripting
public cycle_nextMission()
{
	if(counter < MaxMaps -1) counter++;
	else counter = 0;
	new string[124];
	format(string,sizeof(string),"[CYCLE]"); // For later to easily add different type of cycles, currnt is only normal.
	switch(MapInfo[counter][MapType])
	{
		case MAP_TYPE_BOMBING: format(string,sizeof(string),"<!> %s Next Mission is Bombing: %s. | Map by %s.",string,MapInfo[counter][MapName],MapInfo[counter][MapBy]);
		case MAP_TYPE_DM: format(string,sizeof(string),"<!> %s Next Mission is Deathmatch: %s. | Map by %s.",string,MapInfo[counter][MapName],MapInfo[counter][MapBy]);
		case MAP_TYPE_STEALING: format(string,sizeof(string),"<!> %s Next Mission is Stealing: %s. | Map by %s.",string,MapInfo[counter][MapName],MapInfo[counter][MapBy]);
		case MAP_TYPE_NO_RESPAWN_DM: format(string,sizeof(string),"<!> %s Next Mission is Last Man Standing: %s. | Map by %s.",string,MapInfo[counter][MapName],MapInfo[counter][MapBy]);
		case MAP_TYPE_NO_RESPAWN_TDM: format(string,sizeof(string),"<!> %s Next Mission is Last Team Standing: %s. | Map by %s.",string,MapInfo[counter][MapName],MapInfo[counter][MapBy]);
		case MAP_TYPE_TDM: format(string,sizeof(string),"<!> %s Next Mission is Team Deathmatch: %s. | Map by %s.",string,MapInfo[counter][MapName],MapInfo[counter][MapBy]);
		default: format(string,sizeof(string),"<!> %s Next Mission is Race: %s. | Map by %s.",string,MapInfo[counter][MapName],MapInfo[counter][MapBy]);
	}
	SendClientMessageToAll(COLOR_CYCLE,string);
}

public cycle_getcurrentid() return MapInfo[counter][MapID];
public cycle_getcurrentmode() return MapInfo[counter][MapType];
public cycle_getcurrentmaptime(variable) // variable 0 is for Mins and 1 is for seconds
{
	if(variable == 0) return MapInfo[counter][MapMin];
	else return MapInfo[counter][MapSec];
}

/*public cycle_sendmissionname()
{
	//CallRemoteFunction("GM_SetMissionName","s",MapName[counter]);
}*/ //We might not need this, when we use /cycle command, we can call remote function and make dialog from here.
