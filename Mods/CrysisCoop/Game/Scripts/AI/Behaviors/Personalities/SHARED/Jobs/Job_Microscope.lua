-- look in microscope
-- Created 2002-12-03 Amanda

-- to do work out how to find out first behaviour
--------------------------
AIBehaviour.Job_Microscope = {
	Name = "Job_Microscope",
	JOB = 1,
	AnimTable ={
		[AIAnchorTable.AIANCHOR_MICROSCOPE]= {"microscope1","microscope2"},
		},
	TargetType = AIAnchorTable.AIANCHOR_MICROSCOPE,
	--------------------------
	Constructor = function(self,entity)	
		self:FIND_ANCHOR(entity);	
	end,
	------------------------------------------------------------------------ 	
	OnNoTarget = function(self,entity)	
	end,
	------------------------------------------------------------------------ 	
	OnJobExit = function( self, entity )
	-- make sure doesnt leave job with no gun
		entity.cnt.AnimationSystemEnabled = 1;
		AIBehaviour.DEFAULT:UNHIDE_GUN(entity,sender);
		entity:InsertSubpipe(0,"force_reevaluate");		
	end,
	------------------------------------------------------------------------ 	
 	OnBored = function(self,entity)	
 		rnd = random(1,2);
		if (rnd == 1) then
			entity.cnt.AnimationSystemEnabled = 1;
			entity:InsertSubpipe(0,"pause");
			local boredAnchor = AI_BoredManager:FindAnchor(entity,AI_BoredManager.AIBORED_SCIENTIST,10);
			if (boredAnchor) then
				AI.Signal(0,1, boredAnchor.signal,entity.id);
				entity.EventToCall = "OnSpawn";
			end
		else
			entity:MakeRandomConversation();
		end
	end,
	------------------------------------------------------------------------ 	
	FIND_ANCHOR = function (self,entity)
		
		--locate anchor of desired type
		local foundObject = AI.FindObjectOfType(entity.id,20,self.TargetType);
 		if ( foundObject ) then
 			entity:SelectPipe(0,"anchor_loop_devalue",foundObject);
		else
			if (entity.Properties.aibehavior_behaviour == "Job_Microscope") then
				entity:SelectPipe(0,"beat");
				self:Idle(entity,sender);
			else
				entity:SelectPipe(0,"beat");
			 	AI.Signal(0,1, "BackToJob",entity.id);
			 	if (entity.Properties.aibehavior_behaviour =="Job_CheckApparatus") then
			 		entity.EventToCall = "MARKOFF_CLIPBOARD";
			 	else
			 		entity.EventToCall = "OnSpawn";
			 	end
			end
		end	
	end,
	------------------------------------------------------------------------ 	
	Idle = function (self, entity, sender)
		entity.cnt.AnimationSystemEnabled = 0;
		local MyAnim = Mutant_IdleManager:GetIdle(entity);
			-----	
			AI.CreateGoalPipe(MyAnim.Name.."Delay");
			AI.PushGoal(MyAnim.Name.."Delay","timeout",1,MyAnim.duration);
			AI.PushGoal(MyAnim.Name.."Delay","signal",0,1,"FIND_ANCHOR",0);
			-----
		entity:StartAnimation(0,MyAnim.Name);							
		entity:SelectPipe(0,MyAnim.Name.."Delay");

	end,	
	------------------------------------------------------------------------ 	
	MAIN = function (self, entity, sender)
		local choices = getn(self.AnimTable[self.TargetType]);
		local anim = self.AnimTable[self.TargetType][random(1,choices)] 
		entity:StartAnimation(0,anim);
	end,
	---------------------------------------------
	DECISION_POINT = function( self,entity , sender)
	
	 	local rnd = random(1,10);
	 	
	 	--occasionaly decide enough with button pressing go back to real job
		if ( rnd < 4) then 
			if (entity.Properties.aibehavior_behaviour ==  "Job_Microscope") then
				self:Idle(entity,sender);
			else
			 	AI.Signal(0,1, "BackToJob",entity.id);
			 	if (entity.Properties.aibehavior_behaviour =="Job_CheckApparatus") then
			 		entity.EventToCall = "MARKOFF_CLIPBOARD";
			 	else
			 		entity.EventToCall = "OnSpawn";
			 	end
			end
--		-- or an idle animation	
		elseif (rnd>8) then	
			self:Idle(entity,sender);		
		end
	end,
	---------------------------------------------			
}

 