local oidc = require("resty.openidc")

local auth_header_name = "Authorization"

local opts = {
  discovery = "https://dev.edh-cde.unclass.dfo-mpo.gc.ca/auth/realms/edh/.well-known/openid-configuration",
  jwk_expires_in = 24 * 60 * 60,
  ssl_verify = "no" -- Set to "yes" in production
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
    else
      ngx.status = 401
      ngx.say("Authentication failed: Not valid JWT Token " .. err)
      ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end
  else
    if err then
      ngx.status = 401
      ngx.say("Authentication failed: No JWT token " .. err)
      ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end
end
