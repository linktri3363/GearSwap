fixed_pos = ''
fixed_ts = os.time()
local no_interruptions = true
near_porter = false  -- Track if we're near Porter Moogle

-- Skillchain / Magic Burst window tracking
SCWindowOpen = false
SCWindowTimer = 0
SC_WINDOW_DURATION = 8  -- Skillchain window duration in seconds
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

-- Skillchain detection: listens for WS (cat 3), magic finish (cat 4), monster TP move (cat 11).
-- Opens an 8-second MB window when a skillchain is detected via add_effect_message IDs.
-- Skillchain message IDs confirmed from Ivaar's Skillchains addon:
--   288-301: standard skillchains (Light, Darkness, Gravitation, etc.)
--   385-397: higher-tier skillchains (Radiance, Umbra, etc.)
--   767-770: additional skillchain types
function check_skillchain(act)
    if act.category == 3 or act.category == 4 or act.category == 11 then
        for _, target in ipairs(act.targets) do
            for _, action in ipairs(target.actions) do
                local msg = action.add_effect_message
                if msg and (
                    (msg >= 288 and msg <= 301) or
                    (msg >= 385 and msg <= 397) or
                    (msg >= 767 and msg <= 770)
                ) then
                    SCWindowOpen = true
                    SCWindowTimer = os.clock()
                    windower.add_to_chat(121, '[GearSwap] Skillchain detected - MB window OPEN')
                end
            end
        end
    end
end

-- Returns true if currently within the skillchain MB window
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

windower.raw_register_event('action', function(act)
    check_skillchain(act)
end)

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
    sets.precast.FC = {
        main=gear.grioavolr_fc_staff,
        sub="Clerisy Strap +1",
        ammo="Impatiens",
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5',"CHR+4","Mag. Acc.+14",'"Mag.Atk.Bns."+15',}},
        neck="Voltsurge Torque",
        ear1="Loquac. Earring",
        ear2="Malignance Earring",
        body={ name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25',"CHR+2","Mag. Acc.+11",'"Mag.Atk.Bns."+9',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back=gear.fc_jse_back,
        waist="Witful Belt",
        legs="Gyve Trousers",
        feet={ name="Regal Pumps +1", augments={'Path: A',}}
    }

    -- Geomancy precast: equip Dunna in range slot for FC+3 contribution
    sets.precast.FC.Geomancy = set_combine(sets.precast.FC, {
        range={ name="Dunna", augments={'MP+20','Mag. Acc.+10','"Fast Cast"+3',}},
        ammo=empty
    })

    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {
        ear2="Malignance Earring",
        hands="Bagua Mitaines +4"
    })

    sets.precast.FC.Cure = set_combine(sets.precast.FC, {
        main=gear.gada_healing_club,
        sub="Sors Shield",
        body={ name="Vanya Robe", augments={'MP+50','"Cure" potency +7%','Enmity-6',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        legs="Geomancy Pants +4",
        feet={ name="Medium's Sabots", augments={'MP+50','MND+10','"Conserve MP"+7','"Cure" potency +5%',}}
    })
        
    sets.precast.FC.Curaga = sets.precast.FC.Cure
    
    -- Healing and Refresh sets
    sets.Self_Healing = {neck="Unmoving Collar",ring1="Stikini Ring",ring2="Lebeche Ring",waist="Witful Belt"}
    sets.Cure_Received = {neck="Unmoving Collar",ring1="Stikini Ring",ring2="Lebeche Ring",waist="Witful Belt"}
    sets.Self_Refresh = {back="Nantosuelta's Cape",waist="Witful Belt",feet="Inspirited Boots"}
    
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})
    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {})

    sets.precast.FC.Impact = {
        ammo="Impatiens",
        head=empty,
        neck="Voltsurge Torque",
        ear1="Loquac. Earring",
        ear2="Malignance Earring",
        body="Twilight Cape",
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back=gear.fc_jse_back,
        waist="Witful Belt",
        legs="Gyve Trousers",
        feet={ name="Regal Pumps +1", augments={'Path: A',}}
    }
        
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main="Daybreak",sub="Ammurapi Shield"})
    
    -- Weaponskill sets
    sets.precast.WS = {
        ammo={ name="Coiste Bodhar", augments={'Path: A',}},
        head={ name="Nyame Helm", augments={'Path: B',}},
        neck="Light Gorget",
        ear1="Ishvara Earring",
        ear2={ name="Moonshade Earring", augments={'Accuracy+4','Latent effect: "Regain"+1',}},
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
        ammo={ name="Coiste Bodhar", augments={'Path: A',}},
        head={ name="Nyame Helm", augments={'Path: B',}},
        neck="Light Gorget",
        ear1="Brutal Earring",
        ear2={ name="Moonshade Earring", augments={'Accuracy+4','Latent effect: "Regain"+1',}},
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
        ear1="Loquac. Earring",
        ear2="Malignance Earring",
        body={ name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25',"CHR+2","Mag. Acc.+11",'"Mag.Atk.Bns."+9',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back=gear.fc_jse_back,
        waist="Witful Belt",
        legs="Gyve Trousers",
        feet={ name="Regal Pumps +1", augments={'Path: A',}}
    }

    -- GEOMANCY CASTING SETS
    -- Geo. Galero +4 added for head (Elemental magic skill +19, Haste+6%, Cardinal Chant+4)
    -- Geo. Mitaines +4 corrected from +2
    -- Idris in main for Geomancy potency (in upgrade, will be available)
    sets.midcast.Geomancy = {
        main="Idris",
        sub="Genmei Shield",
        range={ name="Dunna", augments={'MP+20','Mag. Acc.+10','"Fast Cast"+3',}},
        head="Geo. Galero +4",
        neck={ name="Bagua Charm +2", augments={'Path: A',}},
        ear1="Malignance Earring",
        ear2="Azimuth Earring +2",
        body="Geo. Tunic +4",
        hands="Geo. Mitaines +4",
        ring1="Stikini Ring",
        ring2={ name="Murky Ring", augments={'Path: A',}},
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
        main=gear.gada_healing_club,
        sub="Sors Shield",
        ammo="Hydrocera",
        head="Azimuth Hood +3",
        neck="Nodens Gorget",
        ear1="Meili Earring",
        ear2="Alabaster Earring",
        body={ name="Vanya Robe", augments={'MP+50','"Cure" potency +7%','Enmity-6',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Stikini Ring",
        ring2="Lebeche Ring",
        back="Twilight Cape",
        waist="Witful Belt",
        legs="Geomancy Pants +4",
        feet={ name="Medium's Sabots", augments={'MP+50','MND+10','"Conserve MP"+7','"Cure" potency +5%',}}
    }
        
    sets.midcast.LightWeatherCure = {
        main="Chatoyant Staff",
        sub="Clerisy Strap +1",
        ammo="Hydrocera",
        head="Azimuth Hood +3",
        neck="Unmoving Collar",
        ear1="Meili Earring",
        ear2="Alabaster Earring",
        body={ name="Vanya Robe", augments={'MP+50','"Cure" potency +7%','Enmity-6',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Stikini Ring",
        ring2="Lebeche Ring",
        back="Twilight Cape",
        waist="Hachirin-no-Obi",
        legs="Geomancy Pants +4",
        feet={ name="Medium's Sabots", augments={'MP+50','MND+10','"Conserve MP"+7','"Cure" potency +5%',}}
    }
        
    sets.midcast.LightDayCure = {
        main=gear.gada_healing_club,
        sub="Sors Shield",
        ammo="Hydrocera",
        head="Azimuth Hood +3",
        neck="Nodens Gorget",
        ear1="Meili Earring",
        ear2="Alabaster Earring",
        body={ name="Vanya Robe", augments={'MP+50','"Cure" potency +7%','Enmity-6',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Stikini Ring",
        ring2="Lebeche Ring",
        back="Twilight Cape",
        waist="Hachirin-no-Obi",
        legs="Geomancy Pants +4",
        feet={ name="Medium's Sabots", augments={'MP+50','MND+10','"Conserve MP"+7','"Cure" potency +5%',}}
    }

    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {main="Daybreak",sub="Sors Shield"})

    sets.midcast.Cursna = set_combine(sets.midcast.Cure, {
        neck="Unmoving Collar",
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        back="Twilight Cape",
        ring1="Stikini Ring",
        ring2="Lebeche Ring",
        waist="Witful Belt",
        feet={ name="Medium's Sabots", augments={'MP+50','MND+10','"Conserve MP"+7','"Cure" potency +5%',}}
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
        ammo={ name="Coiste Bodhar", augments={'Path: A',}},  -- upgrade to Ghastly Tathlum +1 when acquired
        head={ name="Agwu's Cap", augments={'Path: A',}},
        neck="Baetyl Pendant",  -- MAB+13 beats Sibyl Scarf (INT+10/MAB+10)
        ear1="Malignance Earring",  -- INT+8/MAB+8/MagAcc+10/FC+4% beats Crematio
        ear2={ name="Azimuth Earring +2", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+18','Damage taken-7%','INT+11 MND+11',}},
        body="Azimuth Coat +3",  -- upgraded from Agwu's Robe per BG-wiki BIS
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},  -- BIS ring1 per BG-wiki
        ring2="Lebeche Ring",  -- upgrade to Freke Ring when acquired
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
        ring1="Stikini Ring",
        ring2={ name="Metamor. Ring +1", augments={'Path: A',}},
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
        ear2="Loquac. Earring",
        body={ name="Samnuha Coat", augments={'Mag. Acc.+8','"Mag.Atk.Bns."+11','"Dual Wield"+2',}},
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
        ammo={ name="Coiste Bodhar", augments={'Path: A',}},
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5',"CHR+4","Mag. Acc.+14",'"Mag.Atk.Bns."+15',}},
        neck="Baetyl Pendant",  -- MAB+13 beats Sibyl Scarf
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +2", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+18','Damage taken-7%','INT+11 MND+11',}},
        body={ name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25',"CHR+2","Mag. Acc.+11",'"Mag.Atk.Bns."+9',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Stikini Ring",
        ring2="Lebeche Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4',"Mag. Acc.+6",'"Mag.Atk.Bns."+14',}}
    }
        
    sets.midcast['Elemental Magic'].HighTierNuke = {
        main={ name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}},
        sub="Ammurapi Shield",
        ammo={ name="Coiste Bodhar", augments={'Path: A',}},  -- upgrade to Ghastly Tathlum +1 when acquired
        head={ name="Agwu's Cap", augments={'Path: A',}},
        neck="Baetyl Pendant",
        ear1="Malignance Earring",  -- upgrade to Regal Earring when acquired
        ear2="Azimuth Earring +2",
        body="Azimuth Coat +3",  -- upgraded from Agwu's Robe per BG-wiki BIS
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Lebeche Ring",  -- upgrade to Freke Ring when acquired
        back=gear.nuke_jse_back,
        waist="Eschan Stone",  -- upgrade to Acuity Belt +1 when acquired
        legs="Azimuth Tights +3",  -- upgraded from Agwu's Slops per BG-wiki BIS
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}
    }
        
    sets.midcast['Elemental Magic'].HighTierNuke.Resistant = {
        main={ name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}},
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head={ name="Agwu's Cap", augments={'Path: A',}},  -- MagAcc+40/FC+5% beats Azimuth Hood DT-12%
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +2", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+18','Damage taken-7%','INT+11 MND+11',}},
        body="Azimuth Coat +3",
        hands="Azimuth Gloves +3",
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Lebeche Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Azimuth Tights +3",
        feet="Azimuth Gaiters +3"
    }

    sets.midcast['Elemental Magic'].HighTierNuke.Fodder = {
        main={ name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}},
        sub="Ammurapi Shield",
        ammo={ name="Coiste Bodhar", augments={'Path: A',}},  -- upgrade to Ghastly Tathlum +1 when acquired
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5',"CHR+4","Mag. Acc.+14",'"Mag.Atk.Bns."+15',}},
        neck="Baetyl Pendant",  -- MAB+13 beats Sibyl Scarf
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +2", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+18','Damage taken-7%','INT+11 MND+11',}},
        body="Azimuth Coat +3",  -- upgraded from Merlinic Jubbah per BG-wiki BIS
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Lebeche Ring",  -- upgrade to Freke Ring when acquired
        back=gear.nuke_jse_back,
        waist="Eschan Stone",  -- upgrade to Acuity Belt +1 when acquired
        legs="Azimuth Tights +3",  -- upgraded from Agwu's Slops per BG-wiki BIS
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}
    }

    -- DARK MAGIC SETS
    sets.midcast['Dark Magic'] = {
        main={ name="Rubicundity", augments={'Mag. Acc.+10','"Mag.Atk.Bns."+10','Dark magic skill +10','"Conserve MP"+7',}},
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head={ name="Agwu's Cap", augments={'Path: A',}},
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Azimuth Earring +2",
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Stikini Ring",
        ring2={ name="Metamor. Ring +1", augments={'Path: A',}},
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4',"Mag. Acc.+6",'"Mag.Atk.Bns."+14',}}
    }
        
    -- Drain/Aspir: use merlinic_aspir_feet for Drain/Aspir potency +10
    sets.midcast.Drain = {
        main={ name="Rubicundity", augments={'Mag. Acc.+10','"Mag.Atk.Bns."+10','Dark magic skill +10','"Conserve MP"+7',}},
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head="Befouled Crown",
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Azimuth Earring +2",
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Stikini Ring",
        ring2="Lebeche Ring",
        back=gear.nuke_jse_back,
        waist="Fucho-no-Obi",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet=gear.merlinic_aspir_feet
    }
    
    sets.midcast.Aspir = sets.midcast.Drain
        
    sets.midcast.Stun = {
        main=gear.grioavolr_fc_staff,
        sub="Clerisy Strap +1",
        ammo="Pemphredo Tathlum",
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5',"CHR+4","Mag. Acc.+14",'"Mag.Atk.Bns."+15',}},
        neck="Voltsurge Torque",
        ear1="Loquac. Earring",
        ear2="Malignance Earring",
        body={ name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25',"CHR+2","Mag. Acc.+11",'"Mag.Atk.Bns."+9',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Stikini Ring",
        ring2={ name="Metamor. Ring +1", augments={'Path: A',}},
        back=gear.fc_jse_back,
        waist="Witful Belt",
        legs="Gyve Trousers",
        feet={ name="Regal Pumps +1", augments={'Path: A',}}
    }
        
    sets.midcast.Stun.Resistant = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head={ name="Agwu's Cap", augments={'Path: A',}},
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Azimuth Earring +2",
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Stikini Ring",
        ring2={ name="Metamor. Ring +1", augments={'Path: A',}},
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4',"Mag. Acc.+6",'"Mag.Atk.Bns."+14',}}
    }
        
    sets.midcast.Impact = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head=empty,
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Azimuth Earring +2",
        body="Twilight Cape",
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Stikini Ring",
        ring2={ name="Metamor. Ring +1", augments={'Path: A',}},
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}
    }
        
    sets.midcast.Dispel = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head={ name="Agwu's Cap", augments={'Path: A',}},
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Azimuth Earring +2",
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Stikini Ring",
        ring2={ name="Metamor. Ring +1", augments={'Path: A',}},
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4',"Mag. Acc.+6",'"Mag.Atk.Bns."+14',}}
    }

    sets.midcast.Dispelga = set_combine(sets.midcast.Dispel, {main="Daybreak",sub="Ammurapi Shield"})
        
    -- ENFEEBLING MAGIC SETS
    sets.midcast['Enfeebling Magic'] = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head="Befouled Crown",
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Alabaster Earring",
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Stikini Ring",
        ring2="Kishar Ring",
        back=gear.nuke_jse_back,
        waist="Luminary Sash",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4',"Mag. Acc.+6",'"Mag.Atk.Bns."+14',}}
    }
        
    sets.midcast['Enfeebling Magic'].Resistant = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head="Befouled Crown",
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Alabaster Earring",
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Stikini Ring",
        ring2={ name="Metamor. Ring +1", augments={'Path: A',}},
        back=gear.nuke_jse_back,
        waist="Luminary Sash",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4',"Mag. Acc.+6",'"Mag.Atk.Bns."+14',}}
    }
        
    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {
        head={ name="Agwu's Cap", augments={'Path: A',}},
        ear2="Azimuth Earring +2",
        waist="Eschan Stone"
    })
    sets.midcast.ElementalEnfeeble.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {
        head={ name="Agwu's Cap", augments={'Path: A',}},
        ear2="Azimuth Earring +2",
        waist="Eschan Stone"
    })
    
    sets.midcast.IntEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {
        head={ name="Agwu's Cap", augments={'Path: A',}},
        ear2="Azimuth Earring +2",
        waist="Eschan Stone"
    })
    sets.midcast.IntEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {
        head={ name="Agwu's Cap", augments={'Path: A',}},
        ear2="Azimuth Earring +2",
        waist="Eschan Stone"
    })
    
    sets.midcast.MndEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {range=empty,ring1="Stikini Ring"})
    sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {range=empty,ring1="Stikini Ring"})
    
    sets.midcast.Dia = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast['Dia II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    
    sets.midcast.Bio = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast['Bio II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    
    sets.midcast['Divine Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {ring1="Stikini Ring"})
        
    -- ENHANCING MAGIC SETS
    sets.midcast['Enhancing Magic'] = {
        main=gear.gada_enhancing_club,
        sub="Ammurapi Shield",
        ammo="Hydrocera",
        head={ name="Telchine Cap", augments={'Mag. Acc.+20','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        neck="Nodens Gorget",
        ear1="Andoaa Earring",
        ear2="Malignance Earring",
        body={ name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        hands={ name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        ring1="Stikini Ring",
        ring2="Kishar Ring",
        back="Twilight Cape",
        waist="Embla Sash",
        legs={ name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        feet={ name="Telchine Pigaches", augments={'Mag. Acc.+18','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}}
    }
        
    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
        neck="Nodens Gorget",
        ear2="Alabaster Earring",
        waist="Siegel Sash"
    })
    
    sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {
        head={ name="Agwu's Cap", augments={'Path: A',}}
    })
    
    sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {
        main="Chatoyant Staff",
        sub="Clerisy Strap +1",
        head={ name="Agwu's Cap", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}}
    })
    
    sets.midcast.BarElement = set_combine(sets.precast.FC['Enhancing Magic'], {})
    
    sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {
        ear1="Malignance Earring",
        ear2="Azimuth Earring +2",
        waist="Sacro Cord"
    })
    sets.midcast.Protectra = set_combine(sets.midcast['Enhancing Magic'], {
        ear1="Malignance Earring",
        ear2="Azimuth Earring +2",
        waist="Sacro Cord"
    })
    sets.midcast.Shell = set_combine(sets.midcast['Enhancing Magic'], {
        ear1="Malignance Earring",
        ear2="Azimuth Earring +2",
        waist="Sacro Cord"
    })
    sets.midcast.Shellra = set_combine(sets.midcast['Enhancing Magic'], {
        ear1="Malignance Earring",
        ear2="Azimuth Earring +2",
        waist="Sacro Cord"
    })

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
        ring2="Lebeche Ring",
        back="Nantosuelta's Cape",
        legs="Assid. Pants +1",
        feet="Mallquis Clogs +2"
    }

 
    sets.idle = {
        main="Idris",
        sub="Ammurapi Shield",
        ammo="Homiliary",
        head="Null Masque",
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Alabaster Earring",
        ear2="Azimuth Earring +2",
        body="Azimuth Coat +3",
        hands="Azimuth Gloves +3",
        ring1="Stikini Ring",
        ring2={ name="Murky Ring", augments={'Path: A',}},
        back="Nantosuelta's Cape",
        waist="Carrier's Sash",
        legs="Assid. Pants +1",
        feet="Azimuth Gaiters +3"
    }
        
    sets.idle.PDT = {
        main="Malignance Pole",
        sub="Umbra Strap",
        ammo="Homiliary",
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
        ring2="Ragelise's Ring",
        back="Moonlight Cape",
        waist="Plat. Mog. Belt",
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
        ring2="Ragelise's Ring",
        back="Moonlight Cape",
        waist="Plat. Mog. Belt",
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

    -- Indi idle sets: Bagua Pants +4 in all for enhanced Indi duration
    sets.idle.Indi = set_combine(sets.idle, {legs="Bagua Pants +4"})
    sets.idle.Pet.Indi = set_combine(sets.idle.Pet, {legs="Bagua Pants +4"})
    sets.idle.PDT.Indi = set_combine(sets.idle.PDT, {legs="Bagua Pants +4"})
    sets.idle.PDT.Pet.Indi = set_combine(sets.idle.PDT.Pet, {legs="Bagua Pants +4"})

    sets.idle.Weak = {
        main="Chatoyant Staff",
        sub="Clerisy Strap +1",
        ammo="Homiliary",
        head="Befouled Crown",
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Alabaster Earring",
        ear2="Relaxing Earring",
        body="Mallquis Saio +2",
        hands="Mallquis Cuffs +2",
        ring1={ name="Murky Ring", augments={'Path: A',}},
        ring2="Lebeche Ring",
        back="Nantosuelta's Cape",
        waist="Carrier's Sash",
        legs="Assid. Pants +1",
        feet="Mallquis Clogs +2"
    }

    -- Porter Moogle packing set
    sets.packing = {
        main={ name="Mpaca's Staff", augments={'Path: A',}},
        sub="Umbra Strap",
        ammo="Homiliary",
        head="Null Masque",
        neck="Sibyl Scarf",
        ear1="Alabaster Earring",
        ear2="Relaxing Earring",
        body={ name="Nyame Mail", augments={'Path: B',}},
        hands={ name="Nyame Gauntlets", augments={'Path: B',}},
        ring1="Stikini Ring",
        ring2={ name="Murky Ring", augments={'Path: A',}},
        back=gear.idle_jse_back,
        waist="Fucho-no-Obi",
        legs="Assid. Pants +1",
        feet={ name="Nyame Sollerets", augments={'Path: B',}}
    }

    -- Defense sets
    sets.defense.PDT = {
        main="Malignance Pole",
        sub="Umbra Strap",
        ammo="Homiliary",
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
        ammo="Homiliary",
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
        ammo="Homiliary",
        head="Mall. Chapeau +2",
        neck="Unmoving Collar",
        ear1="Alabaster Earring",
        ear2="Sanare Earring",
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        ring1="Vengeful Ring",
        ring2="Lebeche Ring",
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
    sets.TreasureHunter = {feet={ name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Treasure Hunter"+2',"Mag. Acc.+6",'"Mag.Atk.Bns."+14',}}}
    
    sets.HPDown = {
        head="Befouled Crown",
        ear1="Relaxing Earring",
        ear2="Alabaster Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Stikini Ring",
        ring2="Mephitas's Ring",
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
    sets.RecoverMP = {body={ name="Samnuha Coat", augments={'Mag. Acc.+8','"Mag.Atk.Bns."+11','"Dual Wield"+2',}}}
    
    -- Magic Burst mode
    -- MB dmg toward 40% cap: Bunzi's Rod(+10) + Agwu's Cap(+7) + Agwu's Robe(+10)
    --   + Agwu's Gages(+8) + Agwu's Pigaches(+6) = +41%, at cap.
    -- MB Dmg II (uncapped, multiplicative): Azimuth Tights +3 (+5).
    sets.MagicBurst = {
        main={ name="Bunzi's Rod", augments={'Path: A',}},  -- MB+10 + MAB+35
        sub="Ammurapi Shield",
        head={ name="Agwu's Cap", augments={'Path: A',}},   -- MB+7 + MAB+50
        neck="Mizu. Kubikazari",
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +2", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+18','Damage taken-7%','INT+11 MND+11',}},
        body={ name="Agwu's Robe", augments={'Path: A',}},  -- MB+10 + MAB+50
        hands={ name="Agwu's Gages", augments={'Path: A',}},  -- MB+8 + MAB+50
        ring1="Stikini Ring",
        legs="Azimuth Tights +3",  -- MB Dmg II+5 (uncapped, multiplicative)
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}  -- MB+6 + MAB+50
    }
    sets.ResistantMagicBurst = {
        main={ name="Bunzi's Rod", augments={'Path: A',}},  -- MB+10 + MAB+35
        sub="Ammurapi Shield",
        head={ name="Agwu's Cap", augments={'Path: A',}},   -- MB+7 + MAB+50
        neck="Baetyl Pendant",  -- MagAcc priority for resistant
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +2", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+18','Damage taken-7%','INT+11 MND+11',}},
        body={ name="Agwu's Robe", augments={'Path: A',}},  -- MB+10 + MAB+50
        hands={ name="Agwu's Gages", augments={'Path: A',}},  -- MB+8 + MAB+50
        ring1="Stikini Ring",
        legs="Azimuth Tights +3",  -- MB Dmg II+5 (uncapped, multiplicative)
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}  -- MB+6 + MAB+50
    }
    
    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}
    
    -- Weapons sets
    sets.weapons.Maxentius = {main='Maxentius',sub='Genmei Shield'}
    sets.weapons.DualWeapons = {
        main={ name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}},
        sub={ name="Malevolence", augments={'INT+7','"Mag.Atk.Bns."+5','"Fast Cast"+3',}}
    }
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
function select_default_macro_book()
    set_macro_page(1, 21)
end

-- Sleep detection function
function user_job_buff_change(buff, gain)
    if buff == 'sleep' and gain then
        add_to_chat(123, "Sleep detected! Forcing Lorg Mor equip...")
        
        -- Force weapon state change and direct equip
        state.Weapons:set('None')
        disable('main')
        disable('sub')
        
        -- Force equip with multiple attempts
        equip({main = "Lorg Mor"})
        windower.send_command('wait 0.5; input /equip main "Lorg Mor"')
        windower.send_command('wait 1.0; input /equip main "Lorg Mor"')
        
        -- Reset after delay
        windower.send_command('wait 6; gs enable main; gs enable sub; gs c set Weapons None')
        add_to_chat(123, "Lorg Mor force equipped. Will reset weapon state in 6 seconds.")
    end
end

-- Optional: Add a manual test command
function user_job_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'sleeptest' then
        add_to_chat(123, "Sleep test: Forcing Lorg Mor equip...")
        state.Weapons:set('None')
        disable('main')
        disable('sub')
        equip({main = "Lorg Mor"})
        windower.send_command('wait 0.5; input /equip main "Lorg Mor"')
        windower.send_command('wait 1.0; input /equip main "Lorg Mor"')
        windower.send_command('wait 6; gs enable main; gs enable sub; gs c set Weapons None')
        add_to_chat(123, "Lorg Mor force equipped. Will reset in 6 seconds.")
        eventArgs.handled = true

    elseif cmdParams[1]:lower() == 'mb' then
        -- Manual MB window control: //gs c mb [on|off|status]
        local sub = cmdParams[2] and cmdParams[2]:lower() or ''
        if sub == 'on' then
            SCWindowOpen = true
            SCWindowTimer = os.clock()
            windower.add_to_chat(121, '[AutoMB] MB window manually opened.')
        elseif sub == 'off' then
            SCWindowOpen = false
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

-- Porter Moogle proximity detection function.
-- Called by job_customize_idle_set in GEO.lua (see LINKTRI MODIFICATION block there).
-- near_porter global (line 4) and this function must remain in the gear file
-- as GEO.lua references both at runtime.
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
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Elemental Magic'
        and state.AutoMBMode.value
        and is_sc_window_open()
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