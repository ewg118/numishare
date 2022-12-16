<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xxf="http://www.orbeon.com/oxf/pipeline"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:gml="http://www.opengis.net/gml" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:nm="http://nomisma.org/id/" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/"
	xmlns:crmgeo="http://www.ics.forth.gr/isl/CRMgeo/" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:digest="org.apache.commons.codec.digest.DigestUtils" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../sparql/geojson-templates.xsl"/>
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

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
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
		</nudsGroup>
	</xsl:variable>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
			xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#" xmlns:nomisma="http://nomisma.org/"
			xmlns:nmo="http://nomisma.org/ontology#">

			<!-- aggregate distinct Nomisma URIs and perform an API lookup to get the RDF for all of them -->
			<xsl:variable name="id-param">
				<xsl:for-each
					select="
						distinct-values(descendant::*[not(local-name() = 'typeDesc') and not(local-name() = 'reference')][contains(@xlink:href,
						'nomisma.org')]/@xlink:href | $nudsGroup/descendant::*[not(local-name() = 'object') and not(local-name() = 'typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href | descendant::*[contains(@certainty, 'nomisma.org')]/@certainty | $nudsGroup/descendant::*[contains(@certainty, 'nomisma.org')]/@certainty)">
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
			<xsl:copy-of select="$region-var/*"/>

			<xsl:if test="descendant::nuds:findspotDesc[contains(@xlink:href, 'coinhoards.org')]">
				<xsl:copy-of select="document(concat(descendant::nuds:findspotDesc/@xlink:href, '.rdf'))/rdf:RDF/*"/>
			</xsl:if>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/nuds:nuds"/>
	</xsl:template>

	<!-- TODO: get the region RDF from the mint -->

	<xsl:template match="nuds:nuds">
		<xsl:variable name="model" as="element()*">
			<_object>
				<type>FeatureCollection</type>
				<features>
					<_array>
						<xsl:apply-templates
							select="descendant::nuds:geogname[@xlink:role = 'findspot'][string(@xlink:href)] | descendant::nuds:findspotDesc[contains(@xlink:href, 'coinhoards.org') or contains(@xlink:href, 'nomisma.org')] | $nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][string(@xlink:href)]"/>

						<!-- if there's no linkable mint look for a region -->
						<xsl:if
							test="not($nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint']) or $nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][not(@xlink:href)]">
							<xsl:apply-templates select="$nudsGroup//descendant::nuds:geogname[@xlink:role = 'region'][string(@xlink:href)]"/>
						</xsl:if>

						<!-- if there's a linkable mint, look to see if it has coordinates, if not, look to see if its parent region has coordinates -->
						<xsl:for-each select="$nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][contains(@xlink:href, 'nomisma.org')]">
							<xsl:variable name="mintURI" select="@xlink:href"/>

							<xsl:if test="not($rdf//nmo:Mint[@rdf:about = $mintURI]/geo:location)">
								<xsl:variable name="uri" select="$rdf//nmo:Mint[@rdf:about = $mintURI]/skos:broader/@rdf:resource"/>

								<xsl:call-template name="generateFeature">
									<xsl:with-param name="uri" select="$uri"/>
									<xsl:with-param name="type">mint</xsl:with-param>
									<xsl:with-param name="label" select="numishare:getNomismaLabel($rdf/*[@rdf:about = $uri], $lang)"/>
								</xsl:call-template>
							</xsl:if>
						</xsl:for-each>
						
						<!-- if there is a manually entered findspot point -->
						<xsl:if test="descendant::nuds:findspot[gml:location]">
							<xsl:apply-templates select="descendant::nuds:findspot[gml:location]"/>
						</xsl:if>

						<!-- gather associated hoards from Nomisma, but only for coin types and an active SPARQL endpoint  -->
						<xsl:if test="/content/config/collection_type = 'cointype' and matches($sparql_endpoint, 'https?://')">
							<xsl:apply-templates select="doc('input:hoards')//res:result"/>
							<xsl:apply-templates select="doc('input:findspots')//res:result"/>
						</xsl:if>
					</_array>
				</features>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="nuds:geogname">
		<xsl:variable name="uri" select="@xlink:href"/>

		<xsl:call-template name="generateFeature">
			<xsl:with-param name="uri" select="@xlink:href"/>
			<xsl:with-param name="type">
				<xsl:choose>
					<xsl:when test="@xlink:role = 'mint' or @xlink:role = 'region'">mint</xsl:when>
					<xsl:when test="@xlink:role = 'findspot'">findspot</xsl:when>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="label">
				<xsl:choose>
					<xsl:when test="@xlink:role = 'mint' or @xlink:role = 'region'">
						<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $uri], $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>

		</xsl:call-template>
	</xsl:template>

	<xsl:template match="nuds:findspotDesc">
		<xsl:variable name="uri" select="@xlink:href"/>

		<xsl:call-template name="generateFeature">
			<xsl:with-param name="uri" select="$uri"/>
			<xsl:with-param name="type">hoard</xsl:with-param>
			<xsl:with-param name="label" select="numishare:getNomismaLabel($rdf/*[@rdf:about = $uri], $lang)"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="nuds:findspot">
		<xsl:call-template name="generateFeature">
			<xsl:with-param name="uri"/>
			<xsl:with-param name="type">findspot</xsl:with-param>
			<xsl:with-param name="label" select="nuds:geogname[@xlink:role = 'findspot']"/>
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
									<!-- Hoard RDF in the variable has an nmo:hasFindspot, regardless of IGCH/CHRR or few Nomisma hoard origin -->
									<xsl:when test="$rdf//*[@rdf:about = $uri]/nmo:hasFindspot">

										<!-- @rdf:resource comes within P89 if it's certain -->
										<xsl:variable name="gazetteerURI"
											select="$rdf//*[@rdf:about = $uri]/nmo:hasFindspot/descendant::crm:P89_falls_within[contains(@rdf:resource, 'geonames.org')]/@rdf:resource"/>

										<xsl:if test="string($gazetteerURI)">
											<xsl:variable name="spatialThingURI"
												select="$rdf//*[@rdf:about = $gazetteerURI]/crm:P168_place_is_defined_by/@rdf:resource"/>

											<xsl:if test="$spatialThingURI">
												<geometry>
													<_object>

														<xsl:choose>
															<!-- if there are a lat and long, then output an array of points -->
															<xsl:when test="$rdf//*[@rdf:about = $spatialThingURI][geo:lat and geo:long]">
																<type>Point</type>
																<coordinates>
																	<_array>
																		<_>
																			<xsl:value-of select="$rdf//*[@rdf:about = $spatialThingURI]/geo:long"/>
																		</_>
																		<_>
																			<xsl:value-of select="$rdf//*[@rdf:about = $spatialThingURI]/geo:lat"/>
																		</_>
																	</_array>
																</coordinates>

															</xsl:when>
															<xsl:when test="$rdf//*[@rdf:about = $spatialThingURI][crmgeo:asWKT[contains(., 'POLYGON')]]">
																<xsl:variable name="corners"
																	select="tokenize(substring-after(substring-before($rdf//*[@rdf:about = $spatialThingURI]/crmgeo:asWKT, ')'), '('), ',')"/>
																<type>Polygon</type>
																<coordinates>
																	<_array>
																		<_array>
																			<xsl:for-each select="$corners">
																				<xsl:variable name="points" select="tokenize(normalize-space(.), ' ')"/>

																				<_array>
																				<xsl:for-each select="$points">
																				<_>
																				<xsl:value-of select="normalize-space(.)"/>
																				</_>
																				</xsl:for-each>
																				</_array>

																			</xsl:for-each>
																		</_array>
																	</_array>
																</coordinates>
															</xsl:when>
														</xsl:choose>
													</_object>
												</geometry>
											</xsl:if>
										</xsl:if>
									</xsl:when>
									<!-- if the URI contains a skos:related linking to an uncertain mint attribution -->
									<xsl:when test="$rdf//*[@rdf:about = $uri]/skos:related">
										<xsl:variable name="uncertainMint" as="node()*">
											<xsl:copy-of
												select="document(concat($rdf//*[@rdf:about = $uri]/skos:related/rdf:Description/rdf:value/@rdf:resource, '.rdf'))"
											/>
										</xsl:variable>

										<xsl:if test="$uncertainMint//geo:long and $uncertainMint//geo:lat">
											<geometry>
												<_object>
													<type>Point</type>
													<coordinates>
														<_array>
															<_>
																<xsl:value-of select="$uncertainMint//geo:long"/>
															</_>
															<_>
																<xsl:value-of select="$uncertainMint//geo:lat"/>
															</_>
														</_array>
													</coordinates>
												</_object>
											</geometry>
										</xsl:if>
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
							<xsl:when test="descendant::gml:Point">
								<xsl:variable name="coords" select="tokenize(descendant::gml:Point/gml:pos, ' ')"/>
								<geometry>
									<_object>
										<type>Point</type>
										<coordinates>
											<_array>
												<_>
													<xsl:value-of select="normalize-space($coords[2])"/>
												</_>
												<_>
													<xsl:value-of select="normalize-space($coords[1])"/>
												</_>
											</_array>
										</coordinates>
									</_object>
								</geometry>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<!-- otherwise use the gml:Point stored within NUDS -->
					<xsl:when test="descendant::gml:Point">
						<xsl:variable name="coords" select="tokenize(descendant::gml:Point/gml:pos, ' ')"/>
						<geometry>
							<_object>
								<type>Point</type>
								<coordinates>
									<_array>
										<_>
											<xsl:value-of select="normalize-space($coords[2])"/>
										</_>
										<_>
											<xsl:value-of select="normalize-space($coords[1])"/>
										</_>
									</_array>
								</coordinates>
							</_object>
						</geometry>
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
