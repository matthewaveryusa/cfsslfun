from http.server import HTTPServer, SimpleHTTPRequestHandler
import ssl
import threading

def run_server(port, certfile, keyfile):
    httpd = HTTPServer(('localhost', port), SimpleHTTPRequestHandler)
    httpd.socket = ssl.wrap_socket(httpd.socket, certfile=certfile, keyfile=keyfile, server_side=True)
    httpd.serve_forever()

def start_server(port, certfile, keyfile):
    server_thread = threading.Thread(target=run_server, args=(port, certfile, keyfile))
    server_thread.daemon = True
    server_thread.start()

start_server(8000, "foo.pem", "foo-key.pem")
start_server(8001, "foosni.pem", "foosni-key.pem")
start_server(8002, "fooclient.pem", "fooclient-key.pem")

try:
    while True:
        pass
except KeyboardInterrupt:
    print("Servers shutting down...")
