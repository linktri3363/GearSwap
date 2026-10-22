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

    -- LINKTRI: sleep-proofing via Sel's built-in WakeUpWeapons (replaces the custom sleep handler).
    -- Stage 2 Lorg Mor's HP drain wakes you; Sel locks sets.WakeUpWeapons on while asleep and releases
    -- it when sleep wears off, without changing your Weapons mode.
    state.WakeUpWeapons:set(true)

    -- LINKTRI (2026-10-22): Divine Seal + Divine Veil makes a status removal (Erase or a -na) AoE for the target's
    -- party. Only matters when Yagrush won't be in your main hand at cast time (Yagrush already makes every
    -- status removal AoE). Modes (//gs c cycle AutoDivineSeal):
    --   Smart  - use Divine Seal only when 2+ party members near the target have an ailment this spell removes
    --   Always - use Divine Seal on every status removal while it's ready
    --   Off    - never
    state.AutoDivineSeal = M{['description'] = 'Auto Divine Seal', 'Smart', 'Always', 'Off'}

    select_default_macro_book()
end

-- Function to customize idle sets based on current modes and conditions
-- LINKTRI: renamed from job_customize_idle_set, which replaced WHM.lua's version. WHM.lua's now runs first
-- (Sublimation Embla Sash; Fucho-no-Obi latent refresh in Normal/Sphere idle only), then this Porter check.
-- Removed: forcing sets.idle.PDT/MDT (Sel already picks the idle set from IdleMode) and the copied
-- Sublimation/latent-refresh logic (which also put Fucho over Carrier's Sash in PDT/MDT idle).
function user_job_customize_idle_set(idleSet)
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
        sub = "Clerisy Strap +1",  -- original: "Oneiros Grip" (not owned)
        ammo = "Homiliary",
        head = "Null Masque",
        neck = "Sibyl Scarf",
        ear1 = "Etiolation Earring",
        ear2 = "Alabaster Earring",  -- original: "Ethereal Earring" (not owned)
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
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, -- LINKTRI: Fast Cast +10% (augment, confirmed in game) vs Baetyl +4%; neither has DT
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

    sets.precast.FC.Cure = set_combine(sets.precast.FC["Healing Magic"], {})  -- original: {feet = "Hygieia Clogs +1"} (not owned; Regal Pumps +1 stays)

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
        head = { name="Bunzi's Hat", augments={'Path: A',}},  -- original: "Aya. Zucchetto +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        neck = "Combatant's Torque",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = { name="Bunzi's Robe", augments={'Path: A',}},  -- original: "Ayanmo Corazza +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        hands = { name="Bunzi's Gloves", augments={'Path: A',}},  -- original: "Aya. Manopolas +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, -- LINKTRI MOD 2026-07-02: Moonlight Cape not in inventory; proper fix = 2nd Alaunus's w/ STR+WSD augments
        waist = "Luminary Sash", -- LINKTRI MOD 2026-07-02: Olseni Belt not in inventory  -- original: { name="Sailfi Belt +1", augments={'Path: A',}} (Sailfi Belt +1 is not WHM-equippable; Luminary MND+10 Acc+10 for Realmrazer)
        legs = { name="Bunzi's Pants", augments={'Path: A',}},  -- original: "Aya. Cosciales +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}  -- original: "Aya. Gambieras +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
    }

    sets.precast.WS.Fodder = {
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head = { name="Bunzi's Hat", augments={'Path: A',}},  -- original: "Aya. Zucchetto +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        neck = "Asperity Necklace",
        ear1 = "Mache Earring +1",  -- original: "Cessance Earring" (not owned)
        ear2 = "Telos Earring",  -- original: "Brutal Earring" (not owned)
        body = { name="Bunzi's Robe", augments={'Path: A',}},  -- original: "Ayanmo Corazza +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        hands = { name="Bunzi's Gloves", augments={'Path: A',}},  -- original: "Aya. Manopolas +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, -- LINKTRI MOD 2026-07-02: Moonlight Cape not in inventory; proper fix = 2nd Alaunus's w/ STR+WSD augments
        waist = "Luminary Sash", -- LINKTRI MOD 2026-07-02: Windbuffet Belt +1 not in inventory  -- original: { name="Sailfi Belt +1", augments={'Path: A',}} (Sailfi Belt +1 is not WHM-equippable)
        legs = { name="Bunzi's Pants", augments={'Path: A',}},  -- original: "Aya. Cosciales +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}  -- original: "Aya. Gambieras +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
    }

    sets.precast.WS.Dagan = {
        ammo = "", -- Ghastly Tathlum +1 Specter Worm Unity Wanted
        head = "Pixie Hairpin +1", -- not in inventory export
        neck = "Sibyl Scarf", -- not in inventory export  -- original: "Sanctity Necklace" (not owned)
        ear1 = "Hoxne Earring", -- LINKTRI MOD 2026-07-02: MR7 all stats +15 (Dagan is MND-modded); was Etiolation Earring
        ear2 = "Moonshade Earring",
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = "Shrieker's Cuffs",  -- original: "Regal Cuffs" (not owned)
        ring1 = "Persis Ring",  -- original: "Mephitas's Ring +1" (not owned)
        ring2 = "Mephitas's Ring",
        back = "Aurist's Cape +1",
        waist = "Luminary Sash",  -- original: "Fotia Belt" (not owned)
        legs = "Nyame Flanchard",
        feet = "Theo. Duckbills +4"
    }

    sets.MaxTP = {ear1 = "Mache Earring +1", ear2 = "Telos Earring"}  -- original: {ear1 = "Cessance Earring", ear2 = "Brutal Earring"} (not owned)
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
    sets.Self_Refresh = {feet = "Inspirited Boots"}  -- original: {back = "Grapevine Cape", waist = "Gishdubar Sash", feet = "Inspirited Boots"} (cape/sash not owned)

    -- Conserve Mp set for spells that don't need anything else, for set_combine.

    sets.ConserveMP = {
        main = gear.grioavolr_fc_staff,
        sub = "Thrace Strap",  -- original: "Umbra Strap" (owned, swapped) Conserve MP+3
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head = "Vanya Hood",
        neck = "Deviant Necklace", -- Incanter's Torque Synergy from Melic, Henic, and Deceivers Torques obtained in Escha Ru'Aun  -- original: "" (blank: Incanter's Torque not owned) Conserve MP+2
        ear1 = "Calamitous Earring",  -- original: "Gifted Earring" (not owned) Conserve MP+4
        ear2 = "Magnetic Earring",  -- original: "Gwati Earring" (owned, swapped) Conserve MP+5 vs +1
        body = "Witching Robe",  -- original: "Vedic Coat" (not owned) Conserve MP+5
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1 = "Kishar Ring",
        ring2 = "Water Ring", --Prolix Ring FC+2 enmity-3 Neith Temple of Uggalepih VW Ops  -- original: "" (blank: Prolix Ring not owned) Conserve MP+15
        back = "Thauma. Cape",  -- original: "Solemnity Cape" (not owned) Conserve MP+4
        waist = "Luminary Sash",  -- original: "Austerity Belt +1" (not owned) Conserve MP+4
        legs = "Lengo Pants",  -- original: "Vanya Slops" (not owned) Conserve MP+5
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}  -- original: "Medium's Sabots" (owned, swapped) Conserve MP+7 vs Medium's
    }

    sets.midcast.Teleport = sets.ConserveMP

    -- Gear for Magic Burst mode.
    -- LINKTRI MODIFICATION START 2026-07-02: MagicBurst overlay
    -- Removed main/sub: Daybreak (MAB+40, M.Dmg+241) from the base nuke set beats the Grioavolr
    -- swap (MAB+26). Mujin Band / Locus Ring are NOT in inventory (Mujin Band = cheap Ambuscade
    -- pickup). MB dmg I gear cap (+40) already reached: Bunzi 4pc (+33) + Mizuchi (+10).
    -- REVERT: main=gear.grioavolr_nuke_staff, sub="Enki Strap", ring1="Mujin Band", ring2="Locus Ring"
    sets.MagicBurst = {
        neck = "Sibyl Scarf" -- MB dmg +10  -- original: "Mizu. Kubikazari" (owned, swapped: 5 Bunzi pieces = MB dmg +40 cap already; Sibyl INT+10 MAB+10 counts, Mizuchi's MB+10 did not)
    }
    -- LINKTRI MODIFICATION END

    sets.midcast.FastRecast = {
        main = gear.grioavolr_fc_staff,
        sub = "Clerisy Strap +1",
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head={ name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Voltsurge Torque",
        ear1 = "Etiolation Earring", -- Enchntr. Earring +1 needed - Surged  10th walk, AH 15m gil +2 FC  -- original: "" (blank)
        ear2 = "Malignance Earring",
        body = "Inyanga Jubbah +2",
        hands = { name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},  -- original: "Gende. Gages +1" (not owned) -- Fanatic Gloves FC+5
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring", --Prolix Ring FC+2 enmity-3 Neith Temple of Uggalepih VW Ops  -- original: "" (blank)
        back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}},  -- original: "Swith Cape +1" (not owned) -- Alaunus's FC+10
        waist = "Witful Belt",
        legs = "Lengo Pants",
        feet={ name="Regal Pumps +1", augments={'Path: A',}},
    }

    -- Cure sets

    sets.midcast["Full Cure"] = sets.midcast.FastRecast

    sets.midcast.Cure = {
        main = "Raetic Rod +1",
        sub = "Genmei Shield",  -- original: "Sors Shield" (owned, swapped: Cure potency I was ~64% vs the 50% cap; still ~51% without it) -- Genmei DT-10%
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Loricate Torque +1", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")  -- original: { name="Clr. Torque +2", augments={'Path: A',}} (owned, swapped: Cure potency I was ~64% vs the 50% cap; still ~51% without it) -- Loricate DT-6%
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 = "Ebers Earring +1",
        body = "Theo. Bliaut +4",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring", --Janniston Ring/sea not owned  -- original: "" (blank: Janniston Ring not owned)
        back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, --needs ambu curing back
        waist = "Luminary Sash",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.CureSolace = {
        main = "Raetic Rod +1",
        sub = "Genmei Shield",  -- original: "Sors Shield" (owned, swapped: Cure potency I was ~64% vs the 50% cap; still ~51% without it) -- Genmei DT-10%
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Loricate Torque +1", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")  -- original: { name="Clr. Torque +2", augments={'Path: A',}} (owned, swapped: Cure potency I was ~64% vs the 50% cap; still ~51% without it) -- Loricate DT-6%
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
        sub = "Enki Strap", -- Curatio Grip Nehebkau Abyssea - Misareaux  -- original: "" (blank: Curatio Grip not owned)
        ammo = "Pemphredo Tathlum", --Esper Stone +1 Surged eighth walk  -- original: "" (blank: Esper Stone +1 not owned)
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 ={ name="Nourish. Earring +1", augments={'Path: A',}},
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Lebeche Ring",
        back = "Twilight Cape",         -- LINKTRI: original: Alaunus's Cape. Twilight Cape now owned: enhances the day/weather bonus
        waist = "Hachirin-no-Obi",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightWeatherCureSolace = {
        main = "Chatoyant Staff",
        sub = "Enki Strap", -- Curatio Grip Nehebkau Abyssea - Misareaux  -- original: "" (blank: Curatio Grip not owned)
        ammo = "Pemphredo Tathlum", --Esper Stone +1 Surged eighth walk  -- original: "" (blank: Esper Stone +1 not owned)
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 = "Ebers Earring +1",
        body = "Ebers Bliaut +3",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Lebeche Ring",
        back = "Twilight Cape",         -- LINKTRI: original: Alaunus's Cape. Twilight Cape now owned: enhances the day/weather bonus
        waist = "Hachirin-no-Obi",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightDayCureSolace = {
        main = "Raetic Rod +1",
        sub = "Genmei Shield",  -- original: "Sors Shield" (owned, swapped: Cure potency I was ~64% vs the 50% cap; still ~51% without it) -- Genmei DT-10%
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Loricate Torque +1", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")  -- original: { name="Clr. Torque +2", augments={'Path: A',}} (owned, swapped: Cure potency I was ~64% vs the 50% cap; still ~51% without it) -- Loricate DT-6%
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 = { name="Nourish. Earring +1", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: was empty (Regal Earring Ou Omen Boss still wanted)
        body = "Ebers Bliaut +3",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Menelaus's Ring",
        back = "Twilight Cape",         -- LINKTRI: original: Alaunus's Cape. Twilight Cape now owned: enhances the day/weather bonus
        waist = "Hachirin-no-Obi",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightDayCure = {
        main = "Raetic Rod +1",
        sub = "Genmei Shield",  -- original: "Sors Shield" (owned, swapped: Cure potency I was ~64% vs the 50% cap; still ~51% without it) -- Genmei DT-10%
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Loricate Torque +1", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")  -- original: { name="Clr. Torque +2", augments={'Path: A',}} (owned, swapped: Cure potency I was ~64% vs the 50% cap; still ~51% without it) -- Loricate DT-6%
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 ={ name="Nourish. Earring +1", augments={'Path: A',}},
        body = "Theo. Bliaut +4",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Menelaus's Ring",
        back = "Twilight Cape",         -- LINKTRI: original: Alaunus's Cape. Twilight Cape now owned: enhances the day/weather bonus
        waist = "Hachirin-no-Obi",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.Curaga = {
        main = "Raetic Rod +1",
        sub = "Genmei Shield",  -- original: "Sors Shield" (owned, swapped: Cure potency I was ~64% vs the 50% cap; still ~51% without it) -- Genmei DT-10%
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Loricate Torque +1", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")  -- original: { name="Clr. Torque +2", augments={'Path: A',}} (owned, swapped: Cure potency I was ~64% vs the 50% cap; still ~51% without it) -- Loricate DT-6%
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
        sub = "Enki Strap", -- Curatio Grip Nehebkau Abyssea - Misareaux  -- original: "" (blank: Curatio Grip not owned)
        ammo = "Pemphredo Tathlum", --Esper Stone +1 Surged eighth walk  -- original: "" (blank: Esper Stone +1 not owned)
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Clr. Torque +2", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 ={ name="Nourish. Earring +1", augments={'Path: A',}},
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Lebeche Ring",
        back = "Twilight Cape",         -- LINKTRI: original: Alaunus's Cape. Twilight Cape now owned: enhances the day/weather bonus
        waist = "Hachirin-no-Obi",
        legs = "Ebers Pant. +3",
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightDayCuraga = {
        main = "Raetic Rod +1",
        sub = "Genmei Shield",  -- original: "Sors Shield" (owned, swapped: Cure potency I was ~64% vs the 50% cap; still ~51% without it) -- Genmei DT-10%
        ammo = "Pemphredo Tathlum",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = { name="Loricate Torque +1", augments={'Path: A',}}, -- LINKTRI MOD 2026-07-02: "Cure" potency +10% (was empty awaiting Incanter's Torque; revert: neck = "")  -- original: { name="Clr. Torque +2", augments={'Path: A',}} (owned, swapped: Cure potency I was ~64% vs the 50% cap; still ~51% without it) -- Loricate DT-6%
        ear1 = "Glorious Earring", -- LINKTRI MOD 2026-07-02: Cure pot. II +2%, MP+30, Enmity-5 (now owned; revert: ear1 = "")
        ear2 ={ name="Nourish. Earring +1", augments={'Path: A',}},
        body = "Theo. Bliaut +4",
        hands = "Theo. Mitts +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Menelaus's Ring",
        back = "Twilight Cape",         -- LINKTRI: original: Alaunus's Cape. Twilight Cape now owned: enhances the day/weather bonus
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
    sets.midcast.MeleeLightWeatherCure = set_combine(sets.midcast.MeleeCure, {waist = "Hachirin-no-Obi", back = "Twilight Cape"})
    sets.midcast.MeleeLightWeatherCureSolace =
        set_combine(sets.midcast.MeleeCure, {body = "Ebers Bliaut +3", waist = "Hachirin-no-Obi", back = "Twilight Cape"})
    sets.midcast.MeleeLightDayCureSolace =
        set_combine(sets.midcast.MeleeCure, {body = "Ebers Bliaut +3", waist = "Hachirin-no-Obi", back = "Twilight Cape"})
    sets.midcast.MeleeLightDayCure = set_combine(sets.midcast.MeleeCure, {waist = "Hachirin-no-Obi", back = "Twilight Cape"})
    sets.midcast.MeleeCuraga = set_combine(sets.midcast.MeleeCure, {})
    sets.midcast.MeleeLightWeatherCuraga = set_combine(sets.midcast.MeleeCure, {waist = "Hachirin-no-Obi", back = "Twilight Cape"})
    sets.midcast.MeleeLightDayCuraga = set_combine(sets.midcast.MeleeCure, {waist = "Hachirin-no-Obi", back = "Twilight Cape"})

    sets.midcast.Cursna = {
        main = "Yagrush",
        sub = "Sors Shield",
        ammo = "", --Hasty Pinion +1 needs to be evalated for appropriateness
        head = "Ebers Cap +3",
        neck = "Loricate Torque +1", -- LINKTRI: blank neck was skipped by GearSwap (neck never swapped). No owned Cursna neck (Debilis Medallion unowned); DT-6% while casting
        ear1 = "Meili Earring",
        ear2 = "Malignance Earring",
        body = "Ebers Bliaut +3",
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1 = "Stikini Ring", -- Haoma's Ring 2m on AH  -- original: "" (blank: Haoma's Ring not owned)
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
        ear1 = "Etiolation Earring", -- Enchntr. Earring +1 needed - Surged  10th walk, AH 15m gil +2 FC  -- original: "" (blank)
        ear2 = "Malignance Earring",
        body = "Inyanga Jubbah +2",
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring", --Prolix Ring FC+2 enmity-3 Neith Temple of Uggalepih VW Ops  -- original: "" (blank)
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
        neck = "Loricate Torque +1", -- LINKTRI: blank neck was skipped by GearSwap; no owned enhancing neck (Incanter's Torque unowned), so DT-6%/SIRD while casting
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
        {neck = "Nodens Gorget", waist = "Siegel Sash"}  -- original also had ear2 = "Earthcry Earring", legs = "Shedir Seraweels" (not owned)
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

    sets.midcast.Regen = set_combine(sets.midcast["Enhancing Magic"], {hands = "Ebers Mitts +3", legs = "Theo. Pant. +4", feet = { name="Bunzi's Sabots", augments={'Path: A',}}})  -- LINKTRI 2026-10-18: Bunzi's Sabots R30 "Regen" potency +10 (was Theo. Duckbills +4 from the base set)
-- Sekhmet Corset AA MR II or DM II 
-- Sheltered Ring Bhishani South Gustaberg Voidwatch Op
    sets.midcast.Protect =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {feet = "Theo. Duckbills +4"}  -- original also had ring2 = "Sheltered Ring", ear1 = "Gifted Earring", waist = "Sekhmet Corset" (not owned)
    )
    sets.midcast.Protectra =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {feet = "Theo. Duckbills +4"}  -- original also had ring2 = "Sheltered Ring", ear1 = "Gifted Earring", waist = "Sekhmet Corset" (not owned)
    )
    sets.midcast.Shell =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {feet = "Theo. Duckbills +4"}  -- original also had ring2 = "Sheltered Ring", ear1 = "Gifted Earring", waist = "Sekhmet Corset" (not owned)
    )
    sets.midcast.Shellra =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {feet = "Theo. Duckbills +4"}  -- original also had ring2 = "Sheltered Ring", ear1 = "Gifted Earring", waist = "Sekhmet Corset" (not owned)
    )

    sets.midcast.BarElement = {
        main = "Beneficus",
        sub = "Ammurapi Shield",
        ammo = "Staunch Tathlum +1",
        head = "Ebers Cap +3",
        neck = "Loricate Torque +1", -- LINKTRI: blank neck was skipped by GearSwap; no owned enhancing neck, so DT-6%/SIRD while casting
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

    -- LINKTRI: filled the blank ("") slots, which left fast cast gear on during the midcast. Twilight Cloak now owned.
    sets.midcast.Impact = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = empty,
        neck = "Erra Pendant",
        ear1 = "Psystorm Earring",
        ear2 = "Malignance Earring",
        body = "Twilight Cloak",
        hands = gear.chironic_enfeeble_hands,
        ring1 ={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back = "Aurist's Cape +1",
        waist = "Sacro Cord",
        legs = { name="Bunzi's Pants", augments={'Path: A',}},
        feet = gear.chironic_nuke_feet
    }

    -- LINKTRI MODIFICATION START 2026-07-02: Elemental Magic rebuilt around full Bunzi set
    -- (WHM/RDM/BRD/SMN, verified BG-wiki). Each armor piece: MAB+30, Magic Damage+30, M.Acc+40;
    -- 4pc MB dmg +33. Replaces Witching Robe / Chironic hands+feet and NOT-OWNED Chironic Hose.
    -- Waist also handled dynamically (Orpheus/Hachirin) in job_post_midcast at end of file.
    -- REVERT: see git history / prior file version for the Witching/Chironic layout.
    sets.midcast["Elemental Magic"] = {
        main = "Bunzi's Rod",  -- original: "Daybreak" (owned, swapped: Bunzi's Rod MAB+65 w/ augment vs Daybreak +40; Daybreak kept for Holy/Banish)
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum", -- Ghastly Tathlum +1 Specter Worm Unity Wanted  -- original: "" (blank: Ghastly Tathlum +1 not owned)
        head={ name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Baetyl Pendant",
        ear1 = "Crematio Earring", --Regal Earring Ou Omen Boss  -- original: "" (blank: Regal Earring not owned) -- LINKTRI: sides swapped so Malignance keeps ear2
        ear2 = "Malignance Earring", --Friomisi Earring Kumhau Wildskeeper Reive or 1m on AH  -- original: "" (blank: Friomisi Earring not owned)
        body={ name="Bunzi's Robe", augments={'Path: A',}},
        hands={ name="Bunzi's Gloves", augments={'Path: A',}},
        ring1 = "Metamor. Ring +1", --Shiva Ring +1 Synergy from Shivatear and Rhodium Ring or +1 variant  -- original: "" (blank: Shiva Ring +1 not owned)
        ring2 = "Persis Ring", --Freke Ring Odin HTMB  -- original: "" (blank: Freke Ring not owned)
        back = "Aurist's Cape +1",  -- Toro Cape +10 MAB +8 INT Kumhau Wildskeeper Reive  -- original: "" (blank: Toro Cape not owned)
        waist = "Sacro Cord",           -- LINKTRI: original: gear.ElementalObi (empty name in Sel, so the precast waist stayed). Neutral default; overlay picks Orpheus/Hachirin when they pay
        legs={ name="Bunzi's Pants", augments={'Path: A',}},
        feet={ name="Bunzi's Sabots", augments={'Path: A',}}
    }
    -- LINKTRI MODIFICATION END

    -- LINKTRI MODIFICATION START 2026-07-02: Resistant nukes -> Bunzi (M.Acc+40/pc).
    -- C. Palug Crown, Sanctity Necklace, Yamabuki-no-Obi, Chironic Hose NOT in inventory.
    -- REVERT: see git history / prior file version.
    sets.midcast["Elemental Magic"].Resistant = {
        main = "Bunzi's Rod",  -- original: "Daybreak" (owned, swapped: Bunzi's Rod MAcc+55 w/ augment)
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head={ name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Erra Pendant",
        ear1 = "Crematio Earring", --Regal Earring Ou Omen Boss  -- original: "" (blank: Regal Earring not owned) -- LINKTRI: sides swapped so Malignance keeps ear2
        ear2 = "Malignance Earring",
        body={ name="Bunzi's Robe", augments={'Path: A',}},
        hands={ name="Bunzi's Gloves", augments={'Path: A',}},
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring", --Freke Ring Odin HTMB  -- original: "" (blank: Freke Ring not owned)
        back = "Aurist's Cape +1",  -- Toro Cape +10 MAB +8 INT Kumhau Wildskeeper Reive  -- original: "" (blank: Toro Cape not owned)
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
        neck = "Null Loop", -- LINKTRI: blank neck was skipped by GearSwap; MAcc+50 for Repose/Flash/Banish landing (Holy keeps Baetyl Pendant)
        ear1 = "Psystorm Earring", --Regal Earring Ou Omen Boss  -- original: "" (blank: Regal Earring not owned) -- LINKTRI: sides swapped so Malignance keeps ear2
        ear2 = "Malignance Earring", --Digni. Earring Strophadia Reisenjima  -- original: "" (blank)
        body = "Theo. Bliaut +4",  -- original: "Inyanga Jubbah +2" (owned, swapped: MAcc+60 vs +46)
        hands="Theo. Mitts +4",  -- original: { name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}} (owned, swapped: MAcc+58)
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
        ear1 = "Crematio Earring", --Regal Earring Ou Omen Boss  -- original: "" (blank: Regal Earring not owned) -- LINKTRI: sides swapped so Malignance keeps ear2
        ear2 = "Malignance Earring", --Friomisi Earring Kumhau Wildskeeper Reive or 1m on AH  -- original: "" (blank: Friomisi Earring not owned)
        body={ name="Bunzi's Robe", augments={'Path: A',}},
        hands={ name="Bunzi's Gloves", augments={'Path: A',}},
        ring1 = "Metamor. Ring +1",
        ring2 = "Persis Ring", --Freke Ring Odin HTMB  -- original: "" (blank: Freke Ring not owned)
        back = "Aurist's Cape +1",  -- Toro Cape +10 MAB +8 INT Kumhau Wildskeeper Reive  -- original: "" (blank: Toro Cape not owned)
        waist = "Sacro Cord",           -- LINKTRI: original: gear.ElementalObi (empty name in Sel, so the precast waist stayed). Neutral default; overlay picks Orpheus/Hachirin when they pay
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
        ear1 = "Psystorm Earring", --Regal Earring Ou Omen Boss  -- original: "" (blank: Regal Earring not owned) -- LINKTRI: sides swapped so Malignance keeps ear2
        ear2 = "Malignance Earring", --Digni. Earring Strophadia Reisenjima  -- original: "" (blank)
        body = "Theo. Bliaut +4",  -- original: "Inyanga Jubbah +2" (owned, swapped: MAcc+60 vs +46)
        hands = "Theo. Mitts +4",  -- original: gear.chironic_enfeeble_hands (owned, swapped: MAcc+58)
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
        ear1 = "Psystorm Earring", --Regal Earring Ou Omen Boss  -- original: "" (blank) -- LINKTRI: sides swapped so Malignance keeps ear2
        ear2 = "Malignance Earring", --Digni. Earring Strophadia Reisenjima  -- original: "" (blank)
        body = "Inyanga Jubbah +2",
        hands = gear.chironic_enfeeble_hands,
        ring1 = "Stikini Ring",  -- original: "Evanescence Ring" (not owned)
        ring2 = "Stikini Ring",  -- original: "Archon Ring" (not owned)
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
        ear1 = "Psystorm Earring", --Regal Earring Ou Omen Boss  -- original: "" (blank) -- LINKTRI: sides swapped so Malignance keeps ear2
        ear2 = "Malignance Earring", --Digni. Earring Strophadia Reisenjima  -- original: "" (blank)
        body = { name="Bunzi's Robe", augments={'Path: A',}},  -- original: "Chironic Doublet" (not owned)
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
        ear1 = "Etiolation Earring", -- Enchntr. Earring +1 needed - Surged  10th walk, AH 15m gil +2 FC  -- original: "" (blank)
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
        ear1 = "Psystorm Earring", --Regal Earring Ou Omen Boss  -- original: "" (blank: Regal Earring not owned) -- LINKTRI: sides swapped so Malignance keeps ear2
        ear2 = "Malignance Earring", --Digni. Earring Strophadia Reisenjima  -- original: "" (blank)
        body = "Theo. Bliaut +4",  -- original: "Inyanga Jubbah +2" (owned, swapped: MAcc+60 vs +46)
        hands="Theo. Mitts +4",  -- original: { name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}} (owned, swapped: MAcc+58)
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
        ear1 = "Psystorm Earring", --Regal Earring Ou Omen Boss  -- original: "" (blank: Regal Earring not owned) -- LINKTRI: sides swapped so Malignance keeps ear2
        ear2 = "Malignance Earring", --Digni. Earring Strophadia Reisenjima  -- original: "" (blank)
        body = "Theo. Bliaut +4",  -- original: "Inyanga Jubbah +2" (owned, swapped: MAcc+60 vs +46)
        hands="Theo. Mitts +4",  -- original: { name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}} (owned, swapped: MAcc+58)
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
        ear1 = "Psystorm Earring", --Regal Earring Ou Omen Boss  -- original: "" (blank) -- LINKTRI: sides swapped so Malignance keeps ear2
        ear2 = "Malignance Earring", --Digni. Earring Strophadia Reisenjima  -- original: "" (blank)
        body = "Theo. Bliaut +4",
        hands = "Piety Mitts +4",  -- original: { name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}} (owned, swapped: Enfeebling skill +27, MAcc+43; Telchine had none)
        ring1 = "Kishar Ring",
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back = "Aurist's Cape +1",
        waist = "Obstin. Sash",
        legs = "Theo. Pant. +4",  -- original: { name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}} (owned, swapped: MAcc+59; Telchine had none)
        feet = "Theo. Duckbills +4"
    }

    sets.midcast["Enfeebling Magic"].Resistant = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Befouled Crown",
        neck = "Erra Pendant",
        ear1 = "Psystorm Earring", --Regal Earring Ou Omen Boss  -- original: "" (blank) -- LINKTRI: sides swapped so Malignance keeps ear2
        ear2 = "Malignance Earring", --Digni. Earring Strophadia Reisenjima  -- original: "" (blank)
        body = "Theo. Bliaut +4",
        hands = "Theo. Mitts +4",
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring", -- +1 variant 40m on AH
        back = "Aurist's Cape +1",
        waist = "Luminary Sash",
        legs = "Theo. Pant. +4", -- LINKTRI MOD 2026-07-02: Chironic Hose not in inventory; Inyanga M.Acc for enfeebles  -- original: "Inyanga Shalwar +2" (owned, swapped: MAcc+59 vs +45)
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
        sub = "Clerisy Strap +1",  -- original: "Oneiros Grip" (not owned)
        ammo = "Homiliary",
        head = "Null Masque",
        neck = "Sibyl Scarf",  -- original: "Chrys. Torque" (not owned) Sibyl Refresh+1
        ear1 = "Etiolation Earring",
        ear2 = "Alabaster Earring",  -- original: "Ethereal Earring" (not owned)
        body = "Ebers Bliaut +3",
        hands = "Inyan. Dastanas +2",  -- original: gear.chironic_refresh_hands (not owned)
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Inyanga Ring",  -- original: "Dark Ring" (not owned)
        back = "Alaunus's Cape",  -- original: "Umbra Cape" (not owned)
        waist = "Fucho-no-Obi",
        legs = "Assid. Pants +1",
        feet = "Inyan. Crackows +2"  -- original: gear.chironic_refresh_feet (not owned)
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
        ring1 = "Vengeful Ring",        -- LINKTRI: sides swapped so Defending keeps ring2
        ring2 = "Defending Ring", -- LINKTRI MOD 2026-07-02: Purity Ring not in inventory
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
        head = { name="Bunzi's Hat", augments={'Path: A',}},  -- original: { name="Nyame Helm", augments={'Path: B',}} (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        neck = "Asperity Necklace",
        ear1 = "Alabaster Earring", -- LINKTRI MOD 2026-07-02: Haste+5, DT-5 (Cessance Earring still wanted: Omega II)
        ear2 = "Telos Earring",  -- original: "Brutal Earring" (not owned)
        body = { name="Bunzi's Robe", augments={'Path: A',}},  -- original: { name="Nyame Mail", augments={'Path: B',}} (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        hands = { name="Bunzi's Gloves", augments={'Path: A',}},  -- original: { name="Nyame Gauntlets", augments={'Path: B',}} (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, -- LINKTRI MOD 2026-07-02: was empty (Moonlight Cape wanted)
        waist = "Null Belt", -- LINKTRI MOD 2026-07-02: was empty (Windbuffet Belt +1 wanted)  -- original: { name="Sailfi Belt +1", augments={'Path: A',}} (Sailfi Belt +1 is not WHM-equippable)
        legs = { name="Bunzi's Pants", augments={'Path: A',}},  -- original: { name="Nyame Flanchard", augments={'Path: B',}} (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        feet = { name="Bunzi's Sabots", augments={'Path: A',}},  -- original: { name="Nyame Sollerets", augments={'Path: B',}} (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
    }

    sets.engaged.Acc = {
        ammo = "Amar Cluster", --Hasty Pinion +1 needs to be evalated for appropriateness  -- original: "" (blank: slot was never swapped)
        head = { name="Bunzi's Hat", augments={'Path: A',}},  -- original: "Aya. Zucchetto +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        neck = "Combatant's Torque", -- LINKTRI: was blank (skipped by GearSwap); owned - combat skills +15, Store TP+4
        ear1 = "Telos Earring",
        ear2 = "Crep. Earring",  -- original: "Brutal Earring" (not owned)
        body = { name="Bunzi's Robe", augments={'Path: A',}},  -- original: "Ayanmo Corazza +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        hands = { name="Bunzi's Gloves", augments={'Path: A',}},  -- original: "Aya. Manopolas +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, -- LINKTRI MOD 2026-07-02: was empty (Moonlight Cape wanted)
        waist = "Null Belt", --Olseni Belt  -- original: "" (blank: Olseni Belt not owned)
        legs = { name="Bunzi's Pants", augments={'Path: A',}},  -- original: "Aya. Cosciales +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}  -- original: "Aya. Gambieras +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
    }

    sets.engaged.DW = {
        ammo = "Crepuscular Pebble",
        head = { name="Bunzi's Hat", augments={'Path: A',}},  -- original: "Nyame Helm" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        neck = "Null Loop",
        ear1 = "Mache Earring +1",       -- LINKTRI: original: Moonshade Earring (TP Bonus does nothing while meleeing)
        ear2 = "Suppanomimi",
        body = { name="Bunzi's Robe", augments={'Path: A',}},  -- original: "Nyame Mail" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        hands = { name="Bunzi's Gloves", augments={'Path: A',}},  -- original: "Nyame Gauntlets" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = "Penetrating Cape",
        waist = "Null Belt",
        legs = { name="Bunzi's Pants", augments={'Path: A',}},  -- original: "Nyame Flanchard" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}  -- original: "Nyame Sollerets" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
    }

    sets.engaged.DW.Acc = {
        ammo = "Amar Cluster", --Hasty Pinion +1 needs to be evalated for appropriateness  -- original: "" (blank: slot was never swapped)
        head = { name="Bunzi's Hat", augments={'Path: A',}},  -- original: "Aya. Zucchetto +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        neck = "Combatant's Torque", -- LINKTRI: was blank (skipped by GearSwap); owned - combat skills +15, Store TP+4
        ear1 = "Telos Earring",
        ear2 = "Suppanomimi",
        body = { name="Bunzi's Robe", augments={'Path: A',}},  -- original: "Ayanmo Corazza +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        hands = { name="Bunzi's Gloves", augments={'Path: A',}},  -- original: "Aya. Manopolas +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}, -- LINKTRI MOD 2026-07-02: was empty (Moonlight Cape wanted)
        waist = "Null Belt", --Shetal Stone  -- original: "" (blank: Shetal Stone not owned)
        legs = { name="Bunzi's Pants", augments={'Path: A',}},  -- original: "Aya. Cosciales +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}  -- original: "Aya. Gambieras +2" (owned, swapped: Bunzi R30 Acc+55/Atk+70 per piece)
    }

    -- Buff sets: Gear that needs to be worn to actively enhance a current player buff.
    sets.buff["Divine Caress"] = {hands = "Ebers Mitts +3", back = "Mending Cape"}

    -- LINKTRI: Sel equips and locks this while you're asleep (state.WakeUpWeapons), releasing it on wake.
    sets.WakeUpWeapons = {main = "Lorg Mor"}

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
-- LINKTRI (2026-10-22): Divine Seal + Divine Veil for status removal, ported from Linktri_Geo_Gear.lua (same Smart
-- logic and party-buff tracking). WHM-specific: skipped when Yagrush will be in your main hand at cast time,
-- since Yagrush already makes every status removal AoE. WHM.lua's Auto Divine Caress runs first (job_precast);
-- this runs after it, so with both ready you get Divine Caress, then Divine Seal, then the spell.
-- Divine Seal recast id 26. Esuna and Sacrifice are never sealed.
local DIVINE_VEIL_RADIUS = 10   -- yalms around the target; "small radius" per BG-Wiki, adjust if needed

-- Buff IDs each spell removes (Windower resources; the 5xx IDs are the newer variants of the same ailments).
local REMOVAL_DEBUFFS = {
    ['Poisona']  = S{3, 540},
    ['Paralyna'] = S{4, 566},
    ['Blindna']  = S{5},
    ['Silena']   = S{6},
    ['Stona']    = S{7},
    ['Viruna']   = S{8, 31},
    ['Cursna']   = S{9, 20, 15, 30},     -- curse, curse, doom, bane
    ['Erase']    = S{11, 12, 13, 21, 23, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141,
                     142, 144, 145, 146, 147, 148, 149, 156, 167, 168, 174, 175, 186, 189, 192, 194, 217, 223,
                     404, 557, 558, 559, 560, 561, 562, 563, 564, 565, 567},
}

-- [player id] = S{buff ids}, refreshed from 0x076. Byte layout per entry (48 bytes, 5 entries): ID at +0,
-- 2-bit high parts of each buff ID at +8 (8 bytes), low bytes at +16 (32 bytes); 255 = empty slot.
-- (Same decoding as the PartyBuffs addon / GearSwap.)
local party_member_buffs = {}

windower.raw_register_event('incoming chunk', function(id, data)
    if id ~= 0x076 then return end
    for k = 0, 4 do
        local base = k * 48 + 5
        local uid = data:unpack('I', base)
        if uid and uid ~= 0 then
            local buffs = S{}
            for i = 1, 32 do
                local low = data:byte(base + 16 + i - 1)
                local high = math.floor(data:byte(base + 8 + math.floor((i - 1) / 4)) / 4 ^ ((i - 1) % 4)) % 4
                local buff = low + 256 * high
                if buff ~= 255 then buffs[buff] = true end
            end
            party_member_buffs[uid] = buffs
        end
    end
end)

windower.raw_register_event('zone change', function()
    party_member_buffs = {}
end)

local function has_any(buff_list, wanted)
    for b in pairs(buff_list) do
        if wanted:contains(b) then return true end
    end
    return false
end

-- Number of party members (you included) near the target who have an ailment this spell removes,
-- or nil when the target isn't in your party (no buff data for it).
local function divine_veil_count(spell)
    local wanted = REMOVAL_DEBUFFS[spell.english]
    if not wanted then return nil end
    local target = spell.target and spell.target.id and windower.ffxi.get_mob_by_id(spell.target.id)
    if not target then return nil end

    local party = windower.ffxi.get_party()
    local in_party = false
    for _, key in ipairs({'p0', 'p1', 'p2', 'p3', 'p4', 'p5'}) do
        local m = party[key]
        if m and m.mob and m.mob.id == target.id then in_party = true end
    end
    if not in_party then return nil end

    local count = 0
    for _, key in ipairs({'p0', 'p1', 'p2', 'p3', 'p4', 'p5'}) do
        local m = party[key]
        local mob = m and m.mob
        if mob then
            local buffs
            if key == 'p0' then
                buffs = S(player.buffs or {})
            else
                buffs = party_member_buffs[mob.id]
            end
            local dx, dy = (mob.x or 0) - (target.x or 0), (mob.y or 0) - (target.y or 0)
            local near = math.sqrt(dx * dx + dy * dy) <= DIVINE_VEIL_RADIUS
            if buffs and near and has_any(buffs, wanted) then
                count = count + 1
            end
        end
    end
    return count
end

-- True when Yagrush will be the main weapon when the spell lands: with weapons unlocked (Weapons None or
-- UnlockWeapons) the midcast set's main applies, otherwise whatever you're holding now.
local function yagrush_at_cast(spell, spellMap)
    local main
    if state.Weapons.value == 'None' or state.UnlockWeapons.value then
        local set = sets.midcast[spell.english] or sets.midcast[spellMap]
        main = set and set.main
    else
        main = player.equipment.main
    end
    if type(main) == 'table' then main = main.name end
    return main == 'Yagrush'
end

function user_job_precast(spell, spellMap, eventArgs)
    if spell.action_type == 'Magic' and spellMap == 'StatusRemoval'
            and spell.english ~= 'Sacrifice' and spell.english ~= 'Esuna'
            and state.AutoDivineSeal.value ~= 'Off' and not yagrush_at_cast(spell, spellMap)
            and not buffactive['Divine Seal'] and not silent_check_amnesia() then
        local abil_recasts = windower.ffxi.get_ability_recasts()
        if abil_recasts[26] and abil_recasts[26] < latency then
            if state.AutoDivineSeal.value == 'Smart' then
                local count = divine_veil_count(spell)
                if not count or count < 2 then return end
                add_to_chat(122, '[GearSwap] '..count..' party members need '..spell.english..' - using Divine Seal')
            end
            eventArgs.cancel = true
            windower.chat.input('/ja "Divine Seal" <me>')
            windower.chat.input:schedule(1.1, '/ma "'..spell.english..'" '..spell.target.raw)
            add_tick_delay(1.1)
            return
        end
    end
end

function select_default_macro_book()
    set_macro_page(1, 3)
end

function user_job_lockstyle()
    windower.chat.input("/lockstyleset 003")
end

autows_list = {["DualWeapons"] = "Realmrazer", ["MeleeWeapons"] = "Realmrazer"}

-- LINKTRI: removed the custom sleep handler (user_job_buff_change). It set Weapons to MeleeWeapons and then
-- forced it back to None after 6s (dropping DualWeapons). Sleep-proofing now uses Sel's WakeUpWeapons:
-- sets.WakeUpWeapons below + state.WakeUpWeapons in user_job_setup.

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

-- LINKTRI: renamed from job_self_command (replaced WHM.lua's) and made nil-safe; marks the command handled.
function user_job_self_command(cmdParams, eventArgs)
    if cmdParams[1] and cmdParams[1]:lower() == 'sortie' then
        eventArgs.handled = true
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
-- LINKTRI MODIFICATION START 2026-07-02 (revised 2026-10-21): nuke waist overlay (Orpheus/Hachirin)
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

-- LINKTRI (2026-10-21): ported from BLM. Orpheus's Sash affinity: +15 at <=1.93 yalms, tapering to +1 at >=13.
-- Hachirin-no-Obi: +10 day match, +10 single / +25 double weather. Day/weather proc ~1/3 of the time without
-- the obi, so the obi is credited with ~2/3 of its bonus. Returns nil when neither is worth it (set's Sacro Cord stays).
local ORPHEUS_MIN_DIST = 1.93
local ORPHEUS_MAX_DIST = 13.0
local ORPHEUS_MIN_WORTH = 2

local function nuke_waist_bonus(spell)
    local el = spell.element
    if not el or el == 'None' then return nil end
    local obi = 0
    if world.day_element == el then obi = obi + 10 end
    if world.weather_element == el then
        local intensity = 1
        if world.weather_id and gearswap and gearswap.res and gearswap.res.weather
                and gearswap.res.weather[world.weather_id] then
            intensity = gearswap.res.weather[world.weather_id].intensity or 1
        end
        obi = obi + (intensity == 2 and 25 or 10)
    end
    local dist = (spell.target and spell.target.distance) or 21
    local aff
    if dist <= ORPHEUS_MIN_DIST then
        aff = 15
    elseif dist >= ORPHEUS_MAX_DIST then
        aff = 1
    else
        aff = math.floor(15 - ((dist - ORPHEUS_MIN_DIST) * (14 / (ORPHEUS_MAX_DIST - ORPHEUS_MIN_DIST))))
    end
    if (obi * 0.67) >= aff and obi > 0 then
        return "Hachirin-no-Obi"
    elseif aff >= ORPHEUS_MIN_WORTH then
        return "Orpheus's Sash"
    end
    return nil
end

-- LINKTRI: renamed from job_post_midcast (which replaced WHM.lua's and copied its Divine Caress/BarElement
-- logic). WHM.lua's job_post_midcast now runs first, then this waist/back overlay for damaging magic.
function user_job_post_midcast(spell, spellMap, eventArgs)
    if spell.action_type == 'Magic' and (spell.skill == 'Elemental Magic' or LINKTRI_DIVINE_NUKES:contains(spell.english)) then
        local waist = nuke_waist_bonus(spell)
        if waist then
            equip({waist = waist})
            -- Twilight Cape: +5% to the day/weather bonus, which Hachirin guarantees.
            if waist == "Hachirin-no-Obi" then
                equip({back = "Twilight Cape"})
            end
        end
    end
end
-- LINKTRI MODIFICATION END