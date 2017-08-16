--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Threatened behavior for Alien Trooper, enemy position unknown
--  
--------------------------------------------------------------------------
--  History:
--  - 7/7/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperUnderFire = {
	Name = "TrooperUnderFire",
	Base = "TROOPERDEFAULT",
	NOPREVIOUS = 1,
	alertness = 2,

	---------------------------------------------
	Constructor = function(self,entity)
		entity.AI.startTime = _time;
		entity:MakeAlerted();
		entity:Cloak(0);
		local targetType = AI.GetTargetType(entity.id);
		if(targetType==AITARGET_NONE) then 
			entity:SelectPipe(0,"tr_random_hide");
		elseif(targetType==AITARGET_ENEMY) then 
			AI.Signal(SIGNALFILTER_SENDER,0,"ChooseAttack",entity.id);
		else
			entity:SelectPipe(0,"tr_seek_target");
		end
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,

	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,

	---------------------------------------------
	OnGroupMemberDiedNearest= function( self, entity )
		-- called when a member of the group dies
	end,

	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance )
		entity:SelectPipe(0,"tr_pindown");
		entity:InsertSubpipe(0,"DropBeaconTarget");
	end,

	---------------------------------------------		
	OnInterestingSoundHeard = function( self, entity, fDistance )
		entity:TriggerEvent(AIEVENT_CLEAR);
	end,

	---------------------------------------------		
	OnThreateningSoundHeard = function( self, entity, fDistance )
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"tr_not_so_random_hide_from","atttarget");
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged

		if (AI.GetGroupCount(entity.id) > 1) then
			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "HEADS_UP_GUYS",entity.id);
		end

		entity:SelectPipe(0,"tr_search_for_target");
		entity:InsertSubpipe(0,"tr_not_so_random_hide_from",data.id);
		entity:InsertSubpipe(0,"tr_scared_shoot",data.id);
		entity:InsertSubpipe(0,"DropBeaconAt",data.id);
	end,
	
	---------------------------------------------
	OnHideSpotReached = function( self, entity, sender)
	end,

	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
--		entity:SelectPipe(0,"tr_random_hide_wider");
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender, data)
		-- called when the enemy is damaged

		if (AI.GetGroupCount(entity.id) > 1) then
			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "HEADS_UP_GUYS",entity.id);
		end

		entity:SelectPipe(0,"tr_search_for_target");
		entity:InsertSubpipe(0,"tr_not_so_random_hide_from","beacon");
		entity:InsertSubpipe(0,"tr_scared_shoot",data.id);
		entity:InsertSubpipe(0,"DropBeaconAt",data.id);
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy detects bullet trails around him
	end,

	--------------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
		-- called when the enemy sees a grenade
		entity:SelectPipe(0,"tr_grenade_run_away");
	end,

	------------------------------------------------------------------------
	END_HIDE = function(self,entity,sender)
		self:OnHideSpotReached(entity, sender);
	end,

	--------------------------------------------------
	TRY_TO_LOCATE_SOURCE = function (self, entity, sender)
		entity:SelectPipe(0,"tr_lookaround_30seconds");
	end,
}

