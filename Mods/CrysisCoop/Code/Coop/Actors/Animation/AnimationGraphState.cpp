#include <StdAfx.h>
#include "AnimationGraphState.h"
#include <Actor.h>

// Forward to owner actor.

bool CAnimationGraphState::SetInput(InputID id, float value, TAnimationGraphQueryID * pQueryID)
{
	bool bSucceeded = m_pAnimationGraphState->SetInput(id, value, pQueryID);
	if (gEnv->bServer) m_pOwner->OnAGSetInput(bSucceeded, id, value, pQueryID);
	return bSucceeded;
}

bool CAnimationGraphState::SetInput(InputID id, int value, TAnimationGraphQueryID * pQueryID)
{
	bool bSucceeded = m_pAnimationGraphState->SetInput(id, value, pQueryID);
	if (gEnv->bServer) m_pOwner->OnAGSetInput(bSucceeded, id, value, pQueryID);
	return bSucceeded;
}

bool CAnimationGraphState::SetInput(InputID id, const char* value, TAnimationGraphQueryID * pQueryID)
{
	bool bSucceeded = m_pAnimationGraphState->SetInput(id, value, pQueryID);
	if(gEnv->bServer) m_pOwner->OnAGSetInput(bSucceeded, id, value, pQueryID);
	return bSucceeded;
};