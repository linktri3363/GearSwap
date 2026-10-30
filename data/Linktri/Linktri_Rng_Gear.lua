near_porter = false

-- ======================================================================================================
-- LINKTRI REBUILD 2026-10-30: every set below rebuilt from the Oct 30 RNG inventory export (plus Arcadian
-- Socks +1, owned but missing from the export). The previous version was Selindrile's template and
-- referenced ~55 unowned items (Fomalhaut, Kustawi, every Belenus's Cape, Regal Ring, Fotia, Orion +3,
-- Carmine, Adhemar Jacket, Iskur, Yemaya, ...). Each changed set keeps its original in a comment.
-- Weapons: Vanir Gun, Gleti's Crossbow, Hangaku-no-Yumi and Ullr, with Gleti's Knife / Nusku Shield.
-- Snapshot: Amini Gapette +3 9 + Ikenga's Vest 9 + Ikenga's Gloves 7 + Ikenga's Trousers 8 + Meg. Jam. +2 10
-- + Crepuscular Ring 3 = 46% from gear (cap 70% including Flurry).
-- ======================================================================================================

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_job_setup()
	state.OffenseMode:options('Normal','Acc')
	state.HybridMode:options('Normal','DTLite','DT')
	state.RangedMode:options('Normal','Acc','Fodder')
	state.WeaponskillMode:options('Match','Normal', 'Acc')
	state.IdleMode:options('Normal', 'PDT')
	-- LINKTRI: weapon list rebuilt around owned weapons.
	-- original: 'Default','DualWeapons','DualSavageWeapons','DualEviscerationWeapons','DualMagicWeapons','DualMalevolence'
	state.Weapons:options('Gun','Crossbow','Bow','Ullr','MagicGun','DualMagicGun','None')

	--Ikenga_vest_bonus = 190  -- It is 190 at R20. Uncomment if you need to manually adjust because you are using below R20

	-- original: WeaponType = {['Fail-Not'] = "Bow", ['Fomalhaut'] = "Gun", ['Ataktos'] = "Gun"}
	-- (RNG.lua reads the weapon type from the game data, so this table is informational.)
	WeaponType =  {['Vanir Gun'] = "Gun",
	               ['Gleti\'s Crossbow'] = "Crossbow",
	               ['Hangaku-no-Yumi'] = "Bow",
	               ['Ullr'] = "Bow",
	               }

-- LINKTRI: ammo you own. Bows only have Kabura Arrow (Silence effect, DMG 38) and crossbows have no bolts yet;
-- swap the names in once you buy better ammo (Chrono Arrow, Quelling / Achiyal. Bolt, Chrono Bullet).
-- Hauksbok "Unlimited" entries only equip if you own them.
DefaultAmmo = {
    ['Bow'] = {
        ['Default'] = "Kabura Arrow",   -- original: "Chapuli Arrow" (not owned)
        ['WS'] = "Kabura Arrow",        -- original: "Chapuli Arrow" (not owned)
        ['Acc'] = "Kabura Arrow",       -- original: "Scorpion Arrow" (not owned)
        ['Magic'] = "Kabura Arrow",     -- original: "Chapuli Arrow" (not owned)
        ['MagicAcc'] = "Kabura Arrow",  -- original: "Scorpion Arrow" (not owned)
        ['Unlimited'] = "Hauksbok Arrow",
        ['MagicUnlimited'] = "Hauksbok Arrow",
        ['MagicAccUnlimited'] = "Hauksbok Arrow"
    },
    ['Gun'] = {
        ['Default'] = "Eminent Bullet",   -- original: "Chrono Bullet" (not owned)
        ['WS'] = "Eminent Bullet",        -- original: "Chrono Bullet" (not owned)
        ['Acc'] = "Eminent Bullet",       -- original: "Chrono Bullet" (not owned)
        ['Magic'] = "Eminent Bullet",     -- original: "Orichalc. Bullet" (not owned)
        ['MagicAcc'] = "Eminent Bullet",  -- original: "Orichalc. Bullet" (not owned)
        ['Unlimited'] = "Hauksbok Bullet",
        ['MagicUnlimited'] = "Hauksbok Bullet",
        ['MagicAccUnlimited'] = "Hauksbok Bullet" -- original: "Animikii Bullet" (not owned)
    },
    ['Crossbow'] = {
        ['Default'] = "Quelling Bolt",   -- original: "Eminent Bolt". No bolts owned yet - buy Quelling or Achiyal. Bolts
        ['WS'] = "Quelling Bolt",
        ['Acc'] = "Quelling Bolt",
        ['Magic'] = "Quelling Bolt",
        ['MagicAcc'] = "Quelling Bolt",
        ['Unlimited'] = "Hauksbok Bolt",
        ['MagicUnlimited'] = "Hauksbok Bolt",
        ['MagicAccUnlimited'] = "Hauksbok Bolt"
    }
}

	-- LINKTRI: no Belenus's Cape is owned. Each cape variable points at Null Shawl (R.Acc/Acc/M.Acc+50, Store TP+7)
	-- so the sets still equip a back piece. Swap each one back when you make the capes.
	-- original: gear.tp_ranger_jse_back = {name="Belenus's Cape",augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','"Store TP"+10',}}
	-- original: gear.wsd_ranger_jse_back = {name="Belenus's Cape",augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Weapon skill damage +10%',}}
	-- original: gear.snapshot_jse_back = {name="Belenus's Cape",augments={'"Snapshot"+10',}}
	gear.tp_ranger_jse_back = "Null Shawl"
	gear.wsd_ranger_jse_back = "Null Shawl"
	gear.snapshot_jse_back = "Null Shawl"

	    -- Additional local binds
    send_command('bind !` input /ra <t>')
	send_command('bind !backspace input /ja "Bounty Shot" <t>')
	send_command('bind @f7 gs c toggle RngHelper')
	send_command('bind @` gs c cycle SkillchainMode')
	send_command('bind !r gs c weapons MagicGun;gs c update')  -- original: MagicWeapons (no such weapon set)
	send_command('bind ^q gs c weapons Gun;gs c update')       -- original: SingleWeapon (no such weapon set)

	select_default_macro_book()

end

-- Set up all gear sets.
function init_gear_sets()
	--------------------------------------
	-- Precast sets
	--------------------------------------

	-- Precast sets to enhance JAs
	sets.TreasureHunter = {waist="Chaac Belt",legs="Volte Hose"} -- original: set_combine(sets.TreasureHunter, {}) (global set uses stored Wh. Rarab Cap +1)
	sets.precast.JA['Bounty Shot'] = set_combine(sets.TreasureHunter, {hands="Amini Glove. +3"}) -- Bounty Shot+4
	sets.precast.JA['Camouflage'] = {body="Orion Jerkin +1"}
	sets.precast.JA['Scavenge'] = {feet="Orion Socks +1"}
	sets.precast.JA['Shadowbind'] = {hands="Orion Bracers +1"}
	sets.precast.JA['Sharpshot'] = {legs="Orion Braccae +1"} -- original: "Orion Braccae +3" (you own the +1: Sharpshot+12)
	sets.precast.JA['Double Shot'] = {}  -- original: back=gear.tp_ranger_jse_back (Belenus's Cape, not owned)
	-- LINKTRI: Arcadian +1 (relic) and Amini +3 (empyrean) job ability pieces.
	sets.precast.JA['Eagle Eye Shot'] = {legs="Arc. Braccae +1"}       -- enhances Eagle Eye Shot
	sets.precast.JA['Flashy Shot'] = {hands="Arc. Bracers +1"}         -- enhances Flashy Shot
	sets.precast.JA['Stealth Shot'] = {feet="Arcadian Socks +1"}       -- enhances Stealth Shot
	sets.precast.JA['Unlimited Shot'] = {feet="Amini Bottillons +3"}   -- enhances Unlimited Shot

	-- Fast cast sets for spells (Baetyl 4, Etiolation 1, Dread Jupon 7, Sombra Mittens 3, Rawhide Trousers 5)
	-- original: Carmine Mask +1, Enchntr. Earring +1, Loquac. Earring, Leyline Gloves, Prolix Ring, Moonlight Cape,
	--           Flume Belt +1, Carmine Greaves +1 (not owned)
    sets.precast.FC = {
        head="Nyame Helm",neck="Baetyl Pendant",ear1="Alabaster Earring",ear2="Etiolation Earring",
        body="Dread Jupon",hands="Sombra Mittens",ring1="Defending Ring",ring2="Lebeche Ring",
        back="Null Shawl",waist="Null Belt",legs="Rawhide Trousers",feet="Nyame Sollerets"}

	sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Beads"}) -- original: + body="Passion Jacket" (not owned)


	-- Ranged sets (snapshot)

	-- LINKTRI: Snapshot 46% (see the header). Arc. Bracers +1 (4%) / Arc. Braccae +1 (5%) are lower than Ikenga's.
	-- Under Flurry II (+30%) the Vest swaps for Arc. Jerkin +1 (Rapid Shot+12%): 67%, under the cap.
	-- original: body="Amini Caban +3" (no Snapshot), hands="Carmine Fin. Ga. +1", waist="Impulse Belt" (not owned),
	--           legs="Orion Braccae +3" (you own the +1, no Snapshot)
	sets.precast.RA = {
		head="Amini Gapette +3",
		body="Ikenga's Vest",hands="Ikenga's Gloves",ring1="Crepuscular Ring",
		back=gear.snapshot_jse_back,legs="Ikenga's Trousers",feet="Meg. Jam. +2"}

	sets.precast.RA.Flurry = set_combine(sets.precast.RA, {})
	-- original Flurry2: head="Orion Beret +3", waist="Yemaya Belt", legs="Adhemar Kecks +1" (not owned)
	sets.precast.RA.Flurry2 = set_combine(sets.precast.RA, {body="Arc. Jerkin +1"})


	-- Weaponskill sets
	-- LINKTRI: physical ranged WS = Nyame + Meg. Gloves +2 (WSD+7%) + Amini Bottillons +3 (WSD+12%) + Ephramad's Ring
	-- (PDL+10%) + Amini Earring +2 (Sortie, ear2 only: PDL+9%). Moonshade always in ear1.
	-- original WS / WS.Acc: Orion Beret +3, Fotia Gorget, Moonshade, Telos, Meg. Cuirie +2, Meg. Gloves +2, Regal Ring,
	--                       Dingir Ring, Belenus's WSD cape, Fotia Belt, Meg. Chausses +2, Meg. Jam. +2
    sets.precast.WS = {
        head="Nyame Helm",neck="Null Loop",ear1="Moonshade Earring",ear2="Amini Earring +2",
        body="Nyame Mail",hands="Meg. Gloves +2",ring1="Ephramad's Ring",ring2="Dingir Ring",
        back=gear.wsd_ranger_jse_back,waist="Eschan Stone",legs="Nyame Flanchard",feet="Amini Bottillons +3"}

    sets.precast.WS.Acc = set_combine(sets.precast.WS, {waist="Null Belt"})

	-- Last Stand (Fusion/Reverberation): Light Gorget + Light Belt latents
    sets.precast.WS['Last Stand'] = set_combine(sets.precast.WS, {neck="Light Gorget",waist="Light Belt"})
    sets.precast.WS['Last Stand'].Acc = set_combine(sets.precast.WS['Last Stand'], {neck="Null Loop",waist="Null Belt"})

	-- Magical WS: Nyame (MAB+30 each), Orpheus's Sash.
	-- original Wildfire/Trueflight/Aeolian: Orion Beret +3, Sanctity Necklace, Friomisi, Samnuha Coat, Carmine/Leyline,
	--                                      Regal Ring, Gyve Trousers, Herculean nuke feet (most not owned)
    sets.precast.WS['Wildfire'] = {
        head="Nyame Helm",neck="Baetyl Pendant",ear1="Crematio Earring",ear2="Hecate's Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Ephramad's Ring",ring2="Dingir Ring",
        back=gear.wsd_ranger_jse_back,waist="Orpheus's Sash",legs="Nyame Flanchard",feet="Nyame Sollerets"}

    sets.precast.WS['Wildfire'].Acc = set_combine(sets.precast.WS['Wildfire'], {ring1="Crepuscular Ring"})

    sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS['Wildfire'], {ear1="Moonshade Earring",ring1="Metamor. Ring +1"})

    sets.precast.WS['Trueflight'] = set_combine(sets.precast.WS['Wildfire'], {ear1="Moonshade Earring"})

    sets.precast.WS['Trueflight'].Acc = set_combine(sets.precast.WS['Trueflight'], {ring1="Crepuscular Ring"})

	sets.precast.WS['Hot Shot'] = sets.precast.WS['Trueflight']
	sets.precast.WS['Hot Shot'].Acc = sets.precast.WS['Trueflight'].Acc

	-- Swap to these on Moonshade using WS if at 3000 TP (RNG.lua checks the Ranged/Magical versions first)
	sets.MaxTP = {ear1="Ishvara Earring"}            -- original: {}
	sets.AccMaxTP = {ear1="Crep. Earring"}           -- original: {}
	sets.RangedMaxTP = {ear1="Ishvara Earring"}
	sets.RangedAccMaxTP = {ear1="Crep. Earring"}
	sets.MagicalMaxTP = {ear1="Crematio Earring"}
	sets.MagicalAccMaxTP = {ear1="Crematio Earring"}

	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.


	--------------------------------------
	-- Midcast sets
	--------------------------------------

	-- Fast recast for spells
	-- original: Carmine Mask +1, Enchntr. Earring +1, Loquac. Earring, Leyline Gloves, Kishar Ring (not RNG), Moonlight Cape,
	--           Flume Belt +1, Carmine Greaves +1
    sets.midcast.FastRecast = set_combine(sets.precast.FC, {})

	-- Ranged sets
	-- LINKTRI: Amini +3 head/hands/legs (R.Acc+61~63, R.Atk+62~73, Store TP+11/12, DT-11/11/13) + Ikenga's Vest
	-- (Store TP+11, PDL+7%) + Malignance Boots. DT-44% while shooting. Telos kept for Store TP.
	-- original RA: Malignance set, Iskur Gorget, Enervating, Telos, Crepuscular, Ilabrat, Belenus's TP cape, Yemaya Belt
    sets.midcast.RA = {
        head="Amini Gapette +3",neck="Null Loop",ear1="Crep. Earring",ear2="Telos Earring",
        body="Ikenga's Vest",hands="Amini Glove. +3",ring1="Crepuscular Ring",ring2="Dingir Ring",
        back=gear.tp_ranger_jse_back,waist="Eschan Stone",legs="Amini Bragues +3",feet="Malignance Boots"}

	-- original RA.Acc: Malignance set, Iskur, Enervating, Telos, Regal Ring, Ilabrat, Yemaya Belt
    sets.midcast.RA.Acc = set_combine(sets.midcast.RA, {body="Amini Caban +3",ring1="Cacoethic Ring +1",waist="Null Belt",feet="Amini Bottillons +3"})

	-- Fodder (low-defense targets): more PDL. Amini Caban +3 PDL+10%, Amini Earring +2 PDL+9%.
	-- original RA.Fodder: Malignance set, Iskur, Dedition, Telos, Crepuscular, Ilabrat, Yemaya Belt
    sets.midcast.RA.Fodder = set_combine(sets.midcast.RA, {body="Amini Caban +3",ear2="Amini Earring +2"})

	--These sets will overlay based on accuracy level, regardless of other options.
	sets.buff.Camouflage = {body="Orion Jerkin +1"}
	sets.buff.Camouflage.Acc = {}
	sets.buff['Double Shot'] = {}  -- original: back=gear.tp_ranger_jse_back (Belenus's Cape, not owned)
	sets.buff['Double Shot'].Acc = {}
	sets.buff.Barrage = {hands="Orion Bracers +1"}         -- Barrage+2
	sets.buff['Velocity Shot'] = {body="Amini Caban +3"}   -- LINKTRI: Velocity Shot+11% (RNG.lua equips it while the buff is up)

	-- LINKTRI: no cure-received / refresh-received gear owned for RNG.
	-- original: Phalaina Locket, Buremte Gloves, Kunaji Ring, Gishdubar Sash (not owned)
	sets.Self_Healing = {}
	sets.Cure_Received = {}
	sets.Self_Refresh = {}

    sets.midcast.Utsusemi = sets.midcast.FastRecast

	--------------------------------------
	-- Idle/resting/defense/etc sets
	--------------------------------------

	-- Sets to return to when not performing an action.

	-- Resting sets
	sets.resting = {}

	-- Idle sets
	-- original idle: Malignance set, Loricate, Genmei, Sanare, Defending, Dark Ring, Moonlight Cape, Carrier's Sash
    sets.idle = {
        head="Null Masque",neck="Bathy Choker +1",ear1="Alabaster Earring",ear2="Odnowa Earring +1",
        body="Adamantite Armor",hands="Nyame Gauntlets",ring1="Defending Ring",ring2="Chirich Ring +1",
        back="Null Shawl",waist="Null Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}

    sets.idle.PDT = {
        head="Nyame Helm",neck="Loricate Torque +1",ear1="Alabaster Earring",ear2="Etiolation Earring",
        body="Adamantite Armor",hands="Nyame Gauntlets",ring1="Defending Ring",ring2="Murky Ring",
        back="Null Shawl",waist="Null Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}

    -- Defense sets
	-- original PDT/MDT/MEVA: Malignance set, Loricate / Warder's Charm +1, Genmei, Sanare, Defending, Dark/Shadow/Vengeful Ring,
	--                        Moonlight Cape, Flume Belt +1 / Carrier's Sash
    sets.defense.PDT = {
        head="Nyame Helm",neck="Loricate Torque +1",ear1="Alabaster Earring",ear2="Odnowa Earring +1",
        body="Adamantite Armor",hands="Nyame Gauntlets",ring1="Defending Ring",ring2="Murky Ring",
        back="Null Shawl",waist="Null Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}

    sets.defense.MDT = set_combine(sets.defense.PDT, {ear2="Etiolation Earring"})

    sets.defense.MEVA = {
        head="Nyame Helm",neck="Null Loop",ear1="Alabaster Earring",ear2="Etiolation Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Defending Ring",ring2="Murky Ring",
        back="Null Shawl",waist="Null Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}

    sets.Kiting = {ring2="Shneddick Ring +1"} -- original: legs="Carmine Cuisses +1" (not owned)
	sets.DayIdle = {}
	sets.NightIdle = {}
	-- sets.BulletPouch = {waist="Chr. Bul. Pouch"} -- LINKTRI: not owned

	-- Weapons sets
	-- LINKTRI: rebuilt around owned weapons. Melee hand: Gleti's Knife + Nusku Shield (R.Acc/R.Atk+20, Store TP+3).
	-- Magic: Malevolence (MAB+34, Magic Damage+118) with Vampirism as the dual-wield partner (/NIN or /DNC).
	sets.weapons.Gun = {main="Gleti's Knife",sub="Nusku Shield",range="Vanir Gun"}
	sets.weapons.Crossbow = {main="Gleti's Knife",sub="Nusku Shield",range="Gleti's Crossbow"}
	sets.weapons.Bow = {main="Gleti's Knife",sub="Nusku Shield",range="Hangaku-no-Yumi"}
	sets.weapons.Ullr = {main="Gleti's Knife",sub="Nusku Shield",range="Ullr"}
	sets.weapons.MagicGun = {main="Malevolence",sub="Nusku Shield",range="Vanir Gun"}
	sets.weapons.DualMagicGun = {main="Malevolence",sub="Vampirism",range="Vanir Gun"}
	-- original weapon sets (Kustawi +1, Kustawi, Fomalhaut, Blurred Knife +1, Naegling, Tauret are not in your RNG inventory):
	-- sets.weapons.Default = {main="Kustawi +1",sub="Nusku Shield",range="Fomalhaut"}
	-- sets.weapons.DualWeapons = {main="Kustawi +1",sub="Kustawi",range="Fomalhaut"}
	-- sets.weapons.DualSavageWeapons = {main="Naegling",sub="Blurred Knife +1",range="Fomalhaut"}
	-- sets.weapons.DualEviscerationWeapons = {main="Tauret",sub="Blurred Knife +1",range="Fomalhaut"}
	-- sets.weapons.DualMalevolence = {main="Malevolence",sub="Malevolence",range="Fomalhaut"}
	-- sets.weapons.DualMagicWeapons = {main="Tauret",sub="Naegling",range="Fomalhaut"}

	--------------------------------------
	-- Engaged sets
	--------------------------------------

    -- Normal melee group
	-- original engaged: Dampening Tam, Iskur, Cessance, Brutal, Malignance Tabard, Adhemar Wrist. +1, Epona's, Petrov,
	--                   Belenus's cape, Windbuffet Belt +1, Samnuha Tights, Herculean TA feet
    sets.engaged = {
		head="Dampening Tam",neck="Anu Torque",ear1="Sherida Earring",ear2="Telos Earring",
		body="Malignance Tabard",hands="Adhemar Wrist. +1",ring1="Epona's Ring",ring2="Chirich Ring +1",
		back="Null Shawl",waist="Sailfi Belt +1",legs="Samnuha Tights",feet="Malignance Boots"}

	-- original Acc: Combatant's Torque, Cessance, Telos, Olseni Belt (not owned) on the engaged set
    sets.engaged.Acc = set_combine(sets.engaged, {head="Malignance Chapeau",neck="Null Loop",ring1="Cacoethic Ring +1"})

	-- original DTLite: Malignance + Iskur, Cessance, Brutal, Epona's, Petrov, Windbuffet Belt +1
    sets.engaged.DTLite = set_combine(sets.engaged, {head="Malignance Chapeau",hands="Malignance Gloves",legs="Malignance Tights"})

	-- DT-56%: Malignance set 31 + Null Loop 5 + Defending 10 + Murky 10
	-- original DT: Malignance + Loricate, Cessance, Brutal, Defending, Dark Ring, Windbuffet Belt +1
    sets.engaged.DT = {
		head="Malignance Chapeau",neck="Null Loop",ear1="Sherida Earring",ear2="Telos Earring",
		body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",ring2="Murky Ring",
		back="Null Shawl",waist="Sailfi Belt +1",legs="Malignance Tights",feet="Malignance Boots"}

	-- Dual wield (/NIN or /DNC): Suppanomimi DW+5, Floral Gauntlets DW+5
	-- original DW: Dampening Tam, Asperity, Cessance, Brutal, Adhemar Jacket +1, Floral Gauntlets, Epona's, Petrov,
	--              Windbuffet Belt +1, Samnuha Tights, Herculean TA feet
    sets.engaged.DW = set_combine(sets.engaged, {ear1="Suppanomimi",hands="Floral Gauntlets"})

    sets.engaged.DW.DT = set_combine(sets.engaged.DT, {ear1="Suppanomimi"})

	-- original DW.Acc: Combatant's Torque, Digni. Earring, Telos, Adhemar Jacket +1, Floral Gauntlets, Ramuh Ring +1 x2,
	--                  Olseni Belt, Meg. Chausses +2
    sets.engaged.DW.Acc = set_combine(sets.engaged.Acc, {ear1="Suppanomimi",hands="Floral Gauntlets"})

	--------------------------------------
	-- Custom buff sets
	--------------------------------------
	sets.buff.Doom = set_combine(sets.buff.Doom, {})

	sets.packing = {
		head  = "Nyame Helm",
		neck  = "Loricate Torque +1",
		ear1  = "Alabaster Earring",   -- original: "Genmei Earring"
		ear2  = "Etiolation Earring",  -- original: "Sanare Earring"
		body  = "Nyame Mail",
		hands = "Nyame Gauntlets",
		ring1 = "Defending Ring",
		ring2 = "Murky Ring",          -- original: "Dark Ring" (not owned)
		back  = "Null Shawl",          -- original: "Moonlight Cape" (not owned)
		waist = "Fucho-no-obi",
		legs  = "Nyame Flanchard",
		feet  = "Nyame Sollerets"
	}
end

-- LINKTRI: renamed from job_customize_idle_set (RNG.lua doesn't define one, but this keeps the PorterPacker
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
    if player.sub_job == 'NIN' then
        set_macro_page(1, 11)
    elseif player.sub_job == 'DNC' then
		set_macro_page(1, 11)
    elseif player.sub_job == 'DRG' then
        set_macro_page(3, 11)
    else
        set_macro_page(1, 11)
    end
end

-- LINKTRI: auto-WS per weapon set (RNG.lua's default is Last Stand).
autows_list = {
	['Gun'] = 'Last Stand',
	['Crossbow'] = 'Last Stand',
	['Ullr'] = 'Empyreal Arrow',
	['MagicGun'] = 'Trueflight',
	['DualMagicGun'] = 'Trueflight'
}
