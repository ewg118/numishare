<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>

	<!-- distribution params -->
	<xsl:param name="dist" select="doc('input:request')/request/parameters/parameter[name = 'dist']/value"/>
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
		<xsl:text>"group","value",</xsl:text>
		<xsl:text>"</xsl:text>
		<xsl:value-of select="
				if ($type = 'count') then
					'count'
				else
					'percentage'"/>
		<xsl:text>"&#x0A;</xsl:text>
		<xsl:apply-templates select="//hoard"/>
	</xsl:template>

	<xsl:template match="hoard">
		<xsl:apply-templates select="item">
			<xsl:with-param name="subset" select="@title"/>
		</xsl:apply-templates>
		<xsl:if test="not(position() = last())">
			<xsl:text>&#x0A;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="item">
		<xsl:param name="subset"/>

		<xsl:variable name="object" as="element()*">
			<row>
				<xsl:element name="subset">
					<xsl:value-of select="$subset"/>
				</xsl:element>
				<xsl:element name="{$dist}">
					<xsl:value-of select="@label"/>
				</xsl:element>
				<xsl:element name="{if ($type='count') then 'count' else 'percentage'}">
					<xsl:value-of select="@num"/>
				</xsl:element>
			</row>
		</xsl:variable>

		<xsl:for-each select="$object/*">
			<xsl:choose>
				<xsl:when test=". castable as xs:integer or . castable as xs:decimal">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:when test="string-length(.) = 0"/>
				<xsl:when test="contains(., '&#x022;')">
					<xsl:value-of select="concat('&#x022;', replace(., '&#x022;', '&#x022;&#x022;'), '&#x022;')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('&#x022;', ., '&#x022;')"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="not(position() = last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="not(position() = last())">
			<xsl:text>&#x0A;</xsl:text>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
