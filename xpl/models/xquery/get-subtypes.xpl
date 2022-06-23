<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: June 2022
	Function: Call the get-subtypes XQuery file that is stored in eXist-db	
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
		<p:input name="data" href="oxf:/apps/numishare/exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
					
					<!-- get identifiers from request parameter for the batch Solr serialization, otherwise get the ID from URL sequence -->
					<xsl:variable name="identifiers">
						<xsl:choose>
							<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='identifiers']/value)">
								<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='identifiers']/value"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="tokenize(doc('input:request')/request/request-uri, '/')[last()]"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:variable name="identifiers-clean" select="string-join(tokenize($identifiers, '\|')[string-length(.) &gt; 0], '|')"/>
					
					<config>
						<url>
							<xsl:value-of select="concat(/exist-config/url, $collection-name, '/get-subtypes.xql?identifiers=', encode-for-uri($identifiers-clean))"/>
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
