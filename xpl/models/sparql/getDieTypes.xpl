<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: June 2022
	Function: Execute a SPARQL query in order to query coin types related to a die
	request parameter. 
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

	<!-- get query from a text file on disk -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/numishare/ui/sparql/get-types-for-die.sparql</url>
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
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:numishare="https://github.com/ewg118/numishare">

				<!-- get identifier from request headers if they exist, otherwise, get ID from URL pattern -->
				<xsl:param name="identifiers"
					select="if (string(/request/parameters/parameter[name='identifiers']/value)) 
						then /request/parameters/parameter[name='identifiers']/value 
						else tokenize(/request/request-url, '/')[last()]"/>

				<xsl:template match="/">
					<identifiers>
						<xsl:for-each select="tokenize($identifiers, '\|')">
							<identifier>
								<xsl:value-of select="."/>
							</identifier>
						</xsl:for-each>
					</identifiers>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="identifiers"/>
	</p:processor>

	<p:for-each href="#identifiers" select="//identifier" root="response" id="aggregate-response">
		<p:processor name="oxf:unsafe-xslt">
			<p:input name="id" href="current()"/>
			<p:input name="query" href="#query-document"/>
			<p:input name="request" href="#request"/>
			<p:input name="data" href="#data"/>
			<p:input name="config">
				<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

					<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>
					<xsl:variable name="query" select="doc('input:query')"/>
					<xsl:variable name="namedGraph" select="/config/die_study/namedGraph"/>
					<xsl:variable name="dieURI" select="concat(/config/uri_space, data(doc('input:id')))"/>

					<xsl:variable name="service">
						<xsl:value-of
							select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace($query, '%graphURI%', $namedGraph), '%dieURI%', $dieURI)), '&amp;output=xml')"
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
			<p:output name="data" id="sparql-results"/>
		</p:processor>

		<p:processor name="oxf:identity">
			<p:input name="data" href="aggregate('group', current(), #sparql-results)"/>
			<p:output name="data" ref="aggregate-response"/>
		</p:processor>
	</p:for-each>

	<p:processor name="oxf:identity">
		<p:input name="data" href="#aggregate-response"/>
		<p:output name="data" ref="data"/>
	</p:processor>

</p:config>
