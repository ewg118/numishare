<?xml version="1.0" encoding="UTF-8"?>
<!--***************************************** SHARED TEMPLATES AND FUNCTIONS *****************************************
	Author: Ethan Gruber
	Function: this XSLT stylesheet is included into display.xsl.  It contains shared templates and functions that may be used in object-
	specific stylesheets
	Modification date: Febrary 2012
-->
<xsl:stylesheet xmlns:nuds="http://nomisma.org/nuds" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" xmlns:numishare="http://code.google.com/p/numishare/"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:nm="http://nomisma.org/id/" exclude-result-prefixes="#all" version="2.0">

	<!--***************************************** ELEMENT TEMPLATES **************************************** -->
	<xsl:template match="*[local-name()='refDesc']">
		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>
		<ul>
			<xsl:apply-templates mode="descMeta"/>
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
			<p>Source: <a href="{$typeDesc_resource}"><xsl:value-of select="exsl:node-set($nudsGroup)/nudsGroup/object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:title"/></a></p>
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
			<xsl:when test="not(child::*)">
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
								<xsl:choose>
									<xsl:when test="string(exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel[@xml:lang=$lang])">
										<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel[@xml:lang=$lang]"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel[@xml:lang='en']"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="string($lang) and contains($href, 'geonames.org')">
								<xsl:variable name="geonameId" select="substring-before(substring-after($href, 'geonames.org/'), '/')"/>
								<xsl:variable name="geonames_data" select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
								<xsl:choose>
									<xsl:when test="count(exsl:node-set($geonames_data)//alternateName[@lang=$lang]) &gt; 0">
										<xsl:for-each select="exsl:node-set($geonames_data)//alternateName[@lang=$lang]">
											<xsl:value-of select="."/>
											<xsl:if test="not(position()=last())">
												<xsl:text>/</xsl:text>
											</xsl:if>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="exsl:node-set($geonames_data)//name"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<!-- if there is no text value and it points to nomisma.org, grab the prefLabel -->
								<xsl:choose>
									<xsl:when test="not(string(normalize-space(.))) and contains($href, 'nomisma.org')">
										<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel[@xml:lang='en']"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="."/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:choose>
						<xsl:when test="contains($facets, $field)">
							<a href="{$display_path}results?q={$field}_facet:&#x022;{normalize-space(.)}&#x022;{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
								<xsl:value-of select="$value"/>
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
						<!-- parse nomisma RDFa, create links for pleiades and wikipedia -->
						<!--<xsl:if test="contains($href, 'nomisma.org')">
							<xsl:for-each select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:related">
								<xsl:variable name="source">
									<xsl:choose>
										<xsl:when test="contains(@rdf:resource, 'pleiades')">
											<xsl:text>pleiades</xsl:text>
										</xsl:when>
										<xsl:when test="contains(@rdf:resource, 'wikipedia')">
											<xsl:text>wikipedia</xsl:text>
										</xsl:when>
									</xsl:choose>
								</xsl:variable>

								<a href="{@rdf:resource}" target="_blank" title="{$source}">
									<img src="{$display_path}images/{$source}.png" alt="{$source}" class="external_link"/>
								</a>
							</xsl:for-each>
						</xsl:if>-->
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
		<div class="yui3-u-1">
			<div class="submenu">
				<div class="icon">
					<a href="{$id}.xml">
						<img src="{$display_path}images/xml.png" title="XML" alt="XML"/>
					</a>
				</div>
				<div class="icon">
					<a href="{$id}.rdf">
						<img src="{$display_path}images/rdf.gif" title="RDF" alt="RDF"/>
					</a>
				</div>
				<div class="icon">AddThis could go here...</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
