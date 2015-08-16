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
                            <attendee>{$attendee}</attendee> 
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
                          )else(
                          if ( $pattern/name() = 'unionPattern') then (
                            let $replacementPattern := <unionPattern description="{concat($description,'_u_1')}">
                                <firstPattern>{if ($pattern/firstPattern = $eventRuleDesc) then $newEventRule else $pattern/firstPattern} </firstPattern>
                                    <furtherPatterns>
                                        {for $furtherPattern in $pattern//furtherPatterns/*
                                            return
                                                <furtherPattern> {$furtherPattern/text()}
                                                </furtherPattern>
                                        }
                                   </furtherPatterns>
                                </unionPattern>
                                return
                                update replace $dbCal//patterns/*[@description=$pattern/@description] with $replacementPattern
                          )else()
                          )
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


let $eventRuleDesc := xs:string ($superEvent//eventRule[1]/@description)
let $recurrencePattern := xs:string($superEvent//eventRule[1]/recurrencePattern)
let $newEventRule := concat($description,'_d_',substring-after($eventRuleDesc,'_'))
let $diffExist := for $eventRule in $superEvent/eventRules/*
                    return
                    if ($eventRule/name() = $newEventRule) then
                        $eventRule
                    else
                        xs:boolean('false')
                   
let $eventRule := if (not($diffExists)) then(
                      let $rule :=  <eventRule description="{$newEventRule }" startTime="{$startTime}" endTime="{$endTime}" note="">
                            <recurrencePattern>{$newEventRule }</recurrencePattern>
                         <attendees>
                        {
                            for $attendee in tokenize($attendees,',')
                            return
                            <attendee>$attendee</attendee> 
                        }
                    </attendees>
                        </eventRule>
                        return
                         update insert $rule into $superEvent/eventRules
        )else(
            $diffExist
            )
            let $diff := if ($diffExist) then(
                             let $furtherPattern := <furtherPattern> {$dailyPattern/@description} </furtherPattern>
                             return
                             update insert $furtherPattern into $dbCal//patterns[@description=$diffExist/recurrencePattern/text()]/furtherPatterns
            )else(
                let $diffPattern := 
                                <differencePattern description="{$newEventRule}">
                                <firstPattern>{$superEvent//EventRule[1]/recurrencePattern/text()}</firstPattern>
            <furtherPatterns>
            <furtherPattern>{$dailyPattern/@description}</furtherPattern>
            </furtherPatterns>
            </differencePattern>
            return 
                update insert $diffPattern into $dbCal//patterns
            )
            
return
<root>
{$dbCal}
</root>
};