xquery version "3.0";

import module namespace functx = 'http://www.functx.com' at 'functx-1.0-doc-2007-01.xq';

(:  this query can be used to add the number of events that overlap with the event. This will be needed to represent the events in the overview properly :)

for $e in doc('simpleEvents.xml')//event
let $cnt := count(doc('simpleEvents.xml')//event[@date = $e/@date and ((@startTime > $e/@startTime and @startTime<$e/@endTime) or (@endTime > $e/@startTime and @endTime<$e/@endTime))])
return functx:add-attributes($e, xs:QName('intersecting'), $cnt)