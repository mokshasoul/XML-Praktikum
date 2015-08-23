xquery version "3.0";

(: echo-post.xq: Return all data from an HTTP post to the caller. 
 transform:transform($input, $xsl, $param)
 :)
 import module namespace functx = "http://www.functx.com" at '../views/functx-1.0-doc-2007-01.xq';
import module namespace getEvents = "http://www.getEvents.com" at '../views/getEventsFunctions.xqm';
import module namespace helper = "http://www.help.com" at '../views/helperFunctions.xqm';
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare option exist:serialize "method=xhtml media-type=text/xml indent=no  process-xsl-pi=no";

let $collection :=  'xmldb:exist:///db/apps/praktikum'
let $login := xmldb:login($collection, 'admin', '')

let $data-path := '/db/apps/praktikum/data/'
let $attribute := request:set-attribute('betterform.filter.ignoreResponseBody', 'true')
let $post-req := request:get-data()

let $description := xs:string($post-req//description)
let $endDate := xs:string($post-req//endDate)
let $startDate := xs:string($post-req//startDate)
let $startTimeInput := xs:string($post-req//startTime)
let $endTimeInput := xs:string($post-req//endTime)
let $attendees := xs:string($post-req//attendees)
let $location := xs:string($post-req//location)
let $recurrencePattern := xs:string($post-req//repeat)
let $monthMode := xs:string($post-req//monthlyCardinalOrOrdinal)
let $yearlyMode := xs:string($post-req//yearlyCardinalOrOrdinal)
let $category := xs:string($post-req//category)
let $note := xs:string($post-req//note)
let $ordinality := xs:string($post-req//ordinalType)
let $mode := if ($startDate = $endDate) then(
        'singleDay'
    )else(
$post-req//patternType
)

(: check if times are valid :)
let $error := if(not(matches($startTimeInput, '^\d\d:\d\d$') and matches($endTimeInput, '^\d\d:\d\d$') and $startTimeInput < $endTimeInput))
then <xf:action if="(xs:boolean='true')"></xf:action> else ()

let $startTime := concat($startTimeInput, ':00')
let $endTime := concat($endTimeInput, ':00')

let $days := $post-req//repeatDayOfWeek
let $daysCount := if(contains($days," ")) then
                    count(tokenize($days," "))
                  else
                    1


let $dbCal := helper:calendarDoc()
let $eventRuleDesc := concat($description,"_1")
let $event :=  if ($mode eq 'singleDay' or ($mode eq 'weeklyPattern' and $daysCount < 2) or ($mode eq 'dailyPattern') ) then(
<superEvent description="{$description}" categories="{$category}">
            <eventRules>
                <eventRule description="{$description}" startTime="{$startTime}" endTime="{$endTime}" note="{$note}">
                <recurrencePattern>{$description}</recurrencePattern>
                    <attendees>
                        { for $attendee in tokenize($attendees, ",") return
                        <attendee>{functx:trim($attendee)}</attendee> }
                    </attendees>
                    <location>{$location}</location>
                </eventRule>
            </eventRules>
        </superEvent>
        
)else( 
<superEvent description="{$description}" categories="{$category}">
            <eventRules>
                <eventRule description="{$eventRuleDesc}" startTime="{$startTime}" endTime="{$endTime}" note="{$note}">
                <recurrencePattern>{$eventRuleDesc}</recurrencePattern>
                    <attendees>
                        { for $attendee in tokenize($attendees, ",") return
                        <attendee>{functx:trim($attendee)}</attendee> }
                    </attendees>
                    <location>{$location}</location>
                </eventRule>
            </eventRules>
        </superEvent>
        )
let $store-return-status := update insert $event into $dbCal//superEvents
(: pattern types :)

let $infiniteDay := if($startDate and $mode eq "dailyPattern" and not($endDate)) then
    let $pattern := <unionPattern description="{$description}">
        <firstPattern>monday</firstPattern>
        <furtherPatterns>
            <furtherPattern>tuesday</furtherPattern>
            <furtherPattern>wednesday</furtherPattern>
            <furtherPattern>thursday</furtherPattern>
            <furtherPattern>friday</furtherPattern>
            <furtherPattern>saturday</furtherPattern>
            <furtherPattern>sunday</furtherPattern>
        </furtherPatterns>
        </unionPattern>
      return
      update insert $pattern into $dbCal//patterns 
  else()
        
let $dailyPattern:= if ($startDate and $endDate) then  
    let $pattern :=  <dailyPattern description="{$description}" startDate="{$startDate}" endDate="{$endDate}" />
    return
        update insert $pattern into $dbCal//patterns 
    else (xs:boolean('false')) 


    

let $weeklyPattern := if (($mode eq "weeklyPattern") and $daysCount = 1) then (
    let $pattern := <weeklyPattern description="{$description}" dayOfWeek="{functx:capitalize-first($days)}" />
    return
    update insert $pattern into $dbCal//patterns
    )else()
    
let $isUnionPattern := ($mode eq "weeklyPattern") and ($daysCount > 1 or ($startDate and $endDate))
let $isMonthlyPattern := ($mode eq "monthlyPattern") and ($monthMode eq "monthlyOrdinal")

let $furtherPatternDescription := if (not($startDate and $endDate)) then $eventRuleDesc else concat($eventRuleDesc,'_f')


let $usedPattern := if ($isUnionPattern) then $furtherPatternDescription
                    else $description
    
let $unionPattern := if ($isUnionPattern) then (
        let $pattern := <unionPattern description="{$furtherPatternDescription}">
         <firstPattern>{tokenize($days, " ")[1]}</firstPattern>
         <furtherPatterns> {
             for $day at $pos in tokenize($days, " ")
             return
                 if ($day and $pos > 1) then(
                     <furtherPattern>{$day}</furtherPattern>
                )else()
         }
          </furtherPatterns>
    </unionPattern>
         return 
         update insert $pattern into $dbCal//patterns
    )else()
    
let $monthlyPattern := if ($isMonthlyPattern) then
    let $pattern := <ordinalMonthlyPattern ordinal="{$ordinality}" dayType="{functx:day-of-week-name-en($startDate)}"
            description="{$furtherPatternDescription}"/>
            return
  update insert $pattern into $dbCal//patterns
    else(
    if($monthMode eq "monthlyCardinal") then
    (
    let $pattern := <cardinalMonthlyPattern dayOfMonth="{fn:day-from-date(xs:date($startDate))}" description="{$furtherPatternDescription}"/>
    return
  update insert $pattern into $dbCal//patterns
    )else()
    )
let $yearlyPattern := if (($mode eq "yearlyPattern") and ($yearlyMode eq "yearlyOrdinal")) then 
        let $pattern := <ordinalYearlyPattern ordinal="{$ordinality}" dayType="{functx:day-of-week-name-en($startDate)}"
month="{functx:month-name-en($startDate)}" description="{$furtherPatternDescription}"/>
return
  update insert $pattern into $dbCal//patterns
else(
if ($yearlyMode eq "yearlyCardinal") then
 let $pattern := <cardinalYearlyPattern dayOfMonth="{fn:day-from-date(xs:date($startDate))}" month="{functx:month-name-en($startDate)}"
description="{$furtherPatternDescription}"/>
return
    update insert $pattern into $dbCal//patterns
else()
)


let $intersectionPattern := if ($startDate and $endDate and not($mode eq "dailyPattern")) then(
                let $pattern := <intersectionPattern description="{$eventRuleDesc}">
            <firstPattern>{$description}</firstPattern>
            <furtherPatterns>
                     <furtherPattern>{$furtherPatternDescription}</furtherPattern>
            </furtherPatterns>
        </intersectionPattern>
        return update insert $pattern into $dbCal//patterns
    ) else ()



return
<root/>
