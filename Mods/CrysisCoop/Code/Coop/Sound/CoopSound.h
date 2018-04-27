#ifndef _CoopSound_H_
#define _CoopSound_H_

#include "ISerialize.h"
#include <ISound.h>

class CCoopSound : public ISound
{
public:
	CCoopSound() {};
	~CCoopSound() {};

	// ISound
	virtual void		AddEventListener(ISoundEventListener *pListener, const char *sWho) {}
	virtual void		RemoveEventListener(ISoundEventListener *pListener) {}
	virtual bool		IsPlaying() const { return false; }
	virtual bool		IsPlayingVirtual() const { return false; }
	virtual bool		IsLoading() const { return false; }
	virtual bool		IsLoaded() const { return false; }
	virtual bool		UnloadBuffer() { return false; }
	virtual void		Play(float fVolumeScale = 1.0f, bool bForceActiveState = true, bool bSetRatio = true, IEntitySoundProxy *pEntitySoundProxy = NULL);
	virtual void		Stop(ESoundStopMode eStopMode = ESoundStopMode_EventFade) {}
	virtual void		SetPaused(bool bPaused) {}
	virtual bool		GetPaused() const { return false; }
	virtual void		SetFade(const float fFadeGoal, const int nFadeTimeInMS) {}
	virtual EFadeState	GetFadeState() const { return EFadeState::eFadeState_None; }
	virtual void		SetSemantic(ESoundSemantic eSemantic) { m_nSoundSemantic = eSemantic; }
	virtual ESoundSemantic GetSemantic() { return m_nSoundSemantic; }
	virtual const char*	GetName() { return m_sSoundName.c_str(); }
	virtual const tSoundID	GetId() const { return 0; }
	virtual	void		SetId(tSoundID SoundID) {}
	virtual void		SetLoopMode(bool bLoop) {}
	virtual bool		Preload() { return false; }
	virtual unsigned int GetCurrentSamplePos(bool bMilliSeconds = false) const { return 0; }
	virtual void		SetCurrentSamplePos(unsigned int nPos, bool bMilliSeconds) {}
	virtual void		SetPitching(float fPitching) {}
	virtual void		SetRatio(float fRatio) {}
	virtual int			GetFrequency() const { return 0; }
	virtual void		SetPitch(int nPitch) {}
	virtual void		SetPan(float fPan) {}
	virtual float		GetPan() const { return 0.f; }
	virtual void		Set3DPan(float f3DPan) {}
	virtual float		Get3DPan() const { return 0.f; }
	virtual void		SetMinMaxDistance(float fMinDist, float fMaxDist) {}
	virtual float		GetMaxDistance() const { return 0.f; }
	virtual void		SetDistanceMultiplier(const float fMultiplier) {}
	virtual void		SetConeAngles(const float fInnerAngle, const float fOuterAngle) {}
	virtual void		GetConeAngles(float &fInnerAngle, float &fOuterAngle) {}
	virtual void		AddToScaleGroup(int nGroup) {}
	virtual void		RemoveFromScaleGroup(int nGroup) {}
	virtual void		SetScaleGroup(unsigned int nGroupBits) {}
	virtual	void		SetVolume(const float fVolume) {}
	virtual	float		GetVolume() const {	return 0.f; }
	virtual void		SetPosition(const Vec3 &pos) {}
	virtual Vec3		GetPosition() const { return Vec3(ZERO); }
	virtual void		SetLineSpec(const Vec3 &vStart, const Vec3 &vEnd) {}
	virtual bool		GetLineSpec(Vec3 &vStart, Vec3 &vEnd) { return false; }
	virtual void		SetSphereSpec(const float fRadius) {}
	virtual void		SetVelocity(const Vec3 &vel) {}
	virtual Vec3		GetVelocity(void) const { return Vec3(ZERO); }
	virtual SObstruction* GetObstruction(void) { return nullptr; }
	virtual void		SetPhysicsToBeSkipObstruction(EntityId *pSkipEnts, int nSkipEnts) {}
	virtual void		SetDirection(const Vec3 &dir) {}
	virtual Vec3		GetDirection() const { return Vec3(ZERO); }
	virtual bool		IsRelative() const { return false; }
	virtual int			AddRef() { return 0; }
	virtual int			Release() { return 0; }
	virtual void		SetFlags(uint32 nFlags) {}
	virtual uint32		GetFlags() const { return 0; }
	virtual	void		FXEnable(int nEffectNumber) {}
	virtual	void		FXSetParamEQ(float fCenter, float fBandwidth, float fGain) {}
	virtual int			GetLengthMs() const { return 0; }
	virtual int			GetLength()const { return 0; }
	virtual void		SetSoundPriority(int nSoundPriority) {}
	virtual bool		IsInCategory(const char* sCategory) { return false; }
	virtual bool		GetParam(enumSoundParamSemantics eSemantics, ptParam* pParam) const { return false; }
	virtual bool		SetParam(enumSoundParamSemantics eSemantics, ptParam* pParam) { return false; }
	virtual int			GetParam(const char *sParameter, float *fValue, bool bOutputWarning = true) const { return 0; }
	virtual int			SetParam(const char *sParameter, float fValue, bool bOutputWarning = true) { return 0; }
	virtual bool		GetParam(int nIndex, float *fValue, bool bOutputWarning = true) const { return false; }
	virtual bool		SetParam(int nIndex, float fValue, bool bOutputWarning = true) { return false; }
	// ~ ISound

	virtual void SetName(const char* szName) { m_sSoundName = szName; }
private:
	ESoundSemantic	m_nSoundSemantic;
	string			m_sSoundName;
};


#endif // _CoopSound_H_