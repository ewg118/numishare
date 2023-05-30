<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nm="http://nomisma.org/id/"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:gml="http://www.opengis.net/gml" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:digest="org.apache.commons.codec.digest.DigestUtils" exclude-result-prefixes="#all">

	<xsl:template name="nuds">
		<!-- create default document -->
		<xsl:apply-templates select="//nuds:nuds">
			<xsl:with-param name="lang"/>
		</xsl:apply-templates>

		<!-- create documents for each additional activated language -->
		<xsl:for-each select="//config/descendant::language[@enabled = 'true']">
			<xsl:apply-templates select="//nuds:nuds">
				<xsl:with-param name="lang" select="@code"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<xsl:param name="lang"/>
		<xsl:variable name="id" select="nuds:control/nuds:recordId"/>
		<doc>
			<field name="id">
				<xsl:choose>
					<xsl:when test="string($lang)">
						<xsl:value-of select="concat($id, '-', $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$id"/>
					</xsl:otherwise>
				</xsl:choose>
			</field>
			<field name="recordId">
				<xsl:value-of select="$id"/>
			</field>
			<xsl:if test="string($lang)">
				<field name="lang">
					<xsl:value-of select="$lang"/>
				</field>
			</xsl:if>

			<xsl:if test="@recordType = 'conceptual'">
				<xsl:variable name="uri_space" select="//config/uri_space"/>

				<!-- get the sort id for coin type records, used for ordering by type number -->
				<xsl:choose>
					<xsl:when test="nuds:control/nuds:otherRecordId[@localType = 'sortId']">
						<field name="sortid">
							<xsl:value-of
								select="nuds:control/nuds:otherRecordId[@localType = 'sortId']"/>
						</field>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="sortid">
							<xsl:with-param name="collection-name" select="$collection-name"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>


				<!-- index the type number for specific query -->
				<!-- if there is a typeNumber in the control: -->
				<xsl:choose>
					<xsl:when test="nuds:control/nuds:otherRecordId[@localType = 'typeNumber']">
						<field name="typeNumber">
							<xsl:value-of
								select="nuds:control/nuds:otherRecordId[@localType = 'typeNumber']"
							/>
						</field>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="typeNumber">
							<xsl:with-param name="collection-name" select="$collection-name"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:for-each select="nuds:control/nuds:otherRecordId[@semantic = 'skos:broader']">
					<field name="parentType_uri">
						<xsl:value-of select="concat($uri_space, .)"/>
					</field>
				</xsl:for-each>

				<xsl:choose>
					<xsl:when test="$collection-type = 'cointype'">
						<field name="typeSeries">
							<xsl:value-of select="
									if (descendant::nuds:typeSeries/@xlink:href) then
										descendant::nuds:typeSeries/@xlink:href
									else
										//config/type_series"/>
						</field>
					</xsl:when>
					<xsl:when test="$collection-type = 'die'">
						<field name="dieSeries">
							<xsl:value-of select="//config/die_series"/>
						</field>

						<!-- list associated coin types -->
						<xsl:apply-templates
							select="$die-types//group[identifier = $id]/descendant::res:result"
							mode="die-types"/>
					</xsl:when>
				</xsl:choose>


				<field name="uri_space">
					<xsl:value-of select="$uri_space"/>
				</field>
			</xsl:if>

			<field name="collection-name">
				<xsl:value-of select="$collection-name"/>
			</field>
			<field name="recordType">
				<xsl:value-of select="@recordType"/>
			</field>
			<xsl:if test="nuds:control/nuds:publicationStatus = 'approvedSubtype'">
				<field name="subtype">true</field>
			</xsl:if>
			<field name="publisher_display">
				<xsl:value-of select="$publisher"/>
			</field>
			<field name="timestamp">
				<xsl:choose>
					<xsl:when
						test="descendant::*:maintenanceEvent[last()]/*:eventDateTime/@standardDateTime castable as xs:dateTime">
						<xsl:value-of
							select="format-dateTime(xs:dateTime(descendant::*:maintenanceEvent[last()]/*:eventDateTime/@standardDateTime), '[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01]Z')"
						/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01]Z')"
						/>
					</xsl:otherwise>
				</xsl:choose>
			</field>

			<xsl:apply-templates select="nuds:control/nuds:rightsStmt"/>

			<!-- if there are any uncertain type attributions, flag this in a solr field -->
			<xsl:if
				test="descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem'][string(@xlink:href)][@certainty]">
				<field name="typeUncertain">true</field>
			</xsl:if>

			<!-- insert coin type facets and URIs -->
			<xsl:for-each
				select="descendant::nuds:typeDesc[string(@xlink:href)] | descendant::nuds:undertypeDesc[string(@xlink:href)] | descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem'][string(@xlink:href)]">
				<xsl:variable name="href" select="@xlink:href"/>
				<field name="coinType_uri">
					<xsl:value-of select="$href"/>
				</field>
				<field name="coinType_facet">
					<xsl:choose>
						<xsl:when test="local-name() = 'reference'">
							<xsl:choose>
								<xsl:when test="@xlink:title">
									<xsl:value-of select="@xlink:title"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="tei:title">
											<xsl:value-of select="normalize-space(tei:title)"/>
											<xsl:if test="string(tei:idno)">
												<xsl:text> </xsl:text>
												<xsl:value-of select="normalize-space(tei:idno)"/>
											</xsl:if>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="normalize-space(.)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="$nudsGroup//object[@xlink:href = $href]/descendant::nuds:title"
							/>
						</xsl:otherwise>
					</xsl:choose>
				</field>
			</xsl:for-each>

			<!-- insert the coinType_facet for the conceptual record -->
			<!--<xsl:if test="@recordType='conceptual'">
				<field name="coinType_facet">
					<xsl:value-of select="descendant::nuds:title"/>
				</field>
			</xsl:if>-->


			<xsl:apply-templates select="nuds:descMeta">
				<xsl:with-param name="lang" select="$lang"/>
				<xsl:with-param name="id" select="$id"/>
			</xsl:apply-templates>


			<!-- if there are subtypes, extract the legend and type description or symbols, if missing from parent record (only extract information to index for type-level type)-->
			<xsl:if
				test="not(nuds:control/nuds:otherRecordId[@semantic = 'skos:broader']) and ($index_subtype_metadata = true() or $index_subtypes_as_references = true())">

				<!-- index subtype metadata -->
				<xsl:if test="$index_subtype_metadata = true()">

					<xsl:variable name="typeDesc" as="element()*">
						<xsl:copy-of select="descendant::nuds:typeDesc"/>
					</xsl:variable>

					<xsl:variable name="hasReferences" select="boolean(descendant::nuds:reference)"
						as="xs:boolean"/>


					<xsl:if test="count($subtypes//type[@recordId = $id]/subtype) &gt; 0">

						<xsl:for-each select="('obverse', 'reverse')">
							<xsl:variable name="side" select="."/>
							<xsl:variable name="sideAbbr" select="substring($side, 1, 3)"/>

							<xsl:variable name="hasTypes"
								select="boolean($typeDesc/*[local-name() = $side]/nuds:type)"
								as="xs:boolean"/>
							<xsl:variable name="hasLegends"
								select="boolean($typeDesc/*[local-name() = $side]/nuds:legend)"
								as="xs:boolean"/>
							<xsl:variable name="hasSymbols"
								select="boolean($typeDesc/*[local-name() = $side]/nuds:symbol)"
								as="xs:boolean"/>
							<xsl:variable name="hasDies"
								select="boolean($typeDesc/*[local-name() = $side]/nuds:die)"
								as="xs:boolean"/>

							<!-- type descriptions -->
							<xsl:if
								test="$hasTypes = false() and $subtypes//type[@recordId = $id]/subtype/descendant::*[local-name() = $side]/nuds:type/nuds:description">
								<xsl:variable name="pieces" as="item()*">
									<xsl:for-each select="
											distinct-values($subtypes//type[@recordId = $id]/subtype/descendant::*[local-name() = $side]/nuds:type/nuds:description[if (string($lang)) then
												@xml:lang = $lang
											else
												@xml:lang = 'en'])">
										<xsl:value-of select="."/>
									</xsl:for-each>
								</xsl:variable>

								<field name="{$sideAbbr}_type_display">
									<xsl:value-of select="string-join($pieces, ' | ')"/>
								</field>

								<xsl:for-each select="$pieces">
									<field name="{$sideAbbr}_type_text">
										<xsl:value-of select="."/>
									</field>
								</xsl:for-each>

							</xsl:if>

							<!-- legend -->
							<xsl:if
								test="$hasLegends = false() and $subtypes//type[@recordId = $id]/subtype/descendant::*[local-name() = $side]/nuds:legend">
								<xsl:variable name="pieces" as="item()*">
									<legends>
										<xsl:for-each
											select="$subtypes//type[@recordId = $id]/subtype/descendant::*[local-name() = $side]/nuds:legend">
											<xsl:if
												test="not(self::node() = preceding::nuds:legend)">
												<xsl:copy-of select="self::node()"/>
											</xsl:if>
										</xsl:for-each>
									</legends>

								</xsl:variable>

								<field name="{$sideAbbr}_leg_display">
									<xsl:for-each select="$pieces//nuds:legend">
										<xsl:choose>
											<xsl:when test="tei:div[@type = 'edition']/tei:ab">
												<xsl:apply-templates
												select="tei:div[@type = 'edition']/tei:ab"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="."/>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:if test="not(position() = last())">
											<xsl:text> | </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</field>

								<xsl:for-each select="$pieces//nuds:legend">
									<field name="{$sideAbbr}_leg_text">
										<xsl:value-of select="."/>
									</field>
								</xsl:for-each>
							</xsl:if>

							<!-- symbols -->
							<xsl:if
								test="$hasSymbols = false() and $subtypes//type[@recordId = $id]/subtype/descendant::*[local-name() = $side]/nuds:symbol">

								<xsl:apply-templates
									select="$subtypes//type[@recordId = $id]/subtype/descendant::*[local-name() = $side]/nuds:symbol">
									<xsl:with-param name="side" select="substring($side, 1, 3)"/>
								</xsl:apply-templates>
							</xsl:if>

							<!-- die IDs -->
							<!--<xsl:if test="not($typeDesc/*[local-name() = $side]/nuds:die) and count($subtypes//type[@recordId = $id]/subtype) &gt; 0"> </xsl:if>-->

							<xsl:if
								test="$hasDies = false() and $subtypes//type[@recordId = $id]/subtype/descendant::*[local-name() = $side]/nuds:die">
								<xsl:apply-templates
									select="$subtypes//type[@recordId = $id]/subtype/descendant::*[local-name() = $side]/nuds:die">
									<xsl:with-param name="side" select="substring($side, 1, 3)"/>
								</xsl:apply-templates>
							</xsl:if>

						</xsl:for-each>

						<!-- index type references for the subtypes -->
						<xsl:variable name="refs" as="element()*">
							<refs>
								<xsl:for-each
									select="$subtypes//type[@recordId = $id]/subtype/descendant::nuds:refDesc/nuds:reference">
									<ref>
										<xsl:call-template name="get_ref"/>
									</ref>
								</xsl:for-each>
							</refs>
						</xsl:variable>

						<xsl:for-each select="$refs//ref[string-length(normalize-space(.)) &gt; 0]">
							<xsl:sort order="ascending"/>



							<field name="reference_facet">
								<xsl:value-of select="."/>
							</field>
							<field name="reference_text">
								<xsl:value-of select="."/>
							</field>
							<xsl:if test="position() = 1 and $hasReferences = false()">
								<field name="reference_min">
									<xsl:value-of select="."/>
								</field>
							</xsl:if>
							<xsl:if test="position() = last() and $hasReferences = false()">
								<field name="reference_max">
									<xsl:value-of select="."/>
								</field>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
				</xsl:if>

				<!-- for certain types of collections where a new ID system supplants an older ID system, where the old IDs are treated as subtypes but need to be searchable -->
				<xsl:if test="$index_subtypes_as_references = true()">

					<xsl:for-each select="
							$subtypes//type[@recordId = $id]/subtype/descendant::nuds:title[if (string($lang)) then
								@xml:lang = $lang
							else
								@xml:lang = 'en']">

						<field name="reference_facet">
							<xsl:value-of select="."/>
						</field>
						<field name="reference_text">
							<xsl:value-of select="."/>
						</field>

					</xsl:for-each>
				</xsl:if>


				<!-- subtype fulltext -->
				<xsl:if test="count($subtypes//type[@recordId = $id]/subtype) &gt; 0">
					<field name="fulltext">
						<xsl:for-each
							select="$subtypes//type[@recordId = $id]/subtype/descendant::nuds:descMeta/descendant-or-self::text()">
							<xsl:value-of select="normalize-space(.)"/>
							<xsl:text> </xsl:text>
						</xsl:for-each>
					</field>
				</xsl:if>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="string($sparql_endpoint) and @recordType = 'conceptual'">
					<!-- get findspots only for coin type records -->
					<!-- Oct. 29, 2018: begin transition to SPARQL-generated maps -->
					<!--<xsl:apply-templates select="$sparqlResult/descendant::res:group[@id = $id]/res:result"/>-->
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="nuds:digRep"/>
				</xsl:otherwise>
			</xsl:choose>

			<!-- text -->
			<field name="fulltext">
				<xsl:value-of select="nuds:control/nuds:recordId"/>
				<xsl:text> </xsl:text>
				<xsl:for-each select="nuds:descMeta/descendant-or-self::text()">
					<xsl:value-of select="normalize-space(.)"/>
					<xsl:text> </xsl:text>
				</xsl:for-each>

				<!-- get all labels -->
				<xsl:call-template name="alternativeLabels">
					<xsl:with-param name="lang" select="
							if (string($lang)) then
								$lang
							else
								'en'"/>
					<xsl:with-param name="typeDesc" as="node()*">
						<xsl:choose>
							<xsl:when test="descendant::nuds:typeDesc[string(@xlink:href)]">
								<xsl:variable name="href"
									select="descendant::nuds:typeDesc/@xlink:href"/>

								<xsl:copy-of
									select="$nudsGroup//object[@xlink:href = $href]//nuds:typeDesc"
								/>
							</xsl:when>
							<xsl:when
								test="descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem'][string(@xlink:href)]">
								<xsl:variable name="href"
									select="descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem']/@xlink:href"/>

								<xsl:copy-of
									select="$nudsGroup//object[@xlink:href = $href]//nuds:typeDesc"
								/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="descendant::nuds:typeDesc"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</field>
		</doc>
	</xsl:template>

	<xsl:template match="nuds:rightsStmt">
		<xsl:apply-templates select="nuds:rights[@xlink:href] | nuds:license[@xlink:href]"/>
	</xsl:template>

	<xsl:template match="nuds:rights | nuds:license">
		<field name="{if (@for) then concat(@for, 'License') else local-name()}_uri">
			<xsl:value-of select="@xlink:href"/>
		</field>
	</xsl:template>

	<xsl:template match="nuds:descMeta">
		<xsl:param name="lang"/>
		<xsl:param name="id"/>

		<xsl:variable name="recordType">
			<xsl:value-of select="parent::nuds:nuds/@recordType"/>
		</xsl:variable>

		<field name="title_display">
			<xsl:choose>
				<xsl:when test="nuds:title[@xml:lang = $lang]">
					<xsl:value-of select="nuds:title[@xml:lang = $lang]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="nuds:title[@xml:lang = 'en']">
							<xsl:value-of select="nuds:title[@xml:lang = 'en']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="nuds:title[1]"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</field>
		<field name="title_text">
			<xsl:choose>
				<xsl:when test="nuds:title[@xml:lang = $lang]">
					<xsl:value-of select="nuds:title[@xml:lang = $lang]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="nuds:title[@xml:lang = 'en']">
							<xsl:value-of select="nuds:title[@xml:lang = 'en']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="nuds:title[1]"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</field>

		<xsl:apply-templates select="nuds:subjectSet"/>
		<xsl:apply-templates select="nuds:physDesc">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>


		<!-- ***** typeDesc and/or reference typology indexing ***** -->
		<xsl:variable name="typologies" as="element()*">
			<typologies>
				<xsl:choose>
					<!-- apply template for immediate, explicit typeDesc for coin type records -->
					<xsl:when test="$recordType = 'conceptual'">
						<xsl:copy-of select="nuds:typeDesc"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="nuds:typeDesc[not(@xlink:href)]"/>

						<xsl:for-each
							select="distinct-values(nuds:typeDesc[@xlink:href]/@xlink:href | descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem'][@xlink:href]/@xlink:href)">
							<xsl:variable name="uri" select="."/>

							<xsl:copy-of
								select="$nudsGroup/descendant::object[@xlink:href = $uri]/descendant::nuds:typeDesc"
							/>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</typologies>
		</xsl:variable>

		<!-- process typeDesc(s) -->
		<xsl:apply-templates select="$typologies//nuds:typeDesc">
			<xsl:with-param name="recordType" select="$recordType"/>
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>

		<!-- evaluate the dates within the group of typologies to extract the earliest and latest possible dates -->
		<xsl:call-template name="parse_dates">
			<xsl:with-param name="typologies" select="$typologies"/>
		</xsl:call-template>

		<!-- get sort fields from within the associated $typologies -->
		<xsl:call-template name="get_coin_sort_fields">
			<xsl:with-param name="typologies" select="$typologies"/>
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:call-template>

		<xsl:apply-templates select="nuds:adminDesc"/>
		<xsl:apply-templates select="nuds:refDesc"/>
		<xsl:apply-templates select="nuds:findspotDesc">
			<xsl:with-param name="objectURI" select="
					if (string($uri_space)) then
						concat($uri_space, $id)
					else
						concat($url, 'id/', $id)"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="nuds:findspotDesc">
		<xsl:param name="objectURI"/>

		<xsl:choose>
			<xsl:when test="string(@xlink:href)">
				<xsl:variable name="href" select="@xlink:href"/>

				<!-- the @xlink:href of a findspotDesc is presumed to a a hoard URI -->
				<field name="hoard_uri">
					<xsl:value-of select="$href"/>
				</field>

				<xsl:call-template name="parse_findspot_uri">
					<xsl:with-param name="href" select="$href"/>
					<xsl:with-param name="label"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="nuds:findspot">
					<xsl:with-param name="objectURI" select="$objectURI"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:apply-templates select="nuds:hoard | nuds:discovery"/>

	</xsl:template>
	
	<xsl:template match="nuds:findspot">
		<xsl:param name="objectURI"/>
		
		<xsl:if test="nuds:description">
			<field name="context_facet">
				<xsl:value-of select="nuds:description"/>
			</field>
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="nuds:fallsWithin/nuds:geogname/@xlink:href">
				<xsl:call-template name="parse_findspot_uri">
					<xsl:with-param name="href"
						select="nuds:fallsWithin/nuds:geogname/@xlink:href"/>
					<xsl:with-param name="label"
						select="nuds:fallsWithin/nuds:geogname"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="nuds:fallsWithin/gml:location/gml:Point">
						<xsl:apply-templates select="self::node()" mode="parse-gml">
							<xsl:with-param name="objectURI" select="$objectURI"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="gml:location">
						<xsl:apply-templates select="self::node()" mode="parse-gml">
							<xsl:with-param name="objectURI" select="$objectURI"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<field name="findspot_facet">
							<xsl:value-of
								select="nuds:fallsWithin/nuds:geogname[@xlink:role = 'findspot']"
							/>
						</field>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:apply-templates select="nuds:geogname[@xlink:role = 'stratigraphicUnit'] | nuds:geogname[@xlink:role='area']|nuds:spatialContext"/>
	</xsl:template>

	<xsl:template match="nuds:hoard">
		<field name="hoard_facet">
			<xsl:value-of select="normalize-space(.)"/>
		</field>

		<xsl:if test="@xlink:href">
			<field name="hoard_uri">
				<xsl:value-of select="@xlink:href"/>
			</field>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="nuds:discovery">
		<xsl:apply-templates select="nuds:date | nuds:project/nuds:title" mode="discovery"/>
	</xsl:template>
	
	<xsl:template match="nuds:date"  mode="discovery">
		
		<field name="discoveryDate_display">
			<xsl:value-of select="."/>
		</field>
		
		<xsl:if test="@standardDate castable as xs:integer">
			<field name="discoveryDate_num">
				<xsl:value-of select="@standardDate"/>
			</field>
			<field name="discoveryDate_minint">
				<xsl:value-of select="@standardDate"/>
			</field>
			<field name="discoveryDate_maxint">
				<xsl:value-of select="@standardDate"/>
			</field>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="nuds:title" mode="discovery">
		<field name="projectName_facet">
			<xsl:value-of select="."/>
		</field>
		<field name="projectName_text">
			<xsl:value-of select="."/>
		</field>
	</xsl:template>

	<xsl:template match="nuds:findspot" mode="parse-gml">
		<xsl:param name="objectURI"/>

		<xsl:choose>
			<xsl:when test="nuds:fallsWithin">
				<xsl:variable name="label" select="nuds:fallsWithin/nuds:geogname"/>
				<xsl:variable name="uri" select="
						if (nuds:fallsWithin/nuds:geogname/@xlink:href) then
							nuds:fallsWithin/nuds:geogname/@xlink:href
						else
							concat($objectURI, '#findspot')"> </xsl:variable>
				<xsl:variable name="coords"
					select="tokenize(nuds:fallsWithin/gml:location/gml:Point/gml:coordinates, ',')"/>

				<field name="findspot_facet">
					<xsl:value-of select="$label"/>
				</field>

				<field name="findspot_geo">
					<xsl:value-of select="$label"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="$uri"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of
						select="concat(normalize-space($coords[2]), ',', normalize-space($coords[1]))"
					/>
				</field>
			</xsl:when>
			<xsl:when test="gml:location">
				<xsl:variable name="label" select="nuds:geogname"/>
				<xsl:variable name="uri" select="concat($objectURI, '#findspot')"/> 				
				<xsl:variable name="coords"
					select="tokenize(gml:location/gml:Point/gml:pos, ' ')"/>
				
				<field name="findspot_facet">
					<xsl:value-of select="$label"/>
				</field>
				
				<field name="findspot_geo">
					<xsl:value-of select="$label"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="$uri"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of
						select="concat(normalize-space($coords[2]), ',', normalize-space($coords[1]))"
					/>
				</field>
			</xsl:when>
		</xsl:choose>


	</xsl:template>

	<xsl:template name="parse_findspot_uri">
		<xsl:param name="href"/>
		<xsl:param name="label"/>

		<xsl:choose>
			<xsl:when test="contains($href, 'nomisma.org')">
				<xsl:variable name="label">
					<xsl:choose>
						<xsl:when test="string($rdf/*[@rdf:about = $href]/skos:prefLabel)">
							<xsl:value-of select="$rdf/*[@rdf:about = $href]/skos:prefLabel"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$href"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<field name="findspot_facet">
					<xsl:value-of select="$label"/>
				</field>

				<xsl:if test="$rdf/*[@rdf:about = $href]/nmo:hasFindspot">
					<xsl:variable name="findspot_uri"
						select="$rdf/*[@rdf:about = $href]/nmo:hasFindspot/@rdf:resource"/>

					<field name="findspot_geo">
						<xsl:value-of select="$label"/>
						<xsl:text>|</xsl:text>
						<xsl:value-of select="$findspot_uri"/>
						<xsl:text>|</xsl:text>
						<xsl:value-of
							select="concat($rdf/*[@rdf:about = $findspot_uri]/geo:long, ',', $rdf/*[@rdf:about = $findspot_uri]/geo:lat)"
						/>
					</field>

					<field name="findspot_uri">
						<xsl:value-of select="$findspot_uri"/>
					</field>

					<!-- if the findspot URI is from geonames, then insert geographic hierarchy -->
					<xsl:if test="contains($findspot_uri, 'geonames.org')">
						<xsl:variable name="geonamesUri" select="$findspot_uri"/>


						<!-- insert hierarchical facets -->
						<xsl:variable name="hierarchy_pieces"
							select="tokenize($geonames//place[@id = $geonamesUri]/@hierarchy, '\|')"/>
						<xsl:variable name="count" select="count($hierarchy_pieces)"/>

						<xsl:for-each select="$hierarchy_pieces">
							<xsl:variable name="position" select="position()"/>

							<xsl:choose>
								<xsl:when test="$position = 1">
									<field name="findspot_hier">
										<xsl:value-of
											select="concat('L', position(), '|', substring-after(., '/'), '/', substring-before(., '/'))"
										/>
									</field>
								</xsl:when>
								<xsl:otherwise>
									<field name="findspot_hier">
										<xsl:value-of
											select="concat(substring-before($hierarchy_pieces[$position - 1], '/'), '|', substring-after(., '/'), '/', substring-before(., '/'))"
										/>
									</field>
								</xsl:otherwise>
							</xsl:choose>

							<field name="findspot_text">
								<xsl:value-of select="substring-after(., '/')"/>
							</field>
						</xsl:for-each>
					</xsl:if>
				</xsl:if>
			</xsl:when>
			<xsl:when test="contains($href, 'geonames.org')">
				<field name="findspot_facet">
					<xsl:value-of select="$label"/>
				</field>
				<field name="findspot_uri">
					<xsl:value-of select="$href"/>
				</field>
				<field name="findspot_geo">
					<xsl:value-of select="$label"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="$href"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="$geonames//place[@id = $href]"/>
				</field>

				<xsl:if test="$regionHierarchy = true()">
					<!-- insert hierarchical facets -->
					<xsl:variable name="hierarchy_pieces"
						select="tokenize($geonames//place[@id = $href]/@hierarchy, '\|')"/>
					<xsl:variable name="count" select="count($hierarchy_pieces)"/>

					<xsl:for-each select="$hierarchy_pieces">
						<xsl:variable name="position" select="position()"/>

						<xsl:choose>
							<xsl:when test="$position = 1">
								<field name="findspot_hier">
									<xsl:value-of
										select="concat('L', position(), '|', substring-after(., '/'), '/', substring-before(., '/'))"
									/>
								</field>
							</xsl:when>
							<xsl:otherwise>
								<field name="findspot_hier">
									<xsl:value-of
										select="concat(substring-before($hierarchy_pieces[$position - 1], '/'), '|', substring-after(., '/'), '/', substring-before(., '/'))"
									/>
								</field>
							</xsl:otherwise>
						</xsl:choose>

						<field name="findspot_text">
							<xsl:value-of select="substring-after(., '/')"/>
						</field>
					</xsl:for-each>
				</xsl:if>
			</xsl:when>
			<xsl:when test="contains($href, 'wikidata.org')">
				<field name="findspot_facet">
					<xsl:value-of select="$label"/>
				</field>
				<field name="findspot_uri">
					<xsl:value-of select="$href"/>
				</field>
				<xsl:if test="nuds:findspot/nuds:fallsWithin/gml:location/gml:Point">
					<field name="findspot_geo">
						<xsl:value-of select="$label"/>
						<xsl:text>|</xsl:text>
						<xsl:value-of select="$href"/>
						<xsl:text>|</xsl:text>
						<xsl:value-of
							select="nuds:findspot/nuds:fallsWithin/gml:location/gml:Point/gml:coordinates"
						/>
					</field>
				</xsl:if>

			</xsl:when>
		</xsl:choose>
	</xsl:template>



	<xsl:template match="nuds:digRep">
		<xsl:apply-templates select="mets:fileSec"/>
	</xsl:template>

	<xsl:template match="mets:fileSec">

		<!-- handle standard photographs -->
		<xsl:for-each
			select="mets:fileGrp[@USE = 'obverse' or @USE = 'reverse' or @USE = 'combined']">
			<xsl:variable name="side" select="substring(@USE, 1, 3)"/>

			<xsl:choose>
				<xsl:when test="count(mets:file) = 1 and mets:file[@USE = 'iiif']">
					<field name="iiif_{$side}">
						<xsl:value-of select="mets:file/mets:FLocat/@xlink:href"/>
					</field>
					<field name="thumbnail_{$side}">
						<xsl:value-of
							select="concat(mets:file/mets:FLocat/@xlink:href, '/full/,120/0/default.jpg')"
						/>
					</field>
					<field name="reference_{$side}">
						<xsl:value-of
							select="concat(mets:file/mets:FLocat/@xlink:href, '/full/400,/0/default.jpg')"
						/>
					</field>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each
						select="mets:file[@USE = 'iiif' or @USE = 'archive' or @USE = 'thumbnail' or @USE = 'reference']">
						<field name="{@USE}_{$side}">
							<xsl:value-of select="mets:FLocat/@xlink:href"/>
						</field>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:for-each>

		<!-- otherwise, apply a template to the first fileGrp for a card and index the recto of the first file -->
		<xsl:apply-templates select="mets:fileGrp[@USE = 'card'][1]/mets:fileGrp[@USE = 'recto']"/>

		<field name="imagesavailable">true</field>
	</xsl:template>

	<xsl:template match="mets:fileGrp[@USE = 'recto']">
		<xsl:choose>
			<xsl:when test="count(mets:file) = 1 and mets:file[@USE = 'iiif']">
				<field name="iiif_com">
					<xsl:value-of select="mets:file/mets:FLocat/@xlink:href"/>
				</field>
				<field name="thumbnail_com">
					<xsl:value-of
						select="concat(mets:file/mets:FLocat/@xlink:href, '/full/,120/0/default.jpg')"
					/>
				</field>
				<field name="reference_com">
					<xsl:value-of
						select="concat(mets:file/mets:FLocat/@xlink:href, '/full/400,/0/default.jpg')"
					/>
				</field>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each
					select="mets:file[@USE = 'iiif' or @USE = 'archive' or @USE = 'thumbnail' or @USE = 'reference']">
					<field name="{@USE}_com">
						<xsl:value-of select="mets:FLocat/@xlink:href"/>
					</field>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:physDesc">
		<xsl:param name="lang"/>
		
		<xsl:apply-templates select="nuds:axis"/>
		<xsl:apply-templates select="nuds:measurementsSet"/>
		<xsl:apply-templates select="nuds:conservationState">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>
		<xsl:for-each select="descendant::nuds:grade">
			<field name="grade_facet">
				<xsl:value-of select="."/>
			</field>
		</xsl:for-each>

		<!-- dateOnObject -->
		<xsl:for-each select="nuds:dateOnObject/*[string(@standardDate)]/@standardDate">
			<xsl:sort order="ascending"/>
			<field name="dob_num">
				<xsl:value-of select="."/>
			</field>
			<!-- add min and max -->
			<xsl:if test="position() = 1">
				<field name="dob_min">
					<xsl:value-of select="."/>
				</field>
			</xsl:if>
			<xsl:if test="position() = last()">
				<field name="dob_max">
					<xsl:value-of select="."/>
				</field>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nuds:conservationState">
		<xsl:param name="lang"/>
		
		<xsl:apply-templates
			select="descendant::nuds:secondaryTreatment[string(.) or string(@xlink:href)] | descendant::nuds:condition[string(.) or string(@xlink:href)] | descendant::nuds:wear[string(.) or string(@xlink:href)]"
		>
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="nuds:adminDesc">
		<xsl:for-each select="nuds:collection | nuds:repository | nuds:owner | nuds:department">
			<field name="{local-name()}_facet">
				<xsl:value-of select="normalize-space(.)"/>
			</field>
			<xsl:if test="string(@xlink:href)">
				<field name="{local-name()}_uri">
					<xsl:value-of select="@xlink:href"/>
				</field>
			</xsl:if>
		</xsl:for-each>

		<xsl:apply-templates select="nuds:identifier"/>

		<xsl:apply-templates select="nuds:provenance/nuds:chronList/nuds:chronItem"/>
	</xsl:template>

	<xsl:template match="nuds:chronItem">
		<xsl:apply-templates select="nuds:acquiredFrom | nuds:previousColl"/>
	</xsl:template>

	<xsl:template match="nuds:acquiredFrom | nuds:previousColl">
		<field name="provenance_text">
			<xsl:value-of select="
					if (nuds:saleCatalog) then
						normalize-space(nuds:saleCatalog)
					else
						normalize-space(.)"/>
		</field>

		<field name="provenance_facet">
			<xsl:value-of select="
					if (nuds:saleCatalog) then
						normalize-space(nuds:saleCatalog)
					else
						normalize-space(.)"/>
		</field>

		<field name="source_text">
			<xsl:value-of select="
					if (nuds:saleCatalog) then
						normalize-space(nuds:saleCatalog)
					else
						normalize-space(.)"/>
		</field>

		<field name="source_facet">
			<xsl:value-of select="
					if (nuds:saleCatalog) then
						normalize-space(nuds:saleCatalog)
					else
						normalize-space(.)"/>
		</field>
	</xsl:template>

	<xsl:template match="nuds:identifier">
		<field name="identifier_text">
			<xsl:value-of select="normalize-space(.)"/>
		</field>
	</xsl:template>

	<xsl:template match="nuds:measurementsSet">
		<xsl:for-each select="*[not(self::nuds:specificGravity)]">
			<xsl:if test="number(.)">
				<field name="{local-name()}_num">
					<xsl:value-of select="normalize-space(.)"/>
				</field>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nuds:axis">
		<xsl:if test="number(.)">
			<field name="axis_num">
				<xsl:value-of select="."/>
			</field>
		</xsl:if>
	</xsl:template>

	<!-- ********** SERIALIZE SPARQL RESULTS FOR FINDSPOTS INTO SOLR FIELDS ********** -->
	<!-- As of October 2018, this feature has been commented out since it is too difficult to maintain in Solr indexing at scale. The map feature
		for coin type corpora published in Numishare will eventually transition to SPARQL for both mint and findspot distribution -->
	<xsl:template match="res:result">
		<xsl:variable name="title" select="
				if (string(res:binding[@name = 'findspotLabel']/res:literal)) then
					res:binding[@name = 'findspotLabel']/res:literal
				else
					res:binding[@name = 'findspot']/res:uri"/>
		<xsl:variable name="uri" select="res:binding[@name = 'findspot']/res:uri"/>

		<xsl:if test="string(res:binding[@name = 'findspotLabel']/res:literal)">
			<field name="findspot_facet">
				<xsl:value-of select="$title"/>
			</field>
		</xsl:if>
		<xsl:if
			test="res:binding[@name = 'long']/res:literal and res:binding[@name = 'lat']/res:literal">
			<field name="findspot_uri">
				<xsl:value-of select="$uri"/>
			</field>
			<field name="findspot_geo">
				<xsl:value-of select="$title"/>
				<xsl:text>|</xsl:text>
				<xsl:value-of select="$uri"/>
				<xsl:text>|</xsl:text>
				<xsl:value-of
					select="concat(res:binding[@name = 'long']/res:literal, ',', res:binding[@name = 'lat']/res:literal)"
				/>
			</field>
		</xsl:if>

		<xsl:if test="contains($uri, 'geonames.org')">
			<!-- if the findspot is a geonamesId, then establish the findspot_hier facet -->
			<xsl:variable name="hierarchy_pieces"
				select="tokenize($geonames//place[@id = $uri]/@hierarchy, '\|')"/>
			<xsl:variable name="count" select="count($hierarchy_pieces)"/>

			<xsl:for-each select="$hierarchy_pieces">
				<xsl:variable name="position" select="position()"/>

				<xsl:choose>
					<xsl:when test="$position = 1">
						<field name="findspot_hier">
							<xsl:value-of
								select="concat('L', position(), '|', substring-after(., '/'), '/', substring-before(., '/'))"
							/>
						</field>
					</xsl:when>
					<xsl:otherwise>
						<field name="findspot_hier">
							<xsl:value-of
								select="concat(substring-before($hierarchy_pieces[$position - 1], '/'), '|', substring-after(., '/'), '/', substring-before(., '/'))"
							/>
						</field>
					</xsl:otherwise>
				</xsl:choose>

				<field name="findspot_text">
					<xsl:value-of select="substring-after(., '/')"/>
				</field>
			</xsl:for-each>
		</xsl:if>

	</xsl:template>

	<!-- ********** SERIALIZE SPARQL RESULTS FOR TYPES RELATED TO DIES INTO SOLR FIELDS ********** -->
	<!-- New in June 2022: the getDieTypes API is called in order to aggregate a list of coin types associated with a die URI -->

	<xsl:template match="res:result" mode="die-types">
		<field name="coinType_uri">
			<xsl:value-of select="res:binding[@name = 'type']/res:uri"/>
		</field>
		<field name="coinType_facet">
			<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
		</field>
		<field name="relatedType_facet">
			<xsl:value-of
				select="concat(res:binding[@name = 'type']/res:uri, '|', res:binding[@name = 'label']/res:literal)"
			/>
		</field>
	</xsl:template>

</xsl:stylesheet>
