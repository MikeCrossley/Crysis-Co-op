#pragma once

#include <IAnimationGraph.h>

class CAnimationGraphState
	: public IAnimationGraphState
{
	friend class CActor;
private:

	CAnimationGraphState(CActor* pActor, IAnimationGraphState* pState)
		: m_pOwner(pActor)
		, m_pAnimationGraphState(pState)
	{
	}

	~CAnimationGraphState()
	{

	}

public:

	// IAnimationGraphState

	// recurse setting. query mechanism needs to be wrapped by wrapper.
	// Associated QueryID will be given to QueryComplete when ALL layers supporting the input have reached their matching states.
	// wrapper generates it's own query IDs which are associated to a bunch of sub IDs with rules for how to handle the sub IDs into wrapped IDs.
	virtual bool SetInput(InputID id, float value, TAnimationGraphQueryID * pQueryID = 0);
	virtual bool SetInput(InputID id, int value, TAnimationGraphQueryID * pQueryID = 0);
	virtual bool SetInput(InputID id, const char* value, TAnimationGraphQueryID * pQueryID = 0);
	// SetInputOptional is same as SetInput except that it will not set the default input value in case a non-existing value is passed
	virtual bool SetInputOptional(InputID id, const char * value, TAnimationGraphQueryID * pQueryID = 0) { return m_pAnimationGraphState->SetInputOptional(id, value, pQueryID); };
	virtual void ClearInput(InputID id) { m_pAnimationGraphState->ClearInput(id); };
	virtual void LockInput(InputID id, bool locked) { m_pAnimationGraphState->LockInput(id, locked); };

	// assert all equal, use any (except if signalled, then return the one not equal to default, or return default of all default)
	virtual void GetInput(InputID id, char * name) const { return m_pAnimationGraphState->GetInput(id, name); };

	// AND all layers
	virtual bool IsDefaultInputValue(InputID id) const { return m_pAnimationGraphState->IsDefaultInputValue(id); };

	// returns NULL if InputID is out of range
	virtual const char* GetInputName(InputID id) const { return m_pAnimationGraphState->GetInputName(id); };

	// When QueryID of SetInput (reached queried state) is emitted this function is called by the outside, by convention(verify!).
	// Remember which layers supported the SetInput query and emit QueryLeaveState QueryComplete when all those layers have left those states.
	virtual void QueryLeaveState(TAnimationGraphQueryID * pQueryID) { m_pAnimationGraphState->QueryLeaveState(pQueryID); };

	// assert all equal, forward to all layers, complete when all have changed once (trivial, since all change at once via SetInput).
	// (except for signalled, forward only to layers which currently are not default, complete when all those have changed).
	virtual void QueryChangeInput(InputID id, TAnimationGraphQueryID *query) { m_pAnimationGraphState->QueryChangeInput(id, query); };

	// Just register and non-selectivly call QueryComplete on all listeners (regardless of what ID's they are actually interested in).
	virtual void AddListener(const char * name, IAnimationGraphStateListener * pListener) { m_pAnimationGraphState->AddListener(name, pListener); };
	virtual void RemoveListener(IAnimationGraphStateListener * pListener) { m_pAnimationGraphState->RemoveListener(pListener); };

	// Not used
	virtual bool DoesInputMatchState(InputID id) { return m_pAnimationGraphState->DoesInputMatchState(id); };

	// TODO: This should be turned into registered callbacks or something instead (look at AnimationGraphStateListener).
	// Use to access the SelectLocomotionState() callback in CAnimatedCharacter.
	// Only set for fullbody, null for upperbody.
	virtual void SetAnimatedCharacter(class CAnimatedCharacter* animatedCharacter, int layerIndex, IAnimationGraphState* parentLayerState) { m_pAnimationGraphState->SetAnimatedCharacter(animatedCharacter, layerIndex, parentLayerState); }

	// simply recurse
	virtual bool Update() { return m_pAnimationGraphState->Update(); };
	virtual void Release() { m_pAnimationGraphState->Release(); delete this; };
	virtual void ForceTeleportToQueriedState() { m_pAnimationGraphState->ForceTeleportToQueriedState(); };

	// simply recurse (will be ignored by each layer individually if state not found)
	virtual void PushForcedState(const char * state, TAnimationGraphQueryID * pQueryID = 0) { m_pAnimationGraphState->PushForcedState(state, pQueryID); };

	// simply recurse
	virtual void ClearForcedStates() { m_pAnimationGraphState->ClearForcedStates(); };

	// simply recurse
	virtual void SetBasicStateData(const SAnimationStateData& data) { m_pAnimationGraphState->SetBasicStateData(data); };

	// same as GetInput above
	virtual float GetInputAsFloat(InputID inputId) { return m_pAnimationGraphState->GetInputAsFloat(inputId); };

	// wrapper generates it's own input IDs for the union of all inputs in all layers, and for each input it maps to the layer specific IDs.
	virtual InputID GetInputId(const char *input) { return m_pAnimationGraphState->GetInputId(input); };

	// simply recurse (preserve order), and don't forget to serialize the wrapper stuff, ID's or whatever.
	virtual void Serialize(TSerialize ser) { m_pAnimationGraphState->Serialize(ser); };

	// simply recurse
	virtual void SetAnimationActivation(bool activated) { m_pAnimationGraphState->SetAnimationActivation(activated); };
	virtual bool GetAnimationActivation() { return m_pAnimationGraphState->GetAnimationActivation(); };

	// Concatenate all layers state names with '+'. Use only fullbody layer state name if upperbody layer is not allowed/mixed.
	virtual const char * GetCurrentStateName() { return m_pAnimationGraphState->GetCurrentStateName(); };

	// don't expose (should only be called on specific layer state directly, by AGAnimation)
	//virtual void ForceLeaveCurrentState() = 0;
	//virtual void InvalidateQueriedState() = 0;

	// simply recurse
	virtual void Pause(bool pause, EAnimationGraphPauser pauser) { m_pAnimationGraphState->Pause(pause, pauser); };

	// is the same for all layers (equal assertion should not even be needed)
	virtual bool IsInDebugBreak() { return m_pAnimationGraphState->IsInDebugBreak(); };

	// find highest layer that has output id, or null (this allows upperbody to override fullbody).
	// Use this logic when calling SetOutput on listeners.
	virtual const char * QueryOutput(const char * name) { return m_pAnimationGraphState->QueryOutput(name); };

	// Exact positioning: Forward to fullbody layer only (hardcoded)
	virtual IAnimationSpacialTrigger * SetTrigger(const SAnimationTargetRequest& req, EAnimationGraphTriggerUser user, TAnimationGraphQueryID * pQueryStart, TAnimationGraphQueryID * pQueryEnd) {
		return m_pAnimationGraphState->SetTrigger(req, user, pQueryStart, pQueryEnd);
	};
	virtual void ClearTrigger(EAnimationGraphTriggerUser user) { m_pAnimationGraphState->ClearTrigger(user); };
	virtual const SAnimationTarget* GetAnimationTarget() { return m_pAnimationGraphState->GetAnimationTarget(); };
	virtual void SetTargetPointVerifier(IAnimationGraphTargetPointVerifier *ptr) { m_pAnimationGraphState->SetTargetPointVerifier(ptr); };
	virtual bool IsUpdateReallyNecessary() { return m_pAnimationGraphState->IsUpdateReallyNecessary(); };

	// (only used by vehicle code) (to support simultaneous layer query, IAnimationGraphExistanceQuery must implement it).
	// Forward to fullbody layer only (hardcoded)
	virtual IAnimationGraphExistanceQuery * CreateExistanceQuery() { return m_pAnimationGraphState->CreateExistanceQuery(); };

	// simply recurse
	virtual void Reset() { m_pAnimationGraphState->Reset(); };

	// we've been idle for a while, try to catch up and disrespect blending laws
	// simply recurse
	virtual void SetCatchupFlag() { m_pAnimationGraphState->SetCatchupFlag(); };

	// (hardcoded forward to fullbody layer only) (used for exact positioning trigger and PMC::UpdateMovementState()).
	virtual Vec2 GetQueriedStateMinMaxSpeed() { return m_pAnimationGraphState->GetQueriedStateMinMaxSpeed(); };

	// simply recurse (hurry all layers, let them hurry independently where they can)
	virtual void Hurry() { m_pAnimationGraphState->Hurry(); };

	// simply recurse (first person skippable states are skipped independently by each layer)
	virtual void SetFirstPersonMode(bool on) { m_pAnimationGraphState->SetFirstPersonMode(on); };

	// simply recurse (will add all layer's containers to the sizer)
	virtual void GetMemoryStatistics(ICrySizer * s) { m_pAnimationGraphState->GetMemoryStatistics(s); };

	// the wrapper simply returns false
	virtual bool IsMixingAllowedForCurrentState() const { return m_pAnimationGraphState->IsMixingAllowedForCurrentState(); };

	// used by CAnimationGraphStates
	virtual bool IsSignalledInput(InputID intputId) const { return m_pAnimationGraphState->IsSignalledInput(intputId); };

	// ~IAnimationGraphState

private:
	// Pointer to the owner actor.
	CActor* m_pOwner;
	// Pointer to the native IAnimationGraphState class implementation.
	IAnimationGraphState* m_pAnimationGraphState;
};