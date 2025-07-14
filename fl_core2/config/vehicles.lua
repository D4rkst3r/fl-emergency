Config.Vehicles = {}

-- ================================
-- 🚒 FEUERWEHR-FAHRZEUGE
-- ================================

Config.Vehicles.fire = {
    -- Leichte Fahrzeuge
    light = {
        ['fire_command'] = {
            label = 'ELW 1 (Kommandowagen)',
            model = 'firetruk', -- Standard GTA Model oder Custom
            price = 0,          -- Kostenlos für Dienst
            category = 'light',
            seats = 4,
            requiredGrade = 0,

            -- Ausstattung
            equipment = {
                water = 500, -- Liter
                foam = 200,
                tools = { 'radio', 'megaphone', 'command_tablet' }
            },

            -- Livery & Design
            livery = 1,                                  -- Standard-Feuerwehr-Design
            colors = { primary = 111, secondary = 111 }, -- Rot

            -- Performance
            handling = {
                acceleration = 0.8,
                braking = 1.2,
                speed = 0.9
            },

            -- Features
            features = {
                siren = true,
                lights = true,
                horn = 'fire_horn',
                extras = { 1, 2, 3 } -- Zusätzliche Ausrüstung
            }
        },

        ['fire_rescue'] = {
            label = 'RW 1 (Rüstwagen)',
            model = 'firetruk2',
            price = 0,
            category = 'light',
            seats = 6,
            requiredGrade = 1,

            equipment = {
                water = 800,
                foam = 300,
                tools = { 'jaws_of_life', 'hydraulic_cutter', 'airbags', 'generator' }
            },

            livery = 2,
            colors = { primary = 111, secondary = 0 },

            handling = {
                acceleration = 0.7,
                braking = 1.3,
                speed = 0.8
            },

            features = {
                siren = true,
                lights = true,
                horn = 'fire_horn',
                extras = { 1, 2, 3, 4, 5 }
            }
        }
    },

    -- Schwere Fahrzeuge
    heavy = {
        ['fire_engine'] = {
            label = 'LF 20 (Löschfahrzeug)',
            model = 'firetruk3',
            price = 0,
            category = 'heavy',
            seats = 8,
            requiredGrade = 2,

            equipment = {
                water = 2000, -- Großer Wassertank
                foam = 500,
                tools = { 'fire_hose', 'ladder_30m', 'breathing_apparatus', 'thermal_camera' }
            },

            livery = 3,
            colors = { primary = 111, secondary = 111 },

            handling = {
                acceleration = 0.5,
                braking = 1.5,
                speed = 0.7
            },

            features = {
                siren = true,
                lights = true,
                horn = 'fire_horn_heavy',
                extras = { 1, 2, 3, 4, 5, 6 },
                waterCannon = true -- Wasserwerfer
            }
        },

        ['fire_tanker'] = {
            label = 'TLF 3000 (Tanklöschfahrzeug)',
            model = 'firetruk4',
            price = 0,
            category = 'heavy',
            seats = 4,
            requiredGrade = 3,

            equipment = {
                water = 3000, -- Sehr großer Wassertank
                foam = 800,
                tools = { 'fire_hose_heavy', 'foam_cannon', 'water_pump' }
            },

            livery = 4,
            colors = { primary = 111, secondary = 3 },

            handling = {
                acceleration = 0.4,
                braking = 1.7,
                speed = 0.6
            },

            features = {
                siren = true,
                lights = true,
                horn = 'fire_horn_heavy',
                extras = { 1, 2, 3, 4 },
                waterCannon = true,
                foamCannon = true
            }
        }
    },

    -- Spezialfahrzeuge
    special = {
        ['fire_ladder'] = {
            label = 'DLK 30 (Drehleiter)',
            model = 'fireladder',
            price = 0,
            category = 'special',
            seats = 3,
            requiredGrade = 4,

            equipment = {
                water = 1000,
                tools = { 'ladder_30m', 'rescue_basket', 'cutting_tools' }
            },

            livery = 5,
            colors = { primary = 111, secondary = 0 },

            handling = {
                acceleration = 0.3,
                braking = 1.8,
                speed = 0.5
            },

            features = {
                siren = true,
                lights = true,
                horn = 'fire_horn_heavy',
                extras = { 1, 2, 3 },
                ladder = true, -- Ausfahrbare Leiter
                stabilizers = true
            }
        },

        ['fire_hazmat'] = {
            label = 'GW-G (Gefahrgut)',
            model = 'firehazmat',
            price = 0,
            category = 'special',
            seats = 4,
            requiredGrade = 5,

            equipment = {
                foam = 1000,
                tools = { 'hazmat_suits', 'chemical_detector', 'decontamination_unit' }
            },

            livery = 6,
            colors = { primary = 111, secondary = 89 }, -- Gelb für Gefahrgut

            features = {
                siren = true,
                lights = true,
                horn = 'fire_horn',
                extras = { 1, 2, 3, 4 },
                chemicalDetector = true
            }
        }
    }
}

-- ================================
-- 🚓 POLIZEI-FAHRZEUGE
-- ================================

Config.Vehicles.police = {
    -- Streifenwagen
    patrol = {
        ['police_patrol1'] = {
            label = 'Streifenwagen (Ford)',
            model = 'police',
            price = 0,
            category = 'patrol',
            seats = 4,
            requiredGrade = 0,

            equipment = {
                fuel = 100,
                tools = { 'laptop', 'radar_gun', 'breathalyzer', 'radio' }
            },

            livery = 1,
            colors = { primary = 111, secondary = 0 }, -- Weiß/Blau

            handling = {
                acceleration = 1.0,
                braking = 1.1,
                speed = 1.0
            },

            features = {
                siren = true,
                lights = true,
                horn = 'police_horn',
                extras = { 1, 2, 3 },
                pushBumper = true,
                partition = true -- Trennwand
            }
        },

        ['police_patrol2'] = {
            label = 'Streifenwagen (Dodge)',
            model = 'police2',
            price = 0,
            category = 'patrol',
            seats = 4,
            requiredGrade = 1,

            equipment = {
                fuel = 100,
                tools = { 'laptop', 'radar_gun', 'breathalyzer', 'radio', 'spike_strips' }
            },

            livery = 2,
            colors = { primary = 0, secondary = 111 },

            handling = {
                acceleration = 1.1,
                braking = 1.2,
                speed = 1.1
            },

            features = {
                siren = true,
                lights = true,
                horn = 'police_horn',
                extras = { 1, 2, 3, 4 },
                pushBumper = true,
                partition = true,
                anpr = true -- Kennzeichenerkennung
            }
        },

        ['police_bike'] = {
            label = 'Polizei-Motorrad',
            model = 'policeb',
            price = 0,
            category = 'patrol',
            seats = 2,
            requiredGrade = 2,

            equipment = {
                fuel = 50,
                tools = { 'radio', 'breathalyzer' }
            },

            livery = 1,
            colors = { primary = 0, secondary = 111 },

            handling = {
                acceleration = 1.3,
                braking = 0.9,
                speed = 1.4
            },

            features = {
                siren = true,
                lights = true,
                horn = 'police_horn_bike'
            }
        }
    },

    -- Zivilfahrzeuge
    unmarked = {
        ['police_undercover1'] = {
            label = 'Zivil-Sedan',
            model = 'police4',
            price = 0,
            category = 'unmarked',
            seats = 4,
            requiredGrade = 3,

            equipment = {
                fuel = 100,
                tools = { 'laptop', 'surveillance_kit', 'radio' }
            },

            livery = 0,                                -- Kein Police-Look
            colors = { primary = 12, secondary = 12 }, -- Schwarz

            handling = {
                acceleration = 1.0,
                braking = 1.0,
                speed = 1.0
            },

            features = {
                siren = true,
                lights = true, -- Versteckte Blaulichter
                horn = 'normal_horn',
                hidden = true  -- Versteckte Polizei-Features
            }
        },

        ['police_undercover2'] = {
            label = 'Zivil-SUV',
            model = 'fbi2',
            price = 0,
            category = 'unmarked',
            seats = 4,
            requiredGrade = 4,

            equipment = {
                fuel = 120,
                tools = { 'laptop', 'surveillance_kit', 'radio', 'tracking_device' }
            },

            livery = 0,
            colors = { primary = 1, secondary = 1 }, -- Dunkelgrau

            features = {
                siren = true,
                lights = true,
                horn = 'normal_horn',
                hidden = true,
                armored = true -- Gepanzert
            }
        }
    },

    -- Spezialfahrzeuge
    special = {
        ['police_swat'] = {
            label = 'SEK-Fahrzeug',
            model = 'riot',
            price = 0,
            category = 'special',
            seats = 8,
            requiredGrade = 6,

            equipment = {
                fuel = 150,
                tools = { 'tactical_laptop', 'breaching_charges', 'tactical_gear' }
            },

            livery = 1,
            colors = { primary = 12, secondary = 12 },

            handling = {
                acceleration = 0.8,
                braking = 1.4,
                speed = 0.9
            },

            features = {
                siren = true,
                lights = true,
                horn = 'swat_horn',
                extras = { 1, 2, 3, 4, 5 },
                armored = true,
                ramming = true -- Verstärkter Rammbock
            }
        },

        ['police_helicopter'] = {
            label = 'Polizei-Hubschrauber',
            model = 'polmav',
            price = 0,
            category = 'special',
            seats = 4,
            requiredGrade = 7,

            equipment = {
                fuel = 200,
                tools = { 'thermal_camera', 'spotlight', 'winch', 'megaphone' }
            },

            livery = 1,
            colors = { primary = 0, secondary = 111 },

            features = {
                siren = false,
                lights = true,
                searchlight = true,
                thermalCamera = true,
                rappelling = true
            }
        }
    }
}

-- ================================
-- 🚑 RETTUNGSDIENST-FAHRZEUGE
-- ================================

Config.Vehicles.ems = {
    -- Rettungswagen
    ambulance = {
        ['ems_ambulance1'] = {
            label = 'RTW 1 (Rettungswagen)',
            model = 'ambulance',
            price = 0,
            category = 'ambulance',
            seats = 4,
            requiredGrade = 0,

            equipment = {
                fuel = 100,
                medical = 100, -- Medizinische Vorräte
                tools = { 'defibrillator', 'stretcher', 'oxygen_tank', 'medical_bag' }
            },

            livery = 1,
            colors = { primary = 111, secondary = 4 }, -- Weiß/Gelb

            handling = {
                acceleration = 0.9,
                braking = 1.1,
                speed = 0.95
            },

            features = {
                siren = true,
                lights = true,
                horn = 'ambulance_horn',
                extras = { 1, 2, 3 },
                medicalBay = true, -- Behandlungsraum hinten
                stretcher = true
            }
        },

        ['ems_ambulance2'] = {
            label = 'RTW 2 (Intensiv)',
            model = 'ambulance2',
            price = 0,
            category = 'ambulance',
            seats = 4,
            requiredGrade = 2,

            equipment = {
                fuel = 100,
                medical = 150,
                tools = { 'advanced_defibrillator', 'ventilator', 'stretcher', 'iv_stand', 'cardiac_monitor' }
            },

            livery = 2,
            colors = { primary = 111, secondary = 4 },

            handling = {
                acceleration = 0.8,
                braking = 1.2,
                speed = 0.9
            },

            features = {
                siren = true,
                lights = true,
                horn = 'ambulance_horn',
                extras = { 1, 2, 3, 4 },
                medicalBay = true,
                stretcher = true,
                intensiveCare = true
            }
        },

        ['ems_rapid_response'] = {
            label = 'NEF (Notarzteinsatzfahrzeug)',
            model = 'ambulance3',
            price = 0,
            category = 'ambulance',
            seats = 2,
            requiredGrade = 4,

            equipment = {
                fuel = 80,
                medical = 200,
                tools = { 'advanced_medical_kit', 'portable_defibrillator', 'intubation_kit' }
            },

            livery = 3,
            colors = { primary = 111, secondary = 27 }, -- Weiß/Rot

            handling = {
                acceleration = 1.2,
                braking = 1.0,
                speed = 1.1
            },

            features = {
                siren = true,
                lights = true,
                horn = 'ambulance_horn_fast',
                rapidResponse = true,
                emergencyDoctor = true
            }
        }
    },

    -- Rettungshubschrauber
    helicopter = {
        ['ems_helicopter'] = {
            label = 'RTH (Rettungshubschrauber)',
            model = 'ambulanceheli',
            price = 0,
            category = 'helicopter',
            seats = 6,
            requiredGrade = 5,

            equipment = {
                fuel = 300,
                medical = 100,
                tools = { 'winch', 'stretcher', 'advanced_medical_kit', 'gps_rescue' }
            },

            livery = 1,
            colors = { primary = 111, secondary = 27 },

            features = {
                siren = false,
                lights = true,
                searchlight = true,
                winch = true,
                longRange = true,
                weatherRadar = true
            }
        }
    },

    -- Unterstützungsfahrzeuge
    support = {
        ['ems_command'] = {
            label = 'ELW-SAN (Einsatzleitwagen)',
            model = 'ambulance_command',
            price = 0,
            category = 'support',
            seats = 6,
            requiredGrade = 6,

            equipment = {
                fuel = 120,
                tools = { 'command_center', 'communication_array', 'medical_supplies' }
            },

            livery = 4,
            colors = { primary = 111, secondary = 4 },

            features = {
                siren = true,
                lights = true,
                horn = 'ambulance_horn',
                commandCenter = true,
                communicationHub = true
            }
        }
    }
}

-- ================================
-- 🔧 FAHRZEUG-SYSTEM EINSTELLUNGEN
-- ================================

Config.VehicleSettings = {
    -- Spawn-Verhalten
    spawn = {
        checkRadius = 5.0, -- Meter um Spawn-Point prüfen
        maxAttempts = 3,
        deleteOnFail = false,
        notifyPlayer = true
    },

    -- Kraftstoff-System
    fuel = {
        enabled = true,
        consumptionRate = 1.0, -- Verbrauchsrate
        refuelAtStation = true,
        refuelLocations = {
            { coords = vector3(49.4, -1761.5, 29.6),   price = 2.5 },
            { coords = vector3(263.9, -1261.3, 29.3),  price = 2.5 },
            { coords = vector3(1208.9, -1402.6, 35.2), price = 2.5 }
        }
    },

    -- Schäden & Reparatur
    damage = {
        realistic = true,
        disableOnDuty = false, -- Fahrzeuge im Dienst sind nicht unverwüstlich
        autoRepair = false,
        repairCost = 500
    },

    -- Sicherheit
    security = {
        lockOnSpawn = true,
        onlyOwnerCanEnter = true,
        allowPassengers = true,
        autoLockOnExit = true
    },

    -- Performance
    performance = {
        maxVehiclesPerPlayer = 2,
        despawnOnDutyEnd = true,
        cleanupInterval = 600000, -- 10 Minuten
        maxIdleTime = 1800000     -- 30 Minuten ohne Spieler
    },

    -- Extras & Modifikationen
    modifications = {
        allowTuning = false,  -- Keine Tuning-Shops für Dienstfahrzeuge
        enforceStock = true,  -- Standard-Performance beibehalten
        allowLiveries = true, -- Lackierungen erlaubt
        allowExtras = true
    }
}

-- ================================
-- 🎨 FAHRZEUG-KATEGORIEN UI
-- ================================

Config.VehicleUI = {
    -- Kategorien für Spawn-Menü
    categories = {
        fire = {
            light = { icon = 'fa-solid fa-car', color = '#e74c3c' },
            heavy = { icon = 'fa-solid fa-truck', color = '#c0392b' },
            special = { icon = 'fa-solid fa-helicopter', color = '#922b21' }
        },
        police = {
            patrol = { icon = 'fa-solid fa-car-side', color = '#3498db' },
            unmarked = { icon = 'fa-solid fa-user-secret', color = '#2980b9' },
            special = { icon = 'fa-solid fa-shield', color = '#1f4e79' }
        },
        ems = {
            ambulance = { icon = 'fa-solid fa-ambulance', color = '#2ecc71' },
            helicopter = { icon = 'fa-solid fa-helicopter', color = '#27ae60' },
            support = { icon = 'fa-solid fa-truck-medical', color = '#1e8449' }
        }
    },

    -- Fahrzeug-Info Display
    infoDisplay = {
        showStats = true,
        showEquipment = true,
        showRequirements = true,
        previewImage = true
    }
}
