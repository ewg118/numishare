<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date Modified: August 2020
	Function: Construct HTTP headers for content negotiation
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
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
	
	<xsl:variable name="pipeline">
		<xsl:choose>
			<xsl:when test="doc('input:request')/request/request-url, '/id/'">id</xsl:when>
			<xsl:when test="doc('input:request')/request/request-url, '/results'">results</xsl:when>
			<xsl:otherwise>default</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:template match="/">
		<config>
			<status-code>200</status-code>
			<content-type>text/html</content-type>
			
			<!-- output language, if enabled. otherwise the default is 'en' -->
			<header>
				<name>Content-Language</name>
				<value>
					<xsl:value-of select="if (/config/languages/language[@code = $lang]) then $lang else 'en'"/>
				</value>
			</header>	
			
			<xsl:choose>
				
				<!-- create a Link header for all possible serializations and profiles -->
				<xsl:when test="$pipeline = 'id'">
					<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>					
					<xsl:variable name="objectURI"
						select="
						if (string(/config/uri_space)) then
						concat(/config/uri_space, $id)
						else
						concat(/config/url, 'id/', $id)"
					/>
					
					<header>
						<name>Link</name>
						<value>
							<xsl:text>&lt;</xsl:text>
							<xsl:value-of select="$objectURI"/>
							<xsl:text>&gt;; rel="canonical"; type="text/html", </xsl:text>
							<xsl:text>&lt;</xsl:text>
							<xsl:value-of select="$objectURI"/>
							<xsl:text>&gt;; rel="alternate"; type="text/turtle"; profile="http://nomisma.org/ontology#", </xsl:text>
							<xsl:text>&lt;</xsl:text>
							<xsl:value-of select="$objectURI"/>
							<xsl:text>&gt;; rel="alternate"; type="application/rdf+xml"; profile="http://nomisma.org/ontology#", </xsl:text>
							<xsl:text>&lt;</xsl:text>
							<xsl:value-of select="$objectURI"/>
							<xsl:text>&gt;; rel="alternate"; type="application/ld+json"; profile="http://nomisma.org/ontology#", </xsl:text>
							<xsl:text>&lt;</xsl:text>
							<xsl:value-of select="$objectURI"/>
							<xsl:text>&gt;; rel="alternate"; type="application/ld+json"; profile="https://linked.art/ns/v1/linked-art.json", </xsl:text>
							<xsl:text>&lt;</xsl:text>
							<xsl:value-of select="$objectURI"/>
							<xsl:text>&gt;; rel="alternate"; type="application/xml"; profile="http://nomisma.org/nuds", </xsl:text>
							<xsl:text>&lt;</xsl:text>
							<xsl:value-of select="$objectURI"/>
							<xsl:text>&gt;; rel="alternate"; type="application/vnd.google-earth.kml+xml", </xsl:text>
							<xsl:text>&lt;</xsl:text>
							<xsl:value-of select="$objectURI"/>
							<xsl:text>&gt;; rel="alternate"; type="application/vnd.geo+json"</xsl:text>
						</value>
					</header>
				</xsl:when>
			</xsl:choose>
		</config>
	</xsl:template>

</xsl:stylesheet>
