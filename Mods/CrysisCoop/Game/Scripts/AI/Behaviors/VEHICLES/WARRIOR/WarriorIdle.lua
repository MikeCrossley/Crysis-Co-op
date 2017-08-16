--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: 
--  
--------------------------------------------------------------------------
--  History:
--  - 06/02/2005   : Created by Kirill Bulatsev
--  - 10/07/2006   : Duplicated by Tetsuji
--
--------------------------------------------------------------------------


AIBehaviour.WarriorIdle = {
	Name = "WarriorIdle",
	Base = "VehicleIdle",	

	---------------------------------------------
	Constructor = function(self , entity )
		
		AI.ChangeParameter(entity.id,AIPARAM_COMBATCLASS,AICombatClasses.Warrior);		
		
		entity.AI.vDefultPos = {};
		CopyVector ( entity.AI.vDefultPos, entity:GetPos() );

		AIBehaviour.VehicleIdle:Constructor( entity );

	end,

	
}
