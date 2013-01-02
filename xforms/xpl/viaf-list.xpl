<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ns2="http://viaf.org/viaf/terms#">
				<xsl:output method="xml" encoding="UTF-8"/>
				
				<xsl:template match="/">
					<list>
						<xsl:for-each select="descendant::*[local-name()='recordData']">
							<item href="http://viaf.org/viaf/{ns2:VIAFCluster/ns2:viafID}/">
								<xsl:value-of select="translate(descendant::ns2:mainHeadings/ns2:data/ns2:text[following-sibling::ns2:sources/ns2:s='LC'], '&#x98;&#x9C;', '')"/>
								<!--<xsl:value-of select="descendant::ns2:mainHeadings/ns2:data/ns2:text[following-sibling::ns2:sources/ns2:s='LC']"/>-->
							</item>
						</xsl:for-each>
					</list>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>

</p:config>
