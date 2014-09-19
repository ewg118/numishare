<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" version="2.0">
	<!-- ************** SEARCH FORM ************** -->
	<xsl:template name="search_forms">
		<div class="search-form">
			<p>To conduct a free text search select ‘Keyword’ on the drop-down menu above and enter the text for which you wish to search. The search allows wildcard searches with the * and ?
				characters and exact string matches by surrounding phrases by double quotes (like Google). <a href="http://lucene.apache.org/java/2_9_1/queryparsersyntax.html#Term%20Modifiers"
					target="_blank">See the Lucene query syntax</a> documentation for more information.</p>
			<form id="advancedSearchForm" method="GET" action="results">
				<div class="inputContainer">
					<div class="searchItemTemplate">
						<select class="category_list form-control">
							<xsl:call-template name="search_options"/>
						</select>
						<div style="display:inline;" class="option_container">
							<input type="text" id="search_text" class="search_text form-control" style="display: inline;"/>
						</div>
						<a class="gateTypeBtn" href="#">
							<span class="glyphicon glyphicon-plus"/>
						</a>
					</div>
				</div>
				<input name="q" id="q_input" type="hidden"/>
				<xsl:if test="string($lang)">
					<input name="lang" type="hidden" value="{$lang}"/>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$pipeline='analyze'">
						<input type="submit" value="Filter" id="filterButton" class="btn btn-default"/>
					</xsl:when>
					<xsl:when test="$pipeline='visualize'">
						<input type="submit" value="{numishare:normalizeLabel('visualize_add_query', $lang)}" class="btn btn-default"/>
					</xsl:when>
					<xsl:otherwise>
						<input type="submit" value="{numishare:normalizeLabel('header_search', $lang)}" class="btn btn-default"/>
					</xsl:otherwise>
				</xsl:choose>

			</form>

			<xsl:if test="$pipeline='visualize'">
				<span style="display:none" id="paramName"/>
			</xsl:if>
		</div>

		<div id="searchItemTemplate" class="searchItemTemplate">
			<select class="category_list form-control">
				<xsl:call-template name="search_options"/>
			</select>
			<div style="display:inline;" class="option_container">
				<input type="text" class="search_text form-control" style="display: inline;"/>
			</div>
			<a class="gateTypeBtn" href="#">
				<span class="glyphicon glyphicon-plus"/>
			</a>
			<a class="removeBtn" href="#" style="display:none;">
				<span class="glyphicon glyphicon-remove"/>
			</a>
		</div>
	</xsl:template>

	<!-- ************** SEARCH DROP-DOWN MENUS ************** -->
	<xsl:template name="search_options">
		<xsl:variable name="fields">
			<xsl:text>fulltext,artist_facet,authority_facet,coinType_facet,deity_facet,denomination_facet,dynasty_facet,recordId,issuer_facet,legend_text,obv_leg_text,rev_leg_text,maker_facet,manufacture_facet,material_facet,mint_facet,objectType_facet,portrait_facet,reference_text,region_facet,type_text,obv_type_text,rev_type_text,year_num</xsl:text>
		</xsl:variable>

		<xsl:for-each select="tokenize($fields, ',')">
			<xsl:variable name="name" select="."/>
			<xsl:variable name="root" select="substring-before($name, '_')"/>
			<xsl:choose>
				<xsl:when test="$collection_type='hoard'">
					<xsl:if test="not($name='diameter_num') and not($name='weight_num') and not($name='year_num')">
						<xsl:choose>
							<!-- display only those search options when their facet equivalent has hits -->
							<xsl:when test="$facets//lst[starts-with(@name, $root)][number(int[@name='numFacetTerms']) &gt; 0]">
								<option value="{$name}" class="search_option">
									<xsl:value-of select="numishare:normalize_fields($name, $lang)"/>
								</option>
							</xsl:when>
							<!-- display those search options when they aren't connected to facets -->
							<xsl:when test="not($facets//lst[starts-with(@name, $root)])">
								<option value="{$name}" class="search_option">
									<xsl:value-of select="numishare:normalize_fields($name, $lang)"/>
								</option>
							</xsl:when>
						</xsl:choose>

					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="not($name='taq_num') and not($name='tpq_num')">
						<xsl:choose>
							<!-- display only those search options when their facet equivalent has hits -->
							<xsl:when test="$facets//lst[starts-with(@name, $root)][number(int[@name='numFacetTerms']) &gt; 0]">
								<option value="{$name}" class="search_option">
									<xsl:value-of select="numishare:normalize_fields($name, $lang)"/>
								</option>
							</xsl:when>
							<!-- display those search options when they aren't connected to facets -->
							<xsl:when test="not($facets//lst[starts-with(@name, $root)])">
								<option value="{$name}" class="search_option">
									<xsl:value-of select="numishare:normalize_fields($name, $lang)"/>
								</option>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
