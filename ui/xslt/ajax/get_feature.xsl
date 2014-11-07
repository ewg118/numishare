<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:template match="/">
		<div id="feature">
			<xsl:apply-templates select="descendant::doc"/>
		</div>
	</xsl:template>
	<xsl:template match="doc">
		<h3>Featured Object</h3>
		<div style="text-center">
			<a href="../collection/{str[@name='recordId']}">
				<img src="{str[@name='thumbnail_obv']}"/>
			</a>
			<br/>
			<a href="../collection/{str[@name='recordId']}">
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
