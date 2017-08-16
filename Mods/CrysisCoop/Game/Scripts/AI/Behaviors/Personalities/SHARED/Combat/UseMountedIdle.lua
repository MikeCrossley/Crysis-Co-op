--------------------------------------------------
-- Created By:	Luciano Morpurgo
-- Description: This behavior is used to make
--							agents approach particular mounted
--							weapon and use it since then beginning
--------------------------------------------------

AIBehaviour.UseMountedIdle = {
	Name = "UseMountedIdle",
	Base = "UseMounted",
	alertness = 0,
	exclusive = 1,
	
	Constructor = function( self, entity, data )
	
		entity:InitAIRelaxed();
		if (data and data.id) then 
			AI.Signal(SIGNALFILTER_SENDER,0,"MOUNTED_WEAPON_USABLE",entity.id,data);
		else
			AI.ModifySmartObjectStates(entity.id,"UseMountedWeapon");			
		end
		entity.AI.SkipTargetCheck = true;
		entity.AI.keepMG = nil;
		
		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
	end,
	
	Destructor = function( self, entity )
		if(entity.AI.keepMG==nil) then
			self:LeaveMG(entity);
		end	
	end,

	TO_USE_MOUNTED = function(self,entity)
		-- this signal is specifically used for UseMountedIdle->UseMounted
		-- avoid checking the target position
		entity.AI.SkipTargetCheck = false;
	end,
	
	USE_MOUNTED_WEAPON = function(self,entity)
		entity.AI.SkipTargetCheck = false;
		AIBehaviour.UseMounted:StartUsingMountedWeapon(entity);
	end,
	
	TOO_FAR_FROM_WEAPON = function(self,entity,sender)
		entity:SelectPipe(0,"do_nothing");
	end,
	
	LeaveMG = function(self,entity,sender)
		local weapon = entity.AI.current_mounted_weapon;
		if (weapon ) then		
--		if(weapon.item:GetOwnerId() == entity.id) then 
			weapon.item:StopUse( entity.id );
--		end
			entity:HolsterItem( false );
			AI.ModifySmartObjectStates(weapon.id,"Idle,-Busy");				
			weapon.listPotentialUsers = nil;
			weapon.reserved = nil;
		end
		AI.ModifySmartObjectStates(entity.id,"-Busy");			
		entity.AI.current_mounted_weapon = nil;
		AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, entity.Properties.accuracy );
		AI.ChangeParameter( entity.id, AIPARAM_FOVSECONDARY,	entity.Properties.Perception.FOVSecondary);		
		entity:InsertSubpipe(0,"do_it_standing");
--		AI.SetAimOffset(entity.id, 0,0,0);
 		entity.AI.approachingMountedWeapon = false;
		
	end,
	
	FALL_AND_PLAY_WAKEUP	= function( self, entity, senda )
		AI.SetRefPointPosition(entity.id, data.point);	
		self:LeaveMG(entity,entity);
	end,

	------------------------------------------------------------
	OnPlayerSeen = function( self, entity, senda )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_FIRST_CONTACT",entity.id);
		--entity.AI.keepMG = 1;
		local weapon = entity.AI.current_mounted_weapon;
		if(weapon and AI.IsMountedWeaponUsableWithTarget(entity.id,weapon.id,7)) then
			entity.AI.keepMG = 1;
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_USE_MOUNTED",entity.id);
		else
			entity.AI.keepMG = nil;
--			entity:SelectPipe(0,"mg_short_reaction_leave");
			AI.Signal(SIGNALFILTER_SENDER, 1, "LEAVE_MOUNTED_WEAPON",entity.id);

		end

	end,
	
	------------------------------------------------------------
	OnEnemyDamage = function( self, entity, senda, data )
		
		entity:GettingAlerted();
		-- set the beacon to the enemy pos
		local shooter = System.GetEntity(data.id);
		if(shooter) then
			AI.SetBeaconPosition(entity.id, shooter:GetPos());
		else
			entity:TriggerEvent(AIEVENT_DROPBEACON);
		end
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);
		-- dummy call to this one, just to make sure that the initial position is checked correctly.
		if(shooter) then 
			local weapon = entity.AI.current_mounted_weapon;
			if(weapon and AI.IsMountedWeaponUsableWithTarget(entity.id,weapon.id,7,shooter:GetPos()) ) then
				entity.AI.keepMG = 1;
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_USE_MOUNTED",entity.id);
				return;
			end
		end
		
		entity.AI.keepMG = nil;
		AI.Signal(SIGNALFILTER_SENDER, 1, "LEAVE_MOUNTED_WEAPON",entity.id);
--		entity:SelectPipe(0,"mg_short_reaction_leave");
		
	end,

	------------------------------------------------------------
	OnThreateningSoundHeard = function( self, entity, sender )
		
		local weapon = entity.AI.current_mounted_weapon;
		entity:Readibility("idle_alert_threat_hear",1,1,0.6,1);

		entity:TriggerEvent(AIEVENT_DROPBEACON);
		if(weapon and AI.IsMountedWeaponUsableWithTarget(entity.id,weapon.id,7)) then
			entity.AI.keepMG = 1;
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_USE_MOUNTED",entity.id);
		else
			entity.AI.keepMG = nil;
			AI.Signal(SIGNALFILTER_SENDER, 1, "LEAVE_MOUNTED_WEAPON",entity.id);
			--entity:SelectPipe(0,"mg_short_reaction_leave");
		end

	end,
	
	------------------------------------------------------------
	OnInterestingSoundHeard = function( self, entity, sender )
		entity:Readibility("idle_interest_hear",1,1,0.6,1);

		local weapon = entity.AI.current_mounted_weapon;
		if(weapon and AI.IsMountedWeaponUsableWithTarget(entity.id,weapon.id,7)) then
			entity.AI.keepMG = 1;
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_USE_MOUNTED",entity.id);
		else
			entity.AI.keepMG = nil;
--			AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, entity.Properties.accuracy );
--			AI.ChangeParameter( entity.id, AIPARAM_FOVSECONDARY,	entity.Properties.Perception.FOVSecondary * 1.5);		
			
			--AI.Signal(SIGNALFILTER_SENDER, 1, "LEAVE_MOUNTED_WEAPON",entity.id);
--			entity:InsertSubpipe(0,"mg_short_reaction_leave");
			--entity:SelectPipe(0,"do_nothing"); -- remove the mg lookaround thing, try to look at target
		end
	end,	

	------------------------------------------------------------
	OnSomethingSeen = function( self, entity, sender )
		
		local weapon = entity.AI.current_mounted_weapon;
		--entity:Readibility("idle_alert_threat_hear",1,1,0.6,1);

		entity:TriggerEvent(AIEVENT_DROPBEACON);
		if(weapon and AI.IsMountedWeaponUsableWithTarget(entity.id,weapon.id,7)) then
			entity.AI.keepMG = 1;
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_USE_MOUNTED",entity.id);
		else
			entity.AI.keepMG = nil;
--			AI.Signal(SIGNALFILTER_SENDER, 1, "LEAVE_MOUNTED_WEAPON",entity.id);
--			entity:SelectPipe(0,"mg_short_reaction_leave");
		end

	end,

	------------------------------------------------------------
	OnThreateningSeen = function( self, entity, sender )
		
		local weapon = entity.AI.current_mounted_weapon;
		--entity:Readibility("idle_alert_threat_hear",1,1,0.6,1);

		entity:TriggerEvent(AIEVENT_DROPBEACON);
		if(weapon and AI.IsMountedWeaponUsableWithTarget(entity.id,weapon.id,7)) then
			entity.AI.keepMG = 1;
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_USE_MOUNTED",entity.id);
		else
			entity.AI.keepMG = nil;
			AI.Signal(SIGNALFILTER_SENDER, 1, "LEAVE_MOUNTED_WEAPON",entity.id);
			--entity:SelectPipe(0,"mg_short_reaction_leave");
		end

	end,

	
	------------------------------------------------------------
	OnCollision = function(self,entity,sender,data)
		if(AI.Hostile(entity.id,data.id) and AI.GetAttentionTargetEntity(entity.id,true) ~= System.GetEntity(data.id)) then 
			entity:Readibility("idle_alert_threat_hear",1,1,0.6,1);
			entity:TriggerEvent(AIEVENT_DROPBEACON);
			local weapon = entity.AI.current_mounted_weapon;
			if(weapon and AI.IsMountedWeaponUsableWithTarget(entity.id,weapon.id,7)) then
				entity.AI.keepMG = 1;
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_USE_MOUNTED",entity.id);
			else
				entity.AI.keepMG = nil;
				AI.Signal(SIGNALFILTER_SENDER, 1, "LEAVE_MOUNTED_WEAPON",entity.id);
				--entity:SelectPipe(0,"mg_short_reaction_leave");
			end
		end
	end,
	
	------------------------------------------------------------
	OnBulletRain = function( self, entity, sender )
--	end,
--	OnBulletRain2 = function( self, entity, sender )
		-- only react to hostile bullets.
--		AI.RecComment(entity.id, "hostile="..tostring(AI.Hostile(entity.id, sender.id)));
		if(AI.Hostile(entity.id, sender.id)) then
			entity:GettingAlerted();
			if(AI.GetTargetType(entity.id)==AITARGET_NONE) then
				local	closestCover = AI.GetNearestHidespot(entity.id, 3, 15, sender:GetPos());
				if(closestCover~=nil) then
					AI.SetBeaconPosition(entity.id, closestCover);
				else
					AI.SetBeaconPosition(entity.id, sender:GetPos());
				end
			else
				entity:TriggerEvent(AIEVENT_DROPBEACON);
			end
			entity:Readibility("bulletrain",1,1,0.1,0.4);

			-- dummy call to this one, just to make sure that the initial position is checked correctly.
			AI_Utils:IsTargetOutsideStandbyRange(entity);

			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);
			-- check if fire comes from a point in MG range/fov
			local weapon = entity.AI.current_mounted_weapon;
			if(weapon and AI.IsMountedWeaponUsableWithTarget(entity.id,weapon.id,7,sender:GetPos()) ) then
				entity.AI.keepMG = 1;
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_USE_MOUNTED",entity.id);
			else
				entity.AI.keepMG = nil;
				AI.Signal(SIGNALFILTER_SENDER, 1, "LEAVE_MOUNTED_WEAPON",entity.id);
--				entity:SelectPipe(0,"mg_short_reaction_leave");
			end
		else
			if(sender==g_localActor) then 
				entity:Readibility("friendly_fire",1,0.6,1);
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"look_at_player_5sec");			
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"do_nothing");		-- make the timeout goal in previous subpipe restart if it was there already
			end
		end
	end,

	------------------------------------------------------------
	GO_TO_GRABBED	= function(self,entity)
		entity.AI.keepMG=nil;
		self:LeaveMG(entity);
		entity.AI.SkipTargetCheck = false;
	end,

}

