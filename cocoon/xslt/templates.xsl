<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:numishare="http://code.google.com/p/numishare/" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:nuds="http://nomisma.org/nuds" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:nh="http://nomisma.org/nudsHoard" xmlns:nm="http://nomisma.org/id/" xmlns:math="http://exslt.org/math"
	xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes=" #all" version="2.0">

	<xsl:variable name="flickr-api-key" select="//config/flickr_api_key"/>

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
						select="document(concat('cocoon:/get_hoard_quant?id=', $id, '&amp;calculate=', if (string($role)) then $role else $element, '&amp;type=', $type, '&amp;exclude=', $exclude))"
					/>
				</xsl:if>
				<!-- if there is a compare parameter, load get_hoard_quant with document() function -->
				<xsl:if test="string($compare) and string($calculate)">
					<xsl:for-each select="tokenize($compare, ',')">
						<xsl:copy-of
							select="document(concat('cocoon:/get_hoard_quant?id=', ., '&amp;calculate=', if (string($role)) then $role else $element, '&amp;type=', $type, '&amp;exclude=', $exclude))"
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
				<cinclude:include src="cocoon:/get_hoard_quant?id={$id}&amp;type={$type}&amp;format=js&amp;calculate=date&amp;exclude={$exclude}"/>
			</xsl:if>
			<!-- if there is a compare parameter, load get_hoard_quant with document() function -->
			<xsl:if test="string($compare) and string($calculate)">
				<xsl:if test="$pipeline='display'">
					<xsl:text>,</xsl:text>
				</xsl:if>
				<xsl:for-each select="tokenize($compare, ',')">
					<cinclude:include src="cocoon:/get_hoard_quant?id={.}&amp;type={$type}&amp;format=js&amp;calculate=date&amp;exclude={$exclude}"/>
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
	<xsl:template name="visualization">
		<xsl:param name="action"/>
		<xsl:variable name="queryOptions">authority,coinType,deity,denomination,dynasty,issuer,material,mint,portrait,region</xsl:variable>
		<xsl:variable name="chartTypes">bar,column</xsl:variable>

		<p><xsl:value-of select="numishare:normalizeLabel('visualize_type_desc', $lang)"/>.</p>
		<form action="{$action}" id="visualize-form" style="margin-bottom:40px;">
			<h2>1. <xsl:value-of select="numishare:normalizeLabel('visualize_response_type', $lang)"/></h2>
			<input type="radio" name="type" value="percentage">
				<xsl:if test="$type != 'count'">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
			</input>
			<label for="type-radio">
				<xsl:value-of select="numishare:normalizeLabel('numeric_percentage', $lang)"/>
			</label>
			<br/>
			<input type="radio" name="type" value="count">
				<xsl:if test="$type = 'count'">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
			</input>
			<label for="type-radio">
				<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
			</label>
			<br/>
			<div style="display:table;width:100%">
				<h2>2. <xsl:value-of select="numishare:normalizeLabel('visualize_chart_type', $lang)"/></h2>
				<xsl:for-each select="tokenize($chartTypes, ',')">
					<span class="anOption">
						<input type="radio" name="chartType" value="{.}">
							<xsl:if test="$chartType = . or (.='column' and not(string($chartType)))">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
						</input>
						<label for="chartType-radio">
							<xsl:value-of select="numishare:normalizeLabel(concat('chart_', .), $lang)"/>
						</label>
					</span>

				</xsl:for-each>
			</div>
			<div style="display:table;width:100%">
				<h2>3. <xsl:value-of select="numishare:normalizeLabel('visualize_categories', $lang)"/></h2>
				<div style="height:30px">
					<div class="ui-state-error ui-corner-all" id="visualize-cat-alert" style="display:none">
						<span class="ui-icon ui-icon-alert" style="float:left"/>
						<strong><xsl:value-of select="numishare:normalizeLabel('visualize_alert', $lang)"/>:</strong>
						<xsl:value-of select="numishare:normalizeLabel('visualize_error3', $lang)"/>.</div>
				</div>
				<xsl:for-each select="tokenize($queryOptions, ',')">
					<xsl:variable name="query_fragment" select="."/>
					<span class="anOption">
						<xsl:choose>
							<xsl:when test="$pipeline='analyze'">
								<xsl:call-template name="vis-checks">
									<xsl:with-param name="query_fragment" select="$query_fragment"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if
									test="count($nudsGroup/descendant::*[local-name()=$query_fragment or @xlink:role=$query_fragment]) &gt; 0">
									<xsl:call-template name="vis-checks">
										<xsl:with-param name="query_fragment" select="$query_fragment"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</span>
				</xsl:for-each>
			</div>
			<xsl:choose>
				<xsl:when test="$pipeline='analyze'">
					<h2>
						<xsl:text>4. </xsl:text>
						<xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards', $lang)"/>
						<span style="font-size:60%;margin-left:10px;">
							<a href="#filterHoards" class="showFilter" id="visualize-filter">
								<xsl:value-of select="numishare:normalizeLabel('visualize_filter_list', $lang)"/>
							</a>
						</span>
					</h2>

					<div style="height:30px">
						<div class="ui-state-error ui-corner-all" id="visualize-hoard-alert" style="display:none">
							<span class="ui-icon ui-icon-alert" style="float:left"/>
							<strong><xsl:value-of select="numishare:normalizeLabel('visualize_alert', $lang)"/>:</strong>
							<xsl:value-of select="numishare:normalizeLabel('visualize_error4', $lang)"/>
						</div>
					</div>


					<div class="filter-div" style="display:none">
						<b><xsl:value-of select="numishare:normalizeLabel('visualize_filter_query', $lang)"/>:</b>
						<span/>
						<a href="#" class="removeFilter">
							<xsl:value-of select="numishare:normalizeLabel('visualize_remove_filter', $lang)"/>
						</a>
					</div>
					<xsl:call-template name="get-hoards"/>
				</xsl:when>
				<xsl:otherwise>
					<h2>4. <xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards_optional', $lang)"/></h2>
					<div style="height:30px">
						<div class="ui-state-error ui-corner-all" id="visualize-hoard-alert" style="display:none">
							<span class="ui-icon ui-icon-alert" style="float:left"/>
							<strong><xsl:value-of select="numishare:normalizeLabel('visualize_alert', $lang)"/>:</strong>
							<xsl:value-of select="numishare:normalizeLabel('visualize_error5', $lang)"/>
						</div>
					</div>
					<xsl:call-template name="get-hoards"/>
				</xsl:otherwise>
			</xsl:choose>

			<div>
				<h3>
					<xsl:value-of select="numishare:normalizeLabel('visualize_optional_settings', $lang)"/>
					<span style="font-size:60%;margin-left:10px;">
						<a href="#" class="optional-button" id="visualize-options">
							<xsl:value-of select="numishare:normalizeLabel('visualize_hide-show', $lang)"/>
						</a>
					</span>
				</h3>
				<div class="optional-div" style="display:none">
					<div>
						<dl>
							<dt>
								<xsl:value-of select="numishare:normalizeLabel('visualize_exclude_certainty_codes', $lang)"/>
							</dt>
							<dd>
								<cinclude:include src="cocoon:/get_certainty_codes?exclude={$exclude}"/>
							</dd>
						</dl>
					</div>
					<div>
						<dl>
							<dt>
								<xsl:value-of select="numishare:normalizeLabel('visualize_stacking_options', $lang)"/>
							</dt>
							<dd>
								<select id="stacking">
									<option value="">
										<xsl:value-of select="numishare:normalizeLabel('results_select', $lang)"/>
									</option>
									<option value="stacking:normal">
										<xsl:if test="contains($options, 'stacking:normal')">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:text><xsl:value-of select="numishare:normalizeLabel('numeric_cumulative', $lang)"/></xsl:text>
									</option>
									<option value="stacking:percent">
										<xsl:if test="contains($options, 'stacking:percent')">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:text><xsl:value-of select="numishare:normalizeLabel('numeric_percentage', $lang)"/></xsl:text>
									</option>
								</select>
							</dd>
						</dl>
					</div>
				</div>
			</div>

			<input type="hidden" name="calculate" id="calculate-input" value=""/>
			<input type="hidden" name="compare" class="compare-input" value=""/>
			<input type="hidden" name="exclude" class="exclude-input" value=""/>
			<input type="hidden" name="options" id="options-input" value="{$options}"/>
			<br/>
			<input type="submit" value="{numishare:normalizeLabel('visualize_calculate', $lang)}" class="submit-vis" id="visualize-submit"/>
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

	<xsl:template name="date-vis">
		<xsl:param name="action"/>
		<xsl:variable name="chartTypes">bar,column,area,line,spline,areaspline</xsl:variable>

		<p><xsl:value-of select="numishare:normalizeLabel('visualize_date_desc', $lang)"/>.</p>
		<form action="{$action}" id="date-form" style="margin-bottom:40px;">
			<h2>1. <xsl:value-of select="numishare:normalizeLabel('visualize_response_type', $lang)"/></h2>
			<input type="radio" name="type" value="percentage">
				<xsl:if test="$type != 'count'">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
			</input>
			<label for="type-radio">
				<xsl:value-of select="numishare:normalizeLabel('numeric_percentage', $lang)"/>
			</label>
			<br/>
			<input type="radio" name="type" value="cumulative">
				<xsl:if test="$type = 'cumulative'">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
			</input>
			<label for="type-radio">
				<xsl:value-of select="numishare:normalizeLabel('numeric_cumulative_percentage', $lang)"/>
			</label>
			<br/>
			<input type="radio" name="type" value="count">
				<xsl:if test="$type = 'count'">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
			</input>
			<label for="type-radio">
				<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
			</label>
			<br/>
			<div style="display:table;width:100%">
				<h2>2. <xsl:value-of select="numishare:normalizeLabel('visualize_chart_type', $lang)"/></h2>
				<xsl:for-each select="tokenize($chartTypes, ',')">
					<span class="anOption">
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
						<label for="chartType-radio">
							<xsl:value-of select="numishare:normalizeLabel(concat('chart_', .), $lang)"/>
						</label>
					</span>

				</xsl:for-each>
			</div>
			<xsl:choose>
				<xsl:when test="$pipeline='analyze'">
					<h2>
						<xsl:text>3. </xsl:text>
						<xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards', $lang)"/>
						<span style="font-size:60%;margin-left:10px;">
							<a href="#filterHoards" class="showFilter" id="date-filter">
								<xsl:value-of select="numishare:normalizeLabel('visualize_filter_list', $lang)"/>
							</a>
						</span>
					</h2>
					<div style="height:30px">
						<div class="ui-state-error ui-corner-all" id="date-hoard-alert" style="display:none">
							<span class="ui-icon ui-icon-alert" style="float:left"/>
							<strong><xsl:value-of select="numishare:normalizeLabel('visualize_alert', $lang)"/>:</strong>
							<xsl:value-of select="numishare:normalizeLabel('visualize_error4', $lang)"/>
						</div>
					</div>
					<div class="filter-div" style="display:none">
						<b><xsl:value-of select="numishare:normalizeLabel('visualize_filter_query', $lang)"/>:</b>
						<span/>
						<a href="#" class="removeFilter">
							<xsl:value-of select="numishare:normalizeLabel('visualize_remove_filter', $lang)"/>
						</a>
					</div>
					<xsl:call-template name="get-hoards"/>
				</xsl:when>
				<xsl:otherwise>
					<h2>3. <xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards_optional', $lang)"/></h2>
					<div style="height:30px">
						<div class="ui-state-error ui-corner-all" id="date-hoard-alert" style="display:none">
							<span class="ui-icon ui-icon-alert" style="float:left"/>
							<strong><xsl:value-of select="numishare:normalizeLabel('visualize_alert', $lang)"/>:</strong>
							<xsl:value-of select="numishare:normalizeLabel('visualize_error5', $lang)"/>
						</div>
					</div>
					<xsl:call-template name="get-hoards"/>
				</xsl:otherwise>
			</xsl:choose>
			<div>
				<h3>
					<xsl:value-of select="numishare:normalizeLabel('visualize_optional_settings', $lang)"/>
					<span style="font-size:60%;margin-left:10px;">
						<a href="#" class="optional-button" id="date-options">
							<xsl:value-of select="numishare:normalizeLabel('visualize_hide-show', $lang)"/>
						</a>
					</span>
				</h3>
				<div class="optional-div" style="display:none">
					<h4>
						<xsl:value-of select="numishare:normalizeLabel('visualize_exclude_certainty_codes', $lang)"/>
					</h4>
					<cinclude:include src="cocoon:/get_certainty_codes?exclude={$exclude}"/>
				</div>
			</div>

			<input type="hidden" name="calculate" id="calculate-input" value=""/>
			<input type="hidden" name="compare" class="compare-input" value=""/>
			<input type="hidden" name="exclude" class="exclude-input" value=""/>
			<br/>
			<input type="submit" value="{numishare:normalizeLabel('visualize_calculate', $lang)}" class="submit-vis" id="date-submit"/>
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

	<xsl:template name="data-download">
		<xsl:variable name="queryOptions">authority,coinType,date,deity,denomination,dynasty,issuer,material,mint,portrait,region</xsl:variable>

		<p><xsl:value-of select="numishare:normalizeLabel('visualize_csv_desc', $lang)"/>.</p>
		<form action="{$display_path}hoards.csv" id="csv-form" style="margin-bottom:40px;">
			<h2>1. <xsl:value-of select="numishare:normalizeLabel('visualize_response_type', $lang)"/></h2>
			<input type="radio" name="type" value="percentage">
				<xsl:if test="$type != 'count' and $type != 'cumulative'">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
			</input>
			<label for="type-radio">
				<xsl:value-of select="numishare:normalizeLabel('numeric_percentage', $lang)"/>
			</label>
			<br/>
			<input type="radio" name="type" value="count">
				<xsl:if test="$type = 'count'">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
			</input>
			<label for="type-radio">
				<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
			</label>
			<br/>
			<input type="radio" name="type" value="cumulative">
				<xsl:if test="$type = 'cumulative'">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
				<xsl:if test="$calculate != 'date'">
					<xsl:attribute name="disabled">disabled</xsl:attribute>
				</xsl:if>
			</input>
			<label for="type-radio">
				<xsl:value-of select="numishare:normalizeLabel('numeric_cumulative_percentage', $lang)"/>
			</label>
			<br/>
			<div style="width:100%;display:table">
				<h2>2. <xsl:value-of select="numishare:normalizeLabel('visualize_categories', $lang)"/></h2>
				<div style="height:30px">
					<div class="ui-state-error ui-corner-all" id="csv-cat-alert" style="display:none">
						<span class="ui-icon ui-icon-alert" style="float:left"/>
						<strong><xsl:value-of select="numishare:normalizeLabel('visualize_alert', $lang)"/>:</strong>
						<xsl:value-of select="numishare:normalizeLabel('visualize_error3', $lang)"/>
					</div>
				</div>
				<xsl:for-each select="tokenize($queryOptions, ',')">
					<xsl:variable name="query_fragment" select="."/>
					<span class="anOption">
						<xsl:choose>
							<xsl:when test="$pipeline='analyze'">
								<xsl:call-template name="vis-radios">
									<xsl:with-param name="query_fragment" select="$query_fragment"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if
									test="count($nudsGroup/descendant::*[local-name()=$query_fragment or @xlink:role=$query_fragment]) &gt; 0">
									<xsl:call-template name="vis-radios">
										<xsl:with-param name="query_fragment" select="$query_fragment"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</span>
				</xsl:for-each>
			</div>

			<xsl:choose>
				<xsl:when test="$pipeline='analyze'">
					<h2>
						<xsl:text>3. </xsl:text>
						<xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards', $lang)"/>
						<span style="font-size:60%;margin-left:10px;">
							<a href="#filterHoards" class="showFilter" id="csv-filter">
								<xsl:value-of select="numishare:normalizeLabel('visualize_filter_list', $lang)"/>
							</a>
						</span>
					</h2>
					<div style="height:30px">
						<div class="ui-state-error ui-corner-all" id="csv-hoard-alert" style="display:none">
							<span class="ui-icon ui-icon-alert" style="float:left"/>
							<strong><xsl:value-of select="numishare:normalizeLabel('visualize_alert', $lang)"/>:</strong>
							<xsl:value-of select="numishare:normalizeLabel('visualize_error6', $lang)"/>
						</div>
					</div>
					<div class="filter-div" style="display:none">
						<b><xsl:value-of select="numishare:normalizeLabel('visualize_filter_query', $lang)"/>:</b>
						<span/>
						<a href="#" class="removeFilter">
							<xsl:value-of select="numishare:normalizeLabel('visualize_remove_filter', $lang)"/>
						</a>
					</div>
					<xsl:call-template name="get-hoards"/>
				</xsl:when>
				<xsl:otherwise>
					<h2>3. <xsl:value-of select="numishare:normalizeLabel('visualize_select_hoards_optional', $lang)"/></h2>
					<div style="height:30px">
						<div class="ui-state-error ui-corner-all" id="csv-hoard-alert" style="display:none">
							<span class="ui-icon ui-icon-alert" style="float:left"/>
							<strong><xsl:value-of select="numishare:normalizeLabel('visualize_alert', $lang)"/>:</strong>
							<xsl:value-of select="numishare:normalizeLabel('visualize_error7', $lang)"/>
						</div>
					</div>
					<xsl:call-template name="get-hoards"/>
				</xsl:otherwise>
			</xsl:choose>

			<div>
				<h3>
					<xsl:value-of select="numishare:normalizeLabel('visualize_optional_settings', $lang)"/>
					<span style="font-size:60%;margin-left:10px;">
						<a href="#" class="optional-button" id="csv-options">
							<xsl:value-of select="numishare:normalizeLabel('visualize_hide-show', $lang)"/>
						</a>
					</span>
				</h3>
				<div class="optional-div" style="display:none">
					<h4>
						<xsl:value-of select="numishare:normalizeLabel('visualize_exclude_certainty_codes', $lang)"/>
					</h4>
					<cinclude:include src="cocoon:/get_certainty_codes?exclude={$exclude}"/>
				</div>
			</div>
			<xsl:if test="$pipeline='display'">
				<input type="hidden" id="thisHoard" value="{$id}"/>
			</xsl:if>
			<input type="hidden" name="exclude" class="exclude-input" value=""/>
			<input type="hidden" name="compare" class="compare-input" value=""/>
			<br/>
			<input type="submit" value="{numishare:normalizeLabel('visualize_calculate', $lang)}" id="csv-submit"/>
		</form>
	</xsl:template>

	<xsl:template name="vis-checks">
		<xsl:param name="query_fragment"/>
		<xsl:choose>
			<xsl:when test="contains($calculate, $query_fragment)">
				<input type="checkbox" id="{$query_fragment}-checkbox" checked="checked" value="{$query_fragment}" class="calculate-checkbox"/>
			</xsl:when>
			<xsl:otherwise>
				<input type="checkbox" id="{$query_fragment}-checkbox" value="{$query_fragment}" class="calculate-checkbox"/>
			</xsl:otherwise>
		</xsl:choose>
		<label for="{$query_fragment}-checkbox">
			<xsl:value-of select="numishare:normalize_fields($query_fragment, $lang)"/>
		</label>
	</xsl:template>

	<xsl:template name="vis-radios">
		<xsl:param name="query_fragment"/>
		<input type="radio" name="calculate" id="{$query_fragment}-radio" value="{$query_fragment}" class="calculate-checkbox"/>
		<label for="{$query_fragment}-checkbox">
			<xsl:value-of select="numishare:normalize_fields($query_fragment, $lang)"/>
		</label>
	</xsl:template>

	<xsl:template name="get-hoards">
		<div class="compare-div">
			<cinclude:include src="cocoon:/get_hoards?compare={$compare}&amp;q=*&amp;ignore={$id}"/>
		</div>
	</xsl:template>

	<!-- ************** SEARCH FORM ************** -->
	<xsl:template name="search_forms">
		<div class="search-form">
			<p>To conduct a free text search select ‘Keyword’ on the drop-down menu above and enter the text for which you wish to search. The search allows
				wildcard searches with the * and ? characters and exact string matches by surrounding phrases by double quotes (like Google). <a
					href="http://lucene.apache.org/java/2_9_1/queryparsersyntax.html#Term%20Modifiers" target="_blank">See the Lucene query syntax</a>
				documentation for more information.</p>
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
				<xsl:if test="string($lang)">
					<input name="lang" type="hidden" value="{$lang}"/>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$pipeline='analyze'">
						<input type="submit" value="Filter" id="filterButton"/>
					</xsl:when>
					<xsl:when test="$pipeline='visualize'">
						<input type="submit" value="{numishare:normalizeLabel('visualize_add_query', $lang)}" id="search_buttom"/>
					</xsl:when>
					<xsl:otherwise>
						<input type="submit" value="{numishare:normalizeLabel('header_search', $lang)}" id="search_button"/>
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

	<!-- ************** SEARCH DROP-DOWN MENUS ************** -->
	<xsl:template name="search_options">
		<xsl:variable name="fields">
			<xsl:text>fulltext,recordId,authority_facet,coinType_facet,collection_facet,deity_facet,denomination_facet,department_facet,diameter_num,dynasty_facet,findspot_facet,issuer_facet,legend_text,obv_leg_text,rev_leg_text,manufacture_facet,material_facet,mint_facet,objectType_facet,portrait_facet,reference_text,region_facet,type_text,obv_type_text,rev_type_text,weight_num,year_num</xsl:text>
		</xsl:variable>

		<xsl:for-each select="tokenize($fields, ',')">
			<xsl:variable name="name" select="."/>
			<option value="{$name}" class="search_option">
				<xsl:value-of select="numishare:normalize_fields($name, $lang)"/>
			</option>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="measurementForm">
		<xsl:variable name="action">
			<xsl:choose>
				<xsl:when test="$pipeline='visualize'">#measurements</xsl:when>
				<xsl:when test="$pipeline='display'">
					<xsl:value-of select="concat('./', $id, '#charts')"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="measurements">axis,diameter,weight</xsl:variable>
		<xsl:variable name="chartTypes">
			<xsl:choose>
				<xsl:when test="$pipeline='display'">bar,column</xsl:when>
				<xsl:otherwise>bar,column,area,line,spline,areaspline</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="string($sparqlQuery)">
			<xsl:call-template name="measurementTable"/>
		</xsl:if>

		<form id="measurementsForm" action="{$action}" style="margin:20px">
			<div style="display:table;width:100%">
				<h3>1. <xsl:value-of select="numishare:normalizeLabel('visualize_select_measurement', $lang)"/></h3>
				<xsl:for-each select="tokenize($measurements, ',')">
					<span class="anOption">
						<input type="radio" name="measurement" value="{.}">
							<xsl:choose>
								<xsl:when test="$measurement = .">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:when>
								<xsl:when test=". = 'weight' and not(string($measurement))">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:when>
							</xsl:choose>
						</input>
						<label for="measurement-radio">
							<xsl:value-of select="numishare:regularize_node(., $lang)"/>
						</label>
					</span>
				</xsl:for-each>
			</div>

			<div style="display:table;width:100%">
				<h3>2. <xsl:value-of select="numishare:normalizeLabel('visualize_chart_type', $lang)"/></h3>
				<xsl:for-each select="tokenize($chartTypes, ',')">
					<span class="anOption">
						<input type="radio" name="chartType" value="{.}">
							<xsl:if test="$chartType = . or (.='column' and not(string($chartType)))">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
							<xsl:if test="not(number($duration)) and (.='line' or .='area' or .='areaspline' or .='spline')">
								<xsl:attribute name="disabled">disabled</xsl:attribute>
							</xsl:if>
						</input>
						<label for="chartType-radio">
							<xsl:value-of select="numishare:normalizeLabel(concat('chart_', .), $lang)"/>
						</label>
					</span>

				</xsl:for-each>
			</div>

			<xsl:choose>
				<xsl:when test="$pipeline='display'">
					<!-- create categories as a variable -->
					<xsl:variable name="typologicalCategories" as="element()*">
						<categories>
							<xsl:for-each
								select="//nuds:material[string(@xlink:href)]|//nuds:denomination[string(@xlink:href)]|//nuds:manufacture[string(@xlink:href)]|//nuds:persname[string(@xlink:href)]|//nuds:corpname[string(@xlink:href)]|//nuds:famname[string(@xlink:href)]|//nuds:geogname[string(@xlink:href)]">
								<xsl:sort select="local-name()"/>
								<xsl:variable name="href" select="@xlink:href"/>
								<xsl:variable name="value">
									<xsl:choose>
										<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
											<xsl:choose>
												<xsl:when test="string($rdf/*[@rdf:about=$href]/skos:prefLabel[@xml:lang=$lang][1])">
													<xsl:value-of select="$rdf/*[@rdf:about=$href]/skos:prefLabel[@xml:lang=$lang][1]"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="$rdf/*[@rdf:about=$href]/skos:prefLabel[@xml:lang='en'][1]"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<!-- if there is no text value and it points to nomisma.org, grab the prefLabel -->
											<xsl:choose>
												<xsl:when test="not(string(normalize-space(.))) and contains($href, 'nomisma.org')">
													<xsl:value-of select="$rdf/*[@rdf:about=$href]/skos:prefLabel[@xml:lang='en'][1]"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="."/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="name">
									<xsl:choose>
										<xsl:when test="string(@xlink:role)">
											<xsl:value-of select="@xlink:role"/>
										</xsl:when>
										<xsl:when test="string(@type)">
											<xsl:value-of select="@type"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="local-name()"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<category name="{$name}" href="{$href}" value="{$value}" query="{concat('nm:', $name, ' &lt;', $href, '&gt;')}"/>
							</xsl:for-each>
						</categories>
					</xsl:variable>
					<div style="display:table;width:100%">
						<h3>3. <xsl:value-of select="numishare:normalizeLabel('visualize_compare_category', $lang)"/></h3>
						<!-- create checkboxes for available facets -->
						<xsl:for-each select="$typologicalCategories//category">
							<span class="anOption">
								<xsl:variable name="query_fragment" select="@query"/>
								<xsl:choose>
									<xsl:when test="boolean(index-of($tokenized_sparqlQuery, $query_fragment)) = true()">
										<input type="checkbox" id="{@name}-checkbox" checked="checked" value="{$query_fragment}" class="weight-checkbox"/>
									</xsl:when>
									<xsl:otherwise>
										<input type="checkbox" id="{@name}-checkbox" value="{$query_fragment}" class="weight-checkbox"/>
									</xsl:otherwise>
								</xsl:choose>
								<label for="{@name}-checkbox">
									<xsl:value-of select="numishare:regularize_node(@name, $lang)"/>
									<xsl:text>: </xsl:text>
									<xsl:value-of select="@value"/>
								</label>
							</span>
						</xsl:for-each>
					</div>
					<div id="customSparqlQueryDiv">
						<h3>
							<xsl:text>4. </xsl:text>
							<xsl:value-of select="numishare:normalizeLabel('visualize_add_queries', $lang)"/>
							<span style="font-size:80%;margin-left:10px;">
								<a href="#sparqlBox" id="addSparqlQuery">+ <span><xsl:value-of select="numishare:normalizeLabel('visualize_add_new', $lang)"
										/></span></a>
							</span>
						</h3>
						<xsl:for-each select="$tokenized_sparqlQuery">
							<xsl:variable name="val" select="."/>
							<xsl:if test="not($typologicalCategories//category[@query=$val])">
								<div class="customSparqlQuery">
									<b><xsl:value-of select="numishare:normalizeLabel('visualize_query', $lang)"/>: </b>
									<span class="hr">
										<xsl:call-template name="sparqlLabel"/>
									</span>
									<span class="mr">
										<xsl:value-of select="."/>
									</span>
									<a href="#" class="removeQuery">
										<xsl:value-of select="numishare:normalizeLabel('visualize_remove_query', $lang)"/>
									</a>
								</div>
							</xsl:if>
						</xsl:for-each>
					</div>
				</xsl:when>
				<xsl:when test="$pipeline='visualize'">
					<div id="customSparqlQueryDiv">
						<h3>
							<xsl:text>3. </xsl:text>
							<xsl:value-of select="numishare:normalizeLabel('visualize_add_queries', $lang)"/>
							<span style="font-size:80%;margin-left:10px;">
								<a href="#sparqlBox" id="addSparqlQuery">+ <span><xsl:value-of select="numishare:normalizeLabel('visualize_add_new', $lang)"
										/></span></a>
							</span>
						</h3>
						<xsl:for-each select="$tokenized_sparqlQuery">
							<div class="customSparqlQuery">
								<b><xsl:value-of select="numishare:normalizeLabel('visualize_query', $lang)"/>: </b>
								<span class="hr">
									<xsl:call-template name="sparqlLabel"/>
								</span>
								<span class="mr">
									<xsl:value-of select="."/>
								</span>
								<a href="#" class="removeQuery">
									<xsl:value-of select="numishare:normalizeLabel('visualize_remove_query', $lang)"/>
								</a>
							</div>
						</xsl:for-each>
					</div>
				</xsl:when>
			</xsl:choose>

			<!-- only display duration in visualize page: doesn't work properly from coin type comparison -->
			<xsl:if test="$pipeline='visualize'">
				<div style="display:table;width:100%">
					<div style="height:30px">
						<div class="ui-state-error ui-corner-all" id="measurementsForm-alert" style="display:none">
							<span class="ui-icon ui-icon-alert" style="float:left"/>
							<strong><xsl:value-of select="numishare:normalizeLabel('visualize_alert', $lang)"/>:</strong>
							<span class="validationError"/>
						</div>
					</div>
					<h3>
						<xsl:choose>
							<xsl:when test="$pipeline='display'">5</xsl:when>
							<xsl:when test="$pipeline='visualize'">4</xsl:when>
						</xsl:choose>
						<xsl:text>. </xsl:text>
						<xsl:value-of select="numishare:normalizeLabel('visualize_arrange', $lang)"/>
					</h3>
					<h4>
						<xsl:value-of select="numishare:normalizeLabel('visualize_interval', $lang)"/>
					</h4>
					<select name="interval">
						<option value="">
							<xsl:value-of select="numishare:normalizeLabel('results_select', $lang)"/>
						</option>
						<option value="5">
							<xsl:if test="$interval='5'">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>5</xsl:text>
						</option>
						<option value="10">
							<xsl:if test="$interval='10'">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>10</xsl:text>
						</option>
						<option value="20">
							<xsl:if test="$interval='20'">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>20</xsl:text>
						</option>
						<option value="25">
							<xsl:if test="$interval='25'">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>25</xsl:text>
						</option>
						<option value="50">
							<xsl:if test="$interval='50'">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>50</xsl:text>
						</option>
					</select>

					<h4>
						<xsl:value-of select="numishare:normalizeLabel('visualize_duration', $lang)"/>
					</h4>
					<xsl:value-of select="numishare:normalize_fields('fromDate', $lang)"/>
					<xsl:text>:</xsl:text>
					<input type="text" class="from_date" name="fromDate" value="{if (string($fromDate)) then abs(number($fromDate)) else ''}"/>
					<select class="from_era">
						<option value="minus">
							<xsl:if test="number($fromDate) &lt; 0">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>B.C.</xsl:text>
						</option>
						<option value="">
							<xsl:if test="number($fromDate) &gt; 0 or not(string($fromDate))">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>A.D.</xsl:text>
						</option>
					</select>
					<xsl:value-of select="numishare:normalize_fields('toDate', $lang)"/>
					<xsl:text>: </xsl:text>
					<input type="text" class="to_date" name="toDate" value="{if (string($toDate)) then abs(number($toDate)) else ''}"/>
					<select class="to_era">
						<option value="minus">
							<xsl:if test="number($toDate) &lt; 0">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>B.C.</xsl:text>
						</option>
						<option value="">
							<xsl:if test="number($toDate) &gt; 0 or not(string($toDate))">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>A.D.</xsl:text>
						</option>
					</select>
				</div>
			</xsl:if>


			<input type="hidden" name="sparqlQuery" id="sparqlQuery" value=""/>
			<xsl:if test="string($lang)">
				<input type="hidden" name="lang" value="{$lang}"/>
			</xsl:if>
			<br/>
			<input type="submit" value="{numishare:normalizeLabel('visualize_generate', $lang)}" id="submit-measurements"/>
		</form>

		<div style="display:none">
			<div id="sparqlBox" class="popupQuery">
				<h3>
					<xsl:value-of select="numishare:normalizeLabel('visualize_add_query', $lang)"/>
				</h3>
				<p>
					<xsl:value-of select="numishare:normalizeLabel('visualize_add_query_desc', $lang)"/>
				</p>
				<xsl:call-template name="sparql_form"/>
			</div>
		</div>

		<!--errors -->
		<div style="display:none">
			<span>errors</span>
			<span id="visualize_error1">
				<xsl:value-of select="numishare:normalizeLabel('visualize_error1', $lang)"/>
			</span>
			<span id="visualize_error2">
				<xsl:value-of select="numishare:normalizeLabel('visualize_error2', $lang)"/>
			</span>
		</div>

		<span id="pipeline" style="display:none">
			<xsl:value-of select="$pipeline"/>
		</span>
	</xsl:template>

	<!-- ************** SEARCH INTERFACE FOR CUSTOM WEIGHT QUERIES FROM SPARQL **************** -->
	<xsl:template name="sparql_form">
		<div class="queryGroup">
			<div style="height:30px">
				<div class="ui-state-error ui-corner-all" id="sparqlForm-alert" style="display:none">
					<span class="ui-icon ui-icon-alert" style="float:left"/>
					<strong><xsl:value-of select="numishare:normalizeLabel('visualize_alert', $lang)"/>:</strong>
					<span class="validationError"/>
				</div>
			</div>
			<form id="sparqlForm" method="GET">
				<div id="sparqlInputContainer">
					<div class="searchItemTemplate">
						<select class="sparql_facets">
							<option>
								<xsl:value-of select="numishare:normalizeLabel('results_select', $lang)"/>
							</option>
							<xsl:call-template name="sparql_search_options"/>
						</select>
						<div class="option_container" style="display:inline"/>
						<a class="gateTypeBtn" href="#">add »</a>
					</div>
				</div>
				<input name="q" id="q_input" type="hidden"/>
				<xsl:if test="string($lang)">
					<input name="lang" type="hidden" value="{$lang}"/>
				</xsl:if>
				<input type="submit" value="{numishare:normalizeLabel('visualize_add_query', $lang)}"/>
			</form>
		</div>

		<div id="sparqlItemTemplate" class="searchItemTemplate">
			<select class="sparql_facets">
				<option>
					<xsl:value-of select="numishare:normalizeLabel('results_select', $lang)"/>
				</option>
				<xsl:call-template name="sparql_search_options"/>
			</select>
			<div style="display:inline;" class="option_container"/>
			<a class="gateTypeBtn" href="#">add »</a>
			<a class="removeBtn" href="#" style="display:none;">« remove</a>
		</div>

		<span id="dateTemplate">
			<xsl:value-of select="numishare:normalize_fields('fromDate', $lang)"/>
			<xsl:text>:</xsl:text>
			<input type="text" class="from_date" name="fromDate"/>
			<select class="from_era">
				<option value="minus">B.C.</option>
				<option value="" selected="selected">A.D.</option>
			</select>
			<xsl:value-of select="numishare:normalize_fields('toDate', $lang)"/>
			<xsl:text>: </xsl:text>
			<input type="text" class="to_date" name="toDate"/>
			<select class="to_era">
				<option value="minus">B.C.</option>
				<option value="" selected="selected">A.D.</option>
			</select>
			<!-- empty, unused input, necessary for generalized validation -->
			<div style="display:none">
				<select name="interval">
					<option value="1">1</option>
				</select>
			</div>
		</span>
	</xsl:template>

	<xsl:template name="sparql_search_options">
		<xsl:variable name="fields">
			<xsl:text>authority,date,deity,denomination,issuer,manufacture,material,mint,region</xsl:text>
		</xsl:variable>
		<xsl:for-each select="tokenize($fields, ',')">
			<xsl:variable name="name" select="."/>
			<option value="{if ($name = 'date') then 'date' else concat('nm:', $name)}" class="search_option">
				<xsl:value-of select="numishare:normalize_fields($name, $lang)"/>
			</option>
		</xsl:for-each>
	</xsl:template>

	<!-- use the Nomisma getLabel API to resolve the label -->
	<xsl:template name="sparqlLabel">
		<xsl:variable name="hrefs" as="item()*">
			<xsl:analyze-string select="." regex="&lt;([^>]+)&gt;">
				<xsl:matching-substring>
					<xsl:value-of select="document(concat('http://nomisma.org/apis/getLabel?uri=', regex-group(1), '&amp;lang=', $lang))/response"/>
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:variable>
		<xsl:variable name="dates" as="item()*">
			<xsl:analyze-string select="." regex="&#x022;(-?\d{{4}})&#x022;">
				<xsl:matching-substring>
					<xsl:value-of select="numishare:normalizeYear(number(translate(., '&#x022;', '')))"/>
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:variable>

		<xsl:value-of select="string-join($hrefs, '/')"/>

		<xsl:if test="count($hrefs) &gt; 0 and count($dates) &gt; 0">
			<xsl:text>, </xsl:text>
		</xsl:if>

		<!-- display year range, if applicable -->
		<xsl:value-of select="string-join($dates, '-')"/>
	</xsl:template>

	<!-- ************** GENERATE TABLE FROM PIPELINES THAT EXECUTE SPARQL QUERIES ************** -->
	<xsl:template name="measurementTable">
		<xsl:variable name="iterations" select="ceiling(number($duration) div number($interval))"/>

		<div id="weight-container" style="min-width: 400px; height: 400px; margin: 20px auto"/>
		<!-- class="measurementTable"-->
		<table class="measurementTable">
			<caption>
				<xsl:value-of select="numishare:regularize_node($measurement, $lang)"/>
			</caption>
			<thead>
				<tr>
					<!-- create new table row for basic comparison.  or create a cell for each comparison and row for interval comparison -->
					<xsl:choose>
						<xsl:when test="$duration castable as xs:integer">
							<th id="measurementUnits">
								<xsl:choose>
									<xsl:when test="$measurement='diameter'">mm</xsl:when>
									<xsl:when test="$measurement='weight'">g</xsl:when>
								</xsl:choose>
							</th>
							<!-- generate th -->
							<xsl:for-each select="$tokenized_sparqlQuery">
								<th>
									<xsl:call-template name="sparqlLabel"/>
								</th>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<th/>
							<th id="measurementUnits">
								<xsl:choose>visualize_arrange <xsl:when test="$measurement='diameter'">mm</xsl:when>
									<xsl:when test="$measurement='weight'">g</xsl:when>
								</xsl:choose>
							</th>
						</xsl:otherwise>
					</xsl:choose>
				</tr>
			</thead>
			<tbody>
				<!-- only show current coin type measurement in display pipeline -->
				<xsl:if test="$pipeline='display'">
					<tr>
						<th>
							<xsl:value-of select="$id"/>
						</th>
						<td>
							<cinclude:include
								src="cocoon:/widget?constraints={encode-for-uri(concat('nm:type_series_item &lt;http://numismatics.org/ocre/id/', $id, '&gt;'))}&amp;template=avgMeasurement&amp;measurement={$measurement}"
							/>
						</td>
					</tr>
				</xsl:if>

				<!-- create new table row for basic comparison.  or create a cell for each comparison and row for interval comparison -->
				<xsl:choose>
					<xsl:when test="$duration castable as xs:integer">
						<xsl:call-template name="processInterval">
							<xsl:with-param name="start">1</xsl:with-param>
							<xsl:with-param name="iterations" select="$iterations"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$tokenized_sparqlQuery">
							<tr>
								<th>
									<xsl:call-template name="sparqlLabel"/>
								</th>
								<td>
									<cinclude:include
										src="cocoon:/widget?constraints={encode-for-uri(concat('dcterms:isPartOf &lt;http://nomisma.org/id/ric&gt; AND ', .))}&amp;template=avgMeasurement&amp;measurement={$measurement}"
									/>
								</td>
							</tr>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template name="processInterval">
		<xsl:param name="start"/>
		<xsl:param name="iterations"/>

		<xsl:variable name="from">
			<xsl:choose>
				<xsl:when test="((number($start) - 1) * number($interval)) + number($fromDate) = 0">
					<xsl:text>0001</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="format-number(((number($start) - 1) * number($interval)) + number($fromDate), '0000')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="to">
			<xsl:choose>
				<xsl:when test="((number($start) * number($interval)) + number($fromDate)) = 0">
					<xsl:text>-0001</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="((number($start) * number($interval)) + number($fromDate)) &lt; number($toDate)">
							<xsl:value-of select="format-number((number($start) * number($interval)) + number($fromDate), '0000')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="format-number(number($toDate), '0000')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<tr>
			<th>
				<xsl:value-of select="number($from)"/>/<xsl:value-of select="number($to)"/>
			</th>
			<xsl:for-each select="$tokenized_sparqlQuery">
				<xsl:variable name="hrefs" as="item()*">
					<xsl:analyze-string select="." regex="&lt;([^>]+)&gt;">
						<xsl:matching-substring>
							<xsl:value-of select="document(concat('http://nomisma.org/apis/getLabel?uri=', regex-group(1), '&amp;lang=', $lang))/response"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:variable>
				<xsl:variable name="dates" as="item()*">
					<xsl:analyze-string select="." regex="&#x022;(-?\d{{4}})&#x022;">
						<xsl:matching-substring>
							<xsl:value-of select="numishare:normalizeYear(number(translate(., '&#x022;', '')))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:variable>

				<td>
					<xsl:variable name="filter">
						<xsl:text>nm:end_date ?date FILTER ( ?date &gt;= "</xsl:text>
						<xsl:value-of select="$from"/>
						<xsl:text>"^^xs:gYear \\and ?date &lt; "</xsl:text>
						<xsl:value-of select="$to"/>
						<xsl:text>"^^xs:gYear )</xsl:text>
					</xsl:variable>
					<!--<xsl:value-of select="encode-for-uri(concat('dcterms:isPartOf &lt;http://nomisma.org/id/ric&gt; AND ', ., ' AND ', $filter))"/>-->
					<cinclude:include
						src="cocoon:/widget?constraints={encode-for-uri(concat('dcterms:isPartOf &lt;http://nomisma.org/id/ric&gt; AND ', ., ' AND ', $filter))}&amp;template=avgMeasurement&amp;measurement={$measurement}"
					/>
				</td>
			</xsl:for-each>
		</tr>
		<xsl:if test="$start &lt; $iterations">
			<xsl:call-template name="processInterval">
				<xsl:with-param name="start" select="number($start) + 1"/>
				<xsl:with-param name="iterations" select="$iterations"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- ************** RE-ASSEMBLE CATEGORY SOLR FIELDS INTO HUMAN-READABLE CATEGORY ************** -->
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

	<!-- ************** PROCESS GROUP OF SPARQL RESULTS FROM METIS TO DISPLAY IMAGES ************** -->
	<xsl:template name="numishare:renderSparqlResults">
		<xsl:param name="group"/>
		<xsl:variable name="count" select="count($group/descendant::res:result)"/>
		<xsl:variable name="coin-count" select="count($group/descendant::res:result[contains(res:binding[@name='objectType']/res:uri, 'coin')])"/>
		<xsl:variable name="hoard-count" select="count($group/descendant::res:result[contains(res:binding[@name='objectType']/res:uri, 'hoard')])"/>


		<!--<xsl:variable name="count" select="$group/@hoards + $group/@coins"/>
			<xsl:variable name="coin-count" select="$group/@coins"/>
			<xsl:variable name="hoard-count" select="$group/@hoards"/>-->

		<!-- get images -->
		<xsl:apply-templates select="$group/res:result[res:binding[contains(@name, 'rev') or contains(@name, 'obv')]]" mode="results">
			<xsl:with-param name="id" select="tokenize($url, '/')[last()]"/>
		</xsl:apply-templates>
		<!-- object count -->
		<xsl:if test="$count &gt; 0">
			<br/>
			<xsl:if test="$coin-count &gt; 0">
				<xsl:value-of select="$coin-count"/>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="$coin-count = 1">
						<xsl:value-of select="numishare:normalizeLabel('results_coin', $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="numishare:normalizeLabel('results_coins', $lang)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="$coin-count &gt; 0 and $hoard-count &gt; 0">
				<xsl:text> </xsl:text>
				<xsl:value-of select="numishare:normalizeLabel('results_and', $lang)"/>
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:if test="$hoard-count &gt; 0">
				<xsl:value-of select="$hoard-count"/>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="$hoard-count = 1">
						<xsl:value-of select="numishare:normalizeLabel('results_hoard', $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="numishare:normalizeLabel('results_hoards', $lang)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="res:result" mode="results">
		<xsl:variable name="position" select="position()"/>
		<!-- obverse -->
		<xsl:choose>
			<xsl:when test="string(res:binding[@name='obvRef']/res:uri) and string(res:binding[@name='obvThumb']/res:uri)">
				<a class="thumbImage" rel="gallery" href="{res:binding[@name='obvRef']/res:uri}"
					title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{res:binding[@name='obvThumb']/res:uri}"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(res:binding[@name='obvRef']/res:uri)) and string(res:binding[@name='obvThumb']/res:uri)">
				<img src="{res:binding[@name='obvThumb']/res:uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
				</img>
			</xsl:when>
			<xsl:when test="string(res:binding[@name='obvRef']/res:uri) and not(string(res:binding[@name='obvThumb']/res:uri))">
				<a class="thumbImage" rel="gallery" href="{res:binding[@name='obvRef']/res:uri}"
					title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
					<img src="{res:binding[@name='obvRef']/res:uri}" style="max-width:120px">
						<xsl:if test="$position &gt; 1">
							<xsl:attribute name="style">display:none</xsl:attribute>
						</xsl:if>
					</img>
				</a>
			</xsl:when>
		</xsl:choose>
		<!-- reverse-->
		<xsl:choose>
			<xsl:when test="string(res:binding[@name='revRef']/res:uri) and string(res:binding[@name='revThumb']/res:uri)">
				<a class="thumbImage" rel="gallery" href="{res:binding[@name='revRef']/res:uri}"
					title="Reverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{res:binding[@name='revThumb']/res:uri}"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(res:binding[@name='revRef']/res:uri)) and string(res:binding[@name='revThumb']/res:uri)">
				<img src="{res:binding[@name='revThumb']/res:uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
				</img>
			</xsl:when>
			<xsl:when test="string(res:binding[@name='revRef']/res:uri) and not(string(res:binding[@name='revThumb']/res:uri))">
				<a class="thumbImage" rel="gallery" href="{res:binding[@name='revRef']/res:uri}"
					title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
					<img src="{res:binding[@name='revRef']/res:uri}" style="max-width:120px">
						<xsl:if test="$position &gt; 1">
							<xsl:attribute name="style">display:none</xsl:attribute>
						</xsl:if>
					</img>
				</a>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- ************** PROCESS MODS RECORD INTO CHICAGO MANUAL OF STYLE CITATION ************** -->
	<xsl:template name="mods-citation">
		<xsl:apply-templates select="mods:modsCollection"/>
	</xsl:template>

	<xsl:template match="mods:modsCollection">
		<xsl:apply-templates select="mods:mods"/>
	</xsl:template>

	<xsl:template match="mods:mods">
		<!-- name -->
		<xsl:for-each select="mods:name[@type='personal']">
			<xsl:choose>
				<xsl:when test="position() = 1">
					<xsl:value-of select="mods:namePart[@type='family']"/>
					<xsl:text>, </xsl:text>
					<xsl:value-of select="mods:namePart[@type='given']"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- create separator -->
					<xsl:choose>
						<xsl:when test="position()=last()"> and </xsl:when>
						<xsl:otherwise>, </xsl:otherwise>
					</xsl:choose>

					<xsl:value-of select="mods:namePart[@type='given']"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mods:namePart[@type='family']"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="position()=last()">
				<xsl:text>. </xsl:text>
			</xsl:if>
		</xsl:for-each>

		<!-- title -->
		<xsl:choose>
			<!-- when it is a journal article -->
			<xsl:when test="mods:relatedItem[@type='host']">
				<!-- article title -->
				<xsl:text>"</xsl:text>
				<xsl:apply-templates select="mods:titleInfo"/>
				<xsl:text>." </xsl:text>
				<!-- journal title and publication -->
				<i>
					<xsl:apply-templates select="mods:relatedItem[@type='host']/mods:titleInfo"/>
				</i>
				<xsl:apply-templates select="mods:part"/>
				<xsl:text>.</xsl:text>
			</xsl:when>
			<!-- when it is a monograph -->
			<xsl:otherwise>
				<i>
					<xsl:apply-templates select="mods:titleInfo"/>
				</i>
				<xsl:text>. </xsl:text>
				<xsl:apply-templates select="mods:originInfo"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:titleInfo">
		<xsl:value-of select="mods:title"/>
		<xsl:if test="mods:subTitle">
			<xsl:text>: </xsl:text>
			<xsl:value-of select="mods:subTitle"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="mods:part">
		<xsl:if test="mods:detail[@type='volume']">
			<xsl:text> </xsl:text>
			<xsl:value-of select="mods:detail[@type='volume']/mods:number"/>
		</xsl:if>
		<xsl:if test="mods:date">
			<xsl:text> (</xsl:text>
			<xsl:value-of select="mods:date"/>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="mods:extent[@unit='page']"/>
	</xsl:template>

	<xsl:template match="mods:extent[@unit='page']">
		<xsl:text>: </xsl:text>
		<xsl:value-of select="mods:start"/>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="mods:end"/>
	</xsl:template>

	<xsl:template match="mods:originInfo">
		<xsl:if test="mods:place/mods:placeTerm">
			<xsl:value-of select="mods:place/mods:placeTerm"/>
			<xsl:text>: </xsl:text>
		</xsl:if>
		<xsl:if test="mods:publisher">
			<xsl:value-of select="mods:publisher"/>
		</xsl:if>
		<xsl:if test="mods:dateIssued">
			<xsl:text>, </xsl:text>
			<xsl:value-of select="mods:dateIssued"/>
		</xsl:if>
		<xsl:text>.</xsl:text>
	</xsl:template>
</xsl:stylesheet>
