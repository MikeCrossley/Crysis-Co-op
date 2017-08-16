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
AIBehaviour.TrooperJump = {
	Name = "TrooperJump",
	Base = "TrooperAttack",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity,data)
		if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then
			AIBehaviour.TROOPERDEFAULT:StickPlayerAndShoot(entity);
			AI.Signal(SIGNALFILTER_SENDER, 0,"GO_TO_ATTACK",entity.id);
		else	
			entity:SelectPipe(0,"tr_stay_and_lookaround");
		end			
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- data.id: the shooter
		entity:Readibility("GETTING_SHOT_AT",1);

	end,

	---------------------------------------------
	END_LOOKAROUND = function ( self, entity, sender)
		local targetType = AI.GetTargetType(entity.id);
		if(targetType ~= AITARGET_NONE) then
			AI.GetAttentionTargetPosition(entity.id,g_SignalData.point);
			AI.Signal(SIGNALFILTER_SENDER, 0,"GO_TO_SEARCH",entity.id,g_SignalData);
		end		
	end,
}