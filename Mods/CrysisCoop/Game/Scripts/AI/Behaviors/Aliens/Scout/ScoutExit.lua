--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description:	This behavior moves the alien straight line from it's current position to
--								position which is <entitt name>_EXIT. No path finding is used, only collisions
--								are checked.
--  
--------------------------------------------------------------------------
--  History:
--  - 11/12/2004   : Created by Kirill Bulatsev
--  - 5/4/2005     : CXP Rush Clean up by Mikko Mononen
--
--------------------------------------------------------------------------
AIBehaviour.ScoutExit = {
	Name = "ScoutExit",

	---------------------------------------------
	Constructor = function(self , entity )
		-- Drag the scout to enetity named entityname_EXIT

		local tagPoint;
		local targetType = 0;

		-- Try to 		
		tagPoint = System.GetEntityByName(entity:GetName().."_EXIT_PATROL");
		targetType = 2;

		if( not tagPoint ) then
			tagPoint = System.GetEntityByName(entity:GetName().."_EXIT_SEARCH");
			targetType = 1;
		end

		if( not tagPoint ) then
			tagPoint = System.GetEntityByName(entity:GetName().."_EXIT");
			targetType = 0;
		end

		if( not tagPoint ) then
			tagPoint = System.GetEntityByName( "ScoutGroup"..AI.GetGroupOf(entity.id).."_EXIT" );
			targetType = 0;
		end

		if( tagPoint ) then
			local anchorPos = tagPoint:GetPos();
			local anchorDir = tagPoint:GetDirectionVector();
			local alignPos = g_Vectors.temp_v1;
			local alignLookAt = g_Vectors.temp_v2;

			alignPos.x = anchorPos.x;
			alignPos.y = anchorPos.y;
			alignPos.z = anchorPos.z;

			alignLookAt.x = alignPos.x + anchorDir.x * 10;
			alignLookAt.y = alignPos.y + anchorDir.y * 10;
			alignLookAt.z = alignPos.z + anchorDir.z * 10;

			entity.actor:SetMovementTarget( alignPos, alignLookAt,{x=0,y=0,z=0},1 );

			entity.AI.targetPos = {x=0,y=0,z=0};
			CopyVector( entity.AI.targetPos, alignPos );
			entity.AI.targetType = targetType;
		else
			entity.AI.targetPos = nil;
			entity.AI.targetType = nil;
		end
		
		entity:SelectPipe(0,"sc_exit_delay");
	end,

	---------------------------------------------
	Destructor = function(self , entity )
		-- Make sure the automatic movement gets reset when leaving this behavior.
		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);
	end,
	
	---------------------------------------------
	SC_EXIT_CHECK = function( self, entity )
		if( entity.AI.targetPos ~= nil and entity.AI.targetType ~= nil ) then
			local diff = g_Vectors.temp_v1;
			SubVectors( diff, entity.AI.targetPos, entity:GetPos() );
			local dist = LengthVector( diff );
			if( dist < 4.0 ) then
				if( entity.AI.targetType == 1 ) then
					AI.Signal(SIGNALFILTER_SENDER,0,"GO_SEARCH",entity.id);
				elseif( entity.AI.targetType == 2 ) then
					AI.Signal(SIGNALFILTER_SENDER,0,"GO_PATROL",entity.id);
				end
			end
		end
	end,
}
