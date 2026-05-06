function get_sets()
    sets.TP = {
        ammo = "Ginsen",
        head = "Flam. Zucchetto +2",
        body = "Pumm. Lorica +3",
        hands = "Pumm. Mufflers +3",
        legs = "Pumm. Cuisses +4",
        feet = "Pumm. Calligae +4",
        neck = "War. Beads +2",
        waist = { name = "Sailfi Belt +1", augments = { 'Path: A', } },
        left_ear = "Cessance Earring",
        right_ear = "Brutal Earring",
        left_ring = "Niqmaddu Ring",
        right_ring = "Petrov Ring",
        back = {
            name = "Cichol's Mantle",
            augments = {
                'DEX+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10', 'Phys. dmg. taken-10%',
            }
        },
    }

    sets.WS = {
        ammo = "Knobkierrie",
        head = "Pummeler's Mask +3",
        body = "Pumm. Lorica +3",
        hands = "Pumm. Mufflers +3",
        legs = "Pumm. Cuisses +4",
        feet = "Pumm. Calligae +4",
        neck = "War. Beads +2",
        waist = { name = "Sailfi Belt +1", augments = { 'Path: A', } },
        left_ear = "Thrud Earring",
        right_ear = { name = "Moonshade Earring", augments = { 'Accuracy+4', 'TP Bonus +250', } },
        left_ring = "Niqmaddu Ring",
        right_ring = "Petrov Ring",
        back = {
            name = "Cichol's Mantle",
            augments = {
                'VIT+20', 'Accuracy+20 Attack+20', 'VIT+5', 'Weapon skill damage +10%',
            }
        },
    }

    sets.idle = {
        head = "Sulevia's Mask +2",
        body = "Sulevia's Plate. +2",
        hands = "Sulev. Gauntlets +2",
        legs = "Sulev. Cuisses +2",
        feet = "Sulev. Leggings +2",
        neck = "Loricate Torque",
        waist = "Null Belt",
        left_ear = "Brutal Earring",
        right_ear = "Cessance Earring",
        left_ring = "Murky Ring",
        right_ring = "Shneddick Ring",
        back = {
            name = "Cichol's Mantle",
            augments = {
                'DEX+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10', 'Phys. dmg. taken-10%',
            }
        },
    }
end

function precast(spell)
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
