<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: November 2020
	Function: submit an ASK query for every namedGraph in the Numishare config to look for dies that are related to the given coin type URI, aggregate into a single XML response
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

	<!-- evaluate if die_study is activated -->
	<p:choose href="#data">
		<p:when test="/config/die_study[@enabled = true()]">
			<!-- evaluate the collection_type, and execute a different SPARQL query for dies linked to a coin vs. coin type -->
			<p:choose href="#data">
				<p:when test="/config/collection_type = 'cointype'">
					<p:processor name="oxf:url-generator">
						<p:input name="config">
							<config>
								<url>oxf:/apps/numishare/ui/sparql/ask-dies-for-types.sparql</url>
								<content-type>text/plain</content-type>
								<encoding>utf-8</encoding>
							</config>
						</p:input>
						<p:output name="data" id="query"/>
					</p:processor>

				</p:when>
				<p:when test="/config/collection_type = 'object'">
					<p:processor name="oxf:url-generator">
						<p:input name="config">
							<config>
								<url>oxf:/apps/numishare/ui/sparql/ask-dies-for-coins.sparql</url>
								<content-type>text/plain</content-type>
								<encoding>utf-8</encoding>
							</config>
						</p:input>
						<p:output name="data" id="query"/>
					</p:processor>
				</p:when>
			</p:choose>

			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#query"/>
				<p:input name="config">
					<config/>
				</p:input>
				<p:output name="data" id="query-document"/>
			</p:processor>

			<!-- iterate through named graphs and execute a die-linking query for each named graph to evaluate links from the obverse or reverse -->
			<p:for-each href="#data" select="/config/die_study/namedGraph" root="response" id="sparql-response">
				<!-- generator config for URL generator -->
				<p:processor name="oxf:unsafe-xslt">
					<p:input name="request" href="#request"/>
					<p:input name="query" href="#query-document"/>
					<p:input name="namedGraph" href="current()"/>
					<p:input name="data" href="#data"/>
					<p:input name="config">
						<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
							<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
							
							<!-- config variables -->
							<xsl:variable name="url" select="/config/url"/>
							<xsl:variable name="uri_space" select="/config/uri_space"/>
							<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>

							<xsl:variable name="uri"
								select="if (string($uri_space)) then
								concat($uri_space, $id)
								else
								concat($url, 'id/', $id)"/>

							<xsl:variable name="query">
								<xsl:value-of select="doc('input:query')"/>
							</xsl:variable>

							<xsl:variable name="service">
								<xsl:value-of
									select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace($query, '%URI%', $uri), '%graphURI%', doc('input:namedGraph')/namedGraph)), '&amp;output=xml')"
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
					<p:output name="data" id="url-generator-config"/>
				</p:processor>

				<!-- get the data from fuseki -->
				<p:processor name="oxf:url-generator">
					<p:input name="config" href="#url-generator-config"/>
					<p:output name="data" ref="sparql-response"/>
				</p:processor>
			</p:for-each>

			<p:processor name="oxf:identity">
				<p:input name="data" href="#sparql-response"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<!-- return false for hasDies -->
			<p:processor name="oxf:identity">
				<p:input name="data">
					<sparql xmlns="http://www.w3.org/2005/sparql-results#">
						<head/>
						<boolean>false</boolean>
					</sparql>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>
