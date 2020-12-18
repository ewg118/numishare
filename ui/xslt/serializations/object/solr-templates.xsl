<?xml version="1.0" encoding="UTF-8"?>
<!--***************************************** SHARED TEMPLATES AND FUNCTIONS *****************************************
	Author: Ethan Gruber
	Function: this XSLT stylesheet is included into xslt/solr.xsl.  It contains shared templates and functions that may be used in object-
	specific stylesheets for creating Solr documents
	Modification date: April 2012
-->
<xsl:stylesheet xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:datetime="http://exslt.org/dates-and-times" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:crmdig="http://www.ics.forth.gr/isl/CRMdig/" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:org="http://www.w3.org/ns/org#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all" version="2.0">

	<!-- general subject indexing -->
	<xsl:template match="*:subjectSet">
		<xsl:for-each select="*:subject">
			<xsl:choose>
				<xsl:when test="string(@localType)">
					<xsl:choose>
						<xsl:when test="@localType = 'category'">
							<field name="category_display">
								<xsl:value-of select="."/>
							</field>
							<xsl:variable name="subsets" select="tokenize(., '--')"/>
							<xsl:for-each select="$subsets">
								<field name="category_facet">
									<xsl:value-of select="concat('L', position(), '|', .)"/>
								</field>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<field name="{@localType}_facet">
								<xsl:value-of select="normalize-space(.)"/>
							</field>
							<field name="{@localType}_text">
								<xsl:value-of select="normalize-space(.)"/>
							</field>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<field name="subject_facet">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="string(@xlink:href)">
				<field name="subject_uri">
					<xsl:value-of select="@xlink:href"/>
				</field>
			</xsl:if>
			<field name="subject_text">
				<xsl:value-of select="normalize-space(.)"/>
			</field>
			<xsl:if test="contains(@xlink:href, 'geonames.org')">
				<xsl:call-template name="subject-geographic"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="subject-geographic">
		<xsl:variable name="href" select="@xlink:href"/>
		<xsl:variable name="role">subject</xsl:variable>
		<xsl:variable name="value" select="."/>
		<!-- *_geo format is 'mint name|URI of resource|KML-compliant geographic coordinates' -->
		<field name="{$role}_geo">
			<xsl:value-of select="$geonames//place[@id = $href]/@label"/>
			<xsl:text>|</xsl:text>
			<xsl:value-of select="$href"/>
			<xsl:text>|</xsl:text>
			<xsl:value-of select="$geonames//place[@id = $href]"/>
		</field>
		<!-- insert hierarchical facets -->
		<xsl:for-each select="tokenize($geonames//place[@id = $href]/@hierarchy, '\|')">
			<xsl:if test="not(. = $value)">
				<field name="{$role}_hier">
					<xsl:value-of select="concat('L', position(), '|', .)"/>
				</field>
				<field name="{$role}_text">
					<xsl:value-of select="."/>
				</field>
			</xsl:if>
			<xsl:if test="position() = last()">
				<xsl:variable name="level" select="
						if (. = $value) then
							position()
						else
							position() + 1"/>
				<field name="{$role}_hier">
					<xsl:value-of select="concat('L', $level, '|', $value)"/>
				</field>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- typeDesc -->
	<xsl:template match="nuds:typeDesc">
		<xsl:param name="recordType"/>
		<xsl:param name="lang"/>

		<!-- these templates are only applied on hoard records -->
		<xsl:if test="$recordType = 'hoard'">
			<xsl:apply-templates select="nuds:date | nuds:dateRange"/>
		</xsl:if>

		<!-- AH dates -->
		<xsl:apply-templates select="nuds:dateOnObject[@calendar = 'ah']"/>

		<xsl:choose>
			<xsl:when test="$recordType = 'physical'">
				<xsl:choose>
					<xsl:when test="position() = 1">
						<!-- only the primary typeDesc of the physical object will have include a displaying legend and type description string -->
						<xsl:apply-templates select="nuds:obverse | nuds:reverse">
							<xsl:with-param name="recordType" select="$recordType"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="primary" select="true()"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="nuds:obverse | nuds:reverse">
							<xsl:with-param name="recordType" select="$recordType"/>
							<xsl:with-param name="lang" select="$lang"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="nuds:obverse | nuds:reverse">
					<xsl:with-param name="recordType" select="$recordType"/>
					<xsl:with-param name="lang" select="$lang"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>

		<!-- *********** FACETS ************** -->
		<xsl:apply-templates
			select="
				nuds:objectType | nuds:denomination[string(.) or string(@xlink:href)] | nuds:manufacture[string(.) or string(@xlink:href)] | nuds:material[string(.) or
				string(@xlink:href)]">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>
		<xsl:apply-templates
			select="
				descendant::nuds:persname[string(.) or string(@xlink:href)] | descendant::nuds:corpname[string(.) or string(@xlink:href)] | descendant::nuds:geogname[string(.) or
				string(@xlink:href)] | descendant::nuds:famname[string(.) or string(@xlink:href)] | descendant::nuds:periodname[string(.) or string(@xlink:href)]">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="nuds:typeSeries"/>

	</xsl:template>

	<xsl:template match="nuds:obverse | nuds:reverse">
		<xsl:param name="recordType"/>
		<xsl:param name="lang"/>
		<xsl:param name="primary"/>

		<xsl:variable name="side" select="substring(local-name(), 1, 3)"/>

		<!-- get correct type description based on lang, default to english -->
		<xsl:if test="nuds:type/nuds:description">
			<xsl:choose>
				<xsl:when test="nuds:type/nuds:description[@xml:lang = $lang]">
					<xsl:choose>
						<xsl:when test="$recordType = 'physical'">
							<xsl:if test="$primary = true()">
								<field name="{$side}_type_display">
									<xsl:value-of select="normalize-space(nuds:type/nuds:description[@xml:lang = $lang])"/>
								</field>
							</xsl:if>
						</xsl:when>
						<xsl:when test="$recordType = 'conceptual'">
							<field name="{$side}_type_display">
								<xsl:value-of select="normalize-space(nuds:type/nuds:description[@xml:lang = $lang])"/>
							</field>
						</xsl:when>
					</xsl:choose>
					<field name="{$side}_type_text">
						<xsl:value-of select="normalize-space(nuds:type/nuds:description[@xml:lang = $lang])"/>
					</field>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="nuds:type/nuds:description[@xml:lang = 'en']">
							<xsl:choose>
								<xsl:when test="$recordType = 'physical'">
									<xsl:if test="$primary = true()">
										<field name="{$side}_type_display">
											<xsl:value-of select="normalize-space(nuds:type/nuds:description[@xml:lang = 'en'])"/>
										</field>
									</xsl:if>
								</xsl:when>
								<xsl:when test="$recordType = 'conceptual'">
									<field name="{$side}_type_display">
										<xsl:value-of select="normalize-space(nuds:type/nuds:description[@xml:lang = 'en'])"/>
									</field>
								</xsl:when>
							</xsl:choose>
							<field name="{$side}_type_text">
								<xsl:value-of select="normalize-space(nuds:type/nuds:description[@xml:lang = 'en'])"/>
							</field>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="$recordType != 'hoard'">
								<xsl:choose>
									<xsl:when test="$recordType = 'physical'">
										<xsl:if test="$primary = true()">
											<field name="{$side}_type_display">
												<xsl:value-of select="normalize-space(nuds:type/nuds:description[1])"/>
											</field>
										</xsl:if>
									</xsl:when>
									<xsl:when test="$recordType = 'conceptual'">
										<field name="{$side}_type_display">
											<xsl:value-of select="normalize-space(nuds:type/nuds:description[1])"/>
										</field>
									</xsl:when>
								</xsl:choose>
							</xsl:if>
							<field name="{$side}_type_text">
								<xsl:value-of select="normalize-space(nuds:type/nuds:description[1])"/>
							</field>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<xsl:apply-templates select="nuds:legend">
			<xsl:with-param name="recordType" select="$recordType"/>
			<xsl:with-param name="side" select="$side"/>
			<xsl:with-param name="primary" select="$primary"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="nuds:die">
			<xsl:with-param name="side" select="$side"/>
		</xsl:apply-templates>

		<!-- only index symbols as facets for coin type projects -->
		<xsl:apply-templates select="nuds:symbol">
			<xsl:with-param name="side" select="$side"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="nuds:legend">
		<xsl:param name="recordType"/>
		<xsl:param name="side"/>
		<xsl:param name="primary"/>

		<!-- only include legend if there's a string (ignore gaps) -->

		<xsl:choose>
			<xsl:when test="child::tei:div[@type = 'edition']">
				<xsl:apply-templates select="tei:div[@type = 'edition']">
					<xsl:with-param name="side" select="$side"/>
					<xsl:with-param name="recordType" select="$recordType"/>
					<xsl:with-param name="primary" select="$primary"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="string(.)">
					<xsl:choose>
						<xsl:when test="$recordType = 'physical'">
							<xsl:if test="$primary = true()">
								<field name="{$side}_leg_display">
									<xsl:value-of select="normalize-space(.)"/>
								</field>
							</xsl:if>
						</xsl:when>
						<xsl:when test="$recordType = 'conceptual'">
							<field name="{$side}_leg_display">
								<xsl:value-of select="normalize-space(.)"/>
							</field>
						</xsl:when>
					</xsl:choose>

					<field name="{$side}_leg_text">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
					<field name="{$side}_legendCondensed_text">
						<xsl:value-of select="replace(., ' ', '')"/>
					</field>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:die">
		<xsl:param name="side"/>

		<field name="{$side}_die_facet">
			<xsl:value-of select="."/>
		</field>

		<field name="{$side}_die_text">
			<xsl:value-of select="."/>
		</field>

		<xsl:if test="@xlink:href">
			<field name="{$side}_die_uri">
				<xsl:value-of select="@xlink:href"/>
			</field>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:symbol[not(@localType = 'mintMark')]">
		<xsl:param name="side"/>

		<xsl:variable name="symbolType">symbol</xsl:variable>
		<xsl:variable name="position" select="if (@position) then @position else @localType"/>

		<!-- parse text fragments and monograms encoded in EpiDoc TEI -->
		<xsl:choose>
			<xsl:when test="child::tei:div">
				<xsl:apply-templates select="tei:div" mode="symbols">
					<xsl:with-param name="symbolType" select="$symbolType"/>
					<xsl:with-param name="side" select="$side"/>
					<xsl:with-param name="position" select="if (@position) then @position else @localType"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="string($position)">
						<xsl:choose>
							<xsl:when test="@xlink:href">
								<xsl:variable name="uri" select="@xlink:href"/>
								<field name="{$symbolType}_{$side}_{$position}_facet">
									<xsl:choose>
										<xsl:when test="$rdf//*[@rdf:about = $uri]/descendant::crmdig:D1_Digital_Object">
											<xsl:value-of select="$rdf//*[@rdf:about = $uri]/descendant::crmdig:D1_Digital_Object[1]/@rdf:about"/>
											<xsl:text>|</xsl:text>
											<xsl:value-of select="$rdf//*[@rdf:about = $uri]/skos:prefLabel"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$rdf//*[@rdf:about = $uri]/skos:prefLabel"/>
										</xsl:otherwise>
									</xsl:choose>
								</field>
								<field name="{$symbolType}_{$side}_facet">
									<xsl:choose>
										<xsl:when test="$rdf//*[@rdf:about = $uri]/descendant::crmdig:D1_Digital_Object">
											<xsl:value-of select="$rdf//*[@rdf:about = $uri]/descendant::crmdig:D1_Digital_Object[1]/@rdf:about"/>
											<xsl:text>|</xsl:text>
											<xsl:value-of select="$rdf//*[@rdf:about = $uri]/skos:prefLabel"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$rdf//*[@rdf:about = $uri]/skos:prefLabel"/>
										</xsl:otherwise>
									</xsl:choose>
								</field>
								<field name="{$symbolType}_{$side}_{$position}_uri">
									<xsl:value-of select="@xlink:href"/>
								</field>
								<field name="{$symbolType}_uri">
									<xsl:value-of select="@xlink:href"/>
								</field>

								<!-- index constuent letters -->
								<xsl:apply-templates select="$rdf//*[@rdf:about = $uri]/crm:P106_is_composed_of">
									<xsl:with-param name="side" select="$side"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<field name="{$symbolType}_{$side}_{$position}_facet">
									<xsl:value-of select="."/>
								</field>
								<field name="{$symbolType}_{$side}_facet">
									<xsl:value-of select="."/>
								</field>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="@xlink:href">
								<xsl:variable name="uri" select="@xlink:href"/>
								<field name="{$symbolType}_{$side}_facet">
									<xsl:choose>
										<xsl:when test="$rdf//*[@rdf:about = $uri]/descendant::crmdig:D1_Digital_Object">
											<xsl:value-of select="$rdf//*[@rdf:about = $uri]/descendant::crmdig:D1_Digital_Object[1]/@rdf:about"/>
											<xsl:text>|</xsl:text>
											<xsl:value-of select="$rdf//*[@rdf:about = $uri]/skos:prefLabel"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$rdf//*[@rdf:about = $uri]/skos:prefLabel"/>
										</xsl:otherwise>
									</xsl:choose>
								</field>
								<field name="{$symbolType}_{$side}_uri">
									<xsl:value-of select="@xlink:href"/>
								</field>
								<field name="{$symbolType}_uri">
									<xsl:value-of select="@xlink:href"/>
								</field>

								<!-- index constuent letters -->
								<xsl:apply-templates select="$rdf//*[@rdf:about = $uri]/crm:P106_is_composed_of">
									<xsl:with-param name="side" select="$side"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<field name="{$symbolType}_{$side}_facet">
									<xsl:value-of select="."/>
								</field>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:objectType | nuds:denomination | nuds:manufacture | nuds:material | nuds:typeSeries">
		<xsl:param name="lang"/>
		<xsl:variable name="facet" select="local-name()"/>
		<xsl:variable name="href" select="@xlink:href"/>
		<xsl:variable name="label">
			<xsl:choose>
				<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
					<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], $lang)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="not(string(.))">
							<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], 'en')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(.)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<field name="{$facet}_facet">
			<xsl:value-of select="$label"/>
		</field>
		<field name="{$facet}_text">
			<xsl:value-of select="$label"/>
		</field>

		<xsl:if test="string($href)">
			<field name="{$facet}_uri">
				<xsl:value-of select="$href"/>
			</field>
		</xsl:if>

		<!-- additional content -->
		<xsl:if test="contains($href, 'nomisma.org')">
			<!-- ingest matchinging URIs -->
			<xsl:for-each select="$rdf/*[@rdf:about = $href]/skos:exactMatch | $rdf/*[@rdf:about = $href]/skos:closeMatch">
				<field name="{$facet}_match_uri">
					<xsl:value-of select="@rdf:resource"/>
				</field>
			</xsl:for-each>
			<!-- ingest alternate labels -->
			<xsl:for-each
				select="
					$rdf/*[@rdf:about = $href]/skos:altLabel[if (string($lang)) then
						@xml:lang = $lang
					else
						@xml:lang = 'en']">
				<field name="{$facet}_text">
					<xsl:value-of select="."/>
				</field>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:persname | nuds:corpname | *[local-name() = 'geogname'] | nuds:famname | nuds:periodname">
		<xsl:param name="lang"/>
		<xsl:variable name="href" select="@xlink:href"/>
		<xsl:variable name="role" select="if (string(@xlink:role)) then
			@xlink:role
			else
			local-name()">
			
			<!--<xsl:choose>
				<xsl:when test="self::nuds:persname[string(@xlink:role)]">
					<xsl:variable name="facet" select="concat(@xlink:role, '_facet')"/>
					
					<xsl:choose>
						<xsl:when test="//config/facets[facet = $facet]">
							<xsl:value-of select="@xlink:role"/>
						</xsl:when>
					</xsl:choose>					
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="if (string(@xlink:role)) then
						@xlink:role
						else
						local-name()"/>
				</xsl:otherwise>
			</xsl:choose>-->
			
		</xsl:variable>
		
		<xsl:variable name="label">
			<xsl:choose>
				<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
					<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], $lang)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="not(string(.))">
							<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], 'en')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(.)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<field name="{$role}_facet">
			<xsl:choose>
				<xsl:when test="$role = 'findspot' and contains(@xlink:href, 'geonames.org')">
					<xsl:value-of select="$geonames//place[@id = $href]/@label"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$label"/>
				</xsl:otherwise>
			</xsl:choose>
		</field>
		<xsl:if test="$role = 'findspot' and not(ancestor::nh:findspot/nh:description)">
			<field name="findspot_display">
				<xsl:value-of select="$label"/>
			</field>
		</xsl:if>
		<field name="{$role}_text">
			<xsl:choose>
				<xsl:when test="$role = 'findspot' and contains(@xlink:href, 'geonames.org')">
					<!-- combine the text with the label -->
					<xsl:value-of select="$label"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$geonames//place[@id = $href]/@label"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$label"/>
				</xsl:otherwise>
			</xsl:choose>
		</field>
		<xsl:if test="string(@xlink:href)">
			<field name="{$role}_uri">
				<xsl:value-of select="@xlink:href"/>
			</field>
		</xsl:if>

		<!-- additional content -->
		<xsl:if test="contains($href, 'nomisma.org')">
			<!-- ingest matchinging URIs -->
			<xsl:for-each select="$rdf/*[@rdf:about = $href]/skos:exactMatch | $rdf/*[@rdf:about = $href]/skos:closeMatch">
				<field name="{$role}_match_uri">
					<xsl:value-of select="@rdf:resource"/>
				</field>
			</xsl:for-each>

			<!-- ingest alternate labels -->
			<xsl:for-each
				select="
					$rdf/*[@rdf:about = $href]/skos:altLabel[if (string($lang)) then
						@xml:lang = $lang
					else
						@xml:lang = 'en']">
				<field name="{$role}_text">
					<xsl:value-of select="."/>
				</field>
			</xsl:for-each>

			<!-- get dynasty/political entity from Nomisma RDF -->
			<xsl:for-each select="$rdf/*[@rdf:about = $href]/org:memberOf">
				<xsl:variable name="dynasty_uri" select="@rdf:resource"/>
				<xsl:variable name="label" select="$rdf/*[@rdf:about = $dynasty_uri]/skos:prefLabel[if (string($lang)) then
					@xml:lang = $lang
					else
					@xml:lang = 'en']"/>

				<field name="dynasty_uri">
					<xsl:value-of select="$dynasty_uri"/>
				</field>

				
				
				<field name="dynasty_facet">
					<xsl:value-of select="$label"/>
				</field>
				<field name="dynasty_text">
					<xsl:value-of select="$label"/>
				</field>
			</xsl:for-each>

			<xsl:for-each select="$rdf/*[@rdf:about = $href]/org:hasMembership">
				<xsl:variable name="membership_uri" select="@rdf:resource"/>

				<xsl:if test="$rdf/*[@rdf:about = $membership_uri]/org:organization">
					<xsl:variable name="org_uri" select="$rdf/*[@rdf:about = $membership_uri]/org:organization/@rdf:resource"/>
					<xsl:variable name="label" select="$rdf/*[@rdf:about = $org_uri]/skos:prefLabel[if (string($lang)) then
						@xml:lang = $lang
						else
						@xml:lang = 'en']"/>

					<field name="state_uri">
						<xsl:value-of select="$org_uri"/>
					</field>

					<field name="state_facet">
						<xsl:value-of select="$label"/>
					</field>
					<field name="state_text">
						<xsl:value-of select="$label"/>
					</field>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>

		<xsl:if test="string(@xlink:href) and ($role = 'mint' or $role = 'findspot')">
			<xsl:choose>
				<xsl:when test="contains(@xlink:href, 'geonames')">
					<xsl:variable name="href" select="@xlink:href"/>
					<xsl:variable name="value" select="."/>
					<!-- *_geo format is 'mint name|URI of resource|KML-compliant geographic coordinates' -->

					<xsl:if test="string-length($geonames//place[@id = $href]) &gt; 0">
						<field name="{$role}_geo">
							<xsl:value-of select="$geonames//place[@id = $href]/@label"/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="$href"/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="$geonames//place[@id = $href]"/>
						</field>
						<field name="{$role}_loc">
							<xsl:value-of select="concat(tokenize($geonames//place[@id = $href], ',')[2], ',', tokenize($geonames//place[@id = $href], ',')[1])"
							/>
						</field>
					</xsl:if>

					<!-- insert hierarchical facets -->
					<xsl:variable name="hierarchy_pieces" select="tokenize($geonames//place[@id = $href]/@hierarchy, '\|')"/>
					<xsl:variable name="count" select="count($hierarchy_pieces)"/>

					<xsl:for-each select="$hierarchy_pieces">
						<xsl:variable name="position" select="position()"/>

						<xsl:choose>
							<xsl:when test="$position = 1">
								<field name="{$role}_hier">
									<xsl:value-of select="concat('L', position(), '|', substring-after(., '/'), '/', substring-before(., '/'))"/>
								</field>
							</xsl:when>
							<xsl:otherwise>
								<field name="{$role}_hier">
									<xsl:value-of
										select="concat(substring-before($hierarchy_pieces[$position - 1], '/'), '|', substring-after(., '/'), '/', substring-before(., '/'))"
									/>
								</field>
							</xsl:otherwise>
						</xsl:choose>

						<field name="{$role}_text">
							<xsl:value-of select="substring-after(., '/')"/>
						</field>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="contains(@xlink:href, 'nomisma.org')">
					<xsl:variable name="href" select="@xlink:href"/>

					<xsl:variable name="coordinates" as="node()*">
						<coordinates>
							<xsl:choose>
								<!-- when there is a geo:SpatialThing associated with the mint that contains a lat and long: -->
								<xsl:when test="$rdf//*[@rdf:about = concat($href, '#this')]/geo:long and $rdf//*[@rdf:about = concat($href, '#this')]/geo:lat">
									<lat>
										<xsl:value-of select="$rdf//*[@rdf:about = concat($href, '#this')]/geo:lat"/>
									</lat>
									<long>
										<xsl:value-of select="$rdf//*[@rdf:about = concat($href, '#this')]/geo:long"/>
									</long>
								</xsl:when>
								<!-- ignore uncertain mints for now -->
								<xsl:when test="$rdf//*[@rdf:about = $href]/skos:related"/>
								<!-- if the mint does not have coordinates, but does have skos:broader, exectue the region hierarchy API call to look for parent mint/region coordinates -->
								<xsl:when test="$rdf//*[@rdf:about = $href]/skos:broader">
									<xsl:if test="$regions//hierarchy[@uri = $href]/mint[1][@lat and @long]">
										<lat>
											<xsl:value-of select="$regions//hierarchy[@uri = $href]/mint[1]/@lat"/>
										</lat>
										<long>
											<xsl:value-of select="$regions//hierarchy[@uri = $href]/mint[1]/@long"/>
										</long>
									</xsl:if>
								</xsl:when>
							</xsl:choose>
						</coordinates>
					</xsl:variable>

					<xsl:if test="$coordinates/lat and $coordinates/long">
						<!-- *_geo format is 'mint name|URI of resource|KML-compliant geographic coordinates' -->
						<field name="{$role}_geo">
							<xsl:choose>
								<xsl:when test="string($lang)">
									<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], $lang)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="not(string(.))">
											<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], 'en')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="normalize-space(.)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="@xlink:href"/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="concat($coordinates/long, ',', $coordinates/lat)"/>
						</field>

						<field name="{$role}_loc">
							<xsl:value-of select="concat($coordinates/lat, ',', $coordinates/long)"/>
						</field>
					</xsl:if>

					<xsl:for-each select="$rdf/*[@rdf:about = $href]/skos:closeMatch[contains(@rdf:resource, 'pleiades.stoa.org')]">
						<field name="pleiades_uri">
							<xsl:value-of select="@rdf:resource"/>
						</field>
					</xsl:for-each>

					<!--index region hierarchy -->
					<xsl:for-each select="$regions//hierarchy[@uri = $href]/region">
						<xsl:sort select="position()" order="descending"/>
						<xsl:variable name="id" select="substring-after(@uri, 'id/')"/>

						<field name="region_hier">
							<xsl:choose>
								<xsl:when test="position() = 1">
									<xsl:value-of select="concat('L', position(), '|', ., '/', $id)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat(substring-after(following-sibling::node()[1]/@uri, 'id/'), '|', ., '/', $id)"/>
								</xsl:otherwise>
							</xsl:choose>

						</field>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="string(@xlink:href) and $role = 'region'">
			<xsl:variable name="href" select="@xlink:href"/>
			<xsl:for-each select="$rdf/*[@rdf:about = $href]/skos:closeMatch[contains(@rdf:resource, 'pleiades.stoa.org')]">
				<field name="pleiades_uri">
					<xsl:value-of select="@rdf:resource"/>
				</field>
			</xsl:for-each>
			<xsl:if test="contains($href, 'nomisma.org')">
				<!--index region hierarchy -->
				<xsl:for-each select="$regions//hierarchy[@uri = $href]/region">
					<xsl:sort select="position()" order="descending"/>
					<xsl:variable name="id" select="substring-after(@uri, 'id/')"/>

					<field name="region_hier">
						<xsl:choose>
							<xsl:when test="position() = 1">
								<xsl:value-of select="concat('L', position(), '|', ., '/', $id)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat(substring-after(following-sibling::node()[1]/@uri, 'id/'), '|', ., '/', $id)"/>
							</xsl:otherwise>
						</xsl:choose>

					</field>
					<!-- manually insert lowest region hierarchy for self -->
					<xsl:if test="position() = last()">
						<field name="region_hier">
							<xsl:value-of select="concat(substring-after(@uri, 'id/'), '|', $label, '/', substring-after($href, 'id/'))"/>
						</field>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:dateOnObject[@calendar = 'ah']">
		<xsl:if test="normalize-space(.) castable as xs:integer">
			<field name="ah_num">
				<xsl:value-of select="normalize-space(.)"/>
			</field>
			<field name="ah_minint">
				<xsl:value-of select="normalize-space(.)"/>
			</field>
			<field name="ah_maxint">
				<xsl:value-of select="normalize-space(.)"/>
			</field>
		</xsl:if>
	</xsl:template>

	<!-- TEI-encoded symbols and monograms encoded in EpiDoc -->
	<xsl:template match="tei:div" mode="symbols">
		<xsl:param name="side"/>
		<xsl:param name="symbolType"/>
		<xsl:param name="position"/>

		<xsl:apply-templates select="tei:choice | tei:ab" mode="symbols">
			<xsl:with-param name="side" select="$side"/>
			<xsl:with-param name="symbolType" select="$symbolType"/>
			<xsl:with-param name="position" select="$position"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="tei:ab" mode="symbols">
		<xsl:param name="side"/>
		<xsl:param name="symbolType"/>
		<xsl:param name="position"/>

		<xsl:choose>
			<xsl:when test="child::*">
				<xsl:apply-templates select="*" mode="symbols">
					<xsl:with-param name="side" select="$side"/>
					<xsl:with-param name="symbolType" select="$symbolType"/>
					<xsl:with-param name="position" select="$position"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="string-length(normalize-space(.)) &gt; 0">
				<xsl:apply-templates select="text()" mode="symbols">
					<xsl:with-param name="side" select="$side"/>
					<xsl:with-param name="symbolType" select="$symbolType"/>
					<xsl:with-param name="position" select="$position"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:seg | tei:am | tei:g" mode="symbols">
		<xsl:param name="side"/>
		<xsl:param name="symbolType"/>
		<xsl:param name="position"/>

		<xsl:choose>
			<xsl:when test="child::*">
				<xsl:apply-templates select="*" mode="symbols">
					<xsl:with-param name="side" select="$side"/>
					<xsl:with-param name="symbolType" select="$symbolType"/>
					<xsl:with-param name="position" select="$position"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="string-length(normalize-space(.)) &gt; 0">
				<xsl:apply-templates select="text()" mode="symbols">
					<xsl:with-param name="side" select="$side"/>
					<xsl:with-param name="symbolType" select="$symbolType"/>
					<xsl:with-param name="position" select="$position"/>
					<xsl:with-param name="href" select="@ref"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>


	</xsl:template>

	<xsl:template match="tei:choice" mode="symbols">
		<xsl:param name="side"/>
		<xsl:param name="symbolType"/>
		<xsl:param name="position"/>

		<xsl:for-each select="*">
			<xsl:apply-templates select="self::node()" mode="symbols">
				<xsl:with-param name="side" select="$side"/>
				<xsl:with-param name="symbolType" select="$symbolType"/>
				<xsl:with-param name="position" select="$position"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>

	<!-- process the text() node into a clickable link -->
	<xsl:template match="text()" mode="symbols">
		<xsl:param name="side"/>
		<xsl:param name="symbolType"/>
		<xsl:param name="position"/>
		<xsl:param name="href"/>

		<xsl:call-template name="generate-symbol-field">
			<xsl:with-param name="side" select="$side"/>
			<xsl:with-param name="symbolType" select="$symbolType"/>
			<xsl:with-param name="position" select="$position"/>
			<xsl:with-param name="value" select="."/>
			<xsl:with-param name="href" select="$href"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="generate-symbol-field">
		<xsl:param name="side"/>
		<xsl:param name="symbolType"/>
		<xsl:param name="position"/>
		<xsl:param name="value"/>
		<xsl:param name="href"/>

		<xsl:choose>
			<xsl:when test="string($position)">
				<xsl:choose>
					<xsl:when test="string($href)">
						<field name="{$symbolType}_{$side}_{$position}_facet">
							<xsl:choose>
								<xsl:when test="$rdf//*[@rdf:about = $href]/descendant::crmdig:D1_Digital_Object">
									<xsl:value-of select="$rdf//*[@rdf:about = $href]/descendant::crmdig:D1_Digital_Object[1]/@rdf:about"/>
									<xsl:text>|</xsl:text>
									<xsl:value-of select="$rdf//*[@rdf:about = $href]/skos:prefLabel"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$rdf//*[@rdf:about = $href]/skos:prefLabel"/>
								</xsl:otherwise>
							</xsl:choose>
						</field>
						<field name="{$symbolType}_{$side}_facet">
							<xsl:choose>
								<xsl:when test="$rdf//*[@rdf:about = $href]/descendant::crmdig:D1_Digital_Object">
									<xsl:value-of select="$rdf//*[@rdf:about = $href]/descendant::crmdig:D1_Digital_Object[1]/@rdf:about"/>
									<xsl:text>|</xsl:text>
									<xsl:value-of select="$rdf//*[@rdf:about = $href]/skos:prefLabel"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$rdf//*[@rdf:about = $href]/skos:prefLabel"/>
								</xsl:otherwise>
							</xsl:choose>
						</field>
						<field name="{$symbolType}_{$side}_{$position}_uri">
							<xsl:value-of select="$href"/>
						</field>
						<field name="{$symbolType}_uri">
							<xsl:value-of select="$href"/>
						</field>

						<!-- index constuent letters -->
						<xsl:apply-templates select="$rdf//*[@rdf:about = $href]/crm:P106_is_composed_of">
							<xsl:with-param name="side" select="$side"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<field name="{$symbolType}_{$side}_{$position}_facet">
							<xsl:value-of select="."/>
						</field>
						<field name="{$symbolType}_{$side}_facet">
							<xsl:value-of select="."/>
						</field>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="string($href)">
						<field name="{$symbolType}_{$side}_facet">
							<xsl:choose>
								<xsl:when test="$rdf//*[@rdf:about = $href]/descendant::crmdig:D1_Digital_Object">
									<xsl:value-of select="$rdf//*[@rdf:about = $href]/descendant::crmdig:D1_Digital_Object[1]/@rdf:about"/>
									<xsl:text>|</xsl:text>
									<xsl:value-of select="$rdf//*[@rdf:about = $href]/skos:prefLabel"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$rdf//*[@rdf:about = $href]/skos:prefLabel"/>
								</xsl:otherwise>
							</xsl:choose>
						</field>
						<field name="{$symbolType}_{$side}_uri">
							<xsl:value-of select="$href"/>
						</field>
						<field name="{$symbolType}_uri">
							<xsl:value-of select="$href"/>
						</field>

						<!-- index constuent letters -->
						<xsl:apply-templates select="$rdf//*[@rdf:about = $href]/crm:P106_is_composed_of">
							<xsl:with-param name="side" select="$side"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<field name="{$symbolType}_{$side}_facet">
							<xsl:value-of select="."/>
						</field>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- index TEI-encoded edition into legend field -->
	<xsl:template match="tei:div[@type = 'edition']">
		<xsl:param name="side"/>
		<xsl:param name="recordType"/>
		<xsl:param name="primary"/>

		<xsl:if test="string(.)">
			<xsl:choose>
				<xsl:when test="$recordType = 'physical'">
					<xsl:if test="$primary = true()">
						<field name="{$side}_leg_display">
							<xsl:value-of select="string-join(tei:div, ' ')"/>
						</field>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$recordType = 'conceptual'">
					<field name="{$side}_leg_display">
						<xsl:value-of select="string-join(tei:div, ' ')"/>
					</field>
				</xsl:when>
			</xsl:choose>

			<field name="{$side}_leg_text">
				<xsl:value-of select="string-join(tei:div, ' ')"/>
			</field>
			<field name="{$side}_legendCondensed_text">
				<xsl:value-of select="replace(string-join(tei:div, ' '), ' ', '')"/>
			</field>
		</xsl:if>
	</xsl:template>

	<!-- generalize refDesc for NUDS and NUDS Hoard records -->
	<xsl:template match="*[local-name() = 'refDesc']">

		<!-- references -->
		<xsl:variable name="refs" as="element()*">
			<refs>
				<xsl:for-each select="*[local-name() = 'reference']">
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
			<xsl:if test="position() = 1">
				<field name="reference_min">
					<xsl:value-of select="."/>
				</field>
			</xsl:if>
			<xsl:if test="position() = last()">
				<field name="reference_max">
					<xsl:value-of select="."/>
				</field>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nuds:date">
		<xsl:for-each select="@standardDate">
			<xsl:call-template name="get_date_hierarchy">
				<xsl:with-param name="standardDate" select="."/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nuds:dateRange">
		<xsl:for-each select="*/@standardDate">
			<xsl:call-template name="get_date_hierarchy">
				<xsl:with-param name="standardDate" select="."/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- index constituent letters -->
	<xsl:template match="crm:P106_is_composed_of">
		<xsl:param name="side"/>

		<xsl:if test="string(.)">
			<field name="symbol_{$side}_letter_facet">
				<xsl:value-of select="."/>
			</field>
		</xsl:if>
	</xsl:template>

	<!-- ***** CUSTOM TEMPLATES ***** -->
	<xsl:template name="get_date_hierarchy">
		<xsl:param name="standardDate"/>

		<xsl:if test="number(.)">
			<!--<xsl:variable name="year_string" select="string(abs(number(.)))"/>
			<xsl:variable name="century" select="
					if (number(.) &gt; 0) then
						ceiling(number(.) div 100)
					else
						floor(number(.) div 100)"/>
			<xsl:variable name="decade_digit" select="floor(number(substring($year_string, (string-length($year_string) - 1), 2)) div 10)"/>
			<xsl:variable name="decade" select="(($century - 1) * 100) + $decade_digit"/>

			<xsl:if test="number($century)">
				<field name="century_num">
					<xsl:value-of select="$century"/>
				</field>
			</xsl:if>
			<field name="decade_num">
				<xsl:value-of select="$decade"/>
			</field>-->

			<field name="year_num">
				<xsl:value-of select="number(.)"/>
			</field>
		</xsl:if>
	</xsl:template>

	<xsl:template name="parse_dates">
		<xsl:param name="typologies"/>

		<xsl:variable name="dates" as="element()*">
			<dates>
				<xsl:for-each select="distinct-values($typologies/descendant::*/@standardDate)">
					<xsl:sort order="ascending" data-type="number"/>
					<xsl:if test="number(.)">
						<date>
							<xsl:value-of select="."/>
						</date>
					</xsl:if>
				</xsl:for-each>
			</dates>
		</xsl:variable>

		<xsl:for-each select="$dates//date">
			<!-- add min and max, even if they are integers (for ISO dates) -->
			<xsl:if test="position() = 1">
				<field name="year_minint">
					<xsl:value-of select="number(.)"/>
				</field>
				<field name="year_num">
					<xsl:value-of select="number(.)"/>
				</field>
			</xsl:if>
			<xsl:if test="position() = last()">
				<field name="year_maxint">
					<xsl:value-of select="number(.)"/>
				</field>
				<field name="year_num">
					<xsl:value-of select="number(.)"/>
				</field>
			</xsl:if>
		</xsl:for-each>

		<xsl:if test="count($dates//date) &gt; 0">
			<field name="date_display">
				<xsl:choose>
					<xsl:when test="$dates//date[1] = $dates//date[last()]">
						<xsl:value-of select="numishare:normalizeDate($dates//date[1])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="numishare:normalizeDate($dates//date[1])"/>
						<xsl:text> - </xsl:text>
						<xsl:value-of select="numishare:normalizeDate($dates//date[last()])"/>
					</xsl:otherwise>
				</xsl:choose>
			</field>
		</xsl:if>

	</xsl:template>

	<xsl:template name="get_hoard_sort_fields">
		<xsl:param name="lang"/>
		<xsl:variable name="localLang" select="
				if (string($lang)) then
					$lang
				else
					'en'"/>
		<!-- sortable fields -->
		<xsl:variable name="sort-fields">
			<xsl:text>artist,authority,deity,denomination,dynasty,issuer,magistrate,maker,manufacture,material,mint,portrait,region</xsl:text>
		</xsl:variable>
		<xsl:for-each select="tokenize($sort-fields, ',')">
			<xsl:variable name="field" select="."/>

			<!-- for each sortable field which is a multiValued field in Solr (a facet), grab the min and max values -->
			<xsl:for-each select="$rdf/descendant::*[local-name() = $field]/skos:prefLabel[@xml:lang = $localLang]">
				<xsl:sort order="ascending"/>
				<xsl:if test="position() = 1">
					<field name="{$field}_min">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:if>
				<xsl:if test="position() = last()">
					<field name="{$field}_max">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="get_coin_sort_fields">
		<xsl:param name="lang"/>
		<xsl:param name="typologies"/>

		<!-- sortable fields -->
		<xsl:variable name="sort-fields">
			<xsl:text>artist,authority,deity,denomination,dynasty,issuer,maker,manufacture,material,mint,portrait,region</xsl:text>
		</xsl:variable>

		<xsl:for-each select="tokenize($sort-fields, ',')">
			<xsl:variable name="field" select="."/>
			<!-- for each sortable field which is a multiValued field in Solr (a facet), grab the min and max values -->
			<xsl:for-each
				select="$typologies//nuds:typeDesc/descendant::*[local-name() = $field and local-name() != 'authority'] | $typologies//nuds:typeDesc/descendant::*[@xlink:role = $field]">
				<xsl:sort order="ascending" select="
						if (@xlink:href) then
							@xlink:href
						else
							."/>
				<xsl:variable name="href" select="@xlink:href"/>
				<xsl:variable name="name" select="
						if (@xlink:role) then
							@xlink:role
						else
							local-name()"/>
				<xsl:variable name="label">
					<xsl:choose>
						<xsl:when test="string($lang)">
							<xsl:choose>
								<xsl:when test="contains($href, 'nomisma.org')">
									<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], $lang)"/>
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
				</xsl:variable>
				<xsl:if test="position() = 1">
					<field name="{$name}_min">
						<xsl:value-of select="$label"/>
					</field>
				</xsl:if>
				<xsl:if test="position() = last()">
					<field name="{$name}_max">
						<xsl:value-of select="$label"/>
					</field>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="get_ref">
		<xsl:choose>
			<xsl:when test="*[local-name() = 'objectXMLWrap']/mods:modsCollection">
				<xsl:value-of select="*[local-name() = 'objectXMLWrap']/mods:modsCollection/mods:mods/@ID"/>
			</xsl:when>
			<xsl:otherwise>
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
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- typeNumber -->
	<xsl:template name="typeNumber">
		<xsl:param name="collection-name"/>

		<xsl:choose>
			<xsl:when test="$collection-name = 'crro'">
				<field name="typeNumber">
					<xsl:value-of select="substring-after(nuds:control/nuds:recordId, 'rrc-')"/>
				</field>
			</xsl:when>
			<xsl:when test="$collection-name = 'ocre'">
				<xsl:variable name="pieces" select="tokenize(nuds:control/nuds:recordId, '\.')"/>

				<field name="typeNumber">
					<xsl:value-of select="
							if (count($pieces) = 4) then
								$pieces[4]
							else
								concat($pieces[4], '.', $pieces[5])"/>
				</field>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- sortid -->
	<xsl:template name="sortid">
		<xsl:param name="collection-name"/>

		<xsl:choose>
			<xsl:when test="$collection-name = 'crro'">
				<field name="sortid">
					<!--<xsl:variable name="segs" select="tokenize(substring-after(nuds:control/nuds:recordId, 'rrc-'), '\.')"/>-->
					<xsl:analyze-string select="substring-after(nuds:control/nuds:recordId, 'rrc-')" regex="([0-9]+)(^[\.]+)?(\.)?([0-9]+)?([A-z]+)?">
						<xsl:matching-substring>
							<xsl:value-of
								select="
									concat(format-number(number(regex-group(1)), '0000'), regex-group(2), regex-group(3), if (number(regex-group(4))) then
										format-number(number(regex-group(4)), '0000')
									else
										'', regex-group(5))"
							/>
						</xsl:matching-substring>
						<xsl:non-matching-substring>
							<xsl:value-of select="."/>
						</xsl:non-matching-substring>
					</xsl:analyze-string>
				</field>
			</xsl:when>

			<xsl:when test="$collection-name = 'igch'">
				<field name="sortid">
					<xsl:value-of select="nh:control/nh:recordId"/>
				</field>
			</xsl:when>

			<xsl:when test="$collection-name = 'ocre'">
				<field name="sortid">
					<xsl:variable name="segs" select="tokenize(nuds:control/nuds:recordId, '\.')"/>
					<xsl:variable name="auth">
						<xsl:choose>
							<xsl:when test="$segs[3] = 'aug'">001</xsl:when>
							<xsl:when test="$segs[3] = 'tib'">002</xsl:when>
							<xsl:when test="$segs[3] = 'gai'">003</xsl:when>
							<xsl:when test="$segs[3] = 'cl'">004</xsl:when>
							<xsl:when test="$segs[3] = 'ner'">
								<xsl:choose>
									<xsl:when test="$segs[2] = '1(2)'">005</xsl:when>
									<xsl:when test="$segs[2] = '2'">015</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$segs[3] = 'clm'">006</xsl:when>
							<xsl:when test="$segs[3] = 'cw'">007</xsl:when>
							<xsl:when test="$segs[3] = 'gal'">008</xsl:when>
							<xsl:when test="$segs[3] = 'ot'">009</xsl:when>
							<xsl:when test="$segs[3] = 'vit'">010</xsl:when>
							<xsl:when test="$segs[3] = 'ves'">011</xsl:when>
							<xsl:when test="$segs[3] = 'tit'">012</xsl:when>
							<xsl:when test="$segs[3] = 'dom'">013</xsl:when>
							<xsl:when test="$segs[3] = 'anys'">014</xsl:when>
							<xsl:when test="$segs[3] = 'tr'">016</xsl:when>
							<xsl:when test="$segs[3] = 'hdn'">017</xsl:when>
							<xsl:when test="$segs[3] = 'ant'">018</xsl:when>
							<xsl:when test="$segs[3] = 'm_aur'">019</xsl:when>
							<xsl:when test="$segs[3] = 'com'">020</xsl:when>
							<xsl:when test="$segs[3] = 'pert'">021</xsl:when>
							<xsl:when test="$segs[3] = 'dj'">022</xsl:when>
							<xsl:when test="$segs[3] = 'pn'">023</xsl:when>
							<xsl:when test="$segs[3] = 'ca'">024</xsl:when>
							<xsl:when test="$segs[3] = 'ss'">025</xsl:when>
							<xsl:when test="$segs[3] = 'crl'">026</xsl:when>
							<xsl:when test="$segs[3] = 'ge'">027</xsl:when>
							<xsl:when test="$segs[3] = 'mcs'">028</xsl:when>
							<xsl:when test="$segs[3] = 'el'">029</xsl:when>
							<xsl:when test="$segs[3] = 'sa'">030</xsl:when>
							<xsl:when test="$segs[3] = 'max_i'">031</xsl:when>
							<xsl:when test="$segs[3] = 'pa'">032</xsl:when>
							<xsl:when test="$segs[3] = 'mxs'">033</xsl:when>
							<xsl:when test="$segs[3] = 'gor_i'">034</xsl:when>
							<xsl:when test="$segs[3] = 'gor_ii'">035</xsl:when>
							<xsl:when test="$segs[3] = 'balb'">036</xsl:when>
							<xsl:when test="$segs[3] = 'pup'">037</xsl:when>
							<xsl:when test="$segs[3] = 'gor_iii_caes'">038</xsl:when>
							<xsl:when test="$segs[3] = 'gor_iii'">039</xsl:when>
							<xsl:when test="$segs[3] = 'ph_i'">040</xsl:when>
							<xsl:when test="$segs[3] = 'pac'">041</xsl:when>
							<xsl:when test="$segs[3] = 'jot'">042</xsl:when>
							<xsl:when test="$segs[3] = 'mar_s'">043</xsl:when>
							<xsl:when test="$segs[3] = 'spon'">044</xsl:when>
							<xsl:when test="$segs[3] = 'tr_d'">045</xsl:when>
							<xsl:when test="$segs[3] = 'tr_g'">046</xsl:when>
							<xsl:when test="$segs[3] = 'vo'">047</xsl:when>
							<xsl:when test="$segs[3] = 'aem'">048</xsl:when>
							<xsl:when test="$segs[3] = 'uran_ant'">049</xsl:when>
							<xsl:when test="$segs[3] = 'val_i'">050</xsl:when>
							<xsl:when test="$segs[3] = 'val_i-gall'">051</xsl:when>
							<xsl:when test="$segs[3] = 'val_i-gall-val_ii-sala'">052</xsl:when>
							<xsl:when test="$segs[3] = 'marin'">053</xsl:when>
							<xsl:when test="$segs[3] = 'gall(1)'">054</xsl:when>
							<xsl:when test="$segs[3] = 'gall_sala(1)'">055</xsl:when>
							<xsl:when test="$segs[3] = 'gall_sals'">056</xsl:when>
							<xsl:when test="$segs[3] = 'sala(1)'">057</xsl:when>
							<xsl:when test="$segs[3] = 'val_ii'">058</xsl:when>
							<xsl:when test="$segs[3] = 'sals'">059</xsl:when>
							<xsl:when test="$segs[3] = 'qjg'">060</xsl:when>
							<xsl:when test="$segs[3] = 'gall(2)'">061</xsl:when>
							<xsl:when test="$segs[3] = 'gall_sala(2)'">062</xsl:when>
							<xsl:when test="$segs[3] = 'sala(2)'">063</xsl:when>
							<xsl:when test="$segs[3] = 'cg'">064</xsl:when>
							<xsl:when test="$segs[3] = 'qu'">065</xsl:when>
							<xsl:when test="$segs[3] = 'aur'">066</xsl:when>
							<xsl:when test="$segs[3] = 'aur_seva'">067</xsl:when>
							<xsl:when test="$segs[3] = 'seva'">068</xsl:when>
							<xsl:when test="$segs[3] = 'tac'">069</xsl:when>
							<xsl:when test="$segs[3] = 'fl'">070</xsl:when>
							<xsl:when test="$segs[3] = 'intr'">071</xsl:when>
							<xsl:when test="$segs[3] = 'pro'">072_01</xsl:when>
							<xsl:when test="$segs[3] = 'car'">072_02</xsl:when>
							<xsl:when test="$segs[3] = 'dio'">072_03</xsl:when>
							<xsl:when test="$segs[3] = 'post'">072_04</xsl:when>
							<xsl:when test="$segs[3] = 'lae'">072_05</xsl:when>
							<xsl:when test="$segs[3] = 'mar'">072_06</xsl:when>
							<xsl:when test="$segs[3] = 'vict'">072_07</xsl:when>
							<xsl:when test="$segs[3] = 'tet_i'">072_08</xsl:when>
							<xsl:when test="$segs[3] = 'cara'">072_09</xsl:when>
							<xsl:when test="$segs[3] = 'cara-dio-max_her'">072_10</xsl:when>
							<xsl:when test="$segs[3] = 'all'">072_11</xsl:when>
							<xsl:when test="$segs[3] = 'mac_ii'">072_12</xsl:when>
							<xsl:when test="$segs[3] = 'quit'">072_13</xsl:when>
							<xsl:when test="$segs[3] = 'zen'">072_14</xsl:when>
							<xsl:when test="$segs[3] = 'vab'">072_15</xsl:when>
							<xsl:when test="$segs[3] = 'reg'">072_16</xsl:when>
							<xsl:when test="$segs[3] = 'dry'">072_17</xsl:when>
							<xsl:when test="$segs[3] = 'aurl'">072_18</xsl:when>
							<xsl:when test="$segs[3] = 'dom_g'">072_19</xsl:when>
							<xsl:when test="$segs[3] = 'sat'">072_20</xsl:when>
							<xsl:when test="$segs[3] = 'bon'">072_21</xsl:when>
							<xsl:when test="$segs[3] = 'jul_i'">072_22</xsl:when>
							<xsl:when test="$segs[3] = 'ama'">072_23</xsl:when>
							<xsl:when test="$segs[2] = '6'">
								<xsl:choose>
									<xsl:when test="$segs[3] = 'lon'">073</xsl:when>
									<xsl:when test="$segs[3] = 'tri'">074</xsl:when>
									<xsl:when test="$segs[3] = 'lug'">075</xsl:when>
									<xsl:when test="$segs[3] = 'tic'">076</xsl:when>
									<xsl:when test="$segs[3] = 'aq'">077</xsl:when>
									<xsl:when test="$segs[3] = 'rom'">078</xsl:when>
									<xsl:when test="$segs[3] = 'ost'">079</xsl:when>
									<xsl:when test="$segs[3] = 'carth'">080</xsl:when>
									<xsl:when test="$segs[3] = 'sis'">081</xsl:when>
									<xsl:when test="$segs[3] = 'serd'">082</xsl:when>
									<xsl:when test="$segs[3] = 'thes'">082a</xsl:when>
									<xsl:when test="$segs[3] = 'her'">083</xsl:when>
									<xsl:when test="$segs[3] = 'nic'">084</xsl:when>
									<xsl:when test="$segs[3] = 'cyz'">085</xsl:when>
									<xsl:when test="$segs[3] = 'anch'">086</xsl:when>
									<xsl:when test="$segs[3] = 'alex'">087</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$segs[2] = '7'">
								<xsl:choose>
									<xsl:when test="$segs[3] = 'lon'">088</xsl:when>
									<xsl:when test="$segs[3] = 'lug'">089</xsl:when>
									<xsl:when test="$segs[3] = 'tri'">090</xsl:when>
									<xsl:when test="$segs[3] = 'ar'">091</xsl:when>
									<xsl:when test="$segs[3] = 'rom'">092</xsl:when>
									<xsl:when test="$segs[3] = 'tic'">093</xsl:when>
									<xsl:when test="$segs[3] = 'aq'">094</xsl:when>
									<xsl:when test="$segs[3] = 'sis'">095</xsl:when>
									<xsl:when test="$segs[3] = 'sir'">096</xsl:when>
									<xsl:when test="$segs[3] = 'serd'">096a</xsl:when>
									<xsl:when test="$segs[3] = 'thes'">097</xsl:when>
									<xsl:when test="$segs[3] = 'her'">098</xsl:when>
									<xsl:when test="$segs[3] = 'cnp'">099</xsl:when>
									<xsl:when test="$segs[3] = 'nic'">100</xsl:when>
									<xsl:when test="$segs[3] = 'cyz'">101</xsl:when>
									<xsl:when test="$segs[3] = 'anch'">102</xsl:when>
									<xsl:when test="$segs[3] = 'alex'">103</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$segs[2] = '8'">
								<xsl:choose>
									<xsl:when test="$segs[3] = 'amb'">104</xsl:when>
									<xsl:when test="$segs[3] = 'tri'">105</xsl:when>
									<xsl:when test="$segs[3] = 'lug'">106</xsl:when>
									<xsl:when test="$segs[3] = 'ar'">107</xsl:when>
									<xsl:when test="$segs[3] = 'med'">107a</xsl:when>
									<xsl:when test="$segs[3] = 'rom'">108</xsl:when>
									<xsl:when test="$segs[3] = 'aq'">109</xsl:when>
									<xsl:when test="$segs[3] = 'sis'">110</xsl:when>
									<xsl:when test="$segs[3] = 'sir'">111</xsl:when>
									<xsl:when test="$segs[3] = 'thes'">112</xsl:when>
									<xsl:when test="$segs[3] = 'her'">113</xsl:when>
									<xsl:when test="$segs[3] = 'cnp'">114</xsl:when>
									<xsl:when test="$segs[3] = 'nic'">115</xsl:when>
									<xsl:when test="$segs[3] = 'cyz'">116</xsl:when>
									<xsl:when test="$segs[3] = 'anch'">117</xsl:when>
									<xsl:when test="$segs[3] = 'alex'">118_00</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$segs[2] = '9'">
								<xsl:choose>
									<xsl:when test="$segs[3] = 'alex'">118_01</xsl:when>
									<xsl:when test="$segs[3] = 'anch'">118_02</xsl:when>
									<xsl:when test="$segs[3] = 'aq'">118_03</xsl:when>
									<xsl:when test="$segs[3] = 'ar'">118_04</xsl:when>
									<xsl:when test="$segs[3] = 'cnp'">118_05</xsl:when>
									<xsl:when test="$segs[3] = 'cyz'">118_06</xsl:when>
									<xsl:when test="$segs[3] = 'her'">118_07</xsl:when>
									<xsl:when test="$segs[3] = 'lon'">118_08</xsl:when>
									<xsl:when test="$segs[3] = 'lug'">118_09</xsl:when>
									<xsl:when test="$segs[3] = 'med'">118_10</xsl:when>
									<xsl:when test="$segs[3] = 'nic'">118_11</xsl:when>
									<xsl:when test="$segs[3] = 'rom'">118_12</xsl:when>
									<xsl:when test="$segs[3] = 'sir'">118_13</xsl:when>
									<xsl:when test="$segs[3] = 'sis'">118_14</xsl:when>
									<xsl:when test="$segs[3] = 'thes'">118_15</xsl:when>
									<xsl:when test="$segs[3] = 'tri'">118_16</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$segs[2] = '10'">
								<xsl:choose>
									<xsl:when test="$segs[3] = 'arc_e'">119</xsl:when>
									<xsl:when test="$segs[3] = 'theo_ii_e'">120</xsl:when>
									<xsl:when test="$segs[3] = 'marc_e'">121</xsl:when>
									<xsl:when test="$segs[3] = 'leo_i_e'">122</xsl:when>
									<xsl:when test="$segs[3] = 'leo_ii_e'">123</xsl:when>
									<xsl:when test="$segs[3] = 'leo_ii-zen_e'">124</xsl:when>
									<xsl:when test="$segs[3] = 'zeno(1)_e'">125</xsl:when>
									<xsl:when test="$segs[3] = 'bas_e'">126</xsl:when>
									<xsl:when test="$segs[3] = 'bas-mar_e'">127</xsl:when>
									<xsl:when test="$segs[3] = 'zeno(2)_e'">128</xsl:when>
									<xsl:when test="$segs[3] = 'leon_e'">129</xsl:when>
									<xsl:when test="$segs[3] = 'hon_w'">130</xsl:when>
									<xsl:when test="$segs[3] = 'pr_att_w'">131</xsl:when>
									<xsl:when test="$segs[3] = 'con_iii_w'">132</xsl:when>
									<xsl:when test="$segs[3] = 'max_barc_w'">133</xsl:when>
									<xsl:when test="$segs[3] = 'jov_w'">134</xsl:when>
									<xsl:when test="$segs[3] = 'theo_ii_w'">135</xsl:when>
									<xsl:when test="$segs[3] = 'joh_w'">136</xsl:when>
									<xsl:when test="$segs[3] = 'valt_iii_w'">137</xsl:when>
									<xsl:when test="$segs[3] = 'pet_max_w'">138</xsl:when>
									<xsl:when test="$segs[3] = 'marc_w'">139</xsl:when>
									<xsl:when test="$segs[3] = 'av_w'">140</xsl:when>
									<xsl:when test="$segs[3] = 'leo_i_w'">141</xsl:when>
									<xsl:when test="$segs[3] = 'maj_w'">142</xsl:when>
									<xsl:when test="$segs[3] = 'lib_sev_w'">143</xsl:when>
									<xsl:when test="$segs[3] = 'anth_w'">144</xsl:when>
									<xsl:when test="$segs[3] = 'oly_w'">145</xsl:when>
									<xsl:when test="$segs[3] = 'glyc_w'">146</xsl:when>
									<xsl:when test="$segs[3] = 'jul_nep_w'">147</xsl:when>
									<xsl:when test="$segs[3] = 'bas_w'">148</xsl:when>
									<xsl:when test="$segs[3] = 'rom_aug_w'">149</xsl:when>
									<xsl:when test="$segs[3] = 'odo_w'">150</xsl:when>
									<xsl:when test="$segs[3] = 'zeno_w'">151</xsl:when>
									<xsl:when test="$segs[3] = 'visi'">152</xsl:when>
									<xsl:when test="$segs[3] = 'gallia'">153</xsl:when>
									<xsl:when test="$segs[3] = 'spa'">154</xsl:when>
									<xsl:when test="$segs[3] = 'afr'">155</xsl:when>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="num">
						<xsl:analyze-string regex="([0-9]+)(.*)" select="$segs[4]">
							<xsl:matching-substring>
								<xsl:value-of select="concat(format-number(number(regex-group(1)), '0000'), regex-group(2))"/>
							</xsl:matching-substring>
						</xsl:analyze-string>
					</xsl:variable>
					<xsl:value-of select="concat($auth, '.', $num)"/>
				</field>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="alternativeLabels">
		<xsl:param name="lang"/>
		<xsl:param name="typeDesc" as="node()*"/>

		<xsl:for-each select="distinct-values($typeDesc/descendant::*[contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
			<xsl:variable name="href" select="."/>

			<xsl:for-each select="$rdf//*[@rdf:about = $href]/descendant::*[contains(local-name(), 'Label')][@xml:lang = $lang]">
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:text> </xsl:text>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
