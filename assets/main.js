function addStatus(text){
  var date = new Date();
  statusElem = document.getElementById('status');
  statusElem.innerHTML = statusElem.innerHTML + date + ": " + text + "<br/>";
}

function ready(){
  if ("MozWebSocket" in window) {
    WebSocket = MozWebSocket;
  }

  if ("WebSocket" in window) {
    // browser supports websockets
    ws = new WebSocket("ws://localhost:8080/websocket");

    ws.onopen = function() {
      addStatus("websocket connected!");
      ws.send("hello server!");
      addStatus("sent message to server: 'hello server!'");
    };

    ws.onmessage = function (evt) {
      var receivedMsg = evt.data;
      addStatus("server sent the following: '" + receivedMsg + "'");
    };

    ws.onclose = function() {
      addStatus("websocket was closed");
    };
  } else {
    addStatus("sorry, your browser does not support websockets.");
  }
}

// This can be invoked from the console
function send(message) {
  ws.send(message);
  addStatus("sent message to server: '" + message + "'");
}
