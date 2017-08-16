--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2007.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Scout
--  
--------------------------------------------------------------------------
--  History:
--  - 11/12/2004   : Created by Kirill Bulatsev
--  - 05/04/2005   : CXP Rush Clean up by Mikko Mononen
--	- 29/11/2005   : Revised for new attack patterns by Tetsuji Iwasaki
--	- 15/01/2007   : Separated as the MOAR Scout by Tetsuji Iwasaki
--------------------------------------------------------------------------

--------------------------------------------------------------------------
AIBehaviour.ScoutMOARAttack = {
	Name = "ScoutMOARAttack",
	Base = "ScoutMOARDefault",
	alertness = 2,

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )
		AI.CreateGoalPipe("scoutMOARAttackDefault");
		AI.PushGoal("scoutMOARAttackDefault","timeout",1,1.0);
		AI.PushGoal("scoutMOARAttackDefault","firecmd",0,FIREMODE_FORCED);
		AI.PushGoal("scoutMOARAttackDefault","timeout",1,5.0);
		AI.PushGoal("scoutMOARAttackDefault","firecmd",0,0);
		AI.PushGoal("scoutMOARAttackDefault","timeout",1,3.0);
		entity:SelectPipe(0,"scoutMOARAttackDefault");
	end,
	--------------------------------------------------------------------------
	Destructor = function ( self, entity, data )
	end,

}
