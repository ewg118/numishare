<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date Modified: March 2019
	Function: Read HTTP params in order to forward the response to CSV, raw XML, or d3-compliant JSON serialization pipelines, based on whether the source data are from
	the newer (Feb. - Mar. 2019) SPARQL-based distribution analyses or the older model based on Solr facets -->
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

	<!-- evaluate URL params to direct toward a view based on SPARQL results or based on the older Solr results -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">

				<xsl:template match="/">
					<source>
						<xsl:choose>
							<xsl:when test="//response[lst[@name='responseHeader']]">solr</xsl:when>
							<xsl:when test="//hoard">nudsHoard</xsl:when>
							<xsl:otherwise>sparql</xsl:otherwise>
						</xsl:choose>
					</source>
				</xsl:template>

			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="source"/>
	</p:processor>
	
	<!-- read the format HTTP param to determine output serialization -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- url params -->
				<xsl:param name="format" select="/request/parameters/parameter[name='format']/value"/>
				
				<xsl:template match="/">
					<format>
						<xsl:choose>
							<xsl:when test="$format = 'csv'">csv</xsl:when>
							<xsl:when test="$format = 'xml'">xml</xsl:when>
							<xsl:otherwise>json</xsl:otherwise>
						</xsl:choose>
					</format>
				</xsl:template>
				
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="format"/>
	</p:processor>
	
	<p:choose href="#source">
		<p:when test="source = 'solr'">
			<p:choose href="#format">
				<p:when test="format='csv'">
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../../views/serializations/solr/distribution-csv.xpl"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="format='xml'">
					<p:processor name="oxf:identity">
						<p:input name="data" href="#data"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../../views/serializations/solr/d3plus-json.xpl"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:when>
		<p:when test="source = 'nudsHoard'">
			<p:choose href="#format">
				<p:when test="format='csv'">
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../../views/serializations/nudsHoard/distribution-csv.xpl"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="format='xml'">
					<p:processor name="oxf:identity">
						<p:input name="data" href="#data"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../../views/serializations/nudsHoard/d3plus-json.xpl"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:when>
		<p:when test="source='sparql'">
			<p:choose href="#format">
				<p:when test="format='csv'">
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../../views/serializations/sparql/distribution-csv.xpl"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="format='xml'">
					<!-- output the aggregated SPARQL responses for the XML result: used to query the average axis, weight,
					and diameter for coin type pages when a local SPARQL (not Nomisma.org) endpoint is set in the Numishare config-->
					<p:processor name="oxf:identity">
						<p:input name="data" href="#data"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../../views/serializations/sparql/d3plus-json.xpl"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:when>
	</p:choose>
</p:config>
