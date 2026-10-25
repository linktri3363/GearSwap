--Place for settings and custom functions to work across one characters, all jobs.
latency = .75

--If this is set to true it will prevent you from casting shadows when you have more up than that spell would generate.
conserveshadows = false

--Display related settings.
state.DisplayMode = M(true, 'Display Mode') --Set this to false if you don't want to display modes at the bottom of your screen.
--Uncomment the settings below and change the values to edit the display's look.
--displayx = 3
--displayy = 1062
--displayfont = 'Arial'
--displaysize = 12
--displaybold = true
--displaybg = 0
--displaystroke = 2
--displaytransparancy = 192
--state.DisplayColors = {
    -- h='\\cs(255, 0, 0)', -- Red for active booleans and non-default modals
    -- w='\\cs(255,255,255)', -- White for labels and default modals
    -- n='\\cs(192,192,192)', -- White for labels and default modals
    -- s='\\cs(96,96,96)' -- Gray for inactive booleans
--}

--Options for automation.
state.ReEquip 		  		= M(true, 'ReEquip Mode')		 --Set this to false if you don't want to equip your current Weapon set when you aren't wearing any weapons.
state.AutoArts 		  		= M(true, 'AutoArts') 		 --Set this to false if you don't want to automatically try to keep up Solace/Arts.
state.AutoLockstyle	 	    = M(true, 'AutoLockstyle Mode') --Set this to false if you don't want gearswap to automatically lockstyle on load and weapon change.
state.CancelStoneskin 		= M(true, 'Cancel Stone Skin') --Set this to false if you don't want to automatically cancel stoneskin when you're slept.
state.SkipProcWeapons 		= M(true, 'Skip Proc Weapons') --Set this to false if you want to display weapon sets fulltime rather than just Aby/Voidwatch.
state.NotifyBuffs	  		= M(false, 'Notify Buffs') 	 --Set this to true if you want to notify your party when you recieve a specific buff/debuff. (List Below)
state.Uninterruptible   = M{['description'] = 'Uninterruptible','Full','Off','Delay'} --LINKTRI: Full = cast while moving (replaces the per-job no_interruptions scripts). Delay holds spells until you stop; Off disables both.

--[[Binds you may want to change.
	Bind special characters.
	@ = Windows Key
	% = Works only when text bar not up.
	$ = Works only when text bar is up.
	^ = Control Key
	! = Alt Key
	~ = Shift Key
	# = Apps Key
]]

send_command('bind !@^f7 gs c toggle AutoWSMode') --Turns auto-ws mode on and off.
send_command('bind !^f7 gs c toggle AutoFoodMode') --Turns auto-ws mode on and off.
send_command('bind f7 gs c cycle Weapons') --Cycle through weapons sets.
send_command('bind @f8 gs c toggle AutoNukeMode') --Turns auto-nuke mode on and off.
send_command('bind ^f8 gs c toggle AutoStunMode') --Turns auto-stun mode off and on.
send_command('bind !f8 gs c toggle AutoDefenseMode') --Turns auto-defense mode off and on.
send_command('bind ^@!f8 gs c toggle AutoTrustMode') --Summons trusts automatically.
send_command('bind @pause gs c cycle AutoBuffMode') --Automatically keeps certain buffs up, job-dependant.
send_command('bind @scrolllock gs c cycle Passive') --Changes offense settings such as accuracy.
send_command('bind f9 gs c cycle OffenseMode') --Changes offense settings such as accuracy.
send_command('bind ^f9 gs c cycle HybridMode') --Changes defense settings for melee such as PDT.
send_command('bind @f9 gs c cycle RangedMode') --Changes ranged offense settings such as accuracy.
send_command('bind !f9 gs c cycle WeaponskillMode') --Changes weaponskill offense settings such as accuracy.
send_command('bind f10 gs c set DefenseMode Physical') --Turns your physical defense set on.
send_command('bind ^f10 gs c cycle PhysicalDefenseMode') --Changes your physical defense set.
send_command('bind !f10 gs c toggle Kiting') --Keeps your kiting gear on..
send_command('bind f11 gs c set DefenseMode Magical') --Turns your magical defense set on.
send_command('bind ^f11 gs c cycle MagicalDefenseMode') --Changes your magical defense set.
send_command('bind @f11 gs c cycle CastingMode') --Changes your castingmode options such as magic accuracy.
send_command('bind !f11 gs c cycle ExtraMeleeMode') --Adds another set layered on top of your engaged set.
send_command('bind ^f12 gs c cycle ResistDefenseMode') --Changes your resist defense set.
send_command('bind f12 gs c set DefenseMode Resist') --Turns your resist defense set on.
send_command('bind @f12 gs c cycle IdleMode') --Changes your idle mode options such as refresh.
send_command('bind !f12 gs c reset DefenseMode') --Turns your defensive mode off.
send_command('bind ^@!f12 gs reload') --Reloads gearswap.
send_command('bind pause gs c update user') --Runs a quick check to make sure you have the right gear on and checks variables.
send_command('bind ^@!pause gs org') --Runs organizer.
send_command('bind ^@!backspace gs c buffup') --Buffup macro because buffs are love.
send_command('bind ^r gs c weapons Default') --Requips weapons and gear.
send_command('bind ^z gs c toggle Capacity') --Keeps capacity mantle on and uses capacity rings.
send_command('bind ^y gs c toggle AutoCleanupMode') --Uses certain items and tries to clean up inventory.
send_command('bind ^t gs c cycle treasuremode') --Toggles hitting htings with your treasure hunter set.
send_command('bind !t input /target <bt>') --Targets the battle target.
send_command('bind ^o fillmode') --Lets you see through walls.
send_command('bind @m gs c mount Omega')

NotifyBuffs = S{'doom','petrification'}

bayld_items = {'Tlalpoloani','Macoquetza','Camatlatia','Icoyoca','Tlamini','Suijingiri Kanemitsu',
'Zoquittihuitz','Quauhpilli Helm','Chocaliztli Mask','Xux Hat','Quauhpilli Gloves','Xux Trousers',
'Chocaliztli Boots','Maochinoli','Xiutleato','Hatxiik','Kuakuakait','Azukinagamitsu','Atetepeyorg',
'Kaquljaan','Ajjub Bow','Baqil Staff','Ixtab','Tamaxchi','Otomi Helm','Otomi Gloves','Kaabnax Hat',
'Kaabnax Trousers','Ejekamal Mask','Ejekamal Boots','Quiahuiz Helm','Quiahuiz Trousers','Uk\'uxkaj Cap'}

--[[ List of all Bayld Items.
bayld_items = {'Tlalpoloani','Macoquetza','Camatlatia','Icoyoca','Tlamini','Suijingiri Kanemitsu','Zoquittihuitz',
'Quauhpilli Helm','Chocaliztli Mask','Xux Hat','Quauhpilli Gloves','Xux Trousers','Chocaliztli Boots','Maochinoli',
'Hatxiik','Kuakuakait','Azukinagamitsu','Atetepeyorg','Kaquljaan','Ajjub Bow','Baqil Staff','Ixtab','Otomi Helm',
'Otomi Gloves','Kaabnax Hat','Kaabnax Trousers','Ejekamal Mask','Ejekamal Boots','Quiahuiz Helm','Quiahuiz Trousers',
'Uk\'uxkaj Cap'}
]]

-- LINKTRI MODIFICATION (2026-10-11): route automatic lockstyle through DressUp.
-- Overrides check_lockstyle() from libs/Sel-Utility.lua (this file loads after it), so
-- Selindrile's libs stay untouched for upstream merges. DressUp's self blink prevention
-- otherwise swallows every new lockstyle and keeps the previous job's look.
--   * Jobs with user_job_lockstyle() (per-weapon sets) keep their own set numbers;
--     'du lockstyle open' first lets the new look through DressUp's blink prevention.
--   * Jobs without one get 'du lockstyle', i.e. the set numbered by job ID
--     (WAR=001 ... RUN=022), instead of Selindrile's '/lockstyle on' (current gear).
-- Requires the modified DressUp (github.com/linktri3363/DressUp).
function check_lockstyle()
	if state.AutoLockstyle.value and style_lock and os.clock() > style_delay then
		if user_job_lockstyle or user_lockstyle then
			windower.send_command('du lockstyle open')
			if user_job_lockstyle then
				user_job_lockstyle()
			else
				user_lockstyle()
			end
		else
			windower.send_command('du lockstyle')
		end
		style_lock = false
		style_delay = os.clock() + 15
	end
end

-------------------------------------------------------------------------------------------------------------------
-- LINKTRI MODIFICATION: GearSwap inventory self-heal (all jobs)
-- GearSwap reads your bags once at load, then keeps its own copy updated from item packets. In very crowded
-- zones (e.g. Domain Invasion) packets can be dropped, its copy goes stale, and whole sets fail as "not found"
-- even though the gear is in your bags. Every 5s this compares GearSwap's copy of inventory + wardrobes with the
-- game client's memory (item ID per bag slot only) and, if the SAME difference is seen on two checks in a row,
-- copies the client's entry into just those slots, then re-equips.
-- Safeguards: read-only towards the server (never moves items); skips while an action is in progress; never
-- touches equipment slots or the equipped flag of matching slots; ignores a bag the client reports as fully
-- empty (client still loading after a zone); any error is caught so it can never break GearSwap.
-- Toggle: //gs c toggle InventoryResync   |   REVERT: delete this block.
-------------------------------------------------------------------------------------------------------------------
state.InventoryResync = M(true, 'Inventory Resync')

local INV_RESYNC_BAGS = {'inventory','wardrobe','wardrobe2','wardrobe3','wardrobe4','wardrobe5','wardrobe6','wardrobe7','wardrobe8'}
local INV_RESYNC_INTERVAL = 5
local inv_resync_next = 0
local inv_resync_pending = {}   -- "bag:slot:clientId" -> true, seen on the previous check
local inv_resync_last_msg = -60

local function inv_slot_id(entry)
	if type(entry) == 'table' and entry.id then return entry.id end
	return 0
end

local function inv_resync_check()
	if not (state.InventoryResync and state.InventoryResync.value) then return end
	if midaction() then return end
	local gs_items = gearswap and gearswap.items
	if type(gs_items) ~= 'table' then return end
	local client = windower.ffxi.get_items()
	if type(client) ~= 'table' then return end

	local seen, fixed = {}, 0
	for _, bag in ipairs(INV_RESYNC_BAGS) do
		local cb, gb = client[bag], gs_items[bag]
		if type(cb) == 'table' and cb.enabled ~= false and type(gb) == 'table' then
			local max = tonumber(cb.max) or 80
			local client_count = 0
			for slot = 1, max do
				if inv_slot_id(cb[slot]) ~= 0 then client_count = client_count + 1 end
			end
			-- A bag the client reports as completely empty is most likely still loading: don't trust it.
			if client_count > 0 then
				for slot = 1, max do
					local cid = inv_slot_id(cb[slot])
					if cid ~= inv_slot_id(gb[slot]) then
						local key = bag..':'..slot..':'..cid
						if inv_resync_pending[key] then
							gb[slot] = cb[slot]
							fixed = fixed + 1
						else
							seen[key] = true
						end
					end
				end
			end
		end
	end
	inv_resync_pending = seen

	if fixed > 0 then
		if os.clock() - inv_resync_last_msg >= 60 then
			add_to_chat(122, '[GearSwap] Inventory resynced from the game client: '..fixed..' bag slot(s) corrected.')
			inv_resync_last_msg = os.clock()
		end
		send_command('gs c update')
	end
end

windower.register_event('prerender', function()
	local now = os.clock()
	if now < inv_resync_next then return end
	inv_resync_next = now + INV_RESYNC_INTERVAL
	local ok, err = pcall(inv_resync_check)
	if not ok then
		inv_resync_pending = {}
		if os.clock() - inv_resync_last_msg >= 60 then
			add_to_chat(123, '[GearSwap] Inventory resync check skipped: '..tostring(err))
			inv_resync_last_msg = os.clock()
		end
	end
end)

-------------------------------------------------------------------------------------------------------------------
-- LINKTRI MODIFICATION (2026-10-24): full inventory rebuild whenever the job file loads.
-- //gs reload only reloads the job files; GearSwap's own copy of your bags is read once when the GearSwap addon
-- loads and then patched from item packets. If one of those is missed - e.g. after an NPC augment upgrade, when
-- the item keeps its ID so the 5s check above can't see the change - a piece can be silently skipped until you
-- move it by hand. This re-reads every bag from the game client on each job-file load (//gs reload, job change,
-- login) and on demand with //gs c resyncinventory, then says how many slots were out of date (silent if none).
-- Same safeguards as above: read-only towards the server, skipped mid-action or while bags are still loading,
-- errors caught. REVERT: delete this block.
-------------------------------------------------------------------------------------------------------------------
local INV_REBUILD_BAGS = {'inventory','wardrobe','wardrobe2','wardrobe3','wardrobe4','wardrobe5','wardrobe6','wardrobe7','wardrobe8'}

local function inv_entry_key(entry)
	-- Empty slots all compare equal: GearSwap zeroes the ID of an emptied slot but leaves its old extdata behind.
	if type(entry) ~= 'table' or not entry.id or entry.id == 0 then return '0' end
	return tostring(entry.id or 0)..'|'..tostring(entry.status or 0)..'|'..tostring(entry.extdata or '')
end

-- Returns number of out-of-date slots fixed, or nil plus a reason when it skipped.
local function inv_full_rebuild()
	local gs = gearswap
	if type(gs) ~= 'table' or type(gs.items) ~= 'table' or type(gs.default_slot_map) ~= 'table' then
		return nil, 'GearSwap item list unavailable'
	end
	if midaction() then return nil, 'mid-action' end
	local fresh = windower.ffxi.get_items()
	if type(fresh) ~= 'table' or type(fresh.equipment) ~= 'table' or type(fresh.inventory) ~= 'table' then
		return nil, 'game client inventory not ready'
	end
	-- An inventory the client reports as completely empty is most likely still loading: don't trust it.
	local loaded = false
	for slot = 1, (tonumber(fresh.inventory.max) or 80) do
		if inv_slot_id(fresh.inventory[slot]) ~= 0 then loaded = true break end
	end
	if not loaded then return nil, 'inventory still loading' end

	local changed = 0
	for _, bag in ipairs(INV_REBUILD_BAGS) do
		local cb, gb = fresh[bag], gs.items[bag]
		if type(cb) == 'table' and type(gb) == 'table' then
			for slot = 1, (tonumber(cb.max) or 80) do
				if inv_entry_key(cb[slot]) ~= inv_entry_key(gb[slot]) then changed = changed + 1 end
			end
		end
	end

	-- Equipment into GearSwap's internal {slot, bag_id} form, exactly as statics.lua builds it at load.
	local eq = {}
	for _, name in pairs(gs.default_slot_map) do
		local slot = fresh.equipment[name]
		eq[name] = {slot = (slot == nil or slot == 0) and gs.empty or slot, bag_id = fresh.equipment[name..'_bag'] or 0}
	end
	fresh.equipment = eq

	gs.items = fresh
	gs.refresh_globals()
	inv_resync_pending = {}
	return changed
end

local function inv_full_rebuild_report(manual)
	local ok, fixed, reason = pcall(inv_full_rebuild)
	if not ok then
		add_to_chat(123, '[GearSwap] Inventory rebuild skipped: '..tostring(fixed))
	elseif fixed == nil then
		if manual then add_to_chat(123, '[GearSwap] Inventory rebuild skipped: '..tostring(reason)..'. Try again in a moment.') end
	elseif fixed > 0 then
		add_to_chat(122, '[GearSwap] Inventory rebuilt from the game client: '..fixed..' bag slot(s) were out of date.')
		send_command('gs c update')
	elseif manual then
		add_to_chat(122, '[GearSwap] Inventory rebuilt from the game client: already up to date.')
	end
end

-- On every job-file load. Delayed 1s so it runs after Sel finishes loading the job (and clears any zone-in lag).
coroutine.schedule(function() inv_full_rebuild_report(false) end, 1)

-- //gs c resyncinventory (or //gs c resync): rebuild now, no reload needed.
function user_self_command(commandArgs, eventArgs)
	local cmd = commandArgs[1] and commandArgs[1]:lower()
	if cmd == 'resyncinventory' or cmd == 'resync' then
		inv_full_rebuild_report(true)
		eventArgs.handled = true
	end
end
