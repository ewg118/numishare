<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
	exclude-result-prefixes="#all">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>
	<xsl:include href="../serializations/solr/html-templates.xsl"/>

	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="department" select="substring-after(doc('input:request')/request/request-url, 'department/')"/>
	<xsl:variable name="request-uri" select="concat('http://localhost:8080', substring-before(doc('input:request')/request/request-uri, 'department'))"/>
	<xsl:variable name="uri_space"/>

	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="include_path" select="concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>
	<xsl:variable name="department_facet">
		<xsl:choose>
			<xsl:when test="$department = 'UnitedStates'">
				<xsl:text>United States</xsl:text>
			</xsl:when>
			<xsl:when test="$department = 'EastAsian'">
				<xsl:text>East Asian</xsl:text>
			</xsl:when>
			<xsl:when test="$department = 'SouthAsian'">
				<xsl:text>South Asian</xsl:text>
			</xsl:when>
			<xsl:when test="$department = 'LatinAmerican'">
				<xsl:text>Latin American</xsl:text>
			</xsl:when>
			<xsl:when test="$department = 'MedalsAndDecorations'">
				<xsl:text>Medal</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$department"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="image" select="lower-case(replace($department_facet, ' ', '_'))"/>

	<!-- blank params (from html templates) -->
	<xsl:param name="q"/>
	<xsl:param name="mode"/>
	<xsl:param name="sort"/>
	<xsl:param name="start" as="xs:integer"/>
	<xsl:param name="rows" as="xs:integer"/>
	<xsl:param name="pipeline"/>
	<xsl:param name="side"/>
	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>
	<xsl:variable name="tokenized_q"/>
	<xsl:variable name="collection_type" select="/content//collection_type"/>
	<xsl:variable name="sparqlResult" as="item()*">
		<xml/>
	</xsl:variable>

	<xsl:template match="/content">
		<html lang="en">
			<head>
				<title>
					<xsl:value-of select="config/title"/>
					<xsl:text>: Collections / </xsl:text>
					<xsl:value-of select="$department"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/bootstrap-multiselect.js"/>
				<link rel="stylesheet" href="{$include_path}/css/bootstrap-multiselect.css" type="text/css"/>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>

				<!-- Add fancyBox -->
				<link rel="stylesheet" href="{$include_path}/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
				<script type="text/javascript" src="{$include_path}/javascript/get_facets.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/facet_functions.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/result_functions.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/department_functions.js"/>

				<xsl:if test="string(config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="content"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="content">
		<div id="backgroundPopup"/>
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-12">
					<h1>
						<xsl:value-of select="$department_facet"/>
						<xsl:text> Department</xsl:text>
					</h1>
				</div>
				<div class="col-md-2 text-center">
					<img alt="{$department_facet}" src="{$include_path}/images/{$image}.jpg"/>
				</div>
				<div class="col-md-10">
					<p>
						<a href="{$display_path}results?q=department_facet:&#x022;{$department_facet}&#x022;">View all coins from this department.</a> (<a
							href="{$display_path}results?q=department_facet:&#x022;{$department_facet}&#x022; AND imagesavailable:true">with images</a>) </p>
					<xsl:choose>
						<xsl:when test="$department_facet = 'Greek'">
							<p>The collection of ancient Greek coins comprises some 100,000 items, classified according to regions and mints of the ancient world, from Spain and North Africa in the
								west to Afghanistan in the east. It includes all Greek coins, struck roughly between 650 BC and the time of the Roman conquest, and also the bronze coinages of Greek
								and other cities under Roman administration down to the late 3rd century AD.</p>
							<p>To learn more about the collection please click here.</p>
						</xsl:when>
						<xsl:when test="$department_facet = 'Byzantine'">
							<p>The Byzantine collection comprises some 13,000 coins struck at Byzantium and at the regional mints of the Byzantine Empire from the reign of Anastasius I (AD
								419-518).</p>
							<p>To learn more about the collection please click here.</p>
						</xsl:when>
						<xsl:when test="$department_facet = 'East Asian'">
							<p>The Department of East Asian Coins comprises some 50,000 coins and other objects produced in the area of modern China, Korea, Japan, and Vietnam. The Department includes
								all coins struck in these regions from the beginning of coinage in the 6th century BC down to the modern day. It also includes paper money.</p>
							<p>To learn more about the collection please click here.</p>
						</xsl:when>
						<xsl:when test="$department_facet = 'Medieval'">
							<p>The Medieval Department, comprising some 50,000 objects, contains the coinage of Latin Europe from the fall of the Roman Empire down to the end of hammer-struck coinage
								during the course of the 17th century.</p>
							<p>To learn more about the collection please click here.</p>
						</xsl:when>
						<xsl:when test="$department_facet = 'Medal'">
							<p>The Medals and Decorations Department contains more than 50,000 medals from around the world of all varieties, including commemorative medals, art medals and society
								medals. It also includes decorations issued in the United States.</p>
							<p>To learn more about the collection please click here.</p>
						</xsl:when>
						<xsl:when test="$department_facet = 'Roman'">
							<p>The department includes all coins conventionally identified as Republican or imperial, as well as the silver coins of the imperial provinces and all coins of Roman
								Alexandria. There are approximately 6000 coins of the Republic, about 56000 of the mainstream imperial coinage, about 3000 provincial silver and nearly 13000 of
								Alexandria.</p>
							<p>To learn more about the collection please click here.</p>
						</xsl:when>
						<xsl:when test="$department_facet = 'Islamic'">
							<p>The Islamic Department contains over 70,000 coins and other objects. It includes all coins and paper money from North Africa and the Middle East, as far as Afghanistan
								and Central Asia, from the Islamic conquests of the seventh and eighth centuries to the present day.</p>
							<p>To learn more about the collection please click here.</p>
						</xsl:when>
						<xsl:when test="$department_facet = 'South Asian'">
							<p>The South Asian Department, consisting of some 50,000 objects, includes the coins and paper money of all periods from three principal regions: the Indian subcontinent,
								including the Islamic period; Southeast Asia, including Burma, Thailand, Laos, Cambodia, Indonesia, Malaysia, and the Philippines; and ancient Central Asia, including
								the Indo-Parthians, Sakas, Kushans, and Hephthalites.</p>
							<p>To learn more about the collection please click here.</p>
						</xsl:when>
						<xsl:when test="$department_facet = 'Modern'">
							<p>The Modern Department includes all coins minted by minting machinery and all paper money produced in Europe, Canada, Oceania and sub-Saharan Africa. The total figure for
								the modern cabinet is approximately 100,000 pieces.</p>
							<p>To learn more about the collection please click here.</p>
						</xsl:when>
						<xsl:when test="$department_facet = 'Latin American'">
							<p>The Latin American Department contains coins and paper money of Central America, South American and the Caribbean. The total figure for the Latin American cabinet is
								approximately 30,000 pieces.</p>
							<p>To learn more about the collection please click here.</p>
						</xsl:when>
						<xsl:when test="$department_facet = 'United States'">
							<p>The United States Department includes all coins issued in and for the British North American Plantations until 1783 and for the United States thereafter, including
								Alaska and Hawaii. The total figure for the United States cabinet is approximately 32,000 pieces.</p>
							<p>To learn more about the collection please click here.</p>
						</xsl:when>
					</xsl:choose>
					<p>
						<a href="#instructions" id="show_instructions">Show search instructions.</a>
					</p>
					<div style="display:none">
						<div id="instructions">
							<h1>Collection Search Instructions</h1>
							<p>How to find an object in the ANS database.</p>

							<h2>Accession Number</h2>
							<p>If you know the ANS’ unique accession number for the object click the ‘Search’ button in the toolbar above. On the new page that opens, select ‘Accession number’ on the
								drop-down menu and enter the accession in the following format: YYYY.nnn.nnn.</p>

							<h2>Free Text Searching</h2>
							<p>To conduct a free text search click the ‘Search’ button in the toolbar above. On the new page that opens, select ‘Keyword’ on the drop-down menu and enter the text for
								which you wish to search.</p>

							<h2>Faceted Searching</h2>
							<p>To the right of these instructions is a list of facets by which the collection may be searched or browsed. Click on a facet and a list of all values held in the database
								will appear as a scroll-down list. Select the term for which you wish to search and check the box next to it. You may choose multiple terms within any facet. For
								example, if you want to browse the coins of two different mints, find their names in the ‘Mint’ facet and check the boxes next to both.</p>

							<p>Then click the ‘Search the Department’ button beneath the facet list.</p>

							<h2>Building a search</h2>
							<p>You may build a complex search by choosing search terms under different facets. When you have finished selecting the terms under one facet, open the other facet(s) by
								which you want to search and select the relevant terms there too. For example if w at to find coins struck at a mint in the 17th century, open the ‘Mint’ facet and
								check the appropriate mint, then open the ‘Century’ facet and check ‘17th century’.</p>

							<p>Then click the ‘Search the Department’ button beneath the facet list.</p>

							<h2>Images</h2>
							<p>If you want to restrict your search to objects with images available in the database, check the ‘Has images’ box beneath the facets list before clicking the ‘Search’
								button.</p>
						</div>
					</div>
				</div>
			</div>
			<xsl:call-template name="form"/>
			<xsl:apply-templates select="descendant::lst[@name='facet_fields']"/>
			<div style="display:none">
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
				<span id="department">
					<xsl:value-of select="$department_facet"/>
				</span>
				<div id="ajax-temp"/>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="form">
		<div class="row">
			<div class="col-md-12">
				<h2>Search the Department</h2>
			</div>
			<div class="col-md-6">
				<h3>
					<xsl:value-of select="numishare:regularize_node('keyword', $lang)"/>
				</h3>
				<div class="input-group">
					<input type="text" class="form-control" id="keyword" placeholder="Search"/>
				</div>
			</div>
			<div class="col-md-6">
				<h3>
					<xsl:value-of select="numishare:normalize_fields('dateRange', $lang)"/>
				</h3>
				<label>
					<xsl:value-of select="numishare:normalize_fields('fromDate', $lang)"/>
				</label>
				<input type="text" id="from_date" class="form-control"/>
				<select id="from_era" class="form-control">
					<option value="minus">B.C.</option>
					<option value="" selected="selected">A.D.</option>
				</select>
				<label>
					<xsl:value-of select="numishare:normalize_fields('toDate', $lang)"/>
				</label>
				<input type="text" id="to_date" class="form-control"/>
				<select id="to_era" class="form-control">
					<option value="minus">B.C.</option>
					<option value="" selected="selected">A.D.</option>
				</select>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="lst[@name='facet_fields']">
		<div class="row">
			<div class="col-md-4">
				<h3>General Information</h3>
				<xsl:choose>
					<xsl:when test="$department_facet='Greek'">
						<xsl:apply-templates select="lst[@name='region_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='locality_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='mint_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='dynasty_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='authority_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='issuer_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='artist_facet']" mode="facet"/>
						<!--<xsl:apply-templates select="lst[@name='century_num']" mode="facet"/>-->
					</xsl:when>
					<xsl:when test="$department_facet='Roman'">
						<xsl:apply-templates select="lst[@name='category_hier']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='authority_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='issuer_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='region_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='mint_facet']" mode="facet"/>
						<!--<xsl:apply-templates select="lst[@name='century_num']" mode="facet"/>-->
					</xsl:when>
					<xsl:when test="$department_facet='Byzantine'">
						<xsl:apply-templates select="lst[@name='region_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='mint_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='dynasty_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='authority_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='issuer_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='category_hier']" mode="facet"/>
						<!--<xsl:apply-templates select="lst[@name='century_num']" mode="facet"/>-->
					</xsl:when>
					<xsl:when test="$department_facet='Islamic' or $department_facet = 'East Asian' or $department_facet = 'South Asian' or $department_facet='Modern' or $department_facet='United
						States' or $department_facet='Latin American'">
						<xsl:apply-templates select="lst[@name='region_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='locality_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='mint_facet']" mode="facet"/>
						<xsl:if test="$department_facet='United States' or $department_facet='Latin American'">
							<xsl:apply-templates select="lst[@name='category_hier']" mode="facet"/>
						</xsl:if>
						<xsl:if test="$department_facet!='United States'">
							<xsl:apply-templates select="lst[@name='dynasty_facet']" mode="facet"/>
						</xsl:if>
						<xsl:apply-templates select="lst[@name='state_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='authority_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='issuer_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='maker_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='artist_facet']" mode="facet"/>
						<!--<xsl:apply-templates select="lst[@name='century_num']" mode="facet"/>-->
					</xsl:when>
					<xsl:when test="$department_facet='Medieval'">
						<xsl:apply-templates select="lst[@name='region_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='locality_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='mint_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='category_hier']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='dynasty_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='authority_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='issuer_facet']" mode="facet"/>
						<!--<xsl:apply-templates select="lst[@name='century_num']" mode="facet"/>-->
					</xsl:when>
					<xsl:when test="$department_facet='Medal'">
						<!--<xsl:apply-templates select="lst[@name='century_num']" mode="facet"/>-->
						<xsl:apply-templates select="lst[@name='region_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='locality_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='mint_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='maker_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='series_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='category_hier']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='artist_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='dynasty_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='authority_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='issuer_facet']" mode="facet"/>
					</xsl:when>
				</xsl:choose>
			</div>
			<div class="col-md-4">
				<h3>Object Description</h3>
				<xsl:if test="$department_facet != 'Medal'">
					<xsl:apply-templates select="lst[@name='denomination_facet']" mode="facet"/>
					<xsl:apply-templates select="lst[@name='material_facet']" mode="facet"/>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$department_facet='Modern' or $department_facet = 'United States'">
						<xsl:if test="$department_facet='Modern'">
							<xsl:apply-templates select="lst[@name='era_facet']" mode="facet"/>
						</xsl:if>
						<xsl:apply-templates select="lst[@name='dob_num']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='portrait_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='subjectPlace_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='subjectEvent_facet']" mode="facet"/>
						<xsl:if test="$department_facet='Modern'">
							<xsl:apply-templates select="lst[@name='category_hier']" mode="facet"/>
						</xsl:if>
						<xsl:apply-templates select="lst[@name='objectType_facet']" mode="facet"/>
					</xsl:when>
					<xsl:when test="$department_facet='Greek'">
						<xsl:apply-templates select="lst[@name='era_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='dob_num']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='portrait_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='deity_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='objectType_facet']" mode="facet"/>
					</xsl:when>
					<xsl:when test="$department_facet='Roman'">
						<xsl:apply-templates select="lst[@name='portrait_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='deity_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='objectType_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='coinType_facet']" mode="facet"/>
					</xsl:when>
					<xsl:when test="$department_facet='Byzantine' or $department_facet='Medieval' or $department_facet='Latin American'">
						<xsl:apply-templates select="lst[@name='portrait_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='dob_num']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='objectType_facet']" mode="facet"/>
					</xsl:when>
					<xsl:when test="$department_facet='Islamic' or $department_facet = 'South Asian'">
						<xsl:apply-templates select="lst[@name='era_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='dob_num']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='portrait_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='deity_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='objectType_facet']" mode="facet"/>
					</xsl:when>
					<xsl:when test="$department_facet='East Asian'">
						<xsl:apply-templates select="lst[@name='era_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='dob_num']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='portrait_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='subjectPlace_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='subjectEvent_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='objectType_facet']" mode="facet"/>
					</xsl:when>
					<xsl:when test="$department_facet='Medal'">
						<xsl:apply-templates select="lst[@name='portrait_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='subjectPerson_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='subjectPlace_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='subjectIssuer_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='subjectEvent_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='dob_num']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='material_facet']" mode="facet"/>
						<xsl:apply-templates select="lst[@name='objectType_facet']" mode="facet"/>
					</xsl:when>
				</xsl:choose>
			</div>
			<div class="col-md-4">
				<h3>Technical Details</h3>
				<xsl:apply-templates select="lst[@name='axis_num']" mode="facet"/>
				<xsl:apply-templates select="lst[@name='shape_facet']" mode="facet"/>
				<xsl:apply-templates select="lst[@name='manufacture_facet']" mode="facet"/>
				<div class="form-group">
					<label for="weight_range">
						<xsl:value-of select="numishare:normalize_fields('weight', $lang)"/>
						<xsl:text> (g)</xsl:text>
					</label>
					<div>
						<select id="weight_range" class="form-control technical-dropdown">
							<option value="lessequal">Less/Equal to</option>
							<option value="equal">Equal to</option>
							<option value="greaterequal">Greater/Equal to</option>
						</select>
						<input type="text" id="weight_int" class="form-control technical-input"/>
					</div>
				</div>
				<div class="form-group">
					<label for="diameter_range">
						<xsl:value-of select="numishare:normalize_fields('diameter', $lang)"/>
						<xsl:text> (mm)</xsl:text>
					</label>
					<div>
						<select id="diameter_range" class="form-control technical-dropdown">
							<option value="lessequal">Less/Equal to</option>
							<option value="equal">Equal to</option>
							<option value="greaterequal">Greater/Equal to</option>
						</select>
						<input type="text" id="diameter_int" class="form-control technical-input"/>
					</div>
				</div>
				<form action="{$display_path}results" method="GET" role="form" id="facet_form">
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
	</xsl:template>
</xsl:stylesheet>
