<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:nuds="http://nomisma.org/nuds" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:datetime="http://exslt.org/dates-and-times" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://exslt.org/math"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all">
	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:template name="nudsHoard">
		<!-- create default document -->
		<xsl:apply-templates select="//nh:nudsHoard">
			<xsl:with-param name="lang"/>
		</xsl:apply-templates>

		<!-- create documents for each additional activated language -->
		<xsl:for-each select="//config/descendant::language[@enabled='true']">
			<xsl:apply-templates select="//nh:nudsHoard">
				<xsl:with-param name="lang" select="@code"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nh:nudsHoard">
		<xsl:param name="lang"/>
		<xsl:variable name="contentsDesc" as="element()*">
			<xsl:copy-of select="descendant::nh:contents"/>
		</xsl:variable>

		<xsl:variable name="all-dates" as="element()*">
			<dates>
				<xsl:choose>
					<xsl:when test="descendant::nh:deposit//@standardDate">
						<xsl:for-each select="descendant::nh:deposit//@standardDate">
							<date>
								<xsl:value-of select="number(.)"/>
							</date>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="descendant::nuds:typeDesc">
							<xsl:if test="index-of(//config/certainty_codes/code[@accept='true'], @certainty)">
								<xsl:choose>
									<xsl:when test="string(@xlink:href)">
										<xsl:variable name="href" select="@xlink:href"/>
										<xsl:for-each select="$nudsGroup//object[@xlink:href=$href]/descendant::*/@standardDate">
											<xsl:if test="number(.)">
												<date>
													<xsl:value-of select="number(.)"/>
												</date>
											</xsl:if>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<xsl:for-each select="descendant::*/@standardDate">
											<xsl:if test="number(.)">
												<date>
													<xsl:value-of select="number(.)"/>
												</date>
											</xsl:if>
										</xsl:for-each>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</dates>
		</xsl:variable>
		<xsl:variable name="dates" as="element()*">
			<dates>
				<xsl:for-each select="distinct-values($all-dates//date)">
					<xsl:sort data-type="number"/>
					<date>
						<xsl:value-of select="number(.)"/>
					</date>
				</xsl:for-each>
			</dates>
		</xsl:variable>
		<xsl:variable name="hasContents">
			<xsl:choose>
				<xsl:when test="count(nh:descMeta/nh:contentsDesc/nh:contents/*) &gt; 0">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="title">
			<xsl:value-of select="normalize-space(nh:descMeta/nh:title[1])"/>
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
					<xsl:when test="string($title)">
						<xsl:value-of select="$title"/>
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
			<xsl:if test="$hasContents='true'">
				<field name="closing_date_display">
					<xsl:value-of select="nh:normalize_date($dates/date[last()], $dates/date[last()])"/>
				</field>
				<xsl:if test="count($dates/date) &gt; 0">
					<field name="tpq_num">
						<xsl:value-of select="$dates/date[1]"/>
					</field>
					<field name="taq_num">
						<xsl:value-of select="$dates/date[last()]"/>
					</field>
				</xsl:if>

			</xsl:if>
			<field name="timestamp">
				<xsl:choose>
					<xsl:when test="string(descendant::*:maintenanceEvent[last()]/*:eventDateTime/@standardDateTime)">
						<xsl:choose>
							<xsl:when test="contains(descendant::*:maintenanceEvent[last()]/*:eventDateTime/@standardDateTime, 'Z')">
								<xsl:value-of select="descendant::*:maintenanceEvent[last()]/*:eventDateTime/@standardDateTime"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat(descendant::*:maintenanceEvent[last()]/*:eventDateTime/@standardDateTime, 'Z')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="if(contains(datetime:dateTime(), 'Z')) then datetime:dateTime() else concat(datetime:dateTime(), 'Z')"/>
					</xsl:otherwise>
				</xsl:choose>
			</field>

			<!-- create description if there are contents -->
			<xsl:if test="$hasContents = 'true'">
				<xsl:variable name="total-counts" as="element()*">
					<total-counts>
						<xsl:for-each select="descendant::nuds:typeDesc">
							<xsl:choose>
								<xsl:when test="string(@xlink:href)">
									<xsl:variable name="href" select="@xlink:href"/>
									<xsl:apply-templates select="$nudsGroup//object[@xlink:href=$href]/descendant::nuds:typeDesc/nuds:denomination" mode="den">
										<xsl:with-param name="contentsDesc" select="$contentsDesc"/>
										<xsl:with-param name="lang" select="$lang"/>
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="nuds:denomination" mode="den">
										<xsl:with-param name="contentsDesc" select="$contentsDesc"/>
										<xsl:with-param name="lang" select="$lang"/>
										<xsl:with-param name="num" select="if (ancestor::nh:coin) then 1 else ancestor::nh:coinGrp/@count"/>
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</total-counts>
				</xsl:variable>

				<xsl:variable name="denominations" as="element()*">
					<denominations>
						<xsl:for-each select="distinct-values($total-counts//name[string-length(.) &gt; 0])">
							<xsl:variable name="name" select="."/>
							<name>
								<xsl:attribute name="count">
									<xsl:value-of select="sum($total-counts//name[.=$name]/@count)"/>
								</xsl:attribute>
								<xsl:value-of select="$name"/>
							</name>
						</xsl:for-each>
					</denominations>
				</xsl:variable>

				<xsl:if test="count($denominations//*[local-name()='name']) &gt; 0">
					<field name="description_display">
						<xsl:for-each select="$denominations//*[local-name()='name']">
							<xsl:sort select="@count" order="descending" data-type="number"/>
							<xsl:value-of select="."/>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="@count"/>
							<xsl:if test="not(position()=last())">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</field>
				</xsl:if>
			</xsl:if>


			<xsl:apply-templates select="nh:descMeta"/>

			<!-- apply templates for those typeDescs contained explicitly within the hoard -->
			<xsl:for-each select="descendant::nuds:typeDesc">
				<xsl:choose>
					<xsl:when test="string(@xlink:href)">
						<xsl:variable name="href" select="@xlink:href"/>
						<xsl:apply-templates select="$nudsGroup//object[@xlink:href=$href]/descendant::nuds:typeDesc">
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
					<xsl:value-of select="$nudsGroup//object[@xlink:href=$href]/descendant::nuds:title"/>
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
		<xsl:apply-templates select="nh:hoardDesc"/>
		<xsl:apply-templates select="nh:refDesc"/>
		<!--<xsl:apply-templates select="nh:contentsDesc"/>-->
	</xsl:template>

	<xsl:template match="nh:hoardDesc">
		<xsl:apply-templates select="nh:findspot/nh:geogname[@xlink:role='findspot']"/>
	</xsl:template>

	<xsl:template match="nuds:denomination" mode="den">
		<xsl:param name="contentsDesc"/>
		<xsl:param name="lang"/>
		<xsl:param name="num"/>

		<xsl:variable name="href" select="@xlink:href"/>
		<xsl:variable name="value">
			<xsl:choose>
				<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
					<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about=$href], $lang)"/>
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
		<xsl:variable name="source" select="ancestor::object/@xlink:href"/>
		<xsl:variable name="count">
			<xsl:choose>
				<xsl:when test="string($source)">
					<xsl:choose>
						<xsl:when test="$contentsDesc//nh:coin[nuds:typeDesc[@xlink:href=$source]]">
							<xsl:value-of select="count($contentsDesc//nh:coin/nuds:typeDesc[@xlink:href=$source])"/>
						</xsl:when>
						<xsl:when test="$contentsDesc//nh:coinGrp[nuds:typeDesc[@xlink:href=$source]]">
							<xsl:value-of select="sum($contentsDesc//nh:coinGrp[nuds:typeDesc[@xlink:href=$source]]/@count)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$num"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<name>
			<xsl:attribute name="count">
				<xsl:value-of select="$count"/>
			</xsl:attribute>
			<xsl:value-of select="$value"/>
		</name>
	</xsl:template>
</xsl:stylesheet>
