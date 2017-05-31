local redis = require 'resty.redis'
local service_route = require 'revelatio.service_route'

local red = redis:new()
red:set_timeout(1000) -- 1 sec

local host = ngx.var.host
local uri = ngx.var.uri
local domain = host:match("([%w%-_]+%.-%w+)[%:%d+]-$")

local ok, err = red:connect('redisbox', 6379)
if not ok then
    ngx.say('failed to connect: ', err)
    ngx.redirect("/500.html")
    return
end

-- Check cache first
local cached_route_key = 'routecache:' .. domain .. ':' .. uri
local cached_res, _ = red:get(cached_route_key)
if not cached_res or cached_res == ngx.null then
    ngx.log(ngx.NOTICE, 'CACHE MISS: ' .. uri)
else
    ngx.log(ngx.NOTICE, 'CACHE HIT: ' .. uri .. ' -> ' .. cached_res)
    ngx.var.target = cached_res
    return
end

-- Not cached, calculate route endpoint
-- Load routes from redis
local route_keys_pattern = 'route:' .. domain .. ':*'
local route_keys, err = red:keys(route_keys_pattern)
if not route_keys then
    ngx.log(ngx.ERR, 'Failed to get routes' .. err)
    return
end

if route_keys == ngx.null then
    ngx.log(ngx.ERR, 'Routes not found')
    return
end

local routes = {}
local routes_count = table.getn(route_keys)
for i=1, routes_count do
    local route = string.sub(route_keys[i], string.len(route_keys_pattern))
    local service = red:get(route_keys[i])
    table.insert(routes, {domain = domain, route = route, service = service})
end

-- Calculate the endpoint by matching the uri's
local resolvedRoute = service_route.router (routes, domain, uri)
if resolvedRoute == nil then
-- TODO: handle route not found
  ngx.log(ngx.ERR, 'Routes not found')
  ngx.redirect("/404.html")
  return
end

local serviceRequestUrl = resolvedRoute.service .. uri
ngx.var.target = serviceRequestUrl

-- Save cached route
red:set(cached_route_key, serviceRequestUrl)

-- Save cached route on resolved
local resolved_cached_route_key = 'routeresolved:' .. domain .. ':' .. resolvedRoute.route
local resolved_path = domain .. ':' .. uri
red:hmset(resolved_cached_route_key, {[resolved_path] = true})

-- put it into the connection pool of size 100,
-- with 10 seconds max idle time
local ok, err = red:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end
