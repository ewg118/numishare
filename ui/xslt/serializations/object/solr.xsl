<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Modified: April 2020
	Function: This stylesheet reads the incoming object model (nuds or nudsHoard)
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard"
	xmlns:nm="http://nomisma.org/id/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mets="http://www.loc.gov/METS/" xmlns:gml="http://www.opengis.net/gml"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:org="http://www.w3.org/ns/org#" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../nuds/solr.xsl"/>
	<xsl:include href="../nudsHoard/solr.xsl"/>
	<xsl:include href="../tei/solr.xsl"/>
	<xsl:include href="solr-templates.xsl"/>

	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
	<xsl:variable name="request-uri" select="concat('http://localhost:8080/orbeon/numishare/', $collection-name)"/>

	<!-- config variables -->
	<xsl:variable name="geonames-url">http://api.geonames.org</xsl:variable>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="uri_space" select="/content/config/uri_space"/>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="collection-type" select="/content/config/collection_type"/>
	<xsl:variable name="publisher" select="/content/config/template/agencyName"/>
	<xsl:variable name="regionHierarchy" select="boolean(/content/config/facets/facet[text() = 'region_hier'])" as="xs:boolean"/>
	<xsl:variable name="findspotHierarchy" select="boolean(/content/config/facets/facet[text() = 'findspot_hier'])" as="xs:boolean"/>

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


	<!-- get metadata from subtypes -->
	<xsl:variable name="index_subtype_metadata" as="xs:boolean">
		<xsl:value-of select="
				if (/content/config/index_subtype_metadata = 'true') then
					true()
				else
					false()"/>
	</xsl:variable>

	<xsl:variable name="index_subtypes_as_references" as="xs:boolean">
		<xsl:value-of select="
				if (/content/config/index_subtypes_as_references = 'true') then
					true()
				else
					false()"/>
	</xsl:variable>

	<!-- get subtypes -->
	<xsl:variable name="subtypes" as="element()*">
		<xsl:if test="//config/collection_type = 'cointype' and ($index_subtype_metadata = true() or $index_subtypes_as_references = true())">
			<xsl:if test="doc-available(concat($request-uri, '/get_subtypes?identifiers=', encode-for-uri(string-join(descendant::nuds:recordId, '|'))))">
				<xsl:copy-of
					select="document(concat($request-uri, '/get_subtypes?identifiers=', encode-for-uri(string-join(descendant::nuds:recordId, '|'))))/*"/>
			</xsl:if>
		</xsl:if>
	</xsl:variable>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">

			<!-- execute recursive template to call 1 or more API requests for Nomisma URIs in the document or nudsGroup -->
			<xsl:variable name="id-count"
				select="
					count(distinct-values(descendant::*[not(local-name() = 'typeDesc') and not(local-name() = 'reference')][contains(@xlink:href, 'nomisma.org')]/@xlink:href |
					$nudsGroup/descendant::*[not(local-name() = 'typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href))"/>

			<xsl:variable name="id-var" as="element()*">
				<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
					xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
					xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
					xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">
					<xsl:call-template name="get-ids">
						<xsl:with-param name="start">1</xsl:with-param>
						<xsl:with-param name="end">100</xsl:with-param>
						<xsl:with-param name="count" select="$id-count"/>
						<xsl:with-param name="ids"
							select="
								distinct-values(descendant::*[not(local-name() = 'typeDesc') and not(local-name() = 'reference')][contains(@xlink:href, 'nomisma.org')]/@xlink:href |
								$nudsGroup/descendant::*[not(local-name() = 'typeDesc') and not(local-name() = 'object')][contains(@xlink:href, 'nomisma.org')]/@xlink:href | descendant::*[contains(@ref,
								'nomisma.org')]/@ref | descendant::*[contains(@period,
								'nomisma.org')]/@period)"
						/>
					</xsl:call-template>
				</rdf:RDF>
			</xsl:variable>

			<!-- call API only for those org URIs that weren't in the initial API call -->
			<xsl:variable name="org-count"
				select="count(distinct-values($id-var//org:organization/@rdf:resource | $id-var//org:memberOf/@rdf:resource)[not(. = $id-var/*/@rdf:about)])"/>

			<xsl:variable name="org-var" as="element()*">
				<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
					xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
					xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
					xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">
					<xsl:call-template name="get-ids">
						<xsl:with-param name="start">1</xsl:with-param>
						<xsl:with-param name="end">100</xsl:with-param>
						<xsl:with-param name="count" select="$org-count"/>
						<xsl:with-param name="ids"
							select="distinct-values($id-var//org:organization/@rdf:resource | $id-var//org:memberOf/@rdf:resource)[not(. = $id-var/*/@rdf:about)]"
						> </xsl:with-param>
					</xsl:call-template>
				</rdf:RDF>
			</xsl:variable>

			<!-- merge contents of the ID and additional, unique org API calls into the $rdf variable -->
			<xsl:copy-of select="$id-var/*"/>
			<xsl:copy-of select="$org-var/*"/>

			<!-- perform an RDF request for each distinct monogram/symbol URI -->
			<xsl:for-each
				select="
					distinct-values($nudsGroup/descendant::nuds:symbol[contains(@xlink:href, 'http://numismatics.org')]/@xlink:href | $nudsGroup/descendant::nuds:symbol/descendant::tei:g[contains(@ref, 'http://numismatics.org')]/@ref |
					$subtypes/descendant::nuds:symbol[contains(@xlink:href, 'http://numismatics.org')]/@xlink:href | $subtypes/descendant::nuds:symbol/descendant::tei:g[contains(@ref, 'http://numismatics.org')]/@ref)">
				<xsl:variable name="href" select="."/>

				<xsl:if test="doc-available(concat($href, '.rdf'))">
					<xsl:copy-of select="document(concat($href, '.rdf'))/rdf:RDF/*"/>
				</xsl:if>
			</xsl:for-each>
		</rdf:RDF>
	</xsl:variable>

	<!-- Oct 29, 2018: commenting out the indexing of findspots via SPARQL; it is no longer scalable for indexing. Prepare to transition maps page to SPARQL-derived GeoJSON-->

	<!-- accumulate unique geonames IDs -->
	<xsl:variable name="geonames" as="element()*">
		<places>
			<xsl:for-each
				select="
					distinct-values(descendant::*[local-name() = 'geogname'][contains(@xlink:href,
					'geonames.org')]/@xlink:href | $nudsGroup/descendant::*[local-name() = 'geogname'][contains(@xlink:href, 'geonames.org')]/@xlink:href | $rdf/descendant::*[not(local-name() = 'closeMatch')][contains(@rdf:resource,
					'geonames.org')]/@rdf:resource | descendant::*[local-name() = 'subject'][contains(@xlink:href,
					'geonames.org')]/@xlink:href)">

				<!-- commented out: $sparqlResult/descendant::res:binding[@name = 'findspot'][contains(res:uri, 'geonames.org')]/res:uri -->
				<xsl:variable name="geonameId" select="tokenize(., '/')[4]"/>

				<xsl:if test="number($geonameId)">
					<xsl:variable name="geonames_data" as="element()*">
						<xsl:variable name="api"
							select="concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full')"/>

						<results>
							<xsl:if test="doc-available($api)">
								<xsl:copy-of select="document($api)"/>
							</xsl:if>
						</results>
					</xsl:variable>

					<!-- only evaluate if there's a positive response -->
					<xsl:if test="$geonames_data//geonameId = $geonameId">
						<xsl:variable name="coordinates">
							<xsl:if test="$geonames_data//lng castable as xs:decimal and $geonames_data//lat castable as xs:decimal">
								<xsl:value-of select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>
							</xsl:if>
						</xsl:variable>

						<!-- generate AACR2 label -->
						<xsl:variable name="label">
							<xsl:variable name="countryCode" select="$geonames_data//countryCode[1]"/>
							<xsl:variable name="countryName" select="$geonames_data//countryName[1]"/>
							<xsl:variable name="name" select="$geonames_data//name[1]"/>
							<xsl:variable name="adminName1" select="$geonames_data//adminName1[1]"/>
							<xsl:variable name="fcode" select="$geonames_data//fcode[1]"/>
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
						</xsl:variable>

						<place id="{.}" label="{$label}">
							<xsl:if test="$regionHierarchy = true() or $findspotHierarchy = true()">
								<xsl:variable name="geonames_hier" as="element()*">
									<results>
										<xsl:copy-of
											select="document(concat($geonames-url, '/hierarchy?geonameId=', $geonameId, '&amp;username=', $geonames_api_key))"/>
									</results>
								</xsl:variable>
								<!-- create facetRegion hierarchy -->
								<xsl:variable name="hierarchy">
									<xsl:for-each select="$geonames_hier//geoname[position() &gt;= 3]">
										<xsl:value-of select="concat(geonameId, '/', name)"/>
										<xsl:if test="not(position() = last())">
											<xsl:text>|</xsl:text>
										</xsl:if>
									</xsl:for-each>
								</xsl:variable>

								<xsl:attribute name="hierarchy" select="$hierarchy"/>
							</xsl:if>

							<xsl:value-of select="$coordinates"/>
						</place>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</places>
	</xsl:variable>

	<xsl:variable name="regions" as="element()*">
		<node>
			<xsl:if test="$regionHierarchy = true()">
				<xsl:variable name="mints"
					select="distinct-values($rdf//nmo:Mint/@rdf:about[contains(., 'nomisma.org')] | $rdf//nmo:Region/@rdf:about[contains(., 'nomisma.org')])"/>
				<xsl:variable name="identifiers" select="replace(string-join($mints, '|'), 'http://nomisma.org/id/', '')"/>

				<xsl:copy-of select="document(concat('http://nomisma.org/apis/regionHierarchy?identifiers=', encode-for-uri($identifiers)))"/>
			</xsl:if>
		</node>
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
				<place abbr="Man.">Manitoba</place>
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
		<xsl:param name="ids"/>

		<xsl:variable name="id-param">
			<xsl:for-each select="$ids">
				<xsl:if test="position() &gt;= $start and position() &lt;= $end">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position() = $count)">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="api-url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
		<xsl:copy-of select="document($api-url)/rdf:RDF/*"/>

		<xsl:if test="$end &lt; $count">
			<xsl:call-template name="get-ids">
				<xsl:with-param name="start" select="$start + $end"/>
				<xsl:with-param name="end" select="($start + 1) * 100"/>
				<xsl:with-param name="count" select="$count"/>
				<xsl:with-param name="ids" select="$ids"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/">
		<add>
			<!-- templates should be called for each if different sorts of files are stored in the same collection -->

			<xsl:if test="count(descendant::nuds:nuds) &gt; 0">
				<xsl:call-template name="nuds"/>
			</xsl:if>

			<xsl:if test="count(descendant::tei:TEI) &gt; 0">
				<xsl:call-template name="tei"/>
			</xsl:if>

			<xsl:if test="count(descendant::nh:nudsHoard) &gt; 0">
				<xsl:call-template name="nudsHoard"/>
			</xsl:if>
		</add>
	</xsl:template>
</xsl:stylesheet>
