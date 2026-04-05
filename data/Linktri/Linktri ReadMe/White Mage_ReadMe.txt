# White Mage GearSwap README

## Overview
This White Mage GearSwap setup is based on the Selindrile framework with custom gear configurations. It provides automatic gear swapping for optimal performance across all White Mage activities.

## Key Features
- **Automatic gear swapping** for all spell types and situations
- **Multiple casting modes** (Normal, Resistant, SIRD, DT)
- **Weapon mode support** (None, MeleeWeapons, DualWeapons)
- **Light weather/day optimization** for cure spells
- **Bar-status spell optimization** with Sroda Necklace
- **Afflatus Solace integration**
- **SIRD and DT hybrid support**

## Mode Commands

### Casting Modes
```bash
//gs c cycle CastingMode          # Cycle: Normal → Resistant → SIRD → DT
//gs c set CastingMode Normal     # Default casting gear
//gs c set CastingMode Resistant  # High magic accuracy for tough enemies  
//gs c set CastingMode SIRD       # Spell Interruption Rate Down gear
//gs c set CastingMode DT         # Damage Taken reduction gear
```

### Weapon Modes
```bash
//gs c cycle Weapons              # Cycle weapon configurations
//gs c set Weapons None           # No weapons equipped (staff/club swapping)
//gs c set Weapons MeleeWeapons   # Maxentius + Sors Shield
//gs c set Weapons DualWeapons    # Maxentius + Yagrush
```

### Idle Modes
```bash
//gs c cycle IdleMode             # Cycle idle configurations
//gs c set IdleMode Normal        # Standard refresh/MP gear
//gs c set IdleMode PDT           # Physical damage reduction
//gs c set IdleMode MDT           # Magical damage reduction
```

### Weaponskill Modes
```bash
//gs c cycle WeaponskillMode      # Cycle WS configurations
//gs c set WeaponskillMode Normal # Standard WS gear
//gs c set WeaponskillMode Fodder # High damage for easy content
```

## Manual Gearset Testing Commands

### Precast Sets (Fast Cast)
```bash
//gs equip sets.precast.FC                    # Standard fast cast
//gs equip sets.precast.FC.DT                 # Fast cast with damage taken protection
//gs equip sets.precast.FC.Cure               # Cure-specific fast cast
//gs equip sets.precast.FC["Enhancing Magic"] # Enhancing magic fast cast
//gs equip sets.precast.FC["Healing Magic"]   # Healing magic fast cast
```

### Cure Sets
```bash
//gs equip sets.midcast.Cure                  # Standard cure set
//gs equip sets.midcast.CureSolace            # Afflatus Solace cure set
//gs equip sets.midcast.Cure.DT               # Cure with damage taken protection
//gs equip sets.midcast.Cure.SIRD             # Cure with spell interruption protection
//gs equip sets.midcast.LightWeatherCure      # Light weather cure set
//gs equip sets.midcast.LightDayCure          # Light day cure set
//gs equip sets.midcast.Curaga                # Curaga set
//gs equip sets.midcast.MeleeCure             # Cure set for melee mode
```

### Enhancing Magic Sets
```bash
//gs equip sets.midcast["Enhancing Magic"]    # Standard enhancing magic
//gs equip sets.midcast["Enhancing Magic"].SIRD # Enhancing with SIRD
//gs equip sets.midcast["Enhancing Magic"].DT   # Enhancing with DT protection
//gs equip sets.midcast.Stoneskin             # Stoneskin-specific gear
//gs equip sets.midcast.Aquaveil              # Aquaveil-specific gear
//gs equip sets.midcast.Regen                 # Regen-specific gear
//gs equip sets.midcast.Auspice               # Auspice-specific gear
```

### Bar Spell Sets
```bash
//gs equip sets.midcast.BarElement            # Bar-element spells (Barthundra, etc.)
//gs equip sets.midcast.Barparalyzra          # Bar-status spells (with Sroda Necklace)
//gs equip sets.midcast.Barblindra            # Bar-blindness (with Sroda Necklace)
//gs equip sets.midcast.Barsilencera          # Bar-silence (with Sroda Necklace)
//gs equip sets.midcast.Protect               # Protect-specific gear
//gs equip sets.midcast.Shell                 # Shell-specific gear
```

### Status Removal Sets
```bash
//gs equip sets.midcast.Cursna               # Cursna set (Yagrush for best results)
//gs equip sets.midcast.StatusRemoval        # General status removal (Paralyna, etc.)
//gs equip sets.midcast.Erase                # Erase set
```

### Enfeebling Magic Sets
```bash
//gs equip sets.midcast["Enfeebling Magic"]           # Standard enfeebling
//gs equip sets.midcast["Enfeebling Magic"].Resistant # High magic accuracy enfeebling
//gs equip sets.midcast.MndEnfeebles                  # MND-based enfeebles
//gs equip sets.midcast.IntEnfeebles                  # INT-based enfeebles
//gs equip sets.midcast.Dispel                        # Dispel set
//gs equip sets.midcast.Dispelga                      # Dispelga set
```

### Elemental Magic Sets
```bash
//gs equip sets.midcast["Elemental Magic"]           # Standard nuking
//gs equip sets.midcast["Elemental Magic"].Resistant # High magic accuracy nuking
//gs equip sets.midcast.Holy                         # Holy-specific gear
//gs equip sets.midcast["Divine Magic"]              # Divine magic set
//gs equip sets.midcast["Dark Magic"]                # Dark magic set
//gs equip sets.midcast.Drain                        # Drain/Aspir set
```

### Idle and Engaged Sets
```bash
//gs equip sets.idle                         # Standard idle set
//gs equip sets.idle.PDT                     # Physical damage idle
//gs equip sets.idle.MDT                     # Magical damage idle
//gs equip sets.engaged                      # Melee engagement set
//gs equip sets.engaged.DW                   # Dual wield engagement
```

### Defense Sets
```bash
//gs equip sets.defense.PDT                  # Physical damage defense
//gs equip sets.defense.MDT                  # Magical damage defense  
//gs equip sets.defense.MEVA                 # Magic evasion defense
```

### Weaponskill Sets
```bash
//gs equip sets.precast.WS                   # Standard weaponskill
//gs equip sets.precast.WS.Fodder            # High damage WS for easy content
//gs equip sets.precast.WS.Dagan             # Dagan weaponskill (Gambanteinn)
```

## Key Bindings

The following key bindings are automatically set up:

```bash
Ctrl + `        # Arise on target
Alt + `         # Penury
Win + `         # Cycle Magic Burst Mode
Ctrl + Alt + `  # Toggle Auto Caress
Ctrl + Backspace # Sacrosanctity
Win + Backspace  # Aurora Storm
Alt + Pause     # Toggle Auto Sublimation Mode
Alt + Backspace # Accession  
Alt + =         # Sublimation
Ctrl + Delete   # Dark Arts
Alt + Delete    # Addendum: Black
Win + Delete    # Manifestation
Ctrl + \        # Protectra V on self
Win + \         # Shellra V on self
Alt + \         # Reraise IV on self
```

## Special Features

### Bar-Status Spell Optimization
Bar-status spells (Barparalyzra, Barblindra, etc.) automatically equip the Sroda Necklace for +10 Bar-spell effect, enhancing status ailment resistance.

### Light Weather/Day Detection
Cure spells automatically detect light weather and light day conditions to equip optimal gear combinations (Chatoyant Staff, Hachirin-no-Obi, etc.).

### Afflatus Solace Integration
When Afflatus Solace is active, cure spells automatically use Solace-optimized gear sets (Ebers Bliaut +3).

### SIRD/DT Hybrid Modes
The DT casting mode provides both damage taken reduction and spell interruption protection for dangerous situations.

## Troubleshooting

### Common Issues
1. **Gear not swapping**: Check that the item names match your inventory exactly
2. **Missing items**: Empty quotes ("") are used for items not yet obtained
3. **Syntax errors**: Ensure all quotes are properly closed

### Status Check
//gs c state    # View all current mode settings
```

### Force Equipment Update
//gs c update   # Force gearswap to re-evaluate current situation
```

## Installation Notes
- Place this file in your `Windower/addons/gearswap/data/` folder
- Rename to match your character name (e.g., `Charactername_WHM_Gear.lua`)
- Requires the Selindrile WHM.lua core file
- Set macro book to Book 3, Page 1 for optimal key binding compatibility

## How the Gearsets Work Together

### Automatic Set Selection Hierarchy
The gearswap uses a priority system to determine which set to equip:

1. **Spell-specific sets** (highest priority) - e.g., `sets.midcast.Barparalyzra`
2. **Casting mode variants** - e.g., `sets.midcast.Cure.DT` when in DT mode
3. **Spell category sets** - e.g., `sets.midcast["Enhancing Magic"]`
4. **General midcast** (lowest priority) - `sets.midcast`

### Mode Combinations and Scenarios

#### High-End Content (Omen, Master Trials, Sortie)
**Recommended Setup:**
- `CastingMode: DT` - Provides both damage reduction and SIRD
- `Weapons: None` - Allows weapon swapping for optimal spell performance
- `IdleMode: PDT` or `MDT` - Based on primary damage source

**Why this works:**
- DT mode gives you survivability while maintaining cure potency
- Weapon swapping ensures you get Yagrush for Cursna, Raetic Rod for cures
- The sets automatically layer: `sets.midcast.Cure.DT` combines your cure gear with damage reduction pieces

#### Mid-Tier Content (Ambuscade VD, Lilith)
**Recommended Setup:**
- `CastingMode: SIRD` - Prevents interruptions without sacrificing too much potency
- `Weapons: MeleeWeapons` or `DualWeapons` - Stay engaged for TP/damage
- `IdleMode: Normal` - Standard refresh gear

**Why this works:**
- SIRD mode prioritizes spell completion over max potency
- Melee weapon modes use `sets.midcast.MeleeCure` variants
- Less defensive than DT mode but more reliable casting than Normal

#### Easy Content and Solo Play
**Recommended Setup:**
- `CastingMode: Normal` - Maximum potency and MP efficiency
- `Weapons: None` - Full weapon swapping capability
- `WeaponskillMode: Fodder` - Higher damage for faster kills

**Why this works:**
- Normal mode optimizes for cure potency, enhancing skill, and MP conservation
- Weapon swapping gives you the best tool for each situation
- Light weather/day detection automatically improves cure efficiency

### Spell-Specific Interactions

#### Cursna Optimization
```bash
# The system automatically selects the best Cursna setup:
# 1. Yagrush (if available) for maximum Cursna skill
# 2. Divine Caress detection for hands/back swap
# 3. Gambanteinn toggle available for ultimate Cursna power
```

#### Bar Spell Intelligence
```bash
# Bar-element spells: sets.midcast.BarElement (general enhancing focus)
# Bar-status spells: sets.midcast.Barparalyzra (Sroda Necklace variant)
# The system distinguishes between these automatically
```

#### Weather/Day Synergy
```bash
# Light weather detected:
# - Cure spells → sets.midcast.LightWeatherCure (Chatoyant Staff, Hachirin-no-Obi)
# - Light day only → sets.midcast.LightDayCure (keeps Raetic Rod, adds Hachirin-no-Obi)
# - Combines with Solace: sets.midcast.LightWeatherCureSolace
```

### Advanced Mode Combinations

#### "Tank Healer" Setup
**Scenario:** Main healing in dangerous content where you're taking consistent damage
```bash
//gs c set CastingMode DT
//gs c set IdleMode PDT
//gs c set Weapons MeleeWeapons
```
**Result:** Maximum survivability while maintaining healing capability

#### "Speed Healer" Setup  
**Scenario:** Safe environment, need maximum healing throughput
```bash
//gs c set CastingMode Normal
//gs c set IdleMode Normal
//gs c set Weapons None
```
**Result:** Optimal cure potency, full weapon swapping, maximum MP efficiency

#### "Interrupted Healer" Setup
**Scenario:** High spell interruption environment (lots of AoE, can't avoid damage)
```bash
//gs c set CastingMode SIRD
//gs c set IdleMode Normal
//gs c set Weapons DualWeapons
```
**Result:** Spell completion priority while maintaining some offense

### Set Synergy Examples

#### Afflatus Solace + Light Weather
When both conditions are active, the system uses `sets.midcast.LightWeatherCureSolace`:
- Inherits cure potency from Solace gear (Ebers Bliaut +3)
- Adds weather optimization (Chatoyant Staff, Hachirin-no-Obi)
- Combines with current CastingMode (e.g., `.DT` variant for dangerous content)

#### Divine Caress + Cursna
When Divine Caress buff is active during status removal:
- Base set: `sets.midcast.Cursna` (Yagrush, healing skill focus)
- Automatic overlay: `sets.buff["Divine Caress"]` (Ebers Mitts +3, Mending Cape)
- Result: Maximum Cursna effectiveness with buff enhancement

#### Magic Burst + Elemental Magic
When Magic Burst mode is active:
- Base set: `sets.midcast["Elemental Magic"]` (magic attack focus)
- Automatic overlay: `sets.MagicBurst` (Mujin Band, Locus Ring)
- Casting mode respected: `.Resistant` for accuracy when needed

### Troubleshooting Mode Conflicts

#### When Sets Don't Exist
If you set `CastingMode: SIRD` but don't have `sets.midcast.Cure.SIRD` defined:
- System falls back to `sets.midcast.Cure`
- No error occurs, but you lose SIRD benefits
- **Solution:** Define missing mode variants or use available modes

#### Weapon Mode vs. Optimal Weapons
If `Weapons: MeleeWeapons` but casting Cursna:
- System keeps your melee weapons equipped
- You lose Yagrush's Cursna bonuses
- **Solution:** Temporarily set `Weapons: None` for important Cursna casts

#### Mode Change Timing
Mode changes only affect the next spell cast:
- Current spell completes with current gear
- Next spell uses new mode's gear
- **Best Practice:** Change modes between spell casts, not during

## Customization
Empty gear slots marked with `""` can be filled in as you acquire items. Comments indicate where items can be obtained and their approximate costs/difficulty.