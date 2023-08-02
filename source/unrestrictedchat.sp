#include <sourcemod>
#include <dhooks>

#pragma semicolon 1

ConVar unrestricted_chat_bots_allow;

DynamicHook g_DHookCanHearAndReadChatFrom;

public Plugin myinfo =
{
	name = "Unrestricted Chat",
	author = "Officer Spy",
	description = "Allow players on any team with any life state to chat with each other.",
	version = "1.0.0",
	url = ""
};

public void OnPluginStart()
{
	unrestricted_chat_bots_allow = CreateConVar("sm_unrestricted_chat_bots_allow", "1", "Allow chats to be seen from fake players.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	GameData hGamedata = new GameData("unrestrictedchat.games");
	
	if (hGamedata == null)
		SetFailState("Could not find gamedata file!");
	
	int offset = hGamedata.GetOffset("CBasePlayer::CanHearAndReadChatFrom");
	
	if (offset == -1)
		SetFailState("Failed to retrieve offset for CBasePlayer::CanHearAndReadChatFrom!");
	
	delete hGamedata;
	
	g_DHookCanHearAndReadChatFrom = new DynamicHook(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity);
	g_DHookCanHearAndReadChatFrom.AddParam(HookParamType_CBaseEntity);
}

public void OnClientPutInServer(int client)
{
	DHookEntity(g_DHookCanHearAndReadChatFrom, true, client, _, DHookCallback_CanHearAndReadChatFrom_Post);
}

public MRESReturn DHookCallback_CanHearAndReadChatFrom_Post(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	int them = hParams.Get(1);
	
	if (unrestricted_chat_bots_allow.BoolValue == false && IsFakeClient(them))
		hReturn.Value = false;
	else
		hReturn.Value = true;
	
	return MRES_Supercede;
}