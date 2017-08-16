--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Implementation of a simple outdoor indoor alien behavior
--  
--------------------------------------------------------------------------
--  History:
--  - 09/05/2005   : Created by Mikko Mononen
--	Sept 2005			: Modified by Luciano Morpurgo
--------------------------------------------------------------------------
AIBehaviour.HunterAttack = {
	Name = "HunterAttack",
	alertness = 2,

	---------------------------------------------
	Constructor = function( self , entity )
	--	if ( entity.AI.PathStep == nil ) then 
	--		entity.AI.PathStep = 0;
	--	end
	--	self:Move( entity );
		entity:MakeAlerted( false );
		entity:HolsterItem( false );
		entity:SelectPipe( 0, "do_nothing" );
	end,
	---------------------------------------------
	Destructor = function( self , entity )
		entity:InsertSubpipe( 0, "stop_fire" );
	end,

	---------------------------------------------

	OnPlayerSeen = function(self,entity,distance)
		
--		if(entity.grabParams.entityId and entity.grabParams.entityId~= NULL_ENTITY) then 
--			System.Log("HUNTER THROWING OBJECT!");
--			local pos = g_Vectors.temp;
--			AI.GetAttentionTargetPosition(entity.id, pos);
--				pos.z = pos.z - 1.65;
--			entity:TakeOffDropObjectAtPoint(pos);
--		end
		
	end,
	---------------------------------------------

	OnEnemyMemory = function(self,entity,distance)
	end,
	---------------------------------------------

	OnNoTarget = function(self,entity,sender)
	end,
	---------------------------------------------
	HT_SHOOT = function( self, entity )

		AI.LogEvent( "Hunter shoot" );

		-- Make sure the target is nice.
		local	enemy = AI.GetAttentionTargetEntity(entity.id);
		if( not enemy ) then
			AI.LogEvent( "  - could not find enemy entity" );
			return;
		end
		
--	local targetType = AI.GetTypeOf( enemy.id );
--		if( targetType == AIOBJECT_DUMMY ) then
--			AI.LogEvent( "  - enemy is dummy" );
--			return;
--		end
		
		AI.LogEvent( "  - Hunter SHOOT!" );
		entity:DoShootWeapon();
	end,

	---------------------------------------------
	HT_END_LOOKAROUND = function( self, entity )
		entity:SelectPipe(0,"do_nothing");
	end,	
	---------------------------------------------
	DROP_OBJECT = function(self,entity,sender)
		local targetType = AI.GetTargetType(entity.id);
		local targetPos = g_Vectors.temp;
		AI.GetAttentionTargetPosition(entity.id,targetPos);
		if(targetType ~= AITARGET_NONE) then 
			if(targetType == AITARGET_ENEMY) then 
				targetPos.z = targetPos.z - 1.65;
			end
			entity:DropObjectAtPoint(targetPos);
		end
		entity:SelectPipe(0,"do_nothing");
		AI.SetSmartObjectState(entity.id,"Attack");
		self:Move(entity);
	end,

	--------------------------------------------
	
	Move = function( self,entity)	
--		local targetpos  = g_Vectors.temp;
--		AI.GetAttentionTargetPosition(entity.id,targetpos);
--		local anchorname;
--		if(IsNullVector(targetpos)) then
--			anchorname = AI.GetAnchor(entity.id,100,AIAnchorTable.COMBAT_SHOOTSPOTSTAND,AIANCHOR_RANDOM_IN_RANGE);
--		else
--			anchorname = AI.FindObjectOfType(targetpos,100,AIAnchorTable.COMBAT_SHOOTSPOTSTAND);
--		end
--		if(anchorname) then
--			local anchor = System.GetEntityByName(anchorname);
--			if(anchor) then
--				CopyVector(targetpos,anchor:GetPos());
--				AI.SetRefPointPosition(entity.id,targetpos);
--				entity:SelectPipe(0,"approach_refpoint");
--			end
--		end
	
	end,
	--------------------------------------------
	
	MoveOld = function( self,entity)	
		-- TO DO: hunter is not supposed to fly

	--	local targettype = AI.GetTargetType(entity.id);
--		if(AI.Hostile(entity.id,AI.GetAttentionTargetOf(entity.id))) then
--			local targetpos =g_Vectors.temp;
--			AI.GetAttentionTargetPosition(entity.id,targetpos);
--			targetpos.z = targetpos.z + 30;
--			AI.SetRefPointPosition(entity.id,targetpos);
--			entity:SelectPipe(0,"approach_refpoint");
--			entity:InsertSubpipe(0,"do_it_running");
--		else
			local name = entity:GetName();
			local tpname = name.."_P0";	
			local TagPoint = System.GetEntityByName(name.."_P"..entity.AI.PathStep);
			if (TagPoint) then 		
				tpname = name.."_P"..entity.AI.PathStep;
			else
				entity.AI.PathStep = 0;
				tpname = name.."_P0";
				local TagPoint = System.GetEntityByName(tpname);
				if (TagPoint == nil and not AI.Hostile(entity.id,AI.GetAttentionTargetOf(entity.id))) then 		
					AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_IDLE",entity.id);
					return;
				end
			end
			entity:SelectPipe(0,"ht_patrol",tpname);
			entity.AI.PathStep = entity.AI.PathStep + 1;
--		end
	end,	

--		---------------------------------------------
--	REFPOINT_REACHED = function(self,entity,sender)
--		if(AI.Hostile(entity.id,AI.GetAttentionTargetOf(entity.id))) then
--			entity:SelectPipe(0,"do_nothing");
--		else
--			self:Move(entity);
--		end
--	end,
	
	---------------------------------------------
	HT_NEXT_POINT = function( self,entity, sender )	
		--self:Move(entity);
	end,

		
--	---------------------------------------------
--	Constructor = function(self , entity )
--
--		AI.LogEvent( "AIBehaviour.HunterDefend" );
--
--		entity.AI.defendDamageAcc = 0;
--		entity.AI.defendMode = -1;
--
--		-- Store the target name
--		entity.AI.targetName = AI.GetAttentionTargetOf(entity.id);
--		entity.AI.lastSeenName = nil;
--
--		self:HT_CHOOSE_DEFEND_ACTION( entity );
--	end,
--
--	---------------------------------------------
--	Destructor = function(self , entity )
--	
--		-- Make sure the automatic movement gets reset when leaving this behavior.
--		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);
--
--		entity:BlendAnimation(BasicAlien.BLENDING_RATIO);
--
--		entity.AI.targetName = nil;
--	end,
--
--	---------------------------------------------
--	Relocate = function( self, entity )
--
--		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);
--
--		-- Use the current target or the last seen enemy.
--		if( not entity.AI.targetName ) then
--			local targetName = AI.GetAttentionTargetOf(entity.id);
--			if( targetName ) then
--				entity.AI.targetName = targetName;
--			else
--				entity.AI.targetName = entity.AI.lastSeenName;
--			end
--		end
--		
--		-- Approach the target.
--		if( entity.AI.targetName ) then
--			local defendPos = g_Vectors.temp_v1;
--			local defendDir = g_Vectors.temp_v2;
--			local validPos = 0;
--
--			local enemy = System.GetEntityByName(entity.AI.targetName);
--			if( enemy ) then
--				local targetPos = enemy:GetPos();
--				local targetDir = enemy:GetDirectionVector();
--				validPos = AI.GetHunterApproachParams( entity.id, 0, targetPos, targetDir, defendPos, defendDir );
--			end
--
--			if( validPos > 0 ) then
--				-- found valid target position
--				AI.SetRefPointPosition( entity.id, defendPos );
--				AI.SetRefPointDirection( entity.id, defendDir );
--				entity:SelectPipe(0,"ht_defend_approach", entity.AI.targetName);
--			else
--				AI.LogEvent( "No target." );
--				AI.Signal( SIGNALFILTER_SENDER, 1, "GO_ENEMY_LOST", entity.id);
--			end
--		else
--			AI.LogEvent( "No enemy." );
--			AI.Signal( SIGNALFILTER_SENDER, 1, "GO_ENEMY_LOST", entity.id);
--		end
--	end,
--	
--	---------------------------------------------
--	Assault = function( self, entity )
--
--		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);
--
--		-- Use the current target or the last seen enemy.
--		if( not entity.AI.targetName ) then
--			local targetName = AI.GetAttentionTargetOf(entity.id);
--			if( targetName ) then
--				entity.AI.targetName = targetName;
--			else
--				entity.AI.targetName = entity.AI.lastSeenName;
--			end
--		end
--		
--		-- Approach the target.
--		if( entity.AI.targetName ) then
--			local defendPos = g_Vectors.temp_v1;
--			local defendDir = g_Vectors.temp_v2;
--			local validPos = 0;
--
--			local enemy = System.GetEntityByName(entity.AI.targetName);
--			if( enemy ) then
--				local targetPos = enemy:GetPos();
--				local targetDir = enemy:GetDirectionVector();
--				validPos = AI.GetHunterApproachParams( entity.id, 1, targetPos, targetDir, defendPos, defendDir );
--			end
--
--			if( validPos > 0 ) then
--				-- found valid target position
--				AI.SetRefPointPosition( entity.id, defendPos );
--				AI.SetRefPointDirection( entity.id, defendDir );
--				entity:SelectPipe(0,"ht_defend_assault", entity.AI.targetName);
--			else
--				AI.LogEvent( "No target." );
--				self:Relocate( entity );
--			end
--		else
--			AI.LogEvent( "No enemy." );
--			self:Relocate( entity );
--		end
--	end,
--	
--	---------------------------------------------
--	HT_CHOOSE_DEFEND_ACTION = function( self, entity )
--
--		-- first send him OnSeenByEnemy signal
--		AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", g_localActor.id);
--
--		entity.AI.defendDamageAcc = 0;
--
--		if( not entity.AI.targetName ) then
--			AI.Signal(SIGNALFILTER_SENDER,0,"GO_ENEMY_LOST",entity.id);
--			return;
--		end
--
--		-- Make sure the target is nice.
--		local	ent = System.GetEntityByName( entity.AI.targetName );
--		if( not ent ) then
--			AI.LogEvent( "Could not get entity: "..entity.AI.targetName );
--			AI.Signal(SIGNALFILTER_SENDER,0,"GO_ENEMY_LOST",entity.id);
--			return;
--		end
--		
--		local targetType = AI.GetTypeOf( ent.id );
--
--		AI.LogEvent( "HT_CHOOSE_DEFEND_ACTION: "..entity.AI.targetName.." type:"..targetType );
--
--		if( targetType == AIOBJECT_DUMMY ) then
--			-- Dont Defend dummies!
--			AI.LogEvent( "Target is dummy: "..entity.AI.targetName );
--			AI.Signal(SIGNALFILTER_SENDER,0,"GO_ENEMY_LOST",entity.id);
--			return;
--		end
--
--		-- Alerted!
--		if (not entity.eventAlertInvoked) then
--			entity.eventAlertInvoked = true;
--			entity:Event_Alert( nil );
--		end
--
--		-- Get distance to the attention target.
--		local diff = g_Vectors.temp_v2;
--	
--		local enemy = System.GetEntityByName(entity.AI.targetName);
--		if( not enemy ) then
--			AI.LogEvent( "Target is dummy: "..entity.AI.targetName );
--			AI.Signal(SIGNALFILTER_SENDER,0,"GO_ENEMY_LOST",entity.id);
--			return;
--		end
--		local attPos = enemy:GetPos();
--		
--		SubVectors( diff, attPos, entity:GetPos() );
--		local targetDist = LengthVector( diff );
--
--		local decision = 0;	-- 0 = relocate, 1 = fire, 2 = melee.
--		if( targetDist < 10 ) then
--			-- relocate.
--			decision = 0;
--		elseif( targetDist < 200 ) then
--			-- fire at the player.
--			decision = 1;
--		else
--			-- too far, relocate.
--			decision = 0;
--		end
--
--		entity.AI.defendMode = decision;
--
--		if( decision == 0 ) then
--			AI.LogEvent( "Decision RELOCATE" );
--			self:Relocate( entity );
--		elseif( decision == 1 ) then
--			-- Defend the enemy (attentionTarget) with gun.
--			entity:SelectPipe(0,"ht_defend_fire", entity.AI.targetName);
--			AI.LogEvent( "Decision FIRE" );
--		end
--		
--	end,
--
--	---------------------------------------------
--	HT_FIRE = function( self, entity )
--		entity:BlendAnimation(50);
--		entity:DoShootWeapon();
--	end,
--	
--	---------------------------------------------
--	HT_FIRE_DONE = function( self, entity )
--
--		entity:BlendAnimation(BasicAlien.BLENDING_RATIO);
--
--		local enemy = System.GetEntityByName(entity.AI.targetName);
--		
--		if( enemy ) then
--			-- Get distance to the attention target.
--			local diff = g_Vectors.temp_v2;
--			local attPos = enemy:GetPos();
--		
--			SubVectors( diff, attPos, entity:GetPos() );
--			local targetDist = LengthVector( diff );
--
--			if( targetDist < 100 ) then
--				AI.LogEvent( "ASSAULT "..targetDist );
--				self:Assault( entity );
--			else
--				AI.LogEvent( "RELOCATE (far away) "..targetDist );
--				self:Relocate( entity );
--			end
--		else
--			AI.LogEvent( "RELOCATE (no enemy)" );
--			self:Relocate( entity );
--		end
--
--		-- Forget the enemy (use OnEnemySeen to acquire it again).
----		entity.AI.targetName = nil;
--	end,
--
--	---------------------------------------------
--	HT_ASSAULT_DONE = function( self, entity )
--		self:Relocate( entity );
--	end,
--
--	---------------------------------------------		
--	OnPlayerSeen = function( self, entity, fDistance )
--		-- first send him OnSeenByEnemy signal
--		AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", g_localActor.id);
--
--		-- Drop beacon and let the other know here's something to fight for.
--		entity:TriggerEvent(AIEVENT_DROPBEACON);
--		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GO_ENEMY_FOUND",entity.id);
--		
--		entity.AI.lastSeenName = AI.GetAttentionTargetOf(entity.id);
--	end,
--
--	---------------------------------------------
--	OnEnemyMemory = function( self, entity )
--		-- called when the enemy can no longer see its foe, but remembers where it saw it last
--		entity.AI.lastSeenName = nil;
--	end,
--
--	---------------------------------------------
--	OnEnemyDamage = function ( self, entity, sender, data)
--		-- called when the enemy is damaged
--		entity.AI.defendDamageAcc = entity.AI.defendDamageAcc + data.fValue;
--
----		if( entity.AI.defendDamageAcc > 500 ) then
----			AI.Signal( SIGNALFILTER_SENDER, 1, "GO_RECOIL", entity.id);
----			entity:BlendAnimation(BasicAlien.BLENDING_RATIO);
----		end
--	end,
--
--	--------------------------------------------
--	--------------------------------------------
--	HT_TAKEOFF_DONE = function( self,entity, sender )
--		
--	end,	
--
--	--------------------------------------------
--	HT_LAND = function( self,entity, sender )	
--		entity:DoLand();
--		local entPos = entity:GetPos();
--		entPos.z = entPos.z - 22;
--		entity.actor:SetMovementTarget(entPos,{x=0,y=0,z=0},{x=0,y=0,z=0},2);
--	end,	
--
--	--------------------------------------------
--	HT_LAND_DONE = function( self,entity, sender )	
--		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);
--	end,	
}
