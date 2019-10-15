## This module contains some high level wrapper to build Nginx module with ``nginx-c-function``
##
## For low level wrapper, please import ``ngxcmod/raw``

import macros, ngxcmod/raw
export Context, ContextCycle

const
  CONTENT_TYPE_PLAINTEXT* = "text/plain"
  CONTENT_TYPE_HTML* = "text/html; charset=utf-8"
  CONTENT_TYPE_JSON* = "application/json"
  CONTENT_TYPE_JSONP* = "application/javascript"
  CONTENT_TYPE_XFORMENCODED* = "application/x-www-form-urlencoded"

type
  LOG_LEVEL* = enum
    DEBUG, INFO, WARN, ERR

macro init*(x: varargs[untyped]): untyped =
  ## Proc has ``init`` pragma will get called when Nginx starts, can use only once in a module
  var pdef = x[0]
  if pdef[4].kind == nnkEmpty:
    pdef[4] = newNimNode(nnkPragma)
  pdef[4].add(newNimNode(nnkExprColonExpr)
                         .add(ident("exportc"), newStrLitNode("ngx_link_func_init_cycle")))
  pdef

macro exit*(x: varargs[untyped]): untyped =
  ## Proc has ``init`` pragma will get called when Nginx shutdowns, can use only once in a module
  var pdef = x[0]
  if pdef[4].kind == nnkEmpty:
    pdef[4] = newNimNode(nnkPragma)
  pdef[4].add(newNimNode(nnkExprColonExpr).add(ident("exportc"), newStrLitNode("ngx_link_func_exit_cycle")))
  pdef

template log*(ctx: Context, level: LOG_LEVEL, msg: string) =
  ## sends log message to Nginx
  case level
  of DEBUG:
    log_debug(ctx, msg)
  of INFO:
    log_info(ctx, msg)
  of WARN:
    log_warn(ctx, msg)
  of ERR:
    log_err(ctx, msg)

template cyc_log*(ctx: ContextCycle, level: LOG_LEVEL, msg: string) =
  ## sends log message to Nginx
  case level
  of DEBUG:
    cyc_log_debug(ctx, msg)
  of INFO:
    cyc_log_info(ctx, msg)
  of WARN:
    cyc_log_warn(ctx, msg)
  of ERR:
    cyc_log_err(ctx, msg)

template getHeader*(ctx: Context, key: string): string =
  ## Returns the values associated with the given key
  $raw.get_header(ctx, key)

template getQueryParam*(ctx: Context, key: string): string = $raw.get_query_param(ctx, key)
  ## Returns the values associated with the given key

template getArgs*(ctx: Context): string = $ctx.req_args
  ## get the uri args

template getBody*(ctx: Context): tuple[p: string, size: int] =  ($cast[cstring](ctx.req_body), ctx.req_body_len)
  ## Get request body, and its length

template getBodyAsStr*(ctx: Context): string = $cast[cstring](ctx.req_body)
  ## Get request body, ctx.req_body may not terminated with NULL, use it as yourown risk

template getSharedMem*(ctx: Context): pointer = ctx.shared_mem
  ## returns pointer to shared memory

template response*(ctx: Context, statusCode: uint, statusLine: string, contentType: string, content: string) =
  ## Write response to client
  write_resp(ctx, statusCode, statusLine, contentType, content, content.len)

template cacheGet*(sharedMem: pointer, key: string): pointer = cache_get(sharedName, key)

template cachePut*(sharedMem: pointer, key: string, value: pointer): pointer = cache_put(sharedName, key, value)

template cacheNew*(sharedMem: pointer, key: string, size: int): pointer = cache_new(sharedName, key, size)

template cacheRemove*(sharedMem: pointer, key: string, size: int): pointer = cache_remove(sharedName, key, size)
