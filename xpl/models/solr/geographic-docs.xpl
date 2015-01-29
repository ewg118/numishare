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
				<!-- url params -->
				<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
				<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
				<xsl:param name="rows">10000</xsl:param>
				
				<!-- facet variable -->
				<xsl:variable name="facet">
					<xsl:choose>
						<xsl:when test="contains(doc('input:request')/request/request-url, 'query.kml')">mint_geo</xsl:when>
						<xsl:when test="contains(doc('input:request')/request/request-url, 'hoards.kml')">findspot_geo</xsl:when>
						<xsl:when test="contains(doc('input:request')/request/request-url, 'hoards.json')">findspot_geo</xsl:when>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="mode">
					<xsl:choose>
						<xsl:when test="contains(doc('input:request')/request/request-url, 'query.kml')">query</xsl:when>
						<xsl:when test="contains(doc('input:request')/request/request-url, 'hoards.kml')">hoard</xsl:when>
						<xsl:when test="contains(doc('input:request')/request/request-url, 'hoards.json')">hoard</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>

				<xsl:variable name="service">
					<xsl:choose>
						<xsl:when test="$mode='hoard'">
							<xsl:choose>
								<xsl:when test="string($q)">
									<xsl:choose>
										<xsl:when test="string($lang)">
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+', $facet, ':*+AND+', encode-for-uri($q), '&amp;facet=false&amp;fl=findspot_geo,recordId,title_display,taq_num,tpq_num,closing_date_display&amp;rows=', $rows, '&amp;mode=', $mode)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+', $facet, ':*+AND+', encode-for-uri($q), '&amp;facet=false&amp;fl=findspot_geo,recordId,title_display,taq_num,tpq_num,closing_date_display&amp;rows=', $rows, '&amp;mode=', $mode)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="string($lang)">
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+', $facet, ':*&amp;facet=false&amp;fl=findspot_geo,recordId,title_display,taq_num,tpq_num,closing_date_display&amp;rows=', $rows, '&amp;mode=', $mode)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+', $facet, ':*&amp;facet=false&amp;fl=findspot_geo,recordId,title_display,taq_num,tpq_num,closing_date_display&amp;rows=', $rows, '&amp;mode=', $mode)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="string($q)">
									<xsl:choose>
										<xsl:when test="string($lang)">
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+', $facet, ':*+AND+', encode-for-uri($q), '&amp;facet=false&amp;rows=', $rows, '&amp;mode=', $mode)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+', $facet, ':*+AND+', encode-for-uri($q), '&amp;facet=false&amp;rows=', $rows, '&amp;mode=', $mode)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="string($lang)">
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+', $facet, ':*&amp;facet=false&amp;rows=', $rows, '&amp;mode=', $mode)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+', $facet, ':*&amp;facet=false&amp;rows=', $rows, '&amp;mode=', $mode)"/>
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
