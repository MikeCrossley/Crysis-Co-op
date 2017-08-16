-- move from tag to tag stopping to look around idle a bit go on.
-- TO DO change so that spends variable time at tagpoints looking around for a while and then
--       insert some idle animation.
--------------------------
AIBehaviour.Job_LookPatrol = {
	Name = "Job_LookPatrol",				
	JOB = 1,	
	-- SYSTEM EVENTS -----
	
	---------------------------------------------
	Constructor = function(self,entity)
	
	 	self:FIND_ANCHOR(entity,sender);
	end,
	---------------------------------------------	
	OnBored = function (self, entity)
		entity:MakeRandomConversation();
	end,
	---------------------------------------------		
	--go from tag point to tag point
	FIND_ANCHOR = function (self, entity,sender)
	--AI.LogEvent("+++++++++++++++++++++++++++FIND_ANCHOR");
		if (self.PathStep) then
			self.PathStep = self.PathStep + 1;
			if (self.PathStep > (entity.Properties.pathstart + entity.Properties.pathsteps)) then
				self.PathStep = entity.Properties.pathstart;
			end
		else
			self.PathStep = entity.Properties.pathstart;
		end
		--AI.LogEvent("+++++++++++++++++++++++++++FIND_ANCHOR ["..entity.Properties.pathname..self.PathStep .."]");
		entity:SelectPipe(0,"approach_lookAround",entity.Properties.pathname..self.PathStep);

	end,  
	
	IDLE_ANIMATION = function (self, entity)
		entity.cnt.AnimationSystemEnabled = 0;
		local MyAnim = IdleManager:GetIdle();
		-----	
		AI.CreateGoalPipe(MyAnim.Name.."Delay");
		AI.PushGoal(MyAnim.Name.."Delay","timeout",1,MyAnim.duration);
		-----
		entity:StartAnimation(0,MyAnim.Name);							
		entity:InsertSubpipe(0,MyAnim.Name.."Delay");
		entity.cnt.AnimationSystemEnabled = 1;
	end, 
	
	LOOK_AT_LEFT = function (self, entity)
	
		local direction = random(-90,0);
		
		AI.CreateGoalPipe("LookAroundLeft"..direction);			
		AI.PushGoal("LookAroundLeft"..direction,"lookat",1,direction,(direction+90));
		AI.PushGoal("LookAroundLeft"..direction,"timeout",1,3,8);
		entity:InsertSubpipe(0,"LookAroundLeft"..direction);	
		
	end, 
	
	LOOK_AT_RIGHT = function (self, entity)
		
		local direction = random(0,90);
		
		AI.CreateGoalPipe("LookAroundRight"..direction);			
		AI.PushGoal("LookAroundRight"..direction,"lookat",1,direction,(direction+90));
		AI.PushGoal("LookAroundRight"..direction,"timeout",1,3,8);
		entity:InsertSubpipe(0,"LookAroundRight"..direction);		
		
	end, 
}

 