#ifndef _DialogSynchronizer_H_
#define _DialogSynchronizer_H_

#include <IGameObject.h>

#include "DialogPlayer.h"

class CDialogSession;

class CDialogSynchronizer 
	:	public CGameObjectExtensionHelper<CDialogSynchronizer, IGameObjectExtension>
{
public:
	CDialogSynchronizer();
	virtual ~CDialogSynchronizer();

public:
	struct SDialogParams
	{
		SDialogParams() {};
		SDialogParams(string sDialog, EntityId* pActors, int nAIInterrupt, float fAwareDist, float fAwareAngle, float fAwareTimeOut, int nFlags, int nFromLine) :
			sDialog(sDialog),
			nActor1(pActors[0]),
			nActor2(pActors[1]),
			nActor3(pActors[2]),
			nActor4(pActors[3]),
			nActor5(pActors[4]),
			nActor6(pActors[5]),
			nActor7(pActors[6]),
			nActor8(pActors[7]),
			nAIInterrupt(nAIInterrupt),
			fAwareDist(fAwareDist),
			fAwareAngle(fAwareAngle),
			fAwareTimeOut(fAwareTimeOut),
			nFlags(nFlags),
			nFromLine(nFromLine)
		{};
		string sDialog;
		
		EntityId nActor1;
		EntityId nActor2;
		EntityId nActor3;
		EntityId nActor4;
		EntityId nActor5;
		EntityId nActor6;
		EntityId nActor7;
		EntityId nActor8;

		int nAIInterrupt;
		float fAwareDist;
		float fAwareAngle;
		float fAwareTimeOut;
		int nFlags;
		int nFromLine;

		void SerializeWith(TSerialize ser)
		{
			ser.Value("sDialog", sDialog);

			ser.Value("nActor1", nActor1, 'eid');
			ser.Value("nActor2", nActor2, 'eid');
			ser.Value("nActor3", nActor3, 'eid');
			ser.Value("nActor4", nActor4, 'eid');
			ser.Value("nActor5", nActor5, 'eid');
			ser.Value("nActor6", nActor6, 'eid');
			ser.Value("nActor7", nActor7, 'eid');
			ser.Value("nActor8", nActor8, 'eid');

			ser.Value("nAIInterrupt", nAIInterrupt);
			ser.Value("fAwareDist", fAwareDist);
			ser.Value("fAwareAngle", fAwareAngle);
			ser.Value("fAwareTimeOut", fAwareTimeOut);
			ser.Value("nFlags", nFlags);
			ser.Value("nFromLine", nFromLine);
		}
	};

	struct SDialogStopParams
	{
		SDialogStopParams() {};
		SDialogStopParams(bool bStop) :
			bStop(bStop)
		{};
		bool bStop;

		void SerializeWith(TSerialize ser)
		{
			ser.Value("bStop", bStop, 'bool');
		}
	};

	DECLARE_CLIENT_RMI_NOATTACH(ClPlayDialog, SDialogParams, eNRT_ReliableOrdered);
	DECLARE_CLIENT_RMI_NOATTACH(ClStopDialog, SDialogStopParams, eNRT_ReliableOrdered);
public:
	bool PlayDialog(string sDialog, EntityId* pActors, int nAIInterrupt, float fAwareDist, float fAwareAngle, float fAwareTimeOut, int nFlags, int nFromLine);
	bool StopDialog();

public:
	// IGameObjectExtension
	virtual bool Init(IGameObject *pGameObject);
	virtual void InitClient(int channelId) {};
	virtual void PostInit(IGameObject *pGameObject) { };
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

private:
	CDialogPlayer* m_pDialogPlayer;
};


#endif // _DialogSynchronizer_H_