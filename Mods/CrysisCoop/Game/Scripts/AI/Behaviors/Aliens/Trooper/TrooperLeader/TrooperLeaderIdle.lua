--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Idle behavior for Alien Trooper Leader. 
--  
--------------------------------------------------------------------------
--  History:
--  - 7/2/2006     : Created by Luciano Morpurgo
--------------------------------------------------------------------------

AIBehaviour.TrooperLeaderIdle = {
	Name = "TrooperLeaderIdle",
	Base = "TrooperGroupIdle",

	---------------------------------------------
	Constructor = function(self , entity )
		System.Log(entity:GetName().." TrooperLeaderIdle Constructor");

		AI.Signal(SIGNALFILTER_SENDER, 0, "SEND_JOIN_TEAM", entity.id);
		AI.Signal(SIGNALFILTER_LEADER, 0, "OnKeepEnabled", entity.id);
		
		-- clear all group behavior properties (dont move and dont join combat)
		AI.SetUnitProperties( entity.id, UPR_COMBAT_GROUND );
		entity.AI.EnemyAvgPos = {x=0,y=0,z=0};
		entity.AI.DefensePoint = {x=0,y=0,z=0};
		ItemSystem.GiveItem("MOAR",entity.id);
		ItemSystem.SetActorItemByName(entity.id,"LightMOAC",false);
		AIBehaviour.TROOPERDEFAULT.Constructor(self,entity);

	end,

	------------------------------------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target and target.id) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end
		
		entity:Readibility("FIRST_HOSTILE_CONTACT",0,1);

		entity:TriggerEvent(AIEVENT_DROPBEACON);

		if(target and target.id) then 
			g_SignalData.id = target.id;
		else
			g_SignalData.id = NULL_ENTITY;
		end
		g_SignalData.fValue = fDistance;
		self:OnEnemySeenByUnit(entity,entity,g_SignalData);
		
	end,
		
	------------------------------------------------------------------------
	OnEnemySeenByUnit = function(self,entity,sender,data)
		-- sent by a team member
		-- data.fValue = distance to seen enemy
		-- data.id = enemy's entity id
	--	AI.LogEvent("ONENEMYSEENBY UNIT sent by "..sender:GetName().." behavior="..sender.Behaviour.Name);
		if(data.fValue>8) then 
			-- transition to threatened;
			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "GO_THREATEN", entity.id);
			entity.iTimer = Script.SetTimerForFunction(1000,"AIBehaviour.TrooperLeaderIdle.OnStartAttack",entity);
		else
			-- no transition, target is too close - attack immediately
			AIBehaviour.TrooperLeaderIdle.OnStartAttack(entity,nil);
		end
	end,

	------------------------------------------------------------------------
	SEND_JOIN_TEAM = function(self,entity,sender)	
		AI.Signal(SIGNALFILTER_SUPERGROUP, 0, "JOIN_TEAM", entity.id);
	end,
	
	------------------------------------------------------------------------
	ORDER_ATTACK_FORMATION = function(self,entity,sender)
		-- ignore this order
		AI.Signal(SIGNALFILTER_LEADER, 10, "ORD_DONE", entity.id);
		
	end,
	
	------------------------------------------------------------------------
	OnResetFormationUpdate = function(self,entity,sender)
		AI.SetFormationUpdate(entity.id,false);
	end,

	------------------------------------------------------------------------
	OnSetFormationUpdate = function(self,entity,sender)
		AI.SetFormationUpdate(entity.id,true);
	end,
	
	------------------------------------------------------------------------
	OnAttackRequestFailed = function(self,entity,sender,data)
		-- data.iValue = failed attack action (LAS_*)
		local attackType = data.iValue;
		if(attackType == LAS_ATTACK_ROW) then
			AI.RequestAttack(entity.id,UPR_COMBAT_GROUND,LAS_ATTACK_LEAPFROG,20);
		end
	
	end,
	
	------------------------------------------------------------------------

	GROUP_CLOAK = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_SUPERGROUP,0,"CLOAK",entity.id);
	end,
	------------------------------------------------------------------------

	GROUP_UNCLOAK = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_SUPERGROUP,0,"UNCLOAK",entity.id);
	end,

	--------------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, signalData )
		-- called when the enemy sees an object
		if ( signalData.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end
		if (signalData.iValue == 150) then
			if (fDistance <= 40) then
				entity:InsertSubpipe(0, "tr_grenade_seen");
			end
		end
	end,

	------------------------------------------------------------------------
	OnBackOffFailed = function(self,entity,sender)
		if(AI.GetAttentionTargetType(entity.id) ==150) then 
		-- this is for grenades only, just retry depending on the new grenade position
			entity:InsertSubpipe(0,"tr_grenade_seen");
		end
	end,	
	
	
	------------------------------------------------------------------------
	OnGroupMemberDied = function(self,entity,sender)
 	 	CopyVector(g_SignalData.point,AI.GetRefPointPosition(sender.id));
		g_SignalData.iValue = UPR_COMBAT_GROUND + UPR_COMBAT_RECON;
		g_SignalData.fValue = 20; --search distance
		AI.Signal(SIGNALFILTER_LEADER,1,"ORD_SEARCH",entity.id,g_SignalData);
		AI.Signal(SIGNALFILTER_SENDER,1,"GOTO_SEARCH",entity.id);
	end,

	------------------------------------------------------------------------
	OnUnitDamaged = function(self,entity,sender,data)
 	 	CopyVector(g_SignalData.point,data.point);
		g_SignalData.iValue = UPR_COMBAT_GROUND + UPR_COMBAT_RECON;
		g_SignalData.fValue = 20; --search distance
		AI.Signal(SIGNALFILTER_LEADER,1,"ORD_SEARCH",entity.id,g_SignalData);
		AI.Signal(SIGNALFILTER_SENDER,1,"GOTO_SEARCH",entity.id);
	end,
	
	------------------------------------------------------------------------
	OnStartAttack = function(entity,timerid)

		entity.AI.StartTime = System.GetCurrTime();
--		local avgPos = g_Vectors.temp;
--		AI.GetGroupAveragePosition(entity.id,UPR_COMBAT_GROUND,avgPos);
--		if(not IsNullVector(avgPos)) then 
			local anchorName = AI.FindObjectOfType(entity.id,70, AIAnchorTable.COMBAT_PROTECT_THIS_POINT,AIFAF_INCLUDE_DEVALUED,entity.AI.DefensePoint );
			if(anchorName and anchorName~="") then
				AI.LogEvent("Troopers defending point "..anchorName);
				AI.RequestAttack(entity.id,UPR_COMBAT_GROUND,LAS_ATTACK_ROW,random(5,6),entity.AI.DefensePoint);
				return;
			end
--		end
		--AI.Signal(SIGNALFILTER_SUPERGROUP,1,"GO_TO_ATTACK",entity.id);
		local navType = AI.GetNavigationType(AI.GetGroupOf(entity.id),UPR_COMBAT_GROUND);
		if(navType == NAV_WAYPOINT_3DSURFACE) then 
			g_SignalData.iValue = LAS_ATTACK_USE_SPOTS;
			g_SignalData.fValue = 10;
			g_SignalData.iValue2 = UPR_COMBAT_GROUND;
			AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_ATTACK", entity.id,g_SignalData);
		else	
			AI.RequestAttack(entity.id,UPR_COMBAT_GROUND,LAS_ATTACK_ROW,random(5,6));
		end
	end,
	
	------------------------------------------------------------------------
	OnDeath = function ( self, entity, sender)
		if(entity.iTimer) then 
			Script.KillTimer(entity.iTimer);
			entity.iTimer = nil;
		end
	end,

	-----------------------------------------------------------
	OnPlayerInSight = function(self,entity,sender,data)
		AI.Signal(SIGNALFILTER_LEADER,0,"OnSpotSeeingTarget",entity.id,data);
	end,

	-----------------------------------------------------------
	OnPlayerLost = function(self,entity,sender,data)
		AI.Signal(SIGNALFILTER_LEADER,0,"OnSpotLosingTarget",entity.id,data);
	end,

	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
		AI.LogEvent(entity:GetName().." OnInterestingSound heard");
		entity:Readibility("IDLE_TO_INTERESTED",1);

--		entity:SelectPipe(0,"tr_look_closer");
--		entity:InsertSubpipe(0,"tr_setup_stealth"); 
--		AI.Signal(SIGNALFILTER_GROUPONLY,0,"GO_TO_INTERESTED",entity.id);
		AI.GetAttentionTargetPosition(entity.id,g_SignalData.point);
		g_SignalData.fValue = AI.GetAttentionTargetDistance(entity.id);
		AI.Signal(SIGNALFILTER_NEARESTINCOMM,0,"LOOK_CLOSER",entity.id,g_SignalData);
	end,	
}
