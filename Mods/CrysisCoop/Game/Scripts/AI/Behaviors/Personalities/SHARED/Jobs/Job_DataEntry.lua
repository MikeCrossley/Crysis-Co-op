-- data entry job
-- Created 2002-11-28 Amanda
-- to do: sit down at console type in various write some stuff down get frustrated ocassionaly 
--stand up and run idle then sit back down again
--------------------------
AIBehaviour.Job_DataEntry = {
	Name = "Job_DataEntry",
	JOB = 1,
	AnimTable = { [AIAnchorTable.AIANCHOR_SIT_WRITE] = {
			loop ="sit_writing_loop",
			idles = {"sit_writing_idle1","sit_writing_idle2","sit_writing_idle3","sit_hitdesk"},
			 },
		[AIAnchorTable.AIANCHOR_SIT_TYPE] = {
			loops = {"sit_typing_loop","sit_typing_onehanded"},
			idles = {"sit_typing_idle1","sit_typing_idle2","sit_hitdesk","sit_hitmonitor"},
			},
		[AIAnchorTable.AIANCHOR_CHAIR] = {"sitdown","sitdown_legup","situp"},
		angry = {"sit_hitdesk","sit_hitmonitor"},
	},
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
	-- make sure doesnt leave job with chair attached and no gun
	------------------------------------------------------------------------ 	
	OnJobExit = function( self, entity )
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
--			AI.LogEvent("\001["..entity:GetName().."] Job_DataEntry+++++++++++++++FIND_CHAIR found chair");
			entity:SelectPipe(0,"anchor_traceChair",entity.AI_Chair);
		elseif (entity.Properties.aibehavior_behaviour =="Job_DataEntry") then
			self:Idle(entity,sender);
		else
			AI.Signal(0,1, "BackToJob",entity.id);
			entity.EventToCall = "OnSpawn";
		end	
	end,
	------------------------------------------------------------------------ 	
	FIND_ANCHOR = function (self,entity)
		--choose whether to write or type
		if (random(1,2) == 1) then 
			entity.AI_TargetType = AIAnchorTable.AIANCHOR_SIT_WRITE;
		else
			entity.AI_TargetType = AIAnchorTable.AIANCHOR_SIT_TYPE;
		end
		--locate anchor of desired type
		entity.AI_FoundObject= AI.FindObjectOfType(entity.id,3,entity.AI_TargetType);
		
		if (entity.AI_FoundObject) then
			entity:SelectPipe(0,"bindChair_trace",entity.AI_FoundObject);
		else
		         if (entity.AI_TargetType==AIAnchorTable.AIANCHOR_SIT_WRITE) then
			entity.AI_TargetType = AIAnchorTable.AIANCHOR_SIT_TYPE;
		         else
		       	 entity.AI_TargetType = AIAnchorTable.AIANCHOR_SIT_WRITE;
		         end
		        entity.AI_FoundObject= AI.FindObjectOfType(entity.id,2,entity.AI_TargetType);
		      if (entity.AI_FoundObject) then
			entity:SelectPipe(0,"bindChair_trace",entity.AI_FoundObject);
		      else
		      	entity:InsertSubpipe(0,"beat");
		      end
		end	
	end,
	------------------------------------------------------------------------ 	
	Idle = function (self, entity, sender)
	--occasionaly choose a random idle	
		entity.cnt.AnimationSystemEnabled = 0;
		if (random(1,5) == 5) then
			local MyAnim = Mutant_IdleManager:GetIdle(entity);
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
	START_TASK = function (self, entity, sender)
		entity.cnt.AnimationSystemEnabled = 0;
		entity:SelectPipe(0,"loop_break");
	end, 
	------------------------------------------------------------------------ 	

	SITDOWN_ANIM = function (self, entity, sender)
		entity:StartAnimation(0,self.AnimTable[AIAnchorTable.AIANCHOR_CHAIR][random(1,2)]);
	end, 
	------------------------------------------------------------------------ 	
	MAIN = function (self, entity, sender)
		if (self.AnimTable[entity.AI_TargetType]["loop"]) then
			entity:StartAnimation(0,self.AnimTable[entity.AI_TargetType]["loop"]);
		else
			entity:StartAnimation(0,self.AnimTable[entity.AI_TargetType]["loops"][random(1,getn(self.AnimTable[entity.AI_TargetType]["loops"]))]);
		end
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
		if ( rnd < 4 ) then 
			entity:StartAnimation(0,self.AnimTable["angry"][random(1,getn(self.AnimTable["angry"]))]);
		-- or bored enough to take a break	
		elseif ( rnd == 4 ) then		
			entity:SelectPipe(0,"anchor_SitUp_Bored");
		-- or choose one of the related idles	
		elseif (entity.AI_TargetType) then		
			entity:StartAnimation(0,self.AnimTable[entity.AI_TargetType]["idles"][random(1,getn(self.AnimTable[entity.AI_TargetType]["idles"]))]);
			entity:InsertSubpipe(0,"pause");	
		end
	end,
	------------------------------------------------------------------------ 	
	BORED_BORED = function (self, entity, sender)
		entity:SelectPipe(0,"beat");
		if (random(1,3) == 2) then
			entity:MakeRandomConversation();
		else
			local boredAnchor = AI_BoredManager:FindAnchor(entity,AI_BoredManager.AIBORED_SCIENTIST,10);
			if (boredAnchor) then
				AI.Signal(0,1, boredAnchor.signal,entity.id);
				entity.EventToCall = "OnSpawn";
			else
				AI.Signal(0,1, "Idle",entity.id);
			end
		end
	end,
	------------------------------------------------------------------------ 	
	BIND_CHAIR_TO_ME = function( self,entity, sender )
		local	myDim = {
			height = 2.2,
			eye_height = 2.1,
			ellipsoid_height = 1.9,
			x = 0.010,
			y = 0.010,
			z = 0.07,
		};	
		local chairName = AI.FindObjectOfType(entity.id,3,AIAnchorTable.AIOBJECT_SWIVIL_CHAIR);
		if (chairName) then
			entity.AI_BoundObject = System.GetEntityByName(chairName);--see ScriptObjectSystem

			if (entity.AI_BoundObject) then
				entity.AI_BoundObject:SetPos({x = 0, y = 0.5, z = 0});
				entity.AI_BoundObject:SetAngles({x = 0, y = 0, z = 0});
				entity:Bind(entity.AI_BoundObject);
				entity.cnt:SetDimOverride( myDim );
			else
				AI.Signal(0,1, "Idle",entity.id);
			end
		else
			AI.Signal(0,1, "Idle",entity.id);
		end
	end,
	------------------------------------------------------------------------ 	
	UNBIND_CHAIR = function( self,entity, sender )
		entity.cnt.AnimationSystemEnabled = 1;
		entity:StartAnimation(0,self.AnimTable[AIAnchorTable.AIANCHOR_CHAIR][3]);
		if (entity.AI_BoundObject) then
			local mypos = entity:GetPos();
			mypos.x = mypos.x - .8;
		--	mypos.y = mypos.y - .8;
			entity:Unbind(entity.AI_BoundObject);
			entity.AI_BoundObject:SetPos(mypos);
			entity.AI_BoundObject:SetAngles({x=0,y=0,z=90});
			entity.cnt:SetDimOverride( Grunt.PlayerDimNormal );
			entity.AI_BoundObject:AwakePhysics(1);
		end
	end,		
}

 