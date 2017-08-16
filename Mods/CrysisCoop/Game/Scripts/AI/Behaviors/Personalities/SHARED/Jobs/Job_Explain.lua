-- Explain - not really a job in its own right more of a sub job.
-- Created 2003-01-13 Amanda
--------------------------
AIBehaviour.Job_Explain = {
	Name = "Job_Explain",
	JOB = 1,
	AnimTable ={
		[AIAnchorTable.AIANCHOR_EXPLAIN]= {"talking1_sc","talking2_sc","talking3_sc","talking4_sc","talking5_sc","talking6_sc"},
		},
	TargetType = AIAnchorTable.AIANCHOR_EXPLAIN,
	--------------------------
	Constructor = function(self,entity)	
		entity.cnt.AnimationSystemEnabled = 1;
		self:FIND_ANCHOR(entity);	
	end,
	------------------------------------------------------------------------ 
	OnNoTarget = function(self,entity)	
	end,
	------------------------------------------------------------------------ 
	OnBored = function(self,entity)	
		local boredAnchor = AI_BoredManager:FindAnchor(entity,AI_BoredManager.AIBORED_SCIENTIST,20);
		if (boredAnchor) then
			AI.Signal(0,1, boredAnchor.signal,entity.id);
			entity.EventToCall = "OnSpawn";
		end
	end,
	------------------------------------------------------------------------ 	
	OnJobExit = function( self, entity )
	-- make sure doesnt leave job with no gun
		AIBehaviour.DEFAULT:UNHIDE_GUN(entity,sender);
		entity:InsertSubpipe(0,"force_reevaluate");	
	end,
	------------------------------------------------------------------------ 
	FIND_ANCHOR = function (self,entity)
		--locate anchor of desired type
		local foundObject = AI.FindObjectOfType(entity.id,20,self.TargetType);

 		if (foundObject) then
			entity:SelectPipe(0,"anchor_loop_devalue",foundObject);
		else
			if (entity.Properties.aibehavior_behaviour == "Job_Explain") then
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
	--occasionaly choose a random idle	
		entity.cnt.AnimationSystemEnabled = 0;
		if (random(1,5) == 5) then
			local MyAnim = Mutant_IdleManager:GetIdle(entity);
				-----	
				AI.CreateGoalPipe(MyAnim.Name.."Delay");
				AI.PushGoal(MyAnim.Name.."Delay","timeout",1,MyAnim.duration);
				AI.PushGoal(MyAnim.Name.."Delay","signal",0,1,"FIND_ANCHOR",0);
				-----
			entity:StartAnimation(0,MyAnim.Name);							
			entity:SelectPipe(0,MyAnim.Name.."Delay");
		else
			self:FIND_ANCHOR(entity,sender);
		end

	end,	
	------------------------------------------------------------------------ 	

	MAIN = function (self, entity, sender)
		entity:StartAnimation(0,self.AnimTable[self.TargetType][random(1,getn(self.AnimTable[self.TargetType]))]);
	end,
	---------------------------------------------
	DECISION_POINT = function( self,entity , sender)
	
	 	local rnd = random(1,10);
	 	
	 	--occasionaly decide enough with button pressing go back to real job
		if ( rnd < 4) then 
			if (entity.Properties.aibehavior_behaviour ==  "Job_Explain") then
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

 