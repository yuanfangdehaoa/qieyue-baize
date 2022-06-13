% Automatically generated, do not edit
-module(cfg_flower_honey).

-compile([export_all]).
-compile(nowarn_export_all).

-include("friend.hrl").

buff_ids(Intimacy) when Intimacy >= 0 andalso Intimacy < 999 ->
	130140000;
buff_ids(Intimacy) when Intimacy >= 999 andalso Intimacy < 1999 ->
	130140001;
buff_ids(Intimacy) when Intimacy >= 1999 andalso Intimacy < 3344 ->
	130140002;
buff_ids(Intimacy) when Intimacy >= 3344 andalso Intimacy < 5200 ->
	130140003;
buff_ids(Intimacy) when Intimacy >= 5200 andalso Intimacy < 9999 ->
	130140004;
buff_ids(Intimacy) when Intimacy >= 9999 andalso Intimacy < 16920 ->
	130140005;
buff_ids(Intimacy) when Intimacy >= 16920 andalso Intimacy < 28920 ->
	130140006;
buff_ids(Intimacy) when Intimacy >= 28920 andalso Intimacy < 49999 ->
	130140007;
buff_ids(Intimacy) when Intimacy >= 49999 andalso Intimacy < 99999 ->
	130140008;
buff_ids(Intimacy) when Intimacy >= 99999 andalso Intimacy < 199999 ->
	130140009;
buff_ids(Intimacy) when Intimacy >= 199999 andalso Intimacy < 999999999 ->
	130140010;
buff_ids(_) -> undefined.

all_buff_ids() -> [130140001,130140002,130140003,130140007,130140009,130140010,130140000,130140004,130140005,130140006,130140008].
