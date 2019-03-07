<?xml version="1.0" encoding="UTF-8"?>
<!--
	Perform a Solr query to extract a random doc for the featured object on the index page	
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
	
	<!-- execute a Solr query to extract the number of documents found in the index at the given language, provided by URL parameter or Accept header (default English) -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare">
				<xsl:include href="../../../ui/xslt/functions.xsl"/>
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
				<xsl:variable name="collection-name" select="if (/config/union_type_catalog/@enabled = true()) then concat('(', string-join(/config/union_type_catalog/series/@collectionName, '+OR+'), ')')  					else substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
				
				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>
				
				
				<xsl:variable name="service">
					<xsl:choose>
						<xsl:when test="string($lang)">
							<xsl:value-of
								select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+imagesavailable:true&amp;facet=false&amp;rows=0')"
							/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+imagesavailable:true&amp;facet=false&amp;rows=0')"
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
		<p:output name="data" id="feature-count-config"/>
	</p:processor>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#feature-count-config"/>
		<p:output name="data" id="numFound"/>
	</p:processor>
	
	<!-- only take action if there are records -->
	<p:choose href="#numFound">
		<p:when test="number(//result[@name='response']/@numFound) &gt; 0">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="numFound" href="#numFound"/>
				<p:input name="data" href="#config"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare"
						xmlns:math="http://exslt.org/math">
						<xsl:include href="../../../ui/xslt/functions.xsl"/>
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
						<xsl:variable name="collection-name"
							select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
						
						<!-- config variables -->
						<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>
						<xsl:variable name="numFound" select="doc('input:numFound')/response/result/@numFound"/>
						
						<!-- generate a random number between 0 and $numFound -->
						<xsl:variable name="start" select="floor(math:random()*$numFound) mod $numFound"/>
						
						<xsl:variable name="service">
							<xsl:choose>
								<xsl:when test="string($lang)">
									<xsl:value-of
										select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+imagesavailable:true&amp;facet=false&amp;rows=1&amp;start=', $start)"
									/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+imagesavailable:true&amp;facet=false&amp;rows=1&amp;start=', $start)"
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
				<p:output name="data" id="get-feature-config"/>
			</p:processor>
			
			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#get-feature-config"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<!-- return the empty Solr response from the first query if numFound = 0 -->
			<p:processor name="oxf:identity">
				<p:input name="data" href="#numFound"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>