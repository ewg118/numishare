<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Modified: April 2020
	Function: Serialize the NUDS or NUDS Hoard into KML. The NUDS record for a coin type will serialize a SPARQL response of associated hoards into Placemarks -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:saxon="http://saxon.sf.net/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:gml="http://www.opengis.net/gml" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
	xmlns:crmgeo="http://www.ics.forth.gr/isl/CRMgeo/"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:numishare="https://github.com/ewg118/numishare"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>

	<xsl:output name="html" encoding="UTF-8" method="html" indent="no" omit-xml-declaration="yes"/>

	<xsl:variable name="id" select="descendant::*:recordId"/>
	<xsl:variable name="lang"
		select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
	<xsl:variable name="request-uri" select="
			concat('http://localhost:', if (//config/server-port castable as xs:integer) then
				//config/server-port
			else
				'8080', substring-before(doc('input:request')/request/request-uri, 'id/'))"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="geonames-url">http://api.geonames.org</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="collection_type" select="/content/config/collection_type"/>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:variable name="type_list" as="element()*">
				<list>
					<xsl:for-each
						select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/@xlink:href | descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem'][string(@xlink:href)]/@xlink:href)">
						<type_series_item>
							<xsl:if test="contains(., '/id/')">
								<xsl:attribute name="type_series"
									select="substring-before(., 'id/')"/>
							</xsl:if>

							<xsl:value-of select="."/>
						</type_series_item>
					</xsl:for-each>
				</list>
			</xsl:variable>

			<xsl:for-each select="distinct-values($type_list//type_series_item/@type_series)">
				<xsl:variable name="type_series_uri" select="."/>

				<xsl:variable name="id-param">
					<xsl:for-each
						select="$type_list//type_series_item[contains(., $type_series_uri)]">
						<xsl:value-of select="substring-after(., 'id/')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<xsl:if test="string-length($id-param) &gt; 0">
					<xsl:for-each
						select="document(concat($type_series_uri, 'apis/getNuds?identifiers=', encode-for-uri($id-param)))//nuds:nuds">
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
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
			xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
			xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
			xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">
			<xsl:variable name="id-param">
				<xsl:for-each select="
						distinct-values(descendant::*[not(local-name() = 'typeDesc') and not(local-name() = 'reference')][contains(@xlink:href,
						'nomisma.org')]/@xlink:href | $nudsGroup/descendant::*[not(local-name() = 'object') and not(local-name() = 'typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position() = last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="rdf_url"
				select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
			<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>

			<xsl:if test="descendant::nuds:findspotDesc[contains(@xlink:href, 'coinhoards.org')]">
				<xsl:copy-of
					select="document(concat(descendant::nuds:findspotDesc/@xlink:href, '.rdf'))/rdf:RDF/*"
				/>
			</xsl:if>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<kml xmlns="http://earth.google.com/kml/2.0">
			<Document>
				<Style id="mint">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>https://maps.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style id="hoard">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>https://maps.google.com/intl/en_us/mapfiles/ms/micons/red-dot.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style id="findspot">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>https://maps.google.com/intl/en_us/mapfiles/ms/micons/orange-dot.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style id="mapped">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>https://maps.google.com/intl/en_us/mapfiles/ms/micons/red-dot.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style id="subject">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>https://maps.google.com/intl/en_us/mapfiles/ms/micons/green-dot.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<xsl:choose>
					<xsl:when test="count(/content/*[local-name() = 'nuds']) &gt; 0">
						<xsl:apply-templates select="/content/nuds:nuds"/>
					</xsl:when>
					<xsl:when test="count(/content/*[local-name() = 'nudsHoard']) &gt; 0">
						<xsl:apply-templates select="/content/nh:nudsHoard"/>
					</xsl:when>
				</xsl:choose>
			</Document>
		</kml>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<!-- create mint points -->
		<xsl:for-each
			select="$nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][string(@xlink:href)]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="uri" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#mint</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<!-- create hoard/findspot points (for physical coins) -->
		<xsl:for-each select="descendant::nuds:findspotDesc[string(@xlink:href)]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="uri" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#hoard</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each
			select="descendant::nuds:geogname[@xlink:role = 'findspot'][string(@xlink:href)] | descendant::nuds:findspot[gml:location/gml:Point/gml:pos]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="uri" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#findspot</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<!-- create subject markers whent he subject is a Geonames place -->
		<xsl:for-each select="descendant::nuds:subject[contains(@xlink:href, 'geonames.org')]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="uri" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#subject</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<!-- gather associated hoards from Nomisma, when the KML is for a coin type -->
		<xsl:if test="$collection_type = 'cointype' and matches($sparql_endpoint, 'https?://')">
			<xsl:apply-templates select="doc('input:hoards')//res:result"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nh:nudsHoard">
		<xsl:for-each
			select="descendant::nh:geogname[@xlink:role = 'findspot'][string(@xlink:href)]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="uri" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#hoard</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each
			select="$nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][string(@xlink:href)]">
			<!-- commenting out unique portion: [not(.=preceding::nuds:geogname)] -->
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="uri" select="@xlink:href"/>
				<xsl:with-param name="type">mapped</xsl:with-param>
				<xsl:with-param name="styleUrl">#mint</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="res:result">
		<Placemark xmlns="http://earth.google.com/kml/2.0">
			<name>
				<xsl:value-of select="res:binding[@name = 'hoardLabel']/res:literal"/>
			</name>
			<description>
				<xsl:variable name="desc" as="element()*">
					<ul>
						<li>
							<b>URL: </b>
							<a href="{res:binding[@name='hoard']/res:uri}">
								<xsl:value-of select="res:binding[@name = 'hoardLabel']/res:literal"
								/>
							</a>
						</li>
						<li>
							<b>Findspot: </b>
							<a href="{res:binding[@name='place']/res:uri}">
								<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
							</a>
						</li>
					</ul>
				</xsl:variable>

				<xsl:value-of select="saxon:serialize($desc, 'html')"/>
			</description>
			<styleUrl>#hoard</styleUrl>
			<Point>
				<coordinates>
					<xsl:value-of
						select="concat(res:binding[@name = 'long']/res:literal, ',', res:binding[@name = 'lat']/res:literal)"
					/>
				</coordinates>
			</Point>
		</Placemark>
	</xsl:template>

	<xsl:template name="getPlacemark">
		<xsl:param name="uri"/>
		<xsl:param name="type"/>
		<xsl:param name="styleUrl"/>
		<xsl:variable name="label">
			<!-- display the title (coin type reference) for hoards, place name for other points -->
			<xsl:choose>
				<xsl:when test="$type = 'mapped'">
					<xsl:value-of select="ancestor::nuds:nuds/nuds:descMeta/nuds:title"/>
				</xsl:when>
				<xsl:when test="local-name() = 'findspotDesc'">
					<xsl:choose>
						<xsl:when
							test="contains($uri, 'nomisma.org') or contains($uri, 'coinhoards.org')">
							<xsl:value-of select="$rdf/*[@rdf:about = $uri]/skos:prefLabel"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$uri"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="local-name() = 'findspot'">
					<xsl:value-of select="nuds:geogname[@xlink:role = 'findspot']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<Placemark xmlns="http://earth.google.com/kml/2.0">
			<name>
				<xsl:value-of select="$label"/>
			</name>
			<xsl:choose>
				<xsl:when test="$type = 'mapped'">
					<description>
						<xsl:value-of select="."/>
						<!-- display date -->
						<xsl:if
							test="ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:date or ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:dateRange">
							<xsl:text>, </xsl:text>
							<xsl:choose>
								<xsl:when
									test="string(ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:date)">
									<xsl:value-of
										select="ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:date"
									/>
								</xsl:when>
								<xsl:when
									test="string(ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:dateRange)">
									<xsl:value-of
										select="ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:dateRange/nuds:fromDate"/>
									<xsl:text> - </xsl:text>
									<xsl:value-of
										select="ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:dateRange/nuds:toDate"
									/>
								</xsl:when>
							</xsl:choose>
						</xsl:if>
					</description>
				</xsl:when>
				<xsl:otherwise>
					<description>
						<![CDATA[
          					<span><a href="]]><xsl:value-of select="$uri"
							/><![CDATA[" target="_blank">]]><xsl:value-of select="$label"/><![CDATA[</a>]]>
						<![CDATA[</span>
        				]]>
					</description>
				</xsl:otherwise>
			</xsl:choose>
			<styleUrl>
				<xsl:value-of select="$styleUrl"/>
			</styleUrl>

			<xsl:choose>
				<xsl:when test="$rdf//*[@rdf:about = $uri]">
					<xsl:variable name="coordinates">
						<xsl:choose>
							<!-- when there is a geo:SpatialThing associated with the mint that contains a lat and long: -->
							<xsl:when
								test="$rdf//*[@rdf:about = concat($uri, '#this')]/geo:long and $rdf//*[@rdf:about = concat($uri, '#this')]/geo:lat">
								<xsl:value-of
									select="concat($rdf//*[@rdf:about = concat($uri, '#this')]/geo:long, ',', $rdf//*[@rdf:about = concat($uri, '#this')]/geo:lat)"
								/>
							</xsl:when>
							<!-- if the URI contains a skos:related linking to an uncertain mint attribution -->
							<xsl:when test="$rdf//*[@rdf:about = $uri]/skos:related">
								<xsl:variable name="uncertainMint" as="node()*">
									<xsl:copy-of
										select="document(concat($rdf//*[@rdf:about = $uri]/skos:related/rdf:Description/rdf:value/@rdf:resource, '.rdf'))"
									/>
								</xsl:variable>

								<xsl:if test="$uncertainMint//geo:long and $uncertainMint//geo:lat">
									<xsl:value-of
										select="concat($uncertainMint//geo:long, ',', $uncertainMint//geo:lat)"
									/>
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
									<xsl:value-of
										select="concat($regions//mint[1]/@long, ',', $regions//mint[1]/@lat)"
									/>
								</xsl:if>
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
										<xsl:choose>
											<!-- if there are a lat and long, then output an array of points -->
											<xsl:when
												test="$rdf//*[@rdf:about = $spatialThingURI][geo:lat and geo:long]">
												<xsl:value-of
												select="concat($rdf//*[@rdf:about = $spatialThingURI]/geo:long, ',', $rdf//*[@rdf:about = $spatialThingURI]/geo:lat)"
												/>
											</xsl:when>
											<!-- polygon later -->
											<xsl:when
												test="$rdf//*[@rdf:about = $spatialThingURI][crmgeo:asWKT[contains(., 'POLYGON')]]"
											> </xsl:when>
										</xsl:choose>
									</xsl:if>
								</xsl:if>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>

					<xsl:if test="string($coordinates)">
						<Point>
							<coordinates>
								<xsl:value-of select="$coordinates"/>
							</coordinates>
						</Point>
					</xsl:if>
				</xsl:when>
				<xsl:when test="contains($uri, 'geonames')">
					<xsl:variable name="geonameId" select="tokenize($uri, '/')[4]"/>
					<xsl:variable name="geonames_data" as="element()*">
						<xsl:copy-of
							select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))/*"
						/>
					</xsl:variable>
					<xsl:variable name="coordinates"
						select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>
					<Point>
						<coordinates>
							<xsl:value-of select="$coordinates"/>
						</coordinates>
					</Point>
				</xsl:when>
				<xsl:when test="gml:location/gml:Point/gml:pos">
					<xsl:variable name="coords"
						select="tokenize(gml:location/gml:Point/gml:pos, ' ')"/>

					<Point>
						<coordinates>
							<xsl:value-of
								select="concat(normalize-space($coords[2]), ',', normalize-space($coords[1]))"
							/>
						</coordinates>
					</Point>
				</xsl:when>
			</xsl:choose>
			<!-- display timespan -->
			<xsl:choose>
				<xsl:when test="$styleUrl = '#hoard'">
					<xsl:choose>
						<xsl:when test="ancestor::nh:hoardDesc/nh:deposit/nh:date/@standardDate">
							<TimeStamp>
								<when>
									<xsl:value-of
										select="number(ancestor::nh:hoardDesc/nh:deposit/nh:date/@standardDate)"
									/>
								</when>
							</TimeStamp>
						</xsl:when>
						<xsl:when test="ancestor::nh:hoardDesc/nh:closingDate/nh:date/@standardDate">
							<TimeStamp>
								<when>
									<xsl:value-of
										select="number(ancestor::nh:hoardDesc/nh:closingDate/nh:date/@standardDate)"
									/>
								</when>
							</TimeStamp>
						</xsl:when>
						<xsl:when
							test="ancestor::nh:hoardDesc/nh:closingDate/nh:dateRange/nh:fromDate/@standardDate and ancestor::nh:hoardDesc/nh:closingDate/nh:dateRange/nh:toDate/@standardDate">
							<TimeSpan>
								<begin>
									<xsl:value-of
										select="number(ancestor::nh:hoardDesc/nh:closingDate/nh:dateRange/nh:fromDate/@standardDate)"
									/>
								</begin>
								<end>
									<xsl:value-of
										select="number(ancestor::nh:hoardDesc/nh:closingDate/nh:dateRange/nh:toDate/@standardDate)"
									/>
								</end>
							</TimeSpan>
						</xsl:when>
						<xsl:when
							test="ancestor::nh:hoardDesc/nh:deposit/nh:dateRange/nh:fromDate/@standardDate and ancestor::nh:hoardDesc/nh:deposit/nh:dateRange/nh:toDate/@standardDate">
							<TimeSpan>
								<begin>
									<xsl:value-of
										select="number(ancestor::nh:hoardDesc/nh:deposit/nh:dateRange/nh:fromDate/@standardDate)"
									/>
								</begin>
								<end>
									<xsl:value-of
										select="number(ancestor::nh:hoardDesc/nh:deposit/nh:dateRange/nh:toDate/@standardDate)"
									/>
								</end>
							</TimeSpan>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="ancestor::nuds:typeDesc/nuds:date/@standardDate">
							<TimeStamp>
								<when>
									<xsl:value-of
										select="number(ancestor::nuds:typeDesc/nuds:date/@standardDate)"
									/>
								</when>
							</TimeStamp>
						</xsl:when>
						<xsl:when
							test="ancestor::nuds:typeDesc/nuds:dateRange/nuds:fromDate/@standardDate and ancestor::nuds:typeDesc/nuds:dateRange/nuds:toDate/@standardDate">
							<TimeSpan>
								<begin>
									<xsl:value-of
										select="number(ancestor::nuds:typeDesc/nuds:dateRange/nuds:fromDate/@standardDate)"
									/>
								</begin>
								<end>
									<xsl:value-of
										select="number(ancestor::nuds:typeDesc/nuds:dateRange/nuds:toDate/@standardDate)"
									/>
								</end>
							</TimeSpan>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</Placemark>
	</xsl:template>

</xsl:stylesheet>
