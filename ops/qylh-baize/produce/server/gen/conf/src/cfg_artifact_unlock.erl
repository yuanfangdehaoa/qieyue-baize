% Automatically generated, do not edit
-module(cfg_artifact_unlock).

-compile([export_all]).
-compile(nowarn_export_all).

unlock_artifact(1) -> [{1,8},{2,8},{3,8},{4,8},{5,8}];
unlock_artifact(2) -> [{1,10},{2,10},{3,10},{4,10},{5,10}];
unlock_artifact(3) -> [{1,13},{2,13},{3,13},{4,13},{5,13}];
unlock_artifact(4) -> [{1,15},{2,15},{3,15},{4,15},{5,15}];
unlock_artifact(_) -> [].

artifacts(1) -> [110000,120000,130000,140000];
artifacts(2) -> [220000,230000,240000,210000];
artifacts(3) -> [310000,320000,330000,340000];
artifacts(4) -> [410000,420000,430000,440000];
artifacts(_) -> [].


unlock_enchant(110000) -> {[{3,5}], [{2012,2000}], [{4,1125}], [{6,1125}]};
unlock_enchant(120000) -> {[{3,5}], [{2012,2000}], [{2,33750}], [{5,1875}]};
unlock_enchant(130000) -> {[{3,5}], [{2012,2000}], [{4,2625}], [{11,2625}]};
unlock_enchant(140000) -> {[{3,5}], [{2012,2000}], [{26,225}], [{27,225}]};
unlock_enchant(210000) -> {[{3,5}], [{2012,2000}], [{5,1312}], [{12,1312}]};
unlock_enchant(220000) -> {[{3,5}], [{2012,2000}], [{12,2062}], [{10,2062}]};
unlock_enchant(230000) -> {[{3,5}], [{2012,2000}], [{2,54375}], [{10,3000}]};
unlock_enchant(240000) -> {[{3,5}], [{2012,2000}], [{19,150}], [{27,300}]};
unlock_enchant(310000) -> {[{3,5}], [{2012,2000}], [{4,1500}], [{6,1500}]};
unlock_enchant(320000) -> {[{3,5}], [{2012,2000}], [{9,2250}], [{23,60}]};
unlock_enchant(330000) -> {[{3,5}], [{2012,2000}], [{9,3750}], [{25,225}]};
unlock_enchant(340000) -> {[{3,5}], [{2012,2000}], [{21,45}], [{25,300}]};
unlock_enchant(410000) -> {[{3,5}], [{2012,2000}], [{8,1687}], [{7,1687}]};
unlock_enchant(420000) -> {[{3,5}], [{2012,2000}], [{8,2250}], [{7,2250}]};
unlock_enchant(430000) -> {[{3,5}], [{2012,2000}], [{25,270}], [{26,180}]};
unlock_enchant(440000) -> {[{3,5}], [{2012,2000}], [{23,75}], [{17,75}]};
unlock_enchant(_) -> undefined.

artifact_name(110000) -> "紫晶黯噬幻语";
artifact_name(120000) -> "艾斯青翼魔杖";
artifact_name(130000) -> "万魔天辉杖";
artifact_name(140000) -> "腥红天罚之握";
artifact_name(210000) -> "提亚维卡坚盾";
artifact_name(220000) -> "星之神圣加护";
artifact_name(230000) -> "巨神兵的加护";
artifact_name(240000) -> "阿卡德鲜红盾";
artifact_name(310000) -> "钴蓝骑士魔弓";
artifact_name(320000) -> "晶蓝翼神之羽";
artifact_name(330000) -> "焚焰蛾之殇";
artifact_name(340000) -> "地狱叹息之羽";
artifact_name(410000) -> "蔚蓝之语";
artifact_name(420000) -> "辉光星夜";
artifact_name(430000) -> "天际秘韵";
artifact_name(440000) -> "涅槃火鸟";
artifact_name(_) -> "".

artifact_typename(1) -> "法杖";
artifact_typename(2) -> "圣盾";
artifact_typename(3) -> "弓";
artifact_typename(4) -> "扇";
artifact_typename(_) -> "".
