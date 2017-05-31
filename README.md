# dymanic-upstream-nginx

Openresty implementation for a dynamic
upstream implementation for nginx with support for routes and some extra features ;) 

*Requires docker to be installed and running.* 

```
$ export HOSTIP=<your local IP address>
$ ./start.sh
```

The **start** script requires `sudo` because we are trying to map restricted port 80

## Internals

The **start** script will build a new docker image from openresty/latest
including rules/code to make the backbone of revelatio architecture
work. This is an nginx service (backed with redis storage)

A local `./data` folder will be created with the persistent state of 
the redis storage. A local `./cache` folder will be created with the caching state of nginx.

## Other scripts

```
$ ./shell.sh   # Opens a shell console on the nginx container
```

## How it works?

Once the server is running you can write your routing rules on redis by using redis-cli or 
any other tool.

```
$ redis-cli
127.0.0.1:6379> set "route:my-web-app.com:/" "http://localhost:3500/"
127.0.0.1:6379> set "route:my-web-app.com:/api" "http://localhost:3501/"
```

Each route should be set as `route:<domain>:<path>` and the value should be set to the 
upstream server.

You could also set deep nested routes, Ex: `route:my-web-app.com:/section/content/check` 
meaning that any request coming to `http(s)://*.my-web-app.com/section/content/check(/*)` 
will be routed to that upstream server.

### Route Caching

All resolved routes to upstream servers are cached on redis. So, if you update a upstream 
server route then you should delete also all matching cache keys with the form 
`routecache:<domain>:<resolved-route>`. We are creating an admin CLI to handle
this automatically.


## Why?

In short, Serverless. 

## Copyrights

This repo includes source code from:
- https://github.com/cloudflare/lua-resty-cookie : Simply the best cookie api for Lua
- https://github.com/mirven/underscore.lua : Super useful set of functions for handling with iterators, arrays, tables.
- https://github.com/perusio/lua-resty-ffi-uuid : uuid generator based on libuuid1
