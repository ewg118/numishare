<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

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
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>

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
								<xsl:if test="descendant::res:binding[@name = 'thumbnail']">
									<th style="width:200px"/>
								</xsl:if>
								<th>
									<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
								</th>
								<th>
									<xsl:value-of select="numishare:regularize_node('collection', $lang)"/>
								</th>
							</tr>
						</thead>
						<tbody>
							<xsl:apply-templates select="descendant::res:result" mode="contributors"/>
						</tbody>
						<tfoot>
							<tr>
								<td>
									<h2>Total</h2>
								</td>
								<td>
									<h2>
										<xsl:value-of select="format-number(sum(descendant::res:binding[@name = 'count']/res:literal), '###,###')"/>
									</h2>
								</td>
								<td/>
							</tr>
						</tfoot>
					</table>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="res:result" mode="contributors">
		<tr>
			<td>
				<xsl:if test="string(res:binding[@name = 'thumbnail']/res:uri)">
					<xsl:variable name="link">
						<xsl:choose>
							<xsl:when test="res:binding[@name = 'memberOf']">
								<xsl:value-of select="res:binding[@name = 'memberOf']/res:uri"/>
							</xsl:when>
							<xsl:when test="res:binding[@name = 'homepage']">
								<xsl:value-of select="res:binding[@name = 'homepage']/res:uri"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="res:binding[@name = 'dataset']/res:uri"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<a href="{$link}">
						<img src="{res:binding[@name='thumbnail']/res:uri}" alt="logo" style="max-width:200px"/>
					</a>
				</xsl:if>
			</td>
			<td>
				<h2>
					<xsl:value-of select="format-number(res:binding[@name = 'count']/res:literal, '###,###')"/>
				</h2>
			</td>
			<td>
				<h2>
					<xsl:choose>
						<xsl:when test="res:binding[@name = 'collection']">
							<a
								href="{if (string(res:binding[@name='homepage']/res:uri)) then res:binding[@name='homepage']/res:uri else res:binding[@name='dataset']/res:uri}">
								<xsl:value-of select="res:binding[@name = 'collectionLabel']/res:literal"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a href="{res:binding[@name='dataset']/res:uri}">
								<xsl:value-of select="res:binding[@name = 'title']/res:literal"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>

				</h2>
				<dl class=" {if(//config/languages/language[@code = $lang]/@rtl = true()) then 'dl-horizontal dl-rtl' else 'dl-horizontal'}">
					<xsl:if test="res:binding[@name = 'collection']">
						<dt>Nomisma URI</dt>
						<dd>
							<a href="{res:binding[@name='collection']/res:uri}">
								<xsl:value-of select="res:binding[@name = 'collection']/res:uri"/>
							</a>
						</dd>
					</xsl:if>
					<xsl:if test="res:binding[@name = 'collection']">
						<xsl:if test="not(res:binding[@name='homepage']/res:uri = res:binding[@name='dataset']/res:uri)">
							<dt>
								<xsl:value-of select="numishare:regularize_node('dataset', $lang)"/>
							</dt>
							<dd>
								<a href="{res:binding[@name='dataset']/res:uri}">
									<xsl:value-of select="res:binding[@name = 'title']/res:literal"/>
								</a>
							</dd>
						</xsl:if>
						
					</xsl:if>
					<xsl:if test="res:binding[@name = 'publisher']">
						<dt>
							<xsl:value-of select="numishare:regularize_node('publisher', $lang)"/>
						</dt>
						<dd>
							<xsl:value-of select="res:binding[@name = 'publisher']/res:literal"/>
						</dd>
					</xsl:if>
					<dt>
						<xsl:value-of select="numishare:regularize_node('description', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="res:binding[@name = 'description']/res:literal"/>
					</dd>
					<xsl:choose>
						<xsl:when test="res:binding[@name='license']">
							<dt>
								<xsl:value-of select="numishare:regularize_node('license', $lang)"/>
							</dt>
							<dd>
								<a href="{res:binding[@name='license']/res:uri}">
									<xsl:variable name="license" select="res:binding[@name='license']/res:uri"/>
									<xsl:choose>
										<xsl:when test="contains($license, 'http://opendatacommons.org/licenses/odbl/')">ODC-ODbL</xsl:when>
										<xsl:when test="contains($license, 'http://opendatacommons.org/licenses/by/')">ODC-by</xsl:when>
										<xsl:when test="contains($license, 'http://opendatacommons.org/licenses/pddl/')">ODC-PDDL</xsl:when>
										<xsl:when test="contains($license, 'http://creativecommons.org/licenses/by/')">
											<img src="http://i.creativecommons.org/l/by/3.0/88x31.png" alt="CC BY" title="CC BY"/>
										</xsl:when>
										<xsl:when test="contains($license, 'http://creativecommons.org/licenses/by-nd/')">
											<img src="http://i.creativecommons.org/l/by-nd/3.0/88x31.png" alt="CC BY-ND" title="CC BY-ND"/>
										</xsl:when>
										<xsl:when test="contains($license, 'http://creativecommons.org/licenses/by-nc-sa/')">
											<img src="http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png" alt="CC BY-NC-SA" title="CC BY-NC-SA"/>
										</xsl:when>
										<xsl:when test="contains($license, 'http://creativecommons.org/licenses/by-sa/')">
											<img src="http://i.creativecommons.org/l/by-sa/3.0/88x31.png" alt="CC BY-SA" title="CC BY-SA"/>
										</xsl:when>
										<xsl:when test="contains($license, 'http://creativecommons.org/licenses/by-nc/')">
											<img src="http://i.creativecommons.org/l/by-nc/3.0/88x31.png" alt="CC BY-NC" title="CC BY-NC"/>
										</xsl:when>
										<xsl:when test="contains($license, 'http://creativecommons.org/licenses/by-nc-nd/')">
											<img src="http://i.creativecommons.org/l/by-nc-nd/3.0/88x31.png" alt="CC BY-NC-ND" title="CC BY-NC-ND"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="res:binding[@name='license']/res:uri"/>
										</xsl:otherwise>
									</xsl:choose>
								</a>
							</dd>
						</xsl:when>
						<xsl:when test="res:binding[@name='rights']">
							<dt>
								<xsl:value-of select="numishare:regularize_node('rights', $lang)"/>
							</dt>
							<dd>
								<xsl:value-of select="res:binding[@name='rights']/res:literal"/>
							</dd>
						</xsl:when>
					</xsl:choose>
				</dl>
			</td>

		</tr>
	</xsl:template>
</xsl:stylesheet>
