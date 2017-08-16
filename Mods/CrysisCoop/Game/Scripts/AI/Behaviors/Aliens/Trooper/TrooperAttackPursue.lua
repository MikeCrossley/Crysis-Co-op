--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Pursue Attack behavior for Alien Trooper 
--  like attack, but it doesn't get distracted by other enemies before he reaches the 
--	current attention target
--------------------------------------------------------------------------
--  History:
--  - 4/12/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperAttackPursue = {
	Name = "TrooperAttackPursue",
	Base = "TrooperAttack",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity,data)
		entity.AI.bStrafe = false;
		entity:SelectPipe(0,"tr_acquire_target_and_pursue",data.id);
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- data.id: the shooter
		entity:Readibility("GETTING_SHOT_AT",1);

	end,

}