<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
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
		</p:when>
		<p:when test="path='id'">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../object/rdf.xpl"/>		
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
		</p:when>
	</p:choose>
	
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="#xml"/>		
		<p:input name="config" href="../../../../ui/xslt/serializations/rdf/ttl.xsl"/>
		<p:output name="data" id="model"/>	
	</p:processor>

	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>text/turtle</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>