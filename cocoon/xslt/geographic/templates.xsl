<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" xmlns:gml="http://www.opengis.net/gml/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:nh="http://nomisma.org/nudsHoard" xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">
	<xsl:template name="kml">
		<kml xmlns="http://earth.google.com/kml/2.0">
			<Document>
				<Style xmlns="" id="mint">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/mapfiles/kml/pal4/icon48.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style xmlns="" id="hoard">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/mapfiles/kml/pal4/icon49.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style xmlns="" id="mapped">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/mapfiles/kml/pal4/icon57.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<xsl:choose>
					<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
						<xsl:apply-templates select="/content/nuds:nuds" mode="kml"/>
					</xsl:when>
					<xsl:when test="count(/content/*[local-name()='nudsHoard']) &gt; 0">
						<xsl:apply-templates select="/content/nh:nudsHoard" mode="kml"/>
					</xsl:when>
				</xsl:choose>
			</Document>
		</kml>
	</xsl:template>

	<xsl:template name="json">
		<xsl:text> [ </xsl:text>
		<xsl:choose>
			<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
				<xsl:apply-templates select="/content/nuds:nuds" mode="json"/>
			</xsl:when>
			<xsl:when test="count(/content/*[local-name()='nudsHoard']) &gt; 0">
				<xsl:apply-templates select="/content/nh:nudsHoard" mode="json"/>
			</xsl:when>
		</xsl:choose>
		<xsl:text> ] </xsl:text>
	</xsl:template>

	<xsl:template match="nuds:nuds" mode="kml">
		<!-- create mint points -->
		<xsl:for-each select="exsl:node-set($nudsGroup)/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#mint</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<!-- create findspot points (for physical coins -->
		<xsl:for-each select="exsl:node-set($nudsGroup)/descendant::nuds:geogname[@xlink:role='findspot'][string(@xlink:href)]|descendant::nuds:findspotDesc[string(@xlink:href)]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#hoard</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<!-- gather associated hoards from Metis is available -->
		<xsl:if test="string($sparql_endpoint)">
			<cinclude:include src="cocoon:/widget?uri={concat($url, 'id/', $id)}&amp;template=kml"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:nuds" mode="json">
		<xsl:for-each select="exsl:node-set($nudsGroup)/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]">
			<xsl:call-template name="getJsonPoint">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="type">mint</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nh:nudsHoard" mode="kml">
		<xsl:for-each select="descendant::nh:geogname[@xlink:role='findspot'][string(@xlink:href)]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#hoard</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="exsl:node-set($nudsGroup)/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]">
			<!-- commenting out unique portion: [not(.=preceding::nuds:geogname)] -->
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#mapped</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nh:nudsHoard" mode="json">
		<!-- display map point for findspot -->
		<xsl:for-each select="descendant::nh:geogname[@xlink:role='findspot'][string(@xlink:href)]">
			<xsl:call-template name="getJsonPoint">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="type">findspot</xsl:with-param>
				<xsl:with-param name="title" select="."/>
			</xsl:call-template>
			<xsl:if test="count(distinct-values(exsl:node-set($nudsGroup)/descendant::nuds:geogname[@xlink:role='mint']/@xlink:href)) &gt; 0">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>

		<!-- display map points for mints only -->
		<xsl:for-each select="distinct-values(exsl:node-set($nudsGroup)/descendant::nuds:geogname[@xlink:role='mint']/@xlink:href)">
			<xsl:call-template name="getJsonPoint">
				<xsl:with-param name="href" select="."/>
				<xsl:with-param name="type">mint</xsl:with-param>
				<xsl:with-param name="title">
					<xsl:variable name="href" select="."/>
					<xsl:choose>
						<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
							<xsl:choose>
								<xsl:when test="string(exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel[@xml:lang=$lang])">
									<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel[@xml:lang=$lang]"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel[@xml:lang='en']"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel[@xml:lang='en']"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="count(exsl:node-set($nudsGroup)//nuds:typeDesc) &gt; 0">
			<xsl:text>,</xsl:text>
		</xsl:if>
		<!-- create timeline only events for associated coin types -->
		<xsl:for-each select="exsl:node-set($nudsGroup)/descendant::nuds:typeDesc">
			<xsl:call-template name="getJsonPoint">
				<xsl:with-param name="href"/>
				<xsl:with-param name="type">coinType</xsl:with-param>
				<xsl:with-param name="title">
					<xsl:choose>
						<xsl:when test="parent::nuds:descMeta/nuds:title">
							<xsl:choose>
								<xsl:when test="string($lang)">
									<xsl:choose>
										<xsl:when test="lang($lang, parent::nuds:descMeta/nuds:title)">
											<xsl:value-of select="parent::nuds:descMeta/nuds:title[@xml:lang=$lang]"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when test="lang('en', parent::nuds:descMeta/nuds:title)">
													<xsl:value-of select="parent::nuds:descMeta/nuds:title[@xml:lang='en']"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="parent::nuds:descMeta/nuds:title[1]"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="lang('en', parent::nuds:descMeta/nuds:title)">
											<xsl:value-of select="parent::nuds:descMeta/nuds:title[@xml:lang='en']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="parent::nuds:descMeta/nuds:title[1]"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="nuds:denomination">
									<xsl:value-of select="nuds:denomination"/>
								</xsl:when>
								<xsl:otherwise>[No Title]</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="getJsonPoint">
		<xsl:param name="href"/>
		<xsl:param name="type"/>
		<xsl:param name="title"/>
		<!-- generate json values -->
		<xsl:variable name="coordinates">
			<xsl:choose>
				<xsl:when test="contains($href, 'geonames')">
					<xsl:variable name="geonameId" select="substring-before(substring-after($href, 'geonames.org/'), '/')"/>
					<xsl:variable name="geonames_data" select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
					<xsl:variable name="lat" select="exsl:node-set($geonames_data)//lat"/>
					<xsl:variable name="lon" select="exsl:node-set($geonames_data)//lng"/>
					<xsl:choose>
						<xsl:when test="string($lat) and string($lon)">
							<xsl:value-of select="$lat"/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="$lon"/>
						</xsl:when>
						<xsl:otherwise>NULL</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="contains($href, 'nomisma')">
					<xsl:variable name="coords" select="exsl:node-set($rdf)//*[@rdf:about=$href]/gml:pos"/>
					<xsl:choose>
						<xsl:when test="string($coords)">
							<xsl:variable name="lat" select="substring-before($coords, ' ')"/>
							<xsl:variable name="lon" select="substring-after($coords, ' ')"/>
							<xsl:value-of select="concat($lat, '|', $lon)"/>
						</xsl:when>
						<xsl:otherwise>NULL</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test="$type='coinType'">
					<!-- get coordinates of mint, if applicable-->
					<xsl:choose>
						<xsl:when test="nuds:geographic/nuds:geogname[@xlink:role='mint'][@xlink:href]">
							<xsl:variable name="thisHref" select="nuds:geographic/nuds:geogname[@xlink:role='mint'][1]/@xlink:href"/>
							<xsl:variable name="coordinates">
								<xsl:choose>
									<xsl:when test="contains($thisHref, 'geonames')">
										<xsl:variable name="geonameId" select="substring-before(substring-after($href, 'geonames.org/'), '/')"/>
										<xsl:variable name="geonames_data" select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
										<xsl:variable name="lat" select="exsl:node-set($geonames_data)//lat"/>
										<xsl:variable name="lon" select="exsl:node-set($geonames_data)//lng"/>
										<xsl:choose>
											<xsl:when test="string($lat) and string($lon)">
												<xsl:value-of select="$lat"/>
												<xsl:text>|</xsl:text>
												<xsl:value-of select="$lon"/>
											</xsl:when>
											<xsl:otherwise>NULL</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="contains($thisHref, 'nomisma')">
										<xsl:variable name="coords" select="exsl:node-set($rdf)//*[@rdf:about=$thisHref]/gml:pos"/>
										<xsl:choose>
											<xsl:when test="string($coords)">
												<xsl:variable name="lat" select="substring-before($coords, ' ')"/>
												<xsl:variable name="lon" select="substring-after($coords, ' ')"/>
												<xsl:value-of select="concat($lat, '|', $lon)"/>
											</xsl:when>
											<xsl:otherwise>NULL</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
								</xsl:choose>
							</xsl:variable>
							<![CDATA[<table style='width:100%'><tr><td style='width:50%'>]]>
							<xsl:if test="$coordinates != 'NULL'">
								<![CDATA[<<img src='http://maps.google.com/maps/api/staticmap?size=120x120&zoom=4&markers=color:blue%7C]]><xsl:value-of select="replace($coordinates, '\|', ',')"
									/>
								<![CDATA[&sensor=false&maptype=terrain'/>]]>
							</xsl:if>
							<![CDATA[</td>]]>
							
							<!-- display date -->
							<![CDATA[<td style='width:50%'>]]>
							<xsl:choose>
								<xsl:when test="string($lang)">
									<xsl:choose>
										<xsl:when test="lang($lang, exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$thisHref]/skos:prefLabel)">
											<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$thisHref]/skos:prefLabel[@xml:lang=$lang]"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$thisHref]/skos:prefLabel[@xml:lang='en']"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="nuds:geographic/nuds:geogname[@xlink:role='mint'][@xlink:href][1]"/>
								</xsl:otherwise>
							</xsl:choose>
							<![CDATA[<br/>]]>						
							<xsl:if test="nuds:date or nuds:dateRange">
								<xsl:choose>
									<xsl:when test="string(nuds:date)">
										<xsl:value-of select="nuds:date"/>
									</xsl:when>
									<xsl:when test="string(nuds:dateRange)">
										<xsl:value-of select="nuds:dateRange/nuds:fromDate"/>
										<xsl:text> - </xsl:text>
										<xsl:value-of select="nuds:dateRange/nuds:toDate"/>
									</xsl:when>
								</xsl:choose>
							</xsl:if>
							<![CDATA[</td></tr></table>]]>
						</xsl:when>
						<xsl:otherwise>
							<!-- display date -->
							<xsl:if test="nuds:date or nuds:dateRange">
								<xsl:choose>
									<xsl:when test="string(nuds:date)">
										<xsl:value-of select="nuds:date"/>
									</xsl:when>
									<xsl:when test="string(nuds:dateRange)">
										<xsl:value-of select="nuds:dateRange/nuds:fromDate"/>
										<xsl:text> - </xsl:text>
										<xsl:value-of select="nuds:dateRange/nuds:toDate"/>
									</xsl:when>
								</xsl:choose>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
					
					
				</xsl:when>
				<xsl:when test="$type='mint'"/>
				<xsl:when test="$type='findspot'">
					<![CDATA[Findspot - Lat: ]]><xsl:value-of select="tokenize($coordinates, '\|')[1]"/><![CDATA[, Lon: ]]><xsl:value-of select="tokenize($coordinates, '\|')[2]"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="theme">
			<xsl:choose>
				<xsl:when test="$type='mint'">
					<xsl:text>blue</xsl:text>
				</xsl:when>
				<xsl:when test="$type='coinType'">
					<xsl:text>ltblue</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>red</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="start">
			<xsl:choose>
				<xsl:when test="$type='mint'"/>
				<xsl:when test="$type='coinType'">
					<xsl:choose>
						<xsl:when test="nuds:date/@standardDate">
							<xsl:value-of select="number(nuds:date/@standardDate)"/>
						</xsl:when>
						<xsl:when test="nuds:dateRange/nuds:fromDate/@standardDate">
							<xsl:value-of select="number(nuds:dateRange/nuds:fromDate/@standardDate)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="end">
			<xsl:choose>
				<xsl:when test="$type='mint'"/>
				<xsl:when test="$type='coinType'">
					<xsl:if test="nuds:dateRange/nuds:toDate/@standardDate">
						<xsl:value-of select="number(nuds:dateRange/nuds:toDate/@standardDate)"/>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<!-- output --> { <xsl:if test="string($coordinates) and not($coordinates='NULL')">"point": {"lon": <xsl:value-of select="tokenize($coordinates, '\|')[2]"/>, "lat": <xsl:value-of
				select="tokenize($coordinates, '\|')[1]"/>},</xsl:if> "title": "<xsl:value-of select="$title"/>", <xsl:if test="string($start)">"start": "<xsl:value-of select="$start"/>",</xsl:if>
		<xsl:if test="string($end)">"end": "<xsl:value-of select="$end"/>",</xsl:if> "options": { "theme": "<xsl:value-of select="$theme"/>"<xsl:if test="string($description)">, "description":
				"<xsl:value-of select="normalize-space($description)"/>"</xsl:if><xsl:if test="string($href) or string(@xlink:href)">, "href": "<xsl:value-of
				select="if (string($href)) then $href else @xlink:href"/>"</xsl:if> } } </xsl:template>

	<xsl:template name="getPlacemark">
		<xsl:param name="href"/>
		<xsl:param name="styleUrl"/>

		<xsl:variable name="label">
			<!-- display the title (coin type reference) for hoards, place name for other points -->
			<xsl:choose>
				<xsl:when test="$styleUrl='#mapped'">
					<xsl:value-of select="ancestor::nuds:nuds/nuds:descMeta/nuds:title"/>
				</xsl:when>
				<xsl:when test="local-name()='findspotDesc'">
					<xsl:choose>
						<xsl:when test="contains($href, 'nomisma.org')">
							<xsl:choose>
								<xsl:when test="string(exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel)">
									<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$href"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
					</xsl:choose>
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
				<xsl:when test="$styleUrl='#mapped'">
					<description>
						<xsl:value-of select="."/>
						<!-- display date -->
						<xsl:if test="ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:date or ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:dateRange">
							<xsl:text>, </xsl:text>
							<xsl:choose>
								<xsl:when test="string(ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:date)">
									<xsl:value-of select="ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:date"/>
								</xsl:when>
								<xsl:when test="string(ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:dateRange)">
									<xsl:value-of select="ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:dateRange/nuds:fromDate"/>
									<xsl:text> - </xsl:text>
									<xsl:value-of select="ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:dateRange/nuds:toDate"/>
								</xsl:when>
							</xsl:choose>
						</xsl:if>
					</description>
				</xsl:when>
				<xsl:otherwise>
					<description>
						<![CDATA[
          					<span><a href="]]><xsl:value-of select="$href"/><![CDATA[" target="_blank">]]><xsl:value-of select="$label"/><![CDATA[</a>]]>
						<![CDATA[</span>
        				]]>
					</description>
				</xsl:otherwise>
			</xsl:choose>

			<styleUrl>
				<xsl:value-of select="$styleUrl"/>
			</styleUrl>
			<xsl:choose>
				<xsl:when test="contains($href, 'geonames')">
					<xsl:variable name="geonameId" select="substring-before(substring-after($href, 'geonames.org/'), '/')"/>
					<xsl:variable name="geonames_data" select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
					<xsl:variable name="coordinates" select="concat(exsl:node-set($geonames_data)//lng, ',', exsl:node-set($geonames_data)//lat)"/>
					<Point>
						<coordinates>
							<xsl:value-of select="$coordinates"/>
						</coordinates>
					</Point>
				</xsl:when>
				<xsl:when test="contains($href, 'nomisma')">
					<xsl:variable name="coordinates" select="exsl:node-set($rdf)//*[@rdf:about=$href]/descendant::gml:pos"/>
					<xsl:if test="string($coordinates)">
						<xsl:variable name="lat" select="substring-before($coordinates, ' ')"/>
						<xsl:variable name="lon" select="substring-after($coordinates, ' ')"/>
						<Point>
							<coordinates>
								<xsl:value-of select="concat($lon, ',', $lat)"/>
							</coordinates>
						</Point>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
			<!-- display timespan -->
			<xsl:choose>
				<xsl:when test="ancestor::nuds:typeDesc/nuds:date/@standardDate">
					<TimeStamp>
						<when>
							<xsl:value-of select="number(ancestor::nuds:typeDesc/nuds:date/@standardDate)"/>
						</when>
					</TimeStamp>
				</xsl:when>
				<xsl:when test="ancestor::nuds:typeDesc/nuds:dateRange/nuds:fromDate/@standardDate and ancestor::nuds:typeDesc/nuds:dateRange/nuds:toDate/@standardDate">
					<TimeSpan>
						<begin>
							<xsl:value-of select="number(ancestor::nuds:typeDesc/nuds:dateRange/nuds:fromDate/@standardDate)"/>
						</begin>
						<end>
							<xsl:value-of select="number(ancestor::nuds:typeDesc/nuds:dateRange/nuds:toDate/@standardDate)"/>
						</end>
					</TimeSpan>
				</xsl:when>
			</xsl:choose>
		</Placemark>
	</xsl:template>
</xsl:stylesheet>
