xquery version "3.0";

module namespace getEvents = "http://www.getEvents.com";

import module namespace helper = 'http://www.help.com' at 'helperFunctions.xqm';


declare function getEvents:getEventsForDay($date as xs:date){

for $superEvent in doc('sampleCalendarX2.xml')//superEvents/superEvent
for $event at $e in $superEvent/eventRules/eventRule
where helper:isDateInPattern($date, $event/recurrencePattern/text())
order by $event/@startTime, $event/@endTime
return 
	<event id="{$date}_{$event/@startTime}_{$event/@endTime}_{$e}" description="{$superEvent/@description}" categories="{$superEvent/@categories}" date="{$date}"
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


declare function getEvents:getEventsForWeek($date as xs:date){
for $eventDay in  distinct-values(getEvents:getEventDaysOfWeek($date))
return getEvents:getEventsForDay($eventDay)
};

declare function getEvents:getEventsForMonth($date as xs:date){
   for $eventDay in  distinct-values(getEvents:getEventDaysOfMonth($date))
return getEvents:getEventsForDay($eventDay)
};
