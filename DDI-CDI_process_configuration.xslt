<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
	configuration
	-->
	<xsl:variable name="CSSFilename" select=" '../_static/custom.css' "/>
	<xsl:variable name="DotFontName" select=" 'sans-serif' "/>
	<xsl:variable name="DotActivityShape" select=" 'rect' "/>
	<xsl:variable name="DotActivityStyle" select=" 'filled, rounded' "/>
	<xsl:variable name="DotActivityWidth" select=" '3' "/>
	<xsl:variable name="DotActivityFontColor" select=" 'white' "/>
	<xsl:variable name="DotActivityFontSize" select=" '13pt' "/>
	<!-- blue -->
	<xsl:variable name="DotActivityFillColor" select=" '#4363d8' "/>
	<xsl:variable name="DotSecondaryStepFontSize" select=" '10pt' "/>
	<xsl:variable name="DotParameterFontSize" select=" '10pt' "/>
	<xsl:variable name="DotParameterShape" select=" 'rect' "/>
	<xsl:variable name="DotParameterWidth" select=" '2' "/>
	<xsl:variable name="DotParameterStyle" select=" 'filled' "/>
	<!-- yellow -->
	<xsl:variable name="DotInputParameterFillColor" select=" '#ffe119' "/>
	<!-- lavender -->
	<xsl:variable name="DotOutputParameterFillColor" select=" '#dcbeff' "/>
	<xsl:variable name="DotLinkColor" select=" 'blue' "/>
</xsl:stylesheet>