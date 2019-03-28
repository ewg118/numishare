<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>

	<!-- URL parameters -->
	<!-- distribution params -->
	<xsl:param name="dist" select="doc('input:request')/request/parameters/parameter[name = 'category']/value"/>
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name = 'type']/value"/>
	<!-- query params -->
	<xsl:param name="compare" select="doc('input:request')/request/parameters/parameter[name = 'compare']/value"/>

	<!-- language parameters -->
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[. = 'accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[. = 'accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>

	<xsl:template match="/">
		<xsl:text>[</xsl:text>
		<xsl:apply-templates select="//response[lst[@name='facet_counts']]"/>		
		<xsl:text>]</xsl:text>
	</xsl:template>

	<!-- templates for the getDistribution API: display numeric counts or percentages for distribution queries -->
	<xsl:template match="response[lst[@name='facet_counts']]">
		<xsl:variable name="query" select="lst[@name='responseHeader']/lst[@name='params']/str[@name='compare']"/>

		<xsl:variable name="total" select="sum(descendant::lst[@name=$dist]/int)"/>
		
		<xsl:apply-templates select="descendant::lst[@name=$dist]">
			<xsl:with-param name="query" select="$query"/>
			<xsl:with-param name="total" select="$total"/>
		</xsl:apply-templates>

		<xsl:if test="not(position() = last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="lst">
		<xsl:param name="query"/>
		<xsl:param name="subset"/>
		<xsl:param name="total"/>
		
		<xsl:apply-templates select="int">
			<xsl:with-param name="query" select="$query"/>
			<xsl:with-param name="total" select="$total"/>
		</xsl:apply-templates>	
	</xsl:template>

	<xsl:template match="int">
		<xsl:param name="query"/>
		<xsl:param name="total"/>

		<xsl:variable name="object" as="element()*">
			<row>
				<xsl:element name="subset">
					<xsl:value-of select="numishare:parseSolrQuery($query, $lang)"/>
				</xsl:element>
				<xsl:element name="{$dist}">
					<xsl:value-of select="@name"/>
				</xsl:element>
				<xsl:element name="{if ($type='count') then 'count' else 'percentage'}">
					<xsl:choose>
						<xsl:when test="$type = 'count'">
							<xsl:value-of select="."/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="format-number((number(.) div $total) * 100, '0.0')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</row>
		</xsl:variable>

		<xsl:text>{</xsl:text>
		<xsl:for-each select="$object/*">
			<xsl:value-of select="concat('&#x022;', name(), '&#x022;')"/>
			<xsl:text>:</xsl:text>
			<xsl:choose>
				<xsl:when test=". castable as xs:integer or . castable as xs:decimal">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:when test="contains(., '&#x022;')">
					<xsl:value-of select="concat('&#x022;', replace(., '&#x022;', '\\&#x022;'), '&#x022;')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('&#x022;', ., '&#x022;')"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="not(position() = last())">
				<xsl:text>, </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>}</xsl:text>
		<xsl:if test="not(position() = last())">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
