<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" exclude-result-prefixes="#all" version="2.0">

	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>

	<!-- use the calculate URI parameter to output tables/charts for counts of material, denomination, issuer, etc. -->
	<xsl:param name="q"/>
	<xsl:param name="type"/>
	<xsl:param name="category"/>


	<xsl:template match="/">
		<query q="{$q}">
			<xsl:if test="number(//result[@name='response']/@numFound) &gt; 0">
				<xsl:apply-templates select="//lst[@name='facet_fields']/lst[contains($category, @name)][count(int) &gt; 0]"/>
			</xsl:if>
		</query>
	</xsl:template>

	<xsl:template match="lst">
		<xsl:variable name="total" select="sum(int)"/>

		<xsl:for-each select="int">
			<xsl:sort select="@name"/>
			<xsl:variable name="value">
				<xsl:choose>
					<xsl:when test="$type='count'">
						<xsl:value-of select="."/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number((. div $total) * 100, '##.00')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<name count="{$value}">
				<xsl:value-of select="if (string(@name)) then @name else '[No Label]'"/>
			</name>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
