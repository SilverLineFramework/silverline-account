use std::{fs::File, io::BufReader, sync::Arc};

use anyhow::Result;
use rumqttc::{
    tokio_rustls::rustls::{ClientConfig, RootCertStore},
    AsyncClient, EventLoop, MqttOptions,
};

///
/// Creates a tuple of a rumqttc client and event loop, configured to use TLS encryption
/// and authentication via JWT tokens for the communication with the MQTT broker. See the
/// documentation of the `rumqtt` crate for examples how the client and the event loop can
/// be used for communication.
///
/// ## Arguments
///
/// - tls_cert_path: path to the certificate used by the broker (in this repo, it is the generated `tls.host.crt` file)
/// - username: the username used in the JWTs ('cli' in this repo)
/// - token: the JWT token that the client will use for authenticating (generated with the scripts in this repo)
/// - client_id: the ID that the client will provide to the broker
/// - host: the host/IP of the broker
/// - port: the port of the broker
/// - channel_cap: the capacity for the mqtt channels
///
/// # Returns
///
/// - A result of a tuple containing
///   - the client (used for interacting with the broker)
///   - the event loop (polled to get MQTT events, e.g., messages)
///
pub fn create_client(
    tls_cert_path: &str,
    username: &str,
    token: &str,
    client_id: &str,
    host: &str,
    port: u16,
    channel_cap: usize,
) -> Result<(AsyncClient, EventLoop)> {
    // read in the certificate
    let mut cert_store = RootCertStore::empty();
    let cert_file = File::open(tls_cert_path)?;
    let mut reader = BufReader::new(cert_file);
    for cert in rustls_pemfile::certs(&mut reader) {
        cert_store.add(cert?)?;
    }
    // create the client transport config
    let client_config = ClientConfig::builder()
        .with_root_certificates(cert_store)
        .with_no_client_auth();
    // set the mqtt options for the client
    let mut mqtt_options = MqttOptions::new(client_id, host, port);
    mqtt_options.set_transport(rumqttc::Transport::tls_with_config(
        rumqttc::TlsConfiguration::Rustls(Arc::new(client_config)),
    ));
    // set the username and the token
    mqtt_options.set_credentials(username, token);
    let (client, event_loop) = AsyncClient::new(mqtt_options, channel_cap);
    Ok((client, event_loop))
}
