<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:nuds="http://nomisma.org/nuds" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:datetime="http://exslt.org/dates-and-times" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:gml="http://www.opengis.net/gml/" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0" exclude-result-prefixes="#all">

	<xsl:template name="nuds">
		<xsl:apply-templates select="//nuds:nuds"/>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<xsl:variable name="id" select="nuds:nudsHeader/nuds:nudsid"/>

		<doc>
			<field name="id">
				<xsl:value-of select="$id"/>
			</field>
			<xsl:if test="$collection-name = 'ocre'">
				<xsl:call-template name="sortid"/>
			</xsl:if>
			<field name="collection-name">
				<xsl:value-of select="$collection-name"/>
			</field>
			<field name="recordType">
				<xsl:value-of select="@recordType"/>
			</field>
			<field name="publisher_display">
				<xsl:value-of select="$publisher"/>
			</field>
			<field name="timestamp">
				<xsl:value-of select="if(contains(datetime:dateTime(), 'Z')) then datetime:dateTime() else concat(datetime:dateTime(), 'Z')"/>
			</field>

			<!-- insert coin type facets and URIs -->
			<xsl:for-each select="descendant::nuds:typeDesc[string(@xlink:href)]">
				<xsl:variable name="href" select="@xlink:href"/>
				<field name="coinType_uri">
					<xsl:value-of select="$href"/>
				</field>
				<field name="coinType_facet">
					<xsl:value-of select="exsl:node-set($nudsGroup)//object[@xlink:href=$href]/descendant::nuds:title"/>
				</field>
			</xsl:for-each>

			<xsl:apply-templates select="nuds:descMeta"/>
			<xsl:choose>
				<xsl:when test="string($sparql_endpoint)">
					<!-- get findspots -->
					<xsl:apply-templates select="$sparqlResult/descendant::res:group[@id=$id]/res:result"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="nuds:digRep"/>
				</xsl:otherwise>
			</xsl:choose>
		</doc>
	</xsl:template>

	<xsl:template match="res:result">
		<xsl:variable name="title" select="res:binding[@name='title']/res:literal"/>
		<xsl:variable name="uri" select="res:binding[@name='findspot']/res:uri"/>

		<field name="findspot_facet">
			<xsl:value-of select="$title"/>
		</field>
		<xsl:if test="$geonames//place[@id=$uri]">
			<field name="findspot_uri">
				<xsl:value-of select="$uri"/>
			</field>
			<field name="findspot_geo">
				<xsl:value-of select="$title"/>
				<xsl:text>|</xsl:text>
				<xsl:value-of select="$uri"/>
				<xsl:text>|</xsl:text>
				<xsl:value-of select="$geonames//place[@id=$uri]"/>
			</field>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:descMeta">
		<xsl:variable name="recordType">
			<xsl:value-of select="parent::nuds:nuds/@recordType"/>
		</xsl:variable>
		<xsl:variable name="nuds:typeDesc_resource">
			<xsl:if test="string(nuds:typeDesc/@xlink:href)">
				<xsl:value-of select="nuds:typeDesc/@xlink:href"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="typeDesc">
			<xsl:choose>
				<xsl:when test="string(nuds:typeDesc/@xlink:href)">
					<xsl:choose>
						<xsl:when test="string($nuds:typeDesc_resource)">
							<xsl:copy-of select="exsl:node-set($nudsGroup)/nudsGroup/object[@xlink:href = $nuds:typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:typeDesc"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="/content/nuds:nuds/nuds:descMeta/nuds:typeDesc"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="nuds:typeDesc"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:call-template name="get_coin_sort_fields">
			<xsl:with-param name="typeDesc" select="$typeDesc"/>
		</xsl:call-template>

		<field name="title_display">
			<xsl:value-of select="normalize-space(nuds:title)"/>
		</field>
		<xsl:if test="string(nuds:department)">
			<field name="department_facet">
				<xsl:value-of select="nuds:department"/>
			</field>
		</xsl:if>
		<xsl:apply-templates select="nuds:subjectSet"/>
		<xsl:apply-templates select="nuds:physDesc"/>
		<xsl:apply-templates select="exsl:node-set($typeDesc)//nuds:typeDesc">
			<xsl:with-param name="recordType" select="$recordType"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nuds:adminDesc"/>
		<xsl:apply-templates select="nuds:refDesc"/>
		<xsl:apply-templates select="nuds:findspotDesc"/>
	</xsl:template>

	<xsl:template match="nuds:findspotDesc">
		<xsl:choose>
			<xsl:when test="string(@xlink:href)">
				<xsl:variable name="href" select="@xlink:href"/>
				<xsl:choose>
					<xsl:when test="contains($href, 'nomisma.org')">
						<xsl:variable name="label">
							<xsl:choose>
								<xsl:when test="string(exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel)">
									<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$href"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:if test="string(exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/descendant::gml:pos[1])">
							<xsl:variable name="coordinates" select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/descendant::gml:pos[1]"/>
							<xsl:if test="string($coordinates)">
								<xsl:variable name="lat" select="substring-before($coordinates, ' ')"/>
								<xsl:variable name="lon" select="substring-after($coordinates, ' ')"/>
								<!-- *_geo format is 'mint name|URI of resource|KML-compliant geographic coordinates' -->
								<field name="findspot_geo">
									<xsl:value-of select="$label"/>
									<xsl:text>|</xsl:text>
									<xsl:value-of select="@xlink:href"/>
									<xsl:text>|</xsl:text>
									<xsl:value-of select="concat($lon, ',', $lat)"/>
								</field>
							</xsl:if>
						</xsl:if>
						<xsl:if test="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/descendant::nm:findspot[contains(@rdf:resource, 'geonames.org')]">
							<xsl:variable name="geonamesUri" select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/descendant::nm:findspot[contains(@rdf:resource, 'geonames.org')][1]/@rdf:resource"/>
							<field name="findspot_geo">
								<xsl:value-of select="$label"/>
								<xsl:text>|</xsl:text>
								<xsl:value-of select="$href"/>
								<xsl:text>|</xsl:text>
								<xsl:value-of select="exsl:node-set($geonames)//place[@id=$geonamesUri]"/>
							</field>

							<!-- insert hierarchical facets -->
							<xsl:for-each select="tokenize(exsl:node-set($geonames)//place[@id=$geonamesUri]/@hierarchy, '\|')">
								<field name="findspot_hier">
									<xsl:value-of select="concat('L', position(), '|', .)"/>
								</field>
								<field name="findspot_text">
									<xsl:value-of select="."/>
								</field>


							</xsl:for-each>
						</xsl:if>
						<field name="findspot_facet">
							<xsl:value-of select="$label"/>
						</field>
					</xsl:when>
				</xsl:choose>
				<field name="findspot_uri">
					<xsl:value-of select="$href"/>
				</field>
			</xsl:when>
			<xsl:otherwise>
				<!--<field name="findspot_geo">
					<xsl:value-of select="concat(nuds:findspot/nuds:geogname[@xlink:role='findspot'], '|', tokenize(findspot/gml:Point/gml:coordinates, ', ')[2], ',', tokenize(findspot/gml:Point/gml:coordinates, ', ')[1])"/>
					</field>-->
				<field name="findspot_facet">
					<xsl:value-of select="nuds:findspot/nuds:geoname[@xlink:role='findspot']"/>
				</field>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:subjectSet">
		<xsl:for-each select="nuds:subject">
			<xsl:choose>
				<xsl:when test="string(@type)">
					<xsl:choose>
						<xsl:when test="@type='category'">
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
							<field name="{@type}_facet">
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
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nuds:digRep">
		<xsl:apply-templates select="mets:fileSec"/>
		<xsl:for-each select="nuds:associatedObject">
			<xsl:call-template name="associatedObject"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="associatedObject">
		<xsl:variable name="objectDoc">
			<xsl:copy-of select="document(concat(@xlink:href, '.xml'))/nuds:nuds"/>
		</xsl:variable>

		<field name="ao_uri">
			<xsl:value-of select="@xlink:href"/>
		</field>

		<xsl:if test="number(exsl:node-set($objectDoc)//nuds:weight)">
			<field name="ao_weight">
				<xsl:value-of select="exsl:node-set($objectDoc)//nuds:weight"/>
			</field>
		</xsl:if>
		<xsl:if test="number(exsl:node-set($objectDoc)//nuds:diameter)">
			<field name="ao_diameter">
				<xsl:value-of select="exsl:node-set($objectDoc)//nuds:diameter"/>
			</field>
		</xsl:if>
		<xsl:if test="number(exsl:node-set($objectDoc)//nuds:axis)">
			<field name="ao_axis">
				<xsl:value-of select="exsl:node-set($objectDoc)//nuds:axis"/>
			</field>
		</xsl:if>

		<!-- images -->
		<!-- thumbnails-->
		<xsl:if test="string(exsl:node-set($objectDoc)//mets:fileGrp[@USE='obverse']/mets:file[@USE='thumbnail']/mets:FLocat/@xlink:href)">
			<field name="ao_thumbnail_obv">
				<xsl:value-of select="exsl:node-set($objectDoc)//nuds:nudsid"/>
				<xsl:text>|</xsl:text>
				<xsl:value-of select="exsl:node-set($objectDoc)//mets:fileGrp[@USE='obverse']/mets:file[@USE='thumbnail']/mets:FLocat/@xlink:href"/>
			</field>
		</xsl:if>
		<xsl:if test="string(exsl:node-set($objectDoc)//mets:fileGrp[@USE='reverse']/mets:file[@USE='thumbnail']/mets:FLocat/@xlink:href)">
			<field name="ao_thumbnail_rev">
				<xsl:value-of select="exsl:node-set($objectDoc)//nuds:nudsid"/>
				<xsl:text>|</xsl:text>
				<xsl:value-of select="exsl:node-set($objectDoc)//mets:fileGrp[@USE='reverse']/mets:file[@USE='thumbnail']/mets:FLocat/@xlink:href"/>
			</field>
		</xsl:if>
		<!-- reference-->
		<xsl:if test="string(exsl:node-set($objectDoc)//mets:fileGrp[@USE='obverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href)">
			<field name="ao_reference_obv">
				<xsl:value-of select="exsl:node-set($objectDoc)//nuds:nudsid"/>
				<xsl:text>|</xsl:text>
				<xsl:value-of select="exsl:node-set($objectDoc)//mets:fileGrp[@USE='obverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href"/>
			</field>
		</xsl:if>
		<xsl:if test="string(exsl:node-set($objectDoc)//mets:fileGrp[@USE='reverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href)">
			<field name="ao_reference_rev">
				<xsl:value-of select="exsl:node-set($objectDoc)//nuds:nudsid"/>
				<xsl:text>|</xsl:text>
				<xsl:value-of select="exsl:node-set($objectDoc)//mets:fileGrp[@USE='reverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href"/>
			</field>
		</xsl:if>

		<!-- set imagesavailable to true if there are associated images -->
		<xsl:if test="exsl:node-set($objectDoc)//mets:FLocat/@xlink:href">
			<field name="imagesavailable">true</field>
		</xsl:if>

		<!-- get findspot, if available -->
		<xsl:if test="count(exsl:node-set($objectDoc)//nuds:findspot) &gt; 0">
			<xsl:variable name="name" select="exsl:node-set($objectDoc)//nuds:findspot/nuds:name"/>
			<xsl:variable name="gml-coordinates" select="exsl:node-set($objectDoc)//nuds:findspot/gml:coordinates"/>
			<xsl:variable name="kml-coordinates" select="concat(tokenize($gml-coordinates, ', ')[2], ',', tokenize($gml-coordinates, ', ')[1])"/>

			<xsl:if test="string($kml-coordinates)">
				<field name="ao_findspot_geo">
					<xsl:value-of select="concat($name, '|', @xlink:href, '|', $kml-coordinates)"/>
				</field>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="mets:fileSec">
		<xsl:for-each select="mets:fileGrp[@USE='obverse' or @USE='reverse']">
			<xsl:variable name="side" select="substring(@USE, 1, 3)"/>
			<xsl:for-each select="mets:file">
				<field name="{@USE}_{$side}">
					<xsl:value-of select="mets:FLocat/@xlink:href"/>
				</field>
			</xsl:for-each>
		</xsl:for-each>
		<field name="imagesavailable">true</field>
	</xsl:template>

	<xsl:template match="nuds:physDesc">
		<xsl:apply-templates select="nuds:axis"/>
		<xsl:apply-templates select="nuds:measurementsSet"/>
		<xsl:for-each select="descendant::nuds:grade">
			<field name="grade_facet">
				<xsl:value-of select="."/>
			</field>
		</xsl:for-each>

		<!-- dateOnObject -->
		<xsl:for-each select="nuds:dateOnObject/*[string(@standardDate)]/@standardDate">
			<xsl:sort order="ascending"/>
			<field name="dob_num">
				<xsl:value-of select="."/>
			</field>
			<!-- add min and max -->
			<xsl:if test="position() = 1">
				<field name="dob_min">
					<xsl:value-of select="."/>
				</field>
			</xsl:if>
			<xsl:if test="position() = last()">
				<field name="dob_max">
					<xsl:value-of select="."/>
				</field>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nuds:adminDesc">
		<xsl:for-each select="nuds:collection | nuds:repository | nuds:owner">
			<field name="{local-name()}_facet">
				<xsl:value-of select="normalize-space(.)"/>
			</field>
		</xsl:for-each>

		<xsl:if test="nuds:identifier">
			<field name="identifier_display">
				<xsl:value-of select="normalize-space(nuds:identifier)"/>
			</field>
			<field name="identifier_text">
				<xsl:value-of select="normalize-space(nuds:identifier)"/>
			</field>
		</xsl:if>

		<xsl:for-each select="nuds:provenance/nuds:chronList/nuds:chronItem/nuds:previousColl|nuds:provenance/nuds:chronList/nuds:chronItem/nuds:auction/nuds:saleCatalog">
			<field name="provenance_text">
				<xsl:value-of select="."/>
			</field>
			<field name="provenance_facet">
				<xsl:value-of select="."/>
			</field>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nuds:measurementsSet">
		<xsl:for-each select="*">
			<xsl:if test="number(.)">
				<field name="{local-name()}_num">
					<xsl:value-of select="normalize-space(.)"/>
				</field>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nuds:axis">
		<xsl:if test="number(.)">
			<field name="axis_num">
				<xsl:value-of select="."/>
			</field>
		</xsl:if>
	</xsl:template>

	<xsl:template name="sortid">
		<field name="sortid">
			<xsl:variable name="segs" select="tokenize(nuds:nudsHeader/nuds:nudsid, '\.')"/>
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
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="num">
				<xsl:choose>
					<xsl:when test="lower-case(substring($segs[4], string-length($segs[4]), 1)) = 'a'">
						<xsl:value-of select="format-number(number(substring($segs[4], 1, string-length($segs[4]) - 1)), '0000')"/>
						<xsl:text>.1</xsl:text>
					</xsl:when>
					<xsl:when test="lower-case(substring($segs[4], string-length($segs[4]), 1)) = 'b'">
						<xsl:value-of select="format-number(number(substring($segs[4], 1, string-length($segs[4]) - 1)), '0000')"/>
						<xsl:text>.2</xsl:text>
					</xsl:when>
					<xsl:when test="lower-case(substring($segs[4], string-length($segs[4]), 1)) = 'c'">
						<xsl:value-of select="format-number(number(substring($segs[4], 1, string-length($segs[4]) - 1)), '0000')"/>
						<xsl:text>.3</xsl:text>
					</xsl:when>
					<xsl:when test="lower-case(substring($segs[4], string-length($segs[4]), 1)) = 'd'">
						<xsl:value-of select="format-number(number(substring($segs[4], 1, string-length($segs[4]) - 1)), '0000')"/>
						<xsl:text>.4</xsl:text>
					</xsl:when>
					<xsl:when test="lower-case(substring($segs[4], string-length($segs[4]), 1)) = 'e'">
						<xsl:value-of select="format-number(number(substring($segs[4], 1, string-length($segs[4]) - 1)), '0000')"/>
						<xsl:text>.5</xsl:text>
					</xsl:when>
					<xsl:when test="lower-case(substring($segs[4], string-length($segs[4]), 1)) = 'f'">
						<xsl:value-of select="format-number(number(substring($segs[4], 1, string-length($segs[4]) - 1)), '0000')"/>
						<xsl:text>.6</xsl:text>
					</xsl:when>
					<xsl:when test="lower-case(substring($segs[4], string-length($segs[4]), 1)) = 'g'">
						<xsl:value-of select="format-number(number(substring($segs[4], 1, string-length($segs[4]) - 1)), '0000')"/>
						<xsl:text>.7</xsl:text>
					</xsl:when>
					<xsl:when test="lower-case(substring($segs[4], string-length($segs[4]), 1)) = 'h'">
						<xsl:value-of select="format-number(number(substring($segs[4], 1, string-length($segs[4]) - 1)), '0000')"/>
						<xsl:text>.8</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(number($segs[4]), '0000')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:value-of select="concat($segs[1], '.', $segs[2], '.', $auth, '.', $num)"/>
		</field>
	</xsl:template>

</xsl:stylesheet>
