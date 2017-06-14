<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>

	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path" select="if (string(//config/theme/themes_url)) then concat(//config/theme/themes_url, //config/theme/orbeon_theme) else concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="numishare:normalizeLabel('header_contributors', $lang)"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>

				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>
				<xsl:if test="string(/content/config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="/content/config/google_analytics"/>
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
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-12">
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('header_contributors', $lang)"/>
					</h1>
					<table class="table table-striped">
						<thead>
							<tr>
								<th/>
								<th>Count</th>
								<th>Collection</th>
							</tr>
						</thead>
						<tbody>
							<xsl:apply-templates select="descendant::res:result[res:binding[@name='collection']/res:uri]" mode="contributors"/>
						</tbody>						
					</table>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="res:result" mode="contributors">
		<xsl:variable name="rdf" as="element()*">
			<xsl:copy-of select="document(concat(res:binding[@name='collection']/res:uri, '.rdf'))/*"/>
		</xsl:variable>

		<tr>
			<td>
				<xsl:if test="string($rdf//foaf:thumbnail/@rdf:resource)">
					<a href="{if (string($rdf//foaf:homepage/@rdf:resource)) then $rdf//foaf:homepage/@rdf:resource else res:binding[@name='collection']/res:uri}">
						<img src="{$rdf//foaf:thumbnail/@rdf:resource}" alt="logo"/>
					</a>
				</xsl:if>
			</td>
			<td>
				<h2>
					<xsl:value-of select="res:binding[@name='count']/res:literal"/>
				</h2>
			</td>
			<td>
				<h2>
					<a href="{if (string($rdf//foaf:homepage/@rdf:resource)) then $rdf//foaf:homepage/@rdf:resource else res:binding[@name='collection']/res:uri}">
						<xsl:choose>
							<xsl:when test="$rdf//skos:prefLabel[@xml:lang=$lang]">
								<xsl:value-of select="$rdf//skos:prefLabel[@xml:lang=$lang]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$rdf//skos:prefLabel[@xml:lang='en']"/>
							</xsl:otherwise>
						</xsl:choose>
					</a>
				</h2>
				<dl class="dl-horizontal">
					<dt>Nomisma URI</dt>
					<dd>
						<a href="{res:binding[@name='collection']/res:uri}">
							<xsl:value-of select="res:binding[@name='collection']/res:uri"/>
						</a>
					</dd>
					<dt>Definition</dt>
					<dd>
						<xsl:choose>
							<xsl:when test="$rdf//skos:prefLabel[@xml:lang=$lang]">
								<xsl:value-of select="$rdf//skos:definition[@xml:lang=$lang]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$rdf//skos:definition[@xml:lang='en']"/>
							</xsl:otherwise>
						</xsl:choose>
					</dd>
				</dl>
			</td>

		</tr>
	</xsl:template>
</xsl:stylesheet>
