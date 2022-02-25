<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date Modified: April 2020
	Function: Read the compare URL parameter(s), execute lookup for each hoard file in the eXist-db (compare HTTP request parameter), 
	and then process the results based on the distribution parameter and numeric response type (type parameter)
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

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
	<p:for-each href="#compare-queries" select="//query" root="response" id="response">
		
		<!-- use the compare HTTP parameter to load the file from eXist-db -->		
		<p:processor name="oxf:unsafe-xslt">
			<p:input name="request" href="#request"/>
			<p:input name="id" href="current()"/>
			<p:input name="data" href="oxf:/apps/numishare/exist-config.xml"/>
			<p:input name="config">
				<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
					<xsl:output indent="yes"/>
					<xsl:template match="/">						
						<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
						<xsl:variable name="id" select="string(doc('input:id'))"/>
						
						<config>
							<url>
								<xsl:value-of select="concat(/exist-config/url, $collection-name, '/objects/', $id, '.xml')"/>
							</url>
							<content-type>application/xml</content-type>
							<encoding>utf-8</encoding>
						</config>
					</xsl:template>
				</xsl:stylesheet>
			</p:input>
			<p:output name="data" id="hoard-generator-config"/>
		</p:processor>
		
		<!-- get the file from eXist -->
		<p:processor name="oxf:url-generator">
			<p:input name="config" href="#hoard-generator-config"/>
			<p:output name="data" id="hoard-xml"/>
		</p:processor>
		
		<!-- serialize the NUDS Hoard file into the XML metamodel that represents the distribution analysis (the full result of which is serialized into JSON for d3js later) -->
		<p:processor name="oxf:unsafe-xslt">
			<p:input name="request" href="#request"/>
			<p:input name="data" href="#hoard-xml"/>		
			<p:input name="config" href="../../ui/xslt/controllers/nudsHoard-to-distribution-metamodel.xsl"/>
			<p:output name="data" ref="response"/>
		</p:processor>
	</p:for-each>
	
	<p:processor name="oxf:identity">
		<p:input name="data" href="#response"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
