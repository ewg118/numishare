<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" version="2.0">
	<!-- ************** SEARCH FORM ************** -->

	<!-- the advanced search form is used on the /search page and in the /maps page popup -->
	<xsl:template name="advanced-search-form">
		<xsl:param name="mode"/>

		<form action="{$display_path}results" method="GET" role="form" id="facet_form">

			<div class="form-group">
				<label>Keyword</label>
				<input type="text" class="form-control text-search" id="fulltext" placeholder="Search" autofocus="autofocus">
					<xsl:if test="contains($q, 'fulltext')">
						<xsl:for-each select="$tokenized_q[starts-with(., 'fulltext')][1]">
							<xsl:attribute name="value" select="substring-after(., ':')"/>
						</xsl:for-each>
					</xsl:if>
				</input>
				<button class="btn btn-default" type="submit">
					<i class="glyphicon glyphicon-search"/>
				</button>
				<span class="text-info">These terms will search all fields in the database.</span>
			</div>

			<xsl:if test="//config/facets/facet[@role = 'department']">
				<xsl:for-each select="//config/facets/facet[@role = 'department' and @type = 'list']">
					<xsl:variable name="field" select="."/>

					<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="$collection_type = 'object'">
				<div class="form-group">
					<label for="imagesavailable">
						<xsl:value-of select="numishare:normalizeLabel('results_has-images', $lang)"/>
					</label>
					<input type="checkbox" id="imagesavailable">
						<xsl:if test="contains($q, 'imagesavailable:true')">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
				</div>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="not(//config/facets/facet/@type)">
					<!-- display alert error if the Numishare config is out of down and does not include facet classifications for the search form -->
					<div class="alert alert-danger alert-box" role="alert">
						<span class="glyphicon glyphicon-exclamation-sign"/>
						<strong>Alert:</strong> The Numishare config is out of date with respect to facet classifications. Please enter the administrative panel for this collection
						to update the config. </div>
				</xsl:when>

				<xsl:otherwise>

					<xsl:if test="$collection_type = 'hoard'">
						<xsl:if test="//config/facets/facet[@role = 'context']">
							<h2>
								<xsl:value-of select="numishare:normalize_fields('context', $lang)"/>
							</h2>

							<xsl:for-each select="//config/facets/facet[@role = 'context' and @type = 'list']">
								<xsl:variable name="field" select="."/>

								<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
							</xsl:for-each>
						</xsl:if>
					</xsl:if>

					<xsl:if test="$collection_type = 'hoard'">
						<h2>Contents</h2>
					</xsl:if>

					<xsl:if test="//config/facets/facet[@role = 'entity']">
						<h3>
							<xsl:text>People and Organizations</xsl:text>
							<xsl:if test="//config/facets/facet[@role = 'entity' and @type = 'text'] and $mode = 'search'">
								<small>
									<a class="addBtn" id="add-entity" href="#">
										<span class="glyphicon glyphicon-plus"/> add search field </a>
								</small>
							</xsl:if>
						</h3>

						<xsl:choose>
							<!-- only include text searchable fields if applicable -->
							<xsl:when test="$mode = 'search'">
								<xsl:if test="//config/facets/facet[@role = 'entity' and @type = 'text']">
									<div class="section-container" id="entity-container">
										<div class="form-group">
											<input type="text" class="form-control text-search"/>
											<select class="category_list form-control">
												<xsl:for-each select="//config/facets/facet[@role = 'entity' and @type = 'text']">
													<option value="{.}">
														<xsl:value-of select="numishare:normalize_fields(., $lang)"/>
													</option>
												</xsl:for-each>
											</select>
											<a class="removeBtn hidden" href="#" title="Remove field from query">
												<span class="glyphicon glyphicon-remove"/>
											</a>
										</div>
									</div>
								</xsl:if>

								<!-- list fields -->
								<xsl:for-each select="//config/facets/facet[@role = 'entity' and @type = 'list']">
									<xsl:variable name="field" select="."/>

									<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
								</xsl:for-each>
							</xsl:when>

							<!-- display all as facet lists on maps page -->
							<xsl:when test="$mode = 'maps'">
								<xsl:for-each select="//config/facets/facet[@role = 'entity']">
									<xsl:variable name="field" select="."/>

									<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
								</xsl:for-each>
							</xsl:when>
						</xsl:choose>
					</xsl:if>


					<xsl:if test="//config/facets/facet[@role = 'place']">
						<h3>
							<xsl:text>Places</xsl:text>
							<xsl:if test="//config/facets/facet[@role = 'place' and @type = 'text']">
								<small>
									<a class="addBtn" id="add-place" href="#">
										<span class="glyphicon glyphicon-plus"/> add search field </a>
								</small>
							</xsl:if>
						</h3>

						<!-- general text fields -->
						<xsl:if test="$mode = 'search'">
							<div class="form-group">
								<label for="place_text">Place Search</label>
								<input type="text" class="form-control text-search" id="place_text"
									fields="{string-join(//config/facets/facet[@role = 'place' and @type = 'list'], ';')}"/>
							</div>
						</xsl:if>

						<!-- list fields -->
						<xsl:for-each select="//config/facets/facet[@role = 'place' and @type = 'list']">
							<xsl:variable name="field" select="."/>

							<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
						</xsl:for-each>
					</xsl:if>

					<h3>Typology</h3>

					<xsl:if test="$collection_type = 'hoard'">
						<xsl:apply-templates select="//lst[@name = 'coinType_facet' and number(int) &gt; 0]" mode="facet"/>
					</xsl:if>

					<xsl:for-each select="//config/facets/facet[@role = 'typology' and @type = 'list']">
						<xsl:variable name="field" select="."/>

						<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
					</xsl:for-each>

					<div class="form-group">

						<xsl:variable name="dateRange">
							<xsl:if test="contains($q, 'year_num')">
								<xsl:for-each select="$tokenized_q[starts-with(., 'year_num')][1]">
									<xsl:value-of select="substring-after(., ':')"/>
								</xsl:for-each>
							</xsl:if>
						</xsl:variable>

						<xsl:variable name="fromDate">
							<xsl:if test="string($dateRange)">
								<xsl:analyze-string select="$dateRange" regex="\[(.*) TO (.*)\]">
									<xsl:matching-substring>
										<xsl:if test="number(regex-group(1))">
											<xsl:value-of select="regex-group(1)"/>
										</xsl:if>
									</xsl:matching-substring>
								</xsl:analyze-string>
							</xsl:if>
						</xsl:variable>

						<xsl:variable name="toDate">
							<xsl:if test="string($dateRange)">
								<xsl:analyze-string select="$dateRange" regex="\[(.*) TO (.*)\]">
									<xsl:matching-substring>
										<xsl:if test="number(regex-group(2))">
											<xsl:value-of select="regex-group(2)"/>
										</xsl:if>
									</xsl:matching-substring>
								</xsl:analyze-string>
							</xsl:if>
						</xsl:variable>

						<label>
							<xsl:value-of select="numishare:normalize_fields('dateRange', $lang)"/>
						</label>
						<input type="number" id="from_date" class="form-control" placeholder="{numishare:normalize_fields('fromDate', $lang)}">
							<xsl:if test="number($fromDate)">
								<xsl:attribute name="value" select="$fromDate"/>
							</xsl:if>
						</input>
						<select id="from_era" class="form-control">
							<option value="minus">
								<xsl:if test="number($fromDate) &lt; 0">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:text>BCE</xsl:text>
							</option>
							<option value="">
								<xsl:if test="not(string($fromDate)) or number($fromDate) &gt; 0">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:text>CE</xsl:text>
							</option>
						</select>
						<span> - </span>
						<input type="number" id="to_date" class="form-control" placeholder="{numishare:normalize_fields('toDate', $lang)}">
							<xsl:if test="number($toDate)">
								<xsl:attribute name="value" select="$toDate"/>
							</xsl:if>
						</input>
						<select id="to_era" class="form-control">
							<option value="minus">
								<xsl:if test="number($toDate) &lt; 0">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:text>BCE</xsl:text>
							</option>
							<option value="">
								<xsl:if test="not(string($toDate)) or number($toDate) &gt; 0">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:text>CE</xsl:text>
							</option>
						</select>
					</div>

					<xsl:if test="//config/ah_enabled = true()">
						<xsl:variable name="dateRange">
							<xsl:if test="contains($q, 'ah_num')">
								<xsl:for-each select="$tokenized_q[starts-with(., 'ah_num')][1]">
									<xsl:value-of select="substring-after(., ':')"/>
								</xsl:for-each>
							</xsl:if>
						</xsl:variable>
						
						<xsl:variable name="fromDate">
							<xsl:if test="string($dateRange)">
								<xsl:analyze-string select="$dateRange" regex="\[(.*) TO (.*)\]">
									<xsl:matching-substring>
										<xsl:if test="number(regex-group(1))">
											<xsl:value-of select="regex-group(1)"/>
										</xsl:if>
									</xsl:matching-substring>
								</xsl:analyze-string>
							</xsl:if>
						</xsl:variable>
						
						<xsl:variable name="toDate">
							<xsl:if test="string($dateRange)">
								<xsl:analyze-string select="$dateRange" regex="\[(.*) TO (.*)\]">
									<xsl:matching-substring>
										<xsl:if test="number(regex-group(2))">
											<xsl:value-of select="regex-group(2)"/>
										</xsl:if>
									</xsl:matching-substring>
								</xsl:analyze-string>
							</xsl:if>
						</xsl:variable>
						
						<div class="form-group" id="ah_dateRange">
							<label>
								<xsl:value-of select="numishare:normalize_fields('ah', $lang)"/>
							</label>
							<input type="number" id="ah_fromDate" class="form-control" placeholder="{numishare:normalize_fields('fromDate', $lang)}">
								<xsl:if test="number($fromDate)">
									<xsl:attribute name="value" select="$fromDate"/>
								</xsl:if>
							</input>
							<span> - </span>
							<input type="number" id="ah_toDate" class="form-control" placeholder="{numishare:normalize_fields('toDate', $lang)}">
								<xsl:if test="number($toDate)">
									<xsl:attribute name="value" select="$toDate"/>
								</xsl:if>
							</input>
						</div>
					</xsl:if>

					<div class="form-group">
						<label for="obv_leg_text">
							<xsl:value-of select="numishare:normalize_fields('obv_leg_text', $lang)"/>
						</label>
						<input type="text" class="form-control text-search" id="obv_leg_text">
							<xsl:if test="contains($q, 'obv_leg_text')">
								<xsl:attribute name="value">
									<xsl:for-each select="$tokenized_q[starts-with(., 'obv_leg_text')][1]">
										<xsl:value-of select="substring-after(., ':')"/>
									</xsl:for-each>
								</xsl:attribute>
							</xsl:if>
						</input>
					</div>
					<div class="form-group">
						<label for="rev_leg_text">
							<xsl:value-of select="numishare:normalize_fields('rev_leg_text', $lang)"/>
						</label>
						<input type="text" class="form-control text-search" id="rev_leg_text">
							<xsl:if test="contains($q, 'rev_leg_text')">
								<xsl:attribute name="value">
									<xsl:for-each select="$tokenized_q[starts-with(., 'rev_leg_text')][1]">
										<xsl:value-of select="substring-after(., ':')"/>
									</xsl:for-each>
								</xsl:attribute>
							</xsl:if>
						</input>
					</div>
					<div class="form-group">
						<label for="obv_type_text">
							<xsl:value-of select="numishare:normalize_fields('obv_type_text', $lang)"/>
						</label>
						<input type="text" class="form-control text-search" id="obv_type_text">
							<xsl:if test="contains($q, 'obv_type_text')">
								<xsl:attribute name="value">
									<xsl:for-each select="$tokenized_q[starts-with(., 'obv_type_text')][1]">
										<xsl:value-of select="substring-after(., ':')"/>
									</xsl:for-each>
								</xsl:attribute>
							</xsl:if>
						</input>
					</div>
					<div class="form-group">
						<label for="rev_type_text">
							<xsl:value-of select="numishare:normalize_fields('rev_type_text', $lang)"/>
						</label>
						<input type="text" class="form-control text-search" id="rev_type_text">
							<xsl:if test="contains($q, 'rev_type_text')">
								<xsl:attribute name="value">
									<xsl:for-each select="$tokenized_q[starts-with(., 'rev_type_text')][1]">
										<xsl:value-of select="substring-after(., ':')"/>
									</xsl:for-each>
								</xsl:attribute>
							</xsl:if>
						</input>
					</div>

					<xsl:if test="//config/facets/facet[@role = 'symbol']">
						<h3>
							<xsl:value-of select="numishare:normalize_fields('symbol', $lang)"/>
						</h3>

						<xsl:if test="//lst[contains(@name, 'symbol_obv_') and number(int) &gt; 0]">
							<h5>
								<xsl:value-of select="numishare:normalize_fields('obverse', $lang)"/>
							</h5>
							<xsl:apply-templates select="//lst[contains(@name, 'symbol_obv') and number(int) &gt; 0]" mode="facet"/>
						</xsl:if>
						<xsl:if test="//lst[contains(@name, 'symbol_rev_') and number(int) &gt; 0]">
							<h5>
								<xsl:value-of select="numishare:normalize_fields('reverse', $lang)"/>
							</h5>
							<xsl:apply-templates select="//lst[contains(@name, 'symbol_rev') and number(int) &gt; 0]" mode="facet"/>
						</xsl:if>


					</xsl:if>

					<!-- physical attributes are only visible in specimen collections -->
					<xsl:if test="$collection_type = 'object'">
						<h3>Physical Attributes</h3>
						
						<!-- parse weight from query parameter -->
						<xsl:variable name="weight">
							<xsl:if test="contains($q, 'weight_num')">
								<xsl:for-each select="$tokenized_q[starts-with(., 'weight_num')][1]">
									<xsl:value-of select="substring-after(., ':')"/>
								</xsl:for-each>
							</xsl:if>
						</xsl:variable>
						
						<xsl:variable name="weightMin">
							<xsl:if test="string($weight)">
								<xsl:analyze-string select="$weight" regex="\[(.*) TO (.*)\]">
									<xsl:matching-substring>
										<xsl:if test="number(regex-group(1))">
											<xsl:value-of select="regex-group(1)"/>
										</xsl:if>
									</xsl:matching-substring>
								</xsl:analyze-string>
							</xsl:if>
						</xsl:variable>
						
						<xsl:variable name="weightMax">
							<xsl:if test="string($weight)">
								<xsl:analyze-string select="$weight" regex="\[(.*) TO (.*)\]">
									<xsl:matching-substring>
										<xsl:if test="number(regex-group(2))">
											<xsl:value-of select="regex-group(2)"/>
										</xsl:if>
									</xsl:matching-substring>
								</xsl:analyze-string>
							</xsl:if>
						</xsl:variable>
						
						<!-- parse diameter from query parameter -->
						<xsl:variable name="diameter">
							<xsl:if test="contains($q, 'diameter_num')">
								<xsl:for-each select="$tokenized_q[starts-with(., 'diameter_num')][1]">
									<xsl:value-of select="substring-after(., ':')"/>
								</xsl:for-each>
							</xsl:if>
						</xsl:variable>
						
						<xsl:variable name="diameterMin">
							<xsl:if test="string($diameter)">
								<xsl:analyze-string select="$diameter" regex="\[(.*) TO (.*)\]">
									<xsl:matching-substring>
										<xsl:if test="number(regex-group(1))">
											<xsl:value-of select="regex-group(1)"/>
										</xsl:if>
									</xsl:matching-substring>
								</xsl:analyze-string>
							</xsl:if>
						</xsl:variable>
						
						<xsl:variable name="diameterMax">
							<xsl:if test="string($diameter)">
								<xsl:analyze-string select="$diameter" regex="\[(.*) TO (.*)\]">
									<xsl:matching-substring>
										<xsl:if test="number(regex-group(2))">
											<xsl:value-of select="regex-group(2)"/>
										</xsl:if>
									</xsl:matching-substring>
								</xsl:analyze-string>
							</xsl:if>
						</xsl:variable>

						<div class="form-group">
							<label>
								<xsl:value-of select="numishare:normalize_fields('weight', $lang)"/>
							</label>
							<span>From: </span>
							<input type="number" step="0.1" id="weight_min" class="form-control technical-input" placeholder="From">
								<xsl:if test="number($weightMin)">
									<xsl:attribute name="value" select="$weightMin"/>
								</xsl:if>
							</input>
							<span>To: </span>
							<input type="number" step="0.1" id="weight_max" class="form-control technical-input" placeholder="To">
								<xsl:if test="number($weightMax)">
									<xsl:attribute name="value" select="$weightMax"/>
								</xsl:if>
							</input>
						</div>
						<div class="form-group">
							<label>
								<xsl:value-of select="numishare:normalize_fields('diameter', $lang)"/>
							</label>
							<span>From: </span>
							<input type="number" id="diameter_min" class="form-control technical-input" placeholder="From">								
								<xsl:if test="number($diameterMin)">
									<xsl:attribute name="value" select="$diameterMin"/>
								</xsl:if>
							</input>
							<span>To: </span>
							<input type="number" id="diameter_max" class="form-control technical-input" placeholder="To">
								<xsl:if test="number($diameterMax)">
									<xsl:attribute name="value" select="$diameterMax"/>
								</xsl:if>
							</input>
						</div>

						<xsl:for-each select="//config/facets/facet[@role = 'physical' and @type = 'list']">
							<xsl:variable name="field" select="."/>

							<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
						</xsl:for-each>
					</xsl:if>

					<xsl:if test="//config/facets/facet[@role = 'subject']">
						<h3>
							<xsl:value-of select="numishare:normalize_fields('subjectSet', $lang)"/>
						</h3>

						<xsl:for-each select="//config/facets/facet[@role = 'subject' and @type = 'list']">
							<xsl:variable name="field" select="."/>

							<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
						</xsl:for-each>
					</xsl:if>


					<!-- if it is an object collection, display provenance, including findspot and hoard -->
					<xsl:if test="$collection_type = 'object'">
						<xsl:if test="//config/facets/facet[@role = 'provenance']">
							<h3>
								<xsl:value-of select="numishare:normalize_fields('provenance', $lang)"/>
							</h3>

							<xsl:for-each select="//config/facets/facet[@role = 'provenance' and @type = 'list']">
								<xsl:variable name="field" select="."/>

								<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
							</xsl:for-each>
						</xsl:if>
					</xsl:if>


					<xsl:if test="//config/facets/facet[@role = 'reference'] and $mode = 'search'">
						<h3>
							<xsl:value-of select="numishare:normalize_fields('refDesc', $lang)"/>
						</h3>

						<div class="form-group">
							<label for="reference_text">
								<xsl:value-of select="numishare:normalize_fields('reference_text', $lang)"/>
							</label>
							<input type="text" class="form-control text-search" id="reference_text"/>
						</div>

						<xsl:for-each select="//config/facets/facet[@role = 'reference' and @type = 'list']">
							<xsl:variable name="field" select="."/>

							<xsl:apply-templates select="//lst[@name = $field and number(int) &gt; 0]" mode="facet"/>
						</xsl:for-each>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>

			<!-- hidden params -->
			<input type="hidden" name="q" id="facet_form_query" value="*:*"/>

			<xsl:if test="string($langParam)">
				<input type="hidden" name="lang" value="{$lang}"/>
			</xsl:if>

			<br/>
			<button type="submit" id="search_button" class="btn btn-default">
				<i class="glyphicon glyphicon-search"/>
				<xsl:choose>
					<xsl:when test="$mode = 'search'">Search</xsl:when>
					<xsl:when test="$mode = 'maps'">Refine Map</xsl:when>
				</xsl:choose>
			</button>
		</form>
	</xsl:template>

	<xsl:template name="search_forms">
		<div class="search-form">
			<p>To conduct a free text search select ‘Keyword’ on the drop-down menu and enter the text for which you wish to search. The search allows wildcard searches with the
					<b>*</b> and <b>?</b> characters and exact string matches by surrounding phrases by double quotes (like Google). <a
					href="http://lucene.apache.org/java/2_9_1/queryparsersyntax.html#Term%20Modifiers" target="_blank">See the Lucene query syntax</a> documentation for more
				information.</p>
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
					<xsl:when test="$pipeline = 'analyze'">
						<input type="submit" value="{numishare:normalizeLabel('visualize_filter_list', $lang)}" class="btn btn-default"/>
					</xsl:when>
					<xsl:when test="$pipeline = 'visualize'">
						<input type="submit" value="{numishare:normalizeLabel('visualize_add_query', $lang)}" class="btn btn-default"/>
					</xsl:when>
					<xsl:otherwise>
						<input type="submit" value="{numishare:normalizeLabel('header_search', $lang)}" class="btn btn-default"/>
					</xsl:otherwise>
				</xsl:choose>

			</form>

			<xsl:if test="$pipeline = 'visualize'">
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

	<xsl:template name="text-search-templates">
		<div class="form-group" id="entity-search">
			<input type="text" class="form-control text-search"/>
			<select class="category_list form-control">
				<xsl:for-each select="//config/facets/facet[@role = 'entity' and @type = 'text']">
					<option value="{.}">
						<xsl:value-of select="numishare:normalize_fields(., $lang)"/>
					</option>
				</xsl:for-each>
			</select>
			<a class="removeBtn hidden" href="#">
				<span class="glyphicon glyphicon-remove"/>
			</a>
		</div>

		<div class="form-group" id="place-search">
			<input type="text" class="form-control text-search"/>
			<select class="category_list form-control">
				<xsl:for-each select="//config/facets/facet[@role = 'place' and @type = 'text']">
					<option value="{.}">
						<xsl:value-of select="numishare:normalize_fields(., $lang)"/>
					</option>
				</xsl:for-each>
			</select>
			<a class="removeBtn hidden" href="#">
				<span class="glyphicon glyphicon-remove"/>
			</a>
		</div>

		<div class="form-group" id="provenance-search">
			<input type="text" class="form-control text-search"/>
			<select class="category_list form-control">
				<xsl:for-each select="//config/facets/facet[@role = 'provenance' and @type = 'text']">
					<option value="{.}">
						<xsl:value-of select="numishare:normalize_fields(., $lang)"/>
					</option>
				</xsl:for-each>
			</select>
			<a class="removeBtn hidden" href="#">
				<span class="glyphicon glyphicon-remove"/>
			</a>
		</div>

		<div class="form-group" id="subject-search">
			<input type="text" class="form-control text-search"/>
			<select class="category_list form-control">
				<xsl:for-each select="//config/facets/facet[@role = 'subject' and @type = 'text']">
					<option value="{.}">
						<xsl:value-of select="numishare:normalize_fields(., $lang)"/>
					</option>
				</xsl:for-each>
			</select>
			<a class="removeBtn hidden" href="#">
				<span class="glyphicon glyphicon-remove"/>
			</a>
		</div>

		<div class="form-group" id="reference-search">
			<input type="text" class="form-control text-search"/>
			<select class="category_list form-control">
				<xsl:for-each select="//config/facets/facet[@role = 'reference' and @type = 'text']">
					<option value="{.}">
						<xsl:value-of select="numishare:normalize_fields(., $lang)"/>
					</option>
				</xsl:for-each>
			</select>
			<a class="removeBtn hidden" href="#">
				<span class="glyphicon glyphicon-remove"/>
			</a>
		</div>

		<div class="form-group" id="typology-search">
			<input type="text" class="form-control text-search"/>
			<select class="category_list form-control">
				<xsl:for-each select="//config/facets/facet[@role = 'typology' and @type = 'text']">
					<option value="{.}">
						<xsl:value-of select="numishare:normalize_fields(., $lang)"/>
					</option>
				</xsl:for-each>
			</select>
			<a class="removeBtn hidden" href="#">
				<span class="glyphicon glyphicon-remove"/>
			</a>
		</div>
	</xsl:template>

	<!-- ************** SEARCH DROP-DOWN MENUS ************** -->
	<xsl:template name="search_options">
		<xsl:variable name="fields">
			<xsl:choose>
				<xsl:when test="$collection_type = 'hoard'">
					<xsl:text>fulltext,artist_facet,authority_facet,taq_num,coinType_facet,deity_facet,denomination_facet,dynasty_facet,issuer_facet,legend_text,obv_leg_text,rev_leg_text,maker_facet,manufacture_facet,material_facet,mint_facet,objectType_facet,tpq_num,portrait_facet,recordId,reference_text,region_facet,type_text,obv_type_text,rev_type_text,year_num</xsl:text>
				</xsl:when>
				<xsl:when test="$collection_type = 'cointype' or $collection_type = 'die'">
					<xsl:text>fulltext,artist_facet,authority_facet,typeNumber,deity_facet,denomination_facet,dynasty_facet,issuer_facet,legend_text,obv_leg_text,rev_leg_text,maker_facet,manufacture_facet,material_facet,mint_facet,objectType_facet,portrait_facet,recordId,reference_text,region_facet,type_text,obv_type_text,rev_type_text,year_num</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>fulltext,artist_facet,authority_facet,coinType_facet,deity_facet,denomination_facet,diameter_num,dynasty_facet,issuer_facet,legend_text,obv_leg_text,rev_leg_text,maker_facet,manufacture_facet,material_facet,mint_facet,objectType_facet,portrait_facet,recordId,reference_text,region_facet,type_text,obv_type_text,rev_type_text,weight_num,year_num</xsl:text>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:variable>

		<xsl:for-each select="tokenize($fields, ',')">
			<xsl:variable name="name" select="."/>
			<xsl:choose>
				<xsl:when test="contains($name, '_facet')">
					<!-- display only those search options when their facet equivalent has hits -->
					<xsl:if test="$facets//lst[@name = $name] or boolean(index-of($facets, $name)) = true()">
						<option value="{$name}" class="search_option">
							<xsl:value-of select="numishare:normalize_fields($name, $lang)"/>
						</option>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<!-- display those search options when they aren't connected to facets -->
					<option value="{$name}" class="search_option">
						<xsl:value-of select="numishare:normalize_fields($name, $lang)"/>
					</option>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
