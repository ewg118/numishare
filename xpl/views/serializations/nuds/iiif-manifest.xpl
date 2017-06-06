<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2017 Ethan Gruber
	Numishare
	Apache License 2.0
	
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
		<p:input name="config" href="../../../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<recordType>
						<xsl:choose>							
							<xsl:when test="*/@recordType='conceptual'">conceptual</xsl:when>
							<xsl:when test="*/@recordType='physical'">physical</xsl:when>
						</xsl:choose>
					</recordType>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="recordType"/>
	</p:processor>
	
	<p:choose href="#recordType">		
		<!-- if it is a coin type record, then execute an ASK query -->
		<p:when test="recordType='conceptual'">
			<!--<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../../../models/sparql/ask-types.xpl"/>
				<p:output name="data" id="hasTypes"/>
			</p:processor>-->
			
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="aggregate('content', #data, #config)"/>
				<p:input name="config" href="../../../../ui/xslt/serializations/nuds/iiif-manifest.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:when>
		<p:otherwise>	
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="aggregate('content', #data, #config)"/>
				<p:input name="config" href="../../../../ui/xslt/serializations/nuds/iiif-manifest.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/json</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
