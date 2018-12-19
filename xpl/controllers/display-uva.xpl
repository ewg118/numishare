<?xml version="1.0" encoding="UTF-8"?>

<!-- Author: Ethan Gruber
	Date: December 2018
	Function: This directs the original display-uva Cocoon pipeline from the first version of the project to the id/ namespace. The id request parameter
		is converted to the accession number -->

<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

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
		<p:input name="request" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				
				<xsl:variable name="id" select="upper-case(replace(replace(doc('input:request')/request/parameters/parameter[name='id']/value, 'n', ''), '_', '.'))"/>
				
				<xsl:template match="/">
					<redirect>
						<xsl:attribute name="uri">
							<xsl:choose>
								<xsl:when test="string(/config/uri_space)">
									<xsl:value-of select="concat(/config/uri_space, $id)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat(/config/url, 'id/', $id)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</redirect>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="redirect"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#redirect"/>
		<p:input name="config" href="303-redirect.xpl"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:pipeline>
