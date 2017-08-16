--------------------------------------------------
--   Created By: Luciano
--   Description: The cover searches for enemies around
--------------------------

AIBehaviour.CoverSearch = {
	Name = "CoverSearch",
	--TASK = 1,
	JOB=1,
	alertness = 1,

	Constructor = function(self, entity)
--		AI.Signal(SIGNALFILTER_LEADER,1,"ORD_DONE",entity.id);
		-- Save the hide point for future use
		AIBehaviour.CoverSearch.LOOKING_DONE(self,entity,entity);

	end,
	---------------------------------------------
	Destructor = function(self, entity)
		entity.anchor = nil;
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
--		AIBehaviour.SquadIdle:OnNoTarget(entity);
--		entity:SelectPipe(0,"confirm_targetloss");
	end,
	---------------------------------------------
	
--	OnPlayerSeen = function( self, entity, fDistance )
		
--	end,
	---------------------------------------------
--	OnEnemyMemory = function( self, entity, fDistance )
				
--	end,
	---------------------------------------------
--	OnInterestingSoundHeard = function( self, entity )
--		entity:SelectPipe(0,"seek_target");
--	end,
	---------------------------------------------
--	OnThreateningSoundHeard = function( self, entity )
--	end,
	---------------------------------------------
	OnReload = function( self, entity )

	end,
	---------------------------------------------
--	OnGroupMemberDied = function( self, entity )
--	end,
	--------------------------------------------------
	LOOK_FOR_TARGET = function (self, entity, sender)
		-- do nothing on this signal
		entity:SelectPipe(0,"look_around");
	end,	


	TARGET_REACHED = function (self, entity, sender)
	
		if(entity.anchor) then
			if(entity.anchorType == AIAnchorTable.ACTION_LOOK_AROUND) then
				CopyVector(g_Vectors.temp, entity:GetDirectionVector());
				CopyVector(g_Vectors.temp_v2,entity.anchor:GetDirectionVector());
				g_Vectors.temp.z = 0;
				g_Vectors.temp_v2.z=0;
				local cosine = vecDot(g_Vectors.temp,g_Vectors.temp_v2);
				local angle = math.floor(math.acos(cosine)*g_Rad2Deg/10+0.5);
				local direction = angle*10;
	
				direction = clamp(direction,-90,90);
				entity:SelectPipe(0,"LookAround"..direction);	

				local v = entity.anchor:GetWorldPos();
				v.z = v.z+2;
				entity.anchor:SetWorldPos(v);
				
			elseif(entity.anchorType == AIAnchorTable.ACTION_RECOG_CORPSE) then
				entity:SelectPipe(0,"do_nothing");
				-- select left/right animation
				CopyVector(g_Vectors.temp_v2, entity.anchor:GetWorldPos());
				SubVectors(g_Vectors.temp_v2,g_Vectors.temp_v2,entity:GetWorldPos());
				local cosine = vecDot(entity:GetDirectionVector(),g_Vectors.temp_v2);
				if(cosine<0) then								
					entity:StartAnimation(0,"stand_death_recognition_01" ,6,0.9,0.9,0); 
				else
					entity:StartAnimation(0,"stand_death_recognition_02" ,6,0.9,0.9,0); 
				end
				Script.SetTimerForFunction(entity:GetAnimationLength(0,g_StringTemp1 ) * 1000,"AIBehaviour.CoverSearch.OnEndAnimation",entity);
			end
		end
		
	end, 
	
	LOOKING_DONE = function (self, entity, sender)
		g_StringTemp1 = AI.GetAnchor(entity.id,AIAnchorTable.ACTION_RECOG_CORPSE,15);
		if(g_StringTemp1 ==nil or g_StringTemp1=="") then
			g_StringTemp1 = AI.GetAnchor(entity.id,AIAnchorTable.ACTION_LOOK_AROUND,30);
			if(g_StringTemp1 and g_StringTemp1~="") then
				-- look around
				entity.anchorType = AIAnchorTable.ACTION_LOOK_AROUND;
				entity.anchor = System.GetEntityByName(g_StringTemp1);
				entity:SelectPipe(0,"approach_lastop_lookaround",g_StringTemp1);
				entity:InsertSubpipe(0,"do_it_walking");
				entity:InsertSubpipe(0,"clear_all");
				entity.anchor:Event_Disable();
			else
				-- no more places to search
				entity:SelectPipe(0,"do_nothing");
				entity.anchor = nil;
--				AI.Signal(0, 10, "NC_SearchDone", AI.Commander:GetEntity().id);
			end
			
		else
			-- recog corpse
			entity.anchor = System.GetEntityByName(g_StringTemp1);
			entity.anchorType = AIAnchorTable.ACTION_RECOG_CORPSE;
			entity:SelectPipe(0,"approach_lastop_distance",g_StringTemp1);
			entity:InsertSubpipe(0,"do_it_walking");
			--entity:InsertSubpipe(0,"do_it_running");
			entity:InsertSubpipe(0,"acquire_target",g_StringTemp1);
			entity.anchor.Event_Disable();
		end

	end,
	

	OnEndAnimation = function(entity,timerId)
		AI.Signal(SIGNALFILTER_SENDER,0,"LOOKING_DONE",entity.id);
	end
	

	
}
