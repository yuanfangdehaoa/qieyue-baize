%% @author rong
%% @doc
-module(ut_color).

-include("enum.hrl").

-export([format/2]).
-export([name/1]).

format(Name, Color) ->
    lists:concat(["<color=", color(Color), ">", Name, "</color>"]).

name(?COLOR_WHITE)  -> "白色";
name(?COLOR_GREEN)  -> "绿色";
name(?COLOR_BLUE)   -> "蓝色";
name(?COLOR_PURPLE) -> "紫色";
name(?COLOR_ORANGE) -> "橙色";
name(?COLOR_RED)    -> "红色";
name(?COLOR_PINK)   -> "粉色".

color(?COLOR_WHITE)  -> "#ffffff";
color(?COLOR_GREEN)  -> "#6ce19b";
color(?COLOR_BLUE)   -> "#3ec5fe";
color(?COLOR_PURPLE) -> "#9c48f2";
color(?COLOR_ORANGE) -> "#e08225";
color(?COLOR_RED)    -> "#e63232";
color(?COLOR_PINK)   -> "#d622e6".