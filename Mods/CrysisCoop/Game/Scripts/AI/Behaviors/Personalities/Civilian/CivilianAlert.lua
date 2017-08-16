--------------------------------------------------
--   Description: the idle behaviour for a Civilian
-- Created by: Luciano Morpurgo
--------------------------



AIBehaviour.CivilianAlert = {
	Name = "CivilianAlert",
	Base = "CivilianIdle",
	-- TASK = 1, 
	alertness = 1,
	
	Constructor = function(self, entity)
	
	end,	


	---------------------------------------------

	
	OnTargetDead = function( self, entity, sender )
	end,

	
	---------------------------------------------

	OnSeenByEnemy = function( self, entity, sender )
--		entity:Readibility("THEY_SAW_US", 1);
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player	
	end,
	---------------------------------------------
	END_TIMEOUT = function( self, entity, sender )
		-- no one answered, go to hide
		AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_HIDE",entity.id);	
	end,
	---------------------------------------------
	END_HIDE = function( self, entity, sender )
	end,
	
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player

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
		-- called when the enemy hears a scary sound

	end,


	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	--------------------------------------------------

	---------------------------------------------	

	ORDER_ENTER_VEHICLE	= function (self, entity, sender,data)
	end,
	ORDER_EXIT_VEHICLE	= function (self, entity, sender,data)
	end,

	---------------------------------------------	
	ORDER_HOLD = function ( self, entity, sender, data ) 
	end,

	
	--------------------------------------------------------------
	FOLLOW_LEADER = function(self,entity,sender,data)
	end,

}
