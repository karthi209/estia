import QtQuick
import org.kde.plasma.plasma5support as Support

QtObject {
    id: root
    readonly property string command: "kscreen-doctor -j"
    property var outputs: []
    property bool loading: false
    property string error: ""

    function refresh() {
        if (loading)
            return
        loading = true
        error = ""
        executable.connectSource(command)
        timeout.restart()
    }

    function finish() {
        loading = false
        timeout.stop()
        executable.disconnectSource(command)
    }

    property Timer timeout: Timer {
        interval: 5000
        onTriggered: {
            root.outputs = []
            root.error = qsTr("Display query timed out.")
            root.finish()
        }
    }

    property Support.DataSource executable: Support.DataSource {
        engine: "executable"
        onNewData: (source, data) => {
            if (!root.loading || source !== root.command)
                return
            root.finish()
            try {
                if (data["exit code"] !== 0)
                    throw new Error("Display query failed")
                const result = JSON.parse(data.stdout)
                root.outputs = result.outputs.filter(output => output.connected)
            } catch (error) {
                root.outputs = []
                root.error = qsTr("Could not read display configuration.")
            }
        }
    }
}
