<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">	
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:param name="department"/>
	<xsl:output encoding="UTF-8" method="xhtml"/>

	<xsl:template match="/">
		<xsl:apply-templates select="//doc"/>
	</xsl:template>

	<xsl:template match="doc">		
		<div>
			<a href="id/{str[@name='recordId']}">
				<img src="{str[@name='thumbnail_obv']}"/>
			</a>
			<br/>
			<a href="id/{str[@name='recordId']}">
				<xsl:value-of select="str[@name='title_display']"/>
			</a>
			<xsl:if test="string(str[@name='imagesponsor'])">
				<br/>
				<xsl:text>Image Sponsor: </xsl:text>
				<xsl:value-of select="str[@name='imagesponsor']"/>
			</xsl:if>
		</div>
	</xsl:template>

</xsl:stylesheet>
