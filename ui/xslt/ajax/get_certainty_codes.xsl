<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<xsl:param name="exclude" select="doc('input:request')/request/parameters/parameter[name='exclude']/value"/>
	<xsl:variable name="tokens" select="tokenize($exclude, ',')"/>
	
	<xsl:template match="/">
		<select multiple="multiple" size="10" class="certainty-select form-control" id="get_certainty_codes">
			<xsl:apply-templates select="descendant::code">
				<xsl:sort/>
			</xsl:apply-templates>
		</select>
	</xsl:template>
	
	<xsl:template match="code">
		<xsl:variable name="code" select="."/>
		<option value="{$code}" class="exclude-option">
			<xsl:if test="boolean(index-of($tokens, $code)) or ($code != '1' and $code != '5' and $code !='6')">
				<xsl:attribute name="selected">selected</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="$code"/>
		</option>
	</xsl:template>
	
</xsl:stylesheet>