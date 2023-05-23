// Silverline Client MQTT JWT authentication example for Java Eclipse Vert.x MQTT

import io.vertx.core.*;
import io.vertx.mqtt.MqttClient;
import io.vertx.mqtt.MqttClientOptions;

class Silverline {

    public void ConnectClient(Vertx vertx, String host, String username, String token) {
        ConnectClient(vertx, host, username, token, true);
    }

    public void ConnectClientTest(Vertx vertx, String host, String username, String token, Boolean verify) {
        int port = 8883;
        MqttClientOptions clientOptions = new MqttClientOptions()
                .setUsername(username)
                .setPassword(token);
        if (verify) {
            // CA-signed
            clientOptions
                    .setSsl(true)
                    .setTrustAll(true);
        } else {
            // self-signed
            // Are other options needed to avoid verification?
        }
        MqttClient client = MqttClient.create(vertx, clientOptions);
        client.connect(port, host).onComplete(s -> {
            client.disconnect();
        });
    }

}
