<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
    xmlns:numishare="https://github.com/ewg118/numishare"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- **************** DISPLAY TEMPLATES ****************-->
    <xsl:template match="res:sparql" mode="type-examples">
        <xsl:param name="subtype" select="doc('input:request')/request/parameters/parameter[name='subtype']/value"/>
        
        <xsl:variable name="count" select="count(descendant::res:result)"/>
        
        <div class="row">
            <xsl:if test="not($subtype='true')">
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
                    <xsl:value-of select="res:binding[@name='title']/res:literal"/>
                </a>
            </span>
            <dl class=" {if($lang='ar') then 'dl-horizontal ar' else 'dl-horizontal'}">
                <xsl:choose>
                    <xsl:when test="res:binding[@name='collection']/res:literal">
                        <dt>
                            <xsl:value-of select="numishare:regularize_node('collection', $lang)"/>
                        </dt>
                        <dd>
                            <a href="{res:binding[@name='dataset']/res:uri}">
                                <xsl:value-of select="res:binding[@name='collection']/res:literal"/>
                            </a>
                            
                        </dd>
                    </xsl:when>
                    <xsl:otherwise>
                        <dt>
                            <xsl:value-of select="numishare:regularize_node('collection', $lang)"/>
                        </dt>
                        <dd>
                            <a href="{res:binding[@name='dataset']/res:uri}">
                                <xsl:value-of select="res:binding[@name='datasetTitle']/res:literal"/>
                            </a>
                        </dd>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:if test="string(res:binding[@name='axis']/res:literal)">
                    <dt>
                        <xsl:value-of select="numishare:regularize_node('axis', $lang)"/>
                    </dt>
                    <dd>
                        <xsl:value-of select="string(res:binding[@name='axis']/res:literal)"/>
                    </dd>
                </xsl:if>
                <xsl:if test="string(res:binding[@name='diameter']/res:literal)">
                    <dt>
                        <xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>
                    </dt>
                    <dd>
                        <xsl:value-of select="string(res:binding[@name='diameter']/res:literal)"/>
                    </dd>
                </xsl:if>
                <xsl:if test="string(res:binding[@name='weight']/res:literal)">
                    <dt>
                        <xsl:value-of select="numishare:regularize_node('weight', $lang)"/>
                    </dt>
                    <dd>
                        <xsl:value-of select="string(res:binding[@name='weight']/res:literal)"/>
                    </dd>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="res:binding[@name='findUri']/res:uri">
                        <dt>
                            <xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
                        </dt>
                        <dd>
                            <a href="{if (ends-with(res:binding[@name='findUri']/res:uri, '#this')) then substring-before(res:binding[@name='findUri']/res:uri, '#this') else res:binding[@name='findUri']/res:uri}">
                                <xsl:value-of select="string(res:binding[@name='findspot']/res:literal)"/>
                            </a>
                        </dd>
                        
                    </xsl:when>
                    <xsl:when test="res:binding[@name='hoard']/res:uri">
                        <dt>
                            <xsl:value-of select="numishare:regularize_node('hoard', $lang)"/>
                        </dt>
                        <dd>
                            <a href="{res:binding[@name='hoard']/res:uri}">
                                <xsl:value-of select="string(res:binding[@name='findspot']/res:literal)"/>
                            </a>
                        </dd>
                        
                    </xsl:when>
                </xsl:choose>
            </dl>
            
            <div class="gi_c">
                <xsl:choose>
                    <xsl:when test="string(res:binding[@name='obvRef']/res:uri) and string(res:binding[@name='obvThumb']/res:uri)">
                        <a class="thumbImage" rel="gallery" href="{res:binding[@name='obvRef']/res:uri}" title="Obverse of {res:binding[@name='identifier']/res:literal}:        {if
                            (string(res:binding[@name='collection']/res:literal)) then res:binding[@name='collection']/res:literal else res:binding[@name='datasetTitle']/res:literal}"
                            id="{res:binding[@name='object']/res:uri}">
                            <img class="gi" src="{res:binding[@name='obvThumb']/res:uri}"/>
                        </a>
                    </xsl:when>
                    <xsl:when test="not(string(res:binding[@name='obvRef']/res:uri)) and string(res:binding[@name='obvThumb']/res:uri)">
                        <img class="gi" src="{res:binding[@name='obvThumb']/res:uri}"/>
                    </xsl:when>
                    <xsl:when test="string(res:binding[@name='obvRef']/res:uri) and not(string(res:binding[@name='obvThumb']/res:uri))">
                        <a class="thumbImage" rel="gallery" href="{res:binding[@name='obvRef']/res:uri}" title="Obverse of {res:binding[@name='identifier']/res:literal}:        {if
                            (string(res:binding[@name='collection']/res:literal)) then res:binding[@name='collection']/res:literal else res:binding[@name='datasetTitle']/res:literal}"
                            id="{res:binding[@name='object']/res:uri}">
                            <img class="gi" src="{res:binding[@name='obvRef']/res:uri}" style="max-width:120px"/>
                        </a>
                    </xsl:when>
                </xsl:choose>
                <!-- reverse-->
                <xsl:choose>
                    <xsl:when test="string(res:binding[@name='revRef']/res:uri) and string(res:binding[@name='revThumb']/res:uri)">
                        <a class="thumbImage" rel="gallery" href="{res:binding[@name='revRef']/res:uri}" title="Reverse of {res:binding[@name='identifier']/res:literal}:        {if
                            (string(res:binding[@name='collection']/res:literal)) then res:binding[@name='collection']/res:literal else res:binding[@name='datasetTitle']/res:literal}"
                            id="{res:binding[@name='object']/res:uri}">
                            <img class="gi" src="{res:binding[@name='revThumb']/res:uri}"/>
                        </a>
                    </xsl:when>
                    <xsl:when test="not(string(res:binding[@name='revRef']/res:uri)) and string(res:binding[@name='revThumb']/res:uri)">
                        <img class="gi" src="{res:binding[@name='revThumb']/res:uri}"/>
                    </xsl:when>
                    <xsl:when test="string(res:binding[@name='revRef']/res:uri) and not(string(res:binding[@name='revThumb']/res:uri))">
                        <a class="thumbImage" rel="gallery" href="{res:binding[@name='revRef']/res:uri}" title="Reverse of {res:binding[@name='identifier']/res:literal}:        {if
                            (string(res:binding[@name='collection']/res:literal)) then res:binding[@name='collection']/res:literal else res:binding[@name='datasetTitle']/res:literal}"
                            id="{res:binding[@name='object']/res:uri}">
                            <img class="gi" src="{res:binding[@name='revRef']/res:uri}" style="max-width:120px"/>
                        </a>
                    </xsl:when>
                </xsl:choose>
                <!-- combined -->
                <xsl:choose>
                    <xsl:when test="string(res:binding[@name='comRef']/res:uri) and string(res:binding[@name='comThumb']/res:uri)">
                        <a class="thumbImage" rel="gallery" href="{res:binding[@name='comRef']/res:uri}" title="Image of {res:binding[@name='identifier']/res:literal}:        {if
                            (string(res:binding[@name='collection']/res:literal)) then res:binding[@name='collection']/res:literal else res:binding[@name='datasetTitle']/res:literal}"
                            id="{res:binding[@name='object']/res:uri}">
                            <img class="gi" src="{res:binding[@name='comThumb']/res:uri}" style="max-width:240px"/>
                        </a>
                    </xsl:when>
                    <xsl:when test="string(res:binding[@name='comRef']/res:uri) and not(string(res:binding[@name='comThumb']/res:uri))">
                        <a class="thumbImage" rel="gallery" href="{res:binding[@name='comRef']/res:uri}" title="Image of {res:binding[@name='identifier']/res:literal}:        {if
                            (string(res:binding[@name='collection']/res:literal)) then res:binding[@name='collection']/res:literal else res:binding[@name='datasetTitle']/res:literal}"
                            id="{res:binding[@name='object']/res:uri}">
                            <img class="gi" src="{res:binding[@name='comRef']/res:uri}" style="max-width:240px"/>
                        </a>
                    </xsl:when>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>
    
</xsl:stylesheet>