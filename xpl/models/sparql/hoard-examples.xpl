<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Last modified: May 2020
	Function: execute a SPARQL query with an optional page parameter to get examples of physical specimens for a given hoard, limited to a value set in the config (or 48 if not set)	
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

	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="query" href="#hoard-examples-query-document"/>
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:param name="id" select="doc('input:request')/request/parameters/parameter[name='id']/value"/>				
				<xsl:param name="page" select="doc('input:request')/request/parameters/parameter[name='page']/value"/>
				
				<xsl:variable name="uri">
					<xsl:choose>
						<xsl:when test="string($id)">
							<xsl:value-of select="concat(/config/uri_space, $id)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat(/config/uri_space, tokenize(doc('input:request')/request/request-url, '/')[last()])"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>
				
				<!-- derive offset from page param -->
				<xsl:variable name="limit" select="if (/config/specimens_per_page castable as xs:integer) then /config/specimens_per_page else '48'"/>
				<xsl:variable name="offset">
					<xsl:choose>
						<xsl:when test="string-length($page) &gt; 0 and $page castable as xs:integer and number($page) > 0">
							<xsl:value-of select="($page - 1) * number($limit)"/>
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="query">
					<xsl:value-of select="concat(doc('input:query'), ' OFFSET %OFFSET% LIMIT %LIMIT%')"/>
				</xsl:variable>
				
				<xsl:variable name="service">
					<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace(replace($query, 'hoardURI', $uri), '%OFFSET%', $offset), '%LIMIT%', $limit)), '&amp;output=xml')"/>					
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
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
