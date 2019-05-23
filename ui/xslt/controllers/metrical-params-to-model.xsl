<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
	exclude-result-prefixes="#all">
	<xsl:include href="metamodel-templates.xsl"/>
	<xsl:include href="sparql-metamodel.xsl"/>

	<!-- request parameters -->
	<xsl:param name="filter" select="doc('input:filter')/query"/>
	<xsl:param name="measurement" select="doc('input:request')/request/parameters/parameter[name = 'measurement']/value"/>
	<xsl:param name="format" select="doc('input:request')/request/parameters/parameter[name = 'format']/value"/>

	<!-- derive subject based on primary query property -->
	<xsl:variable name="subject" select="
			if (starts-with($filter, 'nmo:hasTypeSeriesItem')) then
				'?coin'
			else
				'?coinType'"/>

	<!-- config variables -->
	<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>
	<xsl:variable name="query" select="doc('input:query')"/>

	<xsl:variable name="statements" as="node()*">
		<statements>
			<!-- insert the type series set in the config, but only if this isn't a metrical query issued for a specific coin type -->
			<xsl:if test="$subject = '?coinType'">
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
			</xsl:if>

			<!-- process each SPARQL query fragments -->
			<xsl:call-template name="numishare:filterToMetamodel">
				<xsl:with-param name="subject" select="$subject"/>
				<xsl:with-param name="filter" select="$filter"/>
			</xsl:call-template>

			<xsl:if test="$subject = '?coinType'">
				<union>
					<group>
						<triple s="?coin" p="nmo:hasTypeSeriesItem" o="?coinType"/>
					</group>
					<group>
						<triple s="?coinType" p="skos:exactMatch" o="?match"/>
						<triple s="?coin" p="nmo:hasTypeSeriesItem" o="?match"/>						
					</group>					
				</union>				
			</xsl:if>

			<triple s="?coin" p="{$measurement}" o="?measurement"/>
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
