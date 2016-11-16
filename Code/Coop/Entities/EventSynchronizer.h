#ifndef _EventSynchronizer_H_
#define _EventSynchronizer_H_

#include <IGameObject.h>

struct SEventSynchronizerEvent
{
public:
	SEventSynchronizerEvent()
	{
		sEventName = string();
		sEventStrings1 = string();
		sEventStrings2 = string();
		nEventInts1 = 0;
		nEventInts2 = 1;
		fEventFloats1 = 0;
		fEventFloats2 = 0;
		vEventVecs1 = Vec3();
		vEventVecs2 = Vec3();
	}

	void SerializeWith(TSerialize ser)
	{
		ser.Value("sEventName", sEventName);
		ser.Value("sEventStrings1", sEventStrings1);
		ser.Value("sEventStrings2", sEventStrings2);
		ser.Value("nEventInts1", nEventInts1);
		ser.Value("nEventInts2", nEventInts2);
		ser.Value("fEventFloats1", fEventFloats1);
		ser.Value("fEventFloats2", fEventFloats2);
		ser.Value("vEventVecs1", vEventVecs1, 'wrld');
		ser.Value("vEventVecs1", vEventVecs2, 'wrld');
	}

public:
	string sEventName;
	string sEventStrings1;
	string sEventStrings2;
	int nEventInts1;
	int nEventInts2;
	float fEventFloats1;
	float fEventFloats2;
	Vec3 vEventVecs1;
	Vec3 vEventVecs2;
};

struct IEventSynchronizerListener 
{
public:
	virtual void OnSynchronizedEventReceived(SEventSynchronizerEvent sEvent) = 0;
};

class CEventSynchronizer : public CGameObjectExtensionHelper<CEventSynchronizer, IGameObjectExtension>
{
public:
	CEventSynchronizer();
	virtual ~CEventSynchronizer();

public:
	void SendEvent(bool bLocal, SEventSynchronizerEvent sEvent);
	void ClientSendEvent(SEventSynchronizerEvent sEvent);

	DECLARE_CLIENT_RMI_NOATTACH(ClOnEvent, SEventSynchronizerEvent, eNRT_ReliableOrdered);
	DECLARE_SERVER_RMI_NOATTACH(SvRequest, SEventSynchronizerEvent, eNRT_ReliableOrdered);

	void RegisterEventListener(IEventSynchronizerListener* pListener) {
		m_listeners.push_back(pListener);
	}
	void UnregisterEventListener(IEventSynchronizerListener* pListener) {
		m_listeners.remove(pListener);
	}

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
	std::list<IEventSynchronizerListener*> m_listeners;
};


#endif // _EventSynchronizer_H_