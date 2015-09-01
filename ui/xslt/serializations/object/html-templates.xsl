<?xml version="1.0" encoding="UTF-8"?>
<!--***************************************** SHARED TEMPLATES AND FUNCTIONS *****************************************
	Author: Ethan Gruber
	Function: this XSLT stylesheet is included into display.xsl.  It contains shared templates and functions that may be used in object-
	specific stylesheets
	Modification date: Febrary 2012
-->
<xsl:stylesheet xmlns:nuds="http://nomisma.org/nuds" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:nm="http://nomisma.org/id/"
	xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="#all" version="2.0">
	<!--***************************************** ELEMENT TEMPLATES **************************************** -->
	<xsl:template match="*[local-name()='refDesc']">
		<xsl:element name="{if (ancestor::subtype) then 'h4' else 'h3'}">
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</xsl:element>
		<ul>
			<xsl:apply-templates select="*:reference[not(child::*[local-name()='objectXMLWrap'])]|*:citation" mode="descMeta"/>
			<xsl:apply-templates select="*:reference/*[local-name()='objectXMLWrap']"/>
		</ul>
	</xsl:template>
	<xsl:template match="nuds:physDesc[child::*]">
		<xsl:element name="{if (ancestor::subtype) then 'h4' else 'h3'}">
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</xsl:element>
		<ul>
			<xsl:apply-templates mode="descMeta"/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:typeDesc">
		<xsl:param name="typeDesc_resource"/>
		<xsl:element name="{if (ancestor::subtype) then 'h4' else 'h3'}">
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</xsl:element>
		<xsl:if test="string($typeDesc_resource)">
			<p>Source: <a href="{$typeDesc_resource}" rel="nmo:hasTypeSeriesItem"><xsl:value-of select="$nudsGroup//object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:title"
				/></a></p>
		</xsl:if>
		<ul>
			<xsl:choose>
				<xsl:when test="ancestor::subtype">
					<xsl:apply-templates select="nuds:obverse|nuds:reverse" mode="descMeta"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="*" mode="descMeta"/>
				</xsl:otherwise>
			</xsl:choose>
		</ul>
	</xsl:template>

	<!-- handle type descriptions in various languages -->
	<xsl:template match="nuds:type" mode="descMeta">
		<xsl:choose>
			<xsl:when test="nuds:description[@xml:lang=$lang]">
				<li>
					<b>
						<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
						<xsl:text>: </xsl:text>
					</b>
					<xsl:value-of select="nuds:description[@xml:lang=$lang]"/>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<li>
					<b>
						<xsl:value-of select="numishare:regularize_node(local-name(), 'en')"/>
						<xsl:text>: </xsl:text>
					</b>
					<xsl:value-of select="nuds:description[@xml:lang='en']"/>
				</li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="descMeta">
		<xsl:choose>
			<xsl:when test="not(child::*) and (string(.) or string(@xlink:href))">
				<xsl:variable name="href" select="@xlink:href"/>
				<!-- the facet field is the @xlink:role if it exists, otherwise it is the name of the nuds element -->
				<xsl:variable name="field">
					<xsl:choose>
						<xsl:when test="string(@xlink:role)">
							<xsl:value-of select="@xlink:role"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="local-name()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<li>
					<!-- display label first for non-Arabic languages -->
					<b>
						<xsl:choose>
							<xsl:when test="string(@localType)">
								<xsl:variable name="langParam" select="if(string($lang)) then $lang else 'en'"/>
								<xsl:variable name="localType" select="@localType"/>
								<xsl:choose>
									<xsl:when test="$localTypes//localType[@value=$localType]/label[@lang=$langParam]">
										<xsl:value-of select="$localTypes//localType[@value=$localType]/label[@lang=$langParam]"/>
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

						<xsl:text>: </xsl:text>
					</b>
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
											<xsl:value-of select="if ($countryCode = 'US' or $countryCode = 'AU' or $countryCode = 'CA') then if ($fcode = 'ADM1') then $name else concat($name, ' (',
												$abbreviations//country[@code=$countryCode]/place[. = $adminName1]/@abbr, ')') else if ($countryCode= 'GB') then  if ($fcode = 'ADM1') then $name else
												concat($name, ' (', $adminName1, ')') else if ($fcode = 'PCLI') then $name else concat($name, ' (', $countryName, ')')"/>
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
						<xsl:when test="not(ancestor::nuds:typeDesc/@xlink:href) and not(ancestor::nuds:refDesc) and not(@xlink:href)">
							<span>
								<xsl:attribute name="property" select="numishare:normalizeProperty($recordType, if(@xlink:role) then @xlink:role else local-name())"/>
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
								</xsl:call-template>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="display-label">
								<xsl:with-param name="field" select="$field"/>
								<xsl:with-param name="value" select="$value"/>
								<xsl:with-param name="href" select="$href"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>



					<!-- display title -->
					<xsl:if test="string(@title)">
						<i> (<xsl:value-of select="@title"/>)</i>
					</xsl:if>
					<!-- display certainty -->
					<xsl:if test="string(@certainty)">
						<i> (<xsl:value-of select="@certainty"/>)</i>
					</xsl:if>
					<!-- display calendar -->
					<xsl:if test="string(@calendar)">
						<i> (<xsl:value-of select="@calendar"/>)</i>
					</xsl:if>
					<!-- create links to resources -->
					<xsl:if test="string($href)">
						<a href="{$href}" target="_blank" rel="{numishare:normalizeProperty($recordType, if(@xlink:role) then @xlink:role else local-name())}">
							<img src="{$include_path}/images/external.png" alt="external link" class="external_link"/>
						</a>
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
									<xsl:if test="local-name()='obverse' or local-name()='reverse'">
										<xsl:attribute name="rel" select="concat('nmo:has', concat(upper-case(substring(local-name(), 1, 1)), substring(local-name(), 2)))"/>
										<xsl:attribute name="resource" select="concat($url, 'id/', $id, '#', local-name())"/>
									</xsl:if>
									<xsl:apply-templates select="*" mode="descMeta"/>
									<!-- if the $recordType is 'conceptual' and there is no legend or description, and thee are subtypes, display the subtype data -->
									<xsl:if test="$recordType='conceptual' and count($subtypes//subtype) &gt; 0">
										<xsl:if test="(local-name() = 'obverse' or local-name()='reverse' ) and not(nuds:type)">
											<xsl:variable name="side" select="local-name()"/>
											<li>
												<b>
													<xsl:value-of select="numishare:regularize_node('description', $lang)"/>
													<xsl:text>: </xsl:text>
												</b>
												<xsl:for-each select="distinct-values($subtypes//subtype/descendant::*[local-name()=$side]/nuds:type/nuds:description[if (string($lang)) then
													@xml:lang=$lang else @xml:lang='en'])">
													<xsl:value-of select="."/>
													<xsl:if test="not(position()=last())"> | </xsl:if>
												</xsl:for-each>
											</li>
										</xsl:if>
										<xsl:if test="(local-name() = 'obverse' or local-name()='reverse' ) and not(nuds:legend)">
											<xsl:variable name="side" select="local-name()"/>
											<li>
												<b>
													<xsl:value-of select="numishare:regularize_node('legend', $lang)"/>
													<xsl:text>: </xsl:text>
												</b>
												<xsl:for-each select="distinct-values($subtypes//subtype/descendant::*[local-name()=$side]/nuds:legend)">
													<xsl:value-of select="."/>
													<xsl:if test="not(position()=last())"> | </xsl:if>
												</xsl:for-each>
											</li>
										</xsl:if>
									</xsl:if>
									<xsl:if test="nuds:symbol[@position='left'] or nuds:symbol[@position='center'] or nuds:symbol[@position='right'] or nuds:symbol[@position='exergue']">
										<xsl:call-template name="format-control-marks"/>
									</xsl:if>
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
	<xsl:template name="display-label">
		<xsl:param name="field"/>
		<xsl:param name="value"/>
		<xsl:param name="href"/>

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
	</xsl:template>

	<!-- *************** HANDLE SUBTYPES DELIVERED FROM XQUERY ******************-->
	<xsl:template match="subtype">
		<xsl:param name="uri_space"/>
		<xsl:variable name="subtypeId" select="@recordId"/>
		<div class="row">
			<div class="col-md-3" about="{concat($uri_space, $subtypeId)}" typeof="nmo:TypeSeriesItem">
				<h4 property="dcterms:title">
					<a href="{concat($uri_space, $subtypeId)}">
						<xsl:value-of select="nuds:descMeta/nuds:title"/>
					</a>
				</h4>
				<span class="hidden" property="skos:broader">
					<xsl:value-of select="concat($uri_space, $id)"/>
				</span>
				<ul>
					<xsl:apply-templates select="nuds:descMeta/*[not(local-name()='title')]"/>
				</ul>
			</div>
			<div class="col-md-9">
				<xsl:if test="string($sparql_endpoint)">
					<xsl:copy-of select="document(concat($request-uri, 'sparql?uri=', $uri_space, $subtypeId, '&amp;template=display&amp;subtype=true&amp;lang=', $lang))/div[@class='row']"/>
				</xsl:if>
			</div>
		</div>
		<hr/>
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
		<xsl:for-each select="mods:name[@type='personal']">
			<xsl:choose>
				<xsl:when test="position() = 1">
					<xsl:value-of select="mods:namePart[@type='family']"/>
					<xsl:text>, </xsl:text>
					<xsl:value-of select="mods:namePart[@type='given']"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- create separator -->
					<xsl:choose>
						<xsl:when test="position()=last()"> and </xsl:when>
						<xsl:otherwise>, </xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="mods:namePart[@type='given']"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mods:namePart[@type='family']"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="position()=last()">
				<xsl:text>. </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<!-- title -->
		<xsl:choose>
			<!-- when it is a journal article -->
			<xsl:when test="mods:relatedItem[@type='host']">
				<!-- article title -->
				<xsl:text>"</xsl:text>
				<xsl:apply-templates select="mods:titleInfo"/>
				<xsl:text>." </xsl:text>
				<!-- journal title and publication -->
				<i>
					<xsl:apply-templates select="mods:relatedItem[@type='host']/mods:titleInfo"/>
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
		<xsl:if test="mods:detail[@type='volume']">
			<xsl:text> </xsl:text>
			<xsl:value-of select="mods:detail[@type='volume']/mods:number"/>
		</xsl:if>
		<xsl:if test="mods:date">
			<xsl:text> (</xsl:text>
			<xsl:value-of select="mods:date"/>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="mods:extent[@unit='page']"/>
	</xsl:template>
	<xsl:template match="mods:extent[@unit='page']">
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
	<!--***************************************** OPTIONS BAR **************************************** -->
	<xsl:template name="icons">
		<div class="row pull-right icons">
			<div class="col-md-12">
				<ul class="list-inline">
					<li>
						<strong>SHARE:</strong>
					</li>
					<li>
						<!-- AddThis Button BEGIN -->
						<div class="addthis_toolbox addthis_default_style">
							<a class="addthis_button_preferred_1"/>
							<a class="addthis_button_preferred_2"/>
							<a class="addthis_button_preferred_3"/>
							<a class="addthis_button_preferred_4"/>
							<a class="addthis_button_compact"/>
							<a class="addthis_counter addthis_bubble_style"/>
						</div>
						<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=xa-525d63ef6a07cd89"/>
					</li>
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
					<li>
						<a href="{$id}.kml">KML</a>
					</li>
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
</xsl:stylesheet>
