xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform = "http://exist-db.org/xquery/transform";




let $calendar := doc('/db/apps/praktikum/data/events.xml')
let $eventData := request:get-data()
(: MAIN APPEND OPERATION --> replace $calendar with our Events File 
                         --> replace $eventData with our XForms POST instance
let $eventData := doc('/db/apps/learning/data.xml')
:)
let $replace :=
   <event description="{$eventData//description}" categories="{$eventData//category}" date="{$eventData//date}" startTime="{$eventData//startTime}" endTime="{$eventData//endTime}" note="{$eventData//note}">
    <attendees>
    {for $attendee in $eventData//attendees/attendee
       return
       <attendee description="{$attendee}"/>
     }
     </attendees>
     <location description="{$eventData//location}"/>
   </event>
return
    update insert $replace into $calendar/events 