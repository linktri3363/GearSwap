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

    gear.stp_jse_back = {
        name = "Sucellos's Cape",
        augments = {"DEX+20", "Accuracy+20 Attack+20", "Accuracy+10", '"Store TP"+10'}
    }
    gear.nuke_jse_back = {
        name = "Sucellos's Cape",
        augments = {"INT+20", "Mag. Acc+20 /Mag. Dmg.+20", "INT+10", '"Mag.Atk.Bns."+10', "Phys. dmg. taken-10%"}
    }
    gear.wsd_jse_back = {
        name = "Sucellos's Cape",
        augments = {"STR+20", "Accuracy+20 Attack+20", "STR+10", "Weapon skill damage +10%"}
    }

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
        ear1 = "Loquac. Earring",
        ear2 = "Malignance Earring",
        body = "Viti. Tabard +1",
        hands = "Gende. Gages +1",
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",
        back = "Perimede Cape",
        waist = "Witful Belt",
        legs = "Psycloth Lappas",
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
        ear1 = "Cessance Earring",
        ear2 = "Sherida Earring",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Petrov Ring",
        ring2 = "Ilabrat Ring",
        back = gear.wsd_jse_back,
        waist = "Windbuffet Belt +1",
        legs = "Carmine Cuisses +1",
        feet = "Carmine Greaves +1"
    }

    sets.precast.WS.Proc = {
        range = empty,
        ammo = "Hasty Pinion +1",
        head = "Malignance Chapeau",
        neck = "Combatant's Torque",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Ramuh Ring +1",
        ring2 = "Ramuh Ring +1",
        back = gear.wsd_jse_back,
        waist = "Olseni Belt",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS["Requiescat"] = {
        range = empty,
        ammo = "Regal Gem",
        head = "Jhakri Coronal +2",
        neck = "Fotia Gorget",
        ear1 = "Moonshade Earring",
        ear2 = "Sherida Earring",
        body = "Jhakri Robe +2",
        hands = "Atrophy Gloves +3",
        ring1 = "Ifrit Ring +1",
        ring2 = "Rufescent Ring",
        back = gear.wsd_jse_back,
        waist = "Fotia Belt",
        legs = "Jhakri Slops +2",
        feet = "Jhakri Pigaches +2"
    }

    sets.precast.WS["Chant Du Cygne"] = {
        range = empty,
        ammo = "Voluspa Tathlum",
        head = "Malignance Chapeau",
        neck = "Fotia Gorget",
        ear1 = "Moonshade Earring",
        ear2 = "Sherida Earring",
        body = "Ayanmo Corazza +2",
        hands = "Atrophy Gloves +3",
        ring1 = "Begrudging Ring",
        ring2 = "Ilabrat Ring",
        back = gear.wsd_jse_back,
        waist = "Fotia Belt",
        legs = "Carmine Cuisses +1",
        feet = "Thereoid Greaves"
    }

    sets.precast.WS["Evisceration"] = sets.precast.WS["Chant Du Cygne"]

    sets.precast.WS["Savage Blade"] = {
        range = empty,
        ammo = "Sroda Tathlum",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Caro Necklace",
        ear1 = "Moonshade Earring",
        ear2 = "Ishvara Earring",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = "Atrophy Gloves +3",
        ring1 = "Metamor. Ring +1",
        ring2 = "Ilabrat Ring",
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1",
        legs = { name="Nyame Flanchard", augments={'Path: B',}},
        feet = { name="Nyame Sollerets", augments={'Path: B',}}
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
        ring2 = "Archon Ring",
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
        ring2 = "Freke Ring",
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
        ring2 = "Freke Ring",
        back = gear.nuke_jse_back,
        waist = "Orpheus's Sash",
        legs = { name="Nyame Flanchard", augments={'Path: B',}},
        feet = { name="Nyame Sollerets", augments={'Path: B',}}
    }

    -- Midcast Sets

    sets.TreasureHunter = set_combine(sets.TreasureHunter, {feet = gear.chironic_treasure_feet})

    -- Gear that converts elemental damage done to recover MP.
    sets.RecoverMP = {body = "Seidr Cotehardie"}

    -- Gear for Magic Burst mode.
    sets.MagicBurst = {
        main = { name="Bunzi's Rod", augments={'Path: A',}},
        sub = "Ammurapi Shield",
        head = { name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Mizu. Kubikazari",
        body = { name="Bunzi's Robe", augments={'Path: A',}},
        hands = { name="Bunzi's Gloves", augments={'Path: A',}},
        ring1 = "Mujin Band",
        ring2 = "Metamor. Ring +1",
        legs = { name="Bunzi's Pants", augments={'Path: A',}},
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}
    }

    sets.midcast.FastRecast = {
        main = gear.grioavolr_fc_staff,
        sub = "Clerisy Strap +1",
        range = empty,
        ammo = "Hasty Pinion +1",
        head = "Atrophy Chapeau +3",
        neck = "Voltsurge Torque",
        ear1 = "Enchntr. Earring +1",
        ear2 = "Malignance Earring",
        body = "Zendik Robe",
        hands = "Gende. Gages +1",
        ring1 = "Kishar Ring",
        ring2 = "Prolix Ring",
        back = "Swith Cape +1",
        waist = "Witful Belt",
        legs = "Psycloth Lappas",
        feet = "Medium's Sabots"
    }

    sets.midcast.Cure = {
        main = "Daybreak",
        sub = "Sors Shield",
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = { name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "Incanter's Torque",
        ear1 = "Meili Earring",
        ear2 = "Mendi. Earring",
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = { name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1 = "Stikini Ring",
        ring2 = "Menelaus's Ring",
        back = "Tempered Cape +1",
        waist = "Luminary Sash",
        legs = { name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.LightWeatherCure = {
        main = "Chatoyant Staff",
        sub = "Curatio Grip",
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = { name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck = "Incanter's Torque",
        ear1 = "Meili Earring",
        ear2 = "Mendi. Earring",
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = { name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1 = "Stikini Ring",
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
        neck = "Incanter's Torque",
        ear1 = "Meili Earring",
        ear2 = "Mendi. Earring",
        body = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands = { name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1 = "Stikini Ring",
        ring2 = "Menelaus's Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = { name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        feet = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.Cursna = {
        main = gear.grioavolr_fc_staff,
        sub = "Curatio Grip",
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = { name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Debilis Medallion",
        ear1 = "Meili Earring",
        ear2 = "Mendi. Earring",
        body = "Viti. Tabard +1",
        hands = "Hieros Mittens",
        ring1 = "Haoma's Ring",
        ring2 = "Menelaus's Ring",
        back = "Oretan. Cape +1",
        waist = "Witful Belt",
        legs = "Carmine Cuisses +1",
        feet = "Vanya Clogs"
    }

    sets.midcast.StatusRemoval =
        set_combine(sets.midcast.FastRecast, {main = gear.grioavolr_fc_staff, sub = "Clemency Grip"})

    sets.midcast.Curaga = sets.midcast.Cure
    sets.Self_Healing = {
        neck = "Phalaina Locket",
        ear1 = "Etiolation Earring",
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
    sets.Self_Refresh = {back = "Grapevine Cape", waist = "Gishdubar Sash"}

    sets.midcast["Enhancing Magic"] = {
        main = "Colada",
        sub = "Ammurapi Shield",
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = { name="Telchine Cap", augments={'Mag. Acc.+20','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        neck = "Dls. Torque +2",
        ear1 = "Andoaa Earring",
        ear2 = "Gifted Earring",
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
        main = "Pukulatmuj +1",
        head = "Befouled Crown",
        neck = "Incanter's Torque",
        ear2 = "Mimir Earring",
        hands = "Viti. Gloves +1",
        back = { name="Ghostfyre Cape", augments={'Enfb.mag. skill +3','Enha.mag. skill +2','Enh. Mag. eff. dur. +17',}},
        waist = "Olympus Sash",
        legs = "Atrophy Tights +3"
    }
    sets.midcast.Refresh = {head = "Amalric Coif +1", body = "Atrophy Tabard +3", legs = "Leth. Fuseau +3"}
    sets.midcast.Aquaveil = {
        head = "Amalric Coif +1",
        hands = "Regal Cuffs",
        waist = "Emphatikos Rope",
        legs = "Shedir Seraweels"
    }
    sets.midcast.BarElement = {legs = "Shedir Seraweels"}
    sets.midcast.Temper = sets.EnhancingSkill
    sets.midcast.Temper.DW = set_combine(sets.midcast.Temper, {sub = "Pukulatmuj"})
    sets.midcast.Enspell = sets.midcast.Temper
    sets.midcast.Enspell.DW = set_combine(sets.midcast.Enspell, {sub = "Pukulatmuj"})
    sets.midcast.BoostStat = {hands = "Viti. Gloves +1"}
    sets.midcast.Stoneskin = {
        neck = "Nodens Gorget",
        ear2 = "Earthcry Earring",
        waist = "Siegel Sash",
        legs = "Shedir Seraweels"
    }
    sets.midcast.Protect = {ring2 = "Sheltered Ring"}
    sets.midcast.Shell = {ring2 = "Sheltered Ring"}

    sets.midcast["Enfeebling Magic"] = {
        main = { name="Contemplator +1", augments={'Path: A',}},
        sub = "Enki Strap",
        range = empty,
        ammo = "Regal Gem",
        head = "Viti. Chapeau +1",
        neck = "Dls. Torque +2",
        ear1 = "Malignance Earring",
        ear2 = "Snotra Earring",
        body = "Lethargy Sayon +3",
        hands = "Regal Gloves",
        ring1 = "Kishar Ring",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Obstin. Sash",
        legs = "Chironic Hose",
        feet = "Vitiation Boots +1"
    }

    sets.midcast["Enfeebling Magic"].Resistant = {
        main = { name="Contemplator +1", augments={'Path: A',}},
        sub = "Enki Strap",
        range = empty,
        ammo = "Regal Gem",
        head = "Viti. Chapeau +1",
        neck = "Dls. Torque +2",
        ear1 = "Malignance Earring",
        ear2 = "Snotra Earring",
        body = "Atrophy Tabard +3",
        hands = gear.chironic_enfeeble_hands,
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Luminary Sash",
        legs = "Chironic Hose",
        feet = "Vitiation Boots +1"
    }

    sets.midcast.DurationOnlyEnfeebling =
        set_combine(
        sets.midcast["Enfeebling Magic"],
        {main = { name="Bunzi's Rod", augments={'Path: A',}}, sub = "Ammurapi Shield", body = "Atrophy Tabard +3", range = "Kaja Bow"}
    )

    sets.midcast.Silence = sets.midcast.DurationOnlyEnfeebling
    sets.midcast.Silence.Resistant = sets.midcast["Enfeebling Magic"].Resistant
    sets.midcast.Sleep = set_combine(sets.midcast.DurationOnlyEnfeebling, {waist = "Acuity Belt +1"})
    sets.midcast.Sleep.Resistant = set_combine(sets.midcast["Enfeebling Magic"].Resistant, {waist = "Acuity Belt +1"})
    sets.midcast.Bind = set_combine(sets.midcast.DurationOnlyEnfeebling, {waist = "Acuity Belt +1"})
    sets.midcast.Bind.Resistant = set_combine(sets.midcast["Enfeebling Magic"].Resistant, {waist = "Acuity Belt +1"})
    sets.midcast.Break = set_combine(sets.midcast.DurationOnlyEnfeebling, {waist = "Acuity Belt +1"})
    sets.midcast.Break.Resistant = set_combine(sets.midcast["Enfeebling Magic"].Resistant, {waist = "Acuity Belt +1"})

    sets.midcast.Dispel = sets.midcast["Enfeebling Magic"].Resistant

    sets.midcast.SkillBasedEnfeebling =
        set_combine(
        sets.midcast["Enfeebling Magic"],
        {ear1 = "Vor Earring", hands = "Leth. Ganth. +3", ring1 = "Stikini Ring", legs = "Psycloth Lappas"}
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
        ammo = "Ghastly Tathlum +1",
        head = { name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Baetyl Pendant",
        ear1 = "Crematio Earring",
        ear2 = "Malignance Earring",
        body = { name="Bunzi's Robe", augments={'Path: A',}},
        hands = { name="Bunzi's Gloves", augments={'Path: A',}},
        ring1 = "Metamor. Ring +1",
        ring2 = "Freke Ring",
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
        neck = "Dls. Torque +2",
        ear1 = "Malignance Earring",
        ear2 = "Crematio Earring",
        body = { name="Bunzi's Robe", augments={'Path: A',}},
        hands = { name="Bunzi's Gloves", augments={'Path: A',}},
        ring1 = "Metamor. Ring +1",
        ring2 = "Freke Ring",
        back = gear.nuke_jse_back,
        waist = "Yamabuki-no-Obi",
        legs = { name="Bunzi's Pants", augments={'Path: A',}},
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}
    }

    sets.midcast["Elemental Magic"].Fodder = {
        main = { name="Bunzi's Rod", augments={'Path: A',}},
        sub = "Ammurapi Shield",
        range = empty,
        ammo = "Ghastly Tathlum +1",
        head = { name="Bunzi's Hat", augments={'Path: A',}},
        neck = "Baetyl Pendant",
        ear1 = "Crematio Earring",
        ear2 = "Malignance Earring",
        body = { name="Bunzi's Robe", augments={'Path: A',}},
        hands = { name="Bunzi's Gloves", augments={'Path: A',}},
        ring1 = "Metamor. Ring +1",
        ring2 = "Freke Ring",
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
        head = "Vanya Hood",
        neck = "Voltsurge Torque",
        ear1 = "Enchntr. Earring +1",
        ear2 = "Loquac. Earring",
        body = "Zendik Robe",
        hands = "Gende. Gages +1",
        ring1 = "Kishar Ring",
        ring2 = "Prolix Ring",
        back = "Swith Cape +1",
        waist = "Witful Belt",
        legs = "Psycloth Lappas",
        feet = "Regal Pumps +1"
    }

    sets.midcast["Elemental Magic"].HighTierNuke =
        set_combine(
        sets.midcast["Elemental Magic"],
        {head = gear.merlinic_nuke_head, ammo = "Pemphredo Tathlum", ear1 = "Regal Earring", ring1 = "Metamor. Ring +1"}
    )
    sets.midcast["Elemental Magic"].HighTierNuke.Resistant =
        set_combine(
        sets.midcast["Elemental Magic"].Resistant,
        {head = gear.merlinic_nuke_head, ear1 = "Regal Earring", ring1 = "Metamor. Ring +1"}
    )
    sets.midcast["Elemental Magic"].HighTierNuke.Fodder =
        set_combine(
        sets.midcast["Elemental Magic"].Fodder,
        {head = gear.merlinic_nuke_head, ammo = "Pemphredo Tathlum", ear1 = "Regal Earring", ring1 = "Metamor. Ring +1"}
    )

    sets.midcast.Impact = {
        main = { name="Bunzi's Rod", augments={'Path: A',}},
        sub = "Ammurapi Shield",
        range = "Kaja Bow",
        ammo = empty,
        head = empty,
        neck = "Erra Pendant",
        ear1 = "Malignance Earring",
        ear2 = "Snotra Earring",
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
        range = "Kaja Bow",
        ammo = empty,
        head = "Amalric Coif +1",
        neck = "Erra Pendant",
        ear1 = "Malignance Earring",
        ear2 = "Snotra Earring",
        body = "Atrophy Tabard +3",
        hands = "Leth. Ganth. +3",
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Luminary Sash",
        legs = "Psycloth Lappas",
        feet = { name="Bunzi's Sabots", augments={'Path: A',}}
    }

    sets.midcast.Drain = {
        main = "Rubicundity",
        sub = "Ammurapi Shield",
        range = "Kaja Bow",
        ammo = empty,
        head = "Pixie Hairpin +1",
        neck = "Erra Pendant",
        ear1 = "Malignance Earring",
        ear2 = "Snotra Earring",
        body = { name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9',}},
        hands = gear.chironic_enfeeble_hands,
        ring1 = "Evanescence Ring",
        ring2 = "Archon Ring",
        back = gear.nuke_jse_back,
        waist = "Fucho-no-obi",
        legs = "Chironic Hose",
        feet = gear.merlinic_aspir_feet
    }

    sets.midcast.Aspir = sets.midcast.Drain

    sets.midcast.Stun = {
        main = { name="Bunzi's Rod", augments={'Path: A',}},
        sub = "Ammurapi Shield",
        range = "Kaja Bow",
        ammo = empty,
        head = "Atrophy Chapeau +3",
        neck = "Dls. Torque +2",
        ear1 = "Malignance Earring",
        ear2 = "Snotra Earring",
        body = "Zendik Robe",
        hands = "Volte Gloves",
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Chironic Hose",
        feet = gear.merlinic_aspir_feet
    }

    sets.midcast.Stun.Resistant = {
        main = { name="Bunzi's Rod", augments={'Path: A',}},
        sub = "Ammurapi Shield",
        range = "Kaja Bow",
        ammo = empty,
        head = "Atrophy Chapeau +3",
        neck = "Dls. Torque +2",
        ear1 = "Malignance Earring",
        ear2 = "Snotra Earring",
        body = "Atrophy Tabard +3",
        hands = "Volte Gloves",
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Acuity Belt +1",
        legs = "Chironic Hose",
        feet = gear.merlinic_aspir_feet
    }

    -- Sets for special buff conditions on spells.

    sets.buff.Saboteur = {hands = "Leth. Ganth. +3"}

    sets.HPDown = {
        head = "Pixie Hairpin +1",
        ear1 = "Mendicant's Earring",
        ear2 = "Evans Earring",
        body = "Jhakri Robe +2",
        hands = "Jhakri Cuffs +2",
        ring1 = "Mephitas's Ring +1",
        ring2 = "Mephitas's Ring",
        back = "Swith Cape +1",
        legs = "Shedir Seraweels",
        feet = "Jhakri Pigaches +2"
    }

    sets.HPCure = {
        main = "Daybreak",
        sub = "Sors Shield",
        range = empty,
        ammo = "Hasty Pinion +1",
        head = "Gende. Caubeen +1",
        neck = "Unmoving Collar +1",
        ear1 = "Gifted Earring",
        ear2 = "Mendi. Earring",
        body = "Viti. Tabard +1",
        hands = "Kaykaus Cuffs",
        ring1 = "Gelatinous Ring +1",
        ring2 = "Meridian Ring",
        back = "Moonlight Cape",
        waist = "Luminary Sash",
        legs = "Carmine Cuisses +1",
        feet = "Kaykaus Boots"
    }

    sets.buff.Doom = set_combine(sets.buff.Doom, {})

    -- Sets to return to when not performing an action.

    -- Resting sets
    sets.resting = {
        main = "Chatoyant Staff",
        sub = "Oneiros Grip",
        range = empty,
        ammo = "Impatiens",
        head = "Viti. Chapeau +1",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Jhakri Robe +2",
        hands = gear.merlinic_refresh_hands,
        ring1 = "Defending Ring",
        ring2 = "Sheltered Ring",
        back = "Umbra Cape",
        waist = "Flume Belt +1",
        legs = "Lengo Pants",
        feet = gear.chironic_refresh_feet
    }

    -- Idle sets
    sets.idle = {
        main = "Mpaca's Staff",
        sub = "Umbra Strap",
        range = empty,
        ammo = "Homiliary",
        head = "Viti. Chapeau +1",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = { name="Alabaster Earring", augments={'Path: A',}},
        body = "Jhakri Robe +2",
        hands = gear.merlinic_refresh_hands,
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = "Umbra Cape",
        waist = "Flume Belt +1",
        legs = { name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',}},
        feet = gear.merlinic_refresh_feet
    }

    sets.idle.PDT = {
        main = "Terra's Staff",
        sub = "Umbra Strap",
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
        back = "Moonlight Cape",
        waist = "Flume Belt +1",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.idle.MDT = {
        main = "Daybreak",
        sub = "Sacro Bulwark",
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = "Malignance Chapeau",
        neck = "Warder's Charm +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Moonlight Cape",
        waist = "Carrier's Sash",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }


    sets.idle.Weak = {
        main = "Bolelabunga",
        sub = "Sacro Bulwark",
        range = empty,
        ammo = "Homiliary",
        head = "Viti. Chapeau +1",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = { name="Alabaster Earring", augments={'Path: A',}},
        body = "Jhakri Robe +2",
        hands = gear.merlinic_refresh_hands,
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Umbra Cape",
        waist = "Flume Belt +1",
        legs = { name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',}},
        feet = gear.chironic_refresh_feet
    }

    sets.idle.DTHippo =
        set_combine(sets.idle.PDT, {back = "Umbra Cape", legs = "Carmine Cuisses +1", feet = "Hippo. Socks +1"})

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
        back  = "Umbra Cape",
        waist = "Fucho-no-obi",
        legs  = "Nyame Flanchard",
        feet  = "Nyame Sollerets"
    }

    -- Defense sets
    sets.defense.PDT = {
        main = "Terra's Staff",
        sub = "Umbra Strap",
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
        back = "Moonlight Cape",
        waist = "Flume Belt +1",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.defense.NukeLock = sets.midcast["Elemental Magic"]

    sets.defense.MDT = {
        main = "Bolelabunga",
        sub = "Sacro Bulwark",
        range = empty,
        ammo = "Staunch Tathlum +1",
        head = "Malignance Chapeau",
        neck = "Warder's Charm +1",
        ear1 = "Etiolation Earring",
        ear2 = { name="Alabaster Earring", augments={'Path: A',}},
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Moonlight Cape",
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
        neck = "Warder's Charm +1",
        ear1 = "Etiolation Earring",
        ear2 = { name="Alabaster Earring", augments={'Path: A',}},
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Moonlight Cape",
        waist = "Carrier's Sash",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.Kiting = {ring1 = "Shneddick Ring +1"}
    sets.latent_refresh = {waist = "Fucho-no-obi"}
    sets.latent_refresh_grip = {sub = "Oneiros Grip"}
    sets.TPEat = {neck = "Chrys. Torque"}
    sets.DayIdle = {}
    sets.NightIdle = {}

    -- Weapons sets
    sets.weapons.Naegling = {main = "Naegling", sub = "Thibron", range = empty}
	sets.weapons.DualMpuGandring = {main = "Mpu Gandring", sub = "Thibron", range = empty}
    sets.weapons.DualWeapons = {main = "Vorpal Sword", sub = "Qutrub Knife", range = empty}
    sets.weapons.DualWeaponsAcc = {main = "Naegling", sub = "Almace", range = empty}
    sets.weapons.DualEvisceration = {main = "Tauret", sub = "Almace", range = empty}
    sets.weapons.DualAeolian = {main = "Tauret", sub = "Bunzi's Rod", range = empty}
    sets.weapons.DualProcDaggers = {main = "Blurred Knife +1", sub = "Atoyac", range = empty}
    sets.weapons.EnspellOnly = {main = "Norgish Dagger", sub = "Aern Dagger", range = "Kaja Bow", ammo = "Beetle Arrow"}
    sets.weapons.EnspellDW = {main = "Blurred Knife +1", sub = "Atoyac", range = "Kaja Bow", ammo = "Beetle Arrow"}
    sets.weapons.DualClubs = {main = "Maxentius", sub = "Thibron", range = empty}
    sets.weapons.DualAlmace = {main = "Almace", sub = "Sequence", range = empty}
    sets.weapons.DualBow = {main = "Naegling", sub = "Tauret", range = "Kaja Bow"}
    sets.weapons.BowMacc = {main = "Naegling", sub = "Tauret", range = "Kaja Bow", ammo = empty}

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
        ammo = "Aurgelmir Orb +1",
        head = "Malignance Chapeau",
        neck = "Anu Torque",
        ear1 = "Brutal Earring",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Ilabrat Ring",
        back = gear.stp_jse_back,
        waist = "Windbuffet Belt +1",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.EnspellOnly = {
        head = "Malignance Chapeau",
        neck = "Dls. Torque +2",
        ear1 = "Suppanomimi",
        ear2 = "Digni. Earring",
        body = "Ayanmo Corazza +2",
        hands = "Aya. Manopolas +2",
        ring1 = "Metamor. Ring +1",
        ring2 = "Ramuh Ring +1",
        back = "Ghostfyre Cape",
        waist = "Windbuffet Belt +1",
        legs = "Carmine Cuisses +1",
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
        waist = "Windbuffet Belt +1",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.FullAcc = {
        ammo = "Aurgelmir Orb +1",
        head = "Malignance Chapeau",
        neck = "Anu Torque",
        ear1 = "Telos Earring",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.stp_jse_back,
        waist = "Windbuffet Belt +1",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.DT = {
        ammo = "Aurgelmir Orb +1",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Telos Earring",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Moonlight Cape",
        waist = "Windbuffet Belt +1",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.Acc.DT = {
        ammo = "Aurgelmir Orb +1",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Telos Earring",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Moonlight Cape",
        waist = "Reiki Yotai",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.FullAcc.DT = {
        ammo = "Aurgelmir Orb +1",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Telos Earring",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Moonlight Cape",
        waist = "Reiki Yotai",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.DW = {
        ammo = "Aurgelmir Orb +1",
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
        ammo = "Aurgelmir Orb +1",
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
        ammo = "Aurgelmir Orb +1",
        head = "Malignance Chapeau",
        neck = "Anu Torque",
        ear1 = "Suppanomimi",
        ear2 = "Telos Earring",
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
        ammo = "Aurgelmir Orb +1",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Suppanomimi",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Moonlight Cape",
        waist = "Reiki Yotai",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.DW.Acc.DT = {
        ammo = "Aurgelmir Orb +1",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Suppanomimi",
        ear2 = "Leth. Earring +1",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Moonlight Cape",
        waist = "Reiki Yotai",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.DW.FullAcc.DT = {
        ammo = "Aurgelmir Orb +1",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Suppanomimi",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A',}},
        back = "Moonlight Cape",
        waist = "Reiki Yotai",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
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
                (buffactive["Elvorseal"] or buffactive["Reive Mark"] or not player.in_combat)
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

function user_job_lockstyle()
    if player.sub_job == "NIN" or player.sub_job == "DNC" then
        local main_skill = get_weapon_skill(player.equipment.main)
        local sub_skill = get_weapon_skill(player.equipment.sub)
        
        -- If no main weapon or can't determine skill, use default
        if not main_skill then
            windower.chat.input("/lockstyleset 005")
            return
        end
        
        if main_skill == 3 then -- Sword in main hand
            if sub_skill == 3 then -- Sword/Sword
                windower.chat.input("/lockstyleset 005")
            elseif sub_skill == 2 then -- Sword/Dagger
                windower.chat.input("/lockstyleset 005")
            elseif sub_skill == 11 then -- Sword/Club
                windower.chat.input("/lockstyleset 005")
            else
                windower.chat.input("/lockstyleset 005") -- Catchall
            end
        elseif main_skill == 2 then -- Dagger in main hand
            if sub_skill == 3 then -- Dagger/Sword
                windower.chat.input("/lockstyleset 005")
            elseif sub_skill == 2 then -- Dagger/Dagger
                windower.chat.input("/lockstyleset 005")
            elseif sub_skill == 11 then -- Dagger/Club
                windower.chat.input("/lockstyleset 005")
            else
                windower.chat.input("/lockstyleset 005") -- Catchall
            end
        elseif main_skill == 11 then -- Club in main hand
            if sub_skill == 3 then -- Club/Sword
                windower.chat.input("/lockstyleset 005")
            elseif sub_skill == 2 then -- Club/Dagger
                windower.chat.input("/lockstyleset 005")
            elseif sub_skill == 11 then -- Club/Club
                windower.chat.input("/lockstyleset 005")
            else
                windower.chat.input("/lockstyleset 005") -- Catchall
            end
        else
            windower.chat.input("/lockstyleset 005") -- Unknown weapon type catchall
        end
    elseif player.sub_job == "WHM" or state.Buff["Light Arts"] or state.Buff["Addendum: White"] then
        windower.chat.input("/lockstyleset 005")
    elseif player.sub_job == "BLM" or state.Buff["Dark Arts"] or state.Buff["Addendum: Black"] then
        windower.chat.input("/lockstyleset 005")
    else
        windower.chat.input("/lockstyleset 005")
    end
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