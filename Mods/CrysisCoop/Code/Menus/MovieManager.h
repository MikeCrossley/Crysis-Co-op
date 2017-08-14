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
#ifndef __MOVIE_MANAGER_H__
#define __MOVIE_MANAGER_H__

#pragma once

//-----------------------------------------------------------------------------------------------------

class CMovieManager
{

public :

	struct SMovieInfo
	{
		string filename;
		int	allowskip;
		SMovieInfo() : filename(""), allowskip(0) {};
	};

	CMovieManager();
	~	CMovieManager();

	bool Update(float fDeltaTime);
	void PlayVideo(int index);
	void SkipVideo();
	void NextVideo();
	bool IsPlaying();

private :

	int		m_current;

	std::vector<SMovieInfo> m_movieList;

};
#endif

//-----------------------------------------------------------------------------------------------------