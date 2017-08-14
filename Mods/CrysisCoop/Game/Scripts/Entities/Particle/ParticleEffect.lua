ParticleEffect = {
	Properties = {
		soclasses_SmartObjectClass = "",
		ParticleEffect="",
		
		bActive=1,
		bPrime=1,
		Scale=1,								-- Scale entire effect size.
		SpeedScale=1,						-- Scale particle emission speed
		CountScale=1,						-- Scale particle counts.
		bCountPerUnit=0,				-- Multiply count by attachment extent
		AttachType="",					-- BoundingBox, Physics, Render
		AttachForm="Surface",		-- Vertices, Edges, Surface, Volume
		PulsePeriod=0,					-- Restart continually at this period.
	},
	Editor = {
		Model="Editor/Objects/Particles.cgf",
		Icon="Particles.bmp",
	},
	
	States = { "Active","Idle" },
};


-------------------------------------------------------
function ParticleEffect:OnLoad(table)
	if (not table.nParticleSlot) then
		self:Disable();
	elseif (not self.nParticleSlot or self.nParticleSlot ~= table.nParticleSlot) then
		self:Disable();
		if (table.nParticleSlot >= 0) then
			self.nParticleSlot = self:LoadParticleEffect( table.nParticleSlot, self.Properties.ParticleEffect, self.Properties );
		end
	end
end

-------------------------------------------------------
function ParticleEffect:OnSave(table)
  table.nParticleSlot = self.nParticleSlot;
end


-------------------------------------------------------
function ParticleEffect:OnInit()
	self.nParticleSlot=-1;
	self.spawnTimer = 0;
	
	self:SetRegisterInSectors(1);
	
	self:SetUpdatePolicy(ENTITY_UPDATE_POT_VISIBLE);
	self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);

	self:OnReset();
	self:PreLoadParticleEffect( self.Properties.ParticleEffect );
	--self:NetPresent(nil);
end

-------------------------------------------------------
function ParticleEffect:OnPropertyChange()
	self:GotoState("");
	self:OnReset();
end

-------------------------------------------------------
function ParticleEffect:OnReset()
	if (self.Properties.bActive ~= 0) then
		self:GotoState( "Active" );
	else
		self:GotoState( "Idle" );
	end
end

------------------------------------------------------------------------------------------------------
function ParticleEffect:Event_Enable()
	self:GotoState( "Active" );
	self:ActivateOutput( "Enable", true );
end

function ParticleEffect:Event_Disable()
	self:GotoState( "Idle" );
	self:ActivateOutput( "Disable", true );
end

function ParticleEffect:Event_Restart()
	self:GotoState( "Idle" );
	self:GotoState( "Active" );
	self:ActivateOutput( "Restart", true );
end

function ParticleEffect:Event_Spawn()
	self:GetDirectionVector(1, g_Vectors.temp_v2); -- 1=forward vector
	Particle.SpawnEffect( self.Properties.ParticleEffect, self:GetPos(g_Vectors.temp_v1), g_Vectors.temp_v2, self.Properties.Scale );
	self:ActivateOutput( "Spawn", true );
end

-------------------------------------------------------------------------------
function ParticleEffect:Enable()
	if (not self.nParticleSlot or self.nParticleSlot < 0) then
		self.nParticleSlot = self:LoadParticleEffect( -1, self.Properties.ParticleEffect, self.Properties );
	end
end

function ParticleEffect:Disable()
	if (self.nParticleSlot and self.nParticleSlot >= 0) then
		self:FreeSlot(self.nParticleSlot);
		self.nParticleSlot = -1;
	end
end

-------------------------------------------------------------------------------
-- Active State
-------------------------------------------------------------------------------
ParticleEffect.Active =
{
	OnBeginState = function( self )
		self:Enable();
	end,
	OnEndState = function( self )
		self:Disable();
	end,
	
	OnLeaveArea = function( self,entity,areaId )
		self:GotoState( "Idle" );
	end,
}

-------------------------------------------------------------------------------
-- Idle State
-------------------------------------------------------------------------------
ParticleEffect.Idle =
{
	OnBeginState = function( self )
		self:Disable();
	end,
	OnEnterArea = function( self,entity,areaId )
		self:GotoState( "Active" );
	end,
}

-------------------------------------------------------
function ParticleEffect:OnShutDown()
end

ParticleEffect.FlowEvents =
{
	Inputs =
	{
		Disable = { ParticleEffect.Event_Disable, "bool" },
		Enable = { ParticleEffect.Event_Enable, "bool" },
		Restart = { ParticleEffect.Event_Restart, "bool" },
		Spawn = { ParticleEffect.Event_Spawn, "bool" },
	},
	Outputs =
	{
		Disable = "bool",
		Enable = "bool",
		Restart = "bool",
		Spawn = "bool",
	},
}
