# ngxcmod
This module contains some high level wrapper to build Nginx module with ``nginx-c-function``
For low level wrapper, please import ``ngxcmod/raw``


## Usage

```nim
import ngxcmod, strutils

proc init(ctx: Context) =
  ctx.log(INFO, "hello from Nim")

proc exit(ctx: Context) =
  ctx.log(WARN, "goodbye, from Nim w/ <3")

initHook(init)
exitHook(exit)


proc hello(ctx: Context) {.exportc.} =
  ctx.log(INFO, "Calling back and log from /hello")
  let
    name = ctx.getQueryParam("name")
    message = "hello $#, greeting from Nim" % name
  ctx.response(200, "200 OK", CONTENT_TYPE_PLAINTEXT, message)
```