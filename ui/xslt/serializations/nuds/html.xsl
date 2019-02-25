<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:mets="http://www.loc.gov/METS/" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:nm="http://nomisma.org/id/"
	xmlns:gml="http://www.opengis.net/gml" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nuds="http://nomisma.org/nuds"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../templates-visualize.xsl"/>
	<!--<xsl:include href="../../templates-analyze.xsl"/>-->
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../object/html-templates.xsl"/>
	<xsl:include href="../sparql/type-examples.xsl"/>

	<!-- URL params -->
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
	<xsl:variable name="request-uri" select="concat('http://localhost:', if (//config/server-port castable as xs:integer) then //config/server-port else '8080', substring-before(doc('input:request')/request/request-uri, 'id/'))"/>
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
	<xsl:param name="mode" select="doc('input:request')/request/parameters/parameter[name = 'mode']/value"/>
	<xsl:param name="pipeline">display</xsl:param>

	<!-- pagination parameter for iterating through pages of physical speciments -->
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

	<!-- compare page params -->
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name = 'q']/value"/>
	<xsl:param name="start" select="doc('input:request')/request/parameters/parameter[name = 'start']/value"/>
	<xsl:param name="image" select="doc('input:request')/request/parameters/parameter[name = 'image']/value"/>
	<xsl:param name="side" select="doc('input:request')/request/parameters/parameter[name = 'side']/value"/>

	<!-- shared visualization/analysis params -->
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name = 'type']/value"/>
	<xsl:param name="chartType" select="doc('input:request')/request/parameters/parameter[name = 'chartType']/value"/>

	<!-- quantitative analysis parameters -->
	<xsl:param name="measurement" select="doc('input:request')/request/parameters/parameter[name = 'measurement']/value"/>
	<xsl:param name="numericType" select="doc('input:request')/request/parameters/parameter[name = 'numericType']/value"/>
	<xsl:param name="interval" select="doc('input:request')/request/parameters/parameter[name = 'interval']/value"/>
	<xsl:param name="fromDate" select="doc('input:request')/request/parameters/parameter[name = 'fromDate']/value"/>
	<xsl:param name="toDate" select="doc('input:request')/request/parameters/parameter[name = 'toDate']/value"/>
	<xsl:param name="sparqlQuery" select="doc('input:request')/request/parameters/parameter[name = 'sparqlQuery']/value"/>
	<xsl:variable name="tokenized_sparqlQuery" as="item()*">
		<xsl:sequence select="tokenize($sparqlQuery, '\|')"/>
	</xsl:variable>
	<xsl:variable name="duration" select="number($toDate) - number($fromDate)"/>

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

	<!-- get layout -->
	<xsl:variable name="orientation" select="/content/config/theme/layouts/display/nuds/orientation"/>
	<xsl:variable name="image_location" select="/content/config/theme/layouts/display/nuds/image_location"/>
	<xsl:variable name="display_path">
		<xsl:if test="not(string($mode))">
			<xsl:choose>
				<xsl:when test="string(//config/uri_space) and $recordType = 'physical'">
					<xsl:value-of select="$url"/>
				</xsl:when>
				<xsl:otherwise>../</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:variable>
	<xsl:variable name="include_path"
		select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>
	<xsl:variable name="recordType" select="//nuds:nuds/@recordType"/>
	<xsl:variable name="id" select="normalize-space(//*[local-name() = 'recordId'])"/>
	<xsl:variable name="objectUri"
		select="
			if (/content/config/uri_space) then
				concat(/content/config/uri_space, $id)
			else
				concat($url, 'id/', $id)"/>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:choose>
				<xsl:when test="descendant::nuds:typeDesc[string(@xlink:href)]">
					<xsl:variable name="uri" select="descendant::nuds:typeDesc/@xlink:href"/>

					<object xlink:href="{$uri}">
						<xsl:if test="doc-available(concat($uri, '.xml'))">
							<xsl:copy-of select="document(concat($uri, '.xml'))/nuds:nuds"/>
						</xsl:if>
					</object>
				</xsl:when>
				<xsl:when test="descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem'][string(@xlink:href)]">
					<object>
						<xsl:copy-of select="descendant::nuds:typeDesc"/>
					</object>
					
					<xsl:for-each select="descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem'][string(@xlink:href)]">
						<xsl:variable name="uri" select="@xlink:href"/>
						
						<object xlink:href="{$uri}">
							<xsl:if test="doc-available(concat($uri, '.xml'))">
								<xsl:copy-of select="document(concat($uri, '.xml'))/nuds:nuds"/>
							</xsl:if>
						</object>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<object>
						<xsl:copy-of select="descendant::nuds:typeDesc"/>
					</object>
				</xsl:otherwise>
			</xsl:choose>
		</nudsGroup>
	</xsl:variable>

	<xsl:variable name="symbols" as="element()*">
		<symbols>
			<xsl:for-each select="$nudsGroup/descendant::nuds:symbol[@xlink:href]">
				<xsl:variable name="href" select="@xlink:href"/>

				<xsl:if test="doc-available(concat($href, '.rdf'))">
					<xsl:copy-of select="document(concat($href, '.rdf'))"/>
				</xsl:if>
			</xsl:for-each>
		</symbols>
	</xsl:variable>

	<!-- get subtypes -->
	<xsl:variable name="subtypes" as="element()*">
		<xsl:if test="$recordType = 'conceptual' and //config/collection_type = 'cointype'">
			<xsl:if test="doc-available(concat($request-uri, 'get_subtypes?identifiers=', $id))">
				<xsl:copy-of select="document(concat($request-uri, 'get_subtypes?identifiers=', $id))/*"/>
			</xsl:if>
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="facets" select="string-join(//config//facet, ',')"/>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">
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

			<xsl:variable name="rdf_url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
			<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>
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

	<!-- whether there are coin types, mints, findspots, annotations, executed in XPL -->
	<xsl:variable name="hasSpecimens" select="number(//res:sparql[1]//descendant::res:binding[@name = 'count']/res:literal) &gt; 0" as="xs:boolean"/>
	<xsl:variable name="specimenCount" select="//res:sparql[1]/descendant::res:binding[@name = 'count']/res:literal" as="xs:integer"/>
	<xsl:variable name="hasFindspots" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$recordType = 'conceptual'">
				<xsl:choose>
					<xsl:when test="//res:sparql[2]/res:boolean">
						<xsl:value-of select="//res:sparql[2]/res:boolean"/>
					</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="descendant::nuds:findspotDesc/@xlink:href">true</xsl:when>
					<xsl:when test="descendant::nuds:geogname[@xlink:role = 'findspot'][contains(@xlink:href, 'geonames.org')]">true</xsl:when>
					<xsl:when test="descendant::nuds:findspot/gml:Point">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
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

	<xsl:variable name="hasMints" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$rdf//nmo:Mint[geo:location or skos:related] or $regions//mint[@lat and @long] or descendant::nuds:geographic/nuds:geogname[contains(@xlink:href, 'geonames.org')]">true</xsl:when>
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

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when
				test="count(descendant::*:otherRecordId[@semantic = 'dcterms:isReplacedBy']) &gt; 1 and descendant::*:control/*:maintenanceStatus = 'cancelledSplit'">
				<html>
					<head>
						<xsl:call-template name="generic_head"/>
					</head>
					<body>
						<xsl:call-template name="header"/>
						<div class="container-fluid">
							<xsl:if test="$lang = 'ar'">
								<xsl:attribute name="style">direction: rtl;</xsl:attribute>
							</xsl:if>
							<div class="row">
								<div class="col-md-12">
									<h1>
										<xsl:value-of select="$id"/>
									</h1>
									<p>This resource has been split and supplanted by the following new URIs:</p>
									<ul>
										<xsl:for-each select="descendant::*:otherRecordId[@semantic = 'dcterms:isReplacedBy']">
											<xsl:variable name="uri"
												select="
													if (contains(., 'http://')) then
														.
													else
														concat($url, 'id/', .)"/>
											<li>
												<a href="{$uri}">
													<xsl:value-of select="$uri"/>
												</a>
											</li>
										</xsl:for-each>
									</ul>
								</div>
							</div>
						</div>
						<xsl:call-template name="footer"/>
					</body>
				</html>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="construct_page"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="construct_page">
		<xsl:choose>
			<!-- regular HTML display mode-->
			<xsl:when test="not(string($mode))">
				<html
					prefix="geo: http://www.w3.org/2003/01/geo/wgs84_pos# foaf: http://xmlns.com/foaf/0.1/ dcterms: http://purl.org/dc/terms/ xsd: http://www.w3.org/2001/XMLSchema# nm:
					http://nomisma.org/id/ rdf: http://www.w3.org/1999/02/22-rdf-syntax-ns# skos: http://www.w3.org/2004/02/skos/core# nmo:
					http://nomisma.org/ontology# dcmitype: http://purl.org/dc/dcmitype/">
					<xsl:if test="string($lang)">
						<xsl:attribute name="lang" select="$lang"/>
					</xsl:if>
					<head>
						<xsl:call-template name="generic_head"/>
						<xsl:choose>
							<xsl:when test="$recordType = 'physical'">
								<xsl:if test="$geoEnabled = true()">
									<xsl:if test="$hasMints = true() or $hasFindspots = true()">
										<script type="text/javascript" src="{$include_path}/javascript/display_map_functions.js"/>
									</xsl:if>
								</xsl:if>

								<!--- IIIF -->
								<xsl:if test="descendant::mets:file[@USE = 'iiif']">
									<script type="text/javascript" src="{$include_path}/javascript/leaflet-iiif.js"/>
									<script type="text/javascript" src="{$include_path}/javascript/display_iiif_functions.js"/>
								</xsl:if>
							</xsl:when>
							<!-- coin-type CSS and JS dependencies -->
							<xsl:when test="$recordType = 'conceptual'">
								<!--- IIIF -->
								<script type="text/javascript" src="{$include_path}/javascript/leaflet-iiif.js"/>

								<!-- Add fancyBox -->
								<link rel="stylesheet" href="{$include_path}/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
								<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
								<script type="text/javascript" src="{$include_path}/javascript/highcharts.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/modules/exporting.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/display_functions.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/visualize_functions.js"/>

								<!-- mapping -->
								<xsl:if test="$geoEnabled = true()">
									<xsl:if test="$hasMints = true() or $hasFindspots = true()">
										<script type="text/javascript" src="http://openlayers.org/api/2.12/OpenLayers.js"/>
										<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.20&amp;sensor=false"/>
										<script type="text/javascript" src="{$include_path}/javascript/mxn.js"/>
										<script type="text/javascript" src="{$include_path}/javascript/timeline-2.3.0.js"/>
										<link type="text/css" href="{$include_path}/css/timeline-2.3.0.css" rel="stylesheet"/>
										<script type="text/javascript" src="{$include_path}/javascript/timemap_full.pack.js"/>
										<script type="text/javascript" src="{$include_path}/javascript/param.js"/>
										<script type="text/javascript" src="{$include_path}/javascript/display_map_functions.js"/>
									</xsl:if>
								</xsl:if>
							</xsl:when>

						</xsl:choose>
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
								<xsl:choose>
									<xsl:when test="$recordType = 'physical'">
										<xsl:value-of select="concat($display_path, 'id/')"/>
									</xsl:when>
									<xsl:when test="$recordType = 'conceptual' and $hasFindspots = false()">
										<xsl:value-of select="concat($display_path, 'id/')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$display_path"/>
									</xsl:otherwise>
								</xsl:choose>
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
							<xsl:if test="$recordType = 'conceptual'">
								<span id="hasFindspots">
									<xsl:value-of select="$hasFindspots"/>
								</span>
								<span id="manifest"/>
								<div class="iiif-container-template" style="width:100%;height:100%"/>
								<iframe id="model-iframe-template" width="640" height="480" frameborder="0" allowvr="true" allowfullscreen="true"
									mozallowfullscreen="true" webkitallowfullscreen="true" onmousewheel=""/>
								<div id="iiif-window" style="width:600px;height:600px;display:none"/>
								<div id="model-window" style="width:640px;height:480px;display:none"/>
							</xsl:if>
						</div>
					</body>
				</html>
			</xsl:when>
			<xsl:otherwise>
				<!-- only call display template for compare display -->
				<xsl:call-template name="display"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="display">
		<xsl:choose>
			<xsl:when test="$mode = 'compare'">
				<xsl:choose>
					<xsl:when test="count(/content/*[local-name() = 'nuds']) &gt; 0">
						<xsl:apply-templates select="//nuds:nuds"/>
					</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="typeof">
					<xsl:choose>
						<xsl:when test="$recordType = 'conceptual'">nmo:TypeSeriesItem</xsl:when>
						<xsl:when test="$recordType = 'physical'">nmo:NumismaticObject</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<div class="container-fluid" typeof="{$typeof}" about="{$objectUri}">
					<xsl:if test="$lang = 'ar'">
						<xsl:attribute name="style">direction: rtl;</xsl:attribute>
					</xsl:if>
					
					<xsl:apply-templates select="//nuds:nuds"/>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--<xsl:template name="nuds">
		<xsl:apply-templates select="/content/nuds:nuds"/>
	</xsl:template>-->

	<xsl:template match="nuds:nuds">
		<xsl:if test="$mode = 'compare'">
			<div class="compare_options">
				<small>
					<a
						href="compare_results?q={$q}&amp;start={$start}&amp;image={$image}&amp;side={$side}&amp;mode=compare{if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}"
						class="back_results">« Search results</a>
					<xsl:text> | </xsl:text>
					<a href="id/{$id}{if (string($langParam)) then concat('?lang=', $langParam) else ''}">Full record »</a>
				</small>
			</div>
		</xsl:if>
		<!-- below is a series of conditionals for forming the image boxes and displaying obverse and reverse images, iconography, and legends if they are available within the EAD document -->
		<xsl:choose>
			<xsl:when test="not($mode = 'compare')">
				<xsl:call-template name="icons"/>
				<xsl:choose>
					<xsl:when test="$recordType = 'conceptual'">
						<div class="row">
							<div class="col-md-12">
								<h1 id="object_title" property="skos:prefLabel">
									<xsl:if test="$lang = 'ar'">
										<xsl:attribute name="style">direction: ltr; text-align:right</xsl:attribute>
									</xsl:if>
									<xsl:choose>
										<xsl:when test="descendant::*:descMeta/*:title[@xml:lang = $lang]">
											<xsl:attribute name="lang" select="$lang"/>
											<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang = $lang]"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="lang">en</xsl:attribute>
											<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang = 'en']"/>
										</xsl:otherwise>
									</xsl:choose>
								</h1>

								<p>
									<xsl:if test="$hasSpecimens = true()">
										<a href="#examples">
											<xsl:value-of select="numishare:normalizeLabel('display_examples', $lang)"/>
										</a>
										<xsl:text> | </xsl:text>
									</xsl:if>
									<xsl:if test="count($subtypes//subtype) &gt; 0">
										<a href="#subtypes">Subtypes</a>
										<xsl:text> | </xsl:text>
									</xsl:if>
									<xsl:if test="$hasSpecimens = true()">
										<a href="#charts">
											<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
										</a>
									</xsl:if>
									<xsl:if test="$hasAnnotations = true()">
										<xsl:text> | </xsl:text>
										<a href="#annotations">Annotations</a>
									</xsl:if>
								</p>
								<xsl:if test="nuds:control/nuds:otherRecordId[@semantic = 'skos:broader']">
									<xsl:variable name="broader" select="nuds:control/nuds:otherRecordId[@semantic = 'skos:broader']"/>
									<p>Parent Type: <a href="{concat(//config/uri_space, $broader)}" rel="skos:broader"><xsl:value-of select="$broader"
										/></a></p>
								</xsl:if>
							</div>
						</div>
						<xsl:call-template name="nuds_content"/>

						<!-- examples and subtypes -->
						<xsl:if test="$hasSpecimens = true()">
							<xsl:variable name="limit"
								select="
									if (//config/specimens_per_page castable as xs:integer) then
										//config/specimens_per_page
									else
										48"/>

							<xsl:apply-templates select="doc('input:specimens')/res:sparql" mode="type-examples">
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
							</xsl:apply-templates>
						</xsl:if>

						<!-- handle subtypes if they exist -->
						<xsl:if test="count($subtypes//subtype) &gt; 0">
							<hr/>
							<a name="subtypes"/>
							<h3>Subtypes</h3>
							<xsl:apply-templates select="$subtypes//subtype">
								<xsl:sort select="@recordId" order="ascending"/>
								
								<xsl:with-param name="uri_space" select="//config/uri_space"/>
								<xsl:with-param name="endpoint"
									select="
										if (contains($sparql_endpoint, 'localhost')) then
											'http://nomisma.org/query'
										else
											$sparql_endpoint"
								/>
							</xsl:apply-templates>
						</xsl:if>

						<xsl:if test="$hasSpecimens = true()">
							<div class="row">
								<div class="col-md-12">
									<xsl:call-template name="charts"/>
								</div>
							</div>
						</xsl:if>

						<!-- if there are annotations, then render -->
						<xsl:if test="$hasAnnotations = true()">
							<div class="row">
								<div class="col-md-12">
									<xsl:apply-templates select="doc('input:annotations')/res:sparql" mode="annotations"/>
								</div>
							</div>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$recordType = 'physical'">
						<xsl:choose>
							<xsl:when test="$orientation = 'vertical'">
								<div class="row">
									<div class="col-md-12">
										<h1 id="object_title" property="dcterms:title">
											<xsl:if test="$lang = 'ar'">
												<xsl:attribute name="style">direction: ltr; text-align:right</xsl:attribute>
											</xsl:if>
											<xsl:choose>
												<xsl:when test="descendant::*:descMeta/*:title[@xml:lang = $lang]">
													<xsl:attribute name="lang" select="$lang"/>
													<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang = $lang]"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="lang">en</xsl:attribute>
													<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang = 'en']"/>
												</xsl:otherwise>
											</xsl:choose>
										</h1>
									</div>
								</div>

								<div class="row">
									<xsl:choose>
										<xsl:when test="$image_location = 'left'">
											<div class="col-md-4">
												<xsl:call-template name="image">
													<xsl:with-param name="side">obverse</xsl:with-param>
												</xsl:call-template>
												<xsl:call-template name="image">
													<xsl:with-param name="side">reverse</xsl:with-param>
												</xsl:call-template>
												<xsl:call-template name="legend_image"/>
											</div>
											<div class="col-md-8">
												<xsl:call-template name="nuds_content"/>
											</div>
										</xsl:when>
										<xsl:when test="$image_location = 'right'">
											<div class="col-md-8">
												<xsl:call-template name="nuds_content"/>
											</div>
											<div class="col-md-4">
												<xsl:call-template name="image">
													<xsl:with-param name="side">obverse</xsl:with-param>
												</xsl:call-template>
												<xsl:call-template name="image">
													<xsl:with-param name="side">reverse</xsl:with-param>
												</xsl:call-template>
												<xsl:call-template name="legend_image"/>
											</div>
										</xsl:when>
									</xsl:choose>
								</div>
							</xsl:when>
							<xsl:when test="$orientation = 'horizontal'">

								<div class="row">
									<div class="col-md-12">
										<h1 id="object_title" property="dcterms:title">
											<xsl:if test="$lang = 'ar'">
												<xsl:attribute name="style">direction: ltr; text-align:right</xsl:attribute>
											</xsl:if>
											<xsl:choose>
												<xsl:when test="descendant::*:descMeta/*:title[@xml:lang = $lang]">
													<xsl:attribute name="lang" select="$lang"/>
													<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang = $lang]"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="lang">en</xsl:attribute>
													<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang = 'en']"/>
												</xsl:otherwise>
											</xsl:choose>
										</h1>
									</div>
								</div>

								<xsl:choose>
									<xsl:when test="$image_location = 'top'">
										<div class="row">
											<div class="col-md-6">
												<xsl:call-template name="image">
													<xsl:with-param name="side">obverse</xsl:with-param>
												</xsl:call-template>

											</div>
											<div class="col-md-6">
												<xsl:call-template name="image">
													<xsl:with-param name="side">reverse</xsl:with-param>
												</xsl:call-template>
											</div>
										</div>
										<div class="row">
											<div class="col-md-12">
												<xsl:call-template name="nuds_content"/>
											</div>
										</div>
									</xsl:when>
									<xsl:when test="$image_location = 'bottom'">
										<div class="row">
											<div class="col-md-12">
												<xsl:call-template name="nuds_content"/>
											</div>
										</div>
										<div class="row">
											<div class="col-md-6">
												<xsl:call-template name="image">
													<xsl:with-param name="side">obverse</xsl:with-param>
												</xsl:call-template>
											</div>
											<div class="col-md-6">
												<xsl:call-template name="image">
													<xsl:with-param name="side">reverse</xsl:with-param>
												</xsl:call-template>
											</div>
										</div>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>

						<!-- if there are annotations, then render -->
						<xsl:if test="$hasAnnotations = true()">
							<div class="row">
								<div class="col-md-12">
									<xsl:apply-templates select="doc('input:annotations')/res:sparql" mode="annotations"/>
								</div>
							</div>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<div class="row">
					<div class="col-md-12">
						<xsl:call-template name="image">
							<xsl:with-param name="side">obverse</xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="image">
							<xsl:with-param name="side">reverse</xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="nuds_content"/>
					</div>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!--********************************* NUDS STRUCTURE ******************************************* -->
	<xsl:template name="nuds_content">
		<xsl:choose>
			<xsl:when test="$mode = 'compare'">
				<div>
					<xsl:apply-templates select="nuds:descMeta/nuds:physDesc[child::*]"/>
					<!-- apply-template only to NUDS-explicit typeDesc when there is one or more type references -->					
					<xsl:choose>
						<xsl:when test="nuds:descMeta/nuds:typeDesc[not(@xlink:href)]">
							<xsl:apply-templates select="nuds:descMeta/nuds:typeDesc"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="$nudsGroup//nuds:typeDesc">
								<xsl:variable name="typeDesc_resource" select="ancestor::object/@xlink:href"/>
								<xsl:apply-templates select=".">
									<xsl:with-param name="typeDesc_resource" select="$typeDesc_resource"/>
								</xsl:apply-templates>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="nuds:descMeta/nuds:undertypeDesc[child::*]"/>
					<xsl:apply-templates select="nuds:descMeta/nuds:refDesc[child::*]"/>
					<xsl:apply-templates select="nuds:descMeta/nuds:findspotDesc"/>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$recordType = 'conceptual'">
						<div class="row">
							<!-- if there are no mint coordinates and no findspots (from SPARQL), then do not show the map -->
							<xsl:choose>
								<xsl:when test="$geoEnabled = true()">
									<xsl:choose>
										<xsl:when test="$hasFindspots = false() and $hasMints = false()">
											<div class="col-md-12">
												<xsl:call-template name="metadata-container"/>
											</div>
										</xsl:when>
										<xsl:otherwise>
											<div class="col-md-6">
												<xsl:call-template name="metadata-container"/>
											</div>
											<div class="col-md-6">
												<xsl:call-template name="map-container"/>
											</div>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<div class="col-md-12">
										<xsl:call-template name="metadata-container"/>
									</div>
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="row">

							<xsl:if test="$hasAnnotations = true()">
								<div class="col-md-12">
									<a href="#annotations">Annotations</a>
								</div>
							</xsl:if>

							<xsl:call-template name="metadata-container"/>
						</div>
						<xsl:if test="$geoEnabled = true()">
							<xsl:if test="$hasMints = true() or $hasFindspots = true()">
								<div class="row">
									<div class="col-md-12">
										<xsl:call-template name="map-container"/>
									</div>
								</div>
							</xsl:if>
						</xsl:if>						
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="metadata-container">
		<xsl:choose>
			<xsl:when test="$recordType = 'conceptual'">
				<xsl:apply-templates select="$nudsGroup//nuds:typeDesc">
					<xsl:with-param name="typeDesc_resource" select="@xlink:href"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="nuds:descMeta/nuds:refDesc[child::*]"/>
				<xsl:apply-templates select="nuds:descMeta/nuds:descriptionSet[child::*]"/>
				<xsl:apply-templates select="nuds:descMeta/nuds:subjectSet[child::*]"/>
				<xsl:apply-templates select="nuds:descMeta/nuds:noteSet[child::*]"/>
			</xsl:when>
			<xsl:otherwise>
				<div class="col-md-6 {if($lang='ar') then 'pull-right' else ''}">
					<xsl:apply-templates select="nuds:descMeta/nuds:physDesc[child::*]"/>
					
					<!-- apply-template only to NUDS-explicit typeDesc when there is one or more type references -->					
					<xsl:choose>
						<xsl:when test="nuds:descMeta/nuds:typeDesc[not(@xlink:href)]">
							<xsl:apply-templates select="nuds:descMeta/nuds:typeDesc"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="$nudsGroup//nuds:typeDesc">
								<xsl:variable name="typeDesc_resource" select="ancestor::object/@xlink:href"/>
								<xsl:apply-templates select=".">
									<xsl:with-param name="typeDesc_resource" select="$typeDesc_resource"/>
								</xsl:apply-templates>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
						
					<xsl:apply-templates select="nuds:descMeta/nuds:undertypeDesc"/>
					<xsl:apply-templates select="nuds:descMeta/nuds:findspotDesc"/>
				</div>
				<div class="col-md-6 {if($lang='ar') then 'pull-right' else ''}">
					<xsl:apply-templates select="nuds:descMeta/nuds:refDesc[child::*]"/>
					<xsl:apply-templates select="nuds:descMeta/nuds:adminDesc[child::*]"/>
					<xsl:apply-templates select="nuds:descMeta/nuds:descriptionSet[child::*]"/>
					<xsl:apply-templates select="nuds:descMeta/nuds:subjectSet[child::*]"/>
					<xsl:apply-templates select="nuds:descMeta/nuds:noteSet[child::*]"/>
					<xsl:apply-templates select="nuds:control/nuds:rightsStmt[nuds:rights or nuds:license[@for = 'images'] or nuds:copyrightHolder]"/>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="map-container">
		<h3>
			<xsl:value-of select="numishare:normalizeLabel('display_map', $lang)"/>
		</h3>
		<xsl:choose>
			<xsl:when test="$recordType = 'conceptual'">
				<xsl:choose>
					<xsl:when test="$hasFindspots = true()">
						<div id="timemap">
							<div id="mapcontainer">
								<div id="map"/>
							</div>
							<div id="timelinecontainer">
								<div id="timeline"/>
							</div>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div id="mapcontainer"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<div id="mapcontainer"/>
			</xsl:otherwise>
		</xsl:choose>
		<div class="legend">
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
							<!-- only display the uncertain mint key if there's an uncertain mint match -->
							<td style="background-color:#666666;border:2px solid black;width:50px;"/>							
							<td style="width:150px;padding-left:6px;">
								<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
								<xsl:text> (uncertain)</xsl:text>
							</td>
						</xsl:if>
						<td style="background-color:#d86458;border:2px solid black;width:50px;"/>
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
		</div>
		<p>View map in <a href="{$display_path}map/{$id}">fullscreen</a>.</p>
	</xsl:template>

	<xsl:template match="nuds:undertypeDesc">
		<div class="metadata_section">
			<h3>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</h3>
			<ul>
				<xsl:apply-templates mode="descMeta"/>
			</ul>
		</div>
	</xsl:template>

	<xsl:template match="nuds:findspotDesc">
		<div class="metadata_section">
			<h3>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</h3>
			<xsl:choose>
				<xsl:when test="string(@xlink:href)">
					<xsl:choose>
						<xsl:when test="contains(@xlink:href, 'nomisma.org') or contains(@xlink:href, 'coinhoards.org')">
							<xsl:variable name="label">
								<xsl:choose>
									<xsl:when test="doc-available(concat(@xlink:href, '.rdf'))">
										<xsl:value-of select="document(concat(@xlink:href, '.rdf'))//skos:prefLabel[@xml:lang = 'en']"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="@xlink:href"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<ul>
								<li>
									<b><xsl:value-of select="numishare:regularize_node('hoard', $lang)"/>: </b>
									<a
										href="{$display_path}results?q=hoard_uri:&#x022;{@xlink:href}&#x022;{if (string($langParam)) then concat('&amp;lang=', $langParam) else
										''}">
										<xsl:value-of select="$label"/>
									</a>
									<a rel="nmo:hasFindspot" href="{@xlink:href}" target="_blank" class="external_link">
										<span class="glyphicon glyphicon-new-window"/>
									</a>
								</li>
							</ul>
						</xsl:when>
						<xsl:otherwise>
							<ul>
								<li>
									<b><xsl:value-of select="numishare:regularize_node('hoard', $lang)"/>: </b>
									<a
										href="{$display_path}results?q=hoard_uri:&#x022;{@xlink:href}&#x022;{if (string($langParam)) then concat('&amp;lang=', $langParam) else
										''}">
										<xsl:value-of select="@xlink:href"/>
									</a>
									<a rel="nmo:hasFindspot" href="{@xlink:href}" target="_blank" class="external_link">
										<span class="glyphicon glyphicon-new-window"/>
									</a>
								</li>
							</ul>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<ul>
						<xsl:apply-templates mode="descMeta"/>
					</ul>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template match="nuds:adminDesc">
		<div class="metadata_section">
			<h3>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</h3>
			<ul>
				<xsl:apply-templates mode="descMeta"/>
			</ul>
		</div>
	</xsl:template>


	<xsl:template match="nuds:rightsStmt">
		<div class="metadata_section">
			<h3>Rights</h3>
			<ul>
				<xsl:apply-templates select="nuds:license[@for = 'images'] | nuds:rights | nuds:copyrightHolder" mode="descMeta"/>
			</ul>
		</div>
	</xsl:template>

	<xsl:template match="nuds:subjectSet | nuds:noteSet">
		<div class="metadata_section">
			<h3>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</h3>
			<ul>
				<xsl:apply-templates mode="descMeta"/>
			</ul>
		</div>
	</xsl:template>
	
	<xsl:template match="nuds:descriptionSet">
		<div class="metadata_section">
			<h3>
				<xsl:value-of select="numishare:regularize_node('description', $lang)"/>
			</h3>
			
			<xsl:choose>
				<xsl:when test="nuds:description[@xml:lang=$lang]">
					<xsl:apply-templates select="nuds:description[@xml:lang=$lang]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="nuds:description[@xml:lang='en']">
							<xsl:apply-templates select="nuds:description[@xml:lang='en']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="nuds:description"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			
		</div>
	</xsl:template>

	<xsl:template match="nuds:note">
		<li>
			<xsl:value-of select="."/>
		</li>
	</xsl:template>

	<xsl:template match="nuds:provenance" mode="descMeta">
		<li>
			<h4>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</h4>
			<ul>
				<xsl:for-each select="descendant::nuds:chronItem">
					<li>
						<xsl:apply-templates select="*" mode="descMeta"/>
					</li>
				</xsl:for-each>
			</ul>
		</li>
	</xsl:template>

	<xsl:template match="nuds:descripton | nuds:legend" mode="physical">
		<span property="{numishare:normalizeProperty($recordType, local-name())}">
			<xsl:if test="@xml:lang">
				<xsl:attribute name="lang" select="@xml:lang"/>
			</xsl:if>
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<!-- hide symbols with left/right/center/exerque positions, format elsewhere -->
	<xsl:template
		match="nuds:symbol[@position = 'left'] | nuds:symbol[@position = 'center'] | nuds:symbol[@position = 'right'] | nuds:symbol[@position = 'exergue']"
		mode="descMeta"/>

	<!-- *********** IMAGE TEMPLATES FOR PHYSICAL OBJECTS ********** -->
	<xsl:template name="image">
		<xsl:param name="side"/>
		<xsl:variable name="reference-image" select="//mets:fileGrp[@USE = $side]/mets:file[@USE = 'reference']/mets:FLocat/@xlink:href"/>
		<xsl:variable name="iiif-service" select="//mets:fileGrp[@USE = $side]/mets:file[@USE = 'iiif']/mets:FLocat/@xlink:href"/>

		<!-- use the 'archive' direct URL for full-size download if available, otherwise like to IIIF service -->
		<xsl:variable name="full-url">
			<xsl:choose>
				<xsl:when test="//mets:fileGrp[@USE = $side]/mets:file[@USE = 'archive']/mets:FLocat/@xlink:href">
					<xsl:value-of select="//mets:fileGrp[@USE = $side]/mets:file[@USE = 'archive']/mets:FLocat/@xlink:href"/>
				</xsl:when>
				<xsl:when test="string($iiif-service)">
					<xsl:value-of select="concat($iiif-service, '/full/full/0/default.jpg')"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<div class="image-container">
			<xsl:choose>
				<xsl:when test="string($iiif-service)">
					<div id="{substring($side, 1, 3)}-iiif-container" class="iiif-container"/>
					<span class="hidden" id="{substring($side, 1, 3)}-iiif-service">
						<xsl:value-of select="$iiif-service"/>
					</span>
					<noscript>
						<img src="{concat($iiif-service, '/full/400,/0/default.jpg')}" property="foaf:depiction" alt="{$side}"/>
					</noscript>
					<div>
						<a href="{$full-url}" title="Full resolution image" rel="nofollow"><span class="glyphicon glyphicon-download-alt"/> Download full
							resolution image</a>
					</div>
				</xsl:when>
				<xsl:when test="string($reference-image)">
					<xsl:variable name="image_url"
						select="
							if (matches($reference-image, 'https?://')) then
								$reference-image
							else
								concat($display_path, $reference-image)"/>

					<img src="{$image_url}" property="foaf:depiction" alt="{$side}"/>

					<xsl:if test="string($full-url)">
						<div>
							<a href="{$full-url}" title="Full resolution image" rel="nofollow"><span class="glyphicon glyphicon-download-alt"/> Download full
								resolution image</a>
						</div>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
			<xsl:apply-templates select="$nudsGroup/object[1]/descendant::nuds:typeDesc/*[local-name() = $side]" mode="physical"/>
		</div>

	</xsl:template>

	<xsl:template match="nuds:obverse | nuds:reverse" mode="physical">
		<div>
			<strong>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
				<xsl:if test="string(nuds:legend) or string(nuds:type)">
					<xsl:text>: </xsl:text>
				</xsl:if>
			</strong>
			<xsl:apply-templates select="nuds:legend" mode="physical"/>
			<xsl:if test="string(nuds:legend) and string(nuds:type)">
				<xsl:text> - </xsl:text>
			</xsl:if>
			<!-- apply language-specific type description templates -->
			<xsl:choose>
				<xsl:when test="nuds:type/nuds:description[@xml:lang = $lang]">
					<xsl:apply-templates select="nuds:type/nuds:description[@xml:lang = $lang]" mode="physical"/>
				</xsl:when>
				<xsl:when test="nuds:type/nuds:description[@xml:lang = 'en']">
					<xsl:apply-templates select="nuds:type/nuds:description[@xml:lang = 'en']" mode="physical"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="nuds:type/nuds:description[1]" mode="physical"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template name="legend_image">
		<xsl:if test="string(//mets:fileGrp[@USE = 'legend']/mets:file[@USE = 'reference']/mets:FLocat/@xlink:href)">
			<xsl:variable name="src" select="//mets:fileGrp[@USE = 'legend']/mets:file[@USE = 'reference']/mets:FLocat/@xlink:href"/>

			<div class="reference_image">
				<img src="{if (contains($src, 'http://')) then $src else concat($display_path, $src)}" alt="legend"/>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- charts template -->
	<xsl:template name="charts">
		<xsl:variable name="axis"
			select="document(concat('http://nomisma.org/apis/avgAxis?type=', encode-for-uri($objectUri)))"/>
		<xsl:variable name="diameter"
			select="document(concat('http://nomisma.org/apis/avgDiameter?type=', encode-for-uri($objectUri)))"/>
		<xsl:variable name="weight"
			select="document(concat('http://nomisma.org/apis/avgWeight?type=', encode-for-uri($objectUri)))"/>

		<a name="charts"/>
		<h3>
			<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
		</h3>

		<xsl:if test="number($axis) &gt; 0 or number($diameter) &gt; 0 or number($weight) &gt; 0">
			<p>Average measurements for this coin type:</p>
			<dl class=" {if($lang='ar') then 'dl-horizontal ar' else 'dl-horizontal'}">
				<xsl:if test="number($axis) &gt; 0">
					<dt>
						<xsl:value-of select="numishare:regularize_node('axis', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="$axis"/>
					</dd>
				</xsl:if>
				<xsl:if test="number($diameter) &gt; 0">
					<dt>
						<xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="format-number($diameter, '##.##')"/>
					</dd>
				</xsl:if>
				<xsl:if test="number($weight) &gt; 0">
					<dt>
						<xsl:value-of select="numishare:regularize_node('weight', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="format-number($weight, '##.##')"/>
					</dd>
				</xsl:if>
			</dl>
		</xsl:if>

		<xsl:call-template name="measurementForm"/>
	</xsl:template>

	<xsl:template match="nuds:chronList | nuds:list">
		<ul class="list">
			<xsl:apply-templates/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:chronItem | nuds:item">
		<li>
			<xsl:apply-templates/>
		</li>
	</xsl:template>

	<xsl:template match="nuds:date">
		<xsl:choose>
			<xsl:when test="parent::nuds:chronItem">
				<i>
					<xsl:value-of select="."/>
				</i>
				<xsl:text>:  </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:event">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="nuds:eventgrp">
		<xsl:for-each select="nuds:event">
			<xsl:apply-templates select="."/>
			<xsl:if test="not(position() = last())">
				<xsl:text>; </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
