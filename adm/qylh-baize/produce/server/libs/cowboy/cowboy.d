src/cowboy_compress_h.erl:: src/cowboy_stream.erl; @touch $@
src/cowboy_handler.erl:: src/cowboy_middleware.erl; @touch $@
src/cowboy_http.erl:: /mnt/hgfs/code/deps/cowboy-2.6.1/deps/cowlib/include/cow_inline.hrl /mnt/hgfs/code/deps/cowboy-2.6.1/deps/cowlib/include/cow_parse.hrl; @touch $@
src/cowboy_loop.erl:: src/cowboy_sub_protocol.erl; @touch $@
src/cowboy_metrics_h.erl:: src/cowboy_stream.erl; @touch $@
src/cowboy_rest.erl:: src/cowboy_sub_protocol.erl; @touch $@
src/cowboy_router.erl:: src/cowboy_middleware.erl; @touch $@
src/cowboy_stream_h.erl:: src/cowboy_stream.erl; @touch $@
src/cowboy_tracer_h.erl:: src/cowboy_stream.erl; @touch $@
src/cowboy_websocket.erl:: src/cowboy_sub_protocol.erl; @touch $@

COMPILE_FIRST += cowboy_sub_protocol cowboy_middleware cowboy_stream
