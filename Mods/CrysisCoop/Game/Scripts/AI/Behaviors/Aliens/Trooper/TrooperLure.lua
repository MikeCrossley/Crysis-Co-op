--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Group Lure behavior for Alien Trooper. 
--	The trooper lures the player to an ambush point
--  
--------------------------------------------------------------------------
--  History:
--  - 15/11/2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperLure = {
	Name = "TrooperLure",
	Base = "TROOPERDEFAULT",

	Constructor = function(self,entity)
		AIBehaviour.TROOPERDEFAULT.Constructor(self,entity);

		g_SignalData.iValue = UPR_COMBAT_GROUND;
		AI.Signal(SIGNALFILTER_LEADER, 10, "OnSetUnitProperties", entity.id,g_SignalData);
		entity.AI.bInvestigating = false;
		entity.AI.bMoving = false;
	end,	
	
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		entity:MakeAlerted();
		if(entity.AI.bInvestigating) then 
			self:GoToAmbushPoint(entity);
		elseif(not entity.AI.bMoving) then 
			entity:SelectPipe(0,"tr_just_shoot");
		end
		entity.AI.Target = AI.GetAttentionTargetEntity(entity.id);
	end,
	
	---------------------------------------------
	OnTargetDead = function( self, entity )
		-- called when the attention target died
		AI.LogEvent(entity:GetName().." >>> my target just died ");
	end,
	
	
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
		entity:Readibility("IDLE_TO_INTERESTED");
		entity:SelectPipe(0,"tr_look_closer");
		entity:MakeAlerted();
	end,
	

	
	---------------------------------------------
	GET_ALERTED = function( self, entity )
--		entity:Readibility("IDLE_TO_THREATENED");
--		entity:SelectPipe(0,"tr_pindown");
--		entity:DrawWeaponDelay(0.6);
	end,
	
	---------------------------------------------
--	DRAW_GUN = function( self, entity )
--		AI.LogEvent(entity:GetName().." DRAWING GUN");
--		if(not entity.currentItemId) then
--			entity:HolsterItem(false);
--		end
--	end,
	
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		entity:MakeAlerted();
		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then 
			entity:Readibility("IDLE_TO_INTERESTED");
			entity.AI.bInvestigating = true;
			entity:SelectPipe(0,"tr_look_closer");
		elseif(not entity.AI.bMoving) then 
			self:GoToAmbushPoint(entity);
		end
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		-- called when the enemy hears a scary sound
		entity:MakeAlerted();
		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then 
			entity:Readibility("IDLE_TO_THREATENED");
			entity.AI.bInvestigating = true;
			entity:SelectPipe(0,"tr_look_closer");
		elseif(not entity.AI.bMoving) then 
			self:GoToAmbushPoint(entity);
		
		end
	end,

	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
		entity:Readibility("GETTING_SHOT_AT",1);
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged

		entity:MakeAlerted();
		entity:Readibility("GETTING_SHOT_AT",1);
		if(AI.GetTargetType(entity.id) == AITARGET_ENEMY and not entity.AI.bMoving ) then 
			self:GoToAmbushPoint(entity);
		end
	end,

	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
		--entity:SelectPipe(0,"tr_scramble");
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender,data)
		-- called when detect weapon fire around AI

		entity:MakeAlerted();
		entity:Readibility("BULLETRAIN_IDLE");
		if(not entity.AI.bMoving and AI.GetTargetType(entity.id) == AITARGET_ENEMY) then 
			self:GoToAmbushPoint(entity);
			
		end

	end,

	--------------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, signalData )
		-- called when the enemy sees an object
		if ( signalData.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
			return;
		end
		entity:MakeAlerted();
		if (signalData.iValue == 150) then
			AI.LogEvent("OnObjectSeen() GRENADE "..entity:GetName());
			if (fDistance <= 40) then
				--entity:Readibility("GRENADE_SEEN",1);
				if (not entity.Behaviour.alertness) then
					entity:SelectPipe(0, "do_nothing");
				end
				entity:InsertSubpipe(0, "tr_grenade_seen");
			end
		end
	end,
	
	---------------------------------------------
	OnCloseContact = function(self,entity,sender)

		--self:GoToAmbushPoint(entity);
	end,
	
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)
		-- do cover stuff

		--AIBehaviour.DEFAULT:OnGroupMemberDied(entity,sender);
	end,

	--------------------------------------------------
	OnLeaderDied = function(self,entity,sender)
		if(AI.GetGroupTarget(entity.id,true,true)) then
			entity:SelectPipe(0,"tr_confused");
		else
			AIBehaviour.TrooperGroupIdle:OnLeaderDied(entity,sender);
		end
		entity.AI.InSquad = 0;
	end,


	--------------------------------------------------
	INVESTIGATE_TARGET = function (self, entity, sender)
		entity:SelectPipe(0,"tr_investigate_threat");		
	end,
	---------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
	end,

	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,

	---------------------------------------------	
	TR_NORMALATTACK = function (self, entity, sender)

	end,

	---------------------------------------------	

	END_SHORT_FIRE = function (self, entity, sender)
		self:GoToAmbushPoint(entity);
	end,

	---------------------------------------------	
	GoToAmbushPoint = function(self,entity)
		entity.AI.bInvestigating = false;
		entity.AI.bMoving = true;
		local anchorName = AI.FindObjectOfType(entity.id, 200, AIAnchorTable.ALIEN_AMBUSH_AREA,AIFAF_INCLUDE_DEVALUED);
		if(anchorName and anchorName~="") then 
			--AI.Signal(SIGNALFILTER_SENDER,0,"MOVE",entity.id,g_SignalData);
			entity:SelectPipe(0,"do_nothing");
			entity:InsertSubpipe(0,"tr_goto",anchorName);
			entity:InsertSubpipe(0,"do_it_running");
			local targetType = AI.GetTargetType(entity.id);
			if(targetType ==AITARGET_ENEMY or targetType ==AITARGET_SOUND or targetType ==AITARGET_MEMORY) then
				local distToTarget = AI.GetAttentionTargetDistance(entity.id);
				if(distToTarget>5) then 		
					entity:InsertSubpipe(0,"tr_short_fire");
				end
			end
		else
			AI.Warning(entity:GetName().." couldn't find an anchor ALIEN_AMBUSH_AREA");
		end
	end,
	
	---------------------------------------------	
	END_GOTO = function (self, entity, sender)
		g_SignalData.id = NULL_ENTITY;
		local unitcount = AI.GetGroupCount(entity.id);
		for i=1,unitcount do
			local mate = AI.GetGroupMember(entity.id,i);
			if(mate) then 
				local target = AI.GetAttentionTargetEntity(mate.id);
				if(target and AI.Hostile(mate.id,target.id)) then 
					g_SignalData.id = target.id;
					AI.Signal(SIGNALFILTER_SUPERGROUP,0,"START_AMBUSH",entity.id,g_SignalData);
					return;
				end
			end
		end
	end,
	
}
