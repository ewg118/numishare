<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="customQuery" select="doc('input:request')/request/parameters/parameter[name='customQuery']/value"/>
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>
	<xsl:param name="total" select="doc('input:request')/request/parameters/parameter[name='total']/value" as="xs:integer"/>
	
	<xsl:template match="/">
		<xsl:variable name="numFound" select="number(//result[@name='response']/@numFound)"/>
		<xsl:variable name="value">
			<xsl:choose>
				<xsl:when test="$type='count'">
					<xsl:value-of select="$numFound"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="format-number(($numFound div $total) * 100, '##.00')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<query q="{$q}">
			<name count="{$value}">
				<xsl:value-of select="$customQuery"/>
			</name>
		</query>
	</xsl:template>
</xsl:stylesheet>
