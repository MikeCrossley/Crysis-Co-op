--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Trooper is grabbed by scout
--  
--------------------------------------------------------------------------
--  History:
--	- Apr 2007		: created by Luciano Morpurgo
--------------------------------------------------------------------------


AIBehaviour.TrooperGrabbedByScout = {
	Name = "TrooperGrabbedByScout",
	Base = "Dumb",

	---------------------------------------------
	Constructor = function(self, entity)
		entity:SelectPipe(0,"do_nothing");
		--entity:InsertSubpipe(0,"tr_grabbed_by_scout");
		entity.actor:SetParams({overrideFlyAction = "grabbedByScout"});
		entity:SetAttachmentEffect(0, "Grapped", "alien_special.Trooper.carried", g_Vectors.v000, g_Vectors.v010, 1, 0); 

		local entityAI = entity.AI;
		entityAI.bGrabbedFx = true;
		entityAI.bDropped = false;
		entityAI.noDamageImpulse = true;
		
		entityAI.bSwitchingPosition = false;
		entityAI.bSpecialAction = false;
		entityAI.bShootingOnSpot = false;
		entityAI.bSearching = false;
		
		entity.AI.bRemovingShield = false;
		AI.SetIgnorant(entity.id,1);
	end,
	
	---------------------------------------------
	Destructor = function(self, entity)
		entity.AI.noDamageImpulse = false;
		entity.AI.bGrabbedFx = false;
		entity.actor:SetParams({overrideFlyAction = "idle"});--fallback
		if(not entity.AI.bRemovingShield) then 
			-- might happen that the trooper lands before the SET_DROPPED signal is sent
			self:SET_DROPPED(entity);
		end
		AI.SetIgnorant(entity.id,0);
	end,
	
	---------------------------------------------
	OnDropped = function(self, entity)
		entity.AI.bDropped = true;
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_set_dropped");
		entity:PlayIdleSound(entity.voiceTable.idle);
	end,
	---------------------------------------------
	SET_DROPPED = function(self, entity)
		entity.actor:SetParams({overrideFlyAction = "idle"});
		entity:SetAttachmentEffect(0, "Grapped", "alien_special.Trooper.carried_fadeout", g_Vectors.v000, g_Vectors.v010, 1, 0); 
		entity.AI.bGrabbedFx = false;
		entity:SetTimer(TROOPER_GRABBEDFX_TIMER,3000);
		entity:Readibility("startup",1,100);
		entity.AI.bRemovingShield = true;
	end,
	
	---------------------------------------------
	OnLand = function(self,entity,sender)

		local entityAI = entity.AI;
		if(entityAI.bDropped) then -- prevent cases when trooper touches the ground while he's still grabbed
			entityAI.noDamageImpulse = false;
			if(not entityAI.bRemovingShield) then 
				-- might happen that the trooper lands before the SET_DROPPED signal is sent
				self:SET_DROPPED(entity);
			end
			if(entityAI.bSpecialAction or AI.GetGroupCount( entity.id, GROUP_ENABLED, AIOBJECT_PUPPET )<2) then
				AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_SPECIAL_ACTION",entity.id);
				return;
			elseif(entityAI.bSwitchingPosition) then 
				AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_SWITCH_POSITION",entity.id);
				return;
			elseif(entityAI.bShootingOnSpot) then
				AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ON_SPOT",entity.id);
				return;
			elseif(entityAI.bSearching) then
				if(entityAI.point and entityAI.point2 and entityAI.iValue)  then 
					g_SignalData.iValue = entityAI.iValue;
					CopyVector(g_SignalData.point,entityAI.point);
					CopyVector(g_SignalData.point2,entityAI.point2);
					AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_SEARCH",entity.id,g_SignalData);
					return;
				end
			end

			local targetType = AI.GetTargetType(entity.id);
			if(targetType==AITARGET_ENEMY) then 
				AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_SWITCH_POSITION",entity.id);
			elseif(targetType==AITARGET_SOUND or targetType==AITARGET_MEMORY) then 
				if(AI.GetLeader(entity.id)) then 
					g_SignalData.point.x = 0;
					g_SignalData.point.y = 0;
					g_SignalData.point.z = 0;
					g_SignalData.iValue = UPR_COMBAT_GROUND + UPR_COMBAT_RECON;
					g_SignalData.iValue2 = AIAnchorTable.SEARCH_SPOT;-- +AI_USE_HIDESPOTS if you want to include hidespots
					g_SignalData.fValue = 30; --search distance
					AI.Signal(SIGNALFILTER_LEADER,1,"ORD_SEARCH",entity.id,g_SignalData);
				else				
					AI.Signal(SIGNALFILTER_SENDER,0,"GRABBED_TO_INTERESTED",entity.id);
				end
			else
				AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_IDLE",entity.id);
			end
			entity.AI.JumpType = nil;
			entity:Readibility("dropped_call",1,100,0.3,0.7);
			
		end
	end,
	
	
	---------------------------------------------
	OnLandForced = function(self,entity,sender)
		AIBehaviour.TrooperGrabbedByScout:OnLand(entity,sender);
	end,
	
	---------------------------------------------
	REQUEST_CONVERSATION = function(self,entity,sender)
	end,
	
		--------------------------------------------------
	OnAttackSwitchPosition = function(self,entity,sender)
		local entityAI = entity.AI;
		entityAI.bShootingOnSpot = false;
		entityAI.bSwitchingPosition = true;
		entityAI.bSpecialAction = false;
		entityAI.bSearching = false;
	end,

	--------------------------------------------------
	OnSpecialAction = function(self,entity,sender)
		local entityAI = entity.AI;
		entityAI.bShootingOnSpot = false;
		entityAI.bSwitchingPosition = false;
		entityAI.bSpecialAction = true;
		entityAI.bSearching = false;
		
	end,
	
	--------------------------------------------------
	OnAttackShootSpot = function(self,entity,sender)
		local entityAI = entity.AI;
		entityAI.bShootingOnSpot = true;
		entityAI.bSwitchingPosition = false;
		entityAI.bSpecialAction = false;
		entityAI.bSearching = false;
	end,
	
	--------------------------------------------------
	ORDER_SEARCH  = function(self,entity,sender,data)
		local entityAI = entity.AI;
		entityAI.bShootingOnSpot = false;
		entityAI.bSwitchingPosition = false;
		entityAI.bSpecialAction = false;
		entityAI.bSearching = true;
		if(data) then 
			entityAI.point = {};
			entityAI.point2 = {};
			entityAI.iValue = data.iValue;
			CopyVector(entityAI.point,data.point);
			CopyVector(entityAI.point2,data.point2);
		end
	end,

	--------------------------------------------------
	ORDER_COVER_SEARCH  = function(self,entity,sender,data)
		self:ORDER_SEARCH(entity,sender,data);
	end,
}