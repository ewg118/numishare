<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:nuds="http://nomisma.org/nuds" xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all" version="2.0">

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
				<div style="height: 200px; width: 600px; overflow: hidden; font-size: 0.7em">
					<table>
						<tbody>
							<tr>
								<td style="width:200px">
									<xsl:apply-templates select="doc('input:sparql')//res:result"/>
								</td>
								<td style="width:400px">
									<a href="{concat($uri_space, nuds:control/nuds:recordId)}" target="_blank" style="text-decoration: none;">
										<xsl:value-of select="descendant::nuds:title[@xml:lang = 'en']"/>
									</a>
									<xsl:text> </xsl:text>
									<span style="color: #505050;">(<xsl:value-of select="nuds:control/nuds:recordId"/>)</span>
									<!-- display basic typological data -->
									<xsl:apply-templates select="nuds:descMeta/nuds:typeDesc"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="nuds:typeDesc">
		<div>
			<xsl:if test="nuds:date or nuds:dateRange">
				<strong>Date: </strong>
				<xsl:apply-templates select="nuds:date | nuds:dateRange"/>
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
			<xsl:if test="nuds:obverse/nuds:persname[@xlink:role = 'portrait']">
				<strong>Portrait: </strong>
				<xsl:value-of select="string-join(nuds:obverse/nuds:persname[@xlink:role = 'portrait'], ',')"/>
				<br/>
			</xsl:if>
			<xsl:if test="nuds:obverse/nuds:type or nuds:obverse/nuds:legend">
				<xsl:apply-templates select="nuds:obverse | nuds:reverse"/>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="nuds:obverse | nuds:reverse">
		<strong>
			<xsl:value-of select="concat(upper-case(substring(local-name(), 1, 1)), substring(local-name(), 2))"/>
			<xsl:text>: </xsl:text>
		</strong>
		<xsl:apply-templates select="nuds:legend"/>
		<xsl:if test="string(nuds:legend) and string(nuds:type)">
			<xsl:text> - </xsl:text>
		</xsl:if>
		<!-- apply language-specific type description templates -->
		<xsl:choose>
			<xsl:when test="nuds:type/nuds:description[@xml:lang = 'en']">
				<xsl:apply-templates select="nuds:type/nuds:description[@xml:lang = 'en']"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="nuds:type/nuds:description[1]"/>
			</xsl:otherwise>
		</xsl:choose>
		<br/>
	</xsl:template>

	<xsl:template match="nuds:date">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

	<xsl:template match="nuds:dateRange">
		<xsl:value-of select="normalize-space(nuds:fromDate)"/>
		<xsl:text> - </xsl:text>
		<xsl:value-of select="normalize-space(nuds:toDate)"/>
	</xsl:template>
	
	<!-- display thumbnail -->
	<xsl:template match="res:result">
		<a href="{res:binding[@name='object']/res:uri}" target="_blank">
			<xsl:choose>
				<xsl:when test="res:binding[@name='obvThumb'] and res:binding[@name='revThumb']">
					<img src="{res:binding[@name='obvThumb']/res:uri}" alt="obverse" style="width:96px"/>
					<img src="{res:binding[@name='revThumb']/res:uri}" alt="obverse" style="width:96px"/>
				</xsl:when>
				<xsl:when test="res:binding[@name='comRef']">
					<img src="{res:binding[@name='comRef']/res:uri}" alt="combined" style="width:200px"/>
				</xsl:when>
			</xsl:choose>
		</a>		
	</xsl:template>
</xsl:stylesheet>
