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
	send_command('bind !f11 gs c cycle CastingMode')

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
    sets.weapons.MeleeWeapons = {main = "Mjollnir", sub = "Sors Shield"}
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
        waist = "Fucho-no-Obi",
        legs = "Assid. Pants +1",
        feet = "Nyame Sollerets"
    }

    -- Precast Sets


    -- Fast cast sets for spells
	-- Leyline Gloves needed - Sinister Reign +5 base, +8 capped FC
	-- Enchntr. Earring +1 needed - Surged  10th walk, AH 15m gil +2 FC

--current +82 FC	
    sets.precast.FC = {
        main = gear.grioavolr_fc_staff, --+7 FC
        sub = "Clerisy Strap +1",
        ammo = "Impatiens", --+2 QM
        head="Ebers Cap +3", --+13 FC
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, --+10 FC
        ear1 = "Etiolation Earring", --+1 FC
        ear2 = "Malignance Earring", --+4 FC
        body = "Inyanga Jubbah +2", --+14 FC
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}}, --+5 FC
        ring1 = "Kishar Ring", --+4 FC
        ring2 = "Lebeche Ring", --+2 QM
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}},
        waist = "Witful Belt", --+3 FC
        legs = "Kaykaus Tights +1", --+7 FC
        feet={ name="Regal Pumps +1", augments={'Path: A',}}, --+4 FC base, +8 FC capped with unity augment
    }

    sets.precast.FC.DT = {
        main = gear.grioavolr_fc_staff, --+7 FC
        sub = "Clerisy Strap +1",
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

    sets.precast.FC["Healing Magic"] = set_combine(sets.precast.FC, {legs = "Ebers Pant. +3"})

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
        ear1 = "Hoxne Earring", -- LINKTRI MOD 2026-07-02: MR7 = all stats +15 (CHR/VIT feed Waltz). Roundel Earring still an option: 2m AH or Campaign Op "Plucking Wings"
        body = "Piety Bliaut +4",
        hands={ name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        waist = "Chaac Belt",
        back={ name="Aurist's Cape +1", augments={'Path: A',}},
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
        back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, -- LINKTRI MOD 2026-07-02: Moonlight Cape not in inventory; proper fix = 2nd Alaunus's w/ STR+WSD augments
        waist = { name="Sailfi Belt +1", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: Olseni Belt not in inventory
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
        back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, -- LINKTRI MOD 2026-07-02: Moonlight Cape not in inventory; proper fix = 2nd Alaunus's w/ STR+WSD augments
        waist = { name="Sailfi Belt +1", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: Windbuffet Belt +1 not in inventory
        legs = "Aya. Cosciales +2",
        feet = "Aya. Gambieras +2"
    }

    sets.precast.WS.Dagan = {
        ammo = "", -- Ghastly Tathlum +1 Specter Worm Unity Wanted
        head = "Pixie Hairpin +1", -- not in inventory export
        neck = "Sanctity Necklace", -- not in inventory export
        ear1 = "Hoxne Earring", -- LINKTRI MOD 2026-07-02: MR7 all stats +15 (Dagan is MND-modded); was Etiolation Earring
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

    sets.Kiting = {ring1 = "Shneddick Ring +1"}
    sets.latent_refresh = {waist = "Fucho-no-Obi"} --+1 refresh when MP < 50%
    sets.latent_refresh_grip = {} --sub = "Oneiros Grip" +1 refresh when MP <= 75%
    sets.TPEat = {} --Chrys. Torque +1 refresh when TP +10 or greater, drains 10 TP per tick 
    sets.DayIdle = {}
    sets.NightIdle = {} --Umbra Cape -12 PDT at night. 500k on AH
    sets.TreasureHunter = set_combine(sets.TreasureHunter, {}) --feet = gear.chironic_treasure_feet not owned 

    --Situational sets: Gear that is equipped on certain targets
    -- LINKTRI MODIFICATION START 2026-07-02: Self_Healing / Cure_Received emptied.
    -- Sel-Include equips these as an OVERLAY on self-target cures (and cures received). None of
    -- the four items (Phalaina Locket, Kunaji Ring, Asklepian Ring, Gishdubar Sash) are in
    -- inventory, so the overlay was clobbering neck/ring1/ring2/waist of the combined SIRD/DT
    -- cure sets -- the queued missing items simply failed, leaving precast gear in those slots.
    -- SHOPPING: Gishdubar Sash (also on the Doom list), Phalaina Locket, Kunaji/Asklepian Rings.
    -- When acquired, restore them here AND define sets.Self_Healing.SIRD = {} so Sel's built-in
    -- escape hatch keeps the SIRD combined set intact on self-cures in combat.
    -- REVERT: restore the four-item tables from git history / prior file version.
    sets.Self_Healing = {}
    sets.Cure_Received = {}
    -- LINKTRI MODIFICATION END
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
    -- LINKTRI MODIFICATION START 2026-07-02: MagicBurst overlay
    -- Removed main/sub: Daybreak (MAB+40, M.Dmg+241) from the base nuke set beats the Grioavolr
    -- swap (MAB+26). Mujin Band / Locus Ring are NOT in inventory (Mujin Band = cheap Ambuscade
    -- pickup). MB dmg I gear cap (+40) already reached: Bunzi 4pc (+33) + Mizuchi (+10).
    -- REVERT: main=gear.grioavolr_nuke_staff, sub="Enki Strap", ring1="Mujin Band", ring2="Locus Ring"
    sets.MagicBurst = {
        neck = "Mizu. Kubikazari" -- MB dmg +10
    }
    -- LINKTRI MODIFICATION END

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
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 = "Ebers Earring +1",
        body = "Theo. Bliaut +4",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "", --Janniston Ring/sea not owned
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "Luminary Sash",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.CureSolace = {
        main = "Raetic Rod +1",
        sub = "Sors Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 = "Ebers Earring +1",
        body = "Ebers Bliaut +3",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Menelaus's Ring",
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "Luminary Sash",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightWeatherCure = {
        main = "Chatoyant Staff",
        sub = "", -- Curatio Grip Nehebkau Abyssea - Misareaux
        ammo = "", --Esper Stone +1 Surged eighth walk
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 ={ name="Nourish. Earring +1", augments={'Path: A',}},
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Lebeche Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightWeatherCureSolace = {
        main = "Chatoyant Staff",
        sub = "", -- Curatio Grip Nehebkau Abyssea - Misareaux
        ammo = "", --Esper Stone +1 Surged eighth walk
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 = "Ebers Earring +1",
        body = "Ebers Bliaut +3",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Lebeche Ring",
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "Hachirin-no-Obi",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightDayCureSolace = {
        main = "Raetic Rod +1",
        sub = "Sors Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 = { name="Nourish. Earring +1", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: was empty (Regal Earring Ou Omen Boss still wanted)
        body = "Ebers Bliaut +3",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Menelaus's Ring",
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "Hachirin-no-Obi",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightDayCure = {
        main = "Raetic Rod +1",
        sub = "Sors Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 ={ name="Nourish. Earring +1", augments={'Path: A',}},
        body = "Theo. Bliaut +4",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Menelaus's Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.Curaga = {
        main = "Raetic Rod +1",
        sub = "Sors Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 = "Ebers Earring +1",
        body = "Theo. Bliaut +4",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Menelaus's Ring",
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "Luminary Sash",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightWeatherCuraga = {
        main = "Chatoyant Staff",
        sub = "", -- Curatio Grip Nehebkau Abyssea - Misareaux
        ammo = "", --Esper Stone +1 Surged eighth walk
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 ={ name="Nourish. Earring +1", augments={'Path: A',}},
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Lebeche Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightDayCuraga = {
        main = "Raetic Rod +1",
        sub = "Sors Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 ={ name="Nourish. Earring +1", augments={'Path: A',}},
        body = "Theo. Bliaut +4",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Menelaus's Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    --Melee Curesets are used whenever your Weapons state is set to anything but None.
    sets.midcast.MeleeCure = {
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 = "Ebers Earring +1",
        body = "Theo. Bliaut +4",
        hands = { name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Lebeche Ring",
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "Luminary Sash",
        legs = "Ebers Pant. +3",
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

    sets.midcast.Cursna = {
        main = "Yagrush",
        sub = "Sors Shield",
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
        legs = "Theo. Pant. +4",
        feet = "Gende. Galosh. +1" -- Cursna+10
    }

    sets.midcast.StatusRemoval = {
        main = "Yagrush",
        sub = "Sors Shield",
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head = "Ebers Cap +3",
        neck = "Voltsurge Torque", -- LINKTRI MOD 2026-07-02: owned (was empty; revert: neck = "")
        ear1 = "", -- Enchntr. Earring +1 needed - Surged  10th walk, AH 15m gil +2 FC
        ear2 = "Malignance Earring",
        body = "Inyanga Jubbah +2",
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1 = "Kishar Ring",
        ring2 = "", --Prolix Ring FC+2 enmity-3 Neith Temple of Uggalepih VW Ops
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}},
        waist = "Witful Belt",
        legs = "Ebers Pant. +3",
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
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
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

    sets.midcast.Auspice = set_combine(sets.midcast["Enhancing Magic"], {feet = "Ebers Duckbills +3",})

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

    sets.midcast.Regen = set_combine(sets.midcast["Enhancing Magic"], {hands = "Ebers Mitts +3", legs = "Theo. Pant. +4"})
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
        {ring2 = "Sheltered Ring", feet = "Theo. Duckbills +4", ear1 = "Gifted Earring", waist = "Sekhmet Corset"}
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
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}},
        waist = "Embla Sash",
        legs = "Piety Panta. +4",
        feet = "Ebers Duckbills +3",
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

    -- LINKTRI MODIFICATION START 2026-07-02: Elemental Magic rebuilt around full Bunzi set
    -- (WHM/RDM/BRD/SMN, verified BG-wiki). Each armor piece: MAB+30, Magic Damage+30, M.Acc+40;
    -- 4pc MB dmg +33. Replaces Witching Robe / Chironic hands+feet and NOT-OWNED Chironic Hose.
    -- Waist also handled dynamically (Orpheus/Hachirin) in job_post_midcast at end of file.
    -- REVERT: see git history / prior file version for the Witching/Chironic layout.
    sets.midcast["Elemental Magic"] = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "", -- Ghastly Tathlum +1 Specter Worm Unity Wanted
        head={ name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Baetyl Pendant",
        ear1 = "", --Friomisi Earring Kumhau Wildskeeper Reive or 1m on AH
        ear2 = "", --Regal Earring Ou Omen Boss
        body={ name="Bunzi's Robe", augments={'Path: A',}},
        hands={ name="Bunzi's Gloves", augments={'Path: A',}},
        ring1 = "", --Shiva Ring +1 Synergy from Shivatear and Rhodium Ring or +1 variant
        ring2 = "", --Freke Ring Odin HTMB
        back = "",  -- Toro Cape +10 MAB +8 INT Kumhau Wildskeeper Reive
        waist = gear.ElementalObi,
        legs={ name="Bunzi's Pants", augments={'Path: A',}},
        feet={ name="Bunzi's Sabots", augments={'Path: A',}}
    }
    -- LINKTRI MODIFICATION END

    -- LINKTRI MODIFICATION START 2026-07-02: Resistant nukes -> Bunzi (M.Acc+40/pc).
    -- C. Palug Crown, Sanctity Necklace, Yamabuki-no-Obi, Chironic Hose NOT in inventory.
    -- REVERT: see git history / prior file version.
    sets.midcast["Elemental Magic"].Resistant = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Erra Pendant",
        ear1 = "Crematio Earring",
        ear2 = "", --Regal Earring Ou Omen Boss
        body={ name="Bunzi's Robe", augments={'Path: A',}},
        hands={ name="Bunzi's Gloves", augments={'Path: A',}},
        ring1 = "Metamor. Ring +1",
        ring2 = "", --Freke Ring Odin HTMB
        back = "",  -- Toro Cape +10 MAB +8 INT Kumhau Wildskeeper Reive
        waist = "Luminary Sash", -- Acuity Belt +1 wanted: Joyous Green Unity
        legs={ name="Bunzi's Pants", augments={'Path: A',}},
        feet={ name="Bunzi's Sabots", augments={'Path: A',}}
    }
    -- LINKTRI MODIFICATION END

    sets.midcast["Divine Magic"] = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Bunzi's Hat", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: C. Palug Crown not in inventory; Bunzi M.Acc+40
        neck = "", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun
        ear1 = "", --Digni. Earring Strophadia Reisenjima
        ear2 = "", --Regal Earring Ou Omen Boss
        body = "Inyanga Jubbah +2",
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1 = "Stikini Ring", -- +1 variant 40m on AH
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back = "Aurist's Cape +1",
        waist = "Luminary Sash",
        legs={ name="Bunzi's Pants", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: Chironic Hose not in inventory
        feet={ name="Bunzi's Sabots", augments={'Path: A',}} -- LINKTRI MOD 2026-07-02: M.Acc+40 > chironic
    }

    -- LINKTRI MODIFICATION START 2026-07-02: Holy -> full Bunzi. Daybreak stays main:
    -- Light elemental affinity +50 multiplies the whole spell (untouchable for Holy/Banish).
    -- C. Palug Crown not in inventory. Waist also handled by Orpheus logic in job_post_midcast.
    -- REVERT: see git history / prior file version.
    sets.midcast.Holy = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Baetyl Pendant",
        ear1 = "", --Friomisi Earring Kumhau Wildskeeper Reive or 1m on AH
        ear2 = "", --Regal Earring Ou Omen Boss
        body={ name="Bunzi's Robe", augments={'Path: A',}},
        hands={ name="Bunzi's Gloves", augments={'Path: A',}},
        ring1 = "Metamor. Ring +1",
        ring2 = "", --Freke Ring Odin HTMB
        back = "",  -- Toro Cape +10 MAB +8 INT Kumhau Wildskeeper Reive
        waist = gear.ElementalObi,
        legs={ name="Bunzi's Pants", augments={'Path: A',}},
        feet={ name="Bunzi's Sabots", augments={'Path: A',}}
    }
    -- LINKTRI MODIFICATION END

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
        waist = "Luminary Sash", -- LINKTRI MOD 2026-07-02: Acuity Belt +1 not in inventory (Joyous Green Unity)
        legs={ name="Bunzi's Pants", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: Chironic Hose not in inventory
        feet={ name="Bunzi's Sabots", augments={'Path: A',}} -- LINKTRI MOD 2026-07-02: M.Acc+40 > chironic
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
        waist = "Fucho-no-Obi",
        legs={ name="Bunzi's Pants", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: Chironic Hose not in inventory
        feet={ name="Bunzi's Sabots", augments={'Path: A',}} -- LINKTRI MOD 2026-07-02: MAB+30/M.Dmg+30 > chironic
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
        waist = "Fucho-no-Obi",
        legs={ name="Bunzi's Pants", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: Chironic Hose not in inventory
        feet={ name="Bunzi's Sabots", augments={'Path: A',}} -- LINKTRI MOD 2026-07-02: MAB+30/M.Dmg+30 > chironic
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
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back = "Aurist's Cape +1",
        waist = "Luminary Sash", -- LINKTRI MOD 2026-07-02: Acuity Belt +1 not in inventory (Joyous Green Unity)
        legs={ name="Bunzi's Pants", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: Chironic Hose not in inventory
        feet={ name="Bunzi's Sabots", augments={'Path: A',}} -- LINKTRI MOD 2026-07-02: M.Acc+40 > chironic
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
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back = "Aurist's Cape +1",
        waist = "Luminary Sash", -- LINKTRI MOD 2026-07-02: Acuity Belt +1 not in inventory (Joyous Green Unity)
        legs={ name="Bunzi's Pants", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: Chironic Hose not in inventory
        feet={ name="Bunzi's Sabots", augments={'Path: A',}} -- LINKTRI MOD 2026-07-02: M.Acc+40 > chironic
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
        waist = "Luminary Sash",
        legs = "Inyanga Shalwar +2", -- LINKTRI MOD 2026-07-02: Chironic Hose not in inventory; Inyanga M.Acc for enfeebles
        feet = "Theo. Duckbills +4"
    }
	-- LINKTRI MODIFICATION START 2026-07-02: Combined SIRD/DT cure system
	-- Design (agreed 2026-07-02):
	--   SIRD mode (Alt+F11): Rosette Jaseran +1 combined set -> SIRD 103% AND DT 57%, BOTH capped.
	--   DT mode  (Alt+F11): Adamantite Armor "beefy" set -> DT ~77% (huge over-cap buffer), MDB+20,
	--     max M.Eva, HP+100; sacrifices SIRD (~23 residual) for when survival outranks everything.
	-- Ebers Pant. +3 is CRITICAL in BOTH sets: "Converts 8% of Cure amount to MP" only works while
	-- equipped at spell completion, i.e. it must be in the midcast set.
	-- Weather/day/Solace variants deliberately share these sets unchanged: swapping to
	-- Hachirin-no-Obi would evict Rumination Sash (SIRD drops 103 -> 93, below the 102 guarantee)
	-- and Solace's Ebers Bliaut body swap would evict Rosette/Adamantite. Guaranteed casts and
	-- survival outrank weather potency / Afflatus Solace bonus in these modes.
	-- Melee* variants use the armor-only tables so TP weapons are never swapped.
	-- REVERT: restore prior Emphatikos Rope SIRD combine + Null Masque/Ebers DT combine family
	-- (see git history / prior file version).

	-- Armor-only (no main/sub), shared by Melee* variants.
	sets.SIRDCureArmor = {
	    ammo = "Staunch Tathlum +1", -- SIRD +11, DT -3
	    head = { name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}}, -- SIRD +12, Cure pot. +11
	    neck = "Loricate Torque +1", -- SIRD +5, DT -6
	    ear1 = "Magnetic Earring", -- SIRD +8
	    ear2 = "Ebers Earring +1", -- DT -5 (plain string per file convention; item augs are System ID, not Path)
	    body = { name="Ros. Jaseran +1", augments={'Path: A',}}, -- SIRD +25, DT -5, Enmity -13
	    hands = "Theo. Mitts +4", -- Cure pot. II +4
	    ring1 = { name="Murky Ring", augments={'Path: A',}}, -- SIRD +3, DT -10
	    ring2 = "Defending Ring", -- DT -10
	    back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, -- DT -5
	    waist = "Rumination Sash", -- SIRD +10
	    legs = "Ebers Pant. +3", -- DT -13, Cure->MP 8% (must stay in midcast)
	    feet = "Theo. Duckbills +4" -- SIRD +29
	}
	-- Totals: SIRD 103 / DT 57. With Raetic Rod +1: Cure pot. I 34, pot. II 14, flat Cure+50.

	sets.DTCureArmor = {
	    ammo = "Staunch Tathlum +1", -- SIRD +11, DT -3
	    head = { name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}}, -- Cure pot. +11
	    neck = "Loricate Torque +1", -- DT -6
	    ear1 = "Alabaster Earring", -- DT -5, HP+100, Haste +5
	    ear2 = "Ebers Earring +1", -- DT -5 (plain string per file convention; item augs are System ID, not Path)
	    body = "Adamantite Armor", -- DT -20, MDB +20, M.Eva +107, HP+182
	    hands = "Theo. Mitts +4", -- Cure pot. II +4
	    ring1 = { name="Murky Ring", augments={'Path: A',}}, -- DT -10
	    ring2 = "Defending Ring", -- DT -10
	    back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, -- DT -5
	    waist = "Carrier's Sash", -- elemental resistance +15
	    legs = "Ebers Pant. +3", -- DT -13, Cure->MP 8% (must stay in midcast)
	    feet = "Theo. Duckbills +4" -- M.Eva +152
	}
	-- Totals: DT ~77 (capped at 50 with buffer), residual SIRD ~23, MDB+20.

	sets.midcast.Cure.SIRD = set_combine(sets.SIRDCureArmor, {main = "Raetic Rod +1", sub = "Sors Shield"})
	sets.midcast.Cure.DT = set_combine(sets.DTCureArmor, {main = "Raetic Rod +1", sub = "Sors Shield"})

	sets.midcast["Enhancing Magic"].SIRD = set_combine(sets.midcast["Enhancing Magic"], {
	    ammo = "Staunch Tathlum +1", -- SIRD +11
	    neck = "Loricate Torque +1", -- SIRD +5
	    ear1 = "Magnetic Earring", -- SIRD +8
	    body = { name="Ros. Jaseran +1", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: SIRD +25
	    waist = "Rumination Sash", -- LINKTRI MOD 2026-07-02: SIRD +10 (Emphatikos Rope not in inventory)
	    feet = "Regal Pumps +1", -- SIRD +4-8
	})

	-- All cure variants -> combined sets (see design note above).
	sets.midcast.CureSolace.SIRD = sets.midcast.Cure.SIRD
	sets.midcast.LightWeatherCure.SIRD = sets.midcast.Cure.SIRD
	sets.midcast.LightWeatherCureSolace.SIRD = sets.midcast.Cure.SIRD
	sets.midcast.LightDayCureSolace.SIRD = sets.midcast.Cure.SIRD
	sets.midcast.LightDayCure.SIRD = sets.midcast.Cure.SIRD
	sets.midcast.Curaga.SIRD = sets.midcast.Cure.SIRD
	sets.midcast.LightWeatherCuraga.SIRD = sets.midcast.Cure.SIRD
	sets.midcast.LightDayCuraga.SIRD = sets.midcast.Cure.SIRD
	sets.midcast.MeleeCure.SIRD = sets.SIRDCureArmor
	sets.midcast.MeleeCureSolace.SIRD = sets.SIRDCureArmor
	sets.midcast.MeleeLightWeatherCure.SIRD = sets.SIRDCureArmor
	sets.midcast.MeleeLightWeatherCureSolace.SIRD = sets.SIRDCureArmor
	sets.midcast.MeleeLightDayCureSolace.SIRD = sets.SIRDCureArmor
	sets.midcast.MeleeLightDayCure.SIRD = sets.SIRDCureArmor
	sets.midcast.MeleeCuraga.SIRD = sets.SIRDCureArmor
	sets.midcast.MeleeLightWeatherCuraga.SIRD = sets.SIRDCureArmor
	sets.midcast.MeleeLightDayCuraga.SIRD = sets.SIRDCureArmor

	sets.midcast.CureSolace.DT = sets.midcast.Cure.DT
	sets.midcast.LightWeatherCure.DT = sets.midcast.Cure.DT
	sets.midcast.LightWeatherCureSolace.DT = sets.midcast.Cure.DT
	sets.midcast.LightDayCureSolace.DT = sets.midcast.Cure.DT
	sets.midcast.LightDayCure.DT = sets.midcast.Cure.DT
	sets.midcast.Curaga.DT = sets.midcast.Cure.DT
	sets.midcast.LightWeatherCuraga.DT = sets.midcast.Cure.DT
	sets.midcast.LightDayCuraga.DT = sets.midcast.Cure.DT
	sets.midcast.MeleeCure.DT = sets.DTCureArmor
	sets.midcast.MeleeCureSolace.DT = sets.DTCureArmor
	sets.midcast.MeleeLightWeatherCure.DT = sets.DTCureArmor
	sets.midcast.MeleeLightWeatherCureSolace.DT = sets.DTCureArmor
	sets.midcast.MeleeLightDayCureSolace.DT = sets.DTCureArmor
	sets.midcast.MeleeLightDayCure.DT = sets.DTCureArmor
	sets.midcast.MeleeCuraga.DT = sets.DTCureArmor
	sets.midcast.MeleeLightWeatherCuraga.DT = sets.DTCureArmor
	sets.midcast.MeleeLightDayCuraga.DT = sets.DTCureArmor
	-- LINKTRI MODIFICATION END

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

    -- LINKTRI MOD 2026-07-02: IntEnfeebles waist was Acuity Belt +1 (not in inventory; Joyous Green Unity)
    sets.midcast.IntEnfeebles = set_combine(sets.midcast["Enfeebling Magic"], {waist = "Luminary Sash"})
    sets.midcast.IntEnfeebles.Resistant =
        set_combine(sets.midcast["Enfeebling Magic"].Resistant, {waist = "Luminary Sash"})

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
        waist = "Fucho-no-Obi",
        legs = "Assid. Pants +1",
        feet = gear.chironic_refresh_feet
    }

    -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)
    sets.idle = {
		main = { name="Mpaca's Staff", augments={'Path: A',}}, -- Refresh +2
		sub = "Clerisy Strap +1", -- Oneiros Grip Refresh +1 when MP ≤75%
		ammo = "Staunch Tathlum +1", -- Homiliary Better than Staunch for pure refresh focus
		head = "Null Masque", -- Refresh +1
		neck = "Sibyl Scarf", -- Chrys. Torque Refresh +1 when TP ≥10 (drains 10 TP per tick)
		ear1 = "Etiolation Earring", -- Refresh +1
		ear2 = "Ebers Earring +1",
		body = "Ebers Bliaut +3", -- Refresh +4
		hands = "Inyan. Dastanas +2", -- Refresh +0.5
		ring1 = { name="Murky Ring", augments={'Path: A',}}, -- Skill bonuses
		ring2 = "Inyanga Ring", -- Refresh +1
		back = "Alaunus's Cape",
		waist = "Fucho-no-Obi", -- Refresh +1 when MP <50%
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
        ear2 = "Alabaster Earring", -- LINKTRI MOD 2026-07-02: DT-5, HP+100, Haste+5 (Ethereal Earring not in inventory)
        body = "Adamantite Armor", -- LINKTRI MOD 2026-07-02: DT-20, MDB+20 (was Ebers Bliaut +3; swap back if idle Refresh+4 preferred)
        hands = "Ebers Mitts +3",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring", -- LINKTRI MOD 2026-07-02: DT-10 (was Stikini Ring)
        back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, -- LINKTRI MOD 2026-07-02: DT-5 (Moonlight Cape not in inventory)
        waist = "Carrier's Sash",
        legs = "Assid. Pants +1",
        feet = "Ebers Duckbills +3"
    }

    sets.idle.MDT = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Homiliary",
        head = "Null Masque",
        neck = "Loricate Torque +1", -- LINKTRI MOD 2026-07-02: Warder's Charm +1 not in inventory (Dynamis-D wanted)
        ear1 = "Etiolation Earring",
        ear2 = "Alabaster Earring", -- LINKTRI MOD 2026-07-02: DT-5, HP+100 (Ethereal Earring not in inventory)
        body = "Adamantite Armor", -- LINKTRI MOD 2026-07-02: DT-20, MDB+20, M.Eva+107 (was Nyame Mail)
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring", -- LINKTRI MOD 2026-07-02: DT-10 (Shadow Ring not in inventory)
        back = "Aurist's Cape +1", -- LINKTRI MOD 2026-07-02: M.Eva (Moonlight Cape not in inventory)
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
        ear2 = "Alabaster Earring", -- LINKTRI MOD 2026-07-02: DT-5, HP+100 (Ethereal Earring not in inventory)
        body = "Adamantite Armor", -- LINKTRI MOD 2026-07-02: DT-20 (was Ebers Bliaut +3, which has no DT on the +3)
        hands = "Ebers Mitts +3",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring", -- LINKTRI MOD 2026-07-02: DT-10 (Gelatinous Ring +1 not in inventory)
        back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, -- LINKTRI MOD 2026-07-02: DT-5 (Shadow Mantle not in inventory)
        waist = "Carrier's Sash",
        legs = "Ebers Pant. +3",
        feet = "Ebers Duckbills +3"
    }

    sets.defense.MDT = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1", -- LINKTRI MOD 2026-07-02: Warder's Charm +1 not in inventory (Dynamis-D wanted)
        ear1 = "Etiolation Earring",
        ear2 = "Alabaster Earring", -- LINKTRI MOD 2026-07-02: DT-5, HP+100 (Ethereal Earring not in inventory)
        body = "Adamantite Armor", -- LINKTRI MOD 2026-07-02: DT-20, MDB+20, M.Eva+107 (was Nyame Mail)
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: DT-10 (Shadow Ring not in inventory)
        ring2 = "Defending Ring", -- LINKTRI MOD 2026-07-02: DT-10 (Archon Ring not in inventory)
        back = "Aurist's Cape +1", -- LINKTRI MOD 2026-07-02: M.Eva (Moonlight Cape not in inventory)
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.defense.MEVA = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1", -- LINKTRI MOD 2026-07-02: Warder's Charm +1 not in inventory (Dynamis-D wanted)
        ear1 = "Etiolation Earring",
        ear2 = "Alabaster Earring", -- LINKTRI MOD 2026-07-02: Ethereal Earring not in inventory
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring", -- LINKTRI MOD 2026-07-02: Purity Ring not in inventory
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
        ammo = "Staunch Tathlum +1",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Asperity Necklace",
        ear1 = "Alabaster Earring", -- LINKTRI MOD 2026-07-02: Haste+5, DT-5 (Cessance Earring still wanted: Omega II)
        ear2 = "Brutal Earring",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, -- LINKTRI MOD 2026-07-02: was empty (Moonlight Cape wanted)
        waist = { name="Sailfi Belt +1", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: was empty (Windbuffet Belt +1 wanted)
        legs = { name="Nyame Flanchard", augments={'Path: B',}},
        feet = { name="Nyame Sollerets", augments={'Path: B',}},
    }

    sets.engaged.Acc = {
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head = "Aya. Zucchetto +2",
        neck = "", --Combatant's Torque
        ear1 = "Telos Earring",
        ear2 = "Brutal Earring",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, -- LINKTRI MOD 2026-07-02: was empty (Moonlight Cape wanted)
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
        ear1 = "Telos Earring",
        ear2 = "Suppanomimi",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, -- LINKTRI MOD 2026-07-02: was empty (Moonlight Cape wanted)
        waist = "", --Shetal Stone
        legs = "Aya. Cosciales +2",
        feet = "Aya. Gambieras +2"
    }

    -- Buff sets: Gear that needs to be worn to actively enhance a current player buff.
    sets.buff["Divine Caress"] = {hands = "Ebers Mitts +3", back = "Mending Cape"}

    -- LINKTRI NOTE 2026-07-02: CURE CHEAT -- DORMANT BY DESIGN, do not delete these sets.
    -- Mechanic: precast in max-HP-down gear (sets.HPDown) clamps current HP down; midcast swap
    -- restores max HP, leaving a large artificial deficit; the self-cure heals near-full value,
    -- and Ebers Pant. +3 returns 8% of the healed amount as MP (MP battery).
    -- Status: Sel-Include consumes a 'curecheat' flag (equips sets.HPCure on self-cures, one-shot,
    -- resets after firing) but NOTHING in this setup ever sets it true -- the branch cannot fire.
    -- Blocked on gear: Mephitas's Ring +1 (own NQ only), Zendik Robe, Shedir Seraweels,
    -- Swith Cape +1 all missing, so the HP drop would be too small to matter yet.
    -- FUTURE WIRING PLAN (agreed): a TOGGLE, not permanent -- e.g. state.CureCheat = M(false,
    -- 'Cure Cheat') in user_job_setup, flipped via //gs c toggle CureCheat or a keybind; in a
    -- precast hook, when state.CureCheat is on and the spell is a self-target cure, equip
    -- sets.HPDown and set curecheat = true so Sel's built-in midcast branch takes over.
    -- Clean HPCure/HPDown down to owned items at wiring time.
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
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    -- LINKTRI MODIFICATION START 2026-07-02: Doom stopgap from owned gear.
    -- Base Linktri-Items Doom set references Gishdubar Sash + Eshmun's Ring x2 ("Cursna received")
    -- which are NOT in inventory -- only Nicander's Necklace (+30% Holy Water) was equipping.
    -- Blenmot's Ring +1 x2 = Enhances Holy Water effect +10% each (BG-wiki confirmed), so owned
    -- total = +50% Holy Water doom removal. SHOPPING: Gishdubar Sash, Eshmun's Ring x2 (AH).
    -- REVERT: sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Doom = set_combine(sets.buff.Doom, {
        ring1 = "Blenmot's Ring +1",
        ring2 = "Blenmot's Ring +1"
    })
    -- LINKTRI MODIFICATION END
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

-------------------------------------------------------------------------------------------------------------------
-- LINKTRI MODIFICATION START 2026-07-02: job_post_midcast override (Orpheus's Sash logic)
-- WHM.lua also defines job_post_midcast (Divine Caress + BarElement handling). This gear file
-- loads after WHM.lua, so this definition supersedes it -- same mechanism that lets this file's
-- job_customize_idle_set (Porter Moogle) supersede the WHM.lua version. The base WHM.lua logic
-- is replicated verbatim in the first half below, then Orpheus/Hachirin waist selection is added.
-- Orpheus's Sash: Elemental Affinity +1~15 by distance (<=1.93' = 1.15x total damage; ~1.05x at 7').
-- Applies to ALL elemental damage incl. damaging Divine Magic (Holy/Banish). Beats Hachirin's
-- day/weather term in anything short of double weather. Both items owned.
-- REVERT: delete this entire block; WHM.lua's job_post_midcast takes over again.
-------------------------------------------------------------------------------------------------------------------
LINKTRI_DIVINE_NUKES = S{'Holy', 'Holy II', 'Banish', 'Banish II', 'Banish III', 'Banishga', 'Banishga II'}

function job_post_midcast(spell, spellMap, eventArgs)
    -- Base WHM.lua logic (replicated verbatim -- keep in sync if WHM.lua changes):
    if spellMap == 'StatusRemoval' then
        if state.Buff['Divine Caress'] then
            equip(sets.buff['Divine Caress'])
        end
    elseif spellMap == 'BarElement' then
        if (state.Buff['Light Arts'] or state.Buff['Addendum: White']) and sets.midcast.BarElement and sets.midcast.BarElement.LightArts then
            equip(sets.midcast.BarElement.LightArts)
        end
    end

    -- LINKTRI: Orpheus's Sash / Hachirin-no-Obi selection for damaging magic.
    if spell.action_type == 'Magic' and (spell.skill == 'Elemental Magic' or LINKTRI_DIVINE_NUKES:contains(spell.english)) then
        local double_weather_match = (spell.element == world.weather_element and world.weather_intensity == 2)
        if not double_weather_match and spell.target.distance and spell.target.distance < 5 then
            equip({waist = "Orpheus's Sash"})
        elseif spell.element == world.weather_element or spell.element == world.day_element then
            equip({waist = "Hachirin-no-Obi"})
        end
    end
end
-- LINKTRI MODIFICATION END