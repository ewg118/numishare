<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:exsl="http://exslt.org/common"
	xmlns:numishare="http://code.google.com/p/numishare/" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>	
	<xsl:include href="header.xsl"/>
	<xsl:include href="footer.xsl"/>
	<xsl:include href="templates.xsl"/>
	<xsl:include href="functions.xsl"/>

	<xsl:param name="pipeline"/>
	<xsl:param name="display_path"/>
	<xsl:param name="lang"/>

	<xsl:param name="q"/>

	<xsl:param name="category"/>
	<xsl:param name="chartType"/>
	<xsl:param name="compare"/>
	<xsl:param name="custom"/>
	<xsl:param name="type"/>

	<!-- variables -->
	<xsl:variable name="category_normalized">
		<xsl:value-of select="numishare:normalize_fields($category, $lang)"/>
	</xsl:variable>
	<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>
	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>
	<xsl:variable name="qString" select="if (string($q)) then $q else '*:*'"/>

	<!-- config variables -->
	<xsl:variable name="url">
		<xsl:value-of select="//config/url"/>
	</xsl:variable>
	<xsl:variable name="collection_type" select="//config/collection_type"/>

	<!-- load facets into variable -->
	<xsl:variable name="facets" select="//lst[@name='facet_fields']"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: Visualize Queries</xsl:text>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$display_path}images/favicon.png"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/3.8.0/build/cssgrids/grids-min.css"/>
				<!-- Core + Skin CSS -->
				<link type="text/css" href="{$display_path}themes/{//config/theme/jquery_ui_theme}.css" rel="stylesheet"/>
				<link type="text/css" href="{$display_path}jquery.fancybox-1.3.4.css" rel="stylesheet"/>
				<link type="text/css" href="{$display_path}style.css" rel="stylesheet"/>
				<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/jquery-ui-1.8.10.custom.min.js"/>
				
				<!-- menu -->
				<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.core.js"/>
				<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.widget.js"/>
				<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.position.js"/>
				<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.button.js"/>
				<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.menu.js"/>
				<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.menubar.js"/>
				<script type="text/javascript" src="{$display_path}javascript/numishare-menu.js"/>
				
				<!-- visualize functions -->
				<script type="text/javascript" src="{$display_path}javascript/highcharts.js"/>
				<script type="text/javascript" src="{$display_path}javascript/modules/exporting.js"/>
				<script type="text/javascript" src="{$display_path}javascript/visualize_functions.js"/>
				<!-- compare/customQuery functions -->
				<script type="text/javascript" src="{$display_path}javascript/jquery.fancybox-1.3.4.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/jquery.livequery.js"/>
				<script type="text/javascript" src="{$display_path}javascript/search_functions.js"/>

				<xsl:if test="string(/config/google_analytics/script)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics/script"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="visualize"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="visualize">
		<div class="yui3-g">
			<div class="yui3-u-1">
				<div class="content">
					<xsl:apply-templates select="/content/response"/>
				</div>
			</div>
		</div>		
	</xsl:template>

	<xsl:template match="response">
		<h1>Visualize</h1>
		<p>Use the data selection and visualization options below to generate a chart based selected parameters. Instructions for using this feature can be found at <a
			href="http://wiki.numismatics.org/numishare:visualize" target="_blank">http://wiki.numismatics.org/numishare:visualize</a>.</p>

		<!-- display the facet list only if there is a $q -->
		<xsl:if test="string($q)">
			<xsl:call-template name="display_facets">
				<xsl:with-param name="tokens" select="$tokenized_q"/>
			</xsl:call-template>
			<a href="results?q={$q}">Return to search results.</a>
		</xsl:if>

		<xsl:call-template name="visualize_options"/>

		<div style="display:none">
			<div id="searchBox">
				<h3>Add Query</h3>
				<xsl:call-template name="search_forms"/>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="visualize_options">
		<xsl:variable name="chartTypes">column,bar</xsl:variable>

		<form action="{$display_path}visualize" style="margin-bottom:40px;">
			<h2>Step 1: Select Numeric Response Type</h2>
			<input type="radio" name="type" value="percentage">
				<xsl:if test="$type != 'count'">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
			</input>
			<label for="type-radio">Percentage</label>
			<br/>
			<input type="radio" name="type" value="count">
				<xsl:if test="$type = 'count'">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
			</input>
			<label for="type-radio">Count</label>
			<br/>
			<div style="display:table;width:100%">
				<h2>Step 2: Select Chart Type</h2>
				<xsl:for-each select="tokenize($chartTypes, ',')">
					<span class="anOption">
						<input type="radio" name="chartType" value="{.}">
							<xsl:choose>
								<xsl:when test="$chartType = .">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:when>
								<xsl:when test=". = 'column' and not(string($chartType))">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:when>
							</xsl:choose>
						</input>
						<label for="chartType-radio">
							<xsl:value-of select="."/>
						</label>
					</span>
				</xsl:for-each>
			</div>

			<!-- include checkbox categories -->
			<div style="display:table;width:100%">
				<h2>Step 3: Select Categories for Analysis</h2>
				<cinclude:include src="cocoon:/get_vis_categories?category={$category}&amp;q={$qString}"/>
				<h3>
					<xsl:text>Add Custom Queries</xsl:text>
					<span style="font-size:80%;margin-left:10px;">
						<a href="#searchBox" class="addQuery" id="customQuery">Add Query</a>
					</span>
				</h3>
				<div id="customQueryDiv">
					<xsl:for-each select="tokenize($custom, '\|')">
						<div class="customQuery">
							<b>Custom Query: </b>
							<span>
								<xsl:value-of select="."/>
							</span>
							<a href="#" class="removeQuery">Remove Query</a>
						</div>
					</xsl:for-each>
				</div>
			</div>


			<h2>
				<xsl:choose>
					<xsl:when test="string($q)">
						<xsl:text>Step 4: Compare to other Queries (optional)</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Step 4: Compare Queries</xsl:text>
					</xsl:otherwise>
				</xsl:choose>

				<span style="font-size:80%;margin-left:10px;">
					<a href="#searchBox" class="addQuery" id="compareQuery">Add Query</a>
				</span>
			</h2>
			<div id="compareQueryDiv">
				<xsl:for-each select="tokenize($compare, '\|')">
					<div class="compareQuery">
						<b>Comparison Query: </b>
						<span>
							<xsl:value-of select="."/>
						</span>
						<a href="#" class="removeQuery">Remove Query</a>
					</div>
				</xsl:for-each>
			</div>
			<input type="hidden" name="category" id="calculate-input" value=""/>
			<input type="hidden" name="compare" id="compare-input" value=""/>
			<input type="hidden" name="custom" id="custom-input" value=""/>
			<xsl:if test="string($q)">
				<input type="hidden" name="q" value="{$q}"/>
			</xsl:if>
			<br/>
			<input type="submit" value="Generate Charts" id="submit-calculate"/>
		</form>

		<!-- output charts and tables for facets -->
		<xsl:if test="string($category) and (string($q) or string($compare))">
			<xsl:for-each select="tokenize($category, '\|')">
				<xsl:call-template name="quant">
					<xsl:with-param name="facet" select="."/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="string($custom)">
			<xsl:for-each select="tokenize($custom, '\|')">
				<xsl:call-template name="quant">
					<xsl:with-param name="customQuery" select="."/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template name="quant">
		<xsl:param name="facet"/>
		<xsl:param name="customQuery"/>
		<xsl:variable name="counts">
			<counts>
				<xsl:choose>
					<xsl:when test="string($facet)">
						<!-- if there is a $q parameter, gather data -->
						<xsl:if test="string($q)">
							<xsl:copy-of select="document(concat($url, 'get_vis_quant?q=', encode-for-uri($q), '&amp;category=', $facet, '&amp;type=', $type ))"/>
						</xsl:if>
						<!-- if there is a compare parameter, load get_hoard_quant with document() function -->
						<xsl:if test="string($compare)">
							<xsl:for-each select="tokenize($compare, '\|')">
								<xsl:copy-of select="document(concat($url, 'get_vis_quant?q=', encode-for-uri(.), '&amp;category=', $facet, '&amp;type=', $type ))"/>
							</xsl:for-each>
						</xsl:if>
					</xsl:when>
					<xsl:when test="string($customQuery)">
						<!-- if there is a $q parameter, gather data -->
						<xsl:if test="string($q)">
							<xsl:copy-of select="document(concat($url, 'get_vis_custom?q=', encode-for-uri($q), '&amp;customQuery=', $customQuery, '&amp;total=', $numFound, '&amp;type=', $type ))"/>
						</xsl:if>
						<!-- if there is a compare parameter, load get_hoard_quant with document() function -->
						<xsl:if test="string($compare)">
							<xsl:for-each select="tokenize($compare, '\|')">
								<xsl:copy-of select="document(concat($url, 'get_vis_custom?q=', encode-for-uri(.), '&amp;customQuery=', $customQuery, '&amp;total=', $numFound, '&amp;type=', $type ))"
								/>
							</xsl:for-each>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</counts>
		</xsl:variable>

		<!-- only display chart if there are counts -->
		<xsl:if test="count(exsl:node-set($counts)//name) &gt; 0">
			<div id="{.}-container" style="min-width: 400px; height: 400px; margin: 0 auto"/>
			<table class="calculate" id="{.}-table">
				<caption>
					<xsl:choose>
						<xsl:when test="$type='count'">Occurrences</xsl:when>
						<xsl:otherwise>Percentage</xsl:otherwise>
					</xsl:choose>
					<xsl:text> for </xsl:text>
					<xsl:choose>
						<xsl:when test="string($facet)">
							<xsl:value-of select="numishare:normalize_fields($facet, $lang)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$customQuery"/>
						</xsl:otherwise>
					</xsl:choose>

				</caption>
				<thead>
					<tr>
						<th/>
						<xsl:if test="string($q)">
							<th>
								<xsl:value-of select="$q"/>
							</th>
						</xsl:if>
						<xsl:if test="string($compare)">
							<xsl:for-each select="tokenize($compare, '\|')">
								<th>
									<xsl:value-of select="."/>
								</th>
							</xsl:for-each>
						</xsl:if>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="distinct-values(exsl:node-set($counts)//name)">
						<xsl:sort/>
						<xsl:variable name="name" select="."/>
						<tr>
							<th>
								<xsl:value-of select="$name"/>
							</th>
							<xsl:if test="string($q)">
								<td>
									<xsl:choose>
										<xsl:when test="number(exsl:node-set($counts)//query[@q=$q]/*[local-name()='name'][text()=$name]/@count)">
											<xsl:value-of select="exsl:node-set($counts)//query[@q=$q]/*[local-name()='name'][text()=$name]/@count"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>0</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:if>
							<xsl:if test="string($compare)">
								<xsl:for-each select="tokenize($compare, '\|')">
									<xsl:variable name="new-q" select="."/>
									<td>
										<xsl:choose>
											<xsl:when test="number(exsl:node-set($counts)//query[@q=$new-q]/*[local-name()='name'][text()=$name]/@count)">
												<xsl:value-of select="exsl:node-set($counts)//query[@q=$new-q]/*[local-name()='name'][text()=$name]/@count"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>0</xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</xsl:for-each>
							</xsl:if>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>

	<xsl:template name="display_facets">
		<xsl:param name="tokens"/>

		<div class="remove_facets">
			<xsl:for-each select="$tokens">
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
								<xsl:otherwise>Keyword</xsl:otherwise>
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
							<span>
								<b><xsl:value-of select="$name"/>: </b>
								<xsl:value-of select="if ($field = 'century_num') then numishare:normalize_century($term) else $term"/>
							</span>
						</div>

					</xsl:when>
					<!-- if the token contains a parenthisis, then it was probably sent from the search widget and the token must be broken down further to remove other facets -->
					<xsl:when test="substring(., 1, 1) = '('">
						<xsl:variable name="tokenized-fragments" select="tokenize(., ' OR ')"/>

						<div class="ui-widget ui-state-default ui-corner-all stacked_term">
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
													<xsl:otherwise>
														<xsl:analyze-string select="$after-colon" regex="([0-9]+)">
															<xsl:matching-substring>
																<xsl:value-of select="regex-group(1)"/>
															</xsl:matching-substring>
														</xsl:analyze-string>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:variable>
											<xsl:value-of select="concat($other_field, ':', $other_value)"/>
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
										<xsl:value-of select="numishare:normalize_fields($field, $lang)"/>
										<xsl:text>: </xsl:text>
									</b>
									<xsl:value-of select="if ($field='century_num') then numishare:normalize_century($value) else $value"/>
									<xsl:if test="position() != last()">
										<xsl:text> OR </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</span>
						</div>
					</xsl:when>
					<xsl:when test="not(contains(., ':'))">
						<div class="stacked_term">
							<span>
								<b>Keyword: </b>
								<xsl:value-of select="."/>
							</span>
						</div>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
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

		<div class="ui-widget ui-state-default ui-corner-all stacked_term">
			<span class="term">
				<b>Category: </b>
				<xsl:call-template name="recompile_category">
					<xsl:with-param name="category_fragment" select="$category_fragment"/>
					<xsl:with-param name="tokenized_fragment" select="tokenize(substring-after(replace(replace(replace($category_fragment, '\)', ''), '\(', ''), '\+', ''), 'category_facet:'), ' ')"/>
					<xsl:with-param name="level" as="xs:integer">1</xsl:with-param>
				</xsl:call-template>
			</span>
		</div>
	</xsl:template>

</xsl:stylesheet>
