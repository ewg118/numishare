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
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<!-- read request parameters to determine the type of response -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:variable name="collection-name" select="if (/config/union_type_catalog/@enabled = true()) then concat('(', string-join(/config/union_type_catalog/series/@collectionName, '+OR+'), ')')  					else substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
				
				<xsl:param name="prefix" select="doc('input:request')/request/parameters/parameter[name='prefix']/value"/>
				<xsl:param name="limit"
					select="if (doc('input:request')/request/parameters/parameter[name='limit']/value castable as xs:integer) then doc('input:request')/request/parameters/parameter[name='limit']/value else 20"/>
				<xsl:param name="start"
					select="if (doc('input:request')/request/parameters/parameter[name='start']/value castable as xs:integer) then doc('input:request')/request/parameters/parameter[name='start']/value else 0"/>

				<xsl:variable name="fq">
					<xsl:if test="doc('input:request')/request/parameters/parameter[name='type']">
						<xsl:variable name="operator" select="if (doc('input:request')/request/parameters/parameter[name='type_strict']/value = 'all') then 'AND' else 'OR'"/>
						
						<xsl:text>type:(</xsl:text>
						<xsl:for-each select="doc('input:request')/request/parameters/parameter[name='type']/value">
							<xsl:value-of select="concat('&#x022;', ., '&#x022;')"/>
							<xsl:if test="not(position() = last())">
								<xsl:value-of select="concat(' ', $operator, ' ')"/>
							</xsl:if>
						</xsl:for-each>						
						<xsl:text>)</xsl:text>
					</xsl:if>
				</xsl:variable>

				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr_published, 'feed/')"/>
				<xsl:variable name="service"
					select="concat($solr-url, '?q=fulltext:', encode-for-uri($prefix), '+AND+collection-name:', $collection-name, '+AND+NOT(lang:*)&amp;fl=recordId,title_display,recordType&amp;rows=', $limit, '&amp;start=', $start, if (string($fq)) then concat('&amp;fq=', encode-for-uri($fq)) else '')"/>

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
		<p:output name="data" id="url-generator-config"/>
	</p:processor>

	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:pipeline>
