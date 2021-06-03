<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date Modified: June 2021
	Function: Query the dies that are in the opposite property (nmo:hasObverse or nmo:hasReverse) from the current die URI or query the die combinations for a coin type URI
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="input" name="query"/>
	<p:param type="input" name="request"/>
	<p:param type="input" name="uri"/>
	<p:param type="output" name="data"/>
	
	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="query" href="#query"/>
		<p:input name="uri" href="#uri"/>
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
				exclude-result-prefixes="#all">
				<xsl:include href="../../../ui/xslt/controllers/metamodel-templates.xsl"/>
				<xsl:include href="../../../ui/xslt/controllers/sparql-metamodel.xsl"/>
				
				<xsl:variable name="uri" select="doc('input:uri')"/>
				
				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>				
				
				<xsl:variable name="query">
					<xsl:value-of select="doc('input:query')"/>
				</xsl:variable>
				
				<xsl:variable name="statements" as="element()*">
					<statements>
						<xsl:call-template name="numishare:querySymbolRelations">
							<xsl:with-param name="uri" select="$uri"/>								
						</xsl:call-template>			
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
		</p:input>
		<p:output name="data" id="url-generator-config"/>
	</p:processor>
	
	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
