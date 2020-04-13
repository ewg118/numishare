<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../json/json-metamodel.xsl"/>

	<!-- URL parameters -->
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
		<xsl:variable name="model" as="element()*">
			<_array>
				<xsl:apply-templates select="//hoard"/>
			</_array>
		</xsl:variable>
		
		<xsl:apply-templates select="$model"/>
	</xsl:template>
	
	<xsl:template match="hoard">
		<xsl:apply-templates select="item">
			<xsl:with-param name="subset" select="@title"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="item">
		<xsl:param name="subset"/>
		
		<_object>
			<xsl:element name="subset">
				<xsl:value-of select="$subset"/>
			</xsl:element>
			<xsl:element name="{$dist}">
				<xsl:value-of select="@label"/>
			</xsl:element>
			<xsl:if test="@sort">
				<xsl:element name="value">
					<xsl:value-of select="@sort"/>
				</xsl:element>
			</xsl:if>
			<xsl:element name="{if ($type='count') then 'count' else 'percentage'}">
				<xsl:value-of select="@num"/>
			</xsl:element>
		</_object>
	</xsl:template>
</xsl:stylesheet>
