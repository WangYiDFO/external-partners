FROM openresty/openresty:1.27.1.2-0-alpine-fat

# Install Lua modules
RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-openidc \
 && /usr/local/openresty/luajit/bin/luarocks install lua-resty-http \
 && /usr/local/openresty/luajit/bin/luarocks install lua-resty-jwt \
 && /usr/local/openresty/luajit/bin/luarocks install lua-cjson \
 && /usr/local/openresty/luajit/bin/luarocks install luasocket