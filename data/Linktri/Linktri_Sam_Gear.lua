fixed_pos = ''
fixed_ts = os.time()
local no_interruptions = true
local near_porter = false  -- Track Porter Moogle proximity state
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

-- Setup vars that are user-dependent.
function user_job_setup()
    state.OffenseMode:options("Normal", "SomeAcc", "Acc", "FullAcc", "Fodder")
    state.HybridMode:options("Normal", "DTLite", "PDT")
    state.WeaponskillMode:options("Match", "Normal", "SomeAcc", "Acc", "FullAcc", "Fodder", "Proc")
    state.RangedMode:options("Normal", "Acc")
    state.PhysicalDefenseMode:options("PDT")
    state.MagicalDefenseMode:options("MDT")
    state.ResistDefenseMode:options("MEVA")
    state.IdleMode:options("Normal")
    state.Weapons:options("Dojikiri", "ProcWeapon", "Bow")

    gear.ws_jse_back = "Null Shawl"
    gear.stp_jse_back = "Null Shawl"
    -- Additional local binds
    send_command('bind ^` input /ja "Hasso" <me>')
    send_command('bind !` input /ja "Seigan" <me>')
    send_command('bind !backspace input /ja "Third Eye" <me>')
    send_command("bind @` gs c cycle SkillchainMode")
    send_command("bind !@^` gs c cycle Stance")
    send_command(
        "bind !r gs c set skipprocweapons false;gs c weapons ProcWeapon;gs c set WeaponskillMode Proc;gs c update"
    )
    send_command(
        "bind ^r gs c set skipprocweapons true;gs c weapons Default;gs c set WeaponskillMode Normal;gs c update"
    )
    send_command("bind ^q gs c weapons Bow;gs c update")

    select_default_macro_book()
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Precast Sets
    -- Precast sets to enhance JAs
    sets.precast.JA.Meditate = {head = "Wakido Kabuto +1", hands = "Sakonji Kote +1", back = gear.ws_jse_back}
    sets.precast.JA["Warding Circle"] = {head = "Wakido Kabuto +1"}
    sets.precast.JA["Blade Bash"] = {hands = "Sakonji Kote +1"}
    sets.precast.JA["Sekkanoki"] = {hands = "Kasuga Kote +2"}
    sets.precast.JA["Sengikori"] = {feet = "Kasuga Sune-Ate +2"}

    sets.precast.Step = {
        head = "Flam. Zucchetto +2",
        neck = "Moonbeam Nodowa",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = "Sakonji Domaru +3",
        hands = "Flam. Manopolas +2",
        ring1 = "Ramuh Ring +1",
        ring2 = "Ramuh Ring +1",
        back = gear.stp_jse_back,
        waist = "Olseni Belt",
        legs = "Wakido Haidate +1",
        feet = "Wakido Sune-Ate +1"
    }
    sets.precast.JA["Violent Flourish"] = {
        ammo = "Pemphredo Tathlum",
        head = "Flam. Zucchetto +2",
        neck = "Sanctity Necklace",
        ear1 = "Digni. Earring",
        ear2 = "Moonshade Earring",
        body = "Flamma Korazin +2",
        hands = "Flam. Manopolas +2",
        ring1 = "Ramuh Ring +1",
        ring2 = "Ramuh Ring +1",
        back = gear.ws_jse_back,
        waist = "Eschan Stone",
        legs = "Flamma Dirs +2",
        feet = "Flam. Gambieras +2"
    }

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {
        head = "Flam. Zucchetto +2",
        neck = "Unmoving Collar",
        ear1 = "Handler's Earring +1",
        ear2 = "Handler's Earring",
        body = "Tartarus Platemail",
        hands = "Flam. Manopolas +2",
        ring1 = "Asklepian Ring",
        ring2 = "Valseur's Ring",
        back = "Moonlight Cape",
        waist = "Reiki Yotai",
        legs = "Wakido Haidate +1",
        feet = "Flam. Gambieras +2"
    }

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz["Healing Waltz"] = {}

    -- Fast cast sets for spells
    sets.precast.FC = {
        neck = "Voltsurge Torque",
        ear1 = "Enchntr. Earring +1",
        ear2 = "Loquac. Earring",
        hands = "Leyline Gloves",
        body = "Sacro Breastplate",
        ring1 = "Lebeche Ring",
        ring2 = "Prolix Ring"
    }

    -- Ranged snapshot gear
    sets.precast.RA = {}

    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        ammo = "Knobkierrie",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = "Asperity Necklace",
        ear1 = "Ishvara Earring",
        ear2 = "Moonshade Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = "Ephramad's Ring",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = "Reiki Yotai",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }
    sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {head = "Flam. Zucchetto +2"})
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {head = "Flam. Zucchetto +2", ear1 = "Brutal Earring"})
    sets.precast.WS.FullAcc =
        set_combine(sets.precast.WS, {head = "Flam. Zucchetto +2", ear1 = "Brutal Earring", ring2 = "Petrov Ring"})
    sets.precast.WS.Fodder = set_combine(sets.precast.WS, {})

    sets.precast.WS.Proc = {
        ammo = "Hasty Pinion +1",
        head = "Flam. Zucchetto +2",
        neck = "Asperity Necklace",
        ear1 = "Ishvara Earring",
        ear2 = "Brutal Earring",
        body = "Tartarus Platemail",
        hands = "Flam. Manopolas +2",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = "Ioskeha Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = "Flam. Gambieras +2"
    }

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS["Tachi: Fudo"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Tachi: Fudo"].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS["Tachi: Fudo"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Tachi: Fudo"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Tachi: Fudo"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS["Tachi: Shoha"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Tachi: Shoha"].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS["Tachi: Shoha"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Tachi: Shoha"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Tachi: Shoha"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS["Tachi: Rana"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Tachi: Rana"].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS["Tachi: Rana"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Tachi: Rana"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Tachi: Rana"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS["Tachi: Kasha"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Tachi: Kasha"].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS["Tachi: Kasha"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Tachi: Kasha"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Tachi: Kasha"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS["Tachi: Gekko"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Tachi: Gekko"].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS["Tachi: Gekko"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Tachi: Gekko"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Tachi: Gekko"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS["Tachi: Yukikaze"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Tachi: Yukikaze"].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS["Tachi: Yukikaze"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Tachi: Yukikaze"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Tachi: Yukikaze"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS["Tachi: Ageha"] = {
        ammo = "Pemphredo Tathlum",
        head = "Flam. Zucchetto +2",
        neck = "Sanctity Necklace",
        ear1 = "Digni. Earring",
        ear2 = "Moonshade Earring",
        body = "Flamma Korazin +2",
        hands = "Flam. Manopolas +2",
        ring1 = "Ramuh Ring +1",
        ring2 = "Ramuh Ring +1",
        back = gear.ws_jse_back,
        waist = "Eschan Stone",
        legs = "Flamma Dirs +2",
        feet = "Flam. Gambieras +2"
    }

    sets.precast.WS["Tachi: Hobaku"] = {
        ammo = "Pemphredo Tathlum",
        head = "Flam. Zucchetto +2",
        neck = "Sanctity Necklace",
        ear1 = "Digni. Earring",
        ear2 = "Moonshade Earring",
        body = "Flamma Korazin +2",
        hands = "Flam. Manopolas +2",
        ring1 = "Ramuh Ring +1",
        ring2 = "Ramuh Ring +1",
        back = gear.ws_jse_back,
        waist = "Eschan Stone",
        legs = "Flamma Dirs +2",
        feet = "Flam. Gambieras +2"
    }

    sets.precast.WS["Tachi: Jinpu"] = {
        ammo = "Knobkierrie",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = "Sibyl Scarf",
        ear1 = "Friomisi Earring",
        ear2 = "Moonshade Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = "Ephramad's Ring",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = "Eschan Stone",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name="Nyame Sollerets", augments={'Path: B',}},
    }

    sets.precast.WS["Apex Arrow"] = {
        head = "Ynglinga Sallet",
        neck = "Asperity Necklace",
        ear1 = "Clearview Earring",
        ear2 = "Moonshade Earring",
        body = "Kyujutsugi",
        hands = "Buremte Gloves",
        ring1 = "Ephramad's Ring",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = "Reiki Yotai",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

    sets.precast.WS["Apex Arrow"].SomeAcc = set_combine(sets.precast.WS["Apex Arrow"], {})
    sets.precast.WS["Apex Arrow"].Acc = set_combine(sets.precast.WS["Apex Arrow"], {})
    sets.precast.WS["Apex Arrow"].FullAcc = set_combine(sets.precast.WS["Apex Arrow"], {})
    sets.precast.WS["Apex Arrow"].Fodder = set_combine(sets.precast.WS["Apex Arrow"], {})

    -- Swap to these on Moonshade using WS if at 3000 TP
    sets.MaxTP = {ear1 = "Ishvara Earring", ear2 = {name = "Schere Earring", augments = {"Path: A"}}}
    sets.AccMaxTP = {ear1 = "Ishvara Earring", ear2 = "Brutal Earring"}
    sets.AccDayMaxTPWSEars = {ear1 = "Ishvara Earring", ear2 = "Brutal Earring"}
    sets.DayMaxTPWSEars = {ear1 = "Ishvara Earring", ear2 = "Brutal Earring"}
    sets.AccDayWSEars = {ear1 = "Ishvara Earring", ear2 = "Brutal Earring"}
    sets.DayWSEars = {ear1 = "Ishvara Earring", ear2 = "Moonshade Earring"}

    -- Midcast Sets
    sets.midcast.FastRecast = {
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = "Voltsurge Torque",
        ear1 = "Enchntr. Earring +1",
        ear2 = "Loquac. Earring",
        body = "Tartarus Platemail",
        hands = "Leyline Gloves",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Prolix Ring",
        back = "Moonlight Cape",
        waist = "Tempus Fugit",
        legs = "Wakido Haidate +1",
        feet = "Amm Greaves"
    }

    -- Specific spells
    sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {back = "Mujin Mantle"})

    -- Ranged gear
    sets.midcast.RA = {
        head = "Flam. Zucchetto +2",
        neck = "Combatant's Torque",
        ear1 = "Clearview Earring",
        ear2 = "Neritic Earring",
        body = "Kyujutsugi",
        hands = "Buremte Gloves",
        ring1 = "Ilabrat Ring",
        ring2 = "Regal Ring",
        back = gear.stp_jse_back,
        waist = "Carrier's Sash",
        legs = "Wakido Haidate +1",
        feet = "Wakido Sune. +1"
    }

    sets.midcast.RA.Acc = {
        head = "Flam. Zucchetto +2",
        neck = "Combatant's Torque",
        ear1 = "Clearview Earring",
        ear2 = "Neritic Earring",
        body = "Kyujutsugi",
        hands = "Buremte Gloves",
        ring1 = "Ilabrat Ring",
        ring2 = "Regal Ring",
        back = gear.stp_jse_back,
        waist = "Carrier's Sash",
        legs = "Wakido Haidate +1",
        feet = "Wakido Sune. +1"
    }

    -- Sets to return to when not performing an action.

    -- Resting sets
    sets.resting = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Sacro Breastplate",
        hands = "Sakonji Kote +1",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Dark Ring",
        back = "Moonlight Cape",
        waist = "Flume Belt +1",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = "Flam. Gambieras +2"
    }

    -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)

    sets.Kiting = {feet = "Danzo Sune-ate"}

    sets.Reraise = {head = "Twilight Helm", body = "Twilight Mail"}

    sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
    sets.Skillchain = {}

    sets.idle = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Kasuga Domaru +2",
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Dark Ring",
        back = "Moonlight Cape",
        waist = "Flume Belt +1",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = "Danzo Sune-ate"
    }

    sets.idle.Weak = {
        ammo = "Staunch Tathlum +1",
        head = "Twilight Helm",
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Twilight Mail",
        hands = "Sakonji Kote +1",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Dark Ring",
        back = "Moonlight Cape",
        waist = "Flume Belt +1",
        legs = "Flamma Dirs +2",
        feet = "Danzo Sune-ate"
    }

    -- Porter Moogle packing set
    sets.packing = {
        main = "Dojikiri Yasutsuna",
        sub = "Utu Grip",
        ammo = "Staunch Tathlum +1",
        head = "Null Masque",
        neck = "Sibyl Scarf",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Dark Ring",
        back = "Moonlight Cape",
        waist = "Flume Belt +1",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.DayIdle = {}
    sets.NightIdle = {}

    -- Defense sets
    sets.defense.PDT = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Patricius Ring",
        back = "Moonlight Cape",
        waist = "Ioskeha Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

    sets.defense.MDT = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = "Warder's Charm +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Shadow Ring",
        back = "Moonlight Cape",
        waist = "Carrier's Sash",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

    sets.defense.MEVA = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = "Warder's Charm +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Shadow Ring",
        back = "Moonlight Cape",
        waist = "Carrier's Sash",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    -- Normal melee group
    -- Optimized for Store TP and Haste to achieve 5-hit builds
    sets.engaged = {
        ammo = { name="Coiste Bodhar", augments={'Path: A',}},
		head	= "Kasuga Kabuto +2",
		body	= "Kasuga Domaru +2",
        neck = "Asperity Necklace",
        ear1 = "Cessance Earring",
        ear2 = {name = "Kasuga Earring +1",augments = {"System: 1 ID: 1676 Val: 0", "Accuracy+14", "Mag. Acc.+14", "Weapon skill damage +3%"}
        },

        hands = {name = "Mpaca's Gloves", augments = {"Path: A"}},
        ring1 = "Petrov Ring",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = "Reiki Yotai",
        legs = {name = "Mpaca's Hose", augments = {"Path: A"}},
        feet = "Flam. Gambieras +2"
    }
    sets.engaged.SomeAcc = {
        ammo = "Aurgelmir Orb +1",
        head = "Flam. Zucchetto +2",
        neck = "Asperity Necklace",
        ear1 = "Brutal Earring",
        ear2 = {
            name = "Kasuga Earring +1",
            augments = {"System: 1 ID: 1676 Val: 0", "Accuracy+14", "Mag. Acc.+14", "Weapon skill damage +3%"}
        },
        body = "Kasuga Domaru +2",
        hands = {name = "Mpaca's Gloves", augments = {"Path: A"}},
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = "Reiki Yotai",
        legs = {name = "Mpaca's Hose", augments = {"Path: A"}},
        feet = "Flam. Gambieras +2"
    }
    sets.engaged.Acc = {
        ammo = "Aurgelmir Orb +1",
        head = "Flam. Zucchetto +2",
        neck = "Asperity Necklace",
        ear1 = "Brutal Earring",
        ear2 = {
            name = "Kasuga Earring +1",
            augments = {"System: 1 ID: 1676 Val: 0", "Accuracy+14", "Mag. Acc.+14", "Weapon skill damage +3%"}
        },
        body = "Kasuga Domaru +2",
        hands = {name = "Mpaca's Gloves", augments = {"Path: A"}},
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = "Reiki Yotai",
        legs = {name = "Mpaca's Hose", augments = {"Path: A"}},
        feet = "Flam. Gambieras +2"
    }
    sets.engaged.FullAcc = {
        ammo = "Aurgelmir Orb +1",
        head = "Flam. Zucchetto +2",
        neck = "Asperity Necklace",
        ear1 = "Steelflash Earring",
        ear2 = {
            name = "Kasuga Earring +1",
            augments = {"System: 1 ID: 1676 Val: 0", "Accuracy+14", "Mag. Acc.+14", "Weapon skill damage +3%"}
        },
        body = "Kasuga Domaru +2",
        hands = {name = "Mpaca's Gloves", augments = {"Path: A"}},
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = "Reiki Yotai",
        legs = {name = "Mpaca's Hose", augments = {"Path: A"}},
        feet = "Flam. Gambieras +2"
    }
    sets.engaged.Fodder = {
        ammo = "Aurgelmir Orb +1",
        head = "Flam. Zucchetto +2",
        neck = "Asperity Necklace",
        ear1 = "Cessance Earring",
        ear2 = {
            name = "Kasuga Earring +1",
            augments = {"System: 1 ID: 1676 Val: 0", "Accuracy+14", "Mag. Acc.+14", "Weapon skill damage +3%"}
        },
        body = "Kasuga Domaru +2",
        hands = {name = "Mpaca's Gloves", augments = {"Path: A"}},
        ring1 = "Ephramad's Ring",
        ring2 = "Petrov Ring",
        back = "Null Shawl",
        waist = "Reiki Yotai",
        legs = {name = "Mpaca's Hose", augments = {"Path: A"}},
        feet = "Flam. Gambieras +2"
    }
    sets.engaged.PDT = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Patricius Ring",
        back = "Moonlight Cape",
        waist = "Ioskeha Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }
    sets.engaged.SomeAcc.PDT = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Patricius Ring",
        back = "Moonlight Cape",
        waist = "Ioskeha Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }
    sets.engaged.Acc.PDT = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Patricius Ring",
        back = "Moonlight Cape",
        waist = "Ioskeha Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }
    sets.engaged.FullAcc.PDT = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Patricius Ring",
        back = "Moonlight Cape",
        waist = "Ioskeha Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }
    sets.engaged.Fodder.PDT = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Patricius Ring",
        back = "Moonlight Cape",
        waist = "Ioskeha Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }
    sets.engaged.DTLite = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Cessance Earring",
        ear2 = "Brutal Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Patricius Ring",
        back = "Moonlight Cape",
        waist = "Ioskeha Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }
    sets.engaged.SomeAcc.DTLite = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Cessance Earring",
        ear2 = "Telos Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Patricius Ring",
        back = "Moonlight Cape",
        waist = "Ioskeha Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }
    sets.engaged.Acc.DTLite = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Digni. Earring",
        ear2 = "Telos Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Patricius Ring",
        back = "Moonlight Cape",
        waist = "Ioskeha Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }
    sets.engaged.FullAcc.DTLite = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Patricius Ring",
        back = "Moonlight Cape",
        waist = "Ioskeha Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }
    sets.engaged.Fodder.DTLite = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Dedition Earring",
        ear2 = "Brutal Earring",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Patricius Ring",
        back = "Moonlight Cape",
        waist = "Ioskeha Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

    -- Melee sets for in Adoulin, which has an extra 10 Save TP for weaponskills.
    -- Using same sets as non-Adoulin for now

    -- Weapons sets
    sets.weapons.Dojikiri = {main = "Dojikiri Yasutsuna", sub = "Utu Grip"}
    sets.weapons.ProcWeapon = {main = "Hachimonji", sub = "Bloodrain Strap"}
    sets.weapons.Bow = {main = "Shining One"}

    -- Buff sets
    sets.Cure_Received = {hands = "Buremte Gloves", waist = "Gishdubar Sash", legs = "Flamma Dirs +2"}
    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Sleep = {neck = "Vim Torque +1"}
    sets.buff.Hasso = {hands = "Wakido Kote +1"}
    sets.buff["Third Eye"] = {} --legs="Sakonji Haidate +3"
    sets.buff.Sekkanoki = {hands = "Kasuga Kote +2"}
    sets.buff.Sengikori = {feet = "Kasuga Sune-Ate +2"}
    sets.buff["Meikyo Shisui"] = {feet = "Sak. Sune-Ate +1"}
end

-- Porter Moogle proximity detection function
function near_porter_moogle()
    local mobs = windower.ffxi.get_mob_array()
    for i, mob in pairs(mobs) do
        if mob.name == "Porter Moogle" and mob.distance and mob.distance < 36 then
            return true
        end
    end
    return false
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
    if player.sub_job == "DNC" then
        set_macro_page(1, 12)
    elseif player.sub_job == "WAR" then
        set_macro_page(1, 12)
    elseif player.sub_job == "NIN" then
        set_macro_page(1, 12)
    elseif player.sub_job == "THF" then
        set_macro_page(1, 12)
    else
        set_macro_page(1, 12)
    end
end

--Job Specific Trust Overwrite
function check_trust()
    if not moving then
        if
            state.AutoTrustMode.value and not data.areas.cities:contains(world.area) and
                (buffactive["Elvorseal"] or buffactive["Reive Mark"] or not player.in_combat)
         then
            local party = windower.ffxi.get_party()
            if party.p5 == nil then
                local spell_recasts = windower.ffxi.get_spell_recasts()

                if spell_recasts[980] < spell_latency and not have_trust("Yoran-Oran") then
                    windower.send_command('input /ma "Yoran-Oran (UC)" <me>')
                    tickdelay = os.clock() + 3
                    return true
                elseif spell_recasts[952] < spell_latency and not have_trust("Koru-Moru") then
                    windower.send_command('input /ma "Koru-Moru" <me>')
                    tickdelay = os.clock() + 3
                    return true
                elseif spell_recasts[967] < spell_latency and not have_trust("Qultada") then
                    windower.send_command('input /ma "Qultada" <me>')
                    tickdelay = os.clock() + 3
                    return true
                elseif spell_recasts[914] < spell_latency and not have_trust("Ulmia") then
                    windower.send_command('input /ma "Ulmia" <me>')
                    tickdelay = os.clock() + 3
                    return true
                elseif spell_recasts[979] < spell_latency and not have_trust("Selh'teus") then
                    windower.send_command('input /ma "Selh\'teus" <me>')
                    tickdelay = os.clock() + 3
                    return true
                else
                    return false
                end
            end
        end
    end
    return false
end