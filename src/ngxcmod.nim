## This module contains some high level wrapper to build Nginx module with ``nginx-c-function``
##
## For low level wrapper, please import ``ngxcmod/raw``

import macros, ngxcmod/raw
export Context


const
  CONTENT_TYPE_PLAINTEXT* = "text/plain"
  CONTENT_TYPE_HTML* = "text/html; charset=utf-8"
  CONTENT_TYPE_JSON* = "application/json"
  CONTENT_TYPE_JSONP* = "application/javascript"
  CONTENT_TYPE_XFORMENCODED* = "application/x-www-form-urlencoded"

type
  LOG_LEVEL* = enum
    DEBUG
    INFO
    WARN
    ERR

  Callback = proc(ctx: Context) ## proc-types for `init` and `exit` callbacks


macro init*(x: varargs[untyped]): untyped =
  ## Proc has ``init`` pragma will get called when Nginx starts, can use only once in a module
  var pdef = x[0]
  if pdef[4].kind == nnkEmpty:
    pdef[4] = newNimNode(nnkPragma)
  pdef[4].add(newNimNode(nnkExprColonExpr).add(ident("exportc"), newStrLitNode("ngx_http_c_func_init")))
  pdef

macro exit*(x: varargs[untyped]): untyped =
  ## Proc has ``init`` pragma will get called when Nginx shutdowns, can use only once in a module
  var pdef = x[0]
  if pdef[4].kind == nnkEmpty:
    pdef[4] = newNimNode(nnkPragma)
  pdef[4].add(newNimNode(nnkExprColonExpr).add(ident("exportc"), newStrLitNode("ngx_http_c_func_exit")))
  pdef

template log*(ctx: Context, level: LOG_LEVEL, msg: string) =
  case level
  of DEBUG:
    log_debug(ctx, msg)
  of INFO:
    log_info(ctx, msg)
  of WARN:
    log_warn(ctx, msg)
  of ERR:
    log_err(ctx, msg)

template getHeader*(ctx: Context, key: string): string =
  ## Returns the values associated with the given key
  $raw.get_header(ctx, key)

template getQueryParam*(ctx: Context, key: string): string =
  ## Returns the values associated with the given key
  $raw.get_query_param(ctx, key)

template response*(ctx: Context, statusCode: int, statusLine: string, contentType: string, content: string) =
  ## Write response to client
  raw.write_resp(ctx, statusCode, statusLine, contentType, content, content.len)

template cacheGet(sharedMem: pointer, key: string): pointer =
  apit.cache_get(sharedName, key)

template cachePut(sharedMem: pointer, key: string, value: pointer): pointer =
  apit.cache_put(sharedName, key, value)

template cacheNew(sharedMem: pointer, key: string, size: int): pointer =
  apit.cache_new(sharedName, key, size)

template cacheRemove(sharedMem: pointer, key: string, size: int): pointer =
  apit.cache_remove(sharedName, key, size)
