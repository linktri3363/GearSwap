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
    -- Options: Override default values
    state.OffenseMode:options('Normal', 'Acc')
    state.HybridMode:options('Tank', 'DDTank', 'Normal')
    state.WeaponskillMode:options('Match', 'Normal', 'Acc')
    state.CastingMode:options('Normal', 'SIRD')
    state.Passive:options('None', 'AbsorbMP')
    state.PhysicalDefenseMode:options('PDT_HP', 'PDT', 'PDT_Reraise')
    state.MagicalDefenseMode:options('MDT_HP', 'MDT', 'MDT_Reraise')
    state.ResistDefenseMode:options('MEVA_HP', 'MEVA')
    state.IdleMode:options('Tank', 'Kiting', 'PDT', 'Block', 'MDT', 'Normal')
    state.Weapons:options('None', 'SakpataBlurred', 'SakpataGenmei', 'NaeglingBlurred', 'ClubBlurred','DualWeapons')

    state.ExtraDefenseMode = M{['description'] = 'Extra Defense Mode', 'None', 'MP', 'Twilight'}

    -- Define missing gear variables with proper syntax
    gear.odyssean_fc_legs = {name="Odyssean Cuisses", augments={'"Fast Cast"+6','CHR+7','Mag. Acc.+6','"Mag.Atk.Bns."+2'}}
    gear.valorous_wsd_body = {name="Valorous Mail", augments={'Accuracy+17','Weapon skill damage +4%','STR+8','Attack+15'}}
    gear.odyssean_wsd_hands = {name="Odyssean Gauntlets", augments={'Accuracy+22','Weapon skill damage +4%','STR+8'}}

    gear.fastcast_jse_back = {name="Rudianos's Mantle", augments={'INT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Fast Cast"+10'}}
    gear.enmity_jse_back = {name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10'}}

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
end

function init_gear_sets()
    --------------------------------------
    -- Precast sets
    --------------------------------------

    -- OPTIMIZED: Fixed gear availability, added Alabaster Earring and Murky Ring
    -- NOTE: Chevalier Earring +1 MUST be in ear2 slot
    sets.Enmity = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = "Loess Barbuta",
        neck = "Unmoving Collar",
        ear1 = "Trux Earring",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = gear.enmity_jse_back,
        waist = "Creed Baudrier",
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Eschite Greaves", augments={'HP+80','Enmity+7','Phys. dmg. taken -4'}}
    }

    -- OPTIMIZED: Added Murky Ring for SIRD+3% and DT-10%, upgraded to Chevalier pieces
    -- NOTE: Chevalier Earring +1 MUST be in ear2 slot
    sets.Enmity.SIRD = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = {name="Loricate Torque +1", augments={'Path: A'}},
        ear1 = "Trux Earring",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = gear.enmity_jse_back,
        waist = "Rumination Sash",
        legs = {name="Founder's Greaves", augments={'VIT+10','Accuracy+15','"Mag.Atk.Bns."+15','Mag. Evasion+15'}},
        feet = {name="Founder's Greaves", augments={'VIT+10','Accuracy+15','"Mag.Atk.Bns."+15','Mag. Evasion+15'}}
    }

    -- OPTIMIZED: Added Murky Ring for DT-10%, Chev Earring for DT-4%
    -- NOTE: Chevalier Earring +1 MUST be in ear2 slot
    sets.Enmity.DT = {
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = "Unmoving Collar",
        ear1 = "Odnowa Earring",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = "Creed Baudrier",
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    -- Precast sets to enhance JAs
    sets.precast.JA["Invincible"] = set_combine(sets.Enmity, {legs = "Cab. Breeches +1"})
    sets.precast.JA["Holy Circle"] = set_combine(sets.Enmity, {feet = "Rev. Leggings +1"})
    sets.precast.JA["Sentinel"] = set_combine(sets.Enmity, {feet = "Cab. Leggings +1"})
    sets.precast.JA["Rampart"] = set_combine(sets.Enmity, {})
    sets.precast.JA["Fealty"] = set_combine(sets.Enmity, {body = "Cab. Surcoat +1"})
    sets.precast.JA["Divine Emblem"] = set_combine(sets.Enmity, {feet = "Chev. Sabatons +2"})
    sets.precast.JA["Cover"] = set_combine(sets.Enmity, {body = "Cab. Surcoat +1"})

    sets.precast.JA["Invincible"].DT = set_combine(sets.Enmity.DT, {legs = "Cab. Breeches +1"})
    sets.precast.JA["Holy Circle"].DT = set_combine(sets.Enmity.DT, {feet = "Rev. Leggings +1"})
    sets.precast.JA["Sentinel"].DT = set_combine(sets.Enmity.DT, {feet = "Cab. Leggings +1"})
    sets.precast.JA["Rampart"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["Fealty"].DT = set_combine(sets.Enmity.DT, {body = "Cab. Surcoat +1"})
    sets.precast.JA["Divine Emblem"].DT = set_combine(sets.Enmity.DT, {feet = "Chev. Sabatons +2"})
    sets.precast.JA["Cover"].DT = set_combine(sets.Enmity.DT, {body = "Cab. Surcoat +1"})

    -- add mnd for Chivalry
    sets.precast.JA["Chivalry"] = {
        ammo = "Staunch Tathlum +1",
        head = {name="Nyame Helm", augments={'Path: B'}},
        neck = "Unmoving Collar",
        ear1 = {name="Nourish. Earring +1", augments={'Path: A'}},
        ear2 = "Etiolation Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = "Cab. Gauntlets +1",
        ring1 = "Stikini Ring +1",
        ring2 = "Stikini Ring +1",
        back = gear.enmity_jse_back,
        waist = "Luminary Sash",
        legs = {name="Nyame Flanchard", augments={'Path: B'}},
        feet = "Carmine Greaves +1"
    }

    sets.precast.JA["Chivalry"].DT = {
        ammo = "Staunch Tathlum +1",
        head = {name="Nyame Helm", augments={'Path: B'}},
        neck = "Unmoving Collar",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = "Cab. Gauntlets +1",
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = "Luminary Sash",
        legs = {name="Nyame Flanchard", augments={'Path: B'}},
        feet = "Carmine Greaves +1"
    }

    sets.precast.JA["Shield Bash"] = set_combine(sets.Enmity, {hands = "Cab. Gauntlets +1"})
    sets.precast.JA["Provoke"] = set_combine(sets.Enmity, {})
    sets.precast.JA["Warcry"] = set_combine(sets.Enmity, {})
    sets.precast.JA["Palisade"] = set_combine(sets.Enmity, {})
    sets.precast.JA["Intervene"] = set_combine(sets.Enmity, {})
    sets.precast.JA["Defender"] = set_combine(sets.Enmity, {})
    sets.precast.JA["Berserk"] = set_combine(sets.Enmity, {})
    sets.precast.JA["Aggressor"] = set_combine(sets.Enmity, {})

    sets.precast.JA["Shield Bash"].DT = set_combine(sets.Enmity.DT, {hands = "Cab. Gauntlets +1"})
    sets.precast.JA["Provoke"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["Warcry"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["Palisade"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["Intervene"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["Defender"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["Berserk"].DT = set_combine(sets.Enmity.DT, {})
    sets.precast.JA["Aggressor"].DT = set_combine(sets.Enmity.DT, {})

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {
        ammo = "Staunch Tathlum +1",
        head = {name="Nyame Helm", augments={'Path: B'}},
        neck = "Unmoving Collar",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = "Regal Gauntlets",
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = "Chaac Belt",
        legs = {name="Nyame Flanchard", augments={'Path: B'}},
        feet = {name="Nyame Sollerets", augments={'Path: B'}}
    }

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz["Healing Waltz"] = {}

    sets.precast.Step = {
        ammo = "Staunch Tathlum +1",
        head = "Carmine Mask +1",
        neck = "Combatant's Torque",
        ear1 = {name="Alabaster Earring", augments={'Path: A'}},
        ear2 = "Telos Earring",
        body = "Chev. Cuirass +2",
        hands = "Regal Gauntlets",
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = gear.enmity_jse_back,
        waist = "Olseni Belt",
        legs = "Carmine Cuisses +1",
        feet = "Chev. Sabatons +2"
    }

    sets.precast.JA["Violent Flourish"] = {
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = "Unmoving Collar",
        ear1 = {name="Alabaster Earring", augments={'Path: A'}},
        ear2 = "Telos Earring",
        body = "Chev. Cuirass +2",
        hands = "Chev. Gauntlets +2",
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = gear.enmity_jse_back,
        waist = "Olseni Belt",
        legs = "Chev. Cuisses +2",
        feet = "Chev. Sabatons +2"
    }

    sets.precast.JA["Animated Flourish"] = set_combine(sets.Enmity, {})

    -- OPTIMIZED: Added Murky Ring for SIRD, use Rawhide Trousers for FC+5%
    -- Fast cast sets for spells
    sets.precast.FC = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Chanter's Shield",
        ammo = "Staunch Tathlum +1",
        head = {name="Carmine Mask +1", augments={'Accuracy+20','Mag. Acc.+12','"Fast Cast"+4'}},
        neck = "Voltsurge Torque",
        ear1 = "Loquac. Earring",
        ear2 = "Etiolation Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = "Leyline Gloves",
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Kishar Ring",
        back = gear.fastcast_jse_back,
        waist = "Creed Baudrier",
        legs = {name="Rawhide Trousers", augments={'MP+50','"Fast Cast"+5','"Refresh"+1'}},
        feet = {name="Founder's Greaves", augments={'VIT+10','Accuracy+15','"Mag.Atk.Bns."+15','Mag. Evasion+15'}}
    }

    -- OPTIMIZED: Added Murky Ring for SIRD+3% and DT-10%
    sets.precast.FC.DT = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = {name="Loricate Torque +1", augments={'Path: A'}},
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = "Creed Baudrier",
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    sets.precast.FC["Enhancing Magic"] = set_combine(sets.precast.FC, {waist = "Siegel Sash"})
    sets.precast.FC["Enhancing Magic"].DT = set_combine(sets.precast.FC.DT, {waist = "Siegel Sash"})

    sets.precast.FC.Cure = set_combine(sets.precast.FC, {
        neck = "Diemer Gorget", 
        ear1 = {name="Nourish. Earring +1", augments={'Path: A'}},
        body = "Jumalik Mail"
    })

    -- Weaponskill sets
    sets.precast.WS = {
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = "Unmoving Collar",
        ear1 = {name="Alabaster Earring", augments={'Path: A'}},
        ear2 = "Brutal Earring",
        body = "Chev. Cuirass +2",
        hands = "Chev. Gauntlets +2",
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = gear.enmity_jse_back,
        waist = "Fotia Belt",
        legs = {name="Nyame Flanchard", augments={'Path: B'}},
        feet = {name="Nyame Sollerets", augments={'Path: B'}}
    }

    -- OPTIMIZED: Added Murky Ring for DT-10%
    sets.precast.WS.DT = {
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = {name="Loricate Torque +1", augments={'Path: A'}},
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = "Creed Baudrier",
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    -- OPTIMIZED: Added Alabaster Earring for accuracy and Murky Ring
    sets.precast.WS.Acc = {
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = "Combatant's Torque",
        ear1 = {name="Alabaster Earring", augments={'Path: A'}},
        ear2 = "Telos Earring",
        body = "Chev. Cuirass +2",
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = gear.enmity_jse_back,
        waist = "Olseni Belt",
        legs = "Carmine Cuisses +1",
        feet = {name="Nyame Sollerets", augments={'Path: B'}}
    }

    -- Specific weaponskill sets
    sets.precast.WS["Requiescat"] = set_combine(sets.precast.WS, {
        neck = "Fotia Gorget", 
        ear1 = "Brutal Earring", 
        ear2 = {name="Moonshade Earring", augments={'Accuracy+4','Latent effect: "Regain"+1'}}
    })
    
    sets.precast.WS["Requiescat"].Acc = set_combine(sets.precast.WS.Acc, {
        neck = "Fotia Gorget", 
        ear2 = {name="Moonshade Earring", augments={'Accuracy+4','Latent effect: "Regain"+1'}}
    })

    sets.precast.WS["Chant du Cygne"] = set_combine(sets.precast.WS, {
        neck = "Fotia Gorget", 
        ear1 = "Brutal Earring", 
        ear2 = {name="Moonshade Earring", augments={'Accuracy+4','Latent effect: "Regain"+1'}}
    })
    
    sets.precast.WS["Chant du Cygne"].Acc = set_combine(sets.precast.WS.Acc, {
        neck = "Fotia Gorget", 
        ear2 = {name="Moonshade Earring", augments={'Accuracy+4','Latent effect: "Regain"+1'}}
    })

    -- OPTIMIZED: Full Nyame for WSD, added Alabaster Earring and Murky Ring
    sets.precast.WS["Savage Blade"] = {
        ammo = "Staunch Tathlum +1",
        head = {name="Nyame Helm", augments={'Path: B'}},
        neck = "Fotia Gorget",
        ear1 = {name="Alabaster Earring", augments={'Path: A'}},
        ear2 = "Ishvara Earring",
        body = {name="Nyame Mail", augments={'Path: B'}},
        hands = {name="Nyame Gauntlets", augments={'Path: B'}},
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = gear.enmity_jse_back,
        waist = "Fotia Belt",
        legs = {name="Nyame Flanchard", augments={'Path: B'}},
        feet = {name="Nyame Sollerets", augments={'Path: B'}}
    }
    
    sets.precast.WS["Savage Blade"].Acc = set_combine(sets.precast.WS.Acc, {
        neck = "Fotia Gorget",
        ear2 = "Telos Earring"
    })

    sets.precast.WS["Flat Blade"] = {
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = "Unmoving Collar",
        ear1 = {name="Alabaster Earring", augments={'Path: A'}},
        ear2 = "Telos Earring",
        body = "Chev. Cuirass +2",
        hands = "Chev. Gauntlets +2",
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = gear.enmity_jse_back,
        waist = "Olseni Belt",
        legs = "Chev. Cuisses +2",
        feet = "Chev. Sabatons +2"
    }

    sets.precast.WS["Sanguine Blade"] = {
        ammo = "Ghastly Tathlum +1",
        head = "Pixie Hairpin +1",
        neck = "Fotia Gorget",
        ear1 = "Friomisi Earring",
        ear2 = "Crematio Earring",
        body = {name="Nyame Mail", augments={'Path: B'}},
        hands = {name="Nyame Gauntlets", augments={'Path: B'}},
        ring1 = "Archon Ring",
        ring2 = {name="Metamor. Ring +1", augments={'Path: A'}},
        back = "Toro Cape",
        waist = "Fotia Belt",
        legs = {name="Nyame Flanchard", augments={'Path: B'}},
        feet = {name="Nyame Sollerets", augments={'Path: B'}}
    }

    -- OPTIMIZED: Fixed availability - removed Paeapua, Apeile Ring +1, Loess +1
    sets.precast.WS["Atonement"] = {
        ammo = "Staunch Tathlum +1",
        head = "Loess Barbuta",
        neck = "Unmoving Collar",
        ear1 = "Trux Earring",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = gear.enmity_jse_back,
        waist = "Creed Baudrier",
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Eschite Greaves", augments={'HP+80','Enmity+7','Phys. dmg. taken -4'}}
    }

    -- Swap to these on Moonshade using WS if at 3000 TP
    sets.MaxTP = {ear1 = {name="Alabaster Earring", augments={'Path: A'}}, ear2 = "Brutal Earring"}
    sets.AccMaxTP = {ear1 = {name="Alabaster Earring", augments={'Path: A'}}, ear2 = "Telos Earring"}

    --------------------------------------
    -- Midcast sets
    --------------------------------------

    -- OPTIMIZED: Added Murky Ring for SIRD
    sets.midcast.FastRecast = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Chanter's Shield",
        ammo = "Staunch Tathlum +1",
        head = {name="Carmine Mask +1", augments={'Accuracy+20','Mag. Acc.+12','"Fast Cast"+4'}},
        neck = "Voltsurge Torque",
        ear1 = "Loquac. Earring",
        ear2 = "Etiolation Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = "Leyline Gloves",
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Kishar Ring",
        back = gear.fastcast_jse_back,
        waist = "Creed Baudrier",
        legs = {name="Rawhide Trousers", augments={'MP+50','"Fast Cast"+5','"Refresh"+1'}},
        feet = {name="Founder's Greaves", augments={'VIT+10','Accuracy+15','"Mag.Atk.Bns."+15','Mag. Evasion+15'}}
    }

    -- OPTIMIZED: Added Murky Ring for DT-10%
    sets.midcast.FastRecast.DT = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = {name="Loricate Torque +1", augments={'Path: A'}},
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = "Creed Baudrier",
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    sets.midcast.Flash = set_combine(sets.Enmity, {})
    sets.midcast.Flash.SIRD = set_combine(sets.Enmity.SIRD, {})
    sets.midcast.Stun = set_combine(sets.Enmity, {})
    sets.midcast.Stun.SIRD = set_combine(sets.Enmity.SIRD, {})
    sets.midcast["Blue Magic"] = set_combine(sets.Enmity, {})
    sets.midcast["Blue Magic"].SIRD = set_combine(sets.Enmity.SIRD, {})
    sets.midcast.Cocoon = set_combine(sets.Enmity.SIRD, {})

    -- OPTIMIZED: Use Chevalier pieces, keep enmity
    sets.midcast.Cure = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = "Unmoving Collar",
        ear1 = {name="Nourish. Earring +1", augments={'Path: A'}},
        ear2 = "Etiolation Earring",
        body = "Chev. Cuirass +2",
        hands = "Chev. Gauntlets +2",
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = gear.enmity_jse_back,
        waist = "Creed Baudrier",
        legs = "Chev. Cuisses +2",
        feet = "Chev. Sabatons +2"
    }

    -- OPTIMIZED: Murky Ring for SIRD+3% + MP+30 + DT-10%
    sets.midcast.Cure.SIRD = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = {name="Loricate Torque +1", augments={'Path: A'}},
        ear1 = {name="Nourish. Earring +1", augments={'Path: A'}},
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        body = "Chev. Cuirass +2",
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = gear.enmity_jse_back,
        waist = "Rumination Sash",
        legs = {name="Founder's Greaves", augments={'VIT+10','Accuracy+15','"Mag.Atk.Bns."+15','Mag. Evasion+15'}},
        feet = {name="Founder's Greaves", augments={'VIT+10','Accuracy+15','"Mag.Atk.Bns."+15','Mag. Evasion+15'}}
    }

    -- OPTIMIZED: Murky Ring for DT-10%
    sets.midcast.Cure.DT = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = {name="Loricate Torque +1", augments={'Path: A'}},
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = "Creed Baudrier",
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    -- OPTIMIZED: Fixed availability (removed +1 from items you don't have)
    sets.midcast.Reprisal = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = "Loess Barbuta",
        neck = "Unmoving Collar",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = "Creed Baudrier",
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    -- OPTIMIZED: Murky Ring for MP+30
    sets.Self_Healing = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = "Unmoving Collar",
        ear1 = {name="Nourish. Earring +1", augments={'Path: A'}},
        ear2 = "Etiolation Earring",
        body = "Chev. Cuirass +2",
        hands = "Chev. Gauntlets +2",
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = "Moonlight Cape",
        waist = "Creed Baudrier",
        legs = "Chev. Cuisses +2",
        feet = "Chev. Sabatons +2"
    }

    -- OPTIMIZED: Murky Ring for SIRD+3% and MP+30
    sets.Self_Healing.SIRD = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = {name="Loricate Torque +1", augments={'Path: A'}},
        ear1 = {name="Nourish. Earring +1", augments={'Path: A'}},
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        body = "Chev. Cuirass +2",
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = "Moonlight Cape",
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = {name="Founder's Greaves", augments={'VIT+10','Accuracy+15','"Mag.Atk.Bns."+15','Mag. Evasion+15'}},
        feet = {name="Founder's Greaves", augments={'VIT+10','Accuracy+15','"Mag.Atk.Bns."+15','Mag. Evasion+15'}}
    }

    -- OPTIMIZED: Murky Ring for DT-10%
    sets.Self_Healing.DT = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = {name="Loricate Torque +1", augments={'Path: A'}},
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = "Creed Baudrier",
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    sets.Cure_Received = {hands = {name="Sakpata's Gauntlets", augments={'Path: A'}}, feet = {name="Sakpata's Leggings", augments={'Path: A'}}}
    sets.Self_Refresh = {waist = "Gishdubar Sash"}

    sets.midcast["Enhancing Magic"] = {
        main = "Colada",
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = {name="Carmine Mask +1", augments={'Accuracy+20','Mag. Acc.+12','"Fast Cast"+4'}},
        neck = "Incanter's Torque",
        ear1 = "Mimir Earring",
        ear2 = "Andoaa Earring",
        body = {name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},
        hands = {name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},
        ring1 = "Defending Ring",
        ring2 = "Kishar Ring",
        back = "Merciful Cape",
        waist = "Olympus Sash",
        legs = {name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},
        feet = {name="Telchine Pigaches", augments={'Mag. Acc.+18','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}}
    }

    -- OPTIMIZED: Murky Ring for SIRD+3%
    sets.midcast["Enhancing Magic"].SIRD = {
        main = "Colada",
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = "Incanter's Torque",
        ear1 = "Mimir Earring",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        body = {name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = "Merciful Cape",
        waist = "Olympus Sash",
        legs = {name="Founder's Greaves", augments={'VIT+10','Accuracy+15','"Mag.Atk.Bns."+15','Mag. Evasion+15'}},
        feet = {name="Founder's Greaves", augments={'VIT+10','Accuracy+15','"Mag.Atk.Bns."+15','Mag. Evasion+15'}}
    }

    sets.midcast.Stoneskin = set_combine(sets.midcast["Enhancing Magic"], {waist = "Siegel Sash"})
    sets.midcast.Protect = set_combine(sets.midcast["Enhancing Magic"], {ring2 = "Sheltered Ring"})
    sets.midcast.Shell = set_combine(sets.midcast["Enhancing Magic"], {ring2 = "Sheltered Ring"})

    -- OPTIMIZED: Use Chevalier pieces for phalanx received
    sets.midcast.Phalanx = set_combine(sets.midcast["Enhancing Magic"], {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        body = "Chev. Cuirass +2",
        hands = "Chev. Gauntlets +2",
        back = "Weard Mantle",
        legs = "Chev. Cuisses +2",
        feet = "Chev. Sabatons +2"
    })
    
    sets.midcast.Phalanx.SIRD = set_combine(sets.midcast["Enhancing Magic"].SIRD, {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        body = "Chev. Cuirass +2",
        hands = "Chev. Gauntlets +2",
        back = "Weard Mantle",
        feet = "Chev. Sabatons +2"
    })
    
    sets.midcast.Phalanx.DT = set_combine(sets.midcast.Phalanx.SIRD, {})
    
    sets.Phalanx_Received = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        body = "Chev. Cuirass +2",
        hands = "Chev. Gauntlets +2",
        back = "Weard Mantle",
        legs = "Chev. Cuisses +2",
        feet = "Chev. Sabatons +2"
    }

    --------------------------------------
    -- Idle/resting/defense/etc sets
    --------------------------------------

    sets.resting = {
        ammo = "Homiliary",
        head = "Jumalik Helm",
        neck = "Coatl Gorget +1",
        ear1 = "Etiolation Earring",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Damage taken-4%'}},
        body = "Jumalik Mail",
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = "Fucho-no-Obi",
        legs = {name="Nyame Flanchard", augments={'Path: B'}},
        feet = "Cab. Leggings +1"
    }

    -- Idle sets
    sets.idle = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Homiliary",
        head = "Jumalik Helm",
        neck = "Coatl Gorget +1",
        ear1 = "Etiolation Earring",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Damage taken-4%'}},
        body = "Jumalik Mail",
        hands = "Regal Gauntlets",
        ring1 = "Stikini Ring +1",
        ring2 = "Stikini Ring +1",
        back = "Moonlight Cape",
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = "Carmine Cuisses +1",
        feet = "Cab. Leggings +1"
    }

    -- OPTIMIZED: Fixed availability (removed +1 from Unmoving Collar, Odnowa Earring)
    sets.idle.PDT = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = "Unmoving Collar",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    -- OPTIMIZED: Murky Ring for DT-10%
    sets.idle.Block = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = "Diemer Gorget",
        ear1 = "Creed Earring",
        ear2 = "Thureous Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Shadow Mantle",
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    sets.idle.MDT = {
        main = "Malignance Sword",
        sub = "Genmei Shield",
        ammo = "Staunch Tathlum +1",
        head = {name="Nyame Helm", augments={'Path: B'}},
        neck = "Warder's Charm +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = {name="Nyame Mail", augments={'Path: B'}},
        hands = {name="Nyame Gauntlets", augments={'Path: B'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = gear.fastcast_jse_back,
        waist = "Carrier's Sash",
        legs = {name="Nyame Flanchard", augments={'Path: B'}},
        feet = {name="Nyame Sollerets", augments={'Path: B'}}
    }

    -- OPTIMIZED: Full Sakpata's for best defense, Murky Ring for DT-10%
    sets.idle.Tank = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = {name="Loricate Torque +1", augments={'Path: A'}},
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    -- OPTIMIZED: Fixed availability (removed +1 from Unmoving Collar, Odnowa Earring)
    sets.idle.Kiting = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = "Unmoving Collar",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = "Carmine Cuisses +1",
        feet = "Cab. Leggings +1"
    }

    sets.Kiting = {legs = "Carmine Cuisses +1"}

    sets.latent_refresh = {waist = "Fucho-no-Obi"}
    sets.latent_refresh_grip = {sub = "Oneiros Grip"}
    sets.latent_regen = {ring1 = "Defending Ring", ring2 = {name="Murky Ring", augments={'Path: A'}}}
    sets.DayIdle = {}
    sets.NightIdle = {}

    --------------------------------------
    -- Defense sets
    --------------------------------------

    sets.Knockback = {}
    sets.MP = {
        head = "Chev. Armet +2",
        neck = "Coatl Gorget +1",
        ear2 = "Etiolation Earring",
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        feet = "Rev. Leggings +1"
    }
    sets.passive.AbsorbMP = {
        head = "Chev. Armet +2",
        neck = "Coatl Gorget +1",
        ear2 = "Etiolation Earring",
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        feet = "Rev. Leggings +1"
    }
    sets.MP_Knockback = {}
    sets.Twilight = {head = "Twilight Helm", body = "Twilight Mail"}
    sets.TreasureHunter = {}

    -- Weapons sets
    sets.weapons.SakpataBlurred = {main = {name="Sakpata's Sword", augments={'Path: A'}}, sub = "Blurred Shield +1"}
    sets.weapons.SakpataGenmei = {main = {name="Sakpata's Sword", augments={'Path: A'}}, sub = "Genmei Shield"}
    sets.weapons.NaeglingBlurred = {main = "Naegling", sub = "Blurred Shield +1"}
    sets.weapons.ClubBlurred = {main = "Mafic Cudgel", sub = "Blurred Shield +1"}
    sets.weapons.DualWeapons = {main = "Burtgang", sub = "Qutrub Knife"}
    
    sets.defense.Block = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = "Diemer Gorget",
        ear1 = "Creed Earring",
        ear2 = "Thureous Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Shadow Mantle",
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    -- OPTIMIZED: Fixed availability (removed +1 from Unmoving Collar, Odnowa Earring)
    sets.defense.PDT = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = "Unmoving Collar",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Shadow Mantle",
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    -- OPTIMIZED: Murky Ring for DT-10%, fixed availability
    sets.defense.PDT_HP = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = "Unmoving Collar",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = "Creed Baudrier",
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    -- OPTIMIZED: Murky Ring for DT-10% + M.EVA+10
    sets.defense.MDT = {
        main = "Malignance Sword",
        sub = "Genmei Shield",
        ammo = "Staunch Tathlum +1",
        head = {name="Nyame Helm", augments={'Path: B'}},
        neck = "Warder's Charm +1",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Sanare Earring",
        body = {name="Nyame Mail", augments={'Path: B'}},
        hands = {name="Nyame Gauntlets", augments={'Path: B'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = gear.fastcast_jse_back,
        waist = "Carrier's Sash",
        legs = {name="Nyame Flanchard", augments={'Path: B'}},
        feet = {name="Nyame Sollerets", augments={'Path: B'}}
    }

    -- OPTIMIZED: Murky Ring for DT-10% + M.EVA+10
    sets.defense.MDT_HP = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Genmei Shield",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = {name="Loricate Torque +1", augments={'Path: A'}},
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = "Carrier's Sash",
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    -- OPTIMIZED: Murky Ring for M.EVA+10
    sets.defense.MEVA = {
        main = "Malignance Sword",
        sub = "Genmei Shield",
        ammo = "Staunch Tathlum +1",
        head = {name="Nyame Helm", augments={'Path: B'}},
        neck = "Warder's Charm +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = {name="Nyame Mail", augments={'Path: B'}},
        hands = {name="Nyame Gauntlets", augments={'Path: B'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = gear.fastcast_jse_back,
        waist = "Asklepian Belt",
        legs = {name="Nyame Flanchard", augments={'Path: B'}},
        feet = {name="Nyame Sollerets", augments={'Path: B'}}
    }

    -- OPTIMIZED: Murky Ring for M.EVA+10
    sets.defense.MEVA_HP = {
        main = "Malignance Sword",
        sub = "Genmei Shield",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = "Warder's Charm +1",
        ear2 = {name="Chev. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','Damage taken-4%'}},
        ear1 = "Odnowa Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = "Asklepian Belt",
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    sets.defense.PDT_Reraise = set_combine(sets.defense.PDT_HP, {head = "Twilight Helm", body = "Twilight Mail"})
    sets.defense.MDT_Reraise = set_combine(sets.defense.MDT_HP, {head = "Twilight Helm", body = "Twilight Mail"})

    --------------------------------------
    -- Engaged sets
    --------------------------------------

    -- OPTIMIZED: Added Alabaster Earring (Haste+5%, Store TP+5, DT-5%) and Murky Ring
    sets.engaged = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = "Unmoving Collar",
        ear1 = {name="Alabaster Earring", augments={'Path: A'}},
        ear2 = "Brutal Earring",
        body = "Chev. Cuirass +2",
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = gear.enmity_jse_back,
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = "Chev. Cuisses +2",
        feet = "Chev. Sabatons +2"
    }

    -- OPTIMIZED: Alabaster Earring for ACC+15 and all stats, Murky Ring for ACC+15
    sets.engaged.Acc = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = "Unmoving Collar",
        ear1 = {name="Alabaster Earring", augments={'Path: A'}},
        ear2 = "Telos Earring",
        body = "Chev. Cuirass +2",
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = gear.enmity_jse_back,
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    sets.engaged.DW = {
        main = "Naegling",
        sub = {name="Ternion Dagger +1", augments={'Path: A'}},
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = "Unmoving Collar",
        ear1 = {name="Alabaster Earring", augments={'Path: A'}},
        ear2 = "Brutal Earring",
        body = "Chev. Cuirass +2",
        hands = "Chev. Gauntlets +2",
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = gear.enmity_jse_back,
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = "Chev. Cuisses +2",
        feet = "Chev. Sabatons +2"
    }

    sets.engaged.DW.Acc = {
        main = "Naegling",
        sub = {name="Ternion Dagger +1", augments={'Path: A'}},
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = "Combatant's Torque",
        ear1 = {name="Alabaster Earring", augments={'Path: A'}},
        ear2 = "Telos Earring",
        body = "Chev. Cuirass +2",
        hands = "Chev. Gauntlets +2",
        ring1 = {name="Murky Ring", augments={'Path: A'}},
        ring2 = "Defending Ring",
        back = gear.enmity_jse_back,
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = "Chev. Cuisses +2",
        feet = "Chev. Sabatons +2"
    }

    -- OPTIMIZED: Murky Ring for DT-10%
    sets.engaged.Tank = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = "Chev. Armet +2",
        neck = {name="Loricate Torque +1", augments={'Path: A'}},
        ear1 = "Creed Earring",
        ear2 = "Thureous Earring",
        body = "Chev. Cuirass +2",
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Shadow Mantle",
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = "Chev. Cuisses +2",
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    -- OPTIMIZED: Alabaster Earring for Haste+5% + Store TP+5, Murky Ring for Crit+5%
    sets.engaged.DDTank = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = {name="Loricate Torque +1", augments={'Path: A'}},
        ear1 = {name="Alabaster Earring", augments={'Path: A'}},
        ear2 = "Brutal Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    -- OPTIMIZED: Alabaster Earring for accuracy, Murky Ring
    sets.engaged.Acc.DDTank = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = {name="Sakpata's Helm", augments={'Path: A'}},
        neck = {name="Loricate Torque +1", augments={'Path: A'}},
        ear1 = {name="Alabaster Earring", augments={'Path: A'}},
        ear2 = "Telos Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = {name="Sakpata's Cuisses", augments={'Path: A'}},
        feet = {name="Sakpata's Leggings", augments={'Path: A'}}
    }

    sets.engaged.NoShellTank = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        ammo = "Staunch Tathlum +1",
        head = "Jumalik Helm",
        neck = {name="Loricate Torque +1", augments={'Path: A'}},
        ear1 = "Thureous Earring",
        ear2 = "Etiolation Earring",
        body = {name="Sakpata's Plate", augments={'Path: A'}},
        hands = {name="Sakpata's Gauntlets", augments={'Path: A'}},
        ring1 = "Defending Ring",
        ring2 = {name="Murky Ring", augments={'Path: A'}},
        back = "Moonlight Cape",
        waist = {name="Sailfi Belt +1", augments={'Path: A'}},
        legs = {name="Rawhide Trousers", augments={'MP+50','"Fast Cast"+5','"Refresh"+1'}},
        feet = "Cab. Leggings +1"
    }

    sets.engaged.Reraise = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        head = "Twilight Helm",
        body = "Twilight Mail"
    }
    
    sets.engaged.Acc.Reraise = {
        main = {name="Sakpata's Sword", augments={'Path: A'}},
        sub = "Blurred Shield +1",
        head = "Twilight Helm",
        body = "Twilight Mail"
    }

    --------------------------------------
    -- Custom buff sets
    --------------------------------------
    sets.buff.Doom = {}
    sets.buff.Sleep = {neck = "Vim Torque +1"}
    sets.buff.Cover = {body = "Cab. Surcoat +1"}
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == "NIN" then
        set_macro_page(1, 7)
    elseif player.sub_job == "RUN" then
        set_macro_page(1, 7)
    elseif player.sub_job == "RDM" then
        set_macro_page(1, 7)
    elseif player.sub_job == "BLU" then
        set_macro_page(1, 7)
    elseif player.sub_job == "DNC" then
        set_macro_page(1, 7)
    else
        set_macro_page(1, 7) --War/Etc
    end
end

-- Function to update defense mode
function update_defense_mode()
    if state.DefenseMode and state.DefenseMode.value ~= 'None' then
        local newEquipSet = sets.defense[state.DefenseMode.value] or {}
        equip(newEquipSet)
    end
end