% Automatically generated, do not edit
-module(cfg_market_stype).

-compile([export_all]).
-compile(nowarn_export_all).

limit(1, 0) -> 700;
limit(1, 1) -> 100;
limit(1, 2) -> 100;
limit(1, 6) -> 100;
limit(1, 7) -> 100;
limit(1, 8) -> 100;
limit(1, 9) -> 100;
limit(1, 10) -> 100;
limit(2, 0) -> 700;
limit(2, 1) -> 100;
limit(2, 2) -> 100;
limit(2, 6) -> 100;
limit(2, 7) -> 100;
limit(2, 8) -> 100;
limit(2, 9) -> 100;
limit(2, 10) -> 100;
limit(3, 3) -> 100;
limit(3, 4) -> 100;
limit(3, 5) -> 100;
limit(4, 1) -> 100;
limit(4, 2) -> 100;
limit(4, 3) -> 100;
limit(4, 4) -> 100;
limit(4, 5) -> 100;
limit(5, 1) -> 100;
limit(5, 2) -> 100;
limit(5, 3) -> 100;
limit(5, 4) -> 100;
limit(5, 5) -> 100;
limit(5, 6) -> 100;
limit(5, 7) -> 100;
limit(5, 8) -> 100;
limit(5, 9) -> 100;
limit(6, 1) -> 100;
limit(6, 2) -> 100;
limit(6, 3) -> 100;
limit(6, 4) -> 100;
limit(6, 5) -> 100;
limit(6, 6) -> 100;
limit(6, 7) -> 100;
limit(6, 8) -> 100;
limit(6, 9) -> 100;
limit(6, 10) -> 100;
limit(6, 11) -> 100;
limit(6, 12) -> 100;
limit(7, 1) -> 100;
limit(7, 2) -> 100;
limit(7, 3) -> 100;
limit(7, 4) -> 100;
limit(7, 5) -> 100;
limit(7, 6) -> 100;
limit(7, 7) -> 100;
limit(7, 8) -> 100;
limit(7, 9) -> 100;
limit(7, 10) -> 100;
limit(8, 1) -> 100;
limit(8, 2) -> 100;
limit(8, 3) -> 100;
limit(8, 4) -> 100;
limit(8, 5) -> 100;
limit(8, 6) -> 100;
limit(8, 7) -> 100;
limit(8, 8) -> 100;
limit(8, 9) -> 100;
limit(8, 10) -> 100;
limit(8, 11) -> 100;
limit(8, 12) -> 100;
limit(8, 13) -> 100;
limit(9, 1) -> 100;
limit(9, 2) -> 100;
limit(9, 3) -> 100;
limit(9, 4) -> 100;
limit(9, 5) -> 100;
limit(9, 6) -> 100;
limit(9, 7) -> 100;
limit(9, 8) -> 100;
limit(9, 9) -> 100;
limit(9, 10) -> 100;
limit(9, 11) -> 100;
limit(10, 1) -> 100;
limit(10, 2) -> 100;
limit(10, 3) -> 100;
limit(10, 4) -> 100;
limit(10, 5) -> 100;
limit(_, _) -> 0.


stype(1) -> [1,2,6,7,8,9,10];
stype(2) -> [1,2,6,7,8,9,10];
stype(3) -> [3,4,5];
stype(4) -> [2,3,4,5,1];
stype(5) -> [1,2,3,4,5,7,8,6,9];
stype(6) -> [9,10,12,1,2,5,7,8,3,4,6,11];
stype(7) -> [1,2,5,7,8,9,3,4,6,10];
stype(8) -> [2,3,11,1,4,5,6,7,8,9,10,12,13];
stype(9) -> [2,3,5,9,10,1,4,6,7,8,11];
stype(10) -> [1,2,3,4,5];
stype(_) -> [].
