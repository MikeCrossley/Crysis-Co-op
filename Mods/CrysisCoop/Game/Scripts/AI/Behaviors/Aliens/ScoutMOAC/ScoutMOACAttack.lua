--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2007.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Scout
--  
--------------------------------------------------------------------------
--  History:
--  - 11/12/2004   : Created by Kirill Bulatsev
--  - 05/04/2005   : CXP Rush Clean up by Mikko Mononen
--	- 29/11/2005   : Revised for new attack patterns by Tetsuji Iwasaki
--	- 15/01/2007   : Separated as the MOAC Scout by Tetsuji Iwasaki
--------------------------------------------------------------------------
testflg = 0;
local minUpdateTime = 0.33;

local	fSCOUTMOACATTACK_DONOTHING			= 0;
local fSCOUTMOACATTACK_BASICAPPROACH  = 1;
local fSCOUTMOACATTACK_HOVERINGUP  = 2;
local fSCOUTMOACATTACK_GOAWAY = 3;
local fSCOUTMOACATTACK_JUSTSTAY = 4;
local fSCOUTMOACATTACK_SHOOTSINGULARITY = 5;
local fSCOUTMOACATTACK_CIRCLESTRAFE = 7;

local fSCOUTMOACATTACK_POPUP = 8;
local fSCOUTMOACATTACK_STOP = 9;
local fSCOUTMOACATTACK_SEEKHIDEPOSITION = 10;
local fSCOUTMOACATTACK_HIDE = 11;
local fSCOUTMOACATTACK_UNHIDE = 12;
local fSCOUTMOACATTACK_DIRECTSTRAFE = 13;
local fSCOUTMOACATTACK_DIRECTSTRAFE2 = 14;
local fSCOUTMOACATTACK_LOOPINLOOP = 15;
local fSCOUTMOACATTACK_LINEATTACK = 16;
local fSCOUTMOACATTACK_BACKATTACK = 17;
local fSCOUTMOACATTACK_LINEATTACK2 = 18;
local fSCOUTMOACATTACK_LINEATTACK3 = 19;

local fSCOUTMOACATTACK_DODGE = 20;
local fSCOUTMOACATTACK_TRACEPATHPRE = 21;
local fSCOUTMOACATTACK_TRACEPATH = 22;
local fSCOUTMOACATTACK_CIRCLING = 23;
local fSCOUTMOACATTACK_SHORTDUSH = 24;
local fSCOUTMOACATTACK_JAMMER = 25;
local fSCOUTMOACATTACK_JAMMERDUSH = 26;
local fSCOUTMOACATTACK_FOUNDPLAYER = 27;

local fSCOUTMOACATTACK_VSAIR = 28;
local fSCOUTMOACATTACK_VSAIR2 = 29;
local fSCOUTMOACATTACK_VSAIR3 = 30;
local fSCOUTMOACATTACK_VSAIRPAUSE = 31;
local fSCOUTMOACATTACK_VSAIRCIRCLE = 32;
local fSCOUTMOACATTACK_VSAIRUP = 33;
local fSCOUTMOACATTACK_VSCLOAK = 34;

--------------------------------------------------------------------------
AIBehaviour.ScoutMOACAttack = {
	Name = "ScoutMOACAttack",
	Base = "ScoutMOACDefault",
	alertness = 2,

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		entity:DropObject( true, nil, 0 );
		entity:EnableSearchBeam(false);

		AIBehaviour.ScoutMOACIdle:Constructor( entity );
		
		entity.AI.lastStrafingPitch = -30.0;
		AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, entity.AI.lastStrafingPitch );
--		System.Log("AIPARAM_STRAFINGPITCH "..entity.AI.lastStrafingPitch );
		AI.AutoDisable( entity.id, 0 );
		--entity:Event_UnCloak();

		entity.gameParams.forceView = 0.0;
		entity.actor:SetParams(entity.gameParams);

		-- for the nomal update
		entity.AI.deltaTSystem = System.GetCurrTime();
		entity.AI.memorySec = System.GetCurrTime();
		self:SCOUTMOACATTACK_DONOTHING_START( entity );

		entity.AI.circleSec = System.GetCurrTime();
		entity.AI.vMyPosRsv = {};
		entity.AI.vTargetRsv = {};
		entity.AI.vDirectionRsv = {};
		entity.AI.cosinOp = 0.0;
		entity.AI.ndtime = 0;
		entity.AI.bLock = false;
		entity.AI.bLock2 = false;
		entity.AI.bLock3 = false;

		entity.AI.bRvs = false;
		entity.AI.bBlockSignal = false;
		entity.AI.dodgeCounter = 0;
		entity.AI.pathName = nil;

		CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
		CopyVector( entity.AI.vTargetRsv, entity:GetPos() );
		CopyVector( entity.AI.vDirectionRsv, entity:GetPos() );

		-- for the path trace
		entity.AI.tracePathName = "";
		entity.AI.traceRvs =false;

		-- for the interrupt
		entity.AI.InterruptHook = fSCOUTMOACATTACK_DONOTHING;
		entity.AI.vDirectionRsvInterrupt = {};
		entity.AI.circleSecInterrupt = System.GetCurrTime();
		entity.AI.lastDodgeTime = System.GetCurrTime();
		entity.AI.paramrsvInterrupt = entity.gameParams.forceView;
		entity.AI.bLockInterrupt = 0;
		entity.AI.random = random( 1, 65535 );
		entity.AI.bCloseScout = false;
		entity.AI.vLastEnemyPosition = {};
		entity.AI.bLock2 = false;

		entity.AI.targetAveSpeed = 30.0;
		entity.AI.targetAveSpeed1 = 30.0;
		entity.AI.targetAveSpeed2 = 30.0;
		entity.AI.targetAveSpeed3 = 30.0;
		entity.AI.targetAveSpeed4 = 30.0;

		CopyVector( entity.AI.vLastEnemyPosition, entity:GetPos() );
		CopyVector( entity.AI.vDirectionRsvInterrupt, entity:GetPos() );

		AI.CreateGoalPipe("scoutMOACAttackDefault");
		AI.PushGoal("scoutMOACAttackDefault","timeout",1,0.3);
		AI.PushGoal("scoutMOACAttackDefault","signal",0,1,"SCOUTMOACATTACK_FOUNDPLAYER_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutMOACAttackDefault");

		AI.CreateGoalPipe("ScoutMOACFire");
		AI.PushGoal("ScoutMOACFire","+locate",0,"atttarget");
		AI.PushGoal("ScoutMOACFire","+lookat",0,0,0,true,1);
		AI.PushGoal("ScoutMOACFire","+timeout",1,0.5);
		AI.PushGoal("ScoutMOACFire","firecmd",0,FIREMODE_FORCED);

		AI.CreateGoalPipe("ScoutMOACFire2");
		AI.PushGoal("ScoutMOACFire2","+locate",0,"atttarget");
		AI.PushGoal("ScoutMOACFire2","+lookat",0,0,0,true,1);
		AI.PushGoal("ScoutMOACFire2","firecmd",0,0);
		AI.PushGoal("ScoutMOACFire2","+timeout",1,0.1);
		AI.PushGoal("ScoutMOACFire2","+firecmd",0,FIREMODE_FORCED);
		AI.PushGoal("ScoutMOACFire2","+timeout",1,60.0);

		AI.CreateGoalPipe("ScoutMOACFire3");
		AI.PushGoal("ScoutMOACFire3","+firecmd",0,0);
		AI.PushGoal("ScoutMOACFire3","+locate",0,"atttarget");
		AI.PushGoal("ScoutMOACFire3","+lookat",0,0,0,true,1);
		AI.PushGoal("ScoutMOACFire3","+timeout",1,1.0);
		AI.PushGoal("ScoutMOACFire3","firecmd",0,FIREMODE_FORCED);
		AI.PushGoal("ScoutMOACFire3","+timeout",1,60.0);

		AI.CreateGoalPipe("ScoutMOACFire4");
		AI.PushGoal("ScoutMOACFire4","firecmd",0,FIREMODE_FORCED);
		AI.PushGoal("ScoutMOACFire4","+locate",0,"atttarget");
		AI.PushGoal("ScoutMOACFire4","+lookat",0,0,0,true,1);
		AI.PushGoal("ScoutMOACFire4","+timeout",1,30.0);

		AI.CreateGoalPipe("ScoutMOACLookAt");
		AI.PushGoal("ScoutMOACLookAt","locate",0,"atttarget");
		AI.PushGoal("ScoutMOACLookAt","+lookat",0,0,0,true,1);
		AI.PushGoal("ScoutMOACLookAt","timeout",1,60.0);

		AI.CreateGoalPipe("ScoutMOAC");
		AI.PushGoal("ScoutMOAC","firecmd",0,0);
		AI.PushGoal("ScoutMOAC","+lookat",0,-500,0);
		AI.PushGoal("ScoutMOAC","timeout",1,60.0);

		AI.CreateGoalPipe("ScoutMOACFollowPath");
		AI.PushGoal("ScoutMOACFollowPath","lookat",0,-500,0);
		AI.PushGoal("ScoutMOACFollowPath","run", 1, 1 );
		AI.PushGoal("ScoutMOACFollowPath","firecmd", 1, FIREMODE_FORCED);
		AI.PushGoal("ScoutMOACFollowPath","followpath", 1, false, false, true, 0, 10.0, false );
		AI.PushGoal("ScoutMOACFollowPath","signal",1,1,"SCOUTMOACATTACK_TRACEPATH_END",SIGNALFILTER_SENDER);
		AI.PushGoal("ScoutMOACFollowPath","timeout",1,60.0);

		AI.CreateGoalPipe("ScoutMOACFollowPathRvs");
		AI.PushGoal("ScoutMOACFollowPathRvs","lookat",0,-500,0);
		AI.PushGoal("ScoutMOACFollowPathRvs","run", 1, 1 );
		AI.PushGoal("ScoutMOACFollowPathRvs","firecmd", 1, FIREMODE_FORCED);
		AI.PushGoal("ScoutMOACFollowPathRvs","followpath", 1, false, true, true, 0, 10.0, false );
		AI.PushGoal("ScoutMOACFollowPathRvs","signal",1,1,"SCOUTMOACATTACK_TRACEPATH_END",SIGNALFILTER_SENDER);
		AI.PushGoal("ScoutMOACFollowPathRvs","timeout",1,60.0);

		if ( entity.AI.ascensionScout ~= true ) then
			AI.ChangeParameter(entity.id,AIPARAM_COMBATCLASS,AICombatClasses.Scout);		
		end
	
		entity.AI.scoutTimer = 1;
		Script.SetTimerForFunction( minUpdateTime *1000 , "AIBehaviour.ScoutMOACAttack.SCOUTMOACATTACK_UPDATE", entity );

	end,

	--------------------------------------------------------------------------
	Destructor = function ( self, entity, data )
		entity.AI.tracePathName = "";
		AI.SetForcedNavigation( entity.id, entity.AI.vZero );
		entity.AI.scoutTimer = nil;
	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_RANDOM = function ( self, entity, low, high )
		entity.AI.random = math.mod( entity.AI.random * 5 + 1, 65536 );
		return math.abs( math.mod( entity.AI.random, high - low ) ) + low;
	end,

	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUTMOAC_PATROL",entity.id);
	end,

	--------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender, data )

		local targetEntity;
		if ( data and data.id ) then
			entity.AI.lastShooterId = data.id;
			targetEntity = System.GetEntity( data.id );
			if ( targetEntity and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, targetEntity )==true ) then
			else
				return;
			end
		else
			return;
		end
		
	end,
	
	--------------------------------------------------------------------------
	OnFriendlyDamage = function ( self, entity, sender, data )
		-- mainly if shooted by a friend.
	end,

	--------------------------------------------------------------------------
	OnDamage = function ( self, entity, sender, data )
		-- mainly collide to terrein
	end,

	--------------------------------------------------------------------------
	OnSoreDamage = function ( self, entity, sender, data )
		self:OnEnemyDamage( entity, sender, data );
	end,

	--------------------------------------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		if ( entity.AI.InterruptHook == fSCOUTMOACATTACK_DODGE ) then
			return;
		end

		if ( entity.AI.CurrentHook == fSCOUTMOACATTACK_LOOPINLOOP ) then
			return;
		end

		if ( entity.AI.CurrentHook == fSCOUTMOACATTACK_GOAWAY ) then
			return;
		end

		if ( entity.AI.CurrentHook == fSCOUTMOACATTACK_DIRECTSTRAFE ) then
			return;
		end

		if ( entity.AI.CurrentHook == fSCOUTMOACATTACK_SHOOTSINGULARITY ) then
			return;
		end

		if ( entity.AI.CurrentHook == fSCOUTMOACATTACK_TRACEPATHPRE ) then
			return;
		end

		if ( entity.AI.CurrentHook == fSCOUTMOACATTACK_TRACEPATH ) then
			return;
		end

		if ( entity.AI.CurrentHook == fSCOUTMOACATTACK_FOUNDPLAYER ) then
			return;
		end

		if ( entity.AI.CurrentHook == fSCOUTMOACATTACK_VSAIR ) then
			return;
		end

		if ( entity.AI.CurrentHook == fSCOUTMOACATTACK_VSAIR2 ) then
			return;
		end

		local targetEntity;
		if ( data and data.id ) then
			entity.AI.lastShooterId = data.id;
			targetEntity = System.GetEntity( data.id );
			if ( targetEntity and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, targetEntity )==true ) then
			else
				return;
			end
		else
			return;
		end

		self:SCOUTMOACATTACK_DODGE_START( entity, targetEntity, data.iValue );

	end,	

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_DODGE_START = function( self, entity, targetEntity, bHeavyDamage )

		if ( System.GetCurrTime() - entity.AI.lastDodgeTime < 2.0 ) then
			return;
		end

		entity.AI.dodgeCounter = entity.AI.dodgeCounter + 1;

		if ( entity.AI.dodgeCounter < 3 ) then
		
			if ( entity.AI.CurrentHook == fSCOUTMOACATTACK_VSAIRCIRCLE ) then
					return;
			elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_VSAIRPAUSE ) then
					return;
			end
		
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_CIRCLING ) then
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_SHORTDUSH ) then
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_JAMMER ) then
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_JAMMERDUSH ) then
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_VSAIRCIRCLE ) then
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_VSAIRPAUSE ) then
		else
			entity.AI.dodgeCounter = 0;
			if ( entity.AI.bBlockSignal == false ) then
				local vTmp = {};
				SubVectors( vTmp, targetEntity:GetPos(), entity:GetPos() );
				vTmp.z = 0.0;
				if ( LengthVector( vTmp ) > 20.0 ) then
					entity.AI.bBlockSignal = true;
					self:SCOUTMOACATTACK_POPUP_START( entity );
				end
			end
		end

		local vTmp = {};
		local vFwd = {};
		SubVectors( vFwd, targetEntity:GetPos(), entity:GetPos() );
		vFwd.z = 0.0;

		local vWng = {};
		CopyVector( vWng, entity:GetDirectionVector(0) );
		vWng.z = 0.0;

		local vFwdD = {};
		CopyVector( vFwdD, entity:GetDirectionVector(1) );
		vFwdD.z = 0.0;

		local dotinFront = dotproduct3d( vFwd, vFwdD );
		if ( dotinFront < math.cos( 3.1416 * 45.0 / 180.0 ) ) then
			return;
		end

		local vWng2 = {};
		crossproduct3d( vWng2, entity.AI.vUp, vFwd );
		vWng2.z = 0;

		NormalizeVector( vFwd );
		NormalizeVector( vWng );
		NormalizeVector( vWng2 );

		local animationName;
		if ( entity.AI.bJammer == true ) then
			local vJammer = {};
			SubVectors( vJammer, entity.AI.vJammer, entity:GetPos() );
			NormalizeVector( vJammer );
			if ( dotproduct3d( vJammer, vWng2 ) > 0 ) then
				animationName = "dodgeLeft";
				FastScaleVector( entity.AI.vDirectionRsvInterrupt, vWng, -1.0 );
			else
				animationName = "dodgeRight";
				FastScaleVector( entity.AI.vDirectionRsvInterrupt, vWng, 1.0 );
			end
		else
			if ( dotproduct3d( vFwd, vWng ) > 0 ) then
				animationName = "dodgeLeft";
				FastScaleVector( entity.AI.vDirectionRsvInterrupt, vWng, 1.0 );
			else
				animationName = "dodgeRight";
				FastScaleVector( entity.AI.vDirectionRsvInterrupt, vWng, -1.0 );
			end
		end

		if ( bHeavyDamage == 0 ) then
			entity:GetVelocity( vTmp );
			FastScaleVector( vTmp, vTmp, 0.8 );
			AI.SetForcedNavigation( entity.id, vTmp );
			local res = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearanceMain( entity, vTmp, 1.0, 5.0 );
			if ( res == 0 )then
				AI.Animation(entity.id,AIANIM_SIGNAL,animationName);
				entity.actor:SetNetworkedAttachmentEffect(0, "dodge", "alien_special.scout.dodge", g_Vectors.v000, g_Vectors.v010, 1, 0); 
			end
		end

		entity.AI.paramrsvInterrupt = entity.gameParams.forceView;
		entity.gameParams.forceView = 100.0;
		entity.actor:SetParams(entity.gameParams);
		entity.AI.bLockInterrupt = 0.5 + random( 1.0, 100.0 ) / 100.0 ;
		entity.AI.bLockInterrupt2 = false;
		entity.AI.bLockInterrupt3 = bHeavyDamage;
		FastScaleVector( entity.AI.vDirectionRsvInterrupt, entity.AI.vDirectionRsvInterrupt, 23.0 );
		entity.AI.vDirectionRsvInterrupt.z = random( 1.0, 7.0 );
		entity.AI.circleSecInterrupt = System.GetCurrTime();
		entity.AI.InterruptHook = fSCOUTMOACATTACK_DODGE;
		entity.AI.lastDodgeTime = System.GetCurrTime();


	end,

	SCOUTMOACATTACK_DODGE = function( self, entity )
			
		local vTmp = {};
		CopyVector( vTmp, entity.AI.vDirectionRsvInterrupt );

		local res = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearanceMain( entity, vTmp, 1.0, 5.0 );

		if ( entity.AI.bLockInterrupt3 == 0 ) then
			AI.SetForcedNavigation( entity.id, vTmp );
		end
		
		if ( entity.AI.bLockInterrupt2 == false ) then
			if ( System.GetCurrTime() - entity.AI.circleSecInterrupt > 1.0 ) then
				entity.AI.bLockInterrupt2 = true;
				entity.AI.bLockInterrupt3 = 0;
				if ( entity.AI.bBigRolloff and entity.AI.bBigRolloff == true ) then
					entity.actor:PlayNetworkedSoundEvent("sounds/alien:scout_big_rolloff:dodging", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
				else
					entity.actor:PlayNetworkedSoundEvent("Sounds/alien:scout:dodging", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
				end
			end
		end

		if ( System.GetCurrTime() - entity.AI.circleSecInterrupt > entity.AI.bLockInterrupt ) then
			entity.gameParams.forceView = entity.AI.paramrsvInterrupt;
			entity.actor:SetParams(entity.gameParams);
			entity.AI.InterruptHook = 0;
			return;
		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_UPDATE = function( entity )

		----------------------------------------------------------------
		-- set timers
				
		if ( entity.AI == nil or entity.AI.scoutTimer == nil or entity:GetSpeed() == nil ) then
			local myEntity = System.GetEntity( entity.id );
			if ( myEntity ) then
				local vZero = {x=0.0,y=0.0,z=0.0};
				AI.SetForcedNavigation( entity.id, vZero );
			end
			return;
		end

		if ( entity.id and System.GetEntity( entity.id ) ) then
		else
			local vZero = {x=0.0,y=0.0,z=0.0};
			AI.SetForcedNavigation( entity.id, vZero );
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUTMOAC_IDLE",entity.id);
			return;
		end

		if ( entity:IsActive() and AI.IsEnabled(entity.id) ) then
		else
			local vZero = {x=0.0,y=0.0,z=0.0};
			AI.SetForcedNavigation( entity.id, vZero );
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUTMOAC_IDLE",entity.id);
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then
		else
			AIBehaviour.ScoutMOACAttack:OnNoTarget( entity );
			return;
		end

		local dt = System.GetCurrTime() - entity.AI.deltaTSystem;
		entity.AI.deltaTSystem = System.GetCurrTime();
			
		entity.AI.scoutTimer = 1;
		Script.SetTimerForFunction( minUpdateTime *1000, "AIBehaviour.ScoutMOACAttack.SCOUTMOACATTACK_UPDATE", entity );

		----------------------------------------------------------------
		if ( AI.GetTargetType( entity.id ) == AITARGET_MEMORY ) then
			local bClockedTarget = false;
			if ( target.actor and target.actor:GetNanoSuitMode() == 2 ) then
				if ( entity.AI.CurrentHook ~= fSCOUTMOACATTACK_VSCLOAK ) then
					AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_VSCLOAK_START( entity );
				end
			end
		end

		if ( AI.IsPointInFlightRegion( entity:GetPos() ) == false ) then
			if ( entity.AI.ascensionScout and entity.AI.ascensionScout == true ) then
				if ( entity.AI.CurrentHook ~= fSCOUTMOACATTACK_VSCLOAK ) then
					AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_VSCLOAK_START( entity );
				end
			end
		end


		----------------------------------------------------------------
		if ( entity.AI.bJammer == true ) then
			local vJammer = {};
			CopyVector( vJammer, entity.AI.vJammer );
			SubVectors( vJammer, entity:GetPos(), vJammer );
			local jam = LengthVector( vJammer );
			if ( jam < 30.0 ) then
				if ( entity.AI.bLock2 == false ) then
					entity.AI.bLock2 = true;
					Particle.SpawnEffect("alien_special.scout.Jammer_Reaction", entity:GetPos(), entity:GetDirectionVector(1), 1);		  
				end
				NormalizeVector( vJammer );
				FastScaleVector( vJammer, vJammer, 30.0 );
				AI.SetForcedNavigation( entity.id, vJammer );
				AI.Animation(entity.id,AIANIM_SIGNAL,"largeHit");
				if ( entity.AI.CurrentHook == fSCOUTMOACATTACK_JAMMER ) then
				elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_JAMMERDUSH ) then
				else
					AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_JAMMER_START( entity );
				end
				return;
			else
				if ( entity.AI.bLock2 == true ) then
					Particle.SpawnEffect("alien_special.scout.Jammer_Sphere", entity.AI.vJammer, entity.AI.vUp, 1);		  
				end
				entity.AI.bLock2 = false;
			end
		end

		----------------------------------------------------------------
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then
			if ( AI.GetTargetType( entity.id ) == AITARGET_MEMORY ) then
			else
				entity.AI.memorySec = System.GetCurrTime();
			end
			entity.AI.targetAveSpeed  = entity.AI.targetAveSpeed1 + entity.AI.targetAveSpeed2 + entity.AI.targetAveSpeed3 + entity.AI.targetAveSpeed4;
			entity.AI.targetAveSpeed  = entity.AI.targetAveSpeed * 0.25;
			entity.AI.targetAveSpeed1 = entity.AI.targetAveSpeed2;
			entity.AI.targetAveSpeed2 = entity.AI.targetAveSpeed3;
			entity.AI.targetAveSpeed3 = entity.AI.targetAveSpeed4;
			entity.AI.targetAveSpeed4 = target:GetSpeed();

			local newStrafingPitch = -30.0;

			if ( target.actor ) then
				local vehicleId = target.actor:GetLinkedVehicleId();
				if ( vehicleId ) then
					newStrafingPitch = -3.0;
				end
			end

			if (AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_CAR ) then
				newStrafingPitch = -3.0;
			end

			if ( entity.AI.lastStrafingPitch ~= newStrafingPitch ) then
				 entity.AI.lastStrafingPitch = newStrafingPitch;
				AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, entity.AI.lastStrafingPitch );
--		System.Log("AIPARAM_STRAFINGPITCH "..entity.AI.lastStrafingPitch );
			end

		else
			entity.AI.memorySec = System.GetCurrTime();
		end

		----------------------------------------------------------------

		entity.AI.cosinOp = entity.AI.cosinOp + 30.0*3.1416 / 180.0;
		if ( entity.AI.cosinOp > 3.1416*2.0 ) then
			entity.AI.cosinOp = entity.AI.cosinOp - 3.1416*2.0;
		end

		----------------------------------------------------------------
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then
			CopyVector( entity.AI.vLastEnemyPosition, target:GetPos() );
		end

		----------------------------------------------------------------
		-- interrupt

		if ( entity.AI.InterruptHook > 0 ) then
			if ( entity.AI.InterruptHook == fSCOUTMOACATTACK_DODGE ) then
				AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DODGE( entity );
			end
			return;
		end

		----------------------------------------------------------------
		--System.Log( entity:GetName() );

		if (     entity.AI.CurrentHook == fSCOUTMOACATTACK_DONOTHING ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_DONOTHING" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DONOTHING( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_BASICAPPROACH ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_BASICAPPROACH" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_BASICAPPROACH( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_HOVERINGUP ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_HOVERINGUP" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_HOVERINGUP( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_JUSTSTAY ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_JUSTSTAY" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_JUSTSTAY( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_GOAWAY ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_GOAWAY" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_GOAWAY( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_POPUP ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_POPUP" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_POPUP( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_SHOOTSINGULARITY ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_SHOOTSINGULARITY" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_SHOOTSINGULARITY( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_CIRCLESTRAFE ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_CIRCLESTRAFE" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_CIRCLESTRAFE( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_STOP ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_STOP" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_STOP( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_SEEKHIDEPOSITION ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_SEEKHIDEPOSITION" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_SEEKHIDEPOSITION( entity );
		elseif (  entity.AI.CurrentHook == fSCOUTMOACATTACK_HIDE ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_HIDE" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_HIDE( entity );
		elseif (  entity.AI.CurrentHook == fSCOUTMOACATTACK_UNHIDE ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_UNHIDE" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_UNHIDE( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_DIRECTSTRAFE ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_DIRECTSTRAFE" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DIRECTSTRAFE( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_DIRECTSTRAFE2 ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_DIRECTSTRAFE2" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DIRECTSTRAFE2( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_LOOPINLOOP ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_LOOPINLOOP" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_LOOPINLOOP( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_LINEATTACK ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_LINEATTACK" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_LINEATTACK( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_BACKATTACK ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_BACKATTACK" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_BACKATTACK( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_LINEATTACK2 ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_LINEATTACK2" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_LINEATTACK2( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_LINEATTACK3 ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_LINEATTACK3" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_LINEATTACK3( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_TRACEPATHPRE ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_TRACEPATHPRE" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_TRACEPATHPRE( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_TRACEPATH ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_TRACEPATH" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_TRACEPATH( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_CIRCLING ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_CIRCLING" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_CIRCLING( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_SHORTDUSH ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_SHORTDUSH" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_SHORTDUSH( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_JAMMER ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_JAMMER" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_JAMMER( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_JAMMERDUSH ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_JAMMERDUSH" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_JAMMERDUSH( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_FOUNDPLAYER ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_FOUNDPLAYER" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_FOUNDPLAYER( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_VSAIR ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_VSAIR" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_VSAIR( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_VSAIR2 ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_VSAIR2" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_VSAIR2( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_VSAIR3 ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_VSAIR3" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_VSAIR3( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_VSAIRPAUSE ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_VSAIRPAUSE" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_VSAIRPAUSE( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_VSAIRCIRCLE ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_VSAIRCIRCLE" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_VSAIRCIRCLE( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_VSAIRUP ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_VSAIRUP" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_VSAIRUP( entity );
		elseif ( entity.AI.CurrentHook == fSCOUTMOACATTACK_VSCLOAK ) then
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_DEBUGLABEL( entity:GetPos(), "SCOUTMOACATTACK_VSCLOAK" );
			AIBehaviour.ScoutMOACAttack:SCOUTMOACATTACK_VSCLOAK( entity );
		end
		
	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_DEBUGLABEL = function( self, pos, label )
		local vVec ={};
		CopyVector( vVec, pos );
		vVec.z = vVec.z + 10.0;
--		System.DrawLabel( vVec, 2, label, 1, 1, 1, 1);
--		System.Log(label);

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_DONOTHING_START = function ( self, entity )
		entity.AI.CurrentHook = fSCOUTMOACATTACK_DONOTHING;
		local vTmp = { x=0.0, y=0.0, z=0.0 };
		AI.SetForcedNavigation( entity.id, vTmp );
	end,

	SCOUTMOACATTACK_DONOTHING = function ( self, entity )
	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_FOUNDPLAYER_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			local flg = false;
			local groupCount = AI.GetGroupCount( entity.id, GROUP_ENABLED );
			--System.Log(entity:GetName().." group count "..groupCount );
			if ( groupCount > 1 ) then
				for i= 1,groupCount do
					local member = AI.GetGroupMember( entity.id, i, GROUP_ENABLED );
					--System.Log(entity:GetName().." group member "..member:GetName() );
					if( member ~= nil ) then
						if ( member.AI.bCloseScout == true ) then
							--System.Log(entity:GetName().." find close "..member:GetName() );
							flg = true;
						end
					end
				end
			end

			if ( flg == false ) then
				entity.AI.bCloseScout = true;
			end

			if (AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_HELICOPTER ) then
				AIBehaviour.ScoutMOACDefault:SCOUT_CHANGESOUND( entity );
				self:SCOUTMOACATTACK_VSAIR_START( entity );
				return;
			end

			entity.gameParams.forceView = 150.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.CurrentHook = fSCOUTMOACATTACK_FOUNDPLAYER;
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = false;

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOACLookAt");

			if ( AI.GetAttentionTargetDistance(entity.id) > 50.0 ) then
				AI.Animation(entity.id,AIANIM_SIGNAL,"foundPlayer");
			end

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_FOUNDPLAYER = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			local vTmp = {};
			SubVectors( vTmp, target:GetPos(), entity:GetPos() );
			NormalizeVector( vTmp );
			FastScaleVector( vTmp, vTmp, 0.5 );
			
			local movingTime = System.GetCurrTime() - entity.AI.circleSec;

			if ( entity.AI.bLock == false ) then
				
				if ( entity.AI.bCloseScout == true ) then
					if ( movingTime > 0.0 ) then
						if ( entity.AI.bBigRolloff and entity.AI.bBigRolloff == true ) then
							entity.actor:PlayNetworkedSoundEvent("sounds/alien:scout_big_rolloff:anticipation_call", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
						else
							entity.actor:PlayNetworkedSoundEvent("sounds/alien:scout:anticipation_call", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
						end
						local groupCount = AI.GetGroupCount( entity.id, GROUP_ENABLED );
						if ( groupCount > 1 ) then
							for i= 1,groupCount do
								local member = AI.GetGroupMember( entity.id, i, GROUP_ENABLED );
								if( member.id ~= entity.id ) then
									AI.Signal(SIGNALFILTER_SENDER, 1, "SCOUTMOAC_ANTICIPATION_RESPONSE", member.id);
									break;
								end
							end
						end
						entity.AI.bLock = true;
					end
				end

			end

			if ( AI.GetAttentionTargetDistance(entity.id) < 50.0 ) then
				self:SCOUTMOACATTACK_CIRCLING_START( entity );
				return;
			end

			if ( movingTime > 1.0 ) then

				if ( entity.AI.bCloseScout == true ) then
					self:SCOUTMOACATTACK_CIRCLING_START( entity );
				else
					self:SCOUTMOACATTACK_HOVERINGUP_START( entity );
				end
				return;

			end
	
			AI.SetForcedNavigation( entity.id, vTmp );

		end
		
	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_HOVERINGUP_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.CurrentHook = fSCOUTMOACATTACK_HOVERINGUP;
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			
			local vTmp ={};
			SubVectors( vTmp, entity.AI.vMyPosRsv, entity.AI.vTargetRsv );
			vTmp.z = 20.0;
			NormalizeVector( vTmp );
			FastScaleVector( entity.AI.vDirectionRsv, vTmp, 16.0 );

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOAC");

		end

	end,
	
	SCOUTMOACATTACK_HOVERINGUP = function ( self, entity )

		local vTmp = {};
		local vTmp2 = {};

		SubVectors( vTmp, entity:GetPos(), entity.AI.vTargetRsv );
		if ( vTmp.z > 60.0 ) then
			self:SCOUTMOACATTACK_DIRECTSTRAFE2_START( entity );
			return;
		end
		
		vTmp.z =0;
		if ( LengthVector( vTmp ) > 80.0 ) then
			self:SCOUTMOACATTACK_DIRECTSTRAFE2_START( entity );
			return;
		end
	
		CopyVector( vTmp, entity.AI.vDirectionRsv );
		vTmp.z = vTmp.z + ( math.cos( entity.AI.cosinOp ) * 5.0 );

		local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vTmp  , 1, 2.5 );
		AI.SetForcedNavigation( entity.id, vTmp );

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_BASICAPPROACH_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then
			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);
			--entity:Event_UnCloak();
			entity.AI.CurrentHook = fSCOUTMOACATTACK_BASICAPPROACH;
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.lastDot = 0.0;
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOAC");
		end

	end,

	SCOUTMOACATTACK_BASICAPPROACH = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			local vVel = {};
			local vVelRot = {};
			local vWng = {};
			local vFwd = {};
			local vDist = {};
			local vMyPos = {};
			local vTmp = {};
			local vTmp2 = {};
			local vTmp3 = {};

			CopyVector( vMyPos, entity:GetPos() );
			
			SubVectors( vDist, target:GetPos(), entity:GetPos() );
			vDist.z =0;
			local distanceToTheTarget =  LengthVector( vDist );

			local BasicApproachSpeed = 23.0;

			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			vFwd.z = 0;
			NormalizeVector( vFwd );
	
			CopyVector( vWng, entity:GetDirectionVector(0) );

			CopyVector( vVel, entity:GetDirectionVector(1) );
			vVel.z =0;
			NormalizeVector( vVel );

			local dot = dotproduct3d( vFwd, vWng );
			local dot2 = dotproduct3d( vFwd, vVel );

			FastScaleVector( vVel, vVel, BasicApproachSpeed );
	
			CopyVector( vVelRot, vVel );

			local actionAngle = 3.1416* 120.0 / 180.0;
			
			if ( dot * entity.AI.lastDot < 0.0 or distanceToTheTarget < 15.0 ) then
				--self:SCOUTMOACATTACK_LOCKON_START( entity );
				self:SCOUTMOACATTACK_CIRCLESTRAFE_START( entity, 12.0 );
				return;
			elseif ( dot > 0 ) then
				RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, actionAngle * minUpdateTime * -1.0 );
			else
				RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, actionAngle * minUpdateTime  );
			end
			entity.AI.lastDot = dot;

			distanceFactor =  distanceToTheTarget/ 4.0;
			if ( distanceFactor > 12.0 ) then
				distanceFactor = 12.0
			end

			if ( vMyPos.z > entity.AI.vTargetRsv.z + 20.0 ) then
				vVelRot.z = vVelRot.z -5.0;
			end

			vVelRot.z = vVelRot.z + ( math.cos( entity.AI.cosinOp ) * distanceFactor );

			local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vVelRot  , 1, 2.5 );

			AI.SetForcedNavigation( entity.id, vVelRot );

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_CIRCLESTRAFE_START = function( self, entity, sec )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.bCircledHalf = false;
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.circleSecMax = sec;

			local vTmp = {};
			local vFwd = {};
			local vWng = {};

			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			vFwd.z =0;
			NormalizeVector( vFwd );
			crossproduct3d( vWng, vFwd, entity.AI.vUp );
			vWng.z = 0;
			NormalizeVector( vWng );

			CopyVector( vTmp, entity:GetDirectionVector(1) );
			vTmp.z = 0;
			NormalizeVector( vTmp );
			
			if ( dotproduct3d( vWng, vTmp )> 0 ) then
				entity.AI.direc = true;
			else
				entity.AI.direc = false;
			end

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			entity:InsertSubpipe( 0, "ScoutMOACFire2" );

			entity.AI.CurrentHook = fSCOUTMOACATTACK_CIRCLESTRAFE;

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_CIRCLESTRAFE = function( self, entity )

		local vWng = {};
		local vWngR = {};
		local vFwd = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			if ( self:SCOUTMOACATTACK_ISTRACEPOSSIBLE( entity ) == true ) then
				self:SCOUTMOACATTACK_TRACEPATHPRE_START( entity );
				return;
			end

			local vTargetPos = {};
			local vMyPos = {};
			local vVelRot = {};


			if ( System.GetCurrTime() - entity.AI.circleSec > entity.AI.circleSecMax ) then 
				self:SCOUTMOACATTACK_GOAWAY_START( entity );
				return;
			end
	
			CopyVector( vTargetPos, target:GetPos() );
			CopyVector( vMyPos, entity:GetPos() );

			local vTmp = {};

			SubVectors( vTmp, target:GetPos(), entity:GetPos() );
			vTmp.z =0;
			NormalizeVector( vTmp );

			local vDist = {};
			SubVectors( vDist, target:GetPos(), entity:GetPos() );
			vDist.z =0;

			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			NormalizeVector( vFwd );
			crossproduct3d( vWng, vFwd, entity.AI.vUp );
			vWng.z = 0;

			NormalizeVector( vWng );
			if ( entity.AI.direc == true ) then
				FastScaleVector( vWng, vWng, 30.0 );
			else
				FastScaleVector( vWng, vWng, -30.0 );
			end
			FastSumVectors( vWng, vWng, entity:GetPos() );
	
			SubVectors( vFwd, vWng , target:GetPos()  );
			NormalizeVector( vFwd );
			FastScaleVector( vFwd, vFwd, 30.0 );
			FastSumVectors( vFwd, vFwd, target:GetPos() );
			SubVectors( vFwd, vFwd, entity:GetPos() );
			NormalizeVector( vFwd );
			FastScaleVector( vVelRot, vFwd, 12.0 );

			vVelRot.z = vVelRot.z + ( math.cos( entity.AI.cosinOp ) * 5.0 ) - 3.0;

			if ( vMyPos.z < vTargetPos.z + 15.0 ) then
				vVelRot.z  = 10.0;
			end

			local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vVelRot  , 1, 2.5 );

			AI.SetForcedNavigation( entity.id, vVelRot );


		end

	end,
	
	--------------------------------------------------------------------------
	SCOUTMOACATTACK_GOAWAY_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.CurrentHook = fSCOUTMOACATTACK_GOAWAY;
			entity.AI.circleSec = System.GetCurrTime();
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vDirectionRsv, entity:GetDirectionVector(1) );
			entity.AI.vDirectionRsv.z = 0;
			NormalizeVector( entity.AI.vDirectionRsv );
			FastScaleVector( entity.AI.vDirectionRsv, entity.AI.vDirectionRsv, 50.0 );
			entity.AI.vDirectionRsv.z = 35.0 - ( entity.AI.vMyPosRsv.z - entity.AI.vTargetRsv.z );
			NormalizeVector( entity.AI.vDirectionRsv );
			
			FastScaleVector( entity.AI.vDirectionRsv, entity.AI.vDirectionRsv, 25.0 );
			entity.AI.bLock = false;

		end

	end,

	SCOUTMOACATTACK_GOAWAY = function ( self, entity )

		local vDist = {};
		local vVel = {};

		if ( entity.AI.bLock == false ) then
			CopyVector( vVel, entity.AI.vZero );
			AI.SetForcedNavigation( entity.id, vVel );
			if ( entity:GetSpeed() < 13.0 ) then
				CopyVector( vVel, entity.AI.vDirectionRsv );
				CopyVector( vDist, entity.AI.vDirectionRsv );
				local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearanceMain( entity, vDist, 1, 2.5 );
				local vTmp = {};
				local vTmp2 = {};
				CopyVector( vTmp, entity:GetDirectionVector(0) );				
				CopyVector( vTmp2, entity.AI.vDirectionRsv );				
				vTmp.z = 0.0;
				vTmp2.z = 0.0;
				NormalizeVector( vTmp );
				NormalizeVector( vTmp2 );
				if ( dotproduct3d( vTmp, vTmp2 ) > 0.0 and res == 0 ) then
					--entity.actor:PlayNetworkedSoundEvent("Sounds/alien:scout:retreat", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
					AI.Animation(entity.id,AIANIM_SIGNAL,"readyToFly");
				end
				entity.AI.bLock = true;
				entity.gameParams.forceView = 150.0;
				entity.actor:SetParams(entity.gameParams);
				entity:SelectPipe(0,"do_nothing");
				entity:SelectPipe(0,"ScoutMOAC" );
			end
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			SubVectors( vDist, target:GetPos(), entity:GetPos() );
			vDist.z =0;
			if ( LengthVector( vDist ) > 50.0 ) then
				self:SCOUTMOACATTACK_DIRECTSTRAFE2_START( entity );
				return;
			end

			CopyVector( vDist, entity.AI.vDirectionRsv );
	
			vDist.z = vDist.z + ( math.cos( entity.AI.cosinOp ) * 10.0 );

			local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearanceMain( entity, vDist, 1, 2.5 );

			AI.SetForcedNavigation( entity.id, vDist );

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_JUSTSTAY_START = function ( self, entity )

		entity.gameParams.forceView = 0.0;
		entity.actor:SetParams(entity.gameParams);
		--entity.actor:PlayNetworkedSoundEvent("Sounds/alien:scout:singularity", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);

		AI.SetForcedNavigation( entity.id, entity.AI.vZero );

		entity.AI.CurrentHook = fSCOUTMOACATTACK_JUSTSTAY;

		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"ScoutMOAC");

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_JUSTSTAY = function ( self, entity )

		local vDist = {};
		local vVel = {};
		
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity:GetVelocity( vVel );
			vVel.z = 0;
			NormalizeVector( vVel );

			SubVectors( vDist, target:GetPos(), entity:GetPos() );
			vDist.z = 0;
			NormalizeVector( vDist );

			if ( dotproduct3d( vVel, vDist ) > math.cos( 3.1416 * 15.0 / 180.0 ) ) then
				if ( entity:GetSpeed()< 5.0) then
					self:SCOUTMOACATTACK_SHOOTSINGULARITY_START( entity );
					return;
				end
			end

			AI.SetForcedNavigation( entity.id, vDist );
		
		end
	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_SHOOTSINGULARITY_START = function ( self, entity )

		entity.gameParams.forceView = 0.0;
		entity.actor:SetParams(entity.gameParams);

		entity:SelectPrimaryWeapon();
		entity:SelectSecondaryWeapon();
		entity.AI.CurrentHook = fSCOUTMOACATTACK_SHOOTSINGULARITY;
		local vTmp={};

		entity.AI.circleSec = System.GetCurrTime();
		
		local target = AI.GetAttentionTargetEntity( entity.id );
		SubVectors( vTmp, entity:GetPos(), target:GetPos() );
		NormalizeVector( vTmp );
		FastScaleVector( vTmp, vTmp, 30.0 );
		FastSumVectors( vTmp, vTmp, target:GetPos() );
		 
		AI.SetRefPointPosition( entity.id, vTmp );
		AI.CreateGoalPipe("ScoutMOACMain5");
		AI.PushGoal("ScoutMOACMain5","firecmd",0,0);
		AI.PushGoal("ScoutMOACMain5","locate",0,"refpoint");
		AI.PushGoal("ScoutMOACMain5","lookat",0,0,0,true,1);
		AI.PushGoal("ScoutMOACMain5","animation",0,AIANIM_SIGNAL,"fireSingularityCannon");	
		AI.PushGoal("ScoutMOACMain5","+timeout",1,3);
		AI.PushGoal("ScoutMOACMain5","firecmd",0,FIREMODE_FORCED);
		AI.PushGoal("ScoutMOACMain5","+timeout",1,3);
		AI.PushGoal("ScoutMOACMain5","+firecmd",1,0);
		AI.PushGoal("ScoutMOACMain5","+timeout",1,2);
		AI.PushGoal("ScoutMOACMain5","signal",1,1,"SCOUTMOACATTACK_SHOOTSINGULARITY_END",SIGNALFILTER_SENDER);
		AI.PushGoal("ScoutMOACMain5","signal",1,1,"SCOUTMOACATTACK_DIRECTSTRAFE2_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"ScoutMOACMain5");
		entity.AI.ndtime = 1;

		AI.SetForcedNavigation( entity.id, entity.AI.vZero );

	end,

	SCOUTMOACATTACK_SHOOTSINGULARITY = function ( self, entity )
	end,

	SCOUTMOACATTACK_SHOOTSINGULARITY_END  = function ( self, entity )
		entity:SelectPrimaryWeapon();
		entity.AI.memorySec = System.GetCurrTime();
			--entity:Event_Cloak();
	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_POPUP_START = function ( self, entity )

		entity.gameParams.forceView = 100.0;
		entity.actor:SetParams(entity.gameParams);

		entity.AI.CurrentHook = fSCOUTMOACATTACK_POPUP;
		entity.AI.circleSec = System.GetCurrTime();

		CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
		CopyVector( entity.AI.vDirectionRsv, entity:GetDirectionVector(2) );
--		FastSumVectors( entity.AI.vDirectionRsv, entity.AI.vDirectionRsv, entity:GetDirectionVector(1) );
		if ( entity.AI.vDirectionRsv.z < 0 ) then
			FastScaleVector( entity.AI.vDirectionRsv, entity.AI.vDirectionRsv, -1 );
		end

		NormalizeVector( entity.AI.vDirectionRsv );
		FastScaleVector( entity.AI.vDirectionRsv, entity.AI.vDirectionRsv, 20.0 );
		AI.SetForcedNavigation( entity.id, entity.AI.vDirectionRsv );

		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"ScoutMOAC");

	end,

	SCOUTMOACATTACK_POPUP = function ( self, entity )

		local vTmp ={};

		CopyVector( vTmp, entity:GetPos() );
		AI.SetForcedNavigation( entity.id, entity.AI.vZero );
		self:SCOUTMOACATTACK_SEEKHIDEPOSITION_START( entity );

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_SEEKHIDEPOSITION_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.CurrentHook = fSCOUTMOACATTACK_SEEKHIDEPOSITION;
			entity.AI.circleSec = System.GetCurrTime();
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			SubVectors( entity.AI.vDirectionRsv, entity:GetPos(), target:GetPos() );
			entity.AI.vDirectionRsv.z = 0;
			NormalizeVector( entity.AI.vDirectionRsv );
			entity.AI.bLock = false;

			local vTmp = {};
			CopyVector( vTmp, entity.AI.vTargetRsv, entity.AI.vMyPosRsv );
			vTmp.z = 0.0;
			length = LengthVector( vTmp );
			if ( length > 60.0 ) then
				self:SCOUTMOACATTACK_UNHIDE_START( entity );
				return;
			end		

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOAC");

		end

	end,

	SCOUTMOACATTACK_SEEKHIDEPOSITION = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			local objects = {};
			local vSpotPos = {};
			local vTargetPos = {};
			local vTmp = {};

			if ( System.GetCurrTime() - entity.AI.circleSec > 2.0 and entity.AI.bLock == false ) then
				entity.AI.bLock = true;
				--entity:Event_Cloak();
			end

			CopyVector( vTmp, entity:GetPos() );
			CopyVector( vTargetPos, target:GetPos() );

			--[[

			local level = System.GetTerrainElevation( vTmp )
			vTmp.z = level;
			
			local numObjects = AI.GetNearestEntitiesOfType( vTmp, AIAnchorTable.SCOUT_HIDESPOT, 3, objects, AIFAF_INCLUDE_DEVALUED, 50.0 );

			vTargetPos.z = vTargetPos.z + 1.0 ;

			if ( numObjects > 0 ) then

				for i = 1,numObjects do

					local objEntity = System.GetEntity( objects[i].id );
					CopyVector( vSpotPos, objEntity:GetPos() );
					vSpotPos.z = vSpotPos.z + 2.5;

					SubVectors( vTmp, vTargetPos, vSpotPos );
					vTmp.z = 0;
					if ( LengthVector( vTmp ) > 40.0 ) then
						SubVectors( vTmp, vTargetPos, vSpotPos );
						local	hits = Physics.RayWorldIntersection(vSpotPos,vTmp,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,target.id,entity.id,g_HitTable);
						if ( hits > 0 ) then
							self:SCOUTMOACATTACK_HIDE_START( entity, vSpotPos );
							return;
						end
					end

				end

			end				
			--]]

			SubVectors( vTmp, vTargetPos, entity:GetPos() );
			vTmp.z = 0;
			local length = LengthVector( vTmp );
			if (  length > 100.0 ) then
				--entity:Event_UnCloak();
				self:SCOUTMOACATTACK_DIRECTSTRAFE2_START( entity );
				return;
			end

			NormalizeVector( vTmp );
			local vWng = {};
			crossproduct3d( vWng, vTmp, entity.AI.vUp );
			vWng.z = 0;
			NormalizeVector( vWng );

			local lengthR = length;
			if ( lengthR < 0.0 ) then
				lengthR = 0.0;
			end

			FastScaleVector( vWng, vWng, 16.0 * math.sin( ( 3.1416 * 70.0/180.0 ) * ( lengthR / 100.0 ) ) );
			FastScaleVector( vTmp, entity.AI.vDirectionRsv, 16.0 * math.cos( ( 3.1416 * 70.0/180.0 ) * ( lengthR / 100.0 ) ) );

			FastSumVectors( vTmp, vTmp, vWng );

			vTmp.z = vTmp.z + ( math.cos( entity.AI.cosinOp ) * 10.0 );

			local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vTmp , 1, 2.5 );
			AI.SetForcedNavigation( entity.id, vTmp );

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_HIDE_START = function ( self, entity, vSpotPos )

		--entity:Event_UnCloak();

		entity.gameParams.forceView = 100.0;
		entity.actor:SetParams(entity.gameParams);

		entity.AI.CurrentHook = fSCOUTMOACATTACK_HIDE;
		entity.AI.circleSec = System.GetCurrTime();
		entity.AI.bLock = false;

		CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
		CopyVector( entity.AI.vTargetRsv, vSpotPos );

		entity:SelectPipe(0,"ScoutMOACLookAt");

	end,

	SCOUTMOACATTACK_HIDE = function ( self, entity )

		if ( entity.AI.bLock == true ) then
			AI.SetForcedNavigation( entity.id, entity.AI.vZero );
			if ( System.GetCurrTime() - entity.AI.circleSec > 3.0 ) then
				self:SCOUTMOACATTACK_UNHIDE_START( entity );
			end
			return;
		else
		
			local objects = {};
	
			local vMyPos = {};
			local vTargetPos = {};
			local vTmp = {};
	
			CopyVector( vMyPos, entity:GetPos() );
			SubVectors( vTmp, entity.AI.vTargetRsv, vMyPos );
			vTmp.z = 0;
	
			local len = LengthVector( vTmp );
			if ( len > 20.0 ) then
				len = 20.0;
			end
	
			NormalizeVector( vTmp );
			FastScaleVector( vTmp, vTmp, len );
	
			if ( len < 3.0 ) then
	
				local height = vMyPos.z - entity.AI.vTargetRsv.z;
				if ( height > 5.0 ) then
					height = 5.0;
				end
	
				vTmp.z = height * -1.0;
		
				if ( height < 2.0 ) then
					entity.AI.bLock = true;
				end
	
			else
				local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vTmp  , 1, 2.5 );
			end

			
			entity.AI.circleSec = System.GetCurrTime();
			AI.SetForcedNavigation( entity.id, vTmp );

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_STOP_START = function ( self, entity )
		entity.gameParams.forceView = 0.0;
		entity.actor:SetParams(entity.gameParams);
		entity.AI.CurrentHook = fSCOUTMOACATTACK_STOP;
	end,

	SCOUTMOACATTACK_STOP = function ( self, entity )
		AI.SetForcedNavigation( entity.id, entity.AI.vZero );
	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_UNHIDE_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);
	
			entity.AI.CurrentHook = fSCOUTMOACATTACK_UNHIDE;
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = false;
	
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
	
			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOACLookAt");

		end

	end,

	SCOUTMOACATTACK_UNHIDE = function ( self, entity )

		local vTmp = {};
		local vTmp2 = {};
		
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then
			SubVectors( vTmp, target:GetPos(), entity:GetPos() );
			vTmp.z = 0;
			NormalizeVector( vTmp );
			CopyVector( vTmp2, entity:GetDirectionVector(1) );
			vTmp2.z = 0;
			NormalizeVector( vTmp2 );

			local dot = dotproduct3d( vTmp, vTmp2 );

			if ( System.GetCurrTime() - entity.AI.circleSec > 0.5 ) then
				entity.gameParams.forceView = 150.0;
				entity.actor:SetParams(entity.gameParams);
				FastScaleVector( vTmp, vTmp, 1.0 );
				FastScaleVector( vTmp2, entity.AI.vUp, 8.0 );
				FastSumVectors( vTmp, vTmp, vTmp2 );
				AI.SetForcedNavigation( entity.id, vTmp );
				if ( dot > math.cos( 10.0 * 3.1416 / 180.0 ) ) then 
					self:SCOUTMOACATTACK_DIRECTSTRAFE_START( entity );
				end
				return;
			end

			FastScaleVector( vTmp, entity.AI.vUp, 12.0 );
			AI.SetForcedNavigation( entity.id, vTmp );

		end
		--[[
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then
			local vTmp ={};
			local vMyPos ={};
			CopyVector( vMyPos, entity:GetPos() );
			SubVectors( vTmp, entity:GetPos(), entity.AI.vMyPosRsv );
			local height = DistanceVectors( entity:GetPos(), entity.AI.vTargetRsv );
			if ( height > 100.0 ) then 
				height = 100;
			end
			height = 15.0 + ( 15.0 * height / 100.0 );
			vUpSpeed = height + entity.AI.vTargetRsv.z - vMyPos.z + 15.0;
			if ( vUpSpeed > 25.0 ) then
				vUpSpeed = 25.0;
			end
			if ( vUpSpeed < 12.0 ) then
				vUpSpeed = 12.0;
			end
			if ( vTmp.z > height ) then
				entity:SelectPipe(0,"ScoutMOACFire");
				self:SCOUTMOACATTACK_DIRECTSTRAFE_START( entity );
--				self:SCOUTMOACATTACK_LOOPINLOOP_START( entity );
			end
			FastScaleVector( vTmp, entity.AI.vUp, vUpSpeed );
			AI.SetForcedNavigation( entity.id, vTmp );
		end

		--]]

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_DIRECTSTRAFE_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.CurrentHook = fSCOUTMOACATTACK_DIRECTSTRAFE;
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			SubVectors( entity.AI.vDirectionRsv, entity.AI.vTargetRsv, entity.AI.vMyPosRsv );
			
			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOACFire");

		--	entity.actor:PlayNetworkedSoundEvent("sounds/alien:scout:anticipation_call", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);

		end

	end,

	SCOUTMOACATTACK_DIRECTSTRAFE = function ( self, entity )

		local vTmp ={};
		local vTmp2 ={};
		local vMyPos ={};

		CopyVector( vMyPos, entity:GetPos() );

		SubVectors( vTmp, entity.AI.vTargetRsv, entity:GetPos() );
		vTmp.z = 0;
		local distance = LengthVector( vTmp );

		SubVectors( vTmp, entity.AI.vTargetRsv, entity.AI.vMyPosRsv );
		vTmp.z = 0;
		NormalizeVector( vTmp );

		local vTmp3 = {};
		SubVectors( vTmp3, entity.AI.vTargetRsv, entity:GetPos()  );
		vTmp3.z = 0;
		NormalizeVector( vTmp3 );

		local vWng = {};
		crossproduct3d( vWng, vTmp, entity.AI.vUp );
		vWng.z = 0;
		NormalizeVector( vWng );

		dot = dotproduct3d( vTmp, vTmp3 );

		local reset = false;

		if ( distance < 30.0 and dot > 0 ) then
			reset = true;
		end

		if ( dot < 0 ) then
			reset = true;
		end

		if ( entity.AI.bLock == false and reset == true) then
			entity.AI.bLock = true;
			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);
			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOAC");
		end

		if ( dot > 0 ) then

			if ( distance > 100.0 ) then
				distance = 100.0;
			end

			local height = 20.0 *  math.cos( 3.1416 * distance / 100.0 )   - vMyPos.z;

			if ( height < -12.0 ) then
				height = -12.0;
			end
			
			if ( height > 12.0 ) then
				height = 12.0;
			end

			FastScaleVector( vTmp2, vTmp, 16.0 );

			vTmp2.z = height;
	
		else

			FastScaleVector( vTmp2, vTmp, 15.0 );

			if ( distance > 80.0 ) then
				self:SCOUTMOACATTACK_DIRECTSTRAFE2_START( entity );
				return;
			end

			if ( distance > 50.0 ) then
				distance = 50.0;
			end

			local height = 40.0 * math.sin( 3.1416 * distance / 100.0 )  +  entity.AI.vTargetRsv.z + 10.0;
			height = height - vMyPos.z;

			if ( height < -12.0 ) then
				height = -12.0;
			end

			vTmp2.z = height;

			distance = distance - 5.0;

			if ( distance > 0 ) then
				local wng = -30.0 * math.sin( 3.1416 * distance / 100.0 );
				FastScaleVector( vWng, vWng, wng );
				FastSumVectors( vTmp2, vTmp2, vWng );
			end

		end
		
		local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vTmp2  , 1, 2.5 );

		AI.SetForcedNavigation( entity.id, vTmp2 );

	end,


	--------------------------------------------------------------------------
	SCOUTMOACATTACK_DIRECTSTRAFE2_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity:SelectPrimaryWeapon();

			if (AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_HELICOPTER ) then
				AIBehaviour.ScoutMOACDefault:SCOUT_CHANGESOUND( entity );
				self:SCOUTMOACATTACK_VSAIR_START( entity );
				return;
			end

			local flg = false;
			local groupCount = AI.GetGroupCount( entity.id, GROUP_ENABLED );

			if ( groupCount > 1 ) then
				for i= 1,groupCount do
					local member = AI.GetGroupMember( entity.id, i, GROUP_ENABLED );
					if( member ~= nil ) then
						if ( member.AI.bCloseScout == true ) then
							flg = true;
						end
					end
				end
			end

			if ( flg == false ) then
				entity.AI.bCloseScout = true;
			end

			if ( entity.AI.bCloseScout and entity.AI.bCloseScout == true ) then
				self:SCOUTMOACATTACK_CIRCLING_START( entity );
				return;
			end

			entity:SelectPrimaryWeapon();
			entity.AI.tracePathName = "";

			if ( testflg == 1 ) then --random( 1, 256 ) > 128 ) then
				entity.AI.bRvs = true;
				testflg = 0;
			else
				entity.AI.bRvs = false;
				testflg = 1;
			end

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.CurrentHook = fSCOUTMOACATTACK_DIRECTSTRAFE2;
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = self:SCOUTMOACATTACK_RANDOM( entity, 6, 8 ); --random( 5,7 );

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity:SelectPipe(0,"ScoutMOAC");

		end
	
	end,

	SCOUTMOACATTACK_DIRECTSTRAFE2 = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			local vMyPos ={};
			CopyVector( vMyPos, entity:GetPos() );

			local vFwd = {};
			SubVectors( vFwd, entity.AI.vTargetRsv, entity:GetPos() );
			vFwd.z = 0;
			local length = LengthVector( vFwd );

			local vFwdN = {};
			CopyVector( vFwdN, vFwd );
			NormalizeVector( vFwdN );

			local vWngN = {};
			crossproduct3d( vWngN, vFwd, entity.AI.vUp );
			vWngN.z = 0;
			NormalizeVector( vWngN );
			if ( entity.AI.bRvs == true ) then
				FastScaleVector( vWngN, vWngN, -1.0 );
			end

			if ( length > 80.0 ) then
				if (  System.GetCurrTime()- entity.AI.circleSec > entity.AI.bLock ) then
					entity.AI.bBlockSignal = false;
					local randomfactor = self:SCOUTMOACATTACK_RANDOM( entity, 0, 100 );
					if ( target.class and target.class == "Asian_aaa" ) then
						if ( randomfactor < 70 ) then
							self:SCOUTMOACATTACK_JUSTSTAY_START( entity );
						elseif ( randomfactor < 85  ) then
							self:SCOUTMOACATTACK_BASICAPPROACH_START( entity );
						else
							self:SCOUTMOACATTACK_LOOPINLOOP_START( entity );
						end
					else
						if ( randomfactor < 25 ) then
							self:SCOUTMOACATTACK_JUSTSTAY_START( entity );
						elseif ( randomfactor < 65 ) then
							self:SCOUTMOACATTACK_BASICAPPROACH_START( entity );
						else
							self:SCOUTMOACATTACK_LOOPINLOOP_START( entity );
						end
					end
					return;
				end
			else
				entity.AI.circleSec = System.GetCurrTime();
			end

			if ( System.GetCurrTime() - entity.AI.memorySec > 5.0  ) then
--and target.actor~=nil and target.actor:GetHealth()>1.0 and vMyPos.z > entity.AI.vTargetRsv.z + 20.0
				local rvMyPos = {};
				local rvTargetPos = {};
				local rvDir = {};

				CopyVector( rvMyPos, entity:GetPos() );
				CopyVector( rvTargetPos, target:GetPos() );

				rvMyPos.z = rvMyPos.z - 2.0
				rvTargetPos.z = rvTargetPos.z + 2.0;
				SubVectors( rvDir, rvTargetPos, rvMyPos );
			
				local	hits = Physics.RayWorldIntersection(rvMyPos,rvDir,1,ent_terrain,target.id,entity.id,g_HitTable);
				if ( hits == 0 ) then
					self:SCOUTMOACATTACK_JUSTSTAY_START( entity );
					return;
				end

			end

			local scaleFactor = 0.0;
			
			scaleFactor = length - 100.0;
			if ( scaleFactor > 12.0 ) then
				scaleFactor = 12.0;
			end
			if ( scaleFactor < -12.0 ) then
				scaleFactor = -12.0;
			end

			local vTmp = {};
			local vTmp2 = {};
			local vDot = {};

			FastScaleVector( vTmp, vFwdN, scaleFactor);

			FastScaleVector( vTmp2, vWngN, 15.0 );
			FastSumVectors( vTmp, vTmp, vTmp2 );
			NormalizeVector( vTmp );
			CopyVector( vDot, entity:GetDirectionVector(1) );
			vDot.z = 0;
			NormalizeVector( vDot );
			
--			local dot = dotproduct3d( vTmp, vDot );
--			FastScaleVector( vTmp, vTmp, 5.0 * dot + 15.0 );

			FastScaleVector( vTmp, vTmp, 15.0 );

			vTmp.z = vTmp.z + ( math.cos( entity.AI.cosinOp ) * 10.0 );

			if ( vMyPos.z < entity.AI.vTargetRsv.z + 20.0 ) then
				local height = entity.AI.vTargetRsv.z + 20.0 - vMyPos.z;
				if ( height > 5.0 ) then
					height = 5.0;
				end
				vTmp.z = vTmp.z + height;
			end

			if ( vMyPos.z > entity.AI.vTargetRsv.z + 35.0 ) then
				local height = entity.AI.vTargetRsv.z + 35.0 - vMyPos.z;
				if ( height < -5.0 ) then
					height = -5.0;
				end
				vTmp.z = vTmp.z + height;
			end

			local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vTmp  , 1, 2.5 );

			AI.SetForcedNavigation( entity.id, vTmp );

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_LOOPINLOOP_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.CurrentHook = fSCOUTMOACATTACK_LOOPINLOOP;
			entity.AI.circleSec = System.GetCurrTime();

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			local vTmp = {};
			local vTmp2 = {};
			local vTmp3 = {};
			SubVectors( vTmp, entity.AI.vMyPosRsv, entity.AI.vTargetRsv );
			vTmp.z = 0;

			entity.AI.bLock = false;
			entity.AI.bFlg = false;
			entity.AI.bAnimation = false;

			-- rotate it so that an arc is 20.0m
			local distance = LengthVector( vTmp );
			local deg = ( 360.0 *  30.0 ) / ( 3.1416 * distance * 2.0 );
			if ( entity.AI.bRvs == true ) then
				RotateVectorAroundR( vTmp2, vTmp, entity.AI.vUp, -deg * 3.1416 / 180.0  );
			else
				RotateVectorAroundR( vTmp2, vTmp, entity.AI.vUp, deg * 3.1416 / 180.0  );
			end
			SubVectors( vTmp3, vTmp2, vTmp );
			CopyVector( vTmp, vTmp2 );
			NormalizeVector( vTmp );
			FastScaleVector( vTmp, vTmp, 30.0 );
			vTmp2.z = entity.AI.vMyPosRsv.z;
			FastSumVectors( entity.AI.vDirectionRsv, entity.AI.vTargetRsv, vTmp );
			FastSumVectors( entity.AI.vDirectionRsv, entity.AI.vTargetRsv, vTmp2 );
			entity:SelectPipe(0,"ScoutMOAC");

		end

	end,
	
	SCOUTMOACATTACK_LOOPINLOOP = function ( self, entity )

			local vVec = {};
			local vFwdN = {};
			local vFwd = {};

			SubVectors( vFwdN, entity.AI.vDirectionRsv, entity:GetPos() );
			vFwdN.z = 0;
			local distance = LengthVector( vFwdN );
			NormalizeVector( vFwdN );

			distance = distance - 10.0;

			local vWngN = {};
			local vWng = {};

			crossproduct3d( vWngN, vFwdN, entity.AI.vUp );
			vWngN.z = 0;
			NormalizeVector( vWngN );
			if ( entity.AI.bRvs == true ) then
				FastScaleVector( vWngN, vWngN, -1.0 );
			end
			FastScaleVector( vFwd, vFwdN, distance );
			FastScaleVector( vWng, vWngN, -10.0 );
			FastSumVectors( vVec, vWng, vFwd );
			
			local vA = {};
			local vB = {};
			SubVectors( vA, entity.AI.vDirectionRsv, entity:GetPos() );
			SubVectors( vB, entity:GetPos(), entity.AI.vTargetRsv );
			vA.z = 0.0;
			vB.z = 0.0;
			NormalizeVector( vA );
			NormalizeVector( vB );
			
			local dot = dotproduct3d( vA, vB );
			
			
			vVec.z = dot * 15.0;

			local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vVec  , 1.0 , 5.0 );
			AI.SetForcedNavigation( entity.id, vVec );
			
			CopyVector( vA, vVec );
			SubVectors( vB, entity.AI.vTargetRsv, entity:GetPos() );
			vA.z =0;
			vB.z =0;
			NormalizeVector( vA );
			NormalizeVector( vB );
			dot = dotproduct3d( vA, vB );

			if ( dot < 0 ) then
				if ( entity.AI.bFlg == false ) then
					entity.AI.bFlg = true;

					if ( entity.AI.bAnimation == false ) then
						entity.AI.bAnimation =ture;
						if ( entity.AI.bRvs == true ) then
							AI.Animation(entity.id,AIANIM_SIGNAL,"rotateLeft");
						else
							AI.Animation(entity.id,AIANIM_SIGNAL,"rotateRight");
						end
					end

				end
			end

			if ( entity.AI.bFlg == true ) then
				if ( dot > math.cos( 90.0 * 3.1416 / 180.0 ) ) then 
				end
			end

			if ( entity.AI.bFlg == true ) then

				if ( entity.AI.bLock == false ) then
					if ( dot > math.cos( 15.0 * 3.1416 / 180.0 ) ) then
						entity.AI.bLock = true;
					end
				end
				
				if ( entity.AI.bLock == true ) then
					if ( dot < math.cos( 15.0 * 3.1416 / 180.0 ) ) then
						self:SCOUTMOACATTACK_LINEATTACK2_START( entity );
					end
				end

			end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_LINEATTACK_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.CurrentHook = fSCOUTMOACATTACK_LINEATTACK;
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = 0.85;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity:GetVelocity( entity.AI.vDirectionRsv );
			entity.AI.vDirectionRsv.z = -4.0;
			FastScaleVector( entity.AI.vDirectionRsv, entity.AI.vDirectionRsv, entity.AI.bLock );

			entity:SelectPipe(0,"ScoutMOAC");

		end

	end,

	SCOUTMOACATTACK_LINEATTACK = function ( self, entity )

		local vTmp = {};
		local vMyPos = {};
		
		CopyVector( vTmp, entity.AI.vDirectionRsv );

		entity.AI.bLock = entity.AI.bLock + 0.50;
		if ( entity.AI.bLock > 2.0 ) then
			entity.AI.bLock = 2.0;
		end
		FastScaleVector( vTmp, vTmp, entity.AI.bLock );
		local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vTmp  , 1.5 , 5.0 );
		AI.SetForcedNavigation( entity.id, vTmp );

		local vWng = {};
		local vFwd = {};
		
		CopyVector( vWng, entity:GetDirectionVector(0) );
		SubVectors( vFwd, entity:GetPos(), entity.AI.vTargetRsv );
		vWng.z = 0;
		vFwd.z = 0;
		NormalizeVector( vWng );
		NormalizeVector( vFwd );
		if ( entity.AI.bRvs == true ) then
			FastScaleVector( vWng, vWng, -1.0 );
		end
		
		local dot = dotproduct3d( vWng, vFwd );
		if ( math.abs(dot) > math.cos( 15.0 * 3.1416 / 180.0 ) ) then
			self:SCOUTMOACATTACK_BACKATTACK_START( entity );
			return;
		end

		local vTmp = {};
		SubVectors( vTmp, entity.AI.vTargetRsv, entity:GetPos() );
		vTmp.z = 0;

		if ( LengthVector( vTmp ) <30.0 or math.abs(dot) > math.cos( 15.0 * 3.1416 / 180.0 ) ) then
			self:SCOUTMOACATTACK_BACKATTACK_START( entity );
			return;
		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_LINEATTACK2_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.CurrentHook = fSCOUTMOACATTACK_LINEATTACK2;
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity:SelectPipe(0,"ScoutMOAC");

		end

	end,

	SCOUTMOACATTACK_LINEATTACK2 = function ( self, entity )
		
		if ( entity.AI.bLock == false ) then
			local vTmp = {};
			entity:GetVelocity( vTmp );
			FastScaleVector( vTmp, vTmp, 0.5 );
			vTmp.z = 0;
			AI.SetForcedNavigation( entity.id, vTmp );
			if ( entity:GetSpeed() < 8.0 ) then
				CopyVector( vTmp, entity:GetDirectionVector(1) );
				vTmp.z = 0;
				NormalizeVector( vTmp );
				CopyVector( entity.AI.vDirectionRsv, vTmp );
				entity.AI.bLock = true;
				entity.gameParams.forceView = 150.0;
				entity.actor:SetParams(entity.gameParams);
				entity.AI.circleSec = System.GetCurrTime();
				FastScaleVector( vTmp, entity.AI.vDirectionRsv, 23.0 );
				local res = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearanceMain( entity, vTmp, 1.0, 5.0 );
				if ( res == 0 ) then
					local res2 = AIBehaviour.SCOUTDEFAULT:ScoutCheckFlock( entity, vTmp, 1.0, 5.0 );
					if ( res2 == false ) then
						local vTmp2 = {};
						CopyVector( vTmp, entity:GetDirectionVector(0) );				
						CopyVector( vTmp2, entity.AI.vDirectionRsv );				
						vTmp.z = 0.0;
						vTmp2.z = 0.0;
						NormalizeVector( vTmp );
						NormalizeVector( vTmp2 );
						if ( dotproduct3d( vTmp, vTmp2 ) > 0.0 ) then
							AI.SetForcedNavigation( entity.id, entity.AI.vZero );
							AI.Animation(entity.id,AIANIM_SIGNAL,"readyToFly");
							--entity.actor:PlayNetworkedSoundEvent("Sounds/alien:scout:retreat", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
						end
					end
				end
			end
			return;
		else
			local vTmp = {};
			FastScaleVector( vTmp, entity.AI.vDirectionRsv, 23.0 );
			local res = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity, vTmp, 1.0, 5.0 );
			AI.SetForcedNavigation( entity.id, vTmp );
			if ( System.GetCurrTime() - entity.AI.circleSec > 2.0 ) then
				self:SCOUTMOACATTACK_BACKATTACK_START( entity );
				return;
			end
		end


	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_LINEATTACK3_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 100.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.CurrentHook = fSCOUTMOACATTACK_LINEATTACK3;
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity:SelectPipe(0,"ScoutMOAC");

		end

	end,

	SCOUTMOACATTACK_LINEATTACK3 = function ( self, entity )
		
		if ( entity.AI.bLock == false ) then
			local vTmp = {};
			entity:GetVelocity( vTmp );
			FastScaleVector( vTmp, vTmp, 0.5 );
			local res = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity, vTmp, 1.0, 5.0 );
			AI.SetForcedNavigation( entity.id, vTmp );
			if ( entity:GetSpeed() < 4.0 ) then
				CopyVector( vTmp, entity:GetDirectionVector(1) );
				vTmp.z = 0;
				NormalizeVector( vTmp );
				CopyVector( entity.AI.vDirectionRsv, vTmp );
				entity.AI.bLock = true;
				entity.gameParams.forceView = 100.0;
				entity.actor:SetParams(entity.gameParams);
				entity.AI.circleSec = System.GetCurrTime();

			end
			return;
		else
			local vTmp = {};
			FastScaleVector( vTmp, entity.AI.vDirectionRsv, 25.0 );
			
			local res = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity, vTmp, 1.0, 5.0 );
			AI.SetForcedNavigation( entity.id, vTmp );
			if ( System.GetCurrTime() - entity.AI.circleSec > 2.0 ) then
				self:SCOUTMOACATTACK_BACKATTACK_START( entity );
				return;
			end
		end


	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_BACKATTACK_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.CurrentHook = fSCOUTMOACATTACK_BACKATTACK;
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = 0.85;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOACFire2");

		end

	end,
	--------------------------------------------------------------------------
	SCOUTMOACATTACK_BACKATTACK = function ( self, entity )
	
		if ( self:SCOUTMOACATTACK_ISTRACEPOSSIBLE( entity ) == true ) then
				self:SCOUTMOACATTACK_TRACEPATHPRE_START( entity );
				return;
		end

		local vWngN = {};
		local vFwdN = {};

		SubVectors( vFwdN, entity.AI.vTargetRsv, entity:GetPos() );
		local distance = LengthVector( vFwdN );
		vFwdN.z = 0;
		NormalizeVector( vFwdN );

		if ( distance > 100.0 ) then
			self:SCOUTMOACATTACK_DIRECTSTRAFE2_START( entity );
			return;
		end

		
		crossproduct3d( vWngN, vFwdN, entity.AI.vUp );
		vWngN.z =0;
		NormalizeVector( vWngN );
		if ( entity.AI.bRvs == true ) then
			FastScaleVector( vWngN, vWngN, -1.0 );
		end

		distance = distance - 50.0;
		if ( distance < 0.0 ) then
			distance = 0;
		end
		if ( distance > 100.0 ) then
			distance = 100.0;
		end

		local vMyPos = {};
		CopyVector( vMyPos, entity:GetPos() );

		local height = 50.0 * math.sin( ( ( distance ) / 50.0 )  * 3.1416 / 2.0 ) + entity.AI.vTargetRsv.z + 10.0;
		height = height - vMyPos.z ;
		
		FastScaleVector( vFwdN, vFwdN, -6.0 );
		FastScaleVector( vWngN, vWngN, -12.0 );
		
		local vTmp = {};
		FastSumVectors( vTmp, vFwdN, vWngN );
		vTmp.z = height;		

		local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vTmp  , 2.0 , 5.0 );
		AI.SetForcedNavigation( entity.id, vTmp );

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_ISTRACEPOSSIBLE = function ( self, entity )

		-- check the target

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then
		else
			return false;
		end

		--System.Log(entity:GetName().." SCOUTMOACATTACK_ISTRACEPOSSIBLE");

		local pathName = AI.GetNearestPathOfTypeInRange(entity.id, entity:GetPos(), 25.0, AIAnchorTable.ALIEN_COMBAT_AMBIENT_PATH, 0.0, 0);

		if ( not pathName ) then
			return false;
		end

		local vMyPassPos = {};
		local vTargetPassPos = {};

		local vMyPos = {};
		local vTargetPos = {};

		CopyVector( vMyPos, entity:GetPos() );
		CopyVector( vTargetPos, target:GetPos() );

		CopyVector( vMyPassPos,	AI.GetNearestPointOnPath( entity.id, pathName, vMyPos ) );
		CopyVector( vTargetPassPos,	AI.GetNearestPointOnPath( entity.id, pathName, vTargetPos ) );

		-- condition 1: target and my posiiton are on the same path

		local length1 = DistanceVectors( vTargetPassPos, vTargetPos );
		local length2 = DistanceVectors( vMyPassPos, vMyPos );
		local length3 = DistanceVectors( vMyPassPos, vTargetPassPos );

		if ( length1 < 30.0 and length2 < 25.0 and length3 > 10.0 and vMyPassPos.z > vTargetPos.z + 1.7 and vTargetPassPos.z > vTargetPos.z + 1.7 ) then

			local vVel = {};
			SubVectors( vVel, vMyPassPos, vMyPos );

			local vHitPos = {};
			CopyVector( vHitPos, AI.CheckVehicleColision( entity.id, vMyPos, vVel, 1.0 ) );
	
			if ( LengthVector( vHitPos ) > 0.0 ) then
				return false;
			end

			-- check the path can be locked.

			local groupCount = AI.GetGroupCount( entity.id, GROUP_ENABLED );
			if ( groupCount > 1 ) then
				for i= 1,groupCount do
					local member = AI.GetGroupMember( entity.id, i, GROUP_ENABLED );
					if( member ~= nil and member.id ~= entity.id ) then
						if ( member.AI.tracePathName == pathName ) then
								return false;
						end
					end
				end
			end

			entity.AI.tracePathName = pathName;

			local mySegNo			= AI.GetPathSegNoOnPath( entity.id, entity.AI.tracePathName, entity:GetPos() );
			local enemySegNo	= AI.GetPathSegNoOnPath( entity.id, entity.AI.tracePathName, target:GetPos() );

			if ( enemySegNo > mySegNo ) then
				entity.AI.traceRvs = false;
			else
				entity.AI.traceRvs = true;
			end

			return true;

		end

		return false;

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_TRACEPATHPRE_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 150.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.CurrentHook = fSCOUTMOACATTACK_TRACEPATHPRE;

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vDirectionRsv, AI.GetNearestPointOnPath( entity.id, entity.AI.tracePathName, entity:GetPos() ) );
			
			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOACLookAt");

		end

	end,

	SCOUTMOACATTACK_TRACEPATHPRE = function( self, entity )

		local vVel = {};

		SubVectors( vVel, entity.AI.vDirectionRsv, entity:GetPos() );
		local distance = LengthVector( vVel );

		if ( distance < 5.0 ) then
			self:SCOUTMOACATTACK_TRACEPATH_START( entity );
			return;
		end

		NormalizeVector( vVel );

		if ( distance > 10.0 ) then
			distance = 10.0;
		end

		FastScaleVector( vVel, vVel, distance );

		AI.SetForcedNavigation( entity.id, vVel  );

		if ( System.GetCurrTime() - entity.AI.circleSec > 15.0 ) then
			self:SCOUTMOACATTACK_TRACEPATH_END( entity );
		end

	end,

	SCOUTMOACATTACK_TRACEPATH_START = function( self, entity )

		AI.SetForcedNavigation( entity.id, entity.AI.vZero  );

		AI.SetPathToFollow( entity.id, entity.AI.tracePathName );			-- path name
		AI.SetPathAttributeToFollow( entity.id, true );								-- set spline

		entity.AI.CurrentHook = fSCOUTMOACATTACK_TRACEPATH;

		entity:SelectPipe(0,"do_nothing");
		if ( entity.AI.traceRvs == false ) then
			entity:SelectPipe(0,"ScoutMOACFollowPath");
		else
			entity:SelectPipe(0,"ScoutMOACFollowPathRvs");
		end

		entity.gameParams.forceView = 0.0;
		entity.actor:SetParams(entity.gameParams);

	end,

	SCOUTMOACATTACK_TRACEPATH = function( self, entity )
	end,

	SCOUTMOACATTACK_TRACEPATH_END = function( self, entity )
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"ScoutMOAC" );
		if ( entity.AI.bCloseScout == true ) then
			self:SCOUTMOACATTACK_CIRCLING_START( entity );
		else
			self:SCOUTMOACATTACK_GOAWAY_START( entity );
		end
	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_CIRCLING_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			if (AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_HELICOPTER ) then
				AIBehaviour.ScoutMOACDefault:SCOUT_CHANGESOUND( entity );
				self:SCOUTMOACATTACK_VSAIR_START( entity );
				return;
			end

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = 0.0;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOACFire3");

			if ( self:SCOUTMOACATTACK_ISTRACEPOSSIBLE( entity ) ~= true or entity.AI.CurrentHook == fSCOUTMOACATTACK_TRACEPATH ) then

				local rand = self:SCOUTMOACATTACK_RANDOM( entity, 1, 300 );
				if ( rand > 200 and entity.AI.CurrentHook ~= fSCOUTMOACATTACK_SHORTDUSH ) then
					self:SCOUTMOACATTACK_SHORTDUSH_START( entity );
					return;
				elseif ( rand > 100 ) then
					if ( entity.AI.direc == true ) then
						--entity.actor:PlayNetworkedSoundEvent("Sounds/alien:scout:anticipation_call", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
					end
					entity.AI.direc = false;
				else
					if ( entity.AI.direc == false ) then
						--entity.actor:PlayNetworkedSoundEvent("Sounds/alien:scout:anticipation_call", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
					end
					entity.AI.direc = true;
				end

			else

				local rand = self:SCOUTMOACATTACK_RANDOM( entity, 1, 300 );

				if ( rand > 150 ) then
					self:SCOUTMOACATTACK_TRACEPATHPRE_START( entity );
					return;
				elseif ( rand > 100 and entity.AI.CurrentHook ~= fSCOUTMOACATTACK_SHORTDUSH ) then
					self:SCOUTMOACATTACK_SHORTDUSH_START( entity );
					return;
				elseif ( rand > 50 ) then
					if ( entity.AI.direc == true ) then
						--entity.actor:PlayNetworkedSoundEvent("Sounds/alien:scout:anticipation_call", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
					end
					entity.AI.direc = false;
				else
					if ( entity.AI.direc == false ) then
						--entity.actor:PlayNetworkedSoundEvent("Sounds/alien:scout:anticipation_call", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
					end
					entity.AI.direc = true;
				end

			end

			local rand = self:SCOUTMOACATTACK_RANDOM( entity, 1, 300 );



			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOACFire3" );

			entity.AI.CurrentHook = fSCOUTMOACATTACK_CIRCLING;

		end

	end,

	SCOUTMOACATTACK_CIRCLING = function ( self, entity )

		local vWng = {};
		local vWngR = {};
		local vFwd = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			local vTargetPos = {};
			local vMyPos = {};
			local vVelRot = {};

			CopyVector( vTargetPos, target:GetPos() );
			CopyVector( vMyPos, entity:GetPos() );

			local vTmp = {};

			SubVectors( vTmp, target:GetPos(), entity:GetPos() );
			vTmp.z =0;
			NormalizeVector( vTmp );

			local vDist = {};
			SubVectors( vDist, target:GetPos(), entity:GetPos() );
			vDist.z =0;

			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			NormalizeVector( vFwd );
			crossproduct3d( vWng, vFwd, entity.AI.vUp );
			vWng.z = 0;

			NormalizeVector( vWng );
			if ( entity.AI.direc == true ) then
				FastScaleVector( vWng, vWng, 30.0 );
			else
				FastScaleVector( vWng, vWng, -30.0 );
			end
			FastSumVectors( vWng, vWng, entity:GetPos() );
	
			SubVectors( vFwd, vWng , target:GetPos()  );
			NormalizeVector( vFwd );
			FastScaleVector( vFwd, vFwd, 30.0 );
			FastSumVectors( vFwd, vFwd, target:GetPos() );
			SubVectors( vFwd, vFwd, entity:GetPos() );
			NormalizeVector( vFwd );
			FastScaleVector( vVelRot, vFwd, math.sin( entity.AI.bLock )* 10.0 + 3.0 );

			vVelRot.z = vVelRot.z + ( math.cos( entity.AI.bLock ) * 5.0 ) + 3.0;
			entity.AI.bLock = entity.AI.bLock + ( 10.0 * 3.1416 / 180.0 );

			if ( entity.AI.bLock > 3.1416 ) then
				self:SCOUTMOACATTACK_CIRCLING_START( entity );
				return;
			end

			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			if ( vMyPos.z > entity.AI.vTargetRsv.z + 20.0 ) then
				vVelRot.z = vVelRot.z - 5.0;
			end

			if ( vMyPos.z < vTargetPos.z + 15.0 ) then
				vVelRot.z  = 10.0;
			end

			local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vVelRot , 1, 2.5 );

			AI.SetForcedNavigation( entity.id, vVelRot );

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_SHORTDUSH_START = function( self, entity )
	
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			if (AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_HELICOPTER ) then
				AIBehaviour.ScoutMOACDefault:SCOUT_CHANGESOUND( entity );
				self:SCOUTMOACATTACK_VSAIR_START( entity );
				return;
			end
			
			local vTmp = {};
			entity:GetVelocity( vTmp );
			FastScaleVector( vTmp, vTmp, 0.1 );
			vTmp.z = 10.0;
			AI.SetForcedNavigation( entity.id, vTmp );

			entity.gameParams.forceView = 150.0;
			entity.actor:SetParams(entity.gameParams);
	
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.CurrentHook = fSCOUTMOACATTACK_SHORTDUSH;
	
			local res = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearanceMain( entity, vTmp, 1.0, 5.0 );
			if ( res == 0 ) then
				--entity.actor:PlayNetworkedSoundEvent("Sounds/alien:scout:retreat", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
				AI.Animation(entity.id,AIANIM_SIGNAL,"readyToFly");
			end			

			SubVectors( entity.AI.vDirectionRsv, target:GetPos(), entity:GetPos() );
			entity.AI.vDirectionRsv.z = 0;
			NormalizeVector( entity.AI.vDirectionRsv );

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOAC" );

		end

	end,

	SCOUTMOACATTACK_SHORTDUSH = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then
			
			local vFwd = {};
			FastScaleVector( vFwd, entity.AI.vDirectionRsv, 20.0 );
			vFwd.z = 1.0;
			--local res = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearanceMain( entity, vFwd, 1.0, 5.0 );
			AI.SetForcedNavigation( entity.id, vFwd );
			if ( System.GetCurrTime() - entity.AI.circleSec > 2.0 ) then
				self:SCOUTMOACATTACK_CIRCLING_START( entity );
				return;
			end

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_JAMMER_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = 0.0;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOACFire3");

			local rand = self:SCOUTMOACATTACK_RANDOM( entity, 1, 150 );

			if ( rand > 100 ) then
				self:SCOUTMOACATTACK_JAMMERDUSH_START( entity );
				return;
			elseif ( rand > 50 ) then
				entity.AI.direc = false;
			else
				entity.AI.direc = true;
			end

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOACFire3" );

			entity.AI.CurrentHook = fSCOUTMOACATTACK_JAMMER;

		end

	end,

	SCOUTMOACATTACK_JAMMER = function ( self, entity )

		local vWng = {};
		local vWngR = {};
		local vFwd = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			local vTargetPos = {};
			local vMyPos = {};
			local vVelRot = {};

			CopyVector( vTargetPos, target:GetPos() );
			CopyVector( vMyPos, entity:GetPos() );

			local vTmp = {};

			SubVectors( vTmp, target:GetPos(), entity:GetPos() );
			vTmp.z =0;
			NormalizeVector( vTmp );

			local vDist = {};
			SubVectors( vDist, target:GetPos(), entity:GetPos() );
			vDist.z =0;

			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			NormalizeVector( vFwd );
			crossproduct3d( vWng, vFwd, entity.AI.vUp );
			vWng.z = 0;

			NormalizeVector( vWng );
			if ( entity.AI.direc == true ) then
				FastScaleVector( vWng, vWng, 40.0 );
			else
				FastScaleVector( vWng, vWng, -40.0 );
			end
			FastSumVectors( vWng, vWng, entity:GetPos() );
	
			SubVectors( vFwd, vWng , target:GetPos()  );
			NormalizeVector( vFwd );
			FastScaleVector( vFwd, vFwd, 40.0 );
			FastSumVectors( vFwd, vFwd, target:GetPos() );

			--- check jammer
			local vJammer = {};
			CopyVector ( vJammer, entity.AI.vJammer );
			SubVectors( vTmp, vFwd, vJammer );

			local jam = LengthVector( vTmp );
			if ( jam < 45.0 ) then
	
				NormalizeVector( vTmp );
				FastScaleVector( vTmp, vTmp, 45.0 );
				FastSumVectors( vFwd, vTmp, vJammer );
			
				SubVectors( vFwd, vFwd, entity:GetPos() );
				NormalizeVector( vFwd );
				FastScaleVector( vVelRot, vFwd, math.sin( entity.AI.bLock )* 10.0 + 3.0 );

				vVelRot.z = vVelRot.z + ( math.cos( entity.AI.bLock ) * 5.0 ) + 3.0;
				entity.AI.bLock = entity.AI.bLock + ( 10.0 * 3.1416 / 180.0 );

				if ( entity.AI.bLock > 3.1416 ) then
					self:SCOUTMOACATTACK_JAMMER_START( entity );
					return;
				end
	
				CopyVector( entity.AI.vTargetRsv, target:GetPos() );
				if ( vMyPos.z > entity.AI.vTargetRsv.z + 30.0 ) then
					vVelRot.z = vVelRot.z - 5.0;
				end

				if ( vMyPos.z < vTargetPos.z + 15.0 ) then
					vVelRot.z  = 10.0;
				end
			
			else

				SubVectors( vFwd, vFwd, entity:GetPos() );
				NormalizeVector( vFwd );
				FastScaleVector( vVelRot, vFwd, math.sin( entity.AI.bLock )* 10.0 + 3.0 );

				vVelRot.z = vVelRot.z + ( math.cos( entity.AI.bLock ) * 5.0 ) + 3.0;
				entity.AI.bLock = entity.AI.bLock + ( 10.0 * 3.1416 / 180.0 );

				if ( entity.AI.bLock > 3.1416 ) then
					self:SCOUTMOACATTACK_JAMMER_START( entity );
					return;
				end
	
				CopyVector( entity.AI.vTargetRsv, target:GetPos() );
				if ( vMyPos.z > entity.AI.vTargetRsv.z + 20.0 ) then
					vVelRot.z = vVelRot.z - 5.0;
				end
	
				if ( vMyPos.z < vTargetPos.z + 15.0 ) then
					vVelRot.z  = 10.0;
				end

			end

			local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vVelRot , 1, 2.5 );
			AI.SetForcedNavigation( entity.id, vVelRot );

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_JAMMERDUSH_START = function( self, entity )
	
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then
			
			local vTmp = {};
			entity:GetVelocity( vTmp );
			FastScaleVector( vTmp, vTmp, 0.1 );
			vTmp.z = 10.0;
			AI.SetForcedNavigation( entity.id, vTmp );

			entity.gameParams.forceView = 150.0;
			entity.actor:SetParams(entity.gameParams);
	
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.CurrentHook = fSCOUTMOACATTACK_JAMMERDUSH;
	
			local res = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearanceMain( entity, vTmp, 1.0, 5.0 );
			if ( res == 0 ) then
				--AI.Animation(entity.id,AIANIM_SIGNAL,"readyToFly");
			end			

			SubVectors( entity.AI.vDirectionRsv, target:GetPos(), entity:GetPos() );
			entity.AI.vDirectionRsv.z = 0;
			NormalizeVector( entity.AI.vDirectionRsv );

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOAC" );

		end

	end,

	SCOUTMOACATTACK_JAMMERDUSH = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then
			
			local vFwd = {};
			FastScaleVector( vFwd, entity.AI.vDirectionRsv, 10.0 );
			vFwd.z = 1.0;

			-- check Jammer

			local vJammer = {};
			local vTmp = {};
			CopyVector ( vJammer, entity.AI.vJammer );
			SubVectors( vTmp, entity:GetPos(), vJammer );

			local jam = LengthVector( vTmp );
			if ( jam < 45.0 ) then
				NormalizeVector( vTmp );
				FastScaleVector( vTmp, vTmp, 10.0 );
				vTmp.x = 0;
				vTmp.y = 0;
				FastSumVectors( vFwd, vFwd, vTmp );
			end

			--local res = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearanceMain( entity, vFwd, 1.0, 5.0 );
			AI.SetForcedNavigation( entity.id, vFwd );
			if ( System.GetCurrTime() - entity.AI.circleSec > 3.0 ) then
				self:SCOUTMOACATTACK_JAMMER_START( entity );
				return;
			end

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_VSAIR_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target ) == true ) then

			------------------------------------------------------

			entity.AI.pathName = nil;
	
			if ( entity.AI.pathName == nil ) then
				entity.AI.pathName = AI.GetNearestPathOfTypeInRange( entity.id, target:GetPos(), 100000.0, AIAnchorTable.ALIEN_COMBAT_AMBIENT_PATH, 0.0, 0 );
			end

			if ( entity.AI.pathName == nil ) then
				self:SCOUTMOACATTACK_DONOTHING_START( entity );
				return;
			end

			local vMyPassPos = {};
			CopyVector( vMyPassPos,	AI.GetNearestPointOnPath( entity.id, entity.AI.pathName, entity:GetPos() ) );
			SubVectors( vMyPassPos, vMyPassPos, entity:GetPos() );
			vMyPassPos.z =0.0;
			if ( LengthVector( vMyPassPos ) > 500.0 ) then
				entity.AI.pathName = nil;
				self:SCOUTMOACATTACK_DONOTHING_START( entity );
				return;
			end
			
			------------------------------------------------------

			local vTargetToEntity = {};
			local vTargetFwd = {};
			
			SubVectors( vTargetToEntity, entity:GetPos(), target:GetPos() );
			vTargetToEntity.z =0.0;
			NormalizeVector( vTargetToEntity );
			
			CopyVector( vTargetFwd, target:GetDirectionVector(1) );
			vTargetFwd.z =0.0;
			NormalizeVector( vTargetFwd );

			local bInFov = dotproduct3d( vTargetToEntity, vTargetFwd );
			
			if ( bInFov > 0 ) then
				local vDiff = {};
				SubVectors( vDiff, target:GetPos(), entity:GetPos() );
				if ( vDiff.z > 50.0 ) then
					self:SCOUTMOACATTACK_VSAIRUP_START( entity );
					return;
				else
					self:SCOUTMOACATTACK_VSAIR2_START( entity );
					return;
				end
			end

			entity.AI.bLock3 = false;
			entity.gameParams.forceView = 200.0;
			entity.actor:SetParams(entity.gameParams);
	
			entity.AI.circleSec = System.GetCurrTime()-10.0;
			entity.AI.CurrentHook = fSCOUTMOACATTACK_VSAIR;

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOAC" );

		end

	end,

	SCOUTMOACATTACK_VSAIR = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			if ( DistanceVectors( target:GetPos(), entity:GetPos() ) < 100.0 and entity.AI.targetAveSpeed < 30.0 ) then
				self:SCOUTMOACATTACK_VSAIRCIRCLE_START( entity );
				return;		
			end

			local vTmp = {};

			if ( entity.AI.circleSec > 3.0 ) then

				local vFwd = {};
				local vWng = {};
				local vDest = {};
				
				CopyVector( vWng, target:GetDirectionVector(0) );
				vWng.z = 0.0;
				NormalizeVector( vWng );
				
				CopyVector( vFwd, target:GetDirectionVector(1) );
				vFwd.z = 0.0;
				NormalizeVector( vFwd );
				
				local vTargetToEntity = {};
				SubVectors( vTargetToEntity, entity:GetPos(), target:GetPos() );
				vTargetToEntity.z = 150.0;
				NormalizeVector( vTargetToEntity );

				local inSideFOV = dotproduct3d( vTargetToEntity, vWng );
				if ( inSideFOV > 0 ) then
					FastScaleVector( vDest, vWng, 30.0 );
					FastScaleVector( vTmp, vFwd, 30.0 );
					FastSumVectors( vDest, vDest, vTmp );
					FastSumVectors( entity.AI.vTargetRsv, vDest, target:GetPos() );
				else
					FastScaleVector( vDest, vWng, -30.0 );
					FastScaleVector( vTmp, vFwd, 30.0 );
					FastSumVectors( vDest, vDest, vTmp );
					FastSumVectors( entity.AI.vTargetRsv, vDest, target:GetPos() );
				end

			end

			------------------------------------------------------

			local vTargetToEntity = {};
			local vTargetFwd = {};
			local zdiff = 0;
			SubVectors( vTargetToEntity, entity:GetPos(), target:GetPos() );
			zdiff = vTargetToEntity.z;
			vTargetToEntity.z =0.0;
			NormalizeVector( vTargetToEntity );
			
			CopyVector( vTargetFwd, target:GetDirectionVector(1) );
			vTargetFwd.z =0.0;
			NormalizeVector( vTargetFwd );

			local bInFov = dotproduct3d( vTargetToEntity, vTargetFwd );
			
			if ( bInFov > 0 ) then
				self:SCOUTMOACATTACK_VSAIR2_START( entity );
				return;
			end
			
			local vVel = {};
			local vTmp = {};
			local vRes = {};

			SubVectors( vVel, entity.AI.vTargetRsv, entity:GetPos() );
			NormalizeVector( vVel );

			if ( entity.AI.bLock3 == false ) then
				local dwng = {};
				CopyVector( dwng, entity:GetDirectionVector(0) );
				dwng.z =0.0;
				NormalizeVector( dwng );
				local dfwd = {};
				CopyVector( dfwd, vVel );
				dfwd.z =0.0;
				NormalizeVector( dfwd );
				if ( dotproduct3d( dfwd, dwng ) > 0 ) then
					AI.Animation(entity.id,AIANIM_SIGNAL,"dodgeRight");
				else
					AI.Animation(entity.id,AIANIM_SIGNAL,"dodgeLeft");
				end
				entity.actor:PlayNetworkedSoundEvent("sounds/alien:scout_big_rolloff:dodging", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
				entity.actor:SetNetworkedAttachmentEffect(0, "dodge", "alien_special.scout.dodge", g_Vectors.v000, g_Vectors.v010, 1, 0); 
				entity.AI.bLock3 = true;
			end


			FastScaleVector( vTmp, vVel, 80.0 );
			FastScaleVector( vVel, vVel, 80.0 );

			if ( zdiff > 20.0 ) then
				vTmp.z = vTmp.z - 2.0;
				vVel.z = vVel.z - 2.0;
			elseif ( zdiff < -20.0 ) then
				vTmp.z = vTmp.z + 2.0;
				vVel.z = vVel.z + 2.0;
			else
				vTmp.z = vTmp.z + math.cos( entity.AI.cosinOp ) * 5.0;
				vVel.z = vVel.z + math.cos( entity.AI.cosinOp ) * 5.0;
			end


			CopyVector( vRes, AI.IsFlightSpaceVoidByRadius( entity:GetPos(), vTmp, 5.0 ) );
			if ( LengthVector( vRes ) > 20.0 ) then
			
				AI.SetForcedNavigation( entity.id, entity.AI.vZero );
			
			else
			
				local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vVel , 1.0 , 5.0 );
				AI.SetForcedNavigation( entity.id, vVel );

			end

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_VSAIR2_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			if ( DistanceVectors( target:GetPos(), entity:GetPos() ) < 100.0 and entity.AI.targetAveSpeed < 30.0 ) then
				self:SCOUTMOACATTACK_VSAIRCIRCLE_START( entity );
				return;		
			end

			entity.AI.pathName = nil;
	
			if ( entity.AI.pathName == nil ) then
				entity.AI.pathName = AI.GetNearestPathOfTypeInRange( entity.id, target:GetPos(), 100000.0, AIAnchorTable.ALIEN_COMBAT_AMBIENT_PATH, 0.0, 0 );
			end

			if ( entity.AI.pathName == nil ) then
				self:SCOUTMOACATTACK_DONOTHING_START( entity );
				return;
			end

			local vMyPassPos = {};
			CopyVector( vMyPassPos,	AI.GetNearestPointOnPath( entity.id, entity.AI.pathName, entity:GetPos() ) );
			SubVectors( vMyPassPos, vMyPassPos, entity:GetPos() );
			vMyPassPos.z =0.0;
			if ( LengthVector( vMyPassPos ) > 500.0 ) then
				entity.AI.pathName = nil;
				self:SCOUTMOACATTACK_DONOTHING_START( entity );
				return;
			end


			local vTargetToEntity = {};
			local vTargetFwd = {};
			
			SubVectors( vTargetToEntity, entity:GetPos(), target:GetPos() );
			local destLength = LengthVector(  vTargetToEntity );
			vTargetToEntity.z =0.0;
			NormalizeVector( vTargetToEntity );
			
			CopyVector( vTargetFwd, target:GetDirectionVector(1) );
			vTargetFwd.z =0.0;
			NormalizeVector( vTargetFwd );

			local bInFov = dotproduct3d( vTargetToEntity, vTargetFwd );
			
			if ( bInFov > 0 and destLength > 180) then
				self:SCOUTMOACATTACK_VSAIRPAUSE_START( entity );
				return;
			end

			entity.AI.bLock3 = false;
			entity.gameParams.forceView = 200.0;
			entity.actor:SetParams(entity.gameParams);
	
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.CurrentHook = fSCOUTMOACATTACK_VSAIR2;

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOAC" );

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_VSAIR2 = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			if ( DistanceVectors( target:GetPos(), entity:GetPos() ) < 100.0 and entity.AI.targetAveSpeed < 30.0 ) then
				self:SCOUTMOACATTACK_VSAIRCIRCLE_START( entity );
				return;		
			end

			local vTmp = {};
			local vFwd = {};
			local vWng = {};
			local vDst = {};
			local vAssumedPos = {};
			local vAssumedPathPos = {};
			
			CopyVector( vWng, target:GetDirectionVector(0) );
			vWng.z = 0.0;
			NormalizeVector( vWng );
			
			CopyVector( vFwd, target:GetDirectionVector(1) );
			vFwd.z = 0.0;
			NormalizeVector( vFwd );
			
			local vTargetToEntity = {};
			SubVectors( vTargetToEntity, entity:GetPos(), target:GetPos() );
			local diffZ = vTargetToEntity.z;
			vTargetToEntity.z = 0.0;
			local targetLength = LengthVector( vTargetToEntity );
			NormalizeVector( vTargetToEntity );

			local vVel = {};
			target:GetVelocity( vVel );
			vVel.z =0;
			if ( LengthVector( vVel ) < 5.0 ) then
				CopyVector( vVel, target:GetDirectionVector(1) );
			end
			vVel.z = 0.0;
			NormalizeVector( vVel );
			FastScaleVector( vVel, vVel, 230.0 );

			FastSumVectors( vAssumedPos, target:GetPos(), vVel );

			CopyVector( vAssumedPathPos,	AI.GetNearestPointOnPath( target.id, entity.AI.pathName, vAssumedPos ) );
			vAssumedPathPos.z = 0.0;
				
			local inSideFOV = dotproduct3d( vTargetToEntity, vWng );
			if ( inSideFOV > 0 ) then
				FastScaleVector( vDst, vWng, 30.0 );
				FastSumVectors( vDst, vDst, vAssumedPathPos );
				CopyVector( vTmp, target:GetPos() );
				vDst.z = vTmp.z;
			else
				FastScaleVector( vDst, vWng, -30.0 );
				FastSumVectors( vDst, vDst, vAssumedPathPos );
				CopyVector( vTmp, target:GetPos() );
				vDst.z = vTmp.z;
			end

			local vMeToDst  = {};
			SubVectors( vMeToDst, vDst, entity:GetPos() );
			local dstLength = LengthVector( vMeToDst );

			vMeToDst.z = 0.0;
			NormalizeVector( vMeToDst );
			
			local vMyWng = {};
			CopyVector( vMyWng, entity:GetDirectionVector(0) );
			vMyWng.z = 0.0;
			NormalizeVector( vMyWng );
			
			local vMyFwd = {};
			local vMyFwdRot = {};
			CopyVector( vMyFwd,  entity:GetDirectionVector(1) );
			vMyFwd.z = 0.0;
			NormalizeVector( vMyFwd );

			local dotFwd = dotproduct3d( vMyFwd, vMeToDst );
			if ( dotFwd > math.cos( 3.1416 * 30.0 / 180.0 ) ) then
				CopyVector( vMyFwdRot, vMyFwd ); 
			else
				local dotWng = dotproduct3d( vMyWng, vMeToDst );
				local actionAngle = 3.1416* 120.0 / 180.0;
				if ( dotWng > 0 ) then
						RotateVectorAroundR( vMyFwdRot, vMyFwd, entity.AI.vUp, actionAngle * minUpdateTime * -1.0 );
				else
						RotateVectorAroundR( vMyFwdRot, vMyFwd, entity.AI.vUp, actionAngle * minUpdateTime * 1.0 );
				end
			end

			SubVectors( vMyFwdRot, vAssumedPathPos, entity:GetPos() );
			vMyFwdRot.z =0;
			NormalizeVector( vMyFwdRot );

			local inFwdFOV = dotproduct3d( vTargetToEntity, vFwd );
			if ( inFwdFOV < 0.0 and dstLength > 50.0 ) then
				self:SCOUTMOACATTACK_VSAIR_START( entity );
				return;
			end


			if ( inFwdFOV >  0 ) then
				if ( targetLength > 160.0 ) then
					self:SCOUTMOACATTACK_VSAIRPAUSE_START( entity );
					return;
				end
			end

			if ( dstLength > 100.0 ) then
				dstLength = 80.0;
			elseif ( dstLength > 50.0 ) then
				dstLength = dstLength -20.0;
			else
			end

			dstLength = 80.0;

			if ( System.GetCurrTime() - entity.AI.circleSec > 15.0 ) then
				self:SCOUTMOACATTACK_VSAIRPAUSE_START( entity );
				return;
			end

			FastScaleVector( vTmp, vMyFwdRot, dstLength );
			FastScaleVector( vMyFwdRot, vMyFwdRot, dstLength );

			if ( dstLength < 100.0 and diffZ < 50.0 ) then
				vMyFwdRot.z = math.sin( (100.0-dstLength) * 3.1416 * 0.5 / 100.0 ) * 15.0;
			else
			end	
			vMyFwdRot.z = vMyFwdRot.z + math.cos( entity.AI.cosinOp ) * 5.0;
			vTmp.z = vTmp.z + math.cos( entity.AI.cosinOp ) * 5.0;

			if ( entity.AI.bLock3 == false ) then
				local dwng = {};
				CopyVector( dwng, entity:GetDirectionVector(0) );
				dwng.z =0.0;
				NormalizeVector( dwng );
				local dfwd = {};
				CopyVector( dfwd, vMyFwdRot );
				dfwd.z =0.0;
				NormalizeVector( dfwd );
				if ( dotproduct3d( dfwd, dwng ) > 0 ) then
					AI.Animation(entity.id,AIANIM_SIGNAL,"dodgeRight");
				else
					AI.Animation(entity.id,AIANIM_SIGNAL,"dodgeLeft");
				end
				entity.actor:PlayNetworkedSoundEvent("sounds/alien:scout_big_rolloff:dodging", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
				entity.actor:SetNetworkedAttachmentEffect(0, "dodge", "alien_special.scout.dodge", g_Vectors.v000, g_Vectors.v010, 1, 0); 
				entity.AI.bLock3 = true;
			end

			local vRes = {};
			CopyVector( vRes, AI.IsFlightSpaceVoidByRadius( entity:GetPos(),  vTmp, 2.0 ) );
			if ( LengthVector( vRes ) > 20.0 ) then
			
				AI.SetForcedNavigation( entity.id, entity.AI.vZero );
			
			else
			
				local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vMyFwdRot , 1.0 , 2.0 );
				AI.SetForcedNavigation( entity.id, vMyFwdRot );

			end

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_VSAIRPAUSE_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();

			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			SubVectors( entity.AI.vDirectionRsv, target:GetPos(), entity:GetPos() );
			NormalizeVector( entity.AI.vDirectionRsv );

			local vTmp = {};
			SubVectors( vTmp, target:GetPos(), entity:GetPos() );
			vTmp.z =0;
			
			if ( random( 1,256 ) > 200 and  LengthVector( vTmp ) > 180.0  and target:GetSpeed() <5.0 ) then

				entity.gameParams.forceView = 0.0;
				entity.actor:SetParams(entity.gameParams);

				--entity.actor:PlayNetworkedSoundEvent("Sounds/alien:scout:singularity", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);

				entity:SelectPrimaryWeapon();
				entity:SelectSecondaryWeapon();
				 
				AI.CreateGoalPipe("ScoutMOACMain6");
				AI.PushGoal("ScoutMOACMain6","+animation",0,AIANIM_SIGNAL,"fireSingularityCannon");	
				AI.PushGoal("ScoutMOACMain6","+timeout",1,2);
				AI.PushGoal("ScoutMOACMain6","+firecmd",0,FIREMODE_FORCED);
				AI.PushGoal("ScoutMOACMain6","+timeout",1,3);
				AI.PushGoal("ScoutMOACMain6","+firecmd",1,0);
				AI.PushGoal("ScoutMOACMain6","+timeout",1,30.0);
				entity:SelectPipe(0,"ScoutMOACMain6");
				entity.AI.bLock = false;
				entity.AI.CurrentHook = fSCOUTMOACATTACK_VSAIRPAUSE;
				
			else

				entity.gameParams.forceView = 0.0;
				entity.actor:SetParams(entity.gameParams);

				entity:SelectPipe(0,"do_nothing");
				entity:SelectPipe(0,"ScoutMOACFire4" );
				entity.AI.bLock = true;
				entity.AI.CurrentHook = fSCOUTMOACATTACK_VSAIRPAUSE;

				local vTmp = {};
				FastScaleVector( vTmp, entity.AI.vUp , 10.0 );
		
				AI.SetForcedNavigation( entity.id, vTmp );

			end

		end

	end,


	--------------------------------------------------------------------------
	SCOUTMOACATTACK_VSAIRPAUSE = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			if ( DistanceVectors( target:GetPos(), entity:GetPos() ) < 100.0 and entity.AI.targetAveSpeed < 30.0 ) then
				self:SCOUTMOACATTACK_VSAIRCIRCLE_START( entity );
				return;		
			end

			if ( entity.AI.bLock == true ) then
	
					self:SCOUTMOACATTACK_VSAIR3_START( entity );
					return;
		
	
			else
				
				if ( System.GetCurrTime() -  entity.AI.circleSec > 5.5 ) then
					entity:SelectPrimaryWeapon();
					self:SCOUTMOACATTACK_VSAIR3_START( entity );
					return;
				end
	
				local vTmp = {};
				SubVectors( vTmp, target:GetPos(), entity:GetPos() );
				NormalizeVector( vTmp );
				FastScaleVector( vTmp, vTmp, 5.0 );
				AI.SetForcedNavigation( entity.id, vTmp );
	
			end

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_VSAIR3_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			local vVel = {};
			target:GetVelocity( vVel );
			vVel.z =0;
			if ( LengthVector( vVel ) < 1.0 ) then
				CopyVector( vVel, target:GetDirectionVector(1) );
			end
			vVel.z = 0.0;
			FastScaleVector( vVel, vVel, 2.0 );
			FastSumVectors( entity.AI.vTargetRsv, entity.AI.vTargetRsv, vVel );

			SubVectors( entity.AI.vDirectionRsv, target:GetPos(), entity:GetPos() );
			NormalizeVector( entity.AI.vDirectionRsv );

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );

			local rnd = random(1,3);

			if ( rnd == 1 ) then
				RotateVectorAroundR( entity.AI.vMyPosRsv, entity.AI.vUp, entity.AI.vDirectionRsv, 3.1416 * 45.0 /180.0  );
			elseif ( rnd == 2 ) then
				RotateVectorAroundR( entity.AI.vMyPosRsv, entity.AI.vUp, entity.AI.vDirectionRsv, -3.1416 * 45.0 /180.0  );
			else
				RotateVectorAroundR( entity.AI.vMyPosRsv, entity.AI.vUp, entity.AI.vDirectionRsv, 0  );
			end

			entity.AI.bLock3 = false;
			entity.gameParams.forceView = 200.0;
			entity.actor:SetParams(entity.gameParams);
	
			entity.AI.circleSec = System.GetCurrTime();

			--entity.actor:PlayNetworkedSoundEvent("Sounds/alien:scout:retreat", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);

			entity.AI.CurrentHook = fSCOUTMOACATTACK_VSAIR3;

		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_VSAIR3 = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			if ( DistanceVectors( target:GetPos(), entity:GetPos() ) < 100.0 and entity.AI.targetAveSpeed < 30.0 ) then
				self:SCOUTMOACATTACK_VSAIRCIRCLE_START( entity );
				return;		
			end

			if ( System.GetCurrTime() - entity.AI.circleSec > 2.0 ) then
				CopyVector( entity.AI.vTargetRsv, target:GetPos() );
				local vVel = {};
				target:GetVelocity( vVel );
				vVel.z =0;
				if ( LengthVector( vVel ) < 1.0 ) then
					CopyVector( vVel, target:GetDirectionVector(1) );
				end
				vVel.z = 0.0;
				FastScaleVector( vVel, vVel, 2.0 );
				FastSumVectors( entity.AI.vTargetRsv, entity.AI.vTargetRsv, vVel );
				entity.AI.circleSec = System.GetCurrTime();
			end

			local vDir = {};
			local vDir2 = {};
			local vTmp = {};
			local vTmp2 = {};
			local vTmp3 = {};
			
			SubVectors( vDir, entity.AI.vTargetRsv, entity:GetPos() );
			local distance =LengthVector( vDir );
			vDir.z =0.0;
			NormalizeVector( vDir );

			CopyVector( vTmp, entity.AI.vDirectionRsv );
			vTmp.z =0;
			NormalizeVector( vTmp );

			SubVectors( vDir2, target:GetPos(), entity:GetPos() );
			vDir2.z =0.0;
			NormalizeVector( vDir2 );

			local bInFov = dotproduct3d( vDir, vTmp );
			local bInFov2 = dotproduct3d( vDir2, vTmp );

			if ( System.GetCurrTime() - entity.AI.circleSec > 10.0 ) then
				self:SCOUTMOACATTACK_VSAIR_START( entity );
				return;
			end
			
			if ( bInFov < 0 ) then
				self:SCOUTMOACATTACK_VSAIR_START( entity );
				return;
			end
			if ( bInFov2 < 0 ) then
				self:SCOUTMOACATTACK_VSAIR_START( entity );
				return;
			end			

			CopyVector( vTmp3, entity.AI.vZero );

			local vMyPos = {};
			local vTargetPos = {};

			CopyVector( vMyPos , entity:GetPos() );
			CopyVector( vTargetPos ,target:GetPos() );
			if ( vTargetPos.z > vMyPos.z + 10.0 ) then
				vTmp3.z = 10.0;
			end
			if ( vTargetPos.z < vMyPos.z - 10.0 ) then
				vTmp3.z = -10.0;
			end

			if ( bInFov2 < 0 ) then

				FastScaleVector( vTmp, entity.AI.vDirectionRsv, 80.0 );
				FastScaleVector( vTmp2, entity.AI.vDirectionRsv, 80.0 );
				FastSumVectors( vTmp, vTmp, vTmp3 );
				FastSumVectors( vTmp2, vTmp2, vTmp3 );

			else
				if ( distance < 60.0 ) then
		--			FastScaleVector( vTmp3, entity.AI.vMyPosRsv, math.sin( (60.0-distance) * 3.1416 * 0.5 / 60.0 ) * 20.0 );
				end
				FastScaleVector( vTmp, entity.AI.vDirectionRsv, 10.0 );
				FastScaleVector( vTmp2, entity.AI.vDirectionRsv,10.0 );
				FastSumVectors( vTmp, vTmp, vTmp3 );
				FastSumVectors( vTmp2, vTmp2, vTmp3 );
			end
			
			vTmp.z = vTmp.z + math.cos( entity.AI.cosinOp ) * 5.0;
			vTmp2.z = vTmp2.z + math.cos( entity.AI.cosinOp ) * 5.0;

			if ( entity.AI.bLock3 == false and System.GetCurrTime() - entity.AI.circleSec > 0.5 ) then
				local dwng = {};
				CopyVector( dwng, entity:GetDirectionVector(0) );
				dwng.z =0.0;
				NormalizeVector( dwng );
				local dfwd = {};
				CopyVector( dfwd, vTmp );
				dfwd.z =0.0;
				NormalizeVector( dfwd );
				if ( dotproduct3d( dfwd, dwng ) > 0 ) then
					AI.Animation(entity.id,AIANIM_SIGNAL,"dodgeRight");
				else
					AI.Animation(entity.id,AIANIM_SIGNAL,"dodgeLeft");
				end
				entity.actor:PlayNetworkedSoundEvent("sounds/alien:scout_big_rolloff:dodging", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
				entity.actor:SetNetworkedAttachmentEffect(0, "dodge", "alien_special.scout.dodge", g_Vectors.v000, g_Vectors.v010, 1, 0); 
				entity.AI.bLock3 = true;
			end

			local vRes = {};
			CopyVector( vRes, AI.IsFlightSpaceVoidByRadius( entity:GetPos(), vTmp, 2.0 ) );
			if ( LengthVector( vRes ) > 15.0 ) then
				self:SCOUTMOACATTACK_VSAIR_START( entity );
				return;
				
			else
			
				local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vTmp2 , 1.0 , 2.0 );
				AI.SetForcedNavigation( entity.id, vTmp2 );

			end


		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_VSAIRCIRCLE_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = 0.0;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOACFire3");

			local rand = self:SCOUTMOACATTACK_RANDOM( entity, 1, 200 );

			if ( rand > 100 ) then
				entity.AI.direc = false;
			else
				entity.AI.direc = true;
			end

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOACFire3" );

			entity.AI.CurrentHook = fSCOUTMOACATTACK_VSAIRCIRCLE;

		end

	end,

	SCOUTMOACATTACK_VSAIRCIRCLE = function ( self, entity )

		local vWng = {};
		local vWngR = {};
		local vFwd = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			local vTargetPos = {};
			local vMyPos = {};
			local vVelRot = {};

			CopyVector( vTargetPos, target:GetPos() );
			CopyVector( vMyPos, entity:GetPos() );

			local vTmp = {};

			SubVectors( vTmp, target:GetPos(), entity:GetPos() );
			vTmp.z =0;
			NormalizeVector( vTmp );

			local vDist = {};
			SubVectors( vDist, target:GetPos(), entity:GetPos() );
			vDist.z =0;

			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			NormalizeVector( vFwd );
			crossproduct3d( vWng, vFwd, entity.AI.vUp );
			vWng.z = 0;

			NormalizeVector( vWng );
			if ( entity.AI.direc == true ) then
				FastScaleVector( vWng, vWng, 50.0 );
			else
				FastScaleVector( vWng, vWng, -50.0 );
			end
			FastSumVectors( vWng, vWng, entity:GetPos() );
	
			SubVectors( vFwd, vWng , target:GetPos()  );
			NormalizeVector( vFwd );
			FastScaleVector( vFwd, vFwd, 50.0 );
			FastSumVectors( vFwd, vFwd, target:GetPos() );
			SubVectors( vFwd, vFwd, entity:GetPos() );
			NormalizeVector( vFwd );
			FastScaleVector( vVelRot, vFwd, 20.0  );

			vVelRot.z = vVelRot.z + ( math.cos( entity.AI.bLock ) * 5.0 );
			entity.AI.bLock = entity.AI.bLock + ( 10.0 * 3.1416 / 180.0 );

			if ( entity.AI.bLock > 3.1416 ) then
				self:SCOUTMOACATTACK_VSAIRCIRCLE_START( entity );
				return;
			end

			if ( vMyPos.z < vTargetPos.z + 15.0 ) then
				vVelRot.z = - 2.5;
			end

			if ( vMyPos.z < vTargetPos.z ) then
				vVelRot.z  = 2.5;
			end

			local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vVelRot , 1, 2.5 );

			AI.SetForcedNavigation( entity.id, vVelRot );

		end

	end,


	--------------------------------------------------------------------------
	SCOUTMOACATTACK_VSAIRUP_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			SubVectors( entity.AI.vDirectionRsv, target:GetPos(), entity:GetPos() );
			entity.AI.vDirectionRsv.z =0.0;
			FastScaleVector( entity.AI.vDirectionRsv, entity.AI.vDirectionRsv, 0.3 );

			entity.AI.vDirectionRsv.z =30.0;

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOAC" );
	
			entity.gameParams.forceView = 200.0;
			entity.actor:SetParams(entity.gameParams);

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOACFire4" );
			entity.AI.bLock = true;
			entity.AI.CurrentHook = fSCOUTMOACATTACK_VSAIRUP;

			entity.actor:PlayNetworkedSoundEvent("sounds/alien:scout_big_rolloff:dodging", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
			entity.actor:SetNetworkedAttachmentEffect(0, "dodge", "alien_special.scout.dodge", g_Vectors.v000, g_Vectors.v010, 1, 0); 

			AI.SetForcedNavigation( entity.id, entity.AI.vDirectionRsv );

		end

	end,


	--------------------------------------------------------------------------
	SCOUTMOACATTACK_VSAIRUP = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			local vDif = {};
			SubVectors( vDif, target:GetPos(), entity:GetPos() );
			if ( vDif.z < 20.0 ) then
				AI.SetForcedNavigation( entity.id, entity.AI.vZero );
				self:SCOUTMOACATTACK_VSAIR_START( entity );
				return;
			end

			AI.SetForcedNavigation( entity.id, entity.AI.vDirectionRsv );
			
		end

	end,

	--------------------------------------------------------------------------
	SCOUTMOACATTACK_VSCLOAK_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.ScoutMOACDefault:scoutCheckHostile( entity, target )==true ) then

			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = 0.0;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOACFire3");

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"ScoutMOAC" );

			entity.AI.CurrentHook = fSCOUTMOACATTACK_VSCLOAK;

		end

	end,

	SCOUTMOACATTACK_VSCLOAK = function ( self, entity )

		local bClockedTarget = false;

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then
			if ( AI.GetTargetType( entity.id ) == AITARGET_MEMORY ) then
				if ( target.actor and target.actor:GetNanoSuitMode() == 2 ) then
					bClockedTarget = true;
				end
			end
		end
		
		if ( bClockedTarget==false ) then
			if ( System.GetCurrTime() - entity.AI.circleSec > 3.0 ) then
				if ( entity.AI.ascensionScout and entity.AI.ascensionScout == true ) then
				else
					self:SCOUTMOACATTACK_FOUNDPLAYER_START( entity );
					return;
				end
			end
		end
		
		if ( System.GetCurrTime() - entity.AI.circleSec < 3.0 ) then
			AI.SetForcedNavigation( entity.id, entity.AI.vZero );
			return;
		end

		local vWng = {};
		local vWngR = {};
		local vFwd = {};

		local vTargetPos = {};
		local vMyPos = {};
		local vVelRot = {};

		CopyVector( vTargetPos, entity.AI.vTargetRsv );
		CopyVector( vMyPos, entity:GetPos() );

		local vTmp = {};

		SubVectors( vTmp, entity.AI.vTargetRsv, entity:GetPos() );
		vTmp.z =0;
		NormalizeVector( vTmp );

		local vDist = {};
		SubVectors( vDist, entity.AI.vTargetRsv, entity:GetPos() );
		vDist.z =0;

		SubVectors( vFwd, entity.AI.vTargetRsv, entity:GetPos() );
		NormalizeVector( vFwd );
		crossproduct3d( vWng, vFwd, entity.AI.vUp );
		vWng.z = 0;

		NormalizeVector( vWng );
		if ( entity.AI.direc == true ) then
			FastScaleVector( vWng, vWng, 30.0 );
		else
			FastScaleVector( vWng, vWng, -30.0 );
		end
		FastSumVectors( vWng, vWng, entity:GetPos() );

		SubVectors( vFwd, vWng , entity.AI.vTargetRsv  );
		NormalizeVector( vFwd );
		FastScaleVector( vFwd, vFwd, 30.0 );
		FastSumVectors( vFwd, vFwd, entity.AI.vTargetRsv );
		SubVectors( vFwd, vFwd, entity:GetPos() );
		NormalizeVector( vFwd );
		FastScaleVector( vVelRot, vFwd, math.sin( entity.AI.bLock )* 10.0 + 3.0 );

		vVelRot.z = vVelRot.z + ( math.cos( entity.AI.bLock ) * 5.0 ) + 3.0;
		entity.AI.bLock = entity.AI.bLock + ( 10.0 * 3.1416 / 180.0 );

		if ( vMyPos.z > entity.AI.vTargetRsv.z + 20.0 ) then
			vVelRot.z = vVelRot.z - 5.0;
		end

		if ( vMyPos.z < vTargetPos.z + 15.0 ) then
			vVelRot.z  = 10.0;
		end

		local res  = AIBehaviour.SCOUTDEFAULT:ScoutCheckClearance( entity , vVelRot , 1, 2.5 );

		AI.SetForcedNavigation( entity.id, vVelRot );

	end,

}
