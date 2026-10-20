-------------------------------------------------------------------------------------------------------------------
-- LINKTRI (2026-10-20): shared skillchain / magic burst window detection.
-- Used by BLM, GEO and SCH. To add it to another job (RDM, etc.):
--   1. Optionally set SC_WINDOW_DURATION (seconds) before the include; default 10.
--   2. include('Linktri-MBWindow.lua') at the top of the job's gear file (GearSwap finds it in data/Linktri/).
--   3. In that job's post-midcast, check  is_sc_window_open(spell.target and spell.target.id)
--      before equipping the burst set.
--   4. Manual commands: mb_window_manual(true/false) opens/closes a window that applies to any target.
--
-- A window opens only when ALL of these are true:
--   * the action carries a real skillchain message (add_effect_message IDs below - NOT add_effect_animation,
--     which also fires for enspells, additional effects, etc.)
--   * the action is a weapon skill (3), spell (4, e.g. Immanence), NPC/trust TP move (11) or pet ability (13)
--   * whoever performed it is you, a party or alliance member (trusts included), or one of their pets
-- Each window is remembered per monster, so a burst only uses the burst set on the monster that was
-- skillchained (multi-mob pulls, other groups' skillchains nearby don't count).
-------------------------------------------------------------------------------------------------------------------

SC_WINDOW_DURATION = SC_WINDOW_DURATION or 10

-- Manual / any-target window (gs c mb on). Kept under the old names so existing job code still works.
SCWindowOpen = false
SCWindowTimer = 0

-- Per-monster windows: MB_WINDOWS[mob id] = os.clock() when the skillchain landed
MB_WINDOWS = {}

-- Skillchain add_effect_message IDs (Windower message IDs / Ivaar's Skillchains addon):
--   196 generic "Skillchain", 288-302 named skillchains, 385-397 higher tier (Radiance, Umbra...), 767-770 additional types
MB_SC_MESSAGES = {[196] = true}
for id = 288, 302 do MB_SC_MESSAGES[id] = true end
for id = 385, 397 do MB_SC_MESSAGES[id] = true end
for id = 767, 770 do MB_SC_MESSAGES[id] = true end

local MB_SC_CATEGORIES = {[3] = true, [4] = true, [11] = true, [13] = true}
local MB_PARTY_KEYS = {'p0','p1','p2','p3','p4','p5','a10','a11','a12','a13','a14','a15','a20','a21','a22','a23','a24','a25'}

-- Mob IDs of you, your party/alliance (including trusts) and their pets
local function mb_party_ids()
    local ids = {}
    local party = windower.ffxi.get_party()
    if not party then return ids end
    for _, key in ipairs(MB_PARTY_KEYS) do
        local member = party[key]
        if member then
            local mob = member.mob
            if mob and mob.id then
                ids[mob.id] = true
                if mob.pet_index and mob.pet_index > 0 then
                    local pet = windower.ffxi.get_mob_by_index(mob.pet_index)
                    if pet and pet.id then ids[pet.id] = true end
                end
            elseif member.id then
                ids[member.id] = true
            end
        end
    end
    return ids
end

function check_skillchain(act)
    if not act or not MB_SC_CATEGORIES[act.category] or not act.targets then return end
    local party_ids
    for _, target in ipairs(act.targets) do
        for _, action in ipairs(target.actions or {}) do
            local msg = action.add_effect_message
            if msg and MB_SC_MESSAGES[msg] then
                party_ids = party_ids or mb_party_ids()
                if party_ids[act.actor_id] then
                    MB_WINDOWS[target.id] = os.clock()
                    local mob = windower.ffxi.get_mob_by_id(target.id)
                    windower.add_to_chat(121, '[GearSwap] SKILLCHAIN on '..((mob and mob.name) or 'target')..
                        ' - MAGIC BURST WINDOW OPEN ('..SC_WINDOW_DURATION..'s)')
                end
            end
        end
    end
end

-- target_id: the monster you're casting on (spell.target.id). Without it, true if ANY window is open.
function is_sc_window_open(target_id)
    local now = os.clock()
    if SCWindowOpen then
        if (now - SCWindowTimer) < SC_WINDOW_DURATION then
            return true
        end
        SCWindowOpen = false
    end
    local open = false
    for id, t in pairs(MB_WINDOWS) do
        if (now - t) >= SC_WINDOW_DURATION then
            MB_WINDOWS[id] = nil
        elseif target_id == nil or id == target_id then
            open = true
        end
    end
    return open
end

-- Close the window on one monster (e.g. after a confirmed burst), or all of them when no id is given.
function mb_window_close(target_id)
    if target_id then
        MB_WINDOWS[target_id] = nil
    else
        MB_WINDOWS = {}
        SCWindowOpen = false
    end
end

-- Manual control (gs c mb on/off/toggle). An "on" window applies to any target for SC_WINDOW_DURATION.
function mb_window_manual(open)
    if open == nil then open = not is_sc_window_open() end
    if open then
        SCWindowOpen = true
        SCWindowTimer = os.clock()
    else
        mb_window_close()
    end
    return open
end

windower.raw_register_event('action', function(act)
    check_skillchain(act)
end)
