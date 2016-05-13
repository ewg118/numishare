<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:nmo="http://nomisma.org/ontology#" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:param name="url" select="//config/url"/>
	<xsl:param name="lang" select="if (doc('input:request')/request/parameters/parameter[name='lang']/value) then doc('input:request')/request/parameters/parameter[name='lang']/value else 'en'"/>
	<xsl:param name="display_path"/>
	<xsl:variable name="include_path" select="concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<!-- config variables-->
	<xsl:variable name="collection_type" select="//config/collection_type"/>

	<!-- load facets into variable -->
	<xsl:variable name="facets" select="//lst[@name='facet_fields']" as="node()*"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: Symbols</xsl:text>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
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
			<xsl:if test="$lang='ar'">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>
			</xsl:if>
			<div class="row">
				<div class="col-md-12">
					<h1>Symbols</h1>
					<table class="table table-striped">
						<thead>
							<th style="width:100px">Image</th>
							<th>Description</th>
						</thead>
						<tbody>
							<xsl:apply-templates select="//rdf:RDF/*" mode="symbol"/>
						</tbody>
					</table>

				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="*" mode="symbol">
		<xsl:variable name="id" select="tokenize(@rdf:about, '/')[last()]"/>

		<tr>
			<td><img src="../symbols/{$id}.png" style="width:100%"/></td>
			<td>
				<h3>
					<a href="symbol/{$id}">
						<xsl:choose>
							<xsl:when test="skos:prefLabel[@xml:lang=$lang]">
								<xsl:value-of select="skos:prefLabel[@xml:lang=$lang]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="skos:prefLabel[@xml:lang='en']"/>
							</xsl:otherwise>
						</xsl:choose>						
					</a>
				</h3>
				<dl class="dl-horizontal">
					<dt>Definition</dt>
					<dd>
						<xsl:choose>
							<xsl:when test="skos:definition[@xml:lang=$lang]">
								<xsl:value-of select="skos:definition[@xml:lang=$lang]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="skos:definition[@xml:lang='en']"/>
							</xsl:otherwise>
						</xsl:choose>
					</dd>
				</dl>
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>
