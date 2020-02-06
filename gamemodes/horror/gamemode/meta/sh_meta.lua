local p = FindMetaTable('Player')
local e = FindMetaTable('Entity')
local c = FindMetaTable('CMoveData')

function c:RemoveKeys(k)
	local nb = bit.band(self:GetButtons(),bit.bnot(k))
	
	self:SetButtons(nb)
end

local cantruncom = {
	'kickall',
	'killserver',
	'sbox_godmode',
	'sv_noclipspeed'
}

local isw = {}

local old = engine.ActiveGamemode
function engine.ActiveGamemode()
	return 'sandbox'
end

local function ofunc(s)
	for k,v in pairs(cantruncom) do
		if string.find(s,v) then
			if !isw[v] then
				MsgC(Color(255,90,90),'[Horror Maps] Gamemode cannot use this console command! ('..s..')\n')

				isw[v] = true
			end

			return true
		end
	end
end

__oldRunConsoleCommand = __oldRunConsoleCommand or RunConsoleCommand
function RunConsoleCommand(a,...)
	if ofunc(a) then
		return
	end
	
	return __oldRunConsoleCommand(a,...)
end

local old = p.ConCommand

p.__oldConCommand = p.__oldConCommand or p.ConCommand

function p:ConCommand(a,...)
	if ofunc(a) then
		return
	end
	
	return self:__oldConCommand(a,...)
end

e.__oldRemove = e.__oldRemove or e.Remove

function e:Remove(...)
	if IsValid(self) and istable(Horror.__crewept) and Horror.__crewept[self:GetClass()] then
		return
	end

	return self:__oldRemove(...)
end

local RemoveAmmo = {
	['weapon_ar2'] = 30,
	['weapon_crossbow'] = 4,
	['weapon_frag'] = 1,
	['weapon_rpg'] = 3,
}

local RemoveAmmo2 = {
	['weapon_slam'] = 3
}

if SERVER then
	game.__oldConsoleCommand = game.__oldConsoleCommand or game.ConsoleCommand

	function game.ConsoleCommand(a,...)
		if ofunc(a) then
			return
		end
		
		return game.__oldConsoleCommand(a,...)
	end

	p.__oldDropWeapon = p.__oldDropWeapon or p.DropWeapon

	function p:DropWeapon(a,...)
		if !IsValid(self) then return end

		if IsValid(a) then
			if istable(Horror.__crewept) and Horror.__crewept[a:GetClass()] then
				return
			end
		else
			local w = p:GetActiveWeapon()

			if IsValid(w) and istable(Horror.__crewept) and Horror.__crewept[w:GetClass()] then
				return
			end
		end
		
		for k,v in pairs(RemoveAmmo) do
			if a:GetClass() == k then
				self:RemoveAmmo(v,a:GetPrimaryAmmoType())
			end
		end
		
		for k,v in pairs(RemoveAmmo2) do
			if a:GetClass() == k then
				self:RemoveAmmo(v,a:GetSecondaryAmmoType())
			end
		end
		
		return self:__oldDropWeapon(a,...)
	end

	p.__oldGive = p.__oldGive or p.Give

	function p:Give(a,b,c)
		if !IsValid(self) then return end
		
		self:SetNWInt('QTG_USWep',a)
		
		return self:__oldGive(a,b)
	end
	
	p.__oldStripWeapon = p.__oldStripWeapon or p.StripWeapon

	function p:StripWeapon(s,...)
		if istable(Horror.__crewept) and Horror.__crewept[s] then
			return
		end

		return self:__oldStripWeapon(s,...)
	end

	p.__oldStripWeapons = p.__oldStripWeapons or p.StripWeapons

	function p:StripWeapons(...)
		if istable(Horror.__crewept) and next(self:GetWeapons()) != nil then
			for k,v in pairs(self:GetWeapons()) do
				if !Horror.__crewept[v:GetClass()] then
					self:StripWeapon(v:GetClass())
				end
			end
		end

		-- return self:__oldStripWeapons(...)
	end

	NOTIFY_GENERIC	= 0
	NOTIFY_ERROR	= 1
	NOTIFY_UNDO		= 2
	NOTIFY_HINT		= 3
	NOTIFY_CLEANUP	= 4
end

local ntype = {
	[0] = 'ambient/water/drip'..math.random(1,4)..'.wav',
	[1] = 'buttons/button15.wav'
}

function p:QTGAddNotify(m,i,t,s)
	m = m or 'Notify'
	i = i or 0
	t = t or 5
	s = s or ''
	
	if ntype[s] then
		s = ntype[s]
	end
	
	if SERVER then
		self:SendLua('notification.AddLegacy(\''..m..'\','..i..',\''..t..'\') surface.PlaySound(\''..s..'\')')
	else
		notification.AddLegacy(m,i,t)
		surface.PlaySound(s)
	end
end