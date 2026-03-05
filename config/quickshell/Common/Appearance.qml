pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property int barHeight: 27

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 12
    readonly property int fontWeight: Font.Bold

    readonly property QtObject rounding: QtObject {
        readonly property int small: 6
        readonly property int normal: 10
        readonly property int large: 16
        readonly property int full: 9999
    }

    readonly property QtObject spacing: QtObject {
        readonly property int xs: 4
        readonly property int s: 6
        readonly property int m: 8
        readonly property int l: 12
        readonly property int xl: 16
    }

    readonly property QtObject pill: QtObject {
        readonly property int radius: 8
        readonly property int horizontalPadding: 6
        readonly property int verticalMargin: 3
        readonly property int spacing: 4
    }

    readonly property QtObject anim: QtObject {
        readonly property int quick: 150
        readonly property int normal: 250
        readonly property int slow: 400
    }

    readonly property QtObject popout: QtObject {
        readonly property int radius: 12
        readonly property int gap: 8
        readonly property int contentMargin: 16
        readonly property int ccWidth: 550
        readonly property int ncWidth: 380
    }
}
