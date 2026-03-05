pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var apps: []
    property var filteredApps: []
    property string searchQuery: ""
    property bool ready: false

    Component.onCompleted: {
        loadUsageData()
        refreshApps()
    }

    // Refresh when desktop entries change
    Connections {
        target: DesktopEntries
        function onApplicationsChanged() {
            refreshApps()
        }
    }

    function refreshApps() {
        var allApps = []

        // Get all applications from DesktopEntries
        var entries = DesktopEntries.applications.values
        
        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i]
            
            // Skip hidden or terminal apps
            if (entry.noDisplay || entry.terminal) continue
            
            // Get the name (handle localization)
            var name = entry.name
            if (!name) continue
            
            allApps.push({
                id: entry.id,
                name: name,
                genericName: entry.genericName || "",
                comment: entry.comment || "",
                exec: entry.exec || "",
                icon: entry.icon || "",
                entry: entry  // Keep reference to original entry for launching
            })
        }
        
        // Sort alphabetically by name
        allApps.sort(function(a, b) {
            return a.name.localeCompare(b.name)
        })
        
        apps = allApps
        // Sort by frecency initially
        filteredApps = sortByFrecency(allApps)
        ready = true

        console.log("AppLauncher: Loaded " + allApps.length + " applications")
    }

    // Frecency tracking (frequency + recency)
    property var usageData: ({})  // Map of app.id -> {count, lastUsed}
    property string usageFile: Quickshell.env("HOME") + "/.config/quickshell/launcher_usage.json"

    function loadUsageData() {
        try {
            var filePath = Quickshell.env("HOME") + "/.config/quickshell/launcher_usage.json"
            var file = Quickshell.fileView(filePath)
            if (file && file.loaded) {
                var content = file.text()
                if (content) {
                    usageData = JSON.parse(content)
                }
            }
        } catch (e) {
            console.log("Could not load usage data: " + e)
            usageData = {}
        }
    }

    function saveUsageData() {
        try {
            // Use Process to write file since Quickshell doesn't have direct file write API
            var json = JSON.stringify(usageData)
            saveProcess.command = ["bash", "-c", "echo '" + json.replace(/'/g, "'\"'\"'") + "' > " + usageFile]
            saveProcess.running = true
        } catch (e) {
            console.log("Could not save usage data: " + e)
        }
    }

    Process {
        id: saveProcess
    }

    function calculateFrecencyScore(appId) {
        var data = usageData[appId]
        if (!data) return 0

        var now = Date.now()
        var daysSinceLastUse = (now - data.lastUsed) / (1000 * 60 * 60 * 24)
        var frequency = data.count || 1

        // Frecency formula: frequency / (days since last use + 1)
        // This gives higher scores to frequently used and recently used apps
        return frequency / (daysSinceLastUse + 1)
    }

    function sortByFrecency(appList) {
        return appList.slice().sort(function(a, b) {
            var scoreA = calculateFrecencyScore(a.id)
            var scoreB = calculateFrecencyScore(b.id)
            return scoreB - scoreA  // Higher score first
        })
    }

    function filterApps(query) {
        searchQuery = query.toLowerCase().trim()
        if (searchQuery === "") {
            // Sort by frecency when no search query
            filteredApps = sortByFrecency(apps)
        } else {
            var filtered = apps.filter(function(app) {
                return app.name.toLowerCase().includes(searchQuery) ||
                       (app.genericName && app.genericName.toLowerCase().includes(searchQuery)) ||
                       (app.comment && app.comment.toLowerCase().includes(searchQuery))
            })
            // When searching, sort by frecency among matches
            filteredApps = sortByFrecency(filtered)
        }
    }

    function launchApp(app) {
        if (!app || !app.entry) return

        var entry = app.entry
        var cmd = entry.command
        if (!cmd || cmd.length === 0) return

        if (!usageData[app.id])
            usageData[app.id] = { count: 0, lastUsed: 0 }
        usageData[app.id].count++
        usageData[app.id].lastUsed = Date.now()
        saveUsageData()

        Quickshell.execDetached(cmd)

        ShellState.closeLauncher()
    }
}
