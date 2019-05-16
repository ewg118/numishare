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
			<p:input name="config" href="../../../ui/xslt/controllers/distribution-params-to-model.xsl"/>
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
