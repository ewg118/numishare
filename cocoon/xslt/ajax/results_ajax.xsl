<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:cinclude="http://apache.org/cocoon/include/1.0" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../functions.xsl"/>
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../sparql/templates.xsl"/>
	<xsl:include href="../results_generic.xsl"/>
	<xsl:param name="pipeline"/>
	<xsl:param name="lang"/>

	<xsl:variable name="display_path">
		<xsl:choose>
			<xsl:when test="$pipeline='maps'"/>
			<xsl:when test="$pipeline='maps_fullscreen'">../</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:variable>

	<xsl:param name="q"/>
	<xsl:param name="sort"/>
	<xsl:param name="rows">24</xsl:param>
	<xsl:param name="start"/>
	<xsl:param name="tokenized_q" select="tokenize($q, ' AND ')"/>

	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>

	<!-- config variables -->
	<xsl:variable name="sparql_endpoint" select="/content//sparql_endpoint"/>
	<xsl:variable name="url" select="/content//url"/>

	<!-- get block of images from SPARQL endpoint -->
	<xsl:variable name="sparqlResult" as="element()*">
		<xsl:if test="string($sparql_endpoint)">
			<xsl:variable name="identifiers">
				<xsl:for-each select="descendant::str[@name='recordId']">
					<xsl:value-of select="."/>
					<xsl:if test="not(position()=last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="response" as="element()*">
				<xsl:copy-of select="document(concat('cocoon:/widget?identifiers=', $identifiers, '&amp;template=results&amp;baseUri=http://nomisma.org/id/'))/res:sparql"/>
			</xsl:variable>

			<!-- process sparql into a manageable XML model -->
			<response xmlns="http://www.w3.org/2005/sparql-results#">
				<xsl:for-each select="descendant::str[@name='recordId']">
					<xsl:variable name="uri" select="concat('http://nomisma.org/id/', .)"/>
					<group>
						<xsl:attribute name="id" select="."/>
						<xsl:for-each select="distinct-values($response/descendant::res:result[res:binding[@name='type']/res:uri=$uri]/res:binding[@name='object']/res:uri)">
							<xsl:variable name="objectUri" select="."/>
							<xsl:copy-of select="$response/descendant::res:result[res:binding[@name='object']/res:uri=$objectUri][1]"/>
						</xsl:for-each>
					</group>
				</xsl:for-each>
			</response>
		</xsl:if>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:variable name="place_string" select="replace(translate($tokenized_q[contains(., '_uri')], '&#x022;()', ''), '[a-z]+_uri:', '')"/>
		<xsl:variable name="places" select="tokenize($place_string, ' OR ')"/>

		<h1>
			<xsl:text>Place</xsl:text>
			<xsl:if test="contains($place_string, ' OR ')">
				<xsl:text>s</xsl:text>
			</xsl:if>
			<xsl:text>: </xsl:text>
			<xsl:for-each select="$places">
				<xsl:value-of select="."/>
				<xsl:if test="not(position() = last())">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<small>
				<a id="clear_all" href="#">clear</a>
			</small>
		</h1>
		<xsl:call-template name="paging"/>
		<xsl:apply-templates select="descendant::doc" mode="map"/>
		<xsl:call-template name="paging"/>
	</xsl:template>

	<xsl:template match="doc" mode="map">
		<xsl:variable name="sort_category" select="substring-before($sort, ' ')"/>
		<xsl:variable name="regularized_sort">
			<xsl:value-of select="numishare:normalize_fields($sort_category, $lang)"/>
		</xsl:variable>

		<div class="g_doc col-md-4">
			<span class="result_link">
				<a href="{$display_path}id/{str[@name='recordId']}{if (string($lang)) then concat('?lang=', $lang) else ''}" target="_blank">
					<xsl:value-of select="str[@name='title_display']"/>
				</a>
			</span>
			<dl>
				<xsl:choose>
					<xsl:when test="str[@name='recordType'] = 'hoard'">
						<dt>
							<xsl:if test="$lang='ar'">
								<xsl:attribute name="class">ar</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
						</dt>
						<dd>
							<xsl:if test="$lang='ar'">
								<xsl:attribute name="class">ar</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="arr[@name='findspot_facet']/str[1]"/>
						</dd>
						<dt>
							<xsl:if test="$lang='ar'">
								<xsl:attribute name="class">ar</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/>
						</dt>
						<dd>
							<xsl:if test="$lang='ar'">
								<xsl:attribute name="class">ar</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="str[@name='closing_date_display']"/>
						</dd>
						<xsl:if test="string(str[@name='description_display'])">
							<dt>
								<xsl:if test="$lang='ar'">
									<xsl:attribute name="class">ar</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="numishare:regularize_node('description', $lang)"/>
							</dt>
							<dd>
								<xsl:if test="$lang='ar'">
									<xsl:attribute name="class">ar</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="str[@name='description_display']"/>
							</dd>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string(str[@name='date_display'])">
							<dt>
								<xsl:value-of select="numishare:regularize_node('date', $lang)"/>
							</dt>
							<dd>
								<xsl:value-of select="str[@name='date_display']"/>
							</dd>
						</xsl:if>
						<xsl:if test="string(arr[@name='denomination_facet']/str[1])">
							<dt>
								<xsl:value-of select="numishare:regularize_node('denomination', $lang)"/>
							</dt>
							<dd>
								<xsl:for-each select="arr[@name='denomination_facet']/str">
									<xsl:value-of select="."/>
									<xsl:if test="not(position() = last())">
										<xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</dd>
						</xsl:if>
						<xsl:if test="string(arr[@name='mint_facet']/str[1])">
							<dt>
								<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
							</dt>
							<dd>
								<xsl:for-each select="arr[@name='mint_facet']/str">
									<xsl:value-of select="."/>
									<xsl:if test="not(position() = last())">
										<xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</dd>
						</xsl:if>
						<xsl:if test="str[@name='obv_leg_display'] or str[@name='obv_type_display']">
							<dt>
								<xsl:if test="$lang='ar'">
									<xsl:attribute name="class">ar</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="numishare:regularize_node('obverse', $lang)"/>
							</dt>
							<dd>
								<xsl:if test="$lang='ar'">
									<xsl:attribute name="class">ar</xsl:attribute>
								</xsl:if>
								<xsl:value-of
									select="if (string-length(str[@name='obv_leg_display']) &gt; 30) then concat(substring(str[@name='obv_leg_display'], 1, 30), '...') else str[@name='obv_leg_display']"/>
								<xsl:if test="str[@name='obv_leg_display'] and str[@name='obv_type_display']">
									<xsl:text>: </xsl:text>
								</xsl:if>
								<xsl:value-of
									select="if (string-length(str[@name='obv_type_display']) &gt; 30) then concat(substring(str[@name='obv_type_display'], 1, 30), '...') else str[@name='obv_type_display']"
								/>
							</dd>
						</xsl:if>
						<xsl:if test="str[@name='rev_leg_display'] or str[@name='rev_type_display']">
							<dt>
								<xsl:if test="$lang='ar'">
									<xsl:attribute name="class">ar</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="numishare:regularize_node('reverse', $lang)"/>
							</dt>
							<dd>
								<xsl:if test="$lang='ar'">
									<xsl:attribute name="class">ar</xsl:attribute>
								</xsl:if>
								<xsl:value-of
									select="if (string-length(str[@name='rev_leg_display']) &gt; 30) then concat(substring(str[@name='rev_leg_display'], 1, 30), '...') else str[@name='rev_leg_display']"/>
								<xsl:if test="str[@name='rev_leg_display'] and str[@name='rev_type_display']">
									<xsl:text>: </xsl:text>
								</xsl:if>
								<xsl:value-of
									select="if (string-length(str[@name='rev_type_display']) &gt; 30) then concat(substring(str[@name='rev_type_display'], 1, 30), '...') else str[@name='rev_type_display']"
								/>
							</dd>
						</xsl:if>
						<xsl:if test="int[@name='axis_num']">
							<dt>
								<xsl:if test="$lang='ar'">
									<xsl:attribute name="class">ar</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>
							</dt>
							<dd>
								<xsl:if test="$lang='ar'">
									<xsl:attribute name="class">ar</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="int[@name='axis_num']"/>
							</dd>
						</xsl:if>
						<xsl:if test="float[@name='diameter_num']">
							<dt>
								<xsl:if test="$lang='ar'">
									<xsl:attribute name="class">ar</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>
							</dt>
							<dd>
								<xsl:if test="$lang='ar'">
									<xsl:attribute name="class">ar</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="float[@name='diameter_num']"/>
							</dd>
						</xsl:if>
						<xsl:if test="float[@name='weight_num']">
							<dt>
								<xsl:if test="$lang='ar'">
									<xsl:attribute name="class">ar</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="numishare:regularize_node('weight', $lang)"/>
							</dt>
							<dd>
								<xsl:if test="$lang='ar'">
									<xsl:attribute name="class">ar</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="float[@name='weight_num']"/>
							</dd>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</dl>

			<div class="gi_c">
				<xsl:choose>
					<xsl:when test="str[@name='recordType'] = 'physical'">
						<xsl:if test="string(str[@name='thumbnail_obv'])">
							<a class="thumbImage" href="{str[@name='reference_obv']}" title="Obverse of {str[@name='title_display']}">
								<img src="{str[@name='thumbnail_obv']}"/>
							</a>
						</xsl:if>
						<xsl:if test="string(str[@name='thumbnail_rev'])">
							<a class="thumbImage" href="{str[@name='reference_rev']}" title="Reverse of {str[@name='title_display']}">
								<img src="{str[@name='thumbnail_rev']}"/>
							</a>
						</xsl:if>
					</xsl:when>
					<xsl:when test="str[@name='recordType'] = 'conceptual'">
						<xsl:choose>
							<xsl:when test="string($sparql_endpoint)">
								<xsl:variable name="id" select="str[@name='recordId']"/>
								<xsl:variable name="group" as="element()*">
									<xsl:copy-of select="$sparqlResult//res:group[@id=$id]"/>
								</xsl:variable>

								<xsl:call-template name="numishare:renderSparqlResults">
									<xsl:with-param name="group" select="$group"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="count" select="count(arr[@name='ao_uri']/str)"/>
								<xsl:variable name="title" select="str[@name='title_display']	"/>
								<xsl:variable name="docId" select="str[@name='recordId']"/>

								<xsl:if test="count(arr[@name='ao_thumbnail_obv']/str) &gt; 0">
									<xsl:variable name="recordId" select="substring-before(arr[@name='ao_thumbnail_obv']/str[1], '|')"/>
									<a class="thumbImage" rel="{str[@name='recordId']}-gallery" href="{substring-after(arr[@name='ao_reference_obv']/str[contains(., $recordId)], '|')}"
										title="Obverse of {$title}: {$recordId}">
										<img src="{substring-after(arr[@name='ao_thumbnail_obv']/str[1], '|')}"/>
									</a>
									<xsl:if test="arr[@name='ao_thumbnail_rev']/str[contains(., $recordId)]">
										<a class="thumbImage" rel="{str[@name='recordId']}-gallery" href="{substring-after(arr[@name='ao_reference_rev']/str[contains(., $recordId)], '|')}"
											title="Reverse of {$title}: {$recordId}">
											<img src="{substring-after(arr[@name='ao_thumbnail_rev']/str[contains(., $recordId)], '|')}"/>
										</a>
									</xsl:if>
									<div style="display:none">
										<xsl:for-each select="arr[@name='ao_thumbnail_obv']/str[not(contains(., $recordId))]">
											<xsl:variable name="thisId" select="substring-before(., '|')"/>
											<a class="thumbImage" rel="{$docId}-gallery" href="{substring-after(//arr[@name='ao_reference_obv']/str[contains(., $thisId)], '|')}"
												title="Obverse of {$title}: {$thisId}">
												<img src="{substring-after(., '|')}" alt="image"/>
											</a>
											<xsl:if test="//arr[@name='ao_thumbnail_rev']/str[contains(., $thisId)]">
												<a class="thumbImage" rel="{$docId}-gallery" href="{substring-after(ancestor::doc/arr[@name='ao_reference_rev']/str[contains(., $thisId)], '|')}"
													title="Reverse of {$title}: {$thisId}">
													<img src="{substring-after(//arr[@name='ao_thumbnail_rev']/str[contains(., $thisId)], '|')}"/>
												</a>
											</xsl:if>
										</xsl:for-each>
									</div>
								</xsl:if>
								<br/>
								<xsl:value-of select="concat($count, if($count = 1) then ' associated coin' else ' associated coins')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
