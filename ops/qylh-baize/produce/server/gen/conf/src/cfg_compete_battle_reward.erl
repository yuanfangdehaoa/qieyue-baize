% Automatically generated, do not edit
-module(cfg_compete_battle_reward).

-compile([export_all]).
-compile(nowarn_export_all).

win(1, true, 1) -> [{90010004,5000},{90010029,60},{10301,2},{100041,1},{11128,1}];
win(2, true, 1) -> [{90010004,5000},{90010029,60},{10301,2},{100041,1},{11128,1}];
win(3, true, 1) -> [{90010004,5000},{90010029,60},{10301,2},{100041,1},{11128,1}];
win(4, true, 1) -> [{90010004,5000},{90010029,60},{10301,2},{100041,1},{11128,1}];
win(5, true, 1) -> [{90010004,5000},{90010029,60},{10301,2},{100041,1},{11128,1}];
win(6, true, 1) -> [{90010004,5000},{90010029,60},{10301,2},{100041,1},{11128,1}];
win(7, true, 1) -> [{90010004,5000},{90010029,60},{10301,2},{100041,1},{11128,1}];
win(8, true, 1) -> [{90010004,5000},{90010029,60},{10301,2},{100041,1},{11128,1}];
win(1, true, 3) -> [{90010004,5000},{90010029,100},{10301,3},{100033,1},{11129,1}];
win(2, true, 3) -> [{90010004,10000},{90010029,150},{10301,3},{100033,1},{11129,1}];
win(3, true, 3) -> [{90010004,15000},{90010029,150},{10301,3},{100033,1},{11129,1}];
win(4, true, 3) -> [{90010004,15000},{90010029,200},{10301,3},{100033,1},{11129,1}];
win(1, true, 2) -> [{90010004,25000},{90010029,300},{10301,3},{100033,1},{11129,1}];
win(2, true, 2) -> [{90010004,40000},{90010029,300},{10301,3},{100033,1},{11129,1}];
win(3, true, 2) -> [{90010003,5000},{90010029,450},{10301,3},{100033,1},{11129,1}];
win(4, true, 2) -> [{90010003,10000},{90010029,600},{10301,3},{100033,1},{11129,1}];
win(1, false, 1) -> [{90010004,5000},{90010029,100},{10301,5},{100042,1},{11128,1}];
win(2, false, 1) -> [{90010004,5000},{90010029,100},{10301,5},{100042,1},{11128,1}];
win(3, false, 1) -> [{90010004,5000},{90010029,100},{10301,5},{100042,1},{11128,1}];
win(4, false, 1) -> [{90010004,5000},{90010029,100},{10301,5},{100042,1},{11128,1}];
win(5, false, 1) -> [{90010004,5000},{90010029,100},{10301,5},{100042,1},{11128,1}];
win(6, false, 1) -> [{90010004,5000},{90010029,100},{10301,5},{100042,1},{11128,1}];
win(7, false, 1) -> [{90010004,5000},{90010029,100},{10301,5},{100042,1},{11128,1}];
win(8, false, 1) -> [{90010004,5000},{90010029,100},{10301,5},{100042,1},{11128,1}];
win(1, false, 3) -> [{90010004,5000},{90010029,100},{10301,5},{100042,1},{11128,1}];
win(2, false, 3) -> [{90010004,10000},{90010029,150},{10301,5},{100034,1},{11129,1}];
win(3, false, 3) -> [{90010003,5000},{90010029,300},{10301,5},{100034,1},{11129,1}];
win(4, false, 3) -> [{90010003,10000},{90010029,500},{10301,5},{100034,1},{11129,1}];
win(1, false, 2) -> [{90010004,25000},{90010029,300},{10301,5},{100034,1},{11129,1}];
win(2, false, 2) -> [{90010004,40000},{90010029,500},{10301,5},{100034,1},{11129,1}];
win(3, false, 2) -> [{90010003,25000},{90010029,1000},{10301,5},{100034,1},{11129,1}];
win(4, false, 2) -> [{90010003,50000},{90010029,2000},{10301,5},{100034,1},{11129,1}];
win(_, _, _) -> [].

lose(1, true, 1) -> [{90010004,2500},{90010029,30},{10301,2},{100041,1},{11128,1}];
lose(2, true, 1) -> [{90010004,2500},{90010029,30},{10301,2},{100041,1},{11128,1}];
lose(3, true, 1) -> [{90010004,2500},{90010029,30},{10301,2},{100041,1},{11128,1}];
lose(4, true, 1) -> [{90010004,2500},{90010029,30},{10301,2},{100041,1},{11128,1}];
lose(5, true, 1) -> [{90010004,2500},{90010029,30},{10301,2},{100041,1},{11128,1}];
lose(6, true, 1) -> [{90010004,2500},{90010029,30},{10301,2},{100041,1},{11128,1}];
lose(7, true, 1) -> [{90010004,2500},{90010029,30},{10301,2},{100041,1},{11128,1}];
lose(8, true, 1) -> [{90010004,2500},{90010029,30},{10301,2},{100041,1},{11128,1}];
lose(1, true, 3) -> [{90010004,2500},{90010029,50},{10301,3},{100033,1},{11129,1}];
lose(2, true, 3) -> [{90010004,5000},{90010029,100},{10301,3},{100033,1},{11129,1}];
lose(3, true, 3) -> [{90010004,5000},{90010029,100},{10301,3},{100033,1},{11129,1}];
lose(4, true, 3) -> [{90010004,7500},{90010029,150},{10301,3},{100033,1},{11129,1}];
lose(1, true, 2) -> [{90010004,15000},{90010029,150},{10301,3},{100033,1},{11129,1}];
lose(2, true, 2) -> [{90010004,15000},{90010029,150},{10301,3},{100033,1},{11129,1}];
lose(3, true, 2) -> [{90010004,15000},{90010029,150},{10301,3},{100033,1},{11129,1}];
lose(4, true, 2) -> [{90010004,25000},{90010029,150},{10301,3},{100033,1},{11129,1}];
lose(1, false, 1) -> [{90010004,2500},{90010029,50},{10301,5},{100042,1},{11128,1}];
lose(2, false, 1) -> [{90010004,2500},{90010029,50},{10301,5},{100042,1},{11128,1}];
lose(3, false, 1) -> [{90010004,2500},{90010029,50},{10301,5},{100042,1},{11128,1}];
lose(4, false, 1) -> [{90010004,2500},{90010029,50},{10301,5},{100042,1},{11128,1}];
lose(5, false, 1) -> [{90010004,2500},{90010029,50},{10301,5},{100042,1},{11128,1}];
lose(6, false, 1) -> [{90010004,2500},{90010029,50},{10301,5},{100042,1},{11128,1}];
lose(7, false, 1) -> [{90010004,2500},{90010029,50},{10301,5},{100042,1},{11128,1}];
lose(8, false, 1) -> [{90010004,2500},{90010029,50},{10301,5},{100042,1},{11128,1}];
lose(1, false, 3) -> [{90010004,2500},{90010029,50},{10301,5},{100042,1},{11128,1}];
lose(2, false, 3) -> [{90010004,5000},{90010029,100},{10301,5},{100034,1},{11129,1}];
lose(3, false, 3) -> [{90010004,10000},{90010029,150},{10301,5},{100034,1},{11129,1}];
lose(4, false, 3) -> [{90010004,15000},{90010029,300},{10301,5},{100034,1},{11129,1}];
lose(1, false, 2) -> [{90010004,15000},{90010029,150},{10301,5},{100034,1},{11129,1}];
lose(2, false, 2) -> [{90010004,25000},{90010029,500},{10301,5},{100034,1},{11129,1}];
lose(3, false, 2) -> [{90010004,40000},{90010029,500},{10301,5},{100034,1},{11129,1}];
lose(4, false, 2) -> [{90010004,50000},{90010029,1000},{10301,5},{100034,1},{11129,1}];
lose(_, _, _) -> [].
