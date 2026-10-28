function user_job_setup()
    -- Options: Override default values
    state.OffenseMode:options("Normal", "Acc", "FullAcc", "SubtleBlow", "Counter")
    state.WeaponskillMode:options("Match", "Normal", "Acc", "FullAcc")
    state.HybridMode:options("Normal", "PDT", "PDTOffense") -- LINKTRI MODIFICATION: added armor-capped PDT-offense hybrid; removed "Gleti" (Gleti's armor is not MNK-equippable)
    state.PhysicalDefenseMode:options("PDT")
    state.MagicalDefenseMode:options("MDT")
    state.ResistDefenseMode:options("MEVA")
    state.Weapons:options(
        "Prime",
		"Godhands",
        "Staff",
        "Barehanded"
        -- LINKTRI: proc weapons commented out (stored, rarely used on MNK). To restore, add back:
        -- "ProcStaff", "ProcClub", "ProcSword", "ProcGreatSword", "ProcScythe", "ProcPolearm", "ProcGreatKatana"
        -- and uncomment their sets.weapons entries below.
    )

    state.ExtraMeleeMode = M {["description"] = "Extra Melee Mode", "None"}

    -- Additional local binds
    send_command('bind ^` input /ja "Boost" <me>')
    send_command('bind !` input /ja "Perfect Counter" <me>')
    send_command('bind ^backspace input /ja "Mantra" <me>')
    send_command("bind @` gs c cycle SkillchainMode")

    -- LINKTRI: Hoxne Ampulla mode (ported from the DNC file). Toggle: //gs c hoxne, or Ctrl+Alt+H.
    state.HoxneMode = M(false, 'Hoxne Ampulla Mode')
    send_command('bind ^!h gs c hoxne')

    select_default_macro_book()
end

-- Function to customize idle sets based on current modes and conditions
-- LINKTRI: renamed from job_customize_idle_set, which replaced MNK.lua's version. MNK.lua's now runs
-- first (it applies the Boost/Ask Sash overlay), then this one.
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
    
    -- LINKTRI: Boost/Ask Sash overlay removed here - MNK.lua's job_customize_idle_set applies it.
    return idleSet
end

-- ======================================================================
-- LINKTRI MODIFICATION: Hoxne Ampulla mode (ported from the DNC file).
-- With the ampulla's enchantment active, Double Attack is already +100% from the ampulla alone, so
-- DA on gear is wasted - and every DA proc costs 1,000 gil. Triple Attack procs are free. While
-- the mode is on, melee sets swap their DA pieces for the best non-DA piece in the same slot:
--   ear1 Schere/Sherida Earring (DA+6/+5%) -> Odr Earring (DEX+10, Acc+10, Crit+5%)
--   ear2 Sherida Earring (DA+5%)           -> Hoxne Earring (all stats +15 at Mastery Rank 7)
--   ring2 Epona's Ring (DA+3/TA+3%)        -> Ephramad's Ring (STR/DEX+10, Acc/Atk+20, PDL+10%)
-- Ammo is handled by the toggle (ampulla equipped and the slot locked), so Coiste Bodhar drops off
-- on its own. None of the swapped pieces carry DT, so PDT/PDTOffense keep their DT totals.
-- Skipped in the SubtleBlow offense mode (Schere/Sherida carry its Subtle Blow) and in DefenseMode.
-- Kept on purpose: Segomo's Mantle (its STR+30/Acc/Atk still beat Sacro Mantle; only the DA is wasted).
-- REVERT: delete this block and the two HoxneMode lines in user_job_setup.
-- ======================================================================
local HOXNE_SWAPS = {
    {{'ear1', 'left_ear'},   {["Schere Earring"] = "Odr Earring", ["Sherida Earring"] = "Odr Earring"}},
    {{'ear2', 'right_ear'},  {["Sherida Earring"] = "Hoxne Earring"}},
    {{'ring2', 'right_ring'}, {["Epona's Ring"] = "Ephramad's Ring"}},
}

local function hoxne_name(item)
    if type(item) == 'table' then return item.name end
    return item
end

function user_job_customize_melee_set(meleeSet)
    if state.HoxneMode and state.HoxneMode.value and state.DefenseMode.value == 'None'
            and state.OffenseMode.value ~= 'SubtleBlow' then
        local swaps = {}
        for _,entry in ipairs(HOXNE_SWAPS) do
            local keys, map = entry[1], entry[2]
            for _,key in ipairs(keys) do
                local current = hoxne_name(meleeSet[key])
                if current and map[current] then
                    swaps[keys[1]] = map[current]
                end
            end
        end
        if next(swaps) then
            meleeSet = set_combine(meleeSet, swaps)
        end
    end
    return meleeSet
end

-- Game item data: the ampulla must be worn 5s before it can be used, with a 60s recast.
-- Polls the item's own ready flag once a second and uses it the moment it's ready. Deliberately
-- NOT Sel's useItem system: that moves the item to the satchel and unlocks the slot afterward,
-- which would drop the buff.
local HOXNE_MAX_TRIES = 15      -- 5s equip delay + margin for being mid-action

function hoxne_try_use(attempt)
    attempt = attempt or 1
    if not (state.HoxneMode and state.HoxneMode.value) then return end
    if player.equipment.ammo ~= "Hoxne Ampulla" then
        add_to_chat(123, 'Hoxne: ampulla is not equipped - not using it.')
        return
    end

    local item = get_usable_item("Hoxne Ampulla")
    if item and item.usable and not midaction() then
        windower.chat.input('/item "Hoxne Ampulla" <me>')
        add_to_chat(122, 'Hoxne: using Hoxne Ampulla (DA+100%, 1,000g per DA proc).')
    elseif attempt < HOXNE_MAX_TRIES then
        coroutine.schedule(function() hoxne_try_use(attempt + 1) end, 1)
    else
        add_to_chat(123, 'Hoxne: ampulla still not ready (recast is 60s). Use it manually or toggle Hoxne mode again.')
    end
end

-- Zoning drops the enchantment; re-use the ampulla once loaded in if Hoxne mode is still on.
function user_job_zone_change(new_id, old_id)
    if state.HoxneMode and state.HoxneMode.value then
        coroutine.schedule(function() hoxne_try_use(1) end, 8)
    end
end

-- //gs c hoxne: toggles the mode. Locks the ammo slot while active so gear swaps can never
-- unequip the ampulla (which would drop the DA+100% buff).
function user_job_self_command(commandArgs, eventArgs)
    if commandArgs[1] and commandArgs[1]:lower() == 'hoxne' then
        state.HoxneMode:toggle()
        if state.HoxneMode.value then
            enable('ammo')
            equip({ammo = "Hoxne Ampulla"})
            disable('ammo')
            add_to_chat(122, 'Hoxne Ampulla mode ON - ammo locked. Ampulla will be used automatically once ready (~5s), and again after zoning.')
            coroutine.schedule(function() hoxne_try_use(1) end, 1)
        else
            enable('ammo')
            add_to_chat(122, 'Hoxne Ampulla mode OFF - ammo slot unlocked.')
        end
        handle_equipping_gear(player.status)
        eventArgs.handled = true
    end
end

-- LINKTRI: removed this file's job_customize_melee_set. It replaced MNK.lua's and copied its logic
-- (Impetus body / Footwork feet outside FullAcc, Boost Ask Sash); MNK.lua's own version now runs.

function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Precast Sets

    -- Precast sets to enhance JAs on use
    sets.precast.JA["Hundred Fists"] = {legs = "Hesy. Hose +4"}
    sets.precast.JA["Boost"] = {hands = "Anch. Gloves +4", waist = "Ask Sash"}
    sets.precast.JA["Boost"].OutOfCombat = {hands = "Anch. Gloves +4", waist = "Ask Sash"}
    sets.precast.JA["Dodge"] = {feet = "Anch. Gaiters +4"}
    sets.precast.JA["Focus"] = {head = "Anchor. Crown +4"}
    sets.precast.JA["Counterstance"] = {feet = "Hesy. Gaiters +4"}
    sets.precast.JA["Footwork"] = {feet = "Bhikku Gaiters +3"}
    sets.precast.JA["Formless Strikes"] = {body = "Hesy. Cyclas +4"}
    sets.precast.JA["Mantra"] = {feet = "Hesy. Gaiters +4"}

    sets.precast.JA["Chi Blast"] = {}

    -- UPDATED: Better Chakra set with proper gear
    sets.precast.JA["Chakra"] = {
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Anch. Cyclas +4", -- LINKTRI MODIFICATION: fixed missing + (Chakra body was silently failing)
        hands = "Hesy. Gloves +4",
        ring1 = { name="Murky Ring", augments={'Path: A',}}, -- LINKTRI: moved from ring2 (Murky keeps ring1)
        ring2 = "Defending Ring",       -- LINKTRI: original: Gere Ring (STR/Atk/TA do nothing for Chakra); DT-10%
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Hesy. Hose +4",
        feet = "Anch. Gaiters +4"
    }

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz["Healing Waltz"] = {}

    sets.precast.Step = {
        ammo = "Voluspa Tathlum",         -- LINKTRI: original: "Coiste Bodhar". Acc+10/MAcc+15, STR/DEX+5
        head = "Malignance Chapeau",
        neck = "Null Loop",               -- LINKTRI: original: "Combatant's Torque". Acc/MAcc+50, DT-5%
        ear1 = "Telos Earring",
        ear2 = "Bhikku Earring +1", -- LINKTRI: Sortie earring, ear2 only (Acc+13/MAcc+13/STP+4)
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",              -- LINKTRI: original: { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}}. Acc/MAcc+50, DA+7%, STP+7
        waist = "Null Belt",              -- LINKTRI: original: "Eschan Stone". Acc/MAcc+30
        legs = "Hiza. Hizayoroi +2",
        feet = "Malignance Boots"
    }

    sets.precast.Flourish1 = {
        ammo = "Voluspa Tathlum",         -- LINKTRI: original: "Coiste Bodhar". Acc+10/MAcc+15, STR/DEX+5
        head = "Malignance Chapeau",
        neck = "Null Loop",               -- LINKTRI: original: "Combatant's Torque". Acc/MAcc+50, DT-5%
        ear1 = "Telos Earring",
        ear2 = "Bhikku Earring +1", -- LINKTRI: Sortie earring, ear2 only
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",              -- LINKTRI: original: { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}}. Acc/MAcc+50, DA+7%, STP+7
        waist = "Null Belt",              -- LINKTRI: original: "Eschan Stone". Acc/MAcc+30
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    -- Fast cast sets for spells

    -- LINKTRI: head removed (original: gear.herculean_fc_head - not owned; no owned MNK FC head).
    sets.precast.FC = {
        ammo = "Impatiens",
        neck = "Voltsurge Torque",
        ear1 = "Etiolation Earring",    -- LINKTRI: original: Enchntr. Earring +1 (not owned); FC+1
        ear2 = "Loquac. Earring",
        body = "Dread Jupon",
        hands = "Sombra Mittens",       -- LINKTRI: original: Malignance Gloves (no FC); FC+3
        ring1 = "Lebeche Ring",
        ring2 = "Naji's Loop",          -- LINKTRI: original: Kishar Ring (not MNK-equippable); FC+1
        legs = "Rawhide Trousers"
    }

    -- LINKTRI: Passion Jacket removed (not owned); body stays Dread Jupon (FC+7).
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck = "Magoraga Beads"})

    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        ammo = "Coiste Bodhar",
        head = "Mpaca's Cap",
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Hoxne Earring", -- LINKTRI: original: Sherida Earring. All stats +15 (Mastery Rank 7) over DA (first hit only)
        body = "Mpaca's Doublet",
        hands = "Bhikku Gloves +3",
        ring1 = "Gere Ring",
        ring2 = "Ephramad's Ring",       -- LINKTRI: original: Epona's Ring (DA/TA only on the first hit). STR+10, Acc/Atk+20, PDL+10% on every hit
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Mpaca's Hose",
        feet = "Bhikku Gaiters +3"
    }
    sets.precast.WSAcc = {
        ammo = "Coiste Bodhar",
        head = "Dampening Tam",
        neck = "Null Loop",               -- LINKTRI: original: "Combatant's Torque". Acc/MAcc+50, DT-5%
        ear1 = "Telos Earring",
        ear2 = "Bhikku Earring +1", -- LINKTRI: Sortie earring, ear2 only
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Null Belt",              -- LINKTRI: original: "Eschan Stone". Acc/MAcc+30
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }
    sets.precast.WSFullAcc = {
        ammo = "Voluspa Tathlum",         -- LINKTRI: original: "Coiste Bodhar". Acc+10/MAcc+15, STR/DEX+5
        head = "Malignance Chapeau",
        neck = "Null Loop",               -- LINKTRI: original: "Combatant's Torque". Acc/MAcc+50, DT-5%
        ear1 = "Telos Earring",
        ear2 = "Bhikku Earring +1", -- LINKTRI: Sortie earring, ear2 only
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",              -- LINKTRI: original: { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}}. Acc/MAcc+50, DA+7%, STP+7
        waist = "Null Belt",              -- LINKTRI: original: "Eschan Stone". Acc/MAcc+30
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }
    sets.precast.WS.Acc = set_combine(sets.precast.WS, sets.precast.WSAcc)
    sets.precast.WS.FullAcc = set_combine(sets.precast.WS, sets.precast.WSFullAcc)

    -- Specific weaponskill sets.

    -- OPTIMIZED: Raging Fists with Bhikku pieces for WSD+12% and PDL+10%
    sets.precast.WS["Raging Fists"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar", -- LINKTRI MODIFICATION: reverted Knobkierrie -- gear WSD% is FIRST-HIT-ONLY, weak on 5-hit Raging Fists; Coiste DA adds hits across all swings
        head = "Mpaca's Cap",
        neck = "Rep. Plat. Medal",
        ear1 = "Moonshade Earring",
        ear2 = "Hoxne Earring", -- LINKTRI: original: Schere Earring. All stats +15 (Mastery Rank 7): STR/DEX+15 on all 5 hits
        body = "Bhikku Cyclas +3",
        hands = "Bhikku Gloves +3",
        ring1 = "Gere Ring",
        ring2 = "Ephramad's Ring",       -- LINKTRI: original: Epona's Ring (DA/TA only on the first hit). STR+10, Acc/Atk+20, PDL+10% on every hit
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Thunder Belt", -- LINKTRI MODIFICATION: Raging Fists = Impaction; Thunder Belt +0.1 fTP replicates across all 5 hits
        legs = "Mpaca's Hose",
        feet = "Bhikku Gaiters +3"
    })
    
    -- OPTIMIZED: Howling Fist with Bhikku hands for VIT and PDL
    sets.precast.WS["Howling Fist"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar", -- LINKTRI MODIFICATION: reverted Knobkierrie (WSD first-hit-only); Coiste DA adds hits
        head = "Mpaca's Cap",
        neck = "Light Gorget", -- LINKTRI MODIFICATION: Howling Fist = Transfixion/Impaction; Light Gorget (Transfixion) +0.1 fTP replicates all hits
        ear1 = "Moonshade Earring",
        ear2 = "Hoxne Earring", -- LINKTRI: original: Schere Earring. All stats +15 (Mastery Rank 7): STR/VIT+15
        body = "Nyame Mail",
        hands = "Bhikku Gloves +3",
        ring1 = "Gere Ring",
        ring2 = "Ephramad's Ring",       -- LINKTRI: original: Epona's Ring (DA/TA only on the first hit). STR+10, Acc/Atk+20, PDL+10% on every hit
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Thunder Belt", -- LINKTRI MODIFICATION: Howling Fist is Impaction-aligned; elemental belt +0.1 fTP
        legs = "Mpaca's Hose",
        feet = "Mpaca's Boots"
    })
    
    -- OPTIMIZED: Asuran Fists - already using best pieces
    sets.precast.WS["Asuran Fists"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar", -- LINKTRI MODIFICATION: reverted Knobkierrie -- on 8-hit Asuran Fists, first-hit-only WSD+6% is ~+0.75%; Coiste DA adds hits across all 8 swings (Asuran cannot crit, so no crit ammo either)
        head = "Hes. Crown +4",
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Hoxne Earring", -- LINKTRI: original: Bhikku Earring +1 (H2H skill+11). All stats +15 (Mastery Rank 7): STR/VIT+15 on all 8 hits
        body = "Bhikku Cyclas +3",
        hands = "Bhikku Gloves +3",
        ring1 = "Gere Ring",
        ring2 = "Ephramad's Ring",       -- LINKTRI: original: Epona's Ring (DA/TA only on the first hit). STR+10, Acc/Atk+20, PDL+10% on every hit
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Mpaca's Hose",
        feet = "Bhikku Gaiters +3"
    })

    sets.precast.WS["Spinning Attack"] = set_combine(sets.precast.WS, {
        head = "Mpaca's Cap",
        neck = "Rep. Plat. Medal",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    })

    -- OPTIMIZED: Victory Smite with Anch hands for WSD+10%
    sets.precast.WS["Victory Smite"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar", -- LINKTRI MODIFICATION: Victory Smite CAN crit; Coiste DA adds crit-capable hits > Oshasha's first-hit-only WSD+3%
        head = "Mpaca's Cap",
        neck = "Light Gorget", -- LINKTRI MODIFICATION: Victory Smite = Light/Fragmentation (fTP-replicating); Light Gorget +0.1 fTP on EVERY hit
        ear1 = "Moonshade Earring", -- LINKTRI MODIFICATION: TP Bonus+250 (swapped out above 3200 TP via sets.MaxTP)
        ear2 = "Hoxne Earring", -- LINKTRI: original: Sherida Earring, then Odr Earring. STR+15 (80% STR mod); Odr now replaces Moonshade at capped TP
        body = "Mpaca's Doublet",
        hands = "Mpaca's Gloves",       -- LINKTRI: original: Anch. Gloves +4 (WSD+12%, first hit only). Crit rate+5%/TA+3% on every hit of a crit WS
        ring1 = "Gere Ring",
        ring2 = "Ephramad's Ring",       -- LINKTRI: original: Epona's Ring (DA/TA only on the first hit). STR+10, Acc/Atk+20, PDL+10% on every hit
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Light Belt", -- LINKTRI MODIFICATION: pairs with Light Gorget for +0.2 fTP total on Light WS
        legs = "Mpaca's Hose",
        feet = "Mpaca's Boots"
    })

    -- CRITICAL: Victory Smite with Impetus - Bhikku body for +45% crit damage
    sets.precast.WS["Victory Smite"].Impetus = set_combine(sets.precast.WS["Victory Smite"], {
        body = "Bhikku Cyclas +3"
    })

    -- OPTIMIZED: Shijin Spiral with Bhikku pieces for DEX and PDL
    sets.precast.WS["Shijin Spiral"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar", -- LINKTRI MODIFICATION: Shijin (5 hits, cannot crit); Coiste DA adds hits > first-hit-only WSD. NOTE: Mpaca's crit rate here is dead stat (Shijin can't crit) but its TA/Atk/PDL still count
        head = "Mpaca's Cap",
        neck = "Light Gorget", -- LINKTRI MODIFICATION: Shijin = Fusion/Reverberation; Fusion carries the Light element, so Light Gorget aligns & +0.1 fTP replicates all 5 hits
        ear1 = "Mache Earring +1",      -- LINKTRI: sides swapped so Sherida keeps ear2
        ear2 = "Hoxne Earring", -- LINKTRI: original: Sherida Earring. All stats +15 (Mastery Rank 7): DEX+15 on all 5 hits
        body = "Mpaca's Doublet",
        hands = "Bhikku Gloves +3",
        ring1 = "Gere Ring",
        ring2 = "Ephramad's Ring",       -- LINKTRI: original: Epona's Ring (DA/TA only on the first hit). STR+10, Acc/Atk+20, PDL+10% on every hit
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Light Belt", -- LINKTRI MODIFICATION: pairs with Light Gorget for +0.2 fTP on Fusion open
        legs = "Mpaca's Hose",
        feet = "Bhikku Gaiters +3"
    })

    sets.precast.WS["Tornado Kick"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar",
        head = "Mpaca's Cap",
        neck = "Mnk. Nodowa +2", -- LINKTRI MODIFICATION: kick WS -- Kick Attacks+25 directly boosts the kick hits; also PDL+10%/DEX+15 (beats Rep. Plat. Medal here)
        ear1 = "Moonshade Earring",
        ear2 = "Hoxne Earring", -- LINKTRI: original: Sherida Earring. All stats +15 (Mastery Rank 7): STR/VIT+15
        body = "Mpaca's Doublet",
        hands = "Bhikku Gloves +3",
        ring1 = "Gere Ring",
        ring2 = "Ephramad's Ring",       -- LINKTRI: original: Epona's Ring (DA/TA only on the first hit). STR+10, Acc/Atk+20, PDL+10% on every hit
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Thunder Belt", -- LINKTRI MODIFICATION: Tornado Kick = Impaction; Thunder Belt +0.1 fTP replicates across all hits
        legs = "Mpaca's Hose",
        feet = "Bhikku Gaiters +3"
    })

    -- LINKTRI MODIFICATION: Dragon Kick built out as a kick WS. Fragmentation SC property (Thunder Belt aligns
    -- via the Lightning element), fTP-replicating, TP-scaling fTP so it wants high TP + per-hit multipliers.
    -- Kick Attacks feet (Anch. Gaiters +4 Kick Atk +120) + Mnk. Nodowa +2 (Kick Attacks+25) drive the kick damage.
    sets.precast.WS["Dragon Kick"] = set_combine(sets.precast.WS, {
        ammo = "Coiste Bodhar",
        head = "Mpaca's Cap",
        neck = "Mnk. Nodowa +2",
        ear1 = "Moonshade Earring",
        ear2 = "Hoxne Earring", -- LINKTRI: original: Sherida Earring. All stats +15 (Mastery Rank 7): STR+15
        body = "Mpaca's Doublet",
        hands = "Bhikku Gloves +3",
        ring1 = "Gere Ring",
        ring2 = "Ephramad's Ring",       -- LINKTRI: original: Epona's Ring (DA/TA only on the first hit). STR+10, Acc/Atk+20, PDL+10% on every hit
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Thunder Belt",
        legs = "Mpaca's Hose",
        feet = "Anch. Gaiters +4" -- Kick Attacks attack +120 / Kick Attacks+10
    })

    -- OPTIMIZED: Final Heaven with Knobkierrie for WSD+10%
    sets.precast.WS["Final Heaven"] = set_combine(sets.precast.WS, {
        ammo = "Knobkierrie",
        head = "Mpaca's Cap",
        neck = "Rep. Plat. Medal",
        ear1 = "Ishvara Earring",       -- LINKTRI: sides swapped so Sherida keeps ear2
        ear2 = "Hoxne Earring", -- LINKTRI: original: Sherida Earring. All stats +15 (Mastery Rank 7): VIT+15 (80% VIT mod)
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Gere Ring",
        ring2 = "Ephramad's Ring",       -- LINKTRI: original: Epona's Ring (DA/TA only on the first hit). STR+10, Acc/Atk+20, PDL+10% on every hit
        back = "Sacro Mantle",          -- LINKTRI: original: Segomo's Mantle (DA cape). Final Heaven is one hit, so WSD+6% applies in full
        waist = "Eschan Stone",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    })

    -- Staff Weaponskills
    sets.precast.WS["Shell Crusher"] = {
        ammo = "Voluspa Tathlum",         -- LINKTRI: original: "Pemphredo Tathlum". Acc+10/MAcc+15, STR/DEX+5
        head = "Malignance Chapeau",
        neck = "Null Loop",               -- LINKTRI: original: "Rep. Plat. Medal". Acc/MAcc+50, DT-5%
        ear1 = "Telos Earring",         -- LINKTRI: original: "" (empty string equipped nothing)
        ear2 = "Bhikku Earring +1", -- LINKTRI: Sortie earring, ear2 only; original: Telos Earring
        body = "Bhikku Cyclas +3",
        hands = "Bhikku Gloves +3",
        ring1 = "Stikini Ring",
        ring2 = { name="Metamor. Ring +1", augments={'Path: A',}},
        back = "Null Shawl",              -- LINKTRI: original: { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}}. Acc/MAcc+50, DA+7%, STP+7
        waist = "Null Belt",              -- LINKTRI: original: "Eschan Stone". Acc/MAcc+30
        legs = "Bhikku Hose +3",
        feet = "Bhikku Gaiters +3"
    }

    sets.precast.WS["Cataclysm"] = {
        ammo = "Pemphredo Tathlum",
        head = "Nyame Helm",
        neck = "Sibyl Scarf",
        ear1 = "Crematio Earring",      -- LINKTRI: original: Etiolation Earring. MAB+6, Magic Damage+6, Staff skill+5
        ear2 = "Moonshade Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Gere Ring",            -- LINKTRI: original: Archon Ring (not owned); STR+10 for Cataclysm's STR mod
        ring2 = { name="Metamor. Ring +1", augments={'Path: A',}},
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    -- Midcast Sets
    sets.midcast.FastRecast = {}

    -- Specific spells
    sets.midcast.Utsusemi = {}

    -- Idle/resting/defense/etc. sets

    -- NEW: Idle set optimized
    sets.idle = {
        ammo = "Staunch Tathlum +1",
        head = "Null Masque",             -- LINKTRI: original: "Bhikku Crown +3". DT-10%, Regen+3, Refresh+1, Regain+2 (idle DT still ~80%)
        neck = "Bathy Choker +1",         -- LINKTRI: original: Loricate Torque +1 (DT-6%). Regen+3
        ear1 = { name="Alabaster Earring", augments={'Path: A',}},
        ear2 = "Hoxne Earring",           -- LINKTRI: reverted from Infused Earring (Regen+1); Hoxne gives all stats +15 at Mastery Rank 7
        body = "Hiza. Haramaki +2", -- LINKTRI MODIFICATION: Regen+12 vs Cyclas Regen+5; idle DT still capped
        hands = "Nyame Gauntlets",
        ring1 = "Chirich Ring +1",        -- LINKTRI: original: Murky Ring (DT-10%). Regen+2
        ring2 = "Chirich Ring +1",        -- LINKTRI: original: Defending Ring (DT-10%). Regen+2. Idle now DT-54%, Regen 26
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Null Belt",              -- LINKTRI: original: "Carrier's Sash". Regen+3, MEva+30
        legs = "Bhikku Hose +3",
        feet = "Bhikku Gaiters +3"
    }

    -- LINKTRI: Weakness set commented out (2026-10-17). Without it, Sel uses your normal idle set while weakened.
    -- To restore, uncomment the lines below; Sel-Include equips sets.idle.Weak automatically when it exists.
    -- sets.idle.Weak = sets.idle

    -- Defense sets
    sets.defense.PDT = {
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = { name="Alabaster Earring", augments={'Path: A',}},
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Bhikku Hose +3", -- LINKTRI MODIFICATION: fixed missing +3 (was silently failing)
        feet = "Nyame Sollerets"
    }

    sets.defense.MDT = {
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}}, -- LINKTRI: moved from ring2 (Murky keeps ring1)
        ring2 = "Defending Ring",       -- LINKTRI: original: Archon Ring (not owned); DT-10%
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.defense.MEVA = {
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}}, -- LINKTRI: moved from ring2 (Murky keeps ring1)
        ring2 = "Defending Ring",       -- LINKTRI: original: Archon Ring (not owned); DT-10%
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.Kiting = {ring1 = "Shneddick Ring +1"}

    -- Engaged sets

    -- OPTIMIZED: Normal melee set with Hesy hands and Bhikku feet
    sets.engaged = {
        ammo = "Coiste Bodhar",
        head = "Mpaca's Cap",             -- LINKTRI: original: "Dampening Tam". TA+3%, Crit+4%, Acc/Atk+40, STR+33, PDT-7% (Tam: Haste+7/SB+8/Acc+20 only)
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Hesy. Gloves +4",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Cornelia's Belt", -- LINKTRI MODIFICATION: Cornelia's Haste+10%/STR+10 // SWAP TO "Moonbow Belt +1" (DA+3%/STP) WHEN ACQUIRED
        legs = "Bhikku Hose +3",
        feet = "Bhikku Gaiters +3"
    }
    
    -- OPTIMIZED: Accuracy set
    sets.engaged.Acc = {
        ammo = "Coiste Bodhar",
        head = "Mpaca's Cap",             -- LINKTRI: original: "Dampening Tam". TA+3%, Crit+4%, Acc/Atk+40, STR+33, PDT-7% (Tam: Haste+7/SB+8/Acc+20 only)
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Hesy. Gloves +4",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Eschan Stone", -- LINKTRI MODIFICATION: Reiki Yotai DW is wasted on H2H; Eschan Stone gives Acc+15/Atk+15
        legs = "Bhikku Hose +3",
        feet = "Bhikku Gaiters +3"
    }
    
    sets.engaged.FullAcc = {
        ammo = "Voluspa Tathlum",         -- LINKTRI: original: "Coiste Bodhar". Acc+10/MAcc+15, STR/DEX+5
        head = "Malignance Chapeau",
        neck = "Null Loop",               -- LINKTRI: original: "Rep. Plat. Medal". Acc/MAcc+50, DT-5%
        ear1 = "Telos Earring",
        ear2 = "Bhikku Earring +1", -- LINKTRI: Sortie earring, ear2 only
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",              -- LINKTRI: original: { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}}. Acc/MAcc+50, DA+7%, STP+7
        waist = "Null Belt",              -- LINKTRI: original: "Eschan Stone". Acc/MAcc+30
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    -- NEW: Subtle Blow set for TP denial
    sets.engaged.SubtleBlow = {
        ammo = "Coiste Bodhar",
        head = "Bhikku Crown +3",
        neck = "Mnk. Nodowa +2",
        ear1 = "Sherida Earring",
        ear2 = "Bhikku Earring +1", -- LINKTRI: Sortie earring, ear2 only
        body = "Bhikku Cyclas +3",
        hands = "Anch. Gloves +4",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Moonbow Belt +1", -- LINKTRI: was "Moonbow Belt" (NQ). original: "Cornelia's Belt"
        legs = "Mpaca's Hose",
        feet = "Bhikku Gaiters +3"
    }

    -- OPTIMIZED: Counter set with Hesy body for Counter Crit+30%
    sets.engaged.Counter = {
        ammo = "Coiste Bodhar",
        head = "Hes. Crown +4",
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Hesy. Cyclas +4",
        hands = "Hizamaru Kote +2",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Cornelia's Belt", -- LINKTRI MODIFICATION: Haste+10%/STR+10/Counter+5, synergizes with Counter set (Reiki DW wasted on H2H)
        legs = "Anch. Hose +4",
        feet = "Hesy. Gaiters +4"
    }

    -- Defensive melee hybrid sets
    sets.engaged.PDT = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        neck = "Null Loop",               -- LINKTRI: original: "Loricate Torque +1". DT-5%, Acc/MAcc+50 (set was DT-62%, over the cap)
        ear1 = "Schere Earring",          -- LINKTRI: original: "Brutal Earring". DA+6%, STR+5
        ear2 = "Sherida Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Gere Ring",              -- LINKTRI: original: "Defending Ring". TA+5%, STR+10; set still DT-51%
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }
    
    sets.engaged.Acc.PDT = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        neck = "Null Loop",               -- LINKTRI: original: "Loricate Torque +1". DT-5%, Acc/MAcc+50; set DT-51%
        ear1 = "Sherida Earring",
        ear2 = "Bhikku Earring +1", -- LINKTRI: Sortie earring, ear2 only
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }
    
    sets.engaged.FullAcc.PDT = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        neck = "Null Loop",               -- LINKTRI: original: "Loricate Torque +1". DT-5%, Acc/MAcc+50; set DT-51%
        ear1 = "Telos Earring",
        ear2 = "Bhikku Earring +1", -- LINKTRI: Sortie earring, ear2 only
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Chirich Ring +1",
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    -- LINKTRI: Gleti hybrid removed - Gleti's armor is not MNK-equippable (THF/BST/DRG/BLU/DNC only),
    -- so body/hands/legs/feet never equipped. PDTOffense covers this role (DT-50% from armor).
    -- -- NEW: Gleti's hybrid set (Store TP+35 total!)
    -- sets.engaged.Gleti = {
    --     ammo = "Coiste Bodhar",
    --     head = "Malignance Chapeau",
    --     neck = "Rep. Plat. Medal",
    --     ear1 = "Schere Earring",
    --     ear2 = "Sherida Earring",
    --     body = "Gleti's Cuirass",
    --     hands = "Gleti's Gauntlets",
    --     ring1 = "Gere Ring",
    --     ring2 = "Epona's Ring",
    --     back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
    --     waist = "Reiki Yotai",
    --     legs = "Gleti's Breeches",
    --     feet = "Gleti's Boots"
    -- }

    -- LINKTRI MODIFICATION: PDT-offense hybrid. Armor alone caps physical DT at -50
    -- (Bhikku Crown+3 DT-11, Mpaca's Doublet PDT-10, Malig. Gloves DT-5, Bhikku Hose+3 DT-14,
    -- Bhikku Gaiters+3 DT-10), leaving rings/waist/back fully offensive. Higher DPS than full Malignance
    -- when the incoming threat is physical. Cycle via HybridMode if desired.
    sets.engaged.PDTOffense = {
        ammo = "Coiste Bodhar",
        head = "Bhikku Crown +3",
        neck = "Rep. Plat. Medal",
        ear1 = "Schere Earring",
        ear2 = "Sherida Earring",
        body = "Mpaca's Doublet",
        hands = "Malignance Gloves",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = { name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','System: 1 ID: 640 Val: 4',}},
        waist = "Cornelia's Belt",
        legs = "Bhikku Hose +3",
        feet = "Bhikku Gaiters +3"
    }

    -- Hundred Fists/Impetus melee set//g mods
    sets.engaged.HF = set_combine(sets.engaged, {})
    sets.engaged.Acc.HF = set_combine(sets.engaged.Acc, {})
    sets.engaged.FullAcc.HF = set_combine(sets.engaged.FullAcc, {})

    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    -- LINKTRI: sets.buff.Sleep removed (Frenzy Sallet not owned); Sel's sleep handling checks for owned wake-up items itself.
    sets.buff.Impetus = {body = "Bhikku Cyclas +3"}
    sets.buff.Footwork = {feet = "Bhikku Gaiters +3"}
    sets.buff.Boost = {waist = "Ask Sash"}

    sets.buff.FootworkWS = {feet = "Bhikku Gaiters +3"} -- LINKTRI: was sets.FootworkWS; MNK.lua looks for sets.buff.FootworkWS

    -- LINKTRI MODIFICATION: MaxTP sets — MNK.lua's job_post_precast swaps Moonshade out of a WS set
    -- when effective TP > 3200. Without these defined, that swap silently did nothing.
    sets.MaxTP = {ear1 = "Schere Earring"}
    -- LINKTRI: Bhikku Earring +1 is ear2-only, so AccMaxTP sets both ears (Schere replaces Moonshade).
    sets.AccMaxTP = {ear1 = "Schere Earring", ear2 = "Bhikku Earring +1"}
    -- (Raging Fists / Howling Fist now wear Hoxne in ear2, so the generic MaxTP's Schere in ear1 no longer
    -- duplicates; their dedicated MaxTP sets were removed.)
    -- Victory Smite at capped TP: Odr Earring (Crit+5%) replaces Moonshade, Hoxne stays in ear2.
    sets.MaxTP["Victory Smite"] = {ear1 = "Odr Earring"}
    -- LINKTRI: Cataclysm wears Moonshade in ear2; at capped TP swap it for another MAB earring.
    sets.MaxTP["Cataclysm"] = {ear2 = "Hecate's Earring"}
    sets.AccMaxTP["Cataclysm"] = {ear2 = "Hecate's Earring"}
    sets.DayIdle = {}
    sets.NightIdle = {}
    sets.Knockback = {}
    sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
    sets.Skillchain = {back = "Sacro Mantle"} -- LINKTRI: original: {legs = "Ryuo Hakama"} (not owned). Sacro Mantle: Skillchain Bonus+8

    -- Weapons sets
	sets.weapons.Prime = {main = "Varga Purnikawa", sub = empty}
	sets.weapons.Godhands = {main = "Godhands", sub = empty}
	sets.weapons.Barehanded = {main = empty, sub = empty}
	sets.weapons.Staff = {main = "Malignance Pole", sub = "Bloodrain Strap"}
	-- sets.weapons.ProcStaff = {main = "Terra's Staff", sub = empty}
	-- sets.weapons.ProcClub = {main = "Mafic Cudgel", sub = empty}
	-- sets.weapons.ProcSword = {main = "Ark Sword", sub = empty}
	-- sets.weapons.ProcGreatSword = {main = "Lament", sub = empty}
	-- sets.weapons.ProcScythe = {main = "Ark Scythe", sub = empty}
	-- sets.weapons.ProcPolearm = {main = "Pitchfork +1", sub = empty}
	-- sets.weapons.ProcGreatKatana = {main = "Hardwood Katana", sub = empty}
	
	    -- Packing set for Porter Moogle
    sets.packing = {
        -- LINKTRI MODIFICATION: removed main=""/sub="" (empty strings don't unequip; use 'empty' if ever needed)
        ammo = "Staunch Tathlum +1",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back = { name="Segomo's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Damage taken-5%',}},
        waist = "Carrier's Sash",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == "DNC" then
        set_macro_page(1, 2)
    elseif player.sub_job == "NIN" then
        set_macro_page(1, 2)
    elseif player.sub_job == "THF" then
        set_macro_page(1, 2)
    elseif player.sub_job == "RUN" then
        set_macro_page(1, 2)
    else
        set_macro_page(1, 2)
    end
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

-- Handle Boost buff to keep Ask Sash equipped
function job_buff_change(buff, gain)
    update_melee_groups() -- LINKTRI MODIFICATION: restore base MNK.lua behavior (Hundred Fists/AM melee groups)
    if buff == "Boost" then
        if gain then
            equip(sets.buff.Boost)
        else
            handle_equipping_gear(player.status)
        end
    end
end