<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" xmlns:numishare="http://code.google.com/p/numishare/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../functions.xsl"/>

	<!-- use the calculate URI parameter to output tables/charts for counts of material, denomination, issuer, etc. -->
	<xsl:param name="q"/>
	<xsl:param name="category"/>
	<xsl:param name="lang"/>

	<xsl:template match="/">
		<div>
			<xsl:for-each select="//lst[@name='facet_fields']/lst[number(int[@name='numFacetTerms']) &gt; 0]">
				<xsl:variable name="query_fragment" select="@name"/>
				<span class="anOption">
					<xsl:choose>
						<xsl:when test="contains($category, $query_fragment)">
							<input type="checkbox" id="{$query_fragment}-checkbox" checked="checked" value="{$query_fragment}" class="calculate-checkbox"/>
						</xsl:when>
						<xsl:otherwise>
							<input type="checkbox" id="{$query_fragment}-checkbox" value="{$query_fragment}" class="calculate-checkbox"/>
						</xsl:otherwise>
					</xsl:choose>
					<label for="{$query_fragment}-checkbox">
						<xsl:value-of select="numishare:normalize_fields(@name, $lang)"/>
					</label>
				</span>
			</xsl:for-each>
		</div>
	</xsl:template>
</xsl:stylesheet>
