function GM:OnNPCKilled(e,a,i)
	if a:IsPlayer() then
		a:AddFrags(1)
	end
end

local zomt = {
	['npc_zombie_torso'] = true,
	['npc_zombie'] = true,
	['npc_fastzombie'] = true,
	['npc_zombine'] = true
}

function GM:EntityTakeDamage(t,d)
	if !Horror.__noheadcrabs then return end
	if !IsValid(t) or !zomt[t:GetClass()] then return end

	if d:GetDamage() >= t:Health() then
		if d:GetDamage() < t:GetMaxHealth() then
			d:SetDamage(t:GetMaxHealth()*2)
		end

		d:SetDamageType(DMG_SLASH)
	end
end