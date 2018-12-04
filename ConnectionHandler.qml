import QtQuick 2.9
import QtWebSockets 1.0

Component {

    property var model;
    property string wsbase: "wss://stream.binance.com:9443/stream?streams="

    ListModel{
        id: symbolModel
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

}
