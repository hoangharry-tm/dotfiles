import QtQuick
import qs.Common

// The one material: a flat rounded fill, no gradient, grain or rim. Colour is
// reserved for state (the single accent), everything else is neutral.
//   rest     quiet neutral lift of the sheet
//   on       slightly stronger neutral; the "on" colour lives in IconBadge
//   solid    neutral near-text fill for large areas (slider level, play, meters); pair with Theme.onSolid
//   accent   flat Theme.primary, small marks only; pair with Theme.onAccent
//   aurora   alias of rest (notification cards)
//   track    track under a solid fill (always darker than it); trackInset inside a recessed well
//   recessed quiet well one level below its parent (child lists, tracks)
// Per-corner radii are Rectangle's own. Hover/press add a translucent text-colour overlay step.
Rectangle {
    id: root

    property string variant: "rest"
    property bool hovered: false
    property bool pressed: false
    // Override per use (e.g. battery warning); default comes from the variant.
    property color fillA: variant === "on" ? Theme.fillOn : variant === "accent" ? Theme.primary : variant === "solid" ? Theme.fillSolid : variant === "recessed" ? Theme.fillRecess : variant === "track" ? Theme.fillTrack : variant === "trackInset" ? Theme.fillTrackInset : Theme.tile
    property color fillB: fillA // deprecated: second gradient stop, ignored
    readonly property color wash: pressed ? Theme.tonePress : hovered ? Theme.toneHover : "transparent"

    color: Qt.tint(fillA, wash)
    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }
}
