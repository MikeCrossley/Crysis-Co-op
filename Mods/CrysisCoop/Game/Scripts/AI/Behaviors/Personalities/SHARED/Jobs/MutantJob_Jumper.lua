-- node patroling behaviour - 
-- should be retired now same as job_patrolNode.lua
-- version 1 - amanda 2003-01-18
--------------------------


AIBehaviour.MutantJob_Jumper= {
	Name = "MutantJob_Jumper",
	JOB = 1,
	
	---------------------------------------------
	-- SYSTEM EVENTS			
	---------------------------------------------
	OnSpawn = function(self,entity )
		entity.AI_SpecialPoints=0;
	end,

	OnActivate = function(self,entity )

		entity:SelectPipe(0,"standingthere");
		
		local jmp_name = entity:GetName().."_JUMP"..entity.AI_SpecialPoints;
		local TagPoint = Game:GetTagPoint(jmp_name);


		if (TagPoint~=nil) then 	
			--AI.LogEvent("\001 found point "..jmp_name);
			entity:MutantJump();
		else
			AI.LogEvent("COULD NOT FIND POINT "..jmp_name);
		end

	end,

	BACK_TO_ATTACK = function(self,entity,sender)
		--AI.LogEvent("\001 BACK TO ATTACK CALLED");
		--entity.AI_SpecialPoints = entity.AI_SpecialPoints+1;
		self:OnActivate(entity);
	end
	
}

 