--------------------------------------------------
--   Created By: petar
--   Description: This behaviour will just make whoever dig in behind a medium cover
--------------------------

AIBehaviour.DigIn = {
	Name = "DigIn",
	NOPREVIOUS = 1,
	alertness = 2,

	Constructor = function (self, entity)
		entity:CheckReinforcements();
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
		entity:InsertSubpipe(0,"not_so_random_hide_from",data.id);
	end,
	
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		self.LOS = 1;
		if (fDistance<5) then 
			AI.Signal(0,1,"TO_PREVIOUS",entity.id);
			entity:TriggerEvent(AIEVENT_CLEAR);
		end
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		self.LOS = nil;
		if (AI.GetGroupCount(entity.id,GROUP_ENABLED,AIOBJECT_PUPPET) > 1) then	
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
	OnDamage = function ( self, entity, sender,data)
		entity:TriggerEvent(AIEVENT_CLEAR);
		entity:InsertSubpipe(0,"shoot_cover");
	end,
	

	--------------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
	end,
	--------------------------------------------------
	OnBulletRain = function( self, entity, fDistance )
	end,
	
	
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
		AI.LogEvent(entity:GetName().." OnPlayerdied in CoverAttack");
		entity:CheckReinforcements();
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
	CHECK_FOR_TARGET = function (self, entity, sender)
	
		entity:SelectPipe(0,"cover_fire");
		entity:InsertSubpipe(0,"do_it_standing");
		AI.Signal(0,1,"TO_ATTACK",entity.id);		
		do return end
		
	
		if (self.LOS==nil or not AI.Hostile(entity.id,AI.GetAttentionTargetOf(entity.id))) then
			entity:SelectPipe(0,"seek_target");		
		else
			entity:SelectPipe(0,"dig_in_shoot_on_spot");		
		
		end
	end,
	---------------------------------------------
	CHECK_FOR_SAFETY = function (self, entity, sender)
		if (self.LOS) then
			AI.Signal(0,1,"TO_ATTACK",entity.id);
		--	entity:TriggerEvent(AIEVENT_CLEAR);
		end
	end,

	TO_PREVIOUS = function(self,entity,sender)
--		AI.Signal(0,1,"OnReload",entity.id);
	end

}