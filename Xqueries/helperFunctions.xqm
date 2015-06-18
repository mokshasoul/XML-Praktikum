xquery version "3.0";

module namespace helper = "http://www.help.com";

import module namespace functx = 'http://www.functx.com' at 'functx-1.0-doc-2007-01.xq';

declare function helper:isDateInPattern($date as xs:date, $patternName as xs:string){


let $pattern := doc('sampleCalendarX.xml')//patterns/*[@description=$patternName]

 
return switch($pattern/name())
 case "dailyPattern" return xs:date($pattern/@startDate) le $date and xs:date($pattern/@endDate) ge $date
 case "weeklyPattern" return functx:day-of-week-name-en($date) eq $pattern/@dayOfWeek
 case "unionPattern"  return
         let $isInfirstUnionPattern:= helper:isDateInPattern($date, $pattern/firstPattern/text())
         return $isInfirstUnionPattern or  (
            some $furtherPattern in $pattern/furtherPatterns/furtherPattern
            satisfies helper:isDateInPattern($date, $furtherPattern/text()))
case "intersectionPattern" return 
         let $isInfirstIntersectionPattern:= helper:isDateInPattern($date, $pattern/firstPattern/text()) 
         return $isInfirstIntersectionPattern and (
            every $furtherPattern in $pattern/furtherPatterns/furtherPattern
            satisfies helper:isDateInPattern($date, $furtherPattern/text()))
 case "differencePattern" return 
        let $isInfirstDifferencePattern:= helper:isDateInPattern($date, $pattern/firstPattern/text()) 
         return $isInfirstDifferencePattern  and not(
            some $furtherPattern in $pattern/furtherPatterns/furtherPattern
            satisfies helper:isDateInPattern($date, $furtherPattern/text())) 

     default return xs:boolean('true')
 
};


declare function helper:getDatesInPatternWithinWeek($date as xs:date, $pattern as xs:string){
    let $dateOfMonday := helper:getMondayOfWeek($date)
    
    for $i in (0 to 6)
    let $dayOfWeek := $dateOfMonday + xs:dayTimeDuration(concat('P',$i,'D'))
    where helper:isDateInPattern($dayOfWeek,$pattern)
    return  <dayInPattern>{$dayOfWeek}</dayInPattern>
};


declare function helper:getDatesInPatternWithinMonth($date as xs:date, $pattern as xs:string){
    let $dateOfFirstDayOfMonth := functx:first-day-of-month($date)
    
    for $i in (0 to functx:days-in-month($date)-1)
    let $dayOfMonth := $dateOfFirstDayOfMonth + xs:dayTimeDuration(concat('P',$i,'D'))
    where helper:isDateInPattern($dayOfMonth,$pattern)
    return  <dayInPattern>{$dayOfMonth}</dayInPattern>
};


declare function helper:getMondayOfWeek($date as xs:date){
        let $dayOfWeek := (functx:day-of-week($date)-1) mod 7
        
        return $date - xs:dayTimeDuration(concat('P',$dayOfWeek,'D'))
};

