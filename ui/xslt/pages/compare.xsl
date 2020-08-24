<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="text/html"/>
	
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>
	<xsl:include href="../templates-search.xsl"/>

	<xsl:param name="pipeline">compare</xsl:param>
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
	<xsl:param name="mode" select="doc('input:request')/request/parameters/parameter[name='mode']/value"/>
	
	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path" select="if (string(//config/theme/themes_url)) then concat(//config/theme/themes_url, //config/theme/orbeon_theme) else concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<!-- config variables-->
	<xsl:variable name="collection_type" select="//config/collection_type"/>

	<!-- load facets into variable -->
	<xsl:variable name="facets" select="//lst[@name='facet_fields']"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="numishare:normalizeLabel('header_compare', $lang)"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
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
				
				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>

				<!-- search related functions -->
				<script type="text/javascript" src="{$include_path}/javascript/search_functions.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/compare.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/compare_functions.js"/>
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="compare"/>
				<xsl:call-template name="footer"/>
				<div class="hidden">
					<span id="pipeline">
						<xsl:value-of select="$pipeline"/>
					</span>
					<span id="display_path">
						<xsl:value-of select="$display_path"/>
					</span>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="compare">
		<div class="container-fluid">
			<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>							
			</xsl:if>
			<div class="row">
				<div class="col-md-12">
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('header_compare', $lang)"/>
					</h1>
					<p>This feature allows you to compare the results of conducting two separate searches of the database. The results of the searches are displayed on the results page in parallel
						columns and may be sorted separately.</p>
				</div>
			</div>
			<div class="row">
				<div class="col-md-6">
					<h2>Dataset 1</h2>
					<div class="compare-form">
						<form role="form" id="dataset1" method="GET">
							<div class="inputContainer">
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
							</div>
						</form>
					</div>
				</div>
				<div class="col-md-6">
					<h2>Dataset 2</h2>
					<div class="compare-form">
						<form role="form" id="dataset2" method="GET">
							<div class="inputContainer">
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
							</div>
						</form>
						<form role="form" method="GET">
							<div class="form-group">
								<label for="image">Image Side</label>
								<br/>
								<select id="image" class="form-control">
									<option value="obverse">
										<xsl:value-of select="numishare:regularize_node('obverse', $lang)"/>
									</option>
									<option value="reverse">
										<xsl:value-of select="numishare:regularize_node('reverse', $lang)"/>
									</option>
								</select>
							</div>
							<div class="form-group">
								<input class="compare_button btn btn-default" type="submit" value="Compare Data"/>
							</div>
						</form>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-6">
					<div id="search1"/>
				</div>
				<div class="col-md-6">
					<div id="search2"/>
				</div>
			</div>
		</div>

		<div id="searchItemTemplate" class="searchItemTemplate">
			<select class="category_list form-control">
				<xsl:call-template name="search_options"/>
			</select>
			<div style="display:inline;" class="option_container">
				<input type="text" class="search_text form-control" style="display: inline;"/>
			</div>
			<a class="gateTypeBtn" href="#">
				<span class="glyphicon glyphicon-plus"/>
			</a>
			<a class="removeBtn" href="#" style="display:none;">
				<span class="glyphicon glyphicon-remove"/>
			</a>
		</div>
	</xsl:template>
</xsl:stylesheet>
