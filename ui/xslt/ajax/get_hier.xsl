<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../functions.xsl"/>
	<!-- globals -->
	<xsl:variable name="solr-url" select="concat(/content/config/solr_published, 'select/')"/>
	<xsl:variable name="collection-name"
		select="
			if (//config/union_type_catalog/@enabled = true()) then
				concat('(', string-join(//config/union_type_catalog/series/@collectionName, '+OR+'), ')')
			else
				substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
	<xsl:variable name="request-uri"
		select="
			concat('http://localhost:', if (//config/server-port castable as xs:integer) then
				//config/server-port
			else
				'8080', substring-before(doc('input:request')/request/request-uri, 'get_hier'))"/>


	<!-- solr query parameters -->
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name = 'q']/value"/>
	<xsl:param name="field" select="doc('input:request')/request/parameters/parameter[name = 'field']/value"/>
	<xsl:param name="prefix" select="doc('input:request')/request/parameters/parameter[name = 'prefix']/value"/>
	<xsl:param name="fq" select="doc('input:request')/request/parameters/parameter[name = 'fq']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string(doc('input:request')/request/parameters/parameter[name = 'lang']/value)">
				<xsl:if test="//config/languages/language[@code = doc('input:request')/request/parameters/parameter[name = 'lang']/value][@enabled = true()]">
					<xsl:value-of select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[. = 'accept-language']]/value)">
				<xsl:variable name="primaryLang"
					select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[. = 'accept-language']]/value)[1]"/>

				<xsl:if test="//config/languages/language[@code = $primaryLang][@enabled = true()]">
					<xsl:value-of select="$primaryLang"/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:param>

	<!-- output modes -->
	<xsl:param name="link" select="doc('input:request')/request/parameters/parameter[name = 'link']/value"/>

	<xsl:template match="/">
		<html>
			<head>
				<title/>
			</head>
			<body>

				<ul id="root">
					<xsl:apply-templates select="//lst[@name = concat($field, '_hier')]"/>
				</ul>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="lst[@name = concat($field, '_hier')]">
		<xsl:choose>
			<xsl:when test="count(int) = 0">
				<option disabled="disabled">No options available</option>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="int[starts-with(@name, $prefix)]">
					<xsl:variable name="label" select="substring-before(substring-after(@name, '|'), '/')"/>
					<xsl:variable name="next-prefix" select="substring-after(@name, '/')"/>
					<xsl:variable name="next-prefix-count">
						<xsl:choose>
							<xsl:when test="string($lang)">
								<xsl:value-of
									select="count(document(concat($solr-url, '?q=collection-name:', $collection-name, '+AND+lang:', $lang, '+AND+', if (string($q)) then encode-for-uri($q) else '*:*', '&amp;rows=0&amp;facet.field=', $field, '_hier&amp;fq=collection-name:', $collection-name, '+AND+', $field, '_hier:%22', encode-for-uri(@name), '%22&amp;facet.prefix=', $next-prefix))//lst[@name='facet_fields']/lst[@name=concat($field, '_hier')]/int)"
								/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="count(document(concat($solr-url, '?q=collection-name:', $collection-name, '+AND+NOT(lang:*)+AND+', if (string($q)) then encode-for-uri($q) else '*:*', '&amp;rows=0&amp;facet.field=', $field, '_hier&amp;fq=collection-name:', $collection-name, '+AND+', $field, '_hier:%22', encode-for-uri(@name), '%22&amp;facet.prefix=', $next-prefix))//lst[@name='facet_fields']/lst[@name=concat($field, '_hier')]/int)"
								/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<li>
						<xsl:if test="$next-prefix-count &gt; 0">
							<xsl:variable name="starter-space" select="
									if (contains(@name, 'L1|')) then
										''
									else
										' '"/>
							<span class="expand_category glyphicon glyphicon-{if (contains($q, @name)) then 'minus' else 'plus'}"
								id="{replace(@name, ' ', '_')}__{$field}" field="{$field}" q="{$q}" next-prefix="{$next-prefix}"
								link="{concat($link, $starter-space, '+&#x022;', @name, '&#x022;')}"/>
						</xsl:if>

						<!-- figure out problem with labels not updating on findspot city selection -->

						<xsl:choose>
							<xsl:when test="contains($q, @name)">
								<input type="checkbox" value="{@name}" checked="checked" field="{$field}">
									<xsl:if test="$next-prefix-count = 0">
										<xsl:attribute name="style">margin-left:12px;</xsl:attribute>
									</xsl:if>
								</input>
							</xsl:when>
							<xsl:otherwise>
								<input type="checkbox" value="{@name}" field="{$field}">
									<xsl:if test="$next-prefix-count = 0">
										<xsl:attribute name="style">margin-left:12px;</xsl:attribute>
									</xsl:if>
								</input>
							</xsl:otherwise>
						</xsl:choose>

						<xsl:value-of select="$label"/>

						<xsl:if test="$next-prefix-count &gt; 0">
							<xsl:choose>
								<xsl:when test="contains($q, @name)">
									<xsl:variable name="starter-space"
										select="
											if (contains(@name, 'L1|')) then
												''
											else
												' '"/>
									<ul class="{$field}_level" id="{substring-after(@name, '/')}__list">
										<xsl:copy-of
											select="document(concat($request-uri, 'get_hier?q=', if (string($q)) then encode-for-uri($q) else '*:*', '&amp;fq=%22', encode-for-uri(@name), '%22&amp;prefix=', encode-for-uri($next-prefix), '&amp;link=', encode-for-uri(concat($link, $starter-space, '+&#x022;', @name, '&#x022;')), '&amp;field=', $field))//ul[@id='root']/li"
										/>
									</ul>
								</xsl:when>
								<xsl:otherwise>
									<ul class="{$field}_level" id="{substring-after(@name, '/')}__list" style="display:none"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</li>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

</xsl:stylesheet>
