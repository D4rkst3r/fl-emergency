Config.Stations = {}

-- ================================
-- 🚒 FEUERWEHR-WACHEN
-- ================================

Config.Stations.fire = {
    -- Hauptfeuerwache (Downtown)
    ['fire_station_1'] = {
        label = 'Feuerwache 1 - Downtown',
        coords = vector3(1193.54, -1464.17, 34.86),
        heading = 0.0,

        -- Einstempel-Punkt (ox_target)
        dutyPoint = {
            coords = vector3(1193.54, -1464.17, 34.86),
            size = vector3(2.0, 2.0, 2.0),
            rotation = 45.0,
            icon = 'fa-solid fa-clock',
            label = 'Dienst beginnen/beenden'
        },

        -- Fahrzeug-Spawns
        vehicles = {
            {
                coords = vector3(1200.0, -1470.0, 34.7),
                heading = 180.0,
                category = 'light'
            },
            {
                coords = vector3(1205.0, -1470.0, 34.7),
                heading = 180.0,
                category = 'heavy'
            },
            {
                coords = vector3(1210.0, -1470.0, 34.7),
                heading = 180.0,
                category = 'special'
            }
        },

        -- Equipment-Zugang
        equipment = {
            coords = vector3(1190.0, -1460.0, 34.86),
            size = vector3(1.5, 1.5, 2.0),
            icon = 'fa-solid fa-toolbox',
            label = 'Ausrüstung'
        },

        -- Umkleide/Uniform
        wardrobe = {
            coords = vector3(1188.0, -1462.0, 34.86),
            size = vector3(1.5, 1.5, 2.0),
            icon = 'fa-solid fa-shirt',
            label = 'Umkleidekabine'
        },

        -- Bereitschaftsraum
        briefingRoom = {
            coords = vector3(1195.0, -1455.0, 34.86),
            size = vector3(3.0, 3.0, 2.0),
            icon = 'fa-solid fa-users',
            label = 'Bereitschaftsraum'
        },

        -- Garage-Tor (automatisch)
        garageDoor = {
            coords = vector3(1207.5, -1474.0, 34.7),
            heading = 180.0,
            model = 'prop_gate_airport_01'
        }
    },

    -- Feuerwache Nord
    ['fire_station_2'] = {
        label = 'Feuerwache 2 - Nord',
        coords = vector3(-379.58, 6118.44, 31.85),
        heading = 45.0,

        dutyPoint = {
            coords = vector3(-379.58, 6118.44, 31.85),
            size = vector3(2.0, 2.0, 2.0),
            rotation = 45.0,
            icon = 'fa-solid fa-clock',
            label = 'Dienst beginnen/beenden'
        },

        vehicles = {
            {
                coords = vector3(-385.0, 6115.0, 31.5),
                heading = 135.0,
                category = 'light'
            },
            {
                coords = vector3(-390.0, 6110.0, 31.5),
                heading = 135.0,
                category = 'heavy'
            }
        },

        equipment = {
            coords = vector3(-375.0, 6122.0, 31.85),
            size = vector3(1.5, 1.5, 2.0),
            icon = 'fa-solid fa-toolbox',
            label = 'Ausrüstung'
        },

        wardrobe = {
            coords = vector3(-377.0, 6120.0, 31.85),
            size = vector3(1.5, 1.5, 2.0),
            icon = 'fa-solid fa-shirt',
            label = 'Umkleidekabine'
        }
    }
}

-- ================================
-- 🚓 POLIZEI-WACHEN
-- ================================

Config.Stations.police = {
    -- Mission Row Police Station (Hauptwache)
    ['police_station_1'] = {
        label = 'Mission Row Police Station',
        coords = vector3(441.7, -982.0, 30.67),
        heading = 0.0,

        dutyPoint = {
            coords = vector3(441.7, -982.0, 30.67),
            size = vector3(2.0, 2.0, 2.0),
            rotation = 0.0,
            icon = 'fa-solid fa-shield',
            label = 'Dienst beginnen/beenden'
        },

        -- Fahrzeug-Spawns (verschiedene Bereiche)
        vehicles = {
            -- Streifenwagen
            {
                coords = vector3(438.4, -1018.3, 27.7),
                heading = 90.0,
                category = 'patrol'
            },
            {
                coords = vector3(441.0, -1024.2, 28.3),
                heading = 90.0,
                category = 'patrol'
            },
            -- Zivilfahrzeuge
            {
                coords = vector3(445.0, -1019.5, 28.4),
                heading = 90.0,
                category = 'unmarked'
            },
            -- Spezialfahrzeuge
            {
                coords = vector3(449.0, -1025.0, 28.5),
                heading = 90.0,
                category = 'special'
            }
        },

        -- Waffenkammer
        armory = {
            coords = vector3(453.08, -982.28, 30.68),
            size = vector3(2.0, 1.0, 2.0),
            icon = 'fa-solid fa-gun',
            label = 'Waffenkammer',
            requiredGrade = 2 -- Ab Rang 2
        },

        -- Evidence Locker
        evidence = {
            coords = vector3(475.9, -996.4, 30.7),
            size = vector3(1.5, 1.5, 2.0),
            icon = 'fa-solid fa-box',
            label = 'Asservatenkammer'
        },

        -- Verhörräume
        interrogation = {
            {
                coords = vector3(461.65, -994.0, 30.7),
                size = vector3(2.0, 2.0, 2.0),
                icon = 'fa-solid fa-comments',
                label = 'Verhörraum 1'
            },
            {
                coords = vector3(461.8, -998.0, 30.7),
                size = vector3(2.0, 2.0, 2.0),
                icon = 'fa-solid fa-comments',
                label = 'Verhörraum 2'
            }
        },

        -- Gefängniszellen
        cells = {
            {
                coords = vector3(462.1, -1001.9, 30.7),
                heading = 0.0,
                occupied = false
            },
            {
                coords = vector3(462.1, -998.0, 30.7),
                heading = 0.0,
                occupied = false
            }
        },

        equipment = {
            coords = vector3(439.0, -975.0, 30.67),
            size = vector3(1.5, 1.5, 2.0),
            icon = 'fa-solid fa-vest',
            label = 'Ausrüstung'
        },

        wardrobe = {
            coords = vector3(435.0, -975.0, 30.67),
            size = vector3(1.5, 1.5, 2.0),
            icon = 'fa-solid fa-shirt',
            label = 'Umkleidekabine'
        }
    },

    -- Vespucci Police Station
    ['police_station_2'] = {
        label = 'Vespucci Police Station',
        coords = vector3(-1107.0, -845.0, 19.0),
        heading = 37.0,

        dutyPoint = {
            coords = vector3(-1107.0, -845.0, 19.0),
            size = vector3(2.0, 2.0, 2.0),
            rotation = 37.0,
            icon = 'fa-solid fa-shield',
            label = 'Dienst beginnen/beenden'
        },

        vehicles = {
            {
                coords = vector3(-1120.0, -845.0, 13.0),
                heading = 127.0,
                category = 'patrol'
            },
            {
                coords = vector3(-1117.0, -848.0, 13.0),
                heading = 127.0,
                category = 'unmarked'
            }
        },

        equipment = {
            coords = vector3(-1103.0, -840.0, 19.0),
            size = vector3(1.5, 1.5, 2.0),
            icon = 'fa-solid fa-vest',
            label = 'Ausrüstung'
        }
    }
}

-- ================================
-- 🚑 RETTUNGSDIENST-WACHEN
-- ================================

Config.Stations.ems = {
    -- Hauptrettungswache (Pillbox Medical)
    ['ems_station_1'] = {
        label = 'Pillbox Medical Center',
        coords = vector3(310.0, -594.2, 43.3),
        heading = 0.0,

        dutyPoint = {
            coords = vector3(310.0, -594.2, 43.3),
            size = vector3(2.0, 2.0, 2.0),
            rotation = 0.0,
            icon = 'fa-solid fa-ambulance',
            label = 'Dienst beginnen/beenden'
        },

        vehicles = {
            -- RTW-Stellplätze
            {
                coords = vector3(295.0, -574.0, 43.2),
                heading = 70.0,
                category = 'ambulance'
            },
            {
                coords = vector3(291.0, -571.0, 43.2),
                heading = 70.0,
                category = 'ambulance'
            },
            -- Hubschrauber-Landeplatz
            {
                coords = vector3(338.5, -583.85, 74.16),
                heading = 250.0,
                category = 'helicopter'
            }
        },

        -- Medikamentenschrank
        pharmacy = {
            coords = vector3(316.0, -590.0, 43.3),
            size = vector3(1.5, 1.5, 2.0),
            icon = 'fa-solid fa-pills',
            label = 'Medikamentenschrank'
        },

        -- Behandlungsräume
        treatment = {
            {
                coords = vector3(324.0, -582.0, 43.3),
                size = vector3(2.0, 2.0, 2.0),
                icon = 'fa-solid fa-bed',
                label = 'Behandlungsraum 1'
            },
            {
                coords = vector3(332.0, -582.0, 43.3),
                size = vector3(2.0, 2.0, 2.0),
                icon = 'fa-solid fa-bed',
                label = 'Behandlungsraum 2'
            }
        },

        -- Intensivstation
        icu = {
            coords = vector3(327.0, -565.0, 43.3),
            size = vector3(3.0, 3.0, 2.0),
            icon = 'fa-solid fa-heart-pulse',
            label = 'Intensivstation'
        },

        equipment = {
            coords = vector3(305.0, -597.0, 43.3),
            size = vector3(1.5, 1.5, 2.0),
            icon = 'fa-solid fa-kit-medical',
            label = 'Medizinische Ausrüstung'
        },

        wardrobe = {
            coords = vector3(307.0, -600.0, 43.3),
            size = vector3(1.5, 1.5, 2.0),
            icon = 'fa-solid fa-shirt',
            label = 'Umkleidekabine'
        }
    },

    -- Rettungswache Sandy Shores
    ['ems_station_2'] = {
        label = 'Sandy Shores Medical',
        coords = vector3(1835.0, 3672.0, 34.3),
        heading = 210.0,

        dutyPoint = {
            coords = vector3(1835.0, 3672.0, 34.3),
            size = vector3(2.0, 2.0, 2.0),
            rotation = 210.0,
            icon = 'fa-solid fa-ambulance',
            label = 'Dienst beginnen/beenden'
        },

        vehicles = {
            {
                coords = vector3(1838.0, 3675.0, 34.0),
                heading = 210.0,
                category = 'ambulance'
            }
        },

        equipment = {
            coords = vector3(1832.0, 3670.0, 34.3),
            size = vector3(1.5, 1.5, 2.0),
            icon = 'fa-solid fa-kit-medical',
            label = 'Medizinische Ausrüstung'
        }
    }
}

-- ================================
-- 🏥 KRANKENHÄUSER (Allgemein)
-- ================================

Config.Hospitals = {
    ['pillbox'] = {
        label = 'Pillbox Hill Medical Center',
        coords = vector3(298.6, -584.4, 43.3),

        -- Eingangs-Punkte für Patienten
        entrances = {
            {
                coords = vector3(294.0, -583.0, 43.2),
                heading = 70.0,
                label = 'Haupteingang'
            },
            {
                coords = vector3(295.0, -574.0, 43.2),
                heading = 70.0,
                label = 'Notaufnahme'
            }
        },

        -- Betten für Patienten
        beds = {
            { coords = vector3(324.0, -582.0, 43.3), occupied = false },
            { coords = vector3(332.0, -582.0, 43.3), occupied = false },
            { coords = vector3(324.0, -574.0, 43.3), occupied = false },
            { coords = vector3(332.0, -574.0, 43.3), occupied = false }
        }
    },

    ['sandy'] = {
        label = 'Sandy Shores Medical Center',
        coords = vector3(1835.0, 3672.0, 34.3),

        entrances = {
            {
                coords = vector3(1838.0, 3675.0, 34.3),
                heading = 210.0,
                label = 'Haupteingang'
            }
        },

        beds = {
            { coords = vector3(1832.0, 3670.0, 34.3), occupied = false }
        }
    }
}

-- ================================
-- 🔧 STATIONS-ÜBERGREIFENDE SETTINGS
-- ================================

Config.StationSettings = {
    -- Automatische Tor-Steuerung
    automaticDoors = true,
    doorOpenDistance = 10.0,
    doorCloseDelay = 5000, -- ms

    -- Zugangskontrolle
    accessControl = {
        enabled = true,
        requireJobAndDuty = true,
        allowVisitors = false,            -- Zivilisten können Stationen betreten
        visitorAreas = { 'briefingRoom' } -- Bereiche für Besucher
    },

    -- Beleuchtung
    lighting = {
        automatic = true,
        nightTime = { hour = 20, minute = 0 },
        dayTime = { hour = 6, minute = 0 }
    },

    -- Sicherheit
    security = {
        cameras = true,
        alarms = true,
        logAccess = true
    },

    -- Performance
    performance = {
        renderDistance = 100.0,
        interactionDistance = 3.0,
        maxPlayersInStation = 15
    }
}
