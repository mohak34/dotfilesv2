pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string colorsPath: Quickshell.env("HOME") + "/.config/matugen/colors.json"

    property bool matugenLoaded: false

    property color background:       "#1E1E2E"
    property color surface:          "#313244"
    property color surfaceVariant:   "#45475A"
    property color primary:          "#CBA6F7"
    property color primaryText:      "#1E1E2E"
    property color surfaceText:      "#CDD6F4"
    property color surfaceVariantText: "#BAC2DE"
    property color outline:          "#585B70"
    property color outlineVariant:   "#6C7086"
    property color error:            "#F38BA8"
    property color warning:          "#F9E2AF"
    property color info:             "#89B4FA"

    property color primaryContainer:   "#4A3F5C"
    property color secondary:         "#89B4FA"
    property color secondaryContainer: "#3D4F6F"
    property color tertiary:          "#F9E2AF"
    property color tertiaryContainer:  "#4F4835"
    property color inverseSurface:     "#CDD6F4"
    property color inverseOnSurface:   "#313244"
    property color inversePrimary:     "#A855F7"

    readonly property color primaryHover:    Qt.rgba(primary.r, primary.g, primary.b, 0.12)
    readonly property color primaryPressed: Qt.rgba(primary.r, primary.g, primary.b, 0.16)
    readonly property color primarySelected: Qt.rgba(primary.r, primary.g, primary.b, 0.30)

    readonly property color surfaceHover:    Qt.rgba(surface.r, surface.g, surface.b, 0.08)
    readonly property color surfacePressed:  Qt.rgba(surface.r, surface.g, surface.b, 0.12)
    readonly property color surfaceSelected: Qt.rgba(surface.r, surface.g, surface.b, 0.12)

    FileView {
        id: colorsFile
        path: root.colorsPath
        watchChanges: true
        onFileChanged: {
            colorsFile.reload()
            root.loadColors()
        }
        onLoaded: root.loadColors()
    }

    Component.onCompleted: {
        if (colorsFile.loaded) {
            root.loadColors()
        }
    }

    function loadColors() {
        try {
            var data = JSON.parse(colorsFile.text())
            var c = data.colors
            if (!c) return

            root.background         = c.background?.dark         ?? root.background
            root.surface            = c.surface?.dark            ?? root.surface
            root.surfaceVariant     = c.surface_variant?.dark    ?? root.surfaceVariant
            root.primary            = c.primary?.dark            ?? root.primary
            root.primaryText        = c.on_primary?.dark         ?? root.primaryText
            root.surfaceText        = c.on_surface?.dark         ?? root.surfaceText
            root.surfaceVariantText = c.on_surface_variant?.dark ?? root.surfaceVariantText
            root.outline            = c.outline?.dark            ?? root.outline
            root.outlineVariant     = c.outline_variant?.dark   ?? root.outlineVariant
            root.error              = c.error?.dark              ?? root.error
            root.warning            = c.tertiary?.dark           ?? root.warning
            root.info               = c.secondary?.dark          ?? root.info

            root.primaryContainer    = c.primary_container?.dark   ?? root.primaryContainer
            root.secondary           = c.secondary?.dark         ?? root.secondary
            root.secondaryContainer = c.secondary_container?.dark ?? root.secondaryContainer
            root.tertiary           = c.tertiary?.dark          ?? root.tertiary
            root.tertiaryContainer  = c.tertiary_container?.dark ?? root.tertiaryContainer
            root.inverseSurface     = c.inverse_surface?.dark    ?? root.inverseSurface
            root.inverseOnSurface   = c.inverse_on_surface?.dark ?? root.inverseOnSurface
            root.inversePrimary     = c.inverse_primary?.dark    ?? root.inversePrimary

            root.matugenLoaded = true
        } catch (e) {
            root.matugenLoaded = false
        }
    }

    function withAlpha(col, alpha) {
        return Qt.rgba(col.r, col.g, col.b, alpha)
    }
}
