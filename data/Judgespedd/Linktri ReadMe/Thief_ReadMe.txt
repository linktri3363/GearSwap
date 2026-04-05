# Linktri's Thief GearSwap Guide

## Table of Contents
1. [Installation](#installation)
2. [Keyboard Shortcuts](#keyboard-shortcuts)
3. [GearSwap Console Commands](#gearswap-console-commands)
4. [Modes & States](#modes--states)
5. [Weapon Sets](#weapon-sets)
6. [Gear Set Overview](#gear-set-overview)
7. [Tips & Best Practices](#tips--best-practices)

---

## Installation

1. Place `Linktri_Thf_Gear_FIXED.lua` in your GearSwap data folder:
   - `Windower4/addons/GearSwap/data/[YourCharName]/`
2. Rename to match your character: `[YourCharName]_THF.lua`
3. In-game, type: `//gs reload`
4. Check for errors in the console

---

## Keyboard Shortcuts

### Job Abilities & Actions
| Keybind | Action | Description |
|---------|--------|-------------|
| **Ctrl + `** | Flee | Activates Flee (emergency escape) |
| **Alt + `** | Ranged Attack | Shoots target with ranged weapon |
| **Ctrl + Backspace** | Thief's Tools | Uses Thief's Tools on target |
| **Alt + Backspace** | Hide | Activates Hide ability |
| **Ctrl + \\** | Despoil | Uses Despoil on target |
| **Alt + \\** | Mug | Uses Mug on target |

### Weapon Swaps
| Keybind | Weapon Set | Primary Use |
|---------|------------|-------------|
| **Ctrl + Q** | Proc Weapons | Low-level proc weapons (Dynamis/Sortie) |
| **Alt + Q** | Sword + Throwing | Naegling + Gleti's Knife |

### Red Proc Weapons (Abyssea)
| Keybind | Weapon | Magic WS |
|---------|--------|----------|
| **Ctrl + Numpad 1** | Dagger | Energy Drain / Cyclone |
| **Ctrl + Numpad 2** | Sword | Seraph Blade / Red Lotus Blade |
| **Ctrl + Numpad 3** | Great Sword | Freezebite |
| **Ctrl + Numpad 4** | Scythe | Shadow of Death |
| **Ctrl + Numpad 5** | Polearm | Raiden Thrust |
| **Ctrl + Numpad 6** | Club | Seraph Strike |
| **Ctrl + Numpad 7** | Staff | Earth Crusher / Starburst |

### Mode Toggles
| Keybind | Mode | Description |
|---------|------|-------------|
| **Win + `** | Skillchain Mode | Cycles skillchain coordination mode |
| **Win + F10** | Ambush Mode | Toggles Ambush mode (Plunderer's Vest +4) |

---

## GearSwap Console Commands

### Basic Commands
```
//gs reload              # Reload GearSwap file
//gs validate            # Check file for errors
//gs showswaps           # Show gear swaps in chat log
//gs debugmode           # Toggle debug mode (shows detailed swap info)
```

### Mode Cycling Commands
All mode changes can be done via console OR the built-in F-key bindings (F9-F12).

#### Offense Mode (F9)
```
//gs c cycle OffenseMode
```
**Options**: Normal, STP, SomeAcc, Acc, FullAcc, Fodder
- **Normal**: Balanced TP set with good multi-attack
- **STP**: Maximum Store TP for faster WS (STP+19)
- **SomeAcc**: Light accuracy boost
- **Acc**: High accuracy for tough content
- **FullAcc**: Maximum accuracy
- **Fodder**: Maximum damage for easy content

#### Hybrid Mode (Ctrl + F9)
```
//gs c cycle HybridMode
```
**Options**: Normal, DT
- **Normal**: Standard offense sets
- **DT**: Damage Taken sets (50% DT cap)

#### Weaponskill Mode (Ctrl + F10)
```
//gs c cycle WeaponskillMode
```
**Options**: Match, Normal, DT, SomeAcc, Acc, FullAcc, Fodder, Proc
- **Match**: Matches your current OffenseMode
- **Normal**: Standard WS set
- **DT**: WS with damage taken gear
- **Acc tiers**: For accuracy-dependent content
- **Proc**: For Dynamis proc weaponskills

#### Idle Mode (F10)
```
//gs c cycle IdleMode
```
**Options**: Normal, Sphere
- **Normal**: DT, Regain, Regen focused
- **Sphere**: For Geomancy skill (if needed)

#### Physical Defense (Alt + F10)
```
//gs c cycle PhysicalDefenseMode
```
**Options**: PDT (50% DT cap with Nyame)

#### Magical Defense (Alt + F11)
```
//gs c cycle MagicalDefenseMode
```
**Options**: MDT (50%+ DT, 28% MDT with Malignance)

#### Resist Defense (Alt + F12)
```
//gs c cycle ResistDefenseMode
```
**Options**: MEVA (High Magic Evasion)

### Weapon Set Commands
```
//gs c weapons Prime              # Mpu Gandring + Centovente
//gs c weapons Twashtar            # Twashtar + Centovente
//gs c weapons Vajra               # Vajra + Gleti's Knife
//gs c weapons Aeneas              # Aeneas + Gleti's Knife
//gs c weapons Tauret              # Tauret + Gleti's Knife (Evisceration)
//gs c weapons Savage              # Naegling + Gleti's Knife (Savage Blade)
//gs c weapons ProcWeapons         # Qutrub Knife + Ethereal Dagger
//gs c weapons Evisceration        # Tauret + Gleti's Knife
//gs c weapons Throwing            # Qutrub Knife + Twinned Blade
//gs c weapons SwordThrowing       # Naegling + Gleti's Knife
//gs c weapons Bow                 # Mpu Gandring + Ternion + Hangaku-no-Yumi
```

#### Red Proc Weapon Commands
```
//gs c weapons RedProcDagger       # Ethereal Dagger + Qutrub Knife
//gs c weapons RedProcSword        # Twinned Blade + Ethereal Dagger
//gs c weapons RedProcGrSwd        # Ophidian Sword
//gs c weapons RedProcScythe       # Ark Scythe
//gs c weapons RedProcPole         # Tzee Xicu's Blade
//gs c weapons RedProcClub         # Nmd. Moogle Rod + Ethereal Dagger
//gs c weapons RedProcStaff        # Cobra Staff
```

### Extra Melee Mode Commands
```
//gs c cycle ExtraMeleeMode
```
**Options**: None, Suppa, DWMax, Parry
- **None**: Standard engaged set
- **Suppa**: Adds Suppanomimi + Sherida (for specific DW needs)
- **DWMax**: Maximum DW (Dudgeon + Heartseeker + Floral)
- **Parry**: Adds Defending Ring for parrying

### Toggle Commands
```
//gs c toggle AmbushMode          # Toggles Plunderer's Vest +4 for Ambush
//gs c toggle Kiting              # Toggles movement speed gear
```

### State Locking/Unlocking
```
//gs c set OffenseMode Acc        # Lock to Acc mode
//gs c set HybridMode DT           # Lock to DT mode
//gs c set WeaponskillMode Normal  # Lock to Normal WS mode
//gs c reset OffenseMode           # Unlock/reset to cycle through modes
```

---

## Modes & States

### Default F-Key Bindings (Built into Mote Library)
- **F9**: Cycle Offense Mode (Normal → STP → SomeAcc → Acc → FullAcc → Fodder)
- **F10**: Cycle Idle Mode (Normal → Sphere)
- **F11**: Cycle Defense Mode
- **F12**: Update currently equipped gear

- **Ctrl + F9**: Cycle Hybrid Mode (Normal → DT)
- **Ctrl + F10**: Cycle Weaponskill Mode
- **Ctrl + F11**: Cycle Casting Mode (not used for THF)
- **Ctrl + F12**: Cycle Ranged Mode

- **Alt + F10**: Cycle Physical Defense Mode (PDT)
- **Alt + F11**: Cycle Magical Defense Mode (MDT)
- **Alt + F12**: Cycle Resist Defense Mode (MEVA)

- **Win + F9**: Cycle OffenseMode backwards
- **Win + F10**: Toggle Kiting mode

---

## Weapon Sets

### Recommended Weapon Sets by Content

| Content Type | Weapon Set | Primary WS | Why |
|--------------|-----------|------------|-----|
| **General Endgame** | Prime or Twashtar | Ruthless Stroke / Rudra's Storm | Best overall damage |
| **Odyssey Gaol** | Vajra | Mandalic Stab | Aftermath III useful, mythic damage |
| **TP Burn / Easy** | Tauret | Evisceration | High crit rate, fast TP |
| **Cleaving** | Savage | Savage Blade | AoE damage with Naegling |
| **Sortie/Dyna Proc** | ProcWeapons | Wasp Sting | Quick proc weapons |
| **Abyssea Red Proc** | RedProc[Type] | Magic WS | Specific weapon for each element |

### Weapon Set Details

#### **Prime** (Best Overall)
- Main: Mpu Gandring
- Sub: Centovente
- WS: Ruthless Stroke
- Use: Best damage output, optimal for endgame

#### **Twashtar** (REMA Dagger)
- Main: Twashtar
- Sub: Centovente
- WS: Rudra's Storm
- Use: Close second to Prime, excellent mythic

#### **Vajra** (Mythic)
- Main: Vajra
- Sub: Gleti's Knife
- WS: Mandalic Stab
- Use: Aftermath III gives excellent multi-attack

#### **Savage** (Cleaving)
- Main: Naegling
- Sub: Gleti's Knife
- WS: Savage Blade
- Use: AoE damage, great for multiple targets

#### **Tauret** (Critical Build)
- Main: Tauret
- Sub: Gleti's Knife
- WS: Evisceration
- Use: High crit rate, fast TP generation

---

## Gear Set Overview

### TP Sets (Engaged)

#### **sets.engaged** (Normal)
- **Focus**: Balanced multi-attack with proper DW capping
- **Key Pieces**:
  - Head: Skulker's Bonnet +3 (TA+6%, Phys Dmg Limit+10%)
  - Body: Skulker's Vest +3 (WSD+12%, Conspirator)
  - Hands: Pill. Armlets +4 (DW+5, TA dmg+20)
  - Waist: Reiki Yotai (DW+7)
  - Legs: Samnuha Tights (TA+2%, DA+3%)
  - Feet: Plun. Poulaines +4 (TA+5%, TA dmg+11)

#### **sets.engaged.STP**
- **Focus**: Maximum Store TP (STP+19 total)
- **Changes**:
  - Ear2: Dedition Earring (STP+8)
  - Ring1+2: Double Chirich Ring +1 (STP+6 each)

#### **sets.engaged.Acc/FullAcc**
- **Focus**: Maximum accuracy for difficult content
- **Changes**: Pillager +4 pieces, Odr Earring, Skulk. Earring +1

#### **sets.engaged.Fodder**
- **Focus**: Maximum damage for easy content
- **Changes**: Floral Gauntlets (TA+3%), full multi-attack focus

#### **sets.engaged.DT** (Hybrid)
- **Focus**: 50% DT cap with offense
- **Uses**: Full Nyame Path B
- **DT Total**: 57% (capped at 50%)

### Idle Set
- **Focus**: DT, Regain (passive TP gain), Regen (passive HP recovery)
- **Key Pieces**:
  - Head: Gleti's Mask (Regain, DT)
  - Body: Gleti's Cuirass (Regain+10, Regen+10)
  - Full Gleti's set for maximum Regain
  - Murky Ring (DT-10%)
  - Loricate Torque +1 (DT-6%)
- **Total DT**: 32% unbuffed
- **NO REFRESH**: THF doesn't need MP recovery

### Weaponskill Sets

#### **Rudra's Storm / Ruthless Stroke / Mandalic Stab**
- **Standard Set**: WSD stacking with Nyame + Pillager/Plunderer +4
- **Capped Set**: Uses Skulker +3 body (WSD+12% from Conspirator) + Gleti's
- **SA/TA Sets**: Uses Pill. Armlets +4 (TA dmg+20) and Plun. Culottes +4

#### **Evisceration**
- **Focus**: Critical rate stacking
- **Key Pieces**:
  - Head: Mummu Bonnet +2 (Crit rate+5%)
  - Body: Plunderer's Vest +4 (Crit rate+6%, Crit dmg+5%)
  - Ring1: Gere Ring (Crit rate+5%)
  - Ring2: Mummu Ring (Crit rate+3%)
  - Full Gleti's for crit damage

#### **Savage Blade**
- **Focus**: STR/MND hybrid WS
- **Uses**: Mix of Nyame and Pillager +4 for WSD

#### **Aeolian Edge** (Magic WS)
- **Focus**: Magic Attack Bonus
- **Uses**: Full Nyame with MAB accessories

### Treasure Hunter
```lua
sets.TreasureHunter = {
    hands = "Plun. Armlets +4",  -- TH+4
    waist = "Chaac Belt",         -- TH+1
    feet = "Skulk. Poulaines +3", -- TH+5
    ammo = "Per. Lucky Egg"       -- TH+1
}
```
**Total**: TH+11 equipment (with TH+3 trait = TH14 base)

### Buffs

#### Sneak Attack
```lua
sets.buff["Sneak Attack"] = {hands = "Skulk. Armlets +3"} -- SA+30
```

#### Trick Attack
```lua
sets.buff["Trick Attack"] = {hands = "Pill. Armlets +4"} -- TA dmg+20
```

#### Ambush Mode
When toggled ON with **Win+F10**:
```lua
sets.Ambush = {body = "Plunderer's Vest +4"} -- Crit+6%, Crit dmg+5%
```

---

## Tips & Best Practices

### Dual Wield Requirements
With **Haste Samba** (10%) + **Magic Haste** (43.75% capped):
- Need **DW+11** with 550+ Job Points
- **Your sets provide**: Reiki Yotai (DW+7) + Pill. Armlets +4 (DW+5) = **DW+12** ✓

### Optimal TP Rotation
1. Start in **Normal** mode for general content
2. Switch to **STP** mode if TP gain feels slow
3. Use **Acc** modes only when missing frequently
4. Toggle **DT** mode (Ctrl+F9) for dangerous TP moves

### Weaponskill Strategy
1. **Rudra's Storm** is your default WS for most builds
2. Use **Evisceration** with Tauret for crit-heavy situations
3. **Savage Blade** with Naegling for cleaving/AoE
4. **Mandalic Stab** when using Vajra (especially with AM3 up)

### Treasure Hunter Usage
- TH automatically applied to: Steps, Violent Flourish, Provoke
- TH set swaps in automatically when using these actions
- Base TH14 (TH+3 trait + TH+11 gear) with proc potential to TH14+

### Sneak Attack / Trick Attack Usage
- **SA**: Automatically equips Skulk. Armlets +3 (SA+30 damage)
- **TA**: Automatically equips Pill. Armlets +4 (TA damage+20)
- **SATA**: Both bonuses apply when using SA+TA together
- Best used with weaponskills for massive damage

### Common Workflows

#### **Odyssey Gaol Boss**
```
1. //gs c weapons Vajra
2. //gs c set OffenseMode Acc
3. //gs c set HybridMode DT
4. F12 to update gear
```

#### **Sortie/Dynamis Proc**
```
1. Ctrl+Q (proc weapons)
2. //gs c set WeaponskillMode proc
3. Use Wasp Sting for procs
```

#### **Abyssea Red Proc**
```
1. Ctrl+Numpad[1-7] (specific weapon for element)
2. Use corresponding magic WS
```

#### **Ambuscade/Domain Invasion**
```
1. //gs c weapons Savage
2. //gs c set OffenseMode Fodder
3. Cleave with Savage Blade
```

### Troubleshooting

**Problem**: Gear not swapping
```
Solution: //gs reload
          //gs validate (check for errors)
```

**Problem**: Missing gear errors
```
Solution: Check if gear is in inventory/equipped
          Comment out missing gear pieces in the file
```

**Problem**: Wrong weapon set equipped
```
Solution: //gs c weapons [SetName]
          F12 to force update
```

**Problem**: Stuck in wrong mode
```
Solution: //gs c reset [ModeName]
          Or cycle through with F9/F10/etc.
```

### Advanced: Lockstyle

The file includes a `user_job_lockstyle()` function that automatically changes your lockstyle based on weapon equipped:
- Dagger/Sword in main: Uses lockstyle set 006
- Other weapons: Uses lockstyle set 001

You can customize these lockstyle set numbers to your preferences in the file.

---

## Auto-WS Table

The file includes an auto-weaponskill table that sets the default WS for each weapon set:

| Weapon Set | Default WS |
|------------|------------|
| Prime | Ruthless Stroke |
| Twashtar | Rudra's Storm |
| Vajra | Mandalic Stab |
| Tauret | Evisceration |
| Aeneas | Rudra's Storm |
| Savage | Savage Blade |
| Throwing | Rudra's Storm |
| SwordThrowing | Savage Blade |
| Evisceration | Evisceration |
| ProcWeapons | Wasp Sting |
| Bow | Empyreal Arrow |

---

## Quick Reference Card

### Most Important Commands
```
//gs reload                    # Reload file
//gs c weapons Prime           # Best weapon set
//gs c cycle OffenseMode       # Change TP mode (F9)
//gs c cycle HybridMode        # Toggle DT (Ctrl+F9)
//gs c set OffenseMode Acc     # Lock to Acc mode
Ctrl+Q                         # Proc weapons
Win+F10                        # Toggle Ambush
```

### Emergency Shortcuts
```
Ctrl+`                         # Flee (escape)
Alt+Backspace                  # Hide
F11                            # Defense Mode
```

---

## File Information
- **Version**: Optimized for Linktri
- **Line Count**: 975 lines
- **Last Updated**: 2025
- **Compatible With**: Mote-Include library, GearSwap

## Support
For issues or questions:
1. Check `//gs validate` for errors
2. Use `//gs debugmode` to see detailed swap info
3. Verify all gear pieces are in your inventory

---

**Enjoy your optimized Thief gameplay!**