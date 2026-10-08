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

near_porter = false

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_job_setup()
    state.OffenseMode:options("Normal", "Acc", "FullAcc", "Fodder")
    state.HybridMode:options("Pet", "DT", "Normal")
    state.WeaponskillMode:options("Match", "Normal", "Acc", "FullAcc", "Fodder")
    state.PhysicalDefenseMode:options("PDT")
    state.IdleMode:options("Normal", "PDT", "Refresh")
    state.Weapons:options("None", "Prime", "Kenkonken", "Godhands", "PetWeapons")
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
    state.AutoRepairMode = M(false, "Auto Repair Mode")
    state.AutoDeployMode = M(true, "Auto Deploy Mode")
    state.AutoPetMode = M(false, "Auto Pet Mode")
    state.PetWSGear = M(false, "Pet WS Gear")
    state.PetEnmityGear = M(false, "Pet Enmity Gear")

    -- Default/Automatic maneuvers for each pet mode.  Define at least 3.
    defaultManeuvers = {
        Melee = {
            {Name = "Fire Maneuver", Amount = 1},
            {Name = "Thunder Maneuver", Amount = 1},
            {Name = "Wind Maneuver", Amount = 1},
            {Name = "Light Maneuver", Amount = 0}
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
function init_gear_sets()
    -- Precast Sets

    -- Fast cast sets for spells
    sets.precast.FC = {
        head = "Bunzi's Hat",
        neck = "Voltsurge Torque",
        ear1 = "Loquac. Earring",
        ear2 = "Malignance Earring",
        body = "Bunzi's Robe",
        hands = "Malignance Gloves",
        ring1 = "Lebeche Ring",
        ring2 = "Stikini Ring",
        back = "Visucius's Mantle",
        waist = "Isa Belt",
        legs = "Rawhide Trousers",
        feet = "Regal Pumps +1"
    }

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck = "Magoraga Beads"})

    -- Precast sets to enhance JAs
    sets.precast.JA["Tactical Switch"] = {feet = "Pitre Babouches +2"}
    sets.precast.JA["Repair"] = {ammo = "Automat. Oil +3", feet = "Foire Bab. +2", hands = "Foire Dastanas +2"}
    sets.precast.JA["Maintenance"] = {ammo = "Automat. Oil +3", head = "Foire Taj +2"}

    sets.precast.JA.Maneuver = {main = "Ohtas", back = "Visucius's Mantle", body = "Foire Tobe +2"}

    -- Pitre +2 Job Ability Enhancement Sets
    sets.precast.JA["Optimization"] = {head = "Pitre Taj +2"}
    sets.precast.JA["Overdrive"] = {body = "Pitre Tobe +2"}
    sets.precast.JA["Fine-Tuning"] = {hands = "Pitre Dastanas +2"}
    sets.precast.JA["Ventriloquy"] = {legs = "Pitre Churidars +2"}
    sets.precast.JA["Role Reversal"] = {feet = "Pitre Babouches +2"}

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {
        head = "Mpaca's Cap",
        neck = "Unmoving Collar",
        ear1 = "Malignance Earring",
        ear2 = "Odnowa Earring +1",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Stikini Ring",
        back = "Visucius's Mantle",
        waist = "Chaac Belt",
        legs = "Hiza. Hizayoroi +2",
        feet = "Mpaca's Boots"
    }

    sets.precast.Waltz["Healing Waltz"] = {}

    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        head = "Mpaca's Cap",
        neck = "Shulmanu Collar",
        ear1 = "Moonshade Earring",
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Ephramad's Ring",
        ring2 = "Epona's Ring",
        back = "Visucius's Mantle",
        waist = "Moonbow Belt +1",
        legs = "Hiza. Hizayoroi +2",
        feet = "Mpaca's Boots"
    }
    sets.precast.WS.Acc = {
        head = "Mpaca's Cap",
        neck = "Combatant's Torque",
        ear1 = "Moonshade Earring",
        ear2 = "Telos Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Ephramad's Ring",
        ring2 = "Gere Ring",
        back = "Visucius's Mantle",
        waist = "Moonbow Belt +1",
        legs = "Hiza. Hizayoroi +2",
        feet = "Malignance Boots"
    }
    sets.precast.WS.FullAcc = {
        head = "Mpaca's Cap",
        neck = "Combatant's Torque",
        ear1 = "Digni. Earring",
        ear2 = "Telos Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Cacoethic Ring +1",
        ring2 = "Gere Ring",
        back = "Visucius's Mantle",
        waist = "Olseni Belt",
        legs = "Hiza. Hizayoroi +2",
        feet = "Malignance Boots"
    }
    sets.precast.WS.Fodder = {
        head = "Mpaca's Cap",
        neck = "Shulmanu Collar",
        ear1 = "Moonshade Earring",
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Ephramad's Ring",
        ring2 = "Epona's Ring",
        back = "Visucius's Mantle",
        waist = "Moonbow Belt +1",
        legs = "Hiza. Hizayoroi +2",
        feet = "Mpaca's Boots"
    }

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS["Victory Smite"] = set_combine(sets.precast.WS, {head = "Mpaca's Cap", body = "Mpaca's Doublet"})
    sets.precast.WS["Victory Smite"].Acc = set_combine(sets.precast.WS.Acc, {body = "Mpaca's Doublet"})
    sets.precast.WS["Victory Smite"].FullAcc = set_combine(sets.precast.WS.FullAcc, {body = "Mpaca's Doublet"})
    sets.precast.WS["Victory Smite"].Fodder = set_combine(sets.precast.WS.Fodder, {body = "Mpaca's Doublet"})

    sets.precast.WS["Stringing Pummel"] = set_combine(sets.precast.WS, {body = "Mpaca's Doublet"})
    sets.precast.WS["Stringing Pummel"].Acc = set_combine(sets.precast.WS.Acc, {body = "Mpaca's Doublet"})
    sets.precast.WS["Stringing Pummel"].FullAcc = set_combine(sets.precast.WS.FullAcc, {body = "Mpaca's Doublet"})
    sets.precast.WS["Stringing Pummel"].Fodder = set_combine(sets.precast.WS.Fodder, {body = "Mpaca's Doublet"})

    sets.precast.WS["Shijin Spiral"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Shijin Spiral"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Shijin Spiral"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Shijin Spiral"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS["Asuran Fists"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Asuran Fists"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Asuran Fists"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Asuran Fists"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS["Dragon Kick"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Dragon Kick"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Dragon Kick"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Dragon Kick"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS["Tornado Kick"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Tornado Kick"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Tornado Kick"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Tornado Kick"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS["Raging Fists"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Raging Fists"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Raging Fists"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Raging Fists"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS["Howling Fist"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Howling Fist"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Howling Fist"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Howling Fist"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS["Backhand Blow"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Backhand Blow"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Backhand Blow"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Backhand Blow"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS["Spinning Attack"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Spinning Attack"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Spinning Attack"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Spinning Attack"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS["Shoulder Tackle"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Shoulder Tackle"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Shoulder Tackle"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Shoulder Tackle"].Fodder = set_combine(sets.precast.WS.Fodder, {})

    -- Midcast Sets

    sets.midcast.FastRecast = {
        head = "Bunzi's Hat",
        neck = "Voltsurge Torque",
        ear1 = "Loquac. Earring",
        ear2 = "Malignance Earring",
        body = "Bunzi's Robe",
        hands = "Malignance Gloves",
        ring1 = "Lebeche Ring",
        ring2 = "Stikini Ring",
        back = "Visucius's Mantle",
        waist = "Isa Belt",
        legs = "Rawhide Trousers",
        feet = "Regal Pumps +1"
    }

    sets.midcast.Dia = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
    sets.midcast.Diaga = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
    sets.midcast["Dia II"] = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
    sets.midcast.Bio = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
    sets.midcast["Bio II"] = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)

    -- Midcast sets for pet actions
    sets.midcast.Pet.Cure = {legs = "Tali'ah Sera. +2"}
    sets.midcast.Pet["Enfeebling Magic"] = {
        head = "Tali'ah Turban +2",
        neck = "Adad Amulet",
        ear1 = "Enmerkar Earring",
        ear2 = "Domesticator's Earring",
        body = "Tali'ah Manteel +2",
        hands = "Tali'ah Gages +2",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = "Visucius's Mantle",
        waist = "Incarnation Sash",
        legs = "Tali'ah Sera. +2",
        feet = "Tali'ah Crackows +2"
    }
    sets.midcast.Pet["Elemental Magic"] = {
        head = "Tali'ah Turban +2",
        neck = "Adad Amulet",
        ear1 = "Enmerkar Earring",
        ear2 = "Domesticator's Earring",
        body = "Tali'ah Manteel +2",
        hands = "Tali'ah Gages +2",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = "Visucius's Mantle",
        waist = "Incarnation Sash",
        legs = "Tali'ah Sera. +2",
        feet = "Tali'ah Crackows +2"
    }

    -- The following sets are predictive and are equipped before we even know the ability will happen, as a workaround due to
    -- the fact that start of ability packets are too late in the case of Pup abilities, WS, and certain spells.
    sets.midcast.Pet.PetEnmityGear = {head = "Anwig Salade", ear2 = "Odnowa Earring +1"}
    sets.midcast.Pet.PetWSGear = {
        main = "Ohtas",
        head = "Kara. Cappello +3",
        neck = "Shulmanu Collar",
        ear1 = "Enmerkar Earring",
        ear2 = "Domesticator's Earring",
        body = "Kara. Farsetto +3",
        hands = "Karagoz Guanti +3",
        ring1 = "Varar Ring +1",
        ring2 = "C. Palug Ring",
        back = "Visucius's Mantle",
        waist = "Incarnation Sash",
        legs = "Kara. Pantaloni +3",
        feet = "Karagoz Scarpe +3"
    }

    sets.midcast.Pet.PetWSGear.Ranged = set_combine(sets.midcast.Pet.PetWSGear, {waist = "Klouskap Sash"})
    sets.midcast.Pet.PetWSGear.Melee = set_combine(sets.midcast.Pet.PetWSGear, {})
    sets.midcast.Pet.PetWSGear.Tank =
        set_combine(sets.midcast.Pet.PetWSGear, {head = "Anwig Salade", waist = "Isa Belt"})
    sets.midcast.Pet.PetWSGear.Bruiser =
        set_combine(sets.midcast.Pet.PetWSGear, {hands = "Mpaca's Gloves", feet = "Mpaca's Boots"})
    sets.midcast.Pet.PetWSGear.LightTank =
        set_combine(sets.midcast.Pet.PetWSGear, {head = "Anwig Salade", waist = "Isa Belt"})
    sets.midcast.Pet.PetWSGear.Magic =
        set_combine(
        sets.midcast.Pet.PetWSGear,
        {
            head = "Tali'ah Turban +2",
            body = "Tali'ah Manteel +2",
            hands = "Tali'ah Gages +2",
            legs = "Tali'ah Sera. +2",
            feet = "Tali'ah Crackows +2"
        }
    )
    sets.midcast.Pet.PetWSGear.Heal =
        set_combine(
        sets.midcast.Pet.PetWSGear,
        {
            head = "Tali'ah Turban +2",
            body = "Tali'ah Manteel +2",
            hands = "Tali'ah Gages +2",
            legs = "Tali'ah Sera. +2",
            feet = "Tali'ah Crackows +2"
        }
    )
    sets.midcast.Pet.PetWSGear.Nuke =
        set_combine(
        sets.midcast.Pet.PetWSGear,
        {
            head = "Tali'ah Turban +2",
            body = "Tali'ah Manteel +2",
            hands = "Tali'ah Gages +2",
            legs = "Tali'ah Sera. +2",
            feet = "Tali'ah Crackows +2"
        }
    )

    -- Currently broken, preserved in case of future functionality.
    --sets.midcast.Pet.WeaponSkill = {}

    -- Sets to return to when not performing an action.

    -- Resting sets
    sets.resting = {}

    -- Idle sets

    sets.idle = {
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",
        ear2 = "Etiolation Earring",
        body = "Kara. Farsetto +3",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Stikini Ring",
        back = "Visucius's Mantle",
        waist = "Incarnation Sash",
        legs = "Kara. Pantaloni +3",
        feet = "Nyame Sollerets"
    }

    sets.idle.Refresh = {
        head = "Rawhide Mask",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Bunzi's Robe",
        hands = "Bunzi's Gloves",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Stikini Ring",
        back = "Visucius's Mantle",
        waist = "Fucho-no-Obi",
        legs = "Rawhide Trousers",
        feet = "Nyame Sollerets"
    }

    -- Set for idle while pet is out (eg: pet regen gear)
    sets.idle.Pet = {
        head = "Kara. Cappello +3",
        neck = "Loricate Torque +1",
        ear1 = "Enmerkar Earring",
        ear2 = "Kara. Earring +1",
        body = "Kara. Farsetto +3",
        hands = "Karagoz Guanti +3",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Stikini Ring",
        back = "Visucius's Mantle",
        waist = "Isa Belt",
        legs = "Kara. Pantaloni +3",
        feet = "Karagoz Scarpe +3"
    }

    -- Idle sets to wear while pet is engaged
    sets.idle.Pet.Engaged = {
        head = "Kara. Cappello +3",
        neck = "Shulmanu Collar",
        ear1 = "Enmerkar Earring",
        ear2 = "Kara. Earring +1", --"Domesticator's Earring",
        body = "Kara. Farsetto +3",
        hands = "Karagoz Guanti +3",
        ring1 = "Varar Ring +1",
        ring2 = "C. Palug Ring",
        back = "Visucius's Mantle",
        waist = "Incarnation Sash",
        legs = "Kara. Pantaloni +3",
        feet = "Karagoz Scarpe +3"
    }

    sets.idle.Pet.Engaged.Ranged = set_combine(sets.idle.Pet.Engaged, {waist = "Klouskap Sash"})
    sets.idle.Pet.Engaged.Melee = set_combine(sets.idle.Pet.Engaged, {})
    sets.idle.Pet.Engaged.Tank =
        set_combine(sets.idle.Pet.Engaged, {head = "Anwig Salade", waist = "Isa Belt", ear2 = "Odnowa Earring +1"})
    sets.idle.Pet.Engaged.Bruiser =
        set_combine(sets.idle.Pet.Engaged, {hands = "Mpaca's Gloves", feet = "Mpaca's Boots"})
    sets.idle.Pet.Engaged.LightTank =
        set_combine(sets.idle.Pet.Engaged, {head = "Anwig Salade", waist = "Isa Belt", ear2 = "Odnowa Earring +1"})
    sets.idle.Pet.Engaged.Magic =
        set_combine(
        sets.idle.Pet.Engaged,
        {
            head = "Tali'ah Turban +2",
            body = "Tali'ah Manteel +2",
            hands = "Tali'ah Gages +2",
            legs = "Tali'ah Sera. +2",
            feet = "Tali'ah Crackows +2"
        }
    )
    sets.idle.Pet.Engaged.Heal = sets.idle.Pet.Engaged.Magic
    sets.idle.Pet.Engaged.Nuke = sets.idle.Pet.Engaged.Magic

    sets.packing = {
        head  = "Nyame Helm",
        neck  = "Loricate Torque +1",
        ear1  = "Alabaster Earring",
        ear2  = "Kara. Earring +1",
        body  = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Stikini Ring",
        back  = "Visucius's Mantle",
        waist = "Fucho-no-Obi",
        legs  = "Nyame Flanchard",
        feet  = "Nyame Sollerets"
    }

    -- Defense sets

    sets.defense.PDT = {
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Odnowa Earring +1",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Stikini Ring",
        back = "Visucius's Mantle",
        waist = "Isa Belt",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.defense.MDT = {
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Odnowa Earring +1",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Stikini Ring",
        back = "Visucius's Mantle",
        waist = "Isa Belt",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.defense.MEVA = {
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Odnowa Earring +1",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Stikini Ring",
        back = "Visucius's Mantle",
        waist = "Isa Belt",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.Kiting = {ring2 = "Shneddick Ring +1"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    -- Normal melee group
    sets.engaged = {
        head = "Mpaca's Cap",
        neck = "Shulmanu Collar",
        ear1 = "Sherida Earring",
        ear2 = "Telos Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Overbearing Ring",
        ring2 = "Epona's Ring",
        back = "Visucius's Mantle",
        waist = "Moonbow Belt +1",
        legs = "Mpaca's Hose",
        feet = "Mpaca's Boots"
    }
    sets.engaged.Acc = {
        head = "Mpaca's Cap",
        neck = "Shulmanu Collar",
        ear1 = "Sherida Earring",
        ear2 = "Telos Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Overbearing Ring",
        ring2 = "Gere Ring",
        back = "Visucius's Mantle",
        waist = "Moonbow Belt +1",
        legs = "Mpaca's Hose",
        feet = "Mpaca's Boots"
    }
    sets.engaged.FullAcc = {
        head = "Mpaca's Cap",
        neck = "Combatant's Torque",
        ear1 = "Sherida Earring",
        ear2 = "Telos Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Cacoethic Ring +1",
        ring2 = "Gere Ring",
        back = "Visucius's Mantle",
        waist = "Olseni Belt",
        legs = "Hiza. Hizayoroi +2",
        feet = "Malignance Boots"
    }
    sets.engaged.Fodder = {
        head = "Mpaca's Cap",
        neck = "Shulmanu Collar",
        ear1 = "Sherida Earring",
        ear2 = "Brutal Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Overbearing Ring",
        ring2 = "Epona's Ring",
        back = "Visucius's Mantle",
        waist = "Moonbow Belt +1",
        legs = "Mpaca's Hose",
        feet = "Mpaca's Boots"
    }
    sets.engaged.DT = {
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Sherida Earring",
        ear2 = "Telos Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Overbearing Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Visucius's Mantle",
        waist = "Moonbow Belt +1",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }
    sets.engaged.Acc.DT = {
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Sherida Earring",
        ear2 = "Telos Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Overbearing Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Visucius's Mantle",
        waist = "Moonbow Belt +1",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }
    sets.engaged.FullAcc.DT = {
        head = "Nyame Helm",
        neck = "Combatant's Torque",
        ear1 = "Sherida Earring",
        ear2 = "Telos Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Cacoethic Ring +1",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Visucius's Mantle",
        waist = "Olseni Belt",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }
    sets.engaged.Fodder.DT = {
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Sherida Earring",
        ear2 = "Brutal Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Overbearing Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Visucius's Mantle",
        waist = "Moonbow Belt +1",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }
    sets.engaged.Pet = {
        head = "Mpaca's Cap",
        neck = "Shulmanu Collar",
        ear1 = "Sherida Earring",
        ear2 = "Telos Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Overbearing Ring",
        ring2 = "Epona's Ring",
        back = "Visucius's Mantle",
        waist = "Klouskap Sash",
        legs = "Mpaca's Hose",
        feet = "Mpaca's Boots"
    }
    sets.engaged.Acc.Pet = {
        head = "Mpaca's Cap",
        neck = "Shulmanu Collar",
        ear1 = "Sherida Earring",
        ear2 = "Telos Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Overbearing Ring",
        ring2 = "Epona's Ring",
        back = "Visucius's Mantle",
        waist = "Klouskap Sash",
        legs = "Mpaca's Hose",
        feet = "Mpaca's Boots"
    }
    sets.engaged.FullAcc.Pet = {
        head = "Mpaca's Cap",
        neck = "Combatant's Torque",
        ear1 = "Sherida Earring",
        ear2 = "Telos Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Cacoethic Ring +1",
        ring2 = "Gere Ring",
        back = "Visucius's Mantle",
        waist = "Klouskap Sash",
        legs = "Hiza. Hizayoroi +2",
        feet = "Malignance Boots"
    }
    sets.engaged.Fodder.Pet = {
        head = "Mpaca's Cap",
        neck = "Shulmanu Collar",
        ear1 = "Sherida Earring",
        ear2 = "Telos Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Overbearing Ring",
        ring2 = "Epona's Ring",
        back = "Visucius's Mantle",
        waist = "Klouskap Sash",
        legs = "Mpaca's Hose",
        feet = "Mpaca's Boots"
    }

    -- Weapons sets
    sets.weapons.PetWeapons = {main = "Varga Purnikawa", range = "Neo Animator"}
    sets.weapons.Godhands = {main = "Godhands", range = "Neo Animator"}
	sets.weapons.Prime = {main = "Varga Purnikawa", range = "Neo Animator"}
	sets.weapons.Kenkonken = {main = "Kenkonken", range = "Neo Animator"}
end

function job_customize_idle_set(idleSet)
    local currently_near_porter = near_porter_moogle()

    if currently_near_porter then
        if not near_porter then
            windower.add_to_chat(160, "Near Porter Moogle - Using packing gear")
            near_porter = true
        end
        return sets.packing
    else
        if near_porter then
            windower.add_to_chat(160, "Left Porter Moogle area - Returning to normal gear")
            near_porter = false
        end
    end

    return idleSet
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