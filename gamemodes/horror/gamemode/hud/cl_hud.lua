local hide = {
	'CHudHealth',
	'CHudBattery',
	'CHudAmmo',
	'CHudSecondaryAmmo',
	'CHudCrosshair',
	-- 'CHudWeaponSelection'
}

function GM:HUDShouldDraw(name)
	if table.HasValue(hide,name) then return false end
	
	return true
end

local function iammo(a)
	if a != nil then
		return a
	end

	return -1
end

local function ciammo(a)
	if isnumber(a) then
		return string.format('%.0f',a)
	elseif a != nil then
		return a
	end

	return -1
end

local function iammot(w,a,b)
	if !w:IsScripted() then return iammo(a) end

	local clipsize1,clipsize2 = w.Primary.ClipSize,w.Secondary.ClipSize
	if b then
		a = iammo(a)>clipsize2 and (iammo(a)-1)..' + '..iammo(a)-clipsize2 or iammo(a)
	else
		a = iammo(a)>clipsize1 and (iammo(a)-1)..' + '..iammo(a)-clipsize1 or iammo(a)
	end

	return a
end

local Hl2WepList = {
	['weapon_smg1'] = 'a',
	['weapon_shotgun'] = 'b',
	['weapon_crowbar'] = 'c',
	['weapon_pistol'] = 'd',
	['weapon_357'] = 'e',
	['weapon_crossbow'] = 'g',
	['weapon_physgun'] = 'h',
	['weapon_rpg'] = 'i',
	['weapon_ar2'] = 'l',
	['weapon_frag'] = 'k',
	['weapon_bugbait'] = 'j',
	['weapon_physcannon'] = 'm',
	['weapon_alyxgun'] = 'd',
	['weapon_annabelle'] = 'b',
	['weapon_stunstick'] = 'n',
	['weapon_slam'] = 'o'
}

local Hl1WepList = {
}

local function SWepIcon(a)
	if Hl2WepList[a] then
		return Hl2WepList[a]
	end

	return ''
end

local animt = {}
local function animnum(a,b,c)
	if !c then c = 5 end

	animt[a] = Lerp(math.Clamp(FrameTime()*c,0,1),animt[a] or b,b)

	return animt[a]
end

local hp
local hpy 
local hpy2
local hpy3
local ar
local ary
local ary2
local ary3
local wepsm = 0
local sp
local sp2
local sprint = Horror.GetConvar('sprint_durable')

local function drawtext(s,f,x,y,c,t,t2)
	draw.SimpleText(s,f,x+2,y+2,Color(0,0,0,c.a-55),t,t2)
	draw.SimpleText(s,f,x,y,c,t,t2)
end

function GM:HUDPaint()
	hook.Run('HUDDrawTargetID')
	hook.Run('HUDDrawPickupHistory')
	hook.Run('DrawDeathNotice',0.85,0.04)
	
	local p = LocalPlayer()
	local w = p:GetActiveWeapon()
	local t = p:GetObserverTarget()
	local pos = {x=ScrW()/2+300,y=ScrH()/2+300}
	local drawply = p:ShouldDrawLocalPlayer()
	local retime = p:GetNW2Float('QTG_Horror_ReSpawnTime')-CurTime()
	
	if drawply then
		local att = p:GetAttachment(1)
		if att then
			pos = att.Pos:ToScreen()
		end
	else
		local vm = p:GetViewModel()
		if IsValid(vm) then
			local att = vm:GetAttachment(1)
			if att then
				pos = att.Pos:ToScreen()
			end
		end
	end

	pos.x = math.min(pos.x,ScrW()-100)
	pos.y = math.min(pos.y,ScrH()-100)

	if !LocalPlayer():Alive() and LocalPlayer():GetNW2String('qtg_hr_missionfailed') == '' then
		local x,h = 100,100
		local y2 = ScrH()-h/1.1
		local text,text2 = 'You are dead','Respawn Time '..string.ToMinutesSeconds(retime)
		local text3,text4 = 'Left button: Watch the next player','Right button: Watch the previous player'
		local text5 = 'Space key: Switch viewing mode'

		if retime < 1 then
			text2 = 'Ready for respawn'
		end

		surface.SetDrawColor(0,0,0,200)
		surface.DrawRect(0,0,ScrW(),h)
		surface.DrawRect(0,ScrH()-h,ScrW(),h)

		drawtext(text,'QTG_hr_Ammo1',x,h/4,Color(255,0,0,200),TEXT_ALIGN_LEFT)

		drawtext(text2,'QTG_hr_Ammo1',(ScrW()-x),h/4,Color(255,255,255,200),TEXT_ALIGN_RIGHT)

		drawtext(text3,'QTG_hr_HpArN',x,y2,Color(255,255,255,200),TEXT_ALIGN_LEFT)

		y2 = y2+18

		drawtext(text4,'QTG_hr_HpArN',x,y2,Color(255,255,255,200),TEXT_ALIGN_LEFT)

		y2 = y2+18

		drawtext(text5,'QTG_hr_HpArN',x,y2,Color(255,255,255,200),TEXT_ALIGN_LEFT)
	end

	if LocalPlayer():GetNW2String('qtg_hr_missionfailed') != '' then
		surface.SetDrawColor(0,0,0,200)
		surface.DrawRect(0,ScrH()/2-100,ScrW(),200)

		drawtext('Mission Failed','QTG_hr_MissionFailed',ScrW()/2,ScrH()/2-15,Color(255,50,50,200),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		drawtext(LocalPlayer():GetNW2String('qtg_hr_missionfailed'),'QTG_hr_MissionFailed2',ScrW()/2,ScrH()/2+65,Color(255,255,255,200),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	
	if IsValid(t) and t:IsPlayer() then
		p = t
		surface.SetFont('QTG_hr_SpectateName')
		local n = t:Name()
		local x = surface.GetTextSize(n)
		surface.SetTextPos(ScrW()/2-x/2,ScrH()-75)
		surface.SetTextColor(250,250,250)
		surface.DrawText(n)
	end
	
	hp = p:Alive() and p:Health() or 0
	hpy = hp<100 and 100-hp or 0
	hpy2 = hp<200 and 200-hp or 0
	hpy3 = hp<300 and 300-hp or 0
	ar = p:Alive() and p:Armor() or 0
	ary = ar<100 and 100-ar or 0
	ary2 = ar<200 and 200-ar or 0
	ary3 = ar<300 and 300-ar or 0
	sp = p:GetNW2Float('QTG_hr_sprint_durable')/sprint:GetFloat()*100
	sp2 = (1-p:GetNW2Float('QTG_hr_sprint_durable')/sprint:GetFloat())*100
	
	if IsValid(t) and t:IsPlayer() then
		if hp > 0 then
			draw.SimpleText(hp,'QTG_hr_HpArN',41.5,ScrH()-180,Color(0,0,0,200),TEXT_ALIGN_CENTER)
			draw.SimpleText(hp,'QTG_hr_HpArN',40.5,ScrH()-181,Color(255,0,0,200),TEXT_ALIGN_CENTER)
		end

		if ar > 0 then
			draw.SimpleText(ar,'QTG_hr_HpArN',71.5,ScrH()-180,Color(0,0,0,200),TEXT_ALIGN_CENTER)
			draw.SimpleText(ar,'QTG_hr_HpArN',70.5,ScrH()-181,Color(0,50,255,200),TEXT_ALIGN_CENTER)
		end
	end
	
	if !p:Alive() then return end

	local x,y = 30,ScrH()-152
	
	surface.SetDrawColor(255,255,255,30)
	surface.DrawRect(x,y,22,102)
	
	surface.SetDrawColor(255,0,0,200)
	surface.DrawRect(x+1,animnum('hpy',y+1+hpy),20,animnum('hp',hp < 100 and hp or 100))
	
	if hp > 100 then
		surface.SetDrawColor(255,0,0,200)
		surface.DrawRect(x+1,animnum('hpy2',y+1+hpy2),20,animnum('hp2',hp < 200 and hp-100 or 100))
	end

	if hp > 200 then
		surface.SetDrawColor(255,0,0,200)
		surface.DrawRect(x+1,animnum('hpy3',y+1+hpy3),20,animnum('hp3',hp < 300 and hp-200 or 100))
	end
	
	draw.SimpleText('+','QTG_hr_HpAr',x+11.5,ScrH()-60,Color(0,0,0,200),TEXT_ALIGN_CENTER)
	draw.SimpleText('+','QTG_hr_HpAr',x+10.5,ScrH()-61,Color(255,0,0,100),TEXT_ALIGN_CENTER)
	
	if ar > 0 then
		x = x+30

		surface.SetDrawColor(255,255,255,30)
		surface.DrawRect(x,y,22,102)
		
		surface.SetDrawColor(0,50,255,200)
		surface.DrawRect(x+1,animnum('ary',y+1+ary),20,animnum('ar',ar < 100 and ar or 100))
		
		if ar > 100 then
			surface.SetDrawColor(0,50,255,200)
			surface.DrawRect(x+1,animnum('ary2',y+1+ary2),20,animnum('ar2',ar < 200 and ar-100 or 100))
		end

		if ar > 200 then
			surface.SetDrawColor(0,25,255,200)
			surface.DrawRect(x+1,animnum('ary3',y+1+ary3),20,animnum('ar3',ar < 300 and ar-200 or 100))
		end
		
		draw.SimpleText('*','QTG_hr_HpAr',x+11.5,ScrH()-60,Color(0,0,0,200),TEXT_ALIGN_CENTER)
		draw.SimpleText('*','QTG_hr_HpAr',x+10.5,ScrH()-61,Color(0,50,255,100),TEXT_ALIGN_CENTER)
	end
	
	if p:GetNW2Float('QTG_hr_sprint_durable') < sprint:GetFloat() then
		x = x+30

		surface.SetDrawColor(255,255,255,30)
		surface.DrawRect(x,y,22,102)
		
		surface.SetDrawColor(200,200,0,200)
		surface.DrawRect(x+1,animnum('spy',y+1+sp2),20,animnum('sp',sp))
		
		draw.SimpleText('D','QTG_hr_HpAr',x+11.5,ScrH()-60,Color(0,0,0,200),TEXT_ALIGN_CENTER)
		draw.SimpleText('D','QTG_hr_HpAr',x+10.5,ScrH()-61,Color(200,200,0,100),TEXT_ALIGN_CENTER)
	end

	-- draw.SimpleText('a','QTG_hr_hudicon',x+50,ScrH()-60,Color(0,0,0,200),TEXT_ALIGN_CENTER)
	
	local t = p:GetEyeTrace()
	if p:GetPos():Distance(t.HitPos) < 50 and t.Entity:IsWeapon() and LocalPlayer():Alive() then
		halo.Add({t.Entity},Color(0,150,255),3,3)

		local weps = p:GetWeapons()

		surface.SetDrawColor(0,0,0,200)
		surface.DrawRect(ScrW()/2-200,ScrH()/2+50,400,100)

		local bool = false

		for k,v in pairs(weps) do
			if v:GetSlot() == t.Entity:GetSlot() and t.Entity:GetSlot()<=4 then
				if t.Entity:IsScripted() and !v:IsScripted() then
					t.Entity:DrawWeaponSelection(ScrW()/2,ScrH()/2+50,200,50,255)
					draw.SimpleText(SWepIcon(v:GetClass())..'  >       ','QTG_hr_HL2SelectIcons2',ScrW()/2,ScrH()/2+50,Color(255,255,255,255),TEXT_ALIGN_CENTER)

					bool = true
				elseif !t.Entity:IsScripted() and v:IsScripted() then
					v:DrawWeaponSelection(ScrW()/2-200,ScrH()/2+50,200,50,255)
					draw.SimpleText('       >  '..SWepIcon(t.Entity:GetClass()),'QTG_hr_HL2SelectIcons2',ScrW()/2,ScrH()/2+50,Color(255,255,255,255),TEXT_ALIGN_CENTER)

					bool = true
				elseif t.Entity:IsScripted() and v:IsScripted() then
					v:DrawWeaponSelection(ScrW()/2-200,ScrH()/2+50,200,50,255)
					t.Entity:DrawWeaponSelection(ScrW()/2,ScrH()/2+50,200,50,255)
					draw.SimpleText('  >  ','QTG_hr_HL2SelectIcons2',ScrW()/2,ScrH()/2+50,Color(255,255,255,255),TEXT_ALIGN_CENTER)

					bool = true
				else
					draw.SimpleText(SWepIcon(v:GetClass())..'  >  '..SWepIcon(t.Entity:GetClass()),'QTG_hr_HL2SelectIcons2',ScrW()/2,ScrH()/2+50,Color(255,255,255,255),TEXT_ALIGN_CENTER)

					bool = true
				end
			end
		end

		if !bool then
			draw.SimpleText('Press '..string.upper(input.LookupBinding('+use') or 'e')..' key to pick up','QTG_hr_Ammo1',ScrW()/2,ScrH()/2+75,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		end
	end
	
	wepsm = math.Approach(wepsm or 0,p:GetNWFloat('QTG_hr_wepsm')>CurTime() and 1 or 0,FrameTime()*5)
	surface.SetDrawColor(0,10,80,200*wepsm)
	surface.DrawRect(ScrW()/2-125,100,250,200)
	surface.SetDrawColor(0,0,0,200*wepsm)
	surface.DrawRect(ScrW()/2-350,80,200,150)
	surface.DrawRect(ScrW()/2+150,80,200,150)

	for k,v in pairs(Horror.WepsTable) do
		local wepsslot = (!table.IsEmpty(Horror.WepsTable) and IsValid(v)) and v:GetSlot()+1 or 1
		if wepsm != 0 and IsValid(v) then
			if v == Horror.WepsTable[Horror.WepSlot] then
				if v:IsScripted() then
					v:DrawWeaponSelection(ScrW()/2-125,100,250,200,255*wepsm)
				else
					draw.SimpleText(SWepIcon(v:GetClass()),'QTG_hr_HL2SelectIcons',ScrW()/2,125,Color(255,255,255,255*wepsm),TEXT_ALIGN_CENTER)
				end

				draw.SimpleText(v:GetPrintName(),'QTG_hr_Ammo3',ScrW()/2,270,Color(255,255,255,255*wepsm),TEXT_ALIGN_CENTER)
				draw.SimpleText(wepsslot,'QTG_hr_Ammo3',ScrW()/2-115,105,Color(255,255,255,255*wepsm),TEXT_ALIGN_LEFT)
			end

			if v == Horror.WepsTable[Horror.WepSlot-1] or (Horror.WepSlot == 1 and v == Horror.WepsTable[#Horror.WepsTable]) then
				if v:IsScripted() then
					v:DrawWeaponSelection(ScrW()/2-350,80,200,150,255*wepsm)
				else
					draw.SimpleText(SWepIcon(v:GetClass()),'QTG_hr_HL2SelectIcons2',ScrW()/2-250,100,Color(255,255,255,255*wepsm),TEXT_ALIGN_CENTER)
				end

				draw.SimpleText(v:GetPrintName(),'QTG_hr_Ammo3',ScrW()/2-250,200,Color(255,255,255,255*wepsm),TEXT_ALIGN_CENTER)
				draw.SimpleText(wepsslot,'QTG_hr_Ammo3',ScrW()/2-345,85,Color(255,255,255,255*wepsm),TEXT_ALIGN_LEFT)
			end

			if v == Horror.WepsTable[Horror.WepSlot+1] or (Horror.WepSlot == #Horror.WepsTable and v == Horror.WepsTable[1]) then
				if v:IsScripted() then
					v:DrawWeaponSelection(ScrW()/2+150,80,200,150,255*wepsm)
				else
					draw.SimpleText(SWepIcon(v:GetClass()),'QTG_hr_HL2SelectIcons2',ScrW()/2+250,100,Color(255,255,255,255*wepsm),TEXT_ALIGN_CENTER)
				end

				draw.SimpleText(v:GetPrintName(),'QTG_hr_Ammo3',ScrW()/2+250,200,Color(255,255,255,255*wepsm),TEXT_ALIGN_CENTER)
				draw.SimpleText(wepsslot,'QTG_hr_Ammo3',ScrW()/2+155,85,Color(255,255,255,255*wepsm),TEXT_ALIGN_LEFT)
			end
		end
	end
	
	if p:Alive() and (IsValid(w) and w.DrawCrosshair and (w.DoDrawCrosshair and !w:DoDrawCrosshair(ScrW()/2,ScrH()/2) or !w.DoDrawCrosshair)) or (IsValid(w) and !w:IsScripted()) then
		local pos = {x = ScrW()/2,y = ScrH()/2}
		local pos2 = p:GetEyeTrace().HitPos:ToScreen()
		local drawply = p:ShouldDrawLocalPlayer()
		local vm = p:GetViewModel()

		if p:GetActiveWeapon().CW_VM then vm = p:GetActiveWeapon().CW_VM end
		if (vm:GetSequenceActivity(vm:GetSequence()) == ACT_VM_RELOAD or string.match(vm:GetSequenceName(vm:GetSequence()), 'reload') != nil) then
			local anim_perc = math.ceil(vm:GetCycle() * 100)
			h_crosshair = math.Approach(h_crosshair or 0,anim_perc<100 and 0 or 1,FrameTime()*5)
		else
			h_crosshair = math.Approach(h_crosshair or 0,1,FrameTime()*5)
		end

		local c_alpha = 255*h_crosshair
		if drawply then
			pos = p:GetEyeTrace().HitPos:ToScreen()
		end

		if h_crosshair > 0 or drawply then
			draw.RoundedBox(0,pos.x-25,pos.y-2,12,3,Color(0,0,0,c_alpha-55))
			draw.RoundedBox(0,pos.x+12,pos.y-2,12,3,Color(0,0,0,c_alpha-55))
			-- draw.RoundedBox(0,pos.x-2,pos.y-25,3,12,Color(0,0,0,c_alpha-55))
			draw.RoundedBox(0,pos.x-2,pos.y+12,3,12,Color(0,0,0,c_alpha-55))
			
			draw.RoundedBox(0,pos.x-24,pos.y-1,12,1,Color(255,0,0,c_alpha))
			draw.RoundedBox(0,pos.x+11,pos.y-1,12,1,Color(255,0,0,c_alpha))
			-- draw.RoundedBox(0,pos.x-1,pos.y-24,1,12,Color(255,0,0,c_alpha))
			draw.RoundedBox(0,pos.x-1,pos.y+11,1,12,Color(255,0,0,c_alpha))
		end
	end
	
	local tfahud = GetConVar('cl_tfa_hud_enabled')
	local qtghud = GetConVar('cl_qswep_custom_hud')
	if IsValid(w) and ((w:IsScripted() and w.DrawAmmo) or !w:IsScripted()) then
		if (w.IsQTGWeapon and qtghud:GetBool()) or (w.IsTFAWeapon and tfahud:GetBool()) then return end

		local custom = (w.CustomAmmoDisplay and isfunction(w.CustomAmmoDisplay)) and w:CustomAmmoDisplay() or nil
		local ammo1,ammo2 = p:GetAmmoCount(w:GetPrimaryAmmoType()),p:GetAmmoCount(w:GetSecondaryAmmoType())
		local clip1,clip2 = w:Clip1(),w:Clip2()
		local clip1max,clip2max = w:GetMaxClip1(),w:GetMaxClip2()
		local clip1d,clip2d = iammo(clip1)/clip1max,iammo(clip2)/clip2max
		local ammo1d,ammo2d = ammo1 > 0 and 1 or 0,ammo2 > 0 and 1 or 0
		local x,y = pos.x-30,pos.y-30
		
		if custom then
			clip1,clip2 = custom.PrimaryClip,custom.SecondaryClip
			ammo1,ammo2 = custom.PrimaryAmmo,custom.SecondaryAmmo
			
			if ciammo(clip1) != -1 then
				draw.SimpleText('MAG: '..ciammo(clip1),'QTG_hr_Ammo1',x-4,y+1,Color(0,0,0,200),TEXT_ALIGN_RIGHT)
				draw.SimpleText('MAG: '..ciammo(clip1),'QTG_hr_Ammo1',x-5,y,Color(255,255,255,255),TEXT_ALIGN_RIGHT)
				x = x-15
				y = y+40
			end

			if ciammo(ammo1) != -1 then
				draw.SimpleText('RESERVE: '..ciammo(ammo1),'QTG_hr_Ammo2',x-4,y+1,Color(0,0,0,200),TEXT_ALIGN_RIGHT)
				draw.SimpleText('RESERVE: '..ciammo(ammo1),'QTG_hr_Ammo2',x-5,y,Color(255,255,255,255),TEXT_ALIGN_RIGHT)
				x = x-10
				y = y+30
			end

			if ciammo(clip2) != -1 then
				draw.SimpleText('ALT-MAG: '..ciammo(clip2),'QTG_hr_Ammo3',x-4,y+1,Color(0,0,0,200),TEXT_ALIGN_RIGHT)
				draw.SimpleText('ALT-MAG: '..ciammo(clip2),'QTG_hr_Ammo3',x-5,y,Color(255,255,255,255),TEXT_ALIGN_RIGHT)
				x = x-10
				y = y+25
			end

			if ciammo(ammo2) != -1 then
				draw.SimpleText('ALT-Ammo: '..ciammo(ammo2),'QTG_hr_Ammo3',x-4,y+1,Color(0,0,0,200),TEXT_ALIGN_RIGHT)
				draw.SimpleText('ALT-Ammo: '..ciammo(ammo2),'QTG_hr_Ammo3',x-5,y,Color(255,255,255,255),TEXT_ALIGN_RIGHT)
				x = x-10
				y = y+25
			end
		end
		
		if w:GetPrimaryAmmoType() != -1 then
			if iammo(clip1) > -1 then
				draw.SimpleText('MAG: '..iammot(w,clip1),'QTG_hr_Ammo1',x-4,y+1,Color(0,0,0,200),TEXT_ALIGN_RIGHT)
				draw.SimpleText('MAG: '..iammot(w,clip1),'QTG_hr_Ammo1',x-5,y,Color(255,255*clip1d,255*clip1d,255),TEXT_ALIGN_RIGHT)
				x = x-15
				y = y+40
			end

			draw.SimpleText('RESERVE: '..iammo(ammo1),'QTG_hr_Ammo2',x-4,y+1,Color(0,0,0,200),TEXT_ALIGN_RIGHT)
			draw.SimpleText('RESERVE: '..iammo(ammo1),'QTG_hr_Ammo2',x-5,y,Color(255,255*ammo1d,255*ammo1d,255),TEXT_ALIGN_RIGHT)
			x = x-10
			y = y+30
		end

		if w:GetSecondaryAmmoType() != -1 then
			if iammo(clip2) > -1 then
				draw.SimpleText('ALT-MAG: '..iammot(w,clip2,true),'QTG_hr_Ammo3',x-4,y+1,Color(0,0,0,200),TEXT_ALIGN_RIGHT)
				draw.SimpleText('ALT-MAG: '..iammot(w,clip2,true),'QTG_hr_Ammo3',x-5,y,Color(255,255*clip2d,255*clip2d,255),TEXT_ALIGN_RIGHT)
				x = x-10
				y = y+25
			end

			draw.SimpleText('ALT-Ammo: '..iammo(ammo2),'QTG_hr_Ammo3',x-4,y+1,Color(0,0,0,200),TEXT_ALIGN_RIGHT)
			draw.SimpleText('ALT-Ammo: '..iammo(ammo2),'QTG_hr_Ammo3',x-5,y,Color(255,255*ammo2d,255*ammo2d,255),TEXT_ALIGN_RIGHT)
			x = x-10
			y = y+30
		end
	end
end

local function playerall()
	local t = {}

	for k,v in pairs(player.GetAll()) do
		if v != LocalPlayer() and v:Alive() and v != LocalPlayer():GetObserverTarget() then
			t[#t+1] = v
		end
	end

	return t
end

local showhalo = Horror.GetConvar('show_playerhalo')

function GM:PreDrawHalos()
	if !showhalo:GetBool() then return end

	for k,v in pairs(playerall()) do
		if v:Health() > 80 then
			halo.Add({v},Color(0,255,0),3,3,1,true,true)
		elseif v:Health() > 30 and v:Health() < 80 then
			halo.Add({v},Color(255,255,0),3,3,1,true,true)
		else
			halo.Add({v},Color(255,0,0),3,3,1,true,true)
		end
	end
end

local v_bobang = Angle(0,0,0)
local v_zoom = 0
local v_run = 0
local v_look = 0

function GM:CalcView(ply,pos,ang,fov)
	if viewt then return end
	if ply:ShouldDrawLocalPlayer() then return end

	local w = ply:GetActiveWeapon()
	local veh = ply:GetVehicle()
	local v = {}

	v.angles = ang
	v.fov = fov

	if IsValid(veh) then
		return hook.Run('CalcVehicleView',veh,ply,v)
	end

	if drive.CalcView(ply,v) then
		return v
	end

	if IsValid(w) and isfunction(w.CalcView) then
		v.origin,v.angles,v.fov = w:CalcView(ply,pos,ang,fov)

		return v
	end

	if !ply:Alive() then return end

	local ft,ct = FrameTime(),CurTime()
	local p,y = 0,0
	local s = ply:GetVelocity():LengthSqr()
	local run = ((s/ply:GetRunSpeed()^2)*100)/2
	local m = math.min((s*0.000001)*run,1)

	if ply:OnGround() then
		local vel = ply:GetVelocity()
		local dist = Vector(vel.x,vel.y,0):LengthSqr()
		local speed = math.Clamp(dist/(ply:GetRunSpeed()^2),0,1)

		p = -math.sin(ct*16.8)*speed
		y = math.sin(ct*8.4)*speed
	end

	local rd = ply:GetRight():Dot(ply:GetVelocity():GetNormalized())*5*0.7

	v_look = Lerp(math.Clamp(ft*5,0,1),v_look or 0,m < 0.01 and 0 or rd)
	v_bobang = LerpAngle(ft*8,v_bobang,Angle(p,y,0))
	v_run = Lerp(ft*5,v_run,ply:GetNW2Bool('QTG_Running') and ply:OnGround() and 10 or 0)

	v.angles = v.angles+v_bobang
	v.angles.r = v.angles.r+v_look
	v.fov = v.fov+v_run

	return v
end

local c_jump = 0
local c_look = 0
local c_move = 0
local c_move2 = 0
local c_runb = 0
local wept = {}

local c_oang = Angle(0,0,0)
local c_dang = Angle(0,0,0)

local function Sway(p,w,pos,ang,ct,ft,iftp)
	local sway = 1.2
	
	if !IsValid(p) then return pos,ang end
	
    local angdelta = p:EyeAngles()-c_oang
	
	if angdelta.y >= 180 then
		angdelta.y = angdelta.y - 360
	elseif angdelta.y <= -180 then
		angdelta.y = angdelta.y + 360
	end
	
	angdelta.p = math.Clamp(angdelta.p,-5,5)
	angdelta.y = math.Clamp(angdelta.y,-5,5)
	angdelta.r = math.Clamp(angdelta.r,-5,5)
	
	if iftp then
		local newang = LerpAngle(math.Clamp(ft*10,0,1),c_dang,angdelta)
		c_dang = newang
	end
	
    c_oang = p:EyeAngles()
	
	local psway = sway/2
	ang:RotateAroundAxis(ang:Right(),-c_dang.p*sway)
	ang:RotateAroundAxis(ang:Up(),c_dang.y*sway)
	ang:RotateAroundAxis(ang:Forward(),c_dang.y*sway)
	pos = pos + ang:Right()*c_dang.y*psway+ang:Up()*c_dang.p*psway

	return pos,ang
end

local function Movement(p,w,pos,ang,ct,ft,iftp)
	local s = p:GetVelocity():LengthSqr()
	local run = ((s/p:GetRunSpeed()^2)*100)/2
	local m = math.min((s*0.000001)*run,1)

	local v = p:GetVelocity():GetNormalized()
	local rd = p:GetRight():Dot(v)*20

	if iftp then
		local ftt = math.min(ft*8,1)
		c_move = Lerp(ftt,c_move or 0,p:OnGround() and m or 0)
		c_move2 = p:GetNW2Bool('QTG_Running') and 12 or 9

		local jump = math.Clamp(p:GetVelocity().z/120,-0.2,0.2)
		local jump2 = math.Clamp(p:GetVelocity().z/120,-2,1.5)
		c_jump = Lerp(ftt,c_jump or 0,p:GetMoveType() == MOVETYPE_NOCLIP and jump or jump2)
		c_look = Lerp(math.Clamp(ft*5,0,1),c_look or 0,m < 0.01 and 0 or rd)
		c_runb = Lerp(math.Clamp(ft*5,0,1),c_runb or 0,m > 0.9 and 2 or 1)
	end

	pos = pos+1.5*c_jump*ang:Up()
	pos = pos+-(2*c_jump)*ang:Forward()
	ang.p = ang.p+(c_jump or 0)*6
	ang.r = ang.r+(w.ViewModelFlip and -(c_jump or 0) or (c_jump or 0))*10
	ang.r = ang.r+(w.ViewModelFlip and -(c_look/2) or c_look/2)

	if c_move > 0 then
		ang.y = ang.y+math.sin(ct*c_move2)*(0.5*c_runb)*c_move
		ang.p = ang.p+math.sin(ct*(c_move2*2))*(1.5*c_runb)*c_move
		ang.r = ang.r+-(math.cos(ct*c_move2)*(1.2*c_runb)*c_move)

		pos = pos+(math.sin(ct*c_move2)*(0.9*c_runb)*c_move)*ang:Right()
		pos = pos+(math.sin(ct*(c_move2*2))*(0.6*c_runb)*c_move)*ang:Up()
		pos = pos+-(2*c_move)*ang:Forward()
	end

	local p2 = 1-c_move
	
	ang.p = ang.p + math.sin(ct*0.5)*1*p2
	ang.y = ang.y + math.sin(ct*1)*0.5*p2
	ang.r = ang.r + math.sin(ct*2)*0.25*p2

	return pos,ang
end

local hookoff = false

function GM:CalcViewModelView(w,vm,opos,oang,pos,ang)
	if !IsValid(w) then return end
	if hookoff then return end

	if isfunction(w.GetViewModelPosition) then
		if wept[w:GetClass()] == nil then
			wept[w:GetClass()] = debug.getinfo(w.GetViewModelPosition).short_src != 'gamemodes/base/entities/weapons/weapon_base/cl_init.lua'
		end

		if wept[w:GetClass()] then
			return w:GetViewModelPosition(pos,ang)
		end
	end

	if isfunction(w.CalcViewModelView) then
		local wpos,wang = w:CalcViewModelView(pos,ang)

		return wpos,wang
	end

	local p = w:GetOwner()

	if !IsValid(p) then
		return opos,oang
	end

	local t = p:GetObserverTarget()

	if IsValid(t) and t:IsPlayer() then
		p = t
	end

	pos,ang = opos,oang

	local ct,ft = CurTime(),FrameTime()
	local iftp = game.SinglePlayer() or IsFirstTimePredicted()
	
	pos,ang = Sway(p,w,pos,ang,ct,ft,iftp)
	pos,ang = Movement(p,w,pos,ang,ct,ft,iftp)

	hookoff = true

	local hpos,hang = hook.Run('CalcViewModelView',w,vm,opos,oang,pos,ang)

	hookoff = false

	if hpos then
		pos = hpos
	end

	if hang then
		ang = hang
	end

	return pos,ang
end

-- local t = {
-- 	['$pp_colour_addr'] = -50/255,
-- 	['$pp_colour_addg'] = -50/255,
-- 	['$pp_colour_addb'] = -50/255,
-- 	['$pp_colour_brightness'] = -0.08,
-- 	['$pp_colour_contrast'] = 1.50,
-- 	['$pp_colour_colour'] = 0.45,
-- 	['$pp_colour_mulr'] = -50/255,
-- 	['$pp_colour_mulg'] = -50/255,
-- 	['$pp_colour_mulb'] = -50/255
-- }

local t = {
	['$pp_colour_addr'] = -38/255,
	['$pp_colour_addg'] = -38/255,
	['$pp_colour_addb'] = -32/255,
	['$pp_colour_brightness'] = 0.07,
	['$pp_colour_contrast'] = 1.39,
	['$pp_colour_colour'] = 0.65,
	['$pp_colour_mulr'] = -0.17/255,
	['$pp_colour_mulg'] = -43.35/255,
	['$pp_colour_mulb'] = -43.35/255
}

function GM:RenderScreenspaceEffects()
	DrawColorModify(t)
end