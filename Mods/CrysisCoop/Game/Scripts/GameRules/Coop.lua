----------------------------------------------------------------------------------------------------
Script.LoadScript("scripts/gamerules/singleplayer.lua", 1, 1);
--------------------------------------------------------------------------
Coop = new(SinglePlayer);
Coop.States = { "Reset", "InGame", "PostGame", };


Coop.MIN_PLAYER_LIMIT_WARN_TIMER= 15; -- player limit warning timer

Coop.NEXTLEVEL_TIMERID			= 1050;
Coop.NEXTLEVEL_TIME				= 12000;

Coop.MISSIONFAILED_TIMERID		= 1060;
Coop.MISSIONFAILED_TIME			= 6000;

Coop.ENDGAME_TIMERID			= 1040;
Coop.ENDGAME_TIME				= 3000;
Coop.TICK_TIMERID				= 1010;
Coop.TICK_TIME					= 1000;

Coop.SCORE_KILLS_KEY 			= 100;
Coop.SCORE_DEATHS_KEY 			= 101;
Coop.SCORE_HEADSHOTS_KEY 		= 102;
Coop.SCORE_PING_KEY 			= 103;
Coop.SCORE_LAST_KEY 			= 104;	-- make sure this is always the last one

Coop.bMissionFailed				= false;

Coop.DamagePlayerToPlayer =
{
	helmet		= 1.25,
	kevlar		= 1.15,

	head 	    = 1.68,
	torso 		= 1.15,
	arm_left	= 0.96,
	arm_right	= 0.96,
	leg_left	= 0.96,
	leg_right	= 0.96,

	foot_left	= 0.96,
	foot_right	= 0.96,
	hand_left	= 0.96,
	hand_right	= 0.96,
	assist_min	= 0.8,
};


----------------------------------------------------------------------------------------------------
Net.Expose {
	Class = Coop,
	ClientMethods = 
	{
		ClSetupPlayer					= { RELIABLE_UNORDERED, NO_ATTACH, DEPENTITYID, },
		ClVictory						= { RELIABLE_ORDERED, POST_ATTACH, },
		ClDefeat						= { RELIABLE_ORDERED, POST_ATTACH, },
		
		ClClientConnect					= { RELIABLE_UNORDERED, POST_ATTACH, STRING, BOOL },
		ClClientDisconnect				= { RELIABLE_UNORDERED, POST_ATTACH, STRING, },
		ClClientEnteredGame				= { RELIABLE_UNORDERED, POST_ATTACH, STRING, },
		ClTimerAlert					= { RELIABLE_UNORDERED, POST_ATTACH, INT8 },
	},
	ServerMethods = 
	{
		RequestRevive		 			= { RELIABLE_UNORDERED, POST_ATTACH, ENTITYID, },
		RequestSpectatorTarget			= { RELIABLE_UNORDERED, POST_ATTACH, ENTITYID, INT8 },
		RequestDefibrillate		 		= { RELIABLE_UNORDERED, POST_ATTACH, ENTITYID, },
	},
	ServerProperties = 
	{
	},
};

----------------------------------------------------------------------------------------------------
function Coop:IsMultiplayer()
	return true;
end

----------------------------------------------------------------------------------------------------
function Coop:CheckPlayerScoreLimit(playerId, score)
end

----------------------------------------------------------------------------------------------------
function Coop:PlayerCountOk()
	return true;
end

----------------------------------------------------------------------------------------------------
function Coop:OnGameEnd(bWin, type)
	if (bWin) then
		self.allClients:ClVictory();
		System.LogAlways("Coop:OnGameEnd Mission Victory");
		
		self.game:EndGame();
		self:GotoState("PostGame");	
	else
		self.allClients:ClDefeat();
		System.LogAlways("Coop:OnGameEnd Mission Defeat");
		self:SetTimer(self.MISSIONFAILED_TIMERID, self.MISSIONFAILED_TIME);
	end
end

----------------------------------------------------------------------------------------------------
function Coop:IsMissionFailed()
	if (self.bMissionFailed == true) then
		return false;
	end

	local players=self.game:GetPlayers();
	
	local nPlayerCount = 0;
	local nDeadCount = 0;

	if (players) then
		for i,player in ipairs(players) do
			if (player and player.actor and player.actor:GetSpectatorMode()==0) then
				nPlayerCount = nPlayerCount + 1;
				if (player:IsDead()) then
					nDeadCount = nDeadCount + 1;
				end
			end
		end
	end
	
	if (nPlayerCount <= 0) then
		return false;
	end
	
	if (nPlayerCount == nDeadCount) then
		return true;
	end
end

----------------------------------------------------------------------------------------------------
function Coop:DefibPlayer(entityId)
	local entity = System.GetEntity(entityId);

	self.server:RequestDefibrillate(entityId);
end

----------------------------------------------------------------------------------------------------
function Coop:ResetTime()
	self.game:ResetGameTime();
end

----------------------------------------------------------------------------------------------------
function Coop.Server:OnInit()
	SinglePlayer.Server.OnInit(self);
	
	self.isServer=CryAction.IsServer();
	self.isClient=CryAction.IsServer();
	
	self.killHit={};
	self.channelSpectatorMode={}; -- keep track of spectators
	
	self:Reset(true);
	
	-- Delay entity reset
	self:SetTimer(self.MISSIONFAILED_TIMERID, 1000);
end


----------------------------------------------------------------------------------------------------
function Coop.Server:OnStartGame()
	--System.Log("Coop OnStartGame");
	self:StartTicking();
end

----------------------------------------------------------------------------------------------------
function Coop:OnReset()
	if (self.isServer) then
		if (self.Server.OnReset) then
			self.Server.OnReset(self);	
		end
	end

	if (self.isClient) then
		if (self.Client.OnReset) then
			self.Client.OnReset(self);	
		end
	end
end

----------------------------------------------------------------------------------------------------
function Coop.Server:OnReset()
	self:Reset();
end

----------------------------------------------------------------------------------------------------
function Coop.Client:OnReset()
end

----------------------------------------------------------------------------------------------------
function Coop:Reset(forcePregame)
	self:ResetTime();

	self:GotoState("InGame");

	self.forceInGame=nil;
	
	self.works={};
end

----------------------------------------------------------------------------------------------------
function Coop:RestartGame(forceInGame)	
	self:GotoState("Reset");

	self.game:ResetEntities();
	self.bMissionFailed = false;

	if (forceInGame) then
		self.forceInGame=true;
	end
end

----------------------------------------------------------------------------------------------------
function Coop.Client:OnActorAction(player, action, activation, value)
	return true;
end

----------------------------------------------------------------------------------------------------
function Coop.Client:OnDisconnect(cause, desc)
end

----------------------------------------------------------------------------------------------------
function Coop.Server:OnClientConnect(channelId, reset, name)
	local player = self:SpawnPlayer(channelId, name);

	if (not reset) then
		if (not CryAction.IsChannelOnHold(channelId)) then
			self:ResetScore(player.id);
			self.otherClients:ClClientConnect(channelId, player:GetName(), false);
		else
			self.otherClients:ClClientConnect(channelId, player:GetName(), true);
		end
	end
	
	if (not CryAction.IsChannelOnHold(channelId)) then
		self:ResetScore(player.id);
	end

	local specMode= 0;
	local teamId = self.game:GetChannelTeam(channelId) or 0;

	if (specMode==0 or teamId~=0) then
		self.game:SetTeam(teamId, player.id); -- make sure he's got a team before reviving
			
		self:RevivePlayer(player.actor:GetChannel(), player);
	end

	return player;
end

----------------------------------------------------------------------------------------------------
function Coop.Server:OnClientDisconnect(channelId)
	local player=self.game:GetPlayerByChannelId(channelId);
	
	self.channelSpectatorMode[player.actor:GetChannel()]=nil;
	self.works[player.id]=nil;
	
	self.otherClients:ClClientDisconnect(channelId, player:GetName());
end

----------------------------------------------------------------------------------------------------
function Coop.Server:OnClientEnteredGame(channelId, player, reset)
	local onHold=CryAction.IsChannelOnHold(channelId);
	if (not reset) then
		if (player.actor:GetHealth()>0) then
			player.actor:SetPhysicalizationProfile("alive");
		else
			player.actor:SetPhysicalizationProfile("ragdoll");
		end
	end

	if (not reset) then
		self.otherClients:ClClientEnteredGame(channelId, player:GetName());
	end
	
	self:SetupPlayer(player);
	
	if ((not g_localActorId) or (player.id~=g_localActorId)) then
		self.onClient:ClSetupPlayer(player.actor:GetChannel(), player.id);
	end	
end

----------------------------------------------------------------------------------------------------
-- only players get this
function Coop.Server:OnChangeSpectatorMode(playerId, mode, targetId, resetAll, norevive) 
end

----------------------------------------------------------------------------------------------------
function Coop.Server:OnUpdate(frameTime)
	self:UpdatePings(frameTime);
end

----------------------------------------------------------------------------------------------------
function Coop:StartTicking(client)
	if ((not client) or (not self.isServer)) then
		self:SetTimer(self.TICK_TIMERID, self.TICK_TIME);
	end
end

----------------------------------------------------------------------------------------------------
function Coop.Server:OnTimer(timerId, msec)
	if (timerId==self.TICK_TIMERID) then
		if (self.OnTick) then
			--pcall(self.OnTick, self);
			self:OnTick();
			self:SetTimer(self.TICK_TIMERID, self.TICK_TIME);
		end
	elseif(timerId==self.NEXTLEVEL_TIMERID) then
		self:GotoState("Reset");
		self.game:NextLevel();
	elseif(timerId==self.MISSIONFAILED_TIMERID) then
		System.LogAlways("Coop.Server:OnTimer Restarting the level");
		self:RestartGame();
	end
end

----------------------------------------------------------------------------------------------------
function Coop.Client:OnTimer(timerId, msec)
	if (timerId == self.TICK_TIMERID) then
		self:OnClientTick();
		if (not self.isServer) then
			self:SetTimer(self.TICK_TIMERID, self.TICK_TIME);
		end
	elseif (timerId == self.ENDGAME_TIMERID) then
		self:EndGame(true);
	end
end

----------------------------------------------------------------------------------------------------
function Coop.Client:OnUpdate(frameTime)
	SinglePlayer.Client.OnUpdate(self, frameTime);
	if(self.show_scores == true) then
		self:UpdateScores();
	end
end

----------------------------------------------------------------------------------------------------
function Coop:UpdatePings(frameTime)
	if ((not self.pingUpdateTimer) or self.pingUpdateTimer>0) then
		self.pingUpdateTimer=(self.pingUpdateTimer or 0)-frameTime;
		if (self.pingUpdateTimer<=0) then
			local players = self.game:GetPlayers();
			
			if (players) then
				for i,player in ipairs(players) do
					if (player and player.actor:GetChannel()) then
						local ping=math.floor((self.game:GetPing(player.actor:GetChannel()) or 0)*1000+0.5);
						self.game:SetSynchedEntityValue(player.id, self.SCORE_PING_KEY, ping);
					end
				end
			end

			self.pingUpdateTimer=1;
		end
	end
end

----------------------------------------------------------------------------------------------------
function Coop:ShowScores(enable)
	--Log("Coop:ShowScores(%s)", tostring(enable));
	self.show_scores = enable;
end

----------------------------------------------------------------------------------------------------
function Coop:EndGame(enable)
	self.force_scores=enable;
	self.show_scores=enable;
	self.game:ForceScoreboard(enable);
	self.game:FreezeInput(enable);
end

----------------------------------------------------------------------------------------------------
function Coop:GetPlayerTeamKills(playerId)
	return -1;
end

----------------------------------------------------------------------------------------------------
function Coop:UpdateScores()
	if (self.show_scores and g_localActor) then
		local players = Actor.GetActors();-- System.GetEntitiesByClass("Player"); -- temp fix
		
		if (players) then
			--Send to C++ 
			g_localActor.actor:ResetScores();
			for i,player in ipairs(players) do
				local kills=self.game:GetSynchedEntityValue(player.id, self.SCORE_KILLS_KEY) or 0;
				local deaths=self.game:GetSynchedEntityValue(player.id, self.SCORE_DEATHS_KEY) or 0;
				local ping=self.game:GetSynchedEntityValue(player.id, self.SCORE_PING_KEY) or 0;
				local teamKills = self:GetPlayerTeamKills(player.id);
				
				g_localActor.actor:RenderScore(player.id, kills, deaths, ping, teamKills);
			end
		end
	end
end

----------------------------------------------------------------------------------------------------
function Coop:SpawnPlayer(channelId, name)
	if (not self.dudeCount) then self.dudeCount = 0; end;
	
	local pos = g_Vectors.temp_v1;
	local angles = g_Vectors.temp_v2;
	ZeroVector(pos);
	ZeroVector(angles);
	
	local locationId=self.game:GetInterestingSpectatorLocation();
	if (locationId) then
		local location=System.GetEntity(locationId);
		if (location) then
			pos=location:GetWorldPos(pos);
			angles=location:GetWorldAngles(angles);
		end
	end
		
	local player=self.game:SpawnPlayer(channelId, name or "Nomad", "Player", pos, angles);	

	return player;
end

----------------------------------------------------------------------------------------------------
function Coop:SetupPlayer(player)
	player.ammoCapacity =
	{
		bullet=30*4,
		fybullet=30*4,
		lightbullet=20*8,
		smgbullet=20*8,
		explosivegrenade=3,
		flashbang=2,
		smokegrenade=1,
		empgrenade=1,
		scargrenade=3,
		rocket=3,
		sniperbullet=10*4,
		tacbullet=5*4,
		tagbullet=10,
		gaussbullet=5*4,
		hurricanebullet=500*2,
		incendiarybullet=30*4,
		shotgunshell=8*8,
		avexplosive=2,
		c4explosive=1,
		claymoreexplosive=2,
		rubberbullet=30*4,
		tacgunprojectile=1,
    fgl40fraggrenade=6,
    fgl40empgrenade=6,
    aybullet=160,
	};
	
	if (player.inventory and player.ammoCapacity) then
		for ammo,capacity in pairs(player.ammoCapacity) do
			player.inventory:SetAmmoCapacity(ammo, capacity);
		end
	end	
end

----------------------------------------------------------------------------------------------------
function Coop:IsSpawnSafe(player, spawn, safedist)
	return true;
end

----------------------------------------------------------------------------------------------------
function Coop:RevivePlayer(channelId, player, keepEquip)
	local result=false;
	local teamId=self.game:GetTeam(player.id);
	
	if (player:IsDead()) then
		keepEquip=false;
	end
	
	player.lastExitedVehicleId = nil;
	player.lastExitedVehicleTime = nil;
	
	if (not result) then
		local includeNeutral=true;
		if (self.TEAM_SPAWN_LOCATIONS) then
			includeNeutral=self.NEUTRAL_SPAWN_LOCATIONS or false;
		end
	
		local spawnId,zoffset = self.game:GetSpawnLocation(player.id, true, includeNeutral, NULL_ENTITY, 50, player.death_pos, player.skipSpawnId);
			
		player.spawn_time=_time;
		player.skipSpawnId=spawnId;

		local pos,angles;

		if (spawnId) then
			local spawn=System.GetEntity(spawnId)
			if (spawn) then
				spawn:Spawned(player);
				pos=spawn:GetWorldPos(g_Vectors.temp_v1);
				angles=spawn:GetWorldAngles(g_Vectors.temp_v2);
				pos.z=pos.z+zoffset;
				
				if (zoffset>0) then
					Log("Spawning player '%s' with ZOffset: %g!", player:GetName(), zoffset);
				end

				self.game:RevivePlayer(player.id, pos, angles, teamId, not keepEquip);		

				result=true;
			end
		end
	end
	
	-- make the game realise the areas we're in right now...
	-- otherwise we'd have to wait for an entity system update, next frame
	player:UpdateAreas();

	if (result) then
		if(player.actor:GetSpectatorMode() ~= 0) then
			player.actor:SetSpectatorMode(0, NULL_ENTITY);
		end
	
		if (not keepEquip) then
			local additionalEquip;
			if (groupId) then
				local group=System.GetEntity(groupId);
				if (group and group.GetAdditionalEquipmentPack) then
					additionalEquip=group:GetAdditionalEquipmentPack();
				end
			end
			self:EquipPlayer(player, additionalEquip);
		end
		player.death_time=nil;
		player.frostShooterId=nil;
	end
	
	if (not result) then
		System.LogAlways("Failed to spawn %s! teamId: %d  groupId: %s  groupTeamId: %d", player:GetName(), self.game:GetTeam(player.id), tostring(groupId), self.game:GetTeam(groupId or NULL_ENTITY));
	end
	
	return result;
end

----------------------------------------------------------------------------------------------------
-- how much damage does 1 point of energy absorbs?
function Coop:GetEnergyAbsorptionValue(player)
	return 1/1.5;
end

----------------------------------------------------------------------------------------------------
function Coop:GetDamageAbsorption(player, hit)
	if (hit.damage == 0.0 or hit.type=="punish") then
		return 0;
	end;

	local nanoSuitMode = player.actor:GetNanoSuitMode();
	if(nanoSuitMode == 3) then -- armor mode
		local currentSuitEnergy = player.actor:GetNanoSuitEnergy();
		-- Reduce energy based on damage. The left over will be reduced from the health.
		local suitEnergyLeft = currentSuitEnergy - (hit.damage*4.2); -- armor energy is 25% weaker than health
		local absorption = 0.0;
		if (suitEnergyLeft < 0.0) then
			player.actor:SetNanoSuitEnergy(0);
			absorption = 1 + suitEnergyLeft/(hit.damage*4.2);
		else
			player.actor:SetNanoSuitEnergy(suitEnergyLeft);
			absorption = 1;
		end
	
		return math.max(0, absorption);
	end
	
	return 0;
end

----------------------------------------------------------------------------------------------------
function Coop:ProcessActorDamage(hit)
	local target=hit.target;
	local health=target.actor:GetHealth();
	
	health = math.floor(health - hit.damage*(1-self:GetDamageAbsorption(target, hit)));
	
	target.actor:SetHealth(health);
	
	--if (shooter ~= nil) then
		--Log("** %s hit %s for %d (%d absorbed) **", shooter:GetName(), target:GetName(), damage, math.floor(damage*target:GetDamageAbsorption(damageType)));
	--end
	
	return (health <= 0);
end

----------------------------------------------------------------------------------------------------
function Coop:CalcExplosionDamage(entity, explosion, obstruction)
	local newDamage = SinglePlayer.CalcExplosionDamage(self, entity, explosion, obstruction);
	
	-- claymore explosions are directional and the damage depends on angle of approach
	if(explosion.effectClass == "claymoreexplosive") then
		local explosionPos = explosion.pos;
		local entityPos = entity:GetWorldPos();

		local edir = vecNormalize(vecSub(entityPos, explosionPos));
		local dot = 1;
		if (edir) then
			dot = vecDot(edir, explosion.dir);
		end
		
		if(dot > 0.0) then
			newDamage = (0.1 * newDamage) + (0.9 * newDamage * dot);
		else
			newDamage = 0.1 * newDamage;
		end
		
		local debugHits = self.game:DebugHits();
		if (debugHits>0) then
			local angle = math.abs(math.acos(dot));
			Log("%s hit by claymore: dot %f, angle %f, damage %f", entity:GetName(), dot, angle, newDamage);
		end
	end
	
	return newDamage;
end


----------------------------------------------------------------------------------------------------
function Coop.Server:OnFreeze(targetId, shooterId, weaponId, value)
	local target=System.GetEntity(targetId);

	if (target.OnFreeze and not target:OnFreeze(shooterId, weaponId, value)) then
		return false;
	end

	if (target.actor or target.vehicle) then
		target.frostShooterId=shooterId;
	end
	return true;
end


----------------------------------------------------------------------------------------------------
function Coop.Server:OnPlayerKilled(hit)
	local target=hit.target;
	target.death_time=_time;
	target.death_pos=target:GetWorldPos(target.death_pos);
	
	self.game:KillPlayer(hit.targetId, true, true, hit.shooterId, hit.weaponId, hit.damage, hit.materialId, hit.typeId, hit.dir);
end


----------------------------------------------------------------------------------------------------
function Coop:CalculateScore(deaths, kills, teamkills)
	
	local score = (deaths * -1) + (kills * 1);

	return score;
end

----------------------------------------------------------------------------------------------------
function Coop:DisplayKillScores()
	return true;
end

----------------------------------------------------------------------------------------------------
function Coop.Client:OnKill(playerId, shooterId, weaponClassName, damage, material, hit_type)
	local matName=self.game:GetHitMaterialName(material) or "";
	local type=self.game:GetHitType(hit_type) or "";
	
	local headshot=string.find(matName, "head");
	local melee=string.find(type, "melee");
	
	if(playerId == g_localActorId) then
		--do return end; -- DeathFX disabled cause it's not resetting properly atm...
		if(headshot) then
			HUD.ShowDeathFX(2);
		elseif (melee) then
			HUD.ShowDeathFX(3);
		else
			HUD.ShowDeathFX(1);
		end
	end


	-- if killed is a local actor 
	
	local points = 1;
	if (playerId==g_localActorId) then
		if(self.game:GetTeamCount()>1 and self.game:GetTeam(shooterId)==self.game:GetTeam(playerId) and shooterId~=playerId) then
			points = self:CalculateScore(0, 0, 0, 0);
		else
			points = self:CalculateScore(1, 0, 0, 0);
		end
	elseif (shooterId==g_localActorId) then
		if(playerId==shooterId) then
			points = self:CalculateScore(0, 0, 0, 1);
		else 
			if(self.game:GetTeamCount()>1 and self.game:GetTeam(shooterId)==self.game:GetTeam(playerId)) then
				points = self:CalculateScore(0, 0, 1, 0);
			else
				points = self:CalculateScore(0, 1, 0, 0);
			end
		end
	end

	local target=System.GetEntity(playerId);
	local shooter=System.GetEntity(shooterId);

	if(playerId==g_localActorId) then

		if (shooter and shooter.actor and shooter.actor:IsPlayer()) then
			
			if(target.myKillersCountTable==nil) then
				target.myKillersCountTable = {};
			end
			
			if(target.myKillersCountTable[shooter.id]== nil) then
				target.myKillersCountTable[shooter.id] = 0;
			end
			
			local teamkill = (self.game:GetTeam(playerId)==self.game:GetTeam(shooterId)) and (self.game:GetTeamCount() > 1);

			target.myKillersCountTable[shooter.id] = target.myKillersCountTable[shooter.id]+1;

			HUD.DisplayKillMessage(shooter:GetName(), target.myKillersCountTable[shooter.id], teamkill, false, playerId==shooterId, points);
			if (points~=0 and self:DisplayKillScores()) then
				HUD.DisplayFunMessage(tostring(points));
			end

		end

	end
		
	-- if shooter is a local actor and not a self kill
	if(shooterId==g_localActorId and playerId~=shooterId) then
	
		if (target and target.actor and target.actor:IsPlayer()) then

			if(shooter.myKillsCountTable==nil) then
				shooter.myKillsCountTable = {};
			end
			
			if(shooter.myKillsCountTable[target.id]== nil) then
				shooter.myKillsCountTable[target.id] = 0;
			end
			
			local teamkill = (self.game:GetTeam(playerId)==self.game:GetTeam(shooterId)) and (self.game:GetTeamCount() > 1);
			
			shooter.myKillsCountTable[target.id] = shooter.myKillsCountTable[target.id]+1;

			HUD.DisplayKillMessage(target:GetName(), shooter.myKillsCountTable[target.id], teamkill, true, playerId==shooterId, points);
			if (points~=0 and self:DisplayKillScores()) then
				HUD.DisplayFunMessage(tostring(points));
			end

		end

	end

end


----------------------------------------------------------------------------------------------------
function Coop:ShatterEntity(entityId, hit)
	local entity=System.GetEntity(entityId);
	local dead=false;
	if (entity) then
		if (entity.IsDead) then
			dead=entity:IsDead();
		end
		
		if (hit.shooterId==entityId) then
			if (entity.frostShooterId) then
				hit.shooterId=entity.frostShooterId;
				hit.shooter=System.GetEntity(entity.frostShooterId);
			end
		end
	
		if (entity.actor and entity.actor:IsPlayer() and (not dead)) then
			entity.death_time=_time;
			entity.death_pos=entity:GetWorldPos(entity.death_pos);
			self.game:KillPlayer(entityId, false, false, hit.shooterId, hit.weaponId, hit.damage, hit.materialId, hit.typeId, hit.dir);
		end
	end
	
	local damage=math.min(100, hit.damage or 0);
	damage=math.max(20, damage);
	self.game:ShatterEntity(entityId, hit.pos, vecScale(hit.dir, damage));

	if (entity.Server and entity.Server.OnShattered) then
		entity.Server.OnShattered(entity, hit);
	end	
end

----------------------------------------------------------------------------------------------------
function Coop:KillPlayer(player)
	local hit = self.killHit;
	hit.pos=player:GetWorldPos(self.killHit.pos);
	hit.dir=g_Vectors.v000;
	hit.radius = 0;	
	hit.partId = -1;
	hit.target = player;
	hit.targetId = player.id;
	hit.weapon = player;
	hit.weaponId = player.id
	hit.shooter = player;
	hit.shooterId = player.id
	hit.materialId = 0;
	hit.damage = 0;
	hit.typeId = self.game:GetHitTypeId("normal");
	hit.type = "normal";
	
	self:ProcessDeath(hit);
end

----------------------------------------------------------------------------------------------------
function Coop:ProcessDeath(hit)
	if (hit.target.actor:IsPlayer()) then
		self.Server.OnPlayerKilled(self, hit);
	else
		hit.target:Kill(true, hit.shooterId, hit.weaponId);
	end
end


----------------------------------------------------------------------------------------------------
function Coop:ResetScore(playerId)
	self.game:SetSynchedEntityValue(playerId, self.SCORE_KILLS_KEY, 0);
	self.game:SetSynchedEntityValue(playerId, self.SCORE_DEATHS_KEY, 0);
	self.game:SetSynchedEntityValue(playerId, self.SCORE_HEADSHOTS_KEY, 0);
	CryAction.SendGameplayEvent(playerId, eGE_ScoreReset, "", 0);
end

----------------------------------------------------------------------------------------------------
function Coop:GetPlayerScore(playerId)
	return self.game:GetSynchedEntityValue(playerId, self.SCORE_KILLS_KEY, 0) or 0;
end

----------------------------------------------------------------------------------------------------
function Coop:GetPlayerDeaths(playerId)
	return self.game:GetSynchedEntityValue(playerId, self.SCORE_DEATHS_KEY, 0) or 0;
end

----------------------------------------------------------------------------------------------------
function Coop:ProcessVehicleScores(targetId, shooterId)
end

----------------------------------------------------------------------------------------------------
function Coop.Server:RequestRevive(entityId)

--Log(">>>> Coop.Server:RequestRevive");
	local player = System.GetEntity(entityId);

	if (player and player.actor) then
		if (player:IsDead()) then
			self:RevivePlayer(player.actor:GetChannel(), player);
		end
	end
end

function Coop.Server:RequestDefibrillate(entityId)
	local player = System.GetEntity(entityId);
	
	local teamId=self.game:GetTeam(player.id);
	
	player.lastExitedVehicleId = nil;
	player.lastExitedVehicleTime = nil;
	
	player.spawn_time=_time;
	player.skipSpawnId=spawnId;

	local pos = player:GetWorldPos();
	local angles = player:GetWorldAngles();

	self.game:RevivePlayer(player.id, pos, angles, teamId, false);		

	-- Give player new equipment for now until alternative solution
	self:EquipPlayer(player);
	
	-- make the game realise the areas we're in right now...
	-- otherwise we'd have to wait for an entity system update, next frame
	player:UpdateAreas();

	if(player.actor:GetSpectatorMode() ~= 0) then
		player.actor:SetSpectatorMode(0, NULL_ENTITY);
	end
	
	player.death_time=nil;
	player.frostShooterId=nil;
end

----------------------------------------------------------------------------------------------------
function Coop.Server:RequestSpectatorTarget(playerId, change)
end

----------------------------------------------------------------------------------------------------
function Coop.Client:ClSetupPlayer(playerId)
	self:SetupPlayer(System.GetEntity(playerId));
end

----------------------------------------------------------------------------------------------------
function Coop:GetServerStateTable()
	local s=self:GetState();
	return self.Server[s];
end

----------------------------------------------------------------------------------------------------
function Coop:GetClientStateTable()
	return self.Client[self:GetState()];
end

----------------------------------------------------------------------------------------------------
function Coop:OnTick()
	local onTick=self:GetServerStateTable().OnTick;
	if (onTick) then
		onTick(self);
	end
end

----------------------------------------------------------------------------------------------------
function Coop:OnClientTick()
	local onTick=self:GetClientStateTable().OnTick;
	if (onTick) then
		onTick(self);
	end
end

----------------------------------------------------------------------------------------------------
function Coop:ReviveAllPlayers(keepEquip)

--Log(">>>>> Coop:ReviveAllPlayers");
	local players=self.game:GetPlayers();

	if (players) then
		for i,player in ipairs(players) do
			if (player and player.actor and player.actor:GetSpectatorMode()==0) then
				self:RevivePlayer(player.actor:GetChannel(), player, keepEquip);
			end
		end
	end
end

----------------------------------------------------------------------------------------------------
function Coop:DefaultState(cs, state)
	local default=self[cs];
	self[cs][state]={
		OnClientConnect = default.OnClientConnect,
		OnClientDisconnect = default.OnClientDisconnect,
		OnClientEnteredGame = default.OnClientEnteredGame,
		OnDisconnect = default.OnDisconnect, -- client only
		OnActorAction = default.OnActorAction, -- client only
		OnStartLevel = default.OnStartLevel,
		OnStartGame = default.OnStartGame,
		
		OnKill = default.OnKill,
		OnHit = default.OnHit,
		OnFreeze = default.OnFreeze,
		OnExplosion = default.OnExplosion,
		OnChangeTeam = default.OnChangeTeam,
		OnChangeSpectatorMode = default.OnChangeSpectatorMode,
		RequestSpectatorTarget = default.RequestSpectatorTarget,
		OnSetTeam = default.OnSetTeam,
		OnItemPickedUp = default.OnItemPickedUp,
		OnItemDropped = default.OnItemDropped,

		OnTimer = default.OnTimer,
		OnUpdate = default.OnUpdate,	
	}
end

----------------------------------------------------------------------------------------------------
Coop:DefaultState("Server", "Reset");
Coop:DefaultState("Client", "Reset");

----------------------------------------------------------------------------------------------------
Coop:DefaultState("Server", "InGame");
Coop:DefaultState("Client", "InGame");

----------------------------------------------------------------------------------------------------
Coop:DefaultState("Server", "PostGame");
Coop:DefaultState("Client", "PostGame");

----------------------------------------------------------------------------------------------------
Coop.Server.PostGame.OnChangeTeam = nil;
Coop.Server.PostGame.OnChangeSpectatorMode = nil;

----------------------------------------------------------------------------------------------------
function Coop.Server.InGame:OnTick()
end

----------------------------------------------------------------------------------------------------
function Coop.Server.InGame:OnBeginState()
	self:ResetTime();
	self:StartTicking();
	
	CryAction.SendGameplayEvent(NULL_ENTITY, eGE_GameStarted, "", 1);--server
end

----------------------------------------------------------------------------------------------------
function Coop.Client.InGame:OnBeginState()
	self:StartTicking(true);
	
	CryAction.SendGameplayEvent(NULL_ENTITY, eGE_GameStarted, "", 0);--client
end


----------------------------------------------------------------------------------------------------
function Coop.Server.InGame:OnUpdate(frameTime)
	Coop.Server.OnUpdate(self, frameTime);
	
	if (self:IsMissionFailed()) then
		self.bMissionFailed = true;
		self:OnGameEnd(false);
	end
end


----------------------------------------------------------------------------------------------------
function Coop.Server.PostGame:OnBeginState()
	CryAction.SendGameplayEvent(NULL_ENTITY, eGE_GameEnd, "", 1);--server
	
	self:StartTicking();
	self:SetTimer(self.NEXTLEVEL_TIMERID, self.NEXTLEVEL_TIME);
end


----------------------------------------------------------------------------------------------------
function Coop.Client.PostGame:OnBeginState()	
	CryAction.SendGameplayEvent(NULL_ENTITY, eGE_GameEnd, "", 0);--client
	
	self:StartTicking(true);
	self:SetTimer(self.ENDGAME_TIMERID, self.ENDGAME_TIME);
end


----------------------------------------------------------------------------------------------------
function Coop.Client.PostGame:OnEndState()
	self:EndGame(false);
end


----------------------------------------------------------------------------------------------------
function Coop:EquipActor(actor)
end

----------------------------------------------------------------------------------------------------
function Coop:EquipPlayer(actor, additionalEquip)
	if(self.game:IsDemoMode() ~= 0) then -- don't equip actors in demo playback mode, only use existing items
		Log("Don't Equip : DemoMode");
		return;
	end;

	actor.inventory:Destroy();

	ItemSystem.GiveItem("AlienCloak", actor.id, false);
	ItemSystem.GiveItem("OffHand", actor.id, false);
	ItemSystem.GiveItem("Fists", actor.id, false);
	ItemSystem.GiveItem("NightVision", actor.id, false);	
	
	if (additionalEquip and additionalEquip~="") then
		ItemSystem.GiveItemPack(actor.id, additionalEquip, true);
	end

	ItemSystem.GiveItem("Binoculars", actor.id, true);
	ItemSystem.GiveItem("SOCOM", actor.id, true);
	ItemSystem.GiveItem("SCAR", actor.id, true);
	ItemSystem.GiveItem("Silencer", actor.id, true);
	ItemSystem.GiveItem("SOCOMSilencer", actor.id, true);
	ItemSystem.GiveItem("Reflex", actor.id, true);
	ItemSystem.GiveItem("LAM", actor.id, true);
	ItemSystem.GiveItem("LAMFlashLight", actor.id, true);
	ItemSystem.GiveItem("LAMRifleFlashLight", actor.id, true);
	ItemSystem.GiveItem("Defibrillator", actor.id, true);
end

----------------------------------------------------------------------------------------------------
function Coop.Client:ClVictory()
	self.game:GameOver(1);
end

----------------------------------------------------------------------------------------------------
function Coop.Client:ClClientConnect(name, reconnect)
	if (reconnect) then
		HUD.BattleLogEvent(eBLE_Information, "@mp_BLPlayerReConnected", name);
	else
		HUD.BattleLogEvent(eBLE_Information, "@mp_BLPlayerConnected", name);
	end
end

----------------------------------------------------------------------------------------------------
function Coop.Client:ClClientDisconnect(name)
	HUD.BattleLogEvent(eBLE_Information, "@mp_BLPlayerDisconnected", name);
end

----------------------------------------------------------------------------------------------------
function Coop.Client:ClClientEnteredGame(name)
	HUD.BattleLogEvent(eBLE_Information, "@mp_BLPlayerEnteredGame", name);
end

----------------------------------------------------------------------------------------------------
function Coop.Client:ClDefeat()
	HUD.DisplayBigOverlayFlashMessage("Raptor Team Has Been Eliminated!", 5.0, 400, 375, self.hudWhite);
	
	-- Play music for defeat
	Sound.PlayPattern("mp_lose", false, false);
	
	--self.game:GameOver(0);
end

----------------------------------------------------------------------------------------------------
function Coop.Client:ClTimerAlert(time)
	if (not g_localActorId) then return end
end
