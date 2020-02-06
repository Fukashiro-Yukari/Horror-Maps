local keyf = {
	[KEY_G] = function(p,b)
		local w = p:GetActiveWeapon()

		if IsValid(w) then
            p:DropWeapon(w)
		end
	end
}

function GM:PlayerButtonDown(p,b)
	if !IsFirstTimePredicted() then return end
	if keyf[b] then
		keyf[b](p,b)
	end
end