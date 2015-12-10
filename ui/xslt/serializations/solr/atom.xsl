<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:gx="http://www.google.com/kml/ext/2.2"
	xmlns:georss="http://www.georss.org/georss" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:relevance="http://a9.com/-/opensearch/extensions/relevance/1.0/" version="2.0"
	exclude-result-prefixes="#all">
	<xsl:include href="atom-templates.xsl"/>
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<!-- url params -->
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="sort"
		select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
	<xsl:param name="start"
		select="doc('input:request')/request/parameters/parameter[name='start']/value"/>
	<xsl:param name="format"
		select="doc('input:request')/request/parameters/parameter[name='format']/value"/>

	<!-- config variables -->
	<xsl:param name="url" select="/content/config/url"/>

	<!-- other variables -->
	<xsl:variable name="rows" as="xs:integer">100</xsl:variable>
	<xsl:variable name="start_var" as="xs:integer">
		<xsl:choose>
			<xsl:when test="number($start)">
				<xsl:value-of select="$start"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:call-template name="atom">
			<xsl:with-param name="section">feed</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
</xsl:stylesheet>
