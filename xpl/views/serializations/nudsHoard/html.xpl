<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Last modified: May 2020
	Function: HTML view for NUDSHoard -->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:res="http://www.w3.org/2005/sparql-results#">
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
		<p:input name="config" href="../../../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<!-- get list of published hoards from Solr and serialize them into a select list -->
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/solr/get_hoards.xpl"/>
		<p:output name="data" id="get_hoards-model"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#get_hoards-model"/>
		<p:input name="config" href="../../../../ui/xslt/ajax/get_hoards.xsl"/>
		<p:output name="data" id="hoards-list"/>
	</p:processor>

	<!-- get certainty codes from the eXist-db collection and serialize into a list -->
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/xquery/get_certainty_codes.xpl"/>
		<p:output name="data" id="codes-model"/>
	</p:processor>

	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#codes-model"/>
		<p:input name="config" href="../../../views/ajax/get_certainty_codes.xpl"/>
		<p:output name="data" id="codes-view"/>
	</p:processor>
	
	<!-- load SPARQL query from disk -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/numishare/ui/sparql/hoard-examples.sparql</url>
				<content-type>text/plain</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" id="hoard-examples-query"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#hoard-examples-query"/>
		<p:input name="config">
			<config/>
		</p:input>
		<p:output name="data" id="hoard-examples-query-document"/>
	</p:processor>

	<!-- submit SPARQL query to ASK if there are physical specimens associated with the hoard -->
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#config"/>
		<p:input name="config" href="../../../models/sparql/hoard-specimen-count.xpl"/>
		<p:output name="data" id="specimenCount"/>
	</p:processor>

	<p:choose href="#config">
		<p:when test="matches(/config/annotation_sparql_endpoint, 'https?://')">

			<!-- perform ASK query for annotations related to this URI -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="#config"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
						<xsl:param name="uri" select="concat(/config/uri_space, tokenize(doc('input:request')/request/request-url, '/')[last()])"/>

						<!-- config variables -->
						<xsl:variable name="sparql_endpoint" select="/config/annotation_sparql_endpoint"/>

						<xsl:variable name="query">
							<![CDATA[PREFIX oa:	<http://www.w3.org/ns/oa#>
ASK {?s oa:hasBody <URI>}]]>
						</xsl:variable>

						<xsl:variable name="service">
							<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, 'URI', $uri)), '&amp;output=xml')"/>
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
				<p:output name="data" id="ask-url-generator-config"/>
			</p:processor>

			<!-- get a SPARQL response from the endpoint -->
			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#ask-url-generator-config"/>
				<p:output name="data" id="url-data"/>
			</p:processor>

			<p:processor name="oxf:exception-catcher">
				<p:input name="data" href="#url-data"/>
				<p:output name="data" id="url-data-checked"/>
			</p:processor>

			<!-- Check whether we had an exception -->
			<p:choose href="#url-data-checked">
				<p:when test="/exceptions">

					<p:choose href="#specimenCount">
						<p:when test="//res:binding[@name='count']/res:literal = 0">
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="hoards-list" href="#hoards-list"/>
								<p:input name="query" href="#hoard-examples-query-document"/>
								<p:input name="specimenCount" href="#specimenCount"/>
								<p:input name="data" href="aggregate('content', #data, #config, #codes-view)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/nudsHoard/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:when>
						<p:otherwise>
							<p:processor name="oxf:pipeline">
								<p:input name="data" href="#config"/>
								<p:input name="config" href="../../../models/sparql/hoard-examples.xpl"/>
								<p:output name="data" id="specimens"/>
							</p:processor>

							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="hoards-list" href="#hoards-list"/>
								<p:input name="query" href="#hoard-examples-query-document"/>
								<p:input name="specimens" href="#specimens"/>
								<p:input name="specimenCount" href="#specimenCount"/>
								<p:input name="data" href="aggregate('content', #data, #config, #codes-view)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/nudsHoard/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:otherwise>
					</p:choose>
				</p:when>
				<p:otherwise>
					<!-- otherwise, combine the XML model with the annotations SPARQL response and execute transformation into HTML -->
					<p:processor name="oxf:pipeline">
						<p:input name="config" href="../../../models/sparql/annotations.xpl"/>
						<p:output name="data" id="annotations"/>
					</p:processor>

					<p:choose href="#specimenCount">
						<p:when test="//res:binding[@name='count']/res:literal = 0">
							<!-- otherwise, combine the XML model with the annotations SPARQL response and execute transformation into HTML -->
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="annotations" href="#annotations"/>
								<p:input name="hoards-list" href="#hoards-list"/>
								<p:input name="query" href="#hoard-examples-query-document"/>
								<p:input name="specimenCount" href="#specimenCount"/>
								<p:input name="data" href="aggregate('content', #data, #config, #codes-view)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/nudsHoard/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:when>
						<p:otherwise>
							<p:processor name="oxf:pipeline">
								<p:input name="data" href="#config"/>
								<p:input name="config" href="../../../models/sparql/hoard-examples.xpl"/>
								<p:output name="data" id="specimens"/>
							</p:processor>

							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="annotations" href="#annotations"/>
								<p:input name="hoards-list" href="#hoards-list"/>
								<p:input name="query" href="#hoard-examples-query-document"/>
								<p:input name="specimens" href="#specimens"/>
								<p:input name="specimenCount" href="#specimenCount"/>
								<p:input name="data" href="aggregate('content', #data, #config, #codes-view)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/nudsHoard/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:otherwise>
					</p:choose>
				</p:otherwise>
			</p:choose>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="hoards-list" href="#hoards-list"/>
				<p:input name="query" href="#hoard-examples-query-document"/>
				<p:input name="specimenCount" href="#specimenCount"/>
				<p:input name="data" href="aggregate('content', #data, #config, #codes-view)"/>
				<p:input name="config" href="../../../../ui/xslt/serializations/nudsHoard/html.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:otherwise>
	</p:choose>

	<p:processor name="oxf:html-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<version>5.0</version>
				<indent>true</indent>
				<content-type>text/html</content-type>
				<encoding>utf-8</encoding>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
