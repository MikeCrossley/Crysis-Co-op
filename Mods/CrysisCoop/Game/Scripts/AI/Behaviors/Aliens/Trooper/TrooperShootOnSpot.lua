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
AIBehaviour.TrooperShootOnSpot = {
	Name = "TrooperShootOnSpot",
	Base = "TROOPERDEFAULT",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity,data)
		if(data and data.point) then 
			if(not entity.AI.spotPos) then
				entity.AI.spotPos = {};
			end
			CopyVector(entity.AI.spotPos,data.point);
		else
			AI.SetRefPointPosition(entity.id,entity.AI.spotPos);
		end
		entity.AI.spotReached = false;
		entity:SelectPipe(AIGOALPIPE_SAMEPRIORITY,"do_nothing");
		entity:SelectPipe(AIGOALPIPE_SAMEPRIORITY,"tr_goto_shoot_spot");
--		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then 
--			AI.ModifySmartObjectStates(entity.id,"SearchShootSpots,-ShootSpotFound");
--		end
	end,

	Destructor = function(self,entity)
--		AI.ModifySmartObjectStates(entity.id,"SearchShootSpots");
	end,
	
	OnPlayerSeen = function(self,entity,distance)
		if(Trooper_CheckJumpMeleeFromHighSpot(entity,distance)) then 
			return;
		end
		if(distance > 15) then 
			local target = AI.GetAttentionTargetEntity(entity.id);
			if(target) then 
				local navType = AI.GetNavigationType(target.id,UPR_COMBAT_GROUND);
				entity.AI.targetNavType = navType;
				if(navType == NAV_WAYPOINT_HUMAN ) then
					AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ATTACK",entity.id);
					return;
				end
			end
			-- no live target or no waypoint navigation
			-- apparently it's receiving OnPlayerSeen and there's no target entity?
			entity.AI.targetNavType = NAV_TRIANGULAR;
			if(entity.AI.usingMoar ) then
				AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_MOAR",entity.id);
			else
				AI.Signal(SIGNALFILTER_SENDER,0,"OnAttackSwitchPosition",entity.id);
			end
		else
			if(entity.AI.usingMoar ) then
				entity:SelectPipe(0,"tr_keep_position_moar");
			else
				entity:SelectPipe(0,"tr_keep_position");
			end
			--entity:InsertSubpipe(0,"start_fire");
		end
--		AI.ModifySmartObjectStates(entity.id,"-SearchShootSpots");
	end,

	OnEnemyMemory = function(self,entity,sender)
--		entity:SelectPipe(0,"tr_check_other_shoot_spots");
	end,
	
	OnNoTargetVisible = function(self,entity,sender)
		entity:Readibility("target_lost",1,0);
		entity:SelectPipe(0,"tr_check_other_shoot_spots");
	end,
	
	CHECK_NEW_SHOOT_SPOT = function(self,entity,sender)
--		AI.ModifySmartObjectStates(entity.id,"SearchShootSpots");
	end,
	
	OnPlayerLooking = function(self,entity,sender)
		
	end,
	
	OnLeaderActionFailed = function(self,entity,sender,data)
		Trooper_ChooseNextTactic(entity,data,true);
	end,

	OnLeaderActionCompleted = function(self,entity,sender,data)
		Trooper_ChooseNextTactic(entity,data,false);
	
	end,

	OnFormationPointReached = function( self, entity, sender )
	end,
	
	OnThreateningSoundHeard = function( self, entity, sender )

	end,

	OnInterestingSoundHeard = function( self, entity, sender )

	end,

	OnSomethingSeen = function( self, entity, distance )
	end,

	OnBulletRain = function( self, entity, sender,data )
--		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
	end,

	--------------------------------------------------
	OnBulletHit = function( self, entity, sender,data )
	end,

	
	OnNearMiss = function( self, entity, sender,data )
	end,

	OnEnemyDamage = function( self, entity, sender,data )
		if( Trooper_LowHealth(entity)) then 
			if(Trooper_CanRetreat(entity)) then 
				return;
			end
		end
		local curTime = _time;
		if(entity.AI.lastDamageTime==nil) then 
			entity.AI.lastDamageTime = curTime;
			return;
		end
		local timePassed = curTime - entity.AI.lastDamageTime;
		if( timePassed > 3 ) then
			if(not Trooper_JumpMelee(entity)) then 
				AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
			end
		end
	end,

	
	OnFriendlyDamage = function( self, entity, sender,data )
	end,
	
	StickPlayerAndShoot= function(self,entity,sender)
	
	end,
	
	GO_THREATEN = function(self,entity,sender)
	
	end,

	OnCloseContact= function(self,entity,target)
		local diff = entity:GetPos().z - target:GetPos().z;
		if(diff>-1 and diff<-1) then 
			if(entity.AI.spotReached) then 
				AIBehaviour.TrooperAttackSwitchPosition:OnCloseContact(entity,target); 
				Trooper_UpdateMoarStats(entity);
				entity.AI.firingMoar = false;
			end
		end
	end,

	--------------------------------------------------
	OnPathFound = function(self,entity,sender)
		--entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_check_prone");
	end,
	
	--------------------------------------------------
	OnLeaderDied = function(self,entity,sender)
		if(entity ~= sender and not AI.GetLeader(entity.id)) then 
			AI.SetLeader(entity.id);
		end
	end,
	
--	--------------------------------------------------
--	OnGroupMemberDiedNearest= function(self,entity,sender,data)
--		local leader = AI.GetLeader(entity.id);
--		if(sender == leader) then 
--			AI.SetLeader(entity.id);
--		end
--
--	end,
	
	--------------------------------------------------
	OnAvoidDanger = function(self,entity,sender,data)
		if(AI.GetNavigationType(entity.id) == NAV_TRIANGULAR) then 
			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"tr_avoid_danger");
--		AI.SetRefPointPosition(entity.id,data.point);
--		AI.SetPFBlockerRadius( entity.id, PFB_REF_POINT, 8);
		end
	end,

	--------------------------------------------------
	OnNavTypeChanged= function(self,entity,sender,data)

	end,

	--------------------------------------------------
	OnTargetNavTypeChanged= function(self,entity,sender,data)
		AIBehaviour.TrooperAttackSwitchPosition:OnTargetNavTypeChanged(entity,sender,data);
	end,
	
	--------------------------------------------------
	OnLand = function(self,entity,sender)
		entity.AI.JumpType = nil;
		local distSq = DistanceSqVectors(entity.AI.spotPos,entity:GetPos());
		-- check if 
		if(distSq>4) then 
			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
		end	
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_check_lower_target");
	end,
	
	--------------------------------------------------
	END_JUMP_ON_SPOT = function(self,entity,sender)
--		AI.ModifySmartObjectStates(entity.id,"-ShootSpotFound");
--		if(entity.AI.targetNavType == NAV_WAYPOINT_HUMAN ) then
--			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ATTACK",entity.id);
--		else
--			AI.Signal(SIGNALFILTER_SENDER,0,"OnAttackSwitchPosition",entity.id);
--		end
		if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ATTACK",entity.id);
		else
			entity:SelectPipe(0,"tr_seek_target");
		end
		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
	end,

	--------------------------------------------------
	END_MELEE = function( self, entity, sender)
		entity.AI.spotReached = false;
		entity:SelectPipe(0,"tr_goto_shoot_spot");
	end,	

	--------------------------------------------------
	MELEE_FAILED = function( self, entity, sender)
		entity.AI.spotReached = false;
		entity:SelectPipe(0,"tr_goto_shoot_spot");
	  AIBlackBoard.lastTrooperMeleeTime = _time;
	end,	
	
	--------------------------------------------------
	MELEE_OK = function( self, entity, sender)
		if(Trooper_CheckMeleeFinal(entity)) then 
			return;
		end
		entity.AI.spotReached = false;
		entity:SelectPipe(0,"tr_goto_shoot_spot");
	end,	

	--------------------------------------------------
	SPOT_REACHED = function(self,entity,sender)
		entity.AI.spotReached = true;
	end,

	--------------------------------------------------
	IS_PLAYER_ENGAGED = function(self,entity,sender)
		if(AI.GetGroupOf(entity.id) ~= AI.GetGroupOf(sender.id)) then 
			AI.Signal(SIGNALFILTER_GROUPONLY, 0,"PLAYER_ENGAGED",sender.id);
		end
	end,

	--------------------------------------------------
	JUMP_ON_WALL = function(self,entity,sender,data)
			AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,

	--------------------------------------------------
	LOOK_CLOSER= function(self,entity,sender,data)
	end,

}
