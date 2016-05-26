<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: May 2016
	Function: This XPL enables the rendering of symbol image files via a faux proxy pipeline. The symbol images are stored in the symbols folder within the individual Numishare project directory
	
	-->

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

	<!-- create the directory scanner config -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-uri, '/')[last()]"/>
				<xsl:variable name="directory" select="concat('file:', /config/images/absolute_path, '/symbols')"/>

				<xsl:template match="/">
					<config>
						<base-directory>
							<xsl:value-of select="$directory"/>
						</base-directory>
						<include>
							<xsl:text>**/</xsl:text>
							<xsl:value-of select="$id"/>
							<xsl:text>.*</xsl:text>
						</include>
						<case-sensitive>true</case-sensitive>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="directory-config"/>
	</p:processor>

	<p:processor name="oxf:directory-scanner">
		<p:input name="config" href="#directory-config"/>
		<p:output name="data" id="directory-scan"/>
	</p:processor>

	<!-- generate HTML fragment to be returned -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#directory-scan"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="path" select="concat('file:', /directory/@path)"/>
				<xsl:variable name="ext" select="tokenize(//file[1]/@name, '\.')[last()]"/>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="concat($path, '/', //file[1]/@name)"/>
						</url>
						<mode>binary</mode>
						<content-type>
							<xsl:choose>
								<xsl:when test="$ext = 'png'">image/png</xsl:when>
							</xsl:choose>
						</content-type>
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
</p:pipeline>
