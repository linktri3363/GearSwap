fixed_pos = ''
fixed_ts = os.time()
local no_interruptions = true
windower.raw_register_event('outgoing chunk',function(id,original,modified,injected,blocked)
    if no_interruptions and (not blocked) then
        if id == 0x15 then
            if (gearswap.cued_packet or midaction()) and fixed_pos ~= '' and os.time()-fixed_ts < 5 then
                return original:sub(1,4)..fixed_pos..original:sub(17)
            else
                fixed_pos = original:sub(5,16)
                fixed_ts = os.time()
            end
        end
    end
end)
register_unhandled_command(function (...)
    local commands = {...}
    if commands[1] and commands[1]:lower() == 'interrupts' then
        if (no_interruptions) then
            windower.add_to_chat(160, "%s : Disabling \30\2no_interruptions\30\43":format(_addon.name))
            no_interruptions = false
        else
            windower.add_to_chat(160, "%s : Enabling \30\2no_interruptions\30\43":format(_addon.name))
            no_interruptions = true
        end
        return true
    end
    return false
end)

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_job_setup()
	-- Options: Override default values
    state.OffenseMode:options('Normal','SomeAcc','Acc','FullAcc','Fodder')
    state.WeaponskillMode:options('Match','Normal','SomeAcc','Acc','FullAcc','Fodder')
    state.HybridMode:options('Normal')
    state.PhysicalDefenseMode:options('PDT', 'PDTReraise')
    state.MagicalDefenseMode:options('MDT', 'MDTReraise')
	state.ResistDefenseMode:options('MEVA')
	state.IdleMode:options('Normal', 'PDT','Refresh','Reraise')
    state.ExtraMeleeMode = M{['description']='Extra Melee Mode','None'}
	state.Weapons:options('Geirrothr','Areadbhar','Trishula','Naegling')
	state.Passive = M{['description'] = 'Passive Mode','None','MP','Twilight'}

    select_default_macro_book()
	
	-- Additional local binds
	send_command('bind ^` input /ja "Hasso" <me>')
	send_command('bind !` input /ja "Seigan" <me>')
	send_command('bind ^f11 gs c cycle MagicalDefenseMode')
	send_command('bind @f7 gs c toggle AutoJumpMode')
	send_command('bind @` gs c cycle SkillchainMode')
end

-- Define sets and vars used by this job file.
function init_gear_sets()
	--------------------------------------
	-- Start defining the sets
	--------------------------------------
	
	-- Precast Sets
	-- Precast sets to enhance JAs
	sets.precast.JA.Angon = {ammo="Angon",hands="Ptero. Fin. G. +1"}
	sets.precast.JA.Jump = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head="Peltast's Mezail +2",neck="Anu Torque",ear1="Sherida Earring",ear2={ name="Pel. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Crit.hit rate+5',}},
		body={ name="Gleti's Cuirass", augments={'Path: A',}},hands={ name="Gleti's Gauntlets", augments={'Path: A',}},ring1="Chirich Ring +1",ring2="Niqmaddu Ring",
		back="Brigantia's Mantle",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs="Pelt. Cuissots +2",feet={ name="Gleti's Boots", augments={'Path: A',}}}
	sets.precast.JA['Ancient Circle'] = {legs="Pelt. Cuissots +2"}
	sets.precast.JA['High Jump'] = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head="Peltast's Mezail +2",neck="Anu Torque",ear1="Sherida Earring",ear2={ name="Pel. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Crit.hit rate+5',}},
		body={ name="Gleti's Cuirass", augments={'Path: A',}},hands={ name="Gleti's Gauntlets", augments={'Path: A',}},ring1="Chirich Ring +1",ring2="Niqmaddu Ring",
		back="Brigantia's Mantle",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs="Pelt. Cuissots +2",feet={ name="Gleti's Boots", augments={'Path: A',}}}
	sets.precast.JA['Soul Jump'] = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head="Peltast's Mezail +2",neck="Anu Torque",ear1="Sherida Earring",ear2={ name="Pel. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Crit.hit rate+5',}},
		body="Pelt. Plackart +2",hands="Pel. Vambraces +2",ring1="Chirich Ring +1",ring2="Niqmaddu Ring",
		back="Brigantia's Mantle",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs="Pelt. Cuissots +2",feet="Pelt. Schyn. +2"}
	sets.precast.JA['Spirit Jump'] = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head="Peltast's Mezail +2",neck="Anu Torque",ear1="Sherida Earring",ear2={ name="Pel. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Crit.hit rate+5',}},
		body={ name="Gleti's Cuirass", augments={'Path: A',}},hands={ name="Gleti's Gauntlets", augments={'Path: A',}},ring1="Chirich Ring +1",ring2="Niqmaddu Ring",
		back="Brigantia's Mantle",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs="Pelt. Cuissots +2",feet="Pelt. Schyn. +2"}
	sets.precast.JA['Super Jump'] = {}
	sets.precast.JA['Spirit Link'] = {head="Peltast's Mezail +2"}
	sets.precast.JA['Call Wyvern'] = {body="Pelt. Plackart +2"}
	sets.precast.JA['Deep Breathing'] = {head="Peltast's Mezail +2"}
	sets.precast.JA['Spirit Surge'] = {body="Pelt. Plackart +2"}
	sets.precast.JA['Steady Wing'] = {}
	
	-- Breath sets
	sets.precast.JA['Restoring Breath'] = {back="Brigantia's Mantle",head="Peltast's Mezail +2"}
	sets.precast.JA['Smiting Breath'] = {back="Brigantia's Mantle",head="Peltast's Mezail +2"}
	sets.HealingBreath = {back="Brigantia's Mantle",head="Peltast's Mezail +2"}

	-- Fast cast sets for spells
	
	sets.precast.FC = {ammo="Impatiens",
		head="Carmine Mask +1",neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Loquac. Earring",
		body=gear.taeon_pet_body,hands="Leyline Gloves",ring1="Lebeche Ring",ring2="Prolix Ring",
		back="Moonlight Cape",waist="Flume Belt +1",legs="Founder's Hose",feet="Carmine Greaves +1"}
	
	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}
		
	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = {}

	sets.midcast.Cure = {}
	
	sets.Self_Healing = {neck="Phalaina Locket",hands="Buremte Gloves",ring2="Kunaji Ring",waist="Gishdubar Sash"}
	sets.Cure_Received = {neck="Phalaina Locket",hands="Buremte Gloves",ring2="Kunaji Ring",waist="Gishdubar Sash"}
	sets.Self_Refresh = {waist="Gishdubar Sash"}
	
	-- Midcast Sets
	sets.midcast.FastRecast = {ammo="Staunch Tathlum +1",
		head="Carmine Mask +1",neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Loquac. Earring",
		body=gear.taeon_pet_body,hands="Leyline Gloves",ring1="Lebeche Ring",ring2="Prolix Ring",
		back="Moonlight Cape",waist="Tempus Fugit",legs="Founder's Hose",feet="Carmine Greaves +1"}
		
	-- Put HP+ gear and the AF head to make healing breath trigger more easily with this set.
	sets.midcast.HB_Trigger = set_combine(sets.midcast.FastRecast, {head="Peltast's Mezail +2"})
	
	-- Weaponskill sets

	-- Default set for any weaponskill that isn't any more specifically defined
	-- Using Nyame for WSD bonus (Path B augments)
	sets.precast.WS = {ammo="Knobkierrie",
		head={ name="Nyame Helm", augments={'Path: B',}},neck="Fotia Gorget",ear1={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},ear2={ name="Pel. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Crit.hit rate+5',}},
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Ephramad's Ring",ring2="Niqmaddu Ring",
		back="Brigantia's Mantle",waist="Fotia Belt",legs={ name="Nyame Flanchard", augments={'Path: B',}},feet={ name="Nyame Sollerets", augments={'Path: B',}}}
		
	sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {})
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {neck="Shulmanu Collar"})
	sets.precast.WS.FullAcc = set_combine(sets.precast.WS, {neck="Shulmanu Collar"})
	sets.precast.WS.Fodder = set_combine(sets.precast.WS, {})
	
	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
	-- Stardiver - Multi-hit WS, benefits from fTP bonus and DA
	sets.precast.WS['Stardiver'] = set_combine(sets.precast.WS, {
		head={ name="Nyame Helm", augments={'Path: B',}},
		body={ name="Gleti's Cuirass", augments={'Path: A',}},
		hands={ name="Gleti's Gauntlets", augments={'Path: A',}},
		legs={ name="Gleti's Breeches", augments={'Path: A',}},
		feet={ name="Nyame Sollerets", augments={'Path: B',}}})
	sets.precast.WS['Stardiver'].SomeAcc = set_combine(sets.precast.WS['Stardiver'], {})
	sets.precast.WS['Stardiver'].Acc = set_combine(sets.precast.WS['Stardiver'], {neck="Shulmanu Collar"})
	sets.precast.WS['Stardiver'].Fodder = set_combine(sets.precast.WS['Stardiver'], {})

	-- Drakesbane - Crit-based WS
	sets.precast.WS['Drakesbane'] = set_combine(sets.precast.WS, {
		head={ name="Gleti's Mask", augments={'Path: A',}},
		body="Hjarrandi Breast.",
		hands={ name="Gleti's Gauntlets", augments={'Path: A',}},
		legs={ name="Gleti's Breeches", augments={'Path: A',}},
		feet={ name="Gleti's Boots", augments={'Path: A',}}})
	sets.precast.WS['Drakesbane'].SomeAcc = set_combine(sets.precast.WS['Drakesbane'], {})
	sets.precast.WS['Drakesbane'].Acc = set_combine(sets.precast.WS['Drakesbane'], {neck="Shulmanu Collar"})
	sets.precast.WS['Drakesbane'].Fodder = set_combine(sets.precast.WS['Drakesbane'], {})

	-- Camlann's Torment - Single hit WS, pure WSD
	sets.precast.WS["Camlann's Torment"] = set_combine(sets.precast.WS, {
		ear2="Ishvara Earring"})
	
	-- Impulse Drive - 2-hit WS
	sets.precast.WS['Impulse Drive'] = set_combine(sets.precast.WS, {})

	-- Savage Blade for Naegling
	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
		neck="Rep. Plat. Medal",
		waist={ name="Sailfi Belt +1", augments={'Path: A',}}})

	
	-- Sets to return to when not performing an action.
	
	-- Resting sets
	sets.resting = {}

	-- Idle sets - Updated with Nyame, Murky Ring, Alabaster Earring
	sets.idle = {ammo="Staunch Tathlum +1",
		head={ name="Nyame Helm", augments={'Path: B',}},neck={ name="Loricate Torque +1", augments={'Path: A',}},ear1={ name="Alabaster Earring", augments={'Path: A',}},ear2="Ethereal Earring",
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Defending Ring",ring2={ name="Murky Ring", augments={'Path: A',}},
		back="Moonlight Cape",waist="Flume Belt +1",legs="Carmine Cuisses +1",feet={ name="Nyame Sollerets", augments={'Path: B',}}}
		
	sets.idle.Refresh = {ammo="Staunch Tathlum +1",
		head={ name="Nyame Helm", augments={'Path: B',}},neck={ name="Loricate Torque +1", augments={'Path: A',}},ear1={ name="Alabaster Earring", augments={'Path: A',}},ear2="Ethereal Earring",
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Defending Ring",ring2={ name="Murky Ring", augments={'Path: A',}},
		back="Moonlight Cape",waist="Flume Belt +1",legs="Carmine Cuisses +1",feet={ name="Nyame Sollerets", augments={'Path: B',}}}

	sets.idle.Weak = set_combine(sets.idle, {head="Twilight Helm",body="Twilight Mail"})
		
	sets.idle.Reraise = set_combine(sets.idle, {head="Twilight Helm",body="Twilight Mail"})
	
	-- Defense sets - Updated with better DT gear
	sets.defense.PDT = {ammo="Staunch Tathlum +1",
		head={ name="Nyame Helm", augments={'Path: B',}},neck={ name="Loricate Torque +1", augments={'Path: A',}},ear1={ name="Alabaster Earring", augments={'Path: A',}},ear2={ name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%',}},
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Defending Ring",ring2={ name="Murky Ring", augments={'Path: A',}},
		back="Moonlight Cape",waist="Flume Belt +1",legs={ name="Nyame Flanchard", augments={'Path: B',}},feet={ name="Nyame Sollerets", augments={'Path: B',}}}
		
	sets.defense.PDTReraise = set_combine(sets.defense.PDT, {head="Twilight Helm",body="Twilight Mail"})

	sets.defense.MDT = {ammo="Staunch Tathlum +1",
		head={ name="Nyame Helm", augments={'Path: B',}},neck="Warder's Charm +1",ear1={ name="Alabaster Earring", augments={'Path: A',}},ear2={ name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%',}},
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Defending Ring",ring2={ name="Murky Ring", augments={'Path: A',}},
		back="Moonlight Cape",waist="Flume Belt +1",legs={ name="Nyame Flanchard", augments={'Path: B',}},feet={ name="Nyame Sollerets", augments={'Path: B',}}}
		
	sets.defense.MDTReraise = set_combine(sets.defense.MDT, {head="Twilight Helm",body="Twilight Mail"})
		
	sets.defense.MEVA = {ammo="Staunch Tathlum +1",
		head={ name="Nyame Helm", augments={'Path: B',}},neck="Warder's Charm +1",ear1={ name="Alabaster Earring", augments={'Path: A',}},ear2={ name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%',}},
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Defending Ring",ring2={ name="Murky Ring", augments={'Path: A',}},
		back="Moonlight Cape",waist="Flume Belt +1",legs={ name="Nyame Flanchard", augments={'Path: B',}},feet={ name="Nyame Sollerets", augments={'Path: B',}}}

	sets.Kiting = {ring2="Shneddick Ring +1"}
	sets.Reraise = {head="Twilight Helm",body="Twilight Mail"}
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = {head="Frenzy Sallet"}
	
    -- Extra defense sets.  Apply these on top of melee or defense sets.
    sets.passive.MP = {ear2="Ethereal Earring",waist="Flume Belt +1"}
    sets.passive.Twilight = {head="Twilight Helm", body="Twilight Mail"}
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
	
	-- Weapons sets - Geirrothr is highest DMG with Haste/Crit, Areadbhar for STP/skill
	sets.weapons.Geirrothr = {main="Geirrothr",sub="Utu Grip"}
	sets.weapons.Areadbhar = {main="Areadbhar",sub="Utu Grip"}
	sets.weapons.Trishula = {main="Trishula",sub="Utu Grip"}
	sets.weapons.Naegling = {main="Naegling",sub=""}

	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {ear1="Brutal Earring",ear2="Sherida Earring"}
	sets.AccMaxTP = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.AccDayMaxTPWSEars = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.DayMaxTPWSEars = {ear1="Brutal Earring",ear2="Sherida Earring"}
	sets.AccDayWSEars = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.DayWSEars = {ear1={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},ear2="Sherida Earring"}
	
	-- Engaged sets

	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.engaged.Dagger.Accuracy.Evasion
	
	-- Normal melee group - Updated with Coiste Bodhar, Gleti gear, Sailfi Belt

	sets.engaged = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Gleti's Mask", augments={'Path: A',}},neck="Anu Torque",ear1="Sherida Earring",ear2="Brutal Earring",
		body={ name="Gleti's Cuirass", augments={'Path: A',}},hands={ name="Gleti's Gauntlets", augments={'Path: A',}},ring1="Chirich Ring +1",ring2="Niqmaddu Ring",
		back="Brigantia's Mantle",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs={ name="Gleti's Breeches", augments={'Path: A',}},feet={ name="Gleti's Boots", augments={'Path: A',}}}
    sets.engaged.SomeAcc = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Gleti's Mask", augments={'Path: A',}},neck="Shulmanu Collar",ear1="Sherida Earring",ear2="Telos Earring",
		body={ name="Gleti's Cuirass", augments={'Path: A',}},hands={ name="Gleti's Gauntlets", augments={'Path: A',}},ring1="Chirich Ring +1",ring2="Niqmaddu Ring",
		back="Brigantia's Mantle",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs={ name="Gleti's Breeches", augments={'Path: A',}},feet={ name="Gleti's Boots", augments={'Path: A',}}}
	sets.engaged.Acc = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Gleti's Mask", augments={'Path: A',}},neck="Shulmanu Collar",ear1="Telos Earring",ear2="Mache Earring +1",
		body={ name="Gleti's Cuirass", augments={'Path: A',}},hands={ name="Gleti's Gauntlets", augments={'Path: A',}},ring1="Chirich Ring +1",ring2="Niqmaddu Ring",
		back="Brigantia's Mantle",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs={ name="Gleti's Breeches", augments={'Path: A',}},feet={ name="Gleti's Boots", augments={'Path: A',}}}
    sets.engaged.FullAcc = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Gleti's Mask", augments={'Path: A',}},neck="Shulmanu Collar",ear1="Mache Earring +1",ear2="Telos Earring",
		body={ name="Gleti's Cuirass", augments={'Path: A',}},hands={ name="Gleti's Gauntlets", augments={'Path: A',}},ring1="Chirich Ring +1",ring2="Chirich Ring +1",
		back="Brigantia's Mantle",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs={ name="Gleti's Breeches", augments={'Path: A',}},feet={ name="Gleti's Boots", augments={'Path: A',}}}
    sets.engaged.Fodder = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Gleti's Mask", augments={'Path: A',}},neck="Anu Torque",ear1="Sherida Earring",ear2="Brutal Earring",
		body={ name="Gleti's Cuirass", augments={'Path: A',}},hands={ name="Gleti's Gauntlets", augments={'Path: A',}},ring1="Chirich Ring +1",ring2="Niqmaddu Ring",
		back="Brigantia's Mantle",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs={ name="Gleti's Breeches", augments={'Path: A',}},feet={ name="Gleti's Boots", augments={'Path: A',}}}

    sets.engaged.AM = {}
    sets.engaged.AM.SomeAcc = {}
	sets.engaged.AM.Acc = {}
    sets.engaged.AM.FullAcc = {}
    sets.engaged.AM.Fodder = {}
	
	-- PDT Hybrid sets - mixing offense with defense
    sets.engaged.PDT = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Nyame Helm", augments={'Path: B',}},neck={ name="Loricate Torque +1", augments={'Path: A',}},ear1={ name="Alabaster Earring", augments={'Path: A',}},ear2="Sherida Earring",
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Defending Ring",ring2="Niqmaddu Ring",
		back="Moonlight Cape",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs={ name="Nyame Flanchard", augments={'Path: B',}},feet={ name="Nyame Sollerets", augments={'Path: B',}}}
    sets.engaged.SomeAcc.PDT = set_combine(sets.engaged.PDT, {})
	sets.engaged.Acc.PDT = set_combine(sets.engaged.PDT, {neck="Shulmanu Collar"})
    sets.engaged.FullAcc.PDT = set_combine(sets.engaged.PDT, {neck="Shulmanu Collar"})
    sets.engaged.Fodder.PDT = set_combine(sets.engaged.PDT, {})
	
    sets.engaged.AM.PDT = {}
    sets.engaged.AM.SomeAcc.PDT = {}
	sets.engaged.AM.Acc.PDT = {}
    sets.engaged.AM.FullAcc.PDT = {}
    sets.engaged.AM.Fodder.PDT = {}

end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'WAR' then
        set_macro_page(1, 14)
    elseif player.sub_job == 'SAM' then
        set_macro_page(1, 14)
    elseif player.sub_job == 'BLU' then
        set_macro_page(1, 14)
    else
        set_macro_page(1, 14)
    end
end