--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Defend behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 4/12/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperDefend = {
	Name = "TrooperDefend",
	Base = "TrooperAttack",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity)
--		if(targetType==AITARGET_ENEMY) then 
--			--entity:SelectPipe(0,"tr_just_shoot");
--		else
--			entity:SelectPipe(0,"tr_stick_close_defend");
--			if(targetType==AITARGET_NONE or targetType==AITARGET_FRIENDLY) then
--				entity:InsertSubpipe(0,"acquire_target","beacon");
--			end
--		end
		self:CHECK_DEFEND_SPOT(entity);
		
	end,

	------------------------------------------------------------------------
	OnEnemyMemory = function(self,entity,sender)
		
	end,
	
	------------------------------------------------------------------------
	OnPlayerSeen = function(self,entity,distance)
		self:CHECK_DEFEND_SPOT(entity);
		
	end,
	------------------------------------------------------------------------
	CHECK_DEFEND_SPOT = function(self,entity,sender)
		if(AI.SetRefPointAtDefensePos(entity.id,entity.AI.DefensePoint,entity.Properties.Behavior.DefendDistance)) then
			entity:SelectPipe(0,"tr_approach_refpoint");
		else
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_PREVIOUS",entity.id);
		end
	end,
	
	------------------------------------------------------------------------
	REFPOINT_REACHED  = function(self,entity,sender)
			entity:SelectPipe(0,"tr_just_shoot");
		
	end,
	
	------------------------------------------------------------------------
	TR_NORMALATTACK = function(self,entity,sender)
		self:CHECK_DEFEND_SPOT(entity);
	end,

}