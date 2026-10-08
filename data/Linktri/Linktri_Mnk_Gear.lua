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
    state.HybridMode:options("Normal", "PDT", "Gleti", "PDTOffense") -- LINKTRI MODIFICATION: added armor-capped PDT-offense hybrid
    state.PhysicalDefenseMode:options("PDT")
    state.MagicalDefenseMode:options("MDT")
    state.ResistDefenseMode:options("MEVA")
    state.Weapons:options(
        "Prime",
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
    -- LINKTRI MODIFICATION: this override was clobbering MNK.lua's version, killing the Impetus body
    -- swap and Footwork feet handling while engaged. Base logic restored below, Boost kept.
    if state.OffenseMode.value ~= 'FullAcc' then
        if state.Buff['Impetus'] then
            meleeSet = set_combine(meleeSet, sets.buff.Impetus)
        end
        if buffactive.Footwork then
            meleeSet = set_combine(meleeSet, sets.buff.Footwork)
        end
    end
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
    sets.precast.JA["Hundred Fists"] = {legs = "Hesy. Hose +4"}
    sets.precast.JA["Boost"] = {hands = "Anch. Gloves +4", waist = "Ask Sash"}
    sets.precast.JA["Boost"].OutOfCombat = {hands = "Anch. Gloves +4", waist = "Ask Sash"}
    sets.precast.JA["Dodge"] = {feet = "Anch. Gaiters +4"}
    sets.precast.JA["Focus"] = {head = "Anchor. Crown +4"}
    sets.precast.JA["Counterstance"] = {feet = "Hesy. Gaiters +4"}
    sets.precast.JA["Footwork"] = {feet = "Bhikku Gaiters +3"}
    sets.precast.JA["Formless Strikes"] = {body = "Hesy. Cyclas +4"}
    sets.precast.JA["Mantra"] = {feet = "Hesy. Gaiters +4"}

    sets.precast.JA["Chi Blast"] = {}

    -- UPDATED: Better Chakra set with proper gear
    sets.precast.JA["Chakra"] = {
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Anch. Cyclas +4", -- LINKTRI MODIFICATION: fixed missing + (Chakra body was silently failing)
        hands = "Hesy. Gloves +4",
        ring1 = "Gere Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Hesy. Hose +4",
        feet = "Anch. Gaiters +4"
    }

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz["Healing Waltz"] = {}

    sets.precast.Step = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        neck = "Combatant's Torque",
        ear1 = "Bhikku Earring +1", -- LINKTRI MODIFICATION: filled empty ear1 (Acc+13/MAcc+13/STP+4)
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
        neck = "Combatant's Torque",
        ear1 = "Bhikku Earring +1", -- LINKTRI MODIFICATION: filled empty ear1
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
        hands = "Malignance Gloves",
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
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Bhikku Gloves +3",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Mpaca's Hose",
        feet = "Bhikku Gaiters +3"
    }
    sets.precast.WSAcc = {
        ammo = "Coiste Bodhar",
        head = "Dampening Tam",
        neck = "Combatant's Torque",
        ear1 = "Bhikku Earring +1", -- LINKTRI MODIFICATION: filled empty ear1
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
        neck = "Combatant's Torque",
        ear1 = "Bhikku Earring +1", -- LINKTRI MODIFICATION: filled empty ear1
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

    -- OPTIMIZED: Raging Fists with Bhikku pieces for WSD+12% and PDL+10%
    sets.precast.WS["Raging Fists"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar", -- LINKTRI MODIFICATION: reverted Knobkierrie -- gear WSD% is FIRST-HIT-ONLY, weak on 5-hit Raging Fists; Coiste DA adds hits across all swings
        head = "Mpaca's Cap",
        neck = "Rep. Plat. Medal",
        ear1 = "Moonshade Earring",
        ear2 = "Schere Earring",
        body = "Bhikku Cyclas +3",
        hands = "Bhikku Gloves +3",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Thunder Belt", -- LINKTRI MODIFICATION: Raging Fists = Impaction; Thunder Belt +0.1 fTP replicates across all 5 hits
        legs = "Mpaca's Hose",
        feet = "Bhikku Gaiters +3"
    })
    
    -- OPTIMIZED: Howling Fist with Bhikku hands for VIT and PDL
    sets.precast.WS["Howling Fist"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar", -- LINKTRI MODIFICATION: reverted Knobkierrie (WSD first-hit-only); Coiste DA adds hits
        head = "Mpaca's Cap",
        neck = "Light Gorget", -- LINKTRI MODIFICATION: Howling Fist = Transfixion/Impaction; Light Gorget (Transfixion) +0.1 fTP replicates all hits
        ear1 = "Moonshade Earring",
        ear2 = "Schere Earring",
        body = "Nyame Mail",
        hands = "Bhikku Gloves +3",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Thunder Belt", -- LINKTRI MODIFICATION: Howling Fist is Impaction-aligned; elemental belt +0.1 fTP
        legs = "Mpaca's Hose",
        feet = "Mpaca's Boots"
    })
    
    -- OPTIMIZED: Asuran Fists - already using best pieces
    sets.precast.WS["Asuran Fists"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar", -- LINKTRI MODIFICATION: reverted Knobkierrie -- on 8-hit Asuran Fists, first-hit-only WSD+6% is ~+0.75%; Coiste DA adds hits across all 8 swings (Asuran cannot crit, so no crit ammo either)
        head = "Hes. Crown +4",
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Bhikku Earring +1",
        body = "Bhikku Cyclas +3",
        hands = "Bhikku Gloves +3",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Mpaca's Hose",
        feet = "Bhikku Gaiters +3"
    })

    sets.precast.WS["Spinning Attack"] = set_combine(sets.precast.WS, {
        head = "Mpaca's Cap",
        neck = "Rep. Plat. Medal",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    })

    -- OPTIMIZED: Victory Smite with Anch hands for WSD+10%
    sets.precast.WS["Victory Smite"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar", -- LINKTRI MODIFICATION: Victory Smite CAN crit; Coiste DA adds crit-capable hits > Oshasha's first-hit-only WSD+3%
        head = "Mpaca's Cap",
        neck = "Light Gorget", -- LINKTRI MODIFICATION: Victory Smite = Light/Fragmentation (fTP-replicating); Light Gorget +0.1 fTP on EVERY hit
        ear1 = "Moonshade Earring", -- LINKTRI MODIFICATION: TP Bonus+250 (swapped out above 3200 TP via sets.MaxTP)
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Anch. Gloves +4",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Light Belt", -- LINKTRI MODIFICATION: pairs with Light Gorget for +0.2 fTP total on Light WS
        legs = "Mpaca's Hose",
        feet = "Mpaca's Boots"
    })

    -- CRITICAL: Victory Smite with Impetus - Bhikku body for +45% crit damage
    sets.precast.WS["Victory Smite"].Impetus = set_combine(sets.precast.WS["Victory Smite"], {
        body = "Bhikku Cyclas +3"
    })

    -- OPTIMIZED: Shijin Spiral with Bhikku pieces for DEX and PDL
    sets.precast.WS["Shijin Spiral"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar", -- LINKTRI MODIFICATION: Shijin (5 hits, cannot crit); Coiste DA adds hits > first-hit-only WSD. NOTE: Mpaca's crit rate here is dead stat (Shijin can't crit) but its TA/Atk/PDL still count
        head = "Mpaca's Cap",
        neck = "Light Gorget", -- LINKTRI MODIFICATION: Shijin = Fusion/Reverberation; Fusion carries the Light element, so Light Gorget aligns & +0.1 fTP replicates all 5 hits
        ear1 = "Sherida Earring",
        ear2 = "Mache Earring +1",
        body = "Mpaca's Doublet",
        hands = "Bhikku Gloves +3",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Light Belt", -- LINKTRI MODIFICATION: pairs with Light Gorget for +0.2 fTP on Fusion open
        legs = "Mpaca's Hose",
        feet = "Bhikku Gaiters +3"
    })

    sets.precast.WS["Tornado Kick"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar",
        head = "Mpaca's Cap",
        neck = "Mnk. Nodowa +2", -- LINKTRI MODIFICATION: kick WS -- Kick Attacks+25 directly boosts the kick hits; also PDL+10%/DEX+15 (beats Rep. Plat. Medal here)
        ear1 = "Sherida Earring",
        ear2 = "Moonshade Earring",
        body = "Mpaca's Doublet",
        hands = "Bhikku Gloves +3",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Thunder Belt", -- LINKTRI MODIFICATION: Tornado Kick = Impaction; Thunder Belt +0.1 fTP replicates across all hits
        legs = "Mpaca's Hose",
        feet = "Bhikku Gaiters +3"
    })

    -- LINKTRI MODIFICATION: Dragon Kick built out as a kick WS. Fragmentation SC property (Thunder Belt aligns
    -- via the Lightning element), fTP-replicating, TP-scaling fTP so it wants high TP + per-hit multipliers.
    -- Kick Attacks feet (Anch. Gaiters +4 Kick Atk +120) + Mnk. Nodowa +2 (Kick Attacks+25) drive the kick damage.
    sets.precast.WS["Dragon Kick"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar",
        head = "Mpaca's Cap",
        neck = "Mnk. Nodowa +2",
        ear1 = "Sherida Earring",
        ear2 = "Moonshade Earring",
        body = "Mpaca's Doublet",
        hands = "Bhikku Gloves +3",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Thunder Belt",
        legs = "Mpaca's Hose",
        feet = "Anch. Gaiters +4" -- Kick Attacks attack +120 / Kick Attacks+10
    })

    -- OPTIMIZED: Final Heaven with Knobkierrie for WSD+10%
    sets.precast.WS["Final Heaven"] = set_combine(sets.precast.WS, {
        ammo = "Knobkierrie",
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
        body = "Bhikku Cyclas +3",
        hands = "Bhikku Gloves +3",
        ring1 = "Stikini Ring",
        ring2 = { name="Metamor. Ring +1", augments={'Path: A',}},
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Bhikku Hose +3",
        feet = "Bhikku Gaiters +3"
    }

    sets.precast.WS["Cataclysm"] = {
        ammo = "Pemphredo Tathlum",
        head = "Nyame Helm",
        neck = "Sibyl Scarf",
        ear1 = "Etiolation Earring",
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
        head = "Bhikku Crown +3",
        neck = "Loricate Torque +1",
        ear1 = { name="Alabaster Earring", augments={'Path: A',}},
        ear2 = "Hoxne Earring",
        body = "Hiza. Haramaki +2", -- LINKTRI MODIFICATION: Regen+12 vs Cyclas Regen+5; idle DT still capped
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Bhikku Hose +3",
        feet = "Bhikku Gaiters +3"
    }

    sets.idle.Weak = sets.idle

    -- Defense sets
    sets.defense.PDT = {
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = { name="Alabaster Earring", augments={'Path: A',}},
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Bhikku Hose +3", -- LINKTRI MODIFICATION: fixed missing +3 (was silently failing)
        feet = "Nyame Sollerets"
    }

    sets.defense.MDT = {
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Archon Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.defense.MEVA = {
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Archon Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.Kiting = {ring1 = "Shneddick Ring +1"}

    -- Engaged sets

    -- OPTIMIZED: Normal melee set with Hesy hands and Bhikku feet
    sets.engaged = {
        ammo = "Coiste Bodhar",
        head = "Dampening Tam",
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Hesy. Gloves +4",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Cornelia's Belt", -- LINKTRI MODIFICATION: Cornelia's Haste+10%/STR+10 // SWAP TO "Moonbow Belt +1" (DA+3%/STP) WHEN ACQUIRED
        legs = "Bhikku Hose +3",
        feet = "Bhikku Gaiters +3"
    }
    
    -- OPTIMIZED: Accuracy set
    sets.engaged.Acc = {
        ammo = "Coiste Bodhar",
        head = "Dampening Tam",
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Hesy. Gloves +4",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone", -- LINKTRI MODIFICATION: Reiki Yotai DW is wasted on H2H; Eschan Stone gives Acc+15/Atk+15
        legs = "Bhikku Hose +3",
        feet = "Bhikku Gaiters +3"
    }
    
    sets.engaged.FullAcc = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        neck = "Rep. Plat. Medal",
        ear1 = "Bhikku Earring +1", -- LINKTRI MODIFICATION: filled empty ear1
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone", -- LINKTRI MODIFICATION: Reiki Yotai DW wasted on H2H; Eschan Stone Acc+15/Atk+15
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    -- NEW: Subtle Blow set for TP denial
    sets.engaged.SubtleBlow = {
        ammo = "Coiste Bodhar",
        head = "Bhikku Crown +3",
        neck = "Mnk. Nodowa +2",
        ear1 = "Sherida Earring",
        ear2 = "Bhikku Earring +1",
        body = "Bhikku Cyclas +3",
        hands = "Anch. Gloves +4",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Cornelia's Belt", -- LINKTRI MODIFICATION: Cornelia's fallback // SWAP TO "Moonbow Belt +1" WHEN ACQUIRED
        legs = "Mpaca's Hose",
        feet = "Bhikku Gaiters +3"
    }

    -- OPTIMIZED: Counter set with Hesy body for Counter Crit+30%
    sets.engaged.Counter = {
        ammo = "Coiste Bodhar",
        head = "Hes. Crown +4",
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Hesy. Cyclas +4",
        hands = "Hizamaru Kote +2",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Cornelia's Belt", -- LINKTRI MODIFICATION: Haste+10%/STR+10/Counter+5, synergizes with Counter set (Reiki DW wasted on H2H)
        legs = "Anch. Hose +4",
        feet = "Hesy. Gaiters +4"
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
        waist = "Carrier's Sash",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }
    
    sets.engaged.Acc.PDT = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Bhikku Earring +1", -- LINKTRI MODIFICATION: filled empty ear1
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
        ear1 = "Bhikku Earring +1", -- LINKTRI MODIFICATION: filled empty ear1
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
        body = "Gleti's Cuirass",
        hands = "Gleti's Gauntlets",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Reiki Yotai",
        legs = "Gleti's Breeches",
        feet = "Gleti's Boots"
    }

    -- LINKTRI MODIFICATION: PDT-offense hybrid. Armor alone caps physical DT at -50
    -- (Bhikku Crown+3 DT-11, Mpaca's Doublet PDT-10, Malig. Gloves DT-5, Bhikku Hose+3 DT-14,
    -- Bhikku Gaiters+3 DT-10), leaving rings/waist/back fully offensive. Higher DPS than full Malignance
    -- when the incoming threat is physical. Cycle via HybridMode if desired.
    sets.engaged.PDTOffense = {
        ammo = "Coiste Bodhar",
        head = "Bhikku Crown +3",
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Malignance Gloves",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Cornelia's Belt",
        legs = "Bhikku Hose +3",
        feet = "Bhikku Gaiters +3"
    }

    -- Hundred Fists/Impetus melee set//g mods
    sets.engaged.HF = set_combine(sets.engaged, {})
    sets.engaged.Acc.HF = set_combine(sets.engaged.Acc, {})
    sets.engaged.FullAcc.HF = set_combine(sets.engaged.FullAcc, {})

    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Sleep = {head = "Frenzy Sallet"}
    sets.buff.Impetus = {body = "Bhikku Cyclas +3"}
    sets.buff.Footwork = {feet = "Bhikku Gaiters +3"}
    sets.buff.Boost = {waist = "Ask Sash"}

    sets.FootworkWS = {feet = "Bhikku Gaiters +3"}

    -- LINKTRI MODIFICATION: MaxTP sets — MNK.lua's job_post_precast swaps Moonshade out of a WS set
    -- when effective TP > 3200. Without these defined, that swap silently did nothing.
    sets.MaxTP = {ear1 = "Schere Earring"}
    sets.AccMaxTP = {ear1 = "Bhikku Earring +1"}
    sets.DayIdle = {}
    sets.NightIdle = {}
    sets.Knockback = {}
    sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
    sets.Skillchain = {legs = "Ryuo Hakama"}

    -- Weapons sets
	sets.weapons.Prime = {main = "Varga Purnikawa", sub = empty}
	sets.weapons.Godhands = {main = "Godhands", sub = empty}
	sets.weapons.Barehanded = {main = empty, sub = empty}
	sets.weapons.Staff = {main = "Malignance Pole", sub = "Bloodrain Strap"}
	sets.weapons.ProcStaff = {main = "Terra's Staff", sub = empty}
	sets.weapons.ProcClub = {main = "Mafic Cudgel", sub = empty}
	sets.weapons.ProcSword = {main = "Ark Sword", sub = empty}
	sets.weapons.ProcGreatSword = {main = "Lament", sub = empty}
	sets.weapons.ProcScythe = {main = "Ark Scythe", sub = empty}
	sets.weapons.ProcPolearm = {main = "Pitchfork +1", sub = empty}
	sets.weapons.ProcGreatKatana = {main = "Hardwood Katana", sub = empty}
	
	    -- Packing set for Porter Moogle
    sets.packing = {
        -- LINKTRI MODIFICATION: removed main=""/sub="" (empty strings don't unequip; use 'empty' if ever needed)
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
    update_melee_groups() -- LINKTRI MODIFICATION: restore base MNK.lua behavior (Hundred Fists/AM melee groups)
    if buff == "Boost" then
        if gain then
            equip(sets.buff.Boost)
        else
            handle_equipping_gear(player.status)
        end
    end
end