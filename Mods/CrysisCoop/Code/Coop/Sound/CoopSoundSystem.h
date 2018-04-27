#ifndef _CoopSoundSystem_H_
#define _CoopSoundSystem_H_

#include "ISerialize.h"
#include <ISound.h>

class CCoopSoundSystem : public ISoundSystem
{
public:
	CCoopSoundSystem() {};
	~CCoopSoundSystem() {};

	// ISoundSystem
	virtual bool Init();
	virtual void Release() {}
	virtual void Update(ESoundUpdateMode UpdateMode) {};
	virtual IMusicSystem* CreateMusicSystem() { return nullptr; }
	virtual IAudioDevice* GetIAudioDevice()	const { return nullptr; }
	virtual ISoundMoodManager* GetIMoodManager() const { return nullptr; }
	virtual IReverbManager* GetIReverbManager() const { return nullptr; }
	virtual void AddEventListener(ISoundSystemEventListener *pListener, bool bOnlyVoiceSounds);
	virtual void RemoveEventListener(ISoundSystemEventListener *pListener);
	virtual void GetOutputHandle(void **pHandle, EOutputHandle *HandleType) const {}
	virtual void SetMasterVolume(float fVol) {}
	virtual void SetMasterVolumeScale(float fScale, bool bForceRecalc = false) {}
	virtual float GetSFXVolume() { return 0.f; }
	virtual void SetSoundActiveState(ISound *pSound, ESoundActiveState State) {}
	virtual void SetMasterPitch(float fPitch) {}
	virtual struct ISound* GetSound(tSoundID nSoundID) const { return nullptr; }
	virtual EPrecacheResult Precache(const char *sGroupAndSoundName, uint32 nSoundFlags, uint32 nPrecacheFlags) { return EPrecacheResult::ePrecacheResult_Error; }
	virtual ISound* CreateSound(const char *sGroupAndSoundName, uint32 nFlags);
	virtual ISound* CreateLineSound(const char *sGroupAndSoundName, uint32 nFlags, const Vec3 &vStart, const Vec3 &VEnd) { return nullptr; }
	virtual ISound* CreateSphereSound(const char *sGroupAndSoundName, uint32 nFlags, const float fRadius) { return nullptr; }
	virtual bool SetListener(const ListenerID nListenerID, const Matrix34 &matOrientation, const Vec3 &vVel, bool bActive, float fRecordLevel) { return false; };
	virtual void SetListenerEntity(ListenerID nListenerID, EntityId nEntityID) {};
	virtual ListenerID CreateListener() { return 0; };
	virtual bool RemoveListener(ListenerID nListenerID) { return false; }
	virtual ListenerID GetClosestActiveListener(Vec3 vPosition) const { return 0; }
	virtual	IListener* GetListener(ListenerID nListenerID) { return nullptr; }
	virtual IListener* GetNextListener(ListenerID nListenerID) { return nullptr; }
	virtual uint32 GetNumActiveListeners() const { return 0; }
	virtual void RecomputeSoundOcclusion(bool bRecomputeListener, bool bForceRecompute, bool bReset = false) {}
	virtual bool IsEAX(void) { return false; }
	virtual bool SetGroupScale(int nGroup, float fScale) { return false; }
	virtual bool Silence(bool bStopLoopingSounds, bool bUnloadData) { return false; }
	virtual bool DeactivateAudioDevice() { return false; }
	virtual bool ActivateAudioDevice() { return false; }
	virtual void Pause(bool bPause, bool bResetVolume = false) {}
	virtual bool  IsPaused() { return false; }
	virtual void Mute(bool bMute) {}
	virtual void GetSoundMemoryUsageInfo(int *nCurrentMemory, int *nMaxMemory) const {}
	virtual void SetMusicEffectsVolume(float v) {}
	virtual int	GetUsedVoices() const { return 0; }
	virtual float GetCPUUsage() const { return 0.f; }
	virtual float GetMusicVolume() const { return 0.f; }
	virtual void CalcDirectionalAttenuation(const Vec3 &Pos, const Vec3 &Dir, const float fConeInRadians) {}
	virtual float GetDirectionalAttenuationMaxScale() { return 0.f; }
	virtual bool UsingDirectionalAttenuation() { return false; }
	virtual bool SetWeatherCondition(float fWeatherTemperatureInCelsius, float fWeatherHumidityAsPercent, float fWeatherInversion) { return false; }
	virtual bool GetWeatherCondition(float &fWeatherTemperatureInCelsius, float &fWeatherHumidityAsPercent, float &fWeatherInversion) { return false; }
	virtual void GetMemoryUsage(class ICrySizer* pSizer) const {}
	virtual int  GetMemoryUsageInMB() { return 0; }
	virtual bool DebuggingSound() { return false; }
	virtual int SetMinSoundPriority(int nPriority) { return 0; }
	virtual void LockResources() {}
	virtual void UnlockResources() {}
	virtual void TraceMemoryUsage(int nMemUsage) {}
	virtual ISoundProfileInfo* GetSoundInfo(int nIndex) { return nullptr; }
	virtual ISoundProfileInfo* GetSoundInfo(const char* sSoundName) { return nullptr; }
	virtual int GetSoundInfoCount() { return 0; }
	virtual bool GetRecordDeviceInfo(const int nRecordDevice, char* sName, int nNameLength) { return false; }
	virtual IMicrophone* CreateMicrophone(const unsigned int nRecordDevice, const unsigned int nBitsPerSample, const unsigned int nSamplesPerSecond, const unsigned int nBufferSizeInSamples) { return nullptr; }
	virtual bool RemoveMicrophone(IMicrophone *pMicrophone) { return false; }
	virtual ISound* CreateNetworkSound(INetworkSoundListener *pNetworkSoundListener, const unsigned int nBitsPerSample, const unsigned int nSamplesPerSecond, const unsigned int nBufferSizeInSamples, EntityId PlayerID) { return nullptr; }
	virtual void RemoveNetworkSound(ISound *pSound) {}
	virtual void Serialize(TSerialize ser) {}
	// ~ ISoundSystem

	void OnEvent(ESoundSystemCallbackEvent event, ISound *pSound);

private:
	std::list<ISoundSystemEventListener*> m_lSoundSystemEventListener;
};

#endif // _CoopSoundSystem_H_