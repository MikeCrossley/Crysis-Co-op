-- sit down on seat  - look for a magazine to read nb seat does not bind to player
-- to bind magazine to hand need to make sure magazine is exported bound to same bone that I am going to use, and register with AI
-- Created 2002-12-03 Amanda
--------------------------
AIBehaviour.Job_Fix = {
	Name = "Job_Fix",
	JOB = 1,



	------------------------------------------------------------------------
	Constructor = function(self,entity)	
		entity:InitAIRelaxed();
		self.FoundObject = AI.FindObjectOfType(entity.id,20,AIAnchorTable.AIANCHOR_FENCE);
		
		if (self.FoundObject) then
			entity:SelectPipe(0,"anchor_animation");
			entity:InsertSubpipe(0,"job_approach_lastop",self.FoundObject);
			entity:InsertSubpipe(0,"setup_idle");
		else
			AI.Signal(0,1,"BackToJob",entity.id);
		end		
	end,

 
	------------------------------------------------------------------------ 
	START_ANIM = function (self, entity, sender)
		if (self.Sitting == nil) then
			entity:StartAnimation(0,"_fixfence_loop",0);
			entity:InsertAnimationPipe("_fixfence_start",0);
			self.Sitting = 1;
			self.Sit_Decision_Points = random(5,10);
		end
	end,
	------------------------------------------------------------------------ 
	LOOP_ANIM = function (self, entity, sender)
		local rnd=random(1,10);
		if (rnd>7) then 
			if (rnd==8) then 
				entity:InsertAnimationPipe("_fixfence_idle01");
			end
		end
	end,
	------------------------------------------------------------------------ 
	END_ANIM = function (self, entity, sender)
		if (self.Sitting == nil) then
			--AI.LogEvent("\001 SITUP");
			entity:StartAnimation(0,"sidle",0,0);
			entity:InsertAnimationPipe("_fixfence_end",0);
		end
	end,
	---------------------------------------------
	DECISION_POINT = function( self,entity , sender)
	 	self.Sit_Decision_Points = self.Sit_Decision_Points - 1;
		if ( self.Sit_Decision_Points == 0 ) then 
			--self.Sitting = nil;
		end
	end,	
}

 