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
AIBehaviour.TrooperShootOnRock = {
	Name = "TrooperShootOnRock",
	Base = "TROOPERDEFAULT",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity,data)
		entity.AI.landed = false;
		entity:SelectPipe(AIGOALPIPE_DONT_RESET_AG,"do_nothing");
--		if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then 
--			entity:SelectPipe(0,"tr_shoot_on_rock");
--		else
--			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
--			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK",entity.id);
--			entity:SelectPipe(0,"tr_seek_target");
--			
--		end
		Trooper_SetJumpTimeout(entity);
		-- increase accuracy - a lott
		Trooper_SetAccuracy(entity,100);
		-- TO DO: use the proper parameter (aggression?)
		
		entity.AI.landed = false;
		entity.AI.noDamageImpulse = true;
		AI.SetStance(entity.id,BODYPOS_CROUCH);
		AI.ModifySmartObjectStates(entity.id,"Busy");
		entity.AI.bShootingOnSpot = false;
		entity.AI.bSwitchingPosition = false;
		entity.AI.endBehavior = false;

	end,

	Destructor = function(self,entity)
		AI.SetStance(entity.id,BODYPOS_STAND);
		AI.ModifySmartObjectStates(entity.AI.spotEntityId,"KeepBusyFewSec");
		AI.ModifySmartObjectStates(entity.id,"-Busy");
		-- restore accuracy
		-- TO DO: use the proper parameter (aggression?)
		Trooper_SetAccuracy(entity);
		entity.AI.noDamageImpulse = false;
		entity.AI.bShootingOnSpot = false;
		entity.AI.bSwitchingPosition = false;
	end,
	
	OnPlayerSeen = function(self,entity,distance)
		if(entity.AI.landed and not entity.AI.endBehavior) then 
			if(entity.AI.usingMoar) then 
				entity.AI.firingMoar = true;
				entity:SelectPipe(AIGOALPIPE_DONT_RESET_AG,"tr_shoot_on_rock_moar");
			else
				entity:SelectPipe(AIGOALPIPE_DONT_RESET_AG,"tr_shoot_on_rock");
			end			
			entity:InsertSubpipe(0,"tr_start_fire_continuous");
		end
	end,

	OnEnemyMemory = function(self,entity,sender)
--		if(entity.AI.landed) then 
--			entity:SelectPipe(0,"tr_end_stay_on_rock_timeout");
--			if(not entity.AI.usingMoar) then 
--				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"start_fire");
--				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"short_timeout");
--				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"stop_fire");
--			end
--		end
	end,

	OnNoTargetVisible = function(self,entity,sender)
		entity:Readibility("target_lost",1,0);
		if(entity.AI.landed) then 
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_SWITCH_POSITION",entity.id);
--			AIBehaviour.TrooperShootOnRock:END_SHOOT_ON_ROCK(entity,sender);
		end
	end,
	
	
--	CHECK_NEW_SHOOT_SPOT = function(self,entity,sender)
--		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
--	end,
	
	
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
			local dist = AI.GetAttentionTargetDistance(entity.id) or 0;
			if( dist<16) then
				g_SignalData.iValue = -AI_BACKOFF_FROM_TARGET;
				g_SignalData.fValue = 8;
				AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id, g_SignalData);
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
			if(not Trooper_DoubleJumpMelee(entity)) then 
				AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
			else
				self:EndBehaviour(entity);
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
		if(entity.AI.landed) then 
			self:EndBehaviour(entity);
			Trooper_UpdateMoarStats(entity);
			entity.AI.firingMoar = false;
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
		end
--		AI.SetRefPointPosition(entity.id,data.point);
--		AI.SetPFBlockerRadius( entity.id, PFB_REF_POINT, 8);
	end,

	--------------------------------------------------
	OnNavTypeChanged= function(self,entity,sender,data)

	end,

	--------------------------------------------------
	OnTargetNavTypeChanged= function(self,entity,sender,data)
		AIBehaviour.TrooperAttackSwitchPosition:OnTargetNavTypeChanged(entity,sender,data);
	end,
	
	--------------------------------------------------
	OnLand = function(self,entity,sender,data)
		entity.AI.landed = true;
		entity.AI.landTime = _time;
		if(entity.AI.JumpType == TROOPER_JUMP_MELEE) then 
			-- after a jumpMelee
			self:EndBehaviour(entity,true);
		else
--			local dist = DistanceVectors(entity:GetPos(),entity.AI.jumpPos);
--			if(dist>1) then
			if(data and data.iValue==1) then
				entity:SelectPipe(0,"tr_prepare_switch_position");
				entity.AI.noDamageImpulse = false;
				entity.AI.endBehavior = true;
				return;
			end
			
				-- landed somewhere else by accident
				
			entity:SelectPipe(AIGOALPIPE_DONT_RESET_AG,"do_nothing");
			if(entity.AI.usingMoar) then 
				entity:SelectPipe(AIGOALPIPE_DONT_RESET_AG,"tr_shoot_on_rock_moar");
				entity.AI.firingMoar = true;
			else
				entity:SelectPipe(AIGOALPIPE_DONT_RESET_AG,"tr_shoot_on_rock");
			end			
		end
		entity.AI.JumpType = nil;
	end,
	
	--------------------------------------------------
	END_SHOOT_ON_ROCK = function( self, entity, sender)
--		if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then 
		local dist = AI.GetAttentionTargetDistance(entity.id);
			if(dist==nil or dist  > 15) then 
			-- else keep on staying and shooting
				self:EndBehaviour(entity);
			end
--		else
--			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
--			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK",entity.id);
--			entity:SelectPipe(0,"tr_seek_target");
--		end
	end,
	
	--------------------------------------------------
	END_SHOOT_ON_ROCK_MOAR = function( self, entity, sender)
		AIBehaviour.TrooperShootOnRock:END_SHOOT_ON_ROCK(entity,sender);
		Trooper_UpdateMoarStats(entity);
	end,

	--------------------------------------------------
	END_MELEE = function( self, entity, sender)
		self:EndBehaviour(entity);
	end,	
	
	--------------------------------------------------
	MELEE_FAILED = function( self, entity, sender)
		self:EndBehaviour(entity);
	  AIBlackBoard.lastTrooperMeleeTime = curTime;
	end,	

	--------------------------------------------------
	MELEE_OK = function( self, entity, sender)
		local target = AI.GetAttentionTargetEntity(entity.id,true);
	  AIBlackBoard.lastTrooperMeleeTime = curTime;
		if(target) then 
			local diffz = entity:GetPos().z - target:GetPos().z;
			if(diffz>-1.5 and diffz<1.5) then 
				local targetSpeed = target:GetSpeed();
				local targetVel = g_Vectors.temp;
				target:GetVelocity(targetVel);
				ScaleVectorInPlace(targetVel, 1/targetSpeed);--normalize
				local dot = dotproduct3d(targetVel,entity:GetDirectionVector(1));
				if(targetSpeed< 1 or dot < -0.5) then 
				  entity:SelectPipe(0,"tr_melee_timeout");
				  entity:MeleeAttack(target);
				  return;
				end
			end
		end
	end,

	--------------------------------------------------
	IS_PLAYER_ENGAGED = function(self,entity,sender)
		if(AI.GetGroupOf(entity.id) ~= AI.GetGroupOf(sender.id)) then 
			AI.Signal(SIGNALFILTER_GROUPONLY, 0,"PLAYER_ENGAGED",sender.id);
		end
	end,

	--------------------------------------------------
	OnAttackSpecialAction = function(self,entity,sender)
		-- just refuse to do it
		if(entity.AI.landed and (_time - entity.AI.landTime >3)) then 		
			entity:SelectPipe(0,"tr_prepare_special_action");
			entity.AI.noDamageImpulse = false;
			entity.AI.endBehavior = true;
		else
			AI.Signal(SIGNALFILTER_LEADER,10,"OnSpecialActionDone",entity.id);
		end
	end,

	--------------------------------------------------
	OnAttackSwitchPosition = function(self,entity,sender)
		if(entity.AI.landed and (_time - entity.AI.landTime >3)) then 		
			entity:SelectPipe(0,"tr_prepare_switch_position");
			entity.AI.noDamageImpulse = false;
			entity.AI.endBehavior = true;
--		else
--			entity.AI.bSwitchingPosition = true;
		end
		entity.AI.bSwitchingPosition = true;
	end,

	--------------------------------------------------
	OnTankSeen = function(self,entity,sender)
		entity:SelectPipe(0,"tr_prepare_special_action");
		entity.AI.noDamageImpulse = false;
		entity.AI.endBehavior = true;
	end,
	
	--------------------------------------------------
	OnAttackShootSpot = function(self,entity,sender)
		if(entity.AI.landed and (_time - entity.AI.landTime >3)) then 		
			entity:SelectPipe(0,"tr_prepare_shoot_spot");
			entity.AI.noDamageImpulse = false;
			entity.AI.endBehavior = true;
--		else
--			entity.AI.bShootingOnSpot = true;
		end
		entity.AI.bShootingOnSpot = true;
	end,
	
	--------------------------------------------------
	EndBehaviour = function(self,entity,immediate)
		if(AI.GetLeader(entity.id)) then 
			if(immediate) then 
				if(entity.AI.bShootingOnspot) then
					AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_SHOOT_SPOT",entity.id);
				else
					AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_SWITCH_POSITION",entity.id);
				end
			else
				AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
			end
		else
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK",entity.id);
		end
	end,

	--------------------------------------------------
	JUMP_ON_WALL = function(self,entity,sender,data)
			AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,
	
}
