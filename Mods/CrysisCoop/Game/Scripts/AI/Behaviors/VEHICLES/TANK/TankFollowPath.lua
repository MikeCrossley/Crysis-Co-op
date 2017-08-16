-- Vehicle follows a path madw with tagpoints sequentially named entityname.."_P<x>"
-- optional parameter: entity.AI.PathStep (number of path step to begin with - default = 0)
---------------------------------


AIBehaviour.TankFollowPath = {
	Name = "TankFollowPath",
	alertness = 0,

	---------------------------------------------

	Constructor = function(self,entity )
		if(entity.AI.PathStep ==nil) then
			entity.AI.PathStep = 0;	-- need to strart from path beginning
			entity.AI.LastPathStep = nil;
		end
		
		if(entity.AI.PathName == nil) then
			entity.AI.PathName = entity:GetName();
		end
		entity:SelectPipe(0,"wait_and_start_path");
		--self:OnNextPathPoint(entity);
	end,

	----------------------------------------------------FUNCTIONS 
	OnNextPathPoint = function (self, entity, sender)
		-- select next tagpoint for patrolling
		local name = entity.AI.PathName;
		tpname = name.."_P"..entity.AI.PathStep;

		local TagPoint = System.GetEntityByName(tpname);
		if (TagPoint) then 		
			
			local nextstep = entity.AI.PathStep;
			local nextTagPoint = TagPoint;
			local bContinue = true;
			
		else
			if (entity.AI.PathStep == 0) then 
				AI.Warning(" Entity "..name.." has a path job but no specified path points.");
				do return end
			end
			-- no need to loop the path
			-- Job done => notify Commander
			entity:SelectPipe(0,"do_nothing");
			AI.Commander:NotifyPatrolPathDone(entity);
			do return end;
--			entity.AI.PathStep = 0;
		end

		entity:SelectPipe(0,"vehicle_path_approach",tpname);
--		SubVectors(g_Vectors.temp_v2, TagPoint:GetWorldPos(),entity:GetWorldPos());
--		NormalizeVector(g_Vectors.temp_v2);
--		local cosine = math.abs(dotproduct3d(entity:GetDirectionVector(),g_Vectors.temp_v2));
--		if(cosine>0.94) then
--	--entity:InsertSubpipe(0,"continuous_move");
--		else
--			entity:InsertSubpipe(0,"continuous_move");
--		end

		entity:InsertSubpipe(0,"ignore_all");
		

		if (entity.AI.PathStep >= entity.AI.LastPathStep) then
			entity.AI.PathStep = 1000;
		else
			entity.AI.PathStep = entity.AI.PathStep + 1;
		end
	end,
	
}
