#!/bin/bash

# Keycloak details
KEYCLOAK_URL="http://localhost:8080"
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="admin"
REALM_NAME="smart-droplets-realm"
CLIENT_NAME="web-dashboard-client"
ROLE_NAME="farmer"
DEFAULT_GROUP_NAME="default-farm"
DEFAULT_USER="default-farmer"
DEFAULT_USER_PASSWORD="password123"
CLIENT_WEB_ORIGINS="http://localhost:3000"  # Set this to the dashboard's URL

PROXY_CLIENT="oauth2-proxy"

# Obtain Keycloak Admin token using admin credentials
TOKEN=$(curl -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
  -d "username=$ADMIN_USERNAME" \
  -d "password=$ADMIN_PASSWORD" \
  -d "client_id=admin-cli" \
  -d "grant_type=password" | jq -r '.access_token')

# Create a new realm
curl -X POST "$KEYCLOAK_URL/admin/realms" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "realm": "'$REALM_NAME'",
    "enabled": true,
    "displayName": "Farmers Realm",
    "sslRequired": "external",
    "registrationAllowed": false
  }'

# Create "farmer" role in the realm
curl -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/roles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "'$ROLE_NAME'"
  }'

# Create OAuth2 Proxy client with audience mapper
curl -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/clients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "'$PROXY_CLIENT'",
    "enabled": true,
    "protocol": "openid-connect",
    "publicClient": false,
    "secret": "eW91ci1jbGllbnQtc2VjcmV0",
    "redirectUris": ["*"],
    "standardFlowEnabled": true,
    "directAccessGrantsEnabled": true,
    "protocolMappers": [{
      "name": "audience-mapper",
      "protocol": "openid-connect",
      "protocolMapper": "oidc-audience-mapper",
      "consentRequired": false,
      "config": {
        "included.client.audience": "'$PROXY_CLIENT'",
        "id.token.claim": "true",
        "access.token.claim": "true"
      }
    }]
  }'

# Create default group (tenant)
curl -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/groups" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "'$DEFAULT_GROUP_NAME'"
  }'

# Get the default group ID
GROUP_ID=$(curl -s -X GET "$KEYCLOAK_URL/admin/realms/$REALM_NAME/groups" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.[] | select(.name=="'$DEFAULT_GROUP_NAME'") | .id')

# Create a default farmer user
curl -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "'$DEFAULT_USER'",
    "enabled": true,
    "credentials": [{"type": "password", "value": "'$DEFAULT_USER_PASSWORD'", "temporary": false}],
    "firstName": "John",
    "lastName": "Deere",
    "email": "john@myfarm.lt",
    "emailVerified": true
  }'

# Get the default farmer user ID
USER_ID=$(curl -s -X GET "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq -r '.[] | select(.username=="'$DEFAULT_USER'") | .id')

# Assign the user to the default group
curl -X PUT "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users/$USER_ID/groups/$GROUP_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"

# Assign the "farmer" role to the user
ROLE_ID=$(curl -s -X GET "$KEYCLOAK_URL/admin/realms/$REALM_NAME/roles/$ROLE_NAME" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.id')

curl -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users/$USER_ID/role-mappings/realm" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '[{"id": "'$ROLE_ID'", "name": "'$ROLE_NAME'"}]'

echo "Keycloak setup completed with default tenant and farmer user."
