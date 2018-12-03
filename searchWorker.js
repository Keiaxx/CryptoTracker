WorkerScript.onMessage = function(msg) {
    if(msg.action === "filterpairs"){
        var i;

        msg.model.clear();

        for (i = 0; i < msg.originalModel.count; i++) {
             var symbol = msg.originalModel.get(i)
             if(fuzzysearch(String(msg.search).toUpperCase(),String(symbol.symbol).toUpperCase())){

                msg.model.append(symbol);
             }
        }

        msg.model.sync();

        WorkerScript.sendMessage({action: "filterpairsdone"})

    }
}

function fuzzysearch (needle, haystack) {
    //  var hlen = haystack.length;
    //  var nlen = needle.length;
    //  if (nlen > hlen) {
    //    return false;
    //  }
    //  if (nlen === hlen) {
    //    return needle === haystack;
    //  }
    //  outer: for (var i = 0, j = 0; i < nlen; i++) {
    //    var nch = needle.charCodeAt(i);
    //    while (j < hlen) {
    //      if (haystack.charCodeAt(j++) === nch) {
    //        continue outer;
    //      }
    //    }
    //    return false;
    //  }
    //  return true;

    return haystack.indexOf(needle) !== -1;

}
