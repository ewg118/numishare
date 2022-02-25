<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<!-- request parameters -->
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

	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>

	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path"
		select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<!-- config variables-->
	<xsl:variable name="collection_type" select="//config/collection_type"/>

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

				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"/>
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>
				<script type="text/javascript" src="{$include_path}/javascript/identify_functions.js"/>
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="body"/>
				<xsl:call-template name="footer"/>
				<div class="hidden"> </div>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="body">
		<div class="container-fluid">
			<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>
			</xsl:if>
			<div class="row">
				<div class="col-md-12">
					<h1>Identify a Coin</h1>
					<p>This interface allows you to narrow down the most basic visible components of a coin in order to reveal a subset of possible matches in
						the search results page.</p>
					<form method="GET" action="results" class="form-horizontal" id="identify-form" style="margin-bottom:20px">
						<div class="metadata_section">
							<input type="submit" value="Search" class="btn btn-default"/>
						</div>
						<div class="metadata_section">
							<h2>
								<xsl:value-of select="numishare:normalize_fields('material', $lang)"/>
							</h2>
							<p class="text-muted">Select one or more types of metal. Note that, alongside gold and bronze, silver Roman coinage from the mid-3rd
								century onward uses various bronze-silver alloys, and are deemed ’silver’, ‘billon’, or not specified. From the mid-4th century
								onward, ‘billon’ coins only contain trace elements of silver. It is recommended for these coins to search for silver and billon,
								or billon and bronze, if uncertain.</p>
							<div>
								<xsl:apply-templates select="doc('input:materials')//lst[@name = 'material_uri']"/>
							</div>
						</div>
						<div class="metadata_section">
							<h2>
								<xsl:value-of select="numishare:normalize_fields('legend', $lang)"/>
							</h2>
							<p class="text-muted">Search for characters that appear on the front and back of the coin. Please enter legends without spaces or
								punctuation, using the wildcard asterisk character '*' to denote gaps in legibility, in the beginning, middle, or end of the
								legend. <br/>
								<xsl:choose>
									<xsl:when test="$collection-name = 'ocre'">
										<strong>Example: </strong><kbd>PCARISI*LEG</kbd> will match "P CARISIVS LEG". <br/><strong>Example:
										</strong><kbd>*CAES*AVG*</kbd> will match "IMP CAESAR AVGVST", "IMP CAESAR AVGVSTVS", "CAESAR AVG TRIB POTEST", etc.
									</xsl:when>
									<xsl:when test="$collection-name = 'hrc'">
										<strong>Example: </strong><kbd>*ΩΣANT*</kbd> will match "BAΣΙΛΕΩΣ ANTIOXΟΥ", "BAΣΙΛΕΩΣ ANTIOXΟΥ ΘEOY EΠIΦANOYΣ", "BAΣΙΛΕΩΣ ANTIOXOY KAI BAΣΙΛΕΩΣ ΦIΛIΠΠOY", etc.
									</xsl:when>
								</xsl:choose>
								</p>
							<div class="form-group">
								<label class="col-sm-2 control-label">
									<xsl:value-of select="numishare:normalize_fields('obv_leg', $lang)"/>
								</label>
								<div class="col-sm-10">
									<input field="obv_leg_text" type="text" class="form-control"/>
								</div>
							</div>
							<div class="form-group">
								<label class="col-sm-2 control-label">
									<xsl:value-of select="numishare:normalize_fields('rev_leg', $lang)"/>
								</label>
								<div class="col-sm-10">
									<input field="rev_leg_text" type="text" class="form-control"/>
								</div>
							</div>
						</div>
						<div class="metadata_section">
							<h2>
								<xsl:value-of select="numishare:normalize_fields('portrait', $lang)"/>
							</h2>
							<p class="text-muted">Portrait comparison may aid in identification, especially for heavily worn coinage. Ideal portraits are
								presented in gold, silver, and bronze (when available), as well as a worn example. You can page forward and backward through
								examples by clicking the buttons. Hover over the image to read the name of the individual depicted on the coin.</p>

							<xsl:apply-templates select="//period"/>
						</div>

						<div class="metadata_section">
							<p class="text-muted">Click the button below to execute the search.</p>
							<input name="q" id="q_input" type="hidden"/>
							<xsl:if test="string($langParam)">
								<input name="lang" type="hidden" value="{$langParam}"/>
							</xsl:if>
							<input type="submit" value="Search" class="btn btn-default"/>
						</div>
					</form>
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- generate form elements from facets -->
	<xsl:template match="lst">
		<xsl:variable name="count" select="count(int)"/>

		<xsl:apply-templates select="int">
			<xsl:with-param name="count" select="$count"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="int">
		<xsl:param name="count"/>

		<xsl:variable name="label" select="document(concat('http://nomisma.org/apis/getLabel?uri=', @name, '&amp;lang=', $lang))/response"/>

		<div class="col-md-{if ($count = 3) then '4' else '3'}">
			<input type="checkbox" field="material" value="{$label}" id="material-{substring-after(@name, 'id/')}"/>
			<span>
				<xsl:value-of select="$label"/>
			</span>
		</div>
	</xsl:template>

	<!-- periods -->
	<xsl:template match="period">
		<div class="row">
			<div class="col-md-12 metadata_section">
				<h3>
					<xsl:value-of select="@label"/>
				</h3>
				<xsl:apply-templates select="portrait"/>
				<div class="col-md-12">
					<hr/>
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- generate portrait list -->
	<xsl:template match="portrait">
		<xsl:variable name="uri" select="@uri"/>

		<xsl:variable name="label"
			select="
				if (doc('input:rdf')//foaf:Person[@rdf:about = $uri]/skos:prefLabel[@xml:lang = $lang]) then
					doc('input:rdf')//foaf:Person[@rdf:about = $uri]/skos:prefLabel[@xml:lang = $lang]
				else
					doc('input:rdf')//foaf:Person[@rdf:about = $uri]/skos:prefLabel[@xml:lang = 'en']"/>

		<div class="col-sm-6 col-md-3 col-lg-2 portrait" title="{$label}">
			<!--<xsl:attribute name="style">background: url(&#x022;<xsl:value-of select="$portrait/descendant::image[1]"/>&#x022;); background-size: 100%; background-repeat: no-repeat;</xsl:attribute>-->
			<div class="image-spacer text-center">
				<xsl:choose>
					<xsl:when test="descendant::image">
						<img src="{descendant::image[1]}" alt="Obverse Image"/>
					</xsl:when>
					<xsl:otherwise>
						<p style="padding-top:80px" class="text-muted">
							<xsl:text>No portraits available for </xsl:text>
							<xsl:value-of select="$label"/>
						</p>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="paginate-images">
				<div style="margin-bottom:2px">
					<xsl:choose>
						<xsl:when test="descendant::image">
							<xsl:attribute name="class">text-center name-container</xsl:attribute>
							<xsl:value-of select="$label"/>
						</xsl:when>

						<xsl:otherwise>
							<xsl:attribute name="class">text-center name-container-empty</xsl:attribute>
							<span>
								<xsl:text>&#160;</xsl:text>
							</span>
						</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="row">
					<div class="col-xs-4">
						<button class="btn btn-default page-prev">
							<xsl:if test="count(descendant::image) &lt;= 1">
								<xsl:attribute name="disabled">disabled</xsl:attribute>
							</xsl:if>
							<span class="glyphicon glyphicon-chevron-left"/>
						</button>
					</div>
					<div class="col-xs-4 text-center">
						<input type="checkbox" field="portrait" value="{$label}"/>
					</div>
					<div class="col-xs-4 text-right">
						<button class="btn btn-default page-next">
							<xsl:if test="count(descendant::image) &lt;= 1">
								<xsl:attribute name="disabled">disabled</xsl:attribute>
							</xsl:if>
							<span class="glyphicon glyphicon-chevron-right"/>
						</button>
					</div>
				</div>
			</div>

			<!-- construct json and insert into a hidden div -->
			<div class="hidden">
				<xsl:text>{</xsl:text>
				<xsl:for-each select="material[image]">
					<xsl:value-of select="concat('&#x022;', substring-after(@uri, 'id/'), '&#x022;')"/>
					<xsl:text>:[</xsl:text>
					<xsl:for-each select="image">
						<xsl:value-of select="concat('&#x022;', ., '&#x022;')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>,</xsl:text>
						</xsl:if>
					</xsl:for-each>
					<xsl:text>]</xsl:text>
					<xsl:if test="not(position() = last())">
						<xsl:text>,</xsl:text>
					</xsl:if>
				</xsl:for-each>
				<xsl:if test="worn">
					<xsl:text>,"worn":[</xsl:text>
					<xsl:for-each select="worn/image">
						<xsl:value-of select="concat('&#x022;', ., '&#x022;')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>,</xsl:text>
						</xsl:if>
					</xsl:for-each>
					<xsl:text>]</xsl:text>
				</xsl:if>
				<xsl:text>}</xsl:text>
			</div>
		</div>
	</xsl:template>

	<!--<xsl:template match="res:result">
		<xsl:variable name="uri" select="res:binding[@name = 'portrait']/res:uri"/>
		<xsl:variable name="label"
			select="
				if (res:binding[@name = 'default_label']) then
					res:binding[@name = 'default_label']/res:literal
				else
					res:binding[@name = 'en_label']/res:literal"/>
		<xsl:variable name="portrait" as="element()*">
			<xsl:copy-of select="/content//portrait[@uri = $uri]"/>
		</xsl:variable>

		<div class="col-sm-6 col-md-3 col-lg-2 portrait" title="{$label}">
			<!-\-<xsl:attribute name="style">background: url(&#x022;<xsl:value-of select="$portrait/descendant::image[1]"/>&#x022;); background-size: 100%; background-repeat: no-repeat;</xsl:attribute>-\->
			<div class="image-spacer text-center">
				<xsl:choose>
					<xsl:when test="$portrait//image">
						<img src="{$portrait/descendant::image[1]}" alt="Obverse Image"/>
					</xsl:when>
					<xsl:otherwise>
						<p style="padding-top:80px" class="text-muted">
							<xsl:text>No portraits available for </xsl:text>
							<xsl:value-of select="$label"/>
						</p>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="paginate-images">
				<div style="margin-bottom:2px">
					<xsl:choose>
						<xsl:when test="$portrait//image">
							<xsl:attribute name="class">text-center name-container</xsl:attribute>
							<xsl:value-of select="$label"/>
						</xsl:when>

						<xsl:otherwise>
							<xsl:attribute name="class">text-center name-container-empty</xsl:attribute>
							<span>
								<xsl:text>&#160;</xsl:text>
							</span>
						</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="col-xs-4">
					<button class="btn btn-default page-prev">
						<xsl:if test="count($portrait//image) &lt;= 1">
							<xsl:attribute name="disabled">disabled</xsl:attribute>
						</xsl:if>
						<span class="glyphicon glyphicon-chevron-left"/>
					</button>
				</div>
				<div class="col-xs-4 text-center">
					<input type="checkbox" field="portrait" value="{$label}"/>
				</div>
				<div class="col-xs-4 text-right">
					<button class="btn btn-default page-next">
						<xsl:if test="count($portrait//image) &lt;= 1">
							<xsl:attribute name="disabled">disabled</xsl:attribute>
						</xsl:if>
						<span class="glyphicon glyphicon-chevron-right"/>
					</button>
				</div>
			</div>
			<!-\- construct json and insert into a hidden div -\->
			<div class="hidden">
				<xsl:text>{</xsl:text>
				<xsl:for-each select="$portrait/material[image]">
					<xsl:value-of select="concat('&#x022;', substring-after(@uri, 'id/'), '&#x022;')"/>
					<xsl:text>:[</xsl:text>
					<xsl:for-each select="image">
						<xsl:value-of select="concat('&#x022;', ., '&#x022;')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>,</xsl:text>
						</xsl:if>
					</xsl:for-each>
					<xsl:text>]</xsl:text>
					<xsl:if test="not(position() = last())">
						<xsl:text>,</xsl:text>
					</xsl:if>
				</xsl:for-each>
				<xsl:if test="$portrait/worn">
					<xsl:text>,"worn":[</xsl:text>
					<xsl:for-each select="$portrait/worn/image">
						<xsl:value-of select="concat('&#x022;', ., '&#x022;')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>,</xsl:text>
						</xsl:if>
					</xsl:for-each>
					<xsl:text>]</xsl:text>
				</xsl:if>
				<xsl:text>}</xsl:text>
			</div>
		</div>
	</xsl:template>-->
</xsl:stylesheet>
