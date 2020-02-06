local hookr = {
	['CanPlayerSuicide'] = true,
	['PlayerCanPickupWeapon'] = true,
	-- ['PlayerDeath'] = true,
	['KeyPress'] = true,
	['DrawDeathNotice'] = true,
	['PlayerDeathThink'] = true
}

local hookdr = {
	'QTG_',
	'SH_',
	'VJ_',
	'TFA',
	'ULib',
	'ULX',
	'QBSTUTTER_',
}

local function Ihook(a)
	for k,v in pairs(hookdr) do
		if a:StartWith(v) then
			return false
		end
	end

	return true
end

function GM:RemoveHook()
	for a,b in pairs(hook.GetTable()) do
		if hookr[a] then
			for c,d in pairs(table.GetKeys(b)) do
				if Ihook(d) then
					hook.Remove(a,d)
				end
			end
		end
	end
end

hook.Remove('PlayerCanPickupWeapon','VJ_PLAYER_CANPICKUPWEAPON')