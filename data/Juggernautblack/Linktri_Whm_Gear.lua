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

-- Setup vars that are user-dependent.  Can override this in a sidecar file.
function user_job_setup()
    state.OffenseMode:options("Normal", "Acc")
    state.CastingMode:options("Normal", "Resistant", "SIRD", "DT")
    state.IdleMode:options("Normal", "PDT", "MDT")
    state.PhysicalDefenseMode:options("PDT")
    state.MagicalDefenseMode:options("MDT")
    state.ResistDefenseMode:options("MEVA")
    state.Weapons:options("None", "DualWeapons", "MeleeWeapons")
    state.WeaponskillMode:options("Normal", "Fodder")

    gear.obi_cure_waist = "Austerity Belt +1" -- Austerity Belt +1 needed Second walk surged 5m AH
    gear.obi_cure_back = "Alaunus's Cape" -- Alaunus's Cape healing needed Ambuscade

    gear.obi_nuke_waist = ""
    gear.obi_high_nuke_waist = "Yamabuki-no-Obi" --Yamabuki-no-Obi needed Incursion Liij-Vok Waaxwane
    gear.obi_nuke_back = "Toro Cape" -- Toro Cape from Kumhau in Wildskeeper Reive

    -- Additional local binds
    send_command('bind ^` input /ma "Arise" <t>')
    send_command('bind !` input /ja "Penury" <me>')
    send_command("bind @` gs c cycle MagicBurstMode")
    send_command("bind ^@!` gs c toggle AutoCaress")
    send_command('bind ^backspace input /ja "Sacrosanctity" <me>')
    send_command('bind @backspace input /ma "Aurora Storm" <me>')
    send_command("bind !pause gs c toggle AutoSubMode") --Automatically uses sublimation.
    send_command('bind !backspace input /ja "Accession" <me>')
    send_command('bind != input /ja "Sublimation" <me>')
    send_command('bind ^delete input /ja "Dark Arts" <me>')
    send_command('bind !delete input /ja "Addendum: Black" <me>')
    send_command('bind @delete input /ja "Manifestation" <me>')
    send_command('bind ^\\\\ input /ma "Protectra V" <me>')
    send_command('bind @\\\\ input /ma "Shellra V" <me>')
    send_command('bind !\\\\ input /ma "Reraise IV" <me>')

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
    
    -- Apply IdleMode variants
    if state.IdleMode.value == 'PDT' then
        idleSet = sets.idle.PDT
    elseif state.IdleMode.value == 'MDT' then
        idleSet = sets.idle.MDT
    end
    
    -- Apply sublimation gear if active
    if buffactive["Sublimation: Activated"] then
        if state.IdleMode.value == 'Normal' and sets.buff.Sublimation then
            idleSet = set_combine(idleSet, sets.buff.Sublimation)
        elseif state.IdleMode.value:contains("DT") and sets.buff.DTSublimation then
            idleSet = set_combine(idleSet, sets.buff.DTSublimation)
        end
    end

    -- Apply conditional refresh gear when MP is low
    if player.mpp < 51 and sets.latent_refresh then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    
    return idleSet
end
-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Weapons sets
    sets.weapons.MeleeWeapons = {main = "Maxentius", sub = "Sors Shield"}
    sets.weapons.DualWeapons = {main = "Maxentius", sub={ name="Yagrush", augments={'Path: A',}}}

    sets.buff.Sublimation = {waist = "Embla Sash"}
    sets.buff.DTSublimation = {waist = "Embla Sash"}
	
	    -- ADD THE PACKING SET HERE:
    sets.packing = {
        main = "Mpaca's Staff",
        sub = "Oneiros Grip", 
        ammo = "Homiliary",
        head = "Null Masque",
        neck = "Sibyl Scarf",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Stikini Ring",
        back = "Alaunus's Cape",
        waist = "Fucho-no-obi",
        legs = "Assid. Pants +1",
        feet = "Nyame Sollerets"
    }

    -- Precast Sets


    -- Fast cast sets for spells
	-- Voltsurge Torque needed - Ramuh Prime II +4 FC
	-- Clerisy Strap +1 needed - AH 3m gil +3 FC
	-- Leyline Gloves needed - Sinister Reign +5 base, +8 capped FC
	-- Enchntr. Earring +1 needed - Surged  10th walk, AH 15m gil +2 FC

--current +82 FC	
    sets.precast.FC = {
        main = gear.grioavolr_fc_staff, --+7 FC
        sub = "Clerisy Strap +1",
        ammo = "Impatiens", --+2 QM
        head="Ebers Cap +3", --+13 FC
        neck = { name="Clr. Torque +2", augments={'Path: A',}},
        ear1 = "Etiolation Earring", --+1 FC
        ear2 = "Malignance Earring", --+4 FC
        body = "Inyanga Jubbah +2", --+14 FC
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}}, --+5 FC
        ring1 = "Kishar Ring", --+4 FC
        ring2 = "Lebeche Ring", --+2 QM
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}},
        waist = "Witful Belt", --+3 FC
        legs = "Aya. Cosciales +2", --+6 FC
        feet={ name="Regal Pumps +1", augments={'Path: A',}}, --+4 FC base, +8 FC capped with unity augment
    }

    sets.precast.FC.DT = {
        main = gear.grioavolr_fc_staff, --+7 FC
        sub = "Khonsu",
        ammo = "Impatiens", --+2 QM
        head= "Ebers Cap +3", --+13 FC
        neck = "Baetyl Pendant", --+4 FC
        ear1 = "Etiolation Earring", --+1 FC
        ear2 = "Malignance Earring", --+4 FC
        body = "Inyanga Jubbah +2", --+14 FC
        hands= "Ebers Mitts +3", --+11 DT
        ring1 = "Kishar Ring", --+4 FC
        ring2 = "Lebeche Ring", --+2 QM
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}},
        waist = "Witful Belt", --+3 FC
        legs = "Ebers Pant. +3", --+ 13 DT
        feet = "Ebers Duckbills +3", --+4 FC base, +8 FC capped with unity augment
    }

    sets.precast.FC["Enhancing Magic"] = set_combine(sets.precast.FC, {waist = "Siegel Sash"})

    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC["Enhancing Magic"], {})

    sets.precast.FC["Healing Magic"] = set_combine(sets.precast.FC, {legs = "Ebers pant. +3"})

    sets.precast.FC.StatusRemoval = sets.precast.FC["Healing Magic"]

    sets.precast.FC.Cure = set_combine(sets.precast.FC["Healing Magic"], {feet = "Hygieia Clogs +1"}) -- Hygieia Clogs +1 needed

    sets.precast.FC.Curaga = sets.precast.FC.Cure

    sets.precast.FC.CureSolace = sets.precast.FC.Cure

    sets.precast.FC.Impact = set_combine(sets.precast.FC, {head = empty, body = "Twilight Cloak"})  -- Twilight Cloak needed

    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main = "Daybreak", sub = "Genmei Shield"})

    -- Precast sets to enhance JAs
    sets.precast.JA.Benediction = {body = "Piety Bliaut +4"}

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {
        head={ name="Bunzi's Hat", augments={'Path: A',}},
        ear1 = "", -- Roundel Earring situational, not a high priority. 2m AH or Campaign Op "Plucking Wings"
        body = "Piety Bliaut +4",
        hands={ name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        waist = "Chaac Belt",
        back = ""  --back={ name="Aurist's Cape +1", augments={'Path: A',}}, specified but additional research required to determine viabilty
    }

    -- Weaponskill sets

    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head = "Aya. Zucchetto +2",
        neck = "Combatant's Torque",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = "Moonlight Cape",
        waist = "Olseni Belt",
        legs = "Aya. Cosciales +2",
        feet = "Aya. Gambieras +2"
    }

    sets.precast.WS.Fodder = {
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head = "Aya. Zucchetto +2",
        neck = "Asperity Necklace",
        ear1 = "Cessance Earring",
        ear2 = "Brutal Earring",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = "Moonlight Cape",
        waist = "Windbuffet Belt +1",
        legs = "Aya. Cosciales +2",
        feet = "Aya. Gambieras +2"
    }

    sets.precast.WS.Dagan = {
        ammo = "", -- Ghastly Tathlum +1 Specter Worm Unity Wanted
        head = "Pixie Hairpin +1",
        neck = "Sanctity Necklace",
        ear1 = "Etiolation Earring",
        ear2 = "Moonshade Earring",
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = "Regal Cuffs",
        ring1 = "Mephitas's Ring +1",
        ring2 = "Mephitas's Ring",
        back = "Aurist's Cape +1",
        waist = "Fotia Belt",
        legs = "Nyame Flanchard",
        feet = "Theo. Duckbills +4"
    }

    sets.MaxTP = {ear1 = "Cessance Earring", ear2 = "Brutal Earring"}
    sets.MaxTP.Dagan = {ear1 = "Etiolation Earring", ear2 = "Evans Earring"}

    --sets.precast.WS['Flash Nova'] = {}

    --sets.precast.WS['Mystic Boon'] = {}

    -- Midcast Sets

    sets.Kiting = {ring1 = "Shneddick Ring"}
    sets.latent_refresh = {waist = "Fucho-no-obi"} --+1 refresh when MP < 50%
    sets.latent_refresh_grip = {} --sub = "Oneiros Grip" +1 refresh when MP <= 75%
    sets.TPEat = {} --Chrys. Torque +1 refresh when TP +10 or greater, drains 10 TP per tick 
    sets.DayIdle = {}
    sets.NightIdle = {} --Umbra Cape -12 PDT at night. 500k on AH
    sets.TreasureHunter = set_combine(sets.TreasureHunter, {}) --feet = gear.chironic_treasure_feet not owned 

    --Situational sets: Gear that is equipped on certain targets
    sets.Self_Healing = {
        neck = "Phalaina Locket",
        ring1 = "Kunaji Ring",
        ring2 = "Asklepian Ring",
        waist = "Gishdubar Sash"
    }
    sets.Cure_Received = {
        neck = "Phalaina Locket",
        ring1 = "Kunaji Ring",
        ring2 = "Asklepian Ring",
        waist = "Gishdubar Sash"
    }
    sets.Self_Refresh = {back = "Grapevine Cape", waist = "Gishdubar Sash", feet = "Inspirited Boots"}

    -- Conserve Mp set for spells that don't need anything else, for set_combine.

    sets.ConserveMP = {
        main = gear.grioavolr_fc_staff,
        sub = "Umbra Strap",
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head = "Vanya Hood",
        neck = "", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun
        ear1 = "Gifted Earring",
        ear2 = "Gwati Earring",
        body = "Vedic Coat",
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1 = "Kishar Ring",
        ring2 = "", --Prolix Ring FC+2 enmity-3 Neith Temple of Uggalepih VW Ops
        back = "Solemnity Cape",
        waist = "Austerity Belt +1",
        legs = "Vanya Slops",
        feet = "Medium's Sabots"
    }

    sets.midcast.Teleport = sets.ConserveMP

    -- Gear for Magic Burst mode.
    sets.MagicBurst = {
        main = gear.grioavolr_nuke_staff,
        sub = "Enki Strap",
        neck = "Mizu. Kubikazari",
        ring1 = "Mujin Band",
        ring2 = "Locus Ring"
    }

    sets.midcast.FastRecast = {
        main = gear.grioavolr_fc_staff,
        sub = "Clerisy Strap +1",
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head={ name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Voltsurge Torque",
        ear1 = "", -- Enchntr. Earring +1 needed - Surged  10th walk, AH 15m gil +2 FC
        ear2 = "Malignance Earring",
        body = "Inyanga Jubbah +2",
        hands = "Gende. Gages +1",
        ring1 = "Kishar Ring",
        ring2 = "", --Prolix Ring FC+2 enmity-3 Neith Temple of Uggalepih VW Ops
        back = "Swith Cape +1",
        waist = "Witful Belt",
        legs = "Lengo Pants",
        feet={ name="Regal Pumps +1", augments={'Path: A',}},
    }

    -- Cure sets

    sets.midcast["Full Cure"] = sets.midcast.FastRecast

    sets.midcast.Cure = {
        main = "Raetic Rod +1",
        sub = "Sors Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun
        ear1 = "", --Glorious Earring Not-So-Clean Bill Adoulin quest
        ear2 = { name="Ebers Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Damage taken-5%',}},
        body = "Theo. Bliaut +4",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "", --Janniston Ring not owned
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "", --Luminary Sash Neak Geas Fete Reisenjima
        legs = "Ebers pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.CureSolace = {
        main = "Raetic Rod +1",
        sub = "Sors Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun
        ear1 = "", --Glorious Earring Not-So-Clean Bill Adoulin quest
        ear2 = { name="Ebers Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Damage taken-5%',}},
        body = "Ebers Bliaut +3",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Menelaus's Ring",
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "", --Luminary Sash Neak Geas Fete Reisenjima
        legs = "Ebers pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightWeatherCure = {
        main = "Chatoyant Staff",
        sub = "", -- Curatio Grip Nehebkau Abyssea - Misareaux
        ammo = "", --Esper Stone +1 Surged eighth walk
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun
        ear1 = "", --Glorious Earring Not-So-Clean Bill Adoulin quest
        ear2 ={ name="Nourish. Earring +1", augments={'Path: A',}},
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Lebeche Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = "Ebers pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightWeatherCureSolace = {
        main = "Chatoyant Staff",
        sub = "", -- Curatio Grip Nehebkau Abyssea - Misareaux
        ammo = "", --Esper Stone +1 Surged eighth walk
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun
        ear1 = "", --Glorious Earring Not-So-Clean Bill Adoulin quest
        ear2 = { name="Ebers Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Damage taken-5%',}},
        body = "Ebers Bliaut +3",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Lebeche Ring",
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "Hachirin-no-Obi",
        legs = "Ebers pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightDayCureSolace = {
        main = "Raetic Rod +1",
        sub = "Sors Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun
        ear1 = "", --Glorious Earring Not-So-Clean Bill Adoulin quest
        ear2 = "", --Regal Earring Ou Omen Boss
        body = "Ebers Bliaut +3",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Menelaus's Ring",
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "Hachirin-no-Obi",
        legs = "Ebers pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightDayCure = {
        main = "Raetic Rod +1",
        sub = "Sors Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun
        ear1 = "", --Glorious Earring Not-So-Clean Bill Adoulin quest
        ear2 ={ name="Nourish. Earring +1", augments={'Path: A',}},
        body = "Theo. Bliaut +4",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Menelaus's Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = "Ebers pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.Curaga = {
        main = "Raetic Rod +1",
        sub = "Sors Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun
        ear1 = "", --Glorious Earring Not-So-Clean Bill Adoulin quest
        ear2 = { name="Ebers Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Damage taken-5%',}},
        body = "Theo. Bliaut +4",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Menelaus's Ring",
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "", --Luminary Sash Neak Geas Fete Reisenjima
        legs = "Ebers pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightWeatherCuraga = {
        main = "Chatoyant Staff",
        sub = "", -- Curatio Grip Nehebkau Abyssea - Misareaux
        ammo = "", --Esper Stone +1 Surged eighth walk
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun
        ear1 = "", --Glorious Earring Not-So-Clean Bill Adoulin quest
        ear2 ={ name="Nourish. Earring +1", augments={'Path: A',}},
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Lebeche Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = "Ebers pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightDayCuraga = {
        main = "Raetic Rod +1",
        sub = "Sors Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun
        ear1 = "", --Glorious Earring Not-So-Clean Bill Adoulin quest
        ear2 ={ name="Nourish. Earring +1", augments={'Path: A',}},
        body = "Theo. Bliaut +4",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Menelaus's Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = "Ebers pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.Cure.DT = {
        main = "Raetic Rod +1",
        sub = "Sors Shield",
        ammo = "Staunch Tathlum +1",
        head = "Kaykaus Mitra +1",
        neck = "Loricate Torque +1",
        ear1 = "", --Glorious Earring Not-So-Clean Bill Adoulin quest
        ear2 ={ name="Nourish. Earring +1", augments={'Path: A',}},
        body={ name="Nyame Mail", augments={'Path: B',}},
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "", --Janniston Ring not owned
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "", --Luminary Sash Neak Geas Fete Reisenjima
        legs = "Ebers Pant. +3",
        feet = "Ebers Duckbills +3"
    }

    --Melee Curesets are used whenever your Weapons state is set to anything but None.
    sets.midcast.MeleeCure = {
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun
        ear1 = "", --Glorious Earring Not-So-Clean Bill Adoulin quest
        ear2 = { name="Ebers Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Damage taken-5%',}},
        body = "Theo. Bliaut +4",
        hands = { name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Lebeche Ring",
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "", --Luminary Sash Neak Geas Fete Reisenjima
        legs = "Ebers pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.MeleeCureSolace = set_combine(sets.midcast.MeleeCure, {body = "Ebers Bliaut +3"})
    sets.midcast.MeleeLightWeatherCure = set_combine(sets.midcast.MeleeCure, {waist = "Hachirin-no-Obi"})
    sets.midcast.MeleeLightWeatherCureSolace =
        set_combine(sets.midcast.MeleeCure, {body = "Ebers Bliaut +3", waist = "Hachirin-no-Obi"})
    sets.midcast.MeleeLightDayCureSolace =
        set_combine(sets.midcast.MeleeCure, {body = "Ebers Bliaut +3", waist = "Hachirin-no-Obi"})
    sets.midcast.MeleeLightDayCure = set_combine(sets.midcast.MeleeCure, {waist = "Hachirin-no-Obi"})
    sets.midcast.MeleeCuraga = set_combine(sets.midcast.MeleeCure, {})
    sets.midcast.MeleeLightWeatherCuraga = set_combine(sets.midcast.MeleeCure, {waist = "Hachirin-no-Obi"})
    sets.midcast.MeleeLightDayCuraga = set_combine(sets.midcast.MeleeCure, {waist = "Hachirin-no-Obi"})

    sets.midcast.CureSolace.DT = set_combine(sets.midcast.Cure.DT, {body = "Ebers Bliaut +3"})
    sets.midcast.LightWeatherCure.DT = set_combine(sets.midcast.Cure.DT, {waist = "Hachirin-no-Obi"})
    sets.midcast.LightWeatherCureSolace.DT =
        set_combine(sets.midcast.Cure.DT, {body = "Ebers Bliaut +3", waist = "Hachirin-no-Obi"})
    sets.midcast.LightDayCureSolace.DT =
        set_combine(sets.midcast.Cure.DT, {body = "Ebers Bliaut +3", waist = "Hachirin-no-Obi"})
    sets.midcast.LightDayCure.DT = set_combine(sets.midcast.Cure.DT, {waist = "Hachirin-no-Obi"})
    sets.midcast.Curaga.DT = set_combine(sets.midcast.Cure.DT, {})
    sets.midcast.LightWeatherCuraga.DT = set_combine(sets.midcast.Cure.DT, {waist = "Hachirin-no-Obi"})
    sets.midcast.LightDayCuraga.DT = set_combine(sets.midcast.Cure.DT, {waist = "Hachirin-no-Obi"})
    sets.midcast.MeleeCure.DT = set_combine(sets.midcast.Cure.DT, {})

    sets.midcast.MeleeCureSolace.DT = set_combine(sets.midcast.Cure.DT, {body = "Ebers Bliaut +3"})
    sets.midcast.MeleeLightWeatherCure.DT = set_combine(sets.midcast.Cure.DT, {waist = "Hachirin-no-Obi"})
    sets.midcast.MeleeLightWeatherCureSolace.DT =
        set_combine(sets.midcast.Cure.DT, {body = "Ebers Bliaut +3", waist = "Hachirin-no-Obi"})
    sets.midcast.MeleeLightDayCureSolace.DT =
        set_combine(sets.midcast.Cure.DT, {body = "Ebers Bliaut +3", waist = "Hachirin-no-Obi"})
    sets.midcast.MeleeLightDayCure.DT = set_combine(sets.midcast.Cure.DT, {waist = "Hachirin-no-Obi"})
    sets.midcast.MeleeCuraga.DT = set_combine(sets.midcast.Cure.DT, {})
    sets.midcast.MeleeLightWeatherCuraga.DT = set_combine(sets.midcast.Cure.DT, {waist = "Hachirin-no-Obi"})
    sets.midcast.MeleeLightDayCuraga.DT = set_combine(sets.midcast.Cure.DT, {waist = "Hachirin-no-Obi"})

    sets.midcast.Cursna = {
        main = "Yagrush",
        sub = "Clemency Grip",
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head = "Ebers Cap +3",
        neck = "", --Debilis Medallion 4m on AH
        ear1 = "Meili Earring",
        ear2 = "Malignance Earring",
        body = "Ebers Bliaut +3",
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1 = "", -- Haoma's Ring 2m on AH
        ring2 = "Menelaus's Ring",
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "Witful Belt",
        legs = "Th. Pant. +3",
        feet = "" -- Vanya Clogs Gulltop Escha Zi'tah Geas Fete
    }

    sets.midcast.StatusRemoval = {
        main = "Yagrush",
        sub = "Sors Shield",
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head = "Ebers Cap +3",
        neck = "", --Voltsurge Torque Ramuh HTMB
        ear1 = "", -- Enchntr. Earring +1 needed - Surged  10th walk, AH 15m gil +2 FC
        ear2 = "Malignance Earring",
        body = "Inyanga Jubbah +2",
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1 = "Kishar Ring",
        ring2 = "", --Prolix Ring FC+2 enmity-3 Neith Temple of Uggalepih VW Ops
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}},
        waist = "Witful Belt",
        legs = "Ebers pant. +3",
        feet={ name="Regal Pumps +1", augments={'Path: A',}},
    }

    sets.midcast.Erase = set_combine(sets.midcast.StatusRemoval, {neck = { name="Clr. Torque +2", augments={'Path: A',}}})

    -- 110 total Enhancing Magic Skill; caps even without Light Arts
    sets.midcast["Enhancing Magic"] = {
        main = gear.gada_enhancing_club,
        sub = "Ammurapi Shield",
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head={ name="Telchine Cap", augments={'Mag. Acc.+20','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        neck = "", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun
        ear1 = "Andoaa Earring",
        ear2 = "", --Gifted Earring evaluate for appropriateness Conserve MP+3 Blood Boon +3
        body={ name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        hands={ name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        ring1 = "Stikini Ring", -- +1 variant 40m on AH
        ring2 = "", -- Stikini Ring or +1 variant 40m on AH
        back={ name="Mending Cape", augments={'Healing magic skill +2','Enha.mag. skill +8','Mag. Acc.+10',}},
        waist = "Embla Sash",
        legs={ name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        feet = "Theo. Duckbills +4" -- Enhancing Magic duration +10
    }
-- Shedir Seraweels 30k at Curio Moogle
-- Earthcry Earring The Mobline Comedy Bia Orb BCNM

    sets.midcast.Stoneskin =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {neck = "Nodens Gorget", ear2 = "Earthcry Earring", waist = "Siegel Sash", legs = "Shedir Seraweels"}
    )

    sets.midcast.Auspice = set_combine(sets.midcast["Enhancing Magic"], {feet = "Ebers duckbills +3",})

    sets.midcast.Aquaveil =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {
            main = "", -- Vadose Rod Leviathan HTMB
            sub = "Ammurapi Shield",
            hands = "", -- Regal Cuffs Ou Omen
            waist = "", --Emphatikos Rope SIRD +12 Aquaveil +1 Xan Abyssea - Vunkerl 
            legs = "" -- Shedir Seraweels noted above
        }
    )

    sets.midcast.Regen = set_combine(sets.midcast["Enhancing Magic"], {hands = "Ebers Mitts +3", legs = "Th. Pant. +3"})
-- Sekhmet Corset AA MR II or DM II 
-- Sheltered Ring Bhishani South Gustaberg Voidwatch Op
    sets.midcast.Protect =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {ring2 = "Sheltered Ring", feet = "Theo. Duckbills +4", ear1 = "Gifted Earring", waist = "Sekhmet Corset"}
    )
    sets.midcast.Protectra =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {ring2 = "Sheltered Ring", feet = "Theo. Duckbills +4", ear1 = "Gifted Earring", waist = "Sekhmet Corset"}
    )
    sets.midcast.Shell =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {ring2 = "Sheltered Ring", legs = "Theo. Duckbills +4", ear1 = "Gifted Earring", waist = "Sekhmet Corset"}
    )
    sets.midcast.Shellra =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {ring2 = "Sheltered Ring", feet = "Theo. Duckbills +4", ear1 = "Gifted Earring", waist = "Sekhmet Corset"}
    )

    sets.midcast.BarElement = {
        main = "Beneficus",
        sub = "Ammurapi Shield",
        ammo = "Staunch Tathlum +1",
        head = "Ebers Cap +3",
        neck = "",
        ear1 = "Andoaa Earring",
        ear2 = "", --Gifted Earring evaluate for appropriateness Conserve MP+3 Blood Boon +3
        body = "Ebers Bliaut +3",
        hands = "Ebers Mitts +3",
        ring1 = "Stikini Ring", -- +1 variant 40m on AH
        ring2 = "", -- Stikini Ring or+1 variant 40m on AH
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}},
        waist = "Embla Sash",
        legs = "Piety Panta. +4",
        feet = "Ebers duckbills +3",
    }
	
-- Individual bar-status spell sets using Sroda Necklace
    sets.midcast.Barparalyzra = set_combine(sets.midcast["Enhancing Magic"], {neck = "Sroda Necklace"})
    sets.midcast.Barblindra = set_combine(sets.midcast["Enhancing Magic"], {neck = "Sroda Necklace"})
    sets.midcast.Barsilencera = set_combine(sets.midcast["Enhancing Magic"], {neck = "Sroda Necklace"})
    sets.midcast.Barpetra = set_combine(sets.midcast["Enhancing Magic"], {neck = "Sroda Necklace"})
    sets.midcast.Barpoisonra = set_combine(sets.midcast["Enhancing Magic"], {neck = "Sroda Necklace"})
    sets.midcast.Baramnesra = set_combine(sets.midcast["Enhancing Magic"], {neck = "Sroda Necklace"})
    sets.midcast.Barvira = set_combine(sets.midcast["Enhancing Magic"], {neck = "Sroda Necklace"})
    sets.midcast.Barsleepra = set_combine(sets.midcast["Enhancing Magic"], {neck = "Sroda Necklace"})

    sets.midcast.Impact = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = empty,
        neck = "Erra Pendant",
        ear1 = "", --Digni. Earring Strophadia Reisenjima
        ear2 = "", --Regal Earring Ou Omen Boss
        body = "", --Twilight Cloak Shinryu HTMB
        hands = gear.chironic_enfeeble_hands,
        ring1 ={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back = "",  -- Toro Cape +10 MAB +8 INT Kumhau Wildskeeper Reive
        waist = "", -- Acuity Belt +1 Joyous Green Unity Wanted
        legs = "", --Chironic Hose 800 domain points
        feet = gear.chironic_nuke_feet
    }

    sets.midcast["Elemental Magic"] = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "", -- Ghastly Tathlum +1 Specter Worm Unity Wanted
        head={ name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Baetyl Pendant",
        ear1 = "", --Friomisi Earring Kumhau Wildskeeper Reive or 1m on AH
        ear2 = "", --Regal Earring Ou Omen Boss
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',}},
        hands = gear.chironic_enfeeble_hands,
        ring1 = "", --Shiva Ring +1 Synergy from Shivatear and Rhodium Ring or +1 variant
        ring2 = "", --Freke Ring Odin HTMB
        back = "",  -- Toro Cape +10 MAB +8 INT Kumhau Wildskeeper Reive
        waist = gear.ElementalObi,
        legs = "Chironic Hose",
        feet = gear.chironic_nuke_feet
    }

    sets.midcast["Elemental Magic"].Resistant = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "", -- Ghastly Tathlum +1 Specter Worm Unity Wanted
        head = "C. Palug Crown",
        neck = "Sanctity Necklace",
        ear1 = "Crematio Earring",
        ear2 = "", --Regal Earring Ou Omen Boss
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',}},
        hands = gear.chironic_enfeeble_hands,
        ring1 = "Metamor. Ring +1",
        ring2 = "", --Freke Ring Odin HTMB
        back = "",  -- Toro Cape +10 MAB +8 INT Kumhau Wildskeeper Reive
        waist = "Yamabuki-no-Obi",
        legs = "Chironic Hose",
        feet = gear.chironic_nuke_feet
    }

    sets.midcast["Divine Magic"] = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "C. Palug Crown",
        neck = "", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun
        ear1 = "", --Digni. Earring Strophadia Reisenjima
        ear2 = "", --Regal Earring Ou Omen Boss
        body = "Inyanga Jubbah +2",
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1 = "Stikini Ring", -- +1 variant 40m on AH
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back = "Aurist's Cape +1",
        waist = "", --Luminary Sash Neak Geas Fete Reisenjima
        legs = "Chironic Hose",
        feet = gear.chironic_nuke_feet
    }

    sets.midcast.Holy = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "C. Palug Crown",
        neck = "Baetyl Pendant",
        ear1 = "", --Friomisi Earring Kumhau Wildskeeper Reive or 1m on AH
        ear2 = "", --Regal Earring Ou Omen Boss
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',}},
        hands = gear.chironic_enfeeble_hands,
        ring1 = "Metamor. Ring +1",
        ring2 = "", --Freke Ring Odin HTMB
        back = "",  -- Toro Cape +10 MAB +8 INT Kumhau Wildskeeper Reive
        waist = gear.ElementalObi,
        legs = "Gyve Trousers",
        feet = gear.chironic_nuke_feet
    }

    sets.midcast["Dark Magic"] = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Erra Pendant",
        ear1 = "", --Digni. Earring Strophadia Reisenjima
        ear2 = "", --Regal Earring Ou Omen Boss
        body = "Inyanga Jubbah +2",
        hands = gear.chironic_enfeeble_hands,
        ring1 = "Stikini Ring", -- +1 variant 40m on AH
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back = "Aurist's Cape +1",
        waist = "Acuity Belt +1",
        legs = "Chironic Hose",
        feet = gear.chironic_nuke_feet
    }

    sets.midcast.Drain = {
        main = "Rubicundity",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Pixie Hairpin +1",
        neck = "Erra Pendant",
        ear1 = "", --Digni. Earring Strophadia Reisenjima
        ear2 = "", --Regal Earring Ou Omen Boss
        body = "Inyanga Jubbah +2",
        hands = gear.chironic_enfeeble_hands,
        ring1 = "Evanescence Ring",
        ring2 = "Archon Ring",
        back = "Aurist's Cape +1",
        waist = "Fucho-no-obi",
        legs = "Chironic Hose",
        feet = gear.chironic_nuke_feet
    }

    sets.midcast.Drain.Resistant = {
        main = "Rubicundity",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Erra Pendant",
        ear1 = "", --Digni. Earring Strophadia Reisenjima
        ear2 = "", --Regal Earring Ou Omen Boss
        body = "Chironic Doublet",
        hands = gear.chironic_enfeeble_hands,
        ring1 = "Stikini Ring", -- +1 variant 40m on AH
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back = "Aurist's Cape +1",
        waist = "Fucho-no-obi",
        legs = "Chironic Hose",
        feet = gear.chironic_nuke_feet
    }

    sets.midcast.Aspir = sets.midcast.Drain
    sets.midcast.Aspir.Resistant = sets.midcast.Drain.Resistant

    sets.midcast.Stun = {
        main = gear.grioavolr_fc_staff,
        sub = "Clerisy Strap +1",
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head={ name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Voltsurge Torque",
        ear1 = "", -- Enchntr. Earring +1 needed - Surged  10th walk, AH 15m gil +2 FC
        ear2 = "Malignance Earring",
        body = "Inyanga Jubbah +2",
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1 = "Kishar Ring",
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back = "Aurist's Cape +1",
        waist = "Witful Belt",
        legs = "Lengo Pants",
        feet={ name="Regal Pumps +1", augments={'Path: A',}},
    }

    sets.midcast.Stun.Resistant = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Erra Pendant",
        ear1 = "", --Digni. Earring Strophadia Reisenjima
        ear2 = "", --Regal Earring Ou Omen Boss
        body = "Inyanga Jubbah +2",
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1 = "Stikini Ring", -- +1 variant 40m on AH
        ring2 = "", -- Stikini Ring or +1 variant 40m on AH
        back = "Aurist's Cape +1",
        waist = "Acuity Belt +1",
        legs = "Chironic Hose",
        feet = gear.chironic_nuke_feet
    }

    sets.midcast.Dispel = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Erra Pendant",
        ear1 = "", --Digni. Earring Strophadia Reisenjima
        ear2 = "", --Regal Earring Ou Omen Boss
        body = "Inyanga Jubbah +2",
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1 = "Stikini Ring", -- +1 variant 40m on AH
        ring2 = "", -- Stikini Ring or +1 variant 40m on AH
        back = "Aurist's Cape +1",
        waist = "Acuity Belt +1",
        legs = "Chironic Hose",
        feet = gear.chironic_nuke_feet
    }

    sets.midcast.Dispelga = set_combine(sets.midcast.Dispel, {main = "Daybreak", sub = "Ammurapi Shield"})

    sets.midcast["Enfeebling Magic"] = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Befouled Crown",
        neck = "Erra Pendant",
        ear1 = "", --Digni. Earring Strophadia Reisenjima
        ear2 = "", --Regal Earring Ou Omen Boss
        body = "Theo. Bliaut +4",
        hands = { name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        ring1 = "Kishar Ring",
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back = "Aurist's Cape +1",
        waist = "Obstin. Sash",
        legs = { name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        feet = "Theo. Duckbills +4"
    }

    sets.midcast["Enfeebling Magic"].Resistant = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Befouled Crown",
        neck = "Erra Pendant",
        ear1 = "", --Digni. Earring Strophadia Reisenjima
        ear2 = "", --Regal Earring Ou Omen Boss
        body = "Theo. Bliaut +4",
        hands = "Theo. Mitts +4",
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back = "Aurist's Cape +1",
        waist = "", --Luminary Sash Neak Geas Fete Reisenjima
        legs = "Chironic Hose",
        feet = "Theo. Duckbills +4"
    }
	-- SIRD (Spell Interruption Rate Down) gear sets
sets.midcast.Cure.SIRD = set_combine(sets.midcast.Cure, {
    ammo = "Staunch Tathlum +1", -- SIRD +11
    neck = "Loricate Torque +1", -- SIRD +5
    ear1 = "Magnetic Earring", -- SIRD +8
	ring1 = { name="Murky Ring", augments={'Path: A',}},
    waist = "Emphatikos Rope", -- SIRD +12
    feet = "Theo. Duckbills +4", -- SIRD +29
})

sets.midcast["Enhancing Magic"].SIRD = set_combine(sets.midcast["Enhancing Magic"], {
    ammo = "Staunch Tathlum +1", -- SIRD +11
    neck = "Loricate Torque +1", -- SIRD +5
    ear1 = "Magnetic Earring", -- SIRD +8
    waist = "Emphatikos Rope", -- SIRD +12
    feet = "Regal Pumps +1", -- SIRD +4-8
})

-- DT (Damage Taken) gear sets
sets.midcast.Cure.DT = set_combine(sets.midcast.Cure, {
    ammo = "Staunch Tathlum +1", -- PDT -3, MDT -3
    head = "Null Masque", -- DT -7
    neck = "Loricate Torque +1", -- PDT -6, MDT -6
    body = "Ebers Bliaut +3", -- DT -9
    hands = "Ebers Mitts +3", -- DT -7
    ring1 = { name="Murky Ring", augments={'Path: A',}}, 
    legs = "Ebers Pant. +3", -- DT -8
    feet = "Ebers Duckbills +3", -- DT -7
})

sets.midcast["Enhancing Magic"].DT = set_combine(sets.midcast["Enhancing Magic"], {
    ammo = "Staunch Tathlum +1",
    head = "Nyame Helm",
    neck = "Loricate Torque +1",
    body = "Nyame Mail",
    hands = "Nyame Gauntlets", 
    ring1 = { name="Murky Ring", augments={'Path: A',}},
    legs = "Nyame Flanchard",
    feet = "Nyame Sollerets",
})

    sets.midcast.Dia = set_combine(sets.midcast["Enfeebling Magic"], sets.TreasureHunter)
    sets.midcast.Diaga = set_combine(sets.midcast["Enfeebling Magic"], sets.TreasureHunter)
    sets.midcast["Dia II"] = sets.midcast["Enfeebling Magic"]
    sets.midcast.Bio = set_combine(sets.midcast["Enfeebling Magic"], sets.TreasureHunter)
    sets.midcast["Bio II"] = sets.midcast["Enfeebling Magic"]

    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast["Enfeebling Magic"], {})
    sets.midcast.ElementalEnfeeble.Resistant = set_combine(sets.midcast["Enfeebling Magic"].Resistant, {})

    sets.midcast.IntEnfeebles = set_combine(sets.midcast["Enfeebling Magic"], {waist = "Acuity Belt +1"})
    sets.midcast.IntEnfeebles.Resistant =
        set_combine(sets.midcast["Enfeebling Magic"].Resistant, {waist = "Acuity Belt +1"})

    sets.midcast.MndEnfeebles = set_combine(sets.midcast["Enfeebling Magic"], {back = "Alaunus's Cape"})
    sets.midcast.MndEnfeebles.Resistant =
        set_combine(sets.midcast["Enfeebling Magic"].Resistant, {back = "Alaunus's Cape"})

    -- Sets to return to when not performing an action.

    -- Resting sets
    sets.resting = {
        main = "Chatoyant Staff",
        sub = "Oneiros Grip",
        ammo = "Homiliary",
        head = "Null Masque",
        neck = "Chrys. Torque",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Ebers Bliaut +3",
        hands = gear.chironic_refresh_hands,
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Dark Ring",
        back = "Umbra Cape",
        waist = "Fucho-no-obi",
        legs = "Assid. Pants +1",
        feet = gear.chironic_refresh_feet
    }

    -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)
    sets.idle = {
		main = { name="Mpaca's Staff", augments={'Path: A',}}, -- Refresh +2
		sub = "", -- Oneiros Grip Refresh +1 when MP ≤75%
		ammo = "Staunch Tathlum +1", -- Homiliary Better than Staunch for pure refresh focus
		head = "Null Masque", -- Refresh +1
		neck = "Sibyl Scarf", -- Chrys. Torque Refresh +1 when TP ≥10 (drains 10 TP per tick)
		ear1 = "Etiolation Earring", -- Refresh +1
		ear2 = "Ebers Earring +1", -- Alternative for pure refresh build
		body = "Ebers Bliaut +3", -- Refresh +4
		hands = "Inyan. Dastanas +2", -- Refresh +0.5
		ring1 = { name="Murky Ring", augments={'Path: A',}}, -- Skill bonuses
		ring2 = "Inyanga Ring", -- Refresh +1
		back = "Alaunus's Cape",
		waist = "Fucho-no-obi", -- Refresh +1 when MP <50%
		legs = "Assid. Pants +1", -- Refresh +2 (with Unity rank)
		feet = "Inyan. Crackows +2" -- Refresh +0.5
}

    sets.idle.PDT = {
        main = "Malignance Pole",
        sub = "Umbra Strap",
        ammo = "Homiliary",
        head = "Null Masque",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body= "Ebers Bliaut +3",
        hands = "Ebers Mitts +3",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back = "Moonlight Cape",
        waist = "Carrier's Sash",
        legs = "Assid. Pants +1",
        feet = "Ebers duckbills +3"
    }

    sets.idle.MDT = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Homiliary",
        head = "Null Masque",
        neck = "Warder's Charm +1",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Shadow Ring",
        back = "Moonlight Cape",
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    -- Defense sets

    sets.defense.PDT = {
        main = "Bunzi's Rod",
        sub = "Genmei Shield",
        ammo = "Staunch Tathlum +1",
        head = "Null Masque",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Ebers Bliaut +3",
        hands = "Ebers Mitts +3",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Gelatinous Ring +1",
        back = "Shadow Mantle",
        waist = "Carrier's Sash",
        legs = "Ebers Pant. +3",
        feet = "Ebers Duckbills +3"
    }

    sets.defense.MDT = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Warder's Charm +1",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Shadow Ring",
        ring2 = "Archon Ring",
        back = "Moonlight Cape",
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.defense.MEVA = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Warder's Charm +1",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Purity Ring",
        ring2 = "Vengeful Ring",
        back = "Aurist's Cape +1",
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    -- Basic set for if no TP weapon is defined.
    sets.engaged = {
        main = "Maxentius",
        sub = "Ammurapi Shield",
        ammo = "Staunch Tathlum +1",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Asperity Necklace",
        ear1 = "", --Cessance Earring Omega II One to be Feared
        ear2 = "Brutal Earring",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = "", --Moonlight Cape
        waist = "", --Windbuffet Belt +1
        legs = { name="Nyame Flanchard", augments={'Path: B',}},
        feet = { name="Nyame Sollerets", augments={'Path: B',}},
    }

    sets.engaged.Acc = {
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head = "Aya. Zucchetto +2",
        neck = "", --Combatant's Torque
        ear1 = "", --Telos Earring
        ear2 = "Brutal Earring",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = "", --Moonlight Cape
        waist = "", --Olseni Belt
        legs = "Aya. Cosciales +2",
        feet = "Aya. Gambieras +2"
    }

    sets.engaged.DW = {
        ammo = "Crepuscular Pebble",
        head = "Nyame Helm",
        neck = "Null Loop",
        ear1 = "Moonshade Earring",
        ear2 = "Suppanomimi",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = "Penetrating Cape",
        waist = "Null Belt",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.engaged.DW.Acc = {
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head = "Aya. Zucchetto +2",
        neck = "", --Combatant's Torque
        ear1 = "", --Telos Earring
        ear2 = "Suppanomimi",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = "", --Moonlight Cape
        waist = "", --Shetal Stone
        legs = "Aya. Cosciales +2",
        feet = "Aya. Gambieras +2"
    }

    -- Buff sets: Gear that needs to be worn to actively enhance a current player buff.
    sets.buff["Divine Caress"] = {hands = "Ebers Mitts +3", back = "Mending Cape"}

    sets.HPDown = {
        head = "Pixie Hairpin +1",
        ear1 = "Mendicant's Earring",
        ear2 = "Evans Earring",
        body = "Zendik Robe",
        hands = "Hieros Mittens",
        ring1 = "Mephitas's Ring +1",
        ring2 = "Mephitas's Ring",
        back = "Swith Cape +1",
        waist = "Carrier's Sash",
        legs = "Shedir Seraweels",
        feet = ""
    }

    sets.HPCure = {
        main = "Raetic Rod +1",
        sub = "Sors Shield",
        ammo = "Pemphredo Tathlum",
        head = "Nyame Helm",
        neck = "Nodens Gorget",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = { name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1 = "", --Kunaji Ring
        ring2 = "", --Meridian Ring
        back = "Alaunus's Cape",
        waist = "Eschan Stone",
        legs = "Ebers pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.buff.Doom = set_combine(sets.buff.Doom, {})
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    set_macro_page(1, 3)
end

function user_job_lockstyle()
    windower.chat.input("/lockstyleset 003")
end

autows_list = {["DualWeapons"] = "Realmrazer", ["MeleeWeapons"] = "Realmrazer"}

-- Sleep detection function - add this here
function user_job_buff_change(buff, gain)
    if buff == 'sleep' and gain then
        add_to_chat(123, "Sleep detected! Forcing Lorg Mor equip...")
        
        -- Force weapon state change and direct equip
        state.Weapons:set('MeleeWeapons') -- Temporarily change weapon state
        disable('main')
        disable('sub')
        
        -- Force equip with multiple attempts
        equip({main = "Lorg Mor"})
        windower.send_command('wait 0.5; input /equip main "Lorg Mor"')
        windower.send_command('wait 1.0; input /equip main "Lorg Mor"')
        
        -- Reset after delay
        windower.send_command('wait 6; gs enable main; gs enable sub; gs c set Weapons None')
        add_to_chat(123, "Lorg Mor force equipped. Will reset weapon state in 6 seconds.")
    end
end

-- ADD THE PORTER MOOGLE FUNCTION HERE:
function near_porter_moogle()
    local mobs = windower.ffxi.get_mob_array()
    for i, mob in pairs(mobs) do
        if mob.name == "Porter Moogle" and mob.distance and mob.distance < 36 then
            return true
        end
    end
    return false
end
-- Sortie strip/restore functionality
-- Use with in-game /equipset command to remove gear, this just locks/unlocks slots
sortie_stripped = false

function job_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'sortie' then
        if not sortie_stripped then
            -- Lock all slots to prevent GearSwap from auto-equipping
            disable('main','sub','range','ammo','head','neck','ear1','ear2',
                   'body','hands','ring1','ring2','back','waist','legs','feet')
            
            sortie_stripped = true
            add_to_chat(122, 'Sortie Mode: All slots LOCKED. GearSwap disabled.')
        else
            -- Unlock all slots and let GearSwap take over
            enable('main','sub','range','ammo','head','neck','ear1','ear2',
                   'body','hands','ring1','ring2','back','waist','legs','feet')
            
            sortie_stripped = false
            
            -- Force GearSwap to re-evaluate and equip appropriate gear
            status_change(player.status)
            
            add_to_chat(122, 'Sortie Mode: All slots UNLOCKED. GearSwap re-enabled.')
        end
    end
end