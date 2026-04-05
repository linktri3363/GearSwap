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

-- Setup vars that are user-dependent.  Can override this function in a sidecar.
function user_job_setup()
    state.OffenseMode:options('Normal','Acc')
    state.CastingMode:options('Normal','Resistant','OccultAcumen')
    state.IdleMode:options('Normal','PDT')
    state.Weapons:options('None','Khatvanga')

    gear.perp_staff = {name="Mpaca's Staff", augments={'Path: A'}}
    
    gear.magic_jse_back = {name="Conveyance Cape"}
    gear.phys_jse_back = {name="Conveyance Cape"}
    
    send_command('bind !` input /ja "Release" <me>')
    send_command('bind @` gs c cycle MagicBurst')
    send_command('bind ^` gs c toggle PactSpamMode')
    send_command('bind !pause gs c toggle AutoSubMode')
    send_command('bind ^q gs c weapons Khatvanga;gs c set CastingMode OccultAcumen')
    send_command('bind !q gs c weapons default;gs c reset CastingMode')
    
    select_default_macro_book()
end

-- Add this to prevent the update_job_states error
function update_job_states()
    -- Do nothing to prevent errors
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Precast Sets
    --------------------------------------
    
    sets.TreasureHunter = set_combine(sets.TreasureHunter, {waist="Chaac Belt"})
    
    -- Precast sets to enhance JAs
    sets.precast.JA['Astral Flow'] = {head="Beckoner's Horn +1"}
    
    sets.precast.JA['Elemental Siphon'] = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head={name="Telchine Cap", augments={'Mag. Acc.+20','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},neck="Adad Amulet",ear1="Andoaa Earring",ear2="C. Palug Earring",
        body={name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},hands={name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},ring1="Evoker's Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},feet="Beck. Pigaches +1"}

    sets.precast.JA['Mana Cede'] = {hands="Beck. Bracers +1"}

    -- Pact delay reduction gear
    sets.precast.BloodPactWard = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck="Adad Amulet",ear1="Andoaa Earring",ear2="Lugalbanda Earring",
        body="Beck. Doublet +1",hands="Beck. Bracers +1",ring1="Evoker's Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Lucidity Sash",legs="Beck. Spats +1",feet="Beck. Pigaches +1"}
        
    sets.precast.BloodPactRage = sets.precast.BloodPactWard

    -- Fast cast sets for spells
    
    sets.precast.FC = {main={name="Grioavolr", augments={'AGI+2','Spell interruption rate down -6%','"Fast Cast"+7','Magic Damage +1'}},sub="Umbra Strap",ammo="Impatiens",
        head={name="Bunzi's Hat", augments={'Path: A'}},neck="Voltsurge Torque",ear1="Malignance Earring",ear2="C. Palug Earring",
        body="Inyanga Jubbah +2",hands="Beck. Bracers +1",ring1="Kishar Ring",ring2="Stikini Ring",
        back={name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%'}},waist="Witful Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet={name="Regal Pumps +1", augments={'Path: A'}}}

    sets.precast.FC.Cure = set_combine(sets.precast.FC, {main="Espiritus",sub="Umbra Strap"})
        
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})
    
    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {})
    
    sets.precast.FC.Impact = set_combine(sets.precast.FC, {head=empty,body="Twilight Cloak"})       
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main="Daybreak",sub="Genmei Shield"})
    
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {}

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS['Myrkr'] = {ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck="Adad Amulet",ear1="C. Palug Earring",ear2="Ethereal Earring",
        body="Beck. Doublet +1",hands="Beck. Bracers +1",ring1="Mephitas's Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet="Beck. Pigaches +1"}

    
    --------------------------------------
    -- Midcast sets
    --------------------------------------

    sets.midcast.FastRecast = {main={name="Grioavolr", augments={'AGI+2','Spell interruption rate down -6%','"Fast Cast"+7','Magic Damage +1'}},sub="Umbra Strap",ammo="Impatiens",
        head={name="Bunzi's Hat", augments={'Path: A'}},neck="Voltsurge Torque",ear1="Malignance Earring",ear2="C. Palug Earring",
        body="Inyanga Jubbah +2",hands="Beck. Bracers +1",ring1="Kishar Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Witful Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet={name="Regal Pumps +1", augments={'Path: A'}}}
    
    sets.midcast.Cure = {main="Espiritus",sub="Umbra Strap",ammo="Impatiens",
        head={name="Kaykaus Mitra +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%'}},neck="Adad Amulet",ear1="C. Palug Earring",ear2="Ethereal Earring",
        body={name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7'}},hands={name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Kaykaus Tights +1", augments={'MP+80','Spell interruption rate down +12%','"Cure" spellcasting time -7%'}},feet={name="Kaykaus Boots +1", augments={'Mag. Acc.+20','"Cure" potency +6%','"Fast Cast"+4'}}}
        
    sets.Self_Healing = {neck="Adad Amulet",ring1="Stikini Ring",ring2="Stikini Ring",waist="Regal Belt"}
    sets.Cure_Received = {neck="Adad Amulet",ring1="Stikini Ring",ring2="Stikini Ring",waist="Regal Belt"}
    sets.Self_Refresh = {back="Conveyance Cape",waist="Regal Belt",feet="Beck. Pigaches +1"}
        
    sets.midcast.Cursna =  set_combine(sets.midcast.Cure, {neck="Adad Amulet",hands={name="Kaykaus Cuffs +1", augments={'MP+80','MND+12','Mag. Acc.+20'}},
        back="Conveyance Cape",ring1="Stikini Ring",ring2="Stikini Ring",waist="Witful Belt"})
        
    sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {main={name="Grioavolr", augments={'AGI+2','Spell interruption rate down -6%','"Fast Cast"+7','Magic Damage +1'}},sub="Umbra Strap"})

    sets.midcast['Summoning Magic'] = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck="Adad Amulet",ear1="Andoaa Earring",ear2="Lugalbanda Earring",
        body="Beck. Doublet +1",hands="Beck. Bracers +1",ring1="Stikini Ring",ring2="Stikini Ring",
        back=gear.magic_jse_back,waist="Regal Belt",legs="Assid. Pants +1",feet="Beck. Pigaches +1"}
        
    sets.midcast['Elemental Magic'] = {main="Daybreak",sub="Umbra Strap",ammo="Pemphredo Tathlum",
        head={name="Bunzi's Hat", augments={'Path: A'}},neck="Baetyl Pendant",ear1="Crematio Earring",ear2="Malignance Earring",
        body={name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9'}},hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet={name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14'}}}
        
    sets.midcast['Elemental Magic'].Resistant = {main="Daybreak",sub="Umbra Strap",ammo="Pemphredo Tathlum",
        head={name="Bunzi's Hat", augments={'Path: A'}},neck="Baetyl Pendant",ear1="Crematio Earring",ear2="Malignance Earring",
        body={name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9'}},hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back=gear.magic_jse_back,waist="Regal Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet={name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14'}}}
        
    sets.midcast['Elemental Magic'].OccultAcumen = {main="Khatvanga",sub="Bloodrain Strap",ammo="Seraphic Ampulla",
        head={name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5','CHR+4','Mag. Acc.+14','"Mag.Atk.Bns."+15'}},neck="Shulmanu Collar",ear1="Lugalbanda Earring",ear2="Gelos Earring",
        body={name="Merlinic Jubbah", augments={'Mag. Acc.+14','"Occult Acumen"+11','MND+6'}},hands={name="Chironic Gloves", augments={'"Mag.Atk.Bns."+25','"Occult Acumen"+11','CHR+9'}},ring1="Petrov Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet={name="Merlinic Crackows", augments={'"Occult Acumen"+11','INT+8','Mag. Acc.+4'}}}
        
    sets.midcast.Impact = {main="Daybreak",sub="Umbra Strap",ammo="Pemphredo Tathlum",
        head=empty,neck="Adad Amulet",ear1="Malignance Earring",ear2="C. Palug Earring",
        body="Twilight Cloak",hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet={name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14'}}}
        
    sets.midcast.Impact.OccultAcumen = set_combine(sets.midcast['Elemental Magic'].OccultAcumen, {head=empty,body="Twilight Cloak"})

    sets.midcast['Divine Magic'] = {main="Daybreak",sub="Umbra Strap",ammo="Pemphredo Tathlum",
        head={name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5','CHR+4','Mag. Acc.+14','"Mag.Atk.Bns."+15'}},neck="Baetyl Pendant",ear1="Crematio Earring",ear2="Malignance Earring",
        body={name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9'}},hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet={name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14'}}}
        
    sets.midcast['Dark Magic'] = {main="Espiritus",sub="Umbra Strap",ammo="Pemphredo Tathlum",
        head={name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5','CHR+4','Mag. Acc.+14','"Mag.Atk.Bns."+15'}},neck="Adad Amulet",ear1="Malignance Earring",ear2="C. Palug Earring",
        body={name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9'}},hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet={name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14'}}}
    
    sets.midcast.Drain = {main="Espiritus",sub="Umbra Strap",ammo="Pemphredo Tathlum",
        head={name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5','CHR+4','Mag. Acc.+14','"Mag.Atk.Bns."+15'}},neck="Adad Amulet",ear1="Malignance Earring",ear2="C. Palug Earring",
        body={name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9'}},hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet={name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14'}}}
    
    sets.midcast.Aspir = sets.midcast.Drain
        
    sets.midcast.Stun = {main={name="Grioavolr", augments={'AGI+2','Spell interruption rate down -6%','"Fast Cast"+7','Magic Damage +1'}},sub="Umbra Strap",ammo="Impatiens",
        head={name="Bunzi's Hat", augments={'Path: A'}},neck="Voltsurge Torque",ear1="Malignance Earring",ear2="C. Palug Earring",
        body="Inyanga Jubbah +2",hands="Beck. Bracers +1",ring1="Kishar Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Witful Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet={name="Regal Pumps +1", augments={'Path: A'}}}
        
    sets.midcast.Stun.Resistant = {main="Daybreak",sub="Umbra Strap",ammo="Impatiens",
        head={name="Bunzi's Hat", augments={'Path: A'}},neck="Voltsurge Torque",ear1="Malignance Earring",ear2="C. Palug Earring",
        body="Inyanga Jubbah +2",hands="Beck. Bracers +1",ring1="Kishar Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Witful Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet={name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14'}}}
        
    sets.midcast['Enfeebling Magic'] = {main="Daybreak",sub="Umbra Strap",ammo="Pemphredo Tathlum",
        head="Befouled Crown",neck="Adad Amulet",ear1="Malignance Earring",ear2="C. Palug Earring",
        body={name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9'}},hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Kishar Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet={name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14'}}}
        
    sets.midcast['Enfeebling Magic'].Resistant = {main="Daybreak",sub="Umbra Strap",ammo="Pemphredo Tathlum",
        head="Befouled Crown",neck="Adad Amulet",ear1="Malignance Earring",ear2="C. Palug Earring",
        body={name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9'}},hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back=gear.magic_jse_back,waist="Regal Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet={name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14'}}}
        
    sets.midcast.Dia = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast.Diaga = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast['Dia II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast.Bio = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast['Bio II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
        
    sets.midcast['Enhancing Magic'] = {main="Espiritus",sub="Umbra Strap",ammo="Impatiens",
        head={name="Telchine Cap", augments={'Mag. Acc.+20','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},neck="Adad Amulet",ear1="Andoaa Earring",ear2="C. Palug Earring",
        body={name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},hands={name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Embla Sash",legs={name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},feet={name="Telchine Pigaches", augments={'Mag. Acc.+18','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}}}
        
    sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {head={name="Bunzi's Hat", augments={'Path: A'}}})
    sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {main="Espiritus",sub="Genmei Shield",head={name="Bunzi's Hat", augments={'Path: A'}},hands={name="Bunzi's Gloves", augments={'Path: A'}},waist="Regal Belt",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}}})
    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {neck="Nodens Gorget",waist="Siegel Sash",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}}})
    sets.midcast.BarElement = set_combine(sets.precast.FC['Enhancing Magic'], {legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}}})

    -- Avatar pact sets.  All pacts are Ability type.
    
    sets.midcast.Pet.BloodPactWard = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck="Adad Amulet",ear1="Andoaa Earring",ear2="Lugalbanda Earring",
        body="Beck. Doublet +1",hands="Beck. Bracers +1",ring1="Evoker's Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Lucidity Sash",legs="Beck. Spats +1",feet="Beck. Pigaches +1"}

    sets.midcast.Pet.DebuffBloodPactWard = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck="Adad Amulet",ear1="Lugalbanda Earring",ear2="C. Palug Earring",
        body="Beck. Doublet +1",hands={name="Chironic Gloves", augments={'Mag. Acc.+5','Crit.hit rate+1','Mag. Acc.+19 "Mag.Atk.Bns."+19'}},ring1="Evoker's Ring",ring2="Stikini Ring",
        back=gear.magic_jse_back,waist="Regal Belt",legs="Assid. Pants +1",feet="Beck. Pigaches +1"}
        
    sets.midcast.Pet.DebuffBloodPactWard.Acc = sets.midcast.Pet.DebuffBloodPactWard
    
    sets.midcast.Pet.PhysicalBloodPactRage = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck="Shulmanu Collar",ear1="Lugalbanda Earring",ear2="Gelos Earring",
        body="Beck. Doublet +1",hands={name="Chironic Gloves", augments={'Mag. Acc.+5','Crit.hit rate+1','Mag. Acc.+19 "Mag.Atk.Bns."+19'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back=gear.phys_jse_back,waist="Regal Belt",legs="Assid. Pants +1",feet="Beck. Pigaches +1"}
        
    sets.midcast.Pet.PhysicalBloodPactRage.Acc = {feet="Beck. Pigaches +1"}

    sets.midcast.Pet.MagicalBloodPactRage = {main={name="Grioavolr", augments={'Enh. Mag. eff. dur. +7','Mag. Acc.+27','"Mag.Atk.Bns."+26'}},sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck="Adad Amulet",ear1="Lugalbanda Earring",ear2="Gelos Earring",
        body="Beck. Doublet +1",hands={name="Chironic Gloves", augments={'Mag. Acc.+5','Crit.hit rate+1','Mag. Acc.+19 "Mag.Atk.Bns."+19'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back=gear.magic_jse_back,waist="Regal Belt",legs={name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%'}},feet="Beck. Pigaches +1"}

    sets.midcast.Pet.MagicalBloodPactRage.Acc = {head="Beckoner's Horn +1",feet="Beck. Pigaches +1"}

    -- Spirits cast magic spells, which can be identified in standard ways.
    
    sets.midcast.Pet.WhiteMagic = {} --legs="Summoner's Spats"
    
    sets.midcast.Pet['Elemental Magic'] = set_combine(sets.midcast.Pet.MagicalBloodPactRage, {}) --legs="Summoner's Spats"

    sets.midcast.Pet['Elemental Magic'].Resistant = {}
    
    sets.midcast.Pet['Impact'] = sets.midcast.Pet.DebuffBloodPactWard

    sets.midcast.Pet['Flaming Crush'] = {main={name="Grioavolr", augments={'Enh. Mag. eff. dur. +7','Mag. Acc.+27','"Mag.Atk.Bns."+26'}},sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck="Adad Amulet",ear1="Lugalbanda Earring",ear2="Gelos Earring",
        body="Beck. Doublet +1",hands={name="Chironic Gloves", augments={'Mag. Acc.+5','Crit.hit rate+1','Mag. Acc.+19 "Mag.Atk.Bns."+19'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back=gear.phys_jse_back,waist="Regal Belt",legs="Assid. Pants +1",feet="Beck. Pigaches +1"}
        
    sets.midcast.Pet['Flaming Crush'].Acc = {head="Beckoner's Horn +1",feet="Beck. Pigaches +1"}
    
    sets.midcast.Pet['Mountain Buster'] = set_combine(sets.midcast.Pet.PhysicalBloodPactRage, {legs={name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%'}}})
    sets.midcast.Pet['Mountain Buster'].Acc = set_combine(sets.midcast.Pet.PhysicalBloodPactRage.Acc, {legs={name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%'}}})
    sets.midcast.Pet['Rock Buster'] = set_combine(sets.midcast.Pet.PhysicalBloodPactRage, {legs={name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%'}}})
    sets.midcast.Pet['Rock Buster'].Acc = set_combine(sets.midcast.Pet.PhysicalBloodPactRage.Acc, {legs={name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%'}}})
    sets.midcast.Pet['Crescent Fang'] = set_combine(sets.midcast.Pet.PhysicalBloodPactRage, {legs={name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%'}}})
    sets.midcast.Pet['Crescent Fang'].Acc = set_combine(sets.midcast.Pet.PhysicalBloodPactRage.Acc, {legs={name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%'}}})
    sets.midcast.Pet['Eclipse Bite'] = set_combine(sets.midcast.Pet.PhysicalBloodPactRage, {legs={name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%'}}})
    sets.midcast.Pet['Eclipse Bite'].Acc = set_combine(sets.midcast.Pet.PhysicalBloodPactRage.Acc, {legs={name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%'}}})
    sets.midcast.Pet['Blindside'] = set_combine(sets.midcast.Pet.PhysicalBloodPactRage, {legs={name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%'}}})
    sets.midcast.Pet['Blindside'].Acc = set_combine(sets.midcast.Pet.PhysicalBloodPactRage.Acc, {legs={name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%'}}})

    --------------------------------------
    -- Idle/resting/defense/etc sets
    --------------------------------------
    
    -- Resting sets
    sets.resting = {main={name="Mpaca's Staff", augments={'Path: A'}},sub="Umbra Strap",ammo="Impatiens",
        head="Beckoner's Horn +1",neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="C. Palug Earring",ear2="Ethereal Earring",
        body={name="Shomonjijoe +1", augments={'Path: A'}},hands={name="Chironic Gloves", augments={'Mag. Acc.+5','Crit.hit rate+1','Mag. Acc.+19 "Mag.Atk.Bns."+19'}},ring1="Defending Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs="Assid. Pants +1",feet="Beck. Pigaches +1"}
    
    -- Idle sets
    sets.idle = {main={name="Mpaca's Staff", augments={'Path: A'}},sub="Umbra Strap",ammo="Impatiens",
        head="Beckoner's Horn +1",neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="C. Palug Earring",ear2="Ethereal Earring",
        body={name="Shomonjijoe +1", augments={'Path: A'}},hands={name="Chironic Gloves", augments={'Mag. Acc.+5','Crit.hit rate+1','Mag. Acc.+19 "Mag.Atk.Bns."+19'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs="Assid. Pants +1",feet="Beck. Pigaches +1"}

    sets.idle.PDT = {main="Malignance Pole",sub="Umbra Strap",ammo="Impatiens",
        head="Beckoner's Horn +1",neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="C. Palug Earring",ear2="Ethereal Earring",
        body={name="Nyame Mail", augments={'Path: B'}},hands={name="Nyame Gauntlets", augments={'Path: B'}},ring1="Defending Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Nyame Flanchard", augments={'Path: B'}},feet={name="Nyame Sollerets", augments={'Path: B'}}}
        
    -- perp costs:
    -- spirits: 7
    -- carby: 11 (5 with mitts)
    -- fenrir: 13
    -- others: 15
    -- avatar's favor: -4/tick
    
    -- Max useful -perp gear is 1 less than the perp cost (can't be reduced below 1)
    -- Aim for -14 perp, and refresh in other slots.
    
    -- Can make due without either the head or the body, and use +refresh items in those slots.
    
    sets.idle.Avatar = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck="Adad Amulet",ear1="C. Palug Earring",ear2="Ethereal Earring",
        body={name="Shomonjijoe +1", augments={'Path: A'}},hands={name="Chironic Gloves", augments={'Mag. Acc.+5','Crit.hit rate+1','Mag. Acc.+19 "Mag.Atk.Bns."+19'}},ring1="Evoker's Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Lucidity Sash",legs="Assid. Pants +1",feet={name="Chironic Slippers", augments={'"Avatar perpetuation cost" -4','STR+5','Mag. Acc.+20 "Mag.Atk.Bns."+20'}}}
        
    sets.idle.PDT.Avatar = {main="Malignance Pole",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="C. Palug Earring",ear2="Ethereal Earring",
        body={name="Nyame Mail", augments={'Path: B'}},hands={name="Nyame Gauntlets", augments={'Path: B'}},ring1="Defending Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Nyame Flanchard", augments={'Path: B'}},feet={name="Chironic Slippers", augments={'"Avatar perpetuation cost" -4','STR+5','Mag. Acc.+20 "Mag.Atk.Bns."+20'}}}

    sets.idle.Spirit = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck="Adad Amulet",ear1="C. Palug Earring",ear2="Ethereal Earring",
        body={name="Shomonjijoe +1", augments={'Path: A'}},hands={name="Chironic Gloves", augments={'Mag. Acc.+5','Crit.hit rate+1','Mag. Acc.+19 "Mag.Atk.Bns."+19'}},ring1="Evoker's Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Lucidity Sash",legs="Assid. Pants +1",feet={name="Chironic Slippers", augments={'"Avatar perpetuation cost" -4','STR+5','Mag. Acc.+20 "Mag.Atk.Bns."+20'}}}
        
    sets.idle.PDT.Spirit = {main="Malignance Pole",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="C. Palug Earring",ear2="Ethereal Earring",
        body={name="Nyame Mail", augments={'Path: B'}},hands={name="Nyame Gauntlets", augments={'Path: B'}},ring1="Defending Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Lucidity Sash",legs={name="Nyame Flanchard", augments={'Path: B'}},feet="Beck. Pigaches +1"}
        
    --Favor always up and head is best in slot idle so no specific items here at the moment.
    sets.idle.Avatar.Favor = {}
    sets.idle.Avatar.Engaged = {}
    
    sets.idle.Avatar.Engaged.Carbuncle = {}
    sets.idle.Avatar.Engaged['Cait Sith'] = {}
        
    sets.perp = {}
    -- Caller's Bracer's halve the perp cost after other costs are accounted for.
    -- Using -10 (Gridavor, ring, Conv.feet), standard avatars would then cost 5, halved to 2.
    -- We can then use Hagondes Coat and end up with the same net MP cost, but significantly better defense.
    -- Weather is the same, but we can also use the latent on the pendant to negate the last point lost.
    sets.perp.Day = {}
    sets.perp.Weather = {}
    
    sets.perp.Carbuncle = {}
    sets.perp.Diabolos = {}
    sets.perp.Alexander = sets.midcast.Pet.BloodPactWard

    -- Not really used anymore, was for the days of specific staves for specific avatars.
    sets.perp.staff_and_grip = {}
    
    -- Defense sets
    sets.defense.PDT = {main="Malignance Pole",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="C. Palug Earring",ear2="Ethereal Earring",
        body={name="Nyame Mail", augments={'Path: B'}},hands={name="Nyame Gauntlets", augments={'Path: B'}},ring1="Defending Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Nyame Flanchard", augments={'Path: B'}},feet={name="Nyame Sollerets", augments={'Path: B'}}}

    sets.defense.MDT = {main="Malignance Pole",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="C. Palug Earring",ear2="Sanare Earring",
        body={name="Nyame Mail", augments={'Path: B'}},hands={name="Nyame Gauntlets", augments={'Path: B'}},ring1="Defending Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Nyame Flanchard", augments={'Path: B'}},feet={name="Nyame Sollerets", augments={'Path: B'}}}

    sets.defense.MEVA = {main="Malignance Pole",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head={name="Bunzi's Hat", augments={'Path: A'}},neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="Lugalbanda Earring",ear2="Sanare Earring",
        body="Inyanga Jubbah +2",hands={name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},ring1="Defending Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",legs={name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},feet={name="Telchine Pigaches", augments={'Mag. Acc.+18','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}}}
        
    sets.Kiting = {ring1="Shneddick Ring +1"}
    sets.latent_refresh = {waist="Regal Belt"}
    sets.latent_refresh_grip = {sub="Umbra Strap"}
    sets.TPEat = {neck="Adad Amulet"}
    sets.DayIdle = {}
    sets.NightIdle = {}

    sets.HPDown = {head="Beckoner's Horn +1",ear1="C. Palug Earring",ear2="Ethereal Earring",
        body="Beck. Doublet +1",hands="Beck. Bracers +1",ring1="Mephitas's Ring",ring2="Stikini Ring",
        back="Conveyance Cape",legs="Assid. Pants +1",feet="Beck. Pigaches +1"}
    
    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Sleep = {neck="Adad Amulet"}

    -- Weapons sets
    sets.weapons.Khatvanga = {main="Khatvanga",sub="Bloodrain Strap"}

    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}
    
    --------------------------------------
    -- Engaged sets
    --------------------------------------
    
    -- Normal melee group
    sets.engaged = {main="Espiritus",sub="Bloodrain Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +1",neck="Shulmanu Collar",ear1="Lugalbanda Earring",ear2="Gelos Earring",
        body="Beck. Doublet +1",hands={name="Gazu Bracelets +1", augments={'Path: A'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back=gear.phys_jse_back,waist="Regal Belt",legs="Assid. Pants +1",feet="Beck. Pigaches +1"}
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book(reset)
    if reset == 'reset' then
        -- lost pet, or tried to use pact when pet is gone
    end
    
    -- Default macro set/book
    set_macro_page(1, 15)
end