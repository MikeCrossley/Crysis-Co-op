--------------------------------------------------
--   Description: the idle behaviour for a Civilian
-- Created by: Luciano Morpurgo
--------------------------



AIBehaviour.CivilianIdle = {
	Name = "CivilianIdle",
	Base = "HBaseIdle",
	-- TASK = 1, 

	Constructor = function(self, entity)
		AI.ChangeParameter( entity.id, AIPARAM_COMBATCLASS, AICombatClasses.Civilian );
	end,	

	---------------------------------------------
	Destructor = function(self,entity)
		if(entity.iLookTimer) then 
			Script.KillTimer(entity.iLookTimer);
			entity.iLookTimer = nil;
		end
	end,

	--------------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, signalData )
		-- called when the enemy sees an object

		if ( signalData.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end
		if (signalData.iValue == 150) then
			if (fDistance <= 40) then
				--entity:Readibility("GRENADE_SEEN",1);
				AI.LogEvent("GRENADE SEEN");
				entity:InsertSubpipe(0, "grenade_seen");
			end
		end
	end,
	
	---------------------------------------------

	OnCloseContact = function( self, entity, sender )
	end,
	
	---------------------------------------------
	OnTargetDead = function( self, entity, sender )
	end,

	
	---------------------------------------------

	OnSeenByEnemy = function( self, entity, sender )
--		entity:Readibility("THEY_SAW_US", 1);
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		if(not 	self:SearchCower(entity)) then 
			AI.Signal(SIGNALFILTER_NEARESTINCOMM_SPECIES,1,"CIVILIAN_SPOTTED_ENEMY",entity.id);
			entity:TriggerEvent(AIEVENT_DROPBEACON);
			entity:SelectPipe(0,"short_timeout");
		end
	end,
	---------------------------------------------
	END_TIMEOUT = function( self, entity, sender )
		-- no one answered, go to hide
	end,
	---------------------------------------------
	END_HIDE = function( self, entity, sender )
		entity:SelectPipe(0,"do_nothing");
	end,
	
	---------------------------------------------
	COME_HERE = function( self, entity, sender,data )
		entity:SelectPipe(0,"civ_report_contact",data.id);
	end,

	---------------------------------------------
	REPORT_ME = function( self, entity, sender)
		entity:InsertSubpipe(0,"civ_report_contact_inplace");
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		if(AI.GetGroupCount(entity.id)>1) then 
			entity:Readibility("idle_interested_alone");
		else
			entity:Readibility("idle_interested_hear_group");
		end
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		-- called when the enemy hears a scary sound
		if(AI.GetGroupCount(entity.id)>1) then 
			entity:Readibility("idle_alert_threat_hear_alone");
		else
			entity:Readibility("idle_alert_threat_hear_group");
		end
	end,
	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
--		entity:Readibility("GETTING_SHOT_AT",1);
		
		entity:Readibility("cower");
		AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_COWER",entity.id);
		AI.Signal(SIGNALFILTER_NEARESTINCOMM_SPECIES,0,"CIVILIAN_COWERING",entity.id,data);
	end,

	---------------------------------------------
	OnFriendlyDamage = function ( self, entity, sender,data)
--		entity:Readibility("GETTING_SHOT_AT",1);
		-- TO DO
		entity:Readibility("cower");
		AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_COWER",entity.id);
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender,data)
		-- called when detect weapon fire around AI
		--entity:MakeAlerted();
		entity:Readibility("cower");
		AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_COWER",entity.id);
		AI.Signal(SIGNALFILTER_NEARESTINCOMM_SPECIES,0,"CIVILIAN_COWERING",entity.id,data);
	end,

	--------------------------------------------------
	OnNearMiss = function ( self, entity, sender)
		-- called when detect weapon fire around AI
		--entity:MakeAlerted();
--		entity:Readibility("cower");
--		AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_COWER",entity.id);
--		AI.Signal(SIGNALFILTER_NEARESTINCOMM_SPECIES,0,"CIVILIAN_COWERING",entity.id,data);
	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	--------------------------------------------------
	OnGroupMemberDied = function( self, entity, sender)
		entity:Readibility("cower");
		AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_HIDE",entity.id);
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
		-- call the default to do stuff that everyone should do
		entity:Readibility("cower");
		AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_HIDE",entity.id);
		
	end,

	---------------------------------------------	
	OnSomebodyDied	 = function( self, entity, sender)
	
	end,
	---------------------------------------------	

	ORDER_ENTER_VEHICLE	= function (self, entity, sender,data)
--		AIBehaviour.SquadIdle:ORDER_ENTER_VEHICLE(entity,sender,data);
	end,
	ORDER_EXIT_VEHICLE	= function (self, entity, sender,data)
		--AIBehaviour.SquadIdle:ORDER_EXIT_VEHICLE(entity,sender,data);
	end,

	---------------------------------------------	
	ORDER_HOLD = function ( self, entity, sender, data ) 
	end,

	
	--------------------------------------------------------------
	FOLLOW_LEADER = function(self,entity,sender,data)
	end,

	---------------------------------------------
	LOOK_LEFT = function(self,entity,sender)
	end,
	---------------------------------------------
	LOOK_RIGHT = function(self,entity,sender)
	end,

	---------------------------------------------
	CheckLook = function (entity,timerId)
		--Script.KillTimer(timerId);
		if (entity.lookLeft ==nil) then
			entity.lookLeft = false;
		end
		entity.lookLeft = not entity.lookLeft;
		if(entity.lookLeft) then
			entity.Behaviour:LOOK_LEFT(entity,entity);
		else
			entity.Behaviour:LOOK_RIGHT(entity,entity);
		end

		entity.iLookTimer = Script.SetTimerForFunction(math.random(3000,4500),"AIBehaviour.HostageIdle.CheckLook",entity)
		
	end,
	
	---------------------------------------------
	SURRENDER  = function (self,entity,sender)
		entity:Readibility("surrender");
 	end,
	
	---------------------------------------------
	SearchCower = function(self,entity)
		local pos = g_Vectors.temp;
		local dir = g_Vectors.temp_v1;
		local anchorName = AI.FindObjectOfType(entity:GetPos(),15, AIAnchorTable.CIVILIAN_COWER_POINT,AIFAF_INCLUDE_DEVALUED,pos,dir );
		if(anchorName) then 
			local anchor = System.GetEntityByName(anchorName);
			if(anchor) then
				CopyVector(g_SignalData.point,pos);
				CopyVector(g_SignalData.point2,dir);
				AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_COWER",entity.id,g_SignalData);
				return true;
			end
		end
		return false;
	end, 	
	
	---------------------------------------------
	OnPlayerLooking = function(self,entity,sender,data)
		if(not AIBehaviour.CivilianIdle:SearchCower(entity)) then 
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_COWER",entity.id);
		end
	end,
	
}
