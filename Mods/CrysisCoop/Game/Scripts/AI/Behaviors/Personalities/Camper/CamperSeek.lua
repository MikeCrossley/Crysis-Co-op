--------------------------------------------------
-- Cover2Seek
--------------------------
--   created: Mikko Mononen 21-6-2006


AIBehaviour.CamperSeek = {
	Name = "CamperSeek",
	Base = "Cover2Seek",
	alertness = 2,

	Constructor = function (self, entity)
		AIBehaviour.Cover2Seek:Constructor(entity);
	end,
	---------------------------------------------
	Destructor = function (self, entity)
		AIBehaviour.Cover2Seek:Destructor(entity);
	end,

	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity)

		local state = AI.GetGroupTacticState(entity.id, 0, GE_GROUP_STATE);
		
		if (entity.AI.seekCount == 0) then
			state = GS_SEEK;
		end
		
		if (state == GS_ADVANCE) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
		elseif (state == GS_SEARCH or state == GS_ALERTED or state == GS_IDLE) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
		else
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_SEEKING);
--			entity:Readibility("taunt",1,2,0.1,0.4);

			-- Target inside territory and the agent is the nearest
			if(AI_Utils:IsTargetOutsideTerritory(entity) == 0 and AI.GetGroupTacticState(entity.id, 0, GE_NEAREST_SEEK) == 1) then
				entity:Readibility("taunt",1,2,0.1,0.4);
				entity:SelectPipe(0,"cv_seek_direct");
			else
				local	distToDefendPos = DistanceVectors(entity:GetPos(), AI.GetGroupTacticPoint(entity.id, 0, GE_DEFEND_POS));
				if (distToDefendPos > 15.0) then
	--				entity:SelectPipe(0,"cv_seek_defend");
					entity:SelectPipe(0,"cm_seek_retreat");
				else
					entity:SelectPipe(0,"cv_seek_defend");
				end
			end
		end

	end,
}
