local function GetNextPlayer(p)
	local plys = {}

	for _, v in pairs(player.GetAll()) do
		if v:Alive() then
			table.insert(plys, v)
		end
	end

	local NextPly

	for k, v in pairs(plys) do
		if v == p then
			if IsValid(plys[k + 1]) then
				NextPly = plys[k + 1]
			else
				NextPly = plys[1]
			end
			
			return NextPly
		end
	end

	return plys[1]
end

local function GetPreviousPlayer(p)
	local plys = {}

	for _, v in pairs(player.GetAll()) do
		if v:Alive() then
			table.insert(plys, v)
		end
	end

	local PrevPly
	for k, v in pairs(plys) do
		if v == p then
			if IsValid(plys[k - 1]) then
				PrevPly = plys[k - 1]
			else
				PrevPly = plys[#plys]
			end
			
			return PrevPly
		end
	end

	return plys[#plys]
end

local sprint = Horror.GetConvar('sprint_durable')
local ondeath = Horror.GetConvar('ondeathdropweapon')

function GM:DoPlayerDeath(p,a,c)
	local Retime = Horror.GetConvar('ReSpawnTime'):GetInt()
	local weps = p:GetWeapons()

	for _,v in pairs(weps) do
		if ondeath:GetBool() and !Horror.IsAdminWep(v) then
			p:DropWeapon(v)
		end
	end

	p:CreateRagdoll()
	p:AddDeaths(1)

	if IsValid(a) and a:IsPlayer() then
		if a != p then
			a:AddFrags(1)
		end
	end

	p:SetNW2Float('QTG_Horror_ReSpawnTime',CurTime()+Retime)
	p:QTGAddNotify('You are death, please wait '..Retime..' seconds!',0,5,0)

	local alive = 0

	for k,v in pairs(player.GetAll()) do
		if v:Alive() then
			alive = alive+1
		end
	end

	if alive <= 0 then
		Horror:MissionFailed()
	end
end

local KeyPressFunc = {
	[IN_ATTACK] = function(p)
		local t = GetPreviousPlayer(p:GetObserverTarget())

		if IsValid(t) and t:IsPlayer() then
			p:Spectate(p._smode or OBS_MODE_CHASE)
			p:SpectateEntity(t)
			p:SetupHands(t)
		end
	end,
	[IN_ATTACK2] = function(p)
		local t = GetNextPlayer(p:GetObserverTarget())

		if IsValid(t) and t:IsPlayer() then
			p:Spectate(p._smode or OBS_MODE_CHASE)
			p:SpectateEntity(t)
			p:SetupHands(t)
		end
	end,
	[IN_RELOAD] = function(p)
		local t = p:GetObserverTarget()
		if !IsValid(t) or !t:IsPlayer() then return end

		if !p._smode or p._smode == OBS_MODE_CHASE then
			p._smode = OBS_MODE_IN_EYE
		elseif p._smode == OBS_MODE_IN_EYE then
			p._smode = OBS_MODE_CHASE
		end
		
		p:Spectate(p._smode)
		p:SetupHands(t)
	end,
	[IN_JUMP] = function(p)
		if p:GetMoveType() != MOVETYPE_NOCLIP then
			p:SetMoveType(MOVETYPE_NOCLIP)
		end
	end,
	[IN_DUCK] = function(p)
		p:Spectate(OBS_MODE_ROAMING)
		p:SpectateEntity(nil)
	end
}

function GM:KeyPress(p,k)
	if k == IN_USE then
		local t = util.TraceLine({
			start  = p:GetShootPos(),
			endpos = p:GetShootPos() + p:GetAimVector() * 80,
			filter = p,
			mask   = MASK_SHOT
		})
	end

	if !p:Alive() then
		if KeyPressFunc[k] then
			KeyPressFunc[k](p)
		end
	end
end