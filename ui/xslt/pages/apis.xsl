<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

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

	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path" select="if (string(//config/theme/themes_url)) then concat(//config/theme/themes_url, //config/theme/orbeon_theme) else concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: API Documentation</xsl:text>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>

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
					<h1>Documentation</h1>
					<div>
						<h2>APIs</h2>
						<table class="table">
							<thead>
								<tr>
									<th style="width:50%">API</th>
									<th>XML</th>
									<th>JSON</th>
									<th>Turtle</th>
								</tr>
							</thead>
							<tbody>
								<tr>
									<td>
										<a href="#getNuds">getNuds</a>
									</td>
									<td>
										<a href="apis/getNuds?identifiers={string-join(//doc/str[@name='recordId'], '|')}">NUDS/XML</a>
									</td>
									<td/>
									<td/>
								</tr>
								<tr>
									<td>
										<a href="#getRDF">getRDF</a>
									</td>
									<td>
										<a href="apis/getRDF?identifiers={string-join(//doc/str[@name='recordId'], '|')}">RDF/XML</a>
									</td>
									<td/>
									<td/>
								</tr>
							</tbody>
						</table>
						<div class="highlight" id="getNuds">
							<h3>Get NUDS</h3>
							<p>Get an aggregated NUDS/XML serialization based on the recordIds in the collection.<br/>
								<b>Webservice Type</b> : REST<br/>
								<b>Url</b>: <xsl:value-of select="concat(/content/config/url, 'apis/getNuds?')"/><br/>
								<b>Parameters</b> : identifiers (recordIds divided by a pipe '|')<br/>
								<b>Result</b> : returns NUDS/XML records aggregated in a nudsGroup root element.<br/>
								<b>Example</b>: <a href="apis/getNuds?identifiers={string-join(//doc/str[@name='recordId'], '|')}">apis/getNuds?identifiers=<xsl:value-of
										select="string-join(//doc/str[@name='recordId'], '|')"/></a>
							</p>
						</div>
						<div class="highlight" id="getRDF">
							<h3>Get RDF</h3>
							<p>Get an aggregated RDF/XML serialization based on the recordIds in the collection.<br/>
								<b>Webservice Type</b> : REST<br/>
								<b>Url</b>: <xsl:value-of select="concat(/content/config/url, 'apis/getRDF?')"/><br/>
								<b>Parameters</b> : identifiers (recordIds divided by a pipe '|')<br/>
								<b>Result</b> : returns RDF/XML triples for given objects/hoards/coin types.<br/>
								<b>Example</b>: <a href="apis/getRDF?identifiers={string-join(//doc/str[@name='recordId'], '|')}">apis/getRDF?identifiers=<xsl:value-of
									select="string-join(//doc/str[@name='recordId'], '|')"/></a>
							</p>
						</div>
					</div>
					<div>
						<h2>Data Access</h2>
						<div>
							<h3>Individual Records</h3>
							<p>Numishare supports delivery of individual records in a variety of models and serializations through both REST and content negotiation. Content negotiation (with the
								accept header) requests should be sent to the URI space <xsl:value-of select="concat(/content/config/url, 'id/')"/>. Requesting an unsupported content type will result in an HTTP 406: Not
								Acceptable error.</p>
							<table class="table">
								<thead>
									<tr>
										<th>Model</th>
										<th>REST</th>
										<th>Content Type</th>

									</tr>
								</thead>
								<tbody>
									<tr>
										<td>HTML</td>
										<td>
											<xsl:value-of select="concat(/content/config/url, 'id/{$id}')"/>
										</td>
										<td>
											<code>text/html</code>
										</td>
									</tr>
									<tr>
										<td>NUDS/XML</td>
										<td>
											<xsl:value-of select="concat(/content/config/url, 'id/{$id}.xml')"/>
										</td>
										<td>
											<code>application/xml</code>
										</td>
									</tr>
									<tr>
										<td>KML</td>
										<td>
											<xsl:value-of select="concat(/content/config/url, 'id/{$id}.kml')"/>
										</td>
										<td>
											<code>application/vnd.google-earth.kml+xml</code>
										</td>
									</tr>
									<tr>
										<td>RDF/XML</td>
										<td>
											<xsl:value-of select="concat(/content/config/url, 'id/{$id}.rdf')"/>
										</td>
										<td>
											<code>application/rdf+xml</code>
										</td>
									</tr>
									<tr>
										<td>Turtle</td>
										<td>
											<xsl:value-of select="concat(/content/config/url, 'id/{$id}.ttl')"/>
										</td>
										<td>
											<code>text/turtle</code>
										</td>
									</tr>
									<tr>
										<td>JSON-LD</td>
										<td>
											<xsl:value-of select="concat(/content/config/url, 'id/{$id}.jsonld')"/>
										</td>
										<td>
											<code>application/ld+json</code>
										</td>
									</tr>
									<tr>
										<td>geoJSON</td>
										<td>
											<xsl:value-of select="concat(/content/config/url, 'id/{$id}.geojson')"/>
										</td>
										<td>
											<code>application/vnd.geo+json</code>
										</td>
									</tr>
								</tbody>
							</table>
						</div>

						<div>
							<h3>Search Results</h3>
							<p>Search results (the browse page) are returned in HTML5, but Numishare supports Atom and RSS via REST, as well as Atom and raw Solr XML via content negotiation of the
								browse page URL, <a href="{concat(/content/config/url, 'results')}"><xsl:value-of select="concat(/content/config/url, 'results')"/></a>. The REST-based Atom feed sorts
								by the Lucene syntax 'timestamp desc' by default, but the sort parameter may be provided manually to alter the default field and order.</p>							
							<table class="table">
								<thead>
									<tr>
										<th>Model</th>
										<th>REST</th>
										<th>Content Type</th>

									</tr>
								</thead>
								<tbody>
									<tr>
										<td>HTML</td>
										<td>
											<a href="{concat(/content/config/url, 'results')}">
												<xsl:value-of select="concat(/content/config/url, 'results')"/>
											</a>
										</td>
										<td>
											<code>text/html</code>
										</td>
									</tr>
									<tr>
										<td>Atom</td>
										<td>
											<a href="{concat(/content/config/url, 'feed/')}">
												<xsl:value-of select="concat(/content/config/url, 'feed/')"/>
											</a>
										</td>
										<td>
											<code>application/atom+xml</code>
										</td>
									</tr>
									<tr>
										<td>RSS</td>
										<td>
											<a href="{concat(/content/config/url, 'apis/search?q=*:*&amp;format=rss')}">
												<xsl:value-of select="concat(/content/config/url, 'apis/search?q=*:*&amp;format=rss')"/>
											</a>
										</td>
										<td>N/A</td>
									</tr>
									<tr>
										<td>Solr/XML</td>
										<td>N/A</td>
										<td>
											<code>application/xml</code>
										</td>
									</tr>
								</tbody>
							</table>
							
							<h4>Geographic Responses</h4>
							<p>Search results may also be serialized into geographic models when relevant, for example to show the mints, findspots, or subjects related to the current query. Results are made available in KML and geoJSON.</p>
							<table class="table">
								<thead>
									<tr>
										<th>Response Type</th>
										<th>geoJSON</th>
										<th>KML</th>										
									</tr>
								</thead>
								<tbody>
									<tr>
										<td>Mints</td>
										<td>
											<a href="{concat(/content/config/url, 'mints.geojson')}">
												<xsl:value-of select="concat(/content/config/url, 'mints.geojson')"/>
											</a>
										</td>
										<td>
											<a href="{concat(/content/config/url, 'mints.kml')}">
												<xsl:value-of select="concat(/content/config/url, 'mints.kml')"/>
											</a>
										</td>
									</tr>
									<tr>
										<td>Findspots</td>
										<td>
											<a href="{concat(/content/config/url, 'findspots.geojson')}">
												<xsl:value-of select="concat(/content/config/url, 'findspots.geojson')"/>
											</a>
										</td>
										<td>
											<a href="{concat(/content/config/url, 'findspots.kml')}">
												<xsl:value-of select="concat(/content/config/url, 'findspots.kml')"/>
											</a>
										</td>
									</tr>
									<tr>
										<td>Subjects</td>
										<td>
											<a href="{concat(/content/config/url, 'subjects.geojson')}">
												<xsl:value-of select="concat(/content/config/url, 'subjects.geojson')"/>
											</a>
										</td>
										<td>
											<a href="{concat(/content/config/url, 'subjects.kml')}">
												<xsl:value-of select="concat(/content/config/url, 'subjects.kml')"/>
											</a>
										</td>
									</tr>									
								</tbody>
							</table>
							
						</div>
						<div>
							<h3>Nomisma RDF Dump</h3>
							<p>Data dumps conforming to the <a href="http://nomisma.org">Nomisma</a> ontology are linked on the index page. At present, these files are only available in RDF/XML.</p>
							<ul>
								<li>
									<a href="nomisma.void.rdf">VoID RDF</a>
								</li>
								<li>
									<a href="nomisma.rdf">Dump RDF</a>
								</li>
							</ul>
						</div>
						<div>
							<h3>Pelagios RDF Dump</h3>
							<p>Data dumps conforming to the <a href="http://pelagios-project.blogspot.com/">Pelagios 3</a> model are linked on the index page. At present, these files are only available in RDF/XML.</p>
							<ul>
								<li>
									<a href="pelagios.void.rdf">VoID RDF</a>
								</li>
								<li>
									<a href="pelagios.rdf">Dump RDF</a>
								</li>
							</ul>
						</div>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
