<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:nuds="http://nomisma.org/nuds" exclude-result-prefixes="#all" version="2.0">

	<xsl:variable name="uri_space" select="/content/config/uri_space"/>

	<xsl:template match="/content">
		<xsl:apply-templates select="nuds:nuds"/>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<html>
			<head>
				<meta charset="utf-8"/>
				<title>
					<xsl:value-of select="descendant::nuds:title[@xml:lang = 'en']"/>
				</title>
			</head>
			<body style="margin: 0px; font-family: Arial; sans-serif">
				<div style="height: 160px; width: 320px; overflow: hidden; font-size: 0.7em">
					<div>
						<a href="{concat($uri_space, nuds:control/nuds:recordId)}" target="_blank" style="text-decoration: none;">
							<xsl:value-of select="descendant::nuds:title[@xml:lang = 'en']"/>
						</a>
						<xsl:text> </xsl:text>
						<span style="color: #505050;">(<xsl:value-of select="nuds:control/nuds:recordId"/>)</span>
						<!-- display basic typological data -->
						<xsl:apply-templates select="nuds:descMeta/nuds:typeDesc"/>
					</div>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="nuds:typeDesc">
		<div>
			<xsl:if test="nuds:date or nuds:dateRange">
				<strong>Date: </strong>
				<xsl:apply-templates select="nuds:date|nuds:dateRange"/>
				<br/>
			</xsl:if>
			<xsl:if test="nuds:denomination">
				<strong>Denomination: </strong>
				<xsl:value-of select="nuds:denomination"/>
				<br/>
			</xsl:if>
			<xsl:if test="nuds:geographic/nuds:geogname[@xlink:role = 'mint']">
				<strong>Mint: </strong>
				<xsl:value-of select="string-join(nuds:geographic/nuds:geogname[@xlink:role = 'mint'], ',')"/>
				<br/>
			</xsl:if>
			<xsl:if test="nuds:obverse/nuds:persname[@xlink:role='portrait']">
				<strong>Portrait: </strong>
				<xsl:value-of select="string-join(nuds:obverse/nuds:persname[@xlink:role = 'portrait'], ',')"/>
				<br/>
			</xsl:if>
		</div>
	</xsl:template>
	
	<xsl:template match="nuds:date">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>
	
	<xsl:template match="nuds:dateRange">
		<xsl:value-of select="normalize-space(nuds:fromDate)"/>
		<xsl:text> - </xsl:text>
		<xsl:value-of select="normalize-space(nuds:toDate)"/>
	</xsl:template>
</xsl:stylesheet>
