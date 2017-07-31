import libappudo;
import libappudo_special;

func onMessage(ev : WebSocketEvent) {
    let s : Socket = ev.target
    if(ev.isText) {
        _ = sendText(ev.data as! String, s)
    } else {
        _ = sendBytes(ev.data, s)
    }
}
