<?xml version="1.0" encoding="UTF-8"?>
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
	
	<!-- read request header for content-type -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<mode>
						<xsl:choose>
							<xsl:when test="/request/parameters/parameter[name='query']/value or /request/parameters/parameter[name='queries']/value">query</xsl:when>
							<xsl:otherwise>default</xsl:otherwise>
						</xsl:choose>
					</mode>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="mode"/>
	</p:processor>
	
	<p:choose href="#mode">
		<p:when test="mode = 'query'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../models/solr/openrefine-reconcile.xpl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>	
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../models/config.xpl"/>
				<p:output name="data" id="config"/>
			</p:processor>
			
			<!-- return default JSON response, generated from config -->
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../views/serializations/config/reconcile-json.xpl"/>
				<p:output name="data" ref="data"/>
			</p:processor>			
		</p:otherwise>		
	</p:choose>
</p:pipeline>
