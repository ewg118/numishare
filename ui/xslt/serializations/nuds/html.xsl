<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:mets="http://www.loc.gov/METS/" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:nm="http://nomisma.org/id/"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:nuds="http://nomisma.org/nuds" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../templates-visualize.xsl"/>
	<!--<xsl:include href="../../templates-analyze.xsl"/>-->
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../object/html-templates.xsl"/>
	<xsl:include href="../sparql/type-examples.xsl"/>

	<!-- URL params -->
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
	<xsl:variable name="request-uri" select="concat('http://localhost:8080', substring-before(doc('input:request')/request/request-uri, 'id/'))"/>
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
	<xsl:variable name="display_path" select="
			if (not(string($mode))) then
				'../search/'
			else
				''"/>
	<xsl:variable name="include_path" select="concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>
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
						'nomisma.org')]/@xlink:href | $nudsGroup/descendant::*[not(local-name() = 'object') and not(local-name() = 'typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
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
	<xsl:variable name="hasTypes" select="//res:sparql[1]/res:boolean" as="xs:boolean"/>
	<xsl:variable name="hasFindspots" select="//res:sparql[2]/res:boolean" as="xs:boolean"/>
	<xsl:variable name="hasAnnotations" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="/content/res:sparql[3][descendant::res:result]">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="hasMints" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$rdf//nmo:Mint or descendant::*[contains(@xlink:href, 'geonames.org')]">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
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
								<script type="text/javascript" src="{$include_path}/javascript/display_map_functions.js"/>
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
								<script type="text/javascript" src="{$include_path}/javascript/display_map_functions.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/display_functions.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/visualize_functions.js"/>

								<!-- mapping -->
								<script type="text/javascript" src="http://openlayers.org/api/2.12/OpenLayers.js"/>
								<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.20&amp;sensor=false"/>
								<script type="text/javascript" src="{$include_path}/javascript/mxn.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/timeline-2.3.0.js"/>
								<link type="text/css" href="{$include_path}/css/timeline-2.3.0.css" rel="stylesheet"/>
								<script type="text/javascript" src="{$include_path}/javascript/timemap_full.pack.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/param.js"/>
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
							</xsl:if>
						</div>
						<div id="iiif-window" style="width:600px;height:600px;display:none"/>
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
									<xsl:if test="$hasTypes = true()">
										<a href="#examples">
											<xsl:value-of select="numishare:normalizeLabel('display_examples', $lang)"/>
										</a>
										<xsl:text> | </xsl:text>
									</xsl:if>
									<xsl:if test="count($subtypes//subtype) &gt; 0">
										<a href="#subtypes">Subtypes</a>
										<xsl:text> | </xsl:text>
									</xsl:if>
									<a href="#charts">
										<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
									</a>
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
						<xsl:if test="$hasTypes = true()">
							<xsl:apply-templates select="document(concat($request-uri, 'apis/type-examples?id=', $id))/*" mode="type-examples"/>
						</xsl:if>

						<!-- handle subtypes if they exist -->
						<xsl:if test="count($subtypes//subtype) &gt; 0">
							<hr/>
							<a name="subtypes"/>
							<h3>Subtypes</h3>
							<xsl:apply-templates select="$subtypes//subtype">
								<xsl:with-param name="uri_space" select="//config/uri_space"/>
							</xsl:apply-templates>
						</xsl:if>
						<div class="row">
							<div class="col-md-12">
								<xsl:if test="$recordType = 'conceptual' and string($sparql_endpoint) and //config/collection_type = 'cointype'">
									<xsl:call-template name="charts"/>
								</xsl:if>
							</div>
						</div>

						<!-- if there are annotations, then render -->
						<xsl:if test="$hasAnnotations = true()">
							<div class="row">
								<div class="col-md-12">
									<xsl:apply-templates select="/content/res:sparql[3]" mode="annotations"/>
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
												<xsl:call-template name="obverse_image"/>
												<xsl:call-template name="reverse_image"/>
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
												<xsl:call-template name="obverse_image"/>
												<xsl:call-template name="reverse_image"/>
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
												<xsl:call-template name="obverse_image"/>
											</div>
											<div class="col-md-6">
												<xsl:call-template name="reverse_image"/>
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
												<xsl:call-template name="reverse_image"/>
											</div>
											<div class="col-md-6">
												<xsl:call-template name="obverse_image"/>
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
									<xsl:apply-templates select="/content/res:sparql[3]" mode="annotations"/>
								</div>
							</div>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<div class="row">
					<div class="col-md-12">
						<xsl:call-template name="obverse_image"/>
						<xsl:call-template name="reverse_image"/>
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
				<!-- process $typeDesc differently -->
				<div>
					<xsl:if test="nuds:descMeta/nuds:physDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:physDesc"/>
						</div>
					</xsl:if>
					<!-- process $typeDesc differently -->
					<div class="metadata_section">
						<xsl:apply-templates select="$nudsGroup//nuds:typeDesc">
							<xsl:with-param name="typeDesc_resource" select="@xlink:href"/>
						</xsl:apply-templates>
					</div>
					<xsl:if test="nuds:descMeta/nuds:undertypeDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:undertypeDesc"/>
						</div>
					</xsl:if>
					<xsl:if test="nuds:descMeta/nuds:refDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:refDesc"/>
						</div>
					</xsl:if>
					<xsl:if test="nuds:descMeta/nuds:findspotDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:findspotDesc"/>
						</div>
					</xsl:if>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$recordType = 'conceptual'">
						<div class="row">

							<!-- if there are no mint coordinates and no findspots (from SPARQL), then do not show the map -->
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
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="row">
							<xsl:call-template name="metadata-container"/>
						</div>
						<xsl:if test="$hasMints = true()">
							<div class="row">
								<div class="col-md-12">
									<xsl:call-template name="map-container"/>
								</div>
							</div>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="metadata-container">
		<xsl:choose>
			<xsl:when test="$recordType = 'conceptual'">
				<div class="metadata_section">
					<xsl:apply-templates select="$nudsGroup//nuds:typeDesc">
						<xsl:with-param name="typeDesc_resource" select="@xlink:href"/>
					</xsl:apply-templates>
				</div>
				<xsl:if test="nuds:descMeta/nuds:refDesc">
					<div class="metadata_section">
						<xsl:apply-templates select="nuds:descMeta/nuds:refDesc"/>
					</div>
				</xsl:if>
				<xsl:if test="nuds:descMeta/nuds:subjectSet">
					<div class="metadata_section">
						<xsl:apply-templates select="nuds:descMeta/nuds:subjectSet"/>
					</div>
				</xsl:if>
				<xsl:if test="nuds:descMeta/nuds:noteSet">
					<div class="metadata_section">
						<xsl:apply-templates select="nuds:descMeta/nuds:noteSet"/>
					</div>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<div class="col-md-6 {if($lang='ar') then 'pull-right' else ''}">
					<xsl:if test="nuds:descMeta/nuds:physDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:physDesc"/>
						</div>
					</xsl:if>
					<!-- process $typeDesc differently -->
					<div class="metadata_section">
						<xsl:for-each select="$nudsGroup//nuds:typeDesc">
							<xsl:variable name="typeDesc_resource" select="ancestor::object/@xlink:href"/>
							<xsl:apply-templates select=".">
								<xsl:with-param name="typeDesc_resource" select="$typeDesc_resource"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</div>
					<xsl:if test="nuds:descMeta/nuds:undertypeDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:undertypeDesc"/>
						</div>
					</xsl:if>
					<xsl:if test="nuds:descMeta/nuds:findspotDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:findspotDesc"/>
						</div>
					</xsl:if>
				</div>
				<div class="col-md-6">
					<xsl:if test="nuds:descMeta/nuds:refDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:refDesc"/>
						</div>
					</xsl:if>
					<xsl:if test="nuds:descMeta/nuds:adminDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:adminDesc"/>
						</div>
					</xsl:if>

					<xsl:if test="nuds:descMeta/nuds:subjectSet">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:subjectSet"/>
						</div>
					</xsl:if>
					<xsl:if test="nuds:descMeta/nuds:noteSet">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:noteSet"/>
						</div>
					</xsl:if>
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
							<xsl:value-of select="numishare:regularize_node('legend', $lang)"/>
						</th>
						<td style="background-color:#6992fd;border:2px solid black;width:50px;"/>
						<td style="width:100px">
							<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
						</td>
						<td style="background-color:#d86458;border:2px solid black;width:50px;"/>
						<td style="width:100px">
							<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
						</td>
						<xsl:if test="descendant::nuds:subject[contains(@xlink:href, 'geonames.org')]">
							<td style="background-color:#00e64d;border:2px solid black;width:50px;"/>
							<td style="width:100px">
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
		<h3>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h3>
		<ul>
			<xsl:apply-templates mode="descMeta"/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:findspotDesc">
		<h3>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h3>
		<xsl:choose>
			<xsl:when test="string(@xlink:href)">
				<xsl:choose>
					<xsl:when test="contains(@xlink:href, 'nomisma.org')">
						<xsl:variable name="elem" as="element()*">
							<findspot xlink:href="{@xlink:href}"/>
						</xsl:variable>
						<ul>
							<xsl:apply-templates select="$elem" mode="descMeta"/>
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<p>Source: <a rel="nmo:hasFindspot" href="{@xlink:href}"><xsl:value-of select="@xlink:href"/></a></p>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<ul>
					<xsl:apply-templates mode="descMeta"/>
				</ul>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:adminDesc">
		<h3>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h3>
		<ul>
			<xsl:apply-templates mode="descMeta"/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:subjectSet | nuds:noteSet">
		<h3>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h3>
		<ul>
			<xsl:apply-templates/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:subject">
		<li>
			<b><xsl:value-of select="
						if (string(@localType)) then
							@localType
						else
							numishare:regularize_node(local-name(), $lang)"/>: </b>
			<a
				href="{$display_path}results?q={if (string(@localType)) then @localType else 'subject'}_facet:&#x022;{normalize-space(.)}&#x022;{if (string($langParam)) then concat('&amp;lang=', $langParam) else
				''}">
				<xsl:value-of select="."/>
			</a>
			<xsl:if test="string(@xlink:href)">
				<a rel="dcterms:subject" href="{@xlink:href}" target="_blank" class="external_link">
					<span class="glyphicon glyphicon-new-window"/>
				</a>
			</xsl:if>
		</li>
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

	<xsl:template name="obverse_image">
		<xsl:variable name="obverse_image">
			<xsl:if test="string(//mets:fileGrp[@USE = 'obverse']/mets:file[@USE = 'reference']/mets:FLocat/@xlink:href)">
				<xsl:value-of select="//mets:fileGrp[@USE = 'obverse']/mets:file[@USE = 'reference']/mets:FLocat/@xlink:href"/>
			</xsl:if>
		</xsl:variable>

		<!-- display legend and type and image if available -->
		<xsl:choose>
			<xsl:when test="$nudsGroup//nuds:typeDesc/nuds:obverse">
				<xsl:for-each select="$nudsGroup//nuds:typeDesc/nuds:obverse">
					<xsl:variable name="side" select="local-name()"/>
					<div class="reference_image" rel="nmo:hasObverse">
						<xsl:if test="string($obverse_image)">
							<xsl:choose>
								<xsl:when test="contains($obverse_image, 'http://')">
									<img src="{$obverse_image}" property="foaf:depiction" alt="{$side}"/>
								</xsl:when>
								<xsl:otherwise>
									<img src="{$display_path}{$obverse_image}" property="foaf:depiction" alt="{$side}"/>
								</xsl:otherwise>
							</xsl:choose>
							<br/>
						</xsl:if>

						<b>
							<xsl:value-of select="numishare:regularize_node($side, $lang)"/>
							<xsl:if test="string(nuds:legend) or string(nuds:type)">
								<xsl:text>: </xsl:text>
							</xsl:if>
						</b>
						<xsl:apply-templates select="nuds:legend" mode="physical"/>
						<xsl:if test="string(nuds:legend) and string(nuds:type)">
							<xsl:text> - </xsl:text>
						</xsl:if>
						<xsl:apply-templates select="nuds:type/nuds:description" mode="physical"/>
					</div>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<!-- otherwise only display the image -->
				<xsl:if test="string($obverse_image)">
					<div class="reference_image">
						<img src="{if (contains($obverse_image, 'http://')) then $obverse_image else concat($display_path, $obverse_image)}"
							property="foaf:depiction" alt="{$side}"/>
					</div>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="reverse_image">
		<xsl:variable name="reverse_image">
			<xsl:if test="string(//mets:fileGrp[@USE = 'reverse']/mets:file[@USE = 'reference']/mets:FLocat/@xlink:href)">
				<xsl:value-of select="//mets:fileGrp[@USE = 'reverse']/mets:file[@USE = 'reference']/mets:FLocat/@xlink:href"/>
			</xsl:if>
		</xsl:variable>

		<!-- display legend and type and image if available -->
		<xsl:choose>
			<xsl:when test="$nudsGroup//nuds:typeDesc/nuds:reverse">
				<xsl:for-each select="$nudsGroup//nuds:typeDesc/nuds:reverse">
					<xsl:variable name="side" select="local-name()"/>
					<div class="reference_image" rel="nmo:hasReverse">
						<xsl:if test="string($reverse_image)">
							<xsl:choose>
								<xsl:when test="contains($reverse_image, 'http://')">
									<img src="{$reverse_image}" property="foaf:depiction" alt="{$side}"/>
								</xsl:when>
								<xsl:otherwise>
									<img src="{$display_path}{$reverse_image}" property="foaf:depiction" alt="{$side}"/>
								</xsl:otherwise>
							</xsl:choose>
							<br/>
						</xsl:if>

						<b>
							<xsl:value-of select="numishare:regularize_node($side, $lang)"/>
							<xsl:if test="string(nuds:legend) or string(nuds:type)">
								<xsl:text>: </xsl:text>
							</xsl:if>
						</b>
						<xsl:apply-templates select="nuds:legend" mode="physical"/>
						<xsl:if test="string(nuds:legend) and string(nuds:type)">
							<xsl:text> - </xsl:text>
						</xsl:if>
						<xsl:apply-templates select="nuds:type/nuds:description" mode="physical"/>
					</div>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<!-- otherwise only display the image -->
				<xsl:if test="string($reverse_image)">
					<div class="reference_image">
						<img src="{if (contains($reverse_image, 'http://')) then $reverse_image else concat($display_path, $reverse_image)}"
							property="foaf:depiction" alt="{$side}"/>
					</div>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
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
			select="document(concat($request-uri, 'sparql?constraints=', encode-for-uri(concat('nmo:hasTypeSeriesItem &lt;', //config/uri_space, $id, '&gt;')),
			'&amp;template=avgMeasurement&amp;measurement=axis'))"/>
		<xsl:variable name="diameter"
			select="document(concat($request-uri, 'sparql?constraints=', encode-for-uri(concat('nmo:hasTypeSeriesItem &lt;', //config/uri_space, $id, '&gt;')),
			'&amp;template=avgMeasurement&amp;measurement=diameter'))"/>
		<xsl:variable name="weight"
			select="document(concat($request-uri, 'sparql?constraints=', encode-for-uri(concat('nmo:hasTypeSeriesItem &lt;', //config/uri_space, $id, '&gt;')),
			'&amp;template=avgMeasurement&amp;measurement=weight'))"/>

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
						<xsl:value-of select="$diameter"/>
					</dd>
				</xsl:if>
				<xsl:if test="number($weight) &gt; 0">
					<dt>
						<xsl:value-of select="numishare:regularize_node('weight', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="$weight"/>
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
