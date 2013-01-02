<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>
	<xsl:param name="q"/>
	<xsl:param name="customQuery"/>
	<xsl:param name="type"/>
	<xsl:param name="total" as="xs:integer"/>

	<xsl:template match="/">
		<xsl:variable name="numFound" select="number(//result[@name='response']/@numFound)"/>
		<xsl:variable name="value">
			<xsl:choose>
				<xsl:when test="$type='count'">
					<xsl:value-of select="$numFound"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="format-number(($numFound div $total) * 100, '##.00')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<query q="{$q}">
			<name count="{$value}">
				<xsl:value-of select="$customQuery"/>
			</name>
		</query>
	</xsl:template>
</xsl:stylesheet>
