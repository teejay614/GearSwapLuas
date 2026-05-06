-- Classic WAR.lua for Timothy
-- - Uses ONLY gear from your exported list
-- - Automatic weapon detection (Chango, Naegling, Shining One, etc.)
-- - TP / Hybrid / DT / Idle / WS sets modeled after BG-Wiki WAR page
-- - Preserves key set bonuses where possible (Flamma +2, Sulevia +2, Pummeler +3/+4)
-- - Movement: prioritizes Shneddick Ring over movement legs
-- - Auto 180° turn for petrify TP moves
-- - Auto item use for common status ailments

-------------------------------------------------------------------------------------------------------------------
-- Setup
-------------------------------------------------------------------------------------------------------------------

function get_sets()
    -- Modes
    state = {}
    state.OffenseMode = {index = {'Normal','Acc','Hybrid'}}
    state.OffenseMode.current = 'Normal'

    state.IdleMode = {index = {'Normal','DT','Regen','Movement'}}
    state.IdleMode.current = 'Normal'

    state.WeaponMode = {index = {'Chango','Naegling','ShiningOne','Axe','GreatSword','Club','Polearm','Other'}}
    state.WeaponMode.current = 'Chango'

    -- Internal
    current_weapon = 'Chango'
    last_status = 'Idle'

    -- Tables
    sets = {}
    sets.precast = {}
    sets.midcast = {}
    sets.aftercast = {}
    sets.JA = {}
    sets.WS = {}
    sets.idle = {}
    sets.engaged = {}

    ----------------------------------------------------------------------------------------------------------------
    -- Job Abilities
    ----------------------------------------------------------------------------------------------------------------
    sets.JA.Berserk = {
        body="Pumm. Lorica +3",
        feet="Agoge Calligae +1",
        back={ name="Cichol's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10','Phys. dmg. taken-10%',}},
    }

    sets.JA.Aggressor = {
        head="Pummeler's Mask +3",
        body="Pumm. Lorica +3",
    }

    sets.JA.Warcry = {
        head="Pummeler's Mask +3",
    }

    sets.JA.BloodRage = {
        body="Pumm. Lorica +3",
    }

    sets.JA.Provoke = {
        ammo="Thr. Tomahawk",
        head="Genmei Kabuto",
        neck="Loricate Torque",
        body="Eschite Breast.",
        hands="Sulev. Gauntlets +2",
        legs="Pumm. Cuisses +4",
        feet="Sulev. Leggings +2",
        left_ring="Defending Ring",
        back={ name="Cichol's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10','Phys. dmg. taken-10%',}},
    }

    ----------------------------------------------------------------------------------------------------------------
    -- Precast
    ----------------------------------------------------------------------------------------------------------------
    sets.precast.FC = {
        head="Rabid Visor",
        neck="Null Loop",
        left_ear="Loquac. Earring", -- if you ever get it; safe to leave empty if not
    }

    ----------------------------------------------------------------------------------------------------------------
    -- Weaponskill sets
    -- (Modeled after BG-Wiki priorities, using only your gear)
    ----------------------------------------------------------------------------------------------------------------

    -- Generic STR/ATT WS
    sets.WS.Generic = {
        ammo="Knobkierrie",
        head="Pummeler's Mask +3",
        neck="War. Beads +2",
        left_ear="Thrud Earring",
        left_ear="Moonshade Earring",
        body="Pumm. Lorica +3",
        hands="Sulev. Gauntlets +2",
        left_ring="Niqmaddu Ring",
        left_ring="Regal Ring", -- if you get it later; otherwise swap to Petrov/Flamma
        back={ name="Cichol's Mantle", augments={'VIT+20','Accuracy+20 Attack+20','VIT+5','Weapon skill damage +10%',}},
        waist="Sailfi Belt +1",
        legs="Pumm. Cuisses +4",
        feet="Pumm. Calligae +4",
    }

    -- Upheaval (VIT / WSD)
    sets.WS["Upheaval"] = {
        ammo="Knobkierrie",
        head="Pummeler's Mask +3",
        neck="War. Beads +2",
        left_ear="Thrud Earring",
        left_ear="Moonshade Earring",
        body="Pumm. Lorica +3",
        hands="Sulev. Gauntlets +2",
        left_ring="Niqmaddu Ring",
        left_ring="Petrov Ring",
        back={ name="Cichol's Mantle", augments={'VIT+20','Accuracy+20 Attack+20','VIT+5','Weapon skill damage +10%',}},
        waist="Regal Belt",
        legs="Pumm. Cuisses +4",
        feet="Pumm. Calligae +4",
    }

    -- Savage Blade (MND / WSD) with Naegling
    sets.WS["Savage Blade"] = {
        ammo="Knobkierrie",
        head="Pummeler's Mask +3",
        neck="Regal Necklace",
        left_ear="Thrud Earring",
        left_ear="Moonshade Earring",
        body="Pumm. Lorica +3",
        hands="Sulev. Gauntlets +2",
        left_ring="Niqmaddu Ring",
        left_ring="Petrov Ring",
        back={ name="Cichol's Mantle", augments={'VIT+20','Accuracy+20 Attack+20','VIT+5','Weapon skill damage +10%',}},
        waist="Sailfi Belt +1",
        legs="Pumm. Cuisses +4",
        feet="Pumm. Calligae +4",
    }

    -- Impulse Drive (DEX / WSD) with Shining One
    sets.WS["Impulse Drive"] = {
        ammo="Knobkierrie",
        head="Flam. Zucchetto +2",
        neck="Shulmanu Collar",
        left_ear="Cessance Earring",
        left_ear="Moonshade Earring",
        body="Flamma Korazin +2",
        hands="Flam. Manopolas +2",
        left_ring="Niqmaddu Ring",
        left_ring="Flamma Ring",
        back={ name="Cichol's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10','Phys. dmg. taken-10%',}},
        waist="Sailfi Belt +1",
        legs="Flamma Dirs +2",
        feet="Flam. Gambieras +2",
    }

    -- Fell Cleave / Steel Cyclone / other STR WS
    sets.WS["Steel Cyclone"] = sets.WS.Generic
    sets.WS["Fell Cleave"]   = sets.WS.Generic

    ----------------------------------------------------------------------------------------------------------------
    -- TP / Engaged sets
    -- (Normal, Acc, Hybrid; weapon-agnostic, weapon chosen by WeaponMode)
    ----------------------------------------------------------------------------------------------------------------

    -- Base TP (Normal)
    sets.engaged.Normal = {
        ammo="Ginsen",
        head="Flam. Zucchetto +2",
        neck="Shulmanu Collar",
        left_ear="Cessance Earring",
        left_ear="Brutal Earring",
        body="Flamma Korazin +2",
        hands="Flam. Manopolas +2",
        left_ring="Niqmaddu Ring",
        left_ring="Petrov Ring",
        back={ name="Cichol's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10','Phys. dmg. taken-10%',}},
        waist="Sailfi Belt +1",
        legs="Pumm. Cuisses +4",
        feet="Flam. Gambieras +2",
    }

    -- High Accuracy TP
    sets.engaged.Acc = {
        ammo="Ginsen",
        head="Pummeler's Mask +3",
        neck="Shulmanu Collar",
        left_ear="Cessance Earring",
        left_ear="Digni. Earring",
        body="Pumm. Lorica +3",
        hands="Sulev. Gauntlets +2",
        left_ring="Niqmaddu Ring",
        left_ring="Ayanmo Ring",
        back={ name="Cichol's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10','Phys. dmg. taken-10%',}},
        waist="Eschan Stone",
        legs="Pumm. Cuisses +4",
        feet="Pumm. Calligae +4",
    }

    -- Hybrid TP (some DT)
    sets.engaged.Hybrid = {
        ammo="Ginsen",
        head="Genmei Kabuto",
        neck="Loricate Torque",
        left_ear="Cessance Earring",
        left_ear="Cryptic Earring",
        body="Malignance Tabard",
        hands="Sulev. Gauntlets +2",
        left_ring="Defending Ring",
        left_ring="Niqmaddu Ring",
        back={ name="Cichol's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10','Phys. dmg. taken-10%',}},
        waist="Sailfi Belt +1",
        legs="Pumm. Cuisses +4",
        feet="Sulev. Leggings +2",
    }

    ----------------------------------------------------------------------------------------------------------------
    -- Idle sets
    ----------------------------------------------------------------------------------------------------------------

    sets.idle.Normal = {
        ammo="Staunch Tathlum +1", -- if you get it; otherwise leave ammo empty
        head="Genmei Kabuto",
        neck="Loricate Torque",
        left_ear="Cryptic Earring",
        left_ear="Evans Earring",
        body="Eschite Breast.",
        hands="Sulev. Gauntlets +2",
        left_ring="Defending Ring",
        left_ring="Warp Ring",
        back={ name="Cichol's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10','Phys. dmg. taken-10%',}},
        waist="Fucho-no-Obi",
        legs="Pumm. Cuisses +4",
        feet="Sulev. Leggings +2",
    }

    sets.idle.DT = {
        ammo="Staunch Tathlum +1",
        head="Genmei Kabuto",
        neck="Loricate Torque",
        left_ear="Cryptic Earring",
        left_ear="Kasuga Earring",
        body="Malignance Tabard",
        hands="Sulev. Gauntlets +2",
        left_ring="Defending Ring",
        left_ring="Gelatinous Ring +1", -- if you get it later
        back={ name="Cichol's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10','Phys. dmg. taken-10%',}},
        waist="Flume Belt +1", -- if you get it later
        legs="Pumm. Cuisses +4",
        feet="Sulev. Leggings +2",
    }

    sets.idle.Regen = set_combine(sets.idle.Normal, {
        body="Reiki Osode",
        hands="Crusher Gauntlets",
    })

    -- Movement: prioritize Shneddick Ring over movement legs
    sets.idle.Movement = set_combine(sets.idle.Normal, {
        left_ring="Shneddick Ring",
        legs="Pumm. Cuisses +4", -- keep strong legs; you also own Blitzer Poleyn but ring is priority
    })

    ----------------------------------------------------------------------------------------------------------------
    -- Weapon-specific overrides (if you want to tweak later)
    ----------------------------------------------------------------------------------------------------------------
    sets.engaged.Chango     = sets.engaged.Normal
    sets.engaged.Naegling   = sets.engaged.Normal
    sets.engaged.ShiningOne = sets.engaged.Normal
    sets.engaged.Axe        = sets.engaged.Normal
    sets.engaged.GreatSword = sets.engaged.Normal
    sets.engaged.Club       = sets.engaged.Normal
    sets.engaged.Polearm    = sets.engaged.Normal
    sets.engaged.Other      = sets.engaged.Normal

    ----------------------------------------------------------------------------------------------------------------
    -- Done
    ----------------------------------------------------------------------------------------------------------------
end

-------------------------------------------------------------------------------------------------------------------
-- Utility: weapon detection
-------------------------------------------------------------------------------------------------------------------

function update_weapon_mode()
    local main = player.equipment.main or ''

    if main == "Chango" then
        state.WeaponMode.current = 'Chango'
    elseif main == "Naegling" then
        state.WeaponMode.current = 'Naegling'
    elseif main == "Shining One" then
        state.WeaponMode.current = 'ShiningOne'
    elseif main == "Kaja Chopper" or main == "Deacon Blade" or main == "Umaru" or main == "Iapetus" then
        state.WeaponMode.current = 'Axe'
    elseif main == "Bidenhander" or main == "Sowilo Claymore" or main == "Chaosbringer" then
        state.WeaponMode.current = 'GreatSword'
    elseif main == "Loxotic Mace +1" or main == "Daybreak" then
        state.WeaponMode.current = 'Club'
    elseif main == "Shining One" or main == "Yoshihiro" then
        state.WeaponMode.current = 'Polearm'
    else
        state.WeaponMode.current = 'Other'
    end

    current_weapon = state.WeaponMode.current
end

-------------------------------------------------------------------------------------------------------------------
-- Standard GearSwap hooks
-------------------------------------------------------------------------------------------------------------------

function precast(spell)
    if spell.action_type == 'Magic' then
        equip(sets.precast.FC)
    elseif spell.type == 'WeaponSkill' then
        local ws = spell.english
        if sets.WS[ws] then
            equip(sets.WS[ws])
        else
            equip(sets.WS.Generic)
        end
    elseif spell.type == 'JobAbility' then
        if sets.JA[spell.english] then
            equip(sets.JA[spell.english])
        end
    end
end

function midcast(spell)
    -- WAR has almost no midcast needs; leave empty for now
end

function aftercast(spell)
    handle_status_change(player.status)
end

function status_change(new, old)
    last_status = new
    handle_status_change(new)
end

function handle_status_change(status)
    update_weapon_mode()

    if status == 'Engaged' then
        local off = state.OffenseMode.current
        local base_set = sets.engaged[off] or sets.engaged.Normal

        local weapon_set = sets.engaged[current_weapon] or {}
        equip(set_combine(base_set, weapon_set))

    else
        local idle = state.IdleMode.current
        equip(sets.idle[idle] or sets.idle.Normal)
    end
end

function self_command(cmd)
    local args = {}
    for word in cmd:gmatch("%S+") do
        table.insert(args, word)
    end

    if args[1] == 'cycle' then
        if args[2] == 'OffenseMode' then
            cycle_mode(state.OffenseMode)
            add_to_chat(122, 'OffenseMode: '..state.OffenseMode.current)
            handle_status_change(player.status)
        elseif args[2] == 'IdleMode' then
            cycle_mode(state.IdleMode)
            add_to_chat(122, 'IdleMode: '..state.IdleMode.current)
            handle_status_change(player.status)
        end
    end
end

function cycle_mode(mode)
    local idx = 1
    for i,v in ipairs(mode.index) do
        if v == mode.current then
            idx = i
            break
        end
    end
    idx = idx + 1
    if idx > #mode.index then idx = 1 end
    mode.current = mode.index[idx]
end

-------------------------------------------------------------------------------------------------------------------
-- Auto items for status ailments
-------------------------------------------------------------------------------------------------------------------

local last_item_use = {}
local item_cooldown = 8 -- seconds between auto-uses per ailment

local status_items = {
    ['Poison']   = 'Antidote',
    ['Paralysis']= 'Remedy',
    ['Blindness']= 'Eye Drops',
    ['Silence']  = 'Echo Drops',
    ['Curse']    = 'Holy Water',
    ['Doom']     = 'Hallowed Water',
    ['Disease']  = 'Remedy',
}

function buff_change(name, gain, buff_details)
    name = string.gsub(name, '^%l', string.upper) -- normalize first letter

    -- Auto-item logic
    if gain and status_items[name] then
        local now = os.time()
        if not last_item_use[name] or (now - last_item_use[name]) > item_cooldown then
            local item = status_items[name]
            windower.send_command('input /item "'..item..'" <me>')
            last_item_use[name] = now
            add_to_chat(123, 'Auto-Item: '..item..' for '..name)
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Auto 180° turn for petrify TP moves
-------------------------------------------------------------------------------------------------------------------

-- List of common petrify TP moves (you can add more as you encounter them)
local petrify_moves = {
    [1] = "Breakga",
    [2] = "Break",
    [3] = "Petrifying Breath",
    [4] = "Petrifaction",
    [5] = "Stone Breath",
}

local petrify_lookup = {}
for _,name in pairs(petrify_moves) do
    petrify_lookup[name] = true
end

windower.register_event('action', function(act)
    -- act.category 7/8 are usually TP moves/spells; we just check for any action with a known name
    if not act.targets then return end

    for _, target in ipairs(act.targets) do
        if target.id == player.id then
            -- This action is targeting us; find the name
            local param = act.param
            if param and type(param) == 'number' then
                local res = res and res.monster_abilities and res.monster_abilities[param]
                if res and petrify_lookup[res.en] then
                    windower.send_command('input /turnaround')
                    add_to_chat(123, 'Auto-turn: avoiding petrify move ('..res.en..')')
                end
            end
        end
    end
end)

-------------------------------------------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------------------------------------------

function file_unload()
    -- nothing special
end

function job_setup()
    -- nothing special
end

function user_setup()
    update_weapon_mode()
    handle_status_change(player.status)
end
