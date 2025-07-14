-- ================================
-- 🌍 FL EMERGENCY - GERMAN LOCALIZATION
-- ================================

Locale = {}

-- ================================
-- 🔧 SYSTEM MESSAGES
-- ================================

Locale.system = {
    -- Core Messages
    ['loading'] = 'FL Emergency Services wird geladen...',
    ['ready'] = 'FL Emergency Services bereit!',
    ['error'] = 'Fehler: %s',
    ['success'] = 'Erfolgreich: %s',
    ['warning'] = 'Warnung: %s',
    ['info'] = 'Info: %s',

    -- Permissions
    ['no_permission'] = 'Du hast keine Berechtigung für diese Aktion',
    ['admin_only'] = 'Nur Administratoren können diese Aktion ausführen',
    ['service_only'] = 'Nur Emergency Service Mitglieder können diese Aktion ausführen',
    ['rank_required'] = 'Du benötigst Rang %s oder höher',
    ['whitelist_required'] = 'Du stehst nicht auf der Whitelist für diesen Service',

    -- Database
    ['db_error'] = 'Datenbankfehler: %s',
    ['db_connected'] = 'Datenbankverbindung erfolgreich',
    ['db_cleanup'] = 'Datenbank bereinigt: %s Einträge entfernt',

    -- Version
    ['version_check'] = 'Prüfe auf Updates...',
    ['version_current'] = 'Version %s ist aktuell',
    ['version_outdated'] = 'Version %s verfügbar (aktuell: %s)',
    ['version_error'] = 'Versions-Check fehlgeschlagen'
}

-- ================================
-- 🚨 DUTY SYSTEM
-- ================================

Locale.duty = {
    -- Duty Status
    ['duty_started'] = 'Dienst begonnen',
    ['duty_ended'] = 'Dienst beendet',
    ['duty_duration'] = 'Dienstzeit: %s',
    ['already_on_duty'] = 'Du bist bereits im Dienst',
    ['not_on_duty'] = 'Du bist nicht im Dienst',
    ['duty_required'] = 'Du musst im Dienst sein',

    -- Duty Actions
    ['duty_start'] = 'Dienst beginnen',
    ['duty_end'] = 'Dienst beenden',
    ['duty_toggle'] = 'Dienst umschalten',
    ['duty_confirm_end'] = 'Dienst wirklich beenden?',

    -- Duty Validation
    ['not_at_station'] = 'Du musst an einer Wache sein',
    ['max_players_reached'] = 'Maximale Anzahl aktiver Spieler erreicht',
    ['min_duty_time'] = 'Mindest-Dienstzeit von %s Minuten nicht erreicht',
    ['duty_timeout'] = 'Maximale Dienstzeit erreicht - Dienst automatisch beendet',

    -- Equipment
    ['equipment_received'] = 'Ausrüstung erhalten',
    ['equipment_removed'] = 'Ausrüstung abgegeben',
    ['equipment_full'] = 'Inventar ist voll',
    ['equipment_request'] = 'Ausrüstung anfordern',

    -- Uniform
    ['uniform_equipped'] = 'Uniform angezogen',
    ['uniform_removed'] = 'Zivilkleidung angezogen',
    ['uniform_select'] = 'Uniform auswählen',
    ['uniform_civilian'] = 'Zivilkleidung'
}

-- ================================
-- 🏢 STATIONS
-- ================================

Locale.stations = {
    -- General
    ['station_enter'] = 'Wache betreten',
    ['station_exit'] = 'Wache verlassen',
    ['station_access_denied'] = 'Zugang verweigert',
    ['station_welcome'] = 'Willkommen in der %s',

    -- Interactions
    ['duty_point'] = 'Einstempel-Punkt',
    ['equipment_locker'] = 'Ausrüstungsschrank',
    ['vehicle_garage'] = 'Fahrzeug-Garage',
    ['wardrobe'] = 'Umkleidekabine',
    ['briefing_room'] = 'Bereitschaftsraum',
    ['armory'] = 'Waffenkammer',

    -- Station Names
    ['fire_station'] = 'Feuerwache',
    ['police_station'] = 'Polizeiwache',
    ['ems_station'] = 'Rettungswache',
    ['hospital'] = 'Krankenhaus',

    -- Specific Stations
    ['fire_station_1'] = 'Feuerwache 1 - Downtown',
    ['fire_station_2'] = 'Feuerwache 2 - Nord',
    ['police_station_1'] = 'Mission Row Police Station',
    ['police_station_2'] = 'Vespucci Police Station',
    ['ems_station_1'] = 'Pillbox Medical Center',
    ['ems_station_2'] = 'Sandy Shores Medical'
}

-- ================================
-- 🚗 VEHICLES
-- ================================

Locale.vehicles = {
    -- General
    ['vehicle_spawned'] = 'Fahrzeug gespawnt: %s',
    ['vehicle_despawned'] = 'Fahrzeug despawned',
    ['vehicle_spawn_failed'] = 'Fahrzeug konnte nicht gespawnt werden',
    ['vehicle_spawn_blocked'] = 'Spawn-Punkt ist blockiert',
    ['vehicle_not_found'] = 'Fahrzeug nicht gefunden',
    ['vehicle_no_permission'] = 'Keine Berechtigung für dieses Fahrzeug',

    -- Actions
    ['vehicle_spawn'] = 'Fahrzeug spawnen',
    ['vehicle_despawn'] = 'Fahrzeug despawnen',
    ['vehicle_return'] = 'Fahrzeug zurückbringen',
    ['vehicle_locate'] = 'Fahrzeug orten',
    ['vehicle_repair'] = 'Fahrzeug reparieren',
    ['vehicle_refuel'] = 'Fahrzeug auftanken',

    -- Status
    ['vehicle_available'] = 'Verfügbar',
    ['vehicle_in_use'] = 'In Verwendung',
    ['vehicle_damaged'] = 'Beschädigt',
    ['vehicle_out_of_fuel'] = 'Kraftstoff leer',

    -- Equipment
    ['vehicle_equipment'] = 'Fahrzeug-Equipment',
    ['vehicle_equipment_access'] = 'Equipment-Zugang',
    ['vehicle_trunk'] = 'Kofferraum',
    ['vehicle_tools'] = 'Werkzeuge',

    -- Categories
    ['category_light'] = 'Leichte Fahrzeuge',
    ['category_heavy'] = 'Schwere Fahrzeuge',
    ['category_special'] = 'Spezialfahrzeuge',
    ['category_patrol'] = 'Streifenwagen',
    ['category_unmarked'] = 'Zivilfahrzeuge',
    ['category_ambulance'] = 'Rettungswagen',
    ['category_helicopter'] = 'Hubschrauber',
    ['category_support'] = 'Unterstützung',

    -- Features
    ['feature_siren'] = 'Sirene',
    ['feature_lights'] = 'Blaulicht',
    ['feature_water_cannon'] = 'Wasserwerfer',
    ['feature_foam_cannon'] = 'Schaumwerfer',
    ['feature_ladder'] = 'Leiter',
    ['feature_searchlight'] = 'Suchscheinwerfer',
    ['feature_winch'] = 'Winde',
    ['feature_activated'] = '%s aktiviert',
    ['feature_deactivated'] = '%s deaktiviert',

    -- Controls
    ['control_siren'] = 'Q - Sirene',
    ['control_horn'] = 'E - Horn',
    ['control_lights'] = 'L - Blaulicht',
    ['control_water_cannon'] = 'E - Wasserwerfer',
    ['control_searchlight'] = 'H - Suchscheinwerfer',
    ['control_ladder'] = 'Y - Leiter'
}

-- ================================
-- 📞 CALLS SYSTEM
-- ================================

Locale.calls = {
    -- General
    ['call_created'] = 'Einsatz erstellt: %s',
    ['call_updated'] = 'Einsatz aktualisiert: %s',
    ['call_assigned'] = 'Einsatz zugewiesen: %s',
    ['call_unassigned'] = 'Einsatz-Zuweisung aufgehoben: %s',
    ['call_completed'] = 'Einsatz abgeschlossen: %s',
    ['call_cancelled'] = 'Einsatz abgebrochen: %s',
    ['call_timeout'] = 'Einsatz-Timeout: %s',

    -- Status
    ['status_pending'] = 'Ausstehend',
    ['status_assigned'] = 'Zugewiesen',
    ['status_active'] = 'Aktiv',
    ['status_completed'] = 'Abgeschlossen',
    ['status_cancelled'] = 'Abgebrochen',

    -- Priority
    ['priority_1'] = 'Höchste Priorität',
    ['priority_2'] = 'Mittlere Priorität',
    ['priority_3'] = 'Niedrige Priorität',
    ['priority_high'] = 'Hoch',
    ['priority_medium'] = 'Mittel',
    ['priority_low'] = 'Niedrig',

    -- Actions
    ['call_assign'] = 'Zuweisen',
    ['call_unassign'] = 'Entfernen',
    ['call_complete'] = 'Abschließen',
    ['call_cancel'] = 'Abbrechen',
    ['call_details'] = 'Details',
    ['call_gps'] = 'GPS setzen',
    ['call_respond'] = 'Anfahren',

    -- Validation
    ['call_not_found'] = 'Einsatz nicht gefunden',
    ['call_not_assigned'] = 'Du bist diesem Einsatz nicht zugewiesen',
    ['call_already_assigned'] = 'Du bist bereits diesem Einsatz zugewiesen',
    ['call_wrong_service'] = 'Einsatz nicht für deinen Service',
    ['call_max_units'] = 'Maximale Einheiten erreicht',

    -- Types - Fire
    ['call_structure_fire'] = 'Gebäudebrand',
    ['call_vehicle_fire'] = 'Fahrzeugbrand',
    ['call_wildfire'] = 'Waldbrand',
    ['call_rescue'] = 'Technische Hilfeleistung',
    ['call_hazmat'] = 'Gefahrgut',

    -- Types - Police
    ['call_robbery'] = 'Raub',
    ['call_traffic_stop'] = 'Verkehrskontrolle',
    ['call_domestic_violence'] = 'Häusliche Gewalt',
    ['call_burglary'] = 'Einbruch',
    ['call_drug_deal'] = 'Drogenhandel',

    -- Types - EMS
    ['call_heart_attack'] = 'Herzinfarkt',
    ['call_car_accident'] = 'Verkehrsunfall',
    ['call_overdose'] = 'Überdosis',
    ['call_assault'] = 'Körperverletzung',
    ['call_unconscious'] = 'Bewusstlos',

    -- GPS
    ['gps_set'] = 'GPS-Route gesetzt',
    ['gps_cleared'] = 'GPS-Route entfernt',
    ['gps_waypoint'] = 'Wegpunkt gesetzt',

    -- Reports
    ['report_completion'] = 'Abschlussbericht',
    ['report_notes'] = 'Notizen',
    ['report_required'] = 'Bericht erforderlich',
    ['report_saved'] = 'Bericht gespeichert'
}

-- ================================
-- 🎨 UI INTERFACE
-- ================================

Locale.ui = {
    -- MDT
    ['mdt_title'] = 'Mobile Data Terminal',
    ['mdt_open'] = 'MDT öffnen',
    ['mdt_close'] = 'MDT schließen',
    ['mdt_loading'] = 'MDT wird geladen...',
    ['mdt_error'] = 'MDT-Fehler: %s',

    -- Tabs
    ['tab_calls'] = 'Einsätze',
    ['tab_map'] = 'Karte',
    ['tab_vehicles'] = 'Fahrzeuge',
    ['tab_reports'] = 'Berichte',
    ['tab_settings'] = 'Einstellungen',

    -- Buttons
    ['btn_assign'] = 'Zuweisen',
    ['btn_unassign'] = 'Entfernen',
    ['btn_complete'] = 'Abschließen',
    ['btn_cancel'] = 'Abbrechen',
    ['btn_save'] = 'Speichern',
    ['btn_close'] = 'Schließen',
    ['btn_refresh'] = 'Aktualisieren',
    ['btn_create'] = 'Erstellen',
    ['btn_edit'] = 'Bearbeiten',
    ['btn_delete'] = 'Löschen',
    ['btn_back'] = 'Zurück',
    ['btn_next'] = 'Weiter',
    ['btn_confirm'] = 'Bestätigen',

    -- Menus
    ['menu_duty'] = 'Dienst-Menü',
    ['menu_vehicle'] = 'Fahrzeug-Menü',
    ['menu_equipment'] = 'Ausrüstungs-Menü',
    ['menu_wardrobe'] = 'Umkleide-Menü',
    ['menu_calls'] = 'Einsatz-Menü',

    -- Filters
    ['filter_all'] = 'Alle',
    ['filter_status'] = 'Status',
    ['filter_priority'] = 'Priorität',
    ['filter_service'] = 'Service',
    ['filter_type'] = 'Typ',
    ['filter_active'] = 'Aktiv',
    ['filter_completed'] = 'Abgeschlossen',

    -- Search
    ['search_placeholder'] = 'Suchen...',
    ['search_results'] = 'Suchergebnisse',
    ['search_no_results'] = 'Keine Ergebnisse gefunden',

    -- Messages
    ['no_calls'] = 'Keine aktiven Einsätze',
    ['no_vehicles'] = 'Keine Fahrzeuge verfügbar',
    ['no_equipment'] = 'Keine Ausrüstung verfügbar',
    ['no_data'] = 'Keine Daten verfügbar',
    ['loading'] = 'Wird geladen...',
    ['error'] = 'Fehler aufgetreten',
    ['success'] = 'Erfolgreich',

    -- Settings
    ['setting_notifications'] = 'Benachrichtigungen',
    ['setting_sound'] = 'Sound-Benachrichtigungen',
    ['setting_alerts'] = 'Einsatz-Benachrichtigungen',
    ['setting_theme'] = 'Theme',
    ['setting_dark_mode'] = 'Dunkler Modus',
    ['setting_auto_refresh'] = 'Automatische Aktualisierung',
    ['setting_language'] = 'Sprache',

    -- Time
    ['time_now'] = 'Jetzt',
    ['time_minutes_ago'] = 'vor %s Minuten',
    ['time_hours_ago'] = 'vor %s Stunden',
    ['time_days_ago'] = 'vor %s Tagen',
    ['time_format'] = '%H:%M:%S',
    ['date_format'] = '%d.%m.%Y',

    -- Status Indicators
    ['status_online'] = 'Online',
    ['status_offline'] = 'Offline',
    ['status_busy'] = 'Beschäftigt',
    ['status_available'] = 'Verfügbar',
    ['status_on_duty'] = 'Im Dienst',
    ['status_off_duty'] = 'Außer Dienst'
}

-- ================================
-- 🔧 SERVICES
-- ================================

Locale.services = {
    -- Service Names
    ['fire'] = 'Feuerwehr',
    ['police'] = 'Polizei',
    ['ems'] = 'Rettungsdienst',
    ['ambulance'] = 'Rettungsdienst',

    -- Service Actions
    ['service_join'] = '%s beitreten',
    ['service_leave'] = '%s verlassen',
    ['service_active'] = '%s aktiv',
    ['service_inactive'] = '%s inaktiv',

    -- Fire Department
    ['fire_department'] = 'Feuerwehr',
    ['fire_station'] = 'Feuerwache',
    ['fire_captain'] = 'Brandmeister',
    ['fire_lieutenant'] = 'Oberfeuerwehrmann',
    ['fire_fighter'] = 'Feuerwehrmann',
    ['fire_recruit'] = 'Feuerwehrmann-Anwärter',

    -- Police Department
    ['police_department'] = 'Polizei',
    ['police_station'] = 'Polizeiwache',
    ['police_chief'] = 'Polizeipräsident',
    ['police_captain'] = 'Polizeidirektor',
    ['police_lieutenant'] = 'Polizeihauptkommissar',
    ['police_sergeant'] = 'Polizeikommissar',
    ['police_officer'] = 'Polizeimeister',
    ['police_cadet'] = 'Polizeimeisteranwärter',

    -- EMS
    ['ems_department'] = 'Rettungsdienst',
    ['ems_station'] = 'Rettungswache',
    ['ems_chief'] = 'Ärztlicher Leiter',
    ['ems_supervisor'] = 'Rettungsdienstleiter',
    ['ems_paramedic'] = 'Notfallsanitäter',
    ['ems_emt'] = 'Rettungsassistent',
    ['ems_trainee'] = 'Rettungssanitäter-Praktikant'
}

-- ================================
-- 📊 STATISTICS
-- ================================

Locale.stats = {
    -- General
    ['stats_title'] = 'Statistiken',
    ['stats_overview'] = 'Übersicht',
    ['stats_detailed'] = 'Detailliert',
    ['stats_period'] = 'Zeitraum',
    ['stats_today'] = 'Heute',
    ['stats_week'] = 'Diese Woche',
    ['stats_month'] = 'Dieser Monat',
    ['stats_year'] = 'Dieses Jahr',
    ['stats_all_time'] = 'Gesamt',

    -- Duty Stats
    ['stats_duty_time'] = 'Dienstzeit',
    ['stats_total_shifts'] = 'Gesamte Schichten',
    ['stats_avg_shift'] = 'Durchschnittliche Schicht',
    ['stats_longest_shift'] = 'Längste Schicht',
    ['stats_shortest_shift'] = 'Kürzeste Schicht',
    ['stats_active_officers'] = 'Aktive Beamte',

    -- Call Stats
    ['stats_total_calls'] = 'Gesamte Einsätze',
    ['stats_completed_calls'] = 'Abgeschlossene Einsätze',
    ['stats_cancelled_calls'] = 'Abgebrochene Einsätze',
    ['stats_avg_response'] = 'Durchschnittliche Antwortzeit',
    ['stats_avg_completion'] = 'Durchschnittliche Abschlusszeit',
    ['stats_call_rate'] = 'Einsatzrate',
    ['stats_success_rate'] = 'Erfolgsrate',

    -- Vehicle Stats
    ['stats_vehicles_spawned'] = 'Gespawnte Fahrzeuge',
    ['stats_avg_usage'] = 'Durchschnittliche Nutzung',
    ['stats_fuel_consumption'] = 'Kraftstoffverbrauch',
    ['stats_maintenance'] = 'Wartung',

    -- Performance
    ['stats_performance'] = 'Leistung',
    ['stats_efficiency'] = 'Effizienz',
    ['stats_rating'] = 'Bewertung',
    ['stats_rank'] = 'Rang',
    ['stats_score'] = 'Punkte',

    -- Formats
    ['stats_format_time'] = '%d:%02d:%02d',
    ['stats_format_percent'] = '%.1f%%',
    ['stats_format_number'] = '%d',
    ['stats_format_decimal'] = '%.2f'
}

-- ================================
-- 🎯 NOTIFICATIONS
-- ================================

Locale.notifications = {
    -- General
    ['notify_success'] = 'Erfolgreich',
    ['notify_error'] = 'Fehler',
    ['notify_warning'] = 'Warnung',
    ['notify_info'] = 'Information',

    -- Duty
    ['notify_duty_start'] = 'Dienst begonnen als %s',
    ['notify_duty_end'] = 'Dienst beendet nach %s',
    ['notify_duty_error'] = 'Dienst-Fehler: %s',

    -- Calls
    ['notify_call_new'] = 'Neuer Einsatz: %s',
    ['notify_call_assigned'] = 'Einsatz zugewiesen: %s',
    ['notify_call_completed'] = 'Einsatz abgeschlossen: %s',
    ['notify_call_cancelled'] = 'Einsatz abgebrochen: %s',

    -- Vehicles
    ['notify_vehicle_spawned'] = 'Fahrzeug gespawnt: %s',
    ['notify_vehicle_returned'] = 'Fahrzeug zurückgebracht: %s',
    ['notify_vehicle_damaged'] = 'Fahrzeug beschädigt: %s',
    ['notify_vehicle_fuel_low'] = 'Kraftstoff niedrig: %s',

    -- Equipment
    ['notify_equipment_received'] = 'Ausrüstung erhalten: %s',
    ['notify_equipment_removed'] = 'Ausrüstung entfernt: %s',
    ['notify_equipment_missing'] = 'Ausrüstung fehlt: %s',

    -- System
    ['notify_system_update'] = 'System-Update verfügbar',
    ['notify_system_maintenance'] = 'System-Wartung in %s Minuten',
    ['notify_system_restart'] = 'System-Neustart erforderlich',

    -- Errors
    ['notify_error_permission'] = 'Keine Berechtigung',
    ['notify_error_connection'] = 'Verbindungsfehler',
    ['notify_error_timeout'] = 'Zeitüberschreitung',
    ['notify_error_unknown'] = 'Unbekannter Fehler'
}

-- ================================
-- 🎮 COMMANDS
-- ================================

Locale.commands = {
    -- General Commands
    ['cmd_mdt'] = 'MDT öffnen',
    ['cmd_duty'] = 'Dienst umschalten',
    ['cmd_calls'] = 'Einsätze anzeigen',
    ['cmd_vehicles'] = 'Fahrzeuge anzeigen',
    ['cmd_equipment'] = 'Ausrüstung anzeigen',

    -- Admin Commands
    ['cmd_testcall'] = 'Test-Einsatz erstellen',
    ['cmd_fldebug'] = 'Debug-Informationen',
    ['cmd_flcleanup'] = 'Datenbank bereinigen',
    ['cmd_fldutyend'] = 'Dienst für Spieler beenden',
    ['cmd_flstats'] = 'Statistiken anzeigen',

    -- Command Help
    ['cmd_help_mdt'] = 'Öffnet das Mobile Data Terminal',
    ['cmd_help_duty'] = 'Beginnt oder beendet den Dienst',
    ['cmd_help_testcall'] = 'Erstellt einen Test-Einsatz (Admin)',
    ['cmd_help_debug'] = 'Zeigt Debug-Informationen an (Admin)',

    -- Command Errors
    ['cmd_error_permission'] = 'Keine Berechtigung für diesen Befehl',
    ['cmd_error_usage'] = 'Verwendung: %s',
    ['cmd_error_player'] = 'Spieler nicht gefunden',
    ['cmd_error_service'] = 'Service nicht gefunden'
}

-- ================================
-- 🔤 KEYBINDS
-- ================================

Locale.keybinds = {
    ['key_mdt'] = 'MDT öffnen',
    ['key_duty'] = 'Dienst umschalten',
    ['key_siren'] = 'Sirene umschalten',
    ['key_lights'] = 'Blaulicht umschalten',
    ['key_horn'] = 'Horn',
    ['key_radio'] = 'Radio',
    ['key_equipment'] = 'Ausrüstung',
    ['key_vehicle'] = 'Fahrzeug-Menü',
    ['key_call'] = 'Einsatz-Menü',
    ['key_emergency'] = 'Notfall'
}

-- ================================
-- 🌟 MISC
-- ================================

Locale.misc = {
    -- General
    ['yes'] = 'Ja',
    ['no'] = 'Nein',
    ['ok'] = 'OK',
    ['cancel'] = 'Abbrechen',
    ['confirm'] = 'Bestätigen',
    ['continue'] = 'Fortfahren',
    ['back'] = 'Zurück',
    ['next'] = 'Weiter',
    ['finish'] = 'Fertig',
    ['skip'] = 'Überspringen',
    ['retry'] = 'Wiederholen',
    ['refresh'] = 'Aktualisieren',
    ['reset'] = 'Zurücksetzen',
    ['clear'] = 'Leeren',
    ['select'] = 'Auswählen',
    ['deselect'] = 'Abwählen',
    ['enable'] = 'Aktivieren',
    ['disable'] = 'Deaktivieren',
    ['on'] = 'An',
    ['off'] = 'Aus',
    ['active'] = 'Aktiv',
    ['inactive'] = 'Inaktiv',
    ['available'] = 'Verfügbar',
    ['unavailable'] = 'Nicht verfügbar',
    ['online'] = 'Online',
    ['offline'] = 'Offline',
    ['connected'] = 'Verbunden',
    ['disconnected'] = 'Getrennt',
    ['loading'] = 'Wird geladen...',
    ['saving'] = 'Wird gespeichert...',
    ['processing'] = 'Wird verarbeitet...',
    ['completed'] = 'Abgeschlossen',
    ['failed'] = 'Fehlgeschlagen',
    ['unknown'] = 'Unbekannt',
    ['none'] = 'Keine',
    ['empty'] = 'Leer',
    ['full'] = 'Voll',
    ['partial'] = 'Teilweise',
    ['total'] = 'Gesamt',
    ['average'] = 'Durchschnitt',
    ['minimum'] = 'Minimum',
    ['maximum'] = 'Maximum',
    ['first'] = 'Erste',
    ['last'] = 'Letzte',
    ['current'] = 'Aktuell',
    ['previous'] = 'Vorherige',
    ['new'] = 'Neu',
    ['old'] = 'Alt',
    ['updated'] = 'Aktualisiert',
    ['created'] = 'Erstellt',
    ['deleted'] = 'Gelöscht',
    ['modified'] = 'Geändert',
    ['saved'] = 'Gespeichert',
    ['loaded'] = 'Geladen',
    ['required'] = 'Erforderlich',
    ['optional'] = 'Optional',
    ['recommended'] = 'Empfohlen',
    ['automatic'] = 'Automatisch',
    ['manual'] = 'Manuell',
    ['custom'] = 'Benutzerdefiniert',
    ['default'] = 'Standard',
    ['advanced'] = 'Erweitert',
    ['basic'] = 'Grundlegend',
    ['expert'] = 'Experte',
    ['beginner'] = 'Anfänger',
    ['professional'] = 'Professionell',
    ['personal'] = 'Persönlich',
    ['public'] = 'Öffentlich',
    ['private'] = 'Privat',
    ['shared'] = 'Geteilt',
    ['local'] = 'Lokal',
    ['remote'] = 'Entfernt',
    ['internal'] = 'Intern',
    ['external'] = 'Extern',
    ['temporary'] = 'Temporär',
    ['permanent'] = 'Permanent',
    ['emergency'] = 'Notfall',
    ['urgent'] = 'Dringend',
    ['normal'] = 'Normal',
    ['low'] = 'Niedrig',
    ['high'] = 'Hoch',
    ['critical'] = 'Kritisch',
    ['warning'] = 'Warnung',
    ['notice'] = 'Hinweis',
    ['tip'] = 'Tipp',
    ['hint'] = 'Hinweis',
    ['help'] = 'Hilfe',
    ['support'] = 'Support',
    ['contact'] = 'Kontakt',
    ['about'] = 'Über',
    ['version'] = 'Version',
    ['license'] = 'Lizenz',
    ['copyright'] = 'Copyright',
    ['author'] = 'Autor',
    ['credits'] = 'Credits',
    ['thanks'] = 'Danke',
    ['welcome'] = 'Willkommen',
    ['goodbye'] = 'Auf Wiedersehen',
    ['hello'] = 'Hallo',
    ['hi'] = 'Hi',
    ['bye'] = 'Tschüss',
    ['please'] = 'Bitte',
    ['thank_you'] = 'Danke',
    ['sorry'] = 'Entschuldigung',
    ['excuse_me'] = 'Entschuldigung',
    ['good_morning'] = 'Guten Morgen',
    ['good_afternoon'] = 'Guten Tag',
    ['good_evening'] = 'Guten Abend',
    ['good_night'] = 'Gute Nacht',
    ['have_a_nice_day'] = 'Schönen Tag noch',
    ['see_you_later'] = 'Bis später',
    ['take_care'] = 'Pass auf dich auf',
    ['good_luck'] = 'Viel Glück',
    ['congratulations'] = 'Herzlichen Glückwunsch',
    ['happy_birthday'] = 'Alles Gute zum Geburtstag',
    ['merry_christmas'] = 'Frohe Weihnachten',
    ['happy_new_year'] = 'Frohes neues Jahr'
}

-- ================================
-- 🔄 RETURN LOCALE TABLE
-- ================================

return Locale
