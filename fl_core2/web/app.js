/**
 * ================================
 * 🚨 FL EMERGENCY - MDT APPLICATION
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

    this.init();
  }

  // ================================
  // 🔧 INITIALIZATION
  // ================================

  init() {
    this.setupEventListeners();
    this.setupKeyboardShortcuts();
    this.loadSettings();
    // this.startClock(); // Nur starten wenn MDT geöffnet ist

    // UI standardmäßig versteckt halten
    document.body.style.display = "none";

    console.log("🚨 FL Emergency MDT initialized (hidden)");
  }

  setupEventListeners() {
    // NUI Message Handler
    window.addEventListener("message", (event) => {
      this.handleNUIMessage(event.data);
    });

    // Tab Navigation
    document.querySelectorAll(".nav-btn").forEach((btn) => {
      btn.addEventListener("click", () => {
        this.switchTab(btn.dataset.tab);
      });
    });

    // Close Button
    document.getElementById("close-btn").addEventListener("click", () => {
      this.closeMDT();
    });

    // Refresh Button
    document.getElementById("refresh-calls").addEventListener("click", () => {
      this.refreshCalls();
    });

    // Create Call Button
    document.getElementById("create-call").addEventListener("click", () => {
      this.openCreateCallModal();
    });

    // Filters
    document.getElementById("status-filter").addEventListener("change", () => {
      this.filterCalls();
    });

    document
      .getElementById("priority-filter")
      .addEventListener("change", () => {
        this.filterCalls();
      });

    // Settings
    document
      .getElementById("sound-notifications")
      .addEventListener("change", (e) => {
        this.settings.soundNotifications = e.target.checked;
        this.saveSettings();
      });

    document.getElementById("call-alerts").addEventListener("change", (e) => {
      this.settings.callAlerts = e.target.checked;
      this.saveSettings();
    });

    document.getElementById("dark-mode").addEventListener("change", (e) => {
      this.settings.darkMode = e.target.checked;
      this.toggleDarkMode(e.target.checked);
      this.saveSettings();
    });

    document.getElementById("auto-refresh").addEventListener("change", (e) => {
      this.settings.autoRefresh = e.target.checked;
      this.saveSettings();

      if (e.target.checked) {
        this.startAutoRefresh();
      } else {
        this.stopAutoRefresh();
      }
    });

    // Modal Events
    document.querySelector(".modal-close").addEventListener("click", () => {
      this.closeModal();
    });

    document.getElementById("assign-btn").addEventListener("click", () => {
      this.assignToCall();
    });

    document.getElementById("waypoint-btn").addEventListener("click", () => {
      this.setWaypoint();
    });

    document.getElementById("complete-btn").addEventListener("click", () => {
      this.completeCall();
    });

    // Click outside modal to close
    document.getElementById("call-modal").addEventListener("click", (e) => {
      if (e.target === document.getElementById("call-modal")) {
        this.closeModal();
      }
    });
  }

  setupKeyboardShortcuts() {
    document.addEventListener("keydown", (e) => {
      if (!this.isVisible) return;

      switch (e.key) {
        case "Escape":
          this.closeMDT();
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
  // 🎮 NUI MESSAGE HANDLING
  // ================================

  handleNUIMessage(data) {
    console.log("📨 NUI Message:", data);

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
      default:
        console.warn("Unknown NUI message type:", data.type);
    }
  }

  // ================================
  // 🖥️ UI MANAGEMENT
  // ================================

  openMDT(data) {
    this.service = data.service;
    this.serviceData = data.serviceData;
    this.playerData = data.playerData;
    this.calls = data.calls || {};
    this.vehicles = data.vehicles || {};

    // Zeige UI EXPLIZIT
    document.body.style.display = "block";
    document.body.style.visibility = "visible";

    // App Container sichtbar machen
    const appContainer = document.getElementById("app");
    if (appContainer) {
      appContainer.style.display = "block";
      appContainer.style.visibility = "visible";
    }

    // Starte Clock
    this.startClock();

    // Update UI
    this.updateHeader();
    this.updateServiceColors();
    this.renderCalls();
    this.renderVehicles();
    this.updateStats();

    // Show Interface Components
    const loadingScreen = document.getElementById("loading-screen");
    const mdtInterface = document.getElementById("mdt-interface");

    if (loadingScreen) loadingScreen.style.display = "none";
    if (mdtInterface) {
      mdtInterface.style.display = "block";
      mdtInterface.style.visibility = "visible";
    }

    this.isVisible = true;

    // Start auto-refresh
    if (this.settings.autoRefresh) {
      this.startAutoRefresh();
    }

    console.log("🚨 MDT opened for service:", this.service);

    // DEBUG: Log alle wichtigen Elemente
    console.log("App Container:", appContainer);
    console.log("MDT Interface:", mdtInterface);
    console.log("Loading Screen:", loadingScreen);
  }

  closeMDT() {
    this.isVisible = false;
    this.stopAutoRefresh();

    // Hide Interface completely
    document.body.style.display = "none";

    // Send close event to client
    this.postNUI("closeUI", {});

    console.log("🚨 MDT closed");
  }

  updateHeader() {
    // Service Info
    document.getElementById("service-icon").className = this.serviceData.icon;
    document.getElementById("service-name").textContent =
      this.serviceData.label;
    document.getElementById("station-name").textContent =
      this.playerData.station || "Unbekannt";

    // Officer Info
    document.getElementById("officer-name").textContent =
      this.playerData.name || "Unbekannt";
    document.getElementById("officer-rank").textContent =
      this.playerData.rank || "Rang " + this.playerData.rankLevel;

    // Duty Status
    const dutyIcon = document.getElementById("duty-icon");
    const dutyText = document.getElementById("duty-text");

    if (this.playerData.onDuty) {
      dutyIcon.className = "fas fa-circle text-success";
      dutyText.textContent = "Im Dienst";
    } else {
      dutyIcon.className = "fas fa-circle text-danger";
      dutyText.textContent = "Außer Dienst";
    }
  }

  updateServiceColors() {
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
  }

  switchTab(tabName) {
    // Remove active class from all tabs
    document
      .querySelectorAll(".nav-btn")
      .forEach((btn) => btn.classList.remove("active"));
    document
      .querySelectorAll(".tab-content")
      .forEach((content) => content.classList.remove("active"));

    // Add active class to selected tab
    document.querySelector(`[data-tab="${tabName}"]`).classList.add("active");
    document.getElementById(`${tabName}-tab`).classList.add("active");

    this.currentTab = tabName;

    // Load tab-specific content
    this.loadTabContent(tabName);
  }

  loadTabContent(tabName) {
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
  }

  // ================================
  // 🚨 CALLS MANAGEMENT
  // ================================

  renderCalls() {
    const container = document.getElementById("calls-container");
    const calls = Object.values(this.calls);

    if (calls.length === 0) {
      container.innerHTML = `
              <div class="no-calls">
                  <i class="fas fa-check-circle"></i>
                  <h3>Keine aktiven Einsätze</h3>
                  <p>Momentan sind keine Einsätze verfügbar</p>
              </div>
          `;
      return;
    }

    // Sort calls by priority and time
    calls.sort((a, b) => {
      if (a.priority !== b.priority) {
        return a.priority - b.priority; // Higher priority first
      }
      return b.created - a.created; // Newer first
    });

    container.innerHTML = calls
      .map((call) => this.renderCallCard(call))
      .join("");

    // Update badge
    document.getElementById("calls-badge").textContent = calls.length;
  }

  renderCallCard(call) {
    const priorityClass = this.getPriorityClass(call.priority);
    const statusClass = this.getStatusClass(call.status);
    const timeElapsed = this.formatTimeElapsed(call.created);
    const isAssigned =
      call.assigned && call.assigned.includes(this.playerData.source);

    return `
          <div class="call-card ${priorityClass}" data-call-id="${call.id}">
              <div class="call-header">
                  <div class="call-id">${call.id}</div>
                  <div class="call-priority priority-${call.priority}">
                      <i class="fas fa-exclamation-triangle"></i>
                      P${call.priority}
                  </div>
                  <div class="call-status status-${call.status}">
                      ${this.getStatusIcon(call.status)}
                      ${this.getStatusText(call.status)}
                  </div>
              </div>
              
              <div class="call-body">
                  <div class="call-type">
                      <i class="fas fa-tag"></i>
                      ${call.type}
                  </div>
                  <div class="call-description">
                      ${call.description || "Keine Beschreibung verfügbar"}
                  </div>
                  <div class="call-meta">
                      <div class="call-time">
                          <i class="fas fa-clock"></i>
                          ${timeElapsed}
                      </div>
                      <div class="call-units">
                          <i class="fas fa-users"></i>
                          ${call.assigned ? call.assigned.length : 0}/${
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
  }

  updateCalls(calls) {
    this.calls = calls;
    if (this.currentTab === "calls") {
      this.renderCalls();
    }
  }

  filterCalls() {
    const statusFilter = document.getElementById("status-filter").value;
    const priorityFilter = document.getElementById("priority-filter").value;

    const callCards = document.querySelectorAll(".call-card");

    callCards.forEach((card) => {
      const callId = card.dataset.callId;
      const call = this.calls[callId];

      if (!call) return;

      let showCard = true;

      // Status filter
      if (statusFilter !== "all" && call.status !== statusFilter) {
        showCard = false;
      }

      // Priority filter
      if (
        priorityFilter !== "all" &&
        call.priority.toString() !== priorityFilter
      ) {
        showCard = false;
      }

      card.style.display = showCard ? "block" : "none";
    });
  }

  // ================================
  // 🚗 VEHICLES MANAGEMENT
  // ================================

  renderVehicles() {
    const container = document.querySelector(".vehicles-grid");

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
  }

  renderVehicleCard(id, vehicle) {
    return `
          <div class="vehicle-card" data-vehicle-id="${id}">
              <div class="vehicle-image">
                  <i class="fas fa-car"></i>
              </div>
              <div class="vehicle-info">
                  <h4>${vehicle.label}</h4>
                  <p class="vehicle-plate">${vehicle.plate}</p>
                  <div class="vehicle-status">
                      <span class="status-indicator ${vehicle.status}"></span>
                      ${vehicle.status}
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
  }

  // ================================
  // 📊 STATISTICS & REPORTS
  // ================================

  renderReports() {
    this.updateStats();
  }

  updateStats() {
    // Calculate statistics
    const totalCalls = Object.keys(this.calls).length;
    const completedCalls = Object.values(this.calls).filter(
      (call) => call.status === "completed"
    );
    const avgResponseTime = this.calculateAverageResponseTime();
    const activeOfficers = this.countActiveOfficers();

    // Update stat cards
    document.getElementById("total-calls").textContent = totalCalls;
    document.getElementById("avg-response").textContent = avgResponseTime;
    document.getElementById("active-officers").textContent = activeOfficers;
  }

  calculateAverageResponseTime() {
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
  }

  countActiveOfficers() {
    // This would need to be provided by the server
    return this.playerData.activeOfficers || 0;
  }

  // ================================
  // 🎛️ MODAL MANAGEMENT
  // ================================

  openCallDetails(callId) {
    const call = this.calls[callId];
    if (!call) return;

    // Fill modal data
    document.getElementById("call-id").textContent = call.id;
    document.getElementById("call-type").textContent = call.type;
    document.getElementById(
      "call-priority"
    ).textContent = `Priorität ${call.priority}`;
    document.getElementById("call-status").textContent = this.getStatusText(
      call.status
    );
    document.getElementById("call-description").textContent =
      call.description || "Keine Beschreibung";

    // Assigned units
    const assignedUnits = document.getElementById("assigned-units");
    if (call.assigned && call.assigned.length > 0) {
      assignedUnits.innerHTML = call.assigned
        .map((unit) => `<span class="assigned-unit">${unit}</span>`)
        .join("");
    } else {
      assignedUnits.innerHTML =
        '<span class="no-units">Keine Einheiten zugewiesen</span>';
    }

    // Update buttons
    const isAssigned =
      call.assigned && call.assigned.includes(this.playerData.source);
    const assignBtn = document.getElementById("assign-btn");

    if (isAssigned) {
      assignBtn.innerHTML = '<i class="fas fa-user-minus"></i> Entfernen';
      assignBtn.className = "btn btn-danger";
    } else {
      assignBtn.innerHTML = '<i class="fas fa-user-plus"></i> Zuweisen';
      assignBtn.className = "btn btn-primary";
    }

    // Store current call for actions
    this.currentCall = call;

    // Show modal
    document.getElementById("call-modal").style.display = "block";
  }

  closeModal() {
    document.getElementById("call-modal").style.display = "none";
    this.currentCall = null;
  }

  // ================================
  // 🎮 ACTIONS
  // ================================

  assignToCall(callId) {
    if (!callId && this.currentCall) {
      callId = this.currentCall.id;
    }

    this.postNUI("assignCall", { callId });
    this.closeModal();
  }

  unassignFromCall(callId) {
    this.postNUI("unassignCall", { callId });
    this.closeModal();
  }

  setCallWaypoint(callId) {
    const call = this.calls[callId] || this.currentCall;
    if (!call) return;

    this.postNUI("setWaypoint", {
      coords: call.coords,
    });

    this.showNotification("GPS-Route gesetzt", "success");
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
    this.showNotification("Einsätze aktualisiert", "info");
  }

  locateVehicle(vehicleId) {
    this.postNUI("locateVehicle", { vehicleId });
  }

  returnVehicle(vehicleId) {
    if (confirm("Fahrzeug wirklich zurückbringen?")) {
      this.postNUI("returnVehicle", { vehicleId });
    }
  }

  // ================================
  // 🔧 UTILITY FUNCTIONS
  // ================================

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
    const now = Date.now() / 1000;
    const elapsed = now - timestamp;

    if (elapsed < 60) return "Gerade eben";
    if (elapsed < 3600) return `${Math.floor(elapsed / 60)}m`;
    if (elapsed < 86400) return `${Math.floor(elapsed / 3600)}h`;
    return `${Math.floor(elapsed / 86400)}d`;
  }

  // ================================
  // 🔄 AUTO-REFRESH
  // ================================

  startAutoRefresh() {
    if (this.updateInterval) return;

    this.updateInterval = setInterval(() => {
      if (this.isVisible) {
        this.postNUI("requestUpdate", {});
      }
    }, 5000); // Update every 5 seconds
  }

  stopAutoRefresh() {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
      this.updateInterval = null;
    }
  }

  // ================================
  // 🕐 CLOCK
  // ================================

  startClock() {
    setInterval(() => {
      const now = new Date();
      document.getElementById("current-time").textContent =
        now.toLocaleTimeString("de-DE", {
          hour: "2-digit",
          minute: "2-digit",
          second: "2-digit",
        });
    }, 1000);
  }

  // ================================
  // 🎨 THEMING
  // ================================

  toggleDarkMode(enabled) {
    document.body.classList.toggle("dark-mode", enabled);
  }

  // ================================
  // 💾 SETTINGS
  // ================================

  loadSettings() {
    const saved = localStorage.getItem("fl-mdt-settings");
    if (saved) {
      this.settings = { ...this.settings, ...JSON.parse(saved) };
      this.applySettings();
    }
  }

  saveSettings() {
    localStorage.setItem("fl-mdt-settings", JSON.stringify(this.settings));
  }

  applySettings() {
    document.getElementById("sound-notifications").checked =
      this.settings.soundNotifications;
    document.getElementById("call-alerts").checked = this.settings.callAlerts;
    document.getElementById("dark-mode").checked = this.settings.darkMode;
    document.getElementById("auto-refresh").checked = this.settings.autoRefresh;

    this.toggleDarkMode(this.settings.darkMode);
  }

  // ================================
  // 🔊 NOTIFICATIONS
  // ================================

  showNotification(message, type = "info") {
    // Create notification element
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
          <span>${message}</span>
      `;

    // Add to body
    document.body.appendChild(notification);

    // Auto-remove after 3 seconds
    setTimeout(() => {
      notification.remove();
    }, 3000);

    // Play sound if enabled
    if (this.settings.soundNotifications) {
      this.playSound(type);
    }
  }

  playSound(type) {
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
  }

  // ================================
  // 📡 NUI COMMUNICATION
  // ================================

  postNUI(type, data) {
    fetch(`https://${GetParentResourceName()}/${type}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data),
    }).catch((error) => {
      console.error("NUI Error:", error);
    });
  }

  // ================================
  // 🎮 EVENT HANDLERS
  // ================================

  handleCallCreated(call) {
    this.calls[call.id] = call;

    if (this.currentTab === "calls") {
      this.renderCalls();
    }

    if (this.settings.callAlerts) {
      this.showNotification(`Neuer Einsatz: ${call.type}`, "error");
    }
  }

  handleCallUpdated(call) {
    this.calls[call.id] = call;

    if (this.currentTab === "calls") {
      this.renderCalls();
    }
  }

  handleCallCompleted(call) {
    delete this.calls[call.id];

    if (this.currentTab === "calls") {
      this.renderCalls();
    }

    this.showNotification(`Einsatz ${call.id} abgeschlossen`, "success");
  }
}

// ================================
// 🚀 INITIALIZE APPLICATION
// ================================

const flMDT = new FlashingLightsMDT();
window.flMDT = flMDT;

// Helper function for resource name
function GetParentResourceName() {
  return "fl_emergency";
}
