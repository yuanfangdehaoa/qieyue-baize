%%%=============================================================================
%%% @author z.hua
%%% @doc
%%% 敏感词过滤
%%% @end
%%%=============================================================================

-module(ut_word).

%% API
-export([is_sensitive/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
is_sensitive([], _Filter) ->
	false;
is_sensitive(Str, Filter) ->
	UniStr = unicode:characters_to_list(Str, 'utf8'),
	check(string:to_lower(UniStr), Filter).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check(Str = [Char | Tail], Filter) ->
	StrLen = length(Str),
	Words  = Filter([Char]),
	Match  = lists:any(fun
		(Word) ->
			WordLen = length(Word),
			if
				StrLen < WordLen  ->
					false;
				StrLen == WordLen ->
					Word == Str;
				StrLen > WordLen  ->
					Word == lists:sublist(Str, WordLen)
			end
	end, Words),
	case Match of
		true  -> true;
		false -> check(Tail, Filter)
	end;
check([], _Filter) ->
	false.
