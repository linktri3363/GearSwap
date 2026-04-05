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

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_job_setup()
    state.OffenseMode:options("Normal", "SomeAcc", "Acc", "FullAcc", "Fodder")
    state.HybridMode:options("Normal", "DTLite", "DTFull", "Aminon")
    state.WeaponskillMode:options("Match", "Normal", "SomeAcc", "Acc", "FullAcc", "Fodder", "Proc")
    state.IdleMode:options("Normal", "Sphere")
    state.PhysicalDefenseMode:options("PDT")
    state.MagicalDefenseMode:options("MDT")
    state.ResistDefenseMode:options("MEVA")
    state.Weapons:options("MpuGandring", "Aeneas", "Aeolian", "Twashtar", "Ruthless", "Kleos", "Evisceration", "LowBuff", "Karambit", "Proc")
    
    state.Weapons:set("MpuGandring")
    state.ExtraMeleeMode = M {["description"] = "Extra Melee Mode", "None", "Suppa", "DWEarrings", "DWMax"}
    
    -- Enhanced TP system options
    state.TPMode = M{['description']='TP Mode', 'Normal', 'Conservative', 'Aggressive'}
    state.ContentMode = M{['description']='Content Mode', 'Auto', 'Odyssey', 'Sortie', 'General'}

    gear.stp_jse_back = { name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Store TP"+10','Damage taken-5%',}}
    gear.wsd_jse_back = {name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%','Parrying rate+5%',}}

    -- Additional local binds
    send_command("bind @` gs c step")
    send_command("bind ^!@` gs c toggle usealtstep")
    send_command("bind ^@` gs c cycle mainstep")
    send_command("bind !@` gs c cycle altstep")
    send_command('bind ^` input /ja "Saber Dance" <me>')
    send_command('bind !` input /ja "Fan Dance" <me>')
    send_command('bind ^\\\\ input /ja "Chocobo Jig II" <me>')
    send_command('bind !\\\\ input /ja "Spectral Jig" <me>')
    send_command('bind !backspace input /ja "Reverse Flourish" <me>')
    send_command('bind ^backspace input /ja "No Foot Rise" <me>')
    send_command("bind %~` gs c cycle SkillchainMode")
    -- Enhanced system binds - FIXED: Windows+F9 for TPMode, Ctrl+F9 for HybridMode (from globals)
    send_command("bind @f9 gs c cycle TPMode")
    send_command("bind ^f10 gs c cycle ContentMode")
	send_command('bind ^!p gs c pas2')   -- Ctrl+Alt+P triggers Aminon script

    select_default_macro_book()
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    sets.TreasureHunter = set_combine(sets.TreasureHunter, {})

    -- Extra Melee sets.  Apply these on top of melee sets.
    sets.Suppa = {ear1 = "Sherida Earring",ear2 = "Suppanomimi"}
    sets.DWEarrings = {ear1 = "Dudgeon Earring", ear2 = "Heartseeker Earring"}
    sets.DWMax = {
        ear1 = "Dudgeon Earring",
        ear2 = "Heartseeker Earring",
        body = "Horos Casaque +4",
        hands={ name="Floral Gauntlets", augments={'Rng.Acc.+15','Accuracy+15','"Triple Atk."+3','Magic dmg. taken -4%',}},
        waist = "Sailfi Belt +1"
    }

    -- Weapons sets
    sets.weapons.MpuGandring = {main = "Mpu Gandring",sub = "Centovente"}
    sets.weapons.Aeneas = {main = { name="Qutrub Knife", augments={'Path: A',}},sub = "Ethereal Dagger"}
    sets.weapons.Aeolian = {main ={ name="Malevolence", augments={'INT+7','"Mag.Atk.Bns."+5','"Fast Cast"+3',}}, sub = { name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}}}
    sets.weapons.Twashtar = {main = { name="Twashtar", augments={'Path: A',}},sub = "Centovente"}
    sets.weapons.Ruthless = {main = { name="Twashtar", augments={'Path: A',}},sub = "Centovente"} -- Same as Twashtar, optimized for Ruthless Stroke spam
    sets.weapons.Kleos = {main = "Tauret",sub = "Gleti's Knife"}
    sets.weapons.Evisceration = {main = "Tauret",sub = "Gleti's Knife"}
    sets.weapons.LowBuff = {main = "Mpu Gandring", sub = "Gleti's Knife"}
    sets.weapons.Karambit = {main = "Karambit"}
    sets.weapons.Proc = {main = "Twinned Blade", sub = "Gleti's Knife"}

    -- Precast Sets

    -- Precast sets to enhance JAs

    sets.precast.JA["No Foot Rise"] = {body="Horos Casaque +4"}

    sets.precast.JA["Trance"] = {head="Horos Tiara +4"}

    -- Enhanced Waltz set (chr and vit) - Optimized for Waltz Potency
    sets.precast.Waltz = {
        ammo = "Coiste Bodhar",
        head = "Horos Tiara +4",           -- Waltz potency +15%
        neck = "Unmoving Collar",
        ear1 = "Infused Earring",
        ear2 = "Odnowa Earring",
        body = "Maxixi Casaque +4",        -- Waltz potency +19%
        hands = "Horos Bangles +4",        -- Waltz potency +12%
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Cacoethic Ring +1",
        back={ name="Toetapper Mantle", augments={'"Store TP"+4','"Dual Wield"+3','"Rev. Flourish"+21','Weapon skill damage +4%',}},
        waist = "Chaac Belt",
        legs = "Dashing Subligar",
        feet = "Maxixi Toe Sh. +4"         -- Waltz potency +14%
    }

    sets.Self_Waltz = {head = "Mummu Bonnet +2", body = "Vanya Robe", ring1 = "Defending Ring"}

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz["Healing Waltz"] = {}

    sets.precast.Samba = {
        back = gear.stp_jse_back,
        head = "Maxixi Tiara +4"           
    }

    sets.precast.Jig = {
        feet = "Maxixi Toe Sh. +4",      
        legs = "Horos Tights +4"           
    }

    -- Enhanced Step set - Optimized for accuracy and step landing
    sets.precast.Step = {
        ammo = "Crepuscular Pebble",
        head = "Maculele Tiara +3",
        neck = "Etoile Gorget +2",
        ear1 = "Telos Earring",
        ear2 = "Macu. Earring +1",
        body = "Malignance Tabard",
        hands = "Maculele Bangles +3",
        ring1 = "Epona's Ring",
        ring2 = "Gere Ring",
        back = gear.stp_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Gleti's Breeches",
        feet = "Macu. Toe Sh. +3"
    }

    sets.Enmity = {
        ammo = "Paeapua",
        head = "Nyame Helm",
        neck = "Unmoving Collar",
        ear1 = "Ishvara Earring",
        ear2 = "Trux Earring",
        body = "Nyame Mail",
        hands = "Malignance Gloves",
        ring1 = "Petrov Ring",
        ring2 = "Vengeful Ring",
        back = gear.stp_jse_back,
        waist = "Chaac Belt",
        legs = "Nyame Flanchard",
        feet = "Malignance Boots"
    }

    sets.precast.JA.Provoke = sets.Enmity

    sets.precast.Flourish1 = {}
    sets.precast.Flourish1["Violent Flourish"] = {
        ammo = "Crepuscular Pebble",
        head = "Maculele Tiara +3",
        neck = "Etoile Gorget +2",
        ear1 = "Telos Earring",
        ear2 = "Macu. Earring +1",
        body = "Malignance Tabard",
        hands = "Maculele Bangles +3",
        ring1 = "Epona's Ring",
        ring2 = "Gere Ring",
        back = gear.stp_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Gleti's Breeches",
        feet = "Macu. Toe Sh. +3"
    }

    sets.precast.Flourish1["Animated Flourish"] = sets.Enmity

    sets.precast.Flourish1["Desperate Flourish"] = {
        ammo = "Crepuscular Pebble",
        head = "Maculele Tiara +3",
        neck = "Etoile Gorget +2",
        ear1 = "Telos Earring",
        ear2 = "Macu. Earring +1",
        body = "Malignance Tabard",
        hands = "Maculele Bangles +3",
        ring1 = "Epona's Ring",
        ring2 = "Gere Ring",
        back = gear.stp_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Gleti's Breeches",
        feet = "Macu. Toe Sh. +3"
    }

    sets.precast.Flourish2 = {}
    sets.precast.Flourish2["Reverse Flourish"] = {
        back={ name="Toetapper Mantle", augments={'"Store TP"+4','"Dual Wield"+3','"Rev. Flourish"+21','Weapon skill damage +4%',}},
        hands = "Macu. Bangles +3"
    }

    sets.precast.Flourish3 = {}
    sets.precast.Flourish3["Striking Flourish"] = {
        body = "Macu. Casaque +3"
    }
    sets.precast.Flourish3["Climactic Flourish"] = {}

    -- Fast cast sets for spells
    sets.precast.FC = {
        ammo = "Impatiens",
        head = "Maxixi Tiara +4",
        neck = "Voltsurge Torque",
        ear1 = "Etiolation Earring",
        ear2 = "Loquac. Earring",
        body = "Dread Jupon",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Lebeche Ring",
        legs = "Rawhide Trousers"
    }

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck = "Magoraga Beads"})

    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        ammo = "Coiste Bodhar",
        head = "Maculele Tiara +3",
        neck = "Etoile Gorget +2",
        ear1 = "Moonshade Earring",
        ear2 = "Macu. Earring +1",
        body = "Nyame Mail",
        hands = "Maxixi Bangles +4",       
        ring1 = "Ilabrat Ring",
        ring2 = "Gere Ring",
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Horos Tights +4",
        feet = "Nyame Sollerets"
    }

    sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {
        neck = "Etoile Gorget +2",
        ear2 = "Macu. Earring +1"
    })
    
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {
        ammo = "Crepuscular Pebble",
        neck = "Etoile Gorget +2",
        ear2 = "Macu. Earring +1",
        waist = "Sailfi Belt +1"
    })
    
    sets.precast.WS.FullAcc = set_combine(sets.precast.WS.Acc, {
        head = "Nyame Helm",
        hands = "Nyame Gauntlets"
    })
    
    sets.precast.WS.Proc = {
        ammo = "Coiste Bodhar",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Brutal Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Epona's Ring",
        back = gear.stp_jse_back,
        waist = "Chaac Belt",
        legs = "Horos Tights +4",
        feet = "Nyame Sollerets"
    }

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS["Rudra's Storm"] = {
        ammo = "Crepuscular Pebble",
        head = "Maculele Tiara +3",
        neck = "Etoile Gorget +2",
        ear1 = "Moonshade Earring",
        ear2 = "Macu. Earring +1",
        body = "Nyame Mail",
        hands = "Maxixi Bangles +4",       
        ring1 = "Ilabrat Ring",
        ring2 = "Gere Ring",
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Maculele Tights +3",
        feet = "Nyame Sollerets"
    }
    
    
    sets.precast.WS["Ruthless Stroke"] = {
        ammo = "Coiste Bodhar",
        head = "Maculele Tiara +3",
        neck = "Etoile Gorget +2",
        ear1 = "Moonshade Earring",
        ear2 = "Macu. Earring +1",
        body = "Nyame Mail",
        hands = "Maxixi Bangles +4",
        ring1 = "Ilabrat Ring",
        ring2 = "Ephramad's Ring",
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Horos Tights +4",
        feet = "Nyame Sollerets"
    }

    sets.precast.WS["Rudra's Storm"].SomeAcc = set_combine(sets.precast.WS["Rudra's Storm"], {
        ear2 = "Macu. Earring +1"
    })
    
    sets.precast.WS["Rudra's Storm"].Acc = set_combine(sets.precast.WS["Rudra's Storm"], {
        ammo = "Crepuscular Pebble",
        ear2 = "Macu. Earring +1"
    })
    
    sets.precast.WS["Rudra's Storm"].FullAcc = set_combine(sets.precast.WS["Rudra's Storm"].Acc, {})
    sets.precast.WS["Rudra's Storm"].Fodder = set_combine(sets.precast.WS["Rudra's Storm"], {})

    sets.precast.WS["Shark Bite"] = {
        ammo = "Crepuscular Pebble",
        head = "Maculele Tiara +3",
        neck = "Etoile Gorget +2",
        ear1 = "Moonshade Earring",
        ear2 = "Macu. Earring +1",
        body = "Nyame Mail",
        hands = "Maxixi Bangles +4",       
        ring1 = "Ilabrat Ring",
        ring2 = "Gere Ring",
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Maculele Tights +3",
        feet = "Nyame Sollerets"
    }
    
    sets.precast.WS["Shark Bite"].SomeAcc = set_combine(sets.precast.WS["Shark Bite"], {
        ear2 = "Macu. Earring +1"
    })
    
    sets.precast.WS["Shark Bite"].Acc = set_combine(sets.precast.WS["Shark Bite"], {
        ammo = "Crepuscular Pebble",
        ear2 = "Macu. Earring +1"
    })
    
    sets.precast.WS["Shark Bite"].FullAcc = set_combine(sets.precast.WS["Shark Bite"].Acc, {})
    sets.precast.WS["Shark Bite"].Fodder = set_combine(sets.precast.WS["Shark Bite"], {})

    -- Optimized Evisceration set for critical hits with your available gear
    sets.precast.WS["Evisceration"] = {
        ammo = "Coiste Bodhar",
        head = "Blistering Sallet",
        neck = "Asperity Necklace",
        ear1 = "Sherida Earring",
        ear2 = "Brutal Earring",
        body = "Gleti's Cuirass",
        hands = "Gleti's Gauntlets",
        ring1 = "Ilabrat Ring",
        ring2 = "Gere Ring",
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Gleti's Breeches",
        feet = "Gleti's Boots"
    }
    
    sets.precast.WS["Evisceration"].SomeAcc = set_combine(sets.precast.WS["Evisceration"], {
        neck = "Etoile Gorget +2"
    })
    
    sets.precast.WS["Evisceration"].Acc = set_combine(sets.precast.WS["Evisceration"], {
        head = "Maculele Tiara +3",
        neck = "Etoile Gorget +2"
    })
    
    sets.precast.WS["Evisceration"].FullAcc = set_combine(sets.precast.WS["Evisceration"].Acc, {
        body = "Nyame Mail",
        legs = "Nyame Flanchard"
    })
    sets.precast.WS["Evisceration"].Fodder = set_combine(sets.precast.WS["Evisceration"], {})

    -- Optimized Pyrrhic Kleos set
    sets.precast.WS["Pyrrhic Kleos"] = {
        ammo = "Coiste Bodhar",
        head = "Maculele Tiara +3",
        neck = "Asperity Necklace",
        ear1 = "Sherida Earring",
        ear2 = "Macu. Earring +1",
        body = "Horos Casaque +4",         
        hands = "Macu. Bangles +3",
        ring1 = "Ilabrat Ring",
        ring2 = "Gere Ring",
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }
    
    sets.precast.WS["Pyrrhic Kleos"].SomeAcc = set_combine(sets.precast.WS["Pyrrhic Kleos"], {
        neck = "Etoile Gorget +2"
    })
    sets.precast.WS["Pyrrhic Kleos"].Acc = set_combine(sets.precast.WS["Pyrrhic Kleos"], {
        ammo = "Crepuscular Pebble",
        neck = "Etoile Gorget +2"
    })
    sets.precast.WS["Pyrrhic Kleos"].FullAcc = set_combine(sets.precast.WS["Pyrrhic Kleos"].Acc, {})
    sets.precast.WS["Pyrrhic Kleos"].Fodder = set_combine(sets.precast.WS["Pyrrhic Kleos"], {})

    -- Enhanced Exenterator set
    sets.precast.WS["Exenterator"] = {
        ammo = "Crepuscular Pebble",
        head = "Maculele Tiara +3",
        neck = "Asperity Necklace",
        ear1 = "Sherida Earring",
        ear2 = "Macu. Earring +1",
        body = "Gleti's Cuirass",
        hands = "Gleti's Gauntlets",
        ring1 = "Ilabrat Ring",
        ring2 = "Gere Ring",
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Maculele Tights +3",
        feet = "Nyame Sollerets"
    }

    sets.precast.WS["Aeolian Edge"] = {
        ammo = "Seraphic Ampulla",
        head = "Nyame Helm",
        neck = "Baetyl Pendant",
        ear1 = "Ishvara Earring",
        ear2 = "Crematio Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Metamor. Ring +1",
        ring2 = "Dingir Ring",
        back = gear.wsd_jse_back,
        waist = "Chaac Belt",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.precast.WS["Aeolian Edge"].TH = set_combine(sets.precast.WS["Aeolian Edge"], sets.TreasureHunter)

    -- Enhanced TP-based swapping sets
    sets.MaxTP = {
        ear1 = "Sherida Earring",
        ear2 = "Ishvara Earring" 
    }
    sets.AccMaxTP = {
        ear1 = "Sherida Earring",
        ear2 = "Macu. Earring +1"
    }

    -- WS-Specific High TP sets
    sets.MaxTP["Rudra's Storm"] = {
        ear1 = "Sherida Earring",
        ear2 = "Ishvara Earring",
        ring1 = "Ilabrat Ring",
        waist = "Sailfi Belt +1"
    }

    sets.AccMaxTP["Rudra's Storm"] = {
        ear1 = "Sherida Earring",
        ear2 = "Macu. Earring +1",
        ring1 = "Ilabrat Ring",
        waist = "Sailfi Belt +1"
    }

    sets.MaxTP["Pyrrhic Kleos"] = {
        ear1 = "Sherida Earring",
        ear2 = "Macu. Earring +1",
        ring2 = "Gere Ring",
        waist = "Sailfi Belt +1"
    }

    sets.MaxTP["Evisceration"] = {
        ear1 = "Sherida Earring",
        ear2 = "Brutal Earring",
        ring1 = "Ephramad's Ring",
        waist = "Sailfi Belt +1"
    }

    sets.MaxTP["Shark Bite"] = {
        ear1 = "Sherida Earring",
        ear2 = "Ishvara Earring",
        ring1 = "Ilabrat Ring",
        waist = "Sailfi Belt +1"
    }
	
	sets.MaxTP["Ruthless Stroke"] = {
    ear1 = "Odr Earring"  -- Only swap ear1, keep ear2 as Ishvara
}

    sets.Skillchain = {
        hands = "Macu. Bangles +3"
    }

    -- Midcast Sets

    sets.midcast.FastRecast = {
        head = "Maxixi Tiara +4",
        neck = "Voltsurge Torque",
        ear1 = "Etiolation Earring",
        ear2 = "Loquac. Earring",
        body = "Dread Jupon",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Kishar Ring",
        back = gear.stp_jse_back,
        waist = "Chaac Belt",
        legs = "Rawhide Trousers",
        feet = "Malignance Boots"
    }

    -- Specific spells
    sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {back = gear.stp_jse_back})

    -- Sets to return to when not performing an action.

    -- Resting sets
    sets.resting = {}
    sets.ExtraRegen = {}

    -- Idle sets

	sets.idle = {
			ammo = "Staunch Tathlum +1",              -- DT-3% (CHANGED)
			head = "Gleti's Mask",                     
			neck = "Loricate Torque +1",               -- DT-6%
			ear1 = "Etiolation Earring",               
			ear2 = "Sanare Earring",                   
			body = "Gleti's Cuirass",                  -- PDT-9%, Regain+3
			hands = "Gleti's Gauntlets",               
			ring1 = { name="Murky Ring", augments={'Path: A',}}, -- DT-4%
			ring2 = "Defending Ring",                  -- DT-10% (CHANGED)
			back = gear.stp_jse_back,                  -- DT-5%
			waist = "Carrier's Sash",                  -- Elemental resist +15 (CHANGED)
			legs = "Gleti's Breeches",                 -- PDT-8%, Regain+3
			feet = "Gleti's Boots"                     -- PDT-5%, Regain+2
		}

    sets.idle.Sphere = set_combine(sets.idle, {body = "Gleti's Cuirass"})

    -- Defense sets

    sets.defense.PDT = {
        ammo = "Coiste Bodhar",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Epona's Ring",
        back = gear.stp_jse_back,
        waist = "Chaac Belt",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.defense.MDT = {
        ammo = "Coiste Bodhar",
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Epona's Ring",
        back = gear.stp_jse_back,
        waist = "Null Belt",
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.defense.MEVA = {
        ammo = "Coiste Bodhar",
        head = "Maxixi Tiara +4",
        neck = "Yarak Torque",
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Horos Casaque +4",
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Vengeful Ring",
        back = gear.stp_jse_back,
        waist = "Null Belt",
        legs = "Rawhide Trousers",
        feet = "Malignance Boots"
    }

    sets.Kiting = {ring1 = "Shneddick Ring"}

    -- Engaged sets

    -- OPTIMIZED: Normal Mode - Pure Offense with natural DT (-26%)
    -- STP: 57, Haste: 27%, Multi-attack: DA+10%, TA+4%
    sets.engaged = {
        ammo = "Coiste Bodhar",
        head = "Maculele Tiara +3",            -- Haste+8%, STP+10, WSD+12%
        neck = "Etoile Gorget +2",
        ear1 = "Sherida Earring",              -- STP+5, DA+5%
        ear2 = "Telos Earring",                -- Acc+10, DA+5%
        body = "Horos Casaque +4",             -- PDT-6%, Haste+4%, TA+4%, Attack+96
        hands = "Malignance Gloves",           -- DT-5%, STP+12, Haste+4%
        ring1 = "Chirich Ring +1",             -- STP+4
        ring2 = "Chirich Ring +1",             -- STP+4
        back = gear.stp_jse_back,              -- DT-5%, STP+10
        waist = "Sailfi Belt +1",
        legs = "Horos Tights +4",              -- Haste+6%, WSD+12%, Attack+74
        feet = "Macu. Toe Sh. +3"              -- DT-10%, STP+12, Haste+5%
    }

    -- OPTIMIZED: DTLite Mode - Balanced Defense (-33% DT)
    -- STP: 57 (same!), Haste: 30% (better!), Multi-attack: DA+10%, TA+4%
    sets.engaged.DTLite = {
        ammo = "Coiste Bodhar",
        head = "Maculele Tiara +3",            -- Haste+8%, STP+10
        neck = "Etoile Gorget +2",
        ear1 = "Sherida Earring",              -- STP+5, DA+5%
        ear2 = "Telos Earring",                -- Acc+10, DA+5%
        body = "Horos Casaque +4",             -- PDT-6%, Haste+4%, TA+4%, Attack+96
        hands = "Malignance Gloves",           -- DT-5%, STP+12, Haste+4%
        ring1 = "Chirich Ring +1",             -- STP+4
        ring2 = "Chirich Ring +1",             -- STP+4
        back = gear.stp_jse_back,              -- DT-5%, STP+10
        waist = "Sailfi Belt +1",
        legs = "Malignance Tights",            -- DT-7%, STP+10, Haste+9%
        feet = "Macu. Toe Sh. +3"              -- DT-10%, STP+12, Haste+5%
    }

    -- OPTIMIZED: DTFull Mode - Maximum Defense (-50% DT capped)
    -- STP: 51, Haste: 28%, Multi-attack: DA+5%, TA+4%
    sets.engaged.DTFull = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",           -- DT-6%, STP+8, Haste+6%
        neck = "Loricate Torque +1",           -- DT-6%
        ear1 = "Sherida Earring",              -- STP+5, DA+5%
        ear2 = "Odnowa Earring",               -- DT-2%
        body = "Horos Casaque +4",             -- PDT-6%, Haste+4%, TA+4%
        hands = "Malignance Gloves",           -- DT-5%, STP+12, Haste+4%
        ring1 = "Defending Ring",              -- DT-10%
        ring2 = "Chirich Ring +1",             -- STP+4
        back = gear.stp_jse_back,              -- DT-5%, STP+10
        waist = "Sailfi Belt +1",
        legs = "Malignance Tights",            -- DT-7%, STP+10, Haste+9%
        feet = "Macu. Toe Sh. +3"              -- DT-10%, STP+12, Haste+5%
    }

    -- Accuracy Variants for Normal Mode
    sets.engaged.SomeAcc = set_combine(sets.engaged, {
        ear2 = "Macu. Earring +1"              -- Trade Telos for more accuracy
    })

    sets.engaged.Acc = set_combine(sets.engaged, {
        ammo = "Crepuscular Pebble",
        ear2 = "Macu. Earring +1",
        hands = "Maculele Bangles +3",         -- Acc+62 instead of STP
        ring2 = "Ilabrat Ring"                 -- Acc+10 instead of 2nd Chirich
    })

    sets.engaged.FullAcc = set_combine(sets.engaged.Acc, {
        body = "Malignance Tabard",            -- More accuracy
        legs = "Malignance Tights"             -- More accuracy
    })

    sets.engaged.Fodder = set_combine(sets.engaged, {})

    -- Accuracy Variants for DTLite Mode
    sets.engaged.DTLite.SomeAcc = set_combine(sets.engaged.DTLite, {
        ear2 = "Macu. Earring +1"
    })

    sets.engaged.DTLite.Acc = set_combine(sets.engaged.DTLite, {
        ammo = "Crepuscular Pebble",
        ear2 = "Macu. Earring +1",
        hands = "Maculele Bangles +3",
        ring2 = "Ilabrat Ring"
    })

    sets.engaged.DTLite.FullAcc = set_combine(sets.engaged.DTLite.Acc, {
        body = "Malignance Tabard"
    })

    sets.engaged.DTLite.Fodder = set_combine(sets.engaged.DTLite, {})

    -- Accuracy Variants for DTFull Mode
    sets.engaged.DTFull.SomeAcc = set_combine(sets.engaged.DTFull, {})

    sets.engaged.DTFull.Acc = set_combine(sets.engaged.DTFull, {
        hands = "Maculele Bangles +3"
    })

    sets.engaged.DTFull.FullAcc = set_combine(sets.engaged.DTFull.Acc, {
        body = "Malignance Tabard"
    })

    sets.engaged.DTFull.Fodder = set_combine(sets.engaged.DTFull, {})

    -- AMINON SORTIE MODE: Optimized for 4.9 yalm unengaged WS spam with Regal Gloves
    -- TP Generation: Tactician's (~170/min) + Regal Gloves (~350/min) + Gleti's 3pc (~180/min) + Reverse Flourish (~2000/min) = ~2,700 TP/min
    -- Defense: ~-32% DT after Regal +20% penalty (still strong!)
    -- HP Bonus: +1,290 HP total (excellent buffer for AoE hits)
    sets.engaged.Aminon = {
        ammo = "Staunch Tathlum +1",        -- DT -3%
        head = "Gleti's Mask",              -- Regain +2/tick, HP +147
        neck = "Loricate Torque +1",        -- DT -6%
        ear1 = "Tuisto Earring",            -- PDT -2%, HP +150
        ear2 = { name="Odnowa Earring +1", augments={'Path: A',}}, -- DT -3%, HP +110
        body = "Malignance Tabard",         -- DT -9%, HP +175
        hands = "Regal Gloves",             -- Converts 20% damage to TP, DT +20%, HP +342, DEX +40, Acc +45
        ring1 = "Defending Ring",           -- DT -10%
        ring2 = "Chirich Ring +1",          -- Store TP +10
        back = { name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Store TP"+10','Phys. dmg. taken-10%',}}, -- PDT -10%
        waist = "Sailfi Belt +1",           -- PDT -6% MDT -6%
        legs = "Gleti's Breeches",          -- Regain +2/tick, HP +209, PDT -8%
        feet = "Gleti's Boots"              -- Regain +2/tick, HP +157, PDT -5%
    }

    sets.engaged.Aminon.SomeAcc = set_combine(sets.engaged.Aminon, {
        ear2 = "Macu. Earring +1"  -- Swap Odnowa for more accuracy if needed
    })

    sets.engaged.Aminon.Acc = set_combine(sets.engaged.Aminon, {
        head = "Maculele Tiara +3",  -- More accuracy than Gleti's
        ear2 = "Macu. Earring +1",
        ring2 = "Ilabrat Ring"  -- Trade Store TP for accuracy
    })

    sets.engaged.Aminon.FullAcc = set_combine(sets.engaged.Aminon.Acc, {
        body = "Horos Casaque +4"  -- Maximum accuracy
    })

    -- Buff sets: Gear that needs to be worn to actively enhance a current player buff.
    sets.buff["Saber Dance"] = {legs="Horos Tights +4"}      
    sets.buff["Climactic Flourish"] = {
        ammo = "Coiste Bodhar",
        head = "Maculele Tiara +3",
        body = "Horos Casaque +4"
    }
    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Sleep = {head = "Nyame Helm"}
end

-- Simple function to check if we're in a high buff situation
function is_high_buff_situation()
    local has_geo = false
    local has_cor = false
    local has_brd = false
    
    -- Check party for support jobs
    if party then
        for i = 1, 6 do
            local member = party[i]
            if member and member.job then
                if member.job == "GEO" then has_geo = true end
                if member.job == "COR" then has_cor = true end
                if member.job == "BRD" then has_brd = true end
            end
        end
    end
    
    -- Count support jobs
    local support_count = 0
    if has_geo then support_count = support_count + 1 end
    if has_cor then support_count = support_count + 1 end
    if has_brd then support_count = support_count + 1 end
    
    -- High buff if 2+ support or in Odyssey/Sortie content
    local content_area = state.ContentMode and state.ContentMode.value or "Auto"
    if content_area == "Auto" and world.area then
        if world.area:contains("Odyssey") or world.area:contains("Sheol") then
            content_area = "Odyssey"
        elseif world.area:contains("Sortie") then
            content_area = "Sortie"
        end
    end
    
    return (support_count >= 2) or (content_area == "Odyssey") or (content_area == "Sortie")
end

-- ========================================
-- Enhanced TP System Functions
-- ========================================

-- Enhanced TP calculation for more granular control
function get_effective_player_tp(spell, WSset)
    local base_tp = player.tp
    
    -- Account for TP bonus from Moonshade at different TP levels
    if WSset.ear1 == "Moonshade Earring" or WSset.ear2 == "Moonshade Earring" then
        if base_tp >= 1000 and base_tp < 2000 then
            base_tp = base_tp + 250  -- TP+250 bonus
        elseif base_tp >= 2000 and base_tp < 3000 then
            base_tp = base_tp + 250  -- Still get bonus
        end
        -- No bonus at 3000+ TP
    end
    
    return base_tp
end

-- Get optimal TP threshold based on mode and weapon skill
function get_tp_threshold(spell)
    local base_threshold = 3000  -- Default conservative
    
    if state.TPMode and state.TPMode.value == 'Aggressive' then
        -- Replace Moonshade earlier for more damage
        if spell.english == "Evisceration" or spell.english == "Pyrrhic Kleos" then
            base_threshold = 2000
        else
            base_threshold = 2500
        end
    elseif state.TPMode and state.TPMode.value == 'Conservative' then
        -- Keep Moonshade longer for fTP scaling
        base_threshold = 3000
    end
    
    return base_threshold
end

-- Content-specific TP optimization
function get_custom_tp_set(spell)
    local base_set = sets.MaxTP[spell.english] or sets.MaxTP
    
    -- Auto-detect content or use manual setting
    local content_area = state.ContentMode and state.ContentMode.value or "Auto"
    
    if content_area == "Auto" then
        if world.area and (world.area:contains("Odyssey") or world.area:contains("Sheol")) then
            content_area = "Odyssey"
        elseif world.area and world.area:contains("Sortie") then
            content_area = "Sortie"
        end
    end
    
    -- Odyssey - prioritize accuracy over damage
    if content_area == "Odyssey" then
        base_set = set_combine(base_set, {
            ear2 = "Macu. Earring +1",            -- More accuracy
            ring1 = "Ilabrat Ring"             -- Accuracy + attack
        })
    end
    
    -- Sortie - different optimization  
    if content_area == "Sortie" then
        base_set = set_combine(base_set, {
            ring2 = "Gere Ring"                -- Attack focus for Sortie enemies
        })
    end
    
    return base_set
end

-- Enhanced post-precast function with advanced TP logic and Ephramad's Ring
function user_job_post_precast(spell, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        local current_tp = player.tp
        local wsacc = state.WeaponskillMode.value
        local is_high_buff = is_high_buff_situation()
        
        -- Determine if we should use accuracy sets
        local use_acc = wsacc:contains('Acc') and not buffactive['Sneak Attack']
        
        -- Enhanced TP-based swapping with multiple thresholds
        local threshold = get_tp_threshold(spell)
        
        if current_tp >= 2750 then
            -- Very high TP - optimize for pure damage
            if use_acc and sets.AccMaxTP then
                equip(sets.AccMaxTP[spell.english] or sets.AccMaxTP)
            elseif sets.MaxTP then
                equip(sets.MaxTP[spell.english] or sets.MaxTP)
            end
        elseif current_tp >= threshold then
            -- High TP based on mode and WS type
            if use_acc and sets.AccMaxTP then
                equip(sets.AccMaxTP[spell.english] or sets.AccMaxTP)
            elseif sets.MaxTP then
                equip(sets.MaxTP[spell.english] or sets.MaxTP)
            end
        elseif current_tp >= 2000 then
            -- Conditional swapping for certain WSs
            if spell.english == "Evisceration" or spell.english == "Pyrrhic Kleos" then
                if use_acc and sets.AccMaxTP then
                    equip(sets.AccMaxTP[spell.english] or sets.AccMaxTP)
                elseif sets.MaxTP then
                    equip(sets.MaxTP[spell.english] or sets.MaxTP)
                end
            end
        end
        
        -- Ephramad's Ring for high buff situations only
        if is_high_buff and current_tp >= threshold then
            equip({ring1 = "Ephramad's Ring"})
        end
        
        -- Buff-specific modifications
        if state.Buff['Climactic Flourish'] and sets.buff['Climactic Flourish'] then
            equip(sets.buff['Climactic Flourish'])
        end
        
        -- Saber Dance modifications for accuracy
        if state.Buff['Saber Dance'] and spell.english == "Rudra's Storm" then
            equip({
                legs = "Horos Tights +4"    -- Saber Dance bonus
            })
        end
        
        -- Debug info
        if _settings.debug_mode then
            add_to_chat(8, string.format("TP Info: %d/%d, Replace Moonshade: %s, High Buff: %s", 
                current_tp, threshold, tostring(current_tp >= threshold), tostring(is_high_buff)))
        end
    end
end

-- Enhanced party buff checking
function check_party_buffs()
    local has_geo = false
    local has_cor = false
    
    -- Check if we have GEO and COR support
    if alliance and alliance[1] then
        for i = 1, 6 do
            local member = alliance[1][i]
            if member and member.mob then
                if member.main_job == "GEO" then has_geo = true end
                if member.main_job == "COR" then has_cor = true end
            end
        end
    end
    
    return has_geo, has_cor
end

-- ======================================================================
-- RANGE ENGAGE FIX - Force engaged gear even when outside auto-attack range
-- ======================================================================

-- Force engaged gear when status changes to Engaged
function job_status_change(newStatus, oldStatus)
    if newStatus == 'Engaged' then
        handle_equipping_gear(player.status)
    end
end

-- Force gear update after weaponskills at range
function job_aftercast(spell, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' and player.status == 'Engaged' then
        -- Small delay to ensure status is updated
        coroutine.schedule(function()
            if player.status == 'Engaged' then
                handle_equipping_gear(player.status)
            end
        end, 0.5)
    end
end

-- Enhanced step accuracy based on current conditions
function user_job_customize_idle_set(idleSet)
    -- Could add idle modifications based on content here
    return idleSet
end

function user_job_customize_melee_set(meleeSet)
    if state.DefenseMode.value ~= 'None' then
        if state.Buff['Saber Dance'] then
            meleeSet = set_combine(meleeSet, sets.buff['Saber Dance'])
        end
        if state.Buff['Climactic Flourish'] then
            meleeSet = set_combine(meleeSet, sets.buff['Climactic Flourish'])
        end
    end
    
    -- Content-specific adjustments
    if state.ContentMode and state.ContentMode.value == "Odyssey" then
        meleeSet = set_combine(meleeSet, {
            ring1 = "Ilabrat Ring"             -- More accuracy for Odyssey
        })
    end
    
    return meleeSet
end

-- Enhanced self command for new toggles
function user_job_self_command(commandArgs, eventArgs)
    if commandArgs[1]:lower() == 'tpmode' then
        state.TPMode:cycle()
        add_to_chat(122, 'TP Mode: '..state.TPMode.value)
        eventArgs.handled = true
    elseif commandArgs[1]:lower() == 'contentmode' then
        state.ContentMode:cycle()
        add_to_chat(122, 'Content Mode: '..state.ContentMode.value)
        eventArgs.handled = true
	elseif commandArgs[1]:lower() == 'pas2' then
        windower.send_command('exec AminonDNC.txt')
        add_to_chat(122, 'Getting jiggy! Go on Chainspell TP Denial!')
        eventArgs.handled = true
    end
end

-- Enhanced display function
function user_job_display_current_job_state(eventArgs)
    local msg = 'Melee'
    
    if state.CombatForm.has_value then
        msg = msg .. ' (' .. state.CombatForm.value .. ')'
    end
    
    msg = msg .. ': '
    
    msg = msg .. state.OffenseMode.value
    if state.HybridMode.value ~= 'Normal' then
        msg = msg .. '/' .. state.HybridMode.value
    end
    msg = msg .. ', WS: ' .. state.WeaponskillMode.value
    
    if state.DefenseMode.value ~= 'None' then
        msg = msg .. ', ' .. 'Defense: ' .. state.DefenseMode.value .. ' (' .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ')'
    end
    
    if state.Kiting.value then
        msg = msg .. ', Kiting'
    end

    msg = msg .. ', ['..state.MainStep.current

    if state.UseAltStep.value == true then
        msg = msg .. '/'..state.AltStep.current
    end
    
    msg = msg .. ']'
    
    -- Add enhanced mode display
    if state.TPMode then
        msg = msg .. ', TP: ' .. state.TPMode.value
    end
    if state.ContentMode then
        msg = msg .. ', Content: ' .. state.ContentMode.value
    end

    add_to_chat(122, msg)

    eventArgs.handled = true
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == "WAR" then
        set_macro_page(1, 19)
    elseif player.sub_job == "NIN" then
        set_macro_page(1, 19)
    elseif player.sub_job == "SAM" then
        set_macro_page(1, 19)
    elseif player.sub_job == "THF" then
        set_macro_page(1, 19)
    else
        set_macro_page(1, 19)
    end
end