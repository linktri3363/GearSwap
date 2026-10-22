-------------------------------------------------------------------------------------------------------------------
-- Linktri-DivineVeil.lua  (LINKTRI 2026-10-22)
-- Shared party-ailment detection for Divine Seal / Divine Caress on status removal (Erase and the -na spells).
-- Included by Linktri_Geo_Gear.lua (/WHM Divine Seal) and Linktri_Whm_Gear.lua (Divine Seal + Divine Caress).
-- This file only tracks party buffs and counts who needs a removal; each job file keeps its own
-- user_job_precast and states (AutoDivineSeal / AutoDivineCaress), since the rules differ per job.
--
-- API:
--   dv_party_count(spell) -> number of party members (you included) within DV_RADIUS of the target who have an
--                            ailment this spell removes; nil when the target isn't in your party or the spell
--                            isn't a known status removal.
--   DV_RADIUS             -> AoE radius in yalms used for the count ("small radius" per BG-Wiki; adjust here).
--   DV_REMOVAL_DEBUFFS    -> spell name -> set of buff IDs it removes.
-- Party members' buffs come from the Party Buffs packet (0x076): your own party, in your zone. Alliance members
-- in other parties aren't visible. Your own buffs come from player.buffs.
-------------------------------------------------------------------------------------------------------------------

DV_RADIUS = 10   -- yalms around the target; "small radius" per BG-Wiki, adjust if needed

-- Buff IDs each spell removes (Windower resources; the 5xx IDs are the newer variants of the same ailments).
DV_REMOVAL_DEBUFFS = {
    ['Poisona']  = S{3, 540},
    ['Paralyna'] = S{4, 566},
    ['Blindna']  = S{5},
    ['Silena']   = S{6},
    ['Stona']    = S{7},
    ['Viruna']   = S{8, 31},
    ['Cursna']   = S{9, 20, 15, 30},     -- curse, curse, doom, bane
    ['Erase']    = S{11, 12, 13, 21, 23, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141,
                     142, 144, 145, 146, 147, 148, 149, 156, 167, 168, 174, 175, 186, 189, 192, 194, 217, 223,
                     404, 557, 558, 559, 560, 561, 562, 563, 564, 565, 567},
}

-- [player id] = S{buff ids}, refreshed from 0x076. Byte layout per entry (48 bytes, 5 entries): ID at +0,
-- 2-bit high parts of each buff ID at +8 (8 bytes), low bytes at +16 (32 bytes); 255 = empty slot.
-- (Same decoding as the PartyBuffs addon / GearSwap.)
dv_party_member_buffs = {}

windower.raw_register_event('incoming chunk', function(id, data)
    if id ~= 0x076 then return end
    for k = 0, 4 do
        local base = k * 48 + 5
        local uid = data:unpack('I', base)
        if uid and uid ~= 0 then
            local buffs = S{}
            for i = 1, 32 do
                local low = data:byte(base + 16 + i - 1)
                local high = math.floor(data:byte(base + 8 + math.floor((i - 1) / 4)) / 4 ^ ((i - 1) % 4)) % 4
                local buff = low + 256 * high
                if buff ~= 255 then buffs[buff] = true end
            end
            dv_party_member_buffs[uid] = buffs
        end
    end
end)

windower.raw_register_event('zone change', function()
    dv_party_member_buffs = {}
end)

function dv_has_any(buff_list, wanted)
    for b in pairs(buff_list) do
        if wanted:contains(b) then return true end
    end
    return false
end

-- Number of party members (you included) near the target who have an ailment this spell removes,
-- or nil when the target isn't in your party (no buff data for it).
function dv_party_count(spell)
    local wanted = DV_REMOVAL_DEBUFFS[spell.english]
    if not wanted then return nil end
    local target = spell.target and spell.target.id and windower.ffxi.get_mob_by_id(spell.target.id)
    if not target then return nil end

    local party = windower.ffxi.get_party()
    local in_party = false
    for _, key in ipairs({'p0', 'p1', 'p2', 'p3', 'p4', 'p5'}) do
        local m = party[key]
        if m and m.mob and m.mob.id == target.id then in_party = true end
    end
    if not in_party then return nil end

    local count = 0
    for _, key in ipairs({'p0', 'p1', 'p2', 'p3', 'p4', 'p5'}) do
        local m = party[key]
        local mob = m and m.mob
        if mob then
            local buffs
            if key == 'p0' then
                buffs = S(player.buffs or {})
            else
                buffs = dv_party_member_buffs[mob.id]
            end
            local dx, dy = (mob.x or 0) - (target.x or 0), (mob.y or 0) - (target.y or 0)
            local near = math.sqrt(dx * dx + dy * dy) <= DV_RADIUS
            if buffs and near and dv_has_any(buffs, wanted) then
                count = count + 1
            end
        end
    end
    return count
end
