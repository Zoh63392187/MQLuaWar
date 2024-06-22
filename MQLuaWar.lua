--[[
Todo:
Better defensive cycle.
Glyph's Power / Dragon
Regen familiar
]]

local mq = require('mq')
require('ImGui')

if mq.TLO.Me.Class.ShortName() ~= 'WAR' then
	mq.cmd('/beep')
	mq.cmd('/beep')
	print('Wrong class... Did the file name not say it all?')
	os.exit()
end

local srcName = 'MQLuaWar'
local version = '0.2'
local classSettings = {
	currentmode=1,
	Melee_taunt=true,
	Melee_AOE_taunt=true,
	Melee_OT_taunt=false,
	Melee_face=false,
	Melee_distance=false,
	Melee_snare=true,
	Melee_Sheol=true,
	Melee_rampage=false,
	Melee_Burn_always=true,
	Defensive_disc_cycle=false,
	Defensive_buffs=true,	
	Defensive_da=true,
	Offensive_disc_cycle=false,
	End_mana_buffs=true,
	Misc_powersource=true,
	Misc_aura=true,
	Misc_epic1_5=false,
	Misc_epic2_0=false,
	Misc_monitor_food_drink=true,
	Misc_monitor_endurance=true
}
local keepAlive = true
local powerSourceChecked = os.time()

local function initIni()
	if not mq.TLO.Ini(srcName..'_'..mq.TLO.Me.CleanName()..'.ini',"Settings")() then
		print('Creating Ini file')
		
		for k,v in pairs(classSettings) do
			mq.cmd('/ini "'..srcName..'_'..mq.TLO.Me.CleanName()..'.ini" "Settings" '..k..' "0"')
			--classSettings[k] = false
		end
	else 
		for k,v in pairs(classSettings) do
			if mq.TLO.Ini(srcName..'_'..mq.TLO.Me.CleanName()..'.ini',"Settings",k)() == "0" or mq.TLO.Ini(srcName..'_'..mq.TLO.Me.CleanName()..'.ini',"Settings",k)() == "1" then
				if mq.TLO.Ini(srcName..'_'..mq.TLO.Me.CleanName()..'.ini',"Settings",k)() == '1' then
					classSettings[k] = true
				else
					classSettings[k] = false
				end
			else
				mq.cmd('/beep')
				mq.cmd('/beep')
				print('Invalid Ini file! Create a backup and delete the Ini file')
				os.exit()
			end
		end
	end
end

local function updateIni(var,value)
	mq.cmd('/ini "'..srcName..'_'..mq.TLO.Me.CleanName()..'.ini" "Settings" "'..var..'" "'..value..'"')
end

local function setup()
	print('\ay Welcome to '..srcName..' '..version..' - Created by Blasty')
	initIni()
end

local function checkIni()
	for k,v in pairs(classSettings) do
		if classSettings[k] == true then
			updateIni(k,'1')
		elseif classSettings[k] == false then
			updateIni(k,'0')
		end
	end
end

local function HelpDescription(desc)
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 35.0)
        ImGui.Text(desc)
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
    end
end

local function buildWindow()
	local update

	keepAlive = ImGui.Begin(srcName, keepAlive)
	
	local fruits = {"Manuel", "Tank", "TankPuller", "Hunter"}
	classSettings.currentmode = 1
	ImGui.Text("Mode: ")
	ImGui.SameLine()
	ImGui.SetNextItemWidth(100)
	classSettings.currentmode, update = ImGui.Combo("", classSettings.currentmode, fruits, #fruits)
	if update then checkIni() end
	ImGui.Separator()
	
	ImGui.TextColored(IM_COL32(255, 255, 0, 255), 'Melee:')
	ImGui.Separator()
	
    classSettings.Melee_taunt, update = ImGui.Checkbox('Taunt', classSettings.Melee_taunt)
	HelpDescription('Taunt\'s if needed and build aggro on target')
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Melee_AOE_taunt, update = ImGui.Checkbox('AOE Taunt', classSettings.Melee_AOE_taunt)
	HelpDescription('Ensure 100% aggro on extended target list')
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Melee_OT_taunt, update = ImGui.Checkbox('OT Taunt', classSettings.Melee_OT_taunt)
	HelpDescription('Over Time Taunt (Pop illusion)')
	if update then checkIni() end
	
	ImGui.SameLine()
	classSettings.Melee_face, update = ImGui.Checkbox('Face', classSettings.Melee_face)
	HelpDescription('Will face the mob while in combat')
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Melee_distance, update = ImGui.Checkbox('Distance', classSettings.Melee_distance)
	HelpDescription('Will ensure distance between 5 <-> 15 feet within 50 feet')
	if update then checkIni() end
	
	classSettings.Melee_snare, update = ImGui.Checkbox('Snare', classSettings.Melee_snare)
	HelpDescription('Snare target - reducing movement speed')
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Melee_Sheol, update = ImGui.Checkbox('Sheol\'s', classSettings.Melee_Sheol)
	HelpDescription('AA 2H melee strike that also buff you (Attack speed and Critical damage)')
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Melee_rampage, update = ImGui.Checkbox('Rampage', classSettings.Melee_rampage)
	HelpDescription('AOE melee attack')
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Melee_Burn_always, update = ImGui.Checkbox('Burn Always', classSettings.Melee_Burn_always)
	HelpDescription('Use all burns when they are available')
	if update then checkIni() end
	ImGui.NewLine()	
	
	ImGui.TextColored(IM_COL32(255, 255, 0, 255), 'Disciplines:')
	ImGui.Separator()
	classSettings.Defensive_disc_cycle, update = ImGui.Checkbox('Defensive cycle', classSettings.Defensive_disc_cycle)
	HelpDescription('Cycle some defensive Disciplines')
	if update then
		if classSettings.Offensive_disc_cycle == true then
			print('Error! You can\'t have both Offensive and Defensive cycle running at the same time')
			mq.cmd('/beep')
			mq.cmd('/beep')
			classSettings.Defensive_disc_cycle = false
		else 
			checkIni() 
		end
	end
	ImGui.SameLine()
	classSettings.Offensive_disc_cycle, update = ImGui.Checkbox('Offensive cycle', classSettings.Offensive_disc_cycle)
	HelpDescription('Cycle some offensive Disciplines')
	if update then
		if classSettings.Defensive_disc_cycle == true then
			print('Error! You can\'t have both Offensive and Defensive cycle running at the same time')
			mq.cmd('/beep')
			mq.cmd('/beep')
			classSettings.Offensive_disc_cycle = false
		else 
			checkIni() 
		end
	end
	ImGui.NewLine()
	
	ImGui.TextColored(IM_COL32(255, 255, 0, 255), 'Buffs:')
	ImGui.Separator()
	classSettings.Defensive_buffs, update = ImGui.Checkbox('Defensive', classSettings.Defensive_buffs)
	HelpDescription('Will cast melee, armor and group buffs')
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Defensive_buff_cycle, update = ImGui.Checkbox('Defensive Buff Cycle', classSettings.Defensive_buff_cycle)
	HelpDescription('Will cycle all defensive buffs but not defensive Disciplines')
	if update then checkIni() end
	
	
	ImGui.SameLine()
	classSettings.Misc_aura, update = ImGui.Checkbox('Aura', classSettings.Misc_aura)
	HelpDescription('Ensure that you have (Champion\'s Aura) at all times')
	if update then checkIni() end
	if mq.TLO.FindItem("Champion's Sword of Eternal Power").ID() then
		classSettings.Misc_epic1_5, update = ImGui.Checkbox('Epic 1.5', classSettings.Misc_epic1_5)
		HelpDescription('Pop epic 1.5 epic HP buff while in combat')
		if update then checkIni() end
		ImGui.SameLine()
	end
	if mq.TLO.FindItem("Kreljnok's Sword of Eternal Power").ID() then
		classSettings.Misc_epic2_0, update = ImGui.Checkbox('Epic 2.0', classSettings.Misc_epic2_0)
		HelpDescription('Pop epic 2.0 epic HP buff while in combat')
		if update then checkIni() end
		ImGui.NewLine()
	end
	
	ImGui.TextColored(IM_COL32(255, 255, 0, 255), 'Monitor:')
	ImGui.Separator()
	classSettings.Misc_monitor_endurance, update = ImGui.Checkbox('Endurance', classSettings.Misc_monitor_endurance)
	HelpDescription('Will cast Convalesce if endurance gets below 10%')
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Misc_monitor_food_drink, update = ImGui.Checkbox('Food/Drink', classSettings.Misc_monitor_food_drink)
	HelpDescription('This will eat (Misty Thicket Picnic) and drink (Kaladim Constitutional) when needed and not your good food and drink.')
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Misc_powersource, update = ImGui.Checkbox('PowerSource', classSettings.Misc_powersource)
	HelpDescription('Will Alert (once) you when powersouce is at 0%')
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Defensive_da, update = ImGui.Checkbox('DA', classSettings.Defensive_da)
	HelpDescription('If you get below 30% HP and if ready:\nCast (Flash of Anger)\nClick the BP\nCast (Armor of Experience)')
	if update then checkIni() end
	
	classSettings.End_mana_buffs, update = ImGui.Checkbox('Mana/End', classSettings.End_mana_buffs)
	HelpDescription('Will cycle Feather and Horn if End <95 and regen buffs not already active')
	if update then checkIni() end
	
	ImGui.End()
end

local CheckCombat = function ()
	if mq.TLO.Zone.ID() == 190 then
		return false		
	end
	local mySelf = mq.TLO.Me
	local CurTarget = mq.TLO.Target
	local tarAggro = CurTarget.PctAggro()
	local tarDistance = CurTarget.Distance()
	local tarID = CurTarget.ID()
	
	if mySelf.Combat() then	
		-- Melee:
		if classSettings.Melee_taunt == true then
			-- this no longer add hatred
			if mySelf.CombatAbilityReady(mq.TLO.Spell("Razor Tongue Discipline").RankName())() then
				--mq.cmd('/doability "'..mq.TLO.Spell("Razor Tongue Discipline").RankName()..'"')
			end
			if tarAggro and tarAggro < 100 and tarDistance < 20 then
				if mySelf.AltAbilityReady("Ageless Enmity")() then
					mq.cmd('/alt act 10367')
				elseif mySelf.AbilityReady("Taunt")() then
					mq.cmd('/doability Taunt')
				end
			end
			if mySelf.CombatAbilityReady(mq.TLO.Spell("Mortimus' Roar").RankName())() then
				mq.cmd('/doability "'..mq.TLO.Spell("Mortimus' Roar").RankName()..'"')
			end
			if mySelf.CombatAbilityReady(mq.TLO.Spell("Infuriate").RankName())() then
				mq.cmd('/doability "'..mq.TLO.Spell("Infuriate").RankName()..'"')
			end
			if mySelf.CombatAbilityReady(mq.TLO.Spell("Penumbral Precision").RankName())() and not mySelf.Buff("Penumbral Precision").ID() then
				mq.cmd('/doability "'..mq.TLO.Spell("Penumbral Precision").RankName()..'"')
			end
			if mySelf.AltAbilityReady("Gut Punch")() then
				mq.cmd('/alt act 3732')
			end
		end
		if classSettings.Melee_AOE_taunt == true then
			local i = 1
			while (mySelf.XTarget(i).ID() and mySelf.XTarget(i).ID() > 0) do
				if mySelf.XTarget(i).Type() == "NPC" and mySelf.XTarget(i).Distance() <= 40 and (mySelf.XTarget(i).PctAggro() ~= 100 or not mySelf.XTarget(i).PctAggro()) then
					if mySelf.CombatAbilityReady(mq.TLO.Spell("Wade into Conflict").RankName())() then
						mq.cmd('/doability "'..mq.TLO.Spell("Wade into Conflict").RankName()..'"')
					end
					if mySelf.CombatAbilityReady(mq.TLO.Spell("Spiraling Blades").RankName())() then
						mq.cmd('/doability "'..mq.TLO.Spell("Spiraling Blades").RankName()..'"')
						mq.delay(1000)
						break
					elseif mySelf.CombatAbilityReady("Rallying Roar")() then
						mq.cmd('/doability "Rallying Roar"')
						mq.delay(1000)
						break
					elseif mySelf.AltAbilityReady("Area Taunt")() then
						mq.cmd('/alt act 110')
						mq.delay(1000)
						break
					else 
						mq.cmd('/tar id '..mySelf.XTarget(i).ID())
						break
					end
				end
				i = i+1
			end	
			i = 1	
		end
		if classSettings.Melee_face == true then
			if tarID>=1 then
				mq.cmd('/Face')
			end
		end
		if classSettings.Melee_distance == true then
			if tarDistance then
				if tarDistance < 5 then
					mq.cmd('/keypress back hold')
					mq.delay(100)
					mq.cmd('/keypress back')
				end
				if tarDistance and tarDistance > 15 and tarDistance < 50 then
					mq.cmd('/nav target dist=15')
				end
			end
		end		
		if classSettings.Melee_OT_taunt == true then
			if mySelf.CombatAbilityReady(mq.TLO.Spell("Phantom Aggressor").RankName())() then
				mq.cmd('/doability "'..mq.TLO.Spell("Phantom Aggressor").RankName()..'"')
			end
			if mySelf.AltAbilityReady("Projection of Fury")() then
				mq.cmd('/alt act 3213')
			end
		end		
		if classSettings.Melee_snare == true then
			if mySelf.AltAbilityReady("Call of Challenge")() then
				mq.cmd('/alt act 552')
			end
			if mySelf.AltAbilityReady("Knee Strike")() then
				mq.cmd('/alt act 801')
			end
		end
		if classSettings.Melee_Sheol == true then
			if mySelf.AltAbilityReady("Wars Sheol's Heroic Blade")() then
				mq.cmd('/alt act 2007')
			end
		end
		if classSettings.Melee_rampage == true then
			if mySelf.AltAbilityReady("Rampage")() then
				mq.cmd('/alt act 109')
			end
		end
		if classSettings.Melee_Burn_always == true then
			if mySelf.AltAbilityReady("Spire of the Warlord")() then
				mq.cmd('/alt act 1400')
			end
			if mySelf.AltAbilityReady("Vehement Rage")() then
				mq.cmd('/alt act 800')
			end
			if mySelf.AltAbilityReady("Rage of Rallos Zek")() then
				mq.cmd('/alt act 131')
			end		
		end
		-- Disciplins:
		if classSettings.Defensive_disc_cycle == true then
			if mySelf.ActiveDisc.ID() == 66035 or mySelf.ActiveDisc.ID() == nil then
				if mySelf.CombatAbilityReady(mq.TLO.Spell("Climactic Stand").RankName())() then
					mq.cmd('/stopdisc')
					mq.cmd('/doability "'..mq.TLO.Spell("Climactic Stand").RankName()..'"')
				elseif mySelf.CombatAbilityReady(mq.TLO.Spell("Armor of Rallosian Runes").RankName())() then
					mq.cmd('/stopdisc')
					mq.cmd('/doability "'..mq.TLO.Spell("Armor of Rallosian Runes").RankName()..'"')
				elseif mySelf.CombatAbilityReady("Fortitude Discipline")() then
					mq.cmd('/stopdisc')
					mq.cmd('/doability "Fortitude Discipline"')
				end
			end
		end
		if classSettings.Offensive_disc_cycle == true then
			if mySelf.ActiveDisc.ID() == 66035 or mySelf.ActiveDisc.ID() == nil then
				if mySelf.CombatAbilityReady(mq.TLO.Spell("Brightfeld's Onslaught Discipline").RankName())() then
					mq.cmd('/stopdisc')
					mq.cmd('/doability "'..mq.TLO.Spell("Brightfeld's Onslaught Discipline").RankName()..'"')
				elseif mySelf.CombatAbilityReady("Mighty Strike Discipline")() then
					mq.cmd('/stopdisc')
					mq.cmd('/doability "Mighty Strike Discipline"')
				elseif mySelf.CombatAbilityReady("Weapon Affiliation")() then
					mq.cmd('/stopdisc')
					mq.cmd('/doability "Weapon Affiliation"')
				end
			end
		end
		if classSettings.Defensive_da == true then
			if mySelf.PctHPs() < 30 then
				if mySelf.CombatAbilityReady("Flash of Anger")() then
					mq.cmd('/doability "Flash of Anger"')
				elseif mySelf.ItemReady(mq.TLO.InvSlot('Chest').Item.Name())() then
					mq.cmd('/useitem '..mq.TLO.InvSlot('Chest').Item.Name())
				 elseif mySelf.AltAbilityReady("Armor of Experience")() then
					mq.cmd('/alt act 2000')
				end
			end
		end
		-- Buffs:
		if classSettings.Defensive_buffs == true then
			if not mySelf.Song("Commanding Voice").ID() then
				mq.cmd('/doability "Commanding Voice"')
			end	
			if not mySelf.Song("Field Bulwark").ID() then
				mq.cmd('/doability "'..mq.TLO.Spell("Field Bulwark").RankName()..'"')
			end
			if mySelf.AltAbilityReady("Imperator's Command")() and not mySelf.Song("Imperator's Command").ID() then
				mq.cmd('/alt act 2011')
			end
		end
		if classSettings.Offensive_buffs == true then
			if mySelf.AltAbilityReady("Battle Leap")() and not mySelf.Song("Battle Leap Warcry").ID() then
				mq.cmd('/alt act 611')
			end	
		end
		if classSettings.Defensive_buff_cycle == true then
			if classSettings.Defensive_disc_cycle == true then
				if mySelf.ActiveDisc.ID() == 66035 then
					if mySelf.AltAbilityReady("Blade Guardian")() then
						mq.cmd('/alt act 967')
					end
					if mySelf.AltAbilityReady("Brace For Impact")() then
						mq.cmd('/alt act 1686')
					end
					if mySelf.AltAbilityReady("Resplendent Glory")() then
						mq.cmd('/alt act 130')
					end
					if mySelf.AltAbilityReady("Warlord's Bravery")() then
						mq.cmd('/alt act 804')
					end
					if mySelf.AltAbilityReady("Warlord's Resurgence")() then
						mq.cmd('/alt act 911')
					end
					if mySelf.AltAbilityReady("Warlord's Tenacity")() then
						mq.cmd('/alt act 300')
					end
					if mySelf.AltAbilityReady("Resplendent Glory")() then
						mq.cmd('/alt act 130')
					end
				end
			else
				if mySelf.AltAbilityReady("Blade Guardian")() then
					mq.cmd('/alt act 967')
				end
				if mySelf.AltAbilityReady("Brace For Impact")() then
					mq.cmd('/alt act 1686')
				end
				if mySelf.AltAbilityReady("Resplendent Glory")() then
					mq.cmd('/alt act 130')
				end
				if mySelf.AltAbilityReady("Warlord's Bravery")() then
					mq.cmd('/alt act 804')
				end
				if mySelf.AltAbilityReady("Warlord's Resurgence")() then
					mq.cmd('/alt act 911')
				end
				if mySelf.AltAbilityReady("Warlord's Tenacity")() then
					mq.cmd('/alt act 300')
				end
				if mySelf.AltAbilityReady("Resplendent Glory")() then
					mq.cmd('/alt act 130')
				end
			end
		end
		
		if classSettings.Misc_epic1_5 == true then
			if not mySelf.Song("Krekk's Presence")() and mySelf.ItemReady("Champion's Sword of Eternal Power")() then 
				mq.cmd("/useitem Champion's Sword of Eternal Power")
			end
		end
		
		if classSettings.Misc_epic2_0 == true then
			if not mySelf.Song("Kreljnok's Fury")() and mySelf.ItemReady("Kreljnok's Sword of Eternal Power")() then 
				mq.cmd("/useitem Kreljnok's Sword of Eternal Power")				
			end
		end
		
		if classSettings.End_mana_buffs == true then
			if not mySelf.Song("Grace of Unity")() and not mySelf.Song("Blessing of Unity")() then 
				if mySelf.PctEndurance() < 95 then
					if mySelf.ItemReady('Unified Phoenix Feather')() then
						mq.cmd('/useitem Unified Phoenix Feather')
					elseif mySelf.ItemReady('Miniature Horn of Unity')() then
						mq.cmd('/useitem Miniature Horn of Unity')
					end
				end
			end
		end
			
		-- Monitor
		if classSettings.Misc_monitor_endurance == true then
			if mySelf.PctEndurance() < 10 and mySelf.CombatAbilityReady(mq.TLO.Spell("Convalesce").RankName())() then
				mq.cmd('/doability "'..mq.TLO.Spell("Convalesce").RankName()..'"')
			end
		end
		if classSettings.Misc_powersource == true then
			if mySelf.Inventory("powersource")() and mySelf.Inventory("powersource").PctPower() < 1 and powerSourceChecked <= os.time() then
				print("Powersource at 0%")
				mq.cmd('/beep')
				mq.cmd('/beep')
				powerSourceChecked = os.time()+10
			end
		end	
	
		-- Basic Melee
		if mySelf.CombatAbilityReady(mq.TLO.Spell("Vigorous Defense").RankName())() and not mySelf.ActiveDisc() then
			mq.cmd('/doability "'..mq.TLO.Spell("Vigorous Defense").RankName()..'"')
		end
		if mySelf.CombatAbilityReady(mq.TLO.Spell("Shield Rupture").RankName())() then
			mq.cmd('/doability "'..mq.TLO.Spell("Shield Rupture").RankName()..'"')
		end		
		if mySelf.AbilityReady("Disarm")() and tarDistance and tarDistance < 14 then
			mq.cmd('/doability Disarm')
		end	
	end
	--Out of Combat
	if not mySelf.Combat() and not mq.TLO.Navigation.Active() then
		if classSettings.Misc_aura == true then
			if not mq.TLO.Navigation.Active() and not mySelf.Moving() and not mySelf.Casting() and not mySelf.Aura() and not mySelf.Zoning() and not mySelf.Song("Champion's Aura Effect").ID() then
				mq.cmd('/doability "Champion\'s Aura"')
				mq.delay(100)
				while mySelf.Casting() do
					mq.delay(100)
					if mq.TLO.Navigation.Active() then 
						break
					end
				end
			end
		end	
	end
	if classSettings.Misc_monitor_food_drink == true then
		if mySelf.Hunger() <= 4000 then
			print('Eating!')
			mq.cmd('/useitem Misty Thicket Picnic')
			mq.delay(1000)
		end
		if mySelf.Thirst() <= 4000 then
			print('Drinking!')
			mq.cmd('/useitem Kaladim Constitutional')
			mq.delay(1000)
		end
	end
end

setup()
mq.imgui.init('MQ2LuaWar', buildWindow)
checkIni()

while keepAlive do
	if mq.TLO.Me.Class.ShortName()~='WAR' then
		os.exit()
	end
	if mq.TLO.Me.Zoning() then 
		mq.delay(1000)
	end
	CheckCombat()
	mq.delay(500)
end