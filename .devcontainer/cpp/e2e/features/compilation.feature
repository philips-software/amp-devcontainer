Feature: Compilation

    Scenario: Build default configuration
        Given I select the default build configuration
        When I build configuration "host"
        Then the output should contain "Build finished with exit code 0"
