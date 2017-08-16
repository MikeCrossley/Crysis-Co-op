--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Trooper goes dumb for a few seconds because of a player's stunning weapon
--  
--------------------------------------------------------------------------
--  History:
--	- Dec 2005		: created by Luciano Morpurgo
--------------------------------------------------------------------------


AIBehaviour.TrooperGroupDumb = {
	Name = "TrooperGroupDumb",
	Base = "Dumb",
	alertness = 1,

	---------------------------------------------
	Constructor = function(self, entity)
		entity:SelectPipe(0,"tr_dumb");
		AI.Signal(SIGNALFILTER_LEADER,10,"OnUnitBusy",entity.id);
		entity:Readibility("REBOOT",1);
		entity:Cloak(0);
		if (entity.idleSound) then	
			entity:StopSound(entity.idleSound);
			entity.idleSound = nil;
		end	
	end,
	
	---------------------------------------------
	Destructor = function(self, entity)
	end,
	---------------------------------------------
	END_DUMB = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_LEADER,10,"OnResumeUnit",entity.id);
		entity:Readibility("END_REBOOT",1);
		entity:PlayIdleSound(entity.voiceTable.idle);
	end,
}