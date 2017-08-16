--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description:	The search behavior is used to investigate interesting objects
--								on the map the objects are marked with anchor ALIEN_SCOUT_INTERESTING_SPOT.
--  
--------------------------------------------------------------------------
--  History:
--  - 11/12/2004   : Created by Kirill Bulatsev
--  - 5/4/2005     : CXP Rush Clean up by Mikko Mononen
--
--------------------------------------------------------------------------
AIBehaviour.ScoutSearch = {
	Name = "ScoutSearch",

	---------------------------------------------
	Constructor = function(self , entity )

		entity.AI.sniffCounter = 0;
		entity.AI.searchHoverCount = 0;
		entity.AI.searchLocation = { x=0, y=0, z=0 };
		entity.AI.searchLocationDir = { x=0, y=0, z=0 };
		entity.AI.searchPlayerSpotted = 0;
		entity.AI.AnchorName = nil;

		AI.Signal(SIGNALFILTER_SENDER,0,"SC_FIND_INTERESTING_SPOT",entity.id);
	end,

	---------------------------------------------
	Destructor = function(self , entity )
		-- Make sure the automatic movement gets reset when leaving this behavior.
		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);
		entity:BlendAnimation(BasicAlien.BLENDING_RATIO);
		entity:ResetAnimation();
	end,

	---------------------------------------------
	SC_FIND_INTERESTING_SPOT = function( self, entity )

		entity.actor:SetMovementTarget( {x=0,y=0,z=0}, {x=0,y=0,z=0},{x=0,y=0,z=0},1 );

		if( entity.AI.searchHoverCount == 0 ) then
			--
			-- Phase 0: Goto to the anchor.
			--
			entity.AI.searchHoverCount = entity.AI.searchHoverCount + 1;
			local anchorName = AI.GetAnchor(entity.id,AIAnchorTable.ALIEN_SCOUT_INTERESTING_SPOT,1000,AIANCHOR_NEAREST);

			if( anchorName ) then
				local anchor = System.GetEntityByName( anchorName );
				if( anchor ) then
					-- If found interesting anchor, goto to the anchor.				
					CopyVector( entity.AI.searchLocation, anchor:GetPos() );
					CopyVector( entity.AI.searchLocationDir, anchor:GetDirectionVector() );

					entity.AI.searchLocation.z = entity.AI.searchLocation.z + 15;

					AI.SetRefPointPosition( entity.id, entity.AI.searchLocation );
					AI.SetRefPointDirection( entity.id, entity.AI.searchLocationDir );

					entity.AI.AnchorName = anchorName;
					entity:SelectPipe(0,"sc_search");
				else
					-- Could not access anchor, stay in place, and look like searching something.
					entity.AI.AnchorName = nil;
					entity.AI.searchHoverCount = 0;
					if( AI.GetTargetType(entity.id) == AITARGET_ENEMY ) then
						AI.Signal(SIGNALFILTER_SENDER,0,"GO_ATTACK",entity.id);
					else
						entity:DoInvestigate();
						entity:SelectPipe(0,"sc_search_delay");
					end
				end
			else
				-- Could not find anchor, stay in place, and look like searching something.
				CopyVector( entity.AI.searchLocation, entity:GetPos() );
				entity.AI.AnchorName = nil;
				entity.AI.searchHoverCount = 0;
				if( AI.GetAttentionTargetOf(entity.id) ) then
					AI.Signal(SIGNALFILTER_SENDER,0,"GO_ATTACK",entity.id);
				else
					entity:DoInvestigate();
					entity:SelectPipe(0,"sc_search_delay");
				end
			end
			
		elseif( entity.AI.searchHoverCount == 1 ) then
			--
			-- Phase 1: "Scan" the object.
			--

			entity.AI.searchHoverCount = entity.AI.searchHoverCount + 1;

			-- Short pause, look around.
			entity:DoInvestigate();
			entity:SelectPipe(0,"sc_search_delay");

			local entPos = entity:GetPos();
			local anchorDir = entity.AI.searchLocationDir;
			local alignPos = g_Vectors.temp_v1;
			local alignLookAt = g_Vectors.temp_v2;

			-- land 5 meters above the landing mark.
			alignLookAt.x = entPos.x + anchorDir.x * 10;
			alignLookAt.y = entPos.y + anchorDir.y * 10;
			alignLookAt.z = entPos.z + anchorDir.z * 10 - 5;

			entity.actor:SetMovementTarget( {x=0,y=0,z=0}, alignLookAt,{x=0,y=0,z=0},1);

		elseif( entity.AI.searchHoverCount == 2 ) then
			--
			-- Phase 2: Approach the target again.
			--

			entity.AI.searchHoverCount = entity.AI.searchHoverCount + 1;

			entity.AI.searchLocation.x = entity.AI.searchLocation.x - entity.AI.searchLocationDir.x * 2;
			entity.AI.searchLocation.y = entity.AI.searchLocation.y - entity.AI.searchLocationDir.y * 2;
			entity.AI.searchLocation.z = entity.AI.searchLocation.z - entity.AI.searchLocationDir.z * 2 + 8;

			-- found valid target position
			AI.SetRefPointPosition( entity.id, entity.AI.searchLocation );
			AI.SetRefPointDirection( entity.id, entity.AI.searchLocationDir );

			entity:SelectPipe(0,"sc_search");
		else
			--
			-- Phase 3: Land to investigate.
			--
			entity:SelectPipe(0,"sc_search_land");
			entity.AI.searchHoverCount = 0;
		end

		entity.AI.searchPlayerSpotted = 0;
	end,

	---------------------------------------------
	SC_LAND_ADJUST = function( self, entity )
		-- Align for landing.
		local tagPoint = System.GetEntityByName(entity.AI.AnchorName);
		if( tagPoint ) then
			local anchorPos = tagPoint:GetPos();
			local anchorDir = tagPoint:GetDirectionVector();
			local alignPos = g_Vectors.temp_v1;
			local alignLookAt = g_Vectors.temp_v2;

			-- land 5 meters above the landing mark.
			alignPos.x = anchorPos.x;
			alignPos.y = anchorPos.y;
			alignPos.z = anchorPos.z + 12;

			alignLookAt.x = alignPos.x + anchorDir.x * 10;
			alignLookAt.y = alignPos.y + anchorDir.y * 10;
			alignLookAt.z = alignPos.z + anchorDir.z * 10;

			entity.actor:SetMovementTarget( alignPos, alignLookAt,{x=0,y=0,z=0},0.7 );

			entity:BlendAnimation(10);
		end
	end,

	---------------------------------------------
	SC_LAND_LANDING = function( self, entity )
		-- Align for landing.
		local tagPoint = System.GetEntityByName(entity.AI.AnchorName);
		if( tagPoint ) then
			local anchorPos = tagPoint:GetPos();
			local anchorDir = tagPoint:GetDirectionVector();
			local alignPos = g_Vectors.temp_v1;
			local alignLookAt = g_Vectors.temp_v2;

			-- land 5 meters above the landing mark.
			alignPos.x = anchorPos.x;
			alignPos.y = anchorPos.y;
			alignPos.z = anchorPos.z + 5.1;

			alignLookAt.x = alignPos.x + anchorDir.x * 100;
			alignLookAt.y = alignPos.y + anchorDir.y * 100;
			alignLookAt.z = alignPos.z + anchorDir.z * 100;

			entity.actor:SetMovementTarget( alignPos, alignLookAt,{x=0,y=0,z=0},0.4 );
		end

		-- Trigger landing animation.
		entity:StartAnimation(0, "landing_01", 3, 0.3, 1.0, false,true);
		entity:BlendAnimation(50);
	end,

	---------------------------------------------
	SC_LAND_INSPECT = function( self, entity )
		-- Trigger inspect animation.
		entity:StartAnimation(0, "looking_tank", 3, 0.3, 1.0, true,true);
		entity:BlendAnimation(50);
	end,

	---------------------------------------------
	SC_LAND_TAKE_OFF = function( self, entity )
		-- Trigger takeoff animation.
		entity:StartAnimation(0, "taking_off_01", 3, 0.3, 1.0, false,true);
		entity:BlendAnimation(BasicAlien.BLENDING_RATIO);
		entity:SelectPipe(0,"sc_search_takeoff");
	end,
	
	---------------------------------------------
	SC_LAND_TAKE_OFF_FINAL = function( self, entity )
		-- Take off the ground
		local tagPoint = System.GetEntityByName(entity.AI.AnchorName);
		if( tagPoint ) then
			local anchorPos = tagPoint:GetPos();
			local anchorDir = tagPoint:GetDirectionVector();
			local alignPos = g_Vectors.temp_v1;
			local alignLookAt = g_Vectors.temp_v2;

			-- land 5 meters above the landing mark.
			alignPos.x = anchorPos.x;
			alignPos.y = anchorPos.y;
			alignPos.z = anchorPos.z + 20;

			alignLookAt.x = alignPos.x + anchorDir.x * 100;
			alignLookAt.y = alignPos.y + anchorDir.y * 100;
			alignLookAt.z = alignPos.z + anchorDir.z * 100;

			entity.actor:SetMovementTarget( alignPos, alignLookAt,{x=0,y=0,z=0},1 );
		end

		entity:BlendAnimation(BasicAlien.BLENDING_RATIO);
	end,
	
	---------------------------------------------
	SC_SNIFF_PLAYER = function( self, entity )

		entity.actor:SetMovementTarget({x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},1);
		entity:BlendAnimation(BasicAlien.BLENDING_RATIO);

		entity.AI.searchHoverCount = 0;

		local targetName = AI.GetAttentionTargetOf(entity.id);
		if( targetName ) then
			local attackPos = g_Vectors.temp_v1;
			local attackDir = g_Vectors.temp_v2;
			local targetPos = g_Vectors.temp_v3;
			local targetDir = g_Vectors.temp_v4;
			local validPos = 0;

			-- first send him OnSeenByEnemy signal
			local target = AI.GetAttentionTargetEntity(entity.id);
			if(target) then 
				AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
			end

			AI.GetAttentionTargetPosition( entity.id, targetPos );
			AI.GetAttentionTargetDirection( entity.id, targetDir );

			validPos = AI.GetAlienApproachParams( entity.id, 4, targetPos, targetDir, attackPos, attackDir );	-- 0 = attack pos, 1 = recoil pos

			-- found valid target position
			-- Use some random variation to approach the target at facing angle or just rush there.
			AI.SetRefPointPosition( entity.id, attackPos );
			if( math.random(1,100) > 25 ) then
				AI.SetRefPointDirection( entity.id, attackDir );
			else
				AI.SetRefPointDirection( entity.id, {x=0,y=0,z=0} );
			end

			entity:SelectPipe(0,"sc_search_sniff",0);
		else
			-- Could not find target, try to find something interesting.
			AI.Signal(SIGNALFILTER_SENDER,0,"SC_FIND_INTERESTING_SPOT",entity.id);
		end
	end,
	
	---------------------------------------------
	SC_AT_SNIFF_POINT = function( self, entity )
		entity.AI.sniffCounter = entity.AI.sniffCounter + 1;
		if(entity.AI.sniffCounter>1) then
			-- let's switch to attack after few sniffs
			AI.Signal(SIGNALFILTER_SENDER,0,"OnEnemyDamage",entity.id);
		else
			entity:DoInvestigate();
			entity:SelectPipe(0,"sc_search_sniff_delay");
		end	
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

		-- first send him OnSeenByEnemy signal
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end

		entity:DoPlayerSeen();
		entity:SelectPipe(0,"sc_player_seen_delay_attack");
		-- Drop beacon and let the other know here's something to fight for.
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GO_ENEMY_FOUND",entity.id);

--		-- first send him OnSeenByEnemy signal
--		AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", g_localActor.id);
--
--		entity:TriggerEvent(AIEVENT_DROPBEACON);
--		if( entity.AI.searchHoverCount > 0 or not entity.AI.AnchorName ) then
--			-- Display animation that we see that player.
--			entity:DoPlayerSeen();
--			-- Go to the player, and sniff.
--			AI.Signal(SIGNALFILTER_SENDER,0,"SC_SNIFF_PLAYER",entity.id);
--			-- small pause while looking at the player.
--			entity:InsertSubpipe(0,"sc_player_seen_delay");
--
--			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GO_ENEMY_FOUND",entity.id);
--		end
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		self:OnPlayerSeen(entity, fDistance);
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, data)
		if( entity.AI.searchHoverCount >= 2 ) then
			-- Damage while landing, take of now!!
			AI.Signal(SIGNALFILTER_SENDER,0,"SC_SNIFF_PLAYER",entity.id);
		end
	end,
	
}
