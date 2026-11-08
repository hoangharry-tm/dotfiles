import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// Why Backup is here (the parent row has the title and the time): the last
// run failed, or the last success is older than BackupStatus.staleDays.
Section {
    Label {
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        color: BackupStatus.ok ? Theme.textMuted : Theme.error
        font.pixelSize: Theme.textSm
        text: BackupStatus.ok ? "No successful backup in over " + BackupStatus.staleDays + " days." : "The last run failed. Last success: " + BackupStatus.ago(BackupStatus.last) + "."
    }
}
