<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Modified: May 2021
	Function: This stylesheet reads the incoming TEI model and serializes into a Solr document
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nm="http://nomisma.org/id/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:numishare="https://github.com/ewg118/numishare" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:org="http://www.w3.org/ns/org#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" exclude-result-prefixes="#all" version="2.0">

	<xsl:template name="tei">
		<!-- create default document -->
		<xsl:apply-templates select="//tei:TEI">
			<xsl:with-param name="lang"/>
		</xsl:apply-templates>

		<!-- create documents for each additional activated language -->
		<xsl:for-each select="//config/descendant::language[@enabled = true()]">
			<xsl:apply-templates select="//tei:TEI">
				<xsl:with-param name="lang" select="@code"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="tei:TEI">
		<xsl:param name="lang"/>
		<xsl:variable name="id" select="descendant::tei:idno[@type='filename']"/>

		<doc>
			<field name="id">
				<xsl:choose>
					<xsl:when test="string($lang)">
						<xsl:value-of select="concat($id, '-', $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$id"/>
					</xsl:otherwise>
				</xsl:choose>
			</field>
			<field name="recordId">
				<xsl:value-of select="$id"/>
			</field>
			<xsl:if test="string($lang)">
				<field name="lang">
					<xsl:value-of select="$lang"/>
				</field>
			</xsl:if>

			<field name="collection-name">
				<xsl:value-of select="$collection-name"/>
			</field>

			<field name="recordType">physical</field>

			<field name="publisher_display">
				<xsl:value-of select="$publisher"/>
			</field>

			<xsl:apply-templates select="descendant::tei:titleStmt/tei:title"/>

			<field name="timestamp">
				<xsl:choose>
					<xsl:when test="descendant::tei:revisionDesc/tei:listChange/tei:change[last()]/@when castable as xs:date">
						<xsl:variable name="newDateTime" select="concat(descendant::tei:revisionDesc/tei:listChange/tei:change[last()]/@when, 'T00:00:00Z')"/>

						<xsl:value-of select="format-dateTime(xs:dateTime($newDateTime), '[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01]Z')"/>
					</xsl:when>
					<xsl:when test="descendant::tei:revisionDesc/tei:listChange/tei:change[last()]/@when castable as xs:dateTime">
						<xsl:value-of
							select="format-dateTime(xs:dateTime(descendant::tei:revisionDesc/tei:listChange/tei:change[last()]/@whens), '[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01]Z')"
						/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01]Z')"/>
					</xsl:otherwise>
				</xsl:choose>
			</field>

			<xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc">
				<xsl:with-param name="lang" select="$lang"/>
			</xsl:apply-templates>
			
			<!--body -->
			<xsl:apply-templates select="tei:text/tei:body">
				<xsl:with-param name="lang" select="$lang"/>
			</xsl:apply-templates>
			
			<!-- images -->
			<xsl:apply-templates select="tei:facsimile"/>

			<!-- text -->
			<field name="fulltext">
				<xsl:value-of select="$id"/>
				<xsl:text> </xsl:text>
				<xsl:for-each select="descendant-or-self::text()">
					<xsl:value-of select="normalize-space(.)"/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</field>
		</doc>
	</xsl:template>

	<!-- title -->
	<xsl:template match="tei:title">
		<field name="title_display">
			<xsl:value-of select="."/>
		</field>
		<field name="title_text">
			<xsl:value-of select="."/>
		</field>
	</xsl:template>
	
	<xsl:template match="tei:body">
		<xsl:param name="lang"/>
		
		<xsl:apply-templates select="tei:div[@type = 'edition']/tei:div[@type='textpart'][@n]">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="tei:div[@type='textpart']">
		<xsl:param name="lang"/>
		
		<xsl:variable name="side" select="substring(@n, 1, 3)"/>
		
		<!-- include language-specific type description -->
		<xsl:if test="tei:figure/tei:figDesc">
			<xsl:choose>
				<xsl:when test="tei:figure/tei:figDesc[@xml:lang = $lang]">
					<field name="{$side}_type_display">
						<xsl:value-of select="normalize-space(tei:figure/tei:figDesc[@xml:lang = $lang])"/>
					</field>
					<field name="{$side}_type_text">
						<xsl:value-of select="normalize-space(tei:figure/tei:figDesc[@xml:lang = $lang])"/>
					</field>
				</xsl:when>
				<xsl:when test="tei:figure/tei:figDesc[@xml:lang = 'en']">
					<field name="{$side}_type_display">
						<xsl:value-of select="normalize-space(tei:figure/tei:figDesc[@xml:lang = 'en'])"/>
					</field>
					<field name="{$side}_type_text">
						<xsl:value-of select="normalize-space(tei:figure/tei:figDesc[@xml:lang = 'en'])"/>
					</field>
				</xsl:when>
				<xsl:otherwise>
					<field name="{$side}_type_display">
						<xsl:value-of select="normalize-space(tei:figure/tei:figDesc[1])"/>
					</field>
					<field name="{$side}_type_text">
						<xsl:value-of select="normalize-space(tei:figure/tei:figDesc[1])"/>
					</field>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		
		<xsl:apply-templates select="tei:ab">
			<xsl:with-param name="lang" select="$lang"/>
			<xsl:with-param name="side" select="$side"/>
		</xsl:apply-templates>
		
	</xsl:template>
	
	<xsl:template match="tei:ab">
		<xsl:param name="side"/>
		
		
		<field name="{$side}_leg_display">
			<xsl:choose>
				<xsl:when test="tei:g">
					<xsl:value-of select="string-join(tei:g, '')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:otherwise>
			</xsl:choose>
		</field>
		
		<field name="{$side}_leg_text">
			<xsl:choose>
				<xsl:when test="tei:g">
					<xsl:value-of select="string-join(tei:g, '')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:otherwise>
			</xsl:choose>
		</field>
		
		<field name="{$side}_legendCondensed_text">
			<xsl:choose>
				<xsl:when test="tei:g">
					<xsl:value-of select="replace(string-join(tei:g, ''), ' ', '')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="replace(string-join(., ' '), ' ', '')"/>
				</xsl:otherwise>
			</xsl:choose>
		</field>
	</xsl:template>

	<!-- document metadata -->
	<xsl:template match="tei:msDesc">
		<xsl:param name="lang"/>

		<xsl:apply-templates select="tei:physDesc">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="tei:history">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="tei:physDesc">
		<xsl:param name="lang"/>

		<!-- typological attributes -->
		<xsl:apply-templates
			select="tei:objectDesc/tei:supportDesc/tei:support/tei:objectType | tei:objectDesc/tei:supportDesc/tei:support/tei:material | tei:objectDesc/tei:layoutDesc/tei:layout/tei:rs">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>

		<!-- measurements -->
		<xsl:apply-templates select="tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/* | tei:objectDesc/tei:supportDesc/tei:support/tei:measure"/>
	</xsl:template>

	<xsl:template match="tei:history">
		<xsl:param name="lang"/>

		<xsl:apply-templates select="tei:origin">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>
		<!--<xsl:apply-templates select="tei:provenance">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>-->
	</xsl:template>

	<xsl:template match="tei:origin">
		<xsl:param name="lang"/>

		<xsl:apply-templates select="tei:origPlace/tei:placeName | tei:origDate | tei:persName">
			<xsl:with-param name="lang" select="$lang"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="tei:origDate">
		<xsl:param name="lang"/>

		<!-- construct display date based on data present in the element -->
		<xsl:choose>
			<xsl:when test="@notBefore or @notAfter">
				<field name="date_display">
					<xsl:if test="@notBefore">
						<xsl:value-of select="numishare:normalizeDate(@notBefore)"/>
					</xsl:if>
					<xsl:if test="@notBefore and @notAfter">
						<xsl:text>-</xsl:text>
					</xsl:if>
					<xsl:if test="@notAfter">
						<xsl:value-of select="numishare:normalizeDate(@notAfter)"/>
					</xsl:if>
				</field>

				<xsl:if test="@notBefore">
					<field name="year_num">
						<xsl:value-of select="number(@notBefore)"/>
					</field>
					<field name="year_minint">
						<xsl:value-of select="number(@notBefore)"/>
					</field>
				</xsl:if>
				<xsl:if test="@notAfter">
					<field name="year_num">
						<xsl:value-of select="number(@notAfter)"/>
					</field>
					<field name="year_maxint">
						<xsl:value-of select="number(@notAfter)"/>
					</field>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<field name="date_display">
					<xsl:value-of select="normalize-space(.)"/>
				</field>
			</xsl:otherwise>
		</xsl:choose>

		<!-- index period as a facet/URI -->
		<xsl:if test="matches(@period, '^https?://')">
			<xsl:variable name="href" select="@period"/>

			<field name="period_facet">
				<xsl:value-of select="."/>
			</field>
			<field name="period_text">
				<xsl:value-of select="."/>
			</field>
			<field name="period_uri">
				<xsl:value-of select="@period"/>
			</field>

			<!-- additional content -->
			<xsl:if test="contains($href, 'nomisma.org')">
				<xsl:call-template name="matches">
					<xsl:with-param name="lang" select="$lang"/>
					<xsl:with-param name="facet">period</xsl:with-param>
					<xsl:with-param name="href" select="$href"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:measure | tei:dimensions/*">
		<xsl:variable name="field">
			<xsl:choose>
				<xsl:when test="string(@type)">
					<xsl:value-of select="@type"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="local-name() = 'depth'">thickness</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="local-name()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="normalize-space(.) castable as xs:decimal">
			<field name="{$field}_num">
				<xsl:value-of select="normalize-space(.)"/>
			</field>
		</xsl:if>
	</xsl:template>

	<!-- other facets -->
	<xsl:template match="tei:objectType | tei:material | tei:rs | tei:persName | tei:placeName">
		<xsl:param name="lang"/>

		<xsl:variable name="href" select="
				if (matches(@ref, 'https?://')) then
					@ref
				else
					''"/>

		<xsl:variable name="facet">
			<xsl:choose>
				<xsl:when test="string(@role)">
					<xsl:choose>
						<xsl:when test="matches(@role, 'https?://nomisma\.org')">
							<xsl:value-of select="tokenize(@role, '/')[last()]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@role"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="string(@type)">
					<!-- convert EpiDoc 'execution' with numismatic 'manufacture' -->
					<xsl:choose>
						<xsl:when test="@type = 'execution'">manufacture</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@type"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<!-- normalize misc. XML elements to existing fields, if possible -->
					<xsl:choose>
						<xsl:when test="local-name() = 'origDate'">period</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="local-name()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
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
			<xsl:call-template name="matches">
				<xsl:with-param name="lang" select="$lang"/>
				<xsl:with-param name="facet" select="$facet"/>
				<xsl:with-param name="href" select="$href"/>
			</xsl:call-template>
		</xsl:if>


		<xsl:if test="$facet = 'productionPlace' or $facet = 'findspot'">
			<xsl:if test="contains($href, 'nomisma.org')">

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
					<field name="{if ($facet = 'productionPlace') then 'mint' else $facet}_geo">
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
						<xsl:value-of select="$href"/>
						<xsl:text>|</xsl:text>
						<xsl:value-of select="concat($coordinates/long, ',', $coordinates/lat)"/>
					</field>

					<field name="{if ($facet = 'productionPlace') then 'mint' else $facet}_loc">
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
				
				<!-- index the productionPlace URI as a mint_uri -->
				<xsl:if test="$facet = 'productionPlace'">
					<field name="mint_uri">
						<xsl:value-of select="$href"/>
					</field>
					<field name="mint_facet">
						<xsl:value-of select="$label"/>
					</field>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<!-- images -->
	<xsl:template match="tei:facsimile">
		<xsl:for-each select="tei:surface[@n = 'obverse' or @n = 'reverse' or @n = 'combined']">
			<xsl:variable name="side" select="substring(@n, 1, 3)"/>
			
			<xsl:choose>
				<xsl:when test="count(tei:graphic) = 1 and tei:graphic[@n = 'iiif']">
					<field name="iiif_{$side}">
						<xsl:value-of select="tei:graphic/@url"/>
					</field>
					<field name="thumbnail_{$side}">
						<xsl:value-of select="concat(tei:graphic/@url, '/full/,120/0/default.jpg')"/>
					</field>
					<field name="reference_{$side}">
						<xsl:value-of select="concat(tei:graphic/@url, '/full/400,/0/default.jpg')"/>
					</field>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="tei:graphic[@n = 'iiif' or @n = 'archive' or @n = 'thumbnail' or @n = 'reference']">
						<field name="{@n}_{$side}">
							<xsl:value-of select="tei:graphic/@url"/>
						</field>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			
		</xsl:for-each>
		<field name="imagesavailable">true</field>
	</xsl:template>

	<xsl:template name="matches">
		<xsl:param name="href"/>
		<xsl:param name="lang"/>
		<xsl:param name="facet"/>

		<!-- ingest matchinging URIs -->
		<xsl:for-each select="$rdf/*[@rdf:about = $href]/skos:exactMatch | $rdf/*[@rdf:about = $href]/skos:closeMatch">
			<field name="{$facet}_match_uri">
				<xsl:value-of select="@rdf:resource"/>
			</field>
		</xsl:for-each>
		<!-- ingest alternate labels -->
		<xsl:for-each select="
				$rdf/*[@rdf:about = $href]/skos:altLabel[if (string($lang)) then
					@xml:lang = $lang
				else
					@xml:lang = 'en']">
			<field name="{$facet}_text">
				<xsl:value-of select="."/>
			</field>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
