-- sit down on seat  - look for a magazine to read nb seat does not bind to player
-- to bind magazine to hand need to make sure magazine is exported bound to same bone that I am going to use, and register with AI
-- Created 2002-12-03 Amanda
--------------------------
AIBehaviour.Idle_SitDown = {
	Name = "Idle_SitDown",
	JOB = 2,

	AnimTable = {
		[AIAnchorTable.AIANCHOR_MAGAZINE] = {"magazine1","magazine2","magazine3"},
		[AIAnchorTable.AIANCHOR_SEAT] = {"sitdown","sitdown_legup","situp"},
	},
	TargetType = AIAnchorTable.AIANCHOR_MAGAZINE,
	------------------------------------------------------------------------
	Constructor = function(self,entity)	
		entity:InitAIRelaxed();
		self.FoundObject = AI.FindObjectOfType(entity.id,20,AIAnchorTable.AIANCHOR_SEAT);
		
		if (self.FoundObject) then
			
			entity:SelectPipe(0,"anchor_animation");
			entity:InsertSubpipe(0,"job_approach_lastop",self.FoundObject);
			entity:InsertSubpipe(0,"setup_idle");
		else
			AI.Signal(0,1,"BackToJob",entity.id);
		end		
	end,
	------------------------------------------------------------------------
	OnNoTarget = function(self,entity)	
	end,
	------------------------------------------------------------------------ 	
 	OnJobExit = function( self, entity )
		-- make sure doesnt leave job with no gun
		self.Sitting = nil;
		--entity:StartAnimation(0,"situp",4,0);
		entity.cnt.AnimationSystemEnabled = 1;
		entity:SelectPipe(0,"force_reevaluate");		
		--self:END_ANIM(entity,entity);
	end,	

 	BackToJob = function( self, entity,sender )
		entity.cnt.AnimationSystemEnabled = 1;
		entity.EventToCall = "OnJobContinue";
	end,

	------------------------------------------------------------------------ 
	START_ANIM = function (self, entity, sender)
		if (self.Sitting == nil) then
			--AI.LogEvent("\001 SITDOWN");
			entity.cnt.AnimationSystemEnabled = 0;
			entity:StartAnimation(0,"sitdown_breath",0);
			entity:InsertAnimationPipe("sitdown",0);
			self.Sitting = 1;
			self.Sit_Decision_Points = random(5,10);
		end
	end,
	------------------------------------------------------------------------ 
	LOOP_ANIM = function (self, entity, sender)
		--AI.LogEvent("\001 LOOP");
		local rnd=random(1,15);
		if (rnd > 5) then 

			if (self.LegUp) then
				if (rnd==7) then
					entity:StartAnimation(0,"sitdown_breath",0);
					entity:InsertAnimationPipe("magazine3",0);
					self.LegUp=nil;
				elseif (rnd==8) then
					entity:InsertAnimationPipe("magazine2",0);
				elseif (rnd==9) then
					entity:InsertAnimationPipe("magazine5",0);
				elseif (rnd==10) then
					entity:InsertAnimationPipe("magazine4",0);
				elseif (rnd==11) then
					entity:InsertAnimationPipe("magazine7",0);
				end

			else
				self.LegUp = 1;
				entity:StartAnimation(0,"magazine6",0);
				entity:InsertAnimationPipe("magazine1",0);
			end
				
		end
	end,
	------------------------------------------------------------------------ 
	END_ANIM = function (self, entity, sender)
		if (self.Sitting == nil) then
			--AI.LogEvent("\001 SITUP");
			entity:StartAnimation(0,"sidle",0,0);
			entity:InsertAnimationPipe("situp",nil,"BackToJob");
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

 