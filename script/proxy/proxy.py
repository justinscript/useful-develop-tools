from __future__ import with_statement
from threading import Lock
import socket, thread, select

__version__ = '0.1.0 Draft 1'
BUFLEN = 8192
VERSION = 'Python Proxy/' + __version__
HTTPVER = 'HTTP/1.1'
HOST_HEADER_PREFIX = 'Host: '
Real_IP_HEADER_PREFIX = 'X-Forwarded-For: '

allow_ip_list = []
allow_ip_list_lock = Lock()

class ConnectionHandler:

    def __init__(self, connection, address, timeout):
        global allow_ip_list
        global allow_ip_list_lock
        try:
            self.client = connection
            self.client_buffer = ''
            self.timeout = timeout
            self.method, self.path, self.protocol, self.target_host, self.real_ip = self.get_base_header()
            if self.path == '/append_allow_ip.htm':
                with allow_ip_list_lock:
                    if self.real_ip not in allow_ip_list:
                        allow_ip_list.append(self.real_ip)
                        if len(allow_ip_list) > 10:
                            allow_ip_list = allow_ip_list[len(allow_ip_list)-10:]
                return
            # print self.method, self.path, self.protocol, self.target_host, self.real_ip
            if self.allow(self.real_ip):
                if self.method == 'CONNECT':
                    self.method_CONNECT()
                else:
                    self.method_others()
                #elif self.method in ('OPTIONS', 'GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'TRACE'):
            self.client.close()
            if hasattr(self, 'target') and self.target is not None:
                self.target.close()
        except Exception, e:
            print e

    def get_base_header(self):
        while 1:
            self.client_buffer += self.client.recv(BUFLEN)
            end = self.client_buffer.find('\r\n\r\n')
            if end != -1:
                break
        # print self.client_buffer[:end+1]
        headers = self.client_buffer[:end+1].split('\r\n')
        target_host = '1.1.1.1'
        real_ip = ''
        for header in headers:
            if header.startswith(HOST_HEADER_PREFIX):
                target_host = header[len(HOST_HEADER_PREFIX):]
            if header.startswith(Real_IP_HEADER_PREFIX):
                real_ip = header[len(Real_IP_HEADER_PREFIX):]
        first_line = headers[0]
        data = first_line.split()
        self.client_buffer = self.client_buffer[len(first_line):]
        data.append(target_host)
        data.append(real_ip)
        return data

    def method_CONNECT(self):
        self._connect_target(self.path)
        self.client.send(HTTPVER+' 200 Connection established\n' + 'Proxy-agent: %s\n\n' % VERSION)
        self.client_buffer = ''
        self._read_write()        

    def method_others(self):
        self._connect_target(self.target_host)
        header = '%s %s %s' % (self.method, self.path, self.protocol) + self.client_buffer
        self.target.send(header)
        self.client_buffer = ''
        self._read_write()

    def _connect_target(self, host):
        i = host.find(':')
        if i != -1:
            port = int(host[i+1:])
            host = host[:i]
        else:
            port = 80
        if port == 8000:
            port = 80
        if host == 'repo.msun-inc.com':
            port = 7080
        (soc_family, _, _, _, address) = socket.getaddrinfo(host, port)[0]
        self.target = socket.socket(soc_family)
        self.target.connect(address)

    def _read_write(self):
        time_out_max = self.timeout/3
        socs = [self.client, self.target]
        count = 0
        while 1:
            count += 1
            (recv, _, error) = select.select(socs, [], socs, 3)
            if error:
                break
            if recv:
                for in_ in recv:
                    data = in_.recv(BUFLEN)
                    if in_ is self.client:
                        out = self.target
                    else:
                        out = self.client
                    if data:
                        out.send(data)
                        count = 0
            if count == time_out_max:
                break

    def allow(self, real_ip):
        global allow_ip_list
        global allow_ip_list_lock
        if real_ip == '' or real_ip == '127.0.0.1' or real_ip.startswith('192.168.1.'):
            return True
        with allow_ip_list_lock:
            if self.real_ip in allow_ip_list:
                return True
        if real_ip == '121.196.128.188':
            return True
        allow_ip = self.gethostbyname_ex('msun-dev.xicp.net')[2][0]
        if real_ip == allow_ip:
            return True
        allow_ip = self.gethostbyname_ex('zxc.oicp.net')[2][0]
        if real_ip == allow_ip:
            return True
        return False

    def gethostbyname_ex(self, hostname):
        try:
            return socket.gethostbyname_ex(hostname)[2][0]
        except Exception, e:
            return ''

def start_server(host='0.0.0.0', port=8000, IPv6=False, timeout=3600,
                  handler=ConnectionHandler):
    if IPv6 == True:
        soc_type = socket.AF_INET6
    else:
        soc_type = socket.AF_INET
    soc = socket.socket(soc_type)
    soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    soc.bind((host, port))
    print "Serving on %s:%d." % (host, port)
    soc.listen(0)
    while 1:
        thread.start_new_thread(handler, soc.accept() + (timeout,))

if __name__ == '__main__':
    start_server()



