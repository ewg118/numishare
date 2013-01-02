<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="http://code.google.com/p/numishare/" xmlns:cinclude="http://apache.org/cocoon/include/1.0" exclude-result-prefixes="xs cinclude numishare"
	version="2.0">
	<xsl:include href="../search_segments.xsl"/>
	<xsl:param name="q"/>
	<xsl:param name="start"/>
	<xsl:param name="collection"/>
	<xsl:param name="department"/>
	<xsl:param name="section"/>

	<xsl:template match="/">
		<xsl:apply-templates select="//lst[@name='facet_fields']"/>
	</xsl:template>

	<xsl:template match="lst[@name='facet_fields']">
		<h1>Search the department</h1>

		<!-- set department-specific facet fields here -->
		<div class="collection_search">
			<h3>Keyword Search</h3>
			<input type="text" id="cs_text"/>
		</div>
		<xsl:choose>
			<xsl:when test="$department='United States'">
				<xsl:apply-templates
					select="lst[@name = 'category_facet' or @name = 'mint_facet' or @name = 'denomination_facet' or @name='material_facet' or @name='century_num' or @name='persname_facet']" mode="facet"/>
				<hr/>
				<xsl:apply-templates
					select="lst[number(int[@name='numFacetTerms']) &gt; 0 and @name != 'category_facet' and @name != 'mint_facet' and @name != 'denomination_facet' and @name != 'material_facet' and @name != 'century_num' and @name != 'persname_facet' and @name != 'dynasty_facet'  and @name != 'era_facet']"
					mode="facet"/>
			</xsl:when>
			<xsl:when test="$department='Greek'">
				<xsl:apply-templates
					select="lst[@name = 'category_facet' or @name = 'mint_facet' or @name = 'denomination_facet' or @name='material_facet' or @name='century_num' or @name='persname_facet']" mode="facet"/>
				<hr/>
				<xsl:apply-templates
					select="lst[number(int[@name='numFacetTerms']) &gt; 0 and @name != 'category_facet' and @name != 'mint_facet' and @name != 'denomination_facet' and @name != 'material_facet' and @name != 'century_num' and @name != 'persname_facet' and @name != 'dynasty_facet']"
					mode="facet"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates
					select="lst[@name = 'category_facet' or @name = 'mint_facet' or @name = 'denomination_facet' or @name='material_facet' or @name='century_num' or @name='persname_facet']" mode="facet"/>
				<hr/>
				<xsl:apply-templates
					select="lst[number(int[@name='numFacetTerms']) &gt; 0 and @name != 'category_facet' and @name != 'mint_facet' and @name != 'denomination_facet' and @name != 'material_facet' and @name != 'century_num' and @name != 'persname_facet']"
					mode="facet"/>
			</xsl:otherwise>
		</xsl:choose>
		<form action="results" id="{$collection}-widget" title="{$department}">
			<input type="hidden" name="q"/>
			<!--<input type="hidden" name="section" value="collection"/>
			<input type="hidden" name="origin" value="{$collection}"/>-->
			<br/>
			<div>
				<b>Has Images:</b>
				<input type="checkbox" id="imagesavailable"/>
			</div>
			<div class="submit_div">
				<input type="submit" value="Search the Department" id="search_button" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only ui-state-focus"/>
			</div>
		</form>
	</xsl:template>

	<xsl:template match="lst" mode="facet">
		<xsl:choose>
			<!-- display category tree -->
			<xsl:when test="@name = 'category_facet'">
				<!--<h2>Category</h2>-->
				<xsl:choose>
					<xsl:when test="$department = 'United States'">
						<xsl:call-template name="usa_categories"/>
					</xsl:when>
					<xsl:otherwise>
						<button class="ui-multiselect ui-widget ui-state-default ui-corner-all" type="button" title="Category" aria-haspopup="true" style="width: 200px;" id="{@name}_link" label="{$q}">
							<span class="ui-icon ui-icon-triangle-2-n-s"/>
							<span>Category</span>
						</button>
						<div class="ui-multiselect-menu ui-widget ui-widget-content ui-corner-all" style="width: 192px;">
							<div class="ui-widget-header ui-corner-all ui-multiselect-header ui-helper-clearfix ui-multiselect-hasfilter">
								<ul class="ui-helper-reset">
									<li class="ui-multiselect-close">
										<a class="ui-multiselect-close category-close" href="#"> close<span class="ui-icon ui-icon-circle-close"/>
										</a>
									</li>
								</ul>
							</div>
							<ul class="category-multiselect-checkboxes ui-helper-reset" id="{@name}-list" style="height: 175px;"/>
						</div>
					</xsl:otherwise>
				</xsl:choose>

				<br/>
			</xsl:when>
			<!-- ignore the department.  it is already set -->
			<xsl:when test="@name = 'department_facet'"/>
			<xsl:otherwise>
				<xsl:variable name="title">
					<xsl:value-of select="numishare:normalize_fields(@name)"/>
				</xsl:variable>

				<xsl:variable name="count" select="number(int[@name='numFacetTerms'])"/>

				<xsl:variable name="mincount" as="xs:integer">
					<xsl:choose>
						<xsl:when test="$count &gt; 500">
							<xsl:value-of select="ceiling($count div 500)"/>
						</xsl:when>
						<xsl:otherwise>1</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!--<h2>
					<xsl:value-of select="$title"/>
				</h2>-->
				<select id="{@name}-select" multiple="multiple" class="multiselect" size="10" title="{$title}" q="department_facet:&#x022;{$department}&#x022;" mincount="{$mincount}"/>
				<br/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>



	<xsl:template name="usa_categories">
		<button class="ui-multiselect ui-widget ui-state-default ui-corner-all" type="button" title="Category" aria-haspopup="true" style="width: 200px;" id="{@name}_link" label="{$q}">
			<span class="ui-icon ui-icon-triangle-2-n-s"/>
			<span>Category</span>
		</button>
		<div class="ui-multiselect-menu ui-widget ui-widget-content ui-corner-all" style="width: 192px">
			<ul class="ui-multiselect-checkboxes ui-helper-reset" id="{@name}-list" style="height: 175px;">
				<li class="term">
					<span class="expand_usa_category">
						<img src="images/plus.gif" alt="expand"/>
					</span>
					<input type="checkbox" value="L2|Colonial"/>
					<xsl:text>Colonial</xsl:text>
					<ul class="category_level" style="display:none">
						<li class="term">
							<span class="expand_usa_category">
								<img src="images/plus.gif" alt="expand"/>
							</span>
							<input type="checkbox" value="L3|Massachusetts"/>
							<xsl:text>Massachusetts</xsl:text>
							<ul class="category_level" style="display:none">
								<li class="term">
									<input type="checkbox" value="L4|New England"/>
									<xsl:text>New England</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Willow Tree"/>
									<xsl:text>Willow Tree</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Oak Tree"/>
									<xsl:text>Oak Tree</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Pine Tree"/>
									<xsl:text>Pine Tree</xsl:text>
								</li>
							</ul>

						</li>
						<li class="term">
							<span class="expand_usa_category">
								<img src="images/plus.gif" alt="expand"/>
							</span>
							<input type="checkbox" value="L3|Private"/>
							<xsl:text>Private</xsl:text>
							<ul class="category_level" style="display:none">
								<li class="term">
									<input type="checkbox" value="L4|American Plantation Tokens"/>
									<xsl:text>American Plantation Tokens</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Rosa Americana"/>
									<xsl:text>Rosa Americana</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Higley"/>
									<xsl:text>Higley</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Lord Baltimore"/>
									<xsl:text>Lord Baltimore</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Newby St. Patrick"/>
									<xsl:text>Newby St. Patrick</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|New Yorke in America Tokens"/>
									<xsl:text>New Yorke in America Tokens</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Carolina Elephant Tokens"/>
									<xsl:text>Carolina Elephant Tokens</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|London Elephant Tokens"/>
									<xsl:text>London Elephant Tokens</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Sommer Island"/>
									<xsl:text>Sommer Island</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Tory Coppers"/>
									<xsl:text>Tory Coppers</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Virginia Halfpennies"/>
									<xsl:text>Virginia Halfpennies</xsl:text>
								</li>
							</ul>
						</li>
					</ul>
				</li>
				<li class="term">
					<span class="expand_usa_category">
						<img src="images/plus.gif" alt="expand"/>
					</span>
					<input type="checkbox" value="L2|Pre-Federal"/>
					<xsl:text>Pre-Federal</xsl:text>
					<ul class="category_level" style="display:none">
						<li class="term">
							<input type="checkbox" value="L3|Continental Currency"/>
							<xsl:text>Continental Currency</xsl:text>
						</li>
						<li class="term">
							<input type="checkbox" value="L3|Confederatio"/>
							<xsl:text>Confederatio</xsl:text>
						</li>
						<li class="term">
							<input type="checkbox" value="L3|Immunis Columbia"/>
							<xsl:text>Immunis Columbia</xsl:text>
						</li>
						<li class="term">
							<input type="checkbox" value="L3|Machin's Mills"/>
							<xsl:text>Machin's Mills</xsl:text>
						</li>
						<li class="term">
							<input type="checkbox" value="L3|Washington Pieces"/>
							<xsl:text>Washington Pieces</xsl:text>
						</li>
						<li class="term">
							<input type="checkbox" value="L3|Connecticut"/>
							<xsl:text>Connecticut</xsl:text>
						</li>
						<li class="term">
							<input type="checkbox" value="L3|Massachusetts"/>
							<xsl:text>Massachusetts</xsl:text>
						</li>
						<li class="term">
							<input type="checkbox" value="L3|New Hampshiare"/>
							<xsl:text>New Hampshire</xsl:text>
						</li>
						<li class="term">
							<input type="checkbox" value="L3|New Jersey"/>
							<xsl:text>New Jersey</xsl:text>
						</li>
						<li class="term">
							<input type="checkbox" value="L3|New York"/>
							<xsl:text>New York</xsl:text>
						</li>
						<li class="term">
							<input type="checkbox" value="L3|Vermont"/>
							<xsl:text>Vermont</xsl:text>
						</li>
						<li class="term">
							<span class="expand_usa_category">
								<img src="images/plus.gif" alt="expand"/>
							</span>
							<input type="checkbox" value="L3|Private"/>
							<xsl:text>Private</xsl:text>
							<ul class="category_level" style="display:none">
								<li class="term">
									<input type="checkbox" value="L4|Albany Church Pennies"/>
									<xsl:text>Albany Church Pennies</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Associate Church Tokens"/>
									<xsl:text>Associate Church Tokens</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Auctori Plebis"/>
									<xsl:text>Auctori Plebis</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Bar Coppers"/>
									<xsl:text>Bar Coppers</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Castorland Medals"/>
									<xsl:text>Castorland Medals</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Chalmers's Issues"/>
									<xsl:text>Chalmers's Issues</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Ephraim Basher"/>
									<xsl:text>Ephraim Basher</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Franklin Press Tokens"/>
									<xsl:text>Franklin Press Tokens</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Mott Tokens"/>
									<xsl:text>Mott Tokens</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Myddelton Tokens"/>
									<xsl:text>Myddelton Tokens</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|North America Tokens"/>
									<xsl:text>North America Tokens</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Standish Barry"/>
									<xsl:text>Standish Barry</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Starry Pyramid"/>
									<xsl:text>Starry Pyramid</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Talbot, Allum and Lee Tokens"/>
									<xsl:text>Talbot, Allum and Lee Tokens</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Theatre at New York Tokens"/>
									<xsl:text>Theatre at New York Tokens</xsl:text>
								</li>
							</ul>
						</li>
					</ul>

				</li>
				<li class="term">
					<span class="expand_usa_category">
						<img src="images/plus.gif" alt="expand"/>
					</span>
					<input type="checkbox" value="L2|Federal"/>
					<xsl:text>Federal</xsl:text>
					<ul class="category_level" style="display:none">
						<li class="term">
							<input type="checkbox" value="L3|Large Cents"/>
							<xsl:text>Large Cents</xsl:text>
						</li>
						<li class="term">
							<input type="checkbox" value="L3|Small Cent"/>
							<xsl:text>Small Cent</xsl:text>
						</li>
						<li class="term">
							<input type="checkbox" value="L3|Commemorative"/>
							<xsl:text>Commemorative</xsl:text>
						</li>
						<li class="term">
							<input type="checkbox" value="L3|Patterns"/>
							<xsl:text>Patterns</xsl:text>
						</li>
					</ul>

				</li>
				<li class="term">
					<span class="expand_usa_category">
						<img src="images/plus.gif" alt="expand"/>
					</span>
					<input type="checkbox" value="L2|Civil War"/>
					<xsl:text>Civil War</xsl:text>
					<ul class="category_level" style="display:none">
						<li class="term">
							<input type="checkbox" value="L3|Confederate States of America"/>
							<xsl:text>Confederate States of America</xsl:text>
						</li>
					</ul>

				</li>
				<li class="term">
					<span class="expand_usa_category">
						<img src="images/plus.gif" alt="expand"/>
					</span>
					<input type="checkbox" value="L2|Private"/>
					<xsl:text>Private</xsl:text>
					<ul class="category_level" style="display:none">
						<li class="term">
							<span class="expand_usa_category">
								<img src="images/plus.gif" alt="expand"/>
							</span>
							<input type="checkbox" value="L3|Gold Coins and Assay"/>
							<xsl:text>Gold Coins and Assay</xsl:text>

							<ul class="category_level" style="display:none">
								<li class="term">
									<input type="checkbox" value="L4|Alaska"/>
									<xsl:text>Alaska</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|California"/>
									<xsl:text>California</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Colorado"/>
									<xsl:text>Colorado</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Louisiana"/>
									<xsl:text>Louisiana</xsl:text>
								</li>
								<li class="term">
									<span class="expand_usa_category">
										<img src="images/plus.gif" alt="expand"/>
									</span>
									<input type="checkbox" value="L4|North Carolina"/>
									<xsl:text>North Carolina</xsl:text>
									<ul class="category_level" style="display:none">
										<li class="term">
											<input type="checkbox" value="L5|Bechtler"/>
											<xsl:text>Bechtler</xsl:text>
										</li>
									</ul>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Oregon"/>
									<xsl:text>Oregon</xsl:text>
								</li>
								<li class="term">
									<input type="checkbox" value="L4|Utah"/>
									<xsl:text>Utah</xsl:text>
								</li>
							</ul>
						</li>
					</ul>
				</li>
				<li class="term">
					<input type="checkbox" value="L2|Modern Forgery"/>
					<xsl:text>Modern Forgery</xsl:text>
					<ul class="category_level" style="display:none"/>

				</li>
			</ul>
		</div>
	</xsl:template>

</xsl:stylesheet>
