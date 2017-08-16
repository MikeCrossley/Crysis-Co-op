--------------------------------------------------
--   Created By: petar
--   Description: This behaviour will just make whoever dig in behind a medium cover
--------------------------

AIBehaviour.LeanFire = {
	Name = "LeanFire",
	NOPREVIOUS = 1,
	alertness = 2,
	

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
		entity:InsertSubpipe(0,"not_so_random_hide_from",data.id);
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		if (fDistance<5) then 
			AI.Signal(0,1,"TO_PREVIOUS",0);
			entity:TriggerEvent(AIEVENT_CLEAR);
		end
		entity.LeanSuccessfull = 1;
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )

		if (AI.GetGroupCount(entity.id) > 1) then	
			AI.Signal(SIGNALID_READIBILITY, AIREADIBILITY_LOST, "ENEMY_TARGET_LOST_GROUP",entity.id);	
		else
			AI.Signal(SIGNALID_READIBILITY, AIREADIBILITY_LOST, "ENEMY_TARGET_LOST",entity.id);	
		end
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
	end,
	---------------------------------------------
	OnReceivingDamage = function ( self, entity, sender)
		entity:TriggerEvent(AIEVENT_CLEAR);
		--entity:InsertSubpipe(0,"shoot_cover");
	end,

	--------------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
	end,
	--------------------------------------------------
	OnBulletRain = function( self, entity, fDistance )
	end,

	OnReload = function( self, entity )
		entity:TriggerEvent(AIEVENT_CLEAR);
	end,
	

	OnGroupMemberDied = function( self, entity, sender)
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,
	--------------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,
	---------------------------------------------
	KEEP_FORMATION = function (self, entity, sender)
		entity.EventToCall = "KEEP_FORMATION";	
	end,

	---------------------------------------------
	TO_PREVIOUS = function (self, entity, sender)
		entity:TriggerEvent(AIEVENT_CLEAR);
	end,

	---------------------------------------------
	CLEAR_SUCCESS_FLAG = function (self, entity, sender)
		entity.LeanSuccessfull = nil;
	end,
	---------------------------------------------
	CHECK_SUCCESS_FLAG = function (self, entity, sender)
		
		if (entity.LeanSuccessfull==nil) then
			AI.Signal(0,1,"OnReceivingDamage",entity.id);
		end
	end,

	---------------------------------------------
	LEAN_RIGHT_ANIM = function (self, entity, sender)
--		local curr_weap = entity.cnt:GetCurrWeapon();
--		if (curr_weap) then 
--			if (curr_weap.name == "Falcon") then 
--				entity:InsertAnimationPipe("lean_right_s01",3);
--			else
--				entity:InsertAnimationPipe("lean_right_t01",3);
--			end
--		end
	end,

	LEAN_LEFT_ANIM = function (self, entity, sender)
--		local curr_weap = entity.cnt:GetCurrWeapon();
--		if (curr_weap) then 
--			if (curr_weap.name == "Falcon") then 
--				entity:InsertAnimationPipe("lean_left_s01",3);
--			else
--				entity:InsertAnimationPipe("lean_left_t01",3);
--			end
--		end
	end,

}