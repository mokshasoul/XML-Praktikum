xquery version "3.0";


module namespace helper = "http://www.help.com";


import module namespace functx = 'http://www.functx.com' at 'functx-1.0-doc-2007-01.xq';


declare function helper:isDateInPattern($date as xs:date, $patternName as xs:string)
{
    let $pattern := doc('../data/sampleCalendarX.xml')//patterns/*[@description = $patternName]
    return
        switch ($pattern/name())
            case "dailyPattern"
                return xs:date($pattern/@startDate) le $date and xs:date($pattern/@endDate) ge $date
            case "weeklyPattern"
                return functx:day-of-week-name-en($date) eq $pattern/@dayOfWeek
            case "cardinalMonthlyPattern"
                return $pattern/@dayOfMonth eq fn:day-from-date($date)
            case "ordinalMonthlyPattern"
                return helper:getOrdinalOfMonth($date, $pattern/@ordinal, $pattern/@dayType) eq $date
            case "cardinalYealyPattern"
                return $pattern/@dayOfMonth eq fn:day-from-date($date) and $pattern/@month eq functx:month-name-en($date
                                                                                                                  )
            case "ordinalYearlyPattern"
                return helper:getOrdinalOfMonth($date, $pattern/@ordinal, $pattern/@dayType) eq $date and
                    $pattern/@month eq functx:month-name-en($date)
            case "unionPattern"
                return let $isInfirstUnionPattern := helper:isDateInPattern($date, $pattern/firstPattern/text())
                return
                    $isInfirstUnionPattern or (some $furtherPattern in $pattern/furtherPatterns/furtherPattern satisfies
                        helper:isDateInPattern($date, $furtherPattern/text()))
            case "intersectionPattern"
                return let $isInfirstIntersectionPattern := helper:isDateInPattern($date, $pattern/firstPattern/text())
                return
                    $isInfirstIntersectionPattern and (every $furtherPattern in $pattern/furtherPatterns/furtherPattern
                        satisfies helper:isDateInPattern($date, $furtherPattern/text()))
            case "differencePattern"
                return let $isInfirstDifferencePattern := helper:isDateInPattern($date, $pattern/firstPattern/text())
                return
                    $isInfirstDifferencePattern and not(some $furtherPattern in $pattern/furtherPatterns/furtherPattern
                                                            satisfies helper:isDateInPattern($date,
                                                                                             $furtherPattern/text()))
            default
                return xs:boolean('true')
};


declare function helper:getDatesInPatternWithinWeek($date as xs:date, $pattern as xs:string)
{
    let $dateOfMonday := helper:getMondayOfWeek($date)
    for $i in (0 to 6)
    let $dayOfWeek := $dateOfMonday + xs:dayTimeDuration(concat('P', $i, 'D'))
    where helper:isDateInPattern($dayOfWeek, $pattern)
    return <dayInPattern>{ $dayOfWeek }</dayInPattern>
};


declare function helper:getDatesInPatternWithinMonth($date as xs:date, $pattern as xs:string)
{
    (: this is either the 1st of the month (if the 1st is a monday) or the last monday of the previous month (this will
     : also be displayed later because we display all weeks containing least one day of the month :) let
        $dateOfFirstMonday := helper:getMondayOfWeek(functx:first-day-of-month($date))
    (: What is the last day we need? Note that we need full weeks, which means that we might need some days after the
     : month as well to complete the last week :) let $dateOfLastDay :=
        functx:previous-day(helper:getMondayOfWeek(functx:last-day-of-month($date) + xs:dayTimeDuration('P7D')))
    (: how many days are needed? :) let $numberOfDays :=
        fn:days-from-duration(xs:dayTimeDuration(xs:date($dateOfLastDay) - xs:date($dateOfFirstMonday)))
    for $i in (0 to $numberOfDays)
    let $dayOfMonth := $dateOfFirstMonday + xs:dayTimeDuration(concat('P', $i, 'D'))
    where helper:isDateInPattern($dayOfMonth, $pattern)
    return <dayInPattern>{ $dayOfMonth }</dayInPattern>
};


declare function helper:getMondayOfWeek($date as xs:date)
{
    let $dayOfWeek := ((functx:day-of-week($date) - 1) + 7) mod 7
    return $date - xs:dayTimeDuration(concat('P', $dayOfWeek, 'D'))
};


(: returns the date of the "ordinal" "whatever" of a month :)
(: for example: Returns the date of the "second" "tuesday" of month of 2015-05-01 :)
declare function helper:getOrdinalOfMonth($date as xs:date, $ordinal, $dayType)
{
    let $firstOfMonth := functx:first-day-of-month($date)
    let $firstDayOfType :=
        switch ($dayType)
            case "day"
                return $firstOfMonth
            case "weekDay"
                return if (functx:day-of-week-name-en($firstOfMonth) eq "Saturday") then
                    $firstOfMonth + xs:dayTimeDuration('P2D')
                else if (functx:day-of-week-name-en($firstOfMonth) eq "Sunday") then
                    $firstOfMonth + xs:dayTimeDuration('P1D')
                else
                    $firstOfMonth
        case "Monday"
                return $firstOfMonth + xs:dayTimeDuration(concat('P',
                                                                 6 - ((functx:day-of-week($firstOfMonth) + 5) mod 7),
                                                                 'D'))
            case "Tuesday"
                return $firstOfMonth + xs:dayTimeDuration(concat('P',
                                                                 6 - ((functx:day-of-week($firstOfMonth) + 4) mod 7),
                                                                 'D'))
            case "Wednesday"
                return $firstOfMonth + xs:dayTimeDuration(concat('P',
                                                                 6 - ((functx:day-of-week($firstOfMonth) + 3) mod 7),
                                                                 'D'))
            case "Thursday"
                return $firstOfMonth + xs:dayTimeDuration(concat('P',
                                                                 6 - ((functx:day-of-week($firstOfMonth) + 2) mod 7),
                                                                 'D'))
            case "Friday"
                return $firstOfMonth + xs:dayTimeDuration(concat('P',
                                                                 6 - ((functx:day-of-week($firstOfMonth) + 1) mod 7),
                                                                 'D'))
            case "Saturday"
                return $firstOfMonth + xs:dayTimeDuration(concat('P',
                                                                 6 - ((functx:day-of-week($firstOfMonth) + 0) mod 7),
                                                                 'D'))
            case "Sunday"
                return $firstOfMonth + xs:dayTimeDuration(concat('P',
                                                                 6 - ((functx:day-of-week($firstOfMonth) + 6) mod 7),
                                                                 'D'))
            default
                return $firstOfMonth
    (: This may be the last day of "dayType". However, this could also be one week to far (-> already in the next month)
     : :) let $ultimateDayOfTypeSuggestion := $firstDayOfType + xs:dayTimeDuration('P28D')
    let $ultimateDayOfType :=
        if (fn:month-from-date($ultimateDayOfTypeSuggestion) eq fn:month-from-date($firstDayOfType)) then
            $ultimateDayOfTypeSuggestion
        else
            $ultimateDayOfTypeSuggestion - xs:dayTimeDuration('P7D')
    let $penultimateDayOfType := $ultimateDayOfType - xs:dayTimeDuration('P7D')
    return
        switch ($ordinal)
            case "first"
                return $firstDayOfType
            case "second"
                return ($firstDayOfType + xs:dayTimeDuration('P7D'))
            case "third"
                return ($firstDayOfType + xs:dayTimeDuration('P14D'))
            case "fourth"
                return ($firstDayOfType + xs:dayTimeDuration('P21D'))
            case "penultimate"
                return $penultimateDayOfType
            case "ultimate"
                return $ultimateDayOfType
            default
                return $firstDayOfType
};


