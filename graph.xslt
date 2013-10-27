<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:dyn="http://exslt.org/dynamic"
  xmlns:mb="http://itude.com/schemas/MB/2.0"
  extension-element-prefixes="dyn">

  <xsl:output method="text" />
  <xsl:strip-space elements="xsd:schema" />

  <xsl:template match="/xsd:schema">
    <xsl:call-template name="start-digraph" />
    <xsl:apply-templates />
    <xsl:call-template name="end-digraph" />
  </xsl:template>

  <xsl:template match="xsd:complexType">
    <xsl:variable name="parent" select="@name" />

    <!-- Draw a node for each element -->
    <xsl:call-template name="treeNode">
      <xsl:with-param name="name" select="@name" />
      <xsl:with-param name="shape" select="'ellipse'" />
      <xsl:with-param name="peri" select="2" />
    </xsl:call-template>

    <xsl:apply-templates select="xsd:all/xsd:element">
      <xsl:with-param name="parent" select="@name" />
    </xsl:apply-templates>
  </xsl:template>

  <!-- Parameterized template for processing element tags -->
  <xsl:template match="xsd:element">
    <xsl:param name="parent" />

    <!-- Set default values for minOccurs/maxOccurs attributes if necessary -->
    <xsl:variable name="minOccurs">
      <xsl:choose>
        <xsl:when test="@minOccurs">
          <xsl:value-of select="@minOccurs" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'1'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="maxOccurs">
      <xsl:choose>
        <xsl:when test="@maxOccurs">
          <xsl:value-of select="@maxOccurs" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'1'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Determine relation multiplicity based on minOccurs and maxOccurs
         attributes -->
    <xsl:variable name="multiplicity">
      <xsl:choose>
        <xsl:when test="$minOccurs = 0 and $maxOccurs = 'unbounded'">
          <xsl:text>*</xsl:text>
        </xsl:when>
        <xsl:when test="$minOccurs = 1 and $maxOccurs = 'unbounded'">
          <xsl:text>+</xsl:text>
        </xsl:when>
        <xsl:when test="$minOccurs = 0 and $maxOccurs = 1">
          <xsl:text>?</xsl:text>
        </xsl:when>
        <xsl:when test="$minOccurs = 1 and $maxOccurs = 1">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$minOccurs" />
          <xsl:text>,</xsl:text>
          <xsl:value-of select="$maxOccurs" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Draw an edge -->
    <xsl:call-template name="edge">
      <xsl:with-param name="origin" select="$parent" />
      <xsl:with-param name="destination" select="@name" />
      <xsl:with-param name="label" select="$multiplicity" />
    </xsl:call-template>

    <!-- Handle type alternatives -->
    <xsl:apply-templates select="xsd:alternative">
      <xsl:with-param name="parent" select="@name" />
    </xsl:apply-templates>
  </xsl:template>


  <!-- (Parameterized) template for connecting type alternatives -->
  <xsl:template match="xsd:alternative">
    <xsl:param name="parent" />

    <xsl:call-template name="edge">
      <xsl:with-param name="origin" select="$parent" />
      <xsl:with-param name="destination" select="substring(@type, 4)" />
      <xsl:with-param name="label" select="@test" />
      <xsl:with-param name="style" select="'dotted'" />
    </xsl:call-template>
  </xsl:template>

  <!-- Parameterized template for drawing edges -->
  <xsl:template name="edge">
    <xsl:param name="origin" />
    <xsl:param name="destination" />
    <xsl:param name="label" />
    <xsl:param name="style" />

    <xsl:call-template name="newline" />
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$origin" />
    <xsl:text><![CDATA[" -> "]]></xsl:text>
    <xsl:value-of select="$destination" />
    <xsl:text>" [label = "</xsl:text>
    <xsl:value-of select="$label" />
    <xsl:text>",style = "</xsl:text>
    <xsl:value-of select="$style" />
    <xsl:text>"];</xsl:text>
  </xsl:template>


  <!-- Parameterized template for drawing nodes -->
  <xsl:template name="treeNode">
    <xsl:param name="name" />
    <xsl:param name="shape" />
    <xsl:param name="peri" />

    <xsl:call-template name="newline" />
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$name" />
    <xsl:text>" [shape = "</xsl:text>
    <xsl:value-of select="$shape" />
    <xsl:text>",peripheries = "</xsl:text>
    <xsl:value-of select="$peri" />
    <xsl:text>"];</xsl:text>
  </xsl:template>


  <!-- Template for starting the digraph and ending it -->
  <xsl:template name="start-digraph">
    <xsl:text>digraph "mobbl-schema" {
  size=30</xsl:text>
  </xsl:template>

  <xsl:template name="end-digraph">
    <xsl:call-template name="newline">
      <xsl:with-param name="suppressIndent" select="'true'" />
    </xsl:call-template>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <!-- insert a newline with or without indent -->
  <xsl:template name="newline">
    <xsl:param name="suppressIndent" />

    <xsl:choose>
      <xsl:when test="$suppressIndent">
        <xsl:text>
</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>
  </xsl:text>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>


</xsl:transform>
