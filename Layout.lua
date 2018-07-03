local _, playerClass = UnitClass("player")

local TEXTURE = "Interface\\ChatFrame\\ChatFrameBackground"
local EDGE = {
	edgeFile = TEXTURE,
	edgeSize = -1
}
local BACKDROP = {
	bgFile = TEXTURE,
	insets = {
		left = -1, right = -1, top = -1, bottom = -1
	}
}

local ICON_SIZE = 20 

local config = {
	player = {
		width = 250,
		height = 40,
		power = 5,
		aura = {
			b = 20,
			d = 27
		}
	},
	target = {
		width = 250,
		height = 40,
		health = 35,
		power = 5,
		aura = {
			b = 20,
			d = 27
		}
	},
	targettarget = {
		width = 150,
		height = 30,
		health = 20,
		power = 10,
	},
	focus = {
		width = 150,
		height = 30,
		health = 20,
		power = 10,
		aura = {
			b = 20,
			d = 27
		}
	},
	boss = {
		width = 200,
		height = 40,
		power = 5
	}
}

local hasThirdBar = {
	MONK = true,
	SHAMAN = true,
	PRIEST = true,
	DRUID = true,
	WARRIOR = true
}

-- Functions
local function PostCreateAura(self, button)
	-- I have to thank P3lim, creator of oUF_P3lim
	-- and other Plugins, this part of code ensure that our strings
	-- stay above cooldown widget.
	local StringParent = CreateFrame("Frame", nil, button)
	StringParent:SetFrameLevel(20)

	local cd = button.cd:GetRegions()
	cd:ClearAllPoints()
	cd:SetParent(StringParent)
	cd:SetFontObject("AuraOutlineCenter")
	cd:SetTextColor(1, 1, 1, 1)
	cd:SetPoint("BOTTOM", button, "BOTTOM", 0, 2)

	local stack = button.count
	stack:ClearAllPoints()
	stack:SetParent(StringParent)
	stack:SetFontObject("AuraOutlineCenter")
	stack:SetTextColor(1, 1, 1, 1)
	stack:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)

	button.icon:SetTexCoord(.06, .94, .06, .94)
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
		self:SetWidth(config.player.width)
		self:SetHeight(config.player.height)

		-- Health
		self.Health:SetPoint("TOPLEFT")
		self.Health:SetPoint("BOTTOMRIGHT")

		--[[ Absorbs
		local absorbBar = CreateFrame("StatusBar", nil, self.Health)
		absorbBar:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 0, 0)
		absorbBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
		absorbBar:SetStatusBarTexture(TEXTURE)
		absorbBar:SetBackdrop(EDGE)
		absorbBar:SetWidth(config.player.width)
		absorbBar:SetHeight(config.player.height)]]

		-- Power
		self.Power:SetWidth(config.player.width)
		self.Power:SetHeight(config.player.power)
		self.Power:SetPoint("TOPLEFT", self, "TOPRIGHT", 10, 0)

		-- Additional Power
		if hasThirdBar[playerClass] then
			local AdditionalPower = CreateFrame("StatusBar", nil, self)
			AdditionalPower:SetWidth(config.player.width)
			AdditionalPower:SetHeight(config.player.power)
			AdditionalPower:SetPoint("TOP", self.Power, "BOTTOM", 0, -1)
			AdditionalPower:SetBackdrop(EDGE)
			AdditionalPower:SetStatusBarTexture(TEXTURE)
			AdditionalPower:SetBackdropColor(0, 0, 0)
			AdditionalPower:SetBackdropBorderColor(0, 0, 0)
			AdditionalPower:SetStatusBarColor(0, .75, .1)
			if(playerClass == "MONK") then
				self.Stagger = AdditionalPower
			elseif(playerClass == "SHAMAN" or playerClass == "PRIEST" or playerClass == "DRUID") then
				AdditionalPower.colorPower = true
				self.AdditionalPower = AdditionalPower
			elseif(playerClass == "WARRIOR") then
				-- Wanna do this Additional bar as Ignore Pain absorb.
				self.IgnorePain = AdditionalPower
				local PainValue = self.IgnorePain:CreateFontString(nil, "OVERLAY", "TextNormalCenter")
				PainValue:SetTextColor(1, 1, 1)
				self.PainValue = PainValue
				self:Tag(self.PainValue, "[ignorepain:cur]/[ignorepain:max]")
				self.PainValue:SetPoint("TOP", self.IgnorePain, 0, -1)
			end
		end

		--[[ Buffs
		local Buffs = CreateFrame("Frame", nil, self)
		Buffs:SetWidth(config.player.width)
		Buffs:SetHeight(ICON_SIZE * 2)
		Buffs.size = ICON_SIZE
		Buffs.spacing = 2
		Buffs:SetPoint("BOTTOMRIGHT", self.PowerValue, "TOPRIGHT", 0, 1)
		Buffs.PostCreateIcon = PostCreateAura]]

		-- Debuffs
		local Debuffs = CreateFrame("Frame", nil, self)
		Debuffs:SetWidth(config.player.width)
		Debuffs:SetHeight(config.player.aura.d * 2)
		Debuffs.size = config.player.aura.d
		Debuffs.spacing = 2
		Debuffs["growth-y"] = "UP"
		Debuffs.initialAnchor = "BOTTOMLEFT"
		Debuffs:SetPoint("BOTTOM", self, "TOP", 0, 1)
		Debuffs.PostCreateIcon = PostCreateAura

		-- Health Tags position and settings
		self.HealthText:SetPoint("RIGHT", self, "RIGHT", -1, 0)

		-- Power Tags position and settings
		self.PowerValue:SetPoint("BOTTOM", self.Power, "BOTTOM", 0, 1)

		-- Level & Name Tag
		self.NameText:SetPoint("LEFT", self, "LEFT", 1, 0)
		self.LevelText:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, 1)

		-- Castbar
		self.CastbarFrame:SetWidth(config.player.width)
		self.CastbarFrame:SetHeight(20)
		self.CastbarFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)

		local SpellIcon = self.Castbar:CreateTexture(nil, "OVERLAY")
		SpellIcon:SetPoint("TOPLEFT", self.CastbarFrame)
		SpellIcon:SetSize(20, 20)
		SpellIcon:SetTexCoord(.06, .94, .06, .94)

		local TimeText = self.Castbar:CreateFontString(nil, "OVERLAY", "TextNormalRight")
		TimeText:SetPoint("RIGHT", self.Castbar, -1, 0)

		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "TextNormalLeft")
		SpellText:SetPoint("LEFT", self.Castbar, 1, 0)

		self.Castbar:SetBackdrop(EDGE)
		self.Castbar:SetBackdropBorderColor(0, 0, 0)
		self.Castbar:SetPoint("TOPLEFT", SpellIcon, "TOPRIGHT", 1, 0)
		self.Castbar:SetPoint("BOTTOMRIGHT", self.CastbarFrame)

		-- Gotta think something better for this.
		if(playerClass == "ROGUE" or playerClass == "DRUID" or playerClass == "MONK") then
			local ClassPower = CreateFrame("Frame", nil, self)
			ClassPower:SetSize(245, config.player.power)
			ClassPower:SetPoint("TOP", self.Power, "BOTTOM", 0, -1)
			comboWidth = (245 / MAX_COMBO_POINTS) - 1
			for index = 1, 10 do
				ClassPower[index] = CreateFrame('StatusBar', nil, ClassPower)
				ClassPower[index]:SetSize(comboWidth, config.player.power)
				ClassPower[index]:SetStatusBarTexture(TEXTURE)
				ClassPower[index]:SetBackdrop(EDGE)
				ClassPower[index]:SetBackdropBorderColor(0, 0, 0)
				if index == 1 then
					ClassPower[index]:SetPoint("TOPLEFT", ClassPower)
				else
					ClassPower[index]:SetPoint("LEFT", ClassPower[index - 1], "RIGHT", 1, 0)
				end
			end
			self.ClassPower = ClassPower
		end

		-- Runes
		if(playerClass == "DEATHKNIGHT") then
			local Runes = CreateFrame("Frame", nil, self)
			Runes:SetSize(245, config.player.power)
			Runes:SetPoint("TOP", self.Power, "BOTTOM", 0, -1)
			comboWidth = (245 / 6) - 1
			for index = 1, 6 do
				-- Position & size
				Runes[index] = CreateFrame("StatusBar", nil, Runes)
				Runes[index]:SetSize(comboWidth, config.player.power)
				Runes[index]:SetStatusBarTexture(TEXTURE)
				Runes[index]:SetBackdrop(EDGE)
				Runes[index]:SetBackdropBorderColor(0, 0, 0)
				if index == 1 then
					Runes[index]:SetPoint("TOPRIGHT", Runes)
				else
					Runes[index]:SetPoint("RIGHT", Runes[index - 1], "LEFT", -1, 0)
				end
			end
			Runes.colorSpec = true
			self.Runes = Runes
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
		self:SetWidth(config.target.width)
		self:SetHeight(config.target.height)

		-- Health
		self.Health:SetPoint("TOPLEFT")
		self.Health:SetPoint("RIGHT")
		self.Health:SetHeight(config.target.height)

		--[[ Absorbs
		local absorbBar = CreateFrame("StatusBar", nil, self.Health)
		absorbBar:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 0, 0)
		absorbBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
		absorbBar:SetStatusBarTexture(TEXTURE)
		absorbBar:SetBackdrop(EDGE)
		absorbBar:SetWidth(config.player.width)
		absorbBar:SetHeight(config.player.height)]]

		-- Power
		self.Power:SetPoint("BOTTOMRIGHT")
		self.Power:SetFrameLevel(5)
		self.Power:SetWidth(config.target.width / 2)
		self.Power:SetHeight(config.target.power)
		self.Power:SetBackdrop(BACKDROP)
		self.Power:SetBackdropColor(0, 0, 0)


		-- Buffs
		local Buffs = CreateFrame("Frame", nil, self)
		Buffs:SetWidth(config.player.width)
		Buffs:SetHeight(config.target.aura.b * 2)
		Buffs.size = config.target.aura.b
		Buffs.spacing = 2
		Buffs["growth-y"] = "DOWN"
		Buffs.initialAnchor = "TOPLEFT"
		Buffs:SetPoint("TOPLEFT", self, "TOPRIGHT", 1, 0)
		Buffs.PostCreateIcon = PostCreateAura

		-- Debuffs
		local Debuffs = CreateFrame("Frame", nil, self)
		Debuffs:SetWidth(config.player.width)
		Debuffs:SetHeight(config.target.aura.d * 2)
		Debuffs.size = config.target.aura.d
		Debuffs.spacing = 2
		Debuffs["growth-y"] = "UP"
		Debuffs:SetPoint("BOTTOM", self, "TOP", 0, -1)
		Debuffs.onlyShowPlayer = true
		Debuffs.PostCreateIcon = PostCreateAura

		-- Health Tags position and settings
		self.HealthText:SetPoint("RIGHT", self, "RIGHT", -1, 0)
		self.HealthPerText:SetPoint("RIGHT", self.HealthText, "LEFT", -2, 0)

		-- Power Tags position and settings
		--self.PowerValue:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 1)

		-- Level & Name Tag
		self.NameText:SetPoint("LEFT", self, "LEFT", 1, 0)
		self.LevelText:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, 1)

		-- Castbar
		self.CastbarFrame:SetWidth(config.target.width)
		self.CastbarFrame:SetHeight(20)
		self.CastbarFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)

		local SpellIcon = self.Castbar:CreateTexture(nil, "OVERLAY")
		SpellIcon:SetPoint("TOPRIGHT", self.CastbarFrame)
		SpellIcon:SetSize(20, 20)
		SpellIcon:SetTexCoord(.06, .94, .06, .94)

		local TimeText = self.Castbar:CreateFontString(nil, "OVERLAY", "TextNormalRight")
		TimeText:SetPoint("RIGHT", self.Castbar, -1, 0)

		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "TextNormalLeft")
		SpellText:SetPoint("LEFT", self.Castbar, 1, 0)

		self.Castbar:SetBackdrop(EDGE)
		self.Castbar:SetBackdropBorderColor(0, 0, 0)
		self.Castbar:SetPoint("TOPRIGHT", SpellIcon, "TOPLEFT", -1, 0)
		self.Castbar:SetPoint("BOTTOMLEFT", self.CastbarFrame, 0, 0) 

		-- Quest Icon
		local QuestIcon = self:CreateTexture(nil, "OVERLAY")
		QuestIcon:SetSize(16, 16)
		QuestIcon:SetPoint("CENTER", self, "BOTTOMRIGHT", 0, 0)

		-- Register with oUF
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
		self:SetWidth(config.targettarget.width)
		self:SetHeight(config.targettarget.height)

		-- Health
		self.Health:SetPoint("TOPLEFT")
		self.Health:SetPoint("BOTTOMRIGHT")

		-- Debuffs
		local Debuffs = CreateFrame("Frame", nil, self)
		Debuffs:SetWidth(config.focus.width)
		Debuffs:SetHeight(config.focus.aura.d * 2)
		Debuffs.size = config.focus.aura.d
		Debuffs.spacing = 2
		Debuffs["growth-y"] = "UP"
		Debuffs:SetPoint("BOTTOM", self, "TOP", 0, -1)
		Debuffs.PostCreateIcon = PostCreateAura

		-- Health Tags position and settings
		--self.HealthText:SetPoint("CENTER", self, "CENTER", 0, 0)
		--self.HealthPerText:SetPoint("RIGHT", self.Health.textSeparator, "LEFT", 0, -0)

		-- Power Tags position and settings
		--self.PowerValue:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 1)

		-- Level & Name Tag
		self.NameText:SetPoint("CENTER", self, "CENTER", 0, 0)
		self.LevelText:SetPoint("RIGHT", self, "RIGHT", 0, 0)

		--[[ Castbar
		self.CastbarFrame:SetSize(config.targettarget.width, 15)
		self.CastbarFrame:SetPoint("BOTTOMLEFT", self.NameText, "TOPLEFT", 0, 1)
		self.Castbar:SetAllPoints(self.CastbarFrame)
		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		SpellText:SetPoint("LEFT", self.Castbar, 1, 0)]]

		-- Register with oUF
		self.Debuffs = Debuffs
	end,

	focus = function(self)
		-- Unit
		self:SetWidth(config.focus.width)
		self:SetHeight(config.focus.height)

		-- Health
		self.Health:SetPoint("TOPLEFT")
		self.Health:SetPoint("BOTTOMRIGHT")

		-- Debuffs
		local Debuffs = CreateFrame("Frame", nil, self)
		Debuffs:SetWidth(config.focus.width)
		Debuffs:SetHeight(config.focus.aura.d * 2)
		Debuffs.size = config.focus.aura.d
		Debuffs.spacing = 2
		Debuffs["growth-y"] = "UP"
		Debuffs:SetPoint("BOTTOM", self, "TOP", 0, -1)
		Debuffs.PostCreateIcon = PostCreateAura

		--[[ Power
		self.Power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		self.Power:SetPoint("RIGHT")
		self.Power:SetHeight(config.focus.power)]]

		-- Health Tags position and settings
		--self.HealthText:SetPoint("CENTER", self, "CENTER", 0, 0)
		--self.HealthPerText:SetPoint("RIGHT", self.Health.textSeparator, "LEFT", 0, -0)

		-- Power Tags position and settings
		--self.PowerValue:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 1)

		-- Level & Name Tag
		self.NameText:SetPoint("CENTER", self, "CENTER", 0, 0)
		self.LevelText:SetPoint("RIGHT", self, "RIGHT", 0, 0)

		--[[ Castbar
		self.CastbarFrame:SetSize(config.focus.width, 15)
		self.CastbarFrame:SetPoint("BOTTOMLEFT", self.NameText, "TOPLEFT", 0, 1)
		self.Castbar:SetAllPoints(self.CastbarFrame)
		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		SpellText:SetPoint("LEFT", self.Castbar, 1, 0)]]

		-- Register with oUF
		self.Debuffs = Debuffs
	end,

	pet = function(self)
		-- Unit
		self:SetWidth(config.focus.width)
		self:SetHeight(config.focus.height)

		-- Health
		self.Health:SetPoint("TOPLEFT")
		self.Health:SetPoint("BOTTOMRIGHT")

		-- Debuffs
		local Debuffs = CreateFrame("Frame", nil, self)
		Debuffs:SetWidth(config.focus.width)
		Debuffs:SetHeight(config.focus.aura.d * 2)
		Debuffs.size = config.focus.aura.d
		Debuffs.spacing = 2
		Debuffs["growth-y"] = "UP"
		Debuffs:SetPoint("BOTTOM", self, "TOP", 0, -1)
		Debuffs.PostCreateIcon = PostCreateAura

		--[[ Power
		self.Power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		self.Power:SetPoint("RIGHT")
		self.Power:SetHeight(config.focus.power)]]

		-- Health Tags position and settings
		--self.HealthText:SetPoint("CENTER", self, "CENTER", 0, 0)
		--self.HealthPerText:SetPoint("RIGHT", self.Health.textSeparator, "LEFT", 0, -0)

		-- Power Tags position and settings
		--self.PowerValue:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 1)

		-- Level & Name Tag
		self.NameText:SetPoint("CENTER", self, "CENTER", 0, 0)
		self.LevelText:SetPoint("RIGHT", self, "RIGHT", 0, 0)

		--[[ Castbar
		self.CastbarFrame:SetSize(config.focus.width, 15)
		self.CastbarFrame:SetPoint("BOTTOMLEFT", self.NameText, "TOPLEFT", 0, 1)
		self.Castbar:SetAllPoints(self.CastbarFrame)
		local SpellText = self.Castbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		SpellText:SetPoint("LEFT", self.Castbar, 1, 0)]]

		-- Register with oUF
		self.Debuffs = Debuffs
	end,

	party = function(self)
		local ReadyCheck = self:CreateTexture(nil, "OVERLAY")
		ReadyCheck:SetPoint("CENTER", self, "CENTER", 0, 0)
		ReadyCheck:SetSize(15, 15)
		
		local RoleIcon = self.CreateTexture(nil, "OVERLAY")
		RoleIcon:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		RoleIcon:SetSize(10, 10)
	end,

	boss = function(self)
		-- Unit
		self:SetWidth(config.boss.width)
		self:SetHeight(config.boss.height)

		-- Health
		self.Health:SetPoint("TOPLEFT")
		self.Health:SetPoint("BOTTOMRIGHT")

		-- Power
		self.Power:SetWidth(config.boss.width / 2)
		self.Power:SetHeight(config.boss.power)
		self.Power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)

		-- Name tag & Health
		self.NameText:SetPoint("LEFT", self, "LEFT", 1, 0)
		self.HealthText:SetPoint("RIGHT", self, "RIGHT", -1, 0)
	end
}

local function Shared(self, unit)
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:SetBackdrop(EDGE)
	self:SetBackdropBorderColor(0, 0, 0)

	--create health statusbar and reverse bg
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetStatusBarTexture(TEXTURE)
	Health:SetStatusBarColor(0.2, 0.2, 0.2)
	Health:SetAlpha(0.3)
	--[[local HealthBg = CreateFrame("StatusBar", nil, self)
	HealthBg:SetMinMaxValues(0, UnitHealthMax(unit))
	HealthBg:SetValue(UnitHealth(unit))
	HealthBg:SetPoint("RIGHT")
	HealthBg:SetPoint("TOP")
	HealthBg:SetPoint("BOTTOM")
	HealthBg:SetStatusBarTexture(TEXTURE)
	HealthBg:SetStatusBarColor(0, 0, 0)
	HealthBg:SetReverseFill(true)
	Health.PostUpdate = function(Health, unit, min, max)
		self.HealthBg:SetValue(max - Health:GetValue())
	end]]--

	-- Health Options
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.colorClass = true
	Health.colorClassNPC = false
	Health.colorReaction = false
	Health.colorHealth = false

	-- StringParent
	local StringParent = CreateFrame("Frame", "StringParent", self)
	StringParent:SetFrameStrata("LOW")
	StringParent:SetFrameLevel(5)

	-- Level Tag
	local LevelText = StringParent:CreateFontString(nil, "OVERLAY", "TextNormalLeft")
	LevelText:SetTextColor(1, 1, 1)
	self.LevelText = LevelText
	self:Tag(self.LevelText, "([difficulty][level][shortclassification]|r)")
	
	-- Name Tag
	local NameText = StringParent:CreateFontString(nil, "OVERLAY", "TextNormalCenter")
	NameText:SetTextColor(1, 1, 1, 1)
	self.NameText = NameText
	self:Tag(self.NameText, "[name]")

	-- Health Tag
	local HealthText = StringParent:CreateFontString(nil, "OVERLAY", "TextNormalCenter")
	HealthText:SetTextColor(1, 1, 1)
	local HealthPerText = StringParent:CreateFontString(nil, "OVERLAY", "TextNormalRight")
	HealthPerText:SetTextColor(1, 1, 1)
	self.HealthText = HealthText
	self.HealthPerText = HealthPerText
	self:Tag(self.HealthPerText, "[grumpy:hpper]")
	self:Tag(self.HealthText, "[grumpy:shorthp]")

	-- Power
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetStatusBarTexture(TEXTURE)
	Power:SetBackdrop(EDGE)
	Power:SetBackdropColor(0, 0, 0)
	Power:SetBackdropBorderColor(0, 0, 0)
	Power:SetStatusBarColor(1, 0, 1)

	-- Options
	Power.frequentUpdates = true
	Power.displayAltPower = false
	Power.colorTapping = true
	Power.colorDisconnected = true
	Power.colorPower = true
	Power.colorClass = false
	Power.colorReaction = false

	-- Power Tags
	local PowerValue = Power:CreateFontString(nil, "OVERLAY", "TextNormalCenter")
	PowerValue:SetTextColor(1, 1, 1)
	self.PowerValue = PowerValue
	self:Tag(self.PowerValue, "[grumpy:shortpp]")

	-- Castbar
	local Castbar = CreateFrame("StatusBar", nil, self)
	Castbar:SetFrameStrata("LOW")
	Castbar:SetStatusBarTexture(TEXTURE)
	Castbar:SetStatusBarColor(0.2, 0.2, 0.2, 1)
	Castbar:SetBackdrop(EDGE)
	Castbar:SetBackdropColor(0, 0, 0)

	local CastbarFrame = CreateFrame("Frame", nil, self)
	--CastbarFrame:SetFrameStrata("BACKGROUND")
	--CastbarFrame:SetBackdrop(EDGE)
	--CastbarFrame:SetBackdropColor(0, 0, 0)

	-- Registiring everything
	self.Health = Health
	self.HealthBg = HealthBg
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
	self:SetActiveStyle("Grumpy")

	--Spawn more OVERLORDS
	self:Spawn("player"):SetPoint("CENTER", UIParent, -260, -230)
	self:Spawn("pet"):SetPoint("TOPRIGHT", oUF_GrumpyPlayer, "BOTTOMLEFT", -1, -1)
	self:Spawn("target"):SetPoint("CENTER", UIParent, 260, -230)
	self:Spawn("targettarget"):SetPoint("CENTER", UIParent, 500, -180)
	self:Spawn("focus"):SetPoint("CENTER", UIParent, -500, -180)

	for i = 1, 5 do
		self:Spawn("boss"..i):SetPoint("BOTTOMRIGHT", UIParent, "CENTER", 0, (config.boss.height * i))
	end
end)

