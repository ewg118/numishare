<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/config">
					<config>
						<base-directory>
							<xsl:value-of select="concat('file:', symbol_path)"/>
						</base-directory>
						<include>							
							<xsl:value-of select="id"/>
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

	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="#directory-scan"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">				
				<xsl:variable name="path" select="concat('file:', /directory/@path)"/>

				<xsl:template match="/">
					<config>
						<delete>
							<url>
								<xsl:value-of select="concat($path, '/', //file[1]/@name)"/>
							</url>
						</delete>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="delete-config"/>
	</p:processor>

	<p:processor name="oxf:file">
		<p:input name="config" href="#delete-config"/>
	</p:processor>

	<p:processor name="oxf:xml-serializer">
		<p:input name="data" href="#delete-config"/>
		<p:input name="config">
			<config>
				<content-type>application/xml</content-type>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:pipeline>
