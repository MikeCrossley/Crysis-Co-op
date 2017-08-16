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
-- 		19/4/2007 	 : Finalized by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperThreatened = {
	Name = "TrooperThreatened",
	Base = "TROOPERDEFAULT",
	alertness = 1,

	---------------------------------------------
	Constructor = function (self, entity,data)
		entity.AI.startTime = _time;
		entity:Cloak(0);
		entity:MakeAlerted();
		local target = AI.GetAttentionTargetEntity(entity.id);
--		local pos = g_Vectors.temp;
		
--		FastSumVectors(pos,entity:GetPos(),data.point);
--		ScaleVectorInPlace(pos,0.5);
		local pos = data.point;
			
		AI.SetRefPointPosition(entity.id,pos);				
		if(target and AI.GetAttentionTargetDistance(entity.id)<20) then
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ATTACK",entity.id);
			if(target.id ~= data.id ) then
				entity:SelectPipe(0,"tr_retaliate_target",data.id);
			end
		else
			entity:SelectPipe(0,"tr_approach_refpoint");
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_retaliate_target","refpoint");
		end
--		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"do_it_stealth");

	end,

	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
--		entity:Readibility("ENEMY_TARGET_LOST");
--		entity:SelectPipe(0,"tr_search_for_target");
	end,

	---------------------------------------------
	REFPOINT_REACHED = function( self, entity )
		if(AI.GetLeader(entity.id)) then
			CopyVector(g_SignalData.point,entity:GetPos());
			g_SignalData.iValue = UPR_COMBAT_GROUND + UPR_COMBAT_RECON;
			g_SignalData.iValue2 = AIAnchorTable.SEARCH_SPOT;
			g_SignalData.fValue = 20; --search distance
			AI.Signal(SIGNALFILTER_LEADER,1,"ORD_SEARCH",entity.id,g_SignalData);
		else
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_SEARCH",entity.id);
		end	
	end,
	
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player
--		entity:Readibility("FIRST_HOSTILE_CONTACT",1);
--		entity:TriggerEvent(AIEVENT_DROPBEACON);
--
--		if (AI.GetGroupCount(entity.id) > 1) then
--			-- only send this signal if you are not alone
--			entity:SelectPipe(0,"tr_scramble_beacon");
--
--			if (entity:NotifyGroup()==nil) then
--				AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "HEADS_UP_GUYS",entity.id);
--				AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "wakeup",entity.id);
--			end
--		else
--			-- you are on your own
--			entity:SelectPipe(0,"tr_scramble");
--		end


--   	entity:InsertSubpipe(0, "throw_grenade");

	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
	 	entity:SelectPipe(0,"tr_investigate_threat"); 
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		entity:SelectPipe(0,"tr_seek_target");
	end,
	
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
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
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		entity:Readibility("GETTING_SHOT_AT",1);
	end,

	---------------------------------------------
	OnBulletRain = function ( self, entity, sender,data)	
--		if(AI.Hostile(entity.id,data.id) and not Trooper_IsThreateningBullet(entity,data.point)) then 
--			entity.AI.lastEnemyDamageTime	 = _time;
--			AIBlackBoard.lastTrooperDamageTime = _time;
			Trooper_GoToThreatened(entity,data.point,data.id);
--		end				
	end,

	---------------------------------------------
	OnBulletHit = function ( self, entity, sender,data)	
		local curtime = _time;
		-- don't make the trooper lured by every single hit
		if(entity.AI.lastBulletHitTime==nil or (curtime - entity.AI.lastBulletHitTime > 5)) then 
			Trooper_GoToThreatened(entity,data.point);
			entity.AI.lastBulletHitTime = curtime;
		end
	end,
	
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
--		local curtime = _time;
--		--if(entity.AI.lastEnemyDamageTime==nil or (curtime - entity.AI.lastEnemyDamageTime > 0.6)) then 
--			entity.AI.lastEnemyDamageTime = curtime;
--			AIBlackBoard.lastTrooperDamageTime = curtime;
			Trooper_GoToThreatened(entity,data.point,data.id);
		--end

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
	OnGroupMemberDied = function( self, entity, sender)
		-- called when a member of the group dies
	end,


	---------------------------------------------
	Cease = function( self, entity, fDistance )
		entity:SelectPipe(0,"tr_cease_approach"); -- in PipeManagerShared.lua			 
	end,

	--------------------------------------------------
	TRY_TO_LOCATE_SOURCE = function (self, entity, sender)
		entity:SelectPipe(0,"tr_lookaround_30seconds");
	end,

	--------------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
--		if (entity ~= sender) then
--			AI.SetRefPointPosition(entity.id,sender:GetWorldPos());
--			entity:SelectPipe(0,"tr_random_hide","refpoint");
--		end
	end,


	------------------------------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
		-- do nothing on this signal
	end,

	------------------------------------------------------------------------
	PLAYER_ENGAGED= function (self, entity, sender)
		-- trooper is threatened and would attack anyway, do nothing here
	end,
}