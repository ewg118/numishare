<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0">
	<xsl:output method="text"/>
	
	<xsl:template match="/">
		<xsl:variable name="string-value" select="string(avg(//lst[@name='ao_weight']/int/@name))"/>
		
		<xsl:value-of select="concat(substring-before($string-value, '.'), '.', substring(substring-after($string-value, '.'), 1, 3))"/>
	</xsl:template>
	
</xsl:stylesheet>
