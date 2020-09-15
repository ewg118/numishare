<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Modified: April 2020
	Function: This stylesheet transforms a nudsHoard XML document into Solr
-->
<xsl:stylesheet version="2.0" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:nuds="http://nomisma.org/nuds" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:gml="http://www.opengis.net/gml"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all">
	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:template name="nudsHoard">
		<!-- create default document -->
		<xsl:apply-templates select="//nh:nudsHoard">
			<xsl:with-param name="lang"/>
		</xsl:apply-templates>

		<!-- create documents for each additional activated language -->
		<xsl:for-each select="//config/descendant::language[@enabled = 'true']">
			<xsl:apply-templates select="//nh:nudsHoard">
				<xsl:with-param name="lang" select="@code"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nh:nudsHoard">
		<xsl:param name="lang"/>

		<xsl:variable name="hasContents" as="xs:boolean">
			<xsl:choose>
				<xsl:when test="count(nh:descMeta/nh:contentsDesc/nh:contents/*) &gt; 0">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<doc>
			<field name="id">
				<xsl:choose>
					<xsl:when test="string($lang)">
						<xsl:value-of select="concat(nh:control/nh:recordId, '-', $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="nh:control/nh:recordId"/>
					</xsl:otherwise>
				</xsl:choose>
			</field>
			<xsl:call-template name="sortid">
				<xsl:with-param name="collection-name" select="$collection-name"/>
			</xsl:call-template>
			<field name="recordId">
				<xsl:value-of select="nh:control/nh:recordId"/>
			</field>
			<xsl:if test="string($lang)">
				<field name="lang">
					<xsl:value-of select="$lang"/>
				</field>
			</xsl:if>
			<field name="collection-name">
				<xsl:value-of select="$collection-name"/>
			</field>
			<field name="title_display">
				<xsl:choose>
					<xsl:when test="nh:descMeta/nh:title">
						<xsl:value-of select="normalize-space(nh:descMeta/nh:title[1])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="nh:control/nh:recordId"/>
					</xsl:otherwise>
				</xsl:choose>
			</field>
			<field name="recordType">hoard</field>
			<field name="publisher_display">
				<xsl:value-of select="$publisher"/>
			</field>
			<field name="hasContents">
				<xsl:value-of select="$hasContents"/>
			</field>

			<!-- closing date, derive from deposit first -->
			<xsl:if test="not(descendant::nh:deposit[nh:date or nh:dateRange]) and not(descendant::nh:closingDate[nh:date or nh:dateRange])">
				<xsl:if test="$hasContents = true()">

					<!-- derive dates from contents if the nh:deposit is not set -->
					<xsl:variable name="all-dates" as="element()*">
						<dates>
							<xsl:for-each select="descendant::nuds:typeDesc">
								<xsl:if test="index-of(//config/certainty_codes/code[@accept = 'true'], @certainty)">
									<xsl:choose>
										<xsl:when test="string(@xlink:href)">
											<xsl:variable name="href" select="@xlink:href"/>
											<xsl:for-each select="$nudsGroup//object[@xlink:href = $href]/descendant::*/@standardDate">
												<xsl:if test="number(.)">
													<date>
														<xsl:value-of select="."/>
													</date>
												</xsl:if>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<xsl:for-each select="descendant::*/@standardDate">
												<xsl:if test="number(.)">
													<date>
														<xsl:value-of select="."/>
													</date>
												</xsl:if>
											</xsl:for-each>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
							</xsl:for-each>
						</dates>
					</xsl:variable>

					<xsl:variable name="dates" as="element()*">
						<dates>
							<xsl:for-each select="distinct-values($all-dates//date)">
								<xsl:sort data-type="number"/>
								<date>
									<xsl:value-of select="."/>
								</date>
							</xsl:for-each>
						</dates>
					</xsl:variable>


					<field name="closing_date_display">
						<xsl:value-of select="numishare:normalizeDate($dates/date[last()])"/>
					</field>
					<xsl:if test="count($dates/date) &gt; 0">
						<field name="tpq_num">
							<xsl:value-of select="number($dates/date[1])"/>
						</field>
						<field name="taq_num">
							<xsl:value-of select="number($dates/date[last()])"/>
						</field>
					</xsl:if>

				</xsl:if>
			</xsl:if>

			<field name="timestamp">
				<xsl:choose>
					<xsl:when test="descendant::*:maintenanceEvent[last()]/*:eventDateTime/@standardDateTime castable as xs:dateTime">
						<xsl:value-of select="format-dateTime(xs:dateTime(descendant::*:maintenanceEvent[last()]/*:eventDateTime/@standardDateTime), '[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01]Z')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01]Z')"/>
						/>
					</xsl:otherwise>
				</xsl:choose>
			</field>

			<xsl:apply-templates select="nh:descMeta">
				<xsl:with-param name="lang" select="$lang"/>
			</xsl:apply-templates>

			<!-- apply templates for those typeDescs contained explicitly within the hoard -->
			<xsl:for-each select="descendant::nuds:typeDesc">
				<xsl:choose>
					<xsl:when test="string(@xlink:href)">
						<xsl:variable name="href" select="@xlink:href"/>
						<xsl:apply-templates select="$nudsGroup//object[@xlink:href = $href]/descendant::nuds:typeDesc">
							<xsl:with-param name="recordType">hoard</xsl:with-param>
							<xsl:with-param name="lang" select="$lang"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select=".">
							<xsl:with-param name="recordType">hoard</xsl:with-param>
							<xsl:with-param name="lang" select="$lang"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>

			<!-- insert coin type facets and URIs -->
			<xsl:for-each select="descendant::nuds:typeDesc[string(@xlink:href)]">
				<xsl:variable name="href" select="@xlink:href"/>
				<field name="coinType_uri">
					<xsl:value-of select="$href"/>
				</field>
				<field name="coinType_facet">
					<xsl:value-of select="$nudsGroup//object[@xlink:href = $href]/descendant::nuds:title"/>
				</field>
			</xsl:for-each>

			<!-- get sortable fields: distinct values in $nudsGroup -->
			<xsl:call-template name="get_hoard_sort_fields">
				<xsl:with-param name="lang" select="$lang"/>
			</xsl:call-template>

			<field name="fulltext">
				<xsl:for-each select="descendant-or-self::text()">
					<xsl:value-of select="normalize-space(.)"/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</field>
		</doc>
	</xsl:template>

	<xsl:template match="nh:descMeta">
		<xsl:param name="lang"/>

		<xsl:apply-templates select="nh:hoardDesc">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nh:refDesc"/>
		<xsl:apply-templates select="nh:contentsDesc">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates select="nh:subjectSet"/>
	</xsl:template>

	<xsl:template match="nh:hoardDesc">
		<xsl:param name="lang"/>

		<xsl:apply-templates select="nh:findspot">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="nh:deposit[nh:date or nh:dateRange] | nh:discovery[nh:date or nh:dateRange] | nh:closingDate[nh:date or nh:dateRange]"/>
	</xsl:template>

	<xsl:template match="nh:findspot">
		<xsl:param name="lang"/>

		<xsl:if test="nh:description">
			<field name="findspot_display">
				<xsl:value-of select="numishare:display-description(self::node(), $lang)"/>
			</field>
			<field name="findspot_text">
				<xsl:value-of select="numishare:display-description(self::node(), $lang)"/>
			</field>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="gml:location">
				<!-- use localized (non-gazetteer) findspots later -->
			</xsl:when>
			<xsl:when test="nh:fallsWithin">
				<xsl:apply-templates select="nh:fallsWithin"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="nh:fallsWithin">
		<xsl:apply-templates select="nh:geogname[@xlink:href]|nh:type"/>
	</xsl:template>

	<!-- place feature type -->
	<xsl:template match="nh:type">
		<field name="findspot_type_text">
			<xsl:value-of select="."/>
		</field>
		<field name="findspot_type_facet">
			<xsl:value-of select="."/>
		</field>
		
		<xsl:if test="@xlink:href">
			<field name="findspot_type_uri">
				<xsl:value-of select="@xlink:href"/>
			</field>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nh:deposit | nh:discovery | nh:closingDate">
		<xsl:variable name="type" select="if (local-name() = 'closingDate') then 'closing_date' else local-name()"/>

		<field name="{$type}_display">
			<xsl:choose>
				<xsl:when test="nh:date">
					<xsl:value-of select="nh:date"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="nh:dateRange/nh:fromDate"/>
					<xsl:text>-</xsl:text>
					<xsl:value-of select="nh:dateRange/nh:toDate"/>
				</xsl:otherwise>
			</xsl:choose>
		</field>

		<xsl:choose>
			<xsl:when test="nh:date">
				<xsl:choose>
					<xsl:when test="nh:date/@notAfter">
						<xsl:if test="self::nh:deposit or self::nh:closingDate">
							<field name="taq_num">
								<xsl:value-of select="number(nh:date/@notAfter)"/>
							</field>
						</xsl:if>
						<field name="{$type}_maxint">
							<xsl:value-of select="number(nh:date/@notAfter)"/>
						</field>
					</xsl:when>
					<xsl:when test="nh:date/@standardDate">
						<xsl:if test="self::nh:deposit or self::nh:closingDate">
							<field name="taq_num">
								<xsl:value-of select="number(nh:date/@standardDate)"/>
							</field>
						</xsl:if>
						<field name="{$type}_minint">
							<xsl:value-of select="number(nh:date/@standardDate)"/>
						</field>
						<field name="{$type}_maxint">
							<xsl:value-of select="number(nh:date/@standardDate)"/>
						</field>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="self::nh:deposit or self::nh:closingDate">
					<field name="taq_num">
						<xsl:value-of select="number(nh:dateRange/nh:toDate/@standardDate)"/>
					</field>
				</xsl:if>
				<field name="{$type}_minint">
					<xsl:value-of select="number(nh:dateRange/nh:fromDate/@standardDate)"/>
				</field>
				<field name="{$type}_maxint">
					<xsl:value-of select="number(nh:dateRange/nh:toDate/@standardDate)"/>
				</field>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nh:contentsDesc">
		<xsl:param name="lang"/>
		<xsl:apply-templates select="nh:contents">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="nh:contents">
		<xsl:param name="lang"/>

		<field name="description_display">
			<xsl:choose>
				<xsl:when test="@count or @minCount or @maxCount">
					<xsl:choose>
						<xsl:when test="@count">
							<xsl:value-of select="@count"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="@minCount and not(@maxCount)">
									<xsl:value-of select="concat(@minCount, '+')"/>
								</xsl:when>
								<xsl:when test="not(@minCount) and @maxCount">
									<xsl:value-of select="concat('&lt;', @maxCount)"/>
								</xsl:when>
								<xsl:when test="@minCount and @maxCount">
									<xsl:value-of select="concat(@minCount, '-', @maxCount)"/>
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text> coins</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="nh:description">
							<xsl:value-of select="nh:description"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="contents" as="element()*">
								<xsl:copy-of select="self::nh:contents"/>
							</xsl:variable>

							<!-- parse the hoard contents into a human-readable description -->
							<xsl:variable name="description" select="numishare:hoardContentsDescription($contents, $nudsGroup, $rdf, $lang)"/>


							<xsl:if test="string-length($description) &gt; 0">
								<xsl:value-of select="$description"/>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:otherwise>
			</xsl:choose>
		</field>
	</xsl:template>
</xsl:stylesheet>
