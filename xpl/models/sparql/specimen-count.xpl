<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date Modified: October 2020
	Function: Get the count of physical specimens associated with the coin type or die URI. This count is used to set $hasTypes and for pagination
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
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<collectionType>
						<xsl:value-of select="/config/collection_type"/>
					</collectionType>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="collectionType"/>
	</p:processor>
	
	<p:choose href="#collectionType">		
		<p:when test="collectionType = 'die'">
			<!-- load SPARQL query from disk -->
			<p:processor name="oxf:url-generator">
				<p:input name="config">
					<config>
						<url>oxf:/apps/numishare/ui/sparql/specimen-count-for-dies.sparql</url>
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
			
			<!-- generator config for URL generator -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="#data"/>
				<p:input name="query" href="#query-document"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">				
						<xsl:param name="uri" select="concat(/config/uri_space, tokenize(doc('input:request')/request/request-url, '/')[last()])"/>				
						
						<!-- config variables -->
						<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>				
						<xsl:variable name="query" select="doc('input:query')"/>				
						
						<xsl:variable name="service">
							<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace($query, 'dieURI', $uri), 'graphURI', /config/die_study/namedGraph)), '&amp;output=xml')"/>					
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
		</p:when>		
		<!-- if it is a coin type record, then execute an ASK query -->
		<p:when test="collectionType='cointype'">
			<!-- load SPARQL query from disk -->
			<p:processor name="oxf:url-generator">
				<p:input name="config">
					<config>
						<url>oxf:/apps/numishare/ui/sparql/specimen-count-for-types.sparql</url>
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
			
			<!-- generator config for URL generator -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="#data"/>
				<p:input name="query" href="#query-document"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">				
						<xsl:param name="uri" select="concat(/config/uri_space, tokenize(doc('input:request')/request/request-url, '/')[last()])"/>				
						
						<!-- config variables -->
						<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>				
						<xsl:variable name="query" select="doc('input:query')"/>				
						
						<xsl:variable name="service">
							<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, 'typeURI', $uri)), '&amp;output=xml')"/>					
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
		</p:when>
	</p:choose>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
