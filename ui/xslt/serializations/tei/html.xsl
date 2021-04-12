<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date Modified: April 2021
	Function: Develop HTML page structure for EpiDoc
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:numishare="https://github.com/ewg118/numishare" xmlns:nm="http://nomisma.org/id/" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:org="http://www.w3.org/ns/org#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

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

	<!-- config variables -->
	<xsl:variable name="geonames-url">http://api.geonames.org</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="collection_type" select="/content/config/collection_type"/>
	<xsl:variable name="regionHierarchy" select="boolean(/content/config/facets/facet[text() = 'region_hier'])" as="xs:boolean"/>

	<!-- get layout -->
	<xsl:variable name="orientation" select="/content/config/theme/layouts/display/nuds/orientation"/>
	<xsl:variable name="image_location" select="/content/config/theme/layouts/display/nuds/image_location"/>
	<xsl:variable name="display_path">
		<xsl:choose>
			<xsl:when test="string(//config/uri_space)">
				<xsl:value-of select="$url"/>
			</xsl:when>
			<xsl:otherwise>../</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="include_path"
		select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>
	<xsl:variable name="id" select="//tei:TEI/@xml:id"/>
	<xsl:variable name="objectUri"
		select="
			if (/content/config/uri_space) then
				concat(/content/config/uri_space, $id)
			else
				concat($url, 'id/', $id)"/>

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
				<xsl:for-each select="
						distinct-values(descendant::*[contains(@ref,
						'nomisma.org')]/@ref)">
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

			<!-- read distinct skos:broaders for mints in the RDF -->
			<xsl:variable name="region-param">
				<xsl:for-each select="distinct-values($id-var//nmo:Mint/skos:broader[not(@rdf:resource = $id-var//*/@rdf:about)]/@rdf:resource)">
					<xsl:variable name="href" select="."/>

					<xsl:if test="not($id-var/*[@rdf:about = $href])">
						<xsl:value-of select="substring-after($href, 'id/')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="region-url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($region-param))"/>

			<xsl:variable name="region-var" as="element()*">
				<xsl:if test="doc-available($region-url)">
					<xsl:copy-of select="document($region-url)/rdf:RDF"/>
				</xsl:if>
			</xsl:variable>

			<!-- copy the contents of the API request variables into this variable -->
			<xsl:copy-of select="$id-var/*"/>
			<xsl:copy-of select="$org-var/*"/>
			<xsl:copy-of select="$region-var/*"/>
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

	<!-- variable for whether or not geography has been enabled -->
	<xsl:variable name="geoEnabled" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="not(//config/baselayers/layer[@enabled = true()])">false</xsl:when>
			<xsl:otherwise>true</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

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
				<!--- IIIF -->
				<xsl:if test="descendant::mets:file[@USE = 'iiif']">
					<script type="text/javascript" src="{$include_path}/javascript/leaflet-iiif.js"/>
					<script type="text/javascript" src="{$include_path}/javascript/display_iiif_functions.js"/>
				</xsl:if>

				<xsl:if test="$geoEnabled = true()">
					<script type="text/javascript" src="{$include_path}/javascript/display_map_functions.js"/>
				</xsl:if>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="display"/>
				<xsl:call-template name="footer"/>

				<div class="hidden">
					<span id="recordId">
						<xsl:value-of select="$id"/>
					</span>
					<span id="baselayers">
						<xsl:value-of select="string-join(//config/baselayers/layer[@enabled = true()], ',')"/>
					</span>
					<span id="collection_type">
						<xsl:value-of select="$collection_type"/>
					</span>
					<span id="path">
						<xsl:value-of select="concat($display_path, 'id/')"/>
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
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="display">
		<div class="container-fluid" typeof="nmo:NumismaticObject" about="{$objectUri}">
			<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>
			</xsl:if>

			<xsl:apply-templates select="//tei:TEI"/>
		</div>
	</xsl:template>

	<xsl:template match="tei:TEI">

		<div class="row">
			<div class="col-md-12">
				<h1 id="object_title" property="dcterms:title">
					<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
						<xsl:attribute name="style">direction: ltr; text-align:right</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="descendant::tei:titleStmt/tei:title"/>
				</h1>
			</div>
		</div>

		<div class="row">
			<div class="col-md-12">
				<xsl:call-template name="tei_content"/>
			</div>
		</div>
	</xsl:template>


	<!--********************************* NUDS STRUCTURE ******************************************* -->
	<xsl:template name="tei_content">
		<div class="row">
			<xsl:call-template name="metadata-container"/>
		</div>
		<xsl:if test="$geoEnabled = true()">
			<div class="row">
				<div class="col-md-12">
					<xsl:call-template name="map-container"/>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="metadata-container">
		<div class="col-md-6 {if(//config/languages/language[@code = $lang]/@rtl = true()) then 'pull-right' else ''}"> </div>
		<div class="col-md-6 {if(//config/languages/language[@code = $lang]/@rtl = true()) then 'pull-right' else ''}"> </div>
	</xsl:template>

	<xsl:template name="map-container">
		<h3>
			<xsl:value-of select="numishare:normalizeLabel('display_map', $lang)"/>
		</h3>
		<div id="mapcontainer"/>

		<!--<div class="legend">
			<table>
				<tbody>
					<tr>
						<th style="width:100px;background:none">
							<xsl:value-of select="numishare:normalizeLabel('maps_legend', $lang)"/>
						</th>
						<td style="background-color:#6992fd;border:2px solid black;width:50px;"/>
						<td style="width:100px;padding-left:6px;">
							<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
						</td>
						<xsl:if test="$rdf//nmo:Mint[skos:related]">
							<!-\- only display the uncertain mint key if there's an uncertain mint match -\->
							<td style="background-color:#666666;border:2px solid black;width:50px;"/>
							<td style="width:150px;padding-left:6px;">
								<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
								<xsl:text> (uncertain)</xsl:text>
							</td>
						</xsl:if>
						<td style="background-color:#d86458;border:2px solid black;width:50px;"/>
						<td style="width:100px;padding-left:6px;">
							<xsl:value-of select="numishare:regularize_node('hoard', $lang)"/>
						</td>
						<td style="background-color:#f98f0c;border:2px solid black;width:50px;"/>
						<td style="width:100px;padding-left:6px;">
							<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
						</td>
						<xsl:if test="descendant::nuds:subject[contains(@xlink:href, 'geonames.org')]">
							<td style="background-color:#00e64d;border:2px solid black;width:50px;"/>
							<td style="width:100px;padding-left:6px;">
								<xsl:value-of select="numishare:regularize_node('subject', $lang)"/>
							</td>
						</xsl:if>
					</tr>
				</tbody>
			</table>
		</div>-->
		<p>View map in <a href="{$display_path}map/{$id}">fullscreen</a>.</p>
	</xsl:template>

	<xsl:template name="generic_head">
		<title id="{$id}">
			<xsl:value-of select="//config/title"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="descendant::tei:titleStmt/tei:title"/>
		</title>
		<!-- alternates -->
		<link rel="alternate" type="application/xml" href="{$objectUri}.xml"/>
		<link rel="alternate" type="application/rdf+xml" href="{$objectUri}.rdf"/>
		<link rel="alternate" type="application/ld+json" href="{$objectUri}.jsonld"/>
		<link rel="alternate" type="application/ld+json" profile="https://linked.art/ns/v1/linked-art.json" href="{$objectUri}.jsonld?profile=linkedart"/>
		<link rel="alternate" type="text/turtle" href="{$objectUri}.ttl"/>
		<link rel="alternate" type="application/vnd.google-earth.kml+xml" href="{$objectUri}.kml"/>
		<link rel="alternate" type="application/vnd.geo+json" href="{$objectUri}.geojson"/>

		<!-- open graph metadata -->
		<meta property="og:url" content="{$objectUri}"/>
		<meta property="og:type" content="article"/>
		<meta property="og:title">
			<xsl:attribute name="content" select="descendant::tei:titleStmt/tei:title"/>
		</meta>

		<!-- twitter microdata -->
		<meta name="twitter:card" content="summary_large_image"/>
		<meta name="twitter:title">
			<xsl:attribute name="content" select="descendant::tei:titleStmt/tei:title"/>
		</meta>
		<meta name="twitter:url" content="{$objectUri}"/>


		<!--<xsl:for-each select="//mets:fileGrp[@USE = 'obverse']/mets:file[@USE = 'reference']/mets:FLocat/@xlink:href">
			<meta property="og:image" content="{.}"/>
			<meta name="twitter:image" content="{.}"/>
		</xsl:for-each>-->

		<!-- CSS -->
		<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
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
		<xsl:if test="string(//config/google_analytics)">
			<script type="text/javascript">
				<xsl:value-of select="//config/google_analytics"/>
			</script>
		</xsl:if>

		<!-- always include leaflet -->
		<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.0/dist/leaflet.css"/>
		<script type="text/javascript" src="https://unpkg.com/leaflet@1.0.0/dist/leaflet.js"/>
		<script type="text/javascript" src="{$include_path}/javascript/leaflet.ajax.min.js"/>
	</xsl:template>

</xsl:stylesheet>
