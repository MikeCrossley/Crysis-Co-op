-- just sit down and breath a bit
-- Created 2002-11-28 Amanda
-- to do: sit down if you find magazine read it otherwise just stay seated.
--------------------------
AIBehaviour.Job_SitDown = {
	Name = "Job_SitDown",
	JOB = 1,
	AnimTable = {
		[AIAnchorTable.AIANCHOR_MAGAZINE] = {"magazine1","magazine2","magazine3"},
		[AIAnchorTable.AIANCHOR_CHAIR] = {"sitdown","sitdown_legup","situp"},
		none = {"sitdown_breath"},
	},
	TargetType = AIAnchorTable.AIANCHOR_MAGAZINE,
	--------------------------
	Constructor = function(self,entity)	
	 	entity.cnt.AnimationSystemEnabled = 1;
		self:FIND_CHAIR(entity);	
	end,
	------------------------------------------------------------------------ 	
	OnNoTarget = function(self,entity)	
		--AI.LogEvent("++++++++++++++++++++++++++++ OnNoTarget type");
	end,
	------------------------------------------------------------------------ 	
-	OnJobExit = function( self, entity )
	-- make sure doesnt leave job with no gun
		entity.cnt.AnimationSystemEnabled = 1;
		self:UNBIND_CHAIR(entity,sender);
		AIBehaviour.DEFAULT:UNHIDE_GUN(entity,sender);
		entity:InsertSubpipe(0,"force_reevaluate");		
	end,	
	------------------------------------------------------------------------ 	
	FIND_CHAIR = function (self,entity)
		if (entity.AI_Chair == nil) then
			entity.AI_Chair= AI.FindObjectOfType(entity.id,10,AIAnchorTable.AIANCHOR_CHAIR);
		end
		
		if (entity.AI_Chair) then
 			entity:SelectPipe(0,"anchor_traceChair",entity.AI_Chair);
		elseif (entity.Properties.aibehavior_behaviour == "Job_SitDown") then
			self:Idle(entity,sender);
		else
			AI.Signal(0,1, "BackToJob",entity.id);
			entity.EventToCall = "OnSpawn";
		end	
	end,
	------------------------------------------------------------------------ 	
	FIND_ANCHOR = function (self,entity)
		entity:SelectPipe(0,"bindChair");
	end,
	------------------------------------------------------------------------ 	
	Idle = function (self, entity, sender)
	--occasionaly choose a random idle	
		entity.cnt.AnimationSystemEnabled = 0;
		local MyAnim = Mutant_IdleManager:GetIdle(entity);
		-----	
		AI.CreateGoalPipe(MyAnim.Name.."Delay");
		AI.PushGoal(MyAnim.Name.."Delay","timeout",1,MyAnim.duration);
		AI.PushGoal(MyAnim.Name.."Delay","signal",0,1,"FIND_ANCHOR",0);
		-----
		entity:StartAnimation(0,MyAnim.Name);							
		entity:InsertSubpipe(0,MyAnim.Name.."Delay");
	end,	
	------------------------------------------------------------------------ 	
	START_TASK = function (self, entity, sender)
 		entity.AI_FoundObject = AI.FindObjectOfType(entity.id,1,self.TargetType);
		if (entity.AI_FoundObject == nil) then
			self.TargetType="none";
		end
		
		entity.cnt.AnimationSystemEnabled = 0;
		entity:SelectPipe(0,"loop_break");
	end, 
	------------------------------------------------------------------------ 	

	SITDOWN_ANIM = function (self, entity, sender)
		entity.cnt.AnimationSystemEnabled = 0;
		entity:StartAnimation(0,self.AnimTable[AIAnchorTable.AIANCHOR_CHAIR][random(1,2)]);
		entity:SelectPipe(0,"start_task");
	end, 
	------------------------------------------------------------------------ 	
	MAIN = function (self, entity, sender)
		entity.cnt.AnimationSystemEnabled = 0;
		local choices=getn(self.AnimTable[self.TargetType]);
		entity:StartAnimation(0,self.AnimTable[self.TargetType][random(1,choices)]);
	end,
	------------------------------------------------------------------------
	SITUP_ANIM = function (self, entity, sender)
		entity.cnt.AnimationSystemEnabled = 1;
		entity:StartAnimation(0,self.AnimTable[AIAnchorTable.AIANCHOR_CHAIR][3]);
	end,
	---------------------------------------------
	DECISION_POINT = function( self,entity , sender)
	--decide whether or not to run a related idle, lose temper or get up and go for an idle
	 	local rnd = random(1,15);	
		if ( rnd == 4 ) then		
			entity:SelectPipe(0,"anchor_SitUp_Bored");
		end
	end,
	------------------------------------------------------------------------ 	
	BORED_BORED = function (self, entity, sender)
		entity:SelectPipe(0,"beat");
		local boredAnchor = AI_BoredManager:FindAnchor(entity,AI_BoredManager.AIBORED_SCIENTIST,10);
		if (boredAnchor) then
			AI.Signal(0,1, boredAnchor.signal,entity.id);
			entity.EventToCall = "OnSpawn";
		else
			self:Idle(entity,sender);
		end
	end,
	------------------------------------------------------------------------ 	
	BIND_CHAIR_TO_ME = function( self,entity, sender )	
		local chairName = AI.FindObjectOfType(entity.id,5,AIAnchorTable.AIOBJECT_SWIVIL_CHAIR);
		if (chairName) then
			entity.AI_BoundObject = System.GetEntityByName(chairName);--see ScriptObjectSystem
			if (entity.AI_BoundObject) then
				entity.AI_BoundObject:SetPos({x = 0, y = 0.6, z = 0});
				entity.AI_BoundObject:SetAngles({x = 0, y = 0, z = 0});
				entity:Bind(entity.AI_BoundObject);
			else
				self:Idle(entity,sender);
			end
		else
 			self:Idle(entity,sender);
		end
		AI.Signal(0,1, "SITDOWN_ANIM",entity.id);
	end,
	------------------------------------------------------------------------ 	
	UNBIND_CHAIR = function( self,entity, sender )
		entity.cnt.AnimationSystemEnabled = 1;
		entity:StartAnimation(0,self.AnimTable[AIAnchorTable.AIANCHOR_CHAIR][3]);
	--	entity:ActivatePhysics(1);
		if (entity.AI_BoundObject) then
			local mypos = entity:GetPos();
			mypos.x = mypos.x - .5;
		--	mypos.y = mypos.y - .8;
			entity:Unbind(entity.AI_BoundObject);			
			entity.AI_BoundObject:SetPos(mypos);
			entity.AI_BoundObject:SetAngles({x=0,y=0,z=90});
			--entity.AI_BoundObject:SetAngles({x=0,y=0,z=0});
			entity.AI_BoundObject:AwakePhysics(1);
		end
	end,
			
}

 