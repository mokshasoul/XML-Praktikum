<xsl:stylesheet xmlns:foo="http://www.foo.org" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0" exclude-result-prefixes="xs functx"><xsl:include href="functx-1.0-doc-2007-01.xsl"/><xsl:include href="myFunctions.xsl"/><xsl:output method="xml" indent="yes" standalone="no" doctype-public="-//W3C//DTD SVG 1.1//EN" doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" media-type="image/svg"/><xsl:param name="requestedDate"/><xsl:param name="packedView"/><xsl:param name="mode"/><xsl:variable name="weeksInThisMonth"><xsl:variable name="firstMonday"><xsl:value-of select="xs:date(foo:getCertainDayOfWeek(functx:first-day-of-month($requestedDate),0))"/></xsl:variable><week1><xsl:value-of select="$firstMonday"/></week1><week2><xsl:value-of select="xs:date($firstMonday) + xs:dayTimeDuration('P7D')"/></week2><week3><xsl:value-of select="xs:date($firstMonday) + xs:dayTimeDuration('P14D')"/></week3><week4><xsl:value-of select="xs:date($firstMonday) + xs:dayTimeDuration('P21D')"/></week4><week5><xsl:value-of select="xs:date($firstMonday) + xs:dayTimeDuration('P28D')"/></week5><week6><xsl:value-of select="xs:date($firstMonday) + xs:dayTimeDuration('P35D')"/></week6><test><xsl:value-of select="functx:first-day-of-month(xs:date($firstMonday) + xs:dayTimeDuration('P35D'))"/></test>
		<!--
		maxWeek stores how many weeks actually belong to the month. We don't always want to display 6 weeks, this is just the maximum. Minimum weeks to be displayed is 4, so we 
		have to store whether we have 4, 5 or 6 weeks for this month
		 --><maxWeek><xsl:choose><xsl:when test="(functx:first-day-of-month(xs:date($firstMonday) + xs:dayTimeDuration('P35D')))=functx:first-day-of-month($requestedDate)">
						6
					</xsl:when><xsl:when test="(functx:first-day-of-month(xs:date($firstMonday) + xs:dayTimeDuration('P28D')))=functx:first-day-of-month($requestedDate)">
						5
					</xsl:when><xsl:otherwise>
						4
					</xsl:otherwise></xsl:choose></maxWeek></xsl:variable><xsl:variable name="displacement"><xsl:choose><xsl:when test="$packedView eq 'true'"><xsl:value-of select="150+100*events/@maxNumOfEventsOnDay"/></xsl:when><xsl:otherwise><xsl:value-of select="1544"/></xsl:otherwise> <!--1440 (timeline) +100 (header) +4 (horizontal line)--></xsl:choose></xsl:variable><xsl:variable name="scaleMonth" select="0.35"/><xsl:variable name="scaleWeek" select="0.35"/><xsl:variable name="scaleDay" select="0.4"/><xsl:template match="/"><svg xmlns="http://www.w3.org/2000/svg" height="{if ($mode eq 'Day')  then $scaleDay*1564 else if ($mode eq 'Week') then $scaleWeek*1564 else 85*$scaleMonth+$displacement*$scaleMonth*$weeksInThisMonth/maxWeek}" width="100%"><defs><rect id="APP" width="500" height="100" style="stroke: black; fill: lightgrey"/><g class="times" id="TIMES"><g transform="translate(0,140)"><text x="0" y="30" font-size="48">
										00:00
							<tspan x="0" y="130">02:00</tspan><tspan x="0" y="250">04:00</tspan><tspan x="0" y="370">06:00</tspan><tspan x="0" y="490">08:00</tspan><tspan x="0" y="610">10:00</tspan><tspan x="0" y="730">12:00</tspan><tspan x="0" y="850">14:00</tspan><tspan x="0" y="970">16:00</tspan><tspan x="0" y="1090">18:00</tspan><tspan x="0" y="1210">20:00</tspan><tspan x="0" y="1330">22:00</tspan></text></g></g>
				
				<!--GENERATE TASKS--><xsl:for-each select="events/event"><xsl:call-template name="foo:generateBasicTask"/></xsl:for-each>
				
				
				
				
				
				<!--GENERATE DAYS --><xsl:for-each-group select="events/event" group-by="@date"><g id="T{@date}"><xsl:call-template name="foo:printDayAndDate"><xsl:with-param name="date" select="@date"/><xsl:with-param name="displayDayName" select="if(not($mode eq 'Month') or xs:date(@date) - xs:date(foo:getCertainDayOfWeek(functx:first-day-of-month($requestedDate),0)) &lt; xs:dayTimeDuration('P7D')) then xs:boolean('true') else xs:boolean('false')"/></xsl:call-template><g transform="translate(10,130)">
						
						
						<!--			
							Applies Template for each event of the day
						--><xsl:for-each select="current-group()"><xsl:call-template name="foo:translateTaskForDayView"/></xsl:for-each></g></g></xsl:for-each-group></defs><xsl:choose><xsl:when test="$mode eq 'Day' ">
					<!--DISPLAY DAY--><g transform="scale({$scaleDay},{$scaleDay})"><xsl:if test="$packedView eq 'false'"><use xlink:href="#TIMES"/></xsl:if><g transform="translate(120,0)"><xsl:call-template name="foo:printDayAndDate"><xsl:with-param name="date" select="$requestedDate"/><xsl:with-param name="displayDayName" select="xs:boolean('true')"/></xsl:call-template><use xlink:href="#T{$requestedDate}"/></g></g></xsl:when><xsl:when test="$mode eq 'Week' ">
					<!--DISPLAY WEEK--><g transform="scale({$scaleWeek},{$scaleWeek})"><xsl:if test="$packedView eq 'false'"><use xlink:href="#TIMES" transform="translate(0,15)"/></xsl:if>
						
	 					<!-- print the requested week --><g transform="translate(120,0)"><xsl:call-template name="foo:printWeekOfDay"><xsl:with-param name="date" select="$requestedDate"/><xsl:with-param name="displayDayName" select="xs:boolean('true')"/></xsl:call-template></g></g></xsl:when><xsl:otherwise>
					<!--DISPLAY MONTH--><g transform="scale({$scaleMonth},{$scaleMonth})"><g transform="translate(0,0)"><xsl:call-template name="foo:printWeekOfDay"><xsl:with-param name="date" select="$weeksInThisMonth/week1"/><xsl:with-param name="displayDayName" select="xs:boolean('true')"/></xsl:call-template><xsl:call-template name="foo:printHorizontalLine"/><g transform="translate(0,{$displacement})"><xsl:call-template name="foo:printWeekOfDay"><xsl:with-param name="date" select="$weeksInThisMonth/week2"/><xsl:with-param name="displayDayName" select="xs:boolean('false')"/></xsl:call-template><xsl:call-template name="foo:printHorizontalLine"/><g transform="translate(0,{$displacement})"><xsl:call-template name="foo:printWeekOfDay"><xsl:with-param name="date" select="$weeksInThisMonth/week3"/><xsl:with-param name="displayDayName" select="xs:boolean('false')"/></xsl:call-template><xsl:call-template name="foo:printHorizontalLine"/><g transform="translate(0,{$displacement})"><xsl:call-template name="foo:printWeekOfDay"><xsl:with-param name="date" select="$weeksInThisMonth/week4"/><xsl:with-param name="displayDayName" select="xs:boolean('false')"/></xsl:call-template><xsl:call-template name="foo:printHorizontalLine"/><xsl:if test="xs:integer($weeksInThisMonth/maxWeek) ge 5"><g transform="translate(0,{$displacement})"><xsl:call-template name="foo:printWeekOfDay"><xsl:with-param name="date" select="$weeksInThisMonth/week5"/><xsl:with-param name="displayDayName" select="xs:boolean('false')"/></xsl:call-template><xsl:call-template name="foo:printHorizontalLine"/><xsl:if test="xs:integer($weeksInThisMonth/maxWeek) eq 6"><g transform="translate(0,{$displacement})"><xsl:call-template name="foo:printWeekOfDay"><xsl:with-param name="date" select="$weeksInThisMonth/week6"/><xsl:with-param name="displayDayName" select="xs:boolean('false')"/></xsl:call-template><xsl:call-template name="foo:printHorizontalLine"/></g></xsl:if></g></xsl:if></g></g></g></g></g></xsl:otherwise></xsl:choose></svg></xsl:template></xsl:stylesheet>