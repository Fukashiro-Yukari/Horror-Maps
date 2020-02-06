function GM:OnNPCKilled(e,a,i)
	if a:IsPlayer() then
		a:AddFrags(1)
	end
end