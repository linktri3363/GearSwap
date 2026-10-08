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
            windower.add_to_chat(160, string.format("%s : Disabling no_interruptions", _addon.name))
            no_interruptions = false
        else
            windower.add_to_chat(160, string.format("%s : Enabling no_interruptions", _addon.name))
            no_interruptions = true
        end
        return true
    end
    return false
end)

-- Phalanx state machine globals
self_cast_phalanx    = false
phalanx_holding      = false
phalanx_saved_weapons = 'None'

near_porter = false

function get_sets()
  mote_include_version = 2
  include('Mote-Include.lua')
end

function user_job_setup()

    -- Options: Override default values	
	state.OffenseMode:options('Normal','Acc')
    state.HybridMode:options('Tank','DDTank','Normal')
    state.WeaponskillMode:options('Match','Normal', 'Acc')
    state.CastingMode:options('Normal','Phalanx')
	state.Passive:options('None','AbsorbMP')
    state.PhysicalDefenseMode:options('PDT_HP','PDT','PDT_Reraise')
    state.MagicalDefenseMode:options('MDT_HP','MDT','MDT_Reraise')
	state.ResistDefenseMode:options('MEVA_HP','MEVA')
	state.IdleMode:options('Normal','Tank','Kiting','Block','MEVA','Aminon','Regen','elemental','Statresist')
	state.Weapons:options('None','BurtgangPriwen','SakpataPriwen','NaeglingBlurred','DualWeapons')
	
    state.ExtraDefenseMode = M{['description']='Extra Defense Mode','None','MP','Twilight'}
	
	-- Additional local binds
	send_command('bind !` gs c SubJobEnmity')
	send_command('bind ^backspace input /ja "Shield Bash" <t>')
	send_command('bind @backspace input /ja "Cover" <stpt>')
	send_command('bind !backspace input /ja "Sentinel" <me>')
	send_command('bind @= input /ja "Chivalry" <me>')
	send_command('bind != input /ja "Palisade" <me>')
	send_command('bind ^delete input /ja "Provoke" <stnpc>')
	send_command('bind !delete input /ma "Cure IV" <stal>')
	send_command('bind @delete input /ma "Flash" <stnpc>')
    send_command('bind !f11 gs c cycle ExtraDefenseMode')
	send_command('bind @` gs c cycle RuneElement')
	send_command('bind ^pause gs c toggle AutoRuneMode')
	send_command('bind ^q gs c set IdleMode Kiting')
	send_command('bind !q gs c set IdleMode PDT')
	send_command('bind @f8 gs c toggle AutoTankMode')
	send_command('bind @f10 gs c toggle TankAutoDefense')
	send_command('bind ^@!` gs c cycle SkillchainMode')
	
    select_default_macro_book()
    update_defense_mode()
	send_command('@wait 5;input /lockstyleset 7')
end

function init_gear_sets()
	
	--------------------------------------
	-- Precast sets
	--------------------------------------
	
    sets.Enmity = {
	ammo  = "Paeapua",                  -- Enmity+2, Fast Cast+2%, HP+40
	head  = "Loess Barbuta",              -- Enmity+19–24%, DT-20%, MDB+5, MEVA+91
	body  = "Sakpata's Plate",              -- Enmity+9, Cure Potency Rec.+15%
	hands = "Sakpata's Gauntlets",             -- Enmity+9, Cure Potency Rec.+15%
	legs  = "Sakpata's Cuisses",           -- Enmity+9, Cure Potency Rec.+15%
	feet  = "Chev. Sabatons +3",             -- Enmity+12, MEVA+40+
	neck  = { name="Kgt. Beads +2", augments={'Path: A'}},            -- Enmity+10, MEVA+70, Status Resist+10
	waist = "Plat. Mog. Belt",               
	ear1  = "Cryptic Earring",               -- Enmity+4
	ear2  = "Trux Earring",                  -- Enmity+5
	ring1 = "Supershear Ring",                   -- Enmity+5
	ring2 = "Supershear Ring",               -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Eva.+20 /Mag. Eva.+20','Mag. Evasion+15',}},
	} -- Enmity 106-111 ( cap 100 Burtgang gives extra enmity ( 23 ) as well as DT II -18% )
		
    sets.Enmity.DT = {
	ammo	= "Staunch Tathlum",
    head	= { name="Sakpata's Helm", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    body	= "Rev. Surcoat +4",
    hands	= { name="Sakpata's Gauntlets", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    legs	= { name="Sakpata's Cuisses", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    feet	= { name="Sakpata's Leggings", augments={'HP+65','STR+12','Accuracy+13',}},
    neck 	= { name="Loricate Torque +1", augments={'Path: A'}},
    waist	= "Plat. Mog. Belt",
    ear1	= "Trux Earring",
    ear2	= "Cryptic Earring",
    ring1	= "Defending Ring",
    ring2	= "Defending Ring",
    back	= { name="Rudianos's Mantle", augments={'VIT+20','Eva.+10 /Mag. Eva.+10','Enmity+10'}},
}
		
    -- Precast sets to enhance JAs
    sets.precast.JA['Invincible'] = set_combine(sets.Enmity,{legs="Cab. Breeches +4"})
    sets.precast.JA['Holy Circle'] = set_combine(sets.Enmity,{feet="Rev. Leggings +4"})
    sets.precast.JA['Sentinel'] = set_combine(sets.Enmity,{feet="Cab. Leggings +4"})
    sets.precast.JA['Rampart'] = set_combine(sets.Enmity,{head="Cab. Coronet +4"})
    sets.precast.JA['Fealty'] = set_combine(sets.Enmity,{body="Cab. Surcoat +4"})
    sets.precast.JA['Divine Emblem'] = set_combine(sets.Enmity,{feet="Chev. Sabatons +3"})
    sets.precast.JA['Cover'] = set_combine(sets.Enmity, {body="Cab. Surcoat +4", head="Rev. Coronet +4"}) 
	
    sets.precast.JA['Invincible'].DT = set_combine(sets.Enmity.DT,{legs="Cab. Breeches +4"})
    sets.precast.JA['Holy Circle'].DT = set_combine(sets.Enmity.DT,{feet="Rev. Leggings +4"})
    sets.precast.JA['Sentinel'].DT = set_combine(sets.Enmity.DT,{feet="Cab. Leggings +4"})
    sets.precast.JA['Rampart'].DT = set_combine(sets.Enmity.DT,{head="Cab. Coronet +4"})
    sets.precast.JA['Fealty'].DT = set_combine(sets.Enmity.DT,{body="Cab. Surcoat +4"})
    sets.precast.JA['Divine Emblem'].DT = set_combine(sets.Enmity.DT,{feet="Chev. Sabatons +3"})
    sets.precast.JA['Cover'].DT = set_combine(sets.Enmity.DT, {body="Cab. Surcoat +4", head="Rev. Coronet +4"})
	
    sets.precast.JA['Chivalry'] = {
	ammo  = "Pemphredo Tathlum",            
	head  = { name="Sakpata's Helm", augments={'Accuracy+20','Mag. Acc.+12','"Fast Cast"+4'} }, 
	body  = { name="Nyame Mail", augments={'Path: B'} },         
	hands = "Cab. Gauntlets +4",            
	legs  = { name="Nyame Flanchard", augments={'Path: B'} },    
	feet  = { name="Nyame Sollerets", augments={'Path: B'} },    
	neck  = "Incanter's Torque",            
	waist = "Luminary Sash",                
	ear1  = { name="Nourish. Earring +1", augments={'Path: A',}}, 
    ear2  = "Chev. Earring +1",
	ring1 = "Stikini Ring",              
	ring2 = { name="Metamor. Ring +1", augments={'Path: A'} }, 
	back  = { name="Rudianos's Mantle", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+4','Enmity+10','Mag. Evasion+15',}},
	} 
		
    sets.precast.JA['Chivalry'].DT = {
	ammo  = "Staunch Tathlum +1",            
	head  = { name="Nyame Helm", augments={'Path: B'} },        
	body  = { name="Nyame Mail", augments={'Path: B'} },         
	hands = "Cab. Gauntlets +4",             
	legs  = { name="Nyame Flanchard", augments={'Path: B'} },    
	feet  = { name="Nyame Sollerets", augments={'Path: B'} },    
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},            
	waist = "Plat. Mog. Belt",               
	ear1  = "Etiolation Earring",             
	ear2  = "Chev. Earring +1",          
	ring1 = "Defending Ring",                
	ring2 = "Stikini Ring",              
	back  = { name="Rudianos's Mantle", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+4','Enmity+10','Mag. Evasion+15',}},
}

			
    sets.precast.JA['Provoke'] = set_combine(sets.Enmity, {})
	sets.precast.JA['Warcry'] = set_combine(sets.Enmity, {})
	sets.precast.JA['Palisade'] = set_combine(sets.Enmity, {})
	sets.precast.JA['Intervene'] = set_combine(sets.Enmity, {})
	sets.precast.JA['Defender'] = set_combine(sets.Enmity, {})
	sets.precast.JA['Berserk'] = set_combine(sets.Enmity, {})
	sets.precast.JA['Aggressor'] = set_combine(sets.Enmity, {})
	
	sets.precast.JA['Provoke'].DT = set_combine(sets.Enmity.DT, {})
	sets.precast.JA['Warcry'].DT = set_combine(sets.Enmity.DT, {})
	sets.precast.JA['Palisade'].DT = set_combine(sets.Enmity.DT, {})
	sets.precast.JA['Intervene'].DT = set_combine(sets.Enmity.DT, {})
	sets.precast.JA['Defender'].DT = set_combine(sets.Enmity.DT, {})
	sets.precast.JA['Berserk'].DT = set_combine(sets.Enmity.DT, {})
	sets.precast.JA['Aggressor'].DT = set_combine(sets.Enmity.DT, {})

    -- Fast cast sets for spells
    
    sets.precast.FC = {
	ammo	= "Staunch Tathlum +1",
    head	= { name="Sakpata's Helm", augments={'Accuracy+20','Mag. Acc.+12','"Fast Cast"+4',}},
    body	= "Rev. Surcoat +4",
    hands	= { name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
    legs	= "Rawhide Trousers",
    feet	= { name="Founder's Greaves", augments={'Accuracy+30','"Fast Cast"+6','VIT+5',}},
    neck	= { name="Loricate Torque +1", augments={'Path: A',}},
    waist	= "Plat. Mog. Belt",
    ear1	= "Loquac. Earring",
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back	= { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Spell interruption rate down-10%',}},

	}
	    		
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})
		
	-- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
	ammo	= { name="Coiste Bodhar", augments={'Path: A',}},
    head	= { name="Nyame Helm", augments={'Path: B',}},
    body	= { name="Nyame Mail", augments={'Path: B',}},
    hands	= { name="Nyame Gauntlets", augments={'Path: B',}},
    legs	= { name="Nyame Flanchard", augments={'Path: B',}},
    feet	= { name="Nyame Sollerets", augments={'Path: B',}},
    neck	= { name="Kgt. Beads +2", augments={'Path: A',}},
    waist	= { name="Sailfi Belt +1", augments={'Path: A',}},
    ear1	= "Ishvara Earring",
    ear2	= { name="Moonshade Earring", augments={'Accuracy+4','TP Bonus +250',}},
    ring1	= "Ephramad's Ring",
    ring2	= { name="Metamor. Ring +1", augments={'Path: A'}},
    back	= { name="Rudianos's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+5','Weapon skill damage +10%','Damage taken-5%',}},
}
		
    sets.precast.WS.DT = {
	ammo	= { name="Coiste Bodhar", augments={'Path: A',}},
    head	= { name="Nyame Helm", augments={'Path: B',}},
    body	= { name="Nyame Mail", augments={'Path: B',}},
    hands	= { name="Nyame Gauntlets", augments={'Path: B',}},
    legs	= { name="Nyame Flanchard", augments={'Path: B',}},
    feet	= { name="Nyame Sollerets", augments={'Path: B',}},
    neck	= { name="Kgt. Beads +2", augments={'Path: A',}},
    waist	= { name="Sailfi Belt +1", augments={'Path: A',}},
    ear1	= "Ishvara Earring",
    ear2	= { name="Moonshade Earring", augments={'Accuracy+4','TP Bonus +250',}},
    ring1	= "Ephramad's Ring",
    ring2	= { name="Metamor. Ring +1", augments={'Path: A'}},
    back	= { name="Rudianos's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+5','Weapon skill damage +10%','Damage taken-5%',}},
}

    sets.precast.WS.Acc = {
	ammo	= { name="Coiste Bodhar", augments={'Path: A',}},
    head	= { name="Nyame Helm", augments={'Path: B',}},
    body	= { name="Nyame Mail", augments={'Path: B',}},
    hands	= { name="Nyame Gauntlets", augments={'Path: B',}},
    legs	= { name="Nyame Flanchard", augments={'Path: B',}},
    feet	= { name="Nyame Sollerets", augments={'Path: B',}},
    neck	= { name="Kgt. Beads +2", augments={'Path: A',}},
    waist	= { name="Sailfi Belt +1", augments={'Path: A',}},
    ear1	= "Ishvara Earring",
    ear2	= { name="Moonshade Earring", augments={'Accuracy+4','TP Bonus +250',}},
    ring1	= "Ephramad's Ring",
    ring2	= { name="Metamor. Ring +1", augments={'Path: A'}},
    back	= { name="Rudianos's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+5','Weapon skill damage +10%','Damage taken-5%',}},
}

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {neck="Sacro Gorget",ear1="Brutal Earring",ear2="Moonshade Earring"})
    sets.precast.WS['Requiescat'].Acc = set_combine(sets.precast.WS.Acc, {neck="Sacro Gorget",ear1="Telos Earring",ear2="Moonshade Earring"})

	sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {neck="Sacro Gorget",ear1="Brutal Earring",ear2="Moonshade Earring"})
    sets.precast.WS['Chant du Cygne'].Acc = set_combine(sets.precast.WS.Acc, {neck="Sacro Gorget",ear1="Telos Earring",ear2="Moonshade Earring"})

	sets.precast.WS['Savage Blade'] = {
	ammo={ name="Coiste Bodhar", augments={'Path: A',}},
    head={ name="Nyame Helm", augments={'Path: B',}},
    body={ name="Nyame Mail", augments={'Path: B',}},
    hands={ name="Nyame Gauntlets", augments={'Path: B',}},
    legs={ name="Nyame Flanchard", augments={'Path: B',}},
    feet={ name="Nyame Sollerets", augments={'Path: B',}},
    neck="Rep. Plat. Medal",
    waist={ name="Sailfi Belt +1", augments={'Path: A',}},
    ear1 ="Ishvara Earring",
    ear2 ={ name="Moonshade Earring", augments={'Accuracy+4','TP Bonus +250',}},
    ring1 ="Ephramad's Ring",
    ring2 = "", --needs update
    back={ name="Rudianos's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+5','Weapon skill damage +10%','Damage taken-5%',}},
}

    sets.precast.WS['Savage Blade'].Acc = {
	ammo={ name="Coiste Bodhar", augments={'Path: A',}},
    head={ name="Nyame Helm", augments={'Path: B',}},
    body={ name="Nyame Mail", augments={'Path: B',}},
    hands={ name="Nyame Gauntlets", augments={'Path: B',}},
    legs={ name="Nyame Flanchard", augments={'Path: B',}},
    feet={ name="Nyame Sollerets", augments={'Path: B',}},
    neck="Rep. Plat. Medal",
    waist={ name="Sailfi Belt +1", augments={'Path: A',}},
    ear1="Ishvara Earring",
    ear2={ name="Moonshade Earring", augments={'Accuracy+4','TP Bonus +250',}},
    ring1 ="Ephramad's Ring",
    ring2 = "", --needs update
    back={ name="Rudianos's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+5','Weapon skill damage +10%','Damage taken-5%',}},
}
	
	sets.precast.WS['Flat Blade'] = {
		ammo={ name="Coiste Bodhar", augments={'Path: A',}},
        head={ name="Nyame Helm", augments={'Path: B'}},
		neck="Erra Pendant",
        body={ name="Nyame Mail", augments={'Path: B'}},
		hands={ name="Nyame Gauntlets", augments={'Path: B'}},
		ear1="Hermetic Earring",
		ear2="Telos Earring",
		ring1="Defending Ring",
		ring2="Stikini Ring",
        back={ name="Rudianos's Mantle", augments={'VIT+20','Eva.+10 /Mag. Eva.+10','Enmity+10'}},
		waist={ name="Sailfi Belt +1", augments={'Path: A'}},
		legs={ name="Nyame Flanchard", augments={'Path: B'}},
		feet={ name="Nyame Sollerets", augments={'Path: B'}}
	}

    sets.precast.WS['Sanguine Blade'] = { 
	ammo	= { name="Coiste Bodhar", augments={'Path: A',}},
    head	= "Chev. Armet +3",
    body	= "Sakpata's Plate",
    hands	= { name="Nyame Gauntlets", augments={'Path: B',}},
    legs	= "Chev. Cuisses +3",
    feet	= "Chev. Sabatons +3",
    neck	= { name="Kgt. Beads +2", augments={'Path: A',}},
    waist	= "Luminary Sash",
    ear1	= "Ishvara Earring",
    ear2	= "Nourish. Earring +1",
    ring1	= "Stikini Ring",
    ring2	= "Stikini Ring",
    back	= { name="Rudianos's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+5','Weapon skill damage +10%','Damage taken-5%',}},
}

    sets.precast.WS['Atonement'] = {
	ammo	= "Paeapua",
    head	= { name="Loess Barbuta", augments={'Path: A',}},
    body	= { name="Sakpata's Plate", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    hands	= { name="Sakpata's Gauntlets", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    legs	= { name="Sakpata's Cuisses", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    feet	= "Eschite Greaves",
    neck	= { name="Loricate Torque +1", augments={'Path: A'}},
    waist	= "Creed Baudrier",
    ear1	= "Trux Earring",
    ear2	= "Cryptic Earring",
    ring1	= "Chirich Ring +1",
    ring2	= "Chirich Ring +1",
    back	= { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Accuracy+4','Enmity+10','Mag. Evasion+15',}},
	} 
	
	sets.precast.WS['Knights of Round'] = {
	ammo	= "Coiste Bodhar",
	head	= "Null Masque",
    body	= "Nyame Mail",
    hands	= "Nyame Gauntlets",
    legs	= "Nyame Flanchard",
    feet	= "Nyame Sollerets",
    neck	= "Null Loop",
    waist	= "Null Belt",
    ear1	= "Ishvara Earring",
    ear2	= "Ishvara Earring",
    ring1	= { name="Metamor. Ring +1", augments={'Path: A'}},
    ring2	= "Ephramad's Ring",
    back	= { name="Rudianos's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+5','Weapon skill damage +10%','Damage taken-5%',}},
	}
	
	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {ear1="Cessance Earring",ear2="Brutal Earring",}
	sets.AccMaxTP = {ear1="Telos Earring",ear2="Telos Earring"}


	--------------------------------------
	-- Midcast sets
	--------------------------------------

    sets.midcast.FastRecast = {
    ammo="Staunch Tathlum +1",             -- DT-3%, SIRD+11%
    head="Sakpata's Helm",                -- Fast Cast+14%
    neck="Loricate Torque +1",             -- DT-6%, HP+60
    body="Rev. Surcoat +4",                -- Fast Cast+15%, Enmity+10
    hands="Leyline Gloves",                -- Fast Cast+8%, M.Acc+25
    feet="Founder's Greaves",               -- Fast Cast+5–7% (augmented), HP+20
	legs="Rawhide Trousers",                 -- Fast Cast+8%, DT-3%
	waist="Creed Baudrier",                -- Enmity+5
	ring1="Defending Ring",            -- DT-7%, Enmity+3
    ring2={ name="Murky Ring", augments={'Path: A'}},                -- DT-5%, HP+110
	ear1="Odnowa Earring",                 -- HP+150
    ear2="Chev. Earring +1",              -- DT-3%, HP+110
	back={ name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Spell interruption rate down-10%',}},
}
	
		
	sets.midcast.FastRecast.DT = {
    ammo="Staunch Tathlum +1",             -- DT-3%, SIRD+11%
    head="Sakpata's Helm",                -- Fast Cast+14%
    neck="Loricate Torque +1",             -- DT-6%, HP+60
    body="Rev. Surcoat +4",                -- Fast Cast+15%, Enmity+10
    hands="Leyline Gloves",                -- Fast Cast+8%, M.Acc+25
    feet="Founder's Greaves",               -- Fast Cast+5–7% (augmented), HP+20
	legs="Rawhide Trousers",                 -- Fast Cast+8%, DT-3%
	waist="Creed Baudrier",                -- Enmity+5
	ring1="Defending Ring",            -- DT-7%, Enmity+3
    ring2={ name="Murky Ring", augments={'Path: A'}},                -- DT-5%, HP+110
	ear1="Odnowa Earring",                 -- HP+150
    ear2="Chev. Earring +1",              -- DT-3%, HP+110
	back={ name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Spell interruption rate down-10%',}},
}
	

	sets.midcast["Jettatura"] = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3%
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+

	sets.midcast["Blank Gaze"] = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3%
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+

	sets.midcast["Sheep Song"] = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3%
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+

	sets.midcast["Geist Wall"] = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3% 
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+

	sets.midcast["Pollen"] = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3% 
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+

	sets.midcast["Healing Breeze"] = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3% 
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+

	sets.midcast["Sandspin"] = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3% 
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+

	sets.midcast["Wild Carrot"] = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3% 
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+

	sets.midcast["Magic Fruit"] = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3% 
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+

	sets.midcast["Metallic Body"] = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3% 
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+
	
	
    sets.midcast.Flash = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3% 
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+
	
	sets.midcast.Flash.SIRD = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3%
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+
	
    sets.midcast.Stun = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3% 
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+
	
	sets.midcast.Stun.SIRD = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3% 
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+
	
	sets.midcast['Blue Magic'] = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3% 
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+
	
	sets.midcast['Blue Magic'].SIRD = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3% 
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+
	
	sets.midcast.Cocoon = {
	
	ammo  = "Staunch Tathlum +1",         -- SIRD+11%, DT-3%
	head  = "Sakpata's Helm",          -- SIRD+20%, Enmity+9, Cure Potency Rec.+15%
	body  = "Chev. Cuirass +3",           -- SIRD+20%, Enmity+7, DT-10%
	hands = "Chev. Gauntlets +3",         -- Enmity+9, HP+88 (geen SIRD)
	legs  = "Kaykaus Tights +1",             -- SIRD+30% (augmented)
	feet  = "Chev. Sabatons +3",          -- Enmity+15, Fast Cast+13%, MEVA+136
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},         -- SIRD+15%, Enmity+15, M.Acc+15, MEVA+15
	waist = "Rumination Sash",              -- SIRD+10%
	ear1  = "Cryptic Earring",            -- Enmity+4
	ear2  = "Chev. Earring +1",           -- SIRD+3% 
	ring1 = "Supershear Ring",                -- Enmity+5
	ring2 = "Supershear Ring",            -- Enmity+5
	back  = { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',  }},
	} -- maximum SIRD and Enmity ( 100+ ) with Burtgang/Duban DT- 50+

    sets.midcast.Cure = {
    ammo="Staunch Tathlum +1",             -- DT-3%, SIRD+11%
    head="Sakpata's Helm",              -- Cure Potency+10%, Enmity+9
    body="Chev. Cuirass +3",         -- SIRD+20%, Enmity+10
    hands="Cab. Gauntlets +4",          -- Cure Potency+11%, Enmity+7
    legs="Kaykaus Tights +1",                 -- SIRD+30%, MND+
    feet="Founder's Greaves",               -- SIRD+20% (augmented), HP+
    neck="Sacro Gorget",                   -- Cure Potency+10%, Enmity+5
    waist="Rumination Sash",               -- SIRD+10%, MND+4
    ear1={ name="Nourish. Earring +1", augments={'Path: A'}},                 -- Cure Potency+5%
    ear2="Sanare Earring",                 -- 
    ring1="Defending Ring",                -- DT-5%, HP+110
    ring2={ name="Murky Ring", augments={'Path: A'}},                -- DT-5%, HP+110
    back={name="Rudianos's Mantle",augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Spell interruption rate down-10%',}}
}
		
    sets.midcast.Cure.SIRD = {
    ammo="Staunch Tathlum +1",             -- DT-3%, SIRD+11%
    head="Sakpata's Helm",              -- Cure Potency+10%, Enmity+9
    body="Chev. Cuirass +3",         -- SIRD+20%, Enmity+10
    hands="Cab. Gauntlets +4",          -- Cure Potency+11%, Enmity+7
    legs="Kaykaus Tights +1",                 -- SIRD+30%, MND+
    feet="Founder's Greaves",               -- SIRD+20% (augmented), HP+
    neck="Sacro Gorget",                   -- Cure Potency+10%, Enmity+5
    waist="Rumination Sash",               -- SIRD+10%, MND+4
    ear1={ name="Nourish. Earring +1", augments={'Path: A'}},                 -- Cure Potency+5%
    ear2="Sanare Earring",                 -- 
    ring1="Defending Ring",                -- DT-5%, HP+110
    ring2={ name="Murky Ring", augments={'Path: A'}},                -- DT-5%, HP+110
    back={name="Rudianos's Mantle",augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Spell interruption rate down-10%',}}
}
		
    sets.midcast.Cure.DT ={
    
    ammo="Staunch Tathlum +1",             -- DT-3%, SIRD+11%
    head="Sakpata's Helm",              -- Cure Potency+10%, Enmity+9, HP+100
    body="Sakpata's Plate",               -- SIRD+15%, HP+130
    hands="Cab. Gauntlets +4",          -- Cure Potency+11%, Enmity+7
    legs="Kaykaus Tights +1",                 -- SIRD+30%, MND+20
    feet="Founder's Greaves",               -- SIRD+20%, HP+20
    neck="Incanter's Torque",              -- Healing Magic Skill+10
    waist="Rumination Sash",               -- SIRD+10%, MND+4
    ear1={ name="Nourish. Earring +1", augments={'Path: A'}},                 -- Cure Potency+5%
    ear2="Sanare Earring",                 -- 
    ring1="Defending Ring",                -- DT-5%, HP+110, MP+110
    ring2={ name="Murky Ring", augments={'Path: A'}},                -- DT-5%, HP+110, MP+110
    back= { name="Rudianos's Mantle", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+4','Enmity+10','Mag. Evasion+15',}},
}
		
	sets.midcast.CureSelf     = set_combine(sets.midcast.Cure, {})
	sets.midcast.CureSelf.SIRD = set_combine(sets.midcast.Cure.SIRD, {})
	sets.midcast.CureSelf.DT   = set_combine(sets.midcast.Cure.DT, {})

    sets.midcast.Reprisal = {
	
	ammo="Staunch Tathlum +1",
    head="Chev. Armet +3",
    body={ name="Cab. Surcoat +4", augments={'Enhances "Fealty" effect',}},
    hands="Chev. Gauntlets +3",
    legs="Chev. Cuisses +3",
    feet="Rev. Leggings +4",
    neck={ name="Loricate Torque +1", augments={'Path: A'}},
    waist="Rumination Sash",
    ear1="Cryptic Earring",
    ear2="Chev. Earring +1",
    ring1="Defending Ring",
    ring2="Defending Ring",
    back={ name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Spell interruption rate down-10%',}},
}

	sets.Self_Healing = {
	ammo="Staunch Tathlum +1",
    head={ name="Sakpata's Helm", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    body="Sakpata's Plate",
    hands={ name="Sakpata's Gauntlets", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    legs={ name="Kaykaus Tights +1", augments={'MND+5','Mag. Acc.+2','Breath dmg. taken -2%',}},
    feet={ name="Founder's Greaves", augments={'Accuracy+30','"Fast Cast"+6','VIT+5',}},
    neck={ name="Loricate Torque +1", augments={'Path: A'}},
    waist="Rumination Sash",
    ear1={ name="Nourish. Earring +1", augments={'Path: A',}},
    ear2="Chev. Earring +1",
    ring1="Defending Ring",
    ring2={ name="Murky Ring", augments={'Path: A'}},
    back={ name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Spell interruption rate down-10%',}},

}		
		
	sets.Self_Healing.SIRD = {
	ammo="Staunch Tathlum +1",
    head={ name="Sakpata's Helm", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    body="Sakpata's Plate",
    hands={ name="Sakpata's Gauntlets", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    legs={ name="Kaykaus Tights +1", augments={'MND+5','Mag. Acc.+2','Breath dmg. taken -2%',}},
    feet={ name="Founder's Greaves", augments={'Accuracy+30','"Fast Cast"+6','VIT+5',}},
    neck={ name="Loricate Torque +1", augments={'Path: A'}},
    waist="Rumination Sash",
    ear1={ name="Nourish. Earring +1", augments={'Path: A',}},
    ear2="Chev. Earring +1",
    ring1="Defending Ring",
    ring2={ name="Murky Ring", augments={'Path: A'}},
    back={ name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Spell interruption rate down-10%',}},

}		
	sets.Self_Healing.DT = {
	ammo	= "Staunch Tathlum",
    head	= "Chev. Armet +3",
    body	= { name="Sakpata's Plate", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    hands	= { name="Cab. Gauntlets +4", augments={'Path: A',}},
    legs	= "Chev. Cuisses +3",
    feet	= { name="Founder's Greaves", augments={'Attack+15','"Cure" potency +4%','Mag. Acc.+6','"Mag.Atk.Bns."+6',}},
    neck	= { name="Loricate Torque +1", augments={'Path: A'}},
    waist	= "Plat. Mog. Belt",
    ear1	= "Nourish. Earring +1",
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back	= { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Accuracy+4','Enmity+10','Mag. Evasion+15',}},
}
        
	
    sets.midcast['Enhancing Magic'] = {
    
    ammo="Staunch Tathlum +1",
    head={ name="Sakpata's Helm", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    body={ name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},
    hands="Regal Gloves",
    legs={ name="Kaykaus Tights +1", augments={'MND+5','Mag. Acc.+2','Breath dmg. taken -2%',}},
    feet={ name="Founder's Greaves", augments={'Accuracy+30','"Fast Cast"+6','VIT+5',}},
    neck={ name="Loricate Torque +1", augments={'Path: A'}},
    waist="Rumination Sash",
    ear1 ="Odnowa Earring",
    ear2 ="Chev. Earring +1",
    ring1 ="Defending Ring",
    ring2 ={ name="Murky Ring", augments={'Path: A'}},
    back={ name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Spell interruption rate down-10%',}},
}
		
    sets.midcast['Enhancing Magic'].SIRD = {
    
    ammo="Staunch Tathlum +1",
    head={ name="Sakpata's Helm", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    body={ name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},
    hands="Regal Gloves",
    legs={ name="Kaykaus Tights +1", augments={'MND+5','Mag. Acc.+2','Breath dmg. taken -2%',}},
    feet={ name="Founder's Greaves", augments={'Accuracy+30','"Fast Cast"+6','VIT+5',}},
    neck={ name="Loricate Torque +1", augments={'Path: A'}},
    waist="Rumination Sash",
    ear1 ="Odnowa Earring",
    ear2 ="Chev. Earring +1",
    ring1 ="Defending Ring",
    ring2 ={ name="Murky Ring", augments={'Path: A'}},
    back={ name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Spell interruption rate down-10%',}},
}

	sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {waist="Siegel Sash"})

    sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {ring2="Defending Ring"})
    sets.midcast.Shell = set_combine(sets.midcast['Enhancing Magic'], {ring2="Defending Ring"})
	
	-- Phalanx casting set (Rhandalthor gear - upgrade as inventory allows)
	sets.midcast.Phalanx = {
    main	= "Sakpata's Sword",
    sub		= "Priwen",
    ammo	= "Staunch Tathlum +1",
    head	= gear.valorous_phalanx_tank_head,
    body	= gear.valorous_phalanx_tank_body,
    hands	= gear.valorous_phalanx_tank_hands,
    legs	= gear.valorous_phalanx_tank_legs,
    feet	= gear.valorous_phalanx_tank_feet,
    neck	= "Incanter's Torque",
    waist	= "Olympus Sash",
    ear1	= "Mimir Earring",
    ear2	= "Andoaa Earring",
    ring1	= "Stikini Ring +1",
    ring2	= "Stikini Ring +1",
    back	= { name="Weard Mantle", augments={'VIT+2','DEX+4','Enmity+5','Phalanx +5',}},
	}

	-- Phalanx SIRD variant (max spell interruption resistance)
	sets.midcast.Phalanx.SIRD = {
    ammo	= "Staunch Tathlum +1",
    head	= "Souv. Schaller +1",
    body	= { name="Odyss. Chestplate", augments={'Mag. Acc.+16','Sklchn.dmg.+1%','Phalanx +4','Accuracy+8 Attack+8','Mag. Acc.+20 "Mag.Atk.Bns."+20',}},
    hands	= "Souv. Handsch. +1",
    legs	= "Founder's Hose",
    feet	= "Souveran Schuhs +1",
    neck	= "Moonlight Necklace",
    waist	= "Audumbla Sash",
    ear1	= "Knightly Earring",
    ear2	= "Nourish. Earring +1",
    ring1	= "Evanescence Ring",
    ring2	= "Moonlight Ring",
    back	= "Weard Mantle",
	}

	-- Phalanx DT variant (damage taken reduction while casting)
	sets.midcast.Phalanx.DT = {
    ammo	= "Staunch Tathlum +1",
    head	= "Souv. Schaller +1",
    body	= "Yorium Cuirass",
    hands	= "Souv. Handsch. +1",
    legs	= "Founder's Hose",
    feet	= "Souveran Schuhs +1",
    neck	= "Moonlight Necklace",
    waist	= "Audumbla Sash",
    ear1	= "Knightly Earring",
    ear2	= "Nourish. Earring +1",
    ring1	= "Evanescence Ring",
    ring2	= "Moonlight Ring",
    back	= "Weard Mantle",
	}

	-- PhalanxWithWeapons: used for prephalanx command and self-cast pre-equip
	sets.midcast.PhalanxWithWeapons = set_combine(sets.midcast.Phalanx, {
    main	= "Sakpata's Sword",
    sub		= "Priwen",
	})
	--------------------------------------
	-- Idle/resting/defense/etc sets
	--------------------------------------
    
    -- Idle sets
  sets.idle = {
  ammo	= "Staunch Tathlum +1",
  head	= "Chev. Armet +3",
  body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
  hands	= "Chev. Gauntlets +3",
  legs	= "Chev. Cuisses +3",
  feet	= "Chev. Sabatons +3",
  neck	= { name="Kgt. Beads +2", augments={'Path: A',}},
  waist	= "Null Belt",
  ear1	= "Etiolation Earring",
  ear2	= "Chev. Earring +1",
  ring1 = "Defending Ring",
  ring2 = { name="Murky Ring", augments={'Path: A'}},
  back	= { name="Rudianos's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Damage taken-5%',}},
 }
 
  sets.idle.elemental = { 
  ammo	= "Staunch Tathlum +1",
  head	= "Chev. Armet +3",
  body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
  hands	= "Cab. Gauntlets +4",
  legs	= "Chev. Cuisses +3",
  feet	= "Rev. Leggings +4",
  neck	= "Warder's Charm +1",
  waist	= "Carrier's Sash",
  ear1	= "Sanare Earring",
  ear2	= "", --needs update
  ring1	= "Defending Ring",
  ring2	= { name="Murky Ring", augments={'Path: A'}},
  back={ name="Rudianos's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Damage taken-5%',}},
	}
	
  sets.idle.Statresist = { 
  ammo	= "Staunch Tathlum +1",
  head	= "Chev. Armet +3",
  body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
  hands	= "Cab. Gauntlets +4",
  legs	= "Chev. Cuisses +3",
  feet 	= "Rev. Leggings +4",
  neck	= "Warder's Charm +1",
  waist = "Carrier's Sash",
  ear1	= "Sanare Earring",
  ear2	= "", --needs update
  ring1	= "Defending Ring",
  ring2	= { name="Murky Ring", augments={'Path: A'}},
  back	= { name="Rudianos's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Damage taken-5%',}},
	}
	
	
sets.idle.Regen = {
  ammo	= "Staunch Tathlum +1",
  head	= "Null Masque",
  body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
  hands	= "Regal Gloves",
  legs	= "Chev. Cuisses +3",
  feet	= "Chev. Sabatons +3",
  neck	= "Elite Royal Collar",
  waist	= "Null Belt",
  ear1	= "Odnowa Earring",
  ear2	= "Chev. Earring +1",
  ring1	= "Chirich Ring +1",
  ring2	= "Chirich Ring +1",
  back	= { name="Rudianos's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','VIT+10','Enmity+10','"Regen"+5',}},
 }
 
  sets.idle.Aminon = {
  ammo		= "Staunch Tathlum +1",
  head		= "Null Masque",
  body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
  hands		= "Sakpata's Gauntlets",
  legs		= "Sakpata's Cuisses",
  feet		= "Sakpata's Leggings",
  neck		= "Incanter's Torque",
  waist		= "Asklepian Belt",
  ear1		= "Sanare Earring",
  ear2		= "Chev. Earring +1",
  ring1		= "Defending Ring",
  ring2		= { name="Murky Ring", augments={'Path: A'}},
  back		= { name="Rudianos's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Damage taken-5%',}},
	}
	
   sets.idle.MEVA = {
   ammo		= "Staunch Tathlum +1",
   head		= "Null Masque",
   body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
   hands	= { name="Cab. Gauntlets +4", augments={'Path: A',}},
   legs		= "Chev. Cuisses +3",
   feet		= { name="Sakpata's Leggings", augments={'HP+65','STR+12','Accuracy+13',}},
   neck		= "Warder's Charm +1",
   waist	= "Plat. Mog. Belt",
   ear1		= "Sanare Earring",
   ear2		= "", --needs update
   ring1	= "Defending Ring",
   ring2	= { name="Murky Ring", augments={'Path: A'}},
   back		= { name="Rudianos's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Damage taken-5%',}},
}
	
    sets.idle.Block = {
	ammo	= "Staunch Tathlum",
    head	= "Chev. Armet +3",
    body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
    hands	= "Sulev. Gauntlets +2",
    legs	= "Chev. Cuisses +3",
    feet	= "Rev. Leggings +4",
    neck	= "Null Loop",
    waist	= "Carrier's Sash",
    ear1	= "Genmei Earring",
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring	= "Moonlight Ring",
    back	= { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Accuracy+4','Enmity+10','Mag. Evasion+15',}},
}
		
    sets.idle.Tank = {
  ammo	= "Staunch Tathlum +1",
  head	= "Chev. Armet +3",
  body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
  hands	= "Regal Gloves",
  legs	= "Chev. Cuisses +3",
  feet	= "Chev. Sabatons +3",
  neck	= { name="Kgt. Beads +2", augments={'Path: A',}},
  waist	= "Null Belt",
  ear1	= "Etiolation Earring",
  ear2	= "Chev. Earring +1",
  ring1 = "Defending Ring",
  ring2 = { name="Murky Ring", augments={'Path: A'}},
  back	= { name="Rudianos's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Damage taken-5%',}},
 }
		
	sets.idle.Kiting = {
	ammo 	= "Homiliary",
    head	= "Chev. Armet +3",
    body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
    hands	= "Sulev. Gauntlets +2",
    legs	= "Chev. Cuisses +3",
    feet	= "Rev. Leggings +4",
    neck	= { name="Kgt. Beads +2", augments={'Path: A'}},
    waist	= "Carrier's Sash",
    ear1	= "Genmei Earring",
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring2 = { name="Shneddick Ring +1"},
    back	= { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Accuracy+4','Enmity+10','Mag. Evasion+15',}},
}

	sets.Kiting = {ring1 = { name="Shneddick Ring +1"}}

	sets.packing = {
		ammo    = "Homiliary",
		head    = "Null Masque",
		body    = "Sakpata's Plate",
		hands   = "Regal Gloves",
		legs    = "Sakpata's Cuisses",
		feet    = "Sakpata's Leggings",
		neck    = { name="Kgt. Beads +2", augments={'Path: A',}},
		waist   = "Fucho-no-obi",
		ear1    = "Etiolation Earring",
		ear2    = "Chev. Earring +1",
		ring1   = "Defending Ring",
		ring2   = { name="Murky Ring", augments={'Path: A'}},
		back    = { name="Rudianos's Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Damage taken-5%',}},
	}

	sets.latent_refresh = {waist="Fucho-no-obi"}
	sets.latent_refresh_grip = {sub="Oneiros Grip"}
	sets.latent_regen = {ring1="Chirich Ring +1",ring2="Chirich Ring +1"}
	sets.DayIdle = {}
	sets.NightIdle = {}

	--------------------------------------
    -- Defense sets
    --------------------------------------
    
    -- Extra defense sets.  Apply these on top of melee or defense sets.
	sets.Knockback = {}
    sets.MP = {head="Chev. Armet +3",neck="Incanter's Torque",ear2="Etiolation Earring",waist="Flume Belt +1",feet="Rev. Leggings +4"}
	sets.passive.AbsorbMP = {head="Chev. Armet +3",neck="Incanter's Torque",ear2="Etiolation Earring",waist="Flume Belt +1",feet="Rev. Leggings +4"}
    sets.MP_Knockback = {}
    sets.Twilight = {head="Twilight Helm", body="Twilight Mail"}
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
	
	-- Weapons sets
	sets.weapons.BurtgangPriwen = {main="Burtgang",sub={ name="Priwen", augments={'HP+50','Mag. Evasion+50','Damage Taken -3%'}}}
	sets.weapons.SakpataPriwen = {main="Sakpata's Sword",sub={ name="Priwen", augments={'HP+50','Mag. Evasion+50','Damage Taken -3%'}}}
	sets.weapons.NaeglingBlurred = {main="Naegling",sub="Blurred Shield +1"}
	sets.weapons.DualWeapons = {main="Naegling",sub={ name="Ternion Dagger +1", augments={'Path: A'}}}
	
    sets.defense.Block = {
	ammo	= "Staunch Tathlum",
    head	= "Chev. Armet +3",
    body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
    hands	= "Sulev. Gauntlets +2",
    legs	= "Chev. Cuisses +3",
    feet	= "Rev. Leggings +4",
    neck	= "Null Loop",
    waist	= "Carrier's Sash",
    ear1	= "Genmei Earring",
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring	= "Moonlight Ring",
    back	= { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Accuracy+4','Enmity+10','Mag. Evasion+15',}},
}

	sets.defense.Aminon = {
	ammo	= "Staunch Tathlum +1",
    head	= "Sakpata's Helm",
    body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
    hands	= "Sakpata's Gauntlets",
    legs	= "Sakpata's Cuisses",
    feet	= "Sakpata's Leggings",
    neck	= "Incanter's Torque",
    waist	= "Asklepian Belt",
    ear1  	= "Sanare Earring", 
	ear2  	= "Chev. Earring +1",  
    ring1	= "Defending Ring",
    ring2	= { name="Murky Ring", augments={'Path: A'}},
    back	= { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Accuracy+4','Enmity+10','Mag. Evasion+15',}},
	}
	
		
	sets.defense.PDT = {
	ammo	= "Homiliary",
    head	= "Chev. Armet +3",
    body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
    hands	= "Sakpata's Gauntlets",
    legs	= "Chev. Cuisses +3",
    feet	= "Sakpata's Leggings",
    neck	= "Elite Royal Collar",
    waist	= "Plat. Mog. Belt",
    ear1	= "Odnowa Earring",
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back	= { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Accuracy+4','Enmity+10','Mag. Evasion+15',}},
}
		
    sets.defense.PDT_HP = {
	ammo	= "Homiliary",
    head	= "Chev. Armet +3",
    body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
    hands	= "Sakpata's Gauntlets",
    legs	= "Chev. Cuisses +3",
    feet	= "Sakpata's Leggings",
    neck	= { name="Kgt. Beads +2", augments={'Path: A'}},
    waist	= "Plat. Mog. Belt",
    ear1	= "Odnowa Earring",
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back	= { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Accuracy+4','Enmity+10','Mag. Evasion+15',}},
}		

	sets.defense.MDT = {
	ammo	= "Homiliary",
    head	= "Chev. Armet +3",
    body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
    hands	= "Sakpata's Gauntlets",
    legs	= "Chev. Cuisses +3",
    feet	= "Sakpata's Leggings",
    neck	= "Elite Royal Collar",
    waist	= "Plat. Mog. Belt",
    ear1	= "Odnowa Earring",
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back	= { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Accuracy+4','Enmity+10','Mag. Evasion+15',}},
}		
		
    sets.defense.MDT_HP = {
	ammo	= "Homiliary",
    head	= "Chev. Armet +3",
    body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
    hands	= "Sakpata's Gauntlets",
    legs	= "Chev. Cuisses +3",
    feet	= "Sakpata's Leggings",
    neck	= { name="Kgt. Beads +2", augments={'Path: A'}},
    waist	= "Plat. Mog. Belt",
    ear1	= "Odnowa Earring",
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back	= { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Accuracy+4','Enmity+10','Mag. Evasion+15',}},
}		

	sets.defense.MEVA = {
    ammo 	= "Staunch Tathlum +1",               
    head 	= "Loess Barbuta",                 
    body	= "Adamantite Armor",                   -- DT-20%, MEVA+107, MDB+20
    hands 	= "Sakpata's Gauntlets",             
    legs	= "Chev. Cuisses +3",          
    feet	= "Sakpata's Leggings",              
    neck	= "Warder's Charm +1",               
    waist	= "Plat. Mog. Belt",                 
    ear1	= "Sanare Earring",
    ear2	= "Chev. Earring +1",           
    ring1 = "Defending Ring",                  
    ring2	= "Chirich Ring +1",                  
    back	= { name="Rudianos's Mantle", augments={'VIT+20','Enmity+10','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Damage taken-5%',}},
	}
		
    		
		
    sets.defense.PDT_Reraise = set_combine(sets.defense.PDT_HP,{head="Twilight Helm",body="Twilight Mail"})
    sets.defense.MDT_Reraise = set_combine(sets.defense.MDT_HP,{head="Twilight Helm",body="Twilight Mail"})
		
	--------------------------------------
	-- Engaged sets
	--------------------------------------
    
	sets.engaged = {
	ammo={ name="Coiste Bodhar", augments={'Path: A',}},
    head="Hjarrandi Helm",
    body="Hjarrandi Breast.",
    hands={ name="Sakpata's Gauntlets", augments={'Path: A'}},
    legs={ name="Nyame Flanchard", augments={'Path: B',}},
    feet={ name="Nyame Sollerets", augments={'Path: B',}},
    neck="Null Loop",
    waist={ name="Sailfi Belt +1", augments={'Path: A',}},
    ear1 ="Telos Earring",
    ear2 ="Dedition Earring",
    ring1 ="Chirich Ring +1",
    ring2 ={ name="Murky Ring", augments={'Path: A'}},
    back="Null Shawl",
	}
	
    sets.engaged.Acc = {
	ammo={ name="Coiste Bodhar", augments={'Path: A',}},
    head="Hjarrandi Helm",
    body="Hjarrandi Breast.",
    hands={ name="Sakpata's Gauntlets", augments={'Path: A'}},
    legs={ name="Nyame Flanchard", augments={'Path: B',}},
    feet={ name="Nyame Sollerets", augments={'Path: B',}},
    neck="Null Loop",
    waist={ name="Sailfi Belt +1", augments={'Path: A',}},
    ear1 = "Telos Earring",
    ear2 ="Dedition Earring",
    ring1 ="Chirich Ring +1",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back="Null Shawl",
	}

    sets.engaged.DW = {}

    sets.engaged.DW.Acc = {}

	sets.engaged.Tank = {
	ammo={ name="Coiste Bodhar", augments={'Path: A',}},
    head="Hjarrandi Helm",
    body="Hjarrandi Breast.",
    hands={ name="Sakpata's Gauntlets", augments={'Path: A'}},
    legs={ name="Nyame Flanchard", augments={'Path: B',}},
    feet={ name="Nyame Sollerets", augments={'Path: B',}},
    neck="Null Loop",
    waist={ name="Sailfi Belt +1", augments={'Path: A',}},
    ear1 = "Telos Earring",
    ear2 = "Dedition Earring",
    ring1 = "Chirich Ring +1",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back="Null Shawl",
	}
	
		
	sets.engaged.DDTank = {
	ammo={ name="Coiste Bodhar", augments={'Path: A',}},
    head="Hjarrandi Helm",
    body="Hjarrandi Breast.",
    hands={ name="Sakpata's Gauntlets", augments={'Path: A'}},
    legs={ name="Nyame Flanchard", augments={'Path: B',}},
    feet={ name="Nyame Sollerets", augments={'Path: B',}},
    neck="Null Loop",
    waist={ name="Sailfi Belt +1", augments={'Path: A',}},
    ear1 = "Telos Earring",
    ear2 = "Dedition Earring",
    ring1 = "Chirich Ring +1",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back="Null Shawl",
	}
		
	sets.engaged.Acc.DDTank = {
	ammo={ name="Coiste Bodhar", augments={'Path: A',}},
    head="Hjarrandi Helm",
    body="Hjarrandi Breast.",
    hands={ name="Sakpata's Gauntlets", augments={'Path: A'}},
    legs={ name="Nyame Flanchard", augments={'Path: B',}},
    feet={ name="Nyame Sollerets", augments={'Path: B',}},
    neck="Null Loop",
    waist={ name="Sailfi Belt +1", augments={'Path: A',}},
    ear1 = "Telos Earring",
    ear2 = "Dedition Earring",
    ring1 = "Chirich Ring +1",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back="Null Shawl",
	}
		
	sets.engaged.NoShellTank = {
	ammo={ name="Coiste Bodhar", augments={'Path: A',}},
    head="Hjarrandi Helm",
    body="Hjarrandi Breast.",
    hands={ name="Sakpata's Gauntlets", augments={'Path: A'}},
    legs={ name="Nyame Flanchard", augments={'Path: B',}},
    feet={ name="Nyame Sollerets", augments={'Path: B',}},
    neck="Null Loop",
    waist={ name="Sailfi Belt +1", augments={'Path: A',}},
    ear1 = "Telos Earring",
    ear2 = "Dedition Earring",
    ring1 = "Chirich Ring +1",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back="Null Shawl",
	}
		
    sets.engaged.Reraise = set_combine(sets.engaged.Tank, sets.Reraise)
    sets.engaged.Acc.Reraise = set_combine(sets.engaged.Acc.Tank, sets.Reraise)
		
	--------------------------------------
	-- Custom buff sets
	--------------------------------------
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = {neck="Vim Torque +1"}
    sets.buff.Cover = {body="Cab. Surcoat +4"}
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'NIN' then
        set_macro_page(1, 7)
    elseif player.sub_job == 'RUN' then
        set_macro_page(1, 7)
    elseif player.sub_job == 'RDM' then
        set_macro_page(1, 7)
    elseif player.sub_job == 'BLU' then
        set_macro_page(1, 7)
    elseif player.sub_job == 'DNC' then
        set_macro_page(1, 7)
    else
        set_macro_page(1, 7) --War/Etc
    end
	
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

function job_precast(spell, action, spellMap, eventArgs)
    if spell.english == 'Phalanx' then
        self_cast_phalanx = true
        phalanx_saved_weapons = state.Weapons.value
    elseif spell.english == 'Phalanx II' then
        -- Phalanx II is cast by a RDM on you; self_cast_phalanx stays false
     elseif spell.english == 'Reprisal' then
        equip({ body={ name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}} }) 
    end
end

function job_midcast(spell, action, spellMap, eventArgs)
    if spell.english == 'Reprisal' then
        equip(sets.midcast.Reprisal)
    elseif spell.english:match('Phalanx') then
        enable('main', 'sub')
        equip(sets.midcast.Phalanx)
        if eventArgs then eventArgs.handled = true end
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.english:startswith('Cure') then
        if spell.target.type == 'SELF' then
            equip(sets.midcast.CureSelf)
        else
            equip(sets.midcast.Cure)
        end
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.english == 'Phalanx' then
        self_cast_phalanx = false
    end
    if not spell.interrupted then
        enable('waist')
        local idleSet = sets.idle and sets.idle[state.IdleMode.current] or sets.idle
        if idleSet then
            equip(idleSet)
        end
    end
end

-- Phalanx state machine: hold Sakpata+Priwen locked while phalanx_holding is true.
-- This prevents normal weapon swaps from firing until Phalanx lands or expires.
function job_handle_equipping_gear(playerStatus, eventArgs)
    if phalanx_holding then
        equip({main="Sakpata's Sword", sub="Priwen"})
        eventArgs.handled = true
    end
end

function job_buff_change(buff, gain)
    if buff == 'Phalanx' then
        if gain then
            send_command('input /p Phalanx up! Let\'s get weird!')
            -- Only auto-restore weapons when Phalanx was received from another player.
            -- If WE cast it (self_cast_phalanx == true), let normal gear logic handle it.
            if not self_cast_phalanx then
                coroutine.schedule(function()
                    phalanx_holding = false
                    enable('main', 'sub')
                    send_command('gs c set Weapons ' .. phalanx_saved_weapons)
                    send_command('@wait 0.1;gs c update')
                end, 2)
            end
        else
            -- Phalanx expired: release lock and restore weapon set
            phalanx_holding = false
            enable('main', 'sub')
            send_command('gs c set Weapons ' .. state.Weapons.value)
            send_command('@wait 0.1;gs c update')
            send_command('input /p Phalanx expired.')
        end
    end
end

windower.register_event('addon command', function(cmd)
    if cmd == 'prephalanx' then
        equip(sets.midcast.PhalanxWithWeapons)
        send_command('input /p 🛡️ Ready to receive Phalanx II – mitigation set active!')
    elseif cmd == 'endphalanx' then
        enable('main','sub')
        send_command('gs c update')
    end
end)

local danger_list = S{
    'sleep', 'silence', 'paralyze', 'break', 'petrify', 'slow', 'stun', 'bind', 'gravity',
    'defense down', 'magic evasion down', 'magic def. down', 'magic def down', 'max hp down', 
    'max mp down', 'attack down', 'accuracy down', 'evasion down', 'bio', 'dia', 'curse', 
    'amnesia', 'doom', 'terror', 'plague', 'blind', 'weight', 'death', 'charm', 'vit down',
    'dex down', 'agi down', 'str down', 'int down', 'mnd down', 'chr down', 'blight'
}

-- Triggers for enemy actions
local stat_triggers = S{'starts casting', 'is preparing', 'readies'}

windower.register_event('incoming text', function(original, modified, mode, mode_modified, blocked)
    if original == nil or original == '' then return end
    
    local str = original:lower()
    local player_name = player.name:lower()

    -- Phalanx II pre-equip: detect when someone starts casting Phalanx on us.
    -- Pre-equip Sakpata+Priwen and hold weapons until the buff lands (job_buff_change handles release).
    if str:contains(player_name) and str:contains('starts casting') and str:contains('phalanx') then
        if not self_cast_phalanx then
            phalanx_saved_weapons = state.Weapons.value
            enable('main', 'sub')
            equip({main="Sakpata's Sword", sub="Priwen"})
            phalanx_holding = true
        end
    end

    -- Check if you are the target in the combat log (Statresist detection)
    if str:contains(player_name) then
        local is_action = false
        for trigger in stat_triggers:it() do
            if str:contains(trigger) then
                is_action = true
                break
            end
        end
        
        if is_action then
            for danger in danger_list:it() do
                if str:contains(danger) then
                    if sets.idle.Statresist then
                        equip(sets.idle.Statresist)
                        
                        -- Lock slots to ensure the hit lands in the correct gear
                        disable('head','body','hands','legs','feet','neck','waist','ear1','ear2','ring1','ring2','back','ammo')
                        
                        add_to_chat(158, '[Statresist] Danger detected: '..danger..' - Locking gear.')
                        
                        -- Release after 3 seconds (standard monster action time)
                        coroutine.schedule(function()
                            enable('head','body','hands','legs','feet','neck','waist','ear1','ear2','ring1','ring2','back','ammo')
                            send_command('gs c update')
                            add_to_chat(158, '[Statresist] Gear released.')
                        end, 3)
                    end
                    break
                end
            end
        end
    end
end)