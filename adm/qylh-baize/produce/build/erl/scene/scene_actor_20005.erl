-module(scene_actor_20005).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=6340, y=759},
		#p_coord{x=6360, y=759},
		#p_coord{x=6340, y=780},
		#p_coord{x=6360, y=780}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=6400, y=759},
		#p_coord{x=6420, y=759},
		#p_coord{x=6400, y=780},
		#p_coord{x=6420, y=780}
	].

%% 跳跃点
get_jump() ->
	[
	].

%% 安全区
get_safe() ->
	[
		{288, 31},
		{288, 32},
		{288, 33},
		{288, 34},
		{288, 35},
		{288, 36},
		{288, 37},
		{288, 38},
		{288, 39},
		{288, 40},
		{288, 41},
		{288, 42},
		{288, 43},
		{289, 31},
		{289, 32},
		{289, 33},
		{289, 34},
		{289, 35},
		{289, 36},
		{289, 37},
		{289, 38},
		{289, 39},
		{289, 40},
		{289, 41},
		{289, 42},
		{289, 43},
		{290, 31},
		{290, 32},
		{290, 33},
		{290, 34},
		{290, 35},
		{290, 36},
		{290, 37},
		{290, 38},
		{290, 39},
		{290, 40},
		{290, 41},
		{290, 42},
		{290, 43},
		{290, 44},
		{291, 30},
		{291, 31},
		{291, 32},
		{291, 33},
		{291, 34},
		{291, 35},
		{291, 36},
		{291, 37},
		{291, 38},
		{291, 39},
		{291, 40},
		{291, 41},
		{291, 42},
		{291, 43},
		{291, 44},
		{291, 45},
		{292, 30},
		{292, 31},
		{292, 32},
		{292, 33},
		{292, 34},
		{292, 35},
		{292, 36},
		{292, 37},
		{292, 38},
		{292, 39},
		{292, 40},
		{292, 41},
		{292, 42},
		{292, 43},
		{292, 44},
		{292, 45},
		{292, 46},
		{292, 47},
		{293, 29},
		{293, 30},
		{293, 31},
		{293, 32},
		{293, 33},
		{293, 34},
		{293, 35},
		{293, 36},
		{293, 37},
		{293, 38},
		{293, 39},
		{293, 40},
		{293, 41},
		{293, 42},
		{293, 43},
		{293, 44},
		{293, 45},
		{293, 46},
		{293, 47},
		{293, 48},
		{294, 29},
		{294, 30},
		{294, 31},
		{294, 32},
		{294, 33},
		{294, 34},
		{294, 35},
		{294, 36},
		{294, 37},
		{294, 38},
		{294, 39},
		{294, 40},
		{294, 41},
		{294, 42},
		{294, 43},
		{294, 44},
		{294, 45},
		{294, 46},
		{294, 47},
		{294, 48},
		{295, 29},
		{295, 30},
		{295, 31},
		{295, 32},
		{295, 33},
		{295, 34},
		{295, 35},
		{295, 36},
		{295, 37},
		{295, 38},
		{295, 39},
		{295, 40},
		{295, 41},
		{295, 42},
		{295, 43},
		{295, 44},
		{295, 45},
		{295, 46},
		{295, 47},
		{295, 48},
		{295, 49},
		{296, 29},
		{296, 30},
		{296, 31},
		{296, 32},
		{296, 33},
		{296, 34},
		{296, 35},
		{296, 36},
		{296, 37},
		{296, 38},
		{296, 39},
		{296, 40},
		{296, 41},
		{296, 42},
		{296, 43},
		{296, 44},
		{296, 45},
		{296, 46},
		{296, 47},
		{296, 48},
		{296, 49},
		{297, 29},
		{297, 30},
		{297, 31},
		{297, 32},
		{297, 33},
		{297, 34},
		{297, 35},
		{297, 36},
		{297, 37},
		{297, 38},
		{297, 39},
		{297, 40},
		{297, 41},
		{297, 42},
		{297, 43},
		{297, 44},
		{297, 45},
		{297, 46},
		{297, 47},
		{297, 48},
		{297, 49},
		{297, 50},
		{298, 27},
		{298, 28},
		{298, 29},
		{298, 30},
		{298, 31},
		{298, 32},
		{298, 33},
		{298, 34},
		{298, 35},
		{298, 36},
		{298, 37},
		{298, 38},
		{298, 39},
		{298, 40},
		{298, 41},
		{298, 42},
		{298, 43},
		{298, 44},
		{298, 45},
		{298, 46},
		{298, 47},
		{298, 48},
		{298, 49},
		{298, 50},
		{299, 27},
		{299, 28},
		{299, 29},
		{299, 30},
		{299, 31},
		{299, 32},
		{299, 33},
		{299, 34},
		{299, 35},
		{299, 36},
		{299, 37},
		{299, 38},
		{299, 39},
		{299, 40},
		{299, 41},
		{299, 42},
		{299, 43},
		{299, 44},
		{299, 45},
		{299, 46},
		{299, 47},
		{299, 48},
		{299, 49},
		{299, 50},
		{300, 27},
		{300, 28},
		{300, 29},
		{300, 30},
		{300, 31},
		{300, 32},
		{300, 33},
		{300, 34},
		{300, 35},
		{300, 36},
		{300, 37},
		{300, 38},
		{300, 39},
		{300, 40},
		{300, 41},
		{300, 42},
		{300, 43},
		{300, 44},
		{300, 45},
		{300, 46},
		{300, 47},
		{300, 48},
		{300, 49},
		{300, 50},
		{301, 26},
		{301, 27},
		{301, 28},
		{301, 29},
		{301, 30},
		{301, 31},
		{301, 32},
		{301, 33},
		{301, 34},
		{301, 35},
		{301, 36},
		{301, 37},
		{301, 38},
		{301, 39},
		{301, 40},
		{301, 41},
		{301, 42},
		{301, 43},
		{301, 44},
		{301, 45},
		{301, 46},
		{301, 47},
		{301, 48},
		{301, 49},
		{301, 50},
		{302, 25},
		{302, 26},
		{302, 27},
		{302, 28},
		{302, 29},
		{302, 30},
		{302, 31},
		{302, 32},
		{302, 33},
		{302, 34},
		{302, 35},
		{302, 36},
		{302, 37},
		{302, 38},
		{302, 39},
		{302, 40},
		{302, 41},
		{302, 42},
		{302, 43},
		{302, 44},
		{302, 45},
		{302, 46},
		{302, 47},
		{302, 48},
		{302, 49},
		{302, 50},
		{303, 25},
		{303, 26},
		{303, 27},
		{303, 28},
		{303, 29},
		{303, 30},
		{303, 31},
		{303, 32},
		{303, 33},
		{303, 34},
		{303, 35},
		{303, 36},
		{303, 37},
		{303, 38},
		{303, 39},
		{303, 40},
		{303, 41},
		{303, 42},
		{303, 43},
		{303, 44},
		{303, 45},
		{303, 46},
		{303, 47},
		{303, 48},
		{303, 49},
		{303, 50},
		{303, 51},
		{303, 52},
		{304, 25},
		{304, 26},
		{304, 27},
		{304, 28},
		{304, 29},
		{304, 30},
		{304, 31},
		{304, 32},
		{304, 33},
		{304, 34},
		{304, 35},
		{304, 36},
		{304, 37},
		{304, 38},
		{304, 39},
		{304, 40},
		{304, 41},
		{304, 42},
		{304, 43},
		{304, 44},
		{304, 45},
		{304, 46},
		{304, 47},
		{304, 48},
		{304, 49},
		{304, 50},
		{304, 51},
		{304, 52},
		{305, 25},
		{305, 26},
		{305, 27},
		{305, 28},
		{305, 29},
		{305, 30},
		{305, 31},
		{305, 32},
		{305, 33},
		{305, 34},
		{305, 35},
		{305, 36},
		{305, 37},
		{305, 38},
		{305, 39},
		{305, 40},
		{305, 41},
		{305, 42},
		{305, 43},
		{305, 44},
		{305, 45},
		{305, 46},
		{305, 47},
		{305, 48},
		{305, 49},
		{305, 50},
		{305, 51},
		{305, 52},
		{306, 24},
		{306, 25},
		{306, 26},
		{306, 27},
		{306, 28},
		{306, 29},
		{306, 30},
		{306, 31},
		{306, 32},
		{306, 33},
		{306, 34},
		{306, 35},
		{306, 36},
		{306, 37},
		{306, 38},
		{306, 39},
		{306, 40},
		{306, 41},
		{306, 42},
		{306, 43},
		{306, 44},
		{306, 45},
		{306, 46},
		{306, 47},
		{306, 48},
		{306, 49},
		{306, 50},
		{306, 51},
		{306, 52},
		{307, 24},
		{307, 25},
		{307, 26},
		{307, 27},
		{307, 28},
		{307, 29},
		{307, 30},
		{307, 31},
		{307, 32},
		{307, 33},
		{307, 34},
		{307, 35},
		{307, 36},
		{307, 37},
		{307, 38},
		{307, 39},
		{307, 40},
		{307, 41},
		{307, 42},
		{307, 43},
		{307, 44},
		{307, 45},
		{307, 46},
		{307, 47},
		{307, 48},
		{307, 49},
		{307, 50},
		{307, 51},
		{307, 52},
		{308, 24},
		{308, 25},
		{308, 26},
		{308, 27},
		{308, 28},
		{308, 29},
		{308, 30},
		{308, 31},
		{308, 32},
		{308, 33},
		{308, 34},
		{308, 35},
		{308, 36},
		{308, 37},
		{308, 38},
		{308, 39},
		{308, 40},
		{308, 41},
		{308, 42},
		{308, 43},
		{308, 44},
		{308, 45},
		{308, 46},
		{308, 47},
		{308, 48},
		{308, 49},
		{308, 50},
		{308, 51},
		{308, 52},
		{308, 53},
		{309, 24},
		{309, 25},
		{309, 26},
		{309, 27},
		{309, 28},
		{309, 29},
		{309, 30},
		{309, 31},
		{309, 32},
		{309, 33},
		{309, 34},
		{309, 35},
		{309, 36},
		{309, 37},
		{309, 38},
		{309, 39},
		{309, 40},
		{309, 41},
		{309, 42},
		{309, 43},
		{309, 44},
		{309, 45},
		{309, 46},
		{309, 47},
		{309, 48},
		{309, 49},
		{309, 50},
		{309, 51},
		{309, 52},
		{309, 53},
		{310, 22},
		{310, 23},
		{310, 24},
		{310, 25},
		{310, 26},
		{310, 27},
		{310, 28},
		{310, 29},
		{310, 30},
		{310, 31},
		{310, 32},
		{310, 33},
		{310, 34},
		{310, 35},
		{310, 36},
		{310, 37},
		{310, 38},
		{310, 39},
		{310, 40},
		{310, 41},
		{310, 42},
		{310, 43},
		{310, 44},
		{310, 45},
		{310, 46},
		{310, 47},
		{310, 48},
		{310, 49},
		{310, 50},
		{310, 51},
		{310, 52},
		{310, 53},
		{311, 22},
		{311, 23},
		{311, 24},
		{311, 25},
		{311, 26},
		{311, 27},
		{311, 28},
		{311, 29},
		{311, 30},
		{311, 31},
		{311, 32},
		{311, 33},
		{311, 34},
		{311, 35},
		{311, 36},
		{311, 37},
		{311, 38},
		{311, 39},
		{311, 40},
		{311, 41},
		{311, 42},
		{311, 43},
		{311, 44},
		{311, 45},
		{311, 46},
		{311, 47},
		{311, 48},
		{311, 49},
		{311, 50},
		{311, 51},
		{311, 52},
		{311, 53},
		{312, 22},
		{312, 23},
		{312, 24},
		{312, 25},
		{312, 26},
		{312, 27},
		{312, 28},
		{312, 29},
		{312, 30},
		{312, 31},
		{312, 32},
		{312, 33},
		{312, 34},
		{312, 35},
		{312, 36},
		{312, 37},
		{312, 38},
		{312, 39},
		{312, 40},
		{312, 41},
		{312, 42},
		{312, 43},
		{312, 44},
		{312, 45},
		{312, 46},
		{312, 47},
		{312, 48},
		{312, 49},
		{312, 50},
		{312, 51},
		{312, 52},
		{312, 53},
		{313, 22},
		{313, 23},
		{313, 24},
		{313, 25},
		{313, 26},
		{313, 27},
		{313, 28},
		{313, 29},
		{313, 30},
		{313, 31},
		{313, 32},
		{313, 33},
		{313, 34},
		{313, 35},
		{313, 36},
		{313, 37},
		{313, 38},
		{313, 39},
		{313, 40},
		{313, 41},
		{313, 42},
		{313, 43},
		{313, 44},
		{313, 45},
		{313, 46},
		{313, 47},
		{313, 48},
		{313, 49},
		{313, 50},
		{313, 51},
		{313, 52},
		{313, 53},
		{314, 22},
		{314, 23},
		{314, 24},
		{314, 25},
		{314, 26},
		{314, 27},
		{314, 28},
		{314, 29},
		{314, 30},
		{314, 31},
		{314, 32},
		{314, 33},
		{314, 34},
		{314, 35},
		{314, 36},
		{314, 37},
		{314, 38},
		{314, 39},
		{314, 40},
		{314, 41},
		{314, 42},
		{314, 43},
		{314, 44},
		{314, 45},
		{314, 46},
		{314, 47},
		{314, 48},
		{314, 49},
		{314, 50},
		{314, 51},
		{314, 52},
		{314, 53},
		{315, 22},
		{315, 23},
		{315, 24},
		{315, 25},
		{315, 26},
		{315, 27},
		{315, 28},
		{315, 29},
		{315, 30},
		{315, 31},
		{315, 32},
		{315, 33},
		{315, 34},
		{315, 35},
		{315, 36},
		{315, 37},
		{315, 38},
		{315, 39},
		{315, 40},
		{315, 41},
		{315, 42},
		{315, 43},
		{315, 44},
		{315, 45},
		{315, 46},
		{315, 47},
		{315, 48},
		{315, 49},
		{315, 50},
		{315, 51},
		{315, 52},
		{315, 53},
		{316, 22},
		{316, 23},
		{316, 24},
		{316, 25},
		{316, 26},
		{316, 27},
		{316, 28},
		{316, 29},
		{316, 30},
		{316, 31},
		{316, 32},
		{316, 33},
		{316, 34},
		{316, 35},
		{316, 36},
		{316, 37},
		{316, 38},
		{316, 39},
		{316, 40},
		{316, 41},
		{316, 42},
		{316, 43},
		{316, 44},
		{316, 45},
		{316, 46},
		{316, 47},
		{316, 48},
		{316, 49},
		{316, 50},
		{316, 51},
		{316, 52},
		{316, 53},
		{317, 22},
		{317, 23},
		{317, 24},
		{317, 25},
		{317, 26},
		{317, 27},
		{317, 28},
		{317, 29},
		{317, 30},
		{317, 31},
		{317, 32},
		{317, 33},
		{317, 34},
		{317, 35},
		{317, 36},
		{317, 37},
		{317, 38},
		{317, 39},
		{317, 40},
		{317, 41},
		{317, 42},
		{317, 43},
		{317, 44},
		{317, 45},
		{317, 46},
		{317, 47},
		{317, 48},
		{317, 49},
		{317, 50},
		{317, 51},
		{317, 52},
		{317, 53},
		{318, 22},
		{318, 23},
		{318, 24},
		{318, 25},
		{318, 26},
		{318, 27},
		{318, 28},
		{318, 29},
		{318, 30},
		{318, 31},
		{318, 32},
		{318, 33},
		{318, 34},
		{318, 35},
		{318, 36},
		{318, 37},
		{318, 38},
		{318, 39},
		{318, 40},
		{318, 41},
		{318, 42},
		{318, 43},
		{318, 44},
		{318, 45},
		{318, 46},
		{318, 47},
		{318, 48},
		{318, 49},
		{318, 50},
		{318, 51},
		{318, 52},
		{318, 53},
		{319, 22},
		{319, 23},
		{319, 24},
		{319, 25},
		{319, 26},
		{319, 27},
		{319, 28},
		{319, 29},
		{319, 30},
		{319, 31},
		{319, 32},
		{319, 33},
		{319, 34},
		{319, 35},
		{319, 36},
		{319, 37},
		{319, 38},
		{319, 39},
		{319, 40},
		{319, 41},
		{319, 42},
		{319, 43},
		{319, 44},
		{319, 45},
		{319, 46},
		{319, 47},
		{319, 48},
		{319, 49},
		{319, 50},
		{319, 51},
		{319, 52},
		{319, 53},
		{320, 22},
		{320, 23},
		{320, 24},
		{320, 25},
		{320, 26},
		{320, 27},
		{320, 28},
		{320, 29},
		{320, 30},
		{320, 31},
		{320, 32},
		{320, 33},
		{320, 34},
		{320, 35},
		{320, 36},
		{320, 37},
		{320, 38},
		{320, 39},
		{320, 40},
		{320, 41},
		{320, 42},
		{320, 43},
		{320, 44},
		{320, 45},
		{320, 46},
		{320, 47},
		{320, 48},
		{320, 49},
		{320, 50},
		{320, 51},
		{320, 52},
		{320, 53},
		{321, 22},
		{321, 23},
		{321, 24},
		{321, 25},
		{321, 26},
		{321, 27},
		{321, 28},
		{321, 29},
		{321, 30},
		{321, 31},
		{321, 32},
		{321, 33},
		{321, 34},
		{321, 35},
		{321, 36},
		{321, 37},
		{321, 38},
		{321, 39},
		{321, 40},
		{321, 41},
		{321, 42},
		{321, 43},
		{321, 44},
		{321, 45},
		{321, 46},
		{321, 47},
		{321, 48},
		{321, 49},
		{321, 50},
		{321, 51},
		{321, 52},
		{321, 53},
		{322, 22},
		{322, 23},
		{322, 24},
		{322, 25},
		{322, 26},
		{322, 27},
		{322, 28},
		{322, 29},
		{322, 30},
		{322, 31},
		{322, 32},
		{322, 33},
		{322, 34},
		{322, 35},
		{322, 36},
		{322, 37},
		{322, 38},
		{322, 39},
		{322, 40},
		{322, 41},
		{322, 42},
		{322, 43},
		{322, 44},
		{322, 45},
		{322, 46},
		{322, 47},
		{322, 48},
		{322, 49},
		{322, 50},
		{322, 51},
		{322, 52},
		{322, 53},
		{323, 22},
		{323, 23},
		{323, 24},
		{323, 25},
		{323, 26},
		{323, 27},
		{323, 28},
		{323, 29},
		{323, 30},
		{323, 31},
		{323, 32},
		{323, 33},
		{323, 34},
		{323, 35},
		{323, 36},
		{323, 37},
		{323, 38},
		{323, 39},
		{323, 40},
		{323, 41},
		{323, 42},
		{323, 43},
		{323, 44},
		{323, 45},
		{323, 46},
		{323, 47},
		{323, 48},
		{323, 49},
		{323, 50},
		{323, 51},
		{323, 52},
		{323, 53},
		{324, 22},
		{324, 23},
		{324, 24},
		{324, 25},
		{324, 26},
		{324, 27},
		{324, 28},
		{324, 29},
		{324, 30},
		{324, 31},
		{324, 32},
		{324, 33},
		{324, 34},
		{324, 35},
		{324, 36},
		{324, 37},
		{324, 38},
		{324, 39},
		{324, 40},
		{324, 41},
		{324, 42},
		{324, 43},
		{324, 44},
		{324, 45},
		{324, 46},
		{324, 47},
		{324, 48},
		{324, 49},
		{324, 50},
		{324, 51},
		{324, 52},
		{324, 53},
		{325, 22},
		{325, 23},
		{325, 24},
		{325, 25},
		{325, 26},
		{325, 27},
		{325, 28},
		{325, 29},
		{325, 30},
		{325, 31},
		{325, 32},
		{325, 33},
		{325, 34},
		{325, 35},
		{325, 36},
		{325, 37},
		{325, 38},
		{325, 39},
		{325, 40},
		{325, 41},
		{325, 42},
		{325, 43},
		{325, 44},
		{325, 45},
		{325, 46},
		{325, 47},
		{325, 48},
		{325, 49},
		{325, 50},
		{325, 51},
		{325, 52},
		{325, 53},
		{326, 22},
		{326, 23},
		{326, 24},
		{326, 25},
		{326, 26},
		{326, 27},
		{326, 28},
		{326, 29},
		{326, 30},
		{326, 31},
		{326, 32},
		{326, 33},
		{326, 34},
		{326, 35},
		{326, 36},
		{326, 37},
		{326, 38},
		{326, 39},
		{326, 40},
		{326, 41},
		{326, 42},
		{326, 43},
		{326, 44},
		{326, 45},
		{326, 46},
		{326, 47},
		{326, 48},
		{326, 49},
		{326, 50},
		{326, 51},
		{326, 52},
		{326, 53},
		{327, 22},
		{327, 23},
		{327, 24},
		{327, 25},
		{327, 26},
		{327, 27},
		{327, 28},
		{327, 29},
		{327, 30},
		{327, 31},
		{327, 32},
		{327, 33},
		{327, 34},
		{327, 35},
		{327, 36},
		{327, 37},
		{327, 38},
		{327, 39},
		{327, 40},
		{327, 41},
		{327, 42},
		{327, 43},
		{327, 44},
		{327, 45},
		{327, 46},
		{327, 47},
		{327, 48},
		{327, 49},
		{327, 50},
		{327, 51},
		{327, 52},
		{327, 53},
		{328, 22},
		{328, 23},
		{328, 24},
		{328, 25},
		{328, 26},
		{328, 27},
		{328, 28},
		{328, 29},
		{328, 30},
		{328, 31},
		{328, 32},
		{328, 33},
		{328, 34},
		{328, 35},
		{328, 36},
		{328, 37},
		{328, 38},
		{328, 39},
		{328, 40},
		{328, 41},
		{328, 42},
		{328, 43},
		{328, 44},
		{328, 45},
		{328, 46},
		{328, 47},
		{328, 48},
		{328, 49},
		{328, 50},
		{328, 51},
		{328, 52},
		{328, 53},
		{329, 22},
		{329, 23},
		{329, 24},
		{329, 25},
		{329, 26},
		{329, 27},
		{329, 28},
		{329, 29},
		{329, 30},
		{329, 31},
		{329, 32},
		{329, 33},
		{329, 34},
		{329, 35},
		{329, 36},
		{329, 37},
		{329, 38},
		{329, 39},
		{329, 40},
		{329, 41},
		{329, 42},
		{329, 43},
		{329, 44},
		{329, 45},
		{329, 46},
		{329, 47},
		{329, 48},
		{329, 49},
		{329, 50},
		{329, 51},
		{329, 52},
		{329, 53},
		{330, 24},
		{330, 25},
		{330, 26},
		{330, 27},
		{330, 28},
		{330, 29},
		{330, 30},
		{330, 31},
		{330, 32},
		{330, 33},
		{330, 34},
		{330, 35},
		{330, 36},
		{330, 37},
		{330, 38},
		{330, 39},
		{330, 40},
		{330, 41},
		{330, 42},
		{330, 43},
		{330, 44},
		{330, 45},
		{330, 46},
		{330, 47},
		{330, 48},
		{330, 49},
		{330, 50},
		{330, 51},
		{330, 52},
		{330, 53},
		{331, 24},
		{331, 25},
		{331, 26},
		{331, 27},
		{331, 28},
		{331, 29},
		{331, 30},
		{331, 31},
		{331, 32},
		{331, 33},
		{331, 34},
		{331, 35},
		{331, 36},
		{331, 37},
		{331, 38},
		{331, 39},
		{331, 40},
		{331, 41},
		{331, 42},
		{331, 43},
		{331, 44},
		{331, 45},
		{331, 46},
		{331, 47},
		{331, 48},
		{331, 49},
		{331, 50},
		{331, 51},
		{331, 52},
		{331, 53},
		{332, 24},
		{332, 25},
		{332, 26},
		{332, 27},
		{332, 28},
		{332, 29},
		{332, 30},
		{332, 31},
		{332, 32},
		{332, 33},
		{332, 34},
		{332, 35},
		{332, 36},
		{332, 37},
		{332, 38},
		{332, 39},
		{332, 40},
		{332, 41},
		{332, 42},
		{332, 43},
		{332, 44},
		{332, 45},
		{332, 46},
		{332, 47},
		{332, 48},
		{332, 49},
		{332, 50},
		{332, 51},
		{332, 52},
		{332, 53},
		{333, 25},
		{333, 26},
		{333, 27},
		{333, 28},
		{333, 29},
		{333, 30},
		{333, 31},
		{333, 32},
		{333, 33},
		{333, 34},
		{333, 35},
		{333, 36},
		{333, 37},
		{333, 38},
		{333, 39},
		{333, 40},
		{333, 41},
		{333, 42},
		{333, 43},
		{333, 44},
		{333, 45},
		{333, 46},
		{333, 47},
		{333, 48},
		{333, 49},
		{333, 50},
		{333, 51},
		{333, 52},
		{333, 53},
		{334, 25},
		{334, 26},
		{334, 27},
		{334, 28},
		{334, 29},
		{334, 30},
		{334, 31},
		{334, 32},
		{334, 33},
		{334, 34},
		{334, 35},
		{334, 36},
		{334, 37},
		{334, 38},
		{334, 39},
		{334, 40},
		{334, 41},
		{334, 42},
		{334, 43},
		{334, 44},
		{334, 45},
		{334, 46},
		{334, 47},
		{334, 48},
		{334, 49},
		{334, 50},
		{334, 51},
		{334, 52},
		{334, 53},
		{335, 25},
		{335, 26},
		{335, 27},
		{335, 28},
		{335, 29},
		{335, 30},
		{335, 31},
		{335, 32},
		{335, 33},
		{335, 34},
		{335, 35},
		{335, 36},
		{335, 37},
		{335, 38},
		{335, 39},
		{335, 40},
		{335, 41},
		{335, 42},
		{335, 43},
		{335, 44},
		{335, 45},
		{335, 46},
		{335, 47},
		{335, 48},
		{335, 49},
		{335, 50},
		{335, 51},
		{335, 52},
		{335, 53},
		{336, 26},
		{336, 27},
		{336, 28},
		{336, 29},
		{336, 30},
		{336, 31},
		{336, 32},
		{336, 33},
		{336, 34},
		{336, 35},
		{336, 36},
		{336, 37},
		{336, 38},
		{336, 39},
		{336, 40},
		{336, 41},
		{336, 42},
		{336, 43},
		{336, 44},
		{336, 45},
		{336, 46},
		{336, 47},
		{336, 48},
		{336, 49},
		{336, 50},
		{336, 51},
		{336, 52},
		{337, 26},
		{337, 27},
		{337, 28},
		{337, 29},
		{337, 30},
		{337, 31},
		{337, 32},
		{337, 33},
		{337, 34},
		{337, 35},
		{337, 36},
		{337, 37},
		{337, 38},
		{337, 39},
		{337, 40},
		{337, 41},
		{337, 42},
		{337, 43},
		{337, 44},
		{337, 45},
		{337, 46},
		{337, 47},
		{337, 48},
		{337, 49},
		{337, 50},
		{337, 51},
		{337, 52},
		{338, 27},
		{338, 28},
		{338, 29},
		{338, 30},
		{338, 31},
		{338, 32},
		{338, 33},
		{338, 34},
		{338, 35},
		{338, 36},
		{338, 37},
		{338, 38},
		{338, 39},
		{338, 40},
		{338, 41},
		{338, 42},
		{338, 43},
		{338, 44},
		{338, 45},
		{338, 46},
		{338, 47},
		{338, 48},
		{338, 49},
		{338, 50},
		{339, 27},
		{339, 28},
		{339, 29},
		{339, 30},
		{339, 31},
		{339, 32},
		{339, 33},
		{339, 34},
		{339, 35},
		{339, 36},
		{339, 37},
		{339, 38},
		{339, 39},
		{339, 40},
		{339, 41},
		{339, 42},
		{339, 43},
		{339, 44},
		{339, 45},
		{339, 46},
		{339, 47},
		{339, 48},
		{339, 49},
		{339, 50},
		{340, 27},
		{340, 28},
		{340, 29},
		{340, 30},
		{340, 31},
		{340, 32},
		{340, 33},
		{340, 34},
		{340, 35},
		{340, 36},
		{340, 37},
		{340, 38},
		{340, 39},
		{340, 40},
		{340, 41},
		{340, 42},
		{340, 43},
		{340, 44},
		{340, 45},
		{340, 46},
		{340, 47},
		{340, 48},
		{340, 49},
		{340, 50},
		{341, 29},
		{341, 30},
		{341, 31},
		{341, 32},
		{341, 33},
		{341, 34},
		{341, 35},
		{341, 36},
		{341, 37},
		{341, 38},
		{341, 39},
		{341, 40},
		{341, 41},
		{341, 42},
		{341, 43},
		{341, 44},
		{341, 45},
		{341, 46},
		{341, 47},
		{341, 48},
		{341, 49},
		{341, 50},
		{342, 30},
		{342, 31},
		{342, 32},
		{342, 33},
		{342, 34},
		{342, 35},
		{342, 36},
		{342, 37},
		{342, 38},
		{342, 39},
		{342, 40},
		{342, 41},
		{342, 42},
		{342, 43},
		{342, 44},
		{342, 45},
		{342, 46},
		{342, 47},
		{342, 48}
	].

%% 寻宝区
get_hunt() ->
	[
	].

%% NPC 列表
get_npcs() ->
	[
	].

%% 怪物列表
get_creeps() ->
	[
		{ 20005001,#p_coord{x=1757, y=830 } },
		{ 20005002,#p_coord{x=3245, y=2410 } },
		{ 20005003,#p_coord{x=5733, y=2661 } },
		{ 20005004,#p_coord{x=1852, y=3536 } },
		{ 20005005,#p_coord{x=6234, y=5368 } },
		{ 20005006,#p_coord{x=2995, y=4866 } },
		{ 20005007,#p_coord{x=1226, y=5868 } },
		{ 20005008,#p_coord{x=3699, y=6744 } },
		{ 20001112,#p_coord{x=3802, y=498 } },
		{ 20001112,#p_coord{x=3822, y=306 } },
		{ 20001112,#p_coord{x=4013, y=498 } },
		{ 20001112,#p_coord{x=4009, y=322 } },
		{ 20001113,#p_coord{x=782, y=2376 } },
		{ 20001113,#p_coord{x=1038, y=2376 } },
		{ 20001113,#p_coord{x=776, y=2159 } },
		{ 20001113,#p_coord{x=1038, y=2163 } },
		{ 20001114,#p_coord{x=4768, y=3604 } },
		{ 20001114,#p_coord{x=4956, y=3624 } },
		{ 20001114,#p_coord{x=4700, y=3470 } },
		{ 20001114,#p_coord{x=5134, y=3652 } },
		{ 20001115,#p_coord{x=6870, y=3861 } },
		{ 20001115,#p_coord{x=7030, y=3866 } },
		{ 20001115,#p_coord{x=6905, y=3661 } },
		{ 20001115,#p_coord{x=7091, y=3740 } },
		{ 20001116,#p_coord{x=4470, y=5749 } },
		{ 20001116,#p_coord{x=4654, y=5756 } },
		{ 20001116,#p_coord{x=4484, y=5577 } },
		{ 20001116,#p_coord{x=4641, y=5599 } },
		{ 20001117,#p_coord{x=280, y=5038 } },
		{ 20001117,#p_coord{x=503, y=5059 } },
		{ 20001117,#p_coord{x=333, y=4868 } },
		{ 20001117,#p_coord{x=536, y=4888 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
