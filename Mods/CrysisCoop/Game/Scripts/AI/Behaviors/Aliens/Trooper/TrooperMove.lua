--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Move behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - Aug 2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperMove = {
	Name = "TrooperMove",
	Base = "TROOPERDEFAULT",

	Constructor = function(self,entity,data)
		AI.LogEvent(entity:GetName().." TrooperMove constructor");
		if(not IsNullVector(data.point)) then 
			AI.SetRefPointPosition(entity.id,data.point);
		end
		entity.AI.Direction ={x=0,y=0,z=0,};
		CopyVector(entity.AI.Direction,data.point2);
		
		if(data.iValue==0) then 
			entity:SelectPipe(0,"tr_approach_refpoint");
		elseif(data.iValue==1) then 
			entity:SelectPipe(0,"tr_stick_refpoint");
		else 
			entity:SelectPipe(0,"tr_approach_refpoint2");
		end
		if(data.fValue==1) then 
			entity:InsertSubpipe(0,"do_it_running");
		elseif(data.fValue==2) then 
			entity:InsertSubpipe(0,"do_it_sprinting");
		end
 	  entity:InsertSubpipe(0, "reset_lookat");

		--entity:InsertSubpipe(0,"do_it_prone");
--		entity:InsertSubpipe(0,"start_fire");
		entity:Cloak(0);

	end,	

	Destructor = function (self,entity)
		AI.LogEvent(entity:GetName().." TROOPERMOVE destructor");
	end,
	
	OnPlayerSeen = function( self, entity, fDistance )
		
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target and target.id) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end
		
		entity:Readibility("FIRST_HOSTILE_CONTACT",0,1);


--		if(target and target.id) then 
--			g_SignalData.id = target.id;
--		else
--			g_SignalData.id = NULL_ENTITY;
--		end
--		g_SignalData.fValue = fDistance;
		--AI.Signal(SIGNALFILTER_LEADERENTITY, 1, "OnEnemySeenByUnit",entity.id);
		
	end,
	
	
	
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	

	
	---------------------------------------------
	GET_ALERTED = function( self, entity )
	end,
	
	---------------------------------------------
	DRAW_GUN = function( self, entity )
		AI.LogEvent(entity:GetName().." DRAWING GUN");
		if(not entity.inventory:GetCurrentItemId()) then
			entity:HolsterItem(false);
		end
	end,
	
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		AI.LogEvent(entity:GetName().." OnInterestingSound heard");
		entity:Readibility("IDLE_TO_INTERESTED");

	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		-- called when the enemy hears a scary sound
		entity:Readibility("IDLE_TO_THREATENED",1);

		entity:DrawWeaponDelay(0.5);


--		entity:Blind_RunToAlarm();

	end,

	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
		entity:Readibility("GETTING_SHOT_AT",1);
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged

--		g_SignalData.id = data.id;
--		AI.Signal(SIGNALFILTER_LEADERENTITY, 1, "OnEnemySeenByUnit",entity.id);
	end,

	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
	end,


	--------------------------------------------------
--	OnObjectSeen = function( self, entity, fDistance, signalData )
--		-- called when the enemy sees an object
--
--	end,
	
	---------------------------------------------
	OnCloseContact = function(self,entity,sender)
	end,

	---------------------------------------------
	OnNoHidingPlace = function(self,entity,sender)
		
	end,
	
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)
		-- do cover stuff
--			entity:MakeAlerted();

		--AIBehaviour.DEFAULT:OnGroupMemberDied(entity,sender);
	end,


	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender,data)
		-- call the default to do stuff that everyone should do
	end,


	--------------------------------------------------
	INVESTIGATE_TARGET = function (self, entity, sender)
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
	THREAT_TOO_CLOSE = function (self, entity, sender)
	end,
	
	---------------------------------------------	
	REFPOINT_REACHED = function(self,entity,sender)
		entity:SelectPipe(0,"do_nothing"); -- to not process this signal again in the same goalpipe
		if(not IsNullVector(entity.AI.Direction) and AI.GetTargetType(entity.id)~=AITARGET_ENEMY) then 
			local lookpoint = g_Vectors.temp;
			FastSumVectors(lookpoint,AI.GetRefPointPosition(entity.id),entity.AI.Direction);
			FastSumVectors(lookpoint,lookpoint,entity.AI.Direction);
			lookpoint.z = lookpoint.z + 1;
			entity:InsertSubpipe(0,"look_at_lastop","refpoint");
		end
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,
	
	---------------------------------------------	
	REFPOINT_REACHED2 = function(self,entity,sender)
		entity:SelectPipe(0,"do_nothing"); -- to not process this signal again in the same goalpipe
	end,


}
