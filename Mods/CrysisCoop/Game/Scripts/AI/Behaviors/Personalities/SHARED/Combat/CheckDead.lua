--------------------------------------------------
--   Created By: Kirill
--   Description: this is used to run to help a mate who called for help
--------------------------

AIBehaviour.CheckDead = {
	Name = "CheckDead",
--	NOPREVIOUS = 1,
	alertness = 1,
	
	Constructor = function (self, entity)
--		entity:MakeAlerted();
--		entity:SelectPipe(0,"cover_beacon_pindown");
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		--entity:InsertSubpipe(0,"check_it_out");
	end,

	---------------------------------------------	
	OnSomebodyDied = function( self, entity, sender)	
	end,

	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
		AI.LogEvent(entity:GetName().." OnPlayerdied in CheckDead");
		entity:CheckReinforcements();
	end,
	
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,
	
	--------------------------------------------------
	OnBodyFallSound = function(self, entity, sender, data)
	end,
	
	--------------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,
	---------------------------------------------
	MOVE_IN_FORMATION = function (self, entity, sender)
	end,

--play some readability anim here		
	---------------------------------------------
	CHECKING_DEAD = function ( self, entity, sender)
		if(entity.AI.killerPos) then
			AI.SetBeaconPosition(entity.id, entity.AI.killerPos);
		end
		if (AI.SmartObjectEvent( "CheckDeadBody", entity.id, entity.AI.deadBodyId ) == 0) then
			entity:Readibility("checking_body",1,1,0.1,0.4);
		end;
--		AI.SetRefPointPosition(entity.id,entity.killer_pos);
--		entity:InsertSubpipe(0,"DropBeaconAt","refpoint");
	end,	
	
	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
--		entity:MakeAlerted();
--		entity:SelectPipe(0,"cv_scramble");
	end,
	
	--------------------------------------------------
	CHECK_DONE = function ( self, entity, sender)
--		entity:Readibility("confirm_dead",1,1,0.1,0.4);

		-- it's sleeping body - go back to idle	
		AI.Signal(SIGNALFILTER_SENDER, 1, "GO_TO_IDLE",entity.id);		
		entity:SelectPipe(0,"stand_only");
		entity:InsertSubpipe(0,"setup_idle");
		entity:InsertSubpipe(0,"clear_all");
	end,	

	--------------------------------------------------
	BE_ALERTED = function ( self, entity, sender)
		entity:Readibility("confirm_dead",1,1,0.1,0.4);
		
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SEEK",entity.id);		
--		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "SEEK_KILLER",entity.id);
		entity:MakeAlerted();
		
	end,	



}
