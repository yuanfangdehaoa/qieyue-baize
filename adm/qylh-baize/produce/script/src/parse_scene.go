package main

import (
	"bytes"
	"encoding/binary"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"text/template"
)

type SceneData struct {
	ID     string
	Width  uint32
	Height uint32
	Masks  map[int]string
	Buffer *bytes.Buffer
}

var tplErl1 string = `%% Automatically generated, do not edit
%% Generated by parse_scene.go

-module(scene_mask_{{ .ID }}).

-compile([export_all]).
-compile(nowarn_export_all).

size() -> { {{ .Width }}, {{ .Height }} }.

width() -> {{ .Width }}.

height() -> {{ .Height }}.

{{ range $k, $v := .Masks }}
mask({{ $k }}) -> { {{ $v }} };
{{- end }}
mask(_) -> {}.
`

var tplErl2 string = `%% Automatically generated, do not edit
%% Generated by parse_scene.go

-module(scene_config).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 场景大小
{{ range . }}
size({{ . }}) ->
	scene_mask_{{ . }}:size();
{{ end }}
size(_) ->
	undefined.

%% 场景宽度
{{ range . }}
width({{ . }}) ->
	scene_mask_{{ . }}:width();
{{ end }}
width(_) ->
	undefined.

%% 场景高度
{{ range . }}
height({{ . }}) ->
	scene_mask_{{ . }}:height();
{{ end }}
height(_) ->
	undefined.

%% 是否可走
walkable(SceneID, Coord) ->
	walkable(SceneID, Coord#p_coord.x, Coord#p_coord.y).

{{ range . }}
walkable({{ . }}, X, Y) ->
	Ys = scene_mask_{{ . }}:mask(X),
	case 0 =< Y andalso Y < erlang:size(Ys) of
		true  -> element(Y+1, Ys) > 0;
		false -> false
	end;
{{ end }}
walkable(_, _, _) ->
	false.

%% 是否跳跃点
{{ range . }}
jumpable({{ . }}, Coord) ->
	jumpable2(scene_actor_{{ . }}:get_jump(), Coord);
{{ end }}
jumpable(_, _) ->
	false.

jumpable2([Coord1 | T], Coord2) ->
	case scene_util:is_nearby(Coord1, Coord2) of
		true  -> true;
		false -> jumpable2(T, Coord2)
	end;
jumpable2([], _) ->
	false.

%% 安全区
{{ range . }}
is_safe({{ . }}, X, Y) ->
	Ys = scene_mask_{{ . }}:mask(X),
	case 0 =< Y andalso Y < erlang:size(Ys) of
		true  -> element(Y+1, Ys) == 129;
		false -> false
	end;
{{ end }}
is_safe(_, _, _) ->
	false.

%% 传送点
%% {CurCoord, DstScene, DstCoord}
{{ range . }}
portal({{ . }}, PortalID) ->
	scene_actor_{{ . }}:get_portal(PortalID);
{{ end }}
portal(_, _) ->
	[].

%% 出生点
{{ range . }}
born({{ . }}) ->
	scene_actor_{{ . }}:get_born();
{{ end }}
born(_) ->
	[].

%% 复活点
{{ range . }}
reborn({{ . }}) ->
	scene_actor_{{ . }}:get_reborn();
{{ end }}
reborn(_) ->
	[].

%% 寻宝点
{{ range . }}
hunt({{ . }}) ->
	scene_actor_{{ . }}:get_hunt();
{{ end }}
hunt(_) ->
	[].

%% npc
{{ range . }}
npcs({{ . }}) ->
	scene_actor_{{ . }}:get_npcs();
{{ end }}
npcs(_) ->
	[].

%% 怪物
{{ range . }}
creeps({{ . }}) ->
	scene_actor_{{ . }}:get_creeps();
{{ end }}
creeps(_) ->
	[].
`

func main() {
	data, err := ioutil.ReadFile(os.Args[1])
	if err != nil {
		log.Fatalf("文件读取失败: %v", err)
	}

	scene := parseScene(&SceneData{
		Masks:  make(map[int]string),
		Buffer: bytes.NewBuffer(data),
	})

	scene.ID = strings.TrimRight(filepath.Base(os.Args[1]), filepath.Ext(os.Args[1]))

	buf := bytes.NewBuffer(make([]byte, 0, 1024))
	t := template.New("tpl")
	t, _ = t.Parse(tplErl1)
	t.Execute(buf, scene)
	module := "scene_mask_" + scene.ID + ".erl"
	f1 := filepath.Join(os.Args[2], "src", module)
	ioutil.WriteFile(f1, buf.Bytes(), 0666)
}

func parseScene(scene *SceneData) *SceneData {
	var token uint32
	binary.Read(scene.Buffer, binary.LittleEndian, &token)

	var update uint32
	binary.Read(scene.Buffer, binary.LittleEndian, &update)

	var version uint32
	binary.Read(scene.Buffer, binary.LittleEndian, &version)

	// 场景id
	var sceneID uint32
	binary.Read(scene.Buffer, binary.LittleEndian, &sceneID)
	// scene.ID = sceneID

	// 地图宽度
	var width uint32
	binary.Read(scene.Buffer, binary.LittleEndian, &width)
	scene.Width = width

	// 地图高度
	var height uint32
	binary.Read(scene.Buffer, binary.LittleEndian, &height)
	scene.Height = height

	var compress uint32
	binary.Read(scene.Buffer, binary.LittleEndian, &compress)

	var position uint32
	binary.Read(scene.Buffer, binary.LittleEndian, &position)

	var length uint32
	binary.Read(scene.Buffer, binary.LittleEndian, &length)

	// 阻挡信息
	var masks map[int]string = make(map[int]string)
	var mask uint32

	for j := 0; j < int(height); j++ {
		for i := 0; i < int(width); i++ {
			binary.Read(scene.Buffer, binary.LittleEndian, &mask)
			var sep string = ""
			if masks[i] != "" {
				sep = ","
			}
			masks[i] += sep + strconv.Itoa(int(mask))
		}
	}

	scene.Masks = masks

	var splitWith uint32
	binary.Read(scene.Buffer, binary.LittleEndian, &splitWith)

	var splitHeight uint32
	binary.Read(scene.Buffer, binary.LittleEndian, &splitHeight)

	return scene
}
