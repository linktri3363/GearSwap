-- Phalanx state machine globals
self_cast_phalanx    = false
phalanx_holding      = false
phalanx_saved_weapons = 'None'

near_porter = false

-- LINKTRI (2026-10-20): removed a leftover get_sets()/Mote-Include block. PLD.lua's get_sets() loads Sel-Include,
-- which loads this file, so the copy here was never used.
--   original: function get_sets() mote_include_version = 2 include('Mote-Include.lua') end

-- LINKTRI (2026-10-20) PLD audit notes:
--   * Rare items (one copy per character) are never put in both ear or both ring slots of one set.
--   * Ears/rings keep a consistent side across sets (Chev. Earring +1 always ear2, Murky Ring always ring2) to avoid
--     "Failed to equip" mirror swaps.
--   * Only one Rudianos's Mantle is owned (VIT+20 / Eva.+10 Mag. Eva.+10 / Enmity+10). Every set uses gear.pld_rudianos;
--     the augment strings for capes not owned are kept in "original:" comments for when they're made.
--   * Reverence / Caballarius / Chevalier's need no augment strings (plain names match any copy).
--   * Stored (unpack with PorterPacker): Plat. Mog. Belt, Elite Royal Collar, Rep. Plat. Medal, Naegling,
--     Rev. Coronet +4, Twilight Helm/Mail. Until unpacked, those slots keep whatever is already worn.

function user_job_setup()

    -- Options: Override default values
	state.OffenseMode:options('Normal','Acc')
    state.HybridMode:options('Tank','DDTank','Normal')
    state.WeaponskillMode:options('Match','Normal', 'Acc')
    state.CastingMode:options('Normal','SIRD') -- LINKTRI: original 'Normal','Phalanx' (no SIRD option, so every .SIRD set was unreachable)
	state.Passive:options('None','AbsorbMP')
    state.PhysicalDefenseMode:options('PDT_HP','PDT','PDT_Reraise')
    state.MagicalDefenseMode:options('MDT_HP','MDT','MDT_Reraise')
	state.ResistDefenseMode:options('MEVA_HP','MEVA')
	state.IdleMode:options('Normal','Tank','Kiting','Block','MEVA','Aminon','Regen','elemental','Statresist')
	-- LINKTRI: Caliburnus/Duban sets added at the end so the default and usual cycle order are unchanged
	state.Weapons:options('None','BurtgangPriwen','SakpataPriwen','NaeglingBlurred','DualWeapons','CaliburnusPriwen','CaliburnusDuban','BurtgangDuban')

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
	send_command('bind !q gs c set IdleMode Tank') -- LINKTRI: original 'set IdleMode PDT' (no PDT idle mode exists)
	send_command('bind @f8 gs c toggle AutoTankMode')
	send_command('bind @f10 gs c toggle TankAutoDefense')
	send_command('bind ^@!` gs c cycle SkillchainMode')

    select_default_macro_book()
    update_defense_mode()
	send_command('@wait 5;du lockstyle 7') -- LINKTRI MODIFICATION (2026-10-11): via DressUp so blink prevention doesn't swallow it
end

function init_gear_sets()

	-- LINKTRI: the one Rudianos's Mantle owned (augments must match exactly or GearSwap won't equip it)
	gear.pld_rudianos = { name="Rudianos's Mantle", augments={'VIT+20','Eva.+10 /Mag. Eva.+10','Enmity+10',}}

	--------------------------------------
	-- Precast sets
	--------------------------------------

    sets.Enmity = {
	ammo  = "Paeapua",                  -- Enmity+2
	head  = "Loess Barbuta",            -- Enmity+9~14 (Unity), DT-9%
	body  = "Chev. Cuirass +3",         -- Enmity+16  -- original: Sakpata's Plate (no Enmity)
	hands = "Cab. Gauntlets +4",        -- Enmity+9   -- original: Sakpata's Gauntlets (no Enmity)
	legs  = "Cab. Breeches +4",         -- Enmity+9, PDT-7%  -- original: Sakpata's Cuisses (no Enmity)
	feet  = "Chev. Sabatons +3",        -- Enmity+15
	neck  = { name="Kgt. Beads +2", augments={'Path: A'}},  -- Enmity+10 (base)
	waist = "Plat. Mog. Belt",          -- HP+10%, DT-3% (stored)
	ear1  = "Trux Earring",             -- Enmity+5
	ear2  = "Cryptic Earring",          -- Enmity+4
	ring1 = "Supershear Ring",          -- Enmity+5
	ring2 = "Pernicious Ring",          -- Enmity+5  -- original: Supershear Ring (Rare, only one owned)
	back  = gear.pld_rudianos,          -- Enmity+10  -- original: { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Eva.+20 /Mag. Eva.+20','Mag. Evasion+15',}} (not owned)
	} -- Enmity about +100 before Burtgang

    sets.Enmity.DT = {
	ammo	= "Staunch Tathlum +1",     -- DT-3%  -- original: Staunch Tathlum (not owned)
    head	= "Loess Barbuta",          -- DT-9%, Enmity+9~14  -- original: { name="Sakpata's Helm", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}} (augments not owned)
    body	= "Rev. Surcoat +4",        -- DT-11%, Enmity+10
    hands	= "Cab. Gauntlets +4",      -- Enmity+9  -- original: { name="Sakpata's Gauntlets", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}} (augments not owned)
    legs	= "Cab. Breeches +4",       -- PDT-7%, Enmity+9  -- original: { name="Sakpata's Cuisses", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}} (augments not owned)
    feet	= "Chev. Sabatons +3",      -- Enmity+15  -- original: { name="Sakpata's Leggings", augments={'HP+65','STR+12','Accuracy+13',}} (augments not owned)
    neck 	= { name="Kgt. Beads +2", augments={'Path: A'}},  -- Enmity+10  -- original: { name="Loricate Torque +1", augments={'Path: A'}}
    waist	= "Plat. Mog. Belt",        -- DT-3%
    ear1	= "Trux Earring",
    ear2	= "Cryptic Earring",
    ring1	= "Defending Ring",         -- DT-10%
    ring2	= { name="Murky Ring", augments={'Path: A'}},  -- DT-10%  -- original: Defending Ring (Rare, only one owned)
    back	= gear.pld_rudianos,
} -- about PDT-53% / MDT-46% with Priwen (cap 50%), Enmity about +90

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
	head  = "Sakpata's Helm",           -- original: { name="Sakpata's Helm", augments={'Accuracy+20','Mag. Acc.+12','"Fast Cast"+4'} } (augments not owned)
	body  = { name="Nyame Mail", augments={'Path: B'} },
	hands = "Cab. Gauntlets +4",
	legs  = { name="Nyame Flanchard", augments={'Path: B'} },
	feet  = { name="Nyame Sollerets", augments={'Path: B'} },
	neck  = "Null Loop",                -- original: Incanter's Torque (not owned)
	waist = "Luminary Sash",
	ear1  = { name="Nourish. Earring +1", augments={'Path: A',}},
    ear2  = "Chev. Earring +1",
	ring1 = "Stikini Ring",
	ring2 = { name="Metamor. Ring +1", augments={'Path: A'} },
	back  = gear.pld_rudianos,          -- original: { name="Rudianos's Mantle", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+4','Enmity+10','Mag. Evasion+15',}} (not owned)
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
	back  = gear.pld_rudianos,          -- original: { name="Rudianos's Mantle", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+4','Enmity+10','Mag. Evasion+15',}} (not owned)
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
    head	= "Chev. Armet +3",         -- FC+9%, DT-11%  -- original: { name="Sakpata's Helm", augments={'Accuracy+20','Mag. Acc.+12','"Fast Cast"+4',}} (augments not owned)
    body	= "Rev. Surcoat +4",        -- FC+10%, DT-11%
    hands	= "Chev. Gauntlets +3",     -- DT-11%  -- original: { name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}} (not owned)
    legs	= "Chev. Cuisses +3",       -- DT-13%  -- original: Rawhide Trousers (PLD can't equip)
    feet	= "Chev. Sabatons +3",      -- FC+13%  -- original: { name="Founder's Greaves", augments={'Accuracy+30','"Fast Cast"+6','VIT+5',}} (augments not owned)
    neck	= "Voltsurge Torque",       -- FC+4%  -- original: { name="Loricate Torque +1", augments={'Path: A',}}
    waist	= "Plat. Mog. Belt",
    ear1	= "Etiolation Earring",     -- FC+1%  -- original: Loquac. Earring (not owned)
    ear2	= "Chev. Earring +1",
    ring1 = "Kishar Ring",              -- FC+4%  -- original: Defending Ring
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back	= gear.pld_rudianos,        -- original: { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Spell interruption rate down-10%',}} (not owned)

	} -- FC about 41% (+10% with Sakpata's Sword); DT stays above the 50% cap

    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})

	-- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    -- LINKTRI: Moonshade augments fixed everywhere -- original: { name="Moonshade Earring", augments={'Accuracy+4','TP Bonus +250',}} (yours is Attack+4, so it never equipped)
    -- LINKTRI: weapon skill backs -> Null Shawl -- original: { name="Rudianos's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+5','Weapon skill damage +10%','Damage taken-5%',}} (not owned)
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
    ear2	= { name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},
    ring1	= "Ephramad's Ring",
    ring2	= { name="Metamor. Ring +1", augments={'Path: A'}},
    back	= "Null Shawl",
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
    ear2	= { name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},
    ring1	= "Ephramad's Ring",
    ring2	= { name="Metamor. Ring +1", augments={'Path: A'}},
    back	= "Null Shawl",
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
    ear2	= { name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},
    ring1	= "Ephramad's Ring",
    ring2	= { name="Metamor. Ring +1", augments={'Path: A'}},
    back	= "Null Shawl",
}

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    -- LINKTRI: ear1 Brutal Earring dropped (not owned), so the base set's Ishvara Earring stays
    sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {neck="Sacro Gorget",ear2="Moonshade Earring"}) -- original: ear1="Brutal Earring"
    sets.precast.WS['Requiescat'].Acc = set_combine(sets.precast.WS.Acc, {neck="Sacro Gorget",ear1="Telos Earring",ear2="Moonshade Earring"})

	sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {neck="Sacro Gorget",ear2="Moonshade Earring"}) -- original: ear1="Brutal Earring"
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
    ear2 ={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},
    ring1 ="Ephramad's Ring",
    ring2 ={ name="Metamor. Ring +1", augments={'Path: A'}}, -- original: "" (needs update)
    back="Null Shawl",
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
    ear2={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},
    ring1 ="Ephramad's Ring",
    ring2 ={ name="Metamor. Ring +1", augments={'Path: A'}}, -- original: "" (needs update)
    back="Null Shawl",
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
        back=gear.pld_rudianos,
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
    ear1	= "Nourish. Earring +1",
    ear2	= "Ishvara Earring",
    ring1	= "Stikini Ring",
    ring2	= "Stikini Ring",
    back	= gear.pld_rudianos,        -- original: { name="Rudianos's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+5','Weapon skill damage +10%','Damage taken-5%',}} (not owned)
}

    sets.precast.WS['Atonement'] = {
	ammo	= "Paeapua",
    head	= { name="Loess Barbuta", augments={'Path: A',}},
    body	= "Sakpata's Plate",        -- original: { name="Sakpata's Plate", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}} (augments not owned)
    hands	= "Sakpata's Gauntlets",    -- original: { name="Sakpata's Gauntlets", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}} (augments not owned)
    legs	= "Sakpata's Cuisses",      -- original: { name="Sakpata's Cuisses", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}} (augments not owned)
    feet	= "Eschite Greaves",
    neck	= { name="Loricate Torque +1", augments={'Path: A'}},
    waist	= "Isa Belt",               -- original: Creed Baudrier (not owned)
    ear1	= "Trux Earring",
    ear2	= "Cryptic Earring",
    ring1	= "Chirich Ring +1",
    ring2	= "Chirich Ring +1",
    back	= gear.pld_rudianos,        -- original: { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Accuracy+4','Enmity+10','Mag. Evasion+15',}} (not owned)
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
    ear2	= "Mache Earring +1",       -- original: Ishvara Earring (Rare, only one owned; Moonshade does nothing here, KoR fTP doesn't scale with TP)
    ring1	= "Ephramad's Ring",
    ring2	= { name="Metamor. Ring +1", augments={'Path: A'}},
    back	= "Null Shawl",
	}

	-- LINKTRI (2026-10-20): Imperator (Caliburnus weapon skill, needs Caliburnus Level 119 or higher).
	-- 70% DEX / 70% MND, physical, damage scales with TP (fTP 3.75 / 7.5 / 11.75), so Moonshade helps.
	sets.precast.WS['Imperator'] = {
	ammo	= { name="Coiste Bodhar", augments={'Path: A',}},
    head	= { name="Nyame Helm", augments={'Path: B',}},
    body	= { name="Nyame Mail", augments={'Path: B',}},
    hands	= { name="Nyame Gauntlets", augments={'Path: B',}},
    legs	= { name="Nyame Flanchard", augments={'Path: B',}},
    feet	= { name="Nyame Sollerets", augments={'Path: B',}},
    neck	= "Rep. Plat. Medal",
    waist	= { name="Sailfi Belt +1", augments={'Path: A',}},
    ear1	= "Ishvara Earring",
    ear2	= { name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},
    ring1	= "Ephramad's Ring",        -- DEX
    ring2	= { name="Metamor. Ring +1", augments={'Path: A'}}, -- MND
    back	= "Null Shawl",
	}
	sets.precast.WS['Imperator'].Acc = set_combine(sets.precast.WS['Imperator'], {neck="Null Loop",ear1="Telos Earring"})

	-- Swap to these on Moonshade using WS if at 3000 TP
	-- LINKTRI: replace only Moonshade (ear2) and keep Ishvara in ear1; Mache Earring +1 is ear2-only, so no mirror swaps
	sets.MaxTP = {ear2="Mache Earring +1"}                         -- original: {ear1="Cessance Earring",ear2="Brutal Earring"} (not owned)
	sets.AccMaxTP = {ear1="Telos Earring",ear2="Crep. Earring"}    -- original: {ear1="Telos Earring",ear2="Telos Earring"} (Rare, only one owned)


	--------------------------------------
	-- Midcast sets
	--------------------------------------

    sets.midcast.FastRecast = {
    ammo="Staunch Tathlum +1",          -- DT-3%, SIRD 11%
    head="Chev. Armet +3",              -- FC+9%, DT-11%  -- original: Sakpata's Helm
    neck={ name="Loricate Torque +1", augments={'Path: A'}},  -- DT-6%
    body="Rev. Surcoat +4",             -- FC+10%, DT-11%, Enmity+10
    hands="Chev. Gauntlets +3",         -- DT-11%  -- original: Leyline Gloves (not owned)
    feet="Chev. Sabatons +3",           -- FC+13%, Enmity+15  -- original: Founder's Greaves (owned copy has no Fast Cast)
	legs="Chev. Cuisses +3",            -- DT-13%  -- original: Rawhide Trousers (PLD can't equip)
	waist="Isa Belt",                   -- DT-3%  -- original: Creed Baudrier (not owned)
	ring1="Defending Ring",             -- DT-10%
    ring2={ name="Murky Ring", augments={'Path: A'}},  -- DT-10%
	ear1={ name="Odnowa Earring +1", augments={'Path: A',}},  -- original: Odnowa Earring (yours is the +1)
    ear2="Chev. Earring +1",            -- DT-5%
	back=gear.pld_rudianos,             -- original: { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Spell interruption rate down-10%',}} (not owned)
}

	sets.midcast.FastRecast.DT = set_combine(sets.midcast.FastRecast, {}) -- was an exact copy of FastRecast


	-- LINKTRI (2026-10-20): these 17 enmity/SIRD spell sets were identical blocks. They are now built from one base.
	-- set_combine() gives each spell its OWN copy (no shared table), and every spell keeps its own named set, so Sel
	-- finds exactly the same sets as before and any spell can still get its own tweak later.
	-- original per-set items changed: legs Kaykaus Tights +1 (PLD can't equip), ring2 Supershear Ring (Rare, only one
	-- owned), back { name="Rudianos's Mantle", augments={'HP+60','Enmity+10','Spell interruption rate down -10%',}} (not owned)
	local enmity_sird = {
	ammo  = "Staunch Tathlum +1",       -- SIRD 11%, DT-3%
	head  = "Sakpata's Helm",           -- DT-7%, FC+8%
	body  = "Chev. Cuirass +3",         -- SIRD 20%, Enmity+16
	hands = "Chev. Gauntlets +3",       -- DT-11%
	legs  = "Cab. Breeches +4",         -- SIRD 10%, Enmity+9, PDT-7%  -- original: Kaykaus Tights +1
	feet  = "Chev. Sabatons +3",        -- Enmity+15, FC+13%
	neck  = { name="Loricate Torque +1", augments={'Path: A'}},  -- DT-6%
	waist = "Rumination Sash",          -- SIRD 10%
	ear1  = "Cryptic Earring",          -- Enmity+4
	ear2  = "Chev. Earring +1",         -- DT-5%
	ring1 = "Supershear Ring",          -- Enmity+5
	ring2 = "Pernicious Ring",          -- Enmity+5  -- original: Supershear Ring
	back  = gear.pld_rudianos,          -- Enmity+10
	} -- SIRD 51% (+7% with Sacro Bulwark), Enmity about +64 before Burtgang

	sets.midcast["Jettatura"]      = set_combine(enmity_sird, {})
	sets.midcast["Blank Gaze"]     = set_combine(enmity_sird, {})
	sets.midcast["Sheep Song"]     = set_combine(enmity_sird, {})
	sets.midcast["Geist Wall"]     = set_combine(enmity_sird, {})
	sets.midcast["Pollen"]         = set_combine(enmity_sird, {})
	sets.midcast["Healing Breeze"] = set_combine(enmity_sird, {})
	sets.midcast["Sandspin"]       = set_combine(enmity_sird, {})
	sets.midcast["Wild Carrot"]    = set_combine(enmity_sird, {})
	sets.midcast["Magic Fruit"]    = set_combine(enmity_sird, {})
	sets.midcast["Metallic Body"]  = set_combine(enmity_sird, {})
	sets.midcast.Flash             = set_combine(enmity_sird, {})
	sets.midcast.Flash.SIRD        = set_combine(enmity_sird, {})
	sets.midcast.Stun              = set_combine(enmity_sird, {})
	sets.midcast.Stun.SIRD         = set_combine(enmity_sird, {})
	sets.midcast['Blue Magic']     = set_combine(enmity_sird, {})
	sets.midcast['Blue Magic'].SIRD = set_combine(enmity_sird, {})
	sets.midcast.Cocoon            = set_combine(enmity_sird, {})
	-- LINKTRI: Foil (RUN subjob) is Enhancing Magic, so it used to get the Enhancing set; it's an enmity spell
	sets.midcast.Foil              = set_combine(enmity_sird, {})

    sets.midcast.Cure = {
    ammo="Staunch Tathlum +1",          -- DT-3%, SIRD 11%
    head="Sakpata's Helm",              -- Cure potency +5% (R30)
    body="Chev. Cuirass +3",            -- SIRD 20%, Enmity+16
    hands="Cab. Gauntlets +4",          -- Enmity+9
    legs="Cab. Breeches +4",            -- SIRD 10%, Enmity+9  -- original: Kaykaus Tights +1 (PLD can't equip)
    feet="Founder's Greaves",
    neck="Sacro Gorget",                -- Cure potency +10%, Enmity+5
    waist="Rumination Sash",            -- SIRD 10%
    ear1={ name="Nourish. Earring +1", augments={'Path: A'}},  -- Cure potency +3%
    ear2="Chev. Earring +1",            -- Cure potency +11%  -- original: Sanare Earring
    ring1="Defending Ring",             -- DT-10%
    ring2={ name="Murky Ring", augments={'Path: A'}},  -- DT-10%
    back=gear.pld_rudianos,             -- original: {name="Rudianos's Mantle",augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Spell interruption rate down-10%',}} (not owned)
}

    sets.midcast.Cure.SIRD = set_combine(sets.midcast.Cure, {}) -- was an exact copy of Cure

    sets.midcast.Cure.DT ={
    ammo="Staunch Tathlum +1",          -- DT-3%, SIRD 11%
    head="Sakpata's Helm",              -- DT-7%, Cure potency +5%
    body="Sakpata's Plate",             -- DT-10%
    hands="Cab. Gauntlets +4",          -- Enmity+9
    legs="Cab. Breeches +4",            -- SIRD 10%, PDT-7%  -- original: Kaykaus Tights +1 (PLD can't equip)
    feet="Founder's Greaves",
    neck="Sacro Gorget",                -- Cure potency +10%  -- original: Incanter's Torque (not owned)
    waist="Rumination Sash",            -- SIRD 10%
    ear1={ name="Nourish. Earring +1", augments={'Path: A'}},  -- Cure potency +3%
    ear2="Chev. Earring +1",            -- Cure potency +11%, DT-5%  -- original: Sanare Earring
    ring1="Defending Ring",             -- DT-10%
    ring2={ name="Murky Ring", augments={'Path: A'}},  -- DT-10%
    back=gear.pld_rudianos,             -- original: { name="Rudianos's Mantle", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+4','Enmity+10','Mag. Evasion+15',}} (not owned)
}

	sets.midcast.CureSelf     = set_combine(sets.midcast.Cure, {})
	sets.midcast.CureSelf.SIRD = set_combine(sets.midcast.Cure.SIRD, {})
	sets.midcast.CureSelf.DT   = set_combine(sets.midcast.Cure.DT, {})

    sets.midcast.Reprisal = {
	ammo="Staunch Tathlum +1",
    head="Chev. Armet +3",
    body="Cab. Surcoat +4",
    hands="Chev. Gauntlets +3",
    legs="Chev. Cuisses +3",
    feet="Rev. Leggings +4",
    neck={ name="Loricate Torque +1", augments={'Path: A'}},
    waist="Rumination Sash",
    ear1="Cryptic Earring",
    ear2="Chev. Earring +1",
    ring1="Defending Ring",
    ring2={ name="Murky Ring", augments={'Path: A'}},  -- original: Defending Ring (Rare, only one owned)
    back=gear.pld_rudianos,             -- original: { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Spell interruption rate down-10%',}} (not owned)
}

	-- Self-cures (Sel uses these when you cure yourself). Sakpata's Plate: Cure received +10%.
	sets.Self_Healing = {
	ammo="Staunch Tathlum +1",
    head="Sakpata's Helm",              -- original: { name="Sakpata's Helm", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}} (augments not owned)
    body="Sakpata's Plate",
    hands="Sakpata's Gauntlets",        -- original: { name="Sakpata's Gauntlets", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}} (augments not owned)
    legs="Cab. Breeches +4",            -- original: { name="Kaykaus Tights +1", augments={'MND+5','Mag. Acc.+2','Breath dmg. taken -2%',}} (PLD can't equip)
    feet="Sakpata's Leggings",          -- original: { name="Founder's Greaves", augments={'Accuracy+30','"Fast Cast"+6','VIT+5',}} (augments not owned)
    neck={ name="Loricate Torque +1", augments={'Path: A'}},
    waist="Rumination Sash",
    ear1={ name="Nourish. Earring +1", augments={'Path: A',}},
    ear2="Chev. Earring +1",
    ring1="Defending Ring",
    ring2={ name="Murky Ring", augments={'Path: A'}},
    back=gear.pld_rudianos,             -- original: { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Spell interruption rate down-10%',}} (not owned)

}

	sets.Self_Healing.SIRD = set_combine(sets.Self_Healing, {}) -- was an exact copy of Self_Healing

	sets.Self_Healing.DT = {
	ammo	= "Staunch Tathlum +1",     -- original: Staunch Tathlum (not owned)
    head	= "Chev. Armet +3",
    body	= "Sakpata's Plate",        -- original: { name="Sakpata's Plate", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}} (augments not owned)
    hands	= "Cab. Gauntlets +4",      -- original: { name="Cab. Gauntlets +4", augments={'Path: A',}} (augments not owned)
    legs	= "Chev. Cuisses +3",
    feet	= "Sakpata's Leggings",     -- original: { name="Founder's Greaves", augments={'Attack+15','"Cure" potency +4%','Mag. Acc.+6','"Mag.Atk.Bns."+6',}} (augments not owned)
    neck	= { name="Loricate Torque +1", augments={'Path: A'}},
    waist	= "Plat. Mog. Belt",
    ear1	= "Nourish. Earring +1",
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back	= gear.pld_rudianos,        -- original: { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Accuracy+4','Enmity+10','Mag. Evasion+15',}} (not owned)
}


    sets.midcast['Enhancing Magic'] = {
    ammo="Staunch Tathlum +1",
    head="Sakpata's Helm",              -- original: { name="Sakpata's Helm", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}} (augments not owned)
    body="Rev. Surcoat +4",             -- original: { name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}} (PLD can't equip)
    hands="Chev. Gauntlets +3",         -- original: Regal Gloves (PLD can't equip)
    legs="Rev. Breeches +4",            -- Enhancing magic skill +20  -- original: { name="Kaykaus Tights +1", augments={'MND+5','Mag. Acc.+2','Breath dmg. taken -2%',}} (PLD can't equip)
    feet="Sakpata's Leggings",          -- original: { name="Founder's Greaves", augments={'Accuracy+30','"Fast Cast"+6','VIT+5',}} (augments not owned)
    neck={ name="Loricate Torque +1", augments={'Path: A'}},
    waist="Rumination Sash",
    ear1={ name="Odnowa Earring +1", augments={'Path: A',}},  -- original: Odnowa Earring (yours is the +1)
    ear2="Chev. Earring +1",
    ring1="Defending Ring",
    ring2={ name="Murky Ring", augments={'Path: A'}},
    back=gear.pld_rudianos,             -- original: { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Spell interruption rate down-10%',}} (not owned)
}

    sets.midcast['Enhancing Magic'].SIRD = set_combine(sets.midcast['Enhancing Magic'], {legs="Cab. Breeches +4"}) -- SIRD 10% legs

	sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {waist="Siegel Sash"})

	-- LINKTRI: original added ring2="Defending Ring" on top of ring1 Defending Ring (Rare, only one owned)
    sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {})
    sets.midcast.Shell = set_combine(sets.midcast['Enhancing Magic'], {})

	-- Phalanx casting set (Rhandalthor gear - upgrade as inventory allows)
	-- Phalanx+: Valorous head/body/hands +4 each, feet +5; Phalanx received: Sakpata's Sword +5, Sakpata's Cuisses +5, Priwen +2
	sets.midcast.Phalanx = {
    main	= "Sakpata's Sword",
    sub		= "Priwen",
    ammo	= "Staunch Tathlum +1",
    head	= gear.valorous_phalanx_tank_head,
    body	= gear.valorous_phalanx_tank_body,
    hands	= gear.valorous_phalanx_tank_hands,
    legs	= "Sakpata's Cuisses",      -- Phalanx received +5, DT-9%  -- original: gear.valorous_phalanx_tank_legs (Phalanx +4)
    feet	= gear.valorous_phalanx_tank_feet,
    neck	= { name="Loricate Torque +1", augments={'Path: A'}},  -- original: Incanter's Torque (not owned)
    waist	= "Rumination Sash",        -- SIRD 10%  -- original: Olympus Sash (not owned)
    ear1	= { name="Odnowa Earring +1", augments={'Path: A',}},  -- original: Mimir Earring (not owned)
    ear2	= "Andoaa Earring",
    ring1	= "Stikini Ring",           -- original: Stikini Ring +1 (not owned; you have two Stikini Ring)
    ring2	= "Stikini Ring",           -- original: Stikini Ring +1
    back	= gear.pld_rudianos,        -- original: { name="Weard Mantle", augments={'VIT+2','DEX+4','Enmity+5','Phalanx +5',}} (not owned)
	}

	-- LINKTRI: the SIRD and DT variants were almost entirely gear not owned (Souveran, Odyssean, Founder's Hose,
	-- Moonlight, Audumbla, Knightly, Evanescence, Weard, Yorium), which dropped the Phalanx gear when used.
	-- They now match the main Phalanx set.
	--   original SIRD: head Souv. Schaller +1, body Odyss. Chestplate (Phalanx +4), hands Souv. Handsch. +1, legs Founder's Hose,
	--     feet Souveran Schuhs +1, neck Moonlight Necklace, waist Audumbla Sash, ear1 Knightly Earring, ear2 Nourish. Earring +1,
	--     ring1 Evanescence Ring, ring2 Moonlight Ring, back Weard Mantle
	--   original DT: same, with body Yorium Cuirass
	sets.midcast.Phalanx.SIRD = set_combine(sets.midcast.Phalanx, {})
	sets.midcast.Phalanx.DT = set_combine(sets.midcast.Phalanx, {})

	-- PhalanxWithWeapons: used for prephalanx command and self-cast pre-equip
	sets.midcast.PhalanxWithWeapons = set_combine(sets.midcast.Phalanx, {
    main	= "Sakpata's Sword",
    sub		= "Priwen",
	})
	--------------------------------------
	-- Idle/resting/defense/etc sets
	--------------------------------------

    -- Idle sets
	-- LINKTRI: every idle/defense back -> gear.pld_rudianos (the augment strings below were for capes not owned)
	--   original backs: {'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Damage taken-5%'},
	--   {'HP+60','Eva.+20 /Mag. Eva.+20','Accuracy+4','Enmity+10','Mag. Evasion+15'}, {'VIT+20','Eva.+20 /Mag. Eva.+20','VIT+10','Enmity+10','"Regen"+5'}
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
  back	= gear.pld_rudianos,
 }

  sets.idle.elemental = {
  ammo	= "Staunch Tathlum +1",
  head	= "Chev. Armet +3",
  body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
  hands	= "Cab. Gauntlets +4",
  legs	= "Chev. Cuisses +3",
  feet	= "Rev. Leggings +4",
  neck	= { name="Kgt. Beads +2", augments={'Path: A',}},  -- original: Warder's Charm +1 (not owned)
  waist	= "Carrier's Sash",
  ear1	= "Sanare Earring",
  ear2	= "Chev. Earring +1",           -- original: "" (needs update)
  ring1	= "Defending Ring",
  ring2	= { name="Murky Ring", augments={'Path: A'}},
  back	= gear.pld_rudianos,
	}

  sets.idle.Statresist = {
  ammo	= "Staunch Tathlum +1",
  head	= "Chev. Armet +3",
  body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
  hands	= "Cab. Gauntlets +4",
  legs	= "Chev. Cuisses +3",
  feet 	= "Rev. Leggings +4",
  neck	= { name="Kgt. Beads +2", augments={'Path: A',}},  -- original: Warder's Charm +1 (not owned)
  waist = "Carrier's Sash",
  ear1	= "Sanare Earring",
  ear2	= "Chev. Earring +1",           -- original: "" (needs update)
  ring1	= "Defending Ring",
  ring2	= { name="Murky Ring", augments={'Path: A'}},
  back	= gear.pld_rudianos,
	}


sets.idle.Regen = {
  ammo	= "Staunch Tathlum +1",
  head	= "Null Masque",
  body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
  hands	= "Volte Moufles",              -- Regen+2  -- original: Regal Gloves (PLD can't equip)
  legs	= "Chev. Cuisses +3",
  feet	= "Chev. Sabatons +3",
  neck	= "Elite Royal Collar",
  waist	= "Null Belt",
  ear1	= { name="Odnowa Earring +1", augments={'Path: A',}},  -- original: Odnowa Earring (yours is the +1)
  ear2	= "Chev. Earring +1",
  ring1	= "Chirich Ring +1",
  ring2	= "Chirich Ring +1",
  back	= gear.pld_rudianos,
 }

  sets.idle.Aminon = {
  ammo		= "Staunch Tathlum +1",
  head		= "Null Masque",
  body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
  hands		= "Sakpata's Gauntlets",
  legs		= "Sakpata's Cuisses",
  feet		= "Sakpata's Leggings",
  neck		= { name="Kgt. Beads +2", augments={'Path: A',}},  -- original: Incanter's Torque (not owned)
  waist		= "Asklepian Belt",
  ear1		= "Sanare Earring",
  ear2		= "Chev. Earring +1",
  ring1		= "Defending Ring",
  ring2		= { name="Murky Ring", augments={'Path: A'}},
  back		= gear.pld_rudianos,
	}

   sets.idle.MEVA = {
   ammo		= "Staunch Tathlum +1",
   head		= "Null Masque",
   body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
   hands	= "Cab. Gauntlets +4",      -- original: { name="Cab. Gauntlets +4", augments={'Path: A',}} (augments not owned)
   legs		= "Chev. Cuisses +3",
   feet		= "Sakpata's Leggings",     -- original: { name="Sakpata's Leggings", augments={'HP+65','STR+12','Accuracy+13',}} (augments not owned)
   neck		= { name="Kgt. Beads +2", augments={'Path: A',}},  -- original: Warder's Charm +1 (not owned)
   waist	= "Plat. Mog. Belt",
   ear1		= "Sanare Earring",
   ear2		= "Chev. Earring +1",       -- original: "" (needs update)
   ring1	= "Defending Ring",
   ring2	= { name="Murky Ring", augments={'Path: A'}},
   back		= gear.pld_rudianos,
}

    sets.idle.Block = {
	ammo	= "Staunch Tathlum +1",     -- original: Staunch Tathlum (not owned)
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
    ring2	= { name="Murky Ring", augments={'Path: A'}},  -- original: ring = "Moonlight Ring" (typo'd slot name, and not owned)
    back	= gear.pld_rudianos,
}

    sets.idle.Tank = {
  ammo	= "Staunch Tathlum +1",
  head	= "Chev. Armet +3",
  body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
  hands	= "Chev. Gauntlets +3",         -- original: Regal Gloves (PLD can't equip)
  legs	= "Chev. Cuisses +3",
  feet	= "Chev. Sabatons +3",
  neck	= { name="Kgt. Beads +2", augments={'Path: A',}},
  waist	= "Null Belt",
  ear1	= "Etiolation Earring",
  ear2	= "Chev. Earring +1",
  ring1 = "Defending Ring",
  ring2 = { name="Murky Ring", augments={'Path: A'}},
  back	= gear.pld_rudianos,
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
    back	= gear.pld_rudianos,
}

	sets.Kiting = {ring1 = { name="Shneddick Ring +1"}}

	sets.packing = {
		ammo    = "Homiliary",
		head    = "Null Masque",
		body    = "Sakpata's Plate",
		hands   = "Chev. Gauntlets +3",     -- original: Regal Gloves (PLD can't equip)
		legs    = "Sakpata's Cuisses",
		feet    = "Sakpata's Leggings",
		neck    = { name="Kgt. Beads +2", augments={'Path: A',}},
		waist   = "Fucho-no-Obi",
		ear1    = "Etiolation Earring",
		ear2    = "Chev. Earring +1",
		ring1   = "Defending Ring",
		ring2   = { name="Murky Ring", augments={'Path: A'}},
		back    = gear.pld_rudianos,
	}

	sets.latent_refresh = {waist="Fucho-no-Obi"}
	-- sets.latent_refresh_grip = {sub="Oneiros Grip"} -- LINKTRI: not owned, and PLD uses a shield
	sets.latent_regen = {ring1="Chirich Ring +1",ring2="Chirich Ring +1"}
	sets.DayIdle = {}
	sets.NightIdle = {}

	--------------------------------------
    -- Defense sets
    --------------------------------------

    -- Extra defense sets.  Apply these on top of melee or defense sets.
	sets.Knockback = {}
	-- LINKTRI: Etiolation moved to ear1 (its side everywhere else; ear2 would duplicate it on top of idle sets)
	--   original: {head="Chev. Armet +3",neck="Incanter's Torque",ear2="Etiolation Earring",waist="Flume Belt +1",feet="Rev. Leggings +4"}
	--   (Incanter's Torque and Flume Belt +1 not owned)
    sets.MP = {head="Chev. Armet +3",ear1="Etiolation Earring",feet="Rev. Leggings +4"}
	sets.passive.AbsorbMP = {head="Chev. Armet +3",ear1="Etiolation Earring",feet="Rev. Leggings +4"}
    sets.MP_Knockback = {}
    sets.Twilight = {head="Twilight Helm", body="Twilight Mail"}
	sets.Reraise = {head="Twilight Helm", body="Twilight Mail"} -- LINKTRI: used by engaged.Reraise (was undefined)
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})

	-- Weapons sets
	sets.weapons.BurtgangPriwen = {main="Burtgang",sub={ name="Priwen", augments={'HP+50','Mag. Evasion+50','Damage Taken -3%'}}}
	sets.weapons.SakpataPriwen = {main="Sakpata's Sword",sub={ name="Priwen", augments={'HP+50','Mag. Evasion+50','Damage Taken -3%'}}}
	sets.weapons.NaeglingBlurred = {main="Naegling",sub="Blurred Shield +1"}
	sets.weapons.DualWeapons = {main="Naegling",sub={ name="Ternion Dagger +1", augments={'Path: A'}}}
	-- LINKTRI (2026-10-20): Prime weapons (currently Incomplete: no DT/refresh yet, and both drain 1 HP/MP per tick)
	sets.weapons.CaliburnusPriwen = {main="Caliburnus",sub={ name="Priwen", augments={'HP+50','Mag. Evasion+50','Damage Taken -3%'}}}
	sets.weapons.CaliburnusDuban = {main="Caliburnus",sub="Duban"}
	sets.weapons.BurtgangDuban = {main="Burtgang",sub="Duban"}

    sets.defense.Block = {
	ammo	= "Staunch Tathlum +1",     -- original: Staunch Tathlum (not owned)
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
    ring2	= { name="Murky Ring", augments={'Path: A'}},  -- original: ring = "Moonlight Ring" (typo'd slot name, and not owned)
    back	= gear.pld_rudianos,
}

	sets.defense.Aminon = {
	ammo	= "Staunch Tathlum +1",
    head	= "Sakpata's Helm",
    body	= "Adamantite Armor",  -- DT-20%, MEVA+107, MDB+20
    hands	= "Sakpata's Gauntlets",
    legs	= "Sakpata's Cuisses",
    feet	= "Sakpata's Leggings",
    neck	= { name="Kgt. Beads +2", augments={'Path: A',}},  -- original: Incanter's Torque (not owned)
    waist	= "Asklepian Belt",
    ear1  	= "Sanare Earring",
	ear2  	= "Chev. Earring +1",
    ring1	= "Defending Ring",
    ring2	= { name="Murky Ring", augments={'Path: A'}},
    back	= gear.pld_rudianos,
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
    ear1	= { name="Odnowa Earring +1", augments={'Path: A',}},  -- original: Odnowa Earring (yours is the +1)
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back	= gear.pld_rudianos,
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
    ear1	= { name="Odnowa Earring +1", augments={'Path: A',}},  -- original: Odnowa Earring (yours is the +1)
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back	= gear.pld_rudianos,
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
    ear1	= { name="Odnowa Earring +1", augments={'Path: A',}},  -- original: Odnowa Earring (yours is the +1)
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back	= gear.pld_rudianos,
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
    ear1	= { name="Odnowa Earring +1", augments={'Path: A',}},  -- original: Odnowa Earring (yours is the +1)
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring2 = { name="Murky Ring", augments={'Path: A'}},
    back	= gear.pld_rudianos,
}

	sets.defense.MEVA = {
    ammo 	= "Staunch Tathlum +1",
    head 	= "Loess Barbuta",
    body	= "Adamantite Armor",                   -- DT-20%, MEVA+107, MDB+20
    hands 	= "Sakpata's Gauntlets",
    legs	= "Chev. Cuisses +3",
    feet	= "Sakpata's Leggings",
    neck	= { name="Kgt. Beads +2", augments={'Path: A',}},  -- original: Warder's Charm +1 (not owned)
    waist	= "Plat. Mog. Belt",
    ear1	= "Sanare Earring",
    ear2	= "Chev. Earring +1",
    ring1 = "Defending Ring",
    ring2	= "Chirich Ring +1",
    back	= gear.pld_rudianos,            -- original: { name="Rudianos's Mantle", augments={'VIT+20','Enmity+10','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Damage taken-5%',}} (not owned)
	}



    sets.defense.PDT_Reraise = set_combine(sets.defense.PDT_HP,{head="Twilight Helm",body="Twilight Mail"})
    sets.defense.MDT_Reraise = set_combine(sets.defense.MDT_HP,{head="Twilight Helm",body="Twilight Mail"})

	--------------------------------------
	-- Engaged sets
	--------------------------------------
    -- LINKTRI: head -> Sakpata's Helm in every engaged set -- original: Hjarrandi Helm (not owned)

	sets.engaged = {
	ammo={ name="Coiste Bodhar", augments={'Path: A',}},
    head="Sakpata's Helm",
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
    head="Sakpata's Helm",
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

	-- LINKTRI (2026-10-20): real tanking set for the default HybridMode (Tank). It used to be a copy of the damage set.
	--   DT: Armet 11 + Sakpata's Plate 10 + Gauntlets 8 + Chev. Cuisses 13 + Leggings 6 + Chev. Earring 5 = 53, plus Priwen 6
	--   Chev. Cuisses: enmity retention when taking damage; Kgt. Beads +2 and Rudianos's Mantle: Enmity
	--   original: same items as sets.engaged (with Hjarrandi Helm)
	sets.engaged.Tank = {
	ammo={ name="Coiste Bodhar", augments={'Path: A',}},
    head="Chev. Armet +3",
    body="Sakpata's Plate",
    hands={ name="Sakpata's Gauntlets", augments={'Path: A'}},
    legs="Chev. Cuisses +3",
    feet="Sakpata's Leggings",
    neck={ name="Kgt. Beads +2", augments={'Path: A',}},
    waist={ name="Sailfi Belt +1", augments={'Path: A',}},
    ear1 = "Telos Earring",
    ear2 = "Chev. Earring +1",
    ring1 = "Chirich Ring +1",
    ring2 = "Chirich Ring +1",
    back=gear.pld_rudianos,
	}


	sets.engaged.DDTank = {
	ammo={ name="Coiste Bodhar", augments={'Path: A',}},
    head="Sakpata's Helm",
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
    head="Sakpata's Helm",
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
    head="Sakpata's Helm",
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
    sets.engaged.Acc.Reraise = set_combine(sets.engaged.Acc, sets.Reraise) -- original: set_combine(sets.engaged.Acc.Tank, ...) (Acc.Tank doesn't exist)

	--------------------------------------
	-- Custom buff sets
	--------------------------------------
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = {} -- original: {neck="Vim Torque +1"} (not owned)
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

-- LINKTRI (2026-10-20): renamed from job_customize_idle_set. That name replaced PLD.lua's own version, which adds
-- Fucho-no-Obi below 51% MP and Chirich rings below 71% HP. user_job_* runs after it instead.
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

-- LINKTRI (2026-10-20): renamed from job_precast(spell, action, spellMap, eventArgs). That name replaced PLD.lua's own
-- version (Auto Divine Emblem before Flash), and the extra 'action' argument shifted the others.
-- Removed the Reprisal line that equipped Telchine Chasuble (PLD can't equip; precast uses the fast cast set).
--   original: elseif spell.english == 'Reprisal' then equip({ body={ name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}} })
function user_job_precast(spell, spellMap, eventArgs)
    if spell.english == 'Phalanx' then
        self_cast_phalanx = true
        phalanx_saved_weapons = state.Weapons.value
    end
end

-- LINKTRI (2026-10-20): renamed from job_midcast(spell, action, spellMap, eventArgs); with the extra argument eventArgs
-- was always nil, so 'handled' was never set. Removed the Reprisal line (Sel already picks sets.midcast.Reprisal).
function user_job_midcast(spell, spellMap, eventArgs)
    if spell.english:match('Phalanx') then
        enable('main', 'sub')
        equip(sets.midcast.Phalanx)
        if eventArgs then eventArgs.handled = true end
    end
end

-- LINKTRI (2026-10-20): removed job_post_midcast. It equipped sets.midcast.Cure / CureSelf on every Cure, which
-- overwrote Sel's choice of Self_Healing (self-cures) and the SIRD variants.
--   original:
--   function job_post_midcast(spell, action, spellMap, eventArgs)
--       if spell.english:startswith('Cure') then
--           if spell.target.type == 'SELF' then equip(sets.midcast.CureSelf) else equip(sets.midcast.Cure) end
--       end
--   end

-- LINKTRI (2026-10-20): renamed from job_aftercast (replaced PLD.lua's own). Removed the enable('waist') and the
-- idle set equip after every spell (Sel equips the right idle/engaged set right after this anyway).
function user_job_aftercast(spell, spellMap, eventArgs)
    if spell.english == 'Phalanx' then
        self_cast_phalanx = false
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
            local trigger_pos = str:find(trigger, 1, true)
            -- LINKTRI (2026-10-20): skip lines where you are the one acting ("Linktri starts casting Slow on ...").
            -- Your name appearing before the trigger means you're the caster; it used to lock your gear for 3s mid-cast.
            if trigger_pos and str:find(player_name, 1, true) > trigger_pos then
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
