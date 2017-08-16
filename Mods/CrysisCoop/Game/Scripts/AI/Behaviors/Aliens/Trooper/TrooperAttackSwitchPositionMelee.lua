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


AIBehaviour.TrooperAttackSwitchPositionMelee = {
	Name = "TrooperAttackSwitchPositionMelee",
	Base = "TrooperAttackSwitchPosition",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity,data)
--		AI.Signal(SIGNALFILTER_SUPERSPECIES, 0,"IS_PLAYER_ENGAGED",entity.id);
		if(data and data.iValue==1) then 
			entity.AI.canDodge = false;
		else
			entity.AI.canDodge = true;
		end
		entity.AI.lastHealthDamaged = entity.actor:GetHealth();
	end,

	--------------------------------------------------
	Destructor = function(self,entity)
--		AI.ModifySmartObjectStates(entity.id,"-SearchShootSpots");				
		entity.AI.lastHealthDamaged = nil;
	end,
	
	--------------------------------------------------
	OnEnemyDamage = function(self,entity,sender,data) 
		if(not entity.AI.canDodge) then 
			return;
		end
		local health = entity.actor:GetHealth();
		if(not entity.AI.lastHealthDamaged) then
			entity.AI.lastHealthDamaged  = health;
--			return;
		end
		if(entity.AI.lastHealthDamaged - health > 200) then
			entity.AI.lastHealthDamaged = health;
			if(not Trooper_CheckJumpToFormationPoint(entity)) then 
				if( Trooper_Dodge(entity)) then 
					AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_DODGE",entity.id);
					return;
				end
			end
--			AI.Signal(SIGNALFILTER_SENDER,1,"MELEE_FAILED",entity.id);
		end
					
	end,

	--------------------------------------------------
	OnBulletHit = function( self, entity, sender,data )
	end,


	--------------------------------------------------
	OnPlayerSeen = function(self,entity,sender)
	end,
	
	--------------------------------------------------
	OnPlayerLooking = function(self,entity,sender)
	
	end,

	--------------------------------------------------
	OnBulletRain	= function(self,entity,target,data)
	
	end,

	--------------------------------------------------
	OnNearMiss	= function(self,entity,target)
	
	end,
	
	--------------------------------------------------
	OnCloseContact= function(self,entity,target)
	end,

	--------------------------------------------------
	OnNoTargetVisible = function(self,entity,target)
		AI.Signal(SIGNALFILTER_SENDER,1,"MELEE_FAILED",entity.id);
	end,
	
	--------------------------------------------------
	OnNoTarget = function(self,entity,target)
		AI.Signal(SIGNALFILTER_SENDER,1,"MELEE_FAILED",entity.id);
	end,
		
	--------------------------------------------------
	OnNoTargetAwareness = function(self,entity,target)
		AI.Signal(SIGNALFILTER_SENDER,1,"MELEE_FAILED",entity.id);
	end,
	
	--------------------------------------------------
	OnEnemyMemory = function(self,entity,target)
		AI.Signal(SIGNALFILTER_SENDER,1,"MELEE_FAILED",entity.id);
	end,
	
	--------------------------------------------------
	MELEE_OK = function( self, entity, sender)
		if(Trooper_CheckMeleeFinal(entity)) then 
			return;
		end
		AI.Signal(SIGNALFILTER_SENDER,1,"MELEE_FAILED",entity.id);
	end,
	
	--------------------------------------------------
	MELEE_FAILED = function( self, entity, sender)
--		if(not Trooper_CheckJumpToFormationPoint(entity,8)) then 
--			AI.ModifySmartObjectStates(entity.id,"StayOnGround");
--			entity:SelectPipe(0,"tr_attack_switch_position");
--		end
	end,
		
	--------------------------------------------------
	END_MELEE = function( self, entity, sender)
	  AIBlackBoard.lastTrooperMeleeTime = _time;
--		if(not Trooper_CheckJumpToFormationPoint(entity,8)) then 
--			AI.ModifySmartObjectStates(entity.id,"StayOnGround");
--			entity:SelectPipe(0,"tr_attack_switch_position");
--		end
	end,
	
	--------------------------------------------------
	OnPathFound = function(self,entity,sender)
		--entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_check_prone");
			entity:PlayAccelerationSound();
	end,
	
	--------------------------------------------------
	OnBehind = function(self,entity,sender,data)
		entity.AI.bBehind = true;
	end,
	
	--------------------------------------------------
	OnTargetNavTypeChanged = function(self,entity,sender,data)
		local targetNavType = data.iValue2;
	end,
	
	
	--------------------------------------------------
	OnLand = function(self,entity,sender)
		entity.AI.JumpType = nil;
	end,
	
	--------------------------------------------------
	JUMP_ON_ROCK = function (self,entity,sender,data)
			AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,

	--------------------------------------------------
	JUMP_ON_WALL = function (self,entity,sender,data)
			AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,

	--------------------------------------------------
	OnAttackSwitchPosition = function (self,entity,sender,data)
	end,
	--------------------------------------------------
	OnAttackShootSpot = function (self,entity,sender,data)
	end,
	
	--------------------------------------------------
	STAY_AWAY_FROM 	 = function (self,entity,sender,data)
		if(entity.AI.canDodge) then 
			AIBehaviour.TrooperAttackSwitchPosition:STAY_AWAY_FROM(entity,sender,data);
		end
	end,

	--------------------------------------------------
	LOOK_CLOSER= function(self,entity,sender,data)
	end,

}
