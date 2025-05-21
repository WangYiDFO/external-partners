local oidc = require("resty.openidc")

local auth_header_name = "Authorization"

local geonetwork_opts = {
  redirect_uri_path = "/geonetwork/redirect_uri",
  discovery = "https://bug-free-space-eureka-rwjr9g97qrvf5jwx-443.app.github.dev/auth/realms/master/.well-known/openid-configuration",
  client_id = "geonetwork",
  client_secret = "5b8UlQYT4uoZX0YuXHDOH1OvhgsSeKWf",
  scope = "openid email profile",
  ssl_verify = "no",
  jwk_expires_in = 24 * 60 * 60
}

local test_opts = {
  redirect_uri_path = "/csw/redirect_uri",
  discovery = "https://bug-free-space-eureka-rwjr9g97qrvf5jwx-443.app.github.dev/auth/realms/master/.well-known/openid-configuration",
  client_id = "geonetwork",
  client_secret = "5b8UlQYT4uoZX0YuXHDOH1OvhgsSeKWf",
  scope = "openid email profile",
  ssl_verify = "no",
  jwk_expires_in = 24 * 60 * 60
}

-- Check for existing Bearer token
local auth_header = ngx.req.get_headers()[auth_header_name]
if auth_header then
    -- call bearer_jwt_verify for OAuth 2.0 JWT validation
    local res, err = oidc.bearer_jwt_verify(opts)

    if not err then
      -- Set the Shibboleth header according to config-security-shibboleth-overrides.properties
      ngx.req.set_header("REMOTE_USER", res.sub)
      ngx.req.set_header("Shib-Person-surname", res.family_name)
      ngx.req.set_header("Shib-InetOrgPerson-givenName", res.given_name)
      ngx.req.set_header("Shib-EP-Email", res.email)
      ngx.req.set_header("Shib-EP-organisation", res.organization)
      ngx.req.set_header("Shib-EP-Entitlement", res.resource_access.geonetwork.roles)
        -- ngx.req.set_header("X-User", res.sub)
        -- ngx.req.set_header("X-Username", res.preferred_username)
        -- ngx.req.set_header("X-Email", res.email)
        -- Set the OIDC_access_token header, for robot user
        -- ngx.req.set_header("OIDC_access_token", auth_header.gsub("Bearer ", ""))
        return
    end
end

-- Fallback to OIDC authentication if no valid JWT token
local res, err = oidc.authenticate(geonetwork_opts)

if err then
  ngx.status = 500
  ngx.say("Authentication failed: " .. err)
  ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

-- Set the Shibboleth header according to config-security-shibboleth-overrides.properties
ngx.req.set_header("REMOTE_USER", res.id_token.sub)
ngx.req.set_header("Shib-Person-surname", res.id_token.family_name)
ngx.req.set_header("Shib-InetOrgPerson-givenName", res.id_token.given_name)
ngx.req.set_header("Shib-EP-Email", res.id_token.email)
ngx.req.set_header("Shib-EP-organisation", res.id_token.organization)
ngx.req.set_header("Shib-EP-Entitlement", res.id_token.resource_access.geonetwork.roles)

-- ngx.req.set_header("OIDC_access_token", res.access_token)
-- ngx.req.set_header("Authorization", "Bearer " .. res.access_token)
-- ngx.req.set_header("X-User", res.id_token.sub)
-- ngx.req.set_header("X-Username", res.id_token.preferred_username)
-- ngx.req.set_header("X-Email", res.id_token.email)
-- Set the OIDC_id_token_payload header, for Browser user
-- ngx.req.set_header("OIDC_id_token_payload", cjson.encode(res.id_token))
