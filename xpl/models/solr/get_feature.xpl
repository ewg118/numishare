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

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'numishare/'), '/')"/>
				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>
				

				<xsl:variable name="service">
					<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+imagesavailable:true&amp;facet.limit=1&amp;rows=0')"/>					
				</xsl:variable>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="feature-count-config"/>
	</p:processor>

	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#feature-count-config"/>
		<p:output name="data" id="numFound"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="aggregate('content', #numFound, #config)"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="http://exslt.org/math">
				<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'numishare/'), '/')"/>
				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/content/config/solr_published, 'select/')"/>
				<xsl:variable name="numFound" select="/content/response/result/@numFound"/>
				<xsl:variable name="start">
					<xsl:choose>
						<xsl:when test="$numFound = 0">0</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="floor(math:random()*$numFound) mod $numFound" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>				
				
				<xsl:variable name="service">
					<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+imagesavailable:true&amp;facet.limit=1&amp;rows=1&amp;start=', $start)"/>					
				</xsl:variable>
				
				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		
		<p:output name="data" id="get-feature-config"/>		
	</p:processor>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#get-feature-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
