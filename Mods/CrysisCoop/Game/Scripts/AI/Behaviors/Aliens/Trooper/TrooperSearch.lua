--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Search behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 4/12/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperSearch = {
	Name = "TrooperSearch",
	Base = "TROOPERDEFAULT",
	
	alertness = 1,

	hasConversation = true,

	---------------------------------------------
	Constructor = function(self, entity,data)
		-- set reference point at base search position
		local targetType = AI.GetTargetType(entity.id);
		if(targetType== AITARGET_MEMORY) then 
			local dir = g_Vectors.temp;
			local pos = g_Vectors.temp_v1;
			AI.GetAttentionTargetDirection(entity.id,dir);
			AI.GetAttentionTargetPosition(entity.id,pos);
			if(IsNotNullVector(dir)) then
				-- lost target has gone in this direction
				ScaleVectorInPlace(dir,4/LengthVector(dir));
				local	hits = Physics.RayWorldIntersection(pos,dir,2,ent_terrain+ ent_static+ent_rigid+ent_sleeping_rigid ,entity.id,nil,g_HitTable);
				if(hits>0) then
					AI.SetRefPointPosition(entity.id,g_HitTable[1].pos);
				else
					FastSumVectors(pos,pos,dir);
					AI.SetRefPointPosition(entity.id,pos);
				end
			else
				AI.SetRefPointPosition(entity.id,pos);
			end
		elseif(data and data.point and IsNotNullVector(data.point)) then
			local pos = g_Vectors.temp;
			CopyVector(pos,data.point2);
			ScaleVectorInPlace(pos,4);
			FastSumVectors(pos,data.point);
			AI.SetRefPointPosition(entity.id,pos);

		else
			AI.SetRefPointPosition(entity.id,entity:GetPos());
			AI.SetRefPointDirection(entity.id,entity:GetDirectionVector(1));
		end

		entity:SelectPipe(0,"tr_search_hidespot_around","refpoint");
		
    if(entity.searchSound) then
    	entity:StopSound(entity.searchSound);
    	entity.searchSound = nil;
    end
--		local sndFlags = bor(SOUND_DEFAULT_3D,SOUND_LOOP);
--    entity.searchSound = entity:PlaySoundEvent("sounds/alien:trooper:laser",g_Vectors.v000, g_Vectors.v010, sndFlags, SOUND_SEMANTIC_AI_READABILITY);
		Trooper_SetConversation(entity);
	end,

	---------------------------------------------
	Destructor = function ( self, entity)
    if(entity.searchSound) then
    	entity:StopSound(entity.searchSound);
    	entity.searchSound = nil;
    end
	end,

	---------------------------------------------
	OnInterestingSoundheard = function(self,entity,sender)
		entity:SelectPipe(0,"tr_seek_target");
		entity:SelectPipe(0,"do_it_running");
	end,
	---------------------------------------------
	OnThreateningSoundheard = function(self,entity,sender)
		entity:SelectPipe(0,"tr_seek_target");
		entity:SelectPipe(0,"do_it_running");
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
	end,

	---------------------------------------------
	OnReload = function( self, entity )
	end,

	--------------------------------------------------
	OnNoHidingPlace = function (self, entity, sender)
	end,
	
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player

		AIBehaviour.TrooperIdle:OnPlayerSeen(entity,fDistance);
	end,
	
	--------------------------------------------------
	OnNoPathFound = function ( self, entity, sender)
		--entity:SelectPipe(0,"tr_just_shoot");
		AI.ModifySmartObjectStates(entity.id,"SearchShootSpots");
	end,
	--------------------------------------------------
	OnEndPathOffset = function ( self, entity, sender)
		--entity:SelectPipe(0,"tr_just_shoot");
		AI.ModifySmartObjectStates(entity.id,"SearchShootSpots");
	end,

	--------------------------------------------------
	LOOK_FOR_TARGET = function (self, entity, sender)
		-- do nothing on this signal
		entity:SelectPipe(0,"tr_look_around");
	end,	

	--------------------------------------------------
	LOOK_DONE = function (self, entity, sender)
		self:HIDESPOT_SEARCHED(entity,sender);
	end,
	
	--------------------------------------------------
	HIDESPOT_SEARCHED = function (self, entity, sender)
		AI.SetRefPointPosition(entity.id,entity:GetPos());
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"tr_search_hidespot_around","refpoint");
	end,
	
	--------------------------------------------------
	HIDESPOT_NOT_FOUND= function (self, entity, sender)
		entity:SelectPipe(0,"do_nothing");
		AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_IDLE",entity.id);
	end,
}
