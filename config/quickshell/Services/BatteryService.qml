pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property var batteries: UPower.devices.values.filter(dev => dev.isLaptopBattery)
    readonly property UPowerDevice device: batteries[0] || null
    readonly property bool available: batteries.length > 0

    readonly property real percentage: {
        if (!available) return 0
        var validBatteries = batteries.filter(b => b.ready && b.percentage >= 0)
        if (validBatteries.length === 0) return 0
        var avg = validBatteries.reduce((sum, b) => sum + b.percentage, 0) / validBatteries.length
        return Math.round(avg * 100)
    }

    readonly property bool charging: available && batteries.some(b => b.state === UPowerDeviceState.Charging)
    readonly property bool discharging: available && batteries.some(b => b.state === UPowerDeviceState.Discharging)
    readonly property bool fullyCharged: available && batteries.every(b => b.state === UPowerDeviceState.FullyCharged)
    readonly property bool pluggedIn: !UPower.onBattery
    readonly property bool isLow: available && percentage <= 20

    readonly property real changeRate: {
        if (!available) return 0
        return batteries.reduce((sum, b) => sum + b.changeRate, 0)
    }

    readonly property real batteryEnergy: {
        if (!available) return 0
        return batteries.reduce((sum, b) => sum + b.energy, 0)
    }

    readonly property real batteryCapacity: {
        if (!available) return 0
        return batteries.reduce((sum, b) => sum + b.energyCapacity, 0)
    }

    readonly property real health: {
        if (!available) return 0
        var validBatteries = batteries.filter(b => b.healthPercentage > 0)
        if (validBatteries.length === 0) return 0
        var avg = validBatteries.reduce((sum, b) => sum + b.healthPercentage, 0) / validBatteries.length
        return Math.round(avg)
    }

    readonly property string icon: getBatteryIcon()

    function getBatteryIcon() {
        if (!available) return "\uf06a"

        if (charging || pluggedIn) {
            if (percentage >= 95) return "\udb80\udc85"
            if (percentage >= 85) return "\udb80\udc8a"
            if (percentage >= 75) return "\udb82\udc9e"
            if (percentage >= 65) return "\udb80\udc89"
            if (percentage >= 55) return "\udb82\udc9d"
            if (percentage >= 45) return "\udb80\udc88"
            if (percentage >= 35) return "\udb80\udc87"
            if (percentage >= 25) return "\udb80\udc86"
            if (percentage >= 15) return "\udb82\udc9c"
            if (percentage >= 5)  return "\udb82\udc9f"
            return "\udb82\udc9f"
        }

        if (percentage >= 95) return "\udb80\udc79"
        if (percentage >= 85) return "\udb80\udc82"
        if (percentage >= 75) return "\udb80\udc81"
        if (percentage >= 65) return "\udb80\udc80"
        if (percentage >= 55) return "\udb80\udc7e"
        if (percentage >= 45) return "\udb80\udc7d"
        if (percentage >= 35) return "\udb80\udc7c"
        if (percentage >= 25) return "\udb80\udc7b"
        if (percentage >= 15) return "\udb80\udc7a"
        if (percentage >= 5)  return "\udb80\udc7a"
        return "\udb80\udc8e"
    }

    function formatTimeRemaining() {
        if (!available || changeRate <= 0) return ""

        var totalTime = charging
            ? (batteryCapacity - batteryEnergy) / changeRate
            : batteryEnergy / changeRate
        var seconds = Math.abs(totalTime * 3600)

        if (seconds <= 0 || seconds > 86400) return ""

        var hours = Math.floor(seconds / 3600)
        var minutes = Math.floor((seconds % 3600) / 60)
        return hours > 0 ? hours + "h " + minutes + "m" : minutes + "m"
    }

    function formatWattage() {
        if (!available || changeRate <= 0) return ""
        return changeRate.toFixed(1) + " W"
    }
}
