% Automatically generated, do not edit
-module(cfg_combat1v1_local_grade).

-compile([export_all]).
-compile(nowarn_export_all).

-include("combat1v1.hrl").


grade(Score) when Score < 40 -> 11;
grade(Score) when Score < 80 -> 12;
grade(Score) when Score < 120 -> 13;
grade(Score) when Score < 160 -> 14;
grade(Score) when Score < 200 -> 15;
grade(Score) when Score < 280 -> 21;
grade(Score) when Score < 360 -> 22;
grade(Score) when Score < 440 -> 23;
grade(Score) when Score < 520 -> 24;
grade(Score) when Score < 600 -> 25;
grade(Score) when Score < 720 -> 31;
grade(Score) when Score < 840 -> 32;
grade(Score) when Score < 960 -> 33;
grade(Score) when Score < 1080 -> 34;
grade(Score) when Score < 1200 -> 35;
grade(Score) when Score < 1400 -> 41;
grade(Score) when Score < 1600 -> 42;
grade(Score) when Score < 1800 -> 43;
grade(Score) when Score < 2000 -> 44;
grade(Score) when Score < 2200 -> 45;
grade(Score) when Score < 2500 -> 51;
grade(Score) when Score < 2800 -> 52;
grade(Score) when Score < 3100 -> 53;
grade(Score) when Score < 3400 -> 54;
grade(Score) when Score < 3800 -> 55;
grade(Score) when Score < 4200 -> 61;
grade(Score) when Score < 4600 -> 62;
grade(Score) when Score < 5000 -> 63;
grade(Score) when Score < 5400 -> 64;
grade(Score) when Score < 999999999 -> 65.

find(11) -> #cfg_combat1v1_grade{name="青铜5阶", grade=11, score=40,  win_score=30, lose_score=3, win_merit=50, lose_merit=30, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,1000,1}]};
find(12) -> #cfg_combat1v1_grade{name="青铜4阶", grade=12, score=80,  win_score=30, lose_score=3, win_merit=50, lose_merit=30, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,1400,1}]};
find(13) -> #cfg_combat1v1_grade{name="青铜3阶", grade=13, score=120,  win_score=30, lose_score=3, win_merit=50, lose_merit=30, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,1800,1}]};
find(14) -> #cfg_combat1v1_grade{name="青铜2阶", grade=14, score=160,  win_score=30, lose_score=3, win_merit=50, lose_merit=30, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,2200,1}]};
find(15) -> #cfg_combat1v1_grade{name="青铜1阶", grade=15, score=200,  win_score=30, lose_score=3, win_merit=50, lose_merit=30, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,2600,1}]};
find(21) -> #cfg_combat1v1_grade{name="白银5阶", grade=21, score=280,  win_score=40, lose_score=4, win_merit=60, lose_merit=36, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,3200,1}]};
find(22) -> #cfg_combat1v1_grade{name="白银4阶", grade=22, score=360,  win_score=40, lose_score=4, win_merit=60, lose_merit=36, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,3800,1}]};
find(23) -> #cfg_combat1v1_grade{name="白银3阶", grade=23, score=440,  win_score=40, lose_score=4, win_merit=60, lose_merit=36, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,4400,1}]};
find(24) -> #cfg_combat1v1_grade{name="白银2阶", grade=24, score=520,  win_score=40, lose_score=4, win_merit=60, lose_merit=36, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,5000,1}]};
find(25) -> #cfg_combat1v1_grade{name="白银1阶", grade=25, score=600,  win_score=40, lose_score=4, win_merit=60, lose_merit=36, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,5600,1}]};
find(31) -> #cfg_combat1v1_grade{name="黄金5阶", grade=31, score=720,  win_score=60, lose_score=6, win_merit=70, lose_merit=42, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,6400,1}]};
find(32) -> #cfg_combat1v1_grade{name="黄金4阶", grade=32, score=840,  win_score=60, lose_score=6, win_merit=70, lose_merit=42, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,7200,1}]};
find(33) -> #cfg_combat1v1_grade{name="黄金3阶", grade=33, score=960,  win_score=60, lose_score=6, win_merit=70, lose_merit=42, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,8000,1}]};
find(34) -> #cfg_combat1v1_grade{name="黄金2阶", grade=34, score=1080,  win_score=60, lose_score=6, win_merit=70, lose_merit=42, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,8800,1}]};
find(35) -> #cfg_combat1v1_grade{name="黄金1阶", grade=35, score=1200,  win_score=60, lose_score=6, win_merit=70, lose_merit=42, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,9600,1}]};
find(41) -> #cfg_combat1v1_grade{name="铂金5阶", grade=41, score=1400,  win_score=90, lose_score=9, win_merit=80, lose_merit=48, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,10600,1}]};
find(42) -> #cfg_combat1v1_grade{name="铂金4阶", grade=42, score=1600,  win_score=90, lose_score=9, win_merit=80, lose_merit=48, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,11600,1}]};
find(43) -> #cfg_combat1v1_grade{name="铂金3阶", grade=43, score=1800,  win_score=90, lose_score=9, win_merit=80, lose_merit=48, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,12600,1}]};
find(44) -> #cfg_combat1v1_grade{name="铂金2阶", grade=44, score=2000,  win_score=90, lose_score=9, win_merit=80, lose_merit=48, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,13600,1}]};
find(45) -> #cfg_combat1v1_grade{name="铂金1阶", grade=45, score=2200,  win_score=90, lose_score=9, win_merit=80, lose_merit=48, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,14600,1}]};
find(51) -> #cfg_combat1v1_grade{name="钻石5阶", grade=51, score=2500,  win_score=120, lose_score=12, win_merit=90, lose_merit=54, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,15800,1}]};
find(52) -> #cfg_combat1v1_grade{name="钻石4阶", grade=52, score=2800,  win_score=120, lose_score=12, win_merit=90, lose_merit=54, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,17000,1}]};
find(53) -> #cfg_combat1v1_grade{name="钻石3阶", grade=53, score=3100,  win_score=120, lose_score=12, win_merit=90, lose_merit=54, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,18200,1}]};
find(54) -> #cfg_combat1v1_grade{name="钻石2阶", grade=54, score=3400,  win_score=120, lose_score=12, win_merit=90, lose_merit=54, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,19400,1}]};
find(55) -> #cfg_combat1v1_grade{name="钻石1阶", grade=55, score=3800,  win_score=120, lose_score=12, win_merit=90, lose_merit=54, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,20600,1}]};
find(61) -> #cfg_combat1v1_grade{name="王者5阶", grade=61, score=4200,  win_score=150, lose_score=15, win_merit=100, lose_merit=60, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,22000,1}]};
find(62) -> #cfg_combat1v1_grade{name="王者4阶", grade=62, score=4600,  win_score=150, lose_score=15, win_merit=100, lose_merit=60, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,24000,1}]};
find(63) -> #cfg_combat1v1_grade{name="王者3阶", grade=63, score=5000,  win_score=150, lose_score=15, win_merit=100, lose_merit=60, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,26000,1}]};
find(64) -> #cfg_combat1v1_grade{name="王者2阶", grade=64, score=5400,  win_score=150, lose_score=15, win_merit=100, lose_merit=60, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,28000,1}]};
find(65) -> #cfg_combat1v1_grade{name="王者1阶", grade=65, score=0,  win_score=150, lose_score=15, win_merit=100, lose_merit=60, win_reward=[{90010018,750,1},{90010008,1000,1},{52000,2,1}], lose_reward=[{90010018,375,1},{90010008,500,1},{52000,1,1}], daily_reward=[{90010008,30000,1}]};
find(_) -> undefined.
