import QtQuick 2.4

Rectangle {
    id: root
    width: parent.width
    color: "#0099d6" // just random one

    property QtObject container

    // extra properties, maybe some signals

    MouseArea {
        id: titleBarMouseRegion
        property var clickPos
        anchors.fill: parent
        onPressed: {
            clickPos = { x: mouse.x, y: mouse.y }
        }
        onPositionChanged: {
            container.x = mousePosition.cursorPos().x - clickPos.x
            container.y = mousePosition.cursorPos().y - clickPos.y
        }
    }
}
