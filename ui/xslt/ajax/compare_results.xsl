<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"  version="2.0">
	<xsl:include href="../serializations/solr/html-templates.xsl"/>
	<xsl:include href="../functions.xsl"/>
	
	<!-- URL params -->	
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="rows">20</xsl:param>
	<xsl:param name="start" select="doc('input:request')/request/parameters/parameter[name='start']/value"/>
	<xsl:param name="mode" select="doc('input:request')/request/parameters/parameter[name='mode']/value"/>
	<xsl:param name="image" select="doc('input:request')/request/parameters/parameter[name='image']/value"/>
	<xsl:param name="side" select="doc('input:request')/request/parameters/parameter[name='side']/value"/>
	<xsl:param name="sort" select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[.='accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[.='accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>
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
	
	<!-- empty variables -->
	<xsl:variable name="collection_type"/>
	<xsl:variable name="tokenized_q"/>
	<xsl:variable name="sparqlResult" as="element()*">
		<empty/>
	</xsl:variable>
	<xsl:variable name="request-uri"/>
	
	<!-- misc -->
	<xsl:variable name="display_path"/>
	<xsl:param name="pipeline">compare</xsl:param>
	
	<xsl:template match="/">
		<!-- this is for returning search results from the search pipeline -->
		<xsl:choose>
			<xsl:when test="$numFound &gt; 0">
				<xsl:call-template name="paging"/>
				<xsl:call-template name="sort"/>
				<xsl:apply-templates select="descendant::doc"/>
				<xsl:call-template name="paging"/>
			</xsl:when>
			<xsl:otherwise>
				<p>No results found.</p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
