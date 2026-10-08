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
    state.OffenseMode:options("Normal", "SomeAcc", "Acc", "FullAcc", "Fodder", "Crit")
    state.HybridMode:options("Normal", "DT")
    state.RangedMode:options("Normal", "Acc")
    state.WeaponskillMode:options("Match", "Normal", "SomeAcc", "Acc", "FullAcc", "Fodder", "Proc")
    state.CastingMode:options("Normal", "Proc", "Resistant")
    state.IdleMode:options("Normal", "Sphere")
    state.PhysicalDefenseMode:options("PDT")
    state.MagicalDefenseMode:options("MDT")
    state.ResistDefenseMode:options("MEVA")
    state.Weapons:options(
        "Heishi",
        "Savage",
        "MagicWeapons",
        "ProcDagger",
        "ProcSword",
        "ProcGreatSword",
        "ProcScythe",
        "ProcPolearm",
        "ProcGreatKatana",
        "ProcKatana",
        "ProcClub",
        "ProcStaff"
    )
    state.ExtraMeleeMode = M {["description"] = "Extra Melee Mode", "None", "SuppaBrutal", "DWEarrings", "DWMax"}

    -- LINKTRI MODIFICATION 2026-06-11: Andartia's Mantle not owned (it is the NIN-only JSE Ambuscade cape,
    -- so Senuna's Mantle (DNC-only) and Lugh's Cape (SCH-only) cannot substitute - neither is NIN-equippable).
    -- Using Null Shawl (All Jobs: Acc+50 R.Acc+50 M.Acc+50 Eva+50 M.Eva+50 DA+7% StoreTP+7) as the
    -- general-purpose substitute until Andartia's Mantle is acquired.
    -- To revert: swap names/augments back to Andartia's Mantle as originally defined.
    gear.wsd_jse_back = "Null Shawl"
    gear.da_jse_back = "Null Shawl"

    send_command('bind ^` input /ja "Innin" <me>')
    send_command('bind !` input /ja "Yonin" <me>')
    send_command("bind @` gs c cycle SkillchainMode")
    send_command("bind !r gs c set WeaponskillMode Proc;;gs c set CastingMode Proc;gs c update")
    send_command("bind ^r gs c weapons Default;gs c set WeaponskillMode Normal;gs c set CastingMode Normal;gs c update")

    utsusemi_cancel_delay = .3
    utsusemi_ni_cancel_delay = .06

    select_default_macro_book()
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Precast sets
    --------------------------------------

    sets.Enmity = {
        ammo = "Paeapua",
        head = "Dampening Tam",
        neck = "Unmoving Collar",
        ear1 = "Crematio Earring",
        ear2 = "Enervating Earring",
        body = "Ashera Harness",
        hands = "Malignance Gloves",
        ring1 = "Petrov Ring",
        ring2 = "Vengeful Ring",
        back = "Null Shawl",
        waist = "Chaac Belt",
        legs = "Nyame Flanchard",
        feet = "Malignance Boots"
    }

    -- Precast sets to enhance JAs
    -- LINKTRI MODIFICATION 2026-06-27: Full Mochizuki +3 and Hachiya +1 sets confirmed owned.
    -- Mijin Gakure: Mochi. Hakama +3 20x bonus enhances Mijin Gakure effect.
    sets.precast.JA["Mijin Gakure"] = {legs = "Mochi. Hakama +3"} --main="Nagi" if obtained
    sets.precast.JA["Futae"] = {hands = "Hattori Tekko +3"}
    -- LINKTRI MODIFICATION 2026-06-27: Mochi. Chainmail +3 20x bonus enhances Sange effect.
    sets.precast.JA["Sange"] = {body = "Mochi. Chainmail +3"}
    sets.precast.JA["Provoke"] = sets.Enmity
    sets.precast.JA["Warcry"] = sets.Enmity

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {
        ammo = "Yamarang",
        head = "Mummu Bonnet +2",
        neck = "Unmoving Collar",
        ear1 = "Enchntr. Earring +1",
        ear2 = "Mache Earring +1",
        body = gear.herculean_waltz_body,
        hands = gear.herculean_waltz_hands,
        ring1 = "Defending Ring",
        ring2 = "Ephramad's Ring",
        back = "Null Shawl",
        waist = "Chaac Belt",
        legs = "Dashing Subligar",
        feet = gear.herculean_waltz_feet
    }

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz["Healing Waltz"] = {}

    -- Set for acc on steps, since Yonin drops acc a fair bit
    sets.precast.Step = {
        ammo = "Yamarang",
        head = "Dampening Tam",
        neck = "Combatant's Torque",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = "Mummu Jacket +2",
        hands = "Adhemar Wrist. +1",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Mummu Kecks +2",
        feet = "Malignance Boots"
    }

    sets.precast.Flourish1 = {
        ammo = "Yamarang",
        head = "Dampening Tam",
        neck = "Combatant's Torque",
        ear1 = "Gwati Earring",
        ear2 = "Digni. Earring",
        body = "Ashera Harness",
        hands = "Adhemar Wrist. +1",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Hattori Hakama +3",
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
        hands = "Chironic Gloves",
        ring1 = "Lebeche Ring",
        ring2 = "Kishar Ring",
        legs = "Rawhide Trousers",
        feet = "Hachi. Kyahan +1"
    }

    sets.precast.FC.Utsusemi =
        set_combine(sets.precast.FC, {neck = "Magoraga Beads", body = "Dread Jupon", feet = "Hattori Kyahan +3"})
    sets.precast.FC.Shadows =
        set_combine(sets.precast.FC.Utsusemi, {ammo = "Staunch Tathlum +1", ring1 = "Kishar Ring"})

    -- Snapshot for ranged
    sets.precast.RA = {}
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        ammo = "Voluspa Tathlum",
        head={ name="Nyame Helm", augments={'Path: B',}},
        neck = "Combatant's Torque",
        ear1 = "Sherida Earring",
        ear2 = "Brutal Earring",
        body={ name="Nyame Mail", augments={'Path: B',}},
        hands={ name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = "Ilabrat Ring",
        ring2 = "Apate Ring",
        back = gear.da_jse_back,
        waist = { name="Sailfi Belt +1", augments={'Path: A',}},
        legs={ name="Nyame Flanchard", augments={'Path: B',}},
        feet = "Hattori Kyahan +3",
    }
    sets.precast.WS.SomeAcc =
        set_combine(
        sets.precast.WS,
        {head = "Dampening Tam", body = { name="Mpaca's Doublet", augments={'Path: A',}}, legs = "Hiza. Hizayoroi +2", ear2 = "Telos Earring"}
    )
    sets.precast.WS.Acc =
        set_combine(
        sets.precast.WS,
        {
            ammo = "Voluspa Tathlum",
            head = "Ynglinga Sallet",
            neck = "Combatant's Torque",
            ear2 = "Telos Earring",
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            hands = "Mummu Wrists +2",
            waist = "Chaac Belt",
            legs = "Hiza. Hizayoroi +2",
            feet = "Malignance Boots"
        }
    )
    sets.precast.WS.FullAcc =
        set_combine(
        sets.precast.WS,
        {
            ammo = "Voluspa Tathlum",
            head = "Ynglinga Sallet",
            neck = "Combatant's Torque",
            ear1 = "Mache Earring +1",
            ear2 = "Telos Earring",
            body = "Mummu Jacket +2",
            ring1 = "Chirich Ring +1",
            ring2 = "Chirich Ring +1",
            waist = "Chaac Belt",
            legs = "Hiza. Hizayoroi +2",
            feet = "Malignance Boots"
        }
    )
    sets.precast.WS.Proc = {
        ammo = "Yamarang",
        head = "Ynglinga Sallet",
        neck = "Combatant's Torque",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = "Mummu Jacket +2",
        hands = "Mummu Wrists +2",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Mummu Kecks +2",
        feet = "Malignance Boots"
    }

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS["Blade: Jin"] =
        set_combine(
        sets.precast.WS,
        {
            ammo = "Voluspa Tathlum",
            head = "Mummu Bonnet +2",
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            hands = "Hachiya Tekko +1",
            ring1 = "Ilabrat Ring",
            waist = "Chaac Belt",
            legs = "Mummu Kecks +2",
            feet = "Mummu Gamash. +2"
        }
    )
    sets.precast.WS["Blade: Jin"].SomeAcc =
        set_combine(
        sets.precast.WS.SomeAcc,
        {
            ammo = "Voluspa Tathlum",
            head = "Mummu Bonnet +2",
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            hands = "Hachiya Tekko +1",
            waist = "Chaac Belt",
            legs = "Mummu Kecks +2",
            feet = "Mummu Gamash. +2"
        }
    )
    sets.precast.WS["Blade: Jin"].Acc =
        set_combine(
        sets.precast.WS.Acc,
        {
            head = "Mummu Bonnet +2",
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            hands = "Hachiya Tekko +1",
            legs = "Mummu Kecks +2",
            feet = "Mummu Gamash. +2"
        }
    )
    sets.precast.WS["Blade: Jin"].FullAcc =
        set_combine(
        sets.precast.WS.FullAcc,
        {body = "Mummu Jacket +2", hands = "Hachiya Tekko +1", legs = "Mummu Kecks +2", feet = "Mummu Gamash. +2"}
    )
    sets.precast.WS["Blade: Jin"].Fodder = set_combine(sets.precast.WS["Blade: Jin"], {head = "Mummu Bonnet +2"})

    sets.precast.WS["Blade: Hi"] =
        set_combine(
        sets.precast.WS,
        {
            ammo = "Voluspa Tathlum",
            head = "Mummu Bonnet +2",
            ear1 = "Moonshade Earring",
            ear2 = "Brutal Earring",
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            hands = "Hachiya Tekko +1",
            ring1 = "Ilabrat Ring",
            back = gear.wsd_jse_back,
            legs = "Hiza. Hizayoroi +2",
            feet = "Mummu Gamash. +2"
        }
    )
    sets.precast.WS["Blade: Hi"].SomeAcc =
        set_combine(
        sets.precast.WS.SomeAcc,
        {
            ammo = "Voluspa Tathlum",
            head = "Mummu Bonnet +2",
            ear1 = "Moonshade Earring",
            ear2 = "Enervating Earring",
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            hands = "Hachiya Tekko +1",
            ring1 = "Ilabrat Ring",
            back = gear.wsd_jse_back,
            legs = "Hiza. Hizayoroi +2",
            feet = "Mummu Gamash. +2"
        }
    )
    sets.precast.WS["Blade: Hi"].Acc =
        set_combine(
        sets.precast.WS.Acc,
        {
            head = "Mummu Bonnet +2",
            ear1 = "Moonshade Earring",
            ear2 = "Telos Earring",
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            hands = "Hachiya Tekko +1",
            legs = "Hiza. Hizayoroi +2",
            feet = "Mummu Gamash. +2"
        }
    )
    sets.precast.WS["Blade: Hi"].FullAcc =
        set_combine(sets.precast.WS.FullAcc, {hands = "Hachiya Tekko +1", legs = "Hiza. Hizayoroi +2"})
    sets.precast.WS["Blade: Hi"].Fodder = set_combine(sets.precast.WS["Blade: Hi"], {})

    sets.precast.WS["Blade: Shun"] =
        set_combine(
        sets.precast.WS,
        {
            ammo = "Voluspa Tathlum",
            head = { name="Mpaca's Cap", augments={'Path: A',}},
            ear1 = "Lugra Earring",
            ear2 = "Lugra Earring",
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            legs = "Hiza. Hizayoroi +2",
            feet = { name="Mpaca's Boots", augments={'Path: A',}},
        }
    )
    sets.precast.WS["Blade: Shun"].SomeAcc =
        set_combine(
        sets.precast.WS.SomeAcc,
        {
            ammo = "Voluspa Tathlum",
            head = { name="Mpaca's Cap", augments={'Path: A',}},
            ear1 = "Lugra Earring",
            ear2 = "Lugra Earring",
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            legs = "Hiza. Hizayoroi +2",
            feet = "Malignance Boots"
        }
    )
    sets.precast.WS["Blade: Shun"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Blade: Shun"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Blade: Shun"].Fodder = set_combine(sets.precast.WS["Blade: Shun"], {
        head = { name="Mpaca's Cap", augments={'Path: A',}},
        body = { name="Mpaca's Doublet", augments={'Path: A',}},
    })

    sets.precast.WS["Blade: Ten"] =
        set_combine(
        sets.precast.WS,
        {
            ammo = "Voluspa Tathlum",
            neck = "Combatant's Torque",
            ear1 = "Moonshade Earring",
            ear2 = "Lugra Earring",
            body = gear.herculean_wsd_body,
            back = gear.wsd_jse_back,
            waist = "Chaac Belt",
            legs = "Hiza. Hizayoroi +2",
            feet = gear.herculean_wsd_feet
        }
    )
    sets.precast.WS["Blade: Ten"].SomeAcc =
        set_combine(
        sets.precast.WS.SomeAcc,
        {
            ammo = "Voluspa Tathlum",
            neck = "Combatant's Torque",
            ear1 = "Moonshade Earring",
            body = gear.herculean_wsd_body,
            back = gear.wsd_jse_back,
            waist = "Chaac Belt",
            legs = "Hiza. Hizayoroi +2",
            feet = gear.herculean_wsd_feet
        }
    )
    sets.precast.WS["Blade: Ten"].Acc = set_combine(sets.precast.WS.Acc, {back = gear.wsd_jse_back})
    sets.precast.WS["Blade: Ten"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Blade: Ten"].Fodder = set_combine(sets.precast.WS["Blade: Ten"], {})

    sets.precast.WS["Aeolian Edge"] = {
        ammo = "Voluspa Tathlum",
        head = "Dampening Tam",
        neck = "Baetyl Pendant",
        ear1 = "Etiolation Earring",
        ear2 = "Crematio Earring",
        body = { name="Mpaca's Doublet", augments={'Path: A',}},
        hands = "Adhemar Wrist. +1",
        ring1 = "Apate Ring",
        ring2 = "Metamor. Ring +1",
        back = "Null Shawl",
        waist = "Chaac Belt",
        legs = "Nyame Flanchard",
        feet = "Malignance Boots"
    }
    sets.precast.WS["Savage Blade"] = {
        ammo = "Coiste Bodhar",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Null Loop",
        ear1 = { name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},
        ear2 = "Ishvara Earring",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = "Ilabrat Ring",
        ring2 = "Apate Ring",
        back = gear.wsd_jse_back, -- Null Shawl substitute; swap to Andartia's Mantle once obtained
        waist = { name="Sailfi Belt +1", augments={'Path: A',}},
        legs = { name="Nyame Flanchard", augments={'Path: B',}},
        feet = { name="Nyame Sollerets", augments={'Path: B',}},
    }
    sets.precast.WS["Savage Blade"].SomeAcc = set_combine(sets.precast.WS["Savage Blade"], {
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
    })
    sets.precast.WS["Savage Blade"].Acc = set_combine(sets.precast.WS["Savage Blade"], {
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
    })

    -- Swap to these on Moonshade using WS if at 3000 TP
    sets.MaxTP = {ear1 = "Lugra Earring", ear2 = "Lugra Earring"}
    sets.AccMaxTP = {ear1 = "Mache Earring +1", ear2 = "Telos Earring"}
    sets.AccDayMaxTPWSEars = {ear1 = "Mache Earring +1", ear2 = "Telos Earring"}
    sets.DayMaxTPWSEars = {ear1 = "Sherida Earring", ear2 = "Brutal Earring"}
    sets.AccDayWSEars = {ear1 = "Mache Earring +1", ear2 = "Telos Earring"}
    sets.DayWSEars = {ear1 = "Moonshade Earring", ear2 = "Brutal Earring"}

    --------------------------------------
    -- Midcast sets
    --------------------------------------

    sets.midcast.FastRecast = {
        head = gear.herculean_fc_head,
        neck = "Voltsurge Torque",
        ear1 = "Enchntr. Earring +1",
        ear2 = "Loquac. Earring",
        body = "Dread Jupon",
        hands = "Chironic Gloves",
        ring1 = "Defending Ring",
        ring2 = "Kishar Ring",
        legs = "Rawhide Trousers",
        feet = "Malignance Boots"
    }

    -- LINKTRI MODIFICATION 2026-06-27: Added Mochi. Hatsuburi +3 (NIN dmg+21) and Mochi. Kyahan +3
    -- (20x: increases Ninj. MAcc/MAB) to ElementalNinjutsu set. Hattori Tekko +3 retained for Futae+28.
    sets.midcast.ElementalNinjutsu = {
        ammo = "Pemphredo Tathlum",
        head = "Mochi. Hatsuburi +3",
        neck = "Baetyl Pendant",
        ear1 = "Crematio Earring",
        ear2 = "Etiolation Earring",
        body = "Samnuha Coat",
        hands = "Hattori Tekko +3",
        ring1 = "Apate Ring",
        ring2 = "Metamor. Ring +1",
        back = "Null Shawl",
        waist = "Eschan Stone",
        legs = "Gyve Trousers",
        feet = "Mochi. Kyahan +3"
    }

    sets.midcast.ElementalNinjutsu.Proc = sets.midcast.FastRecast

    sets.midcast.ElementalNinjutsu.Resistant = set_combine(sets.midcast.ElementalNinjutsu, {})

    -- Mujin Band/Locus Ring not owned; Apate Ring (MAB) used as MagicBurst ring substitute
    sets.MagicBurst = {ring1 = "Apate Ring", ring2 = "Metamor. Ring +1"}

    -- LINKTRI MODIFICATION 2026-06-27: Mochi. Kyahan +3 (Ninj. skill+23) replaces Hachi. Kyahan +1
    -- (no MAcc) in NinjutsuDebuff feet; Hachi. Kyahan +1 demoted to FC set only (movement speed).
    sets.midcast.NinjutsuDebuff = {
        ammo = "Voluspa Tathlum",
        head = "Dampening Tam",
        neck = "Combatant's Torque",
        ear1 = "Gwati Earring",
        ear2 = "Digni. Earring",
        body = "Ashera Harness",
        hands = "Hachiya Tekko +1",
        ring1 = "Stikini Ring",
        ring2 = "Metamor. Ring +1",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Rawhide Trousers",
        feet = "Mochi. Kyahan +3"
    }

    -- LINKTRI MODIFICATION 2026-06-27: Mochizuki Tekko +3 (NTE+38, 20x enhanced) in NinjutsuBuff hands.
    -- Mochi. Chainmail +3 (Utsusemi cast time -14%) added to Utsusemi feet override.
    sets.midcast.NinjutsuBuff = set_combine(sets.midcast.FastRecast, {
        back = gear.da_jse_back,
        hands = { name="Mochizuki Tekko +3", augments={'Enh. "Ninja Tool Expertise" effect',}}
    })

    sets.midcast.Utsusemi =
        set_combine(sets.midcast.NinjutsuBuff, {back = gear.da_jse_back, body = "Mochi. Chainmail +3", feet = "Hattori Kyahan +3"})

    sets.midcast.RA = {
        head = "Malignance Chapeau",
        neck = "Combatant's Torque",
        ear1 = "Enervating Earring",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Apate Ring",
        ring2 = "Ilabrat Ring",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.midcast.RA.Acc = {
        head = "Malignance Chapeau",
        neck = "Combatant's Torque",
        ear1 = "Enervating Earring",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Apate Ring",
        ring2 = "Ilabrat Ring",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    --------------------------------------
    -- Idle/resting/defense/etc sets
    --------------------------------------

    -- Resting sets
    sets.resting = {}

    -- Idle sets
    sets.idle = {
        ammo = "Staunch Tathlum +1",
        head = "Hattori Zukin +3",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Hattori Ningi +3",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Hattori Hakama +3",
        feet = "Hattori Kyahan",
    }

    sets.idle.Sphere = set_combine(sets.idle, {body = "Samnuha Coat"})

    sets.defense.PDT = {
        ammo = "Yamarang",
        head = "Dampening Tam",
        neck = "Loricate Torque +1",
        ear1 = "Genmei Earring",
        ear2 = "Sanare Earring",
        body = "Ashera Harness",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",
        back = "Null Shawl",
        waist = "Chaac Belt",
        legs = "Nyame Flanchard",
        feet = "Malignance Boots"
    }

    sets.defense.MDT = {
        ammo = "Yamarang",
        head = "Dampening Tam",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Ashera Harness",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Ice Ring",
        back = "Null Shawl",
        waist = "Chaac Belt",
        legs = "Nyame Flanchard",
        feet = "Malignance Boots"
    }

    sets.defense.MEVA = {
        ammo = "Yamarang",
        head = "Dampening Tam",
        neck = "Sacro Gorget",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Samnuha Coat",
        hands = "Chironic Gloves",
        ring1 = "Vengeful Ring",
        ring2 = "Ice Ring",
        back = "Null Shawl",
        waist = "Chaac Belt",
        legs = "Samnuha Tights",
        feet = "Malignance Boots"
    }

    sets.Kiting = {feet = "Hachi. Kyahan +1"}
    sets.DuskKiting = {}
    sets.DuskIdle = {}
    sets.DayIdle = {}
    sets.NightIdle = {}

    --------------------------------------
    -- Engaged sets
    --------------------------------------

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    -- Normal melee group
    sets.engaged = {
        ammo={ name="Coiste Bodhar", augments={'Path: A',}},
        head = "Dampening Tam",
        neck = "Null Loop",
        ear1 = "Odr Earring",
        ear2 ={ name="Hattori Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','"Store TP"+5',}},
        body={ name="Mpaca's Doublet", augments={'Path: A',}},
        hands = "Adhemar Wrist. +1",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Samnuha Tights",
        feet = gear.herculean_ta_feet
    }

    sets.engaged.SomeAcc = {
        ammo = "Yamarang",
        head = "Dampening Tam",
        neck = "Combatant's Torque",
        ear1 = "Sherida Earring",
        ear2 = "Brutal Earring",
        body = { name="Mpaca's Doublet", augments={'Path: A',}},
        hands = "Adhemar Wrist. +1",
        ring1 = "Ilabrat Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = "Regal Belt",
        legs = "Samnuha Tights",
        feet = gear.herculean_ta_feet
    }

    sets.engaged.Acc = {
        ammo = "Yamarang",
        head = "Dampening Tam",
        neck = "Combatant's Torque",
        ear1 = "Digni. Earring",
        ear2 = "Telos Earring",
        body = { name="Mpaca's Doublet", augments={'Path: A',}},
        hands = "Adhemar Wrist. +1",
        ring1 = "Ilabrat Ring",
        ring2 = "Apate Ring",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Mummu Kecks +2",
        feet = "Malignance Boots"
    }

    sets.engaged.FullAcc = {
        ammo = "Yamarang",
        head = "Malignance Chapeau",
        neck = "Combatant's Torque",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.Fodder = {
        ammo = "Yamarang",
        head = "Dampening Tam",
        neck = "Combatant's Torque",
        ear1 = "Dedition Earring",
        ear2 = "Brutal Earring",
        body = { name="Mpaca's Doublet", augments={'Path: A',}},
        hands = "Adhemar Wrist. +1",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = "Regal Belt",
        legs = "Samnuha Tights",
        feet = gear.herculean_ta_feet
    }

    sets.engaged.Crit = {
        ammo = "Yamarang",
        head = "Mummu Bonnet +2",
        neck = "Combatant's Torque",
        ear1 = "Sherida Earring",
        ear2 = "Brutal Earring",
        body = "Mummu Jacket +2",
        hands = "Mummu Wrists +2",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = "Regal Belt",
        legs = "Mummu Kecks +2",
        feet = "Mummu Gamash. +2"
    }

    sets.engaged.DT = {
        ammo = "Yamarang",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Sherida Earring",
        ear2 = "Alabaster Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = "Regal Belt",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.SomeAcc.DT = {
        ammo = "Yamarang",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Telos Earring",
        ear2 = "Alabaster Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = "Regal Belt",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.Acc.DT = {
        ammo = "Yamarang",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = "Regal Belt",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.FullAcc.DT = {
        ammo = "Yamarang",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Mache Earring +1",
        ear2 = "Odr Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Chirich Ring +1",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.Fodder.DT = {
        ammo = "Yamarang",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Sherida Earring",
        ear2 = "Alabaster Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = "Regal Belt",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    --------------------------------------
    -- Custom buff sets
    --------------------------------------

    sets.buff.Migawari = {body="Hattori Ningi +3"} --body="Hattori Ningi +3"
    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Futae = {}
    sets.buff.Yonin = {legs = "Hattori Hakama +3"} --
    sets.buff.Innin = {head="Hattori Zukin +3"} --head="Hattori Zukin +3"

    -- Extra Melee sets.  Apply these on top of melee sets.
    sets.Knockback = {}
    sets.SuppaBrutal = {ear1 = "Suppanomimi", ear2 = "Brutal Earring"}
    sets.DWEarrings = {ear1 = "Dudgeon Earring", ear2 = "Heartseeker Earring"}
    -- LINKTRI MODIFICATION 2026-06-27: Mochi. Chainmail +3 (DW+9) and Mochi. Hakama +3 (DW+10)
    -- replace Mpaca's Doublet in DWMax; Hachiya body (DW+8) is inferior to both Mochi. and Mpaca's.
    sets.DWMax = {
        ear1 = "Dudgeon Earring",
        ear2 = "Heartseeker Earring",
        body = "Mochi. Chainmail +3",
        hands = "Floral Gauntlets",
        legs = "Mochi. Hakama +3",
        waist = "Chaac Belt"
    }
    sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
    sets.Skillchain = {legs = "Hattori Hakama +3"}

    -- Weapons sets
    sets.weapons.Heishi = {main = "Heishi Shorinken", sub = "Yagyu Darkblade"}
    sets.weapons.Savage = {main = "Naegling", sub = "Yagyu Darkblade"}
    sets.weapons.Evisceration = {main = "Tauret", sub = "Kunimitsu"}
    sets.weapons.MagicWeapons = {main = "Kunimitsu", sub = "Tauret"}
    sets.weapons.ProcDagger = {main = "Chicken Knife II", sub = empty}
    sets.weapons.ProcSword = {main = "Ark Sword", sub = empty}
    sets.weapons.ProcGreatSword = {main = "Lament", sub = empty}
    sets.weapons.ProcScythe = {main = "Ark Scythe", sub = empty}
    sets.weapons.ProcPolearm = {main = "Pitchfork +1", sub = empty}
    sets.weapons.ProcGreatKatana = {main = "Hardwood Katana", sub = empty}
    sets.weapons.ProcKatana = {main = "Kanaria", sub = empty}
    sets.weapons.ProcClub = {main = "Dream Bell +1", sub = empty}
    sets.weapons.ProcStaff = {main = "Terra's Staff", sub = empty}

    sets.packing = {
        ammo  = "Staunch Tathlum +1",
        head  = "Nyame Helm",
        neck  = "Loricate Torque +1",
        ear1  = "Etiolation Earring",
        ear2  = "Sanare Earring",
        body  = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A'}},
        back  = "Null Shawl",
        waist = "Fucho-no-Obi",
        legs  = "Nyame Flanchard",
        feet  = "Nyame Sollerets"
    }
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
    if player.sub_job == "WAR" then
        set_macro_page(1, 13)
    elseif player.sub_job == "RNG" then
        set_macro_page(1, 13)
    elseif player.sub_job == "RDM" then
        set_macro_page(1, 13)
    else
        set_macro_page(1, 13)
    end
end