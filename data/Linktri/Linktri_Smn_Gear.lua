near_porter = false

-- LINKTRI (2026-10-20) SMN audit notes:
--   * Owned: full Beckoner's +3, Glyphic +3 and Convoker's +1 sets. Every "Beckoner's +1" slot (not owned) was
--     re-evaluated: kept as the +3 piece where that piece is right for the set, otherwise the best owned piece.
--     Items replaced keep an "original:" comment.
--   * Fixed sides to avoid "Failed to equip" mirror swaps:
--       ear1 = Malignance / C. Palug / Lugalbanda / Andoaa / Crep.      ear2 = Beck. Earring +1 (RIGHT EAR ONLY bonus) / Crematio / Etiolation / Sanare / Psystorm / Magnetic / Meili / Telos / Dedition
--       ring1 = Defending / Evoker's / Kishar / Menelaus / Mephitas / Petrov / Shneddick   ring2 = Murky / Lebeche / Crepuscular   (Stikini: two owned, either side)
--   * Stored (PorterPacker): Twilight Cloak.

-- Setup vars that are user-dependent.  Can override this function in a sidecar.
function user_job_setup()
    state.OffenseMode:options('Normal','Acc')
    state.CastingMode:options('Normal','Resistant','OccultAcumen')
    state.IdleMode:options('Normal','PDT')
    state.Weapons:options('None') -- LINKTRI: original 'None','Khatvanga' (Khatvanga not owned yet)

    gear.perp_staff = {name="Mpaca's Staff", augments={'Path: A'}}

    -- LINKTRI: no Campestres's Cape owned; Samanisi Cape (Avatar Acc/MAcc+7, BP delay -3) for pacts.
    --   original: gear.magic_jse_back = gear.phys_jse_back = {name="Conveyance Cape"}
    gear.magic_jse_back = "Samanisi Cape"
    gear.phys_jse_back = "Samanisi Cape"

    send_command('bind !` input /ja "Release" <me>')
    send_command('bind @` gs c cycle MagicBurst')
    send_command('bind ^` gs c toggle PactSpamMode')
    send_command('bind !pause gs c toggle AutoSubMode')
    -- send_command('bind ^q gs c weapons Khatvanga;gs c set CastingMode OccultAcumen') -- LINKTRI: re-enable when Khatvanga is owned
    send_command('bind ^q gs c set CastingMode OccultAcumen') -- LINKTRI: Occult Acumen without the Khatvanga weapon swap
    send_command('bind !q gs c weapons default;gs c reset CastingMode')

    select_default_macro_book()
end

-- LINKTRI (2026-10-20): removed the empty update_job_states() override. It turned off Sel's on-screen state
-- display for SMN. The labels that used to error (autonuke, AutoSambaMode) now have defaults in Sel-Include.
-- If an update_job_states error appears after //gs reload, restore this:
--   original: function update_job_states() end  -- "Add this to prevent the update_job_states error"

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Precast Sets
    --------------------------------------

    sets.TreasureHunter = set_combine(sets.TreasureHunter, {waist="Chaac Belt"})

    -- Precast sets to enhance JAs
    sets.precast.JA['Astral Flow'] = {head={name="Glyphic Horn +3", augments={'Enhances "Astral Flow" effect',}}} -- original: Beckoner's Horn +1

    -- Elemental Siphon: summoning magic skill + Beck. Pigaches +3 ("Elemental Siphon"+80) + Conveyance Cape
    -- original: Telchine Cap/Chasuble/Gloves/Braconi, Andoaa/C. Palug, Regal Belt, Beck. Pigaches +1 (not owned)
    sets.precast.JA['Elemental Siphon'] = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +3",          -- Summoning skill +23
        neck="Adad Amulet",
        ear1="C. Palug Earring",            -- Summoning skill +5
        ear2="Beck. Earring +1",
        body="Beck. Doublet +3",            -- Summoning skill +24
        hands="Glyphic Bracers +3",         -- Summoning skill +23
        ring1="Evoker's Ring",              -- Summoning skill +10
        ring2="Stikini Ring",
        back="Conveyance Cape",             -- Summoning skill +8, enhances Elemental Siphon
        waist="Lucidity Sash",              -- Summoning skill +7
        legs="Beck. Spats +3",              -- Summoning skill +30
        feet="Beck. Pigaches +3"}           -- "Elemental Siphon"+80

    sets.precast.JA['Mana Cede'] = {hands="Beck. Bracers +3"} -- original: Beck. Bracers +1

    -- Pact delay reduction gear. Caps: Blood Pact ability delay -15, delay II -15.
    --   Delay I: Glyphic Horn +3 -10, Glyphic Bracers +3 -8 (= -18, capped)
    --   Delay II: Epitaph -5, Glyphic Doublet +3 -4, Glyph. Pigaches +3 -3, Espiritus -2 (= -14)
    -- original: Beckoner's +1 head/body/hands/legs/feet (not owned; no delay stats), Andoaa/Lugalbanda, Conveyance Cape
    sets.precast.BloodPactWard = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head={name="Glyphic Horn +3", augments={'Enhances "Astral Flow" effect',}},
        neck="Adad Amulet",
        ear1="Lugalbanda Earring",
        ear2="Beck. Earring +1",
        body={name="Glyphic Doublet +3", augments={'Reduces Sp. "Blood Pact" MP cost',}},
        hands={name="Glyphic Bracers +3", augments={'Inc. Sp. "Blood Pact" magic burst dmg.',}},
        ring1="Evoker's Ring",
        ring2="Stikini Ring",
        back="Samanisi Cape",               -- Blood Pact ability delay -3
        waist="Lucidity Sash",
        legs="Beck. Spats +3",              -- DT-12% (delay I already capped)
        feet={name="Glyph. Pigaches +3", augments={'Inc. Sp. "Blood Pact" magic crit. dmg.',}}}

    sets.precast.BloodPactRage = sets.precast.BloodPactWard

    -- Fast cast sets for spells
    -- FC about 66%: Grioavolr 11, Clerisy 3, Bunzi's Hat 10, Voltsurge 4, Malignance 4, Etiolation 1, Inyanga Jubbah 14,
    -- Kishar 4, Embla 5, Lengo 5, Regal Pumps 5
    sets.precast.FC = {main=gear.grioavolr_fc_staff,
        sub="Clerisy Strap +1",             -- FC+3  -- original: Umbra Strap
        ammo="Impatiens",
        head={name="Bunzi's Hat", augments={'Path: A'}},neck="Voltsurge Torque",ear1="Malignance Earring",
        ear2="Etiolation Earring",          -- FC+1  -- original: C. Palug Earring
        body="Inyanga Jubbah +2",
        hands={name="Bunzi's Gloves", augments={'Path: A'}},  -- DT-8%  -- original: Beck. Bracers +1 (not owned; no FC on +1 or +3)
        ring1="Kishar Ring",
        ring2="Lebeche Ring",               -- original: Stikini Ring
        back="Conveyance Cape",             -- original: Alaunus's Cape (WHM only)
        waist="Embla Sash",                 -- FC+5  -- original: Witful Belt
        legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}},feet={name="Regal Pumps +1", augments={'Path: A'}}}

    sets.precast.FC.Cure = set_combine(sets.precast.FC, {}) -- original: {main="Espiritus",sub="Umbra Strap"} (dropped the fast cast staff)

    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})

    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {})

    sets.precast.FC.Impact = set_combine(sets.precast.FC, {head=empty,body="Twilight Cloak"})
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main="Daybreak",sub="Genmei Shield"})

    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {}

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    -- Myrkr: MP. original: Beckoner's +1 head/body/hands/feet (not owned), Ethereal Earring (not owned), Lengo Pants
    sets.precast.WS['Myrkr'] = {ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +3",          -- MP+154
        neck="Adad Amulet",ear1="C. Palug Earring",
        ear2="Etiolation Earring",          -- MP+50
        body="Beck. Doublet +3",            -- MP+171
        hands="Beck. Bracers +3",           -- MP+114
        ring1="Mephitas's Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Regal Belt",
        legs="Beck. Spats +3",              -- MP+136
        feet="Beck. Pigaches +3"}           -- MP+117


    --------------------------------------
    -- Midcast sets
    --------------------------------------

    sets.midcast.FastRecast = set_combine(sets.precast.FC, {})

    -- Cure potency far past the 50% cap: Daybreak 30, Sors 3, Vanya Hood 10, Nodens 5, Bunzi's Robe 15, Telchine Gloves 10,
    -- Menelaus 5, Lebeche 3, Gyve 10, Medium's Sabots 12
    -- original: Espiritus/Umbra Strap (no Cure potency), Kaykaus +1 set (SMN can't equip), Ethereal Earring (not owned),
    --   Stikini x2, Regal Belt
    sets.midcast.Cure = {main="Daybreak",sub="Sors Shield",ammo="Impatiens",
        head="Vanya Hood",neck="Nodens Gorget",ear1="C. Palug Earring",ear2="Meili Earring",
        body={name="Bunzi's Robe", augments={'Path: A'}},hands={name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},ring1="Menelaus's Ring",ring2="Lebeche Ring",
        back="Pahtli Cape",waist="Rumination Sash",legs="Gyve Trousers",feet={ name="Medium's Sabots", augments={'MP+50','MND+10','"Conserve MP"+7','"Cure" potency +5%',}}}

    -- original: {neck="Adad Amulet",ring1/ring2="Stikini Ring",waist="Regal Belt"} (no Cure-received stats)
    sets.Self_Healing = {}
    sets.Cure_Received = {}
    sets.Self_Refresh = {} -- original: {back="Conveyance Cape",waist="Regal Belt",feet="Beck. Pigaches +1"} (no Refresh-received stats)

    -- Menelaus's Ring: Cursna+20, Meili Earring: Healing magic skill +10
    -- original: Cure set + Kaykaus Cuffs +1 (SMN can't equip), Stikini x2, Witful Belt
    sets.midcast.Cursna = set_combine(sets.midcast.FastRecast, {ring1="Menelaus's Ring",ear2="Meili Earring"})

    sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {main=gear.grioavolr_fc_staff,sub="Umbra Strap"})

    -- Summoning magic skill set. original: Beckoner's +1 head/body/hands/feet, Andoaa/Lugalbanda, Stikini x2, Regal Belt, Assid. Pants +1
    sets.midcast['Summoning Magic'] = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +3",neck="Adad Amulet",ear1="C. Palug Earring",ear2="Beck. Earring +1",
        body="Beck. Doublet +3",hands="Glyphic Bracers +3",ring1="Evoker's Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Lucidity Sash",legs="Beck. Spats +3",feet="Beck. Pigaches +3"}

    -- Your own nukes. Ammurapi Shield (MAB+38) for the club; Eschan Stone (Regal Belt's MAB is avatar-only);
    -- Scintillating Cape (MAB+16); Bunzi's Pants (MAB/Magic Dmg+30, MAcc+40).
    -- original: sub Umbra Strap, ear1 Crematio / ear2 Malignance, back Conveyance Cape, waist Regal Belt, legs Lengo Pants
    sets.midcast['Elemental Magic'] = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head={name="Bunzi's Hat", augments={'Path: A'}},neck="Baetyl Pendant",ear1="Malignance Earring",ear2="Crematio Earring",
        body={name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9'}},hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back="Scintillating Cape",waist="Eschan Stone",legs={name="Bunzi's Pants", augments={'Path: A'}},feet={name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14'}}}

    sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {neck="Null Loop",back="Aurist's Cape +1"})

    -- LINKTRI: Khatvanga and the Merlinic/Chironic Occult Acumen pieces aren't owned; rebuilt on owned Store TP / OA gear.
    -- original: Khatvanga/Bloodrain Strap, Shulmanu Collar, Lugalbanda/Gelos (not owned), Merlinic Jubbah and Chironic Gloves
    --   with Occult Acumen augments (not owned / SMN can't equip), Petrov/Stikini, Conveyance, Regal Belt, Lengo, Merlinic OA feet
    sets.midcast['Elemental Magic'].OccultAcumen = {
        -- main="Khatvanga",sub="Bloodrain Strap", -- LINKTRI: restore when Khatvanga is owned
        ammo="Seraphic Ampulla",
        head={name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5','CHR+4','Mag. Acc.+14','"Mag.Atk.Bns."+15'}},neck="Combatant's Torque",ear1="Crep. Earring",ear2="Dedition Earring",
        body=gear.merlinic_nuke_body,hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Petrov Ring",ring2="Crepuscular Ring",
        back="Penetrating Cape",waist="Kuku Stone",legs="Perdition Slops",feet=gear.merlinic_nuke_feet}

    -- original: neck Adad Amulet (pet-only MAcc), ear2 C. Palug, back Conveyance, waist Regal Belt, legs Lengo, feet Merlinic Crackows
    sets.midcast.Impact = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head=empty,neck="Null Loop",ear1="Malignance Earring",ear2="Psystorm Earring",
        body="Twilight Cloak",hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back="Aurist's Cape +1",waist="Eschan Stone",legs={name="Bunzi's Pants", augments={'Path: A'}},feet={name="Bunzi's Sabots", augments={'Path: A'}}}

    sets.midcast.Impact.OccultAcumen = set_combine(sets.midcast['Elemental Magic'].OccultAcumen, {head=empty,body="Twilight Cloak"})

    sets.midcast['Divine Magic'] = set_combine(sets.midcast['Elemental Magic'], {
        head={name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5','CHR+4','Mag. Acc.+14','"Mag.Atk.Bns."+15'}}})

    -- original: Espiritus (no Dark stats), Adad Amulet, C. Palug, Merlinic Jubbah, Conveyance, Regal Belt, Lengo
    sets.midcast['Dark Magic'] = {main="Rubicundity",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head={name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+5','CHR+4','Mag. Acc.+14','"Mag.Atk.Bns."+15'}},neck="Erra Pendant",ear1="Malignance Earring",ear2="Psystorm Earring",
        body="Psycloth Vest",hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back="Perimede Cape",waist="Eschan Stone",legs={name="Bunzi's Pants", augments={'Path: A'}},feet={name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14'}}}

    -- Pixie Hairpin +1 (dark affinity), Fucho-no-Obi (Drain/Aspir +8)
    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {head="Pixie Hairpin +1",waist="Fucho-no-Obi"})

    sets.midcast.Aspir = sets.midcast.Drain

    -- original: hands Beck. Bracers +1 (not owned), ear2 C. Palug, waist Witful Belt
    sets.midcast.Stun = set_combine(sets.precast.FC, {})

    sets.midcast.Stun.Resistant = set_combine(sets.precast.FC, {main="Daybreak",sub="Ammurapi Shield",ear2="Psystorm Earring",
        feet={name="Merlinic Crackows", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','"Occult Acumen"+4','Mag. Acc.+6','"Mag.Atk.Bns."+14'}}})

    -- original: sub Umbra Strap, neck Adad Amulet (pet-only MAcc), ear2 C. Palug, back Conveyance, waist Regal Belt, legs Lengo, feet Merlinic
    sets.midcast['Enfeebling Magic'] = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Befouled Crown",neck="Null Loop",ear1="Malignance Earring",ear2="Psystorm Earring",
        body={name="Merlinic Jubbah", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','CHR+2','Mag. Acc.+11','"Mag.Atk.Bns."+9'}},hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Kishar Ring",ring2="Stikini Ring",
        back="Aurist's Cape +1",waist="Rumination Sash",legs={name="Bunzi's Pants", augments={'Path: A'}},feet={name="Bunzi's Sabots", augments={'Path: A'}}}

    sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {ring1="Stikini Ring"})

    sets.midcast.Dia = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast.Diaga = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast['Dia II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast.Bio = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast['Bio II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)

    -- original: main Espiritus/Umbra Strap, neck Adad Amulet, ear2 C. Palug, back Conveyance Cape
    sets.midcast['Enhancing Magic'] = {main=gear.gada_enhancing_club,sub="Ammurapi Shield",ammo="Impatiens",
        head={name="Telchine Cap", augments={'Mag. Acc.+20','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="Andoaa Earring",ear2="Magnetic Earring",
        body={name="Telchine Chas.", augments={'Mag. Acc.+24','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},hands={name="Telchine Gloves", augments={'Mag. Acc.+23','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},ring1="Stikini Ring",ring2="Stikini Ring",
        back="Perimede Cape",waist="Embla Sash",legs={name="Telchine Braconi", augments={'Mag. Acc.+15','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}},feet={name="Telchine Pigaches", augments={'Mag. Acc.+18','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}}}

    sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {head={name="Bunzi's Hat", augments={'Path: A'}}})
    -- original: main Espiritus/Genmei Shield, waist Regal Belt, legs Lengo Pants (SIRD 10%)
    sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {head={name="Bunzi's Hat", augments={'Path: A'}},hands={name="Bunzi's Gloves", augments={'Path: A'}},waist="Rumination Sash",legs={name="Bunzi's Pants", augments={'Path: A'}}})
    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {neck="Nodens Gorget",waist="Siegel Sash",legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}}})
    sets.midcast.BarElement = set_combine(sets.precast.FC['Enhancing Magic'], {legs={name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1'}}})

    -- Avatar pact sets.  All pacts are Ability type.

    -- Buff wards: summoning magic skill (Beck. Horn +23, Doublet +24, Spats +30, Glyphic Bracers +23, Evoker's +10,
    -- Conveyance +8, Lucidity +7, C. Palug +5) and Avatar Lv.+1 (Beck. Earring +1, Bunzi's Sabots)
    -- original: Beckoner's +1 head/body/hands/legs/feet (not owned), Andoaa/Lugalbanda
    sets.midcast.Pet.BloodPactWard = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +3",neck="Adad Amulet",ear1="C. Palug Earring",ear2="Beck. Earring +1",
        body="Beck. Doublet +3",hands="Glyphic Bracers +3",ring1="Evoker's Ring",ring2="Stikini Ring",
        back="Conveyance Cape",waist="Lucidity Sash",legs="Beck. Spats +3",feet={name="Bunzi's Sabots", augments={'Path: A'}}}

    -- Debuff wards: avatar Magic Accuracy (Beckoner's +3: +60-64 each)
    -- original: Beckoner's +1 head/body/feet (not owned), Chironic Gloves (SMN can't equip), C. Palug, Regal Belt, Assid. Pants +1
    sets.midcast.Pet.DebuffBloodPactWard = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +3",neck="Adad Amulet",ear1="Lugalbanda Earring",ear2="Beck. Earring +1",
        body="Beck. Doublet +3",hands="Beck. Bracers +3",ring1="Evoker's Ring",ring2="Stikini Ring",
        back=gear.magic_jse_back,waist="Incarnation Sash",legs="Beck. Spats +3",feet="Beck. Pigaches +3"}

    sets.midcast.Pet.DebuffBloodPactWard.Acc = sets.midcast.Pet.DebuffBloodPactWard

    -- Physical rage: Epitaph (BP dmg+16), Glyphic Horn +3 (avatar Atk+62), Glyphic Doublet +3 (avatar DA+15%, crit+20%),
    -- Beck. Bracers/Pigaches +3 (BP dmg+12 each), Enticer's Pants (BP dmg+12, TP Bonus+650), Lugalbanda (+10),
    -- Beck. Earring +1 (+4), Shulmanu Collar, Incarnation Sash
    -- original: Beckoner's +1 head/body/feet (not owned), Gelos Earring (not owned), Chironic Gloves (SMN can't equip),
    --   Regal Belt, Assid. Pants +1
    sets.midcast.Pet.PhysicalBloodPactRage = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head={name="Glyphic Horn +3", augments={'Enhances "Astral Flow" effect',}},neck="Shulmanu Collar",ear1="Lugalbanda Earring",ear2="Beck. Earring +1",
        body={name="Glyphic Doublet +3", augments={'Reduces Sp. "Blood Pact" MP cost',}},hands="Beck. Bracers +3",ring1="Stikini Ring",ring2="Stikini Ring",
        back=gear.phys_jse_back,waist="Incarnation Sash",legs={name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%'}},feet="Beck. Pigaches +3"}

    -- Resistant mode: avatar Accuracy (Beck. Horn +61, Doublet +64, Spats +63). original: {feet="Beck. Pigaches +1"} (not owned)
    sets.midcast.Pet.PhysicalBloodPactRage.Acc = {head="Beckoner's Horn +3",body="Beck. Doublet +3",legs="Beck. Spats +3"}

    -- Magical rage: Espiritus (avatar MAB+120), Glyphic Horn +3 (avatar MAB+60), Beck. Doublet/Bracers/Pigaches +3
    -- (BP dmg+13/12/12), Enticer's Pants, Adad Amulet, Regal Belt (avatar MAB+10)
    -- original: Grioavolr (its augments boost YOUR MAB, not the avatar's), Beckoner's +1 head/body/feet (not owned),
    --   Gelos Earring (not owned), Chironic Gloves (SMN can't equip), Conveyance Cape
    sets.midcast.Pet.MagicalBloodPactRage = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head={name="Glyphic Horn +3", augments={'Enhances "Astral Flow" effect',}},neck="Adad Amulet",ear1="Lugalbanda Earring",ear2="Beck. Earring +1",
        body="Beck. Doublet +3",hands="Beck. Bracers +3",ring1="Stikini Ring",ring2="Stikini Ring",
        back=gear.magic_jse_back,waist="Regal Belt",legs={name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%'}},feet="Beck. Pigaches +3"}

    -- Resistant mode: avatar Magic Accuracy. original: {head="Beckoner's Horn +1",feet="Beck. Pigaches +1"} (not owned)
    sets.midcast.Pet.MagicalBloodPactRage.Acc = {head="Beckoner's Horn +3",legs="Beck. Spats +3"}

    -- Spirits cast magic spells, which can be identified in standard ways.

    sets.midcast.Pet.WhiteMagic = {} --legs="Summoner's Spats"

    sets.midcast.Pet['Elemental Magic'] = set_combine(sets.midcast.Pet.MagicalBloodPactRage, {}) --legs="Summoner's Spats"

    sets.midcast.Pet['Elemental Magic'].Resistant = {}

    sets.midcast.Pet['Impact'] = sets.midcast.Pet.DebuffBloodPactWard

    -- Flaming Crush (hybrid): magical set. original: Grioavolr, Beckoner's +1 (not owned), Gelos, Chironic Gloves,
    --   Regal Belt, Assid. Pants +1
    sets.midcast.Pet['Flaming Crush'] = set_combine(sets.midcast.Pet.MagicalBloodPactRage, {})

    sets.midcast.Pet['Flaming Crush'].Acc = set_combine(sets.midcast.Pet.MagicalBloodPactRage.Acc, {})

    -- original: each of these = Physical set with Enticer's Pants legs (now in the Physical set itself)
    sets.midcast.Pet['Mountain Buster'] = set_combine(sets.midcast.Pet.PhysicalBloodPactRage, {})
    sets.midcast.Pet['Mountain Buster'].Acc = set_combine(sets.midcast.Pet.PhysicalBloodPactRage.Acc, {})
    sets.midcast.Pet['Rock Buster'] = set_combine(sets.midcast.Pet.PhysicalBloodPactRage, {})
    sets.midcast.Pet['Rock Buster'].Acc = set_combine(sets.midcast.Pet.PhysicalBloodPactRage.Acc, {})
    sets.midcast.Pet['Crescent Fang'] = set_combine(sets.midcast.Pet.PhysicalBloodPactRage, {})
    sets.midcast.Pet['Crescent Fang'].Acc = set_combine(sets.midcast.Pet.PhysicalBloodPactRage.Acc, {})
    sets.midcast.Pet['Eclipse Bite'] = set_combine(sets.midcast.Pet.PhysicalBloodPactRage, {})
    sets.midcast.Pet['Eclipse Bite'].Acc = set_combine(sets.midcast.Pet.PhysicalBloodPactRage.Acc, {})
    sets.midcast.Pet['Blindside'] = set_combine(sets.midcast.Pet.PhysicalBloodPactRage, {})
    sets.midcast.Pet['Blindside'].Acc = set_combine(sets.midcast.Pet.PhysicalBloodPactRage.Acc, {})

    --------------------------------------
    -- Idle/resting/defense/etc sets
    --------------------------------------

    -- Idle sets (no avatar out). Refresh: Mpaca's Staff 2, Beck. Horn +3 4, C. Palug 1, Beck. Earring +1 2, Shomonjijoe +1 3,
    -- Assid. Pants +1 1. DT: Beck. Horn 10, Loricate 6, Beck. Earring +1 5, Bunzi's Gloves 8, Defending 10, Murky 10, Regal Belt 3, Bunzi's Sabots 6
    -- original: Beckoner's Horn +1 / Beck. Pigaches +1 (not owned), Ethereal Earring (not owned), Chironic Gloves (SMN can't
    --   equip), Stikini x2
    sets.idle = {main={name="Mpaca's Staff", augments={'Path: A'}},sub="Umbra Strap",ammo="Impatiens",
        head="Beckoner's Horn +3",neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="C. Palug Earring",ear2="Beck. Earring +1",
        body={name="Shomonjijoe +1", augments={'Path: A'}},hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Defending Ring",ring2={name="Murky Ring", augments={'Path: A',}},
        back="Conveyance Cape",waist="Regal Belt",legs="Assid. Pants +1",feet={name="Bunzi's Sabots", augments={'Path: A'}}}

    sets.resting = set_combine(sets.idle, {})

    -- original: Beckoner's Horn +1 (not owned), Ethereal Earring (not owned), ring2 Stikini Ring
    sets.idle.PDT = {main="Malignance Pole",sub="Umbra Strap",ammo="Impatiens",
        head="Beckoner's Horn +3",neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="C. Palug Earring",ear2="Beck. Earring +1",
        body={name="Nyame Mail", augments={'Path: B'}},hands={name="Nyame Gauntlets", augments={'Path: B'}},ring1="Defending Ring",ring2={name="Murky Ring", augments={'Path: A',}},
        back="Conveyance Cape",waist="Regal Belt",legs={name="Nyame Flanchard", augments={'Path: B'}},feet={name="Nyame Sollerets", augments={'Path: B'}}}

    -- perp costs:
    -- spirits: 7
    -- carby: 11 (5 with mitts)
    -- fenrir: 13
    -- others: 15
    -- avatar's favor: -4/tick

    -- Max useful -perp gear is 1 less than the perp cost (can't be reduced below 1)
    -- Aim for -14 perp, and refresh in other slots.
    -- LINKTRI: Beck. Doublet +3 (-8) + Beck. Pigaches +3 (-9) = -17 covers any avatar, so the other slots carry
    -- Refresh (Mpaca's Staff, Beck. Horn +3, C. Palug, Beck. Earring +1, Assid. Pants +1) and DT.
    -- Beck. Horn +3 also gives "Avatar's Favor"+5.
    -- original: Espiritus, Beckoner's Horn +1, Ethereal Earring, Shomonjijoe +1, Chironic Gloves/Slippers (SMN can't equip),
    --   Evoker's/Stikini, Lucidity Sash
    sets.idle.Avatar = {main={name="Mpaca's Staff", augments={'Path: A'}},sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +3",neck="Adad Amulet",ear1="C. Palug Earring",ear2="Beck. Earring +1",
        body="Beck. Doublet +3",hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Defending Ring",ring2={name="Murky Ring", augments={'Path: A',}},
        back="Conveyance Cape",waist="Regal Belt",legs="Assid. Pants +1",feet="Beck. Pigaches +3"}

    -- original: Beckoner's Horn +1, Ethereal Earring, Nyame Mail/Flanchard, Chironic Slippers (SMN can't equip), Stikini
    sets.idle.PDT.Avatar = {main="Malignance Pole",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +3",neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="C. Palug Earring",ear2="Beck. Earring +1",
        body="Beck. Doublet +3",hands={name="Nyame Gauntlets", augments={'Path: B'}},ring1="Defending Ring",ring2={name="Murky Ring", augments={'Path: A',}},
        back="Conveyance Cape",waist="Regal Belt",legs="Beck. Spats +3",feet="Beck. Pigaches +3"}

    -- Spirits (perp 7): Beck. Doublet +3 alone covers it. Glyphic Spats +3 shorten spirits' magic recast.
    -- original: Beckoner's Horn +1, Ethereal Earring, Shomonjijoe +1, Chironic Gloves/Slippers, Evoker's/Stikini, Assid. Pants +1
    sets.idle.Spirit = {main="Espiritus",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +3",neck="Adad Amulet",ear1="C. Palug Earring",ear2="Beck. Earring +1",
        body="Beck. Doublet +3",hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Defending Ring",ring2={name="Murky Ring", augments={'Path: A',}},
        back="Conveyance Cape",waist="Lucidity Sash",legs={name="Glyphic Spats +3", augments={'Increases Sp. "Blood Pact" accuracy',}},feet={name="Bunzi's Sabots", augments={'Path: A'}}}

    -- original: Beckoner's Horn +1 / Beck. Pigaches +1, Ethereal Earring, Nyame Mail, Stikini
    sets.idle.PDT.Spirit = {main="Malignance Pole",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +3",neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="C. Palug Earring",ear2="Beck. Earring +1",
        body="Beck. Doublet +3",hands={name="Nyame Gauntlets", augments={'Path: B'}},ring1="Defending Ring",ring2={name="Murky Ring", augments={'Path: A',}},
        back="Conveyance Cape",waist="Lucidity Sash",legs={name="Nyame Flanchard", augments={'Path: B'}},feet={name="Nyame Sollerets", augments={'Path: B'}}}

    --Favor always up and head is best in slot idle so no specific items here at the moment.
    sets.idle.Avatar.Favor = {}
    sets.idle.Avatar.Engaged = {}

    sets.idle.Avatar.Engaged.Carbuncle = {}
    sets.idle.Avatar.Engaged['Cait Sith'] = {}

    sets.perp = {}
    -- Caller's Bracer's halve the perp cost after other costs are accounted for.
    sets.perp.Day = {}
    sets.perp.Weather = {}

    sets.perp.Carbuncle = {}
    sets.perp.Diabolos = {}
    sets.perp.Alexander = sets.midcast.Pet.BloodPactWard

    -- Not really used anymore, was for the days of specific staves for specific avatars.
    sets.perp.staff_and_grip = {}

    -- Defense sets
    -- original PDT/MDT: Beckoner's Horn +1 (not owned), Ethereal Earring (not owned, PDT), ring2 Stikini Ring
    sets.defense.PDT = {main="Malignance Pole",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +3",neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="C. Palug Earring",ear2="Beck. Earring +1",
        body={name="Nyame Mail", augments={'Path: B'}},hands={name="Nyame Gauntlets", augments={'Path: B'}},ring1="Defending Ring",ring2={name="Murky Ring", augments={'Path: A',}},
        back="Conveyance Cape",waist="Regal Belt",legs={name="Nyame Flanchard", augments={'Path: B'}},feet={name="Nyame Sollerets", augments={'Path: B'}}}

    sets.defense.MDT = set_combine(sets.defense.PDT, {ear2="Sanare Earring"})

    -- original: Inyanga Jubbah +2, Telchine Gloves/Braconi/Pigaches, ring2 Stikini Ring
    sets.defense.MEVA = {main="Malignance Pole",sub="Umbra Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head={name="Bunzi's Hat", augments={'Path: A'}},neck={name="Loricate Torque +1", augments={'Path: A'}},ear1="Lugalbanda Earring",ear2="Sanare Earring",
        body={name="Bunzi's Robe", augments={'Path: A'}},hands={name="Bunzi's Gloves", augments={'Path: A'}},ring1="Defending Ring",ring2={name="Murky Ring", augments={'Path: A',}},
        back="Conveyance Cape",waist="Regal Belt",legs="Beck. Spats +3",feet="Beck. Pigaches +3"}

    sets.Kiting = {ring1="Shneddick Ring +1"}
    sets.latent_refresh = {waist="Fucho-no-Obi"} -- original: {waist="Regal Belt"} (no Refresh)
    -- sets.latent_refresh_grip = {sub="Umbra Strap"} -- LINKTRI: Umbra Strap has no latent refresh
    -- sets.TPEat = {neck="Adad Amulet"}            -- LINKTRI: Adad Amulet doesn't convert TP
    sets.DayIdle = {}
    sets.NightIdle = {}

    -- HPDown is only used by Sel's curecheat (dormant). original: Beckoner's +1 pieces, Ethereal Earring (not owned)
    sets.HPDown = {head="Beckoner's Horn +3",ear1="C. Palug Earring",ear2="Etiolation Earring",
        body="Beck. Doublet +3",hands="Beck. Bracers +3",ring1="Mephitas's Ring",ring2="Stikini Ring",
        back="Conveyance Cape",legs="Assid. Pants +1",feet="Beck. Pigaches +3"}

    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Sleep = {} -- original: {neck="Adad Amulet"} (nothing for Sleep)

    -- Weapons sets
    -- sets.weapons.Khatvanga = {main="Khatvanga",sub="Bloodrain Strap"} -- LINKTRI: restore (and add to state.Weapons) when Khatvanga is owned

    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}

    --------------------------------------
    -- Engaged sets
    --------------------------------------

    -- Normal melee group
    -- original: Beckoner's +1 head/body/feet (not owned), Lugalbanda/Gelos (Gelos not owned), Regal Belt
    sets.engaged = {main="Espiritus",sub="Bloodrain Strap",ammo={name="Epitaph", augments={'Path: A'}},
        head="Beckoner's Horn +3",neck="Shulmanu Collar",ear1="Crep. Earring",ear2="Telos Earring",
        body="Beck. Doublet +3",hands={name="Gazu Bracelets +1", augments={'Path: A'}},ring1="Petrov Ring",ring2="Crepuscular Ring",
        back=gear.phys_jse_back,waist="Kuku Stone",legs="Assid. Pants +1",feet="Beck. Pigaches +3"}

    sets.packing = {
        main  = {name="Mpaca's Staff", augments={'Path: A'}},
        sub   = "Umbra Strap",
        ammo  = "Impatiens",
        head  = "Nyame Helm",
        neck  = {name="Loricate Torque +1", augments={'Path: A'}},
        ear1  = "C. Palug Earring",
        ear2  = "Beck. Earring +1",         -- original: Ethereal Earring (not owned)
        body  = {name="Shomonjijoe +1", augments={'Path: A'}},
        hands = "Nyame Gauntlets",
        ring1 = "Defending Ring",
        ring2 = "Stikini Ring",
        back  = "Conveyance Cape",
        waist = "Fucho-no-Obi",
        legs  = "Assid. Pants +1",
        feet  = "Nyame Sollerets"
    }
end

-- LINKTRI (2026-10-20): renamed from job_customize_idle_set. That name replaced SMN.lua's own version, which adds the
-- day/weather/per-avatar perpetuation sets, Avatar's Favor and avatar-engaged sets, latent refresh and Sublimation gear.
-- SMN.lua's runs first now; this only adds the Porter Moogle packing set.
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
function select_default_macro_book(reset)
    if reset == 'reset' then
        -- lost pet, or tried to use pact when pet is gone
    end

    -- Default macro set/book
    set_macro_page(1, 15)
end
