
#include <CryModuleDefs.h>
#define eCryModule eCryM_System

#include "ResourceCompilerHelper.h"




#if defined(WIN32) || defined(WIN64)

bool CResourceCompilerHelper::SetDataToRegistry()
{
	HKEY  hKey;
	DWORD size = 512;

	bool bRet=true;

	char szSubKey[512];

	sprintf(szSubKey,"Software\\Crytek\\%s","Polybump");		// Appname is always Polybump

	// Create and open key and subkey.
	LONG lResult = RegCreateKeyEx(HKEY_CURRENT_USER,szSubKey,0,NULL,REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS, NULL, &hKey, NULL) ;

	if(ERROR_SUCCESS != lResult)
		return false;

	{
		lResult = RegSetValueEx(hKey,"Bin32Path", 0, REG_SZ, (BYTE *)m_sBin32Path.c_str(), (DWORD)strlen(m_sBin32Path.c_str())+1) ;
		if( ERROR_SUCCESS != lResult )
			bRet=false;
	}

	{
		DWORD dwVal = m_bShowWindow?1:0;
		lResult = RegSetValueEx(hKey,"ShowWindow", 0, REG_DWORD, (BYTE *)&dwVal, sizeof(dwVal)) ;
		if( ERROR_SUCCESS != lResult )
			bRet=false;
	}

	{
		DWORD dwVal = m_bHideCustom?1:0;
		lResult = RegSetValueEx(hKey,"HideCustom", 0, REG_DWORD, (BYTE *)&dwVal, sizeof(dwVal)) ;
		if( ERROR_SUCCESS != lResult )
			bRet=false;
	}

	RegCloseKey( hKey );

	return bRet;
}

CResourceCompilerHelper::CResourceCompilerHelper()
	:m_bErrorFlag(false), m_bHideCustom(false), m_bShowWindow(false)
{
	GetDataFromRegistry();
}


static bool g_bWindowQuit;
static CResourceCompilerHelper *g_pThis=0;
static const uint32 IDC_hWndRCPath	= 100;
static const uint32 IDC_hWndPickRCPath	=	101;
static const uint32 IDC_hWndTest	=	102;

//-----------------------------------------------------------------------------
// Name: WndProc()
// Desc: Static msg handler which passes messages to the application class.
//-----------------------------------------------------------------------------
LRESULT static CALLBACK WndProc( HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam )
{ 
	assert(g_pThis);

	if (uMsg == WM_INITDIALOG) 
	{
		int f=0;
  }

	switch(uMsg)
	{
		case WM_CREATE:
			break;

		case WM_COMMAND:
			switch(LOWORD(wParam))
			{
/*				case IDC_hWndPickRCPath:
					{
						BROWSEINFO bi;

						CoInitializeEx(0,COINIT_MULTITHREADED);

						char buffer[MAX_PATH];

						strcpy(buffer,"");

						memset(&bi,0,sizeof(BROWSEINFO));
						bi.ulFlags=BIF_BROWSEINCLUDEFILES|BIF_USENEWUI|BIF_NONEWFOLDERBUTTON|BIF_RETURNONLYFSDIRS;
						bi.lpszTitle="Choose the RC.exe directory";
						bi.pszDisplayName=buffer;
						SHBrowseForFolder(&bi);
					}
					break;
*/
				case IDC_hWndTest:
					{
						HWND hItemWnd = GetDlgItem(hWnd,IDC_hWndRCPath);

						string sOldPath;
						char szPath[MAX_PATH];

						GetWindowText(hItemWnd,szPath,MAX_PATH);
						g_pThis->SetBin32Path(szPath);
						if(g_pThis->CallResourceCompiler())
							MessageBox(hWnd,"rc/rc.exe found","ResourceCompiler",MB_OK);
					}
					break;
		
				case IDOK:
					{
						HWND hItemWnd = GetDlgItem(hWnd,IDC_hWndRCPath);

						char szPath[MAX_PATH];

						GetWindowText(hItemWnd,szPath,MAX_PATH);
						g_pThis->SetBin32Path(szPath);
						g_pThis->SetDataToRegistry();
					}
				case IDCANCEL:
					g_bWindowQuit=true;
					break;
			}
			break;

		case WM_CLOSE:
			g_bWindowQuit=true;
			break;
	}

  return DefWindowProc( hWnd, uMsg, wParam, lParam );
}


void CResourceCompilerHelper::ResourceCompilerUI( HWND hParent )
{
	g_bWindowQuit=false;
	g_pThis=this;

	const char *szWindowClass = "RESOURCECOMPILERUI";

  // Register the window class
  WNDCLASS wndClass = { 0, WndProc, 0, 
						DLGWINDOWEXTRA,		// DLGWINDOWEXTRA is needed for windows dialogs
						GetModuleHandle(0),
                        /*LoadIcon( dat.m_hInst, MAKEINTRESOURCE(IDI_MAIN_ICON) )*/NULL,
                        LoadCursor( NULL/*dat.m_hInst*/, IDC_ARROW ), 
												(HBRUSH)(::GetSysColorBrush(COLOR_BTNFACE)),
                        NULL, szWindowClass };

	RegisterClass(&wndClass);

	bool bReenableParent=false;

	if(IsWindowEnabled(hParent))
	{
		bReenableParent=true;
		EnableWindow(hParent,false);
	}

	// Create the window
	HWND hDialogWnd = CreateWindowEx( WS_EX_TOOLWINDOW|WS_EX_CONTROLPARENT,szWindowClass,"ResourceCompiler Settings",WS_BORDER|WS_CAPTION|WS_SYSMENU|WS_VISIBLE, 
		CW_USEDEFAULT,CW_USEDEFAULT,
		750+2*GetSystemMetrics(SM_CYFIXEDFRAME),
		84+2*GetSystemMetrics(SM_CYFIXEDFRAME)+GetSystemMetrics(SM_CYSMCAPTION),
		hParent,NULL,GetModuleHandle(0),NULL);

	// ------------------------------------------

	GetDataFromRegistry();

	HWND hStat0 = CreateWindowEx(WS_EX_TRANSPARENT,"STATIC","Bin32 Path (e.g. c:/MasterCD/Bin32):", WS_CHILD | WS_VISIBLE,
    10,10,590,16,
	  hDialogWnd, 0/*IDC_*/,GetModuleHandle(0), NULL);

	HWND hWndRCPath = CreateWindowEx(WS_EX_CLIENTEDGE,"EDIT",m_sBin32Path.c_str(), WS_CHILD | WS_VISIBLE | ES_AUTOHSCROLL | ES_LEFT | WS_TABSTOP,
    10,26,590+30,22,
	  hDialogWnd,(HMENU)IDC_hWndRCPath,GetModuleHandle(0), NULL);

//	HWND hWndPickRCPath = CreateWindow("BUTTON","...", WS_CHILD | WS_VISIBLE | ES_LEFT | WS_TABSTOP,
//    600,26+5,30,22,
//	  hDialogWnd,(HMENU)IDC_hWndPickRCPath,GetModuleHandle(0), NULL);

	HWND hWndTest = CreateWindow("BUTTON","Test", WS_CHILD | WS_VISIBLE | ES_LEFT | WS_TABSTOP,
    10,30+26,60,22,
	  hDialogWnd,(HMENU)IDC_hWndTest,GetModuleHandle(0), NULL);

	HWND hWndOK = CreateWindow("BUTTON","OK", WS_CHILD | BS_DEFPUSHBUTTON | WS_CHILD | WS_VISIBLE | ES_LEFT | WS_TABSTOP,
    665,16,70,22,
	  hDialogWnd,(HMENU)IDOK,GetModuleHandle(0), NULL);

	HWND hWndCancel = CreateWindow("BUTTON","Cancel", WS_CHILD | WS_CHILD | WS_VISIBLE | ES_LEFT | WS_TABSTOP,
    665,46,70,22,
	  hDialogWnd,(HMENU)IDCANCEL,GetModuleHandle(0), NULL);

	HGDIOBJ hDlgFont = GetStockObject (DEFAULT_GUI_FONT);
	SendMessage(hStat0,WM_SETFONT,(WPARAM)hDlgFont,FALSE);
	SendMessage(hWndRCPath,WM_SETFONT,(WPARAM)hDlgFont,FALSE);
//	SendMessage(hWndPickRCPath,WM_SETFONT,(WPARAM)hDlgFont,FALSE);
	SendMessage(hWndTest,WM_SETFONT,(WPARAM)hDlgFont,FALSE);
	SendMessage(hWndOK,WM_SETFONT,(WPARAM)hDlgFont,FALSE);
	SendMessage(hWndCancel,WM_SETFONT,(WPARAM)hDlgFont,FALSE);

	SetFocus(hWndRCPath);

	// ------------------------------------------

	{
		MSG msg;
	
		while(!g_bWindowQuit) 
		{
			GetMessage(&msg, NULL, 0, 0);

			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}

	// ------------------------------------------

	DestroyWindow(hDialogWnd);
	UnregisterClass(szWindowClass,GetModuleHandle(0));

	if(bReenableParent)
		EnableWindow(hParent,true);

	BringWindowToTop(hParent);

	g_pThis=0;
}



void CResourceCompilerHelper::GetDataFromRegistry()
{
	static TCHAR strNull[2] = "";
	HKEY  key;
	DWORD type;

	char szSubKey[512];

	sprintf(szSubKey,"Software\\Crytek\\%s","Polybump");		// Appname is always Polybump

	// Open the appropriate registry key
	LONG result = RegOpenKeyEx( HKEY_CURRENT_USER,szSubKey,0, KEY_READ, &key );
	if( ERROR_SUCCESS != result )
		return;

	{
		TCHAR strPath[MAX_PATH];
		DWORD size=MAX_PATH;

		result = RegQueryValueEx( key, "Bin32Path", NULL,&type, (BYTE*)strPath, &size );
		if( ERROR_SUCCESS == result )
		{
			m_sBin32Path = strPath;
		}
	}

	{
		DWORD dwVal;
		DWORD size=sizeof(dwVal);

		result = RegQueryValueEx( key, "ShowWindow", NULL,&type, (LPBYTE)&dwVal, &size );

		if(ERROR_SUCCESS==result && type==REG_DWORD)
			m_bShowWindow = (dwVal!=0);
		else
			m_bShowWindow=false;
	}

	{
		DWORD dwVal;
		DWORD size=sizeof(dwVal);

		result = RegQueryValueEx( key, "HideCustom", NULL,&type, (LPBYTE)&dwVal, &size );

		if(ERROR_SUCCESS==result && type==REG_DWORD)
			m_bHideCustom = (dwVal!=0);
		else
			m_bHideCustom=false;
	}

	RegCloseKey(key);
}



bool CResourceCompilerHelper::CallResourceCompiler( const char *szFileName, const char *szAdditionalSettings )
{
	// make command for execution
	char szRemoteCmdLine[MAX_PATH*3];

	if(!szAdditionalSettings)
		szAdditionalSettings="";				// better than using default values - the compiler might mess that up

	char szRemoteDirectory[512];
	// we use /nooutput because the file name from Photoshop is temporary and not the one we want to use
	sprintf(szRemoteDirectory, "%s/rc",m_sBin32Path.c_str());

	const char *szHideCustom = m_bHideCustom ? "" : " /userdialogcustom=0";

	// we use /nooutput because the file name from Photoshop is temporary and not the one we want to use

	if(!szFileName)
		sprintf(szRemoteCmdLine, "%s/rc.exe /wait",szRemoteDirectory);
	 else
		sprintf(szRemoteCmdLine, "%s/rc.exe \"%s\" /userdialog=1 %s %s",szRemoteDirectory,szFileName,szAdditionalSettings,szHideCustom);

	STARTUPINFO si;
	ZeroMemory( &si, sizeof(si) );
	si.cb = sizeof(si);
	si.dwX = 100;
	si.dwY = 100;
	si.dwFlags = STARTF_USEPOSITION;

	PROCESS_INFORMATION pi;
	ZeroMemory( &pi, sizeof(pi) );

	if( !CreateProcess( NULL, // No module name (use command line). 
		szRemoteCmdLine,				// Command line. 
		NULL,									  // Process handle not inheritable. 
		NULL,									  // Thread handle not inheritable. 
		FALSE,								  // Set handle inheritance to FALSE. 
		m_bShowWindow?0:CREATE_NO_WINDOW,	// creation flags. 
		NULL,									  // Use parent's environment block. 
		szRemoteDirectory,			// Set starting directory. 
		&si,										// Pointer to STARTUPINFO structure.
		&pi ))									  // Pointer to PROCESS_INFORMATION structure.
	{
		MessageBox(0,"rc/rc.exe (ResourceCompiler) not found\n\nPlease verify the path","Crytek Resource Compiler",MB_ICONERROR|MB_OK);
		return false;
	}

	// Wait until child process exits.
	WaitForSingleObject( pi.hProcess, INFINITE );

	// Close process and thread handles. 
	CloseHandle( pi.hProcess );
	CloseHandle( pi.hThread );
	return true;
}




bool CResourceCompilerHelper::InvokeResourceCompiler( const char *szSrcFile, const char *szDestFile, const char *szDataFolder, const bool bWindow ) const
{
	bool bRet=true;

	// make command for execution
	char szRemoteCmdLine[512];
	char szMasterCDDir[256];
	char szDir[512];

	GetCurrentDirectory(256,szMasterCDDir);

	sprintf(szRemoteCmdLine, "bin32\\rc\\%s \"%s/%s/%s\" /userdialog=0", RC_EXECUTABLE, szMasterCDDir,szDataFolder,szSrcFile);

	sprintf(szDir, "%s\\bin32\\rc", szMasterCDDir);

	STARTUPINFO si;
	ZeroMemory( &si, sizeof(si) );
	si.cb = sizeof(si);
	si.dwX = 100;
	si.dwY = 100;
	si.dwFlags = STARTF_USEPOSITION;

	PROCESS_INFORMATION pi;
	ZeroMemory( &pi, sizeof(pi) );

	if( !CreateProcess( NULL, // No module name (use command line). 
		szRemoteCmdLine,				// Command line. 
		NULL,             // Process handle not inheritable. 
		NULL,             // Thread handle not inheritable. 
		FALSE,            // Set handle inheritance to FALSE. 
		bWindow?0:CREATE_NO_WINDOW,	// creation flags. 
		NULL,             // Use parent's environment block. 
		szDir,					  // Set starting directory. 
		&si,              // Pointer to STARTUPINFO structure.
		&pi )             // Pointer to PROCESS_INFORMATION structure.
		) 
	{
		bRet=false;
	}

	// Wait until child process exits.
	WaitForSingleObject( pi.hProcess, INFINITE );

	// Close process and thread handles. 
	CloseHandle( pi.hProcess );
	CloseHandle( pi.hThread );

	return bRet;
}

bool CResourceCompilerHelper::IsError() const
{
	return m_bErrorFlag;
}


string CResourceCompilerHelper::GetInputFilename( const char *szFilePath, const uint32 dwIndex ) const
{
	const char *ext = GetExtension(szFilePath);

	if(ext)
	{
		if(stricmp(ext,".dds")==0)
		{
			switch(dwIndex)
			{
				case 0: return ReplaceExtension(szFilePath,".tif");	// index 0
//					case 1: return ReplaceExtension(szFilePath,".srf");	// index 1
				default: return "";	// last one
			}
		}
	}

	if(dwIndex)
		return "";				// last one

	return szFilePath;	// index 0
}


bool CResourceCompilerHelper::IsDestinationFormat( const char *szExtension ) const
{
	if(stricmp(szExtension,"dds")==0)		// DirectX surface format
		return true;

	return false;
}


bool CResourceCompilerHelper::IsSourceFormat( const char *szExtension ) const
{
	if(stricmp(szExtension,"tif")==0)			// Crytek resource compiler image input format
//		|| stricmp(szExtension,"srf")==0)		// Crytek surface formats (e.g. normalmap)
		return true;

	return false;
}

#endif //(WIN32) || (WIN64)
