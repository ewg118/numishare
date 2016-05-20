<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:nuds="http://nomisma.org/nuds" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:nh="http://nomisma.org/nudsHoard"
	xmlns:nm="http://nomisma.org/id/" xmlns:math="http://exslt.org/math" xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes=" #all" version="2.0">

	<!--<xsl:variable name="type_series" select="//config/type_series"/>-->

	<!-- ************** QUANTITATIVE ANALYSIS FUNCTIONS ************** -->
	<!-- this template should only apply for hoards, hence the nh namespace -->
	<xsl:template name="nh:quant">
		<xsl:param name="element"/>
		<xsl:param name="role"/>
		<xsl:variable name="counts" as="element()*">
			<counts>
				<!-- use get_hoard_quant to calculate -->
				<xsl:if test="$pipeline = 'display'">					
					<xsl:copy-of
						select="document(concat($request-uri, 'get_hoard_quant?id=', $id, '&amp;calculate=', if (string($role)) then $role else $element, '&amp;type=', $type, '&amp;exclude=', $exclude, '&amp;lang=', $lang))"/>
				</xsl:if>
				<!-- if there is a compare parameter, load get_hoard_quant with document() function -->
				<xsl:if test="string($compare) and string($calculate)">
					<xsl:for-each select="tokenize($compare, ',')">
						<xsl:copy-of
							select="document(concat($request-uri, 'get_hoard_quant?id=', ., '&amp;calculate=', if (string($role)) then $role else $element, '&amp;type=', $type, '&amp;exclude=', $exclude, '&amp;lang=', $lang))"
						/>
					</xsl:for-each>
				</xsl:if>
			</counts>
		</xsl:variable>
		<div id="{if (string($role)) then $role else $element}-container" style="min-width: 400px; height: 400px; margin: 0 auto"/>
		<table class="calculate" id="{if (string($role)) then $role else $element}-table">
			<caption>
				<xsl:choose>
					<xsl:when test="$type='count'">
						<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="numishare:normalizeLabel('numeric_percentage', $lang)"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>: </xsl:text>
				<xsl:choose>
					<xsl:when test="string($role)">
						<xsl:value-of select="concat(upper-case(substring($role, 1, 1)), substring($role, 2))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="numishare:regularize_node($element, $lang)"/>
					</xsl:otherwise>
				</xsl:choose>
			</caption>
			<thead>
				<tr>
					<th/>
					<xsl:if test="$pipeline = 'display'">
						<th>
							<xsl:value-of select="$id"/>
						</th>
					</xsl:if>
					<xsl:if test="string($compare)">
						<xsl:for-each select="tokenize($compare, ',')">
							<xsl:variable name="localId" select="."/>
							<th>
								<xsl:value-of select="$counts//hoard[@id=$localId]/@title"/>
							</th>
						</xsl:for-each>
					</xsl:if>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="distinct-values($counts//name)">
					<xsl:sort data-type="{if ($calculate = 'date') then 'number' else 'text'}"/>
					<xsl:variable name="name" select="if (string(.)) then . else 'Null value'"/>
					<tr>
						<th>
							<xsl:value-of select="$name"/>
						</th>
						<xsl:if test="$pipeline = 'display'">
							<td>
								<xsl:choose>
									<xsl:when test="number($counts//hoard[@id=$id]/*[local-name()='name'][text()=$name]/@count)">
										<xsl:value-of select="$counts//hoard[@id=$id]/*[local-name()='name'][text()=$name]/@count"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>null</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</td>
						</xsl:if>
						<xsl:if test="string($compare)">
							<xsl:for-each select="tokenize($compare, ',')">
								<xsl:variable name="hoard-id" select="."/>
								<td>
									<xsl:choose>
										<xsl:when test="number($counts//hoard[@id=$hoard-id]/*[local-name()='name'][text()=$name]/@count)">
											<xsl:value-of select="$counts//hoard[@id=$hoard-id]/*[local-name()='name'][text()=$name]/@count"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>null</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:for-each>
						</xsl:if>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template name="nh:dateQuant">
		<!-- use get_hoard_quant to calculate -->
		<div id="dateChart"/>
		<span id="dateData" style="white-space:nowrap;overflow:hidden;display:none">
			<xsl:attribute name="title">
				<xsl:choose>
					<xsl:when test="$type='count'">
						<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
					</xsl:when>
					<xsl:when test="$type='cumulative'">
						<xsl:value-of select="numishare:normalizeLabel('numeric_cumulative_percentage', $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="numishare:normalizeLabel('numeric_percentage', $lang)"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>: </xsl:text>
				<xsl:value-of select="numishare:regularize_node('date', $lang)"/>
			</xsl:attribute>

			<xsl:text>[</xsl:text>
			<xsl:if test="$pipeline = 'display'">
				<xsl:value-of select="document(concat($request-uri, 'get_hoard_quant?id=', $id, '&amp;format=js&amp;calculate=date&amp;exclude=', $exclude, '&amp;type=', $type, '&amp;lang=', $lang))"/>
			</xsl:if>
			<!-- if there is a compare parameter, load get_hoard_quant with document() function -->
			<xsl:if test="string($compare) and string($calculate)">
				<xsl:if test="$pipeline='display'">
					<xsl:text>,</xsl:text>
				</xsl:if>
				<xsl:for-each select="tokenize($compare, ',')">
					<xsl:value-of select="document(concat($request-uri, 'get_hoard_quant?id=', ., '&amp;format=js&amp;calculate=date&amp;exclude=', $exclude, '&amp;type=', $type, '&amp;lang=', $lang))"/>
					<xsl:if test="not(position()=last())">
						<!-- threre must be a line break between objects or there will be Javascript eval problems! -->
						<xsl:text>,
</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<xsl:text>]</xsl:text>
		</span>

	</xsl:template>


	<!-- ************** FORM TEMPLATES ************** -->
	<!-- ************** HOARD VISUALIZATION ************** -->
	<xsl:template name="hoard-visualization">
		<xsl:param name="action"/>
		<xsl:variable name="queryOptions">authority,coinType,deity,denomination,dynasty,issuer,material,mint,portrait,region</xsl:variable>
		<xsl:variable name="chartTypes">bar,column</xsl:variable>

		<p><xsl:value-of select="numishare:normalizeLabel('visualize_type_desc', $lang)"/>.</p>
		<form action="{$action}" id="visualize-form" role="form" method="get">
			<div class="row">
				<div class="col-md-12">
					<h2>1. <xsl:value-of select="numishare:normalizeLabel('visualize_response_type', $lang)"/></h2>
					<div class="col-md-2">
						<div class="radio">
							<label class="radio-inline">
								<input type="radio" name="type" value="percentage">
									<xsl:if test="$type = 'percentage' or not(string($type))">
										<xsl:attribute name="checked">checked</xsl:attribute>
									</xsl:if>
								</input>
								<xsl:value-of select="numishare:normalizeLabel('numeric_percentage', $lang)"/>
							</label>
						</div>
					</div>
					<div class="col-md-2">
						<div class="radio">
							<label class="radio-inline">
								<input type="radio" name="type" value="count">
									<xsl:if test="$type = 'count'">
										<xsl:attribute name="checked">checked</xsl:attribute>
									</xsl:if>
								</input>
								<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
							</label>
						</div>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12">
					<h2>2. <xsl:value-of select="numishare:normalizeLabel('visualize_chart_type', $lang)"/></h2>
					<xsl:for-each select="tokenize($chartTypes, ',')">
						<div class="col-md-2">
							<div class="radio">
								<label class="radio-inline">
									<input type="radio" name="chartType" value="{.}">
										<xsl:if test="$chartType = . or (.='column' and not(string($chartType)))">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
									</input>
									<xsl:value-of select="numishare:normalizeLabel(concat('chart_', .), $lang)"/>
								</label>
							</div>
						</div>
					</xsl:for-each>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12">
					<h2>3. <xsl:value-of select="numishare:normalizeLabel('visualize_categories', $lang)"/></h2>
					<div class="alert alert-danger center-block" id="visualize-cat-alert" style="display:none">
						<span class="glyphicon glyphicon-warning-sign"/>
						<xsl:value-of select="numishare:normalizeLabel('visualize_error3', $lang)"/>.</div>
					<xsl:for-each select="tokenize($queryOptions, ',')">
						<xsl:variable name="query_fragment" select="."/>
						<xsl:choose>
							<xsl:when test="$pipeline='analyze'">
								<xsl:call-template name="vis-checks">
									<xsl:with-param name="query_fragment" select="$query_fragment"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="count($nudsGroup/descendant::*[local-name()=$query_fragment or @xlink:role=$query_fragment]) &gt; 0">
									<xsl:call-template name="vis-checks">
										<xsl:with-param name="query_fragment" select="$query_fragment"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12">
					<xsl:choose>
						<xsl:when test="$pipeline='analyze'">
							<h2>
								<xsl:text>4. </xsl:text>
								<xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards', $lang)"/>
								<small style="margin-left:10px;">
									<a href="#filterHoards" class="showFilter" id="visualize-filter">
										<xsl:value-of select="numishare:normalizeLabel('visualize_filter_list', $lang)"/>
									</a>
								</small>
							</h2>

							<div class="alert alert-danger center-block" id="visualize-hoard-alert" style="display:none">
								<span class="glyphicon glyphicon-warning-sign"/>
								<xsl:value-of select="numishare:normalizeLabel('visualize_error4', $lang)"/>
							</div>


							<div class="filter-div" style="display:none">
								<b><xsl:value-of select="numishare:normalizeLabel('visualize_filter_query', $lang)"/>:</b>
								<span/>
								<a href="#" class="removeFilter">
									<span class="glyphicon glyphicon-remove"/>
									<xsl:value-of select="numishare:normalizeLabel('visualize_remove_filter', $lang)"/>
								</a>
							</div>
							<xsl:call-template name="get-hoards"/>
						</xsl:when>
						<xsl:otherwise>
							<h2>4. <xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards_optional', $lang)"/></h2>
							<div class="alert alert-danger center-block" id="visualize-hoard-alert" style="display:none">
								<span class="glyphicon glyphicon-warning-sign"/>
								<xsl:value-of select="numishare:normalizeLabel('visualize_error5', $lang)"/>
							</div>
							<xsl:call-template name="get-hoards"/>
						</xsl:otherwise>
					</xsl:choose>

					<div>
						<h3>
							<xsl:value-of select="numishare:normalizeLabel('visualize_optional_settings', $lang)"/>
							<small style="margin-left:10px;">
								<a href="#" class="optional-button" id="visualize-options">
									<xsl:value-of select="numishare:normalizeLabel('visualize_hide-show', $lang)"/>
								</a>
							</small>
						</h3>
						<div class="optional-div" style="display:none">
							<div>
								<h4>
									<xsl:value-of select="numishare:normalizeLabel('visualize_exclude_certainty_codes', $lang)"/>
								</h4>
								<xsl:apply-templates select="//config/certainty_codes"/>	
							</div>
							<div>
								<h4>
									<xsl:value-of select="numishare:normalizeLabel('visualize_stacking_options', $lang)"/>
								</h4>
								<select id="stacking" class="form-control">
									<option value="">
										<xsl:value-of select="numishare:normalizeLabel('results_select', $lang)"/>
									</option>
									<option value="stacking:normal">
										<xsl:if test="contains($options, 'stacking:normal')">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="numishare:normalizeLabel('numeric_cumulative', $lang)"/>
									</option>
									<option value="stacking:percent">
										<xsl:if test="contains($options, 'stacking:percent')">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="numishare:normalizeLabel('numeric_percentage', $lang)"/>
									</option>
								</select>
							</div>
						</div>
					</div>
				</div>
			</div>
			<input type="hidden" name="calculate" id="calculate-input" value=""/>
			<input type="hidden" name="compare" class="compare-input" value=""/>
			<input type="hidden" name="exclude" class="exclude-input" value=""/>
			<input type="hidden" name="options" id="options-input" value="{$options}"/>
			<br/>
			<input type="submit" value="{numishare:normalizeLabel('visualize_calculate', $lang)}" class="submit-vis btn btn-default" id="visualize-submit"/>
		</form>

		<!-- output charts and tables -->
		<xsl:for-each select="tokenize($calculate, ',')">
			<xsl:if test="not(.='date')">
				<xsl:variable name="element">
					<xsl:choose>
						<xsl:when test=". = 'material' or .='denomination'">
							<xsl:value-of select="."/>
						</xsl:when>
						<xsl:when test=".='mint' or .='region'">
							<xsl:text>geogname</xsl:text>
						</xsl:when>
						<xsl:when test=".='dynasty'">
							<xsl:text>famname</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>persname</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="role">
					<xsl:if test=". != 'material' and . != 'denomination'">
						<xsl:value-of select="."/>
					</xsl:if>
				</xsl:variable>

				<xsl:call-template name="nh:quant">
					<xsl:with-param name="element" select="$element"/>
					<xsl:with-param name="role" select="$role"/>
				</xsl:call-template>
			</xsl:if>			
		</xsl:for-each>
	</xsl:template>

	<!-- ************** DATE ANALYSIS: HOARDS ************** -->
	<xsl:template name="date-vis">
		<xsl:param name="action"/>
		<xsl:variable name="chartTypes">bar,column,area,line,spline,areaspline</xsl:variable>

		<p><xsl:value-of select="numishare:normalizeLabel('visualize_date_desc', $lang)"/>.</p>
		<form action="{$action}" id="date-form" role="form" method="get">
			<div class="row">
				<div class="col-md-12">
					<h2>1. <xsl:value-of select="numishare:normalizeLabel('visualize_response_type', $lang)"/></h2>
					<div class="col-md-2">
						<div class="radio">
							<label class="radio-inline">
								<input type="radio" name="type" value="percentage">
									<xsl:if test="$type = 'percentage' or not(string($type))">
										<xsl:attribute name="checked">checked</xsl:attribute>
									</xsl:if>
								</input>

								<xsl:value-of select="numishare:normalizeLabel('numeric_percentage', $lang)"/>
							</label>
						</div>
					</div>
					<div class="col-md-2">
						<div class="radio">
							<label class="radio-inline">
								<input type="radio" name="type" value="cumulative">
									<xsl:if test="$type = 'cumulative'">
										<xsl:attribute name="checked">checked</xsl:attribute>
									</xsl:if>
								</input>

								<xsl:value-of select="numishare:normalizeLabel('numeric_cumulative_percentage', $lang)"/>
							</label>
						</div>
					</div>
					<div class="col-md-2">
						<div class="radio">
							<label class="radio-inline">
								<input type="radio" name="type" value="count">
									<xsl:if test="$type = 'count'">
										<xsl:attribute name="checked">checked</xsl:attribute>
									</xsl:if>
								</input>
								<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
							</label>
						</div>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12">
					<h2>2. <xsl:value-of select="numishare:normalizeLabel('visualize_chart_type', $lang)"/></h2>
					<xsl:for-each select="tokenize($chartTypes, ',')">
						<div class="col-md-2">
							<div class="radio">
								<label class="radio-inline">
									<input type="radio" name="chartType" value="{.}">
										<xsl:if test="$chartType = . or (.='line' and not(string($chartType)))">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
										<xsl:if test="$type='count' and (.='line' or .='area' or .='areaspline' or .='spline')">
											<xsl:attribute name="disabled">disabled</xsl:attribute>
										</xsl:if>
										<xsl:if test="$type!='count' and (.='column' or .='bar')">
											<xsl:attribute name="disabled">disabled</xsl:attribute>
										</xsl:if>
									</input>
									<xsl:value-of select="numishare:normalizeLabel(concat('chart_', .), $lang)"/>
								</label>
							</div>
						</div>
					</xsl:for-each>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12">
					<xsl:choose>
						<xsl:when test="$pipeline='analyze'">
							<h2>
								<xsl:text>3. </xsl:text>
								<xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards', $lang)"/>
								<small style="margin-left:10px;">
									<a href="#filterHoards" class="showFilter" id="date-filter">
										<xsl:value-of select="numishare:normalizeLabel('visualize_filter_list', $lang)"/>
									</a>
								</small>
							</h2>
							<div class="alert alert-danger center-block" id="date-hoard-alert" style="display:none">
								<span class="glyphicon glyphicon-warning-sign"/>
								<xsl:value-of select="numishare:normalizeLabel('visualize_error4', $lang)"/>
							</div>
							<div class="filter-div" style="display:none">
								<b><xsl:value-of select="numishare:normalizeLabel('visualize_filter_query', $lang)"/>:</b>
								<span/>
								<a href="#" class="removeFilter">
									<span class="glyphicon glyphicon-remove"/>
									<xsl:value-of select="numishare:normalizeLabel('visualize_remove_filter', $lang)"/>
								</a>
							</div>
							<xsl:call-template name="get-hoards"/>
						</xsl:when>
						<xsl:otherwise>
							<h2>3. <xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards_optional', $lang)"/></h2>
							<div class="alert alert-danger center-block" id="date-hoard-alert" style="display:none">
								<span class="glyphicon glyphicon-warning-sign"/>
								<xsl:value-of select="numishare:normalizeLabel('visualize_error5', $lang)"/>
							</div>
							<xsl:call-template name="get-hoards"/>
						</xsl:otherwise>
					</xsl:choose>
					<div>
						<h3>
							<xsl:value-of select="numishare:normalizeLabel('visualize_optional_settings', $lang)"/>
							<small style="margin-left:10px;">
								<a href="#" class="optional-button" id="date-options">
									<xsl:value-of select="numishare:normalizeLabel('visualize_hide-show', $lang)"/>
								</a>
							</small>
						</h3>
						<div class="optional-div" style="display:none">
							<h4>
								<xsl:value-of select="numishare:normalizeLabel('visualize_exclude_certainty_codes', $lang)"/>
							</h4>
							<xsl:copy-of select="/content/select[@id='get_certainty_codes']"/>
						</div>
					</div>
				</div>
			</div>
			<input type="hidden" name="calculate" id="calculate-input" value=""/>
			<input type="hidden" name="compare" class="compare-input" value=""/>
			<input type="hidden" name="exclude" class="exclude-input" value=""/>
			<br/>
			<input type="submit" value="{numishare:normalizeLabel('visualize_calculate', $lang)}" class="submit-vis btn btn-default" id="date-submit"/>
		</form>

		<xsl:if test="$calculate='date'">
			<xsl:choose>
				<xsl:when test="$type='count'">
					<xsl:call-template name="nh:quant">
						<xsl:with-param name="element">date</xsl:with-param>
						<xsl:with-param name="role"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="nh:dateQuant"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- ************** DOWNLOAD: HOARD ANALYSIS ************** -->
	<xsl:template name="data-download">
		<xsl:variable name="queryOptions">authority,coinType,date,deity,denomination,dynasty,issuer,material,mint,portrait,region</xsl:variable>

		<p><xsl:value-of select="numishare:normalizeLabel('visualize_csv_desc', $lang)"/>.</p>
		<form action="{$display_path}hoards.csv" id="csv-form" style="margin-bottom:40px;" role="form" method="get">
			<div class="row">
				<div class="col-md-12">
					<h2>1. <xsl:value-of select="numishare:normalizeLabel('visualize_response_type', $lang)"/></h2>
					<div class="col-md-2">
						<div class="radio">
							<label class="radio-inline">
								<input type="radio" name="type" value="percentage">
									<xsl:if test="$type = 'percentage' or not(string($type))">
										<xsl:attribute name="checked">checked</xsl:attribute>
									</xsl:if>
								</input>
								<xsl:value-of select="numishare:normalizeLabel('numeric_percentage', $lang)"/>
							</label>
						</div>
					</div>
					<div class="col-md-2">
						<div class="radio">
							<label class="radio-inline">
								<input type="radio" name="type" value="count">
									<xsl:if test="$type = 'count'">
										<xsl:attribute name="checked">checked</xsl:attribute>
									</xsl:if>
								</input>
								<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
							</label>
						</div>
					</div>
					<div class="col-md-2">
						<div class="radio">
							<label class="radio-inline">
								<input type="radio" name="type" value="cumulative">
									<xsl:if test="$type = 'cumulative'">
										<xsl:attribute name="checked">checked</xsl:attribute>
									</xsl:if>
									<xsl:if test="$calculate != 'date'">
										<xsl:attribute name="disabled">disabled</xsl:attribute>
									</xsl:if>
								</input>
								<xsl:value-of select="numishare:normalizeLabel('numeric_cumulative_percentage', $lang)"/>
							</label>
						</div>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12">
					<h2>2. <xsl:value-of select="numishare:normalizeLabel('visualize_categories', $lang)"/></h2>
					<div class="alert alert-danger center-block" id="csv-cat-alert" style="display:none">
						<span class="glyphicon glyphicon-warning-sign"/>
						<xsl:value-of select="numishare:normalizeLabel('visualize_error3', $lang)"/>
					</div>
					<xsl:for-each select="tokenize($queryOptions, ',')">
						<xsl:variable name="query_fragment" select="."/>
						<xsl:choose>
							<xsl:when test="$pipeline='analyze'">
								<xsl:call-template name="vis-radios">
									<xsl:with-param name="query_fragment" select="$query_fragment"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="count($nudsGroup/descendant::*[local-name()=$query_fragment or @xlink:role=$query_fragment]) &gt; 0">
									<xsl:call-template name="vis-radios">
										<xsl:with-param name="query_fragment" select="$query_fragment"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12">
					<xsl:choose>
						<xsl:when test="$pipeline='analyze'">
							<h2>
								<xsl:text>3. </xsl:text>
								<xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards', $lang)"/>
								<small style="margin-left:10px;">
									<a href="#filterHoards" class="showFilter" id="csv-filter">
										<xsl:value-of select="numishare:normalizeLabel('visualize_filter_list', $lang)"/>
									</a>
								</small>
							</h2>
							<div class="alert alert-danger center-block" id="csv-hoard-alert" style="display:none">
								<span class="glyphicon glyphicon-warning-sign"/>
								<xsl:value-of select="numishare:normalizeLabel('visualize_error6', $lang)"/>
							</div>
							<div class="filter-div" style="display:none">
								<b><xsl:value-of select="numishare:normalizeLabel('visualize_filter_query', $lang)"/>:</b>
								<span/>
								<a href="#" class="removeFilter">
									<span class="glyphicon glyphicon-remove"/>
									<xsl:value-of select="numishare:normalizeLabel('visualize_remove_filter', $lang)"/>
								</a>
							</div>
							<xsl:call-template name="get-hoards"/>
						</xsl:when>
						<xsl:otherwise>
							<h2>3. <xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards_optional', $lang)"/></h2>
							<div class="alert alert-danger center-block" id="csv-hoard-alert" style="display:none">
								<span class="glyphicon glyphicon-warning-sign"/>
								<xsl:value-of select="numishare:normalizeLabel('visualize_error7', $lang)"/>
							</div>
							<xsl:call-template name="get-hoards"/>
						</xsl:otherwise>
					</xsl:choose>

					<div>
						<h3>
							<xsl:value-of select="numishare:normalizeLabel('visualize_optional_settings', $lang)"/>
							<small style="margin-left:10px;">
								<a href="#" class="optional-button" id="csv-options">
									<xsl:value-of select="numishare:normalizeLabel('visualize_hide-show', $lang)"/>
								</a>
							</small>
						</h3>
						<div class="optional-div" style="display:none">
							<h4>
								<xsl:value-of select="numishare:normalizeLabel('visualize_exclude_certainty_codes', $lang)"/>
							</h4>
							<xsl:copy-of select="/content/select[@id='get_certainty_codes']"/>
						</div>
					</div>
				</div>
			</div>

			<xsl:if test="$pipeline='display'">
				<input type="hidden" id="thisHoard" value="{$id}"/>
			</xsl:if>
			<input type="hidden" name="exclude" class="exclude-input" value=""/>
			<input type="hidden" name="compare" class="compare-input" value=""/>
			<br/>
			<input type="submit" value="{numishare:normalizeLabel('visualize_calculate', $lang)}" id="csv-submit" class="btn btn-default"/>
		</form>
	</xsl:template>

	<!-- ************** HOARDS: GET HOARDS FOR COMPARISON ************** -->
	<xsl:template name="get-hoards">
		<div class="compare-div">
			<xsl:copy-of select="/content/select[@id='get_hoards-control']"/>
		</div>
	</xsl:template>
	
	<!-- ************** CERTAINTY CODES, GENERATED FROM CONFIG ************** -->
	<xsl:template match="certainty_codes">
		<select multiple="multiple" size="10" class="certainty-select">
			<xsl:apply-templates select="descendant::code"/>
		</select>
	</xsl:template>
	
	<xsl:template match="code">		
		<option value="{.}" class="exclude-option">
			<xsl:if test="@accept='false'">
				<xsl:attribute name="selected">selected</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="."/>
		</option>
	</xsl:template>
	
	<!-- ************** CHECKBOXES ************** -->
	<xsl:template name="vis-checks">
		<xsl:param name="query_fragment"/>
		<div class="col-md-2">
			<div class="checkbox">
				<label class="checkbox-inline">
					<xsl:choose>
						<xsl:when test="contains($calculate, $query_fragment)">
							<input type="checkbox" id="{$query_fragment}-checkbox" checked="checked" value="{$query_fragment}" class="calculate-checkbox"/>
						</xsl:when>
						<xsl:otherwise>
							<input type="checkbox" id="{$query_fragment}-checkbox" value="{$query_fragment}" class="calculate-checkbox"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="numishare:normalize_fields($query_fragment, $lang)"/>
				</label>
			</div>
		</div>
	</xsl:template>
	<xsl:template name="vis-radios">
		<xsl:param name="query_fragment"/>
		<div class="col-md-2">
			<div class="radio">
				<label class="radio-inline">
					<input type="radio" name="calculate" id="{$query_fragment}-radio" value="{$query_fragment}" class="calculate-checkbox"/>
					<xsl:value-of select="numishare:normalize_fields($query_fragment, $lang)"/>
				</label>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
