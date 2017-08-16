--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Alien Trooper approaches a target at a given distance
--  This is a group behaviour
--------------------------------------------------------------------------
--  History:
--  - 1 Sept 2005     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.TrooperApproach = {
	Name = "TrooperApproach",
	Base = "TROOPERDEFAULT",
	
	Constructor = function(self,entity,data)
		-- data.fValue = distance to keep to target
		-- data.iValue = if 0, target is moving - don't hide
		entity:Cloak(0);
	
		local distance = data.fValue;
		if(data.iValue==0) then -- don't hide
			g_StringTemp1 = "order_stick"..distance;
			AI.CreateGoalPipe(g_StringTemp1);
			AI.PushGoal(g_StringTemp1,"firecmd",1,0);
			AI.PushGoal(g_StringTemp1,"run",1,1);
			if (data.fValue>=0) then
				-- approach beacon
				AI.PushGoal(g_StringTemp1,"locate",1,"beacon");
				AI.PushGoal(g_StringTemp1,"stick",1,data.fValue,AILASTOPRES_USE,1);
			else --
				-- approach att target
				AI.PushGoal(g_StringTemp1,"stick",1,3,0,1);
			end
			AI.PushGoal(g_StringTemp1,"signal",1,10,"OnApproachEnd",SIGNALFILTER_LEADER);
			AI.PushGoal(g_StringTemp1,"signal",1,10,"ORD_DONE",SIGNALFILTER_LEADER);
			AI.PushGoal(g_StringTemp1,"firecmd",1,1);
		else --hide
			g_StringTemp1 = "order_stick_and_hide"..distance;
			local hideDist = 4;			
			AI.CreateGoalPipe(g_StringTemp1);
			AI.PushGoal(g_StringTemp1,"firecmd",1,0);
			AI.PushGoal(g_StringTemp1,"run",1,1);
			if (data.fValue>=0) then
				-- approach beacon
				AI.PushGoal(g_StringTemp1,"locate",1,"beacon");
				AI.PushGoal(g_StringTemp1,"stick",1,distance+hideDist,AILASTOPRES_USE,1);
			else --
				-- approach att target
				AI.PushGoal(g_StringTemp1,"stick",1,3+hideDist,0,1);
			end
			AI.PushGoal(g_StringTemp1,"hide",1,hideDist+1,HM_NEAREST_TOWARDS_TARGET);
			AI.PushGoal(g_StringTemp1,"branch",1,"END",IF_CAN_HIDE);
				-- can't hide
				if (data.fValue>=0) then
					-- approach beacon
					AI.PushGoal(g_StringTemp1,"locate",1,"beacon");
					AI.PushGoal(g_StringTemp1,"stick",1,distance,AILASTOPRES_USE,1);
				else --
					-- approach att target
					AI.PushGoal(g_StringTemp1,"stick",1,3,0,1);
				end
			AI.PushLabel(g_StringTemp1,"END");
			AI.PushGoal(g_StringTemp1,"signal",1,10,"ORD_DONE",SIGNALFILTER_LEADER);
			AI.PushGoal(g_StringTemp1,"firecmd",1,1);
		end
		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(0,g_StringTemp1);

	--	entity:Event_Cloak();
		if(not AI.Hostile(entity.id,AI.GetAttentionTargetOf(entity.id))) then
			entity:InsertSubpipe(0,"acquire_beacon");
		end

		entity.AI.bMoving = true;
	end,

	Destructor = function(self,entity,data)
--		entity:Event_UnCloak();
		--AI.SetRefPointPosition(entity.id,entity:GetPos());
	end,	
	---------------------------------------------
--	ORDER_HIDE_AROUND = function(self,entity,sender)
--		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
--	end,
	
--	ORDER_APPROACH_END = function(self,entity,sender)
--		-- check for friends in way
--		entity.AI.bMoving = false;
--	end,

	OnPlayerSeen = function(self,entity,sender)
	
	end,

	
	OnNoHidingPlace = function( self, entity, sender )
	end,
	
	OnDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
		entity:Readibility("GETTING_SHOT_AT",1);

	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
		entity:Readibility("GETTING_SHOT_AT",1);

	end,
	
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
	end,
	--------------------------------------------------
	OnEnemyMemory = function ( self, entity, sender)
	end,
	
	--------------------------------------------------
	OnNoTarget = function ( self, entity, sender)
	end,
	
	--------------------------------------------------
--	OnPathFound = function ( self, entity, sender)
--		AI.Signal(SIGNALFILTER_LEADER,1,"OnPathFound",entity.id);
--	end,
	--------------------------------------------------
	OnNoPathFound = function ( self, entity, sender)
		AI.Signal(SIGNALFILTER_LEADER,1,"OnNoPathFound",entity.id);
	end,
	--------------------------------------------------
	OnEndPathOffset = function ( self, entity, sender)
		AI.Signal(SIGNALFILTER_LEADER,1,"OnNoPathFound",entity.id);
	end,
}