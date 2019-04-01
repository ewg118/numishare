<?xml version="1.0" encoding="UTF-8"?>
<!--
	Last Update: May 2018
	Function: submit a Solr query in order to generate a geographic query response to be serialized into KML, GeoJSON, or JSON for TimeMap	
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
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare">
				<xsl:include href="../../../ui/xslt/functions.xsl"/>
				<xsl:variable name="collection-name" select="if (/config/union_type_catalog/@enabled = true()) then concat('(', string-join(/config/union_type_catalog/series/@collectionName, '+OR+'), ')')  					else substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
				<!-- url params -->
				<xsl:param name="lang">
					<xsl:choose>
						<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='lang']/value)">
							<xsl:if test="//config/languages/language[@code=doc('input:request')/request/parameters/parameter[name='lang']/value][@enabled=true()]">
								<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
							</xsl:if>
						</xsl:when>
						<xsl:when test="string(doc('input:request')/request//header[name[.='accept-language']]/value)">
							<xsl:variable name="primaryLang" select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[.='accept-language']]/value)[1]"/>
							
							<xsl:if test="//config/languages/language[@code=$primaryLang][@enabled=true()]">
								<xsl:value-of select="$primaryLang"/>
							</xsl:if>
						</xsl:when>
					</xsl:choose>
				</xsl:param>				
				<xsl:param name="department" select="doc('input:request')/request/parameters/parameter[name='department']/value"/>
				<xsl:param name="q">
					<xsl:choose>
						<xsl:when test="string($department)">
							<xsl:value-of select="concat('department_facet:&#x022;', $department, '&#x022;')"/>
							<xsl:if test="string(doc('input:request')/request/parameters/parameter[name='q']/value)">
								<xsl:text> AND </xsl:text>
								<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
							</xsl:if>						
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:param>
				
				<xsl:param name="rows">10000</xsl:param>				
				
				<!-- facet variable -->
				<xsl:variable name="facet">
					<xsl:choose>
						<xsl:when test="matches(doc('input:request')/request/request-url, 'query\.(kml|geojson)')">mint_geo</xsl:when>
						<xsl:when test="matches(doc('input:request')/request/request-url, 'hoards\.(kml|geojson|json)')">findspot_geo</xsl:when>						
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="mode">
					<xsl:choose>
						<xsl:when test="matches(doc('input:request')/request/request-url, 'query\.(kml|geojson)')">query</xsl:when>
						<xsl:when test="matches(doc('input:request')/request/request-url, 'hoards\.(kml|geojson|json)')">hoard</xsl:when>						
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
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+', $facet, ':*+AND+', encode-for-uri($q), '&amp;facet=false&amp;fl=findspot_geo,recordId,title_display,taq_num,tpq_num,closing_date_display,deposit_maxint,deposit_minint,deposit_display&amp;rows=', $rows, '&amp;mode=', $mode)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+', $facet, ':*+AND+', encode-for-uri($q), '&amp;facet=false&amp;fl=findspot_geo,recordId,title_display,taq_num,tpq_num,closing_date_display,deposit_maxint,deposit_minint,deposit_display&amp;rows=', $rows, '&amp;mode=', $mode)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="string($lang)">
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+', $facet, ':*&amp;facet=false&amp;fl=findspot_geo,recordId,title_display,taq_num,tpq_num,closing_date_display,deposit_maxint,deposit_minint,deposit_display&amp;rows=', $rows, '&amp;mode=', $mode)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+', $facet, ':*&amp;facet=false&amp;fl=findspot_geo,recordId,title_display,taq_num,tpq_num,closing_date_display,deposit_maxint,deposit_minint,deposit_display&amp;rows=', $rows, '&amp;mode=', $mode)"/>
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
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+', $facet, ':*+AND+', encode-for-uri($q), '&amp;facet=false&amp;fl=title_display,mint_geo,findspot_geo_recordId&amp;rows=', $rows, '&amp;mode=', $mode)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+', $facet, ':*+AND+', encode-for-uri($q), '&amp;facet=false&amp;fl=title_display,mint_geo,findspot_geo_recordId&amp;rows=', $rows, '&amp;mode=', $mode)"/>
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
