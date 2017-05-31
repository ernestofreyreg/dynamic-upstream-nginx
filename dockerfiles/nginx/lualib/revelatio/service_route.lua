local _ = require 'revelatio.underscore'
local _M = { _VERSION = '0.1.0' }

local function uriMatch (route, uri)
    return uri:match(route)
end

local function routeAddMatching (route, uri)
    route.matching = uriMatch(route['route'], uri)
    return route
end

function _M.router (routes, domain, uri)
    local domainRoutes = _.filter(
        routes,
        function (route) return route.domain == domain end
    )

    local routesMatching = _.map(
        domainRoutes,
        function (route) return routeAddMatching(route, uri) end
    )

    local keepMatches = _.reject(
        routesMatching,
        function (route) return route.matching == nil end
    )

    if #keepMatches > 0 then
        local finalRoute = _.max(
            keepMatches,
            function (route)  return route.matching:len() end
        )
        return finalRoute
    else
        return nil
    end
end

return _M


