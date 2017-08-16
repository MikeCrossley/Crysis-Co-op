--------------------------------------------------
--    Created By: Petar
--   Description: Enemy should not be disturbed by anything while running for reinforcements
--------------------------
--

AIBehaviour.SharedRetreat = {
	Name = "SharedRetreat",
	NOPREVIOUS = 1,
	TotalNumberRetreaters = 0,
	alertness = 2,

	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player
	end,
	---------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
		-- called when the enemy sees a grenade
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
	end,
	---------------------------------------------
	OnDeath = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity, sender)
		-- call the default to do stuff that everyone should do
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
		-- call the default to do stuff that everyone should do
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- called when no hiding place can be found with the specified parameters

		AI.Signal(0,1,"STOP_RETREATING",entity.id);

		self.TotalNumberRetreaters = self.TotalNumberRetreaters-1;
		if (self.TotalNumberRetreaters==0) then 
			AI.Signal(SIGNALFILTER_SUPERGROUP,1,"RETREAT_NOW_PHASE2",entity.id);
		end

	end,	
	--------------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender)
		-- called when the enemy found no formation point
	end,
	---------------------------------------------
	OnReceivingDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy detects bullet trails around him
	end,
	--------------------------------------------------

	--------------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
		-- dont handle this signal
	end,
	--------------------------------------------------
	COVER_RELAX = function (self, entity, sender)
		-- dont handle this signal
	end,
	--------------------------------------------------
	AISF_GoOn = function (self, entity, sender)
		-- dont handle this signal
	end,
	--------------------------------------------------


	--------------------------------------------------
	PROVIDE_COVERING_FIRE = function (self, entity, sender)
		--Hud:AddMessage("Enemy "..entity:GetAIName().." skipped providing covering fire");

	end,

	--------------------------------------------------
	RETREATED_SAFE = function ( self, entity, sender)
		entity:SelectPipe(0,"dumb_shoot");
--		entity:InsertSubpipe(0,"cover_comeout");


		self.TotalNumberRetreaters = self.TotalNumberRetreaters-1;
		if (self.TotalNumberRetreaters==0) then 
			AI.Signal(SIGNALFILTER_SUPERGROUP,1,"RETREAT_NOW_PHASE2",entity.id);
		end
		--Hud:AddMessage("RETREATERS:"..self.TotalNumberRetreaters);
	end,
	--------------------------------------------------
	RETREAT_NOW_PHASE2 = function ( self, entity, sender)
--		entity:SelectPipe(0,"dumb_shoot");
--		entity:InsertSubpipe(0,"cover_comeout");
	end,
	--------------------------------------------------
	REGISTER_AS_RETREATER = function ( self, entity, sender)
		self.TotalNumberRetreaters = self.TotalNumberRetreaters+1;
--		Hud:AddMessage("RETREATERS:"..self.TotalNumberRetreaters);
	end,

	--------------------------------------------------
	RETREATED_SAFE_PHASE2 = function ( self, entity, sender)
		entity:SelectPipe(0,"dumb_shoot");
		entity:InsertSubpipe(0,"cover_comeout");


		self.TotalNumberRetreaters = self.TotalNumberRetreaters-1;
		if (self.TotalNumberRetreaters==0) then 
			AI.Signal(SIGNALFILTER_SUPERGROUP,1,"STOP_RETREATING",entity.id);
		end
		--Hud:AddMessage("RETREATERS:"..self.TotalNumberRetreaters);
	end,

	--------------------------------------------------
	STOP_RETREATING = function ( self, entity, sender)
		entity:TriggerEvent(AIEVENT_CLEAR);
		entity.DODGING_ALREADY = nil;
	end,



	---------------------------------------------
	RETURN_TO_PREVIOUS = function (self, entity, sender)
		entity:SelectPipe(0,"just_shoot");
		AI.Signal(0,1,"OnReload",entity.id);
	end,

	STILL_WAITING = function(self,entity,sender)
		entity:InsertSubpipe(0,"waiting...");
	end,

	EXIT_WAIT_STATE = function(self,entity,sender)
		entity.EventToCall="OnJobContinue";
	end,


	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
		-- dont handle this signal
		entity.RunToTrigger = 1;
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		-- dont handle this signal
	end,


	-- GROUP SIGNALS
	---------------------------------------------	
	KEEP_FORMATION = function (self, entity, sender)
		-- the team leader wants everyone to keep formation
	end,
	---------------------------------------------	
	BREAK_FORMATION = function (self, entity, sender)
		-- the team can split
	end,
	---------------------------------------------	
	SINGLE_GO = function (self, entity, sender)
		-- the team leader has instructed this group member to approach the enemy
	end,
	---------------------------------------------	
	GROUP_COVER = function (self, entity, sender)
		-- the team leader has instructed this group member to cover his friends
	end,
	---------------------------------------------	
	IN_POSITION = function (self, entity, sender)
		-- some member of the group is safely in position
	end,
	---------------------------------------------	
	GROUP_SPLIT = function (self, entity, sender)
		-- team leader instructs group to split
	end,
	---------------------------------------------	
	PHASE_RED_ATTACK = function (self, entity, sender)
		-- team leader instructs red team to attack
	end,
	---------------------------------------------	
	PHASE_BLACK_ATTACK = function (self, entity, sender)
		-- team leader instructs black team to attack
	end,
	---------------------------------------------	
	GROUP_MERGE = function (self, entity, sender)
		-- team leader instructs groups to merge into a team again
	end,
	---------------------------------------------	
	CLOSE_IN_PHASE = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,
	---------------------------------------------	
	ASSAULT_PHASE = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,
	---------------------------------------------	
	GROUP_NEUTRALISED = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,
}