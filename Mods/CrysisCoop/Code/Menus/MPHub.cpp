#include "StdAfx.h"

#include "INetwork.h"
#include "INetworkService.h"

#include "MPHub.h"
#include "MultiplayerMenu.h"
#include "QuickGame.h"
#include "GameNetworkProfile.h"


#include "Game.h"
#include "IGameFramework.h"
#include "IPlayerProfiles.h"
#include "OptionsManager.h"
#include "FlashMenuObject.h"
#include <IVideoPlayer.h>
#include "CryThread.h"

static const char* gTSPListFileFullName = "%USER%\\TSP.xml";
static const char* gTSPListFileURL = "http://www.ea.com/editorial/crysis/crysis.xml";

static TKeyValuePair<EGsUiCommand,const char*>
gUiCommands[] = {  
  {eGUC_none,""},
  {eGUC_opened,"MenuOpened"},
  {eGUC_back,"Back"},
  {eGUC_cancel,"LoginCancelled"},
  {eGUC_login,"Login"},
  {eGUC_logoff,"AccountDisconnect"},
	{eGUC_accountInfo,"ShowAcountInfo"},
	{eGUC_disableAutoLogin,"AutoDisconnect"},
  {eGUC_rememberPassword,"MPLogin_RememberPassword"},
  {eGUC_forgotPassword,"MPLogin_ForgotPassword"},
  {eGUC_autoLogin,"MPLogin_AutoLogin"},
  {eGUC_internetGame,"MP_InternetGame"},
  {eGUC_recordedGames,"MP_RecordedGames"},
  {eGUC_enterlobby,"LobbyEnter"},
  {eGUC_leavelobby,"LobbyLeave"},
  {eGUC_enterLANlobby,"LanLobbyEnter"},
  {eGUC_leaveLANlobby,"LanLobbyLeave"},
	{eGUC_enterLoginScreen,"EnterLoginScreen"},
	{eGUC_leaveLoginScreen,"LeaveLoginScreen"},
  {eGUC_update,"UpdateServerList"},
  {eGUC_stop,"StopUpdate"},
  {eGUC_setVisibleServers,"SetVisibleServers"},
  {eGUC_displayServerList,"GetServerList"},
  {eGUC_serverScrollBarPos,"ServerScrollbarPos"},
  {eGUC_serverScroll,"ScrollServerList"},
  {eGUC_refreshServer,"RefreshServerList"},
  {eGUC_selectServer,"SetSelectServer"},
	{eGUC_addFavorite,"AddToFavourites"},
  {eGUC_removeFavorite,"RemoveFromFavourites"},
	{eGUC_addFavoriteByIP,"AddToFavoritesServerIP"},
  {eGUC_sortColumn,"SetSortColumn"},
  {eGUC_join,"JoinServer"},
  {eGUC_joinIP,"ConnectToServerIP"},
  {eGUC_joinPassword,"JoinServerWithPassword"},
  {eGUC_disconnect,"Disconnect"},
  {eGUC_tab,"TabEnter"},
  {eGUC_chatClick,"OnBuddyClick"},
  {eGUC_chatOpen,"OnBuddyOpen"},
  {eGUC_chat,"EnteredMessage"},
  {eGUC_find,"UserFind"},
  {eGUC_addBuddy,"AddToBuddies"},
	{eGUC_addIgnore,"AddToIgnore"},
	{eGUC_addBuddyFromFind,"FindAddToBuddies"},
  {eGUC_addBuddyFromInfo,"InfoAddToBuddies"},
  {eGUC_addIgnoreFromInfo,"InfoAddToIgnore"},
  {eGUC_removeBuddy,"RemoveFromBuddies"},
  {eGUC_inviteBuddy,"sendinvitation"},
  {eGUC_stopIgnore,"StopIgnoring"},
  {eGUC_acceptBuddy,"AddFriendAccepted"},
  {eGUC_declineBuddy,"AddFriendDeclined"},
  {eGUC_displayInfo,"ShowInfoOn"},
  {eGUC_displayInfoInList,"ShowBuddyListInfoOn"},
  {eGUC_joinBuddy,"JoinBuddy"},
  {eGUC_userScrollBarPos,"BuddyScrollbarPos"},
  {eGUC_userScroll,"ScrollBuddyList"},
  {eGUC_chatScrollBarPos,"ChatScrollbarPos"},
  {eGUC_chatScroll,"ScrollChatList"},
  {eGUC_register,"MPAccount_START"},
  {eGUC_registerNick,"MPAccount_LOGIN"},
  {eGUC_registerEmail,"MPAccount_EMAIL"},
  {eGUC_registerDateMM,"MPAccount_DATE_MONTH"},
  {eGUC_registerDateDD,"MPAccount_DATE_DAY"},
  {eGUC_registerDateYY,"MPAccount_DATE_YEAR"},
	{eGUC_registerCountry,"MPAccount_COUNTRY"},
  {eGUC_registerEnd,"MPAccount_END"},
  {eGUC_quickGame,"MP_QuickGame"},
  {eGUC_createServerStart,"StartServer"},
	{eGUC_createServerUpdateLevels,"CreateServer_GameMode"},
	{eGUC_createServerOpened,"CreateGameOpened"},
  {eGUC_createServerParams,"GetGlobalSettings"},
  {eGUC_dialogClosed,"LoadingCanceled"},
  {eGUC_dialogYes,"ErrorBoxYes"},
  {eGUC_dialogNo,"ErrorBoxNo"},
	{eGUC_filtersDisplay,"FiltersOpened"},
  {eGUC_filtersEnable,"MPFilter_Enabled"},
  {eGUC_filtersMode,"MPFilter_GameMode"},
  {eGUC_filtersMap,"MPFilter_Mapname"},
  {eGUC_filtersPing,"MPFilter_Ping"},
  {eGUC_filtersNotFull,"MPFilter_NotFull"},
  {eGUC_filtersNotEmpty,"MPFilter_NotEmpty"},
  {eGUC_filtersNoPassword,"MPFilter_NoPassword"},
  {eGUC_filtersAutoTeamBalance,"MPFilter_AutoTeam"},
  {eGUC_filtersAntiCheat,"MPFilter_AntiCheat"},
  {eGUC_filtersFriendlyFire,"MPFilter_FriendlyFire"},
  {eGUC_filtersGamepadsOnly,"MPFilter_GamepadsOnly"},
  {eGUC_filtersNoVoiceComms,"MPFilter_NoVoiceComms"},
  {eGUC_filtersDedicated,"MPFilter_DecicatedServer"},
  {eGUC_filtersDX10,"MPFilter_DirectX"},
	{eGUC_mapDownloadCancel,"cancelMapDownload"},
	{eGUC_downloadErrorYes,"ErrorBoxDownloadYes"},
	{eGUC_downloadErrorNo,"ErrorBoxDownloadNo"},
	{eGUC_downloadOK,"ErrorBoxBigOk"},
	{eGUC_enteredCDKey, "EnteredCDKey"}
};

static TKeyValuePair<EDisconnectionCause,const char*>
gDisconnectErrors[] = {	{eDC_Unknown,"@ui_menu_disconnect_Generic"},
												{eDC_Timeout,"@ui_menu_disconnect_Timeout"},
												{eDC_ProtocolError,"@ui_menu_disconnect_Generic"},
												{eDC_ResolveFailed,"@ui_menu_disconnect_Unreachable"},
												{eDC_VersionMismatch,"@ui_menu_disconnect_VersionMismatch"},
												{eDC_ServerFull,"@ui_menu_disconnect_ServerFull"},
												{eDC_Kicked,"@ui_menu_disconnect_Kicked"},
												{eDC_Banned,"@ui_menu_disconnect_Banned"},
												{eDC_ContextCorruption,"@ui_menu_disconnect_Generic"},
												{eDC_AuthenticationFailed,"@ui_menu_disconnect_AuthenticationFailed"},
												{eDC_NotLoggedIn,"@ui_menu_disconnect_AuthenticationFailed"},
												{eDC_CDKeyChekFailed,"@ui_menu_disconnect_CDKey"},
												{eDC_GameError,"@ui_menu_disconnect_Generic"},
												{eDC_NotDX10Capable,"@ui_menu_disconnect_DX10"},
												{eDC_NubDestroyed,"@ui_menu_disconnect_ServerQuit"},
												{eDC_ICMPError,"@ui_menu_disconnect_Unreachable"},
												{eDC_NatNegError,"@ui_menu_disconnect_Unreachable"},
												{eDC_PunkDetected,"@ui_menu_disconnect_Kicked"},
												{eDC_DemoPlaybackFinished,"@ui_menu_disconnect_Generic"},
												{eDC_DemoPlaybackFileNotFound,"@ui_menu_disconnect_Generic"},
												{eDC_UserRequested,"@ui_menu_disconnect_Generic"},
												{eDC_NoController,"@ui_menu_disconnect_Controller"},
												{eDC_CantConnect,"@ui_menu_disconnect_CantConnect"},
												{eDC_ModMismatch,"@ui_menu_disconnect_Mod"},
												{eDC_MapNotFound,"@ui_menu_disconnect_MapNotFound"},
												{eDC_MapVersion,"@ui_menu_disconnect_MapVersion"},
												{eDC_PunkBusterRequired,"@ui_menu_disconnect_PunkBusterRequired"},
											};

CMPHub::CMPHub():
m_menu(0),
m_currentScreen(0),
m_currentStartScreen(0),
m_currentIngameScreen(0),
m_loggingIn(false),
m_enteringLobby(false),
m_searchingQuickGame(false),
m_menuOpened(false),
m_lastMenu(0),
m_isInLogin(false)
{
  gEnv->pNetwork->GetService("GameSpy");
}

CMPHub::~CMPHub()
{
 // m_menu.reset(0);
 // m_profile.reset(0);
}

bool CMPHub::HandleFSCommand(const char* pCmd, const char* pArgs)
{
  EGsUiCommand cmd = KEY_BY_VALUE(string(pCmd),gUiCommands);

  for(int i=m_dialogs.size()-1;i>=0;--i)
  {
    if(m_dialogs[i]->OnCommand(cmd,pArgs))
    {
      return true;
    }
  }

  bool handled = true;

  switch(cmd)
  {
  case eGUC_opened:
    OnMenuOpened();
    break;
  case eGUC_register:
    m_reginfo = SRegisterInfo();
    break;
  case eGUC_registerNick:
    m_reginfo.nick = pArgs;
    break;
  case eGUC_registerEmail:
    m_reginfo.email = pArgs;
    break;
  case eGUC_registerDateDD:
    m_reginfo.day = atoi(pArgs);
    break;
  case eGUC_registerDateMM:
    m_reginfo.month = atoi(pArgs);
    break;
  case eGUC_registerDateYY:
    m_reginfo.year = atoi(pArgs);
    break;
	case eGUC_registerCountry:
		m_reginfo.country = pArgs;
		if(m_reginfo.country.size()>2)
			m_reginfo.country = "";
		break;
  case eGUC_registerEnd:
    {
      {
        INetworkService *serv = gEnv->pNetwork->GetService("GameSpy");
        if(!serv || serv->GetState()!= eNSS_Ok)
          break;
      }
      SFlashVarValue val("");
      m_currentScreen->GetVariable("_root.MPAccount_Password",&val);
      string pass = val.GetConstStrPtr();
      m_profile.reset(new CGameNetworkProfile(this));
			if(!m_profile->IsDead())
			{
				m_loggingIn = true;
				m_enteringLobby = true;
				ShowLoadingDlg("@ui_menu_register");
				m_profile->Register(m_reginfo.nick, m_reginfo.email, pass, m_reginfo.country, SRegisterDayOfBirth(m_reginfo.day,m_reginfo.month,m_reginfo.year));
			}
    }
    break;
  case eGUC_rememberPassword:
    m_options.remeber = atoi(pArgs)!=0;
		if(!m_options.remeber)
			m_options.autologin = false; 
		if(m_profile.get() && m_profile->IsLoggedIn() && m_options.remeber)
		{
			m_options.login = m_profile->GetLogin();
			m_options.password = m_profile->GetPassword();
		}
		SaveOptions();
    break;
  case eGUC_autoLogin:
    m_options.autologin = atoi(pArgs)!=0; 
		SaveOptions();
    break;
  case eGUC_login:
    {
      {
        INetworkService *serv = gEnv->pNetwork->GetService("GameSpy");
        if(!serv || serv->GetState()!= eNSS_Ok)
          break;
      }
      SFlashVarValue val("");
      m_currentScreen->GetVariable("_root.MPAccount_Password",&val);
      string pass = val.GetConstStrPtr();
      string login(pArgs);
      if(m_options.remeber || m_options.autologin)
      {
        m_options.login = login;
        m_options.password = pass;
      }
      DoLogin(login,pass);
    }
    break;
	case eGUC_accountInfo:
		{
			SFlashVarValue infoArgs[2] = {m_options.remeber, m_options.autologin};
			m_currentScreen->Invoke("showAccountInfo",infoArgs,2);
			if(m_profile.get() && m_profile->IsLoggedIn())
			{
				SUserStats stats = m_profile->GetMyStats();
				static string country;
				if(strlen(m_profile->GetCountry()))
				{
					country = "@ui_country_";
					country += m_profile->GetCountry();
				}
				else
					country = "";

				static string played, accuracy, kills, kpm;

				if(stats.m_played)
					played.Format("%d",stats.m_played/60);
				else
					played.resize(0);

				if(stats.m_accuracy)
					accuracy.Format("%.2f%%",stats.m_accuracy);
				else
					accuracy.resize(0);

				if(stats.m_kills)
					kills.Format("%d",stats.m_kills);
				else
					kills.resize(0);

				if(stats.m_killsPerMinute)
					kpm.Format("%.2f",stats.m_killsPerMinute);
				else
					kpm.resize(0);

				SFlashVarValue args[] = {	m_profile->GetLogin(),
																	country.c_str(),
																	played.c_str(),
																	stats.m_gameMode.c_str(),
																	stats.m_map.c_str(),
																	stats.m_weapon.c_str(),
																	stats.m_vehicle.c_str(),
																	stats.m_suitMode.c_str(),
																	accuracy.c_str(),
																	kpm.c_str(),
																	kills.c_str()};
				m_currentScreen->Invoke("setAccountInfo",args,sizeof(args)/sizeof(args[0]));
			}
		}
		break;
	case eGUC_disableAutoLogin:
		if(!strcmp(pArgs,"On"))
		{
			m_options.autologin = false;
		}
		else
		{
			m_options.autologin = true;
			if(m_profile.get() && m_profile->IsLoggedIn())
			{
				//just to be sure
				m_options.login = m_profile->GetLogin();
				m_options.password = m_profile->GetPassword();
			}
		}
		SaveOptions();
		break;
	case eGUC_logoff:
    DoLogoff();
    break;
  case eGUC_enterlobby:
		if(m_currentScreen)
		{
			m_menu.reset(0);
			m_menu.reset(new CMultiPlayerMenu(false,m_currentScreen,this));
			if(!IsIngame())
				m_lastMenu = 2;
		}
		break;
	case eGUC_leavelobby:
  case eGUC_leaveLANlobby:
		if(!IsIngame())
			m_lastMenu = 0;
    m_menu.reset(0);
    break;
  case eGUC_internetGame:
    {
      INetworkService *serv = gEnv->pNetwork->GetService("GameSpy");
      if(!serv || serv->GetState() == eNSS_Initializing)
        break;
			if(serv->GetState() == eNSS_Failed)
			{
				ShowError("Online support for Crysis Wars is no longer available.");
				break;
			}
			CheckTSPIPs();
			IPatchCheck* pc = serv->GetPatchCheck();
			if(pc->IsUpdateAvailable())
			{
				ShowYesNoDialog("@ui_patch_warning","patch");
				break;
			}
    }
		if(!m_profile.get() || !m_profile->IsLoggedIn())
    {
      TryLogin(true);
    }
    else
      SwitchToLobby();
    break;
  case eGUC_recordedGames:
		SAFE_MENU_FUNC(PlayTutorialVideo());
    break;
  case eGUC_enterLANlobby:
    {
      INetworkService *serv = gEnv->pNetwork->GetService("GameSpy");
      if(!serv || serv->GetState()!= eNSS_Ok)
        break;
    }
		if(!IsIngame())
			m_lastMenu = 3;

		if(m_currentScreen)
		{
			m_menu.reset(0);
			m_menu.reset(new CMultiPlayerMenu(true,m_currentScreen,this));
		}
    break;
  case eGUC_quickGame:
    OnQuickGame();
    break;
  case eGUC_back:
    if(m_quickGame.get())
    {
      m_quickGame->Cancel();
      m_quickGame.reset(0);
    }
    break;
	case eGUC_forgotPassword:
		//gEnv->pGame->GetIGameFramework()->ShowPageInBrowser("http://login.gamespy.com/lostpassword.aspx");
		if(m_currentScreen)
		{
			m_profile.reset(new CGameNetworkProfile(this));
			SFlashVarValue val("");
			m_currentScreen->GetVariable("_root.Root.MainMenu.ForgotPassword_POPUP_M.ForgotPassword_POPUP.Texts.Colorset.CA_EMAILADDY.text",&val);
			m_profile->RetrievePassword(val.GetConstStrPtr());
		}
		break;
  case eGUC_dialogClosed:
		if(m_profile.get() && m_profile->IsLoggingIn())
		{
			m_profile->Logoff();
			m_profile.reset(0);
		}
		else
			gEnv->pGame->GetIGameFramework()->ExecuteCommandNextFrame("disconnect");
    break;
  case eGUC_dialogYes:
    if(!strcmp(pArgs,"tutorial"))
    {
      g_pGame->GetIGameFramework()->ShowPageInBrowser("Power Struggle Tutorial.wmv");
    }
    else if(!strcmp(pArgs,"patch"))
    {
      INetworkService* gs = gEnv->pNetwork->GetService("GameSpy");
      if(gs)
      {
        IPatchCheck* pc = gs->GetPatchCheck();
        if(pc->IsUpdateAvailable())
        {
          g_pGame->GetIGameFramework()->ShowPageInBrowser(pc->GetPatchURL());
          g_pGame->GetIGameFramework()->ExecuteCommandNextFrame("quit");
        }
      }
    }
		else if(!strcmp(pArgs,"quickgame"))
		{
			gEnv->pConsole->ExecuteString("disconnect");
			OnQuickGame();
		}
		else
		{
			handled = false;
		}
    break;
	case eGUC_downloadErrorYes:
		if (!strcmp(pArgs, "download_notPresent") || (!strcmp(pArgs, "download_update")) || (!strcmp(pArgs, "download_Retry")))
		{
			// attempt to kick off the download here. NB same code used for 1st attempt and retries.
			MapDownloadBegin();
		}
		else if (!strcmp(pArgs, "download_cancel"))
		{
			CDownloadTask* pDT = g_pGame->GetDownloadTask();
			if(pDT)
				pDT->StopDownloadTask();
		}
		else if(!strcmp(pArgs, "cd_key_check_failed"))
		{
			ShowEnterCDKey();
		}
		else
		{
			handled = false;
		}
		break;
	case eGUC_downloadErrorNo:
		{
			if(!strcmp(pArgs, "download_cancel"))
			{
				// don't cancel the download, so reshow the box.
				SServerConnectionInfo* pInfo = g_pGame->GetIGameFramework()->GetStoredServerInfo();
				ShowMapDownload(pInfo ? pInfo->levelDownloadURL : "");
			}
			else if(!strcmp(pArgs, "cd_key_check_failed"))
			{
				// go back to MP menu
			}
			else
			{
				// this could be: 
				//	download_Update -	player doesn't want to update the map they have
				//	download_retry	-	player doesn't want to retry
				//	download_notPresent - player doesn't want to download

				// In all cases, clear server information and go to server list page
				g_pGame->GetIGameFramework()->ClearStoredServerInfo();
			}
		}
		break;
	case eGUC_downloadOK:
		{
			if(!strcmp(pArgs, "download_mapChanged"))
			{
				SServerConnectionInfo* pInfo = g_pGame->GetIGameFramework()->GetStoredServerInfo();
				if(pInfo)
				{
					ILevelInfo* pLevelInfo = g_pGame->GetIGameFramework()->GetILevelSystem()->GetLevelInfo(pInfo->levelName);
					MapDownloadPromptUser(pInfo->levelDownloadURL, pLevelInfo != NULL);
				}
			}
			else if(!strcmp(pArgs, "download_notPossible"))
			{
				g_pGame->GetIGameFramework()->ClearStoredServerInfo();
			}
			else if(!strcmp(pArgs, "cd_key_format_wrong"))
			{
				ShowEnterCDKey();
			}
		}
		break;
	case eGUC_mapDownloadCancel:
		{
			ShowLargeYesNoDialog(L"@md_msg7", "download_cancel");
		}
		break;
	case eGUC_enteredCDKey:
		{
			// pArgs will contain the key.
			SaveCDKey(pArgs);

			// if we were trying to log in, try again now
			if(m_enteringLobby)
				TryLogin(m_enteringLobby);
		}
		break;
  default:
    handled = false;
  }

  if(m_menu.get() && !handled)
  {
    handled = m_menu->HandleFSCommand(cmd,pArgs);
  }
  return handled;
}

void CMPHub::OnUIEvent(const SUIEvent& event)
{
  switch(event.event)
  {
  case eUIE_disconnect:
    if(int(eDC_NubDestroyed) == event.param)
    {
       if(!gEnv->bServer)
				 ShowError("@ui_menu_disconnect_ServerQuit");
    }
    else if(int(eDC_UserRequested) != event.param)
		{
			EDisconnectionCause reason = static_cast<EDisconnectionCause>(event.param);
			SServerConnectionInfo* pInfo = g_pGame->GetIGameFramework()->GetStoredServerInfo();
			if(pInfo && (reason == eDC_MapNotFound || reason == eDC_MapVersion))
			{
				// get the download URL from the stored information
				if(pInfo->levelDownloadURL.empty())
					DisconnectError(reason, false, event.descrpition);
				else
					MapDownloadPromptUser(pInfo->levelDownloadURL.c_str(), (reason == eDC_MapVersion));
			}
			else if(pInfo && reason == eDC_ServerMapChanged_NewOneNotFound)
			{
				ShowLargeError(L"@md_msg1", "download_mapChanged");
			}
			else
				DisconnectError(reason,false, event.descrpition);
		}
		CloseLoadingDlg();
    break;
  }

  if(m_menu.get())
    m_menu->OnUIEvent(event);

  for(int i=m_dialogs.size()-1;i>=0;--i)
  {
    m_dialogs[i]->OnUIEvent(event);
  }
}

void CMPHub::SetCurrentFlashScreen(IFlashPlayer* screen, bool ingame)
{
	if(m_currentScreen && !screen)
  {
		//workaround to determine if we just closed current screen
		if((m_currentIngameScreen == m_currentScreen && ingame)
			|| (m_currentStartScreen == m_currentScreen && !ingame))
		{
			OnUIEvent(SUIEvent(eUIE_destroy,ingame?0:1));
			for(int i=m_dialogs.size()-1;i>=0;--i)
				m_dialogs[i]->Close();
			m_menu.reset(0);
		}
  }

	if(ingame)
	{
		m_currentIngameScreen = screen;
	}
	else
	{
		m_currentStartScreen = screen;
	}

  m_menuOpened = false;
	m_currentScreen = screen?screen:(m_currentStartScreen?m_currentStartScreen:m_currentIngameScreen);
   
  if(m_currentScreen)
  {
    if(gEnv->bMultiplayer)
    {
      OnShowIngameMenu();
    }
  }
}

void CMPHub::ConnectFailed(EDisconnectionCause cause, const char * description)
{
  OnUIEvent(SUIEvent(eUIE_connectFailed,int(cause),description));
}

void CMPHub::OnLoginSuccess(const char* nick)
{
  m_loggingIn = false;
	CloseLoadingDlg();
  CloseLoginDlg();
	m_login = nick;
	SetLoginInfo(nick);
	SaveOptions();

	if(m_enteringLobby)
	{
    SwitchToLobby();
		m_enteringLobby = false;
	}
	if(m_searchingQuickGame)
	{
		OnQuickGame();
		m_searchingQuickGame = false;
	}
}

void CMPHub::OnLoginFailed(const char* reason)
{
  m_loggingIn = false;
  CloseLoadingDlg();
  m_profile.reset(0);
  ShowError(reason,true);
  m_options.autologin = false;
  m_options.remeber = false;
	m_options.password = "";
	SaveOptions();
  //ShowLoginDlg();
}

void CMPHub::TryLogin( bool lobby )
{
	ReadOptions();
	m_enteringLobby = lobby;
	m_searchingQuickGame = !lobby;

	// first check CD key is set. If not, pop up the box
	if(!gEnv->pNetwork->HaveCDKey())
	{
		ShowEnterCDKey();
		return;
	}

	if(m_options.autologin)
	{
		if(m_options.login.empty())
		{
			m_options.autologin = false;
			ShowLoginDlg();
		}
		else
		{
			DoLogin(m_options.login,m_options.password);
		}
	}
	else
		ShowLoginDlg();
}

void CMPHub::ShowLoginDlg()
{
  if(!m_currentScreen)
    return;
  SFlashVarValue params[] = {"1",m_options.remeber,m_options.autologin};
  m_currentScreen->Invoke("_root.Root.MainMenu.MultiPlayer.openLoginScreen",params,sizeof(params)/sizeof(params[0]));
  m_currentScreen->SetVariable("_root.Root.MainMenu.MultiPlayer.LoginScreen.Login_Controls.LoginStats.Colorset.Nickname.text",m_options.login.c_str());
  if(m_options.remeber)
    m_currentScreen->SetVariable("_root.Root.MainMenu.MultiPlayer.LoginScreen.Login_Controls.LoginStats.Colorset.Password.text",m_options.password.c_str());
	else
		m_currentScreen->SetVariable("_root.Root.MainMenu.MultiPlayer.LoginScreen.Login_Controls.LoginStats.Colorset.Password.text","");
	m_currentScreen->Invoke0("_root.Root.MainMenu.MultiPlayer.updateLoginScreen");
}

void CMPHub::CloseLoginDlg()
{
  if(m_currentScreen)
    m_currentScreen->Invoke1("_root.Root.MainMenu.MultiPlayer.openLoginScreen", false);
}

void CMPHub::SwitchToLobby()
{
  if(m_currentScreen)
  {
    m_currentScreen->Invoke1("_root.Root.MainMenu.MultiPlayer.MultiPlayer.gotoAndPlay", "internetgame");
		if(!IsIngame())
			m_lastMenu = 2;
  }
}

void CMPHub::ShowLoadingDlg(const char* message)
{
  if(m_currentScreen)
    m_currentScreen->Invoke1("showLOADING",true);
  //TODO : set header
  SetLoadingDlgText(message,true);
}

void CMPHub::ShowLoadingDlg(const char* message, const char* param)
{
	if(m_currentScreen)
		m_currentScreen->Invoke1("showLOADING",true);
	//TODO : set header
	SetLoadingDlgText(message, param);
}

void CMPHub::SetLoadingDlgText(const char* text, bool localize)
{
  SFlashVarValue args[]={text,localize};
  if(m_currentScreen)
    m_currentScreen->Invoke("setLOADINGText",args,sizeof(args)/sizeof(args[0]));
}

void CMPHub::SetLoadingDlgText(const char* fmt, const char* param)
{
	static wstring tmp, tmp2;
	gEnv->pSystem->GetLocalizationManager()->LocalizeLabel(fmt, tmp);
	StrToWstr(param,tmp2);
	static wstring text;
	text.resize(0);
	gEnv->pSystem->GetLocalizationManager()->FormatStringMessage(text,tmp,tmp2.c_str());

	SFlashVarValue args[]={text.c_str(),true};
	if(m_currentScreen)
		m_currentScreen->Invoke("setLOADINGText",args,sizeof(args)/sizeof(args[0]));
}

void CMPHub::CloseLoadingDlg()
{
  if(m_currentScreen)
    m_currentScreen->Invoke1("showLOADING",false);
}

void CMPHub::OnQuickGame()
{
  INetworkService *serv = gEnv->pNetwork->GetService("GameSpy");
  if(!serv || serv->GetState()!= eNSS_Ok)
    return;

	if(IsIngame())
	{
		ShowYesNoDialog("@ui_disconnect_warning","quickgame");
	}
	else
	{
		m_quickGame.reset(new CQuickGame());
		m_quickGame->StartSearch(this);
	}
}

void CMPHub::SetLoginInfo(const char* nick)
{
  if(!m_menuOpened || !m_currentScreen)
    return;
  if(nick)
  {
    m_currentScreen->Invoke0("GSConnect");
  }
  else
  {
    m_currentScreen->Invoke0("GSDisconnect");
  }
}

void ExpandToWChar(const char* charString, wstring& outString)
{
	outString.resize(strlen(charString));
	wchar_t* dst = outString.begin();
	const char* src = charString;
	while (const wchar_t c=(wchar_t)(*src++))
	{
		*dst++ = c;
	}
}

void CMPHub::DisconnectError(EDisconnectionCause dc, bool connecting, const char* serverMsg/*=NULL*/)
{
	const char* msg = VALUE_BY_KEY(dc,gDisconnectErrors);

	switch(dc)
	{
	case eDC_CDKeyChekFailed:
		{
			// cd key wasn't there, so the player must have entered it this session. Give them a chance to correct it.
			ShowLargeYesNoDialog(L"@ui_menu_disconnect_editCDKey", "cd_key_check_failed");
		}
		break;
	case eDC_AuthenticationFailed:
		ShowError(msg, true, 1);
		break;
	case eDC_NotLoggedIn:
		ShowError(msg, true, 4);
		break;
	case eDC_ModMismatch:
	{
		// localise the msg ourselves to add the information retrieved from the server...
		// parse the server msg to extract mod name and version
		// string is of the form "Remote disconnected: modname modversion"
		// so skip the first 21 characters (eurgh)	
		ILocalizationManager* pLoc = gEnv->pSystem->GetLocalizationManager();
		if(pLoc)
		{
			wstring final;
			if(strlen(serverMsg) > 21 && strncmp(serverMsg + 21, "None", 4) != 0)
			{
				wstring localised, tmp;
				ExpandToWChar(serverMsg + 21, tmp);
				pLoc->LocalizeLabel(msg, localised);
				pLoc->FormatStringMessage(final, localised, tmp);
			}
			else
			{
				// different message if the server isn't running a mod
				pLoc->LocalizeLabel("@ui_menu_disconnect_Mod2", final);
			}

			ShowErrorText(final);
		}
		break;
	}
	case eDC_MapNotFound:
		{
			// localise the msg ourselves to add the information retrieved from the server...
			ILocalizationManager* pLoc = gEnv->pSystem->GetLocalizationManager();
			if(pLoc)
			{
				wstring final;
				wstring localised, tmp;
				ExpandToWChar(serverMsg, tmp);
				pLoc->LocalizeLabel(msg, localised);
				pLoc->FormatStringMessage(final, localised, tmp);

				ShowErrorText(final);
			}
			break;
		}
	default:
		ShowError(msg, true);
	}
}

void CMPHub::ShowError(const char* msg, bool translate, int code)
{
	if(code && translate)
	{
		static wstring tmp, tmp2;
		gEnv->pSystem->GetLocalizationManager()->LocalizeLabel(msg, tmp);
		tmp2.Format(L" (%d)", code);
		tmp += tmp2;

		ShowErrorText(tmp);
		return;
	}

	if(!m_currentScreen)
	{
		static wstring tmp;
		gEnv->pSystem->GetLocalizationManager()->LocalizeLabel(msg, tmp);
		m_errorText = tmp;//will be shown next time
		return;
	}
	if(translate)
		m_currentScreen->Invoke1("setErrorText",msg);
	else
		m_currentScreen->Invoke1("setErrorTextNonLocalized",msg);
	m_currentScreen->Invoke1("showErrorMessage","Box1");
	m_errorText.resize(0);
}

void CMPHub::ShowErrorText(const wchar_t* msg)
{
	if(!m_currentScreen)
	{
		m_errorText = msg;//will be shown next time
		return;
	}
	m_currentScreen->Invoke1("setErrorText",msg);
	m_currentScreen->Invoke1("showErrorMessage","Box1");
	m_errorText.resize(0);
}

void CMPHub::DoLogin(const char* nick, const char* pwd)
{
	if(!nick || !*nick)
	{
		ShowError("@ui_Enter_Login", true);
		return;
	}
	m_profile.reset(new CGameNetworkProfile(this));
	if(!m_profile->IsDead())
	{
		ShowLoadingDlg("@ui_menu_login");
		m_loggingIn = true;
		m_profile->Login(nick,pwd);
	}
}

void CMPHub::DoLoginProfile(const char* email, const char* pwd, const char* profile)
{
	m_profile.reset(new CGameNetworkProfile(this));
	if(!m_profile->IsDead())
	{
		ShowLoadingDlg("@ui_menu_login");
		m_loggingIn = true;
		m_profile->LoginProfile(email,pwd,profile);
	}
}

void CMPHub::DoLogoff()
{
  if(!m_profile.get())
    return;
  m_login.resize(0);
  m_profile->Logoff();
  m_profile.reset(0);
  SetLoginInfo(0);
  if(m_menu.get())
    SwitchToMainScreen();
	m_menu.reset(0);
	if(m_lastMenu == 2)
		m_lastMenu = 0;
	if(IsIngame() && gEnv->bMultiplayer)
	{
		g_pGame->GetIGameFramework()->ExecuteCommandNextFrame("disconnect");
	}
}

void CMPHub::SwitchToMainScreen()
{
  if(m_currentScreen)
	{
		m_currentScreen->Invoke0("closeMultiplayerMenu");
	}
}

static const char * hexchars = "0123456789abcdef";
static const char xor_code[16] = {17,		36,		-75,	-13,
																	120,	42,		23,		16,
																	-46,	11,		3,		67,
																	-41,	-19,	-64,	-8};//some random mask

static ILINE string EncodeStr(const char * x, int len)
{
	string out;
	int i=0;
	for (; i<len; i++)
	{
		uint8 c = x[i]^xor_code[i&15];
		out += hexchars[c >> 4];
		out += hexchars[c & 0xf];
	}

	//zero
	uint8 c = xor_code[i&15];
	out += hexchars[c >> 4];
	out += hexchars[c & 0xf];
	++i;
	//padding to some length, so they always 
	for(; i<32; i++)
	{
		uint8 c = uint8((rand()%0xFE)+1)^xor_code[i&15];
		out += hexchars[c >> 4];
		out += hexchars[c & 0xf];
	}
	assert(out.size()>=64);
	return out;
}

static ILINE bool DecodeStr(string& x)
{
	string out;
	uint8 cur;
	if(x.length()<64)
		return false;
	for (int i=0; i<x.length(); i++)
	{
		int j;
		for (j=0; hexchars[j]; j++)
			if (hexchars[j] == x[i])
				break;
		if (!hexchars[j])
			return false;
		cur = (cur << 4) | j;
		if (i&1)
		{
			uint8 c = cur ^ xor_code[(i>>1)&15];
			if(!c)
				break;
			out += c;
		}
	}
	x.swap(out);
	return true;
}

void CMPHub::ReadOptions()
{
  m_options.autologin = false;
  m_options.remeber = false;
  g_pGame->GetOptions()->GetProfileValue("Multiplayer.Login.AutoLogin",m_options.autologin);
  g_pGame->GetOptions()->GetProfileValue("Multiplayer.Login.RememberPassword",m_options.remeber);
  g_pGame->GetOptions()->GetProfileValue("Multiplayer.Login.Login",m_options.login);
	g_pGame->GetOptions()->GetProfileValue("Multiplayer.Login.Password",m_options.password);
	if(!DecodeStr(m_options.password))
	{
		if(m_options.password.size()>20)//it can be old-format password so we'll keep it
		{
			m_options.password = "";
			m_options.remeber = false;
			m_options.autologin = false;
		}
	}
}

void CMPHub::SaveOptions()
{
  g_pGame->GetOptions()->SaveValueToProfile("Multiplayer.Login.AutoLogin",m_options.autologin);
  g_pGame->GetOptions()->SaveValueToProfile("Multiplayer.Login.RememberPassword",m_options.remeber);
  g_pGame->GetOptions()->SaveValueToProfile("Multiplayer.Login.Login",m_options.login);
	string pwd = EncodeStr(m_options.password,m_options.password.size());	
  g_pGame->GetOptions()->SaveValueToProfile("Multiplayer.Login.Password",pwd);
	g_pGame->GetOptions()->SaveProfile();
}

bool CMPHub::IsLoggingIn()const
{
  return m_loggingIn;
}

struct STSPDownload: public IDownloadStream
{
	STSPDownload():m_complete(false),m_ok(false)
	{
	}

	virtual void GotData( const uint8 * pData, uint32 length )
	{
		m_data.reserve(m_data.size() + length);
		m_data.insert(m_data.end(), pData, pData + length);
	}

	virtual void Complete( bool success )
	{
		CryAutoLock<CryFastLock> lock(m_lock);
		m_complete = true;
		m_ok = success;
		if(m_ok)
		{
			FILE* m_file = gEnv->pCryPak->FOpen(gTSPListFileFullName, "wb");
			gEnv->pCryPak->FWrite( &m_data[0], m_data.size(), m_file);
			gEnv->pCryPak->FClose(m_file);
		}
		m_data.clear();
	}

	bool IsCompleted()
	{
		CryAutoLock<CryFastLock> lock(m_lock);

		return m_complete;
	}

	void StartDownload()
	{
		INetworkService* gs = gEnv->pNetwork->GetService("GameSpy");
		if(gs)
		{
			IFileDownloader* down = gs->GetFileDownloader();
			SFileDownloadParameters params;
			params.sourceFilename = gTSPListFileURL;
			params.pStream = this;
			down->SetThrottleParameters(0,0);
			down->DownloadFile(params);
		}
	}

	CryFastLock m_lock;
	bool	m_ok;
	bool  m_complete;
	std::vector<uint8> m_data;
};

static bool GameSpyCheck()
{
	INetworkService* gs = gEnv->pNetwork->GetService("GameSpy");
	return gs->GetState() != eNSS_Initializing;
}
 
void CMPHub::OnMenuOpened()
{
	INetworkService* gs = gEnv->pNetwork->GetService("GameSpy");
	if(gs)
	{
		if(gs->GetState() == eNSS_Initializing)
			g_pGame->BlockingProcess(&GameSpyCheck);
		if(gs->GetState() == eNSS_Ok)
		{
			IPatchCheck* pc = gs->GetPatchCheck();
			pc->TrackUsage();
			pc->CheckForUpdate();
			if(!m_trustedDownload.get())
			{
				m_trustedDownload.reset(new STSPDownload());
				m_trustedDownload->StartDownload();
			}
		}
	}

	m_menuOpened = true;
	if(!m_login.empty())
		SetLoginInfo(m_login);
	if(!m_errorText.empty())
	{
		ShowErrorText(m_errorText.c_str());
	}
	else if(!m_yesNoText.empty())
	{
		ShowLargeYesNoDialog(m_yesNoText.c_str(), m_yesNoName.c_str());
	}
	else if(!m_errorTextLarge.empty())
	{
		ShowLargeError(m_errorTextLarge.c_str(), m_errorNameLarge.c_str());
	}
}

void CMPHub::OnShowIngameMenu()
{
  if(!m_currentScreen)
    return;
  m_currentScreen->SetVariable("MainWindow",2);
  if(m_lastMenu)
    m_currentScreen->SetVariable("SubWindow",m_lastMenu);
}


bool CMPHub::IsIngame()const
{
  return gEnv->pGame->GetIGameFramework()->IsGameStarted();
}

void CMPHub::ShowYesNoDialog(const char* str, const char* name)
{
	if(!m_currentScreen)
		return;
  SFlashVarValue args[]={"Box2",name};
  m_currentScreen->Invoke("showErrorMessage",args,sizeof(args)/sizeof(args[0]));
  m_currentScreen->Invoke1("setErrorText",str);
}

void CMPHub::CloseYesNoDialog()
{
	if(!m_currentScreen)
		return;
	m_currentScreen->Invoke0("closeErrorMessageYesNo");
}

CGameNetworkProfile* CMPHub::GetProfile()const
{
  return m_profile.get();
}

void CMPHub::AddGameModToList(const char* mod)
{
  if(m_currentScreen)
  {
    //_root.Root.MainMenu.MultiPlayer.ClearGameModeList() - clear
    m_currentScreen->Invoke1("_root.Root.MainMenu.MultiPlayer.AddGameMode",mod);
  }
}

CMPHub::CDialog::CDialog():
m_hub(0)
{
}

CMPHub::CDialog::~CDialog()
{
  Close();
}

void CMPHub::CDialog::Show(CMPHub* hub)
{
  m_hub = hub;
  m_hub->m_dialogs.push_back(this);
  //show in UI
  OnShow();
}

void CMPHub::CDialog::Close()
{
  if(!m_hub)//m_hub !=0 
    return;
  OnClose();
  //hide in UI
  assert(m_hub->m_dialogs.back() == this);
  m_hub->m_dialogs.pop_back();
  m_hub = 0;
}

bool CMPHub::CDialog::OnCommand(EGsUiCommand cmd, const char* pArgs)
{
  return false;
}

void CMPHub::CDialog::OnUIEvent(const SUIEvent& event)
{

}

void CMPHub::CDialog::OnClose()
{

}

void CMPHub::CDialog::OnShow()
{

}

bool CMPHub::IsInLobby() const
{
	return m_menu.get() != 0;
}

bool CMPHub::IsInLogin() const
{
	return m_isInLogin;
}

void CMPHub::SetIsInLogin(bool isInLogin)
{
	m_isInLogin = isInLogin;
}

void CMPHub::ShowRetrivePasswordResult(bool ok)
{
	if(ok)
	{
		if(m_currentScreen)
			m_currentScreen->Invoke1("_root.showEmailSendMessage","@ui_menu_EmailWasSend");
	}
	else
	{
		ShowError("@ui_menu_EmailWasNotSend");
	}
}

struct STrustedIPCompare
{
	bool operator()(const STrustedIp& a, const STrustedIp& b)const
	{
		bool r = a.lower < b.lower;
		assert((a.upper < b.upper) == r);
		return r;
	}

	bool operator()(const STrustedIp& a, const uint32& b)const
	{
		return a.upper < b;
	}
};

bool CMPHub::IsIpTrusted(uint32 ip_)const
{
	if(!m_trustedIPsLoaded)
	{
		return false;
	}

	uint32 ip = ((ip_&0xFF)<<24) + ((ip_&0xFF00)<<8) + ((ip_&0xFF0000)>>8) + (ip_>>24);


	std::vector<STrustedIp>::const_iterator it = std::lower_bound(m_trustedIPs.begin(), m_trustedIPs.end(), ip, STrustedIPCompare());
	while(it != m_trustedIPs.end() && it->lower < ip)
	{
		if( ip >= it->lower && ip <= it->upper)
			return true;
		++it;
	}
	return false;
}

bool CMPHub::LoadTrustedIPs()
{
	XmlNodeRef root = gEnv->pSystem->LoadXmlFile(gTSPListFileFullName);
	if(!root)
	{
		root = gEnv->pSystem->LoadXmlFile("Libs\\config\\defaultTSP.xml");
	}

	if(!root || !root->isTag("i"))
		return false;
	int num = 0;
	if(!root->getAttr("e", num))
		return false;
	for(int i=0; i<root->getChildCount(); ++i)
	{
		XmlNodeRef ch = root->getChild(i);
		if(ch->isTag("a"))
		{
			CryFixedStringT<32> ip_str = ch->getAttr("r");
			//CryLog("IP %s", ip_str.c_str());
			STrustedIp ip;
			CryFixedStringT<32>::const_iterator p = ip_str.begin();
			bool failed = false;
			int pos = 0;
			while(p != ip_str.end() && !failed)
			{
				CryFixedStringT<16> ip_digit;
				for(;p!=ip_str.end() && *p != '.'; ++p)
				{
					if(*p != '-' && !isdigit(*p))
					{
						GameWarning("TSP IP list contains invalid character : \'%s\'", ip_str.c_str());
						failed = true;
						break;
					}
					ip_digit += *p;
				}
				if(failed)
					break;
				uint low = 0, up = 0;
				if(const char* minus_p = strchr(ip_digit.c_str(),'-'))
				{
					CryFixedStringT<16> lower(ip_digit.c_str(), minus_p);
					CryFixedStringT<16> upper(minus_p+1);
					low = atoi(lower);
					up = atoi(upper);
				}
				else
				{
					low = up = atoi(ip_digit);
				}
				if(low>255 || up >255 || up<low)
				{
					GameWarning("TSP IP list contains invalid ip address : \'%s\'", ip_str.c_str());
					failed = true;
					break;
				}

				ip.lower = (ip.lower<<8) + low;
				ip.upper = (ip.upper<<8) + up;
				if(p != ip_str.end())
					++p;
				++pos;
			}
			if(!failed)
				m_trustedIPs.push_back(ip);
		}
		else
		{
			GameWarning("TSP list contains bad element \'%s\'", ch->getTag());
		}
	}

	if(m_trustedIPs.size() != num)
	{
		GameWarning("TSP list contains wrong number of elements. Declared - %d, read - %d.", num, m_trustedIPs.size());
	}
	std::sort(m_trustedIPs.begin(),m_trustedIPs.end(), STrustedIPCompare());
	/*for(int i=0; i<m_trustedIPs.size(); ++i)
	{
	CryLog("IP read: %X - %X", m_trustedIPs[i].lower, m_trustedIPs[i].upper);
	}*/
	return true;
}

void CMPHub::CheckTSPIPs()
{
	if(!m_trustedIPsLoaded)
	{
		if(m_trustedDownload.get() && m_trustedDownload->IsCompleted())
		{
			m_trustedIPsLoaded = LoadTrustedIPs();
		}
	}
}

void CMPHub::ShowLargeYesNoDialog(const wchar_t* str, const char* name)
{
	if(!m_currentScreen)
	{
		// shown next time
		m_yesNoName = name;
		m_yesNoText = str;
		return;
	}
	SFlashVarValue args[]={str};
	m_currentScreen->Invoke("setErrorText",args,sizeof(args)/sizeof(args[0]));
	m_currentScreen->Invoke1("showErrorMessageYesNoDL",name);
	m_yesNoText.resize(0);
	m_yesNoName.resize(0);
}

void CMPHub::ShowLargeError(const wchar_t* msg, const char* name)
{
	if(!m_currentScreen)
	{
		m_errorTextLarge = msg;//will be shown next time
		m_errorNameLarge = name;
		return;
	}
	SFlashVarValue args[] = {msg};
	m_currentScreen->Invoke1("showErrorMessageOK_Big",name);
	m_currentScreen->Invoke("setErrorText", args, sizeof(args)/sizeof(args[0]));
	m_errorTextLarge.resize(0);
	m_errorNameLarge.resize(0);
}

void CMPHub::ShowMapDownload(const char* str)
{
	if(m_currentScreen)
	{
		SFlashVarValue args[] = {str, true};
		m_currentScreen->Invoke("showDownloadMap", args, 2);
	}
	SetMapDownloadProgress(0);
}

void CMPHub::CloseMapDownload()
{
	if(m_currentScreen)
	{
		SFlashVarValue args[] = { "text2show", false };
		m_currentScreen->Invoke("showDownloadMap", args, 2);
	}
}

void CMPHub::SetMapDownloadProgress(int percentage)
{
	if(m_currentScreen)
		m_currentScreen->Invoke1("setMapDownloadStatusBar",percentage);
}

void CMPHub::MapDownloadPromptUser(const char* url, bool levelPresent)
{
	bool canDownload = (url != NULL) && (url[0] != 0) && (url[0] != '0');
	ILocalizationManager* pLocMan = gEnv->pSystem->GetLocalizationManager();
	SServerConnectionInfo* pInfo = g_pGame->GetIGameFramework()->GetStoredServerInfo();
	if(!pLocMan)
	{
		CryLog("Can't localise text");
		return;
	}
	if(!pInfo)
	{
		CryLog("no stored server info found");
		return;
	}

	wstring final, error, mapName;
	ExpandToWChar(pInfo->levelName, mapName);

	if(canDownload)
	{
		m_downloadURL = url;
		if(!levelPresent)
		{
			// don't already have this map. Ask whether to download it.
			pLocMan->LocalizeLabel("@md_msg5", error);
			pLocMan->FormatStringMessage(final, error, mapName);
			ShowLargeYesNoDialog(final.c_str(), "download_notPresent");
		}
		else
		{
			// already have the map, but wrong version. Ask whether to update it.
			pLocMan->LocalizeLabel("@md_msg2", error);
			pLocMan->FormatStringMessage(final, error, mapName);
			ShowLargeYesNoDialog(final.c_str(), "download_update");
		}
	}
	else
	{
		if(!levelPresent)
		{
			// level not found, and we don't have a URL to download from.
			pLocMan->LocalizeLabel("@md_msg4", error);
			pLocMan->FormatStringMessage(final, error, mapName);
			ShowLargeError(final.c_str(), "download_notPossible");
		}
		else
		{
			// level found, but wrong version, and we don't have a URL to download from.
			pLocMan->LocalizeLabel("@md_msg3", error);
			pLocMan->FormatStringMessage(final, error, mapName);
			ShowLargeError(final.c_str(), "download_notPossible");
		}
	}
}

void CMPHub::MapDownloadBegin()
{
	if(!m_downloadURL.empty())
	{
		SFileDownloadParameters dl;
		dl.destFilename = "download.zip";
		dl.destPath = "";	
		dl.sourceFilename = m_downloadURL;
		//dl.md5 = nothing. Can't check the supplied md5 until we have unpacked the zip.

		// NB show this *before* starting download: some errors are immediate and hide the dialog
		ShowMapDownload(m_downloadURL);
		SetMapDownloadProgress(0);

		CDownloadTask* pDT = g_pGame->GetDownloadTask();
		if(pDT)
			pDT->StartMapDownload(dl, 1, this);
	}
	else
		assert(false);
}


void CMPHub::OnDownloadProgress(float percent)
{
	CryLog("Progress %f", percent);
	SetMapDownloadProgress((int)(percent * 100));
}

void CMPHub::OnDownloadFinished(int result, const char* fileName)
{
	CryLog("Download finished: %d", result);

	CloseMapDownload();

	ILocalizationManager* pLocMan = gEnv->pSystem->GetLocalizationManager();
	if(!pLocMan)
	{
		CryLog("Can't localise strings!");
		return;
	}
	wstring error, subError, final;
	bool retry = true;

	switch(result)
	{
		// success
	case eDS_Done:
		{
			// unpack zip file here
			ICryPak* pPak = gEnv->pSystem->GetIPak();
			if(pPak)
			{
				int ok = pPak->ExtractPack(fileName);
				if(ok == ENOSPC)
				{
					ShowLargeError(L"@md_msg10", "download_diskSpace");
				}
				else if(ok != 1)
				{
					pLocMan->LocalizeLabel("@md_specific12", subError);
					// error is triggered below
				}
				else
				{
					CryLog("Zip file extracted successfully");

					// delete the file we've just downloaded
					ok = pPak->RemoveFile(fileName);
					CryLog("Zip file %s", ok ? "removed" : "NOT removed");

					// rescan the level folder to add new level
					ILevelSystem* pLevelSystem = g_pGame->GetIGameFramework()->GetILevelSystem();
					if(pLevelSystem)
					{
						pLevelSystem->Rescan(0);

						// use the stored server info to try and connect again
						SServerConnectionInfo* pInfo = g_pGame->GetIGameFramework()->GetStoredServerInfo();
						if(pInfo && !pInfo->serverAddr.empty())
						{
							string connect = "connect ";
							connect += pInfo->serverAddr;
							connect += " ";
							connect += pInfo->serverPort;
							g_pGame->GetIGameFramework()->ExecuteCommandNextFrame(connect.c_str());
							ShowLoadingDlg("@ui_connecting_to", pInfo->serverAddr);
						}
						else
						{
							// don't have a server address.
							//	Not a lot we can do here.
							CryLog("Can't reconnect to the server: no connection info");
						}
					}
				}
			}
		}
		break;

	// non retryable errors. Any?
	//case eDS_Error:
	//	retry = false;
	//	break;

		// special case - do nothing
	case eFDE_RequestCancelled:
		//ShowErrorText(L"Download cancelled"); // not necessary
		break;

		// retryable errors
	case eFDE_ParseURLFailed:        // There was an error parsing the URL.
		pLocMan->LocalizeLabel("@md_specific1", subError);
		break;

	case eFDE_HostLookupFailed:      // Failed looking up the hostname.
		pLocMan->LocalizeLabel("@md_specific2", subError);
		break;

	case eFDE_SocketFailed:          // Failed to create/initialize/read/write a socket.
	case eFDE_ConnectFailed:         // Failed connecting to the http server.
		pLocMan->LocalizeLabel("@md_specific3", subError);
		break;

	case eFDE_BadResponse:           // Error understanding a response from the server.
		pLocMan->LocalizeLabel("@md_specific4", subError);
		break;

	case eFDE_RequestRejected:       // The request has been rejected by the server.
	case eFDE_Unauthorized:          // Not authorized to get the file.
	case eFDE_Forbidden:             // The server has refused to send the file.
		pLocMan->LocalizeLabel("@md_specific5", subError);
		break;

	case eFDE_FileNotFound:          // Failed to find the file on the server.
		pLocMan->LocalizeLabel("@md_specific6", subError);
		break;

	case eFDE_ServerError:           // The server has encountered an internal error.
		pLocMan->LocalizeLabel("@md_specific7", subError);
		break;

	case eFDE_FileWriteFailed:       // An error occured writing to the local file 
		pLocMan->LocalizeLabel("@md_specific8", subError);
		break;

	case eFDE_FileIncomplete:        // Download started but was interrupted.  Only reported if file size is known.
		pLocMan->LocalizeLabel("@md_specific9", subError);
		break;

	case eFDE_OutOfMemory:           // A memory allocation failed.
	case eFDE_BufferOverflow:        // The user-supplied buffer was too small to hold the file.
	case eFDE_FileTooBig:            // The file is to big to be downloaded (size exceeds range of interal data types)
	case eFDE_EncryptionError:       // Error with encryption engine.
		pLocMan->LocalizeLabel("@md_specific10", subError);
		break;

	case eDS_DiskFull:
		pLocMan->LocalizeLabel("@md_specific11", subError);
		break;

	case eDS_Error_FileNotFound:
	case eDS_Error_Checksum:
		pLocMan->LocalizeLabel("@md_specific12", subError);
		break;

	// shouldn't occur
	case eFDE_NoError:							// Successfully retrieved file OR still in progress
	case eDS_None:
	case eDS_Downloading:
	default:
		assert(false);
		break;
	}

	// if there was an error to report, do so now.
	if(!subError.empty())
	{
		if(retry)
			pLocMan->LocalizeLabel("@md_msg9", error);
		else
			pLocMan->LocalizeLabel("@md_msg8", error);

		pLocMan->FormatStringMessage(final, error, subError.c_str());
		ShowLargeYesNoDialog(final.c_str(), "download_Retry");
	}

	// if unsuccessful, clear the server info so we retry from start next time.
	if(result != eDS_Done)
	{
		CryLog("Clearing server info");
		g_pGame->GetIGameFramework()->ClearStoredServerInfo();
	}
}

void CMPHub::ShowEnterCDKey()
{
	if(m_currentScreen)
	{
		string prevKey = gEnv->pNetwork->GetCDKey();

		if(prevKey.length() == 20)
		{
			string subStr1 = prevKey.substr(0,4).c_str();
			string subStr2 = prevKey.substr(4,4).c_str();
			string subStr3 = prevKey.substr(8,4).c_str();
			string subStr4 = prevKey.substr(12,4).c_str();
			string subStr5 = prevKey.substr(16, 4).c_str();
			SFlashVarValue args[] = {subStr1.c_str(), subStr2.c_str(), subStr3.c_str(), subStr4.c_str(), subStr5.c_str()};
			m_currentScreen->Invoke("showEnterCDKey", args, sizeof(args) / sizeof(args[0]));
		}
		else
		{
			SFlashVarValue args[] = {"", "", "", "", ""};
			m_currentScreen->Invoke("showEnterCDKey", args, sizeof(args) / sizeof(args[0]));
		}
	}
}

void CMPHub::SaveCDKey(const char* cdKey)
{
	string cdKeyString = cdKey;
	cdKeyString.replace("-", "");	// since flash sends xxxx-xxxx-xxxx-xxxx-xxxx
	cdKeyString.MakeUpper();
	
	if(cdKeyString.length() == 20)
	{
		gEnv->pNetwork->SetCDKey(cdKeyString.c_str());

		g_pGame->GetIGameFramework()->SaveCDKey(cdKeyString.c_str());
	}
	else
	{
		// invalid length key.
		ShowLargeError(L"@ui_menu_CDKEY_WRONG", "cd_key_format_wrong");
	}
}