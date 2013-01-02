<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:exsl="http://exslt.org/common" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:numishare="http://code.google.com/p/numishare/" exclude-result-prefixes="#all">

	<xsl:template name="search_forms">
		<div class="search-form">
			<p>To conduct a free text search select ‘Keyword’ on the drop-down menu above and enter the text for which you wish to search. The search allows wildcard searches with the * and ?
				characters and exact string matches by surrounding phrases by double quotes (like Google). <a href="http://lucene.apache.org/java/2_9_1/queryparsersyntax.html#Term%20Modifiers"
					target="_blank">See the Lucene query syntax</a> documentation for more information.</p>
			<form id="advancedSearchForm" method="GET" action="results">
				<div id="inputContainer">
					<div class="searchItemTemplate">
						<select class="category_list">
							<xsl:call-template name="search_options"/>
						</select>
						<div style="display:inline;" class="option_container">
							<input type="text" id="search_text" class="search_text" style="display: inline;"/>
						</div>
						<a class="gateTypeBtn" href="#">add »</a>
						<!--<a class="removeBtn" href="#">« remove</a>-->
					</div>
				</div>
				<input name="q" id="q_input" type="hidden"/>
				<xsl:choose>
					<xsl:when test="$pipeline='analyze'">
						<input type="submit" value="Filter" id="filterButton"/>
					</xsl:when>
					<xsl:when test="$pipeline='visualize'">
						<input type="submit" value="Add Query" id="search_buttom"/>
					</xsl:when>
					<xsl:otherwise>
						<input type="submit" value="Search" id="search_button"/>
					</xsl:otherwise>
				</xsl:choose>

			</form>

			<xsl:if test="$pipeline='visualize'">
				<span style="display:none" id="paramName"/>
			</xsl:if>
		</div>

		<div id="searchItemTemplate" class="searchItemTemplate">
			<select class="category_list">
				<xsl:call-template name="search_options"/>
			</select>
			<div style="display:inline;" class="option_container">
				<input type="text" class="search_text" style="display: inline;"/>
			</div>
			<a class="gateTypeBtn" href="#">add »</a>
			<a class="removeBtn" href="#" style="display:none;">« remove</a>
		</div>
	</xsl:template>

	<xsl:template name="search_options">
		<xsl:variable name="fields">
			<xsl:text>fulltext,artist_text,authority_text,coinType_facet,color_text,deity_text,denomination_facet,department_facet,diameter_num,dynasty_facet,findspot_text,objectType_facet,identifier_display,issuer_text,legend_text,obv_leg_text,rev_leg_text,maker_text,manufacture_facet,material_facet,mint_text,portrait_text,reference_facet,region_text,taq_num,tpq_num,type_text,obv_type_text,rev_type_text,weight_num,year_num</xsl:text>
		</xsl:variable>

		<xsl:for-each select="tokenize($fields, ',')">
			<xsl:variable name="name" select="."/>
			<xsl:variable name="root" select="substring-before($name, '_')"/>
			<xsl:choose>
				<xsl:when test="$collection_type='hoard'">
					<xsl:if test="not($name='diameter_num') and not($name='weight_num') and not($name='year_num')">
						<xsl:choose>
							<!-- display only those search options when their facet equivalent has hits -->
							<xsl:when test="exsl:node-set($facets)//lst[starts-with(@name, $root)][number(int[@name='numFacetTerms']) &gt; 0]">
								<option value="{$name}" class="search_option">
									<xsl:value-of select="numishare:normalize_fields($name)"/>
								</option>
							</xsl:when>
							<!-- display those search options when they aren't connected to facets -->
							<xsl:when test="not(exsl:node-set($facets)//lst[starts-with(@name, $root)])">
								<option value="{$name}" class="search_option">
									<xsl:value-of select="numishare:normalize_fields($name)"/>
								</option>
							</xsl:when>
						</xsl:choose>

					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="not($name='taq_num') and not($name='tpq_num')">
						<xsl:choose>
							<!-- display only those search options when their facet equivalent has hits -->
							<xsl:when test="exsl:node-set($facets)//lst[starts-with(@name, $root)][number(int[@name='numFacetTerms']) &gt; 0]">
								<option value="{$name}" class="search_option">
									<xsl:value-of select="numishare:normalize_fields($name)"/>
								</option>
							</xsl:when>
							<!-- display those search options when they aren't connected to facets -->
							<xsl:when test="not(exsl:node-set($facets)//lst[starts-with(@name, $root)])">
								<option value="{$name}" class="search_option">
									<xsl:value-of select="numishare:normalize_fields($name)"/>
								</option>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:function name="numishare:normalize_century">
		<xsl:param name="name"/>
		<xsl:variable name="cleaned" select="number(translate($name, '\', ''))"/>
		<xsl:variable name="century" select="abs($cleaned)"/>
		<xsl:variable name="suffix">
			<xsl:choose>
				<xsl:when test="$century mod 10 = 1 and $century != 11">
					<xsl:text>st</xsl:text>
				</xsl:when>
				<xsl:when test="$century mod 10 = 2 and $century != 12">
					<xsl:text>nd</xsl:text>
				</xsl:when>
				<xsl:when test="$century mod 10 = 3 and $century != 13">
					<xsl:text>rd</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>th</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="concat($century, $suffix)"/>
		<xsl:if test="$cleaned &lt; 0">
			<xsl:text> B.C.</xsl:text>
		</xsl:if>
	</xsl:function>

	<xsl:function name="numishare:normalize_fields">
		<xsl:param name="field"/>
		<xsl:choose>
			<xsl:when test="contains($field, '_uri')">
				<xsl:variable name="name" select="substring-before($field, '_uri')"/>
				<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
				<xsl:text> URI</xsl:text>
			</xsl:when>
			<xsl:when test="contains($field, '_facet')">
				<xsl:variable name="name" select="substring-before($field, '_facet')"/>
				<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
			</xsl:when>
			<xsl:when test="$field = 'timestamp'">Date Record Modified</xsl:when>
			<xsl:when test="$field = 'fulltext'">Keyword</xsl:when>
			<xsl:when test="$field = 'dob'">Date on Object</xsl:when>
			<xsl:when test="$field = 'imagesavailable'">Has Images</xsl:when>
			<xsl:when test="$field = 'imagesponsor_display'">Image Sponsor</xsl:when>
			<xsl:when test="$field = 'obv_leg_display'">Obv. Legend</xsl:when>
			<xsl:when test="$field = 'obv_leg_text'">Obv. Legend</xsl:when>
			<xsl:when test="$field = 'obv_type_text'">Obv. Type</xsl:when>
			<xsl:when test="$field = 'prevcoll_display'">Previous Collection</xsl:when>
			<xsl:when test="$field = 'rev_leg_display'">Rev. Legend</xsl:when>
			<xsl:when test="$field = 'rev_leg_text'">Rev. Legend</xsl:when>
			<xsl:when test="$field = 'rev_type_text'">Rev. Type</xsl:when>
			<xsl:when test="$field = 'taq_num'">Terminus Ante Quem</xsl:when>
			<xsl:when test="$field = 'tpq_num'">Terminus Post Quem</xsl:when>
			<xsl:when test="$field = 'closing_date_display'">Closing Date</xsl:when>
			<xsl:when test="contains($field, '_num')">
				<xsl:variable name="name" select="substring-before($field, '_num')"/>
				<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
			</xsl:when>
			<xsl:when test="contains($field, '_text')">
				<xsl:variable name="name" select="substring-before($field, '_text')"/>
				<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
			</xsl:when>
			<xsl:when test="contains($field, '_min') or contains($field, '_max')">
				<xsl:variable name="name" select="substring-before($field, '_m')"/>
				<xsl:value-of select="numishare:normalize_fields($name)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_display')">
				<xsl:variable name="name" select="substring-before($field, '_display')"/>
				<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
			</xsl:when>
			<xsl:when test="not(contains($field, '_'))">
				<xsl:value-of select="concat(upper-case(substring($field, 1, 1)), substring($field, 2))"/>
			</xsl:when>
			<xsl:otherwise>Undefined Category</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template name="recompile_category">
		<xsl:param name="level" as="xs:integer"/>
		<xsl:param name="category_fragment"/>
		<xsl:param name="tokenized_fragment"/>
		<xsl:value-of select="substring-after(replace($tokenized_fragment[contains(., concat('L', $level, '|'))], '&#x022;', ''), '|')"/>
		<!--<xsl:value-of select="substring-after(replace(., '&#x022;', ''), '|')"/>-->
		<xsl:if test="contains($category_fragment, concat('L', $level + 1, '|'))">
			<xsl:text>--</xsl:text>
			<xsl:call-template name="recompile_category">
				<xsl:with-param name="tokenized_fragment" select="$tokenized_fragment"/>
				<xsl:with-param name="category_fragment" select="$category_fragment"/>
				<xsl:with-param name="level" select="$level + 1"/>
			</xsl:call-template>
		</xsl:if>

	</xsl:template>
</xsl:stylesheet>
