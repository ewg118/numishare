<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: March 2019
	Function: Execute a Solr query or chain of Solr queries for distribution analyses to extract a JSON response for d3. 
	The Solr-based distribution analyses will eventually be deprecated by SPARQL	
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

	<!-- add in compare queries -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- request parameters -->
				<xsl:param name="compare" select="/request/parameters/parameter[name='compare']/value"/>

				<xsl:template match="/">
					<queries>
						<xsl:choose>
							<xsl:when test="contains($compare, '|')">
								<xsl:for-each select="tokenize($compare, '\|')">
									<query>
										<xsl:value-of select="normalize-space(.)"/>
									</query>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<query>
									<xsl:value-of select="normalize-space($compare)"/>
								</query>
							</xsl:otherwise>
						</xsl:choose>

					</queries>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="compare-queries"/>
	</p:processor>

	<!-- when there is at least one compare query, then aggregate the compare queries with the primary query into one model -->
	<p:for-each href="#compare-queries" select="//query" root="aggregate" id="solr-results">
		<p:processor name="oxf:unsafe-xslt">
			<p:input name="query" href="current()"/>
			<p:input name="request" href="#request"/>
			<p:input name="data" href="#config"/>
			<p:input name="config">
				<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
					xmlns:numishare="https://github.com/ewg118/numishare">
					<xsl:include href="../../../ui/xslt/functions.xsl"/>

					<xsl:variable name="collection-name"
						select="if (/config/union_type_catalog/@enabled = true()) then concat('(', string-join(/config/union_type_catalog/series/@collectionName, '+OR+'), ')')  					else substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>

					<!-- request parameters -->
					<xsl:param name="q" select="doc('input:query')/query"/>
					
					<xsl:param name="lang">
						<xsl:choose>
							<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='lang']/value)">
								<xsl:if
									test="//config/languages/language[@code=doc('input:request')/request/parameters/parameter[name='lang']/value][@enabled=true()]">
									<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
								</xsl:if>
							</xsl:when>
							<xsl:when test="string(doc('input:request')/request//header[name[.='accept-language']]/value)">
								<xsl:variable name="primaryLang"
									select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[.='accept-language']]/value)[1]"/>

								<xsl:if test="//config/languages/language[@code=$primaryLang][@enabled=true()]">
									<xsl:value-of select="$primaryLang"/>
								</xsl:if>
							</xsl:when>
						</xsl:choose>
					</xsl:param>
					<xsl:param name="category" select="doc('input:request')/request/parameters/parameter[name='category']/value"/>

					<!-- config variables -->
					<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>

					<xsl:variable name="service">
						<xsl:choose>
							<xsl:when test="string($lang)">
								<xsl:value-of
									select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+', encode-for-uri($q), '&amp;facet=true&amp;rows=0&amp;facet.field=', $category, '&amp;facet.sort=index&amp;compare=', encode-for-uri($q))"
								/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+', encode-for-uri($q), '&amp;facet=true&amp;rows=0&amp;facet.field=', $category, '&amp;facet.sort=index&amp;compare=', encode-for-uri($q))"
								/>
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
			<p:output name="data" id="compare-url-generator-config"/>
		</p:processor>

		<!-- get the data from fuseki -->
		<p:processor name="oxf:url-generator">
			<p:input name="config" href="#compare-url-generator-config"/>
			<p:output name="data" ref="solr-results"/>
		</p:processor>
	</p:for-each>

	<p:processor name="oxf:identity">
		<p:input name="data" href="#solr-results"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
