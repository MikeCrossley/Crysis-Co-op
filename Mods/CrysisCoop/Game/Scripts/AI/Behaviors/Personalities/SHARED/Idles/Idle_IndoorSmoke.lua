-- go for a smoke
-- Created 2002-12-10 Amanda
--------------------------
AIBehaviour.Idle_IndoorSmoke = {
	Name = "Idle_IndoorSmoke",
	JOB = 1,
	AnimTable ={
		[AIAnchorTable.AIANCHOR_SMOKE]= {"_smoking_start","_smoking_end1","_smoking_end2","_smoking_idle_loop","_smoking_1","_smoking_2","_smoking_3"},
		},
	TargetType = AIAnchorTable.AIANCHOR_SMOKE,
	--------------------------
	Constructor = function(self,entity)	
		entity.cnt.AnimationSystemEnabled = 1;
		self:FIND_ANCHOR(entity);	
	end,
	OnNoTarget = function(self,entity)	
		--AI.LogEvent("++++++++++++++++++++++++++++ OnNoTarget type");
	end,
	-- make sure doesnt leave job with chair attached and no gun
	------------------------------------------------------------------------ 	
	OnPlayerSeen = function( self, entity, fDistance )
		self:EXIT_POINT(entity);
	end,
	------------------------------------------------------------------------ 	
	OnBulletRain = function( self, entity )
		self:EXIT_POINT(entity);
	end,
	------------------------------------------------------------------------ 	
	OnGroupMemberDied = function( self, entity )
		self:EXIT_POINT(entity);
	end,
	------------------------------------------------------------------------ 	
	OnReceivingDamage = function( self, entity )
		self:EXIT_POINT(entity);
	end,
	------------------------------------------------------------------------ 	
	OnThreateningSoundHeard = function( self, entity )
		self:EXIT_POINT(entity);
	end,	
	------------------------------------------------------------------------ 	
	OnInterestingSoundHeard = function( self, entity )
		self:EXIT_POINT(entity);
	end,
	------------------------------------------------------------------------ 	
	OnGrenadeSeen = function( self, entity )
		self:EXIT_POINT(entity);
	end,
	------------------------------------------------------------------------ 	
	HEADS_UP_GUYS = function( self, entity )
		self:EXIT_POINT(entity);
	end,
	------------------------------------------------------------------------ 	
	INCOMING_FIRE = function( self, entity )
		self:EXIT_POINT(entity);
	end,
	------------------------------------------------------------------------ 	
	IGNORE_ALL_ELSE = function( self, entity )
		self:EXIT_POINT(entity);
	end,
	------------------------------------------------------------------------ 
	EXIT_POINT=  function( self, entity)
		entity.cnt:DrawThirdPersonWeapon(1);
		entity:InsertSubpipe(0,"force_reevaluate");	
	end,
	------------------------------------------------------------------------ 
	HIDE_GUN = function (self,entity)
		entity.cnt:DrawThirdPersonWeapon(0);		
	end,
	------------------------------------------------------------------------ 
	FIND_ANCHOR = function (self,entity)
		--locate anchor of desired type
		local foundObject = AI.FindObjectOfType(entity.id,10,self.TargetType);
 		if (foundObject) then
--			AI.LogEvent("++++++++++++++++++++++++++++ [".. entity:GetName() .."] FIND_ANCHOR FoundObject ["..self.FoundObject .. "]");
			entity:SelectPipe(0,"anchor_animation",foundObject);
		else
			if (entity.Properties.aibehavior_behaviour == self.Name) then
				self:Idle(entity,sender);
			else
				entity:SelectPipe(0,"beat");
			 	AI.Signal(0,1, "BackToJob",entity.id);
			 	entity.EventToCall = "OnSpawn";
			end
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
			entity:SelectPipe(0,MyAnim.Name.."Delay");
		else
			self:FIND_ANCHOR(entity,sender);
		end

	end,	
	------------------------------------------------------------------------ 	

	START_ANIM = function (self, entity, sender)
--	AI.LogEvent("++++++++++++++++++++++++++++ start animation["..self.AnimTable[self.TargetType][1].."]");
		--entity.cnt.AnimationSystemEnabled = 0;
		entity:StartAnimation(0,self.AnimTable[self.TargetType][1]);
	end, 
	
	LOOP_ANIM = function (self, entity, sender)
--	AI.LogEvent("++++++++++++++++++++++++++++ animation loop2 ["..self.AnimTable[self.TargetType][3].."]");
		entity:StartAnimation(0,self.AnimTable[self.TargetType][random(4,6)]);
	end,
		
	------------------------------------------------------------------------
	END_ANIM = function (self, entity, sender)
--	AI.LogEvent("++++++++++++++++++++++++++++ end animation["..self.AnimTable[self.TargetType][4].."]");
	--start end animation and if its a wheel devalue current anchor so won't select again
		entity:StartAnimation(0,self.AnimTable[self.TargetType][random(2,3)]);
		--entity.cnt.AnimationSystemEnabled = 1;
	end,
	---------------------------------------------
	DECISION_POINT = function( self,entity , sender)
	
	 	local rnd = random(1,4);
	 	
	 	--occasionaly run clipboard idle
		if ( rnd == 2) then 
			entity:SelectPipe(0,"beat");
			 AI.Signal(0,1, "BackToJob",entity.id);
			 entity.EventToCall = "OnSpawn";		
		end
	end,	
}

 