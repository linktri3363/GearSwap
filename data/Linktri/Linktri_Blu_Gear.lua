function user_job_setup()
    -- Options: Override default values
    state.OffenseMode:options("Fodder", "Normal", "Acc", "FullAcc")
    state.HybridMode:options("Normal", "DT")
    state.WeaponskillMode:options("Match", "Normal", "Acc", "FullAcc", "Fodder")
    state.CastingMode:options("Normal", "SIRD", "Resistant", "FullMacc", "Fodder", "Proc")
    state.IdleMode:options("Normal", "Sphere", "PDT", "DTHippo")
    state.PhysicalDefenseMode:options("PDT")
    state.MagicalDefenseMode:options("MDT")
    state.ResistDefenseMode:options("MEVA")
    -- original: "Tizbron","Tizalmace","None","Almace","MeleeClubs","HybridWeapons","Naegbron","Naegmace"
    -- (Tizona/Almace/Sequence not owned; Tizbron was a duplicate of Naegbron)
    state.Weapons:options("Naegbron", "Sakbron", "MeleeClubs", "None")

    state.ExtraMeleeMode = M {["description"] = "Extra Melee Mode", "None", "MP", "SuppaBrutal", "DWEarrings", "DWMax"}

    -- JSE Capes (keep original naming for compatibility)
    -- original: Rosmerta's Cape (Dbl.Atk.+10) - not owned; your only Rosmerta's is the INT/MAB nuke cape
    gear.da_jse_back = "Null Shawl"
    -- original: Rosmerta's Cape (Store TP+10) - not owned; your only Rosmerta's is the INT/MAB nuke cape
    gear.stp_jse_back = "Null Shawl"
    -- original: Rosmerta's Cape (Crit.hit rate+10) - not owned; your only Rosmerta's is the INT/MAB nuke cape
    gear.crit_jse_back = "Null Shawl"
    -- original: Rosmerta's Cape (WSD+10%) - not owned; your only Rosmerta's is the INT/MAB nuke cape
    gear.wsd_jse_back = "Null Shawl"
    gear.nuke_jse_back = {
        name = "Rosmerta's Cape",
        augments = {'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Mag.Atk.Bns."+10','Spell interruption rate down-10%',}
    }

    autows = "Savage Blade"  -- original: "Expiacion" (needs Tizona)

    -- Additional local binds
    send_command('bind ^` input /ja "Chain Affinity" <me>')
    send_command('bind @` input /ja "Efflux" <me>')
    send_command('bind !` input /ja "Burst Affinity" <me>')
    send_command("bind ^@!` gs c cycle SkillchainMode")
    send_command(
        'bind ^backspace input /ja "Unbridled Learning" <me>;wait 1;input /ja "Diffusion" <me>;wait 2;input /ma "Mighty Guard" <me>'
    )
    send_command(
        'bind !backspace input /ja "Unbridled Learning" <me>;wait 1;input /ja "Diffusion" <me>;wait 2;input /ma "Carcharian Verve" <me>'
    )
    send_command('bind @backspace input /ja "Convergence" <me>')
    send_command("bind @f10 gs c toggle LearningMode")
    send_command("bind ^@!` gs c cycle MagicBurstMode")
    send_command("bind @f8 gs c toggle AutoNukeMode")
    send_command("bind !@^f7 gs c toggle AutoWSMode")
    send_command("bind !r gs c weapons None;gs c update")
    -- send_command("bind @q gs c weapons MaccWeapons;gs c update")  -- removed: no MaccWeapons set
    send_command("bind ^q gs c weapons Naegbron;gs c update")  -- original: Almace (not owned)
    send_command("bind !q gs c weapons MeleeClubs;gs c update")  -- original: HybridWeapons (Sequence/Almace not owned)

    select_default_macro_book()
end

function init_gear_sets()
sets.weapons = {}

-- Removed (not owned): Tizbron (= Naegbron), Tizalmace (Tizona/Almace), Almace (Almace/"Brongniart"),
-- HybridWeapons (Sequence/Almace), Naegmace (Naegling/Almace).
sets.weapons.Sakbron = {      -- for when Naegling is packed: Sakpata's Sword (FC+10, DT-10) + Thibron (TP Bonus +1000)
    main={ name="Sakpata's Sword", augments={'Path: A',}},
    sub="Thibron"
}

sets.weapons.MeleeClubs = {
    main="Maxentius",
    sub="Bunzi's Rod"
}


sets.weapons.Naegbron = {
    main="Naegling",
    sub="Thibron"
}



    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Precast Sets
    
    -- Fast Cast (prioritize getting spells off quickly)
    sets.precast.FC = {
        main="Vampirism",
        sub="Sakpata's Sword",
        ammo="Impatiens",
        head="Malignance Chapeau", -- original: "Carmine Mask +1" (not owned)
        neck="Voltsurge Torque",
        ear1="Etiolation Earring", -- original: "Enchntr. Earring +1" (not owned)
        ear2="Loquac. Earring",
        body="Luhlaza Jubbah +1",
        hands="Sombra Mittens", -- original: "Leyline Gloves" (not owned)
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back="Perimede Cape",
        waist="Witful Belt",
        legs="Aya. Cosciales +2",
        feet="Malignance Boots" -- original: "Carmine Greaves +1" (not owned)
    }

    sets.precast.FC['Blue Magic'] = set_combine(sets.precast.FC, {body="Hashishin Mintan +3"})

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {})  -- original: {body="Passion Jacket"} (not owned)

    -- Weaponskill sets
    sets.precast.WS = {
        ammo="Coiste Bodhar", -- original: "Aurgelmir Orb +1" (not owned)
        head="Lilitu Headpiece",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Mache Earring +1", -- original: "Cessance Earring" (not owned)
        ear2="Brutal Earring",
        body={ name="Gleti's Cuirass", augments={'Path: A',}}, -- original: "Adhemar Jacket +1" (not owned)
        hands="Jhakri Cuffs +2",
        ring1="Epona's Ring",
        ring2="Apate Ring",
        back=gear.da_jse_back,
        waist={ name="Sailfi Belt +1", augments={'Path: A',}}, -- original: "Kentarch Belt +1" (not owned)
        legs="Samnuha Tights",
        feet="Malignance Boots"
    }

    sets.precast.WS.Acc = {
        ammo="Mantoptera Eye", -- original: "Falcon Eye" (not owned)
        head="Malignance Chapeau", -- original: "Carmine Mask +1" (not owned)
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Mache Earring +1",
        ear2="Telos Earring",
        body="Assim. Jubbah +2",
        hands="Assim. Bazu. +2",
        ring1="Epona's Ring",
        ring2="Ilabrat Ring",
        back=gear.da_jse_back,
        waist="Null Belt", -- original: "Kentarch Belt +1" (not owned)
        legs="Malignance Tights", -- original: "Carmine Cuisses +1" (not owned)
        feet="Malignance Boots"
    }

    sets.precast.WS.FullAcc = {
        ammo="Mantoptera Eye", -- original: "Falcon Eye" (not owned)
        head="Malignance Chapeau", -- original: "Carmine Mask +1" (not owned)
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Mache Earring +1",
        ear2="Odr Earring",
        body="Assim. Jubbah +2",
        hands="Assim. Bazu. +2",
        ring1="Stikini Ring",
        ring2="Stikini Ring",
        back=gear.da_jse_back,
        waist="Null Belt", -- original: "Olseni Belt" (not owned)
        legs="Malignance Tights", -- original: "Carmine Cuisses +1" (not owned)
        feet="Malignance Boots"
    }

    sets.precast.WS.DT = {
        ammo="Coiste Bodhar", -- original: "Aurgelmir Orb +1" (not owned)
        head="Malignance Chapeau",
        neck="Loricate Torque +1",
        ear1="Mache Earring +1", -- original: "Cessance Earring" (not owned)
        ear2="Brutal Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Defending Ring",
        back=gear.da_jse_back,
        waist={ name="Sailfi Belt +1", augments={'Path: A',}}, -- original: "Kentarch Belt +1" (not owned)
        legs="Malignance Tights",
        feet="Malignance Boots"
    }

    sets.precast.WS.Fodder = {
        ammo="Coiste Bodhar", -- original: "Aurgelmir Orb +1" (not owned)
        head="Lilitu Headpiece",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Mache Earring +1", -- original: "Cessance Earring" (not owned)
        ear2="Brutal Earring",
        body={ name="Gleti's Cuirass", augments={'Path: A',}}, -- original: "Adhemar Jacket +1" (not owned)
        hands="Jhakri Cuffs +2",
        ring1="Epona's Ring",
        ring2="Apate Ring",
        back=gear.da_jse_back,
        waist={ name="Sailfi Belt +1", augments={'Path: A',}}, -- original: "Kentarch Belt +1" (not owned)
        legs="Samnuha Tights",
        feet="Malignance Boots"
    }

    -- Specific weaponskill sets
    sets.precast.WS["Requiescat"] = set_combine(sets.precast.WS, {
        head="Jhakri Coronal +2",
        ear1="Moonshade Earring", -- original: "Regal Earring" (not owned)
        body="Jhakri Robe +2",
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}}, -- original: ring2 (sides 2026-10-23)
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    })

    sets.precast.WS["Requiescat"].Acc = set_combine(sets.precast.WS.Acc, {
        head="Jhakri Coronal +2",
        ear1="Moonshade Earring", -- original: "Regal Earring" (not owned)
        body="Jhakri Robe +2",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    })

    sets.precast.WS["Chant du Cygne"] = set_combine(sets.precast.WS, {
        ammo="Coiste Bodhar", -- LINKTRI MODIFICATION: multi-hit crit WS ammo
        head={ name="Gleti's Mask", augments={'Path: A',}},
        neck="Light Gorget", -- original: "Mirage Stole +2" (not owned)
        ear1="Mache Earring +1",
        ear2="Odr Earring",
        body={ name="Gleti's Cuirass", augments={'Path: A',}},
        hands={ name="Gleti's Gauntlets", augments={'Path: A',}},
        ring1="Epona's Ring",
        ring2="Ilabrat Ring", -- original: "Begrudging Ring" (not owned)
        back=gear.crit_jse_back,
        waist="Reiki Yotai",
        legs={ name="Gleti's Breeches", augments={'Path: A',}},
        feet={ name="Gleti's Boots", augments={'Path: A',}}
    })

    sets.precast.WS["Chant du Cygne"].Acc = set_combine(sets.precast.WS.Acc, {
        head={ name="Gleti's Mask", augments={'Path: A',}}, -- LINKTRI MODIFICATION: full Gleti's crit set
        ear1="Mache Earring +1",
        ear2="Odr Earring",
        body={ name="Gleti's Cuirass", augments={'Path: A',}},
        hands={ name="Gleti's Gauntlets", augments={'Path: A',}},
        ring2="Ilabrat Ring", -- original: "Begrudging Ring" (not owned)
        back=gear.crit_jse_back,
        waist="Reiki Yotai",
        legs={ name="Gleti's Breeches", augments={'Path: A',}},
        feet={ name="Gleti's Boots", augments={'Path: A',}}
    })

    sets.precast.WS["Savage Blade"] = set_combine(sets.precast.WS, {
        ammo="Oshasha's Treatise", -- LINKTRI MODIFICATION: single-hit-style WS damage ammo
        head="Hashishin Kavuk +3",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Moonshade Earring",
        ear2="Ishvara Earring",
        body={ name="Nyame Mail", augments={'Path: B'} },
        hands={ name="Nyame Gauntlets", augments={'Path: B'} },
        ring1="Ephramad's Ring", -- original: "Epaminondas's Ring" (not owned)
        ring2="Beithir Ring",
        back=gear.wsd_jse_back,
        waist={ name="Sailfi Belt +1", augments={'Path: A',}},
        legs={ name="Nyame Flanchard", augments={'Path: B'} },
        feet={ name="Nyame Sollerets", augments={'Path: B'} }
    })

    sets.precast.WS["Savage Blade"].Acc = set_combine(sets.precast.WS.Acc, {
        head="Hashishin Kavuk +3",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Moonshade Earring",
        ear2="Ishvara Earring",
        body={ name="Nyame Mail", augments={'Path: B'} },
        hands={ name="Nyame Gauntlets", augments={'Path: B'} },
        ring1="Ephramad's Ring", -- original: "Epaminondas's Ring" (not owned)
        ring2="Beithir Ring",
        back=gear.wsd_jse_back,
        waist={ name="Sailfi Belt +1", augments={'Path: A',}},
        legs={ name="Nyame Flanchard", augments={'Path: B'} },
        feet={ name="Nyame Sollerets", augments={'Path: B'} }
    })

    sets.precast.WS["Expiacion"] = set_combine(sets.precast.WS["Savage Blade"], {})

    sets.precast.WS["Expiacion"].Acc = set_combine(sets.precast.WS["Savage Blade"].Acc, {})

    sets.precast.WS["Sanguine Blade"] = {
        ammo="Pemphredo Tathlum", -- original: "Ghastly Tathlum +1" (not owned)
        head="Pixie Hairpin +1", -- Dark MAB+28; original: "Hashishin Kavuk +3"
        neck="Sibyl Scarf",
        ear1="Crematio Earring", -- original: "Regal Earring" (not owned)
        ear2="Hecate's Earring", -- original: "Friomisi Earring" (not owned)
        body={ name="Nyame Mail", augments={'Path: B'} },
        hands="Jhakri Cuffs +2",
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}}, -- original: "Epaminondas's Ring" (not owned)
        ring2="Stikini Ring", -- MND+5; original: "Archon Ring" (not owned)
        back=gear.nuke_jse_back,
        waist="Orpheus's Sash",
        legs={ name="Luhlaza Shalwar +1", augments={'Enhances "Assimilation" effect',}},
        feet="Hashi. Basmak +3"
    }

    sets.precast.WS["Red Lotus Blade"] = set_combine(sets.precast.WS["Sanguine Blade"], {
        ring2="Beithir Ring"
    })

    sets.precast.WS["Seraph Blade"] = set_combine(sets.precast.WS["Red Lotus Blade"], {})

    sets.precast.WS["Flash Nova"] = set_combine(sets.precast.WS["Red Lotus Blade"], {})

    -- Midcast Sets
    sets.midcast.FastRecast = {
        ammo="Impatiens",
        head="Malignance Chapeau", -- original: "Carmine Mask +1" (not owned)
        neck="Voltsurge Torque",
        ear1="Etiolation Earring", -- original: "Enchntr. Earring +1" (not owned)
        ear2="Loquac. Earring",
        body="Luhlaza Jubbah +1",
        hands="Sombra Mittens", -- original: "Leyline Gloves" (not owned)
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back="Perimede Cape",
        waist="Witful Belt",
        legs="Aya. Cosciales +2",
        feet="Malignance Boots" -- original: "Carmine Greaves +1" (not owned)
    }

    -- Blue Magic Skill for learning spells
    sets.midcast['Blue Magic'] = sets.midcast['Blue Magic'] or {}
    sets.midcast['Blue Magic'].Learning = {
        hands="Assim. Bazu. +2"
    }

    -- Physical Blue Magic
    sets.midcast['Blue Magic'].Physical = {
        ammo="Coiste Bodhar", -- original: "Aurgelmir Orb +1" (not owned)
        head="Hashishin Kavuk +3",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Mache Earring +1", -- original: "Cessance Earring" (not owned)
        ear2="Brutal Earring",
        body="Hashishin Mintan +3",
        hands="Hashi. Bazu. +3",
        ring1="Epona's Ring",
        ring2="Ilabrat Ring",
        back=gear.da_jse_back,
        waist={ name="Sailfi Belt +1", augments={'Path: A',}}, -- original: "Kentarch Belt +1" (not owned)
        legs="Hashishin Tayt +3",
        feet="Hashi. Basmak +3"
    }

    sets.midcast['Blue Magic'].PhysicalAcc = {
        ammo="Mantoptera Eye", -- original: "Falcon Eye" (not owned)
        head="Hashishin Kavuk +3",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Mache Earring +1",
        ear2="Hashi. Earring +1", -- LINKTRI MODIFICATION: BLU Sortie earring
        body="Hashishin Mintan +3",
        hands="Hashi. Bazu. +3",
        ring1="Cacoethic Ring +1", -- Acc+11; original: "Stikini Ring" (magic accuracy only)
        ring2="Ilabrat Ring",
        back=gear.da_jse_back,
        waist="Null Belt", -- original: "Kentarch Belt +1" (not owned)
        legs="Hashishin Tayt +3",
        feet="Hashi. Basmak +3"
    }

    sets.midcast['Blue Magic'].PhysicalStr = set_combine(sets.midcast['Blue Magic'].Physical, {})

    sets.midcast['Blue Magic'].PhysicalDex = set_combine(sets.midcast['Blue Magic'].Physical, {})

    sets.midcast['Blue Magic'].PhysicalVit = set_combine(sets.midcast['Blue Magic'].Physical, {})

    sets.midcast['Blue Magic'].PhysicalAgi = set_combine(sets.midcast['Blue Magic'].Physical, {})

    sets.midcast['Blue Magic'].PhysicalInt = set_combine(sets.midcast['Blue Magic'].Physical, {})

    sets.midcast['Blue Magic'].PhysicalMnd = set_combine(sets.midcast['Blue Magic'].Physical, {})

    sets.midcast['Blue Magic'].PhysicalChr = set_combine(sets.midcast['Blue Magic'].Physical, {})

    sets.midcast['Blue Magic'].PhysicalHP = set_combine(sets.midcast['Blue Magic'].Physical, {})

    -- Magical Blue Magic
    sets.midcast['Blue Magic'].Magical = {
        ammo="Pemphredo Tathlum", -- original: "Ghastly Tathlum +1" (not owned)
        head="Hashishin Kavuk +3",
        neck="Sibyl Scarf",
        ear1="Crematio Earring", -- original: "Regal Earring" (not owned)
        ear2="Hecate's Earring", -- original: "Friomisi Earring" (not owned)
        body="Hashishin Mintan +3",
        hands="Hashi. Bazu. +3",
        ring1="Stikini Ring",
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Hashishin Tayt +3",
        feet="Hashi. Basmak +3"
    }

    sets.midcast['Blue Magic'].Magical.Resistant = {
        ammo="Pemphredo Tathlum",
        head="Hashishin Kavuk +3",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Crep. Earring", -- original: "Regal Earring" (not owned)
        ear2="Hashi. Earring +1", -- original: "Digni. Earring" (not owned)
        body="Hashishin Mintan +3",
        hands="Hashi. Bazu. +3",
        ring1="Stikini Ring",
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Hashishin Tayt +3",
        feet="Hashi. Basmak +3"
    }

    sets.midcast['Blue Magic'].MagicalMnd = set_combine(sets.midcast['Blue Magic'].Magical, {})

    sets.midcast['Blue Magic'].MagicalChr = set_combine(sets.midcast['Blue Magic'].Magical, {})

    sets.midcast['Blue Magic'].MagicalVit = set_combine(sets.midcast['Blue Magic'].Magical, {})

    sets.midcast['Blue Magic'].MagicalDex = set_combine(sets.midcast['Blue Magic'].Magical, {})

    sets.midcast['Blue Magic'].MagicAccuracy = {
        ammo="Pemphredo Tathlum",
        head="Hashishin Kavuk +3",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Crep. Earring", -- original: "Regal Earring" (not owned)
        ear2="Hashi. Earring +1", -- original: "Digni. Earring" (not owned)
        body="Hashishin Mintan +3",
        hands="Hashi. Bazu. +3",
        ring1="Stikini Ring",
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Hashishin Tayt +3",
        feet="Hashi. Basmak +3"
    }

    -- Breath Spells
    sets.midcast['Blue Magic'].Breath = {
        ammo="Staunch Tathlum +1",
        head="Hashishin Kavuk +3",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Etiolation Earring",
        ear2="Sanare Earring",
        body="Hashishin Mintan +3",
        hands="Hashi. Bazu. +3",
        ring1="Stikini Ring",
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Hashishin Tayt +3",
        feet="Hashi. Basmak +3"
    }

    -- Buff Blue Magic
    sets.midcast['Blue Magic'].Buff = {
        ammo="Impatiens",
        head="Luh. Keffiyeh +1",
        neck="Voltsurge Torque",
        ear1="Etiolation Earring", -- original: "Enchntr. Earring +1" (not owned)
        ear2="Loquac. Earring",
        body="Assim. Jubbah +2",
        hands="Assim. Bazu. +2",
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back="Perimede Cape",
        waist="Witful Belt",
        legs="Hashishin Tayt +3",
        feet="Malignance Boots" -- original: "Carmine Greaves +1" (not owned)
    }

    sets.midcast['Blue Magic']['White Wind'] = {
        ammo="Staunch Tathlum +1",
        head="Jhakri Coronal +2",
        neck="Null Loop", -- original: "Phalaina Locket" (not owned)
        ear1="Etiolation Earring",
        ear2="Sanare Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Stikini Ring",
        back="Aurist's Cape +1", -- original: "Solemnity Cape" (not owned)
        waist="Luminary Sash", -- original: "Gishdubar Sash" (not owned)
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast['Blue Magic']['Battery Charge'] = set_combine(sets.midcast['Blue Magic'].Buff, {
        -- head="Amalric Coif +1", -- removed: not owned
        -- waist="Gishdubar Sash", -- removed: not owned
    })

    sets.midcast['Blue Magic']['Regeneration'] = set_combine(sets.midcast['Blue Magic'].Buff, {})
    sets.midcast['Blue Magic']['Cocoon'] = set_combine(sets.midcast['Blue Magic'].Buff, {})
    sets.midcast['Blue Magic']['Refueling'] = set_combine(sets.midcast['Blue Magic'].Buff, {})

    sets.midcast['Blue Magic'].Healing = {
        ammo="Staunch Tathlum +1",
        head="Jhakri Coronal +2",
        neck="Null Loop", -- original: "Phalaina Locket" (not owned)
        ear1="Etiolation Earring",
        ear2="Sanare Earring", -- original: "Menemeus Earring" (not owned)
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Menelaus's Ring", -- Cure potency+5%; original: "Stikini Ring" (the "Menemeus Earring" in ear2 was meant to be this ring)
        back="Aurist's Cape +1", -- original: "Solemnity Cape" (not owned)
        waist="Luminary Sash", -- original: "Gishdubar Sash" (not owned)
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast['Blue Magic'].HealingSelf = set_combine(sets.midcast['Blue Magic'].Healing, {
        -- neck="Phalaina Locket", -- removed: not owned
        ring2="Menelaus's Ring", -- original: "Kunaji Ring" (not owned)
        -- waist="Gishdubar Sash", -- removed: not owned
    })

    -- Enhancing Magic
    sets.midcast['Enhancing Magic'] = {
        ammo="Impatiens",
        head={ name="Telchine Cap", augments={'Mag. Acc.+20','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}}, -- original: "Carmine Mask +1" (not owned)
        neck="Voltsurge Torque",
        ear1="Etiolation Earring", -- original: "Enchntr. Earring +1" (not owned)
        ear2="Loquac. Earring",
        body="Luhlaza Jubbah +1",
        hands={ name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}}, -- original: "Leyline Gloves" (not owned)
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back="Perimede Cape",
        waist="Witful Belt",
        legs={ name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        feet={ name="Telchine Pigaches", augments={'Mag. Acc.+18','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}}
    }

    sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {
        -- head="Amalric Coif +1", -- removed: not owned
        -- waist="Gishdubar Sash", -- removed: not owned
    })

    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
        -- ear1="Earthcry Earring", -- removed: not owned
        waist="Siegel Sash",
        legs="Shedir Seraweels"
    })

    sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {
        -- head="Amalric Coif +1", -- removed: not owned
        -- hands="Regal Cuffs", -- removed: not owned
        waist="Rumination Sash" -- original: "Emphatikos Rope" (not owned)
    })

    sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {ring2="Sheltered Ring"})
    sets.midcast.Protectra = sets.midcast.Protect
    sets.midcast.Shell = sets.midcast.Protect
    sets.midcast.Shellra = sets.midcast.Protect

    -- Enfeebling Magic
    sets.midcast['Enfeebling Magic'] = {
        ammo="Pemphredo Tathlum", -- original: "Ghastly Tathlum +1" (not owned)
        head="Jhakri Coronal +2",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Crep. Earring", -- original: "Regal Earring" (not owned)
        ear2="Hashi. Earring +1", -- original: "Digni. Earring" (not owned)
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring",
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast['Enfeebling Magic'].Resistant = {
        ammo="Pemphredo Tathlum", -- original: "Ghastly Tathlum +1" (not owned)
        head="Jhakri Coronal +2",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Crep. Earring", -- original: "Regal Earring" (not owned)
        ear2="Hashi. Earring +1", -- original: "Digni. Earring" (not owned)
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring",
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast['Dark Magic'] = {
        ammo="Pemphredo Tathlum", -- original: "Ghastly Tathlum +1" (not owned)
        head="Jhakri Coronal +2",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Crep. Earring", -- original: "Regal Earring" (not owned)
        ear2="Hashi. Earring +1", -- original: "Digni. Earring" (not owned)
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring",
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast.Stun = {
        ammo="Pemphredo Tathlum", -- original: "Ghastly Tathlum +1" (not owned)
        head="Jhakri Coronal +2",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Crep. Earring", -- original: "Regal Earring" (not owned)
        ear2="Hashi. Earring +1", -- original: "Digni. Earring" (not owned)
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring",
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {
        -- ring1="Evanescence Ring", -- removed: not owned
        -- ring2="Archon Ring", -- removed: not owned
        waist="Fucho-no-Obi"
    })

    sets.midcast.Aspir = sets.midcast.Drain

    -- Elemental Magic
    sets.midcast['Elemental Magic'] = {
        ammo="Pemphredo Tathlum", -- original: "Ghastly Tathlum +1" (not owned)
        head="Jhakri Coronal +2",
        neck="Sibyl Scarf",
        ear1="Crematio Earring", -- original: "Regal Earring" (not owned)
        ear2="Hecate's Earring", -- original: "Friomisi Earring" (not owned)
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring",
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast['Elemental Magic'].Resistant = {
        ammo="Pemphredo Tathlum", -- original: "Ghastly Tathlum +1" (not owned)
        head="Jhakri Coronal +2",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Crep. Earring", -- original: "Regal Earring" (not owned)
        ear2="Hashi. Earring +1", -- original: "Digni. Earring" (not owned)
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring",
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    -- Idle Sets
    sets.idle = {
        ammo="Staunch Tathlum +1",
        head="Malignance Chapeau",
        neck="Loricate Torque +1",
        ear1="Etiolation Earring",
        ear2="Sanare Earring",
        body="Jhakri Robe +2",
        hands="Malignance Gloves",
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Stikini Ring",
        back="Null Shawl", -- original: "Solemnity Cape" (not owned)
        waist="Fucho-no-Obi",
        legs="Malignance Tights", -- original: "Carmine Cuisses +1" (not owned)
        feet="Malignance Boots"
    }

    sets.idle.PDT = {
        ammo="Staunch Tathlum +1",
        head="Malignance Chapeau",
        neck="Loricate Torque +1",
        ear1="Etiolation Earring",
        ear2="Sanare Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Stikini Ring",
        back="Null Shawl", -- original: "Solemnity Cape" (not owned)
        waist="Fucho-no-Obi",
        legs="Malignance Tights",
        feet="Malignance Boots"
    }

    sets.idle.Sphere = set_combine(sets.idle, {
        -- body="Mekosu. Harness", -- removed: not owned
    })

    -- LINKTRI MODIFICATION: fills the pre-existing 'DTHippo' IdleMode option, which was in
    -- state.IdleMode:options() but had no matching set (silently fell back to base idle).
    -- Slot-by-slot best-in-owned-gear for combined physical+magic survival, per confirmed stats:
    --   head/hands/legs/feet = Gleti's (Mask/Gauntlets/Breeches/Boots): -6/-7/-8/-5% Physical
    --     dmg taken, MDB+13/12/14/13, Regain+2/2/3/2, plus matching Physical dmg LIMIT (caps
    --     any single hit) that neither Malignance nor Adamantite carry.
    --   body = Adamantite Armor (All Jobs): -20% Damage Taken (covers magic too, unlike Gleti's
    --     Cuirass's Physical-only -9%), MDB+20, HP+182, MP+118 -- the one slot where Adamantite
    --     beats its Gleti's equivalent outright, and the only MP in this set (Gleti's has none).
    --   ear1 = Alabaster Earring: DT-5%, HP+100 (Haste/Store TP do nothing while idle, so the
    --     flat DT/HP is the better trade over Etiolation here).
    -- Combined: ~46% stacked DT (26% Physical from the four Gleti's pieces + Adamantite's 20%
    -- general), MDB+72, HP+454, MP+118, Regain+9, -26% physical damage limit.
    sets.idle.DTHippo = set_combine(sets.idle.PDT, {
        ear1={ name="Alabaster Earring", augments={'Path: A',}},
        head={ name="Gleti's Mask", augments={'Path: A',}},
        body="Adamantite Armor",
        hands={ name="Gleti's Gauntlets", augments={'Path: A',}},
        legs={ name="Gleti's Breeches", augments={'Path: A',}},
        feet={ name="Gleti's Boots", augments={'Path: A',}}
    })

    -- Resting sets
    sets.resting = {
        ammo="Staunch Tathlum +1",
        head="Rawhide Mask",
        neck="Loricate Torque +1",
        ear1="Etiolation Earring",
        ear2="Sanare Earring",
        body="Jhakri Robe +2",
        hands="Malignance Gloves",
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Stikini Ring",
        back="Null Shawl", -- original: "Solemnity Cape" (not owned)
        waist="Fucho-no-Obi",
        legs="Malignance Tights", -- original: "Carmine Cuisses +1" (not owned)
        feet="Malignance Boots"
    }

    -- Defense sets
    sets.defense.PDT = {
        ammo="Staunch Tathlum +1",
        head={ name="Nyame Helm", augments={'Path: B'} },
        neck="Loricate Torque +1",
        ear1="Etiolation Earring",
        ear2="Sanare Earring",
        body={ name="Nyame Mail", augments={'Path: B'} },
        hands={ name="Nyame Gauntlets", augments={'Path: B'} },
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Defending Ring",
        back="Null Shawl", -- original: "Umbra Cape" (not owned)
        waist="Fucho-no-Obi",
        legs={ name="Nyame Flanchard", augments={'Path: B'} },
        feet={ name="Nyame Sollerets", augments={'Path: B'} }
    }

    sets.defense.MDT = {
        ammo="Staunch Tathlum +1",
        head="Malignance Chapeau",
        neck="Loricate Torque +1", -- original: "Warder's Charm +1" (not owned)
        ear1="Etiolation Earring",
        ear2="Sanare Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Defending Ring",
        back="Null Shawl", -- original: "Umbra Cape" (not owned)
        waist="Carrier's Sash",
        legs="Malignance Tights",
        feet="Malignance Boots"
    }

    sets.defense.MEVA = {
        ammo="Staunch Tathlum +1",
        head="Malignance Chapeau",
        neck="Loricate Torque +1", -- original: "Warder's Charm +1" (not owned)
        ear1="Etiolation Earring",
        ear2="Sanare Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves", -- original: "Leyline Gloves" (not owned)
        ring1="Vengeful Ring",
        ring2="Defending Ring", -- original: "Purity Ring" (not owned)
        back=gear.nuke_jse_back,
        waist="Carrier's Sash",
        legs={ name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        feet="Malignance Boots"
    }

    -- Engaged sets

    -- Variations for TP build
    sets.engaged = {
        ammo="Coiste Bodhar", -- original: "Aurgelmir Orb +1" (not owned)
        head={ name="Gleti's Mask", augments={'Path: A',}}, -- LINKTRI MODIFICATION: full Gleti's balanced TP base
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Mache Earring +1", -- original: "Cessance Earring" (not owned)
        ear2="Brutal Earring",
        body={ name="Gleti's Cuirass", augments={'Path: A',}},
        hands={ name="Gleti's Gauntlets", augments={'Path: A',}},
        ring1="Epona's Ring",
        ring2="Petrov Ring", -- sides swapped 2026-10-23
        back=gear.stp_jse_back,
        waist={ name="Sailfi Belt +1", augments={'Path: A',}},
        legs={ name="Gleti's Breeches", augments={'Path: A',}},
        feet={ name="Gleti's Boots", augments={'Path: A',}}
    }

    -- LINKTRI MODIFICATION: pure-offense Adhemar TP variant (OffenseMode Fodder / overpowered content)
    sets.engaged.Fodder = {
        ammo="Coiste Bodhar", -- original: "Aurgelmir Orb +1" (not owned)
        head="Hashishin Kavuk +3",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Mache Earring +1", -- original: "Cessance Earring" (not owned)
        ear2="Brutal Earring",
        body="Ayanmo Corazza +2", -- original: "Adhemar Jacket +1" (not owned)
        hands="Adhemar Wrist. +1",
        ring1="Epona's Ring",
        ring2="Petrov Ring", -- sides swapped 2026-10-23
        back=gear.stp_jse_back,
        waist={ name="Sailfi Belt +1", augments={'Path: A',}},
        legs={ name="Gleti's Breeches", augments={'Path: A',}},
        feet={ name="Gleti's Boots", augments={'Path: A',}}
    }

    sets.engaged.Acc = {
        ammo="Mantoptera Eye", -- original: "Falcon Eye" (not owned)
        head="Hashishin Kavuk +3",
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Mache Earring +1", -- original: "Cessance Earring" (not owned)
        ear2="Telos Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1="Cacoethic Ring +1", -- Acc+11; original: "Petrov Ring" (ring2-side, Ilabrat already there)
        ring2="Ilabrat Ring",
        back=gear.stp_jse_back,
        waist="Null Belt", -- original: "Grunfeld Rope" (not owned)
        legs="Malignance Tights", -- original: "Carmine Cuisses +1" (not owned)
        feet="Malignance Boots"
    }

    sets.engaged.FullAcc = {
        ammo="Mantoptera Eye", -- original: "Falcon Eye" (not owned)
        head="Malignance Chapeau", -- original: "Carmine Mask +1" (not owned)
        neck="Null Loop", -- original: "Mirage Stole +2" (not owned)
        ear1="Mache Earring +1",
        ear2="Telos Earring",
        body="Assim. Jubbah +2",
        hands="Assim. Bazu. +2",
        ring1="Stikini Ring",
        ring2="Stikini Ring",
        back=gear.stp_jse_back,
        waist="Null Belt", -- original: "Olseni Belt" (not owned)
        legs="Malignance Tights", -- original: "Carmine Cuisses +1" (not owned)
        feet="Malignance Boots"
    }

    -- original name: sets.engaged.PDT (HybridMode is Normal/DT, so it was never used)
    sets.engaged.DT = {
        ammo="Coiste Bodhar", -- original: "Aurgelmir Orb +1" (not owned)
        head="Malignance Chapeau",
        neck="Loricate Torque +1",
        ear1="Mache Earring +1", -- original: "Cessance Earring" (not owned)
        ear2="Brutal Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Defending Ring",
        back=gear.stp_jse_back,
        waist={ name="Sailfi Belt +1", augments={'Path: A',}},
        legs="Malignance Tights",
        feet="Malignance Boots"
    }

    sets.engaged.Acc.DT = sets.engaged.DT
    sets.engaged.FullAcc.DT = sets.engaged.DT
    sets.engaged.Fodder.DT = sets.engaged.DT

    sets.engaged.MDT = {
        ammo="Coiste Bodhar", -- original: "Aurgelmir Orb +1" (not owned)
        head="Malignance Chapeau",
        neck="Loricate Torque +1", -- original: "Warder's Charm +1" (not owned)
        ear1="Mache Earring +1", -- original: "Cessance Earring" (not owned)
        ear2="Brutal Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Defending Ring",
        back=gear.stp_jse_back,
        waist="Carrier's Sash",
        legs="Malignance Tights",
        feet="Malignance Boots"
    }

    -- Special sets

    sets.buff['Burst Affinity'] = {legs="Assim. Shalwar +2", feet="Hashi. Basmak +3"}
    sets.buff['Chain Affinity'] = {feet="Assim. Charuqs +2"}  -- original: +1 (you own the +2)
    sets.buff.Convergence = {head="Luh. Keffiyeh +1"}
    sets.buff.Diffusion = {feet="Luhlaza Charuqs +1"}
    sets.buff.Efflux = {back=gear.nuke_jse_back, legs="Hashishin Tayt +3"}  -- any Rosmerta's Cape has Efflux TP Bonus +250; original back: gear.stp_jse_back

    -- Learning Mode set
    sets.Learning = {hands="Assim. Bazu. +2"}

    -- Magic Burst set
    sets.MagicBurst = {
        body="Samnuha Coat",
        -- hands="Amalric Gages +1", -- removed: not owned
        legs="Assim. Shalwar +2",
        ring1="Jhakri Ring", -- original: "Mujin Band" (not owned)
        -- ring2="Locus Ring", -- removed: not owned
    }

    -- Element-based gear
    sets.element = {}
    sets.element.Dark = {head="Pixie Hairpin +1"}  -- original: + ring2="Archon Ring" (not owned)
    sets.element.Light = {} -- Add light-based gear if available

    -- Utility sets
    sets.Cure_Received = {
        -- neck="Phalaina Locket", -- removed: not owned
        -- hands="Buremte Gloves", -- removed: not owned
        ring2="Menelaus's Ring", -- original: "Kunaji Ring" (not owned)
        -- waist="Gishdubar Sash", -- removed: not owned
    }

    sets.Self_Refresh = {
        -- back="Grapevine Cape", -- removed: not owned
        -- waist="Gishdubar Sash", -- removed: not owned
    }

    sets.TreasureHunter = {
        legs="Volte Hose", -- TH+1; original: head="Wh. Rarab Cap +1" (not owned)
        waist="Chaac Belt"
    }
	
	-- Reive set (add this to your init_gear_sets() function)
    sets.Reive = {
        neck="Ygnas's Resolve +1"  -- Can be changed to "Arciela's Grace +1" if you have it
    }
	
	-- Packing set for Porter Moogle
sets.packing = {
    main="Vampirism", -- original: "Sequence" (not owned)
    sub="Sakpata's Sword",
    ammo="Staunch Tathlum +1",
    head="Rawhide Mask",
    neck="Loricate Torque +1",
    ear1="Etiolation Earring",
    ear2="Sanare Earring", -- original: "Ethereal Earring" (not owned)
    body="Nyame Mail",
    hands={ name="Nyame Gauntlets", augments={'Path: B'} },
    ring1={ name="Murky Ring", augments={'Path: A',}},
    ring2="Stikini Ring",
    back="Null Shawl", -- original: "Umbra Cape" (not owned)
    waist="Fucho-no-Obi",
    legs={ name="Nyame Flanchard", augments={'Path: B'} },
    feet={ name="Nyame Sollerets", augments={'Path: B'} }
}
    -- LINKTRI MODIFICATION: Bunzi's Rod (R30) + Culminus nuke/magic-burst loadout,
    -- auto-equipped by job_post_midcast() below only while state.Weapons == 'None'
    sets.BunziNuke = {
        main="Bunzi's Rod",  -- original: { name="Bunzi's Rod", augments={'DMG:+11',...}} never matched (yours is Path: A)
        sub="Culminus"
    }

    sets.Kiting = {ring2="Shneddick Ring +1"}  -- original: ring1 (replaced Murky Ring in idle)
end

-- LINKTRI MODIFICATION: Blue Magic spellMaps that should use the Bunzi's Rod / Culminus
-- nuke loadout (magical-damage and magic-accuracy spells only -- NOT Physical spells,
-- which rely on the equipped weapon's own accuracy/DMG and would be hurt by a club swap).
-- LINKTRI MODIFICATION: Orpheus's Sash / Hachirin-no-Obi elemental affinity overlay.
-- Orpheus's Sash affinity: +15 at <=1.93 yalms, tapering to +1 at >=13 yalms (1.01x-1.15x magic dmg).
-- Hachirin-no-Obi: +10 day match, +10 single weather, +25 double weather (stacks with day).
-- Reused from the live-validated BLM implementation (same tuning constants).
local ORPHEUS_MIN_DIST = 1.93   -- distance at which Orpheus gives its max +15
local ORPHEUS_MAX_DIST = 13.0   -- distance beyond which Orpheus gives only +1
local ORPHEUS_MIN_WORTH = 2     -- below this affinity, leave the set's own waist alone

local function nuke_waist_bonus(spell)
    -- Returns the best waist for this cast based on day/weather/distance, or nil to
    -- leave the set's default waist (e.g. Sailfi Belt +1) untouched.
    local el = spell.element
    if not el or el == 'None' then return nil end

    -- Hachirin side: day + weather bonuses
    local obi = 0
    if world.day_element == el then obi = obi + 10 end
    if world.weather_element == el then
        local intensity = 1
        if world.weather_id and gearswap and gearswap.res and gearswap.res.weather
                and gearswap.res.weather[world.weather_id] then
            intensity = gearswap.res.weather[world.weather_id].intensity or 1
        end
        obi = obi + (intensity == 2 and 25 or 10)
    end

    -- Orpheus side: distance-scaled affinity
    local dist = (spell.target and spell.target.distance) or 21
    local aff
    if dist <= ORPHEUS_MIN_DIST then
        aff = 15
    elseif dist >= ORPHEUS_MAX_DIST then
        aff = 1
    else
        aff = math.floor(15 - ((dist - ORPHEUS_MIN_DIST) * (14 / (ORPHEUS_MAX_DIST - ORPHEUS_MIN_DIST))))
    end

    if obi >= aff and obi > 0 then
        return "Hachirin-no-Obi"
    elseif aff >= ORPHEUS_MIN_WORTH then
        return "Orpheus's Sash"
    end
    return nil
end

-- Confirmed via BG-Wiki's Elemental Weapon Skill category: these are the only WS in this
-- file that actually gain from Affinity. Requiescat is light-flagged for resistance only
-- and is NOT in that category, so it's deliberately excluded here.
blu_elemental_ws = S{'Flash Nova','Red Lotus Blade','Sanguine Blade','Seraph Blade'}

blu_nuke_spellmaps = S{
    'Magical','MagicalMnd','MagicalChr','MagicalVit','MagicalDex','MagicalAgi',
    'MagicAccuracy','Breath'
}

-- Function to customize idle sets based on current modes and conditions
-- Renamed from job_customize_idle_set (that name replaced BLU.lua's latent-refresh/Learning version)
function user_job_customize_idle_set(idleSet)
    -- Check if near Porter Moogle first
    local currently_near_porter = near_porter_moogle()
    
    if currently_near_porter then
        -- Show message only when entering range
        if not near_porter then
            windower.add_to_chat(160, "Near Porter Moogle - Using packing gear")
            near_porter = true
        end
        return sets.packing
    else
        -- Show message only when leaving range
        if near_porter then
            windower.add_to_chat(160, "Left Porter Moogle area - Returning to normal gear")
            near_porter = false
        end
    end

    -- LINKTRI FIX (Jul 2026): this function previously returned idleSet unchanged outside
    -- Porter Moogle range, silently never applying custom IdleMode variants (Sphere, PDT,
    -- DTHippo). Confirmed live via //gs equipset: selecting DTHippo equipped plain sets.idle
    -- (Jhakri Robe +2 body) instead of sets.idle.DTHippo (Adamantite Armor body). This combines
    -- the matching sets.idle[ModeName] override on top whenever one exists.
    if state.IdleMode.value ~= 'Normal' and sets.idle[state.IdleMode.value] then
        idleSet = set_combine(idleSet, sets.idle[state.IdleMode.value])
    end

    return idleSet
end

-- LINKTRI MODIFICATION: additions to BLU.lua's job_post_precast / job_post_midcast.
-- These run AFTER BLU.lua's own versions (Moonshade TP-cap swap, Chain Affinity etc., Learning gear),
-- so only the additions live here. (Previously full copies of BLU.lua's functions.)
function user_job_post_precast(spell, spellMap, eventArgs)
    if state.LearningMode.value then return end
    -- Orpheus's Sash / Hachirin-no-Obi for confirmed elemental weaponskills
    if spell.type == 'WeaponSkill' and blu_elemental_ws:contains(spell.english) then
        local waist_bonus = nuke_waist_bonus(spell)
        if waist_bonus then equip({waist=waist_bonus}) end
    end
end

function user_job_post_midcast(spell, spellMap, eventArgs)
    if eventArgs.handled or state.LearningMode.value or spell.skill ~= 'Blue Magic' then return end
    -- Bunzi's Rod + Culminus nuke swap (unweaponed / 'None' mode only)
    if state.Weapons.value == 'None' and blu_nuke_spellmaps:contains(spellMap) then
        equip(sets.BunziNuke)
    end
    -- Orpheus's Sash / Hachirin-no-Obi elemental affinity overlay
    local waist_bonus = nuke_waist_bonus(spell)
    if waist_bonus then equip({waist=waist_bonus}) end
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'DNC' then
        set_macro_page(1, 16)
    elseif player.sub_job == 'NIN' then
        set_macro_page(1, 16)
    elseif player.sub_job == 'WAR' then
        set_macro_page(1, 16)
    elseif player.sub_job == 'RUN' then
        set_macro_page(1, 16)
    elseif player.sub_job == 'THF' then
        set_macro_page(1, 16)
    elseif player.sub_job == 'RDM' then
        set_macro_page(1, 16)
    else
        set_macro_page(1, 16)
    end
end

-- Porter Moogle detection function
function near_porter_moogle()
    local mobs = windower.ffxi.get_mob_array()
    for i, mob in pairs(mobs) do
        if mob.name == "Porter Moogle" and mob.distance and mob.distance < 36 then
            return true
        end
    end
    return false
end