local d = {}
local c = {}
d[myHero.name] = 0
c[myHero.name] = myHero
local M = Menu("DmgFlow","DmgFlow")
M:Boolean("Do","Enable Flowchart", true)
M:Slider("X","x Pos", GetResolution().x*.85,0,GetResolution().x,10)
M:Slider("Y","y Pos", GetResolution().y*.5,0,GetResolution().y,10)
M:Slider("S","Size", 30,10,50,5)
M:ColorPick("C","Text color",{255,255,255,255})
M:DropDown("R", "Round", 1, {"0.001k", "0.010k", "0.100k", "1.000k"})
M:Boolean("F","Fere fixed OnDamage",false)
if M.F:Value() then M:Boolean(myHero.name,"Draw for self", true) DelayAction(function() for _,i in pairs(GetAllyHeroes()) do 	M:Boolean(i.name,"Draw for "..GetObjectName(i), true) 	d[i.name] = 0 	c[i.name] = i 	end end,0) end
OnDamage( function (unit,target,dmg)
	if not M.Do:Value() then return end
	if GetObjectType(unit) == Obj_AI_Hero and GetObjectType(target) == Obj_AI_Hero and GetTeam(unit) == MINION_ALLY then d[unit.name] = d[unit.name] + dmg end
end)
OnDraw( function()
	if not M.Do:Value() then return end
	local __ = 0
	for _,i in pairs(d) do
		if not M.F:Value() or (M[c[_].name] and M[c[_].name]:Value()) then DrawText(GetObjectName(c[_])..": ".. (10^(M.R:Value()-1)*math.round(i * .1^(M.R:Value()-1))*.001) .."k Dmg",M.S:Value(),M.X:Value(),M.Y:Value()+__,M.C:Value()) __ = __ + M.S:Value() end
	end
end)
