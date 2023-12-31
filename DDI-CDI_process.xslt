<?xml version="1.0" encoding="UTF-8"?>
<!--

Author: joachim.wackerow@posteo.de

This stylesheet follows the structure of a DDI-CDI sequence. It implements a document-driven approach.
Additionally it resolves cross-references (cdi:dataIdentifier) with the xsl:key function.

It has templates with modes for creating text in reStructuredText (rst) and diagrams in Graphviz (dot).
The names of templates or templates modes follow the pattern: [<target language>_]<purpose>[_file].
The appendix 'file' indicates that a separate file is generated by this template

Values for the dot language are defined as XSLT variables in a separate configuration file.
Also values for parameters which could be defined in CSS.
But is seems that it is better to define everything in dot because some size computations might be done on the basis of these values.
The values for dot parameters are defined separately for graph, node, and edge. It is possible to define values on the general level
for each of these types and on the individual level.

The styles of links are done in CSS because this limited in dot.

Templates

templates following document structure generating rst

template match="/">
template match="cdi:DDICDIModels" mode="rst">
template match="cdi:Sequence" mode="rst_MainFile">
template match="cdi:ProcessingAgent" mode="rst_ProcessingAgent_MainFile">
template match="cdi:Activity" mode="rst_Activity_File">
template match="cdi:Activity_hasSubActivity_Activity-Target" mode="rst">
template match="cdi:Activity_has_Step-Target" mode="rst">
template match="cdi:Step" mode="rst_Step_File">
template match="cdi:Step_receives_Parameter-Target | cdi:Step_produces_Parameter-Target" mode="rst">
template match="cdi:Parameter" mode="rst">
template match="cdi:entityBound">
template match="cdi:Sequence" mode="rst_OverviewDiagram_MainFile">

templates generating dot

template name="dot_OverviewDiagram_File">
template match="cdi:Activity" mode="dot_OverviewDiagram">
template match="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target | cdi:Step_hasSubStep_Step-Target" mode="dot_OverviewDiagram">
template name="dot_Subactivities_File">
template match="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target | cdi:Step_hasSubStep_Step-Target" mode="dot_ActivityTitle">
template match="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target | cdi:Step_hasSubStep_Step-Target" mode="dot_ActivityDescription">
template match="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target | cdi:Step_hasSubStep_Step-Target" mode="dot_ActivityDescriptionEdge">
template match="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target | cdi:Step_hasSubStep_Step-Target" mode="dot_ActivityNodeEdge">
template name="dot_Activity_File">
template match="cdi:entityUsed" mode="dot">
template match="cdi:entityProduced" mode="dot">
template name="dot_Step_File">
template match="cdi:Parameter" mode="dot">
template name="dot_StepLegend_File">

helper templates

template match="cdi:ddiReference" mode="rst_TOCEntry">
template name="Title">
template name="Description">
template name="FormatText">
template name="js_ItemDescriptionList_File">

functions

function name="mf:dot_EscapeQuote" as="xs:string">
function name="mf:FileIdentifier" as="xs:string">
function name="mf:DotIdentifier" as="xs:string">

-->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cdi="http://ddialliance.org/Specification/DDI-CDI/1.0/XMLSchema/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mf="http://example.com/mf" xmlns:ddi="ddi:instance:3_3" xmlns:l="ddi:logicalproduct:3_3" xmlns:r="ddi:reusable:3_3" expand-text="true">
	<!--
-->
	<xsl:output method="text"/>
	<!--
	configuration -->
	<xsl:include href="DDI-CDI_process_configuration.xslt"/>
	<!--
	parameter -->
	<xsl:param name="PortalPrefix" select=" 'https://colectica-ess-processing.nsd.no/item/int.esseric/' "/>
	<xsl:param name="DDI33_Study"/>
	<!--
	computed variables -->
	<xsl:variable name="DDI33_Study_Node" select="document($DDI33_Study)" as="document-node()"/>
	<!--
	Key for all elements with IDs -->
	<xsl:key name="id" match="//cdi:*" use="cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier"/>
	<!--
	Key for all variables in supporting DDI 3.3 xml file -->
	<xsl:key name="Variable" match="//l:Variable" use="r:ID"/>
	<!--
	Key for steps which use a specific parameter for input -->
	<xsl:key name="StepWithSpecificInputParameter" match="cdi:Step" use="cdi:Step_receives_Parameter-Target/cdi:ddiReference/cdi:dataIdentifier"/>
	<!--
	Key for steps which use a specific parameter for ouput -->
	<xsl:key name="StepWithSpecificOutputParameter" match="cdi:Step" use="cdi:Step_produces_Parameter-Target/cdi:ddiReference/cdi:dataIdentifier"/>
	<!--
	Entry point -->
	<xsl:template match="/">
		<xsl:apply-templates select="cdi:DDICDIModels" mode="rst"/>
		<xsl:call-template name="js_ItemDescriptionList_File"/>
	</xsl:template>
	<!--
	-->
	<xsl:template match="cdi:DDICDIModels" mode="rst">
		<xsl:apply-templates select="cdi:Sequence" mode="rst_MainFile"/>
		<xsl:call-template name="dot_StepLegend_File"/>
	</xsl:template>
	<!--
	-->
	<xsl:template match="cdi:Sequence" mode="rst_MainFile">
		<xsl:text>.. _{mf:FileIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )}:

</xsl:text>
		<!-- workaround: sequence has no name -->
		<xsl:call-template name="Title">
			<xsl:with-param name="Description" select="cdi:description"/>
		</xsl:call-template>
		<xsl:text>
=======================================================================================================================

.. rst-class:: sequence-title

   **Main Process Sequence**

**Description:** </xsl:text>
		<xsl:call-template name="Description">
			<xsl:with-param name="Description" select="cdi:description"/>
		</xsl:call-template>
		<xsl:text>

</xsl:text>
		<xsl:apply-templates select="key('id', cdi:ControlLogic_informs_ProcessingAgent-Target/cdi:ddiReference/cdi:dataIdentifier)" mode="rst_ProcessingAgent_MainFile"/>
		<xsl:apply-templates select="." mode="rst_OverviewDiagram_MainFile"/>
		<xsl:text>
.. toctree::
   :hidden:
   
</xsl:text>
		<xsl:apply-templates select="cdi:ControlLogic_invokes_Activity-Target/cdi:ddiReference" mode="rst_TOCEntry"/>
		<xsl:apply-templates select="key('id', cdi:ControlLogic_invokes_Activity-Target/cdi:ddiReference/cdi:dataIdentifier)" mode="rst_Activity_File"/>
		<xsl:text>   about.rst
</xsl:text>
		<!-- end of template match="cdi:Sequence" mode="rst_MainFile" -->
	</xsl:template>
	<!--
-->
	<xsl:template match="cdi:ProcessingAgent" mode="rst_ProcessingAgent_MainFile">
		<xsl:text>|  Processing Agent: {normalize-space( cdi:catalogDetails/cdi:title/cdi:languageSpecificString/cdi:content )}
|  Purpose: {normalize-space( cdi:purpose/cdi:languageSpecificString/cdi:content )}
|  Production Environment: {normalize-space( cdi:ProcessingAgent_operatesOn_ProductionEnvironment-Target/cdi:description )}</xsl:text>
	</xsl:template>
	<!--
	-->
	<xsl:template match="cdi:Activity" mode="rst_Activity_File">
		<xsl:variable name="FileIdentifier" select="mf:FileIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
		<xsl:result-document href="{$FileIdentifier}.rst">
			<xsl:text>.. _{$FileIdentifier}:

{cdi:name/cdi:name}
=======================================================================================================================

.. rst-class:: activity-title

   **Process Activity**

**Description:** {cdi:description}
</xsl:text>
			<xsl:if test="count(cdi:entityUsed)>0 or count(cdi:entityProduced)>0">
				<xsl:text>
-----

**Diagram of the Process Activity**

.. graphviz:: {$FileIdentifier}.dot
   :align: center
   :class: diagram activity-diagram
</xsl:text>
			</xsl:if>
			<xsl:if test="cdi:Activity_hasSubActivity_Activity-Target or cdi:Activity_has_Step-Target">
				<xsl:text>

|

-----

**Diagram of the Process Sub-Activities (in sequential order)**

.. note::
   *Click on a sub-activity to go to the corresponding page.*

|

.. graphviz:: subactivitiesof_{$FileIdentifier}.dot
   :align: center
   :class: diagram subactivities-diagram

.. toctree::
   :hidden:
   
</xsl:text>
				<xsl:apply-templates select="cdi:Activity_hasSubActivity_Activity-Target/cdi:ddiReference | cdi:Activity_has_Step-Target/cdi:ddiReference" mode="rst_TOCEntry"/>
				<xsl:apply-templates select="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target" mode="rst"/>
			</xsl:if>
		</xsl:result-document>
		<xsl:result-document href="{$FileIdentifier}.dot">
			<xsl:call-template name="dot_Activity_File">
				<xsl:with-param name="Activity" select="mf:DotIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
			</xsl:call-template>
		</xsl:result-document>
		<xsl:result-document href="subactivitiesof_{$FileIdentifier}.dot">
			<xsl:call-template name="dot_Subactivities_File"/>
		</xsl:result-document>
		<!-- end of template match="cdi:Activity" mode="rst_Activity_File" -->
	</xsl:template>
	<!--
	-->
	<xsl:template match="cdi:Activity_hasSubActivity_Activity-Target" mode="rst">
		<xsl:apply-templates select="key('id', cdi:ddiReference/cdi:dataIdentifier)" mode="rst_Activity_File"/>
	</xsl:template>
	<!--
	-->
	<xsl:template match="cdi:Activity_has_Step-Target" mode="rst">
		<xsl:apply-templates select="key('id', cdi:ddiReference/cdi:dataIdentifier)" mode="rst_Step_File"/>
	</xsl:template>
	<!--
	-->
	<xsl:template match="cdi:Step" mode="rst_Step_File">
		<xsl:variable name="FileIdentifier" select="mf:FileIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
		<xsl:result-document href="{$FileIdentifier}.rst">
			<xsl:text>.. _</xsl:text>
			<xsl:value-of select="$FileIdentifier"/>
			<xsl:text>:

</xsl:text>
			<xsl:value-of select="cdi:name/cdi:name"/>
			<xsl:text>
=======================================================================================================================

.. rst-class:: step-title

   **Process Step**

**Description** </xsl:text>
			<xsl:value-of select="cdi:description"/>
			<xsl:text>

.. container:: target-blank

   This step uses a `script &lt;{cdi:script/cdi:commandFile/cdi:uri}&gt;`_ written in {cdi:scriptingLanguage/cdi:entryValue}.</xsl:text>
			<xsl:if test="cdi:Step_receives_Parameter-Target or cdi:Step_produces_Parameter-Target">
				<xsl:text>

-----

**Diagram of the Process Step**

.. graphviz:: {$FileIdentifier}.dot
   :align: center
   :class: diagram step-diagram

|

.. hint::
   *Move the mouse cursor over a parameter to see more information. Click on a parameter or a related step to go to the corresponding page.*

   | **Legend:**
   
   .. graphviz:: step-legend.dot
      :class: diagram step-legend
</xsl:text>
			</xsl:if>
		</xsl:result-document>
		<xsl:call-template name="dot_Step_File"/>
		<!-- end of template match="cdi:Step" mode="rst_Step_File" -->
	</xsl:template>
	<!--
-->
	<xsl:template match="cdi:Step_receives_Parameter-Target | cdi:Step_produces_Parameter-Target" mode="rst">
		<xsl:apply-templates select="key('id', cdi:ddiReference/cdi:dataIdentifier)" mode="rst"/>
	</xsl:template>
	<!--
-->
	<xsl:template match="cdi:Parameter" mode="rst">
		<xsl:text> - Parameter "</xsl:text>
		<xsl:value-of select="cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier"/>
		<xsl:text>", bound to </xsl:text>
		<xsl:apply-templates select="cdi:entityBound"/>
		<xsl:text>.
</xsl:text>
	</xsl:template>
	<!--
-->
	<xsl:template match="cdi:entityBound">
		<xsl:value-of select="cdi:uri"/>
		<xsl:text>, </xsl:text>
	</xsl:template>
	<!--
-->
	<xsl:template match="cdi:Sequence" mode="rst_OverviewDiagram_MainFile">
		<xsl:text>

-----

**Overview Diagram of the Process Activities (in sequential order)**

.. note::
   *Move the mouse cursor over an activity to see more information. Click on an activity to go to the corresponding page.*

.. graphviz:: overview_{mf:FileIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )}.dot
   :align: center
   :class: diagram overview-diagram
</xsl:text>
		<xsl:call-template name="dot_OverviewDiagram_File"/>
	</xsl:template>
	<!--
	dot templates
-->
	<xsl:template name="dot_OverviewDiagram_File">
		<xsl:variable name="FileIdentifier" select="mf:FileIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
		<xsl:result-document href="overview_{$FileIdentifier}.dot">
			<xsl:text>digraph Diagram {{
	graph [
		stylesheet="{$CSSFilename}"
		fontnames = "svg" # "... rock solid standards compliant SVG", see: https://graphviz.org/faq/font/#what-about-svg-fonts
		rankdir="LR"
		nodesep="0.7"
		ranksep="2"
		tooltip=" "
	];
	node [
		shape="{$DotActivityShape}"
		style="{$DotActivityStyle}"
		width="7"
		height="0.7"
		fontcolor="{$DotActivityFontColor}"
		fillcolor="{$DotActivityFillColor}"
		fontname="{$DotFontName}"
		fontsize="20pt"
	];
</xsl:text>
			<xsl:apply-templates select="key('id', cdi:ControlLogic_invokes_Activity-Target/cdi:ddiReference/cdi:dataIdentifier)" mode="dot_OverviewDiagram"/>
			<xsl:text>
}}
</xsl:text>
		</xsl:result-document>
	</xsl:template>
	<!--
	-->
	<xsl:template match="cdi:Activity" mode="dot_OverviewDiagram">
		<xsl:param name="ParentIdentifier" select=" 'none' "/>
		<xsl:text>
	</xsl:text>
		<xsl:variable name="DotIdentifier" select="mf:DotIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
		<xsl:variable name="FileIdentifier" select="mf:FileIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
		<xsl:text>{$DotIdentifier} [
		label="{cdi:name/cdi:name}"
		URL="../{$FileIdentifier}.html"
		target="_parent"
		tooltip="Process activity:\n{mf:dot_EscapeQuote( normalize-space( cdi:description ) )}"
	];
</xsl:text>
		<xsl:if test="$ParentIdentifier != 'none' ">
			<xsl:text>	{$ParentIdentifier} -> {$DotIdentifier};
</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="cdi:Activity_hasSubActivity_Activity-Target" mode="dot_OverviewDiagram">
			<xsl:with-param name="ParentIdentifier" select="$DotIdentifier"/>
		</xsl:apply-templates>
	</xsl:template>
	<!--
	-->
	<xsl:template match="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target | cdi:Step_hasSubStep_Step-Target" mode="dot_OverviewDiagram">
		<xsl:param name="ParentIdentifier"/>
		<xsl:apply-templates select="key('id', cdi:ddiReference/cdi:dataIdentifier)" mode="dot_OverviewDiagram">
			<xsl:with-param name="ParentIdentifier" select="$ParentIdentifier"/>
		</xsl:apply-templates>
	</xsl:template>
	<!--
-->
	<xsl:template name="dot_Subactivities_File">
		<xsl:text>digraph Diagram {{
	graph [
		stylesheet="{$CSSFilename}"
		fontnames = "svg" # "... rock solid standards compliant SVG", see: https://graphviz.org/faq/font/#what-about-svg-fonts
		rankdir="LR"
		tooltip=" "
	];
	node [
		fontname="{$DotFontName}"
	];
	subgraph {{
		rank="same";
</xsl:text>
		<!-- title of SubActivity, Step, SubStep -->
		<xsl:apply-templates select="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target | cdi:Step_hasSubStep_Step-Target" mode="dot_ActivityTitle"/>
		<xsl:text>	}}
	subgraph {{
		rank="same";
</xsl:text>
		<!-- description of SubActivity, Step, SubStep -->
		<xsl:apply-templates select="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target | cdi:Step_hasSubStep_Step-Target" mode="dot_ActivityDescription"/>
		<xsl:text>	}}
</xsl:text>
		<!-- description edge of SubActivity, Step, SubStep -->
		<xsl:apply-templates select="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target | cdi:Step_hasSubStep_Step-Target" mode="dot_ActivityDescriptionEdge"/>
		<!-- node edge of SubActivity, Step, SubStep -->
		<xsl:apply-templates select="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target | cdi:Step_hasSubStep_Step-Target" mode="dot_ActivityNodeEdge"/>
		<xsl:text>}}
</xsl:text>
	</xsl:template>
	<!--
	activities list - node with title -->
	<xsl:template match="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target | cdi:Step_hasSubStep_Step-Target" mode="dot_ActivityTitle">
		<xsl:for-each select="key('id', cdi:ddiReference/cdi:dataIdentifier)">
			<xsl:variable name="DotIdentifier" select="mf:DotIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
			<xsl:variable name="FileIdentifier" select="mf:FileIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
			<xsl:variable name="Name">
				<xsl:call-template name="FormatText">
					<xsl:with-param name="String" select="cdi:name/cdi:name"/>
					<xsl:with-param name="Length" select=" 28 "/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:text>		{$DotIdentifier} [
			label="{$Name}"
			shape="{$DotActivityShape}"
			style="{$DotActivityStyle}"
			width="{$DotActivityWidth}"
		    fontcolor="{$DotActivityFontColor}"
		    fillcolor="{$DotActivityFillColor}"
			URL="../{$FileIdentifier}.html"
			target="_parent"
		    tooltip=" \nGo to process activity"
		];
</xsl:text>
		</xsl:for-each>
	</xsl:template>
	<!--
	activities list - node with description -->
	<xsl:template match="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target | cdi:Step_hasSubStep_Step-Target" mode="dot_ActivityDescription">
		<xsl:for-each select="key('id', cdi:ddiReference/cdi:dataIdentifier)">
			<xsl:variable name="DotIdentifier" select="mf:DotIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
			<xsl:variable name="Description">
				<xsl:call-template name="FormatText">
					<xsl:with-param name="String" select="replace( normalize-space( cdi:description ), '&quot;', '\\&quot;')"/>
					<xsl:with-param name="Length" select=" 76 "/>
					<!-- left alignment -->
					<xsl:with-param name="Newline" select=" '\l' "/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:text>		{$DotIdentifier}_Description [
			label="{$Description}"
			tooltip=" \nDescription of activity"
			shape="note"
		    width="5"
			height="0.1"
			color="grey"
			fontsize="10pt"
		];
</xsl:text>
		</xsl:for-each>
	</xsl:template>
	<!--
	activities list - title to description edge -->
	<xsl:template match="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target | cdi:Step_hasSubStep_Step-Target" mode="dot_ActivityDescriptionEdge">
		<xsl:for-each select="key('id', cdi:ddiReference/cdi:dataIdentifier)">
			<xsl:variable name="DotIdentifier" select="mf:DotIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
			<xsl:text>	{$DotIdentifier} -> {$DotIdentifier}_Description [
		style="dotted"
		arrowhead="none"
		color="grey"
	];
</xsl:text>
		</xsl:for-each>
	</xsl:template>
	<!--
	activities list - node to node edge -->
	<xsl:template match="cdi:Activity_hasSubActivity_Activity-Target | cdi:Activity_has_Step-Target | cdi:Step_hasSubStep_Step-Target" mode="dot_ActivityNodeEdge">
		<xsl:variable name="Position" select="position()"/>
		<xsl:variable name="PrecedingSiblingDotIdentifier" select="mf:DotIdentifier( key( 'id', preceding-sibling::*[1][name()=name()]/cdi:ddiReference/cdi:dataIdentifier )/cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
		<xsl:variable name="DotIdentifier" select="mf:DotIdentifier( key('id', cdi:ddiReference/cdi:dataIdentifier)/cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
		<xsl:if test="$Position > 1">
			<xsl:text>	{$PrecedingSiblingDotIdentifier} -> {$DotIdentifier}
</xsl:text>
		</xsl:if>
	</xsl:template>
	<!--
	activity diagram -->
	<xsl:template name="dot_Activity_File">
		<xsl:param name="Activity"/>
		<xsl:text>digraph Diagram {{
	graph [
		stylesheet="{$CSSFilename}"
		fontnames = "svg" # "... rock solid standards compliant SVG", see: https://graphviz.org/faq/font/#what-about-svg-fonts
		rankdir="LR"
		nodesep="0.15"
		tooltip=" "
	];
	node [
		fontname="{$DotFontName}"
	];
	{$Activity} [
		shape="{$DotActivityShape}"
		style="{$DotActivityStyle}"
		width="{$DotActivityWidth}"
		height="0.8"
		fontcolor="{$DotActivityFontColor}"
		fillcolor="{$DotActivityFillColor}"
		fontsize="{$DotActivityFontSize}"
		label="{cdi:name/cdi:name}\n(current activity)"
		tooltip=" "
	];
</xsl:text>
		<xsl:apply-templates select="cdi:entityUsed" mode="dot">
			<xsl:with-param name="Activity" select="$Activity"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="cdi:entityProduced" mode="dot">
			<xsl:with-param name="Activity" select="$Activity"/>
		</xsl:apply-templates>
		<xsl:text>}}
</xsl:text>
	</xsl:template>
	<!--
-->
	<xsl:template match="cdi:entityUsed" mode="dot">
		<xsl:param name="Activity"/>
		<xsl:variable name="Entity" select=" concat('EntityUsed_', position() )"/>
		<xsl:variable name="Description">
			<xsl:call-template name="FormatText">
				<xsl:with-param name="Length" select=" 29 "/>
				<xsl:with-param name="Newline" select=" '\n' "/>
				<xsl:with-param name="String" select="cdi:description"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:text>	{$Entity} [
		shape="{$DotParameterShape}"
		style="{$DotParameterStyle}"
		width="{$DotParameterWidth}"
		height="0.1"
		fontcolor="{$DotLinkColor}"
		fontsize="{$DotParameterFontSize}"
		URL="{cdi:uri}"
		target="_blank"
		label="{$Description}"
		tooltip="Entity used for current activity"
		fillcolor="{$DotInputParameterFillColor}"
	];
	{$Entity}:e -> {$Activity}:w [
		minlen="{$DotEdgeMinLen}"
	];
</xsl:text>
	</xsl:template>
	<!--
-->
	<xsl:template match="cdi:entityProduced" mode="dot">
		<xsl:param name="Activity"/>
		<xsl:variable name="Entity" select=" concat('EntityProduced_', position() )"/>
		<xsl:variable name="Description">
			<xsl:call-template name="FormatText">
				<xsl:with-param name="Length" select=" 29 "/>
				<xsl:with-param name="Newline" select=" '\n' "/>
				<xsl:with-param name="String" select="cdi:description"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:text>	{$Entity} [
		shape="{$DotParameterShape}"
		style="{$DotParameterStyle}"
		width="{$DotParameterWidth}"
		height="0.1"
		fontcolor="{$DotLinkColor}"
		fontsize="{$DotParameterFontSize}"
		URL="{cdi:uri}"
		target="_blank"
		label="{$Description}"
		tooltip="Entity produced by current activity"
		fillcolor="{$DotOutputParameterFillColor}"
	];
	{$Activity}:e -> {$Entity}:w [
		minlen="{$DotEdgeMinLen}"
	];
</xsl:text>
	</xsl:template>
	<!--
	step diagram -->
	<xsl:template name="dot_Step_File">
		<xsl:variable name="FileIdentifier" select="mf:FileIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
		<xsl:result-document href="{$FileIdentifier}.dot">
			<xsl:text>digraph Diagram {{
	graph [
		stylesheet="{$CSSFilename}"
		fontnames = "svg" # "... rock solid standards compliant SVG", see: https://graphviz.org/faq/font/#what-about-svg-fonts
		rankdir="LR"
		nodesep="0.15"
		tooltip=" "
	];
	node [
		fontname="{$DotFontName}"
	];
	Step [
		shape="{$DotActivityShape}"
		style="{$DotActivityStyle}"
		width="{$DotActivityWidth}"
		height="0.8"
		fontcolor="{$DotActivityFontColor}"
		fillcolor="{$DotActivityFillColor}"
		fontsize="{$DotActivityFontSize}"
		label="{cdi:name/cdi:name}\n(current process step)"
		tooltip=" "
	];
	# input parameter
</xsl:text>
			<xsl:apply-templates select="key('id', cdi:Step_receives_Parameter-Target/cdi:ddiReference/cdi:dataIdentifier)" mode="dot">
				<xsl:with-param name="Type" select=" 'in' "/>
			</xsl:apply-templates>
			<xsl:text>    # output parameter
</xsl:text>
			<xsl:apply-templates select="key('id', cdi:Step_produces_Parameter-Target/cdi:ddiReference/cdi:dataIdentifier)" mode="dot">
				<xsl:with-param name="Type" select=" 'out' "/>
			</xsl:apply-templates>
			<xsl:text>}}
</xsl:text>
		</xsl:result-document>
	</xsl:template>
	<!--
-->
	<xsl:template match="cdi:Parameter" mode="dot">
		<xsl:param name="Type"/>
		<xsl:variable name="Parameter" select="mf:DotIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
		<xsl:variable name="UUID" select="substring-after(cdi:entityBound/cdi:uri, $PortalPrefix)"/>
		<!-- see: https://www.w3.org/TR/xslt20/#d5e22881 -->
		<xsl:variable name="VariableLabel" select="$DDI33_Study_Node/key( 'Variable', $UUID )/r:Label/r:Content[@xml:lang='en']"/>
		<xsl:variable name="VariableLabel2">
			<xsl:if test="string-length($VariableLabel) > 0">
				<xsl:call-template name="FormatText">
					<xsl:with-param name="Length" select=" 29 "/>
					<xsl:with-param name="Newline" select=" '&lt;br/&gt;' "/>
					<xsl:with-param name="String" select="$VariableLabel"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
		<xsl:text>	{$Parameter} [
		shape="{$DotParameterShape}"
		style="{$DotParameterStyle}"
		width="{$DotParameterWidth}"
		height="0.1"
		fontcolor="{$DotLinkColor}"
		fontsize="{$DotParameterFontSize}"
		URL="{cdi:entityBound/cdi:uri}"
		target="_blank"
</xsl:text>
		<xsl:choose>
			<xsl:when test=" $Type = 'in' ">
				<xsl:text>		label=&lt;&lt;i&gt;{cdi:name/cdi:name}:&lt;/i&gt;&lt;br/&gt;{$VariableLabel2}&gt;
		tooltip="Input parameter for current process step"
		fillcolor="{$DotInputParameterFillColor}"
	];
	{$Parameter}:e -> Step:w [
		minlen="{$DotEdgeMinLen}"
	];
	</xsl:text>
				<xsl:for-each select="key('StepWithSpecificOutputParameter', cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier)">
					<xsl:variable name="PreviousStepDotIdentifier" select="mf:DotIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
					<xsl:variable name="PreviousStepFileIdentifier" select="mf:FileIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
					<xsl:variable name="Tooltip" select="replace( normalize-space( key('id', cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier)/cdi:description), '&quot;', '\\&quot;')"/>
					<xsl:text>	# previous step
	</xsl:text>
					<xsl:value-of select="$PreviousStepDotIdentifier"/>
					<xsl:text> [
		shape="{$DotActivityShape}"
		style="{$DotActivityStyle}"
	    width="{$DotSecondaryActivityWidth}"
	    height="0.075"
		fontcolor="{$DotActivityFontColor}"
		fillcolor="{$DotActivityFillColor}"
		fontsize="{$DotSecondaryStepFontSize}"
		label="{cdi:name/cdi:name}"
		URL="../{$PreviousStepFileIdentifier}.html"
		target="_parent"
		tooltip="Previous process step:\n{$Tooltip}"
	];
	{$PreviousStepDotIdentifier}:e -> {$Parameter}:w [
		minlen="{$DotEdgeMinLen}"
	];

</xsl:text>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test=" $Type = 'out' ">
				<xsl:text>		label=&lt;&lt;i&gt;{cdi:name/cdi:name}:&lt;/i&gt;&lt;br/&gt;{$VariableLabel2}&gt;
		tooltip="Output parameter for current process step"
		fillcolor="{$DotOutputParameterFillColor}"
	];
	Step:e -> {$Parameter}:w [
		minlen="{$DotEdgeMinLen}"
	];
</xsl:text>
				<xsl:for-each select="key('StepWithSpecificInputParameter', cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier)">
					<xsl:variable name="FollowingStepDotIdentifier" select="mf:DotIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
					<xsl:variable name="FollowingStepFileIdentifier" select="mf:FileIdentifier( cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )"/>
					<xsl:variable name="Tooltip" select="replace( normalize-space( key('id', cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier)/cdi:description), '&quot;', '\\&quot;')"/>
					<xsl:text>	# following step
	</xsl:text>
					<xsl:value-of select="$FollowingStepDotIdentifier"/>
					<xsl:text> [
		shape="{$DotActivityShape}"
		style="{$DotActivityStyle}"
	    width="{$DotSecondaryActivityWidth}"
		height="0.075"
		fontcolor="{$DotActivityFontColor}"
		fillcolor="{$DotActivityFillColor}"
		fontsize="{$DotSecondaryStepFontSize}"
		label="{cdi:name/cdi:name}"
		URL="../{$FollowingStepFileIdentifier}.html"
		target="_parent"
		tooltip="Following process step:\n{$Tooltip}"
	];
	{$Parameter}:e -> {$FollowingStepDotIdentifier}:w [
		minlen="{$DotEdgeMinLen}"
	];

</xsl:text>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!--
-->
	<xsl:template name="dot_StepLegend_File">
		<xsl:result-document href="step-legend.dot">
			<xsl:text>digraph Diagram {{
	graph [
		stylesheet="{$CSSFilename}"
		fontnames = "svg" # "... rock solid standards compliant SVG", see: https://graphviz.org/faq/font/#what-about-svg-fonts
		rankdir="LR"
		bgcolor="#eeeeee"
		size="5,10!"
		nodesep=0.15
		tooltip=" "
	];
	node [
		fontname="{$DotFontName}"
	];
	Step [
		width="{$DotActivityWidth}"
		label="Process step"
		tooltip=" "
		shape="rect"
		style="{$DotActivityStyle}"
		fontcolor="{$DotActivityFontColor}"
		fillcolor="{$DotActivityFillColor}"
	];
	# input parameter
	InputParameter [
		shape="rect"
		width="{$DotParameterWidth}"
		height="0.1"
		style="{$DotParameterStyle}"
		label="Input parameter"
		tooltip=" "
		fillcolor="{$DotInputParameterFillColor}"
	];
	InputParameter -> Step [
		label="used by"
	];
	OutputParameter [
		shape="rect"
		width="{$DotParameterWidth}"
		height="0.1"
		style="{$DotParameterStyle}"
		label="Output parameter"
		tooltip=" "
		fillcolor="{$DotOutputParameterFillColor}"
	];
	Step -> OutputParameter [
		label="produces"
	];
}}
</xsl:text>
		</xsl:result-document>
	</xsl:template>
	<!--
	helper templates
-->
	<!--
-->
	<xsl:template match="cdi:ddiReference" mode="rst_TOCEntry">
		<xsl:text>   {mf:FileIdentifier( key( 'id', cdi:dataIdentifier )/cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier )}.rst
</xsl:text>
	</xsl:template>
	<!--
-->
	<xsl:template name="Title">
		<xsl:param name="Description"/>
		<xsl:variable name="SafeDivider" select=" ' ||| ' "/>
		<xsl:variable name="Description2" select="normalize-space( replace( $Description, '&#xA;', $SafeDivider ) )"/>
		<xsl:value-of select="substring-before( $Description2, concat( $SafeDivider, '#' ) )"/>
	</xsl:template>
	<!--
-->
	<xsl:template name="Description">
		<xsl:param name="Description"/>
		<xsl:variable name="SafeDivider" select=" ' ||| ' "/>
		<xsl:variable name="Description2" select="normalize-space( replace( $Description, '&#xA;', $SafeDivider ) )"/>
		<xsl:value-of select="substring-after( $Description2, concat( '#', $SafeDivider ) )"/>
	</xsl:template>
	<!--
	format text at word boundary with given line length and new line character -->
	<xsl:template name="FormatText">
		<xsl:param name="Length" select=" 80 "/>
		<xsl:param name="Newline" select=" '\n' "/>
		<xsl:param name="String"/>
		<xsl:choose>
			<xsl:when test="string-length($String) > $Length ">
				<xsl:variable name="Substring" select="substring($String, 1, $Length)"/>
				<xsl:variable name="LastTokenLength" select="string-length( tokenize( $Substring, ' ' )[last()] )"/>
				<xsl:variable name="LengthAtWordBoundary" select="$Length - $LastTokenLength - 1"/>
				<xsl:value-of select="substring($String, 1, $LengthAtWordBoundary)"/>
				<xsl:value-of select="$Newline"/>
				<xsl:call-template name="FormatText">
					<xsl:with-param name="Length" select="$Length"/>
					<xsl:with-param name="Newline" select="$Newline"/>
					<xsl:with-param name="String" select="substring($String, $LengthAtWordBoundary + 2)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$String"/>
				<xsl:if test=" $Newline = '\l' ">
					<xsl:text>\l</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--
	 Create list of item descriptions for usage as tooltips
	-->
	<xsl:template name="js_ItemDescriptionList_File">
		<xsl:result-document href="../sphinx/_static/description.js">
			<xsl:text>var description = {{
</xsl:text>
			<xsl:for-each select="//cdi:identifier/cdi:ddiIdentifier/cdi:dataIdentifier">
				<xsl:text>	"</xsl:text>
				<xsl:value-of select="mf:FileIdentifier( . )"/>
				<xsl:text>" : "Process </xsl:text>
				<xsl:value-of select="lower-case( local-name(../../..) )"/>
				<xsl:text>:\n</xsl:text>
				<xsl:value-of select="replace( normalize-space( ../../../cdi:description ), '&quot;', '''' )"/>
				<xsl:text>",
</xsl:text>
			</xsl:for-each>
			<xsl:text>}}
</xsl:text>
		</xsl:result-document>
	</xsl:template>
	<!--
	functions
	-->
	<xsl:function name="mf:dot_EscapeQuote" as="xs:string">
		<xsl:param name="String"/>
		<xsl:value-of select="replace( $String, '&quot;', '\\&quot;' )"/>
	</xsl:function>
	<!--
	Create file identifier as compound of item name and identifier
	-->
	<xsl:function name="mf:FileIdentifier" as="xs:string">
		<xsl:param name="Identifier"/>
		<xsl:value-of select="lower-case( concat( local-name( $Identifier/../../.. ) , '_', $Identifier ) )"/>
	</xsl:function>
	<!--
	Create identifier compliant to the DOT language grammar, see: https://graphviz.org/doc/info/lang.html
	"An ID is one of the following: Any string of alphabetic ([a-zA-Z\200-\377]) characters, underscores ('_') or digits([0-9]), not beginning with a digit;"
	-->
	<xsl:function name="mf:DotIdentifier" as="xs:string">
		<xsl:param name="Identifier"/>
		<xsl:value-of select="replace( mf:FileIdentifier( $Identifier ), '[^a-zA-Z0-9]', '_')"/>
	</xsl:function>
	<!-- -->
</xsl:stylesheet>