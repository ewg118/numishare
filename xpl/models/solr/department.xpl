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
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'numishare/'), '/')"/>
				<xsl:variable name="department" select="substring-after(doc('input:request')/request/request-url, 'department/')"/>
				<xsl:variable name="department_facet">
					<xsl:choose>
						<xsl:when test="$department = 'UnitedStates'">
							<xsl:text>United States</xsl:text>
						</xsl:when>
						<xsl:when test="$department = 'EastAsian'">
							<xsl:text>East Asian</xsl:text>
						</xsl:when>
						<xsl:when test="$department = 'SouthAsian'">
							<xsl:text>South Asian</xsl:text>
						</xsl:when>
						<xsl:when test="$department = 'LatinAmerica'">
							<xsl:text>Latin American</xsl:text>
						</xsl:when>
						<xsl:when test="$department = 'MedalsAndDecorations'">
							<xsl:text>Medal</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$department"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- url params -->
				<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
				<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>
				<xsl:variable name="facets" select="concat('&amp;facet.field=', string-join(/config/facets/facet, '&amp;facet.field='), '&amp;facet.field=axis_num')"/>

				<xsl:variable name="service">
					<!-- for compare pipeline, include imagesavailable:true in solr query -->
					<xsl:choose>
						<!-- handle the value of the q parameter or pass *:* as a default when q is not specified -->
						<xsl:when test="string($lang)">
							<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+department_facet:', encode-for-uri(concat('&#x022;', $department_facet, '&#x022;')), '&amp;rows=0', $facets, '&amp;facet.numFacetTerms=1')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+department_facet:', encode-for-uri(concat('&#x022;', $department_facet, '&#x022;')), '&amp;rows=0', $facets, '&amp;facet.numFacetTerms=1')"/>
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
