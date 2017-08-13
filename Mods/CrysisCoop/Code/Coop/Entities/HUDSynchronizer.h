#ifndef _HUDSynchronizer_H_
#define _HUDSynchronizer_H_

#include <IGameObject.h>

class CHUDSynchronizer 
	:	public CGameObjectExtensionHelper<CHUDSynchronizer, IGameObjectExtension>
{
public:
	CHUDSynchronizer();
	virtual ~CHUDSynchronizer();

public:
	struct SHudOverlayParams
	{
		SHudOverlayParams() {};
		SHudOverlayParams(int nPosX, int nPosY, string sMsg, float fDuration, Vec3 vColor) :
			nPosX(nPosX),
			nPosY(nPosY),
			sMsg(sMsg),
			fDuration(fDuration),
			vColor(vColor)
		{};
		int nPosX;
		int nPosY;
		string sMsg;
		float fDuration;
		Vec3 vColor;

		void SerializeWith(TSerialize ser)
		{
			ser.Value("nPosX", nPosX);
			ser.Value("nPosY", nPosY);
			ser.Value("sMsg", sMsg);
			ser.Value("fDuration", fDuration);
			ser.Value("vColor", vColor);
		}
	};

	struct SHudControlParams
	{
		SHudControlParams() {};
		SHudControlParams(int nEnum) :
			nEnum(nEnum)
		{};
		int nEnum;

		void SerializeWith(TSerialize ser)
		{
			ser.Value("nEnum", nEnum);
		}
	};

	DECLARE_CLIENT_RMI_NOATTACH(ClDisplayOverlayMsg, SHudOverlayParams, eNRT_ReliableOrdered);
	DECLARE_CLIENT_RMI_NOATTACH(ClHideOverlayMsg, SHudControlParams, eNRT_ReliableOrdered);
	DECLARE_CLIENT_RMI_NOATTACH(ClHudControl, SHudControlParams, eNRT_ReliableOrdered);


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
};


#endif // _HUDSynchronizer_H_