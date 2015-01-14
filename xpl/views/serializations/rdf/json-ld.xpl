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
</p:config>