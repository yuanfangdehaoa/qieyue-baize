% Automatically generated, do not edit
-module(cfg_compete_guess).

-compile([export_all]).
-compile(nowarn_export_all).

-include("compete.hrl").

find(1, true) -> #cfg_compete_guess{
	type  = 1,
	cost  = [{90010003,2500}],
	right = [{90010029,100}],
	wrong = [{90010029,65}]
};
find(2, true) -> #cfg_compete_guess{
	type  = 2,
	cost  = [{90010003,5000}],
	right = [{90010029,200}],
	wrong = [{90010029,130}]
};
find(3, true) -> #cfg_compete_guess{
	type  = 3,
	cost  = [{90010003,15000}],
	right = [{90010029,600}],
	wrong = [{90010029,390}]
};
find(1, false) -> #cfg_compete_guess{
	type  = 1,
	cost  = [{90010003,5000}],
	right = [{90010029,200}],
	wrong = [{90010029,130}]
};
find(2, false) -> #cfg_compete_guess{
	type  = 2,
	cost  = [{90010003,15000}],
	right = [{90010029,600}],
	wrong = [{90010029,390}]
};
find(3, false) -> #cfg_compete_guess{
	type  = 3,
	cost  = [{90010003,25000}],
	right = [{90010029,1000}],
	wrong = [{90010029,650}]
};
find(4, false) -> #cfg_compete_guess{
	type  = 4,
	cost  = [{90010003,50000}],
	right = [{90010029,2000}],
	wrong = [{90010029,1300}]
};
find(_, _) -> undefined.
