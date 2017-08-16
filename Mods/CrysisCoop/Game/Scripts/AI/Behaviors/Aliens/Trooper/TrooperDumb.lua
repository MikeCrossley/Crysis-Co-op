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


AIBehaviour.TrooperDumb = {
	Name = "TrooperDumb",
	Base = "Dumb",
	alertness = 1,

	---------------------------------------------
	Constructor = function(self, entity)
		entity:SelectPipe(0,"tr_dumb");
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
		entity:Readibility("END_REBOOT",1);
		local targetType = AI.GetTargetType(entity.id);
		if(targetType==AITARGET_ENEMY or targetType==AITARGET_MEMORY or targetType==AITARGET_SOUND) then
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ATTACK",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_SEARCH",entity.id);
		end

		entity:PlayIdleSound(entity.voiceTable.idle);
		
	end,

	---------------------------------------------
	REQUEST_CONVERSATION = function(self,entity,sender)
	end,

}