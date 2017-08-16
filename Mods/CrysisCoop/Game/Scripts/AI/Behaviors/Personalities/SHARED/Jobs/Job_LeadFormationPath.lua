-- leading a formation on a path - 
-- last modified by Luciano 
---------------------------------


AIBehaviour.Job_LeadFormationPath = {
	Name = "Job_LeadFormationPath",
	JOB = 1,
	-- SYSTEM EVENTS			-----
	---------------------------------------------

--	Constructor = Job_PatrolCircle,
	Constructor = function(self,entity )
--		AI.Signal(SIGNALFILTER_LEADER,1,"ORD_FOLLOW", entity.id,"convoy0");
		entity.bGunReady = true;
		entity.AI.PathStep = 0;	-- need to strart from path beginning
		entity:InitAIRelaxed();

		entity:HolsterItem(false);

		local leader = AI.GetLeader(entity.id);
		
		if(leader) then
			entity.AI.PathName = leader:GetName();
		else
			entity.AI.PathName = entity:GetName();
		end
		entity.AI.LastPathStep = nil;
		self:PatrolPath(entity);
	end,
	---------------------------------------------		
	OnJobContinue = function(self,entity )
		entity:InitAIRelaxed();
		self:PatrolPath(entity);
	end,
	---------------------------------------------		
	OnBored = function (self, entity)
		entity:MakeRandomConversation();
	end,
	----------------------------------------------------FUNCTIONS 
	PatrolPath = function (self, entity, sender)
		-- select next tagpoint for patrolling
		local name = entity.AI.PathName;

		local tpname = name.."_P0";	
		if(entity.AI.PathStep == nil) then
			entity.AI.PathStep = 0;
		end

--		local TagPoint = Game:GetTagPoint(name.."_P"..entity.AI.PathStep);
		local TagPoint = System.GetEntityByName(name.."_P"..entity.AI.PathStep);
		if (TagPoint) then 		
			tpname = name.."_P"..entity.AI.PathStep;
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

		entity:SelectPipe(0,"do_nothing");

		if (entity.AI.LastPathStep) then
			entity:SelectPipe(0,"patrol_approach_running",tpname);
		else
			entity:SelectPipe(0,"patrol_approach_no_idle",tpname);
		end;

		if (entity.AI.PathStep == entity.AI.LastPathStep) then
			entity.AI.PathStep = 1000;
		else
			entity.AI.PathStep = entity.AI.PathStep + 1;
		end
	end,
	
	--------------------------------------------------
	OnVehicleDanger = function(self, entity, sender, signalData)
		-- just ignore this signal and avoid default processing.
		-- we don't want to "scare" them now by their own vehicles
	end,

	------------------------------------------------------------------------
	BREAK_AND_IDLE = function (self, entity, sender)
	end,
	------------------------------------------------------------------------	
}
