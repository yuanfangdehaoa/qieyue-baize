% Automatically generated, do not edit
-module(cfg_pet_evolution).

-compile([export_all]).
-compile(nowarn_export_all).

-include("pet.hrl").

find(100, 0) -> #cfg_pet_evolution{
	order      = 100,
	times      = 0,
	cost       = [],
	skill      = [{701000,1,1,0},{701001,1,2,1},{701031,1,3,1}],
	attr       = [{4,0},{6,0},{2,0},{5,0}],
	normal_atk = [701001],
	change_atk = [],
	profound   = [],
	passive    = [701031],
	fight_attr = [{39,0}]
};
find(100, 1) -> #cfg_pet_evolution{
	order      = 100,
	times      = 1,
	cost       = [{12009,1}],
	skill      = [{701000,1,1,1},{701001,1,2,1},{701031,1,3,1}],
	attr       = [{4,180},{6,68},{2,4349},{5,88}],
	normal_atk = [701001],
	change_atk = [701021,701011],
	profound   = [701000],
	passive    = [701031],
	fight_attr = [{39,25000}]
};
find(100, 2) -> #cfg_pet_evolution{
	order      = 100,
	times      = 2,
	cost       = [{12009,2}],
	skill      = [{701100,2,1,1},{701001,1,2,1},{701031,1,3,1}],
	attr       = [{4,451},{6,172},{2,10874},{5,220}],
	normal_atk = [701001],
	change_atk = [701022,701011],
	profound   = [701100],
	passive    = [701031],
	fight_attr = [{39,63000}]
};
find(100, 3) -> #cfg_pet_evolution{
	order      = 100,
	times      = 3,
	cost       = [{12009,3}],
	skill      = [{701200,3,1,1},{701001,1,2,1},{701031,1,3,1}],
	attr       = [{4,813},{6,310},{2,19573},{5,396}],
	normal_atk = [701001],
	change_atk = [701022,701011],
	profound   = [701200],
	passive    = [701031],
	fight_attr = [{39,126000}]
};
find(100, 4) -> #cfg_pet_evolution{
	order      = 100,
	times      = 4,
	cost       = [{12009,5}],
	skill      = [{701300,4,1,1},{701101,2,2,1},{701031,1,3,1}],
	attr       = [{4,1355},{6,516},{2,32623},{5,660}],
	normal_atk = [701101],
	change_atk = [701023,701012],
	profound   = [701300],
	passive    = [701031],
	fight_attr = [{39,226000}]
};
find(200, 0) -> #cfg_pet_evolution{
	order      = 200,
	times      = 0,
	cost       = [],
	skill      = [{708000,1,1,0},{708001,1,2,1},{708031,1,3,1}],
	attr       = [{4,0},{6,0},{2,0},{5,0}],
	normal_atk = [708001],
	change_atk = [],
	profound   = [],
	passive    = [708031],
	fight_attr = [{39,0}]
};
find(200, 1) -> #cfg_pet_evolution{
	order      = 200,
	times      = 1,
	cost       = [{12009,1}],
	skill      = [{708000,1,1,1},{708001,1,2,1},{708031,1,3,1}],
	attr       = [{4,271},{6,103},{2,6524},{5,132}],
	normal_atk = [708001],
	change_atk = [708021,708011],
	profound   = [708000],
	passive    = [708031],
	fight_attr = [{39,38000}]
};
find(200, 2) -> #cfg_pet_evolution{
	order      = 200,
	times      = 2,
	cost       = [{12009,3}],
	skill      = [{708100,2,1,1},{708001,1,2,1},{708031,1,3,1}],
	attr       = [{4,677},{6,258},{2,16311},{5,330}],
	normal_atk = [708001],
	change_atk = [708022,708011],
	profound   = [708100],
	passive    = [708031],
	fight_attr = [{39,94000}]
};
find(200, 3) -> #cfg_pet_evolution{
	order      = 200,
	times      = 3,
	cost       = [{12009,5}],
	skill      = [{708200,3,1,1},{708001,1,2,1},{708031,1,3,1}],
	attr       = [{4,1219},{6,465},{2,29361},{5,594}],
	normal_atk = [708001],
	change_atk = [708022,708011],
	profound   = [708200],
	passive    = [708031],
	fight_attr = [{39,188000}]
};
find(200, 4) -> #cfg_pet_evolution{
	order      = 200,
	times      = 4,
	cost       = [{12009,8}],
	skill      = [{708300,4,1,1},{708101,2,2,1},{708031,1,3,1}],
	attr       = [{4,2032},{6,776},{2,48935},{5,990}],
	normal_atk = [708101],
	change_atk = [708023,708012],
	profound   = [708300],
	passive    = [708031],
	fight_attr = [{39,338000}]
};
find(300, 0) -> #cfg_pet_evolution{
	order      = 300,
	times      = 0,
	cost       = [],
	skill      = [{702000,1,1,0},{702001,1,2,1},{702031,1,3,1}],
	attr       = [{4,0},{6,0},{2,0},{5,0}],
	normal_atk = [702001],
	change_atk = [],
	profound   = [],
	passive    = [702031],
	fight_attr = [{39,0}]
};
find(300, 1) -> #cfg_pet_evolution{
	order      = 300,
	times      = 1,
	cost       = [{12009,3}],
	skill      = [{702000,1,1,1},{702001,1,2,1},{702031,1,3,1}],
	attr       = [{4,352},{6,134},{2,8482},{5,171}],
	normal_atk = [702001],
	change_atk = [702021,702011],
	profound   = [702000],
	passive    = [702031],
	fight_attr = [{39,50000}]
};
find(300, 2) -> #cfg_pet_evolution{
	order      = 300,
	times      = 2,
	cost       = [{12009,5}],
	skill      = [{702100,2,1,1},{702001,1,2,1},{702031,1,3,1}],
	attr       = [{4,881},{6,336},{2,21205},{5,429}],
	normal_atk = [702001],
	change_atk = [702022,702011],
	profound   = [702100],
	passive    = [702031],
	fight_attr = [{39,125000}]
};
find(300, 3) -> #cfg_pet_evolution{
	order      = 300,
	times      = 3,
	cost       = [{12009,8}],
	skill      = [{702200,3,1,1},{702001,1,2,1},{702031,1,3,1}],
	attr       = [{4,1585},{6,605},{2,38169},{5,772}],
	normal_atk = [702001],
	change_atk = [702022,702011],
	profound   = [702200],
	passive    = [702031],
	fight_attr = [{39,250000}]
};
find(300, 4) -> #cfg_pet_evolution{
	order      = 300,
	times      = 4,
	cost       = [{12009,12}],
	skill      = [{702300,4,1,1},{702101,2,2,1},{702031,1,3,1}],
	attr       = [{4,2643},{6,1008},{2,63616},{5,1288}],
	normal_atk = [702101],
	change_atk = [702023,702012],
	profound   = [702300],
	passive    = [702031],
	fight_attr = [{39,450000}]
};
find(100000, 0) -> #cfg_pet_evolution{
	order      = 100000,
	times      = 0,
	cost       = [],
	skill      = [{710000,1,1,0},{710001,1,2,1},{710031,1,3,1}],
	attr       = [{4,0},{6,0},{2,0},{5,0}],
	normal_atk = [710001],
	change_atk = [],
	profound   = [],
	passive    = [710031],
	fight_attr = [{39,0}]
};
find(100000, 1) -> #cfg_pet_evolution{
	order      = 100000,
	times      = 1,
	cost       = [{12009,3}],
	skill      = [{710000,1,1,1},{710001,1,2,1},{710031,1,3,1}],
	attr       = [{4,352},{6,134},{2,8482},{5,171}],
	normal_atk = [710001],
	change_atk = [710021,710011],
	profound   = [710000],
	passive    = [710031],
	fight_attr = [{39,63000}]
};
find(100000, 2) -> #cfg_pet_evolution{
	order      = 100000,
	times      = 2,
	cost       = [{12009,5}],
	skill      = [{710100,2,1,1},{710001,1,2,1},{710031,1,3,1}],
	attr       = [{4,881},{6,336},{2,21205},{5,429}],
	normal_atk = [710001],
	change_atk = [710022,710011],
	profound   = [710100],
	passive    = [710031],
	fight_attr = [{39,157000}]
};
find(100000, 3) -> #cfg_pet_evolution{
	order      = 100000,
	times      = 3,
	cost       = [{12009,8}],
	skill      = [{710200,3,1,1},{710001,1,2,1},{710031,1,3,1}],
	attr       = [{4,1585},{6,605},{2,38169},{5,772}],
	normal_atk = [710001],
	change_atk = [710022,710011],
	profound   = [710200],
	passive    = [710031],
	fight_attr = [{39,313000}]
};
find(100000, 4) -> #cfg_pet_evolution{
	order      = 100000,
	times      = 4,
	cost       = [{12009,12}],
	skill      = [{710300,4,1,1},{710101,2,2,1},{710031,1,3,1}],
	attr       = [{4,2643},{6,1008},{2,63616},{5,1288}],
	normal_atk = [710101],
	change_atk = [710023,710012],
	profound   = [710300],
	passive    = [710031],
	fight_attr = [{39,563000}]
};
find(200000, 0) -> #cfg_pet_evolution{
	order      = 200000,
	times      = 0,
	cost       = [],
	skill      = [{709000,1,1,0},{709001,1,2,1},{709031,1,3,1}],
	attr       = [{4,0},{6,0},{2,0},{5,0}],
	normal_atk = [709001],
	change_atk = [],
	profound   = [],
	passive    = [709031],
	fight_attr = [{39,0}]
};
find(200000, 1) -> #cfg_pet_evolution{
	order      = 200000,
	times      = 1,
	cost       = [{12009,1}],
	skill      = [{709000,1,1,1},{709001,1,2,1},{709031,1,3,1}],
	attr       = [{4,352},{6,134},{2,8482},{5,171}],
	normal_atk = [709001,709011],
	change_atk = [709002,709021],
	profound   = [709000],
	passive    = [709031],
	fight_attr = [{39,94000}]
};
find(200000, 2) -> #cfg_pet_evolution{
	order      = 200000,
	times      = 2,
	cost       = [{12009,5}],
	skill      = [{709100,2,1,1},{709001,1,2,1},{709031,1,3,1}],
	attr       = [{4,881},{6,336},{2,21205},{5,429}],
	normal_atk = [709001,709011],
	change_atk = [709002,709022],
	profound   = [709100],
	passive    = [709031],
	fight_attr = [{39,235000}]
};
find(200000, 3) -> #cfg_pet_evolution{
	order      = 200000,
	times      = 3,
	cost       = [{12009,8}],
	skill      = [{709200,3,1,1},{709001,1,2,1},{709031,1,3,1}],
	attr       = [{4,1585},{6,605},{2,38169},{5,772}],
	normal_atk = [709001,709012],
	change_atk = [709002,709022],
	profound   = [709200],
	passive    = [709031],
	fight_attr = [{39,469000}]
};
find(200000, 4) -> #cfg_pet_evolution{
	order      = 200000,
	times      = 4,
	cost       = [{12009,12}],
	skill      = [{709300,4,1,1},{709101,2,2,1},{709031,1,3,1}],
	attr       = [{4,2643},{6,1008},{2,63616},{5,1288}],
	normal_atk = [709101,709012],
	change_atk = [709102,709023],
	profound   = [709300],
	passive    = [709031],
	fight_attr = [{39,844000}]
};
find(400, 0) -> #cfg_pet_evolution{
	order      = 400,
	times      = 0,
	cost       = [],
	skill      = [{703000,1,1,0},{703001,1,2,1},{703031,1,3,1}],
	attr       = [{4,0},{6,0},{2,0},{5,0}],
	normal_atk = [703001],
	change_atk = [],
	profound   = [],
	passive    = [703031],
	fight_attr = [{39,0}]
};
find(400, 1) -> #cfg_pet_evolution{
	order      = 400,
	times      = 1,
	cost       = [{12009,5}],
	skill      = [{703000,1,1,1},{703001,1,2,1},{703031,1,3,1}],
	attr       = [{4,493},{6,188},{2,11874},{5,240}],
	normal_atk = [703001],
	change_atk = [703021,703011],
	profound   = [703000],
	passive    = [703031],
	fight_attr = [{39,125000}]
};
find(400, 2) -> #cfg_pet_evolution{
	order      = 400,
	times      = 2,
	cost       = [{12009,8}],
	skill      = [{703100,2,1,1},{703001,1,2,1},{703031,1,3,1}],
	attr       = [{4,1233},{6,470},{2,29687},{5,601}],
	normal_atk = [703001],
	change_atk = [703022,703011],
	profound   = [703100],
	passive    = [703031],
	fight_attr = [{39,313000}]
};
find(400, 3) -> #cfg_pet_evolution{
	order      = 400,
	times      = 3,
	cost       = [{12009,12}],
	skill      = [{703200,3,1,1},{703001,1,2,1},{703031,1,3,1}],
	attr       = [{4,2220},{6,847},{2,53437},{5,1081}],
	normal_atk = [703001],
	change_atk = [703022,703011],
	profound   = [703200],
	passive    = [703031],
	fight_attr = [{39,626000}]
};
find(400, 4) -> #cfg_pet_evolution{
	order      = 400,
	times      = 4,
	cost       = [{12009,20}],
	skill      = [{703300,4,1,1},{703101,2,2,1},{703031,1,3,1}],
	attr       = [{4,3700},{6,1412},{2,89062},{5,1803}],
	normal_atk = [703101],
	change_atk = [703023,703012],
	profound   = [703300],
	passive    = [703031],
	fight_attr = [{39,1126000}]
};
find(300000, 0) -> #cfg_pet_evolution{
	order      = 300000,
	times      = 0,
	cost       = [],
	skill      = [{707000,1,1,0},{707001,1,2,1},{707031,1,3,1}],
	attr       = [{4,0},{6,0},{2,0},{5,0}],
	normal_atk = [707001],
	change_atk = [],
	profound   = [],
	passive    = [707031],
	fight_attr = [{39,0}]
};
find(300000, 1) -> #cfg_pet_evolution{
	order      = 300000,
	times      = 1,
	cost       = [{12009,5}],
	skill      = [{707000,1,1,1},{707001,1,2,1},{707031,1,3,1}],
	attr       = [{4,493},{6,188},{2,11874},{5,240}],
	normal_atk = [707001],
	change_atk = [707021,707011],
	profound   = [707000],
	passive    = [707031],
	fight_attr = [{39,156000}]
};
find(300000, 2) -> #cfg_pet_evolution{
	order      = 300000,
	times      = 2,
	cost       = [{12009,8}],
	skill      = [{707100,2,1,1},{707001,1,2,1},{707031,1,3,1}],
	attr       = [{4,1233},{6,470},{2,29687},{5,601}],
	normal_atk = [707001],
	change_atk = [707022,707011],
	profound   = [707100],
	passive    = [707031],
	fight_attr = [{39,390000}]
};
find(300000, 3) -> #cfg_pet_evolution{
	order      = 300000,
	times      = 3,
	cost       = [{12009,12}],
	skill      = [{707200,3,1,1},{707001,1,2,1},{707031,1,3,1}],
	attr       = [{4,2220},{6,847},{2,53437},{5,1081}],
	normal_atk = [707001],
	change_atk = [707022,707011],
	profound   = [707200],
	passive    = [707031],
	fight_attr = [{39,781000}]
};
find(300000, 4) -> #cfg_pet_evolution{
	order      = 300000,
	times      = 4,
	cost       = [{12009,20}],
	skill      = [{707300,4,1,1},{707101,2,2,1},{707031,1,3,1}],
	attr       = [{4,3700},{6,1412},{2,89062},{5,1803}],
	normal_atk = [707101],
	change_atk = [707023,707012],
	profound   = [707300],
	passive    = [707031],
	fight_attr = [{39,1406000}]
};
find(500, 0) -> #cfg_pet_evolution{
	order      = 500,
	times      = 0,
	cost       = [],
	skill      = [{704000,1,1,0},{704001,1,2,1},{704031,1,3,1}],
	attr       = [{4,0},{6,0},{2,0},{5,0}],
	normal_atk = [704001],
	change_atk = [],
	profound   = [],
	passive    = [704031],
	fight_attr = [{39,0}]
};
find(500, 1) -> #cfg_pet_evolution{
	order      = 500,
	times      = 1,
	cost       = [{12009,8}],
	skill      = [{704000,1,1,1},{704001,1,2,1},{704031,1,3,1}],
	attr       = [{4,641},{6,244},{2,15437},{5,312}],
	normal_atk = [704001],
	change_atk = [704021,704011],
	profound   = [704000],
	passive    = [704031],
	fight_attr = [{39,219000}]
};
find(500, 2) -> #cfg_pet_evolution{
	order      = 500,
	times      = 2,
	cost       = [{12009,12}],
	skill      = [{704100,2,1,1},{704001,1,2,1},{704031,1,3,1}],
	attr       = [{4,1603},{6,612},{2,38593},{5,781}],
	normal_atk = [704001],
	change_atk = [704022,704011],
	profound   = [704100],
	passive    = [704031],
	fight_attr = [{39,547000}]
};
find(500, 3) -> #cfg_pet_evolution{
	order      = 500,
	times      = 3,
	cost       = [{12009,20}],
	skill      = [{704200,3,1,1},{704001,1,2,1},{704031,1,3,1}],
	attr       = [{4,2886},{6,1101},{2,69468},{5,1406}],
	normal_atk = [704001],
	change_atk = [704022,704011],
	profound   = [704200],
	passive    = [704031],
	fight_attr = [{39,1094000}]
};
find(500, 4) -> #cfg_pet_evolution{
	order      = 500,
	times      = 4,
	cost       = [{12009,30}],
	skill      = [{704300,4,1,1},{704101,2,2,1},{704031,1,3,1}],
	attr       = [{4,4810},{6,1836},{2,115780},{5,2344}],
	normal_atk = [704101],
	change_atk = [704023,704012],
	profound   = [704300],
	passive    = [704031],
	fight_attr = [{39,1969000}]
};
find(600, 0) -> #cfg_pet_evolution{
	order      = 600,
	times      = 0,
	cost       = [],
	skill      = [{705000,1,1,0},{705001,1,2,1},{705031,1,3,1}],
	attr       = [{4,0},{6,0},{2,0},{5,0}],
	normal_atk = [705001],
	change_atk = [],
	profound   = [],
	passive    = [705031],
	fight_attr = [{39,0}]
};
find(600, 1) -> #cfg_pet_evolution{
	order      = 600,
	times      = 1,
	cost       = [{12009,12}],
	skill      = [{705000,1,1,1},{705001,1,2,1},{705031,1,3,1}],
	attr       = [{4,769},{6,293},{2,18525},{5,375}],
	normal_atk = [705001],
	change_atk = [705021,705011],
	profound   = [705000],
	passive    = [705031],
	fight_attr = [{39,313000}]
};
find(600, 2) -> #cfg_pet_evolution{
	order      = 600,
	times      = 2,
	cost       = [{12009,20}],
	skill      = [{705100,2,1,1},{705001,1,2,1},{705031,1,3,1}],
	attr       = [{4,1924},{6,734},{2,46312},{5,937}],
	normal_atk = [705001],
	change_atk = [705022,705011],
	profound   = [705100],
	passive    = [705031],
	fight_attr = [{39,782000}]
};
find(600, 3) -> #cfg_pet_evolution{
	order      = 600,
	times      = 3,
	cost       = [{12009,30}],
	skill      = [{705200,3,1,1},{705001,1,2,1},{705031,1,3,1}],
	attr       = [{4,3463},{6,1321},{2,83362},{5,1688}],
	normal_atk = [705001],
	change_atk = [705022,705011],
	profound   = [705200],
	passive    = [705031],
	fight_attr = [{39,1563000}]
};
find(600, 4) -> #cfg_pet_evolution{
	order      = 600,
	times      = 4,
	cost       = [{12009,50}],
	skill      = [{705300,4,1,1},{705101,2,2,1},{705031,1,3,1}],
	attr       = [{4,5772},{6,2203},{2,138937},{5,2813}],
	normal_atk = [705101],
	change_atk = [705023,705012],
	profound   = [705300],
	passive    = [705031],
	fight_attr = [{39,2813000}]
};
find(700, 0) -> #cfg_pet_evolution{
	order      = 700,
	times      = 0,
	cost       = [],
	skill      = [{706000,1,1,0},{706001,1,2,1},{706031,1,3,1}],
	attr       = [{4,0},{6,0},{2,0},{5,0}],
	normal_atk = [706001],
	change_atk = [],
	profound   = [],
	passive    = [706031],
	fight_attr = [{39,0}]
};
find(700, 1) -> #cfg_pet_evolution{
	order      = 700,
	times      = 1,
	cost       = [{12009,20}],
	skill      = [{706000,1,1,1},{706001,1,2,1},{706031,1,3,1}],
	attr       = [{4,962},{6,367},{2,23156},{5,468}],
	normal_atk = [706001],
	change_atk = [706021,706011],
	profound   = [706000],
	passive    = [706031],
	fight_attr = [{39,438000}]
};
find(700, 2) -> #cfg_pet_evolution{
	order      = 700,
	times      = 2,
	cost       = [{12009,30}],
	skill      = [{706100,2,1,1},{706001,1,2,1},{706031,1,3,1}],
	attr       = [{4,2405},{6,918},{2,57890},{5,1172}],
	normal_atk = [706001],
	change_atk = [706022,706011],
	profound   = [706100],
	passive    = [706031],
	fight_attr = [{39,1094000}]
};
find(700, 3) -> #cfg_pet_evolution{
	order      = 700,
	times      = 3,
	cost       = [{12009,50}],
	skill      = [{706200,3,1,1},{706001,1,2,1},{706031,1,3,1}],
	attr       = [{4,4329},{6,1652},{2,104203},{5,2110}],
	normal_atk = [706001],
	change_atk = [706022,706011],
	profound   = [706200],
	passive    = [706031],
	fight_attr = [{39,2188000}]
};
find(700, 4) -> #cfg_pet_evolution{
	order      = 700,
	times      = 4,
	cost       = [{12009,80}],
	skill      = [{706300,4,1,1},{706101,2,2,1},{706031,1,3,1}],
	attr       = [{4,7216},{6,2754},{2,173672},{5,3516}],
	normal_atk = [706101],
	change_atk = [706023,706012],
	profound   = [706300],
	passive    = [706031],
	fight_attr = [{39,3938000}]
};
find(9999, 0) -> #cfg_pet_evolution{
	order      = 9999,
	times      = 0,
	cost       = [],
	skill      = [{99000,1,1,0},{99004,1,2,1},{99014,1,3,1}],
	attr       = [{4,0},{6,0},{2,0},{5,0}],
	normal_atk = [99004],
	change_atk = [99008,99011],
	profound   = [99000],
	passive    = [99014],
	fight_attr = [{39,0}]
};
find(400000, 0) -> #cfg_pet_evolution{
	order      = 400000,
	times      = 0,
	cost       = [],
	skill      = [{711000,1,1,0},{711001,1,2,1},{711031,1,3,1}],
	attr       = [{4,0},{6,0},{2,0},{5,0}],
	normal_atk = [711001],
	change_atk = [],
	profound   = [],
	passive    = [711031],
	fight_attr = [{39,0}]
};
find(400000, 1) -> #cfg_pet_evolution{
	order      = 400000,
	times      = 1,
	cost       = [{12009,3}],
	skill      = [{711000,1,1,1},{711001,1,2,1},{711031,1,3,1}],
	attr       = [{4,352},{6,134},{2,8482},{5,171}],
	normal_atk = [711001],
	change_atk = [711021,711011],
	profound   = [711000],
	passive    = [711031],
	fight_attr = [{39,63000}]
};
find(400000, 2) -> #cfg_pet_evolution{
	order      = 400000,
	times      = 2,
	cost       = [{12009,5}],
	skill      = [{711100,2,1,1},{711001,1,2,1},{711031,1,3,1}],
	attr       = [{4,881},{6,336},{2,21205},{5,429}],
	normal_atk = [711001],
	change_atk = [711022,711011],
	profound   = [711100],
	passive    = [711031],
	fight_attr = [{39,157000}]
};
find(400000, 3) -> #cfg_pet_evolution{
	order      = 400000,
	times      = 3,
	cost       = [{12009,8}],
	skill      = [{711200,3,1,1},{711001,1,2,1},{711031,1,3,1}],
	attr       = [{4,1585},{6,605},{2,38169},{5,772}],
	normal_atk = [711001],
	change_atk = [711022,711011],
	profound   = [711200],
	passive    = [711031],
	fight_attr = [{39,313000}]
};
find(400000, 4) -> #cfg_pet_evolution{
	order      = 400000,
	times      = 4,
	cost       = [{12009,12}],
	skill      = [{711300,4,1,1},{711101,2,2,1},{711031,1,3,1}],
	attr       = [{4,2643},{6,1008},{2,63616},{5,1288}],
	normal_atk = [711001],
	change_atk = [711023,711012],
	profound   = [711300],
	passive    = [711031],
	fight_attr = [{39,563000}]
};
find(_, _) -> undefined.
