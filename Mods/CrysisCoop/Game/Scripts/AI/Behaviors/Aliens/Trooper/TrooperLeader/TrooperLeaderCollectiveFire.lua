--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Coordinated Fire Attack behavior for Alien Trooper Leader. 
--  	troopers do a collective fire to the target
--------------------------------------------------------------------------
--  History:
--	- Dec 2005		: Created by Luciano Morpurgo
--------------------------------------------------------------------------
AIBehaviour.TrooperLeaderCollectiveFire = {
	Name = "TrooperLeaderCollectiveFire",
	Base = "TrooperLeaderAttack",
	alertness = 2,
	---------------------------------------------
	Constructor = function(self , entity,data )
		-- data.id = target entity id
		-- data.iValue = attack sub action value
		AI.LogEvent(entity:GetName().." TROOPERLEADER COLL FIRE constructor");
		ItemSystem.SetActorItemByName(entity.id,"MOAR",false);
		entity:SelectPipe(0,"tr_fire_moar", data.id);
	end,

	-----------------------------------------------------------
	Destructor = function(self,entity)
		AI.LogEvent(entity:GetName().." TROOPERLEADER COLL FIRE destructor");
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
		ItemSystem.SetActorItemByName(entity.id,"LightMOAC",false);
	end,	
	
	-----------------------------------------------------------
	OnNoTarget = function(self,entity,sender)
		self:Abort(entity);
	end,

	-----------------------------------------------------------
	OnEnemyMemory = function(self,entity,sender)
		self:Abort(entity);
	end,
	
	-----------------------------------------------------------
	OnPlayerSeen = function(self,entity,sender)
	end,

	
	-----------------------------------------------------------
	OnUnitDied = function(self,entity,sender)
	end,
	
	-----------------------------------------------------------
	Abort = function(self,entity)
		AI.Signal(SIGNALFILTER_LEADER,0,"OnAbortAction",entity.id);
		AI.Signal(SIGNALFILTER_SUPERGROUP,0,"END_COLLECT_FIRE",entity.id);
		entity:SelectPipe(0,"do_nothing");
	end,
}
