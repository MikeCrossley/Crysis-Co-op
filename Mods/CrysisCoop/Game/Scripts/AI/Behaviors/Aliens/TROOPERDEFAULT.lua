-- Default trooper behavior 
-- base behavior from which all other behaviors are inherited


AIBehaviour.TROOPERDEFAULT = {
	Name = "TROOPERDEFAULT",

	Constructor = function(self,entity)
		-- base constructor for all available initial behaviors
		entity.bGunReady = true;
		entity:MakeIdle();
		entity:Cloak(0);
		entity.AI.bAmbush = false;
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTRANGE,entity.Properties.Perception.sightrange);	
		entity:SelectPipe(0,"do_it_standing");
--		AI.Signal(SIGNALFILTER_SUPERGROUP,0,"CHECK_TROOPER_GROUP",entity.id);
		if(not AIBlackBoard.Trooper_SpecialActionTarget) then
			AIBlackBoard.Trooper_SpecialActionTarget = {};
		end
		
		AIBlackBoard.Trooper_SpecialActionTarget[entity:GetName()] = nil;
		-- set fire mode
--		local groupid = AI.GetGroupOf(entity.id);
--		if(AIBlackBoard.trooperFireMode==nil) then 
--			AIBlackBoard.trooperFireMode = {};
--		end
--		
--		if(AIBlackBoard.trooperFireMode[groupid]==nil) then 
--			-- fix: no random fire mode, always 0
--			AIBlackBoard.trooperFireMode[groupid] = 0;--random(0,1);
--		end
--		entity.AI.FireMode = AIBlackBoard.trooperFireMode[groupid];
--		AIBlackBoard.trooperFireMode[groupid] = 1 - AIBlackBoard.trooperFireMode[groupid];

		-- fix: no random fire mode, always 0
		entity.AI.FireMode = 0;
		--AI.SetMinFireTime(entity.id,6.5);
		-- force max accuracy , using a slow bullet weapon
		AI.ChangeParameter( entity.id, AIPARAM_ACCURACY,1);
		
		g_Vectors.temp.x = 0;
		g_Vectors.temp.y = -0.4;
		g_Vectors.temp.z = 0;
--		AI.SetAimOffset(entity.id, 0,0,-0.3);
		
	end,
	
	---------------------------------------------
	OnTargetDead = function( self, entity )
		-- called when the attention target died
		local target = AI.GetAttentionTargetEntity(entity.id);
		if(target) then
			g_SignalData.id = target.id;
			AI.Signal(SIGNALFILTER_LEADER,1,"OnCheckDeadTarget",entity.id,g_SignalData);
		else
			AI.Signal(SIGNALFILTER_LEADER,1,"OnCheckDeadTarget",entity.id);
		end
	end,

	---------------------------------------------
	OnNoGroupTarget = function( self, entity,sender, data)
		Trooper_Search(entity);
	end,

	---------------------------------------------
	OnCheckDeadBody = function( self, entity,sender, data)
		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then
			entity.AI.deadBodyToCheckId = data.id;
			entity:SelectPipe(0,"tr_check_dead_body_moving");
		end
	end,
	
	---------------------------------------------
	CHECK_DEAD_BODY_MOVING = function( self, entity,sender)
		local body = System.GetEntity(entity.AI.deadBodyToCheckId);
		if(body) then 
			if(body:GetSpeed()<1) then
				local pos = g_Vectors.temp;
				CopyVector(pos,body:GetWorldPos());
				pos.z = pos.z + 1;
				AI.SetRefPointPosition(entity.id,pos);
				entity:SelectPipe(0,"tr_check_dead_body");
			end
		else
			AIBehaviour.TROOPERDEFAULT:END_CHECK_DEAD_BODY(entity,sender);
		end
	end,

	---------------------------------------------
	DEAD_BODY_APPROACHED = function( self, entity,sender)
		Trooper_SetConversation(entity,false,200);
	end,

	---------------------------------------------
	END_CHECK_DEAD_BODY = function( self, entity,sender)
		Trooper_Search(entity);
	end,

	---------------------------------------------
	SHARED_USE_THIS_MOUNTED_WEAPON = function( self, entity )
	end,

	---------------------------------------------
	LOOK_AROUND = function(self , entity, sender, data)
		if(data and IsNotNullVector(data.point)) then 
			AI.SetRefPointPosition(entity.id,data.point);
			entity:SelectPipe(0,"tr_look_around_refpoint");
		else
			entity:SelectPipe(0,"tr_look_around");
		end
	end,
	
	---------------------------------------------------------------------------------------------------------------------------------------
	ORDER_HIDE = function( self, entity, sender, data )
		AI.SetRefPointPosition(entity.id, data.point);
	end,

	---------------------------------------------------------------------------------------------------------------------------------------
	ORDER_SEARCH = function( self, entity, sender, data )
--		AI.SetRefPointPosition(entity.id, data.point);
	end,
	---------------------------------------------------------------------------------------------------------------------------------------
	ORDER_COVER_SEARCH = function(self,entity,sender,data)
		-- data.point = enemy position
		-- data.point2 = average group position
		local position = g_Vectors.temp;
		FastSumVectors(position,data.point,data.point2);
		ScaleVectorInPlace(position,0.6);
		AI.SetRefPointPosition(entity.id,position);
		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(0,"tr_search_cover_fire");
	end,	

	---------------------------------------------------------------------------------------------------------------------------------------
	HIDE_FROM_BEACON = function ( self, entity, sender)
		entity:InsertSubpipe(0,"tr_hide_from_beacon");
	end,

	---------------------------------------------------------------------------------------------------------------------------------------
	DESTROY_THE_BEACON = function ( self, entity, sender)
		if (entity.cnt.numofgrenades>0) then 
			local rnd=random(1,4);
--			if (rnd>2) then 
				entity:InsertSubpipe(0,"tr_shoot_the_beacon");
--			else
--				entity:InsertSubpipe(0,"tr_bomb_the_beacon");
--			end
		else
			entity:InsertSubpipe(0,"tr_shoot_the_beacon");
		end
	end,

	OnFriendInWay = function ( self, entity, sender)
	end,

	OnReceivingDamage = function ( self, entity, sender)
	end,

	--------------------------------------------------
--	OnCloseContact = function(self,entity,sender)
--		local curTime = _time;
--		AI.LogEvent("CLOSE CONTACT time = ".._time);
--		if(AIBlackBoard.lastTrooperMeleeTime==nil) then 
--			AIBlackBoard.lastTrooperMeleeTime = curTime - 3;
--		end
--		local timePassed = curTime - AIBlackBoard.lastTrooperMeleeTime;
--		if( timePassed  > 2 ) then
--			AIBlackBoard.lastTrooperMeleeTime = curTime;
--			entity:MeleeAttack(sender);
--		end
--	end,
	
	--------------------------------------------------
	OnCloseContact= function(self,entity,sender)

	end,
	--------------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, signalData )
		-- called when the enemy sees an object
		if ( signalData.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end
		if (signalData.iValue == 150) then
			if (fDistance < 15) then
				AI.Signal(SIGNALFILTER_GROUPONLY,1,"GRENADE_SEEN",entity.id,signalData);
			end
		end
	end,

	--------------------------------------------------

	GRENADE_SEEN = function(self,entity,sender, data)
		if(AI.GetAttentionTargetType(entity.id) == 150) then 
			-- I have seen the grenade
			AI.Signal(SIGNALFILTER_SENDER,1,"DODGE_GRENADE",entity.id,signalData);
		else
			-- TO DO (group member saw a grenade)
		end
	end,
	------------------------------------------------------------------------
	OnBackOffFailed = function(self,entity,sender)
		if(AI.GetAttentionTargetType(entity.id) ==150) then 
		-- this is for grenades only, just retry depending on the new grenade position
			entity:InsertSubpipe(0,"tr_grenade_seen");
		end
	end,	
		
	MAKE_ME_IGNORANT = function ( self, entity, sender)
		AI.SetIgnorant(entity.id,1);
	end,
	
	MAKE_ME_UNIGNORANT = function ( self, entity, sender)
		AI.SetIgnorant(entity.id,0);
	end,

	-- Everyone has to be able to warn anyone around him that he died




	--------------------------------------------------
	OnLeaderDied = function(self,entity,sender)
--		entity:SelectPipe(0,"tr_confused");
--		entity.AI.InSquad = 0;	
		if(entity ~= sender and not AI.GetLeader(entity.id)) then 
			AI.SetLeader(entity.id);
		end
	end,
	

	--------------------------------------------------
	-- Throws a single grenade
	--------------------------------------------------
	SHARED_THROW_GRENADE = function(self, entity, sender)
	end,
	---------------------------------------------
	OnDamage = function(self,entity,sender,data)
--		entity:Readibility("GETTING_SHOT_AT",1);
	end,

	---------------------------------------------
	DO_SOMETHING_IDLE = function( self,entity , sender)

	end,

	--------------------------------------------------------
	JOIN_TEAM = function ( self, entity, sender)
		AI.LogEvent(entity:GetName().." JOINING TEAM");
		entity.AI.InSquad = 1;
	end,

	--------------------------------------------------------
	BREAK_TEAM = function ( self, entity, sender)
		entity.AI.InSquad = 0;
	end,

	-----------------------------------------------------------------------
	END_HIDE_NEAR = function(self,entity,sender)
--		if( entity:SetRefPointToStrafeObstacle() ) then
			AIBehaviour.TROOPERDEFAULT:StrafeObstacle(entity);
		--else
--			entity:SelectPipe(0,"do_nothing"); 
	--		entity:InsertSubpipe(0,"do_it_standing");
		--end
		entity:InsertSubpipe(0,"start_fire");
	end,

	------------------------------------------------------------------------
--	StrafeShoot = function(self,entity,sender,data)
--		local range;
--		if(data and data.fValue>0) then 
--			range = data.fValue;
--		else
--			range = 3;
--		end;
--		range = random(1,range)/3;
--		FastScaleVector(g_Vectors.temp_v1,entity:GetDirectionVector(0), range*(random(1,2)*2-3));
--		FastSumVectors(g_Vectors.temp, entity:GetWorldPos(), g_Vectors.temp_v1);
--		AI.SetRefPointPosition(entity.id,	g_Vectors.temp);
--		entity:SelectPipe(0,"tr_strafe_and_form");
--		entity:InsertSubpipe(0,"start_fire");
--	end,
	StrafeObstacle = function(self,entity)
		
		if(AI.GetTargetType(entity.id)~=AITARGET_ENEMY) then 
			local peek = AI.EvalPeek(entity.id);
			if(peek == 3 ) then 
				if(random(1,10) < 5) then
					entity:SelectPipe(0,"tr_strafe_obstacle_right");
				else
					entity:SelectPipe(0,"tr_strafe_obstacle_left");
				end
			elseif(peek == 2) then
				entity:SelectPipe(0,"tr_strafe_obstacle_right");
			elseif(peek == 1) then
				entity:SelectPipe(0,"tr_strafe_obstacle_left");
			else -- can't peek or no obstacles in front
				entity:SelectPipe(0,"tr_strafe_obstacle");
			end
			entity.AI.bStrafing = true;
		else
			AI.Signal(SIGNALFILTER_SENDER,1,"STRAFE_POINT_REACHED",entity.id);
		end
	end,
	
--	DodgeAndHide = function(self,entity,sender,data)
--		-- data.ObjectName = type of object to hide near to 
--		local range;
--		if(data and data.fValue>0) then 
--			range = data.fValue;
--		else
--			range = 3;
--		end;
--		range = random(1,range)/3+1;
--		FastScaleVector(g_Vectors.temp_v1,entity:GetDirectionVector(0), range*(random(1,2)*2-3));
--		FastSumVectors(g_Vectors.temp, entity:GetWorldPos(), g_Vectors.temp_v1);
--		AI.SetRefPointPosition(entity.id,	g_Vectors.temp);
--		--System.Log(entity:GetName().." HIDING NEAR "..data.ObjectName);
--		entity:SelectPipe(0,"tr_hide_near",data.ObjectName);
--		entity:InsertSubpipe(0,"tr_dodge");
--	end,
		

	------------------------------------------------------------------------

	USE_FREEZE_WEAPON = function(self,entity,sender)
		if(AI.GetTargetType(entity.id) == AITARGET_ENEMY) then 
			entity:InsertSubpipe(0,"tr_use_freeze_weapon");
		end
	end,
	------------------------------------------------------------------------

	SELECT_FREEZE_WEAPON = function(self,entity,sender)
		ItemSystem.SetActorItemByName(entity.id,"MOAR",false);
	end,

	------------------------------------------------------------------------

	SELECT_NORMAL_WEAPON = function(self,entity,sender)
		ItemSystem.SetActorItemByName(entity.id,"LightMOAC",false);
	end,
	
	------------------------------------------------------------------------

	GROUP_CLOAK = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_GROUPONLY,0,"CLOAK",entity.id);
	end,
	------------------------------------------------------------------------

	CLOAK = function(self,entity,sender)
		entity:Event_Cloak();
	end,
	------------------------------------------------------------------------

	GROUP_UNCLOAK = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_GROUPONLY,0,"UNCLOAK",entity.id);
	end,
	------------------------------------------------------------------------

	UNCLOAK = function(self,entity,sender)
		entity:Event_UnCloak();
	end,
	
	---------------------------------------------
	ORDER_ACQUIRE_TARGET = function(self , entity, sender, data)
		if(data.id ~= NULL_ENTITY) then
			entity:InsertSubpipe(0,"acquire_target",data.id);
		else
			entity:InsertSubpipe(0,"acquire_target",data.ObjectName);
		end
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,

	---------------------------------------------
	START_CONFUSED = function(self , entity, sender)
		-- play short-circuit animation
		entity:Cloak(0);
		entity:Readibility("REBOOT",1);
		--entity.actor:QueueAnimationState("trooper_rebootLoop");
	end,

	---------------------------------------------
	END_CONFUSED = function(self , entity, sender)
		-- stop short-circuit animation
		entity:Readibility("END_REBOOT",1);
		if(AI.GetGroupTarget(entity.id)) then
			g_SignalData.iValue = LAS_ATTACK_FRONT;
			AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_ATTACK", entity.id,g_SignalData);
		end

	end,

	---------------------------------------------
	LOOK_CLOSER = function(self , entity, sender, data)
		if(data.id ~= NULL_ENTITY) then 
			entity:SelectPipe(0,"tr_look_closer_lastop",data.id);
		elseif(data.ObjectName ~= "") then 
			entity:SelectPipe(0,"tr_look_closer_lastop",data.ObjectName);
		end
	end,
	
	---------------------------------------------
	GO_THREATEN = function(self , entity, sender, data)
		entity:Cloak(0);
		entity:MakeAlerted();

--		entity.actor:QueueAnimationState("trooper_threaten");
		entity:Readibility("FIRST_HOSTILE_CONTACT",1,1);
		entity:SelectPipe(0,"tr_threatened_2_attack");
	end,


	---------------------------------------------
	OnCoordinatedFire1 = function(self,entity,sender,data)
		local leader = AI.GetLeader(entity.id);
		if(leader) then 
			entity:SelectPipe(0,"acquire_target",sender.id);
			entity:InsertSubpipe(0,"ignore_all");
			entity:InsertSubpipe(0,"stop_fire");
			entity.actor:QueueAnimationState("LandIdle");
		end
	end,
	
	---------------------------------------------
	COLLECT_FIRE = function(self,entity,sender)
		-- shoot a ray to the sender (coordinator)
		-- to do: use the proper fx
--		self:SetAttachmentEffect(0, "weapon_effect", "Alien_Weapons.Freeze_Beam.Hunter_Firemode1", g_Vectors.v000, g_Vectors.v010, 1, 0, 0);
	end,

	---------------------------------------------
	END_COLLECT_FIRE = function(self,entity,sender)
		-- to do: stop the fx
		entity:SelectPipe(0,"ignore_none");
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
		entity.actor:QueueAnimationState("VertIdle");
	end,

	---------------------------------------------
	ACT_GOTO = function( self, entity, sender, data )
		if ( data and data.point ) then
			AI.SetRefPointPosition( entity.id, data.point );

			-- use dynamically created goal pipe to set approach distance
			g_StringTemp1 = "action_goto"..data.fValue;
			AI.BeginGoalPipe(g_StringTemp1);
				AI.PushGoal("locate", 0, "refpoint");
				AI.PushGoal("+stick", 1, data.point2.x, AILASTOPRES_USE, 1);--, data.fValue);	-- noncontinuous stick
--				AI.PushGoal("tr_check_prone_and_stick",1);
				AI.PushGoal("branch", 0, "NO_PATH", IF_NO_PATH );
				AI.PushGoal("branch", 0, "END", BRANCH_ALWAYS );
				AI.PushLabel("NO_PATH" );
				AI.PushGoal("signal", 1, 1, "CANCEL_CURRENT",0);
				AI.PushLabel("END" );
				AI.PushGoal("signal", 1, 1, "END_ACT_GOTO",0);
			AI.EndGoalPipe();
			
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, g_StringTemp1, nil, data.iValue );
		end
	end,
	
	---------------------------------------------
	SET_FIRE_READIBILITY= function( self, entity, sender)
		if(entity.AI.FireMode==1) then 
			entity:Readibility("FIREMODE2",1);
		else
			entity:Readibility("FIREMODE1",1);
		end
	end,

	---------------------------------------------
	SET_FIRE_MODE = function( self, entity, sender, data)
		local mode = data.iValue;
		entity.AI.FireMode = mode;
		local item = entity.inventory:GetCurrentItem();
		if (item and item.weapon) then
			if(mode ==1) then 
				item.weapon:SetCurrentFireMode("Automatic");
			else
				item.weapon:SetCurrentFireMode("Rapid");
			end
		else
			System.Warning("ITEM NOT FOUND");
		end		
	end,
	
	---------------------------------------------
	RANDOM_FIGHT_SOUND = function( self, entity, sender)
			if(random(1,6)==1) then 
				entity.iSoundTimer = Script.SetTimerForFunction(random(3000,4000),"Trooper_x.PlayFightSound",entity);
			end
	end,
	
	
	
	---------------------------------------------	
	TR_NORMALATTACK = function (self, entity, sender)
		Trooper_StickPlayerAndShoot(entity);
	end,

	---------------------------------------------
	LOOK_FOR_TARGET = function (self, entity, sender)
		AI.GetAttentionTargetPosition(entity.id,g_SignalData.point);
		AI.GetAttentionTargetDirection(entity.id,g_SignalData.point2);
		AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_SEARCH",entity.id,g_SignalData);
	end,	
	
	---------------------------------------------
	JUMP_TO = function (self, entity, sender,data)
		-- data.point = destination point
		-- data.fValue = initial additional angle (degrees)
		
		if(Trooper_Jump(entity,data.point,true,true,data.fValue)) then
			entity.AI.FGJump = true;
		else
			entity.AI.FGJumpFail = true;
		end

	end,

	---------------------------------------------
	ACT_DUMMY= function (self, entity, sender,data)
		if(entity.AI.FGJump) then
			entity.AI.FGJump = false;
			entity:InsertSubpipe(0,"tr_wait_land",nil, data.iValue);
		elseif(entity.AI.FGJumpFail) then
			entity.AI.FGJumpFail = false;
			entity:InsertSubpipe(0,"tr_wait_land",nil, data.iValue);
			entity:CancelSubpipe(data.iValue);
		else
			AIBehaviour.DEFAULT:ACT_DUMMY(entity,sender,data);
		end
	end,
	
	--------------------------------------------------
	-- TrooperLeader related
	--------------------------------------------------
	
	OnResetFormationUpdate = function(self,entity,sender)
		AI.SetFormationUpdate(entity.id,false);
	end,

	--------------------------------------------------
	OnSetFormationUpdate = function(self,entity,sender)
		AI.SetFormationUpdate(entity.id,true);
	end,
	
	--------------------------------------------------
	OnLeaderActionCompleted = function(self,entity,sender,data)
		-- data.iValue = Leader action type
		-- data.iValue2 = Leader action subtype
		-- data.id = group's live attention target 
		-- data.ObjectName = group's attention target name
		-- data.fValue = target distance
		-- data.point = enemy average position
		------System.Log("-----------------------------End LEader ACTION "..data.iValue.." "..data.iValue2);
		Trooper_ChooseNextTactic(entity,data,false);
	end,

	--------------------------------------------------
	OnLeaderActionFailed = function(self,entity,sender,data)
		-- data.iValue = Leader action type
		-- data.iValue2 = Leader action subtype
		-- data.id = group's live attention target 
		-- data.ObjectName = group's attention target name
		-- data.fValue = target distance
		-- data.point = enemy average position

		Trooper_ChooseNextTactic(entity,data,true);
	end,

	--------------------------------------------------
	OnAttackRequestFailed = function(self,entity,sender,data)
		-- data.iValue = failed attack action (LAS_*)
		Trooper_ChooseNextTactic(entity,data,true);
	end,

	---------------------------------------------
	OnExplosionDanger = function(self,entity,sender,data)
		--data.id = exploding entity
		--if(data and data.id ~=NULL_ENTITY) then 
			--AI.Signal(SIGNALIFLTER_LEADER,10,"OnUnitBusy",entity.id);
			--entity:InsertSubpipe(0,"tr_backoff_from_explosion",data.id);
		--end
	end,
	
	---------------------------------------------
	OnExplosion = function(self,entity,sender,data)
		entity:CancelSubpipe();
	end,


	--------------------------------------------------
	
	ACT_PUSH_OBJECT = function(self,entity,sender,data)
		-- data.id = pushable object id
		local object = System.GetEntity(data.id);
		if(object) then
			local objectpos = object:GetPos();
			local dir = g_Vectors.temp_v1;
			
			CopyVector(dir, entity:GetDirectionVector(0));

			if (random(1,2)==1) then 
				dir.x = -dir.x;
				dir.y = -dir.y;
				dir.z = -dir.z;
			end
			local maxdist = 10;
			ScaleVectorInPlace(dir,maxdist);
			local bbmin_cache = {};
			local bbmax_cache = {};
			local bbmin,bbmax = object:GetLocalBBox(bbmin_cache, bbmax_cache);	
			local volumeVec = g_Vectors.temp_v2;
			SubVectors(volumeVec,bbmin,bbmax);
			
			local dist = self:GetApproximateThrowDistance(object,dir,volumeVec,maxdist);
			if(dist<3) then 
				dir.x = -dir.x;
				dir.y = -dir.y;
				dir.z = -dir.z;
				dist = self:GetApproximateThrowDistance(object,dir,volumeVec,maxdist);
				if(dist<3) then 
--					System.Log("DISTANCE = "..dist.." FAILED");
					return;
				end
			end
			-- tweak, less velocity for heavier objects
			local mass = object.Properties.Physics.Mass;
			local maxmass = 100;
			if(mass> maxmass or mass <=0) then 
				return;
			end
			local amount = 9 - mass/maxmass*5;
			if(amount<5) then 
				amount = 5;
			end
			volumeVec.x = 0;
			volumeVec.y = 0;
			volumeVec.z = volumeVec.z/2;
			-- to do: Ckeck zero G? (in the code: bool CActor::CheckZeroG(Vec3 &ZAxis))
			dir.z = dir.z + maxdist*mass/maxmass;
			object:AddImpulse(-1,volumeVec, dir, mass*amount, 1);

		end
	end,	
	
	----------------------------------------------------------
	GetApproximateThrowDistance = function (self,object,dir,volumeVec,maxdist)
		local Zdisp = 0.3;
		local raypos = g_Vectors.temp_v2;
		CopyVector(raypos, object:GetPos());
		raypos.z = raypos.z+Zdisp;
		local rayfilter = ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid;
		local dist = 0;
		-- do an approximate collision check 
		local hits = Physics.RayWorldIntersection(raypos,dir,2, rayfilter ,object.id,nil,g_HitTable);
		if(hits>0) then
			dist = dist + g_HitTable[1].dist;
		else
			dist = dist + maxdist;
		end
		
		raypos.y = raypos.y + volumeVec.y;
--		hits = Physics.RayWorldIntersection(raypos,dir,2,rayfilter ,object.id,nil,g_HitTable);
--		if(hits>0) then
--			dist = dist + g_HitTable[1].dist;
--		else
--			dist = dist + maxdist;
--		end

		raypos.z = raypos.z + volumeVec.z;
		hits = Physics.RayWorldIntersection(raypos,dir,2,rayfilter ,object.id,nil,g_HitTable);
		if(hits>0) then
			dist = dist + g_HitTable[1].dist;
		else
			dist = dist + maxdist;
		end

--		raypos.y = raypos.y - volumeVec.y;
--		hits = Physics.RayWorldIntersection(raypos,dir,2,rayfilter ,object.id,nil,g_HitTable);
--		if(hits>0) then
--			dist = dist + g_HitTable[1].dist;
--		else
--			dist = dist + maxdist;
--		end

--		return dist/4;
		return dist/2;
	end,
	
--	---------------------------------------------
--	ChooseAttack = function(self,entity,sender)
--		if(not entity.AI.ChosenTactic) then 
--			entity.AI.ChosenTactic = random(1,100);
--		end
--		local prob = entity.AI.ChosenTactic;
--		local defend = false;
--		local behaviorTable = entity.Properties.Behavior;
--		if(prob < behaviorTable.Melee and AI.GetTargetType(entity.id)==AITARGET_ENEMY) then 
--			AI.LogEvent("Trooper "..entity:GetName().." chosing melee attack");
--			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_MELEE",entity.id);
--			return;
--		elseif(prob < behaviorTable.Defend + behaviorTable.Melee) then 
--			if(not entity.AI.DefensePoint) then
--				entity.AI.DefensePoint = {x=0,y=0,z=0};
--			end
--			local anchorname = AI.FindObjectOfType(entity.id,20, AIAnchorTable.COMBAT_PROTECT_THIS_POINT,AIFAF_INCLUDE_DEVALUED,entity.AI.DefensePoint);
--			if(anchorname and anchorname~="") then
--				--Log("TROOPER CHOOSEs DEFEND");
--				AI.LogEvent("Trooper "..entity:GetName().." defending point "..anchorname);
--				AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_DEFENSE",entity.id);
--				return;
--			end
--		end
--			-- standard attack
----		if(AI.GetLeader(entity.id)) then 
----			AI.LogEvent("Trooper "..entity:GetName().." chosing switch position attack");
----			AI.Signal(SIGNALFILTER_SENDER,0,"OnAttackSwitchPosition",entity.id);
----		else
--			AI.LogEvent("Trooper "..entity:GetName().." chosing range attack");
--			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ATTACK",entity.id);
----		end
--	end,	


	--------------------------------------------------	
	OnOutOfAmmo = function (self,entity, sender)
		-- player would not have Reload implemented
		if(entity.Reload == nil)then
			do return end
		end
		entity:Reload();
	end,

	
	--------------------------------------------------	
	DODGE_OK = function(self,entity,sender)

		entity.AI.lastDodgeTime = _time;
--		local r = g_Vectors.temp;
----		CopyVector(r,AI.GetRefPointPosition(entity.id));
----		Trooper_Jump(entity,r,false,false,-5);
--		CopyVector(r,entity:GetPos());
--		r.z = r.z + 0.2;
--		--Trooper_Jump(entity,r,false,false);
--		local velocity = g_Vectors.temp_v1;
--		local t = AI.CanJumpToPoint(entity.id,r,90,10,0,velocity);
--		if(t) then 
--			entity.actor:SetParams({jumpTo = r, jumpVel = velocity, jumpTime = t});
--			entity:SetTimer(TROOPER_END_JUMP_DODGE_TIMER,t*400);
--		end
	end,

--	DODGE_IMPULSE_RIGHT	 = function(self,entity,sender)
--		local dir = g_Vectors.temp;
--		CopyVector(dir,entity:GetDirectionVector(0));
--		local mass = entity:GetMass();
--		local amount = 8;
--		dir.z = dir.z + 0.2;
--		entity:AddImpulse(-1,pos, dir, mass*amount, 1);	
--	end,
--
--	DODGE_IMPULSE_LEFT	 = function(self,entity,sender)
--		local dir = g_Vectors.temp;
--		CopyVector(dir,entity:GetDirectionVector(0));
--		local mass = entity:GetMass();
--		NegVector(dir);
--		local amount = 8;
--		dir.z = dir.z + 0.2;
--		entity:AddImpulse(-1,pos, dir, mass*amount, 1);	
--	end,

	--------------------------------------------------
	CHECK_LOWER_TARGET = function(self,entity,sender)
		local target = AI.GetAttentionTargetEntity(entity.id,true);
		if(target) then 
			local myPos = g_Vectors.temp;
			CopyVector(myPos,entity:GetPos());
			local diffHeight = myPos.z - target:GetPos().z ;
			if(random(1,100)<50 and not Trooper_LowHealth(entity)) then
				-- trooper is in a higher position
				if(diffHeight>2.5 and Trooper_CheckJumpMeleeFromHighSpot(entity)) then 
					return;
				end
			end
			if(entity:GetDistance(target.id) > 15 or diffHeight <= 2.5) then 
				local navType = AI.GetNavigationType(AI.GetAttentionTargetEntity(entity.id).id,UPR_COMBAT_GROUND);
				entity.AI.targetNavType = navType;
				if(navType == NAV_WAYPOINT_HUMAN ) then
					AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ATTACK",entity.id);
				else
					AI.Signal(SIGNALFILTER_SENDER,0,"OnAttackSwitchPosition",entity.id);
				end
			else
				if(entity.AI.usingMoar) then 
					entity:SelectPipe(0,"tr_keep_position_moar");
				else
					entity:SelectPipe(0,"tr_keep_position");
				end
				entity:InsertSubpipe(0,"start_fire");
			end
		else
--			entity:SelectPipe(0,"tr_seek_target");
			local dummyTargetOwner = AI.GetAttentionTargetEntity(entity.id);
			if(dummyTargetOwner) then 
				local navType = AI.GetNavigationType(dummyTargetOwner.id);
				entity.AI.targetNavType = navType;
				if(navType == NAV_WAYPOINT_HUMAN ) then
					AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ATTACK",entity.id);
				else
					AI.Signal(SIGNALFILTER_SENDER,0,"OnAttackSwitchPosition",entity.id);
				end
			else
				-- boh
				AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
			end
		end
	end,

	
	--------------------------------------------------
	CHECK_TARGET_VISIBILITY = function(self,entity,sender,data)
		-- data.point = jump land S.O. helper
		local viewPos = g_Vectors.temp;
		local vDir = g_Vectors.temp_v1;
		local targetPos = g_Vectors.temp_v2;
		--FastSumVectors(viewPos,data.point,self.gameParams.stance[1].viewOffset);
		CopyVector(viewPos,data.point);
		viewPos.z = viewPos.z + 1.5;
		if(not AI.GetAttentionTargetPosition(entity.id,targetPos)) then
			return
		end
		FastDifferenceVectors(vDir,targetPos,viewPos);
		local	hits = Physics.RayWorldIntersection(viewPos,vDir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,nil,nil,g_HitTable);
		if(hits >0) then
			return
		end
		--AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_SHOOT_ON_SPOT",entity.id,data);
		AI.SetRefPointPosition(entity.id,data.point);
		AI.ModifySmartObjectStates(entity.id,"ShootSpotFound");
		entity:SelectPipe(0,"tr_jump_on_spot","refpoint");
	end,
	
	--------------------------------------------------
	ADD_SHOOT_SPOT = function(self,entity,sender,data)
		AI.Signal(SIGNALFILTER_LEADER,10,"OnShootSpotFound",entity.id,data);
	end,

	--------------------------------------------------
	REMOVE_SHOOT_SPOT = function(self,entity,sender,data)
		AI.Signal(SIGNALFILTER_LEADER,10,"OnShootSpotNotFound",entity.id,data);
	end,

	--------------------------------------------------
	OnBehind = function(self,entity,sender,data)
		entity.AI.bBehind = true;
	end,

	--------------------------------------------------
	OnNotBehind = function(self,entity,sender,data)
		entity.AI.bBehind = false;
	end,

	

	--------------------------------------------------
	JUMP_ON_ROCK = function (self,entity,sender,data)
--		if(Trooper_IsJumping(entity)) then 
		if(entity.actor:IsFlying() or AI.GetGroupCount(entity.id,GROUP_ENABLED,AIOBJECT_PUPPET)<1) then 
			AI.ModifySmartObjectStates(data.id,"-Busy");				
			return;
		end

		if(entity.AI.usingMoar and not Trooper_CanFireMoar(entity)) then 
			AI.ModifySmartObjectStates(data.id,"-Busy");				
			return;
		end
		
		entity:SetJumpSpecialAnim(JUMP_ANIM_LAND,AIANIM_ACTION,"stayOnRock");
		local dest = g_Vectors.temp;
		CopyVector(dest,data.point);
		dest.z = dest.z+0.5;
		if(Trooper_Jump(entity,dest,true,true,15,true)) then 
			local t = entity.AI.jumpTime;
			if(not entity.AI.jumpPos) then
				entity.AI.jumpPos = {};
			end
			CopyVector(entity.AI.jumpPos,data.point);
			if(t > 0.3) then
				t = 0.3;
			end
			entity.actor:SetParams({landPreparationTime = t});
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ON_ROCK",entity.id);
			entity:InsertSubpipe(0,"stop_fire");
			entity.AI.spotEntityId = data.id;
			entity.AI.noDamageImpulse = true;
		else
			AI.ModifySmartObjectStates(data.id,"-Busy");				
		end
	--	end
	end,

	--------------------------------------------------
	JUMP_ON_WALL = function (self,entity,sender,data)
--		if(Trooper_IsJumping(entity)) then 
		local entityAI = entity.AI;
		if(entityAI.failedSpotEntityId == data.id and (_time - entityAI.failedSpotTime) <2) then
			AI.ModifySmartObjectStates(data.id,"-Busy");				
			return;
		end		
		if(entity.actor:IsFlying() or AI.GetGroupCount(entity.id,GROUP_ENABLED,AIOBJECT_PUPPET)<1) then 
			AI.ModifySmartObjectStates(data.id,"-Busy");				
			return;
		end

		if(entityAI.usingMoar and not Trooper_CanFireMoar(entity)) then 
			AI.ModifySmartObjectStates(data.id,"-Busy");				
			return;
		end

		if(AI.SmartObjectEvent("OnWall",entity.id,data.id) ~= 0) then
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ON_WALL",entity.id);
			entityAI.spotEntityId = data.id;
			entityAI.noDamageImpulse = true;
		else
			entityAI.failedSpotEntityId = data.id;
			entityAI.failedSpotTime = _time;
			--AI.Signal(SIGNALFILTER_SENDER,1,"JUMP_ON_WALL_FAILED",entity.id);
			AI.ModifySmartObjectStates(data.id,"-Busy");				
		end
	--	end
	end,


	--------------------------------------------------
	JUMP_OFF = function (self,entity,sender,data)
		entity.AI.lastJumpTime = _time;
		
		local vel = g_Vectors.temp;
		entity:GetVelocity(vel);
		-- project in 2D (x,z)
		local vX = math.sqrt(vel.y*vel.y + vel.x*vel.x);
		
	end,
	--------------------------------------------------
	CHECK_FIRE = function (self,entity,sender)
		if(AI.GetGroupTargetCount(entity.id,true)>1) then 
			entity:InsertSubpipe(0,"start_fire");
		else
			entity:InsertSubpipe(0,"stop_fire");
		end
	end,
	
	--------------------------------------------------
	OnPlayerFrozen = function (self,entity,sender)
		entity.AI.targetFrozenTime = _time;
		if(entity.AI.usingMoar) then 
			entity:SelectPipe(0,"tr_approach_target_timeout");
			if(g_localActor == AI.GetAttentionTargetEntity(entity.id) and not g_localActor.AI.bFrozenNotified) then 
				g_localActor.AI.bFrozenNotified = true;
				if(AI.GetAttentionTargetDistance(entity.id)<6) then
					entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"tr_random_timeout");
				end
				entity.AI.bGoingToShatterPlayer = true;
--			else
--				entity:InsertSubpipe(0,"medium_timeout");
--				entity:InsertSubpipe(0,"stop_fire");
			end
		end
	end,
	
	--------------------------------------------------
	OnPlayerUnFrozen = function (self,entity,sender)
		if(entity.AI.bGoingToShatterPlayer) then 
			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
			entity.AI.bGoingToShatterPlayer = false;
		end
		g_localActor.AI.bFrozenNotified = false;
	end,

	--------------------------------------------------
	REQUEST_NEW_POINT = function (self,entity,sender)
		if(AI.GetTargetType(entity.id)~=AITARGET_ENEMY) then 
			entity:SelectPipe(0,"tr_seek_target");
		else
			entity:SelectPipe(0,"tr_keep_position");
		end
		
		CopyVector(g_SignalData.point,AI.GetRefPointPosition(entity.id));
		g_SignalData.iValue = AI_BACKOFF_FROM_TARGET;
		g_SignalData.fValue = 8;
		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdateAlternative",entity.id,g_SignalData);
	end,
	
	
	--------------------------------------------------
	RETREAT_FAILED = function(self,entity,sender)
		AI.ModifySmartObjectStates(entity.id,"-StayOnGround");
		g_SignalData.iValue = -AI_BACKOFF_FROM_TARGET;
		g_SignalData.fValue = TROOPER_SAFE_DISTANCE;
		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id, g_SignalData);
		AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK",entity.id);
	end,

	---------------------------------------------------------------------
	NEW_SPAWN = function(self,entity,sender,data)
--		entity:SelectPipe(0,"do_it_standing");	
		AIBehaviour.DEFAULT:NEW_SPAWN(entity,sender,data);
	end,
	
	---------------------------------------------------------------------
	MELEE_ONGOING = function(self,entity,data)
	  AIBlackBoard.lastTrooperMeleeTime = _time;
	end,
	
	--------------------------------------------------
	START_FIRE_MOAR = function( self, entity, sender)
		if(Trooper_CanFireMoar(entity)) then 
			entity.AI.firingMoar = true;
			entity:InsertSubpipe(0,"tr_start_fire_moar");
		else
--			local d = AI.GetAttentionTargetDistance(entity.id);
				--g_SignalData.fValue = 12;
			AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdate",entity.id);
		end
	end,

	--------------------------------------------------
	UPDATE_FIRE_MOAR_STATS = function( self, entity, sender)
		Trooper_UpdateMoarStats(entity);
	end,
	
	--------------------------------------------------

	
	--------------------------------------------------
	OnCallReinforcements = function(self,entity,sender,data)
--		local leader = AI.GetLeader(entity.id);
--		if(sender == leader) then 
--			AI.SetLeader(entity.id);
--		end
		
		if(not entity.AI.reinforcementsReceived ) then 
--			if(AI.GetGroupCount( entity.id, GROUP_ENABLED, AIOBJECT_PUPPET ) ==1) then 
				
				--AI.Signal(SIGNALFILTER_SUPERSPECIES,1,"TROOPER_CALL_REINFORCEMENT",entity.id);
				local spot = System.GetEntity(data.id);
	--			entity.AI.reinfSpotId = nil;
				if (spot) then
					spot:TriggerEvent(AIEVENT_DISABLE);
					BroadcastEvent(spot, "Called");
				end
	
				entity.AI.waitingReinforcements = true;
--			end
		end
	end,	
	
	--------------------------------------------------
	GO_REINFORCEMENT= function(self,entity,sender,data)
		AI.SetBeaconPosition(entity.id,sender:GetPos());
		AI.Signal(SIGNALFILTER_GROUPONLY,1,"GO_REINFORCEMENT_GUYS",entity.id);

	end,
	--------------------------------------------------
	GO_REINFORCEMENT_GUYS = function(self,entity,sender,data)
		
--			local senderGroup = data.iValue;
--			AI.ChangeParameter(entity.id,AIPARAM_GROUPID,senderGroup);
		if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_ATTACK",entity.id);
		else
			g_SignalData.iValue =1;--rush mode
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_INTERESTED",entity.id,g_SignalData);
		end
	end,
	
	--------------------------------------------------
	IS_PLAYER_ENGAGED = function(self,entity,sender)
	end,

	--------------------------------------------------
	PLAYER_ENGAGED = function(self,entity,sender)
	end,
	
	--------------------------------------------------
	MELEE_FAILED = function( self, entity, sender)
		Trooper_ChooseAttack(entity);
		AI.ModifySmartObjectStates(entity.id,"-StayOnGround");
	end,

	--------------------------------------------------
	MELEE_OK = function( self, entity, sender)
	--	Trooper_ChooseAttack(entity);
	
	end,
	
	--------------------------------------------------
	END_MELEE = function(self,entity,sender)
		AI.ModifySmartObjectStates(entity.id,"-StayOnGround");
	end,

	
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender,data)
	end,
	
	--------------------------------------------------
	OnGroupMemberDied = function ( self, entity, sender,data)
	end,
	
	--------------------------------------------------
	OnFallAndPlay = function(self,entity,sender)
		--entity:SelectPipe(0,"tr_grabbed");
		local sndFlags = bor(SOUND_DEFAULT_3D);
    entity.grabbedSound = entity:PlaySoundEvent("sounds/alien:trooper:choke",g_Vectors.v000, g_Vectors.v010, sndFlags, SOUND_SEMANTIC_AI_READABILITY);
--		entity.timerGrabbedSound = entity:SetTimer(TROOPER_PLAYERGRABBED_TIMER,5000+random(1,1000));
	end,

	--------------------------------------------------
	REQUEST_CONVERSATION = function(self,entity,sender)
		if(entity.Behaviour.hasConversation and entity.cloaked~= 1) then 
			local numMembers = AI.GetGroupCount(entity.id,GROUP_ENABLED,AIOBJECT_PUPPET);
			if(numMembers>1 and entity:GetDistance(g_localActor.id)>5 and 
				AIBlackBoard.trooper_ConversationState == TROOPER_CONV_REQUESTING) then
				if(entity.Behaviour.search) then 
					entity:Readibility("search_call");
				else
					entity:Readibility("call");
				end
				--System.Log(entity:GetName().." CALLING");
				sender:SetTimer(TROOPER_CONVERSATION_ANSWER_TIMER,random(1500,2000));
				AIBlackBoard.trooper_ConversationState = TROOPER_CONV_IDLE;
			elseif(numMembers==1) then-- and AI.GetAttentionTargetEntity(entity.id) == g_localActor) then 
				if(entity.Behaviour.search) then 
					entity:Readibility("search_call");
				else
					entity:Readibility("call");
				end
				AIBlackBoard.trooper_ConversationState = TROOPER_CONV_IDLE;
			end
			Trooper_SetConversation(entity);
		end
	end,

	--------------------------------------------------
	CONVERSATION_ANSWER= function(self,entity,sender)
		if(entity.Behaviour.hasConversation) then 
				if(entity.Behaviour.search) then 
					entity:Readibility("search_call_respond",1,100);
				else
					entity:Readibility("call_respond",1,100);
				end
			--System.Log(entity:GetName().." ANSWERING");
			AIBlackBoard.trooper_ConversationState = TROOPER_CONV_IDLE; 
		end
	end,
	
	--------------------------------------------------
	REQUEST_MOVE_TARGET_DIRECTION = function(self,entity,sender)
		g_SignalData.iValue = AI_MOVE_BACKWARD+AI_USE_TARGET_MOVEMENT;

		AI.Signal(SIGNALFILTER_LEADER,10,"OnRequestUpdateTowards",entity.id,g_SignalData);
	end,


	--------------------------------------------------
	CHECK_DODGE = function(self,entity,sender,data)
		Trooper_Dodge(entity,nil,data.iValue);
	end,
	
	--------------------------------------------------
	--- TEST STUFF
	--------------------------------------------------
	STRAFE  = function(self,entity,sender)
		AI.BeginGoalPipe("tr_strafe");
		AI.PushGoal("strafe",1,10);
		AI.EndGoalPipe();
		
		entity:InsertSubpipe(0,"tr_strafe");
	end,


	LOOKAT = function(self,entity,sender)
		AI.BeginGoalPipe("tr_lookat");
		AI.PushGoal("acqtarget",1,"P");
		--AI.PushGoal("lookat",1,0,0,true,1);
		AI.PushGoal("timeout",1,60.0);
		AI.EndGoalPipe();
		
		entity:InsertSubpipe(0,"tr_lookat");
	end,

	MELEE_GO = function(self,entity,sender)
		AI.BeginGoalPipe("tr_melee_go");
		AI.PushGoal("locate",1,"P");
		AI.PushGoal("stick",0,0,AILASTOPRES_USE);
		AI.PushGoal("timeout",1,3.0);
		AI.PushGoal("animation",0,AIANIM_SIGNAL,"meleeAttack");
		AI.PushGoal("timeout",1,6.0);
		
		AI.EndGoalPipe();
		
		entity:SelectPipe(0,"tr_melee_go");
	end,
	
	FIRE = function(self,entity,sender)
		entity:InsertSubpipe(0,"start_fire");
	end,
	

	TEST_STICK = function( self, entity, sender,data)
		entity:SelectPipe(0,"tr_stick",data.id);
		AI.Signal(0,1,"GO_TO_ALERTED",entity.id);
	end,

	TEST_SEARCH = function( self, entity, sender,data)
		--entity.AI.lookDir = {x=0,y=1,z=0};
		entity.AI.lookDir = {};
		CopyVector(entity.AI.lookDir,System.GetEntityByName("P1"):GetDirectionVector(1));
		AI.BeginGoalPipe("tr_order_search1");
			----
			AI.PushGoal("bodypos", 1, BODYPOS_STAND);
			AI.PushGoal("firecmd", 0,0);
			AI.PushGoal("pathfind", 1, "P1");
			AI.PushGoal("branch", 1, "PATH_FOUND", NOT+IF_NO_PATH);
				AI.PushGoal("signal",0,1,"OnUnitStop",SIGNALFILTER_LEADER);		
				AI.PushGoal("branch", 1, "DONE", BRANCH_ALWAYS);
			AI.PushLabel("PATH_FOUND");
			AI.PushGoal("signal",0,1,"OnUnitMoving",SIGNALFILTER_LEADER);		
--			AI.PushGoal("trace",1,1);
			AI.PushGoal("locate", 1, "P1");
			AI.PushGoal("stick", 1, 0, AILASTOPRES_USE, 1, STICK_BREAK);	-- noncontinuous stick

			AI.PushGoal("signal",1,1,"TEST_SEARCH_REACHED",SIGNALFILTER_SENDER);		
			AI.PushGoal("bodypos", 1, BODYPOS_STEALTH);
			AI.PushGoal("locate",0,"refpoint");
			AI.PushGoal("+lookat",1,0,0,1,2);
			AI.PushGoal("lookaround",1,20,3,3,5,AI_BREAK_ON_LIVE_TARGET);
			AI.PushGoal("lookat",1,-500);
			AI.PushLabel("DONE");	
			AI.PushGoal("bodypos", 1, BODYPOS_STAND);
			----------------
			AI.PushGoal("locate", 1, "P");
			AI.PushGoal("stick", 1, 0, AILASTOPRES_USE, 1, STICK_BREAK);	-- noncontinuous stick
			--AI.PushGoal("signal",1,1,"TEST_SEARCH",SIGNALFILTER_SENDER);		

		AI.EndGoalPipe();
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"tr_order_search1");
	end,
	
		---------------------------------------------
	TEST_SEARCH_REACHED = function ( self, entity, sender)
		local pos = g_Vectors.temp;
		CopyVector(pos,entity:GetPos());
		local dir  = entity.AI.lookDir;
		if(not dir) then
			dir = {};
			CopyVector(dir,entity:GetDirectionVector(1));
		end
		ScaleVectorInPlace(dir,4);
		FastSumVectors(pos,pos,dir);
		AI.SetRefPointPosition(entity.id,pos);
	end,


	TEST = function(self,entity,sender)
	AI.BeginGoalPipe("tr_test");
		AI.PushGoal("locate", 1, "P");
		AI.PushGoal("acqtarget", 1, "");
		AI.PushGoal("branch", 1, "OK", IF_TARGET_DIST_GREATER,6);
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("timeout",0,3);
		AI.PushLabel("LOOP");
			AI.PushGoal("branch", 1, "OK", IF_TARGET_DIST_GREATER,6);
			AI.PushGoal("branch", 1, "FAIL",NOT+IF_TARGET_MOVED,1);
			AI.PushGoal("timeout",1,0.2);
		AI.PushGoal("branch", 1, "LOOP", IF_ACTIVE_GOALS);
		AI.PushLabel("OK");
			AI.PushGoal("signal",1,1,"AA",SIGNALFILTER_SENDER);
				AI.PushGoal("branch", 1, "END", BRANCH_ALWAYS);
			AI.PushLabel("FAIL");
				AI.PushGoal("signal",1,1,"BB",SIGNALFILTER_SENDER);
		AI.PushLabel("END");
		AI.PushGoal("firecmd",0,0);
				
	AI.EndGoalPipe();

		
		entity:SelectPipe(0,"tr_test");
	end,

}	

