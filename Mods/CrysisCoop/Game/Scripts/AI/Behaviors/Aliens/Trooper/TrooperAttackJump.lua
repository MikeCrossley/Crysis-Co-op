--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Jump behavior for Alien Trooper 
--  trooper jumps and hangs grabbing on an object until he sees the enemy
--------------------------------------------------------------------------
--  History:
--  - 4/12/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperAttackJump = {
	Name = "TrooperAttackJump",
	Base = "TrooperDumb",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity,data)
		local entityAI = entity.AI;
		entityAI.bShootingOnSpot = false;
		entityAI.bSwitchingPosition = true;--default action after landing
		entityAI.bSpecialAction = false;
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- data.id: the shooter

	end,
	
	---------------------------------------------
	END_LOOKAROUND = function ( self, entity, sender)
	end,
	
		--------------------------------------------------
--	JUMP_FIRE = function(self,entity,sender)
--		if(Trooper_Jump(entity,entity.AI.targetPos,true,true,20)) then 
--			entity.AI.JumpType = TROOPER_JUMP_FIRE;
--			entity:SelectPipe(0,entity.AI.jumpPipe);
--			--AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK_JUMP",entity.id);
--		else
--			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
--		end
--	end,
	
	--------------------------------------------------
	JUMP_FIRE_NO_PATH= function(self,entity,sender)
		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
	
	end,
	
	--------------------------------------------------
	OnAttackSwitchPosition = function(self,entity,sender)
		local entityAI = entity.AI;
		entityAI.bShootingOnSpot = false;
		entityAI.bSwitchingPosition = true;
		entityAI.bSpecialAction = false;
	end,

	--------------------------------------------------
	OnSpecialAction = function(self,entity,sender)
		local entityAI = entity.AI;
		entityAI.bShootingOnSpot = false;
		entityAI.bSwitchingPosition = false;
		entityAI.bSpecialAction = true;
		
	end,
	
	--------------------------------------------------
	OnAttackShootSpot = function(self,entity,sender)
		local entityAI = entity.AI;
		entityAI.bShootingOnSpot = true;
		entityAI.bSwitchingPosition = false;
		entityAI.bSpecialAction = false;
	end,
	
	--------------------------------------------------
	OnLand = function(self,entity,sender)
		local entityAI = entity.AI;
		if(AI.GetGroupCount( entity.id, GROUP_ENABLED, AIOBJECT_PUPPET )<2 or entityAI.bSpecialAction) then
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_SPECIAL_ACTION",entity.id);
		elseif(entityAI.bShootingOnSpot) then 
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ON_SPOT",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_SWITCH_POSITION",entity.id);
		end
	end,

	--------------------------------------------------
	END_JUMP = function(self,entity,sender)
		self:OnLand(entity,sender);
	end,
	
	--------------------------------------------------
	END_MELEE = function(self,entity,sender)
		AIBehaviour.TROOPERDEFAULT:END_MELEE(entity,sender);
	end,
}