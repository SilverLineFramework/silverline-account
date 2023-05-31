/**
 *  Silverline Client MQTT JWT authentication example for Paho MQTT C
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "MQTTClient.h"

#define CLIENTID "ExampleClientSilverline"

int client_connect(char *host, char *token, char *password, bool verify)
{
    MQTTClient client;
    MQTTClient_connectOptions conn_opts = MQTTClient_connectOptions_initializer;
    MQTTClient_SSLOptions ssl_opts = MQTTClient_SSLOptions_initializer;
    int rc;
    MQTTClient_create(&client, &host, CLIENTID,
                      MQTTCLIENT_PERSISTENCE_NONE, NULL);

    // verify ? CA-signed : self-signed
    ssl_opts.verify = verify;
    ssl.opts.enableServerCertAuth = verify;
    ssl_opts.sslVersion = MQTT_SSL_VERSION_TLS_1_2;

    conn_opts.ssl = ssl_opts;
    conn_opts.cleansession = 1;
    conn_opts.username = &token;
    conn_opts.password = &password;

    if ((rc = MQTTClient_connect(client, &conn_opts)) != MQTTCLIENT_SUCCESS)
    {
        printf("Failed to connect, return code %d\n", rc);
        exit(EXIT_FAILURE);
    }
    MQTTClient_disconnect(client, 10000);
    MQTTClient_destroy(&client);
    return rc;
}
