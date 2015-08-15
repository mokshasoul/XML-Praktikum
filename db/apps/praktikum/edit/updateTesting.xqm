xquery version "3.0";

module namespace  updateFunction = "http://www.update.com";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare option exist:serialize "method=xhtml media-type=text/xml indent=no  process-xsl-pi=no";
declare function updateFunction:updateSeries($post-req as item()*)
{
let $collection :=  'xmldb:exist:///db/apps/praktikum'
let $login := xmldb:login($collection, 'admin', '')

let $note := $post-req//note
let $description := $post-req//description
let $endDate := $post-req//endDate
let $startDate := $post-req//startDate
let $startTime := $post-req//startTime
let $endTime := $post-req//endTime
let $attendees := $post-req//attendees
let $origDescription := $post-req//origDescription
let $location := $post-req//location
let $mode := $post-req//mode
let $series := $post-req//series


let $data-path := '/db/apps/praktikum/data/'
let $dbCal := doc('/db/apps/praktikum/data/sampleCalendarX.xml')



let $superEvent := $dbCal//superEvents/superEvent[@description=$origDescription]
let $eventRuleDesc := xs:string ($superEvent//eventRule[1]/@description)
let $recurrencePattern := xs:string($superEvent//eventRule[1]/recurrencePattern)
let $newEventRule := concat($description,'_',substring-after($eventRuleDesc,'_'))
let $superEventRep :=<superEvent description="{$description}" categories="teaching">
                    <eventRules>
                        <eventRule description="{$newEventRule }" startTime="{$startTime}" endTime="{$endTime}" note="">
                            <recurrencePattern>{$newEventRule }</recurrencePattern>
                         <attendees>
                        {
                            for $attendee in tokenize($attendees,',')
                            return
                            <attendee>$attendee</attendee> 
                        }
                    </attendees>
                        </eventRule>
                    </eventRules>
                </superEvent>

let $assocPattern := 
<root>{
$dbCal//patterns/*[contains(@description,substring-before($recurrencePattern,'_'))]}
</root>
let $newPattern := for $pattern in $assocPattern/*
                    return
                   if( $pattern/name() = 'intersectionPattern') then(
                        let $replacementPattern := <intersectionPattern description="{$newEventRule}">
                            <firstPattern>{xs:string($description)}</firstPattern>
                            <furtherPatterns>
                                {for $furtherPattern in $pattern//furtherPatterns/*
                                    return
                                        <furtherPattern> {$furtherPattern/text()}
                                        </furtherPattern>
                                }
                           </furtherPatterns>
                         </intersectionPattern>
                        return
                     update replace $dbCal//patterns/*[@description=$pattern/@description] with $replacementPattern
                    )else(
                         if( $pattern/name() = 'dailyPattern') then(
                             let $replacementPattern := <dailyPattern description="{$description}" startDate="{$startDate}" endDate="{$endDate}"/>
                             return
                                 update replace $dbCal//patterns/*[@description=$pattern/@description] with $replacementPattern
                          )else()
                     )               
                       
let $update := update replace $superEvent with $superEventRep
 
                return
                <root>
            {$dbCal}
    </root>
};

declare function updateFunction:updateOccurence($post-req as item()*){
let $collection :=  'xmldb:exist:///db/apps/praktikum'
let $login := xmldb:login($collection, 'admin', '')

let $note := $post-req//note
let $description := $post-req//description
let $endDate := $post-req//endDate
let $startDate := $post-req//startDate
let $startTime := $post-req//startTime
let $endTime := $post-req//endTime
let $attendees := $post-req//attendees
let $origDescription := $post-req//origDescription
let $location := $post-req//location
let $mode := $post-req//mode
let $series := $post-req//series

let $data-path := '/db/apps/praktikum/data/'
let $dbCal := doc('/db/apps/praktikum/data/sampleCalendarX.xml')
let $superEvent := $dbCal//superEvents/superEvent[@description=$origDescription]
return
<root > love is in the air </root>
};