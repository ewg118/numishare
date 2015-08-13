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
				<xsl:if test="$recordType != 'hoard'">
					<field name="{$side}_type_display">
						<xsl:value-of select="normalize-space(nuds:type/nuds:description[if (string($lang)) then @xml:lang=$lang else @xml:lang='en'])"/>
					</field>
				</xsl:if>
				<field name="{$side}_type_text">
					<xsl:value-of select="normalize-space(nuds:type/nuds:description[if (string($lang)) then @xml:lang=$lang else @xml:lang='en'])"/>
				</field>
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
					<xsl:for-each select="$rdf/*[@rdf:about=$href]/skos:relatedMatch[contains(@rdf:resource, 'pleiades.stoa.org')]">
						<field name="pleiades_uri">
							<xsl:value-of select="@rdf:resource"/>
						</field>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="string(@xlink:href) and $role = 'region'">
			<xsl:variable name="href" select="@xlink:href"/>
			<xsl:for-each select="$rdf/*[@rdf:about=$href]/skos:relatedMatch[contains(@rdf:resource, 'pleiades.stoa.org')]">
				<field name="pleiades_uri">
					<xsl:value-of select="@rdf:resource"/>
				</field>
			</xsl:for-each>
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

		<xsl:if test="string(normalize-space(@standardDate))">
			<xsl:call-template name="get_date_hierarchy">
				<xsl:with-param name="standardDate" select="@standardDate"/>
				<xsl:with-param name="recordType" select="$recordType"/>
			</xsl:call-template>
		</xsl:if>
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
				<xsl:variable name="pieces" select="tokenize(nuds:control/nuds:recordId, '\.')"></xsl:variable>
				
				<field name="typeNumber">
					<xsl:value-of select="if(count($pieces) = 4) then $pieces[4] else concat($pieces[4], '.', $pieces[5])"/>
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
							<xsl:when test="$segs[3] = 'aug'">01</xsl:when>
							<xsl:when test="$segs[3] = 'tib'">02</xsl:when>
							<xsl:when test="$segs[3] = 'gai'">03</xsl:when>
							<xsl:when test="$segs[3] = 'cl'">04</xsl:when>
							<xsl:when test="$segs[3] = 'ner'">
								<xsl:choose>
									<xsl:when test="$segs[2]='1(2)'">05</xsl:when>
									<xsl:when test="$segs[2]='2'">15</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$segs[3] = 'clm'">06</xsl:when>
							<xsl:when test="$segs[3] = 'cw'">07</xsl:when>
							<xsl:when test="$segs[3] = 'gal'">08</xsl:when>
							<xsl:when test="$segs[3] = 'ot'">09</xsl:when>
							<xsl:when test="$segs[3] = 'vit'">10</xsl:when>
							<xsl:when test="$segs[3] = 'ves'">11</xsl:when>
							<xsl:when test="$segs[3] = 'tit'">12</xsl:when>
							<xsl:when test="$segs[3] = 'dom'">13</xsl:when>
							<xsl:when test="$segs[3] = 'anys'">14</xsl:when>
							<xsl:when test="$segs[3] = 'tr'">16</xsl:when>
							<xsl:when test="$segs[3] = 'hdn'">17</xsl:when>
							<xsl:when test="$segs[3] = 'ant'">18</xsl:when>
							<xsl:when test="$segs[3] = 'm_aur'">19</xsl:when>
							<xsl:when test="$segs[3] = 'com'">20</xsl:when>
							<xsl:when test="$segs[3] = 'pert'">21</xsl:when>
							<xsl:when test="$segs[3] = 'dj'">22</xsl:when>
							<xsl:when test="$segs[3] = 'pn'">23</xsl:when>
							<xsl:when test="$segs[3] = 'ca'">24</xsl:when>
							<xsl:when test="$segs[3] = 'ss'">25</xsl:when>
							<xsl:when test="$segs[3] = 'crl'">26</xsl:when>
							<xsl:when test="$segs[3] = 'ge'">27</xsl:when>
							<xsl:when test="$segs[3] = 'mcs'">28</xsl:when>
							<xsl:when test="$segs[3] = 'el'">29</xsl:when>
							<xsl:when test="$segs[3] = 'sa'">30</xsl:when>
							<xsl:when test="$segs[3] = 'max_i'">31</xsl:when>
							<xsl:when test="$segs[3] = 'pa'">32</xsl:when>
							<xsl:when test="$segs[3] = 'mxs'">33</xsl:when>
							<xsl:when test="$segs[3] = 'gor_i'">34</xsl:when>
							<xsl:when test="$segs[3] = 'gor_ii'">35</xsl:when>
							<xsl:when test="$segs[3] = 'balb'">36</xsl:when>
							<xsl:when test="$segs[3] = 'pup'">37</xsl:when>
							<xsl:when test="$segs[3] = 'gor_iii_caes'">38</xsl:when>
							<xsl:when test="$segs[3] = 'gor_iii'">39</xsl:when>
							<xsl:when test="$segs[3] = 'ph_i'">40</xsl:when>
							<xsl:when test="$segs[3] = 'pac'">41</xsl:when>
							<xsl:when test="$segs[3] = 'jot'">42</xsl:when>
							<xsl:when test="$segs[3] = 'mar_s'">43</xsl:when>
							<xsl:when test="$segs[3] = 'spon'">44</xsl:when>
							<xsl:when test="$segs[3] = 'tr_d'">45</xsl:when>
							<xsl:when test="$segs[3] = 'tr_g'">46</xsl:when>
							<xsl:when test="$segs[3] = 'vo'">47</xsl:when>
							<xsl:when test="$segs[3] = 'aem'">48</xsl:when>
							<xsl:when test="$segs[3] = 'uran_ant'">49</xsl:when>
							<xsl:when test="$segs[3] = 'val_i'">50</xsl:when>
							<xsl:when test="$segs[3] = 'val_i-gall'">51</xsl:when>
							<xsl:when test="$segs[3] = 'val_i-gall-val_ii-sala'">52</xsl:when>
							<xsl:when test="$segs[3] = 'mar'">53</xsl:when>
							<xsl:when test="$segs[3] = 'gall(1)'">54</xsl:when>
							<xsl:when test="$segs[3] = 'gall_sala(1)'">55</xsl:when>
							<xsl:when test="$segs[3] = 'gall_sals'">56</xsl:when>
							<xsl:when test="$segs[3] = 'sala(1)'">57</xsl:when>
							<xsl:when test="$segs[3] = 'val_ii'">58</xsl:when>
							<xsl:when test="$segs[3] = 'sals'">59</xsl:when>
							<xsl:when test="$segs[3] = 'qjg'">60</xsl:when>
							<xsl:when test="$segs[3] = 'gall(2)'">61</xsl:when>
							<xsl:when test="$segs[3] = 'gall_sala(2)'">62</xsl:when>
							<xsl:when test="$segs[3] = 'sala(2)'">63</xsl:when>
							<xsl:when test="$segs[3] = 'cg'">64</xsl:when>
							<xsl:when test="$segs[3] = 'qu'">65</xsl:when>
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
</xsl:stylesheet>
