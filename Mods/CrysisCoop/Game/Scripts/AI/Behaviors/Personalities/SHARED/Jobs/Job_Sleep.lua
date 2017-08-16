
-- created by petar
--------------------------


AIBehaviour.Job_Sleep = {
	Name = "Job_Sleep",				


	---------------------------------------------
	Constructor = function(self,entity )
		entity:InitAIRelaxed();

		local name = AI.FindObjectOfType(entity.id,50,AIAnchorTable.SLEEP);
		if (name) then 
			entity:SelectPipe(0,"go_to_sleep",name);	
		else
			AI.LogEvent("\002 Entity "..entity:GetName().." was told to sleep but found no SLEEP anchor within 50 meters");
		end


		entity:InsertSubpipe(0,"setup_idle");
	end,


	LAY_DOWN = function(self,entity,sender)
		entity:SelectPipe(0,"sleep");
		entity.cnt.AnimationSystemEnabled = 0;
		entity:StartAnimation(0,"sleeping_loop",0);
		entity:StartAnimation(0,"sleeping_start",0);
	end,
	
}


