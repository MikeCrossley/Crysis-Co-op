--------------------------------------------------
-- Cover2Seek
--------------------------
--   created: Mikko Mononen 21-6-2006


AIBehaviour.Cover2Seek = {
	Name = "Cover2Seek",
	Base = "Cover2Attack",
	alertness = 1,

	---------------------------------------------
	Constructor = function (self, entity)

		entity:GettingAlerted();

		if(not entity.AI.target) then
			entity.AI.target = {x=0, y=0, z=0};
		else
			ZeroVector(entity.AI.target);
		end
		
		entity.AI.lastBulletReactionTime = _time - 10;
		entity.AI.lastLookatTime = _time - 10;
		
		local range = entity.Properties.preferredCombatDistance;
		local radius = 4.0;
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			range = range / 2;
			radius = 2.5;
		end
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, -radius);
--  	AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, range/2);
--  	AI.SetPFBlockerRadius(entity.id, PFB_BEACON, range/2);
  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, radius);
  	AI.SetPFBlockerRadius(entity.id, PFB_REF_POINT, 0);
  	
		entity.AI.seekCount = 0;

		-- If using secondary weapon or running low on ammo, reload.
		-- If the target is not visible, this will also switch back
		-- to the primary weapon an reload it.
--		if(entity:CheckCurWeapon() == 1 or entity:GetAmmoLeftPercent() < 0.25) then
--			entity.AI.reloadReturnToSeek = true;
--			AI.Signal(SIGNALFILTER_SENDER,1,"TO_RELOAD",entity.id);
--		end

		if(entity:CheckCurWeapon() == 1) then
			AI.LogEvent(">> PRIMARY weapon"..entity:GetName());
			entity:SelectPrimaryWeapon();
		end

		--self:COVER_NORMALATTACK(entity);
		-- Call the derived behavior attack logic
		AI.Signal(SIGNALFILTER_SENDER,1,"COVER_NORMALATTACK",entity.id);

		if (AI_Utils:CanThrowGrenade(entity) == 1) then
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"sn_throw_grenade");
		end
	end,

	---------------------------------------------
	Destructor = function (self, entity)
		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
	end,

	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity)

		local state = GS_SEEK; 
		if (entity.AI.seekCount ~= 0) then
			state = AI.GetGroupTacticState(entity.id, 0, GE_GROUP_STATE);
		end

		if (entity.AI.seekCount > 1) then
			local target = AI.GetTargetType(entity.id);
			if (target == AITARGET_NONE) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
				return;
			elseif (AI.GetAttentionTargetDistance(entity.id) < 4.0) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
				return;
			end
		end
		
		entity.AI.seekCount = entity.AI.seekCount + 1;

		if (state == GS_ADVANCE) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
		elseif (state == GS_SEARCH or state == GS_ALERTED or state == GS_IDLE) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
		else
		
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_SEEKING);

			if (AI.GetGroupTacticState(entity.id, 0, GE_DEFEND_POS) == 1) then
				-- The group is set to defend, move towards the defend pos.
				local	distToDefendPos = DistanceVectors(entity:GetPos(), AI.GetGroupTacticPoint(entity.id, 0, GE_DEFEND_POS));
				if (distToDefendPos > 15.0) then
	--				entity:SelectPipe(0,"cv_seek_defend");
					entity:SelectPipe(0,"cm_seek_retreat");
				else
					entity:SelectPipe(0,"cv_seek_defend");
				end
			else
				-- Free attack, move towards the enemy.
				if (AI.GetGroupTacticState(entity.id, 0, GE_MOST_LOST_UNIT) == 1) then
					entity:Readibility("cover_me",1,2,0.1,0.4);
					entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cv_cohesion");
				elseif(AI_Utils:IsTargetOutsideTerritory(entity) == 0 and AI.GetGroupTacticState(entity.id, 0, GE_NEAREST_SEEK) == 1) then
					entity:Readibility("taunt",1,2,0.1,0.4);
					entity:SelectPipe(0,"cv_seek_direct");
				else
					local signal = AI.GetGroupTacticState(entity.id, 0, GE_MOVEMENT_SIGNAL);
					if (signal ~= 0) then
						if (signal == -1) then
							entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cv_signal_advance_left");
						else
							entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cv_signal_advance_right");
						end
					else
						entity:Readibility("combat_seek",1,3,0.1,0.4);
--						if (entity.AI.seekCount > 3) then
--							entity:SelectPipe(0,"cv_seek_direct");
--						else
							entity:SelectPipe(0,"cv_seek");
--						end
					end
				end
			end
		end
	end,

	---------------------------------------------
	SEEK_DIRECT_DONE = function (self, entity)
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
	end,

	---------------------------------------------
	OnNoTargetAwareness = function (self, entity)
--		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
	end,

	---------------------------------------------
	OnNoTargetVisible = function (self, entity)
		-- empty
		if(AI_Utils:IsTargetOutsideStandbyRange(entity) == 1) then
			entity.AI.hurryInStandby = 0;
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED_STANDBY",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
		end
	end,

	---------------------------------------------
	ADVANCE_NOPATH = function (self, entity, sender)
		-- no path could be found to the advance target, do something meaningful.
--		entity:SelectPipe(0,"sn_use_cover_safe");
		-- Do not try to advance here again.
--		AI.SetCurrentHideObjectUnreachable(entity.id);
	end,

	--------------------------------------------------
	OnCoverCompromised = function(self, entity, sender, data)
--		local target = AI.GetTargetType(entity.id);
--		if(target == AITARGET_NONE) then
--			-- Advance towards the enemy
--			local	beaconPos = g_Vectors.temp_v1;
--			AI.GetBeaconPosition(entity.id, beaconPos);
--			AI.SetRefPointPosition(entity.id,beaconPos);
--			
----			if(AI_Utils:IsTargetOutsideTerritory(entity) == 0) then
----				entity:Readibility("taunt",1,2,0.1,0.4);
----				entity:SelectPipe(0,"sn_fast_advance_to_target");
----			else
--				entity:Readibility("taunt",1,2,0.1,0.4);
--				entity:SelectPipe(0,"cv_investigate_probable_target"); 
----			end
--		
----			entity:SelectPipe(0,"cv_refpoint_investigate"); 
--			
--		elseif(target == AITARGET_ENEMY or target == AITARGET_MEMORY) then
--			entity:Readibility("taunt",1,3,0.1,0.4);
--			if(AI.GetGroupTacticState(entity.id, 0, GE_LEADER_COUNT) > 0) then
--				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK_GROUP",entity.id);
--			else
--				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
--			end
--		else
--			entity.AI.seekCount = 0;
--			entity:SelectPipe(0,"do_nothing");
--			entity:SelectPipe(0,"sn_use_cover_safe");			
--		end
	end,

	---------------------------------------------
--	OnEnemyDamage = function ( self, entity, sender,data)
--		-- data.id: the shooter
--		entity:Readibility("taking_fire",1,2,0.1,0.4);
--		
--		-- set the beacon to the enemy pos
--		local shooter = System.GetEntity(data.id);
--		if(shooter) then
--			AI.SetBeaconPosition(entity.id, shooter:GetPos());
--			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);
--		end
--
--		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HIDE",entity.id);
--	
--	end,

	---------------------------------------------
	OnNoTarget = function( self, entity )
--		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance, data )
		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);

		AI_Utils:CommonEnemySeen(entity, data);
	end,

	---------------------------------------------
	OnReload = function( self, entity )
--		entity:Readibility("reloading",1);
	end,
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		--AI.LogEvent(">>SEEK "..entity:GetName().." OnInterestingSoundHeard");
--		entity:Readibility("alert_interest_hear",1,1,0.3,0.6);
--		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_look_at_target");
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		--AI.LogEvent(">>SEEK "..entity:GetName().." OnThreateningSoundHeard");

		local dt = entity.AI.lastLookatTime - _time;
		if(dt > 6.0) then
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_look_at_lastop", "probabletarget");
			entity.AI.lastLookatTime = _time;
		end

--		entity:Readibility("alert_interest_hear",1,1,0.3,0.6);
--		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_look_at_target_threat");
	end,

	---------------------------------------------
	OnThreateningSeen = function( self, entity )
		local dt = entity.AI.lastLookatTime - _time;
		if(dt > 6.0) then
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_look_at_lastop", "probabletarget");
			entity.AI.lastLookatTime = _time;
		end
	end,

	---------------------------------------------	
	OnSomethingSeen	= function( self, entity )
		--AI.LogEvent(">>SEEK "..entity:GetName().." OnSomethingSeen");
		-- called when the enemy hears a scary sound
--		entity:Readibility("alert_interest_see",1,1,0.3,0.6);
--		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_look_at_target_threat");
	end,

	---------------------------------------------
	OnBadHideSpot = function ( self, entity, sender,data)
--		entity:SelectPipe(0,"sn_wait_and_shoot");
	end,
	--------------------------------------------------
	OnNoHidingPlace = function( self, entity, sender,data )
--		entity:SelectPipe(0,"sn_wait_and_shoot");
	end,	
	--------------------------------------------------
	OnNoPathFound = function( self, entity, sender,data )
--		entity:SelectPipe(0,"sn_wait_and_shoot");
	end,	

	--------------------------------------------------
	TARGET_DISTANCE_REACHED = function ( self, entity, sender,data)
		self:LOOK_FOR_TARGET(entity, sender,data);
	end,

	--------------------------------------------------
	LOOK_FOR_TARGET	= function ( self, entity, sender,data)

--		if (AI.GetGroupTacticState(entity.id, 0, GE_LEADER_COUNT) < 2) then
--			local	beaconPos = g_Vectors.temp_v1;
--			AI.GetBeaconPosition(entity.id, beaconPos);
--			local dist = DistanceVectors(beaconPos, entity:GetPos());
--	
--			-- Check if someone is already close to beacon.
--			local state = AI.GetGroupTacticState(entity.id, 0, GE_GROUP_STATE);
--			if(state == GS_SEARCH or state == GS_IDLE) then
--				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
--			else
--	--			local	beaconPos = g_Vectors.temp_v1;
--	--			AI.GetBeaconPosition(entity.id, beaconPos);
--	
--				local probTargetPos = AI.GetProbableTargetPosition(entity.id);
--				local distToTerrEdge = 100000.0;
--	
--				if(entity.AI.TerritoryShape) then
--					probTargetPos = AI.ConstrainPointInsideGenericShape(probTargetPos, entity.AI.TerritoryShape, 1);
--					distToTerrEdge = AI.DistanceToGenericShape(entity:GetPos(), entity.AI.TerritoryShape, 1);
--				end
--	
--				local probTargetDist = DistanceVectors(entity:GetPos(), probTargetPos);
--	
--				-- check if the AI is at the edge of the territory and cannot move.
--				if(distToTerrEdge < 3.0 and probTargetDist < 7.0) then
--					-- at the edge, wait, aim and shoot.
--					entity:Readibility("taunt",1,2,0.1,0.4);
--					entity:SelectPipe(0,"sn_wait_and_shoot"); 
--				else
--					-- there is still some room for moving.
--					entity:Readibility("taunt",1,2,0.1,0.4);
--					entity:SelectPipe(0,"cv_investigate_probable_target"); 
--				end
--			end
--		else
--			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
--		end
	end,

	--------------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function (self, entity, sender)
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
--		local target = AI.GetTargetType(entity.id);
--		if (target == AITARGET_ENEMY) then
--			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
--		else
--			local unitState = AI.GetGroupTacticState(entity.id, 0, GE_UNIT_STATE);
--			if (unitState == GN_NOTIFY_SEEKING) then
--				-- there is still some room for moving.
--				entity:Readibility("taunt",1,2,0.1,0.4);
--				entity:SelectPipe(0,"cv_investigate_probable_target"); 
--			end
--		end
	end,

	--------------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function (self, entity, sender)
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
		entity:Readibility("taunt",1,2, 0.1,0.4);
--		local target = AI.GetTargetType(entity.id);
--		if (target == AITARGET_ENEMY) then
--			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
--		else
--			local unitState = AI.GetGroupTacticState(entity.id, 0, GE_UNIT_STATE);
--			if (unitState == GN_NOTIFY_SEEKING) then
--				-- there is still some room for moving.
--				entity:Readibility("taunt",1,2,0.1,0.4);
--				entity:SelectPipe(0,"cv_investigate_probable_target"); 
--			end
--		end
	end,

	---------------------------------------------
	SEEK_KILLER = function(self, entity)
	end,
	--------------------------------------------------
	OnGroupChanged = function (self, entity)
	end,
}
