--mutant eating corpse job
--Only applicable for mutantMonkey, mutantBezerker . Eats corpse looks around or beats chest eats some more
--
--Requires anchor AIANCHOR_DINNER	

-- Created 2003-01-17 Amanda
-- Reviewed 2003-03-19 Petar
--------------------------
AIBehaviour.MutantJob_Eating = {
	Name = "MutantJob_Eating",
	JOB = 1,

	------------------------------------------------------------------------ 	
	OnSpawn = function(self,entity)	
		local eat_spot = AI.FindObjectOfType(entity.id,10,AIAnchorTable.AIANCHOR_DINNER);		
	
		if (eat_spot == nil) then
			AI.Warning( "3[AI]Mutant entity "..entity:GetName().." was assigned an eat job, but no DINNER anchor was found");
			do return end;
		end
		
		entity:SelectPipe(0,"mutant_eat");
		entity:InsertAnimationPipe("eat_start");
		entity:InsertSubpipe(0,"approach_and_look_at",eat_spot);
	end,
	------------------------------------------------------------------------ 	
	PLAY_FEED_LOOP = function (self, entity, sender)

		local idle_anim = random(1,2);
		AI.Warning(" now playing eat_loop"..idle_anim);
		entity:InsertAnimationPipe("eat_loop"..idle_anim);
	end,
	------------------------------------------------------------------------ 	
	DECISION_POINT = function( self,entity , sender)
	 	local rnd = random(1,10);
		if (rnd < 5) then
		             entity:InsertAnimationPipe("eat_idle1");
 		end
	end,		
}
 