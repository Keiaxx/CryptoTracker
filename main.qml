import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.4
import QtWebSockets 1.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import QtCharts 2.2

Window {
    id: root
    visible: true
    minimumHeight: 150
    minimumWidth: 300
    width: 300
    height: 150
    title: qsTr("Hello World")
    flags: flagset2
    property var flagset: Qt.WindowStaysOnTopHint
    property var flagset2: Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint

    opacity: slider.value

    color: "transparent"

    property var baseColor: Material.Grey

    readonly property string wsbase: "wss://stream.binance.com:9443/stream?streams="

    ListModel{
        id: priceModel
    }

    ListModel{
        id: symbolModel
    }

    ListModel{
        id: filterModel
    }

    TitleBar {
        id: titleBar
        height: 20
        container: root

        color: Material.color(baseColor, Material.Shade900)

        Row{
            anchors.left: parent.left
            height: parent.height - 2
            RoundButton {
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 2
                height: parent.height
                width: parent.height

                text: "O"

                onClicked:{
                    if(slider.visible){
                        slider.visible = false
                    }else{
                        slider.visible = true
                    }
                }
            }

            RoundButton {
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 2
                height: parent.height
                width: parent.height

                text: "$"

                onClicked:{

                }
            }

            RoundButton {
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 2
                height: parent.height
                width: parent.height

                text: "X"

                onClicked:{
                    Qt.quit()
                }
            }
        }





        Slider {
            visible: false
            id: slider
            x: 28
            y: 0
            width: 272
            height: 20
            value: 1

            from: 0.2
            to: 1
        }
    }

    property var pairs: ({})

    function canStart(){
        for(var i = 0; i < symbolModel.count; i++){


            var pair = String(symbolModel.get(i).symbol).toLowerCase()
            var selected = symbolModel.get(i).selected

            if(selected){
                return true
            }
        }

        return false
    }

    function getwsURL(pairs){
        console.log("GETURL " + pairs)
        // xlmbtc@trade/btcusdt@trade
        var pairsargs = ""
        var delimiter = "/"
        var type = "@ticker"

        priceModel.clear()

        for(var i = 0; i < symbolModel.count; i++){


            var pair = String(symbolModel.get(i).symbol).toLowerCase()
            var selected = symbolModel.get(i).selected

            if(!selected) continue;

            pairsargs += pair+type+delimiter

            console.log(pair)

            var data = {
                "e": "24hrTicker",  // Event type
                "E": 123456789,     // Event time
                "s": "Loading",      // Symbol
                "p": "Loading",      // Price change
                "P": "Loading",      // Price change percent
                "w": "Loading",      // Weighted average price
                "x": "Loading",       // Previous day's close price
                "c": "Loading",       // Current day's close price
                "Q": "Loading",          // Close trade's quantity
                "b": "Loading",       // Best bid price
                "B": "Loading",         // Best bid quantity
                "a": "Loading",      // Best ask price
                "A": "Loading",     // Best ask quantity
                "o": "Loading",      // Open price
                "h": "Loading",       // High price
                "l": "Loading",   // Low price
                "v": "Loading",     // Total traded base asset volume
                "q": "Loading",    // Total traded quote asset volume
                "O": 0,             // Statistics open time
                "C": 86400000,      // Statistics close time
                "F": 0,             // First trade ID
                "L": 18150,         // Last trade Id
                "n": 18151          // Total number of trades
            }


            priceModel.append({symbol: pair, tickerData: data })
        }

        return wsbase+pairsargs
    }



    WebSocket {
        id: secureWebSocket
        onTextMessageReceived: {
            message = JSON.parse(message)

            var payload = {symbol: String(message.stream).split("@")[0], tickerData: message.data}

            for(var i = 0; i < priceModel.count; i++){
                var symbol = priceModel.get(i).symbol

                if(symbol === payload.symbol){
                    priceModel.setProperty(i, "tickerData", payload.tickerData)
                }
            }

        }
        onStatusChanged: if (secureWebSocket.status == WebSocket.Error) {
                             console.log("Error: " + secureWebSocket.errorString)


                             reconnectTimer.start()
                         } else if (secureWebSocket.status == WebSocket.Open) {
                             console.log("Connected")
                         } else if (secureWebSocket.status == WebSocket.Closed) {
                             console.log("Error")
                         }
        active: false
    }

    Timer{
        id: reconnectTimer
        onTriggered: {

            if(secureWebSocket.status !== WebSocket.Open){
                secureWebSocket.active = false
                secureWebSocket.active = true
            }else{
                reconnectTimer.stop()
            }


        }

        interval: 1000
        repeat: true
        running: false
    }


    function getSymbols(){
        var url = "https://api.binance.com/api/v1/exchangeInfo"

        var xmlhttp = new XMLHttpRequest();


        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == XMLHttpRequest.DONE && xmlhttp.status == 200) {
                buildSymbols(xmlhttp.responseText);
            }
        }
        xmlhttp.open("GET", url, true);
        xmlhttp.send();
    }

    function buildSymbols(response) {
        var arr = JSON.parse(response);
        var symbols = arr.symbols;

        for(var i = 0; i < symbols.length; i++) {
            var symbol = symbols[i].symbol

            symbolModel.append({symbol: symbol, selected: false, realIndex: i})
        }
    }

    Rectangle {
        id: startView
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        color: "transparent"

        TextField{
            id: search
            anchors{
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: 25
            font.pixelSize: 10
            placeholderText: "Search for a pair"

            onTextChanged: {
                if(text.lenth===0){
                    symbolsListView.model = symbolModel
                    return;
                }
                worker.sendMessage({action: "filterpairs", search: text, originalModel: symbolModel, model: filterModel})
            }

        }

        GridView{
            cacheBuffer: 1000
            clip: true
            id: symbolsListView

            model: symbolModel

            cellWidth: parent.width / 4
            cellHeight: 35

            anchors{
                left: parent.left
                right: parent.right
                top: search.bottom
                bottom: bottomBar.top
            }

            delegate: symbolDelegate

            Component {
                id: symbolDelegate
                Rectangle {
                    id: item
                    anchors.margins: 3
                    width: symbolsListView.cellWidth
                    height: symbolsListView.cellHeight

                    color: Material.color(baseColor, Material.Shade300)

                    Row{
                        CheckBox
                        {
                            id: control
                            text: symbol
                            checked: true

                            Component.onCompleted: {
                                checked = symbolModel.get(realIndex).selected
                            }

                            onClicked: {
                                symbolModel.setProperty(realIndex, "selected", checked)
                            }

                            indicator: Rectangle {
                                implicitWidth: 15
                                implicitHeight: 15
                                x: control.leftPadding
                                y: parent.height / 2 - height / 2
                                border.color: control.down ? "#dark" : "#grey"

                                Rectangle {
                                    width: 10
                                    height: 10
                                    anchors.centerIn: parent
                                    color: control.down ? "#dark" : "#grey"
                                    visible: control.checked
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle{
            id: bottomBar
            color: titleBar.color
            width: parent.width
            height: titleBar.height
            anchors{
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            Row{
                anchors.margins: 5
                anchors.fill: parent
                spacing: 10
                Text {
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                    id: messageBox
                    text: qsTr("Select pairs, then press start!")

                }

                Button{
                    anchors.verticalCenter: parent.verticalCenter

                    text: "Start"
                    height: messageBox.height

                    enabled: canStart()

                    onClicked: {

                        tickerView.visible = true
                        startView.visible = false
                        secureWebSocket.url = getwsURL()
                        secureWebSocket.active = false
                        secureWebSocket.active = true
                    }
                }
            }
        }
    }

    Rectangle {
        visible: false
        id: tickerView
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        color: "transparent"

        Component {
            id: contactDelegate

            Rectangle {
                width: priceListView.width

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
            id: priceListView
            anchors.fill: parent
            model: priceModel
            delegate: contactDelegate
            highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
            focus: true
        }
    }

    Component.onCompleted: {
        getSymbols()
    }

    WorkerScript{
        id: worker
        source: "searchWorker.js"

        onMessage: {
            if(search.text.length > 0){
                symbolsListView.model = filterModel
            }else{
                symbolsListView.model = symbolModel
            }
        }
    }
}
