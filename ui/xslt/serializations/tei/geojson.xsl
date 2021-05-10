<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: May 2021
	Function: Serialize EpiDoc TEI into a GeoJSON document -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:numishare="https://github.com/ewg118/numishare" xmlns:nm="http://nomisma.org/id/" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:org="http://www.w3.org/ns/org#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<xsl:variable name="id" select="descendant::*:recordId"/>
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
	<xsl:variable name="request-uri"
		select="
			concat('http://localhost:', if (//config/server-port castable as xs:integer) then
				//config/server-port
			else
				'8080', substring-before(doc('input:request')/request/request-uri, 'id/'))"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="geonames-url">http://api.geonames.org</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>



	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">

			<!-- aggregate distinct Nomisma URIs and perform an API lookup to get the RDF for all of them -->
			<xsl:variable name="id-param">
				<xsl:for-each
					select="
						distinct-values(descendant::*[contains(@ref,
						'nomisma.org')]/@ref | descendant::*[contains(@period,
						'nomisma.org')]/@period)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position() = last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="id-url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>

			<xsl:variable name="id-var" as="element()*">
				<xsl:if test="doc-available($id-url)">
					<xsl:copy-of select="document($id-url)/rdf:RDF"/>
				</xsl:if>
			</xsl:variable>			
			
			<!-- read distinct org:organization and org:memberOf URIs from the initial RDF API request and request these, but only if they aren't in the initial request -->
			<xsl:variable name="org-param">
				<xsl:for-each select="distinct-values($id-var//org:organization/@rdf:resource | $id-var//org:memberOf/@rdf:resource)">
					<xsl:variable name="href" select="."/>
					
					<xsl:if test="not($id-var/*[@rdf:about = $href])">
						<xsl:value-of select="substring-after($href, 'id/')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="org-url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($org-param))"/>
			
			<xsl:variable name="org-var" as="element()*">
				<xsl:if test="doc-available($org-url)">
					<xsl:copy-of select="document($org-url)/rdf:RDF"/>
				</xsl:if>
			</xsl:variable>

			<!-- read distinct skos:broaders for mints in the RDF -->
			<xsl:variable name="region-param">
				<xsl:for-each select="distinct-values($id-var//nmo:Mint/skos:broader[not(@rdf:resource = $id-var//*/@rdf:about)]/@rdf:resource)">
					<xsl:variable name="href" select="."/>

					<xsl:if test="not($id-var/*[@rdf:about = $href])">
						<xsl:value-of select="substring-after($href, 'id/')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="region-url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($region-param))"/>

			<xsl:variable name="region-var" as="element()*">
				<xsl:if test="doc-available($region-url)">
					<xsl:copy-of select="document($region-url)/rdf:RDF"/>
				</xsl:if>
			</xsl:variable>

			<!-- copy the contents of the API request variables into this variable -->
			<xsl:copy-of select="$id-var/*"/>
			<xsl:copy-of select="$org-var/*"/>
			<xsl:copy-of select="$region-var/*"/>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/tei:TEI"/>
	</xsl:template>

	<!-- TODO: get the region RDF from the mint -->

	<xsl:template match="tei:TEI">
		<xsl:variable name="model" as="element()*">
			<_object>
				<type>FeatureCollection</type>
				<features>
					<_array>
						<xsl:apply-templates select="descendant::tei:placeName[matches(@ref, '^https?://')]"/>


					</_array>
				</features>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="tei:placeName">
		<xsl:variable name="uri" select="@ref"/>

		<xsl:call-template name="generateFeature">
			<xsl:with-param name="uri" select="@ref"/>
			<xsl:with-param name="type">
				<xsl:choose>
					<xsl:when test="parent::tei:origPlace">productionPlace</xsl:when>
					<xsl:when test="parent::tei:provenance">findspot</xsl:when>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="label">
				<xsl:choose>
					<xsl:when test="matches(@ref, '^http:/nomisma\.org')">
						<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $uri], $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>

		</xsl:call-template>
	</xsl:template>



	<xsl:template name="generateFeature">
		<xsl:param name="uri"/>
		<xsl:param name="type"/>
		<xsl:param name="label"/>

		<xsl:variable name="coordinates" as="element()*">
			<node>
				<xsl:choose>
					<!-- evaluate the URI and extract coordinates -->
					<xsl:when test="string($uri)">
						<xsl:choose>
							<xsl:when test="$rdf//*[@rdf:about = $uri]">
								<xsl:choose>
									<!-- when there is a geo:SpatialThing associated with the mint that contains a lat and long: -->
									<xsl:when
										test="$rdf//*[@rdf:about = concat($uri, '#this')]/geo:long and $rdf//*[@rdf:about = concat($uri, '#this')]/geo:lat">
										<geometry>
											<_object>
												<type>Point</type>
												<coordinates>
													<_array>
														<_>
															<xsl:value-of select="$rdf//*[@rdf:about = concat($uri, '#this')]/geo:long"/>
														</_>
														<_>
															<xsl:value-of select="$rdf//*[@rdf:about = concat($uri, '#this')]/geo:lat"/>
														</_>
													</_array>
												</coordinates>
											</_object>
										</geometry>

									</xsl:when>
									<xsl:when test="$rdf//*[@rdf:about = concat($uri, '#this')]/osgeo:asGeoJSON">
										<geometry datatype="osgeo:asGeoJSON">
											<xsl:value-of select="$rdf//*[@rdf:about = concat($uri, '#this')]/osgeo:asGeoJSON"/>
										</geometry>
									</xsl:when>

									<!-- if the mint does not have coordinates, but does have skos:broader, exectue the region hierarchy API call to look for parent mint/region coordinates -->
									<xsl:when test="$rdf//*[@rdf:about = $uri]/skos:broader">
										<xsl:variable name="regions" as="node()*">
											<xsl:copy-of
												select="document(concat('http://nomisma.org/apis/regionHierarchy?identifiers=', encode-for-uri(substring-after($uri, 'http://nomisma.org/id/'))))"
											/>
										</xsl:variable>

										<xsl:if test="$regions//mint[1][@lat and @long]">
											<geometry>
												<_object>
													<type>Point</type>
													<coordinates>
														<_array>
															<_>
																<xsl:value-of select="$regions//mint[1]/@long"/>
															</_>
															<_>
																<xsl:value-of select="$regions//mint[1]/@lat"/>
															</_>
														</_array>
													</coordinates>
												</_object>
											</geometry>
										</xsl:if>
									</xsl:when>
								</xsl:choose>
							</xsl:when>

							<xsl:when test="contains($uri, 'geonames')">
								<xsl:variable name="geonames_data" as="element()*">
									<xsl:variable name="geonameId" select="tokenize($uri, '/')[4]"/>
									<xsl:copy-of
										select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))/*"
									/>
								</xsl:variable>
								<geometry>
									<_object>
										<type>Point</type>
										<coordinates>
											<_array>
												<_>
													<xsl:value-of select="$geonames_data//lng"/>
												</_>
												<_>
													<xsl:value-of select="$geonames_data//lat"/>
												</_>
											</_array>
										</coordinates>
									</_object>
								</geometry>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</node>

		</xsl:variable>

		<xsl:if test="$coordinates/geometry">
			<_object>
				<type>Feature</type>
				<label>
					<xsl:value-of select="$label"/>
				</label>

				<xsl:copy-of select="$coordinates/geometry"/>

				<properties>
					<_object>
						<toponym>
							<xsl:value-of select="$label"/>
						</toponym>
						<gazetteer_label>
							<xsl:value-of select="$label"/>
						</gazetteer_label>
						<xsl:if test="string($uri)">
							<gazetteer_uri>
								<xsl:value-of select="$uri"/>
							</gazetteer_uri>
						</xsl:if>
						<type>
							<xsl:value-of select="$type"/>
						</type>
					</_object>
				</properties>
			</_object>
		</xsl:if>
	</xsl:template>




	<!-- templates for writing the XForms 2.0 spec from the xxf processor into the Numishare XML-JSON metamodel -->
	<xsl:template match="_" mode="xxf">
		<xsl:choose>
			<xsl:when test="@type = 'array'">
				<_array>
					<xsl:apply-templates mode="xxf"/>
				</_array>
			</xsl:when>
			<xsl:otherwise>
				<_>
					<xsl:apply-templates mode="xxf"/>
				</_>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
