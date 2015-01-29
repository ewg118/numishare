<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xmlns="http://earth.google.com/kml/2.0" version="2.0">
	<xsl:param name="field" select="doc('input:request')/request/parameters/parameter[name='field']/value"/>
	<xsl:param name="url" select="/content/config/url"/>
	<xsl:template match="/">
		<xsl:variable name="response">
			<xsl:text> [ </xsl:text>
			<xsl:apply-templates select="descendant::doc"/>
			<xsl:text>]</xsl:text>
		</xsl:variable>
		<xsl:value-of select="normalize-space($response)"/>
	</xsl:template>
	<xsl:template match="doc">
		<xsl:variable name="findspot" select="tokenize(arr[@name='findspot_geo']/str[1], '\|')[1]"/>
		<xsl:variable name="uri" select="tokenize(arr[@name='findspot_geo']/str[1], '\|')[2]"/>
		<xsl:variable name="coordinates" select="tokenize(arr[@name='findspot_geo']/str[1], '\|')[3]"/>
		<xsl:variable name="description">
			<![CDATA[<dl class='dl-horizontal'><dt>ID</dt><dd><a href=']]><xsl:value-of select="concat($url, 'id/', str[@name='recordId'])"/><![CDATA['>]]><xsl:value-of select="str[@name='recordId']"
				/><![CDATA[</a></dd><dt>Closing Date</dt><dd>]]><xsl:value-of select="str[@name='closing_date_display']"/>
			<![CDATA[</dd>]]>
		</xsl:variable> {"point": {"lon": <xsl:value-of select="normalize-space(tokenize($coordinates, ',')[1])"/>, "lat": <xsl:value-of select="normalize-space(tokenize($coordinates, ',')[2])"/>},
		"title": "<xsl:value-of select="str[@name='title_display']"/>", <xsl:if test="number(int[@name='tpq_num'])">"start": "<xsl:value-of select="int[@name='tpq_num']"/>",</xsl:if>
		<xsl:if test="number(int[@name='taq_num'])">"end": "<xsl:value-of select="int[@name='taq_num']"/>",</xsl:if> "options": { "theme": "red"<xsl:if
			test="string($description)">, "description": "<xsl:value-of select="normalize-space($description)"/>"</xsl:if><xsl:if test="$uri">, "href": "<xsl:value-of select="$uri"/>"</xsl:if> } }
			<xsl:if test="not(position()=last())"><xsl:text>,</xsl:text></xsl:if>
	</xsl:template>
</xsl:stylesheet>
