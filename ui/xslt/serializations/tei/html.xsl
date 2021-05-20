<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date Modified: May 2021
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
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="regionHierarchy" select="boolean(/content/config/facets/facet[text() = 'region_hier'])" as="xs:boolean"/>
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
	<xsl:variable name="id" select="descendant::tei:idno[@type='filename']"/>
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
				<xsl:for-each
					select="
						distinct-values(descendant::*[contains(@ref,
						'nomisma.org')]/@ref | descendant::*[contains(@period,
						'nomisma.org')]/@period)">
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
					<span id="collection_type">object</span>
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

	<!--********************************* TEI PAGE STRUCTURE ******************************************* -->
	<xsl:template match="tei:TEI">
		<xsl:call-template name="icons"/>
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

			<div class="col-md-6 {if(//config/languages/language[@code = $lang]/@rtl = true()) then 'pull-right' else ''}">

				<!-- typology and physical condition -->
				<xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc" mode="desc"/>
			</div>

			<div class="col-md-6 {if(//config/languages/language[@code = $lang]/@rtl = true()) then 'pull-right' else ''}">
				<xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc" mode="history"/>
			</div>
		</div>

		<xsl:if test="$geoEnabled = true()">
			<div class="row">
				<div class="col-md-12">
					<xsl:call-template name="map-container"/>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- TEI templates -->
	<xsl:template match="tei:msDesc" mode="desc">
		<xsl:apply-templates select="tei:physDesc"/>
	</xsl:template>

	<xsl:template match="tei:msDesc" mode="history">
		<xsl:apply-templates select="tei:history"/>
	</xsl:template>

	<!-- top-level sections -->
	<xsl:template match="tei:physDesc">
		<div class="metadata_section">
			<h3>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</h3>
			<ul>
				<xsl:if
					test="tei:objectDesc/tei:supportDesc/tei:support/tei:objectType or tei:objectDesc/tei:supportDesc/tei:support/tei:material or tei:objectDesc/tei:layoutDesc/tei:layout/tei:rs">
					<li>
						<h4>
							<xsl:value-of select="numishare:regularize_node('medium', $lang)"/>
						</h4>
						<ul>
							<xsl:apply-templates
								select="tei:objectDesc/tei:supportDesc/tei:support/tei:objectType | tei:objectDesc/tei:supportDesc/tei:support/tei:material"/>
							<xsl:apply-templates select="tei:objectDesc/tei:layoutDesc/tei:layout/tei:rs"/>
						</ul>
					</li>

				</xsl:if>

				<xsl:if test="tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions or tei:objectDesc/tei:supportDesc/tei:support/tei:measure">
					<li>
						<h4>
							<xsl:value-of select="numishare:regularize_node('measurementsSet', $lang)"/>
						</h4>
						<ul>
							<xsl:apply-templates
								select="tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/* | tei:objectDesc/tei:supportDesc/tei:support/tei:measure">
								<xsl:sort select="
										if (@type) then
											@type
										else
											local-name()"/>
							</xsl:apply-templates>
						</ul>
					</li>
				</xsl:if>
			</ul>
		</div>
	</xsl:template>

	<xsl:template match="tei:history">
		<div class="metadata_section">
			<h3>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</h3>

			<ul>
				<xsl:apply-templates select="tei:origin"/>
				<xsl:apply-templates select="tei:provenance"/>
				<xsl:apply-templates select="ancestor::tei:msDesc/tei:msIdentifier"/>
			</ul>
		</div>
	</xsl:template>

	<xsl:template match="tei:origin">
		<li>
			<h4>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</h4>
			<ul>
				<xsl:apply-templates select="tei:origPlace/tei:placeName | tei:origDate | tei:persName"/>
			</ul>
		</li>
	</xsl:template>

	<xsl:template match="tei:provenance">
		<li>
			<h4>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</h4>
			<ul>
				<xsl:apply-templates/>
			</ul>
		</li>
	</xsl:template>

	<xsl:template match="tei:msIdentifier">
		<li>
			<h4>
				<xsl:value-of select="numishare:regularize_node('collection', $lang)"/>
			</h4>
			<ul>
				<xsl:apply-templates select="tei:repository | tei:idno"/>
			</ul>
		</li>
	</xsl:template>

	<!-- metadata elements -->
	<xsl:template match="tei:objectType | tei:material | tei:rs | tei:measure | tei:dimensions/* | tei:persName | tei:placeName | tei:origDate | tei:date | tei:idno | tei:repository">
		<xsl:variable name="href" select="@ref"/>
		<xsl:variable name="field">
			<xsl:choose>
				<xsl:when test="string(@role)">
					<xsl:choose>
						<xsl:when test="matches(@role, 'https?://nomisma\.org')">
							<xsl:value-of select="tokenize(@role, '/')[last()]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@role"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="string(@type)">					
					<xsl:choose>
						<!-- convert EpiDoc 'execution' with numismatic 'manufacture' -->
						<xsl:when test="@type = 'execution'">manufacture</xsl:when>
						<!-- inventory, accession, etc. numbers labeled identifier -->
						<xsl:when test="@type = 'inventory'">identifier</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@type"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<!-- normalize misc. XML elements to existing fields, if possible -->
					<xsl:choose>
						<xsl:when test="local-name() = 'origDate'">period</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="local-name()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<li>
			<b>
				<xsl:value-of select="numishare:regularize_node($field, $lang)"/>
				<xsl:text>: </xsl:text>
			</b>

			<xsl:variable name="value">
				<xsl:choose>
					<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
						<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="not(string(.))">
								<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], 'en')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="self::tei:date or self::tei:origDate">
										<xsl:choose>
											<xsl:when test="string($lang)">
												<!--<xsl:value-of select="format-date(xs:date(concat(@standardDate, '-01-01')), '[Y1]-[Mno]-[D1] [E]', 'fr', 'AD', ())"/>-->
												<xsl:value-of select="normalize-space(.)"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="normalize-space(.)"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(.)"/>
									</xsl:otherwise>
								</xsl:choose>

							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:choose>
				<xsl:when test="$field = 'region' and $regionHierarchy = true() and contains($href, 'nomisma.org')"> </xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="display-label">
						<xsl:with-param name="field" select="$field"/>
						<xsl:with-param name="value" select="$value"/>
						<xsl:with-param name="href" select="$href"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>

			<!-- optional XML attributes -->
			<xsl:if test="@unit">
				<xsl:text> </xsl:text>
				<xsl:value-of select="@unit"/>
			</xsl:if>

			<xsl:if test="@notBefore or @notAfter">
				<i>
					<xsl:text> (</xsl:text>
					<xsl:if test="@notBefore">
						<xsl:value-of select="numishare:normalizeDate(@notBefore)"/>
					</xsl:if>
					<xsl:if test="@notBefore and @notAfter">
						<xsl:text>-</xsl:text>
					</xsl:if>
					<xsl:if test="@notAfter">
						<xsl:value-of select="numishare:normalizeDate(@notAfter)"/>
					</xsl:if>
					<xsl:text>)</xsl:text>
				</i>
			</xsl:if>

			<!-- create links to resources -->
			<xsl:if test="matches(@ref, 'https?://') or matches(@period, 'https?://')">
				<a href="{if (@ref) then @ref else @period}" target="_blank" rel="{numishare:normalizeProperty('physical', $field)}" class="external_link">
					<span class="glyphicon glyphicon-new-window"/>
				</a>
			</xsl:if>
		</li>
	</xsl:template>


	<!-- structural templates -->
	<xsl:template name="display-label">
		<xsl:param name="field"/>
		<xsl:param name="value"/>
		<xsl:param name="href"/>
		<xsl:param name="side"/>

		<xsl:variable name="facet" select="concat($field, '_facet')"/>

		<xsl:choose>
			<xsl:when test="boolean(index-of($facets, $facet)) = true()">
				<!-- if the $lang is enabled in the config (implying indexing into solr), then direct the user to the language-specific Solr query based on Nomisma prefLabel,
					otherwise use the English preferred label -->

				<xsl:variable name="queryValue">
					<xsl:choose>
						<xsl:when test="contains($href, 'nomisma.org') and not($langEnabled = true())">
							<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], 'en')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$value"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>


				<a
					href="{$display_path}results?q={$field}_facet:&#x022;{$queryValue}&#x022;{if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}">
					<xsl:choose>
						<xsl:when test="contains($href, 'geonames.org')">
							<xsl:choose>
								<xsl:when test="string(.)">
									<xsl:value-of select="normalize-space(.)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$value"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$value"/>
						</xsl:otherwise>
					</xsl:choose>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="map-container">
		<h3>
			<xsl:value-of select="numishare:normalizeLabel('display_map', $lang)"/>
		</h3>
		<div id="mapcontainer"/>

		<div class="legend">
			<table>
				<tbody>
					<tr>
						<th style="width:100px;background:none">
							<xsl:value-of select="numishare:normalizeLabel('maps_legend', $lang)"/>
						</th>
						<td style="background-color:#6992fd;border:2px solid black;width:50px;"/>
						<td style="width:100px;padding-left:6px;">
							<xsl:value-of select="numishare:regularize_node('productionPlace', $lang)"/>
						</td>
						<xsl:if test="$rdf//nmo:Mint[skos:related]">
							<!-- only display the uncertain mint key if there's an uncertain mint match -->
							<td style="background-color:#666666;border:2px solid black;width:50px;"/>
							<td style="width:150px;padding-left:6px;">
								<xsl:value-of select="numishare:regularize_node('productionPlace', $lang)"/>
								<xsl:text> (uncertain)</xsl:text>
							</td>
						</xsl:if>
						<td style="background-color:#d86458;border:2px solid black;width:50px;"/>
						<td style="width:100px;padding-left:6px;">
							<xsl:value-of select="numishare:regularize_node('hoard', $lang)"/>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
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

	<!--***************************************** OPTIONS BAR **************************************** -->
	<xsl:template name="icons">
		<div class="row pull-right icons">
			<div class="col-md-12">
				<ul class="list-inline">
					<li>
						<strong>EXPORT:</strong>
					</li>
					<li>
						<a href="{$id}.xml">NUDS/XML</a>
					</li>
					<li>
						<a href="{$id}.rdf">RDF/XML</a>
					</li>
					<li>
						<a href="{$id}.ttl">TTL</a>
					</li>
					<li>
						<a href="{$id}.jsonld">JSON-LD</a>
					</li>
					<li>
						<a href="{$id}.jsonld?profile=linkedart">Linked.art JSON-LD</a>
					</li>
					<xsl:if test="$geoEnabled">
						<li>
							<a href="{$id}.geojson">GeoJSON</a>
						</li>
					</xsl:if>
					<!--<xsl:if test="descendant::mets:file[@USE = 'iiif']">
						<xsl:variable name="manifestURI" select="concat($url, 'manifest/', $id)"/>
						
						<li>
							<a href="{$manifestURI}">IIIF Manifest</a>
							<xsl:text> </xsl:text>
							<a href="http://numismatics.org/mirador/?manifest={encode-for-uri($manifestURI)}">(view)</a>
						</li>
					</xsl:if>-->
				</ul>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
