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
--  - 11/12/2004   : Created by Kirill Bulatsev
--  - 5/4/2005     : CXP Rush Clean up by Mikko Mononen
--
--------------------------------------------------------------------------
AIBehaviour.ScoutAttack = {
	Name = "ScoutAttack",

	---------------------------------------------
	Constructor = function(self , entity )

		-- Create attack reference counters.	
		if( not self.AI_aggressorCount ) then
			self.AI_aggressorCount = 0;
		end
		if( not self.AI_meleeAggressorCount ) then
			self.AI_meleeAggressorCount = 0;
		end

		entity.AI.attackDamageAcc = 0;
		entity.AI.attackMode = -1;

		-- Store the target name
		entity.AI.targetName = AI.GetAttentionTargetOf(entity.id);
		entity.AI.lastSeenName = nil;

		self:SC_CHOOSE_ATTACK_ACTION( entity );
	end,

	---------------------------------------------
	Destructor = function(self , entity )
	
		-- Make sure the automatic movement gets reset when leaving this behavior.
		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);
		-- Make sure the moac stops when leaving the behavior.
		entity:StopEvent("all");
		entity:PushEvent("shield_up");

		entity:BlendAnimation(BasicAlien.BLENDING_RATIO);

		-- Handle leaving entity, decrease references.
		if( entity.AI.attackMode > 0 ) then
			self.AI_aggressorCount = self.AI_aggressorCount - 1;
			if( entity.AI.attackMode == 2 ) then
				self.AI_meleeAggressorCount = self.AI_meleeAggressorCount - 1;
			end
			entity.AI.attackMode = -1;
		end
		
		entity.AI.targetName = nil;
	end,

	---------------------------------------------
	Relocate = function( self, entity )

		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);


		-- Use the current target or the last seen enemy.
		if( not entity.AI.targetName ) then
			local targetName = AI.GetAttentionTargetOf(entity.id);
			if( targetName ) then
				entity.AI.targetName = targetName;
			else
				entity.AI.targetName = entity.AI.lastSeenName;
			end
		end
		
		-- Approach the target.
		if( entity.AI.targetName ) then
			local attackPos = g_Vectors.temp_v1;
			local attackDir = g_Vectors.temp_v2;
			local validPos = 0;

			local enemy = System.GetEntityByName(entity.AI.targetName);
			if( enemy ) then

				local targetPos = enemy:GetPos();
				local targetDir = enemy:GetDirectionVector();

				validPos = AI.GetAlienApproachParams( entity.id, 0, targetPos, targetDir, attackPos, attackDir );
			end

			if( validPos > 0 ) then
				-- found valid target position
				AI.SetRefPointPosition( entity.id, attackPos );
				AI.SetRefPointDirection( entity.id, attackDir );
				entity:SelectPipe(0,"sc_attack_approach", entity.AI.targetName);
			else
				AI.Signal( SIGNALFILTER_SENDER, 1, "GO_ENEMY_LOST", entity.id);
			end
		else
			AI.Signal( SIGNALFILTER_SENDER, 1, "GO_ENEMY_LOST", entity.id);
		end
	end,
	
	---------------------------------------------
	SC_CHOOSE_ATTACK_ACTION = function( self, entity )

		-- first send him OnSeenByEnemy signal
		local target = AI.GetAttentionTargetEntity(entity.id);
		if(target) then 
			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
		end

		entity.AI.attackDamageAcc = 0;

		if( not entity.AI.targetName ) then
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_ENEMY_LOST",entity.id);
			return;
		end

		-- Make sure the target is nice.
		local	enemy = System.GetEntityByName( entity.AI.targetName );
		if( not enemy ) then
			if( AI.GetTargetType(entity.id) ~= AITARGET_NONE ) then
				entity:SelectPipe(0,"sc_move_closer");
			else
				AI.LogEvent( "Could not get entity: "..entity.AI.targetName );
				AI.Signal(SIGNALFILTER_SENDER,0,"GO_ENEMY_LOST",entity.id);
			end
			return;
		end
		
		local targetType = AI.GetTypeOf( enemy.id );

		AI.LogEvent( "SC_CHOOSE_ATTACK_ACTION: "..entity.AI.targetName.." type:"..targetType );

		if( targetType == AIOBJECT_DUMMY ) then
			if( AI.GetTargetType(entity.id) ~= AITARGET_NONE ) then
				entity:SelectPipe(0,"sc_move_closer");
			else
				-- Dont attack dummies!
				AI.LogEvent( "Target is dummy: "..entity.AI.targetName );
				AI.Signal(SIGNALFILTER_SENDER,0,"GO_ENEMY_LOST",entity.id);
			end
			return;
		end

		-- Get distance to the attention target.
		local diff = g_Vectors.temp_v2;
	
		local attPos = enemy:GetPos();
		
		SubVectors( diff, attPos, entity:GetPos() );
		local targetDist = LengthVector( diff );

		local nearRange = 8;
		local meleeRange = 35;
		local fireRange = 100;

		if( entity.Properties ) then
			local d = entity.Properties.attackrange;
			-- use whole attackrange to fire.
			meleeRange = d * 0.20;
			fireRange = d * 0.65;
			AI.LogEvent( "Using properties to calc ranges: "..meleeRange..", "..fireRange );
		end
		
		-- If the enemy is in vehicle, use the vehicles speed.
		local enemySpeed = 0;
		if( enemy.vehicleId ) then
			local	vehicle = System.GetEntity( enemy.vehicleId );
			if( vehicle ) then
				enemySpeed = vehicle:GetSpeed();
			end
			AI.LogEvent( "The enemy is moving at speed: "..enemySpeed.." ("..enemy:GetSpeed()..")" );
		else
			enemySpeed = enemy:GetSpeed();
			AI.LogEvent( "The enemy is moving at speed: "..enemySpeed );
		end
		
		local	canAttack = true;
		if( self.AI_aggressorCount > 2 ) then
			canAttack = false;
		end
		
		local canMelee = true;
		if( self.AI_meleeAggressorCount > 0 ) then
			canMelee = false;
		end
		
		local decision = 0;	-- 0 = relocate, 1 = fire, 2 = melee, 3 = chase.
		if( enemySpeed > 10 and canAttack ) then
			decision = 3;		
			self.AI_aggressorCount = self.AI_aggressorCount + 1;
		elseif( targetDist < meleeRange and AI.VerifyAlienTarget( attPos ) == 1 and canMelee and canAttack ) then
			-- do melee attack.
			decision = 2;
			self.AI_aggressorCount = self.AI_aggressorCount + 1;
			self.AI_meleeAggressorCount = self.AI_meleeAggressorCount + 1;
		elseif( targetDist < fireRange and canAttack and self.AI_meleeAggressorCount == 0 ) then
			-- fire at the player.
			decision = 1;
			self.AI_aggressorCount = self.AI_aggressorCount + 1;
		else
			-- too far, relocate.
			decision = 0;
		end

		entity.AI.attackMode = decision;

		if( decision == 0 ) then
			AI.LogEvent( "Decision RELOCATE agg:"..self.AI_aggressorCount.." melee agg:"..self.AI_meleeAggressorCount );
			self:Relocate( entity );
		elseif( decision == 1 ) then
			-- Attack the enemy (attentionTarget) with gun.
			entity:SelectPipe(0,"sc_attack_fire", entity.AI.targetName);
			AI.LogEvent( "Decision FIRE" );
		elseif( decision == 2 ) then

			AI.LogEvent( "Decision MELEE" );

			-- Goto location just in front of the player, and do the melee there.		
			local enemy = System.GetEntityByName(entity.AI.targetName);
			if( enemy ) then

				local targetPos = enemy:GetPos();
				local targetDir = enemy:GetDirectionVector();

				targetPos.z = targetPos.z + 8.5;
			
				AI.SetRefPointPosition( entity.id, targetPos );
				AI.SetRefPointDirection( entity.id, {x=0,y=0,z=0} );
			
				-- Melee attack the enemy (attentionTarget).
				entity:SelectPipe(0,"sc_attack_melee", entity.AI.targetName);
			end
		elseif( decision == 3 ) then
			entity:SelectPipe(0,"sc_attack_chase", entity.AI.targetName);
			AI.LogEvent( "Decision CHASE" );
		end
		
	end,

	---------------------------------------------
	SC_MELEE = function( self, entity )
		local attackPos = g_Vectors.temp_v2;
		local diff = g_Vectors.temp_v3;
		local entPos = entity:GetPos();

		local enemy = System.GetEntityByName(entity.AI.targetName);
		if( not enemy ) then
			-- Fail the melee.
			self:SC_MELEE_DONE( entity );
			return;
		end
		
		local	enemyPos = enemy:GetPos();

		SubVectors( diff, entPos, enemyPos );
		local targetDist = LengthVector( diff );

		if( targetDist < 20 ) then
			-- Make sure we are near enough to do the melee.
			local mult = 11 / targetDist;
			attackPos.x = enemyPos.x + diff.x * mult;
			attackPos.y = enemyPos.y + diff.y * mult;
			attackPos.z = enemyPos.z + 7.8;

			enemyPos.z = enemyPos.z + 7;

			entity.actor:SetMovementTarget(attackPos,enemyPos,{x=0,y=0,z=0},1);

			entity:MeleeAttack();

			entity:SelectPipe(0,"sc_attack_melee_delay");
		else
			-- Fail the melee.
			self:SC_MELEE_DONE( entity );
		end
	end,

	---------------------------------------------
	SC_MELEE_DONE = function( self, entity )
		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);
		self:Relocate( entity );

		-- Remove references.
		self.AI_aggressorCount = self.AI_aggressorCount - 1;
		self.AI_meleeAggressorCount = self.AI_meleeAggressorCount - 1;
		entity.AI.attackMode = -1;

		-- Forget the enemy (use OnEnemySeen to acquire it again).
		entity.AI.targetName = nil;
	end,

	---------------------------------------------
	SC_FIRE = function( self, entity )
		entity:BlendAnimation(50);
		entity:DoShootWeapon();
	end,
	
	---------------------------------------------
	SC_FIRE_DONE = function( self, entity )
		self:Relocate( entity );

		entity:BlendAnimation(BasicAlien.BLENDING_RATIO);

		-- Remove references.
		self.AI_aggressorCount = self.AI_aggressorCount - 1;
		entity.AI.attackMode = -1;

		-- Forget the enemy (use OnEnemySeen to acquire it again).
		entity.AI.targetName = nil;
	end,

	---------------------------------------------
	SC_CHASE = function( self, entity )
		entity:DoShootWeaponLong();
	end,
	
	---------------------------------------------
	SC_CHASE_DONE = function( self, entity )
		self:Relocate( entity );
		-- Remove references.
		self.AI_aggressorCount = self.AI_aggressorCount - 1;
		entity.AI.attackMode = -1;
		-- Forget the enemy (use OnEnemySeen to acquire it again).
		entity.AI.targetName = nil;
	end,

	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance )
		-- first send him OnSeenByEnemy signal
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end

		-- Drop beacon and let the other know here's something to fight for.
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GO_ENEMY_FOUND",entity.id);
		
--		entity.AI.lastSeenName = entity:GetName();
		entity.AI.lastSeenName = AI.GetAttentionTargetOf(entity.id);
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
		entity.AI.lastSeenName = nil;
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data)
		-- called when the enemy is damaged
		entity.AI.attackDamageAcc = entity.AI.attackDamageAcc + data.fValue;

--		if( entity.AI.attackDamageAcc > 400 ) then
--			AI.Signal( SIGNALFILTER_SENDER, 1, "GO_RECOIL", entity.id);
--			entity:BlendAnimation(BasicAlien.BLENDING_RATIO);
--		end
	end,
}
