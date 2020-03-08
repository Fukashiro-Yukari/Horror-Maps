local sprint = Horror.GetConvar('sprint_durable')

function GM:SetupMove(p,m,c)
	if !p:Alive() then return end

	if m:KeyDown(IN_JUMP) then
		if p:IsOnGround() then
			if p:GetNW2Float('QTG_hr_sprint_durable') < 10 or p:GetNW2Float('qtg_hr_jumptime2') > CurTime() then
				m:RemoveKeys(IN_JUMP)
			end
		end
	end

	if CLIENT then return end

	if p:IsOnGround() then
		if m:KeyDown(IN_JUMP) then
			if p:GetNW2Float('qtg_hr_jumptime2') < CurTime() then
				if p:GetNW2Float('qtg_hr_jumptime') > CurTime() then
					p:SetNW2Float('qtg_hr_jump',p:GetNW2Float('qtg_hr_jump')-0.3)
				end

				p:SetNW2Float('qtg_hr_jumptime',CurTime()+2.5)
				p:SetNW2Float('qtg_hr_jumptime2',CurTime()+0.9)
			end

			if p:GetNW2Float('QTG_hr_sprint_durable') > 0 then
				p:SetNW2Float('QTG_hr_sprint_durable',p:GetNW2Float('QTG_hr_sprint_durable')-10)
			else
				p.tbspeedkey = CurTime()+1.5
			end
		end

		if m:KeyPressed(IN_DUCK) then
			if p:GetNW2Float('qtg_hr_jumptime2') < CurTime() then
				if p:GetNW2Float('qtg_hr_jumptime') > CurTime() then
					p:SetNW2Float('qtg_hr_jump',p:GetNW2Float('qtg_hr_jump')-0.2)
				end

				p:SetNW2Float('qtg_hr_jumptime',CurTime()+2.5)
			end
		end
	end
end

function GM:CreateMove(c)
	local p = LocalPlayer()
	local newb = c:GetButtons()

	if p:Alive() then
		if !p:Crouching() and c:KeyDown(IN_SPEED) and p:GetVelocity():LengthSqr() > p:GetWalkSpeed()^2 then
			if p:GetNW2Float('QTG_hr_sprint_durable') < 0.9 then
				newb = newb-IN_SPEED
			end
		end
		
		c:SetButtons(newb)
	end
end