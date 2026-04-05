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
    state.OffenseMode:options("Normal", "SomeAcc", "Acc", "FullAcc", "Fodder")
    state.WeaponskillMode:options("Match", "Normal", "SomeAcc", "Acc", "FullAcc", "Fodder")
    state.HybridMode:options("Normal", "PDT", "MDT")
    state.PhysicalDefenseMode:options("PDT", "PDTReraise")
    state.MagicalDefenseMode:options("MDT", "MDTReraise")
    state.ResistDefenseMode:options("MEVA")
    state.IdleMode:options("Normal", "PDT", "Refresh", "Reraise")
    state.ExtraMeleeMode = M {["description"] = "Extra Melee Mode", "None", "SuppaBrutal", "DWEarrings", "DWMax"}
    state.Passive = M {["description"] = "Passive Mode", "None", "Twilight"}

    -- Weapon Sets
    state.Weapons:options(
        "Chango", -- Great Axe Upheaval build
        "Naegling", -- Sword Savage Blade build
        "DualWeapons", -- Dual Wield setup
        "Greatsword", -- Great Sword Resolution build
        "ProcDagger",
        "ProcSword",
        "ProcGreatSword",
        "ProcScythe",
        "ProcPolearm",
        "ProcGreatKatana",
        "ProcClub",
        "ProcStaff"
    )

    -- JSE Capes - Only using Cichol's Mantle (WAR JSE Cape)
    gear.da_jse_back = {
        name = "Cichol's Mantle",
        augments = {"STR+20", "Accuracy+20 Attack+20", "STR+10", "Weapon skill damage +10%", "Damage taken-5%"}
    }
    gear.wsd_jse_back = {
        name = "Cichol's Mantle",
        augments = {"STR+20", "Accuracy+20 Attack+20", "STR+10", "Weapon skill damage +10%", "Damage taken-5%"}
    }
    gear.vit_jse_back = {
        name = "Cichol's Mantle",
        augments = {"STR+20", "Accuracy+20 Attack+20", "STR+10", "Weapon skill damage +10%", "Damage taken-5%"}
    }
    gear.crit_jse_back = {
        name = "Cichol's Mantle",
        augments = {"STR+20", "Accuracy+20 Attack+20", "STR+10", "Weapon skill damage +10%", "Damage taken-5%"}
    }

    -- Additional local binds
    send_command('bind ^` input /ja "Hasso" <me>')
    send_command('bind !` input /ja "Seigan" <me>')
    send_command("bind @` gs c cycle SkillchainMode")
    send_command("bind !r gs c weapons Naegling;gs c update")
    send_command("bind ^r gs c weapons Chango;gs c update")

    select_default_macro_book()
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------
    -- Precast Sets

    sets.Enmity = {}
    sets.Knockback = {}
    sets.passive.Twilight = {head = "Twilight Helm", body = "Twilight Mail"}

    -- Precast sets to enhance JAs
    sets.precast.JA["Berserk"] = {
        back = gear.da_jse_back,
        feet = {name = "Agoge Calligae +3", augments = {'Enhances "Tomahawk" effect'}}
    }
    sets.precast.JA["Warcry"] = {head = "Agoge Mask +3"}
    sets.precast.JA["Defender"] = {}
    sets.precast.JA["Aggressor"] = {
        head = "Agoge Mask +3",
        body = "Agoge Lorica +3"
    }
    sets.precast.JA["Mighty Strikes"] = {
        hands = "Agoge Mufflers +3"
    }
    sets.precast.JA["Warrior's Charge"] = {
        legs = "Agoge Cuisses +3"
    }
    sets.precast.JA["Tomahawk"] = {
        ammo = "Throwing Tomahawk",
        feet = "Agoge Calligae +3"
    }
    sets.precast.JA["Retaliation"] = {}
    sets.precast.JA["Restraint"] = {}
    sets.precast.JA["Blood Rage"] = {}
    sets.precast.JA["Brazen Rush"] = {}
    sets.precast.JA["Provoke"] = set_combine(sets.Enmity, {})

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz["Healing Waltz"] = {}

    sets.precast.Step = {}
    sets.precast.Flourish1 = {}

    -- Fast cast sets for spells
    sets.precast.FC = {
        ammo = "Impatiens",
        head = "Carmine Mask +1",
        neck = "Voltsurge Torque",
        ear1 = "Enchntr. Earring +1",
        ear2 = "Loquac. Earring",
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        hands = "Leyline Gloves",
        ring1 = "Lebeche Ring",
        ring2 = "Prolix Ring",
        back = "Moonlight Cape",
        waist = "Flume Belt +1",
        legs = {name = "Sakpata's Cuisses", augments = {"Path: A"}},
        feet = {name = "Sakpata's Leggings", augments = {"Path: A"}}
    }

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck = "Magoraga Beads"})

    -- Midcast Sets
    sets.midcast.FastRecast = set_combine(sets.precast.FC, {ammo = "Staunch Tathlum +1"})
    sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {back = "Mujin Mantle"})
    sets.midcast.Cure = {}

    sets.Self_Healing = {
        neck = "Phalaina Locket",
        hands = "Buremte Gloves",
        ring2 = "Kunaji Ring",
        waist = "Gishdubar Sash"
    }

    sets.Cure_Received = {
        neck = "Phalaina Locket",
        hands = "Buremte Gloves",
        ring2 = "Kunaji Ring",
        waist = "Gishdubar Sash"
    }

    -- Weaponskill sets - Updated with your available gear
    sets.precast.WS = {
        ammo = "Knobkierrie",
        head = "Agoge Mask +3",
        neck = {name = "War. Beads +2", augments = {"Path: A"}},
        ear1 = "Thrud Earring",
        ear2 = {name = "Moonshade Earring", augments = {"Accuracy+4", 'Latent effect: "Regain"+1'}},
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = "Petrov Ring",
        ring2 = "Chirich Ring +1",
        back = gear.wsd_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

    sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {ear1 = "Cessance Earring"})
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {head = "Flam. Zucchetto +2", ear1 = "Cessance Earring", ear2 = "Telos Earring"})
    sets.precast.WS.FullAcc = set_combine(sets.precast.WS.Acc, {ring1 = "Chirich Ring +1", ring2 = "Chirich Ring +1"})
    sets.precast.WS.Fodder = set_combine(sets.precast.WS, {})

    -- Savage Blade - Meta sword WS, STR based with high WSD
    sets.precast.WS["Savage Blade"] = {
        ammo = "Knobkierrie",
        head = "Agoge Mask +3",
        neck = {name = "War. Beads +2", augments = {"Path: A"}},
        ear1 = "Thrud Earring",
        ear2 = {name = "Moonshade Earring", augments = {"Accuracy+4", 'Latent effect: "Regain"+1'}},
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = "Petrov Ring",
        ring2 = "Ephramad's Ring",
        back = gear.wsd_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

    -- Upheaval - Meta great axe WS, VIT based
    sets.precast.WS["Upheaval"] = {
        ammo = "Knobkierrie",
        head = "Agoge Mask +3",
        neck = {name = "War. Beads +2", augments = {"Path: A"}},
        ear1 = "Thrud Earring",
        ear2 = {name = "Moonshade Earring", augments = {"Accuracy+4", 'Latent effect: "Regain"+1'}},
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = "Petrov Ring",
        ring2 = "Menelaus's Ring",
        back = gear.vit_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

    -- Resolution - Great sword WS, multi-hit
    sets.precast.WS["Resolution"] = {
        ammo = {name = "Coiste Bodhar", augments = {"Path: A"}},
        head = {name = "Agoge Mask +3", augments = {'Enhances "Savagery" effect'}},
        neck = {name = "War. Beads +2", augments = {"Path: A"}},
        ear1 = "Brutal Earring",
        ear2 = {name = "Moonshade Earring", augments = {"Accuracy+4", 'Latent effect: "Regain"+1'}},
        body = "Agoge Lorica +3",
        hands = "Agoge Mufflers +3",
        ring1 = "Petrov Ring",
        ring2 = "Ephramad's Ring",
        back = gear.da_jse_back,
        waist = "Fotia Belt",
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Sakpata's Leggings", augments = {"Path: A"}}
    }

    -- Decimation - Axe WS, multi-hit
    sets.precast.WS["Decimation"] = {
        ammo = {name = "Coiste Bodhar", augments = {"Path: A"}},
        head = {name = "Agoge Mask +3", augments = {'Enhances "Savagery" effect'}},
        neck = {name = "War. Beads +2", augments = {"Path: A"}},
        ear1 = "Brutal Earring",
        ear2 = "Suppanomimi",
        body = "Agoge Lorica +3",
        hands = "Agoge Mufflers +3",
        ring1 = "Petrov Ring",
        ring2 = "Ephramad's Ring",
        back = gear.da_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

    -- Rampage - Axe WS, critical hit based
    sets.precast.WS["Rampage"] = {
        ammo = "Yetshila +1",
        head = "Boii Mask +2",
        neck = {name = "War. Beads +2", augments = {"Path: A"}},
        ear1 = "Brutal Earring",
        ear2 = "Boii Earring +1",
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        hands = {name = "Nyame Gauntlets", augments = {"Path: B"}},
        ring1 = "Sroda Ring",
        ring2 = "Niqmaddu Ring",
        back = gear.crit_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = "Boii Calligae +2"
    }

    -- Ukko's Fury - Great axe WS, critical hit based
    sets.precast.WS["Ukko's Fury"] = sets.precast.WS["Rampage"]

    -- Copy accuracy versions for all WS
    for ws_name, ws_set in pairs(sets.precast.WS) do
        if type(ws_set) == "table" and type(ws_name) == "string" then
            if not sets.precast.WS[ws_name].SomeAcc then
                sets.precast.WS[ws_name].SomeAcc = set_combine(ws_set, sets.precast.WS.SomeAcc)
            end
            if not sets.precast.WS[ws_name].Acc then
                sets.precast.WS[ws_name].Acc = set_combine(ws_set, sets.precast.WS.Acc)
            end
            if not sets.precast.WS[ws_name].FullAcc then
                sets.precast.WS[ws_name].FullAcc = set_combine(ws_set, sets.precast.WS.FullAcc)
            end
            if not sets.precast.WS[ws_name].Fodder then
                sets.precast.WS[ws_name].Fodder = set_combine(ws_set, sets.precast.WS.Fodder)
            end
        end
    end

    -- Swap to these on Moonshade using WS if at 3000 TP
    sets.MaxTP = {ear1 = "Brutal Earring", ear2 = "Cessance Earring"}
    sets.AccMaxTP = {ear1 = "Cessance Earring", ear2 = "Telos Earring"}

    -- Sets to return to when not performing an action.

    -- Resting sets
    sets.resting = {}

    -- Idle sets - Optimized with your gear for maximum survivability
    sets.idle = {
        ammo = "Staunch Tathlum +1",
        head = "Boii Mask +2",
        neck = "Null Loop",
        ear1 = "Cryptic Earring",
        ear2 = "Odnowa Earring",
        body = "Boii Lorica +2",
        hands = {name = "Sakpata's Gauntlets", augments = {"Path: A"}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back = gear.wsd_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = "Boii Calligae +2" 
    }

    sets.idle.PDT = set_combine(sets.idle, {
        ammo = "Staunch Tathlum +1",
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Genmei Earring",
        ring2 = "Gelatinous Ring +1"
    })

    sets.idle.Weak = set_combine(sets.idle, {head = "Twilight Helm", body = "Twilight Mail"})
    sets.idle.Reraise = set_combine(sets.idle, {head = "Twilight Helm", body = "Twilight Mail"})
	
	-- Packing set for Porter Moogle
sets.packing = {
    main = "Bravura",
    sub = "Utu Grip",
    ammo = "Staunch Tathlum +1",
    head = "Null Masque",
    neck = "Null Loop",
    ear1 = "Cryptic Earring",
    ear2 = "Odnowa Earring",
    body = {name = "Sakpata's Plate", augments = {"Path: A"}},
    hands = {name = "Sakpata's Gauntlets", augments = {"Path: A"}},
    ring1 = { name="Murky Ring", augments={'Path: A',}},
    ring2 = "Defending Ring",
    back = gear.wsd_jse_back,
    waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
    legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
    feet = "Nyame Sollerets"
}

    -- Defense sets
    sets.defense.PDT = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Genmei Earring",
        ear2 = "Ethereal Earring",
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        hands = {name = "Sakpata's Gauntlets", augments = {"Path: A"}},
        ring1 = "Gelatinous Ring +1",
        ring2 = "Moonlight Ring",
        back = "Shadow Mantle",
        waist = "Flume Belt +1",
        legs = {name = "Sakpata's Cuisses", augments = {"Path: A"}},
        feet = {name = "Sakpata's Leggings", augments = {"Path: A"}}
    }

    sets.defense.PDTReraise = set_combine(sets.defense.PDT, {head = "Twilight Helm", body = "Twilight Mail"})

    sets.defense.MDT = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = "Warder's Charm +1",
        ear1 = "Genmei Earring",
        ear2 = "Ethereal Earring",
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        hands = {name = "Sakpata's Gauntlets", augments = {"Path: A"}},
        ring1 = "Gelatinous Ring +1",
        ring2 = "Moonlight Ring",
        back = "Moonlight Cape",
        waist = "Carrier's Sash",
        legs = {name = "Sakpata's Cuisses", augments = {"Path: A"}},
        feet = {name = "Sakpata's Leggings", augments = {"Path: A"}}
    }

    sets.defense.MDTReraise = set_combine(sets.defense.MDT, {head = "Twilight Helm", body = "Twilight Mail"})
    sets.defense.MEVA = sets.defense.MDT

    sets.Kiting = {ring2 = "Shneddick Ring"}
    sets.Reraise = {head = "Twilight Helm", body = "Twilight Mail"}
    sets.buff.Doom = {}
    sets.buff.Sleep = {neck = "Vim Torque +1"}

    -- Engaged sets - Optimized TP sets based on current meta and your available gear

    -- Single Wield (Naegling/Sword builds) - Using your available gear
    sets.engaged = {
        ammo = {name = "Coiste Bodhar", augments = {"Path: A"}},
        head = {name = "Flam. Zucchetto +2"},
        neck = {name = "War. Beads +2", augments = {"Path: A"}},
        ear1 = "Schere Earring",
        ear2 = "Boii Earring +1",
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        hands = {name = "Sakpata's Gauntlets", augments = {"Path: A"}},
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.da_jse_back,
        waist = "Ioskeha Belt +1",
        legs = {name = "Sakpata's Cuisses", augments = {"Path: A"}},
        feet = {name = "Flam. Gambieras +2"}
    }

    sets.engaged.SomeAcc = set_combine(sets.engaged, {
        neck = "Combatant's Torque",
        ear1 = "Cessance Earring",
        ring1 = "Chirich Ring +1"
    })

    sets.engaged.Acc = set_combine(sets.engaged.SomeAcc, {
        ear2 = "Telos Earring",
        hands = {name = "Flam. Manopolas +2"}
    })

    sets.engaged.FullAcc = set_combine(sets.engaged.Acc, {
        head = {name = "Sakpata's Helm", augments = {"Path: A"}},
        ring2 = "Chirich Ring +1"
    })

    sets.engaged.Fodder = set_combine(sets.engaged, {
        neck = "Asperity Necklace"
    })

    -- Two-Handed weapon sets (Chango/Great Axe) - Using your available gear
    sets.engaged.TwoHanded = {
        ammo = {name = "Coiste Bodhar", augments = {"Path: A"}},
        head = {name = "Flam. Zucchetto +2"},
        neck = "Vim Torque +1",
        ear1 = "Brutal Earring",
        ear2 = "Boii Earring +1",
        body = "Boii Lorica +2",
        hands = {name = "Sakpata's Gauntlets", augments = {"Path: A"}},
        ring1 = "Chirich Ring +1",
        ring2 = "Menelaus's Ring",
        back = gear.da_jse_back,
        waist = "Ioskeha Belt +1",
        legs = "Pumm. Cuisses +1",
        feet = "Pumm. Calligae +1"
    }

    -- Hybrid sets for defensive TP
    sets.engaged.PDT = set_combine(sets.engaged, {
        ammo = "Staunch Tathlum +1",
        head = {name = "Sakpata's Helm", augments = {"Path: A"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = "Genmei Earring",
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        ring1 = "Defending Ring",
        ring2 = "Gelatinous Ring +1",
        back = "Shadow Mantle"
    })

    sets.engaged.SomeAcc.PDT = set_combine(sets.engaged.PDT, sets.engaged.SomeAcc)
    sets.engaged.Acc.PDT = set_combine(sets.engaged.PDT, sets.engaged.Acc)
    sets.engaged.FullAcc.PDT = set_combine(sets.engaged.PDT, sets.engaged.FullAcc)

    sets.engaged.MDT = set_combine(sets.engaged, {
        ammo = "Staunch Tathlum +1",
        head = {name = "Sakpata's Helm", augments = {"Path: A"}},
        neck = "Warder's Charm +1",
        ear1 = "Genmei Earring",
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        ring1 = "Defending Ring",
        ring2 = "Moonlight Ring",
        back = "Moonlight Cape"
    })

    sets.engaged.SomeAcc.MDT = set_combine(sets.engaged.MDT, sets.engaged.SomeAcc)
    sets.engaged.Acc.MDT = set_combine(sets.engaged.MDT, sets.engaged.Acc)
    sets.engaged.FullAcc.MDT = set_combine(sets.engaged.MDT, sets.engaged.FullAcc)

    -- Weapon sets - Updated to use weapons you actually have
    sets.weapons.Chango = {main = "Chango", sub = "Utu Grip"}
    sets.weapons.Naegling = {main = "Naegling", sub = "Blurred Shield +1"}
    sets.weapons.DualWeapons = {main = "Naegling", sub = {name = "Ternion Dagger +1", augments = {'Path: A'}}}
    sets.weapons.Greatsword = {main = "Sowilo Claymore", sub = "Utu Grip"}
    sets.weapons.ProcDagger = {main = "Chicken Knife II", sub = ""}
    sets.weapons.ProcSword = {main = "Ark Sword", sub = ""}
    sets.weapons.ProcGreatSword = {main = "Ark Scythe", sub = ""}
    sets.weapons.ProcScythe = {main = "Ark Scythe", sub = ""}
    sets.weapons.ProcPolearm = {main = "Venabulum", sub = ""}
    sets.weapons.ProcGreatKatana = {main = "Hachimonji", sub = ""}
    sets.weapons.ProcClub = {main = "Poison Axe", sub = ""}
    sets.weapons.ProcStaff = {main = "Chatoyant Staff", sub = ""}

    -- Special buff sets
    sets.buff.Retaliation = {}
    sets.buff.Restraint = {}
    sets.TreasureHunter = {}
    sets.Capacity = {back = {name = "Mecisto. Mantle", augments = {'Cap. Point+48%','DEF+4'}}}

    -- Custom melee group sets
    sets.engaged.Adoulin = {body = "Councilor's Garb"}
    sets.engaged.AM = {} -- Aftermath
    sets.engaged.Charge = {} -- Brazen Rush / Warrior's Charge
    sets.engaged.Mighty = {} -- Mighty Strikes
end

-- Handle weapon-specific engaged sets
function job_handle_equipping_gear(playerStatus, eventArgs)
    if player.equipment.main == "Chango" or player.equipment.main == "Ukonvasara" or 
       player.equipment.main == "Bravura" or player.equipment.main == "Conqueror" then
        if playerStatus == "Engaged" then
            equip(sets.engaged.TwoHanded)
            eventArgs.handled = true
        end
    end
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
    if player.sub_job == "SAM" then
        set_macro_page(1, 1)
    elseif player.sub_job == "DNC" then
        set_macro_page(1, 1)
    elseif player.sub_job == "NIN" then
        set_macro_page(1, 1)
    elseif player.sub_job == "THF" then
        set_macro_page(1, 1)
    else
        set_macro_page(1, 1)
    end
end

function user_job_lockstyle()
    windower.chat.input("/lockstyleset 001")
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