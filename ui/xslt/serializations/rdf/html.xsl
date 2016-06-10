<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:void="http://rdfs.org/ns/void#"
	xmlns:numishare="https://github.com/ewg118/numishare" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- URL params -->
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
	<xsl:variable name="request-uri" select="concat('http://localhost:8080', substring-before(doc('input:request')/request/request-uri, 'id/'))"/>
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

	<!-- paths -->
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="include_path" select="concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<!-- variables -->
	<xsl:variable name="id" select="tokenize(//@rdf:about, '/')[last()]"/>
	<xsl:variable name="objectUri" select="//@rdf:about"/>

	<!-- namespaces -->
	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<xsl:for-each select="//rdf:RDF/namespace::*[not(name()='xml')]">
				<namespace prefix="{name()}" uri="{.}"/>
			</xsl:for-each>
		</namespaces>
	</xsl:variable>
	<xsl:variable name="prefix">
		<xsl:for-each select="$namespaces/namespace">
			<xsl:value-of select="concat(@prefix, ': ', @uri)"/>
			<xsl:if test="not(position()=last())">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:call-template name="contruct_page"/>
	</xsl:template>

	<xsl:template name="contruct_page">
		<html prefix="{$prefix}" itemscope="" itemtype="Thing">
			<xsl:if test="string($lang)">
				<xsl:attribute name="lang" select="$lang"/>
			</xsl:if>
			<head>
				<xsl:call-template name="generic_head"/>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="body"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="generic_head">
		<title id="{$id}">
			<xsl:value-of select="//config/title"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="descendant::skos:prefLabel[@xml:lang='en']"/>
		</title>
		<!-- alternates -->
		<link rel="alternate" type="application/rdf+xml" href="{$objectUri}.rdf"/>
		<link rel="alternate" type="application/ld+json" href="{$objectUri}.jsonld"/>
		<link rel="alternate" type="text/turtle" href="{$objectUri}.ttl"/>

		<!-- open graph metadata -->
		<meta property="og:url" content="{$objectUri}"/>
		<meta property="og:type" content="article"/>
		<meta property="og:title">
			<xsl:attribute name="content">
				<xsl:choose>
					<xsl:when test="descendant::*:descMeta/*:title[@xml:lang=$lang]">
						<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang=$lang]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang='en']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</meta>

		<!-- CSS -->
		<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
		<meta name="viewport" content="width=device-width, initial-scale=1"/>
		<!-- bootstrap -->
		<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
		<script type="text/javascript" src="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
		<xsl:if test="string(//config/google_analytics)">
			<script type="text/javascript">
				<xsl:value-of select="//config/google_analytics"/>
			</script>
		</xsl:if>
	</xsl:template>

	<xsl:template name="body">
		<div class="container-fluid content">
			<div class="row">
				<xsl:if test="descendant::foaf:depiction[@rdf:resource]">
					<div class="col-md-2">
						<xsl:for-each select="descendant::foaf:depiction">
							<img src="{@rdf:resource}" alt="symbol" style="max-width:100%"/>
							<xsl:if test="not(position()=last())">
								<br/>
							</xsl:if>
						</xsl:for-each>
						
					</div>
				</xsl:if>
				<div class="col-md-{if (descendant::foaf:depiction[@rdf:resource]) then '8' else '10'}">
					<xsl:apply-templates select="/content/rdf:RDF/*" mode="type"/>
				</div>
				<div class="col-md-2">
					<h3>Export</h3>
					<ul class="list-inline">
						<li>
							<strong>Linked Data</strong>
						</li>
						<li>
							<a href="{$id}.rdf">RDF/XML</a>
						</li>
						<li>
							<a href="{$id}.ttl">RDF/TTL</a>
						</li>
						<li>
							<a href="{$id}.jsonld">JSON-LD</a>
						</li>

					</ul>
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- templates for RDF/XML -> HTML taken from Nomisma -->
	<xsl:template match="*" mode="type">
		<div typeof="{name()}" about="{@rdf:about}">
			<xsl:if test="contains(@rdf:about, '#')">
				<xsl:attribute name="id" select="substring-after(@rdf:about, '#')"/>
			</xsl:if>
			<xsl:element name="{if(position()=1) then 'h2' else 'h3'}">
				<a href="{@rdf:about}">
					<xsl:choose>
						<xsl:when test="contains(@rdf:about, '#')">
							<xsl:value-of select="concat('#', substring-after(@rdf:about, '#'))"/>
						</xsl:when>
						<xsl:when test="contains(@rdf:about, 'geonames.org')">
							<xsl:value-of select="@rdf:about"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$id"/>
						</xsl:otherwise>
					</xsl:choose>
				</a>
				<small>
					<xsl:text> (</xsl:text>
					<a href="{concat(namespace-uri(.), local-name())}">
						<xsl:value-of select="name()"/>
					</a>
					<xsl:text>)</xsl:text>
				</small>
			</xsl:element>
			<dl class="dl-horizontal">
				<xsl:if test="skos:prefLabel">
					<dt>
						<a href="{concat($namespaces//namespace[@prefix='skos']/@uri, 'prefLabel')}">skos:prefLabel</a>
					</dt>
					<dd>
						<xsl:apply-templates select="skos:prefLabel" mode="prefLabel">
							<xsl:sort select="@xml:lang"/>
						</xsl:apply-templates>
					</dd>
				</xsl:if>
				<xsl:apply-templates select="skos:definition" mode="list-item">
					<xsl:sort select="@xml:lang"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="*[not(name()='skos:prefLabel') and not(name()='skos:definition')][not(child::*)]" mode="list-item">
					<xsl:sort select="name()"/>
					<xsl:sort select="@rdf:resource"/>
				</xsl:apply-templates>
			</dl>
			<xsl:apply-templates select="*[(child::*)]" mode="suburi">
				<xsl:sort select="name()"/>
				<xsl:sort select="@rdf:resource"/>
			</xsl:apply-templates>
		</div>
	</xsl:template>

	<xsl:template match="skos:prefLabel" mode="prefLabel">
		<span property="{name()}" lang="{@xml:lang}">
			<xsl:value-of select="."/>
		</span>
		<xsl:if test="string(@xml:lang)">
			<span class="lang">
				<xsl:value-of select="concat(' (', @xml:lang, ')')"/>
			</span>
		</xsl:if>
		<xsl:if test="not(position()=last())">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="list-item">
		<xsl:variable name="name" select="name()"/>
		<dt>
			<a href="{concat($namespaces//namespace[@prefix=substring-before($name, ':')]/@uri, substring-after($name, ':'))}">
				<xsl:value-of select="name()"/>
			</a>
		</dt>
		<dd>
			<xsl:choose>
				<xsl:when test="string(.)">
					<span property="{name()}">
						<xsl:if test="@xml:lang">
							<xsl:attribute name="xml:lang" select="@xml:lang"/>
						</xsl:if>
						<xsl:if test="@rdf:datatype">
							<xsl:attribute name="datatype" select="@rdf:datatype"/>
						</xsl:if>

						<xsl:choose>
							<xsl:when test="contains(@rdf:datatype, '#gYear')">
								<xsl:value-of select="numishare:normalizeDate(.)"/>
							</xsl:when>
							<xsl:when test="contains(@rdf:datatype, '#gYearMonth')">
								<xsl:value-of select="numishare:normalizeDate(.)"/>
							</xsl:when>
							<xsl:when test="contains(@rdf:datatype, '#date')">
								<xsl:value-of select="numishare:normalizeDate(.)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="."/>
							</xsl:otherwise>
						</xsl:choose>
					</span>
					<xsl:if test="string(@xml:lang)">
						<span class="lang">
							<xsl:value-of select="concat(' (', @xml:lang, ')')"/>
						</span>
					</xsl:if>
				</xsl:when>
				<xsl:when test="string(@rdf:resource)">
					<span>
						<a href="{@rdf:resource}" rel="{name()}" title="{@rdf:resource}">
							<xsl:choose>
								<xsl:when test="name()='rdf:type'">
									<xsl:variable name="uri" select="@rdf:resource"/>
									<xsl:value-of select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@rdf:resource"/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</span>
				</xsl:when>
			</xsl:choose>
		</dd>
	</xsl:template>

	<xsl:template match="*" mode="suburi">
		<xsl:variable name="about" select="if(@rdf:about) then @rdf:about else rdf:Description/@rdf:about"/>

		<div rel="{name()}">
			<xsl:if test="string($about)">
				<xsl:attribute name="resource" select="$about"/>
			</xsl:if>
			<h3>
				<xsl:value-of select="name()"/>
				<xsl:if test="string($about)">
					<small>
						<xsl:text> (</xsl:text>
						<a href="{$about}">
							<xsl:value-of select="$about"/>
						</a>
						<xsl:text>)</xsl:text>
					</small>
				</xsl:if>
			</h3>
			<dl class="dl-horizontal">
				<xsl:apply-templates select="descendant::skos:prefLabel" mode="list-item">
					<xsl:sort select="@xml:lang"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="descendant::skos:definition" mode="list-item">
					<xsl:sort select="@xml:lang"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="descendant::*[not(name()='skos:prefLabel') and not(name()='skos:definition')][not(child::*)]" mode="list-item">
					<xsl:sort select="name()"/>
					<xsl:sort select="@rdf:resource"/>
				</xsl:apply-templates>
			</dl>
		</div>
	</xsl:template>
</xsl:stylesheet>
