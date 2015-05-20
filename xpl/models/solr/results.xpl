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
				<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
				<!-- url params -->
				<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
				<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
				<xsl:param name="sort" select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
				<xsl:param name="rows">20</xsl:param>
				<xsl:param name="start">
					<xsl:choose>
						<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='start']/value)">
							<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='start']/value"/>
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:param>

				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>
				<xsl:variable name="facets" select="concat('&amp;facet.field=', string-join(/config/facets/facet, '&amp;facet.field='))"/>
				
				<!-- set field filters dependent on the type of collection -->
				<xsl:variable name="fl">
					<xsl:choose>
						<xsl:when test="/config/collection_type = 'hoard'">id,recordId,recordType,title_display,findspot_display,closing_date_display,description_display,reference_facet</xsl:when>
						<xsl:when test="/config/collection_type = 'cointype'">id,recordId,recordType,title_display,date_display,denomination_facet,mint_facet,obv_leg_display,obv_type_display,rev_leg_display,rev_type_display,reference_facet</xsl:when>
						<xsl:when test="/config/collection_type = 'object'">id,recordId,recordType,title_display,date_display,denomination_facet,mint_facet,obv_leg_display,obv_type_display,rev_leg_display,rev_type_display,reference_facet,provenance_facet,diameter_num,weight_num</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="service">
					<xsl:choose>
						<!-- handle the value of the q parameter or pass *:* as a default when q is not specified -->
						<xsl:when test="string($q)">
							<xsl:choose>
								<xsl:when test="string($lang)">
									<xsl:choose>
										<xsl:when test="string($sort)">
											<xsl:value-of
												select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+', encode-for-uri($q), '&amp;start=', $start, $facets, '&amp;facet.field=mint_geo&amp;facet.field=findspot_geo&amp;facet.limit=1&amp;facet.sort=index&amp;facet=true', '&amp;sort=', encode-for-uri($sort), '&amp;fl=', $fl)"
											/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+', encode-for-uri($q), '&amp;start=', $start, $facets, '&amp;facet.field=mint_geo&amp;facet.field=findspot_geo&amp;facet.limit=1&amp;facet.sort=index&amp;facet=true&amp;sort=sortid+asc&amp;fl=', $fl)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="string($sort)">
											<xsl:value-of
												select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+', encode-for-uri($q), '&amp;start=', $start, $facets, '&amp;facet.field=mint_geo&amp;facet.field=findspot_geo&amp;facet.limit=1&amp;facet.sort=index&amp;facet=true', '&amp;sort=', encode-for-uri($sort), '&amp;fl=', $fl)"
											/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+', encode-for-uri($q), '&amp;start=', $start, $facets, '&amp;facet.field=mint_geo&amp;facet.field=findspot_geo&amp;facet.limit=1&amp;facet.sort=index&amp;facet=true&amp;sort=sortid+asc&amp;fl=', $fl)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>							
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="string($lang)">
									<xsl:choose>
										<xsl:when test="string($sort)">
											<xsl:value-of
												select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+*:*&amp;start=', $start, $facets, '&amp;facet.field=mint_geo&amp;facet.field=findspot_geo&amp;facet.limit=1&amp;facet.sort=index&amp;facet=true', '&amp;sort=', encode-for-uri($sort), '&amp;fl=', $fl)"
											/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+*:*&amp;start=', $start, $facets, '&amp;facet.field=mint_geo&amp;facet.field=findspot_geo&amp;facet.limit=1&amp;facet.sort=index&amp;facet=true&amp;fl=', $fl)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="string($sort)">
											<xsl:value-of
												select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+*:*&amp;start=', $start, $facets, '&amp;facet.field=mint_geo&amp;facet.field=findspot_geo&amp;facet.limit=1&amp;facet.sort=index&amp;facet=true', '&amp;sort=', encode-for-uri($sort), '&amp;fl=', $fl)"
											/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+*:*&amp;start=', $start, $facets, '&amp;facet.field=mint_geo&amp;facet.field=findspot_geo&amp;facet.limit=1&amp;facet.sort=index&amp;facet=true&amp;fl=', $fl)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
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
		<p:output name="data" id="generator-config"/>
	</p:processor>

	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
