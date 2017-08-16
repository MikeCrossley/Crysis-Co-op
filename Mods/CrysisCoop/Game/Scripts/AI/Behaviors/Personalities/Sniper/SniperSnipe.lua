----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2001-2004.
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: the main combat behaviour for the Sniper - sitting quaetly waiting for target
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 30:nov:2005   : Created by Kirill Bulatsev
--
----------------------------------------------------------------------------------------------------´

AIBehaviour.SniperSnipe = {
	Name = "SniperSnipe",
	alertness = 2,	

	Constructor = function (self, entity)
		entity:MakeAlerted();
		entity:SelectPipe(0,"sniper_snipe");
--		self:FindSnipeSpot(entity);
--		entity:SelectPipe(0,"sniper_move");

		-- this needed to make sure to switch to shoot on PlayerSeen
--		entity:InsertSubpipe(0,"devalue_target");
		
		
	end,

	OnBackOffFailed = function (self, entity)

	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	
		--local targetDist = AI.GetAttentionTargetDistance(entity.id)	
		--local target = AI.GetAttentionTargetEntity( entity.id );
		--if ( target  ) then
		--System.Log(">>>> >>>> shiper sniping target "..target:GetName().." dst ->> "..fDistance );
		--System.Log(">>>>--- measured dist  "..targetDist);
		--else
		--System.Log(">>>> >>>> shiper sniping VOID");
		--end
		--fDistance = targetDist;
	
		if(AIBehaviour.SniperIdle:ChecktargetProximity(entity, fDistance)==nil)  then
			entity:SelectPipe(0,"sniper_shoot");
		end	
	end,
	
	------------------------------------------------------------------------------------------
	OnSomethingSeen = function( self, entity, fDistance )
	end,

	on_spot	= function (self, entity)
	end,

	relocate = function (self, entity)
	end,

	------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------	
	
	
	
	
	


 	OnQueryUseObject = function ( self, entity, sender, extraData )
 	end,
 	---------------------------------------------
 	
	---------------------------------------------
	OnNoTarget = function( self, entity )
	
		--AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GunnerLostTarget",entity.id);
		
		--AI.LogEvent("\001 gunner in vehicle lost target ");
		-- caLled when the enemy stops having an attention target
	end,
	---------------------------------------------
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
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,
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
	------------------------------------------------------------------------------------------
}
