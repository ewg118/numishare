<?xml version="1.0" encoding="UTF-8"?>
<!--***************************************** SHARED TEMPLATES AND FUNCTIONS *****************************************
	Author: Ethan Gruber
	Function: this XSLT stylesheet is included into display.xsl.  It contains shared templates and functions that may be used in object-
	specific stylesheets
	Modification date: Febrary 2012
-->
<xsl:stylesheet xmlns:nuds="http://nomisma.org/nuds" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:nm="http://nomisma.org/id/"
	exclude-result-prefixes="#all" version="2.0">

	<!--***************************************** ELEMENT TEMPLATES **************************************** -->
	<xsl:template match="*[local-name()='refDesc']">
		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>
		<ul>
			<xsl:apply-templates select="*:reference[not(child::*[local-name()='objectXMLWrap'])]|*:citation" mode="descMeta"/>
			<xsl:apply-templates select="*:reference/*[local-name()='objectXMLWrap']"/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:physDesc[child::*]">
		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>
		<ul>
			<xsl:apply-templates mode="descMeta"/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:typeDesc">
		<xsl:param name="typeDesc_resource"/>
		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>
		<xsl:if test="string($typeDesc_resource)">
			<p>Source: <a href="{$typeDesc_resource}"><xsl:value-of select="$nudsGroup//object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:title"/></a></p>
		</xsl:if>
		<ul>
			<xsl:apply-templates mode="descMeta"/>
		</ul>
	</xsl:template>

	<xsl:template match="*" mode="descMeta">
		<xsl:variable name="facets">
			<xsl:text>artist,authority,category,collection,decoration,deity,degree,denomination,department,dynasty,engraver,era,findspot,grade,institution,issuer,portrait,manufacture,maker,material,mint,objectType,owner,region,repository,script,state,subject</xsl:text>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="not(child::*) and (string(.) or string(@xlink:href))">
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
					<!-- display label first for non-Arabic languages -->
					<xsl:if test="not($lang='ar')">
						<b>
							<xsl:value-of select="numishare:regularize_node($field, $lang)"/>
							<xsl:text>: </xsl:text>
						</b>
					</xsl:if>


					<!-- create link from facet, if applicable -->

					<!-- pull language from nomisma, if available -->
					<xsl:variable name="value">
						<xsl:choose>
							<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
								<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about=$href], $lang)"/>
							</xsl:when>
							<xsl:when test="contains($href, 'geonames.org') and not(string(.))">
								<xsl:variable name="geonameId" select="tokenize($href, '/')[4]"/>
								<xsl:choose>
									<xsl:when test="number($geonameId)">
										<xsl:variable name="geonames_data" as="element()*">
											<results>
												<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
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
												select="if ($countryCode = 'US' or $countryCode = 'AU' or $countryCode = 'CA') then if ($fcode = 'ADM1') then $name else concat($name, ' (', $abbreviations//country[@code=$countryCode]/place[. = $adminName1]/@abbr, ')') else if ($countryCode= 'GB') then  if ($fcode = 'ADM1') then $name else concat($name, ' (', $adminName1, ')') else if ($fcode = 'PCLI') then $name else concat($name, ' (', $countryName, ')')"
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
										<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about=$href], 'en')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(.)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:choose>
						<xsl:when test="contains($facets, $field)">
							<a href="{$display_path}results?q={$field}_facet:&#x022;{$value}&#x022;{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
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

					<!-- display title -->
					<xsl:if test="string(@title)">
						<i>
							<xsl:text> (</xsl:text>
							<xsl:value-of select="@title"/>
							<xsl:text>)</xsl:text>
						</i>
					</xsl:if>

					<!-- display certainty -->
					<xsl:if test="string(@certainty)">
						<i>
							<xsl:text> (</xsl:text>
							<xsl:value-of select="@certainty"/>
							<xsl:text>)</xsl:text>
						</i>
					</xsl:if>

					<xsl:if test="string(@calendar)">
						<i> (calendar: <xsl:value-of select="@calendar"/>)</i>
					</xsl:if>

					<!-- display language -->
					<!--<xsl:if test="string(@xml:lang)">
						<xsl:text> (</xsl:text>
						<xsl:value-of select="@xml:lang"/>
						<xsl:text>)</xsl:text>
					</xsl:if>-->

					<!-- create links to resources -->
					<xsl:if test="string($href)">
						<a href="{$href}" target="_blank" title="{if (contains($href, 'geonames')) then 'geonames' else if (contains($href, 'nomisma')) then 'nomisma' else ''}">
							<img src="{$display_path}images/external.png" alt="external link" class="external_link"/>
						</a>
					</xsl:if>

					<!-- display label on right for right-to-left scripts -->
					<xsl:if test="$lang='ar'">
						<b>
							<xsl:text> : </xsl:text>
							<xsl:value-of select="numishare:regularize_node($field, $lang)"/>

						</b>
					</xsl:if>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$recordType='conceptual' or $recordType='hoard'">
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
									<xsl:apply-templates select="*" mode="descMeta"/>
								</ul>
							</li>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<!-- suppress type and legend from nested list output for physical records: these fields are displayed with the images -->
						<xsl:if test="child::*[not(local-name()='type' or local-name()='legend')]">
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
									<xsl:apply-templates select="*[not(local-name()='type' or local-name()='legend')]" mode="descMeta"/>
								</ul>
							</li>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name()='objectXMLWrap']">
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
				<xsl:when test="child::*[local-name()='modsCollection']">
					<xsl:call-template name="mods-citation"/>
				</xsl:when>
			</xsl:choose>
		</li>
	</xsl:template>

	<!--***************************************** CREATE LINK FROM CATEGORY **************************************** -->
	<xsl:template name="assemble_category_query">
		<xsl:param name="level"/>
		<xsl:param name="tokenized-category"/>

		<xsl:for-each select="$tokenized-category[position() &lt;= $level]">
			<xsl:value-of select="concat('+&#x022;L', position(), '|', ., '&#x022;')"/>
		</xsl:for-each>

		<xsl:if test="position() &lt;= $level">
			<xsl:variable name="category-query">
				<xsl:call-template name="assemble_category_query">
					<xsl:with-param name="level" as="xs:integer" select="$level + 1"/>
					<xsl:with-param name="tokenized-category" select="$tokenized-category"/>
				</xsl:call-template>
			</xsl:variable>
		</xsl:if>
	</xsl:template>
	<!--***************************************** EXTERNAL LINKS **************************************** -->

	<xsl:template name="external_links">
		<div class="metadata_section">
			<h2>External Links</h2>
			<ul>
				<xsl:for-each select="document(concat($solr-url, 'select?q=id:&#x022;', $id, '&#x022;))//arr[@name='nomisma_uri']/str">
					<li>
						<b>Nomisma: </b>
						<a href="{.}" target="_blank">
							<xsl:value-of select="."/>
						</a>
					</li>
				</xsl:for-each>
				<xsl:for-each select="document(concat($solr-url, 'select?q=id:&#x022;', $id, '&#x022;))//arr[@name='pleiades_uri']/str">
					<li>
						<b>Pleiades: </b>
						<a href="{.}" target="_blank">
							<xsl:value-of select="."/>
						</a>
					</li>
				</xsl:for-each>
			</ul>
		</div>
	</xsl:template>
	<!--***************************************** OPTIONS BAR **************************************** -->
	<xsl:template name="icons">
		<div class="row pull-right icons">
			<div class="col-md-12">
				<!-- AddThis Button BEGIN -->
				<div class="addthis_toolbox addthis_default_style">
					<a class="addthis_button_preferred_1"/>
					<a class="addthis_button_preferred_2"/>
					<a class="addthis_button_preferred_3"/>
					<a class="addthis_button_preferred_4"/>
					<a class="addthis_button_compact"/>
					<a class="addthis_counter addthis_bubble_style"/>
					<xsl:text> | </xsl:text>
					<a href="{$id}.xml">NUDS/XML</a>
					<xsl:text> | </xsl:text>
					<a href="{$id}.rdf">Nomisma RDF/XML</a>
					<xsl:text> | </xsl:text>
					<a href="{$id}.kml">KML</a>
				</div>
				<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=xa-525d63ef6a07cd89"/>
				<!-- AddThis Button END -->
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

</xsl:stylesheet>
