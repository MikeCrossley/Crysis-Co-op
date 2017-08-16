--------------------------


AIBehaviour.Job_CroweOne = {
	Name = "Job_CroweOne",				

			-----
	---------------------------------------------
	Constructor = function(self,entity )
		entity:InitAIRelaxed();

		AI.CreateGoalPipe("crowe_special_talk");
		AI.PushGoal("crowe_special_talk","firecmd",1,0);
		AI.PushGoal("crowe_special_talk","timeout",1,0.5);
		AI.PushGoal("crowe_special_talk","signal",1,1,"DO_SOMETHING_IDLE",0);
		AI.PushGoal("crowe_special_talk","timeout",1,100);
		entity:SelectPipe(0,"crowe_special_talk");
		entity:InsertSubpipe(0,"setup_idle");
	end,


	OnJobContinue = function(self,entity,sender )	

		local dh=entity:GetName().."_CROWETARGET";

		-- try to get tagpoint of the same name as yourself first
		local TagPoint = Game:GetTagPoint(dh);
 		if (TagPoint==nil) then
			-- try to fish for a observation anhor within 2 meter from yourself
			Hud:AddMessage("CROWE DIDN'T FIND WHERE TO GO. PUT TAGPOINT <name>_CROWETARGET");

		end
		
		entity:SelectPipe(0,"observe_direction",dh);
		if (TagPoint) then
			entity:InsertSubpipe(0,"patrol_approach_to",dh);
		end
	end,

	OnPlayerSeen = function(self,entity,fDistance )	

		entity:StartAnimation(0,"NULL",4);
		local dh=entity:GetName().."_CROWETARGET";

		-- try to get tagpoint of the same name as yourself first
		local TagPoint = Game:GetTagPoint(dh);
 		if (TagPoint==nil) then
			-- try to fish for a observation anhor within 2 meter from yourself
			Hud:AddMessage("CROWE DIDN'T FIND WHERE TO GO. PUT TAGPOINT <name>_CROWETARGET");

		end
		
		entity:SelectPipe(0,"patrol_run_to",dh);
	end,

	OnInterestingSoundHeard = function(self,entity,fDistance )
		self:OnPlayerSeen(entity);	
	end,

	OnThreateningSoundHeard = function(self,entity,fDistance )	
		self:OnPlayerSeen(entity);	
	end,

	HEADS_UP_GUYS = function(self,entity,sender )	
		self:OnPlayerSeen(entity);	
	end,

	OnBulletRain = function(self,entity,sender )	

	end,
	
}


