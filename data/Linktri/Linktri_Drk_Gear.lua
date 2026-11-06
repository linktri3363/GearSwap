function user_job_setup()
	-- Options: Override default values
    state.OffenseMode:options('Normal','SomeAcc','Acc','FullAcc','Fodder')
    state.WeaponskillMode:options('Match','Normal','SomeAcc','Acc','FullAcc','Fodder')
    state.HybridMode:options('Normal')
    state.PhysicalDefenseMode:options('PDT', 'PDTReraise')
    state.MagicalDefenseMode:options('MDT', 'MDTReraise')
	state.ResistDefenseMode:options('MEVA')
	state.IdleMode:options('Normal', 'PDT','Refresh','Reraise')
	state.Weapons:options('Zantetsuken','Deathbane','Naegling')  -- LINKTRI 2026-11-06: owned weapons; original: 'Montante','Anguta','Lycurgos','Scythe','Sword'
    state.ExtraMeleeMode = M{['description']='Extra Melee Mode','None'}
	state.Passive = M{['description'] = 'Passive Mode','None','MP','Twilight'}
	state.DrainSwapWeaponMode = M{'Never','Always','300','1000'}  -- LINKTRI 2026-11-06: default Never (no Drain weapon owned); original default 'Always'

	-- Additional local binds
	send_command('bind ^` input /ja "Hasso" <me>')
	send_command('bind !` input /ja "Seigan" <me>')
	send_command('bind @` gs c cycle SkillchainMode')
	
	select_default_macro_book()
end

-- Define sets and vars used by this job file.
function init_gear_sets()
	--------------------------------------
	-- Start defining the sets
	--------------------------------------
	-- Precast Sets
	-- Precast sets to enhance JAs
	sets.precast.JA['Diabolic Eye'] = {hands="Fall. Fin. Gaunt. +3"} -- LINKTRI 2026-11-05: enhances Diabolic Eye
	sets.precast.JA['Arcane Circle'] = {}
	sets.precast.JA['Souleater'] = {}
	sets.precast.JA['Weapon Bash'] = {}
	sets.precast.JA['Nether Void'] = {}
	sets.precast.JA['Blood Weapon'] = {body="Fall. Cuirass +3"} -- LINKTRI 2026-11-06: enhances Blood Weapon
	sets.precast.JA['Dark Seal'] = {}
	sets.precast.JA['Last Resort'] = {back="Niht Mantle",feet="Fall. Sollerets +3"} -- LINKTRI 2026-11-05: Last Resort+1, enhances Desperate Blows
                   
	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}
                   
	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = {}
           
	sets.precast.Step = {}
	
	sets.precast.Flourish1 = {}
		   
	-- Fast cast sets for spells
	sets.precast.FC = {
		ammo="Impatiens",
		head={ name="Sakpata's Helm", augments={'Path: A',}},
		neck="Baetyl Pendant",
		ear1="Malignance Earring",
		ear2="Loquac. Earring",
		body="Fall. Cuirass +3", -- LINKTRI 2026-11-06: Fast Cast+10%; original: Sakpata's Plate
		hands={ name="Sakpata's Gauntlets", augments={'Path: A',}},
		ring1="Lebeche Ring",
		ring2="Kishar Ring",
		back="Moonlight Cape",
		waist="Embla Sash",
		legs={ name="Sakpata's Cuisses", augments={'Path: A',}},
		feet={ name="Sakpata's Leggings", augments={'Path: A',}}
	}

	sets.precast.FC['Dark Magic'] = set_combine(sets.precast.FC, {head="Fall. Burgeonet +3"}) -- LINKTRI 2026-11-05: Dark magic casting time -12% (Sakpata's Helm is FC+8%)
	sets.precast.FC.Impact = set_combine(sets.precast.FC, {head=empty,body="Twilight Cloak"})
		
	-- Midcast Sets
	sets.midcast.FastRecast = {
		ammo="Impatiens",
		head={ name="Sakpata's Helm", augments={'Path: A',}},
		neck="Baetyl Pendant",
		ear1="Malignance Earring",
		ear2="Loquac. Earring",
		body="Fall. Cuirass +3", -- LINKTRI 2026-11-06: Fast Cast+10%; original: Sakpata's Plate
		hands={ name="Sakpata's Gauntlets", augments={'Path: A',}},
		ring1="Lebeche Ring",
		ring2="Kishar Ring",
		back="Moonlight Cape",
		waist="Embla Sash",
		legs={ name="Sakpata's Cuisses", augments={'Path: A',}},
		feet={ name="Sakpata's Leggings", augments={'Path: A',}}
	}
                   
	-- Specific spells
	sets.midcast['Dark Magic'] = {
		ammo="Pemphredo Tathlum",
		head={ name="Nyame Helm", augments={'Path: B',}},
		neck="Baetyl Pendant",
		ear1="Malignance Earring",
		ear2="Psystorm Earring",
		body={ name="Nyame Mail", augments={'Path: B',}},
		hands="Fall. Fin. Gaunt. +3", -- LINKTRI 2026-11-05: Dark Magic skill+18, Drain/Aspir potency+16, MAB+62; original: Nyame Gauntlets
		ring1="Stikini Ring",
		ring2="Stikini Ring",
		back="Niht Mantle",
		waist="Eschan Stone",
		legs="Heath. Flanchard +3", -- LINKTRI 2026-11-06: Dark Magic skill+30, M.Acc+63, Nether Void+45; original: Nyame Flanchard
		feet={ name="Nyame Sollerets", augments={'Path: B',}}
	}
           
	sets.midcast['Enfeebling Magic'] = {
		ammo="Pemphredo Tathlum",
		head={ name="Nyame Helm", augments={'Path: B',}},
		neck="Baetyl Pendant",
		ear1="Malignance Earring",
		ear2="Psystorm Earring",
		body={ name="Nyame Mail", augments={'Path: B',}},
		hands={ name="Nyame Gauntlets", augments={'Path: B',}},
		ring1="Stikini Ring",
		ring2="Stikini Ring",
		back="Niht Mantle",
		waist="Eschan Stone",
		legs={ name="Nyame Flanchard", augments={'Path: B',}},
		feet={ name="Nyame Sollerets", augments={'Path: B',}}
	}
		   
	sets.midcast['Dread Spikes'] = set_combine(sets.midcast['Dark Magic'], {body="Heath. Cuirass +3",hands={ name="Nyame Gauntlets", augments={'Path: B',}},legs={ name="Nyame Flanchard", augments={'Path: B',}}}) -- LINKTRI 2026-11-05/06: keeps Nyame hands/legs (more HP; Dread Spikes scales with max HP)
	sets.midcast.Absorb = set_combine(sets.midcast['Dark Magic'], {back="Niht Mantle"})
	sets.midcast['Absorb-TP'] = set_combine(sets.midcast.Absorb, {hands="Heath. Gauntlets +3"}) -- LINKTRI 2026-11-06: Absorb-TP +30%
	sets.buff['Nether Void'] = {legs="Heath. Flanchard +3"} -- LINKTRI 2026-11-06: Nether Void+45 (already in the Dark Magic set)
           
	sets.midcast.Stun = {
		ammo="Pemphredo Tathlum",
		head={ name="Nyame Helm", augments={'Path: B',}},
		neck="Baetyl Pendant",
		ear1="Malignance Earring",
		ear2="Psystorm Earring",
		body={ name="Nyame Mail", augments={'Path: B',}},
		hands="Fall. Fin. Gaunt. +3", -- LINKTRI 2026-11-05: Dark Magic skill+18, Drain/Aspir potency+16, MAB+62; original: Nyame Gauntlets
		ring1="Stikini Ring",
		ring2="Stikini Ring",
		back="Niht Mantle",
		waist="Eschan Stone",
		legs="Heath. Flanchard +3", -- LINKTRI 2026-11-06: Dark Magic skill+30, M.Acc+63, Nether Void+45; original: Nyame Flanchard
		feet={ name="Nyame Sollerets", augments={'Path: B',}}
	}
                   
	-- LINKTRI 2026-11-06: Erra Pendant (Drain/Aspir+5, Dark skill+10); Evanescence/Archon aren't owned, rings come from Dark Magic (Stikini)
	sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {
		neck="Erra Pendant",
		back="Niht Mantle",
		waist="Fucho-no-Obi"
	})
	
	-- LINKTRI 2026-11-06: Misanthropy isn't owned; swapping weapons for Drain would only swap the grip and reset TP.
	-- sets.DrainWeapon = {main="Misanthropy",sub="Alber Strap"}
                   
	sets.midcast.Aspir = sets.midcast.Drain
	
	sets.midcast.Impact = set_combine(sets.midcast['Dark Magic'], {head=empty,body="Twilight Cloak"})
	
	sets.midcast.Cure = {}
	
	sets.Self_Healing = {neck="Phalaina Locket",hands="Buremte Gloves",ring2="Kunaji Ring",waist="Gishdubar Sash"}
	sets.Cure_Received = {neck="Phalaina Locket",hands="Buremte Gloves",ring2="Kunaji Ring",waist="Gishdubar Sash"}
	sets.Self_Refresh = {waist="Gishdubar Sash"}
						                   
	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	-- LINKTRI 2026-11-06: WS sets rebuilt. Removed: Cichol's Mantle (WAR-only), Segomo's Mantle (MNK-only), Niqmaddu Ring (not owned),
	-- Baetyl Pendant / Sacro Cord (magic gear). Moonshade moves to ear1 so the Sortie Heath. Earring +2 can stay in ear2.
	-- Single-hit WSD set (Torcleaver, Cross Reaper, Catastrophe, Savage Blade): Nyame WSD+10~12%, Heath. Sollerets +3 WSD+12%,
	-- Sacro Mantle WSD+6%, Ephramad's (PDL+10%), Beithir (WSD+2%), Heath. Earring +2 (PDL+9%).
    sets.precast.WS = {
		ammo="Knobkierrie",
		head={ name="Nyame Helm", augments={'Path: B',}},
		neck="Anu Torque",
		ear1={ name="Moonshade Earring", augments={'Accuracy+4','Latent effect: "Regain"+1',}},
		ear2="Heath. Earring +2",
		body={ name="Nyame Mail", augments={'Path: B',}},
		hands={ name="Nyame Gauntlets", augments={'Path: B',}},
		ring1="Ephramad's Ring",
		ring2="Beithir Ring",
		back="Sacro Mantle",
		waist={ name="Sailfi Belt +1", augments={'Path: A',}},
		legs={ name="Nyame Flanchard", augments={'Path: B',}},
		feet="Heath. Sollerets +3"
	}
	sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {neck="Null Loop"})
	sets.precast.WS.Acc = set_combine(sets.precast.WS.SomeAcc, {waist="Null Belt"})
	sets.precast.WS.FullAcc = set_combine(sets.precast.WS.Acc, {body="Fall. Cuirass +3"}) -- Weapon skill accuracy+27
	sets.precast.WS.Fodder = set_combine(sets.precast.WS, {head="Heath. Bur. +3"}) -- PDL+10%

	-- Multi-hit set (Resolution, Entropy): Double/Triple Attack and PDL over WSD (WSD only boosts the first hit).
	sets.precast.WS.MultiHit = {
		ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head="Heath. Bur. +3",
		neck="Anu Torque",
		ear1={ name="Moonshade Earring", augments={'Accuracy+4','Latent effect: "Regain"+1',}},
		ear2="Heath. Earring +2",
		body={ name="Sakpata's Plate", augments={'Path: A',}},
		hands={ name="Sakpata's Gauntlets", augments={'Path: A',}},
		ring1="Ephramad's Ring",
		ring2="Gere Ring",
		back="Null Shawl",
		waist={ name="Sailfi Belt +1", augments={'Path: A',}},
		legs={ name="Sakpata's Cuisses", augments={'Path: A',}},
		feet={ name="Sakpata's Leggings", augments={'Path: A',}}
	}

    sets.precast.WS['Torcleaver'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Torcleaver'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS['Torcleaver'].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS['Torcleaver'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS['Torcleaver'].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS['Catastrophe'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Catastrophe'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS['Catastrophe'].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS['Catastrophe'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS['Catastrophe'].Fodder = set_combine(sets.precast.WS.Fodder, {})

	sets.precast.WS['Cross Reaper'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Cross Reaper'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
	sets.precast.WS['Cross Reaper'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Cross Reaper'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Cross Reaper'].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS['Resolution'] = set_combine(sets.precast.WS.MultiHit, {})
    sets.precast.WS['Resolution'].SomeAcc = set_combine(sets.precast.WS.MultiHit, {neck="Null Loop"})
    sets.precast.WS['Resolution'].Acc = set_combine(sets.precast.WS['Resolution'].SomeAcc, {waist="Null Belt"})
    sets.precast.WS['Resolution'].FullAcc = set_combine(sets.precast.WS['Resolution'].Acc, {ring2="Chirich Ring +1"})
    sets.precast.WS['Resolution'].Fodder = set_combine(sets.precast.WS.MultiHit, {})

    sets.precast.WS['Entropy'] = set_combine(sets.precast.WS['Resolution'], {})
    sets.precast.WS['Entropy'].SomeAcc = set_combine(sets.precast.WS['Resolution'].SomeAcc, {})
    sets.precast.WS['Entropy'].Acc = set_combine(sets.precast.WS['Resolution'].Acc, {})
    sets.precast.WS['Entropy'].FullAcc = set_combine(sets.precast.WS['Resolution'].FullAcc, {})
    sets.precast.WS['Entropy'].Fodder = set_combine(sets.precast.WS['Resolution'].Fodder, {})

	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS.Acc, {})

     -- Sets to return to when not performing an action.
           
     -- Resting sets
     sets.resting = {}
           
	-- Swap to these on Moonshade using WS if at 3000 TP
	-- LINKTRI 2026-11-06: Moonshade is ear1 now, so these only swap ear1; Heath. Earring +2 (Sortie) always stays in ear2.
	-- Lugra Earring (NQ, STR+7 dusk to dawn) at night; Ishvara (WSD+2%) / Mache +1 (Acc) by day. Lugra +1 isn't owned.
	sets.MaxTP = {ear1="Lugra Earring"}
	sets.AccMaxTP = {ear1="Mache Earring +1"}
	sets.AccDayMaxTPWSEars = {ear1="Mache Earring +1"}
	sets.DayMaxTPWSEars = {ear1="Ishvara Earring"}
	sets.AccDayWSEars = {ear1={ name="Moonshade Earring", augments={'Accuracy+4','Latent effect: "Regain"+1',}}}
	sets.DayWSEars = {ear1={ name="Moonshade Earring", augments={'Accuracy+4','Latent effect: "Regain"+1',}}}
     
	-- LINKTRI 2026-11-06: idle/defense rebuilt. Removed unowned Dark Ring, Ethereal Earring and Moonlight Cape. Heathen's +3 body/hands/legs
	-- (DT-13/10/12) replace Nyame (DT-9/7/8). Rings: Defending ring1, Murky ring2 (Shneddick swaps into ring1 when moving).
	-- Idle (Null Masque): DT about -71%, Regen from Null Masque/Null Belt.
    sets.idle = {
		ammo="Staunch Tathlum +1",
		head="Null Masque",
		neck={ name="Loricate Torque +1", augments={'Path: A',}},
		ear1={ name="Alabaster Earring", augments={'Path: A',}},
		ear2={ name="Odnowa Earring +1", augments={'Path: A',}},
		body="Heath. Cuirass +3",
		hands="Heath. Gauntlets +3",
		ring1="Defending Ring",
		ring2={ name="Murky Ring", augments={'Path: A',}},
		back="Null Shawl",
		waist="Null Belt",
		legs="Heath. Flanchard +3",
		feet={ name="Nyame Sollerets", augments={'Path: B',}}
	}

	-- PDT idle: Nyame Helm (DT-7) for more DEF; about -68% DT.
    sets.idle.PDT = {
		ammo="Staunch Tathlum +1",
		head={ name="Nyame Helm", augments={'Path: B',}},
		neck={ name="Loricate Torque +1", augments={'Path: A',}},
		ear1={ name="Alabaster Earring", augments={'Path: A',}},
		ear2={ name="Odnowa Earring +1", augments={'Path: A',}},
		body="Heath. Cuirass +3",
		hands="Heath. Gauntlets +3",
		ring1="Defending Ring",
		ring2={ name="Murky Ring", augments={'Path: A',}},
		back="Null Shawl",
		waist="Null Belt",
		legs="Heath. Flanchard +3",
		feet={ name="Nyame Sollerets", augments={'Path: B',}}
	}

	-- LINKTRI: Weakness set commented out (2026-10-17). Without it, Sel uses your normal idle set while weakened.
	-- To restore, uncomment the lines below; Sel-Include equips sets.idle.Weak automatically when it exists.
	-- sets.idle.Weak = set_combine(sets.idle, {head="Twilight Helm",body="Twilight Mail"})

	sets.idle.Reraise = set_combine(sets.idle, {head="Twilight Helm",body="Twilight Mail"})

    -- Defense sets
	sets.defense.PDT = {
		ammo="Staunch Tathlum +1",
		head={ name="Nyame Helm", augments={'Path: B',}},
		neck={ name="Loricate Torque +1", augments={'Path: A',}},
		ear1={ name="Alabaster Earring", augments={'Path: A',}},
		ear2={ name="Odnowa Earring +1", augments={'Path: A',}},
		body="Heath. Cuirass +3",
		hands="Heath. Gauntlets +3",
		ring1="Defending Ring",
		ring2={ name="Murky Ring", augments={'Path: A',}},
		back="Null Shawl",
		waist="Null Belt",
		legs="Heath. Flanchard +3",
		feet={ name="Nyame Sollerets", augments={'Path: B',}}
	}

	sets.defense.PDTReraise = set_combine(sets.defense.PDT, {head="Twilight Helm",body="Twilight Mail"})

	sets.defense.MDT = set_combine(sets.defense.PDT, {})

	sets.defense.MDTReraise = set_combine(sets.defense.MDT, {head="Twilight Helm",body="Twilight Mail"})

	-- MEVA keeps Nyame: more Magic Evasion than Heathen's in every slot.
	sets.defense.MEVA = {
		ammo="Staunch Tathlum +1",
		head={ name="Nyame Helm", augments={'Path: B',}},
		neck={ name="Loricate Torque +1", augments={'Path: A',}},
		ear1={ name="Alabaster Earring", augments={'Path: A',}},
		ear2={ name="Odnowa Earring +1", augments={'Path: A',}},
		body={ name="Nyame Mail", augments={'Path: B',}},
		hands={ name="Nyame Gauntlets", augments={'Path: B',}},
		ring1="Defending Ring",
		ring2={ name="Murky Ring", augments={'Path: A',}},
		back="Null Shawl",
		waist="Null Belt",
		legs={ name="Nyame Flanchard", augments={'Path: B',}},
		feet={ name="Nyame Sollerets", augments={'Path: B',}}
	}

	-- LINKTRI: PorterPacker packing-safe set (same approach as WHM/BST/DRG). Equipped while idle within 6 yalms of a
	-- Porter Moogle so nothing on the PorterPacker DRK list (Heathen's +3, Ignominy +1, Fallen's +1, Sulevia's +2,
	-- Flamma +2, ...) is being worn when it gets packed. Only non-slip gear here; weapons are left as they are.
	sets.packing = {ammo="Staunch Tathlum +1",
		head="Null Masque",neck={ name="Loricate Torque +1", augments={'Path: A',}},ear1={ name="Alabaster Earring", augments={'Path: A',}},ear2={ name="Odnowa Earring +1", augments={'Path: A',}},
		body={ name="Nyame Mail", augments={'Path: B',}},hands={ name="Nyame Gauntlets", augments={'Path: B',}},ring1="Defending Ring",ring2={ name="Murky Ring", augments={'Path: A',}},
		back="Null Shawl",waist="Null Belt",legs={ name="Nyame Flanchard", augments={'Path: B',}},feet={ name="Nyame Sollerets", augments={'Path: B',}}}

	sets.Kiting = {ring1 = "Shneddick Ring +1"}
	sets.passive.Reraise = {head="Twilight Helm",body="Twilight Mail"}
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = {head="Frenzy Sallet"}
	sets.buff['Dark Seal'] = {head="Fall. Burgeonet +3"} -- LINKTRI 2026-11-05: enhances Dark Seal (equipped for Absorbs/Drain II-III/Dread Spikes while Dark Seal is up)
     
	-- Engaged sets
	-- LINKTRI 2026-11-06: Sakpata's R30 core kept (DT about -40%). Replaced: Atzintli Necklace (magic neck) -> Anu Torque, Cessance Earring
	-- (not owned) -> Schere Earring, Niqmaddu/Ramuh +1 (not owned) -> Gere/Chirich +1, Segomo's Mantle (MNK-only) -> Null Shawl
	-- (DA+7, Store TP+7, Acc+50), Sacro Cord (magic waist) -> Sailfi Belt +1 / Null Belt.
	sets.engaged = {
		ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Sakpata's Helm", augments={'Path: A',}},
		neck="Anu Torque",
		ear1="Schere Earring",
		ear2="Heath. Earring +2",
		body={ name="Sakpata's Plate", augments={'Path: A',}},
		hands={ name="Sakpata's Gauntlets", augments={'Path: A',}},
		ring1="Epona's Ring",
		ring2="Gere Ring",
		back="Null Shawl",
		waist={ name="Sailfi Belt +1", augments={'Path: A',}},
		legs={ name="Sakpata's Cuisses", augments={'Path: A',}},
		feet={ name="Sakpata's Leggings", augments={'Path: A',}}
	}

    sets.engaged.SomeAcc = {
		ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Sakpata's Helm", augments={'Path: A',}},
		neck="Null Loop",
		ear1="Schere Earring",
		ear2="Heath. Earring +2",
		body={ name="Sakpata's Plate", augments={'Path: A',}},
		hands={ name="Sakpata's Gauntlets", augments={'Path: A',}},
		ring1="Epona's Ring",
		ring2="Gere Ring",
		back="Null Shawl",
		waist={ name="Sailfi Belt +1", augments={'Path: A',}},
		legs={ name="Sakpata's Cuisses", augments={'Path: A',}},
		feet={ name="Sakpata's Leggings", augments={'Path: A',}}
	}

	sets.engaged.Acc = {
		ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Sakpata's Helm", augments={'Path: A',}},
		neck="Null Loop",
		ear1="Mache Earring +1",
		ear2="Heath. Earring +2",
		body={ name="Sakpata's Plate", augments={'Path: A',}},
		hands={ name="Sakpata's Gauntlets", augments={'Path: A',}},
		ring1="Chirich Ring +1",
		ring2="Gere Ring",
		back="Null Shawl",
		waist="Null Belt",
		legs={ name="Sakpata's Cuisses", augments={'Path: A',}},
		feet={ name="Sakpata's Leggings", augments={'Path: A',}}
	}

    sets.engaged.FullAcc = {
		ammo={ name="Coiste Bodhar", augments={'Path: A',}},
		head={ name="Sakpata's Helm", augments={'Path: A',}},
		neck="Null Loop",
		ear1="Mache Earring +1",
		ear2="Heath. Earring +2",
		body={ name="Sakpata's Plate", augments={'Path: A',}},
		hands={ name="Sakpata's Gauntlets", augments={'Path: A',}},
		ring1="Chirich Ring +1",
		ring2="Chirich Ring +1",
		back="Null Shawl",
		waist="Null Belt",
		legs={ name="Sakpata's Cuisses", augments={'Path: A',}},
		feet={ name="Sakpata's Leggings", augments={'Path: A',}}
	}

	-- Fodder: Heath. Bur. +3 (DA+6%, PDL+10%) for easy targets.
    sets.engaged.Fodder = set_combine(sets.engaged, {head="Heath. Bur. +3"})

	--Extra Special Sets
	sets.buff.Souleater = {}
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = {head="Frenzy Sallet"}
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
	
	-- Weapons sets
	-- LINKTRI 2026-11-06: rebuilt around owned weapons. Montante +1 and Lycurgos aren't owned; Malignance Pole is a staff (DRK can't equip).
	sets.weapons.Zantetsuken = {main="Zantetsuken X",sub="Utu Grip"}
	sets.weapons.Deathbane = {main="Deathbane",sub="Utu Grip"}
	sets.weapons.Naegling = {main="Naegling",sub="Blurred Shield +1"}
	
end
	
-- LINKTRI: PorterPacker support (ported from the WHM/BST/DRG files). Sel runs user_job_customize_idle_set after
-- DRK.lua's own job_customize_idle_set, so nothing in the job file is overridden.
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
        set_macro_page(1, 8)
    elseif player.sub_job == 'SAM' then
        set_macro_page(1, 8)
    elseif player.sub_job == 'DNC' then
        set_macro_page(1, 8)
    elseif player.sub_job == 'THF' then
        set_macro_page(1, 8)
    else
        set_macro_page(1, 8)
    end
end