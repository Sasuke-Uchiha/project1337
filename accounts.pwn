#include <a_samp>
#include <a_mysql>
#include <zcmd>
#include <sscanf2>

#include <stuff\defines>

#define DIALOG_REGISTER 0
#define DIALOG_LOGIN 1


forward SetLoginData(playerid,aid,admin,vip,kills,deaths,money);
forward ShowLoginDialog(playerid,idx);
forward ShowRegisterDialog(playerid);

enum pInfo {
	AccID,
	bool:Logged,
	Name[MAX_PLAYER_NAME],
	IP[16],
	Admin,
	Vip,
	Money,
	Kills,
	Deaths,
	Hours,
	Minutes,
	Seconds
}

new Player[MAX_PLAYERS][pInfo];

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Account Filterscript - INITIALIZED ");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	print(" Account Filterscript UNLOADED ");
	return 1;
}

public OnGameModeInit()
{
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	new welcomemsg[128];
	GetPlayerName(playerid,Player[playerid][Name],MAX_PLAYER_NAME);
	GetPlayerIp(playerid, Player[playerid][IP], 16);
	format(welcomemsg,sizeof(welcomemsg),"%s (%i) has joined the Server.",Player[playerid][Name],playerid);
	SendClientMessageToAll(COLOR_GREY,welcomemsg);

	CallRemoteFunction("DB_PlayerBanCheck","i",playerid);

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new leavemsg[128];

	//Store data in DB
	CallRemoteFunction("DB_SavePlayerData","iiiiiis",Player[playerid][AccID],Player[playerid][Admin],Player[playerid][Vip],
	Player[playerid][Kills],Player[playerid][Deaths],Player[playerid][Money],Player[playerid][IP]);

	Player[playerid][AccID] = -1;
	Player[playerid][Admin] = 0;
	Player[playerid][Vip] = 0;
	Player[playerid][Kills] = 0;
	Player[playerid][Deaths] = 0;
	Player[playerid][Money] = 0;

	Player[playerid][Logged] = false;

	format(leavemsg,sizeof(leavemsg),"%s (%i) has left the Server.",Player[playerid][Name],playerid);
	SendClientMessageToAll(COLOR_GREY,leavemsg);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	Player[playerid][Deaths]++;
	if(killerid != INVALID_PLAYER_ID)
		Player[killerid][Kills]++;
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new str[256];
	switch(dialogid)
	{
	    case DIALOG_LOGIN:
		{
	        if(!response) Kick(playerid);
			if(strlen(inputtext) > 5 && strlen(inputtext) < 32)
			{
				CallRemoteFunction("DB_PlayerLogin","is",playerid,inputtext);
			}
			else
			{
			    ShowLoginDialog(playerid,1);
			}
		}
	    case DIALOG_REGISTER:
		{
	        if(!response) { SendClientMessage(playerid,COLOR_YELLOW,"You must register in order to play, so you got kicked!"); Kick(playerid); return 1;}

	        if(strlen(inputtext) <= 5 || strlen(inputtext) >= 32)
			{
			    str = "{FF0000}Error on Registration!\n{FFFFFF}Your password must have at least 5 characters and not more than 32 characters.";
				ShowPlayerDialog(playerid,DIALOG_REGISTER,DIALOG_STYLE_PASSWORD,"User Registration",str,"Register!","Cancel");
			}
			else
			{
				CallRemoteFunction("DB_PlayerRegister","is",playerid,inputtext);

	            /*format(str, sizeof(str), "4%s (%d) is now a Registered User.", Player[playerid][Name], playerid);
				CallRemoteFunction("IRC_CHAT", "s", str);*/
			}
	    }
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

/* -- CUSTOM FUNCTIONS -- */
public SetLoginData(playerid,aid,admin,vip,kills,deaths,money)
{
	new str[128];

	Player[playerid][AccID] = aid;
	Player[playerid][Admin] = admin;
	Player[playerid][Vip] = vip;
	Player[playerid][Kills] = kills;
	Player[playerid][Deaths] = deaths;
	Player[playerid][Money] = money;
	Player[playerid][Logged] = true;

	format(str,sizeof(str),"Welcome back, %s!",Player[playerid][Name]);
	SendClientMessage(playerid,COLOR_YELLOW,str);

	return 1;
}

public ShowLoginDialog(playerid,idx)
{
	new text[256];
	if(idx == 0)
	    format(text,sizeof(text),"{FFFFFF}Hello {FF8800}%s\n{FFFFFF}Please enter your password below to Login.",Player[playerid][Name]);
	else
		text = "{FF0000}Wrong Password!\n{FFFFFF}Enter the correct Password or choose another Nickname.";

	ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"User Login",text,"Login!","Cancel");
	return 1;
}

public ShowRegisterDialog(playerid)
{
	new text[256];
	format(text,sizeof(text),"{FFFFFF}Hello {FF8800}%s\n{FFFFFF}This Username has not been found in our database.\nEnter a password below to Register.",Player[playerid][Name]);
	ShowPlayerDialog(playerid,DIALOG_REGISTER,DIALOG_STYLE_PASSWORD,"User Registration",text,"Register!","Cancel");
	return 1;
}

/* ------------- COMMANDS --------------------*/

//TODO
