<map version="freeplane 1.2.0">
<!--To view this file, download free mind mapping software Freeplane from http://freeplane.sourceforge.net -->
<node TEXT="120104" OBJECT="java.lang.Long|120104" ID="ID_1723255651" CREATED="1283093380553" MODIFIED="1573022955562"><hook NAME="MapStyle">
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
<hook NAME="AutomaticEdgeColor" COUNTER="12"/>
<node TEXT="&#x5e76;&#x884c;&#x8282;&#x70b9;" POSITION="right" ID="ID_1864023417" CREATED="1557567221387" MODIFIED="1557567224717">
<edge COLOR="#7c7c00"/>
<node TEXT="&#x4e8b;&#x4ef6;&#x8282;&#x70b9;" ID="ID_1050916813" CREATED="1553620618566" MODIFIED="1553620626850">
<attribute NAME="event" VALUE="hook_dead"/>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1077946295" CREATED="1553004955100" MODIFIED="1573029994048">
<attribute_layout VALUE_WIDTH="199"/>
<attribute NAME="mod" VALUE="creep_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="creep_ai,disappear"/>
</node>
</node>
<node TEXT="&#x4e8b;&#x4ef6;&#x8282;&#x70b9;" ID="ID_674675028" CREATED="1553620618566" MODIFIED="1573029945859">
<attribute NAME="event" VALUE="hook_timeout"/>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_939220299" CREATED="1553004810101" MODIFIED="1573029990887">
<attribute_layout VALUE_WIDTH="200"/>
<attribute NAME="mod" VALUE="creep_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_newbie_summon_creepai,bomb"/>
</node>
</node>
<node TEXT="&#x9009;&#x62e9;&#x8282;&#x70b9;" ID="ID_1082674358" CREATED="1553004528461" MODIFIED="1557567221429">
<node TEXT="&#x6761;&#x4ef6;&#x8282;&#x70b9;" ID="ID_1327678367" CREATED="1553484561071" MODIFIED="1573023085996">
<attribute_layout VALUE_WIDTH="240"/>
<attribute NAME="mod" VALUE="creep_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_newbie_summon_creepai,is_over"/>
</node>
<node TEXT="&#x5faa;&#x73af;&#x8282;&#x70b9;" ID="ID_722942858" CREATED="1553004535478" MODIFIED="1553620630441">
<attribute NAME="times" VALUE="-1" OBJECT="org.freeplane.features.format.FormattedNumber|-1|#0.####"/>
<node TEXT="&#x9009;&#x62e9;&#x8282;&#x70b9;" ID="ID_703319115" CREATED="1557972792598" MODIFIED="1557972795632">
<node TEXT="&#x8ba1;&#x6570;&#x8282;&#x70b9;" ID="ID_449855052" CREATED="1553004435789" MODIFIED="1553004528497">
<attribute NAME="times" VALUE="1" OBJECT="org.freeplane.features.format.FormattedNumber|1"/>
<node TEXT="&#x5e8f;&#x5217;&#x8282;&#x70b9;" ID="ID_1913813098" CREATED="1573041581546" MODIFIED="1573041584389">
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1489644577" CREATED="1553004441125" MODIFIED="1573042338864">
<attribute_layout VALUE_WIDTH="240"/>
<attribute NAME="mod" VALUE="creep_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_newbie_summon_creepai,init_bomb"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_108253338" CREATED="1553004441125" MODIFIED="1573042341527">
<attribute_layout VALUE_WIDTH="240"/>
<attribute NAME="mod" VALUE="creep_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="creep_ai,born"/>
</node>
</node>
</node>
<node TEXT="&#x9009;&#x62e9;&#x8282;&#x70b9;" ID="ID_633220135" CREATED="1553004584083" MODIFIED="1553004587192">
<node TEXT="&#x5b50;&#x6811;&#x8282;&#x70b9;" ID="ID_1104306137" CREATED="1554175242013" MODIFIED="1557719643540">
<attribute_layout VALUE_WIDTH="148"/>
<attribute NAME="tree" VALUE="cfg_creep_ai,find,100003"/>
</node>
</node>
</node>
</node>
</node>
</node>
</node>
</map>
