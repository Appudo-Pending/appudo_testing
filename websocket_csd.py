#!/usr/bin/env python
"""
Usage::
    ./websocket_csd.py <ws_addr> <message> [<port>]
"""
import SocketServer
import websocket
import ssl
from websocket import create_connection

def run(message, ws_addr="ws://localhost", port=80):
    server_address = ('', port)
    wsclient = websocket.WebSocket()
    ws = create_connection(ws_addr, sslopt={"cert_reqs": ssl.CERT_NONE})
    ws.send(message)
    result =  ws.recv()
    print(result)
    ws.close()

if __name__ == "__main__":
    from sys import argv

    if len(argv) == 4:
        run(message=argv[1], ws_addr=argv[2], port=int(argv[3]))
    elif len(argv) == 3:
        run(message=argv[1], ws_addr=argv[2])
    else:
        exit(1)
