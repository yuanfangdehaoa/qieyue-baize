% Automatically generated, do not edit
-module(cfg_mount_train).

-compile([export_all]).
-compile(nowarn_export_all).

attrs(54110) -> [{2,2400}];
attrs(54111) -> [{2,12000},{5,600},{1202,200},{1204,200},{1205,200},{1206,200},{1207,200},{1208,200},{1209,200},{1210,200},{1211,200},{1212,200}];
attrs(54112) -> [{5,120}];
attrs(_) -> [].

limit(54110) -> [{1,370,99999},{371,450,99999},{451,600,99999},{601,9999,99999}];
limit(54111) -> [{1,370,99999},{371,450,99999},{451,600,99999},{601,9999,99999}];
limit(54112) -> [{1,370,99999},{371,450,99999},{451,600,99999},{601,9999,99999}];
limit(_) -> undefined.

all() -> [54111,54112,54110].