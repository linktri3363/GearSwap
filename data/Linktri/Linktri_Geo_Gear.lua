-- LINKTRI 2026-10-19: earrings/rings keep a fixed side across sets where possible (Malignance Earring = left ear).
-- If one set has item A left / B right and the next wants B left / A right, the game rejects the mirror swap
-- ("Failed to equip ..."), e.g. FC (Loquac./Malignance) -> Dia II (Malignance/Alabaster) while Loquac. is stored.
-- LINKTRI 2026-10-24 (GEO audit): every single-copy ring/earring now has ONE side in every set:
--   ear1: Malignance, Alabaster, Ishvara, Tuisto, Dudgeon
--   ear2: Azimuth Earring +2 (Sortie, ear2 only), Etiolation, Meili, Andoaa, Relaxing, Odnowa +1, Telos, Sanare,
--         Moonshade, Heartseeker, Hirudinea
--   ring1: Kishar, Murky, Metamor. +1, Menelaus's, Mephitas's, Hetairoi
--   ring2: Lebeche, Mallquis, Defending/Ragelise's, Chirich +1, Ephramad's, Vengeful, Petrov
--   Stikini Ring (2 owned, not Rare): one Stikini = ring2; sets that want two use both slots.
-- Loquac. Earring, Brutal Earring and Maxentius are stored and not on the PorterPacker GEO list, so sets use owned
-- gear instead (Etiolation Earring FC+1, Ishvara Earring). The Maxentius weapon option stays for when you unpack it.
near_porter = false  -- Track if we're near Porter Moogle

-- Skillchain / Magic Burst window (shared with BLM and SCH): Linktri-MBWindow.lua
-- LINKTRI (2026-10-20): windows open only for skillchains made by you, your party/alliance (trusts included) or
-- their pets, and only for the monster that was skillchained. Previously any skillchain seen nearby counted.
SC_WINDOW_DURATION = 8  -- Skillchain window duration in seconds
include('Linktri-MBWindow.lua')
include('Linktri-DivineVeil.lua') -- LINKTRI: shared party-ailment detection for /WHM Divine Seal

function user_job_setup()
    -- Options: Override default values
    state.OffenseMode:options('Normal')
    state.CastingMode:options('Normal', 'Resistant', 'Fodder', 'Proc')
    state.IdleMode:options('Normal','PDT','Pet','PetDT')
    state.PhysicalDefenseMode:options('PDT', 'NukeLock', 'GeoLock', 'PetPDT')
    state.MagicalDefenseMode:options('MDT', 'NukeLock')
    state.ResistDefenseMode:options('MEVA')
    state.Weapons:options('None','Maxentius','DualWeapons','Daybreak','Bunzi','PetDT','Skill','Ngai')

    -- Custom Capes
    gear.nuke_jse_back = {name="Nantosuelta's Cape",augments={'Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','Pet: "Regen"+10','Pet: "Regen"+5'}}
    -- idle_jse_back: Nantosuelta's Cape for pet regen / luopan survivability
    gear.idle_jse_back = {name="Nantosuelta's Cape",augments={'Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','Pet: "Regen"+10','Pet: "Regen"+5'}}
    gear.fc_jse_back = gear.nuke_jse_back
    
    -- Belt options for different casting scenarios
    gear.obi_cure_back = "Twilight Cape"
    gear.obi_cure_waist = "Witful Belt"
    gear.obi_low_nuke_back = gear.nuke_jse_back
    gear.obi_low_nuke_waist = "Sacro Cord"
    gear.obi_high_nuke_back = gear.nuke_jse_back
    gear.obi_high_nuke_waist = "Eschan Stone"
    
    -- Auto spells for automation
    autoindi = "Haste"
    autogeo = "Frailty"
    
    -- Auto Magic Burst mode: off by default, must be manually enabled per fight.
    -- Safeguards: will not fire if PetDT weapon set is active.
    -- Toggle: //gs c automg or ^F7
    state.AutoMBMode = M(false, 'Auto MB Mode')

    -- Additional local binds
    send_command('bind ^` gs c cycle ElementalMode')
    send_command('bind !` input /ja "Full Circle" <me>')
    send_command('bind @f8 gs c toggle AutoNukeMode')
    send_command('bind @` gs c cycle MagicBurstMode')
    send_command('bind @f10 gs c cycle RecoverMode')
    send_command('bind ^backspace input /ja "Entrust" <me>')
    send_command('bind !backspace input /ja "Life Cycle" <me>')
    send_command('bind @backspace input /ma "Sleep II" <t>')
    send_command('bind ^delete input /ma "Aspir III" <t>')
    send_command('bind @delete input /ma "Sleep" <t>')
    send_command('bind ^F7 gs c toggle AutoMBMode')

    -- LINKTRI (2026-10-22): /WHM Divine Veil. Divine Seal before a status removal (Erase or a -na) makes it AoE for
    -- the target's party. Modes (//gs c cycle AutoDivineSeal):
    --   Smart  - use Divine Seal only when 2+ party members near the target have an ailment this spell removes
    --   Always - use Divine Seal on every status removal while it's ready
    --   Off    - never
    state.AutoDivineSeal = M{['description'] = 'Auto Divine Seal', 'Smart', 'Always', 'Off'}
    
    indi_duration = 340
    

	-- Nuke stepdown: falls to the next tier when on recast or short on MP
	local tiers = {' VI', ' V', ' IV', ' III', ' II', ''}
	for _, base in ipairs({'Stone', 'Water', 'Aero', 'Fire', 'Blizzard', 'Thunder'}) do
		for i = 1, #tiers - 1 do
			spell_stepdown[base..tiers[i]] = base..tiers[i+1]
		end
	end
	for _, base in ipairs({'Stonera', 'Watera', 'Aera', 'Fira', 'Blizzara', 'Thundara'}) do
		spell_stepdown[base..' III'] = base..' II'
		spell_stepdown[base..' II'] = base
	end
	
	select_default_macro_book()
	cardinal_init()  -- LINKTRI: Cardinal Chant display (moved here from GEO.lua; see bottom of this file)
end


function init_gear_sets()
    
    --------------------------------------
    -- Precast sets
    --------------------------------------

    -- Precast sets to enhance JAs
    -- All Bagua pieces updated to +4 (confirmed in inventory)
    sets.precast.JA.Bolster = {body="Bagua Tunic +4"}
    sets.precast.JA['Life Cycle'] = {body="Geo. Tunic +4",back=gear.idle_jse_back}
    sets.precast.JA['Radial Arcana'] = {feet="Bagua Sandals +4"}
    sets.precast.JA['Mending Halation'] = {legs="Bagua Pants +4"}
    sets.precast.JA['Full Circle'] = {
        head="Bagua Galero +4",
        hands="Bagua Mitaines +4"
    }
    sets.precast.JA['Ecliptic Attrition'] = {head="Jhakri Coronal +2"}
    sets.precast.JA['Blaze of Glory'] = {head="Bagua Galero +4"}
    sets.precast.JA['Dematerialize'] = {head="Bagua Galero +4"}
    
    -- Indi Duration and Entrust
    sets.buff.Entrust = {}
    sets.buff['Blaze of Glory'] = {head="Bagua Galero +4"}
    
    -- Fast cast sets
    -- LINKTRI 2026-10-24: FC ~51% -> ~63% (cap 80): Geomancy Pants +4 FC+15 (was Gyve Trousers FC+4),
    -- Agwu's Robe FC+8 (was Merlinic Jubbah FC+6), Etiolation Earring FC+1 (Loquac. Earring is stored).
    sets.precast.FC = {
        main=gear.grioavolr_fc_staff,
        sub="Clerisy Strap +1",
        ammo="Impatiens",
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5',"CHR+4","Mag. Acc.+14",'"Mag.Atk.Bns."+15',}},
        neck="Voltsurge Torque",
        ear1="Malignance Earring",  -- LINKTRI 2026-10-19: Malignance always left ear (see note at top)
        ear2="Etiolation Earring",
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back=gear.fc_jse_back,
        waist="Witful Belt",
        legs="Geomancy Pants +4",
        feet={ name="Regal Pumps +1", augments={'Path: A',}}
    }

    -- Geomancy precast: equip Dunna in range slot for FC+3 contribution
    sets.precast.FC.Geomancy = set_combine(sets.precast.FC, {
        range={ name="Dunna", augments={'MP+20','Mag. Acc.+10','"Fast Cast"+3',}},
        ammo=empty
    })

    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {
        ear1="Malignance Earring",
        hands="Bagua Mitaines +4"
    })

    sets.precast.FC.Cure = set_combine(sets.precast.FC, {
        main = "Daybreak",  -- Cure potency +30%, MND+30; Raetic Rod +1 swaps in via user_job_post_midcast with Refresh/Ballad; original: gear.gada_healing_club (gear.gada_healing_club: Gada with Cure+9% augments not owned)
        sub="Sors Shield",
        body={ name="Vanya Robe", augments={'MP+50','"Cure" potency +7%','Enmity-6',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        legs="Geomancy Pants +4",
        feet={ name="Medium's Sabots", augments={'MP+50','MND+10','"Conserve MP"+7','"Cure" potency +5%',}}
    })
        
    sets.precast.FC.Curaga = sets.precast.FC.Cure
    
    -- Healing and Refresh sets
    -- LINKTRI 2026-10-24: Self_Healing swapped Unmoving Collar (Enmity+9, no cure stats) over Nodens Gorget (Cure+5) on
    -- every cure you cast on yourself. The cure set already has Agwu's Gages (cure received +10%), so nothing to add.
    sets.Self_Healing = {}
    sets.Cure_Received = {hands={ name="Agwu's Gages", augments={'Path: A',}}}  -- Cure received +10%
    sets.Self_Refresh = {back="Nantosuelta's Cape",waist="Witful Belt",feet="Inspirited Boots"}
    
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})
    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {})

    sets.precast.FC.Impact = {
        ammo="Impatiens",
        head=empty,
        neck="Voltsurge Torque",
        ear1="Malignance Earring",  -- LINKTRI 2026-10-19: Malignance always left ear (see note at top)
        ear2="Etiolation Earring",  -- LINKTRI 2026-10-24: Loquac. Earring is stored
        body = "Twilight Cloak",  -- original: "Twilight Cape" (a cape in the body slot; Impact needs Twilight Cloak)
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back=gear.fc_jse_back,
        waist="Witful Belt",
        legs="Geomancy Pants +4",  -- LINKTRI 2026-10-24: FC+15 (was Gyve Trousers FC+4)
        feet={ name="Regal Pumps +1", augments={'Path: A',}}
    }
        
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main="Daybreak",sub="Ammurapi Shield"})
    
    -- Weaponskill sets
    sets.precast.WS = {
        ammo = "Amar Cluster",  -- original: { name="Coiste Bodhar", augments={'Path: A',}} (Coiste Bodhar is not GEO-equippable)
        head={ name="Nyame Helm", augments={'Path: B',}},
        neck="Light Gorget",
        ear1="Ishvara Earring",
        ear2 = { name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},  -- original: { name="Moonshade Earring", augments={'Accuracy+4','Latent effect: "Regain"+1',}} (augments did not match your Moonshade, so it never equipped)
        body={ name="Nyame Mail", augments={'Path: B',}},
        hands={ name="Nyame Gauntlets", augments={'Path: B',}},
        ring1="Hetairoi Ring",
        ring2="Ephramad's Ring",
        back=gear.nuke_jse_back,
        waist="Light Belt",
        legs={ name="Nyame Flanchard", augments={'Path: B',}},
        feet={ name="Nyame Sollerets", augments={'Path: B',}}
    }

    sets.precast.WS.Physical = {
        ammo = "Amar Cluster",  -- original: { name="Coiste Bodhar", augments={'Path: A',}} (Coiste Bodhar is not GEO-equippable)
        head={ name="Nyame Helm", augments={'Path: B',}},
        neck="Light Gorget",
        ear1="Ishvara Earring",  -- LINKTRI 2026-10-24: Brutal Earring is stored
        ear2 = { name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},  -- original: { name="Moonshade Earring", augments={'Accuracy+4','Latent effect: "Regain"+1',}} (augments did not match your Moonshade, so it never equipped)
        body={ name="Nyame Mail", augments={'Path: B',}},
        hands={ name="Nyame Gauntlets", augments={'Path: B',}},
        ring1="Hetairoi Ring",
        ring2="Ephramad's Ring",
        back=gear.nuke_jse_back,
        waist="Light Belt",
        legs={ name="Nyame Flanchard", augments={'Path: B',}},
        feet={ name="Nyame Sollerets", augments={'Path: B',}}
    }

    sets.precast.WS['Realmrazer'] = set_combine(sets.precast.WS.Physical, {
        neck="Light Gorget",
        waist="Light Belt"
    })

    sets.precast.WS['Exudation'] = set_combine(sets.precast.WS.Physical, {
        neck="Light Gorget",
        waist="Light Belt"
    })

    sets.midcast.FastRecast = {
        main=gear.grioavolr_fc_staff,
        sub="Clerisy Strap +1",
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5',"CHR+4","Mag. Acc.+14",'"Mag.Atk.Bns."+15',}},
        neck="Voltsurge Torque",
        ear1="Malignance Earring",  -- LINKTRI 2026-10-19: Malignance always left ear (see note at top)
        ear2="Etiolation Earring",  -- LINKTRI 2026-10-24: Loquac. Earring is stored
        body={ name="Agwu's Robe", augments={'Path: A',}},  -- LINKTRI 2026-10-24: FC+8 (was Merlinic Jubbah FC+6)
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back=gear.fc_jse_back,
        waist="Witful Belt",
        legs="Geomancy Pants +4",  -- LINKTRI 2026-10-24: FC+15 (was Gyve Trousers FC+4)
        feet={ name="Regal Pumps +1", augments={'Path: A',}}
    }

    -- GEOMANCY CASTING SETS
    -- Geo. Mitaines +4 corrected from +2
    -- Idris in main for Geomancy potency (in upgrade, will be available)
    -- LINKTRI 2026-10-24: head Azimuth Hood +3 (was Geo. Galero +4: its Elemental skill and Cardinal Chant do nothing for
    -- Geomancy) and body Azimuth Coat +3 (was Geo. Tunic +4: Life Cycle/Refresh only). With Azimuth Gaiters +3 that is
    -- 3 Azimuth pieces, which turns on the set bonus "Occasionally casts geomancy spells without using MP"
    -- (one piece gave nothing). Hood also adds Geomancy skill +25 and DT-12%.
    sets.midcast.Geomancy = {
        main="Idris",
        sub="Genmei Shield",
        range={ name="Dunna", augments={'MP+20','Mag. Acc.+10','"Fast Cast"+3',}},
        head="Azimuth Hood +3",
        neck={ name="Bagua Charm +2", augments={'Path: A',}},
        ear1="Malignance Earring",
        ear2="Azimuth Earring +2",
        body="Azimuth Coat +3",
        hands="Geo. Mitaines +4",
        ring1={ name="Murky Ring", augments={'Path: A',}},  -- LINKTRI 2026-10-24: Murky always ring1
        ring2="Stikini Ring",
        back={ name="Lifestream Cape", augments={'Geomancy Skill +10','Indi. eff. dur. +20','Pet: Damage taken -2%',}},
        waist="Luminary Sash",
        legs="Geomancy Pants +4",
        feet="Azimuth Gaiters +3"
    }

    -- Indi set: Solstice main for Indi duration +15% (multiplicative) + Fast Cast+5%.
    -- Idris Geomancy+10 does not apply to Indi-spells so Solstice is correct here.
    -- Lifestream Cape: Geomancy Skill+10, Indi. eff. dur. +20% (multiplicative), Pet: DT-2%.
    -- Duration math: (180 + JP60 + BaguaPants21 + AzimuthGaiters30)
    --                x Solstice(1.15) x Lifestream(1.20) = ~401s (6:41).
    sets.midcast.Geomancy.Indi = set_combine(sets.midcast.Geomancy, {
        main={ name="Solstice", augments={'Mag. Acc.+20','Pet: Damage taken -4%','"Fast Cast"+5',}},
        back={ name="Lifestream Cape", augments={'Geomancy Skill +10','Indi. eff. dur. +20','Pet: Damage taken -2%',}},
        legs="Bagua Pants +4",
        feet="Azimuth Gaiters +3"
    })
        
    -- CURE SETS
    sets.midcast.Cure = {
        main = "Daybreak",  -- Cure potency +30%, MND+30; Raetic Rod +1 swaps in via user_job_post_midcast with Refresh/Ballad; original: gear.gada_healing_club (gear.gada_healing_club: Gada with Cure+9% augments not owned)
        sub = "Genmei Shield",  -- DT-10%; Cure potency stays ~57% (cap 50) with Daybreak; original: "Sors Shield" (owned, swapped)
        ammo="Hydrocera",
        head="Azimuth Hood +3",
        neck="Nodens Gorget",
        ear1="Alabaster Earring",  -- LINKTRI 2026-10-24: Alabaster always ear1, Meili ear2 (were swapped)
        ear2="Meili Earring",
        body={ name="Vanya Robe", augments={'MP+50','"Cure" potency +7%','Enmity-6',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},  -- LINKTRI 2026-10-24: MND+6 (Stikini MND+5); ring1 side
        ring2="Lebeche Ring",
        back = "Aurist's Cape +1",  -- MND+8; original: "Twilight Cape" (Twilight Cape only helps on matching day/weather)
        waist="Witful Belt",
        legs="Geomancy Pants +4",
        feet={ name="Medium's Sabots", augments={'MP+50','MND+10','"Conserve MP"+7','"Cure" potency +5%',}}
    }
        
    sets.midcast.LightDayCure = {
        main = "Daybreak",  -- Cure potency +30%, MND+30; Raetic Rod +1 swaps in via user_job_post_midcast with Refresh/Ballad; original: gear.gada_healing_club (gear.gada_healing_club: Gada with Cure+9% augments not owned)
        sub = "Genmei Shield",  -- DT-10%; Cure potency stays ~57% (cap 50) with Daybreak; original: "Sors Shield" (owned, swapped)
        ammo="Hydrocera",
        head="Azimuth Hood +3",
        neck="Nodens Gorget",
        ear1="Alabaster Earring",  -- LINKTRI 2026-10-24: Alabaster always ear1, Meili ear2 (were swapped)
        ear2="Meili Earring",
        body={ name="Vanya Robe", augments={'MP+50','"Cure" potency +7%','Enmity-6',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},  -- LINKTRI 2026-10-24: MND+6 (Stikini MND+5); ring1 side
        ring2="Lebeche Ring",
        back="Twilight Cape",
        waist="Hachirin-no-Obi",
        legs="Geomancy Pants +4",
        feet={ name="Medium's Sabots", augments={'MP+50','MND+10','"Conserve MP"+7','"Cure" potency +5%',}}
    }

    -- LINKTRI 2026-10-24: LightWeatherCure used Chatoyant Staff (Cure+10) and Unmoving Collar: ~32% potency against the 50%
    -- cap. It now matches LightDayCure: Daybreak + Nodens (capped) with Hachirin-no-Obi and Twilight Cape for the bonus.
    sets.midcast.LightWeatherCure = set_combine(sets.midcast.LightDayCure, {})

    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {})  -- original: {main="Daybreak",sub="Sors Shield"} (Cure now uses Daybreak + Genmei Shield)

    -- LINKTRI 2026-10-24: Cursna success comes from Healing skill and "Cursna"+. Menelaus's Ring (Cursna+20, Healing+15),
    -- Stikini (skills+5), Meili Earring (Healing+10) and Regal Pumps +1 (Healing+11). Unmoving Collar (Enmity+9) dropped.
    sets.midcast.Cursna = set_combine(sets.midcast.Cure, {
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        back = "Aurist's Cape +1",  -- original: "Twilight Cape" (Twilight Cape only helps on matching day/weather)
        ring1="Menelaus's Ring",
        ring2="Stikini Ring",
        waist="Witful Belt",
        feet={ name="Regal Pumps +1", augments={'Path: A',}}
    })
    
    sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {
        main=gear.grioavolr_fc_staff,
        sub="Clerisy Strap +1"
    })
    
    -- ELEMENTAL MAGIC SETS
    -- BG-wiki BIS free nuke set reference (All Jobs Gear Sets/Geomancer):
    --   ammo: Ghastly Tathlum +1 > Coiste Bodhar         -- ACQUIRE: Ghastly Tathlum +1
    --   ear1: Regal Earring > Crematio Earring            -- ACQUIRE: Regal Earring
    --   ring2: Freke Ring > Lebeche Ring                  -- ACQUIRE: Freke Ring
    --   waist: Acuity Belt +1 > Eschan Stone              -- ACQUIRE: Acuity Belt +1
    --   back: Nantosuelta's Cape INT+20/MAB+10 augment    -- ACQUIRE: Nantosuelta's Cape with INT nuke augment
    sets.midcast['Elemental Magic'] = {
        main={ name="Bunzi's Rod", augments={'Path: A',}},  -- upgraded from Daybreak per BG-wiki BIS
        sub="Ammurapi Shield",
        ammo = "Pemphredo Tathlum",  -- original: { name="Coiste Bodhar", augments={'Path: A',}} (Coiste Bodhar is not GEO-equippable)
        head={ name="Agwu's Cap", augments={'Path: A',}},
        neck="Baetyl Pendant",  -- MAB+13 beats Sibyl Scarf (INT+10/MAB+10)
        ear1="Malignance Earring",  -- INT+8/MAB+8/MagAcc+10/FC+4% beats Crematio
        ear2={ name="Azimuth Earring +2", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+18','Damage taken-7%','INT+11 MND+11',}},
        body="Azimuth Coat +3",  -- upgraded from Agwu's Robe per BG-wiki BIS
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},  -- BIS ring1 per BG-wiki
        ring2 = "Mallquis Ring",  -- Magic Damage +12, MAcc+6, elemental cast -3%; Lebeche has no nuke stats; original: "Lebeche Ring" (owned, swapped)
        back=gear.nuke_jse_back,
        waist="Eschan Stone",  -- upgrade to Acuity Belt +1 when acquired
        legs="Azimuth Tights +3",  -- upgraded from Agwu's Slops per BG-wiki BIS
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}
    }

    sets.midcast['Elemental Magic'].Resistant = {
        main={ name="Bunzi's Rod", augments={'Path: A',}},  -- upgraded from Daybreak per BG-wiki BIS
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head={ name="Agwu's Cap", augments={'Path: A',}},
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Azimuth Earring +2",
        body="Azimuth Coat +3",  -- upgraded from Agwu's Robe per BG-wiki BIS
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},  -- LINKTRI 2026-10-24: Metamor. ring1, Stikini ring2
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",  -- upgrade to Acuity Belt +1 when acquired
        legs="Azimuth Tights +3",
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}
    }
        
    sets.midcast['Elemental Magic'].Proc = {
        main=empty,
        sub=empty,
        ammo="Impatiens",
        head="Jhakri Coronal +2",
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Malignance Earring",
        ear2="Etiolation Earring",  -- LINKTRI 2026-10-24: Loquac. Earring is stored
        body = { name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25',"CHR+2","Mag. Acc.+11",'"Mag.Atk.Bns."+9',}},  -- FC+6; original: { name="Samnuha Coat", augments={'Mag. Acc.+8','"Mag.Atk.Bns."+11','"Dual Wield"+2',}} (Samnuha Coat is not GEO-equippable)
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back="Nexus Cape",
        waist="Witful Belt",
        legs="Assid. Pants +1",
        feet={ name="Regal Pumps +1", augments={'Path: A',}}
    }
        
    sets.midcast['Elemental Magic'].Fodder = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo = "Pemphredo Tathlum",  -- original: { name="Coiste Bodhar", augments={'Path: A',}} (Coiste Bodhar is not GEO-equippable)
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5',"CHR+4","Mag. Acc.+14",'"Mag.Atk.Bns."+15',}},
        neck="Baetyl Pendant",  -- MAB+13 beats Sibyl Scarf
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +2", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+18','Damage taken-7%','INT+11 MND+11',}},
        body={ name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25',"CHR+2","Mag. Acc.+11",'"Mag.Atk.Bns."+9',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},  -- LINKTRI 2026-10-24: Stikini can't share ring2 with Mallquis
        ring2 = "Mallquis Ring",  -- Magic Damage +12, MAcc+6, elemental cast -3%; Lebeche has no nuke stats; original: "Lebeche Ring" (owned, swapped)
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4',"Mag. Acc.+6",'"Mag.Atk.Bns."+14',}}
    }
        
    -- LINKTRI 2026-10-24: job_get_spell_map sends every tier III+ nuke and every -ja here, so these were most of your nukes.
    sets.midcast['Elemental Magic'].HighTierNuke = {
        main={ name="Bunzi's Rod", augments={'Path: A',}},  -- LINKTRI 2026-10-24: was Malevolence (Magic Damage+118 vs 248, MAcc+35 vs +40)
        sub="Ammurapi Shield",
        ammo = "Pemphredo Tathlum",  -- original: { name="Coiste Bodhar", augments={'Path: A',}} (Coiste Bodhar is not GEO-equippable)
        head={ name="Agwu's Cap", augments={'Path: A',}},
        neck="Baetyl Pendant",
        ear1="Malignance Earring",  -- upgrade to Regal Earring when acquired
        ear2="Azimuth Earring +2",
        body="Azimuth Coat +3",  -- upgraded from Agwu's Robe per BG-wiki BIS
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2 = "Mallquis Ring",  -- Magic Damage +12, MAcc+6, elemental cast -3%; Lebeche has no nuke stats; original: "Lebeche Ring" (owned, swapped)
        back=gear.nuke_jse_back,
        waist="Eschan Stone",  -- upgrade to Acuity Belt +1 when acquired
        legs="Azimuth Tights +3",  -- upgraded from Agwu's Slops per BG-wiki BIS
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}
    }
        
    sets.midcast['Elemental Magic'].HighTierNuke.Resistant = {
        main={ name="Bunzi's Rod", augments={'Path: A',}},  -- LINKTRI 2026-10-24: was Malevolence (Magic Damage+118 vs 248, MAcc+35 vs +40)
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head={ name="Agwu's Cap", augments={'Path: A',}},  -- MagAcc+40/FC+5% beats Azimuth Hood DT-12%
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +2", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+18','Damage taken-7%','INT+11 MND+11',}},
        body="Azimuth Coat +3",
        hands="Azimuth Gloves +3",
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2 = "Mallquis Ring",  -- Magic Damage +12, MAcc+6, elemental cast -3%; Lebeche has no nuke stats; original: "Lebeche Ring" (owned, swapped)
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Azimuth Tights +3",
        feet="Azimuth Gaiters +3"
    }

    sets.midcast['Elemental Magic'].HighTierNuke.Fodder = {
        main={ name="Bunzi's Rod", augments={'Path: A',}},  -- LINKTRI 2026-10-24: was Malevolence (Magic Damage+118 vs 248, MAcc+35 vs +40)
        sub="Ammurapi Shield",
        ammo = "Pemphredo Tathlum",  -- original: { name="Coiste Bodhar", augments={'Path: A',}} (Coiste Bodhar is not GEO-equippable)
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5',"CHR+4","Mag. Acc.+14",'"Mag.Atk.Bns."+15',}},
        neck="Baetyl Pendant",  -- MAB+13 beats Sibyl Scarf
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +2", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+18','Damage taken-7%','INT+11 MND+11',}},
        body="Azimuth Coat +3",  -- upgraded from Merlinic Jubbah per BG-wiki BIS
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2 = "Mallquis Ring",  -- Magic Damage +12, MAcc+6, elemental cast -3%; Lebeche has no nuke stats; original: "Lebeche Ring" (owned, swapped)
        back=gear.nuke_jse_back,
        waist="Eschan Stone",  -- upgrade to Acuity Belt +1 when acquired
        legs="Azimuth Tights +3",  -- upgraded from Agwu's Slops per BG-wiki BIS
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}
    }

    -- DARK MAGIC SETS
    -- LINKTRI 2026-10-24: rebuilt for magic accuracy and dark skill. Null Loop (MAcc+50) over Baetyl Pendant (MAB+13, no
    -- MAcc), Null Belt (MAcc+30) over Eschan Stone (MAcc+7), Azimuth Hood/Gloves/Gaiters +3 (MAcc+60-62) over Agwu's/
    -- Merlinic (MAcc+40/0), Azimuth Tights +3 (Dark skill+30) and Geo. Tunic +4 (Dark skill+22).
    sets.midcast['Dark Magic'] = {
        main={ name="Rubicundity", augments={'Mag. Acc.+10','"Mag.Atk.Bns."+10','Dark magic skill +10','"Conserve MP"+7',}},
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head="Azimuth Hood +3",
        neck="Null Loop",
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +2", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+18','Damage taken-7%','INT+11 MND+11',}},
        body="Geo. Tunic +4",
        hands="Azimuth Gloves +3",
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Null Belt",
        legs="Azimuth Tights +3",
        feet="Azimuth Gaiters +3"
    }

    -- Drain/Aspir potency: Bagua Galero +4 (+35), Rubicundity (+20), Agwu's Pigaches (+20), Fucho-no-Obi (+8),
    -- Hirudinea Earring; plus Dark skill (Azimuth Tights +30, Geo. Tunic +22, Stikini x2 +10).
    -- LINKTRI 2026-10-24: head was Befouled Crown (no Drain/Aspir potency); ear2 Hirudinea over Azimuth (MAB/Geomancy).
    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {
        head="Bagua Galero +4",
        ear2="Hirudinea Earring",
        ring1="Stikini Ring",
        ring2="Stikini Ring",
        waist="Fucho-no-Obi",
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}
    })

    sets.midcast.Aspir = sets.midcast.Drain

    -- Stun: fast recast first (same FC pieces as FastRecast), magic accuracy rings
    sets.midcast.Stun = {
        main=gear.grioavolr_fc_staff,
        sub="Clerisy Strap +1",
        ammo="Pemphredo Tathlum",
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5',"CHR+4","Mag. Acc.+14",'"Mag.Atk.Bns."+15',}},
        neck="Voltsurge Torque",
        ear1="Malignance Earring",  -- LINKTRI 2026-10-19: Malignance always left ear (see note at top)
        ear2="Etiolation Earring",  -- LINKTRI 2026-10-24: Loquac. Earring is stored
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Stikini Ring",
        back=gear.fc_jse_back,
        waist="Witful Belt",
        legs="Geomancy Pants +4",
        feet={ name="Regal Pumps +1", augments={'Path: A',}}
    }

    sets.midcast.Stun.Resistant = set_combine(sets.midcast['Dark Magic'], {main="Daybreak"})

    sets.midcast.Impact = set_combine(sets.midcast['Dark Magic'], {
        main="Daybreak",
        head=empty,
        body = "Twilight Cloak",  -- original: "Twilight Cape" (a cape in the body slot; Impact needs Twilight Cloak)
    })

    -- ENFEEBLING MAGIC SETS
    -- LINKTRI 2026-10-24: rebuilt for magic accuracy. Head/body/hands/legs/feet Azimuth +3 (MAcc+60-64, Enfeebling skill
    -- +28 on the gloves) over Befouled Crown/Agwu's/Merlinic (MAcc+20/40/0); Null Loop (MAcc+50) over Baetyl Pendant;
    -- Null Belt (MAcc+30) over Luminary Sash (MAcc+10); Azimuth Earring +2 (MAcc+18) over Alabaster (no MAcc - and it
    -- also mirrored ear sides with idle). Kishar Ring kept for Enfeebling duration +10%.
    -- TreasureHunter is defined first now: Dia/Bio below used to pick up Linktri-Items' version with Wh. Rarab Cap +1
    -- (stored), which left the Dia/Bio head slot unchanged.
    sets.TreasureHunter = {waist="Chaac Belt"}  -- original: TH+2 Merlinic Crackows (not owned); Chaac Belt TH+1

    sets.midcast['Enfeebling Magic'] = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head="Azimuth Hood +3",
        neck="Null Loop",
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +2", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+18','Damage taken-7%','INT+11 MND+11',}},
        body="Azimuth Coat +3",
        hands="Azimuth Gloves +3",
        ring1="Kishar Ring",
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Null Belt",
        legs="Azimuth Tights +3",
        feet="Azimuth Gaiters +3"
    }

    sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}}
    })

    -- Elemental enfeebles (Burn, Choke, ...): Agwu's Slops "Elemental magic status ailment effects +10"
    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {
        legs={ name="Agwu's Slops", augments={'Path: A',}}
    })
    sets.midcast.ElementalEnfeeble.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {
        legs={ name="Agwu's Slops", augments={'Path: A',}}
    })

    sets.midcast.IntEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.IntEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

    sets.midcast.MndEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {range=empty})
    sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {range=empty})

    sets.midcast.Dia = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast['Dia II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)

    sets.midcast.Bio = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast['Bio II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)

    sets.midcast['Divine Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {})

    -- Dispel lands on Enfeebling skill + magic accuracy: same as the enfeebling set (was a nuke-style set)
    sets.midcast.Dispel = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Dispelga = set_combine(sets.midcast.Dispel, {main="Daybreak",sub="Ammurapi Shield"})

    -- ENHANCING MAGIC SETS
    sets.midcast['Enhancing Magic'] = {
        main=gear.gada_enhancing_club,
        sub="Ammurapi Shield",
        ammo="Hydrocera",
        head={ name="Telchine Cap", augments={'Mag. Acc.+20','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        neck="Nodens Gorget",
        ear1="Malignance Earring",  -- LINKTRI 2026-10-19: Malignance always left ear (see note at top)
        ear2="Andoaa Earring",
        body={ name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        hands={ name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        ring1="Stikini Ring",  -- LINKTRI 2026-10-24: both Stikini (Enhancing skill +5 each); Kishar (FC/enfeeble) did nothing here
        ring2="Stikini Ring",
        back = "Perimede Cape",  -- Enhancing skill +7; original: "Twilight Cape" (Twilight Cape only helps on matching day/weather)
        waist="Embla Sash",
        legs={ name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        feet={ name="Telchine Pigaches", augments={'Mag. Acc.+18','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}}
    }
        
    -- LINKTRI 2026-10-24: ear2 stays Andoaa (Enhancing skill +5, which Stoneskin scales with); Alabaster had no Stoneskin stat
    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
        neck="Nodens Gorget",
        waist="Siegel Sash"
    })

    -- LINKTRI 2026-10-24: was head Agwu's Cap, which dropped Telchine Cap's Enhancing duration +10% for nothing
    sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {})
    
    sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {
        main="Chatoyant Staff",
        sub="Clerisy Strap +1",
        head={ name="Agwu's Cap", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}}
    })
    
    sets.midcast.BarElement = set_combine(sets.precast.FC['Enhancing Magic'], {})
    
    -- LINKTRI 2026-10-24: Protect/Shell swapped Embla Sash (Enhancing duration +10%) for Sacro Cord (INT/MND/MAB - nothing
    -- for these spells). They use the full enhancing duration set now.
    sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {})
    sets.midcast.Protectra = set_combine(sets.midcast['Enhancing Magic'], {})
    sets.midcast.Shell = set_combine(sets.midcast['Enhancing Magic'], {})
    sets.midcast.Shellra = set_combine(sets.midcast['Enhancing Magic'], {})

    --------------------------------------
    -- Idle/resting/defense/etc sets
    --------------------------------------

    -- Resting sets
    sets.resting = {
        main="Chatoyant Staff",
        sub="Clerisy Strap +1",
        head="Befouled Crown",
        neck="Unmoving Collar",
        ear1="Alabaster Earring",
        ear2="Relaxing Earring",
        body="Jhakri Robe +2",
        hands="Mallquis Cuffs +2",
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Stikini Ring",  -- LINKTRI 2026-10-24: Lebeche is ring2 in FC/cures; resting keeps the idle ring pair
        back="Nantosuelta's Cape",
        legs="Assid. Pants +1",
        feet="Mallquis Clogs +2"
    }

 
    sets.idle = {
        main="Idris",
        sub="Ammurapi Shield",
        ammo = "Staunch Tathlum +1",  -- original: "Homiliary" (Homiliary is not GEO-equippable)
        head="Null Masque",
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Alabaster Earring",
        ear2="Azimuth Earring +2",
        body="Azimuth Coat +3",
        hands="Azimuth Gloves +3",
        ring1={ name="Murky Ring", augments={'Path: A',}},  -- LINKTRI 2026-10-24: Murky ring1 / Stikini ring2 (were swapped)
        ring2="Stikini Ring",
        back="Nantosuelta's Cape",
        waist="Carrier's Sash",
        legs="Assid. Pants +1",
        feet="Azimuth Gaiters +3"
    }
        
    sets.idle.PDT = {
        main="Malignance Pole",
        sub="Umbra Strap",
        ammo = "Staunch Tathlum +1",  -- original: "Homiliary" (Homiliary is not GEO-equippable)
        head={ name="Nyame Helm", augments={'Path: B',}},
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Alabaster Earring",
        ear2="Azimuth Earring +2",
        body="Mallquis Saio +2",
        hands={ name="Nyame Gauntlets", augments={'Path: B',}},
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Mallquis Ring",
        back="Nantosuelta's Cape",
        waist="Carrier's Sash",
        legs={ name="Nyame Flanchard", augments={'Path: B',}},
        feet="Mallquis Clogs +2"
    }

    -- Pet idle: focus on Luopan survivability (DT + Regen)
    -- Refresh/DT hybrid for comfortable content with luopan active.
    -- Luopan DT: Idris(-25%) + Geo. Mitaines +4(-13%) = -38%, exactly capped.
    -- Self DT: Genmei(-10%) + Azimuth Hood(0%) + Alabaster(-5%) + Azimuth Ear(-7%)
    --          + Azimuth Coat(0%) + Geo. Mitaines(-3% PDT) + Murky(-10%) + Defending(-10%)
    --          + Nyame Flanchard(-8%) + Bagua Sandals(0%) + Isa Belt(-3%) = -56%, over cap.
    -- Refresh: Azimuth Coat(+4) + Homiliary(latent) = +4 base.
    -- Pet Regen: Azimuth Hood(+5) + Nantosuelta(+15) + Bagua Sandals(+6) = +26 HP/tick.
    --            Perpetuation: -24 base + Bagua Charm(-6) = -18 HP/tick. Net: +8 HP/tick.
    sets.idle.Pet = {
        main="Idris",
        sub="Genmei Shield",
        head="Azimuth Hood +3",
        neck={ name="Bagua Charm +2", augments={'Path: A',}},
        ear1="Tuisto earring",
        ear2="Odnowa earring +1",
        body="Adamantite Armor",
        hands="Geo. Mitaines +4",
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Ragelise's Ring",  -- DT-10%, Cure received +10%; falls back to Defending Ring when not on you (user_job_customize_idle_set)
        back = gear.idle_jse_back,  -- Nantosuelta's: Luopan Regen+15; original: "Moonlight Cape" (not owned)
        waist = "Isa Belt",  -- DT-3%, Regen+1, Pet Eva+10; original: "Plat. Mog. Belt" (not owned)
        legs={ name="Nyame Flanchard", augments={'Path: B',}},
        feet="Azimuth Gaiters +3"
    }

    -- PetDT idle: mirrors sets.idle.Pet exactly.
    -- Luopan DT: Idris(-25%) + Geo. Mitaines +4(-13%) = -38%, exactly capped.
    -- Midcast/defense sets overlay on top of this base.
    sets.idle.PDT.Pet = {
        main="Idris",
        sub="Genmei Shield",
        head="Azimuth Hood +3",
        neck={ name="Bagua Charm +2", augments={'Path: A',}},
        ear1="Tuisto earring",
        ear2="Odnowa earring +1",
        body="Adamantite Armor",
        hands="Geo. Mitaines +4",
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Ragelise's Ring",  -- DT-10%, Cure received +10%; falls back to Defending Ring when not on you (user_job_customize_idle_set)
        back = gear.idle_jse_back,  -- Nantosuelta's: Luopan Regen+15; original: "Moonlight Cape" (not owned)
        waist = "Isa Belt",  -- DT-3%, Regen+1, Pet Eva+10; original: "Plat. Mog. Belt" (not owned)
        legs={ name="Nyame Flanchard", augments={'Path: B',}},
        feet="Azimuth Gaiters +3"
    }

    -- Pet regen focus
    sets.idle.PetRegen = {
        main={ name="Solstice", augments={'Mag. Acc.+20','Pet: Damage taken -4%','"Fast Cast"+5',}},
        sub="Genmei Shield",
        range={ name="Dunna", augments={'MP+20','Mag. Acc.+10','"Fast Cast"+3',}},
        head="Mall. Chapeau +2",
        neck={ name="Bagua Charm +2", augments={'Path: A',}},
        ear1="Alabaster Earring",
        ear2="Relaxing Earring",
        body={ name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        hands="Bagua Mitaines +4",
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Lebeche Ring",
        back=gear.idle_jse_back,
        waist="Carrier's Sash",
        legs={ name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        feet="Bagua Sandals +4"
    }

    -- LINKTRI 2026-10-24: removed sets.idle.Indi / .Pet.Indi / .PDT.Indi / .PDT.Pet.Indi. They put Bagua Pants +4 on
    -- whenever an Indi- spell was up (nearly always), but "Indicolure duration" only counts when the spell is cast
    -- (sets.midcast.Geomancy.Indi already wears them). While idle it just replaced Assid. Pants +1 (Refresh) or
    -- Nyame Flanchard (DT-8%). The 'Indi' idle group still exists; with no Indi sets Sel uses the plain idle sets.

    -- LINKTRI: Weakness set commented out (2026-10-17). Without it, Sel uses your normal idle set while weakened.
    -- To restore, uncomment the lines below; Sel-Include equips sets.idle.Weak automatically when it exists.
    -- sets.idle.Weak = {
        -- main="Chatoyant Staff",
        -- sub="Clerisy Strap +1",
        -- ammo="Homiliary",
        -- head="Befouled Crown",
        -- neck={ name="Loricate Torque +1", augments={'Path: A',}},
        -- ear1="Alabaster Earring",
        -- ear2="Relaxing Earring",
        -- body="Mallquis Saio +2",
        -- hands="Mallquis Cuffs +2",
        -- ring1={ name="Murky Ring", augments={'Path: A',}},
        -- ring2="Lebeche Ring",
        -- back="Nantosuelta's Cape",
        -- waist="Carrier's Sash",
        -- legs="Assid. Pants +1",
        -- feet="Mallquis Clogs +2"
    -- }

    -- Porter Moogle packing set
    sets.packing = {
        main={ name="Mpaca's Staff", augments={'Path: A',}},
        sub="Umbra Strap",
        ammo = "Staunch Tathlum +1",  -- original: "Homiliary" (Homiliary is not GEO-equippable)
        head="Null Masque",
        neck="Sibyl Scarf",
        ear1="Alabaster Earring",
        ear2="Relaxing Earring",
        body={ name="Nyame Mail", augments={'Path: B',}},
        hands={ name="Nyame Gauntlets", augments={'Path: B',}},
        ring1={ name="Murky Ring", augments={'Path: A',}},  -- LINKTRI 2026-10-24: Murky ring1 / Stikini ring2 (were swapped)
        ring2="Stikini Ring",
        back=gear.idle_jse_back,
        waist="Fucho-no-Obi",
        legs="Assid. Pants +1",
        feet={ name="Nyame Sollerets", augments={'Path: B',}}
    }

    -- Defense sets
    sets.defense.PDT = {
        main="Malignance Pole",
        sub="Umbra Strap",
        ammo = "Staunch Tathlum +1",  -- original: "Homiliary" (Homiliary is not GEO-equippable)
        head={ name="Nyame Helm", augments={'Path: B',}},
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Alabaster Earring",
        ear2="Azimuth Earring +2",
        body="Mallquis Saio +2",
        hands={ name="Nyame Gauntlets", augments={'Path: B',}},
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Mallquis Ring",
        back="Nantosuelta's Cape",
        waist="Carrier's Sash",
        legs={ name="Nyame Flanchard", augments={'Path: B',}},
        feet="Mallquis Clogs +2"
    }

    sets.defense.MDT = {
        main="Malignance Pole",
        sub="Umbra Strap",
        ammo = "Staunch Tathlum +1",  -- original: "Homiliary" (Homiliary is not GEO-equippable)
        head="Mall. Chapeau +2",
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Alabaster Earring",
        ear2="Azimuth Earring +2",
        body="Mallquis Saio +2",
        hands={ name="Nyame Gauntlets", augments={'Path: B',}},
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Mallquis Ring",
        back="Nantosuelta's Cape",
        waist="Carrier's Sash",
        legs={ name="Nyame Flanchard", augments={'Path: B',}},
        feet="Mallquis Clogs +2"
    }
        
    sets.defense.MEVA = {
        main="Malignance Pole",
        sub="Enki Strap",
        ammo = "Staunch Tathlum +1",  -- original: "Homiliary" (Homiliary is not GEO-equippable)
        head="Mall. Chapeau +2",
        neck="Unmoving Collar",
        ear1="Alabaster Earring",
        ear2="Sanare Earring",
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        ring1={ name="Murky Ring", augments={'Path: A',}},  -- LINKTRI 2026-10-24: DT-10% (Lebeche had nothing for MEVA)
        ring2="Vengeful Ring",  -- Magic Evasion+9
        back=gear.idle_jse_back,
        waist="Luminary Sash",
        legs={ name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        feet="Mallquis Clogs +2"
    }
        
    sets.defense.PetPDT = sets.idle.PDT.Pet
    sets.defense.NukeLock = sets.midcast['Elemental Magic']
    sets.defense.GeoLock = sets.midcast.Geomancy.Indi

    -- Utility sets
    sets.Kiting = {feet="Geo. Sandals +4"}
    sets.latent_refresh = {waist="Fucho-no-Obi"}
    sets.latent_refresh_grip = {sub="Clerisy Strap +1"}
    sets.TPEat = {neck="Unmoving Collar"}
    sets.DayIdle = {}
    sets.NightIdle = {}
    -- sets.TreasureHunter: defined above the Dia/Bio sets (LINKTRI 2026-10-24)
    
    sets.HPDown = {
        head="Befouled Crown",
        ear1="Alabaster Earring",
        ear2="Relaxing Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Mephitas's Ring",  -- LINKTRI 2026-10-24: Mephitas's ring1 / Stikini ring2 (sides)
        ring2="Stikini Ring",
        back="Nexus Cape",
        legs="Assid. Pants +1",
        feet="Jhakri Pigaches +2"
    }
    
    sets.buff.Doom = set_combine(sets.buff.Doom, {})

    --------------------------------------
    -- Engaged sets
    --------------------------------------

    sets.engaged = {
        head="Azimuth Hood +3",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Telos Earring",
        body="Azimuth Coat +3",
        hands="Geo. Mitaines +4",
        ring1="Murky Ring",
        ring2="Chirich Ring +1",
        back="Nantosuelta's Cape",
        waist="Null Belt",
        legs="Azimuth Tights +3",
        feet="Azimuth Gaiters +3"
    }
        
    sets.engaged.DW = {
        ammo="Amar Cluster",
        head="Befouled Crown",
        neck="Asperity Necklace",
        ear1="Dudgeon Earring",
        ear2="Heartseeker Earring",
        body="Mallquis Saio +2",
        hands={ name="Gazu Bracelets +1", augments={'Path: A',}},
        ring1="Hetairoi Ring",
        ring2="Petrov Ring",
        back="Nexus Cape",
        waist="Witful Belt",
        legs="Assid. Pants +1",
        feet="Battlecast Gaiters"
    }

    --------------------------------------
    -- Custom buff sets
    --------------------------------------
    
    -- Gear that converts elemental damage done to recover MP
    sets.RecoverMP = {}  -- original: {body=Samnuha Coat} (Samnuha Coat is not GEO-equippable)
    
    -- Magic Burst mode
    -- LINKTRI 2026-10-24: corrected. Azimuth Tights +3 is Magic burst damage +15 (the capped kind, not "II"); the "II"
    -- piece is Azimuth COAT +3 (MB Dmg II +5), which these sets didn't wear. With the coat in the body slot:
    --   MB dmg (cap 40%): Bunzi's Rod 10 + Agwu's Cap 7 + Agwu's Gages 8 + Agwu's Pigaches 6 + Azimuth Tights 15 = 46, capped
    --   MB dmg II (uncapped): Azimuth Coat +3 = 5  (Agwu's Robe's MB+10 was entirely over the cap)
    sets.MagicBurst = {
        main={ name="Bunzi's Rod", augments={'Path: A',}},  -- MB+10 + MAB+35
        sub="Ammurapi Shield",
        head={ name="Agwu's Cap", augments={'Path: A',}},   -- MB+7 + MAB+50
        neck = "Sibyl Scarf",  -- MB dmg already 41 vs the 40 cap without Mizuchi; Sibyl INT+10 MAB+10 counts; original: "Mizu. Kubikazari" (owned, swapped)
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +2", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+18','Damage taken-7%','INT+11 MND+11',}},
        body="Azimuth Coat +3",  -- MB Dmg II +5, MAB+59 (was Agwu's Robe: MB+10, all over the cap)
        hands={ name="Agwu's Gages", augments={'Path: A',}},  -- MB+8 + MAB+50
        ring1 = { name="Metamor. Ring +1", augments={'Path: A',}},  -- keeps INT/MND+6 from the base nuke set; original: "Stikini Ring" (owned, swapped)
        legs="Azimuth Tights +3",  -- MB dmg +15
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}  -- MB+6 + MAB+50
    }
    sets.ResistantMagicBurst = {
        main={ name="Bunzi's Rod", augments={'Path: A',}},  -- MB+10 + MAB+35
        sub="Ammurapi Shield",
        head={ name="Agwu's Cap", augments={'Path: A',}},   -- MB+7 + MAB+50
        neck="Baetyl Pendant",  -- MagAcc priority for resistant
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +2", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+18','Damage taken-7%','INT+11 MND+11',}},
        body="Azimuth Coat +3",  -- MB Dmg II +5, MAcc+64
        hands={ name="Agwu's Gages", augments={'Path: A',}},  -- MB+8 + MAB+50
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},  -- ring1 side; ring2 Stikini comes from the Resistant nuke set
        legs="Azimuth Tights +3",  -- MB dmg +15
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}  -- MB+6 + MAB+50
    }
    
    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}
    
    -- Weapons sets
    sets.weapons.Maxentius = {main='Maxentius',sub='Genmei Shield'}
    -- original: sets.weapons.DualWeapons = { main={ name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}}, sub={ name="Malevolence", augments={'INT+7','"Mag.Atk.Bns."+5','"Fast Cast"+3',}} }  (only one Malevolence owned)
    sets.weapons.DualWeapons = {main="Idris", sub={ name="Bunzi's Rod", augments={'Path: A',}}}
    sets.weapons.Daybreak = {main='Daybreak',sub='Ammurapi Shield'}
    sets.weapons.Bunzi = {
        main={ name="Bunzi's Rod", augments={'Path: A',}},
        sub="Ammurapi Shield"
    }
    sets.weapons.PetDT = {
        main={ name="Solstice", augments={'Mag. Acc.+20','Pet: Damage taken -4%','"Fast Cast"+5',}},
        sub="Genmei Shield"
    }
    sets.weapons.Skill = {
        main="Malignance Pole",
        sub="Enki Strap"
    }
    -- Ngai fight lockout: Idris/Ammurapi/Dunna, no ammo.
    -- Locked via //gs c ngai (see user_job_self_command). Unlock with //gs c ngai off.
    sets.weapons.Ngai = {
        main="Idris",
        sub="Ammurapi Shield",
        range={ name="Dunna", augments={'MP+20','Mag. Acc.+10','"Fast Cast"+3',}},
        ammo=empty
    }
end

-- Select default macro book on initial load or subjob change.
-- LINKTRI (2026-10-22): /WHM Divine Veil. Divine Seal before a status-removal spell makes it a small-radius AoE
-- that removes the ailment from everyone in the target's party (Divine Veil trait, WHM 50; Sacrifice excluded).
-- Same pattern as WHM.lua's Auto Divine Caress: cancel the spell, use Divine Seal, recast the spell 1.1s later.
-- Divine Seal recast is 10 minutes (recast id 26); when it's down the spell just casts single-target.
--
-- Smart mode counts how many party members (you included) have an ailment the spell removes and are within
-- DV_RADIUS (Linktri-DivineVeil.lua) of the target; Divine Seal is used only when that count is 2 or more.
--   Party members' buffs come from the server's Party Buffs packet (0x076), which covers your own party in your
--   zone. Your own buffs come from player.buffs. Alliance members in other parties aren't visible, so a target
--   outside your party never triggers Divine Seal in Smart mode (use Always mode for those).
-- Party-ailment detection (dv_party_count, DV_RADIUS, DV_REMOVAL_DEBUFFS) lives in Linktri-DivineVeil.lua.


function user_job_precast(spell, spellMap, eventArgs)
    if spell.action_type == 'Magic' and spellMap == 'StatusRemoval' and spell.english ~= 'Sacrifice'
            and player.sub_job == 'WHM' and state.AutoDivineSeal.value ~= 'Off'
            and not buffactive['Divine Seal'] and not buffactive['SJ Restriction'] and not silent_check_amnesia() then
        local abil_recasts = windower.ffxi.get_ability_recasts()
        if abil_recasts[26] and abil_recasts[26] < latency then
            if state.AutoDivineSeal.value == 'Smart' then
                local count = dv_party_count(spell)
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
    set_macro_page(1, 21)
end

-- Sleep -> Lorg Mor (its HP drain wakes you up).
-- LINKTRI 2026-10-24: this used to finish with 'gs c set Weapons None', so a sleep threw away whatever weapon mode you
-- were in - including the Ngai lock (it also re-enabled main/sub) and PetDT. It now puts the previous mode back
-- (re-locking Ngai with //gs c ngai), and does nothing but warn when Lorg Mor isn't in your inventory/wardrobes.
local function lorg_mor_wake(label)
    if not item_available("Lorg Mor") then
        add_to_chat(123, label.." - Lorg Mor isn't in your inventory/wardrobes, so it can't be equipped.")
        return
    end
    local previous = state.Weapons.value
    add_to_chat(123, label.." - forcing Lorg Mor. Weapon mode "..previous.." comes back in 6 seconds.")
    state.Weapons:set('None')
    disable('main', 'sub')
    -- /equip goes straight to the game, so it works even with main/sub disabled (e.g. during the Ngai lock)
    windower.send_command('wait 0.5; input /equip main "Lorg Mor"')
    windower.send_command('wait 1.0; input /equip main "Lorg Mor"')
    local restore = 'wait 6; gs enable main; gs enable sub; gs c set Weapons '..previous
    if previous == 'Ngai' then
        restore = restore..'; gs c ngai on'
    end
    windower.send_command(restore)
end

function user_job_buff_change(buff, gain)
    if buff == 'sleep' and gain then
        lorg_mor_wake("Sleep detected")
    end
end

-- Optional: Add a manual test command
function user_job_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'sleeptest' then
        lorg_mor_wake("Sleep test")
        eventArgs.handled = true

    elseif cmdParams[1]:lower() == 'cardinal' then
        cardinal_command(cmdParams, eventArgs)  -- LINKTRI: moved here from GEO.lua's job_self_command hook
        eventArgs.handled = true

    elseif cmdParams[1]:lower() == 'mb' then
        -- Manual MB window control: //gs c mb [on|off|status]
        local sub = cmdParams[2] and cmdParams[2]:lower() or ''
        if sub == 'on' then
            mb_window_manual(true)
            windower.add_to_chat(121, '[AutoMB] MB window manually opened (any target).')
        elseif sub == 'off' then
            mb_window_manual(false)
            windower.add_to_chat(121, '[AutoMB] MB window manually closed.')
        elseif sub == 'status' then
            windower.add_to_chat(121, '[AutoMB] AutoMBMode: '..tostring(state.AutoMBMode.value)..
                ' | Window open: '..tostring(is_sc_window_open())..
                ' | Weapons: '..state.Weapons.value)
        else
            -- Toggle AutoMBMode
            state.AutoMBMode:toggle()
            windower.add_to_chat(121, '[AutoMB] Auto MB mode: '..(state.AutoMBMode.value and 'ENABLED' or 'DISABLED'))
        end
        eventArgs.handled = true

    elseif cmdParams[1]:lower() == 'ngai' then
        -- Lock weapons for Ngai: Idris/Ammurapi Shield/Dunna/no ammo, never changes.
        -- Usage: //gs c ngai [on|off]  (default: on)
        local sub = cmdParams[2] and cmdParams[2]:lower() or 'on'
        if sub == 'off' then
            enable('main','sub','range','ammo')
            state.Weapons:set('None')
            windower.add_to_chat(123, '[Ngai] Weapon lock disabled. Weapons unlocked.')
        else
            state.Weapons:set('Ngai')
            equip(sets.weapons.Ngai)
            disable('main','sub','range','ammo')
            windower.add_to_chat(123, '[Ngai] Weapons locked: Idris / Ammurapi Shield / Dunna / no ammo.')
        end
        eventArgs.handled = true
    end
end

-- Porter Moogle proximity detection, used by user_job_customize_idle_set (bottom of this file).
function near_porter_moogle()
    local mobs = windower.ffxi.get_mob_array()
    for i, mob in pairs(mobs) do
        if mob.name == "Porter Moogle" and mob.distance and mob.distance < 36 then
            return true
        end
    end
    return false
end

-- Auto Magic Burst: equips MagicBurst or ResistantMagicBurst set when a skillchain
-- window is active and AutoMBMode is enabled.
-- Safeguards:
--   1. state.AutoMBMode must be manually enabled (defaults to false)
--   2. Will not fire when PetDT weapon set is active (protects luopan)
-- Window stays open for full SC_WINDOW_DURATION (8s) to allow multiple bursts.
-- LINKTRI 2026-10-19: renamed from job_post_midcast. The old name replaced GEO.lua's job_post_midcast, which is
-- what equips sets.midcast.Geomancy.Indi (Solstice/Bagua Pants duration) and locks Blaze of Glory gear.
-- Sel runs user_job_post_midcast right after GEO.lua's version, so both now apply.
function user_job_post_midcast(spell, spellMap, eventArgs)
    -- Cure main: Daybreak by default; Raetic Rod +1 (Cure potency II +10%, Cure+50, MP cost +30%)
    -- when Refresh or Ballad is on you. Never touches a locked weapon set.
    if (spellMap == 'Cure' or spellMap == 'Curaga') and state.Weapons.value == 'None'
        and (buffactive['Refresh'] or buffactive['Ballad']) and item_available('Raetic Rod +1') then
        equip({main="Raetic Rod +1"})
    end
    if spell.skill == 'Elemental Magic'
        and state.AutoMBMode.value
        and is_sc_window_open(spell.target and spell.target.id)
        and state.Weapons.value ~= 'PetDT' then
        if state.CastingMode.value == 'Resistant' then
            windower.add_to_chat(121, '[AutoMB] SC window active - equipping ResistantMagicBurst for: '..spell.english)
            equip(sets.ResistantMagicBurst)
        else
            windower.add_to_chat(121, '[AutoMB] SC window active - equipping MagicBurst for: '..spell.english)
            equip(sets.MagicBurst)
        end
    end
end

-- LINKTRI 2026-10-19: Ragelise's Ring is a choose-one mission ring (TVR 11-2, swappable with Ephramad's).
-- Pet idle/defense sets name it; if it isn't in your inventory/wardrobes, use Defending Ring (also DT-10%).
local function ragelise_fallback(set)
    if set and set.ring2 == "Ragelise's Ring" and not item_available("Ragelise's Ring") then
        return set_combine(set, {ring2="Defending Ring"})
    end
    return set
end

-- LINKTRI MODIFICATION (moved here from GEO.lua's job_customize_idle_set on 2026-10-24; same behaviour):
-- near a Porter Moogle, idle in sets.packing. Sel lays sets.Kiting over the idle set AFTER this hook, which would
-- stamp Geo. Sandals +4 over the packing set, so Kiting is blanked while in range and restored on leaving.
local porter_saved_kiting = nil

function user_job_customize_idle_set(idleSet)
    if near_porter_moogle() then
        if not near_porter then
            windower.add_to_chat(160, "Near Porter Moogle - Using packing gear")
            near_porter = true
        end
        if porter_saved_kiting == nil then porter_saved_kiting = sets.Kiting end
        sets.Kiting = {}
        return ragelise_fallback(sets.packing)
    elseif near_porter then
        windower.add_to_chat(160, "Left Porter Moogle area - Returning to normal gear")
        near_porter = false
        sets.Kiting = porter_saved_kiting or {feet="Geo. Sandals +4"}
        porter_saved_kiting = nil
    end
    return ragelise_fallback(idleSet)
end

function user_job_customize_defense_set(defenseSet)
    return ragelise_fallback(defenseSet)
end


-- =========================================================================
-- LINKTRI MODIFICATION (moved here from GEO.lua on 2026-10-24 so GEO.lua stays identical to Selindrile's copy
-- and upstream merges can't conflict with it). Behaviour is unchanged.
-- Cardinal Chant direction display overlay.
--
-- Shows which Cardinal Chant bonus is active based on your position relative to the current target, with blend
-- percentages for off-cardinal angles. Always-on mode keeps it visible without a target.
--   Target East of you -> Mag. Atk. Bonus   | Target North -> Magic Crit Chance
--   Target West of you -> Magic Burst Bonus | Target South -> Mag. Acc. Bonus
-- FFXI coordinates (confirmed in-game): +X = East, +Y = North.
--
-- Hooks: cardinal_init() is called from user_job_setup(); 'cardinal' is handled in user_job_self_command().
-- Commands (//gs c cardinal <subcommand>):
--   //gs c cardinal pos <x> <y>  -- Set and save display position
--   //gs c cardinal show         -- Toggle display on/off (saves state)
--   //gs c cardinal always       -- Toggle always-on mode (saves state)
--   //gs c cardinal reset        -- Reset position to default (100, 100)
-- Config persisted to: <windower>/addons/GearSwap/data/GEO_cardinal_pos.lua
--   Format: return {x=<n>, y=<n>, visible=<bool>, always_on=<bool>}
-- =========================================================================
-- -------------------------------------------------------------------------
-- Config persistence
-- -------------------------------------------------------------------------
local cardinal_config_path = windower.addon_path .. 'data/GEO_cardinal_pos.lua'
local cardinal_defaults     = {x=100, y=100, visible=true, always_on=true}
local cardinal_cfg          = {}
local cardinal_display      = nil  -- texts object, created in cardinal_init()

local function cardinal_load_config()
	local f = io.open(cardinal_config_path, 'r')
	if f then
		local content = f:read('*all')
		f:close()
		local fn = loadstring(content)
		if fn then
			local ok, result = pcall(fn)
			if ok and type(result) == 'table' then
				cardinal_cfg.x         = result.x         or cardinal_defaults.x
				cardinal_cfg.y         = result.y         or cardinal_defaults.y
				cardinal_cfg.visible   = (result.visible   ~= nil) and result.visible   or cardinal_defaults.visible
				cardinal_cfg.always_on = (result.always_on ~= nil) and result.always_on or cardinal_defaults.always_on
				return
			end
		end
	end
	cardinal_cfg.x         = cardinal_defaults.x
	cardinal_cfg.y         = cardinal_defaults.y
	cardinal_cfg.visible   = cardinal_defaults.visible
	cardinal_cfg.always_on = cardinal_defaults.always_on
end

local function cardinal_save_config()
	local f = io.open(cardinal_config_path, 'w')
	if f then
		f:write('return {'
			.. 'x='         .. tostring(cardinal_cfg.x)         .. ', '
			.. 'y='         .. tostring(cardinal_cfg.y)         .. ', '
			.. 'visible='   .. tostring(cardinal_cfg.visible)   .. ', '
			.. 'always_on=' .. tostring(cardinal_cfg.always_on) .. '}\n')
		f:close()
	else
		windower.add_to_chat(123, '[CardinalChant] ERROR: Could not save config to ' .. cardinal_config_path)
	end
end

-- -------------------------------------------------------------------------
-- Initialization (called from job_setup hook above)
-- -------------------------------------------------------------------------
function cardinal_init()
	cardinal_load_config()

	local settings = {
		pos   = {x=cardinal_cfg.x, y=cardinal_cfg.y},
		text  = {font='Arial', size=11},
		flags = {draggable=true},
	}
	cardinal_display = texts.new('${value}', settings)
	cardinal_display:bold(true)
	cardinal_display:bg_alpha(160)
	cardinal_display:bg_color(0, 0, 0)
	cardinal_display:stroke_width(2)
	cardinal_display:stroke_transparency(192)
	cardinal_display:draggable(true)
	cardinal_display:visible(false)  -- prerender controls actual visibility

	-- Save position when drag is released
	windower.register_event('mouse', function(type, x, y)
		-- type 2 = mouse left release
		if type == 2 and cardinal_display then
			local new_x, new_y = cardinal_display:pos()
			if new_x ~= cardinal_cfg.x or new_y ~= cardinal_cfg.y then
				cardinal_cfg.x = new_x
				cardinal_cfg.y = new_y
				cardinal_save_config()
			end
		end
	end)
end

-- -------------------------------------------------------------------------
-- Direction calculation
-- -------------------------------------------------------------------------
-- Cardinal Chant direction: "East" means the TARGET is East of YOU (BG-wiki wording).
-- Vector is calculated FROM me TO target: dx = target.x - me.x, dy = target.y - me.y
-- atan2(dy, dx) where +X=East, +Y=North:
--   0   deg = target is East  of me -> Mag. Atk. Bonus
--   90  deg = target is North of me -> Magic Crit Chance
--   180 deg = target is West  of me -> Magic Burst Bonus
--   270 deg = target is South of me -> Mag. Acc. Bonus

local cardinal_bonuses = {
	[  0] = {dir='East',  arrow='->',  bonus='Mag. Atk. Bonus'},
	[ 90] = {dir='North', arrow='^',   bonus='Magic Crit Chance'},
	[180] = {dir='West',  arrow='<-',  bonus='Magic Burst Bonus'},
	[270] = {dir='South', arrow='v',   bonus='Mag. Acc. Bonus'},
}

local cardinal_colors = {
	['Mag. Atk. Bonus']   = '\\cs(255,120,80)',
	['Magic Crit Chance'] = '\\cs(255,220,50)',
	['Magic Burst Bonus'] = '\\cs(120,180,255)',
	['Mag. Acc. Bonus']   = '\\cs(100,255,160)',
}

local function cardinal_get_direction(me, target)
	local dx = target.x - me.x  -- vector FROM me TO target: positive = target is East of me
	local dy = target.y - me.y  -- positive = target is North of me
	if math.abs(dx) < 0.1 and math.abs(dy) < 0.1 then return nil end

	local angle_deg = math.deg(math.atan2(dy, dx))
	if angle_deg < 0 then angle_deg = angle_deg + 360 end

	local cardinal_angles = {0, 90, 180, 270}
	local lower_angle, upper_angle

	for i = 1, #cardinal_angles do
		local ca       = cardinal_angles[i]
		local next_ca  = cardinal_angles[(i % #cardinal_angles) + 1]
		local next_w   = (i == #cardinal_angles) and 360 or next_ca
		local angle_w  = (i == #cardinal_angles and angle_deg < 45) and angle_deg + 360 or angle_deg
		if angle_w >= ca and angle_w < next_w then
			lower_angle = ca
			upper_angle = next_ca
			break
		end
	end

	if not lower_angle then return nil end

	local offset    = angle_deg - lower_angle
	if offset < 0 then offset = offset + 360 end
	local blend     = offset / 90
	local lower_pct = math.floor((1 - blend) * 100 + 0.5)
	local upper_pct = 100 - lower_pct

	return {
		lower     = cardinal_bonuses[lower_angle],
		upper     = cardinal_bonuses[upper_angle % 360],
		lower_pct = lower_pct,
		upper_pct = upper_pct,
		pure      = (lower_pct >= 95 or upper_pct >= 95),
	}
end

-- Fill bar: 10 chars wide using Unicode block characters
local function cardinal_bar(pct)
	local filled = math.floor(pct / 10 + 0.5)
	return string.rep('█', filled) .. string.rep('░', 10 - filled)
end

local function cardinal_build_display(result, no_target)
	local white = '\\cs(255,255,255)'
	local gray  = '\\cs(180,180,180)'
	local title = '\\cs(200,200,255)  -- Cardinal Chant --\\cs(255,255,255)\n'

	if no_target then
		return title .. gray .. '     (no target)' .. white
	end

	if result.pure then
		local data  = (result.lower_pct >= 95) and result.lower or result.upper
		local color = cardinal_colors[data.bonus] or white
		return title
			.. color .. data.arrow .. ' ' .. data.dir .. white
			.. gray  .. '  [' .. data.bonus .. ']\n'
			.. gray  .. '  ' .. cardinal_bar(100) .. '  100%' .. white
	else
		local c1 = cardinal_colors[result.lower.bonus] or white
		local c2 = cardinal_colors[result.upper.bonus] or white
		return title
			.. c1   .. result.lower.arrow .. ' ' .. result.lower.dir .. white
			.. gray .. '  [' .. result.lower.bonus .. ']\n'
			.. gray .. '  ' .. cardinal_bar(result.lower_pct) .. '  ' .. result.lower_pct .. '%\n'
			.. c2   .. result.upper.arrow .. ' ' .. result.upper.dir .. white
			.. gray .. '  [' .. result.upper.bonus .. ']\n'
			.. gray .. '  ' .. cardinal_bar(result.upper_pct) .. '  ' .. result.upper_pct .. '%'
			.. white
	end
end

-- -------------------------------------------------------------------------
-- prerender update
-- -------------------------------------------------------------------------
windower.register_event('prerender', function()
	if not cardinal_display then return end
	if not cardinal_cfg.visible then
		cardinal_display:visible(false)
		return
	end

	local me = windower.ffxi.get_mob_by_target('me')
	local target = windower.ffxi.get_mob_by_target('t')

	-- Use current selected target (t) as primary source.
	-- This ensures the display updates immediately when you select a different target
	-- rather than persisting on the last mob you had hate on (bt).
	if not me then
		cardinal_display:visible(false)
		return
	end

	if not target then
		if cardinal_cfg.always_on then
			cardinal_display.value = cardinal_build_display(nil, true)
			cardinal_display:visible(true)
		else
			cardinal_display:visible(false)
		end
		return
	end

	local result = cardinal_get_direction(me, target)
	if not result then
		cardinal_display:visible(false)
		return
	end

	cardinal_display.value = cardinal_build_display(result, false)
	cardinal_display:visible(true)
end)

-- -------------------------------------------------------------------------
-- Command handler (called from job_self_command hook above)
-- -------------------------------------------------------------------------
function cardinal_command(commandArgs, eventArgs)
	local sub = commandArgs[2] and commandArgs[2]:lower() or ''

	if sub == 'pos' then
		local x = tonumber(commandArgs[3])
		local y = tonumber(commandArgs[4])
		if x and y then
			cardinal_cfg.x = x
			cardinal_cfg.y = y
			if cardinal_display then cardinal_display:pos(x, y) end
			cardinal_save_config()
			windower.add_to_chat(122, '[CardinalChant] Position set to (' .. x .. ', ' .. y .. ') and saved.')
		else
			windower.add_to_chat(123, '[CardinalChant] Usage: //gs c cardinal pos <x> <y>')
		end

	elseif sub == 'show' then
		cardinal_cfg.visible = not cardinal_cfg.visible
		if cardinal_display then cardinal_display:visible(cardinal_cfg.visible) end
		cardinal_save_config()
		windower.add_to_chat(122, '[CardinalChant] Display ' .. (cardinal_cfg.visible and 'shown' or 'hidden') .. '.')

	elseif sub == 'always' then
		cardinal_cfg.always_on = not cardinal_cfg.always_on
		cardinal_save_config()
		windower.add_to_chat(122, '[CardinalChant] Always-on mode ' .. (cardinal_cfg.always_on and 'enabled' or 'disabled') .. '.')

	elseif sub == 'reset' then
		cardinal_cfg.x         = cardinal_defaults.x
		cardinal_cfg.y         = cardinal_defaults.y
		cardinal_cfg.visible   = cardinal_defaults.visible
		cardinal_cfg.always_on = cardinal_defaults.always_on
		if cardinal_display then
			cardinal_display:pos(cardinal_cfg.x, cardinal_cfg.y)
			cardinal_display:visible(cardinal_cfg.visible)
		end
		cardinal_save_config()
		windower.add_to_chat(122, '[CardinalChant] Reset to defaults.')

	else
		windower.add_to_chat(122, '[CardinalChant] Commands:')
		windower.add_to_chat(122, '  //gs c cardinal pos <x> <y>  -- Set display position')
		windower.add_to_chat(122, '  //gs c cardinal show          -- Toggle visibility')
		windower.add_to_chat(122, '  //gs c cardinal always        -- Toggle always-on mode')
		windower.add_to_chat(122, '  //gs c cardinal reset         -- Reset to defaults')
	end

	eventArgs.handled = true
end

-- LINKTRI MODIFICATION END (Cardinal Chant)
-- =========================================================================
