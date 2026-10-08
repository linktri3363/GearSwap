-------------------------------------------------------------------------------------------------------------------
-- Skillchain & Magic Burst Detection
-- Skillchain: detected via add_effect_message 196 or 288-302 on category 3 (weaponskill) actions
--             NOT add_effect_animation, which fires on any add effect (poison, enspell, etc.)
-- Magic Burst: detected via message IDs 252/265/268-275 on category 4 (spell finish)
--              restricted to player's own actions via act.actor_id == player.id
-- no_interruptions: locks position packets during casting to prevent movement interrupts; toggle with //gs c interrupts
-------------------------------------------------------------------------------------------------------------------

-- Skillchain window state
SCWindowOpen = false
SCWindowTimer = 0
SC_WINDOW_DURATION = 8

-- Skillchain add_effect_message IDs (Windower wiki Message IDs reference)
-- 196 = generic "Skillchain!" on weaponskill add_effect
-- 288-302 = named skillchains (Light, Darkness, Gravitation, Fragmentation, etc.)
local SC_MESSAGES = S{196, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302}

-- Magic burst message IDs on spell finish (category 4)
-- 252 = "Magic Burst! <target> takes damage" (with actor/spell name)
-- 265 = "Magic Burst! <target> takes damage" (without actor)
-- 268/269 = Magic Burst + status effect applied
-- 271/272 = Magic Burst + target is <status>
-- 274/275 = Magic Burst + HP/MP drained
local MB_MESSAGES = S{252, 265, 268, 269, 271, 272, 274, 275}

function is_sc_window_open()
    if SCWindowOpen then
        if (os.clock() - SCWindowTimer) < SC_WINDOW_DURATION then
            return true
        else
            SCWindowOpen = false
            return false
        end
    end
    return false
end

windower.raw_register_event('action', function(act)
    -- Category 3: weapon skill finish — check add_effect_message for skillchain IDs
    if act.category == 3 then
        for _, target in ipairs(act.targets) do
            for _, action in ipairs(target.actions) do
                if action.has_add_effect and SC_MESSAGES:contains(action.add_effect_message) then
                    SCWindowOpen = true
                    SCWindowTimer = os.clock()
                    windower.add_to_chat(121, '[GearSwap] Skillchain - MB window open ('..SC_WINDOW_DURATION..'s)')
                end
            end
        end
    -- Category 4: spell finish — detect our own magic bursts to close the SC window
    elseif act.category == 4 and act.actor_id == windower.ffxi.get_player().id then
        for _, target in ipairs(act.targets) do
            for _, action in ipairs(target.actions) do
                if MB_MESSAGES:contains(action.message) then
                    windower.add_to_chat(121, '[GearSwap] Magic Burst confirmed')
                    SCWindowOpen = false
                end
            end
        end
    end
end)

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
    elseif commands[1] and commands[1]:lower() == 'mb' then
        if commands[2] and commands[2]:lower() == 'on' then
            SCWindowOpen = true
            SCWindowTimer = os.clock()
            windower.add_to_chat(121, '[GearSwap] MB window manually opened')
        elseif commands[2] and commands[2]:lower() == 'off' then
            SCWindowOpen = false
            windower.add_to_chat(121, '[GearSwap] MB window manually closed')
        else
            SCWindowOpen = not SCWindowOpen
            if SCWindowOpen then SCWindowTimer = os.clock() end
            windower.add_to_chat(121, '[GearSwap] MB window: '..tostring(SCWindowOpen))
        end
        return true
    end
    return false
end)

function user_job_setup()
    -- Options: Override default values
    state.CastingMode:options("Normal", "Resistant", "Proc", "OccultAcumen")
    state.OffenseMode:options("Normal")
    state.HybridMode:options("Normal", "DT")
    state.IdleMode:options("Normal", "PDT", "DTHippo")
    state.Weapons:options("None", "Opashoro", "BurstWeapons") -- LINKTRI: Khatvanga/Lathi not owned
    
    gear.nuke_jse_back = {
        name = "Taranus's Cape",
        augments = {"INT+20", "Mag. Acc+20 /Mag. Dmg.+20", "INT+10", '"Mag.Atk.Bns."+10', "Damage taken-5%"}
    }
    gear.stp_jse_back = {name = "Taranus's Cape", augments = {"DEX+20", "Accuracy+20 Attack+20", '"Store TP"+10'}}

    -- Auto MB mode: equips MagicBurst set when SC window is open at spell finish
    state.AutoMBMode = M(true, 'Auto MB Mode')
    send_command('bind ^F7 gs c toggle AutoMBMode')

    -- Additional local binds
    send_command("bind ^` gs c cycle ElementalMode")
    send_command("bind ~^` gs c cycleback ElementalMode") --Robbiewobbie's idea
    -- LINKTRI (Sep 2026): ^q = Occult Acumen mode (TP-per-nuke); !q returns to Normal. No weapon swap - Khatvanga not owned.
    send_command("bind ^q gs c set CastingMode OccultAcumen")
    send_command("bind !q gs c weapons Default;gs c reset CastingMode;gs c reset DeathMode;gs c reset MagicBurstMode")
    send_command("bind !r gs c set DeathMode Single;gs c set MagicBurstMode Single")
    send_command('bind !\\\\ input /ja "Manawell" <me>')
    send_command('bind !` input /ma "Aspir III" <t>')
    send_command("bind @` gs c cycle MagicBurstMode")
    send_command("bind @f10 gs c cycle RecoverMode")
    send_command("bind @f9 gs c cycle DeathMode")
    send_command('bind @^` input /ja "Parsimony" <me>')
    send_command("bind !pause gs c toggle AutoSubMode") --Automatically uses sublimation and Myrkr.
    send_command('bind ^backspace input /ma "Stun" <t>')
    send_command('bind !backspace input /ja "Enmity Douse" <t>')
    send_command('bind @backspace input /ja "Alacrity" <me>')
    send_command('bind != input /ja "Light Arts" <me>')
    send_command('bind @= input /ja "Addendum: White" <me>')
    send_command('bind ^delete input /ja "Dark Arts" <me>')
    send_command('bind !delete input /ja "Addendum: Black" <me>')
    send_command('bind @delete input /ja "Manifestation" <me>')
    -- Add keybind to toggle Auto MB mode
    
    select_default_macro_book()
end

function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Weapons sets
    -- LINKTRI MODIFICATION (Jul 2026): Prime staff weapon set. Enki Strap: INT+10 MND+10 MAcc+10 MEva+10 (BLM ok).
    -- Stage 3 Opashoro: MAB+60, Magic Damage+294, INT+25, MAcc+25, MAcc skill+260, Sortie Oshala Aftermath (MAB+/mDMG+).
    sets.weapons.Opashoro = {main = "Opashoro", sub = "Enki Strap"}
    sets.weapons.BurstWeapons = {main = "Bunzi's Rod", sub = "Ammurapi Shield"}

    sets.buff.Sublimation = {waist = "Embla Sash"}
    sets.buff.DTSublimation = {waist = "Embla Sash"}

    -- Treasure Hunter

    sets.TreasureHunter = set_combine(sets.TreasureHunter, {}) -- LINKTRI: merlinic TH feet not in bags; NOTE - zero owned TH gear, TH mode currently does nothing

    ---- Precast Sets ----

    -- Precast sets to enhance JAs
    sets.precast.JA["Mana Wall"] = {back = gear.nuke_jse_back, feet = "Wicce Sabots +3"}

    sets.precast.JA.Manafont = {} --body="Sorcerer's Coat +2"

    -- equip to maximize HP (for Tarus) and minimize MP loss before using convert
    sets.precast.JA.Convert = {}

    -- Fast cast sets for spells

    sets.precast.FC = {
        main = gear.grioavolr_fc_staff,
        sub = "Clerisy Strap +1",
        ammo = "Impatiens",
        head = "Agwu's Cap",
        neck = "Voltsurge Torque",
        ear1 = "Malignance Earring",
        ear2 = "Loquac. Earring",
        body = "Agwu's Robe", -- LINKTRI FIX: FC+8%; Wicce Coat +3 has recast-16% but NO Fast Cast
        hands = "Agwu's Gages",
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",
        back = "Perimede Cape",
        waist = "Witful Belt",
        legs = "Agwu's Slops",
        feet = "Regal Pumps +1"
    }

    sets.precast.FC["Enhancing Magic"] = set_combine(sets.precast.FC, {waist = "Siegel Sash"})

    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC["Enhancing Magic"], {})

    -- LINKTRI FIX (Jul 2026): stripped dead overrides from FC["Elemental Magic"]:
    --   Prolix Ring / Swith Cape +1 not owned (silent failures; Lebeche Ring / Perimede Cape inherit),
    --   Siegel Sash was Enhancing-only cast time (Witful Belt inherits),
    --   Staunch ammo removed: interrupt protection only matters in midcast, and it was
    --   overriding Impatiens' Quick Magic +2% in the slot that actually procs it.
    -- LINKTRI REBUILD (Aug 2026, per Community BLM Guide): Elemental Celerity on a mastered BLM
    -- is 38% faster elemental casting, so this set only needs ~42% Fast Cast to hit the 80 cap.
    -- FC tally: Agwu Cap 5 + Robe 8 + Gages 6 + Slops 7 + Voltsurge 4 + Witful 3 + Loquac. 2
    --           + Grioavolr FC staff/Clerisy grip ~= 42-45.
    -- Every surplus slot is defense for the cast window: Slops R30 DT-10%, Staunch (DT-3, SIRD-11),
    -- Alabaster (DT-5), Murky + Defending (DT-20), Wicce Sabots (DT-11) ~= capped DT-50 while casting.
    -- Non-elemental magic keeps the max-FC base set (celerity is elemental-only).
    sets.precast.FC["Elemental Magic"] =
        set_combine(
        sets.precast.FC,
        {
            ammo = "Staunch Tathlum +1",
            ear1 = "Alabaster Earring",
            ring1 = "Defending Ring",
            ring2 = "Murky Ring",
            feet = "Wicce Sabots +3"
        }
    )

    sets.precast.FC.Cure =
        set_combine(sets.precast.FC, {}) -- LINKTRI: Serenity/Heka's Kalasiris not owned; base FC inherits

    sets.precast.FC.Curaga = sets.precast.FC.Cure

    sets.precast.FC.Impact = set_combine(sets.precast.FC, {head = empty, body = "Twilight Cloak"})
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main = "Daybreak", sub = "Genmei Shield"})

    sets.precast.FC.Death = {
        main = gear.grioavolr_nuke_staff,
        sub = "Enki Strap",
        ammo = "Impatiens",
        head = "Agwu's Cap",
        neck = "Voltsurge Torque",
        ear1 = "Malignance Earring",
        ear2 = "Loquac. Earring",
        body = "Agwu's Robe",
        hands = "Agwu's Gages",
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",
        back = "Perimede Cape",
        waist = "Witful Belt",
        legs = "Agwu's Slops",
        feet = "Regal Pumps +1"
    }

    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        ammo = "Knobkierrie", -- LINKTRI FIX: Ghastly Tathlum +1 not owned; Knobkierrie = WSD+6%
        head = "Nyame Helm",
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): MAcc+30 MAB+7; rank to 25 in Dyna-D
        ear1 = "Malignance Earring", -- LINKTRI FIX: Crematio was duplicated in both ears (one copy owned)
        ear2 = "Crematio Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3", -- LINKTRI: Agwu R15 loses to Wicce here too (magical WS)
        ring1 = "Murky Ring",
        ring2 = { name = "Metamor. Ring +1", augments = {'Path: A'}},
        back = gear.nuke_jse_back,
        waist = "Sacro Cord",
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS["Vidohunir"] = {
        ammo = "Knobkierrie", -- LINKTRI FIX: Ghastly Tathlum +1 not owned; Knobkierrie = WSD+6%
        head = "Nyame Helm",
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): MAcc+30 MAB+7; rank to 25 in Dyna-D
        ear1 = "Malignance Earring", -- LINKTRI FIX: Crematio was duplicated in both ears (one copy owned)
        ear2 = "Crematio Earring",
        body = "Wicce Coat +3",
        hands = "Nyame Gauntlets",
        ring1 = "Metamor. Ring +1",
        ring2 = "Murky Ring",
        back = gear.nuke_jse_back,
        waist = "Sacro Cord",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    -- LINKTRI (Jul 2026): Oshala — Opashoro Prime WS. BG-Wiki confirmed: PHYSICAL, single hit,
    -- 45% MND / 45% INT, fTP 3.95/7.89/11.84 (huge TP scaling -> Moonshade TP Bonus is BiS ear).
    -- Ind/Rev/Fusion SC properties. Accuracy comes from the staff's own Staff skill +260.
    -- STAGE 3: both the WS and its aftermath are SORTIE-ONLY (restriction lifts at stage 4).
    -- Waist: no owned physical-WS waist — Fotia Belt (fTP+) is the acquisition target for this slot.
    sets.precast.WS["Oshala"] = {
        ammo = "Knobkierrie",
        head = "Nyame Helm",
        neck = "Sacro Gorget",
        ear1 = "Moonshade Earring",
        ear2 = "Hoxne Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Chirich Ring +1",
        ring2 = { name = "Metamor. Ring +1", augments = {'Path: A'}},
        back = gear.nuke_jse_back,
        waist = "Plat. Mog. Belt",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.precast.WS["Myrkr"] = {
        ammo = "Staunch Tathlum +1",
        head = "Wicce Petasos +3",
        neck = "Sibyl Scarf",
        ear1 = "Moonshade Earring",
        ear2 = "Etiolation Earring",
        body = "Wicce Coat +3",
        hands = "Spae. Gloves +4",
        ring1 = "Stikini Ring",
        ring2 = "Mephitas's Ring",
        back = "Aurist's Cape +1",
        waist = "Sacro Cord",
        legs = "Wicce Chausses +3",
        feet = "Medium's Sabots"
    }

    sets.MaxTPMyrkr = {ear1 = "Evans Earring", ear2 = "Etiolation Earring"}

    ---- Midcast Sets ----

    sets.midcast.FastRecast = {
        main = gear.grioavolr_fc_staff,
        sub = "Clerisy Strap +1",
        ammo = "Impatiens",
        head = "Wicce Petasos +3",
        neck = "Voltsurge Torque",
        ear1 = "Malignance Earring",
        ear2 = "Loquac. Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",
        back = "Perimede Cape",
        waist = "Witful Belt",
        legs = "Wicce Chausses +3",
        feet = "Regal Pumps +1"
    }

    sets.midcast.Cure = {
        main = gear.gada_healing_club,
        sub = "Sors Shield",
        ammo = "Impatiens",
        head = "Wicce Petasos +3",
        neck = "Voltsurge Torque",
        ear1 = "Loquac. Earring",
        ear2 = "Etiolation Earring",
        body = "Wicce Coat +3",
        hands = "Telchine Gloves",
        ring1 = "Stikini Ring",
        ring2 = "Menelaus's Ring",
        back = "Aurist's Cape +1",
        waist = "Witful Belt",
        legs = "Wicce Chausses +3",
        feet = "Medium's Sabots"
    }

    sets.midcast.LightWeatherCure = {
        main = "Chatoyant Staff",
        sub = "Enki Strap",
        ammo = "Impatiens",
        head = "Wicce Petasos +3",
        neck = "Sibyl Scarf",
        ear1 = "Loquac. Earring",
        ear2 = "Etiolation Earring",
        body = "Wicce Coat +3",
        hands = "Telchine Gloves",
        ring1 = "Stikini Ring",
        ring2 = "Menelaus's Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = "Wicce Chausses +3",
        feet = "Medium's Sabots"
    }

    --Cureset for if it's not light weather but is light day.
    sets.midcast.LightDayCure = {
        main = "Chatoyant Staff",
        sub = "Enki Strap",
        ammo = "Impatiens",
        head = "Wicce Petasos +3",
        neck = "Sibyl Scarf",
        ear1 = "Loquac. Earring",
        ear2 = "Etiolation Earring",
        body = "Wicce Coat +3",
        hands = "Telchine Gloves",
        ring1 = "Stikini Ring",
        ring2 = "Menelaus's Ring",
        back = "Twilight Cape",
        waist = "Hachirin-no-Obi",
        legs = "Wicce Chausses +3",
        feet = "Medium's Sabots"
    }

    sets.midcast.Curaga = sets.midcast.Cure

    sets.midcast.Cursna =
        set_combine(
        sets.midcast.Cure,
        { -- LINKTRI: Debilis/Hieros/Haoma's/Oretan not owned; only Menelaus's remains
            ring2 = "Menelaus's Ring"
        }
    )

    sets.midcast.StatusRemoval =
        set_combine(sets.midcast.FastRecast, {main = gear.grioavolr_fc_staff, sub = "Clemency Grip"})

    sets.midcast["Enhancing Magic"] = {
        main = gear.gada_enhancing_club,
        sub = "Ammurapi Shield",
        ammo = "Impatiens",
        head = "Telchine Cap",
        neck = "Voltsurge Torque",
        ear1 = "Andoaa Earring",
        ear2 = "Loquac. Earring",
        body = "Telchine Chas.",
        hands = "Telchine Gloves",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = "Perimede Cape",
        waist = "Embla Sash",
        legs = "Telchine Braconi",
        feet = "Telchine Pigaches"
    }

    sets.midcast.Stoneskin =
        set_combine(
        sets.midcast["Enhancing Magic"],
        {neck = "Nodens Gorget", waist = "Siegel Sash"} -- LINKTRI: Earthcry/Shedir not owned
    )

    sets.midcast.Refresh = set_combine(sets.midcast["Enhancing Magic"], {}) -- LINKTRI: Amalric Coif not owned

    sets.midcast.Aquaveil =
        set_combine(
        sets.midcast["Enhancing Magic"],
        { -- LINKTRI: Vadose/Amalric/Emphatikos/Shedir not owned; kept owned overrides only
            sub = "Genmei Shield",
            hands = "Spae. Gloves +4"
        }
    )

    sets.midcast.BarElement = set_combine(sets.precast.FC["Enhancing Magic"], {}) -- LINKTRI: Shedir not owned

    sets.midcast["Enfeebling Magic"] = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = "Mall. Chapeau +2",
        neck = "Null Loop", -- LINKTRI: MAcc+50 vs Erra's 17 (Erra's dark skill does nothing for enfeebles)
        ear2 = "Wicce Earring +2",
        ear1 = "Malignance Earring",
        body = "Spae. Coat +4",
        hands = "Wicce Gloves +3",
        ring1 = "Kishar Ring",
        ring2 = "Metamor. Ring +1",
        back = gear.nuke_jse_back,
        waist = "Null Belt", -- LINKTRI: MAcc+30 vs Luminary's 10
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    sets.midcast["Enfeebling Magic"].Resistant = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = "Mall. Chapeau +2",
        neck = "Null Loop", -- LINKTRI: MAcc+50
        ear2 = "Wicce Earring +2",
        ear1 = "Malignance Earring",
        body = "Spae. Coat +4",
        hands = "Wicce Gloves +3",
        ring1 = "Stikini Ring",
        ring2 = "Metamor. Ring +1",
        back = gear.nuke_jse_back,
        waist = "Null Belt", -- LINKTRI: MAcc+30
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    -- Arch. Tonban +4 augment specifically increases Elemental Magic debuff time and potency
    sets.midcast.ElementalEnfeeble = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = "Spae. Petasos +4", -- LINKTRI: MAcc+57 and 3pc Spae set bonus (+30 MAcc with body+hands)
        neck = "Null Loop", -- LINKTRI: MAcc+50
        ear1 = "Malignance Earring",
        ear2 = "Wicce Earring +2", -- LINKTRI FIX: Regal Earring not owned (silent equip failure)
        body = "Spae. Coat +4",
        hands = "Spae. Gloves +4",
        ring1 = "Stikini Ring",
        ring2 = "Metamor. Ring +1",
        back = gear.nuke_jse_back,
        waist = "Null Belt",
        legs = "Arch. Tonban +4",
        feet = "Mallquis Clogs +2"
    }

    sets.midcast.IntEnfeebles =
        set_combine(sets.midcast["Enfeebling Magic"], {}) -- LINKTRI: Ea Hat/Acuity not owned; base has Mall. Chapeau/Null Belt
    sets.midcast.IntEnfeebles.Resistant =
        set_combine(sets.midcast["Enfeebling Magic"].Resistant, {}) -- LINKTRI: Ea Hat/Acuity not owned

    sets.midcast.MndEnfeebles =
        set_combine(sets.midcast["Enfeebling Magic"], {main = "Daybreak", sub = "Ammurapi Shield"})
    sets.midcast.MndEnfeebles.Resistant =
        set_combine(sets.midcast["Enfeebling Magic"].Resistant, {main = "Daybreak", sub = "Ammurapi Shield"})

    sets.midcast.Dia = set_combine(sets.midcast["Enfeebling Magic"], sets.TreasureHunter)
    sets.midcast["Dia II"] = set_combine(sets.midcast["Enfeebling Magic"], sets.TreasureHunter)

    sets.midcast.Bio = set_combine(sets.midcast["Enfeebling Magic"], sets.TreasureHunter)
    sets.midcast["Bio II"] = set_combine(sets.midcast["Enfeebling Magic"], sets.TreasureHunter)

    sets.midcast["Divine Magic"] = set_combine(sets.midcast["Enfeebling Magic"], {})

    sets.midcast["Dark Magic"] = {
        main = "Rubicundity",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Pixie Hairpin +1", -- LINKTRI (Sep 2026): dark affinity +28% (x1.28 on all dark damage incl. Bio)
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): MAcc+30 MAB+7; rank to 25 in Dyna-D
        ear2 = "Wicce Earring +2",
        ear1 = "Malignance Earring",
        body = "Spae. Coat +4",
        hands = "Spae. Gloves +4",
        ring1 = "Stikini Ring",
        ring2 = "Metamor. Ring +1",
        back = gear.nuke_jse_back,
        waist = "Null Belt",
        legs = "Spae. Tonban +4",
        feet = "Wicce Sabots +3" -- LINKTRI FIX: merlinic_aspir_feet not in bags
    }

    -- Spae. Tonban +2: Drain/Aspir potency +10 is a separate multiplicative term — outweighs Wicce Chausses MAB on drain spells
    sets.midcast.Drain = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = "Pixie Hairpin +1", -- LINKTRI (Sep 2026): dark affinity x1.28 also multiplies Drain/Aspir potency (Aspir inherits)
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): MAcc+30 MAB+7; rank to 25 in Dyna-D
        ear2 = "Wicce Earring +2",
        ear1 = "Hirudinea Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Stikini Ring", -- LINKTRI FIX: rings were undefined; Kishar/Lebeche were lingering from precast
        ring2 = "Murky Ring",
        back = gear.nuke_jse_back,
        waist = "Fucho-no-obi",
        legs = "Spae. Tonban +4",
        feet = "Agwu's Pigaches" -- LINKTRI (Aug 2026): R30 = Drain/Aspir potency +35% + MAcc+55
    }

    -- LINKTRI (Aug 2026): Agwu Pigaches R30 = Drain/Aspir potency +35% (verified) + MAcc+55 + SIRD+10.
    -- Arch. Sabots +4's 20x Aspir magnitude is undocumented (BG-Wiki "Information Needed") - Pigaches
    -- inherit from Drain for both spells now; re-test Sabots in-game if curious.
    sets.midcast.Aspir = set_combine(sets.midcast.Drain, {})

    sets.midcast.Aspir.Death = {
        main = gear.grioavolr_nuke_staff,
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = "Pixie Hairpin +1", -- LINKTRI (Sep 2026): dark affinity x1.28 on Aspir potency
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): MAcc+30 MAB+7; rank to 25 in Dyna-D
        ear1 = "Malignance Earring",
        ear2 = "Wicce Earring +2", -- LINKTRI FIX: Regal Earring not owned
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Stikini Ring",
        ring2 = "Murky Ring",
        back = gear.nuke_jse_back,
        waist = "Fucho-no-obi",
        legs = "Spae. Tonban +4",
        feet = "Agwu's Pigaches" -- LINKTRI (Aug 2026): R30 = Drain/Aspir potency +35% verified
    }

    sets.midcast.Death = {
        main = "Bunzi's Rod",
        sub = "Ammurapi Shield",
        ammo = "Pemphredo Tathlum",
        head = "Pixie Hairpin +1", -- LINKTRI (Sep 2026): dark affinity +28% beats Wicce head (MAB51/mDMG31 ~ +12%) on Death
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): equal MB+10, superior everything else vs Mizukage
        ear2 = "Wicce Earring +2",
        ear1 = "Malignance Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Metamor. Ring +1",
        ring2 = "Murky Ring",
        back = gear.nuke_jse_back,
        waist = "Sacro Cord", -- LINKTRI: neutral default; job_post_midcast swaps in Hachirin/Orpheus when they pay
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    sets.midcast.Comet = {
        main = "Opashoro", -- LINKTRI: stage 3 Opashoro (mDMG+294, MAB+60) beats Lathi
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum", -- LINKTRI FIX: Ghastly Tathlum +1 not owned
        head = "Pixie Hairpin +1", -- LINKTRI (Sep 2026): dark affinity +28% - acquired; Comet's biggest single upgrade
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): MAcc+30 MAB+7; rank to 25 in Dyna-D
        ear1 = "Malignance Earring",
        ear2 = "Wicce Earring +2", -- LINKTRI FIX: Regal Earring not owned
        body = "Wicce Coat +3", -- LINKTRI: Wicce core replaces legacy Merlinic/Amalric (MAB59/mDMG34 etc.)
        hands = "Wicce Gloves +3",
        ring1 = "Metamor. Ring +1",
        ring2 = "Murky Ring",
        back = gear.nuke_jse_back,
        waist = "Sacro Cord", -- LINKTRI: neutral default; job_post_midcast swaps in Hachirin/Orpheus when they pay
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    sets.midcast.Stun = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Impatiens",
        head = "Wicce Petasos +3",
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): MAcc+30 for stun landing (Voltsurge is a precast FC neck)
        ear1 = "Malignance Earring",
        ear2 = "Wicce Earring +2",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Stikini Ring",
        ring2 = "Metamor. Ring +1",
        back = gear.nuke_jse_back,
        waist = "Witful Belt",
        legs = "Wicce Chausses +3",
        feet = "Regal Pumps +1"
    }

    sets.midcast.Stun.Resistant = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = "Wicce Petasos +3",
        neck = "Null Loop", -- LINKTRI: MAcc+50, stun landing is pure MAcc
        ear1 = "Malignance Earring",
        ear2 = "Wicce Earring +2", -- LINKTRI FIX: Regal Earring not owned
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Stikini Ring",
        ring2 = "Metamor. Ring +1",
        back = gear.nuke_jse_back,
        waist = "Witful Belt",
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3" -- LINKTRI FIX: merlinic_aspir_feet not in bags
    }

    sets.midcast.BardSong = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum", -- LINKTRI FIX: Ghastly Tathlum +1 not owned
        head = "Wicce Petasos +3",
        neck = "Null Loop", -- LINKTRI: MAcc+50 for lullaby landing
        ear1 = "Malignance Earring",
        ear2 = "Wicce Earring +2", -- LINKTRI FIX: Regal Earring not owned
        body = "Wicce Coat +3",
        hands = "Spae. Gloves +4",
        ring1 = "Stikini Ring",
        ring2 = "Metamor. Ring +1",
        back = gear.nuke_jse_back,
        waist = "Luminary Sash",
        legs = "Wicce Chausses +3",
        feet = "Medium's Sabots"
    }

    sets.midcast.Impact = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = empty,
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): MAcc+30 MAB+7; rank to 25 in Dyna-D
        ear1 = "Malignance Earring",
        ear2 = "Wicce Earring +2", -- LINKTRI FIX: Regal Earring not owned
        body = "Twilight Cloak", 
        hands = "Spae. Gloves +4",
        ring1 = "Stikini Ring",
        ring2 = "Metamor. Ring +1",
        back = gear.nuke_jse_back,
        waist = "Null Belt",
        legs = "Wicce Chausses +3",
        feet = "Mallquis Clogs +2"
    }

    -- Elemental Magic sets
    -- LINKTRI REWORK (Jul 2026): Agwu set is R15, not R30 (R15 totals: MAB 35+15=50, mDMG 20+8=28).
    -- At R15, Wicce +3 beats Agwu in EVERY nuke slot:
    --   Head:  Wicce Petasos +3 (MAB51/mDMG31/MAcc61) > Agwu Cap R15 (50/28/40)
    --   Hands: Wicce Gloves +3  (MAB57/mDMG32/MAcc62) > Agwu Gages R15 (50/28/40)
    --   Legs:  Wicce Chausses +3(MAB58/mDMG33/MAcc63) > Agwu Slops R15 (50/28/40)
    --   Feet:  Wicce Sabots +3  (MAB50/mDMG30/MAcc60) > Agwu Pigaches R15 (50/28/40)
    -- Low/High tier are identical PERMANENTLY (verified Aug 2026): even at Agwu R30 (MAB+25/mDMG+15
    -- max augs), the best piece gains only ~+2% raw over Wicce +3 while breaking the 5pc Empyrean
    -- Conserve MP set bonus (field-measured at 15-20% average damage). Wicce 5/5 wins at every Agwu rank.
    -- Wicce 5/5 also maxes the Conserve MP set-bonus activation (+25%); procs add +12.5~100% damage.
    -- Resistant sets: Null Loop (MAcc+50) replaces Sanctity Necklace (MAcc+10).
    -- Weapon: STAGE 3 OPASHORO CONFIRMED IN HAND (Jul 2026) — live in every nuke/MB/Helix/Comet set.
    -- Its Magic Accuracy skill +260 also makes it the best LANDING weapon, so it now also mains the
    -- enfeebling, ElementalEnfeeble, Drain/Aspir, Stun, BardSong, and Impact sets.
    -- Death keeps Bunzi's Rod + Ammurapi (Death scales on MP; Opashoro has none).
    -- Sortie: keep Oshala Aftermath up — WS at high TP for stronger/longer MAB+/mDMG+ (dedicated Oshala set below).

    sets.midcast["Elemental Magic"] = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum", -- LINKTRI FIX: Ghastly Tathlum +1 not owned
        head = "Wicce Petasos +3",
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): MAcc+30 MAB+7; rank to 25 in Dyna-D
        ear2 = "Wicce Earring +2",
        ear1 = "Malignance Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Murky Ring",
        ring2 = { name = "Metamor. Ring +1", augments = {'Path: A'}},
        back = gear.nuke_jse_back,
        waist = "Sacro Cord", -- LINKTRI: neutral default; job_post_midcast swaps in Hachirin/Orpheus when they pay
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    sets.midcast["Elemental Magic"].Resistant = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = "Wicce Petasos +3",
        neck = "Null Loop",
        ear2 = "Wicce Earring +2",
        ear1 = "Malignance Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Murky Ring",
        ring2 = { name = "Metamor. Ring +1", augments = {'Path: A'}},
        back = gear.nuke_jse_back,
        waist = "Null Belt",
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    -- LowTierNuke: fully explicit set — identical to base but written out to avoid any table reference issues
    sets.midcast["Elemental Magic"].LowTierNuke = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum", -- LINKTRI FIX: Ghastly Tathlum +1 not owned
        head = "Wicce Petasos +3",
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): MAcc+30 MAB+7; rank to 25 in Dyna-D
        ear2 = "Wicce Earring +2",
        ear1 = "Malignance Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Murky Ring",
        ring2 = { name = "Metamor. Ring +1", augments = {'Path: A'}},
        back = gear.nuke_jse_back,
        waist = "Sacro Cord", -- LINKTRI: neutral default; job_post_midcast swaps in Hachirin/Orpheus when they pay
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    sets.midcast["Elemental Magic"].LowTierNuke.Resistant = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = "Wicce Petasos +3",
        neck = "Null Loop",
        ear2 = "Wicce Earring +2",
        ear1 = "Malignance Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Murky Ring",
        ring2 = { name = "Metamor. Ring +1", augments = {'Path: A'}},
        back = gear.nuke_jse_back,
        waist = "Null Belt",
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    -- HighTierNuke: Agwu hands/legs pull ahead at Stone III+ due to higher MAB outweighing mDMG delta
    sets.midcast["Elemental Magic"].HighTierNuke = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum", -- LINKTRI FIX: Ghastly Tathlum +1 not owned
        head = "Wicce Petasos +3",
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): MAcc+30 MAB+7; rank to 25 in Dyna-D
        ear2 = "Wicce Earring +2",
        ear1 = "Malignance Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Murky Ring",
        ring2 = { name = "Metamor. Ring +1", augments = {'Path: A'}},
        back = gear.nuke_jse_back,
        waist = "Sacro Cord", -- LINKTRI: neutral default; job_post_midcast swaps in Hachirin/Orpheus when they pay
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    sets.midcast["Elemental Magic"].HighTierNuke.Resistant = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = "Wicce Petasos +3",
        neck = "Null Loop",
        ear2 = "Wicce Earring +2",
        ear1 = "Malignance Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Murky Ring",
        ring2 = { name = "Metamor. Ring +1", augments = {'Path: A'}},
        back = gear.nuke_jse_back,
        waist = "Null Belt",
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    sets.midcast.Helix = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum", -- LINKTRI FIX: Ghastly Tathlum +1 not owned
        head = "Wicce Petasos +3",
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): MAcc+30 MAB+7; rank to 25 in Dyna-D
        ear2 = "Wicce Earring +2",
        ear1 = "Malignance Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Murky Ring",
        ring2 = { name = "Metamor. Ring +1", augments = {'Path: A'}},
        back = gear.nuke_jse_back,
        waist = "Sacro Cord", -- LINKTRI: neutral default; job_post_midcast swaps in Hachirin/Orpheus when they pay
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }
    sets.midcast.Helix.Resistant = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = "Wicce Petasos +3",
        neck = "Null Loop",
        ear2 = "Wicce Earring +2",
        ear1 = "Malignance Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Murky Ring",
        ring2 = { name = "Metamor. Ring +1", augments = {'Path: A'}},
        back = gear.nuke_jse_back,
        waist = "Null Belt",
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    -- Minimal damage gear, maximum recast gear for procs.
    sets.midcast["Elemental Magic"].Proc = {
        main = empty,
        sub = empty,
        ammo = "Impatiens",
        head = "Spae. Petasos +4",  -- cast time -6%, INT+37, MagAcc+47 — better than Vanya Hood for elemental proc attempts
        neck = "Loricate Torque +1",
        ear1 = "Malignance Earring",
        ear2 = "Loquac. Earring",
        body = "Spae. Coat +4",
        hands = "Spae. Gloves +4",
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",
        back = "Perimede Cape",
        waist = "Witful Belt",
        legs = "Assid. Pants +1",
        feet = "Regal Pumps +1"
    }

    sets.midcast["Elemental Magic"].OccultAcumen = {
        main = "Opashoro", -- LINKTRI (Sep 2026): Khatvanga not owned. OA comes from Mall. Chapeau +2 / Perdition Slops / Seraphic Ampulla;
        sub = "Enki Strap",    -- the weapon just needs to nuke well. (Bloodrain Strap's STP was only worth it alongside Khatvanga.)
        ammo = "Seraphic Ampulla",
        head = "Mall. Chapeau +2",
        neck = "Combatant's Torque",
        ear1 = "Dedition Earring",
        ear2 = "Telos Earring",
        body = "Wicce Coat +3", -- LINKTRI FIX: merlinic_occult_body = Merlinic Jubbah (validate false-positive risk aside, never seen equipping)
        hands = "Wicce Gloves +3", -- LINKTRI FIX: merlinic_occult_hands not in bags
        ring1 = "Crepuscular Ring",
        ring2 = "Chirich Ring +1",
        back = gear.nuke_jse_back, -- LINKTRI FIX (Sep 2026): STP Taranus variant not owned (dead slot); nuke Taranus recovers damage
        waist = "Sacro Cord",
        legs = "Perdition Slops",
        feet = "Wicce Sabots +3" -- LINKTRI FIX: merlinic_occult_feet not in bags
    }

    sets.midcast.Impact.OccultAcumen =
        set_combine(sets.midcast["Elemental Magic"].OccultAcumen, {head = empty, body = "Twilight Cloak"})

    -- Gear that converts elemental damage done to recover MP.
    sets.RecoverMP = {body = "Spae. Coat +4"}

    -- Gear for Magic Burst mode.
    -- LINKTRI REWORK (Jul 2026): Magic Burst Damage I from gear caps at +40.
    --   Arch. Gloves +4 (MB+20) + Wicce Chausses +3 (MB+15) + Mizukage (MB+10) = 45 -> already over cap.
    --   Arch. Petasos +4 20x MB bonus and Agwu Pigaches MB+6 were fully wasted overcap, so those slots
    --   now go to raw MAB/mDMG: Wicce Petasos +3 head, Wicce Coat +3 body (MAB59/mDMG34/MB II+5, and
    --   MB II is a separate uncapped multiplier), Wicce Sabots +3 feet.
    --   Arch. Gloves +4 stay: their MB+20 is what reaches the +40 cap (worth ~+9%, more than Wicce hands offer).
    --   4x Wicce + Arch. Gloves = 5 Empyrean pieces = +25% Conserve MP set-bonus activation.
    --   NOTE: for Ancient Magic bursts specifically, Arch. Petasos +4 head wins (20x also gives AM damage +10%,
    --   a separate multiplier); swap manually or add an AncientMagic set if you burst AM often.
    sets.MagicBurst = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum", -- LINKTRI FIX: Ghastly Tathlum +1 not owned
        head = "Wicce Petasos +3",
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): MB+10 hits the same 40 cap as Mizukage, then adds MB Acc+25, MAcc+30, MAB+7, INT+15
        ear2 = "Wicce Earring +2",
        ear1 = "Malignance Earring",
        body = "Wicce Coat +3",
        hands = "Arch. Gloves +4",
        ring1 = "Murky Ring",
        ring2 = { name = "Metamor. Ring +1", augments = {'Path: A'}},
        back = gear.nuke_jse_back,
        waist = "Sacro Cord",
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    sets.ResistantMagicBurst = {
        main = "Opashoro",
        sub = "Enki Strap",
        ammo = "Pemphredo Tathlum",
        head = "Wicce Petasos +3",
        neck = "Src. Stole +2", -- LINKTRI (Aug 2026): MB+10 keeps MBD capped (no loss vs Mizukage), plus MB Acc+25/MAcc+30
        ear2 = "Wicce Earring +2",
        ear1 = "Malignance Earring",
        body = "Wicce Coat +3",
        hands = "Arch. Gloves +4",
        ring1 = { name = "Murky Ring", augments = {'Path: A'}},
        ring2 = { name = "Metamor. Ring +1", augments = {'Path: A'}},
        back = gear.nuke_jse_back,
        waist = "Null Belt",
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    -- Sets to return to when not performing an action.

    -- Resting sets
    sets.resting = {
        main = "Mpaca's Staff",
        sub = "Umbra Strap",
        ammo = "Staunch Tathlum +1",
        head = "Befouled Crown",
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",
        ear2 = "Etiolation Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3", -- LINKTRI FIX: merlinic_refresh_hands = Merlinic Dastanas (not in bags)
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = "Aurist's Cape +1",
        waist = "Carrier's Sash",
        legs = "Assid. Pants +1",
        feet = "Wicce Sabots +3" -- LINKTRI FIX: merlinic_refresh_feet = Merlinic Crackows (not in bags)
    }

    -- Idle sets

    -- Normal refresh idle set
    sets.idle = {
        main = "Mpaca's Staff",
        sub = "Umbra Strap",
        ammo = "Staunch Tathlum +1",
        head = "Null Masque", -- LINKTRI: Refresh+1, Regen+3, Regain+2, DT-10%, Haste+10%
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",
        ear2 = "Etiolation Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = "Aurist's Cape +1",
        waist = "Carrier's Sash",
        legs = "Assid. Pants +1",
        feet = "Wicce Sabots +3"
    }

    -- Idle mode that keeps PDT gear on, but doesn't prevent normal gear swaps for precast/etc.
    -- LINKTRI REWORK (Jul 2026): capped DT-50% with Refresh retained.
    -- DT: Staunch 3 + Null Masque 10 + Alabaster 5 + Adamantite 20 + Wicce hands 13 + Defending 10
    --     + Murky 10 + Plat. Mog. 3 + Wicce feet 11 = 85 (cap 50, huge slack), Refresh+3 (Masque 1 + Assid. 2)
    sets.idle.PDT = {
        main = "Malignance Pole",
        sub = "Umbra Strap",
        ammo = "Staunch Tathlum +1",
        head = "Null Masque",
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",
        ear2 = "Etiolation Earring",
        body = "Adamantite Armor",
        hands = "Wicce Gloves +3",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",
        back = "Aurist's Cape +1",
        waist = "Plat. Mog. Belt",
        legs = "Assid. Pants +1",
        feet = "Wicce Sabots +3"
    }

    sets.idle.MDT = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Staunch Tathlum +1",
        head = "Wicce Petasos +3",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Alabaster Earring",
        body = "Adamantite Armor", -- LINKTRI: DT-20% + MDB+20 vs Mallquis Saio
        hands = "Wicce Gloves +3",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",
        back = "Aurist's Cape +1",
        waist = "Carrier's Sash",
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    sets.idle.DTHippo = set_combine(sets.idle.PDT, {}) -- LINKTRI: Hippo. Socks +1 not owned

    sets.idle.Death = {
        main = gear.grioavolr_nuke_staff,
        sub = "Umbra Strap",
        ammo = "Staunch Tathlum +1",
        head = "Befouled Crown",
        neck = "Loricate Torque +1",
        ear1 = "Barkarole Earring",
        ear2 = "Etiolation Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3", -- LINKTRI FIX: merlinic_refresh_hands = Merlinic Dastanas (not in bags)
        ring1 = "Stikini Ring",
        ring2 = "Mephitas's Ring",
        back = "Aurist's Cape +1",
        waist = "Fucho-no-obi",
        legs = "Assid. Pants +1",
        feet = "Wicce Sabots +3" -- LINKTRI FIX: merlinic_refresh_feet = Merlinic Crackows (not in bags)
    }

    sets.idle.Weak = {
        main = "Daybreak",
        sub = "Genmei Shield",
        ammo = "Staunch Tathlum +1",
        head = "Befouled Crown",
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",
        ear2 = "Etiolation Earring",
        body = "Wicce Coat +3",
        hands = "Wicce Gloves +3", -- LINKTRI FIX: merlinic_refresh_hands = Merlinic Dastanas (not in bags)
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",
        back = "Aurist's Cape +1",
        waist = "Carrier's Sash",
        legs = "Assid. Pants +1",
        feet = "Wicce Sabots +3" -- LINKTRI FIX: merlinic_refresh_feet = Merlinic Crackows (not in bags)
    }

    -- Packing gear for Porter Moogle
    sets.packing = {
        main = "Mpaca's Staff",
        sub = "Umbra Strap",
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Alabaster Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back = "Aurist's Cape +1",
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    -- Defense sets

    sets.defense.PDT = {
        main = "Malignance Pole",
        sub = "Umbra Strap",
        ammo = "Staunch Tathlum +1",
        head = "Wicce Petasos +3",
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring", -- LINKTRI: DT-5% + HP+100 vs Genmei's PDT-2%
        ear2 = "Etiolation Earring",
        body = "Adamantite Armor", -- LINKTRI: DT-20% vs Mallquis Saio
        hands = "Wicce Gloves +3",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring", -- LINKTRI: DT-10% vs Dark Ring's PDT-6/MDT-6
        back = "Aurist's Cape +1",
        waist = "Plat. Mog. Belt", -- LINKTRI: HP+10%, DT-3%
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    sets.defense.MDT = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Staunch Tathlum +1",
        head = "Wicce Petasos +3",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Alabaster Earring",
        body = "Adamantite Armor", -- LINKTRI: DT-20% + MDB+20
        hands = "Wicce Gloves +3",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",
        back = "Aurist's Cape +1",
        waist = "Carrier's Sash",
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    sets.defense.MEVA = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        ammo = "Staunch Tathlum +1",
        head = "Wicce Petasos +3",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Alabaster Earring",
        body = "Wicce Coat +3", -- LINKTRI: MEva+141 (highest owned) + Refresh+4
        hands = "Wicce Gloves +3",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",
        back = "Aurist's Cape +1",
        waist = "Carrier's Sash",
        legs = "Wicce Chausses +3",
        feet = "Wicce Sabots +3"
    }

    sets.Kiting = {ring1 = "Shneddick Ring +1"}
    sets.latent_refresh = {waist = "Fucho-no-obi"}
    sets.latent_refresh_grip = {} -- LINKTRI: Oneiros Grip not owned
    sets.TPEat = {} -- LINKTRI: Chrys. Torque not owned
    sets.DayIdle = {feet = "Wicce Sabots +3"} -- LINKTRI FIX: merlinic_refresh_feet = Merlinic Crackows (not in bags)
    sets.NightIdle = {}

    -- Buff sets: Gear that needs to be worn to actively enhance a current player buff.

    sets.HPDown = {
        head = "Jhakri Coronal +2",
        ear1 = "Genmei Earring",
        ear2 = "Evans Earring",
        body = "Jhakri Robe +2",
        hands = "Jhakri Cuffs +2",
        ring1 = "Stikini Ring",
        ring2 = "Mephitas's Ring",
        back = "Perimede Cape",
        legs = "Assid. Pants +1",
        feet = "Jhakri Pigaches +2"
    }

    sets.HPCure = {
        main = gear.gada_healing_club,
        sub = "Sors Shield",
        ammo = "Impatiens",
        head = "Nyame Helm",
        neck = "Nodens Gorget",
        ear1 = "Etiolation Earring",
        ear2 = "Alabaster Earring",
        body = "Vrikodara Jupon",
        hands = "Telchine Gloves",
        ring1 = "Stikini Ring",
        ring2 = "Menelaus's Ring",
        back = "Aurist's Cape +1",
        waist = "Witful Belt",
        legs = "Wicce Chausses +3",
        feet = "Medium's Sabots"
    }

    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff["Mana Wall"] = {back = gear.nuke_jse_back, feet = "Wicce Sabots +3"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    -- Normal melee group
    sets.engaged = {
        ammo = "Staunch Tathlum +1",
        head = "Malignance Chapeau",
        neck = "Combatant's Torque",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.stp_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.DT = {
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Combatant's Torque",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.stp_jse_back,
        waist = "Plat. Mog. Belt",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    --Situational sets: Gear that is equipped on certain targets
    sets.Self_Healing = {
        -- LINKTRI: emptied - Phalaina/Kunaji/Asklepian/Gishdubar all unowned (same silent-failure
        -- class as the WHM sets.Self_Healing bug); re-populate if any are acquired
    }
    sets.Cure_Received = {
        -- LINKTRI: emptied - all four items unowned (see Self_Healing note)
    }
    sets.Self_Refresh = {feet = "Inspirited Boots"} -- LINKTRI: Grapevine/Gishdubar not owned
end



-------------------------------------------------------------------------------------------------------------------
-- Job Post Midcast - Magic Burst gear equip on confirmed skillchain window
-------------------------------------------------------------------------------------------------------------------
-- LINKTRI MODIFICATION (Jul 2026): Orpheus/Hachirin tuning constants.
-- Orpheus's Sash affinity: +15 at <=1.93 yalms, tapering to +1 at >=13 yalms.
-- Hachirin-no-Obi: +10 day match, +10 single weather, +25 double weather (stack with day).
local ORPHEUS_MIN_DIST = 1.93   -- distance at which Orpheus gives its max +15
local ORPHEUS_MAX_DIST = 13.0   -- distance beyond which Orpheus gives only +1
local ORPHEUS_MIN_WORTH = 2     -- below this affinity, a neutral waist (Sacro/Acuity) wins

local function nuke_waist_bonus(spell, spellMap)
    -- Returns the best waist for this cast based on day/weather/distance.
    local el = spell.element
    if not el or el == 'None' then return nil end

    -- Hachirin side: day + weather bonuses.
    -- LINKTRI (per BG-Wiki Magic Damage page): Helix spells receive day/weather at 100% with NO
    -- equipment required, so the obi adds nothing on a Helix - skip straight to Orpheus/neutral.
    local obi = 0
    if spellMap == 'Helix' then
        -- leave obi at 0
    else
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

    -- LINKTRI (per BG-Wiki): day/weather still proc naturally ~33% of the time WITHOUT the obi,
    -- so wearing Orpheus only gives up ~2/3 of the obi's bonus. Compare accordingly - this moves
    -- the Orpheus-over-Hachirin crossover from ~5.5 to ~8.5 yalms against single weather/day.
    if (obi * 0.67) >= aff and obi > 0 then
        return "Hachirin-no-Obi"
    elseif aff >= ORPHEUS_MIN_WORTH then
        return "Orpheus's Sash"
    end
    return nil -- no meaningful affinity bonus available; let the set's neutral waist decide
end

function job_post_midcast(spell, spellMap, eventArgs)
    if spell.action_type == 'Magic' then
        -- LINKTRI FIX (Jul 2026): this override was replacing BLM.lua's job_post_midcast entirely,
        -- silently dropping the stock DeathMode and Mana Wall handling. Both restored below.

        -- (restored from BLM.lua) DeathMode: hold Death midcast gear through other casts
        if state.DeathMode.value ~= 'Off' and spell.english ~= 'Death' then
            if sets.midcast[spell.english] and sets.midcast[spell.english].Death then
                equip(sets.midcast[spell.english].Death)
            elseif sets.midcast[spellMap] and sets.midcast[spellMap].Death then
                equip(sets.midcast[spellMap].Death)
            elseif sets.midcast[spell.skill] and sets.midcast[spell.skill].Death then
                equip(sets.midcast[spell.skill].Death)
            else
                equip(sets.precast.FC.Death)
            end
        end

        -- Auto Magic Burst detection (skillchain window open)
        if spell.skill == 'Elemental Magic' and state.AutoMBMode.value and is_sc_window_open() then
            if state.CastingMode.value == 'Resistant' then
                windower.add_to_chat(121, '[GearSwap] MB window open - equipping ResistantMagicBurst for: '..spell.english)
                equip(sets.ResistantMagicBurst)
            else
                windower.add_to_chat(121, '[GearSwap] MB window open - equipping MagicBurst for: '..spell.english)
                equip(sets.MagicBurst)
            end
            -- LINKTRI (Sep 2026): dark-element bursts (Comet) keep Pixie Hairpin +1 over the MB set's Wicce head;
            -- the x1.28 affinity multiplier outvalues the head's MAB/mDMG on any dark spell.
            if spell.element == 'Dark' then
                equip({head = "Pixie Hairpin +1"})
            end
        end

        -- LINKTRI MODIFICATION (Jul 2026): Orpheus/Hachirin/neutral waist selection for nukes.
        -- Runs AFTER the MB equip so the affinity waist also overrides the MB set's Sacro Cord
        -- (day/weather/affinity multipliers apply to bursts too).
        if ((spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble')
                or spell.english == 'Comet' or spell.english == 'Death')
                and state.CastingMode.value ~= 'Proc'
                and state.CastingMode.value ~= 'OccultAcumen' then
            local waist = nuke_waist_bonus(spell, spellMap)
            if waist then
                equip({waist = waist})
            end
            -- nil -> keep the set's neutral waist: Sacro Cord (Normal sets) / Null Belt (Resistant).
        end

        -- (restored from BLM.lua) Mana Wall midcast overlay in DT/Tank idle modes
        if state.Buff['Mana Wall'] and ((state.IdleMode.value:contains('DT') or state.IdleMode.value:contains('Tank')) and in_combat) then
            equip(sets.buff['Mana Wall'])
        end
    end
end

-- Function to customize idle sets based on porter moogle proximity
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

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    set_macro_page(1, 4)
end