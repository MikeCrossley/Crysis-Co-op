--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Pre-Attack for Alien Trooper Leader, ignoring further unit's seeing enemy. 
--  
--------------------------------------------------------------------------
--  History:
--  - 7/1/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperLeaderPreAttack = {
	Name = "TrooperLeaderPreAttack",
	Base = "TrooperLeaderIdle",
	
	Constructor = function(self,entity)
	end,
	
	Destructor = function(self,entity)
	end,
	
	OnEnemySeenByUnit = function(self,entity,sender)
	end,
		
}