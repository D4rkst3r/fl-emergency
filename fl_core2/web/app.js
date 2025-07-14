/**
 * ================================
 * 🚨 FL EMERGENCY - MDT APPLICATION (FIXED)
 * ================================
 */

class FlashingLightsMDT {
  constructor() {
    this.service = null;
    this.serviceData = null;
    this.playerData = null;
    this.calls = {};
    this.vehicles = {};
    this.settings = {
      soundNotifications: true,
      callAlerts: true,
      darkMode: false,
      autoRefresh: true,
    };
    this.currentTab = "calls";
    this.updateInterval = null;
    this.isVisible = false;
    this.debugMode = this.isInBrowser();
    this.currentCall = null;

    this.init();
  }

  // ================================
  // 🔧 INITIALIZATION & UTILITIES
  // ================================

  init() {
    console.log("🚨 MDT initializing...");

    this.setupEventListeners();
    this.setupKeyboardShortcuts();
    this.loadSettings();

    // Verstecke UI initially (außer im Browser-Debug-Modus)
    if (!this.debugMode) {
      document.body.style.display = "none";
    } else {
      // Browser-Debug-Modus: Zeige Test-Button
      this.addDebugControls();
    }

    console.log("🚨 MDT initialized (Debug Mode:", this.debugMode, ")");
  }

  // Prüfe ob wir im Browser sind
  isInBrowser() {
    return (
      typeof GetParentResourceName === "undefined" ||
      (typeof window !== "undefined" &&
        window.location.protocol.startsWith("http"))
    );
  }

  // Füge Debug-Controls für Browser-Testing hinzu
  addDebugControls() {
    const debugPanel = document.createElement("div");
    debugPanel.style.cssText = `
      position: fixed; top: 10px; left: 10px; z-index: 999999;
      background: rgba(0,0,0,0.8); color: white; padding: 10px;
      border-radius: 5px; font-family: monospace;
    `;
    debugPanel.innerHTML = `
      <h4>🚨 MDT Debug Panel</h4>
      <button onclick="flMDT.testOpenMDT()">Test MDT öffnen</button>
      <button onclick="flMDT.testAddCall()">Test Call hinzufügen</button>
      <button onclick="flMDT.testUpdateCall()">Test Call Update</button>
      <button onclick="flMDT.toggleDebugData()">Debug Daten anzeigen</button>
    `;
    document.body.appendChild(debugPanel);
  }

  setupEventListeners() {
    // NUI Message Handler mit Error Handling
    window.addEventListener("message", (event) => {
      try {
        this.handleNUIMessage(event.data);
      } catch (error) {
        console.error("Error handling NUI message:", error, event.data);
        this.showNotification("Fehler beim Verarbeiten der Nachricht", "error");
      }
    });

    // Tab Navigation
    document.querySelectorAll(".nav-btn").forEach((btn) => {
      btn.addEventListener("click", () => {
        this.switchTab(btn.dataset.tab);
      });
    });

    // Close Button
    const closeBtn = document.getElementById("close-btn");
    if (closeBtn) {
      closeBtn.addEventListener("click", () => {
        this.closeMDT();
      });
    }

    // Refresh Button
    const refreshBtn = document.getElementById("refresh-calls");
    if (refreshBtn) {
      refreshBtn.addEventListener("click", () => {
        this.refreshCalls();
      });
    }

    // Create Call Button
    const createBtn = document.getElementById("create-call");
    if (createBtn) {
      createBtn.addEventListener("click", () => {
        this.openCreateCallModal();
      });
    }

    // Filters
    const statusFilter = document.getElementById("status-filter");
    const priorityFilter = document.getElementById("priority-filter");

    if (statusFilter) {
      statusFilter.addEventListener("change", () => {
        this.filterCalls();
      });
    }

    if (priorityFilter) {
      priorityFilter.addEventListener("change", () => {
        this.filterCalls();
      });
    }

    // Settings
    this.setupSettingsListeners();

    // Modal Events
    this.setupModalListeners();
  }

  setupSettingsListeners() {
    const settingsMap = [
      { id: "sound-notifications", key: "soundNotifications" },
      { id: "call-alerts", key: "callAlerts" },
      { id: "dark-mode", key: "darkMode" },
      { id: "auto-refresh", key: "autoRefresh" },
    ];

    settingsMap.forEach(({ id, key }) => {
      const element = document.getElementById(id);
      if (element) {
        element.addEventListener("change", (e) => {
          this.settings[key] = e.target.checked;

          // Spezielle Behandlung für bestimmte Settings
          if (key === "darkMode") {
            this.toggleDarkMode(e.target.checked);
          } else if (key === "autoRefresh") {
            if (e.target.checked) {
              this.startAutoRefresh();
            } else {
              this.stopAutoRefresh();
            }
          }

          this.saveSettings();
        });
      }
    });
  }

  setupModalListeners() {
    // Modal Close
    const modalClose = document.querySelector(".modal-close");
    if (modalClose) {
      modalClose.addEventListener("click", () => {
        this.closeModal();
      });
    }

    // Modal Action Buttons
    const actionButtons = [
      { id: "assign-btn", action: () => this.assignToCall() },
      { id: "waypoint-btn", action: () => this.setCallWaypoint() },
      { id: "complete-btn", action: () => this.completeCall() },
    ];

    actionButtons.forEach(({ id, action }) => {
      const btn = document.getElementById(id);
      if (btn) {
        btn.addEventListener("click", action);
      }
    });

    // Click outside modal to close
    const modal = document.getElementById("call-modal");
    if (modal) {
      modal.addEventListener("click", (e) => {
        if (e.target === modal) {
          this.closeModal();
        }
      });
    }
  }

  setupKeyboardShortcuts() {
    document.addEventListener("keydown", (e) => {
      if (!this.isVisible) return;

      switch (e.key) {
        case "Escape":
          if (document.getElementById("call-modal").style.display === "block") {
            this.closeModal();
          } else {
            this.closeMDT();
          }
          break;
        case "F5":
          e.preventDefault();
          this.refreshCalls();
          break;
        case "1":
          if (e.ctrlKey) {
            e.preventDefault();
            this.switchTab("calls");
          }
          break;
        case "2":
          if (e.ctrlKey) {
            e.preventDefault();
            this.switchTab("map");
          }
          break;
        case "3":
          if (e.ctrlKey) {
            e.preventDefault();
            this.switchTab("vehicles");
          }
          break;
      }
    });
  }

  // ================================
  // 🎮 NUI MESSAGE HANDLING (FIXED)
  // ================================

  handleNUIMessage(data) {
    console.log("📨 NUI Message:", data);

    if (!data || typeof data !== "object") {
      console.warn("Invalid NUI message data:", data);
      return;
    }

    switch (data.type) {
      case "openMDT":
        this.openMDT(data);
        break;
      case "closeMDT":
        this.closeMDT();
        break;
      case "updateCalls":
        this.updateCalls(data.calls);
        break;
      case "callCreated":
        this.handleCallCreated(data.call);
        break;
      case "callUpdated":
        this.handleCallUpdated(data.call);
        break;
      case "callCompleted":
        this.handleCallCompleted(data.call);
        break;
      case "updateVehicles":
        this.updateVehicles(data.vehicles);
        break;
      case "openDebug":
        this.isVisible = true;
        document.body.style.display = "block";
        break;
      default:
        console.warn("Unknown NUI message type:", data.type);
    }
  }

  // ================================
  // 🖥️ UI MANAGEMENT (FIXED)
  // ================================

  openMDT(data) {
    try {
      console.log("🚨 Opening MDT with data:", data);

      // Validiere eingehende Daten
      this.service = data.service || "police";
      this.serviceData = data.serviceData || {
        label: "Emergency Service",
        icon: "fas fa-shield",
        color: "#3498db",
      };
      this.playerData = data.playerData || {
        name: "Unknown Officer",
        rank: "Officer",
        rankLevel: 1,
        station: "Unknown Station",
        onDuty: true,
        source: 1,
      };
      this.calls = data.calls || {};
      this.vehicles = data.vehicles || {};

      // UI sichtbar machen
      this.showUI();

      // Start systems
      this.startClock();

      // Update UI components
      this.updateHeader();
      this.updateServiceColors();
      this.renderCalls();
      this.renderVehicles();
      this.updateStats();

      this.isVisible = true;

      // Start auto-refresh if enabled
      if (this.settings.autoRefresh) {
        this.startAutoRefresh();
      }

      console.log("🚨 MDT successfully opened for service:", this.service);
    } catch (error) {
      console.error("Error opening MDT:", error);
      this.showNotification("Fehler beim Öffnen des MDT", "error");
    }
  }

  showUI() {
    // Show main container
    document.body.style.display = "block";
    document.body.style.visibility = "visible";

    // Show app container
    const appContainer = document.getElementById("app");
    if (appContainer) {
      appContainer.style.display = "block";
      appContainer.style.visibility = "visible";
    }

    // Hide loading screen
    const loadingScreen = document.getElementById("loading-screen");
    if (loadingScreen) {
      loadingScreen.style.display = "none";
    }

    // Show MDT interface
    const mdtInterface = document.getElementById("mdt-interface");
    if (mdtInterface) {
      mdtInterface.style.display = "block";
      mdtInterface.style.visibility = "visible";
    }
  }

  closeMDT() {
    this.isVisible = false;
    this.stopAutoRefresh();

    // Hide UI completely
    if (!this.debugMode) {
      document.body.style.display = "none";
    }

    // Send close event to client (only in game)
    this.postNUI("closeUI", {});

    console.log("🚨 MDT closed");
  }

  updateHeader() {
    try {
      // Service Info
      this.setElementContent("service-icon", null, this.serviceData.icon);
      this.setElementContent("service-name", this.serviceData.label);
      this.setElementContent(
        "station-name",
        this.playerData.station || "Unbekannt"
      );

      // Officer Info
      this.setElementContent(
        "officer-name",
        this.playerData.name || "Unbekannt"
      );
      this.setElementContent(
        "officer-rank",
        this.playerData.rank || `Rang ${this.playerData.rankLevel || 1}`
      );

      // Duty Status
      const dutyIcon = document.getElementById("duty-icon");
      const dutyText = document.getElementById("duty-text");

      if (dutyIcon && dutyText) {
        if (this.playerData.onDuty) {
          dutyIcon.className = "fas fa-circle text-success";
          dutyText.textContent = "Im Dienst";
        } else {
          dutyIcon.className = "fas fa-circle text-danger";
          dutyText.textContent = "Außer Dienst";
        }
      }
    } catch (error) {
      console.error("Error updating header:", error);
    }
  }

  // Helper function for safe element content setting
  setElementContent(id, text, className) {
    const element = document.getElementById(id);
    if (element) {
      if (text !== null && text !== undefined) {
        element.textContent = text;
      }
      if (className) {
        element.className = className;
      }
    } else {
      console.warn(`Element with ID '${id}' not found`);
    }
  }

  updateServiceColors() {
    try {
      const root = document.documentElement;
      const colors = {
        fire: { primary: "#e74c3c", secondary: "#c0392b", accent: "#fff5f5" },
        police: { primary: "#3498db", secondary: "#2980b9", accent: "#f0f8ff" },
        ems: { primary: "#2ecc71", secondary: "#27ae60", accent: "#f0fff4" },
      };

      const serviceColors = colors[this.service] || colors.police;

      root.style.setProperty("--service-primary", serviceColors.primary);
      root.style.setProperty("--service-secondary", serviceColors.secondary);
      root.style.setProperty("--service-accent", serviceColors.accent);
    } catch (error) {
      console.error("Error updating service colors:", error);
    }
  }

  switchTab(tabName) {
    try {
      // Remove active class from all tabs
      document
        .querySelectorAll(".nav-btn")
        .forEach((btn) => btn.classList.remove("active"));
      document
        .querySelectorAll(".tab-content")
        .forEach((content) => content.classList.remove("active"));

      // Add active class to selected tab
      const selectedTab = document.querySelector(`[data-tab="${tabName}"]`);
      const selectedContent = document.getElementById(`${tabName}-tab`);

      if (selectedTab) selectedTab.classList.add("active");
      if (selectedContent) selectedContent.classList.add("active");

      this.currentTab = tabName;

      // Load tab-specific content
      this.loadTabContent(tabName);
    } catch (error) {
      console.error("Error switching tab:", error);
    }
  }

  loadTabContent(tabName) {
    try {
      switch (tabName) {
        case "calls":
          this.renderCalls();
          break;
        case "map":
          this.renderMap();
          break;
        case "vehicles":
          this.renderVehicles();
          break;
        case "reports":
          this.renderReports();
          break;
        case "settings":
          this.renderSettings();
          break;
      }
    } catch (error) {
      console.error(`Error loading content for tab '${tabName}':`, error);
    }
  }

  // ================================
  // 🚨 CALLS MANAGEMENT (FIXED)
  // ================================

  renderCalls() {
    try {
      const container = document.getElementById("calls-container");
      if (!container) {
        console.warn("Calls container not found");
        return;
      }

      const calls = Object.values(this.calls || {});

      if (calls.length === 0) {
        container.innerHTML = `
          <div class="no-calls">
              <i class="fas fa-check-circle"></i>
              <h3>Keine aktiven Einsätze</h3>
              <p>Momentan sind keine Einsätze verfügbar</p>
          </div>
        `;
        this.setElementContent("calls-badge", "0");
        return;
      }

      // Sort calls by priority and time
      calls.sort((a, b) => {
        if (a.priority !== b.priority) {
          return a.priority - b.priority; // Higher priority first
        }
        return (b.created || 0) - (a.created || 0); // Newer first
      });

      container.innerHTML = calls
        .map((call) => this.renderCallCard(call))
        .join("");

      // Update badge
      this.setElementContent("calls-badge", calls.length.toString());
    } catch (error) {
      console.error("Error rendering calls:", error);
      this.showNotification("Fehler beim Laden der Einsätze", "error");
    }
  }

  renderCallCard(call) {
    try {
      if (!call || !call.id) {
        console.warn("Invalid call data:", call);
        return "";
      }

      const priorityClass = this.getPriorityClass(call.priority);
      const statusClass = this.getStatusClass(call.status);
      const timeElapsed = this.formatTimeElapsed(call.created);
      const isAssigned = this.isPlayerAssignedToCall(call);

      return `
        <div class="call-card ${priorityClass}" data-call-id="${call.id}">
            <div class="call-header">
                <div class="call-id">${this.escapeHtml(call.id)}</div>
                <div class="call-priority priority-${call.priority || 2}">
                    <i class="fas fa-exclamation-triangle"></i>
                    P${call.priority || 2}
                </div>
                <div class="call-status status-${call.status || "pending"}">
                    ${this.getStatusIcon(call.status)}
                    ${this.getStatusText(call.status)}
                </div>
            </div>
            
            <div class="call-body">
                <div class="call-type">
                    <i class="fas fa-tag"></i>
                    ${this.escapeHtml(call.type || "Unbekannt")}
                </div>
                <div class="call-description">
                    ${this.escapeHtml(
                      call.description || "Keine Beschreibung verfügbar"
                    )}
                </div>
                <div class="call-meta">
                    <div class="call-time">
                        <i class="fas fa-clock"></i>
                        ${timeElapsed}
                    </div>
                    <div class="call-units">
                        <i class="fas fa-users"></i>
                        ${(call.assigned || []).length}/${
        call.requiredUnits || 1
      }
                    </div>
                </div>
            </div>
            
            <div class="call-actions">
                <button class="btn btn-sm btn-secondary" onclick="flMDT.setCallWaypoint('${
                  call.id
                }')">
                    <i class="fas fa-map-marker-alt"></i>
                    GPS
                </button>
                <button class="btn btn-sm ${
                  isAssigned ? "btn-danger" : "btn-primary"
                }" 
                        onclick="flMDT.${
                          isAssigned ? "unassignFromCall" : "assignToCall"
                        }('${call.id}')">
                    <i class="fas fa-${
                      isAssigned ? "user-minus" : "user-plus"
                    }"></i>
                    ${isAssigned ? "Entfernen" : "Zuweisen"}
                </button>
                <button class="btn btn-sm btn-info" onclick="flMDT.openCallDetails('${
                  call.id
                }')">
                    <i class="fas fa-info-circle"></i>
                    Details
                </button>
            </div>
        </div>
      `;
    } catch (error) {
      console.error("Error rendering call card:", error, call);
      return '<div class="call-card error">Fehler beim Laden des Einsatzes</div>';
    }
  }

  isPlayerAssignedToCall(call) {
    try {
      return (
        call.assigned &&
        Array.isArray(call.assigned) &&
        call.assigned.includes(this.playerData.source)
      );
    } catch (error) {
      console.error("Error checking call assignment:", error);
      return false;
    }
  }

  // ================================
  // 🚗 VEHICLES MANAGEMENT (FIXED)
  // ================================

  renderVehicles() {
    try {
      const container = document.querySelector(".vehicles-grid");
      if (!container) {
        console.warn("Vehicles container not found");
        return;
      }

      if (!this.vehicles || Object.keys(this.vehicles).length === 0) {
        container.innerHTML = `
          <div class="no-vehicles">
              <i class="fas fa-car"></i>
              <h3>Keine Fahrzeuge verfügbar</h3>
              <p>Momentan sind keine Fahrzeuge gespawnt</p>
          </div>
        `;
        return;
      }

      // Render vehicle cards
      container.innerHTML = Object.entries(this.vehicles)
        .map(([id, vehicle]) => this.renderVehicleCard(id, vehicle))
        .join("");
    } catch (error) {
      console.error("Error rendering vehicles:", error);
    }
  }

  renderVehicleCard(id, vehicle) {
    try {
      if (!vehicle) {
        return "";
      }

      return `
        <div class="vehicle-card" data-vehicle-id="${this.escapeHtml(id)}">
            <div class="vehicle-image">
                <i class="fas fa-car"></i>
            </div>
            <div class="vehicle-info">
                <h4>${this.escapeHtml(
                  vehicle.label || "Unbekanntes Fahrzeug"
                )}</h4>
                <p class="vehicle-plate">${this.escapeHtml(
                  vehicle.plate || "N/A"
                )}</p>
                <div class="vehicle-status">
                    <span class="status-indicator ${
                      vehicle.status || "offline"
                    }"></span>
                    ${this.escapeHtml(vehicle.status || "offline")}
                </div>
            </div>
            <div class="vehicle-actions">
                <button class="btn btn-sm btn-primary" onclick="flMDT.locateVehicle('${id}')">
                    <i class="fas fa-map-marker-alt"></i>
                    Orten
                </button>
                <button class="btn btn-sm btn-danger" onclick="flMDT.returnVehicle('${id}')">
                    <i class="fas fa-undo"></i>
                    Zurückbringen
                </button>
            </div>
        </div>
      `;
    } catch (error) {
      console.error("Error rendering vehicle card:", error);
      return '<div class="vehicle-card error">Fehler beim Laden des Fahrzeugs</div>';
    }
  }

  // ================================
  // 🔧 UTILITY FUNCTIONS (FIXED)
  // ================================

  escapeHtml(text) {
    if (typeof text !== "string") {
      return String(text || "");
    }
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }

  getPriorityClass(priority) {
    const classes = {
      1: "priority-high",
      2: "priority-medium",
      3: "priority-low",
    };
    return classes[priority] || "priority-medium";
  }

  getStatusClass(status) {
    const classes = {
      pending: "status-pending",
      assigned: "status-assigned",
      active: "status-active",
      completed: "status-completed",
    };
    return classes[status] || "status-pending";
  }

  getStatusIcon(status) {
    const icons = {
      pending: '<i class="fas fa-clock"></i>',
      assigned: '<i class="fas fa-user-check"></i>',
      active: '<i class="fas fa-play"></i>',
      completed: '<i class="fas fa-check"></i>',
    };
    return icons[status] || '<i class="fas fa-question"></i>';
  }

  getStatusText(status) {
    const texts = {
      pending: "Ausstehend",
      assigned: "Zugewiesen",
      active: "Aktiv",
      completed: "Abgeschlossen",
    };
    return texts[status] || "Unbekannt";
  }

  formatTimeElapsed(timestamp) {
    try {
      if (!timestamp) return "Unbekannt";

      const now = Date.now() / 1000;
      const elapsed = now - timestamp;

      if (elapsed < 60) return "Gerade eben";
      if (elapsed < 3600) return `${Math.floor(elapsed / 60)}m`;
      if (elapsed < 86400) return `${Math.floor(elapsed / 3600)}h`;
      return `${Math.floor(elapsed / 86400)}d`;
    } catch (error) {
      console.error("Error formatting time:", error);
      return "Unbekannt";
    }
  }

  // ================================
  // 📡 NUI COMMUNICATION (FIXED)
  // ================================

  postNUI(type, data) {
    try {
      if (this.debugMode) {
        // Browser-Debug-Modus
        console.log(`[BROWSER-DEBUG] PostNUI called:`);
        console.log(`Type: ${type}`);
        console.log(`Data:`, data);
        this.showNotification(`Aktion '${type}' im Browser simuliert`, "info");

        // Simuliere Antworten für Testing
        this.simulateNUIResponse(type, data);
        return;
      }

      // Game-Modus
      if (typeof GetParentResourceName === "undefined") {
        console.warn(
          "GetParentResourceName not available, running in browser mode"
        );
        return;
      }

      fetch(`https://${GetParentResourceName()}/${type}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
      }).catch((error) => {
        console.error("NUI Error:", error);
        this.showNotification("Verbindungsfehler", "error");
      });
    } catch (error) {
      console.error("Error in postNUI:", error);
    }
  }

  simulateNUIResponse(type, data) {
    // Simuliere Server-Antworten für Browser-Testing
    setTimeout(() => {
      switch (type) {
        case "assignCall":
          this.handleCallUpdated({
            ...this.calls[data.callId],
            assigned: [
              ...(this.calls[data.callId]?.assigned || []),
              this.playerData.source,
            ],
            status: "assigned",
          });
          break;
        case "unassignCall":
          this.handleCallUpdated({
            ...this.calls[data.callId],
            assigned: (this.calls[data.callId]?.assigned || []).filter(
              (id) => id !== this.playerData.source
            ),
            status: "pending",
          });
          break;
        case "completeCall":
          this.handleCallCompleted(this.calls[data.callId]);
          break;
      }
    }, 200);
  }

  // ================================
  // 🎮 TEST FUNCTIONS (für Browser-Debug)
  // ================================

  testOpenMDT() {
    const testData = {
      type: "openMDT",
      service: "police",
      serviceData: {
        label: "Polizei",
        icon: "fas fa-shield-alt",
        color: "#3498db",
      },
      playerData: {
        name: "Max Mustermann",
        rank: "Kommissar",
        rankLevel: 3,
        station: "Revier Innenstadt",
        onDuty: true,
        source: 1,
        activeOfficers: 5,
      },
      calls: {
        "POL-1234": {
          id: "POL-1234",
          type: "Einbruch",
          priority: 1,
          status: "pending",
          description: "Einbruch in einem Juweliergeschäft in der Innenstadt",
          created: Math.floor(Date.now() / 1000) - 90,
          assigned: [],
          requiredUnits: 2,
          coords: { x: -634.0, y: -239.0, z: 38.0 },
        },
        "POL-5678": {
          id: "POL-5678",
          type: "Verkehrsunfall",
          priority: 2,
          status: "assigned",
          description: "Unfall mit zwei Fahrzeugen auf der Hauptstraße",
          created: Math.floor(Date.now() / 1000) - 300,
          assigned: [1],
          requiredUnits: 1,
          coords: { x: 215.0, y: -800.0, z: 30.0 },
        },
      },
      vehicles: {
        v1: { label: "Streifenwagen", plate: "LS-POL-123", status: "active" },
        v2: {
          label: "Zivilfahrzeug",
          plate: "LS-ZIV-456",
          status: "maintenance",
        },
      },
    };

    this.handleNUIMessage(testData);
  }

  testAddCall() {
    const newCall = {
      id: "POL-" + Math.floor(Math.random() * 9999),
      type: "Störung",
      priority: Math.floor(Math.random() * 3) + 1,
      status: "pending",
      description: "Test-Einsatz vom Debug-Panel",
      created: Math.floor(Date.now() / 1000),
      assigned: [],
      requiredUnits: 1,
      coords: { x: Math.random() * 1000, y: Math.random() * 1000, z: 30.0 },
    };

    this.handleCallCreated(newCall);
  }

  testUpdateCall() {
    const callIds = Object.keys(this.calls);
    if (callIds.length > 0) {
      const randomCallId = callIds[0];
      const call = { ...this.calls[randomCallId] };
      call.status = call.status === "pending" ? "assigned" : "pending";
      call.assigned =
        call.status === "assigned" ? [this.playerData.source] : [];

      this.handleCallUpdated(call);
    }
  }

  toggleDebugData() {
    const debugInfo = document.getElementById("debug-info");
    if (debugInfo) {
      debugInfo.remove();
    } else {
      const info = document.createElement("div");
      info.id = "debug-info";
      info.style.cssText = `
        position: fixed; top: 100px; right: 10px; z-index: 999999;
        background: rgba(0,0,0,0.9); color: #00ff00; padding: 15px;
        border-radius: 5px; font-family: monospace; font-size: 12px;
        max-width: 300px; max-height: 400px; overflow-y: auto;
      `;
      info.innerHTML = `
        <h4>🚨 Debug Information</h4>
        <p><strong>Service:</strong> ${this.service}</p>
        <p><strong>Calls:</strong> ${Object.keys(this.calls).length}</p>
        <p><strong>Vehicles:</strong> ${Object.keys(this.vehicles).length}</p>
        <p><strong>Current Tab:</strong> ${this.currentTab}</p>
        <p><strong>Is Visible:</strong> ${this.isVisible}</p>
        <p><strong>Debug Mode:</strong> ${this.debugMode}</p>
        <hr>
        <p><strong>Calls Data:</strong></p>
        <pre>${JSON.stringify(this.calls, null, 2)}</pre>
      `;
      document.body.appendChild(info);
    }
  }

  // ================================
  // Rest der Methoden bleibt gleich...
  // ================================

  renderMap() {
    console.log("Map rendering not implemented yet");
  }

  renderReports() {
    this.updateStats();
  }

  renderSettings() {
    this.applySettings();
  }

  updateStats() {
    try {
      const totalCalls = Object.keys(this.calls).length;
      const avgResponseTime = this.calculateAverageResponseTime();
      const activeOfficers = this.playerData.activeOfficers || 0;

      this.setElementContent("total-calls", totalCalls.toString());
      this.setElementContent("avg-response", avgResponseTime);
      this.setElementContent("active-officers", activeOfficers.toString());
    } catch (error) {
      console.error("Error updating stats:", error);
    }
  }

  calculateAverageResponseTime() {
    try {
      const completedCalls = Object.values(this.calls).filter(
        (call) => call.status === "completed" && call.responseTime
      );

      if (completedCalls.length === 0) return "0m";

      const totalTime = completedCalls.reduce(
        (sum, call) => sum + call.responseTime,
        0
      );
      const avgMinutes = Math.round(totalTime / completedCalls.length / 60);

      return `${avgMinutes}m`;
    } catch (error) {
      console.error("Error calculating average response time:", error);
      return "0m";
    }
  }

  updateCalls(calls) {
    this.calls = calls || {};
    if (this.currentTab === "calls") {
      this.renderCalls();
    }
  }

  updateVehicles(vehicles) {
    this.vehicles = vehicles || {};
    if (this.currentTab === "vehicles") {
      this.renderVehicles();
    }
  }

  filterCalls() {
    try {
      const statusFilter =
        document.getElementById("status-filter")?.value || "all";
      const priorityFilter =
        document.getElementById("priority-filter")?.value || "all";

      const callCards = document.querySelectorAll(".call-card");

      callCards.forEach((card) => {
        const callId = card.dataset.callId;
        const call = this.calls[callId];

        if (!call) return;

        let showCard = true;

        if (statusFilter !== "all" && call.status !== statusFilter) {
          showCard = false;
        }

        if (
          priorityFilter !== "all" &&
          call.priority.toString() !== priorityFilter
        ) {
          showCard = false;
        }

        card.style.display = showCard ? "block" : "none";
      });
    } catch (error) {
      console.error("Error filtering calls:", error);
    }
  }

  openCallDetails(callId) {
    try {
      const call = this.calls[callId];
      if (!call) {
        this.showNotification("Einsatz nicht gefunden", "error");
        return;
      }

      // Fill modal data
      this.setElementContent("call-id", call.id);
      this.setElementContent("call-type", call.type);
      this.setElementContent("call-priority", `Priorität ${call.priority}`);
      this.setElementContent("call-status", this.getStatusText(call.status));
      this.setElementContent(
        "call-description",
        call.description || "Keine Beschreibung"
      );

      // Assigned units
      const assignedUnits = document.getElementById("assigned-units");
      if (assignedUnits) {
        if (call.assigned && call.assigned.length > 0) {
          assignedUnits.innerHTML = call.assigned
            .map(
              (unit) =>
                `<span class="assigned-unit">${this.escapeHtml(unit)}</span>`
            )
            .join("");
        } else {
          assignedUnits.innerHTML =
            '<span class="no-units">Keine Einheiten zugewiesen</span>';
        }
      }

      // Update buttons
      const isAssigned = this.isPlayerAssignedToCall(call);
      const assignBtn = document.getElementById("assign-btn");

      if (assignBtn) {
        if (isAssigned) {
          assignBtn.innerHTML = '<i class="fas fa-user-minus"></i> Entfernen';
          assignBtn.className = "btn btn-danger";
        } else {
          assignBtn.innerHTML = '<i class="fas fa-user-plus"></i> Zuweisen';
          assignBtn.className = "btn btn-primary";
        }
      }

      this.currentCall = call;

      const modal = document.getElementById("call-modal");
      if (modal) {
        modal.style.display = "block";
      }
    } catch (error) {
      console.error("Error opening call details:", error);
      this.showNotification("Fehler beim Öffnen der Einsatzdetails", "error");
    }
  }

  closeModal() {
    const modal = document.getElementById("call-modal");
    if (modal) {
      modal.style.display = "none";
    }
    this.currentCall = null;
  }

  assignToCall(callId) {
    const id = callId || (this.currentCall && this.currentCall.id);
    if (!id) return;

    this.postNUI("assignCall", { callId: id });
    this.closeModal();
  }

  unassignFromCall(callId) {
    const id = callId || (this.currentCall && this.currentCall.id);
    if (!id) return;

    this.postNUI("unassignCall", { callId: id });
    this.closeModal();
  }

  setCallWaypoint(callId) {
    try {
      const call = callId ? this.calls[callId] : this.currentCall;
      if (!call || !call.coords) {
        this.showNotification(
          "Einsatz oder Koordinaten nicht gefunden",
          "error"
        );
        return;
      }

      this.postNUI("setWaypoint", { coords: call.coords });
      this.showNotification("GPS-Route gesetzt", "success");
    } catch (error) {
      console.error("Error setting waypoint:", error);
      this.showNotification("Fehler beim Setzen der Route", "error");
    }
  }

  completeCall() {
    if (!this.currentCall) return;

    const notes = prompt("Abschlussbericht (optional):");
    this.postNUI("completeCall", {
      callId: this.currentCall.id,
      notes: notes || "",
    });
    this.closeModal();
  }

  refreshCalls() {
    this.postNUI("refreshCalls", {});
    this.showNotification("Einsätze werden aktualisiert...", "info");
  }

  locateVehicle(vehicleId) {
    this.postNUI("locateVehicle", { vehicleId });
    this.showNotification("Fahrzeug wird geortet...", "info");
  }

  returnVehicle(vehicleId) {
    if (confirm("Fahrzeug wirklich zurückbringen?")) {
      this.postNUI("returnVehicle", { vehicleId });
    }
  }

  openCreateCallModal() {
    this.showNotification("Call-Erstellung noch nicht implementiert", "info");
  }

  startAutoRefresh() {
    if (this.updateInterval) return;

    this.updateInterval = setInterval(() => {
      if (this.isVisible) {
        this.postNUI("requestUpdate", {});
      }
    }, 5000);
  }

  stopAutoRefresh() {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
      this.updateInterval = null;
    }
  }

  startClock() {
    setInterval(() => {
      const now = new Date();
      this.setElementContent(
        "current-time",
        now.toLocaleTimeString("de-DE", {
          hour: "2-digit",
          minute: "2-digit",
          second: "2-digit",
        })
      );
    }, 1000);
  }

  toggleDarkMode(enabled) {
    document.body.classList.toggle("dark-mode", enabled);
  }

  loadSettings() {
    try {
      const saved = localStorage.getItem("fl-mdt-settings");
      if (saved) {
        this.settings = { ...this.settings, ...JSON.parse(saved) };
        this.applySettings();
      }
    } catch (error) {
      console.error("Error loading settings:", error);
    }
  }

  saveSettings() {
    try {
      localStorage.setItem("fl-mdt-settings", JSON.stringify(this.settings));
    } catch (error) {
      console.error("Error saving settings:", error);
    }
  }

  applySettings() {
    try {
      document.getElementById("sound-notifications").checked =
        this.settings.soundNotifications;
      document.getElementById("call-alerts").checked = this.settings.callAlerts;
      document.getElementById("dark-mode").checked = this.settings.darkMode;
      document.getElementById("auto-refresh").checked =
        this.settings.autoRefresh;

      this.toggleDarkMode(this.settings.darkMode);
    } catch (error) {
      console.error("Error applying settings:", error);
    }
  }

  showNotification(message, type = "info") {
    try {
      const notification = document.createElement("div");
      notification.className = `notification notification-${type}`;
      notification.innerHTML = `
        <i class="fas fa-${
          type === "success"
            ? "check"
            : type === "error"
            ? "exclamation"
            : "info"
        }"></i>
        <span>${this.escapeHtml(message)}</span>
      `;

      document.body.appendChild(notification);

      setTimeout(() => {
        if (notification.parentNode) {
          notification.remove();
        }
      }, 3000);

      if (this.settings.soundNotifications) {
        this.playSound(type);
      }
    } catch (error) {
      console.error("Error showing notification:", error);
    }
  }

  playSound(type) {
    try {
      const sounds = {
        success: "notification-sound",
        error: "alert-sound",
        info: "notification-sound",
      };

      const audioElement = document.getElementById(sounds[type]);
      if (audioElement) {
        audioElement.play().catch((e) => {
          console.log("Could not play sound:", e);
        });
      }
    } catch (error) {
      console.error("Error playing sound:", error);
    }
  }

  handleCallCreated(call) {
    try {
      if (!call || !call.id) return;

      this.calls[call.id] = call;

      if (this.currentTab === "calls") {
        this.renderCalls();
      }

      if (this.settings.callAlerts) {
        this.showNotification(`Neuer Einsatz: ${call.type}`, "error");
      }
    } catch (error) {
      console.error("Error handling call created:", error);
    }
  }

  handleCallUpdated(call) {
    try {
      if (!call || !call.id) return;

      this.calls[call.id] = call;

      if (this.currentTab === "calls") {
        this.renderCalls();
      }
    } catch (error) {
      console.error("Error handling call updated:", error);
    }
  }

  handleCallCompleted(call) {
    try {
      if (!call || !call.id) return;

      delete this.calls[call.id];

      if (this.currentTab === "calls") {
        this.renderCalls();
      }

      this.showNotification(`Einsatz ${call.id} abgeschlossen`, "success");
    } catch (error) {
      console.error("Error handling call completed:", error);
    }
  }
}

// Initialize MDT
const flMDT = new FlashingLightsMDT();
window.flMDT = flMDT;

console.log("🚨 FL Emergency MDT loaded successfully!");
