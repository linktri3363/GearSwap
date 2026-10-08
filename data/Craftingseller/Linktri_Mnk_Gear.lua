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
    state.OffenseMode:options("Normal", "Acc", "FullAcc", "SubtleBlow", "Counter")
    state.WeaponskillMode:options("Match", "Normal", "Acc", "FullAcc")
    state.HybridMode:options("Normal", "PDT", "Gleti")
    state.PhysicalDefenseMode:options("PDT")
    state.MagicalDefenseMode:options("MDT")
    state.ResistDefenseMode:options("MEVA")
    state.Weapons:options(
        "Godhands",
        "Staff",
        "ProcStaff",
        "ProcClub",
        "Barehanded",
        "ProcSword",
        "ProcGreatSword",
        "ProcScythe",
        "ProcPolearm",
        "ProcGreatKatana"
    )

    state.ExtraMeleeMode = M {["description"] = "Extra Melee Mode", "None"}


    -- Additional local binds
    send_command('bind ^` input /ja "Boost" <me>')
    send_command('bind !` input /ja "Perfect Counter" <me>')
    send_command('bind ^backspace input /ja "Mantra" <me>')
    send_command("bind @` gs c cycle SkillchainMode")

    select_default_macro_book()
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
    
    -- Keep Ask Sash equipped while Boost is active
    if buffactive['Boost'] then
        idleSet = set_combine(idleSet, sets.buff.Boost)
    end
    
    return idleSet
end

-- Function to customize engaged sets to keep Boost gear equipped
function job_customize_melee_set(meleeSet)
    if buffactive['Boost'] then
        meleeSet = set_combine(meleeSet, sets.buff.Boost)
    end
    return meleeSet
end

function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Precast Sets

    -- Precast sets to enhance JAs on use
    sets.precast.JA["Hundred Fists"] = {legs = "Hes. Hose +1"}
    sets.precast.JA["Boost"] = {hands = "Anch. Gloves +2", waist = "Ask Sash"}
    sets.precast.JA["Boost"].OutOfCombat = {hands = "Anch. Gloves +2", waist = "Ask Sash"}
    sets.precast.JA["Dodge"] = {feet = "Anch. Gaiters +2"}
    sets.precast.JA["Focus"] = {head = "Anch. Crown +2"}
    sets.precast.JA["Counterstance"] = {feet = "Hes. Gaiters +1"}
    sets.precast.JA["Footwork"] = {feet = "Anch. Gaiters +2"}  -- CORRECTED
    sets.precast.JA["Formless Strikes"] = {body = "Hes. Cyclas +1"}
    sets.precast.JA["Mantra"] = {feet = "Hes. Gaiters +1"}

    sets.precast.JA["Chi Blast"] = {}

    -- UPDATED: Better Chakra set with proper gear
    sets.precast.JA["Chakra"] = {
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Anch. Cyclas +2",
        hands = "Hes. Gloves +1",
        ring1 = "Gere Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Hes. Hose +1",
        feet = "Anch. Gaiters +2"
    }

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz["Healing Waltz"] = {}

    sets.precast.Step = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        neck = "Combatant's Torque",  -- If unavailable, leave empty
        ear1 = "",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Hiza. Hizayoroi +2",
        feet = "Malignance Boots"
    }

    sets.precast.Flourish1 = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        neck = "Combatant's Torque",  -- If unavailable, leave empty
        ear1 = "",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    -- Fast cast sets for spells

    sets.precast.FC = {
        ammo = "Impatiens",
        head = gear.herculean_fc_head,
        neck = "Voltsurge Torque",
        ear1 = "Enchntr. Earring +1",
        ear2 = "Loquac. Earring",
        body = "Dread Jupon",
        hands = "Leyline Gloves",
        ring1 = "Lebeche Ring",
        ring2 = "Kishar Ring",
        legs = "Rawhide Trousers"
    }

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck = "Magoraga Beads", body = "Passion Jacket"})

    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        ammo = "Coiste Bodhar",
        head = "Mpaca's Cap",
        neck = "Rep. Plat. Medal",  -- Attack+10, STR+3, VIT+3
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",  -- CORRECTED: Don't have Niqmaddu
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",  -- Upgrade to Moonbow Belt +1 when available
        legs = "Mpaca's Hose",
        feet = "Mpaca's Boots"
    }
    sets.precast.WSAcc = {
        ammo = "Coiste Bodhar",
        head = "Dampening Tam",
        neck = "Combatant's Torque",  -- If unavailable, use Rep. Plat. Medal
        ear1 = "",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }
    sets.precast.WSFullAcc = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        neck = "Combatant's Torque",  -- If unavailable, use Rep. Plat. Medal
        ear1 = "",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }
    sets.precast.WS.Acc = set_combine(sets.precast.WS, sets.precast.WSAcc)
    sets.precast.WS.FullAcc = set_combine(sets.precast.WS, sets.precast.WSFullAcc)

    -- Specific weaponskill sets.

    -- UPDATED: Better ring choices for Raging Fists
    sets.precast.WS["Raging Fists"] = set_combine(sets.precast.WS, {
        head = "Mpaca's Cap",
        neck = "Rep. Plat. Medal",
        ear1 = "Moonshade Earring",
        ear2 = "Schere Earring",
        body = "Bhikku Cyclas +2",
        hands = "Bhikku Gloves +2",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",  -- Upgrade to Moonbow Belt +1 when available
        legs = "Mpaca's Hose",  -- UPDATED: Better than Nyame for multi-hit
        feet = "Mpaca's Boots"
    })
    
    sets.precast.WS["Howling Fist"] = set_combine(sets.precast.WS, {
        head = "Mpaca's Cap",
        neck = "Rep. Plat. Medal",
        ear1 = "Moonshade Earring",
        ear2 = "Schere Earring",
        body = "Nyame Mail",
        hands = "Bhikku Gloves +2",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",  -- Upgrade to Moonbow Belt +1 when available
        legs = "Mpaca's Hose",
        feet = "Nyame Sollerets"
    })
    
    -- UPDATED: Better ring choices for Asuran Fists
    sets.precast.WS["Asuran Fists"] = set_combine(sets.precast.WS, {
        head = "Hes. Crown +1",
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Bhikku Earring +1",
        body = "Bhikku Cyclas +2",
        hands = "Bhikku Gloves +2",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",  -- CORRECTED: Don't have Regal Ring
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Mpaca's Hose",
        feet = "Malignance Boots"
    })

    sets.precast.WS["Spinning Attack"] = set_combine(sets.precast.WS, {
        head = "Mpaca's Cap",
        neck = "Rep. Plat. Medal",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    })

    -- UPDATED: Victory Smite with proper Impetus handling
    sets.precast.WS["Victory Smite"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar",
        head = "Mpaca's Cap",
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",  -- Upgrade to Moonbow Belt +1 when available
        legs = "Mpaca's Hose",
        feet = "Mpaca's Boots"
    })

    -- NEW: Critical addition - Victory Smite with Impetus
    sets.precast.WS["Victory Smite"].Impetus = set_combine(sets.precast.WS["Victory Smite"], {
        body = "Bhikku Cyclas +2"  -- CRITICAL: +45% crit damage with Impetus
    })

    sets.precast.WS["Shijin Spiral"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar",
        head = "Mpaca's Cap",
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Mpaca's Hose",
        feet = "Mpaca's Boots"
    })

    sets.precast.WS["Tornado Kick"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar",
        head = "Mpaca's Cap",
        neck = "Rep. Plat. Medal",
        ear1 = "Sherida Earring",
        ear2 = "Moonshade Earring",
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Mpaca's Hose",
        feet = "Anch. Gaiters +2"  -- MUST wear for Footwork bonus
    })

    sets.precast.WS["Dragon Kick"] = set_combine(sets.precast.WS, {
        feet = "Anch. Gaiters +2"  -- MUST wear for Footwork bonus
    })

    -- Final Heaven (Relic)
    sets.precast.WS["Final Heaven"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar",
        head = "Mpaca's Cap",
        neck = "Rep. Plat. Medal",
        ear1 = "Sherida Earring",
        ear2 = "Ishvara Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    })

    -- Staff Weaponskills
    sets.precast.WS["Shell Crusher"] = {
        ammo = "Pemphredo Tathlum",
        head = "Malignance Chapeau",
        neck = "Rep. Plat. Medal",
        ear1 = "",
        ear2 = "Telos Earring",
        body = "Bhikku Cyclas +2",
        hands = "Bhikku Gloves +2",
        ring1 = "Stikini Ring",
        ring2 = { name="Metamor. Ring +1", augments={'Path: A',}},
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Bhikku Hose +2",
        feet = "Bhikku Gaiters +2"
    }

    sets.precast.WS["Cataclysm"] = {
        ammo = "Pemphredo Tathlum",
        head = "Nyame Helm",
        neck = "Sibyl Scarf",
        ear1 = "Friomisi Earring",
        ear2 = "Moonshade Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Archon Ring",
        ring2 = { name="Metamor. Ring +1", augments={'Path: A',}},
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    -- Midcast Sets
    sets.midcast.FastRecast = {}

    -- Specific spells
    sets.midcast.Utsusemi = {}

    -- Idle/resting/defense/etc. sets

    -- NEW: Idle set optimized
    sets.idle = {
        ammo = "Staunch Tathlum +1",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = { name="Alabaster Earring", augments={'Path: A',}},
        ear2 = "Sanare Earring",
        body = "Hiza. Haramaki +2",
        hands = "Malignance Gloves",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Chirich Ring +1",  -- Store TP+6, Subtle Blow+10
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Bhikku Hose +2",
        feet = "Bhikku Gaiters +2"
    }

    sets.idle.Weak = sets.idle

    -- Defense sets
    sets.defense.PDT = {
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},  -- DT-10%
        ring2 = "Defending Ring",  -- DT-10% (if you have it)
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.defense.MDT = {
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Warder's Charm +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Archon Ring",
        ring2 = "Shadow Ring",
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.defense.MEVA = {
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Warder's Charm +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Archon Ring",
        ring2 = "Shadow Ring",
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.Kiting = {ring1 = "Shneddick Ring"}

    -- Engaged sets

    -- Normal melee sets
    sets.engaged = {
        ammo = "Coiste Bodhar",
        head = "Dampening Tam",
        neck = "Mnk. Nodowa +2",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Adhemar Wrist. +1",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Reiki Yotai",  -- Store TP+5, Dual Wield+7
        legs = "Bhikku Hose +2",
        feet = "Malignance Boots"
    }
    
    -- UPDATED: Accuracy set with Chirich rings option
    sets.engaged.Acc = {
        ammo = "Coiste Bodhar",
        head = "Dampening Tam",
        neck = "Mnk. Nodowa +2",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Adhemar Wrist. +1",
        ring1 = "Chirich Ring +1",  -- Acc+10, STP+6, SB+10
        ring2 = "Chirich Ring +1",  -- Acc+10, STP+6, SB+10
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Reiki Yotai",
        legs = "Bhikku Hose +2",
        feet = "Malignance Boots"
    }
    
    sets.engaged.FullAcc = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        neck = "Rep. Plat. Medal",
        ear1 = "",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Reiki Yotai",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    -- NEW: Subtle Blow set for TP denial
    sets.engaged.SubtleBlow = {
        ammo = "Coiste Bodhar",
        head = "Hiza. Somen +2",        -- Subtle Blow +6
        neck = "Mnk. Nodowa +2",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Hiza. Haramaki +2",     -- Subtle Blow +10
        hands = "Hizamaru Kote +2",     -- Subtle Blow +8
        ring1 = "Chirich Ring +1",      -- Subtle Blow +10
        ring2 = "Chirich Ring +1",      -- Subtle Blow +10
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Reiki Yotai",
        legs = "Hiza. Hizayoroi +2",    -- Subtle Blow +9
        feet = "Hiza. Sune-Ate +2"      -- Subtle Blow +7
    }
    -- Total: ~60 Subtle Blow

    -- NEW: Counter set
    sets.engaged.Counter = {
        ammo = "Coiste Bodhar",
        head = "Hes. Crown +1",          -- Counter +5
        neck = "Mnk. Nodowa +2",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Hiza. Haramaki +2",      -- Or Mpaca's Doublet
        hands = "Hizamaru Kote +2",      -- Counter +5
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Reiki Yotai",
        legs = "Anch. Hose +2",          -- Counter +8
        feet = "Hes. Gaiters +1"         -- Counter +6
    }

    -- Defensive melee hybrid sets
    sets.engaged.PDT = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Brutal Earring",
        ear2 = "Sherida Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",  -- HP+50, Physical resistance
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }
    
    sets.engaged.Acc.PDT = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "",
        ear2 = "Sherida Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }
    
    sets.engaged.FullAcc.PDT = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    -- NEW: Gleti's hybrid set (Store TP+35 total!)
    sets.engaged.Gleti = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Gleti's Cuirass",      -- Store TP+7
        hands = "Gleti's Gauntlets",   -- Store TP+7
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Reiki Yotai",
        legs = "Gleti's Breeches",     -- Store TP+7
        feet = "Gleti's Boots"         -- Store TP+7
    }

    -- Hundred Fists/Impetus melee set mods
    sets.engaged.HF = set_combine(sets.engaged, {})
    sets.engaged.Acc.HF = set_combine(sets.engaged.Acc, {})
    sets.engaged.FullAcc.HF = set_combine(sets.engaged.FullAcc, {})

    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Sleep = {head = "Frenzy Sallet"}
    sets.buff.Impetus = {body = "Bhikku Cyclas +2"}
    sets.buff.Footwork = {feet = "Anch. Gaiters +2"}  -- CORRECTED
    sets.buff.Boost = {waist = "Ask Sash"}

    sets.FootworkWS = {feet = "Anch. Gaiters +2"}  -- CORRECTED
    sets.DayIdle = {}
    sets.NightIdle = {}
    sets.Knockback = {}
    sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
    sets.Skillchain = {legs = "Ryuo Hakama"}

    -- Weapons sets
    sets.weapons.Godhands = {main = "Godhands"}
    sets.weapons.Barehanded = {main = empty}
    sets.weapons.Staff = {main = "Malignance Pole", sub = "Bloodrain Strap"}
    sets.weapons.ProcStaff = {main = "Terra's Staff"}
    sets.weapons.ProcClub = {main = "Mafic Cudgel"}
    sets.weapons.ProcSword = {main = "Ark Sword", sub = empty}
    sets.weapons.ProcGreatSword = {main = "Lament", sub = empty}
    sets.weapons.ProcScythe = {main = "Ark Scythe", sub = empty}
    sets.weapons.ProcPolearm = {main = "Pitchfork +1", sub = empty}
    sets.weapons.ProcGreatKatana = {main = "Hardwood Katana", sub = empty}
	
	    -- Packing set for Porter Moogle
    sets.packing = {
        main = "",
        sub = "",
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == "DNC" then
        set_macro_page(1, 2)
    elseif player.sub_job == "NIN" then
        set_macro_page(1, 2)
    elseif player.sub_job == "THF" then
        set_macro_page(1, 2)
    elseif player.sub_job == "RUN" then
        set_macro_page(1, 2)
    else
        set_macro_page(1, 2)
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

-- Handle Boost buff to keep Ask Sash equipped
function job_buff_change(buff, gain)
    if buff == "Boost" then
        if gain then
            equip(sets.buff.Boost)
        else
            handle_equipping_gear(player.status)
        end
    end
end