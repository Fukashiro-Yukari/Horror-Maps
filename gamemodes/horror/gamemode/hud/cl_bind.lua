local function SlotSort(a,b)
	return a and b and a:GetSlot() and b:GetSlot() and a:GetSlot() < b:GetSlot()
end

local function CopyVals(src,dest)
	table.Empty(dest)
	
	for k, v in pairs(src) do
		if IsValid(v) then
			table.insert(dest,v)
		end
	end
end

local lastinvWep = {}
function GM:PlayerSwitchWeapon(p,ow,nw)
	lastinvWep[1] = ow
	lastinvWep[2] = nw
end

Horror.WepsTable = {}
Horror.WepSlot = 1

local wepslotpos = 0
local onw = 1
local select = 'garrysmod/ui_hover.wav'
function GM:PlayerBindPress(p,b,pr)
	if !p:Alive() then return end
	
	local weps = p:GetWeapons()
	CopyVals(p:GetWeapons(),Horror.WepsTable)
	table.sort(Horror.WepsTable,SlotSort)
	
	if b == 'invprev' and pr then
		Horror.WepSlot = Horror.WepSlot-1
		
		if Horror.WepSlot<1 then
			Horror.WepSlot = #Horror.WepsTable
		end
		
		p:SetNWFloat('QTG_hr_wepsm',CurTime()+1)
		
		if !table.IsEmpty(Horror.WepsTable) and IsValid(Horror.WepsTable[Horror.WepSlot]) then
			input.SelectWeapon(Horror.WepsTable[Horror.WepSlot])
		end
		
		surface.PlaySound(select)

		return true
	end
	
	if b == 'invnext' and pr then
		Horror.WepSlot = Horror.WepSlot+1
		
		if Horror.WepSlot>#Horror.WepsTable then
			Horror.WepSlot = 1
		end
		
		p:SetNWFloat('QTG_hr_wepsm',CurTime()+1)
		
		if !table.IsEmpty(Horror.WepsTable) and IsValid(Horror.WepsTable[Horror.WepSlot]) then
			input.SelectWeapon(Horror.WepsTable[Horror.WepSlot])
		end
		
		surface.PlaySound(select)

		return true
	end
	
	if string.sub(b,1,4) == 'slot' and pr then
		local idx = tonumber(string.sub(b,5,-1)) or 1
		local slotposlist = {}
		
		p:SetNWFloat('QTG_hr_wepsm',CurTime()+1)
		
		for k,v in pairs(Horror.WepsTable) do
			local wepsslot = v:GetSlot()+1
			if wepsslot == idx then
				table.insert(slotposlist,v)
			end
		end
		
		wepslotpos = wepslotpos+1
		
		if wepslotpos>#slotposlist then
			wepslotpos = 1
		end
		
		for k,v in pairs(Horror.WepsTable) do
			local wepsslot = v:GetSlot()+1
			if wepsslot == idx then
				if v:GetClass() == slotposlist[wepslotpos]:GetClass() then
					Horror.WepSlot = k
				end
			end
		end
		
		if !table.IsEmpty(slotposlist) and IsValid(slotposlist[wepslotpos]) then
			input.SelectWeapon(slotposlist[wepslotpos])
		end
		
		surface.PlaySound(select)

		return true
	end
end