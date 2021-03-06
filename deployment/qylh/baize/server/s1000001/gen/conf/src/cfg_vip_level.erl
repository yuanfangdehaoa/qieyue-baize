% Automatically generated, do not edit
-module(cfg_vip_level).

-compile([export_all]).
-compile(nowarn_export_all).

-include("vip.hrl").

find(0) -> #cfg_vip_level{
	level  = 0,
	exp    = 0,
	reward = [{90010005,50000,1}],
	gift   = [],
	gold   = 1200000,
	bgold  = 1200000,
	vipexp = 0,
	buffs  = [],
	attrs  = []
};
find(1) -> #cfg_vip_level{
	level  = 1,
	exp    = 0,
	reward = [{50000,1,1},{90010005,30000,1}],
	gift   = [{55000,2,1},{90010005,200000,1}],
	gold   = 1200000,
	bgold  = 1200000,
	vipexp = 0,
	buffs  = [130110000],
	attrs  = [{2000,500}]
};
find(2) -> #cfg_vip_level{
	level  = 2,
	exp    = 0,
	reward = [{50000,2,1},{90010005,50000,1}],
	gift   = [{50000,2,1},{90010005,200000,1}],
	gold   = 1200000,
	bgold  = 1200000,
	vipexp = 0,
	buffs  = [130110000],
	attrs  = [{2000,500}]
};
find(3) -> #cfg_vip_level{
	level  = 3,
	exp    = 0,
	reward = [{55000,2,1},{90010020,200,1},{90010005,50000,1}],
	gift   = [{55000,3,1},{90010005,300000,1}],
	gold   = 1200000,
	bgold  = 1200000,
	vipexp = 0,
	buffs  = [130110000],
	attrs  = [{2000,500}]
};
find(4) -> #cfg_vip_level{
	level  = 4,
	exp    = 0,
	reward = [{51000,2,1},{90010020,250,1},{90010005,60000,1}],
	gift   = [{50000,3,1},{90010005,300000,1}],
	gold   = 1200000,
	bgold  = 1200000,
	vipexp = 0,
	buffs  = [130110001],
	attrs  = [{2000,1000}]
};
find(5) -> #cfg_vip_level{
	level  = 5,
	exp    = 0,
	reward = [{52000,2,1},{90010020,300,1},{90010005,60000,1}],
	gift   = [{55000,4,1},{90010005,400000,1}],
	gold   = 1200000,
	bgold  = 1200000,
	vipexp = 0,
	buffs  = [130110001],
	attrs  = [{2000,1000}]
};
find(6) -> #cfg_vip_level{
	level  = 6,
	exp    = 0,
	reward = [{100043,1,1},{90010020,350,1},{90010005,80000,1}],
	gift   = [{50000,4,1},{90010005,400000,1}],
	gold   = 1200000,
	bgold  = 1200000,
	vipexp = 0,
	buffs  = [130110002],
	attrs  = [{2000,1000}]
};
find(7) -> #cfg_vip_level{
	level  = 7,
	exp    = 0,
	reward = [{100034,1,1},{90010020,500,1},{90010005,80000,1}],
	gift   = [{55000,5,1},{90010005,500000,1}],
	gold   = 1200000,
	bgold  = 1200000,
	vipexp = 0,
	buffs  = [130110003],
	attrs  = [{2000,1500}]
};
find(8) -> #cfg_vip_level{
	level  = 8,
	exp    = 0,
	reward = [{10402,1,1},{51000,2,1},{90010020,500,1},{90010005,80000,1}],
	gift   = [{50000,5,1},{90010005,500000,1}],
	gold   = 1200000,
	bgold  = 1200000,
	vipexp = 0,
	buffs  = [130110004],
	attrs  = [{2000,1500}]
};
find(9) -> #cfg_vip_level{
	level  = 9,
	exp    = 0,
	reward = [{57001,1,1},{52000,2,1},{90010020,500,1},{90010005,80000,1}],
	gift   = [{55000,6,1},{90010005,600000,1}],
	gold   = 1200000,
	bgold  = 1200000,
	vipexp = 0,
	buffs  = [130110005],
	attrs  = [{2000,2000}]
};
find(10) -> #cfg_vip_level{
	level  = 10,
	exp    = 0,
	reward = [{51000,2,1},{50000,2,1},{57001,2,1},{90010020,300,1}],
	gift   = [{50000,6,1},{90010005,600000,1}],
	gold   = 1200000,
	bgold  = 2400000,
	vipexp = 0,
	buffs  = [130110006],
	attrs  = [{2000,2500}]
};
find(11) -> #cfg_vip_level{
	level  = 11,
	exp    = 0,
	reward = [{52001,1,1},{50000,2,1},{90010004,1000,1},{90010020,300,1}],
	gift   = [{55000,7,1},{90010005,700000,1}],
	gold   = 1500000,
	bgold  = 2700000,
	vipexp = 0,
	buffs  = [130110007],
	attrs  = [{2000,3000},{4,240},{5,72}]
};
find(12) -> #cfg_vip_level{
	level  = 12,
	exp    = 0,
	reward = [{51001,1,1},{50000,2,1},{90010004,1000,1},{90010020,300,1}],
	gift   = [{50000,7,1},{90010005,700000,1}],
	gold   = 2400000,
	bgold  = 3000000,
	vipexp = 0,
	buffs  = [130110008],
	attrs  = [{2000,3000},{4,360},{5,96}]
};
find(13) -> #cfg_vip_level{
	level  = 13,
	exp    = 10,
	reward = [{50000,1,1},{90010004,1000,1},{12007,1,1},{90010020,300,1}],
	gift   = [{55000,8,1},{90010005,800000,1}],
	gold   = 3300000,
	bgold  = 3300000,
	vipexp = 0,
	buffs  = [130110008],
	attrs  = [{2000,3000},{4,480},{5,120}]
};
find(14) -> #cfg_vip_level{
	level  = 14,
	exp    = 50,
	reward = [{10402,1,1},{55000,2,1},{90010004,1500,1},{90010020,1000,1}],
	gift   = [{50000,8,1},{90010005,800000,1}],
	gold   = 4200000,
	bgold  = 3600000,
	vipexp = 0,
	buffs  = [130110008],
	attrs  = [{2000,3000},{4,720},{5,144}]
};
find(15) -> #cfg_vip_level{
	level  = 15,
	exp    = 100,
	reward = [{55006,1,1},{55000,2,1},{90010004,1500,1},{12007,2,1}],
	gift   = [{55000,9,1},{90010005,900000,1}],
	gold   = 51000000,
	bgold  = 39000000,
	vipexp = 0,
	buffs  = [130110008],
	attrs  = [{2000,3000},{4,960},{5,180}]
};
find(16) -> #cfg_vip_level{
	level  = 16,
	exp    = 200,
	reward = [{54101,1,1},{55000,2,1},{90010004,2000,1},{90010020,3000,1}],
	gift   = [{50000,9,1},{90010005,900000,1}],
	gold   = 60000000,
	bgold  = 42000000,
	vipexp = 0,
	buffs  = [130110008],
	attrs  = [{2000,3000},{4,1440},{5,216}]
};
find(17) -> #cfg_vip_level{
	level  = 17,
	exp    = 500,
	reward = [{55008,1,1},{55000,2,1},{90010004,2000,1},{12007,2,1}],
	gift   = [{55000,10,1},{90010005,1000000,1}],
	gold   = 69000000,
	bgold  = 45000000,
	vipexp = 0,
	buffs  = [130110008],
	attrs  = [{2000,3000},{4,1920},{5,288}]
};
find(18) -> #cfg_vip_level{
	level  = 18,
	exp    = 800,
	reward = [{54110,1,1},{55000,2,1},{90010004,2000,1},{12007,2,1}],
	gift   = [{50000,10,1},{90010005,1000000,1}],
	gold   = 78000000,
	bgold  = 48000000,
	vipexp = 0,
	buffs  = [130110008],
	attrs  = [{2000,3000},{4,2400},{5,360}]
};
find(19) -> #cfg_vip_level{
	level  = 19,
	exp    = 1500,
	reward = [{54112,1,1},{55000,2,1},{90010004,3000,1},{12007,2,1}],
	gift   = [{55000,11,1},{90010005,1100000,1}],
	gold   = 80000000,
	bgold  = 50000000,
	vipexp = 0,
	buffs  = [130110008],
	attrs  = [{2000,3500},{4,2480},{5,400}]
};
find(20) -> #cfg_vip_level{
	level  = 20,
	exp    = 2000,
	reward = [{54106,1,1},{50000,2,1},{90010004,3000,1},{90010020,300,1}],
	gift   = [{50000,11,1},{90010005,1100000,1}],
	gold   = 80000000,
	bgold  = 50000000,
	vipexp = 0,
	buffs  = [130110008],
	attrs  = [{2000,3500},{4,2560},{5,440}]
};
find(21) -> #cfg_vip_level{
	level  = 21,
	exp    = 2500,
	reward = [{54113,1,1},{50000,2,1},{90010004,3000,1},{90010020,300,1}],
	gift   = [{55000,12,1},{90010005,1200000,1}],
	gold   = 80000000,
	bgold  = 50000000,
	vipexp = 0,
	buffs  = [130110008],
	attrs  = [{2000,3500},{4,2640},{5,480}]
};
find(22) -> #cfg_vip_level{
	level  = 22,
	exp    = 3000,
	reward = [{54115,1,1},{50000,2,1},{90010004,5000,1},{90010020,300,1}],
	gift   = [{50000,12,1},{90010005,1200000,1}],
	gold   = 80000000,
	bgold  = 50000000,
	vipexp = 0,
	buffs  = [130110008],
	attrs  = [{2000,3500},{4,2720},{5,520}]
};
find(23) -> #cfg_vip_level{
	level  = 23,
	exp    = 4000,
	reward = [{51002,1,1},{50000,2,1},{90010004,5000,1},{90010020,300,1}],
	gift   = [{55000,13,1},{90010005,1300000,1}],
	gold   = 80000000,
	bgold  = 50000000,
	vipexp = 0,
	buffs  = [130110008],
	attrs  = [{2000,3500},{4,2800},{5,560}]
};
find(_) -> undefined.
