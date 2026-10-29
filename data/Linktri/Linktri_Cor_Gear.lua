near_porter = false

-- ======================================================================================================
-- LINKTRI REBUILD 2026-10-29: every set below rebuilt from the Oct 29 COR inventory export (plus Lanun
-- Gants +1, which is owned but missing from the export). The previous version was Selindrile's template
-- and referenced ~80 unowned items (Rostam, Fomalhaut, Ataktos, every Camulus's Mantle, Luzaf's Ring,
-- Comm. Charm +2, Regal gear, Fotia, Laksa. +3, Meghanada, Carmine, Adhemar Jacket, ...). Each changed
-- line keeps its original in a comment.
-- Roles: Phantom Roll support (Compensator + Lanun/Chasseur's), ranged damage (Vanir Gun) and Savage Blade
-- melee (Naegling). Death Penalty is in progress - add it to the weapon sets once it's finished.
-- Snapshot available from gear: Ikenga's Hat 6 + Vest 9 + Clogs 5, Lanun Gants +1 9, Chas. Culottes +3 9,
-- Crepuscular Ring 3 = 41% (cap 70% including Flurry).
-- ======================================================================================================

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_job_setup()
    state.OffenseMode:options("Normal", "Acc")
    state.RangedMode:options("Normal", "Acc")
    state.WeaponskillMode:options("Match", "Normal", "Acc", "Proc")
    state.CastingMode:options("Normal", "Resistant")
    state.IdleMode:options("Normal", "PDT", "Refresh")
    state.HybridMode:options("Normal", "DT")
    state.ExtraMeleeMode = M {["description"] = "Extra Melee Mode", "None", "DWMax"}
    -- LINKTRI: weapon list rebuilt around owned weapons (Naegling, Tauret, Gleti's Knife, Nusku Shield, Vanir Gun).
    -- original: "Default","Ranged","Savage","Evisceration","DualWeapons","DualSavageWeapons","DualEvisceration",
    --           "DualLeadenRanged","DualLeadenMelee","DualAeolian","DualLeadenMeleeAcc","DualRanged","DualProcWeapons","None"
    state.Weapons:options(
        "Savage",
        "DualSavage",
        "Ranged",
        "Leaden",
        "DualLeaden",
        "None"
    )
    state.CompensatorMode:options("Always", "300", "1000", "Never")

    gear.RAbullet = "Eminent Bullet"
    gear.WSbullet = "Eminent Bullet"
    gear.MAbullet = "Eminent Bullet" -- LINKTRI: original: "Orichalc. Bullet" (not owned; no MAB bullet owned)
    gear.QDbullet = "Eminent Bullet" -- LINKTRI: original: "Animikii Bullet" (not owned). Quick Draw uses up one of these.
    options.ammo_warning_limit = 15
    --Ikenga_vest_bonus = 190  -- It is 190 at R20. Uncomment if you need to manually adjust because you are using below R20

    -- LINKTRI: no Camulus's Mantle is owned. Every cape variable points at Null Shawl (Acc/R.Acc/M.Acc+50,
    -- DA+7%, Store TP+7) so the sets still equip a back piece. Swap each one back when you make the capes.
    -- original: gear.tp_ranger_jse_back = {name = "Camulus's Mantle", augments = {"AGI+20", "Rng.Acc.+20 Rng.Atk.+20", "Rng.Acc.+10", '"Store TP"+10'}}
    -- original: gear.snapshot_jse_back = {name = "Camulus's Mantle", augments = {'"Snapshot"+10'}}
    -- original: gear.tp_jse_back = {name = "Camulus's Mantle", augments = {"DEX+20", "Accuracy+20 Attack+20", "Accuracy+10", '"Store TP"+10'}}
    -- original: gear.ranger_wsd_jse_back = {name = "Camulus's Mantle", augments = {"AGI+20", "Rng.Acc.+20 Rng.Atk.+20", "AGI+10", "Weapon skill damage +10%"}}
    -- original: gear.magic_wsd_jse_back = {name = "Camulus's Mantle", augments = {"AGI+20", "Mag. Acc+20 /Mag. Dmg.+20", "AGI+10", "Weapon skill damage +10%"}}
    -- original: gear.str_wsd_jse_back = {name = "Camulus's Mantle", augments = {"STR+20", "Accuracy+20 Attack+20", "STR+10", "Weapon skill damage +10%"}}
    gear.tp_ranger_jse_back = "Null Shawl"
    gear.snapshot_jse_back = "Null Shawl"
    gear.tp_jse_back = "Null Shawl"
    gear.ranger_wsd_jse_back = "Null Shawl"
    gear.magic_wsd_jse_back = "Null Shawl"
    gear.str_wsd_jse_back = "Null Shawl"

    -- LINKTRI: the two owned Herculean Gloves, by augment.
    gear.herculean_cor_nuke_hands = {name = "Herculean Gloves", augments = {'Magic Damage +16', 'Crit.hit rate+1', 'Accuracy+18 Attack+18', 'Mag. Acc.+19 "Mag.Atk.Bns."+19'}}

    -- Additional local binds
    send_command("bind ^` gs c cycle ElementalMode")
    send_command("bind !` gs c elemental quickdraw")

    send_command('bind ^backspace input /ja "Double-up" <me>')
    send_command('bind @backspace input /ja "Snake Eye" <me>')
    send_command('bind !backspace input /ja "Fold" <me>')
    send_command('bind ^@!backspace input /ja "Crooked Cards" <me>')

    send_command('bind ^\\\\ input /ja "Random Deal" <me>')
    send_command('bind !\\\\ input /ja "Bolter\'s Roll" <me>')
    send_command("bind ^@!\\\\ gs c toggle LuzafRing")
    send_command("bind @f7 gs c toggle RngHelper")

    -- LINKTRI: weapon keybinds point at the rebuilt weapon sets.
    send_command("bind !r gs c weapons DualSavage;gs c update")  -- original: DualSavageWeapons
    send_command("bind ^q gs c weapons DualLeaden;gs c update")  -- original: DualAeolian (same weapons as DualLeaden now)
    send_command("bind !q gs c weapons Leaden;gs c update")      -- original: DualLeadenRanged
    send_command("bind @pause roller roll")

    select_default_macro_book()
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Precast Sets

    -- Precast sets to enhance JAs

    sets.precast.JA["Triple Shot"] = {body = "Chasseur's Frac +3"}
    sets.precast.JA["Snake Eye"] = {legs = "Lanun Trews +1"}
    sets.precast.JA["Wild Card"] = {feet = "Lanun Bottes +1"} -- LINKTRI: original: "Lanun Bottes +3" (not owned); +1 enhances Wild Card
    sets.precast.JA["Random Deal"] = {body = "Lanun Frac +1"} -- LINKTRI: original: "Lanun Frac +3" (not owned)
    sets.precast.FoldDoubleBust = {hands = "Lanun Gants +1"}

    -- LINKTRI: Phantom Roll. No main-hand swap (Rostam isn't owned, and a main swap would wipe your TP);
    -- Compensator goes on through CompensatorMode. Barataria Ring = Phantom Roll+5.
    sets.precast.CorsairRoll = {
        -- original: main = "Rostam" (not owned)
        range = "Compensator",
        head = "Lanun Tricorne +1",
        neck = "Loricate Torque +1",     -- original: "Regal Necklace" (not owned); DT-6%
        ear1 = "Alabaster Earring",      -- original: "Etiolation Earring"; DT-5%
        ear2 = "Etiolation Earring",     -- original: "Sanare Earring"; MDT-3%
        body = "Chasseur's Frac +3",     -- original: "Lanun Frac +3" (not owned); DT-13%, enhances Tactician's Roll
        hands = "Chasseur's Gants +3",
        ring1 = "Barataria Ring",        -- original: "Defending Ring"; Phantom Roll+5 (ring1 so Luzaf's Ring can take ring2)
        ring2 = "Murky Ring",            -- original: "Dark Ring" (not owned); DT-10%. COR.lua swaps Luzaf's Ring in here when owned
        back = gear.tp_jse_back,
        waist = "Null Belt",             -- original: "Flume Belt +1" (not owned)
        legs = "Desultor Tassets",       -- "Phantom Roll" ability delay -5
        feet = "Nyame Sollerets"         -- original: "Malignance Boots"; DT-7%
    }

    sets.precast.LuzafRing = {ring2 = "Luzaf's Ring"} -- COR.lua equips it on rolls/Double-Up when it's in your inventory

    sets.precast.CorsairRoll["Caster's Roll"] = set_combine(sets.precast.CorsairRoll, {legs = "Chas. Culottes +3"})
    sets.precast.CorsairRoll["Courser's Roll"] = set_combine(sets.precast.CorsairRoll, {feet = "Chass. Bottes +3"}) -- original: "Chass. Bottes +2"
    sets.precast.CorsairRoll["Blitzer's Roll"] = set_combine(sets.precast.CorsairRoll, {head = "Chass. Tricorne +3"})
    sets.precast.CorsairRoll["Tactician's Roll"] = set_combine(sets.precast.CorsairRoll, {body = "Chasseur's Frac +3"})
    sets.precast.CorsairRoll["Allies' Roll"] = set_combine(sets.precast.CorsairRoll, {hands = "Chasseur's Gants +3"})

    -- LINKTRI: Quick Draw damage. Nyame (MAB+30 each), Chass. Bottes +3 (MAB+50, Quick Draw+31).
    sets.precast.CorsairShot = {
        ammo = gear.QDbullet,
        head = "Nyame Helm",             -- original: gear.herculean_nuke_head (not owned)
        neck = "Baetyl Pendant",         -- original: "Iskur Gorget" (not owned); MAB+13
        ear1 = "Crematio Earring",       -- original: "Dedition Earring"; MAB+6, Magic Damage+6
        ear2 = "Hecate's Earring",       -- original: "Telos Earring"; MAB+6
        body = "Nyame Mail",             -- original: "Mummu Jacket +2"
        hands = "Nyame Gauntlets",       -- original: "Adhemar Wristbands +1"
        ring1 = "Crepuscular Ring",
        ring2 = "Dingir Ring",
        back = gear.tp_ranger_jse_back,
        waist = "Orpheus's Sash",        -- original: "Goading Belt" (not owned)
        legs = "Nyame Flanchard",        -- original: "Chas. Culottes +3"
        feet = "Chass. Bottes +3"        -- original: "Carmine Greaves +1" (not owned)
    }

    sets.precast.CorsairShot.Damage = set_combine(sets.precast.CorsairShot, {})
    -- original: Sanctity Necklace, Friomisi Earring, Samnuha Coat, Leyline Gloves, Shiva Ring +1, Eschan Stone,
    --           Chass. Bottes +2 - most not owned; now the same as the base Quick Draw set

    -- Treasure Hunter procs on a Quick Draw (WeaponskillMode/CastingMode "Proc"): DT gear plus TH pieces.
    sets.precast.CorsairShot.Proc = {
        ammo = gear.RAbullet,
        head = "Nyame Helm",             -- original: "Wh. Rarab Cap +1" (stored)
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",      -- original: "Genmei Earring"
        ear2 = "Etiolation Earring",     -- original: "Sanare Earring"
        body = "Nyame Mail",             -- original: "Emet Harness +1" (not owned)
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",            -- original: "Dark Ring" (not owned)
        back = gear.tp_jse_back,         -- original: "Moonlight Cape" (not owned)
        waist = "Chaac Belt",            -- original: "Flume Belt +1" (not owned); Treasure Hunter+1
        legs = "Volte Hose",             -- original: "Carmine Cuisses +1" (not owned); Treasure Hunter+1
        feet = "Nyame Sollerets"         -- original: "Chass. Bottes +2"
    }

    -- Light/Dark Shot land on magic accuracy: the full Chasseur's +3 set (Mag. Acc.+60~64 each, set bonus).
    sets.precast.CorsairShot["Light Shot"] = {
        ammo = gear.QDbullet,
        head = "Chass. Tricorne +3",     -- original: "Carmine Mask +1" (not owned)
        neck = "Null Loop",              -- original: "Sanctity Necklace" (not owned); M.Acc+50
        ear1 = "Crep. Earring",          -- original: "Digni. Earring" (not owned)
        ear2 = "Chas. Earring +2",       -- original: "Telos Earring"; Sortie earring (ear2 only): M.Acc+19
        body = "Chasseur's Frac +3",     -- original: "Mummu Jacket +2"
        hands = "Chasseur's Gants +3",   -- original: "Leyline Gloves" (not owned)
        ring1 = "Crepuscular Ring",      -- original: "Metamor. Ring +1"; M.Acc+10
        ring2 = "Stikini Ring",          -- original: "Stikini Ring +1" (you own the NQ)
        back = gear.ranger_wsd_jse_back,
        waist = "Null Belt",             -- original: "Eschan Stone"; M.Acc+30
        legs = "Chas. Culottes +3",      -- original: "Malignance Tights"
        feet = "Chass. Bottes +3"        -- original: "Mummu Gamash. +2"
    }

    sets.precast.CorsairShot["Dark Shot"] = set_combine(sets.precast.CorsairShot["Light Shot"], {}) -- original: feet = "Chass. Bottes +2"

    -- Waltz set (Waltz potency: Herculean Vest +8%, Herculean Gloves +9%, Dashing Subligar +10%)
    sets.precast.Waltz = {
        head = "Nyame Helm",             -- original: "Carmine Mask +1" (not owned)
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",      -- original: "Etiolation Earring"
        ear2 = "Odnowa Earring +1",      -- original: "Sanare Earring"
        body = gear.herculean_waltz_body,
        hands = gear.herculean_waltz_hands,
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",            -- original: "Valseur's Ring" (not owned)
        back = gear.tp_jse_back,         -- original: "Moonlight Cape" (not owned)
        waist = "Null Belt",             -- original: "Flume Belt +1" (not owned)
        legs = "Dashing Subligar",
        feet = "Nyame Sollerets"         -- original: gear.herculean_waltz_feet (not owned)
    }

    sets.Self_Waltz = {head = "Mummu Bonnet +2"} -- original: + body = "Passion Jacket", ring1 = "Asklepian Ring" (not owned)

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz["Healing Waltz"] = {}

    -- Fast cast sets for spells (Baetyl 4, Etiolation 1, Dread Jupon 7, Sombra Mittens 3, Kishar 4, Rawhide Trousers 5)
    sets.precast.FC = {
        head = "Nyame Helm",             -- original: "Carmine Mask +1" (not owned)
        neck = "Baetyl Pendant",
        ear1 = "Alabaster Earring",      -- original: "Enchntr. Earring +1" (not owned)
        ear2 = "Etiolation Earring",     -- original: "Loquac. Earring" (not owned)
        body = "Dread Jupon",
        hands = "Sombra Mittens",        -- original: "Leyline Gloves" (not owned)
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",
        back = gear.tp_jse_back,         -- original: "Moonlight Cape" (not owned)
        waist = "Null Belt",             -- original: "Flume Belt +1" (not owned)
        legs = "Rawhide Trousers",
        feet = "Nyame Sollerets"         -- original: "Carmine Greaves +1" (not owned)
    }

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck = "Magoraga Beads"}) -- original: + body = "Passion Jacket" (not owned)

    sets.precast.FC.Cure = set_combine(sets.precast.FC, {}) -- original: ear2 = "Mendi. Earring" (not owned)

    -- LINKTRI: Snapshot when you fire. 41% from gear (see the header); Flurry II adds 30%, so it trades
    -- Ikenga's Hat (Snapshot+6) for Chass. Tricorne +3 (Rapid Shot+18) and still sits at ~65%.
    sets.precast.RA = {
        ammo = gear.RAbullet,
        head = "Ikenga's Hat",           -- original: "Chass. Tricorne +3"; Snapshot+6
        neck = "Null Loop",              -- original: "Comm. Charm +2" (not owned)
        body = "Ikenga's Vest",          -- original: "Laksa. Frac +3" (not owned); Snapshot+9
        hands = "Lanun Gants +1",        -- original: "Carmine Fin. Ga. +1" (not owned); Snapshot+9
        ring1 = "Crepuscular Ring",      -- Snapshot+3
        back = gear.snapshot_jse_back,
        waist = "Null Belt",             -- original: "Impulse Belt" (not owned)
        legs = "Chas. Culottes +3",      -- original: "Laksa. Trews +3" (not owned); Snapshot+9
        feet = "Ikenga's Clogs"          -- original: "Meg. Jam. +2" (not owned); Snapshot+5
    }

    sets.precast.RA.Flurry = set_combine(sets.precast.RA, {}) -- original: waist = "Yemaya Belt", legs = "Adhemar Kecks +1" (not owned)
    sets.precast.RA.Flurry2 = set_combine(sets.precast.RA, {head = "Chass. Tricorne +3"}) -- original: waist = "Yemaya Belt", legs = "Adhemar Kecks +1" (not owned)

    -- Weaponskill sets
    -- LINKTRI: physical WS core = Nyame (R25 Path B) + Chasseur's Gants +3 (WSD+12%) + Ephramad's Ring (PDL+10%).
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        ammo = gear.WSbullet,
        head = "Nyame Helm",             -- original: "Meghanada Visor +2" (not owned)
        neck = "Null Loop",              -- original: "Fotia Gorget" (not owned)
        ear1 = "Moonshade Earring",
        ear2 = "Chas. Earring +2",       -- original: "Telos Earring"; Sortie earring (ear2 only): STR/AGI+13, Acc+19
        body = "Nyame Mail",             -- original: "Laksa. Frac +3" (not owned)
        hands = "Chasseur's Gants +3",   -- original: "Meg. Gloves +2" (not owned); WSD+12%
        ring1 = "Ephramad's Ring",       -- original: "Regal Ring" (not owned)
        ring2 = "Ilabrat Ring",          -- original: "Ifrit Ring +1" (not owned)
        back = gear.str_wsd_jse_back,
        waist = "Sailfi Belt +1",        -- original: "Fotia Belt" (not owned)
        legs = "Nyame Flanchard",        -- original: "Meg. Chausses +2" (not owned)
        feet = "Nyame Sollerets"         -- original: "Lanun Bottes +3" (not owned)
    }

    sets.precast.WS.Acc = set_combine(sets.precast.WS, {ring2 = "Chirich Ring +1", waist = "Null Belt"})
    -- original WS.Acc: Carmine Mask +1, Combatant's Torque, Digni. Earring, Telos, Meg. Cuirie +2, Meg. Gloves +2,
    --                  Regal Ring, Ilabrat Ring, Grunfeld Rope, Carmine Cuisses +1, Lanun Bottes +3

    sets.precast.WS.Proc = set_combine(sets.precast.CorsairShot.Proc, {ammo = gear.WSbullet})
    -- original WS.Proc: Carmine Mask +1, Combatant's Torque, Digni. Earring, Mache +1, Mummu Jacket +2, Floral Gauntlets,
    --                   Ramuh Ring +1 x2, Olseni Belt, Carmine Cuisses +1, Malignance Boots

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.

    sets.precast.WS["Requiescat"] = set_combine(sets.precast.WS, {ring1 = "Metamor. Ring +1"})
    -- original: head = "Carmine Mask +1", ring2 = "Rufescent Ring", legs = "Carmine Cuisses +1", feet = "Carmine Greaves +1" (not owned)

    sets.precast.WS["Evisceration"] = {
        ammo = gear.WSbullet,
        head = "Mummu Bonnet +2",
        neck = "Null Loop",              -- original: "Fotia Gorget" (not owned)
        ear1 = "Moonshade Earring",      -- original: "Odr Earring" (Moonshade moved to ear1 to match every other set)
        ear2 = "Chas. Earring +2",       -- original: "Moonshade Earring"; Crit+7
        body = "Mummu Jacket +2",
        hands = "Mummu Wrists +2",
        ring1 = "Ephramad's Ring",       -- original: "Mummu Ring" (not owned)
        ring2 = "Ilabrat Ring",          -- original: "Begrudging Ring" (not owned)
        back = gear.tp_jse_back,
        waist = "Shadow Belt",           -- original: "Fotia Belt" (not owned); Gravitation latent
        legs = "Mummu Kecks +2",
        feet = "Mummu Gamash. +2"
    }

    sets.precast.WS["Evisceration"].Acc = set_combine(sets.precast.WS["Evisceration"], {ring2 = "Chirich Ring +1"})
    -- original: same pieces with Regal Ring (not owned)

    sets.precast.WS["Savage Blade"] = {
        ammo = gear.WSbullet,
        head = "Nyame Helm",             -- original: "Lilitu Headpiece"
        neck = "Null Loop",              -- original: "Comm. Charm +2" (not owned)
        ear1 = "Moonshade Earring",
        ear2 = "Chas. Earring +2",       -- original: "Ishvara Earring"; STR+13
        body = "Nyame Mail",             -- original: "Laksa. Frac +3" (not owned)
        hands = "Chasseur's Gants +3",   -- original: "Meg. Gloves +2" (not owned); WSD+12%
        ring1 = "Ephramad's Ring",       -- original: "Regal Ring" (not owned); STR+10, PDL+10%
        ring2 = "Ilabrat Ring",          -- original: "Rufescent Ring" (not owned)
        back = gear.str_wsd_jse_back,
        waist = "Sailfi Belt +1",
        legs = "Nyame Flanchard",        -- original: gear.herculean_wsd_legs (not owned)
        feet = "Nyame Sollerets"         -- original: "Lanun Bottes +3" (not owned)
    }

    sets.precast.WS["Savage Blade"].Acc = set_combine(sets.precast.WS["Savage Blade"], {ring2 = "Chirich Ring +1", waist = "Null Belt"})
    -- original: Carmine Mask +1, Combatant's Torque, Telos, Meg. Cuirie/Gloves +2, Regal/Rufescent, Grunfeld Rope,
    --           Carmine Cuisses +1, Lanun Bottes +3

    sets.precast.WS["Last Stand"] = {
        ammo = gear.WSbullet,
        head = "Nyame Helm",             -- original: "Meghanada Visor +2" (not owned)
        neck = "Light Gorget",           -- original: "Fotia Gorget" (not owned); Fusion latent
        ear1 = "Moonshade Earring",
        ear2 = "Chas. Earring +2",       -- original: "Telos Earring"; AGI+13
        body = "Nyame Mail",             -- original: "Laksa. Frac +3" (not owned)
        hands = "Chasseur's Gants +3",   -- original: "Meg. Gloves +2" (not owned); WSD+12%
        ring1 = "Ephramad's Ring",       -- original: "Regal Ring" (not owned); AGI+10, R.Acc/R.Atk+20, PDL+10%
        ring2 = "Dingir Ring",
        back = gear.ranger_wsd_jse_back,
        waist = "Light Belt",            -- original: "Fotia Belt" (not owned); Fusion latent
        legs = "Nyame Flanchard",        -- original: "Meg. Chausses +2" (not owned)
        feet = "Nyame Sollerets"         -- original: "Lanun Bottes +3" (not owned)
    }

    sets.precast.WS["Last Stand"].Acc = set_combine(sets.precast.WS["Last Stand"], {neck = "Null Loop", waist = "Null Belt"})
    -- original: neck = "Iskur Gorget" (not owned), otherwise the Last Stand set

    sets.precast.WS["Detonator"] = sets.precast.WS["Last Stand"]
    sets.precast.WS["Detonator"].Acc = sets.precast.WS["Last Stand"].Acc
    sets.precast.WS["Slug Shot"] = sets.precast.WS["Last Stand"]
    sets.precast.WS["Slug Shot"].Acc = sets.precast.WS["Last Stand"].Acc
    sets.precast.WS["Numbing Shot"] = sets.precast.WS["Last Stand"]
    sets.precast.WS["Numbing Shot"].Acc = sets.precast.WS["Last Stand"].Acc
    sets.precast.WS["Sniper Shot"] = sets.precast.WS["Last Stand"]
    sets.precast.WS["Sniper Shot"].Acc = sets.precast.WS["Last Stand"].Acc
    sets.precast.WS["Split Shot"] = sets.precast.WS["Last Stand"]
    sets.precast.WS["Split Shot"].Acc = sets.precast.WS["Last Stand"].Acc

    -- Magical WS: Nyame (MAB+30 each), Chass. Bottes +3 (MAB+50), Orpheus's Sash.
    sets.precast.WS["Leaden Salute"] = {
        ammo = gear.MAbullet,
        head = "Pixie Hairpin +1",
        neck = "Baetyl Pendant",         -- original: "Comm. Charm +2" (not owned); MAB+13
        ear1 = "Moonshade Earring",
        ear2 = "Chas. Earring +2",       -- original: "Friomisi Earring" (not owned); AGI+13, M.Acc+19
        body = "Nyame Mail",             -- original: "Laksa. Frac +3" (not owned)
        hands = "Nyame Gauntlets",       -- original: "Carmine Fin. Ga. +1" (not owned)
        ring1 = "Ephramad's Ring",       -- original: "Archon Ring" (not owned); AGI+10
        ring2 = "Dingir Ring",
        back = gear.magic_wsd_jse_back,
        waist = "Orpheus's Sash",        -- original: "Eschan Stone"
        legs = "Nyame Flanchard",
        feet = "Chass. Bottes +3"        -- original: "Lanun Bottes +3" (not owned); MAB+50
    }

    sets.precast.WS["Leaden Salute"].Acc = set_combine(sets.precast.WS["Leaden Salute"], {head = "Nyame Helm", ring1 = "Crepuscular Ring"})
    -- original: same as the original Leaden Salute set

    sets.precast.WS["Aeolian Edge"] = {
        head = "Nyame Helm",             -- original: gear.herculean_nuke_head (not owned)
        neck = "Baetyl Pendant",
        ear1 = "Moonshade Earring",
        ear2 = "Hecate's Earring",       -- original: "Friomisi Earring" (not owned)
        body = "Nyame Mail",             -- original: "Laksa. Frac +3" (not owned)
        hands = "Nyame Gauntlets",       -- original: "Carmine Fin. Ga. +1" (not owned)
        ring1 = "Metamor. Ring +1",
        ring2 = "Dingir Ring",
        back = gear.magic_wsd_jse_back,
        waist = "Orpheus's Sash",        -- original: "Eschan Stone"
        legs = "Nyame Flanchard",
        feet = "Chass. Bottes +3"        -- original: "Lanun Bottes +3" (not owned)
        -- original: ammo = "Animikii Bullet" (not owned; a dagger WS doesn't need a bullet)
    }

    sets.precast.WS["Wildfire"] = {
        ammo = gear.MAbullet,
        head = "Nyame Helm",             -- original: gear.herculean_nuke_head (not owned)
        neck = "Baetyl Pendant",         -- original: "Comm. Charm +2" (not owned)
        ear1 = "Crematio Earring",
        ear2 = "Hecate's Earring",       -- original: "Friomisi Earring" (not owned)
        body = "Nyame Mail",             -- original: "Laksa. Frac +3" (not owned)
        hands = "Nyame Gauntlets",       -- original: "Carmine Fin. Ga. +1" (not owned)
        ring1 = "Ephramad's Ring",       -- original: "Regal Ring" (not owned); AGI+10
        ring2 = "Dingir Ring",
        back = gear.magic_wsd_jse_back,
        waist = "Orpheus's Sash",        -- original: "Eschan Stone"
        legs = "Nyame Flanchard",
        feet = "Chass. Bottes +3"        -- original: "Lanun Bottes +3" (not owned)
    }

    sets.precast.WS["Wildfire"].Acc = set_combine(sets.precast.WS["Wildfire"], {ring1 = "Crepuscular Ring"})
    -- original: hands = "Leyline Gloves" (not owned), otherwise the original Wildfire set

    sets.precast.WS["Hot Shot"] = sets.precast.WS["Wildfire"]
    sets.precast.WS["Hot Shot"].Acc = sets.precast.WS["Wildfire"].Acc

    --Because omen skillchains.
    sets.precast.WS["Burning Blade"] = {
        ammo = gear.RAbullet,
        head = "Nyame Helm",             -- original: "Meghanada Visor +2" (not owned)
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",      -- original: "Genmei Earring"
        ear2 = "Etiolation Earring",     -- original: "Sanare Earring"
        body = "Nyame Mail",             -- original: "Meg. Cuirie +2" (not owned)
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",            -- original: "Dark Ring" (not owned)
        back = gear.tp_jse_back,         -- original: "Moonlight Cape" (not owned)
        waist = "Null Belt",             -- original: "Flume Belt +1" (not owned)
        legs = "Nyame Flanchard",        -- original: "Meg. Chausses +2" (not owned)
        feet = "Nyame Sollerets"         -- original: "Meg. Jam. +2" (not owned)
    }

    -- Swap to these on Moonshade using WS if at 3000 TP (Moonshade is always in ear1)
    sets.MaxTP = {ear1 = "Ishvara Earring"}              -- original: {}
    sets.AccMaxTP = {ear1 = "Crep. Earring"}             -- original: {}
    sets.MagicalMaxTP = {ear1 = "Crematio Earring"}      -- LINKTRI: COR.lua uses these for magical WS
    sets.MagicalAccMaxTP = {ear1 = "Crematio Earring"}
    sets.RangedMaxTP = {ear1 = "Ishvara Earring"}        -- LINKTRI: COR.lua uses these for ranged WS
    sets.RangedAccMaxTP = {ear1 = "Crep. Earring"}

    -- Midcast Sets
    sets.midcast.FastRecast = set_combine(sets.precast.FC, {})
    -- original: Carmine Mask +1, Enchntr. Earring +1, Loquac. Earring, Leyline Gloves, Moonlight Cape, Flume Belt +1,
    --           Carmine Greaves +1 (not owned); otherwise the FC pieces

    -- Specific spells

    sets.midcast.Cure = set_combine(sets.precast.FC, {ring2 = "Menelaus's Ring"}) -- Cure potency+5%
    -- original: Carmine Mask +1, Phalaina Locket, Enchntr. +1, Mendi., Leyline Gloves, Janniston Ring, Solemnity Cape,
    --           Flume Belt +1, Carmine Cuisses/Greaves +1 (not owned)

    -- LINKTRI: no cure-received / refresh-received gear owned for COR.
    -- original: Self_Healing / Cure_Received = Phalaina Locket, Buremte Gloves, Kunaji Ring, Gishdubar Sash; Self_Refresh = Gishdubar Sash
    sets.Self_Healing = {}
    sets.Cure_Received = {}
    sets.Self_Refresh = {}

    sets.midcast.Utsusemi = sets.midcast.FastRecast

    -- Ranged gear: Ikenga's (R.Acc/R.Atk+40, Store TP, PDL) + Chas. Culottes +3 (R.Acc/R.Atk+63, Store TP+12, DT-12%).
    sets.midcast.RA = {
        ammo = gear.RAbullet,
        head = "Ikenga's Hat",           -- original: "Malignance Chapeau"
        neck = "Null Loop",              -- original: "Iskur Gorget" (not owned); R.Acc+50
        ear1 = "Crep. Earring",          -- original: "Enervating Earring"; R.Acc+10, Store TP+5
        ear2 = "Telos Earring",
        body = "Ikenga's Vest",          -- original: "Malignance Tabard"
        hands = "Ikenga's Gloves",       -- original: "Malignance Gloves"
        ring1 = "Crepuscular Ring",
        ring2 = "Dingir Ring",           -- original: "Ilabrat Ring"; AGI+10, R.Atk+25
        back = gear.tp_ranger_jse_back,
        waist = "Eschan Stone",          -- original: "Yemaya Belt" (not owned)
        legs = "Chas. Culottes +3",      -- original: "Malignance Tights"
        feet = "Ikenga's Clogs"          -- original: "Malignance Boots"
    }

    sets.midcast.RA.Acc = set_combine(sets.midcast.RA, {
        head = "Chass. Tricorne +3",     -- R.Acc+61
        body = "Chasseur's Frac +3",     -- R.Acc+64
        hands = "Chasseur's Gants +3",   -- R.Acc+62
        ring1 = "Cacoethic Ring +1",     -- R.Acc+16
        waist = "Null Belt",             -- R.Acc+30
        feet = "Chass. Bottes +3"        -- R.Acc+60
    })
    -- original RA.Acc: Malignance Chapeau, Iskur Gorget, Enervating, Telos, Laksa. Frac +3, Malignance Gloves, Regal Ring,
    --                  Ilabrat Ring, Yemaya Belt, Laksa. Trews +3, Malignance Boots

    sets.buff["Triple Shot"] = {body = "Chasseur's Frac +3"} -- Triple Shot+14%

    -- Sets to return to when not performing an action.

    sets.DayIdle = {}
    sets.NightIdle = {}

    sets.buff.Doom = set_combine(sets.buff.Doom, {})

    -- Resting sets
    sets.resting = {}
    -- sets.BulletPouch = {waist = "Chr. Bul. Pouch"} -- LINKTRI: not owned

    -- Idle sets
    sets.idle = {
        ammo = gear.RAbullet,
        head = "Null Masque",            -- original: "Nyame Helm"; DT-10%, Regen+3, Refresh+1
        neck = "Bathy Choker +1",        -- original: "Loricate Torque +1"; Regen+3
        ear1 = "Alabaster Earring",      -- original: "Genmei Earring"; DT-5%
        ear2 = "Odnowa Earring +1",      -- original: "Sanare Earring"
        body = "Adamantite Armor",       -- original: "Nyame Mail"; DT-20%
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Chirich Ring +1",       -- original: "Shadow Ring" (not owned); Regen+2
        back = gear.tp_jse_back,         -- original: "Moonlight Cape" (not owned)
        waist = "Null Belt",             -- original: "Carrier's Sash"; Regen+3
        legs = "Nyame Flanchard",        -- original: "Carmine Cuisses +1" (not owned)
        feet = "Nyame Sollerets"
    }

    sets.idle.PDT = {
        ammo = gear.RAbullet,
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",      -- original: "Etiolation Earring"
        ear2 = "Etiolation Earring",     -- original: "Sanare Earring"
        body = "Adamantite Armor",       -- original: "Nyame Mail"
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",            -- original: "Dark Ring" (not owned)
        back = gear.tp_jse_back,         -- original: "Shadow Mantle" (not owned)
        waist = "Null Belt",             -- original: "Flume Belt +1" (not owned)
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"         -- original: "Malignance Boots"
    }

    sets.idle.Refresh = set_combine(sets.idle, {legs = "Rawhide Trousers"}) -- Refresh+1 (plus Null Masque Refresh+1)
    -- original: Rawhide Mask, Genmei, Ethereal Earring, Mekosu. Harness, Herculean refresh hands, Dark Ring,
    --           Moonlight Cape, Flume Belt +1, Rawhide Trousers, Malignance Boots (several not owned)

    -- Defense sets
    sets.defense.PDT = {
        ammo = gear.RAbullet,
        head = "Nyame Helm",
        neck = "Loricate Torque +1",
        ear1 = "Alabaster Earring",      -- original: "Genmei Earring"
        ear2 = "Odnowa Earring +1",      -- original: "Tuisto Earring"
        body = "Adamantite Armor",       -- original: "Nyame Mail"; DT-20%
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",            -- original: "Warden's Ring"
        back = gear.tp_jse_back,         -- original: "Shadow Mantle" (not owned)
        waist = "Null Belt",             -- original: "Flume Belt +1" (not owned)
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.defense.MDT = set_combine(sets.defense.PDT, {ear2 = "Etiolation Earring"})
    -- original: Warder's Charm +1, Etiolation, Sanare, Shadow Ring, Moonlight Cape, Carrier's Sash (several not owned)

    sets.defense.MEVA = {
        ammo = gear.RAbullet,
        head = "Nyame Helm",
        neck = "Null Loop",              -- original: "Warder's Charm +1" (not owned)
        ear1 = "Alabaster Earring",      -- original: "Etiolation Earring"
        ear2 = "Etiolation Earring",     -- original: "Sanare Earring"
        body = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",            -- original: "Shadow Ring" (not owned)
        back = gear.tp_jse_back,         -- original: "Moonlight Cape" (not owned); M.Eva+50
        waist = "Null Belt",             -- original: "Carrier's Sash"; M.Eva+30
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets"
    }

    sets.Kiting = {ring2 = "Shneddick Ring +1"} -- original: legs = "Carmine Cuisses +1" (not owned)
    sets.TreasureHunter = {waist = "Chaac Belt", legs = "Volte Hose"} -- original: set_combine(sets.TreasureHunter, {}) (global set uses stored Wh. Rarab Cap +1)
    sets.DWMax = {
        ear1 = "Dudgeon Earring",
        ear2 = "Heartseeker Earring",
        body = "Samnuha Coat",           -- original: "Adhemar Jacket +1" (not owned); Dual Wield+2
        hands = "Floral Gauntlets",
        waist = "Reiki Yotai",
        legs = "Sombra Tights"           -- LINKTRI: Dual Wield+3
    }

    -- Weapons sets
    -- LINKTRI: rebuilt around owned weapons. Naegling and Tauret ride in PorterPacker's COR list.
    -- Vanir Gun is the shooting gun (Compensator comes in for rolls through CompensatorMode).
    sets.weapons.Savage = {main = "Naegling", sub = "Nusku Shield", range = "Vanir Gun"}
    sets.weapons.DualSavage = {main = "Naegling", sub = "Gleti's Knife", range = "Vanir Gun"}
    sets.weapons.Ranged = {main = "Gleti's Knife", sub = "Nusku Shield", range = "Vanir Gun"} -- Nusku Shield: R.Acc/R.Atk+20
    sets.weapons.Leaden = {main = "Tauret", sub = "Nusku Shield", range = "Vanir Gun"}        -- Tauret: MAB+16, Magic Damage+217
    sets.weapons.DualLeaden = {main = "Tauret", sub = "Gleti's Knife", range = "Vanir Gun"}
    -- original weapon sets (Rostam, Fomalhaut, Ataktos, Blurred Knife +1, Atoyac, Kustawi +1 are not owned):
    -- sets.weapons.Default = {main = "Naegling", sub = "Nusku Shield", range = "Fomalhaut"}
    -- sets.weapons.Ranged = {main = "Rostam", sub = "Nusku Shield", range = "Fomalhaut"}
    -- sets.weapons.Evisceration = {main = "Tauret", sub = "Nusku Shield", range = "Ataktos"}
    -- sets.weapons.DualWeapons = {main = "Naegling", sub = "Gleti's Knife", range = "Fomalhaut"}
    -- sets.weapons.DualSavageWeapons = {main = "Naegling", sub = "Blurred Knife +1", range = "Ataktos"}
    -- sets.weapons.DualEvisceration = {main = "Tauret", sub = "Blurred Knife +1", range = "Ataktos"}
    -- sets.weapons.Savage = {main = "Naegling", sub = "Nusku Shield", range = "Ataktos"}
    -- sets.weapons.DualLeadenRanged = {main = "Rostam", sub = "Tauret", range = "Fomalhaut"}
    -- sets.weapons.DualLeadenMelee = {main = "Naegling", sub = "Atoyac", range = "Fomalhaut"}
    -- sets.weapons.DualAeolian = {main = "Rostam", sub = "Tauret", range = "Ataktos"}
    -- sets.weapons.DualLeadenMeleeAcc = {main = "Naegling", sub = "Blurred Knife +1", range = "Fomalhaut"}
    -- sets.weapons.DualRanged = {main = "Rostam", sub = "Kustawi +1", range = "Fomalhaut"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    -- Normal melee group
    sets.engaged = {
        ammo = gear.RAbullet,
        head = "Dampening Tam",          -- Quadruple Attack+3
        neck = "Null Loop",              -- original: "Iskur Gorget" (not owned)
        ear1 = "Crep. Earring",          -- original: "Cessance Earring" (not owned)
        ear2 = "Telos Earring",          -- original: "Brutal Earring" (stored)
        body = "Malignance Tabard",      -- original: "Meg. Cuirie +2" (not owned)
        hands = "Adhemar Wrist. +1",
        ring1 = "Epona's Ring",          -- original: "Petrov Ring"
        ring2 = "Chirich Ring +1",       -- original: "Epona's Ring"
        back = gear.tp_jse_back,
        waist = "Sailfi Belt +1",        -- original: "Windbuffet Belt +1" (not owned)
        legs = "Chas. Culottes +3",      -- original: "Samnuha Tights"; Store TP+12, Acc+63, DT-12%
        feet = "Malignance Boots"        -- original: gear.herculean_ta_feet (not owned)
    }

    sets.engaged.Acc = set_combine(sets.engaged, {head = "Malignance Chapeau", ring1 = "Cacoethic Ring +1", waist = "Null Belt"})
    -- original: Carmine Mask +1, Combatant's Torque, Cessance, Telos, Meg. Cuirie +2, Ramuh Ring +1, Olseni Belt,
    --           Carmine Cuisses +1, Malignance Boots

    -- DT-51%: Malignance head/body/hands/feet (6+9+5+4) + Null Loop 5 + Defending 10 + Chas. Culottes +3 12
    sets.engaged.DT = {
        ammo = gear.RAbullet,
        head = "Malignance Chapeau",
        neck = "Null Loop",              -- original: "Loricate Torque +1"
        ear1 = "Crep. Earring",          -- original: "Cessance Earring" (not owned)
        ear2 = "Telos Earring",          -- original: "Brutal Earring" (stored)
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        ring1 = "Defending Ring",
        ring2 = "Chirich Ring +1",       -- original: "Petrov Ring"
        back = gear.tp_jse_back,
        waist = "Sailfi Belt +1",        -- original: "Windbuffet Belt +1" (not owned)
        legs = "Chas. Culottes +3",      -- original: "Malignance Tights"
        feet = "Malignance Boots"
    }

    sets.engaged.Acc.DT = set_combine(sets.engaged.DT, {waist = "Null Belt"})
    -- original: Loricate Torque +1, Cessance, Ramuh Ring +1, Olseni Belt, Malignance Tights

    -- Dual wield (/NIN or /DNC): Suppanomimi DW+5, Reiki Yotai DW+7
    sets.engaged.DW = set_combine(sets.engaged, {ear1 = "Suppanomimi", waist = "Reiki Yotai"})
    -- original: Dampening Tam, Iskur, Suppanomimi, Brutal, Adhemar Jacket +1, Adhemar Wrist. +1, Petrov, Epona's,
    --           Windbuffet Belt +1, Samnuha Tights, Herculean TA feet

    sets.engaged.DW.Acc = set_combine(sets.engaged.Acc, {ear1 = "Suppanomimi", waist = "Reiki Yotai"})
    -- original: Carmine Mask +1, Combatant's Torque, Odr, Telos, Malignance Tabard, Floral Gauntlets, Ramuh Ring +1 x2,
    --           Olseni Belt, Carmine Cuisses +1, Malignance Boots

    sets.engaged.DW.DT = set_combine(sets.engaged.DT, {ear1 = "Suppanomimi", waist = "Reiki Yotai"})
    -- original: Malignance + Loricate, Suppanomimi, Brutal, Defending, Epona's, Reiki Yotai

    sets.engaged.DW.Acc.DT = set_combine(sets.engaged.DT, {ear1 = "Suppanomimi", waist = "Reiki Yotai"})
    -- original: Malignance + Loricate, Suppanomimi, Telos, Defending, Ramuh Ring +1, Reiki Yotai

    sets.packing = {
        ammo  = gear.RAbullet,
        head  = "Nyame Helm",
        neck  = "Loricate Torque +1",
        ear1  = "Alabaster Earring",     -- original: "Etiolation Earring"
        ear2  = "Etiolation Earring",    -- original: "Sanare Earring"
        body  = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Murky Ring",            -- original: "Shadow Ring" (not owned)
        back  = gear.tp_jse_back,        -- original: "Moonlight Cape" (not owned)
        waist = "Null Belt",             -- original: "Fucho-no-obi" (not COR-equippable)
        legs  = "Nyame Flanchard",
        feet  = "Nyame Sollerets"
    }
end

-- LINKTRI: renamed from job_customize_idle_set (COR.lua doesn't define one, but this keeps the PorterPacker
-- logic in the user hook like every other job).
function user_job_customize_idle_set(idleSet)
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
    if player.sub_job == "NIN" then
        set_macro_page(1, 17)
    elseif player.sub_job == "DNC" then
        set_macro_page(1, 17)
    elseif player.sub_job == "RNG" then
        set_macro_page(1, 17)
    elseif player.sub_job == "DRG" then
        set_macro_page(1, 17)
    else
        set_macro_page(1, 17)
    end
end

function user_job_lockstyle()
    -- LINKTRI MODIFICATION (2026-10-11): lockstyle sets are numbered by job ID (COR = 017).
    -- Was 001-004 by main/sub weapon type; those were not per-weapon looks.
    windower.chat.input("/lockstyleset 017")
end

-- LINKTRI: matches the rebuilt weapon sets.
-- original: Default/Savage/DualWeapons/DualSavageWeapons = Savage Blade, Evisceration/DualEvisceration = Evisceration,
--           Ranged/DualRanged = Last Stand, DualLeadenRanged/DualLeadenMelee = Leaden Salute, DualAeolian = Aeolian Edge
autows_list = {
    ["Savage"] = "Savage Blade",
    ["DualSavage"] = "Savage Blade",
    ["Ranged"] = "Last Stand",
    ["Leaden"] = "Leaden Salute",
    ["DualLeaden"] = "Leaden Salute"
}
