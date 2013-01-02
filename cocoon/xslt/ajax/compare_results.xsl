<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0">

	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:param name="collection_path" select="/content/config/url"/>
	<xsl:include href="../results_generic.xsl"/>

	<xsl:param name="q"/>
	<xsl:param name="rows">20</xsl:param>
	<xsl:param name="start"/>
	<xsl:param name="mode"/>
	<xsl:param name="image"/>
	<xsl:param name="side"/>
	<xsl:param name="sort"/>
	
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
