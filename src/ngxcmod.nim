## This module contains some high level wrapper to build Nginx module with ``nginx-c-function``
##
## For low level wrapper, please import ``ngxcmod/raw``



import ngxcmod/raw

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


template initHook*(p: Callback) =
  ## helper for create `ngx_http_c_func_init` proc, called when NGINX starts,
  ## or you can implement it yourself in your module
  ##
  ## .. code-block:: nim
  ##   proc ngx_http_c_func_init(ctx: Context) {.exportc.} =
  ##     # your code here
  proc ngx_http_c_func_init(ctx: Context) {.exportc.} =
    p(ctx)

template exitHook*(p: Callback) =
  ## same as `initHook`, but it creates `ngx_http_c_func_exit` proc instead

  proc ngx_http_c_func_exit(ctx: Context) {.exportc.} =
    p(ctx)

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

