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

/**
 * ================================
 * 🚨 FL EMERGENCY - COMPLETE CALL SYSTEM
 * ================================
 */

// Erweitere die FlashingLightsMDT Klasse um vollständiges Call-Management
class CallSystem {
  constructor(mdt) {
    this.mdt = mdt;
    this.callHistory = [];
    this.callFilters = {
      status: "all",
      priority: "all",
      service: "all",
      assigned: "all",
    };
    this.sortBy = "priority"; // 'priority', 'time', 'distance'
    this.sortOrder = "asc";
    this.autoRefreshCalls = true;
    this.selectedCalls = new Set();

    this.init();
  }

  init() {
    this.setupCallEventListeners();
    this.setupCallTimers();
    console.log("🚨 Call System initialized");
  }

  setupCallEventListeners() {
    // Advanced Filters
    document.getElementById("calls-search")?.addEventListener("input", (e) => {
      this.searchCalls(e.target.value);
    });

    // Bulk Actions
    document.getElementById("bulk-assign")?.addEventListener("click", () => {
      this.bulkAssignCalls();
    });

    document.getElementById("bulk-complete")?.addEventListener("click", () => {
      this.bulkCompleteCalls();
    });

    // Sort Controls
    document.querySelectorAll(".sort-btn").forEach((btn) => {
      btn.addEventListener("click", () => {
        this.setSortOrder(btn.dataset.sort);
      });
    });
  }

  setupCallTimers() {
    // Update call timers every 30 seconds
    setInterval(() => {
      this.updateCallTimers();
    }, 30000);
  }

  // ================================
  // 🎨 ENHANCED CALL RENDERING
  // ================================

  renderEnhancedCalls() {
    try {
      const container = document.getElementById("calls-container");
      if (!container) return;

      const calls = Object.values(this.mdt.calls || {});

      if (calls.length === 0) {
        container.innerHTML = this.renderEmptyCallsState();
        return;
      }

      // Apply filters and sorting
      const filteredCalls = this.filterAndSortCalls(calls);

      // Render calls with enhanced features
      container.innerHTML = `
        <div class="calls-header">
          ${this.renderCallsToolbar(filteredCalls.length, calls.length)}
        </div>
        <div class="calls-grid">
          ${filteredCalls
            .map((call) => this.renderEnhancedCallCard(call))
            .join("")}
        </div>
      `;

      // Update badges
      this.updateCallBadges(calls);
    } catch (error) {
      console.error("Error rendering enhanced calls:", error);
    }
  }

  renderCallsToolbar(filtered, total) {
    return `
      <div class="calls-toolbar">
        <div class="toolbar-left">
          <div class="calls-counter">
            <span class="filtered-count">${filtered}</span>
            ${
              filtered !== total
                ? `von <span class="total-count">${total}</span>`
                : ""
            } Einsätze
          </div>
          <div class="view-options">
            <button class="btn btn-sm view-btn active" data-view="grid">
              <i class="fas fa-th"></i>
            </button>
            <button class="btn btn-sm view-btn" data-view="list">
              <i class="fas fa-list"></i>
            </button>
            <button class="btn btn-sm view-btn" data-view="map">
              <i class="fas fa-map"></i>
            </button>
          </div>
        </div>
        
        <div class="toolbar-center">
          <div class="search-container">
            <i class="fas fa-search"></i>
            <input type="text" id="calls-search" placeholder="Einsätze durchsuchen..." />
            <button class="btn btn-sm" id="clear-search">
              <i class="fas fa-times"></i>
            </button>
          </div>
        </div>
        
        <div class="toolbar-right">
          <div class="sort-container">
            <label>Sortieren:</label>
            <select id="sort-selector">
              <option value="priority">Priorität</option>
              <option value="time">Zeit</option>
              <option value="distance">Entfernung</option>
              <option value="status">Status</option>
            </select>
            <button class="btn btn-sm sort-btn" data-order="asc">
              <i class="fas fa-sort-amount-up"></i>
            </button>
          </div>
          
          <div class="bulk-actions" style="display: none;">
            <button class="btn btn-sm btn-primary" id="bulk-assign">
              <i class="fas fa-users"></i>
              Zuweisen
            </button>
            <button class="btn btn-sm btn-success" id="bulk-complete">
              <i class="fas fa-check"></i>
              Abschließen
            </button>
          </div>
        </div>
      </div>
    `;
  }

  renderEnhancedCallCard(call) {
    const isAssigned = this.mdt.isPlayerAssignedToCall(call);
    const isSelected = this.selectedCalls.has(call.id);
    const timeElapsed = this.calculateTimeElapsed(call.created);
    const distance = this.calculateDistance(call.coords);
    const urgencyLevel = this.calculateUrgencyLevel(call);

    return `
      <div class="call-card enhanced ${this.mdt.getPriorityClass(
        call.priority
      )} ${urgencyLevel}" 
           data-call-id="${call.id}"
           data-priority="${call.priority}"
           data-status="${call.status}">
        
        <!-- Call Header -->
        <div class="call-header">
          <div class="call-select">
            <input type="checkbox" class="call-checkbox" 
                   data-call-id="${call.id}" 
                   ${isSelected ? "checked" : ""}>
          </div>
          
          <div class="call-id-section">
            <div class="call-id">${this.mdt.escapeHtml(call.id)}</div>
            <div class="call-time">
              <i class="fas fa-clock"></i>
              <span class="time-elapsed" data-created="${call.created}">
                ${timeElapsed}
              </span>
            </div>
          </div>
          
          <div class="call-badges">
            <span class="priority-badge priority-${call.priority}">
              <i class="fas fa-exclamation-triangle"></i>
              P${call.priority}
            </span>
            <span class="status-badge status-${call.status}">
              ${this.mdt.getStatusIcon(call.status)}
              ${this.mdt.getStatusText(call.status)}
            </span>
            ${
              urgencyLevel === "urgent"
                ? '<span class="urgent-badge"><i class="fas fa-bolt"></i></span>'
                : ""
            }
          </div>
        </div>

        <!-- Call Body -->
        <div class="call-body">
          <div class="call-type-section">
            <div class="call-type">
              <i class="fas fa-tag"></i>
              <span class="type-text">${this.mdt.escapeHtml(call.type)}</span>
              ${
                call.subtype
                  ? `<span class="subtype">${this.mdt.escapeHtml(
                      call.subtype
                    )}</span>`
                  : ""
              }
            </div>
            ${
              distance
                ? `<div class="call-distance">
              <i class="fas fa-route"></i>
              ${distance}
            </div>`
                : ""
            }
          </div>
          
          <div class="call-description">
            ${this.mdt.escapeHtml(
              call.description || "Keine Beschreibung verfügbar"
            )}
          </div>
          
          ${
            call.location
              ? `<div class="call-location">
            <i class="fas fa-map-marker-alt"></i>
            ${this.mdt.escapeHtml(call.location)}
          </div>`
              : ""
          }
          
          <!-- Assignment Info -->
          <div class="call-assignment">
            <div class="assigned-units">
              <i class="fas fa-users"></i>
              <span class="unit-count">
                ${(call.assigned || []).length}/${call.requiredUnits || 1}
              </span>
              <span class="unit-text">Einheiten</span>
              ${
                isAssigned
                  ? '<span class="self-assigned"><i class="fas fa-user-check"></i>Du</span>'
                  : ""
              }
            </div>
            
            ${
              call.assigned && call.assigned.length > 0
                ? `
              <div class="assigned-list">
                ${call.assigned
                  .slice(0, 3)
                  .map(
                    (unit) =>
                      `<span class="assigned-unit">${this.mdt.escapeHtml(
                        unit
                      )}</span>`
                  )
                  .join("")}
                ${
                  call.assigned.length > 3
                    ? `<span class="more-units">+${
                        call.assigned.length - 3
                      }</span>`
                    : ""
                }
              </div>
            `
                : ""
            }
          </div>
          
          <!-- Additional Info -->
          ${
            call.reporter
              ? `<div class="call-reporter">
            <i class="fas fa-phone"></i>
            Gemeldet von: ${this.mdt.escapeHtml(call.reporter)}
          </div>`
              : ""
          }
          
          ${
            call.lastUpdate && call.lastUpdate !== call.created
              ? `<div class="call-updated">
            <i class="fas fa-edit"></i>
            Aktualisiert: ${this.formatTime(call.lastUpdate)}
          </div>`
              : ""
          }
        </div>

        <!-- Call Actions -->
        <div class="call-actions">
          <div class="primary-actions">
            <button class="btn btn-sm btn-secondary" onclick="callSystem.setCallWaypoint('${
              call.id
            }')">
              <i class="fas fa-map-marker-alt"></i>
              GPS
            </button>
            
            <button class="btn btn-sm ${
              isAssigned ? "btn-danger" : "btn-primary"
            }" 
                    onclick="callSystem.${
                      isAssigned ? "unassignFromCall" : "assignToCall"
                    }('${call.id}')">
              <i class="fas fa-${isAssigned ? "user-minus" : "user-plus"}"></i>
              ${isAssigned ? "Entfernen" : "Zuweisen"}
            </button>
            
            <button class="btn btn-sm btn-info" onclick="callSystem.openCallDetails('${
              call.id
            }')">
              <i class="fas fa-info-circle"></i>
              Details
            </button>
          </div>
          
          <div class="secondary-actions">
            <button class="btn btn-sm btn-outline" onclick="callSystem.requestBackup('${
              call.id
            }')">
              <i class="fas fa-plus-circle"></i>
              Verstärkung
            </button>
            
            ${
              isAssigned
                ? `
              <button class="btn btn-sm btn-warning" onclick="callSystem.updateCallStatus('${call.id}')">
                <i class="fas fa-edit"></i>
                Status
              </button>
              
              <button class="btn btn-sm btn-success" onclick="callSystem.completeCall('${call.id}')">
                <i class="fas fa-check"></i>
                Abschließen
              </button>
            `
                : ""
            }
          </div>
        </div>
        
        <!-- Progress Bar for Long-Running Calls -->
        ${this.renderCallProgress(call)}
      </div>
    `;
  }

  renderCallProgress(call) {
    if (call.status !== "active") return "";

    const elapsed = Date.now() / 1000 - call.created;
    const maxTime = this.getExpectedCallDuration(call.type);
    const progress = Math.min((elapsed / maxTime) * 100, 100);

    return `
      <div class="call-progress">
        <div class="progress-bar">
          <div class="progress-fill" style="width: ${progress}%"></div>
        </div>
        <span class="progress-text">
          ${Math.floor(elapsed / 60)}m / ${Math.floor(maxTime / 60)}m erwartet
        </span>
      </div>
    `;
  }

  renderEmptyCallsState() {
    return `
      <div class="empty-calls-state">
        <div class="empty-icon">
          <i class="fas fa-check-circle"></i>
        </div>
        <h3>Keine aktiven Einsätze</h3>
        <p>Momentan sind keine Einsätze verfügbar.</p>
        <div class="empty-actions">
          <button class="btn btn-primary" onclick="callSystem.openCreateCallModal()">
            <i class="fas fa-plus"></i>
            Neuen Einsatz erstellen
          </button>
          <button class="btn btn-secondary" onclick="callSystem.showCallHistory()">
            <i class="fas fa-history"></i>
            Einsatzverlauf anzeigen
          </button>
        </div>
      </div>
    `;
  }

  // ================================
  // 📝 CALL CREATION MODAL
  // ================================

  openCreateCallModal() {
    const modal = this.createCallModal();
    document.body.appendChild(modal);
    modal.style.display = "block";

    // Initialize form
    this.initializeCallForm();
  }

  createCallModal() {
    const modal = document.createElement("div");
    modal.className = "modal call-create-modal";
    modal.id = "call-create-modal";

    modal.innerHTML = `
      <div class="modal-content large">
        <div class="modal-header">
          <h2>
            <i class="fas fa-plus-circle"></i>
            Neuen Einsatz erstellen
          </h2>
          <button class="modal-close" onclick="callSystem.closeCreateCallModal()">
            <i class="fas fa-times"></i>
          </button>
        </div>
        
        <div class="modal-body">
          <form id="call-create-form" class="call-form">
            <!-- Basic Info -->
            <div class="form-section">
              <h3>Grundinformationen</h3>
              <div class="form-row">
                <div class="form-group">
                  <label for="call-service">Service *</label>
                  <select id="call-service" required>
                    <option value="">Service wählen...</option>
                    <option value="fire">🚒 Feuerwehr</option>
                    <option value="police">🚓 Polizei</option>
                    <option value="ems">🚑 Rettungsdienst</option>
                  </select>
                </div>
                
                <div class="form-group">
                  <label for="call-priority">Priorität *</label>
                  <select id="call-priority" required>
                    <option value="1">🔴 Hoch (P1)</option>
                    <option value="2" selected>🟡 Mittel (P2)</option>
                    <option value="3">🔵 Niedrig (P3)</option>
                  </select>
                </div>
              </div>
              
              <div class="form-row">
                <div class="form-group">
                  <label for="call-type">Einsatztyp *</label>
                  <select id="call-type" required>
                    <option value="">Typ wählen...</option>
                    <!-- Will be populated based on service -->
                  </select>
                </div>
                
                <div class="form-group">
                  <label for="call-units">Benötigte Einheiten</label>
                  <input type="number" id="call-units" min="1" max="10" value="1">
                </div>
              </div>
            </div>
            
            <!-- Location -->
            <div class="form-section">
              <h3>Einsatzort</h3>
              <div class="form-row">
                <div class="form-group">
                  <label for="call-location">Adresse/Ort</label>
                  <input type="text" id="call-location" placeholder="z.B. Mission Row Police Station">
                </div>
                
                <div class="form-group coords-group">
                  <label>Koordinaten</label>
                  <div class="coords-input">
                    <input type="number" id="call-coord-x" placeholder="X" step="0.1">
                    <input type="number" id="call-coord-y" placeholder="Y" step="0.1">
                    <input type="number" id="call-coord-z" placeholder="Z" step="0.1">
                    <button type="button" class="btn btn-sm btn-secondary" onclick="callSystem.useCurrentLocation()">
                      <i class="fas fa-crosshairs"></i>
                    </button>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- Description -->
            <div class="form-section">
              <h3>Beschreibung</h3>
              <div class="form-group">
                <label for="call-description">Einsatzbeschreibung *</label>
                <textarea id="call-description" rows="4" required 
                          placeholder="Detailierte Beschreibung des Einsatzes..."></textarea>
              </div>
              
              <div class="form-row">
                <div class="form-group">
                  <label for="call-reporter">Melder</label>
                  <input type="text" id="call-reporter" placeholder="Name des Melders">
                </div>
                
                <div class="form-group">
                  <label for="call-contact">Kontakt</label>
                  <input type="text" id="call-contact" placeholder="Telefonnummer">
                </div>
              </div>
            </div>
            
            <!-- Advanced Options -->
            <div class="form-section collapsible">
              <h3 onclick="this.parentElement.classList.toggle('expanded')">
                <i class="fas fa-chevron-right"></i>
                Erweiterte Optionen
              </h3>
              <div class="collapsible-content">
                <div class="form-row">
                  <div class="form-group">
                    <label>
                      <input type="checkbox" id="call-auto-assign">
                      Automatisch zuweisen
                    </label>
                  </div>
                  
                  <div class="form-group">
                    <label>
                      <input type="checkbox" id="call-high-priority">
                      Als dringend markieren
                    </label>
                  </div>
                </div>
                
                <div class="form-group">
                  <label for="call-notes">Interne Notizen</label>
                  <textarea id="call-notes" rows="3" 
                            placeholder="Interne Notizen (nicht für Einsatzkräfte sichtbar)"></textarea>
                </div>
              </div>
            </div>
          </form>
        </div>
        
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" onclick="callSystem.closeCreateCallModal()">
            <i class="fas fa-times"></i>
            Abbrechen
          </button>
          
          <button type="button" class="btn btn-outline" onclick="callSystem.saveCallDraft()">
            <i class="fas fa-save"></i>
            Als Entwurf speichern
          </button>
          
          <button type="submit" form="call-create-form" class="btn btn-primary">
            <i class="fas fa-plus-circle"></i>
            Einsatz erstellen
          </button>
        </div>
      </div>
    `;

    return modal;
  }

  initializeCallForm() {
    // Service-dependent call types
    document.getElementById("call-service").addEventListener("change", (e) => {
      this.updateCallTypes(e.target.value);
    });

    // Form submission
    document
      .getElementById("call-create-form")
      .addEventListener("submit", (e) => {
        e.preventDefault();
        this.submitNewCall();
      });

    // Auto-suggest locations
    this.setupLocationAutocomplete();

    // Load saved draft if exists
    this.loadCallDraft();
  }

  updateCallTypes(service) {
    const typeSelect = document.getElementById("call-type");
    const callTypes = this.getCallTypesForService(service);

    typeSelect.innerHTML = '<option value="">Typ wählen...</option>';

    callTypes.forEach((type) => {
      const option = document.createElement("option");
      option.value = type.id;
      option.textContent = type.label;
      typeSelect.appendChild(option);
    });
  }

  getCallTypesForService(service) {
    const types = {
      fire: [
        { id: "structure_fire", label: "🔥 Gebäudebrand" },
        { id: "vehicle_fire", label: "🚗 Fahrzeugbrand" },
        { id: "wildfire", label: "🌲 Waldbrand" },
        { id: "rescue", label: "🛠️ Technische Hilfeleistung" },
        { id: "hazmat", label: "☠️ Gefahrgut" },
      ],
      police: [
        { id: "robbery", label: "💰 Raub" },
        { id: "traffic_stop", label: "🚦 Verkehrskontrolle" },
        { id: "domestic_violence", label: "🏠 Häusliche Gewalt" },
        { id: "burglary", label: "🔓 Einbruch" },
        { id: "drug_deal", label: "💊 Drogenhandel" },
        { id: "pursuit", label: "🏃 Verfolgung" },
      ],
      ems: [
        { id: "heart_attack", label: "❤️ Herzinfarkt" },
        { id: "car_accident", label: "🚗 Verkehrsunfall" },
        { id: "overdose", label: "💊 Überdosis" },
        { id: "assault", label: "🤕 Körperverletzung" },
        { id: "unconscious", label: "😵 Bewusstlos" },
      ],
    };

    return types[service] || [];
  }

  setupLocationAutocomplete() {
    // Predefined locations for quick selection
    const locations = [
      "Mission Row Police Station",
      "Pillbox Medical Center",
      "Los Santos Fire Station 1",
      "Downtown Los Santos",
      "Vinewood Hills",
      "Sandy Shores",
      "Paleto Bay",
      "Los Santos International Airport",
    ];

    // Simple autocomplete implementation
    const locationInput = document.getElementById("call-location");
    // Implementation would go here...
  }

  useCurrentLocation() {
    // In game, this would get player coordinates
    // For browser testing, use dummy data
    if (this.mdt.debugMode) {
      document.getElementById("call-coord-x").value = (
        Math.random() * 2000 -
        1000
      ).toFixed(1);
      document.getElementById("call-coord-y").value = (
        Math.random() * 2000 -
        1000
      ).toFixed(1);
      document.getElementById("call-coord-z").value = (
        Math.random() * 100 +
        20
      ).toFixed(1);
    } else {
      this.mdt.postNUI("getCurrentLocation", {});
    }
  }

  submitNewCall() {
    const formData = this.collectFormData();

    if (!this.validateCallData(formData)) {
      return;
    }

    // Generate call ID
    formData.id = this.generateCallId(formData.service);
    formData.created = Math.floor(Date.now() / 1000);
    formData.status = "pending";
    formData.assigned = [];

    if (this.mdt.debugMode) {
      // Browser testing
      this.mdt.handleCallCreated(formData);
      this.mdt.showNotification("Einsatz erstellt (Debug)", "success");
    } else {
      // Send to server
      this.mdt.postNUI("createCall", formData);
    }

    this.closeCreateCallModal();
    this.clearCallDraft();
  }

  collectFormData() {
    return {
      service: document.getElementById("call-service").value,
      type: document.getElementById("call-type").value,
      priority: parseInt(document.getElementById("call-priority").value),
      requiredUnits: parseInt(document.getElementById("call-units").value),
      location: document.getElementById("call-location").value,
      coords: {
        x: parseFloat(document.getElementById("call-coord-x").value) || 0,
        y: parseFloat(document.getElementById("call-coord-y").value) || 0,
        z: parseFloat(document.getElementById("call-coord-z").value) || 0,
      },
      description: document.getElementById("call-description").value,
      reporter: document.getElementById("call-reporter").value,
      contact: document.getElementById("call-contact").value,
      autoAssign: document.getElementById("call-auto-assign").checked,
      highPriority: document.getElementById("call-high-priority").checked,
      notes: document.getElementById("call-notes").value,
    };
  }

  validateCallData(data) {
    const errors = [];

    if (!data.service) errors.push("Service ist erforderlich");
    if (!data.type) errors.push("Einsatztyp ist erforderlich");
    if (!data.description.trim()) errors.push("Beschreibung ist erforderlich");
    if (data.coords.x === 0 && data.coords.y === 0)
      errors.push("Koordinaten sind erforderlich");

    if (errors.length > 0) {
      this.mdt.showNotification("Fehler: " + errors.join(", "), "error");
      return false;
    }

    return true;
  }

  generateCallId(service) {
    const prefixes = { fire: "FW", police: "POL", ems: "RD" };
    const prefix = prefixes[service] || "FL";
    const number = Math.floor(Math.random() * 9999)
      .toString()
      .padStart(4, "0");
    const time = new Date()
      .toLocaleTimeString("de-DE", {
        hour: "2-digit",
        minute: "2-digit",
      })
      .replace(":", "");

    return `${prefix}-${time}-${number}`;
  }

  saveCallDraft() {
    const formData = this.collectFormData();
    localStorage.setItem("fl-call-draft", JSON.stringify(formData));
    this.mdt.showNotification("Entwurf gespeichert", "success");
  }

  loadCallDraft() {
    const draft = localStorage.getItem("fl-call-draft");
    if (draft) {
      try {
        const data = JSON.parse(draft);
        this.populateFormWithData(data);
        this.mdt.showNotification("Entwurf geladen", "info");
      } catch (error) {
        console.error("Error loading draft:", error);
      }
    }
  }

  clearCallDraft() {
    localStorage.removeItem("fl-call-draft");
  }

  closeCreateCallModal() {
    const modal = document.getElementById("call-create-modal");
    if (modal) {
      modal.remove();
    }
  }

  // ================================
  // 🔄 CALL MANAGEMENT ACTIONS
  // ================================

  assignToCall(callId) {
    const call = this.mdt.calls[callId];
    if (!call) return;

    this.mdt.postNUI("assignCall", { callId });
    this.mdt.showNotification(`Zu Einsatz ${callId} zugewiesen`, "success");
  }

  unassignFromCall(callId) {
    this.mdt.postNUI("unassignCall", { callId });
    this.mdt.showNotification(`Von Einsatz ${callId} entfernt`, "info");
  }

  setCallWaypoint(callId) {
    const call = this.mdt.calls[callId];
    if (!call || !call.coords) return;

    this.mdt.postNUI("setWaypoint", { coords: call.coords });
    this.mdt.showNotification("GPS-Route gesetzt", "success");
  }

  requestBackup(callId) {
    const call = this.mdt.calls[callId];
    if (!call) return;

    const modal = this.createBackupRequestModal(call);
    document.body.appendChild(modal);
    modal.style.display = "block";
  }

  createBackupRequestModal(call) {
    const modal = document.createElement("div");
    modal.className = "modal backup-request-modal";
    modal.innerHTML = `
      <div class="modal-content">
        <div class="modal-header">
          <h2>Verstärkung anfordern</h2>
          <button class="modal-close" onclick="this.closest('.modal').remove()">×</button>
        </div>
        <div class="modal-body">
          <p>Verstärkung für Einsatz: <strong>${call.id}</strong></p>
          <div class="form-group">
            <label>Anzahl zusätzlicher Einheiten:</label>
            <input type="number" id="backup-units" min="1" max="5" value="1">
          </div>
          <div class="form-group">
            <label>Grund:</label>
            <select id="backup-reason">
              <option value="additional_support">Zusätzliche Unterstützung</option>
              <option value="escalation">Eskalation</option>
              <option value="specialized_unit">Spezialeinheit benötigt</option>
              <option value="officer_safety">Beamtensicherheit</option>
            </select>
          </div>
          <div class="form-group">
            <label>Zusätzliche Informationen:</label>
            <textarea id="backup-notes" rows="3"></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" onclick="this.closest('.modal').remove()">Abbrechen</button>
          <button class="btn btn-primary" onclick="callSystem.submitBackupRequest('${call.id}')">
            Verstärkung anfordern
          </button>
        </div>
      </div>
    `;
    return modal;
  }

  submitBackupRequest(callId) {
    const units = document.getElementById("backup-units").value;
    const reason = document.getElementById("backup-reason").value;
    const notes = document.getElementById("backup-notes").value;

    this.mdt.postNUI("requestBackup", {
      callId,
      additionalUnits: parseInt(units),
      reason,
      notes,
    });

    document.querySelector(".backup-request-modal").remove();
    this.mdt.showNotification("Verstärkung angefordert", "success");
  }

  updateCallStatus(callId) {
    const call = this.mdt.calls[callId];
    if (!call) return;

    const newStatus = this.promptForStatusUpdate(call.status);
    if (newStatus && newStatus !== call.status) {
      this.mdt.postNUI("updateCallStatus", {
        callId,
        status: newStatus,
        timestamp: Math.floor(Date.now() / 1000),
      });
    }
  }

  promptForStatusUpdate(currentStatus) {
    const statusOptions = {
      pending: "Ausstehend",
      assigned: "Zugewiesen",
      en_route: "Anfahrt",
      on_scene: "Vor Ort",
      active: "Aktiv",
      completed: "Abgeschlossen",
    };

    const options = Object.entries(statusOptions)
      .filter(([key]) => key !== currentStatus)
      .map(([key, label]) => `${key}: ${label}`)
      .join("\n");

    const selected = prompt(`Neuer Status wählen:\n${options}\n\nEingabe:`);
    return selected && statusOptions[selected] ? selected : null;
  }

  completeCall(callId) {
    const call = this.mdt.calls[callId];
    if (!call) return;

    const notes = prompt("Abschlussbericht (optional):");

    this.mdt.postNUI("completeCall", {
      callId,
      notes: notes || "",
      completedBy: this.mdt.playerData.source,
      completedAt: Math.floor(Date.now() / 1000),
    });

    this.mdt.showNotification(`Einsatz ${callId} abgeschlossen`, "success");
  }

  // ================================
  // 🎛️ FILTERING & SORTING
  // ================================

  filterAndSortCalls(calls) {
    let filtered = [...calls];

    // Apply filters
    filtered = filtered.filter((call) => {
      if (
        this.callFilters.status !== "all" &&
        call.status !== this.callFilters.status
      ) {
        return false;
      }
      if (
        this.callFilters.priority !== "all" &&
        call.priority.toString() !== this.callFilters.priority
      ) {
        return false;
      }
      if (
        this.callFilters.service !== "all" &&
        call.service !== this.callFilters.service
      ) {
        return false;
      }
      return true;
    });

    // Apply sorting
    filtered.sort((a, b) => {
      let comparison = 0;

      switch (this.sortBy) {
        case "priority":
          comparison = a.priority - b.priority;
          break;
        case "time":
          comparison = (b.created || 0) - (a.created || 0);
          break;
        case "distance":
          const distA = this.calculateDistance(a.coords);
          const distB = this.calculateDistance(b.coords);
          comparison = distA - distB;
          break;
        case "status":
          comparison = (a.status || "").localeCompare(b.status || "");
          break;
      }

      return this.sortOrder === "desc" ? -comparison : comparison;
    });

    return filtered;
  }

  searchCalls(query) {
    if (!query.trim()) {
      this.renderEnhancedCalls();
      return;
    }

    const searchTerms = query.toLowerCase().split(" ");
    const callCards = document.querySelectorAll(".call-card");

    callCards.forEach((card) => {
      const callId = card.dataset.callId;
      const call = this.mdt.calls[callId];

      if (!call) return;

      const searchText = [
        call.id,
        call.type,
        call.description,
        call.location,
        call.reporter,
      ]
        .join(" ")
        .toLowerCase();

      const matches = searchTerms.every((term) => searchText.includes(term));
      card.style.display = matches ? "block" : "none";
    });
  }

  setSortOrder(sortBy) {
    if (this.sortBy === sortBy) {
      this.sortOrder = this.sortOrder === "asc" ? "desc" : "asc";
    } else {
      this.sortBy = sortBy;
      this.sortOrder = "asc";
    }

    this.renderEnhancedCalls();
  }

  // ================================
  // 🔢 UTILITY CALCULATIONS
  // ================================

  calculateTimeElapsed(timestamp) {
    if (!timestamp) return "Unbekannt";

    const now = Date.now() / 1000;
    const elapsed = now - timestamp;

    if (elapsed < 60) return "Gerade eben";
    if (elapsed < 3600) return `${Math.floor(elapsed / 60)}m`;
    if (elapsed < 86400) return `${Math.floor(elapsed / 3600)}h`;
    return `${Math.floor(elapsed / 86400)}d`;
  }

  calculateDistance(coords) {
    if (!coords || !this.mdt.playerData.coords) return null;

    // Simplified distance calculation
    const dx = coords.x - (this.mdt.playerData.coords.x || 0);
    const dy = coords.y - (this.mdt.playerData.coords.y || 0);
    const distance = Math.sqrt(dx * dx + dy * dy);

    if (distance < 1000) {
      return `${Math.round(distance)}m`;
    } else {
      return `${(distance / 1000).toFixed(1)}km`;
    }
  }

  calculateUrgencyLevel(call) {
    const now = Date.now() / 1000;
    const age = now - (call.created || now);
    const maxTime = this.getExpectedCallDuration(call.type);

    if (call.priority === 1 && age > 300) return "urgent"; // P1 over 5 minutes
    if (call.priority === 2 && age > 900) return "urgent"; // P2 over 15 minutes
    if (age > maxTime) return "overdue";

    return "normal";
  }

  getExpectedCallDuration(type) {
    const durations = {
      heart_attack: 1200, // 20 minutes
      structure_fire: 3600, // 1 hour
      robbery: 1800, // 30 minutes
      traffic_stop: 600, // 10 minutes
      car_accident: 2400, // 40 minutes
    };

    return durations[type] || 1800; // Default 30 minutes
  }

  updateCallTimers() {
    const timeElements = document.querySelectorAll(
      ".time-elapsed[data-created]"
    );
    timeElements.forEach((element) => {
      const created = parseInt(element.dataset.created);
      element.textContent = this.calculateTimeElapsed(created);
    });
  }

  updateCallBadges(calls) {
    const total = calls.length;
    const priority1 = calls.filter((c) => c.priority === 1).length;
    const assigned = calls.filter(
      (c) => c.assigned && c.assigned.includes(this.mdt.playerData.source)
    ).length;

    this.mdt.setElementContent("calls-badge", total.toString());

    // Update navigation badges if they exist
    const nav = document.querySelector('[data-tab="calls"]');
    if (nav) {
      nav.classList.toggle("has-urgent", priority1 > 0);
      nav.classList.toggle("has-assigned", assigned > 0);
    }
  }

  formatTime(timestamp) {
    return new Date(timestamp * 1000).toLocaleTimeString("de-DE", {
      hour: "2-digit",
      minute: "2-digit",
    });
  }

  // ================================
  // 📊 CALL HISTORY & ANALYTICS
  // ================================

  showCallHistory() {
    const modal = this.createCallHistoryModal();
    document.body.appendChild(modal);
    modal.style.display = "block";
  }

  createCallHistoryModal() {
    const modal = document.createElement("div");
    modal.className = "modal call-history-modal";
    modal.innerHTML = `
      <div class="modal-content large">
        <div class="modal-header">
          <h2>Einsatzverlauf</h2>
          <button class="modal-close" onclick="this.closest('.modal').remove()">×</button>
        </div>
        <div class="modal-body">
          <div class="history-filters">
            <select id="history-period">
              <option value="today">Heute</option>
              <option value="week">Diese Woche</option>
              <option value="month">Dieser Monat</option>
            </select>
            <select id="history-service">
              <option value="all">Alle Services</option>
              <option value="fire">Feuerwehr</option>
              <option value="police">Polizei</option>
              <option value="ems">Rettungsdienst</option>
            </select>
          </div>
          <div class="history-stats">
            <div class="stat-card">
              <h3 id="total-calls-stat">0</h3>
              <p>Gesamt Einsätze</p>
            </div>
            <div class="stat-card">
              <h3 id="completed-calls-stat">0</h3>
              <p>Abgeschlossen</p>
            </div>
            <div class="stat-card">
              <h3 id="avg-time-stat">0m</h3>
              <p>Ø Bearbeitungszeit</p>
            </div>
          </div>
          <div class="history-list" id="history-list">
            <!-- Call history items will be loaded here -->
          </div>
        </div>
      </div>
    `;
    return modal;
  }
}

// Initialize Call System when MDT is ready
window.callSystem = null;

// Extend the original MDT class
if (window.flMDT) {
  window.callSystem = new CallSystem(window.flMDT);

  // Override the renderCalls method to use enhanced version
  window.flMDT.renderCalls = function () {
    if (window.callSystem) {
      window.callSystem.renderEnhancedCalls();
    }
  };

  // Add call system methods to MDT
  window.flMDT.openCreateCallModal = () =>
    window.callSystem.openCreateCallModal();
}

console.log("🚨 Enhanced Call System loaded successfully!");
