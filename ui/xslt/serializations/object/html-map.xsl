<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:res="http://www.w3.org/2005/sparql-results#"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>
	<!-- URL params -->
	<xsl:param name="pipeline">display_map</xsl:param>
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
	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="collection_type" select="/content/config/collection_type"/>
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="include_path"
		select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>
	
	<xsl:variable name="recordType">
		<xsl:choose>
			<xsl:when test="descendant::nuds:nuds">
				<xsl:value-of select="//nuds:nuds/@recordType"/>
			</xsl:when>
			<xsl:when test="descendant::nh:nudsHoard">hoard</xsl:when>
			<xsl:when test="descendant::tei:TEI">physical</xsl:when>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="id">
		<xsl:choose>
			<xsl:when test="//*[local-name() = 'recordId']">
				<xsl:value-of select="//*[local-name() = 'recordId']"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="descendant::tei:idno[@type='filename']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="hasFindspots"
		select="
			if (doc('input:hasFindspots')//res:sparql/res:boolean) then
				doc('input:hasFindspots')//res:sparql/res:boolean
			else
				false()"
		as="xs:boolean"/>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:choose>
				<xsl:when test="descendant::nuds:typeDesc[string(@xlink:href)]">
					<xsl:variable name="uri" select="descendant::nuds:typeDesc/@xlink:href"/>

					<xsl:call-template name="numishare:getNudsDocument">
						<xsl:with-param name="uri" select="$uri"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<object>
						<xsl:copy-of select="descendant::nuds:typeDesc"/>
					</object>
				</xsl:otherwise>
			</xsl:choose>
		</nudsGroup>
	</xsl:variable>
	
	<xsl:template match="/">
		<html>
			<head>
				<xsl:call-template name="generic_head"/>
				<xsl:choose>
					<xsl:when test="$recordType = 'physical'">
						<script type="text/javascript" src="{$include_path}/javascript/display_map_functions.js"/>
					</xsl:when>
					<!-- coin-type CSS and JS dependencies -->
					<xsl:when test="$recordType = 'conceptual'">
						<xsl:if test="$hasFindspots = true()">
							<script type="text/javascript" src="http://openlayers.org/api/2.12/OpenLayers.js"/>
							<script type="text/javascript" src="{$include_path}/javascript/mxn.js"/>
							<script type="text/javascript" src="{$include_path}/javascript/timeline-2.3.0.js"/>
							<link type="text/css" href="{$include_path}/css/timeline-2.3.0.css" rel="stylesheet"/>
							<script type="text/javascript" src="{$include_path}/javascript/timemap_full.pack.js"/>
							<script type="text/javascript" src="{$include_path}/javascript/param.js"/>
						</xsl:if>
						
						<script type="text/javascript" src="{$include_path}/javascript/display_map_functions.js"/>
					</xsl:when>
					<!-- hoard CSS and JS dependencies -->
					<xsl:when test="$recordType = 'hoard'">
						<script type="text/javascript" src="{$include_path}/javascript/display_hoard_functions.js"/>
					</xsl:when>
				</xsl:choose>
			</head>
			<body>
				<div class="container-fluid" style="height:100%">
					<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
						<xsl:attribute name="style">direction: rtl;</xsl:attribute>
					</xsl:if>
					<div class="row" style="height:100%">
						<div class="col-md-12" style="height:100%">
							<div id="timemap-legend">
								<h2>
									<xsl:value-of select="numishare:normalizeLabel('maps_legend', $lang)"/>
								</h2>
								<div class="legend">
									<table>
										<tbody>
											<tr>
												<td style="background-color:#6992fd;border:2px solid black;width:50px;"/>
												<td style="width:100px;padding-left:6px;">
													<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
												</td>
											</tr>
											<tr>
												<td style="background-color:#666666;border:2px solid black;width:50px;"/>							
												<td style="width:150px;padding-left:6px;">
													<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
													<xsl:text> (uncertain)</xsl:text>
												</td>
											</tr>											
											<tr>
												<td style="background-color:#d86458;border:2px solid black;width:50px;"/>
												<td style="width:100px;padding-left:6px;">
													<xsl:value-of select="numishare:regularize_node('hoard', $lang)"/>
												</td>
											</tr>
											<tr>
												<td style="background-color:#f98f0c;border:2px solid black;width:50px;"/>
												<td style="width:100px;padding-left:6px;">
													<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
												</td>
											</tr>
											<xsl:if test="descendant::nuds:subject[contains(@xlink:href, 'geonames.org')]">
												<tr>
													<td style="background-color:#00e64d;border:2px solid black;width:50px;"/>
													<td style="width:100px;padding-left:6px;">
														<xsl:value-of select="numishare:regularize_node('subject', $lang)"/>
													</td>
												</tr>
											</xsl:if>
										</tbody>
									</table>
								</div>
								<small>
									<a href="{$url}id/{$id}"><span class="glyphicon glyphicon-arrow-left"/>Return</a>
								</small>
							</div>
							<div id="mapcontainer" style="height:100%"/>
						</div>
					</div>
				</div>
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
								<xsl:value-of select="concat($display_path, 'id/')"/>
							</xsl:otherwise>
						</xsl:choose>
					</span>
					<span id="pipeline">
						<xsl:value-of select="$pipeline"/>
					</span>
					<span id="object_title">
						<xsl:value-of select="descendant::*:descMeta/*:title"/>
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
					</xsl:if>
				</div>
			</body>
		</html>
	</xsl:template>
	
	
	<xsl:template name="generic_head">
		<title id="{$id}">
			<xsl:value-of select="//config/title"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="descendant::*:descMeta/*:title"/>
		</title>
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
		<link type="text/css" href="{$include_path}/css/fullscreen.css" rel="stylesheet"/>
		<xsl:if test="string(//config/google_analytics)">
			<script type="text/javascript">
				<xsl:value-of select="//config/google_analytics"/>
			</script>
		</xsl:if>

		<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.0/dist/leaflet.css"/>
		<script src="https://unpkg.com/leaflet@1.0.0/dist/leaflet.js"/>
		<script type="text/javascript" src="{$include_path}/javascript/leaflet.ajax.min.js"/>
	</xsl:template>
</xsl:stylesheet>
