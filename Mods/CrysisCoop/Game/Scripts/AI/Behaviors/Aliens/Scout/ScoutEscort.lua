--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: simple behaviour for testing 3d navigation
--  
--------------------------------------------------------------------------
--  History:
--  - 2/12/2004    : Created by Kirill Bulatsev
--  - 5/4/2005     : CXP Rush Clean up by Mikko Mononen
--
--------------------------------------------------------------------------


AIBehaviour.ScoutEscort = {
	Name = "ScoutEscort",

	---------------------------------------------
	Constructor = function(self,entity )
		entity.AI.PathStep = 0;
		entity.AI.PickedUp = false;
		AI.Signal( SIGNALFILTER_SENDER, 1, "SC_NEXT_POINT",entity.id);
	end,

	---------------------------------------------
	Destructor = function(self , entity )
		-- Make sure the automatic movement gets reset when leaving this behavior.
		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);
		entity:DropGrab();
		entity:BlendAnimation(BasicAlien.BLENDING_RATIO);
		entity:ResetAnimation();
	end,
	
	--------------------------------------------
	SC_NEXT_POINT = function( self,entity, sender )	

		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);

		if( entity.AI.PathStep == 1 and entity.AI.PickedUp == false ) then
			-- We're at the first path point, do the pick up trick.

			-- Align 15 meters above the target.
			
			local vehicleName = entity:GetName().."_VEHICLE";
			local vehicle = System.GetEntityByName(vehicleName);
			if( vehicle ) then
				local vehiclePos = vehicle:GetPos();
				local vehicleDir = vehicle:GetDirectionVector();
				local vehicleUp = vehicle:GetDirectionVector(2);
				local alignPos = g_Vectors.temp_v1;
				local alignLookAt = g_Vectors.temp_v2;
				local alignUp = g_Vectors.temp_v3;

				-- Turn off the physics for the vehicle to be able to approach it.	
				vehicle:EnablePhysics(false);
	
				-- land 5 meters above the landing mark.
				alignPos.x = vehiclePos.x + vehicleDir.x * 0.8 + vehicleUp.x * 5.65;
				alignPos.y = vehiclePos.y + vehicleDir.y * 0.8 + vehicleUp.y * 5.65;
				alignPos.z = vehiclePos.z + vehicleDir.z * 0.8 + vehicleUp.z * 5.65;
	
				alignLookAt.x = alignPos.x - vehicleDir.x * 100;
				alignLookAt.y = alignPos.y - vehicleDir.y * 100;
				alignLookAt.z = alignPos.z - vehicleDir.z * 100;
	
				alignUp.x = alignPos.x + vehicleUp.x * 100;
				alignUp.y = alignPos.y + vehicleUp.y * 100;
				alignUp.z = alignPos.z + vehicleUp.z * 100;
	
				entity.actor:SetMovementTarget( alignPos, alignLookAt, alignUp, 0.35 );
				entity:DoPickupTruck();
				entity:BlendAnimation(0);
			end
			
			entity:SelectPipe(0,"sc_escort_land");
			entity.AI.PickedUp = true;
			
		else
			local name = entity:GetName();
			local tpname = name.."_P0";	
	
			local TagPoint = System.GetEntityByName(name.."_P"..entity.AI.PathStep);
			if (TagPoint) then 		
				tpname = name.."_P"..entity.AI.PathStep;
			else
				entity:SelectPipe(0,"sc_escort_done");
				do return end
			end
	
			if( entity.AI.PathStep == 0 ) then
				entity:SelectPipe(0,"sc_escort_approach",tpname);
			else
				entity:SelectPipe(0,"sc_escort_carry",tpname);
			end

			entity.AI.PathStep = entity.AI.PathStep + 1;
		end


	end,	

	--------------------------------------------
	SC_PICKUP = function( self,entity, sender )
		-- Grap the vehicle.
		local vehicleName = entity:GetName().."_VEHICLE";
		entity:GrabEntity(vehicleName)
		-- Take off.
		local vehicle = System.GetEntityByName(vehicleName);
		if( vehicle ) then
			local vehiclePos = vehicle:GetPos();
			local vehicleDir = vehicle:GetDirectionVector();
			local alignPos = g_Vectors.temp_v1;
			local alignLookAt = g_Vectors.temp_v2;

			-- land 5 meters above the landing mark.
			alignPos.x = vehiclePos.x;
			alignPos.y = vehiclePos.y;
			alignPos.z = vehiclePos.z + 20;

			alignLookAt.x = alignPos.x - vehicleDir.x * 20;
			alignLookAt.y = alignPos.y - vehicleDir.y * 20;
			alignLookAt.z = alignPos.z - vehicleDir.z * 20 - 10;

			entity.actor:SetMovementTarget( alignPos, alignLookAt, {x=0,y=0,z=0}, 0.2 );

			entity:DoHoldTruck();
		end

		entity:SelectPipe(0,"sc_escort_pickup");
	end,	

	--------------------------------------------
	SC_ESCORT_DONE = function( self,entity, sender )
		entity:BlendAnimation(BasicAlien.BLENDING_RATIO);
		entity:DropGrab();
		entity:DoDropTruck();
		AI.Signal( SIGNALFILTER_SENDER, 1, "GO_ABORT_ESCORT",entity.id);
	end,	

	------------------------------------------------------------------------	
	OnEnemyDamage = function ( self, entity, data)
		entity:BlendAnimation(BasicAlien.BLENDING_RATIO);
		entity:DropGrab();
		entity:DoDropTruck();
		AI.Signal( SIGNALFILTER_SENDER, 1, "GO_ABORT_ESCORT",entity.id);
	end,

	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance )
		entity:BlendAnimation(BasicAlien.BLENDING_RATIO);
		entity:DropGrab();
		entity:DoPlayerSeen();
		entity:SelectPipe(0,"sc_player_seen_delay_attack");

		-- Drop beacon and let the other know here's something to fight for.
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GO_ENEMY_FOUND",entity.id);
		AI.Signal( SIGNALFILTER_SENDER, 1, "GO_ABORT_ESCORT",entity.id);
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		self:OnPlayerSeen(entity, fDistance);
	end,
}
