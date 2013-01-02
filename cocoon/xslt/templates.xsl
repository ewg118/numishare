<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:exsl="http://exslt.org/common" xmlns:numishare="http://code.google.com/p/numishare/" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:nm="http://nomisma.org/id/"
	xmlns:math="http://exslt.org/math" exclude-result-prefixes=" #all" version="2.0">

	<xsl:variable name="flickr-api-key" select="//config/flickr_api_key"/>

	<!-- ************** QUANTITATIVE ANALYSIS FUNCTIONS ************** -->
	<!-- this template should only apply for hoards, hence the nh namespace -->
	<xsl:template name="nh:quant">
		<xsl:param name="element"/>
		<xsl:param name="role"/>
		<xsl:variable name="counts">
			<counts>
				<!-- use get_hoard_quant to calculate -->
				<xsl:if test="$pipeline = 'display'">
					<xsl:copy-of select="document(concat($url, 'get_hoard_quant?id=', $id, '&amp;calculate=', if (string($role)) then $role else $element, '&amp;type=', $type))"/>
				</xsl:if>
				<!-- if there is a compare parameter, load get_hoard_quant with document() function -->
				<xsl:if test="string($compare) and string($calculate)">
					<xsl:for-each select="tokenize($compare, ',')">
						<xsl:copy-of select="document(concat($url, 'get_hoard_quant?id=', ., '&amp;calculate=', if (string($role)) then $role else $element, '&amp;type=', $type))"/>
					</xsl:for-each>
				</xsl:if>
			</counts>
		</xsl:variable>

		<div id="{.}-container" style="min-width: 400px; height: 400px; margin: 0 auto"/>
		<table class="calculate" id="{.}-table">
			<caption>
				<xsl:choose>
					<xsl:when test="$type='count'">Occurrences</xsl:when>
					<xsl:otherwise>Percentage</xsl:otherwise>
				</xsl:choose>
				<xsl:text> for </xsl:text>
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
					<xsl:variable name="name" select="if (string(.)) then . else 'Null value'"/>
					<tr>
						<th>
							<xsl:value-of select="$name"/>
						</th>
						<xsl:if test="$pipeline = 'display'">
							<td>
								<xsl:choose>
									<xsl:when test="number(exsl:node-set($counts)//hoard[@id=$id]/*[local-name()='name'][text()=$name]/@count)">
										<xsl:value-of select="exsl:node-set($counts)//hoard[@id=$id]/*[local-name()='name'][text()=$name]/@count"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>0</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</td>
						</xsl:if>
						<xsl:if test="string($compare)">
							<xsl:for-each select="tokenize($compare, ',')">
								<xsl:variable name="hoard-id" select="."/>
								<td>
									<xsl:choose>
										<xsl:when test="number(exsl:node-set($counts)//hoard[@id=$hoard-id]/*[local-name()='name'][text()=$name]/@count)">
											<xsl:value-of select="exsl:node-set($counts)//hoard[@id=$hoard-id]/*[local-name()='name'][text()=$name]/@count"/>
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
	</xsl:template>
	
	<xsl:template name="visualization">
		<xsl:variable name="queryOptions">authority,deity,denomination,dynasty,issuer,material,mint,portrait,region</xsl:variable>
		<xsl:variable name="chartTypes">line,spline,area,areaspline,column,bar,scatter</xsl:variable>
		<xsl:variable name="action">
			<xsl:choose>
				<xsl:when test="$pipeline = 'analyze'">#visualization</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('./', $id, '#quantitative')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<p>Use this feature to visualize percentages or numeric occurrences of the following typologies.</p>		
		<form action="{$action}" id="visualize-form" style="margin-bottom:40px;">
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
								<xsl:when test=". = 'column'">
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
			<div style="display:table;width:100%">
				<h2>Step 3: Select Categories for Analysis</h2>
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
								<xsl:if test="count(exsl:node-set($nudsGroup)/descendant::*[local-name()=$query_fragment or @xlink:role=$query_fragment]) &gt; 0">
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
						<xsl:text>Step 4: Select Hoards</xsl:text>
						<span style="font-size:60%;margin-left:10px;">
							<a href="#filterHoards" id="showFilter">Filter List</a>
						</span>
					</h2>
					<div class="filter-div" style="display:none">
						<b>Filter Query:</b>
						<span/>
						<a href="#" class="removeFilter">Remove Filter</a>
					</div>
					<xsl:call-template name="get-hoards"/>
				</xsl:when>
				<xsl:otherwise>
					<h2>Step 4: Select Hoards to Compare (optional)</h2>
					<xsl:choose>
						<xsl:when test="not(string($compare))">
							<div>
								<a href="#" class="compare-button"><img src="{$display_path}images/plus.gif" alt="Expand"/>Compare to Other Hoards</a>
								<div class="compare-div"/>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<div class="compare-div">
								<cinclude:include src="cocoon:/get_hoards?compare={$compare}&amp;q=*"/>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			
			<input type="hidden" name="calculate" id="calculate-input" value=""/>
			<input type="hidden" name="compare" class="compare-input" value=""/>
			<br/>
			<input type="submit" value="Calculate Selected" id="submit-calculate"/>
		</form>
		
		<!-- output charts and tables -->
		<xsl:for-each select="tokenize($calculate, ',')">
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
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="data-download">
		<xsl:variable name="queryOptions">authority,deity,denomination,dynasty,issuer,material,mint,portrait,region</xsl:variable>
		
		<p>Use this feature to download a CSV for the given query and selected hoards.</p>
		<form action="{$display_path}hoards.csv" id="csv-form" style="margin-bottom:40px;">
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
			<div style="width:100%;display:table">
				<h2>Step 2: Select Categories for Analysis</h2>
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
								<xsl:if test="count(exsl:node-set($nudsGroup)/descendant::*[local-name()=$query_fragment or @xlink:role=$query_fragment]) &gt; 0">
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
						<xsl:text>Step 3: Select Hoards</xsl:text>
						<div class="filter-div" style="display:none">
							<b>Filter Query:</b>
							<span/>
							<a href="#" class="removeFilter">Remove Filter</a>
						</div>
					</h2>
					<xsl:call-template name="get-hoards"/>
				</xsl:when>
				<xsl:otherwise>
					<h2>Step 3: Select Hoards to Compare (optional)</h2>
					<div>
						<a href="#" class="compare-button"><img src="{$display_path}images/plus.gif" alt="Expand"/>Compare to Other Hoards</a>
						<div class="compare-div"/>
					</div>
				</xsl:otherwise>
			</xsl:choose>
			
			<input type="hidden" name="compare" class="compare-input" value=""/>
			<br/>
			<input type="submit" value="Calculate Selected" id="submit-csv"/>
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
			<xsl:value-of select="concat(upper-case(substring($query_fragment, 1, 1)), substring($query_fragment, 2))"/>
		</label>
	</xsl:template>
	
	<xsl:template name="vis-radios">
		<xsl:param name="query_fragment"/>
		<input type="radio" name="calculate" id="{$query_fragment}-radio" value="{$query_fragment}"/>
		<label for="{$query_fragment}-checkbox">
			<xsl:value-of select="concat(upper-case(substring($query_fragment, 1, 1)), substring($query_fragment, 2))"/>
		</label>
	</xsl:template>
	
	<xsl:template name="get-hoards">
		<div class="compare-div">
			<cinclude:include src="cocoon:/get_hoards?compare={$compare}&amp;q=*"/>
		</div>
	</xsl:template>
	
	<!-- ************** NORMALIZATION TEMPLATES ************** -->

	<xsl:template name="nh:normalize_date">
		<xsl:param name="start_date"/>
		<xsl:param name="end_date"/>

		<xsl:choose>
			<xsl:when test="number($start_date) = number($end_date)">
				<xsl:if test="number($start_date) &lt; 500 and number($start_date) &gt; 0">
					<xsl:text>A.D. </xsl:text>
				</xsl:if>
				<xsl:value-of select="abs(number($start_date))"/>
				<xsl:if test="number($start_date) &lt; 0">
					<xsl:text> B.C.</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<!-- start date -->

				<xsl:if test="number($start_date) &lt; 500 and number($start_date) &gt; 0">
					<xsl:text>A.D. </xsl:text>
				</xsl:if>
				<xsl:value-of select="abs(number($start_date))"/>
				<xsl:if test="number($start_date) &lt; 0">
					<xsl:text> B.C.</xsl:text>
				</xsl:if>
				<xsl:text> - </xsl:text>

				<!-- end date -->
				<xsl:if test="number($end_date) &lt; 500 and number($end_date) &gt; 0">
					<xsl:text>A.D. </xsl:text>
				</xsl:if>
				<xsl:value-of select="abs(number($end_date))"/>
				<xsl:if test="number($end_date) &lt; 0">
					<xsl:text> B.C.</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--***************************************** FUNCTIONS **************************************** -->
	<xsl:function name="numishare:get_flickr_uri">
		<xsl:param name="photo_id"/>
		<xsl:value-of
			select="document(concat('http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&amp;api_key=', $flickr-api-key, '&amp;photo_id=', $photo_id, '&amp;format=rest'))/rsp/photo/urls/url[@type='photopage']"
		/>
	</xsl:function>

	<xsl:function name="numishare:regularize_node">
		<xsl:param name="name"/>
		<xsl:param name="lang"/>

		<xsl:choose>
			<xsl:when test="$lang='ar'"> </xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$name='acqinfo'">Aquisitition Information</xsl:when>
					<xsl:when test="$name='acquiredFrom'">Acquired From</xsl:when>
					<xsl:when test="$name='conservationState'">Conservation State</xsl:when>
					<xsl:when test="$name='custodhist'">Custodial History</xsl:when>
					<xsl:when test="$name='dateOnObject'">Date on Object</xsl:when>
					<xsl:when test="$name='dateRange'">Date Range</xsl:when>
					<xsl:when test="$name='fromDate'">From Date</xsl:when>
					<xsl:when test="$name='toDate'">To Date</xsl:when>
					<xsl:when test="$name='objectType'">Object Type</xsl:when>
					<xsl:when test="$name='saleCatalog'">Sale Catalog</xsl:when>
					<xsl:when test="$name='saleItem'">Sale Item</xsl:when>
					<xsl:when test="$name='salePrice'">Sale Price</xsl:when>
					<xsl:when test="$name='testmark'">Test Mark</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>
</xsl:stylesheet>
