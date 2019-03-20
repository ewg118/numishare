<?xml version="1.0" encoding="UTF-8"?>
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
	
	<p:choose href="#format">
		<p:when test="format='csv'">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../../views/serializations/sparql/distribution-csv.xpl"/>	
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="format='xml'">
			<!-- output the aggregated SPARQL responses for the XML result -->
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
	
</p:config>
