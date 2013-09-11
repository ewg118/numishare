<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:datetime="http://exslt.org/dates-and-times" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:exsl="http://exslt.org/common" xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gml="http://www.opengis.net/gml" xmlns:skos="http://www.w3.org/2004/02/skos/core#" version="2.0" exclude-result-prefixes="#all">
	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="nh:nudsHoard"/>
		</add>
	</xsl:template>

	<xsl:template match="nh:nudsHoard">
		<doc>
			<field name="id">
				<xsl:value-of select="nh:control/nh:recordId"/>
			</field>
			<field name="title_display">
				<xsl:value-of select="nh:control/nh:recordId"/>
			</field>
			<field name="recordType">hoard</field>
			<field name="timestamp">
				<xsl:value-of select="if(contains(datetime:dateTime(), 'Z')) then datetime:dateTime() else concat(datetime:dateTime(), 'Z')"/>
			</field>
			<field name="fulltext">
				<xsl:for-each select="descendant-or-self::text()">
					<xsl:value-of select="normalize-space(.)"/>
					<xsl:text> </xsl:text>
				</xsl:for-each>								
			</field>
		</doc>
	</xsl:template>
</xsl:stylesheet>
