<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
	exclude-result-prefixes="#all">
	<xsl:include href="metamodel-templates.xsl"/>
	<xsl:include href="sparql-metamodel.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<!-- request parameters -->
	<xsl:param name="filter" select="doc('input:filter')/query"/>

	<!-- config variables -->
	<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>
	<xsl:variable name="query" select="doc('input:query')"/>

	<!-- parse query statements into a data object -->
	<xsl:variable name="statements" as="element()*">
		<statements>
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

			<!-- insert start and end dates -->
			<triple s="?coinType" p="nmo:hasStartDate" o="?start"/>
			<triple s="?coinType" p="nmo:hasEndDate" o="?end"/>
			
			<!-- only apply the years to types (including skos:exactMatch) that have a specimen -->
			<union>
				<group>
					<triple s="?coin" p="nmo:hasTypeSeriesItem" o="?coinType"/>
				</group>
				<group>
					<triple s="?coinType" p="skos:exactMatch" o="?match"/>
					<triple s="?coin" p="nmo:hasTypeSeriesItem" o="?match"/>						
				</group>					
			</union>
			<triple s="?coin" p="rdf:type" o="nmo:NumismaticObject"/>
		</statements>
	</xsl:variable>

	<xsl:variable name="statementsSPARQL">
		<xsl:apply-templates select="$statements/*"/>
	</xsl:variable>

	<xsl:variable name="service">
		<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, '%STATEMENTS%', $statementsSPARQL)), '&amp;output=xml')"/>
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
