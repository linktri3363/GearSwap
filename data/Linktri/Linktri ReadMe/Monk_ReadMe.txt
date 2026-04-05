# Linktri Monk Gear File
## GearSwap LUA for FFXI Monk

---

## 📋 Table of Contents
- [Overview](#overview)
- [Installation](#installation)
- [Features](#features)
- [Mode System](#mode-system)
- [In-Game Commands](#in-game-commands)
- [Gear Sets Included](#gear-sets-included)
- [Weaponskill Guide](#weaponskill-guide)
- [Keybinds](#keybinds)
- [Current Gear Setup](#current-gear-setup)
- [Upgrade Path](#upgrade-path)
- [Troubleshooting](#troubleshooting)
- [Credits](#credits)

---

## 🎯 Overview

This is a comprehensive GearSwap file for FFXI Monk, optimized for Linktri's current gear inventory. All gear sets have been verified as MNK-equippable and available in inventory.

**Key Features:**
- 5 Offense modes with accuracy progression
- 3 Hybrid modes for defensive situations
- Complete weaponskill sets for all major H2H and staff WS
- Automatic buff handling (Impetus, Footwork, Hundred Fists)
- Counter and Subtle Blow specialized sets
- Full defensive mode support

**Last Updated:** October 2025  
**Updates Made:** 48 blank gear slots filled and optimized

---

## 💾 Installation

### Prerequisites
- Windower 4 with GearSwap addon installed
- FFXI character: Linktri

### Installation Steps

1. **Locate your GearSwap data folder:**
   ```
   FFXI/addons/GearSwap/data/
   ```

2. **Create a character folder if it doesn't exist:**
   ```
   FFXI/addons/GearSwap/data/Linktri/
   ```

3. **Place the file:**
   - Copy `Linktri_Mnk_Gear.lua` into the `Linktri` folder
   - Rename to: `Linktri_MNK.lua` (GearSwap naming convention)

4. **Load in-game:**
   ```
   //gs reload
   ```

5. **Verify it loaded:**
   ```
   //gs showswaps
   ```

---

## ✨ Features

### Automatic Gear Swapping
- **Job Abilities**: Enhances all MNK JAs with appropriate gear
- **Weaponskills**: Optimized sets for each WS
- **Buffs**: Auto-swaps for Impetus, Footwork, Boost
- **Defense**: Instant PDT/MDT/MEVA sets on command
- **Fast Cast**: Utsusemi and emergency magic casting

### Intelligent Mode System
- **5 Offense Modes**: Normal → Acc → FullAcc → SubtleBlow → Counter
- **3 Hybrid Modes**: Normal → PDT → Gleti
- **3 Defense Modes**: PDT → MDT → MEVA
- **Weapon Sets**: Multiple weapon configurations including proc weapons

### Special Features
- **No Interruptions**: Position locking to prevent animation interruption
- **Impetus Detection**: Automatically uses Bhikku Cyclas +2 when Impetus is active
- **Footwork Support**: Auto-swaps to Anch. Gaiters +2 for kick attacks
- **Kicking**: Includes Herald's Gaiters for movement speed

---

## 🎮 Mode System

### Offense Modes
Cycle with: `//gs c cycle OffenseMode`

| Mode | Purpose | Key Gear |
|------|---------|----------|
| **Normal** | Standard DPS | Gere + Epona rings, maximize multi-attack |
| **Acc** | Higher accuracy | Chirich Ring +1 x2, maintain DPS |
| **FullAcc** | Maximum accuracy | Full Malignance, Chirich rings, acc earrings |
| **SubtleBlow** | TP denial | ~60 Subtle Blow total, enemy gains minimal TP |
| **Counter** | Tanking/countering | Maximizes counter rate, good for solo |

### Hybrid Modes
Cycle with: `//gs c cycle HybridMode`

| Mode | Purpose | DT% |
|------|---------|-----|
| **Normal** | No defensive gear | 0% |
| **PDT** | Physical damage reduction | ~25-30% |
| **Gleti** | Store TP hybrid | ~15% + STP+28 |

### Defense Modes
Toggle individual modes:
- `//gs c toggle PhysicalDefenseMode` - PDT set (~40-50% DT)
- `//gs c toggle MagicalDefenseMode` - MDT set (~40-50% DT)
- `//gs c toggle ResistDefenseMode` - MEVA set (magic evasion focus)

### Weapon Sets
Cycle with: `//gs c cycle Weapons`

- **Godhands** (default)
- **Staff** (Malignance Pole + Bloodrain Strap)
- **Barehanded**
- **ProcStaff** (Terra's Staff)
- **ProcClub** (Mafic Cudgel)
- **ProcSword** (Ark Sword)
- **ProcGreatSword** (Lament)
- **ProcScythe** (Ark Scythe)
- **ProcPolearm** (Pitchfork +1)
- **ProcGreatKatana** (Hardwood Katana)

---

## ⌨️ In-Game Commands

### Mode Cycling
```
//gs c cycle OffenseMode       - Cycle through offense modes
//gs c cycle HybridMode        - Cycle through hybrid modes
//gs c cycle WeaponskillMode   - Match, Normal, Acc, FullAcc
//gs c cycle Weapons           - Change weapon sets
```

### Defense Toggles
```
//gs c toggle PhysicalDefenseMode
//gs c toggle MagicalDefenseMode
//gs c toggle ResistDefenseMode
```

### Utility Commands
```
//gs reload                    - Reload the lua file
//gs showswaps                 - Display gear swaps in log
//gs validate                  - Check for gear issues
//gs c interrupts              - Toggle no_interruptions mode
```

---

## 🎹 Keybinds

The following keybinds are automatically configured:

| Key Combination | Action |
|----------------|--------|
| `Ctrl + \`` | Boost (for pre-fight TP) |
| `Alt + \`` | Perfect Counter |
| `Ctrl + Backspace` | Mantra |
| `Alt + \`` | Cycle Skillchain Mode |

**Note:** Boost should be macro'd with Ask Sash equipped for TP generation

---

## 🎒 Gear Sets Included

### Job Ability Sets
- **Hundred Fists** - Hes. Hose +1 (duration +15s)
- **Boost** - Anch. Gloves +2
- **Dodge** - Anch. Gaiters +2 (Evasion +19)
- **Focus** - Anch. Crown +2 (Accuracy +21)
- **Chakra** - HP-focused recovery set
- **Counterstance** - Hes. Gaiters +1 (Counter rate +21%)
- **Footwork** - Anch. Gaiters +2 (kick damage boost)
- **Mantra** - Hes. Gaiters +1 (HP boost +2% per merit)
- **Formless Strikes** - Hes. Cyclas +1 (duration +6s per merit)
- **Perfect Counter** - Bhikku Crown +2 (counter damage +20)

### Engaged/TP Sets
All engaged sets include variations for:
- Normal
- Acc (Accuracy)
- FullAcc (Maximum Accuracy)
- SubtleBlow (~60 Subtle Blow)
- Counter (Maximized counter rate)

Each with PDT and Gleti hybrid variants.

### Fast Cast Set
Configured for emergency casting:
- Utsusemi: Ichi/Ni
- General magic
- ~40% Fast Cast total

### Idle Sets
- **Standard Idle** - Refresh, regen, defensive stats
- **Weak** - Same as standard
- **Kiting** - Herald's Gaiters (movement speed)

### Defense Sets
- **PDT** - ~40-50% Physical Damage Taken reduction
- **MDT** - ~40-50% Magic Damage Taken reduction  
- **MEVA** - Magic Evasion focus

---

## ⚔️ Weaponskill Guide

### Optimal Weaponskill Rotation

**Single Target (High DPS):**
1. **Victory Smite** - Best damage, critical hit focused
   - Best at 2000+ TP for crit rate bonus
   - Use with Impetus for massive damage

2. **Shijin Spiral** - Strong damage + TP Inhibit
   - Synergizes with Penance merit
   - Useful for TP denial strategies

3. **Raging Fists** - Multi-hit consistency
   - 5-hit weaponskill
   - Good at all TP levels

**AoE Situations:**
- **Spinning Attack** - Multiple enemies

**Kick Attacks (with Footwork):**
- **Tornado Kick** - Main kick WS
- **Dragon Kick** - Alternative kick WS

**Staff Weaponskills:**
- **Shell Crusher** - Defense down debuff (magic accuracy set)
- **Cataclysm** - Dark magic damage

**Relic Weaponskill:**
- **Final Heaven** - WSD focused, single hit

### Weaponskill Set Details

Each weaponskill has an optimized set considering:
- Multi-hit WS favor multi-attack over WSD
- Single-hit WS use WSD gear (Nyame)
- Accuracy variants available (WSAcc, WSFullAcc)
- Impetus detection for Victory Smite

---

## 💍 Current Gear Setup

### Key Gear Being Used

**Waist Slots:**
- ✅ **Reiki Yotai** - TP sets (Store TP+5, Dual Wield+7)
- ✅ **Eschan Stone** - WS sets (Attack+7, Accuracy+7)
- ✅ **Carrier's Sash** - Defensive sets (HP+50)

**Neck Slot:**
- ✅ **Rep. Plat. Medal** - All sets (Attack+10, STR+3, VIT+3)

**Rings:**
- ✅ **Gere Ring** - Offense (STR+6, Attack+15, DA+5%)
- ✅ **Epona's Ring** - Offense (Attack+5, DA+3%, STP+3)
- ✅ **Chirich Ring +1** x2 - Accuracy (Acc+10, STP+6, SB+10 each)
- ✅ **Defending Ring** - Defense (DT-10%)
- ✅ **Murky Ring (Path A)** - Defense (DT-10%)

**Earrings:**
- ✅ **Schere Earring** - Critical hits
- ✅ **Sherida Earring** - TA+5%, Acc+8
- ✅ **Moonshade Earring** - WS (TP Bonus+250)
- ✅ **Digni. Earring** - Accuracy
- ✅ **Telos Earring** - Accuracy+10, TA+1%
- ✅ **Brutal Earring** - DA+5%

**Armor Sets:**
- ✅ **Mpaca's Set** (Path A) - TP and WS
- ✅ **Bhikku +2 Set** - Empyrean for Impetus and TP
- ✅ **Malignance Set** - Accuracy and defense
- ✅ **Nyame Set** (Path B) - Defense and single-hit WS
- ✅ **Hizamaru +2 Set** - Subtle Blow build
- ✅ **Anchorite's +2 Set** - Job-specific enhancements
- ✅ **Hesychast's +1 Set** - Job-specific enhancements
- ✅ **Gleti's Set** (Path A) - Hybrid Store TP

---

## 📈 Upgrade Path

### High Priority (Major Impact)

#### 1. **Moonbow Belt +1**
- **Replaces:** Reiki Yotai / Eschan Stone
- **Impact:** Best-in-slot waist for both TP and WS
- **Stats:** Attack+20, Accuracy+15, DA+6%, Haste+5%
- **Source:** Omen (Ou card trade)

#### 2. **Monk's Nodowa +2**
- **Replaces:** Rep. Plat. Medal
- **Impact:** Best-in-slot JSE neck
- **Stats:** STR+20, Attack+20, Critical Hit Rate+5%
- **Source:** JSE neck upgrade (Domain Invasion points)

### Medium Priority (Incremental Improvements)

#### 3. **Combatant's Torque**
- **Replaces:** Rep. Plat. Medal (accuracy sets)
- **Impact:** Superior accuracy neck option
- **Stats:** Accuracy+15, Double Attack+4%
- **Source:** Ambuscade (Hallmarks trade)

#### 4. **Bhikku Crown +3**
- **Current:** Bhikku Crown +2
- **Impact:** Perfect Counter damage +35 (was +20)
- **Source:** Reforged Empyrean +3 upgrade

#### 5. **Bhikku Hose +3**
- **Current:** Bhikku Hose +2
- **Impact:** Best TP legs, Kick Attacks+30, STP+10, DT-14%
- **Source:** Reforged Empyrean +3 upgrade

### Low Priority (Min-Max)

#### 6. **Anchorite's Set +3 → +4**
- Enhanced job ability effects
- Incremental stat improvements

#### 7. **Hesychast's Set +2 → +3**
- Enhanced job ability effects
- Counter rate improvements

---

## 🛠️ Troubleshooting

### Common Issues

**Problem:** Gear not swapping
- **Solution:** Check `//gs showswaps` to see if sets are triggering
- **Solution:** Verify gear names match exactly (case-sensitive)
- **Solution:** Run `//gs validate` to check for missing gear

**Problem:** "Cannot equip item" errors
- **Solution:** Item may be in mog house, wardrobe, or satchel
- **Solution:** Check if item is MNK-equippable
- **Solution:** Verify item name spelling

**Problem:** Wrong mode active
- **Solution:** Check current mode with `//gs c cycle OffenseMode`
- **Solution:** Reset to default: `//gs reload`

**Problem:** Keybinds not working
- **Solution:** Make sure no other addon is using same keybinds
- **Solution:** Check Windower key settings

**Problem:** Position resets during actions
- **Solution:** The file includes no_interruptions code
- **Solution:** Toggle with `//gs c interrupts` if having issues
- **Solution:** May need to adjust based on lag/latency

### Getting Help

1. Check the log window for error messages
2. Use `//gs validate` to check gear
3. Use `//gs showswaps` to see what's equipping
4. Check FFXIAH or BG Wiki forums for GearSwap help

---

## 📊 Technical Notes

### Position Locking
The file includes position-locking code to prevent animation interruption during gear swaps. This is the `no_interruptions` system at the top of the file.

### Set Combining
The file uses `set_combine()` for efficient set building:
- Base sets defined once
- Variants created by combining with base
- Reduces code duplication

### Buff Detection
Automatic detection for:
- **Impetus** - Swaps to Bhikku Cyclas +2 for +45% crit damage
- **Footwork** - Swaps to Anch. Gaiters +2 for kick boost
- **Boost** - Uses Ask Sash for TP generation

### Macro Book Selection
The file automatically sets macro book based on subjob:
- /DNC → Book 2, Page 1
- /NIN → Book 2, Page 1
- /THF → Book 2, Page 1
- /RUN → Book 2, Page 1
- Other → Book 2, Page 1

---

## 📚 Resources

### Recommended Reading
- [BG Wiki - Community Monk Guide](https://www.bg-wiki.com/ffxi/Community_Monk_Guide)
- [FFXIAH - Monk Forums](https://www.ffxiah.com/forum/topic/29740/hesychasts-contemplations-a-monk-guide/)
- [GearSwap Documentation](https://github.com/Windower/Lua/wiki/GearSwap)

### Gear Calculators
- [FFXIAH Gear Sets](https://www.ffxiah.com/gearsets)
- [FFXI AH - Gear Builder](https://www.ffxiah.com/)

### Community Resources
- [Windower Discord](https://discord.gg/windower)
- [FFXI Reddit](https://www.reddit.com/r/ffxi/)

---

## 🙏 Credits

**Created for:** Linktri  
**Based on:** Community Monk Guide (BG Wiki)  
**GearSwap:** Windower development team  
**Optimization:** Claude (Anthropic) - October 2025

**Special Thanks:**
- BG Wiki contributors for the comprehensive Monk guide
- FFXIAH community for gear data
- Windower team for GearSwap addon

---

## 📝 Changelog

### Version 2.0 (October 2025)
- ✅ Filled 48 blank gear slots
- ✅ Verified all gear against inventory
- ✅ Removed references to unavailable gear (Mnk. Nodowa +2, Moonbow Belt +1)
- ✅ Added Rep. Plat. Medal as neck slot solution
- ✅ Added Reiki Yotai/Eschan Stone as waist solutions
- ✅ Optimized accuracy progression (Normal → Acc → FullAcc)
- ✅ Added comments for upgrade paths
- ✅ Verified MNK equipability for all items
- ✅ Added Carrier's Sash to defensive sets
- ✅ Configured Chirich Ring +1 x2 for accuracy builds

### Version 1.0 (Original)
- Base file with many blank slots
- Core functionality and mode system
- Job ability sets configured
- Weapon sets defined

---

## 📄 License

This gear file is provided as-is for personal use. Feel free to modify and adapt for your own character. If sharing modifications, please credit the original sources (BG Wiki, community contributors).

---

## 🎮 Quick Start Guide

**New to this file? Start here:**

1. **Install the file** (see Installation section)
2. **Load in-game:** `//gs reload`
3. **Start with Normal mode** - Everything pre-configured
4. **For harder content:** `//gs c cycle OffenseMode` → Acc mode
5. **Need defense?** `//gs c cycle HybridMode` → PDT mode
6. **Read the Quick Reference** included in your download

**That's it!** The file handles everything else automatically.

---

**Last Updated:** October 28, 2025  
**Maintained by:** Linktri  
**Questions?** Check the Troubleshooting section above

Happy punching! 🥊