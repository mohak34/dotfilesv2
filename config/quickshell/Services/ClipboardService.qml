pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var clipboardItems: []
    property var filteredItems: []
    property string searchText: ""
    property bool ready: false
    property var fetchTime: new Date()

    Process {
        id: listProcess
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            id: listStdout
            onStreamFinished: {
                parseClipboardList(listStdout.text)
            }
        }
    }

    Process {
        id: copyProcess
        command: []
    }

    Process {
        id: deleteProcess
        command: []
    }

    Process {
        id: clearProcess
        command: ["cliphist", "wipe"]
    }

    function refresh() {
        ready = false
        fetchTime = new Date()
        listProcess.running = true
    }

    function formatTimestamp(date) {
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        var month = months[date.getMonth()]
        var day = date.getDate()
        var hours = date.getHours().toString().padStart(2, '0')
        var minutes = date.getMinutes().toString().padStart(2, '0')
        return month + " " + day + " " + hours + ":" + minutes
    }

    function parseClipboardList(output) {
        var lines = output.split("\n").filter(function(line) { return line.trim() !== "" })
        var items = []
        var currentTime = fetchTime
        
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            var parts = line.split("\t")
            if (parts.length >= 2) {
                var id = parts[0]
                var content = parts.slice(1).join("\t")
                var displayText = content
                var isImage = content.indexOf("[[ binary data ") === 0
                var imageSize = ""
                
                if (isImage) {
                    // Extract size from "[[ binary data 259 KiB png 2560x1440 ]]"
                    var match = content.match(/\[\[ binary data ([^\]]+) \]\]/)
                    if (match) {
                        imageSize = match[1]
                    }
                    displayText = "\uf03e Image"
                } else if (content.length > 100) {
                    displayText = content.substring(0, 100) + "..."
                }
                
                // All items get the same timestamp since cliphist doesn't store individual times
                // In a real implementation, you'd parse actual timestamps from cliphist if available
                var timestamp = formatTimestamp(currentTime)
                
                items.push({
                    id: id,
                    content: content,
                    displayText: displayText,
                    isImage: isImage,
                    imageSize: imageSize,
                    timestamp: timestamp,
                    index: i
                })
            }
        }
        
        clipboardItems = items
        filterItems(searchText)
        ready = true
    }

    function filterItems(query) {
        searchText = query
        if (!query || query.trim() === "") {
            filteredItems = clipboardItems
        } else {
            var lowerQuery = query.toLowerCase()
            filteredItems = clipboardItems.filter(function(item) {
                return item.content.toLowerCase().includes(lowerQuery) ||
                       item.displayText.toLowerCase().includes(lowerQuery)
            })
        }
    }

    function copyItem(itemId) {
        copyProcess.command = ["bash", "-c", "cliphist decode " + itemId + " | wl-copy"]
        copyProcess.running = true
    }

    function deleteItem(itemId) {
        deleteProcess.command = ["bash", "-c", "echo '" + itemId + "' | cliphist delete"]
        deleteProcess.running = true
        
        Qt.callLater(function() {
            refresh()
        })
    }

    function clearAll() {
        clearProcess.running = true
        
        Qt.callLater(function() {
            clipboardItems = []
            filteredItems = []
        })
    }

    Component.onCompleted: {
        refresh()
    }
}
