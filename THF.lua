function get_sets()
    sets.TP = {
        ammo = "Ginsen",
        head = "Mummu Bonnet +2",
        body = "Mummu Jacket +2",
        hands = "Mummu Wrists +2",
        legs = "Mummu Kecks +2",
        feet = "Mummu Gamash. +2",
        neck = "Anu Torque",
        waist = { name = "Sailfi Belt +1", augments = { 'Path: A', } },
        left_ear = "Cessance Earring",
        right_ear = "Brutal Earring",
        left_ring = "Niqmaddu Ring",
        right_ring = "Petrov Ring",
        back = {
            name = "Toutatis's Cape",
            -- You own this cape but no augments listed, so left clean
        },
    }

    sets.WS = {
        ammo = "Knobkierrie",
        head = "Mummu Bonnet +2",
        body = "Mummu Jacket +2",
        hands = "Mummu Wrists +2",
        legs = "Mummu Kecks +2",
        feet = "Mummu Gamash. +2",
        neck = "Regal Necklace",
        waist = { name = "Sailfi Belt +1", augments = { 'Path: A', } },
        left_ear = "Thrud Earring",
        right_ear = { name = "Moonshade Earring", augments = { 'Accuracy+4', 'TP Bonus +250', } },
        left_ring = "Niqmaddu Ring",
        right_ring = "Begrudging Ring",
        back = {
            name = "Toutatis's Cape",
        },
    }

    sets.idle = {
        head = "Malignance Chapeau",
        body = "Malignance Tabard",
        hands = "Meg. Gloves +2",
        legs = "Meg. Chausses +2",
        feet = "Meg. Jam. +2",
        neck = "Loricate Torque",
        waist = "Null Belt",
        left_ear = "Brutal Earring",
        right_ear = "Cessance Earring",
        left_ring = "Defending Ring",
        right_ring = "Shneddick Ring",
        back = "Shadow Mantle",
    }

    sets.JA = {}

    sets.JA.SneakAttack = { hands = "Meg. Gloves +2" }
    sets.JA.TrickAttack = { hands = "Meg. Gloves +2" }
    sets.JA.Flee = {}
    sets.JA.Hide = {}
    sets.JA.Accomplice = {}
    sets.JA.Collaborator = {}
    sets.JA.Bully = {}
end

function precast(spell)
    if spell.type == "JobAbility" and sets.JA[spell.english] then
        equip(sets.JA[spell.english])
        return
    end
    if spell.type == "WeaponSkill" then
        equip(sets.WS)
    end
end

function aftercast(spell)
    if player.status == "Engaged" then
        equip(sets.TP)
    else
        equip(sets.idle)
    end
end

function status_change(new, old)
    if new == "Engaged" then
        equip(sets.TP)
    elseif new == "Idle" then
        equip(sets.idle)
    end
end
