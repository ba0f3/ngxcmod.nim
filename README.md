# ngxcmod
This module contains high level API definations to build module for [Nginx](http://nginx.org) with [nginx-link-function](https://github.com/Taymindis/nginx-link-function)

For low level API, please import ``ngxcmod/raw``


## Requirements
* [Nginx](http://nginx.org)
* [nginx-link-function](https://github.com/Taymindis/nginx-link-function)

## Usage

### Nim module
```nim
import ngxcmod, strutils

proc init(ctx: ContextCycle) {.init.} =
  ctx.cyc_log(INFO, "hello from Nim")

proc exit(ctx: ContextCycle) {.exit.} =
  ctx.cyc_log(WARN, "goodbye, from Nim w/ <3")

proc hello(ctx: Context) {.exportc.} =
  ctx.log(INFO, "Calling back and log from hello")
  let
    name = ctx.getQueryParam("name")
    message = "hello $#, greeting from Nim" % name
  ctx.response(200, "200 OK", CONTENT_TYPE_PLAINTEXT, message)

proc post(ctx: Context) {.exportc.} =
  ctx.response(200, "200 OK", CONTENT_TYPE_PLAINTEXT, ctx.getBodyAsStr())
```

### Nginx config
```conf
http {
...
    server {
...
        ngx_link_func_lib "./your-module.so";
        location = /hello {
            ngx_link_func_call "hello";
        }
...
}
```
