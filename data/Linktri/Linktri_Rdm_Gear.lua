near_porter = false

-- Helper function to convert item name to ID
function item_name_to_id(name)
    if not name or name == "empty" then return nil end
    for id, item in pairs(res.items) do
        if item.en == name or item.enl == name then
            return id
        end
    end
    return nil
end

-- Helper function to safely get weapon skill type
function get_weapon_skill(item_name)
    if not item_name or item_name == "empty" then return nil end
    local item_id = item_name_to_id(item_name)
    if item_id and res.items[item_id] then
        return res.items[item_id].skill
    end
    return nil
end

function user_job_setup()
    -- Options: Override default values
    state.OffenseMode:options("Normal", "Acc", "FullAcc")
    state.HybridMode:options("Normal", "DT")
    state.WeaponskillMode:options("Match", "Proc")
    state.AutoBuffMode:options("Off", "Auto", "AutoMelee")
    state.CastingMode:options("Normal", "Resistant", "Fodder", "Proc")
    state.IdleMode:options("Normal", "PDT", "MDT", "DTHippo")
    state.PhysicalDefenseMode:options("PDT", "NukeLock")
    state.MagicalDefenseMode:options("MDT")
    state.ResistDefenseMode:options("MEVA")
    state.Weapons:options(
        "None",
        "Naegling",
		"DualMpuGandring",
        "DualWeapons",
        "DualWeaponsAcc",
        "DualEvisceration",
        "DualClubs",
        "DualAeolian",
        "DualProcDaggers",
        "EnspellOnly",
        "EnspellDW"
    )

    -- original (TP Sucellos's Cape, not owned): gear.stp_jse_back = { name = "Sucellos's Cape", augments = {"DEX+20", "Accuracy+20 Attack+20", "Accuracy+10", '"Store TP"+10'} }
    gear.stp_jse_back = "Null Shawl"
    -- original (nuke/enfeeble Sucellos's Cape, not owned): gear.nuke_jse_back = { name = "Sucellos's Cape", augments = {"INT+20", "Mag. Acc+20 /Mag. Dmg.+20", "INT+10", '"Mag.Atk.Bns."+10', "Phys. dmg. taken-10%"} }
    gear.nuke_jse_back = "Aurist's Cape +1"
    -- original (WS Sucellos's Cape, not owned): gear.wsd_jse_back = { name = "Sucellos's Cape", augments = {"STR+20", "Accuracy+20 Attack+20", "STR+10", "Weapon skill damage +10%"} }
    gear.wsd_jse_back = "Null Shawl"

    -- Additional local binds
    send_command("bind ^` gs c cycle ElementalMode")
    send_command("bind @` gs c cycle MagicBurstMode")
    send_command('bind ^@!` input /ja "Accession" <me>')
    send_command('bind ^backspace input /ja "Saboteur" <me>')
    send_command('bind !backspace input /ja "Spontaneity" <t>')
    send_command('bind @backspace input /ja "Composure" <me>')
    send_command("bind @f8 gs c toggle AutoNukeMode")
    send_command('bind != input /ja "Penury" <me>')
    send_command('bind @= input /ja "Parsimony" <me>')
    send_command('bind ^delete input /ja "Dark Arts" <me>')
    send_command('bind !delete input /ja "Addendum: Black" <me>')
    send_command('bind @delete input /ja "Manifestation" <me>')
    send_command('bind ^\\\\ input /ma "Protect V" <t>')
    send_command('bind @\\\\ input /ma "Shell V" <t>')
    send_command('bind !\\\\ input /ma "Reraise" <me>')
    send_command("bind @f10 gs c cycle RecoverMode")
    send_command(
        "bind ^r gs c set skipprocweapons true;gs c reset weaponskillmode;gs c weapons Default;gs c set unlockweapons false"
    )
    send_command("bind ^q gs c set weapons enspellonly;gs c set unlockweapons true")
    send_command("bind !r gs c set skipprocweapons true;gs c reset weaponskillmode;gs c set weapons none")
    send_command(
        "bind !q gs c set skipprocweapons false;gs c set weapons DualProcDaggers;gs c set weaponskillmode proc"
    )

    select_default_macro_book()
end

function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Precast Sets

    -- Precast sets to enhance JAs
    sets.precast.JA["Chainspell"] = {body = "Viti. Tabard +1"}

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz["Healing Waltz"] = {}

    -- Fast cast sets for spells

    sets.precast.FC = {
        main = gear.grioavolr_fc_staff,
        sub = "Clerisy Strap +1",
        range = empty,
        ammo = "Impatiens",
        head = "Atrophy Chapeau +3",
        neck = "Voltsurge Torque",
        ear1 = "Malignance Earring",  -- original: "Loquac. Earring" (stored; Leth. Earring +1 is FC+8)
        ear2 = "Leth. Earring +1",
        body = "Viti. Tabard +1",
        hands = "Bunzi's Gloves",  -- original: "Gende. Gages +1" (not owned) -- no FC hands owned; Bunzi DT-8
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",
        back = "Perimede Cape",
        waist = "Witful Belt",
        legs = { name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},  -- original: "Psycloth Lappas" (not owned) -- Kaykaus FC+7
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.precast.FC.Impact = set_combine(sets.precast.FC, {head = empty, body = "Twilight Cloak"})
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main = "Daybreak", sub = "Sacro Bulwark"})

    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        range = empty,
        ammo = "Voluspa Tathlum",
        head = "Viti. Chapeau +1",
        neck = "Asperity Necklace",
        ear1 = "Sherida Earring",
        ear2 = "Moonshade Earring",  -- original: ear1 Telos (Cessance not owned), ear2 Sherida  -- sides 2026-10-23
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1",  -- original: "Windbuffet Belt +1" (not owned)
        legs = { name="Nyame Flanchard", augments={'Path: B',}},  -- original: "Carmine Cuisses +1" (not owned)
        feet = { name="Nyame Sollerets", augments={'Path: B',}}  -- original: "Carmine Greaves +1" (not owned)
    }

    sets.precast.WS.Proc = {
        range = empty,
        ammo = "Amar Cluster",  -- original: "Hasty Pinion +1" (not owned)
        head = "Malignance Chapeau",
        neck = "Combatant's Torque",
        ear1 = "Mache Earring +1",
        ear2 = "Leth. Earring +1",  -- original: "Telos Earring" (ear1-side)
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",  -- original: "Ramuh Ring +1" (not owned)
        ring2 = "Cacoethic Ring +1",  -- original: "Ramuh Ring +1" (not owned); sides 2026-10-23
        back = gear.wsd_jse_back,
        waist = "Eschan Stone",  -- original: "Olseni Belt" (not owned)
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS["Requiescat"] = {
        range = empty,
        ammo = "Regal Gem",
        head = "Jhakri Coronal +2",
        neck = "Null Loop",  -- original: "Fotia Gorget" (not owned)
        ear1 = "Sherida Earring",
        ear2 = "Moonshade Earring",  -- sides 2026-10-23
        body = "Jhakri Robe +2",
        hands = "Atrophy Gloves +3",
        ring1 = "Metamor. Ring +1",  -- original: "Rufescent Ring" (not owned)
        ring2 = "Persis Ring",  -- MND+6; original: "Ifrit Ring +1" (not owned), then Ephramad's (no MND)  -- sides 2026-10-23
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1",  -- original: "Fotia Belt" (not owned)
        legs = "Jhakri Slops +2",
        feet = "Jhakri Pigaches +2"
    }

    sets.precast.WS["Chant Du Cygne"] = {
        range = empty,
        ammo = "Voluspa Tathlum",
        head = "Malignance Chapeau",
        neck = "Anu Torque",  -- original: "Fotia Gorget" (not owned)
        ear1 = "Sherida Earring",
        ear2 = "Moonshade Earring",  -- sides 2026-10-23
        body = "Ayanmo Corazza +2",
        hands = "Atrophy Gloves +3",
        ring1 = "Ephramad's Ring",  -- original: "Begrudging Ring" (not owned)
        ring2 = "Ilabrat Ring",
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1",  -- original: "Fotia Belt" (not owned)
        legs = { name="Nyame Flanchard", augments={'Path: B',}},  -- original: "Carmine Cuisses +1" (not owned)
        feet = { name="Nyame Sollerets", augments={'Path: B',}}  -- original: "Thereoid Greaves" (not owned)
    }

    sets.precast.WS["Evisceration"] = sets.precast.WS["Chant Du Cygne"]

    sets.precast.WS["Savage Blade"] = {
        range = empty,
        ammo = "Sroda Tathlum",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Anu Torque",  -- original: "Caro Necklace" (not owned)
        ear1 = "Ishvara Earring",
        ear2 = "Moonshade Earring",  -- sides 2026-10-23
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = "Atrophy Gloves +3",
        ring1 = "Metamor. Ring +1",
        ring2 = "Ilabrat Ring",
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1",
        legs = { name="Nyame Flanchard", augments={'Path: B',}},
        feet = "Leth. Houseaux +3"  -- original: { name="Nyame Sollerets", augments={'Path: B',}} (owned, swapped: Houseaux +3 has WSD+12%)
    }

    sets.precast.WS["Sanguine Blade"] = {
        range = empty,
        ammo = "Pemphredo Tathlum",
        head = "Pixie Hairpin +1",
        neck = "Baetyl Pendant",
        ear1 = "Malignance Earring",
        ear2 = "Crematio Earring",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = "Metamor. Ring +1",
        ring2 = "Persis Ring",  -- original: "Archon Ring" (not owned)
        back = gear.nuke_jse_back,
        waist = "Orpheus's Sash",
        legs = { name="Nyame Flanchard", augments={'Path: B',}},
        feet = { name="Nyame Sollerets", augments={'Path: B',}}
    }

    sets.precast.WS["Seraph Blade"] = {
        range = empty,
        ammo = "Pemphredo Tathlum",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Baetyl Pendant",
        ear1 = "Malignance Earring",
        ear2 = "Crematio Earring",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = "Metamor. Ring +1",
        ring2 = "Persis Ring",  -- original: "Freke Ring" (not owned)
        back = gear.nuke_jse_back,
        waist = "Orpheus's Sash",
        legs = { name="Nyame Flanchard", augments={'Path: B',}},
        feet = { name="Nyame Sollerets", augments={'Path: B',}}
    }

    sets.precast.WS["Aeolian Edge"] = {
        range = empty,
        ammo = "Pemphredo Tathlum",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Baetyl Pendant",
        ear1 = "Malignance Earring",
        ear2 = "Crematio Earring",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = "Metamor. Ring +1",
        ring2 = "Persis Ring",  -- original: "Freke Ring" (not owned)
        back = gear.nuke_jse_back,
        waist = "Orpheus's Sash",
        legs = { name="Nyame Flanchard", augments={'Path: B',}},
        feet = { name="Nyame Sollerets", augments={'Path: B',}}
    }

    -- Midcast Sets

    sets.TreasureHunter = set_combine(sets.TreasureHunter, {waist = "Chaac Belt"})  -- original: {feet = gear.chironic_treasure_feet} (TH Chironic Slippers not owned; Chaac Belt is TH+1)

    -- Gear that converts elemental damage done to recover MP.
    sets.RecoverMP = {}  -- original: {body = "Seidr Cotehardie"} (not owned)

    -- Gear for Magic Burst mode.
    sets.MagicBurst = {
        main = { name="Bunzi's Rod", augments={'Path: A',}},
        sub = "Ammurapi Shield",
        head = { name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Mizu. Kubikazari",
        body = { name="Bunzi's Robe", augments={'Path: A',}},
        hands = { name="Bunzi's Gloves", augments={'Path: A',}},
        ring1 = "Metamor. Ring +1",  -- original: "Mujin Band" (not owned) -- no MB ring owned
        ring2 = "Persis Ring",
        legs = { name="Bunzi's Pants", augments={'Path: A',}},
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}
    }

    sets.midcast.FastRecast = {
        main = gear.grioavolr_fc_staff,
        sub = "Clerisy Strap +1",
        range = empty,
        ammo = "Impatiens",  -- original: "Hasty Pinion +1" (not owned)
        head = "Atrophy Chapeau +3",
        neck = "Voltsurge Torque",
        ear1 = "Malignance Earring",  -- original: "Enchntr. Earring +1" (not owned)
        ear2 = "Leth. Earring +1",
        body = "Viti. Tabard +1",  -- original: "Zendik Robe" (not owned)
        hands = "Bunzi's Gloves",  -- original: "Gende. Gages +1" (not owned)
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",  -- original: "Prolix Ring" (not owned)
        back = "Null Shawl",  -- original: "Swith Cape +1" (not owned)
        waist = "Witful Belt",
        legs = { name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},  -- original: "Psycloth Lappas" (not owned)
        feet = "Medium's Sabots"
    }

    sets.midcast.Cure = {
        main = "Daybreak",
        sub = "Sors Shield",
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = { name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "Nodens Gorget",  -- original: "Incanter's Torque" (not owned) -- Nodens Cure potency +5%
        ear1 = "Meili Earring",
        ear2 = { name="Alabaster Earring", augments={'Path: A',}},  -- original: "Mendi. Earring" (not owned)
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = { name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1 = "Metamor. Ring +1",  -- MND+6; original: "Stikini Ring", (single Stikini is ring2-side)
        ring2 = "Menelaus's Ring",
        back = { name="Ghostfyre Cape", augments={'Enfb.mag. skill +3','Enha.mag. skill +2','Enh. Mag. eff. dur. +17',}},  -- original: "Tempered Cape +1" (not owned)
        waist = "Luminary Sash",
        legs = { name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightWeatherCure = {
        main = "Chatoyant Staff",
        sub = "Enki Strap",  -- original: "Curatio Grip" (not owned)
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = { name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "Nodens Gorget",  -- original: "Incanter's Torque" (not owned) -- Nodens Cure potency +5%
        ear1 = "Meili Earring",
        ear2 = { name="Alabaster Earring", augments={'Path: A',}},  -- original: "Mendi. Earring" (not owned)
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = { name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1 = "Metamor. Ring +1",  -- MND+6; original: "Stikini Ring" (single Stikini is ring2-side)
        ring2 = "Menelaus's Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = { name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    --Cureset for if it's not light weather but is light day.
    sets.midcast.LightDayCure = {
        main = "Daybreak",
        sub = "Sors Shield",
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = { name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "Nodens Gorget",  -- original: "Incanter's Torque" (not owned) -- Nodens Cure potency +5%
        ear1 = "Meili Earring",
        ear2 = { name="Alabaster Earring", augments={'Path: A',}},  -- original: "Mendi. Earring" (not owned)
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = { name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1 = "Metamor. Ring +1",  -- MND+6; original: "Stikini Ring" (single Stikini is ring2-side)
        ring2 = "Menelaus's Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = { name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.Cursna = {
        main = gear.grioavolr_fc_staff,
        sub = "Clerisy Strap +1",  -- original: "Curatio Grip" (not owned)
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = { name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Voltsurge Torque",  -- original: "Debilis Medallion" (not owned)
        ear1 = "Meili Earring",
        ear2 = { name="Alabaster Earring", augments={'Path: A',}},  -- original: "Mendi. Earring" (not owned)
        body = "Viti. Tabard +1",
        hands = { name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},  -- original: "Hieros Mittens" (not owned)
        ring1 = "Metamor. Ring +1",  -- original: "Haoma's Ring" (not owned), then Stikini (ring2-side)
        ring2 = "Menelaus's Ring",
        back = "Vates Cape +1",  -- original: "Oretan. Cape +1" (not owned) -- Vates Healing skill +6
        waist = "Witful Belt",
        legs = "Atrophy Tights +3",  -- original: "Carmine Cuisses +1" (not owned) -- Atrophy Healing skill +17
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}  -- original: "Vanya Clogs" (not owned)
    }

    sets.midcast.StatusRemoval =
        set_combine(sets.midcast.FastRecast, {main = gear.grioavolr_fc_staff, sub = "Clemency Grip"})

    sets.midcast.Curaga = sets.midcast.Cure
    sets.Self_Healing = {}  -- original: {neck="Phalaina Locket", ear1="Etiolation Earring", hands="Buremte Gloves", ring2="Kunaji Ring", waist="Gishdubar Sash"} (none owned)
    sets.Cure_Received = {}  -- original: {neck="Phalaina Locket", hands="Buremte Gloves", ring2="Kunaji Ring", waist="Gishdubar Sash"} (none owned)
    sets.Self_Refresh = {}  -- original: {back = "Grapevine Cape", waist = "Gishdubar Sash"} (not owned)

    sets.midcast["Enhancing Magic"] = {
        main = "Daybreak",  -- original: "Colada" (not owned)
        sub = "Ammurapi Shield",
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = { name="Telchine Cap", augments={'Mag. Acc.+20','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        neck = "Null Loop",  -- original: "Dls. Torque +2" (not owned) -- no enhancing neck owned
        ear1 = "Andoaa Earring",
        ear2 = "Leth. Earring +1",  -- original: "Gifted Earring" (not owned) -- Leth. Earring +1 Enh. duration +8%
        body = { name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        hands = "Atrophy Gloves +3",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = { name="Ghostfyre Cape", augments={'Enfb.mag. skill +3','Enha.mag. skill +2','Enh. Mag. eff. dur. +17',}},
        waist = "Embla Sash",
        legs = { name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        feet = "Leth. Houseaux +3"
    }

    --Atrophy Gloves are better than Lethargy for me despite the set bonus for duration on others.
    sets.buff.ComposureOther = {
        head = "Leth. Chappel +3",
        body = "Lethargy Sayon +3",
        hands = "Leth. Ganth. +3",
        legs = "Leth. Fuseau +3",
        feet = "Leth. Houseaux +3"
    }

    --Red Mage enhancing sets are handled in a different way from most, layered on due to the way Composure works
    --Don't set combine a full set with these spells, they should layer on Enhancing Set > Composure (If Applicable) > Spell
    sets.EnhancingSkill = {
        -- main = "Pukulatmuj +1"  -- removed: (not owned)
        head = "Befouled Crown",
        -- neck = "Incanter's Torque"  -- removed: (not owned)
        -- ear2 = "Mimir Earring"  -- removed: (not owned)
        hands = "Viti. Gloves +1",
        back = { name="Ghostfyre Cape", augments={'Enfb.mag. skill +3','Enha.mag. skill +2','Enh. Mag. eff. dur. +17',}},
        -- waist = "Olympus Sash"  -- removed: (not owned)
        legs = "Atrophy Tights +3"
    }
    sets.midcast.Refresh = {body = "Atrophy Tabard +3", legs = "Leth. Fuseau +3"}  -- original: head = "Amalric Coif +1" (not owned)
    sets.midcast.Aquaveil = {}  -- original: {head="Amalric Coif +1", hands="Regal Cuffs", waist="Emphatikos Rope", legs="Shedir Seraweels"} (none owned)
    sets.midcast.BarElement = {}  -- original: {legs = "Shedir Seraweels"} (not owned)
    sets.midcast.Temper = sets.EnhancingSkill
    sets.midcast.Temper.DW = set_combine(sets.midcast.Temper, {})  -- original: {sub = "Pukulatmuj"} (not owned)
    sets.midcast.Enspell = sets.midcast.Temper
    sets.midcast.Enspell.DW = set_combine(sets.midcast.Enspell, {})  -- original: {sub = "Pukulatmuj"} (not owned)
    sets.midcast.BoostStat = {hands = "Viti. Gloves +1"}
    sets.midcast.Stoneskin = {
        neck = "Nodens Gorget",
        -- ear2 = "Earthcry Earring"  -- removed: (not owned)
        waist = "Siegel Sash",
        -- legs = "Shedir Seraweels"  -- removed: (not owned)
    }
    sets.midcast.Protect = {}  -- original: {ring2 = "Sheltered Ring"} (not owned)
    sets.midcast.Shell = {}  -- original: {ring2 = "Sheltered Ring"} (not owned)

    sets.midcast["Enfeebling Magic"] = {
        main = { name="Contemplator +1", augments={'Path: A',}},
        sub = "Enki Strap",
        range = empty,
        ammo = "Regal Gem",
        head = "Viti. Chapeau +1",
        neck = "Null Loop",  -- original: "Dls. Torque +2" (not owned)
        ear1 = "Malignance Earring",
        ear2 = "Psystorm Earring",  -- original: "Snotra Earring" (not owned)
        body = "Lethargy Sayon +3",
        hands = "Leth. Ganth. +3",  -- original: "Regal Gloves" (Regal Gloves are not RDM-equippable)
        ring1 = "Kishar Ring",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Obstin. Sash",
        legs = "Leth. Fuseau +3",  -- original: "Chironic Hose" (not owned)
        feet = "Vitiation Boots +1"
    }

    sets.midcast["Enfeebling Magic"].Resistant = {
        main = { name="Contemplator +1", augments={'Path: A',}},
        sub = "Enki Strap",
        range = empty,
        ammo = "Regal Gem",
        head = "Viti. Chapeau +1",
        neck = "Null Loop",  -- original: "Dls. Torque +2" (not owned)
        ear1 = "Malignance Earring",
        ear2 = "Psystorm Earring",  -- original: "Snotra Earring" (not owned)
        body = "Atrophy Tabard +3",
        hands = gear.chironic_enfeeble_hands,
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Null Belt",  -- original: "Luminary Sash" (owned, swapped: Luminary Sash MAcc+10 -> Null Belt MAcc+30)
        legs = "Leth. Fuseau +3",  -- original: "Chironic Hose" (not owned)
        feet = "Vitiation Boots +1"
    }

    sets.midcast.DurationOnlyEnfeebling =
        set_combine(
        sets.midcast["Enfeebling Magic"],
        {main = { name="Bunzi's Rod", augments={'Path: A',}}, sub = "Ammurapi Shield", body = "Atrophy Tabard +3"}  -- original also had range = "Kaja Bow" (not owned)
    )

    sets.midcast.Silence = sets.midcast.DurationOnlyEnfeebling
    sets.midcast.Silence.Resistant = sets.midcast["Enfeebling Magic"].Resistant
    sets.midcast.Sleep = set_combine(sets.midcast.DurationOnlyEnfeebling, {waist = "Null Belt"})  -- original: waist = "Acuity Belt +1" (not owned)
    sets.midcast.Sleep.Resistant = set_combine(sets.midcast["Enfeebling Magic"].Resistant, {waist = "Null Belt"})  -- original: waist = "Acuity Belt +1" (not owned)
    sets.midcast.Bind = set_combine(sets.midcast.DurationOnlyEnfeebling, {waist = "Null Belt"})  -- original: waist = "Acuity Belt +1" (not owned)
    sets.midcast.Bind.Resistant = set_combine(sets.midcast["Enfeebling Magic"].Resistant, {waist = "Null Belt"})  -- original: waist = "Acuity Belt +1" (not owned)
    sets.midcast.Break = set_combine(sets.midcast.DurationOnlyEnfeebling, {waist = "Null Belt"})  -- original: waist = "Acuity Belt +1" (not owned)
    sets.midcast.Break.Resistant = set_combine(sets.midcast["Enfeebling Magic"].Resistant, {waist = "Null Belt"})  -- original: waist = "Acuity Belt +1" (not owned)

    sets.midcast.Dispel = sets.midcast["Enfeebling Magic"].Resistant

    sets.midcast.SkillBasedEnfeebling =
        set_combine(
        sets.midcast["Enfeebling Magic"],
        {hands = "Leth. Ganth. +3", ring1 = "Stikini Ring"}  -- original also had ear1 = "Vor Earring", legs = "Psycloth Lappas" (not owned)
    )

    sets.midcast["Frazzle II"] = sets.midcast["Enfeebling Magic"].Resistant
    sets.midcast["Frazzle III"] = sets.midcast.SkillBasedEnfeebling
    sets.midcast["Frazzle III"].Resistant = sets.midcast["Enfeebling Magic"].Resistant

    sets.midcast["Distract III"] = sets.midcast.SkillBasedEnfeebling
    sets.midcast["Distract III"].Resistant = sets.midcast["Enfeebling Magic"].Resistant

    sets.midcast["Divine Magic"] = set_combine(sets.midcast["Enfeebling Magic"].Resistant, {})

    sets.midcast.Dia = set_combine(sets.midcast["Enfeebling Magic"], sets.TreasureHunter)
    sets.midcast.Diaga = set_combine(sets.midcast["Enfeebling Magic"], sets.TreasureHunter)

    sets.midcast.Bio = set_combine(sets.midcast["Enfeebling Magic"], sets.TreasureHunter)

    sets.midcast["Elemental Magic"] = {
        main = { name="Bunzi's Rod", augments={'Path: A',}},
        sub = "Ammurapi Shield",
        range = empty,
        ammo = "Pemphredo Tathlum",  -- original: "Ghastly Tathlum +1" (not owned)
        head = { name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Baetyl Pendant",
        ear1 = "Malignance Earring",
        ear2 = "Crematio Earring",
        body = { name="Bunzi's Robe", augments={'Path: A',}},
        hands = { name="Bunzi's Gloves", augments={'Path: A',}},
        ring1 = "Metamor. Ring +1",
        ring2 = "Persis Ring",  -- original: "Freke Ring" (not owned) -- no Freke-tier nuke ring owned
        back = gear.nuke_jse_back,
        waist = gear.ElementalObi,
        legs = { name="Bunzi's Pants", augments={'Path: A',}},
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}
    }

    sets.midcast["Elemental Magic"].Resistant = {
        main = { name="Bunzi's Rod", augments={'Path: A',}},
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = { name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Null Loop",  -- original: "Dls. Torque +2" (not owned)
        ear1 = "Malignance Earring",
        ear2 = "Crematio Earring",
        body = { name="Bunzi's Robe", augments={'Path: A',}},
        hands = { name="Bunzi's Gloves", augments={'Path: A',}},
        ring1 = "Metamor. Ring +1",
        ring2 = "Persis Ring",  -- original: "Freke Ring" (not owned)
        back = gear.nuke_jse_back,
        waist = "Null Belt",  -- original: "Yamabuki-no-Obi" (not owned)
        legs = { name="Bunzi's Pants", augments={'Path: A',}},
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}
    }

    sets.midcast["Elemental Magic"].Fodder = {
        main = { name="Bunzi's Rod", augments={'Path: A',}},
        sub = "Ammurapi Shield",
        range = empty,
        ammo = "Pemphredo Tathlum",  -- original: "Ghastly Tathlum +1" (not owned)
        head = { name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Baetyl Pendant",
        ear1 = "Malignance Earring",
        ear2 = "Crematio Earring",
        body = { name="Bunzi's Robe", augments={'Path: A',}},
        hands = { name="Bunzi's Gloves", augments={'Path: A',}},
        ring1 = "Metamor. Ring +1",
        ring2 = "Persis Ring",  -- original: "Freke Ring" (not owned) -- no Freke-tier nuke ring owned
        back = gear.nuke_jse_back,
        waist = gear.ElementalObi,
        legs = { name="Bunzi's Pants", augments={'Path: A',}},
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}
    }

    sets.midcast["Elemental Magic"].Proc = {
        main = empty,
        sub = empty,
        range = empty,
        ammo = "Impatiens",
        head = "Atrophy Chapeau +3",  -- original: "Vanya Hood" (not owned) -- Proc set is fast cast/recast
        neck = "Voltsurge Torque",
        ear1 = "Malignance Earring",  -- original: "Enchntr. Earring +1" (not owned)
        ear2 = "Leth. Earring +1",  -- original: "Loquac. Earring" (stored)
        body = "Viti. Tabard +1",  -- original: "Zendik Robe" (not owned)
        hands = "Bunzi's Gloves",  -- original: "Gende. Gages +1" (not owned)
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",  -- original: "Prolix Ring" (not owned)
        back = "Null Shawl",  -- original: "Swith Cape +1" (not owned)
        waist = "Witful Belt",
        legs = { name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},  -- original: "Psycloth Lappas" (not owned)
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}  -- original: "Regal Pumps +1" (Regal Pumps +1 are not RDM-equippable)
    }

    sets.midcast["Elemental Magic"].HighTierNuke =
        set_combine(
        sets.midcast["Elemental Magic"],
        {head = gear.merlinic_nuke_head, ammo = "Pemphredo Tathlum", ring1 = "Metamor. Ring +1"}  -- original also had ear1 = "Regal Earring" (not owned)
    )
    sets.midcast["Elemental Magic"].HighTierNuke.Resistant =
        set_combine(
        sets.midcast["Elemental Magic"].Resistant,
        {head = gear.merlinic_nuke_head, ring1 = "Metamor. Ring +1"}  -- original also had ear1 = "Regal Earring" (not owned)
    )
    sets.midcast["Elemental Magic"].HighTierNuke.Fodder =
        set_combine(
        sets.midcast["Elemental Magic"].Fodder,
        {head = gear.merlinic_nuke_head, ammo = "Pemphredo Tathlum", ring1 = "Metamor. Ring +1"}  -- original also had ear1 = "Regal Earring" (not owned)
    )

    sets.midcast.Impact = {
        main = { name="Bunzi's Rod", augments={'Path: A',}},
        sub = "Ammurapi Shield",
        range = empty,  -- original: "Kaja Bow" (not owned)
        ammo = "Pemphredo Tathlum",  -- original: empty (was empty because of Kaja Bow)
        head = empty,
        neck = "Erra Pendant",
        ear1 = "Malignance Earring",
        ear2 = "Psystorm Earring",  -- original: "Snotra Earring" (not owned)
        body = "Twilight Cloak",
        hands = "Leth. Ganth. +3",
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Luminary Sash",
        legs = { name="Bunzi's Pants", augments={'Path: A',}},
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}
    }

    sets.midcast["Dark Magic"] = {
        main = "Rubicundity",
        sub = "Ammurapi Shield",
        range = empty,  -- original: "Kaja Bow" (not owned)
        ammo = "Pemphredo Tathlum",  -- original: empty (was empty because of Kaja Bow)
        head = "Leth. Chappel +3",  -- original: "Amalric Coif +1" (not owned)
        neck = "Erra Pendant",
        ear1 = "Malignance Earring",
        ear2 = "Psystorm Earring",  -- original: "Snotra Earring" (not owned)
        body = "Atrophy Tabard +3",
        hands = "Leth. Ganth. +3",
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Luminary Sash",
        legs = "Leth. Fuseau +3",  -- original: "Psycloth Lappas" (not owned)
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}
    }

    sets.midcast.Drain = {
        main = "Rubicundity",
        sub = "Ammurapi Shield",
        range = empty,  -- original: "Kaja Bow" (not owned)
        ammo = "Pemphredo Tathlum",  -- original: empty (was empty because of Kaja Bow)
        head = "Pixie Hairpin +1",
        neck = "Erra Pendant",
        ear1 = "Malignance Earring",
        ear2 = "Psystorm Earring",  -- original: "Snotra Earring" (not owned)
        body = { name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9',}},
        hands = "Leth. Ganth. +3",  -- original: gear.chironic_enfeeble_hands (owned Chironic Gloves kept for Enfeebling Resistant; Leth. +3 MAcc+62)
        ring1 = "Stikini Ring",  -- original: "Evanescence Ring" (not owned)
        ring2 = "Stikini Ring",  -- original: "Archon Ring" (not owned)
        back = gear.nuke_jse_back,
        waist = "Fucho-no-obi",
        legs = "Leth. Fuseau +3",  -- original: "Chironic Hose" (not owned)
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}  -- original: gear.merlinic_aspir_feet (not owned)
    }

    sets.midcast.Aspir = sets.midcast.Drain

    sets.midcast.Stun = {
        main = { name="Bunzi's Rod", augments={'Path: A',}},
        sub = "Ammurapi Shield",
        range = empty,  -- original: "Kaja Bow" (not owned)
        ammo = "Pemphredo Tathlum",  -- original: empty (was empty because of Kaja Bow)
        head = "Atrophy Chapeau +3",
        neck = "Null Loop",  -- original: "Dls. Torque +2" (not owned)
        ear1 = "Malignance Earring",
        ear2 = "Psystorm Earring",  -- original: "Snotra Earring" (not owned)
        body = "Viti. Tabard +1",  -- original: "Zendik Robe" (not owned)
        hands = "Leth. Ganth. +3",  -- original: "Volte Gloves" (not owned)
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Leth. Fuseau +3",  -- original: "Chironic Hose" (not owned)
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}  -- original: gear.merlinic_aspir_feet (not owned)
    }

    sets.midcast.Stun.Resistant = {
        main = { name="Bunzi's Rod", augments={'Path: A',}},
        sub = "Ammurapi Shield",
        range = empty,  -- original: "Kaja Bow" (not owned)
        ammo = "Pemphredo Tathlum",  -- original: empty (was empty because of Kaja Bow)
        head = "Atrophy Chapeau +3",
        neck = "Null Loop",  -- original: "Dls. Torque +2" (not owned)
        ear1 = "Malignance Earring",
        ear2 = "Psystorm Earring",  -- original: "Snotra Earring" (not owned)
        body = "Atrophy Tabard +3",
        hands = "Leth. Ganth. +3",  -- original: "Volte Gloves" (not owned)
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Null Belt",  -- original: waist = "Acuity Belt +1" (not owned)
        legs = "Leth. Fuseau +3",  -- original: "Chironic Hose" (not owned)
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}  -- original: gear.merlinic_aspir_feet (not owned)
    }

    -- Sets for special buff conditions on spells.

    sets.buff.Saboteur = {hands = "Leth. Ganth. +3"}

    sets.HPDown = {
        head = "Pixie Hairpin +1",
        -- ear1 = "Mendicant's Earring"  -- removed: (not owned)
        ear2 = "Evans Earring",
        body = "Jhakri Robe +2",
        hands = "Jhakri Cuffs +2",
        -- ring1 = "Mephitas's Ring +1"  -- removed: (not owned)
        ring2 = "Mephitas's Ring",
        -- back = "Swith Cape +1"  -- removed: (not owned)
        -- legs = "Shedir Seraweels"  -- removed: (not owned)
        feet = "Jhakri Pigaches +2"
    }

    sets.HPCure = {
        main = "Daybreak",
        sub = "Sors Shield",
        range = empty,
        ammo = "Staunch Tathlum +1",  -- original: "Hasty Pinion +1" (not owned)
        head = { name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},  -- original: "Gende. Caubeen +1" (not owned)
        neck = "Unmoving Collar",  -- original: "Unmoving Collar +1" (owned Unmoving Collar non-+1)
        ear1 = "Meili Earring",  -- original: "Mendi. Earring" (not owned)
        ear2 = { name="Odnowa Earring +1", augments={'Path: A',}},  -- original: "Gifted Earring" (not owned)  -- sides 2026-10-23
        body = "Viti. Tabard +1",
        hands = { name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},  -- original: "Kaykaus Cuffs" (unaugmented name; you own the +1)
        ring1 = "Defending Ring",  -- original: "Meridian Ring" (not owned); Lebeche is ring2-side
        ring2 = "Menelaus's Ring",  -- original: "Gelatinous Ring +1" (not owned)  -- sides 2026-10-23
        back = { name="Ghostfyre Cape", augments={'Enfb.mag. skill +3','Enha.mag. skill +2','Enh. Mag. eff. dur. +17',}},  -- original: "Moonlight Cape" (not owned)
        waist = "Luminary Sash",
        legs = { name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},  -- original: "Carmine Cuisses +1" (not owned)
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}  -- original: "Kaykaus Boots" (unaugmented name; you own the +1)
    }

    sets.buff.Doom = set_combine(sets.buff.Doom, {})

    -- Sets to return to when not performing an action.

    -- Resting sets
    sets.resting = {
        main = "Chatoyant Staff",
        sub = "Umbra Strap",  -- original: "Oneiros Grip" (not owned)
        range = empty,
        ammo = "Impatiens",
        head = "Viti. Chapeau +1",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = { name="Alabaster Earring", augments={'Path: A',}},  -- original: "Ethereal Earring" (not owned)
        body = "Lethargy Sayon +3",  -- original: "Jhakri Robe +2" (owned, swapped: Refresh+4 same as Jhakri, plus DT-14%)
        hands = "Leth. Ganth. +3",  -- original: gear.merlinic_refresh_hands (not owned)
        ring1 = "Defending Ring",
        ring2 = "Stikini Ring",  -- original: "Sheltered Ring" (not owned)
        back = "Null Shawl",  -- original: "Umbra Cape" (not owned)
        waist = "Null Belt",  -- original: "Flume Belt +1" (not owned)
        legs = "Lengo Pants",
        feet = { name="Nyame Sollerets", augments={'Path: B',}}  -- original: gear.chironic_refresh_feet (not owned)
    }

    -- Idle sets
    sets.idle = {
        main = "Mpaca's Staff",
        sub = "Umbra Strap",
        range = empty,
        ammo = "Homiliary",
        head = "Null Masque",  -- DT-10%, Refresh+1, Regen+3; original: "Viti. Chapeau +1" (2026-10-23)
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = { name="Alabaster Earring", augments={'Path: A',}},
        body = "Lethargy Sayon +3",  -- original: "Jhakri Robe +2" (owned, swapped: Refresh+4 same as Jhakri, plus DT-14%)
        hands = "Leth. Ganth. +3",  -- original: gear.merlinic_refresh_hands (not owned) -- Merlinic refresh hands; Leth. +3 DT-11%
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = "Null Shawl",  -- original: "Umbra Cape" (not owned)
        waist = "Null Belt",  -- original: "Flume Belt +1" (not owned)
        legs = { name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',}},
        feet = { name="Nyame Sollerets", augments={'Path: B',}}  -- original: gear.merlinic_refresh_feet (not owned) -- Merlinic refresh feet
    }

    sets.idle.PDT = {
        main = "Daybreak",  -- original: "Terra's Staff" (not owned)
        sub = "Sacro Bulwark",  -- original: "Umbra Strap" (not owned)
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = { name="Alabaster Earring", augments={'Path: A',}},
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Null Shawl",  -- original: "Moonlight Cape" (not owned)
        waist = "Null Belt",  -- original: "Flume Belt +1" (not owned)
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.idle.MDT = {
        main = "Daybreak",
        sub = "Sacro Bulwark",
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = "Malignance Chapeau",
        neck = { name="Loricate Torque +1", augments={'Path: A',}},  -- original: "Warder's Charm +1" (not owned)
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Null Shawl",  -- original: "Moonlight Cape" (not owned)
        waist = "Carrier's Sash",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }


    -- LINKTRI: Weakness set commented out (2026-10-17). Without it, Sel uses your normal idle set while weakened.
    -- To restore, uncomment the lines below; Sel-Include equips sets.idle.Weak automatically when it exists.
    -- sets.idle.Weak = {
        -- main = "Bolelabunga",
        -- sub = "Sacro Bulwark",
        -- range = empty,
        -- ammo = "Homiliary",
        -- head = "Viti. Chapeau +1",
        -- neck = "Loricate Torque +1",
        -- ear1 = "Etiolation Earring",
        -- ear2 = { name="Alabaster Earring", augments={'Path: A',}},
        -- body = "Jhakri Robe +2",
        -- hands = gear.merlinic_refresh_hands,
        -- ring1 = "Defending Ring",
        -- ring2 = { name="Murky Ring", augments={'Path: A',}},
        -- back = "Umbra Cape",
        -- waist = "Flume Belt +1",
        -- legs = { name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',}},
        -- feet = gear.chironic_refresh_feet
    -- }

    sets.idle.DTHippo =
        set_combine(sets.idle.PDT, {ring2 = "Shneddick Ring +1"})  -- original: {back = "Umbra Cape", legs = "Carmine Cuisses +1", feet = "Hippo. Socks +1"} (not owned); Shneddick for movement

    sets.packing = {
        main  = "Mpaca's Staff",
        sub   = "Umbra Strap",
        range = empty,
        ammo  = "Homiliary",
        head  = "Nyame Helm",
        neck  = "Loricate Torque +1",
        ear1  = "Etiolation Earring",
        ear2  = { name="Alabaster Earring", augments={'Path: A',}},
        body  = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back  = "Null Shawl",  -- original: "Umbra Cape" (not owned)
        waist = "Fucho-no-obi",
        legs  = "Nyame Flanchard",
        feet  = "Nyame Sollerets"
    }

    -- Defense sets
    sets.defense.PDT = {
        main = "Daybreak",  -- original: "Terra's Staff" (not owned)
        sub = "Sacro Bulwark",  -- original: "Umbra Strap" (not owned)
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = { name="Alabaster Earring", augments={'Path: A',}},
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Null Shawl",  -- original: "Moonlight Cape" (not owned)
        waist = "Null Belt",  -- original: "Flume Belt +1" (not owned)
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.defense.NukeLock = sets.midcast["Elemental Magic"]

    sets.defense.MDT = {
        main = "Daybreak",  -- original: "Bolelabunga" (not owned)
        sub = "Sacro Bulwark",
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = "Malignance Chapeau",
        neck = { name="Loricate Torque +1", augments={'Path: A',}},  -- original: "Warder's Charm +1" (not owned)
        ear1 = "Etiolation Earring",
        ear2 = { name="Alabaster Earring", augments={'Path: A',}},
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Null Shawl",  -- original: "Moonlight Cape" (not owned)
        waist = "Carrier's Sash",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.defense.MEVA = {
        main = "Daybreak",
        sub = "Sacro Bulwark",
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = "Malignance Chapeau",
        neck = { name="Loricate Torque +1", augments={'Path: A',}},  -- original: "Warder's Charm +1" (not owned)
        ear1 = "Etiolation Earring",
        ear2 = { name="Alabaster Earring", augments={'Path: A',}},
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Null Shawl",  -- original: "Moonlight Cape" (not owned)
        waist = "Carrier's Sash",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.Kiting = {ring2 = "Shneddick Ring +1"}  -- original: ring1
    sets.latent_refresh = {waist = "Fucho-no-obi"}
    sets.latent_refresh_grip = {}  -- original: {sub = "Oneiros Grip"} (not owned)
    sets.TPEat = {}  -- original: {neck = "Chrys. Torque"} (not RDM-equippable)
    sets.DayIdle = {}
    sets.NightIdle = {}

    -- Weapons sets
    sets.weapons.Naegling = {main = "Naegling", sub = "Thibron", range = empty}
	sets.weapons.DualMpuGandring = {main = "Mpu Gandring", sub = "Thibron", range = empty}
    sets.weapons.DualWeapons = {main = "Naegling", sub = "Gleti's Knife", range = empty}  -- original: {main = "Vorpal Sword", sub = "Qutrub Knife"} (Vorpal Sword not owned)
    sets.weapons.DualWeaponsAcc = {main = "Naegling", sub = "Sakpata's Sword", range = empty}  -- original: {main = "Naegling", sub = "Almace"} (Almace not owned)
    sets.weapons.DualEvisceration = {main = "Tauret", sub = "Gleti's Knife", range = empty}  -- original: {main = "Tauret", sub = "Almace"} (Almace not owned)
    sets.weapons.DualAeolian = {main = "Tauret", sub = "Bunzi's Rod", range = empty}
    sets.weapons.DualProcDaggers = {main = "Ternion Dagger +1", sub = "Ethereal Dagger", range = empty}  -- original: {main = "Blurred Knife +1", sub = "Atoyac"} (not owned)
    sets.weapons.EnspellOnly = {main = "Ternion Dagger +1", sub = "Ethereal Dagger", range = empty}  -- original: {main = "Norgish Dagger", sub = "Aern Dagger", range = "Kaja Bow", ammo = "Beetle Arrow"} (not owned)
    sets.weapons.EnspellDW = {main = "Ternion Dagger +1", sub = "Ethereal Dagger", range = empty}  -- original: {main = "Blurred Knife +1", sub = "Atoyac", range = "Kaja Bow", ammo = "Beetle Arrow"} (not owned)
    sets.weapons.DualClubs = {main = "Maxentius", sub = "Thibron", range = empty}
    sets.weapons.DualAlmace = {main = "Almace", sub = "Sequence", range = empty}  -- not owned; not in the Weapons cycle, kept for later
    sets.weapons.DualBow = {main = "Naegling", sub = "Tauret", range = "Kaja Bow"}  -- Kaja Bow not owned; not in the Weapons cycle, kept for later
    sets.weapons.BowMacc = {main = "Naegling", sub = "Tauret", range = "Kaja Bow", ammo = empty}  -- Kaja Bow not owned; not in the Weapons cycle, kept for later

    sets.buff.Sublimation = {waist = "Embla Sash"}
    sets.buff.DTSublimation = {waist = "Embla Sash"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.Dagger.Accuracy.Evasion

    -- Normal melee group
    --	sets.engaged = {ammo="Aurgelmir Orb +1",
    --		head="Aya. Zucchetto +2",neck="Asperity Necklace",ear1="Cessance Earring",ear2="Brutal Earring",
    --		body="Ayanmo Corazza +2",hands="Aya. Manopolas +2",ring1="Petrov Ring",ring2="Ilabrat Ring",
    --		back=gear.stp_jse_back,waist="Windbuffet Belt +1",legs="Carmine Cuisses +1",feet="Carmine Greaves +1"}

    sets.engaged = {
        ammo = "Coiste Bodhar",  -- original: "Aurgelmir Orb +1" (not owned)
        head = "Malignance Chapeau",
        neck = "Anu Torque",
        ear1 = "Sherida Earring",  -- original: "Brutal Earring" (stored; Sherida DA+5 STP+5)
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Ilabrat Ring",
        back = gear.stp_jse_back,
        waist = "Sailfi Belt +1",  -- original: "Windbuffet Belt +1" (not owned)
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.EnspellOnly = {
        head = "Malignance Chapeau",
        neck = "Null Loop",  -- original: "Dls. Torque +2" (not owned)
        ear1 = "Suppanomimi",
        ear2 = "Crep. Earring",  -- original: "Digni. Earring" (not owned)
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Chirich Ring +1",  -- original: "Metamor. Ring +1" (both Chirich; Acc/STP for enspell hits)
        ring2 = "Chirich Ring +1",  -- original: "Ramuh Ring +1" (not owned)
        back = "Ghostfyre Cape",
        waist = "Sailfi Belt +1",  -- original: "Windbuffet Belt +1" (not owned)
        legs = "Malignance Tights",  -- original: "Carmine Cuisses +1" (not owned)
        feet = "Malignance Boots"
    }

    sets.engaged.Acc = {
        head = "Malignance Chapeau",
        neck = "Anu Torque",
        ear1 = "Telos Earring",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.stp_jse_back,
        waist = "Sailfi Belt +1",  -- original: "Windbuffet Belt +1" (not owned)
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.FullAcc = {
        ammo = "Coiste Bodhar",  -- original: "Aurgelmir Orb +1" (not owned)
        head = "Malignance Chapeau",
        neck = "Anu Torque",
        ear1 = "Telos Earring",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.stp_jse_back,
        waist = "Sailfi Belt +1",  -- original: "Windbuffet Belt +1" (not owned)
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.DT = {
        ammo = "Coiste Bodhar",  -- original: "Aurgelmir Orb +1" (not owned)
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Telos Earring",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Null Shawl",  -- original: "Moonlight Cape" (not owned)
        waist = "Sailfi Belt +1",  -- original: "Windbuffet Belt +1" (not owned)
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.Acc.DT = {
        ammo = "Coiste Bodhar",  -- original: "Aurgelmir Orb +1" (not owned)
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Telos Earring",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Null Shawl",  -- original: "Moonlight Cape" (not owned)
        waist = "Reiki Yotai",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.FullAcc.DT = {
        ammo = "Coiste Bodhar",  -- original: "Aurgelmir Orb +1" (not owned)
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Telos Earring",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Null Shawl",  -- original: "Moonlight Cape" (not owned)
        waist = "Reiki Yotai",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.DW = {
        ammo = "Coiste Bodhar",  -- original: "Aurgelmir Orb +1" (not owned)
        head = "Malignance Chapeau",
        neck = "Anu Torque",
        ear1 = "Suppanomimi",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Ilabrat Ring",
        back = gear.stp_jse_back,
        waist = "Reiki Yotai",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.DW.Acc = {
        ammo = "Coiste Bodhar",  -- original: "Aurgelmir Orb +1" (not owned)
        head = "Malignance Chapeau",
        neck = "Anu Torque",
        ear1 = "Suppanomimi",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.stp_jse_back,
        waist = "Reiki Yotai",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.DW.FullAcc = {
        ammo = "Coiste Bodhar",  -- original: "Aurgelmir Orb +1" (not owned)
        head = "Malignance Chapeau",
        neck = "Anu Torque",
        ear1 = "Suppanomimi",
        ear2 = "Leth. Earring +1",  -- original: "Telos Earring" (ear1-side, Suppanomimi already there)
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.stp_jse_back,
        waist = "Reiki Yotai",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.DW.DT = {
        ammo = "Coiste Bodhar",  -- original: "Aurgelmir Orb +1" (not owned)
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Suppanomimi",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Null Shawl",  -- original: "Moonlight Cape" (not owned)
        waist = "Reiki Yotai",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.DW.Acc.DT = {
        ammo = "Coiste Bodhar",  -- original: "Aurgelmir Orb +1" (not owned)
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Suppanomimi",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Null Shawl",  -- original: "Moonlight Cape" (not owned)
        waist = "Reiki Yotai",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.DW.FullAcc.DT = {
        ammo = "Coiste Bodhar",  -- original: "Aurgelmir Orb +1" (not owned)
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Suppanomimi",
        ear2 = "Leth. Earring +1",  -- original: "Telos Earring" (ear1-side, Suppanomimi already there)
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Null Shawl",  -- original: "Moonlight Cape" (not owned)
        waist = "Reiki Yotai",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }
end

-- LINKTRI: renamed from job_customize_idle_set, which replaced RDM.lua's own version (Sublimation, latent refresh,
-- TP-eat logic). Sel runs user_job_customize_idle_set after RDM.lua's, so both now work.
function user_job_customize_idle_set(idleSet)
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
-- Default macro set/book
function select_default_macro_book()
    if player.sub_job == "DNC" then
        set_macro_page(1, 5)
    elseif player.sub_job == "NIN" then
        set_macro_page(1, 5)
    elseif player.sub_job == "BLM" then
        set_macro_page(1, 5)
    else
        set_macro_page(1, 5)
    end
end

--Job Specific Trust Overwrite
function check_trust()
    if not moving then
        if
            state.AutoTrustMode.value and not data.areas.cities:contains(world.area) and
                (buffactive["Elvorseal"] or buffactive["Reive Mark"] or not in_combat)  -- was player.in_combat (always nil, so trusts were summoned mid-fight)
         then
            local party = windower.ffxi.get_party()
            if party.p5 == nil then
                local spell_recasts = windower.ffxi.get_spell_recasts()

                if spell_recasts[980] < spell_latency and not have_trust("Yoran-Oran") then
                    windower.chat.input('/ma "Yoran-Oran (UC)" <me>')
                    tickdelay = os.clock() + 3
                    return true
                elseif spell_recasts[984] < spell_latency and not have_trust("August") then
                    windower.chat.input('/ma "August" <me>')
                    tickdelay = os.clock() + 3
                    return true
                elseif spell_recasts[967] < spell_latency and not have_trust("Qultada") then
                    windower.chat.input('/ma "Qultada" <me>')
                    tickdelay = os.clock() + 3
                    return true
                elseif spell_recasts[914] < spell_latency and not have_trust("Ulmia") then
                    windower.chat.input('/ma "Ulmia" <me>')
                    tickdelay = os.clock() + 3
                    return true
                elseif spell_recasts[979] < spell_latency and not have_trust("Selh'teus") then
                    windower.chat.input('/ma "Selh\'teus" <me>')
                    tickdelay = os.clock() + 3
                    return true
                else
                    return false
                end
            end
        end
    end
    return false
end

function user_job_buff_change(buff, gain)
    if buff:startswith("Addendum: ") or buff:endswith(" Arts") then
        style_lock = true
    end
end

-- LINKTRI 2026-10-23: every branch already chose set 005 (RDM's job ID); the per-call res.items scans
-- (item_name_to_id over every item) are no longer needed. Lockstyle runs through the global DressUp hook.
function user_job_lockstyle()
    windower.chat.input("/lockstyleset 005")
end

autows_list = {
    ["Naegling"] = "Savage Blade",
	["DualMpuGandring"] = "Ruthless Stroke",
    ["DualWeapons"] = "Savage Blade",
    ["DualWeaponsAcc"] = "Savage Blade",
    ["DualEvisceration"] = "Evisceration",
    ["DualClubs"] = "Black Halo",
    ["DualAeolian"] = "Aeolian Edge",
    ["EnspellDW"] = "Sanguine Blade"
}