<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../functions.xsl"/>
	<xsl:include href="../serializations/solr/html-templates.xsl"/>
	<xsl:include href="numishareResults.xsl"/>

	<!-- params -->
	<xsl:param name="pipeline" select="doc('input:request')/request/parameters/parameter[name='pipeline']/value"/>
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[.='accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[.='accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="layout" select="doc('input:request')/request/parameters/parameter[name='layout']/value"/>
	<xsl:param name="request-uri" select="concat('http://localhost:', if (//config/server-port castable as xs:integer) then //config/server-port else '8080', substring-before(doc('input:request')/request/request-uri, 'results_ajax'))"/>
	<xsl:variable name="authenticated" select="false()" as="xs:boolean"/>

	<xsl:variable name="display_path">
		<xsl:choose>
			<xsl:when test="$pipeline='maps'"/>
			<xsl:when test="$pipeline='maps_fullscreen'">../</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="object-path">
		<xsl:choose>
			<xsl:when test="//config/collection_type = 'object' and string(//config/uri_space)">
				<xsl:value-of select="//config/uri_space"/>
			</xsl:when>
			<xsl:when test="//config/union_type_catalog/@enabled = true()">
				<xsl:value-of select="str[@name='uri_space']"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($display_path, 'id/')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- empty variables -->
	<xsl:variable name="mode"/>
	<xsl:variable name="image"/>
	<xsl:variable name="collection_type"/>
	<xsl:variable name="side"/>
	<xsl:variable name="positions" as="node()*">
		<empty/>
	</xsl:variable>

	<!-- solr params -->
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="sort" select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
	<xsl:param name="rows">24</xsl:param>
	<xsl:param name="start" select="doc('input:request')/request/parameters/parameter[name='start']/value"/>

	<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>
	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>

	<!-- config variables -->	
	<xsl:variable name="url" select="/content/config/url"/>
	
	<xsl:template match="/">
		<xsl:variable name="facets" as="element()*">
			<xsl:copy-of select="descendant::lst[@name='facet_fields']"/>
		</xsl:variable>
		<xsl:variable name="places" as="item()*">
			<xsl:analyze-string select="$q" regex="_uri:&#x022;([^&#x022;]+)&#x022;">
				<xsl:matching-substring>
					<xsl:variable name="value" select="regex-group(1)"/>
					<xsl:value-of select="tokenize($facets/descendant::int[contains(@name, $value)][1]/@name, '\|')[1]"/>					
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:variable>
		<h1>
			<xsl:text>Place</xsl:text>
			<xsl:if test="count($places) &gt; 0">
				<xsl:text>s</xsl:text>
			</xsl:if>
			<xsl:text>: </xsl:text>
			<small>
				<a id="clear_all" href="#">clear</a>
			</small>
		</h1>
		<h2>
			<xsl:for-each select="$places[string-length(.) &gt; 0]">
				<xsl:value-of select="."/>
				<xsl:if test="not(position() = last())">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</h2>
		<xsl:call-template name="paging"/>
		<div class="row">
			<xsl:apply-templates select="descendant::doc" mode="map"/>
		</div>
		<xsl:call-template name="paging"/>
	</xsl:template>

	<xsl:template match="doc" mode="map">
		<xsl:variable name="sort_category" select="substring-before($sort, ' ')"/>
		<xsl:variable name="regularized_sort">
			<xsl:value-of select="numishare:normalize_fields($sort_category, $lang)"/>
		</xsl:variable>

		<div class="g_doc col-md-4">
			<h4>
				<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
					<xsl:attribute name="style">direction: ltr; text-align:right</xsl:attribute>
				</xsl:if>
				<a href="{$object-path}{str[@name='recordId']}{if (string($langParam)) then concat('?lang=', $langParam) else ''}" target="_blank">
					<xsl:value-of select="str[@name='title_display']"/>
				</a>
			</h4>
			<dl class="{if(//config/languages/language[@code = $lang]/@rtl = true()) then 'dl-horizontal dl-rtl' else 'dl-horizontal'}">
				<xsl:choose>
					<xsl:when test="str[@name='recordType'] = 'hoard'">
						<xsl:if test="string(str[@name = 'findspot_display'])">
							<dt>
								<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
							</dt>
							<dd>
								<xsl:value-of select="str[@name = 'findspot_display']"/>
							</dd>
						</xsl:if>
						<xsl:if test="str[@name = 'closing_date_display']">
							<dt>
								<xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/>
							</dt>
							<dd>
								<xsl:value-of select="str[@name = 'closing_date_display']"/>
							</dd>
						</xsl:if>
						<xsl:if test="str[@name = 'deposit_display']">
							<dt>
								<xsl:value-of select="numishare:regularize_node('deposit', $lang)"/>
							</dt>
							<dd>
								<xsl:value-of select="str[@name = 'deposit_display']"/>
							</dd>
						</xsl:if>
						<xsl:if test="str[@name = 'discovery_display']">
							<dt>
								<xsl:value-of select="numishare:regularize_node('discovery', $lang)"/>
							</dt>
							<dd>
								<xsl:value-of select="str[@name = 'discovery_display']"/>
							</dd>
						</xsl:if>
						<xsl:if test="string(str[@name = 'description_display'])">
							<dt>
								<xsl:value-of select="numishare:regularize_node('description', $lang)"/>
							</dt>
							<dd>
								<xsl:value-of select="str[@name = 'description_display']"/>
							</dd>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string(str[@name='date_display'])">
							<dt>
								<xsl:value-of select="numishare:regularize_node('date', $lang)"/>
							</dt>
							<dd>
								<xsl:value-of select="str[@name='date_display']"/>
							</dd>
						</xsl:if>
						<xsl:if test="string(arr[@name='denomination_facet']/str[1])">
							<dt>
								<xsl:value-of select="numishare:regularize_node('denomination', $lang)"/>
							</dt>
							<dd>
								<xsl:for-each select="arr[@name='denomination_facet']/str">
									<xsl:value-of select="."/>
									<xsl:if test="not(position() = last())">
										<xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</dd>
						</xsl:if>
						<xsl:if test="string(arr[@name='mint_facet']/str[1])">
							<dt>
								<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
							</dt>
							<dd>
								<xsl:for-each select="arr[@name='mint_facet']/str">
									<xsl:value-of select="."/>
									<xsl:if test="not(position() = last())">
										<xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</dd>
						</xsl:if>
						<xsl:if test="str[@name='obv_leg_display'] or str[@name='obv_type_display']">
							<dt>								
								<xsl:value-of select="numishare:regularize_node('obverse', $lang)"/>
							</dt>
							<dd>								
								<xsl:value-of select="if (string-length(str[@name='obv_leg_display']) &gt; 30) then concat(substring(str[@name='obv_leg_display'], 1, 30), '...') else
									str[@name='obv_leg_display']"/>
								<xsl:if test="str[@name='obv_leg_display'] and str[@name='obv_type_display']">
									<xsl:choose>
										<xsl:when test="$lang = 'de'">; </xsl:when>
										<xsl:otherwise>: </xsl:otherwise>
									</xsl:choose>
								</xsl:if>
								<xsl:value-of select="if (string-length(str[@name='obv_type_display']) &gt; 30) then concat(substring(str[@name='obv_type_display'], 1, 30), '...') else
									str[@name='obv_type_display']"/>
							</dd>
						</xsl:if>
						<xsl:if test="str[@name='rev_leg_display'] or str[@name='rev_type_display']">
							<dt>								
								<xsl:value-of select="numishare:regularize_node('reverse', $lang)"/>
							</dt>
							<dd>								
								<xsl:value-of select="if (string-length(str[@name='rev_leg_display']) &gt; 30) then concat(substring(str[@name='rev_leg_display'], 1, 30), '...') else
									str[@name='rev_leg_display']"/>
								<xsl:if test="str[@name='rev_leg_display'] and str[@name='rev_type_display']">
									<xsl:choose>
										<xsl:when test="$lang = 'de'">; </xsl:when>
										<xsl:otherwise>: </xsl:otherwise>
									</xsl:choose>
								</xsl:if>
								<xsl:value-of select="if (string-length(str[@name='rev_type_display']) &gt; 30) then concat(substring(str[@name='rev_type_display'], 1, 30), '...') else
									str[@name='rev_type_display']"/>
							</dd>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</dl>

			<div class="gi_c">
				<xsl:choose>
					<xsl:when test="str[@name='recordType'] = 'physical'">
						<xsl:if test="string(str[@name='thumbnail_obv'])">
							<a class="thumbImage" href="{str[@name='reference_obv']}" title="Obverse of {str[@name='title_display']}" id="{$object-path}{str[@name='recordId']}{if
								(string($langParam))         then concat('?lang=', $langParam) else ''}">
								<img src="{str[@name='thumbnail_obv']}" class="side-thumbnail"/>
							</a>
						</xsl:if>
						<xsl:if test="string(str[@name='thumbnail_rev'])">
							<a class="thumbImage" href="{str[@name='reference_rev']}" title="Reverse of {str[@name='title_display']}" id="{$object-path}{str[@name='recordId']}{if
								(string($langParam))         then concat('?lang=', $langParam) else ''}">
								<img src="{str[@name='thumbnail_rev']}" class="side-thumbnail"/>
							</a>
						</xsl:if>
					</xsl:when>
					<xsl:when test="str[@name='recordType'] = 'conceptual' and matches(/content/config/sparql_endpoint, '^https?://')">
						<xsl:variable name="id" select="str[@name='recordId']"/>
						<xsl:apply-templates select="doc('input:numishareResults')//group[@id=$id]" mode="results"/>
					</xsl:when>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
