<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:saxon="http://saxon.sf.net/" xmlns:nuds="http://nomisma.org/nuds" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
	xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#" xmlns:numishare="https://github.com/ewg118/numishare"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<xsl:output name="default" indent="no" omit-xml-declaration="yes"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="id" select="normalize-space(//*[local-name() = 'recordId'])"/>
	<xsl:variable name="objectUri"
		select="
			if (/content/config/uri_space) then
				concat(/content/config/uri_space, $id)
			else
				concat($url, 'id/', $id)"/>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:choose>
				<xsl:when test="descendant::nuds:typeDesc[string(@xlink:href)]">
					<xsl:variable name="uri" select="descendant::nuds:typeDesc/@xlink:href"/>

					<object xlink:href="{$uri}">
						<xsl:if test="doc-available(concat($uri, '.xml'))">
							<xsl:copy-of select="document(concat($uri, '.xml'))/nuds:nuds"/>
						</xsl:if>
					</object>
				</xsl:when>
				<xsl:otherwise>
					<object>
						<xsl:copy-of select="descendant::nuds:typeDesc"/>
					</object>
				</xsl:otherwise>
			</xsl:choose>
		</nudsGroup>
	</xsl:variable>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">
			<xsl:variable name="id-param">
				<xsl:for-each
					select="
						distinct-values(descendant::*[not(local-name() = 'typeDesc') and not(local-name() = 'reference')][contains(@xlink:href,
						'nomisma.org')]/@xlink:href | $nudsGroup/descendant::*[not(local-name() = 'object') and not(local-name() = 'typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position() = last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="rdf_url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
			<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>
		</rdf:RDF>
	</xsl:variable>

	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<namespace prefix="aat" uri="http://vocab.getty.edu/aat/"/>
			<namespace prefix="nm" uri="http://nomisma.org/id/"/>
		</namespaces>
	</xsl:variable>


	<xsl:template match="/">
		<xsl:variable name="model" as="element()*">


			<_object>
				<xsl:apply-templates select="//nuds:nuds"/>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<__context>https://linked.art/ns/v1/linked-art.json</__context>
		<id>
			<xsl:value-of select="$objectUri"/>
		</id>
		<type>ManMadeObject</type>
		<label>
			<xsl:value-of select="//nuds:descMeta/nuds:title[@xml:lang = 'en']"/>
		</label>
		<xsl:apply-templates select="$nudsGroup//nuds:typeDesc"/>
		<xsl:apply-templates select="nuds:descMeta/nuds:physDesc"/>
	</xsl:template>

	<xsl:template match="nuds:typeDesc">
		<classified_as>
			<_array>
				<_>aat:300133025</_>
				<xsl:apply-templates select="nuds:objectType[@xlink:href]"/>
			</_array>
		</classified_as>
		<xsl:if test="nuds:material[@xlink:href]">
			<made_of>
				<_array>
					<xsl:apply-templates select="nuds:material[@xlink:href]"/>
				</_array>
			</made_of>
		</xsl:if>

	</xsl:template>

	<xsl:template match="nuds:objectType">
		<_>
			<xsl:call-template name="numishare:resolveUriToCurie">
				<xsl:with-param name="uri" select="@xlink:href"/>
			</xsl:call-template>
		</_>
	</xsl:template>

	<xsl:template match="nuds:material">

		<_object>
			<id>
				<xsl:call-template name="numishare:resolveUriToCurie">
					<xsl:with-param name="uri" select="@xlink:href"/>
				</xsl:call-template>
			</id>
			<type>Material</type>
			<label>
				<xsl:value-of select="."/>
			</label>
		</_object>
	</xsl:template>

	<xsl:template match="nuds:obverse | nuds:reverse"> </xsl:template>

	<xsl:template match="nuds:physDesc">
		<xsl:apply-templates select="nuds:measurementsSet"/>
	</xsl:template>

	<xsl:template match="nuds:measurementsSet">
		<dimension>
			<_array>
				<xsl:apply-templates select="../nuds:axis"/>
				<xsl:apply-templates select="nuds:diameter | nuds:weight"/>
			</_array>
		</dimension>
	</xsl:template>

	<xsl:template match="nuds:diameter | nuds:weight | nuds:axis | nuds:height | nuds:width | nuds:thickness | nuds:axis">
		<_object>
			<type>Dimension</type>
			<value>
				<xsl:value-of select="."/>
			</value>
			<classified_as>
				<_array>
					<_>
						<xsl:choose>
							<xsl:when test="self::nuds:axis">aat:300055624</xsl:when>
							<xsl:when test="self::nuds:diameter">aat:300055624</xsl:when>
							<xsl:when test="self::nuds:height">aat:300055644</xsl:when>
							<xsl:when test="self::nuds:weight">aat:300056240</xsl:when>
						</xsl:choose>
					</_>
				</_array>
			</classified_as>
			<xsl:choose>
				<xsl:when test="self::nuds:diameter or self::nuds:height or self::nuds:width or self::nuds:thickness">
					<unit>aat:300379097</unit>
				</xsl:when>

				<xsl:when test="self::nuds:weight">
					<unit>aat:300379225</unit>
				</xsl:when>
			</xsl:choose>
		</_object>
	</xsl:template>

	<xsl:template name="numishare:resolveUriToCurie">
		<xsl:param name="uri"/>

		<xsl:choose>
			<xsl:when test="$rdf//*[@rdf:about = $uri]/skos:exactMatch[contains(@rdf:resource, 'http://vocab.getty.edu/aat')]">
				<xsl:variable name="gettyURI"
					select="$rdf//*[@rdf:about = $uri]/skos:exactMatch[contains(@rdf:resource, 'http://vocab.getty.edu/aat')]/@rdf:resource"/>

				<xsl:value-of
					select="replace($gettyURI, $namespaces//namespace[contains($gettyURI, @uri)]/@uri, concat($namespaces//namespace[contains($gettyURI, @uri)]/@prefix, ':'))"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of
					select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"
				/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
