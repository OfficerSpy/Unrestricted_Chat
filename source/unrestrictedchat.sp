#include <sourcemod>
#include <dhooks>

#pragma semicolon 1

ConVar unrestrictedchat_allow_bots;

static DynamicHook m_hCanHearAndReadChatFrom;

public Plugin myinfo =
{
	name = "Unrestricted Chat",
	author = "Officer Spy",
	description = "Allow players on any team with any life state to chat with each other.",
	version = "1.0.1",
	url = ""
};

public void OnPluginStart()
{
	unrestrictedchat_allow_bots = CreateConVar("sm_unrestrictedchat_allow_bots", "1", "Allow chats to be seen from fake players", FCVAR_NOTIFY);
	
	GameData hGamedata = new GameData("unrestrictedchat.games");
	
	if (hGamedata == null)
		SetFailState("Could not find gamedata file!");
	
	int offset = hGamedata.GetOffset("CBasePlayer::CanHearAndReadChatFrom");
	
	if (offset == -1)
		SetFailState("Failed to retrieve offset for CBasePlayer::CanHearAndReadChatFrom");
	
	m_hCanHearAndReadChatFrom = DynamicHook.FromConf(hGamedata, "CBasePlayer::CanHearAndReadChatFrom");
	
	if (m_hCanHearAndReadChatFrom == null)
		SetFailState("Failed to setup DynamicHook for CBasePlayer::CanHearAndReadChatFrom");
	
	CloseHandle(hGamedata);
}

public void OnClientPutInServer(int client)
{
	DHookEntity(m_hCanHearAndReadChatFrom, true, client, _, DHookCallback_CanHearAndReadChatFrom_Post);
}

public MRESReturn DHookCallback_CanHearAndReadChatFrom_Post(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	int them = hParams.Get(1);
	
	if (unrestrictedchat_allow_bots.BoolValue == false && IsFakeClient(them))
		hReturn.Value = false;
	else
		hReturn.Value = true;
	
	return MRES_Supercede;
}