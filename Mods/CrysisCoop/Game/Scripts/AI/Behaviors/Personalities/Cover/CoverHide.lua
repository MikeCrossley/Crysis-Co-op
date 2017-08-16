--------------------------------------------------
--    Created By: Luciano
--   Description: 	Cover goes hiding under fire
--------------------------
--

AIBehaviour.CoverHide = {
	Name = "CoverHide",
	alertness = 2,

	Constructor = function(self,entity)
		entity.bBehaviourJustStarted = true;
		Script.SetTimerForFunction(3000,"AIBehaviour.CoverHide.OnDelayEnd",entity);
	end,
	
	Destructor = function(self,entity)
		entity.bBehaviourJustStarted = false;
	end,

	OnEnemyMemory = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,
	---------------------------------------------
	OnGroupMemberDiedNearest= function( self, entity )
		-- called when a member of the group dies
	end,
	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance )
		if(not entity.bBehaviourJustStarted) then
			AI.Signal(SIGNALFILTER_SENDER,0,"SWITCH_TO_ATTACK",entity.id);
		end
	end,
	---------------------------------------------		
	OnInterestingSoundHeard = function( self, entity, fDistance )
		entity:TriggerEvent(AIEVENT_CLEAR);
	end,
	---------------------------------------------		
	OnThreateningSoundHeard = function( self, entity, fDistance )
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged

--		if (AI.GetGroupCount(entity.id) > 1) then
--			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "HEADS_UP_GUYS",entity.id);
--		end

		entity:SelectPipe(0,"search_for_target");
		entity:InsertSubpipe(0,"not_so_random_hide_from",data.id);
		entity:InsertSubpipe(0,"scared_shoot",data.id);
		entity:InsertSubpipe(0,"delayed_headsup");				
		entity:InsertSubpipe(0,"DropBeaconAt",data.id);
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged

		if (AI.GetGroupCount(entity.id) > 1) then
			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "HEADS_UP_GUYS",entity.id);
		end

		entity:SelectPipe(0,"search_for_target");
		entity:InsertSubpipe(0,"not_so_random_hide_from",data.id);
		entity:InsertSubpipe(0,"scared_shoot",data.id);
		entity:InsertSubpipe(0,"DropBeaconAt",data.id);
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		entity:Readibility("BULLETRAIN_IDLE");
		-- called when the enemy detects bullet trails around him
	end,
	--------------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
		-- called when the enemy sees a grenade
		entity:SelectPipe(0,"grenade_run_away");
	end,
	--------------------------------------------------
	TRY_TO_LOCATE_SOURCE = function (self, entity, sender)
		entity:SelectPipe(0,"lookaround_30seconds");
	end,
	
	--------------------------------------------------------
	OnHideSpotReached = function(self,entity,sender)
		local refPos = g_Vectors.temp;
		local targetDir = g_Vectors.temp_v1;
		if(AI.GetBeaconPosition(entity.id,targetDir)) then
			FastDifferenceVectors(targetDir, targetDir,entity:GetWorldPos());
		else			
			CopyVector(targetDir,entity:GetDirectionVector());
		end
		
		targetDir.z = 0;

		local dot = dotproduct3d(targetDir,	entity:GetDirectionVector());
		if(dot <0) then
			VecRotate90_Z(targetDir);
		else
			VecRotateMinus90_Z(targetDir);
		end					
		FastSumVectors(refPos, entity:GetWorldPos(),targetDir);
		AI.SetRefPointPosition(entity.id,refPos);
		
	end,
	--------------------------------------------------
	STRAFE_POINT_REACHED = function(self,entity,sender)
		-- this happens after strafing the obstacle
		entity:SelectPipe(0,"seek_target");
		entity:InsertSubpipe(0,"stop_fire");
		
	end,
	--------------------------------------------------
	STRAFE_POINT_NOT_REACHED = function(self,entity,sender)
		-- this happens after strafing the obstacle
		entity:SelectPipe(0,"seek_target");
		entity:InsertSubpipe(0,"stop_fire");
		
	end,
	
	--------------------------------------------------
	OnLowHideSpot = function( self, entity, sender)
		if (entity.Properties.special==1) then 
			return
		end
		entity:SelectPipe(0,"dig_in_attack");
	end,
	---------------------------------------------
	OnLeftLean  = function( self, entity, sender)
		if (entity.Properties.special==1) then 
			do return end
		end
		local rnd=random(1,10);
		if (rnd > 5) then 
			AI.Signal(0,1,"LEFT_LEAN_ENTER",entity.id);
		end
	end,
	---------------------------------------------
	OnRightLean  = function( self, entity, sender)
		if (entity.Properties.special==1) then 
			do return end
		end

		local rnd=random(1,10);
		if (rnd > 5) then 
			AI.Signal(0,1,"RIGHT_LEAN_ENTER",entity.id);
		end
	end,
	
	--------------------------------------------------
	END_HIDE = function(self,entity,sender)
		-- Calculate strafe point and set it to ref point.
--		if( entity:SetRefPointToStrafeObstacle() ) then
--			entity:SelectPipe(0,"strafe_obstacle");
--			entity:InsertSubpipe(0,"start_fire");
--			entity:InsertSubpipe(0,"do_it_standing");
--			entity:InsertSubpipe(0,"do_it_running");
--		end
	end,
	
	-----------------------------------------------------
	OnDelayEnd = function(entity,timerid)
		entity.bBehaviourJustStarted = false;
	end
}