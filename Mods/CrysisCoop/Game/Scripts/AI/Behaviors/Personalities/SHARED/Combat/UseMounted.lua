--------------------------------------------------
-- Created By:	Dejan
-- Description: This behavior is used to make
--							agents approach particular mounted
--							weapon and use it
-- Modified by Luciano Morpurgo (smart object usage)
--------------------------------------------------

AIBehaviour.UseMounted = {
	Name = "UseMounted",
--	TASK = 1,
	alertness = 2,
	exclusive = 1,
	
	Constructor = function( self, entity )
		--AI.Signal(SIGNALFILTER_LEADER, 10, "OnUnitBusy", entity.id);
		local weapon = entity.AI.current_mounted_weapon;
		if( weapon and (not weapon.item:IsUsed())) then -- or weapon.item:GetOwnerId()==entity.id and not entity:IsUsingPipe("near_mounted_weapon"))) then 
				-- sorry....
			AIBehaviour.UseMounted:StartUsingMountedWeapon(entity);
		else
			entity:SelectPipe(0,"fire_mounted_weapon");
		end
		
		entity.AI.oldAimTurnSpeed = AI.GetAIParameter(entity.id, AIPARAM_AIM_TURNSPEED);
		entity.AI.oldFireTurnSpeed = AI.GetAIParameter(entity.id, AIPARAM_FIRE_TURNSPEED);
		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, 25);
		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, 15);
		entity.AI.SkipTargetCheck = false;
--		-- prevent shooting a short burst when he see the player sneaking behind him
--		AIBehaviour.UseMounted:CheckTargetInRange( entity );
		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
	end,
	
	Destructor = function( self, entity )
	
		AIBehaviour.UseMountedIdle:LeaveMG(entity);	
 		
		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, entity.AI.oldAimTurnSpeed);
		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, entity.AI.oldFireTurnSpeed);
 		
	end,
	
	
	CheckTargetInRange = function ( self, entity )
--		if ( entity.AI.current_mounted_weapon ) then
--			if ( entity.AI.current_mounted_weapon.item:GetOwnerId() == entity.id ) then
----			if ( entity.AI.current_mounted_weapon:GetUser() == entity ) then
--				if ( not entity:IsTargetAimable( entity.AI.current_mounted_weapon ) ) then
--				end
--			else
--				if ( entity.AI.current_mounted_weapon.item:GetOwnerId() == nil and entity:IsTargetAimable( entity.AI.current_mounted_weapon ) ) then
----				if ( entity.AI.current_mounted_weapon:GetUser() == nil and entity:IsTargetAimable( entity.AI.current_mounted_weapon ) ) then				
--					continuing = true;
--			   	entity:InsertSubpipe(0, "use_this_mounted_weapon", entity.AI.current_mounted_weapon:GetName());
--				end
--			end
--		end

		-- if no "real" target - no check
		if(	AI.GetTargetType(entity.id) ~= AITARGET_ENEMY and
				AI.GetTargetType(entity.id) ~= AITARGET_MEMORY and
				AI.GetTargetType(entity.id) ~= AITARGET_SOUND
			) then	return end

		if(not entity.AI.SkipTargetCheck) then 
			local weapon = entity.AI.current_mounted_weapon;
			--if(not (weapon and entity:IsTargetAimable( weapon )) ) then
			if(not (weapon and AI.IsMountedWeaponUsableWithTarget(entity.id,weapon.id,7) )) then
				--weapon.listPotentialUsers = 1; -- put any value to prevent someone else to use it
				AI.Signal(SIGNALFILTER_SENDER,0,"LeaveMG",entity.id);
			end
		end
	end,
	
	OnSomethingSeen = function ( self, entity, sender )
		entity:Readibility("idle_interest_see",1,1,0.6,1);
		-- assume see enemy
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_DURING_COMBAT",entity.id);
		
	end,
	
	---------------------------------------------
	OnThreateningSeen = function( self, entity )
		entity:Readibility("idle_interest_see",1,1,0.6,1);
		-- assume see enemy
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_DURING_COMBAT",entity.id);
	end,
	
	---------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function( self, entity )
	end,

	---------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function( self, entity )
	end,
	
	---------------------------------------------
	INVESTIGATE_TARGET  = function( self, entity )
	end,

	---------------------------------------------
	OnQueryUseObject = function ( self, entity, sender, extraData )
		-- ignore this signal, execute DEFAULT
	--	System.Log("Signal OnQueryUseObject ignored in UseMounted for "..entity:GetName());
--		AI.Signal(SIGNALFILTER_SENDER,0,"LeaveMG",entity.id);
	end,
--	--------------------------------------------------
--	OnObjectSeen = function( self, entity, fDistance, signalData )
--		-- called when the enemy sees an object
--		if (signalData.iValue == 150) then
--			if (fDistance <= 40) then
--				-- stop using mounted weapon
--				if (entity.AI.current_mounted_weapon and entity.AI.current_mounted_weapon:GetUser() == entity) then
--					entity.AI.current_mounted_weapon:OnStopUsing( entity );
--			   	entity:InsertSubpipe(0, "use_this_mounted_weapon", entity.AI.current_mounted_weapon:GetName());
--				end
--				entity:InsertSubpipe(0, "grenade_seen");
--			end
--		end
--	end,
	--------------------------------------------------
--	PLAYER_CLOSE = function( self, entity, sender)
--		-- sent by smart object rule
--		AI.Signal(SIGNALFILTER_SENDER,0,"LeaveMG",entity.id);
--	end,
	--------------------------------------------------
	OnCloseContact = function( self, entity, sender)
		-- this signal should be ignored here
		AI.Signal(SIGNALFILTER_SENDER,0,"LeaveMG",entity.id);
	end,

	--------------------------------------------------
	OnNearMiss = function(self, entity, sender)
	end,
	--------------------------------------------------
	
	ORDER_HIDE = function( self, entity, sender )
		-- just ignore this leader order
	--	AI.Signal(SIGNALFILTER_LEADER, 10, "ORD_DONE", entity.id);
	end,
	--------------------------------------------------

	ORDER_FIRE = function( self, entity, sender )
		-- just ignore this leader order
	--	AI.Signal(SIGNALFILTER_LEADER, 10, "ORD_DONE", entity.id);
	end,

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	GET_ALERTED = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,
	---------------------------------------------
	OnEnemyDamage = function( self, entity,sender,data )
	
		entity:GettingAlerted();
		-- set the beacon to the enemy pos
		local shooter = System.GetEntity(data.id);
		if(shooter) then
			AI.SetBeaconPosition(entity.id, shooter:GetPos());
		else
			entity:TriggerEvent(AIEVENT_DROPBEACON);
		end
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);
		-- dummy call to this one, just to make sure that the initial position is checked correctly.
		AI_Utils:IsTargetOutsideStandbyRange(entity);
	
		-- leave the MG if shooter is out of range
		if(shooter) then 
			local weapon = entity.AI.current_mounted_weapon;
			if(not(weapon and AI.IsMountedWeaponUsableWithTarget(entity.id,weapon.id,7,shooter:GetPos()) )) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "LEAVE_MOUNTED_WEAPON",entity.id);
				-- prevent the guy to use MG again immediately after
				AI.ModifySmartObjectStates(entity.id,"DontUseMountedMG");
				return;
			end
		end

		-- leave the MG if there's no target
		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then
			--AI.Signal(SIGNALFILTER_SENDER,0,"MOUNTED_WEAPON_DAMAGE_ALERT",entity.id,data);
			AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, 0 );
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"GET_ALERTED",entity.id);
			AI.Signal(SIGNALFILTER_NEARESTINCOMM,1,"GET_ALERTED_RESPONSE",entity.id); -- for dialog
			AI.SetRefPointPosition(entity.id,data.point);
			entity:SelectPipe(0,"mounted_weapon_blind_fire");
			entity:InsertSubpipe(0,"random_reacting_timeout");
			entity:InsertSubpipe(0,"acquire_target","refpoint");
			entity:InsertSubpipe(0,"short_timeout");
		else
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"GET_ALERTED",entity.id);
			AI.Signal(SIGNALFILTER_NEARESTINCOMM,1,"GET_ALERTED_RESPONSE",entity.id); -- for dialog
		end
		-- prevent to go back to MG if he hasn't got a target
--		entity.AI.SkipTargetCheck = false;

	end,

	--------------------------------------------
	TOO_FAR_FROM_WEAPON = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_SENDER,0,"LeaveMG",entity.id);
	end,
	
	--------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player
--		entity.AI.SkipTargetCheck = false;
-- Luciano - this should work but it doesnt		if ( entity.AI.current_mounted_weapon.item:GetOwnerId() == entity.id ) then
--		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"GET_ALERTED",entity.id);
--		AI.Signal(SIGNALFILTER_NEARESTINCOMM,1,"GET_ALERTED_RESPONSE",entity.id); -- for dialog

		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_DURING_COMBAT",entity.id);

		AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, 1 );
		if(not entity.AI.approachingMountedWeapon) then
			entity:SelectPipe(0,"fire_mounted_weapon");
			AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, 1 );
		end
	end,

	---------------------------------------------
	OnSeenByEnemy = function( self, entity )
	end,
	---------------------------------------------
	OnThreateningSoundHeardByEnemy = function( self, entity, sender )
	end,

	---------------------------------------------
	OnPlayerSeenByEnemy = function( self, entity, sender )
	end,
	
	---------------------------------------------
	NotifyPlayerSeen = function( self, entity, sender )
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
--		-- called when the enemy can no longer see its foe, but remembers where it saw it last
---- Luciano - this should work but it doesnt		if ( entity.AI.current_mounted_weapon.item:GetOwnerId() == entity.id ) then
--		if(not entity.AI.approachingMountedWeapon) then
--
--			entity:SelectPipe(0,"mounted_weapon_blind_fire");
--			local dist = AI.GetAttentionTargetDistance(entity.id);
--			-- set spread fire via accuracy, depending on target distance
--			if (dist>20) then 
--				dist = 20; 
--			end
--			local accuracy = dist/20*0.5+0.3;
--			AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, accuracy );
--		
--		end
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
		entity:Readibility("idle_alert_threat_hear",1,1,0.6,1);
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"GET_ALERTED",entity.id);
		AI.Signal(SIGNALFILTER_NEARESTINCOMM,1,"GET_ALERTED_RESPONSE",entity.id); -- for dialog
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
	OnGroupMemberDiedNearest = function( self, entity )
		-- called when a member of the group dies
	end,
	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)
		-- empty
	end,

	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- called when no hiding place can be found with the specified parameters
	end,	
	--------------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender)
		-- called when the enemy found no formation point
	end,
	
	--------------------------------------------------
	OnDamage = function ( self, entity, sender)

	end,
	--------------------------------------------------
	OnFriendlyDamage = function ( self, entity, sender)

	end,
	
	---------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	
	--------------------------------------------------
	FLASHBANG_GONE = function (self, entity)
		entity:GettingAlerted();
		entity:SelectPipe(0,"fire_mounted_weapon");
	end,
	
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender,data)
		-- called when the enemy detects bullet trails around him
--		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then
--			--AI.Signal(SIGNALFILTER_SENDER,0,"MOUNTED_WEAPON_DAMAGE_ALERT",entity.id,data);
--			AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, 0 );
--			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"GET_ALERTED",entity.id);
--			AI.Signal(SIGNALFILTER_NEARESTINCOMM,1,"GET_ALERTED_RESPONSE",entity.id); -- for dialog
--			if(data.id and data.id ~=NULL_ENTITY) then 
--				local shooter  = System.GetEntity(data.id);
--				if(shooter) then
--					AI.SetRefPointPosition(entity.id,shooter:GetPos());
--				end
--			end
--			if(not entity:IsUsingPipe("mounted_weapon_carpet_fire")) then 
--				entity:SelectPipe(0,"mounted_weapon_carpet_fire");
--				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"random_reacting_timeout");
--				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"acquire_target","refpoint");
--				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"short_timeout");
--			end
--		end

	end,
	--------------------------------------------------
	HEADS_UP_GUYS = function ( self, entity, sender)
	end,
	
	---------------------------------------------
	ACT_GOTO = function(self,entity,sender,data)
		entity:SelectPipe(0,"do_nothing");
		AIBehaviour.UseMountedIdle:LeaveMG(entity,sender);
		AIBehaviour.DEFAULT:ACT_GOTO(entity,sender,data);
	end,

	---------------------------------------------
	ACT_FOLLOWPATH = function(self,entity,sender,data)
		entity:SelectPipe(0,"do_nothing");
		AIBehaviour.UseMountedIdle:LeaveMG(entity,sender);
		AIBehaviour.DEFAULT:ACT_FOLLOWPATH(entity,sender,data);
	end,
	
	---------------------------------------------
	OnFallAndPlay	= function( self, entity, data )
		AI.SetRefPointPosition(entity.id, data.point);	
		AIBehaviour.UseMountedIdle:LeaveMG(entity,sender);
	end,

	StartUsingMountedWeapon = function(self,entity)
		local weapon = entity.AI.current_mounted_weapon;
		entity:SelectPipe(0, "do_nothing");
		local weaponPos = g_Vectors.temp;
		local weaponDir = g_Vectors.temp_v1;
		CopyVector(weaponDir,weapon.item:GetMountedDir());
		ScaleVectorInPlace(weaponDir,0.75);
		FastDifferenceVectors(weaponPos,weapon:GetPos(),weaponDir);-- weapon.item:GetMountedDir());
		local dir = g_Vectors.temp_v2;
		dir.x=0;
		dir.y=0;
		dir.z=-2;
		local	hits = Physics.RayWorldIntersection(weaponPos,dir,2,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,entity.id,nil,g_HitTable);
		if(hits>0) then	
			local firstHit = g_HitTable[1];		
			weaponPos.z = firstHit.pos.z;
		end

		
		AI.SetRefPointPosition(entity.id,weaponPos);
		AI.SetRefPointDirection(entity.id,weaponDir);

   	-----------------
   	-- going to a MG fast is more prioritary than avoiding dead bodies
		local radius = 4.0;
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			radius = 2.5;
		end
   	-- set AVOID Dead bodies, rather than BLOCKED (positive radius)
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, radius);
		-----------------
			   	
   	entity:SelectPipe(0, "use_this_mounted_weapon");--, entity.AI.current_mounted_weapon:GetName());
 		entity.AI.approachingMountedWeapon = true;
		AI.ModifySmartObjectStates(entity.id,"-UseMountedWeaponInterested");
	end,
	
	---------------------------------------------
	USE_MOUNTED_FAILED = function( self, entity )
		-- pathfinding or exact positioning to the MG has failed
		AI.Signal(SIGNALFILTER_SENDER,0,"LeaveMG",entity.id);
	end,
	
	--------------------------------------------------	
	LEAVE_MOUNTED_WEAPON = function(self, entity)
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_FIRST_CONTACT",entity.id);
		-- Choose proper action after being interrupted.
		AI_Utils:CommonContinueAfterReaction(entity);
	end,

	--------------------------------------------------	
	PLAYER_CLOSE = function(self, entity,sender,data)
		if(data and data.id) then 
			if(AI.Hostile(entity.id,data.id)) then
				local target = AI.GetAttentionTargetEntity(entity.id);
				if(target and (target.id == data.id)) then 
					AIBehaviour.UseMounted:LEAVE_MOUNTED_WEAPON(entity);
				end
			end
		end
	end,
}