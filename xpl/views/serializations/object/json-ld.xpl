<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: Last modified July 2018
	Function: Determine	the correct pipeline to serialize RDF/XML into JSON-LD for the the symbol or default jsonld pipeline (Nomisma data model), or 
	call an XSLT transformation for NUDS->JSON-LD for linked.art data model
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
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">				
				<xsl:variable name="path" select="tokenize(/request/request-uri, '/')[last()-1]"/>
				
				
				<xsl:template match="/">
					<path>
						<xsl:value-of select="$path"/>
					</path>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="path"/>
	</p:processor>
	
	<p:choose href="#path">		
		<p:when test="path='symbol'">
			<p:processor name="oxf:identity">
				<p:input name="data" href="#data"/>
				<p:output name="data" id="xml"/>				
			</p:processor>
			
			<p:processor name="oxf:unsafe-xslt">		
				<p:input name="data" href="#xml"/>		
				<p:input name="config" href="../../../../ui/xslt/serializations/rdf/json-ld.xsl"/>
				<p:output name="data" id="model"/>	
			</p:processor>
			
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#model"/>
				<p:input name="config">
					<config>
						<content-type>application/ld+json</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="path='id'">
			
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#request"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">				
						<xsl:variable name="profile" select="/request/parameters/parameter[name='profile']/value"/>
						
						
						<xsl:template match="/">
							<profile>
								<xsl:value-of select="$profile"/>
							</profile>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="profile"/>
			</p:processor>
			
			<p:choose href="#profile">		
				<p:when test="profile='linkedart'">
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../nuds/linkedart-json-ld.xpl"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="rdf.xpl"/>		
						<p:output name="data" id="doc"/>		
					</p:processor>
					
					<!-- document needs to be parsed back into application/xml -->	
					<p:processor name="oxf:unsafe-xslt">		
						<p:input name="data" href="#doc"/>		
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/">
								<xsl:template match="/">
									<xsl:copy-of select="saxon:parse(/document)/*"/>
								</xsl:template>				
							</xsl:stylesheet>
						</p:input>
						<p:output name="data" id="xml"/>	
					</p:processor>
					
					<p:processor name="oxf:unsafe-xslt">		
						<p:input name="data" href="#xml"/>		
						<p:input name="config" href="../../../../ui/xslt/serializations/rdf/json-ld.xsl"/>
						<p:output name="data" id="model"/>	
					</p:processor>
					
					<p:processor name="oxf:text-converter">
						<p:input name="data" href="#model"/>
						<p:input name="config">
							<config>
								<content-type>application/ld+json</content-type>
								<encoding>utf-8</encoding>
							</config>
						</p:input>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:when>
	</p:choose>
	
	
</p:config>