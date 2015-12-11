<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	
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
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/config.xpl"/>		
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="../../../../exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="concat(/exist-config/url, 'collections-list.xml')"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="collections-list-generator-config"/>
	</p:processor>
	
	<!-- attempt to load the collections-list XML file from eXist. If it does not exist, then it has not been created (first run) -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#collections-list-generator-config"/>
		<p:output name="data" id="collections-list"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../get-authentication.xpl"/>		
		<p:output name="data" id="auth"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>		
		<p:input name="auth" href="#auth"/>		
		<p:input name="data" href="aggregate('content', #data, #config, #collections-list)"/>		
		<p:input name="config" href="../../../../ui/xslt/serializations/solr/html.xsl"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
