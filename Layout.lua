local _, PlayerClass = UnitClass("player")

local TEXTURE = "Interface\\ChatFrame\\ChatFrameBackground"
local BACKDROP = {
	bgFile = TEXTURE,
	insets = {top = -1, bottom = -1, left = -1, right = -1}
}

-- Functions
local function PostCreateAura(self, button)
	local cdText = button.cd:GetRegions()
	cdText:ClearAllPoints()
	cdText:SetFontObject("LiberationSansCenter")
	cdText:SetTextColor(1,1,1,1)
	cdText:SetTextHeight(10)
	cdText:SetPoint("BOTTOM",button,"BOTTOM",0,2)
end

local UnitSpecific = {
	player = function(self)
		-- Buffs
		local Buffs = CreateFrame("Frame", nil, self)
		Buffs:SetSize(200, 48)
		Buffs.size = 28
		Buffs.spacing = 2
		Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
		Buffs.PostCreateIcon = PostCreateAura

		-- Debuffs
		local Debuffs = CreateFrame("Frame",nil,self)
		Debuffs:SetSize(200,48)
		Debuffs.size = 28
		Debuffs.spacing = 2
		Debuffs:SetPoint("TOPRIGHT",self,"BOTTOMRIGHT",-1,-2)
		Debuffs.PostCreateIcon = PostCreateAura

		-- Health Tags position and settings
		self.HealthValue:SetPoint("LEFT", self.Health, "LEFT", 2, -1)
		self.HealthValue:SetJustifyH("LEFT")
		self.HealthPer:SetPoint("RIGHT",self.Health,"RIGHT",-2,-1)
		self.HealthPer:SetJustifyH("RIGHT")

		-- Power Tags position and settings
		self.PowerValue:SetPoint("RIGHT", self.Power, "RIGHT", -2, 1)
		self.PowerValue:SetJustifyH("RIGHT")

		-- 3D Portrait
		-- Position and size
		-- Due how resolution and pixels works in WoW, I had to SetPoint disjointed from
		-- the oUF Frame. Otherwise there would always be a side without the pixel border.
		-- Another reason could be, Frames attached to another Frame will try to always put that
		-- pixel on the exact location disregarding BACKDROP. I made a test with 2 frames (one background and the 3D layer)
		-- the 3D layer always was attached to the background on Left and Top, the BottomRight of background was attached
		-- to BottomLeft of Player Frame. It didn't work, always one or 2 sides were without 1 pixel.
		local PortraitModel = CreateFrame("PlayerModel",nil,self)
		PortraitModel:SetWidth(99.5)
		PortraitModel:SetHeight(149.5)
		PortraitModel:SetBackdrop(BACKDROP)
		PortraitModel:SetBackdropColor(0,0,0)
		PortraitModel:SetPoint("CENTER",nil,"CENTER",-401,-90)

		-- Castbar
		self.CastbarFrame:SetSize(300,30)
		self.CastbarFrame:SetPoint("CENTER",UIParent,"CENTER",0,-220)
		local SpellIcon = self.Castbar:CreateTexture(nil,"OVERLAY")
		SpellIcon:SetSize(30,30)
		SpellIcon:SetPoint("TOPLEFT",self.CastbarFrame,"TOPLEFT")
		self.Castbar:SetPoint("TOP",self.CastbarFrame)
		self.Castbar:SetPoint("RIGHT",self.CastbarFrame)
		self.Castbar:SetPoint("LEFT",SpellIcon,"RIGHT",1,0)
		self.Castbar:SetStatusBarColor(0.2,0.2,0.2,1)
		local TimeText = self.Castbar:CreateFontString(nil, "OVERLAY", "LiberationSansRight")
		TimeText:SetPoint("RIGHT", self.Castbar,0,2)
		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "LiberationSansLeft")
		SpellText:SetPoint("LEFT",self.Castbar,0,2)


		if(PlayerClass == "ROGUE" or PlayerClass == "DRUID" or PlayerClass == "MONK") then
			local ClassIcons = {}
			for index = 1, 6 do
				local Icon = self:CreateTexture(nil, 'BACKGROUND')
				-- Position and size.
				Icon:SetSize(16, 16)
				Icon:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * Icon:GetWidth(), 0)
				ClassIcons[index] = Icon
			end
			self.ClassIcons = ClassIcons
		end
		if(PlayerClass == "MONK") then
			local Stagger = CreateFrame("StatusBar",nil,self)
			Stagger:SetSize(200,5)
			Stagger:SetPoint("BOTTOMLEFT",self,"TOPLEFT",0,0)
			self.Stagger = Stagger
		elseif(PlayerClass == "SHAMAN" or PlayerClass == "PRIEST" or PlayerClass == "DRUID") then
			local ManaBar = CreateFrame("StatusBar",nil,self)
			ManaBar:SetSize(200,5)
			ManaBar:SetPoint("BOTTOMLEFT",self,"TOPLEFT",0,0)
			self.AdditionalPower = ManaBar
		end

		-- TODO: Totems

		-- Register with oUF
		self.Buffs = Buffs
		self.Debuffs = Debuffs
		self.Portrait = PortraitModel
		self.Castbar.Time = TimeText
		self.Castbar.Text = SpellText
		self.Castbar.Icon = SpellIcon
 end,

 target = function(self)
		-- Buffs
		local Buffs = CreateFrame("Frame", nil, self)
		Buffs:SetSize(200,48)
		Buffs.size = 28
		Buffs.spacing = 2
		Buffs["growth-x"] = "LEFT"
		Buffs.initialAnchor = "BOTTOMRIGHT"
		Buffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -1, 7)
		Buffs.PostCreateIcon = PostCreateAura

		-- Debuffs
		local Debuffs = CreateFrame("Frame",nil,self)
		Debuffs:SetSize(200,48)
		Debuffs.size = 28
		Debuffs.spacing = 2
		Debuffs["growth-x"] = "LEFT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs.initialAnchor = "TOPRIGHT"
		Debuffs:SetPoint("TOPRIGHT",self,"BOTTOMRIGHT",-1,-2)
		Debuffs.PostCreateIcon = PostCreateAura

		-- Health Tags position and settings
		self.HealthValue:SetPoint("RIGHT", self.Health, "RIGHT", -2, -1)
		self.HealthValue:SetJustifyH("RIGHT")
		self.HealthPer:SetPoint("LEFT",self.Health,"LEFT",2,-1)
		self.HealthPer:SetJustifyH("LEFT")

		-- Power Tags position and settings
		self.PowerValue:SetPoint("LEFT", self.Power, "LEFT", 2, 0)
		self.PowerValue:SetJustifyH("LEFT")

		-- 3D Portrait
		-- Position and size
		-- Due how resolution and pixels works in WoW, I had to SetPoint disjointed from
		-- the oUF Frame. Otherwise there would always be a side without the pixel border.
		-- Another reason could be, Frames attached to another Frame will try to always put that
		-- pixel on the exact location disregarding BACKDROP. I made a test with 2 frames (one background and the 3D layer)
		-- the 3D layer always was attached to the background on Left and Top, the BottomRight of background was attached
		-- to BottomLeft of Player Frame. It didn't work, always one or 2 sides were without 1 pixel.
		local PortraitModel = CreateFrame("PlayerModel",nil,self)
		PortraitModel:SetWidth(99.5)
		PortraitModel:SetHeight(149.5)
		PortraitModel:SetBackdrop(BACKDROP)
		PortraitModel:SetBackdropColor(0,0,0)
		PortraitModel:SetPoint("CENTER",nil,"CENTER",401,-90)

		-- Castbar
		self.CastbarFrame:SetSize(300,30)
		self.CastbarFrame:SetPoint("BOTTOM",oUF_GrumpyPlayer.CastbarFrame,"TOP",0,1)
		local SpellIcon = self.Castbar:CreateTexture(nil,"OVERLAY")
		SpellIcon:SetSize(30,30)
		SpellIcon:SetPoint("TOPLEFT",self.CastbarFrame,"TOPLEFT")
		self.Castbar:SetPoint("TOP",self.CastbarFrame)
		self.Castbar:SetPoint("RIGHT",self.CastbarFrame)
		self.Castbar:SetPoint("LEFT",SpellIcon,"RIGHT",1,0)
		self.Castbar:SetStatusBarColor(0.2,0.2,0.2,1)
		local TimeText = self.Castbar:CreateFontString(nil, "OVERLAY", "LiberationSansRight")
		TimeText:SetPoint("RIGHT", self.Castbar,0,2)
		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "LiberationSansLeft")
		SpellText:SetPoint("LEFT",self.Castbar,0,2)

		-- Register with oUF
		self.Buffs = Buffs
		self.Debuffs = Debuffs
		self.Portrait = PortraitModel
		self.Castbar.Time = TimeText
		self.Castbar.Text = SpellText
		self.Castbar.Icon = SpellIcon
	end,

	targettarget = function(self)
		self:SetSize(99.5,36)
		self.Health:SetHeight(25)
		self.Power:SetHeight(10)
		-- Text Tags settings
		self.NameText:SetPoint("LEFT",self.Health,"TOPLEFT",1,-5)
		self.NameText:SetJustifyH("LEFT")

		-- Health Tags settings
		self.HealthPer:SetPoint("RIGHT",self.Health,"BOTTOMRIGHT",-1,6)
		self.HealthPer:SetJustifyH("RIGHT")

		-- Castbar
		self.Castbar:SetSize(self:GetWidth()-15,15)
		self.Castbar:SetPoint("BOTTOMRIGHT",self,"TOPRIGHT",0,1)
		self.Castbar:SetStatusBarColor(0.2,0.2,0.2,1)
		local TimeText = self.Castbar:CreateFontString(nil, "OVERLAY", "LiberationSansRight")
		TimeText:SetPoint("RIGHT", self.Castbar)
		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "LiberationSansLeft")
		SpellText:SetPoint("LEFT",self.Castbar)
		local SpellIcon = self.Castbar:CreateTexture(nil,"OVERLAY")
		SpellIcon:SetSize(15,15)
		SpellIcon:SetPoint("TOPRIGHT",self.Castbar,"TOPLEFT")
	end,

	focus = function(self)
		self:SetSize(99.5,36)
		self.Health:SetHeight(25)
		self.Power:SetHeight(10)
		-- Text Tags settings
		self.NameText:SetPoint("LEFT",self.Health,"TOPLEFT",1,-5)
		self.NameText:SetJustifyH("LEFT")

		-- Health Tags settings
		self.HealthPer:SetPoint("RIGHT",self.Health,"BOTTOMRIGHT",-1,6)
		self.HealthPer:SetJustifyH("RIGHT")

		-- Castbar
		self.Castbar:SetSize(self:GetWidth()-15,15)
		self.Castbar:SetPoint("BOTTOMRIGHT",self,"TOPRIGHT",0,1)
		self.Castbar:SetStatusBarColor(0.2,0.2,0.2,1)
		local TimeText = self.Castbar:CreateFontString(nil, "OVERLAY", "LiberationSansRight")
		TimeText:SetPoint("RIGHT", self.Castbar)
		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "LiberationSansLeft")
		SpellText:SetPoint("LEFT",self.Castbar)
		local SpellIcon = self.Castbar:CreateTexture(nil,"OVERLAY")
		SpellIcon:SetSize(15,15)
		SpellIcon:SetPoint("TOPRIGHT",self.Castbar,"TOPLEFT")
	end,
};

local function Shared(self, unit)
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	--create health statusbar func
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetHeight(35)
	Health:SetPoint('BOTTOM')
	Health:SetPoint('LEFT')
	Health:SetPoint('RIGHT')
	Health:SetStatusBarTexture(TEXTURE)
	Health:SetStatusBarColor(0.2, 0.2, 0.2)

	-- Health Options
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.colorClass = true
	Health.colorClassNPC = false
	Health.colorReaction = true
	Health.colorHealth = false

	-- Text Tags
	local NameText = Health:CreateFontString(nil, "OVERLAY", "LiberationSansLeft")
	NameText:SetTextColor(1, 1, 1)
	self.NameText = NameText
	self:Tag(self.NameText,"[name]")

	-- Health Tags
	local HealthValue = Health:CreateFontString(nil, "OVERLAY", "LiberationSansLeft")
	HealthValue:SetTextColor(1, 1, 1)
	local HealthPer = Health:CreateFontString(nil,"OVERLAY","LiberationSansLeft")
	HealthPer:SetTextColor(1,1,1)
	self.HealthValue = HealthValue
	self.HealthPer = HealthPer
	self:Tag(self.HealthPer,"[grumpy:hpper]")
	self:Tag(self.HealthValue, "[grumpy:shorthp]")

	-- Position and size
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetHeight(15)
	Power:SetPoint('TOP')
	Power:SetPoint('LEFT')
	Power:SetPoint('RIGHT')
	Power:SetStatusBarTexture(TEXTURE)
	Power:SetStatusBarColor(1,0,1)

	-- Options
	Power.frequentUpdates = true
	Power.displayAltPower = false
	Power.colorTapping = true
	Power.colorDisconnected = true
	Power.colorPower = true
	Power.colorClass = false
	Power.colorReaction = false

	-- Power Tags
	local PowerValue = Power:CreateFontString(nil, "OVERLAY", "LiberationSansLeft")
	PowerValue:SetTextColor(1, 1, 1)
	self.PowerValue = PowerValue
	self:Tag(self.PowerValue, "[grumpy:shortpp]")

	-- Castbar
	local Castbar = CreateFrame("StatusBar",nil,self)
	Castbar:SetStatusBarTexture(TEXTURE)
	local CastbarFrame = CreateFrame("Frame",nil,Castbar)
	CastbarFrame:SetFrameStrata("BACKGROUND")
	CastbarFrame:SetBackdrop(BACKDROP)
	CastbarFrame:SetBackdropColor(0,0,0)

	-- Registiring everything
	self.Health = Health
	self.Power = Power
	self.Castbar = Castbar
	self.CastbarFrame = CastbarFrame
	self:SetSize(200,51)
	self:SetBackdrop(BACKDROP)
	self:SetBackdropColor(0, 0, 0)

	if(UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
end

--register style
oUF:RegisterStyle("Grumpy", Shared)

oUF:Factory(function(self)
	--activate style
	oUF:SetActiveStyle("Grumpy")

	--Spawn more OVERLORDS
	oUF:Spawn("player"):SetPoint("CENTER",-250,-140)
	oUF:Spawn("target"):SetPoint("CENTER",250,-140)
	oUF:Spawn("targettarget"):SetPoint("BOTTOMLEFT",oUF_GrumpyTarget.Portrait,"TOPLEFT",0,1)
	oUF:Spawn("focus"):SetPoint("BOTTOMLEFT",oUF_GrumpyPlayer.Portrait,"TOPLEFT",0,1)
end)

