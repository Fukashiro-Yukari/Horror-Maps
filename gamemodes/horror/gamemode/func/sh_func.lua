function Horror.Error(s,b)
	if !isstring(s) then
		s = 'Unknown error'
	end

	if b then
		error('['..Horror.Name..'] Error: '..s)
	else
		MsgC(Color(255,90,90),'['..Horror.Name..'] Error: '..s..'\n')
	end
end

function Horror.Assert(b,s,b2)
	if tobool(b) then return true end

	Horror.Error(s,b2)

	return false
end