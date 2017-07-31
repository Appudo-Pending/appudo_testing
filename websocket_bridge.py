#!/usr/bin/env python
"""
Usage::
    ./websocket_bridge.py <ws_addr> [<port>]
"""
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import SocketServer
from sys import version as python_version
from cgi import parse_header, parse_multipart
import websocket
import ssl
from websocket import create_connection

if python_version.startswith('3'):
    from urllib.parse import parse_qs
    from http.server import BaseHTTPRequestHandler
else:
    from urlparse import parse_qs
    from BaseHTTPServer import BaseHTTPRequestHandler

_ws_addr = ''
stripp = lambda s, ss: s[:s.find(ss)]
stripe = lambda s, ss: s[s.find(ss)+1:]

class S(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def _parse_GET(self):
        return parse_qs(stripe(self.path, "?"))

    def _parse_POST(self):
        ctype, pdict = parse_header(self.headers['content-type'])
        if ctype == 'multipart/form-data':
            postvars = parse_multipart(self.rfile, pdict)
        elif ctype == 'application/x-www-form-urlencoded':
            length = int(self.headers['content-length'])
            postvars = parse_qs(
                    self.rfile.read(length),
                    keep_blank_values=1)
        else:
            postvars = {}
        return postvars

    def do_GET(self):
        global _ws_addr
        gvars = self._parse_GET()
        self._set_headers()
        ws = create_connection(_ws_addr+stripp(self.path, "?"), sslopt={"cert_reqs": ssl.CERT_NONE})
        ws.send(str(gvars) + "|{}")
        result =  ws.recv()
        ws.close()
        self.wfile.write(result)

    def do_POST(self):
        global _ws_addr
        gvars = self._parse_GET()
        pvars = self._parse_POST()
        self._set_headers()
        ws = create_connection(_ws_addr+stripp(self.path, "?"), sslopt={"cert_reqs": ssl.CERT_NONE})
        ws.send(str(gvars) + "|" +  str(pvars))
        result =  ws.recv()
        ws.close()
        self.wfile.write(result)

def run(server_class=HTTPServer, handler_class=S, ws_addr="ws://localhost", port=80):
    global _ws_addr
    _ws_addr = ws_addr
    server_address = ('', port)
    wsclient = websocket.WebSocket()
    httpd = server_class(server_address, handler_class)
    httpd.socket = ssl.wrap_socket (httpd.socket, certfile='./server.pem', server_side=True)
    print 'WebSocket bridge started.'
    httpd.serve_forever()

if __name__ == "__main__":
    from sys import argv

    if len(argv) == 3:
        run(ws_addr=argv[1], port=int(argv[2]))
    elif len(argv) == 2:
        run(ws_addr=argv[1])
    else:
        exit(1)
