<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	
	<xsl:template match="/">
		<div id="feature">
			<xsl:apply-templates select="descendant::doc"/>
		</div>
	</xsl:template>
	<xsl:template match="doc">
		<h3>Featured Object</h3>
		<div>
			<a href="id/{str[@name='recordId']}{if(string($lang)) then concat('?lang=', $lang) else ''}">
				<img src="{str[@name='thumbnail_obv']}"/>
			</a>
			<br/>
			<a href="id/{str[@name='recordId']}{if(string($lang)) then concat('?lang=', $lang) else ''}">
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
