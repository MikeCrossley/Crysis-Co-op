--------------------------------------------------
--   Created By: Luciano Morpurgo
--   Description: Hostage moves to a designated position (refpoint)
--------------------------

AIBehaviour.HostageMove = {
	Name = "HostageMove",
	TASK = 1,

	Constructor = function(self,entity)
	end,
	
	Destructor = function(self,entity)
	end,
	
	
	OnTaskSuspend = function ( self, entity, sender)
		if(entity.AI.RefPointMemory ==nil) then
			entity.AI.RefPointMemory = {};
		end
		CopyVector(entity.AI.RefPointMemory,AI.GetRefPointPosition(entity.id));
	end,
	
	OnTaskResume = function ( self, entity, sender)
		AI.SetRefPointPosition(entity.id,entity.AI.RefPointMemory);
	end,
	 

	---------------------------------------------
	OnNoTarget = function( self, entity )
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity, fDistance )
				
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- ignore this
	end,
	---------------------------------------------
	OnReload = function( self, entity )

	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
		
		AIBehaviour.DEFAULT:OnGroupMemberDiedNearest(entity,sender);	
	
		-- PETAR : Cover in attack should not care who died or not. He is too busy 
		-- watching over his own ass :)
	
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- he is not trying to hide in this behaviour
	end,	
	---------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
	end,
	
	
	
	
	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
		entity:SelectPipe(0,"cover_scramble");
		entity:InsertSubpipe(0,"take_cover");
	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
		entity:SelectPipe(0,"cover_pindown");
	end,
	---------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
		-- do nothing on this signal
		entity.RunToTrigger = 1;
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		-- do nothing on this signal
	end,
	---------------------------------------------
	LOOK_FOR_TARGET = function (self, entity, sender)
		-- do nothing on this signal
		entity:SelectPipe(0,"look_around");
	end,	


	---------------------------------------------
}