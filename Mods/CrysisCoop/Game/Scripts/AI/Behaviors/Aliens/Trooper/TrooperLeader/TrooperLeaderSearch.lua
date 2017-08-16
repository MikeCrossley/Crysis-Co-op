--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Search behavior for Trooper Leader . 
--  
--------------------------------------------------------------------------
--  History:
--	- Feb 2006		: Created by Luciano Morpurgo
--------------------------------------------------------------------------
AIBehaviour.TrooperLeaderSearch = {
	Name = "TrooperLeaderSearch",
	Base = "TrGroupSearch",
	alertness = 1,
	---------------------------------------------
	Constructor = function(self , entity )
		
	end,

	OnEnemySeenByUnit = function(self,entity,sender,data)
		AIBehaviour.TrooperLeaderIdle:OnEnemySeenByUnit(entity,sender,data);
	end,

	ORDER_ATTACK_FORMATION = function(self,entity,sender)
		-- ignore this order
		AI.Signal(SIGNALFILTER_LEADER, 10, "ORD_DONE", entity.id);
		
	end,
	
	OnResetFormationUpdate = function(self,entity,sender)
		AI.SetFormationUpdate(entity.id,false);
	end,

	OnSetFormationUpdate = function(self,entity,sender)
		AI.SetFormationUpdate(entity.id,true);
	end,
	
	OnLeaderActionCompleted = function(self,entity,sender,data)
		AI.Signal(SIGNALFILTER_SUPERGROUP,0,"GO_TO_IDLE",entity.id);
	end,
	
	------------------------------------------------------------------------
	OnLeaderDied = function(self,entity,sender)
--		g_SignalData.iValue = LAS_ATTACK_FRONT;
--		AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_ATTACK", entity.id,g_SignalData);
	end,

	------------------------------------------------------------------------
	OnUnitDamaged = function(self,entity,sender,data)
		if(not AI.Hostile(entity.id,AI.GetGroupTarget(entity.id))) then
	 	 	CopyVector(g_SignalData.point,data.point);
			g_SignalData.iValue = UPR_COMBAT_GROUND + UPR_COMBAT_RECON;
			g_SignalData.fValue = 20; --search distance
			AI.Signal(SIGNALFILTER_LEADER,1,"ORD_SEARCH",entity.id,g_SignalData);
			AI.Signal(SIGNALFILTER_SENDER,1,"GOTO_SEARCH",entity.id);
		end
	end,
}
