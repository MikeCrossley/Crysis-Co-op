#ifndef __COMPATIBILITYALIENMOVEMENTCONTROLLER_H__
#define __COMPATIBILITYALIENMOVEMENTCONTROLLER_H__

#pragma once

#include "IMovementController.h"
#include "Actor.h"

class CAlien;

class CCompatibilityAlienMovementController : public IActorMovementController
{
public:
	CCompatibilityAlienMovementController( CAlien * pAlien );

	virtual void Reset();
	virtual bool Update( float frameTime, SActorFrameMovementParams& params );
	virtual void PostUpdate( float frameTime ){}
	virtual void Release();

	virtual bool RequestMovement( CMovementRequest& request );
	ILINE virtual void GetMovementState( SMovementState& state )
	{
		state = m_currentMovementState;
	};

	virtual bool GetStanceState( EStance stance, float lean, bool defaultPose, SStanceState& state );

	virtual bool GetStats(SStats& stats)
	{
		return false;
	}

	virtual void Serialize(TSerialize &ser) {}

	//Crysis Co-op
	SMovementState GetMovementReqState() { return m_currentMovementState; };
	//~Crysis Co-op

private:

	void	UpdateCurMovementState(const SActorFrameMovementParams& params);

	CAlien * m_pAlien;
	bool m_atTarget;
	bool m_exact;

	CMovementRequest m_currentMovementRequest;
	SMovementState m_currentMovementState;
};

#endif
