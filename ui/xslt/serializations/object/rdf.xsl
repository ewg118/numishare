<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds" xmlns:gml="http://www.opengis.net/gml"
	xmlns:nh="http://nomisma.org/nudsHoard" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:oa="http://www.w3.org/ns/oa#" xmlns:pelagios="http://pelagios.github.io/vocab/terms#" xmlns:void="http://rdfs.org/ns/void#"
	xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#" xmlns:dcmitype="http://purl.org/dc/dcmitype/"
	xmlns:crmsci="http://www.ics.forth.gr/isl/CRMsci/" xmlns:crmgeo="http://www.ics.forth.gr/isl/CRMgeo/"
	xmlns:crmarchaeo="http://www.cidoc-crm.org/cidoc-crm/CRMarchaeo/" xmlns:relations="http://pelagios.github.io/vocab/relations#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:edm="http://www.europeana.eu/schemas/edm/" xmlns:svcs="http://rdfs.org/sioc/services#"
	xmlns:doap="http://usefulinc.com/ns/doap#" xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="xs xsl nuds nh xlink gml numishare"
	version="2.0">
	<xsl:include href="rdf-templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- URL parameters (only valid for GET API) -->
	<xsl:param name="model" select="doc('input:request')/request/parameters/parameter[name = 'model']/value"/>

	<xsl:strip-space elements="*"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="uri_space" select="/content/config/uri_space"/>
	<xsl:variable name="collection-type" select="/content/config/collection_type"/>
	<xsl:variable name="geonames-url">http://api.geonames.org</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:if test="$model = 'pelagios'">
				<xsl:variable name="type_list" as="element()*">
					<list>
						<xsl:for-each
							select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/@xlink:href | descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem'][string(@xlink:href)]/@xlink:href)">
							<type_series_item>
								<xsl:if test="contains(., '/id/')">
									<xsl:attribute name="type_series" select="substring-before(., 'id/')"/>
								</xsl:if>

								<xsl:value-of select="."/>
							</type_series_item>
						</xsl:for-each>
					</list>
				</xsl:variable>

				<xsl:for-each select="distinct-values($type_list//type_series_item/@type_series)">
					<xsl:variable name="type_series_uri" select="."/>

					<xsl:variable name="id-param">
						<xsl:for-each select="$type_list//type_series_item[contains(., $type_series_uri)]">
							<xsl:value-of select="substring-after(., 'id/')"/>
							<xsl:if test="not(position() = last())">
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

				<!-- include individual REST calls for URIs not in a recognized, Numishare based id/ namespace -->
				<xsl:for-each select="$type_list//type_series_item[not(@type_series)]">
					<xsl:variable name="uri" select="."/>

					<xsl:call-template name="numishare:getNudsDocument">
						<xsl:with-param name="uri" select="$uri"/>
					</xsl:call-template>
				</xsl:for-each>

				<!-- get typeDesc -->
				<xsl:for-each select="descendant::nuds:typeDesc[not(string(@xlink:href))]">
					<object>
						<xsl:copy-of select="."/>
					</object>
				</xsl:for-each>
			</xsl:if>
		</nudsGroup>
	</xsl:variable>

	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nmo="http://nomisma.org/ontology#" xmlns:edm="http://www.europeana.eu/schemas/edm/" xmlns:svcs="http://rdfs.org/sioc/services#"
			xmlns:doap="http://usefulinc.com/ns/doap#" xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#"
			xmlns:crmsci="http://www.ics.forth.gr/isl/CRMsci/" xmlns:crmgeo="http://www.ics.forth.gr/isl/CRMgeo/"
			xmlns:crmarchaeo="http://www.cidoc-crm.org/cidoc-crm/CRMarchaeo/">

			<xsl:if test="$model = 'pelagios'">
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
					<xsl:when test="$model = 'pelagios'">
						<rdf:RDF>
							<foaf:Organization rdf:about="{$url}pelagios.rdf#agents/me">
								<foaf:name>
									<xsl:value-of select="//config/template/agencyName"/>
								</foaf:name>
							</foaf:Organization>
							<xsl:apply-templates select="/content/*[not(local-name() = 'config')]" mode="pelagios"/>
						</rdf:RDF>
					</xsl:when>
					<xsl:when test="$model = 'nomisma'">
						<rdf:RDF>
							<xsl:apply-templates select="/content/*[not(local-name() = 'config')]" mode="nomisma"/>
						</rdf:RDF>
					</xsl:when>
					<xsl:otherwise>
						<error>RDF model not defined by URL parameter or not supported</error>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<rdf:RDF>
					<xsl:apply-templates select="/content/*[not(local-name() = 'config')]" mode="nomisma"/>
					
					<xsl:if test="/content/config/collection_type = 'hoard'">
						<xsl:apply-templates select="descendant::nh:geogname[@xlink:role = 'findspot'][@xlink:href][not(@xlink:href = preceding::nh:geogname/@xlink:href)]" mode="place"/>
					</xsl:if>
				</rdf:RDF>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- any symbol or monogram URI requested in the getRDF API will be copied into the root rdf:RDF element -->
	<xsl:template match="rdf:RDF" mode="nomisma">
		<xsl:copy-of select="child::*"/>
	</xsl:template>
</xsl:stylesheet>
