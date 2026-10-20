-------------------------------------------------------------------------------------------------------------------
-- LINKTRI (2026-10-20) SCH audit notes:
--   * Gear rebuilt around what you own: Arbatel +3, Pedagogy +3, Academic +4 (Acad. Mortar. +4 is stored), Agwu R15.
--     Items replaced keep an "original:" comment so they can be restored if acquired.
--   * Rare items (one copy per character) never sit in both ear or both ring slots of one set.
--   * Fixed sides to avoid "Failed to equip" mirror swaps:
--       ear1 = Malignance / Alabaster / Andoaa / Evans / Dedition      ear2 = Etiolation / Arbatel +1 (right ear only) / Meili / Sanare / Magnetic / Telos
--       ring1 = Murky / Kishar / Menelaus / Vengeful / Chirich        ring2 = Metamor. +1 / Defending / Lebeche / Mephitas / Petrov / Shneddick
--     (Stikini Ring: two owned, either side.)
--   * Stored (unpack with PorterPacker): Acad. Mortar. +4, Twilight Cloak, Twilight Cape, Maxentius.
--   * Shedir Seraweels (Stoneskin/Aquaveil/bar-spells) is listed in those sets; it starts working once bought.
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Skillchain / Magic Burst window (shared with BLM and GEO): Linktri-MBWindow.lua
-- LINKTRI (2026-10-20): windows open only for skillchains made by you, your party/alliance (trusts included) or
-- their pets, and only for the monster that was skillchained.
-------------------------------------------------------------------------------------------------------------------
SC_WINDOW_DURATION = 10  -- Skillchain window lasts ~10 seconds
include('Linktri-MBWindow.lua')

local near_porter = false  -- Track Porter Moogle proximity state

-------------------------------------------------------------------------------------------------------------------
-- User Job Setup
-------------------------------------------------------------------------------------------------------------------
-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_job_setup()
    state.OffenseMode:options("Normal")
    state.CastingMode:options("Normal", "Resistant", "Proc", "OccultAcumen", "9k")
    state.IdleMode:options("Normal", "PDT")
    state.HybridMode:options("Normal", "PDT")
    state.Weapons:options("None", "Akademos", "Opashoro") -- LINKTRI: original "None", "Akademos", "Khatvanga" (Khatvanga not owned yet; Opashoro added 2026-10-20)

    -- Auto Magic Burst Mode toggle (enabled by default)
    state.AutoMBMode = M(true, 'Auto MB Mode')

    gear.nuke_jse_back={ name="Lugh's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10','Spell interruption rate down-10%',}}

    -- Additional local binds
    send_command("bind ^` gs c cycle ElementalMode")
    send_command("bind !` gs c scholar power")
    send_command("bind @` gs c cycle MagicBurstMode")
    -- send_command("bind ^q gs c weapons Khatvanga;gs c set CastingMode OccultAcumen") -- LINKTRI: re-enable when Khatvanga is owned
    send_command("bind ^q gs c set CastingMode OccultAcumen") -- LINKTRI: Occult Acumen without the Khatvanga weapon swap
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

    select_default_macro_book()
end

-------------------------------------------------------------------------------------------------------------------
-- Nuke waist selection (ported from BLM)
-------------------------------------------------------------------------------------------------------------------
-- Orpheus's Sash affinity: +15 at <=1.93 yalms, tapering to +1 at >=13 yalms.
-- Hachirin-no-Obi: +10 day match, +10 single weather, +25 double weather (stack with day).
local ORPHEUS_MIN_DIST = 1.93   -- distance at which Orpheus gives its max +15
local ORPHEUS_MAX_DIST = 13.0   -- distance beyond which Orpheus gives only +1
local ORPHEUS_MIN_WORTH = 2     -- below this affinity, the set's neutral waist (Sacro Cord / Null Belt) wins

local function nuke_waist_bonus(spell, spellMap)
    local el = spell.element
    if not el or el == 'None' then return nil end

    -- Hachirin side: day + weather bonuses.
    -- Per BG-Wiki (Magic Damage): Helix spells get day/weather at 100% with NO equipment, so the obi adds
    -- nothing on a Helix - skip straight to Orpheus/neutral.
    local obi = 0
    if spellMap ~= 'Helix' then
        if world.day_element == el then obi = obi + 10 end
        if world.weather_element == el then
            local intensity = 1
            if world.weather_id and gearswap and gearswap.res and gearswap.res.weather
                    and gearswap.res.weather[world.weather_id] then
                intensity = gearswap.res.weather[world.weather_id].intensity or 1
            end
            obi = obi + (intensity == 2 and 25 or 10)
        end
    end

    -- Orpheus side: distance-scaled affinity
    local dist = (spell.target and spell.target.distance) or 21
    local aff
    if dist <= ORPHEUS_MIN_DIST then
        aff = 15
    elseif dist >= ORPHEUS_MAX_DIST then
        aff = 1
    else
        aff = math.floor(15 - ((dist - ORPHEUS_MIN_DIST) * (14 / (ORPHEUS_MAX_DIST - ORPHEUS_MIN_DIST))))
    end

    -- Day/weather still proc naturally ~33% of the time WITHOUT the obi, so wearing Orpheus only gives up
    -- ~2/3 of the obi's bonus.
    if (obi * 0.67) >= aff and obi > 0 then
        return "Hachirin-no-Obi"
    elseif aff >= ORPHEUS_MIN_WORTH then
        return "Orpheus's Sash"
    end
    return nil
end

-- Re-apply the grimoire buff gear SCH.lua equips (it runs before this file's post-midcast, so an MB set would erase it)
local function reapply_sch_buff_gear(spell)
    if state.Buff.Klimaform and spell.element == world.weather_element and sets.buff['Klimaform'] then
        equip(sets.buff['Klimaform'])
    end
    if state.Buff.Ebullience and sets.buff['Ebullience'] then
        equip(sets.buff['Ebullience'])
    end
    if state.Buff.Immanence and sets.buff['Immanence'] then
        equip(sets.buff['Immanence'])
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User Job Post Midcast - Raetic cures, Automatic Magic Burst, nuke waist
-------------------------------------------------------------------------------------------------------------------
-- LINKTRI (2026-10-20): original signature was (spell, action, spellMap, eventArgs). Sel passes (spell, spellMap,
-- eventArgs), so 'spellMap' was really the eventArgs table and the ElementalEnfeeble exclusion never worked
-- (Burn/Choke/Shock... got the burst set).
-- The window now stays open for its full duration so a Helix + nuke can both burst on one skillchain.
--   original: SCWindowOpen = false after the first burst
function user_job_post_midcast(spell, spellMap, eventArgs)
    -- Cure main: Daybreak by default; Raetic Rod +1 (Cure potency II +10%, Cure+50, MP cost +30%) when Refresh or
    -- Ballad is on you. Never touches a locked weapon set. (same rule as GEO)
    if (spellMap == 'Cure' or spellMap == 'Curaga') and state.Weapons.value == 'None'
        and (buffactive['Refresh'] or buffactive['Ballad']) and item_available('Raetic Rod +1') then
        equip({main="Raetic Rod +1"})
    end

    local is_nuke = spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble' and spell.english ~= 'Impact'
        and state.CastingMode.value ~= 'Proc' and state.CastingMode.value ~= 'OccultAcumen'
    if not is_nuke then return end

    if state.AutoMBMode.value and is_sc_window_open(spell.target and spell.target.id) then
        local helix = spellMap == 'Helix'
        if state.CastingMode.value == 'Resistant' then
            windower.add_to_chat(121, '[GearSwap] Auto-MB: SC Window Active - Equipping Resistant '..(helix and 'Helix ' or '')..'MB set for: '..spell.english)
            equip(helix and sets.ResistantHelixBurst or sets.ResistantMagicBurst)
        else
            windower.add_to_chat(121, '[GearSwap] Auto-MB: SC Window Active - Equipping '..(helix and 'Helix ' or '')..'MB set for: '..spell.english)
            equip(helix and sets.HelixBurst or sets.MagicBurst)
        end
        reapply_sch_buff_gear(spell)
        -- Dark bursts (Noctohelix, Kaustra...) keep Pixie Hairpin +1 (dark affinity x1.28), as on BLM
        if spell.element == 'Dark' then
            equip({head = "Pixie Hairpin +1"})
        end
    end

    -- Orpheus/Hachirin/neutral waist, runs after the MB equip so the affinity waist also applies to bursts
    local waist = nuke_waist_bonus(spell, spellMap)
    if waist then
        equip({waist = waist})
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Define sets and vars used by this job file.
-------------------------------------------------------------------------------------------------------------------
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------
    local kaykaus_tights = { name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}}
    local kaykaus_mitra  = { name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}}
    local kaykaus_bliaut = { name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}}
    local kaykaus_cuffs  = { name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}}
    local kaykaus_boots  = { name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}

    -- Precast Sets

    -- Precast sets to enhance JAs

    sets.precast.JA["Tabula Rasa"] = {legs = "Peda. Pants +3"}
    sets.precast.JA["Enlightenment"] = {body="Peda. Gown +3"}

    -- FC about 72%: Grioavolr 11, Clerisy 3, Merlinic Hood 8, Voltsurge 4, Malignance 4, Etiolation 1, Agwu's Robe 8,
    -- Acad. Bracers 9, Kishar 4, Embla 5, Agwu's Slops 7, Peda. Loafers 8
    sets.precast.FC = {
        main = gear.grioavolr_fc_staff,
        sub = "Clerisy Strap +1",
        ammo = "Impatiens",
        head = gear.merlinic_nuke_head,     -- FC+8  -- original: Agwu's Cap (FC+5)
        neck = "Voltsurge Torque",
        ear1 = "Malignance Earring",
		ear2 = "Etiolation Earring",        -- original: Enchntr. Earring +1 (not owned)
        body = "Agwu's Robe",               -- FC+8  -- original: Zendik Robe (not owned)
        hands = "Acad. Bracers +4",         -- FC+9  -- original: Arbatel Bracers +3 (no Fast Cast)
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",
        back = "Perimede Cape",
        waist = "Embla Sash",               -- FC+5  -- original: Witful Belt (Haste only)
        legs = "Agwu's Slops",              -- FC+7  -- original: Psycloth Lappas (not owned)
        feet = "Peda. Loafers +3"           -- FC+8  -- original: Regal Pumps +1 (FC+4~5)
    }

    -- LINKTRI: SCH.lua equips this over FC when the spell matches your active Arts (white magic in Light Arts,
    -- black magic in Dark Arts). Peda. M.Board +3: Grimoire spellcasting time -13%; Acad. Loafers +4: Arts casting time -12%.
    -- original: {}
    sets.precast.FC.Arts = {head = "Peda. M.Board +3", feet = "Acad. Loafers +4"}

    sets.precast.FC["Enhancing Magic"] = set_combine(sets.precast.FC, {waist = "Siegel Sash"})

    sets.precast.FC["Elemental Magic"] = set_combine(sets.precast.FC, {ear1 = "Malignance Earring"})

    -- LINKTRI: Kaykaus Tights (FC+7 and Cure spellcasting time -7%)
    -- original: {main = "Serenity", sub = "Clerisy Strap +1", body = "Heka's Kalasiris"} (not owned)
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {legs = kaykaus_tights})

    sets.precast.FC.Curaga = sets.precast.FC.Cure

    sets.precast.FC.Impact = set_combine(sets.precast.FC["Elemental Magic"], {head = empty, body = "Twilight Cloak"})
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main = "Daybreak", sub = "Genmei Shield"})

    -- Weaponskill sets
    -- Myrkr: MP gear
    sets.precast.WS["Myrkr"] = {
        ammo = "Pemphredo Tathlum",
        head = "Arbatel Bonnet +3",         -- MP+86
        neck = "Voltsurge Torque",          -- MP+20  -- original: Sanctity Necklace (not owned)
        ear1 = "Evans Earring",
        ear2 = "Etiolation Earring",        -- MP+50
        body = "Acad. Gown +4",             -- MP+183  -- original: Agwu's Robe (MP+88)
        hands = "Agwu's Gages",             -- MP+73  -- original: Regal Cuffs (not owned)
        ring2 = "Mephitas's Ring",          -- original: ring1 Mephitas's Ring +1 (not owned)
        back = "Aurist's Cape +1",
        waist = "Luminary Sash",
        legs = "Acad. Pants +4",            -- MP+78  -- original: Psycloth Lappas (not owned)
        feet = "Arbatel Loafers +3",        -- MP+90  -- original: Kaykaus Boots +1
    }

    -- Midcast Sets

    sets.TreasureHunter = set_combine(sets.TreasureHunter, {}) -- original: {feet = gear.chironic_treasure_feet} (augments not owned)

    -- Gear that converts elemental damage done to recover MP.
    sets.RecoverMP = {} -- original: {body = "Seidr Cotehardie"} (not owned)

    -- Gear for specific elemental nukes.
    sets.element.Dark = {head = "Pixie Hairpin +1"} -- original: also ring2 = "Archon Ring" (not owned)

    sets.midcast.FastRecast = set_combine(sets.precast.FC, {})
    -- original: Grioavolr/Clerisy, Hasty Pinion +1, Agwu's Cap, Voltsurge, Malignance/Enchntr. +1, Zendik Robe,
    --   Gende. Gages +1, Kishar/Prolix, Swith Cape +1, Witful Belt, Psycloth Lappas, Regal Pumps +1

    -- Cure potency is far past the 50% cap, so these sets also carry SIRD/Conserve MP.
    -- Raetic Rod +1 replaces Daybreak automatically when Refresh or Ballad is on you (see user_job_post_midcast).
    sets.midcast.Cure = {
        main = "Daybreak",                  -- Cure potency +30%  -- original: Serenity (not owned)
        sub = "Sors Shield",                -- Cure potency +3%  -- original: Curatio Grip (not owned)
        ammo = "Impatiens",                 -- SIRD 10%  -- original: Hasty Pinion +1 (not owned)
        head = kaykaus_mitra,               -- Cure potency +11%, SIRD 12%  -- original: Gende. Caubeen +1 (not owned)
        neck = "Nodens Gorget",             -- Cure potency +5%  -- original: Incanter's Torque (not owned)
        ear1 = "Malignance Earring",
		ear2 = "Meili Earring",
        body = kaykaus_bliaut,              -- Cure potency II +4%, +6%
        hands = "Peda. Bracers +3",         -- Cure potency II +3%  -- original: Kaykaus Cuffs +1
        ring1 = "Menelaus's Ring",          -- Cure potency +5%  -- original: Janniston Ring (not owned)
        ring2 = "Lebeche Ring",             -- Cure potency +3%
        back = "Vates Cape +1",             -- Enmity-8  -- original: Tempered Cape +1 (not owned)
        waist = "Luminary Sash",
        legs = "Acad. Pants +4",            -- Cure potency +15%  -- original: Chironic Hose (not owned)
        feet = kaykaus_boots,               -- Cure potency +11%, +6%
    }

    -- original LightWeatherCure: Chatoyant Staff/Curatio Grip + Cure set items above with Twilight Cape and Hachirin-no-Obi
    sets.midcast.LightWeatherCure = set_combine(sets.midcast.Cure, {main = "Chatoyant Staff", sub = "Khonsu", back = "Twilight Cape", waist = "Hachirin-no-Obi"})
    sets.midcast.LightDayCure = set_combine(sets.midcast.Cure, {back = "Twilight Cape", waist = "Hachirin-no-Obi"})

    sets.midcast.Curaga = sets.midcast.Cure

    -- Agwu's Gages: Cure potency received +10%
    -- original: {neck = "Phalaina Locket", ring1 = "Kunaji Ring", ring2 = "Asklepian Ring", waist = "Gishdubar Sash"} (not owned)
    sets.Self_Healing = {hands = "Agwu's Gages"}
    sets.Cure_Received = {hands = "Agwu's Gages"}
    sets.Self_Refresh = {feet = "Inspirited Boots"} -- original: also back = "Grapevine Cape", waist = "Gishdubar Sash" (not owned)

    -- Cursna: Healing magic skill (Peda. +19/+19/+20, Meili +10, Vates +6) and Menelaus's Ring (Cursna+20)
    sets.midcast.Cursna = {
        main = gear.grioavolr_fc_staff,
        sub = "Clemency Grip",
        ammo = "Impatiens",                 -- original: Hasty Pinion +1 (not owned)
        head = gear.merlinic_nuke_head,     -- FC+8  -- original: Agwu's Cap
        neck = "Voltsurge Torque",          -- original: Debilis Medallion (not owned)
        ear1 = "Malignance Earring",
		ear2 = "Meili Earring",
        body = "Peda. Gown +3",             -- Healing +19  -- original: Zendik Robe (not owned)
        hands = "Peda. Bracers +3",         -- Healing +19  -- original: Hieros Mittens (not owned)
        ring1 = "Menelaus's Ring",          -- Cursna+20  -- original: ring1 Haoma's Ring (not owned), ring2 Menelaus's Ring
        ring2 = "Lebeche Ring",
        back = "Vates Cape +1",             -- Healing +6  -- original: Oretan. Cape +1 (not owned)
        waist = "Embla Sash",               -- original: Witful Belt
        legs = "Agwu's Slops",              -- original: Psycloth Lappas (not owned)
        feet = "Peda. Loafers +3"           -- Healing +20, FC+8  -- original: Vanya Clogs (not owned)
    }

    sets.midcast.StatusRemoval =
        set_combine(sets.midcast.FastRecast, {main = gear.grioavolr_fc_staff, sub = "Clemency Grip"})

    sets.midcast["Enhancing Magic"] = {
        main = gear.gada_enhancing_club,
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",         -- original: Savant's Treatise (not owned)
        head = "Telchine Cap",
        neck = { name="Loricate Torque +1", augments={'Path: A',}},  -- original: Incanter's Torque (not owned)
        ear1 = "Andoaa Earring",
        ear2 = "Magnetic Earring",          -- Conserve MP+5, SIRD 8%  -- original: Gifted Earring (not owned)
        body = "Peda. Gown +3",             -- Enhancing duration +12%  -- original: Telchine Chas. (+10%)
        hands = "Telchine Gloves",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = "Perimede Cape",
        waist = "Embla Sash",
        legs = "Telchine Braconi",
        feet = "Telchine Pigaches"
    }

    -- Arbatel Bonnet +3: Regen potency +25%; Lugh's Cape: Regen duration +15
    sets.midcast.Regen = set_combine(sets.midcast["Enhancing Magic"], {head = "Arbatel Bonnet +3", back = gear.nuke_jse_back}) -- original: back only

    sets.midcast.Stoneskin =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {neck = "Nodens Gorget", waist = "Siegel Sash", legs = "Shedir Seraweels"} -- original: also ear2 = "Earthcry Earring" (not owned)
    )

    sets.midcast.Refresh = set_combine(sets.midcast["Enhancing Magic"], {head = "Agwu's Cap"})

    -- original: main = "Vadose Rod", sub = "Genmei Shield", hands = "Regal Cuffs", waist = "Emphatikos Rope" (not owned)
    sets.midcast.Aquaveil =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {
            head = "Agwu's Cap",            -- SIRD 10%
            legs = "Shedir Seraweels"
        }
    )

    sets.midcast.BarElement = set_combine(sets.precast.FC["Enhancing Magic"], {legs = "Shedir Seraweels"})

    sets.midcast.Storm = set_combine(sets.midcast["Enhancing Magic"], {feet = "Peda. Loafers +3"})

    -- original: {ring2 = "Sheltered Ring"} (not owned)
    sets.midcast.Protect = set_combine(sets.midcast["Enhancing Magic"], {})
    sets.midcast.Protectra = sets.midcast.Protect

    sets.midcast.Shell = set_combine(sets.midcast["Enhancing Magic"], {})
    sets.midcast.Shellra = sets.midcast.Shell

    -- Custom spell classes

    -- SCH.lua adds Acad. Pants +4 (Light Arts) or Acad. Gown +4 (Dark Arts) on top of these sets.
    sets.midcast["Enfeebling Magic"] = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Arbatel Bonnet +3",
        neck = "Null Loop",                 -- Magic Accuracy+50  -- original: Erra Pendant (+17)
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",
        body = "Arbatel Gown +3",           -- Magic Accuracy+64  -- original: Chironic Doublet (not owned)
        hands = "Arbatel Bracers +3",       -- Magic Accuracy+62  -- original: Regal Cuffs (not owned)
        ring1 = "Kishar Ring",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Obstin. Sash",
        legs = "Arbatel Pants +3",          -- Enfeebling +28, Grimoire Magic Accuracy+36  -- original: Chironic Hose (not owned)
        feet = "Acad. Loafers +4"           -- Magic Accuracy+56, Arts Magic Accuracy+20  -- original: Uk'uxkaj Boots (not owned)
    }

    sets.midcast["Enfeebling Magic"].Resistant = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Arbatel Bonnet +3",
        neck = "Null Loop",                 -- original: Erra Pendant
        ear1 = "Malignance Earring",        -- original: Digni. Earring (not owned)
		ear2 = "Arbatel Earring +1",
        body = "Arbatel Gown +3",           -- original: Chironic Doublet (not owned)
        hands = "Arbatel Bracers +3",
        ring1 = "Murky Ring",               -- Magic Accuracy+15  -- original: ring1 Metamor. Ring +1 (moved to ring2)
        ring2 = { name="Metamor. Ring +1", augments={'Path: A',}},  -- original: Stikini Ring
        back = gear.nuke_jse_back,
        waist = "Null Belt",                -- Magic Accuracy+30  -- original: Luminary Sash
        legs = "Arbatel Pants +3",          -- original: Chironic Hose (not owned)
        feet = "Acad. Loafers +4"           -- original: Medium's Sabots
    }

    sets.midcast.ElementalEnfeeble =
        set_combine(
        sets.midcast["Enfeebling Magic"],
        {head = "Agwu's Cap", ear1 = "Malignance Earring", back = gear.nuke_jse_back, waist = "Sacro Cord"} -- original: waist = "Acuity Belt +1" (not owned)
    )
    sets.midcast.ElementalEnfeeble.Resistant =
        set_combine(
        sets.midcast["Enfeebling Magic"].Resistant,
        {head = "Agwu's Cap", back = gear.nuke_jse_back, waist = "Null Belt"} -- original: waist = "Acuity Belt +1" (not owned)
    )

    sets.midcast.IntEnfeebles =
        set_combine(
        sets.midcast["Enfeebling Magic"],
        {head = "Agwu's Cap", ear1 = "Malignance Earring", back = gear.nuke_jse_back, waist = "Sacro Cord"} -- original: waist = "Acuity Belt +1" (not owned)
    )
    sets.midcast.IntEnfeebles.Resistant =
        set_combine(
        sets.midcast["Enfeebling Magic"].Resistant,
        {head = "Agwu's Cap", back = gear.nuke_jse_back, waist = "Null Belt"} -- original: waist = "Acuity Belt +1" (not owned)
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

    sets.midcast["Dark Magic"] = {
        main = "Rubicundity",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Agwu's Cap",
        neck = "Erra Pendant",              -- Dark magic +10  -- original: Incanter's Torque (not owned)
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",
        body = "Psycloth Vest",             -- Dark magic +21  -- original: Chironic Doublet (not owned)
        hands = "Arbatel Bracers +3",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Null Belt",                -- original: Acuity Belt +1 (not owned)
        legs = "Peda. Pants +3",            -- Dark magic +19  -- original: Chironic Hose (not owned)
        feet = "Agwu's Pigaches"            -- Drain/Aspir +20  -- original: gear.merlinic_aspir_feet (augments not owned)
    }

    sets.midcast.Kaustra = {
        main = "Akademos",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = "Pixie Hairpin +1",
        neck = "Sibyl Scarf",               -- original: Saevus Pendant +1 (not owned)
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",        -- original: Crematio Earring
        body = "Arbatel Gown +3",           -- original: gear.merlinic_nuke_body
        hands = "Arbatel Bracers +3",       -- original: Agwu's Gages
        ring1 = "Murky Ring",               -- original: ring1 Metamor. Ring +1, ring2 Archon Ring (not owned)
        ring2 = { name="Metamor. Ring +1", augments={'Path: A',}},
        back = gear.nuke_jse_back,
        waist = "Sacro Cord",               -- original: Refoccilation Stone (not owned)
        legs = "Arbatel Pants +3",          -- original: Merlinic Shalwar (not owned)
        feet = "Arbatel Loafers +3"         -- original: Agwu's Pigaches
    }

    sets.midcast.Kaustra.Resistant = set_combine(sets.midcast.Kaustra, {neck = "Null Loop", waist = "Null Belt"})
    -- original Resistant: Grioavolr nuke staff/Enki, Merlinic Hood/Jubbah, Erra Pendant, Agwu's Gages/Pigaches,
    --   Metamor./Stikini, Acuity Belt +1 (not owned), Merlinic Shalwar (not owned)

    sets.midcast.Drain = {
        main = "Rubicundity",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Pixie Hairpin +1",
        neck = "Erra Pendant",
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",
        body = "Psycloth Vest",             -- Dark magic +21  -- original: Chironic Doublet (not owned)
        hands = "Arbatel Bracers +3",
        ring1 = "Stikini Ring",             -- original: Evanescence Ring (not owned)
        ring2 = "Stikini Ring",             -- original: Archon Ring (not owned)
        back = gear.nuke_jse_back,
        waist = "Fucho-no-Obi",             -- Drain/Aspir +8
        legs = "Peda. Pants +3",            -- Drain/Aspir +15  -- original: Chironic Hose (not owned)
        feet = "Agwu's Pigaches"            -- Drain/Aspir +20  -- original: gear.merlinic_aspir_feet (augments not owned)
    }

    sets.midcast.Drain.Resistant = {
        main = "Rubicundity",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Agwu's Cap",
        neck = "Erra Pendant",
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",
        body = "Arbatel Gown +3",           -- original: Chironic Doublet (not owned)
        hands = "Arbatel Bracers +3",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Null Belt",                -- original: Acuity Belt +1 (not owned)
        legs = "Peda. Pants +3",            -- original: Chironic Hose (not owned)
        feet = "Agwu's Pigaches"            -- original: gear.merlinic_aspir_feet (augments not owned)
    }

    sets.midcast.Aspir = sets.midcast.Drain
    sets.midcast.Aspir.Resistant = sets.midcast.Drain.Resistant

    sets.midcast.Stun = {
        main = gear.grioavolr_fc_staff,
        sub = "Clerisy Strap +1",
        ammo = "Pemphredo Tathlum",         -- original: Hasty Pinion +1 (not owned)
        head = "Agwu's Cap",
        neck = "Voltsurge Torque",
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",        -- original: Enchntr. Earring +1 (not owned)
        body = "Agwu's Robe",               -- FC+8  -- original: Zendik Robe (not owned)
        hands = "Acad. Bracers +4",         -- FC+9, Magic Accuracy+58  -- original: Arbatel Bracers +3
        ring1 = "Kishar Ring",              -- original: Metamor. Ring +1 (moved to ring2 side)
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,
        waist = "Embla Sash",               -- original: Witful Belt
        legs = "Agwu's Slops",              -- FC+7  -- original: Psycloth Lappas (not owned)
        feet = "Peda. Loafers +3"           -- FC+8  -- original: Regal Pumps +1
    }

    sets.midcast.Stun.Resistant = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Arbatel Bonnet +3",
        neck = "Null Loop",                 -- original: Erra Pendant
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",
        body = "Arbatel Gown +3",           -- original: Zendik Robe (not owned)
        hands = "Arbatel Bracers +3",
        ring1 = "Murky Ring",               -- original: ring1 Metamor. Ring +1, ring2 Stikini Ring
        ring2 = { name="Metamor. Ring +1", augments={'Path: A',}},
        back = gear.nuke_jse_back,
        waist = "Null Belt",                -- original: Acuity Belt +1 (not owned)
        legs = "Arbatel Pants +3",          -- original: Chironic Hose (not owned)
        feet = "Acad. Loafers +4"           -- original: gear.merlinic_aspir_feet (augments not owned)
    }

    -- Elemental Magic sets are default for handling low-tier nukes.
    -- LINKTRI: Arbatel +3 beats Agwu R15 in every slot outside bursts (MAB 50-59 / Magic Dmg 30-34 / MAcc 60-64
    -- vs Agwu R15 about MAB 50 / Magic Dmg 28 / MAcc 40).
    -- original: Bunzi's Rod/Ammurapi, Pemphredo, Agwu's Cap/Robe/Gages/Pigaches, Saevus Pendant +1, Crematio/Friomisi,
    --   Metamor./Stikini, Refoccilation Stone, Merlinic Shalwar (Saevus/Friomisi/Refoccilation/Shalwar not owned)
    sets.midcast["Elemental Magic"] = {
        main = "Bunzi's Rod",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Arbatel Bonnet +3",
        neck = "Sibyl Scarf",
        ear1 = "Malignance Earring",
        ear2 = "Arbatel Earring +1",
        body = "Arbatel Gown +3",
        hands = "Arbatel Bracers +3",
        ring1 = "Murky Ring",
        ring2 = { name="Metamor. Ring +1", augments={'Path: A',}},
        back = gear.nuke_jse_back,
        waist = "Sacro Cord",               -- Orpheus/Hachirin replace this automatically when better
        legs = "Arbatel Pants +3",
        feet = "Arbatel Loafers +3"
    }

    -- original: Sanctity Necklace, Mallquis Cuffs +2, Metamor. Ring +1 in BOTH rings (Rare, only one owned),
    --   Acuity Belt +1, Merlinic Shalwar, Agwu's head/body/feet
    sets.midcast["Elemental Magic"].Resistant = set_combine(sets.midcast["Elemental Magic"], {neck = "Null Loop", waist = "Null Belt"})

    sets.midcast["Elemental Magic"]["9k"] = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = gear.merlinic_nuke_head,
        neck = "Sibyl Scarf",               -- original: Saevus Pendant +1 (not owned)
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",        -- original: Crematio Earring
        body = gear.merlinic_nuke_body,
        hands = "Mallquis Cuffs +2",
        ring1 = "Stikini Ring",             -- original: ring1 Metamor. Ring +1, ring2 Stikini Ring
        ring2 = { name="Metamor. Ring +1", augments={'Path: A',}},
        back = gear.nuke_jse_back,          -- original: Swith Cape +1 (not owned)
        waist = "Embla Sash",               -- original: Witful Belt
        legs = "Agwu's Slops",              -- original: Psycloth Lappas (not owned)
        feet = "Regal Pumps +1"
    }

    sets.midcast["Elemental Magic"].Proc = {
        main = empty,
        sub = empty,
        ammo = "Impatiens",
        head = "Vanya Hood",
        neck = "Voltsurge Torque",
        ear1 = "Malignance Earring",
		ear2 = "Etiolation Earring",        -- original: Enchntr. Earring +1 (not owned)
        body = "Vrikodara Jupon",           -- original: Zendik Robe (not owned)
        hands = "Acad. Bracers +4",         -- original: Gende. Gages +1 (not owned)
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",             -- original: Prolix Ring (not owned)
        back = "Perimede Cape",             -- original: Swith Cape +1 (not owned)
        waist = "Embla Sash",               -- original: Witful Belt
        legs = "Doyen Pants",               -- original: Psycloth Lappas (not owned)
        feet = "Regal Pumps +1"
    }

    -- LINKTRI: Khatvanga and the Merlinic Occult Acumen pieces aren't owned; rebuilt on owned Occult Acumen/Store TP gear.
    -- Mall. Chapeau +2 OA+11, Perdition Slops OA+30, Merlinic Crackows OA+4. Uses whatever weapon is equipped.
    sets.midcast["Elemental Magic"].OccultAcumen = {
        -- main = "Khatvanga",              -- LINKTRI: restore when Khatvanga is owned
        -- sub = "Bloodrain Strap",
        ammo = "Seraphic Ampulla",
        head = "Mall. Chapeau +2",
        neck = "Combatant's Torque",
        ear1 = "Dedition Earring",
        ear2 = "Telos Earring",
        body = gear.merlinic_nuke_body,     -- original: gear.merlinic_occult_body (augments not owned)
        hands = "Mallquis Cuffs +2",        -- original: gear.merlinic_occult_hands (not owned)
        ring1 = "Chirich Ring +1",          -- original: Rajas Ring (not owned)
        ring2 = "Petrov Ring",
        back = gear.nuke_jse_back,
        waist = "Null Belt",                -- original: Oneiros Rope (not owned)
        legs = "Perdition Slops",
        feet = gear.merlinic_nuke_feet      -- OA+4  -- original: gear.merlinic_occult_feet (augments not owned)
    }

    -- Gear for Magic Burst mode.
    -- LINKTRI: Magic burst damage from gear caps at +40: Bunzi's Rod 10 + Mizu. Kubikazari 10 + Agwu's Robe 10 +
    -- Arbatel Bracers +3 15 = 45 (capped). That frees legs for Arbatel Pants (MAB54). Magic burst damage II is a separate
    -- uncapped bonus: Peda. M.Board +3 (+4) + Arbatel Loafers +3 (+5).
    -- original: Agwu's Cap/Gages/Slops/Pigaches, Metamor./Stikini, Acuity Belt +1 (not owned)
    sets.MagicBurst = {
        main = "Bunzi's Rod",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Peda. M.Board +3",          -- MB II +4, MB accuracy +15
        neck = "Mizu. Kubikazari",          -- MB +10
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",
        body = "Agwu's Robe",               -- MB +10
        hands = "Arbatel Bracers +3",       -- MB +15
        ring1 = "Murky Ring",               -- original: ring1 Metamor. Ring +1, ring2 Stikini Ring
        ring2 = { name="Metamor. Ring +1", augments={'Path: A',}},
        back = gear.nuke_jse_back,
        waist = "Sacro Cord",
        legs = "Arbatel Pants +3",
        feet = "Arbatel Loafers +3"         -- MB II +5
    }

    -- Resistant Magic Burst set (for high magic evasion targets)
    sets.ResistantMagicBurst = set_combine(sets.MagicBurst, {waist = "Null Belt"})

    -- LINKTRI: sub Culminus (MAB+20) -> Ammurapi Shield (MAB+38, MAcc+38)
    sets.HelixBurst = set_combine(sets.MagicBurst, {})
    sets.ResistantHelixBurst = set_combine(sets.ResistantMagicBurst, {})

    -- Custom refinements for certain nuke tiers
    -- original HighTierNuke: Merlinic Hood, Saevus Pendant +1 (not owned), Metamor. Ring +1 in BOTH rings (Rare),
    --   Acuity Belt +1, Merlinic Shalwar (not owned); the Arbatel set above beats Merlinic Hood (MAB49/MAcc53)
    sets.midcast["Elemental Magic"].HighTierNuke = set_combine(sets.midcast["Elemental Magic"], {})
    sets.midcast["Elemental Magic"].HighTierNuke.Resistant = set_combine(sets.midcast["Elemental Magic"].Resistant, {})

    -- original Helix: Culminus, Merlinic Hood/Jubbah, Saevus, Crematio/Friomisi, Metamor. Ring +1 in BOTH rings (Rare),
    --   Refoccilation Stone, Merlinic Shalwar
    sets.midcast.Helix = set_combine(sets.midcast["Elemental Magic"], {})
    sets.midcast.Helix.Resistant = set_combine(sets.midcast["Elemental Magic"].Resistant, {})
    sets.midcast.Helix.Proc = set_combine(sets.midcast["Elemental Magic"].Proc, {})

    sets.midcast.Impact = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = empty,
        neck = "Null Loop",                 -- original: Erra Pendant
        ear1 = "Malignance Earring",
		ear2 = "Arbatel Earring +1",
        body = "Twilight Cloak",
        hands = "Arbatel Bracers +3",
        ring1 = "Murky Ring",               -- original: ring1 Metamor. Ring +1, ring2 Stikini Ring
        ring2 = { name="Metamor. Ring +1", augments={'Path: A',}},
        back = gear.nuke_jse_back,
        waist = "Null Belt",                -- original: Acuity Belt +1 (not owned)
        legs = "Arbatel Pants +3",          -- original: Merlinic Shalwar (not owned)
        feet = "Acad. Loafers +4"           -- Arts Magic Accuracy+20  -- original: Agwu's Pigaches
    }

    sets.midcast.Impact.OccultAcumen =
        set_combine(sets.midcast["Elemental Magic"].OccultAcumen, {head = empty, body = "Twilight Cloak"})

    -- Sets to return to when not performing an action.

    -- Idle sets
    sets.idle = {
        main = "Mpaca's Staff",
        sub = "Umbra Strap",
        ammo = "Homiliary",
        head = "Null Masque",
        neck = { name="Loricate Torque +1", augments={'Path: A',}},
        ear1 = "Alabaster Earring",
        ear2 = "Etiolation Earring",        -- original: Ethereal Earring (not owned)
        body = "Arbatel Gown +3",
        hands = "Peda. Bracers +3",
        ring1 = "Murky Ring",
        ring2 = "Stikini Ring",
        back = gear.nuke_jse_back,          -- original: Umbra Cape (not owned)
        waist = "Carrier's Sash",
        legs = "Arbatel Pants +3",
        feet = "Arbatel Loafers +3",
    }

    sets.idle.PDT = {
        main = "Malignance Pole",
        sub = "Umbra Strap",
        ammo = "Staunch Tathlum +1",
        head = { name="Nyame Helm", augments={'Path: B',}},        -- original: Gende. Caubeen +1 (not owned)
        neck = { name="Loricate Torque +1", augments={'Path: A',}},
        ear1 = "Alabaster Earring",         -- original: ear1 Etiolation Earring, ear2 Ethereal Earring (not owned)
        ear2 = "Etiolation Earring",
        body = "Adamantite Armor",          -- DT-20%  -- original: Vrikodara Jupon (DT-3%)
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},  -- original: Gende. Gages +1 (not owned)
        ring1 = "Murky Ring",               -- original: ring1 Defending Ring, ring2 Dark Ring (not owned)
        ring2 = "Defending Ring",
        back = gear.nuke_jse_back,          -- original: Umbra Cape (not owned)
        waist = "Carrier's Sash",
        legs = { name="Nyame Flanchard", augments={'Path: B',}},
        feet = { name="Nyame Sollerets", augments={'Path: B',}}    -- original: gear.chironic_refresh_feet (augments not owned)
    }

    sets.idle.Hippo = set_combine(sets.idle.PDT, {}) -- original: {feet = "Hippo. Socks +1"} (not owned)

    -- Resting sets
    -- original: Chatoyant Staff/Oneiros Grip, Befouled Crown, Chrys. Torque, Etiolation/Ethereal, Agwu's Robe,
    --   Merlinic Dastanas, Defending/Dark Ring, Umbra Cape, Fucho-no-Obi, Assid. Pants +1, Chironic Slippers (refresh)
    sets.resting = set_combine(sets.idle, {main = "Chatoyant Staff", sub = "Khonsu"})

    -- LINKTRI: Weakness set commented out (2026-10-17). Without it, Sel uses your normal idle set while weakened.
    -- To restore, uncomment the lines below; Sel-Include equips sets.idle.Weak automatically when it exists.
    -- sets.idle.Weak = {
        -- main = "Bolelabunga",
        -- sub = "Genmei Shield",
        -- ammo = "Homiliary",
        -- head = "Befouled Crown",
        -- neck = "Loricate Torque +1",
        -- ear1 = "Etiolation Earring",
        -- ear2 = "Ethereal Earring",
        -- body = "Jhakri Robe +2",
        -- hands = gear.merlinic_refresh_hands,
        -- ring1 = "Defending Ring",
        -- ring2 = "Dark Ring",
        -- back = "Umbra Cape",
        -- waist = "Carrier's Sash",
        -- legs = "Assid. Pants +1",
        -- feet = gear.chironic_refresh_feet
    -- }

    -- Porter Moogle packing set
    sets.packing = {
        main = "Akademos",
        sub = "Enki Strap",
        ammo = "Homiliary",
        head = "Null Masque",
        neck = "Null Loop",                 -- original: Sibyl Scarf
        ear1 = "Alabaster Earring",         -- original: ear1 Etiolation Earring, ear2 Ethereal Earring (not owned)
        ear2 = "Etiolation Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Murky Ring",               -- original: ring1 Defending Ring, ring2 Dark Ring (not owned)
        ring2 = "Defending Ring",
        back = gear.nuke_jse_back,
        waist = "Fucho-no-Obi",
        legs = "Assid. Pants +1",
        feet = "Nyame Sollerets"
    }

    -- Defense sets
    -- original PDT/MDT: Malignance Pole/Umbra Strap, Staunch +1, Gende. Caubeen +1, Loricate, Etiolation/Ethereal,
    --   Mallquis Saio +2, Gende. Gages +1, Defending/Dark Ring, Umbra Cape, Carrier's Sash, Nyame Flanchard, Battlecast Gaiters
    sets.defense.PDT = set_combine(sets.idle.PDT, {})
    sets.defense.MDT = set_combine(sets.idle.PDT, {})

    sets.defense.MEVA = {
        main = "Daybreak",
        sub = "Genmei Shield",
        ammo = "Staunch Tathlum +1",
        head = "Arbatel Bonnet +3",         -- MEVA+136  -- original: gear.merlinic_nuke_head
        neck = { name="Loricate Torque +1", augments={'Path: A',}},  -- original: Warder's Charm +1 (not owned)
        ear1 = "Alabaster Earring",         -- original: ear1 Etiolation Earring
        ear2 = "Sanare Earring",
        body = "Arbatel Gown +3",           -- MEVA+141  -- original: gear.merlinic_nuke_body
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},  -- original: Gende. Gages +1 (not owned)
        ring1 = "Vengeful Ring",
        ring2 = "Defending Ring",           -- original: Purity Ring (not owned)
        back = gear.nuke_jse_back,
        waist = "Carrier's Sash",           -- original: Acuity Belt +1 (not owned)
        legs = "Arbatel Pants +3",          -- MEVA+168  -- original: Merlinic Shalwar (not owned)
        feet = "Arbatel Loafers +3"         -- MEVA+168  -- original: Agwu's Pigaches
    }

    sets.Kiting = {ring2 = "Shneddick Ring +1"}
    sets.latent_refresh = {waist = "Fucho-no-Obi"}
    -- sets.latent_refresh_grip = {sub = "Oneiros Grip"} -- LINKTRI: not owned
    -- sets.TPEat = {neck = "Chrys. Torque"}             -- LINKTRI: not owned
    sets.DayIdle = {}
    sets.NightIdle = {}

    -- Engaged sets

    -- Normal melee group
    -- original: Befouled Crown/Jhakri Robe +2 refresh set with Merlinic Dastanas, Etiolation/Ethereal, Defending/Sheltered,
    --   Umbra Cape, Chironic Slippers (refresh)
    sets.engaged = {
        main = "Maxentius",
        sub = "Genmei Shield",
        ammo = "Homiliary",
        head = "Befouled Crown",
        neck = { name="Loricate Torque +1", augments={'Path: A',}},
        ear1 = "Alabaster Earring",
        ear2 = "Etiolation Earring",
        body = "Jhakri Robe +2",
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = "Murky Ring",
        ring2 = "Defending Ring",
        back = gear.nuke_jse_back,
        waist = "Carrier's Sash",
        legs = "Assid. Pants +1",
        feet = { name="Nyame Sollerets", augments={'Path: B',}}
    }

    -- original: same as idle.PDT but sub Oneiros Grip (not owned)
    sets.engaged.PDT = set_combine(sets.idle.PDT, {})

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

    -- HPDown/HPCure are only used by Sel's curecheat (dormant). Unowned items left as-is.
    sets.HPDown = {
        head = "Pixie Hairpin +1",
        ear1 = "Evans Earring",             -- LINKTRI: sides swapped so Evans stays ear1 (as in Myrkr)
        ear2 = "Mendicant's Earring",
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
        body = kaykaus_bliaut,
        hands = kaykaus_cuffs,
        ring1 = "Gelatinous Ring +1",
        ring2 = "Meridian Ring",
        back = "Moonlight Cape",
        waist = "Luminary Sash",
        legs = "Acad. Pants +4",            -- original: Carmine Cuisses +1 (SCH can't equip)
        feet = kaykaus_boots,
    }

    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff["Light Arts"] = {legs="Acad. Pants +4"}
    sets.buff["Dark Arts"] = {body="Acad. Gown +4"}


    sets.buff.Sublimation = {head = "Acad. Mortar. +4", waist = "Embla Sash"}
    sets.buff.DTSublimation = {waist = "Embla Sash"}

    -- Weapons sets
    sets.weapons.Akademos = {main = "Akademos", sub = "Enki Strap"}
    -- LINKTRI (2026-10-20): Opashoro stage 3 (MAB+60, Magic Damage+294, INT/MND+25, MAcc+25). About even with Bunzi's Rod +
    -- Ammurapi Shield for free nukes; the Rod's Magic burst damage +10 is better for bursts. Option, not default.
    sets.weapons.Opashoro = {main = "Opashoro", sub = "Enki Strap"}
    -- sets.weapons.Khatvanga = {main = "Khatvanga", sub = "Bloodrain Strap"} -- LINKTRI: restore (and add to state.Weapons) when Khatvanga is owned
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

-- LINKTRI (2026-10-20): renamed from job_customize_idle_set. That name replaced SCH.lua's own version (Sublimation
-- gear, Fucho-no-Obi below 51% MP, staff grip and TP-eat swaps). SCH.lua's version now runs first; this only adds
-- the Porter Moogle packing set.
--   original also re-did the Sublimation and latent-refresh logic here.
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
-- LINKTRI (2026-10-20): renamed from job_self_command. That name replaced SCH.lua's own, which prints your remaining
-- stratagem charges ('gs c showcharge', sent automatically after every stratagem).
function user_job_self_command(cmdParams, eventArgs)
    if cmdParams[1] == 'mb' then
        if cmdParams[2] == 'on' then
            mb_window_manual(true)
            windower.add_to_chat(121, '[GearSwap] MB window manually enabled (any target)')
        elseif cmdParams[2] == 'off' then
            mb_window_manual(false)
            windower.add_to_chat(121, '[GearSwap] MB window manually disabled')
        else
            -- Toggle
            windower.add_to_chat(121, '[GearSwap] MB window: '..tostring(mb_window_manual()))
        end
        eventArgs.handled = true
    end
end
