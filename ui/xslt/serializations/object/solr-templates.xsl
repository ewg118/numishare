<?xml version="1.0" encoding="UTF-8"?>
<!--***************************************** SHARED TEMPLATES AND FUNCTIONS *****************************************
	Author: Ethan Gruber
	Function: this XSLT stylesheet is included into xslt/solr.xsl.  It contains shared templates and functions that may be used in object-
	specific stylesheets for creating Solr documents
	Modification date: April 2012
-->
<xsl:stylesheet xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:datetime="http://exslt.org/dates-and-times"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all"
	version="2.0">

	<xsl:template match="nuds:typeDesc">
		<xsl:param name="recordType"/>
		<xsl:param name="lang"/>

		<xsl:apply-templates select="nuds:date|nuds:dateRange">
			<xsl:with-param name="recordType" select="$recordType"/>
		</xsl:apply-templates>

		<!-- AH dates -->
		<xsl:apply-templates select="nuds:dateOnObject[@calendar='ah']"/>

		<xsl:for-each select="nuds:obverse | nuds:reverse">
			<xsl:variable name="side" select="substring(local-name(), 1, 3)"/>

			<!-- get correct type description based on lang, default to english -->
			<xsl:if test="nuds:type/nuds:description">
				<xsl:choose>
					<xsl:when test="nuds:type/nuds:description[@xml:lang=$lang]">
						<xsl:if test="$recordType != 'hoard'">
							<field name="{$side}_type_display">
								<xsl:value-of select="normalize-space(nuds:type/nuds:description[@xml:lang=$lang])"/>
							</field>
						</xsl:if>
						<field name="{$side}_type_text">
							<xsl:value-of select="normalize-space(nuds:type/nuds:description[@xml:lang=$lang])"/>
						</field>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="$recordType != 'hoard'">
							<field name="{$side}_type_display">
								<xsl:value-of select="normalize-space(nuds:type/nuds:description[@xml:lang='en'])"/>
							</field>
						</xsl:if>
						<field name="{$side}_type_text">
							<xsl:value-of select="normalize-space(nuds:type/nuds:description[@xml:lang='en'])"/>
						</field>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>

			<xsl:if test="nuds:legend">
				<xsl:if test="$recordType != 'hoard'">
					<field name="{$side}_leg_display">
						<xsl:value-of select="normalize-space(nuds:legend)"/>
					</field>
				</xsl:if>
				<field name="{$side}_leg_text">
					<xsl:value-of select="normalize-space(nuds:legend)"/>
				</field>
				<field name="{$side}_legendCondensed_text">
					<xsl:value-of select="replace(nuds:legend, ' ', '')"/>
				</field>
			</xsl:if>

			<!-- handle symbols as facets -->
			<xsl:if test="$recordType='conceptual'">
				<xsl:for-each select="nuds:symbol[@position]">
					<field name="symbol_{$side}_{@position}_facet">
						<xsl:value-of select="."/>
					</field>
					<xsl:if test="string(@xlink:href)">
						<field name="symbol_{$side}_{@position}_uri">
							<xsl:value-of select="."/>
						</field>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:for-each>

		<!-- *********** FACETS ************** -->

		<xsl:apply-templates select="nuds:objectType | nuds:denomination[string(.) or string(@xlink:href)] | nuds:manufacture[string(.) or string(@xlink:href)] | nuds:material[string(.) or
			string(@xlink:href)]">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="descendant::nuds:persname[string(.) or string(@xlink:href)] | descendant::nuds:corpname[string(.) or string(@xlink:href)] | descendant::nuds:geogname[string(.) or
			string(@xlink:href)]|descendant::nuds:famname[string(.) or string(@xlink:href)]|descendant::nuds:periodname[string(.) or string(@xlink:href)]">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="nuds:objectType|nuds:denomination|nuds:manufacture|nuds:material">
		<xsl:param name="lang"/>
		<xsl:variable name="facet" select="local-name()"/>
		<xsl:variable name="href" select="@xlink:href"/>
		<xsl:variable name="label">
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
	</xsl:template>

	<xsl:template match="nuds:persname|nuds:corpname |*[local-name()='geogname']|nuds:famname|nuds:periodname">
		<xsl:param name="lang"/>
		<xsl:variable name="href" select="@xlink:href"/>
		<xsl:variable name="role" select="if (string(@xlink:role)) then @xlink:role else local-name()"/>
		<xsl:variable name="label">
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

		<field name="{$role}_facet">
			<xsl:choose>
				<xsl:when test="$role='findspot' and contains(@xlink:href, 'geonames.org')">
					<xsl:value-of select="$geonames//place[@id=$href]/@label"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$label"/>
				</xsl:otherwise>
			</xsl:choose>
		</field>
		<xsl:if test="$role='findspot'">
			<field name="findspot_display">
				<xsl:value-of select="$label"/>
			</field>
		</xsl:if>
		<field name="{$role}_text">
			<xsl:choose>
				<xsl:when test="$role='findspot' and contains(@xlink:href, 'geonames.org')">
					<!-- combine the text with the label -->
					<xsl:value-of select="$label"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$geonames//place[@id=$href]/@label"/>
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
		<xsl:if test="contains($href, 'nomisma.org')">
			<!-- ingest alternate labels -->
			<xsl:for-each select="$rdf/*[@rdf:about=$href]/skos:altLabel[if (string($lang)) then @xml:lang=$lang else @xml:lang='en']">
				<field name="{$role}_text">
					<xsl:value-of select="."/>
				</field>
			</xsl:for-each>
		</xsl:if>

		<xsl:if test="string(@xlink:href) and ($role = 'mint' or $role = 'findspot')">
			<xsl:choose>
				<xsl:when test="contains(@xlink:href, 'geonames')">
					<xsl:variable name="href" select="@xlink:href"/>
					<xsl:variable name="value" select="."/>
					<!-- *_geo format is 'mint name|URI of resource|KML-compliant geographic coordinates' -->

					<xsl:if test="string-length($geonames//place[@id=$href]) &gt; 0">
						<field name="{$role}_geo">
							<xsl:value-of select="$geonames//place[@id=$href]/@label"/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="$href"/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="$geonames//place[@id=$href]"/>
						</field>
						<field name="{$role}_loc">
							<xsl:value-of select="concat(tokenize($geonames//place[@id=$href], ',')[2], ',', tokenize($geonames//place[@id=$href], ',')[1])"/>
						</field>
					</xsl:if>

					<!-- insert hierarchical facets -->
					<xsl:variable name="hierarchy_pieces" select="tokenize($geonames//place[@id=$href]/@hierarchy, '\|')"/>
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
									<xsl:value-of select="concat(substring-before($hierarchy_pieces[$position - 1], '/'), '|', substring-after(., '/'), '/', substring-before(., '/'))"/>
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
					<xsl:variable name="coordinates">
						<xsl:if test="$rdf/*[@rdf:about=concat($href, '#this')]/geo:lat and $rdf/*[@rdf:about=concat($href, '#this')]/geo:long">
							<xsl:text>true</xsl:text>
						</xsl:if>
					</xsl:variable>
					<xsl:if test="$coordinates = 'true'">
						<!-- *_geo format is 'mint name|URI of resource|KML-compliant geographic coordinates' -->
						<field name="{$role}_geo">
							<xsl:choose>
								<xsl:when test="string($lang)">
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
							<xsl:text>|</xsl:text>
							<xsl:value-of select="@xlink:href"/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="concat($rdf/*[@rdf:about=concat($href, '#this')]/geo:long, ',', $rdf/*[@rdf:about=concat($href, '#this')]/geo:lat)"/>
						</field>

						<field name="{$role}_loc">
							<xsl:value-of select="concat($rdf/*[@rdf:about=concat($href, '#this')]/geo:lat, ',', $rdf/*[@rdf:about=concat($href, '#this')]/geo:long)"/>
						</field>
					</xsl:if>
					<xsl:for-each select="$rdf/*[@rdf:about=$href]/skos:closeMatch[contains(@rdf:resource, 'pleiades.stoa.org')]">
						<field name="pleiades_uri">
							<xsl:value-of select="@rdf:resource"/>
						</field>
					</xsl:for-each>
					
					<!--index region hierarchy -->
					<xsl:for-each select="$regions//hierarchy[@uri=$href]/region">
						<xsl:sort select="position()" order="descending"/>
						<xsl:variable name="id" select="substring-after(@uri, 'id/')"/>
						
						<field name="region_hier">
							<xsl:choose>
								<xsl:when test="position()=1">
									<xsl:value-of select="concat('L',position(), '|', ., '/', $id)"/>
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
			<xsl:for-each select="$rdf/*[@rdf:about=$href]/skos:closeMatch[contains(@rdf:resource, 'pleiades.stoa.org')]">
				<field name="pleiades_uri">
					<xsl:value-of select="@rdf:resource"/>
				</field>
			</xsl:for-each>
			<xsl:if test="contains($href, 'nomisma.org')">
				<!--index region hierarchy -->
				<xsl:for-each select="$regions//hierarchy[@uri=$href]/region">
					<xsl:sort select="position()" order="descending"/>
					<xsl:variable name="id" select="substring-after(@uri, 'id/')"/>
					
					<field name="region_hier">
						<xsl:choose>
							<xsl:when test="position()=1">
								<xsl:value-of select="concat('L',position(), '|', ., '/', $id)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat(substring-after(following-sibling::node()[1]/@uri, 'id/'), '|', ., '/', $id)"/>
							</xsl:otherwise>
						</xsl:choose>
						
					</field>
					<!-- manually insert lowest region hierarchy for self -->
					<xsl:if test="position()=last()">
						<field name="region_hier">
							<xsl:value-of select="concat(substring-after(@uri, 'id/'), '|', $label, '/', substring-after($href, 'id/'))"/>
						</field>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:dateOnObject[@calendar='ah']">
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

	<!-- generalize refDesc for NUDS and NUDS Hoard records -->
	<xsl:template match="*[local-name()='refDesc']">

		<!-- references -->
		<xsl:variable name="refs" as="element()*">
			<refs>
				<xsl:for-each select="*[local-name()='reference']">
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
		<xsl:param name="recordType"/>

		<xsl:if test="$recordType != 'hoard'">
			<field name="date_display">
				<xsl:value-of select="normalize-space(.)"/>
			</field>
		</xsl:if>

		<xsl:for-each select="@standardDate">
			<xsl:call-template name="get_date_hierarchy">
				<xsl:with-param name="standardDate" select="."/>
				<xsl:with-param name="recordType" select="$recordType"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nuds:dateRange">
		<xsl:param name="recordType"/>

		<xsl:if test="$recordType != 'hoard'">
			<field name="date_display">
				<xsl:value-of select="normalize-space(nuds:fromDate)"/>
				<xsl:text> - </xsl:text>
				<xsl:value-of select="normalize-space(nuds:toDate)"/>
			</field>
		</xsl:if>

		<xsl:for-each select="*/@standardDate">
			<xsl:call-template name="get_date_hierarchy">
				<xsl:with-param name="standardDate" select="."/>
				<xsl:with-param name="recordType" select="$recordType"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="get_date_hierarchy">
		<xsl:param name="standardDate"/>
		<xsl:param name="recordType"/>

		<xsl:if test="number(.)">
			<xsl:variable name="year_string" select="string(abs(number(.)))"/>
			<xsl:variable name="century" select="if(number(.) &gt; 0) then ceiling(number(.) div 100) else floor(number(.) div 100)"/>
			<xsl:variable name="decade_digit" select="floor(number(substring($year_string, (string-length($year_string) - 1), 2)) div 10)"/>
			<xsl:variable name="decade" select="(($century - 1) * 100) + $decade_digit"/>

			<xsl:if test="number($century)">
				<field name="century_num">
					<xsl:value-of select="$century"/>
				</field>
			</xsl:if>
			<field name="decade_num">
				<xsl:value-of select="$decade"/>
			</field>
			<xsl:if test="number(.)">
				<field name="year_num">
					<xsl:value-of select="number(.)"/>
				</field>
			</xsl:if>

			<!-- add min and max, even if they are integers (for ISO dates) -->
			<xsl:if test="$recordType != 'hoard'">
				<xsl:if test="position() = 1">
					<field name="year_minint">
						<xsl:value-of select="number(.)"/>
					</field>
				</xsl:if>
				<xsl:if test="position() = last()">
					<field name="year_maxint">
						<xsl:value-of select="number(.)"/>
					</field>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="get_hoard_sort_fields">
		<xsl:param name="lang"/>
		<xsl:variable name="localLang" select="if (string($lang)) then $lang else 'en'"/>
		<!-- sortable fields -->
		<xsl:variable name="sort-fields">
			<xsl:text>artist,authority,deity,denomination,dynasty,issuer,magistrate,maker,manufacture,material,mint,portrait,region</xsl:text>
		</xsl:variable>
		<xsl:for-each select="tokenize($sort-fields, ',')">
			<xsl:variable name="field" select="."/>

			<!-- for each sortable field which is a multiValued field in Solr (a facet), grab the min and max values -->
			<xsl:for-each select="$rdf/descendant::*[local-name()=$field]/skos:prefLabel[@xml:lang=$localLang]">
				<xsl:sort order="ascending"/>
				<xsl:if test="position()=1">
					<field name="{$field}_min">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:if>
				<xsl:if test="position()=last()">
					<field name="{$field}_max">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="get_coin_sort_fields">
		<xsl:param name="typeDesc"/>
		<xsl:param name="lang"/>
		<!-- sortable fields -->
		<xsl:variable name="sort-fields">
			<xsl:text>artist,authority,deity,denomination,dynasty,issuer,maker,manufacture,material,mint,portrait,region</xsl:text>
		</xsl:variable>

		<xsl:for-each select="tokenize($sort-fields, ',')">
			<xsl:variable name="field" select="."/>
			<!-- for each sortable field which is a multiValued field in Solr (a facet), grab the min and max values -->
			<xsl:for-each select="$typeDesc/descendant::*[local-name()=$field and local-name() !='authority']|$typeDesc/descendant::*[@xlink:role=$field]">
				<xsl:sort order="ascending" select="if (@xlink:href) then @xlink:href else ."/>
				<xsl:variable name="href" select="@xlink:href"/>
				<xsl:variable name="name" select="if(@xlink:role) then @xlink:role else local-name()"/>
				<xsl:variable name="label">
					<xsl:choose>
						<xsl:when test="string($lang)">
							<xsl:choose>
								<xsl:when test="contains($href, 'nomisma.org')">
									<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about=$href], $lang)"/>
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
				<xsl:if test="position()=1">
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
			<xsl:when test="*[local-name()='objectXMLWrap']/mods:modsCollection">
				<xsl:value-of select="*[local-name()='objectXMLWrap']/mods:modsCollection/mods:mods/@ID"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="string(*[local-name()='title'])">
						<xsl:value-of select="normalize-space(*[local-name()='title'])"/>
						<xsl:if test="string(*[local-name()='identifier'])">
							<xsl:text> </xsl:text>
							<xsl:value-of select="normalize-space(*[local-name()='identifier'])"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- typeNumber -->
	<xsl:template name="typeNumber">
		<xsl:param name="collection-name"/>

		<xsl:choose>
			<xsl:when test="$collection-name='crro'">
				<field name="typeNumber">
					<xsl:value-of select="substring-after(nuds:control/nuds:recordId, 'rrc-')"/>
				</field>
			</xsl:when>
			<xsl:when test="$collection-name='ocre'">
				<xsl:variable name="pieces" select="tokenize(nuds:control/nuds:recordId, '\.')"/>

				<field name="typeNumber">
					<xsl:value-of select="if(count($pieces) = 4) then $pieces[4] else concat($pieces[4], '.', $pieces[5])"/>
				</field>
			</xsl:when>
			<xsl:when test="$collection-name='pella'">
				<field name="typeNumber">
					<xsl:value-of select="substring-after(nuds:control/nuds:recordId, 'price.')"/>
				</field>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<!-- sortid -->
	<xsl:template name="sortid">
		<xsl:param name="collection-name"/>

		<xsl:choose>
			<xsl:when test="$collection-name='crro'">
				<field name="sortid">
					<!--<xsl:variable name="segs" select="tokenize(substring-after(nuds:control/nuds:recordId, 'rrc-'), '\.')"/>-->
					<xsl:analyze-string select="substring-after(nuds:control/nuds:recordId, 'rrc-')" regex="([0-9]+)(^[\.]+)?(\.)?([0-9]+)?([A-z]+)?">
						<xsl:matching-substring>
							<xsl:value-of select="concat(format-number(number(regex-group(1)), '0000'), regex-group(2), regex-group(3), if (number(regex-group(4))) then
								format-number(number(regex-group(4)), '0000') else '', regex-group(5))"/>
						</xsl:matching-substring>
						<xsl:non-matching-substring>
							<xsl:value-of select="."/>
						</xsl:non-matching-substring>
					</xsl:analyze-string>
				</field>
			</xsl:when>

			<xsl:when test="$collection-name='pella'">
				<field name="sortid">
					<xsl:analyze-string select="substring-after(nuds:control/nuds:recordId, 'price.')" regex="([A-Z])?([0-9]+)([A-z]+)?">
						<xsl:matching-substring>
							<xsl:value-of select="concat(regex-group(1), format-number(number(regex-group(2)), '0000'), regex-group(3))"/>
						</xsl:matching-substring>
						<xsl:non-matching-substring>
							<xsl:value-of select="."/>
						</xsl:non-matching-substring>
					</xsl:analyze-string>
				</field>
			</xsl:when>

			<xsl:when test="$collection-name='igch'">
				<field name="sortid">
					<xsl:value-of select="nh:control/nh:recordId"/>
				</field>
			</xsl:when>

			<xsl:when test="$collection-name='ocre'">
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
									<xsl:when test="$segs[2]='1(2)'">005</xsl:when>
									<xsl:when test="$segs[2]='2'">015</xsl:when>
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
							<xsl:when test="$segs[3]='car'">072_02</xsl:when>
							<xsl:when test="$segs[3]='dio'">072_03</xsl:when>
							<xsl:when test="$segs[3]='post'">072_04</xsl:when>
							<xsl:when test="$segs[3]='lae'">072_05</xsl:when>
							<xsl:when test="$segs[3]='mar'">072_06</xsl:when>
							<xsl:when test="$segs[3]='vict'">072_07</xsl:when>
							<xsl:when test="$segs[3]='tet_i'">072_08</xsl:when>
							<xsl:when test="$segs[3]='cara'">072_09</xsl:when>
							<xsl:when test="$segs[3]='cara-dio-max_her'">072_10</xsl:when>
							<xsl:when test="$segs[3]='all'">072_11</xsl:when>
							<xsl:when test="$segs[3]='mac_ii'">072_12</xsl:when>
							<xsl:when test="$segs[3]='quit'">072_13</xsl:when>
							<xsl:when test="$segs[3]='zen'">072_14</xsl:when>
							<xsl:when test="$segs[3]='vab'">072_15</xsl:when>
							<xsl:when test="$segs[3]='reg'">072_16</xsl:when>
							<xsl:when test="$segs[3]='dry'">072_17</xsl:when>
							<xsl:when test="$segs[3]='aurl'">072_18</xsl:when>
							<xsl:when test="$segs[3]='dom_g'">072_19</xsl:when>
							<xsl:when test="$segs[3]='sat'">072_20</xsl:when>
							<xsl:when test="$segs[3]='bon'">072_21</xsl:when>
							<xsl:when test="$segs[3]='jul_i'">072_22</xsl:when>
							<xsl:when test="$segs[3]='ama'">072_23</xsl:when>
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
			
			<xsl:for-each select="$rdf//*[@rdf:about=$href]/descendant::*[contains(local-name(), 'Label')][@xml:lang=$lang]">
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:text> </xsl:text>
			</xsl:for-each>
		</xsl:for-each>		
	</xsl:template>
</xsl:stylesheet>
