<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:param name="query" select="doc('input:request')/request/parameters/parameter[name = 'query']/value"/>

	<xsl:template match="/">
		<select class="form-control add-filter-object">
			<option value="">Select...</option>
			<xsl:apply-templates select="descendant::res:result"/>
		</select>
	</xsl:template>

	<xsl:template match="res:result">
		<xsl:variable name="curie">
			<xsl:choose>
				<xsl:when test="starts-with(res:binding[@name = 'facet']/res:uri, 'http://nomisma.org/id/')">
					<xsl:value-of select="replace(res:binding[@name = 'facet']/res:uri, 'http://nomisma.org/id/', 'nm:')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('&lt;', res:binding[@name = 'facet']/res:uri, '&gt;')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!--<xsl:variable name="regex" select="concat('([a-z]+:[a-zA-Z]+)\s', $curie)"/>-->

		<option value="{$curie}">
			<xsl:if test="substring-after($query, ' ') = $curie">
				<xsl:attribute name="selected">selected</xsl:attribute>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="res:binding[@name='label']">
					<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="res:binding[@name = 'en_label']/res:literal"/>
				</xsl:otherwise>
			</xsl:choose>			
		</option>
	</xsl:template>

</xsl:stylesheet>
