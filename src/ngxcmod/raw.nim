type
  Context* {.pure.} = ref object
    req_args*: cstring   ##  Uri Args
    req_body*: ptr char  ##  Request Body
    req_body_len*: int   ##  length of body
    shared_mem*: pointer ##  internal
    r: pointer
    pl: pointer
    log: pointer


{.push importc: "ngx_http_c_func_$1", cdecl.}
proc log_debug*(ctx: Context, msg: cstring)
proc log_info*(ctx: Context, msg: cstring)
proc log_warn*(ctx: Context, msg: cstring)
proc log_err*(ctx: Context, msg: cstring)

proc get_header*(ctx: Context, key: cstring): cstring
proc get_query_param*(ctx: Context, key: cstring): cstring
proc palloc*(ctx: Context, size: int): pointer ## malloc from nginx pool, this pool will be freed once finished request, please do not to free by yourself
proc pcalloc*(ctx: Context, size: int): pointer  ## calloc from nginx pool, this pool will be freed once finished request, please do not to free by yourself
proc strdup*(ctx: Context, src: cstring): cstring
proc write_resp*(ctx: Context, status_code: int, status_line: cstring, content_type: cstring, resp_content: cstring, resp_len: csize)
proc write_resp_l*(ctx: Context, status_code: int, status_line: cstring, status_line_len: csize, content_type: cstring, content_type_len: csize, resp_content: cstring, resp_content_len: csize)
proc set_resp_var*(ctx: Context, resp_content: cstring, resp_len: csize)

##  Shared Memory and Cache Scope
proc shmtx_trylock*(shared_mem: pointer): pointer
proc shmtx_lock*(shared_mem: pointer)
proc shmtx_unlock*(shared_mem: pointer)
proc shm_alloc*(shared_mem: pointer, size: csize): pointer
proc shm_free*(shared_mem: pointer, p: pointer)
proc shm_alloc_locked*(shared_mem: pointer, size: csize): pointer
proc shm_free_locked*(shared_mem: pointer, p: pointer)
proc cache_get*(shared_mem: pointer, key: cstring): pointer
proc cache_put*(shared_mem: pointer, key: cstring, value: pointer): pointer
proc cache_new*(shared_mem: pointer, key: cstring, size: csize): pointer
proc cache_remove*(shared_mem: pointer, key: cstring): pointer
{.pop.}
