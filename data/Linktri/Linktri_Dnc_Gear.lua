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

-- ======================================================================
-- ROLLER'S RING - Lucky 11 Roll Detection System
-- ======================================================================
lucky_11_rolls = {}
lucky_11_ring_slot = 'ring2'  -- Change to 'ring1' if you prefer

-- Map roll ability IDs to buff IDs
roll_ability_to_buff = {
    [98] = 310,   -- Fighter's Roll
    [99] = 311,   -- Monk's Roll
    [100] = 312,  -- Healer's Roll
    [101] = 313,  -- Wizard's Roll
    [102] = 314,  -- Warlock's Roll
    [103] = 315,  -- Rogue's Roll
    [104] = 316,  -- Gallant's Roll
    [105] = 317,  -- Chaos Roll
    [106] = 318,  -- Beast Roll
    [107] = 319,  -- Choral Roll
    [108] = 320,  -- Hunter's Roll
    [109] = 321,  -- Samurai Roll
    [110] = 322,  -- Ninja Roll
    [111] = 323,  -- Drachen Roll
    [112] = 324,  -- Evoker's Roll
    [113] = 325,  -- Magus's Roll
    [114] = 326,  -- Corsair's Roll
    [115] = 327,  -- Puppet Roll
    [116] = 328,  -- Dancer's Roll
    [117] = 329,  -- Scholar's Roll
    [118] = 330,  -- Bolter's Roll
    [119] = 331,  -- Caster's Roll
    [120] = 332,  -- Courser's Roll
    [121] = 333,  -- Blitzer's Roll
    [122] = 334,  -- Tactician's Roll
    [302] = 335,  -- Allies' Roll
    [303] = 336,  -- Miser's Roll
    [304] = 337,  -- Companion's Roll
    [305] = 338,  -- Avenger's Roll
    [390] = 600,  -- Naturalist's Roll
    [391] = 601,  -- Runeist's Roll
}

-- COR Roll ability IDs (for fast lookup)
cor_roll_set = {}
for id, _ in pairs(roll_ability_to_buff) do
    cor_roll_set[id] = true
end

-- Function to check if we have any Lucky 11 rolls active
function has_lucky_11_rolls()
    local player = windower.ffxi.get_player()
    if not player then return false end
    
    local current_time = os.time()
    
    for buff_id, roll_data in pairs(lucky_11_rolls) do
        -- Give a 3 second grace period for newly detected rolls (buff may not be in player.buffs yet)
        local grace_period = roll_data.detected_at and (current_time - roll_data.detected_at < 3)
        
        if not grace_period then
            local has_buff = false
            for _, buff in pairs(player.buffs) do
                if buff == buff_id then
                    has_buff = true
                    break
                end
            end
            if not has_buff then
                lucky_11_rolls[buff_id] = nil
            end
        end
    end
    
    for _ in pairs(lucky_11_rolls) do
        return true
    end
    return false
end

-- Register action event to detect roll numbers
windower.register_event('action', function(act)
    if act.category == 6 then
        if cor_roll_set[act.param] then
            local player = windower.ffxi.get_player()
            if not player then return end
            
            for _, target in pairs(act.targets) do
                if target.id == player.id then
                    local roll_num = target.actions[1].param
                    local roll_id = act.param
                    
                    local roll_name = "Unknown Roll"
                    if res.job_abilities[roll_id] then
                        roll_name = res.job_abilities[roll_id].en
                    end
                    
                    if roll_num == 11 then
                        local buff_id = roll_ability_to_buff[roll_id]
                        if buff_id then
                            lucky_11_rolls[buff_id] = {
                                roll_name = roll_name,
                                roll_number = roll_num,
                                detected_at = os.time(),
                            }
                            add_to_chat(122, '[Lucky 11] ' .. roll_name .. ' detected! Roller\'s Ring equipped.')
                            -- Delay to allow buff to appear in player.buffs before gear refresh
                            coroutine.schedule(function()
                                handle_equipping_gear(player.status)
                            end, 0.5)
                        end
                    end
                    break
                end
            end
        end
    end
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
    state.Weapons:options("MpuGandring", "MpuGleti", "Aeneas", "Aeolian", "Twashtar", "Ruthless", "Kleos", "Evisceration", "LowBuff", "Karambit", "Proc")
    
    state.Weapons:set("MpuGandring")
    state.ExtraMeleeMode = M {["description"] = "Extra Melee Mode", "None", "Suppa", "DWEarrings", "DWMax"}
    state.HoxneMode = M(false, 'Hoxne Ampulla Mode') -- LINKTRI: DA+100% enchantment mode; toggle via //gs c hoxne or Ctrl+Alt+H
    
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
    send_command("bind ^f10 gs c cycle ContentMode")
	send_command('bind ^!a gs c pas2')   -- Ctrl+Alt+A triggers Aminon script (LINKTRI: moved off ^!p, which collided with PorterPacker's addon-managed Ctrl+Alt+P pack keybind)
	send_command('bind ^!h gs c hoxne')  -- Ctrl+Alt+H toggles Hoxne Ampulla mode (LINKTRI)

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
        ear1 = "Dudgeon Earring",           -- DW+7% (set bonus with Heartseeker)
        ear2 = "Heartseeker Earring",       -- DW+7% (set bonus with Dudgeon)
        body = "Macu. Casaque +3",          -- DW+11%
        back = { name="Toetapper Mantle", augments={'"Store TP"+3','"Dual Wield"+2','"Rev. Flourish"+30','Weapon skill damage +3%',}}, -- DW+2%
        waist = "Reiki Yotai"               -- DW+7% | Total gear DW: +34%
    }

    -- LINKTRI: Hoxne Ampulla mode overlay (toggle: //gs c hoxne, or Ctrl+Alt+H).
    -- With the enchantment active, DA is already capped at +100% from the ampulla alone, so
    -- every DA% on gear is wasted - and every DA proc costs 1,000 gil. Triple Attack procs
    -- are FREE (no charge) and hit harder, so this overlay strips all DA sources and stacks
    -- TA + raw stats instead. Ammo is intentionally absent from the overlay: the hoxne toggle
    -- equips the ampulla and disable()s the slot, so WS/waltz/step swaps can never unequip it
    -- (unequipping drops the buff until re-used).
    -- Deliberately unchanged: Sailfi Belt +1 (DA+5%) stays in WS sets since its STR+15 is still
    -- the best owned WS waist, and Brutal Earring stays in Evisceration - their DA is just wasted.
    sets.Hoxne = {
        ear1 = "Odr Earring",           -- DEX+10, Acc+10, Crit+5% (replaces Sherida: DA+5%)
        ear2 = "Hoxne Earring",         -- All stats +15 at Mastery Rank 7 (replaces Telos: DA+1%)
        ring1 = "Gere Ring",            -- STR+10, Atk+16, TA+5%
        ring2 = "Hetairoi Ring",        -- TA+2%, TA dmg+5, Crit+1%
        waist = "Cornelia's Belt"       -- Haste+10%, STR+10 (replaces Sailfi Belt +1: DA+5%)
    }

    -- Weapons sets
    sets.weapons.MpuGandring = {main = "Mpu Gandring",sub = "Centovente"}
	sets.weapons.MpuGleti = {main = "Mpu Gandring",sub = "Gleti's Knife"}
    sets.weapons.Aeneas = {main = "Aeneas", sub = "Centovente"} -- LINKTRI: was Qutrub Knife/Ethereal Dagger placeholder; actual Aeneas (Path A) owned. Centovente TP Bonus+1000 stacks with Aeneas TP Bonus+500 for Exenterator
    sets.weapons.Aeolian = {main = { name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}}, sub = "Tauret"} -- LINKTRI: previous main was an unowned Malevolence augment (only one Malevolence in inventory); Tauret sub for Mag.Acc.
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
        ammo = "Yamarang",
        head = "Horos Tiara +4",           -- Waltz potency +15%
        neck = "Etoile Gorget +2",         -- LINKTRI: CHR+25 beats Unmoving CHR+8/VIT+8; gear waltz potency already at the +50% cap
        ear1 = "Infused Earring",
        ear2 = "Odnowa Earring +1",
        body = "Maxixi Casaque +4",        -- Waltz potency +19%
        hands = "Horos Bangles +4",        -- LINKTRI: +4 carries no waltz potency (comment was wrong); kept for CHR+38
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Cacoethic Ring +1",
        back={ name="Toetapper Mantle", augments={'"Store TP"+3','"Dual Wield"+2','"Rev. Flourish"+30','Weapon skill damage +3%',}},
        waist = "Chaac Belt",
        legs = "Dashing Subligar",
        feet = "Maxixi Toe Sh. +4"         -- Waltz potency +14%
    }

    sets.Self_Waltz = {head = "Mummu Bonnet +2", body = "Vanya Robe", ring1 = "Defending Ring", ammo = "Yamarang",}

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz["Healing Waltz"] = {ammo = "Yamarang"}

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
        ammo = "Yamarang",              -- LINKTRI: Acc+15/MAcc+15 for step landing; Pebble added nothing
        head = "Maxixi Tiara +4",       -- Step Accuracy +35
        neck = "Etoile Gorget +2",
        ear1 = "Telos Earring",
        ear2 = "Macu. Earring +1",
        body = "Macu. Casaque +3",      -- Highest accuracy, DT-14%
        hands = "Maxixi Bangles +4",    -- Step Accuracy +40
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back = gear.stp_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Gleti's Breeches",
        feet = "Horos Toe Sh. +4"       -- Step Accuracy +24, Step TP -20
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
        ammo = "Yamarang",              -- LINKTRI: Acc+15/MAcc+15 for stun landing; Pebble added nothing
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
        ammo = "Yamarang",              -- LINKTRI: Acc+15/MAcc+15 for gravity landing; Pebble added nothing
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
        back={ name="Toetapper Mantle", augments={'"Store TP"+3','"Dual Wield"+2','"Rev. Flourish"+30','Weapon skill damage +3%',}},
        hands = "Macu. Bangles +3"
    }

    sets.precast.Flourish3 = {}
    sets.precast.Flourish3["Striking Flourish"] = {
        body = "Macu. Casaque +3"
    }
    sets.precast.Flourish3["Climactic Flourish"] = {
        head = "Maculele Tiara +3"    -- Climactic Flourish: Crit rate +1%, Crit damage +31%
    }

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
        ammo = "Oshasha's Treatise",    -- LINKTRI: single-hit WS; WSD+3% beats Pebble PDL+3% outside attack-capped content. Acc variant keeps Pebble
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
        legs = "Nyame Flanchard",       -- LINKTRI: WSD+11% (R25); high-buff PDL swap to Maculele Tights +3 handled in job_post_precast
        feet = "Nyame Sollerets"
    }
    
    
    sets.precast.WS["Ruthless Stroke"] = {
        ammo = "Oshasha's Treatise",    -- LINKTRI: single-hit WSD scaler; WSD+3% beats Coiste DA+3%
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
        ammo = "Oshasha's Treatise",    -- LINKTRI: single-hit WS; WSD+3% beats Pebble PDL+3% outside attack-capped content. Acc variant keeps Pebble
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
        legs = "Nyame Flanchard",       -- LINKTRI: WSD+11% (R25); high-buff PDL swap to Maculele Tights +3 handled in job_post_precast
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
        ammo = "Coiste Bodhar",         -- LINKTRI: multi-hit WS; DA+3% beats Pebble's PDL+3%
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
        waist = "Orpheus's Sash",       -- LINKTRI: large magical WS boost at close range; .TH variant still applies Chaac Belt
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
        ear1 = "Odr Earring"  -- Swap Moonshade for Odr at 3000 TP; ear2 stays Macu. Earring +1 from base set
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
			head = "Null Masque",                      -- DT-10%, Regen+3, Refresh+1, Regain+2 (LINKTRI: was Gleti's Mask PDT-6/Regain+2 - net regain unchanged, adds regen/refresh)
			neck = "Loricate Torque +1",               -- DT-6%
			ear1 = "Alabaster Earring",                -- DT-5%, Haste+5% (LINKTRI: idle now caps MDT as well as PDT)
			ear2 = "Odnowa Earring +1",                -- DT-3%, MDT-1% (LINKTRI)
			body = "Gleti's Cuirass",                  -- PDT-9%, Regain+3
			hands = "Gleti's Gauntlets",               
			ring1 = { name="Murky Ring", augments={'Path: A',}}, -- DT-4%
			ring2 = "Defending Ring",                  -- DT-10% (CHANGED)
			back = gear.stp_jse_back,                  -- DT-5%
			waist = "Null Belt",                       -- MEva+30, Regen+3 (LINKTRI: was Carrier's Sash; swap back if stacking elemental resistance for specific content)
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
        ammo = "Staunch Tathlum +1",    -- LINKTRI: resist all status +11, DT-3%; Coiste added nothing to a resist set
        head = "Malignance Chapeau",    -- LINKTRI: MEva+123 vs Maxixi 98, plus DT-6%
        neck = "Loricate Torque +1",    -- LINKTRI: Yarak Torque unowned and adds zero MEva (katana/archery/evasion skill only)
        ear1 = "Etiolation Earring",
        ear2 = "Sanare Earring",
        body = "Malignance Tabard",     -- LINKTRI: MEva+139 vs Horos 124, plus DT-9%
        hands = "Nyame Gauntlets",
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Vengeful Ring",
        back = gear.stp_jse_back,
        waist = "Null Belt",
        legs = "Malignance Tights",     -- LINKTRI: MEva+150 vs Rawhide ~69
        feet = "Malignance Boots"
    }

    sets.Kiting = {ring1 = "Shneddick Ring +1"}

    -- Engaged sets

    -- OPTIMIZED: Normal Mode - Pure Offense with natural DT (-33%)
    -- LINKTRI: legs now Malignance Tights. STP: 67, Haste: 30%, Multi-attack: DA+10%, TA+4%
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
        legs = "Malignance Tights",            -- Haste+9%, STP+10, DT-7% (LINKTRI: Horos WSD+12% does nothing at TP time; Saber Dance overlay still swaps Horos Tights +4 in)
        feet = "Macu. Toe Sh. +3"              -- DT-10%, STP+12, Haste+5%
    }

    -- OPTIMIZED: DTLite Mode - Balanced Defense (-33% DT)
    -- LINKTRI: with Alabaster Earring: ~32% DT, Haste 35% (overcapped), STP 62
    sets.engaged.DTLite = {
        ammo = "Coiste Bodhar",
        head = "Maculele Tiara +3",            -- Haste+8%, STP+10
        neck = "Etoile Gorget +2",
        ear1 = "Sherida Earring",              -- STP+5, DA+5%
        ear2 = "Alabaster Earring",            -- DT-5%, Haste+5% (LINKTRI: keeps DTLite defensively distinct now that Normal shares Malignance Tights; Acc variants still override to Macu. Earring +1)
        body = "Horos Casaque +4",             -- PDT-6%, Haste+4%, TA+4%, Attack+96
        hands = "Malignance Gloves",           -- DT-5%, STP+12, Haste+4%
        ring1 = "Chirich Ring +1",             -- STP+4
        ring2 = "Chirich Ring +1",             -- STP+4
        back = gear.stp_jse_back,              -- DT-5%, STP+10
        waist = "Sailfi Belt +1",
        legs = "Malignance Tights",            -- DT-7%, STP+10, Haste+9%
        feet = "Macu. Toe Sh. +3"              -- DT-10%, STP+12, Haste+5%
    }

    -- OPTIMIZED: DTFull Mode - Maximum Defense (DT capped -50%)
    -- LINKTRI revision: prior build totaled 52% DT (overcapped). Null Masque + Null Loop
    -- + Telos keeps the 50% cap while gaining +4% haste, ~+100 acc/macc, and an offensive ear.
    sets.engaged.DTFull = {
        ammo = "Coiste Bodhar",
        head = "Null Masque",                  -- DT-10%, Haste+10%, Acc+50 (LINKTRI: was Malignance Chapeau)
        neck = "Null Loop",                    -- DT-5%, Acc+50/MAcc+50 (LINKTRI: was Loricate Torque +1)
        ear1 = "Sherida Earring",              -- STP+5, DA+5%
        ear2 = "Telos Earring",                -- Acc+10, DA+1%, STP+5 (LINKTRI: DT still capped at 50% after Null Masque/Null Loop swaps)
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
    sets.engaged.Aminon = {
        ammo = "Staunch Tathlum +1",        -- DT -3%
        head = "Gleti's Mask",              -- Regain +2/tick, HP +147
        neck = "Loricate Torque +1",        -- DT -6%
        ear1 = "Sanare Earring",            -- MEVA
        ear2 = "Odnowa Earring +1",           -- MDT -2%, HP conversion
        body = "Macu. Casaque +3", 			-- DT -14%
        hands = "Regal Gloves",             -- Converts 20% damage to TP, DT +20%, HP +342, DEX +40, Acc +45
        ring1 = { name="Murky Ring", augments={'Path: A',}},
        ring2 = "Chirich Ring +1",          -- Store TP +10
        back = gear.stp_jse_back,          -- DT -5%, STP+10
        waist = "Sailfi Belt +1",           -- 
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
    -- LINKTRI: trimmed overlay to head only. The ammo/body lines were overwriting WS pieces
    -- (Nyame Mail WSD+12%, Oshasha's Treatise) during every Climactic-boosted weaponskill;
    -- Horos Casaque +4 has no crit synergy. Maculele Tiara +3 is the actual Climactic piece.
    sets.buff["Climactic Flourish"] = {
        head = "Maculele Tiara +3"
    }
    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Sleep = {}
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

-- Get optimal TP threshold - 2000 TP with Centovente = effective 3000 (capped fTP)
function get_tp_threshold(spell)
    return 2000
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

-- Post-precast function for TP-based gear swapping
function user_job_post_precast(spell, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        local current_tp = player.tp
        local is_high_buff = is_high_buff_situation()
        
        -- At 2000+ TP, Centovente gives effective 3000 TP (capped fTP)
        -- Swap Moonshade for damage earring
        -- LINKTRI: gated on Centovente actually being equipped. With other subs (e.g. Gleti's
        -- Knife) this fired 250 effective TP early; job_post_precast's >3200 effective-TP
        -- check still covers the non-Centovente case.
        if current_tp >= 2000 and player.equipment.sub == "Centovente" then
            if sets.MaxTP[spell.english] then
                equip(sets.MaxTP[spell.english])
            elseif sets.MaxTP then
                equip(sets.MaxTP)
            end
        end
        
        -- Ephramad's Ring for high buff situations (PDL) at 1000+ TP
        if current_tp >= 1000 and is_high_buff then
            equip({ring1 = "Ephramad's Ring"})
        end
        
        -- Buff-specific modifications
        if state.Buff['Climactic Flourish'] and sets.buff['Climactic Flourish'] then
            equip(sets.buff['Climactic Flourish'])
        end
        
        if state.Buff['Saber Dance'] and spell.english == "Rudra's Storm" then
            equip({legs = "Horos Tights +4"})
        end
    end
end

-- ======================================================================
-- JOB POST PRECAST - Content-aware WS gear optimization
-- This overrides DNC.lua's job_post_precast since gear file loads after.
-- Replicates DNC.lua's Moonshade/Climactic Flourish logic, then adds
-- ContentMode-aware PDL swaps on top for high-buff content.
-- Roller's Ring is NOT handled here - job_aftercast covers that.
-- ======================================================================
function job_post_precast(spell, spellMap, eventArgs)
    if spell.type ~= 'WeaponSkill' then return end

    -- Step 1: Replicate DNC.lua Moonshade swap logic
    -- Swap out Moonshade when TP bonus pushes us over effective 3000 cap
    local WSset = standardize_set(get_precast_set(spell, spellMap))
    if WSset.ear1 == "Moonshade Earring" or WSset.ear2 == "Moonshade Earring" then
        if get_effective_player_tp(spell, WSset) > 3200 then
            local wsacc = check_ws_acc()
            if wsacc:contains('Acc') and not buffactive['Sneak Attack'] and sets.AccMaxTP then
                equip(sets.AccMaxTP[spell.english] or sets.AccMaxTP)
            elseif sets.MaxTP then
                equip(sets.MaxTP[spell.english] or sets.MaxTP)
            end
        end
    end

    -- Step 2: Replicate DNC.lua Climactic Flourish overlay
    if state.Buff['Climactic Flourish'] and sets.buff['Climactic Flourish'] then
        equip(sets.buff['Climactic Flourish'])
    end

    -- Step 3: ContentMode-aware PDL swaps for high-buff content
    -- Only applies in Sortie/Odyssey where attack is high enough to hit pDIF cap
    if is_high_buff_situation() then
        -- All WSs: Ephramad's Ring in ring1 for PDL+10%
        -- Exception: don't override ring1 if Climactic Flourish already set it
        -- (Climactic Flourish set only touches head, so ring1 is safe to set here)
        equip({ring1 = "Ephramad's Ring"})

        -- LINKTRI: extended to Rudra's Storm and Shark Bite - their base sets now use
        -- Nyame Flanchard (WSD+11% R25), so high-buff situations swap to Maculele Tights +3
        -- for PDL+10% (PDL+20% total with Ephramad's Ring).
        -- Exception: Saber Dance active -> keep Horos Tights +4 for its WSD/Saber augment
        if spell.english == "Ruthless Stroke" or spell.english == "Rudra's Storm" or spell.english == "Shark Bite" then
            if not state.Buff['Saber Dance'] then
                equip({legs = "Maculele Tights +3"})
            end
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
        -- After WS completes, re-equip melee set (which includes Roller's Ring via customize_melee_set)
        coroutine.schedule(function()
            if player.status == 'Engaged' then
                handle_equipping_gear(player.status)
            end
        end, 0.5)
    elseif has_lucky_11_rolls() and spell.type ~= 'WeaponSkill' then
        -- Re-equip Roller's Ring after non-WS actions if Lucky 11 roll active
        coroutine.schedule(function()
            if player.status == 'Engaged' then
                handle_equipping_gear(player.status)
            else
                equip({[lucky_11_ring_slot] = "Roller's Ring"})
            end
        end, 0.3)
    end
end

-- Enhanced step accuracy based on current conditions
function user_job_customize_idle_set(idleSet)
    -- AMINON RANGE FIX: When engaged but outside melee range, GearSwap may use idle set
    -- Force FULL Aminon engaged set when status is Engaged and HybridMode is Aminon
    if player.status == 'Engaged' and state.HybridMode.value == 'Aminon' then
        -- Force the complete Aminon set, not just combine
        idleSet = sets.engaged.Aminon
        -- Apply accuracy variant if needed
        if state.OffenseMode.value == 'SomeAcc' and sets.engaged.Aminon.SomeAcc then
            idleSet = set_combine(idleSet, sets.engaged.Aminon.SomeAcc)
        elseif state.OffenseMode.value == 'Acc' and sets.engaged.Aminon.Acc then
            idleSet = set_combine(idleSet, sets.engaged.Aminon.Acc)
        elseif state.OffenseMode.value == 'FullAcc' and sets.engaged.Aminon.FullAcc then
            idleSet = set_combine(idleSet, sets.engaged.Aminon.FullAcc)
        end
    end
    
    -- Equip Roller's Ring if we have Lucky 11 rolls active
    if has_lucky_11_rolls() then
        idleSet = set_combine(idleSet, {[lucky_11_ring_slot] = "Roller's Ring"})
    end
    
    return idleSet
end

-- Mote framework hook for idle set
function job_customize_idle_set(idleSet)
    return user_job_customize_idle_set(idleSet)
end

function user_job_customize_melee_set(meleeSet)
    -- AMINON MODE: Force Aminon gear regardless of DW/haste tier
    if state.HybridMode.value == 'Aminon' then
        meleeSet = set_combine(meleeSet, sets.engaged.Aminon)
        -- Apply accuracy variant if needed
        if state.OffenseMode.value == 'SomeAcc' and sets.engaged.Aminon.SomeAcc then
            meleeSet = set_combine(meleeSet, sets.engaged.Aminon.SomeAcc)
        elseif state.OffenseMode.value == 'Acc' and sets.engaged.Aminon.Acc then
            meleeSet = set_combine(meleeSet, sets.engaged.Aminon.Acc)
        elseif state.OffenseMode.value == 'FullAcc' and sets.engaged.Aminon.FullAcc then
            meleeSet = set_combine(meleeSet, sets.engaged.Aminon.FullAcc)
        end
    end

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
    
    -- LINKTRI: Hoxne Ampulla overlay. Applied after ContentMode so its rings win, but before
    -- Roller's Ring so a Lucky 11 ring still takes priority. Gated to Normal/DTLite with no
    -- DefenseMode so it can't overwrite Defending Ring in DTFull or the Aminon/defense builds.
    if state.HoxneMode and state.HoxneMode.value and state.DefenseMode.value == 'None'
            and (state.HybridMode.value == 'Normal' or state.HybridMode.value == 'DTLite') then
        meleeSet = set_combine(meleeSet, sets.Hoxne)
    end

    -- Equip Roller's Ring if we have Lucky 11 rolls active
    if has_lucky_11_rolls() then
        meleeSet = set_combine(meleeSet, {[lucky_11_ring_slot] = "Roller's Ring"})
    end
    
    return meleeSet
end

-- Mote framework hook - this gets called by the base library
function job_customize_melee_set(meleeSet)
    return user_job_customize_melee_set(meleeSet)
end

-- Enhanced self command for new toggles
function user_job_self_command(commandArgs, eventArgs)
    if commandArgs[1]:lower() == 'contentmode' then
        state.ContentMode:cycle()
        add_to_chat(122, 'Content Mode: '..state.ContentMode.value)
        eventArgs.handled = true
	elseif commandArgs[1]:lower() == 'pas2' then
        windower.send_command('exec AminonDNC.txt')
        add_to_chat(122, 'Getting jiggy! Go on Chainspell TP Denial!')
        eventArgs.handled = true
    -- LINKTRI: Hoxne Ampulla mode toggle. Locks the ammo slot while active so gear swaps
    -- can never unequip the ampulla (which would drop the DA+100% buff).
    elseif commandArgs[1]:lower() == 'hoxne' then
        state.HoxneMode:toggle()
        if state.HoxneMode.value then
            enable('ammo')
            equip({ammo = "Hoxne Ampulla"})
            disable('ammo')
            add_to_chat(122, 'Hoxne Ampulla mode ON - ammo locked. Use the ampulla to activate DA+100% (1,000g per DA proc; re-use after zoning).')
        else
            enable('ammo')
            add_to_chat(122, 'Hoxne Ampulla mode OFF - ammo slot unlocked.')
        end
        handle_equipping_gear(player.status)
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

    -- LINKTRI: surface Hoxne Ampulla mode in the job state display
    if state.HoxneMode and state.HoxneMode.value then
        msg = msg .. ', HOXNE ($$)'
    end

    msg = msg .. ', ['..state.MainStep.current

    if state.UseAltStep.value == true then
        msg = msg .. '/'..state.AltStep.current
    end
    
    msg = msg .. ']'
    
    -- Add enhanced mode display
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