local menubg = Color(0,0,0,200)

local PLAYER_LINE = {
	Init = function(self)
		self.AvatarButton = self:Add('DButton')
		self.AvatarButton:Dock( LEFT )
		self.AvatarButton:SetSize( 32, 32 )
		self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

		self.Avatar = vgui.Create('AvatarImage',self.AvatarButton)
		self.Avatar:SetSize( 32, 32 )
		self.Avatar:SetMouseInputEnabled(false)

		self.Name = self:Add('DLabel')
		self.Name:Dock(FILL)
		self.Name:SetFont('QTG_hr_ScoreboardDefault')
		self.Name:SetTextColor(Color(96,96,96))
		self.Name:DockMargin(8,0,0,0)
		
		self.Mute = self:Add('DImageButton')
		self.Mute:SetSize( 32, 32 )
		self.Mute:Dock(RIGHT)

		self.Ping = self:Add('DLabel')
		self.Ping:Dock(RIGHT)
		self.Ping:SetWidth(50)
		self.Ping:SetFont('QTG_hr_ScoreboardDefault')
		self.Ping:SetTextColor(Color(96,96,96))
		self.Ping:SetContentAlignment(5)

		self.Deaths = self:Add('DLabel')
		self.Deaths:Dock(RIGHT)
		self.Deaths:SetWidth(50)
		self.Deaths:SetFont('QTG_hr_ScoreboardDefault')
		self.Deaths:SetTextColor(Color(96,96,96))
		self.Deaths:SetContentAlignment(5)

		self.Kills = self:Add('DLabel')
		self.Kills:Dock(RIGHT)
		self.Kills:SetWidth(50)
		self.Kills:SetFont('QTG_hr_ScoreboardDefault')
		self.Kills:SetTextColor(Color(96,96,96))
		self.Kills:SetContentAlignment(5)
		
		self.Death = self:Add('DLabel')
		self.Death:Dock(RIGHT)
		self.Death:SetWidth(100)
		self.Death:SetFont('QTG_hr_ScoreboardDefault')
		self.Death:SetTextColor(Color(96,96,96))
		self.Death:SetContentAlignment(5)

		self:Dock(TOP)
		self:DockPadding(3,3,3,3)
		self:SetHeight(32 + 3 * 2)
		self:DockMargin(2,0,2,2)
	end,

	Setup = function(self,p)
		self.Player = p
		self.Avatar:SetPlayer(p)
		self:Think(self)
	end,

	Think = function(self)
		if !IsValid(self.Player) then
			self:SetZPos(9999)
			self:Remove()
			return
		end
		if self.PName == nil or self.PName != self.Player:Nick() then
			self.PName = self.Player:Nick()
			self.Name:SetText(self.PName)
		end
		if self.NumKills == nil or self.NumKills != self.Player:Frags() then
			self.NumKills = self.Player:Frags()
			self.Kills:SetText(self.NumKills)
		end
		if self.NumDeaths == nil or self.NumDeaths != self.Player:Deaths() then
			self.NumDeaths = self.Player:Deaths()
			self.Deaths:SetText(self.NumDeaths)
		end
		if self.IsDeath == nil or self.IsDeath != !self.Player:Alive() then
			self.IsDeath = !self.Player:Alive()
			if self.IsDeath then
				self.Death:SetText('Death')
			else
				self.Death:SetText('')
			end
		end
		if (self.NumPing == nil or self.NumPing != self.Player:Ping()) and !self.Player:IsBot() then
			self.NumPing = self.Player:Ping()
			self.Ping:SetText(self.NumPing)
		elseif self.Player:IsBot() then
			self.Ping:SetText('BOT')
		end
		if (self.Muted == nil or self.Muted != self.Player:IsMuted()) and self.Player != LocalPlayer() and !self.Player:IsBot() then
			self.Muted = self.Player:IsMuted()
			if self.Muted then
				self.Mute:SetImage('icon32/muted.png')
			else
				self.Mute:SetImage('icon32/unmuted.png')
			end
			self.Mute.DoClick = function() self.Player:SetMuted(!self.Muted) end
		end
		if self.Player:Team() == TEAM_CONNECTING then
			self:SetZPos(2000 + self.Player:EntIndex())
			return
		end
		self:SetZPos((self.NumKills * -50) + self.NumDeaths + self.Player:EntIndex())
	end,

	Paint = function(self,w,h)
		if !IsValid(self.Player) then
			return
		end
		surface.SetDrawColor(Color(200,200,200,200))

		if self.Player:Team() == TEAM_CONNECTING then
			surface.SetDrawColor(Color(200,200,200,200))
		end

		if self.Player:IsAdmin() then
			surface.SetDrawColor(Color(100,255,100,200))
		end

		if !self.Player:Alive() then
			surface.SetDrawColor(Color(230,100,100,200))
		end

		surface.DrawRect(0,0,w,h)
	end
}

PLAYER_LINE = vgui.RegisterTable(PLAYER_LINE,'DPanel')

local SCORE_BOARD = {
	Init = function(self)
		self.Header = self:Add('Panel')
		self.Header:Dock(TOP)
		self.Header:SetHeight(60)
		
		self.frame = self:Add('DPanel')
		self.frame:Dock(FILL)
		self.frame:DockMargin(5,20,5,5)
		self.frame.Paint = function(self,w,h)
			surface.SetDrawColor(menubg)
			surface.DrawRect(0,0,w,h)
		end
		
		self.frame2 = self:Add('DPanel')
		self.frame2:SetSize(((ScrW()-200)/1.6),0)
		self.frame2:Dock(RIGHT)
		self.frame2:DockMargin(0,20,5,5)
		self.frame2.Paint = function(self,w,h)
			surface.SetDrawColor(menubg)
			surface.DrawRect(0,0,w,h)
		end

		self.Name = self.Header:Add('DLabel')
		self.Name:SetFont('QTG_hr_ScoreboardDefaultTitle')
		self.Name:SetTextColor(Color(255,255,255,255))
		self.Name:Dock(TOP)
		self.Name:SetHeight(60)
		self.Name:SetContentAlignment(5)
		self.Name:SetExpensiveShadow(2,Color(0,0,0,200))
		
		self.frame.Header = self.frame:Add('Panel')
		self.frame.Header:Dock(TOP)
		self.frame.Header:SetHeight(40)
		
		self.NumPlayers = self.frame.Header:Add('DLabel')
		self.NumPlayers:SetFont('QTG_hr_ScoreboardDefault')
		self.NumPlayers:SetTextColor(Color(255,255,255,255))
		self.NumPlayers:Dock(FILL)
		self.NumPlayers:DockMargin(8,0,0,0)
		self.NumPlayers:SetContentAlignment(4)
		self.NumPlayers:SetExpensiveShadow(2,Color(0,0,0,200))
		
		self.Ping = self.frame.Header:Add('DLabel')
		self.Ping:Dock(RIGHT)
		self.Ping:DockMargin(0,0,35,0)
		self.Ping:SetWidth(50)
		self.Ping:SetFont('QTG_hr_ScoreboardDefault2')
		self.Ping:SetTextColor(Color(255,255,255))
		self.Ping:SetText('Ping')
		self.Ping:SetContentAlignment(5)
		
		self.Deaths = self.frame.Header:Add('DLabel')
		self.Deaths:Dock(RIGHT)
		self.Deaths:SetWidth(50)
		self.Deaths:SetFont('QTG_hr_ScoreboardDefault2')
		self.Deaths:SetTextColor(Color(255,255,255))
		self.Deaths:SetText('Deaths')
		self.Deaths:SetContentAlignment(5)
		
		self.Kills = self.frame.Header:Add('DLabel')
		self.Kills:Dock(RIGHT)
		self.Kills:SetWidth(50)
		self.Kills:SetFont('QTG_hr_ScoreboardDefault2')
		self.Kills:SetTextColor(Color(255,255,255))
		self.Kills:SetText('Kills')
		self.Kills:SetContentAlignment(5)
		
		self.frame.Scores = self.frame:Add('DScrollPanel')
		self.frame.Scores:Dock(FILL)
		
		local mapicon = 'maps/thumb/'..game.GetMap()..'.png'

		if Material(mapicon):IsError() then
			mapicon = 'maps/thumb/noicon.png'
		end

		local w,h = self.frame2:GetSize()

		self.Mapicon = self.frame2:Add('Material')
		self.Mapicon:SetMaterial(mapicon)
		self.Mapicon:Dock(TOP)
		self.Mapicon:DockMargin(380,10,380,5)
		self.Mapicon:SetHeight(300)
		self.Mapicon.AutoSize = false
		self.Mapicon:SetColor(Color(255,255,255,100))

		self.MapName = self.frame2:Add('DLabel')
		self.MapName:SetFont('QTG_hr_ScoreboardDefault')
		self.MapName:SetTextColor(Color(255,255,255,255))
		self.MapName:Dock(TOP)
		self.MapName:DockMargin(10,0,10,0)
		self.MapName:SetContentAlignment(4)
		self.MapName:SetExpensiveShadow(2,Color(0,0,0,200))
		self.MapName:SetText('Current map: '..game.GetMap())

		self.mapmission = self.frame2:Add('DLabel')
		self.mapmission:SetFont('QTG_hr_ScoreboardDefault')
		self.mapmission:SetTextColor(Color(255,255,255,255))
		self.mapmission:Dock(TOP)
		self.mapmission:DockMargin(10,0,10,0)
		self.mapmission:SetContentAlignment(4)
		self.mapmission:SetExpensiveShadow(2,Color(0,0,0,200))
		self.mapmission:SetText('Current mission: Make sure all players survive')
	end,

	PerformLayout = function(self)
		self:SetSize(ScrW()-200,ScrH()-200)
		self:SetPos(100,100)
	end,

	Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,menubg)
	end,

	Think = function( self, w, h )
		self.Name:SetText(GetHostName())

		if !self.__plynum or self.__plynum != #player.GetAll() then
			self.__plynum = #player.GetAll()

			self.NumPlayers:SetText('Players: '..self.__plynum..'/'..game.MaxPlayers())
		end

		for id, pl in pairs(player.GetAll()) do
			if IsValid(pl.ScoreEntry) then continue end

			pl.ScoreEntry = vgui.CreateFromTable(PLAYER_LINE,pl.ScoreEntry)
			pl.ScoreEntry:Setup(pl)

			self.frame.Scores:AddItem(pl.ScoreEntry)
		end
	end
}

SCORE_BOARD = vgui.RegisterTable(SCORE_BOARD,'EditablePanel')

function GM:ScoreboardShow()
	if !IsValid(g_Scoreboard) then
		g_Scoreboard = vgui.CreateFromTable(SCORE_BOARD)
	end

	if IsValid(g_Scoreboard) then
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled(false)
	end
end

function GM:ScoreboardHide()
	if IsValid(g_Scoreboard) then
		g_Scoreboard:Hide()
		-- g_Scoreboard:Remove()
	end
end

function GM:HUDDrawScoreBoard() end