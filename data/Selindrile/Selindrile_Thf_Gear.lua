-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_job_setup()
	-- Options: Override default values
    state.OffenseMode:options('Normal','SomeAcc','Acc','FullAcc','Fodder')
    state.HybridMode:options('Normal','DT')
    state.RangedMode:options('Normal', 'Acc')
    state.WeaponskillMode:options('Match','Normal','DT','SomeAcc','Acc','FullAcc','Fodder','Proc')
	state.IdleMode:options('Normal', 'Sphere')
    state.PhysicalDefenseMode:options('PDT')
	state.MagicalDefenseMode:options('MDT')
	state.ResistDefenseMode:options('MEVA')
	state.Weapons:options('Aeneas','Vajra','Tauret','Prime','Savage','ProcWeapons','Evisceration','Throwing','SwordThrowing','Bow')

    state.ExtraMeleeMode = M{['description']='Extra Melee Mode','None','Suppa','DWMax','Parry'}
	state.AmbushMode = M(false, 'Ambush Mode')

	gear.da_jse_back = {name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10',}}
	gear.wsd_jse_back = {name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Weapon skill damage +10%',}}

    -- Additional local binds
    send_command('bind ^` input /ja "Flee" <me>')
    send_command('bind !` input /ra <t>')
	send_command('bind @` gs c cycle SkillchainMode')
	send_command('bind @f10 gs c toggle AmbushMode')
	send_command('bind ^backspace input /item "Thief\'s Tools" <t>')
	send_command('bind ^q gs c weapons ProcWeapons;gs c set WeaponSkillMode proc;')
	send_command('bind !q gs c weapons SwordThrowing')
	send_command('bind !backspace input /ja "Hide" <me>')
	send_command('bind ^r gs c weapons Default;gs c set WeaponSkillMode match') --Requips weapons and gear.
	send_command('bind !r gs c weapons MagicWeapons')
	send_command('bind ^\\\\ input /ja "Despoil" <t>')
	send_command('bind !\\\\ input /ja "Mug" <t>')

    select_default_macro_book()
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Special sets (required by rules)
    --------------------------------------

	sets.TreasureHunter = {waist="Chaac Belt"}
    sets.Kiting = {}

	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = {}
	
    sets.buff['Sneak Attack'] = {}
    sets.buff['Trick Attack'] = {hands="Pill. Armlets +2"}

    -- Extra Melee sets.  Apply these on top of melee sets.
    sets.Knockback = {}
	sets.Suppa = {ear1="Suppanomimi", ear2="Sherida Earring"}
	sets.DWEarrings = {ear1="Dudgeon Earring",ear2="Heartseeker Earring"}
	sets.DWMax = {ear1="Dudgeon Earring",ear2="Heartseeker Earring",hands="Floral Gauntlets"}
	sets.Parry = {ring1="Defending Ring"}
	sets.Ambush = {}
	
	-- Weapons sets - based on available gear only
	sets.weapons.Aeneas = {main="Aeneas",sub="Gleti's Knife"}
	sets.weapons.Vajra = {main="Vajra",sub="Gleti's Knife"}
	sets.weapons.Tauret = {main="Tauret",sub="Gleti's Knife"}
	sets.weapons.Prime = {main="Mpu Gandring",sub="Gleti's Knife"}
	sets.weapons.Savage = {main="Naegling",sub="Gleti's Knife"}
	sets.weapons.ProcWeapons = {main="Qutrub Knife",sub="Kodachi"}
	sets.weapons.Evisceration = {main="Tauret",sub="Gleti's Knife"}
	sets.weapons.Throwing = {main="Aeneas",sub="Gleti's Knife"}
	sets.weapons.SwordThrowing = {main="Naegling",sub="Gleti's Knife"}
	sets.weapons.Bow = {main="Aeneas",sub="Ternion Dagger +1",range="Kaja Bow",ammo="Jukukik Feather"}
	
    -- Actions we want to use to tag TH.
    sets.precast.Step = {
        head="Malignance Chapeau",neck="Combatant's Torque",ear1="Mache Earring +1",ear2="Odr Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Ramuh Ring +1",ring2="Ramuh Ring +1",
        back=gear.da_jse_back,waist="Chaac Belt",legs="Malignance Tights",feet="Malignance Boots"}
		
    sets.precast.JA['Violent Flourish'] = {
        head="Malignance Chapeau",neck="Combatant's Torque",ear1="Odr Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Ramuh Ring +1",ring2="Ramuh Ring +1",
        back=gear.da_jse_back,waist="Chaac Belt",legs="Malignance Tights",feet="Malignance Boots"}
		
	sets.precast.JA['Animated Flourish'] = sets.TreasureHunter
	sets.precast.JA.Provoke = sets.TreasureHunter

    --------------------------------------
    -- Precast sets
    --------------------------------------

    -- Precast sets to enhance JAs
    sets.precast.JA['Collaborator'] = {head="Skulker's Bonnet +3"}
    sets.precast.JA['Accomplice'] = {head="Skulker's Bonnet +3"}
    sets.precast.JA['Flee'] = {feet="Pill. Poulaines +3"}
    sets.precast.JA['Hide'] = {body="Pillager's Vest +2"}
    sets.precast.JA['Conspirator'] = {body="Skulker's Vest +3"} 
    sets.precast.JA['Steal'] = {feet="Pill. Poulaines +3"}
	sets.precast.JA['Mug'] = {}
    sets.precast.JA['Despoil'] = {legs="Skulk. Culottes +3"}
    sets.precast.JA['Perfect Dodge'] = {hands="Plun. Armlets +3"}
    sets.precast.JA['Feint'] = {legs="Plun. Culottes +3"}

    sets.precast.JA['Sneak Attack'] = sets.buff['Sneak Attack']
    sets.precast.JA['Trick Attack'] = sets.buff['Trick Attack']

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {
        head="Mummu Bonnet +2",neck="Unmoving Collar",
        body="Passion Jacket",ring1="Defending Ring",
        back="Moonlight Cape",waist="Chaac Belt",legs="Dashing Subligar"}

	sets.Self_Waltz = {head="Mummu Bonnet +2",body="Passion Jacket"}
		
    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz['Healing Waltz'] = {}

    -- Fast cast sets for spells
    sets.precast.FC = {ammo="Impatiens",
		neck="Voltsurge Torque",ear1="Loquac. Earring",
		body="Dread Jupon",hands="Leyline Gloves",ring1="Lebeche Ring",ring2="Prolix Ring",
		legs="Rawhide Trousers"}

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Beads",body="Passion Jacket"})

    -- Ranged snapshot gear
    sets.precast.RA = {}

    -- Weaponskill sets

    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        head="Pill. Bonnet +2",neck="Fotia Gorget",ear1="Brutal Earring",ear2="Sherida Earring",
        body="Pillager's Vest +2",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.da_jse_back,waist="Fotia Belt",legs="Samnuha Tights"}
    sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {neck="Combatant's Torque"})
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {neck="Combatant's Torque",ear1="Mache Earring +1",ear2="Odr Earring",waist="Olseni Belt",feet="Malignance Boots"})
	sets.precast.WS.FullAcc = set_combine(sets.precast.WS, {neck="Combatant's Torque",ear1="Mache Earring +1",ear2="Odr Earring",waist="Olseni Belt",feet="Malignance Boots"})

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS["Rudra's Storm"] = set_combine(sets.precast.WS, {
        head="Pill. Bonnet +2",neck="Caro Necklace",ear1="Moonshade Earring",ear2="Odr Earring",
        body="Pillager's Vest +2",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.wsd_jse_back,waist="Grunfeld Rope",legs="Pill. Culottes +2"})
    sets.precast.WS["Rudra's Storm"].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {neck="Caro Necklace",ear1="Moonshade Earring",back=gear.wsd_jse_back})
    sets.precast.WS["Rudra's Storm"].Acc = set_combine(sets.precast.WS.Acc, {ear1="Moonshade Earring",back=gear.wsd_jse_back})
	sets.precast.WS["Rudra's Storm"].FullAcc = set_combine(sets.precast.WS.FullAcc, {back=gear.wsd_jse_back})
    sets.precast.WS["Rudra's Storm"].Fodder = set_combine(sets.precast.WS["Rudra's Storm"], {})
	sets.precast.WS["Rudra's Storm"].DT = set_combine(sets.precast.WS["Rudra's Storm"],{neck="Loricate Torque +1",ring1="Defending Ring"})
    sets.precast.WS["Rudra's Storm"].SA = set_combine(sets.precast.WS["Rudra's Storm"].Fodder, {legs="Pill. Culottes +2"})
    sets.precast.WS["Rudra's Storm"].TA = set_combine(sets.precast.WS["Rudra's Storm"].Fodder, {hands="Pill. Armlets +2",legs="Pill. Culottes +2"})
    sets.precast.WS["Rudra's Storm"].SATA = set_combine(sets.precast.WS["Rudra's Storm"].Fodder, {hands="Pill. Armlets +2",legs="Pill. Culottes +2"})

    sets.precast.WS["Mandalic Stab"] = set_combine(sets.precast.WS, {
        head="Pill. Bonnet +2",neck="Caro Necklace",ear1="Moonshade Earring",ear2="Ishvara Earring",
        body="Pillager's Vest +2",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.wsd_jse_back,waist="Grunfeld Rope",legs="Pill. Culottes +2"})
    sets.precast.WS["Mandalic Stab"].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {neck="Caro Necklace",ear1="Moonshade Earring",back=gear.wsd_jse_back})
    sets.precast.WS["Mandalic Stab"].Acc = set_combine(sets.precast.WS.Acc, {ear1="Moonshade Earring",back=gear.wsd_jse_back})
	sets.precast.WS["Mandalic Stab"].FullAcc = set_combine(sets.precast.WS.FullAcc, {back=gear.wsd_jse_back})
    sets.precast.WS["Mandalic Stab"].Fodder = set_combine(sets.precast.WS["Mandalic Stab"], {})
    sets.precast.WS["Mandalic Stab"].SA = set_combine(sets.precast.WS["Mandalic Stab"].Fodder, {legs="Pill. Culottes +2"})
    sets.precast.WS["Mandalic Stab"].TA = set_combine(sets.precast.WS["Mandalic Stab"].Fodder, {hands="Pill. Armlets +2",legs="Pill. Culottes +2"})
    sets.precast.WS["Mandalic Stab"].SATA = set_combine(sets.precast.WS["Mandalic Stab"].Fodder, {hands="Pill. Armlets +2",legs="Pill. Culottes +2"})

    sets.precast.WS["Shark Bite"] = set_combine(sets.precast.WS, {
        head="Pill. Bonnet +2",neck="Caro Necklace",ear1="Moonshade Earring",ear2="Ishvara Earring",
        body="Pillager's Vest +2",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.wsd_jse_back,waist="Grunfeld Rope",legs="Pill. Culottes +2"})
    sets.precast.WS["Shark Bite"].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {neck="Caro Necklace",ear1="Moonshade Earring",back=gear.wsd_jse_back})
    sets.precast.WS["Shark Bite"].Acc = set_combine(sets.precast.WS.Acc, {ear1="Moonshade Earring",back=gear.wsd_jse_back})
	sets.precast.WS["Shark Bite"].FullAcc = set_combine(sets.precast.WS.FullAcc, {back=gear.wsd_jse_back})
    sets.precast.WS["Shark Bite"].Fodder = set_combine(sets.precast.WS["Shark Bite"], {})
    sets.precast.WS["Shark Bite"].SA = set_combine(sets.precast.WS["Shark Bite"].Fodder, {legs="Pill. Culottes +2"})
    sets.precast.WS["Shark Bite"].TA = set_combine(sets.precast.WS["Shark Bite"].Fodder, {hands="Pill. Armlets +2",legs="Pill. Culottes +2"})
    sets.precast.WS["Shark Bite"].SATA = set_combine(sets.precast.WS["Shark Bite"].Fodder, {hands="Pill. Armlets +2",legs="Pill. Culottes +2"})
	
    sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {
        neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Odr Earring",
        hands="Mummu Wrists +2",ring1="Begrudging Ring",
        waist="Fotia Belt",legs="Pill. Culottes +2",feet="Mummu Gamash. +2"})
    sets.precast.WS['Evisceration'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {ear1="Moonshade Earring",ear2="Odr Earring",neck="Fotia Gorget",hands="Mummu Wrists +2",ring1="Begrudging Ring",waist="Fotia Belt",legs="Mummu Kecks +2",feet="Mummu Gamash. +2"})
    sets.precast.WS['Evisceration'].Acc = set_combine(sets.precast.WS.Acc, {head="Mummu Bonnet +2",ring1="Begrudging Ring",neck="Fotia Gorget",hands="Mummu Wrists +2",waist="Fotia Belt",legs="Mummu Kecks +2",feet="Mummu Gamash. +2"})
	sets.precast.WS['Evisceration'].FullAcc = set_combine(sets.precast.WS.FullAcc, {head="Mummu Bonnet +2",body="Mummu Jacket +2",hands="Mummu Wrists +2",legs="Mummu Kecks +2",feet="Mummu Gamash. +2"})
	sets.precast.WS['Evisceration'].Fodder = set_combine(sets.precast.WS['Evisceration'], {})
	
    sets.precast.WS["Savage Blade"] = set_combine(sets.precast.WS, {
        head="Pill. Bonnet +2",neck="Caro Necklace",ear1="Moonshade Earring",ear2="Ishvara Earring",
        body="Pillager's Vest +2",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.wsd_jse_back,waist="Sailfi Belt +1",legs="Pill. Culottes +2"})
    sets.precast.WS["Savage Blade"].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {neck="Caro Necklace",ear1="Moonshade Earring",back=gear.wsd_jse_back})
    sets.precast.WS["Savage Blade"].Acc = set_combine(sets.precast.WS.Acc, {ear1="Moonshade Earring",back=gear.wsd_jse_back})
	sets.precast.WS["Savage Blade"].FullAcc = set_combine(sets.precast.WS.FullAcc, {back=gear.wsd_jse_back})
    sets.precast.WS["Savage Blade"].Fodder = set_combine(sets.precast.WS["Savage Blade"],{waist="Sailfi Belt +1"})
	sets.precast.WS["Savage Blade"].DT = set_combine(sets.precast.WS["Savage Blade"],{neck="Loricate Torque +1",ring1="Defending Ring"})
    sets.precast.WS["Savage Blade"].SA = set_combine(sets.precast.WS["Savage Blade"].Fodder, {legs="Pill. Culottes +2"})
    sets.precast.WS["Savage Blade"].TA = set_combine(sets.precast.WS["Savage Blade"].Fodder, {legs="Pill. Culottes +2"})
    sets.precast.WS["Savage Blade"].SATA = set_combine(sets.precast.WS["Savage Blade"].Fodder, {legs="Pill. Culottes +2"})

    sets.precast.WS.Proc = {
        head="Malignance Chapeau",neck="Voltsurge Torque",ear1="Heartseeker Earring",
        body="Malignance Tabard",hands="Malignance Gloves",
        waist="Chaac Belt",legs="Malignance Tights",feet="Malignance Boots"}

    sets.precast.WS['Last Stand'] = {ammo="Jukukik Feather",
        head="Pill. Bonnet +2",neck="Fotia Gorget",ear1="Telos Earring",ear2="Enervating Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.wsd_jse_back,waist="Fotia Belt",legs="Malignance Tights",feet="Malignance Boots"}
		
    sets.precast.WS['Empyreal Arrow'] = {ammo="Jukukik Feather",
        head="Pill. Bonnet +2",neck="Fotia Gorget",ear1="Telos Earring",ear2="Enervating Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.wsd_jse_back,waist="Fotia Belt",legs="Malignance Tights",feet="Malignance Boots"}
		
    sets.precast.WS['Aeolian Edge'] = {
        neck="Baetyl Pendant",ear1="Friomisi Earring",ear2="Crematio Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Metamor. Ring +1",
        back=gear.wsd_jse_back,waist="Chaac Belt",legs="Nyame Flanchard"}

    sets.precast.WS['Aeolian Edge'].TH = set_combine(sets.precast.WS['Aeolian Edge'], sets.TreasureHunter)

	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {ear1="Ishvara Earring",ear2="Sherida Earring"}
	sets.AccMaxTP = {ear1="Mache Earring +1",ear2="Sherida Earring"}

    --------------------------------------
    -- Midcast sets
    --------------------------------------

    sets.midcast.FastRecast = {
        neck="Voltsurge Torque",ear1="Loquac. Earring",
        body="Dread Jupon",hands="Leyline Gloves",ring1="Defending Ring",ring2="Prolix Ring",
        back="Moonlight Cape",legs="Rawhide Trousers",feet="Malignance Boots"}

    -- Specific spells
	sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {})

	sets.midcast.Dia = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
	sets.midcast.Diaga = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
	sets.midcast['Dia II'] = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
	sets.midcast.Bio = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
	sets.midcast['Bio II'] = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)

    -- Ranged gear
    sets.midcast.RA = {ammo="Jukukik Feather",
        head="Malignance Chapeau",neck="Iskur Gorget",ear1="Telos Earring",ear2="Enervating Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.da_jse_back,waist="Chaac Belt",legs="Malignance Tights",feet="Malignance Boots"}

    sets.midcast.RA.Acc = {ammo="Jukukik Feather",
        head="Malignance Chapeau",neck="Iskur Gorget",ear1="Telos Earring",ear2="Enervating Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.da_jse_back,waist="Chaac Belt",legs="Malignance Tights",feet="Malignance Boots"}

    --------------------------------------
    -- Idle/resting/defense sets
    --------------------------------------

    -- Resting sets
    sets.resting = {}

    -- Idle sets
    sets.idle = {
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Sanare Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",
        back="Moonlight Cape",legs="Malignance Tights",feet="Malignance Boots"}
		
    sets.idle.Sphere = set_combine(sets.idle, {})

    sets.idle.Weak = set_combine(sets.idle, {})

	sets.DayIdle = {}
	sets.NightIdle = {}
	sets.ExtraRegen = {}

    -- Defense sets
    sets.defense.PDT = {
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Sanare Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",
        back="Moonlight Cape",legs="Malignance Tights",feet="Malignance Boots"}

    sets.defense.MDT = {
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Sanare Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",
        back="Moonlight Cape",legs="Malignance Tights",feet="Malignance Boots"}
		
	sets.defense.MEVA = {
		neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Sanare Earring",
		hands="Malignance Gloves",ring1="Defending Ring",
		legs="Malignance Tights",feet="Malignance Boots"}

    --------------------------------------
    -- Melee sets  
    --------------------------------------

    -- Normal melee group
    sets.engaged = {
        head="Dampening Tam",neck="Iskur Gorget",ear1="Dedition Earring",ear2="Sherida Earring",
        hands="Floral Gauntlets",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.da_jse_back,legs="Samnuha Tights"}
		
    sets.engaged.SomeAcc = {
        head="Dampening Tam",neck="Combatant's Torque",ear1="Brutal Earring",ear2="Sherida Earring",
        body="Pillager's Vest +2",hands="Floral Gauntlets",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.da_jse_back,legs="Samnuha Tights"}
    
	sets.engaged.Acc = {
        head="Pill. Bonnet +2",neck="Combatant's Torque",ear1="Telos Earring",ear2="Sherida Earring",
        body="Pillager's Vest +2",hands="Floral Gauntlets",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.da_jse_back,waist="Olseni Belt",legs="Pill. Culottes +2",feet="Malignance Boots"}
		
    sets.engaged.FullAcc = {
        head="Pill. Bonnet +2",neck="Combatant's Torque",ear1="Mache Earring +1",ear2="Odr Earring",
        body="Pillager's Vest +2",hands="Pill. Armlets +2",ring1="Ramuh Ring +1",ring2="Regal Ring",
        back=gear.da_jse_back,waist="Olseni Belt",legs="Pill. Culottes +2",feet="Malignance Boots"}

    sets.engaged.Fodder = {
        head="Dampening Tam",neck="Iskur Gorget",ear1="Dedition Earring",ear2="Sherida Earring",
        hands="Floral Gauntlets",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.da_jse_back,legs="Samnuha Tights"}

    sets.engaged.DT = {
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Brutal Earring",ear2="Sherida Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",
        back=gear.da_jse_back,legs="Malignance Tights",feet="Malignance Boots"}

    sets.engaged.SomeAcc.DT = {
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Suppanomimi",ear2="Sherida Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",
        back="Moonlight Cape",legs="Malignance Tights",feet="Malignance Boots"}
		
    sets.engaged.Acc.DT = {
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Suppanomimi",ear2="Odr Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",
        back="Moonlight Cape",legs="Malignance Tights",feet="Malignance Boots"}

    sets.engaged.FullAcc.DT = {
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Suppanomimi",ear2="Odr Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",
        back="Moonlight Cape",legs="Malignance Tights",feet="Malignance Boots"}
		
    sets.engaged.Fodder.DT = {
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Suppanomimi",ear2="Sherida Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",
        back="Moonlight Cape",legs="Malignance Tights",feet="Malignance Boots"}

    -- Aftermath sets for Vajra
    sets.engaged.AM = {
        head="Dampening Tam",neck="Iskur Gorget",ear1="Dedition Earring",ear2="Sherida Earring",
        hands="Floral Gauntlets",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.da_jse_back,legs="Samnuha Tights"}
		
    sets.engaged.AM.SomeAcc = {
        head="Dampening Tam",neck="Combatant's Torque",ear1="Dedition Earring",ear2="Sherida Earring",
        body="Pillager's Vest +2",hands="Floral Gauntlets",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.da_jse_back,legs="Samnuha Tights"}
		
    sets.engaged.AM.Acc = {
        head="Pill. Bonnet +2",neck="Combatant's Torque",ear1="Telos Earring",ear2="Sherida Earring",
        body="Pillager's Vest +2",hands="Floral Gauntlets",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.da_jse_back,waist="Olseni Belt",legs="Pill. Culottes +2",feet="Malignance Boots"}
		
    sets.engaged.AM.FullAcc = {
        head="Pill. Bonnet +2",neck="Combatant's Torque",ear1="Mache Earring +1",ear2="Odr Earring",
        body="Pillager's Vest +2",hands="Pill. Armlets +2",ring1="Ramuh Ring +1",ring2="Regal Ring",
        back=gear.da_jse_back,waist="Olseni Belt",legs="Pill. Culottes +2",feet="Malignance Boots"}
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book - THF uses book 6, page 1 for all subjobs
    set_macro_page(1, 6)
end

function user_job_lockstyle()
	if player.equipment.main == nil or player.equipment.main == 'empty' then
		windower.chat.input('/lockstyleset 001')
	elseif res.items[item_name_to_id(player.equipment.main)].skill == 3 then --Sword in main hand.
		if player.equipment.sub == nil or player.equipment.sub == 'empty' then --Sword/Nothing.
				windower.chat.input('/lockstyleset 007')
		elseif res.items[item_name_to_id(player.equipment.sub)].skill == 2 then --Sword/Dagger.
			windower.chat.input('/lockstyleset 007')
		else
			windower.chat.input('/lockstyleset 007') --Catchall just in case something's weird.
		end
	elseif res.items[item_name_to_id(player.equipment.main)].skill == 2 then --Dagger in main hand.
		if player.equipment.sub == nil or player.equipment.sub == 'empty' then --Dagger/Nothing.
			windower.chat.input('/lockstyleset 008')
		elseif res.items[item_name_to_id(player.equipment.sub)].skill == 2 then --Dagger/Dagger.
			windower.chat.input('/lockstyleset 008')
		else
			windower.chat.input('/lockstyleset 008') --Catchall just in case something's weird.
		end
	end
end

    -- Ruthless Stroke (Prime WS) sets
    sets.precast.WS["Ruthless Stroke"] = set_combine(sets.precast.WS, {
        head="Pill. Bonnet +2",neck="Caro Necklace",ear1="Moonshade Earring",ear2="Odr Earring",
        body="Pillager's Vest +2",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.wsd_jse_back,waist="Grunfeld Rope",legs="Pill. Culottes +2"})
    sets.precast.WS["Ruthless Stroke"].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {neck="Caro Necklace",ear1="Moonshade Earring",back=gear.wsd_jse_back})
    sets.precast.WS["Ruthless Stroke"].Acc = set_combine(sets.precast.WS.Acc, {ear1="Moonshade Earring",back=gear.wsd_jse_back})
    sets.precast.WS["Ruthless Stroke"].FullAcc = set_combine(sets.precast.WS.FullAcc, {back=gear.wsd_jse_back})
    sets.precast.WS["Ruthless Stroke"].Fodder = set_combine(sets.precast.WS["Ruthless Stroke"], {})
    sets.precast.WS["Ruthless Stroke"].DT = set_combine(sets.precast.WS["Ruthless Stroke"],{neck="Loricate Torque +1",ring1="Defending Ring"})
    sets.precast.WS["Ruthless Stroke"].SA = set_combine(sets.precast.WS["Ruthless Stroke"].Fodder, {legs="Pill. Culottes +2"})
    sets.precast.WS["Ruthless Stroke"].TA = set_combine(sets.precast.WS["Ruthless Stroke"].Fodder, {hands="Pill. Armlets +2",legs="Pill. Culottes +2"})
    sets.precast.WS["Ruthless Stroke"].SATA = set_combine(sets.precast.WS["Ruthless Stroke"].Fodder, {hands="Pill. Armlets +2",legs="Pill. Culottes +2"})

autows_list = {['Aeneas']="Rudra's Storm",['Vajra']="Mandalic Stab",['Tauret']='Evisceration',['Prime']="Ruthless Stroke",['Savage']='Savage Blade',['Throwing']="Rudra's Storm",['SwordThrowing']='Savage Blade',['Evisceration']='Evisceration',['ProcWeapons']='Wasp Sting',['Bow']='Empyreal Arrow'}