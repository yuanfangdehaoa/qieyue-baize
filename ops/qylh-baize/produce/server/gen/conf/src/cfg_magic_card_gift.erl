% Automatically generated, do not edit
-module(cfg_magic_card_gift).

-compile([export_all]).
-compile(nowarn_export_all).


gain(Floor) when Floor >= 0 andalso Floor =< 5 -> [{18001,1}];
gain(Floor) when Floor >= 6 andalso Floor =< 10 -> [{18002,1}];
gain(Floor) when Floor >= 11 andalso Floor =< 15 -> [{18003,1}];
gain(Floor) when Floor >= 16 andalso Floor =< 20 -> [{18004,1}];
gain(Floor) when Floor >= 21 andalso Floor =< 25 -> [{18005,1}];
gain(Floor) when Floor >= 26 andalso Floor =< 30 -> [{18006,1}];
gain(Floor) when Floor >= 31 andalso Floor =< 35 -> [{18007,1}];
gain(Floor) when Floor >= 36 andalso Floor =< 40 -> [{18008,1}];
gain(Floor) when Floor >= 41 andalso Floor =< 45 -> [{18009,1}];
gain(Floor) when Floor >= 46 andalso Floor =< 50 -> [{18010,1}];
gain(Floor) when Floor >= 51 andalso Floor =< 55 -> [{18011,1}];
gain(Floor) when Floor >= 56 andalso Floor =< 60 -> [{18012,1}];
gain(Floor) when Floor >= 61 andalso Floor =< 65 -> [{18013,1}];
gain(Floor) when Floor >= 66 andalso Floor =< 70 -> [{18014,1}];
gain(Floor) when Floor >= 71 andalso Floor =< 75 -> [{18015,1}];
gain(Floor) when Floor >= 76 andalso Floor =< 80 -> [{18016,1}];
gain(Floor) when Floor >= 81 andalso Floor =< 85 -> [{18017,1}];
gain(Floor) when Floor >= 86 andalso Floor =< 90 -> [{18018,1}];
gain(Floor) when Floor >= 91 andalso Floor =< 95 -> [{18019,1}];
gain(Floor) when Floor >= 96 andalso Floor =< 100 -> [{18020,1}];
gain(Floor) when Floor >= 101 andalso Floor =< 105 -> [{18021,1}];
gain(Floor) when Floor >= 106 andalso Floor =< 110 -> [{18022,1}];
gain(Floor) when Floor >= 111 andalso Floor =< 115 -> [{18023,1}];
gain(Floor) when Floor >= 116 andalso Floor =< 120 -> [{18024,1}];
gain(Floor) when Floor >= 121 andalso Floor =< 125 -> [{18025,1}];
gain(Floor) when Floor >= 126 andalso Floor =< 130 -> [{18026,1}];
gain(Floor) when Floor >= 131 andalso Floor =< 135 -> [{18027,1}];
gain(Floor) when Floor >= 136 andalso Floor =< 140 -> [{18028,1}];
gain(Floor) when Floor >= 141 andalso Floor =< 145 -> [{18029,1}];
gain(Floor) when Floor >= 146 andalso Floor =< 150 -> [{18030,1}];
gain(Floor) when Floor >= 151 andalso Floor =< 155 -> [{18031,1}];
gain(Floor) when Floor >= 156 andalso Floor =< 160 -> [{18032,1}];
gain(Floor) when Floor >= 161 andalso Floor =< 165 -> [{18033,1}];
gain(Floor) when Floor >= 166 andalso Floor =< 170 -> [{18034,1}];
gain(Floor) when Floor >= 171 andalso Floor =< 175 -> [{18035,1}];
gain(Floor) when Floor >= 176 andalso Floor =< 180 -> [{18036,1}];
gain(Floor) when Floor >= 181 andalso Floor =< 185 -> [{18037,1}];
gain(Floor) when Floor >= 186 andalso Floor =< 190 -> [{18038,1}];
gain(Floor) when Floor >= 191 andalso Floor =< 195 -> [{18039,1}];
gain(Floor) when Floor >= 196 andalso Floor =< 99999 -> [{18040,1}];
gain(_) -> undefined.
