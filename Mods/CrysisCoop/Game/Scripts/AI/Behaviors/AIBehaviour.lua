-- Global root table of behaviours

AIBehaviour = {

	AVAILABLE = {

	-- hardcoding behavior for video recording
		DemoIdle = "Scripts/AI/Behaviors/Personalities/demo/DemoIdle.lua",
		DemoShoot = "Scripts/AI/Behaviors/Personalities/demo/DemoShoot.lua",
		DemoShoot1 = "Scripts/AI/Behaviors/Personalities/demo/DemoShoot1.lua",		
	-- hardcoding behavior for video recording		

		-- Random test behavior
		TestIdle = "Scripts/AI/Behaviors/Personalities/demo/TestIdle.lua",
		TestIdle2 = "Scripts/AI/Behaviors/Personalities/demo/TestIdle2.lua",
		TestIdle3 = "Scripts/AI/Behaviors/Personalities/demo/TestIdle3.lua",
		SuperDumbIdle = "Scripts/AI/Behaviors/Personalities/demo/SuperDumbIdle.lua",

		FriendlyNPCIdle = "Scripts/AI/Behaviors/Personalities/FriendlyNPC/FriendlyNPCIdle.lua",
		FollowerNPCIdle = "Scripts/AI/Behaviors/Personalities/FollowerNPC/FollowerNPCIdle.lua",
	
		-- for test purposes
		Job_zTest = "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_zTest.lua",			
	
		--3d nav prototype
		Job_3D		= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_3D.lua",
		Job_3DPath		= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_3DPath.lua",		

		SuitBossIdle  	= "Scripts/AI/Behaviors/Personalities/SuitBoss/SuitBossIdle.lua",
		SuitHurricaneIdle		= "Scripts/AI/Behaviors/Personalities/SuitHurricane/SuitHurricaneIdle.lua",
		SuitSniperIdle       	= "Scripts/AI/Behaviors/Personalities/SuitSniper/SuitSniperIdle.lua",

		--MountedGuy		= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/MountedGuy.lua",

		Dumb		= "Scripts/AI/Behaviors/Personalities/SHARED/Other/Dumb.lua",

		-- JOBS
		----------------------------------------------------------	
		--patrols
		Job_PatrolPath		= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_PatrolPath.lua",
		Job_PatrolPathNoIdle	= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_PatrolPathNoIdle.lua",
		Job_PatrolCircle	= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_PatrolCircle.lua",
		Job_FormPatrolCircle	= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_FormPatrolCircle.lua",
		Job_WalkFollow	= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_WalkFollow.lua",		
		Job_PatrolLinear	= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_PatrolLinear.lua",
--		Job_WalkCircle	= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_WalkCircle.lua",
		Job_FormPatrolLinear	= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_FormPatrolLinear.lua",
		Job_PatrolNode		= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_PatrolNode.lua",
		Job_FormPatrolNode	= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_FormPatrolNode.lua",
		Job_CarryBox		= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_CarryBox.lua",
		Job_PracticeFire	= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_PracticeFire.lua",
		Job_Investigate		= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_Investigate.lua",
		Job_RunTo		= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_RunTo.lua",
		Job_RunToActivated	= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_RunToActivated.lua",
		-- added in FP
		Job_LeadFormationPath	= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_LeadFormationPath.lua",
		Job_GenericIdle		= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_GenericIdle.lua",	
		
		-- standing
		Job_Observe		= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_Observe.lua",
		Job_StandIdle		= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_StandIdle.lua",	
		Job_ProneIdle		= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_ProneIdle.lua",	
		Job_LookAround	= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_LookAround.lua",	

--		CommanderIdle		= "Scripts/AI/Behaviors/Personalities/Commander/CommanderIdle.lua",

		WatchTowerGuardIdle		= "Scripts/AI/Behaviors/Personalities/WatchTowerGuard/WatchTowerGuardIdle.lua",

		----------------------------------------------------------
		-- for in-game spawned AI - to ignore deadbodies/interesting sounds/etc.
		HBaseFakeAlerted       = "Scripts/AI/Behaviors/Personalities/HumanBase/HBaseFakeAlerted.lua",
		SneakerIdle       		= "Scripts/AI/Behaviors/Personalities/Sneaker/SneakerIdle.lua",
		SniperIdle       		= "Scripts/AI/Behaviors/Personalities/Sniper/SniperIdle.lua",

		UseMountedIdle		= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/UseMountedIdle.lua",

		----------------------------------------------------------

		-- Hostage
		----------------------------------------------------------
		HostageIdle       	= "Scripts/AI/Behaviors/Personalities/Hostage/HostageIdle.lua",
--		HostageTied       = "Scripts/AI/Behaviors/Personalities/Hostage/HostageTied.lua",

		----------------------------------------------------------
		-- Civilian
		----------------------------------------------------------
		CivilianIdle       	= "Scripts/AI/Behaviors/Personalities/Civilian/CivilianIdle.lua",
		----------------------------------------------------------
		

		-- vehicles
		----------------------------------------------------------
		ProtectVehicle	= "Scripts/AI/Behaviors/Personalities/SHARED/Other/ProtectVehicle.lua",
		--	cars
		CarIdle			= "Scripts/AI/Behaviors/Vehicles/Car/CarIdle.lua",		
		-- tanks
		TankIdle			= "Scripts/AI/Behaviors/Vehicles/Tank/TankIdle.lua",		
		TankCloseIdle = "Scripts/AI/Behaviors/Vehicles/TankClose/TankCloseIdle.lua",		
		TankFixedIdle = "Scripts/AI/Behaviors/Vehicles/TankFixed/TankFixedIdle.lua",		
		WarriorIdle = "Scripts/AI/Behaviors/Vehicles/Warrior/WarriorIdle.lua",		
		AAAIdle			= "Scripts/AI/Behaviors/Vehicles/AAA/AAAIdle.lua",		
		APCIdle			= "Scripts/AI/Behaviors/Vehicles/APC/APCIdle.lua",		
		--	boats
		BoatIdle			= "Scripts/AI/Behaviors/Vehicles/Boat/BoatIdle.lua",
		PatrolBoatIdle			= "Scripts/AI/Behaviors/Vehicles/PatrolBoat/PatrolBoatIdle.lua",
		-- helicopter
		HeliIdle			= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliIdle.lua",		
		HeliAggressiveIdle			= "Scripts/AI/Behaviors/Vehicles/HeliAggressive/HeliAggressiveIdle.lua",		
		-- vtol
		VtolIdle			= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolIdle.lua",		


		-- aliens
		----------------------------------------------------------

		-- Guard
		GuardDumb						= "Scripts/AI/Behaviors/Aliens/Guard/GuardDumb.lua",
		GuardNeueIdle				= "Scripts/AI/Behaviors/Aliens/Guard/GuardNeueIdle.lua",

		-- Trooper
		TrooperIdle = "Scripts/AI/Behaviors/Aliens/Trooper/TrooperIdle.lua",
		TrooperLure = "Scripts/AI/Behaviors/Aliens/Trooper/TrooperLure.lua",
		TrooperLeaderIdle		= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperLeader/TrooperLeaderIdle.lua",
		-- Scout
		ScoutIdle = "Scripts/AI/Behaviors/Aliens/Scout/ScoutIdle2.lua",
		ScoutMeleeIdle = "Scripts/AI/Behaviors/Aliens/ScoutMelee/ScoutMeleeIdle.lua",
		ScoutMOACIdle = "Scripts/AI/Behaviors/Aliens/ScoutMOAC/ScoutMOACIdle.lua",
		ScoutMOARIdle = "Scripts/AI/Behaviors/Aliens/ScoutMOAR/ScoutMOARIdle.lua",
		--[[
		ScoutIdle = "Scripts/AI/Behaviors/Aliens/Scout/ScoutIdle.lua",
		ScoutPatrol = "Scripts/AI/Behaviors/Aliens/Scout/ScoutPatrol.lua",
		ScoutSearch = "Scripts/AI/Behaviors/Aliens/Scout/ScoutSearch.lua",
		ScoutEscort = "Scripts/AI/Behaviors/Aliens/Scout/ScoutEscort.lua",
		ScoutExit = "Scripts/AI/Behaviors/Aliens/Scout/ScoutExit.lua",
		ScoutDumbAttack = "Scripts/AI/Behaviors/Aliens/Scout/ScoutDumbAttack.lua",
		--]]
		-- Hunter
		HunterIdle = "Scripts/AI/Behaviors/Aliens/Hunter/HunterIdle.lua",
		HunterPatrol = "Scripts/AI/Behaviors/Aliens/Hunter/HunterPatrol.lua",
		HunterAttack = "Scripts/AI/Behaviors/Aliens/Hunter/HunterAttack.lua",
		-- Warrior
		-- WarriorIdle = "Scripts/AI/Behaviors/Aliens/Warrior/WarriorIdle.lua",
	},
	
	INTERNAL = {

		Idle_Talk		= "Scripts/AI/Behaviors/Personalities/SHARED/Idles/Idle_Talk.lua",

		FriendlyNPCAttack = "Scripts/AI/Behaviors/Personalities/FriendlyNPC/FriendlyNPCAttack.lua",
		FollowerNPCAttack = "Scripts/AI/Behaviors/Personalities/FollowerNPC/FollowerNPCAttack.lua",

		GroupCombat			= "Scripts/AI/Behaviors/Personalities/SHARED/COMBAT/GroupCombat.lua",
		GroupHide			= "Scripts/AI/Behaviors/Personalities/SHARED/COMBAT/GroupHide.lua",
		GroupUnHide			= "Scripts/AI/Behaviors/Personalities/SHARED/COMBAT/GroupUnHide.lua",
		GroupUnHideCover	= "Scripts/AI/Behaviors/Personalities/SHARED/COMBAT/GroupUnHideCover.lua",
		GroupInitCombat	= "Scripts/AI/Behaviors/Personalities/SHARED/COMBAT/GroupInitCombat.lua",
		GroupSearch			= "Scripts/AI/Behaviors/Personalities/SHARED/Other/GroupSearch.lua",
		Job_OrderMove		= "Scripts/AI/Behaviors/Personalities/SHARED/Jobs/Job_OrderMove.lua",
		ProtectVehicleAttack	= "Scripts/AI/Behaviors/Personalities/SHARED/Other/ProtectVehicleAttack.lua",

		GenericPlaySequence	= "Scripts/AI/Behaviors/Personalities/SHARED/Other/GenericPlaySequence.lua",

		-- Human Base - to be derived from by particular classes
		----------------------------------------------------------
		HBaseIdle       = "Scripts/AI/Behaviors/Personalities/HumanBase/HBaseIdle.lua",
		HBaseAlerted    = "Scripts/AI/Behaviors/Personalities/HumanBase/HBaseAlerted.lua",		
		HBaseGrenadeRun = "Scripts/AI/Behaviors/Personalities/HumanBase/HBaseGrenadeRun.lua",
		HBaseLowHide = "Scripts/AI/Behaviors/Personalities/HumanBase/HBaseLowHide.lua",
		HBaseClose = "Scripts/AI/Behaviors/Personalities/HumanBase/HBaseClose.lua",
		HBaseBackOff = "Scripts/AI/Behaviors/Personalities/HumanBase/HBaseBackOff.lua",
		HBaseAttackTankRpg = "Scripts/AI/Behaviors/Personalities/HumanBase/HBaseAttackTankRpg.lua",
		HBaseAttackTankGrenades = "Scripts/AI/Behaviors/Personalities/HumanBase/HBaseAttackTankGrenades.lua",
		HBaseHideFromTank = "Scripts/AI/Behaviors/Personalities/HumanBase/HBaseHideFromTank.lua",
		HBaseTranquilized = "Scripts/AI/Behaviors/Personalities/HumanBase/HBaseTranquilized.lua",
		HBaseStaticShooter = "Scripts/AI/Behaviors/Personalities/HumanBase/HBaseStaticShooter.lua",

		-- COVER2
		----------------------------------------------------------
		Cover2Idle       	= "Scripts/AI/Behaviors/Personalities/Cover2/Cover2Idle.lua",		
		Cover2Interested  = "Scripts/AI/Behaviors/Personalities/Cover2/Cover2Interested.lua",
		Cover2Threatened  = "Scripts/AI/Behaviors/Personalities/Cover2/Cover2Threatened.lua",
		Cover2ThreatenedStandby  = "Scripts/AI/Behaviors/Personalities/Cover2/Cover2ThreatenedStandby.lua",
		Cover2Attack      = "Scripts/AI/Behaviors/Personalities/Cover2/Cover2Attack.lua",
		Cover2RushAttack      = "Scripts/AI/Behaviors/Personalities/Cover2/Cover2RushAttack.lua",
		Cover2AttackGroup = "Scripts/AI/Behaviors/Personalities/Cover2/Cover2AttackGroup.lua",
		Cover2Seek       	= "Scripts/AI/Behaviors/Personalities/Cover2/Cover2Seek.lua",
		Cover2Search     	= "Scripts/AI/Behaviors/Personalities/Cover2/Cover2Search.lua",
		Cover2Hide       	= "Scripts/AI/Behaviors/Personalities/Cover2/Cover2Hide.lua",
		Cover2AvoidTank   	= "Scripts/AI/Behaviors/Personalities/Cover2/Cover2AvoidTank.lua",
		Cover2AvoidExplosives = "Scripts/AI/Behaviors/Personalities/Cover2/Cover2AvoidExplosives.lua",		
		Cover2AvoidVehicle = "Scripts/AI/Behaviors/Personalities/Cover2/Cover2AvoidVehicle.lua",		
		Cover2Reload			= "Scripts/AI/Behaviors/Personalities/Cover2/Cover2Reload.lua",		
		Cover2CallReinforcements			= "Scripts/AI/Behaviors/Personalities/Cover2/Cover2CallReinforcements.lua",
		Cover2Panic				= "Scripts/AI/Behaviors/Personalities/Cover2/Cover2Panic.lua",
		Cover2RPGAttack		= "Scripts/AI/Behaviors/Personalities/Cover2/Cover2RPGAttack.lua",
		Squad2Cover 			= "Scripts/AI/Behaviors/Personalities/Cover2/Squad2Cover.lua",		
		WatchTowerGuardAlerted		= "Scripts/AI/Behaviors/Personalities/WatchTowerGuard/WatchTowerGuardAlerted.lua",
		WatchTowerGuardCombat	= "Scripts/AI/Behaviors/Personalities/WatchTowerGuard/WatchTowerGuardCombat.lua",

		-- CAMPER
		----------------------------------------------------------
		CamperIdle       		= "Scripts/AI/Behaviors/Personalities/Camper/CamperIdle.lua",
		CamperAttack       	= "Scripts/AI/Behaviors/Personalities/Camper/CamperAttack.lua",
		CamperSeek       		= "Scripts/AI/Behaviors/Personalities/Camper/CamperSeek.lua",
		CamperHide       		= "Scripts/AI/Behaviors/Personalities/Camper/CamperHide.lua",

		-- SNEAKER
		----------------------------------------------------------
		SneakerHide       		= "Scripts/AI/Behaviors/Personalities/Sneaker/SneakerHide.lua",
		SneakerSeek       		= "Scripts/AI/Behaviors/Personalities/Sneaker/SneakerSeek.lua",
		SneakerAttack       	= "Scripts/AI/Behaviors/Personalities/Sneaker/SneakerAttack.lua",
		
		-- SNIPER
		----------------------------------------------------------
		SniperAlert       	= "Scripts/AI/Behaviors/Personalities/Sniper/SniperAlert.lua",		
		SniperSnipe       	= "Scripts/AI/Behaviors/Personalities/Sniper/SniperSnipe.lua",		
		SniperMove       	= "Scripts/AI/Behaviors/Personalities/Sniper/SniperMove.lua",		
		SniperHide       		= "Scripts/AI/Behaviors/Personalities/Sniper/SniperHide.lua",		

		-- SUIT
		----------------------------------------------------------
		SuitSniperThreatened  = "Scripts/AI/Behaviors/Personalities/SuitSniper/SuitSniperThreatened.lua",
		SuitSniperAttack      = "Scripts/AI/Behaviors/Personalities/SuitSniper/SuitSniperAttack.lua",

		SuitIdle 			  = "Scripts/AI/Behaviors/Personalities/Suit/SuitIdle.lua",
		SuitThreatened  = "Scripts/AI/Behaviors/Personalities/Suit/SuitThreatened.lua",
		SuitAttack      = "Scripts/AI/Behaviors/Personalities/Suit/SuitAttack.lua",
		SuitHide       	= "Scripts/AI/Behaviors/Personalities/Suit/SuitHide.lua",
		SuitReload     	= "Scripts/AI/Behaviors/Personalities/Suit/SuitReload.lua",
		SuitStealth    	= "Scripts/AI/Behaviors/Personalities/Suit/SuitStealth.lua",

		-- SUIT HURRICANE
		----------------------------------------------------------
		SuitHurricaneThreatened		= "Scripts/AI/Behaviors/Personalities/SuitHurricane/SuitHurricaneThreatened.lua",
		SuitHurricaneAttack = "Scripts/AI/Behaviors/Personalities/SuitHurricane/SuitHurricaneAttack.lua",

		-- SUIT BOSS
		----------------------------------------------------------
		SuitBossAttack	= "Scripts/AI/Behaviors/Personalities/SuitBoss/SuitBossAttack.lua",
		SuitBossP1	= "Scripts/AI/Behaviors/Personalities/SuitBoss/SuitBossP1.lua",
		SuitBossP1b	= "Scripts/AI/Behaviors/Personalities/SuitBoss/SuitBossP1b.lua",
		SuitBossP2	= "Scripts/AI/Behaviors/Personalities/SuitBoss/SuitBossP2.lua",
		SuitBossP3	= "Scripts/AI/Behaviors/Personalities/SuitBoss/SuitBossP3.lua",
		
--		SneakerSneakL       	= "Scripts/AI/Behaviors/Personalities/Sneaker/SneakerSneakL.lua",

		----------------------------------------------------------
		----------------------------------------------------------
		-- Hostage
		----------------------------------------------------------
		HostageFollow    	= "Scripts/AI/Behaviors/Personalities/Hostage/HostageFollow.lua",
		HostageFollowHide	= "Scripts/AI/Behaviors/Personalities/Hostage/HostageFollowHide.lua",
		HostageHideSquad 	= "Scripts/AI/Behaviors/Personalities/Hostage/HostageHideSquad.lua",
		HostageRetrieve   = "Scripts/AI/Behaviors/Personalities/Hostage/HostageRetrieve.lua",
--		HostageHide      	= "Scripts/AI/Behaviors/Personalities/Hostage/HostageHide.lua",
--		HostageMove       = "Scripts/AI/Behaviors/Personalities/Hostage/HostageMove.lua",
--		HostageFollowed   = "Scripts/AI/Behaviors/Personalities/Hostage/HostageFollowed.lua",
		----------------------------------------------------------

		-- Civilian
		----------------------------------------------------------
		CivilianAlert       	= "Scripts/AI/Behaviors/Personalities/Civilian/CivilianAlert.lua",
		CivilianHide       	= "Scripts/AI/Behaviors/Personalities/Civilian/CivilianHide.lua",
		CivilianCower       	= "Scripts/AI/Behaviors/Personalities/Civilian/CivilianCower.lua",
		CivilianSurrender  	= "Scripts/AI/Behaviors/Personalities/Civilian/CivilianSurrender.lua",


		----------------------------------------------------------	
		-- VEHICLES related
		----------------------------------------------------------			
		-- passenger for vehicles
		EnteringVehicle = "SCRIPTS/AI/Behaviors/Personalities/SHARED/InVehicle/EnteringVehicle.lua",
		InVehicle 			= "SCRIPTS/AI/Behaviors/Personalities/SHARED/InVehicle/InVehicle.lua",
		InVehicleAlerted 			= "SCRIPTS/AI/Behaviors/Personalities/SHARED/InVehicle/InVehicleAlerted.lua",		
		InVehicleControlled	= "SCRIPTS/AI/Behaviors/Personalities/SHARED/InVehicle/InVehicleControlled.lua",
		InVehicleGunner	= "SCRIPTS/AI/Behaviors/Personalities/SHARED/InVehicle/InVehicleGunner.lua",
		InVehicleControlledGunner	= "SCRIPTS/AI/Behaviors/Personalities/SHARED/InVehicle/InVehicleControlledGunner.lua",
		InVehicleChangeSeat = "SCRIPTS/AI/Behaviors/Personalities/SHARED/InVehicle/InVehicleChangeSeat.lua",
		DriverGoto			= "SCRIPTS/AI/Behaviors/Personalities/SHARED/InVehicle/DriverGoto.lua",
		DriverReinforcement	= "SCRIPTS/AI/Behaviors/Personalities/SHARED/InVehicle/DriverReinforcement.lua",
		InVehicleTranquilized = "Scripts/AI/Behaviors/Personalities/SHARED/InVehicle/InVehicleTranquilized.lua",
		
		---------------------------------------------------------------------------------------------------------------------------------------
		--	Common bases for vehicles
		---------------------------------------------------------------------------------------------------------------------------------------
		Vehicle_Path = "Scripts/AI/Behaviors/Vehicles/Vehicle_Path.lua",		
		VehicleIdle = "Scripts/AI/Behaviors/Vehicles/VehicleIdle.lua",
		VehicleGoto = "Scripts/AI/Behaviors/Vehicles/VehicleGoto.lua",								
		---------------------------------------------------------------------------------------------------------------------------------------
		--	FlowGraph	actions bases for vehicles
		---------------------------------------------------------------------------------------------------------------------------------------
		VehicleAct = "Scripts/AI/Behaviors/Vehicles/VehicleAct.lua",				

		----------------------------------------------------------	
		-- vehicles behaviours
		----------------------------------------------------------
		--	cars
		Car_follow	= "Scripts/AI/Behaviors/Vehicles/Car/Car_follow.lua",		
		CarGoto			= "Scripts/AI/Behaviors/Vehicles/Car/CarGoto.lua",
		CarAlerted	= "Scripts/AI/Behaviors/Vehicles/Car/CarAlerted.lua",				
		CarSkid	= "Scripts/AI/Behaviors/Vehicles/Car/CarSkid.lua",				
		-- tanks
		TankFollow		= "Scripts/AI/Behaviors/Vehicles/Tank/TankFollow.lua",
		TankAttack		= "Scripts/AI/Behaviors/Vehicles/Tank/TankAttack.lua",		
		TankGoto		= "Scripts/AI/Behaviors/Vehicles/Tank/TankGoto.lua",		
		TankMove		= "Scripts/AI/Behaviors/Vehicles/Tank/TankMove.lua",		
		TankAlert		= "Scripts/AI/Behaviors/Vehicles/Tank/TankAlert.lua",		
		TankEmergencyExit		= "Scripts/AI/Behaviors/Vehicles/Tank/TankEmergencyExit.lua",		
		TANKDEFAULT	= "Scripts/AI/Behaviors/Vehicles/Tank/TANKDEFAULT.lua",

		TankCloseFollow		= "Scripts/AI/Behaviors/Vehicles/TankClose/TankCloseFollow.lua",
		TankCloseAttack		= "Scripts/AI/Behaviors/Vehicles/TankClose/TankCloseAttack.lua",		
		TankCloseGoto		= "Scripts/AI/Behaviors/Vehicles/TankClose/TankCloseGoto.lua",	
		TankCloseGotoPath		= "Scripts/AI/Behaviors/Vehicles/TankClose/TankCloseGotoPath.lua",
		TankCloseSwitchPath		= "Scripts/AI/Behaviors/Vehicles/TankClose/TankCloseSwitchPath.lua",
		TankCloseRunAway		= "Scripts/AI/Behaviors/Vehicles/TankClose/TankCloseRunAway.lua",

		TankFixedFollow		= "Scripts/AI/Behaviors/Vehicles/TankFixed/TankFixedFollow.lua",
		TankFixedGoto		= "Scripts/AI/Behaviors/Vehicles/TankFixed/TankFixedGoto.lua",	
		
		WarriorFollow = "Scripts/AI/Behaviors/Vehicles/Warrior/WarriorFollow.lua",
		WarriorAttack = "Scripts/AI/Behaviors/Vehicles/Warrior/WarriorAttack.lua",
		WarriorGoto = "Scripts/AI/Behaviors/Vehicles/Warrior/WarriorGoto.lua",
	
		-- boat
		BoatAlert			= "Scripts/AI/Behaviors/Vehicles/Boat/BoatAlert.lua",		
		BoatAttack			= "Scripts/AI/Behaviors/Vehicles/Boat/BoatAttack.lua",		
		BoatGoto			= "Scripts/AI/Behaviors/Vehicles/Boat/BoatGoto.lua",		

		PatrolBoatAlert			= "Scripts/AI/Behaviors/Vehicles/PatrolBoat/PatrolBoatAlert.lua",		
		PatrolBoatAttack			= "Scripts/AI/Behaviors/Vehicles/PatrolBoat/PatrolBoatAttack.lua",		
		PatrolBoatAttack2			= "Scripts/AI/Behaviors/Vehicles/PatrolBoat/PatrolBoatAttack2.lua",		
		PatrolBoatGoto			= "Scripts/AI/Behaviors/Vehicles/PatrolBoat/PatrolBoatGoto.lua",		

		-- helicopters	
		HeliPath		= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliPath.lua",
		HeliAttack	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliAttack.lua",
		HeliPickAttack	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliPickAttack.lua",
		HeliGoto	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliGoto.lua",
		HeliHoverAttack	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliHoverAttack.lua",
		HeliHoverAttack2	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliHoverAttack2.lua",
		HeliHoverAttack3	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliHoverAttack3.lua",
		HeliFly				= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliFly.lua",	
		HeliFlyOver	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliFlyOver.lua",
		HeliPatrol	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliPatrol.lua",
		HeliReinforcement	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliReinforcement.lua",
		HeliLanding	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliLanding.lua",
		HeliShootAt	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliShootAt.lua",
		HeliBase	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliBase.lua",
		HeliEmergencyLanding = "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliEmergencyLanding.lua",
		HELIDEFAULT	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HELIDEFAULT.lua",
		HeliLanding	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliLanding.lua",
		HeliShootAt	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliShootAt.lua",
		HelivsAir	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HelivsAir.lua",
		HelivsBoat	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HelivsBoat.lua",
		HeliSmoothGoto	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliSmoothGoto.lua",

		HeliIgnorant	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliIgnorant.lua",
		HeliUnIgnorant	= "Scripts/AI/Behaviors/Vehicles/Helicopter/HeliUnIgnorant.lua",

		-- vtols
		VtolPath		= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolPath.lua",
		VtolAttack	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolAttack.lua",
		VtolPickAttack	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolPickAttack.lua",
		VtolGoto	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolGoto.lua",
		VtolHoverAttack	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolHoverAttack.lua",
		VtolFly				= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolFly.lua",	
		VtolFlyOver	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolFlyOver.lua",
		VtolPatrol	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolPatrol.lua",
		VtolReinforcement	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolReinforcement.lua",
		VtolLanding	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolLanding.lua",
		VtolShootAt	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolShootAt.lua",
		VtolEmergencyLanding	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolEmergencyLanding.lua",
		VTOLDEFAULT	= "Scripts/AI/Behaviors/Vehicles/Vtol/VTOLDEFAULT.lua",
		VtolvsAir	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolvsAir.lua",
		VtolvsBoat	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolvsBoat.lua",
		VtolSmoothGoto	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolSmoothGoto.lua",

		VtolIgnorant	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolIgnorant.lua",
		VtolUnIgnorant	= "Scripts/AI/Behaviors/Vehicles/Vtol/VtolUnIgnorant.lua",

		----------------------------------------------------------	
		-- LEADERS
		----------------------------------------------------------
		----------------------------------------------------------							
		LeaderIdle		= "Scripts/AI/Behaviors/Personalities/TeamLeaders/LeaderIdle.lua",							
		LeaderFollow       	= "Scripts/AI/Behaviors/Personalities/TeamLeaders/LeaderFollow.lua",
		LeaderSearch       	= "Scripts/AI/Behaviors/Personalities/TeamLeaders/LeaderSearch.lua",
		LeaderAlert       	= "Scripts/AI/Behaviors/Personalities/TeamLeaders/LeaderAlert.lua",


		----------------------------------------------------------	
		-- ANIMALS
		----------------------------------------------------------


		----------------------------------------------------------	
		-- SHARED COMBAT
		------------------------------------------------------------

		FastKill			= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/FastKill.lua",
		Dodge					= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/Dodge.lua",
		CheckDead			= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/CheckDead.lua",
		RunToAlarm		= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/RunToAlarm.lua",
		RunToFriend		= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/RunToFriend.lua",
		UnderFire			= "Scripts/AI/Behaviors/Personalities/Shared/Combat/UnderFire.lua",
--		MountedGuy		= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/MountedGuy.lua",
		UseMounted		= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/UseMounted.lua",
		UseMountedTranquilized		= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/UseMountedTranquilized.lua",
--		UseElevator		= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/UseElevator.lua",
--		UseFlyingFox		= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/UseFlyingFox.lua",
		DigIn			= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/DigIn.lua",
		LeanFire		= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/LeanFire.lua",
--		SharedReinforce		= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/SharedReinforce.lua",
--		SharedRetreat		= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/SharedRetreat.lua",
--		HoldPosition		= "Scripts/AI/Behaviors/Personalities/SHARED/Combat/HoldPosition.lua",
--
--		SpecialLead		= "Scripts/AI/Behaviors/Personalities/SHARED/Other/SpecialLead.lua",
--		SpecialFollow		= "Scripts/AI/Behaviors/Personalities/SHARED/Other/SpecialFollow.lua",
--		SpecialDumb		= "Scripts/AI/Behaviors/Personalities/SHARED/Other/SpecialDumb.lua",
--		SpecialHold		= "Scripts/AI/Behaviors/Personalities/SHARED/Other/SpecialHold.lua",
		Swim			= "Scripts/AI/Behaviors/Personalities/SHARED/Other/Swim.lua",
--		ClimbLadder		= "Scripts/AI/Behaviors/Personalities/SHARED/Other/ClimbLadder.lua",
		

		----------------------------------------------------------	
		-- ALIENS
		----------------------------------------------------------
		
		-- Guard
		GuardNeueCombat				= "Scripts/AI/Behaviors/Aliens/Guard/GuardNeueCombat.lua",

		GUARDDEFAULT				= "Scripts/AI/Behaviors/Aliens/GUARDDEFAULT.lua",

		-- Trooper
		TrooperFunctions		= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperFunctions.lua",
		
		TrooperAlert				= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperAlert.lua",
		TrooperAttack				= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperAttack.lua",
		TrooperDefend				= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperDefend.lua",
		TrooperAttackMelee	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperAttackMelee.lua",
		TrooperAttackSwitchPosition	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperAttackSwitchPosition.lua",
		TrooperAttackSwitchPositionMelee	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperAttackSwitchPositionMelee.lua",
		TrooperAttackMoar	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperAttackMoar.lua",
		TrooperAttackSpecialAction	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperAttackSpecialAction.lua",
		TrooperShootOnSpot	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperShootOnSpot.lua",
		TrooperShootOnRock	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperShootOnRock.lua",
		TrooperShootOnWall	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperShootOnWall.lua",
		TrooperChase				= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperChase.lua",
		TrooperAttackJump		= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperAttackJump.lua",

		TrooperAttackPursue				= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperAttackPursue.lua",
--		TrooperBerserk				= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperBerserk.lua",
--		TrooperGroupIdle		= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperGroupIdle.lua",
--		TrooperGroupInterested		= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperGroupInterested.lua",
----		TrooperGroupThreatened		= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperGroupThreatened.lua",
--		TrooperGroupDumb		= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperGroupDumb.lua",
--		TrooperGroupCombat	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperGroupCombat.lua",
--		TrooperGroupFire		= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperGroupFire.lua",
		TrGroupSearch				= "Scripts/AI/Behaviors/Aliens/Trooper/TrGroupSearch.lua",
		TrGroupCoverSearch	= "Scripts/AI/Behaviors/Aliens/Trooper/TrGroupCoverSearch.lua",

		TrooperForm					= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperForm.lua",
		TrooperMove					= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperMove.lua",
		TrooperApproach			= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperApproach.lua",
		--TrooperAttackFormation = "Scripts/AI/Behaviors/Aliens/Trooper/TrooperAttackFormation.lua",
		TrooperAttackFlank	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperAttackFlank.lua",
--		TrooperHideShoot		= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperHideShoot.lua",
		--TrooperDigIn				= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperDigIn.lua",
		TrooperHide					= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperHide.lua",
		--TrooperHold					= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperHold.lua",
		TrooperInterested		= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperInterested.lua",
--		TrooperRunToFriend	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperRunToFriend.lua",
		TrooperSearch				= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperSearch.lua",
		TrooperThreatened		= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperThreatened.lua",
		--TrooperUnderFire		= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperUnderFire.lua",
		TrooperAmbush 			=	"Scripts/AI/Behaviors/Aliens/Trooper/TrooperAmbush.lua",
		TrooperDumb 				=	"Scripts/AI/Behaviors/Aliens/Trooper/TrooperDumb.lua",
		TrooperDodge				= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperDodge.lua",
--		TrooperDodgeGrenade	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperDodgeGrenade.lua",
		TrooperAvoidExplosion	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperAvoidExplosion.lua",
		TrooperJump					= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperJump.lua",
		TrooperRetreat			= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperRetreat.lua",
		TrooperGrabbedByScout = "Scripts/AI/Behaviors/Aliens/Trooper/TrooperGrabbedByScout.lua",
--		TrooperCollectiveFire1 = "Scripts/AI/Behaviors/Aliens/Trooper/TrooperCollectiveFire1.lua",
--		TrooperCollectiveFire2 = "Scripts/AI/Behaviors/Aliens/Trooper/TrooperCollectiveFire2.lua",
--
--		TrooperLeaderAttack	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperLeader/TrooperLeaderAttack.lua",
--		TrooperLeaderFire		= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperLeader/TrooperLeaderFire.lua",
--		TrooperLeaderSearch	= "Scripts/AI/Behaviors/Aliens/Trooper/TrooperLeader/TrooperLeaderSearch.lua",
--		TrooperLeaderPreAttack = "Scripts/AI/Behaviors/Aliens/Trooper/TrooperLeader/TrooperLeaderPreAttack.lua",
--		TrooperLeaderCollectiveFire = "Scripts/AI/Behaviors/Aliens/Trooper/TrooperLeader/TrooperLeaderCollectiveFire.lua",
		
		TROOPERDEFAULT			= "Scripts/AI/Behaviors/Aliens/TROOPERDEFAULT.lua",

		-- Scout
		ScoutCircling = "Scripts/AI/Behaviors/Aliens/Scout/ScoutCircling.lua",
		ScoutAlert = "Scripts/AI/Behaviors/Aliens/Scout/ScoutAlert2.lua",
		ScoutAttack = "Scripts/AI/Behaviors/Aliens/Scout/ScoutAttack2.lua",
		ScoutPatrol = "Scripts/AI/Behaviors/Aliens/Scout/ScoutPatrol2.lua",
		ScoutHide = "Scripts/AI/Behaviors/Aliens/Scout/ScoutHide.lua",
		ScoutMOARAttack = "Scripts/AI/Behaviors/Aliens/Scout/ScoutMOARAttack.lua",
		ScoutFlyOver = "Scripts/AI/Behaviors/Aliens/Scout/ScoutFlyOver.lua",
		ScoutMelee = "Scripts/AI/Behaviors/Aliens/Scout/ScoutMelee.lua",
		ScoutGrab = "Scripts/AI/Behaviors/Aliens/Scout/ScoutGrab.lua",
		ScoutRoundAttack = "Scripts/AI/Behaviors/Aliens/Scout/ScoutRoundAttack.lua",
		ScoutHoverAttack = "Scripts/AI/Behaviors/Aliens/Scout/ScoutHoverAttack.lua",
		ScoutPickAttack = "Scripts/AI/Behaviors/Aliens/Scout/ScoutPickAttack.lua",
		ScoutAttackVehicle = "Scripts/AI/Behaviors/Aliens/Scout/ScoutAttackVehicle.lua",

		SCOUTDEFAULT = "Scripts/AI/Behaviors/Aliens/SCOUTDEFAULT.lua",

		--ScoutAttack = "Scripts/AI/Behaviors/Aliens/Scout/ScoutAttack.lua",
		--ScoutRecoil = "Scripts/AI/Behaviors/Aliens/Scout/ScoutRecoil.lua",
		--ScoutAlert = "Scripts/AI/Behaviors/Aliens/Scout/ScoutAlert.lua",

		-- ScoutMelee
		ScoutMeleeAttack = "Scripts/AI/Behaviors/Aliens/ScoutMelee/ScoutMeleeAttack.lua",
		ScoutMeleePatrol = "Scripts/AI/Behaviors/Aliens/ScoutMelee/ScoutMeleePatrol.lua",
		ScoutMeleeDefault = "Scripts/AI/Behaviors/Aliens/ScoutMelee/ScoutMeleeDefault.lua",
		-- ScoutMOAC
		ScoutMOACAttack = "Scripts/AI/Behaviors/Aliens/ScoutMOAC/ScoutMOACAttack.lua",
		ScoutMOACPatrol = "Scripts/AI/Behaviors/Aliens/ScoutMOAC/ScoutMOACPatrol.lua",
		ScoutMOACDefault = "Scripts/AI/Behaviors/Aliens/ScoutMOAC/ScoutMOACDefault.lua",
		-- ScoutMOAR
		ScoutMOARAttack = "Scripts/AI/Behaviors/Aliens/ScoutMOAR/ScoutMOARAttack.lua",
		ScoutMOARPatrol = "Scripts/AI/Behaviors/Aliens/ScoutMOAR/ScoutMOARPatrol.lua",
		ScoutMOARDefault = "Scripts/AI/Behaviors/Aliens/ScoutMOAR/ScoutMOARDefault.lua",

		-- dialog
		Dialog		= "Scripts/AI/Behaviors/Personalities/SHARED/Other/Dialog.lua",

		-- Player
		PlayerIdle       	= "Scripts/AI/Behaviors/Personalities/Player/PlayerIdle.lua",
		PlayerAttack     	= "Scripts/AI/Behaviors/Personalities/Player/PlayerAttack.lua",

	},
}

AI.LogEvent("LOADED AI BEHAVIOURS");

-- do not delete this line
Script.ReloadScript("Scripts/AI/Behaviors/DEFAULT.lua");
---------------------------------------------------------


-- load all idle scripts
--Script.ReloadScript("Scripts/AI/Behaviors/Personalities/SHARED/Idles/AnimIdles.lua");
--------------------------------------------------------



function AIBehaviour:LoadAll()
	
	for name,filename in pairs(self.AVAILABLE) do	
--		AI.LogEvent("Preloading behaviour "..name)
		Script.ReloadScript(filename);
	end

	for name,filename in pairs(self.INTERNAL) do	
--		AI.LogEvent("Preloading behaviour "..name)
		Script.ReloadScript(filename);
	end

end












