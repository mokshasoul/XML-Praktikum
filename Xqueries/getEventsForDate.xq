xquery version "3.0";

module namespace dayView = "http://dayView.com";
import module namespace helper = 'http://www.help.com' at 'helperFunctions.xqm';

<<<<<<< HEAD
declare function dayView:view($date as xs:date) as node(){
for $superEvent in doc('sampleCalendarX.xml')//superEvents/superEvent
for $event in $superEvent/eventRules/eventRule
where helper:isDateInPattern($date, $event/recurrencePattern/text())
return (
=======
let $date:=xs:date('2015-06-09')


for $superEvent in doc('sampleCalendarX2.xml')//superEvents/superEvent
for $event in $superEvent/eventRules/eventRule
where helper:isDateInPattern($date, $event/recurrencePattern/text())
order by $event/@startTime, $event/@endTime
return 
>>>>>>> 55a58d0ca7643d7da8b62e53439d4985229c7473
	<event description="{$superEvent/@description}" categories="{$superEvent/@categories}" date="{$date}"
		startTime="{$event/@startTime}" endTime="{$event/@endTime}" note="{$event/@note}">
		<attendees>
            {for $attendee in $event/attendees/attendee
		    return 
			<attendee description="{$attendee/text()}"/>
		    }		
		    </attendees>
		<location description="{$event/location/text()}"/>
	</event>)
};
