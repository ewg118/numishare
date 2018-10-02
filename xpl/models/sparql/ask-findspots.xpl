<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki	
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
	
	<!-- load SPARQL queries from disk -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/numishare/ui/sparql/ask-findspots-for-symbols.sparql</url>
				<content-type>text/plain</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" id="symbol-query"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#symbol-query"/>
		<p:input name="config">
			<config/>
		</p:input>
		<p:output name="data" id="symbol-query-document"/>
	</p:processor>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/numishare/ui/sparql/ask-findspots-for-types.sparql</url>
				<content-type>text/plain</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" id="type-query"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#type-query"/>
		<p:input name="config">
			<config/>
		</p:input>
		<p:output name="data" id="type-query-document"/>
	</p:processor>

	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="symbol-query" href="#symbol-query-document"/>
		<p:input name="type-query" href="#type-query-document"/>
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">	
				<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
				<!-- determine whether the URI corresponds to the type or the symbol -->
				<xsl:variable name="uri">
					<xsl:choose>
						<xsl:when test="contains(doc('input:request')/request/request-url, 'id/') or contains(doc('input:request')/request/request-url, 'map/')">
							<xsl:value-of select="concat(/config/uri_space, $id)"/>
						</xsl:when>
						<xsl:when test="contains(doc('input:request')/request/request-url, 'symbol/')">
							<xsl:value-of select="concat(replace(/config/uri_space, 'id/', 'symbol/'), $id)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>			

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>
				
				<xsl:variable name="query">
					<xsl:choose>
						<xsl:when test="contains(doc('input:request')/request/request-url, 'id/') or contains(doc('input:request')/request/request-url, 'map/')">
							<xsl:value-of select="doc('input:type-query')"/>
						</xsl:when>
						<xsl:when test="contains(doc('input:request')/request/request-url, 'symbol/')">
							<xsl:value-of select="doc('input:symbol-query')"/>
						</xsl:when>
					</xsl:choose>
					</xsl:variable>

				<xsl:variable name="service">
					<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, '%URI%', $uri)), '&amp;output=xml')"/>					
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
