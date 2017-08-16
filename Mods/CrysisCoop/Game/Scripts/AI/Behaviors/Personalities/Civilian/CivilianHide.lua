--------------------------------------------------
--   Description: the hide behaviour for a Civilian
-- Created by: Luciano Morpurgo
--------------------------



AIBehaviour.CivilianHide = {
	Name = "CivilianHide",
	Base = "CivilianIdle",
	alertness = 1,
	-- TASK = 1, 

	Constructor = function(self, entity)
		if(not AIBehaviour.CivilianIdle:SearchCower(entity)) then 
			entity:SelectPipe(0,"civ_hide","beacon");
		end
	end,	

	---------------------------------------------
	Destructor = function(self,entity)
		if(entity.iLookTimer) then 
			Script.KillTimer(entity.iLookTimer);
			entity.iLookTimer = nil;
		end
	end,
	---------------------------------------------
	END_HIDE = function( self, entity, sender )
		entity:SelectPipe(0,"do_nothing");
	end,
	
	--------------------------------------------------
	OnGroupMemberDied = function( self, entity, sender)
		AI.Signal(SIGNALFILTER_NEARESTINCOMM_SPECIES,1,"OnGroupMemberDied",entity.id);
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
		-- call the default to do stuff that everyone should do
		AI.Signal(SIGNALFILTER_NEARESTINCOMM_SPECIES,1,"OnGroupMemberDiedNearest",entity.id);
	end,
	---------------------------------------------
	OnTargetDead = function( self, entity, sender )
	end,

	
	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
--		System.Log("SEEN BY "..sender:GetName());
		
			self:Constructor(entity);
--		elseif(AI.GetTargetType(entity.id)) then 
--			entity:SelectPipe(0,"do_nothing");
--			entity:InsertSubpipe(0,"civ_surrender");
--		end
	end,
	
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		self:Constructor(entity);
	end,
	
	---------------------------------------------
	END_TIMEOUT = function( self, entity, sender )
	
	end,
	
	---------------------------------------------
	COME_HERE = function( self, entity, sender )
		
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

	end,
	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------


	--------------------------------------------------
	-- CUSTOM SIGNALS
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
