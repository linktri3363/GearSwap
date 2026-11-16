near_porter = false

function user_job_setup()
    state.OffenseMode:options("Normal", "Acc", "FullAcc")
    state.HybridMode:options("Tank", "Tank_HP", "Normal", "DTLite")
    state.WeaponskillMode:options("Match", "Normal", "Acc", "FullAcc")
    state.CastingMode:options("SIRD", "Normal")
    state.PhysicalDefenseMode:options("PDT_HP", "PDT")
    state.MagicalDefenseMode:options("MDT_HP", "MDT")
    state.ResistDefenseMode:options("MEVA", "MEVA_HP")
    state.IdleMode:options("Tank", "KiteTank") --,'Normal','Sphere'
    state.Weapons:options("Zantetsuken", "Naegling", "None")  -- LINKTRI 2026-11-15: owned weapons; original: "None", "Aettir", "Lionheart", "DualWeapons"

    state.ExtraDefenseMode = M {["description"] = "Extra Defense Mode", "None", "MP"}

    -- LINKTRI 2026-11-15: no Ogma's capes owned; these stand in (original: three augmented Ogma's capes).
    gear.enmity_jse_back = "Fravashi Mantle"
    gear.stp_jse_back = "Null Shawl"
    gear.da_jse_back = "Null Shawl"

    -- Additional local binds
    send_command("bind !` gs c SubJobEnmity")
    send_command("bind @` gs c cycle RuneElement")
    send_command("bind ^` gs c RuneElement")
    send_command("bind @pause gs c toggle AutoRuneMode")
    send_command('bind ^delete input /ja "Provoke" <stnpc>')
    send_command('bind !delete input /ma "Cure IV" <stal>')
    send_command('bind @delete input /ma "Flash" <stnpc>')
    send_command('bind ^\\\\ input /ma "Protect IV" <t>')
    send_command('bind @\\\\ input /ma "Shell V" <t>')
    send_command('bind !\\\\ input /ma "Crusade" <me>')
    send_command('bind ^backspace input /ja "Lunge" <t>')
    send_command('bind @backspace input /ja "Gambit" <t>')
    send_command('bind !backspace input /ja "Rayke" <t>')
    send_command("bind @f8 gs c toggle AutoTankMode")
    send_command("bind @f10 gs c toggle TankAutoDefense")
    send_command("bind ^@!` gs c cycle SkillchainMode")
    send_command("bind !r gs c weapons Zantetsuken;gs c update")  -- LINKTRI 2026-11-15: was Lionheart (not owned)

    select_default_macro_book()
end

function init_gear_sets()
    -- LINKTRI REBUILD 2026-11-15: every set rebuilt from the Nov 14 RUN inventory export. The old sets were the template
    -- and used 83 items you don't own (Aettir/Lionheart/Epeolatry-era gear, Ogma's capes, Moonlight gear, etc.).
    -- Core: Erilaz +3 (empyrean, DT), Futhark +1/+3 (relic), Runeist +1 (AF), Nyame R25 B, Null pieces.
    -- Rings: Murky ring1 / Defending ring2 (DT), Pernicious ring1 / Supershear ring2 (enmity), Chirich +1 ring2.
    -- Earrings: Alabaster/Cryptic/Halasz/Etiolation/Telos/Moonshade/Mache +1/Crematio ear1;
    --           Odnowa +1/Trux/Erilaz +1 (right ear only)/Sherida/Odr/Tuisto/Hecate's ear2.
    -- DT cap is 50%: sets well past it use only Murky for DT and spend ring2 on something useful.

    --------------------------------------
    -- Enmity sets
    --------------------------------------

    -- Enmity about +52 (Unmoving 9, Cryptic 4, Trux 5, Pernicious 5, Supershear 5, Fravashi 6, Futhark Mitons 6,
    -- Eri. Leg Guards 13, Erilaz Greaves 8) plus Erilaz Surcoat's enmity retention.
    sets.Enmity = {
        ammo = "Staunch Tathlum +1",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Unmoving Collar",
        ear1 = "Cryptic Earring",
        ear2 = "Trux Earring",
        body = "Erilaz Surcoat +3",
        hands = "Futhark Mitons +3",
        ring1 = "Pernicious Ring",
        ring2 = "Supershear Ring",
        back = "Fravashi Mantle",
        waist = "Isa Belt",
        legs = "Eri. Leg Guards +3",
        feet = "Erilaz Greaves +3"
    }

    -- Enmity while capped on DT: Nyame 7, Ashera 7, Erilaz Gauntlets 11 / Leg Guards 13 / Greaves 11, Murky 10,
    -- Staunch 3, Isa 3 = DT-65%; enmity about +42.
    sets.Enmity.DT = {
        ammo = "Staunch Tathlum +1",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Unmoving Collar",
        ear1 = "Cryptic Earring",
        ear2 = "Trux Earring",
        body = "Ashera Harness",
        hands = "Erilaz Gauntlets +3",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Supershear Ring",
        back = "Fravashi Mantle",
        waist = "Isa Belt",
        legs = "Eri. Leg Guards +3",
        feet = "Erilaz Greaves +3"
    }

    -- Spell interruption: Erilaz Galea +3 20%, Staunch 11%, Rumination Sash 10%, Halasz 5%, Murky 3%.
    sets.Enmity.SIRD = set_combine(sets.Enmity.DT, {
        head = "Erilaz Galea +3",
        ear1 = "Halasz Earring",
        waist = "Rumination Sash"
    })

    --------------------------------------
    -- Precast sets
    --------------------------------------

    -- Job abilities (Runeist +1 AF, Futhark relic)
    sets.precast.JA["Vallation"] = set_combine(sets.Enmity, {body = "Runeist Coat +1", legs = "Futhark Trousers +3"})
    sets.precast.JA["Valiance"] = sets.precast.JA["Vallation"]
    sets.precast.JA["Pflug"] = set_combine(sets.Enmity, {feet = "Runeist Bottes +1"})
    sets.precast.JA["Battuta"] = set_combine(sets.Enmity, {head = "Fu. Bandeau +1"})
    sets.precast.JA["Liement"] = set_combine(sets.Enmity, {body = "Futhark Coat +1"})
    sets.precast.JA["Gambit"] = set_combine(sets.Enmity, {hands = "Runeist Mitons +1"})
    sets.precast.JA["Rayke"] = set_combine(sets.Enmity, {feet = "Futhark Boots +3"})
    sets.precast.JA["Elemental Sforzo"] = set_combine(sets.Enmity, {body = "Futhark Coat +1"})
    sets.precast.JA["Swordplay"] = set_combine(sets.Enmity, {hands = "Futhark Mitons +3"})
    sets.precast.JA["Embolden"] = set_combine(sets.Enmity, {})
    sets.precast.JA["One for All"] = set_combine(sets.Enmity, {})
    sets.precast.JA["Provoke"] = set_combine(sets.Enmity, {})
    sets.precast.JA["Warcry"] = set_combine(sets.Enmity, {})
    sets.precast.JA["Defender"] = set_combine(sets.Enmity, {})
    sets.precast.JA["Berserk"] = set_combine(sets.Enmity, {})
    sets.precast.JA["Last Resort"] = set_combine(sets.Enmity, {})
    sets.precast.JA["Aggressor"] = set_combine(sets.Enmity, {})
    sets.precast.JA["Animated Flourish"] = set_combine(sets.Enmity, {})

    sets.precast.JA["Vallation"].DT = set_combine(sets.Enmity.DT, {body = "Runeist Coat +1", legs = "Futhark Trousers +3"})
    sets.precast.JA["Valiance"].DT = sets.precast.JA["Vallation"].DT
    sets.precast.JA["Pflug"].DT = set_combine(sets.Enmity.DT, {feet = "Runeist Bottes +1"})
    sets.precast.JA["Battuta"].DT = set_combine(sets.Enmity.DT, {head = "Fu. Bandeau +1"})
    sets.precast.JA["Liement"].DT = set_combine(sets.Enmity.DT, {body = "Futhark Coat +1"})
    sets.precast.JA["Gambit"].DT = set_combine(sets.Enmity.DT, {hands = "Runeist Mitons +1"})
    sets.precast.JA["Rayke"].DT = set_combine(sets.Enmity.DT, {feet = "Futhark Boots +3"})
    sets.precast.JA["Elemental Sforzo"].DT = set_combine(sets.Enmity.DT, {body = "Futhark Coat +1"})
    sets.precast.JA["Swordplay"].DT = set_combine(sets.Enmity.DT, {hands = "Futhark Mitons +3"})
    sets.precast.JA["Embolden"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["One for All"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["Provoke"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["Warcry"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["Defender"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["Berserk"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["Last Resort"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["Aggressor"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["Animated Flourish"].DT = set_combine(sets.Enmity.DT, {})

    -- Lunge/Swipe: Nyame MAB+30 each, Baetyl, Crematio, Hecate's, Herculean Gloves (MAB-augmented pair),
    -- Metamor. Ring +1, Evasionist's Cape (MAB+10), Orpheus's Sash.
    sets.precast.JA["Lunge"] = {
        ammo = "Pemphredo Tathlum",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Baetyl Pendant",
        ear1 = "Crematio Earring",
        ear2 = "Hecate's Earring",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = { name="Herculean Gloves", augments={'Magic Damage +16','Crit.hit rate+1','Accuracy+18 Attack+18','Mag. Acc.+19 "Mag.Atk.Bns."+19',}},
        ring1 = "Metamor. Ring +1",
        ring2 = "Defending Ring",
        back = "Evasionist's Cape",
        waist = "Orpheus's Sash",
        legs = { name="Nyame Flanchard", augments={'Path: B',}},
        feet = { name="Nyame Sollerets", augments={'Path: B',}}
    }
    sets.precast.JA["Swipe"] = sets.precast.JA["Lunge"]

    -- Gear for specific elemental nukes.
    sets.element.Dark = {head = "Pixie Hairpin +1"}

    -- Vivacious Pulse: Erilaz Galea +3 augments it; divine/enhancing skill helps.
    sets.precast.JA["Vivacious Pulse"] = {
        head = "Erilaz Galea +3",
        ring1 = "Stikini Ring",
        legs = "Rune. Trousers +1"
    }
    sets.precast.JA["Vivacious Pulse"]["Ignis"] = set_combine(sets.precast.JA["Vivacious Pulse"], {})
    sets.precast.JA["Vivacious Pulse"]["Gelus"] = set_combine(sets.precast.JA["Vivacious Pulse"], {})
    sets.precast.JA["Vivacious Pulse"]["Flabra"] = set_combine(sets.precast.JA["Vivacious Pulse"], {})
    sets.precast.JA["Vivacious Pulse"]["Tellus"] = set_combine(sets.precast.JA["Vivacious Pulse"], {})
    sets.precast.JA["Vivacious Pulse"]["Sulpor"] = set_combine(sets.precast.JA["Vivacious Pulse"], {})
    sets.precast.JA["Vivacious Pulse"]["Unda"] = set_combine(sets.precast.JA["Vivacious Pulse"], {})
    sets.precast.JA["Vivacious Pulse"]["Lux"] = set_combine(sets.precast.JA["Vivacious Pulse"], {})
    sets.precast.JA["Vivacious Pulse"]["Tenebrae"] = set_combine(sets.precast.JA["Vivacious Pulse"], {})

    -- Waltz: Herculean Vest/Gloves (Waltz-augmented), Dashing Subligar, DT kept up.
    sets.precast.Waltz = {
        ammo = "Staunch Tathlum +1",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Unmoving Collar",
        ear1 = "Alabaster Earring",
        ear2 = "Odnowa Earring +1",
        body = { name="Herculean Vest", augments={'Attack+25','"Waltz" potency +8%','STR+9','Accuracy+8',}},
        hands = { name="Herculean Gloves", augments={'Attack+25','"Waltz" potency +9%','Accuracy+7',}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back = "Null Shawl",
        waist = "Isa Belt",
        legs = "Dashing Subligar",
        feet = "Erilaz Greaves +3"
    }
    sets.precast.Waltz["Healing Waltz"] = {}
    sets.precast.Step = {}
    sets.precast.Flourish1 = {}

    -- Fast cast: Erilaz Surcoat +3 13%, Rune. Bandeau +1 10%, Aya. Cosciales +2 6%, Baetyl 4%, Kishar 4%, Etiolation 1% = 38%.
    sets.precast.FC = {
        ammo = "Impatiens",
        head = "Rune. Bandeau +1",
        neck = "Baetyl Pendant",
        ear1 = "Etiolation Earring",
        ear2 = "Odnowa Earring +1",
        body = "Erilaz Surcoat +3",
        hands = "Erilaz Gauntlets +3",
        ring1 = "Kishar Ring",
        ring2 = "Defending Ring",
        back = "Fravashi Mantle",
        waist = "Isa Belt",
        legs = "Aya. Cosciales +2",
        feet = "Erilaz Greaves +3"
    }
    sets.precast.FC.DT = set_combine(sets.precast.FC, {ring1 = { name="Murky Ring", augments={'Path: A',}}, legs = "Eri. Leg Guards +3"})
    -- Enhancing: Futhark Trousers +3 (enhancing casting time -15%) and Siegel Sash (-8%).
    sets.precast.FC["Enhancing Magic"] = set_combine(sets.precast.FC, {waist = "Siegel Sash", legs = "Futhark Trousers +3"})
    sets.precast.FC["Enhancing Magic"].DT = set_combine(sets.precast.FC["Enhancing Magic"], {ring1 = { name="Murky Ring", augments={'Path: A',}}})
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck = "Magoraga Beads"})
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {})

    -- Weaponskill sets
    -- Multi-hit (Resolution): Double/Triple Attack and STR. Nyame head/body/feet carry DA+4~5% at R25 B.
    sets.precast.WS = {
        ammo = { name="Coiste Bodhar", augments={'Path: A',}},
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Anu Torque",
        ear1 = "Moonshade Earring",
        ear2 = "Sherida Earring",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = "Adhemar Wrist. +1",
        ring1 = "Epona's Ring",
        ring2 = "Ephramad's Ring",
        back = "Null Shawl",
        waist = { name="Sailfi Belt +1", augments={'Path: A',}},
        legs = "Samnuha Tights",
        feet = { name="Nyame Sollerets", augments={'Path: B',}}
    }
    sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {neck = "Null Loop"})
    sets.precast.WS.Acc = set_combine(sets.precast.WS.SomeAcc, {waist = "Null Belt"})
    sets.precast.WS.HighAcc = set_combine(sets.precast.WS.Acc, {head = "Erilaz Galea +3"})
    sets.precast.WS.FullAcc = set_combine(sets.precast.WS.HighAcc, {hands = "Erilaz Gauntlets +3", legs = "Eri. Leg Guards +3"})

    -- Two-hit / single-hit WSD set (Dimidiation, Savage Blade): Nyame WSD+10~12%, DEX/STR.
    sets.precast.WS.WSD = {
        ammo = "Knobkierrie",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Anu Torque",
        ear1 = "Moonshade Earring",
        ear2 = "Odr Earring",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = "Ilabrat Ring",
        ring2 = "Ephramad's Ring",
        back = "Null Shawl",
        waist = { name="Sailfi Belt +1", augments={'Path: A',}},
        legs = { name="Nyame Flanchard", augments={'Path: B',}},
        feet = { name="Nyame Sollerets", augments={'Path: B',}}
    }

    sets.precast.WS["Resolution"] = set_combine(sets.precast.WS, {})
    sets.precast.WS["Resolution"].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS["Resolution"].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS["Resolution"].HighAcc = set_combine(sets.precast.WS.HighAcc, {})
    sets.precast.WS["Resolution"].FullAcc = set_combine(sets.precast.WS.FullAcc, {})

    sets.precast.WS["Dimidiation"] = set_combine(sets.precast.WS.WSD, {})
    sets.precast.WS["Dimidiation"].SomeAcc = set_combine(sets.precast.WS.WSD, {neck = "Null Loop"})
    sets.precast.WS["Dimidiation"].Acc = set_combine(sets.precast.WS["Dimidiation"].SomeAcc, {waist = "Null Belt"})
    sets.precast.WS["Dimidiation"].HighAcc = set_combine(sets.precast.WS["Dimidiation"].Acc, {})
    sets.precast.WS["Dimidiation"].FullAcc = set_combine(sets.precast.WS["Dimidiation"].Acc, {head = "Erilaz Galea +3"})

    sets.precast.WS["Savage Blade"] = set_combine(sets.precast.WS.WSD, {})
    sets.precast.WS["Savage Blade"].SomeAcc = set_combine(sets.precast.WS["Dimidiation"].SomeAcc, {})
    sets.precast.WS["Savage Blade"].Acc = set_combine(sets.precast.WS["Dimidiation"].Acc, {})
    sets.precast.WS["Savage Blade"].HighAcc = set_combine(sets.precast.WS["Dimidiation"].HighAcc, {})
    sets.precast.WS["Savage Blade"].FullAcc = set_combine(sets.precast.WS["Dimidiation"].FullAcc, {})

    -- Swap to these on Moonshade using WS if at 3000 TP
    sets.MaxTP = {ear1 = "Ishvara Earring"}
    sets.AccMaxTP = {ear1 = "Mache Earring +1"}

    --------------------------------------
    -- Midcast sets
    --------------------------------------

    -- Fast recast while tanking: DT about -79% (Staunch 3, Nyame 7, Loricate 6, Alabaster 5, Erilaz hands/legs/feet 35,
    -- Murky 10, Defending 10, Isa 3) with Erilaz Surcoat +3 (FC+13%).
    sets.midcast.FastRecast = {
        ammo = "Staunch Tathlum +1",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",
        ear2 = "Odnowa Earring +1",
        body = "Erilaz Surcoat +3",
        hands = "Erilaz Gauntlets +3",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back = "Null Shawl",
        waist = "Isa Belt",
        legs = "Eri. Leg Guards +3",
        feet = "Erilaz Greaves +3"
    }
    sets.midcast.FastRecast.DT = set_combine(sets.midcast.FastRecast, {})
    -- SIRD: Erilaz Galea +3 20%, Staunch 11%, Rumination 10%, Halasz 5%, Murky 3%.
    sets.midcast.FastRecast.SIRD = set_combine(sets.midcast.FastRecast, {
        head = "Erilaz Galea +3",
        ear1 = "Halasz Earring",
        waist = "Rumination Sash"
    })

    -- Enhancing: Erilaz Galea +3 (duration+25%), Futhark Trousers +3 (duration+30%), Runeist Mitons +1 (skill+15),
    -- Andoaa (skill), Stikini.
    sets.midcast["Enhancing Magic"] = set_combine(sets.midcast.FastRecast, {
        head = "Erilaz Galea +3",
        ear1 = "Andoaa Earring",
        hands = "Runeist Mitons +1",
        ring1 = "Stikini Ring",
        legs = "Futhark Trousers +3"
    })
    sets.midcast["Enhancing Magic"].SIRD = set_combine(sets.midcast.FastRecast.SIRD, {legs = "Futhark Trousers +3"})

    -- Phalanx: Fu. Bandeau +1 (Phalanx received +5) plus enhancing skill. No Phalanx-augmented Herculean/Taeon owned.
    sets.midcast["Phalanx"] = set_combine(sets.midcast["Enhancing Magic"], {head = "Fu. Bandeau +1"})
    sets.midcast["Phalanx"].SIRD = set_combine(sets.midcast["Enhancing Magic"].SIRD, {hands = "Runeist Mitons +1"})

    sets.midcast["Regen"] = set_combine(sets.midcast["Enhancing Magic"], {head = "Rune. Bandeau +1", neck = "Sacro Gorget"})
    sets.midcast["Refresh"] = set_combine(sets.midcast["Enhancing Magic"], {head = "Erilaz Galea +3"})
    sets.midcast.Stoneskin = set_combine(sets.midcast["Enhancing Magic"], {waist = "Siegel Sash"})
    sets.midcast.Protect = set_combine(sets.midcast["Enhancing Magic"], {})
    sets.midcast.Shell = set_combine(sets.midcast["Enhancing Magic"], {})

    sets.midcast.Flash = set_combine(sets.Enmity, {})
    sets.midcast.Flash.DT = set_combine(sets.Enmity.DT, {})
    sets.midcast.Flash.SIRD = set_combine(sets.Enmity.SIRD, {})
    sets.midcast.Foil = set_combine(sets.Enmity, {})
    sets.midcast.Foil.DT = set_combine(sets.Enmity.DT, {})
    sets.midcast.Foil.SIRD = set_combine(sets.Enmity.SIRD, {})
    sets.midcast.Stun = set_combine(sets.Enmity, {})
    sets.midcast.Stun.DT = set_combine(sets.Enmity.DT, {})
    sets.midcast.Jettatura = set_combine(sets.Enmity, {})
    sets.midcast.Jettatura.DT = set_combine(sets.Enmity.DT, {})
    sets.midcast["Blue Magic"] = set_combine(sets.Enmity, {})
    sets.midcast["Blue Magic"].DT = set_combine(sets.Enmity.DT, {})
    sets.midcast["Blue Magic"].SIRD = set_combine(sets.Enmity.SIRD, {})

    -- Cures on yourself: no cure-potency gear owned for RUN, so DT + Sacro Gorget + Lebeche (Cure potency+3%).
    sets.midcast.Cure = set_combine(sets.midcast.FastRecast, {neck = "Sacro Gorget", ring1 = "Lebeche Ring"})
    sets.midcast["Wild Carrot"] = set_combine(sets.midcast.Cure, {})

    sets.Self_Healing = {}
    sets.Cure_Received = {}
    sets.Self_Refresh = {}
    sets.Phalanx_Received = {head = "Fu. Bandeau +1"}

    --------------------------------------
    -- Idle/resting/defense/etc sets
    --------------------------------------

    sets.resting = {}

    -- Idle: DT about -69% (Staunch 3, Null Masque 10, Loricate 6, Alabaster 5, Erilaz hands/legs/feet 35, Murky 10),
    -- Refresh (Runeist Coat +1 +2, Null Masque +1), Regen (Null Masque 3, Null Belt 3, Chirich 2), Regain+2.
    sets.idle = {
        ammo = "Staunch Tathlum +1",
        head = "Null Masque",
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",
        ear2 = "Erilaz Earring +1",
        body = "Runeist Coat +1",
        hands = "Erilaz Gauntlets +3",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Eri. Leg Guards +3",
        feet = "Erilaz Greaves +3"
    }

    sets.idle.Sphere = set_combine(sets.idle, {})

    -- Tank idle: Erilaz Surcoat +3 (4 Erilaz pieces for the absorb set bonus, enmity retention, damage to MP).
    sets.idle.Tank = set_combine(sets.idle, {body = "Erilaz Surcoat +3"})
    sets.idle.KiteTank = set_combine(sets.idle.Tank, {})

    sets.Kiting = {ring2 = "Shneddick Ring +1"}

    sets.latent_refresh = {waist = "Fucho-no-obi"}
    sets.latent_refresh_grip = {}
    sets.DayIdle = {}
    sets.NightIdle = {}

    -- Packing: nothing on the RUN PorterPacker list, and no weapons (so TP isn't lost near the Porter Moogle).
    sets.packing = {
        ammo  = "Staunch Tathlum +1",
        head  = "Null Masque",
        neck  = "Loricate Torque +1",
        ear1  = "Alabaster Earring",
        ear2  = "Odnowa Earring +1",
        body  = { name="Nyame Mail", augments={'Path: B',}},
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Defending Ring",
        back  = "Null Shawl",
        waist = "Null Belt",
        legs  = { name="Nyame Flanchard", augments={'Path: B',}},
        feet  = { name="Nyame Sollerets", augments={'Path: B',}}
    }

    -- Extra defense sets.  Apply these on top of melee or defense sets.
    sets.Knockback = {}
    sets.MP = {body = "Erilaz Surcoat +3"}
    sets.TreasureHunter = set_combine(sets.TreasureHunter, {})

    -- Weapons sets
    sets.weapons.Zantetsuken = {main = "Zantetsuken X", sub = "Utu Grip"}
    sets.weapons.Naegling = {main = "Naegling", sub = "Sors Shield"}

    -- Defense Sets
    -- PDT: DT about -78% (Staunch 3, Nyame Helm 7, Loricate 6, Alabaster 5, Nyame Mail 9, Erilaz hands/legs/feet 35,
    -- Murky 10, Isa 3). One DT ring (Murky); ring2 Chirich for Regen.
    sets.defense.PDT = {
        ammo = "Staunch Tathlum +1",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",
        ear2 = "Odnowa Earring +1",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = "Erilaz Gauntlets +3",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = "Isa Belt",
        legs = "Eri. Leg Guards +3",
        feet = "Erilaz Greaves +3"
    }
    -- HP versions: Adamantite Armor (HP+182, DT-20%), Tuisto Earring, Trepidity Mantle (HP+100).
    sets.defense.PDT_HP = set_combine(sets.defense.PDT, {body = "Adamantite Armor", ear2 = "Tuisto Earring", back = "Trepidity Mantle"})

    -- MDT: Runeist Coat +1 (resist all elements +33) with Erilaz Greaves +3 (all resistances +35); DT about -69%.
    sets.defense.MDT = set_combine(sets.defense.PDT, {body = "Runeist Coat +1"})
    sets.defense.MDT_HP = set_combine(sets.defense.MDT, {ear2 = "Tuisto Earring", back = "Trepidity Mantle"})

    -- MEVA: Nyame head/body/hands (more Magic Evasion than Erilaz), Erilaz legs/feet (157 each), Null Shawl/Belt,
    -- Erilaz Earring +1, Sanare. DT about -66%.
    sets.defense.MEVA = {
        ammo = "Staunch Tathlum +1",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Loricate Torque +1",
        ear1 = "Sanare Earring",
        ear2 = "Erilaz Earring +1",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = "Null Belt",
        legs = "Eri. Leg Guards +3",
        feet = "Erilaz Greaves +3"
    }
    sets.defense.MEVA_HP = set_combine(sets.defense.MEVA, {ear1 = "Alabaster Earring", back = "Trepidity Mantle"})

    --------------------------------------
    -- Engaged sets
    --------------------------------------

    -- Normal (damage): Ashera Harness (Store TP+10, DT-7%), Adhemar, Samnuha, Telos/Sherida, Epona's/Chirich,
    -- Null Shawl (DA+7%, Store TP+7), Erilaz Greaves +3 (Acc/Atk+60, DT-11%).
    sets.engaged = {
        ammo = { name="Coiste Bodhar", augments={'Path: A',}},
        head = "Dampening Tam",
        neck = "Anu Torque",
        ear1 = "Telos Earring",
        ear2 = "Sherida Earring",
        body = "Ashera Harness",
        hands = "Adhemar Wrist. +1",
        ring1 = "Epona's Ring",
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = { name="Sailfi Belt +1", augments={'Path: A',}},
        legs = "Samnuha Tights",
        feet = "Erilaz Greaves +3"
    }
    sets.engaged.Acc = set_combine(sets.engaged, {head = "Erilaz Galea +3", neck = "Null Loop", ear1 = "Mache Earring +1", waist = "Null Belt"})
    sets.engaged.FullAcc = set_combine(sets.engaged.Acc, {hands = "Erilaz Gauntlets +3", ring1 = "Chirich Ring +1", legs = "Eri. Leg Guards +3"})

    -- DTLite: Nyame Helm 7, Null Loop 5, Ashera 7, Erilaz hands/legs/feet 35, Murky 10 = DT-64%, still offensive.
    sets.engaged.DTLite = {
        ammo = { name="Coiste Bodhar", augments={'Path: A',}},
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Null Loop",
        ear1 = "Telos Earring",
        ear2 = "Sherida Earring",
        body = "Ashera Harness",
        hands = "Erilaz Gauntlets +3",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Chirich Ring +1",
        back = "Null Shawl",
        waist = { name="Sailfi Belt +1", augments={'Path: A',}},
        legs = "Eri. Leg Guards +3",
        feet = "Erilaz Greaves +3"
    }
    sets.engaged.Acc.DTLite = set_combine(sets.engaged.DTLite, {ear1 = "Mache Earring +1", waist = "Null Belt"})
    sets.engaged.FullAcc.DTLite = set_combine(sets.engaged.Acc.DTLite, {})

    -- Tank: DT about -69% with enmity retention (Erilaz Surcoat +3, 4-piece Erilaz absorb bonus) and Supershear (Enmity+5).
    sets.engaged.Tank = {
        ammo = "Staunch Tathlum +1",
        head = { name="Nyame Helm", augments={'Path: B',}},
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",
        ear2 = "Odnowa Earring +1",
        body = "Erilaz Surcoat +3",
        hands = "Erilaz Gauntlets +3",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Supershear Ring",
        back = "Null Shawl",
        waist = "Isa Belt",
        legs = "Eri. Leg Guards +3",
        feet = "Erilaz Greaves +3"
    }
    sets.engaged.Tank_HP = set_combine(sets.engaged.Tank, {body = "Adamantite Armor", ear2 = "Tuisto Earring", back = "Trepidity Mantle"})
    sets.engaged.Acc.Tank = sets.engaged.Tank
    sets.engaged.FullAcc.Tank = sets.engaged.Tank
    sets.engaged.Acc.Tank_HP = sets.engaged.Tank_HP
    sets.engaged.FullAcc.Tank_HP = sets.engaged.Tank_HP

    --------------------------------------
    -- Custom buff sets
    --------------------------------------
    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Sleep = {}
    sets.buff.Battuta = {}
    sets.buff.Embolden = {back = "Evasionist's Cape"}
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
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == "DNC" then
        set_macro_page(1, 22)
    elseif player.sub_job == "RDM" then
        set_macro_page(1, 22)
    elseif player.sub_job == "SCH" then
        set_macro_page(1, 22)
    elseif player.sub_job == "BLU" then
        set_macro_page(1, 22)
    elseif player.sub_job == "WAR" then
        set_macro_page(1, 22)
    elseif player.sub_job == "SAM" then
        set_macro_page(1, 22)
    elseif player.sub_job == "DRK" then
        set_macro_page(1, 22)
    elseif player.sub_job == "NIN" then
        set_macro_page(1, 22)
    else
        set_macro_page(1, 22)
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
                    windower.send_command('input /ma "Yoran-Oran (UC)" <me>')
                    tickdelay = os.clock() + 3
                    return true
                elseif spell_recasts[952] < spell_latency and not have_trust("Koru-Moru") then
                    windower.send_command('input /ma "Koru-Moru" <me>')
                    tickdelay = os.clock() + 3
                    return true
                elseif spell_recasts[979] < spell_latency and not have_trust("Selh'teus") then
                    windower.send_command('input /ma "Selh\'teus" <me>')
                    tickdelay = os.clock() + 3
                    return true
                elseif spell_recasts[967] < spell_latency and not have_trust("Qultada") then
                    windower.send_command('input /ma "Qultada" <me>')
                    tickdelay = os.clock() + 3
                    return true
                elseif spell_recasts[914] < spell_latency and not have_trust("Ulmia") then
                    windower.send_command('input /ma "Ulmia" <me>')
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

function user_job_lockstyle()
    -- LINKTRI MODIFICATION (2026-10-11): lockstyle sets are numbered by job ID (RUN = 022).
    -- Was 034 (Lionheart) / 033 (other weapons); those were not per-weapon looks.
    windower.chat.input("/lockstyleset 022")
end