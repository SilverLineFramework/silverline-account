# silverline-account
Authentication and access control service for the SilverLine Framework.

## Silverline ACL Motivation
- Separate auth model from the communications system
- Avoid tight coupling of user database, auth flows
- Use the topics as ACL, scope, isolation
- Current: MQTT Pub-Sub JWT
- Future: OPC UA Pub-Sub JWT?

## Silverline Threat Model
- Architecture is a moving target
- Started defining endpoints and mitigations
- List of linked scenarios:
    - Endpoints, Mitigations, Risks
- Request for system endpoint definitions
- Best place for collaboration: Github Markdown/Sharepoint Excel
