<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="http://code.google.com/p/numishare/"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0" exclude-result-prefixes="xs cinclude numishare" version="2.0">

	<xsl:template match="doc">
		<xsl:variable name="sort_category" select="substring-before($sort, ' ')"/>
		<xsl:variable name="regularized_sort">
			<xsl:value-of select="numishare:normalize_fields($sort_category, $lang)"/>
		</xsl:variable>
		<xsl:variable name="collection" select="substring-before(str[@name='identifier_display'], '.')"/>


		<tr class="result_doc">
			<xsl:if test="not($mode='compare') and //config/theme/layouts/*[name()=$pipeline]/image_location = 'left'">
				<xsl:call-template name="result_image">
					<xsl:with-param name="alignment">left</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<td class="result_metadata">
				<xsl:if test="$mode='compare'">
					<xsl:variable name="img_string">
						<xsl:choose>
							<xsl:when test="$image='reverse'">
								<xsl:text>reference_rev</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>reference_obv</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<div style="text-align:center;">
						<img src="{str[@name=$img_string]}" style="height:320px"/>
					</div>
				</xsl:if>
				<span class="result_link">
					<xsl:choose>
						<xsl:when test="$mode = 'compare'">
							<a href="{$display_path}id/{str[@name='id']}?mode=compare&amp;q={$q}&amp;start={$start}&amp;image={$image}&amp;side={$side}" class="compare">
								<xsl:value-of select="str[@name='title_display']"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a href="{$display_path}id/{str[@name='id']}{if (string($lang)) then concat('?lang=', $lang) else ''}">
								<xsl:value-of select="str[@name='title_display']"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
				</span>
				<br/>
				<dl>
					<xsl:choose>
						<xsl:when test="str[@name='recordType'] = 'hoard'">
							<div>
								<dt><xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>:</dt>
								<dd style="margin-left:150px;">
									<xsl:value-of select="arr[@name='findspot_facet']/str[1]"/>
								</dd>
							</div>
							<div>
								<dt><xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/>:</dt>
								<dd style="margin-left:150px;">
									<xsl:value-of select="str[@name='closing_date_display']"/>
								</dd>
							</div>
							<xsl:if test="string(str[@name='description_display'])">
								<div>
									<dt><xsl:value-of select="numishare:regularize_node('description', $lang)"/>:</dt>
									<dd style="margin-left:150px;">
										<xsl:value-of select="str[@name='description_display']"/>
									</dd>
								</div>
							</xsl:if>
							<xsl:if test="arr[@name='reference_facet']">
								<div>
									<dt><xsl:value-of select="numishare:regularize_node('reference', $lang)"/>: </dt>
									<dd style="margin-left:150px;">
										<xsl:for-each select="arr[@name='reference_facet']/str">
											<xsl:value-of select="."/>
											<xsl:if test="not(position() = last())">
												<xsl:text>, </xsl:text>
											</xsl:if>
										</xsl:for-each>
									</dd>
								</div>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="str[@name='obv_leg_display'] or str[@name='obv_type_display']">
								<div>
									<dt><xsl:value-of select="numishare:regularize_node('obverse', $lang)"/>:</dt>
									<dd style="margin-left:150px;">
										<xsl:value-of select="str[@name='obv_leg_display']"/>
										<xsl:if test="str[@name='obv_leg_display'] and str[@name='obv_type_display']">
											<xsl:text>: </xsl:text>
										</xsl:if>
										<xsl:value-of select="str[@name='obv_type_display']"/>
									</dd>
								</div>
							</xsl:if>
							<xsl:if test="str[@name='rev_leg_display'] or str[@name='rev_type_display']">
								<div>
									<dt><xsl:value-of select="numishare:regularize_node('reverse', $lang)"/>:</dt>
									<dd style="margin-left:150px;">
										<xsl:value-of select="str[@name='rev_leg_display']"/>
										<xsl:if test="str[@name='rev_leg_display'] and str[@name='rev_type_display']">
											<xsl:text>: </xsl:text>
										</xsl:if>
										<xsl:value-of select="str[@name='rev_type_display']"/>
									</dd>
								</div>
							</xsl:if>
							<xsl:if test="float[@name='diameter_num']">
								<div>
									<dt><xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>: </dt>
									<dd style="margin-left:150px;">
										<xsl:value-of select="float[@name='diameter_num']"/>
									</dd>
								</div>
							</xsl:if>
							<xsl:if test="float[@name='weight_num']">
								<div>
									<dt><xsl:value-of select="numishare:regularize_node('weight', $lang)"/>: </dt>
									<dd style="margin-left:150px;">
										<xsl:value-of select="float[@name='weight_num']"/>
									</dd>
								</div>
							</xsl:if>
							<xsl:if test="arr[@name='reference_facet']">
								<div>
									<dt><xsl:value-of select="numishare:regularize_node('reference', $lang)"/>: </dt>
									<dd style="margin-left:150px;">
										<xsl:for-each select="arr[@name='reference_facet']/str">
											<xsl:value-of select="."/>
											<xsl:if test="not(position() = last())">
												<xsl:text>, </xsl:text>
											</xsl:if>
										</xsl:for-each>
									</dd>
								</div>
							</xsl:if>
							<xsl:if test="arr[@name='provenance_facet']">
								<div>
									<dt><xsl:value-of select="numishare:regularize_node('provenance', $lang)"/>: </dt>
									<dd style="margin-left:150px;">
										<xsl:for-each select="arr[@name='provenance_facet']/str">
											<xsl:value-of select="."/>
											<xsl:if test="not(position() = last())">
												<xsl:text>, </xsl:text>
											</xsl:if>
										</xsl:for-each>
									</dd>
								</div>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>



					<!-- display appropriate sort category if it isn't one of the default display fields -->
					<xsl:if
						test="string($sort) and not(contains($sort_category, 'year')) and not(contains($sort_category, 'department_facet')) and not(contains($sort_category, 'weight_num')) and not(contains($sort_category, 'dimensions_display'))">
						<xsl:choose>
							<xsl:when test="contains($sort, '_num')">
								<div>
									<dt>
										<xsl:value-of select="$regularized_sort"/>
										<xsl:text>:</xsl:text>
									</dt>
									<dd style="margin-left: 150px;">
										<xsl:for-each select="distinct-values(*[@name=$sort_category])">
											<xsl:sort order="descending"/>
											<xsl:value-of select="."/>
											<xsl:if test="not(position() = last())">
												<xsl:text>, </xsl:text>
											</xsl:if>
										</xsl:for-each>
									</dd>
								</div>
							</xsl:when>
							<xsl:when test="contains($sort, 'timestamp')">
								<div>
									<dt>
										<xsl:value-of select="$regularized_sort"/>
										<xsl:text>:</xsl:text>
									</dt>
									<dd style="margin-left: 150px;">
										<xsl:value-of select="date[@name='timestamp']"/>
									</dd>
								</div>
							</xsl:when>
							<xsl:when test="contains($sort, '_facet') or contains($sort, 'reference_facet') or contains($sort, 'provenance_display')">
								<div>
									<xsl:choose>
										<xsl:when test="matches($sort, 'objectType_facet')">
											<dt><xsl:value-of select="numishare:regularize_node('objectType', $lang)"/>:</dt>
											<dd style="margin-left: 150px;">
												<xsl:value-of select="str[@name='objectType_facet']"/>
											</dd>
										</xsl:when>
										<xsl:otherwise>
											<xsl:if test="arr[@name=$sort_category]/str">
												<dt>
													<xsl:value-of select="$regularized_sort"/>
													<xsl:text>:</xsl:text>
												</dt>
												<dd style="margin-left: 150px;">
													<xsl:for-each select="arr[@name=$sort_category]/str">
														<xsl:sort order="descending"/>
														<xsl:value-of select="."/>
														<xsl:if test="not(position() = last())">
															<xsl:text>, </xsl:text>
														</xsl:if>
													</xsl:for-each>
												</dd>
											</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
								</div>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="str[@name=$sort_category]">
									<div>
										<dt>
											<xsl:value-of select="$regularized_sort"/>
											<xsl:text>:</xsl:text>
										</dt>
										<dd style="margin-left: 150px;">
											<xsl:value-of select="substring(str[@name=$sort_category], 1, 25)"/>
											<xsl:if test="string-length(str[@name=$sort_category]) &gt; 25">
												<xsl:text>...</xsl:text>
											</xsl:if>
										</dd>
									</div>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</dl>
			</td>
			<xsl:if test="not($mode='compare') and //config/theme/layouts/*[name()=$pipeline]/image_location = 'right'">
				<xsl:call-template name="result_image">
					<xsl:with-param name="alignment">right</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</tr>
	</xsl:template>

	<xsl:template match="lst[@name='facet_fields']">
		<!-- ignore mint_geo-->
		<xsl:apply-templates select="lst[not(@name='mint_geo') and number(int[@name='numFacetTerms']) &gt; 0]" mode="facet"/>
		<form action="results" id="facet_form">
			<xsl:variable name="imageavailable_stripped">
				<xsl:for-each select="$tokenized_q[not(contains(., 'imagesavailable'))]">
					<xsl:value-of select="."/>
					<xsl:if test="position() != last()">
						<xsl:text> AND </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<input type="hidden" name="q" id="facet_form_query" value="{if (string($imageavailable_stripped)) then $imageavailable_stripped else '*:*'}"/>
			<xsl:if test="string($lang)">
				<input type="hidden" name="lang" value="{$lang}"/>
			</xsl:if>
			<br/>
			<xsl:if test="/content//collection_type != 'hoard'">
				<div>
					<b><xsl:value-of select="numishare:normalizeLabel('results_has-images', $lang)"/>:</b>
					<xsl:choose>
						<xsl:when test="contains($q, 'imagesavailable:true')">
							<input type="checkbox" id="imagesavailable" checked="checked"/>
						</xsl:when>
						<xsl:otherwise>
							<input type="checkbox" id="imagesavailable"/>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:if>

			<div class="submit_div">
				<input type="submit" value="{numishare:normalizeLabel('results_refine-search', $lang)}" id="search_button"
					class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only ui-state-focus"/>
			</div>
		</form>
	</xsl:template>

	<xsl:template match="lst" mode="facet">
		<xsl:variable name="val" select="@name"/>
		<xsl:variable name="new_query">
			<xsl:for-each select="$tokenized_q[not(contains(., $val))]">
				<xsl:value-of select="."/>
				<xsl:if test="position() != last()">
					<xsl:text> AND </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="contains(@name, '_hier')">
				<xsl:variable name="title" select="numishare:regularize_node(substring-before(@name, '_'), $lang)"/>

				<button class="ui-multiselect ui-widget ui-state-default ui-corner-all hierarchical-facet" type="button" title="{$title}" aria-haspopup="true" style="width: 200px;" id="{@name}_link" label="{$q}">
					<span class="ui-icon ui-icon-triangle-2-n-s"/>
					<span>
						<xsl:value-of select="$title"/>
					</span>
				</button>

				<xsl:choose>
					<xsl:when test="contains($q, @name)">
						<div class="ui-multiselect-menu ui-widget ui-widget-content ui-corner-all hierarchical-div" id="{substring-before(@name, '_hier')}-container" style="width: 200px">
							<div class="ui-widget-header ui-corner-all ui-multiselect-header ui-helper-clearfix ui-multiselect-hasfilter">
								<ul class="ui-helper-reset">
									<li class="ui-multiselect-close">
										<a class="ui-multiselect-close hier-close" href="#"> close<span class="ui-icon ui-icon-circle-close"/>
										</a>
									</li>
								</ul>
							</div>
							<ul class="{substring-before(@name, '_hier')}-multiselect-checkboxes ui-helper-reset hierarchical-list" id="{@name}-list" style="height: 175px;" title="{$title}">
								<xsl:if test="contains($q, @name)">
									<cinclude:include src="cocoon:/get_hier?q={$q}&amp;fq=*&amp;prefix=L1&amp;link=&amp;field={substring-before(@name, '_hier')}"/>
								</xsl:if>
							</ul>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="ui-multiselect-menu ui-widget ui-widget-content ui-corner-all hierarchical-div" id="{substring-before(@name, '_hier')}-container" style="width: 200px;">
							<div class="ui-widget-header ui-corner-all ui-multiselect-header ui-helper-clearfix ui-multiselect-hasfilter">
								<ul class="ui-helper-reset">
									<li class="ui-multiselect-close">
										<a class="ui-multiselect-close hier-close" href="#"> close<span class="ui-icon ui-icon-circle-close"/>
										</a>
									</li>
								</ul>
							</div>
							<ul class="{substring-before(@name, '_hier')}-multiselect-checkboxes ui-helper-reset hierarchical-list" id="{@name}-list" style="height: 175px;" title="{$title}"/>
						</div>
					</xsl:otherwise>
				</xsl:choose>
				<br/>
			</xsl:when>
			<xsl:when test="@name='century_num'">
				<button class="ui-multiselect ui-widget ui-state-default ui-corner-all" type="button" title="{numishare:regularize_node('date', $lang)}" aria-haspopup="true" style="width: 200px;"
					id="{@name}_link" label="{$q}">
					<span class="ui-icon ui-icon-triangle-2-n-s"/>
					<span>
						<xsl:value-of select="numishare:regularize_node('date', $lang)"/>
					</span>
				</button>
				<div class="ui-multiselect-menu ui-widget ui-widget-content ui-corner-all date-div" style="width: 200px;">
					<div class="ui-widget-header ui-corner-all ui-multiselect-header ui-helper-clearfix ui-multiselect-hasfilter">
						<ul class="ui-helper-reset">
							<li class="ui-multiselect-close">
								<a class="ui-multiselect-close century-close" href="#">
									<span class="ui-icon ui-icon-circle-close"/>
								</a>
							</li>
						</ul>
					</div>
					<ul class="century-multiselect-checkboxes ui-helper-reset" id="{@name}-list" style="height: 175px;">
						<xsl:if test="contains($q, @name)">
							<cinclude:include src="cocoon:/get_centuries?q={encode-for-uri($q)}"/>
						</xsl:if>
					</ul>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="count" select="number(int[@name='numFacetTerms'])"/>
				<xsl:variable name="mincount" as="xs:integer">
					<xsl:choose>
						<xsl:when test="$count &gt; 500">
							<xsl:value-of select="ceiling($count div 500)"/>
						</xsl:when>
						<xsl:otherwise>1</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="select_new_query">
					<xsl:choose>
						<xsl:when test="string($new_query)">
							<xsl:value-of select="$new_query"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>*:*</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<select id="{@name}-select" multiple="multiple" class="multiselect {@name}-button" size="10" title="{numishare:normalize_fields(@name, $lang)}" q="{$q}" mincount="{$mincount}"
					new_query="{if (contains($q, @name)) then $select_new_query else ''}">
					<xsl:if test="contains($q, @name)">
						<cinclude:include src="cocoon:/get_facet_options?q={$q}&amp;category={@name}&amp;sort=index&amp;offset=0&amp;limit=-1&amp;rows=0&amp;mincount={$mincount}"/>
					</xsl:if>
				</select>
				<br/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="lst[@name='mint_geo' or number(int[@name='numFacetTerms']) = 0]" mode="facet"/>

	<xsl:template name="result_image">
		<xsl:param name="alignment"/>
		<td class="result_image_{$alignment}">
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
							<cinclude:include src="cocoon:/widget?uri={'http://numismatics.org/ocre/'}id/{str[@name='id']}&amp;template=results"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="count" select="count(arr[@name='ao_uri']/str)"/>
							<xsl:variable name="title" select="str[@name='title_display']	"/>
							<xsl:variable name="docId" select="str[@name='id']"/>

							<xsl:if test="count(arr[@name='ao_thumbnail_obv']/str) &gt; 0">
								<xsl:variable name="nudsid" select="substring-before(arr[@name='ao_thumbnail_obv']/str[1], '|')"/>
								<a class="thumbImage" rel="{str[@name='id']}-gallery" href="{substring-after(arr[@name='ao_reference_obv']/str[contains(., $nudsid)], '|')}"
									title="Obverse of {$title}: {$nudsid}">
									<img src="{substring-after(arr[@name='ao_thumbnail_obv']/str[1], '|')}"/>
								</a>
								<xsl:if test="arr[@name='ao_thumbnail_rev']/str[contains(., $nudsid)]">
									<a class="thumbImage" rel="{str[@name='id']}-gallery" href="{substring-after(arr[@name='ao_reference_rev']/str[contains(., $nudsid)], '|')}"
										title="Reverse of {$title}: {$nudsid}">
										<img src="{substring-after(arr[@name='ao_thumbnail_rev']/str[contains(., $nudsid)], '|')}"/>
									</a>
								</xsl:if>
								<div style="display:none">
									<xsl:for-each select="arr[@name='ao_thumbnail_obv']/str[not(contains(., $nudsid))]">
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
							<xsl:if test="$count &gt; 0">
								<br/>
								<xsl:value-of select="concat($count, if($count = 1) then ' associated coin' else ' associated coins')"/>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</td>
	</xsl:template>

	<xsl:template name="remove_facets">
		<div class="remove_facets">
			<xsl:choose>
				<xsl:when test="$q = '*:*'">
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('results_all-terms', $lang)"/>
						<xsl:if test="//lst[@name='mint_geo']/int[@name='numFacetTerms'] &gt; 0">
							<a href="#resultMap" id="map_results">
								<xsl:value-of select="numishare:normalizeLabel('results_map-results', $lang)"/>
							</a>
						</xsl:if>
					</h1>
				</xsl:when>
				<xsl:otherwise>
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('results_filters', $lang)"/>
						<xsl:if test="//lst[@name='mint_geo']/int[@name='numFacetTerms'] &gt; 0">
							<a href="#resultMap" id="map_results">
								<xsl:value-of select="numishare:normalizeLabel('results_map-results', $lang)"/>
							</a>
						</xsl:if>
					</h1>
				</xsl:otherwise>
			</xsl:choose>


			<xsl:for-each select="$tokenized_q">
				<xsl:variable name="val" select="."/>
				<xsl:variable name="new_query">
					<xsl:for-each select="$tokenized_q[not($val = .)]">
						<xsl:value-of select="."/>
						<xsl:if test="position() != last()">
							<xsl:text> AND </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<!--<xsl:value-of select="."/>-->
				<xsl:choose>
					<xsl:when test="not(. = '*:*') and not(substring(., 1, 1) = '(')">
						<xsl:variable name="field" select="substring-before(., ':')"/>
						<xsl:variable name="name">
							<xsl:choose>
								<xsl:when test="string($field)">
									<xsl:value-of select="numishare:normalize_fields($field, $lang)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="numishare:normalize_fields('fulltext', $lang)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="term">
							<xsl:choose>
								<xsl:when test="string(substring-before(., ':'))">
									<xsl:value-of select="replace(substring-after(., ':'), '&#x022;', '')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="replace(., '&#x022;', '')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<div class="ui-widget ui-state-default ui-corner-all stacked_term">
							<xsl:if test="$lang='ar'">
								<xsl:attribute name="style">text-align:right</xsl:attribute>
							</xsl:if>

							<!-- establish orientation based on language parameter -->
							<xsl:choose>
								<xsl:when test="$lang='ar'">
									<a class="ui-icon ui-icon-closethick remove_filter_ar"
										href="{$display_path}results?q={if (string($new_query)) then encode-for-uri($new_query) else '*:*'}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}"/>
									<span>
										<xsl:choose>
											<xsl:when test="$field='century_num'">
												<xsl:value-of select="numishare:normalize_century($term)"/>
											</xsl:when>
											<xsl:when test="contains($field, '_hier')">
												<xsl:variable name="tokens" select="tokenize(substring($term, 2, string-length($term)-2), '\+')"/>
												<xsl:for-each select="$tokens[position() &gt; 1]">
													<xsl:sort/>
													<xsl:value-of select="normalize-space(substring-after(., '|'))"/>
													<xsl:if test="not(position()=last())">
														<xsl:text>--</xsl:text>
													</xsl:if>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$term"/>
											</xsl:otherwise>
										</xsl:choose>
										<b>:<xsl:value-of select="$name"/></b>
									</span>
								</xsl:when>
								<xsl:otherwise>
									<span>
										<b><xsl:value-of select="$name"/>: </b>
										<xsl:choose>
											<xsl:when test="$field='century_num'">
												<xsl:value-of select="numishare:normalize_century($term)"/>
											</xsl:when>
											<xsl:when test="contains($field, '_hier')">
												<xsl:variable name="tokens" select="tokenize(substring($term, 2, string-length($term)-2), '\+')"/>
												<xsl:for-each select="$tokens[position() &gt; 1]">
													<xsl:sort/>
													<xsl:value-of select="normalize-space(substring-after(., '|'))"/>
													<xsl:if test="not(position()=last())">
														<xsl:text>--</xsl:text>
													</xsl:if>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$term"/>
											</xsl:otherwise>
										</xsl:choose>
									</span>
									<a class="ui-icon ui-icon-closethick remove_filter"
										href="{$display_path}results?q={if (string($new_query)) then encode-for-uri($new_query) else '*:*'}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}"
										>X</a>
								</xsl:otherwise>
							</xsl:choose>
						</div>

					</xsl:when>
					<!-- if the token contains a parenthisis, then it was probably sent from the search widget and the token must be broken down further to remove other facets -->
					<xsl:when test="substring(., 1, 1) = '('">
						<xsl:variable name="tokenized-fragments" select="tokenize(., ' OR ')"/>

						<div class="ui-widget ui-state-default ui-corner-all stacked_term">
							<xsl:if test="$lang='ar'">
								<xsl:attribute name="style">text-align:right</xsl:attribute>
								<a class="ui-icon ui-icon-closethick remove_filter_ar"
									href="{$display_path}results?q={if (string($new_query)) then encode-for-uri($new_query) else '*:*'}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}"/>
							</xsl:if>
							<span>
								<xsl:for-each select="$tokenized-fragments">
									<xsl:variable name="field" select="substring-before(translate(., '()', ''), ':')"/>
									<xsl:variable name="after-colon" select="substring-after(., ':')"/>

									<xsl:variable name="value">
										<xsl:choose>
											<xsl:when test="substring($after-colon, 1, 1) = '&#x022;'">
												<xsl:analyze-string select="$after-colon" regex="&#x022;([^&#x022;]+)&#x022;">
													<xsl:matching-substring>
														<xsl:value-of select="concat('&#x022;', regex-group(1), '&#x022;')"/>
													</xsl:matching-substring>
												</xsl:analyze-string>
											</xsl:when>
											<xsl:when test="substring($after-colon, 1, 1) = '('">
												<xsl:analyze-string select="$after-colon" regex="\(([^\)]+)\)">
													<xsl:matching-substring>
														<xsl:value-of select="concat('(', regex-group(1), ')')"/>
													</xsl:matching-substring>
												</xsl:analyze-string>
											</xsl:when>
											<xsl:otherwise>
												<xsl:analyze-string select="$after-colon" regex="([0-9]+)">
													<xsl:matching-substring>
														<xsl:value-of select="regex-group(1)"/>
													</xsl:matching-substring>
												</xsl:analyze-string>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>

									<xsl:variable name="q_string" select="concat($field, ':', $value)"/>

									<!--<xsl:variable name="value" select="."/>-->
									<xsl:variable name="new_multicategory">
										<xsl:for-each select="$tokenized-fragments[not(contains(.,$q_string))]">
											<xsl:variable name="other_field" select="substring-before(translate(., '()', ''), ':')"/>
											<xsl:variable name="after-colon" select="substring-after(., ':')"/>

											<xsl:variable name="other_value">
												<xsl:choose>
													<xsl:when test="substring($after-colon, 1, 1) = '&#x022;'">
														<xsl:analyze-string select="$after-colon" regex="&#x022;([^&#x022;]+)&#x022;">
															<xsl:matching-substring>
																<xsl:value-of select="concat('&#x022;', regex-group(1), '&#x022;')"/>
															</xsl:matching-substring>
														</xsl:analyze-string>
													</xsl:when>
													<xsl:when test="substring($after-colon, 1, 1) = '('">
														<xsl:analyze-string select="$after-colon" regex="\(([^\)]+)\)">
															<xsl:matching-substring>
																<xsl:value-of select="concat('(', regex-group(1), ')')"/>
															</xsl:matching-substring>
														</xsl:analyze-string>
													</xsl:when>
													<xsl:otherwise>
														<xsl:analyze-string select="$after-colon" regex="([0-9]+)">
															<xsl:matching-substring>
																<xsl:value-of select="regex-group(1)"/>
															</xsl:matching-substring>
														</xsl:analyze-string>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:variable>
											<xsl:value-of select="concat($other_field, ':', encode-for-uri($other_value))"/>
											<xsl:if test="position() != last()">
												<xsl:text> OR </xsl:text>
											</xsl:if>
										</xsl:for-each>
									</xsl:variable>
									<xsl:variable name="multicategory_query">
										<xsl:choose>
											<xsl:when test="contains($new_multicategory, ' OR ')">
												<xsl:value-of select="concat('(', $new_multicategory, ')')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$new_multicategory"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>

									<!-- establish orientation based on language parameter -->
									<xsl:choose>
										<xsl:when test="$lang='ar'">
											<xsl:text>[</xsl:text>
											<!-- concatenate the query with the multicategory removed with the new multicategory, or if the multicategory is empty, display just the $new_query -->
											<a
												href="{$display_path}results?q={if (string($multicategory_query) and string($new_query)) then concat($new_query, ' AND ', $multicategory_query) else if (string($multicategory_query) and not(string($new_query))) then $multicategory_query else $new_query}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}"
												>X</a>
											<xsl:text>]</xsl:text>											
											
											<xsl:choose>
												<xsl:when test="$field='century_num'">
													<xsl:value-of select="numishare:normalize_century($value)"/>
												</xsl:when>
												<xsl:when test="contains($field, '_hier')">
													<xsl:variable name="tokens" select="tokenize(substring($value, 2, string-length($value)-2), '\+')"/>
													<xsl:for-each select="$tokens[position() &gt; 1]">
														<xsl:sort/>
														<xsl:value-of select="normalize-space(replace(substring-after(., '|'), '&#x022;', ''))"/>
														<xsl:if test="not(position()=last())">
															<xsl:text>--</xsl:text>
														</xsl:if>
													</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="$value"/>
												</xsl:otherwise>
											</xsl:choose>
											
											<b>
												<xsl:text>: </xsl:text>
												<xsl:value-of select="numishare:normalize_fields($field, $lang)"/>
											</b>
										</xsl:when>
										<xsl:otherwise>
											<!-- display either the term or the regularized name for the century -->
											<b>
												<xsl:value-of select="numishare:normalize_fields($field, $lang)"/>
												<xsl:text>: </xsl:text>
											</b>
											
											<xsl:choose>
												<xsl:when test="$field='century_num'">
													<xsl:value-of select="numishare:normalize_century($value)"/>
												</xsl:when>
												<xsl:when test="contains($field, '_hier')">
													<xsl:variable name="tokens" select="tokenize(substring($value, 2, string-length($value)-2), '\+')"/>
													<xsl:for-each select="$tokens[position() &gt; 1]">
														<xsl:sort/>
														<xsl:value-of select="normalize-space(replace(substring-after(., '|'), '&#x022;', ''))"/>
														<xsl:if test="not(position()=last())">
															<xsl:text>--</xsl:text>
														</xsl:if>
													</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="$value"/>
												</xsl:otherwise>
											</xsl:choose>

											<xsl:text>[</xsl:text>
											<!-- concatenate the query with the multicategory removed with the new multicategory, or if the multicategory is empty, display just the $new_query -->
											<a
												href="{$display_path}results?q={if (string($multicategory_query) and string($new_query)) then concat($new_query, ' AND ', $multicategory_query) else if (string($multicategory_query) and not(string($new_query))) then $multicategory_query else $new_query}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}"
												>X</a>
											<xsl:text>]</xsl:text>
											<xsl:if test="position() != last()">
												<xsl:text> OR </xsl:text>
											</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</span>
							<xsl:if test="not($lang='ar')">
								<a class="ui-icon ui-icon-closethick remove_filter"
									href="{$display_path}results?q={if (string($new_query)) then encode-for-uri($new_query) else '*:*'}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}"
									>X</a>
							</xsl:if>
						</div>
					</xsl:when>
					<xsl:when test="not(contains(., ':'))">
						<div class="stacked_term">
							<xsl:if test="$lang='ar'">
								<xsl:attribute name="style">text-align:right</xsl:attribute>
							</xsl:if>
							<span>
								<xsl:choose>
									<xsl:when test="$lang='ar'">
										<xsl:value-of select="."/>
										<b>
											<xsl:text> :</xsl:text>
											<xsl:value-of select="numishare:normalize_fields('fulltext', $lang)"/>
										</b>
									</xsl:when>
									<xsl:otherwise>
										<b><xsl:value-of select="numishare:normalize_fields('fulltext', $lang)"/>: </b>
										<xsl:value-of select="."/>
									</xsl:otherwise>
								</xsl:choose>
							</span>
						</div>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
			
			<!-- remove sort term -->
			<xsl:if test="string($sort)">
				<xsl:variable name="field" select="substring-before($sort, ' ')"/>
				<xsl:variable name="name">
					<xsl:value-of select="numishare:normalize_fields($field, $lang)"/>
				</xsl:variable>

				<xsl:variable name="order">
					<xsl:choose>
						<xsl:when test="substring-after($sort, ' ') = 'asc'">
							<xsl:value-of select="numishare:normalizeLabel('results_ascending', $lang)"/>
						</xsl:when>
						<xsl:when test="substring-after($sort, ' ') = 'desc'">
							<xsl:value-of select="numishare:normalizeLabel('results_descending', $lang)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<div class="ui-widget ui-state-default ui-corner-all stacked_term">
					<xsl:if test="$lang='ar'">
						<xsl:attribute name="style">text-align:right</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="$lang='ar'">
							<a class="ui-icon ui-icon-closethick remove_filter" href="?q={$q}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">X</a>
							<span>
								<xsl:value-of select="$order"/>
								<xsl:text>, </xsl:text>
								<xsl:value-of select="$name"/>
								<b>
									<xsl:text> :</xsl:text>
									<xsl:value-of select="numishare:normalizeLabel('results_sort-category', $lang)"/>
								</b>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<span>
								<b><xsl:value-of select="numishare:normalizeLabel('results_sort-category', $lang)"/>: </b>
								<xsl:value-of select="$name"/>
								<xsl:text>, </xsl:text>
								<xsl:value-of select="$order"/>
							</span>
							<a class="ui-icon ui-icon-closethick remove_filter" href="?q={$q}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">X</a>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:if>
			<xsl:if test="string($tokenized_q[3])">
				<div class="ui-widget ui-state-default ui-corner-all stacked_term">
					<xsl:if test="$lang='ar'">
						<xsl:attribute name="style">text-align:right</xsl:attribute>
					</xsl:if>
					<a id="clear_all" href="?q=*:*">
						<xsl:value-of select="numishare:normalizeLabel('results_clear-all', $lang)"/>
					</a>
				</div>
			</xsl:if>
		</div>

	</xsl:template>

	<xsl:template name="paging">
		<xsl:variable name="start_var" as="xs:integer">
			<xsl:choose>
				<xsl:when test="string($start)">
					<xsl:value-of select="$start"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="next">
			<xsl:value-of select="$start_var+$rows"/>
		</xsl:variable>

		<xsl:variable name="previous">
			<xsl:choose>
				<xsl:when test="$start_var &gt;= $rows">
					<xsl:value-of select="$start_var - $rows"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="current" select="$start_var div $rows + 1"/>
		<xsl:variable name="total" select="ceiling($numFound div $rows)"/>

		<div class="paging_div">
			<div style="float:left;">
				<xsl:variable name="startRecord" select="$start_var + 1"/>
				<xsl:variable name="endRecord">
					<xsl:choose>
						<xsl:when test="$numFound &gt; ($start_var + $rows)">
							<xsl:value-of select="$start_var + $rows"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$numFound"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:value-of select="replace(replace(replace(numishare:normalizeLabel('results_result-desc', $lang), 'XX', string($startRecord)), 'YY', string($endRecord)), 'ZZ', string($numFound))"
				/>
			</div>

			<!-- paging functionality -->
			<div style="float:right;">
				<ul class="ui-widget ui-helper-clearfix paging">
					<xsl:choose>
						<xsl:when test="$start_var &gt;= $rows">
							<li class="ui-state-default ui-corner-all">
								<a class="pagingBtn"
									href="?q={encode-for-uri($q)}&amp;start={$previous}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}"
									>«</a>
							</li>

						</xsl:when>
						<xsl:otherwise>
							<li class="ui-state-default ui-corner-all">«</li>
						</xsl:otherwise>
					</xsl:choose>

					<!-- always display links to the first two pages -->
					<xsl:if test="$start_var div $rows &gt;= 3">
						<li class="ui-state-default ui-corner-all">
							<a class="pagingBtn"
								href="?q={encode-for-uri($q)}&amp;start=0{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
								<xsl:text>1</xsl:text>
							</a>
						</li>

					</xsl:if>
					<xsl:if test="$start_var div $rows &gt;= 4">
						<li class="ui-state-default ui-corner-all">
							<a class="pagingBtn"
								href="?q={encode-for-uri($q)}&amp;start={$rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
								<xsl:text>2</xsl:text>
							</a>
						</li>

					</xsl:if>

					<!-- display only if you are on page 6 or greater -->
					<xsl:if test="$start_var div $rows &gt;= 5">
						<li class="ui-state-default ui-corner-all">...</li>
					</xsl:if>

					<!-- always display links to the previous two pages -->
					<xsl:if test="$start_var div $rows &gt;= 2">
						<li class="ui-state-default ui-corner-all">
							<a class="pagingBtn"
								href="?q={encode-for-uri($q)}&amp;start={$start_var - ($rows * 2)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
								<xsl:value-of select="($start_var div $rows) -1"/>
							</a>
						</li>
					</xsl:if>
					<xsl:if test="$start_var div $rows &gt;= 1">
						<li class="ui-state-default ui-corner-all">
							<a class="pagingBtn"
								href="?q={encode-for-uri($q)}&amp;start={$start_var - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
								<xsl:value-of select="$start_var div $rows"/>
							</a>
						</li>
					</xsl:if>

					<li class="ui-state-default ui-corner-all">
						<b>
							<xsl:value-of select="$current"/>
						</b>
					</li>

					<!-- next two pages -->
					<xsl:if test="($start_var div $rows) + 1 &lt; $total">
						<li class="ui-state-default ui-corner-all">
							<a class="pagingBtn"
								href="?q={encode-for-uri($q)}&amp;start={$start_var + $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
								<xsl:value-of select="($start_var div $rows) +2"/>
							</a>
						</li>
					</xsl:if>
					<xsl:if test="($start_var div $rows) + 2 &lt; $total">
						<li class="ui-state-default ui-corner-all">
							<a class="pagingBtn"
								href="?q={encode-for-uri($q)}&amp;start={$start_var + ($rows * 2)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
								<xsl:value-of select="($start_var div $rows) +3"/>
							</a>
						</li>
					</xsl:if>
					<xsl:if test="$start_var div $rows &lt;= $total - 6">
						<li class="ui-state-default ui-corner-all">...</li>
					</xsl:if>

					<!-- last two pages -->
					<xsl:if test="$start_var div $rows &lt;= $total - 5">
						<li class="ui-state-default ui-corner-all">
							<a class="pagingBtn"
								href="?q={encode-for-uri($q)}&amp;start={($total * $rows) - ($rows * 2)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
								<xsl:value-of select="$total - 1"/>
							</a>
						</li>
					</xsl:if>
					<xsl:if test="$start_var div $rows &lt;= $total - 4">
						<li class="ui-state-default ui-corner-all">
							<a class="pagingBtn"
								href="?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
								<xsl:value-of select="$total"/>
							</a>
						</li>
					</xsl:if>

					<xsl:choose>
						<xsl:when test="$numFound - $start_var &gt; $rows">
							<li class="ui-state-default ui-corner-all">
								<a class="pagingBtn"
									href="?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}"
									>»</a>
							</li>
						</xsl:when>
						<xsl:otherwise>
							<li class="ui-state-default ui-corner-all">»</li>
						</xsl:otherwise>
					</xsl:choose>
				</ul>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="sort">
		<xsl:variable name="sort_categories_string">
			<xsl:text>authority,axis_num,dob,timestamp,degree,deity,denomination,department,diameter_num,dynasty,findspot,issuer,manufacture,material,mint,obv_leg_display,portrait,region,rev_leg_display,weight_num,year</xsl:text>
		</xsl:variable>
		<xsl:variable name="sort_categories" select="tokenize(normalize-space($sort_categories_string), ',')"/>

		<div class="sort_div">
			<form class="sortForm" action="results">
				<select class="sortForm_categories">
					<option value="null">
						<xsl:value-of select="numishare:normalizeLabel('results_select', $lang)"/>
					</option>
					<xsl:for-each select="$sort_categories">
						<xsl:choose>
							<xsl:when test="contains($sort, .)">
								<option value="{.}" selected="selected">
									<xsl:value-of select="numishare:normalize_fields(., $lang)"/>
								</option>
							</xsl:when>
							<xsl:otherwise>
								<option value="{.}">
									<xsl:value-of select="numishare:normalize_fields(., $lang)"/>
								</option>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</select>
				<select class="sortForm_order">
					<xsl:choose>
						<xsl:when test="contains($sort, 'asc')">
							<option value="asc" selected="selected">
								<xsl:value-of select="numishare:normalizeLabel('results_ascending', $lang)"/>
							</option>
						</xsl:when>
						<xsl:otherwise>
							<option value="asc">
								<xsl:value-of select="numishare:normalizeLabel('results_ascending', $lang)"/>
							</option>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="contains($sort, 'desc')">
							<option value="desc" selected="selected">
								<xsl:value-of select="numishare:normalizeLabel('results_descending', $lang)"/>
							</option>
						</xsl:when>
						<xsl:otherwise>
							<option value="desc">
								<xsl:value-of select="numishare:normalizeLabel('results_descending', $lang)"/>
							</option>
						</xsl:otherwise>
					</xsl:choose>
				</select>
				<input type="hidden" name="q" value="{$q}"/>
				<input type="hidden" name="sort" value="" class="sort_param"/>
				<xsl:if test="string($lang)">
					<input type="hidden" name="lang" value="{$lang}"/>
				</xsl:if>
				<input id="sort_button" type="submit" value="{numishare:normalizeLabel('results_sort-results', $lang)}"/>
			</form>
		</div>
	</xsl:template>

	<xsl:template name="quick_search">
		<div class="quick_search">
			<h3>
				<xsl:value-of select="numishare:normalizeLabel('results_quick-search', $lang)"/>
			</h3>
			<form action="results" method="GET" id="qs_form">
				<input type="text" id="qs_text"/>
				<input type="hidden" name="q" id="qs_query" value="{$q}"/>
				<xsl:if test="string($lang)">
					<input type="hidden" name="lang" value="{$lang}"/>
				</xsl:if>
				<input id="qs_button" type="submit" value="{numishare:normalizeLabel('header_search', $lang)}"/>
			</form>
		</div>
	</xsl:template>

	<xsl:template name="render_categories">
		<xsl:param name="category_fragment"/>

		<xsl:variable name="new_query">
			<xsl:for-each select="$tokenized_q[not(. = $category_fragment)]">
				<xsl:value-of select="."/>
				<xsl:if test="position() != last()">
					<xsl:text> AND </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<div class="stacked_term">
			<span class="term">
				<b>Category: </b>
				<xsl:call-template name="recompile_category">
					<xsl:with-param name="category_fragment" select="$category_fragment"/>
					<xsl:with-param name="tokenized_fragment" select="tokenize(substring-after(replace(replace(replace($category_fragment, '\)', ''), '\(', ''), '\+', ''), 'category_facet:'), ' ')"/>
					<xsl:with-param name="level" as="xs:integer">1</xsl:with-param>
				</xsl:call-template>
			</span>
			<a class="remove_filter" href="?q={if (string($new_query)) then encode-for-uri($new_query) else '*:*'}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">X</a>

		</div>
	</xsl:template>

	<xsl:template name="compare_paging">
		<xsl:variable name="start_var" as="xs:integer">
			<xsl:choose>
				<xsl:when test="string($start)">
					<xsl:value-of select="$start"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="next">
			<xsl:value-of select="$start_var+$rows"/>
		</xsl:variable>

		<xsl:variable name="previous">
			<xsl:choose>
				<xsl:when test="$start_var &gt;= $rows">
					<xsl:value-of select="$start_var - $rows"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="current" select="$start_var div $rows + 1"/>
		<xsl:variable name="total" select="ceiling($numFound div $rows)"/>

		<div style="width:100%;display:table;">
			<div style="float:left;">
				<xsl:variable name="startRecord" select="$start_var + 1"/>
				<xsl:variable name="endRecord">
					<xsl:choose>
						<xsl:when test="$numFound &gt; ($start_var + $rows)">
							<xsl:value-of select="$start_var + $rows"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$numFound"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:value-of select="replace(replace(replace(numishare:normalizeLabel('results_result-desc', $lang), 'XX', string($startRecord)), 'YY', string($endRecord)), 'ZZ', string($numFound))"
				/>
			</div>
			<div style="float:right;">
				<xsl:choose>
					<xsl:when test="$start_var &gt;= $rows">
						<a class="comparepagingBtn" href="compare_results?q={$q}&amp;start={$previous}&amp;image={$image}&amp;side={$side}&amp;mode=compare">« Previous</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>« Previous</xsl:text>
					</xsl:otherwise>
				</xsl:choose> | <xsl:choose>
					<xsl:when test="$numFound - $start_var &gt; $rows">
						<a class="comparepagingBtn" href="compare_results?q={$q}&amp;start={$next}&amp;image={$image}&amp;side={$side}&amp;mode=compare">Next »</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Next »</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
