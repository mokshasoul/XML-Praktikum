xquery version "3.0";


module namespace getEvents = "http://www.getEvents.com";


import module namespace functx = 'http://www.functx.com' at 'functx-1.0-doc-2007-01.xq';

import module namespace helper = 'http://www.help.com' at 'helperFunctions.xqm';


declare function getEvents:getBasicEventsForDay($date as xs:date)
{
    for $superEvent at $s in doc('../data/sampleCalendarX2.xml')//superEvents/superEvent
    for $event at $e in $superEvent/eventRules/eventRule
    where helper:isDateInPattern($date, $event/recurrencePattern/text())
    order by $event/@startTime, $event/@endTime
    return
 <event id="{ $date }_{ $event/@startTime }_{ $event/@endTime }_{ $s }_{ $e }" description="{ $superEvent/@description
    }" categories="{ $superEvent/@categories }" date="{ $date }"
  startTime="{ $event/@startTime }" endTime="{ $event/@endTime }" note="{ $event/@note }" mondayOfWeek="{
            helper:getMondayOfWeek($date)
        }">
  <attendees>
        {
            for $attendee in $event/attendees/attendee
            return
   <attendee description="{ $attendee/text() }"/>
        }        
      </attendees>
  <location description="{ $event/location/text() }"/>
 </event>
};

declare function getEvents:getEventDaysOfWeek($date as xs:date)
{
    for $superEvent in doc('../data/sampleCalendarX2.xml')//superEvents/superEvent
    for $event in $superEvent/eventRules/eventRule
    for $eventDay in helper:getDatesInPatternWithinWeek($date, $event/recurrencePattern/text())
    order by $eventDay, $event/@startTime, $event/@endTime
    return $eventDay
};

declare function getEvents:getEventDaysOfMonth($date as xs:date)
{
    for $superEvent in doc('../data/sampleCalendarX2.xml')//superEvents/superEvent
    for $event in $superEvent/eventRules/eventRule
    for $eventDay in helper:getDatesInPatternWithinMonth($date, $event/recurrencePattern/text())
    order by $eventDay, $event/@startTime, $event/@endTime
    return $eventDay
};

declare function getEvents:getEventsForDay($date as xs:date)
{
      <events>{
        getEvents:refineEvents(getEvents:getBasicEventsForDay($date))
    }</events>
};

declare function getEvents:getEventsForWeek($date as xs:date)
{
      <events>{
        for $eventDay in distinct-values(getEvents:getEventDaysOfWeek($date))
        return getEvents:refineEvents(getEvents:getBasicEventsForDay($eventDay))
    }</events>
};

declare function getEvents:getEventsForMonth($date as xs:date)
{
    let $maxNumOfEventsOnDay := max(
         for $eventDay in distinct-values(getEvents:getEventDaysOfMonth($date))
         let $eventsOnThisDay := getEvents:getBasicEventsForDay($eventDay)
        return count($eventsOnThisDay/@id)
        )
      return <events maxNumOfEventsOnDay="{$maxNumOfEventsOnDay}">{
        for $eventDay in distinct-values(getEvents:getEventDaysOfMonth($date))
        return getEvents:refineEvents(getEvents:getBasicEventsForDay($eventDay))
    }</events>
};

(: adds number of intersecting events for each event :)
declare function getEvents:refineEvents($events)
{
    getEvents:refineEvents2(for $e in $events
                            let $cnt :=
                                count($events[@date = $e/@date and (
                                        (@startTime ge $e/@startTime and @startTime < $e/@endTime) 
                                    or (@startTime > $e/@startTime and @startTime le $e/@endTime) 
                                    or (@endTime ge $e/@startTime and @endTime < $e/@endTime) 
                                    or (@endTime > $e/@startTime and @endTime le $e/@endTime))])-1
                            return functx:add-attributes($e, xs:QName('intersecting'), $cnt))
};


(: adds position numbers of intersecting events :)
declare function getEvents:refineEvents2($events)
{
    for $resultEvents in
        ( let $maxIntersection := max($events/xs:integer(@intersecting))
        for $i in (0 to $maxIntersection)
        for $eventsNintersections at $p in $events[@intersecting = $i]
        return functx:add-attributes($eventsNintersections, xs:QName('pos'), $i - ($p mod ($i + 1))))
    order by $resultEvents/@date, $resultEvents/@startTime, $resultEvents/@endTime
    return $resultEvents
};