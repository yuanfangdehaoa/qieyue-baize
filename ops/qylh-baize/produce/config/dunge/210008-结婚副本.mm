<map version="freeplane 1.2.0">
<!--To view this file, download free mind mapping software Freeplane from http://freeplane.sourceforge.net -->
<node TEXT="210008" OBJECT="java.lang.Long|210008" ID="ID_1723255651" CREATED="1283093380553" MODIFIED="1566458792548"><hook NAME="MapStyle">
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
<hook NAME="AutomaticEdgeColor" COUNTER="10"/>
<node TEXT="&#x5e76;&#x884c;&#x8282;&#x70b9;" POSITION="right" ID="ID_1752390664" CREATED="1552042018566" MODIFIED="1557568036655">
<edge COLOR="#00ffff"/>
<node TEXT="&#x4e8b;&#x4ef6;&#x8282;&#x70b9;" ID="ID_1776905316" CREATED="1553520558456" MODIFIED="1557731979364">
<attribute_layout VALUE_WIDTH="99"/>
<attribute NAME="event" VALUE="hook_init"/>
<node TEXT="&#x5e8f;&#x5217;&#x8282;&#x70b9;" ID="ID_1948550021" CREATED="1557474695716" MODIFIED="1557474698562">
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1972978306" CREATED="1553486733993" MODIFIED="1566627155858">
<attribute_layout VALUE_WIDTH="238"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_couple_dungeai,init"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1627777140" CREATED="1553486733993" MODIFIED="1566459423031">
<attribute_layout VALUE_WIDTH="238"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_ai,callback,dunge_couple_dungeai"/>
</node>
<node TEXT="&#x5ef6;&#x8fdf;&#x8282;&#x70b9;" ID="ID_276926018" CREATED="1557738431514" MODIFIED="1566627792687">
<attribute_layout VALUE_WIDTH="220"/>
<attribute NAME="tick" VALUE="dunge_util,get_cd,prep"/>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1276628935" CREATED="1552040959887" MODIFIED="1557284923533">
<attribute_layout VALUE_WIDTH="239"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_aiwave,summon"/>
</node>
</node>
</node>
</node>
<node TEXT="&#x4e8b;&#x4ef6;&#x8282;&#x70b9;" ID="ID_676712398" CREATED="1553520558456" MODIFIED="1566530877101">
<attribute_layout VALUE_WIDTH="99"/>
<attribute NAME="event" VALUE="hook_enter"/>
<node TEXT="&#x5e8f;&#x5217;&#x8282;&#x70b9;" ID="ID_71035631" CREATED="1567480175754" MODIFIED="1567480186895">
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_432770750" CREATED="1552040959887" MODIFIED="1567477747076">
<attribute_layout VALUE_WIDTH="274"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_couple_dungeai,set_level"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1092275177" CREATED="1552040959887" MODIFIED="1566530923083">
<attribute_layout VALUE_WIDTH="274"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_couple_dungeai,mark_question_times"/>
</node>
</node>
</node>
<node TEXT="&#x4e8b;&#x4ef6;&#x8282;&#x70b9;" ID="ID_134097323" CREATED="1552967545941" MODIFIED="1553257723685">
<attribute_layout VALUE_WIDTH="101"/>
<attribute NAME="event" VALUE="hook_over"/>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_359198555" CREATED="1553573039284" MODIFIED="1567477714960">
<attribute_layout VALUE_WIDTH="189"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_couple_dungeai,stat_one"/>
</node>
</node>
<node TEXT="&#x4e8b;&#x4ef6;&#x8282;&#x70b9;" ID="ID_1688748523" CREATED="1552967545941" MODIFIED="1553498375199">
<attribute_layout VALUE_WIDTH="101"/>
<attribute NAME="event" VALUE="hook_timeout"/>
<node TEXT="&#x9009;&#x62e9;&#x8282;&#x70b9;" ID="ID_1270256955" CREATED="1566463540768" MODIFIED="1566463596684">
<node TEXT="&#x6761;&#x4ef6;&#x8282;&#x70b9;" ID="ID_1044304606" CREATED="1553573308144" MODIFIED="1557291460131">
<attribute_layout VALUE_WIDTH="202"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_aiwave,is_over"/>
</node>
<node TEXT="&#x5b50;&#x6811;&#x8282;&#x70b9;" ID="ID_769631013" CREATED="1553053834882" MODIFIED="1557720015345">
<attribute_layout VALUE_WIDTH="189"/>
<attribute NAME="tree" VALUE="cfg_dunge_ai,find,200001"/>
</node>
</node>
</node>
<node TEXT="&#x4e8b;&#x4ef6;&#x8282;&#x70b9;" ID="ID_434653797" CREATED="1553568520622" MODIFIED="1563701508710">
<attribute_layout VALUE_WIDTH="100"/>
<attribute NAME="event" VALUE="hook_creep_dead"/>
<node TEXT="&#x9009;&#x62e9;&#x8282;&#x70b9;" ID="ID_1487968746" CREATED="1557912648731" MODIFIED="1557912653007">
<node TEXT="&#x5e8f;&#x5217;&#x8282;&#x70b9;" ID="ID_1657531453" CREATED="1557912682587" MODIFIED="1557912686423">
<node TEXT="&#x6761;&#x4ef6;&#x8282;&#x70b9;" ID="ID_1112630443" CREATED="1553573308144" MODIFIED="1566785804978">
<attribute_layout VALUE_WIDTH="202"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_aicreep,is_over"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1727211631" CREATED="1553569567475" MODIFIED="1566461506222">
<attribute_layout VALUE_WIDTH="215"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_ai,clear"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_1158329287" CREATED="1553569567475" MODIFIED="1566461212509">
<attribute_layout VALUE_WIDTH="215"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_couple_dungeai,send_question"/>
</node>
<node TEXT="&#x5ef6;&#x8fdf;&#x8282;&#x70b9;" ID="ID_374802387" CREATED="1557738431514" MODIFIED="1566540445681">
<attribute_layout VALUE_WIDTH="220"/>
<attribute NAME="tick" VALUE="dunge_couple_dungeai,answer_timeout"/>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_847377185" CREATED="1553569567475" MODIFIED="1566528853382">
<attribute_layout VALUE_WIDTH="215"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_couple_dungeai,auto_answer"/>
</node>
</node>
</node>
<node TEXT="&#x5e8f;&#x5217;&#x8282;&#x70b9;" ID="ID_1527095193" CREATED="1553599340151" MODIFIED="1553599342530">
<node TEXT="&#x6761;&#x4ef6;&#x8282;&#x70b9;" ID="ID_182580856" CREATED="1553573308144" MODIFIED="1557291460131">
<attribute_layout VALUE_WIDTH="202"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_aiwave,is_over"/>
</node>
<node TEXT="&#x52a8;&#x4f5c;&#x8282;&#x70b9;" ID="ID_694270603" CREATED="1553569567475" MODIFIED="1557285002710">
<attribute_layout VALUE_WIDTH="127"/>
<attribute NAME="mod" VALUE="dunge_ai"/>
<attribute NAME="func" VALUE="run"/>
<attribute NAME="args" VALUE="dunge_aiwave,summon"/>
</node>
</node>
</node>
</node>
<node TEXT="&#x4e8b;&#x4ef6;&#x8282;&#x70b9;" ID="ID_932950762" CREATED="1553568520622" MODIFIED="1566532240323">
<attribute_layout VALUE_WIDTH="138"/>
<attribute NAME="event" VALUE="hook_answer_all"/>
<node TEXT="&#x5b50;&#x6811;&#x8282;&#x70b9;" ID="ID_1122142447" CREATED="1553053834882" MODIFIED="1566463388069">
<attribute_layout VALUE_WIDTH="189"/>
<attribute NAME="tree" VALUE="cfg_dunge_ai,find,200002"/>
</node>
</node>
</node>
</node>
</map>
