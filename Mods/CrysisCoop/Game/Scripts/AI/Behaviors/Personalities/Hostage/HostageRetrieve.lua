--------------------------------------------------
--   Created By: Luciano Morpurgo
-- 	Hostage goes retrieving an object
--------------------------

AIBehaviour.HostageRetrieve = {
	Name = "HostageRetrieve",

	Constructor = function( self, entity )	
--		entity.AI.InSquad = 1;
		AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 8);
--		local anchorName = AI.GetAnchor(entity.id,AIAnchorTable.ACTION_RETRIEVE_OBJECT,100.0,AIANCHOR_NEAREST);	
--		if(not anchorName) then 
--			AI.Warning(entity:GetName().."couldn't find anchor ACTION_RETRIEVE_OBJECT. Aborting");
--			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_PREVIOUS",entity.id);
--			return;
--		end;
--		entity:SelectPipe(0,"hostage_retrieve_object",anchorName);
		entity.AI.Cower = false;
		entity.AI.bulletRainCount = 0;
		entity.AI.bulletRainTime = _time;
		entity.AI.waiting = false;

		AI.Signal(SIGNALFILTER_LEADER,10,"OnUnitBusy",entity.id);
		--AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 8);
		AI.ModifySmartObjectStates(entity.id,"HostageMoving");
		entity.AI.iTimer = Script.SetTimerForFunction(2000,"AIBehaviour.HostageRetrieve.CheckPlayer",entity);		
		entity.AI.init = true;
	end,

	Destructor = function( self, entity )	
		AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 0);
		AI.ModifySmartObjectStates(entity.id,"-HostageMoving");
		if(entity.AI.iTimer) then 
			Script.KillTimer(entity.AI.iTimer);
		end
	end,

	---------------------------------------------
	FOLLOW = function( self, entity, sender )
		AI.Signal(SIGNALFILTER_LEADER,10,"OnJoinTeam",entity.id);
	end,
	
	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		if(fDistance > entity.melee.damageRadius) then
			local target = AI.GetAttentionTargetEntity(entity.id);
			if(not entity:IsUsingPipe("hostage_cower")) then 
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"hostage_hide_short",target.id);
			end
		-- else OnCloseContact is executed
		end
	end,
	
	---------------------------------------------
	END_COWER = function( self, entity, bender )
		AI.ModifySmartObjectStates(entity.id,"-Cower");
	end,

	---------------------------------------------
	OnCloseContact = function( self, entity, bender )
		local target = AI.GetAttentionTargetEntity(entity.id);
		if(target and target.Behaviour and target.Behaviour.alertness and target.Behaviour.alertness>0) then
			entity:Cower();
		end
	end,
	---------------------------------------------
	OnDamage = function( self, entity, sender )
	end,
	---------------------------------------------
	OnFriendlyDamage = function( self, entity, sender )
		entity:Cower();
	end,

	---------------------------------------------
	OnEnemyDamage = function( self, entity, sender,data )
		entity:Cower();
	end,

	---------------------------------------------
	OnBulletRain = function( self, entity, bender,data )
		local entityAI = entity.AI;
		if(not entityAI.Cower) then 
			if(	_time - entityAI.bulletRainTime >3) then
				entityAI.bulletRainCount = 1;
				entityAI.bulletRainTime = _time;
				return;
			else
				entityAI.bulletRainCount = entityAI.bulletRainCount+1;
			end
		end		
		entityAI.bulletRainTime = _time;
		if(entityAI.Cower or entityAI.bulletRainCount> random(2,4)) then 
			local navType = AI.GetNavigationType(entity.id);
			if(navType == NAV_WAYPOINT_HUMAN) then 
				-- ignore bullets outside the buildings
				local pos = g_Vectors.temp;
				local dir = g_Vectors.temp_v1;
				CopyVector(pos,entity:GetPos());
				pos.z = pos.z + 1.6;
				SubVectors( dir, data.point,pos);
				
				local	hits = Physics.RayWorldIntersection(pos,dir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,entity.id,nil,g_HitTable);
				if(hits>0) then 
					return;
				end
			end
			entityAI.bulletRainCount = 0;
			entity:Cower();
		end
	end,
	
	
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		local navType = AI.GetNavigationType(entity.id);
		if(navType == NAV_WAYPOINT_HUMAN) then 
			-- ignore bullets outside the buildings
			local pos = g_Vectors.temp;
			local dir = g_Vectors.temp_v1;
			if(not AI.GetAttentionTargetPosition( entity.id, dir) ) then 
				return;
			end
			CopyVector(pos,entity:GetPos());
			pos.z = pos.z + 1.6;
			SubVectors( dir, dir,pos);
			
			local	hits = Physics.RayWorldIntersection(pos,dir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,entity.id,nil,g_HitTable);
			if(hits>0) then 
				return;
			end
		end
		entity:Cower();
	end,

	---------------------------------------------
	COWER = function( self, entity , bender)
		entity:Cower();
	end,

	---------------------------------------------
	CHECK_WAIT = function( self, entity , bender)
		
	end,
	
	---------------------------------------------
	OnEnemyMemory = function( self, entity , distance)
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
	end,
	---------------------------------------------
	OnReload = function( self, entity )
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
	end,
	---------------------------------------------

	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
	end,	
	
	---------------------------------------------
	OnGrenadeDanger = function( self, entity, sender )
		-- to do
	end,
	
	---------------------------------------------
	ACT_GOTO = function(self,entity,sender,data)
		entity:SelectPipe(0,"do_nothing");
		AIBehaviour.DEFAULT:ACT_GOTO(entity,sender,data);
	end,
	
	---------------------------------------------
	CheckPlayerOld = function(entity,timerid)
		if(entity.Behaviour == AIBehaviour.HostageRetrieve) then 
			
			if(not entity.AI.Cower) then 
				local mypos = g_Vectors.temp;
				local playerpos = g_Vectors.temp_v1;
				CopyVector(mypos,entity:GetPos());
				CopyVector(playerpos,g_localActor:GetPos());
				local x = mypos.x - playerpos.x;
				local y = mypos.y - playerpos.y;
				local z = mypos.z - playerpos.z;
				local xydist2 = x*x + y*y;
				local condition = false;
				-- checks on z value are done specifically for village map
				-- assuming that the hostage never has to go upstairs
				if(z<0.1) then 
					if(z<-2 and xydist2 > 4) then 
						condition = true;
					elseif(xydist2>36) then
						--check if the player is actually behind
						local playerdir = g_Vectors.temp_v2;
						local movedir = g_Vectors.temp_v3;
						FastDifferenceVectors(playerdir,playerpos,mypos);
						entity:GetVelocity(movedir);
						local dot2d = playerdir.x*movedir.x + playerdir.y*movedir.y;
						condition = (dot2d<=0);
					end
				end
				if(condition) then 
					if(not entity.AI.waiting) then 
						entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"hostage_wait_for_player");
						entity.AI.waiting = true;
					end
				elseif(	entity.AI.waiting) then 
					AI.Signal(SIGNALFILTER_SENDER,0,"CONTINUE",entity.id);
					entity.AI.waiting = false;
				end
			end
			entity.AI.iTimer= Script.SetTimerForFunction(1000,"AIBehaviour.HostageRetrieve.CheckPlayer",entity);
		end
	end,
	---------------------------------------------
	CheckPlayer = function(entity,timerid)
		if(entity.Behaviour == AIBehaviour.HostageRetrieve) then 
			
			if(not entity.AI.Cower) then 
				local dist = AI.GetDistanceAlongPath(entity.id,g_localActor.id,entity.AI.init);
				--System.Log("DISTANCE = "..dist);
				entity.AI.init = (dist ==0);
				local mypos = g_Vectors.temp;
				local playerpos = g_Vectors.temp_v1;
				CopyVector(mypos,entity:GetPos());
				CopyVector(playerpos,g_localActor:GetPos());
				local z = math.abs(mypos.z - playerpos.z);
				if(dist>6 and z>1 or dist>8) then 
					if(not entity.AI.waiting) then 
						entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"hostage_wait_for_player");
						entity.AI.waiting = true;
					end
				elseif(	entity.AI.waiting) then 
					AI.Signal(SIGNALFILTER_SENDER,0,"CONTINUE",entity.id);
					entity.AI.waiting = false;
				end
			end
			entity.AI.iTimer= Script.SetTimerForFunction(1000,"AIBehaviour.HostageRetrieve.CheckPlayer",entity);		
		end
	end,
}
