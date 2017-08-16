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


AIBehaviour.Job_ProneIdle = {
	Name = "Job_ProneIdle",				
	JOB = 1,	
			-----
	---------------------------------------------
	Constructor = function(self,entity )
		entity:InitAIRelaxed();
		entity:SelectPipe(0,"setup_prone");
		entity:InsertSubpipe(0,"DRAW_GUN");
	end,


	OnJobContinue = function(self,entity,sender )	
		self:OnSpawn(entity);
	end,

	
}


