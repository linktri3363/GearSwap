near_porter = false

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_job_setup()
    state.OffenseMode:options("Normal", "Acc", "FullAcc", "Fodder")
    state.HybridMode:options("Pet", "DT", "Normal")
    state.WeaponskillMode:options("Match", "Normal", "Acc", "FullAcc", "Fodder")
    state.PhysicalDefenseMode:options("PDT")
    state.IdleMode:options("Normal", "PDT", "Refresh")
    -- NOTE: every weapon set also sets the animator. Swapping animators while the automaton is
    -- out deactivates it, so only change to/from PrimeMagic before Activate.
    -- Prime first so the animator is equipped on load (original order: "None" first, which equips no weapons/animator)
    state.Weapons:options("Prime", "Kenkonken", "Godhands", "PetWeapons", "PrimeMagic", "None")
    state.PetMode =
        M {
        ["description"] = "Pet Mode",
        "None",
        "Melee",
        "Ranged",
        "HybridRanged",
        "Bruiser",
        "Tank",
        "LightTank",
        "Magic",
        "Heal",
        "Nuke"
    }
    -- Automation defaults (original: Repair/Pet/PetWS all false, AutoPuppet off)
    state.AutoRepairMode = M(true, "Auto Repair Mode")      -- Repair w/ Automat. Oil +3 under 45% pet HP
    state.AutoDeployMode = M(true, "Auto Deploy Mode")      -- Deploy when you engage
    state.AutoPetMode = M(true, "Auto Pet Mode")            -- PetMode follows the head/frame you equip
    state.PetWSGear = M(true, "Pet WS Gear")                -- swap to pet WS gear when pet TP >= 1000
    -- No automaton enmity gear owned; leave off until sets.midcast.Pet.PetEnmityGear is defined.
    state.PetEnmityGear = M(false, "Pet Enmity Gear")
    state.AutoPuppetMode:set(true)                          -- Activate / Deus Ex Automata / Deploy / Deactivate

    -- Default/Automatic maneuvers for each pet mode.  Define at least 3.
    defaultManeuvers = {
        -- VE/VE ("boneslayer"): String Theory says no Thunder, which forces String Shredder over Bone Crusher
        -- original: Fire 1 / Thunder 1 / Wind 1 / Light 0
        Melee = {
            {Name = "Light Maneuver", Amount = 1},
            {Name = "Fire Maneuver", Amount = 1},
            {Name = "Wind Maneuver", Amount = 1},
            {Name = "Thunder Maneuver", Amount = 0}
        },
        Bruiser = {
            {Name = "Light Maneuver", Amount = 1},
            {Name = "Water Maneuver", Amount = 1},
            {Name = "Fire Maneuver", Amount = 1},
            {Name = "Light Maneuver", Amount = 0}
        },
        Ranged = {
            {Name = "Wind Maneuver", Amount = 3},
            {Name = "Fire Maneuver", Amount = 0},
            {Name = "Light Maneuver", Amount = 0},
            {Name = "Thunder Maneuver", Amount = 0}
        },
        HybridRanged = {
            {Name = "Wind Maneuver", Amount = 1},
            {Name = "Fire Maneuver", Amount = 1},
            {Name = "Light Maneuver", Amount = 1},
            {Name = "Thunder Maneuver", Amount = 0}
        },
        Tank = {
            {Name = "Earth Maneuver", Amount = 1},
            {Name = "Fire Maneuver", Amount = 1},
            {Name = "Light Maneuver", Amount = 1},
            {Name = "Dark Maneuver", Amount = 0}
        },
        LightTank = {
            {Name = "Earth Maneuver", Amount = 1},
            {Name = "Fire Maneuver", Amount = 1},
            {Name = "Light Maneuver", Amount = 1},
            {Name = "Dark Maneuver", Amount = 0}
        },
        Magic = {
            {Name = "Light Maneuver", Amount = 1},
            {Name = "Ice Maneuver", Amount = 1},
            {Name = "Dark Maneuver", Amount = 1},
            {Name = "Earth Maneuver", Amount = 0}
        },
        Heal = {
            {Name = "Light Maneuver", Amount = 2},
            {Name = "Dark Maneuver", Amount = 1},
            {Name = "Water Maneuver", Amount = 0},
            {Name = "Earth Maneuver", Amount = 0}
        },
        Nuke = {
            {Name = "Ice Maneuver", Amount = 2},
            {Name = "Dark Maneuver", Amount = 1},
            {Name = "Water Maneuver", Amount = 0},
            {Name = "Earth Maneuver", Amount = 0}
        }
    }

    deactivatehpp = 85

    select_default_macro_book()

    send_command("bind @` gs c cycle SkillchainMode")
    send_command("bind @f8 gs c toggle AutoPuppetMode")
    send_command("bind @f7 gs c toggle AutoRepairMode")
end

-- Define sets used by this job file.
-- Side conventions: ring1 = Gere/Overbearing/Defending/Chirich/Lebeche, ring2 = Epona/Murky/Ephramad's/Shneddick.
-- ear1 = Mache/Crep/Burana/Alabaster/Moonshade/Schere, ear2 = Kara. Earring +1 (Sortie, ear2 only)/Hoxne/Etiolation/Odnowa.
function init_gear_sets()
    -- Precast Sets

    -- Fast cast sets for spells
    -- original: Bunzi's Hat/Robe, Loquac./Malignance Earring, Malignance Gloves, Stikini, Isa Belt, Rawhide Trousers
    sets.precast.FC = {
        -- ammo = "Impatiens", -- removed: non-oil ammo unequips the animator
        head = "Null Masque",
        neck = "Voltsurge Torque",
        ear2 = "Etiolation Earring",
        body = "Vrikodara Jupon",
        hands = "Sombra Mittens",
        ring1 = "Lebeche Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Visucius's Mantle",
        waist = "Null Belt",
        legs = "Rawhide Trousers",
        feet = "Regal Pumps +1"
    }

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck = "Magoraga Beads"})

    -- Precast sets to enhance JAs
    sets.precast.JA["Tactical Switch"] = {feet = "Karagoz Scarpe +3"} -- original: Pitre Babouches +3
    sets.precast.JA["Repair"] = {ammo = "Automat. Oil +3", feet = "Foire Babouches +3"} -- original: feet Foire Bab. +2, hands Foire Dastanas +2
    sets.precast.JA["Maintenance"] = {ammo = "Automat. Oil +3", head = "Foire Taj +3"} -- original: Foire Taj +2

    -- original: main Ohtas (not owned), body Foire Tobe +2
    sets.precast.JA.Maneuver = {
        hands = "Foire Dastanas +3",
        ear1 = "Burana Earring",
        body = "Kara. Farsetto +3",
        back = "Visucius's Mantle"
    }

    -- Pitre +3 Job Ability Enhancement Sets (original: +2 names on head/body/hands)
    sets.precast.JA["Optimization"] = {head = "Pitre Taj +3"}
    sets.precast.JA["Overdrive"] = {body = "Pitre Tobe +3"}
    sets.precast.JA["Fine-Tuning"] = {hands = "Pitre Dastanas +3"}
    sets.precast.JA["Ventriloquy"] = {legs = "Pitre Churidars +3"}
    sets.precast.JA["Role Reversal"] = {feet = "Pitre Babouches +3"}

    -- Waltz set (potency, chr and vit)
    -- original: Mpaca's Cap/Doublet/Gloves, Unmoving Collar, Malignance Earring, Stikini, Chaac Belt
    sets.precast.Waltz = {
        head = "Mpaca's Cap",
        neck = "Unmoving Collar",
        ear2 = "Odnowa Earring +1",
        body = { name="Herculean Vest", augments={'Attack+25','"Waltz" potency +8%','STR+9','Accuracy+8',}},
        hands = { name="Herculean Gloves", augments={'Attack+25','"Waltz" potency +9%','Accuracy+7',}},
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Visucius's Mantle",
        waist = "Null Belt",
        legs = "Hiza. Hizayoroi +2",
        feet = "Mpaca's Boots"
    }

    sets.precast.Waltz["Healing Waltz"] = {}

    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    -- original: Sherida Earring, Moonbow Belt +1 (not owned/equippable), Hiza. legs, Epona's ring2
    sets.precast.WS = {
        -- ammo = "Voluspa Tathlum", -- removed: non-oil ammo unequips the animator
        head = "Kara. Cappello +3",
        neck = "Shulmanu Collar",
        ear1 = "Moonshade Earring",
        ear2 = "Hoxne Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Gere Ring",
        ring2 = "Ephramad's Ring",
        back = "Sacro Mantle",
        waist = "Null Belt",
        legs = "Mpaca's Hose",
        feet = "Karagoz Scarpe +3"
    }
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {back = "Null Shawl"})
    sets.precast.WS.FullAcc = set_combine(sets.precast.WS.Acc, {neck = "Null Loop", ring1 = "Chirich Ring +1"})
    sets.precast.WS.Fodder = set_combine(sets.precast.WS, {})

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    -- Crit WS: full Mpaca's
    sets.precast.WS["Victory Smite"] = set_combine(sets.precast.WS, {
        head = "Mpaca's Cap", neck = "Light Gorget", waist = "Light Belt", feet = "Mpaca's Boots"})
    sets.precast.WS["Stringing Pummel"] = set_combine(sets.precast.WS, {
        head = "Mpaca's Cap", waist = "Shadow Belt", feet = "Mpaca's Boots"})
    -- Multi-hit DEX WS
    sets.precast.WS["Shijin Spiral"] = set_combine(sets.precast.WS, {
        neck = "Light Gorget", waist = "Light Belt", feet = "Mpaca's Boots"})
    sets.precast.WS["Asuran Fists"] = set_combine(sets.precast.WS, {waist = "Shadow Belt"})
    -- WSD / fTP-transfer WS
    sets.precast.WS["Howling Fist"] = set_combine(sets.precast.WS, {waist = "Thunder Belt"})
    sets.precast.WS["Raging Fists"] = set_combine(sets.precast.WS, {waist = "Thunder Belt"})
    sets.precast.WS["Dragon Kick"] = set_combine(sets.precast.WS, {waist = "Thunder Belt"})
    sets.precast.WS["Tornado Kick"] = set_combine(sets.precast.WS, {waist = "Thunder Belt"})
    sets.precast.WS["Spinning Attack"] = set_combine(sets.precast.WS, {waist = "Thunder Belt"})
    sets.precast.WS["Shoulder Tackle"] = set_combine(sets.precast.WS, {waist = "Thunder Belt"})
    sets.precast.WS["Backhand Blow"] = set_combine(sets.precast.WS, {})

    for _, ws in ipairs({"Victory Smite", "Stringing Pummel", "Shijin Spiral", "Asuran Fists", "Howling Fist",
        "Raging Fists", "Dragon Kick", "Tornado Kick", "Spinning Attack", "Shoulder Tackle", "Backhand Blow"}) do
        sets.precast.WS[ws].Acc = set_combine(sets.precast.WS[ws], {back = "Null Shawl"})
        sets.precast.WS[ws].FullAcc = set_combine(sets.precast.WS[ws].Acc, {ring1 = "Chirich Ring +1"})
        sets.precast.WS[ws].Fodder = set_combine(sets.precast.WS[ws], {})
    end

    -- Swap Moonshade out when TP is already capped
    sets.MaxTP = {ear1 = "Schere Earring"}
    sets.MaxTP["Shijin Spiral"] = {ear1 = "Mache Earring +1"}

    -- Midcast Sets

    sets.midcast.FastRecast = set_combine(sets.precast.FC, {})

    -- original: set_combine(sets.TreasureHunter, {waist = "Chaac Belt"}) (pulled in the global Wh. Rarab Cap +1)
    sets.TreasureHunter = {waist = "Chaac Belt"}
    sets.midcast.Dia = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
    sets.midcast.Diaga = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
    sets.midcast["Dia II"] = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
    sets.midcast.Bio = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
    sets.midcast["Bio II"] = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)

    ---------------------------------------------------------------------------------------------
    -- Automaton sets. These are full sets: PUP.lua overlays them on top of idle (and PetWS on top
    -- of engaged) whenever the automaton is engaged, chosen by PetMode.
    ---------------------------------------------------------------------------------------------

    -- Idle sets to wear while pet is engaged
    -- Melee DD (Valoredge / Harlequin head): Acc/Atk, Store TP, skill, Lv+
    sets.idle.Pet = {} -- the pet-out idle set itself is built in the Idle section below
    sets.idle.Pet.Engaged = {
        -- ammo = "Voluspa Tathlum", -- removed: non-oil ammo unequips the animator
        head = "Pitre Taj +3",
        neck = "Shulmanu Collar",
        ear1 = "Crep. Earring",
        ear2 = "Kara. Earring +1",
        body = "Pitre Tobe +3",
        hands = "Karagoz Guanti +3",
        ring1 = "Overbearing Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Visucius's Mantle",
        waist = "Incarnation Sash",
        legs = "Kara. Pantaloni +3",
        feet = "Mpaca's Boots"
    }
    sets.idle.Pet.Engaged.Melee = set_combine(sets.idle.Pet.Engaged, {})
    sets.idle.Pet.Engaged.Bruiser = set_combine(sets.idle.Pet.Engaged, {hands = "Mpaca's Gloves"})

    -- Ranged DD (Sharpshot frame)
    sets.idle.Pet.Engaged.Ranged = set_combine(sets.idle.Pet.Engaged, {neck = "Empath Necklace"}) -- original: waist Klouskap Sash (not owned)
    sets.idle.Pet.Engaged.HybridRanged = set_combine(sets.idle.Pet.Engaged.Ranged, {})

    -- Tank (Valoredge + Soulsoother) / LightTank (Harlequin frame): pet DT, HP, regen, haste
    -- original: Anwig Salade (not owned), Isa Belt, Odnowa ear2
    sets.idle.Pet.Engaged.Tank = {
        -- ammo = "Voluspa Tathlum", -- removed: non-oil ammo unequips the animator
        head = "Foire Taj +3",
        neck = "Shulmanu Collar",
        ear1 = "Burana Earring",
        ear2 = "Kara. Earring +1",
        body = "Foire Tobe +3",
        hands = "Pitre Dastanas +3",
        ring1 = "Overbearing Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Visucius's Mantle",
        waist = "Isa Belt",
        legs = "Foire Churidars +3",
        feet = "Mpaca's Boots"
    }
    sets.idle.Pet.Engaged.LightTank = set_combine(sets.idle.Pet.Engaged.Tank, {})

    -- Support caster (Stormwaker/Sharpshot head): Refresh, MP, MAcc, magic skill
    -- original: full Tali'ah +2
    sets.idle.Pet.Engaged.Magic = {
        -- ammo = "Voluspa Tathlum", -- removed: non-oil ammo unequips the animator
        head = "Pitre Taj +3",
        neck = "Adad Amulet",
        ear1 = "Burana Earring",
        ear2 = "Kara. Earring +1",
        body = "Foire Tobe +3",
        hands = "Karagoz Guanti +3",
        ring1 = "Overbearing Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Visucius's Mantle",
        waist = "Incarnation Sash",
        legs = "Kara. Pantaloni +3",
        feet = "Karagoz Scarpe +3"
    }
    -- Healer (Soulsoother head): Cure potency, MND, MP
    sets.idle.Pet.Engaged.Heal = set_combine(sets.idle.Pet.Engaged.Magic, {legs = "Foire Churidars +3"})
    -- Nuker (Spiritreaver head): MAB/MAcc, Refresh
    sets.idle.Pet.Engaged.Nuke = set_combine(sets.idle.Pet.Engaged.Magic, {
        body = "Udug Jacket", legs = "Pitre Churidars +3", feet = "Pitre Babouches +3"})

    -- Midcast sets for pet actions (equipped when the automaton starts casting)
    sets.midcast.Pet.Cure = set_combine(sets.idle.Pet.Engaged.Heal, {
        legs = "Foire Churidars +3", feet = "Karagoz Scarpe +3"}) -- original: legs Tali'ah Sera. +2
    -- original: full Tali'ah +2, Enmerkar/Domesticator's Earring, Stikini x2
    sets.midcast.Pet["Enfeebling Magic"] = {
        -- ammo = "Voluspa Tathlum", -- removed: non-oil ammo unequips the animator
        head = "Kara. Cappello +3",
        neck = "Adad Amulet",
        ear1 = "Alabaster Earring",
        ear2 = "Kara. Earring +1",
        body = "Kara. Farsetto +3",
        hands = "Karagoz Guanti +3",
        ring1 = "Overbearing Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Visucius's Mantle",
        waist = "Incarnation Sash",
        legs = "Kara. Pantaloni +3",
        feet = "Karagoz Scarpe +3"
    }
    sets.midcast.Pet["Dark Magic"] = set_combine(sets.midcast.Pet["Enfeebling Magic"], {})
    sets.midcast.Pet["Elemental Magic"] = {
        -- ammo = "Voluspa Tathlum", -- removed: non-oil ammo unequips the animator
        head = "Kara. Cappello +3",
        neck = "Adad Amulet",
        ear1 = "Burana Earring",
        ear2 = "Kara. Earring +1",
        body = "Udug Jacket",
        hands = "Karagoz Guanti +3",
        ring1 = "Overbearing Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Visucius's Mantle",
        waist = "Incarnation Sash",
        legs = "Pitre Churidars +3",
        feet = "Pitre Babouches +3"
    }

    -- The following sets are predictive and are equipped before we even know the ability will happen, as a workaround due to
    -- the fact that start of ability packets are too late in the case of Pup abilities, WS, and certain spells.
    -- original: {head = "Anwig Salade", ear2 = "Odnowa Earring +1"} (Anwig not owned; Odnowa has no pet enmity)
    -- sets.midcast.Pet.PetEnmityGear = {}

    -- Pet WS: TP Bonus head, automaton WSD gloves, Atk, Lv+
    -- original: main Ohtas, Enmerkar/Domesticator's Earring, Varar Ring +1/C. Palug Ring, full Karagoz (not owned / no WS stats)
    sets.midcast.Pet.PetWSGear = {
        -- ammo = "Voluspa Tathlum", -- removed: non-oil ammo unequips the animator
        head = "Kara. Cappello +3",
        neck = "Shulmanu Collar",
        ear1 = "Burana Earring",
        ear2 = "Kara. Earring +1",
        body = "Pitre Tobe +3",
        hands = "Mpaca's Gloves",
        ring1 = "Overbearing Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Visucius's Mantle",
        waist = "Incarnation Sash",
        legs = "Kara. Pantaloni +3",
        feet = "Mpaca's Boots"
    }
    sets.midcast.Pet.PetWSGear.Melee = set_combine(sets.midcast.Pet.PetWSGear, {})
    sets.midcast.Pet.PetWSGear.Bruiser = set_combine(sets.midcast.Pet.PetWSGear, {})
    sets.midcast.Pet.PetWSGear.Ranged = set_combine(sets.midcast.Pet.PetWSGear, {neck = "Empath Necklace"})
    sets.midcast.Pet.PetWSGear.HybridRanged = set_combine(sets.midcast.Pet.PetWSGear.Ranged, {})
    -- Tanks keep their DT gear and only take the TP Bonus head + WSD gloves
    sets.midcast.Pet.PetWSGear.Tank = set_combine(sets.idle.Pet.Engaged.Tank, {head = "Kara. Cappello +3", hands = "Mpaca's Gloves"})
    sets.midcast.Pet.PetWSGear.LightTank = set_combine(sets.idle.Pet.Engaged.LightTank, {head = "Kara. Cappello +3", hands = "Mpaca's Gloves"})
    -- Casters rarely WS; stay in caster gear
    sets.midcast.Pet.PetWSGear.Magic = set_combine(sets.idle.Pet.Engaged.Magic, {})
    sets.midcast.Pet.PetWSGear.Heal = set_combine(sets.idle.Pet.Engaged.Heal, {})
    sets.midcast.Pet.PetWSGear.Nuke = set_combine(sets.idle.Pet.Engaged.Nuke, {})

    -- Overlaid while Overdrive is active
    sets.buff.Overdrive = {head = "Kara. Cappello +3", hands = "Mpaca's Gloves"}

    -- Currently broken, preserved in case of future functionality.
    --sets.midcast.Pet.WeaponSkill = {}

    -- Sets to return to when not performing an action.

    -- Resting sets
    sets.resting = {}

    -- Idle sets
    -- sets.idle is rebuilt below, so hold on to the automaton-engaged sets defined above
    local pet_engaged = sets.idle.Pet.Engaged
    -- original: Nyame Helm/Gauntlets, Loricate, Alabaster/Etiolation, Stikini, Incarnation Sash
    sets.idle = {
        -- ammo = "Staunch Tathlum +1", -- removed: non-oil ammo unequips the animator
        head = "Null Masque",
        neck = "Bathy Choker +1",
        ear1 = "Alabaster Earring",
        ear2 = "Etiolation Earring",
        body = "Kara. Farsetto +3",
        hands = "Karagoz Guanti +3",
        ring1 = "Chirich Ring +1",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Kara. Pantaloni +3",
        feet = "Nyame Sollerets"
    }

    sets.idle.PDT = set_combine(sets.idle, {neck = "Loricate Torque +1", ring1 = "Defending Ring"})

    -- original: Rawhide Mask, Sanare Earring, Bunzi's Robe/Gloves, Stikini
    sets.idle.Refresh = set_combine(sets.idle, {waist = "Fucho-no-Obi", legs = "Rawhide Trousers"})

    -- Set for idle while pet is out but not engaged (pet regen/refresh, keep player DT)
    -- original: Kara head/feet, Enmerkar Earring, Stikini, Isa Belt
    sets.idle.Pet = set_combine(sets.idle, {
        -- ammo = "Voluspa Tathlum", -- removed: non-oil ammo unequips the animator
        ear1 = "Burana Earring",
        ear2 = "Kara. Earring +1",
        back = "Contriver's Cape",
        waist = "Isa Belt",
        feet = "Mpaca's Boots"
    })
    sets.idle.Pet.Engaged = pet_engaged

    sets.packing = {
        head  = "Nyame Helm",
        neck  = "Loricate Torque +1",
        ear1  = "Alabaster Earring",
        ear2  = "Kara. Earring +1",
        body  = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Stikini Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back  = "Visucius's Mantle",
        waist = "Fucho-no-Obi",
        legs  = "Nyame Flanchard",
        feet  = "Nyame Sollerets"
    }

    -- Defense sets
    -- original: Nyame Helm/Mail/Gauntlets/Flanchard, Etiolation ear1, Stikini, Isa Belt
    sets.defense.PDT = {
        -- ammo = "Staunch Tathlum +1", -- removed: non-oil ammo unequips the animator
        head = "Null Masque",
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",
        ear2 = "Odnowa Earring +1",
        body = "Kara. Farsetto +3",
        hands = "Karagoz Guanti +3",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Kara. Pantaloni +3",
        feet = "Nyame Sollerets"
    }

    sets.defense.MDT = set_combine(sets.defense.PDT, {ear2 = "Etiolation Earring"})

    sets.defense.MEVA = set_combine(sets.defense.PDT, {body = "Nyame Mail", legs = "Nyame Flanchard"})

    sets.Kiting = {ring2 = "Shneddick Ring +1"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    -- Normal: player DD (Martial Arts from Kara legs + Mache, H2H skill from Kara head/ear)
    -- original: full Mpaca's, Sherida/Telos, Moonbow Belt +1, Overbearing/Epona
    sets.engaged = {
        -- ammo = "Voluspa Tathlum", -- removed: non-oil ammo unequips the animator
        head = "Kara. Cappello +3",
        neck = "Shulmanu Collar",
        ear1 = "Mache Earring +1",
        ear2 = "Kara. Earring +1",
        body = "Mpaca's Doublet",
        hands = "Karagoz Guanti +3",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Kara. Pantaloni +3",
        feet = "Mpaca's Boots"
    }
    sets.engaged.Acc = set_combine(sets.engaged, {neck = "Null Loop"})
    sets.engaged.FullAcc = set_combine(sets.engaged.Acc, {head = "Malignance Chapeau", ring1 = "Chirich Ring +1"})
    sets.engaged.Fodder = set_combine(sets.engaged, {})

    -- DT: Kara body + Malignance head + Murky
    sets.engaged.DT = set_combine(sets.engaged, {
        head = "Malignance Chapeau", body = "Kara. Farsetto +3", ring2 = { name="Murky Ring", augments={'Path: A',}}})
    sets.engaged.Acc.DT = set_combine(sets.engaged.DT, {neck = "Null Loop"})
    sets.engaged.FullAcc.DT = set_combine(sets.engaged.Acc.DT, {ring1 = "Chirich Ring +1"})
    sets.engaged.Fodder.DT = set_combine(sets.engaged.DT, {})

    -- Pet: fight alongside the automaton, gear shared toward its stats
    -- original: full Mpaca's, Sherida/Telos, Klouskap Sash (not owned), Epona's
    sets.engaged.Pet = {
        -- ammo = "Voluspa Tathlum", -- removed: non-oil ammo unequips the animator
        head = "Kara. Cappello +3",
        neck = "Shulmanu Collar",
        ear1 = "Crep. Earring",
        ear2 = "Kara. Earring +1",
        body = "Mpaca's Doublet",
        hands = "Karagoz Guanti +3",
        ring1 = "Overbearing Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Visucius's Mantle",
        waist = "Incarnation Sash",
        legs = "Kara. Pantaloni +3",
        feet = "Mpaca's Boots"
    }
    sets.engaged.Acc.Pet = set_combine(sets.engaged.Pet, {})
    sets.engaged.FullAcc.Pet = set_combine(sets.engaged.Pet, {neck = "Null Loop"})
    sets.engaged.Fodder.Pet = set_combine(sets.engaged.Pet, {})

    -- Weapons sets (Varga Purnikawa: Automaton Lv+2)
    sets.weapons.PetWeapons = {main = "Varga Purnikawa", range = "Neo Animator"}
    sets.weapons.Godhands = {main = "Godhands", range = "Neo Animator"}
    sets.weapons.Prime = {main = "Varga Purnikawa", range = "Neo Animator"}
    sets.weapons.Kenkonken = {main = "Kenkonken", range = "Neo Animator"}
    -- Animator P II +1 (automaton all stats +20) for Heal/Nuke/Magic frames. Pick before Activate.
    sets.weapons.PrimeMagic = {main = "Varga Purnikawa", range = "Animator P II +1"}
end

-- Renamed from job_customize_idle_set: that name replaced PUP.lua's version and disabled
-- all pet-engaged idle swaps, PetWS gear, and Overdrive gear.
-- Non-oil ammo knocks the animator out of the range slot, which blocks maneuvers.
-- Keep the ammo slot empty in idle/engaged gear (Repair/Maintenance still put the oil on).
function no_ammo(set)
    if set and set.ammo == nil then
        return set_combine(set, {ammo = empty})
    end
    return set
end

function user_job_customize_melee_set(meleeSet)
    return no_ammo(meleeSet)
end

function user_job_customize_idle_set(idleSet)
    local currently_near_porter = near_porter_moogle()

    if currently_near_porter then
        if not near_porter then
            windower.add_to_chat(160, "Near Porter Moogle - Using packing gear")
            near_porter = true
        end
        return no_ammo(sets.packing)
    else
        if near_porter then
            windower.add_to_chat(160, "Left Porter Moogle area - Returning to normal gear")
            near_porter = false
        end
    end

    return no_ammo(idleSet)
end

function near_porter_moogle()
    local mobs = windower.ffxi.get_mob_array()
    for i, mob in pairs(mobs) do
        if mob.name == "Porter Moogle" and mob.distance and mob.distance < 36 then
            return true
        end
    end
    return false
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == "DNC" then
        set_macro_page(1, 18)
    elseif player.sub_job == "NIN" then
        set_macro_page(1, 18)
    elseif player.sub_job == "THF" then
        set_macro_page(1, 18)
    else
        set_macro_page(1, 18)
    end
end
