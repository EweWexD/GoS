if GetObjectName(GetMyHero()) ~= "Nasus" then return end

require("Inspired")
--if not pcall( require, "OpenPredict" ) then PrintChat("This script doesn't work without OpenPredict! Download it!") return end
-- Version without OpenPredict TEST ONLY

local version = 1

-- Menu
NMenu = Menu("Nasus", "Nasus")
NMenu:SubMenu("c", "Combo")
NMenu.c:Boolean("Q", "Use Q", true)
--NMenu.c:Boolean("QP", "Use HP Pred for Q", true)
NMenu.c:Slider("QDM", "Q DMG mod", 0, -10, 10, 1)
NMenu.c:Boolean("W", "Use W", true)
NMenu.c:Slider("WHP", "Use W at %HP", 20, 1, 100, 1)
NMenu.c:Boolean("E", "Use E", true)
NMenu.c:Boolean("R", "Use R", true)
NMenu.c:Slider("RHP", "Use R at %HP", 20, 1, 100, 1)

NMenu:SubMenu("f", "Farm")
NMenu.f:Boolean("QLC", "Use Q in LaneClear", true)
NMenu.f:Boolean("QLH", "Use Q in LastHit", true)
NMenu.f:Boolean("QA", "Always use Q", true)

NMenu:SubMenu("ks", "Killsteal")
NMenu.ks:Boolean("KSQ","Killsteal with Q", true)
NMenu.ks:Boolean("KSE","Killsteal with E", true)

NMenu:SubMenu("d", "Draw Damage")
NMenu.d:Boolean("dD","Draw Damage", true)
NMenu.d:Boolean("dQ","Draw Q", true)
NMenu.d:Boolean("dE","Draw E", true)
NMenu.d:Boolean("dQM","Draw Q (Minions)", true)

NMenu:SubMenu("i", "Items")
NMenu.i:Boolean("iC","Use Items only in Combo", true)
NMenu.i:Boolean("iO","Use offensive Items", true)

NMenu:SubMenu("a", "AutoLvl")
NMenu.a:Boolean("aL", "Use AutoLvl", true)
NMenu.a:DropDown("aLS", "AutoLvL", 1, {"Q-W-E","Q-E-W"})
NMenu.a:Slider("sL", "Start AutoLvl with LvL x", 1, 1, 18, 1)
NMenu.a:Boolean("hL", "Humanize LvLUP", true)

NMenu:SubMenu("s","Skin")
NMenu.s:Boolean("uS", "Use Skin", false)
NMenu.s:Slider("sV", "Skin Number", 0, 0, 10, 1)

--Var
NasusE = { delay = 0.1, speed = math.huge, range = GetCastRange(myHero,_E), radius = 390}
cSkin = 0
Stacks = 0
local item = {GetItemSlot(myHero,3144),GetItemSlot(myHero,3142),GetItemSlot(myHero,3153)}
--						 cutlassl 				 gb 			 bork 

--Lvlup table
lTable={
[1]={_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E},
[2]={_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W}
}


-- Start
OnTick(function(myHero)
	if not IsDead(myHero) then
		qDmg = getQdmg()
		local unit = GetCurrentTarget()
		ks()
		combo(unit)
		farm()
		items(unit)
		lvlUp()
		skin()
	end
end)


--Functions

function combo(unit)

	if IOW:Mode() == "Combo" then
		--Q
		if NMenu.c.Q:Value() and Ready(_Q) and ValidTarget(unit, GetCastRange(myHero,_Q)) then
			CastSpell(_Q)
			AttackUnit(unit)
		end
		
		--W
		if Ready(_W) and NMenu.c.W:Value() and ValidTarget(unit, GetCastRange(myHero,_W)) and GetPercentHP(unit) < NMenu.c.WHP:Value() then
			CastTargetSpell(unit,_W)
		end		
		
		--E
		if Ready(_E) and NMenu.c.E:Value() and ValidTarget(unit, GetCastRange(myHero,_E)) then
				CastSkillShot(_E,GetOrigin(unit))
		end		
	end
	
	--R
	if Ready(_R) and NMenu.c.R:Value() and ValidTarget(unit, 1075) and GetPercentHP(myHero) < NMenu.c.RHP:Value() then
		CastSpell(_R)
	end		
end

function farm()
	if (Ready(_Q) or CanUseSpell(myHero,_Q) == 8) and ((NMenu.f.QLC:Value() and IOW:Mode() == "LaneClear") or (NMenu.f.QLH:Value() and IOW:Mode() == "LastHit") or (NMenu.f.QA:Value() and IOW:Mode() ~= "Combo")) then
		for _, creep in pairs(minionManager.objects) do
			if ValidTarget(creep,GetRange(myHero)+GetHitBox(myHero)+GetHitBox(creep)/2) and (GetCurrentHP(creep)<CalcDamage(myHero, creep, qDmg, 0)) then
				CastSpell(_Q)
				AttackUnit(creep)
			end
		end
	end
end

function ks()
	for i,unit in pairs(GetEnemyHeroes()) do
		
		--Q
		if NMenu.ks.KSQ:Value() and Ready(_Q) and ValidTarget(unit, GetCastRange(myHero,_Q)) and GetCurrentHP(unit)+GetDmgShield(unit) < CalcDamage(myHero, unit, qDmg, 0) then
			CastSpell(_Q)
			AttackUnit(unit)
		end
		
		--E
		if NMenu.ks.KSE:Value() and Ready(_E) and ValidTarget(unit,GetCastRange(myHero,_E)) and GetCurrentHP(unit)+GetDmgShield(unit)+GetMagicShield(unit) <  CalcDamage(myHero, unit, 0, 15+40*GetCastLevel(myHero,_E)+GetBonusAP(myHero)*6) then 
				CastSkillShot(_E,GetOrigin(unit))
		end
	end
end

function items(unit)
	if NMenu.i.iO:Value() and ValidTarget(unit,500) then
		if IOW:Mode() == "Combo" or not NMenu.i.iC:Value() then
			for _,i in pairs(item) do
				if i>0 then
					CastTargetSpell(unit,i)
				end
			end
		end
	end
end

function getQdmg()
	local base = 10 + 20*GetCastLevel(myHero,_Q) + GetBaseDamage(myHero) + GetBuffData(myHero,"nasusqstacks").Stacks + NMenu.c.QDM:Value()
	if 		(Sheen or Ready(GetItemSlot(myHero,3078))) and GetItemSlot(myHero,3078)>0 then base = base + GetBaseDamage(myHero)*2 
	elseif 	(Sheen or Ready(GetItemSlot(myHero,3057))) and GetItemSlot(myHero,3057)>0 then base = base + GetBaseDamage(myHero)
	elseif 	(Sheen or Ready(GetItemSlot(myHero,3057))) and GetItemSlot(myHero,3025)>0 then base = base + GetBaseDamage(myHero)*1.25 
	end
	return base
end

function lvlUp()
	if NMenu.a.aL:Value() and GetLevelPoints(myHero) >= 1 and GetLevel(myHero) >= NMenu.a.sL:Value() then
		if NMenu.a.hL:Value() then
			DelayAction(function() LevelSpell(lTable[NMenu.a.aLS:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(500,750))
		else
			LevelSpell(lTable[NMenu.a.aLS:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1])
		end
	end
end

function skin()
	if NMenu.s.uS:Value() and NMenu.s.sV:Value() ~= cSkin then
		HeroSkinChanger(GetMyHero(),NMenu.s.sV:Value()) 
		cSkin = NMenu.s.sV:Value()
	end
end



--CALLBACKS

OnUpdateBuff(function(unit,buffProc)
	if unit == myHero and buffProc.Name == "sheen" then
		Sheen = true
	end
end)

OnRemoveBuff(function(unit,buffProc)
	if unit == myHero and buffProc.Name == "sheen" then
		Sheen = false
	end
end)

PrintChat("Nasus Loaded - Enjoy your game - Logge")