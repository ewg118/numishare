<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: June 2021
	Function: Issues a SPARQL query to the established endpoint (usually Nomisma.org) in order to get a distinct list of findspots and number of coins found at that location
	associated with a particular coin type URI (including narrower matches, exact matches) or symbol URI, following the updated ARIADNE-compatible findspot data model.	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="input" name="config-xml"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<!-- get query from a text file on disk -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/numishare/ui/sparql/getFindspots.sparql</url>
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
		<p:input name="config-xml" href="#config-xml"/>
		<p:input name="data" href="#data"/>
		<p:input name="query" href="#query-document"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nmo="http://nomisma.org/ontology#" xmlns:numishare="https://github.com/ewg118/numishare">
				<xsl:include href="../../../ui/xslt/controllers/metamodel-templates.xsl"/>
				<xsl:include href="../../../ui/xslt/controllers/sparql-metamodel.xsl"/>
				
				<xsl:param name="id">
					<xsl:choose>
						<xsl:when test="doc('input:request')/request/parameters/parameter[name = 'id']/value">
							<xsl:value-of select="doc('input:request')/request/parameters/parameter[name = 'id']/value"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="doc" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
							
							<xsl:choose>								
								<xsl:when test="contains($doc, '.kml')">
									<xsl:value-of select="substring-before($doc, '.kml')"/>
								</xsl:when>
								<xsl:when test="contains($doc, '.geojson')">
									<xsl:value-of select="substring-before($doc, '.geojson')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$doc"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:param>		
				
				<xsl:variable name="type">
					<xsl:choose>
						<xsl:when test="*/namespace-uri()='http://nomisma.org/nuds'">cointype</xsl:when>
						<xsl:when test="*/namespace-uri()='http://www.w3.org/1999/02/22-rdf-syntax-ns#'">symbol</xsl:when>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="uri">
					<xsl:choose>
						<xsl:when test="$type = 'cointype'">
							<xsl:value-of select="concat(doc('input:config-xml')/config/uri_space, $id)"/>
						</xsl:when>
						<xsl:when test="$type = 'symbol'">
							<xsl:value-of select="concat(replace(doc('input:config-xml')/config/uri_space, '/id/', '/symbol/'), $id)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="query" select="doc('input:query')"/>
				<xsl:variable name="endpoint" select="doc('input:config-xml')/config/sparql_endpoint"/>
				
				<xsl:variable name="statements" as="element()*">
					<statements>
						<xsl:call-template name="numishare:getFindspots">
							<xsl:with-param name="type" select="$type"/>
							<xsl:with-param name="uri" select="$uri"/>
						</xsl:call-template>
					</statements>					
				</xsl:variable>
				
				<xsl:variable name="statementsSPARQL">
					<xsl:apply-templates select="$statements/*"/>
				</xsl:variable>
				
				<xsl:variable name="service"
					select="concat($endpoint, '?query=', encode-for-uri(replace($query, '%STATEMENTS%', $statementsSPARQL)), '&amp;output=xml')"/>

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
