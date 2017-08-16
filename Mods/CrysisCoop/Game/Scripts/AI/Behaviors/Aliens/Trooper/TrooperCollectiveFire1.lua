--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Trooper Collective fire 1: the trooper shoots a ray to the Leader
--------------------------------------------------------------------------
--  History:
--  - Feb 2006     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperCollectiveFire1 = {
	Name = "TrooperCollectiveFire1",
	Base = "TrooperDumb",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity,data)
		local leader = AI.GetLeader(entity.id);
		AI.SetRefPointPosition(entity.id,leader:GetPos());
		AI.SetPFBlockerRadius( entity.id, PFB_REF_POINT, 3);
		if(leader) then 
			entity:SelectPipe(0,"do_nothing");
			entity:InsertSubpipe(0,"tr_collective_fire1",leader.id);
		end
	end,

	---------------------------------------------
	Destructor = function (self, entity,data)
		self:BEAM_OFF(entity,sender);
		AI.SetIgnorant(entity.id,0);
		AI.SetPFBlockerRadius( entity.id, PFB_REF_POINT, 0);
	end,
	---------------------------------------------
	OnEnemyMemory = function ( self, entity, sender)
		AI.Signal(SIGNALFILTER_LEADERENTITY,1,"OnEnemyMemory",entity.id);
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- data.id: the shooter
		entity:Readibility("GETTING_SHOT_AT",1);

	end,

	---------------------------------------------
	BEAM_OFF = function ( self, entity, sender)
		-- to do: switch the beam off
		entity:Beam(nil);
		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(0,"tr_end_collective_fire1");
	end,

	---------------------------------------------
	VISIBILITY_POINT_REACHED = function(self,entity,sender)
		-- to do: switch the beam on
		local leader = AI.GetLeader(entity.id);
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
		if(leader) then 
			entity:Beam(leader);
		end
	end,	
}