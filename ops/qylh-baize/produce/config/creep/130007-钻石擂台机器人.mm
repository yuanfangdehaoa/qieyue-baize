<map version="freeplane 1.2.0">
<!--To view this file, download free mind mapping software Freeplane from http://freeplane.sourceforge.net -->
<node TEXT="130007" OBJECT="java.lang.Long|130007" ID="ID_1723255651" CREATED="1283093380553" MODIFIED="1574337549669"><hook NAME="MapStyle">
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
<node TEXT="&#x5e76;&#x884c;&#x8282;&#x70b9;" POSITION="right" ID="ID_530694146" CREATED="1557567854459" MODIFIED="1557567856947">
<edge COLOR="#7c0000"/>
<node TEXT="&#x4e8b;&#x4ef6;&#x8282;&#x70b9;" ID="ID_1155887106" CREATED="1553619666015" MODIFIED="1557566528842">
<attribute NAME="event" VALUE="hook_dead"/>
<node TEXT="&#x5e8f;&#x5217;&#x8282;&#x70b9;" ID="ID_1752170420" CREATED="1553613345611" MODIFIED="1553613349151">
<node TEXT="&#x6761;&#x4ef6;&#x8282;&#x70b9;" ID="ID_1122725146" CREATED="1553613352523" MODIFIED="1574338773203">
<attribute_layout VALUE_WIDTH="162"/>
<attribute NAME="mod" VALUE="creep_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="compete_robot,can_reborn"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1651581259" CREATED="1553619698172" MODIFIED="1574774541708">
<attribute_layout VALUE_WIDTH="163"/>
<attribute NAME="mod" VALUE="creep_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="creep_ai,sleep,2000"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1542558647" CREATED="1553619698172" MODIFIED="1574775582848">
<attribute_layout VALUE_WIDTH="163"/>
<attribute NAME="mod" VALUE="creep_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="compete_robot,reborn"/>
</node>
</node>
</node>
<node TEXT="&#x9009;&#x62e9;&#x8282;&#x70b9;" ID="ID_486180262" CREATED="1530864785472" MODIFIED="1557567854523">
<node TEXT="&#x8ba1;&#x6570;&#x8282;&#x70b9;" ID="ID_1655256356" CREATED="1552562079868" MODIFIED="1558703227778">
<attribute NAME="times" VALUE="1" OBJECT="org.freeplane.features.format.FormattedNumber|1"/>
<attribute NAME="wait" VALUE="false"/>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1640426108" CREATED="1552562105573" MODIFIED="1558707615362" VSHIFT="10">
<attribute_layout VALUE_WIDTH="172"/>
<attribute NAME="mod" VALUE="creep_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="creep_ai,born"/>
</node>
</node>
<node TEXT="&#x5faa;&#x73af;&#x8282;&#x70b9;" ID="ID_1931068483" CREATED="1552562207915" MODIFIED="1553619832802">
<attribute NAME="times" VALUE="-1" OBJECT="org.freeplane.features.format.FormattedNumber|-1|#0.####"/>
<node TEXT="&#x5e8f;&#x5217;&#x8282;&#x70b9;" ID="ID_1166834345" CREATED="1530864804610" MODIFIED="1554957863493">
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1548288356" CREATED="1530864812816" MODIFIED="1552902910342">
<attribute_layout VALUE_WIDTH="115"/>
<attribute NAME="mod" VALUE="creep_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="creep_ai,guard"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_239768857" CREATED="1530864812816" MODIFIED="1554886985569">
<attribute_layout VALUE_WIDTH="115"/>
<attribute NAME="mod" VALUE="creep_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="creep_ai,prepare"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1558248466" CREATED="1530867933265" MODIFIED="1552902907186">
<attribute_layout VALUE_WIDTH="115"/>
<attribute NAME="mod" VALUE="creep_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="creep_ai,pursue"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_55297974" CREATED="1530867818857" MODIFIED="1552902830918">
<attribute_layout VALUE_WIDTH="116"/>
<attribute NAME="mod" VALUE="creep_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="creep_ai,attack"/>
</node>
</node>
</node>
</node>
</node>
</node>
</map>
