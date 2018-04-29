#pragma once

#include <PlayerMovementController.h>

// Summary:
//	Extended movement controller for CCoopGrunt.
class CCoopGruntMovementController
	: public CPlayerMovementController
{
	friend class CCoopGrunt;
private:
	// Summary:
	//	Constructs a CCoopGruntMovementController class instance for the specified CCoopGrunt class instance.
	CCoopGruntMovementController(CCoopGrunt* pGrunt);

	// Summary:
	//	Destructs a CCoopGruntMovementController class instance.
	virtual ~CCoopGruntMovementController();

public:

	// IMovementController

	// Summary:
	//	Specialized movement request handling for CCoopGrunt (for ActorTarget support!)
	virtual bool RequestMovement(CMovementRequest& request);

	// ~IMovementController


private:
	// Pointer to the owner CCoopGrunt class instance.
	CCoopGrunt* m_pGrunt;

	// Boolean indicating whether the previous synchronization had an actor target or not.
	bool m_bHadActorTarget;

	// Query IDs for actor target processing.
	TAnimationGraphQueryID m_nQueryStartID;
	TAnimationGraphQueryID m_nQueryEndID;
	TAnimationGraphQueryID* m_pQueryStartID;
	TAnimationGraphQueryID* m_pQueryEndID;
};
