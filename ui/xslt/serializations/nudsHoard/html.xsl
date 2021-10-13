<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" version="2.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:org="http://www.w3.org/ns/org#"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:nm="http://nomisma.org/id/" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:gml="http://www.opengis.net/gml" xmlns:nmo="http://nomisma.org/ontology#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	exclude-result-prefixes="#all">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../../templates-analyze.xsl"/>
	<xsl:include href="../../templates-search.xsl"/>
	<xsl:include href="../object/html-templates.xsl"/>
	<xsl:include href="../sparql/type-examples.xsl"/>

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
	<xsl:variable name="langEnabled" select="boolean(//config/languages/language[@code = $lang]/@enabled = true())"/>
	
	<xsl:param name="pipeline">display</xsl:param>

	<!--pagination of specimen count -->
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

	<!-- shared visualization/analysis params -->
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name = 'type']/value"/>
	<xsl:param name="dist" select="doc('input:request')/request/parameters/parameter[name = 'dist']/value"/>
	<xsl:param name="compare" select="doc('input:request')/request/parameters/parameter[name = 'compare']/value"/>
	<xsl:param name="exclude" select="doc('input:request')/request/parameters/parameter[name = 'exclude']/value"/>
	<xsl:param name="options" select="doc('input:request')/request/parameters/parameter[name = 'options']/value"/>

	<!-- config variables -->
	<xsl:variable name="geonames-url">http://api.geonames.org</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="collection_type" select="/content/config/collection_type"/>
	<xsl:variable name="localTypes" as="node()*">
		<config>
			<xsl:copy-of select="/content/config/localTypes"/>
		</config>
	</xsl:variable>
	<xsl:variable name="positions" as="node()*">
		<config>
			<xsl:copy-of select="/content/config/positions"/>
		</config>
	</xsl:variable>
	<xsl:variable name="regionHierarchy" select="boolean(/content/config/facets/facet[text() = 'region_hier'])" as="xs:boolean"/>
	<xsl:variable name="display_stub" select="/content/config/hoard_options/display_stub"/>

	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="include_path"
		select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>
	<xsl:variable name="recordType">hoard</xsl:variable>
	<xsl:variable name="id" select="normalize-space(//*[local-name() = 'recordId'])"/>
	<xsl:variable name="objectUri"
		select="
			if (/content/config/uri_space) then
				concat(/content/config/uri_space, $id)
			else
				concat($url, 'id/', $id)"/>

	<!-- get NUDS -->
	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:variable name="type_series" as="element()*">
				<list>
					<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/substring-before(@xlink:href, 'id/'))">
						<type_series>
							<xsl:value-of select="."/>
						</type_series>
					</xsl:for-each>
				</list>
			</xsl:variable>
			<xsl:variable name="type_list" as="element()*">
				<list>
					<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/@xlink:href)">
						<type_series_item>
							<xsl:value-of select="."/>
						</type_series_item>
					</xsl:for-each>
				</list>
			</xsl:variable>

			<xsl:for-each select="$type_series//type_series">
				<xsl:variable name="type_series_uri" select="."/>

				<xsl:variable name="id-param">
					<xsl:for-each select="$type_list//type_series_item[contains(., $type_series_uri)]">
						<xsl:value-of select="substring-after(., 'id/')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<xsl:if test="string-length($id-param) &gt; 0">
					<xsl:for-each select="document(concat($type_series_uri, 'apis/getNuds?identifiers=', encode-for-uri($id-param)))//nuds:nuds">
						<object xlink:href="{$type_series_uri}id/{nuds:control/nuds:recordId}">
							<xsl:copy-of select="."/>
						</object>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="descendant::nuds:typeDesc[not(string(@xlink:href))]">
				<object>
					<xsl:copy-of select="."/>
				</object>
			</xsl:for-each>
		</nudsGroup>
	</xsl:variable>

	<!-- get subtypes -->
	<xsl:variable name="subtypes" as="element()*">
		<xsl:if test="$recordType = 'conceptual' and //config/collection_type = 'cointype'">
			<xsl:copy-of select="document(concat($request-uri, 'get_subtypes?identifiers=', $id))/*"/>
		</xsl:if>
	</xsl:variable>

	<!-- get the facets as a sequence -->
	<xsl:variable name="facets" select="//config/facets/facet"/>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">

			<!-- aggregate distinct Nomisma URIs and perform an API lookup to get the RDF for all of them -->
			<xsl:variable name="id-param">
				<xsl:for-each
					select="
					distinct-values(descendant::*[not(local-name() = 'typeDesc') and not(local-name() = 'reference')][contains(@xlink:href,
					'nomisma.org')]/@xlink:href | $nudsGroup/descendant::*[not(local-name() = 'object') and not(local-name() = 'typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href | descendant::*[contains(@certainty, 'nomisma.org')]/@certainty | $nudsGroup/descendant::*[contains(@certainty, 'nomisma.org')]/@certainty)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position() = last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="id-url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
			
			<xsl:variable name="id-var" as="element()*">
				<xsl:if test="doc-available($id-url)">
					<xsl:copy-of select="document($id-url)/rdf:RDF"/>
				</xsl:if>
			</xsl:variable>
			
			<!-- read distinct org:organization and org:memberOf URIs from the initial RDF API request and request these, but only if they aren't in the initial request -->
			<xsl:variable name="org-param">
				<xsl:for-each select="distinct-values($id-var//org:organization/@rdf:resource | $id-var//org:memberOf/@rdf:resource)">
					<xsl:variable name="href" select="."/>
					
					<xsl:if test="not($id-var/*[@rdf:about = $href])">						
						<xsl:value-of select="substring-after($href, 'id/')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="org-url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($org-param))"/>
			
			<xsl:variable name="org-var" as="element()*">
				<xsl:if test="doc-available($org-url)">
					<xsl:copy-of select="document($org-url)/rdf:RDF"/>
				</xsl:if>
			</xsl:variable>
			
			<!-- copy the contents of the API request variables into this variable -->
			<xsl:copy-of select="$id-var/*"/>
			<xsl:copy-of select="$org-var/*"/>	

			<!-- these individual RDF calls should be replaced with the getRDF API when many symbols might appear in one hoard -->
			<xsl:for-each
				select="
					distinct-values($nudsGroup/descendant::nuds:symbol[contains(@xlink:href, 'http://numismatics.org')]/@xlink:href | $nudsGroup/descendant::nuds:symbol/descendant::tei:g[contains(@ref, 'http://numismatics.org')]/@ref |
					$subtypes/descendant::nuds:symbol[contains(@xlink:href, 'http://numismatics.org')]/@xlink:href | $subtypes/descendant::nuds:symbol/descendant::tei:g[contains(@ref, 'http://numismatics.org')]/@ref)">
				<xsl:variable name="href" select="."/>

				<xsl:if test="doc-available(concat($href, '.rdf'))">
					<xsl:copy-of select="document(concat($href, '.rdf'))/rdf:RDF/*"/>
				</xsl:if>
			</xsl:for-each>
		</rdf:RDF>
	</xsl:variable>

	<xsl:variable name="regions" as="element()*">
		<node>
			<xsl:if test="$regionHierarchy = true()">
				<xsl:variable name="mints"
					select="distinct-values($rdf//nmo:Mint/@rdf:about[contains(., 'nomisma.org')] | $rdf//nmo:Region/@rdf:about[contains(., 'nomisma.org')])"/>
				<xsl:variable name="identifiers" select="replace(string-join($mints, '|'), 'http://nomisma.org/id/', '')"/>

				<xsl:copy-of select="document(concat('http://nomisma.org/apis/regionHierarchy?identifiers=', encode-for-uri($identifiers)))"/>
			</xsl:if>
		</node>
	</xsl:variable>

	<!-- geographic boolean variables -->
	<xsl:variable name="hasMints" as="xs:boolean">
		<xsl:choose>
			<xsl:when
				test="$rdf//nmo:Mint[geo:location or skos:related] or $regions//mint[@lat and @long] or descendant::nuds:geographic/nuds:geogname[contains(@xlink:href, 'geonames.org')]"
				>true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="hasFindspots" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="descendant::nh:findspot/gml:location">true</xsl:when>
			<xsl:when test="descendant::nh:findspot/nh:fallsWithin/gml:location">true</xsl:when>
			<xsl:when test="descendant::nh:geogname[@xlink:role = 'findspot'][@xlink:href]">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- variable for whether or not geography has been enabled -->
	<xsl:variable name="geoEnabled" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="not(//config/baselayers/layer[@enabled = true()])">false</xsl:when>
			<xsl:otherwise>true</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="hasAnnotations" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="matches(//config/annotation_sparql_endpoint, 'https?://')">
				<xsl:choose>
					<xsl:when test="doc('input:annotations')[descendant::res:result]">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="hasSpecimens" select="number(doc('input:specimenCount')//res:sparql//descendant::res:binding[@name = 'count']/res:literal) &gt; 0"
		as="xs:boolean"/>
	<xsl:variable name="specimenCount" select="doc('input:specimenCount')//res:sparql/descendant::res:binding[@name = 'count']/res:literal" as="xs:integer"/>

	<!-- empty dies param (used in html-templates) -->
	<xsl:variable name="hasDies" as="xs:boolean">false</xsl:variable>

	<xsl:template match="/">
		<html
			prefix="geo: http://www.w3.org/2003/01/geo/wgs84_pos# foaf: http://xmlns.com/foaf/0.1/ dcterms: http://purl.org/dc/terms/ xsd: http://www.w3.org/2001/XMLSchema# nm:
			http://nomisma.org/id/ rdf: http://www.w3.org/1999/02/22-rdf-syntax-ns# skos: http://www.w3.org/2004/02/skos/core# nmo:
			http://nomisma.org/ontology# dcmitype: http://purl.org/dc/dcmitype/">
			<xsl:if test="string($lang)">
				<xsl:attribute name="lang" select="$lang"/>
			</xsl:if>
			<head>
				<xsl:call-template name="generic_head"/>

				<xsl:if test="$hasSpecimens">
					<!--- IIIF -->
					<script type="text/javascript" src="{$include_path}/javascript/leaflet-iiif.js"/>

					<!-- Add fancyBox for popups of coin images -->
					<link rel="stylesheet" href="{$include_path}/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
					<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
					<script type="text/javascript" src="{$include_path}/javascript/display_functions.js"/>
				</xsl:if>

				<!-- visualization -->
				<script type="text/javascript" src="{$include_path}/javascript/d3.min.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/d3plus-plot.full.min.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/display_hoard_functions.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/hoard_analysis_functions.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/search_functions.js"/>

				<!-- Add fancyBox -->
				<link rel="stylesheet" href="{$include_path}/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>

				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>
			</head>
			<body>

				<xsl:call-template name="header"/>
				<xsl:call-template name="display"/>
				<xsl:call-template name="footer"/>

				<div class="hidden">
					<span id="baselayers">
						<xsl:value-of select="string-join(//config/baselayers/layer[@enabled = true()], ',')"/>
					</span>
					<span id="collection_type">
						<xsl:value-of select="$collection_type"/>
					</span>
					<span id="path">
						<xsl:value-of select="concat($display_path, 'id/')"/>
					</span>
					<span id="display_path">
						<xsl:value-of select="$display_path"/>
					</span>
					<span id="include_path">
						<xsl:value-of select="$include_path"/>
					</span>
					<span id="pipeline">
						<xsl:value-of select="$pipeline"/>
					</span>
					<span id="mapboxKey">
						<xsl:value-of select="//config/mapboxKey"/>
					</span>
					<span id="lang">
						<xsl:value-of select="$lang"/>
					</span>
					<span id="page">record</span>
					<div id="filterHoards">
						<xsl:call-template name="search_forms"/>
					</div>					
					<span id="manifest"/>
					<div class="iiif-container-template" style="width:100%;height:100%"/>
					<iframe id="model-iframe-template" width="640" height="480" frameborder="0" allowvr="true" allowfullscreen="true" mozallowfullscreen="true"
						webkitallowfullscreen="true" onmousewheel=""/>
					<div id="iiif-window" style="width:600px;height:600px;display:none"/>
					<div id="model-window" style="width:640px;height:480px;display:none"/>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="display">
		<div class="container-fluid" typeof="nmo:Hoard" about="{$objectUri}">
			<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="/content/nh:nudsHoard"/>
		</div>
	</xsl:template>

	<xsl:template match="nh:nudsHoard">
		<xsl:call-template name="icons"/>

		<xsl:call-template name="nudsHoard_content"/>

		<!-- if there are coins from this hoard: -->
		<xsl:if test="$hasSpecimens = true()">
			<xsl:variable name="limit"
				select="
					if (//config/specimens_per_page castable as xs:integer) then
						//config/specimens_per_page
					else
						48"/>

			<xsl:apply-templates select="doc('input:specimens')/res:sparql" mode="hoard-examples">
				<xsl:with-param name="page" select="$page" as="xs:integer"/>
				<xsl:with-param name="numFound" select="$specimenCount" as="xs:integer"/>
				<xsl:with-param name="limit" select="$limit" as="xs:integer"/>
				<xsl:with-param name="endpoint"
					select="
						if (contains($sparql_endpoint, 'localhost')) then
							'http://nomisma.org/query'
						else
							$sparql_endpoint"/>
				<xsl:with-param name="objectUri" select="$objectUri"/>
				<xsl:with-param name="rtl" select="boolean(//config/languages/language[@code = $lang]/@rtl)"/>
			</xsl:apply-templates>
		</xsl:if>

		<!-- if there are annotations, then render -->
		<xsl:if test="$hasAnnotations = true()">
			<div class="row">
				<div class="col-md-12">
					<xsl:apply-templates select="doc('input:annotations')/res:sparql" mode="annotations">
						<xsl:with-param name="rtl" select="boolean(//config/languages/language[@code = $lang]/@rtl)"/>
					</xsl:apply-templates>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="nudsHoard_content">
		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="string(nh:descMeta/nh:title[@xml:lang = $lang])">
					<xsl:value-of select="nh:descMeta/nh:title[@xml:lang = $lang]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string(nh:descMeta/nh:title[@xml:lang = 'en'])">
							<xsl:value-of select="nh:descMeta/nh:title[@xml:lang = 'en']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(nh:descMeta/nh:title[1])"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="row">
			<div class="col-md-12">
				<h1 property="dcterms:title">
					<xsl:if test="string(nh:descMeta/nh:title/@xml:lang)">
						<xsl:attribute name="lang" select="nh:descMeta/nh:title/@xml:lang"/>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="string($title)">
							<xsl:value-of select="$title"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$id"/>
						</xsl:otherwise>
					</xsl:choose>
				</h1>
				<xsl:if test="$hasSpecimens = true()">
					<a href="#examples">Coins from this Hoard</a>
				</xsl:if>
				<xsl:if test="$hasSpecimens = true() and $hasAnnotations = true()">
					<xsl:text> | </xsl:text>
				</xsl:if>
				<xsl:if test="$hasAnnotations = true()">
					<a href="#annotations">Annotations</a>
				</xsl:if>
			</div>
		</div>
		<div class="row">
			<div class="col-md-{if ($geoEnabled = true() and ($hasMints = true() or $hasFindspots = true())) then '6' else '12'}">
				<div class="content">
					<xsl:if test="nh:descMeta/nh:hoardDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nh:descMeta/nh:hoardDesc"/>
						</div>
					</xsl:if>
					<xsl:if test="nh:descMeta/nh:refDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nh:descMeta/nh:refDesc"/>
						</div>
					</xsl:if>
					<xsl:if test="nh:descMeta/nh:noteSet">
						<div class="metadata_section">
							<h3>
								<xsl:value-of select="numishare:regularize_node('noteSet', $lang)"/>
							</h3>
							<ul>
								<xsl:apply-templates select="nh:descMeta/nh:noteSet/nh:note" mode="descMeta"/>
							</ul>
						</div>
					</xsl:if>
				</div>
			</div>

			<xsl:if test="$geoEnabled = true()">
				<xsl:if test="$hasMints = true() or $hasFindspots = true()">
					<div class="col-md-6">
						<div id="mapcontainer"/>
						<div class="legend">
							<table>
								<tbody>
									<tr>
										<th style="width:100px">
											<xsl:value-of select="numishare:normalizeLabel('maps_legend', $lang)"/>
										</th>
										<td style="background-color:#6992fd;border:2px solid black;width:50px;"/>
										<td style="width:100px">
											<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
										</td>
										<xsl:if test="$rdf//nmo:Mint[skos:related]">
											<!-- only display the uncertain mint key if there's an uncertain mint match -->
											<td style="background-color:#666666;border:2px solid black;width:50px;"/>
											<td style="width:150px;padding-left:6px;">
												<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
												<xsl:text> (uncertain)</xsl:text>
											</td>
										</xsl:if>
										<td style="background-color:#d86458;border:2px solid black;width:50px;"/>
										<td style="width:100px">
											<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
						<p>View map in <a href="{$display_path}map/{$id}">fullscreen</a>.</p>
					</div>
				</xsl:if>
			</xsl:if>
		</div>


		<!--********************************* RENDERING HOARD CONTENTS AND VISUALIZATION OPTIONS ******************************************* -->
		<xsl:if test="nh:descMeta/nh:contentsDesc/nh:contents/*">
			<div class="row">
				<div class="col-md-12">
					<hr/>
					<!-- if there are any calculable contents, display the interface -->
					<xsl:choose>
						<xsl:when test="nh:descMeta/nh:contentsDesc/nh:contents[nh:coin or nh:coinGrp[@count or @minCount or @maxCount]]">
							<ul class="nav nav-pills" id="tabs">
								<li class="active">
									<a href="#contents" data-toggle="pill">
										<xsl:value-of select="numishare:normalizeLabel('display_contents', $lang)"/>
									</a>
								</li>
								<li>
									<a href="#quantitative" data-toggle="pill">
										<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
									</a>
								</li>
							</ul>
							<div class="tab-content">
								<div class="tab-pane active" id="contents">
									<xsl:apply-templates select="nh:descMeta/nh:contentsDesc/nh:contents"/>
								</div>
								<div class="tab-pane" id="quantitative">
									<h1>
										<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
									</h1>
									<!-- the chart and downloadable/bookmarkable links are hidden by default on the hoard record page -->
									<xsl:call-template name="hoard-visualization">
										<xsl:with-param name="hidden" select="true()"/>
										<xsl:with-param name="page">record</xsl:with-param>
										<xsl:with-param name="compare" select="$id"/>
									</xsl:call-template>
								</div>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="nh:descMeta/nh:contentsDesc/nh:contents"/>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- ******** HOARD DESCRIPTION STRUCTURE ********-->
	<xsl:template match="nh:hoardDesc">
		<xsl:variable name="hasContents" as="xs:boolean">
			<xsl:choose>
				<xsl:when test="count(parent::node()/nh:contentsDesc/nh:contents/*) &gt; 0">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<h3>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h3>
		<ul>
			<!-- display deposit date if explicit, otherwise, attempt to derive from the contents -->
			<xsl:choose>
				<xsl:when test="nh:deposit[nh:date or nh:dateRange]">
					<xsl:apply-templates select="nh:deposit"/>
				</xsl:when>
				<xsl:when test="nh:closingDate[nh:date or nh:dateRange]">
					<xsl:apply-templates select="nh:closingDate"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$hasContents = true()">
						<xsl:variable name="all-dates" as="element()*">
							<dates>
								<xsl:for-each select="parent::node()/nh:contentsDesc/nh:contents/descendant::nuds:typeDesc">
									<xsl:choose>
										<xsl:when test="string(@xlink:href)">
											<xsl:variable name="href" select="@xlink:href"/>
											<xsl:for-each select="$nudsGroup//object[@xlink:href = $href]/descendant::*/@standardDate">
												<xsl:if test="number(.)">
													<date>
														<xsl:value-of select="."/>
													</date>
												</xsl:if>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<xsl:for-each select="descendant::*/@standardDate">
												<xsl:if test="number(.)">
													<date>
														<xsl:value-of select="."/>
													</date>
												</xsl:if>
											</xsl:for-each>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</dates>
						</xsl:variable>

						<xsl:variable name="dates" as="element()*">
							<dates>
								<xsl:for-each select="distinct-values($all-dates//date)">
									<xsl:sort data-type="number"/>
									<date>
										<xsl:value-of select="."/>
									</date>
								</xsl:for-each>
							</dates>
						</xsl:variable>

						<li>
							<b><xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/>: </b>
							<span property="nm:closing_date" content="{$dates//date[last()]}" datatype="xsd:gYear">
								<xsl:value-of select="numishare:normalizeDate($dates//date[last()])"/>
							</span>
						</li>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:apply-templates select="nh:discovery | nh:disposition"/>

			<!-- add description derived from contents -->
			<xsl:if test="$hasContents = true()">
				<xsl:variable name="contents" as="element()*">
					<xsl:copy-of select="parent::node()/nh:contentsDesc/nh:contents"/>
				</xsl:variable>

				<!-- parse the hoard contents into a human-readable description -->
				<xsl:variable name="description" select="numishare:hoardContentsDescription($contents, $nudsGroup, $rdf, $lang)"/>


				<xsl:if test="string-length($description) &gt; 0">
					<li>
						<b><xsl:value-of select="numishare:regularize_node('description', $lang)"/>: </b>
						<span property="dcterms:description">
							<xsl:value-of select="$description"/>
						</span>
					</li>
				</xsl:if>
			</xsl:if>
		</ul>

		<xsl:apply-templates select="nh:findspot"/>
	</xsl:template>

	<!-- ************ TOP LEVEL DESCRIPTIVE METADATA TEMPLATES ************-->
	<xsl:template match="nh:findspot">
		<h3>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h3>
		<ul>
			<xsl:if test="nh:description">
				<b><xsl:value-of select="numishare:regularize_node('description', $lang)"/>: </b>
				<xsl:value-of select="numishare:display-description(self::node(), $lang)"/>
			</xsl:if>

			<xsl:apply-templates select="nh:fallsWithin"/>
		</ul>
	</xsl:template>

	<xsl:template match="nh:fallsWithin">
		<li>
			<b>Falls Within: </b>
			<xsl:apply-templates select="nh:geogname[@xlink:role = 'findspot']"/>
		</li>
		<xsl:if test="nh:geogname[@xlink:role = 'ancient_place']">
			<li>
				<b>Ancient Place: </b>
				<xsl:apply-templates select="nh:geogname[@xlink:role = 'ancient_place']"/>
			</li>
		</xsl:if>

		<xsl:if test="nh:type">
			<li>
				<b><xsl:value-of select="numishare:regularize_node('type', $lang)"/>: </b>
				<xsl:apply-templates select="nh:type"/>
			</li>
		</xsl:if>

	</xsl:template>

	<xsl:template match="nh:geogname | nh:type">
		<xsl:variable name="facet" select="
				if (@xlink:role) then
					@xlink:role
				else
					'findspot_type'"/>


		<a href="{$display_path}results?q={$facet}_facet:&#x022;{.}&#x022;{if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}">
			<xsl:value-of select="."/>
		</a>
		<!-- display certainty -->
		<xsl:apply-templates select="@certainty"/>

		<xsl:if test="@xlink:href">
			<a href="{@xlink:href}" target="_blank" rel="{numishare:normalizeProperty($recordType, if(@xlink:role) then @xlink:role else local-name())}"
				class="external_link">
				<span class="glyphicon glyphicon-new-window"/>
			</a>
		</xsl:if>
		<xsl:if test="not(position() = last())">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nh:deposit | nh:discovery | nh:closingDate">
		<li>
			<b><xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>: </b>

			<xsl:choose>
				<xsl:when test="nh:date">
					<xsl:value-of select="nh:date"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="nh:dateRange/nh:fromDate"/>
					<xsl:text>-</xsl:text>
					<xsl:value-of select="nh:dateRange/nh:toDate"/>
				</xsl:otherwise>
			</xsl:choose>
		</li>
	</xsl:template>

	<xsl:template match="nh:disposition">
		<li>
			<b><xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>: </b>
			<xsl:value-of select="numishare:display-description(self::node(), $lang)"/>
		</li>
	</xsl:template>

	<!-- ************ CONTENTS ************-->
	<xsl:template match="nh:contents">
		<div class="metadata_section">
			<h3>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</h3>

			<xsl:if test="nh:description or (@count or @minCount or @maxCount)">
				<dl class="{if(//config/languages/language[@code = $lang]/@rtl = true()) then 'dl-horizontal dl-rtl' else 'dl-horizontal'}">
					<xsl:choose>
						<xsl:when test="@count or @minCount or @maxCount">
							<xsl:variable name="count-string">
								<xsl:choose>
									<xsl:when test="@count">
										<xsl:value-of select="@count"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test="@minCount and not(@maxCount)">
												<xsl:value-of select="concat(@minCount, '+')"/>
											</xsl:when>
											<xsl:when test="not(@minCount) and @maxCount">
												<xsl:value-of select="concat('&lt;', @maxCount)"/>
											</xsl:when>
											<xsl:when test="@minCount and @maxCount">
												<xsl:value-of select="concat(@minCount, '-', @maxCount)"/>
											</xsl:when>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<dt>
								<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
							</dt>
							<dd>
								<xsl:value-of select="$count-string"/>
							</dd>
							<xsl:if test="not($count-string = nh:description)">
								<xsl:apply-templates select="nh:description"/>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="nh:description"/>
						</xsl:otherwise>
					</xsl:choose>
				</dl>
			</xsl:if>

			<table class="table table-striped">
				<thead>
					<tr>
						<th style="width:10%" class="text-center">
							<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
						</th>
						<th>
							<xsl:value-of select="numishare:regularize_node('description', $lang)"/>
						</th>
						<th style="width:10%" class="text-center"/>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="descendant::nh:coin | descendant::nh:coinGrp"/>
				</tbody>
			</table>
		</div>
	</xsl:template>

	<!-- display table row for each coin or coinGrp -->
	<xsl:template match="nh:coin | nh:coinGrp">
		<xsl:variable name="obj-id" select="generate-id()"/>
		<xsl:variable name="typeDesc_resource">
			<xsl:if test="string(nuds:typeDesc/@xlink:href)">
				<xsl:value-of select="nuds:typeDesc/@xlink:href"/>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="typeDesc" as="element()*">
			<xsl:choose>
				<xsl:when test="string($typeDesc_resource)">
					<xsl:copy-of select="$nudsGroup//object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:typeDesc"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="nuds:typeDesc"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<tr>
			<td class="text-center">
				<!-- display counts -->
				<xsl:choose>
					<xsl:when test="self::nh:coin">1</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="@count">
								<xsl:value-of select="@count"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="@minCount and not(@maxCount)">
										<xsl:value-of select="concat(@minCount, '+')"/>
									</xsl:when>
									<xsl:when test="not(@minCount) and @maxCount">
										<xsl:value-of select="concat('&lt;', @maxCount)"/>
									</xsl:when>
									<xsl:when test="@minCount and @maxCount">
										<xsl:value-of select="concat(@minCount, '-', @maxCount)"/>
									</xsl:when>
									<xsl:otherwise>[uncertain]</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:if test="string($typeDesc_resource)">
					<!-- display labels for certainty codes -->
					<xsl:variable name="certainty" select="nuds:typeDesc/@certainty"/>
					
					<xsl:variable name="codeNode" as="element()*">
						<xsl:copy-of select="//config/certainty_codes/code[. = $certainty]"/>
					</xsl:variable>
					
					<xsl:choose>
						<xsl:when test="string($certainty) and string($codeNode)">
							
							<xsl:choose>
								<xsl:when test="$codeNode/@position='before'">
									<h3>
										<xsl:value-of select="$codeNode/@label"/>
										<a rel="nm:type_series_item" href="{$typeDesc_resource}" target="_blank">
											<xsl:value-of select="$nudsGroup//object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:title"/>
										</a>
									</h3>									
								</xsl:when>
								<xsl:when test="$codeNode/@position='after'">
									<h3>										
										<a rel="nm:type_series_item" href="{$typeDesc_resource}" target="_blank">
											<xsl:value-of select="$nudsGroup//object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:title"/>
										</a>
										<xsl:value-of select="$codeNode/@label"/>
									</h3>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="contains(@certainty, 'nomisma.org')">
							<h3>										
								<a rel="nm:type_series_item" href="{$typeDesc_resource}" target="_blank">
									<xsl:value-of select="$nudsGroup//object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:title"/>
								</a>
								<xsl:apply-templates select="@certainty"/>
							</h3>							
						</xsl:when>
						<xsl:otherwise>
							<h3>
								<a rel="nm:type_series_item" href="{$typeDesc_resource}" target="_blank">
									<xsl:value-of select="$nudsGroup//object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:title"/>
								</a>
							</h3>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>

				<!-- abstract the displayable stub for the contents summary from the display_stub field in the Numishare config -->
				<xsl:if test="string($display_stub)">
					<xsl:variable name="fields" select="tokenize($display_stub, ',')"/>

					<xsl:variable name="stub" as="element()*">
						<fields>
							<xsl:for-each select="$fields">
								<xsl:variable name="field" select="."/>

								<xsl:choose>
									<xsl:when test="$field = 'date'">
										<xsl:choose>
											<xsl:when test="$typeDesc/nuds:date">
												<field>
													<xsl:value-of select="$typeDesc/nuds:date[1]"/>
												</field>
											</xsl:when>
											<xsl:when test="$typeDesc/nuds:dateRange">
												<field>
													<xsl:value-of select="$typeDesc/nuds:dateRange/nuds:fromDate"/>
													<xsl:text>-</xsl:text>
													<xsl:value-of select="$typeDesc/nuds:dateRange/nuds:toDate"/>
												</field>
											</xsl:when>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<!-- ignore the <authority> element -->
										<xsl:if
											test="$typeDesc/descendant::*[(local-name() = $field and not(local-name() = 'authority')) or @xlink:role = $field]">
											<field>
												<xsl:for-each
													select="$typeDesc/descendant::*[(local-name() = $field and not(local-name() = 'authority')) or @xlink:role = $field]">
													<xsl:apply-templates select="self::node()" mode="stub"/>
													<xsl:if test="not(position() = last())">
														<xsl:text>/</xsl:text>
													</xsl:if>
												</xsl:for-each>
											</field>
										</xsl:if>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</fields>
					</xsl:variable>

					<xsl:value-of select="string-join($stub//field, ', ')"/>
				</xsl:if>

				<div class="coin-content" id="{$obj-id}-div" style="display:none">
					<xsl:apply-templates select="nuds:physDesc"/>
					<xsl:apply-templates select="$typeDesc">
						<xsl:with-param name="typeDesc_resource" select="$typeDesc_resource"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="nuds:refDesc"/>
				</div>
			</td>
			<td style="width:10%" class="text-center">
				<a href="#" class="toggle-coin" id="{$obj-id}-link">[more]</a>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="nh:description">
		<dt>
			<th>
				<xsl:value-of select="numishare:regularize_node('description', $lang)"/>
			</th>
		</dt>
		<dd>
			<xsl:value-of select="."/>
		</dd>
	</xsl:template>

	<xsl:template match="*" mode="stub">
		<xsl:variable name="href" select="@xlink:href"/>

		<xsl:choose>
			<xsl:when test="contains($href, 'nomisma.org')">
				<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], $lang)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
