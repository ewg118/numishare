<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<!-- includes -->
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:param name="pipeline">maps</xsl:param>
	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path"
		select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>
	<xsl:variable name="collection_type" select="/content//collection_type"/>

	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name = 'q']/value"/>
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[. = 'accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[. = 'accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>
	<xsl:variable name="request-uri"
		select="
			concat('http://localhost:', if (//config/server-port castable as xs:integer) then
				//config/server-port
			else
				'8080', substring-before(doc('input:request')/request/request-uri, 'maps'))"/>
	<xsl:variable name="numFound" select="//result[@name = 'response']/@numFound"/>
	<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>

	<xsl:variable name="positions" as="node()*">
		<config>
			<xsl:copy-of select="/content/config/positions"/>
		</config>
	</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="numishare:normalizeLabel('header_maps', $lang)"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon"
					href="{$include_path}/images/{if (string(//config/favicon)) then //config/favicon else 'favicon.png'}"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>

				<!-- jquery -->
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"/>

				<xsl:for-each select="//config/includes/include">
					<xsl:choose>
						<xsl:when test="@type = 'css'">
							<link type="text/{@type}" rel="stylesheet" href="{@url}"/>
						</xsl:when>
						<xsl:when test="@type = 'javascript'">
							<script type="text/{@type}" src="{@url}"/>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>

				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
				<script type="text/javascript" src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/bootstrap-multiselect.js"/>
				<link rel="stylesheet" href="{$include_path}/css/bootstrap-multiselect.css" type="text/css"/>
				<!-- local theme and styling -->
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>

				<!-- Add fancyBox -->
				<link rel="stylesheet" href="{$include_path}/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>

				<!-- maps-->
				<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.0/dist/leaflet.css"/>

				<!-- js -->
				<script src="https://unpkg.com/leaflet@1.0.0/dist/leaflet.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/leaflet.ajax.min.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/map_functions.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/facet_functions.js"/>

				<!-- Google Analytics -->
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
                                                <xsl:value-of select="//config/google_analytics"/>
                                        </script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="maps"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="maps">
		<div class="container-fluid">
			<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>
			</xsl:if>
			<div class="row">
				<div class="col-md-12">
					<div id="backgroundPopup"/>
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('header_maps', $lang)"/>
					</h1>
					<p>For usage instructions, see <a href="http://wiki.numismatics.org/numishare:maps">http://wiki.numismatics.org/numishare:maps</a>. View in
							<a href="maps/fullscreen">fullscreen mode</a>.</p>
				</div>
			</div>
			<xsl:choose>
				<xsl:when test="$numFound &gt; 0">
					<xsl:apply-templates select="//lst[@name = 'facet_fields']"/>

					<div class="row">
						<div class="col-md-12 maps-page">
							<div id="mapcontainer"/>
							<div class="legend">
								<table>
									<tbody>
										<tr>
											<th style="width:100px">
												<xsl:value-of select="numishare:normalizeLabel('maps_legend', $lang)"/>
											</th>
											<td style="background-color:#6992fd;border:2px solid black;width:50px;"/>
											<td style="width:100px;padding-left:5px">
												<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
											</td>
											<td style="background-color:#d86458;border:2px solid black;width:50px;"/>
											<td style="width:100px;padding-left:6px;">
												<xsl:value-of select="numishare:regularize_node('hoard', $lang)"/>
											</td>
											<td style="background-color:#f98f0c;border:2px solid black;width:50px;"/>
											<td style="width:100px;padding-left:6px;">
												<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
											</td>
											<xsl:if test="$collection_type != 'hoard'">
												<td style="background-color:#00e64d;border:2px solid black;width:50px;"/>
												<td style="width:100px;padding-left:5px">
													<xsl:value-of select="numishare:regularize_node('subject', $lang)"/>
												</td>
											</xsl:if>
										</tr>
									</tbody>
								</table>
							</div>

							<div id="results"/>
						</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="row">
						<div class="col-md-12">
							<h1> No results found.</h1>
						</div>
					</div>
				</xsl:otherwise>
			</xsl:choose>
			<div style="display:none">
				<input id="facet_form_query" name="q" value="*:*" type="hidden"/>
				<xsl:if test="string($langParam)">
					<input type="hidden" name="lang" value="{$lang}"/>
				</xsl:if>
				<span id="collection_type">
					<xsl:value-of select="$collection_type"/>
				</span>
				<span id="path">
					<xsl:value-of select="$display_path"/>
				</span>
				<span id="include_path">
					<xsl:value-of select="$include_path"/>
				</span>
				<span id="pipeline">
					<xsl:value-of select="$pipeline"/>
				</span>
				<xsl:if test="string(doc('input:request')/request/parameters/parameter[name = 'department']/value)">
					<span id="department">
						<xsl:value-of select="doc('input:request')/request/parameters/parameter[name = 'department']/value"/>
					</span>
				</xsl:if>
				<span id="mapboxKey">
					<xsl:value-of select="//config/mapboxKey"/>
				</span>
				<span id="section">maps</span>
				<span id="baselayers">
					<xsl:value-of select="string-join(//config/baselayers/layer[@enabled = true()], ',')"/>
				</span>
				<div id="ajax-temp"/>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="lst[@name = 'facet_fields']">

		<div class="row">
			<xsl:apply-templates
				select="lst[not(@name = 'mint_geo') and not(@name = 'mint_facet') and not(matches(@name, '^symbol_[obv|rev]'))] | lst[@name = 'mint_facet' and $collection_type = 'hoard']"
				mode="facet"/>

		</div>

		<xsl:if test="lst[contains(@name, 'symbol_obv_') and number(int) &gt; 0]">
			<div class="row">
				<div class="col-md-12">
					<h4>
						<xsl:value-of select="numishare:normalize_fields('symbol', $lang)"/>
						<xsl:text>, </xsl:text>
						<xsl:value-of select="numishare:normalize_fields('obverse', $lang)"/>
					</h4>
				</div>
				
				<xsl:apply-templates select="lst[contains(@name, 'symbol_obv') and number(int) &gt; 0]" mode="facet"/>
			</div>

		</xsl:if>
		<xsl:if test="lst[contains(@name, 'symbol_rev_') and number(int) &gt; 0]">
			<div class="row">
				<div class="col-md-12">
					<h4>
						<xsl:value-of select="numishare:normalize_fields('symbol', $lang)"/>
						<xsl:text>, </xsl:text>
						<xsl:value-of select="numishare:normalize_fields('reverse', $lang)"/>
					</h4>
				</div>
				
				<xsl:apply-templates select="lst[contains(@name, 'symbol_rev') and number(int) &gt; 0]" mode="facet"/>
			</div>
		</xsl:if>


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

		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="matches(@name, '^symbol_[obv|rev]')">
					<xsl:variable name="langParam" select="
							if (string($lang)) then
								$lang
							else
								'en'"/>

					<!-- evaluate whether the symbol is indexed at a certain position or pertains to the side more generally -->
					<xsl:choose>
						<xsl:when test="count(tokenize(@name, '_')) = 4">
							<xsl:variable name="position" select="tokenize(@name, '_')[3]"/>

							<xsl:choose>
								<xsl:when test="$position = 'letter'">
									<xsl:value-of select="numishare:normalize_fields('letter', $lang)"/>
								</xsl:when>
								<xsl:when test="$positions//position[@value = $position]/label[@lang = $langParam]">
									<xsl:value-of select="$positions//position[@value = $position]/label[@lang = $langParam]"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat(upper-case(substring($position, 1, 1)), substring($position, 2))"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="numishare:normalizeLabel('position_any', $lang)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="numishare:normalize_fields(@name, $lang)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains(@name, '_hier')">
				<!--<xsl:variable name="title" select="numishare:regularize_node(substring-before(@name, '_'), $lang)"/>
					
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
					</div>-->
			</xsl:when>
			<xsl:when test="@name = 'century_num'">
				<!--<button class="ui-multiselect ui-widget ui-state-default ui-corner-all" type="button" title="Date" aria-haspopup="true" style="width: 180px;" id="{@name}_link" label="{$q}">
							<span class="ui-icon ui-icon-triangle-2-n-s"/>
							<span>Date</span>
						</button>
						<div class="ui-multiselect-menu ui-widget ui-widget-content ui-corner-all date-div" style="width: 180px;">
							<div class="ui-widget-header ui-corner-all ui-multiselect-header ui-helper-clearfix ui-multiselect-hasfilter">
								<ul class="ui-helper-reset">
									<li class="ui-multiselect-close">
										<a class="ui-multiselect-close century-close" href="#"> close<span class="ui-icon ui-icon-circle-close"/>
										</a>
									</li>
								</ul>
							</div>
							<ul class="century-multiselect-checkboxes ui-helper-reset" id="{@name}-list" style="height: 175px;"/>
						</div>-->
			</xsl:when>
			<xsl:otherwise>
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
				<div class="col-md-3">
					<select id="{@name}-select" multiple="multiple" class="multiselect" title="{$title}" q="{$q}" mincount="{$mincount}"
						new_query="{if (contains($q, @name)) then $select_new_query else ''}">
						<xsl:if test="$pipeline = 'maps'">
							<xsl:attribute name="style">width:180px</xsl:attribute>
						</xsl:if>
					</select>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
