--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Attack behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 4/12/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperAttackMoar = {
	Name = "TrooperAttackMoar",
	Base = "TROOPERDEFAULT",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity)
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"tr_attack_switch_position_moar");
		Trooper_SetAccuracy(entity,2);
	end,

	OnPlayerSeen = function(self,entity,distance)
		
	end,

	OnEnemyMemory = function(self,entity,sender)
	end,
	
	OnNoTargetVisible = function(self,entity,sender)
			g_SignalData.iValue = AI_BACKOFF_FROM_TARGET;
			g_SignalData.fValue = 10;
			g_SignalData.iValue2 = 0;
			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id,g_SignalData);
	end,
	
	OnPlayerLooking = function(self,entity,sender)
		if(not entity.AI.firingMoar and not g_localActor.actorStats.isFrozen ) then
			if(entity:GetDistance(g_localActor.id) > entity.melee.damageRadius+1) then 
		
				if( Trooper_Dodge(entity)) then 
					AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_DODGE",entity.id);
					return;
				end
			end
			g_SignalData.iValue = AI_BACKOFF_FROM_TARGET;
			g_SignalData.fValue = 10;
			g_SignalData.iValue2 = 0;
			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id,g_SignalData);
		end
	end,
	
	OnLeaderActionFailed = function(self,entity,sender,data)
		AIBehaviour.TrooperAttackSwitchPosition:OnLeaderActionFailed(entity,sender,data);
	end,

	OnLeaderActionCompleted = function(self,entity,sender,data)
		AIBehaviour.TrooperAttackSwitchPosition:OnLeaderActionCompleted(entity,sender,data);
	end,

	OnThreateningSoundHeard = function( self, entity, sender )

	end,

	OnInterestingSoundHeard = function( self, entity, sender )

	end,

	OnSomethingSeen = function( self, entity, distance )
	end,

	OnBulletRain = function( self, entity, sender,data )
--		g_SignalData.iValue = AI_BACKOFF_FROM_TARGET;
--		g_SignalData.fValue = 10;
--		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
		if(AI.Hostile(entity.id,data.id)) then 
			self:OnEnemyDamage(entity,sender,data);
		end
	end,
	
	OnNearMiss = function( self, entity, sender,data )
		if(AI.Hostile(entity.id,data.id)) then 
			self:OnEnemyDamage(entity,sender,data);
		end
	end,

	OnEnemyDamage = function( self, entity, sender,data )
		AI.ModifySmartObjectStates(entity.id,"-StayOnGround");
		if( Trooper_LowHealth(entity)) then 
			if(Trooper_CanRetreat(entity)) then 
				entity.AI.firingMoar = false;
				return;
			end
		end
		if(not entity.AI.firingMoar) then 
			local target = AI.GetAttentionTargetEntity(entity.id);
			if( target == nil  or AI.GetAttentionTargetDistance(entity.id)>5) then
				if( Trooper_Dodge(entity)) then 
					AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_DODGE",entity.id);
					entity.AI.firingMoar = true;
					return;
				end
			end
		end
--		g_SignalData.iValue = 0;
--		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
	end,

	--------------------------------------------------
--	OnAttackSwitchPosition = function(self,entity,sender)
--		if(entity.AI.firingMoar) then 
--			entity.AI.bSwitchingPosition = true;
--		else
--			entity:SelectPipe(0,"do_nothing");
--			entity:SelectPipe(0,"tr_attack_switch_position_moar");
--		end
--	end,
	
	--------------------------------------------------
	OnAttackShootSpot = function(self,entity,sender,data)
		if(data and data.point) then 
			entity.AI.bShootingOnSpot = true;
			if(not entity.AI.spotPos) then
				entity.AI.spotPos = {};
			end
			CopyVector(entity.AI.spotPos,data.point);
--		if(entity.AI.firingMoar) then 
--		else
--			entity:SelectPipe(0,"do_nothing");
--			entity:SelectPipe(0,"tr_attack_switch_position_moar");
--		end
		end
	end,
	
	--------------------------------------------------
	OnSpecialAction = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_LEADER,10,"OnSpecialActionDone",entity.id);
				
	end,
	
	--------------------------------------------------
	OnLand = function(self,entity,sender)
		if(entity.AI.JumpType == TROOPER_JUMP_SWITCH_POSITION) then 
			AI.ModifySmartObjectStates(entity.id,"StayOnGround");

			entity:SelectPipe(0,"tr_attack_switch_position_moar");
		elseif(entity.AI.JumpType == TROOPER_JUMP_FIRE) then 
			AI.ModifySmartObjectStates(entity.id,"StayOnGround");
			entity:SelectPipe(0,"tr_attack_switch_position_moar");
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"stop_fire");
		else
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_check_lower_target");
		end
		entity.AI.JumpType = nil;
	end,


	OnFriendlyDamage = function( self, entity, sender,data )
	end,
	
	StickPlayerAndShoot= function(self,entity,sender)
	
	end,
	
	GO_THREATEN = function(self,entity,sender)
	
	end,

	OnCloseContact= function(self,entity,target)

		if(Trooper_CloseContactChoice(entity,target,1)) then
			-- trooper is either doing melee or jumping away
			Trooper_UpdateMoarStats(entity);
			entity.AI.firingMoar = false;
		end
	end,

	--------------------------------------------------
	OnPathFound = function(self,entity,sender)
		if(entity:IsUsingPipe("tr_attack_switch_position_moar")) then 
			entity:PlayAccelerationSound();
		end
	end,
	
	--------------------------------------------------
	OnLeaderDied = function(self,entity,sender)
		if(entity ~= sender and not AI.GetLeader(entity.id)) then 
			AI.SetLeader(entity.id);
		end
	end,
	

	--------------------------------------------------
	OnAvoidDanger = function(self,entity,sender,data)
		if(AI.GetNavigationType(entity.id) == NAV_TRIANGULAR) then 
			entity:SelectPipe(0,"do_nothing");
			Trooper_UpdateMoarStats(entity);
			entity:SelectPipe(0,"tr_avoid_danger");
			entity.AI.firingMoar = false;
		end
--		AI.SetRefPointPosition(entity.id,data.point);
--		AI.SetPFBlockerRadius( entity.id, PFB_REF_POINT, 8);
	end,

	--------------------------------------------------
	END_MOAR = function(self,entity,sender)
--		local targettype = AI.GetTargetType(entity.id);
--		if(targettype==AITARGET_ENEMY) then 
--			local target = AI.GetAttentionTargetEntity(entity.id);
--			if(target and (target.actorStats.isFrozen or entity:GetDistance(target.id)<6)) then 
--				entity:SelectPipe(0,"tr_approach_target_timeout");
--				return;
--			end
--		end
--		g_SignalData.iValue = AI_BACKOFF_FROM_TARGET;
--		g_SignalData.fValue = 10;
		Trooper_UpdateMoarStats(entity);
		if(entity.AI.bShootingOnSpot) then 
			AI.Signal(SIGNALFILTER_SENDER, 0,"GO_TO_ON_SPOT",entity.id);
		else
			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"tr_attack_switch_position_moar");
		end
		entity.AI.firingMoar = false;
		entity.AI.bShootingOnSpot = false;
		entity.AI.bSwitchingPosition = false;
		
--		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id,g_SignalData);
	end,
	
	--------------------------------------------------
	OnAttackSwitchPosition = function(self,entity,sender)
--		if(not entity.AI.firingMoar) then 
--			if(not Trooper_CheckJumpToFormationPoint(entity,8)) then 
--				AI.ModifySmartObjectStates(entity.id,"StayOnGround");
--				entity:SelectPipe(0,"do_nothing");
--				entity:SelectPipe(0,"tr_attack_switch_position_moar");
--				--entity.AI.firingMoar = false;
--			end
--		end
	end,
	
	--------------------------------------------------
	OnTargetNavTypeChanged= function(self,entity,sender,data)
		AIBehaviour.TrooperAttackSwitchPosition:OnTargetNavTypeChanged(entity,sender,data);
	end,
	
	--------------------------------------------------
	MELEE_OK = function( self, entity, sender)
		if(Trooper_CheckMeleeFinal(entity)) then 
			Trooper_UpdateMoarStats(entity);
			entity.AI.firingMoar = false;
			return;
		end
		if(not Trooper_CheckJumpToFormationPoint(entity,8)) then 
			AI.ModifySmartObjectStates(entity.id,"StayOnGround");
			entity:SelectPipe(0,"tr_attack_switch_position_moar");
			Trooper_UpdateMoarStats(entity);
			entity.AI.firingMoar = false;

		end
		entity.AI.bGoingToShatterPlayer = false;

	end,
	
	--------------------------------------------------
	MELEE_FAILED = function( self, entity, sender)
	  AIBlackBoard.lastTrooperMeleeTime = _time;
		if(not Trooper_CheckJumpToFormationPoint(entity,8)) then 
			AI.ModifySmartObjectStates(entity.id,"StayOnGround");
			Trooper_UpdateMoarStats(entity);
			entity:SelectPipe(0,"tr_attack_switch_position_moar");
			entity.AI.firingMoar = false;

		end
		entity.AI.bGoingToShatterPlayer = false;
	end,

	--------------------------------------------------
	END_MELEE = function( self, entity, sender)
		if(not Trooper_CheckJumpToFormationPoint(entity,8)) then 
			AI.ModifySmartObjectStates(entity.id,"StayOnGround");
			Trooper_UpdateMoarStats(entity);
			entity:SelectPipe(0,"tr_attack_switch_position_moar");
			entity.AI.firingMoar = false;

		end
	end,
	
	--------------------------------------------------
	IS_PLAYER_ENGAGED = function(self,entity,sender)
		if(AI.GetGroupOf(entity.id) ~= AI.GetGroupOf(sender.id)) then 
			AI.Signal(SIGNALFILTER_GROUPONLY, 0,"PLAYER_ENGAGED",sender.id);
		end
	end,
	
		
}
