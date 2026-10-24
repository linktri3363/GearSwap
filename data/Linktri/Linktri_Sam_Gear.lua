local near_porter = false  -- Track Porter Moogle proximity state
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
    state.Weapons:options("Dojikiri", "Masamune", "ShiningOne", "ProcWeapon", "Bow")  -- original: "Dojikiri", "ProcWeapon", "Bow"

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
    -- LINKTRI 2026-10-23: full rebuild around owned gear (Kasuga +3, Mpaca's, Nyame B, Kasuga Earring +1).
    -- Unowned originals (Flamma +2, Sakonji, Moonlight Cape, Patricius Ring, Ioskeha Belt, Cessance/Digni.,
    -- Aurgelmir Orb +1, Danzo, Dark Ring, Flume Belt +1, Kyujutsugi, Buremte, etc.) are noted per set below.
    -- Sides: ear2 = Kasuga Earring +1 (Sortie, ear2 only) / Sanare / Ishvara-free; ear1 = Moonshade/Telos/Ishvara/
    --        Etiolation/Dedition/Schere. ring1 = Murky/Ephramad's/Chirich (single); ring2 = Ilabrat/Defending/
    --        Chirich (second)/Shneddick.
    -- Every WS set keeps BOTH ear slots filled: SAM.lua calls ear1/ear2:startswith() on WS sets.
    --------------------------------------

    -- Precast sets to enhance JAs
    sets.precast.JA.Meditate = {head = "Wakido Kabuto +2", back = gear.ws_jse_back}  -- LINKTRI 2026-10-24: was +1 (upgraded); original also hands "Sakonji Kote +1" (not owned)
    sets.precast.JA["Warding Circle"] = {head = "Wakido Kabuto +2"}  -- LINKTRI 2026-10-24: was +1 (upgraded)
    -- sets.precast.JA["Blade Bash"] = {hands = "Sakonji Kote +1"}  -- not owned
    sets.precast.JA["Sekkanoki"] = {hands = "Kasuga Kote +3"}
    sets.precast.JA["Sengikori"] = {feet = "Kas. Sune-Ate +3"}

    -- Accuracy/magic accuracy sets for Steps and Flourishes (original: Flamma +2, Sakonji Domaru +3,
    -- Moonbeam Nodowa, Ramuh Ring +1 x2, Olseni Belt, Digni. Earring, Sanctity Necklace - not owned)
    sets.precast.Step = {
        ammo = { name="Coiste Bodhar", augments={'Path: A',}},
        head = "Kasuga Kabuto +3",
        neck = "Null Loop",
        ear1 = "Telos Earring",
        ear2 = "Kasuga Earring +1",
        body = "Kasuga Domaru +3",
        hands = "Kasuga Kote +3",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Kasuga Haidate +3",
        feet = "Kas. Sune-Ate +3"
    }
    sets.precast.JA["Violent Flourish"] = set_combine(sets.precast.Step, {ammo = "Pemphredo Tathlum"})

    -- Waltz (original: Flamma +2, Handler's Earrings, Asklepian/Valseur's Ring, Moonlight Cape - not owned)
    sets.precast.Waltz = {
        head = "Kasuga Kabuto +3",
        neck = "Unmoving Collar",
        ear1 = "Etiolation Earring",
        ear2 = { name="Odnowa Earring +1", augments={'Path: A',}},
        body = "Tartarus Platemail",
        hands = "Kasuga Kote +3",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back = "Null Shawl",
        waist = "Reiki Yotai",
        legs = "Wakido Haidate +1",
        feet = "Kas. Sune-Ate +3"
    }
    sets.precast.Waltz["Healing Waltz"] = {}

    -- Fast cast (original: Enchntr. Earring +1, Leyline Gloves, Sacro Breastplate, Prolix Ring - not owned)
    sets.precast.FC = {
        neck = "Voltsurge Torque",
        ear1 = "Etiolation Earring",
        ear2 = "Loquac. Earring",  -- stored (PorterPacker)
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Lebeche Ring"
    }

    sets.precast.RA = {}

    ---------------------------------------------------------------------------------------------
    -- Weaponskill sets: Nyame B (WSD) + Kasuga Kote +3 (WSD+12) + Kas. Sune-Ate +3 (PDL+10) + Knobkierrie
    -- (original base: Asperity Necklace, Reiki Yotai, Chirich ring2, Ishvara/Moonshade)
    ---------------------------------------------------------------------------------------------
    sets.precast.WS = {
        ammo = "Knobkierrie",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = "Asperity Necklace",
        ear1 = "Moonshade Earring",
        ear2 = "Kasuga Earring +1",  -- WSD+3%, Acc+14 (original: "Moonshade Earring" ear2 / Ishvara ear1)
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = "Kasuga Kote +3",
        ring1 = "Ephramad's Ring",
        ring2 = "Ilabrat Ring",
        back = "Null Shawl",
        waist = "Light Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = "Kas. Sune-Ate +3"
    }
    sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {neck = "Null Loop"})
    sets.precast.WS.Acc = set_combine(sets.precast.WS.SomeAcc, {head = "Kasuga Kabuto +3"})
    sets.precast.WS.FullAcc = set_combine(sets.precast.WS.Acc, {ear1 = "Telos Earring", waist = "Null Belt"})
    sets.precast.WS.Fodder = set_combine(sets.precast.WS, {})

    -- Proc: no proc weapon owned (Hachimonji); keep a low-damage set for the WeaponskillMode option
    sets.precast.WS.Proc = {  -- Flamma +2 (packed); original ammo "Hasty Pinion +1", waist "Ioskeha Belt" (not owned)
        ammo = { name="Coiste Bodhar", augments={'Path: A',}},
        head = "Flam. Zucchetto +2",
        neck = "Asperity Necklace",
        ear1 = "Ishvara Earring",
        ear2 = "Kasuga Earring +1",
        body = "Tartarus Platemail",
        hands = "Flam. Manopolas +2",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = "Flam. Gambieras +2"
    }

    -- Elemental belt / gorget per WS skillchain property (Light Gorget only where Light/Fusion/Distortion applies)
    local ws_mods = {
        ["Tachi: Fudo"]     = {neck = "Light Gorget", waist = "Light Belt"},    -- Light / Distortion
        ["Tachi: Shoha"]    = {waist = "Thunder Belt"},                          -- Fragmentation / Compression
        ["Tachi: Kasha"]    = {neck = "Light Gorget", waist = "Light Belt"},    -- Fusion / Compression
        ["Tachi: Gekko"]    = {waist = "Snow Belt"},                             -- Distortion / Reverberation
        ["Tachi: Yukikaze"] = {waist = "Soil Belt"},                             -- Detonation / Scission
        ["Tachi: Rana"]     = {waist = "Shadow Belt"},                           -- Gravitation / Induration
        ["Impulse Drive"]   = {waist = "Shadow Belt"},                           -- Gravitation / Induration (Shining One)
        ["Stardiver"]       = {neck = "Light Gorget", waist = "Light Belt"},    -- Gravitation / Transfixion (Shining One)
    }
    for ws, mod in pairs(ws_mods) do
        sets.precast.WS[ws] = set_combine(sets.precast.WS, mod)
        sets.precast.WS[ws].SomeAcc = set_combine(sets.precast.WS.SomeAcc, mod, {neck = "Null Loop"})
        sets.precast.WS[ws].Acc = set_combine(sets.precast.WS.Acc, mod, {neck = "Null Loop"})
        sets.precast.WS[ws].FullAcc = set_combine(sets.precast.WS.FullAcc, {neck = "Null Loop"})
        sets.precast.WS[ws].Fodder = set_combine(sets.precast.WS.Fodder, mod)
    end

    -- Ageha / Hobaku land debuffs: magic accuracy (original: Flamma +2, Digni., Sanctity, Ramuh Rings - not owned)
    sets.precast.WS["Tachi: Ageha"] = {
        ammo = "Pemphredo Tathlum",
        head = "Kasuga Kabuto +3",
        neck = "Null Loop",
        ear1 = "Moonshade Earring",
        ear2 = "Kasuga Earring +1",
        body = "Kasuga Domaru +3",
        hands = "Kasuga Kote +3",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Kasuga Haidate +3",
        feet = "Kas. Sune-Ate +3"
    }
    sets.precast.WS["Tachi: Hobaku"] = set_combine(sets.precast.WS["Tachi: Ageha"], {})

    -- Jinpu (magical, wind): MAB/WSD (original ear1 "Friomisi Earring" - not owned)
    sets.precast.WS["Tachi: Jinpu"] = {
        ammo = "Knobkierrie",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = "Sibyl Scarf",
        ear1 = "Moonshade Earring",
        ear2 = "Kasuga Earring +1",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = "Kasuga Kote +3",
        ring1 = "Ephramad's Ring",
        ring2 = "Ilabrat Ring",
        back = "Null Shawl",
        waist = "Orpheus's Sash",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

    -- Apex Arrow (Ullr): no ammo key so the bow keeps its arrows
    -- (original: Ynglinga Sallet, Clearview Earring, Kyujutsugi, Buremte Gloves - not owned)
    sets.precast.WS["Apex Arrow"] = {
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = "Light Gorget",
        ear1 = "Moonshade Earring",
        ear2 = "Kasuga Earring +1",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = "Kasuga Kote +3",
        ring1 = "Ephramad's Ring",
        ring2 = "Ilabrat Ring",
        back = "Null Shawl",
        waist = "Light Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }
    sets.precast.WS["Apex Arrow"].SomeAcc = set_combine(sets.precast.WS["Apex Arrow"], {neck = "Null Loop"})
    sets.precast.WS["Apex Arrow"].Acc = sets.precast.WS["Apex Arrow"].SomeAcc
    sets.precast.WS["Apex Arrow"].FullAcc = sets.precast.WS["Apex Arrow"].SomeAcc
    sets.precast.WS["Apex Arrow"].Fodder = sets.precast.WS["Apex Arrow"]

    -- Swap to these on Moonshade-using WS at 3000 TP (both ears must be set; SAM.lua reads ear1 and ear2)
    -- original: MaxTP {ear1 Ishvara, ear2 Schere}, AccMaxTP {ear1 Ishvara, ear2 Brutal}
    sets.MaxTP = {ear1 = "Ishvara Earring", ear2 = "Kasuga Earring +1"}
    sets.AccMaxTP = {ear1 = "Telos Earring", ear2 = "Kasuga Earring +1"}
    -- Lugra Earring day/night sets (Lugra not owned; SAM.lua only uses these when a set contains Lugra)
    sets.AccDayMaxTPWSEars = sets.AccMaxTP
    sets.DayMaxTPWSEars = sets.MaxTP
    sets.AccDayWSEars = sets.AccMaxTP
    sets.DayWSEars = {ear1 = "Moonshade Earring", ear2 = "Kasuga Earring +1"}

    ---------------------------------------------------------------------------------------------
    -- Midcast
    ---------------------------------------------------------------------------------------------
    -- original: Enchntr./Loquac. Earrings, Leyline Gloves, Prolix Ring, Moonlight Cape, Tempus Fugit, Amm Greaves
    sets.midcast.FastRecast = {
        head = "Kasuga Kabuto +3",
        neck = "Voltsurge Torque",
        ear1 = "Etiolation Earring",
        ear2 = "Loquac. Earring",
        body = "Kasuga Domaru +3",
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Kasuga Haidate +3",
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }
    sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {})  -- original: back "Mujin Mantle" (not owned)

    -- Ranged (Ullr) - original: Flamma head, Clearview/Neritic Earrings, Kyujutsugi, Buremte, Regal Ring
    sets.midcast.RA = {
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = "Combatant's Torque",
        ear1 = "Telos Earring",
        ear2 = "Kasuga Earring +1",
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = "Kasuga Kote +3",
        ring1 = "Ephramad's Ring",
        ring2 = "Ilabrat Ring",
        back = "Null Shawl",
        waist = "Reiki Yotai",
        legs = "Wakido Haidate +1",
        feet = "Waki. Sune-Ate +1"  -- original name "Wakido Sune. +1" never matched
    }
    sets.midcast.RA.Acc = set_combine(sets.midcast.RA, {neck = "Null Loop", waist = "Null Belt"})

    ---------------------------------------------------------------------------------------------
    -- Idle / resting / defense
    -- original: Moonlight Cape, Dark Ring, Flume Belt +1, Danzo Sune-ate, Patricius Ring, Ioskeha Belt,
    --           Warder's Charm +1, Shadow Ring, Sacro Breastplate, Sakonji Kote +1, Flamma (not owned)
    ---------------------------------------------------------------------------------------------
    sets.resting = {
        ammo = "Staunch Tathlum +1",
        head = "Null Masque",
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Hiza. Haramaki +2",
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

    sets.Kiting = {ring2 = "Shneddick Ring +1"}  -- original: feet "Danzo Sune-ate" (not owned)
    sets.Reraise = {head = "Twilight Helm", body = "Twilight Mail"}  -- stored (PorterPacker)
    sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
    sets.Skillchain = {}

    -- Null Masque (DT-10, Regen+3, Regain+2), Kasuga body/legs (DT-14/-11), Nyame hands/feet, Murky + Defending
    -- LINKTRI 2026-10-24: legs Nyame Flanchard (DT-8) -> Kasuga Haidate +3 (DT-11). Idle DT is over the -50% cap either way.
    sets.idle = {
        ammo = "Staunch Tathlum +1",
        head = "Null Masque",
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Kasuga Domaru +3",
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Kasuga Haidate +3",
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
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
        ring2 = "Defending Ring",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.DayIdle = {}
    sets.NightIdle = {}

    sets.defense.PDT = {
        ammo = "Staunch Tathlum +1",
        head = "Kasuga Kabuto +3",
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Kasuga Domaru +3",
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Kasuga Haidate +3",
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }
    sets.defense.MDT = set_combine(sets.defense.PDT, {waist = "Carrier's Sash"})
    sets.defense.MEVA = set_combine(sets.defense.PDT, {
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        waist = "Carrier's Sash"
    })

    ---------------------------------------------------------------------------------------------
    -- Engaged: Kasuga head/body/legs (Store TP +37, DT -35) + Kasuga Earring +1 for 5-hit builds.
    -- original base: Cessance Earring (not owned), Petrov Ring, Mpaca's Hose
    ---------------------------------------------------------------------------------------------
    sets.engaged = {
        ammo = { name="Coiste Bodhar", augments={'Path: A',}},
        head = "Kasuga Kabuto +3",
        neck = "Combatant's Torque",
        ear1 = "Telos Earring",
        ear2 = "Kasuga Earring +1",
        body = "Kasuga Domaru +3",
        hands = {name = "Mpaca's Gloves", augments = {"Path: A"}},
        ring1 = "Chirich Ring +1",
        ring2 = "Ilabrat Ring",
        back = "Null Shawl",
        waist = "Reiki Yotai",
        legs = "Kasuga Haidate +3",
        feet = "Flam. Gambieras +2"  -- DA+6%, Store TP+6 (packed Flamma +2)
    }
    sets.engaged.SomeAcc = set_combine(sets.engaged, {neck = "Null Loop"})
    sets.engaged.Acc = set_combine(sets.engaged.SomeAcc, {ring2 = "Chirich Ring +1", waist = "Null Belt"})
    sets.engaged.FullAcc = set_combine(sets.engaged.Acc, {hands = "Kasuga Kote +3", feet = "Kas. Sune-Ate +3"})
    sets.engaged.Fodder = set_combine(sets.engaged, {ear1 = "Dedition Earring"})

    -- DTLite: Kasuga 35 + Null Loop 5 + Murky 10 = DT -50 with Store TP kept
    sets.engaged.DTLite = set_combine(sets.engaged, {neck = "Null Loop", ring1 = { name="Murky Ring", augments={'Path: A',}}})
    sets.engaged.SomeAcc.DTLite = sets.engaged.DTLite
    sets.engaged.Acc.DTLite = set_combine(sets.engaged.DTLite, {waist = "Null Belt"})
    sets.engaged.FullAcc.DTLite = set_combine(sets.engaged.Acc.DTLite, {hands = "Kasuga Kote +3", feet = "Kas. Sune-Ate +3"})
    sets.engaged.Fodder.DTLite = set_combine(sets.engaged.DTLite, {ear1 = "Dedition Earring"})

    -- PDT: add Nyame hands/feet, Loricate and Defending on top of the Kasuga DT core
    sets.engaged.PDT = set_combine(sets.engaged.DTLite, {
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring2 = "Defending Ring",
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    })
    sets.engaged.SomeAcc.PDT = set_combine(sets.engaged.PDT, {neck = "Null Loop"})
    sets.engaged.Acc.PDT = set_combine(sets.engaged.SomeAcc.PDT, {waist = "Null Belt"})
    sets.engaged.FullAcc.PDT = sets.engaged.Acc.PDT
    sets.engaged.Fodder.PDT = sets.engaged.PDT

    ---------------------------------------------------------------------------------------------
    -- Weapons (Shining One and Ullr are packed - PorterPacker)
    ---------------------------------------------------------------------------------------------
    sets.weapons.Dojikiri = {main = "Dojikiri Yasutsuna", sub = "Utu Grip"}
    sets.weapons.Masamune = {main = "Masamune", sub = "Utu Grip"}  -- Path A; augment upgrades still to come
    sets.weapons.ShiningOne = {main = "Shining One", sub = "Utu Grip"}  -- original: sets.weapons.Bow = {main = "Shining One"}
    sets.weapons.Bow = {main = "Dojikiri Yasutsuna", sub = "Utu Grip", range = "Ullr", ammo = "Kabura Arrow"}
    sets.weapons.ProcWeapon = {main = "Hachimonji", sub = "Bloodrain Strap"}  -- Hachimonji packed (PorterPacker)

    -- Buff sets
    sets.Cure_Received = {legs = "Flamma Dirs +2"}  -- Cure received +9%; original also hands "Buremte Gloves", waist "Gishdubar Sash" (not owned)
    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Sleep = {}  -- original: {neck = "Vim Torque +1"} (not owned)
    sets.buff.Hasso = {hands = "Wakido Kote +1"}
    sets.buff["Third Eye"] = {} --legs="Sakonji Haidate +3"
    sets.buff.Sekkanoki = {hands = "Kasuga Kote +3"}
    sets.buff.Sengikori = {feet = "Kas. Sune-Ate +3"}
    sets.buff["Meikyo Shisui"] = {}  -- original: {feet = "Sak. Sune-Ate +1"} (not owned)
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
function user_job_customize_idle_set(idleSet)  -- renamed from job_customize_idle_set (user_ hook; SAM.lua has none today)
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
                (buffactive["Elvorseal"] or buffactive["Reive Mark"] or not in_combat)  -- was player.in_combat (always nil)
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