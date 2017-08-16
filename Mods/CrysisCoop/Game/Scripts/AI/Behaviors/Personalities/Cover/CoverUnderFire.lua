--------------------------------------------------
--    Created By: Petar
--   Description: 	This gets called when the guy knows something has happened (he is getting shot at, does not know by whom), or he is hit. Basically
--  			he doesnt know what to do, so he just kinda sticks to cover and tries to find out who is shooting him
--	Kirill:
--	some modifications:
-- 	when in this behaviour, should be always crouching/proning
--------------------------
--

AIBehaviour.CoverUnderFire = {
	Name = "CoverUnderFire",
	Base = "UnderFire",	
	NOPREVIOUS = 1,
	alertness = 2,
	

	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance )
		entity:SelectPipe(0,"cover_pindown");
		
	end,
	---------------------------------------------		
	OnInterestingSoundHeard = function( self, entity, fDistance )
		entity:TriggerEvent(AIEVENT_CLEAR);
	end,
	---------------------------------------------		
	---------------------------------------------
	OnHideSpotReached = function( self, entity, sender)
			entity:SelectPipe(0,"seek_target");
			entity:InsertSubpipe(0,"look_around_quick");
			entity:InsertSubpipe(0,"do_it_standing");
			entity:InsertSubpipe(0,"look_around");
			entity:InsertSubpipe(0,"look_around");
			entity:InsertSubpipe(0,"look_around");

	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data)
		-- called when the enemy is damaged
		AI.LogEvent("ON DAMAGE UNDER FIRE");

--		if (AI.GetGroupCount(entity.id) > 1) then
--			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "HEADS_UP_GUYS",entity.id);
--		end

		entity:SelectPipe(0,"search_for_target");
		entity:InsertSubpipe(0,"not_so_random_hide_from","beacon");
		entity:InsertSubpipe(0,"scared_shoot",data.id);
		entity:InsertSubpipe(0,"DropBeaconAt",data.id);
	end,
	
	
	--------------------------------------------------
	TRY_TO_LOCATE_SOURCE = function (self, entity, sender)
		entity:SelectPipe(0,"lookaround_30seconds");
	end,

	OnNoHidingPlace = function( self, entity, sender,data )
		-- data.fValue = distance at which the hidespot has been searched
		if(entity.IN_SQUAD~=1) then
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