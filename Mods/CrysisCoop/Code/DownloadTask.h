/*************************************************************************
Crytek Source File.
Copyright (C), Crytek Studios, 2001-2007.
-------------------------------------------------------------------------
$Id$
$DateTime$
Description:  Base-class functionality for downloading files
-------------------------------------------------------------------------
History:
- 16/02/2007   : Steve Humphreys, Created
*************************************************************************/

#ifndef __DOWNLOADTASK_H__
#define __DOWNLOADTASK_H__

#pragma once

#include "INetworkService.h"

// the status of the current task
enum EDownloadState
{
	eDS_None = eFDE_LastError,// not doing anything
	eDS_Downloading,					// downloading a file
	eDS_Error_FileNotFound,		// file isn't present after downloading it
	eDS_Error_Checksum,				// file checksum doesn't match after download
	eDS_DiskFull,							// no space to save/extract file
	eDS_Done,									// finished successfully
};


struct IDownloadTaskListener
{
	// called every frame while downloading with latest status
	virtual void OnDownloadProgress(float percent) = 0;	

	// called on completion (with filename) or error (filename == NULL, result is a EDownloadState or EFileDownloadError
	virtual void OnDownloadFinished(int result, const char* filename) = 0;
};

class CDownloadTask 
{
public:
	CDownloadTask();
	virtual ~CDownloadTask();

	// check client and server machines both have a particular level
	bool StartMapDownload(SFileDownloadParameters& dl, int attempts, IDownloadTaskListener* pListener = NULL);

	// download a patch executable
	bool StartPatchDownload(SFileDownloadParameters& dl);

	void Update();
	void StopDownloadTask();

	bool IsDownloadTaskInProgress() const;
	int GetNumberOfFilesRemaining() const;
	float GetCurrentFileProgress() const;

private:

	void DownloadNextFile();
	int ValidateDownload();	
	bool FileExists(string file, int expectedSize);

	bool GetUserDataFolder(string& path);
	bool CreateDestinationFolder(string& folder);

	uint64 GetMD5FromString(const unsigned char* md5str);

	EDownloadState m_downloadState;					// status of the current download task

	std::list<SFileDownloadParameters> m_downloadList;		// download queue
	SFileDownloadParameters m_currentDownload;						// file currently downloading

	int m_downloadAttempt;									// fail after n unsuccessful attempts
	int	m_maxDownloadAttempts;							// n

	string m_downloadFolderPath;						// where to save the downloaded files

	IDownloadTaskListener* m_pListener;			// only one listener at a time
};

#endif // __DOWNLOADTASK_H__