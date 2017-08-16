----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2001-2004.
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: this makes the gyu select snipeing spot and go there.
--	to be used by Sniper when moving from one snipeSpot to another. Should be ignoring 
--	everything and stay low. 
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 6:dec:2005   : Created by Kirill Bulatsev
--
----------------------------------------------------------------------------------------------------´

AIBehaviour.SniperMove = {
	Name = "SniperMove",
	Base = "SniperSnipe",		

	-- firstTime flag is on when doing geting first point from idle
	FindSnipeSpot  = function (self, entity, firstTime)
	
			-- use prev point position, selected in idle
--			if(entity.AI.snipe_spot_pos~=nil) then return 1 end
	local anchorName = nil;
			if( firstTime~=nil ) then
				anchorName = AI.GetAnchor(entity.id,AIAnchorTable.SNIPER_SPOT,{min=1,max=50},AIANCHOR_NEAREST);
--AI.LogEvent("FindSnipeSpot >>>>> first time ");				
			else
				anchorName = AI.GetAnchor(entity.id,AIAnchorTable.SNIPER_SPOT,{min=0,max=50},AIANCHOR_RANDOM_IN_RANGE_FACING_AT);
--AI.LogEvent("FindSnipeSpot >>>>> next time ");				
			end	
			if( anchorName ) then
--AI.LogEvent("FindSnipeSpot >>>>> found   "..anchorName);
				local anchor = System.GetEntityByName( anchorName );
				entity.AI.snipe_spot_pos = {};
				entity.AI.snipe_spot_dir = {};
				
				CopyVector(entity.AI.snipe_spot_pos, anchor:GetWorldPos());
				CopyVector(entity.AI.snipe_spot_dir, anchor:GetDirectionVector());
				
--				entity.AI.snipe_spot_pos = entity.id, anchor:GetWorldPos();
--				AI.SetRefPointPosition( entity.id, anchor:GetPos() );
--				entity:SelectPipe(0,"sniper_move");
				return 1
			else
				AI.Signal(SIGNALFILTER_SENDER,0,"SniperCloseContact",entity.id);
				entity:SelectPipe(0,"cv_scramble");
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE, "cv_short_cover_fire");
--AI.LogEvent("FindSnipeSpot >>>>> fail");			
				entity.AI.snipe_spot_pos = nil;
				return nil
--				AI.Signal(SIGNALFILTER_SENDER,0,"on_spot",entity.id);	
			end
	end,

	Constructor = function (self, entity)
	
		if(self:FindSnipeSpot(entity) ~= nil) then
--			entity:SelectPipe(0,"sniper_singlespot");
----			AI.Signal(SIGNALFILTER_SENDER,0,"on_spot",entity.id);	
--		else

			local dist1 = DistanceVectors(entity.AI.snipe_spot_pos, entity:GetWorldPos());
			if(dist1 < 2.3) then
				AI.Signal(SIGNALFILTER_SENDER,0,"on_spot",entity.id);
				return
			end
			--calculate best blocker radius		
			local	pfBlockerRad=0;
			
			local target = AI.GetAttentionTargetEntity(entity.id);
			if(target) then 
				local dist2 = DistanceVectors(entity:GetWorldPos(), target:GetWorldPos());
				if(dist1>dist2) then
					pfBlockerRad=dist1 + 5;
				else
					pfBlockerRad=dist2 + 5;
				end	
--				pfBlockerRad=DistanceVectors(entity.AI.snipe_spot_pos, target:GetWorldPos()) + 9;
			end
			
--AI.LogEvent("FindSnipeSpot >>>>> PFBlocker radius  "..pfBlockerRad);
			if(pfBlockerRad > 1) then
				AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, pfBlockerRad);
			end
				
			entity:SelectPipe(0,"sniper_backoff");
		end
		
--		AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 80);
--		entity:SelectPipe(0,"sniper_backoff");
	end,

	HEADS_UP_GUYS = function (self, entity, sender)
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
	end,

	---------------------------------------------
	-- Sniper never does search
	LOOK_FOR_TARGET	 = function( self, entity )

	end,

	---------------------------------------------
	GET_ALERTED = function( self, entity )
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		AIBehaviour.SniperIdle:ChecktargetProximity(entity, fDistance);
	end,
	
	---------------------------------------------
	sniper_move_start = function( self, entity )
--		AI.SetRefPointPosition( entity.id, entity.AI.snipe_spot_pos );
		
		local refPos = g_Vectors.temp;
		FastScaleVector(refPos, entity.AI.snipe_spot_dir, -6);
		FastSumVectors(refPos, entity.AI.snipe_spot_pos, refPos);
		AI.SetRefPointPosition(entity.id,refPos);
		
--		entity.AI.snipe_spot_pos = nil;
		entity:SelectPipe(0,"sniper_move_back");
	end,
	
	---------------------------------------------
	on_spot_back = function( self, entity )
		AI.SetRefPointPosition( entity.id, entity.AI.snipe_spot_pos );
		entity:SelectPipe(0,"sniper_move");
	end,
	
	---------------------------------------------
	move_done = function( self, entity )
		local refPos = g_Vectors.temp;
		FastScaleVector(refPos, entity.AI.snipe_spot_dir, 10);
		FastSumVectors(refPos, entity.AI.snipe_spot_pos, refPos);
		AI.SetRefPointPosition(entity.id,refPos);
		entity:SelectPipe(0,"sniper_pre_snipe");
	end,

	---------------------------------------------
	sniper_move_moving = function( self, entity )
		local target = AI.GetAttentionTargetEntity(entity.id);
		if(target) then 
			AI.SetRefPointPosition( entity.id, target:GetWorldPos() );
		end
	end,
	
	---------------------------------------------



}
