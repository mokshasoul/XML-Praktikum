xquery version "3.0";
(: Xquery to save new events. receives data via "post" from createTask.xqm :)

import module namespace getEvents = "http://www.getEvents.com" at 'getEventsFunctions.xqm';
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
let $repeat := $post-req//repeat
let $patternType := $post-req//patternType

let $dbCal := doc('/db/apps/praktikum/data/calendarX2.xml')

(: create entry :)
let $entry := if ($post-req) then(
    <superEvent description ="{$description}">
       <eventRules>
           <eventRule description="{$description}" startTime="$startTime" endTime="{$endTime}" note="">
                <attendees>
                    { for $attendee in tokenize($attendees, ",") return
                    <attendee>{$attendee}</attendee> }
                </attendees>
                <location>{$location}</location>
         </eventRule>
        </eventRules>)
            