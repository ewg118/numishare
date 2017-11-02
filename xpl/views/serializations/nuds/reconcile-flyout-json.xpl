<?xml version="1.0" encoding="UTF-8"?>
<!--
	Return the flyout service with ?id parameter for Open Refine reconciliation	
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
		<p:input name="data" href="#data"/>
		<p:input name="config" href="../../../../ui/xslt/serializations/nuds/reconcile-flyout-json.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>
	
	<!-- determine whether callback param exists -->
	<p:choose href="#request">
		<p:when test="/request/parameters/parameter[name='callback']">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#request"/>
				<p:input name="json" href="#model"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
						<!-- url params -->
						<xsl:param name="callback" select="/request/parameters/parameter[name='callback']/value"/>
						<xsl:variable name="json" select="doc('input:json')"/>
						
						<xsl:template match="/">
							<xsl:value-of select="concat($callback, '(', $json, ')')"/>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="jsonp"/>
			</p:processor>
			
			<p:processor name="oxf:html-converter">
				<p:input name="data" href="#jsonp"/>
				<p:input name="config">
					<config>
						<version>4.0</version>
						<indent>true</indent>
						<content-type>text/html</content-type>
						<encoding>utf-8</encoding>
						<indent-amount>4</indent-amount>
					</config>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>		
		<p:otherwise>
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
		</p:otherwise>
	</p:choose>
</p:config>
