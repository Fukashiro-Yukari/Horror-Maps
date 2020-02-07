function GM:Initialize()
	if GetConVar('sv_defaultdeployspeed'):GetInt() != 1 then
		game.ConsoleCommand('sv_defaultdeployspeed 1\n')
	end
end

local function ps(fr,to,fo)
	if !to:IsInWorld() and not fo then return false end -- No way we can do this one

	local yawForward = to:EyeAngles().yaw
	local directions = { -- Directions to try
		math.NormalizeAngle( yawForward - 180 ), -- Behind first
		math.NormalizeAngle( yawForward + 90 ), -- Right
		math.NormalizeAngle( yawForward - 90 ), -- Left
		yawForward,
	}

	local t = {}
	t.start = to:GetPos() + Vector(0,0,32) -- Move them up a bit so they can travel across the ground
	t.filter = {to,fr}

	local i = 1
	
	t.endpos = to:GetPos() + Angle(0,directions[i],0):Forward() * 47 -- (33 is player width, this is sqrt( 33^2 * 2 ))
	
	local tr = util.TraceEntity(t,fr)
	
	while tr.Hit do -- While it's hitting something, check other angles
		i = i + 1
		if i > #directions then	 -- No place found
			if fo then
				fr.ulx_prevpos = fr:GetPos()
				fr.ulx_prevang = fr:EyeAngles()
				return to:GetPos() + Angle(0,directions[1],0):Forward() * 47
			else
				return false
			end
		end

		t.endpos = to:GetPos() + Angle(0,directions[i],0):Forward() * 47

		tr = util.TraceEntity(t,fr)
	end

	fr.ulx_prevpos = fr:GetPos()
	fr.ulx_prevang = fr:EyeAngles()
	
	return tr.HitPos
end

local sprint = Horror.GetConvar('sprint_durable')
function GM:PlayerInitialSpawn(p)
	local rp = table.Random(player.GetAll())
	local np = ps(p,rp)
	p:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

	hook.Call('PlayerSpeed',GAMEMODE,p)
	
	p:SetNW2Float('QTG_hr_sprint_durable',sprint:GetFloat())
	
	if IsValid(rp) and rp:Alive() and rp != p and np then
		local na = (rp:GetPos() - np):Angle()
		p:SetPos(np)
		p:SetEyeAngles(na)
		p:SetLocalVelocity(Vector(0,0,0))
	end
end

function GM:PlayerSpawn(p)
	p:UnSpectate()
	p:SetCanZoom(false)
	p:AllowFlashlight(true)
	p:SetAvoidPlayers(false)
	
	local rp = table.Random(player.GetAll())
	local np = ps(p,rp)
	
	p:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	
	hook.Call('PlayerSetModel',GAMEMODE,p)
	hook.Call('PlayerSetColor',GAMEMODE,p)
	hook.Call('PlayerSpeed',GAMEMODE,p)

	p:SetNW2Float('QTG_hr_sprint_durable',sprint:GetFloat())
	p:SetupHands()

	Horror.StartNet('SetWepSlot','Send',p,1)
	
	timer.Simple(0.02,function()
		if !IsValid(p) then return end

		hook.Call('PlayerLoadout',GAMEMODE,p)

		if !IsValid(rp) or !rp:Alive() or rp == p or !np then return end

		local na = (rp:GetPos()-np):Angle()

		p:SetPos(np)
		p:SetEyeAngles(na)
		p:SetLocalVelocity(Vector(0,0,0))
	end)
end

local plyff = Horror.GetConvar('Player_ff')
function GM:PlayerShouldTakeDamage(p,a)
	if a:IsPlayer() and p != a then 
		return plyff:GetBool()
	end
	
	return true
end

local rnpcname
function GM:PlayerDeath(p,i,a)
	rnpcname = ''

	for i = 0,12 do
		rnpcname = rnpcname..string.char(math.random(70,100))
	end

	p:Flashlight(false)
	p:AllowFlashlight(false)
	
	if IsValid(a) and a:IsVehicle() and IsValid(a:GetDriver()) then
		a = a:GetDriver()
	end
	
	if !IsValid(i) and IsValid(a) then
		i = a
	end
	
	if IsValid(i) and i == a and (i:IsPlayer() or i:IsNPC()) then
		i = i:GetActiveWeapon()

		if !IsValid(i) then i = a end
	end
	
	if a == p then
		net.Start('PlayerKilledSelf')
			net.WriteEntity(p)
		net.Broadcast()

		MsgAll(a:Nick() .. ' suicided!\n')

		return
	end
	
	if a:IsPlayer() then
		net.Start('PlayerKilledByPlayer')
			net.WriteEntity(p)
			net.WriteString(i:GetClass())
			net.WriteEntity(a)
		net.Broadcast()

		MsgAll(a:Nick()..' killed '..p:Nick()..' using '..i:GetClass() ..'\n')

		return
	end
	
	local iclass = a:GetClass() == 'worldspawn' and i:GetClass() or 'qtg_horror_unknown'
	local attclass = a:GetClass() == 'worldspawn' and a:GetClass() or rnpcname
	
	net.Start('PlayerKilled')
		net.WriteEntity(p)
		net.WriteString(iclass)
		net.WriteString(attclass)
	net.Broadcast()
	
	MsgAll(p:Nick()..' was killed by '..attclass..'\n')
end

function GM:SetPlayerSpeed()
end

function GM:PlayerSpeed(p,n)
	if !n then
		n = 1

		p:SetNW2Float('qtg_hr_jump',1)
	end

	p:SetWalkSpeed(180*n)
	p:SetRunSpeed(320*n)
	p:SetJumpPower(200*n)
	p:SetCrouchedWalkSpeed(0.6)
	p:SetDuckSpeed(0.5+((1/n)-1))
	p:SetUnDuckSpeed(0.35+((1/n)-1))
	p:SetViewOffsetDucked(Vector(0,0,37))
end

function GM:PlayerDeathThink(p,e,a)
	if p:GetNW2Float('QTG_Horror_ReSpawnTime') < CurTime() and p:GetNW2String('qtg_hr_missionfailed') == '' then
		p:Spawn()

		return true
	end
	
	return false
end

local plymodels = {}
local function addmodel(m)
	plymodels[#plymodels+1] = m
end

Horror.AddPlayerModel = addmodel

addmodel('male03')
addmodel('male04')
addmodel('male05')
addmodel('male07')
addmodel('male06')
addmodel('male09')
addmodel('male01')
addmodel('male02')
addmodel('male08')
addmodel('female06')
addmodel('female01')
addmodel('female03')
addmodel('female05')
addmodel('female02')
addmodel('female04')
addmodel('refugee01')
addmodel('refugee02')
addmodel('refugee03')
addmodel('refugee04')

local rmb = Horror.GetConvar('randomplayermodel')
function GM:PlayerSetModel(p)
	local pm = p:GetInfo('cl_playermodel')
	
	if rmb:GetBool() or p:IsBot() then
		if !p.__hrrm then
			p.__hrrm = table.Random(plymodels)
		end

		pm = p.__hrrm
	end
	
	local modelname = player_manager.TranslatePlayerModel(pm)

	util.PrecacheModel(modelname)
	p:SetModel(modelname)
	
	local skin = p:GetInfoNum('cl_playerskin',0)

	p:SetSkin(skin)
	
	local groups = p:GetInfo('cl_playerbodygroups')

	if groups == nil then groups = '' end
	
	local groups = string.Explode(' ',groups)

	for k = 0,p:GetNumBodyGroups()-1 do
		p:SetBodygroup(k,tonumber(groups[k+1]) or 0)
	end
end

function GM:PlayerSetColor(p)
	local col = p:GetInfo('cl_playercolor')

	p:SetPlayerColor(Vector(col))
	
	local col = Vector(p:GetInfo('cl_weaponcolor'))

	if col:Length() == 0 then
		col = Vector(0.001,0.001,0.001)
	end
	
	p:SetWeaponColor(col)
end

function GM:PlayerSetHandsModel(p,e)
	local pm = p:GetInfo('cl_playermodel')

	if rmb:GetBool() or p:IsBot() then
		if !p.__hrrm then
			p.__hrrm = table.Random(plymodels)
		end

		pm = p.__hrrm
	end
	
	local info = player_manager.TranslatePlayerHands(pm)

	if info then
		e:SetModel(info.model)
		e:SetSkin(info.skin)
		e:SetBodyGroups(info.body)
	end
end

local GiveWeapon = {
	{},
	{},
	{},
	{},
	{}
}

function GM:PlayerLoadout(p)
	p:RemoveAllAmmo()

	if !table.IsEmpty(GiveWeapon[1]) then
		p:Give(table.Random(GiveWeapon[1]),false,true)
	end

	if !table.IsEmpty(GiveWeapon[2]) then
		p:Give(table.Random(GiveWeapon[2]),false,true)
	end

	if !table.IsEmpty(GiveWeapon[3]) then
		p:Give(table.Random(GiveWeapon[3]),false,true)
	end

	if !table.IsEmpty(GiveWeapon[4]) then
		p:Give(table.Random(GiveWeapon[4]),false,true)
	end

	if !table.IsEmpty(GiveWeapon[5]) then
		p:Give(table.Random(GiveWeapon[5]),false,true)
	end
end

function Horror.AddPlayerLoadout(a,b)
	GiveWeapon[a][#GiveWeapon[a]+1] = b
end

function GM:GetFallDamage(p,s)
	if p:GetNWBool('QTG_HorrorDamageMiss') then
		return 0
	end
	
	return s/20
end

local adminwep = {
	['weapon_physgun'] = true,
}

local superadminwep = {}

function Horror.AddAdminWep(s,b)
	if b then
		superadminwep[s] = true

		return
	end

	adminwep[s] = true
end

function Horror.GetAdminWep()
	local t = {}

	t.adminwep = table.Copy(adminwep)
	t.superadminwep = table.Copy(superadminwep)

	return t
end

function Horror.IsAdminWep(s)
	local e

	if IsValid(s) then
		e = s
		s = s:GetClass()
	end

	if adminwep[s] then
		return true
	end

	if superadminwep[s] then
		return true
	end

	local w

	if !IsValid(e) then
		w = weapons.GetStored(s)
	else
		w = e
	end

	if (istable(w) or IsValid(w)) and w.AdminOnly then
		return true
	end

	return false
end

function GM:PlayerCanPickupWeapon(p,w)
	if !p:IsAdmin() and adminwep[w:GetClass()] then
		return false
	end

	if !p:IsSuperAdmin() and superadminwep[w:GetClass()] then
		return false
	end

	local weps = p:GetWeapons()
	
	for _,v in pairs(weps) do
		if w:GetPrimaryAmmoType() != -1 and p:GetAmmoCount(w:GetPrimaryAmmoType()) < 9999 then
			if w:Clip1() > 0 and v:GetPrimaryAmmoType() == w:GetPrimaryAmmoType() then
				p:GiveAmmo(w:Clip1(),w:GetPrimaryAmmoType())
				w:SetClip1(0)
			end
			
			-- if w:Clip1() < 0 and v:GetPrimaryAmmoType() == w:GetPrimaryAmmoType() then
			-- 	p:GiveAmmo(1,w:GetPrimaryAmmoType())
			-- 	w:Remove()
			-- end
		end
	end
	
	if p:HasWeapon(w:GetClass()) and p:GetNWInt('QTG_USWep') != w:GetClass() then return false end
	if p:GetNWInt('QTG_USWep') != w:GetClass() and !p:GetNW2Bool('qtg_hr_forcegivewep') then return false end
	p:SetNW2Bool('qtg_hr_forcegivewep',false)
	p:SetNWInt('QTG_USWep','')

	timer.Simple(0,function()
		if !IsValid(p) then return end

		p:SetNW2Bool('qtg_hr_forcegivewep',false)
		p:SetNWInt('QTG_USWep','')
	end)
	
	local slot = w:GetSlot()
	if slot >= 0 and slot <= 4 then
		for _,v in pairs(weps) do
			if v:GetSlot() == slot then
				p:DropWeapon(v)
			end
		end
	end

	timer.Simple(0,function()
		if !IsValid(w) or !IsValid(p) then return end

		p:SelectWeapon(w:GetClass())
	end)

	Horror.StartNet('SetWepSlot','Send',p,slot+1)
	
	return true
end

function GM:CanPlayerSuicide(p)
	return p:Alive()
end

function GM:PlayerSpray(p)
	return !p:Alive()
end

local rmwep = {
	['weapon_frag'] = true
}

function GM:PlayerThink(p)
	local weps = p:GetWeapons()
	
	for _,v in pairs(weps) do
		if IsValid(v) and v:Clip1() <= 0 and (v:GetPrimaryAmmoType() != -1 and p:GetAmmoCount(v:GetPrimaryAmmoType()) <= 0) and rmwep[v:GetClass()] then
			v:Remove()
		end
	end
end

function GM:PlayerUse(p,e)
	if p:GetNWFloat('QTG_USWepTime') < CurTime() and e:IsWeapon() then
		p:SetNWInt('QTG_USWep',e:GetClass())
		p:SetNWFloat('QTG_USWepTime',CurTime()+0.5)
	end
	
	return p:Alive()
end

function Horror.SetPlayerModel(p)
	local cl_playermodel = p:GetInfo('cl_playermodel')
	local modelname = player_manager.TranslatePlayerModel(cl_playermodel)

	util.PrecacheModel(modelname)
	p:SetModel(modelname)

	local skin = p:GetInfoNum('cl_playerskin',0)
	p:SetSkin(skin)

	local groups = p:GetInfo('cl_playerbodygroups')
	if groups == nil then groups = '' end

	local groups = string.Explode(' ',groups)
	for k = 0,p:GetNumBodyGroups()-1 do
		p:SetBodygroup(k,tonumber(groups[k+1]) or 0)
	end
end

function Horror.SetPlayerColor(p)
	local col = p:GetInfo('cl_playercolor')
	p:SetPlayerColor(Vector(col))

	local col = Vector(p:GetInfo('cl_weaponcolor'))
	if col:Length() == 0 then
		col = Vector(0.001,0.001,0.001)
	end

	p:SetWeaponColor(col)
end

function Horror.SetPlayerHandsModel(p)
	local cl_playermodel = p:GetInfo('cl_playermodel')
	local info = player_manager.TranslatePlayerHands(cl_playermodel)
	local hand = p:GetHands()

	if !IsValid(hand) then
		hand = ents.Create('gmod_hands')
		hand:SetPos(p:GetPos())
		hand:SetOwner(p)
		hand:Spawn()

		p:SetHands(hand)
	end

	if info then
		hand:SetModel(info.model)
		hand:SetSkin(info.skin)
		hand:SetBodyGroups(info.body)
	end
end