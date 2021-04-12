<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Last modified: April 2021
	Function: Transform EpiDoc TEI into HTML
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:saxon="http://saxon.sf.net/">
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
		<p:input name="config" href="../../../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="aggregate('content', #data, #config)"/>
		<p:input name="config" href="../../../../ui/xslt/serializations/tei/html.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>
	
	
	<!-- prepare the HTML model to be piped through the HTTP serializer -->
	<!--<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output name="html" encoding="UTF-8" method="html" indent="yes" omit-xml-declaration="yes" doctype-system="HTML"/>
				
				<xsl:template match="/">
					<xml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema"
						content-type="text/html">
						<xsl:value-of select="saxon:serialize(/html, 'html')"/>
					</xml>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="converted"/>
	</p:processor>
	
	<!-\- generate config for http-serializer -\->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#config"/>
		<p:input name="request" href="#request"/>
		<p:input name="config" href="../../../../ui/xslt/controllers/http-headers.xsl"/>
		<p:output name="data" id="serializer-config"/>
	</p:processor>
	
	<p:processor name="oxf:http-serializer">
		<p:input name="data" href="#converted"/>
		<p:input name="config" href="#serializer-config"/>
	</p:processor>-->
	
	<p:processor name="oxf:html-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<version>5.0</version>
				<indent>true</indent>
				<content-type>text/html</content-type>
				<encoding>utf-8</encoding>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
