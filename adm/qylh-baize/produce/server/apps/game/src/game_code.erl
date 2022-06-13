-module(game_code).

-export([clash/0]).

clash() ->
    Path = get_path(),
    Struct = lists:flatten(build(Path)),
    Len = length(search(Struct)),
    case Len == 0 of
      true  ->
        ok;
      false ->
        io:format("** Found ~w name clashes in code paths ~n", [Len]),
        error
    end.

get_path() -> call(get_path).

call(Req) ->
    code_server:call(Req).

objfile_extension() ->
    init:objfile_extension().

search([]) -> [];
search([{Dir, File} | Tail]) ->
    case lists:keyfind(File, 2, Tail) of
	false ->
	    search(Tail);
	{Dir2, File} ->
	    io:format("** ~ts hides ~ts~n",
		      [filename:join(Dir, File),
		       filename:join(Dir2, File)]),
	    [clash | search(Tail)]
    end.

build([]) -> [];
build([Dir|Tail]) ->
    Files = filter(objfile_extension(), Dir,
		   erl_prim_loader:list_dir(Dir)),
    [decorate(Files, Dir) | build(Tail)].

decorate([], _) -> [];
decorate([File|Tail], Dir) ->
    [{Dir, File} | decorate(Tail, Dir)].

filter(_Ext, Dir, error) ->
    io:format("** Bad path can't read ~ts~n", [Dir]), [];
filter(Ext, _, {ok,Files}) ->
    filter2(Ext, length(Ext), Files).

filter2(_Ext, _Extlen, []) -> [];
filter2(Ext, Extlen, [File|Tail]) ->
    case has_ext(Ext, Extlen, File) of
	true -> [File | filter2(Ext, Extlen, Tail)];
	false -> filter2(Ext, Extlen, Tail)
    end.

has_ext(Ext, Extlen, File) ->
    L = length(File),
    case catch lists:nthtail(L - Extlen, File) of
	Ext -> true;
	_ -> false
    end.

