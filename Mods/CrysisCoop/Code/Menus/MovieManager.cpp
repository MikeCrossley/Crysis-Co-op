/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2008.
-------------------------------------------------------------------------
$Id$
$DateTime$
Description: Handles intro movie playback and order.

-------------------------------------------------------------------------
History:
- 07/2008: Created by Jan Neugebauer

*************************************************************************/

#include "StdAfx.h"
#include <StlUtils.h>
#include "MovieManager.h"

#include <IVideoPlayer.h>

#include "FlashMenuObject.h"
#include "OptionsManager.h"
#include "Game.h"
#include "GameCVars.h"


//-----------------------------------------------------------------------------------------------------

CMovieManager::CMovieManager()
{
	m_movieList.clear();

	XmlNodeRef movieInfo = GetISystem()->LoadXmlFile("Languages/movielist.xml");

	if(movieInfo == 0)
	{
		GameWarning("CMovieManager: Could not load movielist.xml!");
	}
	else
	{
		if(movieInfo)
		{
			for(int n = 0; n < movieInfo->getChildCount(); ++n)
			{
				XmlNodeRef movieNode = movieInfo->getChild(n);
				const char* name = movieNode->getTag();
				if(!stricmp(name, "Movie"))
				{
					SMovieInfo info;
					int attribs = movieNode->getNumAttributes();
					const char* key;
					const char* value;
					for(int i = 0; i < attribs; ++i)
					{
						movieNode->getAttributeByIndex(i, &key, &value);
						if(!stricmp(key,"FileName"))
						{
							info.filename = value;
						}
						else if(!stricmp(key,"AllowSkip") && value)
						{
							info.allowskip = atoi(value);
						}
					}
					m_movieList.push_back(info);
				}
			}
		}
	}

	m_current = 0;
}

//-----------------------------------------------------------------------------------------------------

CMovieManager::~CMovieManager()
{
	m_movieList.clear();
}

//-----------------------------------------------------------------------------------------------------

bool CMovieManager::Update(float fDeltaTime)
{

	if(g_pGameCVars->g_skipIntro==1)
	{
		m_current = m_movieList.size();
	}

	if(!IsPlaying())
		return false;

	IVideoPlayer *player = g_pGame->GetMenu()->GetVideoPlayer();
	if(!player)
	{
		PlayVideo(m_current);
		return true;
	}

	IVideoPlayer::EPlaybackStatus status =  player->GetStatus();

	if(status == IVideoPlayer::PBS_STOPPED)
	{
		g_pGame->GetMenu()->StopVideo();
		return true;
	}

	if(status == IVideoPlayer::PBS_ERROR || status == IVideoPlayer::PBS_FINISHED)
	{
		NextVideo();
		return true;
	}

	player->Render();
	g_pGame->GetMenu()->DisplaySubtitles(fDeltaTime);
	return true;
}

//-----------------------------------------------------------------------------------------------------

void CMovieManager::PlayVideo(int index)
{
	SMovieInfo info = m_movieList[index];
	g_pGame->GetMenu()->PlayVideo(info.filename.c_str(), false);
}

//-----------------------------------------------------------------------------------------------------

void CMovieManager::SkipVideo()
{
	SMovieInfo info = m_movieList[m_current];

	bool firstStart = g_pGame->GetOptions()->IsFirstStart();
	bool devmode = gEnv->pSystem->IsDevMode();

	if(devmode || info.allowskip==0 || (info.allowskip==1 && !firstStart))
	{
		NextVideo();
	}
}

//-----------------------------------------------------------------------------------------------------

void CMovieManager::NextVideo()
{
	g_pGame->GetMenu()->StopVideo();

	ColorF cBlack(Col_Black);
	gEnv->pRenderer->ClearBuffer(FRT_CLEAR | FRT_CLEAR_IMMEDIATE,&cBlack);

	++m_current;
}

bool CMovieManager::IsPlaying()
{
	if(!m_movieList.size())
		return false;

	if(m_current<0 || m_current>=m_movieList.size())
		return false;

	return true;
}