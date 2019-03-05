<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all">
	<xsl:include href="sparql-metamodel.xsl"/>
	
	<!-- request parameters -->
	<xsl:param name="filter" select="doc('input:filter')/query"/>
	<xsl:param name="measurement" select="doc('input:request')/request/parameters/parameter[name='measurement']/value"/>
	<xsl:param name="format" select="doc('input:request')/request/parameters/parameter[name='format']/value"/>
	
	<!-- config variables -->
	<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>
	<xsl:variable name="query" select="doc('input:query')"/>
	
	<xsl:variable name="abstracted" as="node()*">
		<group>
			<xsl:for-each select="tokenize($filter, ';')">
				<xsl:variable name="property" select="substring-before(normalize-space(.), ' ')"/>
				<xsl:variable name="object" select="substring-after(normalize-space(.), ' ')"/>
				
				<xsl:choose>
					<xsl:when test="$property = 'portrait' or $property='deity'">
						<triple s="" p="nmo:hasObverse" o="?obv"/>
						<triple s="" p="nmo:hasReverse" o="?rev"/>
						<union>
							<triple s="?obv" p="nmo:hasPortrait" o="{$object}"/>
							<triple s="?rev" p="nmo:hasPortrait" o="{$object}"/>
						</union>
					</xsl:when>
					<xsl:when test="$property = 'from'">
						<xsl:if test="$object castable as xs:integer">
							<xsl:variable name="gYear" select="format-number(number($object), '0000')"/>
							
							<triple s="" p="nmo:hasStartDate" o="?startDate">
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
							
							<triple s="" p="nmo:hasEndDate" o="?endDate">
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
							
							<triple s="" p="nmo:hasEndDate" o="?endDate">
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
					<xsl:otherwise>
						<triple s="" p="{$property}" o="{$object}"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</group>
	</xsl:variable>
	
	<!-- parse query statements into a data object -->
	<xsl:variable name="statements" as="element()*">
		<statements>
			<!-- parse filters -->
			<union>								
				<xsl:apply-templates select="$abstracted" mode="coin"/>
				<xsl:apply-templates select="$abstracted" mode="coinType"/>
			</union>
			
			<!-- parse measurement -->
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
	
	<!-- construct triple for coins -->
	<xsl:template match="group" mode="coin">	
		<group>
			<xsl:for-each select="triple">
				<triple s="?coin" p="{@p}" o="{@o}">
					<xsl:if test="@filter">
						<xsl:attribute name="filter" select="@filter"/>
					</xsl:if>
				</triple>
			</xsl:for-each>
		</group>						
	</xsl:template>
	
	<!-- construct triples for coin types -->
	<xsl:template match="group" mode="coinType">
		<group>
			<xsl:for-each select="triple">
				<triple s="?coinType" p="{@p}" o="{@o}">
					<xsl:if test="@filter">
						<xsl:attribute name="filter" select="@filter"/>
					</xsl:if>
				</triple>								
			</xsl:for-each>
			<triple s="?coin" p="nmo:hasTypeSeriesItem" o="?coinType"/>
		</group>						
	</xsl:template>
</xsl:stylesheet>
