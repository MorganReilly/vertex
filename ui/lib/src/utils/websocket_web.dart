import 'dart:html';

/// Web WebSocket class, this class called when the application is running on a
/// web browser client. The reasons for this is because Flutter Web is still in a beta
/// and the dart:html package is required.

typedef void OnMessageCallback(dynamic msg);
typedef void OnCloseCallback(int code, String reason);
typedef void OnOpenCallback();

class SimpleWebSocket {
  //Variables
  String _url;
  var _socket;
  OnOpenCallback onOpen;
  OnMessageCallback onMessage;
  OnCloseCallback onClose;

  SimpleWebSocket(this._url) {
    _url = _url.replaceAll('https:', 'wss:');
    print(_url);
  }

  connect() async {
    try {
      _socket = WebSocket(_url, 'json');
      _socket.onOpen.listen((e) {
        this?.onOpen();
      });

      _socket.onMessage.listen((e) {
        this?.onMessage(e.data);
      });

      _socket.onClose.listen((e) {
        this?.onClose(e.code, e.reason);
      });
    } catch (e) {
      this?.onClose(e.code, e.reason);
    }
  }

  /// Function to send data
  send(data) {
    if (_socket != null && _socket.readyState == WebSocket.OPEN) {
      _socket.send(data);
      print('send: $data');
    } else {
      print('WebSocket not connected, message $data not sent');
    }
  }

  /// Close WebSocket
  close() {
    _socket.close();
  }
}//End class
