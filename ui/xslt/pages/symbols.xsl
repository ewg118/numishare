<?xml version="1.0" encoding="UTF-8"?>

<!-- Author: Ethan Gruber
	Date modified: December 2019
	Function: Serialize symbol results into paginated HTML pages -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:numishare="https://github.com/ewg118/numishare" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:void="http://rdfs.org/ns/void#"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:prov="http://www.w3.org/ns/prov#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
	xmlns:crmdig="http://www.ics.forth.gr/isl/CRMdig" exclude-result-prefixes="#all" version="2.0">

	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:param name="url" select="//config/url"/>
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

	<!-- pagination params/variables -->
	<xsl:param name="limit">48</xsl:param>
	<xsl:param name="page" select="doc('input:request')/request/parameters/parameter[name = 'page']/value"/>

	<xsl:variable name="offset">
		<xsl:choose>
			<xsl:when test="string-length($page) &gt; 0 and $page castable as xs:integer and number($page) > 0">
				<xsl:value-of select="($page - 1) * number($limit)"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="numFound" select="doc('input:count')//count" as="xs:integer"/>

	<!-- path variables -->
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
					<xsl:value-of select="numishare:normalizeLabel('header_symbols', $lang)"/>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>

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

			</body>
		</html>
	</xsl:template>

	<xsl:template name="body">
		<div class="container-fluid">
			<xsl:if test="$lang = 'ar'">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>
			</xsl:if>
			<div class="row">
				<div class="col-md-12">
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('header_symbols', $lang)"/>
					</h1>

					<xsl:if test="$numFound &gt; $limit">
						<xsl:call-template name="pagination">
							<xsl:with-param name="page" select="$page" as="xs:integer"/>
							<xsl:with-param name="numFound" select="$numFound" as="xs:integer"/>
							<xsl:with-param name="limit" select="$limit" as="xs:integer"/>
						</xsl:call-template>
					</xsl:if>

					<xsl:apply-templates select="//rdf:RDF/*" mode="symbol"/>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="*" mode="symbol">
		<xsl:variable name="id" select="tokenize(@rdf:about, '/')[last()]"/>

		<div class="col-md-3 col-sm-6 col-lg-2 monogram" style="height:400px">
			<img
				src="{
				if (crm:P165i_is_incorporated_in/@rdf:resource) then
				crm:P165i_is_incorporated_in[1]/@rdf:resource
				else
				crm:P165i_is_incorporated_in[1]/crmdig:D1_Digital_Object/@rdf:about}"
				alt="Symbol image" style="width:100%"/>
			<a href="symbol/{$id}">
				<xsl:choose>
					<xsl:when test="skos:prefLabel[@xml:lang = $lang]">
						<xsl:value-of select="skos:prefLabel[@xml:lang = $lang]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="skos:prefLabel[@xml:lang = 'en']"/>
					</xsl:otherwise>
				</xsl:choose>
			</a>
			<xsl:if test="crm:P106_is_composed_of">
				<br/>
				<strong>Constituent Letters: </strong>
				<xsl:for-each select="crm:P106_is_composed_of">
					<xsl:if test="position() = last()">
						<xsl:text> and</xsl:text>
					</xsl:if>
					<xsl:text> </xsl:text>
					<xsl:value-of select="."/>
					<xsl:if test="not(position() = last()) and (count(../crm:P106_is_composed_of) &gt; 2)">
						<xsl:text>,</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- ********** PAGINATION *********** -->
	<xsl:template name="pagination">
		<xsl:param name="page" as="xs:integer"/>
		<xsl:param name="numFound" as="xs:integer"/>
		<xsl:param name="limit" as="xs:integer"/>

		<xsl:variable name="offset" select="($page - 1) * $limit" as="xs:integer"/>

		<xsl:variable name="previous" select="$page - 1"/>
		<xsl:variable name="current" select="$page"/>
		<xsl:variable name="next" select="$page + 1"/>
		<xsl:variable name="total" select="ceiling($numFound div $limit)"/>

		<div class="col-md-12">
			<div class="row">
				<div class="col-md-6">
					<xsl:variable name="startRecord" select="$offset + 1"/>
					<xsl:variable name="endRecord">
						<xsl:choose>
							<xsl:when test="$numFound &gt; ($offset + $limit)">
								<xsl:value-of select="$offset + $limit"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$numFound"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<p>Records <b><xsl:value-of select="$startRecord"/></b> to <b><xsl:value-of select="$endRecord"/></b> of <b><xsl:value-of select="$numFound"
							/></b></p>
				</div>
				<!-- paging functionality -->
				<div class="col-md-6">
					<div class="btn-toolbar" role="toolbar">
						<div class="btn-group pull-right">
							<!-- first page -->
							<xsl:if test="$current &gt; 1">
								<a class="btn btn-default" role="button" title="First" href="?page=1#examples">
									<span class="glyphicon glyphicon-fast-backward"/>
									<xsl:text> 1</xsl:text>
								</a>
								<a class="btn btn-default" role="button" title="Previous" href="?page={$current - 1}#examples">
									<xsl:text>Previous </xsl:text>
									<span class="glyphicon glyphicon-backward"/>
								</a>
							</xsl:if>
							<xsl:if test="$current &gt; 5">
								<button type="button" class="btn btn-default disabled">
									<xsl:text>...</xsl:text>
								</button>
							</xsl:if>
							<xsl:if test="$current &gt; 4">
								<a class="btn btn-default" role="button" href="?page={$current - 3}#examples">
									<xsl:value-of select="$current - 3"/>
									<xsl:text> </xsl:text>
								</a>
							</xsl:if>
							<xsl:if test="$current &gt; 3">
								<a class="btn btn-default" role="button" href="?page={$current - 2}#examples">
									<xsl:value-of select="$current - 2"/>
									<xsl:text> </xsl:text>
								</a>
							</xsl:if>
							<xsl:if test="$current &gt; 2">
								<a class="btn btn-default" role="button" href="?page={$current - 1}#examples">
									<xsl:value-of select="$current - 1"/>
									<xsl:text> </xsl:text>
								</a>
							</xsl:if>
							<!-- current page -->
							<button type="button" class="btn btn-default active">
								<b>
									<xsl:value-of select="$current"/>
								</b>
							</button>
							<xsl:if test="$total &gt; ($current + 1)">
								<a class="btn btn-default" role="button" title="Next" href="?page={$current + 1}#examples">
									<xsl:value-of select="$current + 1"/>
								</a>
							</xsl:if>
							<xsl:if test="$total &gt; ($current + 2)">
								<a class="btn btn-default" role="button" title="Next" href="?page={$current + 2}#examples">
									<xsl:value-of select="$current + 2"/>
								</a>
							</xsl:if>
							<xsl:if test="$total &gt; ($current + 3)">
								<a class="btn btn-default" role="button" title="Next" href="?page={$current + 3}#examples">
									<xsl:value-of select="$current + 3"/>
								</a>
							</xsl:if>
							<xsl:if test="$total &gt; ($current + 4)">
								<button type="button" class="btn btn-default disabled">
									<xsl:text>...</xsl:text>
								</button>
							</xsl:if>
							<!-- last page -->
							<xsl:if test="$current &lt; $total">
								<a class="btn btn-default" role="button" title="Next" href="?page={$current + 1}#examples">
									<xsl:text>Next </xsl:text>
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default" role="button" title="Last" href="?page={$total}#examples">
									<xsl:value-of select="$total"/>
									<xsl:text> </xsl:text>
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:if>
						</div>
					</div>
				</div>
			</div>
		</div>

	</xsl:template>

</xsl:stylesheet>
