<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:saxon="http://saxon.sf.net/" xmlns:nuds="http://nomisma.org/nuds" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<xsl:output name="default" indent="no" omit-xml-declaration="yes"/>


	<xsl:template match="/nuds:nuds">
		<xsl:variable name="model" as="element()*">
			<xsl:variable name="test" as="node()*">
				<xsl:apply-templates select="nuds:descMeta/nuds:typeDesc"/>
			</xsl:variable>

			<_object>
				<html>
					<xsl:text>&lt;p&gt;</xsl:text>
					<xsl:value-of select="saxon:serialize($test, 'default')"/>
					<xsl:text>&lt;/p&gt;</xsl:text>
				</html>
				<id>
					<xsl:value-of select="nuds:control/nuds:recordId"/>
				</id>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="nuds:typeDesc">
		<xsl:if test="nuds:date or nuds:dateRange">
			<xsl:text>Date: </xsl:text>
			<xsl:apply-templates select="nuds:date | nuds:dateRange"/>
			<xsl:text>; </xsl:text>
		</xsl:if>
		<xsl:if test="nuds:denomination">
			<xsl:text>Denomination: </xsl:text>
			<xsl:value-of select="nuds:denomination"/>
			<xsl:text>; </xsl:text>
		</xsl:if>
		<xsl:if test="nuds:geographic/nuds:geogname[@xlink:role = 'mint']">
			<xsl:text>Mint: </xsl:text>
			<xsl:value-of select="string-join(nuds:geographic/nuds:geogname[@xlink:role = 'mint'], ',')"/>
			<xsl:text>; </xsl:text>
		</xsl:if>
		<xsl:if test="nuds:obverse/nuds:persname[@xlink:role = 'portrait']">
			<xsl:text>Portrait: </xsl:text>
			<xsl:value-of select="string-join(nuds:obverse/nuds:persname[@xlink:role = 'portrait'], ',')"/>
			<xsl:text>; </xsl:text>
		</xsl:if>
		<xsl:if test="nuds:obverse/nuds:type or nuds:obverse/nuds:legend">
			<xsl:apply-templates select="nuds:obverse | nuds:reverse"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:obverse | nuds:reverse">
		<xsl:value-of select="concat(upper-case(substring(local-name(), 1, 1)), substring(local-name(), 2))"/>
		<xsl:text>: </xsl:text>
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
		<xsl:text>; </xsl:text>
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
