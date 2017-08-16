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
AIBehaviour.TrooperShootOnWall = {
	Name = "TrooperShootOnWall",
	Base = "TrooperShootOnRock",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity,data)
		entity.AI.landTime = _time;

		-- increase accuracy - a lott
		Trooper_SetAccuracy(entity,100);
		-- TO DO: use the proper parameter (aggression?)
		
		entity.AI.bSwitchingPosition = false;
		entity.AI.bShootingOnSpot = false;
		entity.AI.noDamageImpulse = true;
		entity.AI.landed = false;
		entity.AI.endBehavior = false;
		AI.ModifySmartObjectStates(entity.id,"Busy");
	end,

	--------------------------------------------------
	Destructor = function(self,entity)
--		entity:InsertSubpipe(0,"tr_end_animation");
--		AI.SetStance(entity.id,BODYPOS_STAND);
		AI.ModifySmartObjectStates(entity.AI.spotEntityId,"KeepBusyFewSec");
		AI.ModifySmartObjectStates(entity.id,"-Busy");
		-- restore accuracy
		-- TO DO: use the proper parameter (aggression?)
		Trooper_SetAccuracy(entity);
		entity.AI.noDamageImpulse = false;
	end,
	
	--------------------------------------------------
	OnPlayerSeen = function(self,entity,distance)
	end,

	--------------------------------------------------
	OnEnemyMemory = function(self,entity,sender)

	end,

	--------------------------------------------------
	OnNoTargetVisible = function(self,entity,sender)
		entity:Readibility("target_lost",1,0);
		if(entity.AI.landed) then 
			self:EndBehaviour(entity);
		end
	end,
	
	--------------------------------------------------
	OnTankSeen = function(self,entity,sender)
		entity:SelectPipe(0,"tr_prepare_special_action");
		entity.AI.noDamageImpulse = false;
		entity.AI.endBehavior = true;
	end,
	
--	CHECK_NEW_SHOOT_SPOT = function(self,entity,sender)
--		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
--	end,
	
--	OnAttackSwitchPosition = function(self,entity,sender)
--		if(_time - entity.AI.landTime >5) then 		
--			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_SWITCH_POSITION",entity.id);
--		else
--			entity.AI.bSwitchingPosition = true;
--		end
--	end,
	
	--------------------------------------------------
	OnPlayerLooking = function(self,entity,sender)
		
	end,
	
	--------------------------------------------------
	OnLeaderActionFailed = function(self,entity,sender,data)
		Trooper_ChooseNextTactic(entity,data,true);
	end,

	--------------------------------------------------
	OnLeaderActionCompleted = function(self,entity,sender,data)
		Trooper_ChooseNextTactic(entity,data,false);
	
	end,

	--------------------------------------------------
	OnFormationPointReached = function( self, entity, sender )
	end,
	
	--------------------------------------------------
	OnThreateningSoundHeard = function( self, entity, sender )

	end,

	--------------------------------------------------
	OnInterestingSoundHeard = function( self, entity, sender )

	end,

	--------------------------------------------------
	OnSomethingSeen = function( self, entity, distance )
	end,

	--------------------------------------------------
	OnBulletRain = function( self, entity, sender,data )
--		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
	end,
	--------------------------------------------------
	OnBulletHit = function( self, entity, sender,data )
	end,

	
	--------------------------------------------------
	OnNearMiss = function( self, entity, sender,data )
	end,

	--------------------------------------------------
	OnEnemyDamage = function( self, entity, sender,data )
		if( Trooper_LowHealth(entity)) then 
			local dist = AI.GetAttentionTargetDistance(entity.id) or 0;
			if( dist<16) then
				g_SignalData.iValue = -AI_BACKOFF_FROM_TARGET;
				g_SignalData.fValue = 10;
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
			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
		end
	end,

	
	--------------------------------------------------
	OnFriendlyDamage = function( self, entity, sender,data )
	end,
	
	--------------------------------------------------
	StickPlayerAndShoot= function(self,entity,sender)
	
	end,
	
	--------------------------------------------------
	GO_THREATEN = function(self,entity,sender)
	
	end,

	
	--------------------------------------------------
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
	
	---------------------------------------------
	OnActionDone = function( self, entity, data )
		-- called after finishing any AI action for which this agent was "the user"
		--
		-- data.ObjectName is the action name
		-- data.iValue is 0 if action was canceled or 1 if it was finished normally
		-- data.id is the entity id of "the object" of AI action
--		if(data and data.iValue==0) then
--			self:EndBehaviour(entity);
--		end
		if(data.iValue==1) then
			-- success
			if(entity.AI.usingMoar) then 
				entity.AI.firingMoar = true;
				entity:SelectPipe(AIGOALPIPE_DONT_RESET_AG,"tr_shoot_on_wall_moar");
			else
				entity:SelectPipe(AIGOALPIPE_DONT_RESET_AG,"tr_shoot_on_wall");
			end	
		else
			self:EndBehaviour(entity,true);
		end
		
	end,

	--------------------------------------------------
--	OnAnimTargetReached = function( self, entity, sender )
--			if(entity.AI.usingMoar) then 
--				entity.AI.firingMoar = true;
--				entity:SelectPipe(AIGOALPIPE_DONT_RESET_AG,"tr_shoot_on_wall_moar");
--			else
--				entity:SelectPipe(AIGOALPIPE_DONT_RESET_AG,"tr_shoot_on_wall");
--			end	
--	end,

	--------------------------------------------------
	CANCEL_CURRENT= function( self, entity )
		AIBehaviour.DEFAULT:CANCEL_CURRENT(entity);
		self:EndBehaviour(entity);
		
	end,

	
	--------------------------------------------------
	OnAvoidDanger = function(self,entity,sender,data)
		-- TO DO
--		if(AI.GetNavigationType(entity.id) == NAV_TRIANGULAR) then 
--			entity:SelectPipe(0,"do_nothing");
--			entity:SelectPipe(0,"tr_avoid_danger");
--		end
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
	OnLand = function(self,entity,sender)
	end,
	
	--------------------------------------------------
	END_SHOOT_ON_WALL = function( self, entity, sender)
		if(entity.Properties.bIndoor ==0 and AI.GetTargetType(entity.id)==AITARGET_ENEMY) then 
			self:EndBehaviour(entity);
		end
	end,
	
	--------------------------------------------------
	END_SHOOT_ON_WALL_MOAR = function( self, entity, sender)
		AIBehaviour.TrooperShootOnWall:END_SHOOT_ON_WALL(entity,sender);
		Trooper_UpdateMoarStats(entity);
	end,

	--------------------------------------------------
	END_MELEE = function( self, entity, sender)
	end,	
	
	--------------------------------------------------
	MELEE_FAILED = function( self, entity, sender)
	end,	

	--------------------------------------------------
	MELEE_OK = function( self, entity, sender)
	end,

	--------------------------------------------------
	IS_PLAYER_ENGAGED = function(self,entity,sender)
		if(AI.GetGroupOf(entity.id) ~= AI.GetGroupOf(sender.id)) then 
			AI.Signal(SIGNALFILTER_GROUPONLY, 0,"PLAYER_ENGAGED",sender.id);
		end
	end,

	
--	--------------------------------------------------
--	OnAttackSpecialAction = function(self,entity,sender)
--		-- just refuse to do it
--		if(_time - entity.AI.landTime >5) then 		
--			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_SPECIAL_ACTION",entity.id);
--		else
--			AI.Signal(SIGNALFILTER_LEADER,10,"OnSpecialActionDone",entity.id);
--		end
--	end,
--	
--	--------------------------------------------------
--	OnAttackShootSpot = function(self,entity,sender)
--		if(_time - entity.AI.landTime >5) then 		
--			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_SHOOT_SPOT",entity.id);
--		else
--			entity.AI.bShootingOnSpot = true;
--		
--		end
--	end,

	ON_WALL = function(self,entity,sender)
		if(AI.GetTargetType(entity.id)~=AITARGET_ENEMY) then 
			self:EndBehaviour(entity,true);
		end
		entity.AI.landed = true;
		entity.AI.landTime = _time;
	end,

	--------------------------------------------------
	JUMP_ON_ROCK = function(self,entity,sender,data)
			AI.ModifySmartObjectStates(data.id,"-Busy");				
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
				if(entity.AI.bShootingOnSpot) then
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
	LOOK_CLOSER= function(self,entity,sender,data)
	end,
	
	--------------------------------------------------
	TARGET_LOST = function(self,entity,sender,data)
		self:EndBehaviour(entity,sender);
	end,
	
}
