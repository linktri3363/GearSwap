-------------------------------------------------------------------------------------------------------------------
-- Linktri BRD gear file (Selindrile framework)
-- Rev 2026-10-04: 5-song audit (Daurdabla + Clarion Call), instrument routing, Null/Murky/Alabaster integration,
--                 TP-safe instrument policy, equippability fixes.
--
-- INSTRUMENT / WEAPON ROUTING (what each song gets)
--   Gjallarhorn  : default for every buff song (All Songs +4) and for debuff accuracy (Resistant mode).
--   Marsyas      : Honor March (required to cast), plus duration-only songs: Foe Lullaby, Mazurka, Hymnus.
--   Daurdabla    : dummy songs (ExtraSongsMode Dummy), FullLength extra songs, Horde Lullaby AoE (string radius).
--   Carnwenhan   : main hand for every song (+50% duration only works in MAIN).
--   Kali (Path D): off hand when you can dual wield (+5% duration works in OFF hand, FC+7, +10 string/wind).
--                  With no DW sub, songs use Genmei Shield (buffs) / Ammurapi Shield (debuffs) instead.
--
-- 5-SONG WORKFLOW
--   Songs 1-2 : any instrument (normal casts).
--   Songs 3-4 : must be sung with Daurdabla equipped. Either sing cheap dummies (Dummy mode) and then overwrite
--               them with real Gjallarhorn songs, or sing the real song with FullLength (loses Gjallarhorn's +4).
--   Song  5   : Clarion Call. While it is active, the CC song always takes slot 3, so songs 4 AND 5 need Daurdabla.
--   Keep all 5 alive by re-singing before anything expires; if a slot is dispelled you need Clarion Call again.
--   AutoDummy (ON by default; Ctrl+Alt+`  or  //gs c autodummy) flips Dummy mode on automatically for the slots
--   that need Daurdabla (counts the songs on yourself, so sing AoE songs on <me>).
--
-- TP SAFETY: swapping instrument -> ammo empties the range slot and zeroes TP. Every set in this file keeps an
--   instrument in range and never uses an ammo. (Linos would be the real melee/WS instrument; not owned.)
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- No-interruptions: replays the last known position packet while casting so movement doesn't interrupt.
-- Toggle in game with:  //gs c interrupts
-------------------------------------------------------------------------------------------------------------------
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
            windower.add_to_chat(160, ("%s : Disabling \30\2no_interruptions\30\43"):format(_addon.name))
            no_interruptions = false
        else
            windower.add_to_chat(160, ("%s : Enabling \30\2no_interruptions\30\43"):format(_addon.name))
            no_interruptions = true
        end
        return true
    end
    return false
end)

-- PorterPacker support: tracks whether we are standing next to a Porter Moogle.
near_porter = false

-------------------------------------------------------------------------------------------------------------------
-- AutoDummy (5-song helper). Wraps BRD.lua's job_precast instead of editing it.
-- Works with old or new BRD.lua. If a newer BRD.lua ships its own AutoDummyMode, that one is switched off and
-- this one is used, because this version knows the Clarion Call slot doesn't need Daurdabla:
--   no Clarion Call : songs 1-2 normal, songs 3-4 dummied on Daurdabla, then real songs overwrite the dummies.
--   Clarion Call up : songs 1-3 normal (3 = CC slot), songs 4-5 dummied, then real songs overwrite the dummies.
-- It counts the songs on YOU, so sing AoE songs on <me>. Debuffs and Pianissimo songs are never touched.
-------------------------------------------------------------------------------------------------------------------
local brd_song_buff_ids = S{195,196,197,198,199,200,201,202,203,204,205,206,
                            207,208,209,210,211,212,213,214,215,216,218,219,
                            220,221,222,223}

local CLARION_CALL_ID = 499

-- Reads the live buff list once: number of song buffs on you, whether Clarion Call is up, and the song names.
local function read_song_state()
    local n, cc, names = 0, false, {}
    local p = windower.ffxi.get_player()
    if p and p.buffs then
        for _, id in ipairs(p.buffs) do
            if brd_song_buff_ids:contains(id) then
                n = n + 1
                names[#names + 1] = (res and res.buffs and res.buffs[id] and res.buffs[id].en) or tostring(id)
            elseif id == CLARION_CALL_ID then
                cc = true
            end
        end
    end
    -- Belt and braces: also accept GearSwap's and Selindrile's views of the buff.
    if buffactive['Clarion Call'] or buffactive[CLARION_CALL_ID] or (state.Buff and state.Buff['Clarion Call']) then
        cc = true
    end
    return n, cc, names
end

local brd_base_job_precast = job_precast
function job_precast(spell, spellMap, eventArgs)
    if spell.type == 'BardSong' and state.LinktriAutoDummy and state.LinktriAutoDummy.value
       and not state.ExtraSongsMode.value:endswith('Lock') then
        if spell.targets.Enemy or buffactive['Pianissimo'] or spell.target.type ~= 'SELF' then
            -- Debuffs and single-target songs are never auto-dummied.
        else
            local have, cc = read_song_state()
            local normal = cc and 3 or 2                       -- slots that don't need Daurdabla
            local cap    = normal + (info.ExtraSongs or 0)     -- 4, or 5 with Clarion Call
            local dummy  = have >= normal and have < cap
            if dummy then
                state.ExtraSongsMode:set('Dummy')
            elseif state.ExtraSongsMode.value == 'Dummy' then
                state.ExtraSongsMode:reset()
            end
            windower.add_to_chat(dummy and 158 or 122, ('AutoDummy: %d songs on you, Clarion Call %s, cap %d -> %s'):format(
                have, cc and 'YES' or 'no', cap, dummy and 'Daurdabla dummy' or 'real song'))
            if dummy and spell.english:find('Honor March') then
                windower.add_to_chat(167, 'AutoDummy: Honor March needs Marsyas and cannot be a dummy - use Paeon/Pastoral/Aubade for dummies.')
            end
        end
    end
    if brd_base_job_precast then
        return brd_base_job_precast(spell, spellMap, eventArgs)
    end
end

function user_job_setup()
    -- Options: Override default values
    state.OffenseMode:options("Normal", "Acc")
    state.HybridMode:options("Normal", "DT")
    state.CastingMode:options("Normal", "Resistant", "AoE")
    state.IdleMode:options("Normal", "DT", "NoRefresh", "Aminon")
    state.Weapons:options("Songs", "SongsShield", "None", "MpuGandring", "Naegling", "DualNaegling", "Aeneas",
        "DualWeapons", "Twashtar", "Club", "Aeolian")
    -- Weapon set Selindrile picks on load / subjob change / "gs c weapons Default" (Ctrl+R):
    --   dual-wield subjob (/NIN, /DNC)      -> default_dual_weapons (Selindrile's own default is "DualWeapons")
    --   non-mage subjob without dual wield  -> default_weapons
    --   mage subjob (/WHM, /RDM, /SCH...)   -> first entry in the Weapons list ("Songs"); press F7 once for SongsShield
    default_dual_weapons = "Songs"
    default_weapons      = "SongsShield"

    -- Whether to use Carn (or song daggers in general) under a certain threshhold even when weapons are locked.
    state.CarnMode = M {"Always", "300", "1000", "Never"}

    -- AutoDummy: always ours (see notes at top). If a newer BRD.lua has its own, keep it off so they don't fight.
    if state.AutoDummyMode then state.AutoDummyMode:set(false) end
    state.LinktriAutoDummy = M(true, "Auto Dummy Songs")   -- ON by default; Ctrl+Alt+` or //gs c autodummy to toggle

    -- Capes: no Intarabus's Cape yet. Null Shawl (Acc/MAcc+50, DA+7, STP+7, MEva+50) beats Rhapsode's Cape
    -- (MAcc+13) everywhere, so Rhapsode's is no longer used and can go to storage.
    gear.song_back  = "Null Shawl"
    gear.melee_back = "Null Shawl"

    -- Instrument that stays in the range slot for every non-song set (keeps TP when swapping back from songs).
    gear.idle_instrument = "Gjallarhorn"

    -- Daurdabla owned: two extra songs (four total, five with Clarion Call).
    info.ExtraSongInstrument = "Daurdabla"
    info.ExtraSongs = 2

    -- Set this to false if you don't want to use custom timers.
    state.UseCustomTimers = M(false, "Use Custom Timers")

    -- Additional local binds
    send_command("bind ^` gs c cycle ExtraSongsMode")
    send_command("bind ^!` gs c autodummy")
    send_command('bind !` input /ma "Chocobo Mazurka" <me>')
    send_command("bind @` gs c cycle MagicBurstMode")
    send_command("bind @f10 gs c cycle RecoverMode")
    send_command("bind @f8 gs c toggle AutoNukeMode")
    send_command("bind !r gs c weapons None;gs c update")
    send_command("bind !q gs c weapons Aeolian;gs c update")
    send_command("bind ^q gs c weapons Naegling;gs c update")
    send_command("bind !f7 gs c cycle CarnMode")

    select_default_macro_book()
end

function user_job_self_command(commandArgs, eventArgs)
    local cmd = commandArgs[1] and commandArgs[1]:lower()

    -- //gs c aoetest        : wear the full Horde Lullaby II AoE midcast and lock it, so you can read
    --                         String Instrument skill in the Status > Skills menu.
    -- //gs c aoetest fili   : same, but Fili Manchettes +3 instead of Brioso Cuffs +4 (more string, no Lullaby+).
    -- //gs c aoetest off    : unlock and return to normal gear.
    if cmd == 'aoetest' then
        local opt = commandArgs[2] and commandArgs[2]:lower()
        if opt == 'off' then
            send_command('gs enable all;wait 0.5;gs c update')
            windower.add_to_chat(122, 'AoE test off.')
        else
            local aoe = sets.midcast["Horde Lullaby II"].AoE
            local test = set_combine(sets.midcast.SongDebuff, aoe, can_dual_wield and sets.midcast.SongDebuff.DW or {})
            if opt == 'fili' then test = set_combine(test, {hands = "Fili Manchettes +3"}) end
            -- unlock synchronously so a second test (e.g. 'fili') isn't blocked by the first lock
            enable('main','sub','range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
            equip(test)
            send_command('wait 1;gs disable all')
            windower.add_to_chat(122, 'AoE test gear locked'..(opt == 'fili' and ' (Fili hands)' or '')..
                '. Check String Instrument skill. Breakpoints: 486 / 567 / 648. "//gs c aoetest off" to release.')
        end
        eventArgs.handled = true
        return
    end

    -- //gs c songcheck : print what AutoDummy sees right now (song count, Clarion Call, song names).
    if cmd == 'songcheck' then
        local have, cc, names = read_song_state()
        local cap = (cc and 3 or 2) + (info.ExtraSongs or 0)
        windower.add_to_chat(122, ('Songs on you: %d [%s] | Clarion Call: %s | cap %d | AutoDummy %s'):format(
            have, table.concat(names, ', '), cc and 'YES' or 'no', cap,
            (state.LinktriAutoDummy and state.LinktriAutoDummy.value) and 'ON' or 'OFF'))
        eventArgs.handled = true
        return
    end

    if cmd == 'autodummy' then
        state.LinktriAutoDummy:toggle()
        windower.add_to_chat(122, 'Auto Dummy Songs: '..(state.LinktriAutoDummy.value and 'ON' or 'OFF'))
        eventArgs.handled = true
    end
end

-- Song JAs that should pull you back to the song weapons (Carnwenhan + Kali / Genmei Shield).
local song_weapon_triggers = S{'nightingale', 'troubadour', 'clarion call'}

local function switch_to_song_weapons(reason)
    local target = can_dual_wield and 'Songs' or 'SongsShield'
    if state.Weapons.value == target then return end
    windower.add_to_chat(122, ('%s: switching weapons %s -> %s'):format(reason, state.Weapons.value, target))
    send_command('gs c weapons '..target)
end

function user_job_buff_change(buff, gain)
    -- Fires only when the buff actually lands, so a failed/interrupted JA doesn't swap you.
    if gain and buff and song_weapon_triggers:contains(buff:lower()) then
        switch_to_song_weapons(buff)
    end

    if buff and buff:lower() == 'clarion call' and gain then
        windower.add_to_chat(122, 'Clarion Call: song 3 = any instrument, songs 4 + 5 need Daurdabla. AutoDummy is '..
            ((state.LinktriAutoDummy and state.LinktriAutoDummy.value) and 'ON.' or 'OFF - set Dummy/FullLength yourself.'))
    end
end

function user_job_unload()
    send_command("unbind ^!`")
end

function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Weapons sets
    sets.weapons.Songs        = {main = "Carnwenhan", sub = "Kali"}           -- /NIN or /DNC
    sets.weapons.SongsShield  = {main = "Carnwenhan", sub = "Genmei Shield"}  -- /WHM, /SCH, /RDM etc.
    sets.weapons.MpuGandring  = {main = "Mpu Gandring", sub = "Centovente"}
    sets.weapons.Naegling     = {main = "Naegling", sub = "Genmei Shield"}
    sets.weapons.DualNaegling = {main = "Naegling", sub = "Centovente"}
    sets.weapons.Aeneas       = {main = "Aeneas", sub = "Genmei Shield"}
    sets.weapons.DualWeapons  = {main = "Aeneas", sub = "Centovente"}
    sets.weapons.Twashtar     = {main = "Twashtar", sub = "Centovente"}
    sets.weapons.Club         = {main = "Daybreak", sub = "Gleti's Knife"}
    sets.weapons.Aeolian      = {main = "Aeneas", sub = "Malevolence"}

    sets.buff.Sublimation = {waist = "Embla Sash"}
    sets.buff.DTSublimation = {waist = "Embla Sash"}

    ---------------------------------------------------------------------------------------------------------------
    -- Precast Sets
    ---------------------------------------------------------------------------------------------------------------

    -- Generic fast cast (no ammo: an Impatiens here would unequip the instrument and zero TP)
    sets.precast.FC = {
        range = gear.idle_instrument,
        head  = "Bunzi's Hat",
        neck  = "Voltsurge Torque",
        ear1  = "Etiolation Earring",
        ear2  = "Fili Earring +1",
        body  = "Inyanga Jubbah +2",
        hands = "Bunzi's Gloves",     -- no FC on these (DT-8 filler); FC hands not owned yet (Leyline/Volte Gloves)
        ring1 = "Kishar Ring",
        ring2 = "Lebeche Ring",
        back  = gear.song_back,
        waist = "Embla Sash",
        legs  = "Aya. Cosciales +2",
        feet  = "Fili Cothurnes +3"
    }
    sets.precast.FC.DW = {sub = "Kali"}   -- Kali FC+7 in the off hand (only applied when weapons are unlocked)

    sets.precast.FC.DT = set_combine(sets.precast.FC, {
        neck  = "Null Loop",
        ear2  = "Alabaster Earring",
        ring2 = "Murky Ring"
    })

    sets.precast.FC.Cure = set_combine(sets.precast.FC, {feet = gear.chironic_cure_feet or "Kaykaus Boots +1"})  -- Cure cast time -7%
    sets.precast.FC["Enhancing Magic"] = set_combine(sets.precast.FC, {waist = "Siegel Sash"})
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main = "Daybreak", sub = "Ammurapi Shield"})

    -- Songs
    sets.precast.FC.BardSong = set_combine(sets.precast.FC, {range = "Gjallarhorn"})
    sets.precast.FC.BardSong.DW = {sub = "Kali"}

    sets.precast.FC.SongDebuff = sets.precast.FC.BardSong

    -- Anything with its own precast entry here must be a FULL set (these are picked by spell name).
    sets.precast.FC["Honor March"] = set_combine(sets.precast.FC.BardSong, {range = "Marsyas"})  -- required to cast
    sets.precast.FC.Mazurka        = set_combine(sets.precast.FC.BardSong, {range = "Marsyas"})

    sets.precast.FC["Horde Lullaby"]              = set_combine(sets.precast.FC.BardSong, {range = "Daurdabla"})
    sets.precast.FC["Horde Lullaby"].Resistant    = set_combine(sets.precast.FC.BardSong, {range = "Gjallarhorn"})
    sets.precast.FC["Horde Lullaby"].AoE          = set_combine(sets.precast.FC.BardSong, {range = "Daurdabla"})
    sets.precast.FC["Horde Lullaby II"]           = sets.precast.FC["Horde Lullaby"]
    sets.precast.FC["Horde Lullaby II"].Resistant = sets.precast.FC["Horde Lullaby"].Resistant
    sets.precast.FC["Horde Lullaby II"].AoE       = sets.precast.FC["Horde Lullaby"].AoE

    sets.precast.FC.Daurdabla = set_combine(sets.precast.FC.BardSong, {range = info.ExtraSongInstrument})
    sets.precast.DaurdablaDummy = sets.precast.FC.Daurdabla

    -- Precast sets to enhance JAs
    sets.precast.JA.Nightingale  = {feet = "Bihu Slippers +3"}
    sets.precast.JA.Troubadour   = {body = "Bihu Just. +4"}
    sets.precast.JA["Soul Voice"] = {legs = "Bihu Cannions +3"}

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {legs = "Dashing Subligar"}

    ---------------------------------------------------------------------------------------------------------------
    -- Weaponskill sets (instrument stays on; no ammo)
    ---------------------------------------------------------------------------------------------------------------
    sets.precast.WS = {
        range = gear.idle_instrument,
        head  = "Nyame Helm",
        neck  = "Rep. Plat. Medal",
        ear1  = "Moonshade Earring",
        ear2  = "Ishvara Earring",
        body  = "Bihu Just. +4",
        hands = "Nyame Gauntlets",
        ring1 = "Epona's Ring",
        ring2 = "Ilabrat Ring",
        back  = gear.melee_back,
        waist = "Sailfi Belt +1",
        legs  = "Nyame Flanchard",
        feet  = "Nyame Sollerets"
    }
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {neck = "Null Loop", ear2 = "Mache Earring +1", ring1 = "Chirich Ring +1"})

    sets.precast.WS["Savage Blade"] = set_combine(sets.precast.WS, {ring1 = "Metamor. Ring +1"})
    sets.precast.WS["Rudra's Storm"] = sets.precast.WS
    sets.precast.WS["Ruthless Stroke"] = sets.precast.WS
    sets.precast.WS["Evisceration"] = set_combine(sets.precast.WS, {ear2 = "Mache Earring +1"})

    -- Mordant Rime: 70% CHR / 30% DEX, no TP scaling (no Moonshade)
    sets.precast.WS["Mordant Rime"] = set_combine(sets.precast.WS, {
        ear1  = "Ishvara Earring",
        ear2  = "Mache Earring +1",
        ring1 = "Metamor. Ring +1"
    })

    sets.precast.WS["Aeolian Edge"] = set_combine(sets.precast.WS, {
        neck  = "Baetyl Pendant",
        ear2  = "Crematio Earring",
        body  = "Nyame Mail",
        ring1 = "Metamor. Ring +1",
        waist = "Orpheus's Sash"
    })

    -- Swap to these on Moonshade using WS if at 3000 TP
    sets.MaxTP = {ear1 = "Ishvara Earring", ear2 = "Telos Earring"}
    sets.AccMaxTP = {ear1 = "Mache Earring +1", ear2 = "Telos Earring"}

    ---------------------------------------------------------------------------------------------------------------
    -- Midcast Sets
    ---------------------------------------------------------------------------------------------------------------

    -- General set for recast times.
    sets.midcast.FastRecast = set_combine(sets.precast.FC, {})

    -- ---- Song buffs: duration + Fili set bonus ("Augments songs"), DT in the filler slots ----
    sets.midcast.SongEffect = {
        main  = "Carnwenhan",
        sub   = "Genmei Shield",
        range = "Gjallarhorn",
        head  = "Fili Calot +3",
        neck  = "Null Loop",
        ear1  = "Alabaster Earring",
        ear2  = "Fili Earring +1",
        body  = "Fili Hongreline +3",
        hands = "Fili Manchettes +3",
        ring1 = "Murky Ring",
        ring2 = "Defending Ring",
        back  = gear.song_back,
        waist = "Null Belt",
        legs  = "Inyanga Shalwar +2",
        feet  = "Brioso Slippers +2"
    }
    -- Overlaid by BRD.lua when you can dual wield. Kali's +5% duration works off hand; Carnwenhan's only main.
    sets.midcast.SongEffect.DW = {main = "Carnwenhan", sub = "Kali"}

    -- Song-type overlays (laid on top of SongEffect)
    sets.midcast.Ballad   = {legs = "Fili Rhingrave +3"}   -- Ballad+; costs Inyanga's duration (shorter than your other songs)
    sets.midcast.Madrigal = {head = "Fili Calot +3"}
    sets.midcast.March    = {hands = "Fili Manchettes +3"}
    sets.midcast["Honor March"] = {range = "Marsyas", hands = "Fili Manchettes +3"}
    sets.midcast.Minuet   = {body = "Fili Hongreline +3"}
    sets.midcast.Minne    = {}
    sets.midcast["Sentinel's Scherzo"] = {feet = "Fili Cothurnes +3"}
    -- Duration-only songs: Marsyas' +50% beats Gjallarhorn here
    sets.midcast.Mazurka  = {range = "Marsyas"}
    sets.midcast["Goddess's Hymnus"] = {range = "Marsyas"}

    -- Paeon is the go-to dummy song: fast recast gear, no duration gear.
    sets.midcast.Paeon = {
        head  = "Bunzi's Hat",
        body  = "Inyanga Jubbah +2",
        hands = "Bunzi's Gloves",
        legs  = "Aya. Cosciales +2",
        feet  = "Fili Cothurnes +3",
        waist = "Embla Sash",
        ring1 = "Kishar Ring"
    }

    -- ---- Extra songs (Daurdabla) ----
    -- FullLength: normal song gear, Daurdabla swapped in (BRD.lua overlays this).
    sets.midcast.Daurdabla = {range = info.ExtraSongInstrument}

    -- Dummy: keep it short so the next real song overwrites it. No main-hand swap (that would cost TP).
    sets.midcast.DaurdablaDummy = set_combine(sets.midcast.Paeon, {range = info.ExtraSongInstrument})

    -- Songs that are only ever used as dummies always go out on Daurdabla.
    sets.midcast["Herb Pastoral"]   = {range = info.ExtraSongInstrument}
    sets.midcast["Fowl Aubade"]     = {range = info.ExtraSongInstrument}
    sets.midcast["Goblin Gavotte"]  = {range = info.ExtraSongInstrument}
    sets.midcast["Puppet's Operetta"] = {range = info.ExtraSongInstrument}
    sets.midcast["Gold Capriccio"]  = {range = info.ExtraSongInstrument}
    sets.midcast["Warding Round"]   = {range = info.ExtraSongInstrument}

    -- ---- Song debuffs ----
    -- Normal: accuracy with duration where it's cheap (Fili body, Inyanga legs, Brioso Slippers).
    sets.midcast.SongDebuff = {
        main  = "Carnwenhan",
        sub   = "Ammurapi Shield",
        range = "Gjallarhorn",
        head  = "Brioso Roundlet +4",
        neck  = "Null Loop",
        ear1  = "Crep. Earring",
        ear2  = "Fili Earring +1",
        body  = "Fili Hongreline +3",
        hands = "Brioso Cuffs +4",
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back  = gear.song_back,
        waist = "Null Belt",
        legs  = "Inyanga Shalwar +2",
        feet  = "Brioso Slippers +2"
    }
    sets.midcast.SongDebuff.DW = {main = "Carnwenhan", sub = "Kali"}   -- Kali Path D: MAcc+15 +10 wind/string

    -- Resistant: five Brioso pieces for the full set bonus.
    sets.midcast.SongDebuff.Resistant = set_combine(sets.midcast.SongDebuff, {
        body  = "Brioso Justau. +2",
        legs  = "Brios. Cann. +4"
    })

    -- Foe Lullaby: duration-only, so Marsyas on Normal. Brioso Cuffs +4 = Lullaby+.
    sets.midcast.Lullaby = {range = "Marsyas", hands = "Brioso Cuffs +4"}
    sets.midcast.Lullaby.Resistant = {range = "Gjallarhorn", hands = "Brioso Cuffs +4"}

    -- Horde Lullaby I/II: Daurdabla (string skill sets the AoE radius). AoE mode stacks string skill.
    sets.midcast["Horde Lullaby"] = {range = "Daurdabla", hands = "Brioso Cuffs +4"}
    sets.midcast["Horde Lullaby"].Resistant = {range = "Gjallarhorn", hands = "Brioso Cuffs +4"}
    sets.midcast["Horde Lullaby"].AoE = {
        range = "Daurdabla",
        head  = "Brioso Roundlet +4",
        body  = "Brioso Justau. +2",
        hands = "Brioso Cuffs +4",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        feet  = "Bihu Slippers +3"
    }
    sets.midcast["Horde Lullaby II"] = sets.midcast["Horde Lullaby"]
    sets.midcast["Horde Lullaby II"].Resistant = sets.midcast["Horde Lullaby"].Resistant
    sets.midcast["Horde Lullaby II"].AoE = sets.midcast["Horde Lullaby"].AoE

    -- Finale is a dispel; land it.
    sets.midcast["Magic Finale"] = sets.midcast.SongDebuff.Resistant

    ---------------------------------------------------------------------------------------------------------------
    -- Other magic
    ---------------------------------------------------------------------------------------------------------------
    sets.midcast.Cure = {
        main  = "Daybreak",
        sub   = "Genmei Shield",
        range = gear.idle_instrument,
        head  = "Kaykaus Mitra +1",
        neck  = "Nodens Gorget",
        ear1  = "Meili Earring",
        ear2  = "Odnowa Earring +1",
        body  = "Kaykaus Bliaut +1",
        hands = "Kaykaus Cuffs +1",
        ring1 = "Naji's Loop",
        ring2 = "Lebeche Ring",
        back  = "Aurist's Cape +1",
        waist = "Luminary Sash",
        legs  = "Kaykaus Tights +1",
        feet  = "Kaykaus Boots +1"
    }
    sets.midcast.LightWeatherCure = set_combine(sets.midcast.Cure, {waist = "Hachirin-no-Obi"})
    sets.midcast.LightDayCure = sets.midcast.LightWeatherCure
    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {ring2 = "Persis Ring"})

    sets.Self_Healing = {}
    sets.Cure_Received = {}
    sets.Self_Refresh = {}

    sets.midcast.Cursna = set_combine(sets.midcast.Cure, {
        neck  = "Null Loop",
        ring1 = "Menelaus's Ring",
        feet  = "Gende. Galosh. +1"
    })

    sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {
        head = "Vanya Hood",
        body = "Vanya Robe",
        ear2 = "Meili Earring",
        ring2 = "Menelaus's Ring"
    })

    sets.midcast["Enhancing Magic"] = {
        range = gear.idle_instrument,
        head  = gear.telchine_enh_head or "Telchine Cap",
        neck  = "Voltsurge Torque",
        ear1  = "Andoaa Earring",
        ear2  = "Etiolation Earring",
        body  = gear.telchine_enh_body or "Telchine Chas.",
        hands = gear.telchine_enh_hands or "Telchine Gloves",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back  = "Null Shawl",
        waist = "Embla Sash",
        legs  = gear.telchine_enh_legs or "Telchine Braconi",
        feet  = gear.telchine_enh_feet or "Telchine Pigaches"
    }
    sets.midcast.Regen     = set_combine(sets.midcast["Enhancing Magic"], {head = "Inyanga Tiara +2"})
    sets.midcast.Haste     = sets.midcast["Enhancing Magic"]
    sets.midcast.Refresh   = sets.midcast["Enhancing Magic"]
    sets.midcast.Stoneskin = set_combine(sets.midcast["Enhancing Magic"], {neck = "Nodens Gorget", waist = "Siegel Sash"})
    sets.midcast.Aquaveil  = sets.midcast["Enhancing Magic"]
    sets.midcast.Protect   = sets.midcast["Enhancing Magic"]
    sets.midcast.Protectra = sets.midcast.Protect
    sets.midcast.Shell     = sets.midcast.Protect
    sets.midcast.Shellra   = sets.midcast.Shell

    -- Merlinic is not BRD-equippable (old set silently failed); Bunzi's/Chironic are.
    sets.midcast["Elemental Magic"] = {
        main  = "Daybreak",
        sub   = "Ammurapi Shield",
        range = gear.idle_instrument,
        head  = "Bunzi's Hat",
        neck  = "Baetyl Pendant",
        ear1  = "Crematio Earring",
        ear2  = "Fili Earring +1",
        body  = "Bunzi's Robe",
        hands = "Bunzi's Gloves",
        ring1 = "Metamor. Ring +1",
        ring2 = "Stikini Ring",
        back  = "Null Shawl",
        waist = "Orpheus's Sash",
        legs  = "Bunzi's Pants",
        feet  = gear.chironic_nuke_feet or "Bunzi's Sabots"
    }
    sets.midcast["Elemental Magic"].Resistant = set_combine(sets.midcast["Elemental Magic"], {neck = "Null Loop", waist = "Null Belt"})

    sets.midcast["Absorb-TP"] = set_combine(sets.midcast.FastRecast, {neck = "Null Loop", ring2 = "Stikini Ring"})

    ---------------------------------------------------------------------------------------------------------------
    -- Idle / resting / defense
    ---------------------------------------------------------------------------------------------------------------
    sets.resting = {
        main  = "Daybreak",
        sub   = "Genmei Shield",
        range = gear.idle_instrument,
        head  = "Null Masque",
        neck  = "Null Loop",
        ear1  = "Alabaster Earring",
        ear2  = "Fili Earring +1",
        body  = "Kaykaus Bliaut +1",
        hands = "Fili Manchettes +3",
        ring1 = "Stikini Ring",
        ring2 = "Stikini Ring",
        back  = "Null Shawl",
        waist = "Fucho-no-Obi",
        legs  = "Assid. Pants +1",
        feet  = "Nyame Sollerets"
    }

    -- Normal: refresh-leaning but still DT-capped from Fili hands/legs + Null + Murky.
    sets.idle = {
        main  = "Daybreak",
        sub   = "Genmei Shield",
        range = gear.idle_instrument,
        head  = "Null Masque",
        neck  = "Null Loop",
        ear1  = "Alabaster Earring",
        ear2  = "Fili Earring +1",
        body  = "Kaykaus Bliaut +1",
        hands = "Fili Manchettes +3",
        ring1 = "Murky Ring",
        ring2 = "Stikini Ring",
        back  = "Null Shawl",
        waist = "Null Belt",
        legs  = "Fili Rhingrave +3",
        feet  = "Nyame Sollerets"
    }

    -- DT: the five-slot -DT core plus every DT accessory.
    sets.idle.DT = set_combine(sets.idle, {
        head  = "Fili Calot +3",
        body  = "Adamantite Armor",
        ring2 = "Defending Ring",
        waist = "Carrier's Sash"
    })

    sets.idle.NoRefresh = set_combine(sets.idle.DT, {head = "Null Masque", body = "Adamantite Armor"})

    sets.idle.Aminon = {
        range = gear.idle_instrument,
        head  = "Null Masque",
        neck  = "Null Loop",
        ear1  = "Alabaster Earring",
        ear2  = "Dedition Earring",
        body  = "Ashera Harness",
        hands = "Regal Gloves",
        ring1 = "Roller's Ring",
        ring2 = "Chirich Ring +1",
        back  = gear.melee_back,
        waist = "Sailfi Belt +1",
        legs  = "Nyame Flanchard",
        feet  = "Nyame Sollerets"
    }

    sets.defense.PDT = set_combine(sets.idle.DT, {body = "Adamantite Armor"})
    sets.defense.MDT = sets.idle.DT

    sets.Kiting = {feet = "Fili Cothurnes +3"}    -- ring slot stays free for whatever you rotate in
    sets.KitingNormal = sets.Kiting               -- saved copy; sets.Kiting is blanked while next to a Porter Moogle
    sets.latent_refresh = {waist = "Fucho-no-Obi"}
    -- sets.TreasureHunter comes from Linktri-Items.lua (Wh. Rarab Cap +1 + Chaac Belt).

    ---------------------------------------------------------------------------------------------------------------
    -- Engaged sets (instrument stays on; Gjallarhorn instead of Coiste Bodhar so songs don't zero your TP)
    ---------------------------------------------------------------------------------------------------------------
    sets.engaged = {
        range = gear.idle_instrument,
        head  = "Bunzi's Hat",
        neck  = "Null Loop",
        ear1  = "Crep. Earring",
        ear2  = "Telos Earring",
        body  = "Ashera Harness",
        hands = "Bunzi's Gloves",
        ring1 = "Chirich Ring +1",
        ring2 = "Chirich Ring +1",
        back  = gear.melee_back,
        waist = "Sailfi Belt +1",
        legs  = "Volte Tights",
        feet  = "Aya. Gambieras +2"
    }
    sets.engaged.Acc = set_combine(sets.engaged, {hands = "Gazu Bracelets +1", feet = "Nyame Sollerets"})
    sets.engaged.DT = set_combine(sets.engaged, {
        head  = "Nyame Helm",
        body  = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Murky Ring",
        ring2 = "Defending Ring",
        legs  = "Nyame Flanchard",
        feet  = "Nyame Sollerets"
    })
    sets.engaged.Acc.DT = sets.engaged.DT

    sets.engaged.DW = set_combine(sets.engaged, {ear1 = "Suppanomimi", waist = "Reiki Yotai"})
    sets.engaged.DW.Acc = set_combine(sets.engaged.Acc, {ear1 = "Suppanomimi", waist = "Reiki Yotai"})
    sets.engaged.DW.DT = set_combine(sets.engaged.DT, {ear1 = "Suppanomimi", waist = "Reiki Yotai"})
    sets.engaged.DW.Acc.DT = sets.engaged.DW.DT

    -- Gear worn while standing at a Porter Moogle (PorterPacker), so nothing being stowed is equipped.
    sets.packing = {
        main  = "Mpaca's Staff",
        sub   = "Umbra Strap",
        ammo  = "Staunch Tathlum +1",
        head  = "Nyame Helm",
        neck  = "Loricate Torque +1",
        ear1  = "Etiolation Earring",
        ear2  = "Sanare Earring",
        body  = "Nyame Mail",
        hands = "Nyame Gauntlets",
        ring1 = "Stikini Ring",
        ring2 = "Defending Ring",
        back  = "Null Shawl",
        waist = "Fucho-no-Obi",
        legs  = "Nyame Flanchard",
        feet  = "Nyame Sollerets"
    }
end

-------------------------------------------------------------------------------------------------------------------
-- PorterPacker: swap to sets.packing while next to a Porter Moogle.
-- Now WRAPS BRD.lua's job_customize_idle_set (Sublimation / latent_refresh overlays) instead of replacing it.
-------------------------------------------------------------------------------------------------------------------
local brd_base_customize_idle_set = job_customize_idle_set
function job_customize_idle_set(idleSet)
    if brd_base_customize_idle_set then
        idleSet = brd_base_customize_idle_set(idleSet)
    end

    local currently_near_porter = near_porter_moogle()

    if currently_near_porter then
        if not near_porter then
            windower.add_to_chat(160, "Near Porter Moogle - Using packing gear")
            near_porter = true
        end
        -- Sel-Include overlays sets.Kiting AFTER this function returns, which would put
        -- Fili Cothurnes back on top of sets.packing while moving. Blank it.
        sets.Kiting = {}
        return sets.packing
    else
        if near_porter then
            windower.add_to_chat(160, "Left Porter Moogle area - Returning to normal gear")
            near_porter = false
            sets.Kiting = sets.KitingNormal
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
    set_macro_page(1, 10)
end

autows_list = {
    ["Songs"] = "Mordant Rime",
    ["SongsShield"] = "Mordant Rime",
    ["MpuGandring"] = "Ruthless Stroke",
    ["Naegling"] = "Savage Blade",
    ["DualNaegling"] = "Savage Blade",
    ["Aeneas"] = "Rudra's Storm",
    ["DualWeapons"] = "Rudra's Storm",
    ["Twashtar"] = "Rudra's Storm",
    ["Club"] = "Flash Nova",
    ["Aeolian"] = "Aeolian Edge"
}