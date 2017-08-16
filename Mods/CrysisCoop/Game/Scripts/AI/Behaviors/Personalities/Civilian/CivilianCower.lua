--------------------------------------------------
--   Description: the hide behaviour for a Civilian
-- Created by: Luciano Morpurgo
--------------------------



AIBehaviour.CivilianCower = {
	Name = "CivilianCower",
	Base = "CivilianIdle",
	alertness = 1,

	Constructor = function(self, entity,data)
		entity:SelectPipe(0,"do_nothing");
		if(data and IsNotNullVector(data.point)) then 
			AI.SetRefPointPosition(entity.id,data.point);
			AI.SetRefPointDirection(entity.id,data.point2);
			entity:InsertSubpipe(0,"civ_go_to_cower");
		else
--			AI.SetRefPointPosition(entity.id,entity:GetPos());
--			AI.SetRefPointDirection(entity.id,entity:GetDirectionVector(1));
			entity:InsertSubpipe(0,"civ_cower");
		end
		entity:Readibility("cower");
	end,	

	---------------------------------------------
	Destructor = function(self,entity)
	end,
	---------------------------------------------
	END_HIDE = function( self, entity, sender )
	end,
	
	---------------------------------------------

	
	OnTargetDead = function( self, entity, sender )
	end,

	
	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
		
	end,
	
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
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
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the entity is damaged by enemy fire
		-- data.id = shooter id
		-- data.fValue = received damage
		entity:Readibility("GETTING_SHOT_AT",1);
		
--		if(not entity.bIgnoreEnemy) then 
--			entity:SelectPipe(0,"random_reacting_timeout");
--			entity:InsertSubpipe(0,"notify_enemy_seen");
--		end
	end,

	---------------------------------------------
	OnFriendlyDamage = function ( self, entity, sender,data)
--		entity:Readibility("GETTING_SHOT_AT",1);
		-- TO DO
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when detect weapon fire around AI
		--entity:MakeAlerted();
	end,
	--------------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
		-- called when the enemy sees a grenade
		entity:Readibility("GRENADE_SEEN",1);

	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

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
