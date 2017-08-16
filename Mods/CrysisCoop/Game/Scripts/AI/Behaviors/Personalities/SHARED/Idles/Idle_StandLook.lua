-- idle stand look
-- Created 2002-11-29 Amanda
-- look at something interesting on the wall fidget about a bit and then wander off
--------------------------

AIBehaviour.Idle_StandLook= {
	Name = "Idle_StandLook",
	JOB = 2,
	AnimTable = {[AIAnchorTable.AIANCHOR_LOOK_WALL]={"_idle_leanright","_idle_leanleft"}},
	TargetType = AIAnchorTable.AIANCHOR_LOOK_WALL,
	--------------------------
	Constructor = function(self,entity)	
--		AI.LogEvent("[".. entity:GetName() .."] Idle_StandLook+++++++++++++++++++++Spawned");
		entity.cnt.AnimationSystemEnabled = 1;
		self:FIND_ANCHOR(entity);	
	end,
	OnNoTarget = function(self,entity)	
		--AI.LogEvent("++++++++++++++++++++++++++++ OnNoTarget type");
	end,

	FIND_ANCHOR = function (self,entity)
--		AI.LogEvent("[".. entity:GetName().. "] Idle_StandLook++++++++++++called FIND_ANCHOR");
		--locate anchor of desired type
		entity.AI_FoundObject = AI.FindObjectOfType(entity.id,10,self.TargetType);		
		if (entity.AI_FoundObject) then
			entity:SelectPipe(0,"anchor_loop_idle",entity.AI_FoundObject);
		else
			AI.Signal(0,1, "BackToJob",entity.id);
			entity.EventToCall = "OnSpawn";
		end	
	end,

	Idle = function (self, entity, sender)
	--occasionaly choose a random idle	
		entity.cnt.AnimationSystemEnabled = 0;
		if (random(1,5) == 5) then
			local MyAnim = IdleManager:GetIdle();
				-----	
				AI.CreateGoalPipe(MyAnim.Name.."Delay");
				AI.PushGoal(MyAnim.Name.."Delay","timeout",1,MyAnim.duration);
				AI.PushGoal(MyAnim.Name.."Delay","signal",0,1,"FIND_ANCHOR",0);
				-----
			entity:StartAnimation(0,MyAnim.Name);							
			entity:InsertSubpipe(0,MyAnim.Name.."Delay");
		else
			self:FIND_ANCHOR(entity,sender);
		end

	end,	
	------------------------------------------------------------------------ 	

	MAIN = function (self, entity, sender)
		entity:StartAnimation(0,self.AnimTable[self.TargetType][random(1,2)]);
	end, 
	
	---------------------------------------------
	DECISION_POINT = function( self,entity , sender)
	
	 	local rnd = random(1,10);
	 	
	 	--finished looking time to wander off
		if ( rnd < 7) then
			entity:StartAnimation(0,self.AnimTable[self.TargetType][1]);
			entity:SelectPipe(0,"devalue_anchor",self.FoundObject);	
			AI.Signal(0,1, "BackToJob",entity.id);
			entity.EventToCall = "OnSpawn";	
--		-- or an idle animation	
		else 
			local MyAnim = IdleManager:GetIdle();
				-----	
				AI.CreateGoalPipe(MyAnim.Name.."Delay");
				AI.PushGoal(MyAnim.Name.."Delay","timeout",1,MyAnim.duration);
				AI.PushGoal(MyAnim.Name.."Delay","signal",0,1,"FIND_ANCHOR",0);
				-----
			entity:StartAnimation(0,MyAnim.Name);							
			entity:InsertSubpipe(0,MyAnim.Name.."Delay");		
		end
	end,
	---------------------------------------------

}