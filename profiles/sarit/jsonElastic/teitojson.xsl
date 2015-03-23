<xsl:stylesheet
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:saxon="http://saxon.sf.net/"
    version="2.0"
    >
<!-- cf http://www.bramstein.com/projects/xsltjson/ for better
coverage -->
<xsl:strip-space elements="*"/>
<xsl:output method="text" encoding="utf-8" />
<xsl:variable name="inq">"</xsl:variable>
<xsl:variable name="outq">\\"</xsl:variable>
<xsl:variable name="esIndexName">saritindex</xsl:variable>
<xsl:variable name="esTypeName">element</xsl:variable>


<xsl:template name="getTitle">
  <xsl:param name="currentDoc"/>
  <xsl:for-each select="$currentDoc//descendant::titleStmt/descendant::title">
    <xsl:apply-templates/>
    <xsl:if test="position() != last()">
      <xsl:text> || </xsl:text>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template name="getAuthor">
  <xsl:param name="currentDoc"/>
  <xsl:for-each select="$currentDoc//descendant::titleStmt/descendant::author">
    <xsl:apply-templates/>
    <xsl:if test="position() != last()">
      <xsl:text> || </xsl:text>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template match="/">
  <xsl:for-each select="//TEI/text/body">
    <xsl:variable name="currentDoc">
      <xsl:copy-of select="ancestor::TEI"/>
    </xsl:variable>
    <xsl:variable name="systemId">
      <xsl:copy-of select="saxon:systemId()"/>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:call-template name="getTitle">
	<xsl:with-param name="currentDoc" select="$currentDoc"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="author">
      <xsl:call-template name="getAuthor">
	<xsl:with-param name="currentDoc" select="$currentDoc"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:apply-templates select=".//p[not(ancestor::note)]" mode="pars">
      <xsl:with-param name="title"><xsl:value-of select="$title"/></xsl:with-param>
      <xsl:with-param name="author"><xsl:value-of select="$author"/></xsl:with-param>
      <xsl:with-param name="systemId"><xsl:value-of select="$systemId"/></xsl:with-param>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//lg[not(ancestor::note)]" mode="linegroups">
      <xsl:with-param name="title"><xsl:value-of select="$title"/></xsl:with-param>
      <xsl:with-param name="author"><xsl:value-of select="$author"/></xsl:with-param>
      <xsl:with-param name="systemId"><xsl:value-of select="$systemId"/></xsl:with-param>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//note" mode="notes">
      <xsl:with-param name="title"><xsl:value-of select="$title"/></xsl:with-param>
      <xsl:with-param name="author"><xsl:value-of select="$author"/></xsl:with-param>
      <xsl:with-param name="systemId"><xsl:value-of select="$systemId"/></xsl:with-param>
    </xsl:apply-templates>
  </xsl:for-each>
</xsl:template>


<xsl:template name="makeJson">
  <xsl:param name="context"/>
  <xsl:param name="title" />
  <xsl:param name="author" />
  <xsl:param name="systemId" />
  <xsl:param name="lang"/>
  <xsl:text>{ "index" : { "_index": "</xsl:text>
  <xsl:value-of select="$esIndexName"/>
  <xsl:text>", "_type": "</xsl:text>
  <xsl:value-of select="$esTypeName"/>
  <xsl:text>" }}</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:text>{  "tag" : "</xsl:text>
  <xsl:value-of select="local-name()"/>
  <xsl:text>", "path" : "</xsl:text>
  <xsl:value-of select="saxon:path()"/>
  <xsl:text>", "lnum" : "</xsl:text>
  <xsl:value-of select="saxon:line-number()"/>
  <xsl:text>", "sysId" : "</xsl:text>
  <xsl:value-of select="$systemId"/>
  <xsl:text>", "lang" : "</xsl:text>
  <xsl:value-of select="$lang"/>
  <xsl:text>", "text" : "</xsl:text>
  <xsl:apply-templates />
  <xsl:text>", "title" : "</xsl:text>
  <xsl:value-of  select="$title"/>
  <xsl:text>", "author" : "</xsl:text>
  <xsl:value-of  select="$author"/>
  <xsl:text>"}</xsl:text>
  <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template match="p">
  <xsl:apply-templates />
</xsl:template>

<xsl:template match="p" mode="pars">
  <xsl:param name="title"/>
  <xsl:param name="author"/>
  <xsl:param name="systemId"/>
  <xsl:call-template name="makeJson">
    <xsl:with-param name="title" select="$title"/>
    <xsl:with-param name="author" select="$author" />
    <xsl:with-param name="systemId" select="$systemId"/>
    <xsl:with-param name="lang" select="./ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="lg">
  <xsl:apply-templates />
</xsl:template>

<xsl:template match="lg" mode="linegroups">
  <xsl:param name="title"/>
  <xsl:param name="author"/>
  <xsl:param name="systemId"/>
  <xsl:call-template name="makeJson">
    <xsl:with-param name="title" select="$title"/>
    <xsl:with-param name="author" select="$author"/>
    <xsl:with-param name="systemId" select="$systemId"/>
    <xsl:with-param name="lang" select="./ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="note" />

<xsl:template match="note" mode="notes">
  <xsl:param name="title"/>
  <xsl:param name="author"/>
  <xsl:param name="systemId"/>
  <xsl:call-template name="makeJson">
    <xsl:with-param name="title" select="$title"/>
    <xsl:with-param name="author" select="editor"/>
    <xsl:with-param name="systemId" select="$systemId"/>
    <xsl:with-param name="lang" select="./ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
  </xsl:call-template>
</xsl:template>



<xsl:template match="text()">
  <xsl:value-of select="replace(replace(replace(normalize-space(.),'\\','\\\\'), '&#10;', ' '),$inq,$outq)"/>
</xsl:template>

<xsl:template name="newline">
  <xsl:text>&#10;</xsl:text>
</xsl:template>
</xsl:stylesheet>
