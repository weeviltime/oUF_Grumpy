--NumberFormat
local function NumberFormat(value)
	if(value >= 1e6) then
		return gsub(format('%.2fm', value / 1e6), '%.?0+([km])$', '%1')
	elseif(value >= 1e4) then
		return gsub(format('%.1fk', value / 1e3), '%.?0+([km])$', '%1')
	else
		return value
	end
end

oUF.Tags.Events["grumpy:shorthp"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION"
oUF.Tags.Events["grumpy:hpper"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION"
oUF.Tags.Events["grumpy:shortpp"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER"

oUF.Tags.Methods["grumpy:shorthp"] = function(unit)
	if(UnitIsDead(unit) or UnitIsGhost(unit)) then
		return "|cff999999Dead|r"
	end
	return NumberFormat(UnitHealth(unit))
end

oUF.Tags.Methods["grumpy:shortpp"] = function(unit)
	if(UnitIsDead(unit) or UnitIsGhost(unit)) then return end

	local cur = UnitPower(unit)
	if(cur > 0) then
		return NumberFormat(cur)
	end
end

oUF.Tags.Methods["grumpy:hpper"] = function(unit)
	if(UnitIsDead(unit) or UnitIsGhost(unit))  then
		return "|cff9999990%|r"
	end
	local hpMin, hpMax = UnitHealth(unit), UnitHealthMax(unit)
	local hpPer = 0
	if hpMax > 0 then hpPer = math.floor(hpMin/hpMax*100) end
	return NumberFormat(hpPer).."%"
end

