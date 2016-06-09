#!/usr/bin/env python3

import GeoIP
import socketserver
import logging

gi = GeoIP.new(GeoIP.GEOIP_STANDARD)


class IP2C(socketserver.BaseRequestHandler):
    def handle(self):
        data = self.request[0].strip()
        socket = self.request[1]
        ip = self.client_address[0]

        logging.info("Request from %s: %r", ip, data)

        try:
            cmd, cmd2, ip = data.split(b' ')
            assert cmd == b'\xff\xff\xff\xffextResponse'
            assert cmd2 == b'ip2cq'
        except Exception:
            logging.exception("Malformed request ignored")
            return

        cn = (gi.country_code_by_addr(ip.decode('utf-8')) or '--').encode('utf-8')
        response = b'\xff\xff\xff\xffextResponse ip2cr %s %s' % (ip, cn)

        logging.info("Response to %s: %r", ip, response)
        socket.sendto(response, self.client_address)


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    HOST, PORT = "", 16886
    logging.info("Listening on port %i", PORT)
    socketserver.UDPServer((HOST, PORT), IP2C).serve_forever()
