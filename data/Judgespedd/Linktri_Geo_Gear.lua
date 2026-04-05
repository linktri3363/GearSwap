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

function user_job_setup()
    -- Updated and optimized to use your actual inventory!
    -- Excellent gear including Mallquis +2, Bagua +1, Geo +1, Agwu's, and more
    
    -- Options: Override default values
    state.OffenseMode:options('Normal')
    state.CastingMode:options('Normal', 'Resistant', 'Fodder', 'Proc')
    state.IdleMode:options('Normal','PDT','Pet','PetDT')
    state.PhysicalDefenseMode:options('PDT', 'NukeLock', 'GeoLock', 'PetPDT')
    state.MagicalDefenseMode:options('MDT', 'NukeLock')
    state.ResistDefenseMode:options('MEVA')
    state.Weapons:options('None','Maxentius','DualWeapons','Daybreak','Bunzi','PetDT','Skill')

    -- Custom Capes (using your available Nantosuelta's Cape)
    gear.nuke_jse_back = {name="Nantosuelta's Cape",augments={'Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','Pet: "Regen"+10','Pet: Damage taken -5%'}}
    gear.idle_jse_back = {name="Nantosuelta's Cape",augments={'Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','Pet: "Regen"+10','Pet: Damage taken -5%'}}
    gear.fc_jse_back = {name="Nantosuelta's Cape",augments={'Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','Pet: "Regen"+10','Pet: Damage taken -5%'}}
    
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
    
    indi_duration = 290
    
    select_default_macro_book()
end

function init_gear_sets()
    
    --------------------------------------
    -- Precast sets
    --------------------------------------

    -- Precast sets to enhance JAs (Using your actual Bagua and Geo gear!)
    sets.precast.JA.Bolster = {body="Bagua Tunic +1"}
    sets.precast.JA['Life Cycle'] = {body="Jhakri Robe +2",back=gear.idle_jse_back}
    sets.precast.JA['Radial Arcana'] = {feet="Bagua Sandals +1"}
    sets.precast.JA['Mending Halation'] = {legs="Bagua Pants +1"}
    sets.precast.JA['Full Circle'] = {
        head="Bagua Galero +1",
        hands="Bagua Mitaines +1"
    }
    sets.precast.JA['Ecliptic Attrition'] = {head="Jhakri Coronal +2"}
    sets.precast.JA['Blaze of Glory'] = {head="Bagua Galero +1"}
    sets.precast.JA['Dematerialize'] = {head="Bagua Galero +1"}
    
    -- Indi Duration and Entrust
    sets.buff.Entrust = {}
    sets.buff['Blaze of Glory'] = {head="Bagua Galero +1"}
    
    -- OPTIMIZED Fast cast sets using your inventory (NO BUNZI'S - SCHOLAR ONLY)
    sets.precast.FC = {
        main={ name="Grioavolr", augments={'AGI+2','Spell interruption rate down -6%','"Fast Cast"+7','Magic Damage +1',}},
        sub="Clerisy Strap +1",
        ammo="Impatiens",
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5','CHR+4','Mag. Acc.+14','"Mag.Atk.Bns."+15',}},
        neck="Voltsurge Torque",
        ear1="Loquac. Earring",
        ear2="Malignance Earring",
        body={ name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9',}},
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back=gear.fc_jse_back,
        waist="Witful Belt",
        legs={ name="Rawhide Trousers", augments={'MP+50','"Fast Cast"+5','"Refresh"+1',}},
        feet={ name="Regal Pumps +1", augments={'Path: A',}}
    }

    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {
        ear2="Malignance Earring",
        hands="Bagua Mitaines +1"
    })

    sets.precast.FC.Cure = set_combine(sets.precast.FC, {
        main={ name="Gada", augments={'Enh. Mag. eff. dur. +6','"Mag.Atk.Bns."+9','DMG:+13',}},
        sub="Sors Shield",
        body={ name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands={ name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        legs={ name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        feet={ name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    })
        
    sets.precast.FC.Curaga = sets.precast.FC.Cure
    
    -- Healing and Refresh sets
    sets.Self_Healing = {neck="Unmoving Collar",ring1="Stikini Ring",ring2="Lebeche Ring",waist="Witful Belt"}
    sets.Cure_Received = {neck="Unmoving Collar",ring1="Stikini Ring",ring2="Lebeche Ring",waist="Witful Belt"}
    sets.Self_Refresh = {back="Umbra Cape",waist="Witful Belt",feet="Inspirited Boots"}
    
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})
    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {})

    sets.precast.FC.Impact = {
        ammo="Impatiens",
        head=empty,
        neck="Voltsurge Torque",
        ear1="Loquac. Earring",
        ear2="Malignance Earring",
        body="Twilight Cape",
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back=gear.fc_jse_back,
        waist="Witful Belt",
        legs={ name="Rawhide Trousers", augments={'MP+50','"Fast Cast"+5','"Refresh"+1',}},
        feet={ name="Regal Pumps +1", augments={'Path: A',}}
    }
        
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main="Daybreak",sub="Ammurapi Shield"})
    
    -- IMPROVED Weaponskill sets using your available Nyame gear
    sets.precast.WS = {
        ammo={ name="Coiste Bodhar", augments={'Path: A',}},
        head={ name="Nyame Helm", augments={'Path: B',}},
        neck="Light Gorget",
        ear1="Ishvara Earring",
        ear2={ name="Moonshade Earring", augments={'Accuracy+4','Latent effect: "Regain"+1',}},
        body={ name="Nyame Mail", augments={'Path: B',}},
        hands={ name="Nyame Gauntlets", augments={'Path: B',}},
        ring1="Epona's Ring",
        ring2="Lebeche Ring",
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
        ring1="Epona's Ring",
        ring2="Lebeche Ring",
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
        main={ name="Grioavolr", augments={'AGI+2','Spell interruption rate down -6%','"Fast Cast"+7','Magic Damage +1',}},
        sub="Clerisy Strap +1",
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5','CHR+4','Mag. Acc.+14','"Mag.Atk.Bns."+15',}},
        neck="Voltsurge Torque",
        ear1="Loquac. Earring",
        ear2="Malignance Earring",
        body={ name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9',}},
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back=gear.fc_jse_back,
        waist="Witful Belt",
        legs={ name="Rawhide Trousers", augments={'MP+50','"Fast Cast"+5','"Refresh"+1',}},
        feet={ name="Regal Pumps +1", augments={'Path: A',}}
    }

    -- MAXED Geomancy casting sets - 900+ skill for maximum potency!
    sets.midcast.Geomancy = {
        main="Malignance Pole",
        sub="Enki Strap",
        range={ name="Dunna", augments={'MP+20','Mag. Acc.+10','"Fast Cast"+3',}},
        head="Azimuth Hood +2",
        neck="Incanter's Torque",
        ear1="Gifted Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        body="Geo. Tunic +1",
        hands="Geo. Mitaines +1",
        ring1="Stikini Ring",
        ring2={ name="Murky Ring", augments={'Path: A',}}, 
        back="Lifestream Cape",
        waist="Luminary Sash",
        legs="Geo. Pants +1",
        feet="Azimuth Gaiters +2"
    }

    sets.midcast.Geomancy.Indi = set_combine(sets.midcast.Geomancy, {
        head="Azimuth Hood +2",
        back=gear.idle_jse_back,
        legs="Bagua Pants +1",
        feet="Azimuth Gaiters +2"
    })
        
    -- OPTIMIZED Cure sets using your Kaykaus gear
    sets.midcast.Cure = {
        main={ name="Gada", augments={'Enh. Mag. eff. dur. +6','"Mag.Atk.Bns."+9','DMG:+13',}},
        sub="Sors Shield",
        ammo="Hydrocera",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck="Incanter's Torque",
        ear1="Gifted Earring",
        ear2="Etiolation Earring",
        body={ name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands={ name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1="Stikini Ring",
        ring2="Lebeche Ring",
        back="Twilight Cape",
        waist="Witful Belt",
        legs={ name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        feet={ name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }
        
    sets.midcast.LightWeatherCure = {
        main="Chatoyant Staff",
        sub="Clerisy Strap +1",
        ammo="Hydrocera",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck="Unmoving Collar",
        ear1="Gifted Earring",
        ear2="Etiolation Earring",
        body={ name="Vanya Robe", augments={'MP+50','"Cure" potency +7%','Enmity-6',}},
        hands={ name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1="Stikini Ring",
        ring2="Lebeche Ring",
        back="Twilight Cape",
        waist="Hachirin-no-Obi",
        legs={ name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        feet={ name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }
        
    sets.midcast.LightDayCure = {
        main={ name="Gada", augments={'Enh. Mag. eff. dur. +6','"Mag.Atk.Bns."+9','DMG:+13',}},
        sub="Sors Shield",
        ammo="Hydrocera",
        head={ name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        neck="Incanter's Torque",
        ear1="Gifted Earring",
        ear2="Etiolation Earring",
        body={ name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
        hands={ name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20',}},
        ring1="Stikini Ring",
        ring2="Lebeche Ring",
        back="Twilight Cape",
        waist="Hachirin-no-Obi",
        legs={ name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%',}},
        feet={ name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    }

    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {main="Daybreak",sub="Sors Shield"})

    sets.midcast.Cursna = set_combine(sets.midcast.Cure, {
        neck="Unmoving Collar",
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        back="Twilight Cape",
        ring1="Stikini Ring",
        ring2="Lebeche Ring",
        waist="Witful Belt",
        feet={ name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4',}}
    })
    
    sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {
        main={ name="Grioavolr", augments={'AGI+2','Spell interruption rate down -6%','"Fast Cast"+7','Magic Damage +1',}},
        sub="Clerisy Strap +1"
    })
    
    -- PREMIUM Elemental Magic sets using your best gear
    sets.midcast['Elemental Magic'] = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo={ name="Coiste Bodhar", augments={'Path: A',}},
        head={ name="Agwu's Cap", augments={'Path: A',}},
        neck="Sibyl Scarf",
        ear1="Crematio Earring",
        ear2="Friomisi Earring",
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Shiva Ring +1",
        ring2="Lebeche Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}
    }

    sets.midcast['Elemental Magic'].Resistant = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head={ name="Agwu's Cap", augments={'Path: A',}},
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Shiva Ring +1",
        ring2={ name="Metamor. Ring +1", augments={'Path: A',}},
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Azimuth Tights +2",
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}
    }
        
    sets.midcast['Elemental Magic'].Proc = {
        main=empty,
        sub=empty,
        ammo="Impatiens",
        head="Jhakri Coronal +2",
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Gifted Earring",
        ear2="Loquac. Earring",
        body={ name="Samnuha Coat", augments={'Mag. Acc.+3','"Mag.Atk.Bns."+2','"Fast Cast"+2',}},
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
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
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5','CHR+4','Mag. Acc.+14','"Mag.Atk.Bns."+15',}},
        neck="Sibyl Scarf",
        ear1="Crematio Earring",
        ear2="Friomisi Earring",
        body={ name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Shiva Ring +1",
        ring2="Lebeche Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14',}}
    }
        
    sets.midcast['Elemental Magic'].HighTierNuke = {
        main={ name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}},
        sub="Ammurapi Shield",
        ammo={ name="Coiste Bodhar", augments={'Path: A',}},
        head={ name="Agwu's Cap", augments={'Path: A',}},
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Lebeche Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}
    }
        
    sets.midcast['Elemental Magic'].HighTierNuke.Resistant = {
        main={ name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}},
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head="Azimuth Hood +2",
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        body="Azimuth Coat +2",
        hands="Azimuth Gloves +2",
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Lebeche Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs="Azimuth Tights +2",
        feet="Azimuth Gaiters +2"
    }

    sets.midcast['Elemental Magic'].HighTierNuke.Fodder = {
        main={ name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}},
        sub="Ammurapi Shield",
        ammo={ name="Coiste Bodhar", augments={'Path: A',}},
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5','CHR+4','Mag. Acc.+14','"Mag.Atk.Bns."+15',}},
        neck="Sibyl Scarf",
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        body={ name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Lebeche Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Agwu's Pigaches", augments={'Path: A',}}
    }

-- Dark Magic sets - PART 3
    sets.midcast['Dark Magic'] = {
        main={ name="Rubicundity", augments={'Mag. Acc.+3','"Mag.Atk.Bns."+3',}},
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head={ name="Agwu's Cap", augments={'Path: A',}},
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14',}}
    }
        
    sets.midcast.Drain = {
        main={ name="Rubicundity", augments={'Mag. Acc.+3','"Mag.Atk.Bns."+3',}},
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head="Befouled Crown",
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1="Lebeche Ring",
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Fucho-no-Obi",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14',}}
    }
    
    sets.midcast.Aspir = sets.midcast.Drain
        
    sets.midcast.Stun = {
        main={ name="Grioavolr", augments={'AGI+2','Spell interruption rate down -6%','"Fast Cast"+7','Magic Damage +1',}},
        sub="Clerisy Strap +1",
        ammo="Pemphredo Tathlum",
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5','CHR+4','Mag. Acc.+14','"Mag.Atk.Bns."+15',}},
        neck="Voltsurge Torque",
        ear1="Loquac. Earring",
        ear2="Malignance Earring",
        body={ name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9',}},
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Stikini Ring",
        back=gear.fc_jse_back,
        waist="Witful Belt",
        legs={ name="Rawhide Trousers", augments={'MP+50','"Fast Cast"+5','"Refresh"+1',}},
        feet={ name="Regal Pumps +1", augments={'Path: A',}}
    }
        
    sets.midcast.Stun.Resistant = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head={ name="Agwu's Cap", augments={'Path: A',}},
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14',}}
    }
        
    sets.midcast.Impact = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head=empty,
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        body="Twilight Cape",
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Stikini Ring",
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
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Agwu's Gages", augments={'Path: A',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Eschan Stone",
        legs={ name="Agwu's Slops", augments={'Path: A',}},
        feet={ name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14',}}
    }

    sets.midcast.Dispelga = set_combine(sets.midcast.Dispel, {main="Daybreak",sub="Ammurapi Shield"})
        
    -- Enfeebling Magic sets
    sets.midcast['Enfeebling Magic'] = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head="Befouled Crown",
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Etiolation Earring",
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1="Kishar Ring",
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Luminary Sash",
        legs={ name="Chironic Slippers", augments={'"Avatar perpetuation cost" -4','STR+5','Mag. Acc.+20 "Mag.Atk.Bns."+20',}},
        feet={ name="Medium's Sabots", augments={'MP+50','MND+10','"Conserve MP"+7','"Cure" potency +5%',}}
    }
        
    sets.midcast['Enfeebling Magic'].Resistant = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo="Pemphredo Tathlum",
        head="Befouled Crown",
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Etiolation Earring",
        body={ name="Agwu's Robe", augments={'Path: A',}},
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
        ring1={ name="Metamor. Ring +1", augments={'Path: A',}},
        ring2="Stikini Ring",
        back=gear.nuke_jse_back,
        waist="Luminary Sash",
        legs={ name="Chironic Slippers", augments={'"Avatar perpetuation cost" -4','STR+5','Mag. Acc.+20 "Mag.Atk.Bns."+20',}},
        feet={ name="Medium's Sabots", augments={'MP+50','MND+10','"Conserve MP"+7','"Cure" potency +5%',}}
    }
        
    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {
        head={ name="Agwu's Cap", augments={'Path: A',}},
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        waist="Eschan Stone"
    })
    sets.midcast.ElementalEnfeeble.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {
        head={ name="Agwu's Cap", augments={'Path: A',}},
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        waist="Eschan Stone"
    })
    
    sets.midcast.IntEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {
        head={ name="Agwu's Cap", augments={'Path: A',}},
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        waist="Eschan Stone"
    })
    sets.midcast.IntEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {
        head={ name="Agwu's Cap", augments={'Path: A',}},
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        waist="Eschan Stone"
    })
    
    sets.midcast.MndEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {range=empty,ring1="Stikini Ring"})
    sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {range=empty,ring1="Stikini Ring"})
    
    sets.midcast.Dia = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast['Dia II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    
    sets.midcast.Bio = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast['Bio II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    
    sets.midcast['Divine Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {ring1="Stikini Ring"})
        
    -- OPTIMIZED Enhancing Magic sets using your Telchine gear
    sets.midcast['Enhancing Magic'] = {
        main={ name="Gada", augments={'Enh. Mag. eff. dur. +6','"Mag.Atk.Bns."+9','DMG:+13',}},
        sub="Ammurapi Shield",
        ammo="Hydrocera",
        head={ name="Telchine Cap", augments={'Mag. Acc.+20','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        neck="Incanter's Torque",
        ear1="Andoaa Earring",
        ear2="Gifted Earring",
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
        ear2="Etiolation Earring",
        waist="Siegel Sash"
    })
    
    sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {
        head={ name="Agwu's Cap", augments={'Path: A',}}
    })
    
    sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {
        main="Chatoyant Staff",
        sub="Clerisy Strap +1",
        head={ name="Agwu's Cap", augments={'Path: A',}},
        hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}}
    })
    
    sets.midcast.BarElement = set_combine(sets.precast.FC['Enhancing Magic'], {})
    
    sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {
        ear1="Gifted Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        waist="Sacro Cord"
    })
    sets.midcast.Protectra = set_combine(sets.midcast['Enhancing Magic'], {
        ear1="Gifted Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        waist="Sacro Cord"
    })
    sets.midcast.Shell = set_combine(sets.midcast['Enhancing Magic'], {
        ear1="Gifted Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        waist="Sacro Cord"
    })
    sets.midcast.Shellra = set_combine(sets.midcast['Enhancing Magic'], {
        ear1="Gifted Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        waist="Sacro Cord"
    })

--------------------------------------
    -- Idle/resting/defense/etc sets - PART 4
    --------------------------------------

    -- Resting sets
    sets.resting = {
        main="Chatoyant Staff",
        sub="Clerisy Strap +1",
        head="Befouled Crown",
        neck="Unmoving Collar",
        ear1="Etiolation Earring",
        ear2="Relaxing Earring",
        body="Jhakri Robe +2",
        hands={ name="Chironic Gloves", augments={'Mag. Acc.+5','Crit.hit rate+1','Mag. Acc.+19 "Mag.Atk.Bns."+19',}},
        ring1={ name="Murky Ring", augments={'Path: A',}}, 
        ring2="Lebeche Ring",
        back="Umbra Cape",
        legs="Assid. Pants +1",
        feet={ name="Chironic Slippers", augments={'"Avatar perpetuation cost" -4','STR+5','Mag. Acc.+20 "Mag.Atk.Bns."+20',}}
    }

    -- PREMIUM idle sets using your Mallquis +2 gear
    sets.idle = {
        main={ name="Mpaca's Staff", augments={'Path: A',}},
        sub="Umbra Strap",
        ammo="Homiliary",
        head="Mall. Chapeau +2",
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Etiolation Earring",
        ear2="Relaxing Earring",
        body="Mallquis Saio +2",
        hands="Mallquis Cuffs +2",
        ring1="Stikini Ring",
        ring2={ name="Murky Ring", augments={'Path: A',}}, 
        back="Umbra Cape",
        waist="Carrier's Sash",
        legs="Assid. Pants +1",
        feet="Mallquis Clogs +2"
    }
        
    sets.idle.PDT = {
        main="Malignance Pole",
        sub="Umbra Strap",
        ammo="Homiliary",
        head={ name="Nyame Helm", augments={'Path: B',}},
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Etiolation Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        body="Mallquis Saio +2",
        hands={ name="Nyame Gauntlets", augments={'Path: B',}},
        ring1={ name="Murky Ring", augments={'Path: A',}}, 
        ring2="Mallquis Ring",
        back="Umbra Cape",
        waist="Carrier's Sash",
        legs={ name="Nyame Flanchard", augments={'Path: B',}},
        feet="Mallquis Clogs +2"
    }

    -- MAXIMIZED Pet sets for Luopan survivability
    sets.idle.Pet = {
        main={ name="Solstice", augments={'Mag. Acc.+20','Pet: Damage taken -4%','"Fast Cast"+5',}},
        sub="Enki Strap",
        range={ name="Dunna", augments={'MP+20','Mag. Acc.+10','"Fast Cast"+3',}},
        head="Mall. Chapeau +2",
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Etiolation Earring",
        ear2="Relaxing Earring",
        body="Mallquis Saio +2",
        hands="Bagua Mitaines +1",
        ring1={ name="Murky Ring", augments={'Path: A',}}, 
        ring2="Lebeche Ring",
        back=gear.idle_jse_back,
        waist="Carrier's Sash",
        legs={ name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        feet="Bagua Sandals +1"
    }

    sets.idle.PDT.Pet = {
        main="Malignance Pole",
        sub="Umbra Strap",
        range={ name="Dunna", augments={'MP+20','Mag. Acc.+10','"Fast Cast"+3',}},
        head={ name="Nyame Helm", augments={'Path: B',}},
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Etiolation Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        body="Mallquis Saio +2",
        hands="Bagua Mitaines +1",
        ring1={ name="Murky Ring", augments={'Path: A',}}, 
        ring2="Lebeche Ring",
        back=gear.idle_jse_back,
        waist="Carrier's Sash",
        legs={ name="Nyame Flanchard", augments={'Path: B',}},
        feet="Bagua Sandals +1"
    }

    -- Pet regen focus using available gear
    sets.idle.PetRegen = {
        main={ name="Solstice", augments={'Mag. Acc.+20','Pet: Damage taken -4%','"Fast Cast"+5',}},
        sub="Enki Strap",
        range={ name="Dunna", augments={'MP+20','Mag. Acc.+10','"Fast Cast"+3',}},
        head="Mall. Chapeau +2",
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Etiolation Earring",
        ear2="Relaxing Earring",
        body={ name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        hands="Bagua Mitaines +1",
        ring1={ name="Murky Ring", augments={'Path: A',}}, 
        ring2="Lebeche Ring",
        back=gear.idle_jse_back,
        waist="Carrier's Sash",
        legs={ name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10',}},
        feet="Bagua Sandals +1"
    }

    -- .Indi sets are for when an Indi-spell is active.
    sets.idle.Indi = set_combine(sets.idle, {}) 
    sets.idle.Pet.Indi = set_combine(sets.idle.Pet, {}) 
    sets.idle.PDT.Indi = set_combine(sets.idle.PDT, {}) 
    sets.idle.PDT.Pet.Indi = set_combine(sets.idle.PDT.Pet, {})

    sets.idle.Weak = {
        main="Chatoyant Staff",
        sub="Clerisy Strap +1",
        ammo="Homiliary",
        head="Befouled Crown",
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Etiolation Earring",
        ear2="Relaxing Earring",
        body="Mallquis Saio +2",
        hands="Mallquis Cuffs +2",
        ring1={ name="Murky Ring", augments={'Path: A',}}, 
        ring2="Lebeche Ring",
        back="Umbra Cape",
        waist="Carrier's Sash",
        legs="Assid. Pants +1",
        feet="Mallquis Clogs +2"
    }

    -- MAXIMIZED Defense sets using your premium gear
    sets.defense.PDT = {
        main="Malignance Pole",
        sub="Umbra Strap",
        ammo="Homiliary",
        head={ name="Nyame Helm", augments={'Path: B',}},
        neck={ name="Loricate Torque +1", augments={'Path: A',}},
        ear1="Etiolation Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        body="Mallquis Saio +2",
        hands={ name="Nyame Gauntlets", augments={'Path: B',}},
        ring1={ name="Murky Ring", augments={'Path: A',}}, 
        ring2="Mallquis Ring",
        back="Umbra Cape",
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
        ear1="Etiolation Earring",
        ear2={ name="Azimuth Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Damage taken-5%',}},
        body="Mallquis Saio +2",
        hands={ name="Nyame Gauntlets", augments={'Path: B',}},
        ring1={ name="Murky Ring", augments={'Path: A',}}, 
        ring2="Mallquis Ring",
        back="Umbra Cape",
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
        ear1="Etiolation Earring",
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
    sets.Kiting = {feet="Herald's Gaiters"}
    sets.latent_refresh = {waist="Fucho-no-Obi"}
    sets.latent_refresh_grip = {sub="Clerisy Strap +1"}
    sets.TPEat = {neck="Unmoving Collar"}
    sets.DayIdle = {}
    sets.NightIdle = {}
    sets.TreasureHunter = {feet={ name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Treasure Hunter"+2','Mag. Acc.+6','"Mag.Atk.Bns."+14',}}}
    
    sets.HPDown = {
        head="Befouled Crown",
        ear1="Relaxing Earring",
        ear2="Etiolation Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Mephitas's Ring +1",
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
        ammo="Amar Cluster",
        head="Befouled Crown",
        neck="Asperity Necklace",
        ear1="Brutal Earring",
        ear2="Suppanomimi",
        body="Mallquis Saio +2",
        hands={ name="Gazu Bracelets +1", augments={'Path: A',}},
        ring1="Epona's Ring",
        ring2="Petrov Ring",
        back="Nexus Cape",
        waist="Witful Belt",
        legs="Assid. Pants +1",
        feet="Battlecast Gaiters"
    }
        
    sets.engaged.DW = {
        ammo="Amar Cluster",
        head="Befouled Crown",
        neck="Asperity Necklace",
        ear1="Dudgeon Earring",
        ear2="Heartseeker Earring",
        body="Mallquis Saio +2",
        hands={ name="Gazu Bracelets +1", augments={'Path: A',}},
        ring1="Epona's Ring",
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
    sets.RecoverMP = {body={ name="Samnuha Coat", augments={'Mag. Acc.+3','"Mag.Atk.Bns."+2','"Fast Cast"+2',}}}
    
    -- Magic Burst mode using your available gear
    sets.MagicBurst = {
        main={ name="Grioavolr", augments={'Enh. Mag. eff. dur. +7','Mag. Acc.+27','"Mag.Atk.Bns."+26',}},
        sub="Alber Strap",
        head="Jhakri Coronal +2",
        neck="Mizu. Kubikazari",
        body="Jhakri Robe +2",
        ring1="Mujin Band",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }
    sets.ResistantMagicBurst = {
        main={ name="Grioavolr", augments={'Enh. Mag. eff. dur. +7','Mag. Acc.+27','"Mag.Atk.Bns."+26',}},
        sub="Enki Strap",
        head="Jhakri Coronal +2",
        neck="Mizu. Kubikazari",
        body="Jhakri Robe +2",
        ring1="Mujin Band",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2"
    }
    
    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}
    
    -- UPDATED Weapons sets using your actual gear
    sets.weapons.Maxentius = {main='Maxentius',sub='Genmei Shield'}
    sets.weapons.DualWeapons = {
        main={ name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}}, 
        sub={ name="Malevolence", augments={'INT+7','"Mag.Atk.Bns."+5','"Fast Cast"+3',}}
    }
    sets.weapons.Daybreak = {main='Daybreak',sub='Ammurapi Shield'}
    sets.weapons.Bunzi = {
        main={ name="Grioavolr", augments={'Enh. Mag. eff. dur. +7','Mag. Acc.+27','"Mag.Atk.Bns."+26',}},
        sub="Enki Strap"
    }
    sets.weapons.PetDT = {
        main={ name="Solstice", augments={'Mag. Acc.+20','Pet: Damage taken -4%','"Fast Cast"+5',}},
        sub="Genmei Shield"
    }
    sets.weapons.Skill = {
        main="Malignance Pole",
        sub="Enki Strap"
    }
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    set_macro_page(1, 21)
end

-- Sleep detection function 
function user_job_buff_change(buff, gain)
    if buff == 'Sleep' and gain then
        -- Sleep detected - equip Lorg Mor to break it with damage
        equip({main = "Lorg Mor"})
        add_to_chat(123, "Sleep detected! Equipped Lorg Mor.")
    end
end

-- Optional: Add a manual test command
function user_job_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'sleeptest' then
        equip({main = "Lorg Mor"})
        add_to_chat(123, "Test: Equipped Lorg Mor.")
        eventArgs.handled = true
    end
end