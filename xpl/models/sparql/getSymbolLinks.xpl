<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date Modified: June 2021
	Function: Query the types and other symbols associated with a symbol URI.
-->
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
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<!-- load SPARQL query from disk -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/numishare/ui/sparql/query-symbol-relations.sparql</url>
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

	<!-- get symbol URI from request parameter -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">				
				<xsl:template match="/">
					<uri>
						<xsl:value-of select="/request/parameters/parameter[name='uri']/value"/>
					</uri>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="uri"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">						
		<p:input name="data" href="#config"/>
		<p:input name="request" href="#request"/>
		<p:input name="query" href="#query-document"/>		
		<p:input name="uri" href="#uri"/>
		<p:input name="config" href="query-symbol-relations.xpl"/>
		<p:output name="data" id="initial-response"/>
	</p:processor>
	
	<!-- iterate through each symbol URI connected with the initial query and execute a SPARQL query -->
	<p:for-each href="#initial-response" select="//res:binding[@name = 'altSymbol']/res:uri" root="response" id="sparql-response">
		<p:processor name="oxf:pipeline">						
			<p:input name="data" href="#config"/>
			<p:input name="request" href="#request"/>
			<p:input name="query" href="#query-document"/>		
			<p:input name="uri" href="current()"/>
			<p:input name="config" href="query-symbol-relations.xpl"/>
			<p:output name="data" ref="sparql-response"/>
		</p:processor>
	</p:for-each>
	
	<p:processor name="oxf:identity">
		<p:input name="data" href="aggregate('content', #initial-response, #sparql-response)"/>
		<p:output name="data" ref="data"/>
	</p:processor>
	
</p:config>
