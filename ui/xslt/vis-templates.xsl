<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:org="http://www.w3.org/ns/org#" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" exclude-result-prefixes="#all" version="2.0">

	<!-- distribution params -->
	<xsl:param name="dist" select="doc('input:request')/request/parameters/parameter[name = 'dist']/value"/>
	<xsl:param name="numericType" select="doc('input:request')/request/parameters/parameter[name = 'type']/value"/>
	<!-- query params -->
	<xsl:param name="compare" select="doc('input:request')/request/parameters/parameter[name = 'compare']/value"/>
	<!--<xsl:param name="filter" select="doc('input:request')/request/parameters/parameter[name = 'filter']/value"/>-->
	<!-- metrical analysis params -->
	<xsl:param name="measurement" select="doc('input:request')/request/parameters/parameter[name = 'measurement']/value"/>
	<xsl:param name="from" select="doc('input:request')/request/parameters/parameter[name = 'from']/value"/>
	<xsl:param name="to" select="doc('input:request')/request/parameters/parameter[name = 'to']/value"/>
	<xsl:param name="interval" select="doc('input:request')/request/parameters/parameter[name = 'interval']/value"/>
	<xsl:param name="analysisType" select="doc('input:request')/request/parameters/parameter[name = 'analysisType']/value"/>

	<!-- ********** VISUALIZATION TEMPLATES *********** -->
	<xsl:template name="metrical-form">
		<xsl:param name="mode"/>
		<xsl:if test="$mode = 'record'">
			<hr/>
		</xsl:if>

		<h3>
			<xsl:value-of select="numishare:normalizeLabel('visualize_measurement', $lang)"/>
		</h3>

		<div>
			<!-- display chart div when applicable, with additional filtering options -->
			<xsl:choose>
				<xsl:when test="$mode = 'page'">
					<xsl:if test="string($measurement) and count($compare) &gt; 0">
						<xsl:call-template name="chart">
							<xsl:with-param name="hidden" select="false()" as="xs:boolean"/>
							<xsl:with-param name="interface">metrical</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$mode = 'record'">
					<xsl:call-template name="chart">
						<xsl:with-param name="hidden" select="true()" as="xs:boolean"/>
						<xsl:with-param name="interface">metrical</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
			<form role="form" id="metricalForm" class="quant-form" method="get">
				<xsl:attribute name="action">
					<xsl:choose>
						<xsl:when test="$mode = 'page'">
							<xsl:value-of select="concat($display_path, 'visualize/metrical')"/>
						</xsl:when>
						<xsl:when test="$mode = 'record'">
							<xsl:value-of select="concat($objectUri, '#metrical')"/>
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>

				<!-- only include filter in the ID page -->
				<xsl:if test="$mode = 'record'">
					<input type="hidden" name="filter"/>
				</xsl:if>

				<div class="form-group">
					<h4>Analysis Type</h4>
					<input type="radio" name="analysisType" value="average">
						<xsl:if test="not(string($analysisType)) or $analysisType = 'average'">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
						<xsl:text>Average</xsl:text>
					</input>
					<br/>
					<input type="radio" name="analysisType" value="stdDev" disabled="disabled">
						<xsl:if test="$analysisType = 'stdDev'">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
						<xsl:text>Standard Deviation</xsl:text>
					</input>
				</div>

				<xsl:call-template name="measurement-categories"/>

				<xsl:call-template name="dist-compare-template">
					<xsl:with-param name="mode" select="$mode"/>
				</xsl:call-template>

				<!-- display optional date range last, but only for the visualization page (ranges not much use for specific types) -->
				<xsl:if test="$mode = 'page'">
					<div class="form-group">
						<h4>
							<xsl:value-of select="numishare:normalize_fields('dateRange', $lang)"/>
						</h4>
						<p>You may select both a start and end date to display change in measurement(s) over time in the form of a line chart. An average will
							be taken for the selected interval over the entire duration. You may automatically generate this date range based on the queries
							above. Note that the automatic date range applies only to typologies for which there is at least one physical specimen where the
							selected measurement applies.</p>

						<div class="alert alert-box alert-danger measurementRange-alert hidden">
							<span class="glyphicon glyphicon-exclamation-sign"/>
							<strong><xsl:value-of select="numishare:normalizeLabel('visualize_alert', $lang)"/>:</strong> Inputted date range is invalid and/or
							interval is not set.</div>

						<div class="alert alert-box alert-danger interval-alert hidden">
							<span class="glyphicon glyphicon-exclamation-sign"/>
							<strong><xsl:value-of select="numishare:normalizeLabel('visualize_alert', $lang)"/>:</strong> An interval of 1 year can only be
							applied to a maximum range of 30 years due to performance issues regarding iterative queries.</div>

						<div class="getDateRange-container hidden" style="margin-bottom:15px">
							<button class="btn btn-default" id="getDateRange">Calculate Range</button>
							<span class="hidden text-muted"><img src="{$include_path}/images/ajax-loader.gif" alt="loading"/> Automatically calculating date
								range based on existing queries.</span>
						</div>

						<div class="form-inline" id="measurementRange-container">
							<input type="number" class="form-control year" id="fromYear" min="1" step="1"
								placeholder="{numishare:regularize_node('year', $lang)}">
								<xsl:if test="$from castable as xs:integer">
									<xsl:attribute name="value" select="abs(xs:integer($from))"/>
								</xsl:if>
							</input>
							<select class="form-control era" id="fromEra">
								<option value="bc">
									<xsl:if test="$from castable as xs:integer">
										<xsl:if test="xs:integer($from) &lt; 0">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
									</xsl:if>
									<xsl:text>B.C.</xsl:text>
								</option>
								<option value="ad">
									<xsl:if test="$from castable as xs:integer">
										<xsl:if test="xs:integer($from) &gt; 0">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
									</xsl:if>
									<xsl:text>A.D.</xsl:text>
								</option>
							</select>
							<xsl:text> to </xsl:text>
							<input type="number" class="form-control year" id="toYear" min="1" step="1" placeholder="{numishare:regularize_node('year', $lang)}">
								<xsl:if test="$to castable as xs:integer">
									<xsl:attribute name="value" select="abs(xs:integer($to))"/>
								</xsl:if>
							</input>
							<select class="form-control era" id="toEra">
								<option value="bc">
									<xsl:if test="$to castable as xs:integer">
										<xsl:if test="xs:integer($to) &lt; 0">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
									</xsl:if>
									<xsl:text>B.C.</xsl:text>
								</option>
								<option value="ad">
									<xsl:if test="$to castable as xs:integer">
										<xsl:if test="xs:integer($to) &gt; 0">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
									</xsl:if>
									<xsl:text>A.D.</xsl:text>
								</option>
							</select>

							<label>
								<xsl:value-of select="numishare:normalizeLabel('visualize_interval', $lang)"/>
							</label>
							<select class="form-control interval" id="interval">
								<option>Select...</option>
								<option value="1">
									<xsl:if test="$interval castable as xs:integer">
										<xsl:if test="xs:integer($interval) = 1">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
									</xsl:if>
									<xsl:text>1</xsl:text>
								</option>
								<option value="5">
									<xsl:if test="$interval castable as xs:integer">
										<xsl:if test="xs:integer($interval) = 5">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
									</xsl:if>
									<xsl:text>5</xsl:text>
								</option>
								<option value="10">
									<xsl:if test="$to castable as xs:integer">
										<xsl:if test="xs:integer($interval) = 10">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
									</xsl:if>
									<xsl:text>10</xsl:text>
								</option>
							</select>
						</div>
					</div>
				</xsl:if>

				<xsl:if test="string($langParam)">
					<input type="hidden" name="lang" value="{$lang}"/>
				</xsl:if>

				<input type="submit" value="{numishare:normalizeLabel('visualize_generate', $lang)}" class="btn btn-default visualize-submit"
					disabled="disabled"/>
			</form>
		</div>
	</xsl:template>

	<xsl:template name="distribution-form">
		<xsl:param name="mode"/>

		<!--<xsl:if test="$mode = 'record'">
			<hr/>
		</xsl:if>-->
		<h3>
			<xsl:value-of select="numishare:normalizeLabel('visualize_typological', $lang)"/>
			<xsl:if test="$mode = 'record'">
				<xsl:call-template name="toggle-button">
					<xsl:with-param name="form">distribution</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</h3>

		<div>
			<xsl:if test="$mode = 'record'">
				<xsl:attribute name="id">distribution</xsl:attribute>
				<xsl:attribute name="style">display:none</xsl:attribute>
			</xsl:if>

			<!-- display chart div when applicable, with additional filtering options -->
			<xsl:choose>
				<xsl:when test="$mode = 'page'">
					<xsl:if test="string($dist) and count($compare) &gt; 0">
						<xsl:call-template name="chart">
							<xsl:with-param name="hidden" select="false()" as="xs:boolean"/>
							<xsl:with-param name="interface">distribution</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$mode = 'record'">
					<xsl:call-template name="chart">
						<xsl:with-param name="hidden" select="true()" as="xs:boolean"/>
						<xsl:with-param name="interface">distribution</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>

			<form role="form" id="distributionForm" class="quant-form" method="get">
				<xsl:attribute name="action">
					<xsl:choose>
						<xsl:when test="$mode = 'page'">
							<xsl:value-of select="concat($display_path, 'visualize/distribution')"/>
						</xsl:when>
						<xsl:when test="$mode = 'record'">
							<xsl:value-of select="concat($display_path, 'id/', $objectUri, '#quant')"/>
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>

				<xsl:call-template name="dist-categories"/>

				<div class="form-group">
					<h4>Numeric response type</h4>
					<input type="radio" name="type" value="percentage">
						<xsl:if test="not(string($numericType)) or $numericType = 'percentage'">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="numishare:normalizeLabel('numeric_percentage', $lang)"/>
					</input>
					<br/>
					<input type="radio" name="type" value="count">
						<xsl:if test="$numericType = 'count'">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
					</input>
				</div>

				<xsl:call-template name="dist-compare-template">
					<xsl:with-param name="mode" select="$mode"/>
				</xsl:call-template>

				<xsl:if test="string($langParam)">
					<input type="hidden" name="lang" value="{$lang}"/>
				</xsl:if>

				<input type="submit" value="{numishare:normalizeLabel('visualize_generate', $lang)}" class="btn btn-default visualize-submit"
					disabled="disabled"/>
			</form>
		</div>
	</xsl:template>

	<xsl:template name="chart">
		<xsl:param name="hidden"/>
		<xsl:param name="interface"/>

		<xsl:variable name="api" select="
				if ($interface = 'metrical') then
					'getMetrical'
				else
					'getDistribution'"/>

		<div>
			<xsl:choose>
				<xsl:when test="$hidden = true()">
					<xsl:attribute name="class">hidden chart-container</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">chart-container</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>

			<div id="{$interface}-chart"/>

			<!-- only display model-generated link when there are URL params (distribution page) -->
			<div style="margin-bottom:10px;" class="control-row text-center">
				<xsl:choose>
					<xsl:when test="$interface = 'distribution'">
						<p>The chart is limited to 100 results. For the full distribution, please download the CSV.</p>
					</xsl:when>
					<xsl:when test="$interface = 'metrical'">
						<!--<p>A value of 0 means that there is no measurement data for the given period. It is not necessarily indicative of a gap in
							production.</p>-->
					</xsl:when>
				</xsl:choose>

				<xsl:choose>
					<xsl:when test="$hidden = false()">
						<xsl:variable name="queryParams" as="element()*">
							<params>
								<xsl:if test="string($dist)">
									<param>
										<xsl:value-of select="concat('dist=', $dist)"/>
									</param>
								</xsl:if>
								<xsl:if test="string($measurement)">
									<param>
										<xsl:value-of select="concat('measurement=', $measurement)"/>
									</param>
								</xsl:if>
								<xsl:if test="string($from)">
									<param>
										<xsl:value-of select="concat('from=', $from)"/>
									</param>
								</xsl:if>
								<xsl:if test="string($to)">
									<param>
										<xsl:value-of select="concat('to=', $to)"/>
									</param>
								</xsl:if>
								<xsl:if test="string($interval)">
									<param>
										<xsl:value-of select="concat('interval=', $interval)"/>
									</param>
								</xsl:if>
								<xsl:if test="string($numericType)">
									<param>
										<xsl:value-of select="concat('type=', $numericType)"/>
									</param>
								</xsl:if>
								<xsl:if test="string($analysisType)">
									<param>
										<xsl:value-of select="concat('analysisType=', $analysisType)"/>
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

						<a href="{$display_path}visualize/{$interface}" title="Bookmark" class="btn btn-primary">
							<span class="glyphicon glyphicon-erase"/>Clear</a>

						<a href="{$display_path}apis/{$api}?{string-join($queryParams/*, '&amp;')}" title="Download CSV" class="btn btn-primary">
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

	</xsl:template>

	<xsl:template name="dist-categories">

		<div class="form-group">
			<h4>
				<xsl:value-of select="numishare:normalizeLabel('visualize_categories', $lang)"/>
			</h4>

			<xsl:variable name="properties" as="element()*">
				<properties>
					<prop value="authPerson" class="foaf:Person"/>
					<prop value="authCorp" class="foaf:Organization"/>
					<prop value="nmo:hasStatedAuthority" class="foaf:Person|foaf:Organization"/>
					<prop value="deity" class=""/>
					<prop value="nmo:hasDenomination" class="nmo:Denomination"/>
					<prop value="nmo:hasIssuer" class="foaf:Person|foaf:Organization"/>
					<prop value="nmo:hasManufacture" class="nmo:Manufacture"/>
					<prop value="nmo:hasMaterial" class="nmo:Material"/>
					<prop value="nmo:hasMint" class="nmo:Mint"/>
					<prop value="nmo:representsObjectType" class="nmo:ObjectType"/>
					<prop value="portrait" class=""/>
					<!--<prop value="region" class="nmo:Region">Region</prop>-->
				</properties>
			</xsl:variable>

			<p>Select a category below to generate a graph showing the quantitative distribution for the following queries. The distribution is based on coin
				type data aggregated into Nomisma.</p>
			<select name="dist" class="form-control" id="categorySelect">
				<option value="">Select...</option>
				<xsl:for-each select="$properties/prop">
					<xsl:variable name="label">
						<xsl:choose>
							<xsl:when test="@value = 'authPerson'">
								<xsl:value-of select="numishare:regularize_node('authority', $lang)"/>
								<xsl:text> (</xsl:text>
								<xsl:text>Person</xsl:text>
								<xsl:text>)</xsl:text>
							</xsl:when>
							<xsl:when test="@value = 'authCorp'">
								<xsl:value-of select="numishare:regularize_node('authority', $lang)"/>
								<xsl:text> (</xsl:text>
								<xsl:value-of select="numishare:regularize_node('state', $lang)"/>
								<xsl:text>)</xsl:text>
							</xsl:when>
							<xsl:when test="@value = 'nmo:representsObjectType'">
								<xsl:value-of select="numishare:regularize_node('objectType', $lang)"/>
							</xsl:when>
							<xsl:when test="contains(@value, 'nmo:')">
								<xsl:value-of
									select="numishare:regularize_node(concat(lower-case(substring(substring-after(@value, 'nmo:has'), 1, 1)), substring(substring-after(@value, 'nmo:has'), 2)), $lang)"
								/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="numishare:regularize_node(@value, $lang)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<option value="{@value}">
						<xsl:if test="$dist = @value">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$label"/>
					</option>
				</xsl:for-each>
			</select>
		</div>
	</xsl:template>

	<xsl:template name="measurement-categories">
		<div class="form-group">
			<h4>
				<xsl:value-of select="numishare:normalizeLabel('visualize_select_measurement', $lang)"/>
			</h4>
			<p>Select the measurement type below for visualization. Measurement queries are executed across all coins harvested in Nomisma.org, regardless
				connection to coin type URIs.</p>
			<select name="measurement" class="form-control" id="measurementSelect">
				<option value="">Select...</option>
				<option value="nmo:hasWeight">
					<xsl:if test="$measurement = 'nmo:hasWeight'">
						<xsl:attribute name="selected">selected</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="numishare:regularize_node('weight', $lang)"/>
				</option>
				<option value="nmo:hasDiameter">
					<xsl:if test="$measurement = 'nmo:hasDiameter'">
						<xsl:attribute name="selected">selected</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>
				</option>
			</select>
		</div>
	</xsl:template>

	<xsl:template name="dist-compare-template">
		<xsl:param name="mode"/>
		<div class="form-inline">
			<h4>
				<xsl:choose>
					<xsl:when test="$mode = 'record'">
						<xsl:value-of select="numishare:normalizeLabel('visualize_compare_optional', $lang)"/>
					</xsl:when>
					<xsl:when test="$mode = 'page'">
						<xsl:value-of select="numishare:normalizeLabel('visualize_compare', $lang)"/>
					</xsl:when>
				</xsl:choose>
			</h4>
			<p>You can compare multiple queries to generate a more complex chart. Note that the value for each category for comparison is refined by previous
				selections in that group. For example, if the first category in a Group is "Denomination: Denarius", and Mint is select as the second category,
				the drop-down menu will include only those mints that produced denarii. <a href="#" class="add-compare"><span class="glyphicon glyphicon-plus"
						/><xsl:value-of select="numishare:normalizeLabel('visualize_add_query', $lang)"/></a></p>
			<div class="compare-master-container">
				<xsl:for-each select="$compare">
					<xsl:call-template name="compare-container-template">
						<xsl:with-param name="template" as="xs:boolean">false</xsl:with-param>
						<xsl:with-param name="query" select="normalize-space(.)"/>
					</xsl:call-template>
				</xsl:for-each>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="date-template">
		<xsl:param name="template"/>
		<xsl:param name="query"/>

		<xsl:variable name="year" select="substring-after($query, ' ')"/>

		<span>
			<xsl:if test="$template = true()">
				<xsl:attribute name="id">date-container-template</xsl:attribute>
			</xsl:if>
			<input type="number" class="form-control year" min="1" step="1" placeholder="{numishare:regularize_node('year', $lang)}">
				<xsl:if test="$year castable as xs:integer">
					<xsl:attribute name="value" select="abs(xs:integer($year))"/>
				</xsl:if>
			</input>
			<select class="form-control era">
				<option value="bc">
					<xsl:if test="$year castable as xs:integer">
						<xsl:if test="xs:integer($year) &lt; 0">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>
					</xsl:if>
					<xsl:text>B.C.</xsl:text>
				</option>
				<option value="ad">
					<xsl:if test="$year castable as xs:integer">
						<xsl:if test="xs:integer($year) &gt; 0">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>
					</xsl:if>
					<xsl:text>A.D.</xsl:text>
				</option>
			</select>
		</span>
	</xsl:template>

	<xsl:template name="coinType-template">
		<xsl:param name="query"/>
		<span>
			<input type="text" disabled="disabled" class="form-control coinType" value="{substring-after($query, ' ')}"/>
		</span>
	</xsl:template>

	<xsl:template name="compare-container-template">
		<xsl:param name="template"/>
		<xsl:param name="query"/>

		<div class="compare-container" style="padding-left:20px;margin-left:20px;border-left:1px solid gray">
			<xsl:if test="$template = true()">
				<xsl:attribute name="id">compare-container-template</xsl:attribute>
			</xsl:if>
			<h4>
				<xsl:text>Group</xsl:text>
				<small>
					<a href="#" title="Remove Group" class="remove-dataset">
						<span class="glyphicon glyphicon-remove"/>
					</a>

					<!-- do not allow other fields if the query is for a coin type -->
					<xsl:if test="not(starts-with($query, 'nmo:hasTypeSeriesItem'))">
						<a href="#" class="add-compare-field" title="Add Query Field"><span class="glyphicon glyphicon-plus"/>Add Query Field</a>
					</xsl:if>
				</small>
			</h4>
			<div class="alert alert-box alert-danger empty-query-alert hidden">
				<span class="glyphicon glyphicon-exclamation-sign"/>
				<strong><xsl:value-of select="numishare:normalizeLabel('visualize_alert', $lang)"/>:</strong> There must be at least one field in the group
				query.</div>
			<div class="alert alert-box alert-danger duplicate-date-alert hidden">
				<span class="glyphicon glyphicon-exclamation-sign"/>
				<strong><xsl:value-of select="numishare:normalizeLabel('visualize_alert', $lang)"/>:</strong> There must not be more than one from or to
				date.</div>
			<!-- if this xsl:template isn't an HTML template used by Javascript (generated in DOM from the compare request parameter), then pre-populate the query fields -->
			<xsl:if test="$template = false()">
				<xsl:variable name="pieces" select="tokenize($query, ';')"/>
				<xsl:for-each select="$pieces">
					<xsl:variable name="position" select="position()"/>

					<xsl:call-template name="field-template">
						<xsl:with-param name="template" as="xs:boolean">false</xsl:with-param>
						<xsl:with-param name="mode">compare</xsl:with-param>
						<xsl:with-param name="query" select="normalize-space(.)"/>
						<xsl:with-param name="filter" select="string-join($pieces[position() &lt; $position], '; ')"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template name="field-template">
		<xsl:param name="template"/>
		<xsl:param name="query"/>
		<xsl:param name="mode"/>
		<xsl:param name="filter"/>

		<div class="form-group filter" style="display:block; margin-bottom:15px;">
			<xsl:if test="$template = true()">
				<xsl:attribute name="id">field-template</xsl:attribute>
			</xsl:if>
			<select class="form-control add-filter-prop">
				<xsl:call-template name="property-list">
					<xsl:with-param name="template" select="$template"/>
					<xsl:with-param name="query" select="$query"/>
					<xsl:with-param name="mode" select="$mode"/>
				</xsl:call-template>
			</select>

			<div class="prop-container">
				<xsl:if test="string($query)">
					<xsl:choose>
						<xsl:when test="substring-before($query, ' ') = 'from' or substring-before($query, ' ') = 'to'">
							<xsl:call-template name="date-template">
								<xsl:with-param name="query" select="$query"/>
								<xsl:with-param name="template" as="xs:boolean">false</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="substring-before($query, ' ') = 'nmo:hasTypeSeriesItem'">
							<xsl:call-template name="coinType-template">
								<xsl:with-param name="query" select="$query"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<span class="hidden query">
								<xsl:value-of select="$query"/>
							</span>
							<xsl:if test="string($filter)">
								<span class="hidden filter">
									<xsl:value-of select="$filter"/>
								</span>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</div>

			<div class="control-container">
				<span class="glyphicon glyphicon-exclamation-sign hidden" title="A selection is required"/>
				<a href="#" title="Remove Property-Object Pair" class="remove-query">
					<span class="glyphicon glyphicon-remove"/>
				</a>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="ajax-loader-template">
		<span id="ajax-loader-template"><img src="{$include_path}/images/ajax-loader.gif" alt="loading"/> Loading</span>
	</xsl:template>

	<xsl:template name="property-list">
		<xsl:param name="query"/>
		<xsl:param name="mode"/>
		<xsl:param name="template"/>

		<xsl:variable name="properties" as="element()*">
			<properties>
				<prop value="authPerson" class="foaf:Person|foaf:Organization"/>
				<prop value="authCorp" class="foaf:Organization"/>
				<prop value="nmo:hasTypeSeriesItem" class="nmo:TypeSeriesItem"/>
				<prop value="from"/>
				<prop value="to"/>
				<prop value="nmo:hasDenomination" class="nmo:Denomination"/>
				<prop value="deity" class=""/>
				<prop value="nmo:hasIssuer" class="foaf:Person|foaf:Organization"/>
				<prop value="nmo:hasManufacture" class="nmo:Manufacture"/>
				<prop value="nmo:hasMaterial" class="nmo:Material"/>
				<prop value="nmo:hasMint" class="nmo:Mint"/>
				<prop value="nmo:representsObjectType" class="nmo:ObjectType"/>
				<prop value="portrait" class=""/>
				<prop value="region" class="nmo:Region"/>
				<prop value="nmo:hasStatedAuthority" class="foaf:Person|foaf:Organization"/>
			</properties>
		</xsl:variable>

		<option>Select...</option>
		<xsl:apply-templates select="$properties//prop">
			<xsl:with-param name="query" select="$query"/>
		</xsl:apply-templates>
		<!--<xsl:choose>
			<xsl:when test="$mode = 'compare' or $template = true()">
				<xsl:apply-templates select="$properties//prop">
					<xsl:with-param name="query" select="$query"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$properties//prop[not(contains(@class, $type))]">
					<xsl:with-param name="query" select="$query"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>-->
	</xsl:template>

	<xsl:template match="prop">
		<xsl:param name="query"/>
		<xsl:variable name="value" select="@value"/>
		<xsl:variable name="label">
			<xsl:choose>
				<xsl:when test="@value = 'authPerson'">
					<xsl:value-of select="numishare:regularize_node('authority', $lang)"/>
					<xsl:text> (</xsl:text>
					<xsl:text>Person</xsl:text>
					<xsl:text>)</xsl:text>
				</xsl:when>
				<xsl:when test="@value = 'authCorp'">
					<xsl:value-of select="numishare:regularize_node('authority', $lang)"/>
					<xsl:text> (</xsl:text>
					<xsl:value-of select="numishare:regularize_node('state', $lang)"/>
					<xsl:text>)</xsl:text>
				</xsl:when>
				<xsl:when test="@value = 'from' or @value = 'to'">
					<xsl:value-of select="numishare:regularize_node(concat(@value, 'Date'), $lang)"/>
				</xsl:when>
				<xsl:when test="@value = 'nmo:hasTypeSeriesItem'">
					<xsl:value-of select="numishare:regularize_node('coinType', $lang)"/>
				</xsl:when>
				<xsl:when test="@value = 'nmo:representsObjectType'">
					<xsl:value-of select="numishare:regularize_node('objectType', $lang)"/>
				</xsl:when>
				<xsl:when test="contains(@value, 'nmo:')">
					<xsl:value-of
						select="numishare:regularize_node(concat(lower-case(substring(substring-after(@value, 'nmo:has'), 1, 1)), substring(substring-after(@value, 'nmo:has'), 2)), $lang)"
					/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="numishare:regularize_node(@value, $lang)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<option value="{$value}" type="{@class}">
			<xsl:if test="substring-before($query, ' ') = $value">
				<xsl:attribute name="selected">selected</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="$label"/>
		</option>
	</xsl:template>

	<xsl:template name="toggle-button">
		<xsl:param name="form"/>

		<small>
			<a href="#" class="toggle-button" id="toggle-{$form}" title="Click to hide or show the analysis form">
				<span class="glyphicon glyphicon-triangle-right"/>
			</a>
		</small>
	</xsl:template>

</xsl:stylesheet>
