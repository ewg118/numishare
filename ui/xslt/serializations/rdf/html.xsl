<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:void="http://rdfs.org/ns/void#" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:prov="http://www.w3.org/ns/prov#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
	xmlns:crmdig="http://www.ics.forth.gr/isl/CRMdig/" exclude-result-prefixes="#all" version="2.0">

	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../sparql/type-examples.xsl"/>
	<xsl:include href="../../ajax/numishareResults.xsl"/>

	<!-- URL params -->
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
	<xsl:variable name="request-uri"
		select="
			concat('http://localhost:', if (//config/server-port castable as xs:integer) then
				//config/server-port
			else
				'8080', substring-before(doc('input:request')/request/request-uri, 'id/'))"/>
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
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

	<!-- paths -->
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="include_path"
		select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<!-- variables -->
	<xsl:variable name="objectUri" select="//rdf:RDF/*[1]/@rdf:about"/>
	<xsl:variable name="id" select="tokenize($objectUri, '/')[last()]"/>

	<xsl:variable name="hasFindspots" select="doc('input:hasFindspots')//res:boolean" as="xs:boolean"/>
	<xsl:variable name="hasMints" select="doc('input:hasMints')//res:boolean" as="xs:boolean"/>
	<xsl:variable name="hasSymbolRelations" select="doc('input:hasSymbolRelations')//res:boolean" as="xs:boolean"/>

	<!-- namespaces -->
	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<xsl:for-each select="//rdf:RDF/namespace::*[not(name() = 'xml')]">
				<namespace prefix="{name()}" uri="{.}"/>
			</xsl:for-each>
		</namespaces>
	</xsl:variable>
	<xsl:variable name="prefix">
		<xsl:for-each select="$namespaces/namespace">
			<xsl:value-of select="concat(@prefix, ': ', @uri)"/>
			<xsl:if test="not(position() = last())">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:call-template name="contruct_page"/>
	</xsl:template>

	<xsl:template name="contruct_page">
		<html prefix="{$prefix}" itemscope="" itemtype="Thing">
			<xsl:if test="string($lang)">
				<xsl:attribute name="lang" select="$lang"/>
			</xsl:if>
			<head>
				<xsl:call-template name="generic_head"/>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="body"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="generic_head">
		<title id="{$id}">
			<xsl:value-of select="//config/title"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="descendant::skos:prefLabel[@xml:lang = 'en']"/>
		</title>
		<!-- alternates -->
		<link rel="alternate" type="application/rdf+xml" href="{$objectUri}.rdf"/>
		<link rel="alternate" type="application/ld+json" href="{$objectUri}.jsonld"/>
		<link rel="alternate" type="text/turtle" href="{$objectUri}.ttl"/>

		<!-- open graph metadata -->
		<meta property="og:url" content="{$objectUri}"/>
		<meta property="og:type" content="article"/>
		<meta property="og:title">
			<xsl:attribute name="content">
				<xsl:choose>
					<xsl:when test="descendant::*:descMeta/*:title[@xml:lang = $lang]">
						<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang = $lang]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang = 'en']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</meta>

		<!-- CSS -->
		<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/{if (string(//config/favicon)) then //config/favicon else 'favicon.png'}"/>
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"/>
		<meta name="viewport" content="width=device-width, initial-scale=1"/>

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

		<!-- bootstrap -->
		<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
		<script type="text/javascript" src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>
		<link rel="stylesheet" href="{$include_path}/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
		<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
		<script type="text/javascript" src="{$include_path}/javascript/result_functions.js"/>

		<!-- map functions -->
		<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.0/dist/leaflet.css"/>
		<script src="https://unpkg.com/leaflet@1.0.0/dist/leaflet.js"/>
		<script type="text/javascript" src="{$include_path}/javascript/leaflet.ajax.min.js"/>
		<script type="text/javascript" src="{$include_path}/javascript/display_map_functions.js"/>

		<!-- network graph functions -->
		<script type="text/javascript" src="{$include_path}/javascript/d3.min.js"/>
		<script type="text/javascript" src="{$include_path}/javascript/d3plus-network.full.min.js"/>
		<script type="text/javascript" src="{$include_path}/javascript/network_functions.js"/>

		<!-- google analytics -->
		<xsl:if test="string(//config/google_analytics)">
			<script type="text/javascript">
				<xsl:value-of select="//config/google_analytics"/>
			</script>
		</xsl:if>
	</xsl:template>

	<xsl:template name="body">
		<div class="container-fluid content">
			<div class="row">
				<xsl:if test="descendant::crm:P165i_is_incorporated_in[@rdf:resource or child::crmdig:D1_Digital_Object]">
					<div class="col-md-3">
						<xsl:for-each select="descendant::crm:P165i_is_incorporated_in[@rdf:resource or child::crmdig:D1_Digital_Object]">
							<xsl:variable name="uri"
								select="
									if (@rdf:resource) then
										@rdf:resource
									else
										crmdig:D1_Digital_Object/@rdf:about"/>

							<img src="{$uri}" alt="symbol" style="max-width:100%"/>
							<xsl:if test="not(position() = last())">
								<br/>
							</xsl:if>
						</xsl:for-each>

					</div>
				</xsl:if>
				<div class="col-md-{if (descendant::crm:P165i_is_incorporated_in[@rdf:resource or child::crmdig:D1_Digital_Object]) then '9' else '12'}">
					<!-- render RDF -->
					<xsl:apply-templates select="/content/rdf:RDF/*[1]" mode="symbol"/>

					<xsl:if test="doc('input:subsymbols')/descendant::*[name() = 'nmo:Monogram' or name() = 'crm:E37_Mark']">
						<h3>Sub Symbols</h3>
						<div class="row">
							<xsl:apply-templates select="doc('input:subsymbols')/descendant::*[name() = 'nmo:Monogram' or name() = 'crm:E37_Mark']"
								mode="subsymbol"/>
						</div>
					</xsl:if>

					<!-- display map -->
					<xsl:if test="$hasMints = true() or $hasFindspots = true()">
						<div class="section">
							<h3>Map</h3>
							<div id="mapcontainer" class="map-normal">
								<div id="info"/>
							</div>
							<div style="margin:10px 0">
								<table>
									<tbody>
										<tr>
											<td style="background-color:#6992fd;border:2px solid black;width:50px;"/>
											<td style="width:100px">Mints</td>
											<td style="background-color:#d86458;border:2px solid black;width:50px;"/>
											<td style="width:100px">Hoards</td>
											<td style="background-color:#f98f0c;border:2px solid black;width:50px;"/>
											<td style="width:100px">Finds</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
					</xsl:if>

					<!-- display network graph -->
					<xsl:if test="$hasSymbolRelations = true()">
						<div class="section">
							<h3>Network Graph</h3>
							<div style="margin:10px 0">
								<table>
									<tbody>
										<tr>
											<td style="background-color:#a8a8a8;border:2px solid black;width:50px;"/>
											<td style="width:100px">This Symbol</td>
											<td style="background-color:#6985c6;border:2px solid black;width:50px;"/>
											<td style="width:100px">Immediate Link</td>
											<td style="background-color:#b3c9fc;border:2px solid black;width:50px;"/>
											<td style="width:100px">Secondary Link</td>
										</tr>
									</tbody>
								</table>
							</div>
							<div class="network-graph hidden" id="{generate-id()}"/>
						</div>
					</xsl:if>

					<!-- display associated coin types, if applicable -->
					<xsl:if test="count(doc('input:types')//res:result) &gt; 0">
						<xsl:apply-templates select="doc('input:types')/res:sparql" mode="listTypes">
							<xsl:with-param name="objectUri" select="$objectUri"/>
							<xsl:with-param name="endpoint"
								select="
									if (contains(//config/sparql_endpoint, 'localhost')) then
										'http://nomisma.org/query'
									else
										//config/sparql_endpoint"/>
							<xsl:with-param name="rtl" select="boolean(//config/languages/language[@code = $lang]/@rtl)"/>
							<xsl:with-param name="lang" select="$lang"/>
						</xsl:apply-templates>
					</xsl:if>
				</div>
				<div class="col-md-12">
					<h3>Export</h3>
					<ul class="list-inline">
						<li>
							<strong>Linked Data</strong>
						</li>
						<li>
							<a href="{$id}.rdf">RDF/XML</a>
						</li>
						<li>
							<a href="{$id}.ttl">RDF/TTL</a>
						</li>
						<li>
							<a href="{$id}.jsonld">JSON-LD</a>
						</li>
						<li>
							<a href="{$id}.geojson">GeoJSON</a>
						</li>
					</ul>
				</div>
			</div>
		</div>

		<!-- hidden variables -->
		<div class="hidden">
			<span id="path">
				<xsl:value-of select="concat($display_path, 'symbol/')"/>
			</span>
			<span id="baselayers">
				<xsl:value-of select="string-join(//config/baselayers/layer[@enabled = true()], ',')"/>
			</span>
			<span id="mapboxKey">
				<xsl:value-of select="//config/mapboxKey"/>
			</span>
			<span id="lang">
				<xsl:value-of select="$lang"/>
			</span>
			<span id="objectURI">
				<xsl:value-of select="$objectUri"/>
			</span>
			<span id="collection_type">symbol</span>
		</div>
	</xsl:template>

	<!-- templates for RDF/XML -> HTML taken from Nomisma -->
	<xsl:template match="*" mode="symbol">
		<div typeof="{name()}" about="{@rdf:about}">
			<xsl:if test="contains(@rdf:about, '#')">
				<xsl:attribute name="id" select="substring-after(@rdf:about, '#')"/>
			</xsl:if>

			<h2>
				<xsl:value-of select="skos:prefLabel[@xml:lang = 'en']"/>
				<small>
					<xsl:text> (</xsl:text>
					<a href="{concat(namespace-uri(.), local-name())}">
						<xsl:value-of select="name()"/>
					</a>
					<xsl:text>) </xsl:text>
					<a href="{$display_path}results?q={encode-for-uri(concat('symbol_uri:&#x022;', @rdf:about, '&#x022;'))}" title="Search for this monogram">
						<span class="glyphicon glyphicon glyphicon-search"/>
					</a>
				</small>
			</h2>

			<dl class="{if(//config/languages/language[@code = $lang]/@rtl = true()) then 'dl-horizontal dl-rtl' else 'dl-horizontal'}">
				<!-- display stable URI first -->
				<dt>URI</dt>
				<dd>
					<a href="{@rdf:about}" title="Stable URI">
						<xsl:value-of select="@rdf:about"/>
					</a>
				</dd>

				<xsl:if test="count(skos:prefLabel) &gt; 1">
					<dt>
						<a href="{concat($namespaces//namespace[@prefix='skos']/@uri, 'prefLabel')}">
							<xsl:value-of select="numishare:getLabelforRDF('skos:prefLabel', $lang)"/>
						</a>
					</dt>
					<dd>
						<xsl:apply-templates select="skos:prefLabel[not(@xml:lang = 'en')]" mode="prefLabel">
							<xsl:sort select="@xml:lang"/>
						</xsl:apply-templates>
					</dd>
				</xsl:if>


				<xsl:apply-templates select="skos:definition" mode="list-item">
					<xsl:sort select="@xml:lang"/>
				</xsl:apply-templates>

				<xsl:apply-templates select="skos:broader" mode="list-item"/>

				<!-- constituent letters -->
				<xsl:if test="crm:P106_is_composed_of">
					<xsl:variable name="name">crm:P106_is_composed_of</xsl:variable>

					<dt>
						<a href="{concat($namespaces//namespace[@prefix=substring-before($name, ':')]/@uri, substring-after($name, ':'))}">
							<xsl:value-of select="numishare:getLabelforRDF('crm:P106_is_composed_of', $lang)"/>
						</a>
					</dt>
					<dd>
						<xsl:for-each select="crm:P106_is_composed_of">
							<xsl:if test="position() &gt; 1 and position() = last()">
								<xsl:text> and</xsl:text>
							</xsl:if>
							<xsl:text> </xsl:text>
							<xsl:value-of select="."/>
							<xsl:if test="not(position() = last()) and (count(../crm:P106_is_composed_of) &gt; 2)">
								<xsl:text>,</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</dd>
				</xsl:if>

				<!-- Unicode characters -->
				<xsl:if test="crm:P165i_is_incorporated_in[string(.) and not(child::*)]">
					<xsl:variable name="name">crm:P165i_is_incorporated_in</xsl:variable>

					<dt>
						<a href="{concat($namespaces//namespace[@prefix=substring-before($name, ':')]/@uri, substring-after($name, ':'))}">
							<xsl:value-of select="numishare:getLabelforRDF($name, $lang)"/>
						</a>
					</dt>
					<dd>
						<xsl:value-of select="crm:P165i_is_incorporated_in[string(.) and not(child::*)]"/>
					</dd>
				</xsl:if>

				<xsl:apply-templates select="dcterms:source | dcterms:isPartOf" mode="list-item">
					<xsl:sort select="name()"/>
					<xsl:sort select="@rdf:resource"/>
				</xsl:apply-templates>
			</dl>

			<xsl:if test="descendant::crmdig:D1_Digital_Object">
				<h3>Digital Image Metadata</h3>
				<xsl:apply-templates select="descendant::crmdig:D1_Digital_Object"/>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="crmdig:D1_Digital_Object">
		<h4>
			<xsl:value-of select="concat('Image ', position())"/>
		</h4>
		<dl class="{if(//config/languages/language[@code = $lang]/@rtl = true()) then 'dl-horizontal dl-rtl' else 'dl-horizontal'}">
			<dt>URI</dt>
			<dd>
				<a href="{@rdf:about}" title="Stable URI">
					<xsl:value-of select="@rdf:about"/>
				</a>
			</dd>

			<xsl:apply-templates select="dcterms:format | dcterms:creator | dcterms:license" mode="list-item">
				<xsl:sort select="name()"/>
			</xsl:apply-templates>
		</dl>
	</xsl:template>

	<xsl:template match="skos:prefLabel" mode="prefLabel">
		<span property="{name()}" lang="{@xml:lang}">
			<xsl:value-of select="."/>
		</span>
		<xsl:if test="string(@xml:lang)">
			<span class="lang">
				<xsl:value-of select="concat(' (', @xml:lang, ')')"/>
			</span>
		</xsl:if>
		<xsl:if test="not(position() = last())">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="list-item">
		<xsl:variable name="name" select="name()"/>
		<dt>
			<a href="{concat($namespaces//namespace[@prefix=substring-before($name, ':')]/@uri, substring-after($name, ':'))}">
				<xsl:value-of select="numishare:getLabelforRDF(name(), $lang)"/>
			</a>
		</dt>
		<dd>
			<xsl:choose>
				<xsl:when test="string(.)">
					<span property="{name()}">
						<xsl:if test="@xml:lang">
							<xsl:attribute name="xml:lang" select="@xml:lang"/>
						</xsl:if>
						<xsl:if test="@rdf:datatype">
							<xsl:attribute name="datatype" select="@rdf:datatype"/>
						</xsl:if>

						<xsl:value-of select="."/>
					</span>
					<xsl:if test="string(@xml:lang)">
						<span class="lang">
							<xsl:value-of select="concat(' (', @xml:lang, ')')"/>
						</span>
					</xsl:if>
				</xsl:when>
				<xsl:when test="string(@rdf:resource)">
					<span>
						<a href="{@rdf:resource}" rel="{name()}" title="{@rdf:resource}">
							<xsl:choose>
								<xsl:when test="name() = 'rdf:type'">
									<xsl:variable name="uri" select="@rdf:resource"/>
									<xsl:value-of
										select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"
									/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@rdf:resource"/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</span>
				</xsl:when>
			</xsl:choose>
		</dd>
	</xsl:template>

	<xsl:template match="*" mode="subsymbol">
		<div class="col-md-3 col-sm-6 col-lg-2 monogram" style="height:240px">
			<div class="text-center">
				<a href="{@rdf:about}">
					<img
						src="{
						if (crm:P165i_is_incorporated_in[@rdf:resource]) then
						crm:P165i_is_incorporated_in[@rdf:resource][1]/@rdf:resource
						else
						crm:P165i_is_incorporated_in//crmdig:D1_Digital_Object[@rdf:about][1]/@rdf:about}"
						alt="Symbol image" style="max-height:200px;max-width:100%"/>
				</a>
			</div>
			<a href="{@rdf:about}">
				<xsl:choose>
					<xsl:when test="skos:prefLabel[@xml:lang = $lang]">
						<xsl:value-of select="skos:prefLabel[@xml:lang = $lang]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="skos:prefLabel[@xml:lang = 'en']"/>
					</xsl:otherwise>
				</xsl:choose>
			</a>
			<xsl:if test="crm:P106_is_composed_of">
				<br/>
				<strong>Constituent Letters: </strong>
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
		</div>
	</xsl:template>

</xsl:stylesheet>
