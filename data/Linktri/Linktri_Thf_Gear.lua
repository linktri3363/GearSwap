fixed_pos = ''
fixed_ts = os.time()
local no_interruptions = true
near_porter = false  -- Track if we're near Porter Moogle
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

-- Define gear variables at file scope (must be before init_gear_sets)
gear.da_jse_back = {name = "Toutatis's Cape", augments = {"DEX+20", "Accuracy+20 Attack+20", '"Dbl.Atk."+10', "Phys. dmg. taken-10%"}}
gear.wsd_jse_back = {
    name = "Toutatis's Cape",
    augments = {"DEX+20", "Accuracy+20 Attack+20", "Weapon skill damage +10%", "Phys. dmg. taken-10%"}
}

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_job_setup()
    -- Options: Override default values
    state.OffenseMode:options("Normal", "STP", "SomeAcc", "Acc", "FullAcc", "Fodder")
    state.HybridMode:options("Normal", "DT")
    state.RangedMode:options("Normal", "Acc")
    state.WeaponskillMode:options("Match", "Normal", "DT", "SomeAcc", "Acc", "FullAcc", "Fodder", "Proc")
    state.IdleMode:options("Normal", "Sphere")
    state.PhysicalDefenseMode:options("PDT")
    state.MagicalDefenseMode:options("MDT")
    state.ResistDefenseMode:options("MEVA")
    state.Weapons:options(
    "Prime",
    "Twashtar",
    "Vajra",
    "Aeneas",
    "Tauret",
    "Savage",
    "ProcWeapons",
    "Evisceration",
    "Throwing",
    "SwordThrowing",
    "Bow",
    "RedProcDagger",
    "RedProcSword", 
    "RedProcGrSwd",
    "RedProcScythe",
    "RedProcPole",
    "RedProcClub",
    "RedProcStaff"
)

    state.ExtraMeleeMode = M {["description"] = "Extra Melee Mode", "None", "Suppa", "DWMax", "Parry"}
    state.AmbushMode = M(false, "Ambush Mode")

    -- Additional local binds
    send_command('bind ^` input /ja "Flee" <me>')
    send_command("bind !` input /ra <t>")
    send_command("bind @` gs c cycle SkillchainMode")
    send_command("bind @f10 gs c toggle AmbushMode")
    send_command('bind ^backspace input /item "Thief\'s Tools" <t>')
    send_command("bind ^q gs c weapons ProcWeapons;gs c set WeaponSkillMode proc;")
    send_command("bind !q gs c weapons SwordThrowing")
    send_command('bind !backspace input /ja "Hide" <me>')
-- Commented out to avoid conflicts and errors
-- send_command('bind @r gs c weapons Prime;gs c set WeaponSkillMode match')
    send_command('bind ^\\\\ input /ja "Despoil" <t>')
    send_command('bind !\\\\ input /ja "Mug" <t>')
    
    -- Macro binds for red proc weapons:
-- Add these to your user_job_setup() function

    send_command('bind ^numpad1 gs c weapons RedProcDagger')   -- Energy Drain/Cyclone
    send_command('bind ^numpad2 gs c weapons RedProcSword')  -- Seraph Blade/Red Lotus
    send_command('bind ^numpad3 gs c weapons RedProcGrSwd')    -- Freezebite
    send_command('bind ^numpad4 gs c weapons RedProcScythe')   -- Shadow of Death
    send_command('bind ^numpad5 gs c weapons RedProcPole')     -- Raiden Thrust
    send_command('bind ^numpad6 gs c weapons RedProcClub')     -- Seraph Strike
    send_command('bind ^numpad7 gs c weapons RedProcStaff')    -- Earth Crusher/Starburst

    select_default_macro_book()
end

-- Add this to prevent the update_job_states error
function update_job_states()
    -- Do nothing to prevent errors
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Special sets (required by rules)
    --------------------------------------

    -- Enhanced Treasure Hunter Sets based on YOUR available equipment
    sets.TreasureHunter = {
        hands = "Plun. Armlets +4", -- TH+4
        waist = "Chaac Belt", -- TH+1
        feet = "Skulk. Poulaines +3", -- TH+3
        ammo = "Per. Lucky Egg" -- TH+1
    }

    -- Maximum TH set (using your gear - TH+9 total)
    sets.TreasureHunterMax = sets.TreasureHunter
    -- Total TH from your gear: +9 (plus +3 from trait = TH12 base)

    -- Practical TH set (balances TH with some survivability/accuracy)
    sets.TreasureHunterPractical = {
        main = "Mpu Gandring", -- Prime weapon
        sub = "Gleti's Knife", -- Good stats
        neck = "Loricate Torque +1", -- Survivability
        hands = "Plun. Armlets +4", -- TH+4
        ring1 = "Murky Ring", -- DT-10%, Acc+15, Eva+7 (rank 22)
        ring2 = "Chirich Ring +1", -- Regen +2, STP+6
        waist = "Chaac Belt", -- TH+1
        feet = "Skulk. Poulaines +3", -- TH+3
        ammo = "Per. Lucky Egg" -- TH+1
    }

    sets.Kiting = {ring1 = "Shneddick Ring +1"}

    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Sleep = {}

    sets.buff["Sneak Attack"] = {}
    sets.buff["Trick Attack"] = {hands = "Pill. Armlets +4"}

    -- Extra Melee sets.  Apply these on top of melee sets.
    sets.Knockback = {}
    sets.Suppa = {ear1 = "Suppanomimi", ear2 = "Sherida Earring"}
    sets.DWEarrings = {ear1 = "Dudgeon Earring", ear2 = "Heartseeker Earring"}
    sets.DWMax = {ear1 = "Dudgeon Earring", ear2 = "Heartseeker Earring", hands = "Floral Gauntlets"}
    sets.Parry = {ring1 = "Defending Ring"}
    sets.Ambush = {body = {name = "Plunderer's Vest +4", augments = {"Enhances \"Ambush\" effect"}}} -- Crit+6%, Crit dmg+5% when behind target or SA

    -- Weapons sets - Prime is now default
    sets.weapons.Prime = {main = "Mpu Gandring", sub = "Centovente"}
    sets.weapons.Twashtar = {main = "Twashtar", sub = "Centovente"}
    sets.weapons.Vajra = {main = "Vajra", sub = "Gleti's Knife"}
    sets.weapons.Aeneas = {main = "Aeneas", sub = "Gleti's Knife"}
    sets.weapons.Tauret = {main = "Tauret", sub = "Gleti's Knife"}
    sets.weapons.Savage = {main = "Naegling", sub = "Centovente"}
    sets.weapons.ProcWeapons = {main = "Ethereal Dagger", sub = "Twinned Blade"}
    sets.weapons.Evisceration = {main = "Tauret", sub = "Gleti's Knife"}
    sets.weapons.Throwing = {main = "Qutrub Knife", sub = "Twinned Blade"}
    sets.weapons.SwordThrowing = {main = "Naegling", sub = "Gleti's Knife"}
    sets.weapons.Bow = {main = "Mpu Gandring", sub = "Ternion Dagger +1", range = "Hangaku-no-Yumi", ammo = "Jukukik Feather"}
    -- Red Proc Weaponsets for Abyssea

-- Energy Drain & Cyclone (Dagger)
sets.weapons.RedProcDagger = {main = "Ethereal Dagger", sub = "Twinned Blade"}

-- Seraph Blade & Red Lotus Blade (Dagger)  
sets.weapons.RedProcSword = {main = "Twinned Blade", sub = "Ethereal Dagger"}

-- Freezebite (Sword) - 2H weapon
sets.weapons.RedProcGrSwd = {main = "Irradiance Blade"}

-- Shadow of Death (Scythe) - 2H weapon
sets.weapons.RedProcScythe = {main = "Ark Scythe"}

-- Raiden Thrust (Polearm) - 2H weapon
sets.weapons.RedProcPole = {main = "Tzee Xicu's Blade"}

-- Seraph Strike (Club) - 2H weapon
sets.weapons.RedProcClub = {main = "Nmd. Moogle Rod", sub = "Ethereal Dagger"}

-- Earth Crusher & Starburst (Staff) - 2H weapon
sets.weapons.RedProcStaff = {main = "Cobra Staff"}

    -- Actions we want to use to tag TH.
    sets.precast.Step =
        set_combine(
        sets.TreasureHunter,
        {
            head = "Pill. Bonnet +4",
            neck = "Asn. Gorget +2",
            ear1 = "Brutal Earring",
            ear2 = "Odr Earring",
            body = "Pill. Vest +4",
            ring1 = "Ilabrat Ring",
            ring2 = "Epona's Ring",
            back = gear.da_jse_back,
            legs = "Pill. Culottes +4",
            feet = "Pill. Poulaines +4"
        }
    )

    sets.precast.JA["Violent Flourish"] =
        set_combine(
        sets.TreasureHunter,
        {
            head = "Pill. Bonnet +4",
            neck = "Asn. Gorget +2",
            ear1 = "Brutal Earring",
            ear2 = "Odr Earring",
            body = "Pill. Vest +4",
            ring1 = "Ilabrat Ring",
            ring2 = "Epona's Ring",
            back = gear.da_jse_back,
            legs = "Pill. Culottes +4",
            feet = "Pill. Poulaines +4"
        }
    )

    sets.precast.JA["Animated Flourish"] = sets.TreasureHunter
    sets.precast.JA.Provoke = sets.TreasureHunter

    --------------------------------------
    -- Precast sets
    --------------------------------------

    -- Precast sets to enhance JAs
    sets.precast.JA["Collaborator"] = {head = "Skulker's Bonnet +3"}
    sets.precast.JA["Accomplice"] = {head = "Skulker's Bonnet +3"}
    sets.precast.JA["Flee"] = {feet = "Pill. Poulaines +4"}
    sets.precast.JA["Hide"] = {body = "Pill. Vest +4"}
    sets.precast.JA["Conspirator"] = {body = "Skulker's Vest +3"}
    sets.precast.JA["Steal"] = set_combine(sets.TreasureHunter, {
        feet = "Pill. Poulaines +4",  -- Force Steal recast reduction, overrides TH feet
		hands = "Thief's Kote",
		neck = "Pentalagus Charm",
    })
    sets.precast.JA["Mug"] = {head = "Plun. Bonnet +4"} -- Mug+5
    sets.precast.JA["Despoil"] = {legs = "Skulk. Culottes +3"}
    sets.precast.JA["Perfect Dodge"] = {hands = "Plun. Armlets +4"}
    sets.precast.JA["Feint"] = {legs = "Plun. Culottes +4"}

    sets.precast.JA["Sneak Attack"] = sets.buff["Sneak Attack"]
    sets.precast.JA["Trick Attack"] = sets.buff["Trick Attack"]

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {
        head = "Mummu Bonnet +2",
        neck = "Loricate Torque +1",
        body = "Malignance Tabard",
        ring1 = "Murky Ring", -- DT-10%, Acc+15, Eva+7 (rank 22)
        ring2 = "Chirich Ring +1",
        back = "Toutatis's Cape",
        waist = "Chaac Belt",
        legs = "Malignance Tights"
    }

    sets.Self_Waltz = {head = "Mummu Bonnet +2", body = "Malignance Tabard"}

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz["Healing Waltz"] = {}

    -- Fast cast sets for spells - optimized with available gear
    sets.precast.FC = {
        ammo = "Impatiens",
        head = "Malignance Chapeau", -- 13% FC
        neck = "Voltsurge Torque", -- 4% FC
        ear1 = "Loquac. Earring", -- 2% FC
        ear2 = "Enervating Earring", -- 1% FC
        body = "Malignance Tabard", -- 8% FC
        hands = "Fanatic Gloves", -- 5% FC
        ring1 = "Lebeche Ring", -- 2% QM
        ring2 = "Kishar Ring", -- 4% FC
        legs = "Rawhide Trousers", -- 5% FC
        feet = "Malignance Boots" -- 6% FC
    }

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck = "Magoraga Beads", body = "Malignance Tabard"})

    -- Ranged snapshot gear
    sets.precast.RA = {}

    -- Weaponskill sets - optimized based on available gear and current meta

    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        head = "Nyame Helm",
        neck = "Asn. Gorget +2", -- Better than Fotia for accuracy and dex
        ear1 = "Moonshade Earring",
        ear2 = "Sherida Earring", -- Better damage than Odr for general use
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Ilabrat Ring",
        ring2 = "Gere Ring",
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1", -- WSD and stats
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }
    sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {ear2 = "Odr Earring"})
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {ear1 = "Odr Earring", ear2 = "Odr Earring"})
    sets.precast.WS.FullAcc = set_combine(sets.precast.WS, {ear1 = "Odr Earring", ear2 = "Odr Earring"})

    -- Specific weaponskill sets - optimized for current meta
    -- Rudra's Storm: 80% DEX mod, benefits from WSD and DEX
    sets.precast.WS["Rudra's Storm"] =
        set_combine(
        sets.precast.WS,
        {
            head = "Pill. Bonnet +4", -- WSD+9%, Crit dmg+5%, DEX+42
            neck = "Asn. Gorget +2", -- DEX+25
            ear1 = "Moonshade Earring",
            ear2 = "Sherida Earring", -- DEX+5
            body = "Skulker's Vest +3", -- WSD+12%, Dagger skill+38
            hands = {name = "Nyame Gauntlets", augments = {"Path: B"}}, -- WSD+5%
            ring1 = "Ilabrat Ring", -- DEX+10
            ring2 = "Gere Ring", -- Crit rate+5%
            back = gear.wsd_jse_back, -- DEX+20, WSD+10%
            waist = {name = "Sailfi Belt +1", augments = {"Path: A"}}, -- WSD+5%
            legs = {name = "Nyame Flanchard", augments = {"Path: B"}}, -- WSD+6%
            feet = {name = "Nyame Sollerets", augments = {"Path: B"}} -- WSD+5%
        }
    ) -- Total WSD: 52% (9+12+5+10+5+6+5), excellent DEX stacking
    sets.precast.WS["Rudra's Storm"].SomeAcc = set_combine(sets.precast.WS["Rudra's Storm"], {ear2 = "Odr Earring"})
    sets.precast.WS["Rudra's Storm"].Acc = set_combine(sets.precast.WS["Rudra's Storm"], {ear1 = "Odr Earring", ear2 = "Odr Earring"})
    sets.precast.WS["Rudra's Storm"].FullAcc = set_combine(sets.precast.WS["Rudra's Storm"], {ear1 = "Odr Earring", ear2 = "Odr Earring"})
    sets.precast.WS["Rudra's Storm"].Fodder = set_combine(sets.precast.WS["Rudra's Storm"], {})
    sets.precast.WS["Rudra's Storm"].DT =
        set_combine(sets.precast.WS["Rudra's Storm"], {neck = "Loricate Torque +1", ring1 = "Murky Ring", ring2 = "Defending Ring"})
    sets.precast.WS["Rudra's Storm"].SA =
        set_combine(sets.precast.WS["Rudra's Storm"].Fodder, {legs = "Pill. Culottes +4"})
    sets.precast.WS["Rudra's Storm"].TA =
        set_combine(sets.precast.WS["Rudra's Storm"].Fodder, {hands = "Pill. Armlets +4", legs = "Pill. Culottes +4"})
    sets.precast.WS["Rudra's Storm"].SATA =
        set_combine(sets.precast.WS["Rudra's Storm"].Fodder, {hands = "Pill. Armlets +4", legs = "Pill. Culottes +4"})

    -- Ruthless Stroke (Prime WS) sets - optimized
    -- 40% STR / 40% DEX mod, benefits from WSD, multi-hit fTP transfer
    sets.precast.WS["Ruthless Stroke"] =
        set_combine(
        sets.precast.WS,
        {
            head = "Pill. Bonnet +4", -- WSD+9%, Crit dmg+5%, DEX+42, STR+30
            neck = "Asn. Gorget +2", -- DEX+25
            ear1 = "Moonshade Earring",
            ear2 = "Sherida Earring", -- DEX+5
            body = "Skulker's Vest +3", -- WSD+12%, Dagger skill+38
            hands = {name = "Nyame Gauntlets", augments = {"Path: B"}}, -- WSD+5%
            ring1 = "Ilabrat Ring", -- DEX+10
            ring2 = "Ephramad's Ring", -- Crit rate+5%
            back = gear.wsd_jse_back, -- DEX+20, WSD+10%
            waist = {name = "Sailfi Belt +1", augments = {"Path: A"}}, -- WSD+5%
            legs = "Plun. Culottes +4", -- WSD+9%
            feet = {name = "Nyame Sollerets", augments = {"Path: B"}} -- WSD+5%
        }
    ) -- Total WSD: 55% (9+12+5+10+5+9+5), excellent for Prime WS
    sets.precast.WS["Ruthless Stroke"].SomeAcc = set_combine(sets.precast.WS["Ruthless Stroke"], {ear2 = "Odr Earring"})
    sets.precast.WS["Ruthless Stroke"].Acc = set_combine(sets.precast.WS["Ruthless Stroke"], {ear1 = "Odr Earring", ear2 = "Odr Earring"})
    sets.precast.WS["Ruthless Stroke"].FullAcc = set_combine(sets.precast.WS["Ruthless Stroke"], {ear1 = "Odr Earring", ear2 = "Odr Earring"})
    sets.precast.WS["Ruthless Stroke"].Fodder = set_combine(sets.precast.WS["Ruthless Stroke"], {})
    sets.precast.WS["Ruthless Stroke"].DT =
        set_combine(sets.precast.WS["Ruthless Stroke"], {neck = "Loricate Torque +1", ring1 = "Murky Ring", ring2 = "Defending Ring"})
    sets.precast.WS["Ruthless Stroke"].SA =
        set_combine(sets.precast.WS["Ruthless Stroke"].Fodder, {legs = "Pill. Culottes +4"})
    sets.precast.WS["Ruthless Stroke"].TA =
        set_combine(sets.precast.WS["Ruthless Stroke"].Fodder, {hands = "Pill. Armlets +4", legs = "Pill. Culottes +4"})
    sets.precast.WS["Ruthless Stroke"].SATA =
        set_combine(sets.precast.WS["Ruthless Stroke"].Fodder, {hands = "Pill. Armlets +4", legs = "Pill. Culottes +4"})

    -- Mandalic Stab - optimized for your Vajra
    sets.precast.WS["Mandalic Stab"] =
        set_combine(
        sets.precast.WS,
        {
            head = "Nyame Helm",
            neck = "Asn. Gorget +2",
            ear1 = "Moonshade Earring",
            ear2 = "Sherida Earring",
            body = "Nyame Mail",
            hands = "Nyame Gauntlets",
            ring1 = "Ilabrat Ring",
            ring2 = "Gere Ring",
            back = gear.wsd_jse_back,
            waist = "Sailfi Belt +1",
            legs = "Nyame Flanchard",
            feet = "Nyame Sollerets"
        }
    )
    sets.precast.WS["Mandalic Stab"].SomeAcc = set_combine(sets.precast.WS["Mandalic Stab"], {ear2 = "Odr Earring"})
    sets.precast.WS["Mandalic Stab"].Acc = set_combine(sets.precast.WS["Mandalic Stab"], {ear1 = "Odr Earring", ear2 = "Odr Earring"})
    sets.precast.WS["Mandalic Stab"].FullAcc = set_combine(sets.precast.WS["Mandalic Stab"], {ear1 = "Odr Earring", ear2 = "Odr Earring"})
    sets.precast.WS["Mandalic Stab"].Fodder = set_combine(sets.precast.WS["Mandalic Stab"], {})
    sets.precast.WS["Mandalic Stab"].SA =
        set_combine(sets.precast.WS["Mandalic Stab"].Fodder, {legs = "Pill. Culottes +4"})
    sets.precast.WS["Mandalic Stab"].TA =
        set_combine(sets.precast.WS["Mandalic Stab"].Fodder, {hands = "Pill. Armlets +4", legs = "Pill. Culottes +4"})
    sets.precast.WS["Mandalic Stab"].SATA =
        set_combine(sets.precast.WS["Mandalic Stab"].Fodder, {hands = "Pill. Armlets +4", legs = "Pill. Culottes +4"})

    -- Evisceration - optimized for crit builds with your gear
    -- 50% DEX mod, multi-hit WS that benefits from Crit Rate and Crit Damage
    sets.precast.WS["Evisceration"] =
        set_combine(
        sets.precast.WS,
        {
            head = "Plun. Bonnet +4", -- TA+4%, Crit rate+6% from Aura Steal augment
            neck = "Asn. Gorget +2", -- DEX+25
            ear1 = {name = "Moonshade Earring", augments = {"Accuracy+4", "TP Bonus +250"}},
            ear2 = "Sherida Earring", -- DEX+5
            body = {name = "Plunderer's Vest +4", augments = {"Enhances \"Ambush\" effect"}}, -- Crit rate+6%, Crit dmg+5%
            hands = {name = "Gleti's Gauntlets", augments = {"Path: A"}}, -- Crit rate+6%, Phys dmg limit+7%
            ring1 = "Gere Ring", -- Crit rate+5%
            ring2 = "Mummu Ring", -- Crit rate+3%
            back = gear.wsd_jse_back, -- DEX+20, WSD+10%
            waist = "Sailfi Belt +1", -- WSD+5%
            legs = "Pill. Culottes +4", -- TA+5%, Crit dmg+5%
            feet = {name = "Gleti's Boots", augments = {"Path: A"}} -- Crit rate+4%, Phys dmg limit+5%
        }
    ) -- Crit rate+30%, Crit dmg+10% - Optimized for multi-hit crits
    sets.precast.WS["Evisceration"].SomeAcc = set_combine(sets.precast.WS["Evisceration"], {ear2 = "Odr Earring"})
    sets.precast.WS["Evisceration"].Acc = set_combine(sets.precast.WS["Evisceration"], {head = "Mummu Bonnet +2", hands = "Mummu Wrists +2", legs = "Mummu Kecks +2", feet = "Mummu Gamash. +2"})
    sets.precast.WS["Evisceration"].FullAcc = set_combine(sets.precast.WS["Evisceration"], {head = "Mummu Bonnet +2", body = "Mummu Jacket +2", hands = "Mummu Wrists +2", legs = "Mummu Kecks +2", feet = "Mummu Gamash. +2"})
    sets.precast.WS["Evisceration"].Fodder = set_combine(sets.precast.WS["Evisceration"], {})

    -- Savage Blade - for Naegling
    sets.precast.WS["Savage Blade"] =
        set_combine(
        sets.precast.WS,
        {
            head = "Nyame Helm",
            neck = "Asn. Gorget +2",
            ear1 = "Moonshade Earring",
            ear2 = "Sherida Earring",
            body = "Nyame Mail",
            hands = "Nyame Gauntlets",
            ring1 = "Ilabrat Ring",
            ring2 = "Gere Ring",
            back = gear.wsd_jse_back,
            waist = "Sailfi Belt +1",
            legs = "Nyame Flanchard",
            feet = "Nyame Sollerets"
        }
    )
    sets.precast.WS["Savage Blade"].SomeAcc = set_combine(sets.precast.WS["Savage Blade"], {ear2 = "Odr Earring"})
    sets.precast.WS["Savage Blade"].Acc = set_combine(sets.precast.WS["Savage Blade"], {ear1 = "Odr Earring", ear2 = "Odr Earring"})
    sets.precast.WS["Savage Blade"].FullAcc = set_combine(sets.precast.WS["Savage Blade"], {ear1 = "Odr Earring", ear2 = "Odr Earring"})
    sets.precast.WS["Savage Blade"].Fodder = set_combine(sets.precast.WS["Savage Blade"], {waist = "Sailfi Belt +1"})
    sets.precast.WS["Savage Blade"].DT =
        set_combine(sets.precast.WS["Savage Blade"], {neck = "Loricate Torque +1", ring1 = "Murky Ring", ring2 = "Defending Ring"})
    sets.precast.WS["Savage Blade"].SA =
        set_combine(sets.precast.WS["Savage Blade"].Fodder, {legs = "Pill. Culottes +4"})
    sets.precast.WS["Savage Blade"].TA =
        set_combine(sets.precast.WS["Savage Blade"].Fodder, {legs = "Pill. Culottes +4"})
    sets.precast.WS["Savage Blade"].SATA =
        set_combine(sets.precast.WS["Savage Blade"].Fodder, {legs = "Pill. Culottes +4"})

    -- Proc WS set
    sets.precast.WS.Proc = {
        head = "Pill. Bonnet +4",
        neck = "Voltsurge Torque",
        ear1 = "Heartseeker Earring",
        body = "Pill. Vest +4",
        hands = "Pill. Armlets +4",
        waist = "Chaac Belt",
        legs = "Pill. Culottes +4",
        feet = "Pill. Poulaines +4"
    }

    -- Ranged WS
    sets.precast.WS["Empyreal Arrow"] = {
        ammo = "Jukukik Feather",
        head = "Pill. Bonnet +4",
        neck = "Asn. Gorget +2",
        ear1 = "Moonshade Earring",
        ear2 = "Enervating Earring",
        body = "Pill. Vest +4",
        hands = "Pill. Armlets +4",
        ring1 = "Ilabrat Ring",
        ring2 = "Epona's Ring",
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Pill. Culottes +4",
        feet = "Pill. Poulaines +4"
    }

    -- Magic WS - optimized with available gear
    sets.precast.WS["Aeolian Edge"] = {
        head = "Nyame Helm",
        neck = "Baetyl Pendant",
        ear1 = "Crematio Earring",
        ear2 = "Hecate's Earring",
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Dingir Ring",
        ring2 = "Stikini Ring", -- INT
        back = gear.wsd_jse_back,
        waist = "Sailfi Belt +1", -- WSD still helps
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.precast.WS["Aeolian Edge"].TH = set_combine(sets.precast.WS["Aeolian Edge"], sets.TreasureHunter)

    -- Swap to these on Moonshade using WS if at 3000 TP
    sets.MaxTP = {ear1 = "Ishvara Earring", ear2 = "Sherida Earring"}
    sets.AccMaxTP = {ear1 = "Odr Earring", ear2 = "Sherida Earring"}

    --------------------------------------
    -- Midcast sets
    --------------------------------------

    sets.midcast.FastRecast = {
        head = "Malignance Chapeau",
        neck = "Voltsurge Torque",
        ear1 = "Loquac. Earring",
        ear2 = "Enervating Earring",
        body = "Malignance Tabard",
        hands = "Fanatic Gloves",
        ring1 = "Murky Ring", -- DT-10%, Acc+15, Eva+7 (rank 22)
        ring2 = "Kishar Ring",
        back = "Toutatis's Cape",
        legs = "Rawhide Trousers",
        feet = "Malignance Boots"
    }

    -- Specific spells
    sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {})

    sets.midcast.Dia = set_combine(sets.TreasureHunter, {neck = "Asn. Gorget +2"})
    sets.midcast.Diaga = sets.midcast.Dia
    sets.midcast["Dia II"] = sets.midcast.Dia
    sets.midcast.Bio = sets.midcast.Dia
    sets.midcast["Bio II"] = sets.midcast.Dia

    -- Ranged gear
    sets.midcast.RA = {
        ammo = "Jukukik Feather",
        head = "Pill. Bonnet +4",
        neck = "Asn. Gorget +2",
        ear1 = "Odr Earring",
        ear2 = "Enervating Earring",
        body = "Pill. Vest +4",
        hands = "Pill. Armlets +4",
        ring1 = "Ilabrat Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Pill. Culottes +4",
        feet = "Pill. Poulaines +4"
    }

    sets.midcast.RA.Acc = {
        ammo = "Jukukik Feather",
        head = "Pill. Bonnet +4",
        neck = "Asn. Gorget +2",
        ear1 = "Odr Earring",
        ear2 = "Enervating Earring",
        body = "Pill. Vest +4",
        hands = "Pill. Armlets +4",
        ring1 = "Ilabrat Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = "Chaac Belt",
        legs = "Pill. Culottes +4",
        feet = "Pill. Poulaines +4"
    }

    --------------------------------------
    -- Idle/resting/defense sets
    --------------------------------------

    -- Resting sets
    sets.resting = {}

    -- Idle sets - optimized with your best gear for survivability and regen
    sets.idle = {
        ammo = "Staunch Tathlum +1", -- DT-3%
        head = "Null Masque", -- DT-10%, Regain+2, Regen+3, Haste+10%
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}}, -- DT-6%
        ear1 = "Alabaster Earring", -- HP+100, Haste+5%, DT-5%, Acc+11 (rank 11)
        ear2 = "Etiolation Earring", -- DT-3%
        body = {name = "Gleti's Cuirass", augments = {"Path: A"}}, -- Regain+10, Regen+10
        hands = {name = "Gleti's Gauntlets", augments = {"Path: A"}}, -- Regain, Regen
        ring1 = "Murky Ring", -- DT-10%, Acc+15, Eva+7 (rank 22)
        ring2 = "Chirich Ring +1", -- Regen+2, STP+6
        back = gear.da_jse_back, -- PDT-10%
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Gleti's Breeches", augments = {"Path: A"}}, -- Regain, Regen
        feet = "Skulk. Poulaines +3" 
    } -- 74% PDT and 43% MDT total, excellent Regain/Regen focus

    sets.idle.Sphere = set_combine(sets.idle, {})
    sets.idle.Weak = set_combine(sets.idle, {})

    -- Porter Moogle packing set - equip when near Porter Moogle
    sets.packing = {
        ammo = "Staunch Tathlum +1",
        head = "Null Masque",
        neck = "Sibyl Scarf",
        ear1 = "Etiolation Earring",
        ear2 = "Ethereal Earring",
        body = { name="Nyame Mail", augments={'Path: B',}},
        hands = { name="Nyame Gauntlets", augments={'Path: B',}},
        ring1 = "Murky Ring", -- DT-10%, Acc+15, Eva+7 (rank 22)
        ring2 = "Chirich Ring +1",
        back = gear.da_jse_back,
        waist = "Fucho-no-Obi",
        legs = { name="Nyame Flanchard", augments={'Path: B',}},
        feet = { name="Nyame Sollerets", augments={'Path: B',}}
    }

    sets.DayIdle = {}
    sets.NightIdle = {}
    sets.ExtraRegen = {}

    -- Defense sets - optimized with Nyame for max DT
    sets.defense.PDT = {
        ammo = "Staunch Tathlum +1", -- DT-3%
        head = {name = "Nyame Helm", augments = {"Path: B"}}, -- DT-7%
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}}, -- DT-6%
        ear1 = "Alabaster Earring", -- DT-5%, Acc+11, HP+100, Haste+5%
        ear2 = "Brutal Earring", -- DA+5%, Crit+5%
        body = "Skulker's Vest +3", -- DT-6%, Dagger skill+38, Conspirator
        hands = "Skulk. Armlets +3", -- DT-5%, SA+30
        ring1 = "Murky Ring", -- DT-10%, Acc+15, Eva+7 (rank 22)
        ring2 = "Defending Ring", -- DT-10%
        back = gear.da_jse_back, -- PDT-10%, DA+10%
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}},
        legs = {name = "Nyame Flanchard", augments = {"Path: B"}}, -- DT-8%
        feet = {name = "Nyame Sollerets", augments = {"Path: B"}} -- DT-7%
    } -- 63% DT (capped at 50%) + Dagger skill+38, SA+30, DA+15%, Acc+26

    sets.defense.MDT = {
        head = "Nyame Helm", -- MDT-10%
        neck = "Loricate Torque +1", -- DT-6%
        ear1 = "Etiolation Earring", -- MDT-4%
        ear2 = "Sanare Earring", -- HP recovery
        body = "Nyame Mail", -- MDT-13%
        hands = "Nyame Gauntlets", -- MDT-10%
        ring1 = "Murky Ring", -- DT-10%, Acc+15, Eva+7 (rank 22)
        ring2 = "Chirich Ring +1", -- Regen +2, STP+6
        back = "Toutatis's Cape",
        waist = "Sailfi Belt +1",
        legs = "Nyame Flanchard", -- MDT-12%
        feet = "Nyame Sollerets" -- MDT-10%
    } -- Total: 69% MDT, capped at 50%

    sets.defense.MEVA = {
        head = "Nyame Helm", -- MEVA+123
        neck = "Loricate Torque +1", -- DT-6%
        ear1 = "Etiolation Earring", -- MEVA+10
        ear2 = "Sanare Earring", -- HP recovery
        body = "Nyame Mail", -- MEVA+139
        hands = "Nyame Gauntlets", -- MEVA+112
        ring1 = "Murky Ring", -- DT-10%, Acc+15, Eva+7 (rank 22)
        ring2 = "Chirich Ring +1", -- Regen +2, STP+6
        back = "Toutatis's Cape", -- MEVA+20 with augment
        waist = "Sailfi Belt +1",
        legs = "Nyame Flanchard", -- MEVA+150
        feet = "Nyame Sollerets" -- MEVA+107
    }

    --------------------------------------
    -- Melee sets - optimized for 2100 JP with excellent haste support
    --------------------------------------

    -- Normal melee group - optimized for 2100 JP with excellent haste support
    -- Only need DW+6 with 550 JP gift, weapon combos provide this
    sets.engaged = {
        ammo = {name = "Coiste Bodhar", augments = {"Path: A"}}, -- STP+3, DA+3%
        head = "Skulker's Bonnet +3", -- TA+6%, Phys dmg limit+10%, Acc+61, Atk+61
        neck = "Asn. Gorget +2", -- DEX+25, Accuracy+25, TA+4%
        ear1 = "Sherida Earring", -- DA+5%, DEX+5
        ear2 = "Skulk. Earring +2",
        body = "Pill. Vest +4", -- TA+7%, Crit dmg+6%, Hide+100
        hands = {name = "Adhemar Wrist. +1", augments = {"DEX+12", "AGI+12", "Accuracy+20"}}, -- TA+4% with Path A
        ring1 = "Gere Ring", -- TA+5%, Crit rate+5%
        ring2 = "Epona's Ring", -- DA+5%, TA+3%
        back = gear.da_jse_back, -- DA+10, DT-10%
        waist = "Reiki Yotai", -- DW+7, Acc+10, Atk+10
        legs = {name = "Samnuha Tights", augments = {"STR+8", "DEX+9", '"Dbl.Atk."+3', '"Triple Atk."+2'}}, -- TA+2%, DA+3%
        feet = "Plun. Poulaines +4" -- TA+5%, TA dmg+11
    } -- TA+36%, DA+14%, Crit rate+5%, Crit dmg+6% - Optimized for max multi-attack

    -- Alternative TP set using double Chirich for STP focus
    sets.engaged.STP = {
        ammo = {name = "Coiste Bodhar", augments = {"Path: A"}}, -- STP+3, DA+3%
        head = "Skulker's Bonnet +3", -- TA+6%, Phys dmg limit+10%
        neck = "Asn. Gorget +2", -- DEX+25, Accuracy+25, TA+4%
        ear1 = "Telos Earring", -- DA+1%, STP+5, Acc+10, Atk+10
        ear2 = "Skulk. Earring +2",
        body = "Pill. Vest +4", -- TA+7%, Crit dmg+6%
        hands = {name = "Adhemar Wrist. +1", augments = {"DEX+12", "AGI+12", "Accuracy+20"}}, -- TA+4%
        ring1 = "Chirich Ring +1", -- STP+6, Acc+10, Subtle Blow+10
        ring2 = "Chirich Ring +1", -- STP+6, Acc+10, Subtle Blow+10
        back = gear.da_jse_back, -- DA+10, DT-10%
        waist = "Reiki Yotai", -- DW+7, Acc+10
        legs = {name = "Samnuha Tights", augments = {"STR+8", "DEX+9", '"Dbl.Atk."+3', '"Triple Atk."+2'}}, -- TA+2%, DA+3%
        feet = "Plun. Poulaines +4" -- TA+5%, TA dmg+11
    } -- STP+24 total, TA+28%, DA+17% - Excellent for TP generation with Subtle Blow+20

    sets.engaged.SomeAcc = {
        ammo = {name = "Coiste Bodhar", augments = {"Path: A"}},
        head = "Pill. Bonnet +4", -- Acc+63, WSD+9%, Crit dmg+5%
        neck = "Asn. Gorget +2",
        ear1 = "Sherida Earring", -- DA+5%
        ear2 = "Skulk. Earring +2",
        body = "Pill. Vest +4", -- TA+7%, Acc+70
        hands = "Pill. Armlets +4", -- DW+5, Acc+58, Crit dmg+4%
        ring1 = "Chirich Ring +1", -- STP+6, Acc+10
        ring2 = "Epona's Ring", -- DA+5%, TA+3%
        back = gear.da_jse_back,
        waist = "Reiki Yotai", -- DW+7, Acc+10
        legs = "Pill. Culottes +4", -- TA+5%, Acc+64, Crit dmg+5%
        feet = "Plun. Poulaines +4" -- TA+5%, Acc+41
    } -- Balanced accuracy with good TA - Pillager's +4 set bonus adds more Acc

    -- High accuracy set with double Chirich for challenging content
    sets.engaged.Acc = {
        ammo = {name = "Coiste Bodhar", augments = {"Path: A"}},
        head = "Pill. Bonnet +4", -- Acc+63, WSD+9%, Crit dmg+5%
        neck = "Asn. Gorget +2",
        ear1 = "Telos Earring", -- Acc+10, Atk+10, DA+1%, STP+5
        ear2 = "Skulk. Earring +2",
        body = "Pill. Vest +4", -- TA+7%, Acc+70
        hands = "Pill. Armlets +4", -- DW+5, Acc+58
        ring1 = "Chirich Ring +1", -- STP+6, Acc+10, Subtle Blow+10
        ring2 = "Chirich Ring +1", -- STP+6, Acc+10, Subtle Blow+10
        back = gear.da_jse_back,
        waist = "Reiki Yotai", -- DW+7, Acc+10
        legs = "Pill. Culottes +4", -- TA+5%, Acc+64
        feet = "Pill. Poulaines +4" -- Acc+62
    } -- Total: High accuracy with Pillager's +4 5pc set bonus (+60 Acc), TA+20%, STP+24

    sets.engaged.FullAcc = {
        ammo = {name = "Coiste Bodhar", augments = {"Path: A"}},
        head = "Pill. Bonnet +4", -- Acc+63, WSD+9%
        neck = "Asn. Gorget +2",
        ear1 = "Odr Earring", -- Acc+10, Crit rate+5%
        ear2 = "Skulk. Earring +2",
        body = "Pill. Vest +4", -- Acc+70, TA+7%
        hands = "Pill. Armlets +4", -- Acc+58, DW+5
        ring1 = "Ilabrat Ring", -- DEX+10, Acc+10
        ring2 = "Chirich Ring +1", -- STP+6, Acc+10
        back = gear.da_jse_back, -- Acc+20, DA+10%
        waist = "Reiki Yotai", -- DW+7, Acc+10
        legs = "Pill. Culottes +4", -- Acc+64, TA+5%
        feet = "Pill. Poulaines +4" -- Acc+62
    } -- Maximum accuracy with full Pillager's +4 5pc set bonus (+60 Acc), TA+16%, DA+10%, STP+10

    sets.engaged.Fodder = {
        ammo = {name = "Coiste Bodhar", augments = {"Path: A"}}, -- STP+3, DA+3%
        head = "Skulker's Bonnet +3", -- TA+6%, Phys dmg limit+10%
        neck = "Asn. Gorget +2", -- TA+4%
        ear1 = "Sherida Earring", -- DA+5%
        ear2 = "Brutal Earring", -- DA+5%
        body = "Pill. Vest +4", -- TA+7%, Crit dmg+6%
        hands = {name = "Adhemar Wrist. +1", augments = {"DEX+12", "AGI+12", "Accuracy+20"}}, -- TA+4%
        ring1 = "Gere Ring", -- TA+5%, Crit rate+5%
        ring2 = "Epona's Ring", -- DA+5%, TA+3%
        back = gear.da_jse_back, -- DA+10%
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}}, -- Haste+10%
        legs = {name = "Samnuha Tights", augments = {"STR+8", "DEX+9", '"Dbl.Atk."+3', '"Triple Atk."+2'}}, -- TA+2%, DA+3%
        feet = "Plun. Poulaines +4" -- TA+5%, TA dmg+11
    } -- TA+36%, DA+31%, Phys dmg limit+10% - Maximum offense for easy content

    -- DT melee sets - 50% DT cap with THF benefits
    sets.engaged.DT = {
        ammo = "Staunch Tathlum +1", -- DT-3%
        head = "Skulker's Bonnet +3", -- TA+6%, Physical Damage Limit+10%
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}}, -- DT-6%
        ear1 = "Alabaster Earring", -- DT-5%, Acc+11, HP+100, Haste+5%
        ear2 = "Brutal Earring", -- DA+5%, Crit+5%
        body = "Skulker's Vest +3", -- DT-6%, Dagger skill+38, Conspirator (WSD+12%)
        hands = "Skulk. Armlets +3", -- DT-5%, SA+30, DEX+53
        ring1 = "Murky Ring", -- DT-10%, Acc+15, Eva+7 (rank 22)
        ring2 = "Chirich Ring +1", -- STP+6, Regen+2
        back = gear.da_jse_back, -- PDT-10%, DA+10%, STP+5
        waist = "Reiki Yotai", -- DW+7 (for haste capping)
        legs = "Skulk. Culottes +3", -- DT-7%, Despoil enhancement
        feet = "Skulk. Poulaines +3" -- DT-6%, TH+5
    } -- 55% DT (capped at 50%) + TA+6%, DA+15%, Phys Dmg Limit+10%, STP+11, Acc+26, TH+5

    sets.engaged.STP.DT = {
        ammo = "Staunch Tathlum +1", -- DT-3%
        head = "Skulker's Bonnet +3", -- TA+6%, Physical Damage Limit+10%
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}}, -- DT-6%
        ear1 = "Alabaster Earring", -- DT-5%, Acc+11, HP+100, Haste+5%
        ear2 = "Skulk. Earring +2",
        body = "Skulker's Vest +3", -- DT-6%, Dagger skill+38, Conspirator
        hands = "Skulk. Armlets +3", -- DT-5%, SA+30
        ring1 = "Murky Ring", -- DT-10%, Acc+15, Eva+7 (rank 22)
        ring2 = "Chirich Ring +1", -- STP+6
        back = gear.da_jse_back, -- PDT-10%, DA+10%, STP+5
        waist = "Reiki Yotai", -- DW+7
        legs = "Skulk. Culottes +3", -- DT-7%
        feet = "Skulk. Poulaines +3" -- DT-6%, TH+5
    } -- 55% DT (capped) + STP+19, TA+6%, DA+10%, Phys Dmg Limit+10%, Acc+26

    sets.engaged.SomeAcc.DT = {
        ammo = "Staunch Tathlum +1", -- DT-3%
        head = "Skulker's Bonnet +3", -- TA+6%, Physical Damage Limit+10%
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}}, -- DT-6%
        ear1 = "Alabaster Earring", -- DT-5%, Acc+11, HP+100, Haste+5%
        ear2 = "Skulk. Earring +2",
        body = "Skulker's Vest +3", -- DT-6%, Dagger skill+38
        hands = "Skulk. Armlets +3", -- DT-5%, SA+30
        ring1 = "Murky Ring", -- DT-10%, Acc+15, Eva+7 (rank 22)
        ring2 = "Chirich Ring +1", -- STP+6, Acc+10
        back = gear.da_jse_back, -- PDT-10%, DA+10%, STP+5
        waist = "Reiki Yotai", -- DW+7, Acc+10
        legs = "Skulk. Culottes +3", -- DT-7%
        feet = "Malignance Boots" -- Accuracy focus, some DT
    }

    sets.engaged.Acc.DT = {
        ammo = "Staunch Tathlum +1", -- DT-3%
        head = "Skulker's Bonnet +3", -- TA+6%, Physical Damage Limit+10%
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}}, -- DT-6%
        ear1 = "Alabaster Earring", -- DT-5%, Acc+11, HP+100, Haste+5%
        ear2 = "Skulk. Earring +2",
        body = "Skulker's Vest +3", -- DT-6%, Dagger skill+38
        hands = "Skulk. Armlets +3", -- DT-5%, SA+30
        ring1 = "Murky Ring", -- DT-10%, Acc+15, Eva+7 (rank 22)
        ring2 = "Chirich Ring +1", -- STP+6, Acc+10
        back = gear.da_jse_back, -- PDT-10%, DA+10%, STP+5
        waist = "Reiki Yotai", -- DW+7, Acc+10
        legs = "Skulk. Culottes +3", -- DT-7%
        feet = "Malignance Boots" -- Accuracy focus, some DT
    }

    sets.engaged.FullAcc.DT = {
        ammo = "Staunch Tathlum +1", -- DT-3%
        head = "Skulker's Bonnet +3", -- TA+6%, Physical Damage Limit+10%
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}}, -- DT-6%
        ear1 = "Alabaster Earring", -- DT-5%, Acc+11, HP+100, Haste+5%
        ear2 = "Skulk. Earring +2", -- Acc+16, STP+6, DEX+7 AGI+7 (right ear only, THF only)
        body = "Skulker's Vest +3", -- DT-6%, Dagger skill+38
        hands = "Skulk. Armlets +3", -- DT-5%, SA+30
        ring1 = "Murky Ring", -- DT-10%, Acc+15, Eva+7 (rank 22)
        ring2 = "Chirich Ring +1", -- STP+6, Acc+10
        back = gear.da_jse_back, -- PDT-10%, STP+5
        waist = "Reiki Yotai", -- DW+7, Acc+10
        legs = "Skulk. Culottes +3", -- DT-7%
        feet = "Malignance Boots" -- Maximum accuracy, some DT
    }

    sets.engaged.Fodder.DT = {
        ammo = "Staunch Tathlum +1", -- DT-3%
        head = "Skulker's Bonnet +3", -- TA+6%, Physical Damage Limit+10%
        neck = {name = "Loricate Torque +1", augments = {"Path: A"}}, -- DT-6%
        ear1 = "Alabaster Earring", -- DT-5%, Acc+11, HP+100, Haste+5%
        ear2 = "Brutal Earring", -- DA+5%, Crit+5%
        body = "Skulker's Vest +3", -- DT-6%, Dagger skill+38
        hands = {name = "Floral Gauntlets", augments = {"Rng.Acc.+15", "Accuracy+15", '"Triple Atk."+3', "Magic dmg. taken -4%"}}, -- TA+3%, MDT-4%
        ring1 = "Murky Ring", -- DT-10%, Acc+15, Eva+7 (rank 22)
        ring2 = "Gere Ring", -- TA+5%, Crit rate+5%
        back = gear.da_jse_back, -- PDT-10%, DA+10%, STP+5
        waist = {name = "Sailfi Belt +1", augments = {"Path: A"}}, -- Haste+10%
        legs = "Skulk. Culottes +3", -- DT-7%
        feet = "Skulk. Poulaines +3" -- DT-6%, TH+5
    } -- 57% DT (capped) + TA+14%, DA+15%, Acc+26, maximum offense with DT

    -- Aftermath sets for Vajra - Mythic AM3 further reduces DW needs
    sets.engaged.AM = {
        head = "Skulker's Bonnet +3",
        neck = "Asn. Gorget +2",
        ear1 = "Sherida Earring", -- No DW needed
        ear2 = "Brutal Earring", -- More damage
        body = "Skulker's Vest +3",
        hands = "Floral Gauntlets", -- TA+3, can use since DW needs are lower
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Samnuha Tights",
        feet = "Plun. Poulaines +4"
    }

    sets.engaged.AM.STP = {
        head = "Skulker's Bonnet +3",
        neck = "Asn. Gorget +2",
        ear1 = "Sherida Earring",
        ear2 = "Brutal Earring",
        body = "Skulker's Vest +3",
        hands = "Floral Gauntlets", -- TA+3
        ring1 = "Chirich Ring +1", -- STP+6
        ring2 = "Chirich Ring +1", -- STP+6
        back = gear.da_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Samnuha Tights",
        feet = "Plun. Poulaines +4"
    }

    sets.engaged.AM.SomeAcc = {
        head = "Pill. Bonnet +4",
        neck = "Asn. Gorget +2",
        ear1 = "Sherida Earring",
        ear2 = "Brutal Earring",
        body = "Malignance Tabard", -- More accuracy
        hands = "Floral Gauntlets",
        ring1 = "Gere Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Samnuha Tights",
        feet = "Malignance Boots"
    }

    sets.engaged.AM.Acc = {
        head = "Pill. Bonnet +4",
        neck = "Asn. Gorget +2",
        ear1 = "Sherida Earring", -- Keep one DA earring
        ear2 = "Odr Earring", -- Accuracy
        body = "Pill. Vest +4",
        hands = "Floral Gauntlets",
        ring1 = "Ilabrat Ring",
        ring2 = "Epona's Ring",
        back = gear.da_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Pill. Culottes +4",
        feet = "Pill. Poulaines +4"
    }

    sets.engaged.AM.FullAcc = {
        head = "Pill. Bonnet +4",
        neck = "Asn. Gorget +2",
        ear1 = "Odr Earring",
        ear2 = "Odr Earring",
        body = "Pill. Vest +4",
        hands = "Pill. Armlets +4",
        ring1 = "Ilabrat Ring",
        ring2 = "Epona's Ring", -- Keep some DA
        back = gear.da_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Pill. Culottes +4",
        feet = "Pill. Poulaines +4"
    }
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- THF uses book 6, page 1 for all subjobs
    set_macro_page(1, 6)
end

-- Lockstyle function optimized for different weapon combinations
function user_job_lockstyle()
    if player.equipment.main == nil or player.equipment.main == "empty" then
        windower.chat.input("/lockstyleset 001")
        return
    end
    
    -- Find main weapon skill
    local main_skill = nil
    for id, item in pairs(res.items) do
        if item.english == player.equipment.main then
            main_skill = item.skill
            break
        end
    end
    
    -- Find sub weapon skill (if equipped)
    local sub_skill = nil
    if player.equipment.sub and player.equipment.sub ~= "empty" then
        for id, item in pairs(res.items) do
            if item.english == player.equipment.sub then
                sub_skill = item.skill
                break
            end
        end
    end
    
    -- Dagger in main hand (skill 2) - most common for THF
    if main_skill == 2 then
        if not sub_skill then -- Dagger/Nothing
            windower.chat.input("/lockstyleset 006")
        elseif sub_skill == 2 then -- Dagger/Dagger
            windower.chat.input("/lockstyleset 006")
        else
            windower.chat.input("/lockstyleset 006") -- Catchall
        end
    -- Sword in main hand (skill 3)
    elseif main_skill == 3 then
        if not sub_skill then -- Sword/Nothing
            windower.chat.input("/lockstyleset 006")
        elseif sub_skill == 2 then -- Sword/Dagger
            windower.chat.input("/lockstyleset 006")
        else
            windower.chat.input("/lockstyleset 006") -- Catchall
        end
    else
        -- Default case for other weapon types
        windower.chat.input("/lockstyleset 001")
    end
end

-- Auto-WS table for different weapons
autows_list = {
    ["Prime"] = "Ruthless Stroke",
    ["Twashtar"] = "Rudra's Storm",
    ["Vajra"] = "Mandalic Stab",
    ["Tauret"] = "Evisceration",
    ["Aeneas"] = "Rudra's Storm",
    ["Savage"] = "Savage Blade",
    ["Throwing"] = "Rudra's Storm",
    ["SwordThrowing"] = "Savage Blade",
    ["Evisceration"] = "Evisceration",
    ["ProcWeapons"] = "Wasp Sting",
    ["Bow"] = "Empyreal Arrow"
}

-- Function to customize idle sets based on current modes and conditions
function job_customize_idle_set(idleSet)
    -- Check if near Porter Moogle first
    local currently_near_porter = near_porter_moogle()
    
    if currently_near_porter then
        -- Show message only when entering range
        if not near_porter then
            windower.add_to_chat(160, "Near Porter Moogle - Using packing gear")
            near_porter = true
        end
        return sets.packing
    else
        -- Show message only when leaving range
        if near_porter then
            windower.add_to_chat(160, "Left Porter Moogle area - Returning to normal gear")
            near_porter = false
        end
    end
    
    return idleSet
end

-- Porter Moogle detection function
function near_porter_moogle()
    local mobs = windower.ffxi.get_mob_array()
    for i, mob in pairs(mobs) do
        if mob.name == "Porter Moogle" and mob.distance and mob.distance < 36 then
            return true
        end
    end
    return false
end