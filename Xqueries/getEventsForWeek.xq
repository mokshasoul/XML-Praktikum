xquery version "3.0";

import module namespace helper = 'http://www.help.com' at 'helperFunctions.xqm';

let $date:=xs:date('2015-06-09')



for $superEvent in doc('sampleCalendarX.xml')//superEvents/superEvent
for $event in $superEvent/eventRules/eventRule
for $eventDay in helper:getDatesInPatternWithinWeek($date, $event/recurrencePattern/text())
order by $eventDay
return 
	<event description="{$superEvent/@description}" categories="{$superEvent/@categories}" date="{$eventDay}"
		startTime="{$event/@startTime}" endTime="{$event/@endTime}" note="{$event/@note}">
		<attendees>
            {for $attendee in $event/attendees/attendee
		    return 
			<attendee description="{$attendee/text()}"/>
		    }		
		    </attendees>
		<location description="{$event/location/text()}"/>
	</event>
