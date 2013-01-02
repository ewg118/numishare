<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:gml="http://www.opengis.net/gml/"
	xmlns:nuds="http://nomisma.org/nuds/numismatic_database_standard" exclude-result-prefixes="xs"
	version="2.0">

	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:template match="/">
		<results xmlns:gml="http://www.opengis.net/gml/"
			xmlns:nuds="http://nomisma.org/nuds/numismatic_database_standard">
			<xsl:apply-templates select="//doc"/>
		</results>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="count" select="count(arr[@name='mint_geo']/str)"/>
		<object type="{str[@name='objectType_facet']}" nuds:catalogId="{str[@name='identifier_display']}">
			<xsl:for-each select="arr[@name='mint_facet']/str">
				<nuds:mint>
					<xsl:value-of select="."/>
				</nuds:mint>
			</xsl:for-each>
			<xsl:for-each select="arr[@name='person_facet']/str">
				<nuds:person>
					<xsl:value-of select="."/>
				</nuds:person>
			</xsl:for-each>
			<xsl:for-each select="arr[@name='denomination_facet']/str">
				<nuds:denomination>
					<xsl:value-of select="."/>
				</nuds:denomination>
			</xsl:for-each>
			<nuds:mintCoordinates>
				<gml:Point gml:id="{str[@name='id']}">
					<gml:coordinates>
						<xsl:value-of select="replace(arr[@name='mint_geo']/str[1], ',', ', ')"/>
					</gml:coordinates>
				</gml:Point>
			</nuds:mintCoordinates>
		</object>
	</xsl:template>

</xsl:stylesheet>
