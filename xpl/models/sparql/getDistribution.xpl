<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: February 2019
	Function: Execute a SPARQL query or chain of SPARQL queries for distribution analyses to extract a JSON response for d3
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<!-- get query from a text file on disk -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/numishare/ui/sparql/typological_distribution.sparql</url>
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

	<!-- add in compare queries -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- request parameters -->
				<xsl:param name="compare" select="/request/parameters/parameter[name='compare']/value"/>
				<xsl:param name="filter" select="/request/parameters/parameter[name='filter']/value"/>

				<xsl:template match="/">
					<queries>
						<xsl:if test="string($filter)">
							<query>
								<xsl:value-of select="normalize-space($filter)"/>
							</query>
						</xsl:if>
						<xsl:for-each select="$compare">
							<query>
								<xsl:value-of select="."/>
							</query>
						</xsl:for-each>
					</queries>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="compare-queries"/>
	</p:processor>

	<!-- when there is at least one compare query, then aggregate the compare queries with the primary query into one model -->
	<p:for-each href="#compare-queries" select="//query" root="response" id="sparql-results">
		<p:processor name="oxf:unsafe-xslt">
			<p:input name="filter" href="current()"/>
			<p:input name="query" href="#query-document"/>
			<p:input name="request" href="#request"/>
			<p:input name="data" href="#config"/>
			<p:input name="config">
				<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
					xmlns:numishare="https://github.com/ewg118/numishare">
					<xsl:include href="../../../ui/xslt/controllers/sparql-metamodel.xsl"/>
					<xsl:include href="../../../ui/xslt/functions.xsl"/>

					<!-- request parameters -->
					<xsl:param name="filter" select="doc('input:filter')/query"/>
					<xsl:param name="dist" select="doc('input:request')/request/parameters/parameter[name='dist']/value"/>
					<xsl:param name="format" select="doc('input:request')/request/parameters/parameter[name='format']/value"/>

					<!-- language -->
					<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
					<xsl:param name="lang">
						<xsl:choose>
							<xsl:when test="string($langParam)">
								<xsl:value-of select="$langParam"/>
							</xsl:when>
							<xsl:when test="string(doc('input:request')/request//header[name[. = 'accept-language']]/value)">
								<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[. = 'accept-language']]/value)[1]"
								/>
							</xsl:when>
						</xsl:choose>
					</xsl:param>

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

							<!-- parse filters -->
							<xsl:for-each select="tokenize($filter, ';')">
								<xsl:variable name="property" select="substring-before(normalize-space(.), ' ')"/>
								<xsl:variable name="object" select="substring-after(normalize-space(.), ' ')"/>

								<xsl:choose>
									<xsl:when test="$property = 'portrait' or $property='deity'">
										<union>
											<triple s="?coinType" p="nmo:hasObverse/nmo:hasPortrait" o="{$object}"/>
											<triple s="?coinType" p="nmo:hasReverse/nmo:hasPortrait" o="{$object}"/>
										</union>
									</xsl:when>
									<xsl:when test="$property = 'region'">
										<union>
											<group>
												<triple s="?coinType" p="nmo:hasRegion" o="{$object}"/>
											</group>
											<group>
												<triple s="?coinType" p="nmo:hasMint" o="?mint"/>
												<triple s="?mint" p="skos:broader+" o="{$object}"/>
											</group>
										</union>
									</xsl:when>
									<xsl:when test="$property = 'from'">
										<xsl:if test="$object castable as xs:integer">
											<xsl:variable name="gYear" select="format-number(number($object), '0000')"/>

											<triple s="?coinType" p="nmo:hasStartDate" o="?startDate">
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

											<triple s="?coinType" p="nmo:hasEndDate" o="?endDate">
												<xsl:attribute name="filter">
													<xsl:text>(?endDate &lt;= "</xsl:text>
													<xsl:value-of select="$gYear"/>
													<xsl:text>"^^xsd:gYear)</xsl:text>
												</xsl:attribute>
											</triple>
										</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<triple s="?coinType" p="{$property}" o="{$object}"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>

							<!-- parse dist -->
							<xsl:choose>
								<xsl:when test="$dist='portrait' or $dist='deity'">
									<xsl:variable name="distClass" select="if ($dist='portrait') then 'foaf:Person' else 'wordnet:Deity'"/>
									<union>
										<triple s="?coinType" p="nmo:hasObverse/nmo:hasPortrait" o="?dist"/>
										<triple s="?coinType" p="nmo:hasReverse/nmo:hasPortrait" o="?dist"/>
									</union>
									<triple s="?dist" p="a" o="{$distClass}"/>
								</xsl:when>
								<xsl:when test="$dist = 'region'">
									<union>
										<triple s="?coinType" p="nmo:hasRegion" o="?dist"/>
										<group>
											<triple s="?coinType" p="nmo:hasMint" o="?mint"/>
											<triple s="?mint" p="skos:broader+" o="?dist"/>
										</group>
									</union>
								</xsl:when>
								<xsl:otherwise>
									<triple s="?coinType" p="{$dist}" o="?dist"/>
									<!-- if the dist is mint, then include lat and long, but only for CSV -->
									<xsl:if test="$dist='nmo:hasMint' and $format='csv'">
										<optional>
											<triple s="?dist" p="geo:location" o="?loc"/>
											<triple s="?loc" p="geo:lat" o="?lat"/>
											<triple s="?loc" p="geo:long" o="?long"/>
										</optional>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>

							<!-- get label -->
							<xsl:choose>
								<xsl:when test="not($lang = 'en')">
									<optional>
										<triple s="?dist" p="skos:prefLabel" o="?label" filter="langMatches(lang(?label), &#x022;{$lang}&#x022;)"/>
									</optional>
									<triple s="?dist" p="skos:prefLabel" o="?en_label" filter="langMatches(lang(?en_label), &#x022;en&#x022;)"/>
								</xsl:when>
								<xsl:otherwise>
									<triple s="?dist" p="skos:prefLabel" o="?label" filter="langMatches(lang(?label), &#x022;en&#x022;)"/>
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
			<p:output name="data" id="compare-url-generator-config"/>
		</p:processor>

		<!-- get the data from fuseki -->
		<p:processor name="oxf:url-generator">
			<p:input name="config" href="#compare-url-generator-config"/>
			<p:output name="data" ref="sparql-results"/>
		</p:processor>
	</p:for-each>

	<p:processor name="oxf:identity">
		<p:input name="data" href="#sparql-results"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
