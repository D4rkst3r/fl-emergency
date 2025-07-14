# 🚨 FL Emergency Services - Modern Emergency System

Ein hochmodernes, vollständig integriertes Emergency Services System für FiveM/QBCore mit **Feuerwehr**, **Polizei** und **Rettungsdienst**.

## 🎯 Features

### 🔥 **Feuerwehr**

- ✅ Realistische Löschsysteme mit Wasserwerfer & Schaum
- ✅ Verschiedene Fahrzeugtypen (Löschfahrzeuge, Drehleitern, Rüstwagen)
- ✅ Ausrüstung: Atemschutz, Schläuche, Rettungsgeräte
- ✅ Einsätze: Brände, Rettung, Gefahrgut

### 🚓 **Polizei**

- ✅ Streifenwagen, Zivilfahrzeuge & Spezialfahrzeuge
- ✅ Komplette Ausrüstung inkl. Waffen & Handschellen
- ✅ Einsätze: Raub, Verkehrskontrollen, Fahndung
- ✅ MDT (Mobile Data Terminal) System

### 🚑 **Rettungsdienst**

- ✅ RTW, NEF & Rettungshubschrauber
- ✅ Medizinische Ausrüstung & Behandlungssystem
- ✅ Einsätze: Notfälle, Unfälle, Transporte
- ✅ Krankenhaus-Integration

### 🎨 **Moderne Technologien**

- ✅ **ox_lib** für Performance & moderne UI
- ✅ **ox_target** für Interaktionen
- ✅ **JSON-basierte Database** für Flexibilität
- ✅ **React-inspirierte UI** mit responsivem Design
- ✅ **Real-time Updates** für alle Spieler
- ✅ **TypeScript-ready** für erweiterte Entwicklung

---

## 📋 Requirements

### **Grundvoraussetzungen**

- **QBCore Framework** (latest version)
- **MySQL/MariaDB** (Version 10.4+)
- **ox_lib** (latest version)
- **ox_target** (latest version)
- **oxmysql** (latest version)

### **Empfohlene Addons**

- **EUP** für realistische Uniformen
- **Fahrzeug-Packs** für Custom Emergency Vehicles
- **qb-vehiclekeys** für Fahrzeugschlüssel
- **LegacyFuel** oder **ox_fuel** für Kraftstoffsystem

---

## 🚀 Installation

### **1. Download & Extract**

```bash
# In deinen FiveM Server resources/ Ordner
git clone https://github.com/your-repo/fl_emergency.git
# oder ZIP herunterladen und extrahieren
```

### **2. Dependencies installieren**

```bash
# Stelle sicher, dass diese Resources installiert sind:
ensure qb-core
ensure ox_lib
ensure ox_target
ensure oxmysql
```

### **3. Database Setup**

```sql
-- Führe die SQL-Datei aus
mysql -u root -p < sql/install.sql

-- Oder importiere über phpMyAdmin/Adminer
-- File: sql/install.sql
```

### **4. Resource-Konfiguration**

```lua
-- In server.cfg NACH qb-core hinzufügen:
ensure fl_emergency
```

### **5. QBCore Jobs Setup**

```lua
-- In qb-core/shared/jobs.lua hinzufügen:
['fire'] = {
    label = 'Feuerwehr',
    defaultDuty = false,
    offDutyPay = false,
    grades = {
        ['0'] = { name = 'Feuerwehrmann', payment = 75 },
        ['1'] = { name = 'Oberfeuerwehrmann', payment = 100 },
        ['2'] = { name = 'Hauptfeuerwehrmann', payment = 125 },
        ['3'] = { name = 'Brandmeister', payment = 150 },
        ['4'] = { name = 'Oberbrandmeister', payment = 175 },
        ['5'] = { name = 'Hauptbrandmeister', payment = 200 },
        ['6'] = { name = 'Brandamtmann', payment = 250 },
        ['7'] = { name = 'Branddirektor', payment = 300 },
    }
},
```

### **6. Items Setup**

```lua
-- In qb-core/shared/items.lua hinzufügen:
-- Feuerwehr Items
['fire_extinguisher'] = {
    name = 'fire_extinguisher',
    label = 'Feuerlöscher',
    weight = 5000,
    type = 'item',
    image = 'fire_extinguisher.png',
    unique = false,
    useable = true,
    shouldClose = false,
    description = 'Feuerlöscher für kleine Brände'
},

['fire_axe'] = {
    name = 'fire_axe',
    label = 'Feuerwehrbeil',
    weight = 2500,
    type = 'item',
    image = 'fire_axe.png',
    unique = false,
    useable = true,
    shouldClose = false,
    description = 'Feuerwehrbeil für Rettungseinsätze'
},

-- Weitere Items siehe: docs/items.md
```

---

## ⚙️ Konfiguration

### **Basis-Konfiguration**

```lua
-- config/main.lua
Config.Debug = false -- Auf true für Development
Config.Framework = 'qb-core'
Config.Locale = 'de'

-- Aktiviere/Deaktiviere Services
Config.EnabledServices = {
    fire = true,
    police = true,
    ems = true
}
```

### **Service-Anpassung**

```lua
-- config/services.lua
Config.Services.fire = {
    label = 'Feuerwehr',
    job = 'fire',
    color = '#e74c3c',
    -- Weitere Einstellungen...
}
```

### **Stations konfigurieren**

```lua
-- config/stations.lua
Config.Stations.fire['fire_station_1'] = {
    label = 'Feuerwache 1',
    coords = vector3(1193.54, -1464.17, 34.86),
    -- Fahrzeug-Spawns, Equipment, etc.
}
```

### **Fahrzeuge anpassen**

```lua
-- config/vehicles.lua
Config.Vehicles.fire.light['fire_truck'] = {
    label = 'Löschfahrzeug',
    model = 'firetruk',
    requiredGrade = 0,
    -- Ausstattung, Livery, etc.
}
```

---

## 🎮 Nutzung

### **Für Spieler**

#### **Dienst beginnen**

1. Gehe zu deiner Wache (Blip auf der Map)
2. Benutze **ox_target** am Einstempel-Punkt
3. Wähle "Dienst beginnen"
4. Automatisch: Uniform + Equipment

#### **Fahrzeuge spawnen**

1. Gehe zum Fahrzeug-Spawn-Punkt
2. Wähle Fahrzeug aus dem Menü
3. Fahrzeug wird gespawnt (mit Schlüsseln)

#### **Einsätze bearbeiten**

1. Öffne MDT mit `/mdt` oder `F6`
2. Sieh aktive Einsätze
3. Weise dich zu oder erstelle neue Einsätze
4. Nutze GPS-Routing zum Einsatzort

#### **Equipment nutzen**

1. Benutze Equipment-Punkte an der Wache
2. Items werden automatisch gegeben
3. Fahrzeug-Equipment über Marker am Fahrzeug

### **Für Admins**

#### **Einsätze erstellen**

```lua
-- Ingame Commands
/testcall fire structure_fire
/testcall police robbery
/testcall ems car_accident

-- Oder via Export
exports.fl_emergency:CreateEmergencyCall({
    service = 'fire',
    type = 'structure_fire',
    coords = { x = 213.5, y = -810.0, z = 31.0 },
    priority = 1,
    description = 'Gebäudebrand Downtown'
})
```

#### **Debug & Monitoring**

```lua
-- Debug-Infos
/fldebug

-- Spieler-Status
/fldutyend [player_id]

-- Cleanup
/flcleanup
```

---

## 🔧 Customization

### **Neue Fahrzeuge hinzufügen**

```lua
-- In config/vehicles.lua
Config.Vehicles.fire.heavy['custom_fire_truck'] = {
    label = 'Custom Löschfahrzeug',
    model = 'custom_model_name',
    requiredGrade = 2,
    equipment = {
        water = 3000,
        foam = 500,
        tools = { 'fire_hose', 'ladder', 'thermal_camera' }
    },
    features = {
        siren = true,
        lights = true,
        waterCannon = true
    }
}
```

### **Neue Einsatz-Typen**

```lua
-- In config/services.lua
Config.Services.fire.callTypes['wildfire'] = {
    label = 'Waldbrand',
    priority = 1,
    requiredUnits = 3,
    equipment = { 'water_tank', 'shovel', 'breathing_apparatus' }
}
```

### **Custom Uniformen**

```lua
-- In config/services.lua
Config.Services.fire.uniforms.male[2] = {
    components = {
        [11] = { drawable = 316, texture = 0 }, -- Custom Jacket
        [4] = { drawable = 135, texture = 0 },  -- Custom Pants
        -- Weitere Components...
    }
}
```

---

## 📊 Database Schema

### **Haupttabelle: fl_emergency_data**

```sql
-- Flexibles JSON-System für alle Daten
id, citizenid, type, service, data, created_at, expires_at
```

### **Verfügbare Typen**

- `duty` - Dienst-Status & Zeiten
- `call` - Einsätze & Status
- `vehicle` - Gespawnte Fahrzeuge
- `equipment` - Equipment-Requests
- `stats` - Statistiken
- `log` - System-Logs

### **Views für Performance**

- `fl_active_players` - Aktive Spieler im Dienst
- `fl_active_calls` - Aktive Einsätze
- `fl_duty_stats` - Dienst-Statistiken
- `fl_call_stats` - Einsatz-Statistiken

---

## 🚨 Troubleshooting

### **Häufige Probleme**

#### **MDT öffnet nicht**

```lua
-- Prüfe Console auf Fehler
-- Stelle sicher, dass ox_lib geladen ist
-- Überprüfe Job-Konfiguration
```

#### **Fahrzeuge spawnen nicht**

```lua
-- Prüfe Fahrzeug-Models in vehicles.lua
-- Stelle sicher, dass Spawn-Punkte frei sind
-- Überprüfe Player-Berechtigungen
```

#### **Einsätze erscheinen nicht**

```lua
-- Prüfe Service-Konfiguration
-- Stelle sicher, dass Player im Dienst ist
-- Überprüfe Database-Verbindung
```

### **Debug-Modus**

```lua
-- In config/main.lua
Config.Debug = true

-- Mehr Logs in F8-Console
-- Zusätzliche Informationen im Chat
```

### **Performance-Optimierung**

```sql
-- Database-Wartung
CALL CleanupExpiredData();

-- Indizes prüfen
ANALYZE TABLE fl_emergency_data;

-- Statistiken aktualisieren
CALL GetServiceStats('fire', 30);
```

---

## 🔄 Updates

### **Version Checking**

```lua
-- System prüft automatisch auf Updates
-- Konfigurierbar in config/main.lua
Config.Version.checkForUpdates = true
```

### **Migration**

```sql
-- Führe Migration-Scripts aus
-- Backup vor Updates erstellen
CALL CreateBackup('pre_update');
```

---

## 📚 Documentation

### **Weitere Docs**

- [API Reference](docs/api.md)
- [Custom Development](docs/development.md)
- [Item Configuration](docs/items.md)
- [Events & Exports](docs/events.md)

### **Support**

- **Discord**: [FL Emergency Discord](https://discord.gg/fl-emergency)
- **GitHub**: [Issues & Bug Reports](https://github.com/your-repo/fl_emergency/issues)
- **Wiki**: [Detailed Documentation](https://github.com/your-repo/fl_emergency/wiki)

---

## 📄 License

```
MIT License

Copyright (c) 2024 FL Emergency Services

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 🙏 Credits

- **QBCore Framework** - Basis-Framework
- **ox_lib** - UI & Performance
- **ox_target** - Interaktions-System
- **Community** - Feedback & Testing

---

## 🚀 Roadmap

### **Geplante Features**

- [ ] Erweiterte Statistiken & Reports
- [ ] Webpanel für Dispatcher
- [ ] KI-basierte Einsätze
- [ ] Erweiterte Fahrzeug-Physik
- [ ] Multi-Language Support
- [ ] Mobile App für Management

### **Version 2.1**

- [ ] Erweiterte Feuerwehr-Mechaniken
- [ ] Neue Polizei-Tools
- [ ] Rettungsdienst-Verbesserungen
- [ ] Performance-Optimierungen

---

**Viel Spaß mit FL Emergency Services! 🚨**
