Horror.ReadNet('GiveWeapon',function(p,s)
	p:Give(s)
end)

Horror.ReadNet('SetModel',function(p)
	if !Horror.GetConvar('randomplayerModel'):GetBool() then
		Horror.SetPlayerModel(p)
		Horror.SetPlayerHandsModel(p)
	end

	Horror.SetPlayerColor(p)
end)