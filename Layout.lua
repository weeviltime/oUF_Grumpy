local _, playerClass = UnitClass("player")

local TEXTURE = "Interface\\ChatFrame\\ChatFrameBackground"
local BACKDROP = {
	bgFile = TEXTURE,
	insets = {top = -1, bottom = -1, left = -1, right = -1}
}
local ICON_SIZE = 30
local P_HEALTH_WIDTH = 250
local P_HEALTH_HEIGHT = 30
local P_POWER_WIDTH = 250
local P_POWER_HEIGHT = 15
local S_HEALTH_WIDTH = 150
local S_HEALTH_HEIGHT = 30
local S_POWER_WIDTH = 150
local S_POWER_HEIGHT = 10

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

-- To test later, abosrb over health, not working properly
--[[local function PostHealthPrediction(self, unit)
	local totalAbsorb = UnitGetTotalAbsorbs(unit) or 0
	local maxHealth = UnitHealthMax(unit)
	self.absorbBar:SetMinMaxValues(0, maxHealth)
	self.absorbBar:SetValue(totalAbsorb)
	self.absorbBar:Show()
end]]

local UnitSpecific = {
	player = function(self)
	  -- Unit
		self:SetWidth(P_HEALTH_WIDTH)
		self:SetHeight(P_HEALTH_HEIGHT)

		-- Health
		self.Health:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
		self.Health:SetPoint("RIGHT")
		self.Health:SetHeight(P_HEALTH_HEIGHT)

		--[[ Absorbs
		local absorbBar = CreateFrame("StatusBar", nil, self.Health)
   	absorbBar:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 0, 0)
		absorbBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
		absorbBar:SetStatusBarTexture(TEXTURE)
		absorbBar:SetBackdrop(BACKDROP)
		absorbBar:SetWidth(P_HEALTH_WIDTH)
		absorbBar:SetHeight(P_HEALTH_HEIGHT)]]

		-- Power
		self.Power:SetWidth(P_POWER_WIDTH)
		self.Power:SetHeight(P_POWER_HEIGHT)
		self.Power:SetPoint("CENTER",nil,0,-240)

		-- Additional Power
		local AdditionalPower = CreateFrame("StatusBar", nil, self)
		AdditionalPower:SetWidth(P_POWER_WIDTH)
		AdditionalPower:SetHeight(P_POWER_HEIGHT)
		AdditionalPower:SetPoint("BOTTOMLEFT",self.Power,"TOPLEFT",0,5)
		AdditionalPower:SetBackdrop(BACKDROP)
		AdditionalPower:SetStatusBarTexture(TEXTURE)
		AdditionalPower:SetBackdropColor(0,0,0)
		AdditionalPower:SetStatusBarColor(0,.75,.1)
		if(playerClass == "MONK") then
			self.Stagger = AdditionalPower
		elseif(playerClass == "SHAMAN" or playerClass == "PRIEST" or playerClass == "DRUID") then
			AdditionalPower.colorPower = true
			self.AdditionalPower = AdditionalPower
		elseif(playerClass == "WARRIOR") then
			-- Wanna do this Additional bar as Ignore Pain absorb.
			self.IgnorePain = AdditionalPower
			local PainValue = self.IgnorePain:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalRight")
			PainValue:SetTextColor(1, 1, 1)
			self.IgnorePain.PainValue = PainValue
			self:Tag(self.IgnorePain.PainValue, "[ignorepain:cur]/[ignorepain:max]")
			self.IgnorePain.PainValue:SetPoint("CENTER",self.IgnorePain,0,0)
		end

		--[[ Buffs
		local Buffs = CreateFrame("Frame", nil, self)
		Buffs:SetWidth(P_HEALTH_WIDTH)
		Buffs:SetHeight(ICON_SIZE * 2)
		Buffs.size = ICON_SIZE
		Buffs.spacing = 2
		Buffs:SetPoint("BOTTOMRIGHT", self.PowerValue, "TOPRIGHT", 0, 1)
		Buffs.PostCreateIcon = PostCreateAura]]

		-- Debuffs
		local Debuffs = CreateFrame("Frame",nil,self)
		Debuffs:SetWidth(P_HEALTH_WIDTH)
		Debuffs:SetHeight(ICON_SIZE * 2)
		Debuffs.size = ICON_SIZE
		Debuffs.spacing = 2
		Debuffs["growth-y"] = "UP"
		Debuffs.initialAnchor = "BOTTOMLEFT"
		Debuffs:SetPoint("BOTTOM",self.NameText,"TOP",0,1)
		Debuffs.PostCreateIcon = PostCreateAura

		-- Health Tags position and settings
		self.HealthValue:SetPoint("CENTER", self, "CENTER", 0, 0)

		-- Power Tags position and settings
		self.PowerValue:SetPoint("CENTER", self.Power, "CENTER", 0, 0)

		-- Level & Name Tag
		self.NameText:SetPoint("BOTTOM",self,"TOP",0, 1)
		self.LevelText:SetPoint("RIGHT",self.NameText,"LEFT",-1,0)

		-- Castbar
		self.CastbarFrame:SetWidth(P_POWER_WIDTH)
		self.CastbarFrame:SetHeight(ICON_SIZE)
		self.CastbarFrame:SetPoint("TOPLEFT",self,"BOTTOMLEFT",0,-3)

		local SpellIcon = self.Castbar:CreateTexture(nil,"OVERLAY")
		SpellIcon:SetPoint("LEFT",self.CastbarFrame)
		SpellIcon:SetPoint("TOP",self.CastbarFrame)
		SpellIcon:SetPoint("BOTTOM",self.CastbarFrame)
		SpellIcon:SetWidth(ICON_SIZE)
		SpellIcon:SetTexCoord(.06,.94,.06,.94)

		local TimeText = self.Castbar:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalRight")
		TimeText:SetPoint("RIGHT", self.Castbar,-1,0)

		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalLeft")
		SpellText:SetPoint("LEFT",self.Castbar,1,0)

		self.Castbar:SetBackdrop(BACKDROP)
		self.Castbar:SetBackdropColor(0,0,0)
		self.Castbar:SetPoint("TOP",self.CastbarFrame)
		self.Castbar:SetPoint("RIGHT",self.CastbarFrame)
		self.Castbar:SetPoint("LEFT",SpellIcon,"RIGHT",1,0)

		-- Gotta think something better for this.
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


		-- TODO: Totems
		local Totems = {}
		for index = 1, MAX_TOTEMS do
			-- Position and size of the totem indicator
			local Totem = CreateFrame("BUTTON", nil, self)
			Totem:SetSize(25, 25)
			Totem:SetPoint("TOPLEFT", self, "BOTTOMLEFT", index * Totem:GetWidth(), 0)

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
		self:SetHeight(P_HEALTH_HEIGHT)
    self.HealthPrediction = {
        --myBar = myBar,
        --otherBar = otherBar,
        --healAbsorbBar = healAbsorbBar,
        --absorbBar = absorbBar,
        maxOverflow = 1.0,
        frequentUpdates = true
		}
		--self.HealthPrediction.PostUpdate = PostHealthPrediction
		--self.Buffs = Buffs
		self.Debuffs = Debuffs
		self.Castbar.Time = TimeText
		self.Castbar.Text = SpellText
		self.Castbar.Icon = SpellIcon
 end,

 target = function(self)
	  -- Unit
		self:SetWidth(P_HEALTH_WIDTH)
		self:SetHeight(P_HEALTH_HEIGHT)

		-- Health
		self.Health:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
		self.Health:SetPoint("RIGHT")
		self.Health:SetHeight(P_HEALTH_HEIGHT - S_POWER_HEIGHT + 1)

		--[[ Absorbs
		local absorbBar = CreateFrame("StatusBar", nil, self.Health)
   	absorbBar:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 0, 0)
		absorbBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
		absorbBar:SetStatusBarTexture(TEXTURE)
		absorbBar:SetBackdrop(BACKDROP)
		absorbBar:SetWidth(P_HEALTH_WIDTH)
		absorbBar:SetHeight(P_HEALTH_HEIGHT)]]

		-- Power
		self.Power:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0, 1)
		self.Power:SetPoint("RIGHT")
		self.Power:SetHeight(S_POWER_HEIGHT - 3)


		-- Buffs
		local Buffs = CreateFrame("Frame", nil, self)
		Buffs:SetWidth(P_HEALTH_WIDTH)
		Buffs:SetHeight(ICON_SIZE * 2)
		Buffs.size = ICON_SIZE
		Buffs.spacing = 2
		Buffs["growth-y"] = "DOWN"
		Buffs.initialAnchor = "TOPLEFT"
		Buffs:SetPoint("TOPRIGHT", self.CastbarFrame, "BOTTOMRIGHT", 0, -1)
		Buffs.PostCreateIcon = PostCreateAura

		-- Debuffs
		local Debuffs = CreateFrame("Frame",nil,self)
		Debuffs:SetWidth(P_HEALTH_WIDTH)
		Debuffs:SetHeight(ICON_SIZE * 2)
		Debuffs.size = ICON_SIZE
		Debuffs.spacing = 2
		Debuffs["growth-y"] = "UP"
		Debuffs:SetPoint("BOTTOM",self.NameText,"TOP",0,1)
		Debuffs.onlyShowPlayer = true
		Debuffs.PostCreateIcon = PostCreateAura

		-- Health Tags position and settings
		self.HealthValue:SetPoint("CENTER", self, "CENTER", 0, 0)
		--self.Health.textSeparator:SetPoint("RIGHT", self.HealthValue, "LEFT", 0, 1)
		self.HealthPer:SetPoint("RIGHT",self,"RIGHT",0,0)

		-- Power Tags position and settings
		--self.PowerValue:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 1)

		-- Level & Name Tag
		self.NameText:SetPoint("BOTTOM",self,"TOP",0, 1)
		self.LevelText:SetPoint("RIGHT",self.NameText,"LEFT",-1,0)

		-- Castbar
		self.CastbarFrame:SetWidth(P_HEALTH_WIDTH)
		self.CastbarFrame:SetHeight(P_HEALTH_HEIGHT)
		self.CastbarFrame:SetPoint("TOPLEFT",self,"BOTTOMLEFT",0,-1)

		local SpellIcon = self.Castbar:CreateTexture(nil,"OVERLAY")
		SpellIcon:SetPoint("RIGHT",self.CastbarFrame)
		SpellIcon:SetPoint("TOP",self.CastbarFrame)
		SpellIcon:SetPoint("BOTTOM",self.CastbarFrame)
		SpellIcon:SetWidth(P_HEALTH_HEIGHT)
		SpellIcon:SetTexCoord(.06,.94,.06,.94)

		local TimeText = self.Castbar:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalRight")
		TimeText:SetPoint("RIGHT", self.Castbar,-1,0)

		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalLeft")
		SpellText:SetPoint("LEFT",self.Castbar,1,0)

		self.Castbar:SetPoint("TOP",self.CastbarFrame)
		self.Castbar:SetPoint("RIGHT",SpellIcon,"LEFT")
		self.Castbar:SetPoint("LEFT",self.CastbarFrame)
		self.Castbar:SetWidth(P_HEALTH_WIDTH - P_HEALTH_HEIGHT - 1)

		-- Quest Icon
		local QuestIcon = self:CreateTexture(nil,"OVERLAY")
		QuestIcon:SetSize(16, 16)
		QuestIcon:SetPoint("CENTER", self, "BOTTOMRIGHT", 0 ,0)

		-- Register with oUF
		self:SetWidth(P_HEALTH_WIDTH)
		self:SetHeight(P_HEALTH_HEIGHT)
    self.HealthPrediction = {
        --myBar = myBar,
        --otherBar = otherBar,
        --healAbsorbBar = healAbsorbBar,
        --absorbBar = absorbBar,
        maxOverflow = 1.0,
        frequentUpdates = true
		}
		--self.HealthPrediction.PostUpdate = PostHealthPrediction
		self.Buffs = Buffs
		self.Debuffs = Debuffs
		self.Castbar.Time = TimeText
		self.Castbar.Text = SpellText
		self.Castbar.Icon = SpellIcon
		self.QuestIcon = QuestIcon
	end,

	targettarget = function(self)
	  -- Unit
		self:SetWidth(S_HEALTH_WIDTH)
		self:SetHeight(S_HEALTH_HEIGHT)

		-- Health
		self.Health:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
		self.Health:SetPoint("RIGHT")
		self.Health:SetHeight(P_HEALTH_HEIGHT - S_POWER_HEIGHT + 1)

		-- Power
		self.Power:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0, 1)
		self.Power:SetPoint("RIGHT")
		self.Power:SetHeight(S_POWER_HEIGHT - 3)

		-- Health Tags position and settings
		self.HealthValue:SetPoint("CENTER", self, "CENTER", 0, 0)
		--self.HealthPer:SetPoint("RIGHT",self.Health.textSeparator,"LEFT",0,-0)

		-- Power Tags position and settings
		--self.PowerValue:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 1)

		-- Level & Name Tag
		self.NameText:SetPoint("BOTTOM",self,"TOP",0, 1)
		self.LevelText:SetPoint("RIGHT",self.NameText,"LEFT",-1,0)

		--[[ Castbar
		self.CastbarFrame:SetSize(S_HEALTH_WIDTH ,15)
		self.CastbarFrame:SetPoint("BOTTOMLEFT",self.NameText,"TOPLEFT",0,1)
		self.Castbar:SetAllPoints(self.CastbarFrame)
		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalLeft")
		SpellText:SetPoint("LEFT",self.Castbar,1,0)]]

		--[[ Register with oUF
		self:SetWidth(S_HEALTH_WIDTH)
		self:SetHeight(P_HEALTH_HEIGHT + P_POWER_HEIGHT + 1)
		self.Castbar.Text = SpellText]]
	end,

	focus = function(self)
	  -- Unit
		self:SetWidth(S_HEALTH_WIDTH)
		self:SetHeight(S_HEALTH_HEIGHT)

		-- Health
		self.Health:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
		self.Health:SetPoint("RIGHT")
		self.Health:SetHeight(P_HEALTH_HEIGHT - S_POWER_HEIGHT + 1)

		-- Power
		self.Power:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0, 1)
		self.Power:SetPoint("RIGHT")
		self.Power:SetHeight(S_POWER_HEIGHT - 3)

		-- Health Tags position and settings
		self.HealthValue:SetPoint("CENTER", self, "CENTER", 0, 0)
		--self.HealthPer:SetPoint("RIGHT",self.Health.textSeparator,"LEFT",0,-0)

		-- Power Tags position and settings
		--self.PowerValue:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 1)

		-- Level & Name Tag
		self.NameText:SetPoint("BOTTOM",self,"TOP",0, 1)
		self.LevelText:SetPoint("RIGHT",self.NameText,"LEFT",-1,0)

		--[[ Castbar
		self.CastbarFrame:SetSize(S_HEALTH_WIDTH ,15)
		self.CastbarFrame:SetPoint("BOTTOMLEFT",self.NameText,"TOPLEFT",0,1)
		self.Castbar:SetAllPoints(self.CastbarFrame)
		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalLeft")
		SpellText:SetPoint("LEFT",self.Castbar,1,0)]]

		--[[ Register with oUF
		self:SetWidth(S_HEALTH_WIDTH)
		self:SetHeight(P_HEALTH_HEIGHT + P_POWER_HEIGHT + 1)
		self.Castbar.Text = SpellText]]
	end,

	party = function(self)
		local ReadyCheck = self:CreateTexture(nil,"OVERLAY")
		ReadyCheck:SetPoint("CENTER", self, "CENTER", 0, 0)
		ReadyCheck:SetSize(15,15)
		
		local RoleIcon = self.CreateTexture(nil, "OVERLAY")
		RoleIcon:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		RoleIcon:SetSize(10,10)
	end,
};

local function Shared(self, unit)
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	--create health statusbar func
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetStatusBarTexture(TEXTURE)
	Health:SetStatusBarColor(0.2, 0.2, 0.2)
	Health:SetBackdrop(BACKDROP)
	Health:SetBackdropColor(0, 0, 0)

	-- Health Options
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.colorClass = false
	Health.colorClassNPC = false
	Health.colorReaction = false
	Health.colorHealth = false

	-- Level Tag
	local LevelText = Health:CreateFontString(nil,"OVERLAY","DejaVuTextNormalLeft")
	LevelText:SetTextColor(1,1,1)
	self.LevelText = LevelText
	self:Tag(self.LevelText,"([difficulty][level][shortclassification]|r)")
	
	-- Name Tag
	local NameText = Health:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalLeft")
	NameText:SetTextColor(1, 1, 1)
	self.NameText = NameText
	self:Tag(self.NameText,"[name]")

	-- Health Tag
	local HealthValue = Health:CreateFontString(nil, "OVERLAY", "DejaVuTextNormalRight")
	HealthValue:SetTextColor(1, 1, 1)
	local HealthPer = Health:CreateFontString(nil,"OVERLAY","DejaVuTextNormalRight")
	HealthPer:SetTextColor(1,1,1)
	self.HealthValue = HealthValue
	self.HealthPer = HealthPer
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
	Castbar:SetBackdrop(BACKDROP)
	Castbar:SetBackdropColor(0, 0, 0)

	local CastbarFrame = CreateFrame("Frame",nil,self)
	--CastbarFrame:SetFrameStrata("BACKGROUND")
	--CastbarFrame:SetBackdrop(BACKDROP)
	--CastbarFrame:SetBackdropColor(0,0,0)

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
	oUF:Spawn("player"):SetPoint("CENTER",UIParent,-260,-230)
	oUF:Spawn("target"):SetPoint("CENTER",UIParent,260,-230)
	oUF:Spawn("targettarget"):SetPoint("CENTER",UIParent,500,-180)
	oUF:Spawn("focus"):SetPoint("CENTER",UIParent,-500,-180)
end)

