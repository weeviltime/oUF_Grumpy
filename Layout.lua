local _, playerClass = UnitClass("player")

local TEXTURE = "Interface\\ChatFrame\\ChatFrameBackground"
local BACKDROP = {
	bgFile = TEXTURE,
	insets = {top = -1, bottom = -1, left = -1, right = -1}
}
local ICON_SIZE = 30
local P_HEALTH_WIDTH = 350
local P_HEALTH_HEIGHT = 10
local P_POWER_WIDTH = 100
local P_POWER_HEIGHT = 7
local S_HEALTH_WIDTH = 150
local S_POWER_WIDTH = 50

-- Functions
local function PostCreateAura(self, button)
	-- I have to thank P3lim, creator of oUF_P3lim
	-- and other Plugins, this part of code ensure that our strings
	-- stay above cooldown widget.
	local StringParent = CreateFrame("Frame", nil, button)
	StringParent:SetFrameLevel(20)

	local cd = button.cd:GetRegions()
	cd:ClearAllPoints()
	cd:SetFontObject("DejaVuAuraOutlineCenter")
	cd:SetTextColor(1,1,1,1)
	cd:SetPoint("BOTTOM",button,"BOTTOM",0,2)

	local stack = button.count
	stack:ClearAllPoints()
	stack:SetParent(StringParent)
	stack:SetFontObject("DejaVuAuraOutlineCenter")
	stack:SetTextColor(1,1,1,1)
	stack:SetPoint("TOPRIGHT",button,"TOPRIGHT",0,0)

	button.icon:SetTexCoord(.06,.94,.06,.94)
end

local function PostHealPrediction(self, unit)
	local totalAbsorb = UnitGetTotalAbsorbs(unit)
	local maxHealth = UnitHealthMax(unit)
	self.absorbBar:SetMinMaxValues(0, maxHealth)
	self.absorbBar:SetValue(totalAbsorb)
	self.absorbBar:Show()
end

local UnitSpecific = {
	player = function(self)
		-- Health
		self.Health:SetWidth(P_HEALTH_WIDTH)
		self.Health:SetHeight(P_HEALTH_HEIGHT)

		-- Absorbs
		local absorbBar = CreateFrame('StatusBar', nil, self.Health)
   	absorbBar:SetPoint('TOPLEFT', self.Health, 'TOPLEFT', 0, 0)
		absorbBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
		absorbBar:SetStatusBarTexture(TEXTURE)
		absorbBar:SetWidth(P_HEALTH_WIDTH)
		absorbBar:SetHeight(P_HEALTH_HEIGHT / 3)

		-- Power
		self.Power:SetWidth(P_POWER_WIDTH)
		self.Power:SetHeight(P_POWER_HEIGHT)
		self.Power:SetPoint("BOTTOMRIGHT",self.Health,"TOPRIGHT",0, 1)

		-- Buffs
		local Buffs = CreateFrame("Frame", nil, self)
		Buffs:SetWidth(P_HEALTH_WIDTH)
		Buffs:SetHeight(ICON_SIZE * 2)
		Buffs.size = ICON_SIZE
		Buffs.spacing = 2
		Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
		Buffs.PostCreateIcon = PostCreateAura

		-- Debuffs
		local Debuffs = CreateFrame("Frame",nil,self)
		Debuffs:SetWidth(P_HEALTH_WIDTH)
		Debuffs.size = ICON_SIZE
		Debuffs.spacing = 2
		Debuffs["growth-y"] = "DOWN"
		Debuffs:SetPoint("TOPRIGHT",self.Totems,"BOTTOMRIGHT",0,-2)
		Debuffs.PostCreateIcon = PostCreateAura

		-- Health Tags position and settings
		self.HealthValue:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, 0)
		self.Health.textSeparator:SetPoint("RIGHT", self.HealthValue, "LEFT", 0, 0)
		self.HealthPer:SetPoint("RIGHT",self.Health.textSeparator,"LEFT",0,0)

		-- Power Tags position and settings
		self.PowerValue:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 0)

		-- Level & Name Tag
		self.NameText:SetPoint("BOTTOMLEFT",self.Health,"TOPLEFT",0, 1)
		self.LevelText:SetPoint("TOPLEFT",self.Health,"BOTTOMLEFT",0,1)

		--[[ 3D Portrait
		-- Position and size
		-- Due how resolution and pixels works in WoW, I had to SetPoint disjointed from
		-- the oUF Frame. Otherwise there would always be a side without the pixel border.
		-- Another reason could be, Frames attached to another Frame will try to always put that
		-- pixel on the exact location disregarding BACKDROP. I made a test with 2 frames (one background and the 3D layer)
		-- the 3D layer always was attached to the background on Left and Top, the BottomRight of background was attached
		-- to BottomLeft of Player Frame. It didn"t work, always one or 2 sides were without 1 pixel.
		local PortraitModel = CreateFrame("PlayerModel",nil,self)
		PortraitModel:SetWidth(99.5)
		PortraitModel:SetHeight(149.5)
		PortraitModel:SetBackdrop(BACKDROP)
		PortraitModel:SetBackdropColor(0,0,0)
		PortraitModel:SetPoint("CENTER",nil,"CENTER",-401,-90)
		]]

		-- Castbar
		self.CastbarFrame:SetSize(300,30)
		self.CastbarFrame:SetPoint("CENTER",UIParent,"CENTER",0,-220)

		local SpellIcon = self.Castbar:CreateTexture(nil,"OVERLAY")
		SpellIcon:SetPoint("LEFT",self.CastbarFrame)
		SpellIcon:SetPoint("TOP",self.CastbarFrame)
		SpellIcon:SetPoint("BOTTOM",self.CastbarFrame)
		SpellIcon:SetWidth(self.CastbarFrame:GetHeight())
		SpellIcon:SetTexCoord(.06,.94,.06,.94)

		local TimeText = self.Castbar:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalRight")
		TimeText:SetPoint("RIGHT", self.Castbar,-1,0)

		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalLeft")
		SpellText:SetPoint("LEFT",self.Castbar,1,0)

		self.Castbar:SetPoint("TOP",self.CastbarFrame)
		self.Castbar:SetPoint("RIGHT",self.CastbarFrame)
		self.Castbar:SetPoint("LEFT",SpellIcon,"RIGHT",1,0)

		if(playerClass == "ROGUE" or playerClass == "DRUID" or playerClass == "MONK") then
			local ClassIcons = {}
			for index = 1, 6 do
				local Icon = self:CreateTexture(nil, "BACKGROUND")
				-- Position and size.
				Icon:SetSize(16, 16)
				Icon:SetPoint("CENTER",UIParent,"CENTER", index * Icon:GetWidth(), -200)
				ClassIcons[index] = Icon
			end
			self.ClassIcons = ClassIcons
		end
		if(playerClass == "MONK") then
			local Stagger = CreateFrame("StatusBar",nil,self.Health)
			Stagger:SetHeight(P_HEALTH_HEIGHT / 3)
			Stagger:SetPoint("TOPLEFT",self.Health,"TOPLEFT",0,0)
			Stagger:SetPoint("TOPRIGHT", self.Health)
			Stagger:SetStatusBarTexture(TEXTURE)
			self.Stagger = Stagger
		elseif(playerClass == "SHAMAN" or playerClass == "PRIEST" or playerClass == "DRUID") then
			local ManaBar = CreateFrame("StatusBar",nil,self)
			ManaBar:SetSize(P_POWER_WIDTH, P_POWER_HEIGHT)
			ManaBar:SetPoint("RIGHT",self.Power,"LEFT",-1,0)
			ManaBar:SetStatusBarTexture(TEXTURE)
			ManaBar:SetBackdrop(BACKDROP)
			ManaBar:SetBackdropColor(0,0,0)
			ManaBar.colorPower = true
			self.AdditionalPower = ManaBar
		end

		-- TODO: Totems
		local Totems = {}
		for index = 1, MAX_TOTEMS do
			-- Position and size of the totem indicator
			local Totem = CreateFrame("BUTTON", nil, self)
			Totem:SetSize(25, 25)
			Totem:SetPoint("TOPLEFT", self.LevelText, "BOTTOMLEFT", index * Totem:GetWidth(), 0)

			local Icon = Totem:CreateTexture(nil, "OVERLAY")
			Icon:SetAllPoints()

			local Cooldown = CreateFrame("Cooldown", nil, Totem, "CooldownFrameTemplate")
			Cooldown:SetAllPoints()

			Totem.Icon = Icon
			Totem.Cooldown = Cooldown

			Totems[index] = Totem
		end

		-- Register with oUF
		self:SetWidth(P_HEALTH_WIDTH)
		self:SetHeight(P_HEALTH_HEIGHT + P_POWER_HEIGHT + 1)
    self.HealPrediction = {
        --myBar = myBar,
        --otherBar = otherBar,
        --healAbsorbBar = healAbsorbBar,
        absorbBar = absorbBar,
        maxOverflow = 1.0,
        frequentUpdates = true
		}
		self.HealPrediction.PostUpdate = PostHealPrediction
		self.Buffs = Buffs
		self.Debuffs = Debuffs
		self.Castbar.Time = TimeText
		self.Castbar.Text = SpellText
		self.Castbar.Icon = SpellIcon
 end,

 target = function(self)
		-- Health
		self.Health:SetWidth(P_HEALTH_WIDTH)
		self.Health:SetHeight(P_HEALTH_HEIGHT)

		-- Power
		self.Power:SetWidth(P_POWER_WIDTH)
		self.Power:SetHeight(P_POWER_HEIGHT)
		self.Power:SetPoint("BOTTOMRIGHT",self.Health,"TOPRIGHT",0, 1)

		-- Buffs
		local Buffs = CreateFrame("Frame", nil, self)
		Buffs:SetWidth(P_HEALTH_WIDTH)
		Buffs:SetHeight(ICON_SIZE * 2)
		Buffs.size = ICON_SIZE
		Buffs.spacing = 2
		Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
		Buffs.PostCreateIcon = PostCreateAura

		-- Debuffs
		local Debuffs = CreateFrame("Frame",nil,self)
		Debuffs:SetSize(200,48)
		Debuffs.size = ICON_SIZE
		Debuffs.spacing = 2
		Debuffs.onlyShowPlayer = true
		Debuffs["growth-x"] = "LEFT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs.initialAnchor = "TOPRIGHT"
		Debuffs:SetPoint("TOPRIGHT",self,"BOTTOMRIGHT",0,-2)
		Debuffs.PostCreateIcon = PostCreateAura

		-- Health Tags position and settings
		self.HealthValue:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, 0)
		self.Health.textSeparator:SetPoint("RIGHT", self.HealthValue, "LEFT", 0, 0)
		self.HealthPer:SetPoint("RIGHT",self.Health.textSeparator,"LEFT",0,0)

		-- Power Tags position and settings
		self.PowerValue:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 0)

		-- Level & Name Tag
		self.NameText:SetPoint("BOTTOMLEFT",self.Health,"TOPLEFT",0, 1)
		self.LevelText:SetPoint("TOPLEFT",self.Health,"BOTTOMLEFT",0,1)

		--[[ 3D Portrait
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
		]]

		-- Castbar
		self.CastbarFrame:SetSize(300,30)
		self.CastbarFrame:SetPoint("BOTTOM",oUF_GrumpyPlayer.CastbarFrame,"TOP",0,1)
		local SpellIcon = self.Castbar:CreateTexture(nil,"OVERLAY")
		SpellIcon:SetSize(30,30)
		SpellIcon:SetPoint("TOPLEFT",self.CastbarFrame,"TOPLEFT")
		self.Castbar:SetPoint("TOP",self.CastbarFrame)
		self.Castbar:SetPoint("RIGHT",self.CastbarFrame)
		self.Castbar:SetPoint("LEFT",SpellIcon,"RIGHT",1,0)
		--self.Castbar:SetStatusBarColor(0.2,0.2,0.2,1)
		local TimeText = self.Castbar:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalRight")
		TimeText:SetPoint("RIGHT", self.Castbar,1,0)
		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalLeft")
		SpellText:SetPoint("LEFT",self.Castbar,1,0)

		-- Quest Icon
		local QuestIcon = self:CreateTexture(nil,"OVERLAY")
		QuestIcon:SetSize(16, 16)
		QuestIcon:SetPoint("CENTER", self, "BOTTOMRIGHT", 0 ,0)

		-- Register with oUF
		self:SetWidth(P_HEALTH_WIDTH)
		self:SetHeight(P_HEALTH_HEIGHT + P_POWER_HEIGHT + 1)
		self.Buffs = Buffs
		self.Debuffs = Debuffs
		--self.Portrait = PortraitModel
		self.Castbar.Time = TimeText
		self.Castbar.Text = SpellText
		self.Castbar.Icon = SpellIcon
		self.QuestIcon = QuestIcon
	end,

	targettarget = function(self)
		self.Health:SetWidth(S_HEALTH_WIDTH)
		self.Health:SetHeight(P_HEALTH_HEIGHT)
		self.Power:SetWidth(S_HEALTH_WIDTH)
		self.Power:SetHeight(P_POWER_HEIGHT)

		-- Health Tags position and settings
		self.HealthValue:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
		self.Health.textSeparator:SetPoint("RIGHT", self.HealthValue, "LEFT", 0, -1)
		self.HealthPer:SetPoint("RIGHT",self.Health.textSeparator,"LEFT",0,-0)

		-- Power Tags position and settings
		self.PowerValue:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 1)

		-- Level & Name Tag
		self.LevelText:SetPoint("TOPLEFT",self.Health,"TOPLEFT",0,1)
		self.NameText:SetPoint("BOTTOMLEFT",self.Health,"TOPLEFT",0, 1)

		-- Castbar
		self.CastbarFrame:SetSize(P_HEALTH_WIDTH ,15)
		self.CastbarFrame:SetPoint("BOTTOMRIGHT",self,"TOPRIGHT",0,1)
		self.CastbarFrame:SetBackdrop(BACKDROP)
		self.CastbarFrame:SetBackdropColor(0,0,0)
		self.Castbar:SetAllPoints(self.CastbarFrame)
		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalLeft")
		SpellText:SetPoint("LEFT",self.Castbar,1,0)

		-- Register with oUF
		self:SetWidth(S_HEALTH_WIDTH)
		self:SetHeight(P_HEALTH_HEIGHT + P_POWER_HEIGHT + 1)
		self.Castbar.Text = SpellText
	end,

	focus = function(self)
		self.Health:SetWidth(S_HEALTH_WIDTH)
		self.Health:SetHeight(P_HEALTH_HEIGHT)
		self.Power:SetWidth(S_HEALTH_WIDTH)
		self.Power:SetHeight(P_POWER_HEIGHT)

		-- Health Tags position and settings
		self.HealthValue:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
		self.Health.textSeparator:SetPoint("RIGHT", self.HealthValue, "LEFT", 0, -1)
		self.HealthPer:SetPoint("RIGHT",self.Health.textSeparator,"LEFT",0,-0)

		-- Power Tags position and settings
		self.PowerValue:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 1)

		-- Level & Name Tag
		self.LevelText:SetPoint("TOPLEFT",self.Health,"TOPLEFT",0,1)
		self.NameText:SetPoint("BOTTOMLEFT",self.Health,"TOPLEFT",0, 1)

		-- Castbar
		self.CastbarFrame:SetSize(P_HEALTH_WIDTH ,15)
		self.CastbarFrame:SetPoint("BOTTOMRIGHT",self,"TOPRIGHT",0,1)
		self.CastbarFrame:SetBackdrop(BACKDROP)
		self.CastbarFrame:SetBackdropColor(0,0,0)
		self.Castbar:SetAllPoints(self.CastbarFrame)
		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalLeft")
		SpellText:SetPoint("LEFT",self.Castbar,1,0)

		-- Register with oUF
		self:SetWidth(S_HEALTH_WIDTH)
		self:SetHeight(P_HEALTH_HEIGHT + P_POWER_HEIGHT + 1)
		self.Castbar.Text = SpellText
	end,
};

local function Shared(self, unit)
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	--create health statusbar func
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("BOTTOM")
	Health:SetPoint("LEFT")
	Health:SetPoint("RIGHT")
	Health:SetStatusBarTexture(TEXTURE)
	Health:SetStatusBarColor(0.2, 0.2, 0.2)
	Health:SetBackdrop(BACKDROP)
	Health:SetBackdropColor(0, 0, 0)

	-- Health Options
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.colorClass = true
	Health.colorClassNPC = false
	Health.colorReaction = false
	Health.colorHealth = false

	-- Level Tag
	local LevelText = Health:CreateFontString(nil,"OVERLAY","DejaVuTextNormalLeft")
	LevelText:SetTextColor(1,1,1)
	self.LevelText = LevelText
	self:Tag(self.LevelText,"[difficulty][level][shortclassification]")
	
	-- Name Tag
	local NameText = Health:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalLeft")
	NameText:SetTextColor(1, 1, 1)
	self.NameText = NameText
	self:Tag(self.NameText,"[name]")

	-- Health Tag
	local textSeparator = Health:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalRight")
	textSeparator:SetTextColor(1, 1, 1)
	textSeparator:SetText("|")
	local HealthValue = Health:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalRight")
	HealthValue:SetTextColor(1, 1, 1)
	local HealthPer = Health:CreateFontString(nil,"OVERLAY","DejaVuTextNormalRight")
	HealthPer:SetTextColor(1,1,1)
	self.HealthValue = HealthValue
	self.HealthPer = HealthPer
	Health.textSeparator = textSeparator
	self:Tag(self.HealthPer,"[grumpy:hpper]")
	self:Tag(self.HealthValue, "[grumpy:shorthp]")

	-- Power
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetStatusBarTexture(TEXTURE)
	Power:SetBackdrop(BACKDROP)
	Power:SetBackdropColor(0, 0, 0)
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
	local PowerValue = Power:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalLeft")
	PowerValue:SetTextColor(1, 1, 1)
	self.PowerValue = PowerValue
	self:Tag(self.PowerValue, "[grumpy:shortpp]")

	-- Castbar
	local Castbar = CreateFrame("StatusBar",nil,self)
	Castbar:SetFrameStrata("LOW")
	Castbar:SetStatusBarTexture(TEXTURE)
	Castbar:SetStatusBarColor(0.2,0.2,0.2,1)

	local CastbarFrame = CreateFrame("Frame",nil,Castbar)
	CastbarFrame:SetFrameStrata("BACKGROUND")
	CastbarFrame:SetBackdrop(BACKDROP)
	CastbarFrame:SetBackdropColor(0,0,0)

	-- Registiring everything
	self.Health = Health
	self.Power = Power
	self.Castbar = Castbar
	self.CastbarFrame = CastbarFrame

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
	oUF:Spawn("player"):SetPoint("CENTER",0,-140)
	oUF:Spawn("target"):SetPoint("CENTER",0,300)
	oUF:Spawn("targettarget"):SetPoint("TOPLEFT",oUF_GrumpyTarget,"TOPRIGHT",1,0)
	oUF:Spawn("focus"):SetPoint("TOPRIGHT",oUF_GrumpyPlayer,"TOPLEFT",-1,0)
--[[ Something I intend to add later, this was a test (and a succesfull one)
local Model = CreateFrame("PlayerModel","model",oUF_GrumpyPlayer)
Model:SetModel("SPELLS/Archimonde_blue_fire.m2")
Model:SetPosition(0,0,4.05)
Model:SetPoint("TOPLEFT",oUF_GrumpyPlayer.Power,"TOPLEFT",0,1)
Model:SetPoint("BOTTOMRIGHT",oUF_GrumpyPlayer.Power,"BOTTOMRIGHT",0,1)
]]
end)

