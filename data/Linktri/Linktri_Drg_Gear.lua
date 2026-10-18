-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_job_setup()
	-- Options: Override default values
    state.OffenseMode:options('Normal','SomeAcc','Acc','FullAcc','Fodder')
    state.WeaponskillMode:options('Match','Normal','SomeAcc','Acc','FullAcc','Fodder')
    state.HybridMode:options('Normal','PDT') -- original: 'Normal' only (PDT hybrid sets were unreachable)
    state.PhysicalDefenseMode:options('PDT', 'PDTReraise')
    state.MagicalDefenseMode:options('MDT', 'MDTReraise')
	state.ResistDefenseMode:options('MEVA')
	state.IdleMode:options('Normal', 'PDT','Refresh','Reraise')
    state.ExtraMeleeMode = M{['description']='Extra Melee Mode','None'}
	state.Weapons:options('Geirrothr','Areadbhar','ShiningOne','Naegling') -- original: 'Geirrothr','Areadbhar','Trishula','Naegling' (Trishula not owned)
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
	sets.precast.JA.Angon = {ammo="Angon"} -- original: hands="Ptero. Fin. G. +1" (not owned); Angon ammo is the consumable, equips if carried
	sets.precast.JA.Jump = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head="Peltast's Mezail +3",neck="Anu Torque",ear1="Sherida Earring",ear2={ name="Pel. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Crit.hit rate+5',}},
		body="Vishap Mail +1",hands="Vishap F. G. +1",ring1="Chirich Ring +1",ring2="Hetairoi Ring",
		back="Null Shawl",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs="Pelt. Cuissots +3",feet="Vishap Greaves +1"}
		-- original: head="Peltast's Mezail +2", body/hands/feet=Gleti's (owned, swapped for Jump TP+35/TP+30/Attack+22%), ring2="Niqmaddu Ring" (not owned), back="Brigantia's Mantle" (not owned), legs="Pelt. Cuissots +2"
	sets.precast.JA['Ancient Circle'] = {legs="Vishap Brais +1"} -- original: legs="Pelt. Cuissots +2" (Vishap Brais +1 is the Ancient Circle+1 piece)
	sets.precast.JA['High Jump'] = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head="Peltast's Mezail +3",neck="Anu Torque",ear1="Sherida Earring",ear2={ name="Pel. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Crit.hit rate+5',}},
		body="Vishap Mail +1",hands="Vishap F. G. +1",ring1="Chirich Ring +1",ring2="Hetairoi Ring",
		back="Null Shawl",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs="Pelt. Cuissots +3",feet="Vishap Greaves +1"}
		-- original: head="Peltast's Mezail +2", body/hands/feet=Gleti's (owned, swapped for Jump TP+35/TP+30/Attack+22%), ring2="Niqmaddu Ring" (not owned), back="Brigantia's Mantle" (not owned), legs="Pelt. Cuissots +2"
	sets.precast.JA['Soul Jump'] = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head="Peltast's Mezail +3",neck="Anu Torque",ear1="Sherida Earring",ear2={ name="Pel. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Crit.hit rate+5',}},
		body="Vishap Mail +1",hands="Pel. Vambraces +3",ring1="Chirich Ring +1",ring2="Hetairoi Ring",
		back="Null Shawl",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs="Pelt. Cuissots +3",feet="Vishap Greaves +1"}
		-- original: head="Peltast's Mezail +2", body="Pelt. Plackart +2", hands="Pel. Vambraces +2", ring2="Niqmaddu Ring" (not owned), back="Brigantia's Mantle" (not owned), legs="Pelt. Cuissots +2", feet="Pelt. Schyn. +2"
	sets.precast.JA['Spirit Jump'] = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head="Peltast's Mezail +3",neck="Anu Torque",ear1="Sherida Earring",ear2={ name="Pel. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Crit.hit rate+5',}},
		body="Vishap Mail +1",hands="Vishap F. G. +1",ring1="Chirich Ring +1",ring2="Hetairoi Ring",
		back="Null Shawl",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs="Pelt. Cuissots +3",feet="Pelt. Schyn. +3"}
		-- original: head="Peltast's Mezail +2", body/hands=Gleti's (owned, swapped for Jump TP+35/TP+30), ring2="Niqmaddu Ring" (not owned), back="Brigantia's Mantle" (not owned), legs="Pelt. Cuissots +2", feet="Pelt. Schyn. +2"
	sets.precast.JA['Super Jump'] = {}
	sets.precast.JA['Spirit Link'] = {head="Vishap Armet +1",hands="Pel. Vambraces +3"} -- original: head="Peltast's Mezail +2" (Armet +1 Spirit Link+12, Vambraces +3 Spirit Link+16%)
	sets.precast.JA['Call Wyvern'] = {body="Pelt. Plackart +3"} -- original: body="Pelt. Plackart +2"
	sets.precast.JA['Deep Breathing'] = {head="Peltast's Mezail +3"} -- original: head="Peltast's Mezail +2"
	sets.precast.JA['Spirit Surge'] = {body="Pelt. Plackart +3"} -- original: body="Pelt. Plackart +2"
	sets.precast.JA['Steady Wing'] = {}
	
	-- Breath sets
	sets.precast.JA['Restoring Breath'] = {back="Updraft Mantle",head="Peltast's Mezail +3"} -- original: back="Brigantia's Mantle" (not owned), head="Peltast's Mezail +2"
	sets.precast.JA['Smiting Breath'] = {back="Updraft Mantle",head="Peltast's Mezail +3"} -- original: back="Brigantia's Mantle" (not owned), head="Peltast's Mezail +2"
	sets.HealingBreath = {back="Updraft Mantle",head="Peltast's Mezail +3"} -- original: back="Brigantia's Mantle" (not owned), head="Peltast's Mezail +2"

	-- Fast cast sets for spells
	
	sets.precast.FC = {ammo="Impatiens",
		head="Null Masque",neck="Voltsurge Torque",ear1="Etiolation Earring",ear2={ name="Alabaster Earring", augments={'Path: A',}},
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Lebeche Ring",ring2="Defending Ring",
		back="Null Shawl",waist="Null Belt",legs="Limbo Trousers",feet={ name="Nyame Sollerets", augments={'Path: B',}}}
		-- original (not owned): head="Carmine Mask +1", ear1="Enchntr. Earring +1", ear2="Loquac. Earring" (stored), body=gear.taeon_pet_body (undefined), hands="Leyline Gloves",
		--   ring2="Prolix Ring", back="Moonlight Cape", waist="Flume Belt +1", legs="Founder's Hose", feet="Carmine Greaves +1"
	
	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}
		
	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = {}

	sets.midcast.Cure = {}
	
	-- original (none owned): {neck="Phalaina Locket",hands="Buremte Gloves",ring2="Kunaji Ring",waist="Gishdubar Sash"}; Self_Refresh {waist="Gishdubar Sash"}
	sets.Self_Healing = {}
	sets.Cure_Received = {}
	sets.Self_Refresh = {}
	
	-- Midcast Sets
	sets.midcast.FastRecast = {ammo="Staunch Tathlum +1",
		head="Null Masque",neck="Voltsurge Torque",ear1="Etiolation Earring",ear2={ name="Alabaster Earring", augments={'Path: A',}},
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Lebeche Ring",ring2="Defending Ring",
		back="Null Shawl",waist="Null Belt",legs="Limbo Trousers",feet={ name="Nyame Sollerets", augments={'Path: B',}}}
		-- original (not owned): head="Carmine Mask +1", ear1="Enchntr. Earring +1", ear2="Loquac. Earring" (stored), body=gear.taeon_pet_body (undefined), hands="Leyline Gloves",
		--   ring2="Prolix Ring", back="Moonlight Cape", waist="Tempus Fugit", legs="Founder's Hose", feet="Carmine Greaves +1"
		
	-- Put HP+ gear and the AF head to make healing breath trigger more easily with this set.
	sets.midcast.HB_Trigger = set_combine(sets.midcast.FastRecast, {head="Peltast's Mezail +3"}) -- original: head="Peltast's Mezail +2"
	
	-- Weaponskill sets

	-- Default set for any weaponskill that isn't any more specifically defined
	-- Using Nyame for WSD bonus (Path B augments)
	sets.precast.WS = {ammo="Knobkierrie",
		head="Peltast's Mezail +3",neck="Shulmanu Collar",ear1={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},ear2={ name="Pel. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Crit.hit rate+5',}},
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Ephramad's Ring",ring2={ name="Beithir Ring", augments={'Path: A',}},
		back="Null Shawl",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs={ name="Nyame Flanchard", augments={'Path: B',}},feet={ name="Nyame Sollerets", augments={'Path: B',}}}
		-- original: head=Nyame Helm (owned; Mezail +3 is WSD+12/Atk+71), neck="Fotia Gorget", ring2="Niqmaddu Ring", back="Brigantia's Mantle", waist="Fotia Belt" (all not owned)
		
	sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {})
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {neck="Shulmanu Collar"})
	sets.precast.WS.FullAcc = set_combine(sets.precast.WS, {neck="Shulmanu Collar"})
	sets.precast.WS.Fodder = set_combine(sets.precast.WS, {})
	
	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
	-- Stardiver - Multi-hit WS, benefits from fTP bonus and DA
	-- Gleti's R30: each piece Attack+70/Acc+55 and PDL; Cuirass DA+10%, Breeches TA+5%, Boots STR+5
	sets.precast.WS['Stardiver'] = set_combine(sets.precast.WS, {
		head="Peltast's Mezail +3",
		body={ name="Gleti's Cuirass", augments={'Path: A',}},
		hands={ name="Gleti's Gauntlets", augments={'Path: A',}},
		legs={ name="Gleti's Breeches", augments={'Path: A',}},
		feet={ name="Gleti's Boots", augments={'Path: A',}}})
		-- original: head=Nyame Helm, feet=Nyame Sollerets (owned; Mezail +3 Atk+71/WSD+12, Gleti's Boots R30 Atk+70/PDL+5 for a 4-hit WS)
	sets.precast.WS['Stardiver'].SomeAcc = set_combine(sets.precast.WS['Stardiver'], {})
	sets.precast.WS['Stardiver'].Acc = set_combine(sets.precast.WS['Stardiver'], {neck="Shulmanu Collar"})
	sets.precast.WS['Stardiver'].Fodder = set_combine(sets.precast.WS['Stardiver'], {})

	-- Drakesbane - Crit-based WS
	sets.precast.WS['Drakesbane'] = set_combine(sets.precast.WS, {
		head={ name="Gleti's Mask", augments={'Path: A',}},
		body="Hjarrandi Breast.",
		hands={ name="Gleti's Gauntlets", augments={'Path: A',}},
		legs="Pelt. Cuissots +3",
		feet={ name="Gleti's Boots", augments={'Path: A',}}})
		-- original: legs=Gleti's Breeches (owned; Cuissots +3 trade crit rate 7% for crit damage +13% and DT-13%)
		-- Hjarrandi kept over Gleti's Cuirass R30: crit +13% vs +8%, and crit rate is what Drakesbane scales on
	sets.precast.WS['Drakesbane'].SomeAcc = set_combine(sets.precast.WS['Drakesbane'], {})
	sets.precast.WS['Drakesbane'].Acc = set_combine(sets.precast.WS['Drakesbane'], {neck="Shulmanu Collar"})
	sets.precast.WS['Drakesbane'].Fodder = set_combine(sets.precast.WS['Drakesbane'], {})

	-- Camlann's Torment - Single hit WS, pure WSD
	sets.precast.WS["Camlann's Torment"] = set_combine(sets.precast.WS, {
		ear2="Ishvara Earring",back="Updraft Mantle"}) -- single hit: Attack+20 back over Null Shawl's DA
	
	-- Impulse Drive - 2-hit WS
	-- Impulse Drive: Shining One adds crit rate based on TP spent (plus Impulse Drive damage +40%),
	-- so it uses the Drakesbane crit set. original: set_combine(sets.precast.WS, {})
	sets.precast.WS['Impulse Drive'] = set_combine(sets.precast.WS['Drakesbane'], {})
	sets.precast.WS['Impulse Drive'].SomeAcc = set_combine(sets.precast.WS['Drakesbane'].SomeAcc, {})
	sets.precast.WS['Impulse Drive'].Acc = set_combine(sets.precast.WS['Drakesbane'].Acc, {})
	sets.precast.WS['Impulse Drive'].Fodder = set_combine(sets.precast.WS['Drakesbane'].Fodder, {})

	-- Savage Blade for Naegling
	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
		neck="Shulmanu Collar", -- original: neck="Rep. Plat. Medal" (not owned)
		waist={ name="Sailfi Belt +1", augments={'Path: A',}}})

	
	-- Sets to return to when not performing an action.
	
	-- Resting sets
	sets.resting = {}

	-- Idle sets - Updated with Nyame, Murky Ring, Alabaster Earring
	sets.idle = {ammo="Staunch Tathlum +1",
		head="Null Masque",neck={ name="Loricate Torque +1", augments={'Path: A',}},ear1={ name="Alabaster Earring", augments={'Path: A',}},ear2={ name="Odnowa Earring +1", augments={'Path: A',}},
		body={ name="Nyame Mail", augments={'Path: B',}},hands="Pel. Vambraces +3",ring1="Defending Ring",ring2="Shneddick Ring +1",
		back="Null Shawl",waist="Null Belt",legs="Pelt. Cuissots +3",feet="Pelt. Schyn. +3"}
		-- DT-75% (cap is 50%): Null Masque 10, Loricate 6, Alabaster 5, Nyame Mail 9, Vambraces 11, Defending 10, Cuissots 13, Schyn. 11
		-- Peltast's +3 hands/legs/feet are DT11/13/11 vs Nyame 7/8/7; the extra DT frees ring2 for Shneddick (movement speed, replaces Carmine Cuisses' role)
		-- original: head=Nyame Helm, hands/legs/feet=Nyame (owned), ring2=Murky Ring (owned), ear2="Ethereal Earring", back="Moonlight Cape", waist="Flume Belt +1", legs="Carmine Cuisses +1" (not owned)
		
	sets.idle.Refresh = {ammo="Staunch Tathlum +1",
		head="Null Masque",neck={ name="Loricate Torque +1", augments={'Path: A',}},ear1={ name="Alabaster Earring", augments={'Path: A',}},ear2={ name="Odnowa Earring +1", augments={'Path: A',}},
		body={ name="Nyame Mail", augments={'Path: B',}},hands="Pel. Vambraces +3",ring1="Defending Ring",ring2="Shneddick Ring +1",
		back="Null Shawl",waist="Null Belt",legs="Pelt. Cuissots +3",feet="Pelt. Schyn. +3"}
		-- DT-75% (cap is 50%): Null Masque 10, Loricate 6, Alabaster 5, Nyame Mail 9, Vambraces 11, Defending 10, Cuissots 13, Schyn. 11
		-- Peltast's +3 hands/legs/feet are DT11/13/11 vs Nyame 7/8/7; the extra DT frees ring2 for Shneddick (movement speed, replaces Carmine Cuisses' role)
		-- original: head=Nyame Helm, hands/legs/feet=Nyame (owned), ring2=Murky Ring (owned), ear2="Ethereal Earring", back="Moonlight Cape", waist="Flume Belt +1", legs="Carmine Cuisses +1" (not owned)

	-- Twilight Helm/Mail are not owned; these sets fall back to the idle/defense gear until you get them
	-- LINKTRI: Weakness set commented out (2026-10-17). Without it, Sel uses your normal idle set while weakened.
	-- To restore, uncomment the lines below; Sel-Include equips sets.idle.Weak automatically when it exists.
	-- sets.idle.Weak = set_combine(sets.idle, {head="Twilight Helm",body="Twilight Mail"})
		
	sets.idle.Reraise = set_combine(sets.idle, {head="Twilight Helm",body="Twilight Mail"})
	
	-- Defense sets - Updated with better DT gear
	sets.defense.PDT = {ammo="Staunch Tathlum +1",
		head={ name="Nyame Helm", augments={'Path: B',}},neck={ name="Loricate Torque +1", augments={'Path: A',}},ear1={ name="Alabaster Earring", augments={'Path: A',}},ear2={ name="Odnowa Earring +1", augments={'Path: A',}},
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Defending Ring",ring2={ name="Murky Ring", augments={'Path: A',}},
		back="Null Shawl",waist="Null Belt",legs={ name="Nyame Flanchard", augments={'Path: B',}},feet={ name="Nyame Sollerets", augments={'Path: B',}}}
		-- original: ear2="Chev. Earring +1" (not DRG-equippable), back="Moonlight Cape", waist="Flume Belt +1" (not owned)
		
	sets.defense.PDTReraise = set_combine(sets.defense.PDT, {head="Twilight Helm",body="Twilight Mail"})

	-- MDT/MEVA original: neck="Warder's Charm +1" (not owned)
	sets.defense.MDT = {ammo="Staunch Tathlum +1",
		head={ name="Nyame Helm", augments={'Path: B',}},neck="Null Loop",ear1={ name="Alabaster Earring", augments={'Path: A',}},ear2={ name="Odnowa Earring +1", augments={'Path: A',}},
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Defending Ring",ring2={ name="Murky Ring", augments={'Path: A',}},
		back="Null Shawl",waist="Null Belt",legs={ name="Nyame Flanchard", augments={'Path: B',}},feet={ name="Nyame Sollerets", augments={'Path: B',}}}
		-- original: ear2="Chev. Earring +1" (not DRG-equippable), back="Moonlight Cape", waist="Flume Belt +1" (not owned)
		
	sets.defense.MDTReraise = set_combine(sets.defense.MDT, {head="Twilight Helm",body="Twilight Mail"})
		
	sets.defense.MEVA = {ammo="Staunch Tathlum +1",
		head={ name="Nyame Helm", augments={'Path: B',}},neck="Null Loop",ear1={ name="Alabaster Earring", augments={'Path: A',}},ear2={ name="Odnowa Earring +1", augments={'Path: A',}},
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Defending Ring",ring2={ name="Murky Ring", augments={'Path: A',}},
		back="Null Shawl",waist="Null Belt",legs={ name="Nyame Flanchard", augments={'Path: B',}},feet={ name="Nyame Sollerets", augments={'Path: B',}}}
		-- original: ear2="Chev. Earring +1" (not DRG-equippable), back="Moonlight Cape", waist="Flume Belt +1" (not owned)

	-- LINKTRI: PorterPacker packing-safe set (same approach as WHM/BST). Equipped while idle within 6 yalms of a
	-- Porter Moogle so nothing on the PorterPacker DRG list (Peltast's +3, Vishap +1, Sulevia's +2, Flamma +2, ...)
	-- is being worn when it gets packed. Only non-slip gear here; weapons are left as they are.
	sets.packing = {ammo="Staunch Tathlum +1",
		head="Null Masque",neck={ name="Loricate Torque +1", augments={'Path: A',}},ear1={ name="Alabaster Earring", augments={'Path: A',}},ear2={ name="Odnowa Earring +1", augments={'Path: A',}},
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Defending Ring",ring2={ name="Murky Ring", augments={'Path: A',}},
		back="Null Shawl",waist="Null Belt",legs={ name="Nyame Flanchard", augments={'Path: B',}},feet={ name="Nyame Sollerets", augments={'Path: B',}}}

	sets.Kiting = {ring2="Shneddick Ring +1"}
	sets.Reraise = {head="Twilight Helm",body="Twilight Mail"}
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = {} -- original: head="Frenzy Sallet" (not owned)
	
    -- Extra defense sets.  Apply these on top of melee or defense sets.
    sets.passive.MP = {} -- original: {ear2="Ethereal Earring",waist="Flume Belt +1"} (not owned)
    sets.passive.Twilight = {head="Twilight Helm", body="Twilight Mail"}
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})

	-- Equipped automatically when someone starts casting Phalanx II on you (Valorous Phalanx +21 total)
	sets.Phalanx_Received = {
		head={name="Valorous Mask", augments={'INT+12','Magic burst dmg.+7%','Phalanx +4','Accuracy+1 Attack+1',}},
		body={name="Valorous Mail", augments={'STR+5','Rng.Atk.+26','Phalanx +4',}},
		hands={name="Valorous Mitts", augments={'Enmity-4','Mag. Acc.+14 "Mag.Atk.Bns."+14','Phalanx +4','Accuracy+10 Attack+10',}},
		legs={name="Valorous Hose", augments={'Pet: Attack+11 Pet: Rng.Atk.+11','Magic burst dmg.+7%','Phalanx +4',}},
		feet={name="Valorous Greaves", augments={'Mag. Acc.+1','"Cure" spellcasting time -9%','Phalanx +5','Mag. Acc.+14 "Mag.Atk.Bns."+14',}}}
	
	-- Weapons sets - Geirrothr is highest DMG with Haste/Crit, Areadbhar for STP/skill
	sets.weapons.Geirrothr = {main="Geirrothr",sub="Utu Grip"}
	sets.weapons.Areadbhar = {main="Areadbhar",sub="Utu Grip"}
	sets.weapons.ShiningOne = {main="Shining One",sub="Utu Grip"}
	sets.weapons.Trishula = {main="Trishula",sub="Utu Grip"} -- not owned; removed from the Weapons cycle, kept for when you get it
	sets.weapons.Naegling = {main="Naegling",sub=""}

	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {ear1="Ishvara Earring",ear2="Sherida Earring"} -- original: ear1="Brutal Earring" (not owned)
	sets.AccMaxTP = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.AccDayMaxTPWSEars = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.DayMaxTPWSEars = {ear1="Ishvara Earring",ear2="Sherida Earring"} -- original: ear1="Brutal Earring" (not owned)
	sets.AccDayWSEars = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.DayWSEars = {ear1={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},ear2="Sherida Earring"}
	
	-- Engaged sets

	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.engaged.Dagger.Accuracy.Evasion
	
	-- Normal melee group - Updated with Coiste Bodhar, Gleti gear, Sailfi Belt
	-- original (all engaged sets): ear2="Brutal Earring" (Normal/Fodder), ring2="Niqmaddu Ring", back="Brigantia's Mantle" (not owned)

	sets.engaged = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Gleti's Mask", augments={'Path: A',}},neck="Anu Torque",ear1="Sherida Earring",ear2="Telos Earring",
		body={ name="Gleti's Cuirass", augments={'Path: A',}},hands={ name="Gleti's Gauntlets", augments={'Path: A',}},ring1="Chirich Ring +1",ring2="Chirich Ring +1",
		back="Null Shawl",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs={ name="Gleti's Breeches", augments={'Path: A',}},feet={ name="Gleti's Boots", augments={'Path: A',}}}
    sets.engaged.SomeAcc = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Gleti's Mask", augments={'Path: A',}},neck="Shulmanu Collar",ear1="Sherida Earring",ear2="Telos Earring",
		body={ name="Gleti's Cuirass", augments={'Path: A',}},hands={ name="Gleti's Gauntlets", augments={'Path: A',}},ring1="Chirich Ring +1",ring2="Chirich Ring +1",
		back="Null Shawl",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs={ name="Gleti's Breeches", augments={'Path: A',}},feet={ name="Gleti's Boots", augments={'Path: A',}}}
	sets.engaged.Acc = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Gleti's Mask", augments={'Path: A',}},neck="Shulmanu Collar",ear1="Telos Earring",ear2="Mache Earring +1",
		body={ name="Gleti's Cuirass", augments={'Path: A',}},hands={ name="Gleti's Gauntlets", augments={'Path: A',}},ring1="Chirich Ring +1",ring2="Chirich Ring +1",
		back="Null Shawl",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs={ name="Gleti's Breeches", augments={'Path: A',}},feet={ name="Gleti's Boots", augments={'Path: A',}}}
    sets.engaged.FullAcc = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Gleti's Mask", augments={'Path: A',}},neck="Shulmanu Collar",ear1="Mache Earring +1",ear2="Telos Earring",
		body={ name="Gleti's Cuirass", augments={'Path: A',}},hands={ name="Gleti's Gauntlets", augments={'Path: A',}},ring1="Chirich Ring +1",ring2="Chirich Ring +1",
		back="Null Shawl",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs={ name="Gleti's Breeches", augments={'Path: A',}},feet={ name="Gleti's Boots", augments={'Path: A',}}}
    sets.engaged.Fodder = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Gleti's Mask", augments={'Path: A',}},neck="Anu Torque",ear1="Sherida Earring",ear2="Telos Earring",
		body={ name="Gleti's Cuirass", augments={'Path: A',}},hands={ name="Gleti's Gauntlets", augments={'Path: A',}},ring1="Chirich Ring +1",ring2="Chirich Ring +1",
		back="Null Shawl",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs={ name="Gleti's Breeches", augments={'Path: A',}},feet={ name="Gleti's Boots", augments={'Path: A',}}}

    sets.engaged.AM = {}
    sets.engaged.AM.SomeAcc = {}
	sets.engaged.AM.Acc = {}
    sets.engaged.AM.FullAcc = {}
    sets.engaged.AM.Fodder = {}
	
	-- PDT Hybrid sets - capped DT on five armor pieces + Defending Ring, everything else offense
	-- PDT-63% / MDT-57%: Gleti's Mask PDT6 (physical only), Hjarrandi 12, Vambraces +3 11, Cuissots +3 13, Schyn. +3 11, Defending 10
	-- original (all Nyame, DT-59%): head/body/hands/legs/feet=Nyame Path B, neck=Loricate Torque +1, ear1=Alabaster Earring,
	--   ring2="Niqmaddu Ring", back="Moonlight Cape" (not owned)
    sets.engaged.PDT = {ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Gleti's Mask", augments={'Path: A',}},neck="Anu Torque",ear1="Sherida Earring",ear2="Telos Earring",
		body="Hjarrandi Breast.",hands="Pel. Vambraces +3",ring1="Defending Ring",ring2="Chirich Ring +1",
		back="Null Shawl",waist={ name="Sailfi Belt +1", augments={'Path: A',}},legs="Pelt. Cuissots +3",feet="Pelt. Schyn. +3"}
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

-- LINKTRI: PorterPacker support (ported from the WHM/BST files). Sel runs user_job_customize_idle_set after
-- DRG.lua's own idle customization, so nothing in the job file is overridden.
near_porter = false

function near_porter_moogle()
	local mobs = windower.ffxi.get_mob_array()
	for i, mob in pairs(mobs) do
		-- mob.distance is squared yalms: < 36 means within 6 yalms
		if mob.name == "Porter Moogle" and mob.distance and mob.distance < 36 then
			return true
		end
	end
	return false
end

function user_job_customize_idle_set(idleSet)
	if near_porter_moogle() then
		if not near_porter then
			windower.add_to_chat(160, "Near Porter Moogle - Using packing gear")
			near_porter = true
		end
		return sets.packing
	elseif near_porter then
		windower.add_to_chat(160, "Left Porter Moogle area - Returning to normal gear")
		near_porter = false
	end
	return idleSet
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