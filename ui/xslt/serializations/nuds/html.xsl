<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date Modified: August 2020
	Function: Develop HTML page structure for NUDS documents for types/specimens. See ../object/html-templates.xsl for generate XSL templates for NUDS and NUDS-Hoard elements
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:mets="http://www.loc.gov/METS/" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:nm="http://nomisma.org/id/" xmlns:gml="http://www.opengis.net/gml"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:org="http://www.w3.org/ns/org#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nuds="http://nomisma.org/nuds"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../../vis-templates.xsl"/>
	<xsl:include href="../object/html-templates.xsl"/>
	<xsl:include href="../sparql/type-examples.xsl"/>
	<xsl:include href="../../controllers/metamodel-templates.xsl"/>
	<xsl:include href="../../controllers/sparql-metamodel.xsl"/>
	<xsl:include href="../../ajax/numishareResults.xsl"/>

	<!-- URL params -->
	<xsl:variable name="collection-name"
		select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
	<xsl:variable name="request-uri" select="
			concat('http://localhost:', if (//config/server-port castable as xs:integer) then
				//config/server-port
			else
				'8080', substring-before(doc('input:request')/request/request-uri, 'id/'))"/>
	<xsl:param name="langParam"
		select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when
				test="string(doc('input:request')/request//header[name[. = 'accept-language']]/value)">
				<xsl:value-of
					select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[. = 'accept-language']]/value)[1]"
				/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>

	<xsl:variable name="langEnabled"
		select="boolean(//config/languages/language[@code = $lang]/@enabled = true())"/>

	<xsl:param name="mode"
		select="doc('input:request')/request/parameters/parameter[name = 'mode']/value"/>
	<xsl:param name="pipeline">display</xsl:param>

	<!-- a boolean variable if there are both obverse and reverse images -->
	<xsl:variable name="sideImages" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="//mets:fileGrp[@USE = 'obverse'] and //mets:fileGrp[@USE = 'reverse']"
				>true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- pagination parameter for iterating through pages of physical specimens -->
	<xsl:param name="page" as="xs:integer">
		<xsl:choose>
			<xsl:when test="
					string-length(doc('input:request')/request/parameters/parameter[name = 'page']/value) &gt; 0 and doc('input:request')/request/parameters/parameter[name = 'page']/value castable
					as xs:integer and number(doc('input:request')/request/parameters/parameter[name = 'page']/value) > 0">
				<xsl:value-of
					select="doc('input:request')/request/parameters/parameter[name = 'page']/value"
				/>
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<!-- compare page params -->
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name = 'q']/value"/>
	<xsl:param name="start"
		select="doc('input:request')/request/parameters/parameter[name = 'start']/value"/>
	<xsl:param name="image"
		select="doc('input:request')/request/parameters/parameter[name = 'image']/value"/>
	<xsl:param name="side"
		select="doc('input:request')/request/parameters/parameter[name = 'side']/value"/>

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
	<xsl:variable name="regionHierarchy"
		select="boolean(/content/config/facets/facet[text() = 'region_hier'])" as="xs:boolean"/>

	<!-- get layout -->
	<xsl:variable name="orientation" select="/content/config/theme/layouts/display/nuds/orientation"/>
	<xsl:variable name="image_location"
		select="/content/config/theme/layouts/display/nuds/image_location"/>
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
	<xsl:variable name="include_path" select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>
	<xsl:variable name="recordType" select="//nuds:nuds/@recordType"/>
	<xsl:variable name="id" select="normalize-space(//*[local-name() = 'recordId'])"/>
	<xsl:variable name="manifestURI" select="concat($url, 'manifest/', $id)"/>
	<xsl:variable name="objectUri" select="
			if (/content/config/uri_space) then
				concat(/content/config/uri_space, $id)
			else
				concat($url, 'id/', $id)"/>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:choose>
				<xsl:when test="descendant::nuds:typeDesc[string(@xlink:href)]">
					<xsl:variable name="uri" select="descendant::nuds:typeDesc/@xlink:href"/>

					<xsl:call-template name="numishare:getNudsDocument">
						<xsl:with-param name="uri" select="$uri"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when
					test="descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem'][string(@xlink:href)]">
					<object>
						<xsl:copy-of select="descendant::nuds:typeDesc"/>
					</object>

					<xsl:for-each
						select="descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem'][string(@xlink:href)]">
						<xsl:variable name="uri" select="@xlink:href"/>

						<xsl:call-template name="numishare:getNudsDocument">
							<xsl:with-param name="uri" select="$uri"/>
						</xsl:call-template>
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

	<!-- get subtypes -->
	<xsl:variable name="subtypes" as="element()*">
		<xsl:if test="$recordType = 'conceptual' and $collection_type = 'cointype'">
			<xsl:copy-of select="doc('input:subtypes')/*"/>
		</xsl:if>
	</xsl:variable>

	<!-- get the facets as a sequence -->
	<xsl:variable name="facets" select="//config/facets/facet"/>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
			xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
			xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
			xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">

			<!-- aggregate distinct Nomisma URIs and perform an API lookup to get the RDF for all of them -->
			<xsl:variable name="id-param">
				<xsl:for-each select="
						distinct-values(descendant::*[not(local-name() = 'typeDesc') and not(local-name() = 'reference')][contains(@xlink:href,
						'nomisma.org')]/@xlink:href | $nudsGroup/descendant::*[not(local-name() = 'object') and not(local-name() = 'typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href | descendant::*[contains(@certainty, 'nomisma.org')]/@certainty | $nudsGroup/descendant::*[contains(@certainty, 'nomisma.org')]/@certainty | $subtypes/descendant::*[contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position() = last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="id-url"
				select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>

			<xsl:variable name="id-var" as="element()*">
				<xsl:if test="doc-available($id-url)">
					<xsl:copy-of select="document($id-url)/rdf:RDF"/>
				</xsl:if>
			</xsl:variable>

			<!-- read distinct org:organization and org:memberOf URIs from the initial RDF API request and request these, but only if they aren't in the initial request -->
			<xsl:variable name="org-param">
				<xsl:for-each
					select="distinct-values($id-var//org:organization/@rdf:resource | $id-var//org:memberOf/@rdf:resource)">
					<xsl:variable name="href" select="."/>

					<xsl:if test="not($id-var/*[@rdf:about = $href])">
						<xsl:value-of select="substring-after($href, 'id/')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="org-url"
				select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($org-param))"/>

			<xsl:variable name="org-var" as="element()*">
				<xsl:if test="doc-available($org-url)">
					<xsl:copy-of select="document($org-url)/rdf:RDF"/>
				</xsl:if>
			</xsl:variable>

			<!-- read distinct skos:broaders for mints in the RDF -->
			<xsl:variable name="region-param">
				<xsl:for-each
					select="distinct-values($id-var//nmo:Mint/skos:broader[not(@rdf:resource = $id-var//*/@rdf:about)]/@rdf:resource)">
					<xsl:variable name="href" select="."/>

					<xsl:if test="not($id-var/*[@rdf:about = $href])">
						<xsl:value-of select="substring-after($href, 'id/')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="region-url"
				select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($region-param))"/>

			<xsl:variable name="region-var" as="element()*">
				<xsl:if test="doc-available($region-url)">
					<xsl:copy-of select="document($region-url)/rdf:RDF"/>
				</xsl:if>
			</xsl:variable>

			<!-- copy the contents of the API request variables into this variable -->
			<xsl:copy-of select="$id-var/*"/>
			<xsl:copy-of select="$org-var/*"/>
			<xsl:copy-of select="$region-var/*"/>

			<!-- request RDF from the coinhoards.org URIs -->
			<xsl:if test="descendant::nuds:findspotDesc[contains(@xlink:href, 'coinhoards.org')]">
				<xsl:copy-of
					select="document(concat(descendant::nuds:findspotDesc/@xlink:href, '.rdf'))/rdf:RDF/*"
				/>
			</xsl:if>

			<!-- perform an RDF request for each distinct monogram/symbol URI -->
			<xsl:for-each select="
					distinct-values($nudsGroup/descendant::nuds:symbol[matches(@xlink:href, 'https?://numismatics\.org')]/@xlink:href | $nudsGroup/descendant::nuds:symbol/descendant::tei:g[matches(@ref, 'https?://numismatics\.org')]/@ref |
					$subtypes/descendant::nuds:symbol[matches(@xlink:href, 'https?://numismatics\.org')]/@xlink:href | $subtypes/descendant::nuds:symbol/descendant::tei:g[matches(@ref, 'https?://numismatics\.org')]/@ref)">
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
				<xsl:variable name="identifiers"
					select="replace(string-join($mints, '|'), 'http://nomisma.org/id/', '')"/>

				<xsl:copy-of
					select="document(concat('http://nomisma.org/apis/regionHierarchy?identifiers=', encode-for-uri($identifiers)))"
				/>
			</xsl:if>
		</node>
	</xsl:variable>

	<!-- whether there are coin types, mints, findspots, annotations, dies, executed in XPL -->
	<xsl:variable name="hasSpecimens"
		select="number(//res:sparql[1]//descendant::res:binding[@name = 'count']/res:literal) &gt; 0"
		as="xs:boolean"/>
	<xsl:variable name="specimenCount"
		select="//res:sparql[1]/descendant::res:binding[@name = 'count']/res:literal"
		as="xs:integer"/>
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
					<xsl:when
						test="descendant::nuds:geogname[@xlink:role = 'findspot'][contains(@xlink:href, 'geonames.org')]"
						>true</xsl:when>
					<xsl:when
						test="descendant::nuds:findspot/nuds:fallsWithin/gml:location/gml:Point"
						>true</xsl:when>
					<xsl:when test="descendant::nuds:findspot/gml:location">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="hasAnnotations" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="matches(//config/annotation_sparql_endpoint, 'https?://')">
				<xsl:choose>
					<xsl:when test="doc('input:annotations')[descendant::res:result]"
						>true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="hasDies" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="//config/die_study[@enabled = true()]">
				<xsl:choose>
					<xsl:when test="$recordType = 'conceptual'">
						<xsl:choose>
							<xsl:when test="$collection_type = 'cointype'">
								<!-- if there is a true() response for dies for any possible named graph, then $hasDies is true -->
								<xsl:value-of
									select="boolean(doc('input:hasDies')//res:boolean = true())"/>
							</xsl:when>
							<xsl:when test="$collection_type = 'die'">
								<xsl:value-of
									select="number(//res:sparql[1]//descendant::res:binding[@name = 'count']/res:literal) &gt; 0"
								/>
							</xsl:when>
							<xsl:otherwise>false</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="boolean(doc('input:hasDies')//res:boolean = true())"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="hasMints" as="xs:boolean">
		<xsl:choose>
			<xsl:when
				test="$rdf//nmo:Mint[geo:location or skos:related] or $rdf//nmo:Region[geo:location] or $regions//mint[@lat and @long] or descendant::nuds:geographic/nuds:geogname[contains(@xlink:href, 'geonames.org')]"
				>true</xsl:when>
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
			<xsl:when test="$mode = 'compare'">
				<!-- only call display template for compare display -->
				<xsl:call-template name="display"/>
			</xsl:when>
			<!-- regular HTML display mode-->
			<xsl:otherwise>
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
								<!--- IIIF -->

								<!-- use Leaflet for standard photographs of coins in IIIF -->
								<xsl:if
									test="descendant::mets:fileGrp[@USE = 'obverse' or @USE = 'reverse' or @USE = 'combined']/mets:file[@USE = 'iiif']">
									<script type="text/javascript" src="{$include_path}/javascript/leaflet-iiif.js"/>
									<script type="text/javascript" src="{$include_path}/javascript/display_iiif_functions.js"/>
								</xsl:if>

								<!-- display cards as a IIIF manifest loaded in Mirador -->
								<xsl:if
									test="descendant::mets:fileGrp[@USE = 'card']/descendant::mets:file[@USE = 'iiif']">
									<script type="text/javascript" src="{$include_path}/javascript/mirador.min.js"/>
									<script type="text/javascript" src="{$include_path}/javascript/display_mirador_functions.js"/>
								</xsl:if>

								<xsl:if test="$geoEnabled = true()">
									<xsl:if test="$hasMints = true() or $hasFindspots = true()">
										<script type="text/javascript" src="{$include_path}/javascript/display_map_functions.js"/>
									</xsl:if>
								</xsl:if>
							</xsl:when>
							<!-- coin-type CSS and JS dependencies -->
							<xsl:when test="$recordType = 'conceptual'">
								<!--- IIIF -->
								<script type="text/javascript" src="{$include_path}/javascript/leaflet-iiif.js"/>

								<!-- Add fancyBox -->
								<link rel="stylesheet"
									href="{$include_path}/css/jquery.fancybox.css?v=2.1.5"
									type="text/css" media="screen"/>
								<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
								<script type="text/javascript" src="{$include_path}/javascript/display_functions.js"/>

								<!-- visualization -->
								<script type="text/javascript" src="{$include_path}/javascript/d3.min.js"/>

								<xsl:if test="$collection_type = 'cointype'">
									<script type="text/javascript" src="{$include_path}/javascript/d3plus-plot.full.min.js"/>
									<script type="text/javascript" src="{$include_path}/javascript/vis_functions.js"/>

									<!-- if there are dies, then activate the die visualizations -->
									<xsl:if test="$hasDies = true()">
										<script type="text/javascript" src="{$include_path}/javascript/die_vis_functions.js"/>
									</xsl:if>

								</xsl:if>

								<!-- network graph functions -->
								<xsl:if test="$collection_type = 'die' and $hasSpecimens = true()">
									<script type="text/javascript" src="{$include_path}/javascript/d3plus-network.full.min.js"/>
									<script type="text/javascript" src="{$include_path}/javascript/network_functions.js"/>
								</xsl:if>

								<!-- mapping -->
								<xsl:if test="$geoEnabled = true()">
									<xsl:if test="$hasMints = true() or $hasFindspots = true()">

										<!-- commented out: LinkedPaths Leaflet libraries for timelines -->
										<!--<link type="text/css" href="{$include_path}/css/leaflet.timeline.css" rel="stylesheet"/>
										<link type="text/css" href="{$include_path}/css/vis-timeline-graph2d.min.css" rel="stylesheet"/>
										
										<script type="text/javascript" src="{$include_path}/javascript/IntervalTree.js"/>
										<script type="text/javascript" src="{$include_path}/javascript/moment.min.js"/>
										<script type="text/javascript" src="{$include_path}/javascript/Timeline.js"/>
										<script type="text/javascript" src="{$include_path}/javascript/TimelineSliderControl.js"/>
										<script type="text/javascript" src="{$include_path}/javascript/VisTimeline.js"/>
										<script type="text/javascript" src="{$include_path}/javascript/vis-timeline-graph2d.min.js"/>-->

										<script type="text/javascript" src="{$include_path}/javascript/display_map_functions.js"/>
									</xsl:if>
								</xsl:if>
							</xsl:when>

						</xsl:choose>
						<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"
						/>
					</head>
					<body>
						<xsl:call-template name="header"/>
						<xsl:call-template name="display"/>
						<xsl:call-template name="footer"/>

						<div class="hidden">
							<span id="recordId">
								<xsl:value-of select="$id"/>
							</span>
							<span id="objectURI">
								<xsl:value-of select="$objectUri"/>
							</span>
							<span id="baselayers">
								<xsl:value-of
									select="string-join(//config/baselayers/layer[@enabled = true()], ',')"
								/>
							</span>
							<span id="collection_type">
								<xsl:value-of select="$collection_type"/>
							</span>
							<span id="path">
								<xsl:choose>
									<xsl:when test="$recordType = 'physical'">
										<xsl:value-of select="concat($display_path, 'id/')"/>
									</xsl:when>
									<xsl:when test="$recordType = 'conceptual'">
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
							<span id="manifestURI">
								<xsl:value-of select="$manifestURI"/>
							</span>
							<span id="publisher">
								<xsl:value-of select="descendant::nuds:copyrightHolder"/>
							</span>


							<xsl:if test="$recordType = 'conceptual'">
								<!-- metrical analysis params -->
								<span id="page">record</span>
								<span id="interface">metrical</span>
								<span id="base-query">
									<xsl:value-of
										select="concat('nmo:hasTypeSeriesItem &lt;', $objectUri, '&gt;')"
									/>
								</span>

								<!-- include templates for form -->
								<xsl:call-template name="field-template">
									<xsl:with-param name="template" as="xs:boolean"
										>true</xsl:with-param>
								</xsl:call-template>

								<xsl:call-template name="compare-container-template">
									<xsl:with-param name="template" as="xs:boolean"
										>true</xsl:with-param>
								</xsl:call-template>

								<xsl:call-template name="date-template">
									<xsl:with-param name="template" as="xs:boolean"
										>true</xsl:with-param>
								</xsl:call-template>

								<xsl:call-template name="ajax-loader-template"/>

								<!-- die study/named graph variables -->
								<xsl:if test="//config/die_study[@enabled = true()]">
									<span id="dieStudy">
										<xsl:value-of select="//config/die_study/namedGraph"/>
									</span>
								</xsl:if>
								<xsl:if test="$collection_type = 'cointype'">
									<span id="die-frequencies-query">
										<xsl:value-of select="doc('input:die-frequencies-query')"/>
									</span>
								</xsl:if>


								<!-- IIIF -->
								<span id="hasFindspots">
									<xsl:value-of select="$hasFindspots"/>
								</span>
								<span id="manifest"/>
								<div class="iiif-container-template" style="width:100%;height:100%"/>
								<iframe id="model-iframe-template" width="640" height="480"
									frameborder="0" allowvr="true" allowfullscreen="true"
									mozallowfullscreen="true" webkitallowfullscreen="true"
									onmousewheel=""/>
								<div id="iiif-window" style="width:600px;height:600px;display:none"/>
								<div id="model-window" style="width:640px;height:480px;display:none"
								/>
							</xsl:if>
						</div>
					</body>
				</html>
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
					<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
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
					<a
						href="id/{$id}{if (string($langParam)) then concat('?lang=', $langParam) else ''}"
						>Full record »</a>
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
								<xsl:if
									test="nuds:control/nuds:publicationStatus = 'deprecatedType'">
									<div class="alert alert-box alert-danger">
										<span class="glyphicon glyphicon-exclamation-sign"/>
										<strong>Attention:</strong> This type has been deprecated,
										but does not link to a newer reference.</div>
								</xsl:if>

								<h1 id="object_title" property="skos:prefLabel">
									<xsl:if
										test="//config/languages/language[@code = $lang]/@rtl = true()">
										<xsl:attribute name="style">direction: ltr;
											text-align:right</xsl:attribute>
									</xsl:if>
									<xsl:choose>
										<xsl:when
											test="descendant::*:descMeta/*:title[@xml:lang = $lang]">
											<xsl:attribute name="lang" select="$lang"/>
											<xsl:value-of
												select="descendant::*:descMeta/*:title[@xml:lang = $lang]"
											/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="lang">en</xsl:attribute>
											<xsl:value-of
												select="descendant::*:descMeta/*:title[@xml:lang = 'en']"
											/>
										</xsl:otherwise>
									</xsl:choose>
								</h1>

								<p>
									<strong><xsl:value-of
											select="numishare:normalizeLabel('display_canonical_uri', $lang)"
										/>: </strong>
									<code>
										<a href="{$objectUri}" title="{$objectUri}">
											<xsl:value-of select="$objectUri"/>
										</a>
									</code>
								</p>

								<p>
									<xsl:if test="count($subtypes//subtype) &gt; 0">
										<a href="#subtypes">
											<xsl:value-of
												select="numishare:normalizeLabel('display_subtypes', $lang)"
											/>
										</a>
										<xsl:text> | </xsl:text>
									</xsl:if>
									<xsl:if test="$hasSpecimens = true()">
										<a href="#examples">
											<xsl:value-of select="
													if ($collection_type = 'cointype') then
														numishare:normalizeLabel('display_examples', $lang)
													else
														numishare:normalizeLabel('display_die_examples', $lang)"
											/>
										</a>
									</xsl:if>
									<!-- if the die_study is enabled, then display a section for die links -->
									<xsl:if test="$hasDies = true()">
										<xsl:text> | </xsl:text>
										<a href="#dieAnalysis">
											<xsl:value-of
												select="numishare:normalizeLabel('display_die_analysis', $lang)"
											/>
										</a>
									</xsl:if>
									<xsl:if
										test="$hasSpecimens = true() and $collection_type = 'cointype'">
										<xsl:text> | </xsl:text>
										<a href="#metrical">
											<xsl:value-of
												select="numishare:normalizeLabel('display_quantitative', $lang)"
											/>
										</a>
									</xsl:if>
									<xsl:if test="$hasAnnotations = true()">
										<xsl:text> | </xsl:text>
										<a href="#annotations">Annotations</a>
									</xsl:if>
								</p>
								<xsl:if
									test="nuds:control/nuds:otherRecordId[@semantic = 'skos:broader']">
									<xsl:variable name="broader"
										select="nuds:control/nuds:otherRecordId[@semantic = 'skos:broader']"/>
									<p><xsl:value-of
											select="numishare:normalizeLabel('display_parent_type', $lang)"
										/>: <a href="{concat(//config/uri_space, $broader)}"
											rel="skos:broader"><xsl:value-of select="$broader"
										/></a></p>
								</xsl:if>
							</div>
						</div>
						<xsl:call-template name="nuds_content"/>

						<!-- handle subtypes if they exist -->
						<xsl:if test="count($subtypes//subtype) &gt; 0">
							<div class="row" id="subtypes">
								<div class="col-md-12">
									<h3>
										<xsl:value-of
											select="numishare:normalizeLabel('display_subtypes', $lang)"
										/>
									</h3>
									<p>
										<xsl:value-of
											select="numishare:normalizeLabel('display_subtype_desc', $lang)"
										/>
									</p>
									<div class="table-responsive">
										<table class="table table-striped">
											<thead>
												<tr>
												<th>Subtype</th>
												<th>
												<xsl:value-of
												select="numishare:regularize_node('obverse', $lang)"
												/>
												</th>
												<th>
												<xsl:value-of
												select="numishare:regularize_node('reverse', $lang)"
												/>
												</th>
												<th style="width:320px">
												<xsl:value-of
												select="numishare:normalizeLabel('display_examples', $lang)"
												/>
												</th>
												</tr>
											</thead>
											<tbody>
												<xsl:apply-templates select="$subtypes//subtype">
												<xsl:sort select="
															if (@sortId) then
																@sortId
															else
																@recordId" order="ascending"/>


												<xsl:with-param name="uri_space"
												select="//config/uri_space"/>
												<xsl:with-param name="endpoint" select="
															if (contains($sparql_endpoint, 'localhost')) then
																'http://nomisma.org/query'
															else
																$sparql_endpoint"/>
												<xsl:with-param name="rtl"
												select="boolean(//config/languages/language[@code = $lang]/@rtl)"
												/>
												</xsl:apply-templates>
											</tbody>
										</table>
									</div>

									<hr/>

								</div>
							</div>
						</xsl:if>

						<!-- examples and subtypes -->
						<xsl:if test="$hasSpecimens = true()">
							<xsl:variable name="limit" select="
									if (//config/specimens_per_page castable as xs:integer) then
										//config/specimens_per_page
									else
										48"/>

							<!-- evaluate collection_type in order to determine which mode to apply to the res:sparql template -->
							<xsl:choose>
								<xsl:when test="$collection_type = 'cointype'">
									<xsl:apply-templates select="doc('input:specimens')/res:sparql"
										mode="type-examples">
										<xsl:with-param name="page" select="$page" as="xs:integer"/>
										<xsl:with-param name="numFound" select="$specimenCount"
											as="xs:integer"/>
										<xsl:with-param name="limit" select="$limit" as="xs:integer"/>
										<xsl:with-param name="endpoint" select="
												if (contains($sparql_endpoint, 'localhost')) then
													'http://nomisma.org/query'
												else
													$sparql_endpoint"/>
										<xsl:with-param name="objectUri" select="$objectUri"/>
										<xsl:with-param name="rtl"
											select="boolean(//config/languages/language[@code = $lang]/@rtl)"/>
										<xsl:with-param name="subtypes" as="xs:boolean"
											select="boolean(doc('input:subtypes')//subtype)"/>
									</xsl:apply-templates>
								</xsl:when>
								<xsl:when test="$collection_type = 'die'">

									<!-- display associated coin types -->
									<xsl:apply-templates select="doc('input:die-types')//res:sparql"
										mode="die-types"/>

									<!-- form the SPARQL query and pass it to the template parameter -->
									<xsl:variable name="statements" as="element()*">
										<statements>
											<union>
												<xsl:for-each select="//config/die_study/namedGraph">
												<group>
												<xsl:call-template name="numishare:graph-group">
												<xsl:with-param name="uri" select="$objectUri"/>
												<xsl:with-param name="namedGraph" select="."/>
												<xsl:with-param name="side"
												>Obverse</xsl:with-param>
												</xsl:call-template>
												</group>
												<group>
												<xsl:call-template name="numishare:graph-group">
												<xsl:with-param name="uri" select="$objectUri"/>
												<xsl:with-param name="namedGraph" select="."/>
												<xsl:with-param name="side"
												>Reverse</xsl:with-param>
												</xsl:call-template>
												</group>
												</xsl:for-each>
											</union>
										</statements>
									</xsl:variable>

									<xsl:variable name="statementsSPARQL">
										<xsl:apply-templates select="$statements/*"/>
									</xsl:variable>

									<xsl:apply-templates select="doc('input:specimens')/res:sparql"
										mode="die-examples">
										<xsl:with-param name="query"
											select="replace(doc('input:query'), '%STATEMENTS%', $statementsSPARQL)"/>
										<xsl:with-param name="page" select="$page" as="xs:integer"/>
										<xsl:with-param name="numFound" select="$specimenCount"
											as="xs:integer"/>
										<xsl:with-param name="limit" select="$limit" as="xs:integer"/>
										<xsl:with-param name="endpoint" select="
												if (contains($sparql_endpoint, 'localhost')) then
													'http://nomisma.org/query'
												else
													$sparql_endpoint"/>
										<xsl:with-param name="objectUri" select="$objectUri"/>
										<xsl:with-param name="rtl"
											select="boolean(//config/languages/language[@code = $lang]/@rtl)"
										/>
									</xsl:apply-templates>
								</xsl:when>
							</xsl:choose>
						</xsl:if>

						<!-- display die analysis, visualization, only if there are dies in the SPARQL endpoint -->
						<xsl:if test="$hasDies = true()">
							<div class="row" id="dieAnalysis">
								<div class="col-md-12">
									<h3>
										<xsl:value-of
											select="numishare:normalizeLabel('display_die_analysis', $lang)"
										/>
									</h3>

									<!-- only display options for die calculations in coin type corpora, not die URIs -->
									<xsl:if test="$collection_type = 'cointype'">
										<div id="dieCount-container"/>

										<div class="chart-container">
											<div id="dieVis-chart" style="height:600px"/>
										</div>
									</xsl:if>

									<!-- display a div for each d3js forced network graph for each namedGraph for die attributions -->
									<xsl:for-each select="//config/die_study/namedGraph">
										<xsl:variable name="position" select="position()"/>


										<xsl:choose>
											<!-- only display the table if there are links -->
											<xsl:when
												test="doc('input:dies')//res:sparql[$position]/descendant::res:result">
												<h4>
												<xsl:text>Attribution: </xsl:text>
												<a href="{.}">
												<xsl:value-of select="."/>
												</a>
												</h4>

												<!-- only display graph on die pages -->
												<xsl:if test="$collection_type = 'die'">
												<div namedGraph="{.}" class="network-graph hidden"
												id="{generate-id()}"/>
												</xsl:if>

												<!-- display die link table only in a type page -->
												<div>
												<h4>Die Links</h4>

												<!-- serialize the SPARQL response relevant to the named graph into an HTML table -->
												<xsl:choose>
												<xsl:when test="$collection_type = 'cointype'">
												<xsl:apply-templates
												select="doc('input:dies')//res:sparql[$position]"
												mode="die-links">
												<xsl:with-param name="reverse" as="xs:boolean"
												>false</xsl:with-param>
												</xsl:apply-templates>
												</xsl:when>
												<xsl:when test="$collection_type = 'die'">
												<xsl:choose>
												<xsl:when
												test="count(doc('input:dies')/dies/obverse/res:sparql[$position]/descendant::res:result) &gt; 0">
												<xsl:apply-templates
												select="doc('input:dies')/dies/obverse/res:sparql[$position]"
												mode="die-links">
												<xsl:with-param name="reverse" as="xs:boolean"
												>false</xsl:with-param>
												</xsl:apply-templates>
												</xsl:when>
												<xsl:when
												test="count(doc('input:dies')/dies/reverse/res:sparql[$position]/descendant::res:result) &gt; 0">
												<xsl:apply-templates
												select="doc('input:dies')/dies/reverse/res:sparql[$position]"
												mode="die-links">
												<xsl:with-param name="reverse" as="xs:boolean"
												>true</xsl:with-param>
												</xsl:apply-templates>
												</xsl:when>
												</xsl:choose>
												</xsl:when>
												</xsl:choose>
												</div>
											</xsl:when>
											<!-- otherwise, display an alert about the lack of dies links -->
											<xsl:otherwise>
												<div class="alert alert-box alert-info">
												<span class="glyphicon glyphicon-info-sign"/>
												<strong>Attention:</strong> There are dies
												associated with this type, but no links between
												obverse and reverse dies.</div>
											</xsl:otherwise>
										</xsl:choose>

									</xsl:for-each>
								</div>
							</div>
						</xsl:if>

						<xsl:if test="$hasSpecimens = true() and $collection_type = 'cointype'">
							<div class="row" id="metrical">
								<div class="col-md-12">
									<xsl:call-template name="charts"/>
								</div>
							</div>
						</xsl:if>

						<!-- if there are annotations, then render -->
						<xsl:if test="$hasAnnotations = true()">
							<div class="row">
								<div class="col-md-12">
									<xsl:apply-templates
										select="doc('input:annotations')/res:sparql"
										mode="annotations">
										<xsl:with-param name="rtl"
											select="boolean(//config/languages/language[@code = $lang]/@rtl)"
										/>
									</xsl:apply-templates>
								</div>
							</div>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$recordType = 'physical'">
						<div class="row">
							<div class="col-md-12">
								<h1 id="object_title" property="dcterms:title">
									<xsl:if
										test="//config/languages/language[@code = $lang]/@rtl = true()">
										<xsl:attribute name="style">direction: ltr;
											text-align:right</xsl:attribute>
									</xsl:if>
									<xsl:choose>
										<xsl:when
											test="descendant::*:descMeta/*:title[@xml:lang = $lang]">
											<xsl:attribute name="lang" select="$lang"/>
											<xsl:value-of
												select="descendant::*:descMeta/*:title[@xml:lang = $lang]"
											/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="lang">en</xsl:attribute>
											<xsl:value-of
												select="descendant::*:descMeta/*:title[@xml:lang = 'en']"
											/>
										</xsl:otherwise>
									</xsl:choose>
								</h1>

								<p>
									<strong>Canonical URI: </strong>
									<code>
										<a href="{$objectUri}" title="{$objectUri}">
											<xsl:value-of select="$objectUri"/>
										</a>
									</code>
								</p>
							</div>
						</div>

						<!-- if there are not METS files, then only display the NUDS content -->
						<xsl:choose>
							<xsl:when test="descendant::mets:fileSec">
								<xsl:choose>
									<xsl:when test="$orientation = 'vertical'">
										<div class="row">
											<xsl:choose>
												<xsl:when test="$image_location = 'left'">
												<div class="col-md-4">
												<xsl:call-template name="image">
												<xsl:with-param name="side"
												>obverse</xsl:with-param>
												</xsl:call-template>
												<xsl:call-template name="image">
												<xsl:with-param name="side"
												>reverse</xsl:with-param>
												</xsl:call-template>
												<xsl:call-template name="image">
												<xsl:with-param name="side"
												>combined</xsl:with-param>
												</xsl:call-template>

												<!-- show additional images -->
												<xsl:if
												test="descendant::mets:fileGrp[not(@USE = 'obverse') and not(@USE = 'reverse') and not(@USE = 'combined') and not(@USE = 'legend')]">
												<h3>Additional Images</h3>
												<xsl:for-each
												select="descendant::mets:fileGrp[not(@USE = 'obverse') and not(@USE = 'reverse') and not(@USE = 'combined') and not(@USE = 'legend')]">
												<xsl:call-template name="image">
												<xsl:with-param name="side" select="@USE"/>
												</xsl:call-template>
												</xsl:for-each>
												</xsl:if>

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
												<xsl:with-param name="side"
												>obverse</xsl:with-param>
												</xsl:call-template>
												<xsl:call-template name="image">
												<xsl:with-param name="side"
												>reverse</xsl:with-param>
												</xsl:call-template>
												<xsl:call-template name="image">
												<xsl:with-param name="side"
												>combined</xsl:with-param>
												</xsl:call-template>

												<!-- show additional images -->
												<xsl:if
												test="descendant::mets:fileGrp[not(@USE = 'obverse') and not(@USE = 'reverse') and not(@USE = 'combined') and not(@USE = 'legend')]">
												<h3>Additional Images</h3>
												<xsl:for-each
												select="descendant::mets:fileGrp[not(@USE = 'obverse') and not(@USE = 'reverse') and not(@USE = 'combined') and not(@USE = 'legend')]">
												<xsl:call-template name="image">
												<xsl:with-param name="side" select="@USE"/>
												</xsl:call-template>
												</xsl:for-each>
												</xsl:if>

												<xsl:call-template name="legend_image"/>
												</div>
												</xsl:when>
											</xsl:choose>
										</div>
									</xsl:when>
									<xsl:when test="$orientation = 'horizontal'">
										<xsl:choose>
											<xsl:when test="$image_location = 'top'">
												<xsl:choose>
												<!-- standard output of photographs -->
												<xsl:when test="$sideImages = true()">
												<div class="row">
												<div class="col-md-6">
												<xsl:call-template name="image">
												<xsl:with-param name="side"
												>obverse</xsl:with-param>
												</xsl:call-template>

												</div>
												<div class="col-md-6">
												<xsl:call-template name="image">
												<xsl:with-param name="side"
												>reverse</xsl:with-param>
												</xsl:call-template>
												</div>

												<!-- show additional images -->
												<xsl:if
												test="descendant::mets:fileGrp[not(@USE = 'obverse') and not(@USE = 'reverse') and not(@USE = 'combined') and not(@USE = 'legend')]">
												<div class="col-md-12">
												<h3>Additional Images</h3>
												<xsl:for-each
												select="descendant::mets:fileGrp[not(@USE = 'obverse') and not(@USE = 'reverse') and not(@USE = 'combined') and not(@USE = 'legend')]">
												<xsl:call-template name="image">
												<xsl:with-param name="side" select="@USE"/>
												</xsl:call-template>
												</xsl:for-each>
												</div>
												</xsl:if>
												</div>

												<div class="row">
												<div class="col-md-12">
												<xsl:call-template name="nuds_content"/>
												</div>
												</div>
												</xsl:when>
												<xsl:otherwise>
												<!-- display mirador for cards, if applicable -->
												<xsl:if
												test="descendant::mets:fileGrp[@USE = 'card']/descendant::mets:file[@USE = 'iiif']">
												<xsl:call-template name="mirador"/>
												</xsl:if>

												<div class="row">
												<div class="col-md-12">
												<xsl:call-template name="nuds_content"/>
												</div>
												</div>
												</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:when test="$image_location = 'bottom'">


												<xsl:choose>
												<!-- standard output of photographs -->
												<xsl:when test="$sideImages = true()">
												<div class="row">
												<div class="col-md-12">
												<xsl:call-template name="nuds_content"/>
												</div>
												</div>
												<div class="row">
												<div class="col-md-6">
												<xsl:call-template name="image">
												<xsl:with-param name="side"
												>obverse</xsl:with-param>
												</xsl:call-template>
												</div>
												<div class="col-md-6">
												<xsl:call-template name="image">
												<xsl:with-param name="side"
												>reverse</xsl:with-param>
												</xsl:call-template>
												</div>

												<!-- show additional images -->
												<xsl:if
												test="descendant::mets:fileGrp[not(@USE = 'obverse') and not(@USE = 'reverse') and not(@USE = 'combined') and not(@USE = 'legend')]">
												<div class="col-md-12">
												<h3>Additional Images</h3>
												<xsl:for-each
												select="descendant::mets:fileGrp[not(@USE = 'obverse') and not(@USE = 'reverse') and not(@USE = 'combined') and not(@USE = 'legend')]">
												<xsl:call-template name="image">
												<xsl:with-param name="side" select="@USE"/>
												</xsl:call-template>
												</xsl:for-each>
												</div>
												</xsl:if>
												</div>
												</xsl:when>

												<xsl:otherwise>
												<div class="row">
												<div class="col-md-12">
												<xsl:call-template name="nuds_content"/>
												</div>
												</div>

												<!-- display mirador for cards, if applicable -->
												</xsl:otherwise>
												</xsl:choose>

											</xsl:when>
										</xsl:choose>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<!-- otherwise, simply display NUDS content -->
								<div class="row">
									<div class="col-md-12">
										<xsl:call-template name="nuds_content"/>
									</div>
								</div>
							</xsl:otherwise>
						</xsl:choose>

						<!-- if there are annotations, then render -->
						<xsl:if test="$hasAnnotations = true()">
							<div class="row">
								<div class="col-md-12">
									<xsl:apply-templates
										select="doc('input:annotations')/res:sparql"
										mode="annotations">
										<xsl:with-param name="rtl"
											select="boolean(//config/languages/language[@code = $lang]/@rtl)"
										/>
									</xsl:apply-templates>
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
								<xsl:variable name="typeDesc_resource"
									select="ancestor::object/@xlink:href"/>
								<xsl:apply-templates select=".">
									<xsl:with-param name="typeDesc_resource"
										select="$typeDesc_resource"/>
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
										<xsl:when
											test="$hasFindspots = false() and $hasMints = false()">
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
				<div
					class="col-md-6 {if(//config/languages/language[@code = $lang]/@rtl = true()) then 'pull-right' else ''}">
					<xsl:apply-templates select="nuds:descMeta/nuds:physDesc[child::*]"/>

					<!-- apply-template only to NUDS-explicit typeDesc when there is one or more type references -->
					<xsl:choose>
						<xsl:when test="nuds:descMeta/nuds:typeDesc[not(@xlink:href)]">
							<xsl:apply-templates select="nuds:descMeta/nuds:typeDesc"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="$nudsGroup//nuds:typeDesc">
								<xsl:variable name="typeDesc_resource"
									select="ancestor::object/@xlink:href"/>
								<xsl:apply-templates select=".">
									<xsl:with-param name="typeDesc_resource"
										select="$typeDesc_resource"/>
								</xsl:apply-templates>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:apply-templates select="nuds:descMeta/nuds:undertypeDesc"/>
					<xsl:apply-templates select="nuds:descMeta/nuds:findspotDesc"/>
				</div>
				<div
					class="col-md-6 {if(//config/languages/language[@code = $lang]/@rtl = true()) then 'pull-right' else ''}">
					<xsl:apply-templates select="nuds:descMeta/nuds:refDesc[child::*]"/>
					<xsl:apply-templates select="nuds:descMeta/nuds:adminDesc[child::*]"/>
					<xsl:apply-templates select="nuds:descMeta/nuds:descriptionSet[child::*]"/>
					<xsl:apply-templates select="nuds:descMeta/nuds:subjectSet[child::*]"/>
					<xsl:apply-templates select="nuds:descMeta/nuds:noteSet[child::*]"/>
					<xsl:apply-templates
						select="nuds:control/nuds:rightsStmt[nuds:rights or nuds:license[@for = 'images'] or nuds:copyrightHolder]"
					/>
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
						<div id="mapcontainer"/>
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
							<xsl:value-of select="numishare:regularize_node('hoard', $lang)"/>
						</td>
						<td style="background-color:#f98f0c;border:2px solid black;width:50px;"/>
						<td style="width:100px;padding-left:6px;">
							<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
						</td>
						<xsl:if
							test="descendant::nuds:subject[contains(@xlink:href, 'geonames.org')]">
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
		<div class="metadata_section" id="findspot">
			<h3>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</h3>
			<xsl:choose>
				<xsl:when test="string(@xlink:href)">
					<xsl:choose>
						<xsl:when
							test="contains(@xlink:href, 'nomisma.org') or contains(@xlink:href, 'coinhoards.org')">
							<xsl:variable name="uri" select="@xlink:href"/>
							<xsl:variable name="label"
								select="$rdf//*[@rdf:about = $uri]/skos:prefLabel[@xml:lang = 'en']"/>

							<ul>
								<li>
									<b><xsl:value-of
											select="numishare:regularize_node('hoard', $lang)"/>: </b>
									<a
										href="{$display_path}results?q=hoard_uri:&#x022;{@xlink:href}&#x022;{if (string($langParam)) then concat('&amp;lang=', $langParam) else
										''}">
										<xsl:value-of select="$label"/>
									</a>
									<a rel="nmo:hasFindspot" href="{@xlink:href}" target="_blank"
										class="external_link">
										<span class="glyphicon glyphicon-new-window"/>
									</a>
								</li>
							</ul>
						</xsl:when>
						<xsl:otherwise>
							<ul>
								<li>
									<b><xsl:value-of
											select="numishare:regularize_node('hoard', $lang)"/>: </b>
									<a
										href="{$display_path}results?q=hoard_uri:&#x022;{@xlink:href}&#x022;{if (string($langParam)) then concat('&amp;lang=', $langParam) else
										''}">
										<xsl:value-of select="@xlink:href"/>
									</a>
									<a rel="nmo:hasFindspot" href="{@xlink:href}" target="_blank"
										class="external_link">
										<span class="glyphicon glyphicon-new-window"/>
									</a>
								</li>
							</ul>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="nuds:findspot"/>
					<xsl:apply-templates select="nuds:deposit"/>
					<xsl:apply-templates select="nuds:discovery"/>
					<xsl:apply-templates select="nuds:disposition"/>
					
					<xsl:if test="nuds:hoard">
						<ul>
							<xsl:apply-templates select="nuds:hoard" mode="descMeta"/>
						</ul>
					</xsl:if>					
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template match="nuds:findspot">

		<h4>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h4>

		<!-- when the label of the findspot is the same as the gazetteer label, then only apply template to geogname -->
		<ul>
			<xsl:choose>
				<xsl:when test="nuds:description = nuds:fallsWithin/nuds:geogname">
					<xsl:apply-templates select="nuds:fallsWithin/nuds:geogname" mode="descMeta"/>
				</xsl:when>
				<xsl:otherwise>
					
					<xsl:apply-templates select="nuds:description | nuds:fallsWithin/nuds:geogname"
						mode="descMeta"/>
					<xsl:apply-templates select="nuds:geogname[not(@xlink:href)]" mode="descMeta"/>
					<xsl:apply-templates select="nuds:spatialContext" mode="descMeta"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:apply-templates select="gml:location"/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:deposit | nuds:discovery | nuds:disposition">
		<h4>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h4>

		<ul>
			<xsl:apply-templates select="*" mode="descMeta"/>
		</ul>
	</xsl:template>

	<xsl:template match="gml:location">
		<li>
			<h4>Coordinates</h4>
			<xsl:apply-templates select="gml:Point/gml:pos"/>
		</li>
	</xsl:template>

	<xsl:template match="gml:pos">
		<xsl:variable name="coords" select="tokenize(., ' ')"/>

		<ul>
			<li>
				<b><xsl:value-of select="numishare:regularize_node('latitude', $lang)"/>: </b>
				<xsl:value-of select="normalize-space($coords[1])"/>
			</li>
			<li>
				<b><xsl:value-of select="numishare:regularize_node('longitude', $lang)"/>: </b>
				<xsl:value-of select="normalize-space($coords[2])"/>
			</li>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:descripton | nuds:legend" mode="physical">
		<span property="{numishare:normalizeProperty($recordType, local-name())}">
			<xsl:if test="@xml:lang">
				<xsl:attribute name="lang" select="@xml:lang"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="child::tei:div">
					<xsl:apply-templates select="tei:div[@type = 'edition']" mode="legend"/>
					<xsl:apply-templates select="tei:div[@type = 'transliteration']" mode="legend"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</span>
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
				<xsl:apply-templates
					select="nuds:license[@for = 'images'] | nuds:rights | nuds:copyrightHolder"
					mode="descMeta"/>
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
				<xsl:when test="nuds:description[@xml:lang = $lang]">
					<xsl:apply-templates select="nuds:description[@xml:lang = $lang]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="nuds:description[@xml:lang = 'en']">
							<xsl:apply-templates select="nuds:description[@xml:lang = 'en']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="nuds:description"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>

		</div>
	</xsl:template>

	<xsl:template match="nuds:note" mode="descMeta">
		<li>
			<xsl:if test="@localType">
				<xsl:variable name="langParam" select="
						if (string($lang)) then
							$lang
						else
							'en'"/>
				<xsl:variable name="localType" select="@localType"/>

				<b>
					<xsl:choose>
						<xsl:when
							test="$localTypes//localType[@value = $localType]/label[@lang = $langParam]">
							<xsl:value-of
								select="$localTypes//localType[@value = $localType]/label[@lang = $langParam]"
							/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="concat(upper-case(substring(@localType, 1, 1)), substring(@localType, 2))"
							/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>: </xsl:text>
				</b>
			</xsl:if>

			<xsl:apply-templates/>
		</li>
	</xsl:template>

	<!-- ***** provenance styling ***** -->
	<xsl:template match="nuds:provenance" mode="descMeta">
		<li>
			<h4>
				<xsl:choose>
					<xsl:when test="//config/facets/facet[. = 'source_facet']">Source</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
					</xsl:otherwise>
				</xsl:choose>
			</h4>
			<ul>
				<xsl:apply-templates select="descendant::nuds:chronItem">
					<!-- sort by latest date -->
					<xsl:sort select="
							if (nuds:date) then
								nuds:date/@standardDate
							else
								nuds:dateRange/nuds:toDate/@standardDate" data-type="text"
						order="descending"/>
				</xsl:apply-templates>
			</ul>
		</li>
	</xsl:template>

	<xsl:template match="nuds:chronItem">
		<li>
			<xsl:apply-templates select="nuds:date | nuds:dateRange" mode="provenance"/>
			<xsl:apply-templates select="nuds:acquiredFrom | nuds:previousColl"/>
		</li>
	</xsl:template>

	<xsl:template match="nuds:acquiredFrom | nuds:previousColl">

		<xsl:call-template name="display-label">
			<xsl:with-param name="field">
				<xsl:choose>
					<xsl:when test="//config/facets/facet[. = 'provenance_facet']"
						>provenance</xsl:when>
					<xsl:when test="//config/facets/facet[. = 'source_facet']">source</xsl:when>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="value" select="
					if (nuds:saleCatalog) then
						normalize-space(nuds:saleCatalog)
					else
						normalize-space(.)"/>
			<xsl:with-param name="href" select="nuds:saleCatalog/@xlink:href"/>
			<xsl:with-param name="side"/>
			<xsl:with-param name="position"/>
		</xsl:call-template>

		<!-- create links to resources -->
		<xsl:if test="string(nuds:saleCatalog/@xlink:href)">
			<a href="{nuds:saleCatalog/@xlink:href}" target="_blank" class="external_link">
				<span class="glyphicon glyphicon-new-window"/>
			</a>
		</xsl:if>

		<xsl:if test="nuds:identifier">
			<xsl:text>no. </xsl:text>
			<xsl:value-of select="nuds:identifier"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:date" mode="provenance">
		<strong>
			<xsl:value-of select="."/>
		</strong>
		<xsl:text>: </xsl:text>
	</xsl:template>

	<xsl:template match="nuds:dateRange" mode="provenance">
		<strong>
			<xsl:value-of select="concat(nuds:fromDate, ' - ', nuds:toDate)"/>
		</strong>
		<xsl:text>: </xsl:text>
	</xsl:template>

	<!-- *********** IMAGE TEMPLATES FOR PHYSICAL OBJECTS ********** -->
	<xsl:template name="image">
		<xsl:param name="side"/>
		<xsl:variable name="reference-image"
			select="//mets:fileGrp[@USE = $side]/mets:file[@USE = 'reference']/mets:FLocat/@xlink:href"/>
		<xsl:variable name="iiif-service"
			select="//mets:fileGrp[@USE = $side]/mets:file[@USE = 'iiif']/mets:FLocat/@xlink:href"/>

		<!-- use the 'archive' direct URL for full-size download if available, otherwise like to IIIF service -->
		<xsl:variable name="full-url">
			<xsl:choose>
				<xsl:when
					test="//mets:fileGrp[@USE = $side]/mets:file[@USE = 'archive']/mets:FLocat/@xlink:href">
					<xsl:value-of
						select="//mets:fileGrp[@USE = $side]/mets:file[@USE = 'archive']/mets:FLocat/@xlink:href"
					/>
				</xsl:when>
				<xsl:when test="string($iiif-service)">
					<xsl:value-of select="concat($iiif-service, '/full/full/0/default.jpg')"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<div class="image-container">
			<xsl:choose>
				<xsl:when test="string($iiif-service)">
					<div id="{$side}-iiif-container" class="iiif-container"
						service="{$iiif-service}"/>
					<noscript>
						<img src="{concat($iiif-service, '/full/400,/0/default.jpg')}"
							property="foaf:depiction" alt="{$side}"/>
					</noscript>
					<div>
						<a href="{$full-url}" title="Full resolution image" rel="nofollow"><span
								class="glyphicon glyphicon-download-alt"/> Download full resolution
							image</a>
					</div>
				</xsl:when>
				<xsl:when test="string($reference-image)">
					<xsl:variable name="image_url" select="
							if (matches($reference-image, 'https?://')) then
								$reference-image
							else
								concat($display_path, $reference-image)"/>

					<img src="{$image_url}" property="foaf:depiction" alt="{$side}"/>

					<xsl:if test="string($full-url)">
						<div>
							<a href="{$full-url}" title="Full resolution image" rel="nofollow"><span
									class="glyphicon glyphicon-download-alt"/> Download full
								resolution image</a>
						</div>
					</xsl:if>

					<xsl:if
						test="//mets:fileGrp[@USE = $side]/mets:file[@USE = 'context']/mets:FLocat/@xlink:href">
						<div>
							<a
								href="{//mets:fileGrp[@USE = $side]/mets:file[@USE = 'context']/mets:FLocat/@xlink:href}"
								title="View in context" rel="nofollow"><span
									class="glyphicon glyphicon-picture"/>View in context</a>
						</div>
					</xsl:if>
				</xsl:when>
			</xsl:choose>

			<!-- only display legend/type for obverse/reverse/edge images -->
			<xsl:if test="$side = 'obverse' or $side = 'reverse' or $side = 'edge'">
				<xsl:apply-templates
					select="$nudsGroup/object[1]/descendant::nuds:typeDesc/*[local-name() = $side]"
					mode="physical"/>
			</xsl:if>
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
				<xsl:choose>
					<xsl:when test="$lang = 'de'">; </xsl:when>
					<xsl:otherwise>
						<xsl:text> - </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<!-- apply language-specific type description templates -->
			<xsl:choose>
				<xsl:when test="nuds:type/nuds:description[@xml:lang = $lang]">
					<xsl:apply-templates select="nuds:type/nuds:description[@xml:lang = $lang]"
						mode="physical"/>
				</xsl:when>
				<xsl:when test="nuds:type/nuds:description[@xml:lang = 'en']">
					<xsl:apply-templates select="nuds:type/nuds:description[@xml:lang = 'en']"
						mode="physical"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="nuds:type/nuds:description[1]" mode="physical"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template name="legend_image">
		<xsl:if
			test="string(//mets:fileGrp[@USE = 'legend']/mets:file[@USE = 'reference']/mets:FLocat/@xlink:href)">
			<xsl:variable name="src"
				select="//mets:fileGrp[@USE = 'legend']/mets:file[@USE = 'reference']/mets:FLocat/@xlink:href"/>

			<div class="reference_image">
				<img
					src="{if (matches($src, 'https?://')) then $src else concat($display_path, $src)}"
					alt="legend"/>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- template for using Mirador IIIF viewer to display archival card images -->
	<xsl:template name="mirador">
		<div class="row">
			<div class="col-md-12">
				<div style="width:100%;height:800px" id="mirador-div"/>
			</div>
		</div>

	</xsl:template>

	<!-- ***** CHARTS TEMPLATES ***** -->
	<xsl:template name="charts">

		<!-- if the SPARQL endpoint is Nomisma.org, use the Nomisma measurement APIs, otherwise query the locally-defined SPARQL endpoint -->
		<xsl:variable name="measurements" as="element()*">
			<measurements>
				<xsl:choose>
					<xsl:when test="//config/sparql_endpoint = 'http://nomisma.org/query'">
						<axis>
							<xsl:value-of
								select="document(concat('http://nomisma.org/apis/avgAxis?type=', encode-for-uri($objectUri)))"
							/>
						</axis>
						<diameter>
							<xsl:value-of
								select="document(concat('http://nomisma.org/apis/avgDiameter?type=', encode-for-uri($objectUri)))"
							/>
						</diameter>
						<weight>
							<xsl:value-of
								select="document(concat('http://nomisma.org/apis/avgWeight?type=', encode-for-uri($objectUri)))"
							/>
						</weight>
					</xsl:when>
					<xsl:otherwise>
						<axis>
							<xsl:value-of
								select="document(concat($url, 'apis/getMetrical?format=xml&amp;measurement=nmo:hasAxis&amp;compare=', encode-for-uri(concat('nmo:hasTypeSeriesItem &lt;', $objectUri, '&gt;'))))//res:binding[@name='average']/res:literal"
							/>
						</axis>
						<diameter>
							<xsl:value-of
								select="document(concat($url, 'apis/getMetrical?format=xml&amp;measurement=nmo:hasDiameter&amp;compare=', encode-for-uri(concat('nmo:hasTypeSeriesItem &lt;', $objectUri, '&gt;'))))//res:binding[@name='average']/res:literal"
							/>
						</diameter>
						<weight>
							<xsl:value-of
								select="document(concat($url, 'apis/getMetrical?format=xml&amp;measurement=nmo:hasWeight&amp;compare=', encode-for-uri(concat('nmo:hasTypeSeriesItem &lt;', $objectUri, '&gt;'))))//res:binding[@name='average']/res:literal"
							/>
						</weight>
					</xsl:otherwise>
				</xsl:choose>
			</measurements>
		</xsl:variable>

		<h3>
			<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
		</h3>

		<xsl:if
			test="number($measurements//axis) &gt; 0 or number($measurements//diameter) &gt; 0 or number($measurements//weight) &gt; 0">
			<p>Average measurements for this coin type:</p>
			<dl
				class=" {if(//config/languages/language[@code = $lang]/@rtl = true()) then 'dl-horizontal dl-rtl' else 'dl-horizontal'}">
				<xsl:if test="number($measurements//axis) &gt; 0">
					<dt>
						<xsl:value-of select="numishare:regularize_node('axis', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="format-number($measurements//axis, '##.##')"/>
					</dd>
				</xsl:if>
				<xsl:if test="number($measurements//diameter) &gt; 0">
					<dt>
						<xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="format-number($measurements//diameter, '##.##')"/>
					</dd>
				</xsl:if>
				<xsl:if test="number($measurements//weight) &gt; 0">
					<dt>
						<xsl:value-of select="numishare:regularize_node('weight', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="format-number($measurements//weight, '##.##')"/>
					</dd>
				</xsl:if>
			</dl>
		</xsl:if>

		<xsl:call-template name="metrical-form">
			<xsl:with-param name="mode">record</xsl:with-param>
		</xsl:call-template>
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

	<!-- ************** TEMPLATES FOR RENDERING SPARQL RESULTS INTO A TABLE OF DIE LINKS ************** -->
	<xsl:template match="res:sparql" mode="die-links">
		<xsl:param name="reverse" as="xs:boolean"/>

		<table class="table table-striped">
			<thead>
				<th>
					<xsl:value-of select="numishare:regularize_node('obverse', $lang)"/>
				</th>
				<th>
					<xsl:value-of select="numishare:regularize_node('reverse', $lang)"/>
				</th>
				<th>
					<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
				</th>
			</thead>
			<tbody>
				<xsl:apply-templates select="descendant::res:result" mode="die-links">
					<xsl:with-param name="reverse" select="$reverse" as="xs:boolean"/>
				</xsl:apply-templates>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="res:result" mode="die-links">
		<xsl:param name="reverse" as="xs:boolean"/>

		<tr>
			<xsl:choose>
				<!-- switch die/altDie when the query is looking for the die URI in the reverse property -->
				<xsl:when test="$reverse = true()">
					<td>
						<a href="{res:binding[@name = 'altDie']/res:uri}">
							<xsl:value-of select="res:binding[@name = 'altDieLabel']/res:literal"/>
						</a>
					</td>
					<td>
						<a href="{res:binding[@name = 'die']/res:uri}">
							<xsl:value-of select="res:binding[@name = 'dieLabel']/res:literal"/>
						</a>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td>
						<a href="{res:binding[@name = 'die']/res:uri}">
							<xsl:value-of select="res:binding[@name = 'dieLabel']/res:literal"/>
						</a>
					</td>
					<td>
						<a href="{res:binding[@name = 'altDie']/res:uri}">
							<xsl:value-of select="res:binding[@name = 'altDieLabel']/res:literal"/>
						</a>
					</td>
				</xsl:otherwise>
			</xsl:choose>
			<td>
				<xsl:value-of select="res:binding[@name = 'count']/res:literal"/>
			</td>
		</tr>
	</xsl:template>

	<!-- ************** TEMPLATES FOR RENDERING SPARQL A LIST OF TYPES RELATED TO DIES ************** -->
	<xsl:template match="res:sparql" mode="die-types">
		<div class="row">
			<div class="col-md-12">
				<h3>Associated Types</h3>
				<ul>
					<xsl:apply-templates select="descendant::res:result" mode="die-types"/>
				</ul>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="res:result" mode="die-types">
		<li>
			<a href="{res:binding[@name = 'type']/res:uri}">
				<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
			</a>
		</li>
	</xsl:template>

</xsl:stylesheet>
