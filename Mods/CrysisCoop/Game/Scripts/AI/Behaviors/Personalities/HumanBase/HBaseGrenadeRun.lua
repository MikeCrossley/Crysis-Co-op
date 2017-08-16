--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--   Description: reaction on grenade - ingnore everything and run away
--  
--------------------------------------------------------------------------
--  History:
--  - 23/nov/2005   : Created by Kirill Bulatsev
--	- Mar/2006			: Rewritten by Luciano Morpurgo (smartobject usage)
--------------------------------------------------------------------------



AIBehaviour.HBaseGrenadeRun = {
	Name = "HBaseGrenadeRun",

	Constructor = function(self,entity,data)
		
		--AI.Signal(SIGNALFILTER_LEADER,10,"OnPause",entity.id);
		--AI.Signal(SIGNALFILTER_LEADER,10,"OnUnitBusy",entity.id);
		if(data and data.id) then 
			local exploder = System.GetEntity(data.id);
			if(exploder and exploder.RegisterWithExplosion) then 
				exploder:RegisterWithExplosion(entity);
			end
		end
	end,	
	
	Destructor = function(self,entity)
		AI.Signal(SIGNALFILTER_LEADER,10,"OnUnitResumed",entity.id);
		AI.ModifySmartObjectStates(entity.id,"-AvoidExplosion");
	end,	

	OnSeenByEnemy = function( self, entity, sender )
	end,
	
	OnQueryUseObject = function ( self, entity, sender, extraData )
	end,


	OnPlayerSeen = function( self, entity, fDistance )
	end,
	
	---------------------------------------------
	OnTargetDead = function( self, entity )
	end,
	
	
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	---------------------------------------------
	OnThreateningSeen = function( self, entity )
	end,

	--------------------------------------------------
	OnNoHidingPlace = function( self, entity, sender,data )
		entity:InsertSubpipe(0,"backoff_from_grenade");
	end,	

	---------------------------------------------
	OnBackOffFailed = function(self,entity,sender)
	end,
	---------------------------------------------
	GET_ALERTED = function( self, entity )
	end,
	
	---------------------------------------------
	DRAW_GUN = function( self, entity )
	end,
	
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )

	end,
	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender)
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
	end,
	---------------------------------------------
	OnReload = function( self, entity )
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender,data)

	end,
	--------------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, signalData )
		if ( signalData.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end
	end,
	
	---------------------------------------------
	OnCloseContact = function(self,entity,sender)
--		entity:SelectPipe(0,"backoff_firing");
	end,
	
	
	---------------------------------------------
	OnPathFound = function(self,entity,sender)
--		entity:SelectPipe(0,"backoff_firing");
	end,

	---------------------------------------------
	OnNoTarget = function(self,entity,sender)
--		entity:SelectPipe(0,"backoff_firing");
	end,

	
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)
	end,
	
	
	
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender,data)
	end,
	--------------------------------------------------

	INVESTIGATE_TARGET = function (self, entity, sender)
	end,
	---------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
	end,

	
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,
	---------------------------------------------
	
	OnHideSpotReached = function ( self, entity, sender,data)
	
		entity:InsertSubpipe(0,"do_it_prone");
	
	end,
	

	---------------------------------------------
	GRENADE_RUN_OVER = function(self,entity,sender)
		if(entity.AI.InSquad==1) then 
			AI.Signal(SIGNALFILTER_SENDER,0,"GRENADE_END_REACTION_GROUP",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER,0,"GRENADE_END_REACTION",entity.id);
		end
	end,

	-------------------------------------------------


}
