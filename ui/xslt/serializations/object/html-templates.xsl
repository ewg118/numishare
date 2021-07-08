<?xml version="1.0" encoding="UTF-8"?>
<!--***************************************** SHARED TEMPLATES AND FUNCTIONS *****************************************
	Author: Ethan Gruber
	Function: this XSLT stylesheet is included into display.xsl.  It contains shared templates and functions that may be used in object-
	specific stylesheets. Includes templates for bibliographies in MODS and TEI/EpiDoc extensions
	Modification date: 2018
-->
<xsl:stylesheet xmlns:nuds="http://nomisma.org/nuds" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:nm="http://nomisma.org/id/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:gml="http://www.opengis.net/gml" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:org="http://www.w3.org/ns/org#" xmlns:nmo="http://nomisma.org/ontology#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
	xmlns:crmdig="http://www.ics.forth.gr/isl/CRMdig/" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0">
	<!--***************************************** ELEMENT TEMPLATES **************************************** -->
	<xsl:template match="*[local-name() = 'refDesc']">
		<div class="metadata_section">
			<xsl:element name="{if (ancestor::subtype) then 'h4' else 'h3'}">
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</xsl:element>
			<ul>
				<xsl:apply-templates
					select="*:reference[not(child::*[local-name() = 'objectXMLWrap']) and not(child::tei:*)] | *:citation[not(child::*[local-name() = 'objectXMLWrap']) and not(child::tei:*)]"
					mode="descMeta"/>
				<xsl:apply-templates select="*:reference/*[local-name() = 'objectXMLWrap'] | *:reference[child::tei:*] | *:citation[child::tei:*]"/>
			</ul>
		</div>
	</xsl:template>

	<xsl:template match="nuds:physDesc[child::*]">
		<div class="metadata_section">
			<xsl:element name="{if (ancestor::subtype) then 'h4' else 'h3'}">
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</xsl:element>
			<ul>
				<xsl:apply-templates mode="descMeta"/>
			</ul>
		</div>
	</xsl:template>

	<xsl:template match="nuds:typeDesc">
		<xsl:param name="typeDesc_resource"/>
		<div class="metadata_section">
			<xsl:element name="{if (ancestor::subtype) then 'h4' else 'h3'}">
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</xsl:element>
			<xsl:if test="string($typeDesc_resource)">
				<p>Source: <a href="{$typeDesc_resource}" rel="nmo:hasTypeSeriesItem"><xsl:value-of
							select="$nudsGroup//object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:title"/></a></p>
			</xsl:if>
			<ul>
				<xsl:choose>
					<xsl:when test="ancestor::subtype">
						<xsl:apply-templates select="nuds:obverse | nuds:reverse" mode="descMeta"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*" mode="descMeta"/>
					</xsl:otherwise>
				</xsl:choose>
			</ul>
		</div>
	</xsl:template>

	<!-- handle type descriptions in various languages -->
	<xsl:template match="nuds:type" mode="descMeta">
		<li>
			<b>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
				<xsl:text>: </xsl:text>
			</b>
			<xsl:choose>
				<xsl:when test="nuds:description[@xml:lang = $lang]">
					<xsl:value-of select="nuds:description[@xml:lang = $lang]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="nuds:description[@xml:lang = 'en']">
							<xsl:value-of select="nuds:description[@xml:lang = 'en']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="nuds:description[1]"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</li>
	</xsl:template>

	<xsl:template match="*:dateRange" mode="descMeta">
		<li>
			<b>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
				<xsl:text>: </xsl:text>
			</b>

			<xsl:value-of select="concat(nuds:fromDate, ' - ', nuds:toDate)"/>
		</li>
	</xsl:template>

	<xsl:template match="*" mode="descMeta">
		<xsl:choose>
			<!-- always process symbol here -->
			<xsl:when test="(not(child::*) and (string(.) or string(@xlink:href))) or self::nuds:symbol">
				<xsl:variable name="href" select="@xlink:href"/>
				<!-- the facet field is the @xlink:role if it exists, otherwise it is the name of the nuds element -->
				<xsl:variable name="field">
					<xsl:choose>
						<xsl:when test="string(@xlink:role)">
							<xsl:value-of select="@xlink:role"/>
						</xsl:when>
						<xsl:when test="string(@localType)">
							<xsl:value-of select="@localType"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="local-name()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<li>
					<b>
						<xsl:choose>
							<xsl:when test="string(@localType)">
								<xsl:variable name="langParam" select="
										if (string($lang)) then
											$lang
										else
											'en'"/>
								<xsl:variable name="localType" select="@localType"/>
								<xsl:choose>
									<xsl:when test="$localTypes//localType[@value = $localType]/label[@lang = $langParam]">
										<xsl:value-of select="$localTypes//localType[@value = $localType]/label[@lang = $langParam]"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat(upper-case(substring(@localType, 1, 1)), substring(@localType, 2))"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="numishare:regularize_node($field, $lang)"/>
							</xsl:otherwise>
						</xsl:choose>

						<!-- insert position under bold heading -->
						<xsl:if test="string(@position)">
							<xsl:variable name="langParam" select="
									if (string($lang)) then
										$lang
									else
										'en'"/>
							<xsl:variable name="position" select="@position"/>
							<xsl:choose>
								<xsl:when test="$positions//position[@value = $position]/label[@lang = $langParam]">
									<i> (<xsl:value-of select="$positions//position[@value = $position]/label[@lang = $langParam]"/>)</i>
								</xsl:when>
								<xsl:otherwise>
									<i> (<xsl:value-of select="concat(upper-case(substring(@position, 1, 1)), substring(@position, 2))"/>)</i>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>

						<xsl:text>: </xsl:text>
					</b>
					<!-- create link from facet, if applicable -->
					<!-- pull language from nomisma, if available -->
					<xsl:variable name="value">
						<xsl:choose>
							<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
								<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], $lang)"/>
							</xsl:when>
							<xsl:when test="self::*:reference and string(@xlink:href) and @xlink:arcrole = 'nmo:hasTypeSeriesItem'">
								<!-- extract the title from $nudsGroup -->
								<xsl:variable name="uri" select="@xlink:href"/>

								<xsl:choose>
									<xsl:when test="$nudsGroup//object[@xlink:href = $uri]/descendant::nuds:descMeta/nuds:title[@xml:lang = $lang]">
										<xsl:value-of select="$nudsGroup//object[@xlink:href = $uri]/descendant::nuds:descMeta/nuds:title[@xml:lang = $lang]"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(.)"/>
									</xsl:otherwise>
								</xsl:choose>

							</xsl:when>
							<xsl:when test="contains($href, 'geonames.org') and not(string(.))">
								<xsl:variable name="geonameId" select="tokenize($href, '/')[4]"/>
								<xsl:choose>
									<xsl:when test="number($geonameId)">
										<xsl:variable name="geonames_data" as="element()*">
											<results>
												<xsl:copy-of
													select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"
												/>
											</results>
										</xsl:variable>
										<xsl:variable name="label">
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
																concat($name, ' (', $adminName1, ')')
														else
															if ($fcode = 'PCLI') then
																$name
															else
																concat($name, ' (', $countryName, ')')"
											/>
										</xsl:variable>
										<xsl:value-of select="$label"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(.)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="not(string(.))">
										<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], 'en')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test="self::*:date or self::*:fromDate or self::*:toDate">
												<xsl:choose>
													<xsl:when test="string($lang)">
														<!--<xsl:value-of select="format-date(xs:date(concat(@standardDate, '-01-01')), '[Y1]-[Mno]-[D1] [E]', 'fr', 'AD', ())"/>-->
														<xsl:value-of select="normalize-space(.)"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="normalize-space(.)"/>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="normalize-space(.)"/>
											</xsl:otherwise>
										</xsl:choose>

									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:choose>
						<!-- process non-linkable literals -->
						<xsl:when
							test="not(ancestor::nuds:typeDesc/@xlink:href) and not(ancestor::nuds:refDesc) and not(self::nuds:symbol) and not(@xlink:href)">
							<span>
								<xsl:attribute name="property"
									select="
										numishare:normalizeProperty($recordType, if (@xlink:role) then
											@xlink:role
										else
											local-name())"/>
								<xsl:if test="@xml:lang">
									<xsl:attribute name="lang" select="@xml:lang"/>
								</xsl:if>
								<xsl:if test="@standardDate">
									<xsl:attribute name="content" select="@standardDate"/>
									<xsl:attribute name="datatype">xsd:gYear</xsl:attribute>
								</xsl:if>
								<xsl:call-template name="display-label">
									<xsl:with-param name="field" select="$field"/>
									<xsl:with-param name="value" select="$value"/>
									<xsl:with-param name="href" select="$href"/>
									<xsl:with-param name="position" select="@position"/>
								</xsl:call-template>

							</span>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$field = 'region' and $regionHierarchy = true() and contains($href, 'nomisma.org')">
									<xsl:choose>
										<!-- only display the hierarchy if there is a positive response from the Nomisma API -->
										<xsl:when test="$regions//hierarchy[@uri = $href]/region">
											<xsl:call-template name="assemble_hierarchy_query">
												<xsl:with-param name="href" select="$href"/>
											</xsl:call-template>
											<xsl:text>--</xsl:text>
											<!-- add self -->

											<xsl:variable name="selfQuery">
												<xsl:for-each select="$regions//hierarchy[@uri = $href]/region">
													<xsl:sort select="position()" order="descending"/>
													<xsl:variable name="id" select="substring-after(@uri, 'id/')"/>

													<xsl:choose>
														<xsl:when test="position() = 1">
															<xsl:value-of select="concat('+&#x022;L', position(), '|', ., '/', $id, '&#x022;')"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of
																select="concat('+&#x022;', substring-after(following-sibling::node()[1]/@uri, 'id/'), '|', ., '/', $id, '&#x022;')"/>
															<xsl:for-each select="following-sibling::node()">
																<xsl:text> </xsl:text>
																<xsl:value-of
																	select="
																		concat('+&#x022;', if (position() = last()) then
																			'L1'
																		else
																			substring-after(following-sibling::node()[1]/@uri, 'id/'), '|',
																		., '/', substring-after(@uri, 'id/'), '&#x022;')"
																/>
															</xsl:for-each>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:for-each>
												<xsl:text> </xsl:text>
												<xsl:value-of
													select="
														concat('+&#x022;', substring-after($regions//hierarchy[@uri = $href]/region[1]/@uri, 'id/'), '|', $value, '/', substring-after($href,
														'id/'), '&#x022;')"
												/>
											</xsl:variable>

											<a
												href="{$display_path}results?q=region_hier:({encode-for-uri($selfQuery)}){if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}">
												<xsl:value-of select="$value"/>
											</a>
										</xsl:when>
										<xsl:otherwise>
											<xsl:variable name="selfQuery">
												<xsl:text>+&#x022;L1|</xsl:text>
												<xsl:value-of select="$value"/>
												<xsl:text>/</xsl:text>
												<xsl:value-of select="tokenize($href, '/')[last()]"/>
												<xsl:text>&#x022;</xsl:text>
											</xsl:variable>

											<a
												href="{$display_path}results?q=region_hier:({encode-for-uri($selfQuery)}){if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}">
												<xsl:value-of select="$value"/>
											</a>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="self::nuds:symbol">
									<!-- if the symbol is for a die, then ignore the side -->
									<xsl:variable name="side"
										select="
											if (parent::nuds:typeDesc) then
												''
											else
												substring(parent::node()/name(), 1, 3)"/>

									<xsl:choose>
										<xsl:when test="child::tei:div">

											<xsl:apply-templates select="tei:div" mode="symbols">
												<xsl:with-param name="field" select="$field"/>
												<xsl:with-param name="side" select="$side"/>
												<xsl:with-param name="position"
													select="
														if (@position) then
															@position
														else
															@localType"
												/>
											</xsl:apply-templates>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="display-label">
												<xsl:with-param name="field" select="$field"/>
												<xsl:with-param name="value" select="$value"/>
												<xsl:with-param name="href" select="$href"/>
												<xsl:with-param name="side" select="$side"/>
												<xsl:with-param name="position"
													select="
														if (@position) then
															@position
														else
															@localType"
												/>
											</xsl:call-template>


											<!-- if the element is a symbol, display image and constituent letters, if applicable -->
											<xsl:if test="string($href) and self::nuds:symbol">
												<xsl:apply-templates select="$rdf/*[@rdf:about = $href]"/>
											</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="display-label">
										<xsl:with-param name="field" select="$field"/>
										<xsl:with-param name="value" select="$value"/>
										<xsl:with-param name="href" select="$href"/>
										<xsl:with-param name="position"
											select="
												if (@position) then
													@position
												else
													@localType"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>

					<!-- ***** additional attributes ***** -->
					<!-- display title -->
					<xsl:if test="string(@title)">
						<i> (<xsl:value-of select="@title"/>)</i>
					</xsl:if>

					<!-- display certainty -->
					<xsl:apply-templates select="@certainty"/>

					<!-- display calendar -->
					<xsl:if test="string(@calendar)">
						<i> (<xsl:value-of select="@calendar"/>)</i>
					</xsl:if>
					<xsl:if test="string(@for)">
						<i> (<xsl:value-of select="@for"/>)</i>
					</xsl:if>

					<!-- create links to resources -->
					<xsl:if test="string($href)">
						<a href="{$href}" target="_blank" rel="{numishare:normalizeProperty($recordType, if(@xlink:role) then @xlink:role else local-name())}"
							class="external_link">
							<span class="glyphicon glyphicon-new-window"/>
						</a>
					</xsl:if>
				</li>

				<!-- display region hierarchy if region_hier is a facet -->
				<xsl:if test="$field = 'mint' and $regionHierarchy = true() and contains($href, 'nomisma.org')">

					<!-- only display the hierarchy if there is a positive response from the Nomisma API -->
					<xsl:if test="$regions//hierarchy[@uri = $href]/region">
						<li>
							<b>
								<xsl:value-of select="numishare:regularize_node('region', $lang)"/>
								<xsl:text>: </xsl:text>
							</b>
							<xsl:call-template name="assemble_hierarchy_query">
								<xsl:with-param name="href" select="$href"/>
							</xsl:call-template>
						</li>
					</xsl:if>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$recordType = 'conceptual' or $recordType = 'hoard'">
						<xsl:if test="child::*">
							<li>
								<xsl:choose>
									<xsl:when test="parent::physDesc">
										<h3>
											<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
										</h3>
									</xsl:when>
									<xsl:otherwise>
										<h4>
											<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
										</h4>
									</xsl:otherwise>
								</xsl:choose>
								<ul>
									<xsl:if test="local-name() = 'obverse' or local-name() = 'reverse'">
										<xsl:attribute name="rel"
											select="concat('nmo:has', concat(upper-case(substring(local-name(), 1, 1)), substring(local-name(), 2)))"/>
										<xsl:attribute name="resource" select="concat($url, 'id/', $id, '#', local-name())"/>
									</xsl:if>

									<!-- ignore symbols in OCRE -->
									<xsl:choose>
										<xsl:when test="$collection-name = 'ocre'">
											<xsl:apply-templates select="*[not(self::nuds:symbol[@position])]" mode="descMeta"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:apply-templates select="*" mode="descMeta"/>
										</xsl:otherwise>
									</xsl:choose>

									<!-- if the $recordType is 'conceptual' and there is no legend or description, and there are subtypes, display the subtype data -->
									<xsl:if test="$recordType = 'conceptual' and (local-name() = 'obverse' or local-name() = 'reverse')">

										<xsl:if test="count($subtypes//subtype) &gt; 0">
											<xsl:variable name="side" select="local-name()"/>

											<xsl:if test="not(nuds:type) and $subtypes//subtype/descendant::*[local-name() = $side]/nuds:type/nuds:description">
												<xsl:variable name="side" select="local-name()"/>
												<li>
													<b>
														<xsl:value-of select="numishare:regularize_node('type', $lang)"/>
														<xsl:text>: </xsl:text>
													</b>
													<xsl:for-each
														select="
															distinct-values($subtypes//subtype/descendant::*[local-name() = $side]/nuds:type/nuds:description[if (@xml:lang = $lang) then
																@xml:lang = $lang
															else
																@xml:lang = 'en'])">
														<xsl:value-of select="."/>
														<xsl:if test="not(position() = last())"> | </xsl:if>
													</xsl:for-each>
												</li>
											</xsl:if>
											<xsl:if test="not(nuds:legend) and $subtypes//subtype/descendant::*[local-name() = $side]/nuds:legend">
												<xsl:variable name="side" select="local-name()"/>
												<li>
													<b>
														<xsl:value-of select="numishare:regularize_node('legend', $lang)"/>
														<xsl:text>: </xsl:text>
													</b>
													<xsl:for-each select="distinct-values($subtypes//subtype/descendant::*[local-name() = $side]/nuds:legend)">
														<xsl:value-of select="."/>
														<xsl:if test="not(position() = last())"> | </xsl:if>
													</xsl:for-each>
												</li>
											</xsl:if>
										</xsl:if>
									</xsl:if>

									<!-- display Roman style mint marks for OCRE -->
									<xsl:if
										test="
											$collection-name = 'ocre' and (nuds:symbol[@position = 'left'] or nuds:symbol[@position = 'center'] or nuds:symbol[@position = 'right'] or
											nuds:symbol[@position = 'exergue'])">
										<xsl:call-template name="format-control-marks"/>
									</xsl:if>
								</ul>
							</li>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<!-- suppress type and legend from nested list output for physical records: these fields are displayed with the images -->
						<!-- November 2020: display the section and heading if $hasDies = true() -->
						<xsl:if test="(child::*[not(local-name() = 'type' or local-name() = 'legend')]) or $hasDies = true()">
							<li>
								<xsl:choose>
									<xsl:when test="parent::physDesc">
										<h3>
											<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
										</h3>
									</xsl:when>
									<xsl:otherwise>
										<h4>
											<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
										</h4>
									</xsl:otherwise>
								</xsl:choose>
								<ul>
									<xsl:apply-templates select="*[not(local-name() = 'type' or local-name() = 'legend')]" mode="descMeta"/>

									<!-- if $hasDies is true for a physical collection, then display the die link(s) in the appropriate obverse/reverse section -->
									<xsl:if test="$collection_type = 'object' and $hasDies = true()">										
										<xsl:choose>
											<xsl:when test="local-name() = 'obverse' and parent::nuds:typeDesc">
												<xsl:apply-templates select="doc('input:dies')//query/res:sparql[1]/descendant::res:binding[@name = 'die']" mode="coin-die"/>
											</xsl:when>
											<xsl:when test="local-name() = 'reverse' and parent::nuds:typeDesc">
												<xsl:apply-templates select="doc('input:dies')//query/res:sparql[2]/descendant::res:binding[@name = 'die']" mode="coin-die"/>
											</xsl:when>
										</xsl:choose>
									</xsl:if>
								</ul>
							</li>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

		<!-- if the element is a persname with a Nomisma URI, then extract the state and dynasty from the Nomisma RDF -->
		<xsl:if test="local-name() = 'persname' and contains(@xlink:href, 'nomisma.org')">
			<xsl:variable name="href" select="@xlink:href"/>

			<!-- nest the org/dynasty sub-fields under the person -->
			<xsl:if test="$rdf//*[@rdf:about = $href]/org:hasMembership or $rdf//*[@rdf:about = $href]/org:memberOf">
				<li>
					<ul>
						<xsl:apply-templates select="$rdf//*[@rdf:about = $href]/org:hasMembership | $rdf//*[@rdf:about = $href]/org:memberOf"/>
					</ul>
				</li>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'objectXMLWrap']">
		<xsl:variable name="label">
			<xsl:choose>
				<xsl:when test="parent::*:reference">
					<xsl:value-of select="numishare:regularize_node(parent::node()/local-name(), $lang)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<li>
			<b><xsl:value-of select="$label"/>: </b>
			<!-- determine which template to process -->
			<xsl:choose>
				<!-- process MODS record into Chicago Manual of Style formatted citation -->
				<xsl:when test="child::*[local-name() = 'modsCollection']">
					<xsl:call-template name="mods-citation"/>
				</xsl:when>
			</xsl:choose>
		</li>
	</xsl:template>

	<xsl:template name="display-label">
		<xsl:param name="field"/>
		<xsl:param name="value"/>
		<xsl:param name="href"/>
		<xsl:param name="side"/>
		<xsl:param name="position"/>

		<xsl:variable name="facet" select="concat($field, '_facet')"/>

		<xsl:choose>
			<xsl:when test="$field = 'symbol'">

				<!-- get the first crmdig Digital Image URL from the $rdf -->
				<xsl:variable name="image-url" select="$rdf/*[@rdf:about = $href]/descendant::crmdig:D1_Digital_Object[1]/@rdf:about"/>

				<xsl:choose>
					<xsl:when test="string($position) and $positions//position[@value = $position]">
						<a
							href="{$display_path}results?q=symbol_{$side}_{$position}_facet:&#x022;{if (string($image-url)) then concat($image-url, '%7C', $value) else $value}&#x022;{if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}">
							<xsl:value-of select="$value"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="string($side)">
								<a
									href="{$display_path}results?q=symbol_{$side}_facet:&#x022;{if (string($image-url)) then concat($image-url, '%7C', $value) else $value}&#x022;{if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}">
									<xsl:value-of select="$value"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a
									href="{$display_path}results?q=symbol_facet:&#x022;{if (string($image-url)) then concat($image-url, '%7C', $value) else $value}&#x022;{if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}">
									<xsl:value-of select="$value"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="boolean(index-of($facets, $facet)) = true()">
				<!-- if the $lang is enabled in the config (implying indexing into solr), then direct the user to the language-specific Solr query based on Nomisma prefLabel,
					otherwise use the English preferred label -->

				<xsl:variable name="queryValue">
					<xsl:choose>
						<xsl:when test="contains($href, 'nomisma.org') and not($langEnabled = true())">
							<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], 'en')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$value"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>


				<a
					href="{$display_path}results?q={$field}_facet:&#x022;{$queryValue}&#x022;{if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}">
					<xsl:choose>
						<xsl:when test="contains($href, 'geonames.org')">
							<xsl:choose>
								<xsl:when test="string(.)">
									<xsl:value-of select="normalize-space(.)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$value"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$value"/>
						</xsl:otherwise>
					</xsl:choose>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- *************** DISPLAY PREFERRED LABEL FOR CERTAINTY, IF A NOMISMA URI ******************-->
	<xsl:template match="@certainty">
		<xsl:text> </xsl:text>
		<i>
			<xsl:text>(</xsl:text>
			<xsl:choose>
				<xsl:when test="matches(., 'https?://nomisma\.org')">
					<xsl:variable name="href" select="."/>

					<a href="{$href}">
						<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], $lang)"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>)</xsl:text>
		</i>
	</xsl:template>

	<!-- *************** RENDER RDF ABOUT SYMBOLS ******************-->
	<xsl:template match="nmo:Monogram | crm:E37_Mark">
		<xsl:apply-templates select="descendant::crmdig:D1_Digital_Object">
			<xsl:with-param name="uri" select="@rdf:about"/>
		</xsl:apply-templates>

		<xsl:if test="crm:P106_is_composed_of">
			<xsl:text>, consists of </xsl:text>
			<xsl:for-each select="crm:P106_is_composed_of">
				<xsl:if test="position() = last()">
					<xsl:text> and</xsl:text>
				</xsl:if>
				<xsl:text> </xsl:text>
				<xsl:value-of select="."/>
				<xsl:if test="not(position() = last()) and (count(../crm:P106_is_composed_of) &gt; 2)">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template match="crmdig:D1_Digital_Object">
		<xsl:param name="uri"/>
		<xsl:text> </xsl:text>
		<a href="{$uri}">
			<img src="{@rdf:about}" alt="symbol" style="height:24px"/>
		</a>
		<xsl:if test="not(position() = last())">
			<xsl:text> -</xsl:text>
		</xsl:if>

	</xsl:template>

	<!-- *************** FORMAT CONTROL MARKS FROM INDIVIDUAL SYMBOL ELEMENTS ******************-->
	<xsl:template name="format-control-marks">
		<li>
			<b>Control Marks: </b>
			<xsl:choose>
				<xsl:when test="nuds:symbol[@position = 'center']">
					<xsl:value-of select="nuds:symbol[@position = 'center']"/>
					<xsl:text>//</xsl:text>
					<xsl:value-of
						select="
							if (nuds:symbol[@position = 'exergue']) then
								nuds:symbol[@position = 'exergue']
							else
								'-'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="
							if (nuds:symbol[@position = 'left']) then
								nuds:symbol[@position = 'left']
							else
								'-'"/>
					<xsl:text>/</xsl:text>
					<xsl:value-of select="
							if (nuds:symbol[@position = 'right']) then
								nuds:symbol[@position = 'right']
							else
								'-'"/>
					<xsl:text>//</xsl:text>
					<xsl:value-of
						select="
							if (nuds:symbol[@position = 'exergue']) then
								nuds:symbol[@position = 'exergue']
							else
								'-'"/>
				</xsl:otherwise>
			</xsl:choose>
		</li>
	</xsl:template>

	<!-- *************** HANDLE SUBTYPES DELIVERED FROM XQUERY ******************-->
	<xsl:template match="subtype">
		<xsl:param name="uri_space"/>
		<xsl:param name="endpoint"/>
		<xsl:param name="rtl"/>

		<xsl:variable name="subtypeId" select="@recordId"/>
		<xsl:variable name="objectUri" select="concat($uri_space, $subtypeId)"/>

		<div class="row">
			<div class="col-md-3" about="{$objectUri}" typeof="nmo:TypeSeriesItem">
				<h4 property="skos:prefLabel">
					<a href="{$objectUri}">
						<xsl:value-of select="nuds:descMeta/nuds:title"/>
					</a>
				</h4>
				<span class="hidden" property="skos:broader">
					<xsl:value-of select="concat($uri_space, $id)"/>
				</span>
				<ul>
					<xsl:apply-templates select="nuds:descMeta/*[not(local-name() = 'title')]"/>
				</ul>
			</div>
			<div class="col-md-9">
				<xsl:apply-templates select="document(concat($request-uri, 'apis/type-examples?id=', $subtypeId))/res:sparql" mode="type-examples">
					<xsl:with-param name="subtype" select="true()" as="xs:boolean"/>
					<xsl:with-param name="objectUri" select="$objectUri"/>
					<xsl:with-param name="endpoint" select="$endpoint"/>
					<xsl:with-param name="rtl" select="$rtl"/>
				</xsl:apply-templates>
			</div>
		</div>
		<hr/>
	</xsl:template>

	<!-- *************** RDF TEMPLATES ******************-->
	<!-- these templates process corporate entities and dynasties connected to people in the underlying RDF in order to display them as clickable links to the browse page -->
	<xsl:template match="org:hasMembership">
		<xsl:variable name="uri" select="@rdf:resource"/>

		<xsl:apply-templates select="$rdf//org:Membership[@rdf:about = $uri]/org:organization"/>
	</xsl:template>

	<!-- construct variables of relevant NUDS elements, and then apply the template against this variable element -->
	<xsl:template match="org:organization">
		<xsl:variable name="element" as="element()*">
			<xsl:element name="corpname" namespace="http://nomisma.org/nuds">
				<xsl:attribute name="xlink:role">state</xsl:attribute>
				<xsl:attribute name="xlink:href" select="@rdf:resource"/>
			</xsl:element>
		</xsl:variable>

		<xsl:apply-templates select="$element" mode="descMeta"/>
	</xsl:template>

	<xsl:template match="org:memberOf">
		<xsl:variable name="element" as="element()*">
			<xsl:element name="famname" namespace="http://nomisma.org/nuds">
				<xsl:attribute name="xlink:role">dynasty</xsl:attribute>
				<xsl:attribute name="xlink:href" select="@rdf:resource"/>
			</xsl:element>
		</xsl:variable>

		<xsl:apply-templates select="$element" mode="descMeta"/>
	</xsl:template>

	<!-- ************** PROCESS MODS RECORD INTO CHICAGO MANUAL OF STYLE CITATION ************** -->
	<xsl:template name="mods-citation">
		<xsl:apply-templates select="mods:modsCollection"/>
	</xsl:template>
	<xsl:template match="mods:modsCollection">
		<xsl:apply-templates select="mods:mods"/>
	</xsl:template>
	<xsl:template match="mods:mods">
		<!-- name -->
		<xsl:for-each select="mods:name[@type = 'personal']">
			<xsl:choose>
				<xsl:when test="position() = 1">
					<xsl:value-of select="mods:namePart[@type = 'family']"/>
					<xsl:text>, </xsl:text>
					<xsl:value-of select="mods:namePart[@type = 'given']"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- create separator -->
					<xsl:choose>
						<xsl:when test="position() = last()"> and </xsl:when>
						<xsl:otherwise>, </xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="mods:namePart[@type = 'given']"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mods:namePart[@type = 'family']"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="position() = last()">
				<xsl:text>. </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<!-- title -->
		<xsl:choose>
			<!-- when it is a journal article -->
			<xsl:when test="mods:relatedItem[@type = 'host']">
				<!-- article title -->
				<xsl:text>"</xsl:text>
				<xsl:apply-templates select="mods:titleInfo"/>
				<xsl:text>." </xsl:text>
				<!-- journal title and publication -->
				<i>
					<xsl:apply-templates select="mods:relatedItem[@type = 'host']/mods:titleInfo"/>
				</i>
				<xsl:apply-templates select="mods:part"/>
				<xsl:text>.</xsl:text>
			</xsl:when>
			<!-- when it is a monograph -->
			<xsl:otherwise>
				<i>
					<xsl:apply-templates select="mods:titleInfo"/>
				</i>
				<xsl:text>. </xsl:text>
				<xsl:apply-templates select="mods:originInfo"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="mods:titleInfo">
		<xsl:value-of select="mods:title"/>
		<xsl:if test="mods:subTitle">
			<xsl:text>: </xsl:text>
			<xsl:value-of select="mods:subTitle"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="mods:part">
		<xsl:if test="mods:detail[@type = 'volume']">
			<xsl:text> </xsl:text>
			<xsl:value-of select="mods:detail[@type = 'volume']/mods:number"/>
		</xsl:if>
		<xsl:if test="mods:date">
			<xsl:text> (</xsl:text>
			<xsl:value-of select="mods:date"/>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="mods:extent[@unit = 'page']"/>
	</xsl:template>
	<xsl:template match="mods:extent[@unit = 'page']">
		<xsl:text>: </xsl:text>
		<xsl:value-of select="mods:start"/>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="mods:end"/>
	</xsl:template>
	<xsl:template match="mods:originInfo">
		<xsl:if test="mods:place/mods:placeTerm">
			<xsl:value-of select="mods:place/mods:placeTerm"/>
			<xsl:text>: </xsl:text>
		</xsl:if>
		<xsl:if test="mods:publisher">
			<xsl:value-of select="mods:publisher"/>
		</xsl:if>
		<xsl:if test="mods:dateIssued">
			<xsl:text>, </xsl:text>
			<xsl:value-of select="mods:dateIssued"/>
		</xsl:if>
		<xsl:text>.</xsl:text>
	</xsl:template>

	<!-- *************** TEI TEMPLATES FOR REFERENCES, LEGENDS TRANSCRIPTIONS, ETC ******************-->
	<xsl:template match="*:reference[child::tei:*]">
		<li>
			<b><xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>: </b>
			<xsl:choose>
				<xsl:when test="@xlink:title">
					<a
						href="{$display_path}results?q={if (@xlink:arcrole='nmo:hasTypeSeriesItem') then 'coinType' else 'reference'}_facet:&#x022;{@xlink:title}&#x022;{if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}">
						<xsl:value-of select="@xlink:title"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="label">
						<xsl:choose>
							<xsl:when test="tei:title">
								<xsl:value-of select="tei:title"/>
								<xsl:if test="tei:idno">
									<xsl:text> </xsl:text>
									<xsl:value-of select="tei:idno"/>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(.)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<a
						href="{$display_path}results?q={if (@xlink:arcrole='nmo:hasTypeSeriesItem') then 'coinType' else 'reference'}_facet:&#x022;{$label}&#x022;{if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}">
						<xsl:apply-templates select="*"/>
					</a>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="@xlink:href">
				<xsl:text> </xsl:text>
				<a href="{@xlink:href}" target="_blank">
					<span class="glyphicon glyphicon-new-window"/>
				</a>
			</xsl:if>
			<xsl:apply-templates select="@certainty"/>
		</li>
	</xsl:template>

	<xsl:template match="*:citation[child::tei:*]">
		<li>
			<b><xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>: </b>

			<!-- structure a bibliographic reference -->
			<xsl:for-each select="tei:author">
				<xsl:if test="(position() = last()) and position() &gt; 1">
					<xsl:text> and</xsl:text>
				</xsl:if>
				<xsl:text> </xsl:text>
				<xsl:value-of select="."/>
				<xsl:if test="not(position() = last()) and (count(../tei:author) &gt; 2)">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:for-each>

			<!--insert period after final author if it isn't embedded in the value -->
			<xsl:if test="not(substring(tei:author[last()], -1, 1) = '.')">
				<xsl:text>. </xsl:text>
			</xsl:if>

			<xsl:apply-templates select="tei:title"/>

			<xsl:if test="tei:publisher or tei:pubPlace or tei:date">
				<xsl:text>. </xsl:text>

				<xsl:for-each select="tei:pubPlace">
					<xsl:if test="(position() = last()) and position() &gt; 1">
						<xsl:text> and</xsl:text>
					</xsl:if>
					<xsl:text> </xsl:text>
					<xsl:value-of select="."/>
					<xsl:if test="not(position() = last()) and (count(../tei:pubPlace) &gt; 2)">
						<xsl:text>,</xsl:text>
					</xsl:if>
				</xsl:for-each>
				<xsl:if test="tei:pubPlace and tei:publisher">
					<xsl:text>: </xsl:text>
				</xsl:if>

				<xsl:value-of select="tei:publisher"/>

				<xsl:if test="tei:date">
					<xsl:text>, </xsl:text>
					<xsl:value-of select="tei:date"/>
				</xsl:if>

				<xsl:text>.</xsl:text>
			</xsl:if>

			<xsl:if test="@xlink:href">
				<xsl:text> </xsl:text>
				<a href="{@xlink:href}" target="_blank">
					<span class="glyphicon glyphicon-new-window"/>
				</a>
			</xsl:if>

		</li>
	</xsl:template>

	<xsl:template match="tei:title">
		<i>
			<xsl:if test="@type = 'sub'">
				<xsl:text>: </xsl:text>
			</xsl:if>
			<xsl:apply-templates/>
		</i>
	</xsl:template>

	<xsl:template match="tei:idno">
		<xsl:text> </xsl:text>
		<xsl:apply-templates/>
		<xsl:if test="parent::node()/tei:title/@key">
			<xsl:text> </xsl:text>
			<a href="{parent::node()/tei:title/@key}" target="_blank">
				<span class="glyphicon glyphicon-new-window"/>
			</a>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:div" mode="descMeta">
		<li>
			<xsl:apply-templates/>
		</li>
	</xsl:template>

	<xsl:template match="tei:gap">
		<xsl:text>[gap: </xsl:text>
		<i>
			<xsl:value-of select="@reason"/>
		</i>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<!-- complex symbols and monograms encoded in EpiDoc -->
	<xsl:template match="tei:div" mode="symbols">
		<xsl:param name="field"/>
		<xsl:param name="side"/>
		<xsl:param name="position"/>

		<xsl:apply-templates select="tei:choice | tei:ab" mode="symbols">
			<xsl:with-param name="field" select="$field"/>
			<xsl:with-param name="side" select="$side"/>
			<xsl:with-param name="position" select="$position"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="tei:ab" mode="symbols">
		<xsl:param name="field"/>
		<xsl:param name="side"/>
		<xsl:param name="position"/>

		<xsl:choose>
			<xsl:when test="child::*">
				<xsl:apply-templates select="*" mode="symbols">
					<xsl:with-param name="field" select="$field"/>
					<xsl:with-param name="side" select="$side"/>
					<xsl:with-param name="position" select="$position"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="string-length(normalize-space(.)) &gt; 0">
				<xsl:apply-templates select="text()" mode="symbols">
					<xsl:with-param name="field" select="$field"/>
					<xsl:with-param name="side" select="$side"/>
					<xsl:with-param name="position" select="$position"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>

		<xsl:if test="@rend">
			<xsl:text> (</xsl:text>
			<i>
				<xsl:value-of select="@rend"/>
			</i>
			<xsl:text>)</xsl:text>
		</xsl:if>

		<xsl:if test="not(position() = last())">
			<xsl:text> / </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:seg | tei:am | tei:g" mode="symbols">
		<xsl:param name="field"/>
		<xsl:param name="side"/>
		<xsl:param name="position"/>

		<xsl:choose>
			<xsl:when test="child::*">
				<xsl:apply-templates select="*" mode="symbols">
					<xsl:with-param name="field" select="$field"/>
					<xsl:with-param name="side" select="$side"/>
					<xsl:with-param name="position" select="$position"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="string-length(normalize-space(.)) &gt; 0">
				<xsl:apply-templates select="text()" mode="symbols">
					<xsl:with-param name="field" select="$field"/>
					<xsl:with-param name="side" select="$side"/>
					<xsl:with-param name="href" select="@ref"/>
					<xsl:with-param name="position" select="$position"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>



		<xsl:if test="self::tei:g and starts-with(@ref, 'http://numismatics.org')">
			<xsl:variable name="href" select="@ref"/>
			<xsl:apply-templates select="$rdf/*[@rdf:about = $href]"/>

			<a href="{$href}" target="_blank" class="external_link">
				<span class="glyphicon glyphicon-new-window"/>
			</a>
		</xsl:if>

		<xsl:if test="@rend">
			<i>
				<xsl:text> (</xsl:text>
				<xsl:value-of select="@rend"/>
				<xsl:text>)</xsl:text>
			</i>
		</xsl:if>

		<xsl:if test="tei:unclear">
			<i> (unclear)</i>
		</xsl:if>

		<xsl:if test="not(position() = last())">
			<i> beside </i>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:choice" mode="symbols">
		<xsl:param name="field"/>
		<xsl:param name="side"/>
		<xsl:param name="position"/>

		<xsl:for-each select="*">
			<xsl:apply-templates select="self::node()" mode="symbols">
				<xsl:with-param name="field" select="$field"/>
				<xsl:with-param name="side" select="$side"/>
				<xsl:with-param name="position" select="$position"/>
			</xsl:apply-templates>
			<xsl:if test="not(position() = last())">
				<i> or </i>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- process the text() node into a clickable link -->
	<xsl:template match="text()" mode="symbols">
		<xsl:param name="field"/>
		<xsl:param name="side"/>
		<xsl:param name="position"/>
		<xsl:param name="href"/>

		<xsl:call-template name="display-label">
			<xsl:with-param name="field" select="$field"/>
			<xsl:with-param name="value" select="."/>
			<xsl:with-param name="href" select="$href"/>
			<xsl:with-param name="side" select="$side"/>
			<xsl:with-param name="position" select="$position"/>
		</xsl:call-template>
	</xsl:template>

	<!--***************************************** CREATE LINK FROM CATEGORY **************************************** -->
	<xsl:template name="assemble_category_query">
		<xsl:param name="level"/>
		<xsl:param name="tokenized-category"/>
		<xsl:for-each select="$tokenized-category[position() &lt;= $level]">
			<xsl:value-of select="concat('+&#x022;L', position(), '|', ., '&#x022;')"/>
		</xsl:for-each>
		<xsl:if test="position() &lt;= $level">
			<xsl:call-template name="assemble_category_query">
				<xsl:with-param name="level" as="xs:integer" select="$level + 1"/>
				<xsl:with-param name="tokenized-category" select="$tokenized-category"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!--***************************************** CREATE LINKS FROM NOMISMA REGION HIERARCHY **************************************** -->
	<xsl:template name="assemble_hierarchy_query">
		<xsl:param name="href"/>

		<xsl:for-each select="$regions//hierarchy[@uri = $href]/region">
			<xsl:sort select="position()" order="descending"/>
			<xsl:variable name="id" select="substring-after(@uri, 'id/')"/>

			<xsl:variable name="fragment">
				<xsl:choose>
					<xsl:when test="position() = 1">
						<xsl:value-of select="concat('+&#x022;L', position(), '|', ., '/', $id, '&#x022;')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('+&#x022;', substring-after(following-sibling::node()[1]/@uri, 'id/'), '|', ., '/', $id, '&#x022;')"/>
						<xsl:for-each select="following-sibling::node()">
							<xsl:text> </xsl:text>
							<xsl:value-of
								select="
									concat('+&#x022;', if (position() = last()) then
										'L1'
									else
										substring-after(following-sibling::node()[1]/@uri, 'id/'), '|', ., '/', substring-after(@uri,
									'id/'), '&#x022;')"
							/>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<a href="{$display_path}results?q=region_hier:({encode-for-uri($fragment)}){if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}">
				<xsl:value-of select="."/>
			</a>
			<xsl:if test="not(position() = last())">
				<xsl:text>--</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- **************** OPEN ANNOTATIONS (E.G., LINKS FROM A TEI FILE) **************** -->
	<xsl:template match="res:sparql" mode="annotations">
		<xsl:param name="rtl"/>

		<xsl:variable name="sources" select="distinct-values(descendant::res:result/res:binding[@name = 'source']/res:uri)"/>
		<xsl:variable name="results" as="element()*">
			<xsl:copy-of select="res:results"/>
		</xsl:variable>

		<div id="annotations">
			<h3>Annotations<xsl:if test="$recordType = 'conceptual'"><small><a href="#top" title="Return to top"><span class="glyphicon glyphicon-arrow-up"
							/></a></small></xsl:if></h3>
			<xsl:for-each select="$sources">
				<xsl:variable name="uri" select="."/>


				<div class="row">
					<div class="col-md-12">
						<h4>
							<xsl:value-of select="position()"/>
							<xsl:text>. </xsl:text>
							<a href="{$uri}">
								<xsl:value-of
									select="$results/res:result[res:binding[@name = 'source']/res:uri = $uri][1]/res:binding[@name = 'bookTitle']/res:literal"/>
							</a>
						</h4>
					</div>
					<div
						class="col-md-{if ($results/res:result[res:binding[@name='source']/res:uri = $uri][1]/res:binding[@name='thumbnail']/res:uri) then '8' else '12'}">
						<dl class="{if($rtl = true()) then 'dl-horizontal dl-rtl' else 'dl-horizontal'}">

							<!-- only display sections if there are targets (annotations). this is suppressed if the URI is a dcterms:subject, rather than annotation -->
							<xsl:if test="$results/res:result[res:binding[@name = 'source']/res:uri = $uri]/res:binding[@name = 'target']">
								<dt>Sections</dt>
								<dd>
									<xsl:apply-templates select="$results/res:result[res:binding[@name = 'source']/res:uri = $uri]" mode="annotations"/>
								</dd>
							</xsl:if>
							<dt>Creator</dt>
							<dd>
								<xsl:choose>
									<xsl:when
										test="$results/res:result[res:binding[@name = 'source']/res:uri = $uri][1]/res:binding[@name = 'name']/res:literal">
										<a href="{$results/res:result[res:binding[@name='source']/res:uri = $uri][1]/res:binding[@name='creator']/res:uri}">
											<xsl:value-of
												select="$results/res:result[res:binding[@name = 'source']/res:uri = $uri][1]/res:binding[@name = 'name']/res:literal"
											/>
										</a>
									</xsl:when>
									<xsl:otherwise>
										<a href="{$results/res:result[res:binding[@name='source']/res:uri = $uri][1]/res:binding[@name='creator']/res:uri}">
											<xsl:value-of
												select="$results/res:result[res:binding[@name = 'source']/res:uri = $uri][1]/res:binding[@name = 'creator']/res:uri"
											/>
										</a>
									</xsl:otherwise>
								</xsl:choose>
							</dd>
							<xsl:if test="$results/res:result[res:binding[@name = 'source']/res:uri = $uri][1]/res:binding[@name = 'abstract']/res:literal">
								<dt>Abstract</dt>
								<dd>
									<xsl:value-of
										select="$results/res:result[res:binding[@name = 'source']/res:uri = $uri][1]/res:binding[@name = 'abstract']/res:literal"
									/>
								</dd>
							</xsl:if>
						</dl>
					</div>
					<xsl:if test="$results/res:result[res:binding[@name = 'source']/res:uri = $uri][1]/res:binding[@name = 'thumbnail']/res:uri">
						<div class="col-md-4 text-right">
							<a href="{$uri}">
								<img src="{$results/res:result[res:binding[@name='source']/res:uri = $uri][1]/res:binding[@name='thumbnail']/res:uri}"
									alt="thumbnail"/>
							</a>
						</div>
					</xsl:if>
				</div>
			</xsl:for-each>
			<hr/>
		</div>
	</xsl:template>

	<xsl:template match="res:result" mode="annotations">
		<a href="{res:binding[@name='target']/res:uri}">
			<xsl:value-of select="res:binding[@name = 'title']/res:literal"/>
		</a>
		<xsl:if test="not(position() = last())">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="res:binding[@name = 'die'] | res:binding[@name = 'altDie']" mode="coin-die">
		<xsl:variable name="name" select="@name"/>

		<li>
			<b><xsl:value-of select="numishare:regularize_node('die', $lang)"/>: </b>
			<a href="{res:uri}">
				<xsl:value-of select="parent::res:result/res:binding[@name = concat($name, 'Label')]/res:literal"/>
			</a>
		</li>
	</xsl:template>

	<!--***************************************** OPTIONS BAR **************************************** -->
	<xsl:template name="icons">
		<div class="row pull-right icons">
			<div class="col-md-12">
				<ul class="list-inline">
					<li>
						<strong>EXPORT:</strong>
					</li>
					<li>
						<a href="{$id}.xml">NUDS/XML</a>
					</li>
					<li>
						<a href="{$id}.rdf">RDF/XML</a>
					</li>
					<li>
						<a href="{$id}.ttl">TTL</a>
					</li>
					<li>
						<a href="{$id}.jsonld">JSON-LD</a>
					</li>
					<xsl:if test="$recordType = 'physical'">
						<li>
							<a href="{$id}.jsonld?profile=linkedart">Linked.art JSON-LD</a>
						</li>
					</xsl:if>
					<xsl:if test="$hasMints = true() or $hasFindspots = true()">
						<li>
							<a href="{$id}.kml">KML</a>
						</li>
						<li>
							<a href="{$id}.geojson">GeoJSON</a>
						</li>
					</xsl:if>
					<xsl:if test="descendant::mets:file[@USE = 'iiif']">
						<xsl:variable name="manifestURI" select="concat($url, 'manifest/', $id)"/>

						<li>
							<a href="{$manifestURI}">IIIF Manifest</a>
							<xsl:text> </xsl:text>
							<a href="http://numismatics.org/mirador/?manifest={encode-for-uri($manifestURI)}">(view)</a>
						</li>
					</xsl:if>
					<xsl:if test="$collection_type = 'cointype'">
						<!-- only display coin type manifest link if there are IIIF service resources -->
						<xsl:variable name="hasIIIF" select="doc('input:hasIIIF')//res:boolean" as="xs:boolean"/>

						<xsl:if test="$hasIIIF = true()">
							<xsl:variable name="manifestURI" select="concat($url, 'manifest/', $id)"/>
							<li>
								<a href="{$manifestURI}">IIIF Manifest</a>
								<xsl:text> </xsl:text>
								<a href="http://www.kanzaki.com/works/2016/pub/image-annotator?u={encode-for-uri($manifestURI)}">(view)</a>
							</li>
						</xsl:if>
					</xsl:if>
				</ul>
			</div>
		</div>
	</xsl:template>
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

	<xsl:template name="generic_head">
		<title id="{$id}">
			<xsl:value-of select="//config/title"/>
			<xsl:text>: </xsl:text>
			<xsl:choose>
				<xsl:when test="descendant::*:descMeta/*:title[@xml:lang = $lang]">
					<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang = $lang]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang = 'en']"/>
				</xsl:otherwise>
			</xsl:choose>
		</title>
		<!-- alternates -->
		<link rel="alternate" type="application/xml" href="{$objectUri}.xml"/>
		<link rel="alternate" type="application/rdf+xml" href="{$objectUri}.rdf"/>
		<link rel="alternate" type="application/ld+json" href="{$objectUri}.jsonld"/>
		<link rel="alternate" type="application/ld+json" profile="https://linked.art/ns/v1/linked-art.json" href="{$objectUri}.jsonld?profile=linkedart"/>
		<link rel="alternate" type="text/turtle" href="{$objectUri}.ttl"/>
		<link rel="alternate" type="application/vnd.google-earth.kml+xml" href="{$objectUri}.kml"/>
		<link rel="alternate" type="application/vnd.geo+json" href="{$objectUri}.geojson"/>

		<!-- open graph metadata -->
		<meta property="og:url" content="{$objectUri}"/>
		<meta property="og:type" content="article"/>
		<meta property="og:title">
			<xsl:attribute name="content">
				<xsl:choose>
					<xsl:when test="descendant::*:descMeta/*:title[@xml:lang = $lang]">
						<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang = $lang]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang = 'en']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</meta>

		<!-- twitter microdata -->
		<meta name="twitter:card" content="summary_large_image"/>
		<meta name="twitter:title">
			<xsl:attribute name="content">
				<xsl:choose>
					<xsl:when test="descendant::*:descMeta/*:title[@xml:lang = $lang]">
						<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang = $lang]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang = 'en']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</meta>
		<meta name="twitter:url" content="{$objectUri}"/>


		<xsl:for-each select="//mets:fileGrp[@USE = 'obverse']/mets:file[@USE = 'reference']/mets:FLocat/@xlink:href">
			<meta property="og:image" content="{.}"/>
			<meta name="twitter:image" content="{.}"/>
		</xsl:for-each>

		<!-- CSS -->
		<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"/>
		<meta name="viewport" content="width=device-width, initial-scale=1"/>

		<xsl:for-each select="//config/includes/include">
			<xsl:choose>
				<xsl:when test="@type = 'css'">
					<link type="text/{@type}" rel="stylesheet" href="{@url}"/>
				</xsl:when>
				<xsl:when test="@type = 'javascript'">
					<script type="text/{@type}" src="{@url}"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>

		<!-- bootstrap -->
		<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
		<script type="text/javascript" src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>
		<xsl:if test="string(//config/google_analytics)">
			<script type="text/javascript">
				<xsl:value-of select="//config/google_analytics"/>
			</script>
		</xsl:if>

		<!-- always include leaflet -->
		<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.0/dist/leaflet.css"/>
		<script type="text/javascript" src="https://unpkg.com/leaflet@1.0.0/dist/leaflet.js"/>
		<script type="text/javascript" src="{$include_path}/javascript/leaflet.ajax.min.js"/>
	</xsl:template>
</xsl:stylesheet>
