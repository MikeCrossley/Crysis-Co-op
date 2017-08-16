--------------------------------------------------
--    Created By: Mikko
--   Description: 	Avoid explosives
--------------------------
--

AIBehaviour.Cover2AvoidExplosives = {
	Name = "Cover2AvoidExplosives",
	alertness = 2,
	exclusive = 1,

	-----------------------------------------------------
	Constructor = function(self,entity)
--		entity:Readibility("explosion_imminent",1,1,0.1,0.4);

		if (entity.AI.grenadeDist) then
			if (entity.AI.grenadeDist > 6.0) then
				entity:SelectPipe(0,"cv_backoff_from_explosion_short");
			else
				entity:SelectPipe(0,"cv_backoff_from_explosion");
			end
		else
			entity:SelectPipe(0,"cv_backoff_from_explosion");
		end

		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,0,"GET_ALERTED",entity.id);
	end,
	
	-----------------------------------------------------
	Destructor = function(self,entity)
		AI.ModifySmartObjectStates(entity.id,"-AvoidExplosion");
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,

	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,

	---------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender, data )
		entity:Readibility("ai_down",1,1,0.1,0.4);
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "OnGroupMemberDied",entity.id, data );
	end,

	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance, data )
		if (data.iValue == AITSR_SEE_STUNT_ACTION) then
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
			AI_Utils:ChooseStuntReaction(entity);
		elseif (data.iValue == AITSR_SEE_CLOAKED) then
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
			entity:SelectPipe(0,"sn_target_cloak_reaction");
		end
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------		
	OnInterestingSoundHeard = function( self, entity, fDistance )
	end,

	---------------------------------------------		
	OnThreateningSoundHeard = function( self, entity, fDistance )
	end,

	---------------------------------------------
	OnThreateningSeen = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
	end,

	---------------------------------------------
	OnReload = function( self, entity )
	end,

	--------------------------------------------------------
	OnHideSpotReached = function(self,entity,sender)
	end,

	--------------------------------------------------
	OnLowHideSpot = function( self, entity, sender)
	end,

	---------------------------------------------
	END_BACKOFF = function(self,entity)
--		CopyVector(entity.AI.explosionPos,g_Vectors.v000);
		-- Choose proper action after being interrupted.
		AI_Utils:CommonContinueAfterReaction(entity);
	end,

	---------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function(self,entity)
	end,
	
	---------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function(self,entity)
	end,

	---------------------------------------------
	OnVehicleDanger = function(self,entity)
		-- empty
	end,
	
	---------------------------------------------
	OnExplosionDanger = function(self,entity,sender,data)
	end,

	--------------------------------------------------
	OnGrenadeDanger = function( self, entity, sender, signalData )
	end,

	-------------------------------------------------
	GO_TO_AVOIDEXPLOSIVES = function(self,entity,sender)
	--	entity:SelectPipe(0,"do_nothing");
	--	entity:SelectPipe(0,"cv_backoff_from_explosion");
	end,
	
	-------------------------------------------------
	OnBackOffFailed = function(self,entity)
		entity:SelectPipe(0,"sn_flinch_front");
	end,

	---------------------------------------------
	PANIC_DONE = function(self,entity)
--		CopyVector(entity.AI.explosionPos,g_Vectors.v000);
		-- Choose proper action after being interrupted.
		AI_Utils:CommonContinueAfterReaction(entity);
	end,

	--------------------------------------------------
	MOUNTED_WEAPON_USABLE = function(self,entity,sender,data)
		-- sent by smart object rule
		if(data and data.id) then 
			local weapon = System.GetEntity(data.id);
			if(weapon) then
				AI.ModifySmartObjectStates(weapon.id,"Idle,-Busy");				
			end
		end
		AI.ModifySmartObjectStates(entity.id,"-Busy");				
	end,

}