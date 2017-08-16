-- May run as sub behaviour called from Job_CheckApparatus in response to AIANCHOR_PULL
-- used for worker characters eg. scientist, lab assistant, evil worker
--
-- A character with this behavior will look at 20 meters around him to find an AIAnchorTable AIANCHOR_PULL.
-- If successful he will approach this anchor 
--	run  one of the pull animations
--	Devalue anchor so will not return to this anchor for a period of time - this forces AI to move between anchors
-- At decision point will decide to either
--	return to main job if has one OR idle if not
--	OR run a random idle animation appropriate to character
--	OR go straight to next anchor
-- Then cycles back to top.
--
--When he receives onBored event he will 
--	OR look around for an idle anchor within 10m 
--		looks for AIANCHOR_SMOKE, AIANCHOR_SEAT,AIANCHOR_LOOK_WALL, AIANCHOR_PISS, 
--		if one of these is found AI will run the associated sub behaviour
--	OR look for an AIANCHOR_RANDOM_TALK if AI finds one of these will try to initiate conversation
-- Created 2002-12-03 Amanda
--------------------------
AIBehaviour.Job_PullLever = {
	Name = "Job_PullLever",
	JOB = 2,
	AnimTable ={
		[AIAnchorTable.AIANCHOR_PULL]= {"pull_Lever","pull_Lever","pull_Lever","pull_Lever","push_hit_machine"},
		},
	TargetType = AIAnchorTable.AIANCHOR_PULL,
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
		AIBehaviour.DEFAULT:UNHIDE_GUN(entity,sender);
		entity:InsertSubpipe(0,"force_reevaluate");		
	end,	
	------------------------------------------------------------------------ 	
 	OnBored = function(self,entity)	
 		rnd = random(1,2);
		if (rnd == 1) then
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
 		--	AI.LogEvent("\003["..entity:GetName() .."] Job_PullLever<<<<<<<<<<<<<<<FIND_ANCHOR");
 			entity:SelectPipe(0,"anchor_loop_devalue",foundObject);
		else
			if (entity.Properties.aibehavior_behaviour == "Job_PullLever") then
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
		entity:StartAnimation(0,self.AnimTable[self.TargetType][random(1,getn(self.AnimTable[self.TargetType]))]);
	end,
	---------------------------------------------
	DECISION_POINT = function( self,entity , sender)
	
	 	local rnd = random(1,10);
	 	
	 	--occasionaly decide enough with button pressing go back to real job
		if ( rnd < 4) then 
			if (entity.Properties.aibehavior_behaviour ==  "Job_PullLever") then
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

 