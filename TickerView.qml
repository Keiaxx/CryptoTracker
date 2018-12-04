import QtQuick 2.9
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.3

Rectangle {
    visible: false
    id: tickerView


    color: "transparent"

    property alias model: _priceListView.model

    Component {
        id: contactDelegate

        Rectangle {
            width: _priceListView.width

            color: {
                if(index % 2 === 0){
                    Material.color(baseColor, Material.Shade100)
                }else{
                    Material.color(baseColor, Material.Shade200)
                }
            }

            height: 30

            Row{
                anchors.fill: parent
                anchors.margins: 3

                id: priceInfo

                spacing: 10

                Text { anchors.verticalCenter: parent.verticalCenter; text: symbol.toUpperCase(); font.pixelSize: 24 }
                Text { anchors.verticalCenter: parent.verticalCenter; text: tickerData.c; font.pixelSize: 18 }

                Column{
                    Text{
                        font.pixelSize: 10
                        text: tickerData.v
                    }
                    Text{
                        font.pixelSize: 10
                        text: tickerData.P
                    }
                }
            }
        }
    }

    ListView {
        clip: true
        id: _priceListView
        anchors.fill: parent
        delegate: contactDelegate
        highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
        focus: true
    }
}
