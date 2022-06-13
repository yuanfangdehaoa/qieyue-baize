% Automatically generated, do not edit
-module(cfg_arena_high_rank).

-compile([export_all]).
-compile(nowarn_export_all).

-include("arena.hrl").

find(1) -> #cfg_arena_high_rank{rank=1, reward=[{90010004,25000}]};
find(2) -> #cfg_arena_high_rank{rank=2, reward=[{90010004,22500}]};
find(3) -> #cfg_arena_high_rank{rank=3, reward=[{90010004,20000}]};
find(4) -> #cfg_arena_high_rank{rank=10, reward=[{90010004,17500}]};
find(5) -> #cfg_arena_high_rank{rank=30, reward=[{90010004,15000}]};
find(6) -> #cfg_arena_high_rank{rank=50, reward=[{90010004,12500}]};
find(7) -> #cfg_arena_high_rank{rank=100, reward=[{90010004,10000}]};
find(8) -> #cfg_arena_high_rank{rank=150, reward=[{90010004,7500}]};
find(9) -> #cfg_arena_high_rank{rank=200, reward=[{90010004,6000}]};
find(10) -> #cfg_arena_high_rank{rank=250, reward=[{90010004,5000}]};
find(11) -> #cfg_arena_high_rank{rank=300, reward=[{90010004,4000}]};
find(12) -> #cfg_arena_high_rank{rank=350, reward=[{90010004,3500}]};
find(13) -> #cfg_arena_high_rank{rank=400, reward=[{90010004,3250}]};
find(14) -> #cfg_arena_high_rank{rank=500, reward=[{90010004,3000}]};
find(15) -> #cfg_arena_high_rank{rank=600, reward=[{90010004,2750}]};
find(16) -> #cfg_arena_high_rank{rank=650, reward=[{90010004,2500}]};
find(17) -> #cfg_arena_high_rank{rank=700, reward=[{90010004,2250}]};
find(18) -> #cfg_arena_high_rank{rank=750, reward=[{90010004,2000}]};
find(19) -> #cfg_arena_high_rank{rank=800, reward=[{90010004,1750}]};
find(20) -> #cfg_arena_high_rank{rank=850, reward=[{90010004,1500}]};
find(21) -> #cfg_arena_high_rank{rank=1000, reward=[{90010004,1000}]};
find(22) -> #cfg_arena_high_rank{rank=3000, reward=[{90010004,500}]};
find(_) -> undefined.

all() -> [5,6,14,19,2,3,10,16,18,20,4,7,12,15,17,21,22,1,8,9,11,13].
