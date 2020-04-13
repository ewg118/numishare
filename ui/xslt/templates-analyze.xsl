<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nuds="http://nomisma.org/nuds" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:nh="http://nomisma.org/nudsHoard" xmlns:nm="http://nomisma.org/id/" xmlns:math="http://exslt.org/math"
	xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes=" #all" version="2.0">

	<!-- ************** FORM TEMPLATES ************** -->
	<xsl:template name="hoard-visualization">
		<xsl:param name="hidden"/>
		<xsl:param name="action"/>
		<xsl:param name="compare"/>
		
		<div>
			<xsl:choose>
				<xsl:when test="$hidden = true()">
					<xsl:attribute name="class">hidden chart-container</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">chart-container</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			
			<div id="distribution-chart"/>
			
			<!-- only display model-generated link when there are URL params (distribution page) -->
			<div style="margin-bottom:10px;" class="control-row text-center">				
				
				<xsl:choose>
					<xsl:when test="$hidden = false()">
						<xsl:variable name="queryParams" as="element()*">
							<params>
								<xsl:if test="string($dist)">
									<param>
										<xsl:value-of select="concat('dist=', $dist)"/>
									</param>
								</xsl:if>								
								<xsl:if test="string($type)">
									<param>
										<xsl:value-of select="concat('type=', $type)"/>
									</param>
								</xsl:if>
								<xsl:for-each select="$compare">
									<param>
										<xsl:value-of select="concat('compare=', normalize-space(.))"/>
									</param>
								</xsl:for-each>
								<xsl:if test="string($langParam)">
									<param>
										<xsl:value-of select="concat('lang=', $langParam)"/>
									</param>
								</xsl:if>
								<param>format=csv</param>
							</params>
						</xsl:variable>
						
						<a href="{$display_path}analyze" title="Clear" class="btn btn-primary">
							<span class="glyphicon glyphicon-erase"/>Clear</a>
						
						<a href="{$display_path}apis/getHoardQuant?{string-join($queryParams/*, '&amp;')}" title="Download CSV" class="btn btn-primary">
							<span class="glyphicon glyphicon-download"/>Download CSV</a>
					</xsl:when>
					<xsl:otherwise>
						<a href="#" title="Download" class="btn btn-primary">
							<span class="glyphicon glyphicon-download"/>Download CSV</a>
						<a href="#" title="Bookmark" class="btn btn-primary">
							<span class="glyphicon glyphicon-download"/>View in Separate Page</a>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
		
		<xsl:call-template name="distributionForm">
			<xsl:with-param name="action" select="concat('./', $id, '#quantitative')"/>
			<xsl:with-param name="compare" select="$id"/>
		</xsl:call-template>
	</xsl:template>


	<!-- ************** HOARD DISTRIBUTION HTML FORM ************** -->
	<xsl:template name="distributionForm">
		<xsl:param name="action"/>
		<xsl:param name="compare"/>

		<p><xsl:value-of select="numishare:normalizeLabel('visualize_type_desc', $lang)"/>.</p>
		<form action="{$action}" id="distributionForm" class="quant-form" role="form" method="get">
			<div>
				<h3>
					<xsl:value-of select="numishare:normalizeLabel('visualize_categories', $lang)"/>
				</h3>
				<div class="alert alert-danger alert-box" id="visualize-cat-alert">
					<span class="glyphicon glyphicon-warning-sign"/>
					<xsl:value-of select="numishare:normalizeLabel('visualize_error3', $lang)"/>
				</div>
				<select class="form-control" name="dist" id="categorySelect">
					<option value="">
						<xsl:value-of select="numishare:normalizeLabel('results_select', $lang)"/>
					</option>
					<xsl:call-template name="distribution_options"/>
				</select>
			</div>
			<div>
				<h3>
					<xsl:value-of select="numishare:normalizeLabel('visualize_response_type', $lang)"/>
				</h3>
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
				<div class="radio">
					<label class="radio-inline">
						<input type="radio" name="type" value="cumulative">
							<xsl:choose>
								<xsl:when test="$type = 'cumulative'">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="disabled">disabled</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>

						</input>
						<xsl:value-of select="numishare:normalizeLabel('numeric_cumulative', $lang)"/>
					</label>
				</div>
			</div>
			<div>
				<xsl:choose>
					<xsl:when test="$pipeline = 'analyze'">
						<h3>
							<xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards', $lang)"/>
							<small style="margin-left:10px;">
								<a href="#filterHoards" class="showFilter" id="visualize-filter">
									<xsl:value-of select="numishare:normalizeLabel('visualize_filter_list', $lang)"/>
								</a>
							</small>
						</h3>

						<div class="alert alert-danger alert-box hidden" id="hoard-count-alert">
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
						<h3>
							<xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards_optional', $lang)"/>
						</h3>
						<div class="alert alert-danger alert-box hidden" id="hoard-count-alert">
							<span class="glyphicon glyphicon-warning-sign"/>
							<xsl:value-of select="numishare:normalizeLabel('visualize_error5', $lang)"/>
						</div>
						<xsl:call-template name="get-hoards"/>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:if test="//config/certainty_codes/*">
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
						</div>
					</div>
				</xsl:if>				
			</div>


			<input type="hidden" name="dist"/>
			<input type="hidden" name="exclude"/>
			<xsl:if test="string($compare)">
				<input type="hidden" name="compare" value="{$compare}"/>
			</xsl:if>
			<input type="hidden" name="options" value="{$options}"/>
			<br/>
			<input type="submit" value="{numishare:normalizeLabel('visualize_calculate', $lang)}" class="btn btn-default visualize-submit" disabled="disabled"/>
		</form>
	</xsl:template>

	<xsl:template name="distribution_options">
		<xsl:variable name="fields" select="concat(string-join(//config/facets/facet[contains(., '_facet')], ','), ',date')"/>

		<xsl:for-each select="tokenize($fields, ',')">
			<xsl:sort select="." order="ascending"/>

			<xsl:variable name="name" select="replace(., '_facet', '')"/>
			<option value="{$name}" class="dist_option">
				<xsl:if test="$name = $dist">
					<xsl:attribute name="selected">selected</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="numishare:normalize_fields($name, $lang)"/>
			</option>
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
										<xsl:if test="$chartType = . or (. = 'line' and not(string($chartType)))">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
										<xsl:if test="$type = 'count' and (. = 'line' or . = 'area' or . = 'areaspline' or . = 'spline')">
											<xsl:attribute name="disabled">disabled</xsl:attribute>
										</xsl:if>
										<xsl:if test="$type != 'count' and (. = 'column' or . = 'bar')">
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
						<xsl:when test="$pipeline = 'analyze'">
							<h2>
								<xsl:text>3. </xsl:text>
								<xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards', $lang)"/>
								<small style="margin-left:10px;">
									<a href="#filterHoards" class="showFilter" id="date-filter">
										<xsl:value-of select="numishare:normalizeLabel('visualize_filter_list', $lang)"/>
									</a>
								</small>
							</h2>
							<div class="alert alert-danger alert-box" id="date-hoard-alert" style="display:none">
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
							<div class="alert alert-danger alert-box" id="date-hoard-alert" style="display:none">
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
							<xsl:copy-of select="/content/select[@id = 'get_certainty_codes']"/>
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

		<!--<xsl:if test="$dist='date'">
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
		</xsl:if>-->
	</xsl:template>

	<!-- ************** HOARDS: GET HOARDS FOR COMPARISON ************** -->
	<xsl:template name="get-hoards">
		<div class="compare-div">
			<xsl:copy-of select="/content/select[@id = 'get_hoards-control']"/>
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
			<xsl:if test="@accept = 'false'">
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
						<xsl:when test="contains($dist, $query_fragment)">
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
