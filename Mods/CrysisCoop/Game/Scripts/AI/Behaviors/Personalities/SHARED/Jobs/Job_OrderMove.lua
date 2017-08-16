-- moving a group on a path in response to commander order CORD_MOVE
-- last modified by Dejan Pavlovski
---------------------------------


AIBehaviour.Job_OrderMove = {
	Name = "Job_OrderMove",
	Base = "LeaderIdle",

	-- SYSTEM EVENTS			-----
	---------------------------------------------

	Constructor = function( self, entity )
		entity:SelectPipe(0, "clear_all");
		
		--AI.LogEvent(entity:GetName()..": in Job_OrderMove:Constructor");
		g_StringTemp1 = "";
		g_SignalData.ObjectName = "line_follow";
		g_SignalData.iValue = 0;
		entity:CreateFormation(nil, true);

		entity.AI_PathStep = nil;	-- need to start from path beginning
		if (not entity.PathName) then
			entity.PathName = entity:GetName();
		end
		--AI.LogEvent(entity:GetName()..": using Path: "..entity.PathName);
		self:PatrolPath(entity);
	end,
	---------------------------------------------		
--	OnJobContinue = function(self,entity )
--		self:PatrolPath(entity);
--	end,
	---------------------------------------------		
	OnBored = function (self, entity)
--		entity:MakeRandomConversation();
	end,
	----------------------------------------------------FUNCTIONS 
	PatrolPath = function (self, entity, sender)
		-- select next tagpoint for patrolling
		--AI.LogEvent(entity:GetName()..": in Job_OrderMove:PatrolPath");

		if (entity.AI_PathStep == nil) then
			entity.AI_PathStep = 0;
			--AI.LogEvent(entity:GetName()..": Job_OrderMove:PatrolPath going to first TagPoint");
		end

		local tpname = entity.PathName.."_P"..entity.AI_PathStep;
		local TagPoint = System.GetEntityByName(tpname);
		if (TagPoint == nil) then
			if (entity.AI_PathStep == 0) then 
				--AI.Warning(" Entity "..entity:GetName().." has received CORD_MOVE but no specified path points.");
				return;
			end
			-- Job done => notify Commander
			--AI.Commander:NotifyMoveDone(entity);
			g_SignalData.id = entity.id;
			--AI.LogEvent(entity:GetName()..": Job_OrderMove:PatrolPath sending NC_OrderMoveDone");
			AI.Signal(0, 10, "NC_OrderMoveDone", AI.Commander:GetEntity().id, g_SignalData);
			entity.AI_PathStep = nil;
			entity:SelectPipe(0, "do_nothing");
			return;
		end

		--AI.LogEvent(entity:GetName()..": Job_OrderMove:PatrolPath going to TagPoint "..tpname);
		entity:SelectPipe(0, "do_nothing");
		entity:SelectPipe(0, "order_move_path", tpname);

		if (entity.AI_PathStep == entity.AI_LastPathStep) then
			entity.AI_PathStep = 1000;
		else
			entity.AI_PathStep = entity.AI_PathStep + 1;
		end
	end,
}
