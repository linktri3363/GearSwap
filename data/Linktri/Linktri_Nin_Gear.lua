near_porter = false

-- LINKTRI (2026-10-20) NIN audit notes:
--   * Rare items (one copy per character) never sit in both ear or both ring slots of one set.
--   * Fixed sides to avoid "Failed to equip" mirror swaps:
--       ear1 = Odr / Mache +1 / Moonshade / Lugra / Etiolation / Crematio / Psystorm / Gwati / Genmei / Trux / Suppanomimi / Dudgeon / Crep.
--       ear2 = Hattori Earring +1 (its Physical damage limit +8% is RIGHT EAR ONLY) / Telos / Alabaster / Sanare / Loquac. / Hecate's / Dedition / Ishvara / Heartseeker
--       ring2 = Ephramad's / Epona's / Murky / Metamor. +1 / Kishar (Gere, Ilabrat, Defending, Dingir, Chirich: ring1)
--   * Lugra Earring only works dusk to dawn; NIN.lua swaps in sets.DayWSEars / DayMaxTPWSEars by day.
--   * Stored (unpack with PorterPacker): Loquac. Earring, Naegling, Tauret.
--   * Brutal Earring dropped: Hattori Earring +1, Telos, Dedition and Odr cover every slot it was in.
--   * Items replaced keep an "original:" comment.

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_job_setup()
    state.OffenseMode:options("Normal", "SomeAcc", "Acc", "FullAcc", "Fodder", "Crit")
    state.HybridMode:options("Normal", "DT")
    state.RangedMode:options("Normal", "Acc")
    state.WeaponskillMode:options("Match", "Normal", "SomeAcc", "Acc", "FullAcc", "Fodder", "Proc")
    state.CastingMode:options("Normal", "Proc", "Resistant")
    state.IdleMode:options("Normal", "Sphere")
    state.PhysicalDefenseMode:options("PDT")
    state.MagicalDefenseMode:options("MDT")
    state.ResistDefenseMode:options("MEVA")
    -- LINKTRI (2026-10-20): proc weapons commented out (none owned right now); add them back to this list later
    state.Weapons:options(
        "Heishi",
        "Savage",
        "MagicWeapons"
        -- "ProcDagger",
        -- "ProcSword",
        -- "ProcGreatSword",
        -- "ProcScythe",
        -- "ProcPolearm",
        -- "ProcGreatKatana",
        -- "ProcKatana",
        -- "ProcClub",
        -- "ProcStaff"
    )
    state.ExtraMeleeMode = M {["description"] = "Extra Melee Mode", "None", "SuppaBrutal", "DWEarrings", "DWMax"}

    -- LINKTRI MODIFICATION 2026-06-11: Andartia's Mantle not owned (it is the NIN-only JSE Ambuscade cape,
    -- so Senuna's Mantle (DNC-only) and Lugh's Cape (SCH-only) cannot substitute - neither is NIN-equippable).
    -- To revert: swap names/augments back to Andartia's Mantle as originally defined.
    -- LINKTRI (2026-10-20): weapon skill back -> Sacro Mantle (WSD+6, DEX+25, Acc/Atk+20), same as THF.
    --   original: gear.wsd_jse_back = "Null Shawl"
    gear.wsd_jse_back = "Sacro Mantle"
    gear.da_jse_back = "Null Shawl"

    send_command('bind ^` input /ja "Innin" <me>')
    send_command('bind !` input /ja "Yonin" <me>')
    send_command("bind @` gs c cycle SkillchainMode")
    send_command("bind !r gs c set WeaponskillMode Proc;;gs c set CastingMode Proc;gs c update")
    send_command("bind ^r gs c weapons Default;gs c set WeaponskillMode Normal;gs c set CastingMode Normal;gs c update")

    utsusemi_cancel_delay = .3
    utsusemi_ni_cancel_delay = .06

    select_default_macro_book()
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Precast sets
    --------------------------------------

    sets.Enmity = {
        ammo = "Yamarang",                  -- original: Paeapua (NIN can't equip)
        head = "Dampening Tam",
        neck = "Unmoving Collar",           -- Enmity+9
        ear1 = "Trux Earring",              -- Enmity+5  -- original: Crematio Earring
        ear2 = "Alabaster Earring",         -- original: Enervating Earring (Enmity-3)
        body = "Ashera Harness",
        hands = "Malignance Gloves",
        ring1 = "Petrov Ring",              -- Enmity+4
        ring2 = "Vengeful Ring",            -- Enmity+3
        back = "Null Shawl",
        waist = "Chaac Belt",
        legs = "Nyame Flanchard",
        feet = "Mochi. Kyahan +3"           -- Enmity+8  -- original: Malignance Boots
    }

    -- Precast sets to enhance JAs
    -- LINKTRI MODIFICATION 2026-06-27: Full Mochizuki +3 and Hachiya +1 sets confirmed owned.
    -- Mijin Gakure: Mochi. Hakama +3 20x bonus enhances Mijin Gakure effect.
    sets.precast.JA["Mijin Gakure"] = {legs = "Mochi. Hakama +3"} --main="Nagi" if obtained
    sets.precast.JA["Futae"] = {hands = "Hattori Tekko +3"}
    -- LINKTRI MODIFICATION 2026-06-27: Mochi. Chainmail +3 20x bonus enhances Sange effect.
    sets.precast.JA["Sange"] = {body = "Mochi. Chainmail +3"}
    sets.precast.JA["Provoke"] = sets.Enmity
    sets.precast.JA["Warcry"] = sets.Enmity

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {
        ammo = "Yamarang",
        head = "Mummu Bonnet +2",
        neck = "Unmoving Collar",
        ear1 = "Mache Earring +1",          -- original: ear1 Enchntr. Earring +1 (not owned), ear2 Mache Earring +1
        ear2 = "Alabaster Earring",
        body = gear.herculean_waltz_body,
        hands = gear.herculean_waltz_hands,
        ring1 = "Defending Ring",
        ring2 = "Ephramad's Ring",
        back = "Null Shawl",
        waist = "Chaac Belt",
        legs = "Dashing Subligar",
        feet = "Mochi. Kyahan +3"           -- CHR+39  -- original: gear.herculean_waltz_feet (Herculean Boots not owned)
    }

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz["Healing Waltz"] = {}

    -- Set for acc on steps, since Yonin drops acc a fair bit
    sets.precast.Step = {
        ammo = "Yamarang",
        head = "Dampening Tam",
        neck = "Combatant's Torque",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = "Mummu Jacket +2",
        hands = "Adhemar Wrist. +1",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Mummu Kecks +2",
        feet = "Malignance Boots"
    }

    sets.precast.Flourish1 = {
        ammo = "Yamarang",
        head = "Dampening Tam",
        neck = "Combatant's Torque",
        ear1 = "Psystorm Earring",          -- Magic Accuracy+12  -- original: Gwati Earring (+8)
        ear2 = { name="Hattori Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','"Store TP"+5',}}, -- original: Digni. Earring (not owned)
        body = "Ashera Harness",
        hands = "Adhemar Wrist. +1",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Hattori Hakama +3",
        feet = "Malignance Boots"
    }

    -- Fast cast sets for spells

    sets.precast.FC = {
        ammo = "Impatiens",
        head = "Hattori Zukin +3",          -- original: gear.herculean_fc_head (Herculean Helm not owned; no owned FC head)
        neck = "Voltsurge Torque",
        ear1 = "Etiolation Earring",        -- FC+1  -- original: Enchntr. Earring +1 (not owned)
        ear2 = "Loquac. Earring",           -- (stored)
        body = "Dread Jupon",
        hands = "Sombra Mittens",           -- FC+3  -- original: Chironic Gloves (NIN can't equip)
        ring1 = "Lebeche Ring",
        ring2 = "Kishar Ring",
        legs = "Rawhide Trousers",
        feet = "Hachi. Kyahan +1"
    }

    -- LINKTRI: Mochi. Chainmail +3 ("Utsusemi" spellcasting time -14%) must be worn at PRECAST to shorten the cast.
    --   original: body = "Dread Jupon", feet = "Hattori Kyahan +3" here, Mochi. Chainmail +3 only in midcast (no effect there).
    --   Hattori Kyahan +3 (Utsusemi +1) stays in midcast, where the extra shadow is applied.
    sets.precast.FC.Utsusemi =
        set_combine(sets.precast.FC, {neck = "Magoraga Beads", body = "Mochi. Chainmail +3"})
    -- original: also ring1 = "Kishar Ring" (Rare, already in ring2)
    sets.precast.FC.Shadows =
        set_combine(sets.precast.FC.Utsusemi, {ammo = "Staunch Tathlum +1"})

    -- Snapshot for ranged
    sets.precast.RA = {}
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        ammo = "Voluspa Tathlum",
        head={ name="Nyame Helm", augments={'Path: B',}},
        neck = "Combatant's Torque",
        ear1 = "Odr Earring",               -- original: Sherida Earring (NIN can't equip)
        ear2 = { name="Hattori Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','"Store TP"+5',}}, -- PDL+8%  -- original: Brutal Earring
        body={ name="Nyame Mail", augments={'Path: B',}},
        hands={ name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = "Ilabrat Ring",
        ring2 = "Apate Ring",
        back = gear.da_jse_back,
        waist = { name="Sailfi Belt +1", augments={'Path: A',}},
        legs={ name="Nyame Flanchard", augments={'Path: B',}},
        feet = "Hattori Kyahan +3",
    }
    sets.precast.WS.SomeAcc =
        set_combine(
        sets.precast.WS,
        {head = "Dampening Tam", body = { name="Mpaca's Doublet", augments={'Path: A',}}, legs = "Hiza. Hizayoroi +2", ear2 = "Telos Earring"}
    )
    sets.precast.WS.Acc =
        set_combine(
        sets.precast.WS,
        {
            ammo = "Voluspa Tathlum",
            head = "Ynglinga Sallet",
            neck = "Combatant's Torque",
            ear2 = "Telos Earring",
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            hands = "Mummu Wrists +2",
            waist = "Chaac Belt",
            legs = "Hiza. Hizayoroi +2",
            feet = "Malignance Boots"
        }
    )
    sets.precast.WS.FullAcc =
        set_combine(
        sets.precast.WS,
        {
            ammo = "Voluspa Tathlum",
            head = "Ynglinga Sallet",
            neck = "Combatant's Torque",
            ear1 = "Mache Earring +1",
            ear2 = "Telos Earring",
            body = "Mummu Jacket +2",
            ring1 = "Chirich Ring +1",
            ring2 = "Chirich Ring +1",
            waist = "Chaac Belt",
            legs = "Hiza. Hizayoroi +2",
            feet = "Malignance Boots"
        }
    )
    sets.precast.WS.Proc = {
        ammo = "Yamarang",
        head = "Ynglinga Sallet",
        neck = "Combatant's Torque",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = "Mummu Jacket +2",
        hands = "Mummu Wrists +2",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Mummu Kecks +2",
        feet = "Malignance Boots"
    }

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    -- LINKTRI: Blade: Jin is a critical-hit weapon skill -> Mpaca's Gloves (crit +5%)
    --   original hands: Hachiya Tekko +1 (no Jin stats) in every Jin set
    sets.precast.WS["Blade: Jin"] =
        set_combine(
        sets.precast.WS,
        {
            ammo = "Voluspa Tathlum",
            head = "Mummu Bonnet +2",
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            hands = { name="Mpaca's Gloves", augments={'Path: A',}},
            ring1 = "Ilabrat Ring",
            waist = "Chaac Belt",
            legs = "Mummu Kecks +2",
            feet = "Mummu Gamash. +2"
        }
    )
    sets.precast.WS["Blade: Jin"].SomeAcc =
        set_combine(
        sets.precast.WS.SomeAcc,
        {
            ammo = "Voluspa Tathlum",
            head = "Mummu Bonnet +2",
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            hands = { name="Mpaca's Gloves", augments={'Path: A',}},
            waist = "Chaac Belt",
            legs = "Mummu Kecks +2",
            feet = "Mummu Gamash. +2"
        }
    )
    sets.precast.WS["Blade: Jin"].Acc =
        set_combine(
        sets.precast.WS.Acc,
        {
            head = "Mummu Bonnet +2",
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            hands = { name="Mpaca's Gloves", augments={'Path: A',}},
            legs = "Mummu Kecks +2",
            feet = "Mummu Gamash. +2"
        }
    )
    sets.precast.WS["Blade: Jin"].FullAcc =
        set_combine(
        sets.precast.WS.FullAcc,
        {body = "Mummu Jacket +2", hands = { name="Mpaca's Gloves", augments={'Path: A',}}, legs = "Mummu Kecks +2", feet = "Mummu Gamash. +2"}
    )
    sets.precast.WS["Blade: Jin"].Fodder = set_combine(sets.precast.WS["Blade: Jin"], {head = "Mummu Bonnet +2"})

    -- LINKTRI: Blade: Hi (single hit, crit rate varies with TP):
    --   body Hattori Ningi +3 (crit +8%)  -- original: Mpaca's Doublet
    --   hands Mpaca's Gloves (crit +5%)  -- original: Hachiya Tekko +1
    --   legs Mochi. Hakama +3 (WSD+10)  -- original: Hiza. Hizayoroi +2 (WSD+7)
    --   ear2 Hattori Earring +1 (PDL+8%)  -- original: Brutal Earring (Enervating in SomeAcc)
    sets.precast.WS["Blade: Hi"] =
        set_combine(
        sets.precast.WS,
        {
            ammo = "Voluspa Tathlum",
            head = "Mummu Bonnet +2",
            ear1 = "Moonshade Earring",
            body = "Hattori Ningi +3",
            hands = { name="Mpaca's Gloves", augments={'Path: A',}},
            ring1 = "Ilabrat Ring",
            back = gear.wsd_jse_back,
            legs = "Mochi. Hakama +3",
            feet = "Mummu Gamash. +2"
        }
    )
    sets.precast.WS["Blade: Hi"].SomeAcc =
        set_combine(
        sets.precast.WS.SomeAcc,
        {
            ammo = "Voluspa Tathlum",
            head = "Mummu Bonnet +2",
            ear1 = "Moonshade Earring",
            ear2 = "Telos Earring",
            body = "Hattori Ningi +3",
            hands = { name="Mpaca's Gloves", augments={'Path: A',}},
            ring1 = "Ilabrat Ring",
            back = gear.wsd_jse_back,
            legs = "Mochi. Hakama +3",
            feet = "Mummu Gamash. +2"
        }
    )
    sets.precast.WS["Blade: Hi"].Acc =
        set_combine(
        sets.precast.WS.Acc,
        {
            head = "Mummu Bonnet +2",
            ear1 = "Moonshade Earring",
            ear2 = "Telos Earring",
            body = "Hattori Ningi +3",
            hands = { name="Mpaca's Gloves", augments={'Path: A',}},
            legs = "Mochi. Hakama +3",
            feet = "Mummu Gamash. +2"
        }
    )
    sets.precast.WS["Blade: Hi"].FullAcc =
        set_combine(sets.precast.WS.FullAcc, {hands = { name="Mpaca's Gloves", augments={'Path: A',}}, legs = "Hiza. Hizayoroi +2"})
    sets.precast.WS["Blade: Hi"].Fodder = set_combine(sets.precast.WS["Blade: Hi"], {})

    -- LINKTRI: Lugra Earring (night STR/DEX+7) ear1 + Hattori Earring +1 ear2.
    --   original: Lugra Earring in BOTH ears (Rare, only one owned). By day NIN.lua swaps in sets.DayWSEars.
    sets.precast.WS["Blade: Shun"] =
        set_combine(
        sets.precast.WS,
        {
            ammo = "Voluspa Tathlum",
            head = { name="Mpaca's Cap", augments={'Path: A',}},
            ear1 = "Lugra Earring",
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            legs = "Hiza. Hizayoroi +2",
            feet = { name="Mpaca's Boots", augments={'Path: A',}},
        }
    )
    sets.precast.WS["Blade: Shun"].SomeAcc =
        set_combine(
        sets.precast.WS.SomeAcc,
        {
            ammo = "Voluspa Tathlum",
            head = { name="Mpaca's Cap", augments={'Path: A',}},
            ear1 = "Lugra Earring",
            ear2 = { name="Hattori Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','"Store TP"+5',}},
            body = { name="Mpaca's Doublet", augments={'Path: A',}},
            legs = "Hiza. Hizayoroi +2",
            feet = "Malignance Boots"
        }
    )
    sets.precast.WS["Blade: Shun"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Blade: Shun"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Blade: Shun"].Fodder = set_combine(sets.precast.WS["Blade: Shun"], {
        head = { name="Mpaca's Cap", augments={'Path: A',}},
        body = { name="Mpaca's Doublet", augments={'Path: A',}},
    })

    -- LINKTRI: Blade: Ten (single hit, STR, WSD):
    --   body Nyame Mail (base set)  -- original: gear.herculean_wsd_body (augments not owned)
    --   feet Hattori Kyahan +3 (WSD+12, base set)  -- original: gear.herculean_wsd_feet (Herculean Boots not owned)
    --   legs Mochi. Hakama +3 (WSD+10)  -- original: Hiza. Hizayoroi +2 (WSD+7)
    --   ear2 Hattori Earring +1 (PDL+8%)  -- original: Lugra Earring
    --   waist Sailfi Belt +1 (base set)  -- original: Chaac Belt
    sets.precast.WS["Blade: Ten"] =
        set_combine(
        sets.precast.WS,
        {
            ammo = "Voluspa Tathlum",
            neck = "Combatant's Torque",
            ear1 = "Moonshade Earring",
            back = gear.wsd_jse_back,
            legs = "Mochi. Hakama +3",
        }
    )
    sets.precast.WS["Blade: Ten"].SomeAcc =
        set_combine(
        sets.precast.WS.SomeAcc,
        {
            ammo = "Voluspa Tathlum",
            neck = "Combatant's Torque",
            ear1 = "Moonshade Earring",
            body = { name="Nyame Mail", augments={'Path: B',}},
            back = gear.wsd_jse_back,
            legs = "Mochi. Hakama +3",
            feet = "Hattori Kyahan +3"
        }
    )
    sets.precast.WS["Blade: Ten"].Acc = set_combine(sets.precast.WS.Acc, {back = gear.wsd_jse_back})
    sets.precast.WS["Blade: Ten"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS["Blade: Ten"].Fodder = set_combine(sets.precast.WS["Blade: Ten"], {})

    -- LINKTRI: Aeolian Edge is a magical weapon skill -> Magic Atk. Bonus gear
    --   original: Voluspa, Dampening Tam, Etiolation (ear2), Mpaca's Doublet, Adhemar Wrist. +1, Apate Ring,
    --   Chaac Belt, Malignance Boots
    sets.precast.WS["Aeolian Edge"] = {
        ammo = "Pemphredo Tathlum",
        head = "Mochi. Hatsuburi +3",       -- MAB+61
        neck = "Baetyl Pendant",
        ear1 = "Crematio Earring",
        ear2 = "Hecate's Earring",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = "Dingir Ring",              -- MAB+10
        ring2 = { name="Metamor. Ring +1", augments={'Path: A',}},
        back = "Null Shawl",
        waist = "Orpheus's Sash",
        legs = { name="Nyame Flanchard", augments={'Path: B',}},
        feet = { name="Nyame Sollerets", augments={'Path: B',}}
    }
    -- LINKTRI: legs Mochi. Hakama +3 (WSD+10), feet Hattori Kyahan +3 (WSD+12), rings Gere (STR+10) / Ephramad's (STR+10)
    --   original: Nyame Flanchard / Nyame Sollerets, Ilabrat Ring / Apate Ring
    sets.precast.WS["Savage Blade"] = {
        ammo = "Coiste Bodhar",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Null Loop",
        ear1 = { name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},
        ear2 = "Ishvara Earring",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = "Gere Ring",
        ring2 = "Ephramad's Ring",
        back = gear.wsd_jse_back,
        waist = { name="Sailfi Belt +1", augments={'Path: A',}},
        legs = "Mochi. Hakama +3",
        feet = "Hattori Kyahan +3",
    }
    sets.precast.WS["Savage Blade"].SomeAcc = set_combine(sets.precast.WS["Savage Blade"], {
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
    })
    sets.precast.WS["Savage Blade"].Acc = set_combine(sets.precast.WS["Savage Blade"], {
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
    })

    -- Swap to these on Moonshade using WS if at 3000 TP (Moonshade is always ear1)
    -- original: MaxTP = {ear1 = "Lugra Earring", ear2 = "Lugra Earring"} (Rare, only one owned)
    sets.MaxTP = {ear1 = "Lugra Earring"}
    sets.AccMaxTP = {ear1 = "Mache Earring +1", ear2 = "Telos Earring"}
    sets.AccDayMaxTPWSEars = {ear1 = "Mache Earring +1", ear2 = "Telos Earring"}
    sets.DayMaxTPWSEars = {ear1 = "Odr Earring"}           -- original: {ear1 = "Sherida Earring", ear2 = "Brutal Earring"}
    sets.AccDayWSEars = {ear1 = "Mache Earring +1", ear2 = "Telos Earring"}
    sets.DayWSEars = {ear1 = "Moonshade Earring"}          -- original: {ear1 = "Moonshade Earring", ear2 = "Brutal Earring"}

    --------------------------------------
    -- Midcast sets
    --------------------------------------

    sets.midcast.FastRecast = {
        head = "Hattori Zukin +3",          -- original: gear.herculean_fc_head (not owned)
        neck = "Voltsurge Torque",
        ear1 = "Etiolation Earring",        -- original: Enchntr. Earring +1 (not owned)
        ear2 = "Loquac. Earring",
        body = "Dread Jupon",
        hands = "Sombra Mittens",           -- original: Chironic Gloves (NIN can't equip)
        ring1 = "Defending Ring",
        ring2 = "Kishar Ring",
        legs = "Rawhide Trousers",
        feet = "Malignance Boots"
    }

    -- LINKTRI MODIFICATION 2026-06-27: Added Mochi. Hatsuburi +3 (NIN dmg+21) and Mochi. Kyahan +3
    -- (20x: increases Ninj. MAcc/MAB) to ElementalNinjutsu set. Hattori Tekko +3 retained for Futae+28.
    sets.midcast.ElementalNinjutsu = {
        ammo = "Pemphredo Tathlum",
        head = "Mochi. Hatsuburi +3",
        neck = "Baetyl Pendant",
        ear1 = "Crematio Earring",
        ear2 = "Hecate's Earring",          -- MAB+6  -- original: Etiolation Earring
        body = "Samnuha Coat",
        hands = "Hattori Tekko +3",
        ring1 = "Dingir Ring",              -- MAB+10  -- original: Apate Ring (no magic stats)
        ring2 = "Metamor. Ring +1",
        back = "Null Shawl",
        waist = "Orpheus's Sash",           -- original: Eschan Stone
        legs = "Gyve Trousers",
        feet = "Mochi. Kyahan +3"
    }

    sets.midcast.ElementalNinjutsu.Proc = sets.midcast.FastRecast

    sets.midcast.ElementalNinjutsu.Resistant = set_combine(sets.midcast.ElementalNinjutsu, {})

    -- LINKTRI: Nyame Flanchard (Magic burst damage +6); Hattori Tekko +3 (MB+15) is already in the nuke set.
    -- original: {ring1 = "Apate Ring", ring2 = "Metamor. Ring +1"} (no burst stats)
    sets.MagicBurst = {legs = { name="Nyame Flanchard", augments={'Path: B',}}}

    -- LINKTRI (2026-10-20): Magic Accuracy rebuild. original: Voluspa, Dampening Tam, Combatant's Torque, Gwati/Digni.,
    --   Ashera Harness, Hachiya Tekko +1, Stikini/Metamor., Chaac Belt, Rawhide Trousers, Mochi. Kyahan +3
    sets.midcast.NinjutsuDebuff = {
        ammo = "Yamarang",                  -- Magic Accuracy+15
        head = "Hattori Zukin +3",          -- Magic Accuracy+61
        neck = "Null Loop",                 -- Magic Accuracy+50
        ear1 = "Psystorm Earring",          -- Magic Accuracy+12
        ear2 = { name="Hattori Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','"Store TP"+5',}},
        body = "Hattori Ningi +3",          -- Magic Accuracy+64
        hands = "Hattori Tekko +3",         -- Magic Accuracy+62
        ring1 = "Stikini Ring",
        ring2 = "Metamor. Ring +1",
        back = gear.da_jse_back,            -- Null Shawl, Magic Accuracy+50
        waist = "Null Belt",                -- Magic Accuracy+30
        legs = "Hattori Hakama +3",         -- Magic Accuracy+63
        feet = "Mochi. Kyahan +3"           -- Ninjutsu skill+23
    }

    -- LINKTRI MODIFICATION 2026-06-27: Mochizuki Tekko +3 (NTE+38, 20x enhanced) in NinjutsuBuff hands.
    sets.midcast.NinjutsuBuff = set_combine(sets.midcast.FastRecast, {
        back = gear.da_jse_back,
        hands = { name="Mochizuki Tekko +3", augments={'Enh. "Ninja Tool Expertise" effect',}}
    })

    -- Hattori Kyahan +3: "Utsusemi"+1. original: also body = "Mochi. Chainmail +3" (casting time gear; moved to precast)
    sets.midcast.Utsusemi =
        set_combine(sets.midcast.NinjutsuBuff, {back = gear.da_jse_back, feet = "Hattori Kyahan +3"})

    sets.midcast.RA = {
        head = "Malignance Chapeau",
        neck = "Combatant's Torque",
        ear1 = "Crep. Earring",             -- original: Enervating Earring (moved off ear1)
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Ilabrat Ring",
        ring2 = "Apate Ring",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.midcast.RA.Acc = set_combine(sets.midcast.RA, {})

    --------------------------------------
    -- Idle/resting/defense/etc sets
    --------------------------------------

    -- Resting sets
    sets.resting = {}

    -- Idle sets
    sets.idle = {
        ammo = "Staunch Tathlum +1",
        head = "Hattori Zukin +3",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Hattori Ningi +3",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Hattori Hakama +3",
        feet = "Hattori Kyahan +3",         -- original: Hattori Kyahan (you have the +3)
    }

    sets.idle.Sphere = set_combine(sets.idle, {body = "Samnuha Coat"})

    -- original PDT: Yamarang, Dampening Tam (DT-4%), Ashera Harness (DT-7%), Chaac Belt
    sets.defense.PDT = {
        ammo = "Staunch Tathlum +1",
        head = "Hattori Zukin +3",          -- DT-10%
        neck = "Loricate Torque +1",
        ear1 = "Genmei Earring",
        ear2 = "Sanare Earring",
        body = "Hattori Ningi +3",          -- DT-13%
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Nyame Flanchard",
        feet = "Malignance Boots"
    }

    -- original MDT: same as PDT original plus ring2 Ice Ring (elemental magic skill)
    sets.defense.MDT = set_combine(sets.defense.PDT, {ear1 = "Etiolation Earring"})

    -- original MEVA: Yamarang, Dampening Tam, Sacro Gorget (NIN can't equip), Samnuha Coat/Tights, Chironic Gloves
    --   (NIN can't equip), Vengeful/Ice Ring, Chaac Belt, Malignance Boots
    sets.defense.MEVA = {
        ammo = "Staunch Tathlum +1",
        head = "Hattori Zukin +3",          -- MEVA+119
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Hattori Ningi +3",          -- MEVA+129
        hands = "Nyame Gauntlets",          -- MEVA+112
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Hattori Hakama +3",         -- MEVA+135
        feet = "Hattori Kyahan +3"          -- MEVA+135
    }

    -- LINKTRI: Hachi. Kyahan +1 only gives movement speed dusk to dawn; NIN.lua uses sets.DuskKiting at night.
    --   original: sets.Kiting = {feet = "Hachi. Kyahan +1"}, sets.DuskKiting = {}
    sets.Kiting = {ring2 = "Shneddick Ring +1"}
    sets.DuskKiting = {feet = "Hachi. Kyahan +1"}
    sets.DuskIdle = {}
    sets.DayIdle = {}
    sets.NightIdle = {}

    --------------------------------------
    -- Engaged sets
    --------------------------------------
    -- LINKTRI: Sherida Earring and Regal Belt (NIN can't equip) -> Odr Earring and Sailfi Belt +1;
    --   Brutal Earring -> Hattori Earring +1 / Dedition; Herculean Boots (not owned) -> Mpaca's Boots (TA+3%, DT-6%)

    -- Normal melee group
    sets.engaged = {
        ammo={ name="Coiste Bodhar", augments={'Path: A',}},
        head = "Dampening Tam",
        neck = "Null Loop",
        ear1 = "Odr Earring",
        ear2 ={ name="Hattori Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','"Store TP"+5',}},
        body={ name="Mpaca's Doublet", augments={'Path: A',}},
        hands = "Adhemar Wrist. +1",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Samnuha Tights",
        feet = { name="Mpaca's Boots", augments={'Path: A',}}  -- original: gear.herculean_ta_feet
    }

    sets.engaged.SomeAcc = {
        ammo = "Yamarang",
        head = "Dampening Tam",
        neck = "Combatant's Torque",
        ear1 = "Odr Earring",               -- original: Sherida Earring
        ear2 = { name="Hattori Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','"Store TP"+5',}}, -- original: Brutal Earring
        body = { name="Mpaca's Doublet", augments={'Path: A',}},
        hands = "Adhemar Wrist. +1",
        ring1 = "Ilabrat Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = { name="Sailfi Belt +1", augments={'Path: A',}},  -- original: Regal Belt
        legs = "Samnuha Tights",
        feet = { name="Mpaca's Boots", augments={'Path: A',}}    -- original: gear.herculean_ta_feet
    }

    sets.engaged.Acc = {
        ammo = "Yamarang",
        head = "Dampening Tam",
        neck = "Combatant's Torque",
        ear1 = "Odr Earring",               -- original: Digni. Earring (not owned)
        ear2 = "Telos Earring",
        body = { name="Mpaca's Doublet", augments={'Path: A',}},
        hands = "Adhemar Wrist. +1",
        ring1 = "Ilabrat Ring",
        ring2 = "Apate Ring",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Mummu Kecks +2",
        feet = "Malignance Boots"
    }

    sets.engaged.FullAcc = {
        ammo = "Yamarang",
        head = "Malignance Chapeau",
        neck = "Combatant's Torque",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.Fodder = {
        ammo = "Yamarang",
        head = "Dampening Tam",
        neck = "Combatant's Torque",
        ear1 = "Odr Earring",               -- original: ear1 Dedition Earring, ear2 Brutal Earring
        ear2 = "Dedition Earring",
        body = { name="Mpaca's Doublet", augments={'Path: A',}},
        hands = "Adhemar Wrist. +1",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = { name="Sailfi Belt +1", augments={'Path: A',}},  -- original: Regal Belt
        legs = "Samnuha Tights",
        feet = { name="Mpaca's Boots", augments={'Path: A',}}    -- original: gear.herculean_ta_feet
    }

    sets.engaged.Crit = {
        ammo = "Yamarang",
        head = "Mummu Bonnet +2",
        neck = "Combatant's Torque",
        ear1 = "Odr Earring",               -- crit +5%  -- original: Sherida Earring
        ear2 = { name="Hattori Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','"Store TP"+5',}}, -- original: Brutal Earring
        body = "Mummu Jacket +2",
        hands = "Mummu Wrists +2",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = { name="Sailfi Belt +1", augments={'Path: A',}},  -- original: Regal Belt
        legs = "Mummu Kecks +2",
        feet = "Mummu Gamash. +2"
    }

    sets.engaged.DT = {
        ammo = "Yamarang",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Odr Earring",               -- original: Sherida Earring
        ear2 = "Alabaster Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = { name="Sailfi Belt +1", augments={'Path: A',}},  -- original: Regal Belt
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.SomeAcc.DT = {
        ammo = "Yamarang",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Mache Earring +1",          -- original: Telos Earring (moved off ear1)
        ear2 = "Alabaster Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = { name="Sailfi Belt +1", augments={'Path: A',}},  -- original: Regal Belt
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.Acc.DT = {
        ammo = "Yamarang",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = { name="Sailfi Belt +1", augments={'Path: A',}},  -- original: Regal Belt
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.FullAcc.DT = {
        ammo = "Yamarang",
        head = "Malignance Chapeau",
        neck = "Loricate Torque +1",
        ear1 = "Mache Earring +1",
        ear2 = "Telos Earring",             -- original: Odr Earring (moved off ear2)
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Chirich Ring +1",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Malignance Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.Fodder.DT = set_combine(sets.engaged.DT, {}) -- was an exact copy of engaged.DT

    --------------------------------------
    -- Custom buff sets
    --------------------------------------

    sets.buff.Migawari = {body="Hattori Ningi +3"} --body="Hattori Ningi +3"
    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Futae = {}
    sets.buff.Yonin = {legs = "Hattori Hakama +3"} --
    sets.buff.Innin = {head="Hattori Zukin +3"} --head="Hattori Zukin +3"

    -- Extra Melee sets.  Apply these on top of melee sets.
    sets.Knockback = {}
    sets.SuppaBrutal = {ear1 = "Suppanomimi"} -- original: also ear2 = "Brutal Earring" (engaged ear2 Hattori Earring +1 stays)
    sets.DWEarrings = {ear1 = "Dudgeon Earring", ear2 = "Heartseeker Earring"}
    -- LINKTRI MODIFICATION 2026-06-27: Mochi. Chainmail +3 (DW+9) and Mochi. Hakama +3 (DW+10)
    -- replace Mpaca's Doublet in DWMax; Hachiya body (DW+8) is inferior to both Mochi. and Mpaca's.
    sets.DWMax = {
        ear1 = "Dudgeon Earring",
        ear2 = "Heartseeker Earring",
        body = "Mochi. Chainmail +3",
        hands = "Floral Gauntlets",
        legs = "Mochi. Hakama +3",
        waist = "Reiki Yotai"               -- Dual Wield+7  -- original: Chaac Belt (no Dual Wield)
    }
    sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
    sets.Skillchain = {legs = "Hattori Hakama +3"}

    -- Weapons sets
    sets.weapons.Heishi = {main = "Heishi Shorinken", sub = "Yagyu Darkblade"}
    sets.weapons.Savage = {main = "Naegling", sub = "Yagyu Darkblade"}
    sets.weapons.Evisceration = {main = "Tauret", sub = "Kunimitsu"}
    sets.weapons.MagicWeapons = {main = "Kunimitsu", sub = "Tauret"}
    -- LINKTRI (2026-10-20): proc weapons commented out (not owned right now); restore with the state.Weapons list
    -- sets.weapons.ProcDagger = {main = "Chicken Knife II", sub = empty}
    -- sets.weapons.ProcSword = {main = "Ark Sword", sub = empty}
    -- sets.weapons.ProcGreatSword = {main = "Lament", sub = empty}
    -- sets.weapons.ProcScythe = {main = "Ark Scythe", sub = empty}
    -- sets.weapons.ProcPolearm = {main = "Pitchfork +1", sub = empty}
    -- sets.weapons.ProcGreatKatana = {main = "Hardwood Katana", sub = empty}
    -- sets.weapons.ProcKatana = {main = "Kanaria", sub = empty}
    -- sets.weapons.ProcClub = {main = "Dream Bell +1", sub = empty}
    -- sets.weapons.ProcStaff = {main = "Terra's Staff", sub = empty}

    sets.packing = {
        ammo  = "Staunch Tathlum +1",
        head  = "Nyame Helm",
        neck  = "Loricate Torque +1",
        ear1  = "Etiolation Earring",
        ear2  = "Sanare Earring",
        body  = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = { name="Murky Ring", augments={'Path: A'}},
        back  = "Null Shawl",
        waist = "Isa Belt",                 -- original: Fucho-no-Obi (NIN can't equip)
        legs  = "Nyame Flanchard",
        feet  = "Nyame Sollerets"
    }
end

-- LINKTRI (2026-10-20): renamed from job_customize_idle_set. That name replaced NIN.lua's own version, which puts on
-- Hattori Ningi +3 (Migawari+16) while Migawari is up. NIN.lua's runs first now; this only adds the packing set.
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
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == "WAR" then
        set_macro_page(1, 13)
    elseif player.sub_job == "RNG" then
        set_macro_page(1, 13)
    elseif player.sub_job == "RDM" then
        set_macro_page(1, 13)
    else
        set_macro_page(1, 13)
    end
end
