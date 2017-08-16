--A character with this behavior will look at 20 meters around him to find an AIAnchorTable AIANCHOR_FENCE.
-- If successful he will approach this anchor 
--	run  _fixfence_start 
--	run _fixfence_loop once and then decide whether to continue looping for 1 to 5 seconds
--	OR run fixfence idle
--When he receives onBored event he will 
--	run _fixfence_end
--	look for run random idle appropriate to character
--	OR look around for an idle anchor within 10m 
--		looks for AIANCHOR_PISS, AIANCHOR_SMOKE, AIANCHOR_SEAT,AIANCHOR_LOOK_WALL
--		if one of these is found AI will run the associated sub behaviour
--	OR look for an AIANCHOR_RANDOM_TALK if AI finds one of these will try to initiate conversation
-- Then cycles back to top.

--------------------------
AIBehaviour.Job_FixFence = {
	Name = "Job_FixFence",
	JOB = 2,
	TargetType = AIAnchorTable.AIANCHOR_FENCE,
	AnimTable = {"_fixfence_start","_fixfence_loop","_fixfence_end","_fixfence_idle01"},	
	------------------------------------------------------------------------ 	
	Constructor = function(self,entity)	
		-- create correct length delay pipes for start and end
		local character = entity.Properties.aicharacter_character.."FixFence";
		
		--create start pipe
		local duration = entity:GetAnimationLength(0, self.AnimTable[1]);
		if (duration == nil) then 
			duration = 0.4;
		end
		AI.CreateGoalPipe(character..self.AnimTable[1]);
		AI.PushGoal(character..self.AnimTable[1],"timeout",1,duration);
		
		--create end pipe
		duration = entity:GetAnimationLength(0, self.AnimTable[3]);
		if (duration == nil) then 
			duration = 0.4;
		end
		AI.CreateGoalPipe(character..self.AnimTable[3]);
		AI.PushGoal(character..self.AnimTable[3],"timeout",1,duration);
		
		--create loop pipe
		duration = entity:GetAnimationLength(0, self.AnimTable[2]);
		if (duration == nil) then 
			duration = 0.7;
		end
		
		AI.CreateGoalPipe(character..self.AnimTable[2]);
		AI.PushGoal(character..self.AnimTable[2],"timeout",1,duration);
		AI.PushGoal(character..self.AnimTable[2],"signal",0,1,"DECISION_POINT",0);		
 		AI.PushGoal(character..self.AnimTable[2],"signal",0,1,"LOOP_ANIM",0);
 		
 		AI.CreateGoalPipe(character.."Variable");
		AI.PushGoal(character.."Variable","timeout",1,2.1,4.9);
--duration = entity:GetAnimationLength(0, self.AnimTable[4]);
--AI.LogEvent("\003["..entity:GetName() .."] Job_FixFence<<<<<<<<<<<<<<<duration["..duration.."]");
 		AI.CreateGoalPipe(character.."Idle");
		AI.PushGoal(character.."Idle","timeout",3.96);
						
		self:FIND_ANCHOR(entity);	
	end,
	------------------------------------------------------------------------ 
 	OnBored = function(self,entity)	
 --	AI.LogEvent("\003["..entity:GetName() .."] Job_FixFence<<<<<<<<<<<<<<<OnBored");
 		local rnd = random(1,4);
 		if (rnd == 1) then
 			entity:SelectPipe(0,"animation_takeBreak");
 		elseif (rnd == 2) then
			entity:MakeRandomConversation();
		else
		 	 local boredAnchor = AI_BoredManager:FindAnchor(entity,AI_BoredManager.AIBORED_OUTDOOR_GRUNT,10);
			if (boredAnchor) then
				AI.Signal(0,1, boredAnchor.signal,entity.id);
				entity.EventToCall = "OnSpawn";
			end
		end
	end,
	------------------------------------------------------------------------ 	
	OnNoTarget = function(self,entity)	
	end,
	------------------------------------------------------------------------
	OnJobExit = function( self, entity )
	-- make sure doesnt leave job with no gun
--	AI.LogEvent("\003["..entity:GetName() .."] Job_FixFence<<<<<<<<<<<<<<<OnJobExit");
--		entity.cnt.AnimationSystemEnabled = 1;
		AIBehaviour.DEFAULT:UNHIDE_GUN(entity,sender);
		entity:SelectPipe(0,"randomhide");
		entity:InsertSubpipe(0,"force_reevaluate");		
	end,
	------------------------------------------------------------------------	
	FIND_ANCHOR = function (self,entity)
		entity.AI_FoundObject = AI.FindObjectOfType(entity.id,10,self.TargetType);
		
		if (entity.AI_FoundObject) then
			entity:SelectPipe(0,"anchor_set_animation",entity.AI_FoundObject);
		else
			self:IDLE_ANIMATION(entity,sender);
		end	
	end,
	------------------------------------------------------------------------ 	
	IDLE_ANIMATION = function (self, entity, sender)
	--occasionaly choose a random idle
--	AI.LogEvent("\003["..entity:GetName() .."] Job_FixFence<<<<<<<<<<<<<<< IDLE_ANIMATION");
		local MyAnim = Mutant_IdleManager:GetIdle(entity);
			AI.CreateGoalPipe(MyAnim.Name.."Delay");
			AI.PushGoal(MyAnim.Name.."Delay","timeout",1,MyAnim.duration);
			AI.PushGoal(MyAnim.Name.."Delay","timeout",1,1,5);
			AI.PushGoal(MyAnim.Name.."Delay","signal",0,1,"FIND_ANCHOR",0);
			-----
		entity:StartAnimation(0,MyAnim.Name,4);							
		entity:SelectPipe(0,MyAnim.Name.."Delay");

	end,	
	------------------------------------------------------------------------ 	
	START_ANIM = function (self, entity, sender)
--	AI.LogEvent("\003["..entity:GetName() .."] Job_FixFence<<<<<<<<<<<<<<< START_ANIM");
--		entity.cnt.AnimationSystemEnabled = 0;	
		entity:StartAnimation(0,self.AnimTable[1],4);
		entity:InsertSubpipe(0,entity.Properties.aicharacter_character.."FixFence"..self.AnimTable[1],2);
	end, 
	------------------------------------------------------------------------ 	
	LOOP_ANIM = function (self, entity, sender)
--	AI.LogEvent("\003["..entity:GetName() .."] Job_FixFence <<<<<<<<<<<<<<<LOOP_ANIM");
		entity:StartAnimation(0,self.AnimTable[2],4);
		entity:SelectPipe(0,entity.Properties.aicharacter_character.."FixFence"..self.AnimTable[2],2);
	end,
	------------------------------------------------------------------------
	END_ANIM = function (self, entity, sender)
--	AI.LogEvent("\003["..entity:GetName() .."] Job_FixFence <<<<<<<<<<<<<<<END_ANIM");
		entity:StartAnimation(0,self.AnimTable[3],4);
		entity:InsertSubpipe(0,entity.Properties.aicharacter_character.."FixFence"..self.AnimTable[3],2);
		entity.cnt.AnimationSystemEnabled = 1;
	end,
	------------------------------------------------------------------------ 	
	DECISION_POINT = function( self,entity , sender)
 		
 	 	local rnd = random(1,3);
		--bored enough to take a break	
		if (rnd == 1) then
--		             AI.LogEvent("\003["..entity:GetName() .."] Job_FixFence <<<<<<<<<<<<<<<idle_ANIM");
		             entity:StartAnimation(0,self.AnimTable[4],4);
		             entity:InsertSubpipe(0,entity.Properties.aicharacter_character.."FixFenceIdle");
		else
		             entity:InsertSubpipe(0,entity.Properties.aicharacter_character.."FixFenceVariable");
		end
	end,			
}

 