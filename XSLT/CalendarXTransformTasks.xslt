<?xml version="1.0" encoding="iso-8859-1"?>


<xsl:stylesheet version="2.0" exclude-result-prefixes="xs functx" 
xmlns:foo="http://www.foo.org"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xlink="http://www.w3.org/1999/xlink" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns:functx="http://www.functx.com" 
xmlns:fn="http://www.w3.org/2005/xpath-functions">


	<xsl:include href="functx-1.0-doc-2007-01.xsl"/>
	<xsl:include href="myFunctions.xsl"/>


  <xsl:output
    method="xml"
    indent="yes"
    standalone="no"
    doctype-public="-//W3C//DTD SVG 1.1//EN"
    doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"
    media-type="image/svg" />






  <xsl:template match="/">

    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      <defs>

        <rect id="APP" width="500" height="100"
            style="stroke: black; fill: lightgrey">
        </rect>

        <xsl:apply-templates select="events/event"/>


      </defs>
<!--      <g alignment-baseline="baseline">
        <use xlink:href="#T2015-05-07_101500_120000" transform="translate(0,100)"/>
        <use xlink:href="#T2015-05-04_121500_134500" transform="translate(0,200)"/>
      </g>
-->
    </svg>
  </xsl:template>




  <xsl:template match="event" >


    <g id="T{@id}" xmlns="http://www.w3.org/2000/svg">
      <use xlink:href="#APP" />

      <xsl:call-template name="foo:printEventDescription">
      <xsl:with-param name="event"><xsl:value-of select="."/></xsl:with-param>
      </xsl:call-template>
    </g>

   <xsl:if test="@intersecting>0">
   	<g id="T{@id}_cropped" xmlns="http://www.w3.org/2000/svg">
   	<g transform="scale({1 div (@intersecting+1)},1)" xmlns="http://www.w3.org/2000/svg">
      <use xlink:href="#APP" />

	</g>
      <xsl:call-template name="foo:printEventDescription">
      <xsl:with-param name="event"><xsl:value-of select="."/></xsl:with-param>
      </xsl:call-template>
    </g>
   </xsl:if>




  </xsl:template>


</xsl:stylesheet>

