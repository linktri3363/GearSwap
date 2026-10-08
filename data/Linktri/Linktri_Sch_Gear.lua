-------------------------------------------------------------------------------------------------------------------
-- Skillchain Window Tracking for Magic Burst (Auto-Detection System)
-------------------------------------------------------------------------------------------------------------------
SCWindowOpen = false
SCWindowTimer = 0
SC_WINDOW_DURATION = 10  -- Skillchain window lasts ~10 seconds

-------------------------------------------------------------------------------------------------------------------
-- Position Fix for Casting Interruptions
-------------------------------------------------------------------------------------------------------------------
fixed_pos = ''
fixed_ts = os.time()
local no_interruptions = true
local near_porter = false  -- Track Porter Moogle proximity state
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

-------------------------------------------------------------------------------------------------------------------
-- Skillchain Detection Functions
-------------------------------------------------------------------------------------------------------------------
-- Function to check incoming actions for skillchain resonance
function check_skillchain(act)
    -- Category 3 = Weaponskill, Category 4 = Magic finish, Category 11 = Monster TP move
    if act.category == 3 or act.category == 4 or act.category == 11 then
        for _, target in ipairs(act.targets) do
            for _, action in ipairs(target.actions) do
                if action.has_add_effect and action.add_effect_animation and action.add_effect_animation > 0 then
                    -- Skillchain detected! Open the window
                    SCWindowOpen = true
                    SCWindowTimer = os.clock()
                    windower.add_to_chat(121, '[GearSwap] SKILLCHAIN DETECTED - MAGIC BURST WINDOW NOW OPEN')
                end
            end
        end
    end
end

-- Function to check if SC window is still valid
function is_sc_window_open()
    if SCWindowOpen then
        local elapsed = os.clock() - SCWindowTimer
        if elapsed < SC_WINDOW_DURATION then
            return true
        else
            SCWindowOpen = false
            return false
        end
    end
    return false
end

-------------------------------------------------------------------------------------------------------------------
-- User Job Setup
-------------------------------------------------------------------------------------------------------------------
-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_job_setup()
    state.OffenseMode:options("Normal")
    state.CastingMode:options("Normal", "Resistant", "Proc", "OccultAcumen", "9k")
    state.IdleMode:options("Normal", "PDT")
    state.HybridMode:options("Normal", "PDT")
    state.Weapons:options("None", "Akademos", "Khatvanga")

    -- Auto Magic Burst Mode toggle (enabled by default)
    state.AutoMBMode = M(true, 'Auto MB Mode')

    gear.nuke_jse_back={ name="Lugh's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10','Spell interruption rate down-10%',}}

    -- Additional local binds
    send_command("bind ^` gs c cycle ElementalMode")
    send_command("bind !` gs c scholar power")
    send_command("bind @` gs c cycle MagicBurstMode")
    send_command("bind ^q gs c weapons Khatvanga;gs c set CastingMode OccultAcumen")
    send_command("bind !q gs c weapons default;gs c reset CastingMode")
    send_command("bind @f10 gs c cycle RecoverMode")
    send_command("bind @f8 gs c toggle AutoNukeMode")
    send_command("bind !pause gs c toggle AutoSubMode") --Automatically uses sublimation and Myrkr.
    send_command('bind @^` input /ja "Parsimony" <me>')
    send_command('bind ^backspace input /ma "Stun" <t>')
    send_command("bind !backspace gs c scholar speed")
    send_command("bind @backspace gs c scholar aoe")
    send_command('bind ^= input /ja "Dark Arts" <me>')
    send_command('bind != input /ja "Light Arts" <me>')
    send_command('bind ^\\\\ input /ma "Protect V" <t>')
    send_command('bind @\\\\ input /ma "Shell V" <t>')
    send_command('bind !\\\\ input /ma "Reraise III" <me>')
    -- Auto MB Mode toggle keybind
    send_command('bind @f7 gs c toggle AutoMBMode')

    -- Register for action packets to detect skillchains
    windower.raw_register_event('action', function(act)
        check_skillchain(act)
    end)

    select_default_macro_book()
end

-------------------------------------------------------------------------------------------------------------------
-- User Job Post Midcast - Handle Automatic Magic Burst Detection
-------------------------------------------------------------------------------------------------------------------
function user_job_post_midcast(spell, action, spellMap, eventArgs)
    -- Check for automatic MB when AutoMBMode is enabled
    -- Exclude ElementalEnfeeble spells (Burn, Choke, Shock, Drown, Frost, Rasp) from MB logic
    if spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble' and state.AutoMBMode.value and is_sc_window_open() then
        -- Check current casting mode for Resistant vs Normal MB set
        if state.CastingMode.value == 'Resistant' then
            -- Check if it's a Helix spell for specialized burst set
            if spell.english:startswith('Helix') then
                windower.add_to_chat(121, '[GearSwap] Auto-MB: SC Window Active - Equipping Resistant Helix Burst set for: '..spell.english)
                equip(sets.ResistantHelixBurst)
            else
                windower.add_to_chat(121, '[GearSwap] Auto-MB: SC Window Active - Equipping Resistant MB set for: '..spell.english)
                equip(sets.ResistantMagicBurst)
            end
        else
            -- Check if it's a Helix spell for specialized burst set
            if spell.english:startswith('Helix') then
                windower.add_to_chat(121, '[GearSwap] Auto-MB: SC Window Active - Equipping Helix Burst set for: '..spell.english)
                equip(sets.HelixBurst)
            else
                windower.add_to_chat(121, '[GearSwap] Auto-MB: SC Window Active - Equipping MB set for: '..spell.english)
                equip(sets.MagicBurst)
            end
        end
        -- Close the window after use (single burst behavior)
        SCWindowOpen = false
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Define sets and vars used by this job file.
-------------------------------------------------------------------------------------------------------------------
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Precast Sets

    -- Precast sets to enhance JAs

    sets.precast.JA["Tabula Rasa"] = {legs = "Peda. Pants +3"}
    sets.precast.JA["Enlightenment"] = {body="Peda. Gown +3"} 

    sets.precast.FC = {
        main = gear.grioavolr_fc_staff,
        sub = "Clerisy Strap +1",
        ammo = "Impatiens",
        head = "Agwu's Cap", 
        neck = "Voltsurge Torque",
        ear1 = "Malignance Earring",
		ear2 = "Enchntr. Earring +1",
        body = "Zendik Robe",
        hands = "Arbatel Bracers +3",
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",
        back = "Perimede Cape",
        waist = "Witful Belt",
        legs = "Psycloth Lappas",
        feet = "Regal Pumps +1"
    }

    sets.precast.FC.Arts = {}

    sets.precast.FC["Enhancing Magic"] = set_combine(sets.precast.FC, {waist = "Siegel Sash"})

    sets.precast.FC["Elemental Magic"] = set_combine(sets.precast.FC, {ear1 = "Malignance Earring"})  -- FIXED: Was ear1, caused slot conflict

    sets.precast.FC.Cure =
        set_combine(sets.precast.FC, {main = "Serenity", sub = "Clerisy Strap +1", body = "Heka's Kalasiris"})

    sets.precast.FC.Curaga = sets.precast.FC.Cure

    sets.precast.FC.Impact = set_combine(sets.precast.FC["Elemental Magic"], {head = empty, body = "Twilight Cloak"})
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main = "Daybreak", sub = "Genmei Shield"})

    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    -- CORRECTED: Replaced missing items with inventory equivalents
    sets.precast.WS["Myrkr"] = {
        ammo = "Pemphredo Tathlum",  -- CORRECTED: Was Ghastly Tathlum +1
        head = "Arbatel Bonnet +3",  -- CORRECTED: Was Pixie Hairpin +1 (keep if you have it for dark)
        neck = "Sanctity Necklace",
        ear1 = "Evans Earring",
        ear2 = "Etiolation Earring",
        body = "Agwu's Robe",  -- CORRECTED: Was Amalric Doublet +1
        hands = "Regal Cuffs",
        ring1 = "Mephitas's Ring +1",
        ring2 = "Mephitas's Ring",
        back = "Aurist's Cape +1",
        waist = "Luminary Sash",
        legs = "Psycloth Lappas",
        feet={ name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}},
    }

    -- Midcast Sets

    sets.TreasureHunter = set_combine(sets.TreasureHunter, {feet = gear.chironic_treasure_feet})

    -- Gear that converts elemental damage done to recover MP.
    sets.RecoverMP = {body = "Seidr Cotehardie"}

    -- Gear for specific elemental nukes.
    -- NOTE: Pixie Hairpin +1 and Archon Ring - verify you own these for dark damage boost
    sets.element.Dark = {head = "Pixie Hairpin +1", ring2 = "Archon Ring"}

    -- CORRECTED: Replaced Amalric Coif +1 with Agwu's Cap
    sets.midcast.FastRecast = {
        main = gear.grioavolr_fc_staff,
        sub = "Clerisy Strap +1",
        ammo = "Hasty Pinion +1",
        head = "Agwu's Cap",  -- CORRECTED: Was Amalric Coif +1
        neck = "Voltsurge Torque",
        ear1 = "Malignance Earring",
		ear2 = "Enchntr. Earring +1",
        body = "Zendik Robe",
        hands = "Gende. Gages +1",
        ring1 = "Kishar Ring",
        ring2 = "Prolix Ring",
        back = "Swith Cape +1",
        waist = "Witful Belt",
        legs = "Psycloth Lappas",
        feet = "Regal Pumps +1"
    }

    sets.midcast.Cure = {
        main = "Serenity",
        sub = "Curatio Grip",
        ammo = "Hasty Pinion +1",
        head = "Gende. Caubeen +1",
        neck = "Incanter's Torque",
        ear1 = "Malignance Earring",
		ear2 = "Meili Earring",
        body={ name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands={ name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1 = "Janniston Ring",
        ring2 = "Lebeche Ring",
        back = "Tempered Cape +1",
        waist = "Luminary Sash",
        legs = "Chironic Hose",
        feet={ name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}},
    }

    sets.midcast.LightWeatherCure = {
        main = "Chatoyant Staff",
        sub = "Curatio Grip",
        ammo = "Hasty Pinion +1",
        head = "Gende. Caubeen +1",
        neck = "Incanter's Torque",
        ear1 = "Malignance Earring",
		ear2 = "Meili Earring",
        body={ name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands={ name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1 = "Janniston Ring",
        ring2 = "Lebeche Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = "Chironic Hose",
        feet={ name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}},
    }

    sets.midcast.LightDayCure = {
        main = "Serenity",
        sub = "Curatio Grip",
        ammo = "Hasty Pinion +1",
        head = "Gende. Caubeen +1",
        neck = "Incanter's Torque",
        ear1 = "Malignance Earring",
		ear2 = "Meili Earring",
        body={ name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands={ name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1 = "Janniston Ring",
        ring2 = "Lebeche Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = "Chironic Hose",
        feet={ name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}},
    }

    sets.midcast.Curaga = sets.midcast.Cure

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

    -- CORRECTED: Replaced Amalric Coif +1 with Agwu's Cap
    sets.midcast.Cursna = {
        main = gear.grioavolr_fc_staff,
        sub = "Clemency Grip",
        ammo = "Hasty Pinion +1",
        head = "Agwu's Cap",  -- CORRECTED: Was Amalric Coif +1
        neck = "Debilis Medallion",
        ear1 = "Malignance Earring",
		ear2 = "Meili Earring",
        body = "Zendik Robe",
        hands = "Hieros Mittens",
        ring1 = "Haoma's Ring",
        ring2 = "Menelaus's Ring",
        back = "Oretan. Cape +1",
        waist = "Witful Belt",
        legs = "Psycloth Lappas",
        feet = "Vanya Clogs"
    }

    sets.midcast.StatusRemoval =
        set_combine(sets.midcast.FastRecast, {main = gear.grioavolr_fc_staff, sub = "Clemency Grip"})

    sets.midcast["Enhancing Magic"] = {
        main = gear.gada_enhancing_club,
        sub = "Ammurapi Shield",
        ammo = "Savant's Treatise",
        head = "Telchine Cap",
        neck = "Incanter's Torque",
        ear1 = "Andoaa Earring",
        ear2 = "Gifted Earring",
        body = "Telchine Chas.",
        hands = "Telchine Gloves",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = "Perimede Cape",
        waist = "Embla Sash",
        legs = "Telchine Braconi",
        feet = "Telchine Pigaches"
    }

    sets.midcast.Regen = set_combine(sets.midcast["Enhancing Magic"], {back = gear.nuke_jse_back})

    sets.midcast.Stoneskin =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {neck = "Nodens Gorget", ear2 = "Earthcry Earring", waist = "Siegel Sash", legs = "Shedir Seraweels"}
    )

    -- CORRECTED: Replaced Amalric Coif +1 with Agwu's Cap
    sets.midcast.Refresh = set_combine(sets.midcast["Enhancing Magic"], {head = "Agwu's Cap"})  -- CORRECTED: Was Amalric Coif +1

    -- CORRECTED: Replaced Amalric Coif +1 with Agwu's Cap
    sets.midcast.Aquaveil =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {
            main = "Vadose Rod",
            sub = "Genmei Shield",
            head = "Agwu's Cap",  -- CORRECTED: Was Amalric Coif +1
            hands = "Regal Cuffs",
            waist = "Emphatikos Rope",
            legs = "Shedir Seraweels"
        }
    )

    sets.midcast.BarElement = set_combine(sets.precast.FC["Enhancing Magic"], {legs = "Shedir Seraweels"})

    sets.midcast.Storm = set_combine(sets.midcast["Enhancing Magic"], {feet = "Peda. Loafers +3"})

    sets.midcast.Protect = set_combine(sets.midcast["Enhancing Magic"], {ring2 = "Sheltered Ring"})
    sets.midcast.Protectra = sets.midcast.Protect

    sets.midcast.Shell = set_combine(sets.midcast["Enhancing Magic"], {ring2 = "Sheltered Ring"})
    sets.midcast.Shellra = sets.midcast.Shell

    -- Custom spell classes

    -- CORRECTED: Replaced Acad. Mortar. +4 with Arbatel Bonnet +3, Regal Earring with Arbatel Earring +1
    sets.midcast["Enfeebling Magic"] = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Arbatel Bonnet +3",  -- CORRECTED: Was Acad. Mortar. +4
        neck = "Erra Pendant",
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",  -- CORRECTED: Was Regal Earring
        body = "Chironic Doublet",
        hands = "Regal Cuffs",
        ring1 = "Kishar Ring",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Obstin. Sash",
        legs = "Chironic Hose",
        feet = "Uk'uxkaj Boots"
    }

    -- CORRECTED: Replaced Acad. Mortar. +4, Regal Earring, Acad. Bracers +3
    sets.midcast["Enfeebling Magic"].Resistant = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Arbatel Bonnet +3",  -- CORRECTED: Was Acad. Mortar. +4
        neck = "Erra Pendant",
        ear1 = "Digni. Earring",
		ear2 = "Arbatel Earring +1",  -- CORRECTED: Was Regal Earring
        body = "Chironic Doublet",
        hands = "Arbatel Bracers +3",  -- CORRECTED: Was Acad. Bracers +4
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Luminary Sash",
        legs = "Chironic Hose",
        feet = "Medium's Sabots"
    }

    -- CORRECTED: Replaced Amalric Coif +1 with Agwu's Cap
    sets.midcast.ElementalEnfeeble =
        set_combine(
        sets.midcast["Enfeebling Magic"],
        {head = "Agwu's Cap", ear1 = "Malignance Earring", back = gear.nuke_jse_back, waist = "Acuity Belt +1"}  -- CORRECTED: Was Amalric Coif +1
    )
    sets.midcast.ElementalEnfeeble.Resistant =
        set_combine(
        sets.midcast["Enfeebling Magic"].Resistant,
        {head = "Agwu's Cap", back = gear.nuke_jse_back, waist = "Acuity Belt +1"}  -- CORRECTED: Was Amalric Coif +1
    )

    -- CORRECTED: Replaced Amalric Coif +1 with Agwu's Cap
    sets.midcast.IntEnfeebles =
        set_combine(
        sets.midcast["Enfeebling Magic"],
        {head = "Agwu's Cap", ear1 = "Malignance Earring", back = gear.nuke_jse_back, waist = "Acuity Belt +1"}  -- CORRECTED: Was Amalric Coif +1, FIXED ear slot
    )
    sets.midcast.IntEnfeebles.Resistant =
        set_combine(
        sets.midcast["Enfeebling Magic"].Resistant,
        {head = "Agwu's Cap", back = gear.nuke_jse_back, waist = "Acuity Belt +1"}  -- CORRECTED: Was Amalric Coif +1
    )

    sets.midcast.MndEnfeebles = set_combine(sets.midcast["Enfeebling Magic"], {})
    sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast["Enfeebling Magic"].Resistant, {})

    sets.midcast.Dia = set_combine(sets.midcast["Enfeebling Magic"], sets.TreasureHunter)
    sets.midcast.Diaga = set_combine(sets.midcast["Enfeebling Magic"], sets.TreasureHunter)
    sets.midcast["Dia II"] = sets.midcast["Enfeebling Magic"]
    sets.midcast.Bio = set_combine(sets.midcast["Enfeebling Magic"], sets.TreasureHunter)
    sets.midcast["Bio II"] = sets.midcast["Enfeebling Magic"]

    sets.midcast["Divine Magic"] =
        set_combine(sets.midcast["Enfeebling Magic"], {ring2 = "Stikini Ring", feet = gear.chironic_nuke_feet})

    -- CORRECTED: Replaced Amalric Coif +1, Regal Earring, Acad. Bracers +4
    sets.midcast["Dark Magic"] = {
        main = "Rubicundity",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Agwu's Cap",  -- CORRECTED: Was Amalric Coif +1
        neck = "Incanter's Torque",
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",  -- CORRECTED: Was Regal Earring
        body = "Chironic Doublet",
        hands = "Arbatel Bracers +3",  -- CORRECTED: Was Acad. Bracers +4
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Acuity Belt +1",
        legs = "Chironic Hose",
        feet = gear.merlinic_aspir_feet
    }

    -- CORRECTED: Replaced Amalric Gages +1, Freke Ring, Archon Ring, Amalric Nails +1
    -- NOTE: Keeping Pixie Hairpin +1 for dark boost - verify you own it
    sets.midcast.Kaustra = {
        main = "Akademos",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = "Pixie Hairpin +1",  -- Keep for dark boost if you have it, otherwise use Agwu's Cap
        neck = "Saevus Pendant +1",
        ear1 = "Malignance Earring",
		ear2 = "Crematio Earring",
        body = gear.merlinic_nuke_body,
        hands = "Agwu's Gages",  -- CORRECTED: Was Amalric Gages +1
        ring1 = "Metamor. Ring +1",  -- CORRECTED: Was Freke Ring
        ring2 = "Archon Ring",  -- Keep if you have it for dark boost
        back = gear.nuke_jse_back,
        waist = "Refoccilation Stone",
        legs = "Merlinic Shalwar",
        feet = "Agwu's Pigaches"  -- CORRECTED: Was Amalric Nails +1
    }

    -- CORRECTED: Replaced Amalric Gages +1, Shiva Ring +1, Freke Ring, Amalric Nails +1
    sets.midcast.Kaustra.Resistant = {
        main = gear.grioavolr_nuke_staff,
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = gear.merlinic_nuke_head,
        neck = "Erra Pendant",
        ear1 = "Malignance Earring",
		ear2 = "Crematio Earring",
        body = gear.merlinic_nuke_body,
        hands = "Agwu's Gages",  -- CORRECTED: Was Amalric Gages +1
        ring1 = "Stikini Ring",  -- CORRECTED: Was Shiva Ring +1
        ring2 = "Metamor. Ring +1",  -- CORRECTED: Was Freke Ring
        back = gear.nuke_jse_back,
        waist = "Acuity Belt +1",
        legs = "Merlinic Shalwar",
        feet = "Agwu's Pigaches"  -- CORRECTED: Was Amalric Nails +1
    }

    -- CORRECTED: Replaced Regal Earring, Acad. Bracers +4
    -- NOTE: Keeping Pixie Hairpin +1 and Archon Ring for dark boost - verify you own them
    sets.midcast.Drain = {
        main = "Rubicundity",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Pixie Hairpin +1",  -- Keep for dark boost if you have it
        neck = "Erra Pendant",
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",  -- CORRECTED: Was Regal Earring
        body = "Chironic Doublet",
        hands = "Arbatel Bracers +3",  -- CORRECTED: Was Acad. Bracers +4
        ring1 = "Evanescence Ring",
        ring2 = "Archon Ring",  -- Keep if you have it for dark boost
        back = gear.nuke_jse_back,
        waist = "Fucho-no-obi",
        legs = "Chironic Hose",
        feet = gear.merlinic_aspir_feet
    }

    -- CORRECTED: Replaced Amalric Coif +1, Regal Earring, Acad. Bracers +4
    sets.midcast.Drain.Resistant = {
        main = "Rubicundity",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Agwu's Cap",  -- CORRECTED: Was Amalric Coif +1
        neck = "Erra Pendant",
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",  -- CORRECTED: Was Regal Earring
        body = "Chironic Doublet",
        hands = "Arbatel Bracers +3",  -- CORRECTED: Was Acad. Bracers +4
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Acuity Belt +1",
        legs = "Chironic Hose",
        feet = gear.merlinic_aspir_feet
    }

    sets.midcast.Aspir = sets.midcast.Drain
    sets.midcast.Aspir.Resistant = sets.midcast.Drain.Resistant

    -- CORRECTED: Replaced Amalric Coif +1, Acad. Bracers +4
    sets.midcast.Stun = {
        main = gear.grioavolr_fc_staff,
        sub = "Clerisy Strap +1",
        ammo = "Hasty Pinion +1",
        head = "Agwu's Cap",  -- CORRECTED: Was Amalric Coif +1
        neck = "Voltsurge Torque",
        ear1 = "Malignance Earring",
		ear2 = "Enchntr. Earring +1",
        body = "Zendik Robe",
        hands = "Arbatel Bracers +3",  -- CORRECTED: Was Acad. Bracers +4
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Witful Belt",
        legs = "Psycloth Lappas",
        feet = "Regal Pumps +1"
    }

    -- CORRECTED: Replaced Acad. Mortar. +4, Regal Earring, Acad. Bracers +4
    sets.midcast.Stun.Resistant = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Arbatel Bonnet +3",  -- CORRECTED: Was Acad. Mortar. +4
        neck = "Erra Pendant",
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",  -- CORRECTED: Was Regal Earring
        body = "Zendik Robe",
        hands = "Arbatel Bracers +3",  -- CORRECTED: Was Acad. Bracers +4
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Acuity Belt +1",
        legs = "Chironic Hose",
        feet = gear.merlinic_aspir_feet
    }

    -- Elemental Magic sets are default for handling low-tier nukes.
    -- CORRECTED: Replaced Ghastly Tathlum +1, Amalric Doublet +1, Amalric Gages +1, Freke Ring, Shiva Ring +1, Amalric Nails +1
    sets.midcast["Elemental Magic"] = {
        main = "Bunzi's Rod",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",  -- CORRECTED: Was Ghastly Tathlum +1
        head = "Agwu's Cap",
        neck = "Saevus Pendant +1",
        ear1 = "Crematio Earring",
        ear2 = "Friomisi Earring",
        body = "Agwu's Robe",  -- CORRECTED: Was Amalric Doublet +1
        hands = "Agwu's Gages",  -- CORRECTED: Was Amalric Gages +1
        ring1 = "Metamor. Ring +1",  -- CORRECTED: Was Freke Ring
        ring2 = "Stikini Ring",  -- CORRECTED: Was Shiva Ring +1
        back = gear.nuke_jse_back,
        waist = "Refoccilation Stone",
        legs = "Merlinic Shalwar",
        feet = "Agwu's Pigaches"  -- CORRECTED: Was Amalric Nails +1
    }

    -- CORRECTED: Replaced Regal Earring, Amalric Doublet +1, Freke Ring
    sets.midcast["Elemental Magic"].Resistant = {
        main = "Bunzi's Rod",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Agwu's Cap",
        neck = "Sanctity Necklace",
        ear1 = "Malignance Earring",  -- FIXED: Was ear1
		ear2 = "Arbatel Earring +1",  -- FIXED: Swapped to prevent ear slot conflict
        body = "Agwu's Robe",  -- CORRECTED: Was Amalric Doublet +1
        hands = "Mallquis Cuffs +2",
        ring1 = "Metamor. Ring +1",  -- CORRECTED: Was Freke Ring
        ring2 = "Metamor. Ring +1",
        back = gear.nuke_jse_back,
        waist = "Acuity Belt +1",
        legs = "Merlinic Shalwar",
        feet = "Agwu's Pigaches"
    }

    -- CORRECTED: Replaced Shiva Ring +1, Freke Ring
    sets.midcast["Elemental Magic"]["9k"] = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = gear.merlinic_nuke_head,
        neck = "Saevus Pendant +1",
        ear1 = "Malignance Earring",
		ear2 = "Crematio Earring",
        body = gear.merlinic_nuke_body,
        hands = "Mallquis Cuffs +2",
        ring1 = "Stikini Ring",  -- CORRECTED: Was Shiva Ring +1
        ring2 = "Metamor. Ring +1",  -- CORRECTED: Was Freke Ring
        back = "Swith Cape +1",
        waist = "Witful Belt",
        legs = "Psycloth Lappas",
        feet = "Regal Pumps +1"
    }

    sets.midcast["Elemental Magic"].Proc = {
        main = empty,
        sub = empty,
        ammo = "Impatiens",
        head = "Vanya Hood",
        neck = "Voltsurge Torque",
        ear1 = "Malignance Earring",
		ear2 = "Enchntr. Earring +1",
        body = "Zendik Robe",
        hands = "Gende. Gages +1",
        ring1 = "Kishar Ring",
        ring2 = "Prolix Ring",
        back = "Swith Cape +1",
        waist = "Witful Belt",
        legs = "Psycloth Lappas",
        feet = "Regal Pumps +1"
    }

    sets.midcast["Elemental Magic"].OccultAcumen = {
        main = "Khatvanga",
        sub = "Bloodrain Strap",
        ammo = "Seraphic Ampulla",
        head = "Mall. Chapeau +2",
        neck = "Combatant's Torque",
        ear1 = "Dedition Earring",
        ear2 = "Telos Earring",
        body = gear.merlinic_occult_body,
        hands = gear.merlinic_occult_hands,
        ring1 = "Rajas Ring",
        ring2 = "Petrov Ring",
        back = gear.nuke_jse_back,
        waist = "Oneiros Rope",
        legs = "Perdition Slops",
        feet = gear.merlinic_occult_feet
    }

    -- Gear for Magic Burst mode.
    -- CORRECTED: Replaced Ghastly Tathlum +1, Regal Earring, Amalric Doublet +1, Amalric Gages +1, Freke Ring, Mujin Band, Amalric Nails +1
    -- NOTE: Agwu's Gages has MB Damage II +6 which exceeds the 40% cap! Excellent for MB.
    sets.MagicBurst = {
        main = "Bunzi's Rod",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",  -- CORRECTED: Was Ghastly Tathlum +1
        head = "Agwu's Cap",
        neck = "Mizukage-no-Kubikazari",
        ear1 = "Malignance Earring",  -- FIXED: Was ear1
		ear2 = "Arbatel Earring +1",  -- FIXED: Swapped to prevent ear slot conflict
        body = "Agwu's Robe",  -- CORRECTED: Was Amalric Doublet +1
        hands = "Agwu's Gages",  -- CORRECTED: Was Amalric Gages +1 - HAS MB DAMAGE II +6!
        ring1 = "Metamor. Ring +1",  -- CORRECTED: Was Freke Ring
        ring2 = "Stikini Ring",  -- CORRECTED: Was Mujin Band (you lose MB II +5, consider acquiring)
        back = gear.nuke_jse_back,
        waist = "Acuity Belt +1",
        legs = "Agwu's Slops",
        feet = "Agwu's Pigaches"  -- CORRECTED: Was Amalric Nails +1
    }

    -- Resistant Magic Burst set (for high magic evasion targets)
    -- CORRECTED: Replaced Regal Earring, Amalric Doublet +1, Amalric Gages +1, Mujin Band
    sets.ResistantMagicBurst = {
        main = "Bunzi's Rod",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Agwu's Cap",
        neck = "Mizukage-no-Kubikazari",
        ear1 = "Malignance Earring",  -- FIXED: Was ear1
		ear2 = "Arbatel Earring +1",  -- FIXED: Swapped to prevent ear slot conflict
        body = "Agwu's Robe",  -- CORRECTED: Was Amalric Doublet +1
        hands = "Agwu's Gages",  -- CORRECTED: Was Amalric Gages +1 - HAS MB DAMAGE II +6!
        ring1 = "Stikini Ring",  -- CORRECTED: Was Mujin Band
        ring2 = "Metamor. Ring +1",
        back = gear.nuke_jse_back,
        waist = "Acuity Belt +1",
        legs = "Agwu's Slops",
        feet = "Agwu's Pigaches"
    }

    -- CORRECTED: Replaced Ghastly Tathlum +1, Regal Earring, Amalric Doublet +1, Amalric Gages +1, Freke Ring, Mujin Band, Amalric Nails +1
    sets.HelixBurst = {
        main = "Bunzi's Rod",
        sub = "Culminus",
        ammo = "Pemphredo Tathlum",  -- CORRECTED: Was Ghastly Tathlum +1
        head = "Agwu's Cap",
        neck = "Mizukage-no-Kubikazari",
        ear1 = "Malignance Earring",  -- FIXED: Was ear1
		ear2 = "Arbatel Earring +1",  -- FIXED: Swapped to prevent ear slot conflict
        body = "Agwu's Robe",  -- CORRECTED: Was Amalric Doublet +1
        hands = "Agwu's Gages",  -- CORRECTED: Was Amalric Gages +1 - HAS MB DAMAGE II +6!
        ring1 = "Metamor. Ring +1",  -- CORRECTED: Was Freke Ring
        ring2 = "Stikini Ring",  -- CORRECTED: Was Mujin Band
        back = gear.nuke_jse_back,
        waist = "Refoccilation Stone",
        legs = "Agwu's Slops",
        feet = "Agwu's Pigaches"  -- CORRECTED: Was Amalric Nails +1
    }

    -- CORRECTED: Replaced Ghastly Tathlum +1, Regal Earring, Amalric Doublet +1, Amalric Gages +1, Mujin Band
    sets.ResistantHelixBurst = {
        main = "Bunzi's Rod",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",  -- CORRECTED: Was Ghastly Tathlum +1
        head = "Agwu's Cap",
        neck = "Mizukage-no-Kubikazari",
        ear1 = "Malignance Earring",  -- FIXED: Was ear1
		ear2 = "Arbatel Earring +1",  -- FIXED: Swapped to prevent ear slot conflict
        body = "Agwu's Robe",  -- CORRECTED: Was Amalric Doublet +1
        hands = "Agwu's Gages",  -- CORRECTED: Was Amalric Gages +1 - HAS MB DAMAGE II +6!
        ring1 = "Stikini Ring",  -- CORRECTED: Was Mujin Band
        ring2 = "Metamor. Ring +1",
        back = gear.nuke_jse_back,
        waist = "Acuity Belt +1",
        legs = "Agwu's Slops",
        feet = "Agwu's Pigaches"
    }

    -- Custom refinements for certain nuke tiers
    -- CORRECTED: Replaced Ghastly Tathlum +1, Regal Earring, Amalric Doublet +1, Amalric Gages +1, Freke Ring, Amalric Nails +1
    sets.midcast["Elemental Magic"].HighTierNuke = {
        main = "Bunzi's Rod",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",  -- CORRECTED: Was Ghastly Tathlum +1
        head = "Merlinic Hood",
        neck = "Saevus Pendant +1",
        ear1 = "Malignance Earring",  -- FIXED: Was ear1
		ear2 = "Arbatel Earring +1",  -- FIXED: Swapped to prevent ear slot conflict
        body = "Agwu's Robe",  -- CORRECTED: Was Amalric Doublet +1
        hands = "Agwu's Gages",  -- CORRECTED: Was Amalric Gages +1
        ring1 = "Metamor. Ring +1",  -- CORRECTED: Was Freke Ring
        ring2 = "Metamor. Ring +1",
        back = gear.nuke_jse_back,
        waist = "Acuity Belt +1",
        legs = "Merlinic Shalwar",
        feet = "Agwu's Pigaches"  -- CORRECTED: Was Amalric Nails +1
    }

    -- CORRECTED: Replaced Ghastly Tathlum +1, Regal Earring, Amalric Doublet +1, Freke Ring
    sets.midcast["Elemental Magic"].HighTierNuke.Resistant = {
        main = "Bunzi's Rod",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",  -- CORRECTED: Was Ghastly Tathlum +1
        head = "Merlinic Hood",
        neck = "Sanctity Necklace",
        ear1 = "Malignance Earring",  -- FIXED: Was ear1
		ear2 = "Arbatel Earring +1",  -- FIXED: Swapped to prevent ear slot conflict
        body = "Agwu's Robe",  -- CORRECTED: Was Amalric Doublet +1
        hands = "Jhakri Cuffs +2",
        ring1 = "Metamor. Ring +1",  -- CORRECTED: Was Freke Ring
        ring2 = "Metamor. Ring +1",
        back = gear.nuke_jse_back,
        waist = "Acuity Belt +1",
        legs = "Merlinic Shalwar",
        feet = "Jhakri Pigaches +2"
    }

    -- CORRECTED: Replaced Ghastly Tathlum +1, Amalric Gages +1, Freke Ring, Amalric Nails +1
    sets.midcast.Helix = {
        main = "Bunzi's Rod",
        sub = "Culminus",
        ammo = "Pemphredo Tathlum",  -- CORRECTED: Was Ghastly Tathlum +1
        head = "Merlinic Hood",
        neck = "Saevus Pendant +1",
        ear1 = "Crematio Earring",
        ear2 = "Friomisi Earring",
        body = gear.merlinic_nuke_body,
        hands = "Agwu's Gages",  -- CORRECTED: Was Amalric Gages +1
        ring1 = "Metamor. Ring +1",
        ring2 = "Metamor. Ring +1",  -- CORRECTED: Was Freke Ring
        back = gear.nuke_jse_back,
        waist = "Refoccilation Stone",
        legs = "Merlinic Shalwar",
        feet = "Agwu's Pigaches"  -- CORRECTED: Was Amalric Nails +1
    }

    -- CORRECTED: Replaced Amalric Gages +1, Freke Ring, Amalric Nails +1
    sets.midcast.Helix.Resistant = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = gear.merlinic_nuke_head,
        neck = "Sanctity Necklace",
        ear1 = "Malignance Earring",  -- FIXED: Was ear1
		ear2 = "Friomisi Earring",  -- FIXED: Swapped to prevent ear slot conflict
        body = gear.merlinic_nuke_body,
        hands = "Agwu's Gages",  -- CORRECTED: Was Amalric Gages +1
        ring1 = "Metamor. Ring +1",
        ring2 = "Metamor. Ring +1",  -- CORRECTED: Was Freke Ring
        back = gear.nuke_jse_back,
        waist = "Acuity Belt +1",
        legs = "Merlinic Shalwar",
        feet = "Agwu's Pigaches"  -- CORRECTED: Was Amalric Nails +1
    }

    sets.midcast.Helix.Proc = {
        main = empty,
        sub = empty,
        ammo = "Impatiens",
        head = "Vanya Hood",
        neck = "Voltsurge Torque",
        ear1 = "Malignance Earring",
		ear2 = "Enchntr. Earring +1",
        body = "Zendik Robe",
        hands = "Gende. Gages +1",
        ring1 = "Kishar Ring",
        ring2 = "Prolix Ring",
        back = "Swith Cape +1",
        waist = "Witful Belt",
        legs = "Psycloth Lappas",
        feet = "Regal Pumps +1"
    }

    -- CORRECTED: Replaced Regal Earring, Acad. Bracers +4, Amalric Nails +1
    sets.midcast.Impact = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = empty,
        neck = "Erra Pendant",
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",  -- CORRECTED: Was Regal Earring
        body = "Twilight Cloak",
        hands = "Arbatel Bracers +3",  -- CORRECTED: Was Acad. Bracers +4
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Acuity Belt +1",
        legs = "Merlinic Shalwar",
        feet = "Agwu's Pigaches"  -- CORRECTED: Was Amalric Nails +1
    }

    sets.midcast.Impact.OccultAcumen =
        set_combine(sets.midcast["Elemental Magic"].OccultAcumen, {head = empty, body = "Twilight Cloak"})

    -- Sets to return to when not performing an action.

    -- Resting sets
    -- CORRECTED: Replaced Amalric Doublet +1
    sets.resting = {
        main = "Chatoyant Staff",
        sub = "Oneiros Grip",
        ammo = "Homiliary",
        head = "Befouled Crown",
        neck = "Chrys. Torque",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Agwu's Robe",  -- CORRECTED: Was Amalric Doublet +1
        hands = gear.merlinic_refresh_hands,
        ring1 = "Defending Ring",
        ring2 = "Dark Ring",
        back = "Umbra Cape",
        waist = "Fucho-no-obi",
        legs = "Assid. Pants +1",
        feet = gear.chironic_refresh_feet
    }

    -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)

    sets.idle = {
        main = "Mpaca's Staff",
        sub = "Umbra Strap",
        ammo = "Homiliary",
        head = "Null Masque",
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",
        ear2 = "Ethereal Earring",
        body = "Arbatel Gown +3",
        hands = "Peda. Bracers +3",
        ring1 = "Murky Ring",
        ring2 = "Stikini Ring",
        back = "Umbra Cape",
        waist = "Carrier's Sash",
        legs = "Arbatel Pants +3",
        feet = "Arbatel Loafers +3",
    }

    sets.idle.PDT = {
        main = "Malignance Pole",
        sub = "Umbra Strap",
        ammo = "Staunch Tathlum +1",
        head = "Gende. Caubeen +1",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Vrikodara Jupon",
        hands = "Gende. Gages +1",
        ring1 = "Defending Ring",
        ring2 = "Dark Ring",
        back = "Umbra Cape",
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = gear.chironic_refresh_feet
    }

    sets.idle.Hippo = set_combine(sets.idle.PDT, {feet = "Hippo. Socks +1"})

    sets.idle.Weak = {
        main = "Bolelabunga",
        sub = "Genmei Shield",
        ammo = "Homiliary",
        head = "Befouled Crown",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Jhakri Robe +2",
        hands = gear.merlinic_refresh_hands,
        ring1 = "Defending Ring",
        ring2 = "Dark Ring",
        back = "Umbra Cape",
        waist = "Carrier's Sash",
        legs = "Assid. Pants +1",
        feet = gear.chironic_refresh_feet
    }

    -- Porter Moogle packing set
    sets.packing = {
        main = "Akademos",
        sub = "Enki Strap",
        ammo = "Homiliary",
        head = "Null Masque",
        neck = "Sibyl Scarf",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Dark Ring",
        back = gear.nuke_jse_back,
        waist = "Fucho-no-obi",
        legs = "Assid. Pants +1",
        feet = "Nyame Sollerets"
    }

    -- Defense sets

    sets.defense.PDT = {
        main = "Malignance Pole",
        sub = "Umbra Strap",
        ammo = "Staunch Tathlum +1",
        head = "Gende. Caubeen +1",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Mallquis Saio +2",
        hands = "Gende. Gages +1",
        ring1 = "Defending Ring",
        ring2 = "Dark Ring",
        back = "Umbra Cape",
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Battlecast Gaiters"
    }

    sets.defense.MDT = {
        main = "Malignance Pole",
        sub = "Umbra Strap",
        ammo = "Staunch Tathlum +1",
        head = "Gende. Caubeen +1",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Mallquis Saio +2",
        hands = "Gende. Gages +1",
        ring1 = "Defending Ring",
        ring2 = "Dark Ring",
        back = "Umbra Cape",
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Battlecast Gaiters"
    }

    -- CORRECTED: Replaced Amalric Nails +1
    sets.defense.MEVA = {
        main = "Daybreak",
        sub = "Genmei Shield",
        ammo = "Staunch Tathlum +1",
        head = gear.merlinic_nuke_head,
        neck = "Warder's Charm +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = gear.merlinic_nuke_body,
        hands = "Gende. Gages +1",
        ring1 = "Vengeful Ring",
        ring2 = "Purity Ring",
        back = gear.nuke_jse_back,
        waist = "Acuity Belt +1",
        legs = "Merlinic Shalwar",
        feet = "Agwu's Pigaches"  -- CORRECTED: Was Amalric Nails +1
    }

    sets.Kiting = {Ring2 = "Shneddick Ring +1"}
    sets.latent_refresh = {waist = "Fucho-no-obi"}
    sets.latent_refresh_grip = {sub = "Oneiros Grip"}
    sets.TPEat = {neck = "Chrys. Torque"}
    sets.DayIdle = {}
    sets.NightIdle = {}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    -- Normal melee group
    sets.engaged = {
        main = "Maxentius",
        sub = "Genmei Shield",
        ammo = "Homiliary",
        head = "Befouled Crown",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Jhakri Robe +2",
        hands = gear.merlinic_refresh_hands,
        ring1 = "Defending Ring",
        ring2 = "Sheltered Ring",
        back = "Umbra Cape",
        waist = "Carrier's Sash",
        legs = "Assid. Pants +1",
        feet = gear.chironic_refresh_feet
    }

    sets.engaged.PDT = {
        main = "Malignance Pole",
        sub = "Oneiros Grip",
        ammo = "Staunch Tathlum +1",
        head = "Gende. Caubeen +1",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = "Vrikodara Jupon",
        hands = "Gende. Gages +1",
        ring1 = "Defending Ring",
        ring2 = "Dark Ring",
        back = "Umbra Cape",
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = gear.chironic_refresh_feet
    }

    -- Buff sets: Gear that needs to be worn to actively enhance a current player buff.
    sets.buff["Ebullience"] = {head = "Arbatel Bonnet +3"}
    sets.buff["Rapture"] = {head = "Arbatel Bonnet +3"}
    sets.buff["Perpetuance"] = {hands = "Arbatel Bracers +3"}
    sets.buff["Immanence"] = {hands = "Arbatel Bracers +3"}
    sets.buff["Penury"] = {legs = "Arbatel Pants +3"}
    sets.buff["Parsimony"] = {legs = "Arbatel Pants +3"}
    sets.buff["Celerity"] = {feet = "Peda. Loafers +3"}
    sets.buff["Alacrity"] = {feet = "Peda. Loafers +3"}
    sets.buff["Klimaform"] = {feet = "Arbatel Loafers +3"}

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
        main = "Daybreak",
        sub = "Sors Shield",
        range = empty,
        ammo = "Hasty Pinion +1",
        head = "Gende. Caubeen +1",
        neck = "Unmoving Collar +1",
        ear1 = "Gifted Earring",
        ear2 = "Mendi. Earring",
        body={ name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands={ name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1 = "Gelatinous Ring +1",
        ring2 = "Meridian Ring",
        back = "Moonlight Cape",
        waist = "Luminary Sash",
        legs = "Carmine Cuisses +1",
        feet={ name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}},
    }

    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff["Light Arts"] = {legs="Acad. Pants +4"}
    sets.buff["Dark Arts"] = {body="Acad. Gown +4"}


    sets.buff.Sublimation = {head = "Acad. Mortar. +4", waist = "Embla Sash"} 
    sets.buff.DTSublimation = {waist = "Embla Sash"}

    -- Weapons sets
    sets.weapons.Akademos = {main = "Akademos", sub = "Enki Strap"}
    sets.weapons.Khatvanga = {main = "Khatvanga", sub = "Bloodrain Strap"}
end

-------------------------------------------------------------------------------------------------------------------
-- Porter Moogle Detection for PorterPacker
-------------------------------------------------------------------------------------------------------------------
-- Porter Moogle proximity detection function
function near_porter_moogle()
    local mobs = windower.ffxi.get_mob_array()
    for i, mob in pairs(mobs) do
        if mob.name == "Porter Moogle" and mob.distance and mob.distance < 36 then
            return true
        end
    end
    return false
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

-------------------------------------------------------------------------------------------------------------------
-- Select default macro book on initial load or subjob change.
-------------------------------------------------------------------------------------------------------------------
-- Default macro set/book
function select_default_macro_book()
    if player.sub_job == "RDM" then
        set_macro_page(1, 20)
    elseif player.sub_job == "BLM" then
        set_macro_page(1, 20)
    elseif player.sub_job == "WHM" then
        set_macro_page(1, 20)
    else
        set_macro_page(1, 20)
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Custom Self Commands for MB Control
-------------------------------------------------------------------------------------------------------------------
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1] == 'mb' then
        if cmdParams[2] == 'on' then
            SCWindowOpen = true
            SCWindowTimer = os.clock()
            windower.add_to_chat(121, '[GearSwap] MB window manually enabled')
        elseif cmdParams[2] == 'off' then
            SCWindowOpen = false
            windower.add_to_chat(121, '[GearSwap] MB window manually disabled')
        else
            -- Toggle
            SCWindowOpen = not SCWindowOpen
            if SCWindowOpen then
                SCWindowTimer = os.clock()
            end
            windower.add_to_chat(121, '[GearSwap] MB window: '..tostring(SCWindowOpen))
        end
        eventArgs.handled = true
    end
end