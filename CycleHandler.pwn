//GAMEMODE
#include <a_samp>
#include <stuff\defines>

new mapid,maptype,mMin,mSec,mTimer;

forward GM_StartTimer(time);
forward TimerFunc();
forward GM_Restart();

public OnGameModeInit()
{
	mapid = CallRemoteFunction("cycle_getcurrentid",""); //Get's map id from CycleHandler
	maptype = CallRemoteFunction("cycle_getcurrentmode",""); //Get's map type from CycleHandler

	CallRemoteFunction("maphandler_init","i",mapid); //initialize the map handler	

	switch(maptype)
	{
		case MAP_TYPE_BOMBING: SendRconCommand("loadfs bombing");
		case MAP_TYPE_DM: SendRconCommand("loadfs deathmatch");
		case MAP_TYPE_STEALING: SendRconCommand("loadfs stealing");
		case MAP_TYPE_NO_RESPAWN_DM: SendRconCommand("loadfs lms");
		case MAP_TYPE_NO_RESPAWN_TDM: SendRconCommand("loadfs lts");
		case MAP_TYPE_TDM: SendRconCommand("loadfs tdm");
		default: SendRconCommand("loadfs race");
	}	
	//CallRemoteFunction("cycle_sendmissionname",""); We just don't need it.
}

public GM_StartTimer(time) //maphandler
{
	mMin = CallRemoteFunction("cycle_getcurrentmaptime","i",0);
	mSec = CallRemoteFunction("cycle_getcurrentmaptime","i",1);
	mTimer = SetTimer("TimeFunc",1000,true);
}

public TimerFunc()
{
	new string[10];
	mSec--;
	if(mMin < 10) format(string,sizeof(string),"0%d",mMin);
	else format(string,sizeof(string),"%d",mMin);
	if(mSec < 10) format(string,sizeof(string),"%s:0%d",string,mSec);
	else format(string,sizeof(string),"%s:%d",string,mSec);
	CallRemoteFunction("textdraw_UpdateMissionClock","ii",mMin,mSec);//Clock Textdraw update should be added here.
	if(mSec < 1 && mMin > 0) 
	{ 
		mSec = 59;
		mMin--;
	}
	else if(mSec == 0 && mMin == 0)
	{
		CallRemoteFunction("maphandler_reset","");
		CallRemoteFunction("cycle_nextMission","");

		switch(maptype)
		{
			case MAP_TYPE_BOMBING: SendRconCommand("unloadfs bombing");
			case MAP_TYPE_DM: SendRconCommand("unloadfs deathmatch");
			case MAP_TYPE_STEALING: SendRconCommand("unloadfs stealing");
			case MAP_TYPE_NO_RESPAWN_DM: SendRconCommand("unloadfs lms");
			case MAP_TYPE_NO_RESPAWN_TDM: SendRconCommand("unloadfs lts");
			case MAP_TYPE_TDM: SendRconCommand("unloadfs tdm");
			default: SendRconCommand("unloadfs race");
		}
		
		//rewards etc... DO NOT ADD THEM NOW!
		KillTimer(mTimer);
		SetTimer("GM_Restart",3000,false); //3 sec
	}
}

public GM_Restart() { return SendRconCommand("gmx"); }
