<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date modified: February 2021
	Function: Construct Solr results into a CSV model, dependent upon the collection type -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>

	<!-- url params -->
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[. = 'accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[. = 'accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="uri_space" select="/content/config/uri_space"/>
	<xsl:variable name="collection_type" select="/content/config/collection_type"/>
	
	<!-- list of fields to display in the csv -->
	<xsl:variable name="fields" as="element()*">
		<fields>
			<xsl:choose>
				<xsl:when test="$collection_type = 'hoard'">
					<field>title_display</field>
					<field>recordId</field>
					<field>tpq_num</field>
					<field>taq_num</field>
					<field>coinType_uri</field>
					<field>description_display</field>
					<field>findspot_display</field>
					<field>findspot_uri</field>
					<field>reference_facet</field>
					<field>timestamp</field>
				</xsl:when>
				<xsl:when test="$collection_type = 'cointype'">
					<field>title_display</field>
					<field>recordId</field>
					<field>year_num</field>

					<!-- facets -->
					<xsl:for-each select="/content/config/facets/facet">
						<field>
							<xsl:value-of select="."/>
						</field>
					</xsl:for-each>

					<!-- obverse/reverse typological attributes -->
					<field>obv_leg_display</field>
					<field>obv_type_display</field>
					<field>rev_leg_display</field>
					<field>rev_type_display</field>

					<!-- symbols -->
					<xsl:if test="count(/content/config/positions/position) &gt; 0">
						<xsl:for-each select="/content/config/positions/position">
							<xsl:choose>
								<xsl:when test="@side = 'both'">
									<field label="Obverse {label[@lang = 'en']}">
										<xsl:value-of select="concat('symbol_obv_', @value, '_facet')"/>
									</field>
									<field label="Reverse {label[@lang = 'en']}">
										<xsl:value-of select="concat('symbol_rev_', @value, '_facet')"/>
									</field>
								</xsl:when>
								<xsl:otherwise>
									<field label="{concat(upper-case(substring(@side, 1, 1)), substring(@side, 2))}erse {label[@lang = 'en']}">
										<xsl:value-of select="concat('symbol_', @side, '_', @value, '_facet')"/>
									</field>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:if>

					<field>timestamp</field>


					<!--<xsl:text>title_display,recordId,authority_facet,degree_facet,deity_facet,denomination_facet,dynasty_facet,engraver_facet,era_facet,issuer_facet,maker_facet,manufacture_facet,material_facet,mint_facet,obv_leg_display,obv_type_display,objectType_facet,portrait_facet,reference_facet,region_facet,rev_leg_display,rev_type_display,symbol_obv_facet,symbol_rev_facet,year_num,timestamp</xsl:text>-->
				</xsl:when>
				<xsl:otherwise>
					<field>title_display</field>
					<field>recordId</field>
					<field>coinType_uri</field>
					<field>year_num</field>
					
					<!-- facets -->
					<xsl:for-each select="/content/config/facets/facet">
						<field>
							<xsl:value-of select="."/>
						</field>
					</xsl:for-each>
					
					<!-- obverse/reverse typological attributes -->
					<field>obv_leg_display</field>
					<field>obv_type_display</field>
					<field>rev_leg_display</field>
					<field>rev_type_display</field>
					<field>dob_num</field>
					<field>ah_num</field>
					
					<!-- physical attributes -->
					<field>axis_num</field>
					<field>diameter_num</field>
					<field>weight_num</field>
					
					<!-- images -->
					<field>thumbnail_obv</field>
					<field>thumbnail_rev</field>
						
					<field>timestamp</field>
				</xsl:otherwise>
			</xsl:choose>
		</fields>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:variable name="sheet" as="element()*">
			<csv>
				<!-- header -->
				<row>
					<column>
						<val>URI</val>
					</column>
					<xsl:apply-templates select="$fields//field"/>
				</row>

				<!-- each doc -->
				<xsl:for-each select="descendant::doc">
					<xsl:variable name="object-path">
						<xsl:choose>
							<xsl:when test="//config/collection_type = 'object' and string(//config/uri_space)">
								<xsl:value-of select="//config/uri_space"/>
							</xsl:when>
							<xsl:when test="//config/union_type_catalog/@enabled = true()">
								<xsl:value-of select="str[@name = 'uri_space']"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($url, 'id/')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:variable name="doc" as="element()*">
						<xsl:copy-of select="."/>
					</xsl:variable>

					<row>
						<column>
							<val>
								<xsl:value-of select="concat($object-path, str[@name = 'recordId'])"/>
							</val>
						</column>

						<xsl:for-each select="$fields//field">
							<xsl:variable name="field" select="."/>
							
							<!-- ensure that 1 or 2 blank columns are inserted as needed when the field is not in the Solr results -->
							<xsl:choose>
								<xsl:when test="$doc/*[@name = $field]">
									<xsl:apply-templates select="$doc/*[@name = $field]" mode="content"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="$field = 'year_num'">
											<column/>
											<column/>
										</xsl:when>
										<xsl:otherwise>											
											<column/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</row>
				</xsl:for-each>
			</csv>
		</xsl:variable>

		<xsl:apply-templates select="$sheet//row"/>
	</xsl:template>

	<!-- fields -->
	<xsl:template match="field">
		<xsl:choose>
			<xsl:when test=". = 'region_hier'">
				<column>
					<val>
						<xsl:value-of select="numishare:regularize_node('region', $lang)"/>
					</val>
				</column>
			</xsl:when>
			<xsl:when test=". = 'year_num'">
				<column>
					<val>
						<xsl:value-of select="numishare:regularize_node('fromDate', $lang)"/>
					</val>
				</column>
				<column>
					<val>
						<xsl:value-of select="numishare:regularize_node('toDate', $lang)"/>
					</val>
				</column>
			</xsl:when>
			<xsl:otherwise>
				<column>
					<val>
						<xsl:choose>
							<xsl:when test="@label">
								<xsl:value-of select="@label"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="numishare:normalize_fields(., $lang)"/>
							</xsl:otherwise>
						</xsl:choose>
					</val>
				</column>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- CSV structure templates -->
	<xsl:template match="row">
		<xsl:apply-templates select="column"/>

		<xsl:if test="not(position() = last())">
			<xsl:text>&#x0A;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="column">
		<xsl:text>"</xsl:text>
		<xsl:value-of select="replace(string-join(val, '||'), '&#x022;', '&#x022;&#x022;')"/>
		<xsl:text>"</xsl:text>
		<xsl:if test="not(position() = last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- Solr templates -->
	<xsl:template match="*[@name = 'year_num']" mode="content">
		<xsl:apply-templates select="int">
			<xsl:sort order="ascending" data-type="number"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="int">
		<column>
			<val>
				<xsl:value-of select="."/>
			</val>
		</column>
	</xsl:template>
	
	<!-- display only lowest-level region -->
	<xsl:template match="arr[@name = 'region_hier']" mode="content">
		<column>
			<val>
				<xsl:value-of select="substring-before(substring-after(str[last()], '|'), '/')"/>
			</val>
		</column>
		
		<!--<xsl:for-each select="str">
			<xsl:value-of select="tokenize(tokenize(., '\|')[last()], '/')[last()]"/>
			<xsl:if test="not(position() = last())">
				<xsl:text>||</xsl:text>
			</xsl:if>
		</xsl:for-each>-->
		
	</xsl:template>

	<xsl:template match="*" mode="content">
		<column>
			<xsl:choose>
				<xsl:when test="child::*">

					<xsl:for-each select="distinct-values(child::*)">
						<val>
							<xsl:value-of select="normalize-space(.)"/>
						</val>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<val>
						<xsl:value-of select="normalize-space(.)"/>
					</val>
				</xsl:otherwise>
			</xsl:choose>
		</column>
	</xsl:template>
</xsl:stylesheet>
