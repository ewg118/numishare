<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<!-- use the calculate URI parameter to output tables/charts for counts of material, denomination, issuer, etc. -->
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>
	<xsl:param name="category" select="doc('input:request')/request/parameters/parameter[name='category']/value"/>
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
