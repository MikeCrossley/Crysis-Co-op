#ifndef __COOPPLAYER_H__
#define __COOPPLAYER_H__

#include "Player.h"

class CCoopPlayer : public CPlayer
{
public:
	CCoopPlayer();
	virtual ~CCoopPlayer();

	//CPlayer
	virtual bool Init(IGameObject * pGameObject);
	virtual void PostInit(IGameObject * pGameObject);
	virtual void PostUpdate(float frameTime);
	virtual void Update(SEntityUpdateContext& ctx, int updateSlot);
	virtual bool NetSerialize(TSerialize ser, EEntityAspects aspect, uint8 profile, int flags);
	//~CPlayer

	struct SAwarenessParams
	{
		SAwarenessParams() {};
		SAwarenessParams(float awarenessFloat): 
			awarenessFloat(awarenessFloat) 
		{};

		float awarenessFloat;
		void SerializeWith(TSerialize ser)
		{
			ser.Value("awarenessFloat", awarenessFloat);
		}
	};

	void ForceMusicMood(float intensity, bool force){m_bMusicForceMood = force; m_fMusicIntensity = intensity; m_fMusicDelay = 5.f;};

	DECLARE_CLIENT_RMI_PREATTACH(ClUpdateAwareness, SAwarenessParams, eNRT_ReliableUnordered);

private:
	void UpdateDetectionValue(float frameTime);
	void UpdateMusic(float frameTime);

public:
	
	// Summary:
	//	Gets the player's current detection value.
	float GetDetectionValue() {
		return m_fDetectionValue;
	}

private:
	struct ICVar* m_pSystemUpdateRate;
	float m_fDetectionTimer;
	float m_fDetectionValue;
	float m_fLastDetectionValue;

	float m_fMusicDelay;


	float m_fNetDetectionDelay;

	float m_fMusicIntensity;
	bool m_bMusicForceMood;
};

#endif // __COOPPLAYER_H__