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
--  - 20/07/2006   : Created by Tetsuji
--
--------------------------------------------------------------------------


AIBehaviour.AAAIdle = {
	Name = "AAAIdle",
	Base = "TankIdle",	

	---------------------------------------------
	Constructor = function( self , entity )
		
		AIBehaviour.TankIdle:Constructor( entity );
		AI.ChangeParameter(entity.id,AIPARAM_COMBATCLASS,AICombatClasses.AAA);		
		
		entity.AI.isAAA = true; -- temporary

	end,

	
}
