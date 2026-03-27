<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:numishare="https://github.com/ewg118/numishare"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">


    <!-- ************** SOLR-BASED VISUALIZATION FORM ************** -->
    <xsl:template name="solr-distribution-form">
        <xsl:param name="page"/>

        <form role="form" id="distributionForm" class="quant-form" method="get">

            <xsl:attribute name="action">
                <xsl:choose>
                    <xsl:when test="$page = 'provenance'"/>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($display_path, 'visualize')"/>
                    </xsl:otherwise>
                </xsl:choose>                
            </xsl:attribute>

            <div class="form-group">
                <h4>
                    <xsl:value-of
                        select="numishare:normalizeLabel('visualize_response_type', $lang)"/>
                </h4>
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

            <!-- select distribution category by checklist -->
            <div class="form-group">
                <h4>Category</h4>

                <select name="category" class="form-control" id="categorySelect">
                    <option value="">Select...</option>
                    <xsl:for-each
                        select="//lst[@name = 'facet_fields']/lst[not(ends-with(@name, '_geo')) and not(ends-with(@name, '_hier'))][int]">
                        <option value="{@name}">
                            <xsl:if test="@name = $dist">
                                <xsl:attribute name="selected">selected</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="numishare:normalize_fields(@name, $lang)"/>
                        </option>
                    </xsl:for-each>
                </select>
            </div>

            <!-- do not display compare controls on provenance related pages -->
            <xsl:if test="not($page = 'provenance')">
                <div class="form-group">
                    <h4>
                        <xsl:choose>
                            <xsl:when test="string($q)">
                                <xsl:value-of
                                    select="numishare:normalizeLabel('visualize_compare_optional', $lang)"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="numishare:normalizeLabel('visualize_compare', $lang)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <small style="margin-left:10px;">
                            <a href="#searchBox" class="addQuery" id="compareQuery">
                                <span class="glyphicon glyphicon-plus"/>
                                <xsl:value-of
                                    select="numishare:normalizeLabel('visualize_add_query', $lang)"
                                />
                            </a>
                        </small>
                    </h4>
                    <div id="compareQueryDiv">
                        <div id="empty-query-alert">
                            <xsl:attribute name="class">
                                <xsl:choose>
                                    <xsl:when test="string($compare)">alert alert-box alert-danger
                                        hidden</xsl:when>
                                    <xsl:otherwise>alert alert-box alert-danger</xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <span class="glyphicon glyphicon-exclamation-sign"/>
                            <strong><xsl:value-of
                                    select="numishare:normalizeLabel('visualize_alert', $lang)"
                                />:</strong> There must be at least one query to visualize.</div>

                        <xsl:for-each select="tokenize($compare, '\|')">
                            <div class="compareQuery">
                                <b><xsl:value-of
                                        select="numishare:normalizeLabel('visualize_comparison_query', $lang)"
                                    />: </b>
                                <span class="query">
                                    <xsl:value-of select="."/>
                                </span>
                                <a href="#" class="removeQuery">
                                    <span class="glyphicon glyphicon-remove"/>
                                    <xsl:value-of
                                        select="numishare:normalizeLabel('visualize_remove_query', $lang)"
                                    />
                                </a>
                            </div>
                        </xsl:for-each>
                    </div>
                </div>
            </xsl:if>


            <xsl:if test="string($langParam)">
                <input type="hidden" name="lang" value="{$lang}"/>
            </xsl:if>
            <input type="hidden" name="compare" value="{$compare}"/>
            <br/>

            <input type="submit" value="{numishare:normalizeLabel('visualize_generate', $lang)}"
                class="btn btn-default visualize-submit" disabled="disabled"/>
        </form>
    </xsl:template>

    <!-- templates -->
    <xsl:template name="solr-chart">
        <xsl:param name="hidden"/>
        <xsl:param name="interface"/>
        <xsl:param name="page"/>

        <xsl:variable name="api">getSolrDistribution</xsl:variable>

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
                <p>The chart is limited to 100 results. For the full distribution, please download
                    the CSV.</p>

                <xsl:choose>
                    <xsl:when test="$hidden = false()">
                        <xsl:variable name="queryParams" as="element()*">
                            <params>
                                <xsl:if test="string($dist)">
                                    <param>
                                        <xsl:value-of select="concat('category=', $dist)"/>
                                    </param>
                                </xsl:if>
                                <xsl:if test="string($numericType)">
                                    <param>
                                        <xsl:value-of select="concat('type=', $numericType)"/>
                                    </param>
                                </xsl:if>
                                <xsl:if test="string($compare)">
                                    <param>
                                        <xsl:value-of select="concat('compare=', $compare)"/>
                                    </param>
                                </xsl:if>
                                <xsl:if test="string($langParam)">
                                    <param>
                                        <xsl:value-of select="concat('lang=', $langParam)"/>
                                    </param>
                                </xsl:if>
                                <param>format=csv</param>
                            </params>
                        </xsl:variable>

                        <a href="{$display_path}apis/{$api}?{string-join($queryParams/*, '&amp;')}"
                            title="Download CSV" class="btn btn-primary">
                            <span class="glyphicon glyphicon-download"/>Download CSV</a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="not($page = 'provenance')">
                            <a href="#" title="Download" class="btn btn-primary">
                                <span class="glyphicon glyphicon-download"/>Download CSV</a>
                            <a href="#" title="Bookmark" class="btn btn-primary">
                                <span class="glyphicon glyphicon-download"/>View in Separate Page</a>
                        </xsl:if>
                       
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>

    </xsl:template>
</xsl:stylesheet>
