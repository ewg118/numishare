<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date modified: January 2022
	Function: load the exist-config.xml file from the primary numishare installation via oxf: rather than a relative path to avoid changing the port number or URL
	in branch projects
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
				<xsl:template match="/">
					<xsl:variable name="collection-name">
						<xsl:choose>
							<xsl:when test="contains(doc('input:request')/request/request-uri, 'admin/')">
								<xsl:value-of select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/admin/'), '/')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>	

					<config>
						<url>
							<xsl:value-of select="concat(/exist-config/url, $collection-name, '/config.xml')"/>
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
