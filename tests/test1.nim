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
