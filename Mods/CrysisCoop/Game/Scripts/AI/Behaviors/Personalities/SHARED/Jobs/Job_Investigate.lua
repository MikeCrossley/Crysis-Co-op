-- Created by Petar; 
--------------------------


AIBehaviour.Job_Investigate = {
	Name = "Job_Investigate",
	JOB = 1,
	alertness = 1,
	
	-- SYSTEM EVENTS			-----
	---------------------------------------------

	Constructor = function(self,entity )
--		entity.AI_GunOut = 1;
		entity:HolsterItem(false);
		entity:SelectPipe(0,"investigate_wrapper");
		entity:InsertSubpipe(0,"setup_stealth");	-- get in correct stance
	end,


	TAKE_NEXT_INVESTIGATION_POINT = function(self,entity )

		local dh = AI.FindObjectOfType(entity.id,30,AIAnchorTable.INVESTIGATE_HERE);

		if (dh) then
			entity:InsertSubpipe(0,"investigate_to",dh);
		end

		
	end,

	OnJobContinue = function(self,entity,sender)
		self:OnSpawn(entity);
	end,

	OnJobExit = function(self,entity,sender)
	end,



}