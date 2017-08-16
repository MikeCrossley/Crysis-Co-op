-- inspect apparatus mark off on clipboard
--Select behavior Job_CheckApparatus. AI will move from AIANCHOR_CLIPBOARD anchor to 
--clipboard anchor looking at whatever making notes. 
-- optional sub hevaiours 
--	AIANCHOR_PULL, AIANCHOR_PUSHBUTTON, AIANCHOR_MICROSCOPE, AIANCHOR_BEAKER
--	if finds one of these anchors within 10m will run sub behaviour then came back and note down.
--
--Requires: AIANCHOR_CLIPBOARD as many as you like

--TODO integrate job_explain sub behaviour 
--integrate random chat and bored anchors
-- Created 2002-10-08 Amanda
--------------------------
AIBehaviour.Job_CheckApparatus = {
	Name = "Job_CheckApparatus",
	JOB = 1,
	AnimTable ={
		[AIAnchorTable.AIANCHOR_CLIPBOARD]= {"clipboard_start","clipboard_breathing_loop","clipboard_writing_loop","clipboard_end"},
		},
	TargetType = AIAnchorTable.AIANCHOR_CLIPBOARD,
	--------------------------
	Constructor = function(self,entity)	
		entity.cnt.AnimationSystemEnabled = 1;
		self:FIND_ANCHOR(entity);	
	end,
	------------------------------------------------------------------------ 
	OnNoTarget = function(self,entity)	
	end,
	------------------------------------------------------------------------ 	
	OnJobExit = function( self, entity )
	-- make sure doesnt leave job with crate attached and no gun
		entity.cnt.AnimationSystemEnabled = 1;
		AIBehaviour.DEFAULT:UNHIDE_GUN(entity,sender);
		entity:InsertSubpipe(0,"force_reevaluate");	
	end,
	------------------------------------------------------------------------ 	
	FIND_ANCHOR = function (self,entity)
		--locate anchor of desired type
		local foundObject = AI.FindObjectOfType(entity.id,10,self.TargetType);
 		if (foundObject) then
			entity:SelectPipe(0,"anchor_animation_devalue",foundObject);
		else
			if (entity.Properties.aibehavior_behaviour == "Job_CheckApparatus") then
				self:Idle(entity,sender);
			else
				entity:SelectPipe(0,"beat");
			 	AI.Signal(0,1, "BackToJob",entity.id);
			 	entity.EventToCall = "OnSpawn";
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
	START_ANIM = function (self, entity, sender)
		entity:StartAnimation(0,self.AnimTable[self.TargetType][1]);
	end, 
	------------------------------------------------------------------------ 
	LOOP_ANIM = function (self, entity, sender)
		entity:StartAnimation(0,self.AnimTable[self.TargetType][random(2,3)]);
	end,		
	------------------------------------------------------------------------
	END_ANIM = function (self, entity, sender)
		entity:StartAnimation(0,self.AnimTable[self.TargetType][4]);
	end,
	---------------------------------------------
	DECISION_POINT = function( self,entity , sender)	
	 	local rnd = random(1,10);	 	
	 	--occasionaly run clipboard idle
		if ( rnd < 4) then 
			local idx = random(1,2);
			entity:StartAnimation(0,"clipboard_idle"..idx);
			entity:InsertSubpipe(0,"pause");	
			
		-- or bored enough to take a break	
		elseif (rnd == 4) then		
			entity:SelectPipe(0,"beat");
			local boredAnchor = AI_BoredManager:FindAnchor(entity,AI_BoredManager.AIBORED_SCIENTIST,10);
			if (boredAnchor) then
				AI.Signal(0,1, boredAnchor.signal,entity.id);
				entity.EventToCall = "OnSpawn";
			else
				self:Idle(entity,sender);
			end
		elseif (rnd == 5) then
			entity:MakeRandomConversation();
		-- or look for apparatus to peer at and make notes
		elseif (rnd < 9) then	
			entity:SelectPipe(0,"beat");
			local jobAnchor = AI_JobManager:FindAnchor(entity,AI_JobManager.AIJob_CHECK_APPARATUS,10);
			if (jobAnchor ) then
				AI.Signal(0,1, jobAnchor.signal,entity.id);
 				entity.EventToCall = "OnSpawn";
 			else
 				self:Idle(entity,sender);
			end		
--		-- or an idle animation	
		elseif (rnd>8) then	
			self:Idle(entity,sender);		
		end
	end,
	---------------------------------------------	
	MARKOFF_CLIPBOARD = function (self,entity,sender)
		entity:SelectPipe(0,"animation_cycle");	
	end,		
}

 