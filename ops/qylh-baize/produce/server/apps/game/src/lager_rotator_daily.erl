-module(lager_rotator_daily).

-include_lib("kernel/include/file.hrl").

-behaviour(lager_rotator_behaviour).

-export([
    create_logfile/2, open_logfile/2, ensure_logfile/4, rotate_logfile/2
]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

create_logfile(Name, Buffer) ->
    open_logfile(Name, Buffer).

open_logfile(Name, Buffer) ->
    case filelib:ensure_dir(Name) of
        ok ->
            Options = [append, raw] ++
            case  Buffer of
                {Size, Interval} when is_integer(Interval), Interval >= 0, is_integer(Size), Size >= 0 ->
                    [{delayed_write, Size, Interval}];
                _ -> []
            end,
            case file:open(Name, Options) of
                {ok, FD} ->
                    case file:read_file_info(Name) of
                        {ok, FInfo} ->
                            Inode = FInfo#file_info.inode,
                            {ok, {FD, Inode, FInfo#file_info.size}};
                        X -> X
                    end;
                Y -> Y
            end;
        Z -> Z
    end.

ensure_logfile(Name, FD, Inode, Buffer) ->
    case file:read_file_info(Name) of
        {ok, FInfo} ->
            Inode2 = FInfo#file_info.inode,
            case Inode == Inode2 of
                true ->
                    {ok, {FD, Inode, FInfo#file_info.size}};
                false ->
                    %% delayed write can cause file:close not to do a close
                    _ = file:close(FD),
                    _ = file:close(FD),
                    case open_logfile(Name, Buffer) of
                        {ok, {FD2, Inode3, Size}} ->
                            %% inode changed, file was probably moved and
                            %% recreated
                            {ok, {FD2, Inode3, Size}};
                        Error ->
                            Error
                    end
            end;
        _ ->
            %% delayed write can cause file:close not to do a close
            _ = file:close(FD),
            _ = file:close(FD),
            case open_logfile(Name, Buffer) of
                {ok, {FD2, Inode3, Size}} ->
                    %% file was removed
                    {ok, {FD2, Inode3, Size}};
                Error ->
                    Error
            end
    end.

%% renames failing are OK
rotate_logfile(File, 0) ->
    %% open the file in write-only mode to truncate/create it
    case file:open(File, [write]) of
        {ok, FD} ->
            file:close(FD),
            ok;
        Error ->
            Error
    end;
rotate_logfile(File, _Count) ->
	GregDays = calendar:date_to_gregorian_days(date()) - 1,
	{Y,M,D}  = calendar:gregorian_days_to_date(GregDays),
    _ = file:rename(File, File++io_lib:format(".~4..0B~2..0B~2..0B", [Y, M, D])),
    rotate_logfile(File, 0).
