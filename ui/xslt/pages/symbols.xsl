<?xml version="1.0" encoding="UTF-8"?>

<!-- Author: Ethan Gruber
	Date modified: December 2019
	Function: Serialize symbol results into paginated HTML pages -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:numishare="https://github.com/ewg118/numishare" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:void="http://rdfs.org/ns/void#"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:prov="http://www.w3.org/ns/prov#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
	xmlns:crmdig="http://www.ics.forth.gr/isl/CRMdig/" exclude-result-prefixes="#all" version="2.0">

	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:param name="url" select="//config/url"/>
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
	<xsl:param name="symbol" select="doc('input:request')/request/parameters/parameter[name = 'symbol']"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[. = 'accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[. = 'accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>

	<!-- pagination params/variables -->
	<xsl:param name="limit">24</xsl:param>

	<!-- pagination parameter for iterating through pages of physical specimens -->
	<xsl:param name="page" as="xs:integer">
		<xsl:choose>
			<xsl:when
				test="
					string-length(doc('input:request')/request/parameters/parameter[name = 'page']/value) &gt; 0 and doc('input:request')/request/parameters/parameter[name = 'page']/value castable
					as xs:integer and number(doc('input:request')/request/parameters/parameter[name = 'page']/value) > 0">
				<xsl:value-of select="doc('input:request')/request/parameters/parameter[name = 'page']/value"/>
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:variable name="numFound" select="doc('input:count')//count" as="xs:integer"/>

	<!-- path variables -->
	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path"
		select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<!-- config variables-->
	<xsl:variable name="collection_type" select="//config/collection_type"/>
	<xsl:variable name="union_type_catalog" select="boolean(//config/union_type_catalog/@enabled)"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="numishare:normalizeLabel('header_symbols', $lang)"/>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<link rel="shortcut icon" type="image/x-icon"
					href="{$include_path}/images/{if (string(//config/favicon)) then //config/favicon else 'favicon.png'}"/>

				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"/>
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
				<script type="text/javascript" src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>

				<!-- map functions -->
				<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.0/dist/leaflet.css"/>
				<script src="https://unpkg.com/leaflet@1.0.0/dist/leaflet.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/leaflet.ajax.min.js"/>

				<!-- fancybox -->
				<link rel="stylesheet" href="{$include_path}/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
				<script type="text/javascript" src="{$include_path}/javascript/symbol_functions.js"/>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>

				<xsl:for-each select="//config/includes/include">
					<xsl:choose>
						<xsl:when test="@type = 'css'">
							<link type="text/{@type}" rel="stylesheet" href="{@url}"/>
						</xsl:when>
						<xsl:when test="@type = 'javascript'">
							<script type="text/{@type}" src="{@url}"/>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>

				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="body"/>
				<xsl:call-template name="footer"/>

			</body>
		</html>
	</xsl:template>

	<xsl:template name="body">
		<div class="container-fluid">
			<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>
			</xsl:if>
			<div class="row">
				<div class="col-md-12">
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('header_symbols', $lang)"/>
						<xsl:if test="count($symbol//value) &gt; 0">
							<small>
								<a href="#resultMap" id="map_results">
									<xsl:value-of select="numishare:normalizeLabel('results_map-results', $lang)"/>
								</a>
							</small>
						</xsl:if>
					</h1>



					<div style="display:none">
						<div id="resultMap"/>
					</div>


					<!-- display clickable buttons -->
					<xsl:apply-templates select="doc('input:letters')//letters"/>

					<xsl:if test="$numFound &gt; $limit">
						<xsl:call-template name="pagination">
							<xsl:with-param name="page" select="$page" as="xs:integer"/>
							<xsl:with-param name="numFound" select="$numFound" as="xs:integer"/>
							<xsl:with-param name="limit" select="$limit" as="xs:integer"/>
						</xsl:call-template>
					</xsl:if>

					<!-- render each symbol/monogram -->

					<xsl:choose>
						<xsl:when test="count(//rdf:RDF/*) &gt; 0">
							<xsl:apply-templates select="//rdf:RDF/*" mode="symbol"/>
						</xsl:when>
						<xsl:otherwise>
							<h3>No symbols found.</h3>
						</xsl:otherwise>
					</xsl:choose>



					<xsl:if test="$numFound &gt; $limit">
						<xsl:call-template name="pagination">
							<xsl:with-param name="page" select="$page" as="xs:integer"/>
							<xsl:with-param name="numFound" select="$numFound" as="xs:integer"/>
							<xsl:with-param name="limit" select="$limit" as="xs:integer"/>
						</xsl:call-template>
					</xsl:if>
				</div>
			</div>
		</div>

		<div class="hidden">
			<span id="baselayers">
				<xsl:value-of select="string-join(//config/baselayers/layer[@enabled = true()], ',')"/>
			</span>
			<span id="mapboxKey">
				<xsl:value-of select="//config/mapboxKey"/>
			</span>
			<span id="lang">
				<xsl:value-of select="$lang"/>
			</span>
			<span id="typeSeries">
				<xsl:value-of
					select="
						if (//config/union_type_catalog/@enabled = true()) then
							string-join(//config/union_type_catalog/series/@typeSeries, '|')
						else
							//config/type_series"
				/>
			</span>
		</div>
	</xsl:template>

	<!-- ******** RDF TEMPLATES ********* -->
	<xsl:template match="*" mode="symbol">
		<xsl:variable name="uri"
			select="
				if ($union_type_catalog = true()) then
					@rdf:about
				else
					concat('symbol/', tokenize(@rdf:about, '/')[last()])"/>
		<xsl:variable name="label"
			select="
				if (skos:prefLabel[@xml:lang = $lang]) then
					skos:prefLabel[@xml:lang = $lang]
				else
					skos:prefLabel[@xml:lang = 'en']"/>

		<div class="col-md-3 col-sm-6 col-lg-2 monogram" style="height:240px">
			<div class="text-center">
				<a href="{$uri}">
					<img
						src="{
						if (crm:P165i_is_incorporated_in[@rdf:resource]) then
						crm:P165i_is_incorporated_in[@rdf:resource][1]/@rdf:resource
						else
						crm:P165i_is_incorporated_in//crmdig:D1_Digital_Object[@rdf:about][1]/@rdf:about}"
						alt="Symbol image" style="max-height:200px;max-width:100%"/>
				</a>
			</div>
			<a href="{$uri}" title="{$label}">
				<xsl:value-of select="$label"/>
			</a>
			<xsl:text> </xsl:text>
			<a href="{$display_path}results?q={encode-for-uri(concat('symbol_uri:&#x022;', @rdf:about, '&#x022;'))}" title="Search for this monogram">
				<span class="glyphicon glyphicon glyphicon-search"/>
			</a>
			<xsl:if test="crm:P106_is_composed_of">
				<br/>
				<strong><xsl:value-of select="numishare:getLabelforRDF('crm:P106_is_composed_of', $lang)"/>: </strong>
				<xsl:for-each select="crm:P106_is_composed_of">
					<xsl:if test="position() = last() and position() &gt; 1">
						<xsl:text> and</xsl:text>
					</xsl:if>
					<xsl:text> </xsl:text>
					<xsl:value-of select="."/>
					<xsl:if test="not(position() = last()) and (count(../crm:P106_is_composed_of) &gt; 2)">
						<xsl:text>,</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="crm:P165i_is_incorporated_in[string(.) and not(child::*)]">
				<br/>
				<strong><xsl:value-of select="numishare:getLabelforRDF('crm:P165i_is_incorporated_in', $lang)"/>: </strong>
				<xsl:value-of select="crm:P165i_is_incorporated_in[string(.) and not(child::*)]"/>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- ********** LETTER TEMPLATES *********** -->
	<xsl:template match="letters">

		<!-- Greek 880-1023 (https://codepoints.net/greek_and_coptic) -->
		<!-- Latin 33-591  -->


		<div class="row">
			<div class="col-md-12">
				<h3>
					<xsl:value-of select="numishare:getLabelforRDF('crm:P106_is_composed_of', $lang)"/>
				</h3>

				<p>Click the buttons for letters below in order to select them in order to filter for only those monograms that contain the letters (click
					Refine Search after the selection is complete). Clicking a selected letter again will deselect it.</p>

				<xsl:if test="letter[@codepoint &gt;= 33 and @codepoint &lt;= 591]">
					<div id="symbol-container">
						<h4>Latin</h4>
						<xsl:apply-templates select="letter[@codepoint &gt;= 33 and @codepoint &lt;= 591]"/>
					</div>
				</xsl:if>

				<xsl:if test="letter[@codepoint &gt;= 880 and @codepoint &lt;= 1023]">
					<div id="symbol-container">
						<h4>
							<xsl:value-of select="numishare:normalizeLabel('lang_el', $lang)"/>
						</h4>
						<xsl:apply-templates select="letter[@codepoint &gt;= 880 and @codepoint &lt;= 1023]"/>
					</div>
				</xsl:if>
				
				<xsl:if test="glyph[matches(@codepoint, '68[0-9]{3}', 'i')]">
					
					
					<div id="symbol-container">
						<h4>Kharoshthi</h4>
						<xsl:apply-templates select="glyph[matches(@codepoint, '68[0-9]{3}', 'i')]"/>
					</div>
				</xsl:if>

				<div id="form-container">
					<form role="form" method="get" action="symbols" id="symbol-form">
						<xsl:for-each select="$symbol//value">
							<input type="hidden" name="symbol" value="{.}"/>
						</xsl:for-each>

						<input class="btn btn-primary" type="submit" value="Refine Search"/>
					</form>

					<xsl:if test="$symbol">
						<form role="form" method="get" action="symbols">
							<input class="btn btn-primary" type="submit" value="Clear"/>
						</form>
					</xsl:if>
				</div>

			</div>
		</div>
	</xsl:template>

	<xsl:template match="letter|glyph">
		<xsl:variable name="active" as="xs:boolean">
			<xsl:choose>
				<xsl:when test="$symbol//value = .">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>

		</xsl:variable>

		<button class="btn btn-default letter-button {if ($active = true()) then 'active' else ''}">
			<xsl:value-of select="."/>
		</button>
	</xsl:template>

	<!-- ********** PAGINATION *********** -->
	<xsl:template name="pagination">
		<xsl:param name="page" as="xs:integer"/>
		<xsl:param name="numFound" as="xs:integer"/>
		<xsl:param name="limit" as="xs:integer"/>

		<xsl:variable name="offset" select="($page - 1) * $limit" as="xs:integer"/>

		<xsl:variable name="previous" select="$page - 1"/>
		<xsl:variable name="current" select="$page"/>
		<xsl:variable name="next" select="$page + 1"/>
		<xsl:variable name="total" select="ceiling($numFound div $limit)"/>

		<xsl:variable name="symbol-params">
			<xsl:for-each select="$symbol//value">
				<xsl:text>&amp;symbol=</xsl:text>
				<xsl:value-of select="."/>
			</xsl:for-each>
		</xsl:variable>


		<div class="col-md-12 paging_div">
			<div class="row">
				<div class="col-md-6">
					<xsl:variable name="startRecord" select="$offset + 1"/>
					<xsl:variable name="endRecord">
						<xsl:choose>
							<xsl:when test="$numFound &gt; ($offset + $limit)">
								<xsl:value-of select="$offset + $limit"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$numFound"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<p>Records <b><xsl:value-of select="$startRecord"/></b> to <b><xsl:value-of select="$endRecord"/></b> of <b><xsl:value-of select="$numFound"
							/></b></p>
				</div>
				<!-- paging functionality -->
				<div class="col-md-6">
					<div class="btn-toolbar" role="toolbar">
						<div class="btn-group pull-right">
							<!-- first page -->
							<xsl:if test="$current &gt; 1">
								<a class="btn btn-default" role="button" title="First" href="symbols?page=1{$symbol-params}">
									<span class="glyphicon glyphicon-fast-backward"/>
									<xsl:text> 1</xsl:text>
								</a>
								<a class="btn btn-default" role="button" title="Previous" href="symbols?page={$current - 1}{$symbol-params}">
									<xsl:text>Previous </xsl:text>
									<span class="glyphicon glyphicon-backward"/>
								</a>
							</xsl:if>
							<xsl:if test="$current &gt; 5">
								<button type="button" class="btn btn-default disabled">
									<xsl:text>...</xsl:text>
								</button>
							</xsl:if>
							<xsl:if test="$current &gt; 4">
								<a class="btn btn-default" role="button" href="symbols?page={$current - 3}{$symbol-params}">
									<xsl:value-of select="$current - 3"/>
									<xsl:text> </xsl:text>
								</a>
							</xsl:if>
							<xsl:if test="$current &gt; 3">
								<a class="btn btn-default" role="button" href="symbols?page={$current - 2}{$symbol-params}">
									<xsl:value-of select="$current - 2"/>
									<xsl:text> </xsl:text>
								</a>
							</xsl:if>
							<xsl:if test="$current &gt; 2">
								<a class="btn btn-default" role="button" href="symbols?page={$current - 1}{$symbol-params}">
									<xsl:value-of select="$current - 1"/>
									<xsl:text> </xsl:text>
								</a>
							</xsl:if>
							<!-- current page -->
							<button type="button" class="btn btn-default active">
								<b>
									<xsl:value-of select="$current"/>
								</b>
							</button>
							<xsl:if test="$total &gt; ($current + 1)">
								<a class="btn btn-default" role="button" title="Next" href="symbols?page={$current + 1}{$symbol-params}">
									<xsl:value-of select="$current + 1"/>
								</a>
							</xsl:if>
							<xsl:if test="$total &gt; ($current + 2)">
								<a class="btn btn-default" role="button" title="Next" href="symbols?page={$current + 2}{$symbol-params}">
									<xsl:value-of select="$current + 2"/>
								</a>
							</xsl:if>
							<xsl:if test="$total &gt; ($current + 3)">
								<a class="btn btn-default" role="button" title="Next" href="symbols?page={$current + 3}{$symbol-params}">
									<xsl:value-of select="$current + 3"/>
								</a>
							</xsl:if>
							<xsl:if test="$total &gt; ($current + 4)">
								<button type="button" class="btn btn-default disabled">
									<xsl:text>...</xsl:text>
								</button>
							</xsl:if>
							<!-- last page -->
							<xsl:if test="$current &lt; $total">
								<a class="btn btn-default" role="button" title="Next" href="symbols?page={$current + 1}{$symbol-params}">
									<xsl:text>Next </xsl:text>
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default" role="button" title="Last" href="symbols?page={$total}{$symbol-params} ">
									<xsl:value-of select="$total"/>
									<xsl:text> </xsl:text>
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:if>
						</div>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
