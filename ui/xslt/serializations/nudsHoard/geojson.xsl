<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:gml="http://www.opengis.net/gml"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nmo="http://nomisma.org/ontology#" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:digest="org.apache.commons.codec.digest.DigestUtils" exclude-result-prefixes="#all" version="2.0">
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

	<xsl:variable name="contentsDesc" as="element()*">
		<xsl:copy-of select="descendant::nh:contents"/>
	</xsl:variable>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:variable name="type_list" as="element()*">
				<list>
					<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/@xlink:href)">
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

	<!-- generate a list of distinct mint concepts from within the $nudsGroup, parsing labels and coordinates from the Nomisma RDF -->
	<xsl:variable name="mints" as="element()*">
		<mints>
			<xsl:for-each
				select="distinct-values($nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][starts-with(@xlink:href, 'http://nomisma.org/id/')]/@xlink:href)">
				<xsl:variable name="uri" select="."/>

				<xsl:variable name="coordinates">
					<xsl:choose>
						<!-- when there is a geo:SpatialThing associated with the mint that contains a lat and long: -->
						<xsl:when test="$rdf//*[@rdf:about = concat($uri, '#this')]/geo:long and $rdf//*[@rdf:about = concat($uri, '#this')]/geo:lat">
							<xsl:value-of
								select="concat($rdf//*[@rdf:about = concat($uri, '#this')]/geo:long, ',', $rdf//*[@rdf:about = concat($uri, '#this')]/geo:lat)"
							/>
						</xsl:when>
						<!-- if the URI contains a skos:related linking to an uncertain mint attribution -->
						<xsl:when test="$rdf//*[@rdf:about = $uri]/skos:related">
							<xsl:variable name="uncertainMint" as="node()*">
								<xsl:copy-of select="document(concat($rdf//*[@rdf:about = $uri]/skos:related/rdf:Description/rdf:value/@rdf:resource, '.rdf'))"
								/>
							</xsl:variable>

							<xsl:if test="$uncertainMint//geo:long and $uncertainMint//geo:lat">
								<xsl:value-of select="concat($uncertainMint//geo:long, ',', $uncertainMint//geo:lat)"/>
							</xsl:if>
						</xsl:when>
						<!-- if the mint does not have coordinates, but does have skos:broader, execute the region hierarchy API call to look for parent mint/region coordinates -->
						<!--<xsl:when test="$rdf//*[@rdf:about = $uri]/skos:broader">
								<xsl:variable name="regions" as="node()*">
									<xsl:copy-of
										select="document(concat('http://nomisma.org/apis/regionHierarchy?identifiers=', encode-for-uri(substring-after($uri, 'http://nomisma.org/id/'))))"
									/>
								</xsl:variable>
								
								<xsl:if test="$regions//mint[1][@lat and @long]">
									<xsl:value-of select="concat($regions//mint[1]/@long, ',', $regions//mint[1]/@lat)"/>
								</xsl:if>
							</xsl:when>-->
					</xsl:choose>
				</xsl:variable>

				<xsl:if test="$rdf//*[@rdf:about = $uri]/name() = 'nmo:Mint' and string($coordinates)">
					<mint>
						<xsl:attribute name="uri" select="$uri"/>
						<xsl:attribute name="coordinates" select="$coordinates"/>


						<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $uri], $lang)"/>
					</mint>
				</xsl:if>

			</xsl:for-each>
		</mints>
	</xsl:variable>

	<!-- get the total number of coins that can be geographically mapped. the numeric visualization is based only on mappable coin groups, not the total -->
	<xsl:variable name="total-counts">
		<total>
			<xsl:for-each select="/content/nh:nudsHoard//nh:coin | /content/nh:nudsHoard//nh:coinGrp">

				<xsl:variable name="mints" as="element()*">
					<mints>
						<xsl:choose>
							<xsl:when test="nuds:typeDesc/@xlink:href">
								<xsl:variable name="href" select="nuds:typeDesc/@xlink:href"/>

								<xsl:for-each
									select="$nudsGroup//object[@xlink:href = $href]/descendant::nuds:geogname[@xlink:role = 'mint'][starts-with(@xlink:href, 'http://nomisma.org/id/')]">
									<mint>
										<xsl:value-of select="@xlink:href"/>
									</mint>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="descendant::nuds:geogname[@xlink:role = 'mint'][starts-with(@xlink:href, 'http://nomisma.org/id/')]">
									<mint>
										<xsl:value-of select="@xlink:href"/>
									</mint>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</mints>
				</xsl:variable>

				<xsl:variable name="count" as="xs:integer">
					<xsl:choose>
						<xsl:when test="self::nh:coin">1</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="number(@minCount) and number(@maxCount)">
									<xsl:value-of select="round((@minCount + @maxCount) div 2)"/>
								</xsl:when>
								<xsl:when test="number(@minCount)">
									<xsl:value-of select="@minCount"/>
								</xsl:when>
								<xsl:when test="number(@maxCount)">
									<xsl:value-of select="@maxCount"/>
								</xsl:when>
								<xsl:when test="number(@count)">
									<xsl:value-of select="@count"/>
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<!-- only include a countable item when there is a mint -->
				<xsl:if test="count($mints//mint) &gt; 0">
					<item count="{$count}">
						<xsl:copy-of select="$mints"/>
					</item>
				</xsl:if>
			</xsl:for-each>
		</total>

	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/nh:nudsHoard"/>
	</xsl:template>

	<!-- NUDS Hoard templates -->

	<xsl:template match="nh:nudsHoard">
		<xsl:variable name="model" as="element()*">
			<_object>
				<type>FeatureCollection</type>
				<features>
					<_array>
						<xsl:apply-templates select="nh:descMeta/nh:hoardDesc/nh:findspot"/>
						<xsl:apply-templates select="$mints//mint"/>
					</_array>
				</features>
			</_object>			
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
		<!--<xsl:copy-of select="$model"/>-->
	</xsl:template>

	<!-- evaluate the various permutations of coordinates that might occur within the nh:findspot -->
	<xsl:template match="nh:findspot">
		<xsl:choose>
			<xsl:when test="gml:location">
				<xsl:apply-templates select="gml:location">
					<xsl:with-param name="name" select="nh:geogname[@xlink:role = 'findspot']"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="nh:fallsWithin">
				<xsl:apply-templates select="nh:fallsWithin"/>
			</xsl:when>
			<xsl:when test="nh:geogname[@xlink:role = 'findspot'][contains(@xlink:href, 'geonames.org')]">
				<xsl:apply-templates select="nh:geogname[@xlink:role = 'findspot'][contains(@xlink:href, 'geonames.org')]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nh:fallsWithin">
		<xsl:choose>
			<xsl:when test="gml:location">
				<xsl:apply-templates select="gml:location">
					<xsl:with-param name="name" select="nh:geogname[@xlink:role = 'findspot']"/>
					<xsl:with-param name="uri" select="nh:geogname[@xlink:role = 'findspot']/@xlink:href"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="nh:geogname[@xlink:role = 'findspot'][contains(@xlink:href, 'geonames.org')]">
				<xsl:apply-templates select="nh:geogname[@xlink:role = 'findspot'][contains(@xlink:href, 'geonames.org')]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- execute API call for geonames URIs when there's no embedded gml:location -->
	<xsl:template match="nh:geogname[@xlink:role = 'findspot']">
		<xsl:variable name="geonames_data" as="element()*">
			<xsl:variable name="geonameId" select="tokenize(@xlink:href, '/')[4]"/>
			<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))/*"/>
		</xsl:variable>

		<xsl:call-template name="generateFeature">
			<xsl:with-param name="uri" select="@xlink:href"/>
			<xsl:with-param name="featureType">Point</xsl:with-param>
			<xsl:with-param name="coordinates" select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>
			<xsl:with-param name="type">findspot</xsl:with-param>
			<xsl:with-param name="name" select="."/>
		</xsl:call-template>
	</xsl:template>

	<!-- GML template: evaluation the type of feature -->
	<xsl:template match="gml:location">
		<xsl:param name="name"/>
		<xsl:param name="uri"/>

		<xsl:call-template name="generateFeature">
			<xsl:with-param name="uri" select="$uri"/>
			<xsl:with-param name="featureType" select="
					if (gml:Polygon) then
						'Polygon'
					else
						'Point'"/>
			<xsl:with-param name="coordinates" select="
					if (gml:Polygon) then
						gml:Polygon/gml:coordinates
					else
						gml:Point/gml:coordinates"/>
			<xsl:with-param name="type">findspot</xsl:with-param>
			<xsl:with-param name="name" select="$name"/>
		</xsl:call-template>
	</xsl:template>



	<!-- transform distinct concepts for each mint into a Point with a average count -->
	<xsl:template match="mint">
		<xsl:variable name="uri" select="@uri"/>

		<xsl:call-template name="generateFeature">
			<xsl:with-param name="uri" select="@uri"/>
			<xsl:with-param name="featureType" select="
					if (contains(@coordinates, ' ')) then
						'Polygon'
					else
						'Point'"/>
			<xsl:with-param name="coordinates" select="@coordinates"/>
			<xsl:with-param name="type">mint</xsl:with-param>
			<xsl:with-param name="name" select="."/>
			<xsl:with-param name="count" select="sum($total-counts//item[mints/mint = $uri]/@count)"/>
		</xsl:call-template>
	</xsl:template>

	<!-- generate the GeoJSON feature depending on variables passed for mints and findspots -->
	<xsl:template name="generateFeature">
		<xsl:param name="uri"/>
		<xsl:param name="featureType"/>
		<xsl:param name="coordinates"/>
		<xsl:param name="type"/>
		<xsl:param name="count"/>
		<xsl:param name="name"/>

		<_object>
			<type>Feature</type>
			<geometry>
				<_object>
					<type>
						<xsl:value-of select="$featureType"/>
					</type>
					<coordinates>
						<_array>
							<!--<_><xsl:value-of select="$coordinates"/></_>-->
							<xsl:choose>
								<xsl:when test="$featureType = 'Point'">
									<xsl:for-each select="tokenize($coordinates, ',')">
										<_>
											<xsl:value-of select="normalize-space(.)"/>
										</_>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="$featureType = 'Polygon'">
									<xsl:variable name="points" select="tokenize($coordinates, ' ')"/>

									<_array>
										<!-- take a GML Polygon represented as a diagonal set of points and convert to a 4-point GeoJSON Polygon -->
										<xsl:choose>
											<xsl:when test="count($points) = 2">
												<xsl:variable name="x1" select="tokenize(normalize-space($points[1]), ',')[1]"/>
												<xsl:variable name="x2" select="tokenize(normalize-space($points[2]), ',')[1]"/>
												<xsl:variable name="y1" select="tokenize(normalize-space($points[1]), ',')[2]"/>
												<xsl:variable name="y2" select="tokenize(normalize-space($points[2]), ',')[2]"/>


												<xsl:variable name="polygon" as="element()*">
													<polygon>
														<sw>
															<x>
																<xsl:value-of
																	select="
																		if ($x1 &lt; $x2) then
																			$x1
																		else
																			$x2"
																/>
															</x>
															<y>
																<xsl:value-of
																	select="
																	if ($y1 &lt; $y2) then
																	$y1
																	else
																	$y2"
																/>
															</y>
														</sw>
														<nw>
															<x>
																<xsl:value-of
																	select="
																		if ($x1 &lt; $x2) then
																			$x1
																		else
																			$x2"
																/>
															</x>
															<y>
																<xsl:value-of
																	select="
																		if ($y1 &gt; $y2) then
																			$y1
																		else
																			$y2"
																/>
															</y>
														</nw>
														<ne>
															<x>
																<xsl:value-of
																	select="
																		if ($x1 &gt; $x2) then
																			$x1
																		else
																			$x2"
																/>
															</x>
															<y>
																<xsl:value-of
																	select="
																		if ($y1 &gt; $y2) then
																			$y1
																		else
																			$y2"
																/>
															</y>
														</ne>
														<se>
															<x>
																<xsl:value-of
																	select="
																		if ($x1 &gt; $x2) then
																			$x1
																		else
																			$x2"
																/>
															</x>
															<y>
																<xsl:value-of
																	select="
																		if ($y1 &lt; $y2) then
																			$y1
																		else
																			$y2"
																/>
															</y>
														</se>
													</polygon>
												</xsl:variable>

												<xsl:for-each select="$polygon/*">													
													<_array>
														<_>
															<xsl:value-of select="x"/>
														</_>
														<_>
															<xsl:value-of select="y"/>
														</_>
													</_array>
												</xsl:for-each>
											</xsl:when>
										</xsl:choose>
									</_array>
								</xsl:when>
							</xsl:choose>

						</_array>
					</coordinates>
				</_object>
			</geometry>
			<properties>
				<_object>
					<name>
						<xsl:choose>
							<xsl:when test="$name castable as xs:string">
								<xsl:value-of select="$name"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="string-join($name, '/')"/>
							</xsl:otherwise>
						</xsl:choose>
						
					</name>
					<xsl:if test="$uri castable as xs:string">
						<uri>
							<xsl:value-of select="$uri"/>
						</uri>
					</xsl:if>
					<type>
						<xsl:value-of select="$type"/>
					</type>
					<xsl:if test="number($count)">
						<average_count>
							<xsl:value-of select="$count"/>
						</average_count>
					</xsl:if>
				</_object>
			</properties>
		</_object>
	</xsl:template>

</xsl:stylesheet>
