<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:output method="xml"/>
	<xsl:param name="id"/>
	<xsl:param name="field"/>
	
	<xsl:template match="/">
		<xsl:variable name="numFound" select="number(//result[@name='response']/@numFound)"/>
		<xsl:element name="response-{$field}">
			<xsl:choose>
				<xsl:when test="$numFound = 1">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>		
	</xsl:template>

</xsl:stylesheet>
