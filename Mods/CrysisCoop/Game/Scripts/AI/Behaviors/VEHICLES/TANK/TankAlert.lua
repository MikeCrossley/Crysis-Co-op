--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: 
--  "Alert" behaviour for the tank
--------------------------------------------------------------------------
--  History:
--  - 06/12/2005   : Created by Tetsuji
--
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
local function checkFriendInWay( entity ,vDifference )

	-- returns 0 no obstacle
	-- returns 1 there are obstacles and all obstacles are not moving
	-- returns 2 there is an obstacle which is moving

	local result = 0;
	local objects = {};

	local myPosition = {};
	local vRot = {};
	
	vDifference.x =0.0;
	vDifference.y =0.0;
	vDifference.z =0.0;

	CopyVector( myPosition, entity:GetPos() );
	
	CopyVector( vRot, entity:GetVelocity() );
	if ( LengthVector(vRot) < 0.1 ) then
		CopyVector( vRot, entity:GetDirectionVector() );
	end
	NormalizeVector( vRot );

	local i;

	local entities = System.GetPhysicalEntitiesInBox( entity:GetPos(), 30.0 );
	local targetEntity;

	if (entities) then

		-- calculate damage for each entity
		for i,targetEntity in ipairs(entities) do

			local objEntity = targetEntity;

			if ( objEntity.id == entity.id or objEntity:GetMass()< 200.0 ) then

			else

				local objPosition = {}
				CopyVector( objPosition, objEntity:GetPos() );

				if ( math.abs(myPosition.z - objPosition.z ) < 10.0 ) then -- if the object is not flying.

					local objDestDirN ={};
					local objDestDir ={};
					SubVectors( objDestDir, objPosition, myPosition );
					CopyVector( objDestDirN, objDestDir );
					NormalizeVector( objDestDirN );			
	
					local objDestance = LengthVector( objDestDir );
					if (objDestance < 1.0 ) then
						objDestance = 1.0;
					end
					objDestance = 30.0 - objDestance;
					if ( objDestance < 0.0 ) then
						objDestance = 0.0;
					end
					objDestance = objDestance * -1.0;

					FastScaleVector( objDestDir, objDestDirN, objDestance );
					FastSumVectors( vDifference, vDifference, objDestDir );

					local t = dotproduct3d( objDestDirN, vRot );
					--AI.LogComment("tankNoFriendInWay "..entity:GetName().." innter product with "..objEntity:GetName().." is "..t );

					if ( t > 0 ) then

						local objDistance = DistanceVectors( objPosition, myPosition );
						if ( objDistance < 15.0 ) then 
							--AI.LogComment("tankNoFriendInWay "..entity:GetName().." detected friend 3 "..objEntity:GetName() );
							if ( objEntity:GetSpeed() < 0.5 ) then
								if ( result == 0 ) then
									result = 1;
								end
							else
								result =  2;
							end
						end

						local d = DistanceLineAndPoint( objPosition, vRot, myPosition );
						if ( objDistance < 30.0 and d < 15.0 ) then
							--AI.LogComment("tankNoFriendInWay "..entity:GetName().." detected friend 2 "..objEntity:GetName() );
							if ( objEntity:GetSpeed() < 0.5 ) then
								if ( result == 0 ) then
									result = 1;
								end
							else
								result =  2;
							end
						end

					end

				end
			end
		end

	else
		--AI.LogComment("tankNoFriendInWay "..entity:GetName().." can't get entities");
	end	

	if ( result == true ) then
		--AI.LogComment("tankNoFriendInWay "..entity:GetName().." has no friend in way");
	else
		--AI.LogComment("tankNoFriendInWay "..entity:GetName().." has a friend in way");
	end

	return	result;

end

AIBehaviour.TankAlert = {
	Name = "TankAlert",
	alertness = 1,

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- called when the behaviour is selected
		-- the extra data is from the signal that caused the behavior transition

		entity.AI.myDistance = 0.0;
		entity.AI.blockSignal = false;

		entity.AI.vRefPointRsv ={};
		CopyVector( entity.AI.vRefPointRsv, entity:GetPos() );
		entity.AI.vRefPointRsv = AI.GetRefPointPosition(entity.id);

		entity.AI.bStopCount = 0;

		-- if there is no anchor just stop and wait.

		AI.CreateGoalPipe("tank_alert_standby");
		AI.PushGoal("tank_alert_standby","timeout",1,2);
		AI.PushGoal("tank_alert_standby","signal",0,1,"TANK_ALERT_NEXT",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"tank_alert_standby");

	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )

		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition

		entity.AI.blockSignal = false;

	end,

	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
		-- when spawned tank - has to keep moving to reinf point, once there are no enemies
		if(entity.AI.spawnerListenerId) then
			local spawnerEnt = System.GetEntity(entity.AI.spawnerListenerId);
			if(spawnerEnt) then
				spawnerEnt:FindSpawnReinfPoint();
				entity.AI.reinfPoint = g_SignalData.ObjectName;
				entity:SelectPipe(0,"goto_point",entity.AI.reinfPoint);
			end
		end		
	end,
	
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the AI sees a living enemy
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the AI can no longer see its enemy, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the AI hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the AI hears a threatening sound
	end,

	---------------------------------------------------------------------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender )	

		-- called when there are bullet impacts nearby

		if ( entity.AI.blockSignal==true ) then
			return;
		end

		local senderEntity =System.GetEntity( sender.id );
		if ( senderEntity ) then
			--AI.LogComment(entity:GetName().." TankAlert.OnBulletRain() from "..senderEntity:GetName());
			CopyVector( g_SignalData.point, senderEntity:GetPos() );
			AI.Signal(SIGNALFILTER_ANYONEINCOMM,1,"TANK_ALERT_SEARCH", entity.id, g_SignalData);
		else
			-- just in case when we can't get an entity
		end

	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		-- called when AI is damaged by an enemy AI
		-- data.id = damaging enemy's entity id
		-- local hitter = System.GetEntity(data.id);
		-- local hitterName = hitter:GetName()

		if ( entity.AI.blockSignal==true ) then
			return;
		end

		local senderEntity =System.GetEntity( data.id );
		if ( senderEntity ) then
			--AI.LogComment(entity:GetName().." TankAlert.OnBulletRain() from "..senderEntity:GetName());
			CopyVector( g_SignalData.point, senderEntity:GetPos() );
			AI.Signal(SIGNALFILTER_ANYONEINCOMM,1,"TANK_ALERT_SEARCH", entity.id, g_SignalData);
		else
			-- just in case when we can't get an entity
		end
	
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )
	end,

	---------------------------------------------------------------------------------------------------------------------------------------
	TANK_ALERT_NEXT = function( self, entity )

		-- continue the patroll when a damage or a bullet rain is only once.
		
		AI.SetRefPointPosition( entity.id , entity.AI.vRefPointRsv );
		AI.CreateGoalPipe("tank_alert_next");
		AI.PushGoal("tank_alert_next","clear",0,1);
		AI.PushGoal("tank_alert_next","continuous",0,1);
		AI.PushGoal("tank_alert_next","locate",1,"refpoint");
		AI.PushGoal("tank_alert_next","approach",1,4.0,AILASTOPRES_USE);
		AI.PushGoal("tank_alert_next","signal",0,1,"TANK_ALERT_CONTINUE",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"tank_alert_next");

	end,
	---------------------------------------------------------------------------------------------------------------------------------------
	TANK_ALERT_CONTINUE = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_TANK_ATTACK", entity.id);		
		else
		end
		
		local vUp = { x=0.0, y=0.0, z=1.0 };
		local vDest = {};
		local angle = random ( -60, 60 ) * 3.1416 *2 / 360.0;

		RotateVectorAroundR( vDest, entity:GetDirectionVector( 1 ), vUp, angle )

		FastScaleVector( vDest, vDest, 100.0 );
		FastSumVectors( vDest, vDest, entity:GetPos() );
		AI.SetRefPointPosition( entity.id , vDest );

		AI.CreateGoalPipe("tank_alert_continue");
		AI.PushGoal("tank_alert_continue","ignoreall",0,1);
		AI.PushGoal("tank_alert_continue","locate",0,"refpoint");
		AI.PushGoal("tank_alert_continue","acqtarget",0,"");
--		AI.PushGoal("tank_alert_continue","firecmd",0,1);
		AI.PushGoal("tank_alert_continue","timeout",1,4.0);
		AI.PushGoal("tank_alert_continue","firecmd",0,0);
		AI.PushGoal("tank_alert_continue","ignoreall",0,0);
		AI.PushGoal("tank_alert_continue","timeout",1,1.0);

		AI.PushGoal("tank_alert_continue","timeout",1,4.0);
		AI.PushGoal("tank_alert_continue","approach",0,3.0,AILASTOPRES_USE);
		AI.PushGoal("tank_alert_continue","signal",0,1,"TANK_ALERT_SEARCH_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("tank_alert_continue","timeout",1,0.5);
		AI.PushGoal("tank_alert_continue","branch",1,-2);
		AI.PushGoal("tank_alert_continue","timeout",1,1.0);
		AI.PushGoal("tank_alert_continue","signal",0,1,"TANK_ALERT_CONTINUE",SIGNALFILTER_SENDER);

		entity:SelectPipe(0,"tank_alert_continue");

	end,

	---------------------------------------------
	TANK_ALERT_SEARCH = function( self, entity, sender, data )

		--approach to the place from where the tank is shooted. 

		CopyVector( entity.AI.vRefPointRsv, data.point );
		self:TANK_ALERT_SEARCH_NEXT( entity );
		
	end,

	---------------------------------------------
	TANK_ALERT_SEARCH_NEXT = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_TANK_ATTACK", entity.id);		
		end
		
		local vDifference = {};
		checkFriendInWay( entity, vDifference );
		
		local destination = {};
		FastSumVectors( destination, entity.AI.vRefPointRsv, vDifference );
		
		entity.AI.myDistance = DistanceVectors( entity.AI.vRefPointRsv , entity:GetPos() );

		if ( entity.AI.myDistance < 20.0 ) then
			entity.AI.myDistance = entity.AI.myDistance * -0.8;
		end

		if ( entity.AI.myDistance >20.0 ) then
			entity.AI.myDistance = 20.0;
		end

		entity:SelectPipe(0,"do_nothing");

		AI.SetRefPointPosition( entity.id , destination );
		AI.CreateGoalPipe("tank_alert_search");
		AI.PushGoal("tank_alert_search","signal",0,1,"TANK_ALERT_SEARCH_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("tank_alert_search","locate",0,"refpoint");
		AI.PushGoal("tank_alert_search","approach",0,entity.AI.myDistance,AILASTOPRES_USE);
		AI.PushGoal("tank_alert_search","signal",0,1,"TANK_ALERT_SEARCH_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("tank_alert_search","timeout",1,0.5);
		AI.PushGoal("tank_alert_search","branch",1,-2);
		AI.PushGoal("tank_alert_search","signal",0,1,"TANK_ALERT_SEARCH_NEXT",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"tank_alert_search");
	
	end,

	TANK_ALERT_SEARCH_CHECK = function( self, entity )

		local vDifference = {};
		local destination = {};
		local obstacles = checkFriendInWay( entity, vDifference );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_TANK_ATTACK", entity.id);		
		else
		end

		if ( obstacles == 0 ) then

		elseif (obstacles == 1 ) then

			NormalizeVector( vDifference );
			FastScaleVector( vDifference, vDifference, 25.0 );
			local destination = {};
			FastSumVectors( destination, entity:GetPos(), vDifference );
			entity.AI.bBlockSignal = true;
			AI.SetRefPointPosition( entity.id, destination );
			AI.CreateGoalPipe("tank_alert_avoid_deadlock");
			AI.PushGoal("tank_alert_avoid_deadlock","locate",0,"refpoint");
			AI.PushGoal("tank_alert_avoid_deadlock","approach",1,3.0,AILASTOPRES_USE);
			AI.PushGoal("tank_alert_avoid_deadlock","signal",0,1,"TANK_ALERT_SEARCH_NEXT",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"tank_alert_avoid_deadlock");

		else		

			entity.AI.bStopCount = 0;
			AI.CreateGoalPipe("tank_alert_emergency_stop");
			AI.PushGoal("tank_alert_emergency_stop","firecmd",0,0);
			AI.PushGoal("tank_alert_emergency_stop","timeout",1,2);
			AI.PushGoal("tank_alert_emergency_stop","signal",0,1,"TANK_ALERT_SEARCH_CHECK2",0);
			entity:SelectPipe(0,"tank_alert_emergency_stop");

		end

	end,

	TANK_ALERT_SEARCH_CHECK2 = function( self, entity )

		local vDifference = {};
		local destination = {};

		if ( checkFriendInWay( entity, vDifference ) == 0 ) then
			self:TANK_ALERT_SEARCH_NEXT( entity );
		else		
			entity.AI.bStopCount = entity.AI.bStopCount +1;
			if ( entity.AI.bStopCount == 3 ) then
				NormalizeVector( vDifference );
				FastScaleVector( vDifference, vDifference, 25.0 );
				local destination = {};
				FastSumVectors( destination, entity:GetPos(), vDifference );
				entity.AI.bBlockSignal = true;
				AI.SetRefPointPosition( entity.id, destination );
				AI.CreateGoalPipe("tank_alert_avoid_deadlock");
				AI.PushGoal("tank_alert_avoid_deadlock","locate",0,"refpoint");
				AI.PushGoal("tank_alert_avoid_deadlock","approach",1,3.0,AILASTOPRES_USE);
				AI.PushGoal("tank_alert_avoid_deadlock","signal",0,1,"TANK_ALERT_SEARCH_NEXT",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"tank_alert_avoid_deadlock");
			end
		end

	end,

	--------------------------------------------------------------------------
	TANK_PROTECT_ME = function( self, entity, sender )

		if ( AI.GetSpeciesOf(entity.id) == AI.GetSpeciesOf(sender.id) ) then

			entity.AI.protect = sender.id;

			if ( entity.id == sender.id ) then
				if (entity.AI.mindType == 3 ) then
					entity.AI.mindType = 2;
				end
			else
				if (entity.AI.mindType == 2 ) then
					entity.AI.mindType = 3;
				end
			end

		end

	end,


}
