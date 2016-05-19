<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all" version="2.0">
	<xsl:template match="doc">
		<xsl:variable name="sort_category" select="substring-before($sort, ' ')"/>
		<xsl:variable name="regularized_sort">
			<xsl:value-of select="numishare:normalize_fields($sort_category, $lang)"/>
		</xsl:variable>
		<div class="row result-doc">			
			<div class="col-md-12">
				<h4>
					<xsl:if test="$lang='ar'">
						<xsl:attribute name="style">direction: ltr; text-align:right</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="$mode = 'compare'">
							<a href="{$display_path}id/{str[@name='recordId']}?mode=compare&amp;q={$q}&amp;start={$start}&amp;image={$image}&amp;side={$side}{if (string($langParam)) then
								concat('&amp;lang=', $langParam) else ''}" class="compare">
								<xsl:value-of select="str[@name='title_display']"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a href="{$display_path}id/{str[@name='recordId']}{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
								<xsl:value-of select="str[@name='title_display']"/>
							</a>
							<xsl:if test="$authenticated = true()">
								<xsl:variable name="adminURL" select="concat(doc('input:request')/request/scheme, '://', doc('input:request')/request/server-name, ':8080/orbeon/numishare/admin/')"/>
								<small>
									<a href="{$adminURL}edit/coin/?id={str[@name='recordId']}" title="Edit Record" style="margin-left:5px">
										<span class="glyphicon glyphicon-pencil"/>
									</a>
								</small>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</h4>
			</div>
			<xsl:if test="not($mode='compare')">
				<xsl:call-template name="result_image">
					<xsl:with-param name="alignment" select="//config/theme/layouts/*[name()=$pipeline]/image_location"></xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<div>
				<xsl:choose>
					<xsl:when test="$mode='compare'">
						<xsl:attribute name="class">col-md-12</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="class">col-md-7 col-lg-8</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
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
				<dl class=" {if($lang='ar') then 'dl-horizontal ar' else 'dl-horizontal'}">
					<xsl:choose>
						<xsl:when test="str[@name='recordType'] = 'hoard'">
							<xsl:if test="string(str[@name='findspot_display'])">
								<dt>
									<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
								</dt>
								<dd>
									<xsl:value-of select="str[@name='findspot_display']"/>
								</dd>
							</xsl:if>
							<dt>
								<xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/>
							</dt>
							<dd>
								<xsl:value-of select="str[@name='closing_date_display']"/>
							</dd>
							<xsl:if test="string(str[@name='description_display'])">
								<dt>
									<xsl:value-of select="numishare:regularize_node('description', $lang)"/>
								</dt>
								<dd>
									<xsl:value-of select="str[@name='description_display']"/>
								</dd>
							</xsl:if>
							<xsl:if test="arr[@name='reference_facet']">
								<dt>
									<xsl:value-of select="numishare:regularize_node('reference', $lang)"/>
								</dt>
								<dd>

									<xsl:for-each select="arr[@name='reference_facet']/str">
										<xsl:value-of select="."/>
										<xsl:if test="not(position() = last())">
											<xsl:text>, </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</dd>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="string(str[@name='date_display'])">
								<dt>
									<xsl:value-of select="numishare:regularize_node('date', $lang)"/>
								</dt>
								<dd>
									<xsl:value-of select="str[@name='date_display']"/>
								</dd>
							</xsl:if>
							<xsl:if test="string(arr[@name='denomination_facet']/str[1])">
								<dt>
									<xsl:value-of select="numishare:regularize_node('denomination', $lang)"/>
								</dt>
								<dd>
									<xsl:for-each select="arr[@name='denomination_facet']/str">
										<xsl:value-of select="."/>
										<xsl:if test="not(position() = last())">
											<xsl:text>, </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</dd>
							</xsl:if>
							<xsl:if test="string(arr[@name='mint_facet']/str[1])">
								<dt>
									<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
								</dt>
								<dd>
									<xsl:for-each select="arr[@name='mint_facet']/str">
										<xsl:value-of select="."/>
										<xsl:if test="not(position() = last())">
											<xsl:text>, </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</dd>
							</xsl:if>
							<xsl:if test="str[@name='obv_leg_display'] or str[@name='obv_type_display']">
								<dt>
									<xsl:value-of select="numishare:regularize_node('obverse', $lang)"/>
								</dt>
								<dd>
									<xsl:choose>
										<xsl:when test="$lang='ar'">
											<xsl:value-of select="str[@name='obv_type_display']"/>
											<xsl:if test="str[@name='obv_leg_display'] and str[@name='obv_type_display']">
												<xsl:text> :</xsl:text>
											</xsl:if>
											<xsl:value-of select="str[@name='obv_leg_display']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="str[@name='obv_leg_display']"/>
											<xsl:if test="str[@name='obv_leg_display'] and str[@name='obv_type_display']">
												<xsl:text>: </xsl:text>
											</xsl:if>
											<xsl:value-of select="str[@name='obv_type_display']"/>
										</xsl:otherwise>
									</xsl:choose>
								</dd>
							</xsl:if>
							<xsl:if test="str[@name='rev_leg_display'] or str[@name='rev_type_display']">
								<dt>
									<xsl:value-of select="numishare:regularize_node('reverse', $lang)"/>
								</dt>
								<dd>
									<xsl:choose>
										<xsl:when test="$lang='ar'">
											<xsl:value-of select="str[@name='rev_type_display']"/>
											<xsl:if test="str[@name='rev_leg_display'] and str[@name='rev_type_display']">
												<xsl:text> :</xsl:text>
											</xsl:if>
											<xsl:value-of select="str[@name='rev_leg_display']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="str[@name='rev_leg_display']"/>
											<xsl:if test="str[@name='rev_leg_display'] and str[@name='rev_type_display']">
												<xsl:text>: </xsl:text>
											</xsl:if>
											<xsl:value-of select="str[@name='rev_type_display']"/>
										</xsl:otherwise>
									</xsl:choose>
								</dd>
							</xsl:if>
							<xsl:if test="float[@name='diameter_num']">
								<dt>
									<xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>
								</dt>
								<dd>
									<xsl:value-of select="float[@name='diameter_num']"/>
								</dd>
							</xsl:if>
							<xsl:if test="float[@name='weight_num']">
								<dt>
									<xsl:value-of select="numishare:regularize_node('weight', $lang)"/>
								</dt>
								<dd>
									<xsl:value-of select="float[@name='weight_num']"/>
								</dd>
							</xsl:if>
							<xsl:if test="arr[@name='reference_facet']">
								<dt>
									<xsl:value-of select="numishare:regularize_node('reference', $lang)"/>
								</dt>
								<dd>
									<xsl:for-each select="arr[@name='reference_facet']/str">
										<xsl:value-of select="."/>
										<xsl:if test="not(position() = last())">
											<xsl:text>, </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</dd>
							</xsl:if>
							<xsl:if test="arr[@name='provenance_facet']">
								<dt>
									<xsl:value-of select="numishare:regularize_node('provenance', $lang)"/>
								</dt>
								<dd>
									<xsl:for-each select="arr[@name='provenance_facet']/str">
										<xsl:value-of select="."/>
										<xsl:if test="not(position() = last())">
											<xsl:text>, </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</dd>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
					<!-- display appropriate sort category if it isn't one of the default display fields -->
					<xsl:if test="string($sort) and not(contains($sort_category, 'year')) and not(contains($sort_category, 'department_facet')) and not(contains($sort_category, 'weight_num')) and
						not(contains($sort_category, 'dimensions_display'))">
						<xsl:choose>
							<xsl:when test="contains($sort, '_num')">
								<dt>
									<xsl:value-of select="$regularized_sort"/>
								</dt>
								<dd>
									<xsl:for-each select="distinct-values(*[@name=$sort_category])">
										<xsl:sort order="descending"/>
										<xsl:value-of select="."/>
										<xsl:if test="not(position() = last())">
											<xsl:text>, </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</dd>
							</xsl:when>
							<xsl:when test="contains($sort, 'timestamp')">
								<dt>
									<xsl:value-of select="$regularized_sort"/>
								</dt>
								<dd>
									<xsl:value-of select="date[@name='timestamp']"/>
								</dd>
							</xsl:when>
							<xsl:when test="contains($sort, '_facet') or contains($sort, 'reference_facet') or contains($sort, 'provenance_display')">
								<xsl:choose>
									<xsl:when test="matches($sort, 'objectType_facet')">
										<dt>
											<xsl:value-of select="numishare:regularize_node('objectType', $lang)"/>
										</dt>
										<dd>
											<xsl:value-of select="str[@name='objectType_facet']"/>
										</dd>
									</xsl:when>
									<xsl:otherwise>
										<xsl:if test="arr[@name=$sort_category]/str">
											<dt>
												<xsl:value-of select="$regularized_sort"/>
											</dt>
											<dd>
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
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="str[@name=$sort_category]">
									<dt>
										<xsl:value-of select="$regularized_sort"/>
									</dt>
									<dd>
										<xsl:value-of select="substring(str[@name=$sort_category], 1, 25)"/>
										<xsl:if test="string-length(str[@name=$sort_category]) &gt; 25">
											<xsl:text>...</xsl:text>
										</xsl:if>
									</dd>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</dl>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="lst[@name='facet_fields']">
		<!-- ignore mint_geo-->
		<xsl:choose>
			<xsl:when test="$collection_type = 'hoard'">
				<h4><xsl:value-of select="numishare:normalize_fields('hoard', $lang)"/></h4>
				<xsl:apply-templates select="lst[(@name='taq_num' or @name='findspot_hier' or @name='reference_facet') and number(int) &gt; 0]" mode="facet"/>
				<h4><xsl:value-of select="numishare:normalize_fields('contents', $lang)"/></h4>
				<xsl:apply-templates select="lst[(@name='authority_facet'or @name='coinType_facet' or @name='deity_facet' or @name='denomination_facet' or @name='issuer_facet' or
					@name='manufacture_facet' or @name='material_facet' or @name='mint_facet' or @name='objectType_facet' or @name='portrait_facet' or @name='region_facet') and      number(int) &gt;
					0]" mode="facet"/>
			</xsl:when>
			<xsl:when test="$collection_type='cointype'">
				<xsl:apply-templates select="lst[not(contains(@name, '_geo')) and not(contains(@name, 'symbol_')) and number(int) &gt; 0]" mode="facet"/>
				<xsl:if test="lst[contains(@name, 'symbol_')]">
					<h4>
						<xsl:value-of select="numishare:normalize_fields('symbol', $lang)"/>
						<small>
							<a href="#" id="toggle-symbols" title="Hide/Show Symbol Facets"><span class="glyphicon glyphicon-{if(contains($q, 'symbol_')) then 'triangle-bottom' else 'triangle-right'}"/></a>
						</small>
					</h4>
					<div id="symbol-container">
						<xsl:if test="not(contains($q, 'symbol_'))">
							<xsl:attribute name="style">display:none</xsl:attribute>
						</xsl:if>
						<xsl:if test="lst[contains(@name, 'symbol_obv_') and number(int) &gt; 0]">
							<h5><xsl:value-of select="numishare:normalize_fields('obverse', $lang)"/></h5>
							<xsl:apply-templates select="lst[contains(@name, 'symbol_obv') and number(int) &gt; 0]" mode="facet"/>
						</xsl:if>
						<xsl:if test="lst[contains(@name, 'symbol_rev_') and number(int) &gt; 0]">
							<h5><xsl:value-of select="numishare:normalize_fields('reverse', $lang)"/></h5>
							<xsl:apply-templates select="lst[contains(@name, 'symbol_rev') and number(int) &gt; 0]" mode="facet"/>
						</xsl:if>	
					</div>				
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="lst[not(contains(@name, '_geo')) and not(contains(@name, 'symbol_')) and number(int) &gt; 0]" mode="facet"/>
			</xsl:otherwise>
		</xsl:choose>
		<form action="results" method="GET" role="form" id="facet_form">
			<xsl:variable name="imageavailable_stripped">
				<xsl:for-each select="$tokenized_q[not(contains(., 'imagesavailable'))]">
					<xsl:value-of select="."/>
					<xsl:if test="position() != last()">
						<xsl:text> AND </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<!-- coin type number -->
			<xsl:if test="$collection_type = 'cointype'">
				<h4>
					<xsl:value-of select="numishare:normalize_fields('typeNumber', $lang)"/>
				</h4>
				<p><a href="https://lucene.apache.org/core/2_9_4/queryparsersyntax.html#Wildcard%20Searches">Wildcards</a><xsl:text> </xsl:text><b>*</b> and <b>?</b> are supported.</p>
				<input type="text" id="typeNumber" class="form-control">
					<xsl:if test="$tokenized_q[contains(., 'typeNumber')]">
						<xsl:attribute name="value" select="substring-after($tokenized_q[contains(., 'typeNumber')][1], ':')"/>
					</xsl:if>
				</input>
			</xsl:if>

			<!-- date ranges -->
			<h4>
				<xsl:choose>
					<xsl:when test="$collection_type='hoard'">
						<xsl:value-of select="numishare:normalize_fields('closing_date', $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="numishare:normalize_fields('dateRange', $lang)"/>
					</xsl:otherwise>
				</xsl:choose>
			</h4>

			<!-- if AH date range searching is enabled, then display that form first -->
			<xsl:if test="/content/config/ah_enabled='true'">
				<div class="form-group" id="ah_dateRange">
					<span>AH </span>
					<input type="text" id="ah_fromDate" class="form-control" placeholder="{numishare:normalize_fields('fromDate', $lang)}"/>
					<span> - </span>
					<input type="text" id="ah_toDate" class="form-control" placeholder="{numishare:normalize_fields('toDate', $lang)}"/>
				</div>
			</xsl:if>

			<div class="form-group">
				<div>
					<label>
						<xsl:value-of select="numishare:normalize_fields('fromDate', $lang)"/>
					</label>
				</div>
				<input type="text" id="from_date" class="form-control"/>
				<select id="from_era" class="form-control">
					<option value="minus">B.C.</option>
					<option value="" selected="selected">A.D.</option>
				</select>
			</div>
			<div class="form-group">
				<div>
					<label>
						<xsl:value-of select="numishare:normalize_fields('toDate', $lang)"/>
					</label>
				</div>
				<input type="text" id="to_date" class="form-control"/>
				<select id="to_era" class="form-control">
					<option value="minus">B.C.</option>
					<option value="" selected="selected">A.D.</option>
				</select>
			</div>

			<!-- hidden params -->
			<input type="hidden" name="q" id="facet_form_query" value="{if (string($imageavailable_stripped)) then $imageavailable_stripped else '*:*'}"/>
			<xsl:if test="string($langParam)">
				<input type="hidden" name="lang" value="{$lang}"/>
			</xsl:if>
			<br/>
			<xsl:if test="$collection_type = 'object'">
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
			<input type="submit" value="{numishare:normalizeLabel('results_refine-search', $lang)}" id="search_button" class="btn btn-default"/>
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

				<div class="btn-group">
					<button class="dropdown-toggle btn btn-default hierarchical-facet" type="button" style="width:250px;margin-bottom:10px;" title="{$title}" id="{@name}-btn" label="{$q}">
						<span>
							<xsl:value-of select="$title"/>
						</span>
						<xsl:text> </xsl:text>
						<b class="caret"/>
					</button>
					<ul class="dropdown-menu hier-list" id="{@name}-list">
						<div class="text-right">
							<a href="#" class="hier-close">close <span class="glyphicon glyphicon-remove"/></a>
						</div>
						<xsl:if test="contains($q, @name)">
							<xsl:copy-of select="document(concat($request-uri, 'get_hier?q=', encode-for-uri($q), '&amp;fq=*&amp;prefix=L1&amp;link=&amp;field=', substring-before(@name,
								'_hier')))//ul[@id='root']/li"/>
						</xsl:if>
					</ul>
				</div>
			</xsl:when>
			<xsl:when test="@name='century_num'">
				<div class="btn-group">
					<button class="dropdown-toggle btn btn-default" type="button" style="width:250px;margin-bottom:10px;" title="{numishare:regularize_node('date', $lang)}" id="{@name}_link"
						label="{$q}">
						<xsl:value-of select="numishare:regularize_node('date', $lang)"/>
						<xsl:text> </xsl:text>
						<b class="caret"/>
					</button>
					<ul class="dropdown-menu" id="{@name}-list">
						<div class="text-right">
							<a href="#" class="century-close">close <span class="glyphicon glyphicon-remove"/></a>
						</div>
						<xsl:if test="contains($q, @name)">
							<xsl:copy-of select="document(concat($request-uri, 'get_centuries?q=', encode-for-uri($q)))//ul[@id='root']/li"/>
						</xsl:if>
					</ul>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="title">
					<xsl:choose>
						<xsl:when test="contains(@name, 'symbol_')">
							<xsl:variable name="position" select="tokenize(@name, '_')[3]"/>
							<xsl:variable name="langParam" select="if(string($lang)) then $lang else 'en'"/>
							
							<xsl:choose>
								<xsl:when test="$positions//position[@value=$position]/label[@lang=$langParam]">
									<xsl:value-of select="$positions//position[@value=$position]/label[@lang=$langParam]"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat(upper-case(substring($position, 1, 1)), substring($position, 2))"/>
								</xsl:otherwise>
							</xsl:choose>
							
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="numishare:normalize_fields(@name, $lang)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="mincount" as="xs:integer">
					<xsl:choose>
						<xsl:when test="$numFound &gt; 200000">
							<xsl:value-of select="ceiling($numFound div 200000)"/>
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
				<select id="{@name}-select" multiple="multiple" class="multiselect {@name}-button" title="{$title}" q="{$q}" mincount="{$mincount}" new_query="{if
					(contains($q, @name)) then $select_new_query else ''}">
					<xsl:if test="contains($q, @name)">
						<xsl:copy-of select="document(concat($request-uri, 'get_facet_options?q=', encode-for-uri($q), '&amp;category=', @name, '&amp;pipeline=', $pipeline, '&amp;lang=', $lang,
							'&amp;mincount=', $mincount))//option"/>
					</xsl:if>
				</select>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="lst[@name='mint_geo']" mode="facet"/>

	<xsl:template name="result_image">
		<xsl:param name="alignment"/>
		<div class="col-md-5 col-lg-4 {if ($alignment = 'right') then 'pull-right' else ''}">
			<xsl:choose>
				<xsl:when test="str[@name='recordType'] = 'physical'">
					<xsl:if test="string(str[@name='thumbnail_obv'])">
						<a class="thumbImage" href="{str[@name='reference_obv']}" title="Obverse of {str[@name='title_display']}" id="{$display_path}id/{str[@name='recordId']}{if (string($langParam)) then
							concat('?lang=', $langParam) else ''}">
							<img src="{str[@name='thumbnail_obv']}"/>
						</a>
					</xsl:if>
					<xsl:if test="string(str[@name='thumbnail_rev'])">
						<a class="thumbImage" href="{str[@name='reference_rev']}" title="Reverse of {str[@name='title_display']}" id="{$display_path}id/{str[@name='recordId']}{if (string($langParam)) then
							concat('?lang=', $langParam) else ''}">
							<img src="{str[@name='thumbnail_rev']}"/>
						</a>
					</xsl:if>
				</xsl:when>
				<xsl:when test="str[@name='recordType'] = 'conceptual'">
					<xsl:variable name="id" select="str[@name='recordId']"/>
					<xsl:apply-templates select="$sparqlResult//group[@id=$id]" mode="results"/>
				</xsl:when>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<xsl:template name="remove_facets">
		<div class="row">
			<xsl:choose>
				<xsl:when test="$q = '*:*' or not(string($q))">
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('results_all-terms', $lang)"/>
						<xsl:if test="count(//lst[@name='mint_geo']/int) &gt; 0 or count(//lst[@name='findspot_geo']/int) &gt; 0">
							<small>
								<a href="#resultMap" id="map_results">
									<xsl:value-of select="numishare:normalizeLabel('results_map-results', $lang)"/>
								</a>
							</small>
						</xsl:if>
					</h1>
				</xsl:when>
				<xsl:otherwise>
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('results_filters', $lang)"/>
						<xsl:if test="count(//lst[@name='mint_geo']/int) &gt; 0 or count(//lst[@name='findspot_geo']/int) &gt; 0">
							<small>
								<a href="#resultMap" id="map_results">
									<xsl:value-of select="numishare:normalizeLabel('results_map-results', $lang)"/>
								</a>
							</small>
						</xsl:if>
					</h1>
				</xsl:otherwise>
			</xsl:choose>
		</div>
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
			<xsl:variable name="params" as="node()*">
				<params>
					<xsl:if test="string($new_query)">
						<param>q=<xsl:value-of select="encode-for-uri($new_query)"/></param>
					</xsl:if>
					<xsl:if test="string($langParam)">
						<param>lang=<xsl:value-of select="$langParam"/></param>
					</xsl:if>
				</params>
			</xsl:variable>
			
			<xsl:choose>
				<xsl:when test="not(. = '*:*') and not(substring(., 1, 1) = '(')">
					<xsl:variable name="field" select="substring-before(., ':')"/>
					<xsl:variable name="name">
						<xsl:choose>
							<xsl:when test="string($field)">
								<xsl:choose>
									<xsl:when test="contains($field, 'symbol_')">
										<xsl:variable name="position" select="tokenize($field, '_')[3]"/>
										<xsl:variable name="langParam" select="if(string($lang)) then $lang else 'en'"/>
										
										<xsl:choose>
											<xsl:when test="$positions//position[@value=$position]/label[@lang=$langParam]">
												<xsl:value-of select="$positions//position[@value=$position]/label[@lang=$langParam]"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="concat(upper-case(substring($position, 1, 1)), substring($position, 2))"/>
											</xsl:otherwise>
										</xsl:choose>
										
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="numishare:normalize_fields($field, $lang)"/>
									</xsl:otherwise>
								</xsl:choose>								
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
					
					<div class="stacked_term bg-info row">
						<xsl:if test="$lang='ar'">							
							<div class="col-md-2 left">
								<a href="{$display_path}results{if (count($params//param) &gt; 0) then concat('?', string-join($params//param, '&amp;')) else ''}">
									<span class="glyphicon glyphicon-remove"/>
								</a>
							</div>
						</xsl:if>
						<!-- establish orientation based on language parameter -->
						<div class="col-md-10">
							<span>
								<b><xsl:value-of select="$name"/>: </b>
								<xsl:choose>
									<xsl:when test="$field='century_num'">
										<xsl:value-of select="numishare:normalize_century($term)"/>
									</xsl:when>
									<xsl:when test="contains($field, '_hier')">
										<xsl:variable name="tokens" select="tokenize(substring($term, 2, string-length($term)-2), '\+')"/>
										<xsl:for-each select="$tokens[position() &gt; 1]">
											<xsl:sort select="position()" order="descending"/>
											<xsl:value-of select="normalize-space(substring-after(substring-before(., '/'), '|'))"/>
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
						</div>
						<xsl:if test="not($lang='ar')">
							<div class="col-md-2 right">
								<a href="{$display_path}results{if (count($params//param) &gt; 0) then concat('?', string-join($params//param, '&amp;')) else ''}">
									<span class="glyphicon glyphicon-remove"/>
								</a>
							</div>
						</xsl:if>

					</div>
				</xsl:when>
				<!-- if the token contains a parenthisis, then it was probably sent from the search widget and the token must be broken down further to remove other facets -->
				<xsl:when test="substring(., 1, 1) = '('">
					<xsl:variable name="tokenized-fragments" select="tokenize(., ' OR ')"/>
					<div class="stacked_term bg-info row">
						<xsl:if test="$lang='ar'">
							<div class="col-md-2 left">
								<a href="{$display_path}results{if (count($params//param) &gt; 0) then concat('?', string-join($params//param, '&amp;')) else ''}">
									<span class="glyphicon glyphicon-remove"/>
								</a>
							</div>
						</xsl:if>
						<div class="col-md-10">
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
									<!-- display either the term or the regularized name for the century -->
									<b>
										<xsl:choose>
											<xsl:when test="contains($field, 'symbol_')">
												<xsl:variable name="position" select="tokenize($field, '_')[3]"/>
												<xsl:variable name="langParam" select="if(string($lang)) then $lang else 'en'"/>
												
												<xsl:choose>
													<xsl:when test="$positions//position[@value=$position]/label[@lang=$langParam]">
														<xsl:value-of select="$positions//position[@value=$position]/label[@lang=$langParam]"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="concat(upper-case(substring($position, 1, 1)), substring($position, 2))"/>
													</xsl:otherwise>
												</xsl:choose>
												
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="numishare:normalize_fields($field, $lang)"/>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:text>: </xsl:text>
									</b>
									<xsl:choose>
										<xsl:when test="$field='century_num'">
											<xsl:value-of select="numishare:normalize_century($value)"/>
										</xsl:when>
										<xsl:when test="contains($field, '_hier')">
											<xsl:variable name="tokens" select="tokenize(substring($value, 2, string-length($value)-2), '\+')"/>
											<xsl:for-each select="$tokens[position() &gt; 1]">
												<xsl:sort select="position()" order="descending"/>
												<xsl:value-of select="normalize-space(replace(substring-after(substring-before(., '/'), '|'), '&#x022;', ''))"/>
												<xsl:if test="not(position()=last())">
													<xsl:text>--</xsl:text>
												</xsl:if>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$value"/>
										</xsl:otherwise>
									</xsl:choose>
									<!-- concatenate the query with the multicategory removed with the new multicategory, or if the multicategory is empty, display just the $new_query -->
									<a href="{$display_path}results?q={if (string($multicategory_query) and string($new_query)) then concat($new_query, ' AND ', $multicategory_query) else if
										(string($multicategory_query) and not(string($new_query))) then $multicategory_query else $new_query}{if (string($lang)) then concat('&amp;lang=',
										$lang) else ''}">
										<span class="glyphicon glyphicon-remove"/>
									</a>
									<xsl:if test="position() != last()">
										<xsl:text> OR </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</span>
						</div>
						<xsl:if test="not($lang='ar')">
							<div class="col-md-2 right">
								<a href="{$display_path}results{if (count($params//param) &gt; 0) then concat('?', string-join($params//param, '&amp;')) else ''}">
									<span class="glyphicon glyphicon-remove"/>
								</a>
							</div>
						</xsl:if>
					</div>
				</xsl:when>
				<xsl:when test="not(contains(., ':'))">
					<div class="stacked_term bg-info row">
						<xsl:if test="$lang='ar'">
							<xsl:attribute name="style">text-align:right</xsl:attribute>
						</xsl:if>
						<div class="col-md-12">
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
			<div class="stacked_term bg-info row">
				<xsl:if test="$lang='ar'">
					<xsl:attribute name="style">text-align:right</xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$lang='ar'">
						<div class="col-md-2">
							<a href="{$display_path}results?q={$q}{if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}">
								<span class="glyphicon glyphicon-remove"/>
							</a>
						</div>
						<div class="col-md-10">
							<span>
								<xsl:value-of select="$order"/>
								<xsl:text>, </xsl:text>
								<xsl:value-of select="$name"/>
								<b>
									<xsl:text> :</xsl:text>
									<xsl:value-of select="numishare:normalizeLabel('results_sort-category', $lang)"/>
								</b>
							</span>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="col-md-10">
							<span>
								<b><xsl:value-of select="numishare:normalizeLabel('results_sort-category', $lang)"/>: </b>
								<xsl:value-of select="$name"/>
								<xsl:text>, </xsl:text>
								<xsl:value-of select="$order"/>
							</span>
						</div>
						<div class="col-md-2 right">
							<a href="{$display_path}results?q={$q}{if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}">
								<span class="glyphicon glyphicon-remove"/>
							</a>
						</div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:if>
		<xsl:if test="string($tokenized_q[3])">
			<div class="stacked_term bg-info row">
				<xsl:if test="$lang='ar'">
					<xsl:attribute name="style">text-align:right</xsl:attribute>
				</xsl:if>
				<div class="col-md-12">
					<a id="clear_all" href="{$display_path}results">
						<xsl:value-of select="numishare:normalizeLabel('results_clear-all', $lang)"/>
					</a>
				</div>
			</div>
		</xsl:if>
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
		<div class="paging_div row">
			<div class="col-md-6 {if ($lang='ar') then 'pull-right' else ''}">
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
				
				<xsl:value-of select="numishare:recordCount($lang, $startRecord, $endRecord, $numFound)"/>
			</div>
			<!-- paging functionality -->
			<div class="col-md-6 page-nos">
				<div class="btn-toolbar" role="toolbar">
					<div class="btn-group pagination {if (not($lang='ar')) then 'pull-right' else ''}">
						<xsl:choose>
							<xsl:when test="$lang='ar'">
								<xsl:choose>
									<xsl:when test="$numFound - $start_var &gt; $rows">
										<xsl:call-template name="last-button">
											<xsl:with-param name="class">pagingBtn</xsl:with-param>
											<xsl:with-param name="total" select="$total"/>
										</xsl:call-template>
										<xsl:call-template name="next-button">
											<xsl:with-param name="class">pagingBtn</xsl:with-param>
											<xsl:with-param name="next" select="$next"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="last-button">
											<xsl:with-param name="class">disabled</xsl:with-param>
											<xsl:with-param name="total" select="$total"/>
										</xsl:call-template>
										<xsl:call-template name="next-button">
											<xsl:with-param name="class">disabled</xsl:with-param>
											<xsl:with-param name="next" select="$next"/>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>

							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$start_var &gt;= $rows">
										<xsl:call-template name="first-button">
											<xsl:with-param name="class">pagingBtn</xsl:with-param>
										</xsl:call-template>
										<xsl:call-template name="prev-button">
											<xsl:with-param name="class">pagingBtn</xsl:with-param>
											<xsl:with-param name="previous" select="$previous"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="first-button">
											<xsl:with-param name="class">disabled</xsl:with-param>
										</xsl:call-template>
										<xsl:call-template name="prev-button">
											<xsl:with-param name="class">disabled</xsl:with-param>
											<xsl:with-param name="previous" select="$previous"/>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>


						<!-- current page -->
						<button type="button" class="btn btn-default active">
							<b>
								<xsl:value-of select="$current"/>
							</b>
						</button>
						<!-- next page -->
						<xsl:choose>
							<xsl:when test="$lang='ar'">
								<xsl:choose>
									<xsl:when test="$start_var &gt;= $rows">
										<xsl:call-template name="prev-button">
											<xsl:with-param name="class">pagingBtn</xsl:with-param>
											<xsl:with-param name="previous" select="$previous"/>
										</xsl:call-template>
										<xsl:call-template name="first-button">
											<xsl:with-param name="class">pagingBtn</xsl:with-param>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="prev-button">
											<xsl:with-param name="class">disabled</xsl:with-param>
											<xsl:with-param name="previous" select="$previous"/>
										</xsl:call-template>
										<xsl:call-template name="first-button">
											<xsl:with-param name="class">disabled</xsl:with-param>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$numFound - $start_var &gt; $rows">
										<xsl:call-template name="next-button">
											<xsl:with-param name="class">pagingBtn</xsl:with-param>
											<xsl:with-param name="next" select="$next"/>
										</xsl:call-template>
										<xsl:call-template name="last-button">
											<xsl:with-param name="class">pagingBtn</xsl:with-param>
											<xsl:with-param name="total" select="$total"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="next-button">
											<xsl:with-param name="class">disabled</xsl:with-param>
											<xsl:with-param name="next" select="$next"/>
										</xsl:call-template>
										<xsl:call-template name="last-button">
											<xsl:with-param name="class">disabled</xsl:with-param>
											<xsl:with-param name="total" select="$total"/>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>


					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- button templates (for arranging RTL in Arabic -->
	<xsl:template name="first-button">
		<xsl:param name="class"/>

		<a class="btn btn-default {$class}" role="button" title="First" href="{if($pipeline='results') then 'results' else ''}?q={encode-for-uri($q)}{if (string($sort)) then    concat('&amp;sort=',
			$sort)          else ''}{if(string($langParam)) then concat('&amp;lang=', $langParam) else ''}{if(string($side)) then concat('&amp;side=', $side) else ''}{if(string($mode)) then concat('&amp;mode=',
			$mode) else ''}{if(string($image)) then concat('&amp;image=', $image) else ''}">
			<span class="glyphicon glyphicon-fast-{if ($lang='ar') then 'forward' else 'backward'}"/>
		</a>
	</xsl:template>

	<xsl:template name="prev-button">
		<xsl:param name="class"/>
		<xsl:param name="previous"/>

		<a class="btn btn-default {$class}" role="button" title="Previous" href="{if($pipeline='results') then 'results' else    ''}?q={encode-for-uri($q)}&amp;start={$previous}{if (string($sort))
			then          concat('&amp;sort=',          $sort) else ''}{if (string($langParam)) then    concat('&amp;lang=', $langParam) else ''}{if(string($side)) then concat('&amp;side=', $side) else
			''}{if(string($mode)) then concat('&amp;mode=',    $mode) else ''}{if(string($image)) then concat('&amp;image=', $image) else ''}">
			<span class="glyphicon glyphicon-{if ($lang='ar') then 'forward' else 'backward'}"/>
		</a>
	</xsl:template>

	<xsl:template name="next-button">
		<xsl:param name="class"/>
		<xsl:param name="next"/>

		<a class="btn btn-default {$class}" role="button" title="Next" href="{if($pipeline='results') then 'results' else ''}?q={encode-for-uri($q)}&amp;start={$next}{if    (string($sort)) then
			concat('&amp;sort=', $sort) else          ''}{if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}{if(string($side)) then concat('&amp;side=', $side) else ''}{if(string($mode))
			then concat('&amp;mode=',    $mode) else ''}{if(string($image)) then concat('&amp;image=', $image) else ''}">
			<span class="glyphicon glyphicon-{if ($lang='ar') then 'backward' else 'forward'}"/>
		</a>
	</xsl:template>

	<xsl:template name="last-button">
		<xsl:param name="class"/>
		<xsl:param name="total"/>

		<a class="btn btn-default {$class}" role="button" href="{if($pipeline='results') then 'results' else ''}?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if    (string($sort)) then
			concat('&amp;sort=',          $sort) else ''}{if (string($langParam)) then concat('&amp;lang=', $langParam) else ''}{if(string($side)) then concat('&amp;side=', $side) else ''}{if(string($mode))
			then concat('&amp;mode=',    $mode) else ''}{if(string($image)) then concat('&amp;image=', $image) else ''}">
			<span class="glyphicon glyphicon-fast-{if ($lang='ar') then 'backward' else 'forward'}"/>
		</a>
	</xsl:template>

	<xsl:template name="sort">
		<xsl:variable name="sort_categories_string">
			<xsl:choose>
				<xsl:when test="$collection_type='hoard'">
					<xsl:text>authority,taq_num,timestamp,deity,denomination,dynasty,findspot,issuer,manufacture,material,mint,obv_leg_display,portrait,region,rev_leg_display</xsl:text>
				</xsl:when>
				<xsl:when test="$collection_type='cointype'">
					<xsl:text>authority,timestamp,deity,denomination,findspot,issuer,manufacture,material,mint,obv_leg_display,portrait,region,rev_leg_display,year</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>authority,axis,timestamp,deity,denomination,diameter,findspot,issuer,manufacture,material,mint,obv_leg_display,portrait,region,recordId,rev_leg_display,weight,year</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="sort_categories" select="tokenize(normalize-space($sort_categories_string), ',')"/>
		<div class="row">
			<div class="col-md-12">
				<form role="form" class="sortForm form-inline" action="results" method="GET">
					<div class="form-group">
						<select class="sortForm_categories form-control">
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
					</div>
					<div class="form-group">
						<select class="sortForm_order form-control">
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
					</div>
					<input type="hidden" name="q" value="{$q}"/>
					<input type="hidden" name="sort" value="" class="sort_param"/>
					<xsl:if test="string($langParam)">
						<input type="hidden" name="lang" value="{$lang}"/>
					</xsl:if>
					<input class="btn btn-default sort_button" type="submit" value="{numishare:normalizeLabel('results_sort-results', $lang)}">
						<xsl:if test="not(string($sort))">
							<xsl:attribute name="disabled"/>
						</xsl:if>
					</input>
				</form>
			</div>
		</div>
	</xsl:template>
	<xsl:template name="quick_search">
		<div class="quick_search">
			<h3>
				<xsl:value-of select="numishare:regularize_node('keyword', $lang)"/>
			</h3>
			<form role="form" action="results" method="GET" id="qs_form">
				<input type="hidden" name="q" id="qs_query" value="{$q}"/>
				<xsl:if test="string($langParam)">
					<input type="hidden" name="lang" value="{$lang}"/>
				</xsl:if>
				<div class="input-group">
					<input type="text" class="form-control" id="qs_text" placeholder="{numishare:normalizeLabel('header_search', $lang)}"/>
					<div class="input-group-btn">
						<button class="btn btn-default" type="submit">
							<i class="glyphicon glyphicon-search"/>
						</button>
					</div>
				</div>
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
		<xsl:variable name="params" as="node()*">
			<params>
				<xsl:if test="string($new_query)">
					<param>q=<xsl:value-of select="encode-for-uri($new_query)"/></param>
				</xsl:if>
				<xsl:if test="string($langParam)">
					<param>lang=<xsl:value-of select="$langParam"/></param>
				</xsl:if>
			</params>
		</xsl:variable>
		
		<div class="stacked_term bg-info row">
			<div class="col-md-10">
				<span>
					<b>Category: </b>
					<xsl:value-of select="numishare:recompile_category($category_fragment, tokenize(substring-after(replace(replace(replace($category_fragment, '\)', ''), '\(', ''), '\+', ''),
						'category_facet:'), ' '), 1)"/>
				</span>
			</div>
			<div class="col-md-2 right">
				<a class="remove_filter" href="{$display_path}results{if (count($params//param) &gt; 0) then concat('?', string-join($params//param, '&amp;')) else ''}">
					<span class="glyphicon glyphicon-remove"/>
				</a>
			</div>
		</div>
	</xsl:template>
	<!-- ************** PROCESS GROUP OF SPARQL RESULTS FROM NOMISMA TO DISPLAY IMAGES ************** -->
	<xsl:template match="group" mode="results">
		<xsl:variable name="hoard-count" select="number(hoard-count)"/>
		<xsl:variable name="object-count" select="number(object-count)"/>
		<xsl:variable name="count" select="$hoard-count + $object-count"/>
		<!-- display images -->
		<xsl:apply-templates select="descendant::object" mode="results"/>
		<!-- object count -->
		<xsl:if test="$count &gt; 0">
			<br/>
			<xsl:if test="$object-count &gt; 0">
				<xsl:choose>
					<xsl:when test="$object-count = 1">object</xsl:when>
					<xsl:otherwise>objects</xsl:otherwise>
				</xsl:choose>
				<xsl:text>: </xsl:text>
				<xsl:value-of select="$object-count"/>
				<xsl:if test="$hoard-count &gt; 0">
					<xsl:text>; </xsl:text>
				</xsl:if>
			</xsl:if>

			<xsl:if test="$hoard-count &gt; 0">
				<xsl:choose>
					<xsl:when test="$hoard-count = 1">
						<xsl:value-of select="numishare:normalizeLabel('results_hoard', $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="numishare:normalizeLabel('results_hoards', $lang)"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>: </xsl:text>
				<xsl:value-of select="$hoard-count"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="object" mode="results">
		<xsl:variable name="position" select="position()"/>
		<!-- obverse -->
		<xsl:choose>
			<xsl:when test="string(obvRef) and string(obvThumb)">
				<a class="thumbImage" rel="gallery" href="{obvRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{obvThumb}"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(obvRef)) and string(obvThumb)">
				<img src="{obvThumb}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
				</img>
			</xsl:when>
			<xsl:when test="string(obvRef) and not(string(obvThumb))">
				<a class="thumbImage" rel="gallery" href="{obvRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{obvRef}" style="max-width:120px"/>
				</a>
			</xsl:when>
		</xsl:choose>
		<!-- reverse-->
		<xsl:choose>
			<xsl:when test="string(revRef) and string(revThumb)">
				<a class="thumbImage" rel="gallery" href="{revRef}" title="Reverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{revThumb}"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(revRef)) and string(revThumb)">
				<img src="{revThumb}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
				</img>
			</xsl:when>
			<xsl:when test="string(revRef) and not(string(revThumb))">
				<a class="thumbImage" rel="gallery" href="{revRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{revRef}" style="max-width:120px"/>
				</a>
			</xsl:when>
		</xsl:choose>
		<!-- combined -->
		<xsl:choose>
			<xsl:when test="string(comRef) and string(comThumb)">
				<a class="thumbImage" rel="gallery" href="{comRef}" title="Reverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{comThumb}"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(comRef)) and string(comThumb)">
				<img src="{comThumb}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
				</img>
			</xsl:when>
			<xsl:when test="string(comRef) and not(string(comThumb))">
				<a class="thumbImage" rel="gallery" href="{comRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{comRef}" style="max-width:240px"/>
				</a>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
