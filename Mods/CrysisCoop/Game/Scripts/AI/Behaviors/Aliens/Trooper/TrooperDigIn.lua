--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Threatened behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 7/7/2005     : Created by Mikko Mononen
--
--------------------------------------------------------------------------
AIBehaviour.TrooperDigIn = {
	Name = "TrooperDigIn",
	Base = "TROOPERBASE",
	NOPREVIOUS = 1,
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity)
		entity:CheckReinforcements();
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
		entity:InsertSubpipe(0,"tr_not_so_random_hide_from",data.id);
	end,
	
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		if (fDistance<5) then 
			AI.Signal(0,1,"TO_PREVIOUS",entity.id);
			entity:TriggerEvent(AIEVENT_CLEAR);
		end
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		if (AI.GetGroupCount(entity.id,GROUP_ENABLED,AIOBJECT_PUPPET) > 1) then	
			entity:Readibility("ENEMY_TARGET_LOST_GROUP",1);
		else
			entity:Readibility("ENEMY_TARGET_LOST");
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
		entity:InsertSubpipe(0,"tr_shoot_cover");
	end,

	--------------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
	end,

	--------------------------------------------------
	OnBulletRain = function( self, entity, fDistance )
	end,
	
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
	end,

	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,

	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
	end,

	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,

	---------------------------------------------
	CHECK_FOR_TARGET = function (self, entity, sender)
		if (not AI.Hostile(entity.id,AI.GetAttentionTargetOf(entity.id))) then
			entity:SelectPipe(0,"tr_seek_target");		
		else
			entity:SelectPipe(0,"tr_dig_in_shoot_on_spot");		
		
		end
		AI.Signal(0,1,"TO_ATTACK",entity.id);
	end,

	---------------------------------------------
	CHECK_FOR_SAFETY = function (self, entity, sender)
		AI.Signal(0,1,"TO_ATTACK",entity.id);
	end,

	---------------------------------------------
	TO_PREVIOUS = function(self,entity,sender)
	end
}
