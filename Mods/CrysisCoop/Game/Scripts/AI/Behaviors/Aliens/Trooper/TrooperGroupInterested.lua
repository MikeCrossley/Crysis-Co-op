--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Interested group-behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 7/7/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperGroupInterested = {
	Name = "TrooperGroupInterested",
	Base = "TrooperGroupIdle",
	alertness = 1,

	Constructor = function(self,entity,data)
		entity:Event_Cloak();
--		if(AI.GetTargetType(entity.id) ==AITARGET_SOUND) then
			entity:SelectPipe(0,"tr_look_closer");
		--else
		--	entity:SelectPipe(0,"do_nothing");
--			entity:InsertSubpipe(0,"look_at_lastop",data.ObjectName);
		--end
    if(entity.searchSound) then
    	entity:StopSound(entity.searchSound);
    	entity.searchSound = nil;
    end
--		local sndFlags = bor(SOUND_DEFAULT_3D,SOUND_LOOP);
--    entity.searchSound = entity:PlaySoundEvent("sounds/alien:trooper:laser",g_Vectors.v000, g_Vectors.v010, sndFlags, SOUND_SEMANTIC_AI_READABILITY);
		
	end,
	---------------------------------------------
	Destructor = function(self,entity)
    if(entity.searchSound) then
    	entity:StopSound(entity.searchSound);
    	entity.searchSound = nil;
    end
  end,


}