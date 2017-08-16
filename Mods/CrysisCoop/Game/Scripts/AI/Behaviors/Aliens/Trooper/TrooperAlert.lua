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
AIBehaviour.TrooperAlert = {
	Name = "TrooperAlert",
	Base = "TROOPERBASE",
	alertness = 1,

	---------------------------------------------
	Constructor = function (self, entity)
		entity:MakeAlerted();
		entity:SelectPipe(0,"tr_choose_manner");
	end,

	---------------------------------------------
--	OnEnemyDamage = function ( self, entity, sender,data)
--		AI.LogEvent(entity:GetName().." ONENEMY DAMAGE TrooperAlert");
--		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "INCOMING_FIRE",entity.id);
--		entity:Readibility("GETTING_SHOT_AT",1);
--		--entity:SelectPipe(0,"tr_not_so_random_hide_from",data.id);
--	end,

	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player

		AIBehaviour.TrooperIdle:OnPlayerSeen(entity,fDistance);
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		if(entity:SetRefPointAtDistanceFromTarget(8)) then 
			entity:SelectPipe(0,"tr_approach_target_at_distance");
		end
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
		entity:SelectPipe(0,"tr_look_closer");
		entity:TriggerEvent(AIEVENT_DROPBEACON); 
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		entity:SelectPipe(0,"tr_investigate_threat"); 

		if (fDistance > 20) then 
			entity:InsertSubpipe(AI,"do_it_running");
		else
			entity:InsertSubpipe(0,"do_it_walking");
		end

		entity:InsertSubpipe(0,"tr_threatened"); 
	end,

	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
		--entity:SelectPipe(0,"tr_scramble");
	end,

	---------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender,data)
		-- called when the enemy found no formation point
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
		entity:Readibility("GETTING_SHOT_AT",1);
		entity:SelectPipe(0,"tr_getting_shot_at");
	end,

	---------------------------------------------
	OnHideSpotReached = function( self, entity, sender)
		local targetName = AI.GetAttentionTargetOf(entity.id);
		if(AI.Hostile(entity.id,targetName) and System.GetEntityByName(targetName)) then
			entity:SelectPipe(0,"tr_pindown");
			AI.Signal(SIGNALFILTER_SENDER,0,"TO_ATTACK",entity.id);
		elseif(targetName) then
			entity:SelectPipe(0,"tr_seek_target");
--			entity:InsertSubpipe(0,"do_it_prone");
			entity:InsertSubpipe(0,"tr_random_short_timeout");
		end
	end,
	--------------------------------------------------
	OnNoPathFound = function ( self, entity, sender)
		if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then 
			entity:SelectPipe(0,"tr_just_shoot");
		else
			entity:SelectPipe(0,"do_nothing");
		end
		AI.ModifySmartObjectStates(entity.id,"SearchShootSpots");
	end,
	--------------------------------------------------
	OnEndPathOffset = function ( self, entity, sender)
		if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then 
			entity:SelectPipe(0,"tr_just_shoot");
		else
			entity:SelectPipe(0,"do_nothing");
		end
		AI.ModifySmartObjectStates(entity.id,"SearchShootSpots");
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy detects bullet trails around him
	end,

	---------------------------------------------	
	INVESTIGATE_TARGET = function (self, entity, sender)
		entity:SelectPipe(0,"tr_investigate_threat");		
	end,

--	--------------------------------------------------
--	OnGroupMemberDiedNearest = function ( self, entity, sender)
--		AIBehaviour.TROOPERDEFAULT:OnGroupMemberDiedNearest(entity,sender);
--		entity:SelectPipe(0,"tr_group_member_dies_beacon",sender.id);
--	end,

	---------------------------------------------
	CEASE = function( self, entity, fDistance )
		entity:SelectPipe(0,"tr_cease_approach"); -- in PipeManagerShared.lua			 
	end,

	---------------------------------------------
	TRY_TO_LOCATE_SOURCE = function (self, entity, sender)
		entity:SelectPipe(0,"tr_lookaround_30seconds");
	end,
	
	---------------------------------------------
	DEATH_CONFIRMED = function (self, entity, sender)
		entity:SelectPipe(0,"tr_choose_manner");
	end,
	
	---------------------------------------------
	CHOOSE_MANNER = function (self, entity, sender)
		local XRandom = random(1,3);
		if (XRandom == 1) then
			entity:InsertSubpipe(0,"tr_look_for_threat");			
		elseif (XRandom == 2) then
			entity:InsertSubpipe(0,"tr_random_search");			
		elseif (XRandom == 3) then
			entity:InsertSubpipe(0,"tr_approach_dead_beacon");
		end
	end,

	------------------------------------------------------------------------
	TARGET_LOST_ANIMATION = function (self, entity, sender)
		entity:StartAnimation(0,"enemy_target_lost",0);
	end,

	------------------------------------------------------------------------
	CONFUSED_ANIMATION = function (self, entity, sender)
		entity:StartAnimation(0,"_headscratch1",0);
	end,

	------------------------------------------------------------------------
	GET_ALERTED = function( self, entity )
	end,

}
