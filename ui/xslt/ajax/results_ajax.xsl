<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../functions.xsl"/>
	<xsl:include href="../serializations/solr/html-templates.xsl"/>

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
	<xsl:param name="request-uri" select="concat('http://localhost:8080', substring-before(doc('input:request')/request/request-uri, 'results_ajax'))"/>
	<xsl:variable name="authenticated" select="false()" as="xs:boolean"/>

	<xsl:variable name="display_path">
		<xsl:choose>
			<xsl:when test="$pipeline='maps'"/>
			<xsl:when test="$pipeline='maps_fullscreen'">../</xsl:when>
			<xsl:otherwise/>
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
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="url" select="/content/config/url"/>

	<!-- get block of images from SPARQL endpoint, via nomisma API -->
	<xsl:variable name="sparqlResult" as="element()*">
		<xsl:if test="string($sparql_endpoint) and //config/collection_type='cointype'">
			<xsl:variable name="service" select="concat('http://nomisma.org/apis/numishareResults?identifiers=', encode-for-uri(string-join(descendant::str[@name='recordId'], '|')), '&amp;baseUri=',
				encode-for-uri(/content/config/uri_space))"/>
			<xsl:copy-of select="document($service)/response"/>
		</xsl:if>
	</xsl:variable>

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
				<xsl:if test="$lang='ar'">
					<xsl:attribute name="style">direction: ltr; text-align:right</xsl:attribute>
				</xsl:if>
				<a href="{$display_path}id/{str[@name='recordId']}{if (string($langParam)) then concat('?lang=', $langParam) else ''}" target="_blank">
					<xsl:value-of select="str[@name='title_display']"/>
				</a>
			</h4>
			<dl class=" {if($lang='ar') then 'dl-horizontal ar' else 'dl-horizontal'}">
				<xsl:choose>
					<xsl:when test="str[@name='recordType'] = 'hoard'">
						<dt>							
							<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
						</dt>
						<dd>							
							<xsl:value-of select="arr[@name='findspot_facet']/str[1]"/>
						</dd>
						<dt>							
							<xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/>
						</dt>
						<dd>							
							<xsl:value-of select="str[@name='closing_date_display']"/>
						</dd>
						<xsl:if test="string(str[@name='description_display'])">
							<dt>								
								<xsl:value-of select="numishare:regularize_node('description', $lang)"/>
							</dt>
							<dd>								
								<xsl:value-of select="str[@name='description_display']"/>
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
									<xsl:text>: </xsl:text>
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
									<xsl:text>: </xsl:text>
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
							<xsl:variable name="path">
								<xsl:if test="not(contains(str[@name='thumbnail_obv'], 'http://'))">
									<xsl:value-of select="$display_path"/>
								</xsl:if>
							</xsl:variable>

							<a class="thumbImage" href="{$path}{str[@name='reference_obv']}" title="Obverse of {str[@name='title_display']}" id="{$display_path}id/{str[@name='recordId']}{if
								(string($langParam))         then concat('?lang=', $langParam) else ''}">
								<img src="{$path}{str[@name='thumbnail_obv']}"/>
							</a>
						</xsl:if>
						<xsl:if test="string(str[@name='thumbnail_rev'])">
							<xsl:variable name="path">
								<xsl:if test="not(contains(str[@name='thumbnail_rev'], 'http://'))">
									<xsl:value-of select="$display_path"/>
								</xsl:if>
							</xsl:variable>

							<a class="thumbImage" href="{$path}{str[@name='reference_rev']}" title="Reverse of {str[@name='title_display']}" id="{$display_path}id/{str[@name='recordId']}{if
								(string($langParam))         then concat('?lang=', $langParam) else ''}">
								<img src="{$path}{str[@name='thumbnail_rev']}"/>
							</a>
						</xsl:if>
					</xsl:when>
					<xsl:when test="str[@name='recordType'] = 'conceptual'">
						<xsl:if test="string($sparql_endpoint)">
							<xsl:variable name="id" select="str[@name='recordId']"/>
							<xsl:apply-templates select="$sparqlResult//group[@id=$id]" mode="results"/>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
