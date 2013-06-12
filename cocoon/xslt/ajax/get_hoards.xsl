<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<xsl:param name="compare"/>
	<xsl:variable name="tokens" select="tokenize($compare, ',')"/>
	
	<xsl:template match="/">
		<select multiple="multiple" size="10" class="compare-select">
			<xsl:apply-templates select="descendant::doc"/>
		</select>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="id" select="str[@name='nudsid']"/>
		<option value="{$id}" class="compare-option">
			<xsl:for-each select="$tokens[.=$id]">
				<xsl:attribute name="selected">selected</xsl:attribute>
			</xsl:for-each>
			
			<xsl:value-of select="str[@name='title_display']"/>
		</option>
	</xsl:template>
</xsl:stylesheet>
