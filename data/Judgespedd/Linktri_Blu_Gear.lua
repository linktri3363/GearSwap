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
    state.Weapons:options(
        "Tizbron",
        "Tizalmace", 
        "None",
        "Almace",
        "MeleeClubs",
        "HybridWeapons",
        "Naegbron",
        "Naegmace"
    )

    state.ExtraMeleeMode = M {["description"] = "Extra Melee Mode", "None", "MP", "SuppaBrutal", "DWEarrings", "DWMax"}

    -- JSE Capes (keep original naming for compatibility)
    gear.da_jse_back = {
        name = "Rosmerta's Cape",
        augments = {"DEX+20", "Accuracy+20 Attack+20", "Accuracy+10", '"Dbl.Atk."+10'}
    }
    gear.stp_jse_back = {
        name = "Rosmerta's Cape",
        augments = {"DEX+20", "Accuracy+20 Attack+20", "Accuracy+10", '"Store TP"+10'}
    }
    gear.crit_jse_back = {
        name = "Rosmerta's Cape",
        augments = {"DEX+20", "Accuracy+20 Attack+20", "DEX+10", "Crit.hit rate+10"}
    }
    gear.wsd_jse_back = {
        name = "Rosmerta's Cape",
        augments = {"STR+20", "Accuracy+20 Attack+20", "STR+10", "Weapon skill damage +10%"}
    }
    gear.nuke_jse_back = {
        name = "Rosmerta's Cape",
        augments = {'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Mag.Atk.Bns."+10','Spell interruption rate down-10%',}
    }

    autows = "Expiacion"

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
    send_command("bind @q gs c weapons MaccWeapons;gs c update")
    send_command("bind ^q gs c weapons Almace;gs c update")
    send_command("bind !q gs c weapons HybridWeapons;gs c update")

    select_default_macro_book()
end

function init_gear_sets()
sets.weapons = {}

sets.weapons.Tizbron = {
    main="Qutrub Knife",
    sub="Ethereal Dagger"
}

sets.weapons.Tizalmace = {
    main="Tizona",
    sub="Almace"
}

sets.weapons.Almace = {
    main="Almace",
    sub="Brongniart"
}

sets.weapons.MeleeClubs = {
    main="Maxentius",
    sub="Bunzi's Rod"
}

sets.weapons.HybridWeapons = {
    main="Sequence",
    sub="Almace"
}

sets.weapons.Naegbron = {
    main="Naegling",
    sub="Brongniart"
}

sets.weapons.Naegmace = {
    main="Naegling",
    sub="Almace"
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
        head="Carmine Mask +1",
        neck="Voltsurge Torque",
        ear1="Enchntr. Earring +1",
        ear2="Loquac. Earring",
        body="Luhlaza Jubbah +1",
        hands="Leyline Gloves",
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back="Perimede Cape",
        waist="Witful Belt",
        legs="Aya. Cosciales +2",
        feet="Carmine Greaves +1"
    }

    sets.precast.FC['Blue Magic'] = set_combine(sets.precast.FC, {body="Hashishin Mintan +2"})

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {body="Passion Jacket"})

    -- Weaponskill sets
    sets.precast.WS = {
        ammo="Aurgelmir Orb +1",
        head="Lilitu Headpiece",
        neck="Mirage Stole +2",
        ear1="Cessance Earring",
        ear2="Brutal Earring",
        body="Adhemar Jacket +1",
        hands="Jhakri Cuffs +2",
        ring1="Epona's Ring",
        ring2="Apate Ring",
        back=gear.da_jse_back,
        waist="Kentarch Belt +1",
        legs="Samnuha Tights",
        feet="Malignance Boots"
    }

    sets.precast.WS.Acc = {
        ammo="Falcon Eye",
        head="Carmine Mask +1",
        neck="Mirage Stole +2",
        ear1="Mache Earring +1",
        ear2="Telos Earring",
        body="Assim. Jubbah +2",
        hands="Assim. Bazu. +2",
        ring1="Epona's Ring",
        ring2="Ilabrat Ring",
        back=gear.da_jse_back,
        waist="Kentarch Belt +1",
        legs="Carmine Cuisses +1",
        feet="Malignance Boots"
    }

    sets.precast.WS.FullAcc = {
        ammo="Falcon Eye",
        head="Carmine Mask +1",
        neck="Mirage Stole +2",
        ear1="Mache Earring +1",
        ear2="Odr Earring",
        body="Assim. Jubbah +2",
        hands="Assim. Bazu. +2",
        ring1="Stikini Ring +1",
        ring2="Stikini Ring +1",
        back=gear.da_jse_back,
        waist="Olseni Belt",
        legs="Carmine Cuisses +1",
        feet="Malignance Boots"
    }

    sets.precast.WS.DT = {
        ammo="Aurgelmir Orb +1",
        head="Malignance Chapeau",
        neck="Loricate Torque +1",
        ear1="Cessance Earring",
        ear2="Brutal Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Defending Ring",
        back=gear.da_jse_back,
        waist="Kentarch Belt +1",
        legs="Malignance Tights",
        feet="Malignance Boots"
    }

    sets.precast.WS.Fodder = {
        ammo="Aurgelmir Orb +1",
        head="Lilitu Headpiece",
        neck="Mirage Stole +2",
        ear1="Cessance Earring",
        ear2="Brutal Earring",
        body="Adhemar Jacket +1",
        hands="Jhakri Cuffs +2",
        ring1="Epona's Ring",
        ring2="Apate Ring",
        back=gear.da_jse_back,
        waist="Kentarch Belt +1",
        legs="Samnuha Tights",
        feet="Malignance Boots"
    }

    -- Specific weaponskill sets
    sets.precast.WS["Requiescat"] = set_combine(sets.precast.WS, {
        head="Jhakri Coronal +2",
        ear1="Regal Earring",
        body="Jhakri Robe +2",
        ring2={ name="Metamor. Ring +1", augments={'Path: A',}},
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    })

    sets.precast.WS["Requiescat"].Acc = set_combine(sets.precast.WS.Acc, {
        head="Jhakri Coronal +2",
        ear1="Regal Earring",
        body="Jhakri Robe +2",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    })

    sets.precast.WS["Chant du Cygne"] = set_combine(sets.precast.WS, {
        head="Hashishin Kavuk +2",
        neck="Mirage Stole +2",
        ear1="Mache Earring +1",
        ear2="Odr Earring",
        body="Adhemar Jacket +1",
        hands="Adhemar Wrist. +1",
        ring1="Epona's Ring",
        ring2="Begrudging Ring",
        back=gear.crit_jse_back,
        waist="Reiki Yotai",
        legs={ name="Gleti's Breeches", augments={'Path: A',}},
        feet={ name="Gleti's Boots", augments={'Path: A',}}
    })

    sets.precast.WS["Chant du Cygne"].Acc = set_combine(sets.precast.WS.Acc, {
        head="Hashishin Kavuk +2",
        ear1="Mache Earring +1",
        ear2="Odr Earring",
        body="Adhemar Jacket +1",
        hands="Adhemar Wrist. +1",
        ring2="Begrudging Ring",
        back=gear.crit_jse_back,
        waist="Reiki Yotai",
        legs={ name="Gleti's Breeches", augments={'Path: A',}},
        feet={ name="Gleti's Boots", augments={'Path: A',}}
    })

    sets.precast.WS["Savage Blade"] = set_combine(sets.precast.WS, {
        ammo="Aurgelmir Orb +1",
        head="Hashishin Kavuk +2",
        neck="Mirage Stole +2",
        ear1="Moonshade Earring",
        ear2="Ishvara Earring",
        body={ name="Nyame Mail", augments={'Path: B'} },
        hands={ name="Nyame Gauntlets", augments={'Path: B'} },
        ring1="Epaminondas's Ring",
        ring2="Beithir Ring",
        back=gear.wsd_jse_back,
        waist={ name="Sailfi Belt +1", augments={'Path: A',}},
        legs={ name="Nyame Flanchard", augments={'Path: B'} },
        feet={ name="Nyame Sollerets", augments={'Path: B'} }
    })

    sets.precast.WS["Savage Blade"].Acc = set_combine(sets.precast.WS.Acc, {
        head="Hashishin Kavuk +2",
        neck="Mirage Stole +2",
        ear1="Moonshade Earring",
        ear2="Ishvara Earring",
        body={ name="Nyame Mail", augments={'Path: B'} },
        hands={ name="Nyame Gauntlets", augments={'Path: B'} },
        ring1="Epaminondas's Ring",
        ring2="Beithir Ring",
        back=gear.wsd_jse_back,
        waist={ name="Sailfi Belt +1", augments={'Path: A',}},
        legs={ name="Nyame Flanchard", augments={'Path: B'} },
        feet={ name="Nyame Sollerets", augments={'Path: B'} }
    })

    sets.precast.WS["Expiacion"] = set_combine(sets.precast.WS["Savage Blade"], {})

    sets.precast.WS["Expiacion"].Acc = set_combine(sets.precast.WS["Savage Blade"].Acc, {})

    sets.precast.WS["Sanguine Blade"] = {
        ammo="Ghastly Tathlum +1",
        head="Hashishin Kavuk +2",
        neck="Sibyl Scarf",
        ear1="Regal Earring",
        ear2="Friomisi Earring",
        body={ name="Nyame Mail", augments={'Path: B'} },
        hands="Jhakri Cuffs +2",
        ring1="Epaminondas's Ring",
        ring2="Archon Ring",
        back=gear.nuke_jse_back,
        waist="Orpheus's Sash",
        legs={ name="Luhlaza Shalwar +1", augments={'Enhances "Assimilation" effect',}},
        feet="Hashi. Basmak +2"
    }

    sets.precast.WS["Red Lotus Blade"] = set_combine(sets.precast.WS["Sanguine Blade"], {
        ring2="Beithir Ring"
    })

    sets.precast.WS["Seraph Blade"] = set_combine(sets.precast.WS["Red Lotus Blade"], {})

    sets.precast.WS["Flash Nova"] = set_combine(sets.precast.WS["Red Lotus Blade"], {})

    -- Midcast Sets
    sets.midcast.FastRecast = {
        ammo="Impatiens",
        head="Carmine Mask +1",
        neck="Voltsurge Torque",
        ear1="Enchntr. Earring +1",
        ear2="Loquac. Earring",
        body="Luhlaza Jubbah +1",
        hands="Leyline Gloves",
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back="Perimede Cape",
        waist="Witful Belt",
        legs="Aya. Cosciales +2",
        feet="Carmine Greaves +1"
    }

    -- Blue Magic Skill for learning spells
    sets.midcast['Blue Magic'].Learning = {
        hands="Assim. Bazu. +2"
    }

    -- Physical Blue Magic
    sets.midcast['Blue Magic'].Physical = {
        ammo="Aurgelmir Orb +1",
        head="Hashishin Kavuk +2",
        neck="Mirage Stole +2",
        ear1="Cessance Earring",
        ear2="Brutal Earring",
        body="Hashishin Mintan +2",
        hands="Hashi. Bazu. +2",
        ring1="Epona's Ring",
        ring2="Ilabrat Ring",
        back=gear.da_jse_back,
        waist="Kentarch Belt +1",
        legs="Hashishin Tayt +2",
        feet="Hashi. Basmak +2"
    }

    sets.midcast['Blue Magic'].PhysicalAcc = {
        ammo="Falcon Eye",
        head="Hashishin Kavuk +2",
        neck="Mirage Stole +2",
        ear1="Mache Earring +1",
        ear2="Telos Earring",
        body="Hashishin Mintan +2",
        hands="Hashi. Bazu. +2",
        ring1="Stikini Ring +1",
        ring2="Ilabrat Ring",
        back=gear.da_jse_back,
        waist="Kentarch Belt +1",
        legs="Hashishin Tayt +2",
        feet="Hashi. Basmak +2"
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
        ammo="Ghastly Tathlum +1",
        head="Jhakri Coronal +2",
        neck="Sibyl Scarf",
        ear1="Regal Earring",
        ear2="Friomisi Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring +1",
        ring2="Stikini Ring +1",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast['Blue Magic'].Magical.Resistant = {
        ammo="Ghastly Tathlum +1",
        head="Jhakri Coronal +2",
        neck="Mirage Stole +2",
        ear1="Regal Earring",
        ear2="Digni. Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring +1",
        ring2="Stikini Ring +1",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast['Blue Magic'].MagicalMnd = set_combine(sets.midcast['Blue Magic'].Magical, {})

    sets.midcast['Blue Magic'].MagicalChr = set_combine(sets.midcast['Blue Magic'].Magical, {})

    sets.midcast['Blue Magic'].MagicalVit = set_combine(sets.midcast['Blue Magic'].Magical, {})

    sets.midcast['Blue Magic'].MagicalDex = set_combine(sets.midcast['Blue Magic'].Magical, {})

    sets.midcast['Blue Magic'].MagicAccuracy = {
        ammo="Ghastly Tathlum +1",
        head="Jhakri Coronal +2",
        neck="Mirage Stole +2",
        ear1="Regal Earring",
        ear2="Digni. Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring +1",
        ring2="Stikini Ring +1",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    -- Breath Spells
    sets.midcast['Blue Magic'].Breath = {
        ammo="Staunch Tathlum +1",
        head="Jhakri Coronal +2",
        neck="Mirage Stole +2",
        ear1="Etiolation Earring",
        ear2="Sanare Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring +1",
        ring2="Stikini Ring +1",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    -- Buff Blue Magic
    sets.midcast['Blue Magic'].Buff = {
        ammo="Impatiens",
        head="Luh. Keffiyeh +1",
        neck="Voltsurge Torque",
        ear1="Enchntr. Earring +1",
        ear2="Loquac. Earring",
        body="Assim. Jubbah +2",
        hands="Assim. Bazu. +2",
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back="Perimede Cape",
        waist="Witful Belt",
        legs="Hashishin Tayt +2",
        feet="Carmine Greaves +1"
    }

    sets.midcast['Blue Magic']['White Wind'] = {
        ammo="Staunch Tathlum +1",
        head="Jhakri Coronal +2",
        neck="Phalaina Locket",
        ear1="Etiolation Earring",
        ear2="Sanare Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Stikini Ring +1",
        back="Solemnity Cape",
        waist="Gishdubar Sash",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast['Blue Magic']['Battery Charge'] = set_combine(sets.midcast['Blue Magic'].Buff, {
        head="Amalric Coif +1",
        waist="Gishdubar Sash"
    })

    sets.midcast['Blue Magic']['Regeneration'] = set_combine(sets.midcast['Blue Magic'].Buff, {})
    sets.midcast['Blue Magic']['Cocoon'] = set_combine(sets.midcast['Blue Magic'].Buff, {})
    sets.midcast['Blue Magic']['Refueling'] = set_combine(sets.midcast['Blue Magic'].Buff, {})

    sets.midcast['Blue Magic'].Healing = {
        ammo="Staunch Tathlum +1",
        head="Jhakri Coronal +2",
        neck="Phalaina Locket",
        ear1="Etiolation Earring",
        ear2="Menemeus Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Stikini Ring +1",
        back="Solemnity Cape",
        waist="Gishdubar Sash",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast['Blue Magic'].HealingSelf = set_combine(sets.midcast['Blue Magic'].Healing, {
        neck="Phalaina Locket",
        ring2="Kunaji Ring",
        waist="Gishdubar Sash"
    })

    -- Enhancing Magic
    sets.midcast['Enhancing Magic'] = {
        ammo="Impatiens",
        head="Carmine Mask +1",
        neck="Voltsurge Torque",
        ear1="Enchntr. Earring +1",
        ear2="Loquac. Earring",
        body="Luhlaza Jubbah +1",
        hands="Leyline Gloves",
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back="Perimede Cape",
        waist="Witful Belt",
        legs={ name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        feet={ name="Telchine Pigaches", augments={'Mag. Acc.+18','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}}
    }

    sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {
        head="Amalric Coif +1",
        waist="Gishdubar Sash"
    })

    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
        ear1="Earthcry Earring",
        waist="Siegel Sash",
        legs="Shedir Seraweels"
    })

    sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {
        head="Amalric Coif +1",
        hands="Regal Cuffs",
        waist="Emphatikos Rope"
    })

    sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {ring2="Sheltered Ring"})
    sets.midcast.Protectra = sets.midcast.Protect
    sets.midcast.Shell = sets.midcast.Protect
    sets.midcast.Shellra = sets.midcast.Protect

    -- Enfeebling Magic
    sets.midcast['Enfeebling Magic'] = {
        ammo="Ghastly Tathlum +1",
        head="Jhakri Coronal +2",
        neck="Mirage Stole +2",
        ear1="Regal Earring",
        ear2="Digni. Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring +1",
        ring2="Stikini Ring +1",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast['Enfeebling Magic'].Resistant = {
        ammo="Ghastly Tathlum +1",
        head="Jhakri Coronal +2",
        neck="Mirage Stole +2",
        ear1="Regal Earring",
        ear2="Digni. Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring +1",
        ring2="Stikini Ring +1",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast['Dark Magic'] = {
        ammo="Ghastly Tathlum +1",
        head="Jhakri Coronal +2",
        neck="Mirage Stole +2",
        ear1="Regal Earring",
        ear2="Digni. Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring +1",
        ring2="Stikini Ring +1",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast.Stun = {
        ammo="Ghastly Tathlum +1",
        head="Jhakri Coronal +2",
        neck="Mirage Stole +2",
        ear1="Regal Earring",
        ear2="Digni. Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring +1",
        ring2="Stikini Ring +1",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {
        ring1="Evanescence Ring",
        ring2="Archon Ring",
        waist="Fucho-no-Obi"
    })

    sets.midcast.Aspir = sets.midcast.Drain

    -- Elemental Magic
    sets.midcast['Elemental Magic'] = {
        ammo="Ghastly Tathlum +1",
        head="Jhakri Coronal +2",
        neck="Sibyl Scarf",
        ear1="Regal Earring",
        ear2="Friomisi Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring +1",
        ring2="Stikini Ring +1",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }

    sets.midcast['Elemental Magic'].Resistant = {
        ammo="Ghastly Tathlum +1",
        head="Jhakri Coronal +2",
        neck="Mirage Stole +2",
        ear1="Regal Earring",
        ear2="Digni. Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring +1",
        ring2="Stikini Ring +1",
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
        ring2="Stikini Ring +1",
        back="Solemnity Cape",
        waist="Fucho-no-Obi",
        legs="Carmine Cuisses +1",
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
        ring2="Stikini Ring +1",
        back="Solemnity Cape",
        waist="Fucho-no-Obi",
        legs="Malignance Tights",
        feet="Malignance Boots"
    }

    sets.idle.Sphere = set_combine(sets.idle, {
        body="Mekosu. Harness"
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
        ring2="Stikini Ring +1",
        back="Solemnity Cape",
        waist="Fucho-no-Obi",
        legs="Carmine Cuisses +1",
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
        back="Umbra Cape",
        waist="Fucho-no-Obi",
        legs={ name="Nyame Flanchard", augments={'Path: B'} },
        feet={ name="Nyame Sollerets", augments={'Path: B'} }
    }

    sets.defense.MDT = {
        ammo="Staunch Tathlum +1",
        head="Malignance Chapeau",
        neck="Warder's Charm +1",
        ear1="Etiolation Earring",
        ear2="Sanare Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Defending Ring",
        back="Umbra Cape",
        waist="Carrier's Sash",
        legs="Malignance Tights",
        feet="Malignance Boots"
    }

    sets.defense.MEVA = {
        ammo="Staunch Tathlum +1",
        head="Malignance Chapeau",
        neck="Warder's Charm +1",
        ear1="Etiolation Earring",
        ear2="Sanare Earring",
        body="Malignance Tabard",
        hands="Leyline Gloves",
        ring1="Vengeful Ring",
        ring2="Purity Ring",
        back=gear.nuke_jse_back,
        waist="Carrier's Sash",
        legs={ name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        feet="Malignance Boots"
    }

    sets.Kiting = {ring1="Shneddick Ring"}

    -- Engaged sets

    -- Variations for TP build
    sets.engaged = {
        ammo="Aurgelmir Orb +1",
        head="Hashishin Kavuk +2",
        neck="Mirage Stole +2",
        ear1="Cessance Earring",
        ear2="Brutal Earring",
        body="Adhemar Jacket +1",
        hands="Adhemar Wrist. +1",
        ring1="Petrov Ring",
        ring2="Epona's Ring",
        back=gear.stp_jse_back,
        waist={ name="Sailfi Belt +1", augments={'Path: A',}},
        legs={ name="Gleti's Breeches", augments={'Path: A',}},
        feet={ name="Gleti's Boots", augments={'Path: A',}}
    }

    sets.engaged.Acc = {
        ammo="Falcon Eye",
        head="Hashishin Kavuk +2",
        neck="Mirage Stole +2",
        ear1="Cessance Earring",
        ear2="Telos Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1="Petrov Ring",
        ring2="Ilabrat Ring",
        back=gear.stp_jse_back,
        waist="Grunfeld Rope",
        legs="Carmine Cuisses +1",
        feet="Malignance Boots"
    }

    sets.engaged.FullAcc = {
        ammo="Falcon Eye",
        head="Carmine Mask +1",
        neck="Mirage Stole +2",
        ear1="Mache Earring +1",
        ear2="Telos Earring",
        body="Assim. Jubbah +2",
        hands="Assim. Bazu. +2",
        ring1="Stikini Ring +1",
        ring2="Stikini Ring +1",
        back=gear.stp_jse_back,
        waist="Olseni Belt",
        legs="Carmine Cuisses +1",
        feet="Malignance Boots"
    }

    sets.engaged.PDT = {
        ammo="Aurgelmir Orb +1",
        head="Malignance Chapeau",
        neck="Loricate Torque +1",
        ear1="Cessance Earring",
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

    sets.engaged.MDT = {
        ammo="Aurgelmir Orb +1",
        head="Malignance Chapeau",
        neck="Warder's Charm +1",
        ear1="Cessance Earring",
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

    sets.buff['Burst Affinity'] = {legs="Assim. Shalwar +2", feet="Hashi. Basmak +2"}
    sets.buff['Chain Affinity'] = {feet="Assim. Charuqs +1"}
    sets.buff.Convergence = {head="Luh. Keffiyeh +1"}
    sets.buff.Diffusion = {feet="Luhlaza Charuqs +1"}
    sets.buff.Efflux = {back=gear.stp_jse_back, legs="Hashishin Tayt +2"}

    -- Learning Mode set
    sets.Learning = {hands="Assim. Bazu. +2"}

    -- Magic Burst set
    sets.MagicBurst = {
        body="Samnuha Coat",
        hands="Amalric Gages +1",
        legs="Assim. Shalwar +2",
        ring1="Mujin Band",
        ring2="Locus Ring"
    }

    -- Element-based gear
    sets.element = {}
    sets.element.Dark = {head="Pixie Hairpin +1", ring2="Archon Ring"}
    sets.element.Light = {} -- Add light-based gear if available

    -- Utility sets
    sets.Cure_Received = {
        neck="Phalaina Locket",
        hands="Buremte Gloves",
        ring2="Kunaji Ring",
        waist="Gishdubar Sash"
    }

    sets.Self_Refresh = {
        back="Grapevine Cape",
        waist="Gishdubar Sash"
    }

    sets.TreasureHunter = {
        head="Wh. Rarab Cap +1",
        waist="Chaac Belt"
    }
	
	-- Reive set (add this to your init_gear_sets() function)
    sets.Reive = {
        neck="Ygnas's Resolve +1"  -- Can be changed to "Arciela's Grace +1" if you have it
    }
	
	-- Packing set for Porter Moogle
sets.packing = {
    main="Sequence",
    sub="Sakpata's Sword",
    ammo="Staunch Tathlum +1",
    head="Rawhide Mask",
    neck="Loricate Torque +1",
    ear1="Etiolation Earring",
    ear2="Ethereal Earring",
    body="Jhakri Robe +2",
    hands={ name="Nyame Gauntlets", augments={'Path: B'} },
    ring1={ name="Murky Ring", augments={'Path: A',}},
    ring2="Stikini Ring +1",
    back="Umbra Cape",
    waist="Fucho-no-Obi",
    legs={ name="Nyame Flanchard", augments={'Path: B'} },
    feet={ name="Nyame Sollerets", augments={'Path: B'} }
}
end

-- Function to customize idle sets based on current modes and conditions
function job_customize_idle_set(idleSet)
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
    
    return idleSet
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