% Automatically generated, do not edit
-module(cfg_pet_score).

-compile([export_all]).
-compile(nowarn_export_all).


ratio(1104) -> 14.4;
ratio(1106) -> 6.4;
ratio(13) -> 23;
ratio(1102) -> 14.4;
ratio(1105) -> 6.4;
ratio(41) -> 23;
ratio(19) -> 6.3;
ratio(22) -> 18.8;
ratio(16) -> 19.1;
ratio(27) -> 3.8;
ratio(25) -> 5.6;
ratio(23) -> 9.4;
ratio(17) -> 28;
ratio(_) -> 0.



quality_ratio(2005) -> [{3,0.1},{4,0.1},{5,0.07},{6,0.05},{7,0.05}];
quality_ratio(2004) -> [{3,0.005},{4,0.005},{5,0.0035},{6,0.0035},{7,0.0025}];
quality_ratio(2003) -> [{3,0.1},{4,0.1},{5,0.07},{6,0.05},{7,0.05}];
quality_ratio(2002) -> [];
quality_ratio(2001) -> [];
quality_ratio(_) -> [].

