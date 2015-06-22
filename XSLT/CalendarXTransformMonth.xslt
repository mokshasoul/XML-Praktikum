<?xml version="1.0" encoding="UTF-8" ?>


<xsl:stylesheet version="2.0" exclude-result-prefixes="xs functx" 
xmlns:foo="http://www.foo.org"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xlink="http://www.w3.org/1999/xlink" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns:functx="http://www.functx.com" 
xmlns:fn="http://www.w3.org/2005/xpath-functions">

	<xsl:output method="xml" indent="yes" standalone="no" doctype-public="-//W3C//DTD SVG 1.1//EN" doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" media-type="image/svg"/>
	
	<xsl:include href="functx-1.0-doc-2007-01.xsl"/>
	<xsl:include href="myFunctions.xsl"/>
	
	
	<xsl:param name="requestedDate" select="xs:date('2015-05-27')"/>
	
	<xsl:variable name="weeksInThisMonth">
		<xsl:variable name="firstMonday">
			<xsl:value-of select="xs:date(foo:getCertainDayOfWeek(functx:first-day-of-month($requestedDate),0))"/>
		</xsl:variable>
		<week1>
			<xsl:value-of select="$firstMonday"/>
		</week1>
		<week2>
			<xsl:value-of select="xs:date($firstMonday) + xs:dayTimeDuration('P7D')"/>
		</week2>
		<week3>
			<xsl:value-of select="xs:date($firstMonday) + xs:dayTimeDuration('P14D')"/>
		</week3>
		<week4>
			<xsl:value-of select="xs:date($firstMonday) + xs:dayTimeDuration('P21D')"/>
		</week4>
		<week5>
			<xsl:value-of select="xs:date($firstMonday) + xs:dayTimeDuration('P28D')"/>
		</week5>
		<week6>
			<xsl:value-of select="xs:date($firstMonday) + xs:dayTimeDuration('P35D')"/>
		</week6>
		<test>
			<xsl:value-of select="functx:first-day-of-month(xs:date($firstMonday) + xs:dayTimeDuration('P35D'))"/>
		</test>
		<!--
		maxWeek stores how many weeks actually belong to the month. We don't always want to display 6 weeks, this is just the maximum. Minimum weeks to be displayed is 4, so we 
		have to store whether we have 4, 5 or 6 weeks for this month
		 -->
		<maxWeek>
			<xsl:choose>
				<xsl:when test="(functx:first-day-of-month(xs:date($firstMonday) + xs:dayTimeDuration('P35D')))=functx:first-day-of-month($requestedDate)">
						6
					</xsl:when>
				<xsl:when test="(functx:first-day-of-month(xs:date($firstMonday) + xs:dayTimeDuration('P28D')))=functx:first-day-of-month($requestedDate)">
						5
					</xsl:when>
				<xsl:otherwise>
						4
					</xsl:otherwise>
			</xsl:choose>
		</maxWeek>
	</xsl:variable>
	<xsl:template match="/">
		<svg width="1472px" height="1972px" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
			<defs>
			<!--
				define the month to be displayed. For every week, first print the "template-week", then overlay the week from the week-svg (if this week exists, i.e. if the week has at least one event. Otherwise, the "use" will find 
				nothing, thus you will see just the default week with no events)
		 	-->
				<g id="MONTH{functx:first-day-of-month($requestedDate)}">
					<g transform="translate(0,0)">
						<xsl:call-template name="foo:printWeekOfDay">
							<xsl:with-param name="date" select="$weeksInThisMonth/week1"/>
						</xsl:call-template>
						<use xlink:href="CalendarXTransformWeek.xml#WEEKOF{$weeksInThisMonth/week1}"/>
						<xsl:call-template name="foo:printHorizontalLine"/>
						<g transform="translate(0,1544)"><!--1440 (timeline) +100 (header) +4 (horizontal line)-->
							<xsl:call-template name="foo:printWeekOfDay">
								<xsl:with-param name="date" select="$weeksInThisMonth/week2"/>
							</xsl:call-template>
							<use xlink:href="CalendarXTransformWeek.xml#WEEKOF{$weeksInThisMonth/week2}"/>
							<xsl:call-template name="foo:printHorizontalLine"/>
							<g transform="translate(0,1544)">
								<xsl:call-template name="foo:printWeekOfDay">
									<xsl:with-param name="date" select="$weeksInThisMonth/week3"/>
								</xsl:call-template>
								<use xlink:href="CalendarXTransformWeek.xml#WEEKOF{$weeksInThisMonth/week3}"/>
								<xsl:call-template name="foo:printHorizontalLine"/>
								<g transform="translate(0,1544)">
									<xsl:call-template name="foo:printWeekOfDay">
										<xsl:with-param name="date" select="$weeksInThisMonth/week4"/>
									</xsl:call-template>
									<use xlink:href="CalendarXTransformWeek.xml#WEEKOF{$weeksInThisMonth/week4}"/>
									<xsl:if test="xs:integer($weeksInThisMonth/maxWeek) ge 5">
										<xsl:call-template name="foo:printHorizontalLine"/>
										<g transform="translate(0,1544)">
											<xsl:call-template name="foo:printWeekOfDay">
												<xsl:with-param name="date" select="$weeksInThisMonth/week5"/>
											</xsl:call-template>
											<use xlink:href="CalendarXTransformWeek.xml#WEEKOF{$weeksInThisMonth/week5}"/>
											<xsl:if test="xs:integer($weeksInThisMonth/maxWeek) eq 6">
												<xsl:call-template name="foo:printHorizontalLine"/>
												<g transform="translate(0,1544)">
													<xsl:call-template name="foo:printWeekOfDay">
														<xsl:with-param name="date" select="$weeksInThisMonth/week6"/>
													</xsl:call-template>
													<use xlink:href="CalendarXTransformWeek.xml#WEEKOF{$weeksInThisMonth/week6}"/>
												</g>
											</xsl:if>
										</g>
									</xsl:if>
								</g>
							</g>
						</g>
					</g>
				</g>
			</defs>
			<use xlink:href="#MONTH{functx:first-day-of-month($requestedDate)}" transform="scale(0.25,0.2)"/>
		</svg>
	</xsl:template>
</xsl:stylesheet>