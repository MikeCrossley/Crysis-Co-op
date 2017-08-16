-- fix car job
--AI will go through the motions of moving to each AIANCHOR_WHEEL and tightening the wheel nuts on the car, 
--or going to the AIANCHOR_HOOD to fix the hood. 
--Every now and again the AI will go to AIANCHOR_TOOLBOX and bring back a tool.
--	OR loook for a bored anchor
--	
--
--NB. AIANCHOR_WHEEL is suited to fixing a wheel attached to a vehicle, for a wheel that is removed / lying flat use AIANCHOR_HOOD with the anchor pointing up. The animation associated with AIANCHOR_HOOD is just a general fixing motion.
--
--Requires:  One or more of following within radius of 20m.
--	AIANCHOR_WHEEL 
--	AIANCHOR_HOOD
--      	 AIANCHOR_TOOLBOX
--
--Optional: Within radius of 20m.
--	looks for AIANCHOR_PISS, AIANCHOR_SMOKE, AIANCHOR_SEAT,AIANCHOR_LOOK_WALL

-- Created 2002-10-08 Amanda
--------------------------
AIBehaviour.Job_FixCar = {
	Name = "Job_FixCar",
	JOB = 1,
	AnimTable =		{
					[AIAnchorTable.AIANCHOR_WHEEL] = {"_fixwheel_start","_fixwheel_loop","_fixwheel_end"},
				 	[AIAnchorTable.AIANCHOR_HOOD] = {"_fixfence_start","_fixfence_loop","_fixfence_end"},
				},
	TargetType = AIAnchorTable.AIANCHOR_WHEEL,
	------------------------------------------------------------------------ 	
	Constructor = function(self,entity)	
		entity.cnt.AnimationSystemEnabled = 1;
		self:FIND_ANCHOR(entity);	
	end,
	------------------------------------------------------------------------ 	
	OnNoTarget = function(self,entity)	
	end,
	------------------------------------------------------------------------ 	
	OnJobExit = function( self, entity )
	-- make sure doesnt leave job with no gun
		entity.cnt.AnimationSystemEnabled = 1;
		AIBehaviour.DEFAULT:UNHIDE_GUN(entity,sender);
		entity:InsertSubpipe(0,"force_reevaluate");	
	end,
	------------------------------------------------------------------------  		
	FIND_ANCHOR = function (self,entity)
		--choose whether to work on hood or wheel, do not want to work on hood 2x in a row
		if (entity.AI_TargetType and (entity.AI_TargetType == AIAnchorTable.AIANCHOR_HOOD)) then
			entity.AI_TargetType = AIAnchorTable.AIANCHOR_WHEEL;
		else
			if (random(1,2) == 1) then 
				entity.AI_TargetType = AIAnchorTable.AIANCHOR_HOOD;
			else
				entity.AI_TargetType = AIAnchorTable.AIANCHOR_WHEEL;
			end
		end
		--locate anchor of desired type
		entity.AI_FoundObject = AI.FindObjectOfType(entity.id,10,entity.AI_TargetType);
		
		if (entity.AI_FoundObject) then
			entity:SelectPipe(0,"anchor_animation",entity.AI_FoundObject);
			if (entity.AI_TargetType == AIAnchorTable.AIANCHOR_WHEEL) then
				entity:InsertSubpipe(0,"devalue_anchor");
			end
		else
			self:Idle(entity,sender);
		end	
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

	START_ANIM = function (self, entity, sender)
		entity.cnt.AnimationSystemEnabled = 0;
		entity:StartAnimation(0,self.AnimTable[entity.AI_TargetType][1]);
	end, 
	------------------------------------------------------------------------ 	
	LOOP_ANIM = function (self, entity, sender)
		entity:StartAnimation(0,self.AnimTable[entity.AI_TargetType][2]);
	end,
	------------------------------------------------------------------------
	END_ANIM = function (self, entity, sender)
	--start end animation and if its a wheel devalue current anchor so won't select again
		entity:StartAnimation(0,self.AnimTable[entity.AI_TargetType][3]);
		entity.cnt.AnimationSystemEnabled = 1;
	end,
	------------------------------------------------------------------------ 	
	DECISION_POINT = function( self,entity , sender)
	 	local rnd = random(1,10);	 	
	 	--decide whether or not to get the toolbox
		if ( rnd < 3) then 
			entity.cnt.AnimationSystemEnabled = 1;
			entity:SelectPipe(0,"get_toolbox",entity.AI_FoundObject);
		-- or bored enough to take a break	
		elseif (rnd < 5) then		
			entity.cnt.AnimationSystemEnabled = 1;
			entity:SelectPipe(0,"pause");
			local boredAnchor = AI_BoredManager:FindAnchor(entity,AI_BoredManager.AIBORED_OUTDOOR_GRUNT,20);
			if (boredAnchor) then
				AI.Signal(0,1, boredAnchor.signal,entity.id);
				entity.EventToCall = "OnSpawn";				
			end
		elseif(rnd < 7) then
			entity:MakeRandomConversation();
		-- or choose one of the fix wheel idles	
		elseif ( (rnd > 6) and (entity.AI_TargetType) and (entity.AI_TargetType == AIAnchorTable.AIANCHOR_WHEEL)) then		
			local idx = random(1,3);
			entity:StartAnimation(0,"_fixwheel_idle0"..idx);
			entity:InsertSubpipe(0,"pause");	
		end
	end,
	------------------------------------------------------------------------ 	
	GOT_TOOLS = function( self,entity , sender)
		entity.cnt.AnimationSystemEnabled = 0;
		
		entity:StartAnimation(0,self.AnimTable[AIAnchorTable.AIANCHOR_HOOD][1]);
		entity:SelectPipe(0,"anchor_animation",entity.AI_FoundObject);
		entity:InsertSubpipe(0,"pause");
		
		entity.cnt.AnimationSystemEnabled = 1;
	end, 
	------------------------------------------------------------------------ 			
}

 