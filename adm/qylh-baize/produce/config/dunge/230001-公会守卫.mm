<map version="freeplane 1.2.0">
<!--To view this file, download free mind mapping software Freeplane from http://freeplane.sourceforge.net -->
<node TEXT="230001" OBJECT="java.lang.Long|230001" ID="ID_1723255651" CREATED="1283093380553" MODIFIED="1559113906921"><hook NAME="MapStyle">
    <properties show_icon_for_attributes="true" show_note_icons="true"/>

<map_styles>
<stylenode LOCALIZED_TEXT="styles.root_node">
<stylenode LOCALIZED_TEXT="styles.predefined" POSITION="right">
<stylenode LOCALIZED_TEXT="default" MAX_WIDTH="600" COLOR="#000000" STYLE="as_parent">
<font NAME="SansSerif" SIZE="10" BOLD="false" ITALIC="false"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.details"/>
<stylenode LOCALIZED_TEXT="defaultstyle.note"/>
<stylenode LOCALIZED_TEXT="defaultstyle.floating">
<edge STYLE="hide_edge"/>
<cloud COLOR="#f0f0f0" SHAPE="ROUND_RECT"/>
</stylenode>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.user-defined" POSITION="right">
<stylenode LOCALIZED_TEXT="styles.topic" COLOR="#18898b" STYLE="fork">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.subtopic" COLOR="#cc3300" STYLE="fork">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.subsubtopic" COLOR="#669900">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.important">
<icon BUILTIN="yes"/>
</stylenode>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.AutomaticLayout" POSITION="right">
<stylenode LOCALIZED_TEXT="AutomaticLayout.level.root" COLOR="#000000">
<font SIZE="18"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,1" COLOR="#0033ff">
<font SIZE="16"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,2" COLOR="#00b439">
<font SIZE="14"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,3" COLOR="#990000">
<font SIZE="12"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,4" COLOR="#111111">
<font SIZE="10"/>
</stylenode>
</stylenode>
</stylenode>
</map_styles>
</hook>
<hook NAME="AutomaticEdgeColor" COUNTER="8"/>
<node TEXT="&#x5e76;&#x884c;&#x8282;&#x70b9;" POSITION="right" ID="ID_1752390664" CREATED="1552042018566" MODIFIED="1557568075877">
<edge COLOR="#00ffff"/>
<node TEXT="&#x4e8b;&#x4ef6;&#x8282;&#x70b9;" ID="ID_1969782829" CREATED="1557478968100" MODIFIED="1557478976522">
<attribute NAME="event" VALUE="hook_init"/>
<node TEXT="&#x5e8f;&#x5217;&#x8282;&#x70b9;" ID="ID_1303108632" CREATED="1557474941979" MODIFIED="1557476595715">
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1927674872" CREATED="1559628944347" MODIFIED="1559628966367">
<attribute_layout VALUE_WIDTH="238"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="guild_guard,init_dunge"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1618084005" CREATED="1557231500119" MODIFIED="1559114605388">
<attribute_layout VALUE_WIDTH="239"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="guild_guard,init_npcs"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1627777140" CREATED="1553486733993" MODIFIED="1559113932239">
<attribute_layout VALUE_WIDTH="238"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_ai,callback,guild_guard"/>
</node>
<node TEXT="&#x5ef6;&#x8fdf;&#x8282;&#x70b9;" ID="ID_374802387" CREATED="1557738431514" MODIFIED="1559113945816">
<attribute_layout VALUE_WIDTH="238"/>
<attribute NAME="tick" VALUE="dunge_util,get_cd,prep"/>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1276628935" CREATED="1552040959887" MODIFIED="1567847178697">
<attribute_layout VALUE_WIDTH="236"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="guild_guard,summon"/>
</node>
</node>
</node>
</node>
<node TEXT="&#x4e8b;&#x4ef6;&#x8282;&#x70b9;" ID="ID_506595682" CREATED="1552040885494" MODIFIED="1553590648563">
<attribute_layout VALUE_WIDTH="98"/>
<attribute NAME="event" VALUE="hook_enter"/>
<node TEXT="&#x5e8f;&#x5217;&#x8282;&#x70b9;" ID="ID_1960278332" CREATED="1552040941326" MODIFIED="1552633023608">
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1081730198" CREATED="1557236977624" MODIFIED="1559114630476">
<attribute_layout VALUE_WIDTH="215"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="guild_guard,init_role"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_696676835" CREATED="1552040959887" MODIFIED="1559114640876">
<attribute_layout VALUE_WIDTH="215"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="guild_guard,send_info"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1026192576" CREATED="1552040959887" MODIFIED="1559114656284">
<attribute_layout VALUE_WIDTH="215"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="guild_guard,send_npcs"/>
</node>
</node>
</node>
<node TEXT="&#x4e8b;&#x4ef6;&#x8282;&#x70b9;" ID="ID_1688748523" CREATED="1552967545941" MODIFIED="1553589833934">
<attribute_layout VALUE_WIDTH="102"/>
<attribute NAME="event" VALUE="hook_timeout"/>
<node TEXT="&#x5b50;&#x6811;&#x8282;&#x70b9;" ID="ID_769631013" CREATED="1553053834882" MODIFIED="1567847755977">
<attribute_layout VALUE_WIDTH="188"/>
<attribute NAME="tree" VALUE="cfg_dunge_ai,find,200002"/>
</node>
</node>
<node TEXT="&#x4e8b;&#x4ef6;&#x8282;&#x70b9;" ID="ID_955423594" CREATED="1552041250798" MODIFIED="1553498425114">
<attribute_layout VALUE_WIDTH="101"/>
<attribute NAME="event" VALUE="hook_creep_dead"/>
<font BOLD="false"/>
<node TEXT="&#x9009;&#x62e9;&#x8282;&#x70b9;" ID="ID_1779131613" CREATED="1557231872181" MODIFIED="1557231882889">
<node TEXT="&#x5e8f;&#x5217;&#x8282;&#x70b9;" ID="ID_283302674" CREATED="1557231888325" MODIFIED="1557231892793">
<node TEXT="&#x6761;&#x4ef6;&#x8282;&#x70b9;" ID="ID_1091132236" CREATED="1557231959999" MODIFIED="1559115322738">
<attribute_layout VALUE_WIDTH="203"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="guild_guard,is_npc_dead"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_410365760" CREATED="1557232353351" MODIFIED="1559115365277">
<attribute_layout VALUE_WIDTH="205"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="guild_guard,update_npc"/>
</node>
<node TEXT="&#x6210;&#x529f;&#x8282;&#x70b9;" ID="ID_939430338" CREATED="1557232404693" MODIFIED="1557232407338">
<node TEXT="&#x5e8f;&#x5217;&#x8282;&#x70b9;" ID="ID_1677655703" CREATED="1557232328917" MODIFIED="1557232332993">
<node TEXT="&#x6761;&#x4ef6;&#x8282;&#x70b9;" ID="ID_1187346389" CREATED="1557232005039" MODIFIED="1559115417026">
<attribute_layout VALUE_WIDTH="169"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="guild_guard,is_fail"/>
</node>
<node TEXT="&#x5b50;&#x6811;&#x8282;&#x70b9;" ID="ID_631317873" CREATED="1553053834882" MODIFIED="1557720070261">
<attribute_layout VALUE_WIDTH="170"/>
<attribute NAME="tree" VALUE="cfg_dunge_ai,find,200001"/>
</node>
</node>
</node>
</node>
<node TEXT="&#x5e8f;&#x5217;&#x8282;&#x70b9;" ID="ID_107569028" CREATED="1553590586565" MODIFIED="1553590590028">
<node TEXT="&#x6761;&#x4ef6;&#x8282;&#x70b9;" ID="ID_1544354693" CREATED="1557231903053" MODIFIED="1559115463710">
<attribute_layout VALUE_WIDTH="212"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="guild_guard,is_monst_dead"/>
</node>
<node TEXT="&#x5e8f;&#x5217;&#x8282;&#x70b9;" ID="ID_1692703966" CREATED="1553590519525" MODIFIED="1553590571964">
<node TEXT="&#x6761;&#x4ef6;&#x8282;&#x70b9;" ID="ID_913530244" CREATED="1553590525238" MODIFIED="1557291414096">
<attribute_layout VALUE_WIDTH="161"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_aiwave,is_over"/>
</node>
<node TEXT="&#x9009;&#x62e9;&#x8282;&#x70b9;" ID="ID_1856805098" CREATED="1553932443306" MODIFIED="1553932447282">
<node TEXT="&#x5e8f;&#x5217;&#x8282;&#x70b9;" ID="ID_289291" CREATED="1553932460834" MODIFIED="1553932462862">
<node TEXT="&#x6761;&#x4ef6;&#x8282;&#x70b9;" ID="ID_1003837830" CREATED="1553591646568" MODIFIED="1568027034686">
<attribute_layout VALUE_WIDTH="167"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_aiwave,is_max"/>
</node>
<node TEXT="&#x5b50;&#x6811;&#x8282;&#x70b9;" ID="ID_442901833" CREATED="1553053834882" MODIFIED="1568027037469">
<attribute_layout VALUE_WIDTH="167"/>
<attribute NAME="tree" VALUE="cfg_dunge_ai,find,200002"/>
</node>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_142799662" CREATED="1553590525238" MODIFIED="1568027029363">
<attribute_layout VALUE_WIDTH="168"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="guild_guard,summon_later,5"/>
</node>
</node>
</node>
</node>
</node>
</node>
</node>
</node>
</map>
