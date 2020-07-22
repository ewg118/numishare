<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: July 2020
	Function: submit a SPARQL query for a type corpus or union type corpus to ascertain contributors of physical specimens
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<!-- load SPARQL text file from disk -->
	<!-- get query from a text file on disk -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/numishare/ui/sparql/contributors.sparql</url>
				<content-type>text/plain</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" id="query"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#query"/>
		<p:input name="config">
			<config/>
		</p:input>
		<p:output name="data" id="query-document"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="#config"/>
		<p:input name="query" href="#query-document"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">		
				<xsl:include href="../../../ui/xslt/controllers/sparql-metamodel.xsl"/>
				
				<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>				
				<xsl:variable name="query" select="doc('input:query')"/>
				
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
								<triple s="?object" p="nmo:hasTypeSeriesItem" o="?coinType"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="matches(/config/type_series, '^https?://')">
									<union>
										<group>
											<triple s="?coinType" p="dcterms:source">
												<xsl:attribute name="o" select="concat('&lt;', /config/type_series, '&gt;')"/>
											</triple>
										</group>
										<group>
											<triple s="?types" p="dcterms:source">
												<xsl:attribute name="o" select="concat('&lt;', /config/type_series, '&gt;')"/>
											</triple>
											<triple s="?types" p="skos:exactMatch" o="?coinType"/>
										</group>
									</union>
									<triple s="?object" p="nmo:hasTypeSeriesItem" o="?coinType"/>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</statements>
				</xsl:variable>
				
				<xsl:variable name="statementsSPARQL">
					<xsl:apply-templates select="$statements/*"/>
				</xsl:variable>
				
				<xsl:variable name="service">
					<xsl:value-of
						select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, '%STATEMENTS%', $statementsSPARQL)), '&amp;output=xml')"
					/>
				</xsl:variable>
				
				<!--<xsl:variable name="service" select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'TYPE_SERIES', /config/type_series))), '&amp;output=xml')"/>-->

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
		</p:input>
		<p:output name="data" id="generator-config"/>
	</p:processor>

	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
