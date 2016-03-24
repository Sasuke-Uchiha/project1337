#include <a_samp>
#include <a_mysql>
#include <float>

#include <mm\colors>

#define MYSQL_USERNAME 	"port_2489"
#define MYSQL_DATABASE 	"port_2489"
#define MYSQL_PASSWORD 	"1qg4dtzx2j"
#define MYSQL_SERVER 	"127.0.0.1"

native WP_Hash(buffer[], len, const str[]);

new mCon, qString[1001];


forward getConnection();

//ACCOUNT-RELATED FUNCTIONS
forward DB_PlayerBanCheck(playerid);
forward DB_SavePlayerData(aid,admin,vip,kills,deaths,money,ip[16]);
forward DB_PlayerLogin(playerid,password[]);
forward DB_PlayerRegister(playerid,password[]);

forward OnPlayerBanCheck(playerid);
forward OnPlayerLogin(playerid);
forward FindAccount(playerid);
forward OnFindAccount(playerid);



public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" DATABASE FILTERSCRIPT - INITIALIZED");
	print("--------------------------------------\n");
	
	//Establish a connection to the MYSQL-Server
	mysql_debug(1);
	mCon = mysql_connect(MYSQL_SERVER, MYSQL_USERNAME, MYSQL_DATABASE, MYSQL_PASSWORD);
	if(mysql_ping(mCon) > 0) { print("MySQL - Database connected!"); }
	
	return 1;
}

public OnFilterScriptExit()
{
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


public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

/* -- CUSTOM FUNCTIONS -- */

/* ---- BEGIN OF ACCOUNT-RELATED FUNCTIONS ---- */

public getConnection() { return mCon; }

public DB_PlayerBanCheck(playerid)
{
	new name[MAX_PLAYER_NAME];
	new ip[16];
	GetPlayerName(playerid,name,sizeof(name));
	GetPlayerIp(playerid,ip,sizeof(ip));
	
    format(qString, sizeof(qString), "SELECT * FROM `Bans` WHERE `Name` = '%s' OR `IP` = '%s'", name, ip);
	mysql_function_query(mCon, qString, true, "OnPlayerBanCheck", "i", playerid);
	return 1;
}

public DB_PlayerLogin(playerid,password[])
{
	new hashPass[129],name[MAX_PLAYER_NAME];

	GetPlayerName(playerid,name,sizeof(name));
	
    mysql_real_escape_string(password, password);

	WP_Hash(hashPass, sizeof(hashPass), password);
	format(qString, sizeof(qString), "SELECT * FROM `Accounts` WHERE Name = '%s' AND `Password` = '%s' LIMIT 1", name, hashPass);
	mysql_function_query(mCon, qString, true, "OnPlayerLogin", "i", playerid);
	return 1;
}

public DB_PlayerRegister(playerid,password[])
{
	new hashPass[129],name[MAX_PLAYER_NAME],ip[16];

	GetPlayerName(playerid,name,sizeof(name));
	GetPlayerIp(playerid,ip,16);
	
	mysql_real_escape_string(password, password);

    WP_Hash(hashPass, sizeof(hashPass), password);

	format(qString, sizeof(qString), "INSERT INTO `Accounts` \
	(`Name`, `Password`, `Admin`, `Vip`, `Kills`, `Deaths`, `Money`, `IP`, `RegDate`) VALUES \
	('%s', '%s', '0', '0', '0', '0', '0', '%s', NOW())", name, hashPass, ip);
	mysql_function_query(mCon, qString, false, "","");
	
	SendClientMessage(playerid,COLOR_LIGHT_BLUE,"You have successfully registered an Account!.");
	CallRemoteFunction("ShowLoginDialog","ii",playerid,0);

	return 1;
}

public DB_SavePlayerData(aid,admin,vip,kills,deaths,money,ip[16])
{
	format(qString,sizeof(qString),"UPDATE `Accounts` SET `Admin`='%i',`Vip`='%i',`Kills`='%i',\
	`Deaths`='%i',`Money`='%i',`IP`='%s' WHERE `aID` = '%i'",admin,vip,kills,deaths,money,ip,aid);
	mysql_function_query(mCon,qString,false,"","");

	return 1;
}

public FindAccount(playerid)
{
	new name[MAX_PLAYER_NAME];
	
	GetPlayerName(playerid,name,MAX_PLAYER_NAME);
	
	format(qString,sizeof(qString),"SELECT aID FROM `Accounts` WHERE `Name` = '%s' LIMIT 1",name);
	mysql_function_query(mCon,qString,true,"OnFindAccount","i",playerid);

	return 1;
}

/* ---- ACCOUNTS - THREADED QUERIES ----*/

public OnPlayerBanCheck(playerid)
{
	new rows,fields;
	cache_get_data(rows,fields,mCon);
	if(rows == 1)
	{
	    SendClientMessage(playerid,COLOR_RED,"Oops.. It seems like you're banned from this server.");
	    Kick(playerid);
	}
	else
	{
	    FindAccount(playerid);
	}
	return 1;
}

public OnFindAccount(playerid)
{
	new rows,fields;
	cache_get_data(rows,fields,mCon);

	if(rows) { CallRemoteFunction("ShowLoginDialog","ii",playerid,0);  }
	else { CallRemoteFunction("ShowRegisterDialog","i",playerid); }

	return 1;
}

public OnPlayerLogin(playerid)
{
	new rows,fields;
	cache_get_data(rows,fields,mCon);
	
	if(rows == 1)
	{
		new admin[1],vip[1],kills[11],deaths[11],money[11],aid[11];

		cache_get_row(0,0,aid,mCon);
		cache_get_row(0,3,admin,mCon);
		cache_get_row(0,4,vip,mCon);
		cache_get_row(0,5,kills,mCon);
		cache_get_row(0,6,deaths,mCon);
		cache_get_row(0,7,money,mCon);

		CallRemoteFunction("SetLoginData","iiiiiii",playerid,strval(aid),strval(admin),strval(vip),strval(kills),strval(deaths),strval(money));
 	}
 	
 	else
 	{
 	    CallRemoteFunction("ShowLoginDialog","ii",playerid,1);
 	}

	return 1;
}

/* ---- END OF ACCOUNT-RELATED FUNCTIONS ---- */

