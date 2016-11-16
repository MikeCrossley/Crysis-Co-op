#ifndef _CoopReadability_H_
#define _CoopReadability_H_

#include "ISound.h"

class CCoopReadability 
	: public ISoundSystemEventListener
{
public:
	CCoopReadability();
	~CCoopReadability();

	//ISoundSystemEventListener
	virtual void OnSoundSystemEvent( ESoundSystemCallbackEvent event,ISound *pSound );
	//~ISoundSystemEventListener

private:

	bool SendSoundToClosestActor(ISound* pSound);
};

#endif // _CoopSystem_H_