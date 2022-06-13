%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(db).

-include("game.hrl").
-include("table.hrl").

%% API
-export([
    on_game_start/0,
    %% Start, stop and debugging
    start/0, start/1, stop/0,   % Not for public use
    set_debug_level/1, % Not for public use
    change_config/2,

    %% Activity mgt
    abort/1, transaction/1, transaction/2, transaction/3,
    sync_transaction/1, sync_transaction/2, sync_transaction/3,
    async_dirty/1, async_dirty/2, sync_dirty/1, sync_dirty/2, ets/1, ets/2,
    activity/2, activity/3, activity/4, % Not for public use
    is_transaction/0,

    %% Access within an activity - Lock acquisition
    lock/2,
    read_lock_table/1,
    write_lock_table/1,

    %% Access within an activity - Updates
    write/1, s_write/1, write/3,
    delete/1, s_delete/1, delete/3,
    delete_object/1, s_delete_object/1, delete_object/3,

    %% Access within an activity - Reads
    read/1, read/2, wread/1, read/3,
    match_object/1, match_object/3,
    select/1,select/2,select/3,select/4,
    all_keys/1,
    index_match_object/2, index_match_object/4,
    index_read/3,
    first/1, next/2, last/1, prev/2,

    %% Iterators within an activity
    foldl/3, foldr/3,

    %% Dirty access regardless of activities - Updates
    dirty_write/1, dirty_write/2,
    dirty_delete/1, dirty_delete/2,
    dirty_delete_object/1, dirty_delete_object/2,
    dirty_update_counter/2, dirty_update_counter/3,

    %% Dirty access regardless of activities - Read
    dirty_read/1, dirty_read/2,
    dirty_select/2,
    dirty_match_object/1, dirty_match_object/2, dirty_all_keys/1,
    dirty_index_match_object/2, dirty_index_match_object/3,
    dirty_index_read/3, dirty_slot/2,
    dirty_first/1, dirty_next/2, dirty_last/1, dirty_prev/2,

    %% Info
    table_info/2, schema/0, schema/1,
    error_description/1, info/0, system_info/1,

    %% Database mgt
    create_schema/1, delete_schema/1,
    backup/1, backup/2, traverse_backup/4, traverse_backup/6,
    install_fallback/1, install_fallback/2,
    uninstall_fallback/0, uninstall_fallback/1,
    activate_checkpoint/1, deactivate_checkpoint/1,
    backup_checkpoint/2, backup_checkpoint/3, restore/2,

    %% Table mgt
    create_table/2, delete_table/1,
    add_table_copy/3, del_table_copy/2, move_table_copy/3,
    add_table_index/2, del_table_index/2,
    transform_table/3, transform_table/4,
    change_table_copy_type/3, change_table_majority/2,
    clear_table/1,

    %% Table load
    dump_tables/1, wait_for_tables/2, force_load_table/1,
    change_table_access_mode/2, change_table_load_order/2,
    set_master_nodes/1, set_master_nodes/2,

    %% Misc admin
    dump_log/0, sync_log/0,
    subscribe/1, unsubscribe/1, report_event/1,

    %% Snmp
    snmp_open_table/2, snmp_close_table/1,
    snmp_get_row/2, snmp_get_next_index/2, snmp_get_mnesia_key/2,

    %% Textfile access
    load_textfile/1, dump_to_textfile/1,

    %% QLC functions
    table/1, table/2,

    dirty_match_all/1
]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
on_game_start() ->
    TabList =
        case game_env:get_type() of
            ?SERVER_TYPE_LOCAL  ->
                table:tabs();
            _ ->
                table:cross_tabs() ++ table:game_tabs()
        end,
    lists:foreach(
        fun(#r_tab{name = TabName}) ->
            catch sign_frag(TabName)
        end, TabList),
    ok.

sign_frag(TabName) ->
    IsFrag =
        case table_info(TabName, frag_properties) of
            [] ->
                false;
            _ ->
                true
        end,
    KeyFrag = key_frag(TabName),
    mochiglobal:put(KeyFrag, IsFrag).

key_frag(TabName) ->
    ut_conv:to_atom(lists:concat(["frag_", TabName])).


db_operate(Tab, Fun, Args) ->
    db_operate(Tab, Fun, Fun, Args).

db_operate(Tab, Fun, FunOrigin, Args) ->
    KeyFrag = key_frag(Tab),
    case catch mochiglobal:get(KeyFrag) of
        true ->
            mnesia:activity(sync_dirty, Fun, [Args], mnesia_frag);
        _ ->
            FunOrigin(Args)
    end.


%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
abort(Reason) ->
    mnesia:abort(Reason).

activate_checkpoint(Args) ->
    mnesia:activate_checkpoint(Args).

activity(AccessContext, Fun) ->
    mnesia:activity(AccessContext, Fun).

activity(AccessContext, Fun, Args) when is_list(Args) ->
    activity(AccessContext, Fun, Args, mnesia_monitor:get_env(access_module));
activity(AccessContext, Fun, Mod) ->
    activity(AccessContext, Fun, [], Mod).

activity(AccessContext, Fun, Args, AccessMod) ->
    mnesia:activity(AccessContext, Fun, Args, AccessMod).

add_table_copy(Tab, Node, Type) ->
    mnesia:add_table_copy(Tab, Node, Type).

add_table_index(Tab, AttrName) ->
    mnesia:add_table_index(Tab, AttrName).

all_keys(Tab) ->
    Fun = fun(TabF) -> mnesia:all_keys(TabF) end,
    db_operate(Tab, Fun, Tab).

async_dirty(Fun) ->
    mnesia:async_dirty(Fun).

async_dirty(Fun, Args) ->
    mnesia:async_dirty(Fun, Args).

backup(Opaque) ->
    mnesia:backup(Opaque).

backup(Opaque, BackupMod) ->
    mnesia:backup(Opaque, BackupMod).

backup_checkpoint(Name, Opaque) ->
    mnesia:backup_checkpoint(Name, Opaque).

backup_checkpoint(Name, Opaque, BackupMod) ->
    mnesia:backup_checkpoint(Name, Opaque, BackupMod).

change_config(Config, Value) ->
    mnesia:change_config(Config, Value).

change_table_access_mode(Tab, AccessMode) ->
    mnesia:change_table_access_mode(Tab, AccessMode).

change_table_copy_type(Tab, Node, To) ->
    mnesia:change_table_copy_type(Tab, Node, To).

change_table_load_order(Tab, LoadOrder) ->
    mnesia:change_table_load_order(Tab, LoadOrder).

change_table_majority(Tab, Majority) ->
    mnesia:change_table_majority(Tab, Majority).

clear_table(Tab) ->
    Fun = fun(TabF) -> mnesia:clear_table(TabF) end,
    db_operate(Tab, Fun, Tab).

create_schema(DiscNodes) ->
    mnesia:create_schema(DiscNodes).

create_table(Name, TabDef) ->
    mnesia:create_table(Name, TabDef).

deactivate_checkpoint(Name) ->
    mnesia:deactivate_checkpoint(Name).

del_table_copy(Tab, Node) ->
    mnesia:del_table_copy(Tab, Node).

del_table_index(Tab, AttrName) ->
    mnesia:del_table_index(Tab, AttrName).

delete({Tab, Key}) ->
    Fun = fun({TabF, KeyF}) -> mnesia:delete({TabF, KeyF}) end,
    db_operate(Tab, Fun, {Tab, Key}).

delete(Tab, Key, LockKind) ->
    Fun = fun({TabF, KeyF, LockKindF}) -> mnesia:delete(TabF, KeyF, LockKindF) end,
    db_operate(Tab, Fun, {Tab, Key, LockKind}).

delete_object(Record) ->
    Fun = fun(RecordF) -> mnesia:delete_object(RecordF) end,
    db_operate(element(1, Record), Fun, Record).

delete_object(Tab, Record, LockKind) ->
    Fun = fun({TabF, RecordF, LockKindF}) -> mnesia:delete_object(TabF, RecordF, LockKindF) end,
    db_operate(Tab, Fun, {Tab, Record, LockKind}).

delete_schema(DiscNodes) ->
    mnesia:delete_schema(DiscNodes).

delete_table(Tab) ->
    mnesia:delete_table(Tab).

dirty_all_keys(Tab) ->
    Fun = fun(TabF) -> mnesia:all_keys(TabF) end,
    FunOrigin = fun(TabF) -> mnesia:dirty_all_keys(TabF) end,
    db_operate(Tab, Fun, FunOrigin, Tab).

dirty_delete({Tab, Key}) ->
    Fun = fun({TabF, KeyF}) -> mnesia:delete({TabF, KeyF}) end,
    FunOrigin = fun({TabF, KeyF}) -> mnesia:dirty_delete({TabF, KeyF}) end,
    db_operate(Tab, Fun, FunOrigin, {Tab, Key}).

dirty_delete(Tab, Key) ->
    Fun = fun({TabF, KeyF}) -> mnesia:delete({TabF, KeyF}) end,
    FunOrigin = fun({TabF, KeyF}) -> mnesia:dirty_delete(TabF, KeyF) end,
    db_operate(Tab, Fun, FunOrigin, {Tab, Key}).

dirty_delete_object(Record) ->
    dirty_delete_object(element(1, Record), Record).

dirty_delete_object(Tab, Record) ->
    Fun = fun(RecordF) -> mnesia:delete_object(RecordF) end,
    FunOrigin = fun(RecordF) -> mnesia:dirty_delete_object(RecordF) end,
    db_operate(Tab, Fun, FunOrigin, Record).

dirty_first(Tab) ->
    Fun = fun(TabF) -> mnesia:first(TabF) end,
    FunOrigin = fun(TabF) -> mnesia:dirty_first(TabF) end,
    db_operate(Tab, Fun, FunOrigin, Tab).

dirty_index_match_object(Pattern, Pos) ->
    dirty_index_match_object(element(1, Pattern), Pattern, Pos).

dirty_index_match_object(Tab, Pattern, Pos) ->
    Fun = fun({_TabF, PatternF, PosF}) -> mnesia:index_match_object(PatternF, PosF) end,
    FunOrigin = fun({TabF, PatternF, PosF}) -> mnesia:dirty_index_match_object(TabF, PatternF, PosF) end,
    db_operate(Tab, Fun, FunOrigin, {Tab, Pattern, Pos}).

dirty_index_read(Tab, SecondaryKey, Pos) ->
    Fun = fun({TabF, SecondaryKeyF, PosF}) -> mnesia:index_read(TabF, SecondaryKeyF, PosF) end,
    FunOrigin = fun({TabF, SecondaryKeyF, PosF}) -> mnesia:dirty_index_read(TabF, SecondaryKeyF, PosF) end,
    db_operate(Tab, Fun, FunOrigin, {Tab, SecondaryKey, Pos}).

dirty_last(Tab) ->
    Fun = fun(TabF) -> mnesia:last(TabF) end,
    FunOrigin = fun(TabF) -> mnesia:dirty_last(TabF) end,
    db_operate(Tab, Fun, FunOrigin, Tab).

dirty_match_object(Pattern) ->
    dirty_match_object(element(1, Pattern), Pattern).

dirty_match_object(Tab, Pattern) ->
    Fun = fun(PatternF) -> mnesia:match_object(PatternF) end,
    FunOrigin = fun(PatternF) -> mnesia:dirty_match_object(PatternF) end,
    db_operate(Tab, Fun, FunOrigin, Pattern).

dirty_next(Tab, Key) ->
    Fun = fun({TabF, KeyF}) -> mnesia:next(TabF, KeyF) end,
    FunOrigin = fun({TabF, KeyF}) -> mnesia:dirty_next(TabF, KeyF) end,
    db_operate(Tab, Fun, FunOrigin, {Tab, Key}).

dirty_prev(Tab, Key) ->
    Fun = fun({TabF, KeyF}) -> mnesia:prev(TabF, KeyF) end,
    FunOrigin = fun({TabF, KeyF}) -> mnesia:dirty_prev(TabF, KeyF) end,
    db_operate(Tab, Fun, FunOrigin, {Tab, Key}).

dirty_read({Tab, Key}) ->
    Fun = fun({TabF, KeyF}) -> mnesia:read({TabF, KeyF}) end,
    FunOrigin = fun({TabF, KeyF}) -> mnesia:dirty_read({TabF, KeyF}) end,
    db_operate(Tab, Fun, FunOrigin, {Tab, Key}).

dirty_read(Tab, Key) ->
    Fun = fun({TabF, KeyF}) -> mnesia:read(TabF, KeyF) end,
    FunOrigin = fun({TabF, KeyF}) -> mnesia:dirty_read(TabF, KeyF) end,
    db_operate(Tab, Fun, FunOrigin, {Tab, Key}).

dirty_select(Tab, MatchSpec) ->
    Fun = fun({TabF, MatchSpecF}) -> mnesia:select(TabF, MatchSpecF) end,
    FunOrigin = fun({TabF, MatchSpecF}) -> mnesia:dirty_select(TabF, MatchSpecF) end,
    db_operate(Tab, Fun, FunOrigin, {Tab, MatchSpec}).

dirty_slot(Tab, Slot) ->
    mnesia:dirty_slot(Tab, Slot).

dirty_update_counter({Tab, Key}, Incr) ->
    mnesia:dirty_update_counter({Tab, Key}, Incr).

dirty_update_counter(Tab, Key, Incr) ->
    mnesia:dirty_update_counter(Tab, Key, Incr).

dirty_write(Record) ->
    Fun = fun(RecordF) -> mnesia:write(RecordF) end,
    FunOrigin = fun(RecordF) -> mnesia:dirty_write(RecordF) end,
    db_operate(element(1, Record), Fun, FunOrigin, Record).

dirty_write(_Tab, Record) ->
    dirty_write(Record).

dump_log() ->
    mnesia:dump_log().

dump_tables(TabList) ->
    mnesia:dump_tables(TabList).

dump_to_textfile(Filename) ->
    mnesia:dump_to_textfile(Filename).

error_description(Error) ->
    mnesia:error_description(Error).

ets(Fun) ->
    mnesia:ets(Fun).

ets(Fun, Args) ->
    mnesia:ets(Fun, Args).

first(Tab) ->
    Fun = fun(TabF) -> mnesia:first(TabF) end,
    db_operate(Tab, Fun, Tab).

foldl(Function, Acc, Table) ->
    Fun = fun({FunctionF, AccF, TableF}) -> mnesia:foldl(FunctionF, AccF, TableF) end,
    db_operate(Table, Fun, {Function, Acc, Table}).

foldr(Function, Acc, Table) ->
    Fun = fun({FunctionF, AccF, TableF}) -> mnesia:foldr(FunctionF, AccF, TableF) end,
    db_operate(Table, Fun, {Function, Acc, Table}).

force_load_table(Tab) ->
    mnesia:force_load_table(Tab).

index_match_object(Pattern, Pos) ->
    Fun = fun({PatternF, PosF}) -> mnesia:index_match_object(PatternF, PosF) end,
    db_operate(element(1, Pattern), Fun, {Pattern, Pos}).

index_match_object(Tab, Pattern, Pos, LockKind) ->
    Fun = fun({TabF, PatternF, PosF, LockKindF}) -> mnesia:index_match_object(TabF, PatternF, PosF, LockKindF) end,
    db_operate(Tab, Fun, {Tab, Pattern, Pos, LockKind}).

index_read(Tab, SecondaryKey, Pos) ->
    Fun = fun({TabF, SecondaryKeyF, PosF}) -> mnesia:index_read(TabF, SecondaryKeyF, PosF) end,
    db_operate(Tab, Fun, {Tab, SecondaryKey, Pos}).

info() ->
    mnesia:info().

install_fallback(Opaque) ->
    mnesia:install_fallback(Opaque).

install_fallback(Opaque, BackupMod) ->
    mnesia:install_fallback(Opaque, BackupMod).

is_transaction() ->
    mnesia:is_transaction().

last(Tab) ->
    Fun = fun(TabF) -> mnesia:last(TabF) end,
    db_operate(Tab, Fun, Tab).

load_textfile(Filename) ->
    mnesia:load_textfile(Filename).

lock(LockItem, LockKind) ->
    mnesia:lock(LockItem, LockKind).

match_object(Pattern) ->
    Fun = fun(PatternF) -> mnesia:match_object(PatternF) end,
    db_operate(element(1, Pattern), Fun, Pattern).

match_object(Tab, Pattern, LockKind) ->
    Fun = fun({TabF, PatternF, LockKindF}) -> mnesia:match_object(TabF, PatternF, LockKindF) end,
    db_operate(Tab, Fun, {Tab, Pattern, LockKind}).

move_table_copy(Tab, From, To) ->
    mnesia:move_table_copy(Tab, From, To).

next(Tab, Key) ->
    Fun = fun({TabF, KeyF}) -> mnesia:next(TabF, KeyF) end,
    db_operate(Tab, Fun, {Tab, Key}).

prev(Tab, Key) ->
    Fun = fun({TabF, KeyF}) -> mnesia:prev(TabF, KeyF) end,
    db_operate(Tab, Fun, {Tab, Key}).

read({Tab, Key}) ->
    Fun = fun({TabF, KeyF}) -> mnesia:read({TabF, KeyF}) end,
    db_operate(Tab, Fun, {Tab, Key}).

read(Tab, Key) ->
    Fun = fun({TabF, KeyF}) -> mnesia:read(TabF, KeyF) end,
    db_operate(Tab, Fun, {Tab, Key}).

read(Tab, Key, LockKind) ->
    Fun = fun({TabF, KeyF, LockKindF}) -> mnesia:read(TabF, KeyF, LockKindF) end,
    db_operate(Tab, Fun, {Tab, Key, LockKind}).

read_lock_table(Tab) ->
    mnesia:read_lock_table(Tab).

report_event(Event) ->
    mnesia:report_event(Event).

restore(Opaque, Args) ->
    mnesia:restore(Opaque, Args).

s_delete({Tab, Key}) ->
    mnesia:s_delete({Tab, Key}).

s_delete_object(Record) ->
    mnesia:s_delete_object(Record).

s_write(Record) ->
    mnesia:s_write(Record).

schema() ->
    mnesia:schema().

schema(Tab) ->
    mnesia:schema(Tab).

select(Tab, MatchSpec) ->
    mnesia:select(Tab, MatchSpec).

select(Tab, MatchSpec, Lock) ->
    mnesia:select(Tab, MatchSpec, Lock).

select(Tab, MatchSpec, NObjects, Lock) ->
    mnesia:select(Tab, MatchSpec, NObjects, Lock).

select(Cont) ->
    mnesia:select(Cont).

set_debug_level(Level) ->
    mnesia:set_debug_level(Level).

set_master_nodes(MasterNodes) ->
    mnesia:set_master_nodes(MasterNodes).

set_master_nodes(Tab, MasterNodes) ->
    mnesia:set_master_nodes(Tab, MasterNodes).

snmp_close_table(Tab) ->
    mnesia:snmp_close_table(Tab).

snmp_get_mnesia_key(Tab, RowIndex) ->
    mnesia:snmp_get_mnesia_key(Tab, RowIndex).

snmp_get_next_index(Tab, RowIndex) ->
    mnesia:snmp_get_next_index(Tab, RowIndex).

snmp_get_row(Tab, RowIndex) ->
    mnesia:snmp_get_row(Tab, RowIndex).

snmp_open_table(Tab, SnmpStruct) ->
    mnesia:snmp_open_table(Tab, SnmpStruct).

start() ->
    mnesia:start().

start(ExtraEnv) ->
    mnesia:start(ExtraEnv).

stop() ->
    mnesia:stop().

subscribe(EventCategory) ->
    mnesia:subscribe(EventCategory).

sync_dirty(Fun) ->
    mnesia:sync_dirty(Fun).

sync_dirty(Fun, Args) ->
    mnesia:sync_dirty(Fun, Args).

sync_log() ->
    mnesia:sync_log().

sync_transaction(Fun) ->
    mnesia:sync_transaction(Fun).

sync_transaction(Fun, Retries) ->
    mnesia:sync_transaction(Fun, Retries).

sync_transaction(Fun, Args, Retries) ->
    mnesia:sync_transaction(Fun, Args, Retries).

system_info(InfoKey) ->
    mnesia:system_info(InfoKey).

table(Tab) ->
    mnesia:table(Tab).

table(Tab, Option) ->
    mnesia:table(Tab, Option).

table_info(Tab, InfoKey) ->
    Fun = fun({TabF, InfoKeyF}) -> mnesia:table_info(TabF, InfoKeyF) end,
    db_operate(Tab, Fun, {Tab, InfoKey}).

transaction(Fun) ->
    mnesia:transaction(Fun).

transaction(Fun, Retries) ->
    mnesia:transaction(Fun, Retries).

transaction(Fun, Args, Retries) ->
    mnesia:transaction(Fun, Args, Retries).

transform_table(Tab, Fun, NewAttributeList, NewRecordName) ->
    mnesia:transform_table(Tab, Fun, NewAttributeList, NewRecordName).

transform_table(Tab, Fun, NewAttributeList) ->
    mnesia:transform_table(Tab, Fun, NewAttributeList).

traverse_backup(Source, Target, Fun, Acc) ->
    mnesia:traverse_backup(Source, Target, Fun, Acc).

traverse_backup(Source, SourceMod, Target, TargetMod, Fun, Acc) ->
    mnesia:traverse_backup(Source, SourceMod, Target, TargetMod, Fun, Acc).

uninstall_fallback() ->
    mnesia:uninstall_fallback().

uninstall_fallback(Args) ->
    mnesia:uninstall_fallback(Args).

unsubscribe(EventCategory) ->
    mnesia:unsubscribe(EventCategory).

wait_for_tables(TabList, Timeout) ->
    mnesia:wait_for_tables(TabList, Timeout).

wread({Tab, Key}) ->
    mnesia:wread({Tab, Key}).

write(Record) ->
    Fun = fun(RecordF) -> mnesia:write(RecordF) end,
    db_operate(element(1, Record), Fun, Record).

write(Tab, Record, LockKind) ->
    Fun = fun({TabF, RecordF, LockKindF}) -> mnesia:write(TabF, RecordF, LockKindF) end,
    db_operate(Tab, Fun, {Tab, Record, LockKind}).

write_lock_table(Tab) ->
    mnesia:write_lock_table(Tab).

dirty_match_all(Tab)->
    Pattern = mnesia:table_info(Tab, wild_pattern),
    Fun = fun({_TabF, PatternF}) -> mnesia:match_object(PatternF) end,
    FunOrigin = fun({TabF, PatternF}) -> mnesia:dirty_match_object(TabF, PatternF) end,
    db_operate(Tab, Fun, FunOrigin, {Tab, Pattern}).
%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
