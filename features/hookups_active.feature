Feature: Show Active Hookups
  In order to let other members know which hookups are active and available
  As a user
  I would like to view and manage active events

  Background:
    Given I am logged in
    And following events exist:
      | name     | description    | category        | event_date | start_time              | end_time                | repeats | time_zone |
      | Hookup 0 | hookup meeting | PairProgramming | 2014/02/03 | 2000-01-01 09:00:00 UTC | 2000-01-01 10:30:00 UTC | never   | UTC       |
      | Hookup 1 | hookup meeting | PairProgramming | 2015/02/03 | 2000-01-01 07:00:00 UTC | 2000-01-01 09:30:00 UTC | never   | UTC       |
      | Scrum 0  | hookup meeting | Scrum           | 2015/02/03 | 2000-01-01 07:00:00 UTC | 2000-01-01 09:30:00 UTC | never   | UTC       |
    And the events are all active
    When I go to the "Hookups" page


  Scenario: displaying active events table header
    Then I should see:
      | Active Hookups |
      | Title          |
      | Time range     |
      | Actions        |

  Scenario: displaying existing active events
    Then I should see "Active Hookups" before "Hookup 0"
    And I should see "Hookup 0" before "Hookup 1"
    And I should see "Hookup 1" before "Pending Hookups"

#  Scenario: Join hangout
#    Given the time now is "2014-07-15 12:00:00 UTC"
#    When I follow "join" for active hookup "1"
    #what next?

#  Scenario: Manage hangout
#    Given the time now is "2014-07-15 12:00:00 UTC"
#    When I follow "Manage Hangout" for active hookup "1"
#    Then I should be on the event "show" page for "Hookup 1"
