<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:include href="../templates.xsl"/>
	<!--<xsl:include href="../templates-search.xsl"/>-->	
	<xsl:include href="../functions.xsl"/>
	<xsl:include href="../serializations/solr/html-templates.xsl"/>

	<xsl:param name="pipeline">search</xsl:param>
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
	
	<xsl:variable name="request-uri" select="concat('http://localhost:', if (//config/server-port castable as xs:integer) then //config/server-port else '8080', substring-before(doc('input:request')/request/request-uri, 'results'))"/>
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
	
	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path" select="if (string(//config/theme/themes_url)) then concat(//config/theme/themes_url, //config/theme/orbeon_theme) else concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<!-- load facets into variable -->
	<xsl:variable name="facets" select="//lst[@name='facet_fields']" as="node()*"/>

	<!-- blank params (from html templates) -->
	<xsl:param name="q"/>
	<xsl:param name="mode"/>
	<xsl:param name="sort"/>
	<xsl:param name="start" as="xs:integer"/>
	<xsl:param name="rows" as="xs:integer"/>
	<xsl:param name="side"/>
	<xsl:param name="layout"/>
	<xsl:param name="authenticated"/>
	<xsl:variable name="tokenized_q"/>
	<xsl:variable name="numFound" select="//result[@name = 'response']/@numFound" as="xs:integer"/>
	<xsl:variable name="image"/>
	
	<!-- config variables -->
	<xsl:variable name="collection_type" select="/content//collection_type"/>
	<xsl:variable name="positions" as="node()*">
		<config>
			<xsl:copy-of select="/content/config/positions"/>
		</config>
	</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="numishare:normalizeLabel('header_search', $lang)"/>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/{if (string(//config/favicon)) then //config/favicon else 'favicon.png'}"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"/>
				
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
				
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/bootstrap-multiselect.js"/>
				<link rel="stylesheet" href="{$include_path}/css/bootstrap-multiselect.css" type="text/css"/>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>
				<script type="text/javascript" src="{$include_path}/javascript/get_facets.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/facet_functions.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/search.js"/>
				<!--<script type="text/javascript" src="{$include_path}/javascript/result_functions.js"/>-->
				<!--<script type="text/javascript" src="{$include_path}/javascript/search.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/search_functions.js"/>-->
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="search"/>
				<xsl:call-template name="footer"/>
				
				<div id="backgroundPopup"/>
				<div class="hidden">
					<input id="facet_form_query" name="q" value="*:*" type="hidden"/>
					<xsl:if test="string($lang)">
						<input type="hidden" name="lang" value="{$lang}"/>
					</xsl:if>
					<span id="collection_type">
						<xsl:value-of select="$collection_type"/>
					</span>
					<span id="path">
						<xsl:value-of select="$display_path"/>
					</span>
					<span id="pipeline">
						<xsl:value-of select="$pipeline"/>
					</span>					
					<div id="ajax-temp"/>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="search">
		<div class="container-fluid">
			<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>							
			</xsl:if>
			<div class="row">
				<div class="col-md-12">
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('header_search', $lang)"/>
					</h1>
					
					<!--<form id="advancedSearchForm" method="GET" action="results">
						
						<div class="form-group">
							<label>Keyword</label>
							<input type="text" class="form-control" id="keyword" placeholder="Search"/>
						</div>
						
						<!-\-<div class="inputContainer">
							<div class="searchItemTemplate">
								<select class="category_list form-control">
									<xsl:call-template name="search_options"/>
								</select>
								<div style="display:inline;" class="option_container">
									<input type="text" id="search_text" class="search_text form-control" style="display: inline;"/>
								</div>
								<a class="gateTypeBtn" href="#">
									<span class="glyphicon glyphicon-plus"/>
								</a>
							</div>
						</div>-\->
						
						
						
					</form>-->
					
					
					
					
					
					<form action="{$display_path}results" method="GET" role="form" id="facet_form">
						
						<div class="form-group">
							<label>Keyword</label>
							<br/>
							<span class="text-info">These terms will search all fields in the database.</span>
							<input type="text" class="form-control" id="keyword" placeholder="Search"/>
						</div>
						
						<h3>People and Organizations</h3>						
						<div class="form-group">
							<label>Authority</label>
							<input type="text" class="form-control text-search" id="authority_text_search"/>
						</div>
						<div class="form-group">
							<label>Stated Authority</label>
							<input type="text" class="form-control text-search" id="statedAuthority_text_search"/>
						</div>
						<xsl:apply-templates select="//lst[@name = 'dynasty_facet']" mode="facet"/>
						<xsl:apply-templates select="//lst[@name = 'state_facet']" mode="facet"/>
						
						<h3>Places</h3>
						<xsl:choose>
							<xsl:when test="//lst[@name = 'productionPlace_facet']">
								<xsl:apply-templates select="//lst[@name = 'productionPlace_facet']" mode="facet"/>
							</xsl:when>
							<xsl:when test="//lst[@name = 'mint_facet']">
								<xsl:apply-templates select="//lst[@name = 'mint_facet']" mode="facet"/>
							</xsl:when>
						</xsl:choose>
						<xsl:apply-templates select="//lst[@name = 'region_hier']" mode="facet"/>
						<xsl:apply-templates select="//lst[@name = 'issuePlace_facet']" mode="facet"/>
						<xsl:apply-templates select="//lst[@name = 'relatedPlace_facet']" mode="facet"/>
						
						<h3>Typology</h3>
						<xsl:apply-templates select="//lst[@name = 'manufacture_facet']" mode="facet"/>
						<xsl:apply-templates select="//lst[@name = 'material_facet']" mode="facet"/>
						<xsl:apply-templates select="//lst[@name = 'denomination_facet']" mode="facet"/>
						
						<xsl:if test="//lst[@name = 'category_hier'] or //lst[starts-with(@name, 'subject')]">
							<h3>Subjects</h3>
							<xsl:apply-templates select="//lst[@name = 'category_hier']" mode="facet"/>
							<xsl:apply-templates select="//lst[@name = 'subjectEvent_facet']" mode="facet"/>
							<xsl:apply-templates select="//lst[@name = 'subjectPerson_facet']" mode="facet"/>
							<xsl:apply-templates select="//lst[@name = 'subjectPlace_facet']" mode="facet"/>
						</xsl:if>						
						
						<h3>Provenance</h3>
						<xsl:apply-templates select="//lst[@name = 'hoard_facet']" mode="facet"/>
						<xsl:apply-templates select="//lst[@name = 'findspot_facet']" mode="facet"/>
						
						<!-- hidden params -->
						<input type="hidden" name="q" id="facet_form_query" value="*:*"/>
						<xsl:if test="string($lang)">
							<input type="hidden" name="lang" value="{$lang}"/>
						</xsl:if>
						<br/>
						<label for="imagesavailable">
							<xsl:value-of select="numishare:normalizeLabel('results_has-images', $lang)"/>
						</label>
						<input type="checkbox" id="imagesavailable"/>
						<br/>
						<input type="submit" value="{numishare:normalizeLabel('results_refine-search', $lang)}" id="search_button" class="btn btn-default"/>
					</form>
					
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
