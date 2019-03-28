<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all">
	<xsl:include href="sparql-metamodel.xsl"/>
	
	<!-- request parameters -->
	<xsl:param name="filter" select="doc('input:filter')/query"/>
	<xsl:param name="measurement" select="doc('input:request')/request/parameters/parameter[name='measurement']/value"/>
	<xsl:param name="format" select="doc('input:request')/request/parameters/parameter[name='format']/value"/>
	
	<!-- derive subject based on primary query property -->
	<xsl:variable name="subject" select="if (starts-with($filter, 'nmo:hasTypeSeriesItem')) then '?coin' else '?coinType'"/>
	
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
			
			<!-- process each SPARQL query fragment -->
			<xsl:for-each select="tokenize($filter, ';')">
				<xsl:variable name="property" select="substring-before(normalize-space(.), ' ')"/>
				<xsl:variable name="object" select="substring-after(normalize-space(.), ' ')"/>
				
				<xsl:choose>
					<xsl:when test="$property = 'portrait' or $property='deity'">
						<union>
							<triple s="{$subject}" p="nmo:hasObverse/nmo:hasPortrait" o="{$object}"/>
							<triple s="{$subject}" p="nmo:hasReverse/nmo:hasPortrait" o="{$object}"/>
						</union>
					</xsl:when>
					<xsl:when test="$property = 'from'">
						<xsl:if test="$object castable as xs:integer">
							<xsl:variable name="gYear" select="format-number(number($object), '0000')"/>
							
							<triple s="{$subject}" p="nmo:hasStartDate" o="?startDate">
								<xsl:attribute name="filter">
									<xsl:text>(?startDate >= "</xsl:text>
									<xsl:value-of select="$gYear"/>
									<xsl:text>"^^xsd:gYear)</xsl:text>
								</xsl:attribute>
							</triple>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$property = 'to'">
						<xsl:if test="$object castable as xs:integer">
							<xsl:variable name="gYear" select="format-number(number($object), '0000')"/>
							
							<triple s="{$subject}" p="nmo:hasEndDate" o="?endDate">
								<xsl:attribute name="filter">
									<xsl:text>(?endDate &lt;= "</xsl:text>
									<xsl:value-of select="$gYear"/>
									<xsl:text>"^^xsd:gYear)</xsl:text>
								</xsl:attribute>
							</triple>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$property = 'range'">
						<xsl:if test="matches($object, '-?\d+\|-?\d+')">
							<xsl:variable name="range" select="tokenize($object, '\|')"/>
							
							<xsl:variable name="s">
								<xsl:choose>
									<xsl:when test="contains($filter, 'nmo:hasTypeSeriesItem')">
										<xsl:analyze-string select="$filter" regex="nmo:hasTypeSeriesItem\s(&lt;.*&gt;)">
											<xsl:matching-substring>
												<xsl:value-of select="regex-group(1)"/>
											</xsl:matching-substring>
										</xsl:analyze-string>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$subject"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<triple s="{$s}" p="nmo:hasEndDate" o="?endDate">
								<xsl:attribute name="filter">
									<xsl:text>(?endDate &gt;= "</xsl:text>
									<xsl:value-of select="format-number(number($range[1]), '0000')"/>
									<xsl:text>"^^xsd:gYear &amp;&amp; ?endDate &lt;= "</xsl:text>
									<xsl:value-of select="format-number(number($range[2]), '0000')"/>
									<xsl:text>"^^xsd:gYear)</xsl:text>
								</xsl:attribute>
							</triple>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$property = 'nmo:hasTypeSeriesItem'">
						<!-- get the measurements for all coins connected with a given type or any of its subtypes -->
						<union>
							<group>
								<triple s="{$subject}" p="{$property}" o="{$object}"/>
							</group>							
							<group>
								<triple s="?broader" p="skos:broader+" o="{$object}"/>
								<triple s="{$subject}" p="{$property}" o="?broader"/>
							</group>
						</union>
					</xsl:when>
					<xsl:otherwise>
						<triple s="{$subject}" p="{$property}" o="{$object}"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			
			<xsl:if test="$subject = '?coinType'">
				<triple s="?coin" p="nmo:hasTypeSeriesItem" o="?coinType"/>
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
