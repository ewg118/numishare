<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">

	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:param name="collection_path" select="/content/config/url"/>
	<xsl:include href="../results_generic.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:param name="display_path"/>
	<xsl:param name="q"/>
	<xsl:param name="rows">20</xsl:param>
	<xsl:param name="start"/>
	<xsl:param name="mode"/>
	<xsl:param name="image"/>
	<xsl:param name="side"/>
	<xsl:param name="sort"/>
	<xsl:param name="lang"/>
	<xsl:variable name="start_var" as="xs:integer">
		<xsl:choose>
			<xsl:when test="number($start)">
				<xsl:value-of select="$start"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="numFound">
		<xsl:value-of select="//result[@name='response']/@numFound"/>
	</xsl:variable>

	<xsl:template match="/">
		<!-- this is for returning search results from the search pipeline -->

		<xsl:choose>
			<xsl:when test="$numFound &gt; 0">
				<xsl:call-template name="compare_paging"/>
				<xsl:call-template name="sort"/>
				<xsl:apply-templates select="//doc"/>
				<xsl:call-template name="compare_paging"/>
			</xsl:when>
			<xsl:otherwise>
				<p>No results found.</p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
