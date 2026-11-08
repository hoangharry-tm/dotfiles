import QtQuick
import qs.Common
import qs.Widgets

// Widgets/Segmented sized by its option count: `segmentWidth` each, so every
// choice in Settings has the same rhythm.
Segmented {
    property int segmentWidth: Theme.controlXl + Theme.spaceXl

    implicitWidth: segmentWidth * model.length + Theme.spaceXs * 2
}
