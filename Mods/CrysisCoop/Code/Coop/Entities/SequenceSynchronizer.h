#ifndef _SequenceSynchronizer_H_
#define _SequenceSynchronizer_H_

#include <IGameObject.h>

class CSequenceSynchronizer 
	:	public CGameObjectExtensionHelper<CSequenceSynchronizer, IGameObjectExtension>
{
public:
	CSequenceSynchronizer();
	virtual ~CSequenceSynchronizer();

	struct STrackviewSeqParams
	{
		STrackviewSeqParams() {};
		STrackviewSeqParams(bool bStart, string sSequence, float fStartTime, bool bBreakOnStop) :
			bStart(bStart),
			sSequence(sSequence),
			fStartTime(fStartTime),
			bBreakOnStop(bBreakOnStop)
		{};

		bool bStart;
		string sSequence;
		float fStartTime;
		bool bBreakOnStop;

		void SerializeWith(TSerialize ser)
		{
			ser.Value("bStart", bStart);
			ser.Value("sSequence", sSequence);
			ser.Value("fStartTime", fStartTime);
			ser.Value("bBreakOnStop", bBreakOnStop);
		}
	};

	DECLARE_CLIENT_RMI_NOATTACH(ClTrackviewSequence, STrackviewSeqParams, eNRT_ReliableOrdered);

public:
	void PlaySequence(string sSequence, float fStartTime, bool bBreakOnStop);
	void StopSeqeunce(string sSequence, float fStartTime, bool bBreakOnStop);

public:
	// IGameObjectExtension
	virtual bool Init(IGameObject *pGameObject);
	virtual void InitClient(int channelId) {};
	virtual void PostInit(IGameObject *pGameObject);
	virtual void PostInitClient(int channelId) {};
	virtual void Release();
	virtual void FullSerialize(TSerialize ser) { };
	virtual bool NetSerialize(TSerialize ser, EEntityAspects aspect, uint8 profile, int flags) { return true; };
	virtual void PostSerialize() {}
	virtual void SerializeSpawnInfo(TSerialize ser) {}
	virtual ISerializableInfoPtr GetSpawnInfo() { return 0; }
	virtual void Update(SEntityUpdateContext &ctx, int updateSlot) { };
	virtual void PostUpdate(float frameTime) {};
	virtual void PostRemoteSpawn() {};
	virtual void HandleEvent(const SGameObjectEvent &) { };
	virtual void ProcessEvent(SEntityEvent &) { };
	virtual void SetChannelId(uint16 id) {}
	virtual void SetAuthority(bool auth) {};
	virtual void GetMemoryStatistics(ICrySizer * s) { };
	//~IGameObjectExtension

protected:
	bool m_bInitialized;
};


#endif // _SequenceSynchronizer_H_