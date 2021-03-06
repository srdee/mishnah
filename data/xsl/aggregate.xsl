<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:cx="http://interedition.eu/collatex/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="http://dev.digitalmishnah.org/local-functions.uri"
    exclude-result-prefixes="xs cx xd my xsl" version="2.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 21, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:param name="rqs"
        >mcite=4.2.2.11&amp;Kauf=1&amp;ParmA=2&amp;Camb=3&amp;Maim=4&amp;Paris=5&amp;Nap=6&amp;Vilna=7&amp;Mun=0&amp;Hamb=9&amp;Leid=10&amp;G2=&amp;G4=&amp;G6=&amp;G7=&amp;G1=&amp;G3=&amp;G5=&amp;G8=</xsl:param>
    <xsl:param name="mcite" select="'4.2.2.1'"/>
    <xsl:variable name="cite" select="if (string-length($mcite) = 0) then '4.2.2.1' else $mcite"/>
    <xsl:variable name="witlist">
        <xsl:variable name="params">
            <xsl:call-template name="tokenize-params">
                <xsl:with-param name="src" select="$rqs"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="$params/tei:sortWit[text()]">
            <xsl:sort select="@sortOrder"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="witIndex" xpath-default-namespace="http://www.tei-c.org/ns/1.0"><xsl:copy-of
        select="document('../tei/ref.xml')/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit//tei:witness[@corresp]"/></xsl:variable>
 
    <xsl:template match="*|@*|text()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/">
        <site>
            <tokens>
                <TEI xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:svg="http://www.w3.org/2000/svg"
                    xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns="http://www.tei-c.org/ns/1.0">
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title>Title</title>
                            </titleStmt>
                            <publicationStmt>
                                <p>Publication Information</p>
                            </publicationStmt>
                            <sourceDesc>
                                <p>Information about the source</p>
                            </sourceDesc>
                        </fileDesc>
                    </teiHeader>
                    <text>
                        <body>
                            <div>
                                <xsl:attribute name="n">
                                    <xsl:value-of select="$cite"/>
                                </xsl:attribute>
                                
                                <xsl:variable name="uriList">
                                    <xsl:call-template name="buildURI">
                                        <xsl:with-param name="wits"
                                            select="$witIndex/tei:witness[@corresp]"/>
                                        
                                    </xsl:call-template>
                                </xsl:variable>
                                
                                
                                <xsl:for-each select="$uriList/tei:uri">
                                    
                                    <ab>
                                        <xsl:namespace name="tei" select="'http://www.tei-c.org/ns/1.0'"/><xsl:attribute name="n" select="@n"/>
                                        <!-- Extract text -->
                                        <xsl:variable name="mExtract" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
                                            <extract>
                                                <xsl:namespace name="tei" select="'http://www.tei-c.org/ns/1.0'"></xsl:namespace>
                                                <xsl:copy-of select="document(.)/node()|@*" copy-namespaces="yes"/>
                                            </extract>
                                        </xsl:variable>
                                        
                                        <xsl:variable name="mPreproc-1">
                                            <!-- Preprocess pass 1. By sibling recursion (mode = "preproc-1")
                                    and processing within sibling nodes ("preproc-within"), convert
                                    to text + a few select elements. -->
                                            <xsl:apply-templates mode="preproc-1"
                                                select="$mExtract/tei:extract/node()[1]"/>
                                        </xsl:variable>
                                        
                                       
                                        <xsl:variable name="mTokenize">
                                            <xsl:apply-templates mode="tokenize"
                                                select="$mPreproc-1/node()[1]"/>
                                        </xsl:variable>
                                        <xsl:copy-of select="$mTokenize"/>
                                    </ab> 
                                </xsl:for-each>
                                
                                
                            </div>
                        </body>
                    </text>
                </TEI>
    
            </tokens>
            <collate xmlns="http://interedition.eu/collatex/ns/1.0">
                <xsl:apply-templates/>
            </collate>
        </site>
    </xsl:template>
    <xsl:template match="node()" mode="preproc-1">
        <xsl:choose>
            <xsl:when test="self::text()">
                <xsl:copy-of select="."/>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when
                test="self::tei:c[(@rend != 'nonlettermark')] | self::tei:g[not(@ref = '#fill')]">
                <xsl:value-of select="."/>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:c[@rend = 'nonlettermark'] | self::tei:g[@ref = '#fill']">
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:quote">
                <xsl:apply-templates mode="preproc-within"/>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:w">
                <xsl:choose>
                    <xsl:when test="./tei:lb/@n mod 10 = 0">
                        <w xmlns="http://www.tei-c.org/ns/1.0">
                            
                            <xsl:apply-templates select="./node()" mode="preproc-within"/>
                            <reg>
                                <xsl:value-of select="normalize-space(translate(.,'?וי','*'))"/>
                            </reg>
                        </w>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="self::tei:persName">
                <xsl:apply-templates select="./node()" mode="preproc-within"/>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:pc">
                <xsl:element name="{name()}" xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:if test="./@type">
                        <xsl:attribute name="type" select="./@type"/>
                    </xsl:if>
                </xsl:element>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:label">
                <xsl:element name="{name()}" xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:value-of select="."/>
                </xsl:element>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:lb[not(./@type)]">
                <xsl:element name="{name()}" xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:if test="./@n mod 10 = 0">
                        <xsl:attribute name="n" select="./@n"/>
                    </xsl:if>
                </xsl:element>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:seg">
                <!-- Currently selects only original text. Can be altered to include to include
                    added corrected text as well. -->
                <!-- use of <text> to insert spaces here is a hack. Must be a better way. -->
                <!-- Have now added seg for poem-like text in columns. Need to verify that this does not cause errors -->
                <xsl:text> </xsl:text><xsl:for-each select="node()">
                    <xsl:choose>
                        
                        <xsl:when test="self::tei:del"><xsl:value-of select="."></xsl:value-of></xsl:when>
                        <xsl:when test="self::tei:add"/>
                        <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each><xsl:text> </xsl:text>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:choice">
                <xsl:variable name="expan" select="normalize-space(./tei:expan)"> </xsl:variable>
                <xsl:variable name="abbr" select="normalize-space(./tei:abbr)"> </xsl:variable>
                <xsl:choose>
                    <xsl:when test="not(contains($expan,' '))">
                        <w xmlns="http://www.tei-c.org/ns/1.0">
                            <xsl:value-of select="$abbr"/>
                            <expan>
                                <xsl:value-of select="$expan"/>
                            </expan>
                            <reg>
                                <xsl:value-of select="translate($expan,'?וי','*')"/>
                            </reg>
                        </w>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="tokenize-abbr">
                            <xsl:with-param name="abbr" select="$abbr"> </xsl:with-param>
                            <xsl:with-param name="src" select="$expan"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:damage">
                <xsl:apply-templates select="./node()" mode="preproc-within"/>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <!-- Nodes to be removed altogether-->
            <!-- For now: removing fw. Need to be added back? -->
            <xsl:when
                test="self::tei:g[@ref='#fill'] | self::tei:note | self::tei:space | self::tei:surplus | self::tei:milestone | self::tei:fw | self::comment()">
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- These templates process notes within the siblings selected by sibling recursion -->
    <xsl:template match="//tei:choice" mode="preproc-within">
        <!-- For abbreviations embedded in other nodes (e.g., persName) use this template -->
        <xsl:variable name="expan">
            <xsl:value-of select="normalize-space(./tei:expan)"/>
        </xsl:variable>
        <xsl:variable name="abbr">
            <xsl:value-of select="normalize-space(./tei:abbr)"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not(contains($expan,' '))">
                <w xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:value-of select="$abbr"/>
                    <expan>
                        <xsl:value-of select="$expan"/>
                    </expan>
                    <reg>
                        <xsl:value-of select="translate($expan,'?וי','*')"/>
                    </reg>
                </w>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="tokenize-abbr">
                    <xsl:with-param name="abbr">
                        <xsl:value-of select="$abbr"/>
                    </xsl:with-param>
                    <xsl:with-param name="src">
                        <xsl:value-of select="$expan"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="//tei:ref" mode="preproc-within"/>
    <!-- This looks like a duplication -->
    <xsl:template match="tei:c[@type='nonlettermark']" mode="preproc-within"/>
    <xsl:template match="tei:g[@type='wordbreak'] | tei:c[@type='wordbreak']" mode="preproc-within"/>
    <xsl:template match="tei:g[@type!='wordbreak']" mode="preproc-within">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="tei:lb[@type = 'nobreak']" mode="spec-case">
        <xsl:text>|</xsl:text>
    </xsl:template>
    <xsl:template match="tei:lb | tei:pb | tei:cb" mode="preproc-within">
        <xsl:element name="{name()}" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
            <xsl:if test="./@n mod 10 = 0">
                <xsl:attribute name="n">
                    <xsl:value-of select="./@n"/>
                </xsl:attribute>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template
        match="//tei:supplied | //tei:damageSpan | //tei:anchor | //tei:space | //tei:note"
        mode="preproc-within"/>
    <xsl:template match="//tei:unclear | //tei:gap" mode="preproc-within">
        <xsl:text>[ ]</xsl:text>
    </xsl:template>
    <!-- Tokenize mode -->
    <xsl:template match="node()" mode="tokenize">
        <xsl:choose>
            <xsl:when test="self::text()">
                <xsl:variable name="string" select="normalize-space(replace(.,'\]\s*?\[',''))"/>
                <xsl:choose>
                    <xsl:when test="not(contains($string,' '))">
                        <w xmlns="http://www.tei-c.org/ns/1.0">
                            <xsl:value-of select="$string"/>
                            <reg>
                                <xsl:value-of select="translate($string,'?וי','*')"/>
                            </reg>
                        </w>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="tokenize-wds">
                            <xsl:with-param name="src" select="$string"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="tokenize"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="tokenize"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- recursively splits string into <token> elements -->
    <!-- Adapts a template from: http://www.usingxml.com/Transforms/XslTechniques -->
    <!-- Second and Third versions: one to deal with words in text nodes, another to process choice/abbr -->
    <xsl:template name="tokenize-wds">
        <xsl:param name="src"/>
        <xsl:choose>
            <xsl:when test="contains($src,' ')">
                <!-- build first token element -->
                <w xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:value-of select="translate(substring-before($src,' '),'?','*')"/>
                    <reg>
                        <xsl:value-of select="translate(substring-before($src,' '),'?וי','*')"/>
                    </reg>
                </w>
                <!-- recurse -->
                <xsl:call-template name="tokenize-wds">
                    <xsl:with-param name="src" select="translate(substring-after($src,' '),'?','*')"
                    />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- last token, end recursion -->
                <w xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:value-of select="translate($src,'?','*')"/>
                    <reg>
                        <xsl:value-of select="translate($src,'?וי','*')"/>
                    </reg>
                </w>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="tokenize-abbr">
        <xsl:param name="src"/>
        <xsl:param name="abbr"/>
        <xsl:choose>
            <xsl:when test="contains($src,' ')">
                <!-- build first token element -->
                <w xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:value-of select="normalize-space($abbr)"/>
                    <expan>
                        <xsl:value-of
                            select="normalize-space(translate(substring-before($src,'
                            '),'?','*'))"
                        />
                    </expan>
                    <reg>
                        <xsl:value-of
                            select="normalize-space(translate(substring-before($src,' '),'?וי','*'))"
                        />
                    </reg>
                </w>
                <!-- recurse -->
                <xsl:call-template name="tokenize-abbr">
                    <xsl:with-param name="src" select="translate(substring-after($src,' '),'?','*')"/>
                    <xsl:with-param name="abbr"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- last token, end recursion -->
                <w xmlns="http://www.tei-c.org/ns/1.0">
                    <expan>
                        <xsl:value-of select="normalize-space(translate($src,'?','*'))"/>
                    </expan>
                    <reg>
                        <xsl:value-of select="normalize-space(translate($src,'?וי','*'))"/>
                    </reg>
                </w>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- Same technique used to tokenize the passed parameter data -->
    <xsl:template name="tokenize-params">
        <xsl:param name="src"/>
        <xsl:choose>
            <xsl:when test="contains($src,'&amp;')"><!-- build first token element -->
    <xsl:if test="not(contains(substring-before($src,'&amp;'),'mcite')) and not(contains(substring-before($src,'&amp;'),'algorithm'))">
        <tei:sortWit>
            <xsl:attribute name="sortOrder">
                <xsl:choose>
                    <xsl:when
                        test="substring-after(substring-before($src,'&amp;'),'=')
                        =''">
                        <xsl:value-of select="0"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="substring-after(substring-before($src,'&amp;'),'=')"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="substring-before(substring-before($src,'&amp;'),'=')"
            />
        </tei:sortWit>
    </xsl:if>
    <!-- recurse -->
    <xsl:call-template name="tokenize-params">
        <xsl:with-param name="src" select="substring-after($src,'&amp;')"/>
    </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
        <!-- last token, end recursion -->
        <tei:sortWit>
            <xsl:attribute name="sortOrder">
                <xsl:choose>
                    <xsl:when
                        test="substring-after($src,'=')
                        =''">
                        <xsl:value-of select="0"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-after($src,'=')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="substring-before($src,'=')"/>
        </tei:sortWit>
    </xsl:otherwise>
    </xsl:choose>
    </xsl:template>
    <xsl:template name="buildURI">
        <xsl:param name="wits"/>
        <xsl:for-each select="$witlist/tei:sortWit[@sortOrder != 0]">
            <xsl:sort select="@sortOrder"/>
            <xsl:variable name="curr-wit" select="current()/text()"/>
            <tei:uri>
                <xsl:attribute name="n" select="$curr-wit"></xsl:attribute>
                <xsl:text>../tei/</xsl:text>
                <xsl:value-of select="$wits[@xml:id =
                    $curr-wit]/@corresp"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$curr-wit"/>
                <xsl:text>.</xsl:text>
                <xsl:value-of select="$cite"/>
            </tei:uri>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
