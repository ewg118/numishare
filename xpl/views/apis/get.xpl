<?xml version="1.0" encoding="UTF-8"?>
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
				<xsl:template match="/">
					<format>
						<xsl:value-of select="/request/parameters/parameter[name='format']/value"/>
					</format>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="format-config"/>
	</p:processor>

	<p:choose href="#format-config">
		<p:when test="format='json'">
			<p:processor name="oxf:pipeline">				
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../serializations/object/timemap-json.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="format='kml'">
			<p:processor name="oxf:pipeline">				
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../serializations/object/kml.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="format='rdf'">
			<p:processor name="oxf:pipeline">				
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../serializations/object/rdf.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:identity">
				<p:input name="data">
					<error>Format URL parameter not declared or not valid</error>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>
