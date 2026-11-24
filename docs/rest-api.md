# REST API
In addition to MQTT, the driver exposes a REST API that third-party applications can use to manage devices and to interact with them programmatically.

The two interfaces are complementary:
- **MQTT** carries the real-time data flow: every uplink is decoded and published as JSON, together with downlinks and acknowledgements (see [MQTT Integration](mqtt-integration.md))
- **REST API** is used for management and on-demand operations, for example:
  - enrolling, editing and removing devices
  - scheduling downlinks (commands and configurations), following their status and canceling them
  - reading the history of uplinks, or following them live through Server-Sent Events
  - reading device details, FOTA status and installation data
  - translating a raw CBOR payload into JSON

## Base URL
The API is reachable on the same address and port as the web interface, under the path `/api`:

```
http://<HOST>/api
```

For example `http://192.168.1.1/api/devices`. If the web interface is published through a reverse proxy with HTTPS (recommended, see [Security Best Practices](first-launch.md#security-best-practices)), use `https://<HOST>/api`.

⚠️ The API Server also listens on port 8080 for the internal services of the driver. Do not expose that port to third-party applications: use the `/api` path of the web interface instead.

## Authentication
Every endpoint requires a Bearer token in the `Authorization` header:

```
Authorization: Bearer <token>
```

There are two ways to obtain a token. For integrations with third-party applications, the API Token is the recommended one.

### API Token (recommended)
An API Token is a long-lived token, bound to a set of permissions, that can be revoked at any time without affecting the users of the web interface.

1. Open the web interface, open the left side menu and select **API Tokens**.
2. Click **Generate new token**.
3. Fill in the fields as follows:
   - **Token name:** A descriptive name to identify the application later, e.g., `scada-connector`.
   - **Expiration:** Choose according to your security policies. If you do **not** choose *No expiration*, you will need to regenerate the token before it expires.
   - **Permissions:** Enable only the permissions the application needs (see the table below).
4. Click **Generate token** and **store the token securely**, as it cannot be viewed again later.

| Permission | Allows to |
| ---------- | --------- |
| Can read devices | Read devices, uplink history, live uplinks, downlink history, FOTA status, translate CBOR payloads |
| Can write devices | Enroll, edit and remove devices |
| Can send downlink | Schedule and cancel downlinks |

Example:
```console
curl -H "Authorization: Bearer <token>" http://<HOST>/api/devices
```

A token can be regenerated (the old one stops working) or deleted from the same **API Tokens** page.

### OAuth2 (client credentials)
Alternatively, an application can obtain a short-lived token by providing the username and password of a user of the web interface:

```console
curl -X POST http://<HOST>/api/oauth2/token \
     -H "Content-Type: application/json" \
     -d '{"client_id": "<username>", "client_secret": "<password>", "grant_type": "client_credentials"}'
```

Response:
```json
{
    "access_token": "eyJhbGciOi...",
    "token_type": "bearer",
    "expires_in": 604800,
    "refresh_token": "eyJhbGciOi...",
    "scope": null
}
```

The `access_token` is valid for 7 days and has the same permissions as the user. Before it expires, a new one can be obtained with the `refresh_token` (valid for 30 days):

```console
curl -X POST http://<HOST>/api/oauth2/refresh \
     -H "Content-Type: application/json" \
     -d '{"refresh_token": "<refresh_token>"}'
```

## API reference
The complete reference of the endpoints, with request and response formats, is available in the web interface: open the left side menu and select **API Docs**. The page documents the API in OpenAPI (Swagger) format.

Main groups of endpoints:

| Path | Purpose |
| ---- | ------- |
| `/api/devices` | List, enroll, edit and remove devices; hardware and device types |
| `/api/devices/{serial}/uplinklogs` | History of the uplinks received from a device |
| `/api/devices/{serial}/uplinklogsstream` | Live uplinks of a device (Server-Sent Events) |
| `/api/devices/update` | Live updates of the devices, sent when a device changes (Server-Sent Events) |
| `/api/devices/{serial}/downlink` | Schedule, list and cancel downlinks |
| `/api/devices/{serial}/fota` | FOTA status of a device |
| `/api/devices/{serial}/installation` | Installation data and history |
| `/api/devices/cbor` | Translate a CBOR payload into JSON |
| `/api/oauth2` | OAuth2 token and refresh |

The remaining endpoints (users, API tokens, applications, firmware, settings, mobile devices) are used by the web interface and require administrative permissions.

## Example: scheduling a downlink
```console
curl -X POST http://<HOST>/api/devices/A0000001/downlink \
     -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     -d '{"timestamp": 1792074480, "command": {"id": "0219dfb3-00a8-40e6-90ea-1f83e807e885", "callback": "https://example.com/callback", "data": "{\"tx_interval\": 3600}"}}'
```

Response:
```json
{
    "timestamp": 1792074480,
    "command_id": "0219dfb3-00a8-40e6-90ea-1f83e807e885",
    "status": "queued",
    "expected_delivery": "2026-11-24T10:01:00+01:00"
}
```

The `data` field contains the JSON payload for the device, as a string. The available fields depend on the device family, see for example [VIDI Transmitter](vidi-transmitter.md). For the downlink states, the optional `ttl` and the status notifications sent to the `callback` URL, see [Scheduling downlinks](mqtt-integration.md#scheduling-downlinks).

## Errors
| Status | Meaning |
| ------ | ------- |
| 400 | Invalid request (the response body describes the invalid field) or invalid token |
| 401 | Missing `Authorization` header, token expired, or API Token deleted/regenerated |
| 403 | The token does not have the permission required by the endpoint |
| 404 | Resource not found (e.g., unknown device serial) |
