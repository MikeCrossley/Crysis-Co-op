--------------------------------------------------
--    Created By: Luciano Morpurgo
--   Description: <short_description>
--------------------------
--

AIBehaviour.TrGroupSearch = {
	Name = "TrGroupSearch",
	BASE = "TROOPERDEFAULT",
	--TASK = 1,
	alertness = 1,
	search = true,
	hasConversation = true,
	
	Constructor = function ( self, entity,data )
		-- data.point = search spot pos
		-- data.point2 = search spot dir
		if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then 
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK",entity.id);		
			return;
		end
		
		AI.SetRefPointPosition(entity.id,data.point);
		if(not entity.AI.lookDir ) then 
			entity.AI.lookDir = {};
		end
		CopyVector(entity.AI.lookDir, data.point2);
 	  entity:SelectPipe(0, "do_nothing");--clear all current goals
 	  --entity:SelectPipe(0, "tr_look_around");
 	  if(data.iValue==0) then
    	entity:SelectPipe(0, "tr_order_search");
    else
    	entity:SelectPipe(0, "tr_order_search_hidespot");
    end
    if(entity.searchSound) then
    	entity:StopSound(entity.searchSound);
    	entity.searchSound = nil;
    end
--		local sndFlags = bor(SOUND_DEFAULT_3D,SOUND_LOOP);
--    entity.searchSound = entity:PlaySoundEvent("sounds/alien:trooper:laser",g_Vectors.v000, g_Vectors.v010, sndFlags, SOUND_SEMANTIC_AI_READABILITY);

		Trooper_SetAccuracy(entity);
		Trooper_SetConversation(entity);
	end,

	---------------------------------------------
	Destructor = function ( self, entity)
    if(entity.searchSound) then
    	entity:StopSound(entity.searchSound);
    	entity.searchSound = nil;
    end
	  entity:SelectPipe(0, "do_nothing");--clear all current goals
 	  entity:InsertSubpipe(0, "reset_lookat");
		AI.SetStance(entity.id,BODYPOS_STAND);
 	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
		-- data.id = shooter id
		-- data.point = shooter position
		entity:Cloak(0);
		if(AIBlackBoard.lastTrooperDamageTime and _time - AIBlackBoard.lastTrooperDamageTime < 1) then 
			return;
		end
		AIBlackBoard.lastTrooperDamageTime = _time;
		local pos = g_Vectors.temp;
		local mypos = g_Vectors.temp_v1;
		local shooter = System.GetEntity(data.id);
--		if(shooter) then 
--			CopyVector(pos,shooter:GetWorldPos());
--		else
--			CopyVector(pos,data.point);
--		end

--		CopyVector(mypos,entity:GetPos());
--		ScaleVectorInPlace(pos,0.7); -- weighted sum
--		ScaleVectorInPlace(mypos,0.3); -- weighted sum
--		FastSumVectors(g_SignalData.point,pos,mypos);
		if(shooter) then 
			--CopyVector(g_SignalData.point,shooter:GetWorldPos());
			FastSumVectors(g_SignalData.point,entity:GetPos(),shooter:GetPos());
			ScaleVectorInPlace(g_SignalData.point,0.5); 
		else
			CopyVector(g_SignalData.point,data.point);
		end
		g_SignalData.id = data.id;
		
		AI.Signal(SIGNALFILTER_LEADER,1,"OnUnitDamaged",entity.id,g_SignalData);
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender, data)
		-- data.id: the shooter
	end,

	---------------------------------------------
	CORD_ATTACK = function( self, entity, sender )
		-- Ignore this order!
	end,

	---------------------------------------------	
	-- Orders --
	---------------------------------------------

	ORDER_SEARCH = function ( self, entity, sender, data )
	  AI.LogEvent("ORDER_SEARCH received in TrGroupSearch of "..entity:GetName());
		AI.SetRefPointPosition(entity.id, data.point);
 	  entity:SelectPipe(0, "do_nothing");--clear all current goals
 		CopyVector(entity.AI.lookDir, data.point2);
	  --entity:SelectPipe(0, "tr_look_around");
    entity:SelectPipe(0, "tr_order_search");
	end,

	---------------------------------------------
	HIDESPOT_REACHED = function ( self, entity, sender)
		local pos = g_Vectors.temp;
		CopyVector(pos,AI.GetRefPointPosition(entity.id));
		local dir  = entity.AI.lookDir;
		if(dir == nil or IsNullVector(dir)) then
			dir ={};
			CopyVector(dir,entity:GetDirectionVector(1));
		end
		ScaleVectorInPlace(dir,4);
		FastSumVectors(pos,pos,dir);
		AI.SetRefPointPosition(entity.id,pos);
	end,
	
	-- SYSTEM EVENTS			-----
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,

	---------------------------------------------
	OnCloseContact = function( self, entity, target )
		-- should not happen before OnPlayerSeen
		AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK",entity.id);
		
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the enemy sees a living player
		-- first send him OnSeenByEnemy signal
--		if(entity.AI.InSquad==1) then 
--			local target = AI.GetAttentionTargetEntity(entity.id);
--			if(target) then 
--				g_SignalData.id = target.id;
--			else
--				g_SignalData.id = NULL_ENTITY;
--			end
--			g_SignalData.fValue = fDistance;
--			AI.Signal(SIGNALFILTER_LEADERENTITY,0,"OnEnemySeenByUnit",entity.id,g_SignalData);
--		else
--			-- no more leader
--			g_SignalData.iValue = LAS_ATTACK_FRONT;
--			AI.Signal(SIGNALFILTER_LEADER,0,"ORD_ATTACK",entity.id,g_SignalData);
--		end
		entity:ReadibilityContact();
		AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK",entity.id);
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
 	  entity:SelectPipe(0, "do_nothing");--clear all current goals
    entity:SelectPipe(0, "tr_order_search");
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity,sender )
		local pos = g_Vectors.temp;
		if(AI.GetAttentionTargetPosition(entity.id,pos)) then 
			-- move the current hidespot to the target position
			AI.SetRefPointPosition(entity.id,pos);
			CopyVector(entity.AI.lookDir,g_Vectors.v000);
	 	  entity:SelectPipe(0, "do_nothing");--clear all current goals
  	  entity:SelectPipe(0, "tr_order_search");
  	end
	end,
	
	---------------------------------------------
	OnSomethingSeen = function( self, entity, sender )
		local target = AI.GetAttentionTargetEntity(entity.id);
		if(target and target.id) then 
			g_SignalData.id = target.id;
		else
			g_SignalData.id = NULL_ENTITY;
		end
		g_SignalData.ObjectName = AI.GetAttentionTargetOf(entity.id);
--		System.Log(entity:GetName().." ON SOMETHING SEEN: "..tostring(g_SignalData.ObjectName));
		AI.Signal(SIGNALFILTER_GROUPONLY,0,"LOOK_CLOSER",entity.id,g_SignalData);
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
		entity:SelectPipe(0,"tr_look_closer");
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
	---------------------------------------------
	INCOMING_FIRE = function ( self, entity, sender)
	end,
	---------------------------------------------
	OnBulletRain = function ( self, entity, sender,data)
		-- called when the enemy detects bullet trails around him
--		local shooter = System.GetEntity(data.id);
--		if(shooter) then 
--			if(entity:GetDistance(shooter.id)<30) then
--				AI.SetRefPointPosition(entity.id,shooter:GetPos());
--				entity:SelectPipe(0,"tr_approach_refpoint");
--			end
--		end
		if(AI.Hostile(entity.id,data.id) and (entity.AI.lastEnemyDamageTime==nil or (_time - entity.AI.lastEnemyDamageTime > 0.3))) then 
			self:OnEnemyDamage(entity,sender,data);
		end
	end,
	
	--------------------------------------------------
	OnBulletHit = function( self, entity, sender,data )
		if(AI.Hostile(entity.id,data.id) and (entity.AI.lastEnemyDamageTime==nil or (_time - entity.AI.lastEnemyDamageTime > 0.3))) then 
			self:OnEnemyDamage(entity,sender,data);
		end
	end,


	---------------------------------------------
	END_SEARCH = function ( self, entity, sender)
		--entity:SelectPipe(0,"tr_look_around");
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,
--	---------------------------------------------
--	OnLeaderDied = function ( self, entity, sender)
--		--entity:SelectPipe(0,"tr_pindown");
--		entity.AI.InSquad = 0;
--
--	end,
	---------------------------------------------
	END_LOOK_CLOSER = function ( self, entity, sender)
 	  entity:SelectPipe(0, "do_nothing");--clear all current goals
 	  --entity:SelectPipe(0, "tr_look_around");
    entity:SelectPipe(0, "tr_order_search");
	end,
	
	--------------------------------------------------
	JUMP_ON_ROCK = function (self,entity,sender,data)
			AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,

	--------------------------------------------------
	JUMP_ON_WALL = function (self,entity,sender,data)
			AI.ModifySmartObjectStates(data.id,"-Busy");				
	end,

	--------------------------------------------------
	CHECK_DEAD_TARGET = function(self,entity,sender)

	end,
	
	---------------------------------------------
	OnCheckDeadBody = function( self, entity,sender, data)
	end,
	
	---------------------------------------------
	END_CHECK_DEAD_BODY = function( self, entity,sender)
	end,

	---------------------------------------------
	OnNoGroupTarget = function( self, entity,sender, data)
	end,
}