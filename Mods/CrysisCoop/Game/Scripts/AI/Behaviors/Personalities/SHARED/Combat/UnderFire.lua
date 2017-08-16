--------------------------------------------------
--    Created By: Petar
--   Description: 	This gets called when the guy knows something has happened (he is getting shot at, does not know by whom), or he is hit. Basically
--  			he doesnt know what to do, so he just kinda sticks to cover and tries to find out who is shooting him
--	Kirill:
--	some modifications:
-- 	when in this behaviour, should be always crouching/proning
--------------------------
--

AIBehaviour.UnderFire = {
	Name = "UnderFire",
	NOPREVIOUS = 1,
	alertness = 2,
	Constructor = function(self,entity)
		entity.bBehaviourJustStarted = true;
		Script.SetTimerForFunction(3000,"AIBehaviour.UnderFire.OnDelayEnd",entity);
		entity:MakeAlerted();

		local target = AI.GetAttentionTargetEntity(entity.id);
		if(target == nil) then
			AI.SetRefPointPosition(entity.id,entity:GetWorldPos());
			entity:SelectPipe(0,"look_around_quick");
			entity:InsertSubpipe(0,"do_it_crouched");
			entity:InsertSubpipe(0,"randomhide","refpoint");
			
		end	
--entity:SelectPipe(0,"setup_crouch");
		
	end,
	
	Destructor = function(self,entity)
		entity.bBehaviourJustStarted = false;
	end,

	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,
	---------------------------------------------
--	OnGroupMemberDiedNearest= function( self, entity )
		-- called when a member of the group dies
--	end,
	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance )
		entity:SelectPipe(0,"cover_pindown");
		
	end,
	---------------------------------------------		
	OnInterestingSoundHeard = function( self, entity, fDistance )
		entity:TriggerEvent(AIEVENT_CLEAR);
	end,
	---------------------------------------------		
	OnThreateningSoundHeard = function( self, entity, fDistance )
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"not_so_random_hide_from","atttarget");
		--entity:TriggerEvent(AIEVENT_CLEAR);
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged
		AI.LogEvent("ONENEMY DAMAGE UNDER FIRE");
--		if (AI.GetGroupCount(entity.id) > 1) then
--			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "HEADS_UP_GUYS",entity.id);
--		end

		entity:SelectPipe(0,"not_so_random_hide_from",data.id);
		entity:InsertSubpipe(0,"delayed_headsup");
		entity:InsertSubpipe(0,"DropBeaconAt",data.id);		

--		entity:SelectPipe(0,"search_for_target");
--		entity:InsertSubpipe(0,"not_so_random_hide_from",data.id);
--		entity:InsertSubpipe(0,"scared_shoot",data.id);
--		entity:InsertSubpipe(0,"DropBeaconAt",data.id);

	end,
	
	---------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)

			entity:MakeAlerted();
--			entity:DrawWeaponDelay(0.6);
			entity:SelectPipe(0,"hide_from_beacon");
	end,
	
	
	---------------------------------------------
	OnHideSpotReached = function( self, entity, sender)
--			entity:SelectPipe(0,"seek_target");
--			entity:InsertSubpipe(0,"do_it_standing");
--			entity:InsertSubpipe(0,"medium_timeout");
--			entity:InsertSubpipe(0,"do_it_standing");

			entity:SelectPipe(0,"look_around_quick");
			entity:InsertSubpipe(0,"do_it_crouched");
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data)
		-- called when the enemy is damaged
		AI.LogEvent("ON DAMAGE UNDER FIRE");

--		if (AI.GetGroupCount(entity.id) > 1) then
--			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "HEADS_UP_GUYS",entity.id);
--		end

--		entity:SelectPipe(0,"search_for_target");
		entity:InsertSubpipe(0,"not_so_random_hide_from","beacon");
		entity:InsertSubpipe(0,"scared_shoot",data.id);
		entity:InsertSubpipe(0,"DropBeaconAt",data.id);
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy detects bullet trails around him
	end,
	--------------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
		-- called when the enemy sees a grenade
		entity:SelectPipe(0,"grenade_run_away");
	end,

	--------------------------------------------------
	being_shot = function ( self, entity, sender)
		-- called when the enemy detects bullet trails around him
	end,
	
	
	--------------------------------------------------
	TRY_TO_LOCATE_SOURCE = function (self, entity, sender)
		entity:SelectPipe(0,"lookaround_30seconds");
	end,

	OnNoHidingPlace = function( self, entity, sender,data )
		-- data.fValue = distance at which the hidespot has been searched
		if(entity.AI.InSquad~=1) then
			if(data.fValue<20) then 
				-- only non grouped behaviour
				local targetName = AI.GetAttentionTargetOf(entity.id);
				if(targetName  and AI.Hostile(entity.id,targetName)) then
					-- target is flesh and blood and enemy
					local target = System.GetEntityByName(targetName);
					local dist = entity:GetDistance(target.id);
					if(dist >50) then
						entity:SelectPipe(0,"just_shoot");
						entity:InsertSubpipe(0,"do_it_prone");
								
					elseif(dist >10) then
						entity:SelectPipe(0,"just_shoot");
					else
						entity:SelectPipe(0,"backoff_fire");
					end
					return;
				end
				--no interesting target
				entity:SelectPipe(0,"randomhide_wider");
				entity:InsertSubpipe(0,"medium_timeout");
				entity:InsertSubpipe(0,"do_it_prone");
			else
				if(targetName  and AI.Hostile(entity.id,targetName)) then
					-- target is flesh and blood and enemy
					entity:SelectPipe(0,"just_shoot");
					local target = System.GetEntityByName(targetName);
					local dist = entity:GetDistance(target.id);
					if(dist>50) then 
						entity:InsertSubpipe(0,"do_it_crouched");
					end
				else
				
					entity:SelectPipe(0,"just_shoot");
					entity:InsertSubpipe(0,"do_it_prone");
--					entity:InsertSubpipe(0,"random_short_timeout");
					entity:InsertSubpipe(0,"acquire_beacon");
				end
			end
		end
	end,	

	
	-----------------------------------------------------
	OnDelayEnd = function(entity,timerid)
		entity.bBehaviourJustStarted = false;
	end

}