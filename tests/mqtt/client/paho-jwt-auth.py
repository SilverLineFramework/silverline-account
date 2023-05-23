'''
    Silverline Client MQTT JWT authentication example for Python paho-mqtt
'''

import ssl

import paho.mqtt.client as mqtt


class Silverline:

    def connect_client_test(self, host, username, token, verify=True):
        port = 8883
        client = mqtt.Client()
        client.username_pw_set(username=username, password=token)

        if verify(host):
            # CA-signed
            client.tls_set()
        else:
            # self-signed
            client.tls_set_context(ssl._create_unverified_context())
            client.tls_insecure_set(True)
        try:
            client.connect(host, port=port)
        except Exception as err:
            print(f'MQTT connect error to {host}, port={port}: {err}')

        client.disconnect()
