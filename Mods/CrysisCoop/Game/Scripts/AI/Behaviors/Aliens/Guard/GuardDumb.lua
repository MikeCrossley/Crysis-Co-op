
AIBehaviour.GuardDumb = {
	Name = "GuardDumb",

 	---------------------------------------------
	Constructor = function(self, entity)
		entity.iCaptureTimer = nil;
	end,
	
 	---------------------------------------------
	Destructor = function( self, entity )	
		if (entity.iCaptureTimer) then
			Log(">>"..entity:GetName().." Destructor, kill timer");
			Script.KillTimer(entity.iCaptureTimer);
			entity.iCaptureTimer = nil;
		end
	end,

 	---------------------------------------------
	OnFlowgraphRelease = function( self, entity )	
		-- HACK! Flowgraph release has to be delayed, otherwise the current action will break too early.
		Log(entity:GetName().." OnFlowgraphRelease");
		if (not entity.iCaptureTimer) then
			entity.iCaptureTimer = Script.SetTimerForFunction(50,"AIBehaviour.GuardDumb.OnTimer",entity);
			Log(" - entity.iTimer!!!");
		end
	end,

	OnTimer = function(entity,timerid)
		if (entity.iCaptureTimer) then
			Log(">>"..entity:GetName().." OnTimer");
--			Script.KillTimer(entity.iCaptureTimer);
			entity.iCaptureTimer = nil;
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_PURSUE",entity.id);
		end
	end,

 	---------------------------------------------
	OnDeath = function( self, entity )	
		if (entity.iCaptureTimer) then
			Log(">>"..entity:GetName().." OnDeath, kill timer");
			Script.KillTimer(entity.iCaptureTimer);
			entity.iCaptureTimer = nil;
		end
	end,

 	---------------------------------------------
 	OnQueryUseObject = function ( self, entity, sender, extraData )
 	end,
	---------------------------------------------
	OnSelected = function( self, entity )	
	end,
	---------------------------------------------
	OnActivate = function( self, entity )
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	end,
	---------------------------------------------
	OnEnemySeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity )
		
	end,
	---------------------------------------------
	OnFriendSeen = function( self, entity )
		-- called when the enemy sees a friendly target
	end,
	---------------------------------------------
	OnDeadBodySeen = function( self, entity )
		-- called when the enemy a dead body
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
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
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,
	---------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- called when no hiding place can be found with the specified parameters
	end,	
	--------------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender)
		-- called when the enemy found no formation point
	end,
	---------------------------------------------
	OnReceivingDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy detects bullet trails around him
	end,
	--------------------------------------------------
	OnDeath = function( self,entity )
	end,
	--------------------------------------------------
	OnDamage = function(self,entity,sender)
	end,
	--------------------------------------------------
	OnCloseContact = 	function(self,entity,sender)
	end,
	--------------------------------------------------
	OnGrenadeSeen = 	function(self,entity,sender)
	end,
	--------------------------------------------------
	OnSomebodyDied = 	function(self,entity,sender)
	end,
	--------------------------------------------------
	RPT_ENEMYSEEN = function (self, entity, sender)
	end,
	--------------------------------------------------
	RPT_INCOMING = function (self, entity, sender)
	end,
	--------------------------------------------------
	RPT_THREATENING = function (self, entity, sender)
	end,
}