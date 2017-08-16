--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Trooper dodges shoots 
--  
--------------------------------------------------------------------------
--  History:
--  - 12/1/2006     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperDodge = {
	Name = "TrooperDodge",
	Base = "TROOPERDEFAULT",
	alertness = 2,
	
	--------------------------------------------------
	Constructor = function(self,entity)
		entity:PlayAccelerationSound();
	end,
	
	Destructor = function(self,entity)
		if(Trooper_LowHealth(entity)) then 
			if(Trooper_CanRetreat(entity)) then 
				return;
			end
		end

		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
	end,
	
	---------------------------------------------
	OnEnemyDamage = function(self,entity,sender,data)
		if(Trooper_LowHealth(entity)) then 
			if(Trooper_CanRetreat(entity)) then 
				return;
			end
		end
	end,
	
	OnBulletRain = function(self,entity,sender,data)
	end,
	
	OnNearMiss = function(self,entity,sender,data)
	end,
	
	OnCloseContact = function(self,entity,sender)
	end,
	
	--------------------------------------------------
	JUMP_ON_ROCK = function(self,entity,sender,data)
			AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,

	--------------------------------------------------
	JUMP_ON_WALL = function(self,entity,sender,data)
			AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,

	--------------------------------------------------
	OnBulletHit = function( self, entity, sender,data )
	end,


	--------------------------------------------------
	IS_PLAYER_ENGAGED = function(self,entity,sender)
		if(AI.GetGroupOf(entity.id) ~= AI.GetGroupOf(sender.id)) then 
			AI.Signal(SIGNALFILTER_GROUPONLY, 0,"PLAYER_ENGAGED",sender.id);
		end
	end,
	
	--------------------------------------------------
	OnTargetNavTypeChanged= function(self,entity,sender,data)
		AIBehaviour.TrooperAttackSwitchPosition:OnTargetNavTypeChanged(entity,sender,data);
	end,
	-------------------------------------------
	
	-- to do: melee during dodge should not happen?
	MELEE_OK = function(self,entity,sender)
	  AIBlackBoard.lastTrooperMeleeTime = _time;
		local target = AI.GetAttentionTargetEntity(entity.id,true);
		if(target) then 
			local diffz = entity:GetPos().z - target:GetPos().z;
			if(diffz>-1.5 and diffz<1.5) then 
				local targetSpeed = target:GetSpeed();
				if(targetSpeed< 1) then 
	--			  AIBlackBoard.lastTrooperMeleeTime = curTime;
				  entity:SelectPipe(0,"tr_melee_timeout");
				  entity:MeleeAttack(target);
				  return;
				end
				local targetVel = g_Vectors.temp;
				target:GetVelocity(targetVel);
				ScaleVectorInPlace(targetVel, 1/targetSpeed);--normalize
				local dot = dotproduct3d(targetVel,entity:GetDirectionVector(1));
				if(dot < -0.5) then 
	--			  AIBlackBoard.lastTrooperMeleeTime = curTime;
				  entity:SelectPipe(0,"tr_melee_timeout");
				  entity:MeleeAttack(target);
				  return;
				end
			end
		end
		AI.Signal(SIGNALFILTER_SENDER,1,"DODGE_FINISHED",entity.id);
	end,

	MELEE_FAILED = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_SENDER,1,"DODGE_FINISHED",entity.id);
	end,

	END_MELEE = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_SENDER,1,"DODGE_FINISHED",entity.id);
	end,
	
}
