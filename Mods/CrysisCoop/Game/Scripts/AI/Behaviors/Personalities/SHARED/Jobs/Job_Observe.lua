-- observe behaviour - 
-- Created by Sten; 18-09-2002
-- Modified by Petar; 
--------------------------


AIBehaviour.Job_Observe = {
	Name = "Job_Observe",
	JOB = 1,
	
	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self,entity )
		entity:InitAIRelaxed();
	
		local dh=entity:GetName().."_OBSERVE";

		-- try to get tagpoint of the same name as yourself first
		local TagPoint = System.GetEntityByName(dh);		
 		if (TagPoint==nil) then
			-- try to fish for a observation anhor within 2 meter from yourself
			dh = AI.FindObjectOfType(entity.id,20,AIAnchorTable.ACTION_OBSERVE);
		end
		if(dh and dh~="") then
			entity:SelectPipe(0,"observe_direction",dh);
			if (TagPoint or dh) then
				entity:InsertSubpipe(0,"patrol_approach_to",dh);
			end
			entity:InsertSubpipe(0,"setup_idle");	-- get in correct stance
		else
			AI.Warning(entity:GetName().." couldn't find anchor ACTION_OBSERVE or tagpoint "..entity:GetName().."_OBSERVE for Job_Observe");
		end
	end,

	OnJobContinue = function(self,entity,sender)
		self:OnSpawn(entity);
	end,
	----------------------------------------------------	
	OnBored = function (self, entity)
		entity:MakeRandomConversation();
		entity.cnt:CounterSetValue("Boredom", 0 );
	end,
	----------------------------------------------------FUNCTIONS 
--	DO_SOMETHING_IDLE = function (self, entity, sender)
--		local rnd = random(1,10);
--		if (rnd > 7) then 
--			if (entity:DoSomethingInteresting() == nil) then
--				entity:MakeRandomIdleAnimation();
--			end
--		else
--			entity:MakeRandomIdleAnimation();
--		end
--	end,

	FOLLOW_ME = function (self, entity, sender)
		entity:SelectPipe(0,"simple_follow");
		entity:InsertSubpipe(0,"follow_leader");
		
	end,


}