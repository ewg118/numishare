<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xsl nuds nh xlink" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:oa="http://www.w3.org/ns/oa#" xmlns:pelagios="http://pelagios.github.io/vocab/terms#" xmlns:void="http://rdfs.org/ns/void#" xmlns:dcmitype="http://purl.org/dc/dcmitype/"
	xmlns:relations="http://pelagios.github.io/vocab/relations#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" version="2.0">
	<xsl:include href="rdf-templates.xsl"/>

	<!-- URL parameters (only valid for GET API) -->
	<xsl:param name="model" select="doc('input:request')/request/parameters/parameter[name='model']/value"/>

	<xsl:strip-space elements="*"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="uri_space" select="/content/config/uri_space"/>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:if test="$model='pelagios' or $model='crm'">
				<xsl:variable name="type_series" as="element()*">
					<list>
						<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/substring-before(@xlink:href, 'id/'))">
							<type_series>
								<xsl:value-of select="."/>
							</type_series>
						</xsl:for-each>
					</list>
				</xsl:variable>
				<xsl:variable name="type_list" as="element()*">
					<list>
						<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/@xlink:href)">
							<type_series_item>
								<xsl:value-of select="."/>
							</type_series_item>
						</xsl:for-each>
					</list>
				</xsl:variable>

				<xsl:for-each select="$type_series//type_series">
					<xsl:variable name="type_series_uri" select="."/>

					<xsl:variable name="id-param">
						<xsl:for-each select="$type_list//type_series_item[contains(., $type_series_uri)]">
							<xsl:value-of select="substring-after(., 'id/')"/>
							<xsl:if test="not(position()=last())">
								<xsl:text>|</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>

					<xsl:if test="string-length($id-param) &gt; 0">
						<xsl:for-each select="document(concat($type_series_uri, 'apis/getNuds?identifiers=', encode-for-uri($id-param)))//nuds:nuds">
							<object xlink:href="{$type_series_uri}id/{nuds:control/nuds:recordId}">
								<xsl:copy-of select="."/>
							</object>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="descendant::nuds:typeDesc[not(string(@xlink:href))]">
					<object>
						<xsl:copy-of select="."/>
					</object>
				</xsl:for-each>
			</xsl:if>
		</nudsGroup>
	</xsl:variable>

	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
			xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nmo="http://nomisma.org/ontology#">

			<xsl:if test="$model='pelagios'">
				<xsl:variable name="id-param">
					<xsl:for-each select="distinct-values(descendant::*[not(local-name()='typeDesc') and not(local-name()='reference')][contains(@xlink:href,
						'nomisma.org')]/@xlink:href|$nudsGroup/descendant::*[not(local-name()='object') and not(local-name()='typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
						<xsl:value-of select="substring-after(., 'id/')"/>
						<xsl:if test="not(position()=last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<xsl:variable name="rdf_url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
				<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>

				<xsl:if test="descendant::nuds:findspotDesc[contains(@xlink:href, 'coinhoards.org')]">
					<xsl:copy-of select="document(concat(descendant::nuds:findspotDesc/@xlink:href, '.rdf'))/rdf:RDF/*"/>
				</xsl:if>
			</xsl:if>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<!-- determine whether the serialization is taking place in the GET API or from the id/ path -->
		<xsl:choose>
			<xsl:when test="string($model)">
				<xsl:choose>
					<xsl:when test="$model='pelagios'">
						<rdf:RDF>
							<xsl:apply-templates select="/content/*[not(local-name()='config')]" mode="pelagios"/>
						</rdf:RDF>
					</xsl:when>
					<xsl:when test="$model='crm'">
						<rdf:RDF>
							<xsl:apply-templates select="/content/*[not(local-name()='config')]" mode="crm"/>
						</rdf:RDF>
					</xsl:when>
					<xsl:when test="$model='nomisma'">
						<rdf:RDF>
							<xsl:apply-templates select="/content/*[not(local-name()='config')]" mode="nomisma"/>
						</rdf:RDF>
					</xsl:when>
					<xsl:otherwise>
						<error>RDF model not defined by URL parameter or not supported</error>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<rdf:RDF>
					<xsl:apply-templates select="/content/*[not(local-name()='config')]" mode="nomisma"/>
				</rdf:RDF>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
