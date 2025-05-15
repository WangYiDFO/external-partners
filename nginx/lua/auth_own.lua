local oidc = require("resty.openidc")

local auth_header_name = "Authorization"


local opts = {
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
        ngx.req.set_header("X-User", res.sub)
        ngx.req.set_header("X-Username", res.preferred_username)
        ngx.req.set_header("X-Email", res.email)
        return
    end
end

-- Fallback to OIDC authentication if no valid JWT token
local res, err = oidc.authenticate(opts)

if err then
  ngx.status = 500
  ngx.say("Authentication failed: " .. err)
  ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

-- Set the Bearer token in Authorization header
ngx.req.set_header("Authorization", "Bearer " .. res.access_token)
ngx.req.set_header("X-User", res.id_token.sub)
ngx.req.set_header("X-Username", res.id_token.preferred_username)
ngx.req.set_header("X-Email", res.id_token.email)
