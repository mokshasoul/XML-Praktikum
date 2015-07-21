xquery version "3.0";

module namespace getEvents = "http://www.getEvents.com";
import module namespace functx = 'http://www.functx.com' at 'functx-1.0-doc-2007-01.xq';
import module namespace helper = 'http://www.help.com' at 'helperFunctions.xqm';


declare function getEvents:getBasicEventsForDay($date as xs:date){
for $superEvent at $s in doc('sampleCalendarX2.xml')//superEvents/superEvent
for $event at $e in $superEvent/eventRules/eventRule
where helper:isDateInPattern($date, $event/recurrencePattern/text())
order by $event/@startTime, $event/@endTime
return 
	<event id="{$date}_{$event/@startTime}_{$event/@endTime}_{$s}_{$e}" description="{$superEvent/@description}" categories="{$superEvent/@categories}" date="{$date}"
		startTime="{$event/@startTime}" endTime="{$event/@endTime}" note="{$event/@note}" mondayOfWeek="{helper:getMondayOfWeek($date)}">
		<attendees>
            {for $attendee in $event/attendees/attendee
		    return 
			<attendee description="{$attendee/text()}"/>
		    }		
		    </attendees>
		<location description="{$event/location/text()}"/>
	</event>
};

declare function getEvents:getEventDaysOfWeek($date as xs:date){
    
    for $superEvent in doc('sampleCalendarX2.xml')//superEvents/superEvent
for $event in $superEvent/eventRules/eventRule
for $eventDay in helper:getDatesInPatternWithinWeek($date, $event/recurrencePattern/text())
order by $eventDay, $event/@startTime, $event/@endTime
return $eventDay
};

declare function getEvents:getEventDaysOfMonth($date as xs:date){
    for $superEvent in doc('sampleCalendarX2.xml')//superEvents/superEvent
for $event in $superEvent/eventRules/eventRule
for $eventDay in helper:getDatesInPatternWithinMonth($date, $event/recurrencePattern/text())
order by $eventDay, $event/@startTime, $event/@endTime
return $eventDay
};

declare function getEvents:getEventsForDay($date as xs:date){
getEvents:refineEvents(getEvents:getBasicEventsForDay($date))
};

declare function getEvents:getEventsForWeek($date as xs:date){
for $eventDay in  distinct-values(getEvents:getEventDaysOfWeek($date))
return getEvents:refineEvents(getEvents:getBasicEventsForDay($eventDay))
};

declare function getEvents:getEventsForMonth($date as xs:date){
   for $eventDay in  distinct-values(getEvents:getEventDaysOfMonth($date))
return getEvents:refineEvents(getEvents:getBasicEventsForDay($eventDay))
};

declare function getEvents:refineEvents($events){
  for $e in $events
let $cnt := count($events[@date = $e/@date and ((@startTime > $e/@startTime and @startTime<$e/@endTime) or (@endTime > $e/@startTime and @endTime<$e/@endTime))])
return <events>{functx:add-attributes($e, xs:QName('intersecting'), $cnt)}</events>  
};