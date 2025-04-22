<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../templates-search.xsl"/>
	<xsl:include href="../functions.xsl"/>
	<xsl:include href="../serializations/solr/html-templates.xsl"/>

	<xsl:param name="pipeline">search</xsl:param>
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

	<xsl:variable name="request-uri" select="
			concat('http://localhost:', if (//config/server-port castable as xs:integer) then
				//config/server-port
			else
				'8080', substring-before(doc('input:request')/request/request-uri, 'results'))"/>
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>

	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path" select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<!-- load facets into variable -->
	<xsl:variable name="facets" select="//lst[@name = 'facet_fields']" as="node()*"/>

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

					<xsl:call-template name="text-search-templates"/>
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

					<p>The advanced search interface enables a combination of faceted list terms and text field searches. The text field searches include alternate labels for
						people and places and may cast a wider net from the preferred label derived from Nomisma.org or the collection database. Note that the entry of keywords in
						text fields or the selection of terms from the facet lists will restrict other term lists according to the query currently being formed by the user.</p>

					<form action="{$display_path}results" method="GET" role="form" id="facet_form">

						<div class="form-group">
							<label>Keyword</label>
							<input type="text" class="form-control text-search" id="fulltext" placeholder="Search"/>
							<span class="text-info">These terms will search all fields in the database.</span>
						</div>
						
						<xsl:if test="$collection_type = 'object'">
							<div class="form-group">
								<label for="imagesavailable">
									<xsl:value-of select="numishare:normalizeLabel('results_has-images', $lang)"/>
								</label>
								<input type="checkbox" id="imagesavailable"/>
							</div>
						</xsl:if>

						<xsl:choose>
							<xsl:when test="not(//config/facets/facet/@type)">
								<!-- display alert error if the Numishare config is out of down and does not include facet classifications for the search form -->
								<div class="alert alert-danger alert-box" role="alert">
									<span class="glyphicon glyphicon-exclamation-sign"/>
									<strong>Alert:</strong> The Numishare config is out of date with respect to facet classifications. Please enter the administrative panel for
									this collection to update the config. </div>
							</xsl:when>

							<xsl:otherwise>

								<xsl:if test="$collection_type = 'hoard'">
									<xsl:if test="//config/facets/facet[@role = 'context']">
										<h2>
											<xsl:value-of select="numishare:normalize_fields('context', $lang)"/>
										</h2>

										<xsl:for-each select="//config/facets/facet[@role = 'context' and @type = 'list']">
											<xsl:variable name="field" select="."/>

											<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
										</xsl:for-each>
									</xsl:if>
								</xsl:if>
								
								<xsl:if test="$collection_type = 'hoard'">
									<h2>Contents</h2>
								</xsl:if>

								<xsl:if test="//config/facets/facet[@role = 'entity']">
									<h3>
										<xsl:text>People and Organizations</xsl:text>
										<xsl:if test="//config/facets/facet[@role = 'entity' and @type = 'text']">
											<small>
												<a class="addBtn" id="add-entity" href="#">
													<span class="glyphicon glyphicon-plus"/> add search field </a>
											</small>
										</xsl:if>
									</h3>

									<!-- only include text searchable fields if applicable -->
									<xsl:if test="//config/facets/facet[@role = 'entity' and @type = 'text']">
										<div class="section-container" id="entity-container">
											<div class="form-group">
												<input type="text" class="form-control text-search"/>
												<select class="category_list form-control">
													<xsl:for-each select="//config/facets/facet[@role = 'entity' and @type = 'text']">
														<option value="{.}">
															<xsl:value-of select="numishare:normalize_fields(., $lang)"/>
														</option>
													</xsl:for-each>
												</select>
												<a class="removeBtn hidden" href="#" title="Remove field from query">
													<span class="glyphicon glyphicon-remove"/>
												</a>
											</div>
										</div>
									</xsl:if>

									<!-- list fields -->
									<xsl:for-each select="//config/facets/facet[@role = 'entity' and @type = 'list']">
										<xsl:variable name="field" select="."/>

										<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
									</xsl:for-each>

								</xsl:if>


								<xsl:if test="//config/facets/facet[@role = 'place']">
									<h3>
										<xsl:text>Places</xsl:text>
										<xsl:if test="//config/facets/facet[@role = 'place' and @type = 'text']">
											<small>
												<a class="addBtn" id="add-place" href="#">
													<span class="glyphicon glyphicon-plus"/> add search field </a>
											</small>
										</xsl:if>
									</h3>

									<!-- general text fields -->
									<div class="form-group">
										<label for="place_text">Place Search</label>
										<input type="text" class="form-control text-search" id="place_text"
											fields="{string-join(//config/facets/facet[@role = 'place' and @type = 'list'], ';')}"/>
									</div>

									<!-- list fields -->
									<xsl:for-each select="//config/facets/facet[@role = 'place' and @type = 'list']">
										<xsl:variable name="field" select="."/>

										<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
									</xsl:for-each>
								</xsl:if>

								<h3>Typology</h3>

								<xsl:for-each select="//config/facets/facet[@role = 'typology' and @type = 'list']">
									<xsl:variable name="field" select="."/>

									<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
								</xsl:for-each>

								<div class="form-group">
									<label>
										<xsl:value-of select="numishare:normalize_fields('dateRange', $lang)"/>
									</label>
									<input type="number" id="from_date" class="form-control" placeholder="{numishare:normalize_fields('fromDate', $lang)}"/>
									<select id="from_era" class="form-control">
										<option value="minus">BCE</option>
										<option value="" selected="selected">CE</option>
									</select>
									<span> - </span>
									<input type="number" id="to_date" class="form-control" placeholder="{numishare:normalize_fields('toDate', $lang)}"/>
									<select id="to_era" class="form-control">
										<option value="minus">BCE</option>
										<option value="" selected="selected">CE</option>
									</select>
								</div>

								<xsl:if test="//config/ah_enabled = true()">
									<div class="form-group" id="ah_dateRange">
										<label>
											<xsl:value-of select="numishare:normalize_fields('ah', $lang)"/>
										</label>
										<input type="number" id="ah_fromDate" class="form-control" placeholder="{numishare:normalize_fields('fromDate', $lang)}"/>
										<span> - </span>
										<input type="number" id="ah_toDate" class="form-control" placeholder="{numishare:normalize_fields('toDate', $lang)}"/>
									</div>
								</xsl:if>

								<div class="form-group">
									<label for="obv_leg_text">
										<xsl:value-of select="numishare:normalize_fields('obv_leg_text', $lang)"/>
									</label>
									<input type="text" class="form-control text-search" id="obv_leg_text"/>
								</div>
								<div class="form-group">
									<label for="rev_leg_text">
										<xsl:value-of select="numishare:normalize_fields('rev_leg_text', $lang)"/>
									</label>
									<input type="text" class="form-control text-search" id="rev_leg_text"/>
								</div>
								<div class="form-group">
									<label for="obv_type_text">
										<xsl:value-of select="numishare:normalize_fields('obv_type_text', $lang)"/>
									</label>
									<input type="text" class="form-control text-search" id="obv_type_text"/>
								</div>
								<div class="form-group">
									<label for="rev_type_text">
										<xsl:value-of select="numishare:normalize_fields('rev_type_text', $lang)"/>
									</label>
									<input type="text" class="form-control text-search" id="rev_type_text"/>
								</div>
								
								<xsl:if test="//config/facets/facet[@role = 'symbol']">
									<h3>
										<xsl:value-of select="numishare:normalize_fields('symbol', $lang)"/>
									</h3>
									
									<xsl:if test="//lst[contains(@name, 'symbol_obv_') and number(int) &gt; 0]">
										<h5>
											<xsl:value-of select="numishare:normalize_fields('obverse', $lang)"/>
										</h5>
										<xsl:apply-templates select="//lst[contains(@name, 'symbol_obv') and number(int) &gt; 0]" mode="facet"/>
									</xsl:if>
									<xsl:if test="//lst[contains(@name, 'symbol_rev_') and number(int) &gt; 0]">
										<h5>
											<xsl:value-of select="numishare:normalize_fields('reverse', $lang)"/>
										</h5>
										<xsl:apply-templates select="//lst[contains(@name, 'symbol_rev') and number(int) &gt; 0]" mode="facet"/>
									</xsl:if>
									
									
								</xsl:if>

								<!-- physical attributes are only visible in specimen collections -->
								<xsl:if test="$collection_type = 'object'">
									<h3>Physical Attributes</h3>

									<div class="form-group">
										<label>
											<xsl:value-of select="numishare:normalize_fields('weight', $lang)"/>
										</label>
										<span>From: </span>
										<input type="number" step="0.1" id="weight_min" class="form-control technical-input" placeholder="From"/>
										<span>To: </span>
										<input type="number" step="0.1" id="weight_max" class="form-control technical-input" placeholder="To"/>
									</div>
									<div class="form-group">
										<label>
											<xsl:value-of select="numishare:normalize_fields('diameter', $lang)"/>
										</label>
										<span>From: </span>
										<input type="number" id="diameter_min" class="form-control technical-input" placeholder="From"/>
										<span>To: </span>
										<input type="number" id="diameter_max" class="form-control technical-input" placeholder="To"/>
									</div>

									<xsl:for-each select="//config/facets/facet[@role = 'physical' and @type = 'list']">
										<xsl:variable name="field" select="."/>

										<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
									</xsl:for-each>
								</xsl:if>

								<xsl:if test="//config/facets/facet[@role = 'subject']">
									<h3>
										<xsl:value-of select="numishare:normalize_fields('subjectSet', $lang)"/>
									</h3>

									<xsl:for-each select="//config/facets/facet[@role = 'subject' and @type = 'list']">
										<xsl:variable name="field" select="."/>

										<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
									</xsl:for-each>
								</xsl:if>


								<!-- if it is an object collection, display provenance, including findspot and hoard -->
								<xsl:if test="$collection_type = 'object'">
									<xsl:if test="//config/facets/facet[@role = 'provenance']">
										<h3>
											<xsl:value-of select="numishare:normalize_fields('provenance', $lang)"/>
										</h3>

										<xsl:for-each select="//config/facets/facet[@role = 'provenance' and @type = 'list']">
											<xsl:variable name="field" select="."/>

											<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
										</xsl:for-each>
									</xsl:if>
								</xsl:if>


								<xsl:if test="//config/facets/facet[@role = 'reference']">
									<h3>
										<xsl:value-of select="numishare:normalize_fields('refDesc', $lang)"/>
									</h3>

									<div class="form-group">
										<label for="reference_text">
											<xsl:value-of select="numishare:normalize_fields('reference_text', $lang)"/>
										</label>
										<input type="text" class="form-control text-search" id="reference_text"/>
									</div>

									<xsl:for-each select="//config/facets/facet[@role = 'reference' and @type = 'list']">
										<xsl:variable name="field" select="."/>

										<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
									</xsl:for-each>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>	

						<!-- hidden params -->
						<input type="hidden" name="q" id="facet_form_query" value="*:*"/>

						<xsl:if test="string($langParam)">
							<input type="hidden" name="lang" value="{$lang}"/>
						</xsl:if>

						<br/>
						<input type="submit" value="{numishare:normalizeLabel('results_refine-search', $lang)}" id="search_button" class="btn btn-default"/>
					</form>

				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
