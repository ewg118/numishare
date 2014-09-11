<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Modified: April 2012
	Function: This stylesheet reads the incoming object model (nuds or nudsHoard)
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:cinclude="http://apache.org/cocoon/include/1.0"
	xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../nuds/solr.xsl"/>
	<xsl:include href="../nudsHoard/solr.xsl"/>
	<xsl:include href="solr-templates.xsl"/>

	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'numishare/'), '/')"/>

	<!-- config variables -->
	<xsl:variable name="geonames-url">http://api.geonames.org</xsl:variable>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="publisher" select="/content/config/template/agencyName"/>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
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
		</nudsGroup>
	</xsl:variable>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#">
			<xsl:variable name="count"
				select="count(distinct-values(descendant::*[not(local-name()='typeDesc') and not(local-name()='reference')][contains(@xlink:href, 'nomisma.org')]/@xlink:href | $nudsGroup/descendant::*[not(local-name()='typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href))"/>

			<xsl:call-template name="get-ids">
				<xsl:with-param name="start">1</xsl:with-param>
				<xsl:with-param name="end">100</xsl:with-param>
				<xsl:with-param name="count" select="$count"/>
			</xsl:call-template>
		</rdf:RDF>
	</xsl:variable>

	<!-- get block of images from SPARQL endpoint -->
	<xsl:variable name="sparqlResult" as="element()*">
		<xsl:if test="string($sparql_endpoint)">
			<response xmlns="http://www.w3.org/2005/sparql-results#">
				<!--<xsl:for-each select="descendant::nuds:recordId">
					<group>
						<xsl:attribute name="id" select="."/>
						<xsl:variable name="uri" select="concat(//config/uri_space, .)"/>
						<xsl:copy-of select="document(concat('cocoon:/widget?uri=', $uri, '&amp;template=solr'))//res:result"/>
					</group>
				</xsl:for-each>-->
			</response>
		</xsl:if>
	</xsl:variable>

	<!-- accumulate unique geonames IDs -->
	<xsl:variable name="geonames" as="element()*">
		<places>
			<xsl:for-each
				select="distinct-values(descendant::*[local-name()='geogname'][contains(@xlink:href, 'geonames.org')]/@xlink:href|$rdf/descendant::*[contains(@rdf:resource, 'geonames.org')]/@rdf:resource)">
				<xsl:variable name="geonameId" select="tokenize(., '/')[4]"/>

				<xsl:if test="number($geonameId)">
					<xsl:variable name="geonames_data" as="element()*">
						<results>
							<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
						</results>
					</xsl:variable>
					<xsl:variable name="coordinates" select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>

					<!-- generate AACR2 label -->
					<xsl:variable name="label">
						<xsl:variable name="countryCode" select="$geonames_data//countryCode"/>
						<xsl:variable name="countryName" select="$geonames_data//countryName"/>
						<xsl:variable name="name" select="$geonames_data//name"/>
						<xsl:variable name="adminName1" select="$geonames_data//adminName1"/>
						<xsl:variable name="fcode" select="$geonames_data//fcode"/>
						<!-- set a value equivalent to AACR2 standard for US, AU, CA, and GB.  This equation deviates from AACR2 for Malaysia since standard abbreviations for territories cannot be found -->
						<xsl:value-of
							select="if ($countryCode = 'US' or $countryCode = 'AU' or $countryCode = 'CA') then if ($fcode = 'ADM1') then $name else concat($name, ' (', $abbreviations//country[@code=$countryCode]/place[. = $adminName1]/@abbr, ')') else if ($countryCode= 'GB') then  if ($fcode = 'ADM1') then $name else concat($name, ' (', $adminName1, ')') else if ($fcode = 'PCLI') then $name else concat($name, ' (', $countryName, ')')"
						/>
					</xsl:variable>


					<!-- create facetRegion hierarchy -->
					<xsl:variable name="hierarchy">
						<xsl:value-of select="$geonames_data//countryName"/>
						<xsl:for-each select="$geonames_data//*[starts-with(local-name(), 'adminName')]">
							<xsl:sort select="local-name()"/>
							<xsl:if test="string-length(.) &gt; 0">
								<xsl:text>|</xsl:text>
								<xsl:value-of select="."/>
							</xsl:if>
						</xsl:for-each>
						<xsl:text>|</xsl:text>
						<xsl:value-of select="$geonames_data//name"/>
					</xsl:variable>

					<place id="{.}" label="{$label}" hierarchy="{$hierarchy}">
						<xsl:value-of select="$coordinates"/>
					</place>
				</xsl:if>
			</xsl:for-each>
		</places>
	</xsl:variable>

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

	<xsl:template name="get-ids">
		<xsl:param name="start"/>
		<xsl:param name="end"/>
		<xsl:param name="count"/>

		<xsl:variable name="id-param">
			<xsl:for-each
				select="distinct-values(descendant::*[not(local-name()='typeDesc') and not(local-name()='reference')][contains(@xlink:href, 'nomisma.org')]/@xlink:href | $nudsGroup/descendant::*[not(local-name()='typeDesc') and not(local-name()='object')][contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
				<xsl:if test="position() &gt;= $start and position() &lt;= $end">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position()=$count)">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="rdf_url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
		<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>

		<xsl:if test="$end &lt; $count">
			<xsl:call-template name="get-ids">
				<xsl:with-param name="start" select="$start + $end"/>
				<xsl:with-param name="end" select="($start + 1) * 100"/>
				<xsl:with-param name="count" select="$count"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/">
		<add>
			<xsl:choose>
				<xsl:when test="count(descendant::nuds:nuds) &gt; 0">
					<xsl:call-template name="nuds"/>
				</xsl:when>
				<xsl:when test="count(descendant::nh:nudsHoard) &gt; 0">
					<xsl:call-template name="nudsHoard"/>
				</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</add>
	</xsl:template>
</xsl:stylesheet>
