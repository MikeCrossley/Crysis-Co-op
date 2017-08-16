--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Alien Trooper goes to formation before starting attack
--  
--------------------------------------------------------------------------
--  History:
--  - Aug 2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperForm = {
	Name = "TrooperForm",
	Base = "TROOPERDEFAULT",
	alertness = 2,
	---------------------------------------------
	Constructor = function (self, entity)
		entity:MakeAlerted();
		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(0,"tr_squad_form");
		entity:InsertSubpipe(0,"do_it_running");
--		entity:InsertSubpipe(0,"do_it_prone");
		entity:InsertSubpipe(0,"stop_fire");
		entity:Cloak(0);
	end,
	
	---------------------------------------------
	Destructor = function (self, entity)
		entity:SelectPipe(0,"clear_goalpipes");
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- data.id: the shooter
		entity:Readibility("GETTING_SHOT_AT",1);
		entity:SelectPipe(0,"tr_short_cover_fire",data.id);
	end,

	---------------------------------------------
	OnLowHideSpot = function( self, entity, sender)
	end,

	---------------------------------------------
	OnHideSpotReached = function( self, entity, sender)
	end,

	---------------------------------------------
	OnNoTarget = function( self, entity )
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

--		local rnd=random(1,10);
--		if (rnd < 5) then 
--			entity:Readibility("THREATEN",1);			
--		end
--		local targetEntity = AI.GetAttentionTargetEntity(entity.id);
--		if(targetEntity) then 
--			entity:SelectPipe(0,"tr_short_cover_fire",targetEntity.id);
--		end
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )

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


	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )

	end,	

	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
	end,

	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender)
--		-- called when the enemy is damaged
--		entity:SelectPipe(0,"tr_scramble");
	end,

	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)
	end,
	
	--------------------------------------------------
	TR_NORMALATTACK = function (self, entity, sender)
	end,
	
	--------------------------------------------------
	FORMATION_REACHED = function(self,entity,sender)
		--AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
		entity:SelectPipe(0,"tr_stay_in_formation");
	end,

--	--------------------------------------------------
--	OnLeaderDied = function(self,entity,sender)
--		entity:SelectPipe(0,"tr_confused");
--		entity.AI.InSquad = 0;
--	end,
	OnNoPathFound = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,
}
