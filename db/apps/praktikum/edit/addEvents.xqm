xquery version "3.0";

(: echo-post.xq: Return all data from an HTTP post to the caller. 
 transform:transform($input, $xsl, $param)
 :)
 import module namespace fn = "http://www.functx.com" at '../views/functx-1.0-doc-2007-01.xq';
import module namespace getEvents = "http://www.getEvents.com" at '../views/getEventsFunctions.xqm';
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

let $description := $post-req//description
let $endDate := $post-req//endDate
let $startDate := $post-req//startDate
let $startTime := $post-req//startTime
let $endTime := $post-req//endTime
let $attendees := $post-req//attendees
let $location := $post-req//location
let $recurrencePattern := $post-req//repeat

let $mode := if ($startDate = $endDate) then(
        'singleDay'
    )else(
$post-req//patternType
)

let $days := $post-req//repeatDayOfWeek
let $daysCount := count(tokenize($days," "))


let $dbCal := doc('/db/apps/praktikum/data/calendarX2.xml')
let $eventRuleDesc := concat($description,"_1")
let $event :=  if ($mode eq 'singleDay' or ($mode eq 'weeklyPatter' and $daysCount < 2) or ($mode eq 'dailyPattern') ) then(
<superEvent description="{$description}">
            <eventRules>
                <eventRule description="{$description}" startTime="{$startTime}" endTime="{$endTime}" note="">
                <recurrencePattern>{$description}</recurrencePattern>
                    <attendees>
                        { for $attendee in tokenize($attendees, ",") return
                        <attendee>{$attendee}</attendee> }
                    </attendees>
                    <location>{$location}</location>
                </eventRule>
            </eventRules>
        </superEvent>
        
)else( 
<superEvent description="{$description}">
            <eventRules>
                <eventRule description="{$eventRuleDesc}" startTime="{$startTime}" endTime="{$endTime}" note="">
                <recurrencePattern>{$eventRuleDesc}</recurrencePattern>
                    <attendees>
                        { for $attendee in tokenize($attendees, ",") return
                        <attendee>{$attendee}</attendee> }
                    </attendees>
                    <location>{$location}</location>
                </eventRule>
            </eventRules>
        </superEvent>
        )
let $store-return-status := update insert $event into $dbCal//SuperEvents
(: pattern types :)

let $dailyPattern:= if ($startDate and $endDate) then  
    let $pattern :=  <dailyPattern description="{$description}" startDate="{$startDate}" endDate="{$endDate}" />
    return
        update insert $pattern into $dbCal//patterns 
    else (xs:boolean('false')) 

let $intersectionPattern := if ($dailyPattern and ($mode eq "weeklyPattern")) then(
                let $pattern := <intersectionPattern description="{$eventRuleDesc}">
            <firstPattern>{$dailyPattern/@description}</firstPattern>
            <furtherPatterns>{
                for $day in tokenize($days," ")
                return
                     <furtherPattern>{$day}</furtherPattern>
            }
            </furtherPatterns>
        </intersectionPattern>
        return update insert $pattern into $dbCal//patterns
    ) else ()
    

let $weeklyPattern := if (($mode eq "weeklyPattern") and $daysCount = 1) then (
    <weeklyPattern description="{$description}" dayOfWeek="{$days}" />
    )else()
    
let $unionPattern := if (($mode eq "weeklyPattern") and $daysCount > 1) then (
        let $pattern := <unionPattern description="{$eventRuleDesc}">
         <firstPattern>{tokenize($days, " ")[1]}</firstPattern>
         <furtherPatterns> {
             for $day in tokenize($days, " ")
             return
                 if ($day) then(
                     <furtherPattern>{$day}</furtherPattern>
                )else()
         }
          </furtherPatterns>
    </unionPattern>
         return 
         update insert $pattern into $dbCal//patterns
    )else()
    
let $monthlyPattern := if (($mode eq "monthlyPattern") and ($monthMode eq "day")) then
    <ordinalMonthlyPattern ordinal="first" dayType="{$startDate}"
            description="{$description}"/>
    else
    <cardinalMonthlyPattern dayOfMonth="{fn:day-of-week-name-en($startDate)}" description="{$description}"/>

let $yearlyPattern := if (($mode eq "yearlyPattern") and ($yearlyMode eq "day")) then 
        <ordinalYearlyPattern ordinal="second" dayType="Saturday"
month="{fn:month-name-en($startDate)}" description="{$description}"/>
else
<cardinalYearlyPattern dayOfMonth="{fn:day-of-week-name-en($startDate)}" month="{fn:month-name-en($startDate)}"
description="{$description}"/>
return
<root/>
