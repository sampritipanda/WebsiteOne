Feature: Show Pending Hookups
  In order to let other members know which hookups are available
  As a user
  I would like to be able to create pending events

  Background:
    Given I am logged in
    And following events exist:
      | name     | description    | category        | event_date | start_time              | end_time                | repeats | time_zone |
      | Hookup 0 | hookup meeting | PairProgramming | 2014/02/03 | 2000-01-01 09:00:00 UTC | 2000-01-01 10:30:00 UTC | never   | UTC       |
      | Hookup 1 | hookup meeting | PairProgramming | 2015/02/03 | 2000-01-01 07:00:00 UTC | 2000-01-01 09:30:00 UTC | never   | UTC       |
      | Scrum 0  | hookup meeting | Scrum           | 2015/02/03 | 2000-01-01 07:00:00 UTC | 2000-01-01 09:30:00 UTC | never   | UTC       |
    When I go to the "Hookups" page

  Scenario: displaying pending events empty table
    Then I should see:
      | Pending Hookups |
      | Title           |
      | Time range      |
      | Actions         |

  Scenario: displaying existing pending events
    Then I should see:
      | Hookup 1       |
      | 07:00-09:30    |
      | Create Hangout |
    And I should see "Pending Hookups" before "Hookup 1"

  Scenario: displaying pending hookup events but not pending scrums
    Then I should see:
      | Hookup 1       |
      | 07:00-09:30    |
      | Create Hangout |
    And I should see "Pending Hookups" before "Hookup 1"
    And I should not see "Scrum 0"

  Scenario: display all non-expired events
    Given the time now is "2014-07-15 12:00:00 UTC"
    Then I should see:
      | Hookup 1       |
      | 07:00-09:30    |
      | Create Hangout |
    And I should see "Pending Hookups" before "Hookup 1"
    But I should not see "Hookup 0"
    And I should not see "Scrum 0"

  Scenario: Create hangout
    Given the time now is "2014-07-15 12:00:00 UTC"
    When I follow "start" for pending hookup "0"
    Then I should be on the event "show" page for "Hookup 1"
