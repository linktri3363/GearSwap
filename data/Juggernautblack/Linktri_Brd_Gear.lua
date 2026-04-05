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
    state.OffenseMode:options("Normal", "Acc")
    state.HybridMode:options("Normal", "DT")
    state.CastingMode:options("Normal", "Resistant", "AoE")
    state.IdleMode:options("Normal", "NoRefresh", "DT")
    state.Weapons:options("None", "Naegling", "Aeneas", "DualWeapons", "DualNaegling", "DualTauret", "DualAeolian")
    -- Whether to use Carn (or song daggers in general) under a certain threshhold even when weapons are locked.
    state.CarnMode = M {"Always", "300", "1000", "Never"}

    gear.melee_jse_back = {name = "Senuna's Mantle", augments = {"DEX+20", "Accuracy+20 Attack+20", "DEX+10", "Weapon skill damage +10%", "Damage taken-5%"}}
    gear.magic_jse_back = {name = "Alaunus's Cape", augments = {"MND+20", "Eva.+20 /Mag. Eva.+20", "MND+10", '"Fast Cast"+10', "Damage taken-5%"}}

    -- Adjust this if using the Terpander (new +song instrument)
    info.ExtraSongInstrument = "Blurred Harp +1"
    -- How many extra songs we can keep from Daurdabla/Terpander
    info.ExtraSongs = 1

    -- Set this to false if you don't want to use custom timers.
    state.UseCustomTimers = M(false, "Use Custom Timers")

    -- Additional local binds
    send_command("bind ^` gs c cycle ExtraSongsMode")
    send_command('bind !` input /ma "Chocobo Mazurka" <me>')
    send_command("bind @` gs c cycle MagicBurstMode")
    send_command("bind @f10 gs c cycle RecoverMode")
    send_command("bind @f8 gs c toggle AutoNukeMode")
    send_command("bind !r gs c weapons None;gs c update")
    send_command("bind !q gs c weapons NukeWeapons;gs c update")
    send_command("bind ^q gs c weapons Swords;gs c update")
    send_command("bind !f7 gs c cycle CarnMode")

    select_default_macro_book()
end

function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Weapons sets
    sets.weapons.Aeneas = {main = "Aeneas", sub = "Genmei Shield"}
    sets.weapons.DualWeapons = {main = "Aeneas", sub = "Twashtar"}
    sets.weapons.DualNaegling = {main = "Naegling", sub = "Centovente"}
    sets.weapons.Naegling = {main = "Naegling", sub = "Genmei Shield"}
    sets.weapons.DualTauret = {main = "Tauret", sub = "Twashtar"}
    sets.weapons.DualAeolian = {main = "Tauret", sub = "Malevolence"}

    sets.buff.Sublimation = {waist = "Embla Sash"}
    sets.buff.DTSublimation = {waist = "Embla Sash"}

    -- Precast Sets

    -- Fast cast sets for spells
    sets.precast.FC = {
        main = "",
        sub = "",
        ammo = "Impatiens",
        head = "Bunzi's Hat",
        neck = "Voltsurge Torque",
        ear1 = "Loquac. Earring",
        ear2 = "Enchntr. Earring +1",
        body = "Inyanga Jubbah +2",
        hands = "Bunzi's Gloves",
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",
        back = gear.magic_jse_back,
        waist = "Witful Belt",
        legs = "Aya. Cosciales +2",
        feet = "Regal Pumps +1"
    }

    sets.precast.FC.DT = {
        main = "",
        sub = "",
        ammo = "Impatiens",
        head = "Bunzi's Hat",
        neck = "Loricate Torque +1",
        ear1 = "Loquac. Earring",
        ear2 = "Etiolation Earring",
        body = "Inyanga Jubbah +2",
        hands = "Bunzi's Gloves",
        ring1 = "Defending Ring",
        ring2 = "Kishar Ring",
        back = gear.magic_jse_back,
        waist = "Witful Belt",
        legs = "Aya. Cosciales +2",
        feet = "Regal Pumps +1"
    }

    sets.precast.FC.Cure = set_combine(sets.precast.FC, {feet = "Medium's Sabots"})

    sets.precast.FC["Enhancing Magic"] = set_combine(sets.precast.FC, {waist = "Siegel Sash"})
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main = "Daybreak", sub = "Genmei Shield"})

    sets.precast.FC.BardSong = {
        main = "",
        sub = "",
        range = "Blurred Harp +1",
        ammo = empty,
        head = "Bunzi's Hat",
        neck = "Voltsurge Torque",
        ear1 = "Loquac. Earring",
        ear2 = "Enchntr. Earring +1",
        body = "Inyanga Jubbah +2",
        hands = "Bunzi's Gloves",
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",
        back = gear.magic_jse_back,
        waist = "Witful Belt",
        legs = "Aya. Cosciales +2",
        feet = "Regal Pumps +1"
    }

    sets.precast.FC.SongDebuff = set_combine(sets.precast.FC.BardSong, {range = "Blurred Harp +1"})
    sets.precast.FC.SongDebuff.Resistant = set_combine(sets.precast.FC.BardSong, {range = "Blurred Harp +1"})
    sets.precast.FC.Lullaby = {range = "Blurred Harp +1"}
    sets.precast.FC.Lullaby.Resistant = {range = "Blurred Harp +1"}
    sets.precast.FC["Horde Lullaby"] = {range = "Blurred Harp +1"}
    sets.precast.FC["Horde Lullaby"].Resistant = {range = "Blurred Harp +1"}
    sets.precast.FC["Horde Lullaby"].AoE = {range = "Blurred Harp +1"}
    sets.precast.FC["Horde Lullaby II"] = {range = "Blurred Harp +1"}
    sets.precast.FC["Horde Lullaby II"].Resistant = {range = "Blurred Harp +1"}
    sets.precast.FC["Horde Lullaby II"].AoE = {range = "Blurred Harp +1"}

    sets.precast.FC.Mazurka = set_combine(sets.precast.FC.BardSong, {range = "Blurred Harp +1"})
    sets.precast.FC["Honor March"] = set_combine(sets.precast.FC.BardSong, {range = "Blurred Harp +1"})

    sets.precast.FC.Daurdabla = set_combine(sets.precast.FC.BardSong, {range = info.ExtraSongInstrument})
    sets.precast.DaurdablaDummy = sets.precast.FC.Daurdabla

    -- Precast sets to enhance JAs

    sets.precast.JA.Nightingale = {feet = "Regal Pumps +1"}
    sets.precast.JA.Troubadour = {body = "Fili Hongreline +1"}
    sets.precast.JA["Soul Voice"] = {legs = "Fili Rhingrave +1"}

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}

    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        ammo = "Coiste Bodhar",
        head = "Aya. Zucchetto +2",
        neck = "Fotia Gorget",
        ear1 = "Moonshade Earring",
        ear2 = "Ishvara Earring",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Epona's Ring",
        ring2 = "Ilabrat Ring",
        back = gear.melee_jse_back,
        waist = "Fotia Belt",
        legs = "Aya. Cosciales +2",
        feet = "Aya. Gambieras +2"
    }

    sets.precast.WS.Acc = {
        ammo = "Coiste Bodhar",
        head = "Aya. Zucchetto +2",
        neck = "Fotia Gorget",
        ear1 = "Moonshade Earring",
        ear2 = "Telos Earring",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Epona's Ring",
        ring2 = "Ilabrat Ring",
        back = gear.melee_jse_back,
        waist = "Fotia Belt",
        legs = "Aya. Cosciales +2",
        feet = "Aya. Gambieras +2"
    }

    sets.precast.WS["Savage Blade"] = {
        ammo = "Coiste Bodhar",
        head = "Aya. Zucchetto +2",
        neck = "Fotia Gorget",
        ear1 = "Moonshade Earring",
        ear2 = "Ishvara Earring",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Epona's Ring",
        ring2 = "Ilabrat Ring",
        back = gear.melee_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Aya. Cosciales +2",
        feet = "Aya. Gambieras +2"
    }

    sets.precast.WS["Aeolian Edge"] = {
        ammo = "Pemphredo Tathlum",
        head = "Bunzi's Hat",
        neck = "Baetyl Pendant",
        ear1 = "Moonshade Earring",
        ear2 = "Crematio Earring",
        body = "Chironic Slippers",
        hands = "Chironic Gloves",
        ring1 = "Metamor. Ring +1",
        ring2 = "Shiva Ring +1",
        back = gear.melee_jse_back,
        waist = "Eschan Stone",
        legs = "Gyve Trousers",
        feet = "Chironic Slippers"
    }

    -- Swap to these on Moonshade using WS if at 3000 TP
    sets.MaxTP = {ear1 = "Ishvara Earring", ear2 = "Telos Earring"}
    sets.AccMaxTP = {ear1 = "Telos Earring", ear2 = "Brutal Earring"}

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.

    -- Midcast Sets

    -- General set for recast times.
    sets.midcast.FastRecast = {
        main = "",
        sub = "",
        ammo = "Impatiens",
        head = "Bunzi's Hat",
        neck = "Voltsurge Torque",
        ear1 = "Loquac. Earring",
        ear2 = "Enchntr. Earring +1",
        body = "Inyanga Jubbah +2",
        hands = "Bunzi's Gloves",
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",
        back = gear.magic_jse_back,
        waist = "Witful Belt",
        legs = "Aya. Cosciales +2",
        feet = "Regal Pumps +1"
    }

    -- Gear to enhance certain classes of songs
    sets.midcast.Ballad = {legs = "Fili Rhingrave +1"}
    sets.midcast.Lullaby = {range = "Blurred Harp +1"}
    sets.midcast.Lullaby.Resistant = {range = "Blurred Harp +1"}
    sets.midcast["Horde Lullaby"] = {range = "Blurred Harp +1"}
    sets.midcast["Horde Lullaby"].Resistant = {range = "Blurred Harp +1"}
    sets.midcast["Horde Lullaby"].AoE = {range = "Blurred Harp +1"}
    sets.midcast["Horde Lullaby II"] = {range = "Blurred Harp +1"}
    sets.midcast["Horde Lullaby II"].Resistant = {range = "Blurred Harp +1"}
    sets.midcast["Horde Lullaby II"].AoE = {range = "Blurred Harp +1"}
    sets.midcast.Madrigal = {head = "Fili Calot +1"}
    sets.midcast.Paeon = {}
    sets.midcast.March = {hands = "Fili Manchettes +1"}
    sets.midcast["Honor March"] = set_combine(sets.midcast.March, {range = "Blurred Harp +1"})
    sets.midcast.Minuet = {body = "Fili Hongreline +1"}
    sets.midcast.Minne = {}
    sets.midcast.Carol = {}
    sets.midcast["Sentinel's Scherzo"] = {feet = "Fili Cothurnes +1"}
    sets.midcast["Magic Finale"] = {range = "Blurred Harp +1"}
    sets.midcast.Mazurka = {range = "Blurred Harp +1"}

    -- For song buffs (duration and AF3 set bonus)
    sets.midcast.SongEffect = {
        main = "Kali",
        sub = "",
        range = "Blurred Harp +1",
        ammo = empty,
        head = "Fili Calot +1",
        neck = "Yarak Torque",
        ear1 = "Loquac. Earring",
        ear2 = "Enchntr. Earring +1",
        body = "Fili Hongreline +1",
        hands = "Inyan. Dastanas +2",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = gear.magic_jse_back,
        waist = "Embla Sash",
        legs = "Inyanga Shalwar +2",
        feet = "Regal Pumps +1"
    }

    sets.midcast.SongEffect.DW = {main = "Kali", sub = "Kali"} --Only weapons in this set. This set is overlayed onto  SongEffect

    -- For song defbuffs (duration primary, accuracy secondary)
    sets.midcast.SongDebuff = {
        main = "Kali",
        sub = "",
        range = "Blurred Harp +1",
        ammo = empty,
        head = "Inyanga Tiara +2",
        neck = "Yarak Torque",
        ear1 = "Digni. Earring",
        ear2 = "Regal Earring",
        body = "Fili Hongreline +1",
        hands = "Inyan. Dastanas +2",
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.magic_jse_back,
        waist = "Acuity Belt +1",
        legs = "Inyanga Shalwar +2",
        feet = "Regal Pumps +1"
    }

    sets.midcast.SongDebuff.DW = {main = "Kali", sub = "Kali"} --Only weapons in this set. This set is overlayed onto  SongDebuff

    -- For song defbuffs (accuracy primary, duration secondary)
    sets.midcast.SongDebuff.Resistant = {
        main = "Daybreak",
        sub = "",
        range = "Blurred Harp +1",
        ammo = empty,
        head = "Inyanga Tiara +2",
        neck = "Yarak Torque",
        ear1 = "Digni. Earring",
        ear2 = "Regal Earring",
        body = "Inyanga Jubbah +2",
        hands = "Inyan. Dastanas +2",
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.magic_jse_back,
        waist = "Acuity Belt +1",
        legs = "Inyanga Shalwar +2",
        feet = "Aya. Gambieras +2"
    }

    -- Song-specific recast reduction
    sets.midcast.SongRecast = {
        main = "",
        sub = "",
        range = "Blurred Harp +1",
        ammo = empty,
        head = "Bunzi's Hat",
        neck = "Voltsurge Torque",
        ear1 = "Loquac. Earring",
        ear2 = "Enchntr. Earring +1",
        body = "Inyanga Jubbah +2",
        hands = "Bunzi's Gloves",
        ring1 = "Kishar Ring",
        ring2 = "Prolix Ring",
        back = gear.magic_jse_back,
        waist = "Witful Belt",
        legs = "Fili Rhingrave +1",
        feet = "Aya. Gambieras +2"
    }

    -- Cast spell with normal gear, except using Daurdabla instead
    sets.midcast.Daurdabla = {range = info.ExtraSongInstrument}

    -- Dummy song with Daurdabla; minimize duration to make it easy to overwrite.
    sets.midcast.DaurdablaDummy = set_combine(sets.midcast.SongRecast, {range = info.ExtraSongInstrument})

    -- Other general spells and classes.
    sets.midcast.Cure = {
        main = "Daybreak",
        sub = "",
        ammo = "Pemphredo Tathlum",
        head = "Kaykaus Mitra +1",
        neck = "Nodens Gorget",
        ear1 = "Mendi. Earring",
        ear2 = "Odnowa Earring",
        body = "Kaykaus Bliaut +1",
        hands = "Kaykaus Cuffs +1",
        ring1 = "Stikini Ring",
        ring2 = "Menelaus's Ring",
        back = "Aurist's Cape +1",
        waist = "Luminary Sash",
        legs = "Kaykaus Tights +1",
        feet = "Kaykaus Boots +1"
    }

    sets.midcast.Curaga = sets.midcast.Cure

    sets.Self_Healing = {
        hands = "Buremte Gloves",
        ring2 = "Kunaji Ring",
        waist = "Gishdubar Sash"
    }
    sets.Cure_Received = {
        hands = "Buremte Gloves",
        ring2 = "Kunaji Ring",
        waist = "Gishdubar Sash"
    }
    sets.Self_Refresh = {back = "Grapevine Cape", waist = "Gishdubar Sash"}

    sets.midcast["Enhancing Magic"] = {
        main = "Daybreak",
        sub = "",
        ammo = "Impatiens",
        head = "Telchine Cap",
        neck = "Voltsurge Torque",
        ear1 = "Andoaa Earring",
        ear2 = "Loquac. Earring",
        body = "Telchine Chas.",
        hands = "Telchine Gloves",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = gear.magic_jse_back,
        waist = "Embla Sash",
        legs = "Telchine Braconi",
        feet = "Telchine Pigaches"
    }

    sets.midcast.Stoneskin =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {neck = "Nodens Gorget", ear2 = "Earthcry Earring", waist = "Siegel Sash"}
    )

    sets.midcast["Elemental Magic"] = {
        main = "Daybreak",
        sub = "",
        ammo = "Pemphredo Tathlum",
        head = "Bunzi's Hat",
        neck = "Sanctity Necklace",
        ear1 = "Crematio Earring",
        ear2 = "Malignance Earring",
        body = "Merlinic Jubbah",
        hands = "Amalric Gages +1",
        ring1 = "Shiva Ring +1",
        ring2 = "Metamor. Ring +1",
        back = "Toro Cape",
        waist = "Sekhmet Corset",
        legs = "Merlinic Shalwar",
        feet = "Merlinic Crackows"
    }

    sets.midcast["Elemental Magic"].Resistant = {
        main = "Daybreak",
        sub = "",
        ammo = "Pemphredo Tathlum",
        head = "Bunzi's Hat",
        neck = "Sanctity Necklace",
        ear1 = "Crematio Earring",
        ear2 = "Malignance Earring",
        body = "Merlinic Jubbah",
        hands = "Amalric Gages +1",
        ring1 = "Stikini Ring +1",
        ring2 = "Metamor. Ring +1",
        back = "Toro Cape",
        waist = "Acuity Belt +1",
        legs = "Merlinic Shalwar",
        feet = "Merlinic Crackows"
    }

    sets.midcast.Cursna =
        set_combine(
        sets.midcast.Cure,
        {
            neck = "Debilis Medallion",
            hands = "Hieros Mittens",
            back = "Oretan. Cape +1",
            ring1 = "Haoma's Ring",
            ring2 = "Menelaus's Ring",
            waist = "Witful Belt"
        }
    )

    sets.midcast.StatusRemoval =
        set_combine(sets.midcast.FastRecast, {main = "", sub = "Genmei Shield"})

    -- Resting sets
    sets.resting = {
        main = "Mpaca's Staff",
        sub = "Umbra Strap",
        ammo = "Staunch Tathlum +1",
        head = "Bunzi's Hat",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Stikini Ring +1",
        back = gear.magic_jse_back,
        waist = "Carrier's Sash",
        legs = "Assid. Pants +1",
        feet = "Nyame Sollerets"
    }

    sets.idle = {
        main = "Mpaca's Staff",
        sub = "Umbra Strap",
        ammo = "Staunch Tathlum +1",
        head = "Bunzi's Hat",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Stikini Ring",
        back = gear.magic_jse_back,
        waist = "Carrier's Sash",
        legs = "Assid. Pants +1",
        feet = "Nyame Sollerets"
    }

    sets.idle.NoRefresh = {
        main = "Daybreak",
        sub = "",
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Shadow Ring",
        back = "Moonlight Cape",
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Fili Cothurnes +1"
    }

    sets.idle.DT = {
        main = "Daybreak",
        sub = "",
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Shadow Ring",
        back = "Moonlight Cape",
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    -- Defense sets

    sets.defense.PDT = {
        main = "Malignance Pole",
        sub = "Umbra Strap",
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Shadow Ring",
        back = "Moonlight Cape",
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.defense.MDT = {
        main = "Malignance Pole",
        sub = "Umbra Strap",
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Shadow Ring",
        back = "Moonlight Cape",
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.Kiting = {feet = "Fili Cothurnes +1"}
    sets.latent_refresh = {waist = "Fucho-no-obi"}
    sets.latent_refresh_grip = {sub = "Oneiros Grip"}
    sets.TPEat = {neck = "Chrys. Torque"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    sets.engaged = {
        main = "Aeneas",
        sub = "",
        ammo = "Coiste Bodhar",
        head = "Aya. Zucchetto +2",
        neck = "Asperity Necklace",
        ear1 = "Cessance Earring",
        ear2 = "Brutal Earring",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = gear.melee_jse_back,
        waist = "Windbuffet Belt +1",
        legs = "Aya. Cosciales +2",
        feet = "Battlecast Gaiters"
    }
    sets.engaged.DT = {
        main = "Aeneas",
        sub = "",
        ammo = "Coiste Bodhar",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Cessance Earring",
        ear2 = "Brutal Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = gear.melee_jse_back,
        waist = "Windbuffet Belt +1",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }
    sets.engaged.Acc = {
        main = "Aeneas",
        sub = "",
        ammo = "Coiste Bodhar",
        head = "Aya. Zucchetto +2",
        neck = "Combatant's Torque",
        ear1 = "Digni. Earring",
        ear2 = "Telos Earring",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Ramuh Ring +1",
        ring2 = "Ilabrat Ring",
        back = gear.melee_jse_back,
        waist = "Olseni Belt",
        legs = "Aya. Cosciales +2",
        feet = "Aya. Gambieras +2"
    }
    sets.engaged.DW = {
        main = "Aeneas",
        sub = "Twashtar",
        ammo = "Coiste Bodhar",
        head = "Aya. Zucchetto +2",
        neck = "Asperity Necklace",
        ear1 = "Suppanomimi",
        ear2 = "Brutal Earring",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = gear.melee_jse_back,
        waist = "Reiki Yotai",
        legs = "Aya. Cosciales +2",
        feet = "Battlecast Gaiters"
    }
    sets.engaged.DW.DT = {
        main = "Aeneas",
        sub = "Twashtar",
        ammo = "Coiste Bodhar",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Suppanomimi",
        ear2 = "Brutal Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = gear.melee_jse_back,
        waist = "Reiki Yotai",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }
    sets.engaged.DW.Acc = {
        main = "Aeneas",
        sub = "Twashtar",
        ammo = "Coiste Bodhar",
        head = "Aya. Zucchetto +2",
        neck = "Combatant's Torque",
        ear1 = "Suppanomimi",
        ear2 = "Telos Earring",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Ramuh Ring +1",
        ring2 = "Ilabrat Ring",
        back = gear.melee_jse_back,
        waist = "Reiki Yotai",
        legs = "Aya. Cosciales +2",
        feet = "Aya. Gambieras +2"
    }
    sets.engaged.DW.Acc.DT = {
        main = "Aeneas",
        sub = "Twashtar",
        ammo = "Coiste Bodhar",
        head = "Nyame Helm",
        neck = "Combatant's Torque",
        ear1 = "Suppanomimi",
        ear2 = "Telos Earring",
        body = "Ayanmo Corazza +2",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Ilabrat Ring",
        back = gear.melee_jse_back,
        waist = "Reiki Yotai",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    set_macro_page(1, 10)
end

state.Weapons:options("None", "Naegling", "Aeneas", "DualWeapons", "DualNaegling", "DualTauret", "DualAeolian")

autows_list = {
    ["Naegling"] = "Savage Blade",
    ["Aeneas"] = "Rudra's Storm",
    ["DualWeapons"] = "Rudra's Storm",
    ["DualNaegling"] = "Savage Blade",
    ["DualTauret"] = "Evisceration",
    ["DualAeolian"] = "Aeolian Edge"
}