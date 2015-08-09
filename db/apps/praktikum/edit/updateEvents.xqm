xquery version "3.0";

(: echo-post.xq: Return all data from an HTTP post to the caller. 
 transform:transform($input, $xsl, $param)
 :)

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

(: 
let $test := 
<data>
    <description>Test</description>
    <category>Test</category>
    <startDate>2015-08-19</startDate>
    <endDate>2015-08-26</endDate>
    <startTime>10:00</startTime>
    <endTime>12:00</endTime>
    <note>test</note>
    <attendees>
    <attendee>test</attendee>
    </attendees>
    <location>test</location>
</data>
:)

let $description := $post-req//description
let $endDate := $post-req//endDate
let $startDate := $post-req//startDate
let $startTime := $post-req//startTime
let $endTime := $post-req//endTime
let $attendees := $post-req//attendees
let $note := $post-req//note
let $location := $post-req//location

(:
let $description := $test//description
let $endDate := $test//endDate
let $startDate := $test//startDate
let $startTime := $test//startTime
let $endTime := $test//endTime
let $attendees := $test//attendees
let $location := $test//location
:)

let $dbCal := doc('/db/apps/praktikum/data/sampleCalendarX2.xml')
let $event :=  
<superEvent description="{$description}">
            <eventRules>
                <eventRule description="{$description}" startTime="{$startTime}" endTime="{$endTime}" note="">
                    <attendees>
                        {
                            for $attendee in tokenize($attendees,',')
                            return
                            <attendee description="{$attendee}" /> 
                        }
                    </attendees>
                    <note> {$note} </note>
                    <location>{$location}</location>
                </eventRule>
            </eventRules>
        </superEvent>

let $pattern := 
    <dailyPattern description="{$description}" startDate="{$startDate}" endDate="{if($endDate) then ($endDate) else ($startDate)}" />
    
let $targetEvent := $dbCal//superEvents/superEvent[@description=$description]
let $test2 := update replace $targetEvent with $event
let $targetPattern := $dbCal//patterns/dailyPattern[@description=$description]
let $test3 := update replace $targetPattern with $pattern
    return
        $dbCal
     