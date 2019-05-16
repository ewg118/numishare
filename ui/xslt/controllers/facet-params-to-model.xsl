<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
	exclude-result-prefixes="#all">
	<xsl:include href="metamodel-templates.xsl"/>
	<xsl:include href="sparql-metamodel.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<!-- request parameters -->
	<xsl:param name="filter" select="doc('input:request')/request/parameters/parameter[name='filter']/value"/>
	<xsl:param name="facet" select="doc('input:request')/request/parameters/parameter[name='facet']/value"/>
	
	<!-- language -->
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[. = 'accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[. = 'accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>
	
	<!-- config variables -->
	<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>
	<xsl:variable name="query" select="doc('input:query')"/>
	
	<xsl:variable name="statements" as="element()*">
		<statements>
			<triple s="?coinType" p="rdf:type" o="nmo:TypeSeriesItem"/>
			
			<!-- insert the type series set in the config -->
			<xsl:choose>
				<xsl:when test="/config/union_type_catalog/@enabled = true()">
					<union>
						<xsl:for-each select="/config/union_type_catalog/series">
							<triple s="?coinType" p="dcterms:source">
								<xsl:attribute name="o" select="concat('&lt;', @typeSeries, '&gt;')"/>
							</triple>
						</xsl:for-each>
					</union>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="matches(/config/type_series, '^https?://')">
						<triple s="?coinType" p="dcterms:source">
							<xsl:attribute name="o" select="concat('&lt;', /config/type_series, '&gt;')"/>
						</triple>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- process each SPARQL query fragments -->
			<xsl:call-template name="numishare:filterToMetamodel">
				<xsl:with-param name="subject">?coinType</xsl:with-param>
				<xsl:with-param name="filter" select="$filter"/>
			</xsl:call-template>
			
			<!-- facet -->
			<xsl:call-template name="numishare:distToMetamodel">
				<xsl:with-param name="object">?facet</xsl:with-param>
				<xsl:with-param name="dist" select="$facet"/>
			</xsl:call-template>
			
			<!-- get label -->
			<xsl:choose>
				<xsl:when test="not($lang = 'en')">
					<optional>
						<triple s="?facet" p="skos:prefLabel" o="?label" filter="langMatches(lang(?label), &#x022;{$lang}&#x022;)"/>
					</optional>
					<triple s="?facet" p="skos:prefLabel" o="?en_label" filter="langMatches(lang(?en_label), &#x022;en&#x022;)"/>
				</xsl:when>
				<xsl:otherwise>
					<triple s="?facet" p="skos:prefLabel" o="?label" filter="langMatches(lang(?label), &#x022;en&#x022;)"/>
				</xsl:otherwise>
			</xsl:choose>
		</statements>
	</xsl:variable>
	
	<xsl:variable name="statementsSPARQL">
		<xsl:apply-templates select="$statements/*"/>
	</xsl:variable>
	
	<xsl:variable name="service">
		<xsl:value-of
			select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, '%STATEMENTS%', $statementsSPARQL)), '&amp;output=xml')"/>
	</xsl:variable>
	
	<xsl:template match="/">
		<config>
			<url>
				<xsl:value-of select="$service"/>
			</url>
			<content-type>application/xml</content-type>
			<encoding>utf-8</encoding>
		</config>
	</xsl:template>
</xsl:stylesheet>
