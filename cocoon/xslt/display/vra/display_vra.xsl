<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:output method="html" encoding="UTF-8"/>
	<xsl:include href="../../header.xsl"/>
	<xsl:include href="../../footer.xsl"/>
	<xsl:param name="q"/>
	<xsl:param name="start"/>
	<xsl:param name="mode"/>	
	<xsl:param name="exist-config"/>

	<xsl:param name="doc_id">
		<xsl:value-of select="//work/@id"/>
	</xsl:param>

	<!-- path to javascript, images, search results, etc. should be ../../ from this path.  display_path param not necessary for any files gathered from the ajax-driven compare mode -->
	<xsl:param name="display_path">
		<xsl:if test="not(string($mode))">
			<xsl:text>../../</xsl:text>
		</xsl:if>
	</xsl:param>
	<xsl:param name="title">
		<xsl:value-of select="normalize-space(descendant::work/titleSet/display)"/>
	</xsl:param>
	<xsl:param name="date">
		<xsl:value-of select="normalize-space(descendant::work/dateSet/display)"/>
	</xsl:param>
	<xsl:param name="format">
		<xsl:value-of select="normalize-space(descendant::work/worktypeSet/worktype[1])"/>
	</xsl:param>
	<xsl:param name="source">vra</xsl:param>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="document(concat($exist-config, '/config.xml'))/config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of
						select="concat(upper-case(substring($format, 1, 1)), substring($format, 2))"/>
					<xsl:text> of </xsl:text>
					<xsl:value-of select="$title"/>
					<xsl:if test="string($date)">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="$date"/>
					</xsl:if>
				</title>
				<link rel="stylesheet" type="text/css"
					href="http://yui.yahooapis.com/2.8.2r1/build/grids/grids-min.css"/>
				<link rel="stylesheet" type="text/css"
					href="http://yui.yahooapis.com/2.8.2r1/build/reset-fonts-grids/reset-fonts-grids.css"/>
				<link rel="stylesheet" type="text/css"
					href="http://yui.yahooapis.com/2.8.2r1/build/base/base-min.css"/>
				<link rel="stylesheet" type="text/css"
					href="http://yui.yahooapis.com/2.8.2r1/build/fonts/fonts-min.css"/>
				<!-- Core + Skin CSS -->
				<link rel="stylesheet" type="text/css"
					href="http://yui.yahooapis.com/2.8.2r1/build/menu/assets/skins/sam/menu.css"/>
				<link rel="stylesheet" type="text/css"
					href="http://yui.yahooapis.com/2.8.2r1/build/tabview/assets/skins/sam/tabview.css"/>				
				
				<link type="text/css" href="{$display_path}style.css" rel="stylesheet"/>
				<script type="text/javascript" src="{$display_path}javascript/jquery-1.3.2.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/display_menu_tabs.js"/>
				<script type="text/javascript" src="{$display_path}javascript/display_gallery.js"/>
			</head>			
			<body class="yui-skin-sam">
				<div id="doc4" class="yui-t6">
					<xsl:call-template name="header"/>
					<div id="bd">
						<div id="yui-main">							
							<xsl:apply-templates select="descendant::work"/>
						</div>
					</div>
					<xsl:call-template name="footer"/>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="work">
		<div class="yui-g">
			<xsl:call-template name="print"/>
			<div class="yui-u first">				
				<xsl:if test="//image">
					<xsl:call-template name="image_box"/>
				</xsl:if>
			</div>
			<div class="yui-u">
				<h1>
					<xsl:value-of select="normalize-space(titleSet/title)"/>
					<xsl:if test="string(dateSet/display)">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="normalize-space(dateSet/display)"/>
					</xsl:if>
				</h1>
				<div id="demo" class="yui-navset">
					<ul class="yui-nav">
						<li class="selected" id="metadata_link">
							<a href="#tab1">
								<em>Summary</em>
							</a>
						</li>
						<xsl:if
							test="descriptionSet">
							<li id="commentary_link">
								<a href="#tab2">
									<em>Commentary</em>
								</a>
							</li>
						</xsl:if>
						
					</ul>
					<div class="yui-content">
						<div id="metadata">
							<div class="metadata_section">
								<h3>Descriptive Information</h3>
								<ul>
									<xsl:call-template name="descriptive_information"/>
								</ul>
							</div>
							
							<xsl:if test="textrefSet or sourceSet">
								<div class="metadata_section">
									<h3>References</h3>
									<xsl:apply-templates select="textrefSet | sourceSet"/>
								</div>
							</xsl:if>
							
							<xsl:if test="stateEditionSet or rightsSet or locationSet/location[@type='repository']">
								<div class="metadata_section">
									<h3>Archival Data</h3>
									<ul>
										<xsl:call-template name="archival_data"/>
									</ul>
								</div>
							</xsl:if>
							
							<div class="metadata_section">
								<h3>Index Terms</h3>
								<xsl:call-template name="index_terms"/>
							</div>
						</div>
						<div id="commentary" class="hidden">
							<xsl:apply-templates select="descriptionSet"/>
						</div>
					</div>
				</div>
			</div>
			<xsl:call-template name="print"/>
		
		</div>			
	</xsl:template>

	<xsl:template name="descriptive_information">
		<xsl:if test="agentSet/display">
			<b>Origination: </b>
			<xsl:value-of select="agentSet/display"/>
			<br/>
		</xsl:if>
		<xsl:if test="dateSet/display">
			<b>Date: </b>
			<xsl:value-of select="dateSet/display"/>
			<br/>
		</xsl:if>
		<xsl:if test="string(normalize-space(culturalContextSet/culturalContext[1]))">
			<b>Cultural Context: </b>
			<xsl:for-each select="ulturalContextSet/culturalContext">
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:if test="not(position() = last())">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<br/>
		</xsl:if>
		<xsl:if test="string(normalize-space(worktypeSet/worktype[1]))">
			<b>Format: </b>
			<xsl:for-each select="worktypeSet/worktype">
				<a
					href="{$display_path}results?q=objectType_facet:&#x0022;{normalize-space(.)}&#x0022;"
					style="text-transform:capitalize;">
					<xsl:value-of select="normalize-space(.)"/>
				</a>
				<xsl:if test="not(position() = last())">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<br/>
		</xsl:if>
		<xsl:if test="string(normalize-space(techniqueSet/technique[1]))">
			<b>Technique: </b>
			<xsl:for-each select="techniqueSet/technique">
				<a
					href="{$display_path}results?q=technique_facet:&#x0022;{normalize-space(.)}&#x0022;"
					style="text-transform:capitalize;">
					<xsl:value-of select="normalize-space(.)"/>
				</a>
				<xsl:if test="not(position() = last())">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<br/>
		</xsl:if>
		<xsl:if test="string(normalize-space(styleSet/style[1]))">
			<b>Style: </b>
			<xsl:for-each select="styleSet/style">
				<a
					href="{$display_path}results?q=style_facet:&#x0022;{normalize-space(.)}&#x0022;"
					style="text-transform:capitalize;">
					<xsl:value-of select="normalize-space(.)"/>
				</a>
				<xsl:if test="not(position() = last())">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<br/>
		</xsl:if>
		<xsl:apply-templates select="materialSet"/>
		<xsl:apply-templates select="measurementsSet"/>
		<xsl:apply-templates select="inscriptionSet"/>
	</xsl:template>

	<xsl:template name="archival_data">
		<xsl:if test="string(normalize-space(@source))">
			<b>Collection: </b>
			<a
				href="{$display_path}results?q=collection_facet:&#x0022;{normalize-space(@source)}&#x0022;">
				<xsl:value-of select="normalize-space(@source)"/>
			</a>
			<br/>
		</xsl:if>
		<xsl:apply-templates
			select="locationSet/location[@type='repository'] | locationSet/location[@type='exhibition'] | locationSet/location[@type='formerOwner'] | locationSet/location[@type='formerRepository'] | locationSet/location[@type='installation'] | locationSet/location[@type='intended'] | locationSet/location[@type='owner']"
			mode="archival_data"/>
		<xsl:if test="string(normalize-space(stateEditionSet/display))">
			<b>State Edition: </b>
			<xsl:value-of select="normalize-space(stateEditionSet/display)"/>
		</xsl:if>
		<xsl:if test="string(normalize-space(rightsSet/display))">
			<b>Rights Statement: </b>
			<xsl:value-of select="normalize-space(rightsSet/display)"/>
			<xsl:if test="string(normalize-space(rightsSet/notes[1]))">
				<xsl:text>. </xsl:text>
				<xsl:for-each select="rightsSet/notes">
					<xsl:value-of select="."/>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="locationSet/location" mode="archival_data">
		<b>
			<xsl:value-of select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
			<xsl:text>:</xsl:text>
		</b>
		<ul>
			<xsl:for-each select="name">
				<li>
					<xsl:choose>
						<xsl:when test="@type='geographic'">
							<xsl:choose>
								<xsl:when test="string(normalize-space(@extent))">
									<xsl:value-of
										select="concat(upper-case(substring(@extent, 1, 1)), substring(@extent, 2))"/>
									<xsl:text>: </xsl:text>
								</xsl:when>
								<xsl:otherwise>Geographical Location: </xsl:otherwise>
							</xsl:choose>
							<xsl:value-of select="normalize-space(.)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
							<xsl:if test="@type">
								<xsl:text>: </xsl:text>
							</xsl:if>
							<a
								href="{$display_path}results?q=institution_facet:&#x0022;{normalize-space(.)}&#x0022;">
								<xsl:value-of select="normalize-space(.)"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>

				</li>
			</xsl:for-each>
			<xsl:if test="string(normalize-space(refid))">
				<li>
					<xsl:apply-templates select="refid"/>
				</li>
			</xsl:if>
		</ul>
	</xsl:template>

	<xsl:template match="materialSet">
		<b>Material: </b>
		<xsl:if test="string(normalize-space(display))">
			<xsl:value-of select="normalize-space(display)"/>
		</xsl:if>
		<xsl:if test="string(normalize-space(material[1]))">
			<ul>
				<xsl:for-each select="material">
					<li>
						<xsl:if test="@type">
							<xsl:value-of
								select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
							<xsl:text>: </xsl:text>
						</xsl:if>
						<a
							href="{$display_path}results?q=material_facet:&#x0022;{normalize-space(.)}&#x0022;"
							style="text-transform:capitalize;">
							<xsl:value-of select="normalize-space(.)"/>
						</a>
					</li>
				</xsl:for-each>
			</ul>
		</xsl:if>
	</xsl:template>

	<xsl:template match="measurementsSet">
		<b>Measurements: </b>
		<xsl:if test="string(normalize-space(display))">
			<xsl:value-of select="normalize-space(display)"/>
		</xsl:if>
		<xsl:if test="string(normalize-space(measurements[1]))">
			<ul>
				<xsl:for-each select="measurements">
					<li>
						<xsl:if test="@type">
							<xsl:value-of
								select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
							<xsl:text>: </xsl:text>
						</xsl:if>
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:if test="@unit">
							<xsl:text> </xsl:text>
							<xsl:value-of select="normalize-space(@unit)"/>
						</xsl:if>
					</li>
				</xsl:for-each>
			</ul>
		</xsl:if>
	</xsl:template>

	<xsl:template match="inscriptionSet">
		<xsl:choose>
			<xsl:when
				test="(string(normalize-space(inscription[1])) and string(normalize-space(display))) or string(normalize-space(inscription[2]))">
				<b>Inscriptions: </b>
			</xsl:when>
			<xsl:otherwise>
				<b>Inscription: </b>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="string(normalize-space(display))">
			<xsl:value-of select="normalize-space(display)"/>
		</xsl:if>
		<xsl:if test="string(normalize-space(inscription[1]))">
			<ul>
				<xsl:for-each select="inscription">
					<li>
						<b>Inscription: </b>
					</li>
					<xsl:for-each select="author">
						<li>
							<xsl:text>Author: </xsl:text>
							<xsl:value-of select="normalize-space(.)"/>
						</li>
					</xsl:for-each>
					<xsl:for-each select="text">
						<li>
							<xsl:text>Text: </xsl:text>
							<xsl:value-of select="normalize-space(.)"/>
							<xsl:if test="@type">
								<i>
									<xsl:text> (</xsl:text>
									<xsl:value-of
										select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
									<xsl:text>)</xsl:text>
								</i>
							</xsl:if>
						</li>
					</xsl:for-each>
					<xsl:for-each select="position">
						<li>
							<xsl:text>Position: </xsl:text>
							<xsl:value-of select="normalize-space(.)"/>
						</li>
					</xsl:for-each>
				</xsl:for-each>
			</ul>
		</xsl:if>
	</xsl:template>

	<xsl:template match="sourceSet">
		<xsl:for-each select="source">
			<div class="bibref">
				<xsl:if test="string(normalize-space(@type))">
					<xsl:value-of select="normalize-space(@type)"/>
					<xsl:text>: </xsl:text>
				</xsl:if>
				<xsl:value-of select="normalize-space(name)"/>
				<br/>
				<xsl:if test="refid">
					<xsl:apply-templates select="refid"/>
					<br/>
				</xsl:if>
			</div>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="textrefSet">
		<xsl:for-each select="textref">
			<div class="bibref">
				<xsl:if test="string(normalize-space(@type))">
					<xsl:value-of select="normalize-space(@type)"/>
					<xsl:text>: </xsl:text>
				</xsl:if>
				<xsl:value-of select="normalize-space(name)"/>
				<br/>
				<xsl:if test="refid">
					<xsl:apply-templates select="refid"/>
					<br/>
				</xsl:if>
			</div>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="refid">
		<xsl:if test="string(normalize-space(@type))">
			<xsl:value-of select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
			<xsl:text>: </xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="@href">
				<a href="@href">
					<xsl:value-of select="normalize-space(.)"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="index_terms">
		<ul class="index_terms">
			<xsl:if test="descendant::agent/name[@type='personal']">
				<li>
					<h4>Personal Names:</h4>
				</li>
				<ul class="controlaccess_list">
					<xsl:apply-templates select="descendant::agent/name[@type='personal']"/>
				</ul>
			</xsl:if>
			<xsl:if test="descendant::agent/name[@type='family']">
				<li>
					<h4>Dynasty:</h4>
				</li>
				<ul class="controlaccess_list">
					<xsl:apply-templates select="descendant::agent/name[@type='family']"/>
				</ul>
			</xsl:if>
			<xsl:if
				test="descendant::agent/name[@type='corporate'] or descendant::location[@type='creation']/name[@type='corporate'] or descendant::location[@type='discovery']/name[@type='corporate'] or descendant::location[@type='performance']/name[@type='corporate'] or descendant::location[@type='publication']/name[@type='corporate'] or descendant::location[@type='site']/name[@type='corporate']">
				<li>
					<h4>Political Entities:</h4>
				</li>
				<ul class="controlaccess_list">
					<xsl:apply-templates select="descendant::agent/name[@type='corporate']"/>
					<xsl:apply-templates
						select="descendant::location[@type='creation']/name[@type='corporate'] | descendant::location[@type='discovery']/name[@type='corporate'] | descendant::location[@type='performance']/name[@type='corporate'] | descendant::location[@type='publication']/name[@type='corporate'] | descendant::location[@type='site']/name[@type='corporate']"
						mode="index_terms"/>
				</ul>
			</xsl:if>
			<xsl:if
				test="descendant::subject/term[@type='conceptTopic'] or descendant::subject/term[@type='descriptiveTopic'] or descendant::subject/term[@type='iconographicTopic'] or descendant::subject/term[@type='otherTopic']">
				<li>
					<h4>Subjects:</h4>
					<ul class="controlaccess_list">
						<xsl:for-each
							select="descendant::subject/term[@type='conceptTopic'] | descendant::subject/term[@type='descriptiveTopic'] | descendant::subject/term[@type='iconographicTopic'] | descendant::subject/term[@type='otherTopic']">
							<li>
								<a
									href="{$display_path}results?q=subject_facet:&#x0022;{normalize-space(.)}&#x0022;">
									<xsl:value-of select="normalize-space(.)"/>
								</a>
							</li>
						</xsl:for-each>
					</ul>
				</li>
			</xsl:if>
			<xsl:if
				test="descendant::location[@type='creation']/name[@type='geographic'] or descendant::location[@type='discovery']/name[@type='geographic'] or descendant::location[@type='performance']/name[@type='geographic'] or descendant::location[@type='publication']/name[@type='geographic'] or descendant::location[@type='site']/name[@type='geographic']">
				<li>
					<h4>Geographical Locations:</h4>
				</li>
				<ul class="controlaccess_list">
					<xsl:for-each
						select="descendant::location[@type='creation'] | descendant::location[@type='discovery'] | descendant::location[@type='performance'] | descendant::location[@type='publication'] | descendant::location[@type='site']">
						<li>
							<b><xsl:value-of
									select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"
								/>: </b>
							<ul>
								<xsl:apply-templates select="name[@type='geographic']"
									mode="index_terms"/>
							</ul>
						</li>
					</xsl:for-each>
				</ul>
			</xsl:if>
		</ul>
	</xsl:template>

	<xsl:template match="agent/name">
		<xsl:variable name="category">
			<xsl:choose>
				<xsl:when test="@type='personal'">
					<xsl:text>persname_facet</xsl:text>
				</xsl:when>
				<xsl:when test="@type='family'">
					<xsl:text>dynasty_facet</xsl:text>
				</xsl:when>
				<xsl:when test="@type='corporate'">
					<xsl:text>corpname_facet</xsl:text>
				</xsl:when>
				<xsl:when test="@type='other'">
					<xsl:text>persname_text</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<li>
			<xsl:if test="string(normalize-space(parent::node()/role[1]))">
				<xsl:for-each select="parent::node()/role">
					<xsl:value-of select="concat(upper-case(substring(., 1, 1)), substring(., 2))"/>
					<xsl:if test="not(position() = last())">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
				<xsl:text>: </xsl:text>
			</xsl:if>
			<a
				href="{$display_path}results?q={$category}:&#x0022;{normalize-space(.)}&#x0022;">
				<xsl:value-of select="normalize-space(.)"/>
			</a>
			<xsl:if test="parent::node()/dates[@type='life']">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="parent::node()/dates[@type='life']/earliestDate"/>
				<xsl:text> - </xsl:text>
				<xsl:value-of select="parent::node()/dates[@type='life']/latestDate"/>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:if test="string(normalize-space(parent::node()/culture[1]))">
				<xsl:text>; </xsl:text>
				<xsl:for-each select="parent::node()/culture">
					<xsl:value-of select="."/>
					<xsl:if test="not(position() = last())">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</li>
	</xsl:template>

	<xsl:template match="location/name" mode="index_terms">
		<xsl:choose>
			<xsl:when test="@type='geographic'">
				<xsl:variable name="category">
					<xsl:choose>
						<xsl:when test="@extent='city'">city_facet</xsl:when>
						<xsl:when test="@extent='region'">region_facet</xsl:when>
						<xsl:when test="@extent='state'">state_facet</xsl:when>
						<xsl:otherwise>geogname_text</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<li>
					<a
						href="{$display_path}results?q={$category}:&#x0022;{normalize-space(.)}&#x0022;">
						<xsl:value-of select="normalize-space(.)"/>
					</a>
				</li>
			</xsl:when>
			<xsl:when test="@type='corporate'">
				<li>
					<a
						href="{$display_path}results?q=corpname_facet:&#x0022;{normalize-space(.)}&#x0022;">
						<xsl:value-of select="normalize-space(.)"/>
					</a>
				</li>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="descriptionSet">
		<div class="essay_section">
			<a name="{generate-id(.)}"/>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="descriptionSet/display">
		<p>
			<b>
				<xsl:apply-templates/>
			</b>
		</p>
	</xsl:template>

	<xsl:template match="description">
		<p>
			<xsl:value-of select="."/>
		</p>
		<xsl:if test="string(normalize-space(@source))">
			<p>
				<i>
					<xsl:value-of select="@source"/>
				</i>
			</p>
		</xsl:if>
	</xsl:template>

	<xsl:template name="image_box">
		<div class="image_box">
			<div id="reference_container">
				<xsl:apply-templates select="//imageSet[1]/image[@source='screen']"
					mode="reference_image"/>
			</div>
			<div class="thumbnail_container">
				<xsl:apply-templates select="//imageSet/image[@source='thumb']" mode="thumbnail_image"/>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="image" mode="reference_image">
		<img src="{$display_path}{@href}" class="reference_image" alt="Image: {parent::node()/display}"/>
		<div id="reference_display" class="reference_image">
			<xsl:value-of select="parent::node()/display"/>
		</div>
	</xsl:template>

	<xsl:template match="image" mode="thumbnail_image">
		<img src="{$display_path}{@href}" alt="Thumbnail" title="{parent::node()/display}"
			id="{$display_path}{parent::node()/image[@source='screen']/@href}" class="display_thumb"
		/>
	</xsl:template>

	<!--***************************************** OPTIONS BAR  (PRINT/PDF) **************************************** -->
	<xsl:template name="print">
		<div class="submenu">
			<div class="icon">
				<a href="{$display_path}id/{$source}/{$doc_id}.pdf">
					<img src="{$display_path}images/pdficon.png"/>
				</a>
			</div>
			<div class="icon">
				<a href="{$display_path}id/{$source}/{$doc_id}.xml">
					<img src="{$display_path}images/xml.png"/>
				</a>
			</div>
			<div class="icon">
				<a href="{$display_path}id/{$source}/{$doc_id}.rdf">
					<img src="{$display_path}images/rdf.gif" title="RDF" alt="PDF"/>
				</a>
			</div>
			<div class="icon">
				<a href="{$display_path}id/{$source}/{$doc_id}.atom">
					<img src="{$display_path}images/atom.png" title="Atom" alt="Atom"/>
				</a>
			</div>			
			<div class="icon">AddThis could go here...</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
