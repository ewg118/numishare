<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date Modified: April 2020	
	Function: Read the URL or HTTP request headers in order to get the ID for the filename to load from eXist-db
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
					<xsl:choose>
						<!-- IIIF manifest generation -->
						<xsl:when test="contains(doc('input:request')/request/request-url, 'manifest/')">
							<xsl:variable name="pieces" select="tokenize(substring-after(doc('input:request')/request/request-url, 'manifest/'), '/')"/>
							<xsl:variable name="id">
								<xsl:choose>
									<xsl:when test="$pieces[1] = 'obverse' or $pieces[1] = 'reverse'">
										<xsl:value-of select="$pieces[2]"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$pieces[1]"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<config>
								<url>
									<xsl:value-of select="concat(/exist-config/url, $collection-name, '/objects/', $id, '.xml')"/>
								</url>
								<content-type>application/xml</content-type>
								<encoding>utf-8</encoding>
							</config>
						</xsl:when>
						<!-- handle id/ pipeline in the public interface -->
						<xsl:when test="contains(doc('input:request')/request/request-url, 'id/') or contains(doc('input:request')/request/request-url, 'map/')">							
							<xsl:variable name="doc" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
							<xsl:variable name="id">
								<xsl:choose>
									<xsl:when test="contains($doc, '.xml')">
										<xsl:value-of select="substring-before($doc, '.xml')"/>
									</xsl:when>
									<xsl:when test="contains($doc, '.rdf')">
										<xsl:value-of select="substring-before($doc, '.rdf')"/>
									</xsl:when>
									<xsl:when test="contains($doc, '.kml')">
										<xsl:value-of select="substring-before($doc, '.kml')"/>
									</xsl:when>
									<xsl:when test="contains($doc, '.solr')">
										<xsl:value-of select="substring-before($doc, '.solr')"/>
									</xsl:when>
									<xsl:when test="contains($doc, '.ttl')">
										<xsl:value-of select="substring-before($doc, '.ttl')"/>
									</xsl:when>
									<xsl:when test="contains($doc, '.json')">
										<xsl:value-of select="substring-before($doc, '.json')"/>
									</xsl:when>
									<xsl:when test="contains($doc, '.geojson')">
										<xsl:value-of select="substring-before($doc, '.geojson')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$doc"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<config>
								<url>
									<xsl:value-of select="concat(/exist-config/url, $collection-name, '/objects/', $id, '.xml')"/>
								</url>
								<content-type>application/xml</content-type>
								<encoding>utf-8</encoding>
							</config>
						</xsl:when>
						<xsl:otherwise>							
							<xsl:variable name="id" select="doc('input:request')/request/parameters/parameter[name='id']/value"/>
							<config>
								<url>
									<xsl:value-of select="concat(/exist-config/url, $collection-name, '/objects/', $id, '.xml')"/>
								</url>
								<content-type>application/xml</content-type>
								<encoding>utf-8</encoding>
							</config>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="generator-config"/>
	</p:processor>
	
	<!-- get the file from eXist -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
	
</p:config>
