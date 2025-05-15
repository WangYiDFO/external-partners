local oidc = require("resty.openidc")

local opts = {
  redirect_uri_path = "/test/redirect_uri",
  discovery = "https://second.idp.com//.well-known/openid-configuration",
  client_id = "clientid",
  client_secret = "clientsecret",
  scope = "openid email profile",
  ssl_verify = "no"
}

local res, err = oidc.authenticate(opts)

if err then
  ngx.status = 500
  ngx.say("Authentication failed: " .. err)
  ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

ngx.req.set_header("X-User", res.id_token.sub)
ngx.req.set_header("X-Email", res.id_token.email)
