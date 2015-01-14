<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
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
		<p:input name="config" href="../../models/config.xpl"/>		
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:param name="format" select="/request/parameters/parameter[name='format']/value"/>

				<xsl:template match="/">
					<format>
						<xsl:choose>
							<xsl:when test="$format='json'">text</xsl:when>
							<xsl:otherwise>xml</xsl:otherwise>
						</xsl:choose>
					</format>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="serializer-config"/>
	</p:processor>

	<p:processor name="oxf:xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="aggregate('content', #data, #config)"/>
		<p:input name="config" href="../../../ui/xslt/apis/get.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>

	<p:choose href="#serializer-config">
		<p:when test="format='text'">
			<p:processor name="oxf:text-serializer">
				<p:input name="data" href="#model"/>
				<p:input name="config">
					<config>
						<content-type>application/json</content-type>
					</config>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:xml-serializer">
				<p:input name="data" href="#model"/>
				<p:input name="config">
					<config>
						<content-type>application/xml</content-type>
					</config>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>
