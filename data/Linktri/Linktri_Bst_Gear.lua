function user_job_setup()
	state.OffenseMode:options('Normal','SomeAcc','Acc','FullAcc','Fodder')
	state.HybridMode:options('Normal','PDT','PetTank','BothDD')
	state.WeaponskillMode:options('Match','Normal', 'SomeAcc', 'Acc', 'FullAcc', 'Fodder')
	state.CastingMode:options('Normal')
	state.IdleMode:options('Normal', 'Refresh', 'Reraise','SingleWield')
	state.RestingMode:options('Normal')
	state.PhysicalDefenseMode:options('PetPDT', 'PDT', 'Reraise', 'PKiller')
	state.MagicalDefenseMode:options('PetMDT','MDT', 'MKiller')
	state.ResistDefenseMode:options('PetMEVA', 'MEVA')
	-- LINKTRI: PetPDTAxe = Agwu's Axe (pet stats), MasterAxe = Ikenga's Axe (crit/TP Bonus), DualWeapons = both.
	state.Weapons:options('None','PetPDTAxe','MasterAxe','DualWeapons')
	state.ExtraMeleeMode = M{['description']='Extra Melee Mode','None','Knockback','Suppa','DWEarrings'}

	-- Set up Jug Pet cycling and keybind Ctrl+F7
	-- INPUT PREFERRED JUG PETS HERE
	state.JugMode = M{['description']='Jug Mode','FatsoFargann','ScissorlegXerin','BlackbeardRandy','AttentiveIbuki','DroopyDortwin','WarlikePatrick','AcuexFamiliar','GenerousArthur','PonderingPeter','SlimeFamiliar'}
	send_command('bind ^f7 gs c cycle JugMode')

	-- Set up Monster Correlation Modes and keybind Alt+F7
	state.CorrelationMode = M{['description']='Correlation Mode', 'Neutral', 'Favorable'}
	send_command('bind !f7 gs c cycle CorrelationMode')

	-- Set up Pet Modes for Hybrid sets and keybind 'Windows Key'+F7
	state.PetMode = M{['description']='Pet Mode','Tank','DD'}
	send_command('bind @f7 gs c cycle PetMode')

	-- Set up Reward Modes and keybind Ctrl+Backspace
	state.RewardMode = M{['description']='Reward Mode', 'Theta', 'Zeta', 'Eta'}
	send_command('bind ^backspace gs c cycle RewardMode')

	send_command('bind @f8 gs c toggle AutoReadyMode')
	send_command('bind !` gs c ready default')

	select_default_macro_book()
end

-- BST gearsets
-- LINKTRI REBUILD 2026-10-14: every set below rebuilt from the Oct 14 BST inventory export, with each item
-- checked for BST equippability against the game client data. The previous version referenced a lot of
-- unowned gear (Artio's Mantle, Kumbhakarna, Izizoeksi, Ankusa, Nukumi +1, ...) and some non-BST gear
-- (Bunzi's, Kaykaus, Kishar Ring, Lugh's Cape, Malignance Earring).
-- Weapons are never part of JA/Ready sets: a main/sub swap wipes your TP. Pick weapons with the Weapons mode.
function init_gear_sets()
	-- PRECAST SETS
	sets.precast.JA['Killer Instinct'] = {}
	-- "Summoned Pet: Lv.+1" pieces worn while calling the jug pet.
	sets.precast.JA['Bestial Loyalty'] = {ear2="Nukumi Earring +1",feet="Gleti's Boots"}
	sets.precast.JA['Call Beast'] = sets.precast.JA['Bestial Loyalty']
	sets.precast.JA.Familiar = {}
	sets.precast.JA.Tame = {head="Totemic Helm +1"}
	sets.precast.JA.Spur = {feet="Nukumi Ocreae +3"} -- "Spur"+21
	sets.SpurAxe = {}     -- no Spur axe owned; empty so Spur never swaps your weapon (TP-safe)
	sets.SpurAxesDW = {}

	sets.precast.JA['Feral Howl'] = {}

	-- Reward: potency scales with MND; Totemic pieces add "Reward"+ and cut its recast.
	sets.precast.JA.Reward = {
		head="Null Masque",neck="Loricate Torque +1",ear1="Alabaster Earring",ear2="Odnowa Earring +1",
		body="Tot. Jackcoat +1",hands="Malignance Gloves",ring1="Metamor. Ring +1",ring2="Stikini Ring",
		back="Pastoralist's Mantle",waist="Null Belt",legs="Tot. Trousers +1",feet="Tot. Gaiters +1"}
	sets.precast.JA.Reward.ear2 = "Hoxne Earring" -- MR7 all stats +15 (MND for Reward potency); original: ear2="Odnowa Earring +1"

	sets.precast.JA.Reward.Theta = set_combine(sets.precast.JA.Reward, {ammo="Pet Food Theta"})
	sets.precast.JA.Reward.Zeta = set_combine(sets.precast.JA.Reward, {ammo="Pet Food Zeta"})
	sets.precast.JA.Reward.Eta = set_combine(sets.precast.JA.Reward, {ammo="Pet Food Eta"})

	sets.RewardAxe = {}
	sets.RewardAxesDW = {}

	sets.precast.JA.Charm = {}

	-- CURING WALTZ (Gleti's Cuirass and Dashing Subligar: "Waltz" potency +10% each)
	sets.precast.Waltz = {
		head="Nyame Helm",neck="Loricate Torque +1",ear1="Alabaster Earring",ear2="Odnowa Earring +1",
		body="Gleti's Cuirass",hands="Nyame Gauntlets",ring1="Defending Ring",ring2="Murky Ring",
		back="Null Shawl",waist="Chaac Belt",legs="Dashing Subligar",feet="Nyame Sollerets"}

	-- HEALING WALTZ
	sets.precast.Waltz['Healing Waltz'] = {}

	-- STEPS
	sets.precast.Step = {ammo="Voluspa Tathlum",
		head="Malignance Chapeau",neck="Null Loop",ear1="Mache Earring +1",ear2="Telos Earring",
		body="Malignance Tabard",hands="Malignance Gloves",ring1="Cacoethic Ring +1",ring2="Chirich Ring +1",
		back="Null Shawl",waist="Null Belt",legs="Malignance Tights",feet="Malignance Boots"}

	-- VIOLENT FLOURISH (magic accuracy)
	sets.precast.Flourish1 = {}
	sets.precast.Flourish1['Violent Flourish'] = set_combine(sets.precast.Step, {ear1="Crep. Earring",ear2="Gwati Earring"}) -- original: ear1="Gwati Earring",ear2="Crep. Earring"

	-- FAST CAST (owned FC: Voltsurge 4, Sombra Mittens 3, Limbo Trousers 3, Etiolation 1; DT elsewhere)
	sets.precast.FC = {ammo="Impatiens",
		head="Nyame Helm",neck="Voltsurge Torque",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Nyame Mail",hands="Sombra Mittens",ring1="Defending Ring",ring2="Murky Ring",
		back="Null Shawl",waist="Null Belt",legs="Limbo Trousers",feet="Nyame Sollerets"}

	sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Beads"})

	-- MIDCAST SETS
	sets.midcast.FastRecast = set_combine(sets.precast.FC, {ammo="Staunch Tathlum +1"})

	sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {})

	sets.midcast.Cure = set_combine(sets.midcast.FastRecast, {})
	sets.midcast.Curaga = sets.midcast.Cure

	-- No owned cure-received / self-healing / refresh-received gear.
	sets.Self_Healing = {}
	sets.Cure_Received = {}
	sets.Self_Refresh = {}

	sets.midcast.Stoneskin = sets.midcast.FastRecast

	sets.midcast.Cursna = set_combine(sets.midcast.FastRecast, {ring2="Menelaus's Ring"})

	sets.midcast.Protect = set_combine(sets.midcast.FastRecast, {})
	sets.midcast.Protectra = sets.midcast.Protect

	sets.midcast.Shell = set_combine(sets.midcast.FastRecast, {})
	sets.midcast.Shellra = sets.midcast.Shell

	sets.midcast['Enfeebling Magic'] = sets.midcast.FastRecast

	sets.midcast['Elemental Magic'] = sets.midcast.FastRecast

	sets.midcast.Helix = sets.midcast['Elemental Magic']
	sets.midcast.Helix.Resistant = sets.midcast['Elemental Magic']

	-- PHALANX RECEIVED: Sel-Stahp swaps this in when someone starts casting Phalanx II on you (not mid-action
	-- or in a full DefenseMode) and restores your gear when it lands. Valorous set = Phalanx +21.
	sets.Phalanx_Received = {
		head={name="Valorous Mask", augments={'INT+12','Magic burst dmg.+7%','Phalanx +4','Accuracy+1 Attack+1'}},
		body={name="Valorous Mail", augments={'STR+5','Rng.Atk.+26','Phalanx +4'}},
		hands={name="Valorous Mitts", augments={'Enmity-4','Mag. Acc.+14 "Mag.Atk.Bns."+14','Phalanx +4','Accuracy+10 Attack+10'}},
		legs={name="Valorous Hose", augments={'Pet: Attack+11 Pet: Rng.Atk.+11','Magic burst dmg.+7%','Phalanx +4'}},
		feet={name="Valorous Greaves", augments={'Mag. Acc.+1','"Cure" spellcasting time -9%','Phalanx +5','Mag. Acc.+14 "Mag.Atk.Bns."+14'}}}
	sets.midcast.Phalanx = set_combine(sets.midcast.FastRecast, sets.Phalanx_Received)

	-- WEAPONSKILLS
	-- Nukumi Gausape +3 matches Nyame Mail's WSD+12% with more STR/Attack/Accuracy for physical WS.
	sets.precast.WS = {ammo="Voluspa Tathlum",
		head="Nyame Helm",neck="Shulmanu Collar",ear1="Sherida Earring",ear2="Moonshade Earring", -- original: ear1 Moonshade, ear2 Sherida
		body="Nukumi Gausape +3",hands="Nyame Gauntlets",ring1="Ephramad's Ring",ring2="Gere Ring",
		back="Sacro Mantle",waist="Sailfi Belt +1",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {neck="Null Loop"})
	sets.precast.WS.Acc = set_combine(sets.precast.WS.SomeAcc, {head="Nuk. Cabasset +3",waist="Null Belt"})
	sets.precast.WS.FullAcc = set_combine(sets.precast.WS.Acc, {ear1="Mache Earring +1",ring2="Chirich Ring +1",back="Null Shawl"}) -- original: ear2="Telos Earring",ring2="Cacoethic Ring +1"
	sets.precast.WS.Fodder = set_combine(sets.precast.WS, {ammo="Paeapua"})

	-- Specific weaponskill sets
	sets.precast.WS['Ruinator'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Ruinator'].Mekira = set_combine(sets.precast.WS['Ruinator'], {})
	sets.precast.WS['Ruinator'].WSMidAcc = set_combine(sets.precast.WS.SomeAcc, {})
	sets.precast.WS['Ruinator'].WSHighAcc = set_combine(sets.precast.WS.Acc, {})

	sets.precast.WS['Onslaught'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Onslaught'].WSMidAcc = set_combine(sets.precast.WS.SomeAcc, {})
	sets.precast.WS['Onslaught'].WSHighAcc = set_combine(sets.precast.WS.Acc, {})

	-- Magical axe WS
	sets.precast.WS['Primal Rend'] = {ammo="Pemphredo Tathlum",
		head="Nyame Helm",neck="Baetyl Pendant",ear1="Crematio Earring",ear2="Moonshade Earring", -- original: ear1 Moonshade, ear2 Crematio
		body="Nyame Mail",hands="Nyame Gauntlets",ring1="Metamor. Ring +1",ring2="Beithir Ring",
		back="Sacro Mantle",waist="Orpheus's Sash",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	sets.precast.WS['Cloudsplitter'] = set_combine(sets.precast.WS['Primal Rend'], {})

	-- Swap to these on Moonshade using WS if at 3000 TP (BST.lua reads ear1 AND ear2, so both are set)
	sets.MaxTP = {ear1="Sherida Earring",ear2="Ishvara Earring"} -- original: ear1="Ishvara Earring",ear2="Sherida Earring"
	sets.AccMaxTP = {ear1="Mache Earring +1",ear2="Telos Earring"}
	-- Magic WS keep magic earrings at 3000 TP (BST.lua looks up sets.MaxTP[spell.english] first)
	sets.MaxTP['Primal Rend'] = {ear1="Crematio Earring",ear2="Hecate's Earring"}
	sets.MaxTP['Cloudsplitter'] = sets.MaxTP['Primal Rend']
	sets.AccMaxTP['Primal Rend'] = sets.MaxTP['Primal Rend']
	sets.AccMaxTP['Cloudsplitter'] = sets.MaxTP['Primal Rend']

	-- PET SIC & READY MOVES
	-- Nukumi +3 carries Pet Acc/MAcc +60~64 per piece; Nukumi Manoplas +3 also has "Ready" TP Bonus +700
	-- (BST.lua re-adds them via Pet.TPBonus when the pet's TP is low). Shulmanu/Nukumi Earring +1/Incarnation
	-- add pet Double Attack. No weapons here: a main/sub swap would wipe your TP.
	sets.midcast.Pet.WS = {ammo="Voluspa Tathlum",
		head="Gleti's Mask",neck="Shulmanu Collar",ear1="Alabaster Earring",ear2="Nukumi Earring +1",
		body="Nukumi Gausape +3",hands="Nukumi Manoplas +3",ring1="Defending Ring",ring2="Murky Ring",
		back="Pastoralist's Mantle",waist="Incarnation Sash",legs="Nukumi Quijotes +3",feet="Nukumi Ocreae +3"}

	sets.midcast.Pet.SomeAcc = set_combine(sets.midcast.Pet.WS, {})
	sets.midcast.Pet.Acc = set_combine(sets.midcast.Pet.WS, {head="Nuk. Cabasset +3"})
	sets.midcast.Pet.FullAcc = set_combine(sets.midcast.Pet.Acc, {})
	sets.midcast.Pet.MultiHitReady = set_combine(sets.midcast.Pet.WS, {})

	-- Magic Ready: Adad Amulet is the only owned pet "Magic Atk. Bonus" piece; Nukumi head adds pet MAcc+61.
	-- Udug Jacket: Pet Magic Acc.+45 "Magic Atk. Bonus"+45, DT-10%. original body: Nukumi Gausape +3 (from Pet.WS)
	sets.midcast.Pet.MagicReady = set_combine(sets.midcast.Pet.WS, {head="Nuk. Cabasset +3",neck="Adad Amulet",body="Udug Jacket"})
	-- Debuff Ready: pure magic accuracy, so the Gausape (Pet MAcc+64) stays
	sets.midcast.Pet.DebuffReady = set_combine(sets.midcast.Pet.MagicReady, {body="Nukumi Gausape +3"})
	sets.midcast.Pet.PhysicalDebuffReady = set_combine(sets.midcast.Pet.WS, {head="Nuk. Cabasset +3"})

	sets.midcast.Pet.ReadyRecast = {legs="Gleti's Breeches"}   -- "Sic" and "Ready" ability delay -5
	sets.midcast.Pet.ReadyRecastDW = {legs="Gleti's Breeches"}
	sets.midcast.Pet.Neutral = {head="Gleti's Mask"}
	sets.midcast.Pet.Favorable = {head="Nuk. Cabasset +3"}   -- Monster correlation effects +28
	sets.midcast.Pet.TPBonus = {hands="Nukumi Manoplas +3"}

	-- RESTING
	sets.resting = {}

	-- IDLE SETS (no weapons: the Weapons mode decides those)
	sets.idle = {ammo="Staunch Tathlum +1",
		head="Null Masque",neck="Bathy Choker +1",ear1="Alabaster Earring",ear2="Odnowa Earring +1",
		body="Nyame Mail",hands="Nukumi Manoplas +3",ring1="Defending Ring",ring2="Chirich Ring +1",
		back="Null Shawl",waist="Null Belt",legs="Nukumi Quijotes +3",feet="Nyame Sollerets"}

	sets.idle.SingleWield = set_combine(sets.idle, {})
	sets.idle.Refresh = set_combine(sets.idle, {})
	sets.idle.Reraise = set_combine(sets.idle, {head="Twilight Helm",body="Twilight Mail"})

	-- Pet out, you idle: pet survivability (Gleti's Gauntlets pet DT-8, Tali'ah Seraweels pet DT-5,
	-- Isa Belt pet DT-3/Regen) with your own DT on the remaining slots.
	sets.idle.Pet = {ammo="Staunch Tathlum +1",
		head="Nuk. Cabasset +3",neck="Empath Necklace",ear1="Alabaster Earring",ear2="Nukumi Earring +1",
		body="Nyame Mail",hands="Gleti's Gauntlets",ring1="Defending Ring",ring2="Murky Ring",
		back="Pastoralist's Mantle",waist="Isa Belt",legs="Tali'ah Sera. +2",feet="Nyame Sollerets"}

	-- Pet fighting, you idle: pet offense (Store TP, Double Attack, Attack, Haste).
	sets.idle.Pet.Engaged = {ammo="Voluspa Tathlum",
		head="Tali'ah Turban +2",neck="Shulmanu Collar",ear1="Crep. Earring",ear2="Nukumi Earring +1",
		body="Nukumi Gausape +3",hands="Gleti's Gauntlets",ring1="Defending Ring",ring2="Murky Ring",
		back="Pastoralist's Mantle",waist="Incarnation Sash",legs="Despair Cuisses",feet="Tali'ah Crackows +2"}

	sets.idle.Pet.Engaged.DW = set_combine(sets.idle.Pet.Engaged, {})
	-- Pet Mode "Tank" (Win+F7): keep the pet DT pieces on while the pet fights (BST.lua adds PetMode as an idle group)
	sets.idle.Pet.Engaged.Tank = set_combine(sets.idle.Pet.Engaged, {hands="Gleti's Gauntlets",legs="Tali'ah Sera. +2",waist="Isa Belt"})
	sets.idle.Pet.Engaged.DW.Tank = sets.idle.Pet.Engaged.Tank

	-- LINKTRI: PorterPacker packing-safe set (same approach as the WHM file). Equipped while a Porter Moogle
	-- is close so none of your slip-storable gear (Nukumi/Totemic artifact pieces etc.) is being worn when
	-- PorterPacker packs it. Only non-slip gear here; weapons are left as they are.
	sets.packing = {ammo="Staunch Tathlum +1",
		head="Null Masque",neck="Loricate Torque +1",ear1="Alabaster Earring",ear2="Odnowa Earring +1",
		body="Nyame Mail",hands="Nyame Gauntlets",ring1="Defending Ring",ring2="Murky Ring",
		back="Null Shawl",waist="Null Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	-- DEFENSE SETS
	sets.defense.PDT = {ammo="Staunch Tathlum +1",
		head="Nuk. Cabasset +3",neck="Loricate Torque +1",ear1="Alabaster Earring",ear2="Odnowa Earring +1",
		body="Nyame Mail",hands="Nukumi Manoplas +3",ring1="Defending Ring",ring2="Murky Ring",
		back="Null Shawl",waist="Null Belt",legs="Nukumi Quijotes +3",feet="Nyame Sollerets"}

	sets.defense.PetPDT = set_combine(sets.defense.PDT, {ear2="Nukumi Earring +1",hands="Gleti's Gauntlets",
		back="Pastoralist's Mantle",waist="Isa Belt",legs="Tali'ah Sera. +2"})

	sets.defense.PetMDT = set_combine(sets.defense.PetPDT, {})

	sets.defense.PetMEVA = sets.defense.PetMDT

	sets.defense.PKiller = set_combine(sets.defense.PDT, {body="Nukumi Gausape +3"})
	sets.defense.Reraise = set_combine(sets.defense.PDT, {head="Twilight Helm",body="Twilight Mail"})

	sets.defense.MDT = set_combine(sets.defense.PDT, {ear2="Etiolation Earring"})

	sets.defense.MEVA = {ammo="Staunch Tathlum +1",
		head="Malignance Chapeau",neck="Null Loop",ear1="Sanare Earring",ear2="Etiolation Earring",
		body="Malignance Tabard",hands="Malignance Gloves",ring1="Vengeful Ring",ring2="Murky Ring",
		back="Null Shawl",waist="Null Belt",legs="Malignance Tights",feet="Malignance Boots"}

	sets.defense.MKiller = set_combine(sets.defense.MDT, {body="Nukumi Gausape +3"})

	sets.Kiting = {ring2="Shneddick Ring +1"}
	sets.DayIdle = {}
	sets.NightIdle = {}

	-- MELEE (SINGLE-WIELD)
	sets.engaged = {ammo="Coiste Bodhar",
		head="Malignance Chapeau",neck="Anu Torque",ear1="Sherida Earring",ear2="Telos Earring",
		body="Gleti's Cuirass",hands="Malignance Gloves",ring1="Hetairoi Ring",ring2="Gere Ring", -- original: ring1 Gere, ring2 Hetairoi
		back="Null Shawl",waist="Sailfi Belt +1",legs="Gleti's Breeches",feet="Malignance Boots"}

	sets.engaged.SomeAcc = set_combine(sets.engaged, {neck="Shulmanu Collar"})

	sets.engaged.Acc = set_combine(sets.engaged.SomeAcc, {neck="Null Loop",ear1="Mache Earring +1",body="Malignance Tabard",
		ring1="Cacoethic Ring +1",ring2="Chirich Ring +1",waist="Null Belt",legs="Malignance Tights"})

	sets.engaged.FullAcc = set_combine(sets.engaged.Acc, {ammo="Voluspa Tathlum",head="Nuk. Cabasset +3"})

	sets.engaged.Fodder = set_combine(sets.engaged, {neck="Asperity Necklace",ear1="Trux Earring"})

	-- MELEE (SINGLE-WIELD) HYBRID SETS
	-- Nukumi head/hands/legs (DT-11/11/13) + Nyame body + Defending Ring = DT-54% (cap 50), with offensive
	-- neck/ammo/earrings and more Accuracy/Attack than the old all-Nyame build.
	sets.engaged.PDT = {ammo="Coiste Bodhar",
		head="Nuk. Cabasset +3",neck="Shulmanu Collar",ear1="Sherida Earring",ear2="Telos Earring",
		body="Nyame Mail",hands="Nukumi Manoplas +3",ring1="Defending Ring",ring2="Gere Ring",
		back="Null Shawl",waist="Sailfi Belt +1",legs="Nukumi Quijotes +3",feet="Nukumi Ocreae +3"} -- original feet: Nyame Sollerets (DT was 61%)

	sets.engaged.SomeAcc.PDT = set_combine(sets.engaged.PDT, {neck="Null Loop"})
	sets.engaged.Acc.PDT = set_combine(sets.engaged.SomeAcc.PDT, {ear1="Mache Earring +1",ring2="Chirich Ring +1",waist="Null Belt"})
	sets.engaged.FullAcc.PDT = set_combine(sets.engaged.Acc.PDT, {ammo="Voluspa Tathlum"}) -- original: ring2="Cacoethic Ring +1" (keeps Chirich ring2)
	sets.engaged.Fodder.PDT = set_combine(sets.engaged.PDT, {})

	-- MELEE (DUAL-WIELD): Dudgeon + Heartseeker set bonus and Reiki Yotai for Dual Wield
	sets.engaged.DW = set_combine(sets.engaged, {ear1="Dudgeon Earring",ear2="Heartseeker Earring",waist="Reiki Yotai"})
	sets.engaged.DW.SomeAcc = set_combine(sets.engaged.SomeAcc, {ear1="Dudgeon Earring",ear2="Heartseeker Earring"})
	sets.engaged.DW.Acc = set_combine(sets.engaged.Acc, {})
	sets.engaged.DW.FullAcc = set_combine(sets.engaged.FullAcc, {})
	sets.engaged.DW.Fodder = set_combine(sets.engaged.Fodder, {ear1="Dudgeon Earring",ear2="Heartseeker Earring",waist="Reiki Yotai"})

	-- MELEE (DUAL-WIELD) HYBRID SETS
	sets.engaged.DW.PDT = set_combine(sets.engaged.PDT, {ear1="Dudgeon Earring",ear2="Heartseeker Earring"})
	sets.engaged.DW.SomeAcc.PDT = set_combine(sets.engaged.SomeAcc.PDT, {ear1="Dudgeon Earring",ear2="Heartseeker Earring"})
	sets.engaged.DW.Acc.PDT = set_combine(sets.engaged.Acc.PDT, {})
	sets.engaged.DW.FullAcc.PDT = set_combine(sets.engaged.FullAcc.PDT, {})

	-- MASTER ENGAGED & PET ENGAGED: Shulmanu (master DA+3, pet DA+5) and Nukumi Earring +1 (pet DA+7, PDL+8)
	local both_dd = {neck="Shulmanu Collar",ear2="Nukumi Earring +1"}
	sets.engaged.BothDD = set_combine(sets.engaged, both_dd)
	sets.engaged.BothDD.SomeAcc = set_combine(sets.engaged.SomeAcc, both_dd)
	sets.engaged.BothDD.Acc = set_combine(sets.engaged.Acc, {ear2="Nukumi Earring +1"})
	sets.engaged.BothDD.FullAcc = set_combine(sets.engaged.FullAcc, {ear2="Nukumi Earring +1"})
	sets.engaged.BothDD.Fodder = set_combine(sets.engaged.Fodder, both_dd)

	-- MASTER ENGAGED & PET TANKING: pet DT pieces (Gleti's Gauntlets, Tali'ah Seraweels, Isa Belt)
	local pet_tank = {hands="Gleti's Gauntlets",legs="Tali'ah Sera. +2",waist="Isa Belt"}
	sets.engaged.PetTank = set_combine(sets.engaged, pet_tank)
	sets.engaged.PetTank.SomeAcc = set_combine(sets.engaged.SomeAcc, pet_tank)
	sets.engaged.PetTank.Acc = set_combine(sets.engaged.Acc, pet_tank)
	sets.engaged.PetTank.FullAcc = set_combine(sets.engaged.FullAcc, pet_tank)
	sets.engaged.PetTank.Fodder = set_combine(sets.engaged.Fodder, pet_tank)

	sets.engaged.DW.BothDD = set_combine(sets.engaged.DW, both_dd)
	sets.engaged.DW.BothDD.SomeAcc = set_combine(sets.engaged.DW.SomeAcc, both_dd)
	sets.engaged.DW.BothDD.Acc = set_combine(sets.engaged.DW.Acc, {ear2="Nukumi Earring +1"})
	sets.engaged.DW.BothDD.FullAcc = set_combine(sets.engaged.DW.FullAcc, {ear2="Nukumi Earring +1"})
	sets.engaged.DW.BothDD.Fodder = set_combine(sets.engaged.DW.Fodder, both_dd)

	sets.engaged.DW.PetTank = set_combine(sets.engaged.DW, pet_tank)
	sets.engaged.DW.PetTank.SomeAcc = set_combine(sets.engaged.DW.SomeAcc, pet_tank)
	sets.engaged.DW.PetTank.Acc = set_combine(sets.engaged.DW.Acc, pet_tank)
	sets.engaged.DW.PetTank.FullAcc = set_combine(sets.engaged.DW.FullAcc, pet_tank)
	sets.engaged.DW.PetTank.Fodder = set_combine(sets.engaged.DW.Fodder, pet_tank)

	sets.buff['Killer Instinct'] = {body="Nukumi Gausape +3"} -- Augments "Killer" effects
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = {}
	sets.TreasureHunter = {legs="Volte Hose",waist="Chaac Belt"} -- original: set_combine(sets.TreasureHunter, {}) (global set uses stored Wh. Rarab Cap +1)
	sets.Knockback = {}
	sets.SuppaBrutal = {ear1="Sherida Earring",ear2="Telos Earring"}
	sets.DWEarrings = {ear1="Dudgeon Earring",ear2="Heartseeker Earring"}

	-- WEAPON SETS
	sets.weapons.PetPDTAxe = {main="Agwu's Axe",sub="Sacro Bulwark"}     -- pet: Melee DMG+10, all attr. +20, Acc+50
	sets.weapons.MasterAxe = {main="Ikenga's Axe",sub="Sacro Bulwark"}   -- you: Crit+10%, TP Bonus +500 (R30)
	sets.weapons.DualWeapons = {main="Ikenga's Axe",sub="Agwu's Axe"}    -- needs /NIN or /DNC

	-------------------------------------------------------------------------------------------------------------------
	-- Complete Lvl 76-99 Jug Pet Precast List +Funguar +Courier +Amigo
	-------------------------------------------------------------------------------------------------------------------

	sets.precast.JA['Bestial Loyalty'].FunguarFamiliar = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Seedbed Soil"})
	sets.precast.JA['Bestial Loyalty'].CourierCarrie = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Fish Oil Broth"})
	sets.precast.JA['Bestial Loyalty'].AmigoSabotender = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Sun Water"})
	sets.precast.JA['Bestial Loyalty'].NurseryNazuna = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="D. Herbal Broth"})
	sets.precast.JA['Bestial Loyalty'].CraftyClyvonne = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Cng. Brain Broth"})
	sets.precast.JA['Bestial Loyalty'].PrestoJulio = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="C. Grass. Broth"})
	sets.precast.JA['Bestial Loyalty'].SwiftSieghard = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Mlw. Bird Broth"})
	sets.precast.JA['Bestial Loyalty'].MailbusterCetas = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Gob. Bug Broth"})
	sets.precast.JA['Bestial Loyalty'].AudaciousAnna = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Bub. Carrion Broth"}) -- original: "B. Carrion Broth"
	sets.precast.JA['Bestial Loyalty'].TurbidToloi = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Auroral Broth"})
	sets.precast.JA['Bestial Loyalty'].LuckyLulush = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="L. Carrot Broth"})
	sets.precast.JA['Bestial Loyalty'].DipperYuly = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Wool Grease"})
	sets.precast.JA['Bestial Loyalty'].FlowerpotMerle = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Vermihumus"})
	sets.precast.JA['Bestial Loyalty'].DapperMac = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Briny Broth"})
	sets.precast.JA['Bestial Loyalty'].DiscreetLouise = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Deepbed Soil"})
	sets.precast.JA['Bestial Loyalty'].FatsoFargann = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="C. Plasma Broth"})
	sets.precast.JA['Bestial Loyalty'].FaithfulFalcorr = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Lucky Broth"})
	sets.precast.JA['Bestial Loyalty'].BugeyedBroncha = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Svg. Mole Broth"})
	sets.precast.JA['Bestial Loyalty'].BloodclawShasra = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Rzr. Brain Broth"})
	sets.precast.JA['Bestial Loyalty'].GorefangHobs = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Bur. Carrion Broth"}) -- original: "B. Carrion Broth"
	sets.precast.JA['Bestial Loyalty'].GooeyGerard = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Cl. Wheat Broth"})
	sets.precast.JA['Bestial Loyalty'].CrudeRaphie = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Shadowy Broth"})

	-------------------------------------------------------------------------------------------------------------------
	-- Complete iLvl Jug Pet Precast List
	-------------------------------------------------------------------------------------------------------------------

	sets.precast.JA['Bestial Loyalty'].DroopyDortwin = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Swirling Broth"})
	sets.precast.JA['Bestial Loyalty'].PonderingPeter = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Vis. Broth"})
	sets.precast.JA['Bestial Loyalty'].SunburstMalfik = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Shimmering Broth"})
	sets.precast.JA['Bestial Loyalty'].AgedAngus = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Ferm. Broth"})
	sets.precast.JA['Bestial Loyalty'].WarlikePatrick = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Livid Broth"})
	sets.precast.JA['Bestial Loyalty'].ScissorlegXerin = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Spicy Broth"})
	sets.precast.JA['Bestial Loyalty'].BouncingBertha = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Bubbly Broth"})
	sets.precast.JA['Bestial Loyalty'].RhymingShizuna = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Lyrical Broth"})
	sets.precast.JA['Bestial Loyalty'].AttentiveIbuki = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Salubrious Broth"})
	sets.precast.JA['Bestial Loyalty'].SwoopingZhivago = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Windy Greens"})
	sets.precast.JA['Bestial Loyalty'].AmiableRoche = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Airy Broth"})
	sets.precast.JA['Bestial Loyalty'].HeraldHenry = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Trans. Broth"})
	sets.precast.JA['Bestial Loyalty'].BrainyWaluis = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Crumbly Soil"})
	sets.precast.JA['Bestial Loyalty'].HeadbreakerKen = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Blackwater Broth"})
	sets.precast.JA['Bestial Loyalty'].SuspiciousAlice = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Furious Broth"})
	sets.precast.JA['Bestial Loyalty'].AnklebiterJedd = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Crackling Broth"})
	sets.precast.JA['Bestial Loyalty'].FleetReinhard = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Rapid Broth"})
	sets.precast.JA['Bestial Loyalty'].CursedAnnabelle = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Creepy Broth"})
	sets.precast.JA['Bestial Loyalty'].SurgingStorm = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Insipid Broth"})
	sets.precast.JA['Bestial Loyalty'].SubmergedIyo = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Deepwater Broth"})
	sets.precast.JA['Bestial Loyalty'].RedolentCandi = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Electrified Broth"})
	sets.precast.JA['Bestial Loyalty'].AlluringHoney = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Bug-Ridden Broth"})
	sets.precast.JA['Bestial Loyalty'].CaringKiyomaro = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Fizzy Broth"})
	sets.precast.JA['Bestial Loyalty'].VivaciousVickie = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Tant. Broth"})
	sets.precast.JA['Bestial Loyalty'].HurlerPercival = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Pale Sap"})
	sets.precast.JA['Bestial Loyalty'].BlackbeardRandy = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Meaty Broth"})
	sets.precast.JA['Bestial Loyalty'].GenerousArthur = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Dire Broth"})
	sets.precast.JA['Bestial Loyalty'].ThreestarLynn = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Muddy Broth"})
	sets.precast.JA['Bestial Loyalty'].MosquitoFamiliar = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Wetlands Broth"})
	sets.precast.JA['Bestial Loyalty']['Left-HandedYoko'] = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Heavenly Broth"})
	sets.precast.JA['Bestial Loyalty'].BraveHeroGlenn = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Wispy Broth"})
	sets.precast.JA['Bestial Loyalty'].SharpwitHermes = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Saline Broth"})
	sets.precast.JA['Bestial Loyalty'].ColibriFamiliar = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Sugary Broth"})
	sets.precast.JA['Bestial Loyalty'].ChoralLeera = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Glazed Broth"})
	sets.precast.JA['Bestial Loyalty'].SpiderFamiliar = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Sticky Webbing"})
	sets.precast.JA['Bestial Loyalty'].GussyHachirobe = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Slimy Webbing"})
	sets.precast.JA['Bestial Loyalty'].AcuexFamiliar = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Poisonous Broth"})
	sets.precast.JA['Bestial Loyalty'].FluffyBredo = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Venomous Broth"})
	sets.precast.JA['Bestial Loyalty'].WeevilFamiliar = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Pristine Sap"})
	sets.precast.JA['Bestial Loyalty'].StalwartAngelina = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="T. Pristine Sap"})
	sets.precast.JA['Bestial Loyalty'].SweetCaroline = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Aged Humus"})
	sets.precast.JA['Bestial Loyalty']['P.CrabFamiliar'] = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Rancid Broth"})
	sets.precast.JA['Bestial Loyalty'].JovialEdwin = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Pungent Broth"})
	sets.precast.JA['Bestial Loyalty']['Y.BeetleFamiliar'] = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Zestful Sap"})
	sets.precast.JA['Bestial Loyalty'].EnergizedSefina = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Gassy Sap"})
	sets.precast.JA['Bestial Loyalty'].LynxFamiliar = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Frizzante Broth"})
	sets.precast.JA['Bestial Loyalty'].VivaciousGaston = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Spumante Broth"})
	sets.precast.JA['Bestial Loyalty']['Hip.Familiar'] = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Turpid Broth"})
	sets.precast.JA['Bestial Loyalty'].DaringRoland = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Feculent Broth"})
	sets.precast.JA['Bestial Loyalty'].SlimeFamiliar = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Decaying Broth"})
	sets.precast.JA['Bestial Loyalty'].SultryPatrice = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Putrescent Broth"})
end

-- LINKTRI: PorterPacker support (ported from the WHM file). Uses user_job_customize_idle_set, which Sel runs
-- AFTER BST.lua's own job_customize_idle_set, so BST's pet idle logic is left intact.
near_porter = false

function near_porter_moogle()
	local mobs = windower.ffxi.get_mob_array()
	for i, mob in pairs(mobs) do
		-- mob.distance is squared yalms: < 36 means within 6 yalms
		if mob.name == "Porter Moogle" and mob.distance and mob.distance < 36 then
			return true
		end
	end
	return false
end

function user_job_customize_idle_set(idleSet)
	if near_porter_moogle() then
		if not near_porter then
			windower.add_to_chat(160, "Near Porter Moogle - Using packing gear")
			near_porter = true
		end
		return sets.packing
	elseif near_porter then
		windower.add_to_chat(160, "Left Porter Moogle area - Returning to normal gear")
		near_porter = false
	end
	return idleSet
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
	-- Default macro set/book
	if player.sub_job == 'DNC' then
		set_macro_page(1, 9)
	elseif player.sub_job == 'NIN' then
		set_macro_page(1, 9)
	elseif player.sub_job == 'THF' then
		set_macro_page(1, 9)
	elseif player.sub_job == 'RUN' then
		set_macro_page(1, 9)
	else
		set_macro_page(1, 9)
	end
end

-- original: duplicate state.Weapons:options(...) line removed (already set in user_job_setup)
autows_list = {['PetPDTAxe']='Ruinator',['MasterAxe']='Ruinator',['DualWeapons']='Ruinator'}