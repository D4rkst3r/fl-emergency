Config.Services = {}

-- ================================
-- 🚒 FEUERWEHR (FIRE DEPARTMENT)
-- ================================

Config.Services.fire = {
    -- Basis-Informationen
    label = 'Feuerwehr',
    job = 'fire', -- QBCore Job-Name
    color = '#e74c3c',
    icon = 'fa-solid fa-fire',
    shortName = 'FW',

    -- Berechtigungen & Ränge
    ranks = {
        [0] = { name = 'Feuerwehrmann-Anwärter', payment = 50 },
        [1] = { name = 'Feuerwehrmann', payment = 75 },
        [2] = { name = 'Oberfeuerwehrmann', payment = 100 },
        [3] = { name = 'Hauptfeuerwehrmann', payment = 125 },
        [4] = { name = 'Brandmeister', payment = 150 },
        [5] = { name = 'Oberbrandmeister', payment = 175 },
        [6] = { name = 'Hauptbrandmeister', payment = 200 },
        [7] = { name = 'Brandamtmann', payment = 250 },
        [8] = { name = 'Branddirektor', payment = 300 }
    },

    -- EUP-Uniformen (automatisch beim Dienstbeginn)
    uniforms = {
        male = {
            [0] = {                                         -- Basis-Uniform
                components = {
                    [11] = { drawable = 314, texture = 0 }, -- Oberteil
                    [4] = { drawable = 134, texture = 0 },  -- Hose
                    [6] = { drawable = 25, texture = 0 },   -- Schuhe
                    [8] = { drawable = 15, texture = 0 },   -- Unterhemd
                    [3] = { drawable = 4, texture = 0 }     -- Handschuhe/Arme
                },
                props = {
                    [0] = { drawable = 137, texture = 0 }, -- Helm
                }
            },
            [1] = { -- Atemschutz-Uniform
                components = {
                    [11] = { drawable = 315, texture = 0 },
                    [4] = { drawable = 134, texture = 0 },
                    [6] = { drawable = 25, texture = 0 },
                    [8] = { drawable = 15, texture = 0 },
                    [3] = { drawable = 4, texture = 0 }
                },
                props = {
                    [0] = { drawable = 138, texture = 0 }, -- Atemschutz-Helm
                }
            }
        },
        female = {
            [0] = { -- Basis-Uniform
                components = {
                    [11] = { drawable = 325, texture = 0 },
                    [4] = { drawable = 144, texture = 0 },
                    [6] = { drawable = 25, texture = 0 },
                    [8] = { drawable = 15, texture = 0 },
                    [3] = { drawable = 4, texture = 0 }
                },
                props = {
                    [0] = { drawable = 137, texture = 0 },
                }
            }
        }
    },

    -- Standard-Ausrüstung (beim Dienstbeginn)
    equipment = {
        items = {
            'fire_extinguisher',
            'fire_axe',
            'breathing_apparatus',
            'first_aid_kit',
            'radio',
            'flashlight',
            'rope',
            'crowbar'
        },
        weapons = {
            -- Feuerwehr hat normalerweise keine Waffen
        }
    },

    -- Einsatz-Typen
    callTypes = {
        ['structure_fire'] = {
            label = 'Gebäudebrand',
            priority = 1,
            requiredUnits = 2,
            equipment = { 'fire_hose', 'ladder', 'breathing_apparatus' }
        },
        ['vehicle_fire'] = {
            label = 'Fahrzeugbrand',
            priority = 2,
            requiredUnits = 1,
            equipment = { 'fire_extinguisher', 'foam' }
        },
        ['wildfire'] = {
            label = 'Waldbrand',
            priority = 1,
            requiredUnits = 3,
            equipment = { 'water_tank', 'shovel', 'breathing_apparatus' }
        },
        ['rescue'] = {
            label = 'Technische Hilfeleistung',
            priority = 2,
            requiredUnits = 1,
            equipment = { 'jaws_of_life', 'rope', 'first_aid_kit' }
        },
        ['hazmat'] = {
            label = 'Gefahrgut',
            priority = 1,
            requiredUnits = 2,
            equipment = { 'hazmat_suit', 'detector', 'decontamination' }
        }
    }
}

-- ================================
-- 🚓 POLIZEI (POLICE DEPARTMENT)
-- ================================

Config.Services.police = {
    -- Basis-Informationen
    label = 'Polizei',
    job = 'police',
    color = '#3498db',
    icon = 'fa-solid fa-shield',
    shortName = 'POL',

    -- Berechtigungen & Ränge
    ranks = {
        [0] = { name = 'Polizeimeisteranwärter', payment = 60 },
        [1] = { name = 'Polizeimeister', payment = 85 },
        [2] = { name = 'Polizeiobermeiester', payment = 110 },
        [3] = { name = 'Polizeihauptmeister', payment = 135 },
        [4] = { name = 'Polizeikommissar', payment = 160 },
        [5] = { name = 'Polizeioberkommissar', payment = 185 },
        [6] = { name = 'Polizeihauptkommissar', payment = 210 },
        [7] = { name = 'Polizeidirektor', payment = 275 },
        [8] = { name = 'Polizeipräsident', payment = 350 }
    },

    -- EUP-Uniformen
    uniforms = {
        male = {
            [0] = {                                        -- Streife
                components = {
                    [11] = { drawable = 55, texture = 0 }, -- Oberteil
                    [4] = { drawable = 25, texture = 0 },  -- Hose
                    [6] = { drawable = 25, texture = 0 },  -- Schuhe
                    [8] = { drawable = 58, texture = 0 },  -- Unterhemd
                    [3] = { drawable = 30, texture = 0 },  -- Handschuhe
                    [9] = { drawable = 15, texture = 0 }   -- Schutzweste
                },
                props = {
                    [0] = { drawable = 46, texture = 0 }, -- Polizeimütze
                    [1] = { drawable = 25, texture = 0 }  -- Sonnenbrille
                }
            },
            [1] = { -- SEK/SWAT
                components = {
                    [11] = { drawable = 53, texture = 0 },
                    [4] = { drawable = 31, texture = 0 },
                    [6] = { drawable = 25, texture = 0 },
                    [8] = { drawable = 15, texture = 0 },
                    [3] = { drawable = 4, texture = 0 },
                    [9] = { drawable = 16, texture = 0 } -- Taktische Weste
                },
                props = {
                    [0] = { drawable = 125, texture = 0 }, -- Taktischer Helm
                }
            }
        },
        female = {
            [0] = { -- Streife
                components = {
                    [11] = { drawable = 48, texture = 0 },
                    [4] = { drawable = 34, texture = 0 },
                    [6] = { drawable = 25, texture = 0 },
                    [8] = { drawable = 15, texture = 0 },
                    [3] = { drawable = 14, texture = 0 },
                    [9] = { drawable = 18, texture = 0 }
                },
                props = {
                    [0] = { drawable = 45, texture = 0 },
                }
            }
        }
    },

    -- Standard-Ausrüstung
    equipment = {
        items = {
            'handcuffs',
            'radio',
            'breathalyzer',
            'radar_gun',
            'evidence_bag',
            'notepad',
            'flashlight',
            'first_aid_kit'
        },
        weapons = {
            'weapon_nightstick',
            'weapon_pistol',
            'weapon_taser',
            'weapon_flashlight'
        }
    },

    -- Einsatz-Typen
    callTypes = {
        ['robbery'] = {
            label = 'Raub',
            priority = 1,
            requiredUnits = 2,
            equipment = { 'weapon_pistol', 'handcuffs', 'radio' }
        },
        ['traffic_stop'] = {
            label = 'Verkehrskontrolle',
            priority = 3,
            requiredUnits = 1,
            equipment = { 'breathalyzer', 'radar_gun', 'notepad' }
        },
        ['domestic_violence'] = {
            label = 'Häusliche Gewalt',
            priority = 1,
            requiredUnits = 2,
            equipment = { 'weapon_taser', 'handcuffs', 'first_aid_kit' }
        },
        ['burglary'] = {
            label = 'Einbruch',
            priority = 2,
            requiredUnits = 1,
            equipment = { 'evidence_bag', 'fingerprint_kit', 'flashlight' }
        },
        ['drug_deal'] = {
            label = 'Drogenhandel',
            priority = 2,
            requiredUnits = 2,
            equipment = { 'drug_test_kit', 'handcuffs', 'evidence_bag' }
        }
    }
}

-- ================================
-- 🚑 RETTUNGSDIENST (EMS)
-- ================================

Config.Services.ems = {
    -- Basis-Informationen
    label = 'Rettungsdienst',
    job = 'ambulance',
    color = '#2ecc71',
    icon = 'fa-solid fa-ambulance',
    shortName = 'RD',

    -- Berechtigungen & Ränge
    ranks = {
        [0] = { name = 'Rettungssanitäter-Praktikant', payment = 45 },
        [1] = { name = 'Rettungssanitäter', payment = 70 },
        [2] = { name = 'Rettungsassistent', payment = 95 },
        [3] = { name = 'Notfallsanitäter', payment = 120 },
        [4] = { name = 'Praxisanleiter', payment = 145 },
        [5] = { name = 'Wachvorsteher', payment = 170 },
        [6] = { name = 'Rettungsdienstleiter', payment = 220 },
        [7] = { name = 'Ärztlicher Leiter', payment = 300 }
    },

    -- EUP-Uniformen
    uniforms = {
        male = {
            [0] = {                                         -- Standard RTW
                components = {
                    [11] = { drawable = 250, texture = 0 }, -- RTW-Jacke
                    [4] = { drawable = 96, texture = 0 },   -- RTW-Hose
                    [6] = { drawable = 25, texture = 0 },   -- Schuhe
                    [8] = { drawable = 15, texture = 0 },   -- Unterhemd
                    [3] = { drawable = 85, texture = 0 }    -- RTW-Arme
                },
                props = {
                    [0] = { drawable = 8, texture = 0 }, -- RTW-Cap
                }
            },
            [1] = {                                         -- Notarzt
                components = {
                    [11] = { drawable = 251, texture = 0 }, -- Arzt-Kittel
                    [4] = { drawable = 96, texture = 0 },
                    [6] = { drawable = 25, texture = 0 },
                    [8] = { drawable = 15, texture = 0 },
                    [3] = { drawable = 85, texture = 0 }
                },
                props = {
                    [0] = { drawable = -1, texture = 0 }, -- Kein Helm
                }
            }
        },
        female = {
            [0] = { -- Standard RTW
                components = {
                    [11] = { drawable = 258, texture = 0 },
                    [4] = { drawable = 99, texture = 0 },
                    [6] = { drawable = 25, texture = 0 },
                    [8] = { drawable = 15, texture = 0 },
                    [3] = { drawable = 109, texture = 0 }
                },
                props = {
                    [0] = { drawable = 8, texture = 0 },
                }
            }
        }
    },

    -- Standard-Ausrüstung
    equipment = {
        items = {
            'defibrillator',
            'medical_bag',
            'stretcher',
            'oxygen_tank',
            'bandage',
            'painkillers',
            'radio',
            'flashlight',
            'iv_drip'
        },
        weapons = {
            -- Rettungsdienst hat keine Waffen
        }
    },

    -- Einsatz-Typen
    callTypes = {
        ['heart_attack'] = {
            label = 'Herzinfarkt',
            priority = 1,
            requiredUnits = 1,
            equipment = { 'defibrillator', 'oxygen_tank', 'iv_drip' }
        },
        ['car_accident'] = {
            label = 'Verkehrsunfall',
            priority = 1,
            requiredUnits = 2,
            equipment = { 'stretcher', 'medical_bag', 'bandage' }
        },
        ['overdose'] = {
            label = 'Überdosis',
            priority = 1,
            requiredUnits = 1,
            equipment = { 'naloxone', 'oxygen_tank', 'iv_drip' }
        },
        ['assault'] = {
            label = 'Körperverletzung',
            priority = 2,
            requiredUnits = 1,
            equipment = { 'bandage', 'painkillers', 'medical_bag' }
        },
        ['unconscious'] = {
            label = 'Bewusstlos',
            priority = 2,
            requiredUnits = 1,
            equipment = { 'stretcher', 'oxygen_tank', 'defibrillator' }
        }
    }
}

-- ================================
-- 🔧 SERVICE-ÜBERGREIFENDE SETTINGS
-- ================================

-- Gemeinsame Einstellungen für alle Services
Config.ServiceSettings = {
    -- Mindest-Dienstzeit in Minuten
    minDutyTime = 30,

    -- Maximum gleichzeitig aktive Spieler pro Service
    maxActivePerService = 20,

    -- Automatische Zuweisung neuer Einsätze
    autoAssignCalls = true,

    -- Cross-Service Kommunikation
    crossServiceChat = true,

    -- Gemeinsame Ausrüstung (alle Services)
    sharedEquipment = {
        'radio',
        'flashlight',
        'first_aid_kit'
    },

    -- Service-übergreifende Befehle
    commands = {
        ['backup'] = {
            description = 'Verstärkung anfordern',
            allServices = true
        },
        ['status'] = {
            description = 'Status-Update senden',
            allServices = true
        }
    }
}

-- ================================
-- 🎨 UI-FARBEN FÜR SERVICES
-- ================================

Config.ServiceColors = {
    fire = {
        primary = '#e74c3c',
        secondary = '#c0392b',
        accent = '#fff5f5'
    },
    police = {
        primary = '#3498db',
        secondary = '#2980b9',
        accent = '#f0f8ff'
    },
    ems = {
        primary = '#2ecc71',
        secondary = '#27ae60',
        accent = '#f0fff4'
    }
}
