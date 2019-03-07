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
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare">
				<xsl:include href="../../../ui/xslt/functions.xsl"/>
				<xsl:variable name="collection-name"
					select="if (/config/union_type_catalog/@enabled = true()) then concat('(', string-join(/config/union_type_catalog/series/@collectionName, '+OR+'), ')') 
					else substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
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
				<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
				<xsl:param name="sort" select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
				<xsl:param name="rows">0</xsl:param>
				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>
				<xsl:variable name="facets" select="concat('&amp;facet.field=', string-join(/config/facets/facet, '&amp;facet.field='))"/>

				<xsl:variable name="service">
					<!-- for compare pipeline, include imagesavailable:true in solr query -->
					<xsl:choose>
						<xsl:when test="contains(doc('input:request')/request/request-url, 'compare')">
							<xsl:choose>
								<!-- handle the value of the q parameter or pass *:* as a default when q is not specified -->
								<xsl:when test="string($lang)">
									<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+imagesavailable:true&amp;rows=0', $facets, '&amp;facet.limit=1')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+imagesavailable:true&amp;rows=0', $facets, '&amp;facet.limit=1')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="contains(doc('input:request')/request/request-url, 'visualize')">
							<xsl:choose>
								<xsl:when test="string($q)">
									<xsl:choose>
										<!-- handle the value of the q parameter or pass *:* as a default when q is not specified -->
										<xsl:when test="string($lang)">
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+', encode-for-uri($q), '&amp;rows=0', $facets, '&amp;facet.limit=1')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+', encode-for-uri($q), '&amp;rows=0', $facets, '&amp;facet.limit=1')"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<!-- handle the value of the q parameter or pass *:* as a default when q is not specified -->
										<xsl:when test="string($lang)">
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '&amp;rows=0', $facets, '&amp;facet.limit=1')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)&amp;rows=0', $facets, '&amp;facet.limit=1')"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>							
						</xsl:when>
						<xsl:otherwise>							
							<xsl:choose>
								<!-- handle the value of the q parameter or pass *:* as a default when q is not specified -->
								<xsl:when test="string($lang)">
									<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '&amp;rows=0', $facets, '&amp;facet.limit=1')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)&amp;rows=0', $facets, '&amp;facet.limit=1')"/>
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
