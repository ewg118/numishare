<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:gml="http://www.opengis.net/gml"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nmo="http://nomisma.org/ontology#" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:digest="org.apache.commons.codec.digest.DigestUtils"
	exclude-result-prefixes="#all" version="2.0">
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
			<xsl:variable name="type_series" as="element()*">
				<list>
					<xsl:for-each
						select="distinct-values((descendant::nuds:typeDesc[string(@xlink:href)] | descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem'][string(@xlink:href)])/substring-before(@xlink:href, 'id/'))">
						<type_series>
							<xsl:value-of select="."/>
						</type_series>
					</xsl:for-each>
				</list>
			</xsl:variable>
			<xsl:variable name="type_list" as="element()*">
				<list>
					<xsl:for-each
						select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/@xlink:href | descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem'][string(@xlink:href)]/@xlink:href)">
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
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
			xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#" xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">
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
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="count(/content/*[local-name() = 'nuds']) &gt; 0">
				<xsl:apply-templates select="/content/nuds:nuds"/>
			</xsl:when>
			<xsl:when test="count(/content/*[local-name() = 'nudsHoard']) &gt; 0">
				<xsl:apply-templates select="/content/nh:nudsHoard"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<xsl:choose>
			<xsl:when
				test="count($nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][string(@xlink:href)] | descendant::nuds:geogname[@xlink:role = 'findspot'][string(@xlink:href)] | descendant::nuds:findspotDesc[string(@xlink:href)] | descendant::nuds:subject[contains(@xlink:href, 'geonames.org')] | descendant::nuds:findspot[gml:Point]) &gt; 1">
				<xsl:text>[</xsl:text>
			</xsl:when>
			<xsl:when
				test="count($nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][string(@xlink:href)] | descendant::nuds:geogname[@xlink:role = 'findspot'][string(@xlink:href)] | descendant::nuds:findspotDesc[string(@xlink:href)] | descendant::nuds:subject[contains(@xlink:href, 'geonames.org')] | descendant::nuds:findspot[gml:Point]) = 0">
				<xsl:text>{</xsl:text>
			</xsl:when>
		</xsl:choose>


		<!-- create mint points -->
		<xsl:for-each
			select="$nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][string(@xlink:href)] | descendant::nuds:geogname[@xlink:role = 'findspot'][string(@xlink:href)] | descendant::nuds:findspotDesc[string(@xlink:href)] | descendant::nuds:subject[contains(@xlink:href, 'geonames.org')] | descendant::nuds:findspot[gml:Point]">
			<xsl:variable name="uri" select="@xlink:href"/>
			<xsl:variable name="type">
				<xsl:choose>
					<xsl:when test="@xlink:role = 'mint'">
						<!-- evaluate whether the mint is uncertain or not -->
						<xsl:choose>
							<xsl:when test="@certainty">uncertainMint</xsl:when>
							<xsl:when test="$rdf//*[@rdf:about = $uri]/skos:related">uncertainMint</xsl:when>
							<xsl:otherwise>mint</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="@xlink:role = 'findspot' or self::nuds:findspotDesc or self::nuds:findspot">findspot</xsl:when>
					<xsl:when test="self::nuds:subject">subject</xsl:when>
				</xsl:choose>
			</xsl:variable>

			<xsl:call-template name="generateFeature">
				<xsl:with-param name="uri" select="$uri"/>
				<xsl:with-param name="type" select="$type"/>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:choose>
			<xsl:when
				test="count($nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][string(@xlink:href)] | descendant::nuds:geogname[@xlink:role = 'findspot'][string(@xlink:href)] | descendant::nuds:findspotDesc[string(@xlink:href)] | descendant::nuds:subject[contains(@xlink:href, 'geonames.org')] | descendant::nuds:findspot[gml:Point]) &gt; 1">
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:when
				test="count($nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][string(@xlink:href)] | descendant::nuds:geogname[@xlink:role = 'findspot'][string(@xlink:href)] | descendant::nuds:findspotDesc[string(@xlink:href)] | descendant::nuds:subject[contains(@xlink:href, 'geonames.org')] | descendant::nuds:findspot[gml:Point]) = 0">
				<xsl:text>}</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nh:nudsHoard">
		<xsl:choose>
			<xsl:when
				test="count($nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][string(@xlink:href)] | descendant::nh:geogname[@xlink:role = 'findspot'][string(@xlink:href)]) &gt; 1">
				<xsl:text>[</xsl:text>
			</xsl:when>
			<xsl:when
				test="count($nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][string(@xlink:href)] | descendant::nh:geogname[@xlink:role = 'findspot'][string(@xlink:href)]) = 0">
				<xsl:text>{</xsl:text>
			</xsl:when>
		</xsl:choose>

		<xsl:for-each
			select="descendant::nh:geogname[@xlink:role = 'findspot'][string(@xlink:href)] | $nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][string(@xlink:href)]">
			<xsl:call-template name="generateFeature">
				<xsl:with-param name="uri" select="@xlink:href"/>
				<xsl:with-param name="type">
					<xsl:choose>
						<xsl:when test="@xlink:role = 'mint'">mapped</xsl:when>
						<xsl:when test="@xlink:role = 'findspot'">findspot</xsl:when>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:choose>
			<xsl:when
				test="count($nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][string(@xlink:href)] | descendant::nh:geogname[@xlink:role = 'findspot'][string(@xlink:href)]) &gt; 1">
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:when
				test="count($nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][string(@xlink:href)] | descendant::nh:geogname[@xlink:role = 'findspot'][string(@xlink:href)]) = 0">
				<xsl:text>}</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="generateFeature">
		<xsl:param name="uri"/>
		<xsl:param name="type"/>

		<xsl:variable name="geonames_data" as="element()*">
			<xsl:choose>
				<xsl:when test="contains($uri, 'geonames')">
					<xsl:variable name="geonameId" select="tokenize($uri, '/')[4]"/>
					<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))/*"/>
				</xsl:when>
				<xsl:otherwise>
					<empty/>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:variable>

		<xsl:variable name="name">
			<!-- display the title (coin type reference) for hoards, place name for other points -->
			<xsl:choose>
				<xsl:when test="$type = 'mapped'">
					<xsl:value-of select="ancestor::nuds:nuds/nuds:descMeta/nuds:title"/>
				</xsl:when>
				<xsl:when test="local-name() = 'findspotDesc'">
					<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $uri], $lang)"/>
				</xsl:when>
				<xsl:when test="local-name() = 'findspot'">
					<xsl:value-of select="nuds:geogname"/>
				</xsl:when>
				<xsl:when test="@xlink:role = 'mint'">
					<xsl:choose>
						<xsl:when test="contains($uri, 'geonames')">
							<xsl:variable name="countryCode" select="$geonames_data//countryCode"/>
							<xsl:variable name="countryName" select="$geonames_data//countryName"/>
							<xsl:variable name="name" select="$geonames_data//name"/>
							<xsl:variable name="adminName1" select="$geonames_data//adminName1"/>
							<xsl:variable name="fcode" select="$geonames_data//fcode"/>
							<!-- set a value equivalent to AACR2 standard for US, AU, CA, and GB.  This equation deviates from AACR2 for Malaysia since standard abbreviations for territories cannot be found -->
							<xsl:value-of
								select="
									if ($countryCode = 'US' or $countryCode = 'AU' or $countryCode = 'CA') then
										if ($fcode = 'ADM1') then
											$name
										else
											concat($name, ' (',
											$abbreviations//country[@code = $countryCode]/place[. = $adminName1]/@abbr, ')')
									else
										if ($countryCode = 'GB') then
											if ($fcode = 'ADM1') then
												$name
											else
												concat($name, ' (',
												$adminName1, ')')
										else
											if ($fcode = 'PCLI') then
												$name
											else
												concat($name, ' (', $countryName, ')')"
							/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $uri], $lang)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="coordinates">
			<xsl:choose>
				<!-- evaluate the URI and extract coordinates -->
				<xsl:when test="string($uri)">
					<xsl:choose>
						<xsl:when test="contains($uri, 'geonames')">
							<xsl:value-of select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>
						</xsl:when>
						<xsl:when test="contains($uri, 'nomisma')">
							<xsl:choose>
								<!-- when there is a geo:SpatialThing associated with the mint that contains a lat and long: -->
								<xsl:when test="$rdf//*[@rdf:about = concat($uri, '#this')]/geo:long and $rdf//*[@rdf:about = concat($uri, '#this')]/geo:lat">
									<xsl:value-of select="concat($rdf//*[@rdf:about = concat($uri, '#this')]/geo:long, ',', $rdf//*[@rdf:about = concat($uri, '#this')]/geo:lat)"/>
								</xsl:when>
								<!-- if the URI contains a skos:related linking to an uncertain mint attribution -->
								<xsl:when test="$rdf//*[@rdf:about = $uri]/skos:related">
									<xsl:variable name="uncertainMint" as="node()*">
										<xsl:copy-of select="document(concat($rdf//*[@rdf:about = $uri]/skos:related/rdf:Description/rdf:value/@rdf:resource, '.rdf'))"/>
									</xsl:variable>

									<xsl:if test="$uncertainMint//geo:long and $uncertainMint//geo:lat">
										<xsl:value-of select="concat($uncertainMint//geo:long, ',', $uncertainMint//geo:lat)"/>
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
										<xsl:value-of select="concat($regions//mint[1]/@long, ',', $regions//mint[1]/@lat)"/>
									</xsl:if>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="contains($uri, 'coinhoards.org')">
							<xsl:variable name="findspotUri" select="$rdf//*[@rdf:about = $uri]/nmo:hasFindspot/@rdf:resource"/>

							<xsl:if test="string-length($findspotUri) &gt; 0">
								<xsl:value-of select="concat($rdf//*[@rdf:about = $findspotUri]/geo:long, ',', $rdf//*[@rdf:about = $findspotUri]/geo:lat)"/>
							</xsl:if>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<!-- otherwise use the gml:Point stored within NUDS -->
				<xsl:when test="gml:Point">
					<xsl:variable name="coords" select="tokenize(gml:Point/gml:coordinates, ',')"/>
					<xsl:value-of select="concat(normalize-space($coords[2]), ',', normalize-space($coords[1]))"/>
				</xsl:when>
			</xsl:choose>


		</xsl:variable>

		<xsl:if test="string-length($coordinates) &gt; 0">
			<xsl:text>{"type": "Feature","geometry": {"type": "Point","coordinates": [</xsl:text>
			<xsl:value-of select="$coordinates"/>
			<xsl:text>]},"properties": {"name": "</xsl:text>
			<xsl:value-of select="$name"/>
			<xsl:text>",</xsl:text>
			<xsl:if test="string($uri)">
				<xsl:text>"uri": "</xsl:text>
				<xsl:value-of select="$uri"/>
				<xsl:text>",</xsl:text>
			</xsl:if>
			<xsl:text>"type": "</xsl:text>
			<xsl:value-of select="$type"/>
			<xsl:text>"</xsl:text>
			<xsl:text>}}</xsl:text>
			<xsl:if test="not(position() = last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- AACR2 place normalization variable -->
	<xsl:variable name="abbreviations" as="element()*">
		<abbreviations>
			<country code="US">
				<place abbr="Ala.">Alabama</place>
				<place abbr="Alaska">Alaska</place>
				<place abbr="Ariz.">Arizona</place>
				<place abbr="Ark.">Arkansas</place>
				<place abbr="Calif.">California</place>
				<place abbr="Colo.">Colorado</place>
				<place abbr="Conn.">Connecticut</place>
				<place abbr="Del.">Delaware</place>
				<place abbr="D.C.">Washington, D.C.</place>
				<place abbr="Fla.">Florida</place>
				<place abbr="Ga.">Georgia</place>
				<place abbr="Hawaii">Hawaii</place>
				<place abbr="Idaho">Idaho</place>
				<place abbr="Ill.">Illinois</place>
				<place abbr="Ind.">Indiana</place>
				<place abbr="Iowa">Iowa</place>
				<place abbr="Kans.">Kansas</place>
				<place abbr="Ky.">Kentucky</place>
				<place abbr="La.">Louisiana</place>
				<place abbr="Maine">Maine</place>
				<place abbr="Md.">Maryland</place>
				<place abbr="Mass.">Massachusetts</place>
				<place abbr="Mich.">Michigan</place>
				<place abbr="Minn.">Minnesota</place>
				<place abbr="Miss.">Mississippi</place>
				<place abbr="Mo.">Missouri</place>
				<place abbr="Mont.">Montana</place>
				<place abbr="Nebr.">Nebraska</place>
				<place abbr="Nev.">Nevada</place>
				<place abbr="N.H.">New Hampshire</place>
				<place abbr="N.J.">New Jersey</place>
				<place abbr="N.M.">New Mexico</place>
				<place abbr="N.Y.">New York</place>
				<place abbr="N.C.">North Carolina</place>
				<place abbr="N.D.">North Dakota</place>
				<place abbr="Ohio">Ohio</place>
				<place abbr="Okla.">Oklahoma</place>
				<place abbr="Oreg.">Oregon</place>
				<place abbr="Pa.">Pennsylvania</place>
				<place abbr="R.I.">Rhode Island</place>
				<place abbr="S.C.">South Carolina</place>
				<place abbr="S.D">South Dakota</place>
				<place abbr="Tenn.">Tennessee</place>
				<place abbr="Tex.">Texas</place>
				<place abbr="Utah">Utah</place>
				<place abbr="Vt.">Vermont</place>
				<place abbr="Va.">Virginia</place>
				<place abbr="Wash.">Washington</place>
				<place abbr="W.Va.">West Virginia</place>
				<place abbr="Wis.">Wisconsin</place>
				<place abbr="Wyo.">Wyoming</place>
				<place abbr="A.S.">American Samoa</place>
				<place abbr="Guam">Guam</place>
				<place abbr="M.P.">Northern Mariana Islands</place>
				<place abbr="P.R.">Puerto Rico</place>
				<place abbr="V.I.">U.S. Virgin Islands</place>
			</country>
			<country code="CA">
				<place abbr="Alta.">Alberta</place>
				<place abbr="B.C.">British Columbia</place>
				<place abbr="Alta.">Manitoba</place>
				<place abbr="Man.">Alberta</place>
				<place abbr="N.B.">New Brunswick</place>
				<place abbr="Nfld.">Newfoundland and Labrador</place>
				<place abbr="N.W.T.">Northwest Territories</place>
				<place abbr="N.S.">Nova Scotia</place>
				<place abbr="NU">Nunavut</place>
				<place abbr="Ont.">Ontario</place>
				<place abbr="P.E.I.">Prince Edward Island</place>
				<place abbr="Que.">Quebec</place>
				<place abbr="Sask.">Saskatchewan</place>
				<place abbr="Y.T.">Yukon</place>
			</country>
			<country code="AU">
				<place abbr="A.C.T.">Australian Capital Territory</place>
				<place abbr="J.B.T.">Jervis Bay Territory</place>
				<place abbr="N.S.W.">New South Wales</place>
				<place abbr="N.T.">Northern Territory</place>
				<place abbr="Qld.">Queensland</place>
				<place abbr="S.A.">South Australia</place>
				<place abbr="Tas.">Tasmania</place>
				<place abbr="Vic.">Victoria</place>
				<place abbr="W.A.">Western Australia</place>
			</country>
		</abbreviations>
	</xsl:variable>

</xsl:stylesheet>
