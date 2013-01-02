<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:output method="xml" omit-xml-declaration="yes"/>
	<xsl:param name="q"/>

	<xsl:template match="/">
		<xsl:if test="//result[@name='response']/@numFound &gt; 0">
			<input type="checkbox" checked="checked" value="{substring-before($q, &quot; AND &quot;)}">
				<xsl:value-of select="concat(substring-before($q, '_facet'), ': ', substring-before(substring-after($q, '&#x022;'), '&#x022;'))"/>
			</input>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
