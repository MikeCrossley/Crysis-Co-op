-- Wind area
WindArea = {
	Properties = {
		bActive = 1,
		Size = { x=10,y=10,z=10 },
		bEllipsoidal = 1,
		FalloffInner = 0,
		Dir = { x=0,y=0,z=0 },
		Speed = 0,
		AirResistance = 0,
		AirDensity = 0,
	},
	Editor = {
		Icon = "Tornado.bmp",
	},
	_PhysTable = { Area={}, },
}

-------------------------------------------------------
function WindArea:OnLoad(table)
  self.bActive = table.bActive  
end

-------------------------------------------------------
function WindArea:OnSave(table)
  table.bActive = self.bActive
end

------------------------------------------------------------------------------------------------------
function WindArea:OnInit()
	self.bActive = self.Properties.bActive;
	if (self.bActive == 1) then
		self:PhysicalizeThis();
	end
end

------------------------------------------------------------------------------------------------------
-- OnPropertyChange called only by the editor.
------------------------------------------------------------------------------------------------------
function WindArea:OnPropertyChange()
	self.bActive = self.Properties.bActive;
	self:PhysicalizeThis();
end

------------------------------------------------------------------------------------------------------
-- OnReset called only by the editor.
------------------------------------------------------------------------------------------------------
function WindArea:OnReset()
end

------------------------------------------------------------------------------------------------------
function WindArea:PhysicalizeThis()
	if (self.bActive == 1) then
		local Properties = self.Properties;
		local Area = self._PhysTable.Area;
		Area.type = AREA_BOX;
		Area.box_max = Properties.Size;
		Area.box_min = { x = -Area.box_max.x, y = -Area.box_max.y, z = -Area.box_max.z };
		if (Properties.bEllipsoidal == 1 or Properties.FalloffInner < 1) then
			Area.falloffInner = Properties.FalloffInner;
		else
			Area.falloffInner = -1;
		end
		if (Properties.Dir.x == 0 and Properties.Dir.y == 0 and Properties.Dir.z == 0) then
			Area.uniform = 0;
			Area.wind = {x = 0, y = 0, z = Properties.Speed};
		else
			Area.uniform = 2;
			Area.wind = { x = Properties.Dir.x * Properties.Speed, y = Properties.Dir.y * Properties.Speed, z = Properties.Dir.z * Properties.Speed };
		end
		Area.resistance = Properties.AirResistance;
		Area.density = Properties.AirDensity;
		self:Physicalize( 0,PE_AREA,self._PhysTable );
	else
		self:DestroyPhysics();
	end
end

------------------------------------------------------------------------------------------------------
function WindArea:Event_Activate()
	if (self.bActive ~= 1) then
		self.bActive = 1;
		self:PhysicalizeThis();
	end
end


------------------------------------------------------------------------------------------------------
function WindArea:Event_Deactivate()
	if (self.bActive ~= 0) then
		self.bActive = 0;
		self:PhysicalizeThis();
	end
end

WindArea.FlowEvents =
{
	Inputs =
	{
		Deactivate = { WindArea.Event_Deactivate, "bool" },
		Activate = { WindArea.Event_Activate, "bool" },
	},
	Outputs =
	{
		Deactivate = "bool",
		Activate = "bool",
	},
}
