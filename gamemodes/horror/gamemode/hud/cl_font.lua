local function addfont(a,b,c,d,e)
	surface.CreateFont(a,{
		font = b, 
		size = c,
		weight = d,
		additive = e
	})
end

addfont('QTG_hr_hudicon','horroricon',35,1000,false)
addfont('QTG_hr_HpAr','HALFLIFE2',35,1000,false)
addfont('QTG_hr_Ammo1','Roboto Bk',40,1000,false)
addfont('QTG_hr_Ammo2','Roboto Bk',30,1000,false)
addfont('QTG_hr_Ammo3','Roboto Bk',25,1000,false)
addfont('QTG_hr_SpectateName','Roboto Bk',44,800,false)
addfont('QTG_hr_HpArN','Roboto Bk',20,800,false)
addfont('QTG_hr_HL2SelectIcons','HALFLIFE2',ScreenScale(50),nil,true)
addfont('QTG_hr_HL2SelectIcons2','HALFLIFE2',ScreenScale(30),nil,true)
addfont('QTG_hr_SelectIcons','horroricon',ScreenScale(50),nil,true)

addfont('qtg_horror_unknown_font','Roboto Bk',ScreenScale(10),nil,true)
addfont('QTG_hr_ScoreboardDefault','Roboto',22,800,false)
addfont('QTG_hr_ScoreboardDefault2','Roboto',18,800,false)
addfont('QTG_hr_ScoreboardDefaultTitle','Roboto',60,800,false)

killicon.AddFont('qtg_horror_unknown','qtg_horror_unknown_font','?',Color(255,80,0))
killicon.AddFont('qtg_hr_item_lighter','QTG_hr_SelectIcons','d',Color(255,80,0))