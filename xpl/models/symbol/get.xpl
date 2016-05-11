<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	
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
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
					<xsl:variable name="doc" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
					<xsl:variable name="id">
						<xsl:choose>									
							<xsl:when test="contains($doc, '.rdf')">
								<xsl:value-of select="substring-before($doc, '.rdf')"/>
							</xsl:when>
							<xsl:when test="contains($doc, '.ttl')">
								<xsl:value-of select="substring-before($doc, '.ttl')"/>
							</xsl:when>
							<xsl:when test="contains($doc, '.jsonld')">
								<xsl:value-of select="substring-before($doc, '.jsonld')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$doc"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<config>
						<url>
							<xsl:value-of select="concat(/exist-config/url, $collection-name, '/symbols/', $id, '.rdf')"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="generator-config"/>
	</p:processor>
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
