--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Interested behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--
--------------------------------------------------------------------------
AIBehaviour.TrooperInterested = {
	Name = "TrooperInterested",
	Base = "TrooperIdle",
	alertness = 1,

	Constructor = function(self,entity,data)
		--entity:Cloak(1);
		entity:SelectPipe(0,"tr_look_closer");
		local attPos = g_Vectors.temp;
		AI.GetAttentionTargetPosition(entity.id, attPos);
		AI.SetRefPointPosition(entity.id, attPos);
		if(AI.GetTargetType(entity.id) ==AITARGET_NONE) then
			entity:InsertSubpipe(0,"acquire_target","beacon");
		end
		if(data and data.iValue==1) then
			-- rush mode
			entity:InsertSubpipe(0,"do_it_running");
		end
    if(entity.searchSound) then
    	entity:StopSound(entity.searchSound);
    	entity.searchSound = nil;
    end
    entity:InsertSubpipe(0,"tr_random_short_timeout");
--		local sndFlags = bor(SOUND_DEFAULT_3D,SOUND_LOOP);
--    entity.searchSound = entity:PlaySoundEvent("sounds/alien:trooper:laser",g_Vectors.v000, g_Vectors.v010, sndFlags, SOUND_SEMANTIC_AI_READABILITY);
		
	end,
	---------------------------------------------
	Destructor = function(self,entity)
    if(entity.searchSound) then
    	entity:StopSound(entity.searchSound);
    	entity.searchSound = nil;
    end
    AI.SetStance(entity.id,BODYPOS_STAND);
  end,
  ---------------------------------------------
	OnNoTarget = function( self, entity )
--		if(not AI.GetGroupTarget(entity.id,true,true)) then
--			Trooper_Search(entity);
--		end
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
	end,

	---------------------------------------------
	OnSomethingSeen= function( self, entity,sender )
		-- redirect to new target
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"tr_look_closer");
	end,
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
	end,

	---------------------------------------------
	OnReload = function( self, entity )
	end,

	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
	end,	

	--------------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender)
	end,

	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
	end,

	
--	--------------------------------------------------
--	OnGroupMemberDiedNearest = function ( self, entity, sender)
--
--		AIBehaviour.TROOPERDEFAULT:OnGroupMemberDiedNearest(entity,sender);
--
--		entity:SelectPipe(0,"tr_recog_corpse",sender.id);
--	end,

	---------------------------------------------
	CEASE = function( self, entity, fDistance )
		entity:SelectPipe(0,"tr_cease_investigation"); -- in PipeManagerShared.lua			 
	end,

	---------------------------------------------
	TRY_TO_LOCATE_SOURCE = function (self, entity, sender)
		entity:SelectPipe(0,"tr_lookaround_30seconds");
	end,

	--------------------------------------------------
	OnNoPathFound = function ( self, entity, sender)
		if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then 
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK",entity.id);
		else
			entity:SelectPipe(0,"tr_look_around");
		end
		AI.ModifySmartObjectStates(entity.id,"SearchShootSpots");
	end,
	
	--------------------------------------------------
	OnThreateningSoundHeard = function(self, entity, sender)
		AI.SetStance(entity.id,BODYPOS_STAND);
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"tr_look_closer");
		
	end,
	
	--------------------------------------------------
	OnEndPathOffset = function ( self, entity, sender)
		if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then 
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK",entity.id);
		else
			entity:SelectPipe(0,"tr_look_around");
		end
		AI.ModifySmartObjectStates(entity.id,"SearchShootSpots");
	end,
	
	--------------------------------------------------
	END_LOOK_CLOSER = function ( self, entity, sender)
		entity:SelectPipe(0,"tr_look_around");
	end,
	
	--------------------------------------------------
	CHECK_LOOK_AROUND = function ( self, entity, sender)
		if(not AI.GetGroupTarget(entity.id,true,true)) then
			local pos = g_Vectors.temp;
			AI.GetRefPointPosition(entity.id,pos);
			Trooper_Search(entity,pos);
		end
	end,
}