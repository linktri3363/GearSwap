fixed_pos = ''
fixed_ts = os.time()
local no_interruptions = true

-- HP lock state for emergency CR set
hp_lock_active = false
last_hp = 100
hp_check_timer = 0

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
        "Naegling", -- Sword Savage Blade - Fencer build (Blurred Shield +1)
		"Shining",
        "NaeglingDual", -- Sword Savage Blade - Dual Wield build (Naegling + Ternion Dagger +1)
        "Loxotic", -- Blunt damage build on club (Judgment)
        "DualWeapons", -- Alias for NaeglingDual, kept for macro compatibility
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

    sets.Enmity = {
        head  = {name = "Eschite Helm", augments = {"HP+80", "Enmity+7", "Phys. dmg. taken -4"}},
        body  = "Pumm. Lorica +3",
        hands = {name = "Eschite Gauntlets", augments = {"Accuracy+20", '"Dbl.Atk."+4', "Enmity+7"}},
        legs  = {name = "Eschite Cuisses", augments = {"HP+80", "Enmity+7", "Phys. dmg. taken -4"}},
        feet  = "Eschite Greaves",
        ear1  = "Trux Earring",
        ear2  = "Lugalbanda Earring",
        ring1 = "Flamma Ring",
    }
    sets.Knockback = {}
    sets.passive.Twilight = {head = "Twilight Helm", body = "Twilight Mail"}

    -- Precast sets to enhance JAs
    sets.precast.JA["Berserk"] = {
        back = gear.da_jse_back,
        body = "Pumm. Lorica +3",
        feet = "Agoge Calligae +3" -- Enhances "Berserk" effect duration (base +3 bonus, no augment needed)
    }
    sets.precast.JA["Warcry"] = {head = "Agoge Mask +3"}
    sets.precast.JA["Defender"] = {
        hands = "Agoge Mufflers +3"
    }
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
    sets.precast.JA["Retaliation"] = {
        hands = "Pumm. Mufflers +3"
    }
    sets.precast.JA["Restraint"] = {
        hands = "Boii Mufflers +3"
    }
    sets.precast.JA["Blood Rage"] = {
        body = "Boii Lorica +3"
    }
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

    -- Weaponskill sets
    -- NOTE: Moonshade Earring in inventory has Attack+4 / TP Bonus +250 augments.
    --       It is used in ear2 of WS sets as a TP dump piece (swap out at 3000 TP via sets.MaxTP).
    sets.precast.WS = {
        ammo = "Knobkierrie",
        head = "Agoge Mask +3",
        neck = {name = "War. Beads +2", augments = {"Path: A"}},
        ear1 = "Ishvara Earring",
        ear2 = {name = "Moonshade Earring", augments = {"Attack+4", "TP Bonus +250"}},
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = "Boii Mufflers +3",
        ring1 = "Ephramad's Ring",
        ring2 = "Beithir Ring",
        back = gear.wsd_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

    sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {ear1 = "Cessance Earring"})
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {head = "Flam. Zucchetto +2", ear1 = "Cessance Earring", ear2 = "Telos Earring"})
    sets.precast.WS.FullAcc = set_combine(sets.precast.WS.Acc, {ring1 = "Chirich Ring +1", ring2 = "Chirich Ring +1"})
    sets.precast.WS.Fodder = set_combine(sets.precast.WS, {})

    -- Savage Blade - Sword WS, 2-hit, STR 30% / MND 50%
    -- MND-heavy modifier. Serves both Fencer (Naegling + Blurred Shield +1) and DualWeapons
    -- (Naegling + Ternion Dagger +1) builds -- weapon swap handled in sets.weapons, not here.
    sets.precast.WS["Savage Blade"] = {
        ammo = "Knobkierrie",
        head = "Agoge Mask +3",
        neck = {name = "War. Beads +2", augments = {"Path: A"}},
        ear1 = "Ishvara Earring",
        ear2 = {name = "Moonshade Earring", augments = {"Attack+4", "TP Bonus +250"}},
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        hands = "Boii Mufflers +3",
        ring1 = "Ephramad's Ring",
        ring2 = "Beithir Ring",
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
        ear1 = "Ishvara Earring",
        ear2 = {name = "Moonshade Earring", augments = {"Attack+4", "TP Bonus +250"}},
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = "Boii Mufflers +3",
        ring1 = "Ephramad's Ring",
        ring2 = "Beithir Ring",
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
        ear2 = {name = "Moonshade Earring", augments = {"Attack+4", "TP Bonus +250"}},
        body = "Agoge Lorica +3",
        hands = "Agoge Mufflers +3",
        ring1 = "Ephramad's Ring",
        ring2 = "Beithir Ring",
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
        ear2 = "Schere Earring",
        body = "Agoge Lorica +3",
        hands = "Agoge Mufflers +3",
        ring1 = "Ephramad's Ring",
        ring2 = "Beithir Ring",
        back = gear.da_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

    -- Rampage - Axe WS, critical hit based
    -- NOTE: Boii Earring +2 MUST be in ear2 slot.
    sets.precast.WS["Rampage"] = {
        ammo = "Yetshila +1",
        head = "Boii Mask +3",
        neck = {name = "War. Beads +2", augments = {"Path: A"}},
        ear1 = "Brutal Earring",
        ear2 = {name = "Boii Earring +2", augments = {'System: 1 ID: 1676 Val: 0','Accuracy+17','Mag. Acc.+17','Crit.hit rate+6','STR+9 VIT+9'}},
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        hands = "Boii Mufflers +3",
        ring1 = "Ephramad's Ring",
        ring2 = "Beithir Ring",
        back = gear.crit_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = "Boii Calligae +3"
    }

    -- Ukko's Fury - Great axe WS, critical hit based (same as Rampage build)
    sets.precast.WS["Ukko's Fury"] = sets.precast.WS["Rampage"]

    -- Judgment - Club WS, 1-hit, STR 40% / MND 40%
    -- Stack both STR and MND equally. Nyame Mail Path B contributes MND alongside STR.
    sets.precast.WS["Judgment"] = {
        ammo = "Knobkierrie",
        head = "Agoge Mask +3",
        neck = {name = "War. Beads +2", augments = {"Path: A"}},
        ear1 = "Ishvara Earring",
        ear2 = {name = "Moonshade Earring", augments = {"Attack+4", "TP Bonus +250"}},
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = "Boii Mufflers +3",
        ring1 = "Ephramad's Ring",
        ring2 = "Beithir Ring",
        back = gear.wsd_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

    -- Impulse Drive - Polearm WS, 2-hit, STR 50%
    -- Pure STR/WSD build. Mirrors Upheaval in structure; use on Shining One.
    sets.precast.WS["Impulse Drive"] = {
        ammo = "Knobkierrie",
        head = "Agoge Mask +3",
        neck = {name = "War. Beads +2", augments = {"Path: A"}},
        ear1 = "Ishvara Earring",
        ear2 = {name = "Moonshade Earring", augments = {"Attack+4", "TP Bonus +250"}},
        body = {name = "Nyame Mail", augments = {"Path: B"}},
        hands = "Boii Mufflers +3",
        ring1 = "Ephramad's Ring",
        ring2 = "Beithir Ring",
        back = gear.wsd_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}}
    }

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

    -- Idle sets
    sets.idle = {
        ammo = "Staunch Tathlum +1",
        head = "Boii Mask +3",
        neck = "Null Loop",
        ear1 = {name = "Alabaster Earring", augments = {"Path: A"}},
        ear2 = "Odnowa Earring",
        body = "Boii Lorica +3",
        hands = {name = "Sakpata's Gauntlets", augments = {"Path: A"}},
        ring1 = {name = "Murky Ring", augments = {"Path: A"}},
        ring2 = "Defending Ring",
        back = gear.wsd_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet = "Boii Calligae +3"
    }

    sets.idle.PDT = set_combine(sets.idle, {
        ammo = "Staunch Tathlum +1",
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = {name = "Alabaster Earring", augments = {"Path: A"}},
        ring2 = "Defending Ring"
    })

    sets.idle.Weak = set_combine(sets.idle, {head = "Twilight Helm", body = "Twilight Mail"})
    sets.idle.Reraise = set_combine(sets.idle, {head = "Twilight Helm", body = "Twilight Mail"})
	
    -- Packing set for Porter Moogle
    sets.packing = {
        main  = "Bravura",
        sub   = "Utu Grip",
        ammo  = "Staunch Tathlum +1",
        head  = "Null Masque",
        neck  = "Null Loop",
        ear1  = "Cryptic Earring",
        ear2  = "Odnowa Earring",
        body  = {name = "Sakpata's Plate", augments = {"Path: A"}},
        hands = {name = "Sakpata's Gauntlets", augments = {"Path: A"}},
        ring1 = {name = "Murky Ring", augments = {"Path: A"}},
        ring2 = "Defending Ring",
        back  = gear.wsd_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs  = {name = "Nyame Flanchard", augments = {"Path: B"}},
        feet  = "Nyame Sollerets"
    }

    -- Defense sets
    sets.defense.PDT = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = {name = "Alabaster Earring", augments = {"Path: A"}},
        ear2 = "Odnowa Earring",
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        hands = {name = "Sakpata's Gauntlets", augments = {"Path: A"}},
        ring1 = "Defending Ring",
        ring2 = {name = "Murky Ring", augments = {"Path: A"}},
        back = gear.da_jse_back, -- Cichol's Mantle: Damage taken-5%
        waist = "Flume Belt +1",
        legs = {name = "Sakpata's Cuisses", augments = {"Path: A"}},
        feet = {name = "Sakpata's Leggings", augments = {"Path: A"}}
    }

    sets.defense.PDTReraise = set_combine(sets.defense.PDT, {head = "Twilight Helm", body = "Twilight Mail"})

    sets.defense.MDT = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = {name = "Alabaster Earring", augments = {"Path: A"}},
        ear2 = "Odnowa Earring",
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        hands = {name = "Sakpata's Gauntlets", augments = {"Path: A"}},
        ring1 = "Defending Ring",
        ring2 = {name = "Murky Ring", augments = {"Path: A"}},
        back = "Moonlight Cape",
        waist = "Carrier's Sash",
        legs = {name = "Sakpata's Cuisses", augments = {"Path: A"}},
        feet = {name = "Sakpata's Leggings", augments = {"Path: A"}}
    }

    sets.defense.MDTReraise = set_combine(sets.defense.MDT, {head = "Twilight Helm", body = "Twilight Mail"})
    sets.defense.MEVA = sets.defense.MDT

    sets.Kiting = {ring2 = "Shneddick Ring +1"}
    sets.Reraise = {head = "Twilight Helm", body = "Twilight Mail"}
    sets.buff.Doom = {}
    sets.buff.Sleep = {neck = "Vim Torque +1"}

    -- Emergency survival set: auto-equips when HP drops to or below 50% while engaged.
    -- Prioritizes damage taken reduction and HP. Releases automatically when HP recovers above 50%.
    sets.CR = {
        ammo = "Staunch Tathlum +1",
        head = {name = "Nyame Helm", augments = {"Path: B"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = {name = "Alabaster Earring", augments = {"Path: A"}},
        ear2 = "Odnowa Earring",
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        hands = {name = "Sakpata's Gauntlets", augments = {"Path: A"}},
        ring1 = "Defending Ring",
        ring2 = {name = "Murky Ring", augments = {"Path: A"}},
        back = gear.da_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Sakpata's Cuisses", augments = {"Path: A"}},
        feet = {name = "Sakpata's Leggings", augments = {"Path: A"}}
    }

    -- Engaged sets

    -- Single Wield (Naegling/Sword builds)
    sets.engaged = {
        ammo = {name = "Coiste Bodhar", augments = {"Path: A"}},
        head = {name = "Flam. Zucchetto +2"},
        neck = {name = "War. Beads +2", augments = {"Path: A"}},
        ear1 = "Schere Earring",
        ear2 = {name = "Boii Earring +2", augments = {'System: 1 ID: 1676 Val: 0','Accuracy+17','Mag. Acc.+17','Crit.hit rate+6','STR+9 VIT+9'}},
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        hands = {name = "Sakpata's Gauntlets", augments = {"Path: A"}},
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.da_jse_back,
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = "Boii Cuisses +3",
        feet = {name = "Flam. Gambieras +2"}
    }

    sets.engaged.SomeAcc = set_combine(sets.engaged, {
        neck = "Asperity Necklace",  -- Note: Combatant's Torque (Combat Skills+15, STP+1) craftable via Synergy if ingredients gathered
        ear1 = "Cessance Earring",
        ring1 = "Chirich Ring +1",
        back = "Null Shawl",
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

    -- Two-Handed weapon sets (Chango/Great Axe)
    sets.engaged.TwoHanded = {
        ammo = {name = "Coiste Bodhar", augments = {"Path: A"}},
        head = {name = "Flam. Zucchetto +2"},
        neck = "Vim Torque +1",
        ear1 = "Schere Earring",
        ear2 = {name = "Boii Earring +2", augments = {'System: 1 ID: 1676 Val: 0','Accuracy+17','Mag. Acc.+17','Crit.hit rate+6','STR+9 VIT+9'}},
        body = "Hjarrandi Breast.",
        hands = {name = "Sakpata's Gauntlets", augments = {"Path: A"}},
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = "Pumm. Cuisses +3",
        feet = "Pumm. Calligae +3"
    }

    -- Hybrid sets for defensive TP
    sets.engaged.PDT = set_combine(sets.engaged, {
        ammo = "Staunch Tathlum +1",
        head = {name = "Sakpata's Helm", augments = {"Path: A"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = {name = "Alabaster Earring", augments = {"Path: A"}},
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        ring1 = "Defending Ring",
        ring2 = {name = "Murky Ring", augments = {"Path: A"}},
        legs = {name = "Sakpata's Cuisses", augments = {"Path: A"}},
        back = gear.da_jse_back -- Cichol's Mantle: Damage taken-5%
    })

    sets.engaged.SomeAcc.PDT = set_combine(sets.engaged.PDT, sets.engaged.SomeAcc, {back = gear.da_jse_back})
    sets.engaged.Acc.PDT = set_combine(sets.engaged.PDT, sets.engaged.Acc, {back = gear.da_jse_back})
    sets.engaged.FullAcc.PDT = set_combine(sets.engaged.PDT, sets.engaged.FullAcc, {back = gear.da_jse_back})

    sets.engaged.MDT = set_combine(sets.engaged, {
        ammo = "Staunch Tathlum +1",
        head = {name = "Sakpata's Helm", augments = {"Path: A"}},
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}},
        ear1 = {name = "Alabaster Earring", augments = {"Path: A"}},
        body = {name = "Sakpata's Plate", augments = {"Path: A"}},
        ring1 = "Defending Ring",
        ring2 = {name = "Murky Ring", augments = {"Path: A"}},
        legs = {name = "Sakpata's Cuisses", augments = {"Path: A"}},
        back = "Moonlight Cape"
    })

    sets.engaged.SomeAcc.MDT = set_combine(sets.engaged.MDT, sets.engaged.SomeAcc)
    sets.engaged.Acc.MDT = set_combine(sets.engaged.MDT, sets.engaged.Acc)
    sets.engaged.FullAcc.MDT = set_combine(sets.engaged.MDT, sets.engaged.FullAcc)

    -- Weapon sets
    sets.weapons.Chango = {main = "Chango", sub = "Utu Grip"}
    sets.weapons.Naegling = {main = "Naegling", sub = "Blurred Shield +1"}
	sets.weapons.Shining = {main = "Shining One", sub = "Utu Grip"}
    sets.weapons.NaeglingDual = {main = "Naegling", sub = {name = "Ternion Dagger +1", augments = {'Path: A'}}}
    sets.weapons.Loxotic = {main = "Loxotic Mace +1", sub = "Blurred Shield +1"}
    sets.weapons.DualWeapons = {main = "Naegling", sub = {name = "Ternion Dagger +1", augments = {'Path: A'}}}
    sets.weapons.Greatsword = {main = "Mes'Yohi Sword", sub = "Utu Grip"}
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
    sets.Capacity = {back = {name = "Mecisto. Mantle", augments = {'Cap. Point+49%','MP+17','DEF+9'}}}

    -- Custom melee group sets
    sets.engaged.Adoulin = {body = "Councilor's Garb"}
    sets.engaged.AM = {} -- Aftermath
    sets.engaged.Charge = {} -- Brazen Rush / Warrior's Charge
    sets.engaged.Mighty = {} -- Mighty Strikes
end

-- Handle weapon-specific engaged sets through the library's customize hook
-- This works WITH the library instead of bypassing it, so all modes (PDT, Acc, etc.) still apply
-- Two-handed weapons: Great Axes, Great Swords, Polearms
local two_handed_weapons = S{
    -- Great Axes
    "Chango", "Ukonvasara", "Bravura", "Conqueror", "Laphria",
    -- Great Swords
    "Mes'Yohi Sword", "Helheim",
    -- Polearms (Shining One etc.)
    "Shining One",
}

function user_job_customize_melee_set(meleeSet)
    if two_handed_weapons[player.equipment.main] then
        meleeSet = set_combine(meleeSet, sets.engaged.TwoHanded)
    end
    return meleeSet
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

-- HP lock check: returns true when HP <= 50% while engaged, sticky until recovery above 50%
function check_hp_lock()
    if player.status == 'Engaged' and player.hpp <= 50 then
        if not hp_lock_active then
            hp_lock_active = true
            windower.add_to_chat(167, "WARNING: HP critical - emergency gear active")
        end
        return true
    end
    if hp_lock_active and player.hpp > 50 then
        hp_lock_active = false
        windower.add_to_chat(160, "HP recovered - returning to normal gear")
    end
    return false
end

-- Handles equipping the correct melee set, respecting hp lock and doom
function handle_melee_gear()
    if check_hp_lock() then
        local meleeSet = sets.CR
        if buffactive['doom'] then
            meleeSet = set_combine(meleeSet, sets.buff.Doom)
        end
        equip(meleeSet)
    end
    -- If not hp locked, let the normal framework handle gear as usual
end

-- Intercept gear equipping while engaged to enforce hp lock
function job_handle_equipping_gear(playerStatus, eventArgs)
    if playerStatus == 'Engaged' and check_hp_lock() then
        local crSet = sets.CR
        if buffactive['doom'] then
            crSet = set_combine(crSet, sets.buff.Doom)
        end
        equip(crSet)
        eventArgs.handled = true
    end
end

-- Poll HP once per second while engaged and trigger gear swap when threshold is crossed
windower.register_event('prerender', function()
    local now = os.time()
    if now ~= hp_check_timer then
        hp_check_timer = now
        local current_hp = player.hpp or 100
        if current_hp ~= last_hp then
            last_hp = current_hp
            if player.status == 'Engaged' then
                handle_melee_gear()
            end
        end
    end
end)

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    set_macro_page(1, 1)
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