-- stand still and look around with binoculars between using idle animations.
-- 
-- place a AIANCHOR_RANDOM_TALK if you want him to try and talk to his fellows occasionaly
-- place an idle anchor within 5 meters eg  AIANCHOR_PISS, AIANCHOR_SMOKE, AIANCHOR_SEAT,AIANCHOR_LOOK_WALL
--	if you want him to choose idle behaviour. 
--
-- version 2002-10-12 Amanda based on Job_Observe - 
--	alternate between looking with binoculars and run thru idles without turning
--
-- modified by petar (shortened and cleaned up)
--------------------------


AIBehaviour.Job_StandIdle = {
	Name = "Job_StandIdle",				
	JOB = 1,	
			-----
	---------------------------------------------
	Constructor = function(self,entity )

--		AI.LogEvent(entity:GetName().." STAND IDLE");
		g_StringTemp1 = tostring(entity.Properties.aicharacter_character).."Idle";
		local defaultBehavior = AIBehaviour[g_StringTemp1];
		if(defaultBehavior and defaultBehavior ~= AIBehaviour.Job_StandIdle and defaultBehavior.Constructor) then 
			defaultBehavior:Constructor(entity);
		else			
			if ( entity.AI and entity.AI.needsAlerted ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "INCOMING_FIRE",entity.id);
				entity.AI.needsAlerted = nil;
			end	
		end
		
		entity:InitAIRelaxed();
		entity:SelectPipe(0,"stand_only");
		entity:InsertSubpipe(0,"setup_idle");
		entity:InsertSubpipe(0,"clear_all"); -- to allow receive again onplayerseen 

--		if (entity.Properties.special == 1) then 
--			AI.Signal(0,0,"SPECIAL_GODUMB",entity.id)
--		end
	end,

	Destructor = function(self, entity)
		entity:StopConversation();
	end,


	OnJobContinue = function(self,entity,sender )	
		self:Constructor(entity);
	end,

	OnBored = function (self, entity)
		AI.LogEvent(entity:GetName().." is BORED");
		entity:MakeRandomConversation();
	end,	


}


