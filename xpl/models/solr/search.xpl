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
				<xsl:param name="sort" select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
				<xsl:param name="rows">0</xsl:param>
				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>
				

				<xsl:variable name="service">
					<xsl:choose>
						<!-- handle the value of the q parameter or pass *:* as a default when q is not specified -->
						<xsl:when test="string($lang)">
							<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '&amp;rows=0&amp;facet.field=artist_facet&amp;facet.field=authority_facet&amp;facet.field=citation_facet&amp;facet.field=coinType_facet&amp;facet.field=degree_facet&amp;facet.field=deity_facet&amp;facet.field=denomination_facet&amp;facet.field=department_facet&amp;facet.field=dynasty_facet&amp;facet.field=engraver_facet&amp;facet.field=era_facet&amp;facet.field=findspot_facet&amp;facet.field=grade_facet&amp;facet.field=institution_facet&amp;facet.field=issuer_facet&amp;facet.field=maker_facet&amp;facet.field=manufacture_facet&amp;facet.field=material_facet&amp;facet.field=mint_facet&amp;facet.field=objectType_facet&amp;facet.field=owner_facet&amp;facet.field=portrait_facet&amp;facet.field=reference_facet&amp;facet.field=region_facet&amp;facet.field=collection_facet&amp;facet.field=script_facet&amp;facet.field=state_facet&amp;facet.field=mint_geo&amp;facet.numFacetTerms=1')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)&amp;rows=0&amp;facet.field=artist_facet&amp;facet.field=authority_facet&amp;facet.field=citation_facet&amp;facet.field=coinType_facet&amp;facet.field=degree_facet&amp;facet.field=deity_facet&amp;facet.field=denomination_facet&amp;facet.field=department_facet&amp;facet.field=dynasty_facet&amp;facet.field=engraver_facet&amp;facet.field=era_facet&amp;facet.field=findspot_facet&amp;facet.field=grade_facet&amp;facet.field=institution_facet&amp;facet.field=issuer_facet&amp;facet.field=maker_facet&amp;facet.field=manufacture_facet&amp;facet.field=material_facet&amp;facet.field=mint_facet&amp;facet.field=objectType_facet&amp;facet.field=owner_facet&amp;facet.field=portrait_facet&amp;facet.field=reference_facet&amp;facet.field=region_facet&amp;facet.field=collection_facet&amp;facet.field=script_facet&amp;facet.field=state_facet&amp;facet.field=mint_geo&amp;facet.numFacetTerms=1')"/>
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
