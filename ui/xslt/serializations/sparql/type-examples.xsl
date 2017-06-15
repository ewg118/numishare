<?xml version="1.0" encoding="UTF-8"?>
<!-- 	Author: Ethan Gruber
	Date: June 2017
	Function: There are two modes of templates to render SPARQL results into HTML:
	   1. type-examples renders examples of physical specimens related to coin types displayed on coin type pages
	   2. examples of coin types associated with a symbol
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
    xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">

    <!-- **************** PHYSICAL EXAMPLES OF COIN TYPES ****************-->
    <xsl:template match="res:sparql" mode="type-examples">
        <xsl:param name="subtype" select="doc('input:request')/request/parameters/parameter[name = 'subtype']/value"/>

        <xsl:variable name="count" select="count(descendant::res:result)"/>

        <div class="row">
            <xsl:if test="not($subtype = 'true')">
                <xsl:attribute name="id">examples</xsl:attribute>
            </xsl:if>
            <xsl:if test="$count &gt; 0">
                <div class="col-md-12">
                    <xsl:element name="{if($subtype='true') then 'h4' else 'h3'}">
                        <xsl:value-of select="numishare:normalizeLabel('display_examples', $lang)"/>
                    </xsl:element>
                </div>
                <xsl:apply-templates select="descendant::res:result" mode="type-examples"/>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="res:result" mode="type-examples">
        <div class="g_doc col-md-4">
            <span class="result_link">
                <a href="{res:binding[@name='object']/res:uri}" target="_blank">
                    <xsl:value-of select="res:binding[@name = 'title']/res:literal"/>
                </a>
            </span>
            <dl class=" {if($lang='ar') then 'dl-horizontal ar' else 'dl-horizontal'}">
                <xsl:choose>
                    <xsl:when test="res:binding[@name = 'collection']/res:literal">
                        <dt>
                            <xsl:value-of select="numishare:regularize_node('collection', $lang)"/>
                        </dt>
                        <dd>
                            <a href="{res:binding[@name='dataset']/res:uri}">
                                <xsl:value-of select="res:binding[@name = 'collection']/res:literal"/>
                            </a>

                        </dd>
                    </xsl:when>
                    <xsl:otherwise>
                        <dt>
                            <xsl:value-of select="numishare:regularize_node('collection', $lang)"/>
                        </dt>
                        <dd>
                            <a href="{res:binding[@name='dataset']/res:uri}">
                                <xsl:value-of select="res:binding[@name = 'datasetTitle']/res:literal"/>
                            </a>
                        </dd>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:if test="string(res:binding[@name = 'axis']/res:literal)">
                    <dt>
                        <xsl:value-of select="numishare:regularize_node('axis', $lang)"/>
                    </dt>
                    <dd>
                        <xsl:value-of select="string(res:binding[@name = 'axis']/res:literal)"/>
                    </dd>
                </xsl:if>
                <xsl:if test="string(res:binding[@name = 'diameter']/res:literal)">
                    <dt>
                        <xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>
                    </dt>
                    <dd>
                        <xsl:value-of select="string(res:binding[@name = 'diameter']/res:literal)"/>
                    </dd>
                </xsl:if>
                <xsl:if test="string(res:binding[@name = 'weight']/res:literal)">
                    <dt>
                        <xsl:value-of select="numishare:regularize_node('weight', $lang)"/>
                    </dt>
                    <dd>
                        <xsl:value-of select="string(res:binding[@name = 'weight']/res:literal)"/>
                    </dd>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="res:binding[@name = 'findUri']/res:uri">
                        <dt>
                            <xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
                        </dt>
                        <dd>
                            <a
                                href="{if (ends-with(res:binding[@name='findUri']/res:uri, '#this')) then substring-before(res:binding[@name='findUri']/res:uri, '#this') else res:binding[@name='findUri']/res:uri}">
                                <xsl:value-of select="string(res:binding[@name = 'findspot']/res:literal)"/>
                            </a>
                        </dd>

                    </xsl:when>
                    <xsl:when test="res:binding[@name = 'hoard']/res:uri">
                        <dt>
                            <xsl:value-of select="numishare:regularize_node('hoard', $lang)"/>
                        </dt>
                        <dd>
                            <a href="{res:binding[@name='hoard']/res:uri}">
                                <xsl:value-of select="string(res:binding[@name = 'findspot']/res:literal)"/>
                            </a>
                        </dd>

                    </xsl:when>
                </xsl:choose>
            </dl>

            <div class="gi_c">
                <xsl:variable name="title"
                    select="
                        concat(res:binding[@name = 'identifier']/res:literal, ': ', if
                        (string(res:binding[@name = 'collection']/res:literal)) then
                            res:binding[@name = 'collection']/res:literal
                        else
                            res:binding[@name = 'datasetTitle']/res:literal)"/>

                <xsl:if test="res:binding[contains(@name, 'Manifest')]">
                    <span class="glyphicon glyphicon-zoom-in iiif-zoom-glyph" title="Click image(s) to zoom" style="display:none"/>
                </xsl:if>

                <xsl:choose>
                    <xsl:when test="string(res:binding[@name = 'obvRef']/res:uri) and string(res:binding[@name = 'obvThumb']/res:uri)">
                        <a title="Obverse of {$title}" id="{res:binding[@name='object']/res:uri}">
                            <xsl:choose>
                                <xsl:when test="res:binding[@name = 'obvManifest']">
                                    <xsl:attribute name="href">#iiif-window</xsl:attribute>
                                    <xsl:attribute name="class">iiif-image</xsl:attribute>
                                    <xsl:attribute name="manifest" select="res:binding[@name = 'obvManifest']/res:uri"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="res:binding[@name = 'obvRef']/res:uri"/>
                                    <xsl:attribute name="class">thumbImage</xsl:attribute>
                                    <xsl:attribute name="rel">gallery</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>

                            <img class="gi side-thumbnail" src="{res:binding[@name='obvThumb']/res:uri}"/>                            
                        </a>                        
                    </xsl:when>
                    <xsl:when test="not(string(res:binding[@name = 'obvRef']/res:uri)) and string(res:binding[@name = 'obvThumb']/res:uri)">
                        <img class="gi side-thumbnail" src="{res:binding[@name='obvThumb']/res:uri}"/>
                    </xsl:when>
                    <xsl:when test="string(res:binding[@name = 'obvRef']/res:uri) and not(string(res:binding[@name = 'obvThumb']/res:uri))">
                        <a title="Obverse of {$title}" id="{res:binding[@name='object']/res:uri}">
                            <xsl:choose>
                                <xsl:when test="res:binding[@name = 'obvManifest']">
                                    <xsl:attribute name="href">#iiif-window</xsl:attribute>
                                    <xsl:attribute name="class">iiif-image</xsl:attribute>
                                    <xsl:attribute name="manifest" select="res:binding[@name = 'obvManifest']/res:uri"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="res:binding[@name = 'obvRef']/res:uri"/>
                                    <xsl:attribute name="class">thumbImage</xsl:attribute>
                                    <xsl:attribute name="rel">gallery</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <img class="gi side-thumbnail" src="{res:binding[@name='obvRef']/res:uri}"/>
                        </a>
                    </xsl:when>
                </xsl:choose>
                <!-- reverse-->
                <xsl:choose>
                    <xsl:when test="string(res:binding[@name = 'revRef']/res:uri) and string(res:binding[@name = 'revThumb']/res:uri)">
                        <a title="Reverse of {$title}" id="{res:binding[@name='object']/res:uri}">
                            <xsl:choose>
                                <xsl:when test="res:binding[@name = 'revManifest']">
                                    <xsl:attribute name="href">#iiif-window</xsl:attribute>
                                    <xsl:attribute name="class">iiif-image</xsl:attribute>
                                    <xsl:attribute name="manifest" select="res:binding[@name = 'revManifest']/res:uri"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="res:binding[@name = 'revRef']/res:uri"/>
                                    <xsl:attribute name="class">thumbImage</xsl:attribute>
                                    <xsl:attribute name="rel">gallery</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <img class="gi side-thumbnail" src="{res:binding[@name='revThumb']/res:uri}"/>
                        </a>
                    </xsl:when>
                    <xsl:when test="not(string(res:binding[@name = 'revRef']/res:uri)) and string(res:binding[@name = 'revThumb']/res:uri)">
                        <img class="gi side-thumbnail" src="{res:binding[@name='revThumb']/res:uri}"/>
                    </xsl:when>
                    <xsl:when test="string(res:binding[@name = 'revRef']/res:uri) and not(string(res:binding[@name = 'revThumb']/res:uri))">
                        <a title="Reverse of {$title}" id="{res:binding[@name='object']/res:uri}">
                            <xsl:choose>
                                <xsl:when test="res:binding[@name = 'revManifest']">
                                    <xsl:attribute name="href">#iiif-window</xsl:attribute>
                                    <xsl:attribute name="class">iiif-image</xsl:attribute>
                                    <xsl:attribute name="manifest" select="res:binding[@name = 'revManifest']/res:uri"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="res:binding[@name = 'revRef']/res:uri"/>
                                    <xsl:attribute name="class">thumbImage</xsl:attribute>
                                    <xsl:attribute name="rel">gallery</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <img class="gi side-thumbnail" src="{res:binding[@name='revRef']/res:uri}"/>
                        </a>
                    </xsl:when>
                </xsl:choose>
                <!-- combined -->
                <xsl:choose>
                    <xsl:when test="string(res:binding[@name = 'comRef']/res:uri) and string(res:binding[@name = 'comThumb']/res:uri)">
                        <a title="Image of {$title}" id="{res:binding[@name='object']/res:uri}">
                            <xsl:choose>
                                <xsl:when test="res:binding[@name = 'comManifest']">
                                    <xsl:attribute name="href">#iiif-window</xsl:attribute>
                                    <xsl:attribute name="class">iiif-image</xsl:attribute>
                                    <xsl:attribute name="manifest" select="res:binding[@name = 'comManifest']/res:uri"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="res:binding[@name = 'comRef']/res:uri"/>
                                    <xsl:attribute name="class">thumbImage</xsl:attribute>
                                    <xsl:attribute name="rel">gallery</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <img src="{res:binding[@name='comThumb']/res:uri}" class="gi combined-thumbnail"/>
                        </a>
                    </xsl:when>
                    <xsl:when test="string(res:binding[@name = 'comRef']/res:uri) and not(string(res:binding[@name = 'comThumb']/res:uri))">
                        <a title="Image of {$title}" id="{res:binding[@name='object']/res:uri}">
                            <xsl:choose>
                                <xsl:when test="res:binding[@name = 'comManifest']">
                                    <xsl:attribute name="href">#iiif-window</xsl:attribute>
                                    <xsl:attribute name="class">iiif-image</xsl:attribute>
                                    <xsl:attribute name="manifest" select="res:binding[@name = 'comManifest']/res:uri"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="res:binding[@name = 'comRef']/res:uri"/>
                                    <xsl:attribute name="class">thumbImage</xsl:attribute>
                                    <xsl:attribute name="rel">gallery</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <img src="{res:binding[@name='comRef']/res:uri}" class="gi combined-thumbnail"/>
                        </a>
                    </xsl:when>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>

    <!-- **************** EXAMPLES OF COIN TYPES ASSOCIATED TO A SYMBOL ****************-->
    <xsl:template match="res:sparql" mode="listTypes">
        <xsl:param name="objectUri"/>
        <xsl:param name="endpoint"/>

        <!-- aggregate ids and get URI space -->
        <xsl:variable name="type_series_items" as="element()*">
            <type_series_items>
                <xsl:for-each select="descendant::res:result/res:binding[@name = 'type']/res:uri">
                    <item>
                        <xsl:value-of select="."/>
                    </item>
                </xsl:for-each>
            </type_series_items>
        </xsl:variable>

        <xsl:variable name="type_series" as="element()*">
            <list>
                <xsl:for-each select="distinct-values(descendant::res:result/res:binding[@name = 'type']/substring-before(res:uri, 'id/'))">
                    <xsl:variable name="uri" select="."/>
                    <type_series uri="{$uri}">
                        <xsl:for-each select="$type_series_items//item[starts-with(., $uri)]">
                            <item>
                                <xsl:value-of select="substring-after(., 'id/')"/>
                            </item>
                        </xsl:for-each>
                    </type_series>
                </xsl:for-each>
            </list>
        </xsl:variable>

        <!-- use the Numishare Results API to display example coins -->
        <xsl:variable name="sparqlResult" as="element()*">
            <response>
                <xsl:for-each select="$type_series//type_series">
                    <xsl:variable name="baseUri" select="concat(@uri, 'id/')"/>
                    <xsl:variable name="ids" select="string-join(item, '|')"/>

                    <xsl:variable name="service"
                        select="concat('http://nomisma.org/apis/numishareResults?identifiers=', encode-for-uri($ids), '&amp;baseUri=',
                        encode-for-uri($baseUri))"/>
                    <xsl:copy-of select="document($service)/response/*"/>
                </xsl:for-each>
            </response>
        </xsl:variable>

        <!-- HTML output -->
        <h3>Associated Types</h3>

        <xsl:variable name="query" select="replace(doc('input:query'), '%URI%', $objectUri)"/>

        <div id="listTypes-container">
            <div style="margin-bottom:10px;" class="control-row">
                <a href="#" class="toggle-button btn btn-primary" id="toggle-listTypesQuery"><span class="glyphicon glyphicon-plus"/> View SPARQL for full
                    query</a>
                <a href="{$endpoint}?query={encode-for-uri($query)}&amp;output=csv" title="Download CSV" class="btn btn-primary" style="margin-left:10px">
                    <span class="glyphicon glyphicon-download"/>Download CSV</a>
            </div>
            <div id="listTypesQuery-container" style="display:none">
                <pre>
				<xsl:value-of select="$query"/>
			</pre>
            </div>

            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Type</th>
                        <th style="width:280px">Example</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="descendant::res:result">
                        <xsl:variable name="type_id" select="substring-after(res:binding[@name = 'type']/res:uri, 'id/')"/>

                        <tr>
                            <td>
                                <a href="{res:binding[@name='type']/res:uri}">
                                    <xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
                                </a>
                                <dl class="dl-horizontal">
                                    <xsl:if test="res:binding[@name = 'mint']/res:uri">
                                        <dt>Mint</dt>
                                        <dd>
                                            <a href="{res:binding[@name='mint']/res:uri}">
                                                <xsl:value-of select="res:binding[@name = 'mintLabel']/res:literal"/>
                                            </a>
                                        </dd>
                                    </xsl:if>
                                    <xsl:if test="res:binding[@name = 'den']/res:uri">
                                        <dt>Denomination</dt>
                                        <dd>
                                            <a href="{res:binding[@name='den']/res:uri}">
                                                <xsl:value-of select="res:binding[@name = 'denLabel']/res:literal"/>
                                            </a>
                                        </dd>
                                    </xsl:if>
                                    <xsl:if test="res:binding[@name = 'startDate']/res:literal or res:binding[@name = 'endDate']/res:literal">
                                        <dt>Date</dt>
                                        <dd>
                                            <xsl:value-of select="numishare:normalizeDate(res:binding[@name = 'startDate']/res:literal)"/>
                                            <xsl:if test="res:binding[@name = 'startDate']/res:literal and res:binding[@name = 'startDate']/res:literal"> - </xsl:if>
                                            <xsl:value-of select="numishare:normalizeDate(res:binding[@name = 'endDate']/res:literal)"/>
                                        </dd>
                                    </xsl:if>
                                </dl>
                            </td>
                            <td class="text-right">
                                <xsl:apply-templates select="$sparqlResult//group[@id = $type_id]/descendant::object" mode="results"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:template>

</xsl:stylesheet>
